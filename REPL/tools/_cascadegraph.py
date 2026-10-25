#!/usr/bin/env python3
"""Is the publish cascade actually wired, or only configured? Graph it and check it.

    python3 REPL/tools/_cascadegraph.py            human report
    python3 REPL/tools/_cascadegraph.py --json     nodes/edges/findings, for the admin pane

WHY THIS EXISTS.  `.wasp/cross-pollinate.yml` is a HAND-MAINTAINED description of a thing that
changes on its own -- packages get added to a repo, a consumer picks up a new dependency -- and a
description that drifts from what it describes fails SILENTLY.  Nothing errors; the cascade simply
skips what it was never told about.

That is not hypothetical.  Until 2026-10-25 the config listed `ouronet-core` and `ouronet-codex`
under `_libs/ouronet-libs` and nothing else, while `packages/talos-registry` sat on disk beside
them and OuronetUI pinned it in `dependencies`.  **The package most affected by every on-chain
deploy was the one package the cascade did not know existed.**  After a deploy the registry
regenerated, the package rebuilt locally, and nothing reached the consumer -- which went on
validating against a surface the chain no longer had.  No step failed.

So the two checks that matter most are the ones that find what is MISSING, and both run in the
direction the config cannot see:

    E.  a publishable package ON DISK that the config does not declare
    H.  a consumer dep that RESOLVES to a workspace package with no edge carrying it

A config review reads what is written.  These two ask what is not.
"""
import io
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OURONET = os.path.dirname(os.path.dirname(HERE))
WS = os.path.dirname(os.path.dirname(OURONET))
CFG = os.path.join(WS, ".wasp", "cross-pollinate.yml")


def jload(p):
    try:
        with io.open(p, encoding="utf-8") as fh:
            return json.load(fh)
    except Exception:
        return None


def discover_packages(root):
    """Every publishable package in a repo, however it is laid out.

    THREE LAYOUTS, AND ASSUMING ONE IS A FALSE-POSITIVE FACTORY. The first cut of this looked in
    `packages/` only and duly reported `@ouronet/dalos-crypto` as "declared but not on disk" --
    it lives at `DALOS_Crypto/ts/package.json`, a custom directory, which the publisher explicitly
    supports ("single-package, multi-package monorepo (npm workspaces / packages/* / custom
    dirs), and plain repos"). A validator that reports a correct config as broken gets ignored,
    and then it protects nothing. So: repo ROOT, then `packages/*`, then any other first-level
    directory, skipping the obvious non-package ones.
    """
    found = {}
    cands = [root, *(os.path.join(root, "packages", d)
                     for d in (sorted(os.listdir(os.path.join(root, "packages")))
                               if os.path.isdir(os.path.join(root, "packages")) else []))]
    skip = {"node_modules", ".git", "dist", "build", "coverage", ".wasp", ".bee", "docs"}
    try:
        cands += [os.path.join(root, d) for d in sorted(os.listdir(root))
                  if os.path.isdir(os.path.join(root, d))
                  and d not in skip and not d.startswith(".") and d != "packages"]
    except OSError:
        pass
    for c in cands:
        pj = jload(os.path.join(c, "package.json"))
        if pj and pj.get("name") and pj["name"] not in found:
            found[pj["name"]] = {
                "dir": os.path.relpath(c, root), "version": pj.get("version"),
                "private": bool(pj.get("private")),
                "publishable": not pj.get("private") and bool(pj.get("publishConfig")),
            }
    return found


def sh(args, cwd=None, timeout=25):
    """Run a command, return (rc, stdout+stderr). Never raises -- a missing binary is a FINDING."""
    import subprocess
    try:
        r = subprocess.run(args, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return r.returncode, (r.stdout + r.stderr).strip()
    except FileNotFoundError:
        return 127, f"{args[0]}: not found"
    except Exception as e:                                   # noqa: BLE001
        return 1, str(e)


def dryrun(repos, declared, findings):
    """The preflight: would a publish actually succeed, RIGHT NOW?

    The static checks above ask "is the config a faithful description of the tree". That is
    necessary and not sufficient -- a perfectly described cascade still fails on a dirty worktree,
    an expired npm token, a branch that is behind its remote, or a version already on the
    registry. Each of those is invisible until the publish is half done, which is the worst time
    to learn it: `npm publish` cannot be undone after 72 hours, and a partly-published cascade
    leaves consumers pinned to versions that do not exist.

    READ-ONLY BY CONSTRUCTION. `npm publish --dry-run` packs the tarball and contacts the registry
    for validation but uploads nothing; `git status`/`rev-list` and `npm view` only read. Nothing
    here can change the tree, the registry or a remote.
    """
    # LOCAL NPM LOGIN IS NOT THE GATE, AND SAYING IT IS GETS THIS TOOL SWITCHED OFF.
    # The first cut reported "npm is not authenticated -- every publish would fail" as an ERROR.
    # That is wrong here: `ouronet-libs/.github/workflows/publish.yml` publishes with
    # `--provenance` and its own comment says "the OIDC exchange happens inside `npm publish`
    # itself" -- npm Trusted Publishing, where GitHub Actions trades an OIDC token with npm
    # directly. ZERO repo secrets and no local login is the CORRECT state for that workflow.
    rc, who = sh(["npm", "whoami"])
    add(findings, "info", "NPM-LOCAL-AUTH",
        f"local npm: {'logged in as ' + who if rc == 0 else 'not logged in'} "
        f"(only matters if a repo publishes from this machine rather than CI).")

    rc, _ = sh(["gh", "auth", "status"])
    if rc != 0:
        add(findings, "warn", "GH-NO-AUTH",
            "GitHub CLI not authenticated -- release creation and CI waiting will not work.",
            "gh auth login")

    for r in repos:
        if not r.get("publishes"):
            continue
        rel = r.get("path", "?")
        root = os.path.join(WS, rel)
        if not os.path.isdir(root):
            continue

        # A DIRTY TREE ONLY MATTERS IF THIS REPO IS ABOUT TO PUBLISH, and the first version of
        # this check did not ask. It warned on DALOS_Crypto -- 108 changes, every tracked one a
        # LINE-ENDING flip (git diff -w was empty) and zero commits since its last release tag, so
        # the cascade would not queue it at all. A yellow that cannot be acted on is the kind that
        # gets the whole panel ignored, which is exactly the failure this tool was written to
        # avoid. So: establish whether the repo HAS anything to publish, and grade accordingly.
        rc, out = sh(["git", "status", "--porcelain"], cwd=root)
        dirty = out.splitlines() if rc == 0 and out else []
        if dirty:
            rc_t, last_tag = sh(["git", "describe", "--tags", "--abbrev=0"], cwd=root)
            unreleased = None
            if rc_t == 0 and last_tag:
                rc_c, log = sh(["git", "log", "--oneline", f"{last_tag}..HEAD"], cwd=root)
                unreleased = len([l for l in log.splitlines() if l.strip()]) if rc_c == 0 else None

            tracked = [l for l in dirty if not l.startswith("??")]
            untracked = [l for l in dirty if l.startswith("??")]
            rc_w, ws = sh(["git", "diff", "-w", "--shortstat"], cwd=root)
            ws_only = bool(tracked) and rc_w == 0 and not ws.strip()

            detail = []
            if tracked:
                detail.append(f"{len(tracked)} modified"
                              + (" (WHITESPACE/line-endings only -- `git diff -w` is empty)"
                                 if ws_only else ""))
            if untracked:
                detail.append(f"{len(untracked)} untracked")

            if unreleased == 0:
                add(findings, "info", "GIT-DIRTY-IDLE",
                    f"{rel}: {', '.join(detail)}, but NO commits since `{last_tag}` -- nothing to "
                    f"publish, so the cascade will not queue this repo. Not blocking.")
            else:
                add(findings, "warn", "GIT-DIRTY",
                    f"{rel}: {', '.join(detail)}"
                    + (f", and {unreleased} commit(s) since `{last_tag}` -- this repo WILL be "
                       f"queued, and the publisher commits version bumps into this tree."
                       if unreleased else
                       "; the publisher commits version bumps into this tree."),
                    "Commit or stash before cascading.")

        want = r.get("branch")
        rc, cur = sh(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=root)
        if rc == 0 and want and cur != want:
            add(findings, "error", "GIT-BRANCH",
                f"{rel}: on `{cur}`, but the cascade targets `{want}`.",
                f"git switch {want}")

        rc, counts = sh(["git", "rev-list", "--left-right", "--count", "@{upstream}...HEAD"],
                        cwd=root)
        if rc == 0 and counts:
            behind, ahead = (counts.split() + ["0", "0"])[:2]
            if behind != "0":
                add(findings, "warn", "GIT-BEHIND",
                    f"{rel}: {behind} commit(s) behind upstream.", "git pull --ff-only")

        # HOW THIS REPO AUTHENTICATES ITS PUBLISH -- reported, never judged. Static analysis
        # cannot prove a publish will authenticate; it can say which mechanism is configured,
        # which is what a human needs to know where to look if one fails.
        wf = os.path.join(root, ".github", "workflows", "publish.yml")
        if os.path.exists(wf):
            try:
                body = io.open(wf, encoding="utf-8", errors="replace").read()
            except OSError:
                body = ""
            oidc = "--provenance" in body or "id-token" in body
            secs = sorted({m for m in re.findall(r"secrets\.([A-Z_][A-Z0-9_]*)", body)
                           if m != "GITHUB_TOKEN"})
            url = sh(["git", "remote", "get-url", "origin"], cwd=root)[1]
            slug = re.sub(r"\.git$", "", re.sub(r".*github\.com[:/]", "", url)) if url else ""
            have = set()
            if slug:
                rc2, out2 = sh(["gh", "api", f"repos/{slug}/actions/secrets",
                                "--jq", ".secrets[]?.name"])
                if rc2 == 0:
                    have = {l.strip() for l in out2.splitlines() if l.strip()}
            missing = [x for x in secs if x not in have]
            if oidc:
                add(findings, "info", "AUTH-OIDC",
                    f"{rel}: publishes via npm Trusted Publishing (OIDC + --provenance). "
                    f"No npm token is needed; {len(have)} repo secret(s) set"
                    + (f", workflow also references {', '.join(secs)} as fallback." if secs else "."))
            elif missing:
                add(findings, "error", "AUTH-SECRET-MISSING",
                    f"{rel}: publish.yml needs {', '.join(missing)} and the repo does not have "
                    f"them, with no OIDC provenance path.",
                    f"gh secret set {missing[0]} --repo {slug}")
            else:
                add(findings, "info", "AUTH-SECRETS",
                    f"{rel}: token-authenticated publish; required secrets present.")

        pkgs = discover_packages(root)
        for name in (r.get("packages") or []):
            info = pkgs.get(name)
            if not info:
                continue
            ver = info.get("version")
            rc, out = sh(["npm", "view", f"{name}@{ver}", "version"])
            if rc == 0 and out.strip() == str(ver):
                # INFO, not WARN. Local version == published version is the STEADY STATE between
                # releases, so warning on it fires on every clean run and trains the reader to
                # skim past the block that also carries the real findings.
                add(findings, "info", "VERSION-PUBLISHED",
                    f"`{name}` {ver} is the version already on the registry -- "
                    f"the cascade bumps from here.")
            rc, out = sh(["npm", "publish", "--dry-run", "--ignore-scripts"],
                         cwd=os.path.join(root, info["dir"]), timeout=90)
            if rc != 0:
                first = (out.splitlines() or ["(no output)"])[0][:160]
                add(findings, "error", "PUBLISH-DRYRUN-FAILED",
                    f"`{name}`: npm publish --dry-run failed -- {first}",
                    "Fix before cascading; the real publish would fail the same way.")
            else:
                add(findings, "info", "PUBLISH-DRYRUN-OK",
                    f"`{name}` {ver}: publish dry-run clean.")


def add(f, sev, code, msg, fix=""):
    f.append({"severity": sev, "code": code, "message": msg, "fix": fix})


def analyse():
    findings, nodes, edges = [], [], []
    try:
        import yaml
    except ImportError:
        add(findings, "error", "NO-YAML", "pyyaml is not installed; cannot parse the config.",
            "pip install pyyaml")
        return {"ok": False, "nodes": [], "edges": [], "findings": findings, "config": CFG}
    if not os.path.exists(CFG):
        add(findings, "error", "NO-CONFIG", f"No cascade config at {CFG}.",
            "Run /wasp:cross-pollinate once to bootstrap it.")
        return {"ok": False, "nodes": [], "edges": [], "findings": findings, "config": CFG}
    try:
        cfg = yaml.safe_load(io.open(CFG, encoding="utf-8")) or {}
    except Exception as e:                                   # noqa: BLE001
        add(findings, "error", "BAD-YAML", f"Config does not parse: {e}")
        return {"ok": False, "nodes": [], "edges": [], "findings": findings, "config": CFG}

    repos = cfg.get("repos") or []
    declared = {}                                            # package -> repo path

    for r in repos:
        rel = r.get("path", "?")
        root = os.path.join(WS, rel)
        exists = os.path.isdir(root)
        pkgs = list(r.get("packages") or [])
        # `issues` is per-NODE, so the graph can colour the box itself rather than make the
        # reader match a text finding back to a vertex. The whole reason this is drawn is that a
        # missing or unready thing should be visible AS A SHAPE -- the owner's words: "let me see
        # that it isn't on the graph, to recognise such future needs in the future."
        node = {"id": rel, "path": rel, "publishes": bool(r.get("publishes")),
                "branch": r.get("branch"), "exists": exists, "packages": [], "consumes": [],
                "bootstrapped": None, "issues": []}

        if not exists:
            node["issues"].append("REPO-MISSING")
            add(findings, "error", "REPO-MISSING", f"{rel}: declared but not on disk.",
                "Clone it, or remove the entry.")
            nodes.append(node)
            continue

        # C -- claims bootstrap, but has no per-repo wasp state
        if r.get("publishes"):
            # TEST WHAT THE PUBLISHER TESTS, NOT A PROXY FOR IT. This checked for a `.wasp/`
            # DIRECTORY, so hand-writing `config.json` turned this pane green while
            # cross-pollinate's own Guard 3 still refused the repo -- the graph said ready and the
            # cascade said no. A readiness check that disagrees with the thing it reports on is
            # worse than no check: it produces confident permission to start something that will
            # stop. The publisher looks for the credentials record, so this does too.
            node["bootstrapped"] = os.path.isfile(os.path.join(
                root, ".wasp", "pollinate-credentials", "pollinate-credentials.md"))
            if r.get("pollinate_initialized") and not node["bootstrapped"]:
                node["issues"].append("NOT-BOOTSTRAPPED")
                has_cfg = os.path.isfile(os.path.join(root, ".wasp", "config.json"))
                add(findings, "warn", "NOT-BOOTSTRAPPED",
                    f"{rel}: `pollinate_initialized: true` but no "
                    f"`.wasp/pollinate-credentials/pollinate-credentials.md`"
                    + (" (the lifecycle `config.json` IS present — so this repo is half "
                       "bootstrapped: cross-pollinate's Guard 3 looks for the credentials "
                       "record and will refuse the repo)." if has_cfg
                       else " — the publisher has no state or config there."),
                    "Run /wasp:pollinate in that repo, or drop the flag.")

        # D/E -- declared vs on-disk, BOTH directions
        on_disk = discover_packages(root)
        for name in pkgs:
            declared[name] = rel
            info = on_disk.get(name)
            if not info:
                add(findings, "error", "PKG-NOT-ON-DISK",
                    f"{rel}: declares `{name}`, which is not in packages/.",
                    "Remove it from the config, or restore the package.")
            node["packages"].append({"name": name, "declared": True,
                                     "version": (info or {}).get("version")})
        for name, info in on_disk.items():
            if name not in pkgs and info["publishable"]:
                node["issues"].append("PKG-UNDECLARED")
                add(findings, "error", "PKG-UNDECLARED",
                    f"{rel}: `{name}` is publishable on disk but NOT declared — "
                    f"the cascade will never publish it.",
                    f"Add \"{name}\" to that repo's `packages:` list.")
                node["packages"].append({"name": name, "declared": False,
                                         "version": info["version"]})
        nodes.append(node)

    # F/G -- every edge must name a real package and land on a consumer that really pins it
    for e in cfg.get("edges") or []:
        frm, to_repo = e.get("from"), e.get("to_repo")
        field = e.get("to_field", "dependencies")
        ok = True
        if frm not in declared:
            ok = False
            add(findings, "error", "EDGE-UNKNOWN-PKG",
                f"edge `{frm}` → {to_repo}: no repo declares that package.")
        cpj = jload(os.path.join(WS, to_repo or "", "package.json"))
        pin = None
        if cpj is None:
            ok = False
            add(findings, "error", "EDGE-NO-CONSUMER",
                f"edge `{frm}` → {to_repo}: consumer package.json not found.")
        else:
            pin = (cpj.get(field) or {}).get(frm)
            if pin is None:
                ok = False
                add(findings, "warn", "EDGE-NOT-PINNED",
                    f"edge `{frm}` → {to_repo}: consumer does not list it in `{field}`.",
                    "Drop the edge, or add the dependency.")
        edges.append({"from": frm, "to": to_repo, "field": field, "pin": pin, "ok": ok})

    # H -- the inverse: a consumer dep that IS one of ours, with no edge carrying it
    carried = {(e.get("from"), e.get("to_repo")) for e in cfg.get("edges") or []}
    for r in repos:
        rel = r.get("path", "?")
        cpj = jload(os.path.join(WS, rel, "package.json"))
        if not cpj:
            continue
        for field in ("dependencies", "devDependencies"):
            for dep, pin in (cpj.get(field) or {}).items():
                if dep in declared and declared[dep] != rel:
                    node = next((n for n in nodes if n["id"] == rel), None)
                    if node is not None:
                        node["consumes"].append({"name": dep, "pin": pin,
                                                 "edge": (dep, rel) in carried})
                    if (dep, rel) not in carried:
                        if node is not None:
                            node["issues"].append("MISSING-EDGE")
                        add(findings, "error", "MISSING-EDGE",
                            f"{rel} pins `{dep}` in {field}, but NO edge carries it — "
                            f"publishing it will never raise this pin.",
                            f"Add an edge: from `{dep}` → {rel} ({field}).")
    if "--dry-run" in sys.argv:
        dryrun(repos, declared, findings)

    worst = ("error" if any(f["severity"] == "error" for f in findings)
             else "warn" if findings else "ok")
    return {"ok": worst != "error", "status": worst, "config": CFG,
            "workspace": cfg.get("workspace", {}).get("name") or os.path.basename(WS),
            "nodes": nodes, "edges": edges, "findings": findings}


def main():
    r = analyse()
    if "--json" in sys.argv:
        print(json.dumps(r, indent=2))
        return 0
    print(f"cascade: {r.get('workspace')}   ({r['config']})")
    for n in r["nodes"]:
        role = "publishes" if n["publishes"] else "consumer "
        print(f"  [{role}] {n['path']}{'' if n['exists'] else '   (MISSING)'}")
        for p in n["packages"]:
            mark = " " if p["declared"] else "!"
            print(f"       {mark} {p['name']}  {p.get('version') or ''}"
                  f"{'' if p['declared'] else '   NOT DECLARED'}")
        for c in n["consumes"]:
            print(f"       {'→' if c['edge'] else '✗'} consumes {c['name']} {c['pin']}"
                  f"{'' if c['edge'] else '   NO EDGE'}")
    print()
    if not r["findings"]:
        print("cascade: clean -- every package is declared and every pin has an edge.")
        return 0
    for f in r["findings"]:
        print(f"  {f['severity'].upper():5} [{f['code']}] {f['message']}")
        if f["fix"]:
            print(f"        fix: {f['fix']}")
    return 0 if r["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())

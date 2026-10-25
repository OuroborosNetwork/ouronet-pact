#!/usr/bin/env python3
"""Propose (and optionally write) the missing per-repo publisher config.

    python3 REPL/tools/_cascadefix.py --repo _libs/ouronet-libs            propose, as JSON
    python3 REPL/tools/_cascadefix.py --repo _libs/ouronet-libs --apply    write .wasp/config.json

WHAT IT FIXES.  `_cascadegraph.py` reports a repo whose cascade config claims
`pollinate_initialized: true` while the repo has no `.wasp/` at all -- the publisher has no
lifecycle config, so the cascade cannot act on it.  Every field of that config is derivable from
what is already on disk: the package manifests, the publish workflow, and the git tags.  So this
derives them, and REFUSES to invent the two that are not derivable.

WHY IT PROPOSES BEFORE IT WRITES, AND WHY TWO FIELDS ARE LEFT TO A HUMAN.

  THE TRAP, MEASURED 2026-10-25: a tag pattern is not only a release LABEL, it is the BASELINE
  change detection diffs from (`git describe --tags --match <pattern>` then `git diff <tag>..HEAD
  -- <dir>`). Recommending `prefixed` here on collision-safety grounds was WRONG: with no tag
  matching the new pattern, all three packages read as first releases instead of one, and uniform
  versioning would have converged them. Flat fails LOUDLY and far away (at tag creation, ~19 minor
  bumps out, when talos-registry reaches the occupied 4.x range); prefixed failed SILENTLY and
  immediately, in the direction that over-publishes. Evaluate a tag pattern against change
  detection first, collision second.

  `tag_pattern` -- `ouronet-libs` tags FLAT (`v5.3.2`, `v2.3.1-0`, `v0.5.7`) for three different
  packages.  Those do not collide only because the version lines happen to be disjoint.  DALOS_Crypto
  instead prefixes by directory (`ts-v4.5.1`).  Choosing a prefix here would change the tag
  convention and break release BACKFILL, which walks existing tags; choosing flat preserves history
  and keeps the latent collision.  That is a release-history decision, not a default.

  `version_model` -- only `"uniform"` is supported ("independent" is deferred), and uniform means
  every QUEUED package converges on one version, largest bump winning.  With packages at 5.3.2,
  2.3.1-0 and 0.5.7, any round that queues two of them drags the lower one up -- irreversibly, since
  a published version can never be reused.

A tool that guessed either of those would be writing a decision into a file and calling it a
derivation.  Both are reported as `decisions`, with the evidence, for a human to settle.
"""
import io
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OURONET = os.path.dirname(os.path.dirname(HERE))
WS = os.path.dirname(os.path.dirname(OURONET))

sys.path.insert(0, HERE)
from _cascadegraph import discover_packages                  # noqa: E402  (one definition only)


def sh(args, cwd=None):
    try:
        r = subprocess.run(args, cwd=cwd, capture_output=True, text=True, timeout=30)
        return r.returncode, (r.stdout + r.stderr).strip()
    except Exception:                                        # noqa: BLE001
        return 1, ""


def propose(rel):
    root = os.path.join(WS, rel)
    out = {"repo": rel, "root": root, "ok": True, "decisions": [], "evidence": {}}
    if not os.path.isdir(root):
        return {**out, "ok": False, "error": f"{rel} is not on disk"}

    pkgs = {n: i for n, i in discover_packages(root).items() if i["publishable"]}
    if not pkgs:
        return {**out, "ok": False, "error": f"{rel} has no publishable package"}

    # workflow + auth, read from the workflow rather than assumed
    wfdir = os.path.join(root, ".github", "workflows")
    wf = "publish.yml" if os.path.exists(os.path.join(wfdir, "publish.yml")) else None
    body = ""
    if wf:
        body = io.open(os.path.join(wfdir, wf), encoding="utf-8", errors="replace").read()
    provenance = "--provenance" in body
    secrets = sorted({m for m in re.findall(r"secrets\.([A-Z_][A-Z0-9_]*)", body)
                      if m != "GITHUB_TOKEN"})
    auth = secrets[0] if secrets else None

    rc, tags = sh(["git", "tag", "--sort=-creatordate"], cwd=root)
    taglist = [t for t in tags.splitlines() if t.strip()][:40]
    flat = [t for t in taglist if re.fullmatch(r"v\d+\.\d+\.\d+.*", t)]
    prefixed = [t for t in taglist if re.fullmatch(r"[a-z0-9-]+-v\d+\.\d+\.\d+.*", t)]
    out["evidence"]["tags_sample"] = taglist[:10]
    out["evidence"]["flat_tags"] = len(flat)
    out["evidence"]["prefixed_tags"] = len(prefixed)
    out["evidence"]["workflow"] = wf
    out["evidence"]["provenance"] = provenance
    out["evidence"]["workflow_secrets"] = secrets

    rc, branch = sh(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=root)
    target = branch if rc == 0 and branch else "main"

    # TAG STYLE IS A REAL CHOICE, so it is a PARAMETER rather than a paragraph. The first cut
    # printed both options as prose and then wrote the default anyway -- which presented a decision
    # the caller could not actually make. Either a thing is choosable or it is a constraint; saying
    # "I will not decide this for you" while hard-coding one answer is the worst of both.
    style = "flat"
    if "--tag-style" in sys.argv:
        style = sys.argv[sys.argv.index("--tag-style") + 1]
    if style not in ("flat", "prefixed"):
        return {**out, "ok": False, "error": f"--tag-style must be flat|prefixed, got {style!r}"}
    out["tag_style"] = style

    entries = []
    for name, info in sorted(pkgs.items()):
        d = info["dir"]
        short = name.split("/")[-1]
        pat = "v{version}" if style == "flat" else f"{short}-v{{version}}"
        entries.append({
            "name": name,
            "dir": d if d != "." else ".",
            "tag_pattern": pat,
            "release_title_pattern": pat,
            "workflow": wf or "publish.yml",
            "changelog_path": (f"{d}/CHANGELOG.md" if d != "." else "CHANGELOG.md"),
            "readme_path": (f"{d}/README.md" if d != "." else "README.md"),
            # AUTH_SECRET IS OMITTED UNDER OIDC, and that is not a detail. pollinate validates a
            # declared `auth_secret` by asking GitHub whether a repo secret of that name exists
            # (gate 3). This repo publishes via npm Trusted Publishing -- `--provenance`, the OIDC
            # exchange inside `npm publish` -- so it legitimately has ZERO repo secrets, and the
            # workflow's NPM_PUBLISHER reference is a dead fallback. Naming it here would make the
            # wizard halt on a secret that is absent BY DESIGN and never used.
            "registries": [{
                "kind": "npm", "url": "https://registry.npmjs.org", "access": "public",
                "provenance": provenance,
                **({} if provenance else ({"auth_secret": auth} if auth else {})),
            }],
        })

    cfg = {"lifecycle": {
        "repo_type": "npm-package",
        "publishes_to_npm": True,
        "version_source": "package_json",
        "version_model": "uniform",
        "target_branch": target,
        "tag_message_source": "changelog",
        "backfill_on_publish": True,
        "wait_for_ci_seconds": 600,
        "ci_workflow_skip": False,
        "branch_protection": "fast-forward",
        "packages": entries,
    }}
    out["config"] = cfg

    out["constraints"] = []
    if len(entries) > 1:
        out["choices"] = [{
            "field": "packages[].tag_pattern",
            "selected": style,
            "options": [
                {"value": "flat", "pattern": "v{version}",
                 "effect": f"Matches this repo's {len(flat)} existing tags, so release BACKFILL "
                           f"keeps finding prior releases. The latent risk stays: "
                           f"{len(entries)} packages share one pattern and only avoid collision "
                           f"while their version lines are disjoint."},
                {"value": "prefixed", "pattern": "<package>-v{version}",
                 "effect": "Collision becomes impossible (DALOS_Crypto does this with `ts-v…`). "
                           "BUT IT ALSO BLINDS CHANGE DETECTION, which is the bigger cost and the "
                           "one that is easy to miss: the cascade finds each package's baseline "
                           "with `git describe --match <pattern>`, so switching the pattern means "
                           "NO tag matches and EVERY package reads as a first release. Under "
                           "`version_model: uniform` all of them then converge on one shared "
                           "version -- measured here as codex 0.5.7 being dragged into the 5.x "
                           "line, irreversibly. Only choose this on a repo with no release "
                           "history under the old pattern, or after re-tagging history."},
            ],
        }]
        out["constraints"].append({
            "field": "version_model",
            "value": "uniform",
            "why": "NOT a choice -- `independent` is deferred to v1.2.0+ and the publisher halts "
                   "if asked for it. Stated because the behaviour matters: every QUEUED package "
                   "converges on one version, largest bump winning. A registry-only round queues "
                   "one package and is safe; a round touching two drags the lower version up, and "
                   "a published version can never be reused.",
        })
        out["decisions"].append({
            "field": "packages[].tag_pattern",
            "proposed": "v{version}  (flat, for every package)",
            "why": f"{len(flat)} existing tags are flat `vX.Y.Z` and {len(prefixed)} are "
                   f"directory-prefixed. Flat matches this repo's history, so release BACKFILL "
                   f"keeps working — but {len(entries)} packages sharing one pattern only avoid "
                   f"collision while their version lines stay disjoint "
                   f"({', '.join(f'{n.split('/')[-1]} {i['version']}' for n, i in sorted(pkgs.items()))}).",
            "alternative": "Prefix per package (`talos-registry-v{version}`, as DALOS_Crypto does "
                           "with `ts-v…`). Removes the collision; existing tags no longer match, "
                           "so backfill would not see prior releases.",
        })
    return out


def main():
    if "--repo" not in sys.argv:
        print(__doc__)
        return 1
    rel = sys.argv[sys.argv.index("--repo") + 1]
    r = propose(rel)
    if not r["ok"]:
        print(json.dumps(r, indent=2))
        return 1
    dest = os.path.join(r["root"], ".wasp", "config.json")
    r["dest"] = dest
    r["exists"] = os.path.exists(dest)
    if "--apply" in sys.argv:
        # REPLACE IS SEPARATE FROM WRITE, ON PURPOSE. Refusing to overwrite protects a config that
        # may carry decisions this tool cannot see -- but it also blocked CORRECTING a choice made
        # seconds earlier, which is how a wrong tag style became unfixable from the UI. So the
        # guard stays and `--force` is the explicit way past it, surfaced as its own button.
        if r["exists"] and "--force" not in sys.argv:
            r["written"] = False
            r["error"] = (f"{dest} already exists -- refusing to overwrite. Use --force (the "
                          f"Replace button) if you mean to change a choice you already wrote.")
            try:
                r["current"] = json.load(io.open(dest, encoding="utf-8"))
            except Exception:                                # noqa: BLE001
                pass
            print(json.dumps(r, indent=2))
            return 1
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with io.open(dest, "w", encoding="utf-8") as fh:
            fh.write(json.dumps(r["config"], indent=2) + "\n")
        r["written"] = True
    print(json.dumps(r, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())

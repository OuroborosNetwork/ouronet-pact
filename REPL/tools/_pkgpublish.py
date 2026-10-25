#!/usr/bin/env python3
"""Does @ouronet/talos-registry need publishing, and what exactly changed?

    python3 REPL/tools/_pkgpublish.py            human report
    python3 REPL/tools/_pkgpublish.py --json     machine form, for the Scripts pane

WHAT THIS ANSWERS AND `_pkgsync.py` DOES NOT.  `_pkgsync.py` says STALE / in sync -- a boolean.
That is the right answer to "is the gate clean" and the wrong one to "what do I do now", which is
the question an operator actually has after a deploy.  This names the DELTA: which entrypoints and
previews the chain gained, what that implies for the semver bump, and whether the consumer's pin
still points at a version that can serve them.

WHY IT DOES NOT PUBLISH.  `npm publish` is irreversible -- a version number can never be reused,
and unpublishing is barred after 72 hours -- so a browser button is the wrong trigger for it.
The workspace already has a publisher that does the whole job properly (`/wasp:cross-pollinate`):
it waits for CI, verifies the version actually appeared on the registry, creates the GitHub
release, and commits the dep-pin bump in the consumer repo.  A hand-rolled `npm publish` here
would do one of those five things and look like it had done all five.

**The reason publishing was ever manual was a two-line omission**, not a missing feature: until
2026-10-25 `.wasp/cross-pollinate.yml` listed only `ouronet-core` and `ouronet-codex` under
`_libs/ouronet-libs`, with no edge for `talos-registry` -- so the package most affected by every
deploy was the one package the cascade did not know about.  Both are now present.

SEMVER, AND WHY THE SURFACE HASH ALONE CANNOT DECIDE IT.  `surfaceHash` covers ghost values and
metadata, so it moves for changes that add no callable surface at all.  Deciding the bump from it
would publish a MINOR for a docstring.  So the counts are compared by NAME:

    entrypoints or previews ADDED      -> minor   (consumers gain callable surface)
    entrypoints or previews REMOVED    -> major   (a consumer's call can stop resolving)
    neither, but the hash moved        -> patch   (ghosts/metadata only)
    nothing moved                      -> nothing to publish
"""
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REGISTRY = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.json")
PKG = os.path.abspath(os.path.join(
    ROOT, "..", "..", "_libs", "ouronet-libs", "packages", "talos-registry"))
BUNDLE = os.path.join(PKG, "src", "data", "registry.json")
PKGJSON = os.path.join(PKG, "package.json")
CONSUMER = os.path.abspath(os.path.join(ROOT, "..", "..", "daimons", "OuronetUI", "package.json"))
DEP = "@ouronet/talos-registry"


def published_snapshot(version):
    """The registry snapshot inside the PUBLISHED tarball -- the only honest baseline.

    THE BUG THIS FIXES, found 2026-10-25 by running the real post-deploy chain. This compared the
    repo registry against `packages/talos-registry/src/data/registry.json` -- the LOCAL copy. But
    the Scripts chain runs `npm run build` (which syncs that copy) at step 3, and this verdict at
    step 4. So step 3 erased the very difference step 4 exists to detect, and the verdict read
    "NOTHING TO PUBLISH" immediately after a deploy that added three entrypoints.

    The published tarball cannot be edited by a local build, so it is the baseline. Measured at
    the moment of the fix: published 2.3.1-0 carried 439/444, the tree carried 442/447.
    """
    import subprocess, tempfile, tarfile, glob
    try:
        with tempfile.TemporaryDirectory() as d:
            r = subprocess.run(["npm", "pack", f"@ouronet/talos-registry@{version}"],
                               cwd=d, capture_output=True, text=True, timeout=180)
            if r.returncode != 0:
                return None
            tgz = glob.glob(os.path.join(d, "*.tgz"))
            if not tgz:
                return None
            with tarfile.open(tgz[0]) as tf:
                # The PUBLISHED path is `dist/data/registry.json`, not `src/...` -- the
                # package's `files` list ships `dist` only, so src/ is never in the tarball.
                # Guessing the source path returned None, which silently fell back to the local
                # bundle and reproduced the very bug this function was written to fix.
                for m in tf.getmembers():
                    if m.name.endswith("data/registry.json"):
                        return json.loads(tf.extractfile(m).read().decode("utf-8"))
    except Exception:                                        # noqa: BLE001
        return None
    return None


def load(path):
    try:
        with io.open(path, encoding="utf-8") as fh:
            return json.load(fh)
    except Exception:
        return None


def bump(version, kind):
    """Next version. A PRERELEASE is resolved to its release first: 2.3.1-0 + minor -> 2.4.0,
    never 2.3.1-1 -- a prerelease is an unfinished attempt at the version it names, and carrying
    one forward would publish a number nobody chose."""
    m = re.match(r"^(\d+)\.(\d+)\.(\d+)", version or "0.0.0")
    if not m:
        return None
    a, b, c = (int(x) for x in m.groups())
    pre = "-" in (version or "")
    if kind == "major":
        return f"{a + 1}.0.0"
    if kind == "minor":
        return f"{a}.{b + 1}.0"
    return f"{a}.{b}.{c}" if pre else f"{a}.{b}.{c + 1}"


def main():
    as_json = "--json" in sys.argv
    reg, pkgbundle, pkgjson, consumer = (
        load(REGISTRY), load(BUNDLE), load(PKGJSON), load(CONSUMER))

    out = {"ok": True, "action": "none", "reason": "", "added": {}, "removed": {}}
    if not reg:
        out.update(ok=False, reason="no Deploy/OURONET-REGISTRY.json -- run _registry.py --probe")
    elif not os.path.isdir(PKG):
        out.update(reason=f"package not checked out at {PKG} -- skipped")
    elif not pkgbundle:
        out.update(action="publish", reason="the package carries no registry snapshot")
    else:
        # Compare against what is PUBLISHED, not the local copy a build may just have synced.
        latest = (pkgjson or {}).get("version")
        pub = published_snapshot(latest) if latest else None
        if pub:
            pkgbundle = pub
            out["baseline"] = f"published {latest}"
        else:
            out["baseline"] = "local bundle (could not reach the registry)"

        for field in ("entrypoints", "previews"):
            now, had = set(reg.get(field, {})), set(pkgbundle.get(field, {}))
            out["added"][field] = sorted(now - had)
            out["removed"][field] = sorted(had - now)
        any_add = any(out["added"].values())
        any_rem = any(out["removed"].values())
        hash_moved = reg.get("surfaceHash") != pkgbundle.get("surfaceHash")
        kind = "major" if any_rem else "minor" if any_add else "patch" if hash_moved else None
        out["kind"] = kind
        out["current"] = (pkgjson or {}).get("version")
        out["next"] = bump(out["current"], kind) if kind else None
        out["action"] = "publish" if kind else "none"
        out["consumerPin"] = ((consumer or {}).get("dependencies") or {}).get(DEP)
        out["reason"] = {
            "major": "the chain REMOVED callable surface the package still advertises",
            "minor": "the chain gained callable surface the package does not carry",
            "patch": "metadata or ghost values moved; the callable surface is unchanged",
            None: "the package already carries this exact surface",
        }[kind]

    if as_json:
        print(json.dumps(out, indent=2))
        return 0 if out["ok"] else 1

    print(f"package : {DEP}")
    print(f"  built   : {out.get('current')}   consumer pins: {out.get('consumerPin')}")
    if out["action"] == "none":
        print(f"  verdict : NOTHING TO PUBLISH -- {out['reason']}")
        return 0
    print(f"  verdict : PUBLISH a {out.get('kind','?').upper()} -> "
          f"{out.get('next')}   ({out['reason']})")
    for field in ("entrypoints", "previews"):
        for sign, key in (("+", "added"), ("-", "removed")):
            for n in out.get(key, {}).get(field, []):
                print(f"            {sign} {field[:-1]}: {n}")
    print()
    print("  To publish AND raise the consumer pin in one pass, run the workspace cascade:")
    print("      /wasp:cross-pollinate")
    print("  It waits for CI, verifies the version on the registry, creates the GitHub release,")
    print("  and commits the dep-pin bump in OuronetUI. Publishing by hand does the first step")
    print("  only -- and `npm publish` cannot be undone after 72 hours.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

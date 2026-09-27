#!/usr/bin/env python3
"""Is the @ouronet/talos-registry package still carrying THIS registry?

The package bundles a snapshot of Deploy/OURONET-REGISTRY.json rather than fetching at runtime,
which is the right trade -- but it creates the one drift this whole registry exists to prevent,
one level up: the Pact repo regenerates, the package is not re-synced, and consumers validate
against a surface that no longer exists. Confidently, which is the dangerous part.

So the two are diffed here, by surface hash.

WHY A WARNING AND NOT A FAILURE. The package lives in a SEPARATE repository
(`_libs/ouronet-libs`), which may legitimately be absent -- a fresh clone of the Pact repo
alone, or CI that checks out one tree. Failing on absence would make this repo's gate depend on
another repo being present, which it is not. A STALE package, when the package IS present, is
reported loudly; an ABSENT one is reported and skipped.

  python3 REPL/tools/_pkgsync.py --check    warn if the bundled snapshot has drifted
"""
import io
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REGISTRY = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.json")
PKG = os.path.abspath(os.path.join(
    ROOT, "..", "..", "_libs", "ouronet-libs", "packages", "talos-registry"))
BUNDLE = os.path.join(PKG, "src", "data", "registry.json")


def main():
    if "--check" not in sys.argv:
        print(__doc__)
        return 0
    if not os.path.exists(REGISTRY):
        print("pkgsync: no Deploy/OURONET-REGISTRY.json -- run _registry.py --probe")
        return 1
    mine = json.load(io.open(REGISTRY, encoding="utf8"))
    if not os.path.isdir(PKG):
        print(f"pkgsync: skipped -- @ouronet/talos-registry is not checked out at {PKG}")
        return 0
    if not os.path.exists(BUNDLE):
        print("pkgsync: the package is present but carries NO snapshot. "
              "Run `npm run sync` in packages/talos-registry.")
        return 1
    theirs = json.load(io.open(BUNDLE, encoding="utf8"))
    if theirs.get("surfaceHash") != mine.get("surfaceHash"):
        print("pkgsync: STALE -- @ouronet/talos-registry is shipping a different surface.")
        print(f"    this repo: {mine.get('surfaceHash')}  "
              f"({len(mine.get('entrypoints', {}))} entrypoints)")
        print(f"    package:   {theirs.get('surfaceHash')}  "
              f"({len(theirs.get('entrypoints', {}))} entrypoints)")
        # DO NOT say "the callable surface moved" here, which is what this line used to read.
        # surfaceHash is a sha256 over the WHOLE entrypoints+previews body, ghost example values
        # included, so it moves for a changed example with no signature change anywhere. It did
        # exactly that on 2026-09-27 when the ghost `use` tags were added. A consumer who reads
        # this as "the API changed" reviews a diff that isn't there; worse, one who learns the
        # message overstates starts discounting it for the time it doesn't.
        same = len(mine.get("entrypoints", {})) == len(theirs.get("entrypoints", {}))
        print("    Run `npm run build` in packages/talos-registry, and bump its version.")
        print("    NOTE: surfaceHash covers ghost values too, so this may be a metadata-only "
              "change." + ("  Entrypoint COUNT is unchanged, which is consistent with that."
                           if same else "  Entrypoint count ALSO changed -- check signatures."))
        print("    `_registry.py --probe` reports the divergence count; that is the question "
              "'did the callable surface change', and this hash is not.")
        return 1
    print(f"pkgsync: clean -- the package carries surface {mine['surfaceHash']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

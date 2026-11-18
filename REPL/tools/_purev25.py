#!/usr/bin/env python3
"""Emit and verify the PureV25 hand-deploy round -- the equity share-count stake gate.

WHAT THIS ROUND IS. A share issuance under a live stake drove a score base to -10,000,
because a base is an accumulated signed delta while the class-3 equity leg weighs a position
at the LIVE share value. This round adds the gate that refuses the issuance
(`UEV_AQP|NoLiveStakeOfAsset`, called by both share doors in TS02-C1) and the repair path for
a base that is already wrong (the re-rate engine's class-3 route). See the round's `why` in
`_deploybundle.py` for the full account.

WHY IT RUNS THE PLANNER SCOPED rather than lifting transactions out of `Deploy/1_Pure/`:
this round's 5 modules are spread across THREE of the full plan's batches (16, 21, 24), and
those batches carry 11 other modules that have not changed. Copying them would redeploy 11
modules for nothing. A scoped run bins the 5 on their own -- 2 transactions, not 3 -- and the
dependency order survives: AQP-POOL lands in tx 1, ahead of the TS02-C1 that calls into it.

THE DANCE, AND WHY IT IS AUTOMATED. `_deploybundle.py --write` ALWAYS writes to
`Deploy/1_Pure/` + `MANIFEST.md` + `TABLES.md` regardless of `--round`, so a scoped write
OVERWRITES the full chain's generated artefacts that `_gate.py`'s fatal
`_deploybundle.py --check` expects. So: back up `Deploy/`, clear the slate, run scoped, copy
the output out, restore the backup, and VERIFY `--check` is clean again before claiming
success. Skipping the restore leaves the gate permanently red. The dance is imported from
`_purev10.py` rather than re-implemented, because a second copy of it is a second thing that
can forget to restore.

    python3 REPL/tools/_purev25.py --plan    # what the scoped planner bins, no writes
    python3 REPL/tools/_purev25.py --write   # emit Deploy/PureV25/
    python3 REPL/tools/_purev25.py --check   # does Deploy/PureV25/ match the sources?
"""
import importlib.util, io, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEST = os.path.join(ROOT, "Deploy", "PureV25")
ROUND_NAME = "2026-11-v25-equity-share-stake-gate"

_spec = importlib.util.spec_from_file_location(
    "_purev10", os.path.join(os.path.dirname(os.path.abspath(__file__)), "_purev10.py"))
_v10 = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_v10)
_v10.ROUND_NAME = ROUND_NAME            # retarget the shared dance at THIS round


def scoped():
    """The scoped round's emitted transactions, renumbered 01..NN for this folder."""
    files, _manifest = _v10._run_scoped_round()
    return {f"{i:02d}_deploy.pact": body
            for i, body in enumerate(files.values(), start=1)}


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "--plan"
    files = scoped()
    total = sum(len(b.encode("utf8")) for b in files.values())

    if mode == "--plan":
        for n, b in files.items():
            mods = re.findall(r'^\(module\s+(\S+)', b, re.M)
            ifaces = re.findall(r'^\(interface\s+(\S+)', b, re.M)
            print(f"  {n}  {len(b.encode('utf8')):>8,} B   "
                  f"interfaces={ifaces or '-'}  modules={mods}")
        print(f"  TOTAL {total:,} B across {len(files)} transaction(s)")
        return 0

    if mode == "--write":
        os.makedirs(DEST, exist_ok=True)
        for n, b in files.items():
            io.open(os.path.join(DEST, n), "w", encoding="utf8").write(b)
        print(f"wrote {DEST} -- {len(files)} transaction(s), {total:,} bytes")
        return 0

    if mode == "--check":
        bad = []
        for n, b in files.items():
            p = os.path.join(DEST, n)
            if not os.path.isfile(p):
                bad.append(f"MISSING  {n}")
            elif io.open(p, encoding="utf8").read() != b:
                bad.append(f"STALE    {n}")
        extra = [f for f in os.listdir(DEST)
                 if re.match(r"^\d+_deploy\.pact$", f) and f not in files]
        bad += [f"ORPHAN   {f}" for f in extra]
        if bad:
            print("PureV25 round is STALE against the sources:")
            for x in bad:
                print("   " + x)
            print("\nRegenerate with:  python3 REPL/tools/_purev25.py --write")
            return 1
        print(f"PureV25: clean -- {len(files)} transaction(s), {total:,} bytes, "
              f"matches the sources")
        return 0

    sys.exit(__doc__)


if __name__ == "__main__":
    sys.exit(main())

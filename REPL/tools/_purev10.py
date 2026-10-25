#!/usr/bin/env python3
"""Emit and verify the PureV10 hand-deploy round.

WIDENED 2026-10-12. The original V10 (three features: TF beneficiary reassignment, the
sleeping-leg multiplier reader, the `CCp_`->`CC_` naming correction -- 6 transactions) is
SUPERSEDED, not appended to: the owner ruling that triggered the interface-membership sweep
("do the sweep now ... widen pure V10, for the whole pact code stage 1 and stage 2 modules")
asked for ONE round, and the sweep's own dot-pin cascade already reaches every module the old
V10 touched (AQP-SCORE, RPS, AQP-FVT, AQP-VCT/MTX-AQP/AQP-DSA, TS02-C3, AQP-INFO, AQP-BOOT are
all inside the new round's `interfaces` scope). Deploying the old 6 first would just mean
re-deploying the same modules again moments later inside the new 22 -- strictly wasted gas, no
safety benefit, since the new round's content is a superset.

WHAT THIS ROUND IS: every user/client function and every reader must sit in its module's own
interface (StoicSyntax-Prefixes.md Sec5, owner ruling, 2026-10-12) -- not just the ones convenient
to add when the interface was last touched. `REPL/tools/_ifacemembership.py` is ground truth for
the gap (307 defun stubs were missing across 36 sovereign modules); `REPL/tools/_ifacebump.py`
closed it mechanically (bump each module's own co-located interface by exactly one, insert the
missing stubs, rewrite every `module{OLD}`/`object{OLD.Schema}` consumer tree-wide). This tool
packages the result for mainnet.

HOW THIS DIFFERS FROM V2-V9's OWN TOOLS, and why: those copy NAMED transactions out of
`Deploy/1_Pure/NN_deploy.pact` by number, because their round's module set was a small, known
subset of the full chain's OWN bin-packing -- copying transaction 15 verbatim out of the full
round was safe because the full round's packer and the narrow round's packer would have binned
AQP-SCORE the same way regardless. That assumption breaks here: this round touches 74 of the
full chain's ~79 modules, so a SEPARATE, SCOPED run of the planner (`_deploybundle.py --round
2026-10-interfaces`) bins the surviving ~74 into fewer, differently-shaped transactions than the
full round does (22 here vs 24 for everything) -- transaction N of this round is NOT transaction
N of `Deploy/1_Pure`. The tool therefore RUNS THE PLANNER SCOPED rather than lifting files out of
an already-run full plan.

THE DANCE THIS TOOL AUTOMATES, and why it needs automating rather than running by hand once:
`_deploybundle.py --write` ALWAYS writes to `Deploy/1_Pure/` + `Deploy/MANIFEST.md` +
`Deploy/TABLES.md`, regardless of `--round` -- there is no separate output directory per round.
Running the scoped round's `--write` therefore OVERWRITES the full chain's own generated
artefacts (24 files -> 22, different content) that `_gate.py`'s `_deploybundle.py --check` (fatal,
DEFAULT_ROUND-scoped) expects to find. So: back up `Deploy/`, run the scoped round, copy its 22
files out, DELETE the scoped output, restore the backup, and verify `--check` is clean again
before declaring success. Skipping the restore step leaves the gate permanently red.

    python3 REPL/tools/_purev10.py --plan / --write / --check / --multipact
"""
import sys, os, re, json, io, shutil, subprocess, tempfile

BLOCK_GAS_LIMIT = 2_000_000
MAXBYTES = 320_000
ROUND_NAME = "2026-10-interfaces"

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPLOY = os.path.join(ROOT, "Deploy", "PureV10")
FULL = os.path.join(ROOT, "Deploy")


def module_names(path):
    return re.findall(r'^\(module\s+(\S+)', open(path, encoding="utf8").read(), re.M)


def gas(nbytes):
    return 95_225 * ((nbytes / 1024) / 256) ** 7


def _run_scoped_round(write_dest=None):
    """Back up Deploy/, run the planner SCOPED to ROUND_NAME, capture the emitted
    `NN_deploy.pact` files (+ MANIFEST.md), restore Deploy/ to exactly what it was, and verify
    the restore with `--check`. Returns (files_by_name, manifest_text). Raises on any failure --
    a half-finished dance that leaves Deploy/ scoped is worse than refusing to run."""
    backup = tempfile.mkdtemp(prefix="deploy_backup_")
    shutil.copytree(FULL, os.path.join(backup, "Deploy"))
    try:
        # `_deploybundle.py --write` never DELETES a `Deploy/1_Pure/NN_deploy.pact` it no longer
        # emits -- confirmed the hard way: the full round emits 25, this round emits 22, and the
        # first draft of this function read 23/24/25 back as if the scoped round had produced
        # them too. Clear the slate first so every file read back afterward is one THIS run
        # actually wrote.
        pure = os.path.join(FULL, "1_Pure")
        for f in os.listdir(pure):
            if re.match(r"^\d+_deploy\.pact$", f):
                os.remove(os.path.join(pure, f))
        r = subprocess.run(
            [sys.executable, "tools/_deploybundle.py", "--round", ROUND_NAME, "--write"],
            cwd=os.path.join(ROOT, "REPL"), capture_output=True, text=True)
        if r.returncode != 0:
            raise SystemExit(f"scoped round write failed:\n{r.stdout}\n{r.stderr}")
        pure = os.path.join(FULL, "1_Pure")
        files = {}
        for f in sorted(os.listdir(pure)):
            if re.match(r"^\d+_deploy\.pact$", f):
                files[f] = open(os.path.join(pure, f), encoding="utf8").read()
        manifest = open(os.path.join(FULL, "MANIFEST.md"), encoding="utf8").read()
    finally:
        # restore no matter what the scoped run did or didn't produce
        shutil.rmtree(FULL)
        shutil.move(os.path.join(backup, "Deploy"), FULL)
        shutil.rmtree(backup, ignore_errors=True)
    r = subprocess.run([sys.executable, "tools/_deploybundle.py", "--check"],
                        cwd=os.path.join(ROOT, "REPL"), capture_output=True, text=True)
    if r.returncode != 0 or "deploy pipeline: clean" not in r.stdout:
        raise SystemExit("RESTORE VERIFICATION FAILED -- Deploy/ may not match the full round "
                          f"any more. Investigate before doing anything else.\n{r.stdout}\n{r.stderr}")
    # the scoped round emits however many transactions it binned to; keep only the
    # `NN_deploy.pact` ones in numeric order, however many that turned out to be
    ordered = sorted(files, key=lambda f: int(f.split("_")[0]))
    return {f: files[f] for f in ordered}, manifest


def check_or_write(write):
    files, _ = _run_scoped_round()
    bad = 0
    want_names = set(files)
    have_names = {f for f in os.listdir(DEPLOY) if re.match(r"^\d+_deploy\.pact$", f)}
    stale = have_names - want_names
    for f in sorted(stale):
        print(f"  STALE-ORPHAN  {f} -- in Deploy/PureV10/ but not in the current scoped plan")
        bad += 1
    for name in sorted(files, key=lambda f: int(f.split("_")[0])):
        want = files[name]
        n = len(want.encode())
        if n > MAXBYTES:
            print(f"  TOO BIG  {name} -- {n:,} bytes over the {MAXBYTES:,} cap")
            bad += 1
        dst = os.path.join(DEPLOY, name)
        cur = open(dst, encoding="utf8").read() if os.path.exists(dst) else None
        if cur == want:
            continue
        if write:
            open(dst, "w", encoding="utf8").write(want)
            print(f"  wrote    {name}  ({n:,} bytes, ~{gas(n):,.0f} gas)")
        else:
            print(f"  STALE    {name} -- out of sync with the scoped plan")
            bad += 1
    if write:
        for f in stale:
            os.remove(os.path.join(DEPLOY, f))
            print(f"  removed  {f} (orphaned by a packing change)")
    if bad and not write:
        print(f"PureV10: {bad} problem(s). Run REPL/tools/_purev10.py --write")
    elif not bad:
        print(f"PureV10: clean -- {len(files)} transaction(s) match the scoped round plan")
    return bad


#: Hand-authored, non-generated transactions that ride after the 22 generated ones --
#: `(id, filename, label)`. Not matched by `NN_deploy.pact`, so `check_or_write` never sees them
#: (same invisibility `Deploy/2_Init/00_MANUAL_rotate-s2-governor.pact` relies on); listed here
#: explicitly so `--multipact` can fold them into the SAME round as a second sequential group.
MANUAL_FOLLOWUPS = [
    ("23_repair", "23_repair.pact", "23 — STOAICO repair (A_MigrateGeneralFields)"),
    ("24_contribution", "24_contribution.pact", "24 — STOAICO contribution (A_Stake 4200.0)"),
]


def emit_multipact():
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import _multipact as MP

    names = sorted((f for f in os.listdir(DEPLOY) if re.match(r"^\d+_deploy\.pact$", f)),
                    key=lambda f: int(f.split("_")[0]))
    txs = []
    for name in names:
        path = os.path.join(DEPLOY, name)
        code = io.open(path, encoding="utf-8").read()
        nbytes = len(code.encode())
        mods = ", ".join(module_names(path))
        txs.append(MP.transaction(
            name.replace(".pact", ""), code, label=f"{name[:2]} — {mods}",
            gas_limit=BLOCK_GAS_LIMIT, est_gas=int(gas(nbytes))))

    grp = MP.group(
        "PureV10 — interface-membership sweep (38 interfaces, 36 sovereign modules)",
        "sequential", txs,
        note="STRICTLY ORDERED -- this is a dependency-ordered chain, not a batch that must "
             "clear atomically, but sending out of order leaves a dot-pinned caller aborting "
             "with 'hash not blessed' until its own re-pin send catches up. See README.md for "
             "the full dot-pin cascade.")

    groups = [grp]
    followups = []
    for tx_id, fname, label in MANUAL_FOLLOWUPS:
        path = os.path.join(DEPLOY, fname)
        if not os.path.exists(path):
            continue
        code = io.open(path, encoding="utf-8").read()
        nbytes = len(code.encode())
        followups.append(MP.transaction(
            tx_id, code, label=label, gas_limit=BLOCK_GAS_LIMIT, est_gas=int(gas(nbytes))))
    if followups:
        groups.append(MP.group(
            "PureV10 follow-ups — STOAICO repair + contribution (MANUAL, not generated)",
            "sequential", followups,
            note="Runs AFTER the 22 deploys above are fully confirmed -- tx23 calls a function "
                 "tx21 is what deploys, and tx24 depends on tx23 having landed first. Not part "
                 "of the interface-membership sweep; folded into this same round because both "
                 "fix/use the STOAICO redeploy this round already carries. See "
                 "Deploy/PureV10/23_repair.pact and 24_contribution.pact for the full reasoning "
                 "behind each, including how each was verified against real live chain content "
                 "before being added here.")

        )

    doc = MP.manifest(
        name="Ouronet PureV10", source="python3 REPL/tools/_purev10.py --multipact",
        groups=groups, draft=False,
        signer={"role": "module governance keyset",
                "note": "Transactions 1-22 upgrade a module in ouronet-ns and are signed by "
                        "that module's governance keyset. Transactions 23-24 (if present) call "
                        "STOAICO admin functions and are signed by STOAICO's own admin key -- "
                        "the same keyset, since STOAICO's governance is the Demiurgoi key."},
        defaults={"gasLimit": BLOCK_GAS_LIMIT})

    errs = MP.validate(doc)
    if errs:
        for e in errs:
            print("  INVALID: " + e)
        return 1

    out = os.path.join(DEPLOY, "ROUND.multipact.json")
    with io.open(out, "w", encoding="utf-8") as fh:
        json.dump(doc, fh, indent=1)
    print(MP.summary(doc))
    print(f"\n  wrote {out}")
    print(f"  {len(txs)} transactions, {sum(len(t['code'].encode()) for t in txs):,} bytes, "
          f"~{sum(t['estGas'] for t in txs):,} gas in size charges")
    return 0


def main():
    if "--plan" in sys.argv:
        names = sorted((f for f in os.listdir(DEPLOY) if re.match(r"^\d+_deploy\.pact$", f)),
                        key=lambda f: int(f.split("_")[0]))
        tot, gt = 0, 0.0
        for name in names:
            path = os.path.join(DEPLOY, name)
            b = os.path.getsize(path)
            tot, gt = tot + b, gt + gas(b)
            mods = ", ".join(module_names(path))
            flag = "  !! OVER CAP" if b > MAXBYTES else ""
            print(f"  {name}  {b:7,} bytes  ~{gas(b):9,.0f} gas   {mods}{flag}")
        print(f"\n  {len(names)} transactions, {tot:,} emitted bytes, ~{gt:,.0f} gas total")
        return 0

    if "--multipact" in sys.argv:
        return emit_multipact()

    check, write = "--check" in sys.argv, "--write" in sys.argv
    if not (check or write):
        print(__doc__)
        return 0
    return check_or_write(write)


if __name__ == "__main__":
    sys.exit(main())

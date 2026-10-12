#!/usr/bin/env python3
"""Emit and verify the PureV10 hand-deploy round.

ROUND V10 -- true-fungible beneficiary reassignment, the TF counterpart to the already-live
OF/collectable reassigns (`CCp_ReassignOrtoStakeBeneficiary` / `...CollectableStakeBeneficiary`).

Unlike V9 (and V6-V8 before it), this round does NOT re-derive its transaction bodies from
module source with a bespoke `create-table`-stripping pass: `_deploybundle.py --write` already
regenerates `Deploy/1_Pure/18_deploy.pact` (AQP-FVT) and `Deploy/1_Pure/21_deploy.pact`
(TS02-C3 + AQP-INFO + TS02-DPAD) in upgrade mode as part of the FULL round, and the gate already
diffs those byte-for-byte against the sovereign sources (`_deploybundle.py --check`, fatal in
`_gate.py`). Re-deriving a second time here would be a second implementation of the same
transformation, free to drift from the first. This tool instead just COPIES the two already-
correct files out of the full round and watches that they stay copied.

No dot-pin cascade this round -- `_deploybundle.py --check` against the full round found exactly
these two transactions stale and nothing else: no other module `dot`-calls into AQP-FVT, TS02-C3
or AQP-INFO in a way a hash re-pin would require. See Deploy/PureV10/README.md for the full
writeup (mechanism, defcap shape, the REPL regression test and what it caught).

    python3 REPL/tools/_purev10.py --plan / --write / --check / --multipact
"""
import sys, os, re, json, io

# Same ceiling every round since V3 has used, for the same measured reason (gas_size scales as
# the 7th power of transaction size -- see _purev8.py for the derivation). Both this round's
# files are already comfortably under it (~271 KB / ~299 KB of the ~395 KB practical ceiling).
BLOCK_GAS_LIMIT = 2_000_000
MAXBYTES = 320_000

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPLOY = os.path.join(ROOT, "Deploy", "PureV10")
PURE = os.path.join(ROOT, "Deploy", "1_Pure")

# deploy file (this round) -> source transaction in the full round it is a verbatim copy of.
SOURCES = {
    "01_deploy.pact": "18_deploy.pact",   # AQP-FVT
    "02_deploy.pact": "21_deploy.pact",   # TS02-C3, AQP-INFO, TS02-DPAD (unchanged, co-packed)
}


def module_names(path):
    return re.findall(r'^\(module\s+(\S+)', open(path, encoding="utf8").read(), re.M)


def gas(nbytes):
    return 95_225 * ((nbytes / 1024) / 256) ** 7


def check_or_write(write):
    bad = 0
    for name, src_name in sorted(SOURCES.items()):
        src = os.path.join(PURE, src_name)
        dst = os.path.join(DEPLOY, name)
        if not os.path.exists(src):
            print(f"  MISSING-SOURCE  {src_name} -- run `cd REPL && python3 tools/_deploybundle.py --write` first")
            bad += 1
            continue
        want = open(src, encoding="utf8").read()
        n = len(want.encode())
        if n > MAXBYTES:
            print(f"  TOO BIG  {name} -- {n:,} bytes over the {MAXBYTES:,} cap")
            bad += 1
        cur = open(dst, encoding="utf8").read() if os.path.exists(dst) else None
        if cur == want:
            continue
        if write:
            open(dst, "w", encoding="utf8").write(want)
            print(f"  wrote    {name}  <- {src_name}  ({n:,} bytes, ~{gas(n):,.0f} gas)")
        else:
            print(f"  STALE    {name} -- out of sync with Deploy/1_Pure/{src_name}")
            bad += 1
    if bad and not write:
        print(f"PureV10: {bad} problem(s). Run REPL/tools/_purev10.py --write")
    elif not bad:
        print(f"PureV10: clean -- {len(SOURCES)} transaction(s) match Deploy/1_Pure/")
    return bad


def emit_multipact():
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import _multipact as MP

    txs, missing = [], []
    for name in sorted(SOURCES):
        path = os.path.join(DEPLOY, name)
        if not os.path.exists(path):
            missing.append(name)
            continue
        code = io.open(path, encoding="utf-8").read()
        nbytes = len(code.encode())
        mods = ", ".join(module_names(path))
        txs.append(MP.transaction(
            name.replace(".pact", ""), code, label=f"{name[:2]} — {mods}",
            gas_limit=BLOCK_GAS_LIMIT, est_gas=int(gas(nbytes))))

    if missing:
        print("  MISSING: " + ", ".join(missing) + "\n  Run `--write` first.")
        return 1

    grp = MP.group(
        "PureV10 — true-fungible beneficiary reassignment",
        "sequential",
        txs,
        note="01 (AQP-FVT) carries the new defcap/function and the XI_TrueFungibleStakePhases "
             "extraction; 02 (TS02-C3 + AQP-INFO) carries the Talos wrapper and cost preview that "
             "call into it. Send in order for the same reason every module round does.")
    doc = MP.manifest(
        name="Ouronet PureV10",
        source="python3 REPL/tools/_purev10.py --multipact",
        groups=[grp], draft=False,
        signer={"role": "module governance keyset",
                "note": "Every transaction upgrades a module in ouronet-ns and is signed by "
                        "that module's governance keyset."},
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
        tot, gt = 0, 0.0
        for name, src_name in sorted(SOURCES.items()):
            path = os.path.join(DEPLOY, name)
            src = os.path.join(PURE, src_name)
            b = os.path.getsize(path) if os.path.exists(path) else (
                os.path.getsize(src) if os.path.exists(src) else 0)
            tot, gt = tot + b, gt + gas(b)
            mods = ", ".join(module_names(src)) if os.path.exists(src) else "?"
            flag = "  !! OVER CAP" if b > MAXBYTES else ""
            print(f"  {name}  {b:7,} bytes  ~{gas(b):9,.0f} gas   {mods}{flag}")
        print(f"\n  {len(SOURCES)} transactions, {tot:,} emitted bytes, ~{gt:,.0f} gas total")
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

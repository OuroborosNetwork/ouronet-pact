#!/usr/bin/env python3
"""Emit and verify the PureV9 hand-deploy round.

ROUND V9 -- a frozen leg's id was never "F|" + the native id, and two readers assumed it was.

Reported live, 2026-10-11, right after V8's beneficiary-reassignment fix deployed and testing
resumed: staking a real frozen LP (`F|W|SSTOA-OURO-WSTOA|LP-_MYr9VcKUkBx`) was refused with
"Invalid dptf-id: leg does not match pool canonical asset", while the native leg of the same
pool staked fine. Root cause, confirmed by reading the id-construction path rather than
inferred from the symptom: `VST::XI_CreateSpecialTrueFungibleLink` mints the frozen counterpart
as its OWN token via `XIv_Issue` -> `UDC_Makeid`, which appends a FRESH block-hash-derived
suffix -- not the native token's. Two readers assumed the opposite, reconstructing a "native
id" by stripping the `F|` prefix and comparing the remainder directly, which could never match
a real frozen leg for any pool:

  * AQP-POOL::URC_StakeTrueFungibleDptfMatchesPool (03_AQP.pact)   -- the direct cause
  * AQP-SCORE::URC_StakeLpTokenToNativeLpDptf       (02_SCORE.pact) -- the NEXT blocker, masked
                                                                       by the first while it stood

Both now resolve the frozen leg via `DPTF::UR_Frozen`, the SAME lookup `URCv_CoreDptf`
(`01_ANK.pact`) already used for the reverse direction -- `frozen-link` is written
BIDIRECTIONALLY (`XE_UpdateSpecialTrueFungible`'s `XI_UpdateFrozen` runs once each way), so one
real lookup replaces the broken string surgery both call sites did independently.

A RELATED, NOT-YET-FIXED DEFECT was found in the same function and deliberately left alone:
`URC_StakeLpTokenToNativeLpDptf` also prefix-strips `Z|` (sleeping) ids on the same false
assumption, and there is no existing reverse resolver for that direction to reuse -- unlike
`F|`, `DPTF::UR_Sleeping` is a ONE-WAY write. See DEFECT-LEDGER 8.53 for the full writeup.

AQP-POOL and AQP-SCORE both own tables with live dot-callers --
`python3 REPL/tools/_dotpin.py --upgrade AQP-POOL` / `--upgrade AQP-SCORE` -- so RPS, AQP-VCT,
AQP-INFO and AQP-BOOT all have to re-pin in the SAME round or abort with "hash not blessed" on
their next call in. Six single-module transactions, AQP-SCORE and AQP-POOL first:

  01  AQP-SCORE   the fix (URC_StakeLpTokenToNativeLpDptf)
  02  AQP-POOL    the fix (URC_StakeTrueFungibleDptfMatchesPool)
  03  RPS         dot-pin re-pin only
  04  AQP-VCT     dot-pin re-pin only
  05  AQP-INFO    dot-pin re-pin only
  06  AQP-BOOT    dot-pin re-pin only

No client transaction this round -- both fixes are code changes to how an argument is
VALIDATED, nothing moves, nothing needs migrating.

    python3 REPL/tools/_purev9.py --plan / --write / --check / --multipact
"""
import sys, os, re, difflib, json, io

# StoaChain runs `--block-gas-limit 2000000`; the UI's own fallback constant is
# `STOA_BLOCK_GAS_LIMIT` in `daimons/OuronetUI/src/lib/gas-limits.ts`. Named here rather
# than inlined so the manifest's gasLimit and this file's size-charge model (`gas()`,
# which solves for the same ceiling) cannot drift apart silently.
BLOCK_GAS_LIMIT = 2_000_000

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPLOY = os.path.join(ROOT, "Deploy", "PureV9")
MARK = ";;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev9.py"

# 320,000 BYTES -- the same cap every round since V3, for the same measured reason. The binding
# constraint is GAS, and it scales as the seventh power of transaction size:
#
#   gas_size(S) ~= 95_225 * (S_KB / 256)**7
#
# fitted from the wallet deploy editor's own two data points. See _purev8.py for the full
# derivation; unchanged here.
MAXBYTES = 320_000
# Header allowance used by --plan for a file that has not been emitted yet.
HEADER_RESERVE = 6_000

# A `create-table` form, INCLUDING a trailing ;; comment. An upgrade source must carry none --
# `create-table` aborts the whole transaction on a table that already exists.
CT_RE = r'^\(create-table [^)]*\)[ \t]*(;;.*)?$'

AQP = "1_SOVEREIGN/STAGE_02/2_Core/03_AQP/"

# deploy file -> sources in deploy order.  ("path", mode):
#   module-only    ship from `(module `, create-table stripped -- the interface is already live
MANIFEST = {
    "01_deploy.pact": [(AQP + "02_SCORE.pact", "module-only")],
    "02_deploy.pact": [(AQP + "03_AQP.pact", "module-only")],
    "03_deploy.pact": [(AQP + "04_RPS.pact", "module-only")],
    "04_deploy.pact": [(AQP + "06_VCT.pact", "module-only")],
    "05_deploy.pact": [(AQP + "09_AQP-INFO.pact", "module-only")],
    "06_deploy.pact": [("2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact", "module-only")],
}
FROZEN = {}

HANDWRITTEN = {
    # No client transaction this round -- both fixes are validation-logic changes to how an
    # argument is checked, not to any stored data. Nothing moves, nothing needs migrating.
}

# Interfaces SHIPPED NEW by this round. None -- both fixed functions are module-only, and
# neither module's `implements` clause changed.
NEW_IFACES: list[str] = []

# (callee module, caller module) pairs this round must honour: callee ships STRICTLY earlier.
# Derived from `python3 REPL/tools/_dotpin.py --upgrade AQP-POOL` / `--upgrade AQP-SCORE`,
# restricted to the modules this round touches. Both callees own/reach tables, so a stale
# dot-caller does not merely go stale, it ABORTS with "hash not blessed".
DOT_EDGES: list[tuple[str, str]] = [
    ("AQP-SCORE", "RPS"), ("AQP-SCORE", "AQP-INFO"),
    ("AQP-POOL", "RPS"), ("AQP-POOL", "AQP-VCT"),
    ("AQP-POOL", "AQP-INFO"), ("AQP-POOL", "AQP-BOOT"),
]


def read(rel):
    return open(os.path.join(ROOT, rel), encoding="utf8").read()


def module_name(rel):
    return re.search(r'^\(module\s+(\S+)', read(rel), re.M).group(1)


def source_body(rel, mode):
    text = read(rel)
    k = re.search(r'^\(module ', text, re.M).start()
    body = re.sub(CT_RE, '', text[k:], flags=re.M).rstrip()
    if mode == "iface+upgrade":
        j = re.search(r'^\(interface ', text, re.M).start()
        iface = text[j:k].rstrip()
        note = " (new interface, whole; module as an upgrade -- create-table stripped)"
        return f";; ---- source: {rel}{note}\n{iface}\n\n{body}\n"
    return f";; ---- source: {rel} (module only -- its interface is already live)\n{body}\n"


def body_for(sources):
    out = ['(namespace "ouronet-ns")', ""]
    for rel, mode in sources:
        out.append(source_body(rel, mode))
    return "\n".join(out)


def gas(nbytes):
    return 95_225 * ((nbytes / 1024) / 256) ** 7


def sequence():
    """Global deploy order: (position, deploy file, rel, mode). Modules inside one transaction
    load top to bottom, so position -- not transaction index -- is what ordering constrains."""
    out = []
    for name in sorted(MANIFEST):
        for rel, mode in MANIFEST[name]:
            out.append((len(out), name, rel, mode))
    return out


def check_shape():
    """The two ways an emitted file burns the owner's gas, asserted on the emitted BYTES.

    Neither is visible to a source diff, and neither can be checked in the REPL: the load
    harness deploys from source, so it never sees an upgrade-mode body at all.
    """
    bad = 0
    for name, sources in sorted(MANIFEST.items()):
        body = body_for(sources)
        ct = len(re.findall(r'^\(create-table ', body, re.M))
        if ct:
            print(f"  CREATE-TABLE  {name} -- {ct} create-table form(s) survived into an upgrade; "
                  f"this aborts the transaction on a table that already exists")
            bad += 1
        ifaces = len(re.findall(r'^\(interface ', body, re.M))
        want = sum(1 for _, m in sources if m == "iface+upgrade")
        if ifaces != want:
            print(f"  INTERFACE  {name} -- {ifaces} interface form(s), expected {want}. "
                  f"Too many re-sends a live interface (refused); too few drops a new one and "
                  f"breaks every modref downstream")
            bad += 1
        mods = len(re.findall(r'^\(module ', body, re.M))
        if mods != len(sources):
            print(f"  MODULE  {name} -- {mods} module form(s) for {len(sources)} source(s)")
            bad += 1
    return bad


def check_order():
    """Every dot-callee ships strictly before its callers.

    NO-OPS ON A FROZEN ROUND. Ordering is a constraint on what is ABOUT TO BE SENT; once the
    manifest is empty every file is a record of something already on chain.
    """
    seq, bad = sequence(), 0
    if not seq:
        return 0
    pos = {}
    for i, name, rel, _ in seq:
        pos[module_name(rel)] = (i, name)
    for callee, caller in DOT_EDGES:
        if callee not in pos or caller not in pos:
            continue
        if pos[callee][0] >= pos[caller][0]:
            print(f"  ORDER   {caller} dot-calls {callee}, but {callee} ships in "
                  f"{pos[callee][1]} and {caller} in {pos[caller][1]} -- callee must come EARLIER "
                  f"or {caller} pins a superseded hash and aborts on its tables")
            bad += 1
    for iface in NEW_IFACES:
        born = [i for i, _, rel, mode in seq
                if mode == "iface+upgrade" and re.search(rf'^\(interface {iface}\b', read(rel), re.M)]
        if not born:
            print(f"  INTERFACE  {iface} is listed in NEW_IFACES but no `iface+upgrade` source "
                  f"in the round defines it")
            bad += 1
            continue
        for i, name, rel, mode in seq:
            if i == born[0]:
                continue
            if re.search(rf'\b{iface}\b', read(rel)) and i < born[0]:
                print(f"  ORDER   {rel} names {iface} but ships in {name}, at sequence position "
                      f"{i}, before the interface itself at {born[0]}")
                bad += 1
    return bad


def emit_multipact():
    """Emit the round as ONE Multipact manifest for OuronetUI's deploy queue.

    SEQUENTIAL, AND THE MODE IS THE WHOLE POINT -- see _purev8.py's own docstring for the full
    reasoning (size^7 gas scaling, dot-pin ordering). Unchanged here.
    """
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import _multipact as MP

    txs, missing = [], []
    for name in sorted(MANIFEST) + sorted(HANDWRITTEN):
        path = os.path.join(DEPLOY, name)
        if not os.path.exists(path):
            missing.append(name)
            continue
        code = io.open(path, encoding="utf-8").read()
        nbytes = len(code.encode())
        if name in MANIFEST:
            mods = ", ".join(module_name(r) for r, _ in MANIFEST[name])
            label = f"{name[:2]} — {mods}"
        else:
            label = name
        txs.append(MP.transaction(
            name.replace(".pact", ""), code, label=label,
            gas_limit=BLOCK_GAS_LIMIT, est_gas=int(gas(nbytes))))

    if missing:
        print("  MISSING: " + ", ".join(missing) + "\n  Run `--write` first.")
        return 1

    grp = MP.group(
        "PureV9 — a frozen leg's id is resolved via the real link, not \"F|\" + the native id",
        "sequential",
        txs,
        note="STRICTLY ORDERED. Dot-pin edges between these modules mean a caller "
             "deployed before its callee's upgrade keeps the old callee and later "
             "ABORTS with 'hash not blessed' on an unrelated call. Do not switch this "
             "group to parallel.")
    doc = MP.manifest(
        name="Ouronet PureV9",
        source="python3 REPL/tools/_purev9.py --multipact",
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
        tot, gt, est = 0, 0.0, False
        for name, srcs in sorted(MANIFEST.items()):
            path = os.path.join(DEPLOY, name)
            if os.path.exists(path):
                b, mark = os.path.getsize(path), " "
            else:
                b, mark, est = len(body_for(srcs).encode()) + HEADER_RESERVE, "~", True
            tot, gt = tot + b, gt + gas(b)
            mods = ", ".join(module_name(r) for r, _ in srcs)
            flag = "  !! OVER CAP" if b > MAXBYTES else ""
            print(f"  {name} {mark} {b:7,} bytes  ~{gas(b):9,.0f} gas   {mods}{flag}")
        print(f"\n  {len(MANIFEST)} transactions, {tot:,} emitted bytes, ~{gt:,.0f} gas total "
              f"(per-tx ceiling ~395 KB / 2.00M gas; charge grows as size^7)")
        if est:
            print(f"  `~` = not yet written; body + {HEADER_RESERVE:,}-byte header reserve")
        return 1 if (check_order() + check_shape()) else 0

    if "--multipact" in sys.argv:
        return emit_multipact()

    check, write = "--check" in sys.argv, "--write" in sys.argv
    if not (check or write):
        print(__doc__)
        return 0
    bad = check_order() + check_shape()
    for name, sources in sorted(MANIFEST.items()):
        path = os.path.join(DEPLOY, name)
        if not os.path.exists(path):
            print(f"  MISSING  {name} -- no header written yet")
            bad += 1
            continue
        cur = open(path, encoding="utf8").read()
        if MARK not in cur:
            print(f"  NO-MARKER  {name}")
            bad += 1
            continue
        want = cur.split(MARK)[0] + MARK + "\n\n" + body_for(sources) + "\n"
        n = len(want.encode())
        if n > MAXBYTES:
            print(f"  TOO BIG  {name} -- {n:,} bytes over the {MAXBYTES:,} cap")
            bad += 1
        if want == cur:
            continue
        if write:
            open(path, "w", encoding="utf8").write(want)
            print(f"  wrote    {name}  ({n:,} bytes, ~{gas(n):,.0f} gas)")
        else:
            print(f"  STALE    {name}")
            for line in list(difflib.unified_diff(cur.splitlines(), want.splitlines(),
                                                  "on-disk", "regenerated", lineterm="", n=1))[:12]:
                print(f"           {line[:100]}")
            bad += 1
    known = set(MANIFEST) | set(FROZEN) | set(HANDWRITTEN) | {"README.md", "ROUND.multipact.json"}
    for f in sorted(os.listdir(DEPLOY)) if os.path.isdir(DEPLOY) else []:
        if f not in known:
            print(f"  ORPHAN   {f}")
            bad += 1
    if bad and not write:
        print(f"PureV9: {bad} problem(s). Run REPL/tools/_purev9.py --write")
        return 1
    if not bad:
        print(f"PureV9: clean -- {len(MANIFEST)} generated, {len(FROZEN)} frozen")
    return 0


if __name__ == "__main__":
    sys.exit(main())

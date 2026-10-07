#!/usr/bin/env python3
"""Emit and verify the PureV4 hand-deploy round -- share-based (equity) scoring.

WHY THIS ROUND EXISTS.  Owner observation, 2026-10-07, settling how `E|` shareholder collections
score.  Demiourgos Snakes was *meant* to read "the nonce valued at 500 shares is worth 100", but
the system had no way to say that: a semi-fungible score definition stores a weight PER NONCE,
and an equity nonce's worth in shares is not fixed -- `EQUITY::URC_SingleSharePerMillions`
derives it from the collection's live total, so raising a collection from 1M to 10M shares makes
every stored per-nonce weight stale the instant it is written.

  RULING.  An `E|` collection exposes share-based scoring and NOTHING ELSE -- it is a BUILT-IN
  mechanism, not a definition.  The score itself only decides whether the stake earns debt.
  Score definitions on an equity collection are therefore REFUSED, not merely ignored, because a
  stored definition that can never be read is a lie the UI will eventually display.

AND THE SHARE COUNT CANNOT MOVE TODAY -- recorded because the first draft of this file said it
could, and that was wrong.  `C_IssueShareholderCollection` mints exactly 1,000,000 nonce-1 shares
and grants `R-AddQuantity` to <dpdc> ALONE; the two functions that use it credit PACKAGE nonces,
never nonce 1, and Make/Break escrow shares through <dpdc> rather than minting.  So a stored
per-nonce table would not be stale YET.  The reasons to derive anyway are (a) the variable share
count is a STATED REQUIREMENT, and deriving now means adding EQUITY's own issuance path later will
not force a re-settling of every score already issued, and (b) a table has to be WRITTEN, per
score x per collection x per nonce, and every write is a chance to enter a wrong number.

WHAT CHANGED, in three places:

  `URC_IzEquitySemiFungible` (EQUITY)   the `E|` predicate, promoted to the interface so
                                       AQP-SCORE can ask.  This is why EquityV2 -> V3.
  `URCx_EquityShareRawWeight` (SCORE)   raw weight = SUM over staked nonces of quantity x share
                                       value: 1.0 for nonce 1 (raw shares), and
                                       `URC_SingleSharePerMillions` for the package tiers 2-8.
                                       Derived at STAKE time, so it tracks the live total.
  the dispatch (SCORE)                 `URC_SignedBaseDeltaForDpsfStake` is now three-way:
                                       equity -> share weight, `sft-equality` -> flat, else the
                                       stored per-nonce definition.

REPL EVIDENCE, in three parts, and the second and third both exist because the first was not
enough.

  `[6.1.1]_EQUITY.repl` `TX-EQUITY-004`   the predicate, the weight helper (packaging
                                          weight-neutrality, additivity, out-of-range -> 0), and
                                          the TRACKING property -- the supply is driven 1M -> 10M
                                          with `env-module-admin`, the same module-admin write the
                                          owner uses on mainnet, and the tier weight follows it
                                          x10 while a raw share stays at 1.  Restored in-tx.
  `[6.2.2]_AQP-SCORE.repl` `<<TX-SCORE-15>>`   the definition REFUSAL, plus its non-vacuity pair.
  `[6.2.2]_AQP-SCORE.repl` `<<TX-SCORE-15b>>`  the DISPATCH, through
                                          `URC_SignedBaseDeltaForDpsfStake`.

WHY 15b IS A SEPARATE TRANSACTION.  Every helper assertion above passed with the dispatch branch
DELETED -- they call the helper directly and never traverse the stake path, so the one line that
makes the feature reachable was unpinned.  And the first version of the dispatch assertion sat
inside `<<TX-SCORE-15>>` and read `E|TSEQ-98c486052a51` out of `[6.1.1]`'s fixture, which SEVEN of
the eight gate entrypoints that load `[6.2.2]` never load: green under Stage02_Tester, "No value
found in table DPSF|T|Nonces" everywhere else.  A cross-suite fixture is a load-order bet, not a
fixture.  `<<TX-SCORE-15b>>` issues its own company under a ticker nothing else uses and rolls the
transaction back, so it is self-sufficient in all eight and leaves no trace in any.

THE ROUND IS 12 MODULES, AND ONLY FIVE CHANGED.  The rest are cascade:

  INTERFACE CASCADE.  EquityV2 -> V3.  Every module naming it moves together: AQP-SCORE,
  TS02-C1, INFO-TWO and the citizen DEMIPAD-SNAKES.

  DOT-PIN CASCADE, and it is the expensive one.  AQP-SCORE owns 12 tables and is dot-called by
  RPS and AQP-INFO; RPS is dot-called by AQP-FVT, AQP-VCT, MTX-AQP, AQP-DSA and AQP-INFO;
  AQP-FVT by AQP-INFO and AQP-BOOT.  A stale dot-caller of a table-owning callee does not go
  quietly stale -- it ABORTS with "hash not blessed" -- so the closure is forced even though
  seven of these modules are byte-identical to what is already live.  See REPL/tools/_dotpin.py.

  EQUITY itself is NOT a dot-callee (0 sites), which is the only reason the round is not larger.

PACKING.  1,397,160 EMITTED bytes (sources plus this tool's headers, minus the stripped
create-tables), RPS alone at 296,148 -- so a floor of 5 transactions, and this round is 6.  Gas
grows as the SEVENTH power of size (see MAXBYTES), so the partition is balanced, not greedy: six
balanced transactions total ~412k gas with a worst single transaction of ~224k, which is *below*
V3's worst at eight.  Five would put ~760k on the round and 2.4x the worst case.  Fewer files is
not cheaper here, and --plan measures the EMITTED file rather than the body for the same reason.

  python3 REPL/tools/_purev4.py --check    regenerate in memory, report drift (fatal in _gate)
  python3 REPL/tools/_purev4.py --write    rewrite the bodies
  python3 REPL/tools/_purev4.py --plan     print the packing with sizes, gas and the order proof
"""
import sys, os, re, difflib

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPLOY = os.path.join(ROOT, "Deploy", "PureV4")
MARK = ";;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev4.py"

# 320,000 BYTES -- the same cap as V3, for the same measured reason. The binding constraint is
# GAS, and it scales as the seventh power of transaction size:
#
#   gas_size(S) ~= 95_225 * (S_KB / 256)**7
#
# fitted from the wallet deploy editor's own two data points (3 x ~256 KB = ~285,675 gas against
# ~202,525,154 for one 768 KB transaction), giving an exponent of 6.97 and a ceiling of ~395 KB at
# the 2.00M gas limit. `_purev3.py` carries the full derivation and the record of the 3-file
# consolidation that would have cost ~100,000,000 gas per transaction.
MAXBYTES = 320_000
# Header allowance used by --plan for a file that has not been emitted yet. The six current
# headers run 5,600-5,700 bytes; this is deliberately generous.
HEADER_RESERVE = 6_000

# A `create-table` form, INCLUDING a trailing ;; comment -- `(create-table FVT|T)   ;; Key = ...`.
# The obvious `[^)]+\)\s*$` misses those, and three survived into V3/06 on its first emission. A
# create-table in an UPGRADE aborts the whole transaction on a table that already exists, so the
# miss is paid in the owner's gas at signing time with nothing before it to object.
CT_RE = r'^\(create-table [^)]*\)[ \t]*(;;.*)?$'

AQP = "1_SOVEREIGN/STAGE_02/2_Core/03_AQP/"

# deploy file -> sources in deploy order.  ("path", mode):
#   module-only    ship from `(module `, create-table stripped -- the interface is already live
#   iface+upgrade  ship a NEW interface whole, then the module as an upgrade
MANIFEST = {
    # EquityV3 ships FIRST in the round and in this file, so the three modules that name it below
    # resolve it top-to-bottom within the same transaction.
    "01_deploy.pact": [
        ("1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact", "iface+upgrade"),
        ("1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact",        "module-only"),
        ("1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact",       "module-only"),
        ("2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact",       "module-only"),
    ],
    "02_deploy.pact": [(AQP + "02_SCORE.pact", "module-only")],
    "03_deploy.pact": [(AQP + "04_RPS.pact", "module-only")],
    "04_deploy.pact": [
        (AQP + "07_MTX-AQP.pact", "module-only"),
        (AQP + "08_DSA.pact",     "module-only"),
        (AQP + "06_VCT.pact",     "module-only"),
    ],
    "05_deploy.pact": [(AQP + "05_FVT.pact", "module-only")],
    "06_deploy.pact": [
        (AQP + "09_AQP-INFO.pact", "module-only"),
        ("2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact", "module-only"),
    ],
}
FROZEN = {}
HANDWRITTEN = {}

# Interfaces SHIPPED NEW by this round. Every module naming one must come LATER in the global
# sequence; a module naming an interface that has not loaded yet fails its modref at deploy.
NEW_IFACES = ["EquityV3"]

# (callee module, caller module) pairs this round must honour: callee ships STRICTLY earlier.
# Derived from `_dotpin.py` and restricted to modules in this round.
DOT_EDGES = [
    ("AQP-SCORE", "RPS"), ("AQP-SCORE", "AQP-INFO"),
    ("RPS", "AQP-FVT"), ("RPS", "AQP-VCT"), ("RPS", "MTX-AQP"), ("RPS", "AQP-DSA"),
    ("RPS", "AQP-INFO"),
    ("AQP-FVT", "AQP-INFO"), ("AQP-FVT", "AQP-BOOT"),
    ("AQP-VCT", "AQP-INFO"), ("AQP-DSA", "AQP-INFO"),
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

      create-table in an UPGRADE  aborts the whole transaction. 02_SCORE.pact ends in twelve of
                                  them and 11_EQUITY+.pact in two, all live since round V1.
      interface/module count      `iface+upgrade` emitting `module-only` drops the NEW interface
                                  and every module naming it fails to resolve its modref;
                                  emitting an already-live interface is refused outright.
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
    """Every dot-callee ships strictly before its callers; every new interface before its namers."""
    seq, bad = sequence(), 0
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


def main():
    if "--plan" in sys.argv:
        # EMITTED bytes, not body bytes. `_purev3.py --plan` reported the body and so UNDERSTATED
        # every transaction by the header -- ~5.6 KB here, and at the seventh power a 5.6 KB
        # understatement on the 296 KB file is ~13k gas. `--check` enforces MAXBYTES on the emitted
        # file, so a planner that measures something else is the "proxy whose check is advisory"
        # trap CLAUDE.md records against `_deploybundle.py`. When the file does not exist yet, fall
        # back to body + HEADER_RESERVE and say so, rather than silently reporting a smaller number.
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
    known = set(MANIFEST) | set(FROZEN) | set(HANDWRITTEN) | {"README.md"}
    for f in sorted(os.listdir(DEPLOY)):
        if f not in known:
            print(f"  ORPHAN   {f}")
            bad += 1
    if bad and not write:
        print(f"PureV4: {bad} problem(s). Run REPL/tools/_purev4.py --write")
        return 1
    if not bad:
        print(f"PureV4: clean -- {len(MANIFEST)} generated, {len(FROZEN)} frozen")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Emit and verify the PureV3 hand-deploy round -- the StoicSyntax 2.16 canon sweep.

WHY THIS ROUND EXISTS.  Two owner rulings on 2026-10-06, both from one observation: a score was
issued, and the block explorer could tell you neither what had happened nor what had been made.

  2.16.1  only the MAIN capability of a C_/A_ may be @event; an XI_/XE_/XB_ capability may not.
          8 violations.  Two events for one operation are indistinguishable, to anything reading
          the chain, from two operations.
  2.16.2  an issuance must return the id it generated.  11 violations.  Reporting the name the
          caller typed echoes an INPUT; the id is the only thing the transaction produced, and
          every later operation keys on it.

Plus the work those rulings pulled in: `UEV_SemiFungibleScoreDefinition` (a raw `fold (and)`
lifted out of a capability), `UEV_ScoreDefinitionTargetMatchesPool` (the dead-definition guard),
the five `URH_SCR|` definition-inspection readers, and six arity defects in Talos format strings
found while sweeping.

THE ROUND IS 19 MODULES, AND MOST OF THEM CHANGED NOTHING.  Only 12 were edited.  The other 7
are dragged in by two cascades that are easy to forget and expensive to get wrong:

  INTERFACE CASCADE.  AcquisitionScoresV1 -> V2 (the five readers).  A module holding
  `module{AcquisitionScoresV1} AQP-SCORE` fails its modref check the moment AQP-SCORE implements
  only V2, so all ten modules naming the interface move together.

  DOT-PIN CASCADE.  A dot call resolves at the CALLER's deploy time.  Every module that
  dot-calls an upgraded module must be redeployed too -- and because these callees own tables,
  a stale caller does not merely go stale, it ABORTS with "hash not blessed".  That is why
  04_AQP-BOOT is here: it dot-calls AQP-POOL, and the boot sequence still has steps to run.
  See REPL/tools/_dotpin.py.

ORDERING IS A CORRECTNESS CONSTRAINT, NOT A PREFERENCE.  Within this round every dot-callee must
ship in an EARLIER transaction than its callers, and AcquisitionScoresV2 must precede every
module naming it.  `--check` re-derives both from the sources and fails on a violation, so the
packing cannot silently drift into an order that bricks a module.

PACKING.  2,122,145 bytes across a 314,000-byte usable budget is a floor of 7 transactions; this
round is 8.  The extra one is forced, not sloppy: RPS alone is 290,392 bytes and AQP-SCORE
228,709, so neither shares a transaction with anything large.

  python3 REPL/tools/_purev3.py --check    regenerate in memory, report drift (fatal in _gate)
  python3 REPL/tools/_purev3.py --write    rewrite the bodies
  python3 REPL/tools/_purev3.py --plan     print the packing with sizes and the order proof
"""
import sys, os, re, difflib

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPLOY = os.path.join(ROOT, "Deploy", "PureV3")
MARK = ";;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev3.py"
# 320,000 BYTES. THE BINDING CONSTRAINT IS GAS, AND IT SCALES AS THE SEVENTH POWER OF SIZE.
#
# MEASURED 2026-10-06 from the wallet's deploy editor, which reports the rule outright:
#
#   "The per-transaction ceiling on this network is about 7,769 lines (397 KB), set by how gas
#    scales with size -- not by any size limit. ... 3 ~256 KB transactions cost about 285,675 gas
#    in size charges, against ~202,525,154 for one 768 KB transaction. The charge grows as the
#    seventh power of size, so halving a transaction divides its size charge by 128."
#
# Fitting those two points gives an exponent of 6.97 and a ceiling of 395 KB at the 2.00M limit --
# both matching the editor. So:
#
#   gas_size(S) ~= 95_225 * (S_KB / 256)**7
#
# THIS REPO RECORDED THE CEILING AS UNKNOWN. `_deploybundle.py` says the 320,000 cap is
# "justified by evidence (`04_RPS.pact` is 304,738 bytes and deploys) rather than by a
# specification", and that "what the real byte ceiling is remains UNKNOWN. Something else binds
# first." It is gas, and it binds superlinearly. The conservative guess was very nearly right.
#
# AND IT IS WHY BIGGER FILES ARE THE WRONG INSTINCT. Consolidating this round to 3 transactions of
# ~692 KB was tried on 2026-10-06, reasoning from a LINEAR extrapolation of one measured data
# point (268 KB -> ~300k gas). At the seventh power those transactions cost ~100,000,000 gas EACH
# -- fifty times the limit -- and every one would have been rejected. Optimal contiguous
# partitions of this round, by total gas:
#
#    6 tx  IMPOSSIBLE (needs >395 KB per transaction)
#    7 tx  3,668,468 total, worst single tx 1,598,921 -- 80% of the budget on one transaction
#    8 tx  1,167,414 total, worst   263,564   <-- chosen
#    9 tx    840,708 total, worst   263,564
#   10 tx    582,630 total, worst   211,976
#
# Fewer transactions is not cheaper here, it is exponentially more expensive, and below 7 it is
# not possible at all. 8 is the smallest count that keeps every transaction an order of magnitude
# clear of the ceiling. BALANCE matters more than count: one 320 KB file costs as much as four
# 230 KB files, so the manifest below is a DP-optimal balanced partition, not greedy first-fit.
MAXBYTES = 320_000

# A `create-table` form, INCLUDING a trailing ;; comment.
#
# The obvious pattern -- `^\(create-table [^)]+\)\s*$` -- is what `_purev2.py` and
# `_deploybundle.py` both use, and it MISSES any form annotated with a trailing comment:
#
#     (create-table FVT|T)                      ;; Key = <FVT-ID>
#
# Three of those survived into 06_deploy on the first emission of this round. A surviving
# create-table in an UPGRADE aborts the whole transaction on a table that already exists, so
# the miss is paid for in the owner's gas, at signing time, with nothing before it to object.
CT_RE = r'^\(create-table [^)]*\)[ \t]*(;;.*)?$'

S1C = "1_SOVEREIGN/STAGE_01/2_Core/"
S1T = "1_SOVEREIGN/STAGE_01/3_Talos/"
AQP = "1_SOVEREIGN/STAGE_02/2_Core/03_AQP/"
S2T = "1_SOVEREIGN/STAGE_02/3_Talos/"

# deploy file -> sources in deploy order.  ("path", mode):
#   module-only    ship from `(module `, create-table stripped -- the interface is already live
#   iface+upgrade  ship a NEW interface whole, then the module as an upgrade
MANIFEST = {
    # EMPTY: ROUND V3 IS COMPLETE AND ON MAINNET. Verified 2026-10-07 by the chain itself --
    # `URH_AQP|AllPoolIds` returns 7, and those pools can only exist if Step 7 ran, which requires
    # the AQP-BOOT shipped in V3/08. So every file below is a RECORD of what was sent and must
    # never be regenerated when its source later moves; that is what FROZEN is for, and PureV2's
    # notes record the round being bitten by exactly this four separate times.
    #
    # The equity-scoring work that followed goes to `Deploy/PureV4/` and `_purev4.py`.
}

# EXECUTED ON MAINNET and therefore records, not sources. Verified by the chain:
# `URH_AQP|AllPoolIds` returns 7, and those pools exist only if Step 7 ran, which requires the
# AQP-BOOT shipped in 08. Regenerating any of these would rewrite what was actually sent.
FROZEN = {
    "01_deploy.pact": "SWPI + AQP-ANK (@event strip). Deployed.",
    "02_deploy.pact": "OUROBOROS + TS01-C2/C3 format fixes + DPDC-S set-class output. Deployed.",
    "03_deploy.pact": "AQP-SCORE + the NEW AcquisitionScoresV2 interface. Deployed.",
    "04_deploy.pact": "AQP-POOL dead-definition guard + TS02-C1/C2 set-class ids. Deployed.",
    "05_deploy.pact": "RPS (@event strip). Deployed.",
    "06_deploy.pact": "AQP-FVT + MTX-AQP + AQP-DSA (interface/dot-pin cascade). Deployed.",
    "07_deploy.pact": "AQP-VCT + TS02-C3 score-id output strings. Deployed.",
    "08_deploy.pact": "AQP-INFO + AQP-BOOT (Step 7, 11 score ids) + O-UI-FOURTEEN. Deployed.",
}
HANDWRITTEN = {}

# (callee module, caller module) pairs this round must honour: callee ships STRICTLY earlier.
# Derived from `_dotpin.py` and restricted to modules in this round.
DOT_EDGES = [
    ("RPS", "AQP-FVT"), ("RPS", "AQP-VCT"), ("RPS", "MTX-AQP"), ("RPS", "AQP-DSA"),
    ("RPS", "AQP-INFO"),
    ("AQP-SCORE", "RPS"), ("AQP-SCORE", "AQP-INFO"),
    ("AQP-POOL", "RPS"), ("AQP-POOL", "AQP-VCT"), ("AQP-POOL", "AQP-INFO"),
    ("AQP-POOL", "AQP-BOOT"),
    ("AQP-FVT", "AQP-INFO"), ("AQP-FVT", "AQP-BOOT"),
    ("AQP-VCT", "AQP-INFO"), ("AQP-DSA", "AQP-INFO"),
    ("AQP-ANK", "RPS"), ("AQP-ANK", "AQP-VCT"), ("AQP-ANK", "AQP-BOOT"),
    ("TS02-C3", "AQP-INFO"), ("TS02-C3", "AQP-BOOT"),
]


def module_name(path):
    t = open(os.path.join(ROOT, path), encoding="utf8").read()
    return re.search(r'^\(module\s+(\S+)', t, re.M).group(1)


def source_body(rel, mode):
    text = open(os.path.join(ROOT, rel), encoding="utf8").read()
    if mode == "iface+upgrade":
        j, k = text.index("(interface "), text.index("(module ")
        iface = text[j:k].rstrip()
        body = re.sub(CT_RE, '', text[k:], flags=re.M).rstrip()
        note = " (new interface, whole; module as an upgrade -- create-table stripped)"
        return f";; ---- source: {rel}{note}\n{iface}\n\n{body}\n"
    k = text.index("(module ")
    body = re.sub(CT_RE, '', text[k:], flags=re.M).rstrip()
    return f";; ---- source: {rel} (module only -- its interface is already live)\n{body}\n"


def body_for(sources):
    out = ['(namespace "ouronet-ns")', ""]
    for rel, mode in sources:
        out.append(source_body(rel, mode))
    return "\n".join(out)


def check_shape():
    """The two ways an emitted file burns the owner's gas, asserted on the emitted BYTES.

    Neither is visible to a source diff, and neither can be checked in the REPL: the load
    harness cannot deploy 03 at all, because `deploy-stage02` has already loaded V2 from source
    and Pact refuses an interface name twice. So this is the only place they get checked.

      create-table in an UPGRADE  aborts the whole transaction. 02_SCORE.pact ends in twelve of
                                  them, every table live since round V1.
      interface/module count      `iface+upgrade` emitting `full` re-sends the create-tables;
                                  emitting `module-only` drops the new interface entirely and
                                  every consumer downstream fails to resolve its modref.
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
    """Every dot-callee must ship strictly before its callers, and V2 before its namers."""
    # SEQUENCE POSITION, not transaction index. Two modules in the same transaction are still
    # ordered relative to each other -- the file deploys them top to bottom -- so the constraint is
    # "callee earlier in the global sequence", and requiring a strictly earlier FILE would reject
    # correct packings. (It did: it was why this round was eight transactions instead of three.)
    pos, bad, seq = {}, 0, 0
    for i, (name, srcs) in enumerate(sorted(MANIFEST.items())):
        for rel, _ in srcs:
            pos[module_name(rel)] = (seq, name)
            seq += 1
    for callee, caller in DOT_EDGES:
        if callee not in pos or caller not in pos:
            continue
        if pos[callee][0] >= pos[caller][0]:
            print(f"  ORDER   {caller} dot-calls {callee}, but {callee} ships in "
                  f"{pos[callee][1]} and {caller} in {pos[caller][1]} -- callee must come EARLIER "
                  f"or {caller} pins a superseded hash and aborts on its tables")
            bad += 1
    # AcquisitionScoresV2 must precede every module naming it
    iface_seq, k = None, 0
    for name, srcs in sorted(MANIFEST.items()):
        for rel, m in srcs:
            if m == "iface+upgrade" and iface_seq is None:
                iface_seq = k
            k += 1
    k = 0
    for name, srcs in sorted(MANIFEST.items()):
        for rel, mode in srcs:
            cur, k = k, k + 1
            if mode == "iface+upgrade":
                continue
            if "AcquisitionScoresV2" in open(os.path.join(ROOT, rel), encoding="utf8").read() \
               and cur < iface_seq:
                print(f"  ORDER   {rel} names AcquisitionScoresV2 but ships in {name}, "
                      f"before the interface itself")
                bad += 1
    return bad


def main():
    if "--plan" in sys.argv:
        tot = 0
        for name, srcs in sorted(MANIFEST.items()):
            b = len(body_for(srcs).encode())
            tot += b
            mods = ", ".join(module_name(r) for r, _ in srcs)
            g = 95_225 * ((b / 1024) / 256) ** 7
            flag = "  !! OVER CAP" if b > MAXBYTES else ""
            print(f"  {name}  {b:7,} bytes  ~{g:9,.0f} gas   {mods}{flag}")
        gt = sum(95_225 * ((len(body_for(s).encode()) / 1024) / 256) ** 7 for s in MANIFEST.values())
        print(f"\n  {len(MANIFEST)} transactions, {tot:,} bytes, ~{gt:,.0f} gas total "
              f"(per-tx ceiling ~395 KB / 2.00M gas; charge grows as size^7)")
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
            print(f"  wrote    {name}  ({n:,} bytes)")
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
        print(f"PureV3: {bad} problem(s). Run REPL/tools/_purev3.py --write")
        return 1
    if not bad:
        print(f"PureV3: clean -- {len(MANIFEST)} generated, {len(FROZEN)} frozen")
    return 0


if __name__ == "__main__":
    sys.exit(main())

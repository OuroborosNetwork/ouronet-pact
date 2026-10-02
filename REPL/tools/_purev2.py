#!/usr/bin/env python3
"""Emit and verify the PureV2 hand-deploy round from its module sources.

WHY THIS EXISTS.  `Deploy/` proper is generated and diffed by `_deploybundle.py`, and the
AppReads modules are EXCLUDED from that round because the owner deploys them one at a time
by hand.  Excluded meant unchecked, and a deploy file assembled by hand is a COPY of a module
-- copies drift.  On 2026-09-24 a price formatter was transcribed with an ASCII `c` where the
original had `¢`, and the wrong glyph reached mainnet in two modules before anything noticed,
because nothing compared the deploy file to the module it claims to deploy.

So the body of every live PureV2 file is now GENERATED.  Each file keeps its hand-written
prose header -- that is the part worth writing by hand -- terminated by the GENERATED marker
below; everything after the marker is the concatenated module sources, byte for byte.

FROZEN files are deploy files already executed on mainnet.  They are the RECORD of what was
sent, so they must NOT be regenerated when their source later changes; a superseding upgrade
file is the correct response instead.  They are listed, with the reason, rather than omitted,
because a file that is silently out of scope is indistinguishable from one that was forgotten.

  python3 REPL/tools/_purev2.py --check    regenerate in memory, report drift (fatal in _gate)
  python3 REPL/tools/_purev2.py --write    rewrite the bodies
"""
import sys, os, re, difflib

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPLOY = os.path.join(ROOT, "Deploy", "PureV2")
SRC = os.path.join(ROOT, "2_CITIZEN", "Stage_Z")   # manifest paths hang off here
MARK = ";;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py"

# deploy file -> list of sources in deploy order.  A source is "path" for the whole file, or
# ("path", "module-only") to emit the module form WITHOUT its interface.
#
# `module-only` is not an optimisation, it is a HARD REQUIREMENT for an upgrade.  Pact refuses
# to deploy an interface name a second time -- byte-identical included -- so shipping a module
# source verbatim when its interface is already live fails the transaction outright
# ("Interface cannot be upgraded"), which is how deploy round V1 lost tx 11 and tx 21.  Modules
# upgrade freely; interfaces never do.
MANIFEST = {
    "13_deploy.pact": [("AppReads/OuronetUI/01_O-UI-ONE.pact", "module-only"),
                       ("AppReads/OuronetUI/02_O-UI-TWO.pact", "module-only"),
                       ("AppReads/OuronetUI/03_O-UI-THREE.pact", "module-only"),
                       ("AppReads/OuronetUI/12_O-UI-TWELVE.pact", "module-only")],
    "14_deploy.pact": [("01_DPL-UR.pact", "module-only")],
    "16_deploy.pact": [("../../1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact",
                        "module-only")],
    "17_deploy.pact": ["AppReads/OuronetUI/08_O-UI-EIGHT.pact",
                       "AppReads/OuronetUI/09_O-UI-NINE.pact"],
    "18_deploy.pact": [("AppReads/OuronetUI/02_O-UI-TWO.pact", "module-only")],
    "19_deploy.pact": ["AppReads/Pythia/01_P-UI-ONE.pact"],
    "20_deploy.pact": [("../../1_SOVEREIGN/STAGE_01/Z_Reads/02_INFO-ONE+.pact",
                        "module-only")],
    "22_deploy.pact": [("../../1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact",
                        "module-only")],
    "23_deploy.pact": [("../4_BunniesMinter/02_KBunnies.pact", "module-only")],
    "25_deploy.pact": [("../5_VaultsMinter/04_AQP-BOOT.pact", "module-only")],
}

# Hand-written files with no module source: init transactions, table repairs. They are not
# generated, so there is nothing to diff -- but they are listed so the orphan sweep does not
# report them, and so "not generated" is a recorded decision rather than an omission.
HANDWRITTEN = {
    "15_deploy.pact": "create-table repair for the eight tables round V1 shipped commented out, "
                      "plus SWPI::A_RebuildGraph to backfill the swap graph. No module body.",
    "24_deploy.pact": "AQP inter-module permissions (TS02-C1/C2/C3 P|A_Define -- only C3 was "
                      "actually missing) plus the never-written DALOS stoa|price oracle key. "
                      "Four admin calls, no module body.",
}

FROZEN = {
    "05_deploy.pact": "executed on mainnet 2026-09-25 (O-UI-TWELVE first deploy); the record of what was sent",
    "06_deploy.pact": "executed on mainnet 2026-09-25 (O-UI-ONE + O-UI-TWO formatter fix); the record of what was sent",
    "07_deploy.pact": "executed on mainnet 2026-09-25 (O-UI-EIGHT first deploy); the record of what was sent",
    "08_deploy.pact": "executed on mainnet 2026-09-25 (O-UI-NINE first deploy); the record of what was sent",
    "09_deploy.pact": "executed on mainnet 2026-09-25 (O-UI-TEN first deploy); the record of what was sent",
    "10_deploy.pact": "executed on mainnet 2026-09-25 (O-UI-SEVEN first deploy); the record of what was sent",
    "11_deploy.pact": "executed on mainnet 2026-09-25 (O-UI-FOUR first deploy); the record of what was sent",
    "12_deploy.pact": "executed on mainnet 2026-09-25 (OUiThreeV2 + O-UI-THREE upgrade); the record of what was sent",
    "01_deploy.pact": "executed on mainnet 2026-09-24 (OuronetIdsV1 + O-UI-ONE first deploy); "
                      "superseded for the formatter fix by 06_deploy.pact",
    "02_deploy.pact": "executed on mainnet 2026-09-24 (OUiTwoV1 + O-UI-TWO first deploy); "
                      "superseded for the formatter fix by 06_deploy.pact",
    "03_deploy.pact": "executed on mainnet 2026-09-24 (DALOS kadena-konto revert); not an "
                      "AppReads module, and its body is a hand-trimmed upgrade of a sovereign "
                      "core file",
    "04_deploy.pact": "executed on mainnet 2026-09-24 (OUiThreeV1 + O-UI-THREE first deploy); "
                      "superseded for the recovery reads by 12_deploy.pact",

    # NOT A MODULE DEPLOY AT ALL, which is a third category this registry did not have. 21 is a
    # one-shot ADMINISTRATIVE transaction: `acquire-module-admin` plus a single `insert` that
    # writes DEMIPAD-STOICPAY's `KPAY|T|Properties` row -- the sale's own asset-id, which the
    # module declares a table for and has no function to write. There is no source to regenerate
    # it from, so "stale" is not a state it can be in.
    #
    # Listed here rather than exempted by a filename pattern, for the reason the docstring gives
    # about FROZEN: a file silently out of scope is indistinguishable from one that was
    # forgotten. The gate found this within minutes of the file being written, which is the
    # behaviour worth keeping.
    "21_deploy.pact": "not a module deploy -- a one-shot admin tx (acquire-module-admin + one "
                      "insert) writing DEMIPAD-STOICPAY's KPAY|T|Properties row; nothing to "
                      "generate it from",
}


def body_for(sources):
    """The generated half: namespace form, then each source from its first top-level form."""
    out = ['(namespace "ouronet-ns")', ""]
    for src in sources:
        rel, mode = src if isinstance(src, tuple) else (src, "full")
        text = open(os.path.join(SRC, rel), encoding="utf8").read()
        if mode == "module-only":
            i = text.index("(module ")
            note = " (module only -- its interface is already live)"
            # AND NO create-table. A module source ends with the `(create-table ...)` forms its
            # FIRST deploy needs; an upgrade must never re-run them, because re-creating an
            # existing table aborts the whole transaction -- "Table ouronet-ns.DALOS_P|T already
            # exists". The AppReads upgrades have no tables, so this went unnoticed until
            # 16_deploy carried DALOS, whose source ends in seven of them. Caught by loading the
            # emitted file in the REPL, which is the only reason it did not reach a signer.
            text = re.sub(r'^\(create-table [^)]+\)\s*$', '', text[i:], flags=re.M)
            i = 0
        else:
            # drop the file's own ;;-comment banner; the deploy file has its own header
            i = min((text.index(t) for t in ("(interface ", "(module ") if t in text))
            note = ""
        out.append(f";; ---- source: 2_CITIZEN/Stage_Z/{rel}{note}")
        out.append(text[i:].rstrip())
        out.append("")
    return "\n".join(out)


def main():
    check = "--check" in sys.argv
    write = "--write" in sys.argv
    if not (check or write):
        print(__doc__)
        return 0
    bad = 0
    for name, sources in sorted(MANIFEST.items()):
        path = os.path.join(DEPLOY, name)
        if not os.path.exists(path):
            print(f"  MISSING  {name} -- no header written yet")
            bad += 1
            continue
        cur = open(path, encoding="utf8").read()
        if MARK not in cur:
            print(f"  NO-MARKER  {name} -- header is not terminated by the generated marker")
            bad += 1
            continue
        head = cur.split(MARK)[0]
        want = head + MARK + "\n\n" + body_for(sources) + "\n"
        if want == cur:
            continue
        if write:
            open(path, "w", encoding="utf8").write(want)
            print(f"  wrote    {name}")
        else:
            print(f"  STALE    {name} -- body differs from {', '.join(r if isinstance(r, str) else r[0] for r in sources)}")
            d = list(difflib.unified_diff(cur.splitlines(), want.splitlines(),
                                          "on-disk", "regenerated", lineterm="", n=1))
            for line in d[:12]:
                print(f"           {line[:100]}")
            bad += 1
    known = set(MANIFEST) | set(FROZEN) | set(HANDWRITTEN) | {"README.md"}
    for f in sorted(os.listdir(DEPLOY)):
        if f not in known:
            print(f"  ORPHAN   {f} -- not in MANIFEST and not FROZEN")
            bad += 1
    if bad and not write:
        print(f"PureV2: {bad} file(s) stale, missing or orphaned. "
              f"Run REPL/tools/_purev2.py --write")
        return 1
    if not bad:
        print(f"PureV2: clean -- {len(MANIFEST)} generated, {len(FROZEN)} frozen, "
              f"{len(HANDWRITTEN)} hand-written")
    return 0


if __name__ == "__main__":
    sys.exit(main())

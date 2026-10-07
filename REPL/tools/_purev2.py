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
# A `create-table` form INCLUDING a trailing ;; comment.
#
# CORRECTED 2026-10-06. This was `^\(create-table [^)]+\)\s*$`, which misses any form carrying a
# trailing comment -- `(create-table FVT|T)   ;; Key = <FVT-ID>`. No PureV2 file happens to contain
# one, so it never bit here; the identical pattern in the V3 round left THREE create-table forms in
# an upgrade transaction, and a surviving create-table ABORTS the whole transaction on a table that
# already exists. The cost of the miss is the owner's gas, at signing time, with nothing before it
# to object. (`_deploybundle.py` is unaffected: its TABLE_RE has no `$` anchor and re-emits table
# names canonically rather than deleting lines.)
CT_RE = r'^\(create-table [^)]*\)[ \t]*(;;.*)?$'

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
    # EMPTY, AND THAT IS THE POINT: ROUND V2 IS COMPLETE.
    #
    # The owner deployed through 34 on 2026-10-06 ("I have deployed up to deploy 34"), and 35 is
    # superseded by round V3. A deploy file that has been SENT is a record of what was sent, so it
    # must never be regenerated when its source later moves -- that is what FROZEN is for, and
    # four separate notes below record the round leaving a landed file in MANIFEST and having its
    # body silently rewritten by the next source change.
    #
    # New work goes to `Deploy/PureV3/` and `REPL/tools/_purev3.py`. This tool stays live because
    # it still answers two questions: that no frozen body was touched, and that no file appeared
    # in the directory without an entry -- the ORPHAN check, which is the only reason the loss of
    # this tool's uncommitted state on 2026-10-06 was noticeable at all.
}

HANDWRITTEN = {
    # NOT GENERATED: it has no module body at all. It is a table-repair transaction -- the seven
    # `(create-table ouronet-ns.X.Y)` forms round V1 shipped commented out -- plus
    # SWPI::A_RebuildGraph to backfill the swap graph. Its create-tables are its PURPOSE, which is
    # why the `check_shape`-style create-table alarm added to the V3 tool would be wrong here.
    "15_deploy.pact": "create-table repair for the eight tables round V1 shipped commented out, "
                      "plus SWPI::A_RebuildGraph to backfill the swap graph. No module body.",
}

FROZEN = {
    # ── 13-35, FROZEN 2026-10-06 ──────────────────────────────────────────────────────────────
    # Basis: the owner's statement that mainnet carries through 34, plus 35 superseded by V3.
    # RECONSTRUCTED after a `git checkout` of this tool discarded the prior session's uncommitted
    # entries; the files were on disk and surfaced as ORPHANs, which is how the loss was seen.
    "13_deploy.pact": "AppReads O-UI-ONE/TWO/THREE/TWELVE. Deployed.",
    "14_deploy.pact": "DPL-UR. Deployed.",
    "16_deploy.pact": "DALOS. Deployed.",
    "17_deploy.pact": "O-UI-EIGHT + O-UI-NINE. Deployed.",
    "18_deploy.pact": "O-UI-TWO. Deployed.",
    "19_deploy.pact": "P-UI-ONE. Deployed.",
    "20_deploy.pact": "INFO-ONE+. Deployed.",
    "22_deploy.pact": "ATS. Deployed.",
    "23_deploy.pact": "KBunnies. Deployed.",
    "24_deploy.pact": "IGNIS + AQP-BOOT. Deployed -- its body predates the TS02-C3 V2 cascade, "
                      "which is why it no longer matches today's source. That is a record, not drift.",
    "26_deploy.pact": "O-UI-THIRTEEN. Deployed -- body predates later O-UI-THIRTEEN work.",
    "27_deploy.pact": "AQP-ANK LP anchors. Deployed. Module re-ships in Deploy/PureV3/01.",
    "28_deploy.pact": "Talos vacate rename + interface cascade. Deployed.",
    "29_deploy.pact": "Deployed.",
    "30_deploy.pact": "Deployed.",
    "31_deploy.pact": "Deployed (owner-confirmed).",
    "32_deploy.pact": "Deployed.",
    "33_deploy.pact": "Deployed.",
    "34_deploy.pact": "O-UI-FOURTEEN boost-link + lp-denominator. Deployed (owner-confirmed).",
    # ── 35: DEPLOYED, AND SUPERSEDED. Owner-confirmed 2026-10-06. ─────────────────────────────
    # The AQP-BOOT Step 7 fix (the eager `let` that read seven pools before creating them). It IS
    # on mainnet; `URH_AQP|AllPoolIds` reads 0 only because Step 7 has not been RE-RUN since.
    #
    # Harmless where it sits, because it landed BEFORE round V3. The hazard was only ever the
    # other order: re-sending it AFTER V3/03 would put back an AQP-BOOT naming
    # `module{AcquisitionScoresV1}`, which stops resolving once AQP-SCORE implements only V2 --
    # and because AQP-BOOT DOT-CALLS AQP-POOL, that copy would ABORT with "hash not blessed"
    # rather than going quietly stale. V3/08 re-ships the identical Step 7 fix with the bump.
    #
    # ONE OPERATIONAL CONSEQUENCE: do not run Step 7 BETWEEN V3/04 and V3/08. V3/04 upgrades
    # AQP-POOL, which this AQP-BOOT dot-calls, so the boot is pinned-and-broken until V3/08
    # redeploys it. Run Step 7 before the round starts, or after it finishes.
    "35_deploy.pact": "AQP-BOOT Step 7 fix -- DEPLOYED, superseded by Deploy/PureV3/08.",
    # EXECUTED ON MAINNET 2026-10-03 -- module hash czxa3OAGASamWMsViJlVsX7SvuA1odY6L5-cKL7gsKw.
    # It was in MANIFEST until the moment it landed, and the very next `--write` regenerated its
    # body from a source that had since gained URC_13|AnchorFull -- rewriting the record of what
    # was actually sent, which is the one thing a deploy file must never do. Superseded by
    # 26_deploy.pact, which is the correct response to a frozen file's source changing.
    "25_deploy.pact": "executed on mainnet 2026-10-03 (O-UI-THIRTEEN first deploy, with "
                      "OUiThirteenV1); the record of what was sent. Superseded by 26_deploy.pact",
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
            text = re.sub(CT_RE, '', text[i:], flags=re.M)
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

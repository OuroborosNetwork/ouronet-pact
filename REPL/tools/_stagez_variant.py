#!/usr/bin/env python3
"""Generate the REPL-only Stage-Z TESTING VARIANT from the canonical module (never edit canonical).

WHY THIS EXISTS
---------------
2_CITIZEN/Stage_Z/02_EXPLORER.pact is headed "canonical; keep aligned with live net" and hardcodes
LIVE-chain ids (Auryndex-O136CBn22ncY, EliteAuryndex-O136CBn22ncY). A REPL sandbox derives its own
deployment hash (98c486052a51), so those rows cannot exist and URC_0001_LandingPage aborts with
"No value found in table". That is the whole reason the function was never reached by any test.

The owner's ruling was: do NOT edit canonical -- use a variant for testing, carrying the testing ids.

This script IS that variant, expressed as a generator rather than a checked-in copy. A checked-in
copy rots the moment someone edits canonical and forgets the copy; a generated one cannot, because
`--check` fails the gate the instant the two diverge. The diff is confined to a whitelist of exact
string substitutions, so the variant cannot acquire behaviour canonical does not have.

USAGE
    python3 _stagez_variant.py            # (re)generate REPL/_generated/*.pact
    python3 _stagez_variant.py --check    # exit 1 if the generated file is stale vs canonical

READ BEFORE EXTENDING
    DPL-UR::URC_0001_HeaderV3 is NOT fixable by id substitution alone -- see the note in
    VARIANTS below. Do not add it here expecting it to work.
"""
import sys, os, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
OUTDIR = pathlib.Path(__file__).resolve().parent.parent / "_generated"

# The sandbox's deployment hash. Verified live, not assumed: modules/_probe_stagez.repl showed
# ATS.UR_IndexName "Auryndex-98c486052a51" -> "Auryndex" on a deploy-only chain, while the mainnet
# id "Auryndex-O136CBn22ncY" is ABSENT.
SANDBOX_HASH = "98c486052a51"

# RETIRED 2026-09-24 -- EMPTY ON PURPOSE. Read this before adding an entry back.
#
# This tool existed for exactly one reason: EXPLORER::URC_0001_LandingPage hardcoded two mainnet
# ATS pair ids, so it aborted on any sandbox, so no test could reach it. The owner's ruling at
# the time was "do NOT edit canonical -- use a variant for testing", and this generator was that
# variant.
#
# THE PREMISE IS GONE. Those ids are now DERIVED at call time (EXPLORER, and the fourteen in
# DPL-UR::URC_0001_HeaderV3 with them, after the 2026-09-24 dashboard outage). Canonical is
# chain-agnostic, so it runs in the fixture directly and the variant has nothing left to
# substitute. STAGE-Z.repl now asserts against canonical, which is strictly better: one module
# under test instead of a near-copy, and the coverage tools stop reporting the real function as
# unreached because the real function is the one being called.
#
# That supersedes the owner ruling above rather than ignoring it. The ruling said not to edit
# canonical TO SUIT A TEST; this edit was made to fix a production outage, and it moved canonical
# CLOSER to "aligned with live net", not further -- a derived id is right on every chain.
#
# HOW IT FAILED FIRST, which is the part worth keeping. The `subs` entries carried an exact
# occurrence count, and the comment beside them read: "Each MUST appear the stated number of
# times, or generation fails -- that is what stops a canonical rename from silently producing a
# no-op variant." It did not stop it. The count was taken over the raw file, COMMENTS INCLUDED,
# so when the fix replaced the two literals with derivations and mentioned the old ids in the
# explanatory comment, the substitution matched the COMMENT, hit its count of 1, and reported
# success while changing no code. The generated variant was byte-for-byte canonical apart from
# the module rename, and the gate was green.
#
# So if you ever repopulate this list: count occurrences OUTSIDE `;;` comments, or the guard is
# decorative. A whitelist that can be satisfied by prose is not a whitelist.
#
# DPL-UR was never here anyway, and the reason still stands: substituting its ids would not have
# made it run, because the sandbox has no WSTOA/SSTOA/GSTOA tokens and SWPI::URC_OuroPrimordialPrice
# has no pools to price against. It needed a fixture, not a variant -- and now it needs neither.
VARIANTS = []

HEADER = """;; GENERATED FILE -- DO NOT EDIT. Regenerate with: python3 REPL/tools/_stagez_variant.py
;;
;; REPL-ONLY TESTING VARIANT of {src}
;; Generated because the canonical module is headed "keep aligned with live net" and must not be
;; edited to suit a test. This copy differs from canonical in EXACTLY these ways:
;;   - module renamed {old} -> {new} (so it deploys ALONGSIDE canonical, never shadowing it)
{sublines}
;; Nothing else. `python3 _stagez_variant.py --check` fails the gate if canonical moves and this
;; file is not regenerated, so the variant cannot drift into testing behaviour canonical lacks.
;;
;; HONESTY NOTE: a test against this file proves the LOGIC of the canonical function is correct.
;; It does NOT prove the canonical module works on this chain -- canonical still cannot, by
;; construction, because its ids name a different deployment. Coverage tooling therefore keeps
;; reporting canonical EXPLORER::URC_0001_LandingPage as unreached, and that report is CORRECT.
;;
"""


def build(v):
    src_path = ROOT / v["src"]
    text = src_path.read_text()
    applied = []
    for old, new, expected in v["subs"]:
        n = text.count(old)
        if n != expected:
            sys.exit(
                f"_stagez_variant.py: expected {expected} occurrence(s) of {old} in {v['src']}, "
                f"found {n}. Canonical changed -- review before regenerating."
            )
        text = text.replace(old, new)
        applied.append(f";;   - {old} -> {new}")
    old_mod, new_mod = v["module"]
    marker = f"(module {old_mod} GOV"
    if text.count(marker) != 1:
        sys.exit(f"_stagez_variant.py: could not find a unique '{marker}' in {v['src']}.")
    text = text.replace(marker, f"(module {new_mod} GOV")
    head = HEADER.format(src=v["src"], old=old_mod, new=new_mod, sublines="\n".join(applied))
    return head + text


def main():
    check = "--check" in sys.argv
    OUTDIR.mkdir(exist_ok=True)
    stale = []
    for v in VARIANTS:
        want = build(v)
        dest = OUTDIR / v["out"]
        have = dest.read_text() if dest.exists() else None
        if check:
            if have != want:
                stale.append(v["out"])
        else:
            dest.write_text(want)
            print(f"wrote {dest.relative_to(ROOT)}  ({len(want.splitlines())} lines)")
    if check:
        if stale:
            sys.exit(
                "_stagez_variant.py --check: STALE variant(s): " + ", ".join(stale) +
                "\n  Canonical Stage-Z source moved but the testing variant was not regenerated."
                "\n  Fix: python3 REPL/tools/_stagez_variant.py"
            )
        if not VARIANTS:
            print("_stagez_variant.py --check: OK -- no variants configured (retired 2026-09-24; "
                  "see the note above VARIANTS).")
        else:
            print(f"_stagez_variant.py --check: OK -- {len(VARIANTS)} variant(s) in sync with "
                  f"canonical.")


if __name__ == "__main__":
    main()

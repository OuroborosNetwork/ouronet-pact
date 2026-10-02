#!/usr/bin/env python3
"""_dotpin.py -- which modules must be REDEPLOYED when another module is upgraded.

WHY THIS EXISTS, and it cost a live transaction to learn.

A cross-module call written with a DOT -- `(KBN.A_BunnyRGBSet ...)` -- resolves at the CALLER's
deploy time and the callee's code is pinned into the caller. A call written with a MODREF --
`(ref-KBN::A_BunnyRGBSet ...)` -- resolves at RUNTIME. Measured, not assumed:

    module A calls B.f  (dot)         module A calls ref-B::f  (modref)
    upgrade B                          upgrade B
    B.f  -> "NEW"                      B.f  -> "NEW"
    A.g  -> "OLD"   <-- pinned         A.g  -> "NEW"

MAINNET, 2026-10-02. KBN was upgraded at block 621,458 to write Arweave artwork into the Bunny
RGB Set. AQP-BOOT's Step 1 ran at block 621,472 -- fourteen blocks LATER -- and wrote the OLD
placeholder strings, because AQP-BOOT had not been redeployed and was still carrying the KBN it
was compiled against. The owner then had to repair the set by hand with C_UpdateSetNonceURI.

Nothing reported it. The deploy planner orders a round by DEPENDENCY, which is the right order
for a first deploy and says nothing about who must be REFRESHED after a single-module upgrade.
`CLAUDE.md` has a cascade rule, but it is about INTERFACES -- bump B's interface and every module
naming it must bump too. This is a DIFFERENT cascade with no rule attached: upgrade B's BODY and
every module that dot-calls B keeps the old body, silently, with no version to disagree about.

WHAT IS AND IS NOT AT RISK. Only CODE is pinned; TABLES are not. A pinned `UR_Konto` still reads
the live table, so a pure reader whose logic has not changed is harmless. The damage is where the
callee's BEHAVIOUR changed -- a constant in the body, a new guard, a corrected formula -- which is
exactly the KBN case: two hardcoded URL strings.

USAGE
  python3 REPL/tools/_dotpin.py                   every dot edge, grouped by callee
  python3 REPL/tools/_dotpin.py --upgrade KBN     who must be redeployed if KBN ships
  python3 REPL/tools/_dotpin.py --check           fail if a dot edge is not registered below
"""
import argparse, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TOPS = ("1_SOVEREIGN", "2_CITIZEN")

# KNOWN DOT EDGES, as (caller-file-basename, callee). Registered rather than merely counted,
# for the reason the IMP registry gives: a number nobody can attribute is a number nobody
# re-derives. A NEW edge is fatal in --check, so adding one is a decision with a reason
# attached, not a default.
#
# Most of these are READS whose logic is stable, and they are listed to be seen, not to be
# fixed. The one that caused harm is marked.
KNOWN = {
    ("04_AQP-BOOT.pact", "KBN"),        # <-- THE 2026-10-02 INCIDENT. Hardcoded URLs in the
                                        # callee body; AQP-BOOT must be redeployed after any
                                        # KBN change or Step 1 writes the previous artwork.
    ("04_AQP-BOOT.pact", "AQP-ANK"), ("04_AQP-BOOT.pact", "AQP-FVT"),
    ("04_AQP-BOOT.pact", "AQP-POOL"), ("04_AQP-BOOT.pact", "DPDC"),
    ("04_AQP-BOOT.pact", "TS02-C3"),
    ("01_DALOS.pact", "TS01-C1"),
    ("04_RPS.pact", "AQP-ANK"), ("04_RPS.pact", "AQP-POOL"), ("04_RPS.pact", "AQP-SCORE"),
    ("04_RPS.pact", "DPDC-T"), ("04_RPS.pact", "DPOF"), ("04_RPS.pact", "TFT"),
    ("05_FVT.pact", "RPS"),
    ("06_VCT.pact", "AQP-ANK"), ("06_VCT.pact", "AQP-POOL"), ("06_VCT.pact", "DPDC-T"),
    ("06_VCT.pact", "DPOF"), ("06_VCT.pact", "RPS"), ("06_VCT.pact", "TFT"),
    ("07_MTX-AQP.pact", "RPS"), ("08_DSA.pact", "RPS"),
    ("09_AQP-INFO.pact", "AQP-DSA"), ("09_AQP-INFO.pact", "AQP-FVT"),
    ("09_AQP-INFO.pact", "AQP-POOL"), ("09_AQP-INFO.pact", "AQP-SCORE"),
    ("09_AQP-INFO.pact", "AQP-VCT"), ("09_AQP-INFO.pact", "DPDC"),
    ("09_AQP-INFO.pact", "RPS"), ("09_AQP-INFO.pact", "TS02-C3"),
    ("01_AOZ+.pact", "ATS"),
    ("01_BSD-L.pact", "DPDC"), ("02_BSD-E.pact", "DPDC"), ("03_BSD-R.pact", "DPDC"),
    ("04_BSD-C.pact", "DPDC"), ("01_NOSFERATU.pact", "DPDC"), ("02_KBunnies.pact", "DPDC"),
    ("03_CADUCEUS.pact", "DPTF"), ("01_Spark.pact", "DPTF"), ("05_STOAICO.pact", "DPTF"),
    ("99_TS02-CPAD.pact", "STOAICO"), ("04_O-UI-FOUR.pact", "STOAICO"),
}


def _files():
    for top in TOPS:
        for d, _, fs in os.walk(os.path.join(ROOT, top)):
            if os.sep + "Audit" in d + os.sep:
                continue
            for f in sorted(fs):
                if f.endswith(".pact"):
                    yield os.path.join(d, f)


def scan():
    """Every (caller-file, callee, line, fn) where a DOT reaches another module."""
    mods = set()
    for p in _files():
        mods |= set(re.findall(r'^\(module\s+([^\s()]+)', open(p, encoding="utf8",
                                                               errors="ignore").read(), re.M))
    alt = "|".join(re.escape(m) for m in sorted(mods, key=len, reverse=True))
    pat = re.compile(r'\((' + alt + r')\.([A-Za-z][\w|>-]*)')
    out = []
    for p in _files():
        raw = open(p, encoding="utf8", errors="ignore").read()
        own = set(re.findall(r'^\(module\s+([^\s()]+)', raw, re.M))
        for i, ln in enumerate(raw.split("\n"), 1):
            # `;;` comments only -- a dot inside a string literal is rare enough here that
            # stripping them too would cost more precision than it buys.
            for callee, fn in pat.findall(ln.split(";;")[0]):
                if callee not in own:
                    out.append((os.path.relpath(p, ROOT), callee, i, fn))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--upgrade", metavar="MODULE",
                    help="who must be redeployed if MODULE ships")
    ap.add_argument("--check", action="store_true",
                    help="gate mode: fail on a dot edge not in KNOWN")
    a = ap.parse_args()
    edges = scan()

    if a.upgrade:
        hit = sorted({f for f, c, _, _ in edges if c == a.upgrade})
        if not hit:
            print(f"{a.upgrade}: no module dot-calls it -- upgrading it refreshes every caller.")
            return 0
        print(f"UPGRADING {a.upgrade} PINS STALE CODE INTO {len(hit)} MODULE(S).")
        print("Redeploy these AFTER it, or they keep calling the version they were built on:\n")
        for f in hit:
            n = sum(1 for g, c, _, _ in edges if g == f and c == a.upgrade)
            print(f"   {f}   ({n} call site(s))")
        return 0

    pairs = {(os.path.basename(f), c) for f, c, _, _ in edges}
    if a.check:
        new = sorted(pairs - KNOWN)
        if new:
            print(f"!! {len(new)} UNREGISTERED cross-module DOT call(s):")
            for f, c in new:
                print(f"   {f} -> {c}")
            print("\nA dot call PINS the callee's code at this module's deploy time. Either use a\n"
                  "modref (`ref-X::fn`), or add the pair to KNOWN in _dotpin.py with a reason and\n"
                  "make sure the deploy order redeploys this module after that one.")
            return 1
        gone = sorted(KNOWN - pairs)
        if gone:
            print(f"!! {len(gone)} registered dot edge(s) NO LONGER EXIST -- delete them:")
            for f, c in gone:
                print(f"   {f} -> {c}")
            return 1
        print(f"dot-pin: clean -- {len(edges)} dot call site(s) across {len(pairs)} "
              f"registered (caller, callee) pair(s)")
        return 0

    by = {}
    for f, c, ln, fn in edges:
        by.setdefault(c, []).append((f, ln, fn))
    print(f"{len(edges)} cross-module DOT call site(s); {len(by)} callee(s).")
    print("Upgrading a callee leaves every caller below on the OLD code until redeployed.\n")
    for c in sorted(by, key=lambda k: -len(by[k])):
        fs = sorted({f for f, _, _ in by[c]})
        print(f"  {c:<12} {len(by[c]):>3} site(s) in {len(fs)} file(s): {', '.join(os.path.basename(x) for x in fs)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

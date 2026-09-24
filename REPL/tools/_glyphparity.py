#!/usr/bin/env python3
"""Every non-ASCII literal the retired read layer emitted must survive in its replacement.

WHY THIS EXISTS.  Porting DPL-UR's reads into `AppReads/` flattened a user-facing string to
ASCII on four separate occasions:

    ¢   -> c        every price on the header and the dashboard
    ×   -> x        the DEB multiplier on the Elite Account page
    ≥   -> >=       two dispo-lock explanations, same page
    Ξ₳  -> Xi-A     the ELITE-AURYN SYMBOL, twice, in the header

All four render.  None looks wrong in isolation.  Two reached mainnet.  No test could catch
them, because a test written from the port agrees with the port -- they were found only by
calling the old function and the new one on chain and diffing the objects key by key.

The character IS the wire format: `Ξ₳` is a brand mark, and "Total Xi-A" is the wrong words on
the screen.

WHY THE REFERENCE IS A CONSTANT AND NOT A FILE.  It was a file -- this tool read the literals
straight out of `01_DPL-UR.pact`.  Then DPL-UR went into archive mode, those reads were deleted,
and the tool went VACUOUS: zero literals in the reference, nothing to check, still printing
"clean".  A check that passes because it has nothing left to look at is worse than no check,
since it keeps reporting success.  So REFERENCE below is the list as it stood on 2026-09-25,
immediately before the stub, recovered from that file's last pre-archive revision -- and an
EMPTY reference is now a hard error rather than a pass.

  python3 REPL/tools/_glyphparity.py          report (fatal inside _gate.py)
"""
import glob
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
APPREADS = os.path.join(ROOT, "2_CITIZEN", "Stage_Z", "AppReads")

# Emitted by DPL-UR as of 2026-09-25, the day before archive mode removed the reads that
# produced them. Add to this list when a new glyph enters a user-facing string; never trim it
# to make the tool pass.
REFERENCE = [
    "<0.001¢",
    "¢",
    "DEB ×{} on AQP scores when deb-boost is enabled",
    "Native Elite-Auryn is dispo-locked until OURO balance returns to ≥ 0",
    "Total Ξ₳",
    "{}% of native Elite-Auryn OURO-value may be overspent (requires Major Tier ≥ 3)",
    "Ξ₳ for Next Tier",
]

RETIRED = {
    "¢": "DPL-UR bound the cent sign to a variable and interpolated it as `{}{}`; the AppReads "
         "formatters inline it instead, so the glyph ships inside '<0.001¢' and '{}¢' -- both "
         "of which ARE present. The bare one-character literal has no counterpart by design.",
}


def literals(path):
    """Every string literal that can reach a caller -- @doc prose stripped, it is commentary."""
    text = io.open(path, encoding="utf8").read()
    text = re.sub(r'@doc\s*"(?:[^"\\]|\\.)*"', "", text, flags=re.S)
    return set(re.findall(r'"((?:[^"\\]|\\.)*)"', text))


def main():
    if not REFERENCE:
        print("glyph parity: REFERENCE is empty -- this check would pass without looking at "
              "anything. Restore the list; see the module docstring.")
        return 1

    modules = sorted(glob.glob(os.path.join(APPREADS, "*", "*.pact")))
    if not modules:
        print(f"glyph parity: no AppReads modules found under {APPREADS}")
        return 1
    carried = set()
    for path in modules:
        carried |= literals(path)

    missing = [l for l in REFERENCE if l not in carried and l not in RETIRED]
    stale = [l for l in RETIRED if l in carried]

    for l in missing:
        print(f"  FLATTENED  {l!r}")
        print( "             the retired read layer emitted this; no AppReads module does. "
               "Either a glyph")
        print( "             was lost in transcription -- restore it -- or the string is "
               "deliberately gone,")
        print( "             in which case add it to RETIRED with the reason.")
    for l in stale:
        print(f"  UN-RETIRE  {l!r} is in RETIRED but now present; drop the registry entry.")

    if missing or stale:
        print(f"glyph parity: {len(missing)} flattened, {len(stale)} stale registry entries")
        return 1
    print(f"glyph parity: clean -- {len(REFERENCE)} reference literal(s), "
          f"{len(REFERENCE) - len(RETIRED)} carried into {len(modules)} AppReads module(s), "
          f"{len(RETIRED)} retired with a reason")
    return 0


if __name__ == "__main__":
    sys.exit(main())

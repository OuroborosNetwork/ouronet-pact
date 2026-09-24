#!/usr/bin/env python3
"""EVERY HARDCODED ENTITY ID IN A DEPLOYABLE SOURCE -- explained, or the tool fails.

WHY THIS EXISTS. Ouronet entity ids carry a BLOCK-HASH SUFFIX: `OURO-8Nh-JO8JO4F5`,
`Auryndex-O136CBn22ncY`, `KBN-98c486052a51`. The suffix is the hash of the transaction that
minted the asset, so an id written as a string literal is correct for exactly ONE issuance and
stale for every one after it.

`DPL-UR.URC_0001_HeaderV3` -- the function the UI dashboard calls for its entire top strip --
carried TWELVE such literals, and `EXPLORER.URC_0001_LandingPage` carried two more. Both were
switched to derived ids on 2026-09-24.

CORRECTED, SAME DAY. The first version of this docstring said a redeploy "re-issued the
primordials, every suffix moved", and blamed these literals for the dashboard outage. THAT WAS
WRONG and it was a guess dressed as a finding. The round deployed in UPGRADE mode -- zero
`create-table` across all 24 emitted files -- so every table persisted and every id on chain is
unchanged. `OURO-8Nh-JO8JO4F5` is still OURO. The outage had a different cause entirely: the
live DPL-UR was the pre-sweep module and bound `module{OuronetDalosV1}` / `{AutostakeV2}` /
`{SwapperV3}`, interfaces those modules no longer implement, so every modref failed to bind.

The literals are STILL a defect worth a gate check -- they are a latent trap that fires the day
anything IS re-issued, and the untestability below is real and unconditional. But this tool
exists because of what they PREVENT (a test), not because of an outage they caused.

THE PART THAT MADE IT INVISIBLE. A hardcoded MAINNET id does not exist in the REPL fixture, so
a function containing one ABORTS on its first read and can never be asserted against. Neither
function had ever executed in a test. The bug was not that a test failed to catch it -- it was
that the literal made the function untestable BY CONSTRUCTION, and an untestable function's
staleness is invisible until a user hits it.

Both modules already derived their ids correctly elsewhere; EXPLORER did it on the four lines
immediately above the two literals. So this is not a hard problem, it is an easily-missed one,
which is exactly the kind a static check is for.

WHAT COUNTS AS A HIT. A string literal shaped `<name>-<12 chars>` whose suffix mixes upper and
lower case. Real base62 block-hash suffixes do; a hyphenated English identifier such as
`negative-counterparts` or `failed-transactions` does not, which is what keeps this quiet.

FATAL ONLY ON AN UNREGISTERED SITE, in the shape of `_patronslots.py`. Some ids genuinely
cannot be derived -- a citizen token with no sovereign reader is a real constant, not a
mistake. Those belong in REGISTRY with the reason. A site that is NOT in REGISTRY fails.

    python3 REPL/tools/_hardcodedids.py         report + fail on an unregistered literal
    python3 REPL/tools/_hardcodedids.py --all   include 0_Sample (documentation, never deployed)
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Directories that never reach chain. `0_Sample` is documentation whose whole job is to SHOW a
# realistic id; `Deploy` is generated FROM the sources this tool already scans, so flagging it
# would double-report every finding against a file nobody edits.
SKIP_DIRS = {".git", "Deploy", "REPL", "Audit", "node_modules", "0_Sample",
             "00_KadenaSandbox", "00_StoaSandbox", "0_Stoa"}

# ACCEPTED HARDCODED IDS. Key: "<repo-relative path>:<literal>". Value: why it cannot be derived.
# Adding an entry is a deliberate act -- it asserts that no reader exists, not that deriving it
# was inconvenient.
REGISTRY = {
    "2_CITIZEN/Stage_Z/03_DSP+.pact:STOICISM-hCNmIIxczuBs":
        "UNRESOLVED, 2026-09-24. STOICISM is a CITIZEN-issued token with no sovereign reader "
        "(no DALOS::UR_*ID, and it is not the reward/RBT side of any ATS pair), so unlike the "
        "fourteen ids fixed the same day this one has nothing to derive from. It sits inside "
        "A_StoicismMinter, whose HAPPY PATH HAS NEVER RUN IN A TEST -- STAGEZ-21 drives only "
        "the two length-mismatch refusals, which abort in the defcap before this `let` is "
        "reached. So the tree cannot tell whether the id is still live. Settle it with a dirty "
        "read against chain; if it is stale, DSP+ is transaction 24 and must be redeployed.",
}

LITERAL = re.compile(r'"([A-Za-z|][A-Za-z0-9|]*-([A-Za-z0-9]{12}))"')


def looks_like_block_hash(suffix):
    """Base62 block-hash suffixes mix case; a hyphenated English word does not."""
    return any(c.isupper() for c in suffix) and any(c.islower() for c in suffix)


def scan(include_samples=False):
    skip = SKIP_DIRS - ({"0_Sample"} if include_samples else set())
    found = []
    for root, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in skip]
        for f in sorted(files):
            if not f.endswith(".pact"):
                continue
            path = os.path.join(root, f)
            rel = os.path.relpath(path, ROOT)
            for n, line in enumerate(open(path, encoding="utf8", errors="replace"), 1):
                if line.lstrip().startswith(";;"):
                    continue
                for m in LITERAL.finditer(line):
                    if looks_like_block_hash(m.group(2)):
                        found.append((rel, n, m.group(1)))
    return found


def main():
    found = scan("--all" in sys.argv)
    known, unknown = [], []
    for rel, n, lit in found:
        (known if f"{rel}:{lit}" in REGISTRY else unknown).append((rel, n, lit))

    if known:
        print(f"registered hardcoded ids ({len(known)}) -- accepted, with a reason:")
        for rel, n, lit in known:
            print(f"  {rel}:{n}  {lit}")
            print(f"      -- {REGISTRY[f'{rel}:{lit}']}")
    if not unknown:
        print(f"\nhardcoded ids: clean -- {len(known)} registered, 0 unregistered.")
        return 0

    print(f"\n!! {len(unknown)} UNREGISTERED hardcoded entity id(s):")
    for rel, n, lit in unknown:
        print(f"     {rel}:{n}  {lit}")
    print("\n!! An id's suffix is the block hash of the transaction that minted it. Written as a")
    print("!! literal it is correct for one issuance and stale for every one after -- and it")
    print("!! makes its own function UNTESTABLE, because a mainnet id does not exist in the")
    print("!! fixture. DERIVE it (DALOS::UR_*ID, DPTF::UR_RewardBearingToken, ...). If nothing")
    print("!! can derive it, add it to REGISTRY with the reason -- not because deriving it was")
    print("!! awkward, but because no reader exists.")
    return 1


if __name__ == "__main__":
    sys.exit(main())

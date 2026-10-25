#!/usr/bin/env python3
"""_ifacecascade.py -- close the SECOND-ORDER gap `_ifacebump.py`'s sweep left behind.

WHY THIS EXISTS. The 2026-10-12 interface-membership sweep bumped 38 interfaces (new functions
declared) and rewrote every `module{OLD}` / `object{OLD.Schema}` CONSUMER tree-wide to the new
name -- including consumers that are THEMSELVES interfaces, not just modules. CLAUDE.md's cascade
rule says exactly this must trigger a further bump ("when interface B -> B', every interface A
that names B ... must bump to A' with the new reference") but `_ifacebump.py`'s sweep only
renamed the TEXT inside those other interfaces -- it did not bump THEIR version, because they had
no missing-function gap of their own; `_ifacemembership.py` never flagged them, since membership
completeness and reference freshness are different questions.

The result: a wallet simulation of the rebuilt `Deploy/PureV10` round found interfaces like
`OuronetInfoV2` whose declared signature now reads `object{IgnisCollectorV4.OutputCumulator}` --
needed for the TREE to keep compiling once IgnisCollectorV3 stopped existing anywhere -- while
the LIVE, deployed `OuronetInfoV2` still correctly reads `IgnisCollectorV3`. Same name, drifted
content: exactly the state Pact's immutable-interface rule forbids. "Module ouronet-ns.IGNIS does
not correctly implement the function OI|UC_IfpFromOutputCumulator from the interface" is what
that looks like on-chain. `_deploybundle.py --write` already pins 37 OTHER already-live
interfaces (`LIVE_INTERFACES`, "unchanged, so strip and skip") -- these are NOT unchanged, and
could not safely be added there.

WALKED TO A FIXED POINT, not assumed to be one wave: bumping these 21 can itself drift a THIRD
interface that names one of THEM (found 2 -- `InfoTwoV2`, `SparksV2` -- confirming `InfoTwoV2`
specifically was correctly left unresolved by the live-interface pass rather than guessed).

USAGE
    python3 REPL/tools/_ifacecascade.py --list     show the targets and their referenced names
    python3 REPL/tools/_ifacecascade.py --write     apply all of them in one pass
"""
import importlib.util
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

_spec = importlib.util.spec_from_file_location("ib", os.path.join(HERE, "_ifacebump.py"))
ib = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(ib)

# The 38 originally-bumped names -- the seed wave. Any OTHER interface whose own body names one
# of these (or a later wave) via `object{}`/`module{}` has drifted and needs its own bump.
SEED_38 = {
    "UtilitySwpV3", "OuronetDalosV3", "IgnisCollectorV4", "BrandingV3",
    "DemiourgosPactOrtoFungibleV3", "AutostakeComputerV3", "AutostakeV4",
    "AutostakeUsageV3", "VestingV3", "StoaLiquidStakingV3", "SwapTracerV4",
    "SwapperV5", "SwapperIssueV5", "SwapperUsageV4", "SwapperMtxV5", "CodexV3",
    "PythiaLedgerV4", "PythiaV6", "InfoOneV3", "DpdcV3", "DpdcCreateV3",
    "DpdcRolesV3", "DpdcManagementV3", "DpdcTransferV3", "DpdcSetsV3", "DpdcNonceV3",
    "DemiourgosLaunchpadV3", "AcquisitionAnchorsV2", "AcquisitionScoresV3",
    "AcquisitionPoolsV2", "AcquisitionRewardPerShareV2",
    "AcquisitionFarmsVaultsTreasuriesV2", "AcquisitionVacateV2", "DsaV2",
    "TalosStageTwo_ClientOneV3", "TalosStageTwo_ClientTwoV3",
    "TalosStageTwo_ClientThreeV3", "TalosStageTwo_DemiPadV3",
}
# CORRECTED 2026-10-12, after `_chaintxsim.py`'s full-round replay caught a real self-collision:
# `EquityV3` was WRONGLY treated as "already a genuinely new interface, no rename needed" --
# based on a one-off misread of `Deploy/LIVE-MODULES.json`, not re-verified against the chain. A
# fresh, direct `describe-module "ouronet-ns.EQUITY"` (hash-matched against the existing cache
# entry, so not a drift -- the ORIGINAL reading was simply wrong) confirms `EquityV3` has been
# live since `Deploy/PureV4` (the "EquityV3 round" `_deploybundle.py` itself already names
# elsewhere). So `EquityV3` is NOT seeded -- it is left to be DISCOVERED by the cascade walk
# like everything else, because its own body references `IgnisCollectorV4` (the tree-wide
# consumer-sweep touched it exactly like the other 21), which means ITS declared content has
# drifted from what's live, exactly like `OuronetInfoV2` did. It needs a REAL bump
# (`EquityV3` -> `EquityV4`), not a straight re-ship under its already-live name.


def source_files():
    import glob
    return (glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True)
            + glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True))


def find_drifted(seed):
    """-> {name: (path, text, block)} for every interface NOT in `seed` whose own body
    references a member of `seed` via object{}/module{}, walked to a fixed point."""
    files = source_files()
    cache = {f: ib.read(f) for f in files}
    all_ifaces = {}
    for f, text in cache.items():
        for m in re.finditer(r'^\(interface\s+([A-Za-z0-9_]+)', text, re.M):
            end = ib.find_matching_paren(text, m.start())
            all_ifaces[m.group(1)] = (f, text, text[m.start():end + 1])

    known = set(seed)
    wave = set(seed)
    drifted = {}
    while wave:
        nxt = set()
        for name, (f, text, block) in all_ifaces.items():
            if name in known:
                continue
            for target in wave:
                if re.search(rf'\b(object|module)\{{{re.escape(target)}[.\}}]', block):
                    nxt.add(name)
                    drifted[name] = (f, text, block)
                    break
        known |= nxt
        wave = nxt
    return drifted


def plan():
    drifted = find_drifted(SEED_38)
    # EquityV3 is seeded (no rename needed) -- never appears in `drifted` since it's excluded
    # from the walk target set by construction (`name in known` check above).
    renames = {}
    for name, (f, text, block) in drifted.items():
        renames[name] = ib.bumped_name(name)
    return drifted, renames


def apply(drifted, renames):
    # Group by file: a file may host more than one drifted interface (e.g. DPTF hosts both
    # BrandingUsagePrimaryV2 and DemiourgosPactTrueFungibleV2).
    by_file = {}
    for name, (f, _, _) in drifted.items():
        by_file.setdefault(f, []).append(name)

    for f, names in by_file.items():
        text = ib.read(f)
        for old in names:
            new = renames[old]
            text, n = re.subn(rf'^\(interface\s+{re.escape(old)}\b', f'(interface {new}', text,
                               count=1, flags=re.M)
            if n != 1:
                raise SystemExit(f"{f}: expected exactly 1 interface header for {old}, got {n}")
        ib.write(f, text)

    # Tree-wide consumer sweep -- `(implements OLD)`, `module{OLD}`, bare/qualified
    # `{OLD.Schema}` (deftable row-type form included, not just `object{}`) -- same patterns
    # `_ifacebump.py` uses, run here for the SAME reason: a schema name can carry `|`/`-`, and
    # the structural `(implements ...)` text can also appear inside an unrelated @doc string
    # earlier in the same file, so a replace-all (not count=1) is required for correctness.
    import glob
    files = (glob.glob(os.path.join(ROOT, "1_SOVEREIGN", "**", "*.pact"), recursive=True)
             + glob.glob(os.path.join(ROOT, "2_CITIZEN", "**", "*.pact"), recursive=True)
             + glob.glob(os.path.join(ROOT, "REPL", "**", "*.repl"), recursive=True))
    touched = []
    for f in files:
        t = ib.read(f)
        t2 = t
        for old, new in renames.items():
            t2 = re.sub(rf'\(implements\s+{re.escape(old)}\)', f'(implements {new})', t2)
            t2 = re.sub(rf'\bmodule\{{{re.escape(old)}\}}', f'module{{{new}}}', t2)
            t2 = re.sub(rf'\{{{re.escape(old)}\.([A-Za-z0-9_|-]+)\}}', rf'{{{new}.\1}}', t2)
        if t2 != t:
            ib.write(f, t2)
            touched.append(os.path.relpath(f, ROOT))
    return touched


def main():
    drifted, renames = plan()
    print(f"{len(renames)} interface(s) drifted by the original sweep's consumer rewrite, "
          f"need their own bump:\n")
    for old, new in sorted(renames.items()):
        f = drifted[old][0]
        print(f"  {old:32s} -> {new:32s} {os.path.relpath(f, ROOT)}")

    if "--write" not in sys.argv:
        print("\n(preview only -- pass --write to apply)")
        return 0

    touched = apply(drifted, renames)
    print(f"\nwrote {len(by_file_count(drifted))} file(s) with renamed headers, "
          f"swept {len(touched)} consumer file(s) tree-wide.")
    return 0


def by_file_count(drifted):
    return {v[0] for v in drifted.values()}


if __name__ == "__main__":
    sys.exit(main())

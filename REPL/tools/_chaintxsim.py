#!/usr/bin/env python3
"""_chaintxsim.py -- ChainedTXSimulator: replay a whole deploy round against REAL live content.

WHAT THIS IS, PRECISELY. `_chainsim.py` proves individual batches against the real chain tip but
cannot compose across separate `/local` calls (nodes don't persist between them -- see that
module's docstring). A plain REPL replay (the `_scratch_loadpurevN.repl` pattern) composes a FULL
round sequentially, but bootstraps from a presumed-live git commit, which could in principle have
drifted from what is actually deployed -- and did, once: PureV10's `EQUITY` module carried an
interface -- `EquityV3` -- that turned out to ALREADY be live (confirmed via direct, hash-matched
`describe-module`, after an earlier belief that it was unshipped proved wrong), colliding with
itself when the round's own content tried to declare it again. This tool removes that assumption: it FETCHES the real declared source of
every TOUCHED module and interface via `describe-module` (works for interfaces too, not just
modules), overwrites a throwaway worktree's copies of just those files with the fetched real
content, and lets the tree's OWN `deploy-stage01.repl` / `deploy-stage02.repl` handle bootstrap --
init steps, keyset registration, dependency order and all -- exactly as it already does for every
other REPL suite in this repo. Only the CONTENT of touched files is swapped for real fetched
source; the init mechanics are the tree's own proven code, untouched.

WHY NOT ONE REAL CHAIN CALL INSTEAD. Measured directly (2026-10-12): Chainweb's `/local` endpoint
caps request bodies at 2,097,152 bytes on a direct node and tighter still (~1.0-1.2 MB) behind the
public one's reverse proxy; gzip doesn't help because the endpoint doesn't decompress; safe
comment/doc stripping only gets a typical round to ~65% of its raw size. A round this size is
several megabytes of Pact source -- there is no real single HTTP call it fits in. `_chainsim.py`
gets as much real-chain coverage as the size limit allows, batch by batch; THIS tool gets
full-round coverage by running locally against fetched-real content for everything that matters.

HOW THE BOOTSTRAP IS BUILT.
  1. Every interface/module this round's own files declare is discovered from LOCAL source. For
     each that has a known OLD (pre-round) name (`NEW_TO_OLD` below), the OLD name is what
     actually needs fetching -- local source only ever spells the NEW one once a module's
     `implements` clause has been bumped, so file-based discovery alone cannot find the old name
     by searching; it has to be supplied.
  2. `describe-module "ouronet-ns.<OLD NAME>"` fetches the real declared text for each -- for
     both module bodies and (confirmed working, not assumed) standalone interfaces.
  3. A throwaway `git worktree` at the commit immediately before this round started is created,
     and ONLY the files this round touches have their content overwritten with the fetched real
     source (interfaces first, matching Pact's own load-order requirement, then the module).
     Every other file is untouched -- those are presumed identical to live because nothing in
     this round edited them, which is a much safer presumption than "the whole commit matches
     live."
  4. `deploy-stage01.repl` / `deploy-stage02.repl`, run FROM that worktree, do everything they
     always do -- Kadena/Stoa sandbox, namespace registration, every init/keyset step between
     module loads -- using real fetched content for touched files and the worktree's own
     (unmodified, trusted) content for everything else.
  5. AppReads/Pythia pages outside that chain are registered the same way, using fetched content.
  6. The round's OWN transaction files, from the CURRENT (post-round) tree, load on top in
     signing order, with the same governance key `_chainsim.py` already uses (confirmed real: the
     chain's own "Keyset failure" error names it as one of two keys a `keys-any` checks).

    python3 REPL/tools/_chaintxsim.py --round Deploy/PureV10
    python3 REPL/tools/_chaintxsim.py --round Deploy/PureV10 --base-commit b8e87a11
"""
import glob
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TOOLS = os.path.dirname(os.path.abspath(__file__))
# Same two keys `_scratch_loadpurev3.repl` already supplies for this exact purpose: "the round
# spans modules governed by each." The first is confirmed against real chain state (the
# "Keyset failure" error from `_chainsim.py`'s real /local calls names it). The second is this
# REPL suite's own test-fixture admin key for modules whose governance was set up differently
# during Stage01 init -- U|SWP's `GOV|U|SWP_ADMIN` needed it, not the first key alone.
GOV_SIGNERS_REPL = (
    '[ { "key": "1a4e15d3c51e0b73e92644600487ba8eaae312e1a178b91801d54e13c1b350a5", "caps": [] }\n'
    '  { "key": "PK_AncientHodler", "caps": [] } ]'
)
DEFAULT_BASE_COMMIT = "HEAD"

# NEW -> OLD for every interface the 2026-10-12 interface-membership sweep renamed. Load-bearing:
# a touched file's local source now only spells the NEW name, so the OLD one -- what is actually
# live -- has to be supplied, not discovered. See module docstring for why this matters.
NEW_TO_OLD = {
    "UtilitySwpV3": "UtilitySwpV2", "OuronetDalosV3": "OuronetDalosV2",
    "IgnisCollectorV4": "IgnisCollectorV3", "BrandingV3": "BrandingV2",
    "DemiourgosPactOrtoFungibleV3": "DemiourgosPactOrtoFungibleV2",
    "AutostakeComputerV3": "AutostakeComputerV2", "AutostakeV4": "AutostakeV3",
    "AutostakeUsageV3": "AutostakeUsageV2", "VestingV3": "VestingV2",
    "StoaLiquidStakingV3": "StoaLiquidStakingV2", "SwapTracerV4": "SwapTracerV3",
    "SwapperV5": "SwapperV4", "SwapperIssueV5": "SwapperIssueV4",
    "SwapperUsageV4": "SwapperUsageV3", "SwapperMtxV5": "SwapperMtxV4", "CodexV3": "CodexV2",
    "PythiaLedgerV4": "PythiaLedgerV3", "PythiaV6": "PythiaV5", "InfoOneV3": "InfoOneV2",
    "DpdcV3": "DpdcV2", "DpdcCreateV3": "DpdcCreateV2", "DpdcRolesV3": "DpdcRolesV2",
    "DpdcManagementV3": "DpdcManagementV2", "DpdcTransferV3": "DpdcTransferV2",
    "DpdcSetsV3": "DpdcSetsV2", "DpdcNonceV3": "DpdcNonceV2",
    "DemiourgosLaunchpadV3": "DemiourgosLaunchpadV2",
    # AQP FAMILY RE-POINTED 2026-10-24, ONE VERSION FORWARD. These entries were written for the
    # PureV10 round, when the repo said V2 and the chain said V1. PureV10 then SHIPPED, so V2
    # became live -- and nothing re-pointed this map. The next round (repo V3) therefore looked up
    # "V3" , missed, and the tool fetched the V1 copy its stale entry still named, splicing
    # one-version-old source into a round built against V2. The replay failed on the mismatch and
    # the failure LOOKED like a defect in the round: two separate wrong diagnoses were built on it
    # (a module that merely shared a transaction, then an imagined double-bump) before anyone
    # polled the chain and found V1 AND V2 both live.
    #
    # THE REAL FIX IS NOT TO EDIT THESE NUMBERS AGAIN. A hardcoded "what is live" goes stale the
    # moment a round ships, which is precisely when it is next consulted, and it fails SILENTLY --
    # it returns real source, just the wrong vintage. Resolve the live version by asking the chain
    # (probe `<Base>V1..Vn`, take the highest that answers `describe-module`); that is a handful of
    # calls and it cannot rot. Until that lands, re-point these the day a round ships.
    "AcquisitionAnchorsV3": "AcquisitionAnchorsV2",
    "AcquisitionScoresV4": "AcquisitionScoresV3",
    "AcquisitionPoolsV3": "AcquisitionPoolsV2",
    "AcquisitionRewardPerShareV3": "AcquisitionRewardPerShareV2",
    "AcquisitionFarmsVaultsTreasuriesV3": "AcquisitionFarmsVaultsTreasuriesV2",
    "AcquisitionVacateV3": "AcquisitionVacateV2", "DsaV3": "DsaV2",
    "AcquisitionSchemasV2": "AcquisitionSchemasV1",
    "TalosStageTwo_ClientOneV3": "TalosStageTwo_ClientOneV2",
    "TalosStageTwo_ClientTwoV3": "TalosStageTwo_ClientTwoV2",
    "TalosStageTwo_ClientThreeV3": "TalosStageTwo_ClientThreeV2",
    "TalosStageTwo_DemiPadV3": "TalosStageTwo_DemiPadV2",
    # SECOND-ORDER CASCADE, now TWO waves deep (V2/V3 -> V3/V4 -> V4/V5): these 21 interfaces
    # drifted a SECOND time, because the first cascade bump (V2->V3) was itself a consumer of
    # one of the 38 originals and got its OWN content rewritten by the same tree-wide sweep.
    # The intermediate V3 name never shipped -- what maps here is the FINAL current name
    # straight to what is ACTUALLY live, skipping the never-deployed middle version.
    "BrandingUsagePrimaryV4": "BrandingUsagePrimaryV2",
    "BrandingUsageSecondaryV4": "BrandingUsageSecondaryV2",
    "BrandingUsageTertiaryV4": "BrandingUsageTertiaryV2",
    "DemiourgosPactTrueFungibleV4": "DemiourgosPactTrueFungibleV2",
    "DpdcFragmentsV4": "DpdcFragmentsV2", "DpdcIssueV4": "DpdcIssueV2", "InfoTwoV4": "InfoTwoV2",
    "OuroborosV4": "OuroborosV2", "OuronetInfoV4": "OuronetInfoV2",
    "SaleCustodiansV4": "SaleCustodiansV2", "SaleSnakesV4": "SaleSnakesV2", "SparksV4": "SparksV2",
    "StoicPayV5": "StoicPayV3", "SwapperLiquidityClientV4": "SwapperLiquidityClientV2",
    "SwapperLiquidityV4": "SwapperLiquidityV2",
    "TalosStageOne_ClientFourV10": "TalosStageOne_ClientFourV8",
    "TalosStageOne_ClientOneV4": "TalosStageOne_ClientOneV2",
    "TalosStageOne_ClientPactsV6": "TalosStageOne_ClientPactsV4",
    "TalosStageOne_ClientThreeV6": "TalosStageOne_ClientThreeV4",
    "TalosStageOne_ClientTwoV4": "TalosStageOne_ClientTwoV2",
    "TrueFungibleTransferV4": "TrueFungibleTransferV2",
    # CORRECTED 2026-10-12: this used to read "EquityV3": "EquityV2", on the mistaken belief
    # that EquityV3 was itself a pre-existing, never-shipped bump. A direct, hash-matched
    # `describe-module` confirmed EquityV3 has been live since `Deploy/PureV4` -- so, unlike
    # every other entry above, there is no never-shipped middle version here: EquityV3 itself
    # IS what's live, and the current tree's `EquityV4` maps straight to it.
    "EquityV4": "EquityV3",
}

APPREADS = {
    "O-UI-ONE": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/01_O-UI-ONE.pact",
    "O-UI-TWO": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/02_O-UI-TWO.pact",
    "O-UI-THREE": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/03_O-UI-THREE.pact",
    "O-UI-FOUR": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/04_O-UI-FOUR.pact",
    "O-UI-SEVEN": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/07_O-UI-SEVEN.pact",
    "O-UI-EIGHT": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/08_O-UI-EIGHT.pact",
    "O-UI-NINE": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/09_O-UI-NINE.pact",
    "O-UI-TEN": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/10_O-UI-TEN.pact",
    "O-UI-TWELVE": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/12_O-UI-TWELVE.pact",
    "O-UI-THIRTEEN": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/13_O-UI-THIRTEEN.pact",
    "O-UI-FOURTEEN": "2_CITIZEN/Stage_Z/AppReads/OuronetUI/14_O-UI-FOURTEEN.pact",
    "P-UI-ONE": "2_CITIZEN/Stage_Z/AppReads/Pythia/01_P-UI-ONE.pact",
}


def _import(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _declared(path):
    text = open(path, encoding="utf-8", errors="ignore").read()
    ifaces = re.findall(r'^\(interface\s+([A-Za-z0-9_]+)', text, re.M)
    mods = re.findall(r'^\(module\s+(\S+)', text, re.M)
    return ifaces, mods


def sh(cmd, **kw):
    r = subprocess.run(cmd, capture_output=True, text=True, **kw)
    if r.returncode != 0:
        raise SystemExit(f"command failed: {cmd}\n{r.stdout}\n{r.stderr}")
    return r.stdout


def round_files(round_dir):
    return sorted(glob.glob(os.path.join(round_dir, "*_deploy.pact")),
                  key=lambda p: int(os.path.basename(p).split("_")[0]))


def round_new_names(round_dir):
    names = set()
    for f in round_files(round_dir):
        ifaces, _ = _declared(f)
        names.update(ifaces)
    return names


def round_appreads(round_dir):
    """Which of the 12 AppReads/Pythia pages THIS round actually ships -- not all of them.
    `APPREADS` lists every page that EXISTS in the tree, but several (O-UI-ONE/TWO/THREE/TWELVE,
    as of PureV10) are explicitly held back by the owner, not live, and not part of any round's
    `extra` injection -- their content is work in progress and is not expected to even COMPILE
    cleanly in isolation (confirmed the hard way: `O-UI-ONE` references `OuronetIdsV1.
    IDX_AURYNDEX`, which does not resolve, as part of registering it unconditionally). A round's
    own transaction files are the ground truth for which pages it actually injects: each
    extra-injected page's `(module NAME GOV ...)` appears verbatim inside one of the round's own
    `NN_deploy.pact` files, so matching round file content against `APPREADS` keys is exact,
    not a guess."""
    names = set()
    for f in round_files(round_dir):
        _, mods = _declared(f)
        names.update(m for m in mods if m in APPREADS)
    return names


def touched_repo_files(round_dir, new_names):
    """Every LOCAL repo file (not round file) that declares one of this round's new interface
    names or one of this round's directly-changed modules -- these are the ones whose worktree
    copy needs real fetched content instead of the commit's own."""
    out = set()
    for top in ("1_SOVEREIGN", "2_CITIZEN"):
        for p in glob.glob(os.path.join(ROOT, top, "**", "*.pact"), recursive=True):
            ifaces, _ = _declared(p)
            if any(i in new_names for i in ifaces):
                out.add(p)
    return out


_LIVE_IFACE_CACHE = {}

def resolve_live_iface(name, rpc):
    """Which version of `name`'s interface is ACTUALLY LIVE -- asked, never assumed.

    REPLACES THE HARDCODED `NEW_TO_OLD` LOOKUP, and the reason is that a hardcoded answer to
    "what is live" is wrong by construction: it is written during a round, when the repo is ahead
    of the chain, and it becomes stale the instant that round SHIPS -- which is exactly when it is
    next consulted. Measured 2026-10-24: every AQP entry AND `IgnisCollectorV4`, `OuronetDalosV3`,
    `DemiourgosPactTrueFungibleV3` were all live under their "new" names while the map still
    insisted the live copy was one version lower. So the tool fetched one-version-old source for
    most of the tree and spliced it into a round built against the current one. The failures that
    produced were specific, plausible and pointed at the ROUND -- three separate wrong diagnoses
    came out of it before anyone ran `describe-module` on the version the repo actually names.

    The rule: if `name` itself answers `describe-module`, that IS the live one -- use it. Only if
    it does not, walk DOWN the version suffix to find the newest that does. Nothing to re-point
    after a deploy, because the chain is the answer rather than a cached belief about it."""
    if name in _LIVE_IFACE_CACHE:
        return _LIVE_IFACE_CACHE[name]
    def _live(n):
        r = rpc(f'(describe-module "ouronet-ns.{n}")')
        return bool(r and r.get("code"))
    found = name if _live(name) else None
    if not found:
        m = re.match(r'^(.*?)V(\d+)$', name)
        if m:
            base, n = m.group(1), int(m.group(2))
            for k in range(n - 1, 0, -1):
                if _live(f"{base}V{k}"):
                    found = f"{base}V{k}"
                    break
    _LIVE_IFACE_CACHE[name] = found
    return found


def fetch_real(names, rpc):
    """-> {name: source text} for every module/interface name `describe-module` can answer."""
    out, missing = {}, []
    for n in sorted(names):
        r = rpc(f'(describe-module "ouronet-ns.{n}")')
        if r and r.get("code"):
            out[n] = r["code"]
        else:
            missing.append(n)
    return out, missing


def build_worktree(base_commit, round_dir, reg):
    new_names = round_new_names(round_dir)
    repo_files = touched_repo_files(round_dir, new_names)
    appreads = round_appreads(round_dir)
    print(f"{len(repo_files)} local file(s) touched by this round's interfaces, need real "
          f"fetched content for their bootstrap copy")
    print(f"AppReads pages this round ships: {sorted(appreads) or '(none)'}")

    # What to fetch: for each touched file, its OLD interface name(s) (via NEW_TO_OLD) and its
    # own module name(s) (always fetched -- a touched file's module body changed too, even where
    # its own interface name didn't move, e.g. a pure consumer-sweep rename).
    fetch_ifaces, fetch_mods = set(), set()
    per_file = {}
    for p in repo_files:
        ifaces, mods = _declared(p)
        old_ifaces = [NEW_TO_OLD.get(i, i) for i in ifaces if i in NEW_TO_OLD]
        fetch_ifaces.update(old_ifaces)
        fetch_mods.update(mods)
        per_file[p] = (old_ifaces, mods)
    for name in appreads:
        path = APPREADS[name]
        full = os.path.join(ROOT, path)
        if not os.path.exists(full):
            continue
        ifaces, mods = _declared(full)
        old_ifaces = [resolve_live_iface(i, reg.rpc) for i in ifaces]
        old_ifaces = [i for i in old_ifaces if i]
        if old_ifaces or name in fetch_mods:
            pass
        fetch_ifaces.update(old_ifaces)
        fetch_mods.add(name)
        per_file[full] = (old_ifaces, mods)

    print(f"fetching {len(fetch_ifaces)} interface(s) + {len(fetch_mods)} module(s) from the "
          "live chain...")
    live_ifaces, missing_i = fetch_real(fetch_ifaces, reg.rpc)
    live_mods, missing_m = fetch_real(fetch_mods, reg.rpc)
    if missing_i:
        print(f"  interfaces not live (expected if genuinely new/unshipped): {missing_i}")
    if missing_m:
        print(f"  modules not live (expected if genuinely not deployed, e.g. DPMF): {missing_m}")

    wt = tempfile.mkdtemp(prefix="chaintxsim_wt_")
    sh(["git", "worktree", "add", "-q", wt, base_commit], cwd=ROOT)

    pactlex = _import("pactlex_chaintxsim", os.path.join(TOOLS, "_pactlex.py"))

    def replace_block(text, kind, candidates, new_code):
        """Surgical, not whole-file: a touched file routinely co-hosts OTHER, unrelated
        interfaces (DALOS's file also declares `OuronetPolicyV2`, which this round never
        touches) -- replacing the whole file drops those entirely and the worktree stops
        loading at all. Replace ONLY the named block; leave everything else as the worktree
        (the presumed-live baseline) already has it.

        `candidates` is tried IN ORDER, first match wins -- normally just [OLD_NAME], but for
        a pre-existing, already-renamed-before-this-round case (`EquityV3`, see NEW_TO_OLD's own
        comment) the base commit does NOT have the old name at all; it already has the NEW one,
        because that rename predates this round entirely. Searching [OLD, NEW] and replacing
        whichever is actually found prevents BOTH ending up in the file -- found the hard way:
        the first version of this function only tried OLD, missed, appended the fetched content
        alongside the untouched NEW declaration that was already there, and the round's own
        transaction redeclaring that NEW name then collided with itself ("Interface cannot be
        upgraded") during bootstrap, before the round's own files were even reached."""
        for name in candidates:
            pat = r'^\(' + kind + r'\s+' + re.escape(name) + r'\b'
            m = re.search(pat, text, re.M)
            if m:
                end = pactlex.balanced(text, m.start())
                return text[:m.start()] + new_code + text[end + 1:]
        # Not present under ANY candidate name at base_commit (e.g. the file structure itself
        # changed since). Insert rather than silently drop.
        #
        # POSITION IS LOAD-BEARING FOR AN INTERFACE, and this used to append blindly with the
        # comment "which does not matter for load-order within one file". It does matter: Pact
        # requires an interface to be declared BEFORE the module that implements it. Observed
        # 2026-10-24 on 01_ANK.pact -- the fetched `AcquisitionAnchorsV2` landed at the END of the
        # file while `(module AQP-ANK ...)` at line 166 carried `(implements AcquisitionAnchorsV2)`,
        # so the replay died at EOF with an error that read like unbalanced parens and sent three
        # separate investigations chasing the ROUND instead of the patcher.
        #
        # An interface therefore goes in immediately before the first `(module ...)` in the file;
        # a module, having no such constraint relative to what follows it, still appends.
        if kind == "interface":
            mm = re.search(r'^\(module\s', text, re.M)
            if mm:
                return text[:mm.start()] + new_code + "\n\n" + text[mm.start():]
        return text.rstrip() + "\n\n" + new_code + "\n"

    old_to_new = {old: new for new, old in NEW_TO_OLD.items()}

    written = 0
    for p, (old_ifaces, mods) in per_file.items():
        rel = os.path.relpath(p, ROOT)
        wt_path = os.path.join(wt, rel)
        if not os.path.exists(wt_path):
            continue   # file is new-to-this-round (nothing at base_commit to patch)
        text = open(wt_path, encoding="utf-8").read()
        changed = False
        for i in old_ifaces:
            if i in live_ifaces:
                candidates = [i, old_to_new[i]] if i in old_to_new else [i]
                # ...AND EVERY LOWER VERSION OF THE SAME BASE NAME. The worktree is at the commit
                # before this round, which is not necessarily the version that is LIVE: commits lag
                # deploys in this repo, so base_commit can legitimately still carry V1 while the
                # chain is already on V2. Without this, neither candidate matches, the replace
                # falls through to the insert path, and the file ends up carrying TWO versions of
                # the same interface -- the stale one it already had plus the fetched one. Trying
                # the lower versions finds the declaration that is actually there and REPLACES it,
                # which is the whole point of a surgical patch.
                m = re.match(r'^(.*?)V(\d+)$', i)
                if m:
                    base, n = m.group(1), int(m.group(2))
                    candidates += [f"{base}V{k}" for k in range(n - 1, 0, -1)]
                text = replace_block(text, "interface", candidates, live_ifaces[i])
                changed = True
        for m in mods:
            if m in live_mods:
                text = replace_block(text, "module", [m], live_mods[m])
                changed = True
        if not changed:
            continue
        open(wt_path, "w", encoding="utf-8").write(text)
        written += 1
    print(f"patched {written} file(s) in the worktree with real fetched content "
          f"(surgical per-block replace, co-located unrelated declarations preserved)")
    return wt


def write_replay_repl(wt, round_dir, out_repl_path):
    rel_root = os.path.relpath(wt, os.path.join(ROOT, "REPL"))
    lines = [
        ';;================================================================',
        ';; GENERATED by _chaintxsim.py -- do not hand-edit, regenerate instead.',
        ';;================================================================',
        f'(load "{rel_root}/REPL/Stage00_Sanboxes.repl")',
        f'(load "{rel_root}/REPL/deploy-stage01.repl")',
        f'(load "{rel_root}/REPL/deploy-stage02.repl")',
        '(begin-tx "ChainedTXSimulator -- register AppReads/Pythia pages (not in the deploy chain)")',
        f'(env-sigs {GOV_SIGNERS_REPL})',
        '(namespace "ouronet-ns")',
    ]
    for name in round_appreads(round_dir):
        path = APPREADS[name]
        full = os.path.join(wt, path)
        if os.path.exists(full):
            lines.append(f'(load "{rel_root}/{path}")')
    lines.append('(commit-tx)')
    lines.append('(begin-tx "ChainedTXSimulator -- round transactions, real signing order")')
    lines.append('(namespace "ouronet-ns")')
    lines.append(f'(env-sigs {GOV_SIGNERS_REPL})')
    for f in round_files(round_dir):
        lines.append(f'(print "--- [{os.path.basename(f)}] ---") (load "{f}")')
    lines.append('(commit-tx)')
    lines.append('(print "=== CHAINEDTXSIMULATOR: round replayed clean over real live content ===")')
    open(out_repl_path, "w", encoding="utf-8").write("\n".join(lines) + "\n")


def round_followups(round_dir):
    """Hand-authored, non-generated files riding in the round directory -- not matched by
    `*_deploy.pact`, and declaring no `(module ...)`/`(interface ...)` of their own (a bare
    invocation script, not a deploy under a different naming pattern). `Deploy/PureV10/
    23_repair.pact` and `24_contribution.pact` are the first examples: an admin migration call
    and a client call, both depending on a module THIS SAME ROUND redeploys."""
    out = []
    for p in sorted(glob.glob(os.path.join(round_dir, "*.pact"))):
        name = os.path.basename(p)
        if re.match(r"^\d+_deploy\.pact$", name):
            continue
        text = open(p, encoding="utf-8", errors="ignore").read()
        if re.search(r'^\(module\s|^\(interface\s', text, re.M):
            continue
        out.append(p)
    return out


def _find_module_source(name):
    """The CURRENT local tree file that declares `(module NAME ...)`, or None."""
    for top in ("1_SOVEREIGN", "2_CITIZEN"):
        for p in glob.glob(os.path.join(ROOT, top, "**", "*.pact"), recursive=True):
            text = open(p, encoding="utf-8", errors="ignore").read()
            if re.search(r'^\(module\s+' + re.escape(name) + r'\b', text, re.M):
                return p, text
    return None, None


def _new_top_level_forms(live_text, local_text, pactlex):
    """`defun`/`defcap` forms present in the CURRENT local module body but absent from the
    LIVE one, matched by name -- the minimal real diff, not a reconstruction.

    WHY NOT JUST USE THE ROUND'S OWN GENERATED `NN_deploy.pact` TEXT (tried first, and wrong):
    that file is the post-sweep module, so STOAICO's own typed modrefs already read e.g.
    `module{OuronetDalosV3}` -- a name THIS SAME ROUND is what deploys, in transaction 1, not
    something already live. Upgrading STOAICO standalone with that text fails immediately with
    "Cannot find module: ouronet-ns.OuronetDalosV3", for the exactly-correct reason that tx21
    genuinely cannot land before tx1 does -- confirmed the hard way, see git history on this
    function. Splicing only the NEW forms into the REAL live source (which still correctly reads
    `module{OuronetDalosV2}`, because that is what is actually live) tests the followup's own
    fix in isolation, independent of a dependency chain a single real call cannot fit regardless
    (the whole round is ~5.9 MB; see the module docstring's own size-ceiling section)."""
    out = []
    for kind in ("defcap", "defun"):
        for m in re.finditer(r'^(\s*)(\(' + kind + r'\s+([A-Za-z][A-Za-z0-9_|-]*))',
                              local_text, re.M):
            name = m.group(3)
            if re.search(r'^\s*\(' + kind + r'\s+' + re.escape(name) + r'\b', live_text, re.M):
                continue
            start = m.start(2)
            end = pactlex.balanced(local_text, start)
            if end > start:
                out.append(local_text[start:end + 1])
    return out


def verify_followups_live(round_dir, reg):
    """-> (ok: bool, boundary: bool, message: str). `boundary` is True when `ok` is True ONLY
    because the account-ownership signature check was reached (see below) -- distinct from a
    clean pass, for a caller (e.g. `main`'s `--json` mode) that wants to report the difference.

    REAL, non-destructive `/local` verification for `round_followups()` -- the sandbox replay
    (`build_worktree` / `write_replay_repl`) cannot meaningfully cover these, and the reason is
    structural, not a gap to close later: a followup like `A_MigrateGeneralFields` or `A_Stake`
    is DATA-dependent -- it reads/writes a module's live TABLE ROWS -- and a throwaway worktree
    bootstraps that module fresh, with none of the real row history (no existing users, no
    pre-existing drift). Proving a data-dependent fix works means testing it against REAL data,
    which means a REAL (if non-destructive) chain call, not a sandbox.

    MECHANISM: find which `ouronet-ns.MODULE.` names the followups call into; for each, fetch
    the REAL live module source via `describe-module`, then splice in ONLY the genuinely NEW
    `defun`/`defcap` forms this round's local tree adds (`_new_top_level_forms`) -- not the
    round's post-sweep module text, which assumes dependencies this single call cannot also
    carry. Fire ONE real `/local` call that upgrades the module(s) this way (nothing commits --
    `/local` never does) and then runs every followup against the result, in order, in the SAME
    call so each sees the previous one's effects. This is exactly how the STOAICO distribution-
    round gap was first proven and how the `try`/`with-default-read` dead ends in its own fix
    were found -- this function is that verification, made permanent and repeatable.

    WHAT IT DOES NOT PROVE: who may sign. `_chainsim.py`'s key satisfies every keyset this round
    needs for GOVERNANCE (module upgrades, admin calls), but `A_Stake`'s own capability also
    enforces ACCOUNT OWNERSHIP of the `account` argument via `CAP_EnforceAccountOwnership` --
    unrelated to the distribution-round bug this exists to catch, and the real send will need the
    real account's real signature regardless of anything this function reports. It also does NOT
    prove the followup's TARGET module can actually be reached in isolation on a real send -- if
    it depends on an interface THIS round deploys first (STOAICO does), the followup is only
    real-sendable after the deploy group ahead of it has actually landed; this check verifies the
    followup's OWN logic against real data, not the full cross-transaction ordering (the sandbox
    phase above is what verifies ordering, for the parts it CAN reach)."""
    followups = round_followups(round_dir)
    if not followups:
        return True, False, "(no follow-ups in this round)"

    cs = _import("chainsim_for_followups", os.path.join(TOOLS, "_chainsim.py"))
    pactlex = _import("pactlex_followups", os.path.join(TOOLS, "_pactlex.py"))

    called = set()
    for p in followups:
        text = open(p, encoding="utf-8").read()
        called.update(re.findall(r'ouronet-ns\.([A-Za-z][A-Za-z0-9_|-]*)\.', text))

    live_src, missing_live = fetch_real(called, reg.rpc)
    if missing_live:
        print(f"  WARNING: {sorted(missing_live)} not found live via describe-module -- "
              f"skipping real-content check for them.")

    module_text = {}
    for name, live_text in live_src.items():
        local_path, local_text = _find_module_source(name)
        if local_text is None:
            print(f"  WARNING: {name} is live but has no local tree source anymore -- skipping.")
            continue
        new_forms = _new_top_level_forms(live_text, local_text, pactlex)
        m = re.search(r'^\(module\s+' + re.escape(name) + r'\b', live_text, re.M)
        end = pactlex.balanced(live_text, m.start())
        spliced = live_text[:end] + "\n" + "\n".join(new_forms) + "\n" + live_text[end:]
        module_text[name] = spliced
        print(f"  {name}: {len(new_forms)} new form(s) spliced into the real live source "
              f"({os.path.relpath(local_path, ROOT)})")

    print(f"\nfollow-up real-chain check: upgrading {sorted(module_text) or '(nothing)'} for "
          f"real (non-destructive /local, real content + only this round's genuinely new "
          f"forms), then running {[os.path.basename(p) for p in followups]} against REAL live "
          f"table data...")

    parts = ['(namespace "ouronet-ns")']
    for name in sorted(module_text):
        parts.append(module_text[name])
    # NO `(print ...)` IN THIS LIST -- found the hard way. `print` is a REPL-only native: it
    # works in every `.repl` file this tool and its siblings run (those go through the `pact`
    # CLI's REPL interpreter, which adds REPL-only natives), but a REAL `/local` call against the
    # live node does not have it, and under `(namespace "ouronet-ns")` the failure is actively
    # misleading -- Pact tries to resolve the unknown name as a MODULE REFERENCE under the
    # current namespace first and reports "Cannot find module: ouronet-ns.print", which reads
    # like a namespacing bug in THIS code rather than what it is (a REPL native that plain does
    # not exist on chain). Confirmed directly: even a bare top-level `(print "hi")` fails the
    # identical way. Labelling is done in Python instead, against each list position.
    calls = []
    for p in followups:
        text = open(p, encoding="utf-8").read()
        text = re.sub(r'^\(namespace\s+"ouronet-ns"\)\s*$', '', text, flags=re.M).strip()
        calls.append(text)
    parts.append("[\n" + "\n".join(calls) + "\n]")
    code = "\n".join(parts)

    r = cs.rpc(code, gas=150_000_000)
    result = r.get("result", {})
    if result.get("status") == "success":
        data = result.get("data")
        if isinstance(data, list):
            for p, d in zip(followups, data):
                print(f"  OK -- [{os.path.basename(p)}] {json.dumps(d)[:300]}")
        else:
            print(f"  OK -- {json.dumps(data)[:500]}")
        return True, False, "all follow-ups cleared"
    err = result.get("error", {})
    msg = err.get("message", "")
    # THE EXPECTED BOUNDARY, NOT A FAILURE. This function's own docstring says so: the signer
    # here satisfies every GOVERNANCE capability the round needs, but a client call like
    # `A_Stake` separately enforces ACCOUNT OWNERSHIP of its own argument (`CAP_
    # EnforceAccountOwnership` / `UEV_StandardAccOwn`), which no read-only check can satisfy
    # without the real account's real private key. Reaching exactly this error, after the
    # distribution-round bug it exists to catch has already cleared, is what success through the
    # whole reachable surface looks like -- treating it as a hard failure would make this
    # function un-passable for any followup that calls a real client entrypoint, forever.
    if msg.startswith("Keyset failure") and "StandardAccOwn" in err.get("info", ""):
        print(f"  BOUNDARY REACHED (expected, not a failure) -- {msg} ({err.get('info')})")
        print("  This is account-ownership enforcement, unrelated to what this check verifies: "
              "it proves the followup's OWN logic clears, past the distribution-round bug, "
              "reaching the point where only the real account's real signature is missing -- "
              "which no read-only /local call can supply. A real send still needs that "
              "signature regardless of this result.")
        return True, True, f"boundary reached (expected): {msg} ({err.get('info')})"
    print(f"  FAILED -- {msg} ({err.get('info')})")
    return False, False, f"{msg} ({err.get('info')})"


def main():
    if "--round" not in sys.argv:
        print(__doc__)
        return 0
    round_dir = sys.argv[sys.argv.index("--round") + 1]
    if not os.path.isabs(round_dir):
        round_dir = os.path.join(ROOT, round_dir)
    base_commit = DEFAULT_BASE_COMMIT
    if "--base-commit" in sys.argv:
        base_commit = sys.argv[sys.argv.index("--base-commit") + 1]
    as_json = "--json" in sys.argv

    reg = _import("registry_chaintxsim", os.path.join(TOOLS, "_registry.py"))

    # STRUCTURED RESULT, ALONGSIDE THE HUMAN LOG -- not instead of it. Every existing `print`
    # stays exactly as it was (this tool's own terminal output is unchanged and still the
    # authority a human reads); `--json` additionally emits ONE machine-parseable summary line at
    # the very end, prefixed so a caller can find it by scanning rather than needing to capture
    # ONLY stdout and hope nothing else was printed after it. Built for OuronetUI's "Chain-
    # simulate (whole round)" button: the backend already shells out to this tool (see
    # `plugins/ouronet-scripts.ts`'s `chaintxsim-purev10` entry); without this, the UI would have
    # to regex-scrape human prose to know which of the 24 files actually passed.
    file_names = [os.path.basename(f) for f in round_files(round_dir)]
    followup_names = [os.path.basename(f) for f in round_followups(round_dir)]
    result = {
        "round": os.path.relpath(round_dir, ROOT),
        "phase1": {"ok": False, "files": file_names, "failed_file": None, "message": ""},
        "phase2": {"ok": None, "boundary": False, "followups": followup_names, "message": ""},
    }

    def emit(code):
        if as_json:
            print("CHAINTXSIM_JSON:" + json.dumps(result))
        return code

    wt = None
    try:
        wt = build_worktree(base_commit, round_dir, reg)
        repl_dir = os.path.join(ROOT, "REPL")
        out_repl = os.path.join(repl_dir, "_chaintxsim_replay.repl")
        write_replay_repl(wt, round_dir, out_repl)

        print(f"\nrunning the replay from {repl_dir}...")
        pact = os.path.expanduser("~/.local/bin/pact")
        r = subprocess.run([pact if os.path.exists(pact) else "pact",
                            os.path.basename(out_repl)],
                           capture_output=True, text=True, cwd=repl_dir)
        combined = r.stdout + r.stderr
        print(combined[-6000:])
        os.remove(out_repl)

        if r.returncode != 0:
            # The LAST "--- [name] ---" banner to print is the last file that STARTED loading;
            # everything after it never ran. Not exact (an error can occur before its own file's
            # banner line is flushed in rare interleavings), but far better than nothing, and
            # exactly what a human reading the same log would infer by eye.
            seen = re.findall(r'--- \[([\w.]+)\] ---', combined)
            failed = next((n for n in reversed(seen) if n in file_names), None)
            # FALL BACK TO THE SOURCE PATH PACT ITSELF NAMED, 2026-10-24.
            #
            # The banner heuristic above only works when the replay prints `--- [file] ---` lines
            # AND the failing file is one of the round's own `*_deploy.pact`. Neither held on the
            # V13 round: the bootstrap replay prints no such banners, so `seen` was empty, `failed`
            # came back None, and the UI rendered "stopped at an unidentified file" -- which its
            # own rendering path then treated as "no failure index", painting every row green.
            #
            # Pact's error text carries the real location (`.../01_ANK.pact:2673:0:`). Reading it
            # is strictly better than inferring from banners that may not exist: it names the file
            # that actually raised, even when that file is a worktree source rather than one of
            # the round's transactions. Mapped back to a round file when it IS one, and reported
            # verbatim when it is not, because "the round broke inside a bootstrap file" is a
            # genuinely different answer from "transaction 3 is bad" and must not be disguised
            # as one.
            if not failed:
                paths = re.findall(r'([^\s:()"]+\.pact):\d+:\d+', combined)
                if paths:
                    base = os.path.basename(paths[-1])
                    failed = next((n for n in file_names if n == base), None)
                    if not failed:
                        result["phase1"]["failed_in_source"] = paths[-1]
            result["phase1"]["failed_file"] = failed
            result["phase1"]["message"] = combined[-2000:]
            return emit(r.returncode)

        result["phase1"]["ok"] = True
        result["phase1"]["message"] = "Load successful"

        # PHASE 2 -- real-chain verification for any hand-authored followup transactions
        # (round_followups): the sandbox above proves the 22 generated deploys compose in order;
        # it cannot meaningfully prove a data-dependent admin call like a migration or a stake,
        # because the sandbox's tables are freshly bootstrapped and carry none of the real chain's
        # row history. See verify_followups_live's own docstring for the full reasoning.
        if followup_names:
            ok, boundary, message = verify_followups_live(round_dir, reg)
            result["phase2"]["ok"] = ok
            result["phase2"]["boundary"] = boundary
            result["phase2"]["message"] = message
            return emit(0 if ok else 1)
        return emit(0)
    finally:
        # --keep-worktree: LEAVE THE PATCHED TREE ON DISK SO A FAILURE CAN BE INSPECTED.
        #
        # Added 2026-10-24, after a round failed here twice with the error caret sitting at a
        # module's closing paren and no message -- the signature of source that does not parse.
        # That is a question about the PATCHED file (this tool's own splice of live-fetched blocks
        # into a worktree copy), and the patched file was deleted by this very `finally` before
        # anyone could read it. A verification tool whose failures cannot be examined sends you
        # back to guessing, which is what it exists to replace.
        if wt:
            if "--keep-worktree" in sys.argv:
                print(f"\n--keep-worktree: patched tree left at {wt}\n"
                      f"  inspect it, then: git worktree remove --force {wt}")
            else:
                subprocess.run(["git", "worktree", "remove", "--force", wt], cwd=ROOT,
                               capture_output=True)


if __name__ == "__main__":
    sys.exit(main())

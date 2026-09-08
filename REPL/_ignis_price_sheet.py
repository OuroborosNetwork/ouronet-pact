#!/usr/bin/env python3
"""#76 — IGNIS PRICE SHEET, built from the TALOS client surface.

Owner spec (2026-09-05, correcting v1):
  * A "$100 function" means its DETER MULTIPLIER is 10000x. Deter is NOT the total price —
    the normal IGNIS consumption (the op's component cost) still applies ON TOP:
        TOTAL = deter + components
  * SIMPLE (fixed-price) = a function whose logic is fixed, so its cost is exactly knowable:
    flipping a boolean, minting a true fungible, transferring a DPTF. These are the BUILDING
    BLOCKS every other function is composed from.
  * COMPLEX = composed of several such simple ops in a VARYING composition (list-driven loops,
    per-nonce/per-hop work, heavy scans). We cannot state a total, so we print
    "COMPLEX — at least <deter>", i.e. the floor price.
  * Group by LOGICAL Talos entity: the `ENTITY|fn` prefix on the Talos wrapper. `SWP` therefore
    covers ops physically spread over SWP / SWPI / SWPLC / SWPU / MTX-SWP.

Talos is the only supported client path, so the Talos wrapper IS the client surface — this sheet
lists what a client actually calls, not the internal core defuns.

Shares the pricing brain of _ignis_deter_worksheet.py (OWNER_DECISIONS + suggest_deter + the
Option-A component model), so the two documents cannot drift.
"""
import re, glob, importlib.util
from collections import defaultdict

spec = importlib.util.spec_from_file_location('dw', 'REPL/_ignis_deter_worksheet.py')
dw = importlib.util.module_from_spec(spec); spec.loader.exec_module(dw)   # main() is guarded

TALOS = sorted(glob.glob('1_SOVEREIGN/STAGE_01/3_Talos/*.pact')
             + glob.glob('1_SOVEREIGN/STAGE_02/3_Talos/*.pact')
             + glob.glob('2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact'))

# module name -> defining file (so `ref-DPTF::` resolves to 05_DPTF.pact)
MOD2FILE = {}
for f in glob.glob('1_SOVEREIGN/**/*.pact', recursive=True) + glob.glob('2_CITIZEN/**/*.pact', recursive=True):
    for m in re.finditer(r'^\(module\s+([A-Za-z0-9|_+-]+)\s', open(f).read(), flags=re.M):
        MOD2FILE.setdefault(m.group(1), f)

# op index: file -> {op: (role, comp, deter, why)}
OPS = {}
for p in dw.MODS:
    OPS[p] = {nm: (rl, comp, d, why)
              for nm, rl, ins, upd, r, sc, x, comp, cur, d, why in dw.analyze(p)}

CLIENT = re.compile(r'^(C{1,2}p?_|A{1,2}p?_)')
HEAVY_PREFIX = re.compile(r'^(?:[A-Za-z0-9-]+\|)?(CC_|AA_|CCp_|AAp_|Cp_|Ap_)')
VARIABLE_FAMILY = re.compile(r'(Wipe|MultiTransfer|MultiBulk|BulkTransfer|SmartSwap|Vacate'
                             r'|Drain|Sweep|Unstale|Slice)')
SCALES = re.compile(r'\(dec\s*\(length|\(dec\s+token-count\)|\(dec\s+no-of-nonces\)'
                    r'|\(dec\s+number-of-nonces\)|fold\s*\(\+\)\s*0\.0'
                    r'|\(\*\s*\(dec|per-nonce|price-per-nonce')
# Same-module delegation must be followed too: DPOF::C_WipeClean is a thin alias that just calls
# C_WipePure in its OWN module, so a walk chasing only URCi_/X*_ stops before the cumulator and the
# op publishes "?". Bare C_/CC_/Cp_/CCp_ names are same-module client calls. This is only safe
# because the caller strips @doc prose first (see billing_text) -- without that it charges an op
# for every function its documentation happens to mention.
# UDC_*Cumulator constructors are cost SOURCES, not plumbing: IGNIS::UDC_BrandingCumulator holds
# the 100-ignis branding charge, so every C_UpdatePendingBranding ended at "?" while its own @doc
# said "costing 100 IGNIS". Follow them like any other cost reader.
BILL_FN = re.compile(r'((?:[A-Za-z0-9-]+\|)?(?:URCi[x]?_|XB_|XI_|XE_|UDC_[A-Za-z]*Cumulator)[A-Za-z0-9|_-]*)')

def defun_body(src, name):
    hits = [m for m in re.finditer(r'\(defun\s+' + re.escape(name) + r'(?::[^\s(]+)?\s*\(', src)]
    if not hits: return ''
    m = hits[-1]; j = m.start() + 1; depth = 1; instr = False
    while j < len(src) and depth:
        c = src[j]
        if instr:
            if c == '"' and src[j-1] != '\\': instr = False
        elif c == '"': instr = True
        elif c == '(': depth += 1
        elif c == ')': depth -= 1
        j += 1
    return src[m.start():j]

_SRC_CACHE = {}
def _src(path):
    if path not in _SRC_CACHE: _SRC_CACHE[path] = open(path).read()
    return _SRC_CACHE[path]

def billing_text(src, name, depth=3):
    """Walk the cost path from <name>, following URCi_/XB_/XI_/XE_ calls — INCLUDING
    cross-module ones (`ref-MOD::URCi_X`), since many ops delegate their cumulator to another
    module (e.g. MTX-SWP -> SWPI, DALOS ops -> IGNIS's DALOS|URCi_* readers)."""
    seen=set(); frontier=[(src, name)]; txt=''
    for _round in range(depth+1):
        nxt=[]
        for csrc, fn in frontier:
            key=(id(csrc), fn)
            if key in seen: continue
            seen.add(key)
            b = defun_body(csrc, fn)
            if not b: continue
            txt += ' ' + b
            # Follow calls found in CODE ONLY. @doc prose names other functions constantly --
            # ATS::C_ToggleUpgrade's doc says "Gates C_Control (...)" -- and a name matched in
            # prose gets that function's cost charged to this op.
            #
            # The strip MUST use \\[\\s\\S], not \\. : every Pact @doc is a multi-line
            # continuation ("... \\" newline "\\ ..."), and \\. cannot cross a newline, so the
            # string never closed, docs went unstripped AND the unmatched quote mis-paired with a
            # later one and stripped REAL CODE. That is what made the first attempt at this look
            # like a deep "walk vs extractor are coupled" problem when it was a broken regex.
            #
            # <txt> keeps the RAW body on purpose: charge() harvests deter keys out of string
            # literals, e.g. (URCi_IssueAnchor "anchor-nf" ...).
            b_code = re.sub(r'"(?:[^"\\]|\\[\s\S])*"', ' ', b)
            nxt.extend((csrc, f) for f in BILL_FN.findall(b_code))
            # DIRECT same-module delegation only, and only from the op's OWN body (round 0).
            # DPOF::C_WipeClean is a thin alias onto C_WipePure, so without this the walk stops
            # before the cumulator. Following C_ TRANSITIVELY is what breaks: at depth it reaches
            # sibling client ops and charges their deterrence here (DPDC-F::C_MergeFragments
            # absorbed frag-enable 100 + C_MakeFragments, floor 18 -> 152, though its code calls
            # only C_Transfer). One hop captures the alias; more hops capture the neighbourhood.
            if _round == 0:
                nxt.extend((csrc, f) for f in
                           re.findall(r'\((C{1,2}p?_[A-Za-z0-9|_-]+)', b_code))
            # Same-module PRICE HELPERS, at any depth. A cost reader often just forwards to one:
            # PYTHIA's URCi_DeployApiKey is literally (UC_DeployPrice), which forwards to
            # UR_DeployPrice -> UR_Config -> UC_StoaPrice "pythia-deploy". None of those are
            # URCi_/X*_ names, so the walk stopped one call short of the price and the op
            # published "?" while charging $50. Deliberately NARROW -- only names that say they
            # are about price/fee/cost/config/stoa -- so this cannot become "follow everything".
            nxt.extend((csrc, f) for f in re.findall(
                r'\((U(?:C|R|RC)_[A-Za-z0-9|_-]*(?:Price|Fee|Cost|Config|Stoa)[A-Za-z0-9|_-]*)', b_code))
            # Follow cross-module CLIENT ops too (ref-TFT::C_Transfer, ref-DPTF::C_Mint …):
            # ops like VST|C_Freeze hold no cumulator of their own, they CONCATENATE the
            # cumulators of the client ops they drive. Without this they read as unresolved
            # even though every leg is knowable.
            # An alias is NOT the module name. `(ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)`
            # binds alias `B|DPOF` to module `DPOF`; likewise ref-ANK -> AQP-ANK, ref-ORBR ->
            # OUROBOROS, ref-LEDGER -> PYTHIA, and every B|*/P|* form. Looking the ALIAS up in
            # MOD2FILE returned None, so the hop was silently dropped and the op published "?"
            # even though it charges. Read the real module out of the let-binding first.
            alias2mod = dict((a, mm) for a, _i, mm in
                             re.findall(r'\((ref-[A-Za-z0-9|_+-]+):module\{([A-Za-z0-9|_+-]+)\}\s+([A-Za-z0-9|_+-]+)\)', b))
            # Cross-module hops must cover the SAME name classes the same-module walk does:
            # cumulator constructors (ref-IGNIS::UDC_BrandingCumulator holds the 100-ignis
            # branding charge) and price helpers. Listing UDC_ only in BILL_FN fixed nothing,
            # because these are always reached through a ref.
            for mod, rf in re.findall(
                    r'(ref-[A-Za-z0-9|_+-]+)::((?:[A-Za-z0-9-]+\|)?'
                    r'(?:URCi[x]?_|XB_|XI_|XE_|CC?p?_|UDC_[A-Za-z]*Cumulator'
                    r'|U(?:C|R|RC)_[A-Za-z0-9|_-]*(?:Price|Fee|Cost|Config|Stoa))'
                    r'[A-Za-z0-9|_-]*)', b_code):
                real = alias2mod.get(mod) or mod[4:]
                mf = MOD2FILE.get(real) or MOD2FILE.get(mod[4:])
                if mf: nxt.append((_src(mf), rf))
        frontier = nxt
    return txt

def is_variable(core_file, core_fn, talos_body):
    """COMPLEX per the owner: a VARYING composition of simpler ops."""
    if HEAVY_PREFIX.match(core_fn):     return 'heavy / parallel-slice op'
    if VARIABLE_FAMILY.search(core_fn): return 'per-nonce / per-item work'
    src = open(core_file).read()
    role, comp, d, why = OPS[core_file][core_fn]
    if SCALES.search(billing_text(src, core_fn)):
        return 'charge multiplies by an item count'
    # Composed op: it holds no cumulator of its own, it concatenates the cumulators of the
    # client ops it drives. The static walk reaches every leg but CANNOT count repeats (a
    # two-transfer op collapses to one transfer leg on de-dup), so the sum is a FLOOR, never
    # an exact price. Saying "exact" here would be a lie of precision.
    if re.search(r'ref-[A-Za-z0-9|_+-]+::(?:[A-Za-z0-9-]+\|)?CC?p?_', defun_body(src, core_fn) or ''):
        return 'composes other client ops (legs may repeat — floor)'
    # a Talos wrapper that fans out over a list argument composes a varying number of sub-ops
    if re.search(r'\(map\s|\(fold\s', talos_body):
        return 'wrapper fans out over a list'
    return None


# ---------------------------------------------------------------------------------------------
# ACTUAL CHARGE EXTRACTION — read the real cumulator legs out of the code, not the cost MODEL.
# IGNIS is charged by the cumulator an op returns; STOA by STOA|C_Collect on a UsagePrice key.
# ---------------------------------------------------------------------------------------------
_ig = open('1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact').read()
def _parse_map(nm):
    i=_ig.index('(defconst %s'%nm); j=_ig.index('\n    )', i)
    return {k: float(v) for k, v in re.findall(r'"([A-Za-z0-9|_+-]+)"\s*:\s*([0-9.]+)', _ig[i:j])}
IG_DETER  = _parse_map('IG|DETER')
IG_COMPONENTS = _parse_map('IG|COMPONENTS')
IG_WEIGHT = _parse_map('IG|WEIGHTS')
IG_LEGS   = _parse_map('IG|LEGS')
# tier words that also occur as ordinary strings — never inferred from a bare literal
GENERIC_DETER = {'usage', 'setup', 'auth', 'fee', 'small'}
# IG|DETER keys that are a DOLLAR BASIS FOR A STOA LEG ONLY — the op charges no IGNIS at all.
# They must never produce an IGNIS deter leg: PYTHIA carries no IGNIS cost (owner-confirmed),
# account deploys and branding are STOA-priced. Without this, seeing UC_StoaPrice "pythia-deploy"
# in the text made PYTHIA|C_DeployApiKey publish 6000 IGNIS ($60) for a free-in-IGNIS op — and
# because UR_Config reads BOTH tolls, it charged deploy AND rename together.
STOA_ONLY_DETER = {'acct-standard', 'acct-smart', 'pythia-deploy', 'pythia-rename',
                   'branding-blue'}
USAGE = {k: float(v) for k, v in re.findall(
    r'A_UpdateUsagePrice\s+"([^"]+)"\s+([0-9.]+)',
    open('REPL/Stage_01/[4.0]_Sovereign-Executor.repl').read())}
# The rehaul RE-SEEDS the per-asset STOA keys later in the same executor file, as DERIVED
# expressions the literal regex above cannot see:
#     (DALOS|A_UpdateUsagePrice "dptf" (ref-IGNIS::UC_StoaPrice "issue-tf"))
# Those overrides come LAST, so they are what the chain actually holds -- but the sheet kept
# reporting the STALE pre-rehaul literals seeded earlier (dptf 0.2, dpnf 0.5, ats 0.1 ...).
# Owner rule: an issuance op's STOA fee is its DETERRENCE EXPRESSED IN DOLLARS, converted at
# the hard peg. UC_StoaPrice(k) == (IG|DETER[k] / 100) / stoa|price, i.e. deter/10 at $0.10.
# So issue-tf 1000 -> $10 -> 100 STOA; issue-nft 2500 -> $25 -> 250 STOA.
STOA_PEG = USAGE.get('stoa|price', 0.1)
STOA_DETER = {}          # usage-price key -> the IG|DETER key its STOA fee is derived from
for _k, _dk in re.findall(
        r'A_UpdateUsagePrice\s+"([^"]+)"\s+\([^)]*UC_StoaPrice\s+"([^"]+)"\)',
        open('REPL/Stage_01/[4.0]_Sovereign-Executor.repl').read()):
    USAGE[_k] = (IG_DETER.get(_dk, 0.0) / 100.0) / STOA_PEG
    STOA_DETER[_k] = _dk

TIER = {'UDC_SmallestCumulator':'ignis|smallest','UDC_SmallCumulator':'ignis|small',
        'UDC_MediumCumulator':'ignis|medium','UDC_BigCumulator':'ignis|big',
        'UDC_BiggestCumulator':'ignis|biggest'}

def charge(src, core_fn, entity=None, extra=''):
    """Depth-3 first; if that yields NOTHING, retry deeper (see _charge_at).

    Escalating only on an unresolved op is what makes deeper walking safe. Depth 5 applied
    globally bleeds sibling operations into already-priced rows (AQP-FVT|CC_Collect absorbed
    deter:aqp-inject 500, floor 557 -> 1150). A row that resolves at 3 keeps its depth-3 answer,
    so it cannot move; a row that resolves to NOTHING at 3 has no price to protect, and any leg
    found deeper is strictly more than the "?" it would otherwise publish. Ops that need this are
    the ones whose cost sits behind pure delegation hops that burn the budget before reaching it:
    SWP|C_Swap goes C_Swap -> XI_STOA-PID|Swap -> XI_Swap before its first real leg.
    """
    ig, st = _charge_at(src, core_fn, entity, extra, 3)
    if not ig:
        for deeper in (5, 7):
            ig2, st2 = _charge_at(src, core_fn, entity, extra, deeper)
            if ig2: return ig2, st2
    return ig, st


def _charge_at(src, core_fn, entity=None, extra='', _depth=3):
    """Return (ignis_legs, stoa_legs) actually billed, each a list of (label, amount)."""
    # Many Talos wrappers build the cumulator THEMSELVES —
    #   (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_ControlSmartAccount account))
    # so the price leg lives in the wrapper, not the core op. Scan both.
    txt = billing_text(src, core_fn, depth=_depth) + ' ' + extra
    ig, st = [], []
    for m in re.finditer(r'UDC_(?:Smallest|Small|Medium|Big|Biggest)Cumulator', txt):
        key = TIER['UDC_' + m.group(0)[4:]]
        ig.append((key.split('|')[-1], USAGE.get(key, 0.0)))
    # the migrated form: UC_IgnisPrice "<ENTITY|FN>" "<deter-key>" == deter + components
    for opk, dk in re.findall(r'UC_IgnisPrice\s+"([A-Za-z0-9|_+-]+)"\s+"([a-z0-9|-]+)"', txt):
        ig.append(('deter:' + dk, IG_DETER.get(dk, 0.0)))
        ig.append(('components:' + opk, IG_COMPONENTS.get(opk, 0.0)))
    for k in re.findall(r'(?<!UC_IgnisPrice )UC_IgnisDeter\s+"([a-z0-9|-]+)"', txt):
        ig.append(('deter:' + k, IG_DETER.get(k, 0.0)))
    for k in re.findall(r'UC_IgnisWeight\s+"([a-z0-9|-]+)"', txt):
        ig.append(('weight:' + k, IG_WEIGHT.get(k, 0.0)))
    # Deter key passed AS AN ARGUMENT, not written literally at the UC_IgnisDeter call site:
    #   (URCi_IssueAnchor "anchor-nf" [...])  ->  the reader does (UC_IgnisDeter deter-key).
    # Whole families (ANK/POOL/FVT issuance) bill this way and were showing as unresolved.
    # Only distinctive keys count — the generic tier words appear in unrelated strings.
    for k in re.findall(r'"([a-z][a-z0-9-]*)"', txt):
        if k in IG_DETER and k not in GENERIC_DETER and k not in STOA_ONLY_DETER:
            ig.append(('deter:' + k, IG_DETER[k]))
    # A legacy tier is often MULTIPLIED at the call site -- ATS::URCi_SetColdRecoveryFees
    # charges `(* (UR_UsagePrice "ignis|biggest") 20.0)` = 100, but a bare scan reported the
    # unmultiplied 5, understating the op 20x. Consume the multiplied forms FIRST, then let
    # the plain scan handle whatever is left.
    # Unit tiers now come from the IG|LEGS CONSTANTS, not the DALOS usage-price table
    # (owner 2026-09-07: "no more table values"). Label them by their bare tier name so the
    # breakdown text is unchanged from the table era -- the conversion moved no price, and the
    # sheet must show that.
    def _leg(m):
        k = m.group('k'); n = float(m.group('n') or 1)
        lab = k[5:] if k.startswith('tier-') else 'leg:' + k
        ig.append((lab if n == 1 else f'{lab}x{n:g}', IG_LEGS.get(k, 0.0) * n))
        return ' '
    txt = re.sub(r'\(\*\s*\(?[\w:|-]*UC_IgnisLeg\s+"(?P<k>[a-z0-9-]+)"\)\s*(?P<n>[0-9]+\.[0-9]+)\s*\)', _leg, txt)
    txt = re.sub(r'\(\*\s*(?P<n>[0-9]+\.[0-9]+)\s*\(?[\w:|-]*UC_IgnisLeg\s+"(?P<k>[a-z0-9-]+)"\)\s*\)', _leg, txt)
    for _k in re.findall(r'UC_IgnisLeg\s+"([a-z0-9-]+)"', txt):
        _lab = _k[5:] if _k.startswith('tier-') else 'leg:' + _k
        ig.append((_lab, IG_LEGS.get(_k, 0.0)))

    def _mul(m):
        k = m.group('k'); n = float(m.group('n'))
        ig.append((f"{k.split('|')[-1]}x{n:g}", USAGE.get(k, 0.0) * n))
        return ' '
    txt = re.sub(r'\(\*\s*\(?[\w:|-]*UR_UsagePrice\s+"(?P<k>ignis\|[a-z-]+)"\)\s*(?P<n>[0-9]+\.[0-9]+)\s*\)',
                 _mul, txt)
    txt = re.sub(r'\(\*\s*(?P<n>[0-9]+\.[0-9]+)\s*\(?[\w:|-]*UR_UsagePrice\s+"(?P<k>ignis\|[a-z-]+)"\)\s*\)',
                 _mul, txt)
    for k in re.findall(r'UR_UsagePrice\s+"(ignis\|[a-z-]+)"', txt):
        ig.append((k.split('|')[-1], USAGE.get(k, 0.0)))
    for lit in re.findall(r'UDC_ConstructOutputCumulator\s+([0-9]+\.[0-9]+)', txt):
        if float(lit) == 0.0: continue    # identity element in a conditional, not a charge
        ig.append(('literal', float(lit)))
    if 'STOA|C_Collect' in txt or re.search(r'URCi_\w*Stoa', txt):
        for k in re.findall(r'UR_UsagePrice\s+"([a-z]+)"', txt):
            if k in USAGE and not k.startswith('ignis'):
                st.append((k, USAGE[k]))
    # The issuance STOA readers (URCi_IssueStoa, URCi_IssueCollectionStoa, ...) call
    # UC_StoaPrice DIRECTLY on an IG|DETER key instead of going through UR_UsagePrice, so the
    # scan above never saw them and EVERY issuance row printed "-" in the STOA column while the
    # chain was charging correctly all along. Owner rule: an issuance op's STOA fee carries the
    # SAME DOLLAR VALUE as its deterrence, converted at the peg --
    #     UC_StoaPrice(k) == (IG|DETER[k] / 100) / stoa|price
    # so issue-tf 1000 -> $10 -> 100 STOA, issue-nft 2500 -> $25 -> 250 STOA.
    for k in re.findall(r'UC_StoaPrice\s+"([a-z0-9-]+)"', txt):
        st.append(('stoa:' + k, (IG_DETER.get(k, 0.0) / 100.0) / STOA_PEG))
    # `(if son A B)` branches: DPSF is son=true (first branch), DPNF is son=false (second).
    # Without this the SFT and NFT prices get SUMMED instead of selected.
    if entity in ('DPSF', 'DPNF') and re.search(r'\(if\s+son', txt):
        # migrated form — the branch is visible in the leg LABELS
        # (components:DPSF|C_Control vs components:DPNF|C_Control), so select by entity rather
        # than by position. Positional picking only worked for a bare 2-leg tier pair and left
        # every son-branching UC_IgnisPrice op summing BOTH components (DPSF|C_Control showed
        # 35 = 5 + 15 + 15 while the chain charges 20).
        keyed = [lab for lab, _ in ig if lab.startswith('components:')]
        if any(l.startswith('components:DPSF|') for l in keyed) and \
           any(l.startswith('components:DPNF|') for l in keyed):
            ig = [(lab, amt) for lab, amt in ig
                  if not lab.startswith('components:') or lab.startswith(f'components:{entity}|')]
        # same branch, deter side: `(if son (UC_IgnisPrice .. "issue-sft") (.. "issue-nft"))`
        sft, nft = 'deter:issue-sft', 'deter:issue-nft'
        if any(l == sft for l, _ in ig) and any(l == nft for l, _ in ig):
            drop = nft if entity == 'DPSF' else sft
            ig = [(lab, amt) for lab, amt in ig if lab != drop]
        elif len(ig) == 2 and not any(
                lab.startswith(('deter:', 'components:')) for lab, _ in ig):
            # LEGACY TIER PAIR ONLY. A single migrated `UC_IgnisPrice "<op>" "<deter>"` emits
            # exactly TWO legs (deter: + components:) that must be SUMMED, not chosen between.
            # Without this guard the positional pick fired on the ~28 nonce-field updates and
            # kept one half each way: DPSF showed deter 5, DPNF showed components 17, where the
            # chain charges 5 + 17 = 22 for both (URCi_UpdateNonceField, one shared reader).
            ig = [ig[0 if entity == 'DPSF' else 1]]
        ssft, snft = 'stoa:issue-sft', 'stoa:issue-nft'
        if any(l == ssft for l, _ in st) and any(l == snft for l, _ in st):
            drop = snft if entity == 'DPSF' else ssft
            st = [(lab, amt) for lab, amt in st if lab != drop]
        elif len(st) == 2:
            st = [st[0 if entity == 'DPSF' else 1]]
    # PYTHIA: UR_Config reads BOTH tolls in one row, so walking into it collects deploy AND
    # rename for whichever op we are pricing (both published 600 STOA = $60). Disambiguate on the
    # specific helper the op's own reader called: URCi_DeployApiKey -> UC_DeployPrice,
    # URCi_UpdateDualConsumerLane -> UC_RenamePrice.
    _has_dep, _has_ren = 'UC_DeployPrice' in txt, 'UC_RenamePrice' in txt
    if _has_dep != _has_ren:
        _drop = 'stoa:pythia-rename' if _has_dep else 'stoa:pythia-deploy'
        st = [(lab, amt) for lab, amt in st if lab != _drop]

    # de-dup identical legs (same reader reached by several paths)
    def dedup(v):
        out=[]; seen=set()
        for lab, amt in v:
            if (lab, amt) in seen: continue
            seen.add((lab, amt)); out.append((lab, amt))
        return out
    return dedup(ig), dedup(st)

def money(ig): return "$%.2f" % (ig/100.0)
def md(x):
    """Render an identifier safely in a markdown table cell.

    Ouronet identifiers contain '|' (C_2|Inject, STOA-PID|C_AddStandardLiquidity). Markdown
    splits table cells on a raw '|' BEFORE parsing inline code, so backticks do not protect it,
    and a \\| escape does NOT work inside backticks either (renderers print the backslash
    literally and still split). The one form that survives is an HTML <code> element with the
    pipe as a numeric entity, because entities ARE decoded inside <code>."""
    x = str(x)
    if '|' in x:
        # NOT <code>+&#124; — the renderer prints that literally. Outside a code span a
        # backslash-escaped pipe IS honoured, so emit plain text with \| (loses monospace,
        # but the name renders correctly and stays copy-pasteable).
        return x.replace('|', r'\|')
    return '`' + x + '`'

rows = defaultdict(list)     # entity -> [ (talos_fn, core_fn, role, deter, comp, reason) ]
emitted = set()
skipped = 0
for tf in TALOS:
    src = open(tf).read()
    for m in re.finditer(r'^    \(defun\s+([A-Za-z0-9-]+)\|([A-Za-z0-9_|+-]+?)(?::[^\s(]+)?\s*\(', src, flags=re.M):
        entity, fn = m.group(1), m.group(2)
        body = defun_body(src, f'{entity}|{fn}')
        if not body: continue
        # the priced core ops this wrapper drives (IGNIS::C_Collect is billing plumbing, not an op)
        # `ref-AQP::` is a LET-BINDING ALIAS, not a module name — the real module is bound as
        # (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL). Resolve aliases from the wrapper's own
        # file, else every AQP-* wrapper silently fails module lookup and gets skipped.
        alias = dict(re.findall(r'\(ref-([A-Za-z0-9|_+-]+):module\{[^}]*\}\s+([A-Za-z0-9|_+-]+)\)', src))
        cores = [(alias.get(mod, mod), cf)
                 for mod, cf in re.findall(r'ref-([A-Za-z0-9|_+-]+)::([A-Za-z0-9_|+-]+)', body)
                 if CLIENT.match(cf) and alias.get(mod, mod) != 'IGNIS']
        seen=set(); cores=[c for c in cores if not (c in seen or seen.add(c))]
        if not cores:
            skipped += 1; continue
        if (entity, fn) in emitted:      # Talos files declare each fn twice (interface + module)
            continue
        emitted.add((entity, fn))
        # price from the PRIMARY core op (the first priced call); extra fixed calls noted below
        mod, cf = cores[0]
        cfile = MOD2FILE.get(mod)
        if not cfile or cfile not in OPS or cf not in OPS[cfile]:
            skipped += 1; continue
        role, comp, d, why = OPS[cfile][cf]
        if re.match(r'^A{1,2}p?_', fn):
            d = None                    # admin-run Talos entrypoint: IGNIS+STOA free (owner rule)
        reason = is_variable(cfile, cf, body)
        if len(cores) > 1 and reason is None:
            reason = None   # fixed multi-call composition is still exactly knowable
        # resolve any cumulator readers the WRAPPER itself calls (cross-module)
        extra = body
        # WALK the wrapper's cost readers, do not merely append their body. PYTHIA's toll is
        # three hops past the reader (URCi_DeployApiKey -> UC_DeployPrice -> UR_DeployPrice ->
        # UR_Config -> UC_StoaPrice "pythia-deploy"), so a one-level append stops short and the
        # op published "?" despite charging $50. Alias-resolved for the same reason billing_text
        # is: `ref-LEDGER` is PYTHIA, `ref-B|DPTF` is DPTF.
        _alias2mod = dict((a, mm) for a, _i, mm in
                          re.findall(r'\((ref-[A-Za-z0-9|_+-]+):module\{([A-Za-z0-9|_+-]+)\}\s+([A-Za-z0-9|_+-]+)\)', body))
        for mod2, rf in re.findall(r'(ref-[A-Za-z0-9|_+-]+)::((?:[A-Za-z0-9-]+\|)?URCi[x]?_[A-Za-z0-9|_-]+)', body):
            real = _alias2mod.get(mod2) or mod2[4:]
            mf = MOD2FILE.get(real) or MOD2FILE.get(mod2[4:])
            if mf: extra += ' ' + billing_text(_src(mf), rf, depth=3)
        igl, stl = charge(_src(cfile), cf, entity, extra)
        rows[entity].append((f'{entity}|{fn}', cf, role, d, comp, reason, len(cores), igl, stl))

print("# IGNIS PRICE SHEET — per Talos client function, grouped by logical module\n")
print("Generated by `REPL/_ignis_price_sheet.py` (shares the pricing brain of")
print("`REPL/_ignis_deter_worksheet.py`, so the two sheets cannot drift).\n")
print("## How to read this\n")
print("**`TOTAL = deter + components`.** The *deter* column is the deterrence multiplier only —")
print("a \"$100 function\" means deter = 10000x, i.e. 10000 IGNIS of deterrence. The normal IGNIS")
print("consumption (*components*: writes, updates, reads, scans, cross-module hops) is charged")
print("**on top**, and is what the *components* column shows.\n")
print("**SIMPLE (fixed price)** — the logic is fixed, so the cost is exactly knowable. These are")
print("the BUILDING BLOCKS every complex function is composed from (flip a boolean, mint a true")
print("fungible, transfer a DPTF …). Their TOTAL is a real, quotable number.\n")
print("**COMPLEX** — composed of several simple ops in a *varying* composition (a list-driven")
print("loop, per-nonce/per-hop work, a heavy scan). No single total exists, so we print the")
print("**floor**: it costs *at least* the deter price, plus whatever its runtime path consumes.\n")
print("**EXEMPT** — deliberately free: all Ouronet-Admin `A_*` ops, account deploys, and the")
print("IGNIS machinery itself (the collectors, Compress/Sublimate/Firestarter, DalosFuel).\n")
print("Each section is one **logical Talos entity**; the rows drop the redundant prefix, so a row")
print("`C_AddHotRBT` under `## ATS` is called as **`ATS|C_AddHotRBT`**. Functions are listed")
print("alphabetically within each module.\n")
print("Grouping is by **logical Talos entity** — the `ENTITY|fn` prefix — so e.g. `SWP` covers ops")
print("physically spread across SWP / SWPI / SWPLC / SWPU / MTX-SWP. Talos is the only supported")
print("client path, so these are the functions a client actually calls.\n")
print("*Caveat:* `components` is the modelled compute cost (Option-A buckets, calibrated against")
print("measured gas in rehaul substage 6). It counts the core op's own module-internal work;")
print("cross-module callee internals are not re-summed, so delegating ops read a little low.\n")

DETER_ROLE = {'usage': 'USAGE', 'setup': 'SETUP', 'auth': 'AUTH', 'fee': 'FEE',
              'small': 'SETUP', 'token-account': 'ISSUE', 'fee-unlock': 'FEE'}


def role_from_legs(igl):
    """Role as the CODE charges it: the deter key an op bills through. None when the op does not
    resolve to a single deterrence tier (composed ops, legacy flat tiers)."""
    keys = [lab.split(':', 1)[1] for lab, _ in igl if lab.startswith('deter:')]
    if len(set(keys)) != 1:
        return None
    k = keys[0]
    return DETER_ROLE.get(k, 'ISSUE' if k.startswith('issue-') else None)


nsimple=ncomplex=nexempt=nunknown=nstoaonly=0
for entity in sorted(rows):
    print(f"\n## {entity}\n")
    print("| Talos function | core op | role | IGNIS | STOA | $ (ignis) | charge breakdown |")
    print("|----------------|---------|------|------:|-----:|----------:|------------------|")
    for tfn, cf, role, d, comp, reason, ncall, igl, stl in sorted(
            rows[entity], key=lambda z: z[0].split('|', 1)[-1].lower()):
        compose = f" ×{ncall}" if ncall > 1 else ""
        tfn_s, cf_s = md(tfn.split('|', 1)[-1]), md(cf)
        # The role column used to come from a NAME heuristic, which drifts from what the code
        # actually charges (C_RotateOwnership read "SETUP" while billing deter:auth). When the
        # op bills through UC_IgnisPrice the deter key IS the role — prefer that ground truth.
        role = role_from_legs(igl) or role
        ig_sum = sum(a for _, a in igl)
        st_sum = sum(a for _, a in stl)
        st_cell = f"{st_sum:g}" if stl else "—"
        legs = " + ".join(f"{lab} {amt:g}" for lab, amt in igl) if igl else "—"
        if stl:
            legs += " | STOA: " + " + ".join(f"{lab} {amt:g}" for lab, amt in stl)
        # An admin (A_/AA_) Talos entrypoint is IGNIS+STOA exempt REGARDLESS of what legs the
        # core op it drives would otherwise charge — classify from the Talos prefix.
        if d is None:
            nexempt += 1
            print(f"| {tfn_s} | {cf_s}{compose} | {role} | **0** | — | free | admin/exempt |")
        elif not igl and stl:
            # NO ignis legs but a REAL STOA leg = an op that is priced in STOA only, by design
            # (its Talos wrapper carries no IGNIS::C_Collect at all). Branding upgrades, the
            # PYTHIA tolls and the CODEX StoicTag family are all like this. Printing "?" for
            # them said "we could not work it out" when the honest answer is "no IGNIS is
            # charged, here is the STOA".
            nstoaonly += 1
            print(f"| {tfn_s} | {cf_s}{compose} | {role} | **0** | {st_cell} | STOA only | "
                  f"no IGNIS charged — priced in STOA only |")
        elif not igl:
            nunknown += 1
            print(f"| {tfn_s} | {cf_s}{compose} | {role} | **?** | {st_cell} | — | "
                  f"cumulator not resolvable statically (reader lives in another module) |")
        elif reason:
            ncomplex += 1
            print(f"| {tfn_s} | {cf_s}{compose} | {role} | **≥ {ig_sum:g}** | {st_cell} | "
                  f"COMPLEX | {reason}; legs: {legs} |")
        else:
            nsimple += 1
            print(f"| {tfn_s} | {cf_s}{compose} | {role} | **{ig_sum:g}** | {st_cell} | "
                  f"{money(ig_sum)} | {legs} |")

print(f"\n---\n{nsimple} simple (exact price) · {ncomplex} complex (floor price) · "
      f"{nstoaonly} STOA-only · {nexempt} exempt"
      f" · {nunknown} unresolved"
      f" · {nsimple+ncomplex+nexempt} Talos client functions"
      f"\n\n`×N` on a core op = the wrapper drives N priced core ops in a FIXED composition"
      f" (still exactly knowable).\n")
print("Regenerate: `python3 REPL/_ignis_price_sheet.py > OuronetInformational/IGNIS-PRICING/IGNIS-PRICE-SHEET.md`")

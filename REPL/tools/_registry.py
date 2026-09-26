#!/usr/bin/env python3
"""Build the Ouronet consumer registry: every callable function, its shape, and how to call it.

WHAT THIS IS.  A machine-readable description of the protocol's callable surface, so that a
consumer supplies VALUES and never types a function name.  Three consumers -- OuronetUI, the
Codex package, Pythia -- each hardcoded names and argument orders as strings, each drifted
independently, and every drift was found by a user rather than a test: 30 cost previews left on
the wrong side of an `INFO_` rename, five builders one argument short after the patron/executor
sweep, a nonce reader that made Awake and Slumber report "no nonces" against three live ones.
A missing member is a RESOLUTION error, so `try` cannot catch it and consumers render it as a
default -- which is exactly why these read as missing DATA rather than as broken calls.

It is not an ABI in the Ethereum sense.  There is no binary: Pact returns its own source, so the
deployed code IS the interface and can be read directly.

DEPLOYED CODE WINS.  `describe-module` returns the live source; the repo is consulted only for
modules not yet on chain, and those entries are marked `repo-only` and flagged NOT CALLABLE.
Generating from the repo alone would advertise functions that exist in files nobody has deployed
-- the same `no such member` failure, arriving from the other direction.

THE AUTHORED LAYER IS NEVER OVERWRITTEN.  Ghost values are example data; they cannot be derived
from a contract and must be written by a human.  They live in a separate file that is merged in,
so regenerating can never destroy them.

HOW A CALL EXECUTES is the fourth axis, alongside shape, ownership and price.  Knowing the
argument list is not enough to make a call, because some arguments cannot be typed by a user --
they are the output of a scan the client must run first.  Four modes:

  direct               the provided inputs suffice.  406 of 423.
  indirect-single      ONE transaction, but a preflight read supplies some argument.  The two
                       SmartSwap entrypoints (the route bundle is assembled client-side) and the
                       three `C_WipePure`s (the object comes from `URHC_WipePure`).
  indirect-parallel    a preflight is cut into slices, one per transaction, ORDER-INDEPENDENT --
                       so the slices may be submitted at once.
  indirect-sequential  a preflight reports progress; each call takes a SIZE and advances a stored
                       cursor, so the calls are STRICTLY ORDERED.

The last two both wear the `p` suffix and the distinction is NOT cosmetic: firing a cursor
pager's pages in parallel races its own progress counter.  CLAUDE.md states the rule (fed slice
vs cursor pager); this encodes it per entrypoint so a consumer does not have to know it.

The fed set is DERIVED, not listed -- a parameter is preflight-fed when its type is the return
type of a heavy read (`URH_`/`URHC_`/`URD_`), which by definition no caller can construct.  The
first cut used a hand-picked tuple and missed all three `C_WipePure`s; that error is invisible,
because the arity and the type are both right and the call merely wipes the wrong nonces.  Types
are matched WITH their interface qualifier: `DpofUdcV2.RemovableNonces` and
`DpdcManagementV2.RemovableNonces` are different schemas returned by two different readers that
share the name `URHC_WipePure`, and the unqualified match cited both for every wipe entrypoint.

  python3 REPL/tools/_registry.py --probe   read the chain, rebuild (slow, needs network)
  python3 REPL/tools/_registry.py --check   offline; fatal inside _gate.py
"""
import base64
import hashlib
import io
import json
import os
import re
import sys
import time
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _authsurface import strip_code  # noqa: E402  (shared parser, never re-implemented)
from _authsurface import (collect as auth_collect, surface_structured,  # noqa: E402
                          ENTRY as AUTH_ENTRY)

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.json")
AUTHORED = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.authored.json")
GHOSTS   = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.ghosts.json")
AUTH_SURFACE = os.path.join(ROOT, "OuronetInformational", "ARCHITECTURE", "AUTH-SURFACE.md")
NODE = ("https://node2.stoachain.com/chainweb/0.0/stoa/chain/0/pact/api/v1/local"
        "?signatureVerification=false&preflight=false")

ENTRYPOINT = re.compile(r'^[A-Za-z0-9|_-]*\|C{1,2}p?_[A-Za-z0-9]+$')
PREVIEW = re.compile(r'^INFO_[A-Za-z0-9|_-]+$')
# A read that RETURNS the external capabilities a call needs, rather than a value. All five
# launchpads share the shape: `:[string]` of `(coin.TRANSFER from to amount)` forms, padded by
# slippage. The contract owns the formula; the registry only has to point at it, which is why
# no formula is encoded here.
CAPS_READ = re.compile(r'\(defun\s+(URC[a-z]?_[A-Za-z]+):\[string\]')

# HOW A CALL IS EXECUTED -- direct, or fed by an off-chain read first.
#
# A parameter is NOT user input when its type is the RETURN TYPE OF A HEAVY READ. That set is
# DERIVED from the tree (scan_heavy_returns below), not hand-listed -- the first cut of this was a
# hand-picked tuple and it missed the three `C_WipePure` entrypoints, which take the object
# `URHC_WipePure` returns. A consumer told "direct" there would try to build a heavy scan's output
# out of user input, which cannot be done. The signature of the mistake is that it is INVISIBLE:
# the arity is right, the type is right, and the call simply wipes the wrong set of nonces.
HEAVY_RETURN = re.compile(
    r'\(defun\s+(URH[C]?_|URD_)([A-Za-z0-9|_-]+):\[?object\{([A-Za-z0-9._|-]+)\}')

# The one set that CANNOT be derived that way, because no on-chain read returns it: the SmartSwap
# bundle is assembled client-side from several cached-path reads. The evidence is the schema's own
# @doc -- "Assembled entirely client-side per P3.7's orchestration sequence" (19_SWPU.pact:96) --
# so the list is checked against that doc rather than trusted; see check_client_assembled().
CLIENT_ASSEMBLED = {
    "SmartSwapPathBundle": "HANDOFFS/HANDOFF-swp-smartswap-bundle-architecture.md",
    "SwapRoute":           "HANDOFFS/HANDOFF-swp-smartswap-bundle-architecture.md",
    "CachedPathOrMiss":    "HANDOFFS/HANDOFF-swp-smartswap-bundle-architecture.md",
}

# The `p` suffix marks a multi-transaction recipe (StoicSyntax-Prefixes.md, "Recipe axes"), and
# TWO shapes wear it -- only one is parallel. A FED-SLICE takes an explicit slice and is
# order-independent, so its legs can be fired at once. A CURSOR PAGER takes a size, computes its
# own window from stored progress, and is strictly SEQUENTIAL. Getting this backwards would have
# a consumer fire a pager's pages in parallel, which races its own progress counter.
# A `defpact` is the FOURTH shape, and the one a taxonomy about dirty reads does not naturally
# reach -- it is orthogonal. Its inputs are ordinary literals, so on the input axis it looks
# `direct`; but the owner's definition of direct is "nothing else is needed", and a defpact needs
# a CONTINUATION. Step 0 runs on submit and the rest advance with `continue-pact`, which is a
# `cont` payload, not a new `exec`. A consumer told "direct" submits once, sees success, and
# leaves the operation half-finished -- liquidity committed with no LP minted, for instance.
# Found by restoring docs/CHAPTER-INTEGRATION/01-client-orchestration.md, which names this as
# shape IV; all 14 starters were classified `direct` until then.
DEFPACT_DECL = re.compile(r'\(defpact\s+([A-Za-z0-9|_-]+)')

# Every defpact has a SINGLE-TRANSACTION twin with a byte-identical parameter list (verified, all
# ten). Owner ruling 2026-09-15 (memories/2026-09-15-gas-station-cannot-whitelist-continuations):
# multi-step only ever existed because the block gas limit was 150k; at 2,000,000 the whole worst
# case fits in one transaction (measured 415,419 gas, 21% of budget), and the defpact paths are
# kept for historical/learning purposes only. So the registry names the twin rather than leaving a
# consumer to discover the continuation machinery it does not need.
# PREVIEW PAIRING EXCEPTIONS. The automatic rule matches CATEGORY + ACTION out of
# `CATEGORY|C_Action` against `INFO_CATEGORY|Action`. Ten user-facing entrypoints have a preview
# that EXISTS but does not fit that shape, so they silently shipped with no cost preview at all --
# every launchpad purchase and both wrap/unwrap pairs. A UI cannot show a price before signing for
# any of them, which is precisely the drift this registry was built to surface.
#
# These are listed rather than matched by a looser rule ON PURPOSE. Loosening the matcher to catch
# them would risk pairing an entrypoint with the WRONG preview, and a wrong price shown to a user
# before they sign is worse than no price. Every pairing below was checked parameter by parameter.
#
# Three distinct causes, all real:
#   1. CITIZEN SALES put the preview on the sale module and drop the `CATEGORY|` segment --
#      `DEMIPAD-SPARK.INFO_BuySparks`, not `INFO_SPARK|BuySparks`. The module name IS the category.
#   2. CATEGORY ALIAS -- Talos says `LQD|`, the preview says `LIQUID|`.
#   3. SPELLING -- `C_Redem…` against `INFO_Redeem…`, and All/Few share one preview.
# A PRICED client entrypoint with no cost preview is a defect, and one that nothing caught until
# 2026-09-26. `DPTF|C_ClearDispoForeign` was created on 2026-09-21 by the patron/executor sweep
# SPLITTING `DPTF|C_ClearDispo (patron account)` into a self variant and a foreign one. The sweep
# added the new entrypoint AND its 51.0 price in the same commit -- but the `INFO_` readers live
# in a different file (`Z_Reads/02_INFO-ONE+.pact`) which that commit never touched, and nothing
# compared the two. It shipped to mainnet priced and unpreviewable.
#
# Everything about that is repeatable: splitting an entrypoint is routine, the price table and the
# INFO readers are always in different files, and the symptom (a UI that cannot quote a price) only
# appears when someone finally wires the new variant. So the check is mechanical from here.
#
# An entry below is a KNOWN, REASONED exemption. EMPTY IS THE GOAL, and it is currently empty:
# the one entry this table ever held (`DPTF|C_ClearDispoForeign`, awaiting PureV2/20) was removed
# on 2026-09-26 when the deploy landed and the check itself reported the exemption stale. That is
# the design -- an exemption that outlives its cause fails the gate rather than lingering.
PREVIEW_EXEMPT = {}

PREVIEW_ALIAS = {
    # 1. citizen sales
    "TS02-CPAD.SPARK|C_BuySparks":       "DEMIPAD-SPARK.INFO_BuySparks",
    "TS02-CPAD.SNAKES|C_Acquire":        "DEMIPAD-SNAKES.INFO_Acquire",
    "TS02-CPAD.CUSTODIANS|C_Acquire":    "DEMIPAD-CUSTODIANS.INFO_Acquire",
    "TS02-CPAD.STOAICO|C_Collect":       "STOAICO.INFO_Collect",
    # 3. spelling; both share one preview, which takes the quantity explicitly -- so for the
    #    "All" variant the client must first read the holding to price it.
    "TS02-CPAD.SPARK|C_RedemAllSparks":  "DEMIPAD-SPARK.INFO_RedeemSparks",
    "TS02-CPAD.SPARK|C_RedemFewSparks":  "DEMIPAD-SPARK.INFO_RedeemSparks",
    # category alias KPAY -> STOICPAY
    "TS02-CPAD.KPAY|C_BuyStoicPay":      "DEMIPAD-STOICPAY.INFO_BuyStoicPay",
    # the MTX previews drop the pipe before the action: `INFO_AQP-MTX|2Inject`, not
    # `INFO_AQP-MTX|2|Inject`. Module segment is reversed too (MTX-AQP vs AQP-MTX).
    "TS02-C3.MTX-AQP|2|CC_Inject":            "AQP-INFO.INFO_AQP-MTX|2Inject",
    "TS02-C3.MTX-AQP|2|CC_SweepRevokeAnchor": "AQP-INFO.INFO_AQP-MTX|2SweepRevokeAnchor",
    # CORE twins. Not client-callable (behind P|UEV_IMC, and the gas station only funds
    # `ouronet-ns.TS…` code) but they share the Talos entrypoint's preview, and leaving them
    # blank with no reason is the same silent gap this table exists to close.
    "ATS.HOT-RBT|C_Repurpose":             "INFO-ONE.INFO_ATS|HOT-RBT|Repurpose",
    "ATS.HOT-RBT|C_UpdatePendingBranding": "INFO-ONE.INFO_ATS|HOT-RBT|UpdatePendingBranding",
    "ATS.HOT-RBT|C_UpgradeBranding":       "INFO-ONE.INFO_ATS|HOT-RBT|UpgradeBranding",
    "SWPLC.STOA-PID|C_AddFrozenLiquidity":   "INFO-ONE.INFO_SWP|AddFrozenLiquidity",
    "SWPLC.STOA-PID|C_AddGlacialLiquidity":  "INFO-ONE.INFO_SWP|AddGlacialLiquidity",
    "SWPLC.STOA-PID|C_AddIcedLiquidity":     "INFO-ONE.INFO_SWP|AddIcedLiquidity",
    "SWPLC.STOA-PID|C_AddSleepingLiquidity": "INFO-ONE.INFO_SWP|AddSleepingLiquidity",
    "SWPLC.STOA-PID|C_AddStandardLiquidity": "INFO-ONE.INFO_SWP|AddStandardLiquidity",
    # 2. category alias LQD -> LIQUID. `executor` is named `wrapper`/`unwrapper` in the preview:
    #    same slot, same type, positional rename only.
    "TS01-C2.LQD|C_WrapStoa":            "INFO-ONE.INFO_LIQUID|WrapStoa",
    "TS01-C2.LQD|C_WrapUrStoa":          "INFO-ONE.INFO_LIQUID|WrapUrStoa",
    "TS01-C2.LQD|C_UnwrapStoa":          "INFO-ONE.INFO_LIQUID|UnwrapStoa",
    "TS01-C2.LQD|C_UnwrapUrStoa":        "INFO-ONE.INFO_LIQUID|UnwrapUrStoa",
}

DEFPACT_ALTERNATIVE = {
    "TS01-CP.SWP|C_AddFrozenLiquidity":        "TS01-C3.SWP|C_AddFrozenLiquidity",
    "TS01-CP.SWP|C_AddGlacialLiquidity":       "TS01-C3.SWP|C_AddGlacialLiquidity",
    "TS01-CP.SWP|C_AddIcedLiquidity":          "TS01-C3.SWP|C_AddIcedLiquidity",
    "TS01-CP.SWP|C_AddSleepingLiquidity":      "TS01-C3.SWP|C_AddSleepingLiquidity",
    "TS01-CP.SWP|C_AddStandardLiquidity":      "TS01-C3.SWP|C_AddLiquidity",
    "TS01-CP.SWP|C_IssueStablePool":           "TS01-C3.SWP|C_IssueStable",
    "TS01-CP.SWP|C_IssueStandardPool":         "TS01-C3.SWP|C_IssueStandard",
    "TS01-CP.SWP|C_IssueWeightedPool":         "TS01-C3.SWP|C_IssueWeighted",
    "TS02-C3.MTX-AQP|2|CC_Inject":             "TS02-C3.AQP-FVT|CC_Inject",
    "TS02-C3.MTX-AQP|2|CC_SweepRevokeAnchor":  "TS02-C3.AQP-FVT|CC_SweepRevokeAnchor",
}
STEP = re.compile(r'\(step(?:-with-rollback)?[\s(]')

RECIPE = re.compile(r'\|C{1,2}p_')
PAGER_PARAM = re.compile(r'^(chunk|page|size|limit|batch)(-size)?$')
HEAVY_RETURNS = {}
SCHEMAS = {}

# Named preflight per recipe. The typed ones are resolved by type (a param's type IS the read's
# return type); the pagers take a bare `chunk:integer`, which names nothing, so those three are
# listed. Anything not covered is emitted with preflightUnresolved rather than guessed.
PAGER_PREFLIGHT = {
    "AQP-FVT|CCp_SweepRecomputeChunk": ["AQP-FVT.UR_FVT|SweepProgress", "AQP-FVT.UR_FVT|SweepActive"],
    "AQP-FVT|CCp_InjectFixChunk":      ["AQP-FVT.URH_FvtStalePresentUsers"],
    "AQP-FVT|CCp_UnstaleAll":          ["AQP-FVT.URH_FvtStalePresentUsers"],
}
SLICE_PLANNER = {
    "RemovableNonces": ["URHC_BuildWipeSlicePlan", "UCv_TakePureWipe"],
}
LEG_PREFLIGHT = {
    "AQP-POOL|CCp_BatchVacateTrueFungible":  ["AQP-VCT.URH_VacateTrueFungiblePoolLegs", "AQP-VCT.URHC_BuildVacateSlicePlan"],
    "AQP-POOL|CCp_BatchVacateOrtoFungible":  ["AQP-VCT.URH_VacateOrtoFungiblePoolLegs", "AQP-VCT.URHC_BuildVacateSlicePlan"],
    "AQP-POOL|CCp_BatchVacateCollectables":  ["AQP-VCT.URH_VacateCollectablesPoolLegs", "AQP-VCT.URHC_BuildVacateSlicePlan"],
    "AQP-POOL|CCp_BatchDrainTrueFungible":   ["AQP-VCT.URH_VacateTrueFungiblePoolLegs"],
    "AQP-POOL|CCp_BatchDrainOrtoFungible":   ["AQP-VCT.URH_VacateOrtoFungiblePoolLegs"],
    "AQP-POOL|CCp_BatchDrainCollectable":    ["AQP-VCT.URH_VacateCollectablesPoolLegs"],
}


def rpc(code, gas=10_000_000):
    cmd = json.dumps({
        "networkId": "stoa", "payload": {"exec": {"data": {}, "code": code}}, "signers": [],
        "meta": {"gasLimit": gas, "chainId": "0", "gasPrice": 1e-8, "sender": "",
                 "ttl": 600, "creationTime": int(time.time()) - 60},
        "nonce": str(time.time())}, separators=(",", ":"))
    digest = hashlib.blake2b(cmd.encode(), digest_size=32).digest()
    body = json.dumps({"cmd": cmd,
                       "hash": base64.urlsafe_b64encode(digest).decode().rstrip("="),
                       "sigs": []}).encode()
    req = urllib.request.Request(NODE, data=body, headers={"Content-Type": "application/json"})
    # RETRY transient transport failures. A probe walks every module over several minutes, and a
    # single DNS blip used to abort the whole run and leave the previous artefact in place -- the
    # worst outcome, because the run LOOKS like it failed loudly while the stale file stays
    # committed. Only transport errors are retried; a node that answers with a Pact failure is a
    # real answer and is returned as such.
    for attempt in range(4):
        try:
            result = json.load(urllib.request.urlopen(req, timeout=60)).get("result", {})
            break
        except (urllib.error.URLError, TimeoutError, ConnectionError) as e:
            if attempt == 3:
                raise
            print(f"    transport retry {attempt + 1}/3 ({e})")
            time.sleep(3 * (attempt + 1))
    return result.get("data") if result.get("status") == "success" else None


def params_at(text, idx):
    i = text.index("(", idx)
    depth, j = 0, i
    while j < len(text):
        if text[j] == "(":
            depth += 1
        elif text[j] == ")":
            depth -= 1
            if depth == 0:
                break
        j += 1
    return [{"name": m.group(1), "type": m.group(2)}
            for m in re.finditer(r'([a-z][A-Za-z0-9-]*)\s*:\s*([A-Za-z0-9\[\]{}.|_-]+)',
                                 text[i:j + 1])]


def functions_in(code):
    """{name: params} for every entrypoint and preview in one module's source."""
    out = {}
    for d in re.finditer(r'\n\s{1,8}\(defun\s+([^\s:(]+)', code):
        name = d.group(1)
        if ENTRYPOINT.match(name) or PREVIEW.match(name):
            out.setdefault(name, params_at(code, d.end()))
    return out


def returns_in(code):
    """{name: declared return type} -- absent when the defun declares none.

    Params alone do not tell a consumer what comes BACK. Talos clients mostly return a formatted
    `string` describing the branch taken (CLAUDE.md, "Talos client output"), some return an
    `OutputCumulator`, and a large number declare nothing at all -- which is itself the answer a
    consumer needs, since it means the shape is not pinned by the signature.
    """
    out = {}
    for d in re.finditer(r'\n\s{1,8}\(defun\s+([^\s:(]+):([A-Za-z0-9\[\]{}.|_-]+)', code):
        if ENTRYPOINT.match(d.group(1)) or PREVIEW.match(d.group(1)):
            out.setdefault(d.group(1), d.group(2))
    return out


def repo_modules():
    """{module: (source, relpath)} for every module in the tree."""
    out = {}
    for base, _d, files in os.walk(ROOT):
        if os.sep + "Deploy" in base or os.sep + "REPL" in base:
            continue
        for fn in files:
            if not fn.endswith(".pact"):
                continue
            path = os.path.join(base, fn)
            text = io.open(path, encoding="utf8", errors="replace").read()
            for m in re.finditer(r'^\(module\s+([A-Za-z0-9|_-]+)\s', text, re.M):
                out.setdefault(m.group(1), (text[m.start():], os.path.relpath(path, ROOT)))
    return out


def scan_schemas(repo):
    """{schema-name: [(field, type), ...]} for every defschema in the tree.

    Object parameters are 83 of the 2,182 slots and no name/type dictionary can cover them --
    an `object{DPDC|NonceData}` ghost has to have the right FIELDS or it teaches the wrong
    shape. The fields are already written down in the contract, so they are read rather than
    authored.
    """
    # WHOLE FILES, not repo_modules(). That helper slices from `(module `, and most schemas a
    # client actually passes are declared in the INTERFACE above it -- `SwapperV4.PoolTokens`,
    # `SwapperUsageV3.Slippage`, the whole `DpdcUdcV2` family. Scanning module-onward found 72
    # of 201 and silently produced no ghost for exactly the object parameters this exists for.
    out = {}
    for base, _d, files in os.walk(ROOT):
        if os.sep + "Deploy" in base or os.sep + "REPL" in base:
            continue
        for fn in files:
            if not fn.endswith(".pact"):
                continue
            src = strip_code(io.open(os.path.join(base, fn), encoding="utf8",
                                     errors="replace").read())
            for m in re.finditer(r'\(defschema\s+([A-Za-z0-9|_-]+)', src):
                body = src[m.start():balanced_at(src, m.start())]
                fields = re.findall(r'^\s+([a-z][A-Za-z0-9|_-]*):(\[?[A-Za-z0-9{}.|_-]+\]?)',
                                    body, re.M)
                if fields:
                    out.setdefault(m.group(1), fields)
    return out


def ghost_fits(v, t):
    """Does this ghost value match the DECLARED type?

    The dictionary is keyed by parameter NAME, which is what makes it authorable -- but a name
    does not pin a type. `ats` is a bare id on most entrypoints and `[string]` on ATS|C_Issue;
    `method` is a string in one place and a bool in another. Applying the name entry blindly
    produced values the Pact formatter then refused, which the package's build-every-ghost test
    caught 23 times. So a name hit that does not fit falls through to the type layer.
    """
    t = t.strip()
    if t.startswith("[") and t.endswith("]"):
        return isinstance(v, list) and all(ghost_fits(x, t[1:-1]) for x in v)
    if t == "string":
        return isinstance(v, str)
    if t == "integer":
        return isinstance(v, int) and not isinstance(v, bool)
    if t == "decimal":
        return isinstance(v, (int, float)) and not isinstance(v, bool)
    if t == "bool":
        return isinstance(v, bool)
    if t == "object" or t.startswith("object{") or t == "guard":
        return isinstance(v, dict)
    return True


def ghost_for_type(t, by_type, schemas, depth=0):
    """A ghost value for a declared type, recursing into object schemas. None if unknown."""
    if t in by_type:
        return by_type[t]["v"]
    listed = t.startswith("[") and t.endswith("]")
    inner = t[1:-1] if listed else t
    if listed and inner.startswith("["):
        v = ghost_for_type(inner, by_type, schemas, depth + 1)
        return None if v is None else [v]
    m = re.match(r'object\{([A-Za-z0-9._|-]+)\}', inner)
    if not m or depth > 4:
        return None
    fields = schemas.get(m.group(1).split(".")[-1])
    if fields is None:
        return None
    obj = {}
    for fname, ftype in fields:
        v = ghost_for_type(ftype, by_type, schemas, depth + 1)
        obj[fname] = v if v is not None else None
    return [obj] if listed else obj


def scan_defpacts(repo):
    """{module.defun: {"pact":name,"steps":n,"rollback":n}} for every defun that STARTS a defpact.

    Two hops, because the Talos entrypoint does not call the defpact directly: the core module
    wraps each `defpact MTX|C_Issue` in a plain `defun C_IssueStablePool`, and Talos calls the
    wrapper. Matching defpact NAMES against Talos bodies therefore finds nothing -- the first
    attempt at this returned 0 of 14.
    """
    starters = {}
    for mod, (raw, _rel) in repo.items():
        src = strip_code(raw)
        names = set(DEFPACT_DECL.findall(src))
        if not names:
            continue
        info = {}
        for m in DEFPACT_DECL.finditer(src):
            body = src[m.start():balanced_at(src, m.start())]
            info[m.group(1)] = {"steps": len(STEP.findall(body)),
                                "rollback": len(re.findall(r'\(step-with-rollback[\s(]', body))}
        for m in re.finditer(r'^\s{4}\(defun\s+([A-Za-z0-9|_-]+)[\s:(]', src, re.M):
            body = src[m.start():balanced_at(src, m.start())]
            for n in names:
                if re.search(r'\(' + re.escape(n) + r'[\s)]', body):
                    starters["%s.%s" % (mod, m.group(1))] = dict(info[n], pact=n)
                    break
    return starters


def balanced_at(s, i):
    """End index (exclusive) of the balanced form whose `(` is at or after i."""
    j = s.index("(", i)
    d = 0
    while j < len(s):
        if s[j] == "(":
            d += 1
        elif s[j] == ")":
            d -= 1
            if d == 0:
                return j + 1
        j += 1
    return len(s)


def scan_heavy_returns(repo):
    """{schema-name: {reader, ...}} for every type a HEAVY read returns.

    Derived, never listed. A heavy read (`URH_`/`URHC_`/`URD_`) is by definition a scan, so its
    return value is something no caller can construct -- which makes it the exact marker for
    "this parameter came from a preflight read, not from the user".
    """
    out = {}
    for mod, (src, _rel) in repo.items():
        for m in HEAVY_RETURN.finditer(src):
            # Indexed by the FULL type, interface qualifier included, and by the short name
            # only as a fallback. `RemovableNonces` is TWO different schemas --
            # `DpofUdcV2.RemovableNonces` and `DpdcManagementV2.RemovableNonces` -- and both are
            # returned by a reader called `URHC_WipePure`. Keying on the short name alone made
            # every wipe entrypoint cite both readers, which is worse than citing none: a
            # consumer that picks the wrong one calls a reader with the wrong arity (the DPDC
            # one takes `son`) against the wrong module's tables.
            reader = "%s.%s%s" % (mod, m.group(1), m.group(2))
            out.setdefault(m.group(3), set()).add(reader)
            out.setdefault(m.group(3).split(".")[-1], set()).add(reader)
    return out


def check_client_assembled(repo):
    """CLIENT_ASSEMBLED is the one non-derived list here, so verify each entry still earns it.

    An entry is legitimate only while NO on-chain read returns the type -- the moment one does,
    scan_heavy_returns covers it and the manual entry is stale duplication. Returns complaints.
    """
    bad = []
    for t in CLIENT_ASSEMBLED:
        for src, rel in repo.values():
            # `UR` family ONLY. A `UC_` is pure compute on arguments (prefix table: "no table
            # reads"), so `UC_FindStoaPath` reshapes paths the client already holds -- it is not
            # a source of chain data, and counting it flagged CachedPathOrMiss as a false stale.
            if re.search(r'\(defun\s+UR[A-Za-z]*_[A-Za-z0-9|_-]+:\[?object\{[A-Za-z0-9._|-]*'
                         + re.escape(t) + r'\}', src):
                bad.append("%s: now returned by a read in %s -- drop the manual entry" % (t, rel))
                break
        else:
            if not any(t in src for src, _ in repo.values()):
                bad.append("%s: no longer present in the tree" % t)
    return bad


def ownership_map():
    """entrypoint -> the PARAMETERS whose ownership is enforced in its call tree.

    `_authsurface.py` already computes this. Its cell mixes parameter names with the readers
    used to derive them (`UR_OwnerKonto`, `DALOS|SC_NAME`) and with `name:type` forms, so it is
    filtered against the real parameter list by the caller -- an unfiltered list would tell a
    consumer to prove ownership of a function name.
    """
    out = {}
    if not os.path.exists(AUTH_SURFACE):
        return out
    for line in io.open(AUTH_SURFACE, encoding="utf8"):
        m = re.match(r'\|\s*`[^`]+`\s*\|\s*`([^`]+)`\s*\|\s*(.+?)\s*\|\s*$', line)
        if m:
            out[m.group(1)] = {t.strip(" `") for t in m.group(2).split(",")}
    return out


MODREF_BIND = re.compile(r'\(ref-([A-Za-z0-9|_-]+):module\{[^}]*\}\s+([A-Za-z0-9|_-]+)\)')


def delegates_of(entry_src, fn):
    """Modules this entrypoint calls into, with modref ALIASES resolved.

    Talos binds a modref under a LOCAL name -- `(ref-SPARK:module{...} DEMIPAD-SPARK)` and then
    calls `ref-SPARK::C_BuySparks`. Matching `ref-DEMIPAD-SPARK::` finds nothing, which is how a
    first pass at this reported every module as calling nobody.
    """
    m = re.search(r'^\s*\(defun\s+' + re.escape(fn) + r'[\s:(]', entry_src, re.M)
    if not m:
        return []
    body = entry_src[m.start():balanced_at(entry_src, m.start())]
    alias = {a.group(1): a.group(2) for a in MODREF_BIND.finditer(body)}
    out = []
    for c in re.finditer(r'\(ref-([A-Za-z0-9|_-]+)::', body):
        if c.group(1) in alias and alias[c.group(1)] not in out:
            out.append(alias[c.group(1)])
    return out


def caps_reads(source):
    """Reads in this module that return external capability descriptions."""
    found = []
    for m in CAPS_READ.finditer(source):
        tail = source[m.end():m.end() + 700]
        if "coin.TRANSFER" in tail or re.search(r'cap(abilit(y|ies))?', tail, re.I):
            found.append(m.group(1))
    return found


def build(probe):
    repo = repo_modules()
    owners = ownership_map()
    deployed_src = {}
    global HEAVY_RETURNS, SCHEMAS
    HEAVY_RETURNS = scan_heavy_returns(repo)
    SCHEMAS = scan_schemas(repo)
    for complaint in check_client_assembled(repo):
        print("  CLIENT_ASSEMBLED stale -- " + complaint)
    entries, previews, divergences, unreachable = {}, {}, [], []
    chosen_src = {}

    # structured authorisation surface, computed ONCE and IMPORTED rather than read from a
    # sidecar artefact -- a second generated file is a second thing that can go stale silently.
    _adefs, _amod = auth_collect()
    AUTH_STRUCT = {k[1]: surface_structured(k, _adefs, _amod, set(), 0)
                   for k in sorted(_adefs) if AUTH_ENTRY.match(k[1])}

    for module, (repo_src, relpath) in sorted(repo.items()):
        live_src, module_hash, source = None, None, "repo-only"
        if probe:
            described = rpc(f'(describe-module "ouronet-ns.{module}")')
            if isinstance(described, dict) and described.get("code"):
                live_src, module_hash, source = described["code"], described.get("hash"), "deployed"
                deployed_src[module] = live_src

        chosen = live_src or repo_src
        chosen_src[module] = chosen
        fns = functions_in(chosen)
        if not fns:
            continue
        if source == "repo-only" and probe:
            unreachable.append(module)

        # DIVERGENCE is recorded, never silently resolved. A deployed module whose source has
        # moved on is exactly the state that produced `kadena-konto` and the missing tables.
        if live_src:
            a, b = functions_in(live_src), functions_in(repo_src)
            for name in sorted(set(a) | set(b)):
                if a.get(name) != b.get(name):
                    divergences.append({
                        "module": module, "function": name,
                        "deployed": a.get(name), "repo": b.get(name),
                    })

        rets = returns_in(chosen)
        for name, params in sorted(fns.items()):
            key = f"{module}.{name}"
            record = {"params": params, "returns": rets.get(name), "source": source,
                      "modulePath": relpath}
            if record["returns"] is None:
                record["returnsNote"] = ("the defun declares no return type; the shape is not "
                                         "pinned by the signature")
            if module_hash:
                record["moduleHash"] = module_hash
            if source == "repo-only":
                record["callable"] = False
                record["note"] = ("not callable -- no live code deployed yet; the shape of a "
                                  "work-in-progress function")
            if PREVIEW.match(name):
                previews[key] = record
                continue
            # OWNERSHIP -- whose key the caller must be able to sign for.
            #
            # From `_authsurface.surface_structured`, which walks the whole call tree and reads
            # the FULL argument every `CAP_EnforceAccountOwnership` was given. Two shapes, and a
            # consumer must tell them apart:
            #     a bare name          -> that parameter IS the account
            #     `(UR_OwnerKonto x)`  -> the account is what the READER returns for entity `x`
            # The previous version captured only the first identifier after the cap, so
            # `(UR_OwnerKonto swpair)` yielded `UR_OwnerKonto`; intersecting that with the
            # parameter list produced `["patron", "swpair"]`, naming a POOL ID as an account --
            # and nobody holds the key to a pool.
            #
            # ONLY `CAP_EnforceAccountOwnership` counts. The seven sibling `CAP_*Owner` wrappers
            # take an ENTITY and resolve the owner themselves (`CAP_Owner swpair` ->
            # `CAP_EnforceAccountOwnership (UR_OwnerKonto swpair)`), and the walk reaches through
            # them, so counting the wrappers too would re-report the entity as an account. Every
            # wrapper was checked to bottom out here.
            own_rows = AUTH_STRUCT.get(name, [])
            pnames = {pp["name"] for pp in params}
            requires, unmapped = [], []
            for row in own_rows:
                subj = row.get("subject")
                if subj and subj in pnames:
                    if row["kind"] == "parameter":
                        item = {"account": subj, "via": "parameter",
                                "meaning": "the caller must hold the key for the account passed "
                                           "as `%s`" % subj}
                    else:
                        item = {"account": "owner of `%s`" % subj, "via": "reader",
                                "reader": row["reader"], "subject": subj,
                                "meaning": "`%s` is an ENTITY id, NOT an account. Read `%s` with "
                                           "it to get the account whose key is required"
                                           % (subj, row["reader"])}
                    # ALWAYS vs SOMETIMES. An enforce inside an `if`/`cond`/`enforce-one` binds
                    # on one path only, and flattening that away is actively misleading: on
                    # `UEV_Patron`'s sponsored branch the GAS STATION signs and the caller needs
                    # no patron key at all, while the self-pay branch needs exactly that.
                    if row.get("conditional"):
                        item["when"] = "CONDITIONAL"
                        item["conditionalOn"] = ("reached inside an `%s`, so it binds on one "
                                                 "path and not the other -- do not read it as "
                                                 "an unconditional requirement"
                                                 % row["conditional"])
                    else:
                        item["when"] = "ALWAYS"
                    if item not in requires:
                        requires.append(item)
                elif subj and subj not in unmapped:
                    unmapped.append(subj)
            if requires:
                record["ownership"] = {"resolved": True, "requires": requires}
                if unmapped:
                    record["ownership"]["unmapped"] = sorted(unmapped)
                    record["ownership"]["unmappedNote"] = (
                        "enforces reached DEEPER in the tree whose subject is named for that "
                        "callee's parameter rather than this entrypoint's. Mapping them back "
                        "needs argument threading, which is not done -- so they are listed, not "
                        "guessed.")
            else:
                record["ownership"] = {
                    "resolved": False,
                    "reason": ("no ownership enforce in the call tree resolves to one of this "
                               "entrypoint's own parameters" if own_rows else
                               "the call tree reaches no ownership enforce at all"),
                    "unmapped": sorted(unmapped) or None,
                }
            # sponsorship: a Talos client entrypoint is the gas-funded path, by definition
            record["sponsorship"] = {
                "sponsored": module.startswith("TS0"),
                "sponsor": "Ouronet gas station" if module.startswith("TS0") else None,
                "cap": "ouronet-ns.DALOS.GAS_PAYER" if module.startswith("TS0") else None,
                "capArgs": [{"name": "user", "type": "string"},
                            {"name": "limit", "type": "integer"},
                            {"name": "price", "type": "decimal"}] if module.startswith("TS0") else [],
                "suppliedBy": ("a signer on the caps key, alongside the guard public keys"
                               if module.startswith("TS0") else None),
                "conditional": ("GAS_PAYER inspects `exec-code` from the message, so sponsorship "
                                "depends on what the transaction actually contains"
                                if module.startswith("TS0") else None),
            }
            # execution mode -- see HEAVY_RETURN / RECIPE above
            fed = []
            for prm in params:
                full = prm["type"].rstrip("}").lstrip("[").replace("object{", "")
                t = full.split(".")[-1]
                src = None
                # exact type first -- the qualifier is what tells the two RemovableNonces apart
                if full in HEAVY_RETURNS:
                    src = sorted(HEAVY_RETURNS[full])
                elif t in HEAVY_RETURNS:
                    src = sorted(HEAVY_RETURNS[t])
                elif t in CLIENT_ASSEMBLED:
                    src = ["<assembled client-side: %s>" % CLIENT_ASSEMBLED[t]]
                if src:
                    # the slicer lives in the SAME module as the producer, so qualify it from
                    # there rather than repeating the module in the table
                    mods = {q.split(".")[0] for q in src if "." in q and not q.startswith("<")}
                    sl = SLICE_PLANNER.get(t)
                    fed.append({"param": prm["name"], "type": t, "producedBy": src,
                                "slicedBy": sorted("%s.%s" % (mm, f) for mm in mods
                                                   for f in sl) if sl and mods else sl})
            short = name.split(".", 1)[-1]
            pager = RECIPE.search(name) and any(
                PAGER_PARAM.match(prm["name"]) and prm["type"] == "integer" for prm in params)

            if pager:
                pre = PAGER_PREFLIGHT.get(short)
                record["execution"] = {
                    "mode": "indirect-sequential", "shape": "cursor pager",
                    "preflight": pre,
                    "note": "a preflight read reports progress; each call takes a SIZE and "
                            "advances a stored cursor, so the calls are STRICTLY ORDERED. Firing "
                            "them concurrently races the cursor -- repeat until the report says "
                            "done",
                }
                if pre is None:
                    record["execution"]["preflightUnresolved"] = True
            elif RECIPE.search(name):
                pre = LEG_PREFLIGHT.get(short) or sorted(
                    {q for f in fed for q in f["producedBy"]}) or None
                record["execution"] = {
                    "mode": "indirect-parallel", "shape": "fed slice",
                    "preflight": pre, "fedParams": fed or None,
                    "note": "a preflight read is cut into slices, each fed to its own "
                            "transaction. Order-independent, so the slices MAY be submitted in "
                            "parallel",
                }
                if pre is None:
                    record["execution"]["preflightUnresolved"] = True
            elif fed:
                record["execution"] = {
                    "mode": "indirect-single", "shape": "dirty-read injection",
                    "preflight": sorted({q for f in fed for q in f["producedBy"]}),
                    "fedParams": fed,
                    "note": "ONE transaction, but the client must run the read first and inject "
                            "its result -- these params cannot be built from user input. Where "
                            "the injected value is a swap route it carries TOPOLOGY ONLY, never "
                            "amounts: the contract recomputes every figure from live reserves "
                            "and validates the route structurally before using it",
                }
            else:
                record["execution"] = {
                    "mode": "direct",
                    "note": "the provided inputs suffice; nothing is read off-chain first",
                }
            entries[key] = record

    # pair each entrypoint with its preview, by CATEGORY and ACTION. They live in different
    # modules by design, and assuming they share one is how codex ended up calling INFO-ZERO
    # for previews that live on INFO-ONE.
    by_action = {}
    for key in previews:
        mod, fn = key.split(".", 1)
        m = re.match(r'^INFO_([A-Za-z0-9|_-]+)\|(.+)$', fn)
        if m:
            by_action[(m.group(1), m.group(2))] = key
    for key, record in entries.items():
        mod, fn = key.split(".", 1)
        m = re.match(r'^([A-Za-z0-9|_-]+)\|C{1,2}p?_(.+)$', fn)
        if m:
            hit = by_action.get((m.group(1), m.group(2)))
            if hit:
                record["preview"] = hit

    # DEFPACT STARTERS -- a post-pass, so it reads the same authoritative source everything else
    # does (deployed where deployed, repo otherwise) rather than the repo copy alone.
    starters = scan_defpacts({m: (src, "") for m, src in chosen_src.items()})
    stripped = {m: strip_code(src) for m, src in chosen_src.items()}
    for key, rec in entries.items():
        mod, fn = key.split(".", 1)
        src = stripped.get(mod, "")
        m = re.search(r'^\s*\(defun\s+' + re.escape(fn) + r'[\s:(]', src, re.M)
        if not m:
            continue
        body = src[m.start():balanced_at(src, m.start())]
        for sk, info in starters.items():
            smod, sfn = sk.split(".", 1)
            if re.search(r'ref-' + re.escape(smod) + r'::' + re.escape(sfn) + r'[\s)]', body):
                prior = rec["execution"]["mode"]
                rec["execution"] = {
                    "mode": "defpact",
                    "shape": "continuation",
                    "inputs": prior,
                    "pact": "%s.%s" % (smod, info["pact"]),
                    "steps": info["steps"],
                    "rollbackSteps": info["rollback"],
                    "note": ("MULTI-TRANSACTION by continuation. Step 0 runs on submit; the "
                             "remaining %d advance with `continue-pact`, which is a `cont` "
                             "payload against the same pact id -- NOT a fresh `exec`. Submitting "
                             "once and reporting success leaves the operation half-finished. "
                             "Chain-ordered, so never parallel. `inputs` says whether the step-0 "
                             "arguments themselves need a preflight."
                             % (info["steps"] - 1)),
                    "continuation": {
                        "payload": "cont",
                        "pactId": "returned by the step-0 transaction result "
                                  "(`continuation.pactId`); it is NOT derivable in advance",
                        "step": "0-based index of the step to RUN next -- after step 0 succeeds, "
                                "send step 1",
                        "rollback": "false to advance. Send true ONLY to unwind a "
                                    "step-with-rollback; this entry has %d of them"
                                    % info["rollback"],
                        "data": {},
                        "dataNote": "EMPTY. Neither MTX module calls `read-msg` anywhere, so no "
                                    "step takes client input -- state moves between steps by "
                                    "`yield`/`resume` inside the contract. Verified by scanning "
                                    "both modules for every read-msg/read-integer/read-decimal/"
                                    "read-string form: zero hits.",
                        "gas": "PAID BY THE CUSTOMER ACCOUNT, NOT THE GAS STATION. This is the "
                               "one thing that surprises people. Chainweb injects `exec-code` "
                               "only for `exec` payloads; a `cont` payload is "
                               "{pactId, step, rollback, data, proof} and carries none. "
                               "DALOS.GAS_PAYER binds `(at \"exec-code\" (read-msg))` EAGERLY in "
                               "its opening `let`, so on a continuation it raises "
                               "`Key \"exec-code\" not found` before any of its checks run. "
                               "Step 0 is sponsored; every later step is not.",
                    },
                }
                alt = DEFPACT_ALTERNATIVE.get(key)
                if alt:
                    rec["execution"]["supported"] = False
                    rec["execution"]["preferInstead"] = alt
                    rec["execution"]["supportedNote"] = (
                        "NOT the supported route (owner ruling 2026-09-15). `%s` performs the "
                        "same operation in ONE transaction with a BYTE-IDENTICAL parameter list. "
                        "Multi-step existed only for the old 150k block gas limit; at 2,000,000 "
                        "the worst case measures 415,419 gas (21%%). Use the twin unless you are "
                        "deliberately exercising the defpact." % alt)
                # sponsorship is step-scoped here, and the generic field above is WRONG for it
                if rec.get("sponsorship", {}).get("sponsored"):
                    rec["sponsorship"]["sponsored"] = "step-0-only"
                    rec["sponsorship"]["stepsNote"] = (
                        "Step 0 is an `exec` and is sponsored normally. Continuations are `cont` "
                        "payloads with no `exec-code`, which DALOS.GAS_PAYER cannot evaluate -- "
                        "the CUSTOMER ACCOUNT pays for them. See execution.continuation.gas.")
                break

    # EXTERNAL CAPABILITIES, and the FORMULA that computes their arguments.
    #
    # Some operations need the caller to sign capabilities beyond the gas-station's GAS_PAYER --
    # the launchpad buys need `coin.TRANSFER` legs paying the sale contract. The amounts are NOT
    # something a client may compute: they depend on live price, the native-vs-wrapped split and
    # a slippage pad. So the contract ships a READER that returns the capability strings ready to
    # parse, and that reader IS the formula.
    #
    # It lives in the module the entrypoint DELEGATES to, never in the entrypoint's own module --
    # `TS02-CPAD.SPARK|C_BuySparks` against `DEMIPAD-SPARK.URC_Acquire`. The first version of this
    # looked in the entrypoint's module and therefore emitted the field ZERO times out of 423,
    # which read as "no operation needs extra capabilities" rather than as a failed lookup.
    for key, rec in entries.items():
        mod, fn = key.split(".", 1)
        src = stripped.get(mod, "")
        for target in delegates_of(src, fn):
            tsrc = chosen_src.get(target, "")
            readers = caps_reads(tsrc)
            if not readers:
                continue
            reader = readers[0]
            m = re.search(r'^\s*\(defun\s+' + re.escape(reader) + r'[\s:(]', tsrc, re.M)
            rparams = params_at(tsrc, m.end()) if m else []

            # CAN THIS ENTRYPOINT EVEN CALL THE READER? Finding a capability reader in the module
            # an entrypoint delegates to is NOT evidence that the reader is FOR that entrypoint.
            # DEMIPAD holds one and sixteen entrypoints delegate there, but twelve of them --
            # every Retrieve/Fuel/Withdraw -- cannot supply its arguments at all: they have no
            # `buyer`, no `buy-amount-in-dollarz`, no `type`. Emitting the field for them would
            # tell a consumer to sign transfer capabilities for an operation that takes no
            # payment, which is worse than saying nothing.
            #
            # The test is therefore whether the entrypoint can SUPPLY the reader's arguments.
            # `slippage` is exempt: it is the client's pad, deliberately not an entrypoint
            # argument. Names are matched loosely in one direction only (`sparks-amount` against
            # `amount`) because the citizen readers were written to mirror their entrypoint.
            def norm(n):
                return re.sub(r'[^a-z]', '', n.lower())
            own = {norm(pp["name"]): pp["name"] for pp in rec["params"]}
            argsFrom, missing = {}, []
            for rp in rparams:
                if rp["name"] == "slippage":
                    argsFrom[rp["name"]] = ("CLIENT-SUPPLIED -- the pad, not an entrypoint "
                                            "argument. 0.0 for exact caps; UI policy caps it at "
                                            "50. Keep it consistent with the entrypoint's own "
                                            "ceiling argument (max-cost), or the capability the "
                                            "user signs and the ceiling the contract enforces "
                                            "describe different amounts")
                    continue
                n = norm(rp["name"])
                hit = own.get(n) or next((v for kk, v in own.items() if n in kk or kk in n), None)
                if hit:
                    argsFrom[rp["name"]] = hit
                else:
                    missing.append(rp["name"])
            if missing:
                continue          # this reader is not this entrypoint's formula

            rec["externalCaps"] = {
                "required": True,
                "computedBy": f"{target}.{reader}",
                "readerParams": rparams,
                "argsFrom": argsFrom,
                "returns": "[string]",
                "format": '<(coin.TRANSFER "from" "to" <decimal>)>',
                "parse": "strip the surrounding < >, then read (NAME \"from\" \"to\" amount); "
                         "attach each as a capability with args [from, to, {decimal: amount}]",
                "attachTo": "the PAYER signer, alongside ouronet-ns.DALOS.GAS_PAYER",
                "note": "CALL THE READER -- do not recompute the amounts. They depend on live "
                        "price, the native/wrapped split and the slippage pad, so a client that "
                        "derives them itself signs a capability the contract will not match. "
                        "Prefer THIS reader over the sovereign DEMIPAD.URC_Acquire: it takes the "
                        "entrypoint's own arguments, where the sovereign one additionally needs "
                        "the asset id and the amount converted to dollars.",
            }
            rec["execution"]["capabilityPreflight"] = f"{target}.{reader}"
            break

    # Every preflight this registry CITES must exist in DEPLOYED code, not merely in the repo.
    # A cited reader that is repo-only is the worst possible entry: it reads as an instruction,
    # a consumer calls it, and the call fails as a RESOLUTION error -- which surfaces as a
    # default value rather than an error, so the recipe silently operates on an empty slice.
    if probe:
        missing = []
        for key, rec in entries.items():
            ex = rec.get("execution", {})
            cites = [q for q in (ex.get("preflight") or []) if not q.startswith("<")]
            cites += [q for f in (ex.get("fedParams") or []) for q in (f.get("slicedBy") or [])]
            # the capability formula is cited the same way and carries the same risk: a consumer
            # follows it, the call fails as a RESOLUTION error, and the caps come back empty --
            # so the transaction is submitted unfunded rather than refused
            if ex.get("capabilityPreflight"):
                cites.append(ex["capabilityPreflight"])
            for c in cites:
                mod, fn = c.split(".", 1)
                src = deployed_src.get(mod)
                if not src or not re.search(r'\(defun\s+' + re.escape(fn) + r'[:\s(]', src):
                    missing.append((key, c, "module not deployed" if not src else "no such defun"))
        if missing:
            print(f"  PREFLIGHT NOT ON CHAIN -- {len(missing)} citation(s):")
            for key, c, why in missing[:10]:
                print(f"      {key} -> {c} ({why})")
        else:
            n = sum(1 for r in entries.values()
                    if r.get("execution", {}).get("mode", "direct") != "direct")
            c = sum(1 for r in entries.values() if r.get("externalCaps"))
            print(f"  preflight: clean -- every reader cited by {n} indirect and {c} "
                  f"capability-bearing entrypoint(s) is present in deployed code")

    # apply the pairing exceptions, and FAIL LOUDLY on a stale one. A silently-dropped alias
    # would put the entrypoint straight back to having no preview, which is the bug being fixed.
    for ep, pv in PREVIEW_ALIAS.items():
        if ep not in entries:
            print(f"  PREVIEW_ALIAS stale -- no entrypoint {ep}")
        elif pv not in previews:
            print(f"  PREVIEW_ALIAS stale -- no preview {pv} (for {ep})")
        elif entries[ep].get("preview"):
            print(f"  PREVIEW_ALIAS redundant -- {ep} now pairs automatically; drop the entry")
        else:
            entries[ep]["preview"] = pv
            entries[ep]["previewVia"] = "alias (name does not fit CATEGORY|Action)"

    # An entrypoint with NO preview is either free or an oversight, and silence cannot tell the
    # two apart. `DPTF|C_ClearDispoForeign` is priced at 51.0 IGNIS in `02_IGNIS.pact:887` and
    # has no `INFO_` reader anywhere -- a gap in the CONTRACT, not in this pairing, and one a UI
    # hits as "cannot show the user what this costs before they sign".
    for key, rec in entries.items():
        if not rec.get("preview"):
            rec["previewMissing"] = ("no INFO_ reader exists for this operation. It IS priced "
                                     "(see IGNIS price table) -- a consumer cannot show its cost "
                                     "before signing. Contract-side gap, not a pairing failure.")

    # GHOST VALUES -- composed per entrypoint from a per-PARAMETER dictionary.
    #
    # Authoring one object per entrypoint would mean 423 of them, and writing the same account
    # into 416 `patron` slots by hand is how a fixture ends up wrong in one place and right
    # everywhere else. The 423 entrypoints have 2,182 parameter slots but only 276 distinct
    # NAMES, and four of those cover half -- so the dictionary is keyed by name, with a type
    # fallback, and each entrypoint's ghost is assembled from it.
    #
    # Resolution order, most specific first:
    #   1. OURONET-REGISTRY.authored.json  -- a hand-written whole-object override for ONE
    #      entrypoint. Always wins; that is the escape hatch for anything the dictionary cannot
    #      express.
    #   2. ghosts.byParam[<name>]          -- by parameter name
    #   3. ghosts.byType[<type>]           -- by declared type
    # Anything unresolved is NAMED, not filled with a plausible-looking blank.
    ghosts = {}
    if os.path.exists(GHOSTS):
        ghosts = json.load(io.open(GHOSTS, encoding="utf8"))
    by_param, by_type = ghosts.get("byParam", {}), ghosts.get("byType", {})
    for key, rec in entries.items():
        args, why, unresolved = {}, {}, []
        fed_names = {f["param"] for f in (rec["execution"].get("fedParams") or [])}
        for prm in rec["params"]:
            # A PREFLIGHT-FED PARAMETER GETS NO FAKE VALUE. Its whole point is that the client
            # cannot construct it -- inventing a plausible object here would contradict the
            # execution block two keys away and invite someone to submit it.
            if prm["name"] in fed_names:
                args[prm["name"]] = None
                why[prm["name"]] = ("DO NOT SYNTHESISE. Obtain it from the preflight named in "
                                    "`execution.preflight`; this parameter is the output of a "
                                    "read, not user input")
                continue
            hit = by_param.get(prm["name"])
            if hit is not None and not ghost_fits(hit["v"], prm["type"]):
                hit = None                      # right name, wrong type -- fall through
            if hit is None:
                hit = by_type.get(prm["type"])
            if hit is not None:
                args[prm["name"]] = hit["v"]
                if hit.get("why"):
                    why[prm["name"]] = hit["why"]
                continue
            derived = ghost_for_type(prm["type"], by_type, SCHEMAS)
            if derived is not None:
                args[prm["name"]] = derived
                why[prm["name"]] = ("shape DERIVED from the contract's own defschema, so the "
                                    "fields are right even though the values are placeholders")
                continue
            unresolved.append("%s:%s" % (prm["name"], prm["type"]))
        rec["ghost"] = {"args": args, "source": "composed from OURONET-REGISTRY.ghosts.json"}
        if why:
            rec["ghost"]["notes"] = why
        if unresolved:
            rec["ghost"]["unresolved"] = unresolved
            rec["ghost"]["unresolvedNote"] = (
                "no ghost for these -- add them to ghosts.json byParam. They are LISTED rather "
                "than filled, because a plausible-looking wrong example is worse than a gap: it "
                "gets copied.")
        rec["ghost"]["warning"] = (
            "ILLUSTRATIVE, NOT SUBMITTABLE. Every id was read from mainnet so the SHAPE is real, "
            "but the accounts are not yours to sign for and the amounts are placeholders.")

    # the hand-authored per-entrypoint layer WINS. Merged last, never generated, never lost.
    if os.path.exists(AUTHORED):
        for key, extra in json.load(io.open(AUTHORED, encoding="utf8")).get("ghost", {}).items():
            if key not in entries:
                continue
            # MERGE, never replace. An override that drops `args` leaves consumers with a ghost
            # that has no example call in it at all -- and the composed args are still the best
            # starting point for every parameter the override does not mention.
            g = entries[key]["ghost"]
            g["args"] = dict(g.get("args", {}), **(extra.get("args") or {}))
            for k2, v2 in extra.items():
                if k2 != "args":
                    g[k2] = v2
            g["source"] = ("composed, then overridden per-parameter by "
                           "OURONET-REGISTRY.authored.json")

    # NAME COLLISIONS. Entries are keyed MODULE.function, so the registry itself is unambiguous.
    # A consumer resolving by the BARE name is not, and that is the exact habit this registry
    # exists to break -- OuronetUI and the Codex package both hardcoded bare names. Four SWP
    # liquidity names resolve to two modules with IDENTICAL signatures and DIFFERENT execution
    # modes (TS01-C3 single-transaction, TS01-CP defpact). Picking wrong is silent both ways:
    # address the defpact believing it direct and the operation sits half-finished; address the
    # direct one believing it a defpact and the continuation has no pact to continue.
    collisions = {}
    for key, rec in entries.items():
        collisions.setdefault(key.split(".", 1)[1], []).append(
            {"module": key.split(".", 1)[0], "mode": rec["execution"]["mode"]})
    collisions = {f: v for f, v in sorted(collisions.items()) if len(v) > 1}
    for f, v in collisions.items():
        if len({x["mode"] for x in v}) > 1:
            print("  name collision -- %s resolves to %s" % (
                f, ", ".join("%s (%s)" % (x["module"], x["mode"]) for x in v)))

    doc = {
        "note": "GENERATED by REPL/tools/_registry.py. Deployed code wins; the repo is the "
                "fallback and those entries are marked not callable. Ghost values come from "
                "OURONET-REGISTRY.authored.json and are never overwritten.",
        "namespace": "ouronet-ns",
        "generatedFrom": "chain+repo" if probe else "repo-only",
        "entrypoints": dict(sorted(entries.items())),
        "previews": dict(sorted(previews.items())),
        "nameCollisions": collisions,
        "divergences": divergences,
        "notDeployed": sorted(unreachable),
    }
    body = json.dumps({"entrypoints": doc["entrypoints"], "previews": doc["previews"]},
                      sort_keys=True)
    doc["surfaceHash"] = hashlib.sha256(body.encode()).hexdigest()[:16]
    return doc


def main():
    if "--probe" in sys.argv:
        doc = build(probe=True)
        io.open(OUT, "w", encoding="utf8").write(json.dumps(doc, indent=1) + "\n")
        ghosts = sum(1 for e in doc["entrypoints"].values() if "ghost" in e)
        print(f"wrote Deploy/OURONET-REGISTRY.json")
        print(f"  {len(doc['entrypoints'])} entrypoints, {len(doc['previews'])} previews")
        print(f"  {sum(1 for e in doc['entrypoints'].values() if e.get('preview'))} paired, "
              f"{ghosts} with ghost values")
        print(f"  {sum(1 for e in doc['entrypoints'].values() if e['source'] == 'repo-only')} "
              f"repo-only (not callable)")
        print(f"  {len(doc['divergences'])} deployed/repo divergence(s)")
        for d in doc["divergences"][:10]:
            print(f"      {d['module']}.{d['function']}")
        print(f"  surface {doc['surfaceHash']}")
        return 0
    if "--check" in sys.argv:
        if not os.path.exists(OUT):
            print("registry: Deploy/OURONET-REGISTRY.json is absent. Run --probe.")
            return 1
        doc = json.load(io.open(OUT, encoding="utf8"))
        # Offline: the committed file must be internally consistent and non-empty. Whether it
        # matches the CHAIN needs --probe, exactly as _livetables.py splits the same way.
        bad = [k for k, v in doc["entrypoints"].items()
               if v.get("preview") and v["preview"] not in doc["previews"]]
        if not doc["entrypoints"]:
            print("registry: no entrypoints -- every check below would pass vacuously.")
            return 1
        if bad:
            print(f"registry: {len(bad)} entrypoint(s) point at a preview that is not in the file")
            for k in bad[:10]:
                print(f"    {k} -> {doc['entrypoints'][k]['preview']}")
            return 1
        # every entry must SAY how it executes. A missing `execution` is not a neutral
        # omission: a consumer reading the registry to decide whether to run a preflight will
        # read absence as "direct" and skip a read the call cannot work without.
        noexec = [k for k, v in doc["entrypoints"].items() if "execution" not in v]
        if noexec:
            print(f"registry: {len(noexec)} entrypoint(s) carry no execution mode")
            for k in noexec[:10]:
                print(f"    {k}")
            return 1
        vague = [k for k, v in doc["entrypoints"].items()
                 if v["execution"].get("preflightUnresolved")]
        if vague:
            print(f"registry: {len(vague)} indirect entrypoint(s) ship with an UNRESOLVED "
                  f"preflight -- name the read or the entry cannot be acted on")
            for k in vague[:10]:
                print(f"    {k} ({doc['entrypoints'][k]['execution']['mode']})")
            return 1
        # A `preferInstead` pointer is an INSTRUCTION to call something else. If the twin was
        # renamed or its shape drifted, the pointer sends a consumer at a function that does not
        # exist or takes different arguments -- strictly worse than no pointer at all. So the
        # twin must exist AND still carry an identical parameter list.
        broken = []
        for k, v in doc["entrypoints"].items():
            alt = v["execution"].get("preferInstead")
            if not alt:
                continue
            if alt not in doc["entrypoints"]:
                broken.append(f"{k} -> {alt} (no such entrypoint)")
            elif doc["entrypoints"][alt]["params"] != v["params"]:
                broken.append(f"{k} -> {alt} (parameter lists have diverged)")
        if broken:
            print(f"registry: {len(broken)} preferInstead pointer(s) are broken")
            for b in broken[:10]:
                print(f"    {b}")
            return 1

        # PRICED BUT UNPREVIEWABLE -- see PREVIEW_EXEMPT above for why this check exists.
        naked = [k for k, v in doc["entrypoints"].items()
                 if not v.get("preview") and k not in PREVIEW_EXEMPT]
        if naked:
            print(f"registry: {len(naked)} entrypoint(s) have NO cost preview and no exemption -- "
                  f"a client cannot show their price before the user signs")
            for k in naked[:10]:
                print(f"    {k}")
            print("    Write the INFO_ reader, or add a reasoned PREVIEW_EXEMPT entry.")
            return 1
        stale_ex = [k for k in PREVIEW_EXEMPT
                    if k not in doc["entrypoints"] or doc["entrypoints"][k].get("preview")]
        for k in stale_ex:
            print(f"registry: PREVIEW_EXEMPT stale -- {k} now pairs (or is gone); drop the entry")
        if stale_ex:
            return 1

        # GHOST COVERAGE. Every entrypoint carries an example call, and a parameter with no
        # ghost is listed rather than filled -- so a regression here shows up as a count, not
        # as a plausible-looking wrong example that someone copies.
        noghost = [k for k, v in doc["entrypoints"].items() if "ghost" not in v]
        gaps = sum(len(v.get("ghost", {}).get("unresolved", []))
                   for v in doc["entrypoints"].values())
        if noghost:
            print(f"registry: {len(noghost)} entrypoint(s) carry no ghost example")
            for k in noghost[:10]:
                print(f"    {k}")
            return 1
        slots = sum(len(v["params"]) for v in doc["entrypoints"].values())
        print(f"registry: ghosts -- {slots - gaps}/{slots} parameter slots have an example"
              + (f", {gaps} unresolved" if gaps else " (complete)"))

        modes = {}
        for v in doc["entrypoints"].values():
            modes[v["execution"]["mode"]] = modes.get(v["execution"]["mode"], 0) + 1
        print("registry: execution -- " + ", ".join(
            f"{n} {m}" for m, n in sorted(modes.items(), key=lambda kv: -kv[1])))
        print(f"registry: clean -- {len(doc['entrypoints'])} entrypoints, "
              f"{len(doc['previews'])} previews, surface {doc['surfaceHash']} "
              f"({doc['generatedFrom']})")
        return 0
    print(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main())

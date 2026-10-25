# Deploy/PureV10 — interface-membership sweep + TF reassignment, sleeping-leg multiplier, `CCp_`→`CC_`

**22 transactions, STRICT ORDER, 01 through 22.** ~5.98 MB total emitted / ~3.70M gas in size
charges, ~5.74M gas in measured module (exec) gas (per `_deploybundle.py --round
2026-10-interfaces` / `_purev10.py --plan`, the authority on emitted size — see the
per-transaction table below). Every individual transaction is well under the ~320 KB /
2.00M-gas single-transaction ceiling. **WIDENED 2026-10-12 from the original 6-transaction V10**
(owner instruction: *"do the sweep now, and lets fix this gap with the interfaces, i want to do
a single deploy... widen pure V10, for the whole pact code stage 1 and stage 2 modules"*) — this
supersedes the original 6, it does not follow it. The original round's own dot-pin cascade
(AQP-SCORE → RPS → AQP-FVT/AQP-VCT/MTX-AQP/AQP-DSA → TS02-C3 → AQP-INFO/AQP-BOOT) sits entirely
inside this round's 74-module scope, so sending the old 6 first would just redeploy the same
modules twice for no safety benefit.

## What this round adds

### 0. The interface-membership sweep — the reason this round widened

Owner ruling, 2026-10-12 (`StoicSyntax-Prefixes.md` §5): *"it was agreed upon that all user
functions must sit in the module's interface by default, as a glossary of all the user/client
functions said module employs... i dont want the interfaces to miss functions, just because it
was inconvenient to add them due to interface bump and refactoring."* Measuring the whole
sovereign tree against that rule (`REPL/tools/_ifacemembership.py`, the ground-truth scanner)
found **307 `defun` stubs missing across 36 sovereign modules, 38 interfaces** — every one a
function the module body already had, declared nowhere in its own interface, because adding it
had meant an interface bump at the time and that bump got skipped.

`REPL/tools/_ifacebump.py` closed the gap mechanically, module by module: bump the module's own
co-located interface by exactly one version, insert the missing stubs (paren-balanced signature
extraction from the module body — not a reformatted guess), flip the module's own `(implements
OLD)` to `(implements NEW)`, and rewrite every OTHER file's `module{OLD}` / `object{OLD.Schema}`
reference to `NEW` — citizen and sovereign, `.pact` and `.repl`, tree-wide. **Three bugs found
and fixed in the tool itself before the sweep was trusted** (all now hardened and covered by the
tool's own comments): a `count=1` replace that silently missed a SECOND `(implements OLD)` when
the literal text also appeared earlier in an `@doc` string; a schema-name regex (`\w+`) that
could not match the `|`/`-` characters this tree's schema names routinely carry (`DPTF|Balance-
Schema`, `DPDC-MNG|WipeSlicePlan`), so no `object{Old.Pipe|Named}` reference was ever rewritten
anywhere; and a missing same-interface unqualification step — a stub extracted from the MODULE
body always qualifies a same-interface schema (`object{Iface.Schema}`, required outside the
interface), but pasted back INSIDE that interface it must be unqualified (`object{Schema}`) per
CLAUDE.md's "Same-interface object types" rule, or the interface fails to load at all.

A fourth defect was found one layer down, in `_ifacemembership.py`'s own exception for the
load-order rule ("a function cannot be interface-declared if its signature references a
module-local schema") — it checked the RETURN type only, which missed `CODEX::UDC_STG|With-
RegisteredFlag`-shaped functions (untyped `object` return, module-local schema in a PARAM), and
a stub built from that signature aborted the interface's own load with "Cannot find module".
Fixed to check params too.

**One silent-revert bug was found AFTER the sweep was believed clean**, during gate verification:
`_gate.py` runs `--selftest` on every `REPL/tools/_*.py` tool that has one, and `_arweave.py
--selftest` REGENERATES `REPL/Stage_02/[6.1.10]_ARWEAVE-SHAPE.repl` from hardcoded Python string
literals in its own generator function — literals that still named the pre-bump interfaces, so
every gate run silently reverted the fix in that one file the instant the selftest step fired, no
`git` operation involved. Fixed `_arweave.py`'s generator itself, not just the emitted file.

**No new tables, no new capabilities, no new IMP registrations.** Every stub declares a function
the module body already had; `init` for this round is empty.

### 1. `AQP-POOL|CC_ReassignTrueFungibleStakeBeneficiary` — new client operation

The true-fungible (native or frozen) counterpart to the OF/collectable beneficiary reassigns
already live. The owner of an already-staked TF leg can redirect part or all of its earnings to a
different beneficiary without unstaking and restaking it:

- Works on **either** leg of a pool's canonical asset — native or its `F|` frozen counterpart —
  since `dptf-id` is a free parameter, not a native-only assumption.
- **Partial by design.** A TF position carries no nonce (unlike OF/collectable, where the
  nonce IS the indivisible unit), so the owner may move any amount up to the current balance —
  splitting a position across two beneficiaries, or moving it whole.
- No asset ever moves — an ordinary TF unstake always returns the position to the owner
  regardless of who the beneficiary was, so this is pure earnings bookkeeping.
- Refuses a no-op self-reassign and an amount above the current staked/rollup balance.
- Requires the OWNER's signature, not the current beneficiary's.

**Mechanism:** `CC_TrueFungibleStakeFlow`'s phase chain (custody transfer → per-pool tracker →
cross-pool `BenDptfTotal` rollup → RPS settle prelude → ANK anchor refresh → SCORE delta →
checkpoint) is now `XI_TrueFungibleStakePhases`, taking a `move-asset` flag that gates only the
custody-transfer leg — the same extraction already done for `XI_OrtoStakePhases` and
`XI_CollectableStakePhases`. The new function runs that chain TWICE with the asset pinned: once
with `direction` false to vacate the outgoing beneficiary (settling what they earned first), once
true to credit the incoming one — `owner` fixed on both runs, never a pool account, because TF has
no custodial variant. The new `FVT|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY` defcap bounds `amount` by
BOTH the current tracker balance and the cross-pool rollup, requires `CAP_EnforceAccountOwnership`
on the owner, and validates the new beneficiary exists, is a standard account, and differs from
the current one.

**Now interface-declared, by the sweep above.** `CC_ReassignTrueFungibleStakeBeneficiary` is one
of `AQP-FVT`'s (`AcquisitionFarmsVaultsTreasuriesV1`→`V2`) 20 new stubs; its siblings
`CC_ReassignOrtoStakeBeneficiary` / `CC_ReassignCollectableStakeBeneficiary` are declared too.
`UR_AQP|DPTFTrackerBalance` / `UR_AQP|BenDptfTotalBalance` already existed and were sufficient; no
reader changes needed for this feature.

**Verification:** `TX-FVT-11` in `[6.2.4]_AQP-FVT.repl` — partial reassign, remainder reassign,
both refusal paths, no-tokens-moved, and unstake still pays the owner. Delta-based throughout
(an earlier draft that moved the pool's OBSERVED self-balance instead of just this test's own
contribution left a stray row that collided with `[6.2.5]_AQP-VCT.repl`'s later full-pool
vacate — fixed). Mutation-tested the amount bound.

### 2. `AQP-SCORE::URC_SCR|SleepingLegHeldMultiplier` — new reader, closes a UI display gap

Owner noticed sleeping legs showed no multiplier tag at all (frozen's flat `mx-frozen` showed
fine; sleeping's per-nonce, time-decayed rate had no reader that could hand it back on its own —
`URC_SCR|SleepingLegWeight`/`...HeldWeight` fold `amount × multiplier` before returning, and
amount is almost never round, so the rate can't be recovered from the result). New reader isolates
just the rate, reading the LEDGER (stamped-at-stake) clock to match what the position is actually
earning right now. Verified two ways: a REPL regression (`[6.2.17]_AQP-RERATE.repl`
`<<TX-RERATE-SAT>>`) cross-checking against `UC_MxForRemaining` called directly and against the
real credited base-score delta; then a standalone half-term-lock scenario (150 of 300 months,
mx-sleeping 1.999) run through the REAL generated TypeScript composition end-to-end, which came
back `state-mx: [1.4995]` — exactly the hand-predicted value. `poolChain.ts`'s `allPositions` now
calls it for sleeping (non-hibernating) `of` legs. **Now interface-declared**, one of
`AQP-SCORE`'s (`AcquisitionScoresV2`→`V3`) 30 new stubs, alongside its direct siblings
`URC_SCR|SleepingLegWeight`/`...HeldWeight`/`UR_SCR|SleepRemainingAtStake`.

### 3. `CCp_Reassign*` → `CC_Reassign*` — naming correction on the two already-live siblings

`CCp_ReassignOrtoStakeBeneficiary` and `CCp_ReassignCollectableStakeBeneficiary` (both live on
mainnet, confirmed `"source": "deployed"` in `Deploy/OURONET-REGISTRY.json`) renamed to
`CC_ReassignOrtoStakeBeneficiary` / `CC_ReassignCollectableStakeBeneficiary`. The `p` suffix means
one specific thing (`StoicSyntax-Prefixes.md` §2.2, "Recipe axes"): *"fed ONE SLICE of a `URH_*`
dirty-read plan, order-independent, retryable, fired in parallel"* — part of a genuine
multi-transaction Hydra sweep (preflight computes N slices → N parallel/sequential slice calls →
optional begin/finalize bracket). Neither function has that shape: no preflight, no slice object,
one `(owner, beneficiary, amount-or-nonce)` tuple per call, one atomic transaction that happens to
invoke the same underlying phase-chain helper twice. Renamed in `05_FVT.pact`, `04_TS02-C3.pact`,
`09_AQP-INFO.pact`'s doc strings, three REPL test files, and `REPL/tools/_registry.py`'s
preflight-route table (a load-bearing lookup keyed by entrypoint name, not just documentation).
Historical references (what PureV8 actually shipped under the old name) are left as the
historical record — only forward-looking references were updated. No defcap renamed — the
C_/CC_/Cp_/CCp_ axis applies to `defun`s only.

## What ships, and why (22 transactions, in order)

Generated by `python3 REPL/tools/_deploybundle.py --round 2026-10-interfaces` (ROUNDS entry of
the same name) and lifted out by `python3 REPL/tools/_purev10.py --write`. Re-run `_purev10.py
--check` any time the sovereign/citizen tree changes again before this round ships — it re-runs
the scoped planner fresh and diffs the result against what is sitting in this directory.

| tx | module(s) | bytes | ~gas (size) |
|---:|---|---:|---:|
| 01 | U\|SWP, DALOS, IGNIS, BRD | 294,860 | 216,911 |
| 02 | DPTF, DPOF | 289,306 | 189,878 |
| 03 | O-UI-NINE, ELITE, ATS, O-UI-EIGHT, TFT | 313,111 | 330,263 |
| 04 | ATSU, VST, LIQUID | 293,971 | 212,375 |
| 05 | OUROBOROS, SWPT, SWP | 230,259 | 38,414 |
| 06 | SWPI, SWPL | 257,201 | 83,345 |
| 07 | SWPLC, SWPU, MTX-SWP | 290,992 | 197,760 |
| 08 | CODEX, O-UI-SEVEN, PYTHIA, P-UI-ONE, TS01-A, TS01-C1 | 295,558 | 220,531 |
| 09 | TS01-C2, TS01-C3, TS01-C4, TS01-CP, INFO-ZERO | 208,334 | 19,067 |
| 10 | INFO-ONE, AOZ, DPDC-UDC, O-UI-TEN | 311,159 | 316,117 |
| 11 | DPDC, DPDC-C, DPDC-I, DPDC-R, DPDC-MNG | 288,500 | 186,205 |
| 12 | DPDC-T, DPDC-S, DPDC-F, DPDC-N, EQUITY | 267,504 | 109,719 |
| 13 | DEMIPAD, AQP-ANK, O-UI-THIRTEEN | 262,739 | 96,748 |
| 14 | **AQP-SCORE** | 307,049 | 288,022 |
| 15 | AQP-POOL, O-UI-FOURTEEN | 279,028 | 147,403 |
| 16 | **RPS** | 312,557 | 326,194 |
| 17 | **AQP-FVT** | 271,277 | 121,021 |
| 18 | AQP-VCT, MTX-AQP, AQP-DSA | 280,512 | 152,979 |
| 19 | TS02-C1, TS02-C2 | 160,235 | 3,036 |
| 20 | **TS02-C3**, AQP-INFO, TS02-DPAD | 304,531 | 271,889 |
| 21 | DEMIPAD-SPARK, DEMIPAD-SNAKES, DEMIPAD-CUSTODIANS, DEMIPAD-STOICPAY, STOAICO, O-UI-FOUR, TS02-CPAD, INFO-TWO, KBN | 284,575 | 169,180 |
| 22 | AQP-BOOT (citizen), DSP | 174,471 | 5,509 |

Bold = carries one of the three features above (1/2/3); every other transaction in the plan is
there because it either (a) names one of the 38 bumped interfaces directly (the vast majority —
this round touches 36 sovereign modules' own interfaces plus every file that types a
`module{}`/`object{}` reference to one), or (b) is swept in by the dot-pin cascade below. `O-UI-*`
/ `P-UI-ONE` / `KBN` / `AOZ` are **citizen AppReads / minter modules in no generated deploy
chain** — `_deploybundle.py`'s `extra` mechanism injects each one right after the sovereign
module it reads, since they are confirmed LIVE (shipped by earlier PureV2/V3/V4 hand-rounds) and
their own source also named a bumped interface.

**Order is the safety property**, same as every prior round: a module may only reference modules
already deployed, and 14/16/17/20 above (AQP-SCORE, RPS, AQP-FVT, TS02-C3) must additionally
precede everything the dot-pin cascade below names, or a dot-calling caller aborts with `"hash
not blessed"` until its own re-send catches up.

## The dot-pin cascade, in full

Walked with `_dotpin.py --upgrade <module>` from every one of the 36 directly-bumped modules.
Twelve reach further (all own tables, so a stale pin ABORTS rather than silently going stale):

```
DPOF        --dot-pinned by-->  RPS, AQP-VCT
ATS         --dot-pinned by-->  AOZ (citizen)
DPDC        --dot-pinned by-->  AQP-INFO, BLOODSHED x4 + SETS (excluded, see below), NOSFERATU
                                 (excluded), KBN (AQP-BOOT's own dependency, already in-round)
DPDC-T      --dot-pinned by-->  RPS, AQP-VCT
AQP-ANK     --dot-pinned by-->  RPS, AQP-VCT, AQP-BOOT
AQP-SCORE   --dot-pinned by-->  RPS, AQP-INFO
AQP-POOL    --dot-pinned by-->  RPS, AQP-VCT, AQP-INFO, AQP-BOOT
RPS         --dot-pinned by-->  AQP-FVT, AQP-VCT, MTX-AQP, AQP-DSA, AQP-INFO
AQP-FVT     --dot-pinned by-->  AQP-INFO, AQP-BOOT
AQP-VCT     --dot-pinned by-->  AQP-INFO
AQP-DSA     --dot-pinned by-->  AQP-INFO
TS02-C3     --dot-pinned by-->  AQP-INFO, AQP-BOOT
AQP-INFO, AQP-BOOT, MTX-AQP, AOZ  --dot-pinned by nothing -- cascade terminates
```

Every module named above also directly names one of the 38 bumped interfaces (confirmed: `grep`
for the new interface names against each), so the `interfaces`-scoped round plan already carries
all of them without a separate `extra` entry — the one exception is `09_AQP-INFO.pact`, which
*is* interface-matched but sits in no deploy chain (same shape the 2026-09-aqp round hit for the
same file), so it is injected via `extra` anchored after `04_TS02-C3.pact`, same reasoning as
that round: AQP-INFO calls `TS02-C3.URCi_IssueGenericEarningVault` as a direct module reference,
which resolves at DEPLOY time, so it must follow TS02-C3's OWN transaction (20), not merely the
AQP core.

BLOODSHED (`01_BSD-L/02_BSD-E/03_BSD-R/04_BSD-C/05_BSD-SETS.pact`) and `NOSFERATU` also dot-call
DPDC and therefore technically need a re-pin, but both are **excluded from this round** by a
standing owner ruling (2026-09-21): mint-only, job done, not redeployed until a live comparison
and refactor to the current interfaces happens first. See `_deploybundle.py`'s `BLOODSHED`
constant and this round's own `excluded` map for the verbatim reasoning. If either is ever
needed for a bulk edit, re-pin them FIRST, against whatever DPDC hash is live at that time.

## Already-live, unrelated interfaces — found by a real mainnet simulation, fixed before resend

**A wallet simulation of all 22 transactions failed 22/22** the first time this round was built,
because Pact refuses to redeploy *any* already-live interface at all — not "refuses if changed,"
refuses outright, byte-identical content included. None of this round's own REPL/gate testing
can catch this: those build a chain from scratch, where declaring something for the first time is
fine. Only a simulation against the real chain state can see "this is already there," and it did.

Every one of the 22 files redeploys a module that needs ITS OWN interface bumped, but each file
also co-hosts OTHER, unrelated interfaces that happen to live in the same source file and are
already deployed, unchanged. Found and fixed systematically — not patched per failing transaction
— by diffing every `(interface ...)` in `Deploy/PureV10/*.pact` against the 38 genuinely-new
bumped names: **39 already-live interfaces**, across every one of the 22 files.

Each was checked against `Deploy/LIVE-MODULES.json` (a `describe-module` snapshot of the real
chain) before being trusted, not assumed from local source alone:

- **34 confirmed directly** — the interface appears in some already-deployed module's own
  `interfaces` list, which Pact populated from the chain.
- **`DpofUdcV2`** confirmed by necessity rather than direct listing: nothing
  currently *implements* it (so `describe-module` never surfaces it), but two already-live
  modules (`TS01-C1`, `INFO-ONE+`) type-reference `object{DpofUdcV2.RemovableNonces}`, which could
  not have compiled when THEY were deployed unless the interface already existed.
- **`OUiThirteenV1` / `OUiFourteenV1`** confirmed via this repo's own `Deploy/MANIFEST.md`, which
  already carried a specific, independently-verified claim for both (shipped in `PureV2/33` and
  `PureV3/08`+`PureV4/06`, the second backed by a live read fact: `URH_AQP|AllPoolIds` returning 7
  only if that transaction ran) — the live-chain snapshot used for the other 36 simply predates
  AppReads being added to its probe list.

**Two were investigated and are NOT stripped:**

- **`EquityV3`** — real near-miss. It looked like "already live, safe to skip," but the chain
  snapshot shows live `EQUITY` still implements `EquityV2`. `11_EQUITY+.pact`'s local source
  already has an UNSHIPPED `EquityV2→V3` bump sitting in it from earlier, unrelated work — this
  round carries it along (since EQUITY+ is being redeployed anyway) as a genuinely new interface,
  not a skip.
- **`InfoTwoV2`** — genuinely unresolved. Nothing implements it live (`INFO-TWO`'s own
  `implements InfoTwoV2` is commented out in source) or locally, and nothing references it as a
  qualified type anywhere in the tree, so its live status could not be determined without chain
  access this environment doesn't have. Left un-stripped: if it IS live, transaction 21 fails the
  same diagnosable way again and that settles it; if not, nothing downstream depends on it either
  way. **Confirm directly before sending transaction 21**, e.g. a dirty `(describe-module
  "ouronet-ns.INFO-TWO")` or equivalent against StoaChain.

The 37 confirmed-safe ones are pinned with content hashes in `REPL/tools/_deploybundle.py`'s
`LIVE_INTERFACES` dict (same mechanism the tree already used once before, for `AgeOfZalmoxis`) —
stripped from the emitted transaction, with a comment left in their place, while every module that
`implements` one keeps referencing it by its existing, unchanged name. The hash is the safety net:
if any of these 37 is edited locally after this pin, the hash changes and `_deploybundle.py`
refuses to guess, by design.

**All 22 files were regenerated with this fix** (`_purev10.py --write`, which runs the full
backup/scoped-write/extract/restore dance so `Deploy/`'s default full-round artefacts — what the
gate itself checks — are never left in a scoped, half-written state). Gate re-run clean after:
28,526 assertions, same count as before (stripping an upgrade-mode artefact doesn't touch what the
REPL/gate tests compile against, since those always build from raw source). `_purev10.py --check`
and `_deploybundle.py --check` both confirm clean. **Re-simulate before sending** — this was found
by simulation once already and should be confirmed by simulation again, not trusted on reasoning
alone.

## Second-order cascade — found by a SECOND simulation, fixed before resend again

The first fix above (stripping 39 already-live interfaces) was necessary but not sufficient.
Re-simulating the regenerated 22 files still failed 22/22, with a new first error: *"Module
ouronet-ns.IGNIS does not correctly implement the function OI|UC_IfpFromOutputCumulator from the
interface."*

Root cause, and it is a gap in the ORIGINAL interface-membership sweep, not the deploy packaging:
bumping `IgnisCollectorV3→V4` correctly rewrote every file that type-references
`object{IgnisCollectorV3.OutputCumulator}` to `IgnisCollectorV4.OutputCumulator` tree-wide — but
some of those referencing files are themselves *interfaces* (`OuronetInfoV2` declares
`OI|UC_IfpFromOutputCumulator` taking that exact type), not just modules. Rewriting an
interface's own declared signature changes what that interface *is*. CLAUDE.md's cascade rule
says precisely this must trigger its own version bump ("when interface B → B′, every interface A
that names B ... must bump to A′"), but nothing caught it: `_ifacemembership.py` only checks for
*missing* functions (completeness), never for *drifted* ones (freshness against what's live). So
`OuronetInfoV2`'s local content had silently diverged from what's actually deployed — same name,
different content, exactly the state Pact's immutable-interface rule forbids — while every
automated check this repo runs (gate included) stayed green, because none of them compare local
interface content against the live chain.

Walked to a real fixed point with `REPL/tools/_ifacecascade.py` (new tool, same cascade mechanism
as `_ifacebump.py`, generalized: find every interface whose OWN body references an already-bumped
name, bump IT too, repeat against the new frontier until a wave finds nothing new):

```
wave 1 (19): BrandingUsagePrimaryV2, BrandingUsageSecondaryV2, BrandingUsageTertiaryV2,
             DemiourgosPactTrueFungibleV2, DpdcFragmentsV2, DpdcIssueV2, OuroborosV2,
             OuronetInfoV2, SaleCustodiansV2, SaleSnakesV2, StoicPayV3,
             SwapperLiquidityClientV2, SwapperLiquidityV2, TalosStageOne_ClientFourV8,
             TalosStageOne_ClientOneV2, TalosStageOne_ClientPactsV4,
             TalosStageOne_ClientThreeV4, TalosStageOne_ClientTwoV2, TrueFungibleTransferV2
wave 2 (2):  InfoTwoV2, SparksV2   -- each names something FROM wave 1
wave 3 (0):  fixed point
```

**`InfoTwoV2` was the one left deliberately unresolved by the first fix** ("nothing implements it
live or locally, nothing references it as a type, could not be determined") — the cascade walk
resolves that ambiguity for real: it needed a bump all along (it references `SparksV2`, which
references `DemiourgosLaunchpadV3`), not a skip. Good evidence the earlier caution was the right
call rather than a guess that happened to dodge a bullet.

All 21 bumped for real (new interface name, `implements` updated, every consumer swept tree-wide
-- 19 files with renamed headers, 173 consumer files touched). The 21 OLD names were removed
entirely from `_deploybundle.py`'s `LIVE_INTERFACES` (they were wrongly pinned there as
"unchanged" by the first fix) rather than left as dead entries, since leaving a stale pin under a
name nothing declares anymore reads as settled when it was actually wrong. `EquityV3` needed no
rename (already a correct, never-shipped new name) but is now explicitly listed in the round's
`interfaces` scope alongside the 21, so `round_modules()` keeps catching `11_EQUITY+.pact` for the
right reason.

Re-verified completely after: `_ifacemembership.py --check` (0 sovereign gaps, confirms the
cascade didn't reopen the original membership question), `pact Z.repl` clean, full gate green at
28,526 assertions (same count — a cascade bump renames references, it does not add test surface),
every one of the 60 total bumped interfaces (38 original + 21 cascade + `EquityV3`) confirmed
present in the regenerated `Deploy/PureV10/*.pact`, every one of the 17 remaining
confirmed-unchanged interfaces confirmed still correctly stripped, zero unexpected interfaces of
any kind remaining in any of the 22 files. **Re-simulate again before sending** — this is the
second time a real mainnet simulation found something no offline check could, and that pattern
should be trusted, not argued with.

## A real sequential replay — not another round of blind re-simulation

Two fixes in, the wallet's "Simulate all" was still reporting failures on 21 of 22 files, and the
pattern stopped being informative: most of the errors ("Cannot find module: OuronetDalosV3" in
transaction 22, which transaction 1 creates) are consistent with the simulator evaluating each of
the 22 files INDEPENDENTLY against today's unchanged chain tip, rather than composing state as if
earlier transactions in the same queued batch had already landed — which `/local` (what a
"simulate" button calls) is architecturally incapable of doing; Kadena/Pact nodes have no concept
of a client-side pending queue. That would make most of the remaining red rows an artefact of the
TEST METHOD, not the round — but "probably" is not good enough for a mainnet send, so this was
verified directly instead of argued.

**Built a real sequential replay.** This environment turned out to have live network access to a
StoaChain node, which `REPL/tools/_livemodules.py --probe` already knew how to use (its own
docstring's "no network" caveat was stale for THIS session). Used it to: (1) refresh
`Deploy/LIVE-MODULES.json` / `.live-source-cache.json` against the current chain tip, confirming
mainnet state matches what every fix above assumed (`DALOS` still implements `OuronetDalosV2`,
`EQUITY` still implements `EquityV2`, `DPMF`/`CADUCEUS` confirmed not deployed at all); (2) built a
harness mirroring the tree's own established pattern for exactly this question
(`REPL/_scratch_loadpurev3.repl`, which already does this for round V3): bootstrap a sandbox from
the commit immediately BEFORE this sweep (`git worktree` at `b8e87a11`, standing in for "live
mainnet," the same assumption that precedent script already relies on), then sequentially `load`
all 22 `Deploy/PureV10/*.pact` files on top, in signing order, with the same two governance keys
used throughout this REPL suite for admin operations — exactly what "Send 22 in sequence" with
"Consecutive" checked actually does.

**This caught one more real bug**, and it is exactly the kind no isolated per-file check (gate,
`_modulecomplete.py`, the wallet's independent simulation) could ever see, because it is a
cross-transaction ordering question: **5 of the 8 injected AppReads pages were anchored on only
ONE of their several `module{...}` type dependencies** — whichever was found first, not the
LATEST. `O-UI-NINE` (anchored after `DPOF`, transaction 2) also needs `SwapperIssueV5`, which
ships in transaction 6; loading it before transaction 6 landed aborted with "Cannot find module:
ouronet-ns.VestingV3"-shaped errors (a `module{Iface}` type annotation is checked at LOAD time,
not call time, so this fails the whole transaction, not just a function nobody calls yet).
Checked exhaustively for all 8 (`grep -oE 'module\{[A-Za-z0-9_]+\}'` per page, every referenced
name mapped to the transaction that actually ships it, latest one wins) and fixed in
`_deploybundle.py`'s round definition: `O-UI-EIGHT`/`O-UI-NINE` now anchor on `SWPI`
(transaction 6, not 3/2), `O-UI-TEN` on `DPDC-F` (12, not 10), `O-UI-THIRTEEN` on `AQP-POOL`
(15, not 13), `O-UI-FOURTEEN` on `RPS` (16, not 15).

**Two harness-only artefacts, not round bugs, worth recording so the next person doesn't re-chase
them:** the throwaway worktree's `11_EQUITY+.pact` already carried `EquityV3` from the SAME
pre-existing, unshipped, unrelated bump this README already documents — renamed to `EquityV2`
(and its 4 tree-wide consumers) in the WORKTREE ONLY, so the bootstrap phase stops colliding with
itself and correctly represents "EQUITY still implements V2," letting transaction 12 declare
`EquityV3` fresh, exactly as a real send against real mainnet would. The real `Deploy/PureV10/`
files were never touched by this patch. AppReads modules also needed registering by hand in the
bootstrap (`O-UI-FOUR/SEVEN/EIGHT/NINE/TEN/THIRTEEN/FOURTEEN`, `P-UI-ONE`) since
`deploy-stage01/02.repl` never load them (same gap `_scratch_loadpurev3.repl` already flags for
two of these eight).

**Result after the anchor fix: `EXIT:0`, "Load successful," zero load-time errors across all 22
transactions, replayed in true signing order over a sandbox seeded from the commit immediately
before this sweep.** Full gate re-run clean again after rebuilding `Deploy/PureV10` with the
anchor fix. This is the strongest evidence this round has had so far — a real multi-transaction
sequential deploy, not a single file's structural check — and it is evidence FOR the fixes above,
not a replacement for sending it for real. Re-simulate or re-send at your discretion; if the
wallet's simulator is independent-per-file as suspected, expect many of the same "cannot find
X"-shaped rows to persist even now for files whose only problem is depending on an earlier
transaction in this same batch — that is the simulator's limitation, not this round's.

## The ChainedTXSimulator — composed replay against REAL fetched live content

The sequential replay above was a real improvement but still rested on an ASSUMPTION it stated
plainly: *"standing in for 'live mainnet'"* meant the commit just before this sweep, not mainnet
itself. That assumption was good enough to catch the AppReads anchor-ordering bug, but a
wallet-side "Simulate all" kept reporting the SAME error shapes afterward
(`BrandingV3 has no such member: SocialSchema`, `IgnisCollectorV4 has no such member:
OutputCumulator`) — because `/local` is stateless per call (confirmed by reproducing the wallet's
exact error set via raw API calls against the real node) and cannot compose a 22-transaction batch
in one HTTP round trip regardless of how correct the round is: a combined payload for all 22 files
is ~5.9 MB, and both the remote node and a local StoaChain node reject anything over roughly
1–2 MB (`node2.stoachain.com` ~1.0–1.2 MB, local node exactly 2,097,152 bytes — Warp/Chainweb's own
default). Gzip does not help; the server does not decode `Content-Encoding: gzip`. There is no way
to fit this round in one real `/local` call — this is a hard architectural ceiling, not a bug.

So two complementary tools were built instead of arguing the point further:

- **`REPL/tools/_chainsim.py`** — packs the round's own files into the LARGEST batches that fit
  under a conservative 900 KB, and fires each batch as a REAL `/local` call against
  `node2.stoachain.com` (`signatureVerification=false&preflight=false`, with the real governance
  public key named in `signers` — skipping signature verification does not exempt the keyset
  predicate check, so the right key still has to be named). Batch 1 (transactions 1–3, 836 KB)
  comes back genuinely GREEN against the live chain. Batches 2–8 fail, exactly as expected,
  because each one still only sees today's unmodified chain tip, not the hypothetical state after
  the batches before it — the same `/local` statelessness, demonstrated rather than assumed.
- **`REPL/tools/_chaintxsim.py`** — the real answer to *"can we get a green confirm for the whole
  chain, as if it were cached ahead of time in a virtual pot?"* It builds a throwaway `git
  worktree` at the pre-sweep commit, then for every interface/module this round touches, calls
  `describe-module` against the LIVE chain and splices the real, currently-deployed source in —
  not the pre-sweep commit's guess at what mainnet holds, the chain's own answer, fetched live.
  A `NEW_TO_OLD` map translates each current-tree interface name back to whatever name is
  genuinely live (`UtilitySwpV3` ⇒ fetch and splice in as `UtilitySwpV2`, etc.), and splicing is
  done with a paren-balanced surgical block replace (not whole-file overwrite, which was tried
  first and silently dropped co-located, unrelated declarations sharing the same file). On top of
  that real-content worktree it replays `Stage00_Sanboxes.repl` → `deploy-stage01.repl` →
  `deploy-stage02.repl` for the real init/keyset bootstrap, registers only the AppReads pages this
  round actually ships, then loads all 22 `Deploy/PureV10/*.pact` files in true signing order with
  both real governance keys. This is as close to "ahead-simulate the whole chain in a virtual
  pot" as is achievable without an actual mainnet send: every byte of context the round builds on
  is the CHAIN's own current answer, not a snapshot or a guess.

### A real mistake this caught, and the correction

Building `_chaintxsim.py` surfaced a genuine factual error that had been standing since the
"Already-live, unrelated interfaces" pass earlier in this document, and the sequential-replay
section just above repeats it: **`EquityV3` is NOT "a pre-existing, unshipped bump" and `EQUITY`
does NOT "still implement `EquityV2`."** A direct, hash-matched `describe-module
"ouronet-ns.EQUITY"` against the live chain shows `EquityV3` has been live since `Deploy/PureV4`
— a round this very file's "already-live" section names elsewhere as "the EquityV3 round." The
wrong reading traced to a one-off human misread of `Deploy/LIVE-MODULES.json`, not a stale cache
— the cached hash was correct and unchanged throughout. Because `_chaintxsim.py` replays against
the chain's REAL current content rather than a worktree-local stand-in, it self-collided on this
the first time it tried to bootstrap: `EquityV3` already being live meant the tree's own
consumer-sweep (documented in "Second-order cascade" above) had silently drifted `EquityV3`'s
OWN body the same way it drifted the 21 others — a real second-order drift that the original
cascade walk missed only because `EquityV3` had been wrongly excluded from it as "not live, no
bump needed."

Fixed for real, not patched around: `EquityV3` → `EquityV4` (the actual bump this interface
needed, via `REPL/tools/_ifacecascade.py`'s walk, now correctly including it), its 8 tree-wide
consumers swept, and every tool that had propagated the wrong belief corrected —
`_ifacecascade.py`'s seed set, `_deploybundle.py`'s round interface list and `LIVE_INTERFACES`
comment, and `_chaintxsim.py`'s own `NEW_TO_OLD` map (`EquityV4` ⇒ fetch-and-splice as `EquityV3`,
not `EquityV3` ⇒ `EquityV2`). This is disclosed here, rather than silently corrected, because it
is exactly the class of error the owner has been pushing this whole round's verification effort
to catch — a plausible-sounding belief about live chain state that nothing but asking the chain
itself actually checks — and it was the TOOLING's own rigor, not a human re-read, that caught it.

### Result

`python3 REPL/tools/_chaintxsim.py --round Deploy/PureV10` → **`EXIT:0`, "Load successful"** — the
complete 22-transaction round replays clean against 100% real, chain-fetched live content, through
every real init/keyset bootstrap step, with the round's own actually-shipped AppReads pages
registered, in true signing order. Full gate re-run GREEN again after the EquityV4 correction
(28,526 assertions). This is the strongest verification available short of an actual send: not a
simulation of a guess about mainnet, a replay against mainnet's own current, live-fetched answer.

**This is also the backend for the tool the owner asked for by name — "ChainedTXSimulator," "hold
in cache… in some sort of virtual pot, so that we could ahead-simulate it."** `_chaintxsim.py` IS
that simulator, as a REPL/Python backend, now also wired into OuronetUI's Scripts pane
(`daimons/OuronetUI/plugins/ouronet-scripts.ts`'s `SCRIPTS` array / `ScriptsPane.tsx`) as a
clickable `chaintxsim-purev10` entry — dev-server-only, by the same deliberate design as every
other entry there (see that file's own header comment): it is absent, not disabled, from a
deployed build of wallet/devwallet, because running arbitrary repo scripts from a public site
would be a real security hole, not a feature. `npm run dev` locally, admin → Scripts pane, is
where the button lives.

## Transactions 23–24 — the STOAICO repair and the owner's contribution, same round

Widened again, 2026-10-12, same day: `23_repair.pact` (`STOAICO::A_MigrateGeneralFields`, the
one-time admin migration fixing the live `distribution-round`/`zombie-rewards` gap — see that
module's own `@doc` and `GOV|MIGRATE-GENERAL-FIELDS` for the full diagnosis) and
`24_contribution.pact` (`STOAICO::A_Stake` replaying the owner's own real
`mJhPVaPs_0mCgc5tT7cAs1S41WbRdeHvAziy4B5QC9M` transaction — same patron, same account, same
4200.0). **Neither is generated.** `_purev10.py` extracts module/interface deploys from the
scoped planner; a bare admin function call has no module source to extract, so both are
hand-authored — same reasoning as `Deploy/2_Init/00_MANUAL_rotate-s2-governor.pact`, and
invisible to `_purev10.py --check`/`--write` by construction (neither matches `NN_deploy.pact`).
`_purev10.py --multipact` folds them into `ROUND.multipact.json` as a SECOND sequential group,
running after the 22 deploys are fully confirmed — tx23 calls a function tx21 is what deploys.

### Why the sandbox replay (Phase 1, above) cannot cover these, and what covers them instead

`_chaintxsim.py` grew a second phase, `verify_followups_live`, specifically because Phase 1's
sandbox is the wrong tool for these two. A worktree bootstrap gives STOAICO a FRESH, EMPTY table
— no real users, no real balances, no real drift — so replaying `A_MigrateGeneralFields` there
would prove nothing about the real bug it exists to fix, and could even pass for the wrong
reason (a fresh row already has every field the live one is missing). Proving a DATA-dependent
fix means testing it against REAL data.

**First attempt, wrong, kept in the tool's own comments as a lesson:** extracting STOAICO's full
module text straight out of the round's own generated `21_deploy.pact` and upgrading it standalone
via a real `/local` call failed immediately — `"Cannot find module: ouronet-ns.OuronetDalosV3"` —
for the exactly-correct reason that transaction 21 cannot really land before transaction 1 does;
its typed modrefs already assume interfaces only the EARLIER transactions in this same round
deploy. **Fixed**: fetch STOAICO's REAL live source (still correctly reading
`module{OuronetDalosV2}`, because that is what is actually live), and splice in ONLY the
genuinely NEW `defcap`/`defun` forms this round's local tree adds — not the round's post-sweep
module, which assumes a dependency chain a single real call cannot also carry (the whole round is
~5.9 MB; see the size-ceiling section above for why no call fits it).

**Second defect found the same way, smaller but worth recording:** the first version embedded
`(print "--- [file] ---")` labels inside the real `/local` payload for readability. `print` is a
REPL-only native — it works in every `.repl` file this tool and its siblings run (the `pact` CLI's
REPL interpreter adds it), but does not exist on the real chain's execution path, and under
`(namespace "ouronet-ns")` the failure is actively misleading: Pact tries to resolve the unknown
name as a module reference in the current namespace first and reports `"Cannot find module:
ouronet-ns.print"`, which reads like a bug in this code rather than what it is. Confirmed directly
— even a bare top-level `(print "hi")` fails the identical way against a real node. Fixed by
labelling in Python instead, against each list position in the response.

**Result, after both fixes:** the real call upgrades STOAICO for real (non-destructive — nothing
commits), runs `A_MigrateGeneralFields` then `A_Stake` against the ACTUAL live table (33 real
users, real balances, all preserved), and reaches exactly one more thing — `A_Stake`'s own
`CAP_EnforceAccountOwnership` check on the `account` argument, refusing for lack of that account's
real signature. That is the correct, EXPECTED boundary of what a read-only check can reach, not a
failure: the tool recognises this specific keyset-failure shape and reports it as `BOUNDARY
REACHED (expected, not a failure)`, distinctly from a genuine problem. Past that point only the
real account's real private key — which nothing in this repository holds — can take over.

### The limits, stated plainly (also shown in the UI on a click, next to the Run button)

A green `_chaintxsim.py` run proves: the 22 deploy transactions load, in order, against content
fetched live from chain moments earlier; and the two followups clear the distribution-round bug
against REAL current table data. It does **not** prove: (1) anything was actually sent — every
call is `/local`, nothing commits, nothing is signed for real; (2) the full 24-transaction chain
composes in ONE shot — Phase 2 tests tx23/24's own logic in isolation, because no single real call
can hold the whole round, so the cross-transaction ordering guarantee for 1–22 still rests on
Phase 1 plus actually sending "Consecutive"; (3) who may sign — the governance key here satisfies
every ADMIN capability, not the account-ownership check `A_Stake` separately enforces, which still
needs the real account's real signature on a real send regardless of this tool's result.

## What this round deliberately does NOT touch

- **`00_DPMF.pact`** — archive-mode, never redeployed (owner ruling). Its `ref-DALOS:module{
  OuronetDalosV2}` type annotation was swept to V3 for tree hygiene, but that reference lives
  inside a `defconst` (`GOV|MD_DPMF`) evaluated ONCE at DPMF's own original deploy time and
  cached forever on chain — it does not re-run when DALOS upgrades, so leaving DPMF unredeployed
  carries no runtime risk from this round.
- **`03_CADUCEUS.pact`** — Stage 3, not started; nothing live to upgrade.
- **`01_DPL-UR.pact` / `02_EXPLORER.pact`** — Stage-Z, deployed from their own separate
  `deploy-stagezz.repl` chain, last, by design; DPL-UR is additionally BLOCKED ON A LIVE READ
  (owner ruling) pending a check against whatever the owner may have deployed directly.
- **AppReads `O-UI-ONE/TWO/THREE/TWELVE.pact`** — held back; the owner is wiring the read-layer
  migration personally, page by page, and DPL-UR stays authoritative until each page's own reads
  are deployed by that process.

All four groups were swept for tree hygiene (their stale `object{}`/`module{}` references were
rewritten so the REPO keeps compiling and gating), but none is redeployed by this round.

## Verification

Gate green, 28,526 assertions (unchanged from pre-sweep — the sweep adds interface DECLARATIONS
only, no new module bodies, so no new assertions are expected or were added; feature 1's 6 TF-
FVT-11 assertions and feature 2's 2 RERATE assertions were already counted in the pre-sweep
baseline from the original V10 work). `python3 REPL/tools/_gate.py` run clean after:

- `REPL/tools/_ifacemembership.py` scan: 0 sovereign RECIPE-band gaps, 0 sovereign READER-band
  gaps remaining (citizen gaps remain, out of scope per the 2026-09-26 owner ruling that citizen
  modules are free to construct functions as they please).
- Full regeneration cascade: `_pricesync.py --write`, `_docsall.py --write`, `_suite_stats.py`,
  `_auditbook.py --docx`, `_deploybundle.py --write` (default round, the full from-scratch
  chain — NOT this round; see `_purev10.py`'s docstring for why the two must never be confused),
  `_talosabi.py --write`, `_toolindex.py --write`.
- `_purev10.py --check`: this directory's 22 files match a fresh scoped run of the planner.

Then, after sending all 22: `python3 REPL/tools/_registrylive.py --record` and
`python3 REPL/tools/_registry.py --probe` (CORRECTED — this read `--registry.py --write`, which
is not a flag that tool has; `--probe` is the one that reads the chain and rebuilds). The TF
reassign and the two renamed OF/collectable functions are client-facing entrypoints that need to
reach the registry before any UI can wire a button to them; the 304 OTHER new stubs are
interface declarations of already-live functions, not new entrypoints, and need no such step.

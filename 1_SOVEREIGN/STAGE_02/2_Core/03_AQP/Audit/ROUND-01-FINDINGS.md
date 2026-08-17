# ROUND I — Findings (AQP modules)

**Date:** 2026-08-11 · **Status:** frozen (append-only). Owner verdicts recorded inline as they arrive.

> **Superseded surface (2026-08 Phase 4 vacate rehaul):** findings/snippets below that name the old vacate API —
> `C_FullVacate*`, `C_Vacate*Legs`, and the `VCT|C>FULL-*` caps — refer to code REMOVED in Phase 4 (commit
> 57f5a6e). The live surface is `CC_FullVacate` / `XB_Vacate*` / `CC_BatchVacate*` (auto-begin-freeze /
> auto-finalize-on-drain, no finalize flag); see `README_VACATE_UI.md` + `README_TALOS_CATALOGUE.md`. This record
> is kept append-only for history.
**Scope:** `01_ANK.pact`, `02_SCORE.pact`, `03_AQP.pact` (POOL), `04_FVT.pact`, `05_VCT.pact` (~15,300 lines).
**Baseline:** `Z.repl` single pass green — 240 assertions, 0 failures (correctness for all 5 modules; the
CRITICAL/HIGH findings below are **not** covered by existing assertions).

> **Ground truth for reward math** — the proven UrStoa RPS vault, `00_StoaSandbox/coin.pact` 1520–1940:
> bank pending at the **OLD** rps → mutate score → checkpoint `last-rps` to the **NEW** rps;
> `INJECT`: `G += floor(R/S, PREC)`, guard `S>0`; `AVAILABLE = pending + floor(W·(G−L_i), PREC)`;
> `CLAIMABLE = (unclaimed-count==1 && avail>0) ? full stoa-supply : avail` (dust sweep).

Verification tags: **CONFIRMED** = lead re-read the code · **PLAUSIBLE** = auditor-reported, verify in REPL round.

---

# CRITICAL

## C1 · VCT — OF/DPSF/DPNF vacate legs are not bound to staked rows  `[CONFIRMED]`

**Location:** `05_VCT.pact` caps `VCT|C>ORTO-FUNGIBLE-VACATE-BATCH` (311), `…COLLECTABLE-VACATE-BATCH` (333),
`…FULL-ORTO-FUNGIBLE-VACATE` (446), `…FULL-COLLECTABLE-VACATE` (469).

**What's wrong:** the TF vacate caps (303, 435) bind every leg to a real stake row via
`URC_VacateTfLegsOk → URC_VacateTfLegBalancesOk` (def 1144, **wired at 1468**) — enforcing `amount>0`,
`amount == staked-bal(owner,ben)`, `rollup-bal >= amount`. The OF/collectable caps validate only
asset-matches-pool, array parity, gas/nonce totals, and `CAP_VctVacatePoolOwner`. **Nothing ties the
supplied `owner-ids`/`beneficiary-ids`/`nonces` to actual staked rows.** The five validators that would
close this are **defined but never wired** (grep: each appears exactly 1× = definition only, vs the TF
validator's 2×):
`URC_VacateOrtoLegBeneficiaryOk` (1087), `URC_VacateOrtoNoncesSufficient` (1115),
`URC_VacateCollectableLegBeneficiaryOk` (1329), `URC_VacateCollectableNoncesSufficient` (1360),
`URC_VacateCollectableRollupSufficient` (1392).

**Failure scenario (fund theft by pool owner):** OF vault transfer is whole-nonce, receiver-directed
(`XI_VacateOrtoFungibleBatch` → `DPOF::C_BulkTransfer … owner-ids true`, 06_DPOF.pact:2107). A pool owner
signs `C_VacateOrtoFungibleLegs` with `owner-ids=[attacker]`, `nonces=[[victim's staked nonce]]`:
`URC_ResolveOfDecimalAmountsFromTracker` (925) reads the attacker's empty key → `[[0.0]]`; the cap passes;
the bulk transfer still moves the **victim's** whole nonce vault→attacker; unwind at amount 0 leaves the
victim's tracker/SCORE/RPS intact → stolen inventory + pool insolvency on the next real unstake. DPSF/DPNF
are worse (amount-controlled `DPDC-T::C_BulkTransfer`, plus `bal-amount` write with no `>=0` floor / no
sufficiency cap on the vacate path).

**Fix direction:** wire the five validators into their caps exactly as TF does — bind each leg's
`owner+beneficiary(+amount)` to the real tracker row and rollup before any transfer.

**Owner verdict:** _pending_

## C2 · FVT — farm inject divisor captured before the in-tx ghost-TVL sync  `[CONFIRMED]`

**Location:** `C_Inject` `04_FVT.pact:2683-2732`.

**What's wrong:** `denominator` is bound at **2688** from `URC_InjectDenominator` → reads the **cached**
`total-ghost-tvl-weight` (S) (reader 1170; writer 1003). `gained-rps` (2689) and `new-g` (2690) derive
from it — all in the top `let`, evaluated **eagerly before** the body. The body's **first** step is
PHASE 0.1 `XI_SyncFarmGhostTvlForInject` (2698) → `XI_1|SyncFarmGhostTvlForEmployedScores` (3445), which
**overwrites** `total-ghost-tvl-weight` by reconciling against live SWP values. Then 2707 writes `new-g`,
computed from the **pre-sync** S. Member Tier-2 settle later pays `W_i·(G−g_i)` at the **post-sync** `W_i`.

**Consequence:** conservation needs `ΔG = amount / Σ W_i`. Here `ΔG = amount/S_old` but `Σ W_i = S_new`.
- Ghost TVL rose (`S_new>S_old`): total accruable `= S_new·amount/S_old > amount` → over-distribution;
  `available-rewards` goes negative on collect; the real TFT transfer out of `AQP|SC_NAME` bricks once
  drained (first collectors win, later collectors stuck).
- Ghost TVL fell: rewards stranded. Fully removed after the stale `S_old>0` guard passed: whole inject
  vanishes into `available-rewards` with nothing accruable.

**Trigger:** ghost-TVL drift between the last sync and the inject — exactly the state PHASE 0.1 exists to
absorb, so realistic latent condition, not a corner case. **Vault/Treasury injects are NOT affected**
(no phase-0 sync; denominator + settle both read live SCR deb in the same tx).

**Fix direction:** run the sync first, then read `denominator`/`gained-rps`/`new-g` from the freshly-written
S (move those bindings out of the top `let` into a step after 2698, or re-read S post-sync).

**Owner verdict:** _pending_

---

# HIGH

## H1 · SCORE — LP base weight mark-to-market by delta, no floor-at-zero  `[PLAUSIBLE]`

**Location:** `02_SCORE.pact:2262, 2274-2278` (via `2036/2069`); consumed by `04_FVT.pact:2884-2887`.
Class-0 LP base is recomputed each interaction from `URC_LpAmountToLpDenominatorEquivalent →
SWPL::URC_LpBreakAmounts` at **current** reserves, applied as signed delta `floor(ob+signed, p)` with **no
`max 0`** on the base column (only foreign-surplus boosted/deb get `UC_Max 0`, 2309/2318).
**Failure:** stake 1000 LP at equiv 100 → base 100; reserves drift so 1000 LP now = equiv 105; full unstake
→ `base -= 105` → user & `total-base` = −5 after a full exit that should be 0. FVT reads deb (=base for a
plain LP score) as the Tier-2 weight → negative weight in divisor `S`. `Σuser==total` preserved; sign/magnitude wrong.
**Fix direction:** floor base at 0 on unstake, and/or pin the stake-time lp-denominator so unstake reverses the exact added amount.
**Owner verdict:** _pending_

## H2 · POOL — stake re-open ignores `vacate-in-progress`  `[PLAUSIBLE, corroborated by VCT audit]`

**Location:** `03_AQP.pact:2646-2661` (`C_EnablePoolStake`), `661-668` (cap), `2053-2056`
(`URC_PoolStakeAdmissionOk` = `stake-enabled AND has-employed-scores`). Neither consults
`vacate-in-progress`; blocking during vacate is only the indirect `stake-enabled=false` VCT sets.
**Failure:** owner (or a race) re-enables stake mid-vacate → a slipped stake lands in `(P,X,O,B)`; then
`XE_ZeroDptfTrackerSlot` zeros the tracker **absolutely** while the rollup/transfer move only the manifest
amount → tracker=0 but vault still custodies the extra, `BenDptfTotal` off, funds stranded.
**Fix direction:** fold `vacate-in-progress` into `URC_PoolStakeAdmissionOk` and/or block `C_EnablePoolStake` during vacate.
**Owner verdict:** _pending_

## H3 · VCT — `finalize=true` re-enables pool-wide stake, no remaining/cross-stream check  `[PLAUSIBLE]`

**Location:** `05_VCT.pact:1875-1896` (`XI_MaybeFinalizeVacate`). On `finalize=true` it unconditionally
`XE_SetVacateJobState pool false` + `XB_SetPoolStakeEnabled pool true` — no remaining-inventory read, no
per-stream notion (`vacate-in-progress`/`PoolStakeEnabled` are single pool-wide flags). LP pools have
independent TF and OF streams (README_VACATE_UI §1.2): finalizing the TF stream re-enables stake while OF
inventory is still fully staked. The documented model ("finalize succeeds only if remaining units == 0")
is **not** implemented — it's UI-trust.
**Fix direction:** gate finalize on an on-chain remaining-unit-count==0 for the relevant stream; require both streams empty before re-enabling stake on LP pools. **(Owner: is on-chain enforcement wanted, or is UI-trust acceptable-and-documented?)**
**Owner verdict:** _pending_

## H4 · ANK — revoke leaves stale user aggregate promile  `[PLAUSIBLE]`

**Location:** `C_RevokeAnchor` (1714-1728) → `XI_RevokeAnchorBookkeeping` (1805-1818). Deactivates + strips
the anchor from BoostClass/AssetAnchors bookkeeping but never decrements any user's
`ANK|T|UserBoost.aggregate-promile` nor zeroes per-user `ANK|T|Anchors.promile`. SCORE reads the stored
aggregate directly → keeps boosting off a dead anchor until the user next triggers an update on some
**other** live anchor in that class (`XI_2|RecomputeAffectedBoostAggregates` recomputes from live slots).
**Fix direction:** accept eventual-consistency (document it) OR add a recompute path. Note: enumerating all
holders needs a forbidden scan — so an eager fix must be event/positioned differently.
**Owner verdict:** _pending_

## H5 · FVT/SCORE — triplet Tier-2 divisor runs an unbounded `select` on the hot path  `[CONFIRMED, two auditors]`

**Location:** `04_FVT.pact:1651-1671` (`URC_FarmTripletTier1Denominator` / `URC_ScoreEntityMemberTier2Divisor`)
→ `AQP-SCORE::URD_UserScoreStakerAccounts` (`02_SCORE.pact:1832 → (select SCR|T|UserScore …)`), mapped over
**every** staker in the silver pool. `XI_2|SettleMemberTier2` runs on every stake (2.3), collect, and inject
(0.1) touching a triplet farm member → O(stakers) gas, StoicSyntax "no scans on execution path" violation,
DoS/gas-out at scale; also re-derives each staker's lanes live (divisor drift vs banked `W_user`).
**Fix direction:** maintain a farm-triplet aggregate weight row (updated per stake/unstake delta) and point-read it.
**Owner verdict:** _pending_

---

# MEDIUM

## M1 · FVT — `unclaimed-count==1` dust-sweep not implemented  `[PLAUSIBLE]`
`URC_CollectClaimableRewards` (1916-1925) returns `URC_UserTier1AvailableRewards` unconditionally — no
`unclaimed-count==1` full-supply branch (Global or Member). Two-tier flooring guarantees `Σ payouts < injected`;
residual is locked in the vault, and the whole `unclaimed-count` subsystem (phases 5.1, 3308-3330, 3698-3777)
is maintained but never read for payout. Slow value-lock, not a leak (material at reward-DPTF precision ~10⁻¹²/collect).
**Fix direction:** implement the sweep to match the reference. **Owner verdict:** _pending_

## M2 · FVT — vault/treasury inject denominator `keys` scan inside a defcap  `[PLAUSIBLE]`
`URC_InjectDenominator` (1553) for class 1/2 → `URC_FvtVaultDebDenominator` (1528) → `URD_FvtScoreEntityLinkKeysForFvt`
(1492) → `(keys FVT|T|ScoreEntityLink)`; runs in `C_Inject` body **and** in `UEV_InjectContext` (2320) which
is invoked from the `FVT|C>INJECT` defcap. Cross-tenant gas coupling (cost scales with global ScoreEntityLink
rows). StoicSyntax defcap-scan + execution-path-scan violation. Functionally correct today.
**Fix direction:** maintain a per-FVT deb-sum aggregate; point-read it. **Owner verdict:** _pending_

## M3 · SCORE — boost-class link with aggregate promile <1000 zeros rewards  `[PLAUSIBLE]`
`02_SCORE.pact:2295-2299`: `nominal-boosted = floor(base·(prom/1000), p)`, `prom = UR_UB|AggregatePromile`
which defaults to **0.0** with no 1000 baseline (`01_ANK.pact:768`, fold from 0.0 at 2123). Linking a
BoostClass but holding no anchor → `boosted = deb = 0` → real stake earns nothing; adding a boost class
**reduces** effective weight to 0. Matches the README formula literally but is a sharp footgun.
**Fix direction:** guard (`promile>=1000` to employ) or a documented "promile is additive over 1000" contract. **Owner verdict:** _pending_

## M4 · SCORE — links/deb-boost settable after positions exist  `[PLAUSIBLE]`
`SCR|C>CREATE-BOOST-CLASS-LINK-SCORE` (706), `…CREATE-BOOST-LINK-SCORE` (726), `…ENABLE-DEB-BOOST-SCORE`
(590) check only slot==BAR / currently-false — not `nzs-count==0`/totals==0. Adding a foreign `boost-link`
after a user has base 100 → next delta hits the foreign-surplus branch → `new-user-base=0`,
`delta-global-base = 0−100 = −100` → previously-staked base erased from user + vault totals.
**Fix direction:** enforce `nzs-count==0` (or `total-base==0`) in these caps. **Owner verdict:** _pending_

## M5 · POOL — DPOF/collectable unstake self-key vs non-self stake  `[PLAUSIBLE]`
Unstake recovers beneficiary from the tracker at the **self key** `(owner,owner)`
(`URC_OrtoUnstakeBeneficiaryId` 2135-2139, `URC_CollectableUnstakeBeneficiaryId` 2176-2183; `bid` at 2919/2993),
but stake writes the tracker under caller-supplied `beneficiary-id` with no `beneficiary==owner` restriction
(`XE_OrtoFungiblePoolTracker` stake branch 2916-2918). A non-self OF/collectable stake lands at `(owner,ben)`
and unstake can never locate it → stuck (recoverable only via forced vacate). TF path is symmetric (unaffected).
**Fix direction:** restrict OF/collectable stake to `beneficiary==owner`, OR implement per-nonce beneficiary lookup on unstake. **Owner verdict:** _pending_

## M6 · ANK — TF promile pro-rated vs documented whole-step + 1000 cap  `[CONFIRMED]`
`URC_TrueFungibleAnchorPromile` (line 793): `floor((total-dptf-amount / dptf-amount) · ank-promile, prec)`
— continuous pro-rate, no cap. README_ANK:130: `floor(bal/dptf-amount) · ank-promile` capped at 1000.0
(whole-step). SF/NF paths (816, 842) use the whole-step `(dec conform-nonces)·promile`, so TF is the outlier.
Ex: amt=1000, promile=500, stake 2500 → README **1000**, code **1250** (no cap).
**Fix direction (owner decides code-vs-doc):** either make TF whole-step + cap 1000 (match SF/NF & README), or update README:130 to the pro-rate model. **Owner verdict:** _pending_

---

# LOW (discipline / hygiene)

- **L1 · POOL** — `URC_OrtoStakeWholeNonceAmounts` (2140-2167) contains an `enforce` (2149); redundant (caller
  asserts the same at 724). Move to `UEV_`/return bool. `[PLAUSIBLE]` · _verdict pending_
- **L2 · POOL** — `XI_2|BumpBenDpsfNonceTotal`/`…Dpnf…` (3110-3183) write two tables in one `XI` (nonce-total +
  AnkMeta). Logic correct; StoicSyntax prefers one focused write per `XI`. `[PLAUSIBLE]` · _verdict pending_
- **L3 · POOL** — `URD_AQP|BenDpsf/DpnfActiveNonceSupplies` (1499-1517 / 1574-1592) use `select`, consumed on
  `C_SyncCollectableAnchors` (2699-2704). Rare repair path, hoisted before `with-capability`; unbounded gas — note it. `[PLAUSIBLE]` · _verdict pending_
- **L4 · ANK** — `ANK|C>REVOKE` (491-496) has no `UEV_LiveAnchor` gate; double-revoke is saved only by a deep
  util `enforce` in `UC_RemoveItemAt` (aborts cleanly, no corruption). `UEV_LiveAnchor` (1118) exists, unused. `[PLAUSIBLE]` · _verdict pending_
- **L5 · ANK** — `XE_UpdateTrueFungible…`/`XE_Resync…` (1821, 1970, 2032) return `OutputCumulator` + carry IGNIS,
  while `XE_UpdateSemiFungible…`/`XE_UpdateNonFungible…` (1884, 1927) return nothing — asymmetric vs the XE contract. `[PLAUSIBLE]` · _verdict pending_
- **L6 · ANK** — `URC_SemiFungibleAnchorPromile`/`…NonFungible…` (818-821, 844-847) incremental unstake has no
  `max 0.0` floor → negative promile if caller passes a delta > recorded stake (repaired by Absolute resync). `[PLAUSIBLE]` · _verdict pending_
- **L7 · SCORE** — non-equal SF / model-1 NF weight reads **mutable** definition rows; a def change between
  stake and unstake yields asymmetric deltas (mitigated by `applied-def-revision-nonce` lazy refresh). Same
  no-floor root as H1. `[PLAUSIBLE]` · _verdict pending_
- **L8 · SCORE** — `XI_IssueTriplet` (3048) trailing `triplet-id`, `XE_CreateAqpoolLink`/`…FvtLink` (3516/3533)
  trailing `pool-id`/`fvt-id` after the write; interface return types require a string — harmless. `[PLAUSIBLE]` · _verdict pending_
- **L9 · VCT** — `VACATE-MAX-LEGS`=16 + `URC_VacateBatchLegParityOk` (1255) are defined but never called (nonce-total
  gas cap dominates); vestigial. `[PLAUSIBLE]` · _verdict pending_
- **L10 · FVT** — `C_Collect` settles the member Tier-2 twice (2751 bare + 2758 inside phase-0 sync); traced
  harmless (second settle is a no-op) but wasted work + ordering inconsistency vs stake flow. `[CONFIRMED]` · _verdict pending_

---

# What is VERIFIED CORRECT (invariants that hold — the sign-off backbone)

These are the things the auditors checked and found **right**; the final "code is correct" report builds on
re-confirming these plus closing the findings above.

**ANK** — insert-once issuance (`WI_BoostClass`/`WI_Anchor` on `UDC_Makeid` ids); empty-BoostClass revoke gate
(anchors==0 & active); TF div-by-zero guard (791); AssetAnchors enumeration re-filters on liveness (695-737);
aggregate = clean absolute recompute of live slots (2094-2135, idempotent); 49-cap before PlaceAnchor; slot
compaction; `UEV_IMC` first in every mutator; `keys` only in `URD_*` (not on exec path); TF user-anchor update
absolute/idempotent.

**SCORE** — single weight-mutation path (`WW_UserScore`+`WU3_Score|VaultTotals`+`WU_Score|NzsCount` in one `do`,
3488-3501); `Σuser==vault-total` exact (deltas floored at precision); NZS transitions ±1/0 over the full triple;
foreign-surplus math matches README; one-time links enforced (706/726/812/848, no self boost-link); triplet
bookkeeping (`WI_Triplet` insert, all three marked, `URC_IsTrueTriplet` exactly-one-BAR-hub); every mutator behind
a `SECURE`-composing defcap; `UEV_IMC` first; correct insert-vs-`WW_` first-touch.

**POOL** — TF custody↔tracker↔rollup mirror sign-consistent (2836-2839 / 3184-3201 / 3216-3234); rollup doesn't
drift on vacate (given no mid-vacate stake — see H2); score slots ≤7 with contiguity preserved on revoke; no
class-mismatched score employed; revoke leaves no dangling per-score state; `active-nonce-count` 0↔positive
crossing correct; sync convergence is absolute (no double-count); `UEV_IMC` first in all 13 XE/XB; `AQP|GOV`
composed only in-module.

**FVT** — RPS **ordering** correct: bank-at-OLD-rps (phase 2.3, 3420/3606) **before** score change (phase 4),
checkpoint-AFTER (phase 5.2, 3834); new-staker insert `last-rps=index` banks 0; unstake nzs--/unclaimed-- gating;
collect ordering (payout→transmit→reset→unclaimed→checkpoint→reduce supply) with no double-collect / no negative
supply **given a correct inject**; vault/treasury single-tier path conserves (denominator + settle both read live SCR deb).

**VCT** — TF vacate fully bound + parity with unstake (1956); TF double-process rejected by the cap; auto-begin
idempotent (`XI_EnsureVacateBegun` 1846); Abort clears flag, touches no tracker; gas ceilings enforced on-chain,
boundary-correct (`<=` 24/33/29/30; Full 128 legs/512 nonces); no `select`/`keys`/`URD_` on the exec path;
discipline exemplary (UEV_IMC first, atomic `XI_Vacate*` under `P|VCT|RECIPE`, no enforce in XI/C bodies).

---

# Cross-cutting themes

1. **Missing floor-at-zero on delta accounting** — H1 (LP mark-to-market), L6 (SF/NF promile), L7 (mutable defs).
   Absolute-resync paths repair; delta paths don't.
2. **Scans on the execution path** — H5 (triplet Tier-2), M2 (vault inject in defcap), L3 (collectable sync).
   Pattern to adopt: maintained aggregate row + point read.
3. **Compute-before-mutate / validate-that-was-never-wired** — C2 (FVT captures S before the sync), C1 (VCT
   defined the OF/collectable leg validators but never wired them). Both are small, surgical, large-blast-radius.
4. **Pool-wide single flags for independent LP streams** — H2, H3: `vacate-in-progress`/`stake-enabled` don't
   model the TF/OF stream split.

# Needs a REPL to confirm (Round III fodder)

Directly testable, and each should become a regression assertion once fixed:
- **C2:** inject after ghost-TVL drift → Σ member accrual == injected (conservation).
- **C1:** vacate leg with `owner-id`=non-staker → tx rejected.
- **H1:** LP stake → reserve drift → full unstake → base returns to **exactly 0**.
- **H2:** `C_EnablePoolStake` during vacate → rejected (or admission blocks the stake).
- **H3:** Legs `finalize=true` with remaining units > 0 → rejected.
- **M3:** employ boost-class with 0 promile, stake → earns > 0 (or employment rejected).

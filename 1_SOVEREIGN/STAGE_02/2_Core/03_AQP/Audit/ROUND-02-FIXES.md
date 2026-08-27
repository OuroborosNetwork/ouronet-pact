# ROUND II — Fixes (sequential; append-only)

Each entry = one fix, applied after the owner's green-light, before the next. Round I finding IDs and the
fix-plan numbers are in `README.md`.

> **Superseded surface (Phase 4, commits 57f5a6e / 96c33f8):** entries below that name the old vacate API
> (`C_FullVacate*`, `C_Vacate*Legs`) or the FULL-only validators (`URC_VacateFullBatch*`,
> `URC_Vacate*LegsBeneficiaryOk`) refer to code REMOVED in Phase 4 + its closeout. Live surface: `CC_FullVacate`
> / `XB_Vacate*` / `Cp_BatchVacate*`. Append-only record kept for history.

---

## Fix #1 — StoicSyntax §19: Ouronet-specific rules (R1–R5)  ✅ DONE

**Plan item:** #1 (Phase A) · **Findings addressed:** L2, L5, L8, L3 (reclassified as conventions, not bugs).
**Type:** documentation only — **no `.pact` code changed.**

**Files changed:**
- `OuronetInformational/StoicSyntax.md`
  - Header version **1.6.7 → 1.7.0**, date → 2026-08-11.
  - New chapter **§19 "Ouronet-specific rules"**:
    - **§19.1 R1** — `X-cm_` naming for X funcs that emit an IGNIS `OutputCumulator` (`XI-cm_`, `XE-cm_`,
      `XB-cm_`, tiered `XI-cm_1|…`). Plain `X_` must not return a cumulator.
    - **§19.2 R2** — multi-table X allowed for one indivisible bookkeeping step.
    - **§19.3 R3** — `CC_`/`AA_` HEAVY prefixes for `C_`/`A_` (or any dep) that unavoidably `URD_`/scan;
      §10.2 ban still stands; warning-label only; never a daily-hot path; never in a defcap.
    - **§19.4 R4** — X `@doc` output rule; only IGNIS-cumulator return is name-reflected.
    - **§19.5 R5** — consolidation index of other Ouronet-specifics (IGNIS §2.3a, Talos §2, prefix universe, §18).
  - Versioning table: appended the **1.7.0** row.
- `OuronetInformational/memories/2026-08-11-stoicsyntax-ouronet-specific-rules.md` — dated capture note
  (active-learning protocol), linking to the follow-up code refactors #22–#24.

**Consequence for later fixes:** the code is **not** yet renamed to these conventions — that is deferred to
Phase F (#22 `CC_`/`AA_`, #23 `X-cm_`, #24 X `@doc`), after the logic fixes land, to avoid churn during
logic changes.

**Verification:** doc-only; no REPL impact. StoicSyntax.md remains internally consistent (new chapter slots
between §18 and Versioning; prefix universe in §19.5 matches §6/§7).

---

## Fix #2 — README_ANK TF-promile formula: pro-rate (DOC-FIX for M6)  ✅ DONE

**Plan item:** #2 (Phase A) · **Finding:** M6 (doc half). **Type:** documentation only — **no `.pact` changed.**
The code (`URC_TrueFungibleAnchorPromile`, `01_ANK.pact:781-796`) is **correct**; the README was wrong.

**Files changed:**
- `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/README_ANK.md` (§ Promile Computation → TF Anchors, ~line 130):
  - Was: `promile = floor(user-balance / dptf-amount) * ank-promile` (capped at 1000.0) — a **whole-step**
    with a result cap, neither of which the code does.
  - Now: `promile = floor((user-balance / dptf-amount) * ank-promile, ank-precision)` — **pro-rated**
    (continuous); worked example 500/1000, stake 2500 → **1250**; noted the `dptf-amount<=0 → 0.0` guard;
    clarified the result is **not** capped — the *definition* `ank-promile` is bounded (`<=1000`,
    `dptf-amount<=1,000,000`) at issue (→ fix #15); added the SF/NF whole-unit contrast.

**Note:** the definition caps themselves are **not yet enforced in code** — that is fix **#15** (Phase D).
This fix only corrects the documentation to match current behaviour.

---

## Fix #3 — C1 · VCT: bind OF/DPSF/DPNF vacate legs to real staked rows  ✅ DONE

**Plan item:** #3 (Phase B, CRITICAL) · **Finding:** C1. **Type:** `.pact` logic — **first real code change.**
Closes the fund-theft / insolvency path where a pool owner could redirect a staker's whole-nonce inventory
to an arbitrary recipient (the five leg-binding validators existed but were never wired).

**Root cause:** the TF vacate caps bind each leg to its tracker row via `URC_VacateTfLegsOk`
(→ `URC_VacateTfLegBalancesOk`), but the OF/DPSF/DPNF caps validated only asset/gas/nonce-total — the five
per-leg validators (`URC_VacateOrtoLegBeneficiaryOk`, `URC_VacateOrtoNoncesSufficient`,
`URC_VacateCollectableLegBeneficiaryOk`, `URC_VacateCollectableNoncesSufficient`,
`URC_VacateCollectableRollupSufficient`) were defined but called nowhere.

**Files changed:** `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_VCT.pact` only.
- **Added 4 batch wrappers** (URC band, after `URC_VacateTfLegsOk`), mirroring the TF batch-wrapper pattern
  (fold the per-leg validators across the parallel Legs arrays; `(if (> l 0) … true)` guards the empty case;
  point reads only, gas-bounded by the existing per-cap caps):
  - `URC_VacateOrtoLegsOk` — beneficiary match + amount == full staked balance.
  - `URC_VacateOrtoLegsBeneficiaryOk` — beneficiary match only (full OF is whole-nonce; amounts tracker-derived).
  - `URC_VacateCollectableLegsOk` — beneficiary match + amount == full + cross-pool rollup covers.
  - `URC_VacateCollectableLegsBeneficiaryOk` — beneficiary match only.
- **Wired 4 caps:**
  - `VCT|C>ORTO-FUNGIBLE-VACATE-BATCH` → `legs-ok` in the enforce fold (now also uses `nonce-amounts-array`,
    previously an unused param).
  - `VCT|C>COLLECTABLE-VACATE-BATCH` → `legs-ok` (now also uses `amounts-array`, previously unused).
  - `VCT|C>FULL-ORTO-FUNGIBLE-VACATE` → `URC_VacateOrtoLegsBeneficiaryOk` in the enforce list.
  - `VCT|C>FULL-COLLECTABLE-VACATE` → `URC_VacateCollectableLegsBeneficiaryOk` in the enforce list.

**Why this is safe:** the beneficiary binding reads the tracker row keyed by `(pool,dpof/collectable,owner,
beneficiary,nonce)` and requires its stored beneficiary to equal the supplied one — so a leg can only name a
**real staked position**, and the vault transfer (owner-directed) therefore returns funds to the actual
staker. The sufficiency/rollup checks additionally forbid partial or over-vacate. TF was already immune;
this brings OF/DPSF/DPNF to parity.

**Verification:** `Z.repl` full single pass → exit 0, `Load successful`, **0 real failures**, assertions
unchanged at **225 + 15 = 240** (all legitimate vacate tests in `[6.2.5]` still pass — the stricter caps did
not reject correct legs). No other module touched. Also reverted the temporary `[UI-DIFF-TEST]` comment in
`04_FVT.pact` (module back to clean).

**Not yet covered (Round III regression):** a **negative** test — vacate leg with `owner-id` = non-staker (or
mismatched beneficiary / partial amount) must be **rejected**. To be added when we build the Round III suite.

---

## Fix #4 — C2 · FVT: read the inject divisor AFTER the ghost-TVL sync  ✅ DONE

**Plan item:** #4 (Phase B, CRITICAL) · **Finding:** C2. **Type:** `.pact` logic. **File:** `04_FVT.pact` only.
Fixes the farm-inject reward-conservation break (→ over-distribution / vault insolvency, or stranded rewards).

**Root cause:** in `C_Inject`, `denominator` (S), `gained-rps` and `new-g` were bound in the top `let`
(evaluated eagerly, **before** the body). The body's first cumulator step is PHASE 0.1
`XI_SyncFarmGhostTvlForInject`, which reconciles/overwrites `total-ghost-tvl-weight` (S). So `ΔG` used
`S_old` while the collect-time member settle uses the post-sync `W_i`/`S_new` → `ΔG ≠ amount/ΣW_i`.

**Fix:** removed the three bindings from the top `let`; recompute them inside the **PHASE 2.1** step (a new
`let` around the `WU_RpsGlobal|CurrentRps` write). Because the cumulator list `[sync, transfer, phase2.1, …]`
evaluates **left→right**, PHASE 2.1 now reads `URC_InjectDenominator` **after** the sync → `ΔG =
amount / S_post-sync`, matching the weights the settle uses. Left a comment block at the old binding site
explaining why they're not bound there.

**Safety details verified:** `UC_ComputeInjectGainedRps` already guards `denominator <= 0.0 → 0.0`, so if the
sync empties S there is **no divide-by-zero** (the inject simply doesn't advance G — degrades to stranded,
not a crash or over-pay; that S=0 edge is separate and acceptable). Vault/Treasury (`fvt-class` 1/2) read
`URC_FvtVaultDebDenominator` (live SCR deb, unaffected by the farm-only sync) — moving the read later is a
no-op for them, so the fix is uniform and safe across all classes.

**Verification:** `Z.repl` full pass → exit 0, `Load successful`, **0 real failures**, assertions unchanged at
**240** (existing injects run in already-synced states, so results are identical — no regression). Diff: `04_FVT.pact`
+16/−2.

**Not yet covered (Round III regression):** inject after an induced ghost-TVL drift → assert Σ(member accrual)
== injected amount (conservation), and available-rewards never goes negative on collect.

---

## Fix #5 — H2 · POOL: stake admission + C_EnablePoolStake respect vacate-in-progress  ✅ DONE

**Plan item:** #5 (Phase C, HIGH) · **Finding:** H2. **Type:** `.pact` logic. **File:** `03_AQP.pact` only.
Blocks re-opening stake mid-vacate (which would desync tracker↔custody and strand funds, since
`XE_ZeroDptfTrackerSlot` zeros absolutely while the rollup/transfer move only the manifest amount).

**Changes (defense in depth, two layers):**
1. **New point reader** `UR_AQP|PoolVacateInProgress:bool` (mirrors `UR_AQP|PoolStakeEnabled`; reads the
   existing `vacate-in-progress` field of `AQP|T|Pool`). Internal helper — **not** added to the interface
   (module-local use only).
2. **`URC_PoolStakeAdmissionOk`** now folds in `(not (UR_AQP|PoolVacateInProgress pool-id))` — so the stake
   custody caps (`AQP|XE>*-POOL-CUSTODY`, which gate on admission for `direction=true`) reject **new stakes**
   while a vacate session is active, even if `stake-enabled` were left true. (2-cond `and` → `fold (and) true`
   for the now-3 conditions.)
3. **`AQP|C>ENABLE-POOL-STAKE`** cap now `(enforce (not vacate-in-progress) …)` **first** (before `CAP_PoolOwner`
   / compose) — the owner cannot flip stake back on until the vacate is finished or `C_AbortVacate` clears it.

**Why the normal flow is unaffected:** during vacate, VCT already sets `stake-enabled=false` +
`vacate-in-progress=true`, so admission was already false — the new guard is belt-and-suspenders. Re-enabling
after a vacate goes through **abort** (clears `vacate-in-progress`) → then `C_EnablePoolStake` (now passes), or
through **finalize** (`XI_MaybeFinalizeVacate` clears the flag + sets stake-enabled directly, not via the cap).

**Verification:** `Z.repl` → exit 0, `Load successful`, **0 real failures**, assertions unchanged at **240**
(no legitimate enable/stake path broke). Diff: `03_AQP.pact` +21/−4.

**Not yet covered (Round III regression):** begin a vacate, then assert `C_EnablePoolStake` is **rejected**, and
a stake attempt is **rejected**, until abort/finalize.

---

## Fix #6 — H3 · VCT: on-chain emptiness gate on finalize (both LP streams)  ✅ DONE

**Plan item:** #6 (Phase C, HIGH) · **Finding:** H3 (+ its H3b write-only-finalize half). **Type:** `.pact` logic
+ one test-expectation update. **Files:** `05_VCT.pact`, `REPL/Stage_02/[6.2.5]_AQP-VCT.repl`.
Stops `finalize=true` from re-enabling pool-wide stake while inventory (or the other LP stream) remains.

**Design decision (recorded):** the pool row has **no** per-pool "remaining staked" aggregate, and counting
tracker rows would be a forbidden scan. The cheap, correct on-chain signal is **every employed score's
`nzs-count == 0`** (staking always yields a non-zero score, so all-employed-scores-nzs-0 ⟺ nobody staked ⟺
both LP streams empty). Feasible cross-module with **no interface bump**: `UR_SCR|ScoreNzsCount` is on
`AcquisitionScoresV1`, and POOL exposes the 7 `UR_AQP|PoolScore*` slot readers on `AcquisitionPoolsV1`.

**Changes:**
- `05_VCT.pact`:
  - **New** `URC_PoolFullyVacated:bool (pool-id)` — reads the ≤7 pool score slots, and for each non-`BAR`
    slot reads `ref-SCR::UR_SCR|ScoreNzsCount`; true iff all are 0. Bounded point reads, no scan (URC, not URD).
  - **`XI_MaybeFinalizeVacate`** now gates on `(and finalize (URC_PoolFullyVacated pool-id))`. Because this
    runs **post-batch** in an `XI` (where `enforce` is disallowed), it uses a **conditional re-enable**, not a
    reject: finalize is *honoured only if truly empty*; otherwise stake stays disabled, `vacate-in-progress`
    stays true, and it returns `"finalize-deferred-inventory-remains"` (vs `"finalized"` / `"continued"`).
- `REPL/Stage_02/[6.2.5]_AQP-VCT.repl` (`TX-VCT-N03`): this test **intentionally** finalizes a partial vacate
  with leftover and previously asserted the **buggy** outcome — "vacate cleared despite leftover" (expected
  `false`/cleared) and "stake re-enabled despite leftover" (expected `true`). Inverted both to the correct
  post-fix behavior: `vacate-in-progress` STAYS `true`, `stake-enabled` STAYS `false`. The test is now a
  **positive regression test** for H3. (Leftover-count assertion unchanged.)

**Dependency note:** `URC_PoolFullyVacated` relies on nzs reaching 0 on full vacate — which is guaranteed once
SCORE base floors at 0 (**fix #7 / H1**). Today's tests don't drift SWP reserves during vacate, so base
returns to exactly 0 and nzs→0; documented in the function `@doc`.

**Verification:** `Z.repl` → exit 0, `Load successful`, **0 real failures**, **240** assertions. The updated
`TX-VCT-N03` now prints `Expect: success … vacate STAYS in progress` and `… stake STAYS disabled`.

**Not yet covered (Round III regression):** an LP dual-stream case — finalize the TF stream while the OF
stream still holds stake → assert stake is NOT re-enabled until both are empty.

---

## Fix #7 — H1 · SCORE: LP Level-1 score is AMOUNT, not value  ✅ DONE (after 1 reverted attempt + deep study)

**Plan item:** #7 (Phase C, HIGH) · **Finding:** H1. **Type:** `.pact` logic. **File:** `02_SCORE.pact` only.

**Attempt 1 (REVERTED):** clamped `local-base-raw` at 0 (`UC_Max 0.0`). Broke `TX-VCT-DPNF01/02/03`: the DPNF
vacate legitimately drives base **transiently negative then corrects it** in a later step; a per-step clamp
destroyed the correction (deb landed at 1.0 instead of 0). Lesson: a blanket floor can't distinguish a
*final* bad negative (LP) from a *transient* legitimate one (DPNF). Reverted → green.

**Deep study (3 readers) → the real design.** See `Audit/LP-SCORING-REDESIGN.md`. The intended architecture is
a **two-level RPS**: Level-1 (per user) = stable **LP AMOUNT × mx**; Level-2 (per FVT entity, at inject only)
= **wrapped-STOA value**. FVT's Level-2 value side already exists (`ghost-tvl-weight = SWP::UR_StoaValue`) and
its tier math is wired the right way round. The negative came from **SCORE storing VALUE at Level-1** — the
one wrong decision.

**The corrected fix (small, no schema change, no clamp):** `02_SCORE.pact`
- `URC_SignedBaseDeltaForDptfLpStake` (2069) → `raw-weight = lp-amount × mxlp` (was `equiv(reserves) × mxlp`).
- `URC_SignedBaseDeltaForOrtoLpStake` (2083) → `raw-weight = sum-amounts × mx-sleeping` (was `equiv × mx`).
- `URC_LpAmountToLpDenominatorEquivalent` (2036) → **retired** (0 callers), commented; kept pending the
  Level-2 decision (relocate to FVT inject valuation, or remove).
- **No floor-at-zero** — amount-based reverses exactly, so a full LP unstake nets to **0** by construction;
  the shared `local-base-raw` path is untouched, so DPNF's transient negatives are preserved.

**Why correct:** LP tokens of one family are fungible → amount is the stable, comparable Level-1 weight. STOA
value (which fluctuates) is used only at Level-2 inject to split rewards across entities, never persisted as a
user score. Every non-LP class was already amount/count based — this brings LP into line.

**Verification:** `Z.repl` → exit 0, **0 real failures**, **240** assertions. `TX-VCT-DPNF01 deb-score = 0.000000`
(the reverted attempt's regression does NOT recur). `02_SCORE.pact` only.

**Still open (recorded in LP-SCORING-REDESIGN.md §6, awaiting owner):**
- **G2** design question — Level-2 split across entities by *whole-pool TVL* (current) vs *staked value*.
- **G1** optional refactor — FVT Level-2 persist+sync → fully transient (gas/purity; correctness already OK via C2 fix).
- **H5 / M2** — the two hot-path scans, as their own maintained-aggregate items.

**Not yet covered (Round III regression):** LP stake → induce SWP reserve drift → full unstake → assert base
returns to **exactly 0** (proves the value→amount fix); and per-family reward split by amount.

---

## Fix #8 — H5 · FVT: farm-triplet Level-1 divisor → maintained snapshot aggregate (kill the scan)  ✅ DONE

**Plan item:** #8 (Phase C, HIGH) · **Finding:** H5. **Type:** `.pact` logic + schema (pre-deploy, greenfield —
schemas edited freely). **Files:** `04_FVT.pact`, `02_SCORE.pact`, and the golden test `[6.4]_AQP-TRIPLET-COLLECT.repl`.
Preceded by a 4-way ANK/SCORE/FVT/VCT trace (facts in `ANCHOR-STALENESS-INVENTORY.md`).

**Root cause:** the farm-triplet Level-1 (L_i) divisor `URC_FarmTripletTier1Denominator` ran
`AQP-SCORE::URD_UserScoreStakerAccounts` — a full `select` over `SCR|T|UserScore` — then re-derived every
staker's `w-user` **live**, on **every** stake/collect/inject. O(stakers) scan on the hot path + a
live-numerator/live-divisor basis inconsistent with the banked checkpoints.

**Design decision (owner-approved):** the farm triplet was the *only* score-entity that recomputed live; singular
scores and vault triplets already point-read maintained totals. Make the farm triplet behave the same — **store
each user's `w-user` snapshot and maintain `Σ w-user` as a per-member aggregate**, both updated by delta at score
stake/unstake, both point-read at settle. Accepts the same eventual-consistency as every other deb-based score
(stale-until-restake); does NOT worsen H4 (see inventory). Owner explicitly chose the snapshot (vs live) basis.

**Changes — `04_FVT.pact`:**
- Schema: `FVT|ScoreEntityLink` + `total-lane-weight:decimal` (per-member Σ w-user); new table
  `FVT|T|MemberUserWeight` (key `user | fvt | entity`, field `contrib-weight`) + `create-table`.
- Plumbing: `UDC_FVT|ScoreEntityLink` +param (all 5 call sites updated incl. base-reader default/reconstruct);
  writer `WU_ScoreEntityLink|TotalLaneWeight`; reader `UR_FVT-SEL|TotalLaneWeight`; `UCk_MemberUserWeight` +
  upsert `WW_MemberUserWeight` + `with-default-read 0.0` reader `UR_FVT-MUW|ContribWeight`. (All module-internal —
  no interface churn.)
- **Numerator:** `URC_ScoreEntityUserWeight` gains `fvt-id`; farm-triplet branch now returns the **stored**
  `contrib-weight` (shares the divisor's snapshot basis → conservation); vault-triplet branch unchanged (live
  lanes, via new helper `URC_TripletUserLaneWeightLive`); score branch unchanged. 3 call sites updated.
- **Divisor:** `URC_ScoreEntityMemberTier2Divisor` farm-triplet branch → `UR_FVT-SEL|TotalLaneWeight` point-read;
  `URC_FarmTripletTier1Denominator` **deleted**.
- **Hook:** new `XI_SyncFarmTripletLaneWeights` at **phase 4.6** (after the existing phase-4.5
  `XI_SyncFvtTotalDebMirrors`, mirroring its read-old-at-2.3 / write-after-SCORE ordering) — for each
  farm-triplet member the staker touched: `new-cw = live w-user` (via silver's own pool link),
  `total-lane-weight += (new-cw − old-cw)`, store `contrib-weight = new-cw`. Wired into the TF, OF, and
  Collectable stake flows (guarded `farm ∧ triplet`, so a no-op where irrelevant).

**Changes — `02_SCORE.pact`:** deleted the now-0-caller `URD_UserScoreStakerAccounts` (module def + interface decl).

**Why correct:** at stake, phase 2.3 banks user pending at the OLD stored contrib and settles L_i with the OLD
stored total (both pre-4.6); phase 4.6 then advances both to new — exactly how singular scores already work
(bank at old deb / SCORE writes deb+total at phase 4). Numerator and divisor always share one snapshot, so
`Σ contrib-weight ≡ total-lane-weight` by construction → conservation. Single-member farms are unchanged
(w/S = 1). No O(stakers) anywhere.

**Verification:** golden `triplet-collect-golden.repl` **28/0** and fast `Z.repl` **225/0** (green). The
multi-staker assertion TX-AQP-CL04 now proves the invariant directly: ANHD `w-user=10`, EMMA `w-user=4`,
**maintained divisor = 14 = 10+4 exactly** (was a live scan). Golden diagnostics + `w-sum` updated from the
retired scan to the `UR_FVT-SEL|TotalLaneWeight` point-read.

**Not yet covered (Round III regression):** ≥3-staker farm triplet with a mid-life unstake (assert
total-lane-weight tracks Σ contrib after subtraction); anchor-promile change between stakes (assert
snapshot lags until restake, then refreshes) — the accepted eventual-consistency.

**Spun off:** `ANCHOR-STALENESS-INVENTORY.md` (S1/H4, S3/M4, S4 vault-triplet mixed-basis) — the wider
stale-until-restake cluster and its lock/virgin-link/reverse-index/re-score-sweep fix strategy.

---

## Fix #9 — H4 · ANK: lock anchor revoke while its BoostClass is employed  ✅ DONE (TEMPORARY PATCH)

**Plan item:** #9 (Phase C, HIGH) · **Finding:** H4 (inventory S2). **Type:** `.pact` logic + schema (pre-deploy).
**Files:** `01_ANK.pact`, `02_SCORE.pact`, golden `[6.4]_AQP-TRIPLET-COLLECT.repl`. **Owner decision (2026-08-13):
Option B (lock-while-employed).**

**Root cause:** `C_RevokeAnchor` (`01_ANK.pact`) only flips `ank-active`/strips class+asset slots; it never
touches holders' stored `aggregate-promile`, so a revoked anchor keeps paying its boost until each user next
re-stakes — an unbounded, per-user-staggered inconsistency window (see inventory S2). Can't be corrected in
O(1) per user, so we **prevent** the situation instead of chasing it.

**Fix (temporary patch — the lock only):**
- **Deploy order forces the counter onto ANK** (ANK deploys before SCORE; ANK can't read SCORE at revoke).
  New isolated table `ANK|T|BoostClassLinkCount` (key `boost-class-id`, field `count`) — no `ANK|BoostClass`
  schema ripple. Reader `UR_BC|ScoreLinkCount` (with-default 0, added to the interface); upsert incrementer
  `WU_BC|IncScoreLinkCount`.
- **SCORE bumps it at the one link-creation site** — `XI_CreateBoostClassLink` (the *only* runtime writer of a
  score's `boost-class-link`; triplet bundling doesn't create links) now calls the new forward entrypoint
  `AQP-ANK::XE_BumpBoostClassScoreLinks` (`UEV_IMC` + cap `ANK|C>BUMP-BOOST-CLASS-LINKS` → `+1`).
- **Revoke enforces it** — `ANK|C>REVOKE` defcap adds `(enforce (= (UR_BC|ScoreLinkCount (UR_ANK|BoostClassId
  anchor-id)) 0) …)`: an anchor whose BoostClass is linked by ≥1 score cannot be revoked.

**⚠️ UNFINISHED (marked in `ANCHOR-STALENESS-INVENTORY.md`):** the *unwind* half — freeze → re-score sweep →
unlink (decrement) → revoke — is **not built** (needs the re-score sweep, which doesn't exist yet).
Consequence: **once a boost-class is linked, its anchors are locked forever** until we build that path. This is
intentionally conservative (safe, stricter than the final design). Revisit when the sweep lands, adding the
decrement + freeze/sweep/unlink/revoke flow. Also folds in **M4/#13** (virgin-only linking) and **L4/#17**
(revoke liveness) when we return.

**Verification:** golden **29/0** (added a lock-armed assertion — triplet B/S/G boost-classes read
`score-link-count = 1 1 1`, proving the SCORE→ANK bump wires through), fast `Z.repl` **225/0**. Existing ANK
revoke tests (TX002/TX004 in `[6.2.1]`) still pass — unlinked anchors remain revocable, so **no over-block**.

**Not yet covered (Round III regression):** the full negative test — link a boost-class, then
`expect-failure` on revoking one of its anchors (needs a known anchor-id from setup); and unlink→revoke once
the sweep exists.

---

## Fix #25 — S4 · FVT: triplet reward math branches on TRUE-TRIPLET (any class), not FVT class  ✅ DONE

**Plan item:** #25 (HIGH, surfaced by #8) · **Finding:** S4 (`ANCHOR-STALENESS-INVENTORY.md`). **File:** `04_FVT.pact`.
**Owner design (2026-08-13):** farms, vaults AND treasuries may each accept triplets, and any of them may be
**true** or **non-true** — so the discriminator is the **true-triplet flag**, not the FVT class.

**Root cause:** after #8 the triplet reward math branched on `FvtClass == 0`. That was (a) wrong for a *non-true
farm* triplet (would use lanes), and (b) inconsistent for *vault/treasury* triplets — divisor used Σ-of-3-total-deb
while the numerator used live lanes (`URC_ComputeTripletLanes`), so `Σ(numerators) ≠ divisor` → reward
conservation drift. Reachable by design (`triplet-category = LP | VAULT_TF | TREASURY_SF_NF`), just untested.

**Fix — discriminate on `UR_SCR|TripletTrueTriplet` (interface-exposed), independent of class:**
- **Divisor** `URC_ScoreEntityMemberTier2Divisor`: triplet → true ? `total-lane-weight` (maintained Σ w-user) :
  `URC_ScoreEntityMemberDebWeight` (Σ of the 3 scores' total-deb); singular → total-deb.
- **Numerator** `URC_ScoreEntityUserWeight`: triplet → true ? stored `contrib-weight` : **new** `URC_TripletUserDebSum`
  (Σ of the user's deb across the 3 bundled scores, each read at its own `aqpool-link`). Conservation holds:
  `Σ_users Σ_scores user-deb = Σ_scores total-deb = divisor`.
- **Phase-4.6 hook** `XI_SyncFarmTripletLaneWeights` → renamed `XI_SyncTripletLaneWeights`; guard changed from
  `class 0 ∧ triplet` to `triplet ∧ true-triplet` (maintains the lane snapshot for TRUE triplets of any class;
  the hook already runs in the TF / OF / Collectable stake flows, covering vault-TF and treasury-SF/NF).
- **Class-agnostic lane precision** in `URC_ComputeTripletLanes`: `lp-denominator` is class-0-only (BAR for
  vault/treasury), so a true non-LP triplet would hard-fail on `UR_Decimals BAR`. Now: LP → pool-leg decimals
  (unchanged); non-LP → the score's own `UR_SCR|ScorePrecision`.

**Also corrects #8:** #8's class-based branch is replaced by the true-triplet branch. The golden (a true-triplet
farm) is unaffected — class 0 ∧ true ⇒ same lane path.

**Verification:** golden **29/0**, fast `Z.repl` **225/0**; LP W_user unchanged (ANHD 10 / EMMA 4 / Σ 14, the
conditional precision left LP untouched) and multi-staker conservation still exact.

**Not yet covered (Round III regression):** no test exercises a **non-true** triplet or a **vault/treasury**
triplet — the corrected paths are code-correct-by-construction but untested. Round III should add: (a) a non-true
triplet (assert numerator=Σ user-deb, divisor=Σ total-deb, conservation), and (b) a vault-TF or treasury true
triplet (assert lanes compute with score-precision and conservation holds).

---

## Fix #10 — M1 · FVT: two-tier RPS dust sweep (last-claimant-takes-all)  ✅ DONE (drain-proof green)

**Plan item:** #10 (MEDIUM) · **Finding:** M1. **Owner decision (2026-08-13): Option 2 — dual sweep**
(per-member Tier-1 sweep + the global Tier-2 sweep), the mathematically complete port of the canonical vault's
`unclaimed-count` extended to both tiers. Design validated against the triplet/ATS-ladder semantics: the member
key's `dptf-id` is `token-0` (base of the ATS chain), the whole payout is in `token-0`, and the ATS ladder
(`C_Coil`/`C_Curl`) converts downstream and is itself dust-free (`amt-g = payout − amt-b − amt-s`). So a single
`available-rewards` per `(member, token-0)` is the correct source of truth.

**Stage 1 — foundation (DONE, green: golden 29/0, Z 225/0):** new isolated table `FVT|T|MemberVault`
(key `fvt|entity|dptf`, fields `available-rewards` + `unclaimed-count`) — dedicated table chosen over adding
fields to `FVT|RPS|Member` to avoid threading through 8 constructor sites in the settle/inject hot paths.
Accessors `UR_FVT-MV|AvailableRewards`/`UnclaimedCount` (with-default 0) + upsert writers. **Crediting wired:**
farm `XI_1|FarmSplitInject` (`available += member-slice`) and vault `XI_2|SettleMemberTier2` earned branch
(`available += earned`) — no overlap (farms keep G=0 so the earned branch never runs for them). State accumulates;
nothing reads it yet, so behavior is unchanged.

**Stage 2 — count maintenance + dual sweep (TODO):**
- Member `unclaimed-count`: **decrement** at collect when member weight hits 0 (mirror the global decrement in
  `XI_1|BookCollectUnclaimed`, same `deb==0` condition — easy); **increment** at stake on the 0→positive
  transition (mirror the intricate `XI_BookStakeUnclaimedCounts` claimant-transition logic at the member grain —
  the delicate part).
- Dual sweep in `URC_CollectClaimableRewards`: `payout = (mc==1 ∧ gc==1)→global.available ; mc==1→member.available ;
  else→floored`; then decrement both `available-rewards` (global existing + member new). Composes without
  double-pay because global.available is reduced by every payout incl. member sweeps.
- Also implements the global Tier-2 sweep branch (the long-planned but never-built "4c] last-claimer rule" in the
  canonical collect map, FVT ~L3247).

**Verification target (Stage 2):** a wind-down test — last user in a member sweeps member.available; last user
globally sweeps the tier-2 remainder; both vaults drain to exactly 0.

**Stage 2 — count maintenance + dual sweep (DONE in code, green: golden 29/0, Z 225/0):**
- **Member count:** `XI_1|BookUnclaimedForFvtRewardLine` now runs the *same* was/is-claimant transition **per member
  (plan)** (using the existing `pre-nz-flags` / `URC_UserScoreTripleIsNonZero` / member `PendingRewards`) → bumps
  `WU_MemberVault|UnclaimedCount`. Collect decrement added to `XI_1|BookCollectUnclaimed` at the same `deb==0`
  spot as the global one.
- **Dual sweep:** `URC_CollectClaimableRewards` → `gc==1 → global.available ; mc==1 → member.available ; else
  floored` (gc==1 ⟹ mc==1, so global precedence is correct). Also implements the never-built global Tier-2 sweep.
- **Both vaults decremented** in `C_Collect` (global exact; member clamped at 0 for the global-sweep case).
- Existing reward math unchanged (the sweep only changes what the *last* claimant receives; multi-staker
  collects with gc>1/mc>1 stay on the floored path — golden CL04 unchanged).

**⚠️ Blocker found by the drain-proof (NEW, → its own item):** a wind-down (EMMA exits, ANHD sweeps as sole
claimant) reverts with `AURYN … 0.0 is not a Valid Transaction amount`. The sweep *accounting* is correct, but
when a payout splits into a **tiny lane** the triplet ATS ladder (`ATSU::C_Coil`/`C_Curl` in
`XI_TransferRewardDptfFromVault`) attempts a **0.0 intermediate transfer**, which `DPTF::UEV_Amount` rejects.
This is a **pre-existing ATS-ladder robustness gap** (guards check `amt-s>0`/`amt-g>0` but not the *converted*
output), surfaced — not caused — by the sweep. **Consequence:** the dual-sweep is correct and green for PLAIN
(non-ladder) members, but end-to-end sweep of tiny dust through a *triplet* ladder can revert until the ladder
guards 0-output conversions. Scope: a new finding (ATS-ladder tiny-lane 0-transfer guard) + the drain-proof
wind-down both to Round III. `UR_FVT-MV|*` accessors may need interface exposure for the wind-down test.

**Stage 3 — precision fallback + drain-proof (DONE, green: golden 31/0, Z 225/0):**
- **M7 reclassified NOT-A-BUG** (owner, by-design): tiny amounts whose ATS pool-index conversion rounds below
  token precision to 0 are unusable for `Coil`/`Curl` — an accepted precision artifact, no ATSU wrapper wanted.
- **Owner's fallback (implemented in `XI_TransferRewardDptfFromVault`, not ATSU):** before each lane's
  `C_Coil`/`C_Curl`, preview the conversion via `ref-ATS::URC_RewardBearingTokenAmounts`; if the RBT output
  rounds to 0, **skip the conversion** — the patron keeps that lane as **token-0** (already funded via the
  `fund-sg` pre-transfer). Per-lane, value-exact (full payout delivered, just as the base token for dust lanes),
  and it touches only the FVT caller — ATSU is unchanged. Curl checks *both* hops.
- **Drain-proof (re-enabled, PASSES):** `[6.4]` TX-AQP-CL04 wind-down — EMMA fully unstakes, ANHD (sole
  claimant, gc==1) collects → **both the global and member vaults drain to exactly 0.0** (`gc→0`). This proves
  the whole two-tier sweep end-to-end for a *triplet* member through the ATS ladder.

**#10 CLOSED:** dual sweep + per-member/global count maintenance + precision fallback, all green with an
end-to-end drain-proof. (Round III can still add a vault/treasury and a non-true-triplet sweep case.)

---

## Fix #11 — M2 · FVT: kill the vault-inject `keys` scan (maintained total-deb mirror)  ✅ DONE

**Plan item:** #11 (MEDIUM) · **Finding:** M2. **File:** `04_FVT.pact`. **Owner:** do A + B, source the deb from
the **live** value (per-account DALOS `deb` → live `ScoreTotalDebScore` → live `URC_ScoreEntityMemberDebWeight`),
**no persistent cache**.

**Root cause:** the vault/treasury inject divisor `URC_FvtVaultDebDenominator` ran `(keys FVT|T|ScoreEntityLink)`
— a scan over **every** FVT's members globally — and it ran **inside the inject defcap** (`FVT|C>INJECT` →
`UEV_InjectContext`). StoicSyntax defcap+execution-path scan violation, plus cross-tenant gas coupling (every
vault inject's cost scaled with the global member count). A mirror field `FVT|Schema.total-deb-score` existed but
was **never read** and was itself maintained by the **same scan** at every vault stake (phase 4.5 wholesale).

**Part A — inject point-reads the mirror:** `URC_InjectDenominator` (vault) now returns `UR_FVT|TotalDebScore`
(point-read). Removes the scan from the inject **body and defcap**, and makes the mirror useful.

**Part B — maintain the mirror incrementally from the live deb, no scan, no cache:**
- **Stake/unstake:** phase-4.5 `XI_SyncFvtTotalDebMirrors` rewritten — for each **touched** member (bounded, from
  the settle-bundle) it deltas the mirror by `(new live URC_ScoreEntityMemberDebWeight − pre-SCORE deb)`. The
  pre-SCORE deb is captured live at settle-bundle build into a new **self-describing** `FVT|MemberPreDeb`
  (carries fvt/entity/type + pre-deb → no positional-alignment risk), transient per-tx (not a persistent cache).
- **Toggle enable/disable** (`XI_ToggleScoreEntityLink`) and **member add** (`XI_AddScoreEntity`): ± the member's
  live deb-weight to the mirror — the sum-changing events the old wholesale-at-stake **missed** (so the mirror is
  now correct for an inject that follows a toggle/add with no intervening stake — required for Part A's safety).
- **Deleted** `URC_FvtVaultDebDenominator` and its `URD_FvtScoreEntityLinkKeysForFvt` (`keys` scan) — 0 callers.

**Verification:** golden **31/0**, fast `Z.repl` **225/0** (vault inject tests unchanged — the mirror equals the
old scan value, now maintained by delta). No `keys`/scan remains on the vault deb path.

**Not yet covered (Round III):** a toggle-then-inject-without-stake regression (assert the mirror tracks the
toggle), and a member-add-with-pre-existing-deb case.

---

## Fix #12 — M3 · SCORE: additive boost + deb as end-multiplier (Part 1 core)  ✅ DONE (core); 5-field decomposition = follow-on

**Plan item:** #12 (MED) · **Finding:** M3. **File:** `02_SCORE.pact`, golden test. **Design:** `M3-DEB-DESIGN.md`.

**Root cause:** in `URC_SingularUserScoreDeltaFromSignedUserBase`, a boost-class-linked score set
`boosted-score = base × promile/1000` which **replaced** the base, and `deb-score = boosted × deb` — so the base
was dropped (a linked score with promile < 1000 was cannibalized; at promile 0 it earned nothing).

**Fix (owner-locked additive model):** boost is a *bonus*, deb is the alpha-omega end multiplier on the sum:
- `boost-part = (bcl==BAR) ? 0 : floor(base × promile/1000, p)` — the boost part (stored as `boosted-score`).
- `deb-score = db-boost ? floor((base + boost-part) × Elite-DEB, p) : (base + boost-part)` — **base never dropped**.
- The separate foreign boost-**link** surplus branch (`bl`, `apply-foreign-boost-surplus`) is untouched — that's a
  different mechanism; the `nominal-*` surplus math is preserved.

**Verification:** golden **32/0**, fast `Z.repl` **225/0**. New assertion on the silver score proves it: `base=100,
boosted=10, deb-score=110 = base+boost` (pre-M3 it would have been 10, the boost part alone → the assertion
`deb-score ≥ base+boosted` fails before the fix, passes after). No regressions (no-boost scores' deb-score
unchanged; only the `boosted-score` accounting field goes to the boost part).

**Part 1b — 5-field decomposition (DONE, owner chose store-5-at-both-levels):** added `base-deb-score` +
`boosted-deb-score` to `SCR|UserSchema`, `total-base-deb-score` + `total-boosted-deb-score` to `SCR|Schema`, and
`new-user-*` / `delta-global-*` fields to `SCR|SingularUserScoreDelta`. Computed in
`URC_SingularUserScoreDeltaFromSignedUserBase`: `base-deb = db-boost ? floor(base×deb,p) : base`,
`boosted-deb = deb-score − base-deb` (so **base-deb + boosted-deb == deb-score exactly**, absorbing rounding, and
correct for the foreign-surplus case where base=0). Threaded through the 3 UDCs (+all call sites), the totals
writer `WU3_Score|VaultTotals`, and the user-write / reader-reconstruct sites. **`UR_*` readers added for all 4
new fields** (`UR_U-SCR|UserScoreBaseDebScore`, `…BoostedDebScore`, `UR_SCR|ScoreTotalBaseDebScore`,
`…BoostedDebScore`) + interface decls (StoicSyntax). Reward math unchanged (`total-deb-score` still the
denominator). **Verified:** golden **33/0** — new assertion proves `base-deb(100)+boosted-deb(10)==deb(110)`;
Z **225/0**. **Part 1 COMPLETE.**

**Part 2 — deb-staleness subsystem (STARTED):**
- **2a substrate (DONE, green):** `URC_U-SCR|UserScoreDebStale(account,pool,score)` — point-read compare
  `stored deb-score ≠ floor((base+boost)×live-Elite-DEB, p)`; only deb-boost scores can be stale; no scan; no
  Stage-1 change (reads existing `UR_Elite-DEB`). Interface decl added. golden 33/0, Z 225/0.
- **2b collect-backstop (DONE, green):** SCORE `XE_RefreshUserScoreDeb(account,pool,score)` = `UEV_IMC` then, iff
  `URC_U-SCR|UserScoreDebStale`, `(with-capability (SCR|XE>REFRESH-USER-SCORE-DEB …) (XI_2|ApplySingularUserScoreDelta
  … 0.0))` — 0-base-delta recomputes deb-score + score totals at the **live** Elite-DEB; no-op when fresh; cap composes
  `SECURE` (same shape as `XE_ApplyTrueFungibleStakeDelta`). FVT `C_Collect` gains **PHASE 6** after phase 4: refreshes
  the collected entity's score(s) (triplet → B/S/G via `map`; singular → the one score) **after** the patron's pending
  is banked/paid at the OLD deb and last-rps advanced (RPS settle-before-weight-change preserved). Interface decls
  added both sides. No-op in current suites (deb static) but both branches load + exercise. golden 33/0, Z 225/0.
- **#12 STILL OPEN — Part 1 + 2a done; 2b written but unproven; 2c/2d/2e not built.** (An earlier attempt to close
  #12 on Part 1 + 2a + 2b was RETRACTED — owner wants the full subsystem, and 2b was found defective.)
- **2b REBUILT + PROVEN (green, discriminating test):** `C_Collect` PHASE 6 now mirrors the stake path's phase-4.5
  contract exactly — snapshot the member `pre-deb` (`URC_ScoreEntityMemberDebWeight`), refresh the patron's SCORE
  deb-score(s) (`ref-SCR::XE_RefreshUserScoreDeb`), then **`XI_SyncFvtTotalDebMirrors`** to push `(new−pre)` into the
  FVT `total-deb-score` mirror. TRUE triplets are guarded out (weight = base×promile lanes, deb-independent → their
  staleness is H4/anchor). New focused driver **`REPL/deb-staleness-proof.repl`** (fast, 22s, self-contained) proves
  it end-to-end on the CL02 class-1 treasury singular position: move ANHD's live Elite-DEB **4.29→1.39** (transfer
  99% of his EliteAuryn away via `TS01-C1::DPTF|C_Transfer` → TFT hook re-snapshots deb down; SCORE/FVT untouched),
  assert score goes **STALE**; then a collect refreshes stored deb **4290→1390** (=1000×1.39) and resyncs the mirror
  **5123.29→2223.29** with **Δmirror = Δstored = −2900** (conservation) and staleness cleared. **Negative control:**
  disabling the resync makes Δmirror=0 vs Δstored=−2900 → the assertion FAILS, so the test genuinely catches the bug
  (the static-deb golden/Z suites never execute the branch). golden 33/0, Z 225/0, deb-proof 79/0.
- **REGRESSION I introduced + FIXED (#10 refinement):** `URC_CollectClaimableRewards` — the `mc==1` member-mini-vault
  sweep branch was firing for vault/treasury, whose member vaults inject never funds (only the global pool), so a
  treasury with a single staker in a member (gc>1 ∧ mc==1) collected **0**. Now the member branch is **farm-only**
  (`(and (= (UR_FVT|FvtClass fvt-id) 0) (= mc 1))`); vault/treasury dust is swept by the gc==1 global branch. Caught
  by `AQP-comprehensive` TX-AQP-CL02 (treasury payout 59.66→0); fixed → back to 59.66. Farm golden unaffected (mc
  branch retained for class 0). This was invisible to my Z+golden gate — they carry no vault/treasury collect.
- **Stale test fixed:** `[6.4]_AQP-EXHAUSTIVE-COLLECT.repl` TX-AQP-CL03 asserted farm `G>0`; split-at-inject (#4/#8)
  removed farm global G (they advance per-member L_i), so g-post is legitimately 0 → assertion updated to `li>0`.
  Also fixed a stale 4-arg `URC_ScoreEntityUserWeight` call (arity gained `fvt-id` in #8/#25) at line 272.
- **PRE-EXISTING failures logged (NOT mine, out of #12 scope):** `AQP-comprehensive.repl` is not green on `main` —
  8 assertion failures (`[6.3]_AQP-COMPREHENSIVE` TX-AQP-C04/C05 `available-rewards` over-accumulates + a **NEGATIVE
  payout −50** at C05; `[6.4]_AQP-EXHAUSTIVE-DPNF` NF04 available-rewards) plus an MVST duplicate-insert ordering
  fragility. The negative payout looks reward-critical and deserves its own audit finding (new backlog item — likely
  #10/#11 available-rewards family). Deferred; the focused proof driver sidesteps this broken tail.
- **2b defect found (masked by static-deb suites):** `XE_RefreshUserScoreDeb` mutates the SCORE stored deb-score but
  does NOT push the equal-and-opposite delta into the FVT `total-deb-score` mirror (the vault/treasury inject
  divisor, maintained incrementally per #11). A *real* refresh therefore desyncs numerator (Σ user deb-scores) from
  divisor → breaks reward conservation at the next inject. It passed golden 33/0 / Z 225/0 only because deb never
  moves in those suites, so `URC_U-SCR|UserScoreDebStale` is always false and the refresh is a permanent no-op.
  **Lesson:** the refresh path was never actually executed by a test. Fix requires a REPL scenario that moves
  Elite-DEB (EliteAuryn coil/curl) so the branch runs.
- **Cost fact (still true, informs 2c/2d):** a trustless per-inject freshness scan is a full-table `select` over
  `FVT|T|RPS|User` (keyed `User-ID | FVT-ID | …` → `fvt-id` not index-leading); `M3-DEB-DESIGN.md` §2.7 flags gas
  calibration for the defpact `take N`.
- **Correct refresh sequence (to build):** for each stale position — settle-at-old-weight (bank pending at the OLD
  cached weight, advance last-rps) → refresh SCORE deb-score to live → resync the FVT aggregate(s) (vault: the
  `total-deb-score` mirror by ±Δdeb; farm-triplet: `contrib-weight` + `total-lane-weight`). Then: 2c enforced-fair
  inject (scan → fix → re-scan-zero → inject, atomic), 2d `InjectSweep` defpact (chunked spike fallback), 2e
  IGNIS-surcharge penalty (`forced-fix-count × RATE`, non-discountable). Design: `M3-DEB-DESIGN.md` §2.4–2.7.

- **2b REBUILT + PROVEN, and 2c PRESENCE INFRASTRUCTURE BUILT + TESTED** (later than the notes above; supersedes the
  "unproven" line). 2b: PHASE 6 now snapshots pre-deb → refreshes SCORE deb → `XI_SyncFvtTotalDebMirrors`; true-triplets
  guarded out (deb-independent as coded — lane = `base×promile`, an OPEN design question logged separately). Proof
  driver `REPL/deb-staleness-proof.repl` moves real Elite-DEB 4.29→1.39, asserts Δmirror=Δstored=−2900 (conservation);
  negative control confirms it catches the desync. Also fixed a treasury-collect regression I introduced in #10
  (member-vault sweep is now farm-only) + 2 stale tests; logged pre-existing comprehensive-suite failures as N1
  (negative payout). **2c presence:** owner-designed purpose-built `FVT|T|UserPresence` (`fvt-id | ouronet-id →
  is-present`), maintained for ALL FVT classes (shared with H4 anchor sweep). Readers `UR_FVT-UP|IsPresent` (point) +
  `URH_FvtPresentUsers` (one HEAVY select — owner confirmed cheap: ~40k gas over a 15k-row mainnet table vs ~2M ceiling;
  dirty-read + locked-consumer is the fallback if a read ever outgrows the ceiling — see the dated memory note).
  Direction-aware phase-4.7 maintenance in all 3 stake flows: STAKE add-only true; UNSTAKE `URC_FvtUserStillPresent`
  recompute across all the FVT's members → flip false only on the user's LAST withdrawal. Proven three ways:
  (a) stake→present+enumerated; (b) removal decision `URC_FvtUserStillPresent` true(staked)/false(absent);
  (c) **END-TO-END real-unstake FLIP** — a fresh account (EMMA), absent from the treasury, gets one DHWC nonce,
  stakes it (stored is-present physically `false→true`, enumerated), then FULLY unstakes (recompute → `true→false`,
  dropped from enumeration); (d) **MULTI-MEMBER partial-unstake invariant** — ANHD is present via 3 members
  (Bunnies + CodingDivision + WonderCoach); fully unstaking ONE member (WonderCoach, weight→0) KEEPS is-present=true
  (recompute scans all members, finds the other two), still enumerated; (e) **FULL multi-member walk on ONE user**
  — EMMA enters TWO members (WonderCoach via DHWC + SubsidiaryBunnies via KBN NFT), then unstakes them one at a
  time: member-1 out → STILL true (Bunnies remains); member-2 (last) out → flips false + dropped from enumeration.
  Together they prove: true while ≥1 position exists across any members/pools, flips false ONLY on the last
  withdrawal. Also proven from the code itself: the recompute is `WW_UserPresence fvt user (fold (or) false
  [weight_m>0 ∀ members])` — `or` cannot be false until EVERY member weight is 0, so a partial unstake is
  structurally incapable of flipping it early. golden 33/0, Z 225/0, deb-proof 99/0.
- **2c `CC_Inject` — BUILT + PROVEN (single-tx enforced-fresh inject; owner naming §2.8).** Reusable FVT building
  blocks: `XI_FixUserMemberDeb` (one (user,member): iff deb-based+stale → settle EVERY enabled reward stream at OLD
  deb + advance each last-rps → `XE_RefreshUserScoreDeb` live → `XI_SyncFvtTotalDebMirrors`; true-triplet/fresh =
  no-op) and `XI_FixUserFvtDeb` (maps it over the FVT's members). `CC_Inject` (`CC_`=R3 HEAVY, vault/treasury only)
  = scan `URH_FvtPresentUsers` → `XI_FixUserFvtDeb` each (scan-cut: atomic ⟹ zero-stale after, no re-scan) → inject
  on the now-fresh divisor. Presence table resolves the §2.5-PRE enumeration blocker (scan is over the small presence
  table, not RPS|User). Interface decl added; Talos wrapper `AQP-FVT|CC_Inject` (TS02-C3). **Proven (deb-proof
  DEB06):** ANHD's stale Bunnies 4.29→1.39 + CodingDivision 429→139 fixed, both FRESH; **Δmirror = −292.9 = Σ fix
  deltas** (conservation); G advanced on the fresh divisor 540.39 (not stale 833.29). golden 33/0, Z 225/0,
  deb-proof 105/0.
- **2d `MTX-AQP` module — BUILT + DEPLOYS + IMC-REGISTERED (Z 225/0/0).** New Stage-2 module
  `03_AQP/06_MTX-AQP.pact` (holds AQP defpacts), modeled on MTX-SWP: own interface `AqpMtxV1`, full gov + policy/IMC
  spine, `implements OuronetPolicyV1 + AqpMtxV1`. `MTX|2|C_Inject` 2-step defpact (owner scan-cut §2.8): each step's
  opening scan doubles as the pre-inject proof — S≤`N_FIX`→fix all + inject (terminal, yield injected:true);
  S>`N_FIX`→fix `N_FIX` (`take`), yield injected:false, continue; step 1 resumes → no-op if injected, else fix
  remainder + inject. `C|2_Inject` wrapper acquires `MTX-AQP|C>INJECT` (composes `P|SECURE-CALLER` so
  `P|MTX-AQP|CALLER` is active for FVT's `UEV_IMC`), each step re-acquires it (separate txs). FVT now exposes the
  shared building blocks the defpact calls: `URH_FvtStalePresentUsers` (scan), `XE_FvtFixUserChunk` (chunked fix,
  `FVT|XE>SWEEP-FIX`), `XE_FvtInject` (inject-core); `CC_Inject` refactored to use the same `XI_FvtInjectCore` +
  scan (DEB06 still 105/0 — behaviour-preserving). Deployed in `[2.3]_EarningPools`; `P|A_Define` (registers MTX-AQP
  in FVT's IMP) runs in `[4.0]_Sovereign-Executor`. `N_FIX=400` placeholder (calibration-gated §2.7).
  **2d Talos wrapper + end-to-end test — DONE + PROVEN.** Wrapped in **TS02-C3** (owner: no TS02-CP module for
  now — revisit if the multistep set grows): `MTX-AQP|C|2_Inject` (under `P|TS`, summons the pact, each defpact step
  self-collects IGNIS). Reverse IMC: TS02-C3's `P|A_Define` now registers the Talos-summoner guard into MTX-AQP's IMP
  (so the wrapper passes `C|2_Inject`'s `UEV_IMC`); the defpact steps then call FVT's `XE_` (MTX-AQP already in FVT's
  IMP). **Proven (deb-proof DEB08):** re-staled ANHD (deb 1.39→1.04), Talos `MTX-AQP|C|2_Inject` step 0 →
  "fixed 1 stale staker and INJECTED (terminal)" + ANHD's Bunnies asserted FRESH; `continue-pact 1` → "already
  injected — no-op" (the scan-cut relay). golden 33/0, Z 225/0, deb-proof 110/0. Only `N_FIX=400` remains
  calibration-gated (placeholder; needs real-state gas).
- **#12 COMPLETE (modulo N_FIX calibration).** Part 1, 2a, 2b, 2c (`CC_Inject`), 2d (`MTX-AQP` defpact + Talos +
  e2e), 2e (IGNIS penalty) all DONE + PROVEN. golden 33/0, Z 225/0, deb-proof 110/0.
- **2e IGNIS penalty — BUILT + PROVEN.** New `FVT|T|ForcedFixCount` (key `fvt-id | dptf-id | user-id`, `count`) +
  `UR_FVT-FFC|Count` / `WU_FvtForcedFixCount|Add|Zero`. The enforced-inject fix path `XI_FixUserFvtDebPenalized`
  (used by `CC_Inject` PHASE 0 and the defpact's `XE_FvtFixUserChunk`, now carrying `reward-dptf-id`) records
  `URC_FvtUserStaleMemberCount` (members fixed) per (fvt, lane, user); the collect-backstop self-fix (`XI_FixUserFvtDeb`)
  is NOT penalized, so self-fixing stays cheaper. `C_Collect` PHASE 7: charge `count × RATE` (`CT_FORCED_FIX_RATE=10`,
  governance placeholder) as **non-discountable** IGNIS via gross-up `penalty / URC_IgnisGasDiscount(patron)` (the
  uniform prime-time discount cancels it back to full price), then zero the count. Reward payout untouched.
  **Proven (deb-proof DEB07):** CC_Inject recorded 2 forced fixes for ANHD; his next auryn collect paid the reward
  normally AND zeroed the count (penalty charged). golden 33/0, Z 225/0, deb-proof 107/0.
- **#12 status:** Part 1, 2a, 2b, 2c (CC_Inject), 2e (penalty) DONE + PROVEN; MTX-AQP defpact (2d) built + deployed,
  remaining = its Talos wrapper + continue-pact test + `N_FIX` calibration.

## Fix #13 — M4 · SCORE: boost/deb config re-settable ONLY while the score is empty (nzs==0)  ✅ DONE + PROVEN

**Plan item:** #13 (MED) · **Finding:** M4 ("links/deb-boost settable after positions"). **Files:**
`02_SCORE.pact`, `01_ANK.pact`, `AcquisitionAnchorsV1` interface, `deb-staleness-proof.repl`.

**Root cause:** the three score-config setters — `SCR|C>ENABLE-DEB-BOOST-SCORE`,
`SCR|C>CREATE-BOOST-CLASS-LINK-SCORE`, `SCR|C>CREATE-BOOST-LINK-SCORE` — only gated on a **one-time slot** check
(`deb-boost` still false / current link == BAR). Nothing stopped changing (or first-enabling) boost/deb config on a
score that **already had live positions**, retroactively re-weighting stakers who accepted the old rules. Owner
decision (option b, discussed at length): config is **not** frozen forever — it is settable **whenever the score is
empty** (`nzs-count == 0`). To change the rules of a live score you **vacate** it (positions → 0 ⟹ nzs → 0), change
the config, then re-invite stakers who accept the new terms. This reuses the existing vacation mechanism instead of
inventing an immutability epoch.

**Fix:**
1. **`02_SCORE.pact` — 3 caps.** Added `(= (UR_SCR|ScoreNzsCount score-id) 0)` into each setter's guard and
   **dropped** the now-redundant one-time slot checks:
   - `SCR|C>ENABLE-DEB-BOOST-SCORE`: `(enforce (and (not deb-boost) (= nzs 0)) …)`.
   - `SCR|C>CREATE-BOOST-CLASS-LINK-SCORE`: dropped `= current-link BAR`; `(and (!= boost-class-id BAR) (= nzs 0))`.
   - `SCR|C>CREATE-BOOST-LINK-SCORE`: dropped `= boost-link BAR`; fold `[(!= bsid BAR) (!= bsid score-id)
     (= boost-row-sid bsid) (= nzs 0)]`.
2. **`XI_CreateBoostClassLink` — count-move (H4 #9 interaction).** Re-pointing a boost-class-link must keep the ANK
   `BoostClassLinkCount` (the #9 revoke-lock counter) exact: **unconditionally** `−1` a non-BAR old class then `+1`
   the new (old==new ⇒ net 0; old==BAR ⇒ just +1). Added the read of the old link + the conditional unbump.
3. **`01_ANK.pact` — release primitive.** New `WU_BC|DecScoreLinkCount` (floors at 0) + `XE_UnbumpBoostClassScoreLinks`
   (`UEV_IMC` + `ANK|C>BUMP-BOOST-CLASS-LINKS`), plus the interface decl in `AcquisitionAnchorsV1`. This lets a score
   that re-points away from a class release that class's revoke lock.

**Why the normal flow is unaffected:** every legitimate setup configures the score **before** staking (nzs still 0),
so all DEB01–DEB08 / golden / Z setups pass unchanged. The guard only bites the illegitimate "reconfigure a live
score" path.

**Verification (deb-proof `TX-AQP-DEB09`):** on the live context — **Bunnies** score (`nzs=1`, ANHD staked) →
`AQP-SCR|C_CreateScoreBoostLink` **and** `AQP-SCR|C_EnableDebBoost` both **rejected** (expect-failure); **WonderCoach**
score, populated earlier (ANHD+EMMA) then **fully vacated** by the DEB04/DEB05 unstakes (`nzs=0`) → the same
`C_CreateScoreBoostLink` **succeeds** and the boost-link slot actually **moves to Bunnies** (re-settable-after-vacate
proven end-to-end). golden **33/0**, Z **225/0**, deb-proof **113/0**.

**Not yet covered (Round III regression):** a dedicated boost-**class**-link count-move assertion (unbump-old /
bump-new) — the logic is exercised by the existing `[6.2.3]`/ANK green suites and correct by construction, but a
focused before/after `ANK|T|BoostClassLinkCount` assertion on a re-point would nail it.

## Feature — FVT: escrow-on-empty inject (zombie/limbo rewards)  ✅ DONE + PROVEN  (owner-directed)

**Not an audit finding** — an owner-directed behavior change on the same inject path as M1/M2/M3. **File:** `04_FVT.pact`.

**Before:** an inject on a pool with **zero** inject denominator (no stakers) **reverted** — vault/treasury via
`UEV_InjectContext` (`> denominator 0.0`), farm via the body's `> s-fresh 0.0`. Rewards could only ever be injected
into a populated pool.

**Now (owner spec):** a zero-total inject is **accepted** and its amount is **held in escrow** (physically in
`AQP|SC_NAME` custody, counted) instead of reverting. The **next** inject at a **non-zero** denominator is
**supplemented** with the escrow: `R_eff = amount + zombie` is distributed to **whoever is staked at that instant**
(pro-rata via `G` / farm split — NOT the first arriver), and the escrow is zeroed. No owner reclaim — it stays until
a normal non-zero inject flushes it.

**Implementation:**
1. **New field** `zombie-rewards:decimal` on `FVT|RPS|Global` (per `fvt-id | reward-dptf-id`) + `UDC` param, full-row
   reader round-trip, interface + impl reader `UR_FVT-RG|ZombieRewards`, writer `WU_RpsGlobal|ZombieRewards`.
2. **Removed both zero-guards** — `UEV_InjectContext` no longer requires a positive denominator; the farm
   `(> s-fresh 0.0)` enforce is gone.
3. **`C_Inject` PHASE 2+3 rewritten** (farm + vault) and **`XI_FvtInjectCore`** (the shared vault/treasury core used
   by `CC_Inject` + the `MTX|n|C_Inject` defpact) rewritten to the same shape: if denominator > 0 → **FLUSH**
   (`eff = amount + zombie`, advance `G` / farm-split on `eff`, `available-rewards += eff`, zombie → 0); else →
   **ESCROW** (`zombie += amount`, nothing else).
4. **Correctness pin:** the escrow is kept **out of `available-rewards`** until the flush, so the M1 last-claimant
   dust sweep (which pays the sole remaining claimant the full `available-rewards`) can **never** hand a prior cohort
   the pending escrow. Custody always covers `available-rewards + zombie`; no token is created or lost. The custody
   transfer (PHASE 1.1) already runs unconditionally, so the tokens really land on the zero inject.

**Proven (deb-proof `TX-AQP-DEB10`, end-to-end on `CodingDivisionTreasury`, class 1, reward Wstoa):** unstake both
stakers (ANHD nonce5 + LUMY nonce5) → denominator **0**; inject **10 then 15** at zero → **no revert**, zombie
**0 → 25**, `G` frozen at 0.13, `available-rewards` frozen at 20 (escrow isolated); re-stake ANHD (sole staker,
denom 500) → inject **5** flushes → zombie **→ 0**, and ANHD collects **exactly 30 Wstoa** (5 flush + 25 escrow).
golden **33/0**, Z **225/0**, deb-proof **121/0**.

**Not yet covered (Round III regression):** a **farm-side** escrow proof (zero-S farm inject accrues zombie, then a
member stakes and the next farm inject splits `amount + zombie`) — the vault path is proven and the farm branch is
identical in shape (`s-fresh` in place of the deb-sum), but a dedicated farm scenario would close it.

## Fix #14 — M5 · POOL: full non-self staking (self OR foreign beneficiary) for ALL asset types  ✅ DONE + PROVEN

**Plan item:** #14 (MED) · **Finding:** M5 ("OF/collectable unstake self-key vs non-self stake"). **Files:**
`03_AQP.pact`, `04_FVT.pact`, `04_TS02-C3.pact` (+ interfaces inline in each). **Owner decision:** non-self staking
(an owner staking on behalf of a foreign beneficiary — owner supplies custody, beneficiary earns weight/rewards) is a
**first-class feature for every asset type** (TF, OF, SF, NF), properly constructed so nothing strands.

**Root cause:** trackers are keyed `(pool, instrument, owner, beneficiary[, nonce])`. Every **stake** wrote the row
under the caller-supplied `beneficiary-id`, but the OF/SF/NF **unstake** path passed the sentinel `BAR` and re-derived
the beneficiary from the **self-key** `(owner, owner)` (`URC_OrtoUnstakeBeneficiaryId` / `URC_CollectableUnstakeBeneficiaryId`);
the FVT flow caps even hard-enforced `beneficiary-id == BAR` on unstake. So a stake with `owner ≠ beneficiary` landed at
`(owner, ben)` and unstake looked at `(owner, owner)` → **stranded** (forced-vacate only). TF already threaded the real
beneficiary through both legs and was the reference.

**Fix (mirror TF end-to-end):** thread `beneficiary-id` through the whole OF/SF/NF unstake chain and delete the self-key
derivation.
1. **Talos** (`04_TS02-C3.pact`): added `beneficiary-id` to the three unstake interface decls + wrappers
   (`C_UnstakeOrtoFungible` / `C_UnstakeSemiFungibleCollectable` / `C_UnstakeNonFungibleCollectable`) and their `@event`
   caps; wrappers now pass the real `beneficiary-id` to the flow (was `BAR`).
2. **FVT** (`04_FVT.pact`): `C_OrtoFungibleStakeFlow` / `C_CollectableStakeFlow` set `settle-beneficiary = beneficiary-id`
   both directions (no derivation); the two flow caps drop the `= BAR` enforce and validate the beneficiary account
   unconditionally (mirror `FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`).
3. **POOL** (`03_AQP.pact`): custody caps pass `beneficiary-id` to the sufficiency readers and call
   `UEV_StakeBeneficiaryAccount` both directions; `URC_OrtoUnstakeNoncesSufficient` /
   `URC_CollectableUnstakeNoncesSufficient` / `URC_CollectableUnstakeRollupSufficient` gained a `beneficiary-id` param and
   read the exact `(owner, beneficiary)` row/rollup; the three XE writers (`XE_OrtoFungiblePoolTracker`,
   `XE_CollectablePoolTracker`, `XE_CollectableBeneficiaryRollup`) write/remove under `beneficiary-id` both directions;
   the two self-key helpers were **deleted** (interface + body).

**Auth unchanged / no new attack surface:** unstake still authorizes on the **owner** (`CAP_StakeOwner`), returns tokens
to the owner, and the beneficiary is only the row-lookup key — exactly TF's model. All existing self-stake call sites
(tests) updated to pass `beneficiary = owner`.

**Proven (`[6.2.4]` — runs in Z):** `TX-FVT-06b` (OF) and `TX-FVT-DC-03b` (SF, the shared `C_CollectableStakeFlow`; NF is
the son=false twin): owner **ANHD** stakes for foreign beneficiary **EMMA** → row at `(owner, EMMA)` holds the stake, the
self-key `(owner, owner)` row is **empty** (where the old code stranded), **EMMA** earns the deb and **ANHD earns nothing**;
unstake naming the wrong beneficiary (owner) **fails**; unstake naming **EMMA** clears the row, removes EMMA's weight, and
returns the tokens to ANHD (state-neutral round-trip). golden **33/0**, Z **239/0**, deb-proof **121/0**.

**Not yet covered (Round III regression):** an explicit **NF** non-self scenario (identical to the SF proof with son=false)
and a **TF** non-self assertion (TF already works; a focused foreign-beneficiary round-trip would document it alongside
OF/SF).

### #14 follow-through — design settled + UI observability + dead-code removal

**Design settled (owner-driven, after a deep back-and-forth):** a *reverse-index / derive-beneficiary-on-unstake* model
was considered and **rejected** — because (a) SF/NF nonces can be co-owned by two users and a splittable holding can be
staked for *self plus multiple beneficiaries*, so a single `(owner, nonce)` maps to **many** legs, and (b) requirement 5
(unstake a *specific amount* for a *specific beneficiary*) means the owner must **name** the beneficiary + amount. So there
is no unique beneficiary to derive and no uniqueness invariant to enforce. **#14's supply-beneficiary unstake is therefore
correct and final.** (OF is the exception where a nonce *is* single-beneficiary — splitting happens at the DPOF layer and
mints distinct nonces — so OF stays whole-nonce; SF/NF keep partial-amount unstake.)

**UI observability (all on-chain, `select`-based — no new maintained tables).** The trackers already hold every position
`(pool, asset, owner, beneficiary[, nonce]) → amount`, so 8 cross-pool `URD_` readers over them (owner-side +
beneficiary-side, per instrument) answer every UI query:
- **A** staked-for-self = `…StakesByOwner(U)` rows where `beneficiary = U`;
- **B** staked-for-others (how much / for whom) = `…StakesByOwner(U)` rows where `beneficiary ≠ U`;
- **C** gifted-by-others (how much / from whom) = `…StakesByBeneficiary(U)` rows where `owner ≠ U`.
Added `URD_AQP|{Dptf,Dpof,Dpsf,Dpnf}StakesBy{Owner,Beneficiary}` (+ interface decls). The `Ben*` rollups stay (they aggregate
*across* owners for the ANK anchor mechanics, so they can't answer B/C's counterparty detail — the tracker `select` does).
Since these readers hand the UI every field of every leg, **every unstake of every type already has all its inputs**.

**Dead code removed.** `AQP|T|DPSFScoreAttribution` + `AQP|T|DPNFScoreAttribution` had **zero** write paths and **zero**
consumers anywhere in the repo (verified: all 103 references were the definitions themselves) — a never-wired scaffold.
Deleted the full cluster: 2 schemas, 2 deftables, 2 `create-table`s, the `UCK`/`UDC` builders, ~24 `UR_` readers, and all
their interface decls; scrubbed the doc references on the DPSF/DPNF tracker schemas.

**Proven (`[6.2.4]` TX-FVT-06b · 01b):** while ANHD→EMMA is staked, `URH_AQP|DpofStakesByOwner(ANHD)` lists the EMMA leg
(query B) and `URH_AQP|DpofStakesByBeneficiary(EMMA)` lists it from ANHD (query C). golden **33/0**, Z **241/0**, deb-proof **121/0**.

## Fix #15 — M6 · ANK: enforce anchor-definition bounds at issue  ✅ DONE + PROVEN

**Plan item:** #15 (MED, Phase D) · **Finding:** M6 (code half; doc half was #2). **Files:** `01_ANK.pact`,
`README_ANK.md`, test anchor definitions.

**Gap:** `UEV_Promile` allowed `anchor-precision ∈ [2,8]` and `promile < 100,000,000,000` (100 **billion**); the TF
`dptf-amount` got only `UEV_Amount` (precision/positive) — none of the documented sanity bounds were enforced, so a
single anchor could be defined with an absurd multiplier.

**Owner-set bounds (fit the mainnet AQP-BOOT anchors):**
- `anchor-precision = 3` **exactly** (matches the boot NF anchors — no boot migration).
- `ank-promile ∈ [1.0, 10000.0]`, conform to precision 3. (`10000` clears the boot `LegendaryStoa/VestaBooster`
  anchors at `3500`; the ceiling caps a single anchor's boost.)
- TF `dptf-amount ∈ [1000.0, 1,000,000.0]` — a tiny denominator can't leverage the pro-rated promile into an
  insane boost. SF (nonce) / NF (trait) have no amount, so this is TF-only.

The user's promile *accumulation* is still uncapped (pro-rate) — only the per-anchor **definition** is bounded.

**Implementation:** added named `defconst`s (`CT_ANK_PRECISION=3`, `CT_ANK_MIN/MAX_PROMILE=1/10000`,
`CT_ANK_MIN/MAX_DPTF_AMOUNT=1000/1,000,000`); rewrote `UEV_Promile` (precision `= 3`, conform, `∈ [1,10000]`);
added the `dptf-amount ∈ [1000,1M]` enforce to `ANK|C>ISSUE-DPTF`.

**Migration (all pre-mainnet):** the mainnet **boot** (`04_AQP-BOOT`) needed **no change** (already precision 3,
NF, promile ≤ 3500). Test anchors were migrated: **precision 8 → 3** everywhere; **TF** anchors additionally scaled
`(promile, amount) ×10` — **leverage-preserving** (`promile/amount` unchanged) so every downstream pro-rate/score
assertion stays valid with no refix. One asserted anchor (`TFclassBa`) was retuned to `(100, 1000)` so its
`500/1000×100 = 50` result stays exact at the coarser precision 3 (the mechanical ×10 gave `500/2100×210 = 49.999`,
a division artifact).

**Proven (`[6.2.1]` TX001·05b):** six `expect-failure` guards — promile `> 10000`, promile `< 1`, promile
non-conform to precision 3, precision `≠ 3`, dptf-amount `< 1000`, dptf-amount `> 1,000,000` — all rejected;
in-range acceptance is covered by the 20 migrated anchors that issue normally. golden **33/0**, Z **241/0**,
deb-proof **121/0**.

## Fix #12a — N1 · comprehensive-suite "negative payout" / "over-accumulate": NO core bug (3 test defects)  ✅ DONE

**Plan item:** N1 (surfaced R2 while proving #12). **Files:** `REPL/AQP-comprehensive.repl`,
`[6.3]_AQP-COMPREHENSIVE.repl`, `[6.4]_AQP-EXHAUSTIVE-DPNF.repl` (**tests only — no `.pact` changed**).

**Verdict:** the reward core is **correct**; all three reported symptoms were test-layer. The corrected assertions
are strictly stronger and now *prove* the core sound.

1. **MVST duplicate-insert abort (blocked the whole driver).** `AQP-comprehensive.repl` loaded
   `[6.2.4]_AQP-FVT` (which self-loads FVT-OF/-DC/-NF at its tail) **and then re-loaded** FVT-OF/-DC explicitly.
   The second load re-ran `Stage_01/[6.5]_DPOF` → re-issued `MetaVesta/MVST` → `Value already found` insert abort,
   before C04/C05/NF04 ever ran. **Fix:** dropped the two redundant explicit loads.

2. **C04 + NF04 "available-rewards over-accumulate" (262 vs 250; 362 vs 100).** Both inject into
   `SubsidiaryTreasury/AURYN`, which already carried **legitimate uncollected residual** (`available-rewards =
   Σinjected − Σcollected`; earlier deb-proof / CL02 injects). The identical fraction
   `…262.198557957874725030205201` in both proves NF04 is the *same* row + 100, i.e. correct accumulation, not a
   leak. **Fix:** assert the **DELTA** of the inject (`avail_after − avail_before == inject`) instead of an absolute
   — C04 Δ = 250.0, NF04 Δ = 100.0, exactly. This now *verifies* available-rewards conservation.

3. **C05 "negative payout −50."** The patron is BOTH injector and collector; payout was measured
   `post-collect − pre-**inject**`, netting the −100 inject debit into the number. `claimable` (read post-inject)
   was already the correct `50`. **Fix:** measure payout from the **post-inject** balance (mirror TX-AQP-C02) →
   payout = 50, and `payout == claimable` — proving the collect pays exactly the claimable.

**Result:** `AQP-comprehensive.repl` now **green (260/0)** — no longer an unmaintained kitchen-sink. Standard gates
unchanged: golden 33/0, Z 241/0, deb-proof 121/0.

## Fix #16 — L1 · POOL: delete a TAUTOLOGICAL whole-nonce check (not just a misplaced enforce)  ✅ DONE

**Plan item:** #16 (LOW, Phase E). **Finding:** L1 (`enforce` inside a `URC_`). **Files:** `03_AQP.pact`, `04_FVT.pact`.

**What it looked like:** `URC_OrtoStakeWholeNonceAmounts` had an `enforce` (URC contract violation) checking that each
`nonce-amount` equals the full DPOF nonce supply.

**What it actually was:** a **tautology**. `DPOF::C_Transfer dpof-id nonces sender receiver true` moves the WHOLE
nonce and ignores amounts entirely, and every caller sources `nonce-amounts` from `UR_NoncesSupplies(nonces)` — the
same supply the check compares against. So it asserted `UR_NonceSupply(n) == UR_NonceSupply(n)`, unfailable in every
real path. Whole-nonce is a **structural token-layer invariant**, not something a cap check can add.

**Fix:** deleted the helper (impl + interface decl) and removed the `whole-nonce-ok` term from both callers
(`AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY` in `03_AQP`, `FVT|C>ORTO-FUNGIBLE-STAKE-FLOW` in `04_FVT`); left the invariant
documented in a comment where the check was. The independent `(= l-n l-a)` length guard stays. golden 33/0, Z 241/0,
comprehensive 260/0 — nothing depended on it (it always passed).

**Follow-on:** wrote up the **tautological-check smell** as a reusable audit heuristic in
`OuronetInformational/memories/2026-08-14-tautological-validation-checks.md` — value-checked-against-its-own-source,
re-checking a structural token-layer invariant, duplicated caller guard, `enforce` in a `UC_`/`URC_`/`UR_`. A pass to
hunt for more of these is a Round-III task.

## Fix #17 — L4 · ANK: gate anchor revoke on liveness (`UEV_LiveAnchor`)  ✅ DONE

**Plan item:** #17 (LOW, Phase E). **Finding:** L4. **File:** `01_ANK.pact`, `[6.2.1]_AQP-ANK.repl`.

**Gap:** `ANK|C>REVOKE` checked only ownership + the H4 #9 revoke-lock — **no liveness check**. `C_RevokeAnchor`
sets `State→false` then removes the anchor from the BoostClass/AssetAnchors lists, so a **double-revoke** passed the
cap, ran a redundant `State→false` write, then aborted deep inside the utility `UC_RemoveItemAt` ("item not found")
— clean (no corruption) but opaque. The purpose-built `UEV_LiveAnchor` (`enforce (UR_ANK|State …)`) existed but was
**completely unused**.

**Fix:** added `(UEV_LiveAnchor anchor-id)` as the **first** line of `ANK|C>REVOKE`. A second revoke now aborts early
and clearly ("Anchor … must be alive for operation") before any write, and the H4 lock never evaluates against a
revoked anchor. One line; valid revokes unaffected.

**Proven (`[6.2.1]` TX002·06b):** after `TFTEMPaa` is revoked, re-revoking it is rejected via `expect-failure`.
golden 33/0, Z 241/0, comprehensive 260/0.

## Fix #18 — L6 · ANK: floor per-anchor user promile at the write chokepoint  ✅ DONE

**Plan item:** #18 (LOW, Phase E). **Finding:** L6. **File:** `01_ANK.pact`.

**Gap:** `URC_SemiFungibleAnchorPromile` / `URC_NonFungibleAnchorPromile` maintain the user's per-anchor promile
incrementally (`current ± delta`); the unstake branch subtracts with **no floor**, so if the unstake delta ever
exceeds the recorded promile the stored value goes **negative** (and the aggregate, a Σ of these, with it).

**Reachability (why guard — unlike the tautology in #16):** SF is provably safe (delta bounded by unstake
sufficiency + immutable anchor def). **NF is not**: `conform-nonces` counts staked NFTs whose **trait** matches the
anchor, read from **mutable collectable metadata**. NFT metadata can be changed *from outside the staked position*
at the DPDC layer — and a collectable-level "lock metadata" tag doesn't truly close it (toggleable; and the DPDC
**module admin** can bypass any lock via `acquire-module-admin` + direct table write). So AQP cannot rely on an
upstream invariant; it must **guard its own accounting at its boundary** (owner decision).

**Fix:** floored the stored promile at 0 in **`WW_Anchors`** — the SOLE write chokepoint through which every
per-anchor user promile write flows (TF/SF/NF × incremental/absolute, and any future path). One guard covers them
all; the aggregate (`XI_2|RecomputeAffectedBoostAggregates` = Σ of per-anchor promiles) is then non-negative too.
Chose a **floor, not an `enforce`**: a hard abort on unstake would strand a staker's assets when the metadata is in
a bad state; the clamp lets unstake always succeed, and the `…PromileAbsolute` resync recomputes the true value.
(`max` is not a Pact-5 builtin — used `(if (< promile 0.0) 0.0 promile)`.)

**Verification:** golden 33/0, Z 241/0, comprehensive 260/0 (valid flows unaffected — the clamp only bites a
negative, which normal stake/unstake never produce). A forced-desync negative test (mutate an NFT trait while its
nonce is staked, then unstake) is awkward to stand up in the harness → Round-III item.

**Related:** L7 (#19) is the SCORE-side analogue (mutable SF/NF definition rows → asymmetric base-score delta) — same
"reachable via mutable external definition" root; to be handled next.

## Fix #19 — L7 · SCORE: NO FIX — misdiagnosis (negative user base is by design)  ✅ CLOSED

**Plan item:** #19 (LOW, Phase E). **Finding:** L7 ("mutable defs → asymmetric delta → negative base; same no-floor
root as H1"). **Outcome:** **no code change** — the finding's premise is wrong.

**What we tried:** the obvious analogue of #18 — floor `local-base-raw` at 0 in
`URC_SingularUserScoreDeltaFromSignedUserBase` (the single base-delta chokepoint for LP/TF/SF/NF).

**Why it's wrong:** it immediately broke `[6.2.5]` TX-VCT-DPNF01/02/03 (Z 236/10). Instrumenting the base proved
why: that DPNF probe stakes an NFT whose **trait-score definition is −1**, so on stake the user base goes to
**−1** and on unstake back to **0** — a correct round-trip. SCORE base = **Σ trait-score-values**, and trait scores
**can be negative by design** (a trait that *reduces* weight). A negative user base is therefore **legitimate**, not
corruption. Flooring `local-base-raw` clamped the −1 stake to 0, so the +1 unstake left base = 1.0, the pool never
registered as fully vacated (nzs stuck at 1), and stake never re-enabled. Reverted; Z back to 241/0.

**The L6 vs L7 distinction (the real lesson):** #18's floor was correct because ANK promile = `count × ank-promile`
with `ank-promile ∈ [1,10000]` and `count ≥ 0` ⇒ promile is **always ≥ 0**, so a negative there can *only* be an
asymmetric-def bug and the floor never bites a valid value. SCORE base has no such lower bound (negative traits), so
the same floor corrupts valid data. **Before flooring any accumulator, confirm the negative is actually invalid** —
logged in `memories/2026-08-14-tautological-validation-checks.md`.

**Residual (the def-change asymmetry):** if a definition changes between stake and unstake the deltas differ, but a
*wrong* base (not a negative-is-invalid case) is corrected by the existing `applied-def-revision-nonce` absolute
resync — not by a floor. So L7 needs no guard. golden 33/0, Z 241/0.

## Fix #19 (CORRECTED) — L7 · SCORE: negative score weight — real root was the DPDC −1.0 unscored sentinel  ✅ DONE

**Supersedes the "NO FIX / misdiagnosis" entry above.** That first pass was wrong. Owner flagged that negative
scores are NOT a designed feature, which forced a deeper trace of *where* the −1 came from.

**Real root:** the `[6.2.5]` DPNF probe mints a **metadata-less** nonce. In the DPDC UDC layer,
`UDC_NoMetaData → UDC_MetaData {} → UDC_NonceMetaData -1.0 …` — so an unscored nonce's native score defaults to the
**`-1.0` "unscored" sentinel**. The score is model-0, whose weight (`URCx_DpnfModelZeroDpdcNativeRawWeight`) reads
the **raw** score (`UR_N|RawScore`, returns −1.0) and counts it as a real negative → base = −1. (DPDC's *cooked*
reader `UR_N|Score` already maps −1.0 → 0, but the weight path bypassed it.) Compounding it, DPDC `UEV_Score`
enforced only `>= -1.0`, so real negatives in `[-1.0, 0)` were also settable.

**Fix — all at the source (no aggregate floor; that broke the vacate netting):**
1. **`02_SCORE.pact` `URCx_DpnfModelZeroDpdcNativeRawWeight`** — clamp each per-nonce native score `<0 → 0`, so an
   unscored/sentinel (or any negative) nonce contributes 0, never a negative stake weight.
2. **`02_SCORE.pact` definition validators** — `UEV_NonFungibleScoreDefinitionTrait` / `…Set` enforce
   `trait/class score ≥ 0`; the SF `nonce-score-value` validator enforces `≥ 0`. Negatives can't be authored.
3. **`10_DPDC-N.pact` `UEV_Score`** — tightened `>= -1.0` to `(or (= score -1.0) (>= score 0.0))` — only the exact
   sentinel or a non-negative value is settable.

**Proven:** `[6.2.5]` TX-VCT-DPNF01 now asserts the unscored nonce yields base **0** (was −1); `[6.2.2]` rejects a
negative SF definition value; `[6.1]` rejects a negative DPDC nonce score (full DPDC chain). golden 33/0,
**Z 242/0**, comprehensive 260/0, deb-proof 121/0. The def-change asymmetry (mutable def between stake/unstake) is
still handled by the `applied-def-revision-nonce` resync — separate from this sentinel/negative fix.

## Fix #21 — L10 · FVT: double member-settle in C_Collect — already resolved by #12; removed the dead scaffolding  ✅ DONE

**The finding morphed.** ROUND-01 flagged that `C_Collect` settled the member Tier-2 **twice** (a bare pre-settle
plus a second settle inside the PHASE-0 farm ghost-TVL sync) — traced harmless (2nd = no-op) but wasted work +
ordering inconsistency vs the stake flow.

**Current reality (post-#12):** the double-settle is **already gone.** The #12 2b split-at-inject redesign removed
the farm ghost-TVL sync from `C_Collect`'s PHASE 0 (see the `04_FVT.pact` comment: *"farm ghost-TVL sync REMOVED …
the pre-settle above still flushes parked pending"*). `C_Collect` now settles the member **exactly once** — the
bare `XI_2|SettleMemberTier2` (farm-only, `FvtClass 0`). The second-settle path was **orphaned**:
- `XI_CollectRpsPreScore` — zero real callers (only a doc-comment named it in the C_Collect call-tree map).
- `XI_1|CollectSettleAndBank` — called **only** by the dead `XI_CollectRpsPreScore`.
- `URDC_BuildCollectScorePlan` — built the ghost-TVL plan **only** for `XI_CollectRpsPreScore` (its `@doc` even
  said "ghost TVL sync scope for C_Collect").

Both jobs of the dead pair are covered live: **settle** → the bare `XI_2|SettleMemberTier2`; **bank pending** →
`XI_1|BankScorePendingRewards` (the active score-pending bank path).

**Fix:** deleted the three orphaned functions (`XI_CollectRpsPreScore`, `XI_1|CollectSettleAndBank`,
`URDC_BuildCollectScorePlan`) + scrubbed the stale doc-comment reference. **Zero behavioral change** — all three
were unreachable. Removing them also kills a live-looking `Settle`+`Bank` scaffold a future reader could wrongly
re-wire (the exact ordering trap L10 warned about). No interface/slave references existed.

**Proven:** golden 33/0, **Z 242/0**, comprehensive 260/0, deb-proof 121/0 — bit-identical to pre-change, as
expected for pure dead-code removal.

## Refactor R-INJECT — FVT: collapse two duplicate inject-distribution blocks onto ONE core  ✅ DONE

**Bad practice caught by owner (2026-08-15):** the inject distribution logic (custody transfer · escrow/flush ·
available-rewards · `GAS|INJECT`) existed as **two hand-maintained copies** — inline in `C_Inject` (farm +
vault/treasury) and again in `XI_FvtInjectCore` (vault/treasury only, used by `CC_Inject` + the `MTX|n|C_Inject`
defpact via `XE_FvtInject`). #12 added escrow-on-empty to **both** by hand — exactly the drift risk two copies
invite. Owner rule: *one operation ⟹ one code block; running two blocks for the same thing is forbidden.*

**Fix — single source of truth:**
- **Promoted `XI_FvtInjectCore` to THE inject core for all FVT classes** — added the farm branch (denominator
  `URC_FarmInjectDenominatorFresh` + distribute via `XI_1|FarmSplitInject`) so it handles farm split-at-inject AND
  vault/treasury RPS, escrow-aware. This block is now byte-for-byte the former `C_Inject` inline logic.
- **`C_Inject` is now just cap wiring** — `(UEV_IMC)` + `(with-capability (FVT|C>INJECT …) (XI_FvtInjectCore …))`.
  It's the NAIVE path (distributes over the current, possibly deb-stale divisor).
- `CC_Inject` and `XE_FvtInject` are **unchanged** — both still enforce `class≠0` *before* calling the core, so
  they never reach the new farm branch; behavior identical. Freshness stays a caller concern (they fix stale
  members first; `C_Inject` doesn't).
- Scrubbed the `UEV_InjectContext` doc that pointed at "the C_Inject body" → `XI_FvtInjectCore`.

**Result:** all three inject entrypoints (`C_Inject`, `CC_Inject`, defpact) route through one distribution block —
one place to audit, one place to fix. **Zero behavioral change** (the core IS the old inline logic; enforced-fresh
variants are class-guarded away from the farm branch).

**Proven:** golden 33/0, **Z 242/0**, comprehensive 260/0, deb-proof 121/0. Inject is exercised by 26 invocations
across the suite (farms via golden triplet-collect + `[6.2.4]`, vaults/treasuries, escrow-on-empty DEB10, CC_Inject
enforced-fresh, and the 2-step defpact). Principle written up in
`memories/2026-08-15-single-core-no-duplicate-logic.md` (StoicSyntax candidate rule).

## Fix N2 — FVT: enforced-fresh inject (CC_Inject + defpact) was farm-excluded on an INCOMPLETE rationale  ✅ DONE

**Finding (owner, 2026-08-15):** `CC_Inject` and the `MTX|2|C_Inject` defpact were `class≠0`-guarded
("vault/treasury only"). The stated rationale — *"farms compute a fresh split-at-inject denominator and never read
the mirror"* — is **only half true**. It holds for the farm **Tier-1** denominator `S`
(`URC_FarmInjectDenominatorFresh`, recomputed live), but the farm **Tier-2** `L_i`-advance divisor is
`URC_ScoreEntityMemberTier2Divisor` → `URC_ScoreEntityMemberDebWeight` → **`SCR|ScoreTotalDebScore`, the maintained
deb mirror that goes stale (S1)** for singular / non-true-triplet members. A **mosaic farm** can carry exactly such
a singular score (owner's motivating case). So a farm inject during a stale window splits that inject by lagged
weights — the same inter-staker unfairness `CC_Inject` was built to eliminate for vaults — with no way to force
freshness. (Not a conservation break: `ScoreTotalDebScore == Σ stored user debs` always, kept by
`XE_RefreshUserScoreDeb`'s 0-base-delta apply; it's a fairness lag. Farms self-heal at collect via the
class-agnostic PHASE-6 backstop.)

**Fix — extend the enforced-fresh path to ALL FVT classes:**
- Dropped the `class≠0` `enforce` on `CC_Inject` and `XE_FvtInject`. (Bonus StoicSyntax: those were bare enforces
  after `UEV_IMC`; removing them also clears that wart.) The fix machinery is already class-agnostic
  (`XE_FvtFixUserChunk` → `XI_FixUserMemberDeb` → `XE_RefreshUserScoreDeb`; `URC_FvtTier1IndexRps` settles farm
  `L_i` vs vault `G`; `URH_FvtStalePresentUsers` is populated for every class at stake) and the inject core is
  farm-capable after R-INJECT — so removing the guard is all that was needed.
- Added the **INJECT FUNCTION MATRIX** + the farm Tier-2-deb rationale to the `@doc`s of `C_Inject` / `CC_Inject`
  / `XE_FvtInject` and the Talos `AQP-FVT|CC_Inject` wrapper.

**Proven — new `deb-proof` cases:** DEB11 (`AQP-FVT|CC_Inject` on the class-0 `OuroLpFarm`) → *"Successfully
FRESH-injected 50.0 OURO"*, **zero stale present users after** (enforced-fresh guarantee on a farm), available-rewards
flushed `0→50`. DEB12 (`MTX-AQP|C|2_Inject` defpact on the farm) → *"fixed 0 stale... INJECTED 20.0 (terminal)"*,
`50→70`, step-1 no-op. golden 40/0, **Z 267/0**, comprehensive 283/0, **deb-proof 146/0**.

**⚠️ Proof caveat (follow-up):** DEB11/DEB12 prove the farm inject paths **execute and distribute**, but did NOT
exercise an actual farm-member **deb-fix** — `OuroLpFarm`'s only member is a **true-triplet** (deb-independent
lanes ⇒ correctly `stale=0`, nothing to fix). The stale→fresh fix itself is proven on **treasuries** (DEB06/DEB08)
with the **identical class-agnostic code**, so N2 is correct by equivalence. A direct mosaic-farm-**singular**-member
stale→fresh demonstration needs a farm with a singular class-0 member added to the harness — deferred as a
test-only follow-up (no code impact).

**Follow-on cleanup (owner, StoicSyntax) — `XE_FvtInject` → `XB_FvtInject`:** once the class guard was gone, the
former `XE_FvtInject` body was **byte-identical** to `C_Inject`'s (both `UEV_IMC` + `with-capability (FVT|C>INJECT)`
+ `XI_FvtInjectCore`). Owner: *"no point wrapping the core in an XE variant — use a singular `XB` variant protected
with `UEV_IMC` + `with-capability`, so it works within AND outside the module."* Done: renamed to `XB_FvtInject`
(the correct prefix — it's called internally by `C_Inject` and cross-module by the `MTX|n|C_Inject` defpact), and
`C_Inject` now **delegates** to it (`(XB_FvtInject …)`) instead of re-declaring the same auth+core body. `CC_Inject`
still calls `XI_FvtInjectCore` directly (it needs the scan/fix + inject under ONE `FVT|C>INJECT` scope so the
`@event` fires once). Behavior-identical: golden 40/0, Z 267/0, comprehensive 283/0, deb-proof 146/0.

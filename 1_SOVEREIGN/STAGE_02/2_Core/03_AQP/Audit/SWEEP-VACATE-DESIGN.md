# Score-rewrite sweep + vacate rehaul — Phase-0 design (H4 half-2 · L9/#20 · S1)

**Status:** ✅ APPROVED / LOCKED by owner 2026-08-15. Phase 0 complete. Evidence base = 4-way deep-read map
(deb-fix chain, vacate walk, anchor lock/revoke, score-write path).

**DECISIONS (locked 2026-08-15):**
- **D1** Module home = **extend `MTX-AQP`** (its charter is "all AQP multi-tx defpacts"). ✅
- **D2** Anchor ops = **revoke + re-price** an in-use anchor (same walk serves both). ✅
- **D3** Sweep freeze = disable **stake admission** on affected pools + `sweep-in-progress` flag; **collect stays
  open** (self-heals via the PHASE-6 backstop). ✅
- **D4** Sweep gas = **owner-initiated → owner pays**; NO staker 2e-penalty. ✅
- **D5** Triplet + anchor = **SUPPORTED — do NOT forbid.** The sweep MUST carry a **triplet-lane recompute** path
  (option a); an anchor change on a triplet's boost-class re-prices its lanes (`URC_ComputeTripletLanes`). ✅
- **D6** Vacate hash-commitment = **wire** the existing (currently-dead) hash fields during the rehaul. ✅

All owner realizations (below) confirmed TRUE and acted on: the shared skeleton is real, the recompute engine +
pagination + presence tracking already exist, the reverse index is the one new structure, and the sweep recompute
is DEEPER than deb-fix (aggregate-promile refresh) + must handle triplet lanes.

---

## 1. The key realization

The "core score-rewrite sweep" is **mostly assembly of pieces that already exist**, plus **one** genuinely new
data structure. Pact can't pass a terminal-action lambda across modules, so the shared core is **NOT one generic
function** — it's:

1. **A per-position recompute engine** — `XI_2|ApplySingularUserScoreDelta` (02_SCORE:3613). A `0`-base-delta call
   recomputes `boosted`/`deb` at **live promile + live Elite-DEB** and deltas the `SCR|T|Score` totals — base and
   nzs untouched. This IS the rewrite. *(exists, proven)*
2. **A settle-at-old-deb primitive** — bank pending across every reward stream, advance `last-rps`, before any
   weight change. Used identically by deb-fix (`XI_FixUserMemberDeb` step 1) and vacate
   (`XI_3|RpsVacatePreZero` → `FVT::XE_BankScorePendingRewards`). *(exists)*
3. **A pagination defpact template** — re-scan a bounded set each step, `take N`, apply a chunk, `yield`/`continue`
   until dry. This is exactly `MTX|2|C_Inject` (06_MTX-AQP:158) with `N_FIX=400`. *(exists as a shape to replicate)*
4. **Present-user enumeration** — `FVT|T|UserPresence` + `URD_FvtStalePresentUsers`, class-agnostic, maintained at
   stake (`XI_SyncFvtPresence`). *(exists)*

**The ONE missing piece:** a **reverse index** `boost-class → [score-ids]`. Today `ANK|BoostClassLinkCount` stores
only an integer `count` (the H4/#9 lock is a coarse count-gate); there is **no** enumerable map from an anchor /
boost-class to the scores that employ it. Answering "which scores does this anchor touch?" currently needs a full
`SCR|T|Score` scan. This index is the new build that unlocks the whole sweep. **Good news:** the lock *decrement*
writer already exists — `WU_BC|DecScoreLinkCount` / `XE_UnbumpBoostClassScoreLinks` (01_ANK:1488/1807) — so revoke's
counter teardown is wiring, not new code.

## 2. The shared walk skeleton (steps identical across all three consumers)

```
enumerate bounded unit-set              (per-consumer SCAN — differs)
  └─ per unit:
       1. settle pending @ OLD deb across every reward stream, advance last-rps   (SHARED)
       2. SCORE delta via XI_2|ApplySingularUserScoreDelta                          (SHARED engine)
       3. re-sync FVT aggregate (deb mirror) + RPS book/checkpoint                  (SHARED)
       4. TERMINAL ACTION                                                           (per-consumer — differs)
```

**The terminal is what forks the three consumers:**

| consumer | scan (position source) | terminal action |
|---|---|---|
| **deb-fix** (exists) | `URD_FvtStalePresentUsers` (one FVT) | recompute: delta=0, refresh deb. No custody, no unlink. |
| **anchor sweep** (new) | reverse-index: anchor→BC→scores→pools/FVTs→present users | recompute (see §4 — DEEPER than deb-fix), then ONCE at end: unlink + revoke + `WU_BC|DecScoreLinkCount`. |
| **vacate** (rehaul) | `URDC_Vacate*OwnerRows` → legs → unique beneficiaries (one pool) | zero: delta=−full, zero tracker slots, then **bulk custody-return** last; toggle session begin/finalize. |

## 3. Consumer 1 — deb-fix: re-host (light)

Already runs on primitives 1-4. Action = **confirm it uses the shared helpers and leave behavior identical**
(gates must stay bit-for-bit). This is the regression harness that proves the extracted core before the new
consumers bind to it. Likely near-zero code change — mostly naming/placement so sweep + vacate can call the same
helpers. **Lowest risk; do first.**

## 4. Consumer 2 — anchor sweep (the real new build)

### 4a. Flow
1. Owner calls "retire/re-price anchor A" (new client entry, Talos-wired).
2. Resolve `A → boost-class BC → {scores}` via the **new reverse index**.
3. **Freeze**: mark `sweep-in-progress` + disable stake admission on the affected pools (bounds the position set;
   see §6). Collect stays OPEN (a mid-sweep collect self-heals via the PHASE-6 backstop — idempotent).
4. Apply the anchor change to the def (re-price: new promile; revoke: mark dead).
5. **Paginate** (defpact, `take N` per step) over all present users on the affected scores → per-position recompute.
6. Teardown (once, terminal): re-enable stake; for revoke → `XI_RevokeAnchorBookkeeping` + `WU_BC|DecScoreLinkCount`.

### 4b. ⚠️ Complication A — the sweep recompute is DEEPER than deb-fix
deb-fix assumes the user's **aggregate-promile is already correct** (only Elite-DEB moved). But an anchor *def*
change makes the stored `ANK|T|UserBoost.aggregate-promile` itself stale (it was maintained at stake with the OLD
promile). So each affected holder needs **two** refreshes, in order:
  1. **refresh aggregate-promile** — re-derive Σ(count × NEW anchor-promile) for the holder
     (`XI_2|RecomputeAffectedBoostAggregates` family already writes this field);
  2. **then refresh score deb** — `XE_RefreshUserScoreDeb` (which reads the now-fresh aggregate-promile).
So the sweep's per-position terminal = **promile-aggregate refresh + deb refresh**, a superset of deb-fix's single
deb refresh. Design the walk's terminal as a small ordered pair here.

### 4c. ⚠️ Complication B — triplet members (S4-adjacent)
True-triplets are deb-*independent* (lane weights), so the deb-fix no-ops on them — BUT triplet **lane weights are
computed from ANK promiles** on the bronze/silver/golden boost-class-links (`URC_ComputeTripletLanes`). So an anchor
change on a triplet's boost-class **does** change its lanes, which the deb-fix path does NOT handle. The sweep must
therefore also carry a **triplet-lane recompute** path for affected triplet members. **DECIDED (D5, locked):
build option (a)** — triplet+anchor is a supported combo, so the sweep terminal includes a triplet-lane recompute
(re-derive lanes via `URC_ComputeTripletLanes` at the new promile, write the lane weights + the member's Tier-2
`total-lane-weight` aggregate). Forbidding anchors on triplets is explicitly OFF the table.

### 4d. The reverse index (new)
Add `boost-class → [score-ids]` (append on link in `SCR::XI_CreateBoostClassLink`, remove on unlink). Bounded by
score *definitions* (few), not stakers. This replaces the coarse count with an enumerable set; the existing
`BoostClassLinkCount` can be derived from it (or kept alongside as the O(1) lock gate).

## 5. Consumer 3 — vacate rehaul

- **Collapse** the 8 entrypoints (`C_FullVacate*`×4 + `C_Vacate*Legs`×4) → **1 shared vacate core** (asset-kind
  dispatch INSIDE, kinds 1-4 already constants) **+ 2 defpact variants** (full one-tx for small pools; paginated
  legs for large — the 10k-staker gas ceiling falls out) **+ `C_AbortVacate`**.
- **Reuse** the shared walk: the per-leg unwind (settle → SCORE-zero → **custody-return last**) already exists
  (05_VCT:2104-2166); wrap it in the pagination template. Vacate's terminal = zero + bulk custody-return + session
  begin/finalize (`XI_EnsureVacateBegun` / `XI_MaybeFinalizeVacate`).
- **Delete dead code (L9/#20):** `URC_VacateBatchLegParityOk` (05_VCT:1261) + `VACATE-MAX-LEGS`=16 (05_VCT:264) —
  confirmed zero callers; live caps use `VACATE-GAS-MAX-*`.
- **Hash-commitment decision:** the `initial/phase/last-vacate-hash` fields exist and are read but every writer
  passes `""` (never populated). Either wire them (tamper-evidence across multi-tx legs) or drop them. Recommend
  **wire** during the rehaul (cheap integrity for the paginated path); flag if you'd rather drop.

## 6. Cross-cutting decisions (recommendations)

| # | Decision | Recommendation |
|---|---|---|
| D1 | Module home for the new defpacts | **Extend `MTX-AQP`** (assumed). |
| D2 | Anchor ops | **Revoke + re-price** (assumed). |
| D3 | Freeze semantics during a sweep | Disable **stake admission** on affected pools + `sweep-in-progress` flag on the AQP-POOL session row; **leave collect open** (self-heals). |
| D4 | Who pays the sweep gas | **Owner-initiated → owner pays** the paginated sweep. NO staker 2e-penalty (they didn't cause it; contrast the inject forced-fix penalty). |
| D5 | S4 / triplet+anchor | **LOCKED: build triplet-lane recompute** into the sweep (§4c). Anchors on triplets stay supported. |
| D6 | Vacate hash-commitment | **LOCKED: wire** the existing hash fields. |

## 7. Proposed implementation order (the 4 phases)

- **Phase 1 — extract the shared primitives + build the reverse index.** Factor the settle/recompute helpers into
  callable-by-all form; add `boost-class → [score-ids]`. No behavior change yet. ✅ **DONE** — reverse index built:
  `ANK|BoostClassLinkCount{count}` → `ANK|BoostClassScoreLinks{score-links:[string]}` (the SET is the single source
  of truth; `UR_BC|ScoreLinkCount = (length …)`, so the #9 revoke lock is unchanged). New `UR_BC|ScoreLinks` reader;
  `WU_BC|Add/RemoveScoreLink` + `XE_Bump/UnbumpBoostClassScoreLinks(bc, score-id)` maintain the set from
  `SCR::XI_CreateBoostClassLink` (add on link, remove on re-point). Behavior-neutral (golden 40/0, Z 267/0,
  comprehensive 283/0) + enumerability proven (`deb-proof` DEB13: `UR_BC|ScoreLinks` returns the linked score,
  count==length, lock armed). The "primitive extraction" is a no-op — the map confirmed the deb-fix chain
  (`XE_RefreshUserScoreDeb`, `XI_FixUserMemberDeb`, `XE_FvtFixUserChunk`, the MTX pagination shape) is already
  well-factored + cross-module-callable; phases 2-4 reuse it directly.
- **Phase 2 — re-host deb-fix onto the shared primitives.** Gates bit-identical = phase-1 proof. ✅ **DONE — VERIFIED,
  no re-host needed.** The deb-fix and the vacate walk ALREADY converge on the same primitives (no duplication to
  merge):
  - **SETTLE (old-deb):** vacate's `XE_BankScorePendingRewards` (04_FVT:4728) → `XI_1|BankScorePendingRewards`
    (3939) → `XI_2|SettleMemberTier2` + **`XI_2|BankUserTier1Pending`** (4199) — the *exact* primitive the deb-fix's
    `XI_FixUserMemberDeb` calls directly per reward stream. One settle implementation, two callers.
  - **RECOMPUTE (score weight):** both bottom out in **`XI_2|ApplySingularUserScoreDelta`** (02_SCORE:3613) —
    deb-fix via `XE_RefreshUserScoreDeb` (0-base), vacate via `XE_ApplyTrueFungibleStakeDelta` (signed).
  So phases 3-4 REUSE these directly; no code changed in phase 2 (gates unchanged from phase 1). See the
  Shared-core contract below.

### Shared-core contract (verified phase 2 — the primitives phases 3-4 bind to)
| need | primitive (already exists) | how the sweep/vacate uses it |
|---|---|---|
| enumerate positions | `ANK::UR_BC|ScoreLinks` (phase 1) + `FVT::URD_FvtStalePresentUsers` / `FVT|T|UserPresence` | sweep: anchor→BC→scores→present users; vacate: legs |
| settle @ old-deb (cross-module) | `FVT::XE_BankScorePendingRewards(ben, pool, plan)` | both — banks pending across streams before any weight change |
| recompute deb (0-base) | `FVT::XE_RefreshUserScoreDeb`-driver / `SCR::XE_RefreshUserScoreDeb` → `XI_2|ApplySingularUserScoreDelta` | sweep deb terminal |
| signed score delta (zero/unstake) | `SCR::XE_ApplyTrueFungibleStakeDelta` (+OF/SF/NF) `direction=false` | vacate terminal |
| pagination | replicate the `MTX|2|C_Inject` defpact shape (scan → `take N` → chunk → yield/continue) | sweep + vacate defpacts |
| lock decrement | `ANK::XE_UnbumpBoostClassScoreLinks(bc, score-id)` (phase 1) | sweep revoke teardown |

**Phase 3 must still BUILD (not reuse — sweep-specific, the DEEPER recompute):** an exposed aggregate-promile
refresh XE_ (anchor def changed ⇒ stored aggregate-promile stale), a triplet-lane recompute XE_ (D5), the
`sweep-in-progress` freeze, and the sweep client + defpact in MTX-AQP.
- **Phase 3 — anchor sweep.** Reverse-index scan + freeze + per-position (promile-aggregate + deb + triplet-lane)
  recompute + unlink/revoke/decrement teardown. New Talos client + defpact in MTX-AQP. Prove: retire an in-use
  anchor end-to-end + re-price; lock releases.
- **Phase 4 — vacate rehaul.** 8→1+2 defpacts, asset-kind dispatch, dead-code removal, hash-commitment. Riskiest
  (asset custody) → last, heavy tests. Absorbs L9/#20.

## 8. Open risks / notes
- Cross-module terminal actions can't be lambdas in Pact → each consumer owns its defpact; the shared part is the
  primitive set + the pagination shape, not a single mega-function. Keep the shared helpers in one place so they
  don't drift (the single-core lesson from R-INJECT).
- The sweep's DEEPER recompute (§4b) and triplet lanes (§4c) are the two places this is more than "reuse deb-fix."
- `N_FIX=400` is inject-calibrated; the sweep/vacate chunk sizes need their own gas calibration (different per-unit
  cost).

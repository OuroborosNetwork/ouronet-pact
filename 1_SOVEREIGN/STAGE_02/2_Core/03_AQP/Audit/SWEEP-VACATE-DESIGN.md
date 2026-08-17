# Score-rewrite sweep + vacate rehaul — Phase-0 design (H4 half-2 · L9/#20 · S1)

**Status:** ✅ APPROVED / LOCKED by owner 2026-08-15. Phase 0 complete. Evidence base = 4-way deep-read map
(deb-fix chain, vacate walk, anchor lock/revoke, score-write path).

**DECISIONS (locked 2026-08-15):**
- **D1** Module home — REFINED (owner, 2026-08-15): the **single-tx `CC_SweepRevokeAnchor` lives in `AQP-FVT`**
  (the earliest module that can call ANK/SCR/POOL/FVT, and it owns the recompute machinery; MTX-AQP's charter is
  *defpacts only*, and a single-tx orchestrator isn't one). The future **paginated `MTX|n` defpact** variant DOES
  belong in `MTX-AQP` (calling the FVT sweep helpers). ✅
- **D2** Anchor ops = **revoke + re-price** an in-use anchor (same walk serves both). ✅
- **D3** ~~Sweep freeze = disable stake admission only; collect stays open.~~ **REVISED 2026-08-15:** the sweep
  freezes **stake admission AND collect** on affected pools until it completes. Reason: `XE_RefreshUserScoreDeb`
  recomputes deb at the *stored* aggregate-promile — it does NOT recompute the aggregate. During a revoke/re-price
  sweep the aggregate is in flux (anchor removed/re-priced globally, holders recomputed over N txs), so a holder
  who collects **before being swept** would refresh deb against a stale-high aggregate ⇒ over-collect. The PHASE-6
  backstop heals *deb* staleness, not *aggregate* staleness. Freezing collect for the bounded operator-run sweep is
  the simple, correct fix. (Making the collect backstop aggregate-aware — the alternative — touches the hot collect
  path; deferred.) ✅

**Phase-3 build order (revoke-first):** (1) expose `XE_RecomputeUserBoostAggregates` (wrap
`XI_2|RecomputeAffectedBoostAggregates`); (2) triplet-lane recompute XE_ (D5); (3) `sweep-in-progress` freeze
(stake **+ collect**) on affected pools; (4) swept-revoke path (removes the anchor, skips the `set==0` lock because
the sweep refreshed everyone — distinct from `C_RevokeAnchor`; the reverse-index set is UNCHANGED by anchor revoke,
scores stay linked) + the paginated sweep defpact in MTX-AQP; (5) Talos + end-to-end proof. Re-price is a later 3b
(adds a per-anchor-user-promile refresh before the aggregate refold).
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
4. **Present-user enumeration** — `FVT|T|UserPresence` + `URH_FvtStalePresentUsers`, class-agnostic, maintained at
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
| **deb-fix** (exists) | `URH_FvtStalePresentUsers` (one FVT) | recompute: delta=0, refresh deb. No custody, no unlink. |
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

## 5. Consumer 3 — vacate rehaul  [REVISED 2026-08-16 — parallel-safe model, owner-approved]

> Supersedes the earlier "1 core + 2 defpact variants" plan. The defpact is **dropped** (see 5.1). The rehaul is now:
> a single-tx agnostic path (shipped) + a parallel-safe multi-tx Legs path (begin → parallel drain → finalize).

### 5.0 Single-tx agnostic path — ✅ SHIPPED (commits this session)
`CC_FullVacate(pool-id)`: `UEV_IMC` → read `aqp-class` → dispatch to per-kind `XI_Vacate*Pool` → shared `XI_Vacate*Batch`
cores. On-chain scan (`URHC_VacateNonceOwnerRowsRaw`, `URHC_VacateTfOwnerRows`), **no UI legs**. All 5 classes proven
(`TX-VCT-{TF01b,L01b,L02b,DPNF02b,CC01}`). Class-1 drains native TF + every live DPOF satellite via new
`URD_AQP|ActivePoolDpofIds` (HEAVY select). `XB_Vacate{True,Orto,Semi,Non}Fungible` + Talos wrappers. This is the
"small pool, one click" path.

### 5.1 Large-pool requirement — ABSOLUTE PARALLELISM (why not a defpact)
Owner requirement: the UI splits the leg list into N txs; **two txs built from the same list must NEVER write-conflict**,
or parallel submission errors out. A `defpact` is the wrong tool — vacate legs are *independent* (no ordered
dependency), so a defpact's sequential guarantee buys nothing, and its **fixed step count caps pool size** (10 steps
can't be extended mid-run). Use **independent txs** the UI fires until the pool is empty.

### 5.2 Conflict trace (source: vacate leg-unwind write classification)
- **PARALLEL-SAFE:** only the per-staker tracker-zero — `AQP|T|{DPTF,DPOF,DPSF,DPNF}Tracker`, keyed
  `pool|asset|owner|beneficiary(|nonce)`. Disjoint slices touch different rows.
- **Tier-1 per-beneficiary rows** (`UserScore`, `RPS|User`, `ANK|Anchors`, `ANK|UserBoost`, `BenDptfTotal`,
  `BenDpsf/DpnfNonceTotal`, `BenDpsf/DpnfAnkMeta`): collide **iff a beneficiary spans two txs** → FIX: **partition by
  beneficiary** (never split one beneficiary across txs).
- **Tier-2 pool-wide aggregates** — collide **unconditionally** (any two slices hit the same row):
  `SCR|T|Score.nzs-count` + `.total-base/boosted/deb` (key `score-id`); `FVT|T|RPS|Member` +
  `MemberVault.available/unclaimed` (key `fvt|score|reward` — the reward accumulator, advanced on *every* beneficiary
  unwind); `FVT|T|RPS|Global.unclaimed` (key `fvt|reward`). → FIX: **hoist out of the per-leg path**.
- **Oracle chicken-and-egg:** `URC_PoolFullyVacated` decides "empty?" by reading `Score.nzs-count == 0` for every
  employed score — the same Tier-2 aggregate we must stop touching per-leg → **re-base the oracle on tracker-row
  absence** (leg-disjoint, already parallel-safe).

### 5.3 Architecture: begin → parallel drain → finalize
**Load-bearing fact (verified):** reward-per-share `G` advances **only on inject** (`04_FVT:3029` "current-rps
G += floor(R/S)"), never time/collect-based. So with injects blocked during vacate, `G` is constant and every
member/user can settle against a **frozen snapshot** independently — the basis for removing Tier-2 writes from the
parallel middle.

1. **begin — single tx** (`C_VacateBegin(pool-id)`, owner-gated). Freeze EVERYTHING that could touch the pool's
   rows during the drain window:
   - **Pool-level:** set `vacate-in-progress`; disable **stake AND unstake** (unstake mid-drain hits the same
     staker tracker row the vacate zeroes → direct conflict; unstake currently is NOT gated by `stake-enabled`, so
     add a `vacate-in-progress` reject on the unstake path).
   - **Per-FVT (all of the pool's FVTs):** walk the ≤7 employed scores → each `fvt-link`; for **every** distinct FVT,
     set its `vacate-frozen` flag (blocks **both collect and inject** on that FVT — NEW; neither path checks vacate
     state today) and **settle its member once** (advance `g_i→G`, credit `MemberVault.available`). If the 7 scores
     map to 7 FVTs, all 7 are frozen + settled.
   - Must be an explicit tx BEFORE the fan-out (a parallel auto-begin would race the flags + member settles).
2. **drain — N parallel txs, beneficiary-partitioned** (reworked `C_Vacate*Legs(pool, asset, legs, finalize=false)`):
   per leg → tracker-zero + custody-return (disjoint); per beneficiary → Tier-1 reward-bank *against frozen G* +
   `UserScore` SET-to-0 + `Anchors`/`UserBoost` SET. **Zero writes to any Tier-2 aggregate.** `finalize` is always
   false on this path.
3. **finalize — single tx** (`C_VacateFinalize(pool-id)`, owner-gated): verify empty via **tracker-row absence**
   (new leg-disjoint oracle); SET `Score.nzs-count=0` + `Score.totals=0` per employed score; zero member
   accumulators; reconcile `RPS|Global.unclaimed`; re-enable stake; unblock injects; clear `vacate-in-progress`.

### 5.4 Partitioning + anti-tamper
UI partitions so each beneficiary's full position lands in exactly ONE tx (partition by beneficiary → pack
beneficiaries into gas-bounded txs; UI re-splits on gas failure — no static leg cap). Each Legs tx still **validates
every leg against the live tracker** (`URC_VacateTfLegBalancesOk`, `URC_VacateOrtoNoncesSufficient`,
`URC_VacateOrtoLegBeneficiaryOk`) so the UI can only choose *which real stakers*, never fake amounts. Add an on-chain
guard that a tx carries a beneficiary's legs **completely** (no partial-beneficiary) so Tier-1 SETs are correct.

### 5.5 Deltas vs the earlier plan
- **REVERSES "no explicit begin/abort":** absolute parallelism *requires* explicit begin (freeze) + finalize
  (reconcile) bookending the parallel middle. **Keep `C_AbortVacate`** (reset a stuck/abandoned campaign).
- **Keep** `C_Vacate*Legs` (all 4 kinds), reworked to the drain contract (strip Tier-2 writes).
- **Drop** the defpact entirely.
- **Still delete dead code (L9/#20):** `URC_VacateBatchLegParityOk` + `VACATE-MAX-LEGS` (a static leg cap is *wrong*
  once per-leg gas is data-dependent — let gas bound it, UI re-splits).
- **D6 flips wire→DROP the hash-commitment fields:** per-leg tracker validation is the real anti-tamper guard, so
  `initial/phase/last-vacate-hash` are redundant.

### 5.6 Vault topology (grounded — no shared vaults)
Vacate is **per-pool**. A pool has ≤7 employed scores (`URC_PoolActiveScoreIds`); each score links **one-time to
exactly one FVT** (farm/vault/treasury) via `UR_SCR|ScoreFvtLink`. Injects are keyed by `fvt-id`
(`CC_Inject(patron, fvt-id, reward, amount)`); `G` (`RPS|Global`, key `fvt|reward`) is **per-FVT**. **FVTs are NOT
shared across pools** — an FVT's members are one pool's scores. So the begin-freeze scopes to the vacating pool's own
FVTs (walk employed scores → `fvt-link`), blocking only pool-local injects — **no co-tenant impact**, and `G` for
those FVTs is held constant for the drain. (Earlier "shared vault" concern was a mis-read of the many-members schema:
many members = one pool's several scores / a mosaic farm, never cross-pool.)

**Freeze mechanism:** an FVT-level `vacate-frozen` flag (small `FVT|T|VacateFreeze` table, `with-default-read` false),
SET on **each** of the pool's FVTs at `C_VacateBegin`, checked by **both** the inject path (`CC_Inject`/`XI_FvtInjectCore`)
**and the collect path** (reject when frozen), CLEARED at `C_VacateFinalize`. Stake+unstake are frozen pool-level via
`vacate-in-progress`. Because FVTs aren't shared across pools, freezing the pool's FVTs never blocks another pool.

Remaining checks: confirm `collect`/reward-claim only READS `G` (never advances it) so the freeze is exact; gas —
begin (settle ≤7 members) + finalize (set ≤7 aggregates) are bounded/cheap, drain per-tx bounded by beneficiary count
(UI calibrates).

### 5.7 Build phases (Phase 4 remaining) [REVISED 2026-08-17 — serial-execution model]

**Key simplification (owner, authoritative — SUPERSEDES §5.3's freeze-at-begin/settle-once/hoist-Tier-2 design):**
Chainweb executes txs **serially** — the UI "fires in parallel" only means submitting to the mempool; miners integrate
txs into blocks **one at a time**, and at ~1.8–1.95M gas per vacate tx that is effectively **one vacate tx per block**
(≈2 blocks/min → e.g. 20 batches ≈ 10 min). So there are **no same-block write conflicts**: every batch executes
against committed state and composes its delta. Consequences: **no Tier-2 hoisting** (`nzs`, Score totals, `RPS|Member`
stay maintained per batch); **no "partition by beneficiary" constraint** (a beneficiary split across batches drains
incrementally); first/last detection is trivially safe.

- **Phase 1 — Freeze layer (foundation, cross-module).** Per-FVT `vacate-frozen` flag (small table, `with-default-read`
  false); extend `XI_EnsureVacateBegun` → set `vacate-in-progress` + disable stake + freeze the pool's ≤7
  employed-score FVTs (walk `URC_PoolActiveScoreIds` → `UR_SCR|ScoreFvtLink`); add rejects to **unstake** (pool, on
  `vacate-in-progress`), **collect** + **inject** (FVT, on `vacate-frozen`); `XI_MaybeFinalizeBatchVacate` → when
  `URC_PoolFullyVacated` (all ≤7 scores `nzs==0`) clear `vacate-in-progress` + re-enable stake + unfreeze the FVTs.
  Prove isolated (begin freezes; the 4 ops reject mid-vacate; finalize lifts all).
- **Phase 2 — 3 batch functions.** `CC_BatchVacate{TrueFungible,OrtoFungible,Collectables}` + `VCT|C>BATCH-VACATE`
  cap (owner-gate + validate the supplied slice vs the live tracker per kind — `URC_VacateTfLegBalancesOk` /
  `URC_VacateOrtoNoncesSufficient`+`…LegBeneficiaryOk` / `URC_VacateCollectableNoncesSufficient`+`…LegBeneficiaryOk`)
  + Talos wrappers + IGNIS. Skeleton (identical, only the consume line differs):
  `EnsureVacateBegun → XI_Vacate<Kind>FromLegs → MaybeFinalizeBatchVacate`. Prove single-batch each.
- **Phase 3 — E2E multi-tx proofs.** Multi-batch drain (auto begin→N slices→finalize); split beneficiary (one
  beneficiary's nonces across 2 batches, `nzs`→0 only on the 2nd); dual pool (class-1 TF series + OF series, finalize
  only after BOTH drain).
- **Phase 4 — Cleanup (deferred end pass).** Remove superseded `C_Vacate*Legs` / `C_FullVacate*` /
  `C_AbortVacate` + old begin/finalize surface, dead L9/#20 + hash fields, function-ordering sweep.

### 5.8 Split capability — UI batch-construction spec

The UI drives the whole campaign, so the split model must be precise. A vacate **leg** = one `(owner-id,
beneficiary-id)` pair's stake in ONE asset lane (TF: `{owner,beneficiary,balance}`; nonce kinds:
`{owner,beneficiary,nonces[],amounts[]}`). Both `owner` and `beneficiary` matter — one owner may stake for hundreds
of beneficiaries, and one beneficiary may be staked-for by many owners; each `(owner,beneficiary)` is its own leg.

**Where a split IS possible — two granularities:**
1. **Across legs — ALL asset types (TF, OF, SF, NF).** The pool's legs for one asset are partitioned into slices;
   each batch tx carries a disjoint subset of legs. This is the primary split (hundreds of `(owner,beneficiary)` legs).
2. **Within a leg, by nonces — nonce kinds ONLY (OF, SF, NF).** A nonce leg's `(nonces[],amounts[])` is partitioned;
   a slice may carry a *subset* of one beneficiary's nonces (e.g. 800 NFTs → 400 + 400). TF has no nonces (one
   fungible balance) → **not** splittable within a leg.

**Atomic unit — indivisible:**
- **One nonce** (OF/SF/NF): vacated in full — its `amount` must equal that nonce's live tracker balance
  (`URC_Vacate*NoncesSufficient`). No partial-within-a-nonce. A single nonce's custody-return + unwind is O(1) → a
  nonce always fits one tx, so splitting by nonce is always sufficient.
- **One TF `(owner,beneficiary)` balance**: vacated in full (`URC_VacateTfLegBalancesOk`). O(1) per leg → always fits
  one tx; TF is atomic at the leg level (split only *across* legs).

**Gas sizing (UI responsibility):** per-leg/per-nonce cost is data-dependent (≤7 score updates + custody-return +
settle). The UI estimates and packs slices under the ~1.9M ceiling; a tx that fails on gas → re-split smaller +
resubmit. No fixed on-chain leg cap (`VACATE-MAX-LEGS` is dead).

**Disjointness + validation:** slices MUST be disjoint (no leg/nonce in two slices) — otherwise the second tx
double-vacates an already-zeroed row and fails validation. Each supplied leg/nonce is validated against the LIVE
tracker at execution (amount == balance per nonce/leg; beneficiary matches the row), so a stale slice fails and the
UI re-reads + rebuilds.

**Snapshot validity:** once the FIRST batch establishes the freeze (`vacate-in-progress` + per-FVT `vacate-frozen`),
no external op (stake/unstake/collect/inject) can mutate the trackers, so the UI's initial dirty-read snapshot stays
valid for every subsequent batch. Only the first batch risks pre-freeze staleness (retry-safe); a UI may instead fire
a freeze-only prime batch first, then scan.

**Serial-drain correctness:** because blocks integrate txs serially, a beneficiary split across slices drains
incrementally — each slice subtracts its portion of that beneficiary's score/anchor/RPS rows; the score's `nzs` flips
to 0 only when the beneficiary's TOTAL stake (all their legs/nonces, TF + OF) is gone → `URC_PoolFullyVacated`
(finalize) fires only on the genuinely-last batch, unifying TF and OF series automatically (§5-mixed-pool note).

**Dual pools (class 0/1):** the UI dirty-reads BOTH `URH_VacateTrueFungiblePoolLegs` and
`URH_VacateOrtoFungiblePoolLegs`, builds a TF series (`CC_BatchVacateTrueFungible`) AND an OF series
(`CC_BatchVacateOrtoFungible`), and fires them as ONE campaign; finalize fires only when the whole pool is empty.

**UI algorithm:** (1) read `aqp-class` + `PoolAssetId`; (2) dirty-read the class's lanes (TF+OF for 0/1; OF for 2;
DPSF/DPNF for 3/4) via the `URD_Vacate*PoolLegs` scanners; (3) flatten to legs, partition into disjoint gas-bounded
slices (across legs; within a leg by nonces for nonce kinds); (4) fire `CC_BatchVacate<Kind>` per slice; (5) on a
validation/gas failure, re-read the affected lane and rebuild the remaining slices.

## 6. Cross-cutting decisions (recommendations)

| # | Decision | Recommendation |
|---|---|---|
| D1 | Module home for the new defpacts | **Extend `MTX-AQP`** (assumed). |
| D2 | Anchor ops | **Revoke + re-price** (assumed). |
| D3 | Freeze semantics during a sweep | Disable **stake admission** on affected pools + `sweep-in-progress` flag on the AQP-POOL session row; **leave collect open** (self-heals). |
| D4 | Who pays the sweep gas | **Owner-initiated → owner pays** the paginated sweep. NO staker 2e-penalty (they didn't cause it; contrast the inject forced-fix penalty). |
| D5 | S4 / triplet+anchor | **LOCKED: build triplet-lane recompute** into the sweep (§4c). Anchors on triplets stay supported. |
| D6 | Vacate hash-commitment | **RE-LOCKED 2026-08-16: DROP** the hash fields (§5.5) — per-leg tracker validation is the real anti-tamper guard; on-chain scan / validated legs make the hashes redundant. |
| D7 | Large-pool multi-tx mechanism | **LOCKED 2026-08-16: parallel independent txs, NOT a defpact** (§5.1). begin → parallel drain → finalize; reward accumulator frozen at begin (G is inject-driven, §5.3). |

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
| enumerate positions | `ANK::UR_BC|ScoreLinks` (phase 1) + `FVT::URH_FvtStalePresentUsers` / `FVT|T|UserPresence` | sweep: anchor→BC→scores→present users; vacate: legs |
| settle @ old-deb (cross-module) | `FVT::XE_BankScorePendingRewards(ben, pool, plan)` | both — banks pending across streams before any weight change |
| recompute deb (0-base) | `FVT::XE_RefreshUserScoreDeb`-driver / `SCR::XE_RefreshUserScoreDeb` → `XI_2|ApplySingularUserScoreDelta` | sweep deb terminal |
| signed score delta (zero/unstake) | `SCR::XE_ApplyTrueFungibleStakeDelta` (+OF/SF/NF) `direction=false` | vacate terminal |
| pagination | replicate the `MTX|2|C_Inject` defpact shape (scan → `take N` → chunk → yield/continue) | sweep + vacate defpacts |
| lock decrement | `ANK::XE_UnbumpBoostClassScoreLinks(bc, score-id)` (phase 1) | sweep revoke teardown |

**Phase 3 must still BUILD (not reuse — sweep-specific, the DEEPER recompute):** an exposed aggregate-promile
refresh XE_ (anchor def changed ⇒ stored aggregate-promile stale), a triplet-lane recompute XE_ (D5), the
`sweep-in-progress` freeze, and the sweep client + defpact in MTX-AQP.
- **Phase 3 — anchor sweep.** ✅ **DONE (single-tx `CC_SweepRevokeAnchor`).** Built + PROVEN end-to-end
  (`deb-proof` TX-AQP-SWEEP01: LUMY, the KBN-asset/anchor owner, retires the employed AurynRain anchor →
  aggregate-promile 100→0, true-triplet lanes 20→0, reverse-index unchanged, pool unfrozen). Pieces: reverse-index
  scan (leg→member via `UR_SCR|ScoreTripletId`) + `sweep-in-progress` freeze (stake+collect) + per-holder
  `XI_SweepRecomputeUserMember` (settle → aggregate refold → deb refresh OR true-triplet lane refold) + swept-revoke
  (`XE_SweepRevokeAnchor`, skips the #9 lock) + Talos wrapper. Two bugs the proof caught + fixed: the true-triplet
  lane refold needed the aggregate refold FIRST (lanes read `UR_UB|AggregatePromile`); and
  `XI_2|RecomputeAffectedBoostAggregates` skipped the write when a class emptied (stale aggregate on last-anchor
  removal). Auth = the anchored-asset owner (owner clarification: no separate anchor-owner). **Deferred within
  phase 3:** the RE-PRICE variant (3b — adds a per-anchor-user-promile refresh). **DONE (Phase 3 closeout):** the
  paginated `MTX-AQP::MTX|2|C_SweepRevokeAnchor` defpact for spike staker sets (mirrors CC_Inject → MTX|2|C_Inject) —
  FVT `XE_SweepBegin`/`XE_SweepEnd` bracket + `XI_SweepRecomputeWindow` global-offset paging over the frozen present
  set; proven in `deb-staleness-proof.repl` TX-AQP-SWEEP01/02. `N_SWEEP` is a calibration-gated placeholder.
- **Phase 4 — vacate rehaul.** [REVISED 2026-08-16 — see §5]
  - ✅ **DONE (single-tx agnostic):** `CC_FullVacate(pool-id)` + per-kind `XI_Vacate*Pool` + `XB_Vacate*` + Talos +
    `URD_AQP|ActivePoolDpofIds` (class-1 satellites). All 5 classes proven (`TX-VCT-{TF01b,L01b,L02b,DPNF02b,CC01}`).
  - ⏳ **PARALLEL-SAFE LEGS (the reward-settlement refactor, §5.3):** inject-block during vacate → `C_VacateBegin`
    (freeze + settle members) + tracker-absence oracle → drain-contract `C_Vacate*Legs` (strip Tier-2 writes) →
    `C_VacateFinalize` (set-to-empty). Prove 2 disjoint-beneficiary parallel drains with no conflict. Touches
    FVT/SCORE — riskiest, heavy tests.
  - ⏳ **Dead-code removal (L9/#20 + hash fields, D6-drop):** last, after the above is proven.

## 8. Open risks / notes
- Cross-module terminal actions can't be lambdas in Pact → each consumer owns its defpact; the shared part is the
  primitive set + the pagination shape, not a single mega-function. Keep the shared helpers in one place so they
  don't drift (the single-core lesson from R-INJECT).
- The sweep's DEEPER recompute (§4b) and triplet lanes (§4c) are the two places this is more than "reuse deb-fix."
- `N_FIX=400` is inject-calibrated; the sweep/vacate chunk sizes need their own gas calibration (different per-unit
  cost).

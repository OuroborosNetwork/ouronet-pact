# Vacate v2 — "Fast Vacate" design (LOCKED, owner-approved)

> Keep v1 (the delta-per-batch vacate) as the **safe / parallel / abortable** path. v2 is the **cheap**
> path for large pools (Bloodshed = 13k NFTs). This doc specifies v2 in both a **full** (single-tx) and a
> **batch** (paginated) form. The architecture below is **locked**; §9 records the resolved decisions.
> Primitives it builds on (`nns`, the `URH_Vacate*Inventory` readers, `URC_PoolFullyVacated`) already exist.

---

## 1. Why v1 is expensive (the measured shape)

v1 vacate is **mass-unstake**: it runs the full per-user accounting on every batch. From
`XI_2|Vacate*ScoreUnwind`, each beneficiary in each batch triggers:
`settle (RpsVacatePreZero) + apply-delta-across-≤7-scores + book-unclaimed + re-checkpoint-RPS`,
on top of the per-position `transfer + tracker-clear`.

Consequence: a raw nonce transfer is ~2–3k gas (so ~700–800 fit in 2M), but `VACATE-GAS-MAX-DPNF = 30`.
**~95% of each batch's per-position gas is the reward/aggregate overhead, not the transfer.** A user
split across K batches pays the settle machinery K times (correct — the 2nd+ settle to 0 — but it burns
gas every time).

**13k NFTs @ 30/tx ≈ 433 transactions.** At the transfer floor it would be ~17.

## 2. The three work classes (the whole idea)

| Work | Order | Cost | v1 | v2 |
|---|---|---|---|---|
| **Asset transfer** back to owner | per **position** | cheap each, but this is the real bulk | in every batch | **drain phase, maxed out (~700–800/tx)** |
| **Reward preserve** (settle pending → unclaimed) | per **beneficiary** | moderate | re-run **every batch** | **once per user** (settle-on-last-drain, §4) |
| **Score aggregate** → 0 (`total-base/boosted/deb`, `nzs`) | per **score** (≤7) | trivial if bulk | decremented `O(users×7)` | **bulk-set to 0** (nuke, ≤7 writes) |
| **Per-user score rows** → invalid | per **user×score** | the hidden O(users) cost | deleted/decremented | **generation bump** — O(1), lazy (§5) |

v2 = **separate them.** Drain assets cheaply and in parallel; settle each user **once** as their last
position leaves; bulk-zero the ≤7 aggregates **once**; invalidate all per-user score rows with a single
**generation bump** instead of `O(users)` writes.

## 3. The ordering constraint (why v2 needs a gate, v1 didn't)

- **v1 delta is self-consistent per batch** — each batch is a complete unstake of its positions (tracker
  AND score move together). Batches are independent → **parallelizable, no defpact, abortable anytime.**
- **v2 decouples** tracker (drained now) from score aggregates (nuked at the end). So there is an
  **inconsistent window**: assets are back with owners while the pool's *aggregate* scores still show them.
  The nuke is only correct **after every asset is drained.**
- **The gate is `nns == 0`** (the occupancy counter, now universal across classes 1–4 after #FP1). Finalize
  may run *only* when the pool tracker is empty. That is the ordering primitive — **no defpact needed**,
  only a hard precondition (a cap that enforces `nns == 0`) on the finalize defun.

## 4. Reward preservation — settle-on-last-drain (LOCKED)

To make the pool **reconfigurable**, per-user scores must be cleared; to be **fair**, each user's pending
reward must be captured first. That O(users) settle work is **unavoidable** — it cannot be pushed to lazy
claims without leaving stale per-user scores that would corrupt a reconfigured pool.

**Decision: settle a user the moment their *last* position drains, into their existing `unclaimed` balance;
they `C_Collect` later via the existing path (no new claim surface).** This works because during v2 the
score *aggregates* are untouched until the nuke, so a settle mid-drain reads the same RPS/score state it
would at finalize. Two supports make it exact and idempotent:
- **A per-user occupancy counter (`unn` — user-nonces-in-pool)**, decremented on each drained position;
  `unn == 0` after a drain ⇒ settle that user now. (Same read-modify-write shape as `nns`.)
- **A `settled-this-generation` mark** per (pool, user) so a user straddling multiple drain chunks is
  settled exactly once even if a retry re-touches their rows.

This makes **finalize aggregate-only** (bulk-zero + generation bump), so it is O(scores) not O(users) — the
key win for many-user pools. (The alternative, settle-all-at-finalize, was rejected: it re-imposes the
O(users) cost in a single tx and forces the finalize to paginate.)

## 5. Per-user score-row invalidation — `vacate-generation` (LOCKED)

Clearing per-user score rows directly is O(users×scores) writes — the exact cost v2 exists to avoid. Instead:
- **The counter is per-SCORE, not per-pool** (deploy order forces this): the per-user row to invalidate,
  `SCR|T|UserScore`, lives in the SCORE module (02), which loads *before* POOL (03) — so a UserScore reader
  cannot read a pool-level field in POOL. A score maps 1:1 to a pool (`aqpool-link`), and a pool's ≤7 scores
  are exactly the `SCR|T|Score` rows the nuke already zeroes, so the counter sits on `SCR|Schema` and the
  ≤7 scores bump together. Field: `SCR|Schema.vacate-generation:integer` (default 0). *(Implemented — Step 1,
  commit `4186bd3`.)*
- Each per-user row carries `SCR|UserSchema.stamped-generation:integer` — the generation it was written under.
- **Reads** (`URC` score readers) treat a row whose `stamped-generation < score.vacate-generation` as **0**
  (stale ⇒ empty). No write needed to "clear" it. *(Step 2.)*
- **The nuke bumps each employed score's `vacate-generation` once** (≤7 writes, alongside the aggregate
  zero) → every prior per-user row for those scores is instantly, lazily invalid. *(Step 4.)*
- **Re-stake after vacate** writes the row fresh at the current generation (resetting it to a real value),
  so a reused pool starts clean with no migration. *(The stake write already stamps `score.vacate-generation`
  — Step 1.)*

Net: the O(users) per-row clear becomes **one integer increment**. Combined with §4 (rewards already
settled on last drain), finalize touches only: the ≤7 aggregates (set 0), `nns` (already 0), and
`vacate-generation` (+1) — a fixed, tiny write set.

## 6. defun + gate, NOT defpact (LOCKED)

The drain is an **unknown, large N** (13k NFTs). A **defpact has a fixed step count** decided at start — it
cannot scale to an arbitrary, UI-discovered position count, and a stuck/oversized step strands the pact.
So:
- **Drain = repeatable parallel *defuns*.** Each drain tx is an independent `CC_BatchDrain*` call: read live
  tracker rows for a chunk, `bulk-transfer + clear tracker (nns -= count)` + per-drained-user `unn -= 1`
  and settle-if-`unn==0` (§4). Idempotent (re-reads live rows), parallelizable (disjoint tracker rows),
  submit as many as the UI needs — exactly like v1's batches but with **no aggregate/score-delta work**.
- **Nuke = one gated *defun*.** `C_FinalizeVacate` is a single call whose cap enforces `nns == 0`; body =
  bulk-zero ≤7 aggregates + bump `vacate-generation` + clear flags/re-enable stake. Fixed, tiny, atomic.
- **No defpact anywhere in v2.** The `nns == 0` gate is what lets the parallel drains be followed by a
  single ordered nuke without pact machinery.

## 7. v2 — FULL version (single transaction, small pools)

One tx, when the whole job fits under gas (~few hundred positions + few users):
1. `require nns != -1` (occupancy-tracked pool) and owner-gated (`CAP_VctVacatePoolOwner`); freeze as today
   (stake/collect/inject **and unstake**, §8).
2. **Drain:** bulk-transfer every position back + clear every tracker row (`nns → 0`); per user `unn → 0`
   ⇒ settle each once (§4).
3. **Nuke:** `nns == 0` now holds → bulk-set each employed score's `total-base/boosted/deb = 0`,
   `nzs = 0`; bump `vacate-generation`.
4. **Finalize:** clear `vacate-in-progress`, re-enable stake, unfreeze FVTs.

Linear, self-contained, no defpact — the common case for small/medium pools.

## 8. v2 — BATCH version (paginated, large pools)

**Phase A — DRAIN (parallel, defun, no defpact).** UI reads remaining positions (`URH_Vacate*Inventory`)
and submits **independent** `CC_BatchDrain*` txs, each: `bulk-transfer chunk + clear tracker rows + nns -=
count`, plus per-user `unn -= drained` and settle-on-`unn==0` (§4). No aggregate/score work → per-position
cost ≈ transfer floor → cap ~700–800/tx (calibrated). Parallel-safe (disjoint tracker rows, no shared
aggregate touched).

> **Batch-slicing constraint (inherited from v1):** the TFT/collectable bulk-transfer requires **unique
> receivers**, so a single drain batch must not carry two legs with the **same owner** (both would resolve
> to the same receiver). The UI slices batches by unique owner (`UC_Vacate*LegsToBulkArrays` maps leg→owner
> without aggregating). Same rule the v1 `CC_BatchVacate*` batches follow.

> **STATUS — Step 3 drain paths COMPLETE + runtime-proven for ALL asset families.** All reuse the
> asset-agnostic `XI_2|SettleBeneficiaryRewardsOnly` (Bank→Book→Checkpoint reward triple), drop their
> `XE_Apply*StakeDelta`, and never finalize:
> - **TF** — `CC_BatchDrainTrueFungible` (`18e3e55`), proven by `TX-VCT-DRAIN` (15 assertions).
> - **OF** — `CC_BatchDrainOrtoFungible` (`aee4a11` code / `f8bbcf6` test `TX-FVT-OF-DRAIN`, 7 assertions):
>   tracker-clear only (no rollup/anchor).
> - **Collectable (SF/NF)** — `CC_BatchDrainCollectable` (`aee4a11` / `4d5c577` test `TX-FVT-NF-DRAIN`, 9
>   assertions): tracker-clear + per-leg rollup + per-leg anchor refresh (delta-based; verified the anchor
>   refresh never writes the per-user deb, so it's safe before the last-drain Bank). Proven for a **ghost
>   nonce** (0-score) — occupancy via `unn`, the #FP1 point `nzs` misses.
>
> Each drain returns assets, settles each beneficiary once when their `unn` hits 0, leaves per-user scores
> UNTOUCHED (for the lazy generation-bump nuke), and keeps the pool FROZEN. A drain batch must carry unique
> owners (bulk-transfer receivers).
>
> **STATUS — Step 4 (`C_FinalizeVacate` nuke) SHIPPED (`85f5d3f`). VACATE-V2 PHASE 1 COMPLETE.** Pool-owner +
> `nns==0` gated. Nukes each employed score via `XE_NukeScoreForVacate` (`WU_Score|Nuke`: bulk-zero
> aggregates + bump `vacate-generation` — **O(scores), ≤7 writes, not O(users)**), then clears
> vacate-in-progress + re-enables stake + unfreezes FVTs. Proven end-to-end by `TX-VCT-FINALIZE` (10
> assertions): per-user scores the drain left at 20 read **0** after the generation bump (lazy, zero per-user
> writes), aggregate bulk-zeroed, generation +1, pool re-enabled, and a **re-stake reads live again (fresh,
> generation reset)** — the pool is fully reusable. The §5 lazy-invalidation design is fully validated.
>
> **Phase 1 done:** S1 generation state · S2 generation-aware reads · S3 `unn` + drains (TF/OF/SF/NF) ·
> S4 finalize nuke. Phase 2+ (drain-slice gas calibration; paginated finalize-settle only if a pool's
> beneficiary set ever exceeds one-tx capacity — moot under settle-on-last-drain since finalize is O(scores))
> is future work.

**Phase B — FINALIZE (single gated defun).** `C_FinalizeVacate`: cap enforces `nns == 0` (all drained and,
by §4, all users already settled). Body = bulk-zero the ≤7 aggregates + bump `vacate-generation` + clear
flags. **No defpact** — because §4 moved the O(users) settle into the drains, the finalize is O(scores),
so it always fits one tx regardless of user count.

So: **drains scale by re-submission; finalize is always one small tx.** The `nns == 0` gate makes the
parallel drains safe to follow with the single ordered nuke.

## 9. Consistency, abort, freeze — resolved decisions

1. **Reward path — LOCKED: settle-on-last-drain (§4)**, settled-this-generation-guarded, into existing
   `unclaimed`. No new claim surface; finalize stays O(scores).
2. **Abort — LOCKED: v2 is commit-forward.** Once draining begins, assets are out and aggregates are not
   yet zeroed → there is no consistent early-abort state. "Abort" is valid only *before the first drain*.
   **v1 remains the abortable path** for callers who need to bail mid-campaign.
3. **Freeze `unstake` — LOCKED: yes, for the whole v2 campaign.** v1 already freezes stake/collect/inject;
   v2 must also freeze **unstake**, else a user whose asset was already drained could "unstake" a
   position the pool no longer holds. Freeze covers stake + unstake + collect + inject until finalize.
4. **Full-vs-batch selector — LOCKED: UI decides** by estimating pool size (positions + users), same
   simulate-and-construct loop as today's vacate slicing: small ⇒ FULL (§7, 1 tx); large ⇒ BATCH (§8).
5. **Keep v1 — LOCKED: keep both.** v1 = small/abortable/parallel-consistent; v2 = large/commit-forward/cheap.

## 10. Cost model (target)

| Scenario | v1 | v2 (est.) |
|---|---|---|
| 13k NFTs, 1 user | ~433 tx | ~17 drain + 1 finalize ≈ **18** |
| 1500 TF stakers | ~63 tx | ~2 drain (settle folded in) + 1 finalize ≈ **3** |
| Small pool (≤ few hundred pos, few users) | several | **1 (full version)** |

Drains hit the transfer floor + a cheap per-last-position settle; finalize is a fixed O(scores) tx. Both
single-user-many-nonce and many-user pools become transfer-bound (near-optimal) because §4+§5 removed the
per-user finalize cost.

## 11. New state + entrypoints (build surface)

**New per-pool state** (on `AQP|Pool` or a sibling table):
- `vacate-generation:integer` (default 0) — §5.
- (per-user) `unn:integer` — user-nonces-in-pool, and a `settled-generation` mark — §4.

**Reused, already built:** `nns` (now universal, #FP1), `URH_Vacate*Inventory` readers,
`URC_PoolFullyVacated` (nns-based) as the Phase-B gate, the existing `unclaimed`/`C_Collect` path.

**New entrypoints:**
- `CC_BatchDrain{TrueFungible,Collectable}` (+ Talos wiring) — Phase-A drain defuns (per asset family, like
  v1's batch vacate; no score/aggregate work).
- `C_FinalizeVacate` (+ cap enforcing `nns == 0`) — Phase-B nuke defun (bulk-zero + generation bump).
- Score `URC` readers updated to honor `vacate-generation` (stale row ⇒ 0); stake writers stamp the current
  generation; `unn`/`settled-generation` maintained in the stake/unstake/drain tracker writers.

**Interaction with what we just built:** `nns` is the finalize gate and is now truly universal (classes
1–4) after #FP1 — TF included. The genuinely new writes are the generation-stamp on score rows, the
`unn`/settled marks, and the bulk-zero nuke. v2 is mostly **new drain + finalize entrypoints on top of
existing primitives.**

## 12. Phase 2 — gas calibration (SHIPPED `d38ec10`) + a cost-model correction

A benchmark (`TX-NF-BENCH` model-0, `TX-NF-BENCH-M1` model-1 KBN) measured the real per-position and
per-beneficiary costs, and it **corrects §1/§10's optimistic model**:

- The **per-beneficiary settle (~67-85k) dominates**; the per-position marginal is only ~4k (bare/model-0)
  to ~10k (trait-rich/model-1). The trait cost (~5.5k/nonce for KBN) is **metadata + anchor work that BOTH
  v1 and v2 pay** — not the score-delta.
- **v1 vacate and v2 drain differ by only ~600 gas/nonce** (the `ApplyStakeDelta` write v2 drops). So the
  "v2 is the 20× speedup" framing was **wrong**: v2's gas edge is ~7-14%. v2's real value is architectural
  (commit-forward, deferred O(scores) finalize, lazy nuke), not gas.
- **The actual win is the cap model.** The old flat caps (24/33/29/30) were sized for the worst case (1
  position/beneficiary), throttling *concentrated* batches ~5×. The 1500-TF-staker "→17 tx" and any
  spread-pool row in §10's table were over-claims — a spread pool pays the ~76k settle per position in v1
  AND v2, so it stays ~19/tx regardless.

**Beneficiary-aware cap (both v1 vacate + v2 drain, since their gap is negligible):**
`est = unique_beneficiaries × PER_BEN(90k) + positions × PER_POS(12k) ≤ BUDGET(2M)`, replacing the flat
check inside `URC_TfOwnerArraysGasOk` / `URC_BatchOwnerArraysGasOk` (both entrypoint families share them).
Coefficients are conservative upper bounds covering trait-rich model-1 NFTs.

**Step 3 (`dd05547`) — the cap is a loose backstop + UI seed, not the optimizer.** The UI sizes real batches
by **simulating** (`/local` dry-run) against the true, model-dependent gas; the **node gas meter** is the real
enforcement (an oversized batch aborts atomically — submitter's gas, no protocol harm). A tight on-chain cap
would only throttle the UI below its simulated optimum. So the coefficients were loosened to the cheapest
realistic case (`PER_BEN 75k`, `PER_POS 4k`) → a generous ceiling that never throttles and only rejects
egregious/non-simulated batches early. `UC_ComputeMinSliceCount` seeds the UI's loop from the same model.

| shape | old flat cap | cap ceiling (loose backstop) | true UI optimum (simulated) |
|---|---|---|---|
| **concentrated** (few beneficiaries, many positions — e.g. 13k NFTs, 1 owner) | ~30 | **~481** | ~446 bare / ~195 trait-rich |
| **spread** (1 position per beneficiary — e.g. 1500 distinct stakers) | ~30 | **~25** | ~24 bare / ~19 trait-rich (settle-bound) |

So the honest picture: **v2 is worth keeping for its architecture, but the transaction-count win comes from
the beneficiary-aware model + the UI's simulate-and-optimize loop, and it accrues to v1 vacate equally.** The
on-chain cap is now just a coarse safety ceiling around that loop. Both v1 and v2 are retained pending a
later decision on whether to consolidate.

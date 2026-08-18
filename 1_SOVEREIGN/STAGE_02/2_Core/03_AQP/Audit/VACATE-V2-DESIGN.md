# Vacate v2 — "Fast Vacate" design (DRAFT, owner-review)

> Keep v1 (the delta-per-batch vacate) as the **safe / parallel** path. v2 is the **cheap** path for
> large pools (Bloodshed = 13k NFTs). This doc specifies v2 in both a **full** (single-tx) and a
> **batch** (paginated) form. Nothing here is built yet — this is the Phase-0 lock.

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
| **Reward preserve** (settle pending → unclaimed) | per **beneficiary** | moderate | re-run **every batch** | **once per user** (finalize) |
| **Score aggregate** → 0 (`total-base/boosted/deb`, `nzs`) | per **score** (≤7) | trivial if bulk | decremented `O(users×7)` | **bulk-set to 0** (finalize, ≤7 writes) |

v2 = **separate them.** Drain assets cheaply and in parallel; do the O(users) settle **once**; bulk-zero
the ≤7 aggregates **once**. "Nuke the scores" = set aggregates to 0 directly instead of `O(users×scores)`
deltas.

## 3. The ordering constraint (why v2 needs sequencing, v1 didn't)

- **v1 delta is self-consistent per batch** — each batch is a complete unstake of its positions (tracker
  AND score move together). Batches are independent → **parallelizable, no defpact, abortable anytime.**
- **v2 decouples** tracker (drained now) from score (nuked at the end). So there is an **inconsistent
  window**: assets are back with their owners while the pool's scores still show them. The nuke is only
  correct **after every asset is drained.**
- **The gate is `nns == 0`** (the occupancy counter we just built): finalize may run *only* when the
  pool tracker is empty. That's the ordering primitive — no defpact needed for the *drain*, only a hard
  precondition on the *finalize*.

## 4. Reward preservation — the pivotal decision

To make the pool **reconfigurable**, per-user scores must be cleared. To be **fair**, each user's pending
reward must be captured first. That O(users) work is **unavoidable at finalize** — it cannot be pushed to
lazy user-claims without leaving stale per-user scores that would corrupt a reconfigured pool. (Snapshotting
per-user for a lazy claim is the same O(users) write cost as settling — so lazy-claim buys nothing here and
costs a new claim entrypoint.)

**Decision: settle each user ONCE into their existing `unclaimed` balance at finalize; they `C_Collect`
later via the existing path.** No new claim surface. The only question is *pagination* (§6).

*(Refinement option — settle-on-last-drain: settle a user the moment their last position drains, using a
per-user occupancy counter, so the finalize is aggregate-zero only. Cheaper finalize, but adds per-user
state + complexity. Deferred; revisit if the finalize settle proves too heavy.)*

## 5. v2 — FULL version (single transaction, small pools)

One tx, when the whole job fits under gas (~few hundred positions + few users):
1. `require nns != -1` (nonce pool) and owner-gated (`CAP_VctVacatePoolOwner`), freeze as today.
2. **Drain:** bulk-transfer every position back + clear every tracker row (`nns → 0`).
3. **Settle:** for each unique beneficiary, settle pending → unclaimed (once).
4. **Nuke:** bulk-set each employed score's `total-base/boosted/deb = 0`, `nzs = 0`; clear per-user score rows.
5. **Finalize:** clear `vacate-in-progress`, re-enable stake, unfreeze FVTs.

No defpact — it's linear and self-contained. This is the common case for small/medium pools.

## 6. v2 — BATCH version (paginated, large pools)

Two logically distinct phases:

**Phase A — DRAIN (parallel, no defpact).** The UI reads the remaining positions (the `URH_Vacate*Inventory`
readers) and submits **independent** drain txs, each: `bulk-transfer chunk + clear tracker rows + nns -=
count`. **No score/reward work** → per-position cost ≈ transfer floor → cap ~700–800/tx (calibrated). These
are parallelizable exactly like v1's batches, because they touch disjoint tracker rows and no shared score
aggregate.

**Phase B — FINALIZE (ordered, gated on `nns == 0`).**
- Precondition: `nns == 0` (all assets drained). Enforced in the finalize cap.
- Work: settle every unique beneficiary once (§4) + bulk-zero the ≤7 aggregates + clear per-user score rows
  + finalize flags.
- **This is where a defpact appears** — *only if* the beneficiary set is too large to settle in one tx. Then
  Finalize is a paginated defpact: step 0..k settle beneficiary chunks; the terminal step bulk-zeroes the
  aggregates + finalizes. Gated so it can only start at `nns == 0` and can only finalize on the last chunk.
- If the beneficiary set is small, Finalize is a single tx (no defpact).

So: **drains never need a defpact; the finalize needs one only when users > one-tx capacity.** The `nns == 0`
gate is what makes the parallel drains safe to follow with an ordered nuke.

## 7. Cost model (target)

| Scenario | v1 | v2 (est.) |
|---|---|---|
| 13k NFTs, 1 user | ~433 tx | ~17 drain + 1 finalize ≈ **18** |
| 1500 TF stakers | ~63 tx | ~2 drain + ~15 finalize-settle ≈ **17** |
| Small pool (≤ few hundred pos, few users) | several | **1 (full version)** |

Drains hit the transfer floor; the residual cost is the O(users) settle in Phase B (paginated). Single-user-
many-nonce pools become transfer-bound (near-optimal); many-user pools are bounded by the settle pagination.

## 8. Consistency, abort, recovery (the v2 risks)

- **Inconsistent window:** between drain start and finalize, tracker is (partially) empty while scores are
  intact. Nothing may read/act on scores during this window → **stake, unstake, collect, inject must ALL be
  frozen** for the whole v2 campaign (v1 already freezes stake/collect/inject; v2 must also freeze **unstake**,
  because a user whose asset was already drained must not "unstake" again).
- **Abort:** v1's `C_AbortVacate` unfreezes cleanly because each batch was consistent. **v2 cannot abort into
  a consistent state once draining has begun** (assets are out, scores not yet zeroed). Options:
  (a) v2 is **commit-forward** — once started it must reach finalize (`nns == 0` then nuke); "abort" only
  valid before the first drain; or
  (b) an abort re-consistency path that re-credits drained assets (expensive, defeats the purpose).
  **Lean (a): v2 is commit-forward.** The UI must be sure before starting; v1 remains the abortable path.
- **Idempotent drains:** a drain chunk reads live tracker rows, so re-submitting a chunk that partially
  landed naturally drains "the remains" (same property v1 has). Safe to retry.
- **Finalize atomicity:** the nuke (bulk-zero + clear user rows) must be all-or-nothing per finalize tx;
  if paginated, the aggregate-zero happens only in the terminal step, after all settles.

## 9. Open decisions for the owner

1. **Reward path — settle-once-into-unclaimed (this doc) vs the settle-on-last-drain refinement (§4)?**
   The former is simpler; the latter makes finalize O(scores) but needs a per-user occupancy counter.
2. **Abort semantics — commit-forward (lean) vs a re-consistency abort?** Commit-forward keeps v2 cheap;
   v1 stays as the abortable option.
3. **Do we also freeze `unstake` for the v2 window?** (§8 — required for correctness; confirm no path
   depends on mid-vacate unstake.)
4. **Full-vs-batch selector — who decides?** UI estimates pool size (positions + users) and picks full
   (1 tx) vs batch (drain txs + finalize). Same simulate-and-construct loop as the vacate slicing today.
5. **Keep v1 in the codebase as the parallel/abortable path, or retire it once v2 lands?** (Lean: keep
   both — v1 for small/abortable, v2 for large/commit-forward.)

## 10. Interaction with what we just built

- `nns` (the occupancy counter) is the **finalize gate** for v2 — Phase B's precondition is `nns == 0`.
  Already implemented and tested (#FP1).
- The `URH_Vacate*Inventory` "read the remains" readers already give the UI the drain work-list.
- `URC_PoolFullyVacated` (nns-based) already answers "is the tracker empty?" — reuse it as the Phase B gate.

So v2 is mostly **new drain + finalize entrypoints** on top of primitives that already exist; the reward
settle-once and the bulk-zero are the genuinely new writes.

# Acquisition pools

The third family, and the largest single subsystem in Ouronet — **ten files, 27,074 lines**. It is
also the one that needs its vocabulary established before anything else makes sense.

The clearest statement is in the project's own notes:

> Users **stake** assets into **pools**. Each pool employs up to **7 scores**. Scores produce
> base / boosted / deb weight. Optional **anchors** add a per-mille boost. An **FVT** registers
> scores and reward tokens, then injects and collects.

And the separation that everything else depends on:

> **Users never stake "into the farm." They stake into a pool.** The FVT only accounts and pays
> rewards.

---

## 1. Four concepts

| | is |
|---|---|
| **Pool** | where you stake. Holds the asset, tracks positions. |
| **Score** | a weighting rule. Turns your stake into a number. |
| **Anchor** | a rule that boosts your score based on something you hold *elsewhere*. |
| **FVT** | Farm, Vault or Treasury — the reward distributor. |

They chain in one direction:

```
anchor → boost class → score → pool → asset
```

A pool accepts one asset shape, chosen from five classes: LP tokens, plain fungibles,
orto-fungibles, semi-fungibles, non-fungibles.

**Owner and beneficiary are separate.** The owner signs and receives custody back; the beneficiary
earns the score and the boost. When they are the same account it is an ordinary self-stake — but
the split means one party can stake on another's behalf without surrendering the asset.

---

## 2. Reward-per-share, and why claims are free

The reward accounting is the most elegant piece of engineering in the system, so it is worth
stating precisely.

A naive design credits each staker when rewards arrive — which means looping over every staker on
every injection, and that does not fit in a transaction. The reward-per-share model inverts it:

```
on inject:  index += reward / total_weight
on claim:   owed   = pending + your_weight × (index − your_last_index)
```

**Injecting touches one row. Claiming touches two.** Neither depends on the number of stakers, the
number of injections, or how long you were away. A claim is two point-reads and a multiply.

The correctness condition is a discipline stated in the source: on every weight change, **settle
every reward stream at the old weight first**, then advance the checkpoint. Get that wrong and a
weight change retroactively rewrites history.

The index carries **48 decimal places**, because it is a running division that must not lose
precision across thousands of injections.

### Rewards arriving at an empty pool

If nothing is staked, the divisor is zero. Rather than reverting or discarding, the reward is
parked in a separate **escrow** field and distributed on the next non-empty injection.

Deliberately kept out of the main pool, and the reason is precise: it must not be reachable by a
dust sweep that would otherwise pay it to a *previous* cohort who had already exited.

### Streamed rewards

An injection can be spread linearly over time — one hour to one year. Each release routes through
the same distribution function, so *a streamed release is identical to an instant injection of the
same amount*. One code path, two behaviours.

Concurrent streams are capped per owner by their account tier, up to **49** — seven by seven.

There is also a read-only projection so an interface can show a claim "ticking" between blocks
without a transaction. The source labels it honestly: **a UI hint, not a promise.**

---

## 3. Farm, Vault, Treasury

One field selects which, and the differences are structural rather than cosmetic:

| | Farm | Vault | Treasury |
|---|---|---|---|
| accepts scores over | LP tokens | fungibles and orto-fungibles | collectables |
| accounting | **two-tier** | single-tier | single-tier |
| the index you check | your member's | the global one | the global one |

**A vault or treasury has one index.** A **farm has two levels**: an injection first splits across
members by their weight, then each member's own index splits across its stakers. That exists
because a farm's members are *pools of different sizes*, and splitting by size before splitting by
stake is the only way a large pool does not swallow a small one.

A farm's member weights can be set to reflect either what is **staked** in each pool, or each
pool's **total value** — participation versus pool size. Switching modes re-weights only future
injections, because the model is checkpoint-based.

### An admission rule that was inverted

The mapping from score class to distributor class was wrong: it admitted collectables into the
vault and sent orto-fungibles to the treasury. The two were swapped.

The reason nobody noticed is the instructive part:

> nothing caught it because the bootstrap issued its four entities **named Treasury** at class 1,
> so the broken rule was exactly what let them work.

A fixture built to match the bug confirms the bug. That is a failure mode no test can catch,
because the test and the code agree — which is exactly the shape `60-methodology/04-what-went-wrong.md`
catalogues.

---

## 4. Scores

Your weight is built in three steps:

```
base      ← the staked amount, times a multiplier for its variant
boosted   ← base + base × (anchor promille / 1000)
deb       ← boosted × your account tier
```

`deb` is what the reward model multiplies. **The boost is additive, not a replacement** — the base
is never dropped.

Three multipliers apply to the special variants, and the defaults encode the economics: **frozen
defaults to 2.0**, sleeping and hibernated to 1.0. Frozen has no exit at all, so it earns double.

**The multipliers are immutable once positions exist.** Changing them would leave every existing
row wrong; the migration path is a new score, not an edit.

### Scores can point at each other

A score may take its base from *another* score. When it does, its own stored base is zero — the
canonical base lives on the linked score, and this one stores only the boost it contributes.

With a caveat the source states plainly: **summing base + boosted + deb across linked entities does
not reconstruct a single total.** They are views, not addends.

---

## 5. Anchors

An anchor converts holding one asset into a per-mille boost on a score for a *different* asset.

For fungibles the boost is **pro-rated, not a threshold**:

```
promille = (your_amount / anchor_amount) × anchor_promille
```

Hold two and a half times the anchor amount, get two and a half times the boost. For collectables
it counts whole units — nonces matching a nonce number, a trait, or a set class.

The *result* is uncapped; the *definition* is bounded. Per-unit leverage is fixed at issue, but
accumulated boost still grows by staking more.

### Two sevens, and they are different

A **boost class** holds up to **7 anchors**, and they may be heterogeneous — different assets,
different asset types, in one class.

Separately, each asset tracks **7 groups × 7 slots = 49 anchors**. That grid is bookkeeping: it
lets a single read enumerate everything anchored to an asset. The whole lookup chain is direct key
reads — **no scans anywhere**.

*(A third seven-by-seven exists, unrelated: the 49-stream cap in §2. Three sevens in one subsystem
is a naming coincidence worth noting so a reader does not infer a connection.)*

### A vulnerability worth recording

Boost classes originally had **no owner**. Anyone owning any anchorable asset could anchor it into
someone else's class and hand their holders a boost inside that vault's scoring. As the note puts
it: *six free slots on a seven-slot class is six such grants.* An owner field was added.

---

## 6. Delegated staking

An agency is one member of a farm. Delegators stake into it; an operator runs infrastructure and
takes a per-mille fee, bounded between **1% and 50%**.

The fee mechanism is worth quoting because it is unusually clean:

> the member index advances by the **net**, so every staker accrues net, and the whole fee is
> credited direct to the operator's pending. **The fee never touches a stored weight, so a fee
> change reprices only the next injection** — O(1).

No migration, no recomputation, no per-staker loop. Changing the fee is one field.

### The oracle, and a 25-hour window

Capacity is reported by an oracle. If its last write is stale, the agency **captures nothing** and
its whole share routes to a separate royalty pool.

The window is **25 hours**, and the constant documents its own arithmetic: *a daily oracle write
plus one hour of overlap, so there is never a gap between last-write-expired and next-write.*

The oracle writer is authorised by a **guard rather than an account** — deliberately, with the
attribution one level up: the function that *registers* the guard takes a proven executor. Authority
and accountability are separated on purpose, and the source says so.

The shortfall between ideal and actual capacity accumulates as royalty, custodied separately and
disposable by the owner in three ways: withdraw, burn, or convert to liquidity.

---

## 7. Vacating

A pool owner can force-unstake everyone. It has its own module, and the reason is the ordering:

**Vacate unwinds in a different order than staking.** Staking transfers custody *first*; vacating
transfers custody **last**, after the trackers, scores and reward checkpoints are settled.

It is also a gas-planning problem rather than a logic problem. The cost model is measured:

```
estimated_gas = unique_beneficiaries × 75,000 + positions × 4,000   ≤ 2,000,000
```

Cost is dominated by per-beneficiary settlement, so roughly **481 positions if concentrated, 25 if
spread**. Large pools drain in slices, and there is no finalise flag — the batch that empties the
pool finishes the job, which is safe because the chain executes serially.

The philosophy behind that number recurs across this subsystem and is worth adopting:

> this on-chain check is a **generous backstop**, not the optimizer. The interface sizes real
> batches by simulating against true gas, and the node's meter is the real enforcement; an aborted
> oversized batch rolls back — the submitter's gas, no protocol harm.

---

## 8. Limitations

**Things that cannot be changed after the fact.** A score cannot be deleted. Boost links are
one-time and never cleared. A score belongs to one pool and one distributor. Adding a second LP to
a farm is a new pool plus new scores — never reusing existing ones.

**One known staleness gap**, recorded as a design gap rather than a bug: after an anchor
synchronises, a score's boosted value stays stale until that user's next stake or unstake in that
pool.

**The naive injection path distributes over the current divisor.** Only the checked variants
refresh stale members first. The source states the trade: *freshness is a caller concern.*

**And the test state is stated honestly** rather than as a pass:

> Honest testing: the deployment triad is green. **Not every matrix reject/partial is closed.**

Several rejection-path suites are explicitly listed as missing, including the 49-anchor cap.
Publishing that list is more useful than a coverage percentage.

### Documentation inside the subsystem has drifted

Several of its own notes now describe code that changed — a module file number, a table name, an
API with a flag the code says does not exist, and a set of gas ceilings explicitly marked
superseded in the source.

That is worth stating in a public document for one reason: **this chapter was written from the
code, not from those notes**, and a reader who finds them should know which is authoritative.

---

## Sources

- `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/` — ten files: schemas, anchors, scores, pools, the reward
  engine, the distributor, vacating, multi-step operations, delegation, and previews
- The subsystem's own `README_*.md` files — used for vocabulary, **not** for figures
- `REPL/Kursan/AQP-scale-sweep.repl`, `AQP-scale-inject.repl` — the gas measurements

There is no prior whitepaper chapter for this subsystem; it was written from source.

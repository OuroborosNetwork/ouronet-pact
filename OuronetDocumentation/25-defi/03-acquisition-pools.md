# Acquisition pools

The third family, and the largest single subsystem in Ouronet — **twelve files, 33,353 lines**. It is
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

## 8. Evicting rewards

Vacating returns **assets**. Evicting returns **rewards**, and the two are not variants of each
other — an eviction does not unwind a single stake, change a single score or freeze anything. It is
a collect, triggered by the pool owner instead of the beneficiary.

The asymmetry in *who* is checked is the whole of it:

| | who must prove ownership | who is paid | who pays the IGNIS |
|---|---|---|---|
| collect | the **beneficiary** | the beneficiary | whoever sponsors the call |
| evict | the **FVT owner** | every listed beneficiary | the evictor |

So an FVT operator can hand their stakers their rewards without those stakers doing anything, and
pays for the privilege. That is the point: the operator wants the tokens out of the aggregator, and
the stakers are the only legitimate destination.

**It pays exactly what a self-collect would pay.** Not approximately — the eviction path calls the
same phase functions a collect calls (the drip, the payout, the checkpoint), so there is one
implementation and not two that have to be kept in agreement. This is asserted rather than
asserted-to: a differential test runs three rounds inside **one transaction** on one account —
prime, inject-and-collect, inject-and-evict — and checks exact equality of the payout, the
reward-per-share checkpoint, the pending drain and both available-reward aggregates. One
transaction matters, because block time does not advance inside it and a live reward stream
therefore vests identically across the rounds; across two transactions the comparison would be
measuring the clock.

**A whole-FVT eviction leaves no dust.** It pays *every* leg, so the last claimant's dust sweep
pays out the entire remaining balance and the lane lands on exactly zero — measured as `0.000000`,
not as a rounding residue. A single-leg collect cannot do that and does not claim to.

### Two deliberate asymmetries

**The staleness penalty is waived.** A staker whose scores have gone stale normally pays a small
IGNIS penalty when they collect, because somebody had to refresh them. Eviction **zeroes** that
counter instead of charging it, and the reasoning is the owner's: a staker whose rewards are
evicted *for* them never had the chance to collect them, so charging them for the refresh would be
billing them for not acting.

**The slice path refuses a zero leg; the whole-FVT path does not need to.** A sliced eviction is
fed arrays a client read in an *earlier* transaction, so a leg can go stale in between — and a zero
reward simply means there is nothing to collect, which is a refusal rather than a billed no-op. The
single-transaction variant reads its own legs in the transaction that spends them, so no such
window exists.

### Paid and gasless

Reward eviction has four client entrypoints, in two pairs:

| | one slice | whole FVT |
|---|---|---|
| anyone who owns the FVT, pays IGNIS | `AQP-EVCT\|CCp_EvictRewards` | `AQP-EVCT\|CC_FullEvictRewards` |
| Ouronet administrator, gasless | `AQP-EVCT\|AAp_EvictRewards` | `AQP-EVCT\|AA_FullEvictRewards` |

The gasless pair exists because daily eviction across every administrator-owned FVT is the intended
operating mode, and at normal rates that is a large standing IGNIS bill. The exemption is not a
flag on the operation — it is a property of **one account**, the Ouronet system account, which the
collector recognises and does not charge. The collection path still runs and the operation is still
priced; it simply is not billed.

Two consequences worth being explicit about, because each is a door that could have been left open:

- **The gasless pair is admin-gated as well as owner-gated.** Eviction itself only checks FVT
  ownership, so a gasless wrapper carrying no admin check would have handed every FVT owner in the
  system an unmetered path to the gas station. The admin keyset says the call may happen; the owner
  konto says whose rewards may move. Both are required, and the *ownership* half is the one the
  tests isolate — signed with an admin key that does not own the FVT, the gasless call is refused.
- **Gasless means no IGNIS, not no gas.** The Chainweb gas is still paid, by the Ouronet gas
  station, because this is a Talos path like any other.

### Where it sits, and what it cost to build

Eviction is its own module. It owns no table, holds no custody and performs no write of its
own — every write is a forward call into the distributor's eviction surface. That is why it needs
no entry in the pool policy table and no governor rotation, and it is the reason the module is
small (about 36 KB) next to the subsystem it extends.

Building it forced two changes elsewhere, both visible to a reader of the code:

- **The triplet reward ladder now coils from the pool account, not from the beneficiary.** A
  multiplet reward pays through up to three tokens, and the coiling step used to send *from* the
  account being paid — which works for a self-collect and is meaningless when somebody else
  triggers it. Autostake usage grew a coil whose funder and recipient are separate accounts, and
  the collect ladder was rewritten to use it. Measured: **+9.5% gas on the ladder, with the payout
  amounts identical to 24 decimal places** — the price of having one implementation instead of two.
- **The reward engine was split.** It had reached 336 KB of source against a transaction size
  charge that grows as the **seventh power** of size, so there was no version of this work in which
  it also absorbed the eviction readers. Six cost-preview readers moved to a sibling module. The
  engine keeps its name and its tables, because a deployed Pact module cannot be renamed and its
  tables are bound to its identity.

---

## 9. Limitations

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

- `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/` — twelve files: schemas, anchors, scores, pools, the reward
  engine, its cost-preview sibling, the distributor, vacating, multi-step operations, delegation,
  reward eviction, and previews
- The subsystem's own `README_*.md` files — used for vocabulary, **not** for figures
- `REPL/Kursan/AQP-scale-sweep.repl`, `AQP-scale-inject.repl` — the gas measurements

There is no prior whitepaper chapter for this subsystem; it was written from source.

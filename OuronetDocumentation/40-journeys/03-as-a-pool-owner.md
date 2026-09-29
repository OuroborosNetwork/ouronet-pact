# As a pool owner

Creating a pool, the parameters you choose, and what you can and cannot do to your users
afterwards.

Three pool families. This chapter covers what an owner decides in each.

---

## 1. A swap pool

**Two to seven tokens.** The curve is not a setting you pick by name — it is **derived from the
parameters you supply**:

| you set | you get |
|---|---|
| an amplifier (1 – 2000) | **stable** — Curve-style, for assets that should trade near par |
| no amplifier, weights summing to 1.0 | **weighted** — Balancer-style |
| no amplifier, all weights 1.0 | **plain constant product** |

The resulting letter appears in the pool's identifier and in its LP token's name, so anyone can
tell what mathematics your pool runs.

**Issuance costs $50** and mints **10,000,000 LP** to you at 24 decimal places.

### What you set afterwards

**Three fees**, each per mille, each capped at 320: one to liquidity providers, one to targets you
name, one protocol-wide. Combined they can never consume more than 96% of a swap.

**A fee lock**, which is the decision that matters most to anyone quoting against your pool.
Unlocked, a trader's slippage protection does not cover you changing the rate between their quote
and their transaction. Locking costs nothing; unlocking costs $50 twice over.

**Whether asymmetric deposits are allowed**, and whether frozen or sleeping liquidity is accepted.
Both of the latter are **irreversible** — no code path writes them back to false.

**Weights and the amplifier can be changed.** Be aware that Ouronet has no gradual ramp: a change is
instantaneous, reserves do not move, so the implied price jumps and whoever notices first
arbitrages it. Balancer and Curve ramp precisely to avoid this.

### What you cannot do

**You cannot stop withdrawals.** You can pause new liquidity and you can halt trading. Removal is
deliberately exempt, and the source states why:

> an admin-controlled ability to freeze user funds already deposited **isn't a safety mechanism,
> it's a trust violation**

It notes that Curve's kill switch exempts plain removal and Balancer's recovery mode is
permissionless while paused. Same conclusion, reached independently.

---

## 2. An autostake pool

Users stake a reward token, receive a receipt, and the receipt gains value as the pool's index
rises. **Issuance costs $40.**

### What you control

| | |
|---|---|
| **royalty** | a per-mille cut of every deposit |
| **hibernation mode** | decides which two of four entry operations are available |
| **entry fee curve** | a peak and a decay rate, for hibernated entries |
| **recovery toggles** | which of three exits you offer |
| **index precision** | how finely the index is floored |

**Hibernation mode is global to your pool**, not per-user. With it off, users can coil and curl —
liquid receipts. With it on, they constrict and brumate — time-locked receipts. A user who wants the
other kind cannot have it.

The entry fee **decays with commitment length**: longer locks are cheaper to enter. Peak and decay
are validated together — the peak must be an exact multiple of the decay — so the curve reaches
zero at a whole number of days rather than crossing it mid-day.

### The starting condition

A pool cannot start until its would-be index reaches **0.1**. Without that floor a pool could be
started at a near-zero index, where a trivial deposit mints an enormous receipt supply.

**Nothing in the mechanism generates yield.** An autostake pool distributes; it does not produce. If
you create one, you are committing to fund it — from protocol revenue, a treasury, or a swap pool's
fees.

---

## 3. An acquisition pool

The most configurable and the most work. You are assembling four things:

**A pool** — accepts one asset shape, from five classes.

**Up to seven scores** — the weighting rules. Each turns a stake into a number, with multipliers for
locked variants. The default for frozen holdings is **2.0**: double weight, for the lock with no
exit.

**Optionally, anchors** — rules that boost a user's score based on assets they hold elsewhere. Up to
seven per boost class, 49 per asset.

**A distributor** — Farm, Vault or Treasury, depending on what your scores weight. A farm has
two-level accounting so a large member pool does not swallow a small one.

### What you should know before committing

**Scores are immutable once staked.** Changing a multiplier would leave every existing position
wrong. The migration path is a *new* score, not an edit.

**Links are one-time.** A score belongs to one pool and one distributor, permanently. Adding a
second liquidity pool to a farm is a new pool plus new scores — never reusing existing ones.

**Claims are free, injections are not.** The reward model means a user's claim is two reads and a
multiply regardless of how many stakers or injections there have been. Your cost is at injection,
and it scales with the number of *members*, not stakers.

**Vacating is a gas-planning exercise.** Force-unstaking everyone costs roughly `75,000 ×
beneficiaries + 4,000 × positions`, against a 2,000,000 ceiling — about 481 positions if
concentrated, 25 if spread. Large pools drain in slices.

---

## 4. Across all three

**Preview and charge cannot diverge.** Every priced operation has one cost function, called by both.
You do not maintain a separate price display.

**Your users' costs are visible to them** before they sign, including anything you set.

**Some parameters are one-way.** Enabling frozen or sleeping liquidity, enabling fractionalisation,
creating a special link — all irreversible. None happens by accident; none can be undone by asking.

**Ownership transfer is one-phase** everywhere. A mistyped destination permanently strips you.

---

## Where to read next

- `25-defi/02-swap-pools.md` — the curves, routing, and limitations
- `25-defi/01-autostake-pools.md` — the index model
- `25-defi/03-acquisition-pools.md` — scores, anchors, reward-per-share

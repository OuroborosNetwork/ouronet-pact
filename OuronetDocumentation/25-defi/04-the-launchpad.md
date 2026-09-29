# The launchpad

DemiPad is a **permissioned venue** where assets are sold for one of three tokens while the
protocol retains a decreasing royalty.

It is also the clearest worked example of the sovereign/citizen boundary this documentation keeps
referring to, so it is worth reading even if launchpads are not your interest: **five independent
sales are built on one sovereign core, and none of them can touch its internals.**

---

## 1. What the sovereign core provides

Four administrative operations and ten client ones, generic over all four asset types.

| | |
|---|---|
| **Inventory custody** | unsold assets sit in one protocol account; a sale reads what remains |
| **The money-in leg** | dollars → working token, the wrap/unwrap, the split, the royalty |
| **The royalty curve** | identical for every sale |
| **A price record** | typed as an *open object* — each sale defines its own shape |
| **Withdrawal** | accumulated funds out to the asset's seller |

That fourth row is the extension point. The core stores a price blob and never interprets it; each
sale reads it back with its own accessor. So one venue can host a flat per-unit price, a
share-based price, a weight-based price and a time curve without the core knowing any of them.

---

## 2. What a sale provides, and why it cannot cheat

A citizen sale owns: what one unit costs in dollars, what is available, which transfer moves the
good, and any post-sale mechanics.

**It is strict composition, not inheritance.** A sale is two or three sovereign calls in sequence:

```
1.  DEMIPAD|C_Deposit    — take the money
2.  DPTF|C_Transfer      — hand over the goods
```

And the constraint that makes this safe is economic rather than syntactic. From the code:

> A citizen cannot fold cumulators (no permission for the bare uncollected core functions), so
> **IGNIS is billed Σ-wise — once per operation.**

A sovereign module composes a bill across its legs and charges once. A citizen module has no
access to the uncollected internals, so it must call *finished* operations, and each bills
independently. A citizen sale therefore costs **the sum of its legs**.

That is a real cost — a redemption path runs **six** sovereign operations and pays six times. It is
also the enforcement mechanism: the permission boundary and the billing boundary are the same
boundary, so there is no way to be inside one and outside the other.

### The gas-funded path is separate from the callable path

The citizen sales' user-facing wrappers live in **one citizen Talos module, deployed last**, and
its header explains why:

> the citizen `C_` functions stay callable directly from their own module, but **ONLY these Talos
> wrappers are the gas-funded path** — a direct citizen-module call would not have its gas paid.

So a sale is permissionlessly callable and only conditionally sponsored. Anyone may write a citizen
module; being *paid for* is a separate grant.

---

## 3. How a sale works

**Everything is quoted in dollars and settled in tokens.** One conversion point reads a price
oracle and derives every accepted token's dollar value. A buyer pays with native currency, a
wrapped form, a staked form, or the protocol token — and the core wraps or unwraps as needed so
the internal accounting is uniform.

### Every dollar splits three ways

```
royalty     = the decreasing curve, applied to this deposit
  ├─ one third  → environment  (paid in native currency)
  └─ two thirds → coding division
remainder   → the seller's ledger
```

At the opening rate of 150‰ that is exactly **5% / 10% / 85%**, which is where the internal names
come from. As the curve decays, the one-to-two ratio holds and the absolute take shrinks.

### The royalty decreases with volume raised

Up to fifty intervals, from **150‰ (15%) down to 3‰ (0.3%)**, with the interval *size* growing as
the rate falls:

| cumulative raised | rate |
|---|---|
| first 10,000 | 150‰ |
| next 15,000 | 147‰ |
| next 20,100 | 144‰ |
| … | … |
| beyond the last | flat 3‰ |

The fee is **marginal, not tiered**: a deposit spanning a boundary is integrated across the
intervals it crosses. A buyer who pushes a sale past a threshold pays the blend, not the new rate
on the whole amount.

That matters for the incentive it creates — early buyers fund the protocol most, and a large buyer
is never penalised for the size of a single purchase.

### Slippage

Two modes, selected by a sentinel. With protection, the interface receives the literal signing
limits, padded by the chosen percentage, and a maximum cost is enforced on-chain. Passing a
negative maximum selects the second mode, where limits are installed at the live price.

### There is no claim step

For four of the five sales, the asset moves to the buyer **in the same transaction**. Only a
redemption path and one distribution vault have a separate collection step.

---

## 4. The five sales

| | sells | priced by |
|---|---|---|
| **Spark** | a redeemable token | flat dollars per unit |
| **Snakes** | equity shares | live share price × shares in that tier |
| **Custodians** | node-operator fragments | a weight per fragment tier |
| **StoicPay** | a token | **a three-year linear curve** |
| **StoicIco** | *nothing* — a distribution vault | n/a |

**Spark** is the only one with real post-sale mechanics: a Spark redeems for **$1 × (1 + boost)**
in currency, and redemption does not burn — it recycles the unit back into the launchpad and
re-freezes it to the redeemer, across six operations.

**Snakes and Custodians are deliberate mirrors** of each other — nearly identical size and
structure, cross-referencing each other in comments as "the twin". Snakes prices off the live
equity module rather than a hard-coded ladder, so package tiers track the company. Custodians uses
**negative nonces** — bronze, silver, golden fragments weighted **1, 10, 100**.

That weighting is not arbitrary. It is the same unit the delegated-staking system uses for agency
capacity, and the delegation module names Custodians as its first client. **The launchpad sale is
the on-ramp to the staking subsystem**, and the two are wired through a shared unit rather than a
shared module.

**StoicPay** prices on a clock, not on demand: **$0.01 at launch rising linearly to $1.00 over
three years**, with supply released across 25 periods on an arithmetic series. The buy path quotes
ten minutes ahead so a signed transaction cannot be invalidated by the clock.

**StoicIco** is not a sale. It is a small, independent reimplementation of the reward-per-share
model from `03-acquisition-pools.md` — same index, same pending field, same escrow-on-empty — with
a round barrier: a new distribution opens only when everyone has collected the last one. An
administrative sweep exists to push-collect stragglers and unblock it.

---

## 5. Two things a reader should not carry across

**The revenue split is not the protocol's.** Both split four ways as 10/20/30/40, and both use the
same helper — but the destinations differ:

| share | protocol fee | launchpad environment |
|---|---|---|
| 10% | holding company | **gas station** |
| 20% | **gas station** | holding company |
| 30% | development | development |
| 40% | liquid staking | liquid staking |

**The first two are swapped.** Verified in both sources. Anyone reusing the protocol's table to
describe the launchpad will attribute the wrong shares to the wrong accounts.

**And there is no protocol fee on a launchpad operation at all.** Every sale's preview says so
explicitly, and the wording is careful:

> the acquisition cost is declared in the description as **the good being bought, not a fee to
> execute.**

What you pay for a Spark is a price, not a charge. The only protocol charge is the virtual gas for
the operations themselves.

---

## 6. Where this connects to the rest

The coding-division share accumulates in the launchpad's own account, and the code carries a
commented-out future path:

```pact
;;When AQP LIVE, to be replaced by:
;;(ref-AQP::C_Inject <pool-id> <working-id> <cod> <injection-type>)
```

That is the seam between this chapter and the previous one: launchpad revenue is intended to fund
acquisition-pool rewards. The wiring is not live, and a commented intention is not a feature — but
it is the clearest statement of how the three families are meant to close a loop.

---

## 7. Preview and charge cannot diverge

Every sale ships a matched pair: a cost function and the preview an interface renders. The preview
sums the *sovereign* cost functions of its own legs, so it is derived from the same numbers the
execution pays.

**One defect proves the design was worth having**, and it is quoted here because it is small enough
to be checkable:

> The Σ counted the deposit and the transfer gas but **not the royalty**. A collectable transfer
> pays the collection's creator out of the patron, so a buyer of a royalty-bearing nonce is charged
> more than the preview quoted. **Measured: 89.002 quoted against 89.004 charged on a two-share
> buy.**

Two thousandths of a token. It was found because the preview and the charge are separately
computed from a shared definition, and someone compared them — which is the whole argument for
building it that way.

---

## Sources

- `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact` — the sovereign venue
- `2_CITIZEN/7_Launchpad/` — the five sales and the citizen Talos
- `1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact` — the sovereign orchestration

There is no prior whitepaper chapter for the launchpad; this was written from source. The two
whitepaper table rows that mention it are stale — they place the citizen wrappers on the sovereign
Talos, which they left, and omit one sale entirely.

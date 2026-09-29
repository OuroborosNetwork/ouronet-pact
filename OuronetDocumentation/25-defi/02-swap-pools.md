# Swap pools

The largest subsystem in Ouronet — seven modules, **15,243 lines** — and the one with the most
prior art to be measured against. This chapter covers the mathematics, the routing, and the
limitations, in that order.

---

## 1. Three curves, chosen by the pool's own parameters

A pool holds **two to seven tokens**. Which curve it runs is decided once, at issuance, from the
weights and the amplifier:

```pact
if amp == -1.0:  if weights sum to 1.0  → "W"   else → "P"
else:                                             → "S"
```

| | curve | when |
|---|---|---|
| **S** | Curve StableSwap | an amplifier is set (1.0 – 2000.0) |
| **W** | Balancer-style weighted product | no amplifier, weights sum to exactly 1.0 |
| **P** | plain constant product | no amplifier, every weight exactly 1.0 |

`-1.0` is the sentinel for "not a stable pool", which is why the amplifier's lower bound of 1.0
also excludes it with a single range check.

**The letter is the first character of the pool's identifier**, and of its LP token's name and
ticker. You can tell what mathematics a pool runs by looking at the token it issued.

### S — the StableSwap invariant

The source says what it is: *"Stable Pools Computation using Curve Finance original math."*

The invariant `D` is solved by Newton iteration:

```
n  = token count,  S = Σxᵢ,  P = Πxᵢ
Dp = D^(n+1) / (P · nⁿ)
D' = ((A·nⁿ·S + Dp·n) · D) / ((A·nⁿ − 1)·D + (n+1)·Dp)
```

**`A` is the amplification coefficient**, and it interpolates between two behaviours: large `A`
pushes the solution toward a constant *sum* — a flat, near-zero-slippage line, which is what you
want for assets that should trade at par — and small `A` toward a constant *product*, the ordinary
curve.

Swapping solves for the new output reserve with a second Newton iteration.

**The amplifier is capped at 2,000, and the reason is measured rather than conventional:** the
solver runs a *fixed* iteration count, and round-trip convergence stays around 1e-13 into the low
hundreds but degrades to about 1e-7 by A = 5000 on skewed reserves. The ceiling is where the
arithmetic stops being trustworthy, not a number someone liked.

### W and P — closed form

```
xA^wA · xB^wB · …  =  (xA + in)^wA · … · (xC − out)^wC · …
```

Weighted pools solve this directly — no iteration. Equal-weight pools are the same expression with
every exponent 1, so no exponentiation at all.

---

## 2. Two things Pact forced, and both are documented

### Fixed iteration counts

Pact is **not Turing-complete** — there is no dynamic loop and no early exit on convergence. The
iteration count must be decided in advance. The source states this plainly, and then does the
work:

Measured at 1000× reserve skew, six iterations left the invariant off by **0.0078 absolute**, and
the result was bit-identical to a 255-iteration reference by iteration **ten**. It is set to
**twelve**, for two iterations of margin, at a cost of **64 gas**.

That is the right shape for a constant that cannot adapt: measure where it converges, add margin,
state the cost.

### A precision limit that was accepted rather than fixed

Pact's native `^` drops to double precision for decimal exponents. For the stable pools this was
worked around with repeated multiplication, since those exponents are whole numbers.

**For weighted pools it cannot be**, because the exponent is a genuine fraction. The source
declines the fix explicitly:

> Fixing this fully would mean writing a from-scratch high-precision power routine … assessed and
> explicitly declined as disproportionate to the residual risk. **Accepted as a bounded, documented
> limitation of the underlying language, not tracked as an open bug.**

The audit book is blunter, and its phrasing is the one a liquidity provider should read:

> **It is a real, permanent, bounded arbitrage against weighted-pool LPs.**

Both sentences belong in this documentation. The first is the engineering decision; the second is
what it means for someone's money.

### Rounding always favours the pool

Six functions, one rule: floor what is paid **out**, ceiling what is taken **in**.

The subtlety is *where*. Flooring the intermediate solution before subtracting made outputs
systematically **larger** than the exact invariant — favouring the trader, at the pool's expense.
Rounding the final settled amount instead favours the pool, matching Curve's convention.

---

## 3. Fees

Three components, all in per mille, all capped at **320‰** individually:

| | goes to |
|---|---|
| **LP fee** | back into the reserves — raising every LP token's value, not minting new ones |
| **special fee** | the pool's configured targets, proportionally |
| **boost fee** | converted and burned, raising a protocol-wide index |

The cap is deliberate: three components at 320 leaves **at least 4% of every swap that fees can
never consume**.

The LP fee is withheld from the **input** before the curve runs, so it never enters the
mathematics. The other two are taken from the **output**. Elite account tiers discount all three.

There is no fee on liquidity removal.

---

## 4. Slippage

```pact
{ expected-output-amount, output-precision, slippage-percent }
```

Bounded to **50%**, two decimal places, with `-1.0` meaning no protection.

**It is a floor only.** The upper bound exists in the source and is *commented out, not deleted*,
with the reasoning recorded:

> Rejecting a swap for delivering MORE than quoted ("positive slippage") isn't how any major AMM
> works — checked Uniswap V2/V3, Curve, Balancer, SushiSwap, PancakeSwap: every one enforces a
> floor only on exact-input swaps, never a ceiling.

Breaching it is **not a revert**. The swap returns a zero-cost result carrying the message, and the
client formats *"Smart Swap not executed: …"*. You are not charged for a swap that did not happen.

### A hole that was closed, and one that is open by design

**Closed:** the 50% ceiling originally lived only in the *constructor*, which is called by the
interface — while the client entrypoint takes the *built object*. A forged 9,999% drives the floor
to **−98,990**, so no output can breach it and the protection is inoperative. A validator on the
object itself now runs from four capabilities.

That is a general lesson about validation placement: **a check in a constructor protects callers
of the constructor, not callers of the function that takes its output.**

**Open, and disclosed:** slippage compares a *fee-exclusive* quote against *fee-exclusive*
execution. It correctly catches reserve movement. It does **not** catch a pool owner changing the
fee rate between your quote and your transaction — only the fee-lock does that, and **fee-lock is
off by default**. An integrator quoting against an unlocked pool has no fee-rate guarantee.

---

## 5. Asymmetric liquidity

Most AMMs require balanced deposits, or mint you less LP if you deposit lopsided. Ouronet takes a
third path, and it is the most distinctive thing in this chapter.

> Unlike the Curve approach, which restricts LP minting, this tax **permits minting but imposes a
> fee** to offset the deficit.

You may deposit any ratio. You receive the full LP. You pay for the imbalance **in IGNIS**.

### How the imbalance is priced

Not by a formula on the deposit — by **simulating the trades that would rebalance it**. The engine
builds a virtual pool from the real reserves plus the balanced part of your deposit, then virtually
swaps the asymmetric remainder into a single token and back, accumulating the fees those swaps
would have paid. The shortfall is the deficit.

That is a genuinely unusual design: the price of imbalance is *the cost of the arbitrage your
imbalance creates*, computed rather than approximated.

Five distinct taxes exist, each an evented capability: gaseous, deficit, fuelling, special, and
liquid-boost. Which apply depends on the deposit mode — and there are five of those too, trading
native LP for frozen or sleeping LP (see `20-assets/07-pool-positions.md`).

Deviation is capped at **40% of the theoretical maximum** for the pool's token count, and the whole
feature is behind a protocol-wide administrator switch.

### The honest part

The compensation does not go to the diluted pool's own liquidity providers. The audit states it
directly:

> It is captured protocol-wide (treasury, special targets, primordial-pool boost). LPs in a pool
> that receives a large asymmetric deposit are diluted and compensated **indirectly, not
> directly**. This is a legitimate design choice and **it should be visible to anyone providing
> liquidity**.

---

## 6. Routing

Pools form a graph: tokens are nodes, pools are edges, and **parallel pools between the same pair
are a list on one edge** rather than separate edges.

A breadth-first search finds a route; each hop then picks its edge by **highest computed output**,
evaluated against live reserves.

### Caching structure, never value

The path cache stores **nodes and edges only** — never an amount. Every use re-derives from current
reserves. Entries carry a **topology version**, bumped only when a genuinely new connection or a
genuinely new parallel pool appears, so a stale route collapses to a cache miss rather than being
served.

The cache exists because it was originally insert-only and first-write-wins: an entry could never
be refreshed even after new pools made a better route possible.

### Best-of-three became first-found, on evidence

The router used to compute three candidate routes and pick the best. It now takes the first, and
the measurement is in the source:

> against this codebase's real, organically-grown ~102-pool topology (not a hand-engineered one)
> across 7 representative pairs spanning 1–8 hops: best-of-3 found a better route than the single
> first-found one in **ZERO of them — 0.0% difference every time.**

The caveat is stated just as plainly, and it was true at every setting:

> per-hop selection is a **greedy** choice and does not mathematically guarantee the overall path
> is the highest-value one achievable end to end.

A greedy router that says so is more useful than an optimal-sounding one that does not.

### Where the depth cap actually is

There is a constant — **7 nodes, 6 hops** — and an attempt ceiling of 50,000. Both appear in
exactly one file.

The depth bound is a **post-discovery filter** on the exhaustive search, not a constraint inside
the traversal, and the source explains the deviation: baking a bound into the shared search utility
would change a lower-layer module with other callers, and the exhaustive search is **read-only,
never a paid path**, so the efficiency argument for baking it in does not apply.

So the bound a reader should carry is: the **submitted-route** variant validates against the 7-node
cap explicitly; the self-searching variant is bounded by the **size of the pool graph** rather than
by a hop count. Those are different guarantees, and worth knowing which one a given entrypoint
gives you.

---

## 7. Two smart swaps, and an 18× gas story

| | self-searching | route-supplied |
|---|---|---|
| finds the route | **in the transaction** | client supplies it |
| validates | against its own computation | the **submitted** route, against the live graph |

Both exist deliberately — the second was built *alongside* the first for direct comparison, not to
replace it.

The reason is a measured crisis. Worst-case execution reached **6–7 million gas against a ~2
million ceiling**, and the largest single contributor was not routing at all:

> **56.9%** came from a previously-unknown source — post-swap per-pool re-pricing.

The redesign measured **7,145,298 → 397,043 gas on the identical worst-case swap: 18.5×.** Further
work took a cold cache from 5,094,054 to 1,296,898, and a warm one to 1,143,255.

**One phase failed and is recorded as a failure.** A binary search over a sorted graph list looked
like a win synthetically and **regressed by 27,527 gas** in real integrated measurement. Reverted,
written down as a negative result.

Keeping the losing experiment in the record is what makes the winning numbers credible.

---

## 8. Limitations

Stated plainly, because a DeFi reader will ask.

**No concentrated liquidity.** The owner is direct:

> "only a few exotic things are missing like concentrated liquidity (which we'll research and add
> on a later date, if needed)"

**No price oracle.** No time-weighted accumulator, and no external oracle — one reference price is
currently hardcoded, pending future work.

**No flash loans, no hooks.**

**Weight and amplifier changes are instantaneous.** Balancer ramps weights gradually and Curve ramps
its amplifier over time, precisely because an instant change moves the implied price with reserves
unchanged — which is arbitrageable by whoever sees it first. Ouronet has no ramp.

**Exact-output swaps are compute-only.** The inverse mathematics exists and is used for quoting, but
every client entrypoint is exact-input.

**Abandoned multi-step operations persist forever.** Pact has no scheduled execution, so nothing can
expire them. And explicit rollback costs *more* than walking away — measured at 53 IGNIS extra,
nothing refunded.

**Ownership transfer is one-phase.** A mistyped destination permanently strips the owner. Mitigation
is client-side only.

**One latent issue with no finding number.** A valuation function hard-codes the reserve order of
one special pool while the capability that guards it checks only membership and length. A pool
issued with the same tokens in a different order would transpose them silently. Unreachable today
only because genesis happens to use the matching order — which is a property of the fixture, not of
the code.

### What is *not* missing, deliberately

Two omissions that look like gaps and are decisions:

**No reentrancy mutex.** A comparison against a mainnet AMM that has one concluded it is not needed
here: an isolated test proved Pact blocks any write attempted during guard evaluation, and the
failure is not catchable.

**No pause that blocks withdrawals.** Owners can halt new liquidity and halt trading. They cannot
stop you leaving.

---

## Sources

- `1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact` — all three curves and the solvers
- `1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact` — the search
- `1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact` … `20_MTX-SWP.pact` — graph, registry, issuance,
  liquidity, the client surface, swaps, and the multi-step variants
- `Audit/book/PART-I/03-SWP.md` — the audit's own limitation list
- `Audit/module-audits/SWP/` — findings, owner rulings, and the mainnet AMM comparison

Gas figures are audit-measured and quoted as such; they were not independently re-executed for this
chapter. Curve parameters and iteration counts were read from source.

# Pool positions

Three pool families — autostake, swap, acquisition — and a position in each is **an ordinary asset
you hold**, not an entry in a registry. That is the design decision worth understanding, because
it means a position is transferable, stakeable, and composable with everything else in this
section.

`25-defi/` covers how the pools work. This chapter covers what you are holding.

---

## 1. Swap pools: the LP token

An LP token is a **true fungible**, issued and owned by the protocol's swap account, redeemable
pro-rata for the pool's reserves.

Issuance mints exactly **10,000,000** LP to the founder, at **24 decimal places**. Redemption
burns your LP and pays out every pool token at the current ratio:

```
ratio  = your_LP / total_LP_supply
out_i  = ratio × reserve_i
```

The supply in that denominator is the **live circulating supply**, so every burn mechanically
raises everyone else's per-LP claim.

### The prefix tells you the pool's mathematics

| | |
|---|---|
| `S\|` | **stable** pool — Curve-style amplified invariant |
| `W\|` | **weighted constant product** — weights sum to exactly 1.0 |
| `P\|` | weighted, weights do **not** sum to 1.0 |

It is computed from the pool's own parameters and appears in three places at once: the pool
identifier, the LP token's name, and its ticker. You can tell what curve a pool runs by looking at
its token.

### One governance decision worth quoting

Pool owners can pause new liquidity. They **cannot** block withdrawals, and the source explains
why at the site:

> "`can-add` is a pool-owner switch meant to pause new liquidity provisioning; it must never also
> block existing LPs from getting their own principal back — an admin-controlled ability to freeze
> user funds already deposited **isn't a safety mechanism, it's a trust violation**."

It notes that Curve's kill switch exempts plain removal and Balancer's recovery mode is
deliberately permissionless while paused. Same conclusion, reached independently and recorded.

### Special variants cross the boundary

You can add liquidity **in a frozen or sleeping token** and receive **frozen or sleeping LP**.

The sleeping case is the cleanest illustration of "state, not token" in the whole system: the
sleeping parcel is burned, and a new sleeping LP parcel is minted **with exactly the remaining
duration**. The lock survives the transformation of the asset it was locking.

This is why the linking table in `06-the-special-variants.md` is asymmetric: frozen and sleeping
links are permitted on LP tokens; vesting and hibernation are not.

Enabling either is **owner-only and irreversible** — no code path ever writes the flag back to
false. It once was not owner-gated, and any caller routed through a governing path could enable
frozen LP on *any* pool.

---

## 2. Autostake pools: reward token and reward-bearing token

An autostake pool converts a **reward token** (what you stake) into a **reward-bearing token**
(what you hold), at the pool's index. The receipt is an ordinary true fungible.

```
index = total_staked / receipt_supply
```

The four live pools form a **ladder**:

| pool | stake this | receive this |
|---|---|---|
| Auryndex | OURO | AURYN |
| EliteAuryndex | AURYN | ELITEAURYN |
| SilverStoaPillar | WSTOA | SSTOA |
| GoldenStoaPillar | SSTOA | GSTOA |

Each receipt is the next pool's deposit. SSTOA is simultaneously one pool's output and the next
one's input — the joint in the ladder.

### The distinction that caused a live defect

On a **token**, `reward-token` and `reward-bearing-token` are **lists of pool identifiers** — reverse
indices answering *"which pools am I the stake in?"* and *"which pools am I the receipt of?"*

On a **pool**, they are token identifiers.

So the same two names mean different things depending on which row you are reading, and the
directions are opposite. Compounding it: an unset reverse index is the sentinel `["|"]`, **not an
empty list**.

That combination produced a failure measured on mainnet on 2026-09-27:

> A sentinel reached a table read. AURYN is a reward token on EliteAuryndex, whose receipt is
> ELITEAURYN, which is a reward token on **no pool at all** — so the second hop returned the
> sentinel, and `"|"` was used as a pool key.
>
> **A failed table read is not catchable.** So this did not degrade one field; it killed every
> caller, including the read the token toolbar is built from.

And the second half, which is worse than the crash:

> **The interface answered a failed read by enabling every button.**

A separate defect in the same area: two operations derived their availability from *whether an
eligible pool existed*, and two others from a flag *independent of that*. OURO measured
`can-constrict: true` with an **empty list of pools to constrict into** — a lit button with
nowhere to act.

Both are fixed, both pinned by tests, and the second was negative-tested by reverting it and
confirming ten assertions go red.

### Four ways in

A two-by-two grid:

| | one pool | two pools chained |
|---|---|---|
| **liquid receipt** | coil | curl |
| **hibernated receipt** | constrict | brumate |

Coil and curl require the pool's hibernation mode **off**; constrict and brumate require it **on**.
The hibernated variants end by hibernating the receipt, so the last leg is the bond described in
`06-the-special-variants.md`.

The entry fee for a hibernated position **decays with the length of the commitment** — a longer
lock is cheaper to enter. The exit fee on the resulting token decays as the release date
approaches. Two fees, both peaking at 80%, running in opposite directions.

### Three ways out

| | |
|---|---|
| **cold recovery** | position-based, with an unbonding period |
| **hot recovery** | mints an orto-fungible unbonding receipt |
| **direct recovery** | immediate, one flat fee |

A holding is recorded in **eight position slots** per account per pool, each carrying its reward
amounts and a maturity time.

### A near-miss worth including

Converting a receipt back divides by the index, so **index zero is a division by zero**. The source
records that this is not a contrived input:

> a reachable live state — any pair whose receipt carries supply minted **outside** the pool reads
> a zero stake against a positive receipt supply, which is exactly the state **the five primal-asset
> pools are in at deploy**

One entry point already refused. Another had no index check and "died inside the arithmetic … which
`try` cannot even catch." The guard now lives in the arithmetic itself, so previews and executions
refuse in the same words.

---

## 3. Acquisition pools: anchor, score, FVT

The third family is the most abstract, and three concepts carry it.

**A score** is a weighting rule. Your position under it is a row holding a base score, a boost, and
a final weight. Critically, the base is the **stable staked amount**, not its fluctuating market
value — so a full unstake reverses exactly and nets to zero. Valuation happens later, never stored.

The score is where special variants earn differently: three multipliers, for frozen, sleeping and
hibernated holdings. Frozen defaults to **2.0** — twice the weight, for the variant with no exit.
The economics follow the lock.

**An anchor** converts holding some *other* asset into a per-mille boost. Anchors group into
classes of seven, and an asset may carry seven groups — **49 anchors**.

Boosts are **additive, not multiplicative**:

```
final = (base + base × promille/1000) × account_tier
```

The source is explicit that the base is never dropped.

Anchors had a real vulnerability: a boost class originally had **no owner**, so anyone owning any
anchorable asset could anchor it into someone else's class and hand their holders a boost inside
that vault's scoring. *"Six free slots on a 7-slot class is six such grants."* An owner field was
added.

**An FVT** is Farm, Vault or Treasury — the reward distributor, using a reward-per-share model. It
links to scores, which link to pools, which name the stakeable asset.

The chain, in one line:

```
anchor → boost class → score → pool → asset
```

---

## 4. The shape of it

A position in any of the three families is an ordinary asset:

| family | position is |
|---|---|
| swap | a true fungible, pro-rata claim on reserves |
| autostake | a true fungible whose value grows with the pool index |
| acquisition | a score row, plus whatever you staked |

The first two are transferable, stakeable and freezable like any other token — which is why a
frozen LP token and a sleeping LP token exist, and why an autostake receipt can be staked into the
next pool up the ladder.

**That composability is the point of the type system.** A position that were a special registry
entry would need its own transfer logic, its own freeze logic, and its own everything. Making it a
true fungible means the 200 functions from `01-true-fungibles.md` already apply to it.

---

## Sources

- `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact` … `20_MTX-SWP.pact` — the swap family
- `1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact`, `10_ATSU.pact` — autostake
- `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/` — acquisition pools
- `Deploy/PureV2/22_deploy.pact` — the mainnet-measured sentinel defect
- `REPL/RedTeam/[RT-A]_Economics.repl`, `[RT-H]_InputDomain.repl` — the pinned near-misses

Pool pairings were read from deploy-time probes and initialisation sources. Live per-pool state —
current indices, fee settings, mode toggles — is not quoted here; it changes, and
`90-reference/03-how-these-figures-were-obtained.md` records the rule for such figures.

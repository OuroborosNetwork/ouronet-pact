# The three pool families

Ouronet builds three kinds of pool on top of its four asset types:

| | what you put in | what you get | what it does |
|---|---|---|---|
| **Autostake** | a token | a receipt token whose value grows | compounds rewards into an index |
| **Swap** | two or more tokens | an LP token | trades between them |
| **Acquisition** | a stake, plus qualifying holdings elsewhere | a weighted claim on a reward stream | distributes rewards by score |

The owner's framing:

> "On top of these, **3 defi-like assets** are built: autostake pools, swap pools, and earning
> pools. Each with their own complexities and management possibilities."

That word *assets* is exact. A position in any of the three is an ordinary Ouronet token, not a
registry entry — which is what makes them compose.

---

## 1. Why three rather than one

Each answers a different question about an idle holding:

**Autostake** — *"I want this to grow without doing anything."* You hold a receipt; the pool's
index rises; the receipt is worth more of the underlying. No claiming, no transactions, no
decisions.

**Swap** — *"I want this to earn from other people's activity."* You supply reserves; traders pay
fees; your pro-rata claim on the reserves grows.

**Acquisition** — *"I want a share of a reward stream, weighted by what I've committed."* Your
weight comes from a score, and the score can be boosted by holdings that are not in the pool at
all.

They are genuinely different mechanisms rather than one mechanism with settings, which is why they
get a chapter each.

---

## 2. How they compose

The composability is the interesting part, and it follows from positions being ordinary tokens.

**Autostake pools chain.** The four live pools form a ladder where each receipt is the next pool's
deposit:

```
OURO  → Auryndex        → AURYN
AURYN → EliteAuryndex   → ELITEAURYN
WSTOA → SilverStoaPillar → SSTOA
SSTOA → GoldenStoaPillar → GSTOA
```

SSTOA is simultaneously one pool's output and the next one's input. And because chaining is
common, there are single operations that traverse two pools at once rather than requiring two
transactions.

**Swap positions accept special variants.** You can add liquidity in a frozen or sleeping token
and receive frozen or sleeping LP — with the sleeping case preserving the **exact remaining
duration** across the transformation.

**Acquisition scores weight the variants differently.** Frozen holdings default to a **2.0**
multiplier against 1.0 for sleeping and hibernated. The economics follow the strength of the lock:
frozen has no exit at all, so it earns double.

**And anchors reach across all of it.** An acquisition pool can boost your score based on assets
you hold *somewhere else entirely* — including a position in one of the other two families.

So the three are not parallel products. They are layers that reference each other, and the
type system is what lets them.

---

## 3. What is missing

The owner is direct about the gap:

> "allow basically for everything defi offers today, only a few exotic things are missing like
> **concentrated liquidity**. (which we'll research and add on a later date, if needed)"

Concentrated liquidity — supplying reserves only within a chosen price band — is the significant
absence. `02-swap-pools.md` covers what that costs in practice.

---

## 4. Where to read next

| | |
|---|---|
| `01-autostake-pools.md` | the index model, and four ways in |
| `02-swap-pools.md` | three curves, routing, and the limitations |
| `03-acquisition-pools.md` | scores, anchors, and reward-per-share |
| `04-the-launchpad.md` | how a sale uses all of it |

For what a position *is* as an asset, see `20-assets/07-pool-positions.md`.

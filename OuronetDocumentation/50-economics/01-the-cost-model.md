# The cost model

Every priced operation in Ouronet costs the same two things added together:

```
IGNIS = deterrence + components
```

**Components** is the modelled cost of the work — table writes, reads, cross-module calls, each
weighted. **Deterrence** is a deliberate business premium: what an operation *should* cost,
independent of what it costs to run.

Both terms are in IGNIS, and IGNIS is pegged:

> **1 IGNIS = 1 US/EUR cent.**

That peg is the reason the model is arguable at all. A price of 2,549 is $25.49, and a pricing
decision can be debated in dollars rather than in an abstract unit.

---

## 1. Four constant maps

The whole cost model is four lookup tables, and their sizes tell you the shape of it:

| | entries | holds |
|---|---:|---|
| **weights** | 14 | the cost of a primitive — a write, a read, a cross-module call |
| **legs** | 22 | unit tiers for operations that scale with an item count |
| **deterrence** | 54 | the business premium, by operation class |
| **components** | **397** | the modelled compute, per named operation |

Each reader is a bare lookup that **fails on an unknown key**. There is no default. An operation
whose name is not in the map does not get a cheap price — it does not get a price at all, and the
transaction aborts.

That is the right failure mode for a pricing table: a missing entry is a bug, and silently pricing
it at zero would hide the bug behind revenue loss.

---

## 2. Deterrence is why issuance is expensive

Creating a swap pool computes almost nothing and costs **5,000 IGNIS — $50**.

That is not a mistake in the model. A chain full of abandoned pools is worse for everyone than a
$50 barrier is for anyone. The premium is the point, and it is stored in a separate map from the
compute precisely so the two can be argued about separately.

| operation | dollars |
|---|---:|
| issue a fungible | $10 |
| issue a semi-fungible collection | $20 |
| issue a non-fungible collection | $25 |
| issue an autostake pool | $40 |
| issue a swap pool | $50 |
| unlock a fee | $50 |
| create a company | $120 |

Against ordinary use:

| operation | |
|---|---:|
| a transmute | $0.05 |
| a burn | $0.72 |
| a mint | $0.87 |

**Everyday actions cost cents. Creating permanent structure costs tens of dollars.** That gradient
is the entire pricing philosophy, and it is legible in the numbers without explanation.

Deterrence is **additive, not multiplicative** — the neutral value is 1, not 0. An operation with
no premium still carries the base unit.

---

## 3. The weights were measured, and the measurement overturned the model

The component weights are not estimates. They were calibrated against measured gas, and three of
four modelled parameters were wrong:

| | modelled | measured |
|---|---|---|
| read costs | 1 / 1 / 2 / 3 | **1 / 2 / 5 / 9** |
| update divisor | halve | **quarter** |
| wipe ceiling | 120 | **1,000** |
| write multipliers | 1 / 2 / 3 / 5 | unchanged |

Only the write multipliers survived contact with data.

One specific result is worth carrying because it is the kind of thing intuition gets wrong:
**wiping a collectable measured 2.3× heavier than wiping an orto-fungible** — 952 against 406 gas
per item. Nothing in the two operations' descriptions suggests a factor of two.

---

## 4. One definition, two callers

The most important property of the model is not a number. It is that **the billing path and the
price preview call the same function**.

Every cost-emitting operation has one cost reader. The execution path calls it to charge. The
interface calls it to quote. They cannot disagree, because there is nothing to disagree *with* —
a quoted price differing from a charged price is not a bug that is tested for, it is a state that
cannot be represented.

There are **314** such cost readers serving **428** previews. Not one-to-one, because a single leaf
is shared by the execution path and several previews.

The placement rule matters too: a cost reader lives **in the module that charges it**, never in a
shared pricing module. Nothing accumulates into a central file that no one module owns.

One exception, forced by deployment order: the identity module deploys before the gas module, so it
cannot construct a bill. Its cost readers live in the gas module instead. The exception is recorded
where it applies rather than generalised into a rule.

---

## 5. Bills carry recipients

A price is not a number — it is a list of legs, each with an amount and **who earns it**. Several
modules contribute to one operation, and the bill records that.

The payer's account tier discounts the whole bill, up to **49%**. Each remaining leg then splits:
**25%** to the smart-account recipient that earned it, the rest to the protocol.

So the model does not just charge for work; it **routes payment to whoever performed the work**.
A pool operator or token issuer earns from the traffic they generate.

And that is why bills are itemised rather than totalled. A single assertion once caught a preview
that had **split one leg into two, with the total unchanged** — every total-level check passed it.
An operation charging the right amount to the wrong recipient is invisible to any test that looks
only at the sum.

---

## 6. Two currencies

| | IGNIS | native |
|---|---|---|
| charged on | nearly everything | **issuance only**, plus named fees |
| maximum discount | 49% | **24.5%** — exactly half |
| default | off | off |

Native charges apply only where something **permanent is created** — a token, a pool, an account, a
branding registration. Ordinary usage is virtual-gas only.

**No native price is hardcoded.** Each derives from a dollar figure divided by the current market
price. There is exactly one exception, and it is recorded as a ruling rather than an oversight: one
registration fee is fixed in native units per character, with an instruction in the source not to
"correct" it.

A rule with one documented exception is more trustworthy than a rule with none, because the
exception proves someone checked.

---

## Where to read next

- `02-why-it-is-expensive.md` — the honest accounting
- `03-heavy-reads.md` — the cost that is not in this model
- `04-the-price-sheet.md` — every price, generated

## Sources

- `1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact` — the four maps and the arithmetic
- `OuronetInformational/IGNIS-PRICING/IGNIS-PRICING.md` — the authoritative model and its history

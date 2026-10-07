# What the complexity buys

The previous two chapters compare Ouronet to specific alternatives. This one answers the question
underneath them: **124,750 lines is a lot. What is it for?**

The answer is a ledger, not an argument. Each row is a cost this documentation has already
established, paired with what it purchases.

---

## 1. The ledger

| cost | buys |
|---|---|
| a preview layer at **22% of a block** — the most expensive module in the system | a quoted price that **cannot** differ from the charge, because both call one function |
| itemised bills instead of totals | revenue routed to whoever earned it, per leg |
| four asset types instead of one | parcels, composition, fractionalisation, traits — as first-class tokens |
| **128 scans** named and fenced off the execution path | unbounded reads that exist, are usable, and cannot enter a transaction |
| a permanent interface discipline — one interface implemented by **58 modules** | a deploy graph that cannot silently break |
| a 162-character account, unreadable to humans | 1,280 bits of identifier, and key authority structurally separated from code authority |
| **its own gas economy** | **users transact holding none of the host chain's currency** |

That last row is the load-bearing one, and everything above it is partly in service of it.

---

## 2. The one that justifies the rest

**409 of 427 client operations are gas-sponsored.** A user with an empty native balance can hold
tokens, stake, swap, and claim.

That is not a convenience feature. It is the difference between a system a newcomer can use and one
where the first instruction is *"acquire the chain's currency from an exchange, then come back."*

But look at what it requires, and the shape of the whole system falls out of it:

- a **price for every operation**, or sponsorship is unbounded
- a **sponsor that can read what a transaction contains**, or it pays for anything
- a **revenue split that funds the sponsor**, or it drains
- a **preview layer**, so a user can see a cost they are not paying in the usual currency
- a **virtual currency with a stable peg**, so those prices mean something

Remove sponsorship and most of this documentation's subject matter becomes optional. Keep it, and
each of those follows necessarily.

**That is the honest answer to "why is it complex":** not feature accretion, but one decision with
a long tail.

---

## 3. What you would give up by choosing something simpler

For a project that needs a token and nothing else, Ouronet is the wrong answer and this
documentation should say so plainly. A standard fungible token on an established chain is simpler,
more liquid, more legible to tooling, and needs no explanation.

The trade becomes favourable at a specific threshold: **when you need several of these at once.**

- tokens whose holders can be frozen *and* whose issuer can prove they cannot be
- positions that lock *and remain composable* — a frozen LP token that still earns
- rewards weighted by holdings in a *different* system
- a price a user can see before signing, that is provably the price they pay
- users who do not hold the host chain's currency

Any one of these is buildable separately. The reason they are expensive separately is that each
needs its own notion of a position, its own accounting, and its own adapter to the others.

**Ouronet's claim is that these compose because they are the same tokens.** A frozen liquidity
position is a token, in a pool, subject to the same transfer rules, earning a score weighted at 2.0
because it cannot be withdrawn. No adapter, no wrapper, no bridge between subsystems.

---

## 4. What it does not buy

An honest ledger needs the empty rows.

**It does not buy correctness.** The naming system and its 26 structural rules make correctness
*checkable*; they do not make it true. `60-methodology/04-what-went-wrong.md` is a catalogue of the
gap, and the most instructive entries are checks that reported success while proving nothing.

**It does not buy freedom from the wrong-entity class.** Every argument well-formed, one of them
naming the wrong thing, the operation succeeding and answering a different question. No structural
rule catches that. Several of this project's real defects were exactly it.

**It does not buy liquidity or ubiquity.** No amount of design quality substitutes for being spoken
by every wallet.

**And it does not buy concentrated liquidity**, or a price oracle, or flash loans, or gradual
parameter ramps. Those are named in `25-defi/02-swap-pools.md` as absent, with the owner's own note
that some are planned "if needed".

---

## 5. The claim actually being made

Not *"this is better than the alternatives"*. The claim is narrower and more defensible:

> **This is what it costs to implement a chain's worth of token and DeFi semantics inside smart
> contracts, on a platform where you cannot change the runtime — and here is the accounting.**

Whether that is worth it depends entirely on whether you need the top of §3. The documentation's
job is to let you decide, which requires publishing the costs as clearly as the capabilities.

That is why this section exists, why `50-economics/02-why-it-is-expensive.md` leads with the most
expensive module being the one that *describes* the system, and why the methodology section ends
with a chapter on failures rather than achievements.

**A system that only publishes its capabilities is asking to be trusted. One that publishes its
costs and its failures can be evaluated.**

---

## Where to read next

- `50-economics/02-why-it-is-expensive.md` — the cost side, in detail
- `60-methodology/04-what-went-wrong.md` — the failures
- `25-defi/02-swap-pools.md` — the named limitations

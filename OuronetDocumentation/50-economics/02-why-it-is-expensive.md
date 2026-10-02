# Why it is expensive

Ouronet costs more to run than a token contract, and the reasons are structural rather than
accidental. This chapter states them without softening, because a reader deciding whether to build
on this needs the real accounting.

---

## 1. It is a chain implemented inside a chain

The central fact: Ouronet defines its **own accounts, own gas, own token types and own DeFi
primitives** — in smart contracts, on a host chain that already has all of those.

Everything follows from that.

A transfer on the host chain adjusts two numbers. A transfer in Ouronet resolves an account,
checks roles, evaluates a fee that may scale with size, applies a per-holder freeze, routes to one
of several balance layouts, assembles an itemised bill with recipients, and charges virtual gas
that must itself be converted and split.

Both are "a transfer". One is an order of magnitude more work, and **that is the feature** — the
second one supports vesting, freezing, roles, progressive fees and revenue sharing. The cost is
what those buy.

---

## 2. The single most expensive thing is describing itself

The largest deploy cost in the system is not a DeFi module. It is the **preview layer** — the
functions that answer *"what will this do and what will it cost?"* before anything is signed.

| module | deploy gas | share of a block |
|---|---:|---:|
| the Stage-1 preview module | **436,250** | **22%** |
| the reward engine | 353,662 | 18% |
| the reward distributor | 252,470 | 13% |

It runs at nearly **double the tree's median gas per line**, and it costs 23% more to deploy than
the module the sizing tool marks as "split before deploying" — on 25% fewer lines.

**A system that can quote its own prices pays for that ability in deploy cost.** Most contracts do
not offer it, which is why most cannot tell you what an operation costs before you send it.

### The sizing bands could not order their own population

A detail worth carrying, because it is a good lesson about proxies. The line-count bands mis-rank
the tree: a "Warning" module deploys for less than two "Acceptable" ones, and gas per line varies
**26×** across the codebase.

> **A threshold on this proxy cannot order the population, so it cannot decide which module to
> split.**

The conclusion was an owner ruling on 2026-09-18 — *"I don't think we need any splitting of
modules"* — supported by the measurement rather than by the bands: nothing exceeds 22% of a block,
and the splits that mattered were already done.

---

## 3. Deploy order is a real constraint

A module may only call modules already deployed. That forces a strict order, and the order has
costs:

**Interfaces are permanent.** A deployed interface can never be changed, so a signature change
means a new version — and by the cascade rule, every interface naming it and every implementor
bumps too. One shared interface is implemented by **58 modules**. A change there is a 58-module
redeploy.

**Some things cannot be where they belong.** The identity module deploys before the gas module, so
its cost readers live in the gas module. That is not untidiness; it is the deploy graph showing
through.

The constraint is **dependency order, not size**. A common misstatement — repeated in this
project's own instructions until recently — was that a ~150k gas cap forced the ordering. Measured,
the largest emitted transaction uses **686,700 of 2,000,000 gas at 316 KB**. There is room; what
there isn't is freedom to call something not yet deployed.

---

## 4. Complexity is visible in the counts

| | |
|---:|---|
| 123,058 | lines of contract |
| 8,849 | functions |
| 988 | capabilities |
| 99 | modules |
| 423 | client entrypoints |

Those are not padding. The four asset types need genuinely different machinery — a true fungible
has 2 wipe operations, an orto-fungible has 5, collectables have 7 — because wiping a balance is
one write and wiping a holder's parcels may be thousands.

And every client operation needs a preview, a cost reader, a capability, and a test. **423
entrypoints is 423 of each.**

---

## 5. What the complexity actually buys

The honest ledger:

| cost | what it buys |
|---|---|
| a preview layer at 22% of a block | a quoted price that cannot differ from the charge |
| itemised bills instead of totals | revenue routed to whoever earned it |
| four asset types instead of two | vesting, fractionalisation, traits, composition |
| a permanent interface discipline | a deploy graph that cannot silently break |
| its own account model | one wallet key controlling many accounts, with separate key and code authority |
| its own gas | **users transact without holding the host chain's currency** |

That last one is the load-bearing answer. Ouronet's gas station sponsors **405 of 423 entrypoints**.
A user with zero native currency can transact. Achieving that requires a virtual gas economy, a
price for every operation, a sponsor that can read what a transaction contains, and a revenue split
that funds it.

You cannot have that cheaply. The question is whether you want it.

---

## 6. Where the cost is *not*

Two things a reader might assume and should not.

**It is not that Pact is slow.** The measured constraints are deploy gas and transaction gas, both
of which the system fits with margin. The places where Pact genuinely costs something are specific
and documented: no dynamic loops, so solvers run fixed iteration counts; no first-class high-
precision exponentiation, so one curve carries a known bounded error.

**And it is not that the tests are heavy.** The full suite is **26,128 assertions in 312 seconds**
across sixteen cores — five minutes for a system this size. Test *coverage* is not where the
expense lives.

The expense is in the surface area, and the surface area is the product.

---

## Sources

- `OuronetInformational/MODULE-SIZING.md` — the measured deploy gas and the owner ruling
- `10-architecture/04-deploy-order.md` — the ordering constraint and the corrected figure
- `10-architecture/08-the-read-layer.md` — why the preview layer is separate
- `60-methodology/03-the-gate.md` — the measured suite figures

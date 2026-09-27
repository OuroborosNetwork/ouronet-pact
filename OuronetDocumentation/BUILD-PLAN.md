# Build plan

What each file in this folder is, what it must contain, and the order to write them in.

This plan implements the owner directive of 2026-08-27 (`OuronetInformational/
DOCUMENTATION-PLAN.md`), which specified a "capture-all" documentation of the entire system and
**deferred it until the final code shape was deployed**. That gate opened 2026-09-27.

---

## 1. The reader

One reader, stated once, because every file depends on it:

> A capable technical person who has never seen Ouronet, is not a Pact programmer, and needs to
> understand what this system is, what it does, how it does it, and why it was built this way.

They are not an auditor (the Audit Book serves that), not a UI developer (the Integration
chapter serves that), and not a casual visitor. They are someone deciding whether this is
serious, or someone about to build on it.

Three consequences:

- **Nothing may assume Pact.** Where a Pact construct matters — `defcap`, modref, `defpact` —
  explain it at first use, once, and link back.
- **Nothing may assume the reader was here.** No "as discussed", no handoff references in the
  body text. Cite sources in a footer, for someone who wants to verify.
- **Depth is not optional.** The directive asks for every module, every function, every shape.
  A summary that omits what a function does is not this document.

## 2. What the directive requires

Seven things. Every one gets a section; none may be dropped for length.

| # | requirement | lives in |
|---|---|---|
| 1 | Purpose and vision — what Ouronet strives to be | `00-orientation/` |
| 2 | Architecture — layers, sovereign vs citizen, module map, deploy order, gas model | `10-architecture/` |
| 3 | Every module, every function, every shape | `30-modules/` |
| 4 | What a client or user can actually achieve | `40-journeys/` |
| 5 | Why it is complex and why it costs — honestly | `50-economics/` |
| 6 | Advantages over industry standards | `70-comparison/` |
| 7 | StoicSyntax, and how it made the code semi-self-auditing | `60-methodology/` |

Item 7 is explicitly a **first-class chapter**, not an appendix. The directive's wording: the
naming *is* part of the design, and it is why the audits were tractable.

---

## 3. The files

### `00-orientation/` — what this is

| file | contains |
|---|---|
| `01-what-ouronet-is.md` | The one-page answer. A virtual blockchain implemented entirely in smart contracts on StoaChain, with its own account model, its own gas, its own asset types and its own DeFi primitives. |
| `02-why-it-exists.md` | The problem it solves and the bet it makes. Why a virtual chain rather than a set of contracts. |
| `03-the-shape-in-one-diagram.md` | Utilities → Core → Talos → Reads, with sovereign and citizen alongside. The mental model everything else refines. |
| `04-how-to-read-this.md` | Reading orders for three arrivals: evaluating, integrating, or going deep. |

### `10-architecture/` — how it is put together

| file | contains |
|---|---|
| `01-the-layer-cake.md` | Utilities, Core, Talos, Z_Reads. What each layer may and may not do. Why Talos is the only client path. |
| `02-sovereign-and-citizen.md` | The two halves, what a citizen module may do, and the owner ruling that citizen modules are free to shape their own functions. |
| `03-the-module-map.md` | All 79 deployed modules by role, with one line each and a link to its page. |
| `04-deploy-order.md` | Why order is forced, what the constraint actually is (dependency, not bytes), and the 24-transaction round. |
| `05-accounts-and-identity.md` | DALOS accounts, smart vs standard, guards, the glyph account format. |
| `06-ignis-and-the-gas-station.md` | Virtual gas, who pays, `GAS_PAYER`, and the patron/executor/executee split. |
| `07-interfaces-and-versioning.md` | Why interfaces are versioned, the cascade rule, and why a deployed interface can never change. |
| `08-the-read-layer.md` | Why reads are split per surface, and what a client should call. |

### `20-assets/` — what can exist

One file per asset type plus a comparison. The directive names seven; confirm against the code
before writing the index, and record the count with its source.

| file | contains |
|---|---|
| `00-the-asset-types.md` | The table that distinguishes them, and the decision tree for which to use. |
| `01-true-fungibles.md` | DPTF. Balances, roles, fees, freezing, wiping, the special-link family. |
| `02-orto-fungibles.md` | DPOF. Nonces, why a parcel is not a balance, the five wipes and why there are five. |
| `03-collectables.md` | DPDC/DPSF/DPNF. Semi vs non-fungible, sets, fragments, equity. |
| `04-liquidity-positions.md` | LP tokens, what holding one means. |
| `05-staked-positions.md` | ATS positions, reward tokens vs reward-bearing tokens — a distinction that has already caused a real defect. |
| `06-vested-and-locked.md` | VST. Frozen, reserved, vesting, sleeping, hibernating, and the link that must exist first. |

### `30-modules/` — the reference

**One file per module, in deploy order.** 79 files. This is the bulk and the part that makes
this documentation rather than a brochure.

Each file follows one template, so a reader who has read two can navigate any of them:

```
# <MODULE> — <one-line role>

## What it is for
## Where it sits            (layer, and what depends on it)
## The data it owns         (every schema and table, with what a row MEANS)
## The capabilities         (every defcap, grouped by band, and what each authorises)
## The functions            (grouped by prefix, each with: what it does, how, why)
## What a client can call   (its Talos entrypoints, with cost)
## Traps                    (anything that has actually bitten someone)
## Sources                  (file path, line counts, and where figures came from)
```

**Do not read 122,969 lines by hand.** `OuronetInformational/MODULE-INDEX.md` is GENERATED from
the tree and already carries, per module: its path, its tables, its function list and a one-line
purpose. Start there, then open the source for the functions that need the "how" and the "why"
— which the index does not have and cannot generate.

The function section is the work. Group by the prefix system (`UC`/`UR`/`URC`/`UEV`/`UDC`/
`CAP`/`A_`/`C_`/`X*`) — the grouping is meaningful and explaining it per module reinforces
`60-methodology/`.

Order: deploy order, because dependency order is the order in which the system makes sense.
Utilities first, then core, then Talos, then reads, then citizen.

### `40-journeys/` — what you can do

| file | contains |
|---|---|
| `01-as-a-holder.md` | Hold, transfer, stake, lock, swap. |
| `02-as-a-token-issuer.md` | Issue, mint, set fees, grant roles, freeze, wipe. Which powers exist and what they cost. |
| `03-as-a-pool-owner.md` | Create a pool, set weights and fees, manage liquidity. |
| `04-as-a-builder.md` | Write a citizen module against Ouronet's token logic. What the sovereign surface guarantees. |
| `05-as-an-integrator.md` | Points at `docs/CHAPTER-INTEGRATION/` rather than restating it. |

### `50-economics/` — why it costs

| file | contains |
|---|---|
| `01-the-cost-model.md` | How a price is assembled. Deterrence plus components. |
| `02-why-it-is-expensive.md` | Honestly: on-chain virtual chain, heavy reads, the transitive-heavy rule, module-size reality. |
| `03-heavy-reads.md` | What makes a read heavy, why it matters, and what was done about it. |
| `04-the-price-sheet.md` | Points at the GENERATED price sheet rather than copying it. |

### `60-methodology/` — how it was built

| file | contains |
|---|---|
| `01-stoicsyntax.md` | The prefix system in full: what each prefix promises, and what it forbids. |
| `02-semi-self-auditing.md` | **The chapter the directive cares about.** How a name that promises "no table reads" turns a whole class of review into a mechanical check, and why the audits were tractable because of it. |
| `03-the-gate.md` | 26,128 assertions, what the gate enforces, and why generated artefacts are diffed rather than trusted. |
| `04-what-went-wrong.md` | The failure classes this project actually hit — resolution errors, short calls, sentinels, stale figures — and the mechanisms built against each. Credibility comes from this chapter, not from claiming none happened. |

### `70-comparison/` — against the industry

| file | contains |
|---|---|
| `01-versus-erc20.md` | What a true fungible has that an ERC-20 does not, and the cost of that. |
| `02-versus-an-amm.md` | SWP against a constant-product pool. |
| `03-what-the-complexity-buys.md` | The honest accounting: what you get, what you pay, and who it is for. |

### `90-reference/` — the checkable parts

| file | contains |
|---|---|
| `01-entrypoint-catalogue.md` | All 423 client entrypoints. Generated, not typed. |
| `02-glossary.md` | Every term, defined once. |
| `03-how-these-figures-were-obtained.md` | The command behind every number in this folder. |
| `04-source-map.md` | Which repo file backs which page. |

---

## 4. Order of writing

1. `00-orientation/` and `10-architecture/` — nothing else can be written well without the
   vocabulary they establish.
2. `60-methodology/01-stoicsyntax.md` — the module pages depend on the prefix system being
   explained once rather than eighty times.
3. `20-assets/` — the nouns.
4. `30-modules/` — the bulk. Deploy order.
5. `40-journeys/`, `50-economics/`, `70-comparison/` — these synthesise and are easiest last.
6. `90-reference/` — generate at the end, when the figures have settled.

## 5. Conventions

**Figures are read, not remembered**, and each page says where its numbers came from. Three
rounds of this project found published figures that had gone stale while every document agreed
with every other one.

**Cite, never copy.** Where a fact is maintained elsewhere — the price sheet, the registry, the
Audit Book — link it. A copy is a second version to keep in step.

**Traps are documented.** Where something has actually caused a defect, say so and say what
happened. A document that reads as though nothing ever went wrong is not trusted by the kind of
reader this is for.

**No file assumes another has been read**, except the four in `00-orientation/`.

## 6. Status

| section | files | written |
|---|---|---|
| `00-orientation` | 4 | 1 |
| `10-architecture` | 8 | 0 |
| `20-assets` | 7 | 0 |
| `30-modules` | 79 | 0 |
| `40-journeys` | 5 | 0 |
| `50-economics` | 4 | 0 |
| `60-methodology` | 4 | 0 |
| `70-comparison` | 3 | 0 |
| `90-reference` | 4 | 1 |
| **total** | **118** | **2** |

Update this table as files land. A plan whose status is stale is worse than no plan.

# Build plan

What each file in this folder is, what it must contain, and the order to write them in.

This plan implements the owner directive of 2026-09-23, which specified a "capture-all"
documentation of the entire system and **deferred it until the final code shape was deployed**.
That gate opened 2026-09-27 with the ATS upgrade.

**REVISED 2026-09-27, against the directive's own words rather than a summary of them.** The first
draft of this plan was derived from `OuronetInformational/DOCUMENTATION-PLAN.md`, a same-day
summary of the commissioning conversation. Reading the transcripts themselves
(`REPL/tools/_transcripts.py`; passages quoted in `90-reference/04-the-owner-directive.md`) found
that the summary had lost two whole requirements and inverted one term:

| | summary said | the owner said |
|---|---|---|
| designation | "a virtual blockchain" | **"the sovereign defi layer of stoa chain, which is its official current designation"** — explicitly superseding the older phrase |
| assets | a flat list of seven | **four types**, then special *variants*, then three *pool families* |
| cryptography | not mentioned | "**a chapter for the cryptography alone is also waranted**" |
| maintainability | not mentioned | "**tied to some sort of skeleton** … i dont want to stay a week everytime something change" |

None of those is a detail. The first was on the front page of the documentation, sourced from
`CLAUDE.md`, which still carries the retired phrase. The lesson is the one this project keeps
relearning: **a derived document is evidence about its source, not a substitute for it.**

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

**Nine** things. Every one gets a section; none may be dropped for length. (The directive as
summarised listed seven. Items 7 and 9 below were in the conversation and not in the summary.)

| # | requirement | lives in |
|---|---|---|
| 1 | Purpose and vision — what Ouronet strives to be | `00-orientation/` |
| 2 | Architecture — layers, sovereign vs citizen, module map, deploy order, gas model | `10-architecture/` |
| 3 | Every module, every function, every shape | `30-modules/` |
| 4 | What a client or user can actually achieve | `40-journeys/` |
| 5 | Why it is complex and why it costs — honestly | `50-economics/` |
| 6 | Advantages over industry standards | `70-comparison/` |
| 7 | **Cryptography** — the custom curve, account derivation, browser Schnorr | `80-cryptography/` |
| 8 | StoicSyntax, and how it made the code semi-self-auditing | `60-methodology/` |
| 9 | **Maintainability** — a skeleton so a code change is not a week of editing | `MAINTAINING.md` |

Items 7 and 8 are explicitly **first-class chapters**, not appendices — both named as "a chapter"
in the owner's own words. For StoicSyntax the reasoning is that the naming *is* part of the
design, and it is why the audits were tractable.

Item 9 is different in kind: it is a requirement about how this folder is **built**, not about
what it says, which is exactly why a section-by-section plan drops it. Its test is concrete —
*when a module changes, how many files must a human edit by hand?* — and the answer has to be
small. See `MAINTAINING.md`.

**The models the owner named**, in order of fit:

| reference | why |
|---|---|
| <https://docs.multiversx.com> | "a documetnation of the whole blcockhain, which in a sense is what Ouroent is somehow" |
| <https://developers.uniswap.org/docs> | "where everything related to the uniswap code sits" |
| <https://demiourgos-holdings-tm.gitbook.io/kadena> | the existing book — superseded, "a lot of stuf is stale" |

---

## 3. The files

### `00-orientation/` — what this is

| file | contains |
|---|---|
| `01-what-ouronet-is.md` | The one-page answer. The Sovereign DeFi Layer of StoaChain: its own account model, its own gas, four asset types and three pool families, all in smart contracts. Carries the note retiring "virtual blockchain". |
| `02-why-it-exists.md` | The problem it solves and the bet it makes. The MultiversX lineage, why a sovereign layer rather than a set of contracts, and citizen modules as the point rather than a bonus. |
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

**The owner's taxonomy, not an invented one:** four asset *types*, then special *variants* of
them, then what a pool position is. An earlier draft of this plan listed seven flat "asset types"
and was wrong — LP tokens and staked positions are not a fifth and sixth type alongside
non-fungibles.

| file | contains |
|---|---|
| `00-the-asset-model.md` | The four types, the discriminator between them, and the decision tree for which to use. The MultiversX taxonomy this extends, and what was added. |
| `01-true-fungibles.md` | DPTF. Balances, roles, fees, freezing, wiping, the special-link family. |
| `02-orto-fungibles.md` | DPOF. Nonces, why a parcel is not a balance, the five wipes and why there are five. Includes the DPMF → DPOF rename and why the old name survives in module names. |
| `03-semi-fungibles.md` | DPSF. Quantity per nonce, and where that differs from an orto-fungible. |
| `04-non-fungibles.md` | DPNF. One per nonce, metadata, and the constraints that follow. |
| `05-sets-and-fragments.md` | DPDC-S sets, DPDC-F fragments (units of 1000), EQUITY. Composition and fractionalisation. |
| `06-the-special-variants.md` | Vested, locked, frozen, reserved, sleeping, hibernating — **states with rules, not separate tokens**. What each is for, and the link that must exist first. |
| `07-pool-positions.md` | What holding an LP token, an ATS position or an AQP position actually means. Reward tokens vs reward-bearing tokens — a distinction that has already caused a live defect. |

### `25-defi/` — how the three pool families work

The directive asks for "descriptions of formulas how it works, what does it do, what are its
limitations". That does not fit a per-module reference page, so it gets its own section. This is
the part a DeFi reader arrives for.

| file | contains |
|---|---|
| `00-the-three-pool-families.md` | Autostake, swap, acquisition. What each is for and how they compose. |
| `01-autostake-pools.md` | ATS. Coiling, brumation, hibernation, curling, constriction — what each does and when it is available. |
| `02-swap-pools.md` | SWP. The swap model and its mathematics, asymmetric liquidity provisioning, slippage, and the breadth-first route search over the pool graph. Limitations, including the absence of concentrated liquidity. |
| `03-acquisition-pools.md` | AQP. Anchors, scores, farms/vaults/treasuries, delegated staking. |
| `04-the-launchpad.md` | DemiPad: the sovereign rules and the citizen sales that use them. |

> **PRIOR ART — read it before writing these.** `websites/ouronetwork-website/OuronetWhitepaper/`
> is a 9,241-word hand-written predecessor, thirteen chapters, June 2026. Its **prose is still
> good** and its organising idea is worth weighing: it documents *entities* — logical subsystems,
> each backed by one or more modules — rather than one file per module. Thirteen chapters instead
> of seventy-nine. Its **figures are 95% stale** (see `MAINTAINING.md` §0), so take the structure
> and the explanations, and regenerate every signature.

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

**Do not read 123,084 lines by hand.** `OuronetInformational/MODULE-INDEX.md` is GENERATED from
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

### `80-cryptography/` — the layer that is not Pact

Named by the owner as warranting a chapter of its own, and scoped by him: the custom curve,
account derivation, and browser-side Schnorr — **explicitly not** the Stoic predicates, which are
a different mechanism and belong in `10-architecture/05-accounts-and-identity.md`.

Source material is the `DALOS-Crypto` repository, not this one. That makes this the one section
whose figures cannot be gate-checked from here; say so on the page.

| file | contains |
|---|---|
| `01-why-custom-cryptography.md` | What the account string has to do that a standard address does not. |
| `02-the-curve-and-derivation.md` | The custom ellipse, how an Ouronet account string and its public key are derived. |
| `03-signing-in-the-browser.md` | Schnorr verification client-side, what is proved where, and the seam between the crypto layer and the contracts. |
| `04-what-is-not-on-chain.md` | The honest boundary: the cryptography is not implemented in Pact, what that means for trust, and what enforcing it on chain would take. |

### `90-reference/` — the checkable parts

| file | contains |
|---|---|
| `01-entrypoint-catalogue.md` | All 423 client entrypoints. Generated, not typed. |
| `02-glossary.md` | Every term, defined once. |
| `03-how-these-figures-were-obtained.md` | The command behind every number in this folder. |
| `04-the-owner-directive.md` | The commissioning directive **verbatim**. Every claim about intent traces here. |
| `05-source-map.md` | Which repo file backs which page. |

---

## 4. Order of writing

1. `00-orientation/` and `10-architecture/` — nothing else can be written well without the
   vocabulary they establish.
2. `60-methodology/01-stoicsyntax.md` — the module pages depend on the prefix system being
   explained once rather than eighty times.
3. `MAINTAINING.md` — **before the bulk, not after.** It decides which figures are generated, and
   retrofitting generation across 79 written pages is the week of work the directive forbids.
4. `20-assets/` — the nouns.
5. `25-defi/` — the verbs. Needs the nouns.
6. `30-modules/` — the bulk. Deploy order.
7. `40-journeys/`, `50-economics/`, `70-comparison/` — these synthesise and are easiest last.
8. `80-cryptography/` — independent of the rest; needs the `DALOS-Crypto` repo open.
9. `90-reference/` — generate at the end, when the figures have settled.

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
| root (`README`, `BUILD-PLAN`, `MAINTAINING`) | 3 | 3 |
| `00-orientation` | 4 | 4 |
| `10-architecture` | 8 | 5 |
| `20-assets` | 8 | 0 |
| `25-defi` | 5 | 0 |
| `30-modules` | 79 | 0 (+1 exemplar) |
| `40-journeys` | 5 | 0 |
| `50-economics` | 4 | 0 |
| `60-methodology` | 4 | 2 |
| `70-comparison` | 3 | 0 |
| `80-cryptography` | 4 | 0 |
| `90-reference` | 5 | 2 |
| **total** | **132** | **17** |

Update this table as files land. A plan whose status is stale is worse than no plan.

## 7. Provenance

The directive is quoted verbatim in `90-reference/04-the-owner-directive.md`. It was recovered
from the session transcripts with `REPL/tools/_transcripts.py` — read that tool's docstring before
using it, in particular **the sidechain trap**: subagent briefs are recorded as user messages and
are indistinguishable from owner prose in every field except `isSidechain`. The first attempt at
the provenance page quoted eleven of the assistant's own agent briefs as though the owner had
written them, each one describing Ouronet with the designation he had just retired.

> **Working on the documentation? Read `OuronetDocumentation/RESUME-HERE.md` first.**

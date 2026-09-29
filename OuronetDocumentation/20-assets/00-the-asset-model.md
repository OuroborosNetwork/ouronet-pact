# The asset model

Ouronet defines **four asset types**. Everything else in this section — sets, fragments, vested
tokens, pool positions — is one of those four in a particular state.

That sentence is doing real work. An earlier draft of this documentation listed seven "asset
types" and was wrong: LP tokens and staked positions are not a fifth and sixth kind of thing
alongside non-fungibles. Getting the taxonomy right first is what keeps the rest of this section
from being a list of unrelated features.

The owner's own statement of it:

> "has its own **4 type of token assets, true / (initial-meta) now-orto / semi / non-fungible**,
> with advanced management possibilities. On top of these, 3 defi-like assets are built:
> **autostake pools, swap pools, and earning pools**. On top of this the tokens exist as
> **special variants** to offer all types of defi primitives — vesting, locking, freezing,
> hibernating, each filling a specific purpose."

Three layers, in that order: **types**, then **pools**, then **variants**.

---

## 1. The four types

| | what one unit is | divisible | carries metadata |
|---|---|---|---|
| **True fungible** (DPTF) | a balance | yes | no |
| **Orto-fungible** (DPOF) | an indivisible **parcel** with its own quantity and metadata | no | yes |
| **Semi-fungible** (DPSF) | a nonce many accounts hold quantities of | by integer count | yes |
| **Non-fungible** (DPNF) | exactly one thing | no | yes |

This is the MultiversX taxonomy, extended. The owner is explicit about the lineage, and it is the
clearest single statement of what Ouronet is trying to be:

> "Think of MultiversX — existed initially as ERD on Ethereum, then they launched the chain,
> migrated ERD to EGLD on their own chain … then they added the token infrastructure, with all the
> 4 token types. **Ouronet token architecture is an extension of that, with even more complex
> management capabilities.** However on top of that we also added the defi primitives."

**"Orto-fungible" was originally "meta-fungible."** The rename separated the active design from
the legacy one, and the old name survives in the archived module. See `02-orto-fungibles.md`.

---

## 2. How the system tells them apart

Not by an enum. By a **two-element list of booleans**:

```pact
(defconst TF [true true])     ;; True Fungible
(defconst OF [true false])    ;; Orto-Fungible
(defconst SF [false true])    ;; Semi-Fungible
(defconst NF [false false])   ;; Non-Fungible
```

Two bits, four types, exhaustively. Every place that must handle all four does a four-way
comparison against these constants and dispatches to the owning module.

The **first** bit selects the layer: Stage-1 fungibles (`DPTF`, `DPOF`) against Stage-2
collectables (`DPSF`, `DPNF`). The **second** bit, for collectables, is the parameter the code
calls `son` — and that parameter is threaded through hundreds of function signatures.

> *(The layer reading of the two bits is consistent with every dispatch site but is not stated in
> any docstring. It is presented here as the pattern the code follows, not as a documented
> contract.)*

### Why `son` is not decoration

The source is emphatic, and the reason is worth understanding because it explains the table
layout:

> "`son` **IS PART OF THE KEY**, not decoration. DPSF and DPNF are separate tables and a given id
> can exist in both, so an owner lookup without `son` is a lookup of a **different token**."

Semi-fungibles and non-fungibles have **mirrored table families** — five pairs of them. The same
identifier can name two unrelated assets, one in each. Dropping the discriminator does not
degrade a lookup; it silently answers about something else.

---

## 3. Four types, three implementations

The taxonomy does not map one-to-one onto modules, and this surprises people:

| type | implemented by |
|---|---|
| True fungible | **one module** — 3,352 lines, 200 functions |
| Orto-fungible | **one module** — 3,479 lines, 197 functions |
| Semi-fungible | ⎫ **one family of 11 modules** — 12,359 lines, 565 functions, |
| Non-fungible | ⎭ separated by `son` rather than by module |

There is **no module named DPSF or DPNF anywhere in the tree.** Both are the *collectables*
family, which handles issuance, roles, transfer, management, metadata, sets, fragments and equity
across two mirrored table sets.

So the two collectable chapters that follow are two views of one implementation, not two parallel
systems. That is the honest shape, and it is why they are shorter than the fungible chapters.

---

## 4. What an identifier looks like

One generator serves every asset type, every pool and every anchor:

```
<TICKER> + "-" + <first 12 characters of the previous block hash>
```

So `OURO-8Nh-JO8JO4F5` is `OURO`, a hyphen, and the twelve characters `8Nh-JO8JO4F5`. It looks
like three segments because the block hash is base64url and may contain hyphens of its own. There
are only ever **two** parts.

That sibling ids share a suffix is meaningful: `OURO-8Nh-JO8JO4F5`, `AURYN-8Nh-JO8JO4F5` and
`WSTOA-8Nh-JO8JO4F5` were issued **in the same block**.

Which points at a known limitation, recorded as an accepted audit finding rather than hidden: the
block hash is **per block, not per transaction**, so two issuances of the same ticker in the same
block produce byte-identical identifiers and the second aborts on the raw insert. It is atomic and
self-healing — resubmit in a later block — and fixing it properly would require a utility module
deployed *before* the core reading a core table, which the deploy order forbids.

### Prefixes carry meaning

A leading `X|` on a ticker marks a derived asset:

| | |
|---|---|
| `V\|` `Z\|` `H\|` | vested, sleeping, hibernating — orto-fungible wrappers |
| `F\|` `R\|` | frozen, reserved — true-fungible wrappers |
| `E\|` | equity |
| `S\|` `W\|` `P\|` | the three swap-pool kinds |

**One collision is worth flagging now**, because it will mislead anyone reading raw identifiers:
`F|OURO-…|AURYN-…|ELITEAURYN-…` is **not** a frozen token. Multi-token pool families use `F|` and
`T|` as plain string concatenations rather than as generated identifiers. Prefix meaning depends
on how many `|` separators follow it.

---

## 5. Which type to use

| if a unit is… | use |
|---|---|
| interchangeable and divisible, with one number per holder | **true fungible** |
| individually identified, indivisible, carrying metadata and its own quantity | **orto-fungible** |
| one design held in integer quantities by many accounts | **semi-fungible** |
| unique, one per holder, with traits | **non-fungible** |

The decision most often got wrong is **orto-fungible versus semi-fungible**, because both carry
metadata and both have a quantity. The distinction:

- An **orto-fungible** parcel has exactly **one holder**, recorded on the parcel itself. Splitting
  a holding means minting a new parcel.
- A **semi-fungible** nonce has **no holder at all** — holdings live in a separate per-account
  supply table, and quantity moves by adjusting two rows.

So: a vesting schedule is orto-fungible (each schedule is a distinct object with one owner), while
a concert ticket tier is semi-fungible (one design, a thousand holders).

---

## 6. What the section covers

| chapter | |
|---|---|
| `01-true-fungibles.md` | balances, roles, fees, freezing, wiping, the special links |
| `02-orto-fungibles.md` | parcels, why five wipe operations exist, the archived predecessor |
| `03-semi-fungibles.md` | quantity per nonce, and where it diverges from orto-fungible |
| `04-non-fungibles.md` | one per nonce, traits, and an identifier that is an abbreviation |
| `05-sets-and-fragments.md` | composition and fractionalisation, and equity |
| `06-the-special-variants.md` | vested, sleeping, hibernating, frozen, reserved |
| `07-pool-positions.md` | what an LP token or a staked position actually is |

---

## Sources

- `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact` — the four discriminator constants
- `1_SOVEREIGN/STAGE_01/1_Utilities/08_U_DALOS.pact` — the identifier generator
- `1_SOVEREIGN/STAGE_01/1_Utilities/11_U_VST.pact` — the prefix family
- `90-reference/04-the-owner-directive.md` — the taxonomy, quoted verbatim

Line and function counts are module-body measurements excluding interface declarations. See
`90-reference/03-how-these-figures-were-obtained.md`.

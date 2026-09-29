# Semi-fungibles

One design, held in integer quantities by many accounts. A concert ticket tier, a game item, a
share class.

Semi-fungibles have **no module of their own**. They are one half of the collectables family —
eleven modules, 12,359 lines — and the other half is non-fungibles. A single boolean, `son`,
selects between two mirrored sets of tables at every step.

This chapter is therefore short by design. The machinery is described in `04-non-fungibles.md` and
`05-sets-and-fragments.md`; what follows is only what makes a semi-fungible *different*.

---

## 1. Where the quantity lives

A collectable nonce carries a global supply. For a semi-fungible, **who holds how much** is a
separate table entirely, keyed `<account>|<token>|<nonce>`.

The nonce row's holder field is set to the sentinel `"|"` and stays there. The schema says so
directly:

> "Only applies to NFT nonces. **SFT nonces can't have a unique holder**, and would store BAR
> instead (unmodifiable for SFTs)."

So a transfer adjusts two rows in the supply table. The nonce itself is untouched — it is a
*design*, not a holding.

---

## 2. Against the orto-fungible

These are the two types people confuse, because both carry metadata and both have a quantity. The
differences are structural:

| | orto-fungible | semi-fungible |
|---|---|---|
| holder | **one**, recorded on the parcel | **many**, in a separate table |
| quantity | `decimal` | **`integer`** |
| token-level decimals | yes, 2–24 | **none — no such field** |
| splitting a holding | **mint a new parcel** | adjust two supply rows |
| requires a flag to split | yes (*segmentation*) | no — it is native |
| roles | 4 | 10 |
| creator distinct from owner | no | **yes** |
| sets and fragments | no | **yes** |

The decisive one is the first. An orto-fungible parcel is an *object with an owner*; a
semi-fungible nonce is a *design with a distribution*. Everything else follows.

The second is nearly as important: semi-fungible quantities are **integers**. There is no decimals
field on the token at all. Three hundred tickets, not 300.000.

---

## 3. Ten roles, and a creator

Collectables carry a richer permission model than either fungible type — ten account-level roles
against four, plus a distinction the fungibles do not have:

**Owner and creator are separate accounts.** Many operations accept either, through a capability
that checks both. That split exists so a collection can be administratively owned by one party and
minted by another without handing over ownership.

One role is semi-fungible-only: **add-quantity**. Non-fungibles cannot have it, because their
quantity is locked at one. That asymmetry is visible in the schemas — the semi-fungible account
role record has four fields, the non-fungible one has three — and in the fact that the
role-toggling operation for it is the only one in its module that does *not* take the `son`
discriminator. It hardcodes the semi-fungible path, because there is no other.

---

## 4. What semi-fungibles get that fungibles do not

**Sets.** A recipe binding several nonces into one composite token, with the constituents held in
escrow. Semi-fungible sets get their set nonce minted at definition time with zero supply, so
making a set adds quantity to something that already exists.

**Fragments.** Fractionalisation into exactly 1,000 pieces per unit, represented as the *negative*
of the original nonce.

**Equity.** An eight-nonce collection representing a tokenised company, using the `E|` prefix.

All three are in `05-sets-and-fragments.md`.

---

## Sources

- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/01_DPDC-UDC.pact` — the shared schemas
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact` — the state module and the mirrored tables
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/05_DPDC-R.pact` — roles

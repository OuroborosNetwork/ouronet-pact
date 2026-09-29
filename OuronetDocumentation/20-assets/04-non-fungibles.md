# Non-fungibles

One per nonce. The type everyone already knows — and the one where Ouronet's constraints are most
visible, because "exactly one" has to be enforced in several places at once.

Non-fungibles share the collectables family with semi-fungibles; see `03-semi-fungibles.md` for
the split. This chapter covers what is specific to them.

---

## 1. Quantity is locked at one, in three places

A non-fungible's supply is `1` and stays `1` — **even after it is burned or wiped**. The schema
says so explicitly.

Two separate checks enforce the amount on creation and on credit:

```pact
(enforce (= amount 1) "For an NFT Collectable the amount must be equal to 1")
(enforce (= amount 1) "Credit amount is must be 1 for NFTs")
```

Both are annotated in the source as **unreachable by construction** — every caller on the
non-fungible path passes the literal `1`. They are kept anyway, as fail-closed backstops.

That is a pattern worth naming, because it recurs throughout this codebase: a check that cannot
currently fire, kept because the thing it guards is a *type invariant* rather than a caller
convention. Deleting it would be safe today and unsafe after the next new caller.

---

## 2. Inactivation, not deletion

Ownership is a field on the nonce row, not a row in a supply table. Setting it to the sentinel
`"|"` **inactivates** the nonce rather than destroying it.

Reviving one is possible, and deliberately narrow:

> "Once an NFT nonce is inactivated, it can only be activated again by the collection owner **if
> its class is 0**."

Class 0 means a native nonce. A set instance — a nonce minted to represent a composed set — cannot
be revived, because doing so would resurrect a claim on constituents that have since been released
from escrow.

---

## 3. The holder field is an abbreviation, and cannot be trusted alone

This is the most instructive detail in the chapter.

The holder stored on a non-fungible nonce is **not the account**. It is an 11-character
abbreviation: the first five characters, an ellipsis, and the last three.

An Ouronet account is 162 characters, and two of those five leading characters are the fixed type
glyph and separator. So the abbreviation distinguishes accounts by **three leading and three
trailing body characters** — out of 160.

Any two accounts sharing those six characters collide. The address space is a 256-glyph alphabet,
so that is not an exotic scenario for an attacker who can generate candidate accounts.

It was found by red-team testing, and the fix is not to widen the abbreviation. It is a **second
check against the supply table**, whose key carries the full 162-character account. Two independent
refusals, with **deliberately different messages**, so which one fired is visible.

Both are pinned by tests: one by an exhaustive suite, one by the ownership attack suite.

The general lesson is worth stating, because the abbreviation is not a mistake — it is a
deliberate storage saving:

> **A truncated identifier is a display convenience. The moment it is used for a decision, it is a
> collision.**

---

## 4. Metadata and traits

Every nonce carries two metadata objects: one for the whole, one for its fragment shape.

Inside each:

| | |
|---|---|
| name, description | strings |
| `meta-data` | **free-form — this is where traits live** |
| `score` | a number |
| `composition` | the constituent list, when this nonce is a set |
| asset type + three URI slots | image, audio, video, document, archive, model, exotic |

Traits are arbitrary key/value pairs, and the acquisition-pool system consumes them directly: an
anchor can be defined as *"holders of any nonce whose trait `rarity` equals `gold`"*, and the
matching is a count over the metadata object.

**One field reads nothing.** The royalty field carries an in-source note that it is a
forward-looking hook for a marketplace that does not exist yet, with **no on-chain consumer** —
unlike its sibling, which is actively read by transfer pricing. Recording that distinction in the
schema is what stops the next reader assuming both are live.

---

## 5. Where the non-fungible constraints bite

Collectables have **seven** wipe operations against the true fungible's two, and the reason is the
same as for orto-fungibles: a holding may be thousands of individual rows rather than one number.

The set machinery also treats the two types differently. A non-fungible set **mints a brand-new
nonce** carrying the list of what went into it, because there is no pre-existing nonce to add
quantity to. Breaking the set reads that stored list to decide what to return — which is why the
list had to be made immutable, and was not always.

---

## Sources

- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/01_DPDC-UDC.pact` — schemas and the quantity invariant
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact` — the amount checks
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact` — the abbreviation and its second check
- `REPL/RedTeam/[RT-D2]_Ownership-Collectables.repl` — the collision attack

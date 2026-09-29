# Orto-fungibles

The type with no equivalent in most token systems, and the one worth understanding properly.

An orto-fungible holding is not a balance. It is a **parcel**: an indivisible object with its own
identity, its own quantity, its own metadata, and exactly one holder. The source says it in one
line:

> "Nonces can't be separated. An orto-fungible nonce has one unique holder."

One module, **3,479 lines, 197 functions, 39 capabilities** — slightly larger than the true
fungible module, for a type that most systems do not have at all.

---

## 1. A parcel is not a balance

There is **no per-account balance table**. The authoritative record of who holds what is the
parcel row itself:

```
holder:string              ;; one account — mutable
value:integer              ;; the parcel's own number — immutable
supply:decimal             ;; how much is inside it — mutable
meta-data-chain:[object]   ;; immutable
```

The per-account table that does exist holds only a running total, as a convenience.

Three consequences follow, and they explain the entire operation set:

**Transfer moves whole parcels.** No arithmetic on two balances — the `holder` field is rewritten.

**Moving part of a holding mints a new parcel.** There is a separate operation for it, it requires
the token to have *segmentation* enabled, and it carries the metadata forward onto the new parcels.
You cannot send half a parcel; you can create a new one and send that.

**Spent parcels are decommissioned, not deleted.** A wiped parcel is set to supply `-1.0` so that
any later debit fails validation, and a separate counter tracks how many have been excluded.

That last decision is what makes the parcel model workable. Deleting rows would make identifiers
reusable; a negative sentinel makes a dead parcel permanently, provably dead.

---

## 2. Why this type exists

A vesting schedule is the canonical case. It has:

- an amount
- a release timetable
- one owner
- no meaningful notion of "half of it"

As a balance, that is three tokens and a side table. As a parcel, it is one object whose metadata
chain *is* the schedule — and claiming matured tranches becomes: burn the parcel, pay out what has
matured, **mint a fresh parcel holding the remainder**.

Every special variant in `06-the-special-variants.md` is built this way.

---

## 3. Roles, and the one that is singular

Four grantable roles plus a freeze list, mirroring the true fungible — with one structural
difference:

| | |
|---|---|
| add-quantity | multiple holders |
| burn | multiple holders |
| transfer | multiple holders |
| **create** | **exactly one account** |

The create role is a single string, not a list. So it cannot be toggled — it is **moved**. There
is a dedicated operation for handing it over, gated by its own flag on the token.

A role that only one account can hold needs different machinery from one that many can, and the
schema says which it is rather than leaving it as a convention.

---

## 4. Five ways to wipe, and why

The true fungible module has two wipe operations. This one has five. They are not redundant —
three independent axes are being crossed:

| axis | |
|---|---|
| **granularity** | one parcel · a named subset · everything |
| **who pays for the read** | the contract scans, or the client supplies a pre-read list |
| **fits in one transaction** | or must be sharded across several |

The five:

| operation | takes | for |
|---|---|---|
| partial wipe | one parcel and an amount | reducing a single parcel |
| heavy wipe | just the account | convenience — scans on-chain, small holdings only |
| pure wipe | a pre-read list | **the primitive** — three of the others end here |
| clean wipe | explicit parcel numbers | a named subset |
| slice wipe | one slice of a plan | large holdings, executed in parallel |

The interesting one is the last. Slices are **disjoint and order-independent**, so they can be
submitted simultaneously — and replaying one is safe, because the parcels it targets are already
at `-1.0` and the transaction reverts.

**The slice ceiling is 1,000 parcels, and it was measured rather than guessed:**

> measured 405.6 gas per parcel wiped ⇒ roughly 4,907 fit a 2,000,000-gas transaction

The limit is set at a fifth of that, because the measurement used parcels with no metadata and no
URIs — the cheapest possible case. A calibration that states its own optimism is a calibration you
can trust.

---

## 5. The predecessor, and how it was retired

This module was originally **MetaFungible** (`DPMF`). The rename to *orto*-fungible separated the
live design from the legacy one.

On 2026-09-21 the old module was put into **archive mode** — the project's canonical way of
retiring a contract, and worth describing because Pact makes deletion impossible.

**A deployed module cannot be removed.** So archiving means: keep every schema, every table and
every **read** function, so whatever history those tables hold stays readable; delete everything
that **changes** anything.

Measured: **2,416 lines → 902**. Every writer gone, every reader kept, all five tables intact.

Two consequences are more interesting than the deletion:

**Dropping `implements` removes a module from every future cascade.** The retired module
implemented the shared branding interface alongside four others, so every branding signature
change had to be carried into a contract nobody called. That cascade is now four modules instead
of five.

**Its interface was bumped, not edited** — 95 functions to 53 — because a deployed interface can
never be changed. The old one stays deployed and unimplemented, which costs nothing.

And a caveat the project records rather than papers over: **whether the live module still holds
rows is unknown.** Its source calls `create-table` zero times — but that is exactly what an
*upgrade* source looks like, since creating an existing table fails. Reading the source cannot
settle it; only asking the chain can.

> *(Two counts of the removal are in circulation — 105 and 108 definitions. The measured figure is
> **105**: 79 functions and 26 capabilities from the module body. The project instructions say 108
> and the basis for that figure was not found.)*

---

## Sources

- `1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact` — the module
- `1_SOVEREIGN/STAGE_01/2_Core/00_DPMF.pact` — the archived predecessor
- `OuronetInformational/StoicSyntax-Prefixes.md` §7.21 — the archive-mode specification
- `REPL/Kursan/DPOF-scale-wipe.repl` — the gas measurement behind the slice ceiling

# What the sweep found

Three live defects, two wrong published prices, one module that no instrument was looking at, and
an authorisation surface that had to be measured twice before it told the truth. None of these was
the object of the exercise. Every one of them was found by asking the same question at an
entrypoint nobody suspected: *which account does this prove, and is it the one the signature
names?*

---

## Defect 1 — a revoke that checked no account at all

**`ANK|C>REVOKE-BOOST-CLASS`.** The capability validated exactly two things: that the BoostClass
was **empty**, and that it was **active**. It checked **no account**. Any account reachable
through Talos could revoke any empty BoostClass that was not theirs.

What makes this one instructive is the shape of the mistake. A boost class **owner** field had
been added earlier in the audit programme, as the fix for a different hole — attaching an anchor
to somebody else's class. That fix landed on the **attach** path and enforced `class-owner`
there. The **revoke** path was never carried over. So the module had the field, had the
enforcement, and had a door that used neither.

> A partially-applied fix is the most convincing kind of absence: the field exists, the
> enforcement exists, and the grep that would find the gap succeeds.

The repair enforces both halves — that the executor *is* the recorded owner, and that the
transaction is *signed* for that account:

```pact
(defun UEV_ExecutorIzClassOwner (executor:string boost-class-id:string)
    (let ((co:string (at "class-owner" (UR_BC|Data boost-class-id))))
        (enforce (= executor co) "… is not the BoostClass's owner …")
        (ref-DALOS::CAP_EnforceAccountOwnership co)))
```

Both are needed. The equality alone would let anyone *name* the owner; the signature alone would
prove the caller owns *some* account, not this class.

---

## Defect 2 — an admin keyset says MAY, never WHO

**Four `00_Demipad` admin operations** — register an asset to the launchpad, define its price,
toggle it open for business, toggle retrieval — ran under a `GOV|*_ADMIN` keyset and took **no
account argument at all**. So the events they emitted named nobody, and the audit trail for a
launchpad price change was the keyset that permitted it rather than the administrator who made it.

This is the general failure the canon exists to catch, and it hides behind a true statement:
*"only an admin can call this."* True, and irrelevant to the question being asked. **Authority and
attribution are two different gates.** A keyset held by several people answers *may they*; it
cannot answer *which one*.

It was confirmed by measurement rather than by reading. With the new guard disabled,
`A_DefinePrice` **succeeded**, returning:

```
"Asset TSFS-… price succesfully updated with the Price Object {"pid": 1.0}"
```

An administrator could change a launchpad price and have the event name somebody else. All four
now take `patron` and `executor` and run `CAP_EnforceAccountOwnership` on the executor **before**
the admin capability — authorisation first, then attribution, in that order.

The regression test for this one has an unusual shape worth recording: it is a **`rollback-tx`**,
not a `commit-tx`, because the subject **mutates when the guard is absent**. A test that proves a
guard is missing by successfully performing the forbidden act has to leave no trace, or the next
assertion is reading a state the suite created by attacking itself.

---

## Defect 3 — dead code that published a wrong price

`DPDC-T::C_RepurposeCollectable` and `DPDC-F::C_RepurposeCollectableFragments` each opened with a
`let` binding an entire duplicated cost model — owner, the small and medium price legs, the sum of
amounts, the computed price, the trigger — and then **read none of it**. Dead bindings, of the
kind the sweep learned to expect: the derived actor is so obviously the subject of the operation
that somebody bound it by reflex, and the signature had nowhere to put it.

This one was not merely dead. The IGNIS price sheet derives a function's price by reading the
tier legs its body **mentions**, and the dead block mentioned **both** tiers where the live code
charges one — `(if son s m)` picks exactly one of them. So the published price sheet quoted a
floor of **5** for an operation whose real floor is **2** for a semi-fungible and **3** for a
non-fungible. Deleting the dead block corrected the published figure.

> Dead code is usually harmless because nothing reads it. **A generator reads everything.**

---

## Two prices that rested on a word

The same generator produced two more corrections, and together they make a rule.

**A comment classified a price.** The sheet's `SCALES` test — does this operation's cost grow with
the size of its input? — matched the literal phrase `per-nonce`, and it runs over text that
**includes `@doc` prose**. `C_RepurposeCollectable`'s doc says *"per-nonce"*;
`C_RepurposeCollectableFragments`'s says *"per-fragment"*. Identical price shape, different
classification, decided by a hyphenated word in a sentence. Replaced with structural patterns that
match the **form** that actually scales — `(dec (length …))`, a `fold (+) 0.0`, a multiplication
by a counted quantity. The published tally moved from *185 exact · 135 floor* to
*183 · 137*: two operations that had been quoted an exact price they could not honour.

**And documenting a function raised its price.** The deterrence worksheet counts a function's cost
legs — inserts, updates, reads, scans, cross-module hops — from its source text, transitively. It
counted them in `;;` comments and inside `@doc` strings too. Measured the day it was found: **24
`ref-X::` tokens inside `@doc` strings and 25 inside `;;` comments**, forty-nine phantom
cross-module hops, plus phantom reads and scans, inflating the design figures for **29 published
rows**. The trigger was as ordinary as it gets: eight functions gained an `@doc` explaining how
their executor is proven, and the act of explaining it made them more expensive.

Both corrections are the same rule, and it is now written into the generator beside the fix:

> **A cost leg must be read from a FORM, and a form only exists in code.**

With one deliberate exception, kept visible in the same comment: the price *classifier* still
reads prose on purpose, because `per-nonce` in a doc string is evidence about the **shape** of a
price rather than a **leg** of it.

---

## The module nobody was looking at

On the last day, with the sweep reported complete and every instrument green, a routine
cross-check compared `_executorenforced.py --swept` against the same tool run over the whole tree.

```
--swept:      756 proven, 0 UNPROVEN
whole tree:   758 proven, 8 UNPROVEN
```

The eight were all in one module, `20_MTX-SWP`. The cause was one character. `--swept` derives its
module list from the worklist's ticked rows — deliberately, because a hardcoded list had already
gone stale twice in this programme — and the pattern it used required the row's index column to be
a **number**. One ticked row carries an em-dash there instead, because that module had no turn of
its own: its signatures were carried in by *other* modules' turns. So the derivation dropped it,
`--swept` judged **45** modules while the worklist plainly said **46**, and reported a confident
`0 UNPROVEN`.

All eight were the defpact-step shape, and all eight turned out to be genuinely proven — every
route bottoms out in a **debit of the executor's own tokens**, which is the strongest form this
proof takes, since a caller naming an account it does not own cannot pay. So the finding is not
that eight entrypoints were unguarded. The finding is that **for two days, a tool reported a
verified zero over a set that silently excluded a module.**

Three things came out of it:

1. The eight routes are now registered and named in each function's own `@doc`.
2. The tick parser accepts any index token. *A tick is the definition of swept; what sits in the
   column beside it is decoration.*
3. **The check is now in the gate, over the whole tree.** The sweep is complete and the tree is
   clean at **766 proven, 0 UNPROVEN**, so there is no longer a reason to gate on a subset — and
   a gate over everything cannot be narrowed by a list going stale.

This is the fifth time in this programme that a tool's correctness depended on a list that changes
as the work proceeds. The first four were fixed by **deriving** the list. This one *was* derived,
and the derivation had the hole — which is the next lesson in the sequence rather than a
repetition of the last one.

---

## The authorisation surface, measured

`ARCHITECTURE/AUTH-SURFACE.md` records, for every sovereign client entrypoint, the set of accounts
whose ownership is enforced **anywhere in its capability chain**. The gate requires that set to
only ever **grow**. It is the instrument that turns "we did not weaken anything" from a claim into
a check.

Reading its headline across the round is a lesson in its own right, because the headline goes the
**wrong way**:

| | at the start | at the end |
|---|---:|---:|
| entrypoints scanned | 1,104 | 1,193 |
| reaching at least one ownership enforce | 813 | 856 |
| reaching **none** | 291 | **337** |

Forty-six *more* entrypoints reach no ownership enforce at the end of a round whose entire purpose
was to reduce that number. Taken at face value the round made things worse. It did not, and the
only way to know that is to diff the surface **entrypoint by entrypoint** rather than compare its
totals:

| | count |
|---|---:|
| entrypoints present in **both** measurements | 1,075 |
| of those, **gained** an ownership gate | **60** |
| of those, **lost** one | **0** |
| of those, changed their enforced set at all | 110 |
| appeared during the window | 118 — of which **116** are one admin pair added to 58 modules |
| disappeared during the window | 29 — 21 archived, 6 re-prefixed to protected, 2 renamed |

`813 − 18 + 1 + 60 − 0 = 856`, which is the whole of the movement accounted for. The 116 newcomers
are `P|A_SetIMP` / `P|A_RemoveIMP`, the inter-module policy recovery hatch, added to every module
by a separate piece of work inside the same three days. They are `GOV|*_ADMIN`-gated and `P|`
policy functions, exempt from the canon by rule, and they enforce no *account* ownership **by
construction**. They are the entire reason the "reaching none" column rose.

> **A total is a summary of two populations, and a summary cannot tell you that one of them
> changed.** The number that matters is `60 gained, 0 lost` — and it is only visible per
> entrypoint.

The sixty are worth naming by family, because they are the round's actual security product:
thirteen DALOS admin operations and their Talos wrappers; five SWP pool-parameter admins; five
PYTHIA and two CODEX operations; the four DEMIPAD launchpad admins from Defect 2; the ANK revoke
from Defect 1; two launchpad price setters in citizen modules; and the FVT multiplet family
issuer. Almost all of them gained the same pair — `account:string`, `executor` — which is what an
admin operation looks like once it has to say **who**.

---

## What an auditor has to re-verify

Because the client surface is positional, this round **moved every adversarial call site in the
previous edition's attack register**. Against the pre-sweep baseline, **694 entrypoint signatures
changed across 58 files**.

The consequence is sharper than it sounds:

> An attack that still passes without being re-pointed is passing on an **arity error** rather
> than on the guard it names.

A short modref call partially applies into a closure, so the `expect-failure` around it fails as
expected — green — for entirely the wrong reason. This happened **six times** during the round,
twice inside `expect-failure`s that had looked green for weeks. It is why `Audit/AUDIT-V2-DELTA.md`
carries a per-module entry written *at the time the module was swept*, naming which assertions are
invalidated, which findings are re-framed, and which new gates need an adversarial test that did
not exist before. That judgement cannot be derived from a diff, and writing it afterwards from
memory across 46 modules is how an audit becomes fiction.

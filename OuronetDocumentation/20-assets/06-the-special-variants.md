# The special variants

Vested, sleeping, hibernating, frozen, reserved. The owner describes them as *"special variants to
offer all types of defi primitives, each filling a specific purpose."*

The single fact that makes them comprehensible:

> **A special variant is not a flag on your balance. It is a different token, which you hold
> instead.**

The original is taken into escrow by the protocol's vesting account, and a prefixed wrapper token
is minted to you one-for-one. "Your tokens are vested" means *you no longer hold those tokens; you
hold `V|`-prefixed parcels that can be exchanged back under rules.*

---

## 1. The five, at a glance

| state | prefix | form | exit |
|---|---|---|---|
| **Vested** | `V\|` | orto-fungible | claim matured tranches over time |
| **Sleeping** | `Z\|` | orto-fungible | all-or-nothing at the cliff |
| **Hibernating** | `H\|` | orto-fungible | any time, with a decaying penalty |
| **Frozen** | `F\|` | true fungible | **no exit** |
| **Reserved** | `R\|` | true fungible | owner only |

Vesting, sleeping and hibernating are orto-fungible because each holding is a distinct object with
its own timetable — exactly what the parcel model is for. Frozen and reserved are true fungibles
because they carry no schedule.

---

## 2. The link must exist first

Before anyone can vest a token, its owner must **create the vesting link**. That single act issues
an entire new token: owned by the protocol, inheriting the parent's decimal precision, with
upgrade and ownership-transfer permanently disabled.

Three properties:

**Only the parent token's owner may create one**, and must name themselves as executor.

**It is bidirectional.** The parent points at the wrapper, the wrapper points back.

**It is immutable.** Once created, never changed or removed.

So a token's capabilities are set by its owner in advance. A holder cannot decide to vest a token
whose owner never enabled vesting.

**Not every variant is available to every token.** Linking refuses on the parent's own prefix, and
the table is asymmetric in a way that has real consequences:

| link | refused on |
|---|---|
| Frozen | already frozen or reserved — **LP tokens allowed** |
| Sleeping | already frozen or reserved — **LP tokens allowed** |
| Reserved, Vesting, Hibernation | frozen, reserved, **and all three LP kinds** |

That asymmetry is why **frozen and sleeping liquidity positions exist and vested ones do not** —
see `07-pool-positions.md`.

---

## 3. Transfer restriction, and the one exception

Four of the five wrappers are **transfer-restricted**: only the protocol account can move them
unless the owner grants a transfer role.

**Hibernating tokens are freely transferable.** The source comment is exact:

> "Vested tokens and sleeping tokens are transfer restricted, **hibernated tokens are not**."

That makes hibernation the only variant that is a *tradeable* claim. A hibernating token is a bond
with a decaying exit penalty, and bonds need a secondary market — the other four are locks, and a
tradeable lock is not a lock.

---

## 4. Each state

### Vested

The owner vests tokens *to* someone — it is a distribution primitive, not something a holder does
to themselves. The parcel's metadata is a chain of `{amount, release-date}` entries, up to **250
milestones** over at most **25 years**.

Claiming culls only matured entries, burns the parcel, pays out what matured, and **mints a fresh
parcel holding the remainder**. That mint-on-claim is why vesting is orto-fungible.

### Sleeping

Vesting with one milestone and no offset — a cliff rather than a stream. Same 25-year ceiling.

Two differences: **anyone may put their own tokens to sleep** (no owner permission), and the exit
is **all or nothing** — the claim must equal the whole parcel.

### Hibernating

A time-locked bond, **1 day to 100 years**, with an exit penalty that decays linearly:

> "Hibernated tokens have an **80% peak awakening fee**, that goes down to zero as time elapses
> towards its release date. This fee is **discarded (burning it)**, with no way of collecting it."

Waking immediately costs 80% of the holding. Waking at the release date costs nothing. In between
it is linear.

**The fee is burned, not collected.** Nobody earns it. That matters: a penalty paid *to* someone
creates an incentive to design for early exits. A burned penalty is pure commitment device, and
accrues to every remaining holder through supply reduction.

### Frozen

The strongest lock: the original goes to escrow, the `F|` token is minted, and it is sent to an
**arbitrary third account** — not necessarily the person who froze it.

**There is no unfreeze operation.** The only exits are an ownership reassignment or consuming the
frozen token as liquidity in a swap pool. Freezing is one-way by design.

### Reserved

The asymmetric one. **Anyone may reserve** — while the token's reservation switch is open, and
from a standard account. **Only the token owner may unreserve**, and must do so through a smart
account.

So reserving is an opt-in commitment by a holder that only the issuer can release. It is the
primitive for deposits and subscriptions, where a holder pledges and the issuer decides when the
pledge is discharged.

---

## 5. Two defects this design caused

Both come from the same root, and both are instructive.

**Two prefixes, one family.** Sleeping and hibernating are both orto-fungible wrappers, handled by
shared code. A function testing only for `Z|` sent every hibernating token down the true-fungible
branch, which died looking up an `H|` identifier in the true-fungible table.

**Metadata shape is chosen by a tag, and nothing checked the token.** Sleeping parcels carry
`{amount, release-date}`; hibernating parcels carry `{mint-time, release-date}`. The merge
operations picked the shape from a tag argument, and neither capability verified what the token
actually *was*. Pointing the hibernation merge at a sleeping token stamped the wrong metadata on
it — and the unsleep operation then died on a **runtime type check before any guard could run**,
leaving the parcel:

> "permanently un-unsleepable while still in circulation"

The fix adds prefix checks to both merges. It was deliberately **not** added to the two repurpose
capabilities, because those are *"the ONLY remaining exit for a nonce that was already minted
wrong."*

That restraint is the interesting part. The obvious fix — validate everywhere — would have sealed
the only door out for the parcels the bug had already created.

---

## 6. A name collision worth carrying

Three different things in this system are called freezing or hibernating:

| | |
|---|---|
| **account freeze** | an administrative flag on one holder's balance |
| **frozen token** (`F\|`) | the variant in this chapter |
| **pool hibernation** | a *mode* on an autostake pool — see `07-pool-positions.md` |

And two distinct fees both peak at 800 per mille: the hibernating token's **exit** fee, which
decays as the release date approaches, and the pool's **entry** fee, which decays with the length
of the commitment. They run in opposite directions and are easy to conflate.

---

## Sources

- `1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact` — every transition
- `1_SOVEREIGN/STAGE_01/1_Utilities/11_U_VST.pact` — the prefix family and the vesting arithmetic
- `1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact`, `06_DPOF.pact` — the link fields
- `REPL/modules/VST.repl` — the tests pinning both defects

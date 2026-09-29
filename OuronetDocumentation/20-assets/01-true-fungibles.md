# True fungibles

The ordinary kind of token: a number per holder, divisible, interchangeable. Ouronet calls it
**DPTF**, and it is the busiest asset in the system — OURO, IGNIS, every LP token and every
autostake receipt is one.

One module, **3,352 lines, 200 functions, 40 capabilities**. What follows is what those 200
functions are *for*, because a token that is only a balance does not need two hundred.

---

## 1. The balance, and two exceptions

A holding is a row keyed `<token-id>|<account>`, carrying the amount plus five per-holder flags:

```
balance:decimal
frozen:bool
role-burn:bool  role-mint:bool  role-fee-exemption:bool  role-transfer:bool
```

The flags live **beside** the balance rather than in a separate permissions table, so every
transfer already has them in hand.

**Two tokens do not use this table.** OURO and IGNIS balances live directly on the account row in
the identity module. They are read and written through a different path, and code that freezes an
account has to branch on it. The reason is bootstrapping: the gas token has to be spendable before
the token module is fully wired.

That exception is exactly the kind of detail that makes a system hard to reason about, and it is
worth knowing it exists rather than discovering it.

---

## 2. Four roles and a freeze list

The role table holds five lists of accounts. Only four are roles:

| | grants |
|---|---|
| `r-mint` | create supply |
| `r-burn` | destroy supply |
| `r-transfer` | move the token when transfer is restricted |
| `r-fee-exemption` | pay no transfer fee |
| `a-frozen` | *not a role* — the roster of frozen accounts |

A role is a **dual write**: the account is appended to the token-level list *and* a boolean is
flipped on that account's balance row. Two representations of one fact, which is a deliberate
trade — the list answers "who has this?" and the flag answers "does this holder have it?" without
scanning.

**Granting is gated; revoking is not.** The chain of checks on a grant:

1. the recipient must not be a smart account
2. the token owner must sign
3. the state must actually be changing
4. the token's `can-add-special-role` flag must be **on**

That fourth check applies only when granting. An owner who has switched off role-granting can
still take a role away — which is the correct asymmetry, since the alternative traps a mistake
permanently.

**Two prefixed token families are exempt** from the first and third checks: frozen and reserved
wrappers may hold transfer roles on core smart accounts, because that is precisely how they work.

---

## 3. Fees, and a tax that scales with size

A token carries a fee block: a toggle, a minimum transfer amount, a rate, a destination, a lock
flag, and two running volume counters.

The rate is **per mille with four decimal places**, capped at 999 — a maximum of 99.9%. Two
sentinel values (`-1.0` and `0.0`) mean "no fee".

### The volumetric tax

Ouronet also implements a fee that **grows with the size of the transfer**, and not linearly. The
amount is decomposed into its decimal digits, and each digit position contributes a rate derived
from a repunit logarithm at that position.

The practical effect: moving 10 costs proportionally less than moving 10,000,000. It is a
progressive transaction tax, computed on-chain, with no brackets to maintain — the arithmetic *is*
the schedule.

**The fee lock is the expensive one.** Unlocking a fee costs a flat $50 in virtual gas *and* $50
in native currency — one of the most expensive operations in the system. The lock duration is
**10,000 on mainnet and 1 in the test namespace**, which is the sort of constant that must be
checked rather than assumed when reading test output.

---

## 4. Freezing, and why the name collides

Two entirely different things are called freezing, and conflating them is easy:

| | |
|---|---|
| **account freeze** | a flag on one holder's balance row — that account cannot move this token |
| **frozen token** (`F\|`) | a *separate token* you hold instead, covered in `06-the-special-variants.md` |

The first is an administrative action against a holder. The second is a voluntary state transition
that mints a different asset. They share a word and nothing else.

Account freezing requires the token's `can-freeze` flag, and — for the two core tokens — routes to
the identity module instead of the balance table.

---

## 5. Wiping

Two operations: **partial** (a stated amount) and **total**. Both require the token's `can-wipe`
flag.

Two is worth noting because the orto-fungible module has **five** and the collectables family has
**seven**. The difference is not inconsistency — it is that a balance is a single number, so there
is nothing to page through. Wiping a fungible holding is one write. Wiping a holder's parcels may
be thousands.

That contrast is the cleanest illustration in the system of why the four types need different
machinery rather than one generic one.

---

## 6. The special links

Five fields on a true fungible point at its derived forms:

```
vesting-link  sleeping-link  hibernation-link      → orto-fungible wrappers
frozen-link   reservation-link                     → true-fungible wrappers
```

Unset is the sentinel `"|"`, **never an empty string**. Code that tests for emptiness rather than
the sentinel gets the wrong answer — a recurring theme in this codebase, and the cause of at least
two live defects covered in `06-the-special-variants.md`.

Three properties matter:

**The link is bidirectional.** Reading the vesting link on a plain token gives its vested wrapper;
reading it on the wrapper gives the parent. One write updates both sides.

**The link is immutable.** Once created it can never be changed or removed:

> "Special True Fungible Links (Frozen or Reserved) are **immutable**!"

**Creating one is the token owner's privilege alone**, and it issues an entire new token — owned
by the protocol's vesting account, inheriting the parent's decimal precision, with upgrade and
ownership-transfer permanently disabled.

---

## 7. What this buys

A true fungible in most systems is a balance and an allowance. Here it is a balance, four
grantable roles, a per-holder freeze, a two-part fee system including a progressive tax, two wipe
modes, and five permanent links to derived asset forms.

That is the "advanced management possibilities" the owner's description refers to, made concrete.
Whether it is worth the complexity is the question `50-economics/` and `70-comparison/` take up
directly — this chapter's job is only to say what is there.

---

## Sources

- `1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact` — the module
- `1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact` — the balance schema and the two core-token exceptions
- `1_SOVEREIGN/STAGE_01/1_Utilities/10_U_DPTF.pact` — the volumetric tax arithmetic
- `1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact` — link creation

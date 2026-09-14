# `@doc` claims nothing tests — the other half of the ORBR|A_Fuel lesson

**Date:** 2026-09-11 · **Status:** tool `REPL/_docclaims.py`; one claim now pinned

## Why

TS01-A's `ORBR|A_Fuel` carried *"As Stand-Alone Function, can only be used by the Admin"* and
enforced nothing — `(with-capability (SECURE) …)` where that module's `SECURE` is
`(defcap SECURE () true)`. Any signer could fire it. It was found **by hand**, probing Talos admin
entrypoints with a non-admin key during an unrelated sweep. `_conformance.py`'s `admin-gate-terminal`
rule now catches that **structure**. `_docclaims.py` catches the other half: **the claim**.

A `@doc` saying "only the owner can" is a specification. Unlike a comment it reads as authoritative,
survives every refactor untouched, and nothing checks it. When the code drifts the doc becomes a
confident lie — and reviewers trust it *because* it sounds definite.

Tiers: **AUTHORITY** (who may do this — a false one is a security claim), **BOUND** (numeric
limits), **INVARIANT** (always/never/must).

## Result

**7 AUTHORITY claims exist. Exactly one had a negative test** — `ORBR|A_Fuel`, and only because its
claim turned out to be *false* and was fixed. The other six were unverified.

The most security-relevant, `ORBR|C_WithdrawFees` (*"Only the Token Owner can withdraw these
fees"*), was checked and is **structurally TRUE**: `OUROBOROS|C>WITHDRAW` composes `DPTF::CAP_Owner`.
**No bug** — but nothing watched it, and deleting `CAP_Owner` would have broken no test. Now pinned
by `Kursan/_verify_finding_ORBR-FEE_01_withdraw_ownership.repl`.

## Three fee-system facts, each found by running it

These are why a naive version of that test reads zero and looks like a broken fee system:

1. **The token owner is fee-EXEMPT on its own token**, so the owner's transfers accrue nothing.
   Exemption applies to **either party** — the receiver must not be the owner either.
2. **Fee routing depends on the token's kind.** A reward (RT) or reward-bearing (RBT) token's fee is
   partly *stilled* and partly **BURNED** — total supply drops and the fee target gets **nothing**.
   Only a **plain** DPTF credits the target. Of `[6.2]`'s twelve fee-bearing tokens only **OS** and
   **IR** are plain; every other choice silently yields zero. I lost several attempts to this by
   picking `LI`, which is an RBT.
3. **The ownership gate sits BEHIND an amount check.** On a token with no accrued fees a non-owner
   gets *"There are no `<id>` fees to be withdrawn"* and never reaches the authority error — so the
   fixture must accrue a real fee before the claim is testable at all.

## Placement note

It needed its own gate entrypoint. `modules/DPTF.repl` was the natural home and could not host it:
its mock tokens start fee-less, and by the end of that file EMMA is frozen for MOCKA and the spare
accounts have no compatible DPTF account. Only the `[6.2]_DPTF` chain produces a token with accrued
fees. (Contrast `EL-6`, which I *moved* into `modules/AQP.repl` precisely to avoid a redundant
entrypoint — the rule is "go where the fixture is", and here the fixture is `[6.2]`.)

## CORRECTION — "7 claims, closed" was wrong; the REGEX was too narrow

I reported the AUTHORITY tier closed at 7/7. It was 7 because my own pattern only matched
*"can only be **used / called / invoked**"*. `STOAICO::A_Stake` says *"Can only be **DONE** by the
Admin"* — **one unlisted verb was hiding unverified admin claims on functions that move real
contribution balances.** Widening the verb list (done/executed/performed/run/fired, plus
"only by the admin") took the tier from 7 claims to **15**.

The tool now says so in its own docstring: *prefer a false positive to a miss — a wrong hit costs
one read, a miss costs a security claim.* This is the second time a tool of mine under-reported
(the first was defcaps, below); both were silent, and both looked like clean results.

## CLOSED — all 15 AUTHORITY claims are now verified

| claim | outcome |
|---|---|
| `ORBR\|A_Fuel` | claim was **FALSE** — fixed earlier, tested |
| `ORBR\|C_WithdrawFees` | true; pinned (`_verify_finding_ORBR-FEE_01`) |
| `VST\|C_CreateFrozenLink` | true; pinned (`VST-G4`) |
| `VST\|C_CreateReservationLink` | true; pinned (`VST-G4`) |
| `VST\|C_CreateVestingLink` | true; pinned (`VST-G4`) |
| `ATS\|C_VestedCoil` | **doc wording misleading**; real property true, pinned (`ATS-G11`) |
| `FVT\|C>UNSTALE-ALL` | **already tested** — my tool's false positive |
| `BRD\|A_Live` | true (`BRD\|C>LIVE` composes `GOV\|BRD_ADMIN`); pinned (`ADMIN-G9`) |
| `STOAICO::A_Stake` / `A_Unstake` | true; pinned (`SICO-G9`) — surfaced only by the widened regex |
| `ATS\|HOT-RBT\|C_Repurpose`, `ATS\|C_KickStart`, `SWP\|C_ToggleSwapCapability`, `A_Inject` | already covered |
| `SWP\|C_UpdateFee` | BOUND tier; pinned (`SWP-G20`) |

### Two things the sweep taught about the tool itself

**A defcap is never named by a test.** `FVT|C>UNSTALE-ALL` was reported unmentioned while its
ownership gate was fully tested through `CCp_UnstaleAll`. Name-mention coverage UNDER-counts for
caps: a defcap hit means "check the acquirer", not "untested". Now documented in the tool.

**`ATS|C_VestedCoil`'s doc is imprecise, not wrong.** *"Only the Owner of `<coil-token>`"* reads as
the token's registrar-owner. It cannot mean that — `[6.7]_VST:142` coils OURO as ANHD, who does not
own OURO, and that call is correct. "Owner" means the HOLDER. The security-relevant property is the
stronger one: **a third party cannot cause someone else's tokens to be coiled and vested away**.
That is what `ATS-G11` pins.

### Fixture traps hit along the way

Each cost a run and each would have produced a test that passed for the wrong reason:

- **Auryndex has HIBERNATION on** by the end of `modules/ATS.repl`, and that check fires before the
  ownership one — the test would have gone green on the wrong error. Used EliteAuryndex instead.
- **STOA is charged BEFORE the ownership check** in the VST link path, so an unfunded caller fails
  on payment and never reaches the authority error. EMMA had to be funded to pay her own way for
  the rejection to mean anything.
- **Tag collisions**: `ATS-G9` and `DALOS-G2e` were already taken. Always
  `grep -o "<PREFIX>-G[0-9A-Za-z]*" <file> | sort -u` before choosing.

## A whole CLASS the patterns missed: IMMUTABLE

AUTHORITY/BOUND/INVARIANT caught none of *"A Frozen Link is **immutable**"*. A permanent property of
stored state is the strongest promise a contract makes and the most damaging to get wrong, so it is
now its own tier. Small by design — 8 occurrences codebase-wide — which means it can be triaged
**exhaustively** rather than sampled.

**5 claims, all now accounted for:**

| claim | outcome |
|---|---|
| `VST\|C_CreateSleepingLink` | immutable — **pinned** (`VST-G5`) |
| `VST\|C_CreateHibernatingLink` | immutable — **pinned** (`VST-G5b`) |
| `AQP-SCR\|C_EnableDebBoost` | "irreversible" — covered, and **structurally guaranteed: no disable function exists** |
| `UEV_ScoreMultiplier` | already tested (`15H-1`..`15H-4`) |
| `UC_ReshapeUnstakeObject` | incidental prose |

**The mechanism matters and is recorded.** `VST-04`/`VST-06` already created those links and
asserted they registered — the *positive* half. Nothing asserted the immutable half. It holds, but
**not by a deliberate guard**: the second create dies on the DPOF insert colliding with the existing
counterpart row, so a caller gets a raw database error rather than *"this DPTF already has a
sleeping link"*. Correct behaviour, unhelpful message — the same diagnosability shape as the
empty-list index faults. Pinned on the stable message prefix, so if a real guard is ever added this
fails and the expectation moves to that message.

## Tier status

| tier | state |
|---|---|
| AUTHORITY (15) | ✅ closed |
| IMMUTABLE (5) | ✅ closed |
| BOUND (7 after re-tiering) | ✅ audited — one real gap, pinned (`SWP-G20`) |
| INVARIANT (74) | ⬜ not audited — mostly incidental "always"/"never"; read-and-triage, low expected yield |

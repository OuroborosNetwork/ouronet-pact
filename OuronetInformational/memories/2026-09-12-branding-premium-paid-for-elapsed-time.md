# Branding premium is charged for time that has already elapsed

**Date:** 2026-09-12 · **BOTH FIXED the same day**, owner-authorised (*"so lets fix those BRD bugs,
since they are bugs, as it seems"*) · pinned by `modules/SWP.repl <<SWP-G24>>`
**Site:** `1_SOVEREIGN/STAGE_01/2_Core/04_BRD.pact` — `BRD|DEFAULT` / `XE_Issue` and
`XE_UpgradeBranding`

## Resolution

**Fix 2 — clamp the extension base to now when the premium has lapsed:**

```pact
(current:time (at "block-time" (chain-data)))
(premium-until:time
    (add-time
        (if (> (diff-time premium current) 0.0) premium current)
        seconds
    )
)
```

**Fix 1 — `genesis` stamped per issuance; `premium-until` a deliberate sentinel:**

```pact
(defconst BRD|NO_PREMIUM:time (time "1970-01-01T00:00:00Z"))     ;; "never held premium"
…
(defun XE_Issue (entity-id:string)
    (P|UEV_IMC)
    (let ((fresh:object{BrandingV2.Schema}
              (UDC_BrandingGenesis BRD|DEFAULT (at "block-time" (chain-data)))))
        (insert BRD|BrandingTable entity-id
            {"branding" : fresh ,"branding-pending" : fresh})))
```

**The first attempt stamped `premium-until` with the issuance time too, and that was wrong.** It
broke three upgrade call sites that had always worked, and the gate caught it. The reason is worth
keeping: "premium expired the instant this row was written" is a *different claim* from "this entity
has never held premium", and its truth depends on **when the row happened to be written**. Since this
suite's simulated clock runs BACKWARDS between files, issuance-stamped premium made fresh entities
look months-premium to earlier transactions, and `BRD|C>UPGRADE` correctly refused to extend a flag
with over 15 days left.

A fixed point in the past that no clock can overtake says the intended thing, everywhere, at any
clock. `genesis` genuinely *should* be the entity's own time — it is a birth date — so only that one
moved.

`UDC_BrandingGenesis` is new and **module-only on purpose** — declaring it in the `BrandingV2`
interface would bump the interface and drag every consumer along under the cascade rule, for a
constructor only `XE_Issue` needs. Its six siblings are interface-declared because external modules
build branding objects with them; nothing outside BRD sets a genesis. `BRD|DEFAULT` keeps both time
fields (the schema requires them) with a comment that they are placeholders which must never reach a row.

**Blast radius checked before editing:** `BRD|DEFAULT` had exactly one consumer (`XE_Issue`), and
nothing outside BRD reads `UR_Genesis` / `UR_PremiumUntil` — the `UR_Genesis*` hits elsewhere are SWP
swap-pair genesis *weights*, unrelated.

## What the fix bought: a guard that was unreachable is now pinned

`BRD|C>UPGRADE`'s fifth guard — *"Blue Flag has more than 15 days remainig!"* — **could not be reached
while Fix 2 stood**, because premium was always behind the clock, `remaining` was always negative, and
the guard always passed. It is now pinned: one upgrade puts premium 30 days out, and the immediate
second attempt is refused. **All five BRD guards are covered.**

`SWP-G24` also pins **the other branch of the clamp**, which matters as much as the fix: 20 days on
(10 days of premium left, under the threshold) a renewal is permitted and adds 30 days to the **stored**
date, so the entity keeps its 10 remaining days for 40 in total. Without that assertion the fix could
drift into "always extend from now" — the mirror-image bug, which would confiscate a renewal's
remaining days.

## Finding 2 — the one that costs money

```pact
(premium:time      (UR_PremiumUntil entity-id false))
(seconds:decimal   (fold (*) 1.0 [86400.0 30.0 (dec months)]))
(premium-until:time (add-time premium seconds))          ;; :442 — from STORED, never from NOW
```

Extending from the stored value is **right for a live subscription** — no time is lost between
renewals. It is wrong when the premium has **lapsed**: the buyer pays for 30·N days measured from a
date already gone, and receives a **Blue flag with zero usable premium**.

Measured end-to-end through the real client (`TS01-C3.SWP|C_UpgradeBranding`):

| | |
|---|---|
| premium-until before | the frozen default, in the past |
| after paying for 1 month | advanced by exactly 2,592,000 s — **still in the past** |
| flag after paying | **1 (BLUE)** — i.e. other code now reads this entity as premium |
| a second paid upgrade | **ALLOWED** (the 15-day guard sees negative "remaining") |
| a third | also allowed — each buys 30 days that already elapsed |

The STOA is really spent: the call settles two `coin.TRANSFER` legs (≈19.1 + ≈57.4 at current pricing).

Applied as shown in the Resolution above. (`current` was NOT already bound in `XE_UpgradeBranding`'s
own `let` — only in the defcap — so the fix adds it.)

## Finding 1 — why *every* entity starts lapsed

```pact
(defconst BRD|DEFAULT
    {… ,"flag" : 3
     ,"genesis"       : (at "block-time" (chain-data))
     ,"premium-until" : (at "block-time" (chain-data))})
```

A `defconst` is evaluated **once, at module load**. So `genesis` and `premium-until` are not the
entity's issue time — they are **BRD's own deploy timestamp**, baked in and shared by every entity
`XE_Issue` ever creates. Two consequences:

1. **`genesis` is meaningless as a birth date.** It is a constant, identical for all entities, and it
   is the value `UR_Genesis` hands to anything that reads it.
2. **Every never-upgraded entity starts with premium already lapsed**, which is exactly the state
   Finding 2 mishandles. The two defects compound: Finding 1 guarantees the input that Finding 2 gets
   wrong.

On this chain the constant is the **epoch** (nothing had set `chain-data` when BRD loaded); on a live
chain it is the deploy date — still permanently in the past. Fixed by moving both timestamps into
`XE_Issue`, where `(at "block-time" (chain-data))` is evaluated per call.

**A consequence of Fix 1 worth knowing, found by the test failing:** `premium-until` is now a real
point on the suite's timeline — and the REPL timeline is **not monotonic**, because each loaded file
sets its own `env-chain-data`. So a transaction can run at a block-time *earlier* than the one at which
the entity was issued, making a fresh entity look like it has months of premium left. A real chain
cannot run backwards; a REPL can. `SWP-G24` therefore **pins its own clock** (100 days past the pair's
own genesis) instead of inheriting whatever the previous file left, and restores it afterwards.

## Pinned, and what it unblocked

`SWP-G24` drives the whole sequence and asserts each step, including the two findings, so the fix
verifies itself: clamp the base and *"premium-until is STILL in the past after paying"* flips.

It also explains a coverage gap honestly. `BRD|C>UPGRADE`'s fifth guard —
*"Blue Flag has more than 15 days remainig!"* — **cannot be reached while Finding 2 stands**: premium
is always behind the clock, so `remaining` is negative and the guard always passes. On this chain it
would take ~660 paid upgrades to climb from 1970 to the suite's clock. **The guard is unpinned because
of a defect, not because of a missing fixture** — and fixing Finding 2 makes the very next upgrade
reach it.

Four of BRD's five guards are now pinned (flag domain, months bound, Golden, Red) — all reached via
`BRD|A_SetFlag`, a real admin client, with no table surgery at all.

## How it was found

By building the fixture for guard 5 the obvious way — *succeed first, then the refusal becomes
reachable* — and asserting the intermediate state instead of assuming it. The assertion
*"the upgrade pushed premium-until into the future"* failed. Had the test gone straight for the
refusal, the upgrade would have appeared to work and the expect-failure would simply have been
recorded as "not reachable, needs a fixture".

**Assert the state your fixture is supposed to have created, not just the outcome you were after.**

And once more while flipping the test to the fixed behaviour: I wrote *"the 20-day shift is undone"*
without actually undoing it. The assertion caught it. That is the argument for asserting a restore
rather than trusting it — the same reason every fixture in this suite has a no-leakage transaction.

## The bug had been written down as the rule — which is most of why it survived

`modules/ATS.repl <<ATS-BRD>>` asserted:

```pact
;;<months> buys months measured from branding genesis, not from now.
(expect "<<ATS-BRD>> three months of premium were bought"
    (add-time (at "genesis" b) (days 90)) (at "premium-until" b))
```

That is the defect, stated as a requirement, with a comment rationalising it. And it was *accurate*
about the old code: `genesis` and `premium-until` were the same frozen constant, and the upgrade
extended from the stored premium — so "genesis + 90 days" really was what came out, and it read like
deliberate design.

**An assertion that restates what the code does, with a comment explaining why that is sensible,
converts a defect into a requirement.** A test earns the right to state a rule only when somebody has
checked that the rule is the intended one. The assertion now pins "90 days from NOW" and a second one
names the old value explicitly, so reverting either fix fails here rather than quietly passing again.

## A mistake of mine, and the rule that would have prevented it

To undo a test-side edit I no longer needed, I ran `git checkout -- "REPL/Stage_01/[6.6]_ATS.repl"`.
This repository has **extensive uncommitted work**, and that file was among it: the checkout discarded
an unstaged rename (`ATS::URC_RTSplitAmounts` → `URCv_RTSplitAmounts`, 4 occurrences) from a previous
session's conformance pass. Unstaged changes are not recoverable from git — `git fsck --lost-found`
had nothing.

It was recovered by static analysis rather than guesswork: extract every `ref-MOD::FUNC` and
`MOD.FUNC` reference in the file, resolve the module aliases from its own `let` bindings, and check
each name against the current `.pact` sources. That found exactly four stale references; three were
commented out, and the fourth was the lost rename. `git diff` on `08_ATS.pact` then gave the new name.
Gate green after, so nothing else was lost.

**Rule: never `git checkout --` a file in a tree with uncommitted work to undo your own edit.** Apply
a targeted reverse edit instead. The blast radius of `checkout` is the whole file, not your change.

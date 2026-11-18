<!-- F4 · opened 2026-11-08 · OPEN · blocked on S1 -->

# SPEC — `coin`'s UrStoa vault carries S1, and one guard holds by accident

> **Companion to** [`FINDINGS-2026-11-08.md`](FINDINGS-2026-11-08.md) §F4 and to
> [`SPEC-unclaimed-count.md`](SPEC-unclaimed-count.md) (S1), which this repeats one contract over.
>
> **This is StoaChain's root `coin` contract, not an Ouronet module.** Owner ruling: *"that vault
> only has 5 stakers. so fixing it is okay"* — and *"fix AFTER S1, so the pattern is proven on
> modules we own before touching StoaChain's root contract."* **S1 ships first. This spec does not
> authorise a deploy.**
>
> Every line below was checked against the **LIVE** contract (`/tmp/live_coin.pact`, fetched
> 2026-11-08), not against the repo copies in `00_StoaSandbox/`. The repo copies are older and
> differ in exactly the way that matters (§4).

---

## 1. What is wrong — the same defect, the same two sentences

The vault's counter is documented as one thing and maintained as another, exactly as in S1.

**The documented meaning** (`coin.pact:1532`, the schema comment):

```pact
unclaimed-count:integer    ;;Stores the total number of Users with unclaimed Rewards
```

**The maintenance rule** (`C_URV|Collect`, step 3, line 1816):

```pact
;;3]Decrement <unclaimed-count> only when account has no stake left (user-supply = 0): they have
;;  collected and no longer accrue; if they still have stake we do not decrement (they keep accruing)
(if (= (UR_URV|UserSupply account) 0.0)
    (XI_URV|UpdateUnclaimedCount false)
    true)
```

A staked account that has just collected holds **no** unclaimed rewards and is **still counted**. So
the counter is "accounts that can ever claim", not "accounts with unclaimed rewards" — S1's defect,
verbatim.

### 1.1 What it breaks — the sweep

```pact
;; URC_URV|ClaimableRewards, line 1655
@doc "Computes Claimable Reward of Account. When only one staker has unclaimed rewards \
    \ (unclaimed-count=1), that staker receives the full vault supply to avoid rounding dust."
(if (and (= (UR_URV|VaultUnclaimedCount) 1) (> available 0.0))
    (UR_URV|VaultSupply)
    available)
```

The sweep fires at `unclaimed-count = 1`. Because a staked collector is never retired, **the count
cannot fall to 1 while two or more accounts hold stake.** With five stakers it sits at five. The
floored per-account figures are paid, the remainder stays in `stoa-supply`, and nothing ever sweeps
it.

**Consequence: a permanently unclaimable residue of native STOA accumulates in StoaChain's root
contract.** It is monotonic — measured on the Ouronet side across three injection rounds as `1e-24`,
carried, `2e-24`. Small per round, and there is no mechanism that ever returns it.

### 1.2 The decrement rules in full

For completeness, because the fix must preserve the two that are right:

| site | line | rule | correct? |
|---|---|---|---|
| stake | 1756 | increment when the account's initial score was 0 (a new staker) | **yes** |
| unstake to zero | 1787 | decrement `nzs`; decrement `unclaimed` **only if pending = 0** | **yes** — a zero-stake account with pending rewards must stay counted |
| collect | 1816 | decrement **only if `user-supply = 0`** | **no** — this is the defect |

Note that 1787 is *carefully* right: it was written by someone who had thought about the
zero-stake-with-pending case. The same author wrote 1816. The two rules disagree about what the
counter means, in adjacent functions.

---

## 2. The guard that holds by accident — read this before changing anything

`C_URV|Collect` decrements the counter at step 3 with **no check that anything was collected**, and
`URV|COLLECT` authorises on ownership alone:

```pact
(defcap URV|COLLECT (account:string)
    @managed
    (CAP_Account account)
    (compose-capability (URV|NATIVE-AUTOMATIC))
    (compose-capability (SECURE)))
```

There is no *"nothing to collect"* refusal. Taken alone, that is an unbounded decrement: an account
at zero stake and zero pending could call collect repeatedly, driving `unclaimed-count` down past 1
to 0 and below, and then — having staked a dust amount and accrued anything at all — collect at
`unclaimed-count = 1` and be paid `UR_URV|VaultSupply`, **the entire vault, including every other
staker's rewards.**

**That path does not execute**, and the reason is three call levels away from the vault:

```
C_URV|Collect  →  C_Transmit  →  TRANSMIT  →  X_TRANSFER
                                              →  (UEV_Amount amount "Transfer requires a positive amount")
                                              →  (enforce (> amount 0.0) message)
```

Step 1 of collect transmits `available-rewards`. When that is `0.0`, `UEV_Amount` is **strict**
(`>` , not `>=`) and the transaction **aborts before step 3 is reached**. The repeated-decrement
vector is closed.

**It is closed by a token-transfer precondition, not by the vault's own logic, and nothing records
the dependency.** Three plausible future changes re-open it:

1. A zero-amount tolerance anywhere on the transmit path (a bulk payout, a "collect all" convenience,
   a `UEV_MngAmount` substitution — the `>= 0.0` variant **already exists** in the same contract at
   `UEV_MngAmount`).
2. Reordering collect so the counter is decremented before the transfer.
3. Any new collect entrypoint that books without paying.

**Point 3 is not hypothetical — it is what the Ouronet-side eviction bulking does.**
`XE_EvictPayNoMove` deliberately books a leg and defers the movement so a multi-bulk can pay it.
Checked, 2026-11-08: that path is **safe**, because the amount it defers is read per-leg before
booking and the bulk pays exactly that sum, so a zero-owed leg books nothing and is paid nothing —
and `XI_1|BookCollectUnclaimed` retires on `deb == 0 AND pending > 0`, so a no-op leg does not
decrement either. **But the protection there is a different one**, and the two must not be conflated:
on `coin` the safety comes from the transfer aborting; on the Ouronet bulked path the transfer no
longer aborts, and safety comes from the per-leg read and the retirement guard.

**Therefore §6.1 is non-negotiable: the fix must add the explicit guard** rather than rely on the
accident, *whatever else it changes*. It is a one-line `enforce` and it converts an invariant that
currently depends on a precondition in another module into one that is stated where it is needed.

---

## 3. A second dead mechanism — `nzs-count` is write-only

`nzs-count` (line 1530, *"Stores the number of users with `<Non-Zero-Score>`"*) is faithfully
maintained — incremented at 1759, decremented at 1790 — and **read by nothing that runs.**

Complete census of `UR_URV|VaultNZS`:

| line | site | live? |
|---|---|---|
| 1604/1606 | its own declaration and body | — |
| 1900 | inside `XI_URV|UpdateNZS`, to compute its own next value | self-reference |
| 1939 | inside `XI_URV|ResetUnclaimedCount` | **dead — see §4** |

So the only consumer of `nzs-count` is a function that is never called. It is the `TotalNzsCount`
pattern (`SPEC-score-definition-reissue.md` §1.4) in StoaChain's root contract: state maintained on
every stake and unstake, for a reader that does not exist.

The fix must decide whether `nzs-count` becomes live (§6.3) or is documented as vestigial. **It must
not be silently left as it is**, because a maintained counter with no reader is indistinguishable
from a working feature.

---

## 4. The dead reset, and why removing it was RIGHT

`XI_URV|ResetUnclaimedCount` (line 1936) occurs **exactly once in the live contract — its own
`defun`.** It is dead code.

```pact
(defun XI_URV|ResetUnclaimedCount ()
    (require-capability (SECURE))
    (update URV|UrStoaVault USV
        {"unclaimed-count" : (UR_URV|VaultNZS)}))
```

The older deployed contracts — `coin-live`, `coin-stoa`, `stoa-v1`, `stoa-v2` — **do** call it, on
inject. So the call was removed deliberately at some point between those and the live `coin`.

**The removal was correct, and the live contract records the reasoning twice:**

> `1731` — `;;3]Do not reset <unclaimed-count> on inject so accounts with 0 stake but pending rewards remain counted`
>
> `1756` — `;;2.3]… do not reset unclaimed to nzs or we lose 0-score-with-pending accounts`

Resetting `unclaimed-count := nzs-count` on inject would drop every account holding pending rewards
at zero stake, under-counting the claimant population — and an **under**-count is the dangerous
direction, because it is what makes the sweep fire early and pay one account the whole vault while
others still hold claims. The author saw that and removed the call.

**CORRECTED 2026-11-08:** an earlier reading in this session called the removal *"an unreasoned port
artefact"*. It is the opposite — it is the single best-reasoned decision in this vault, and the
rationale is written in the contract at two separate sites. What was never done is **replacing the
capability the reset provided**. The reset was the only thing that could ever bring the count back
down to a correct floor; removing it fixed the under-count and left the over-count (§1) with no
remedy.

That is the precise shape of the defect: **a correct fix to one direction of an error, with nothing
built for the other.**

---

## 5. What makes this easier than S1

Three structural simplifications, worth stating because they bound the work:

1. **One vault, one lane.** `URV|UrStoaVault` is a single-row table keyed `USV`, and the reward token
   is always native STOA. S1's per-FVT-per-reward-token lane matrix does not exist here, so the
   per-lane-vs-per-FVT question that needed an owner ruling in S1 (§12.1 there) **has no analogue**.
2. **No disabled-member case.** There is no admission flag on a vault staker, so F3's
   collect-ineligible claimant — the permanent floor on the count — cannot arise. The counter has
   exactly one population.
3. **Five stakers.** The backfill is enumerable by hand and verifiable by inspection. Owner: *"that
   vault only has 5 stakers. so fixing it is okay."*

Against that, one thing makes it harder: **it is the root contract**, so there is no REPL-first
iteration against the real thing and no second attempt. Hence the ordering ruling.

---

## 6. The fix

### 6.1 Add the explicit nothing-to-collect guard — unconditional, do first

```pact
(enforce (> available-rewards 0.0) "Nothing to collect")
```

in `C_URV|Collect`, before any state change. It is correct today, changes no behaviour that currently
succeeds, and it makes §2's invariant local instead of accidental. **This is the one change that is
right regardless of every other decision in this spec**, and it is the one that must not be left out
of whatever round lands.

### 6.2 Correct the collect decrement

Per S1's locked definition, retire the claimant when they hold nothing claimable — not when they hold
no stake:

```pact
;; replaces line 1816's (= (UR_URV|UserSupply account) 0.0)
(if (= (UR_URV|UserPendingRewards account) 0.0)   ;; after XI_URV|ResetPendingRewards
    (XI_URV|UpdateUnclaimedCount false)
    true)
```

This is the shape S1 settles for the Ouronet lanes, which is why S1 must land first: **the predicate
is derived there, against a test suite we own, and copied here.** Do not derive it twice.

**The ordering inside collect matters.** Step 2 (`XI_URV|ResetPendingRewards`) zeroes pending, so a
post-step-2 read of pending is always 0 and the guard would degenerate into "always decrement". Place
the decision **before** step 2, or decide it from the pre-collect figure. This is the same ordering
hazard `SPEC-unclaimed-count.md` §7 records for backfill vs. accrual, and it is the likeliest way to
get this wrong while believing it is fixed.

### 6.3 Resolve `nzs-count`

Either give it a live reader or mark it vestigial in the schema comment. **Recommendation: mark it
vestigial.** Making it live means finding a job for it; S1 establishes that the sweep needs the
*claimable* population, which is `unclaimed-count`, not the non-zero-score population. A second
counter with no distinct consumer is what produced §3.

### 6.4 The dead reset

Delete `XI_URV|ResetUnclaimedCount`, and move its reasoning (§4) into a comment at the schema field,
where the next reader will be. Deleting the function without preserving the rationale would invite
someone to re-add the reset — which is the one change that turns a dust leak into a theft vector.

### 6.5 Backfill

With the decrement corrected, the live `unclaimed-count` is too high by the number of accounts that
hold stake and no pending rewards. Five stakers: enumerate them, compute the correct count, write it
once under `GENESIS`/admin authority. **Then sweep the accumulated residue** — with the count correct,
the last claimant's collect pays `UR_URV|VaultSupply` and drains it by the existing mechanism, so no
new sweep code is needed. Verify `stoa-supply` reaches exactly 0 after the final collect.

---

## 7. Tests

The live contract cannot be iterated against, so everything is proven in `00_StoaSandbox/` first. The
sandbox copies are **older** (§4: they still call the reset), so **step one is bringing the sandbox to
parity with the live contract** — otherwise the suite tests a contract that is not deployed.

- `<<TX-F4-000>>` — **parity**: assert the sandbox vault's collect/stake/unstake decrement rules match
  the live source, including the absent reset call. Without this the rest is testing fiction.
- `<<TX-F4-001>>` — the defect: two stakers, both collect while staked, assert `unclaimed-count` stays
  2 and the sweep does not fire. Passes today.
- `<<TX-F4-002>>` — residue: inject, collect by both, assert `stoa-supply > 0`. Repeat three rounds and
  assert it is **monotonically increasing** — the Ouronet-side measurement that established accrual.
- `<<TX-F4-003>>` — **the accidental guard** (§2): a zero-stake, zero-pending account calls collect;
  assert it **fails**, and assert `unclaimed-count` is unchanged. This is the regression that protects
  against the theft vector; it must pass before AND after the fix.
- `<<TX-F4-004>>` — after §6.1, assert the refusal message is *"Nothing to collect"*, so the explicit
  guard is distinguishable from the transfer's refusal. A test that cannot tell them apart would pass
  with §6.1 deleted.
- `<<TX-F4-005>>` — after §6.2: staked account collects, assert it **is** retired; assert the count
  reaches 1 with one claimant remaining and the sweep pays `VaultSupply`.
- `<<TX-F4-006>>` — exact drain: full cycle, every account collects, assert `stoa-supply` is **exactly
  0.0**. The conservation assertion; this is what the whole spec is for.
- `<<TX-F4-007>>` — preserve 1787: a zero-stake account with pending rewards stays counted. A standing
  regression against "simplifying" the two decrements into one.
- `<<TX-F4-008>>` — the under-count direction: assert no reachable sequence drives `unclaimed-count`
  below the number of accounts holding claimable rewards. This is the property §4's removed reset
  violated, and the one that makes over-counting the safe failure.

`Stage00a_StoaTests.repl` is the existing Stoa coin regression suite and is where these belong.

---

## 8. Decisions needed from the owner

### 8.1 Confirm the ordering

S1 lands, is observed on mainnet, **then** this. Already the owner's ruling; restated because this
spec is the one place it could be forgotten.

### 8.2 Who can write the backfilled count?

§6.5 needs a one-shot authorised write. The vault's existing authorities are `GENESIS` and
`SECURE`/`URV|NATIVE-AUTOMATIC`. **Which is acceptable for a one-time correction on the root
contract, and does the correcting entrypoint get removed afterwards or kept?** A kept entrypoint that
can set the counter arbitrarily is a standing risk of exactly the under-count §4 warns about.

### 8.3 Is `nzs-count` wanted at all?

§6.3 recommends marking it vestigial rather than finding it a job. If it is meant to serve something
not yet built, say so and it stays with a comment naming the intent — but then it is a fourth
half-built mechanism and should be on the ledger as one.

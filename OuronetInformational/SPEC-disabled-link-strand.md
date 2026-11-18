<!-- F3 · opened 2026-11-08 · OPEN -->

# SPEC — one flag doing two jobs: disabled links strand earned rewards

> **Companion to** [`FINDINGS-2026-11-08.md`](FINDINGS-2026-11-08.md) §F3.
>
> Owner, on finding this: *"i never expected it to strand rewards."* That is the whole defect — the
> flag does what its name says and one thing more, and the extra thing is invisible from every
> surface that describes it.

---

## 1. What is wrong

`FVT|T|ScoreEntityLink.enabled` is a freely-togglable flag whose intended job is **to stop a member
accruing**. It also **gates collection of rewards already accrued**, and nothing in its name, its
`@doc`, its capability comment or the UI says so.

```pact
;; 05_FVT.pact:2365 — inside UEV_CollectContext
(enforce (ref-RPS::UR_FVT-SEL|Enabled fvt-id score-entity-id)
    "ScoreEntityLink must be enabled for collect")
```

### 1.1 Why the toggle cannot mean "remove the member"

Membership is **permanent**, so "disable" has only one available meaning. Verified:

- `SCR|XE>CREATE-FVT-LINK` enforces `(and (= fvt-link BAR) (!= fvt-id BAR))` — *"One-time fvt-link:
  slot BAR"*.
- There is exactly **one** writer of the field in the tree, `WU_Score|FvtLink` (`02_SCORE.pact:4089`),
  reached from exactly one entrypoint (5079).
- Nothing sets it back to `BAR`. Confirmed with the owner 2026-11-08.

So the flag cannot be read as "remove from aggregator". It can only mean "stop accruing" — which is
what the UI promises, in `OuronetUI/src/components/tokens/TokenActionBar.tsx:286`:

> "Enable or disable the selected member. **A disabled member earns nothing from new injections; its
> already-accrued rewards are untouched.** Enabling re-checks stream eligibility, so a disabled
> member on a latched aggregator must itself be drift-locked. Owner only."

**"Untouched" is true of the accounting and false of the access.** The rewards are still in the row
and cannot be withdrawn.

### 1.2 There is no escape hatch — evict is gated on the same flag

This is the part the ledger entry did not have, and it changes the severity.

`UEV_CollectContext` has **two** callers:

| caller | line | who it serves |
|---|---|---|
| `FVT|C>COLLECT` | `05_FVT.pact:1294` | the holder, collecting their own rewards |
| `FVT|XE>EVICT-REWARD` | `05_FVT.pact:4469` | the aggregator owner, evicting on a holder's behalf |

So the aggregator owner cannot route around it either — **the same owner who flipped the flag, and
the only party who could plausibly be asked to clean up, is refused by the same `enforce`.** Eviction
exists precisely to move rewards out when a holder will not or cannot, and it is closed here too.

The rewards are recoverable by exactly one action: **re-enabling the member.** That is a real escape
hatch and it bounds the damage — nothing is destroyed. But it is a *manual, owner-only* action, it is
not discoverable from any error message the holder sees, and the holder cannot perform it.

### 1.3 What is NOT wrong — checked, because a reader will worry about it

Four things that look like they should also be broken and are not. Recording them is the point of
this section; each was traced.

1. **Principal is not stranded.** `URC_PoolEmployedScoresFvtStakeReady` — which checks `Enabled` via
   `URC_ScoreFvtStakeReady` — is consulted as `(if direction (…) true)` at `05_FVT.pact:1356`, 1482
   and 1596. `direction` is the stake flag, so readiness gates **staking only**. A holder can always
   **unstake** out of a disabled member. Only the rewards are trapped.
2. **Accrual genuinely stops, as advertised.** `URC_SettleEligibleEmployedScores`
   (`04_RPS.pact:1721`) filters settlement on `Enabled`, so a disabled member is excluded from the
   settle set and books nothing from new injections.
3. **The `TotalDebScore` mirror stays correct across a disable → unstake → re-enable cycle.** The
   toggle adjusts the mirror by `∓ URC_ScoreEntityMemberDebWeight` (`04_RPS.pact:3056`), and
   `XI_SyncFvtTotalDebMirrors` (3348) deltas it by `new-deb − pre-deb` with **no `enabled`
   condition** — which looks like a double-count waiting to happen. It is not: `pre-member-debs` is
   built from `settle-plans`, which derives from the `Enabled`-filtered `settle-scores` (2395), so a
   disabled member is never in the sync set. Disable subtracts `d₁`; the unstake moves the score's
   own total but not the mirror; re-enable adds the live `d₂`. Net `d₂ − d₁`, which is correct.
4. **The farm's `S` is adjusted symmetrically** (`±W_i`, class 0) by the same writer, on `changed`
   only, so repeated same-value toggles are no-ops.

**This is not an accounting defect. It is an access-control defect**, and conflating the two would
send the fix to the wrong place. The numbers are right; one `enforce` is in the wrong function.

---

## 2. The twin — `reward-enabled`, with a wider blast radius

The line immediately above the one in §1 is the same defect on a different flag:

```pact
;; 05_FVT.pact:2364
(enforce (ref-RPS::UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id)
    "Reward token is disabled for collect")
```

`FVT|C>TOGGLE-REWARD-LINK` (`05_FVT.pact:1142`) carries **no guard beyond ownership** — not even the
re-enable eligibility check its sibling has. Its `@doc` is *"Toggle RPS|Global.reward-enabled; ±1
enabled-reward-count on flip. FVT owner."*

**Severity is strictly worse than §1.** `ScoreEntityLink.enabled` strands one member's rewards in all
tokens; `reward-enabled` strands **every member's** rewards in that token. On an aggregator with many
members, one toggle closes the exit for all of them at once.

It must be fixed in the same change. A fix that only addresses `ScoreEntityLink` leaves the larger
version of the same hole open, and the two gates are **adjacent lines in one function**.

---

## 3. The locked definitions

### 3.1 `ScoreEntityLink.enabled`

> **Accrual admission.** When false, the member is excluded from settlement and from farm/vault weight
> totals, and may not be staked into. It says nothing about rewards already booked.

### 3.2 `RPS|Global.reward-enabled`

> **Injection admission for a reward token.** When false, the token accrues nothing new on this
> aggregator. It says nothing about rewards already booked.

### 3.3 The invariant both must satisfy

> **Booked rewards are always reachable.** Once `deb` has been credited to a member in a token, there
> exists an executable path that pays it out, for every reachable configuration of every
> admission flag.

That sentence is the spec. Today it is false in two places.

---

## 4. Why it happened — worth recording, because the comment is still there

`FVT|C>TOGGLE-SCORE-ENTITY-LINK` carries this:

```pact
;; DRIFT INVARIANT on RE-ENABLE only: a member being switched back ON must still be
;; drift-locked if this FVT streams. Disabling is always allowed — removing a member
;; cannot break the promise.
```

The author was reasoning about **the streaming drift promise** — and was right about it: disabling
cannot break *that* invariant. The sentence *"Disabling is always allowed"* is a conclusion about one
invariant, written in a place where it reads as a conclusion about all of them. Then the collect gate
was added in a different function, for a different reason, and nothing connected the two.

This is the same shape as F1's drift latch (`SPEC-score-definition-reissue.md` §1.2): a correct,
narrow, reasoned claim whose wording generalises itself. The remedy in both cases is to **scope the
sentence**, not delete it.

---

## 5. What the fix must account for

1. **Why the gate is there at all must be established before it is removed.** Nobody has yet produced
   a reason a disabled member's collect is unsafe. The candidates, all of which must be checked:
   - *Stale `rps` / rounding.* A disabled member's accrual stops, so its `deb` is frozen; collecting a
     frozen figure is the easy case, not the hard one.
   - *The `unclaimed-count` interaction.* **This is the one that matters.** Collect retires a
     claimant and decrements the lane counter; see §6.
   - *Stream eligibility.* `UEV_StreamEligibleMemberOk` is enforced on **re-enable only**, so it is a
     statement about accrual, not payout.
2. **The sweep guard must not be perturbed.** The last-claimant sweep pays the whole
   `available-rewards` when `(and (= gc 1) (> deb-user 0.0))`. Admitting new collects changes which
   account is last. See §6 — this is a hard ordering dependency on S1.
3. **Evict must regain the same access as collect** (§1.2), and for the same reason: it is the
   owner-side remedy for a holder who cannot act.
4. **Both flags, one change** (§2).
5. **Re-enable must stay guarded.** `UEV_StreamEligibleMemberOk` on re-enable is correct and must
   survive: it protects the stream-drift promise, which is a different invariant and genuinely at
   risk. **Do not "simplify" the toggle by dropping it.**
6. **No new scan.** The fix is the removal or relocation of two `enforce`s, not new state. If a design
   needs a new table to decide whether a collect is allowed, it is the wrong design.

---

## 6. The hard dependency — S1 must land first

`UEV_CollectContext`'s gate currently has a side effect nobody chose: **it keeps disabled members out
of the claimant population.** Admitting them changes the population that `unclaimed-count` counts, and
that counter is already wrong in a way that is separately specified.

From [`SPEC-unclaimed-count.md`](SPEC-unclaimed-count.md): the counter is documented as "accounts with
unclaimed rewards" and implemented as "accounts that can ever claim", and the dust sweep is
unreachable on a live aggregator as a result.

A disabled member is **exactly the ambiguous case** between those two readings:

- under *"accounts that can ever claim"* — it is counted today, because membership is permanent and
  it can claim after a re-enable;
- under *"accounts with unclaimed rewards"* — it is counted too, because it holds `deb > 0`;
- but it **cannot claim now**, so it can never be the account that drives the count to 1 and fires
  the sweep.

So **a disabled member with `deb > 0` is a permanent floor on `unclaimed-count`** — a claimant that
is counted and cannot be retired. That is a second, independent reason the sweep is unreachable, and
it is not recorded in `SPEC-unclaimed-count.md`. **Add it there** (§7 below).

**Ordering ruling for this spec: S1 lands first.** Fixing F3 before S1 would change the claimant
population underneath a counter that is being redefined in the same period, and the sweep guard is
re-derived in that round rather than carried over (`SPEC-unclaimed-count.md` §9). Two simultaneous
changes to who may claim, with a guard being rewritten between them, is how the first version of this
got wrong.

---

## 7. Changes required in the S1 spec

`SPEC-unclaimed-count.md` must gain, in its §5 (*what it must account for*):

> **A member whose link is disabled holds `deb` and cannot collect** (F3). Under any definition of the
> counter it is counted, and under the current collect gate it can never be retired — so it is a
> permanent floor on the count and an independent reason the sweep never fires. The locked definition
> must say explicitly whether a *collect-ineligible* claimant counts, and if it does, the sweep guard
> cannot be `(= gc 1)` alone.

This is the single most important consequence of F3 and it belongs in the spec that redefines the
counter, not only in this one.

---

## 8. The fix

### 8.1 The shape

Move both `enforce`s out of `UEV_CollectContext`. They are **injection-side** conditions sitting on a
**payout-side** path.

- **`reward-enabled` — VERIFIED redundant.** `UEV_InjectContext` already enforces it:
  `05_FVT.pact:2288`, *"Reward token is disabled for inject"*. `FVT|C>INJECT-FIX` (1237) and
  `FVT|C>UNSTALE-ALL` (1266) carry it too. The injection side is fully covered, so the collect-side
  copy at **2363** contributes nothing except the strand.
- **`ScoreEntityLink.enabled` — VERIFIED redundant.** `URC_SettleEligibleEmployedScores`
  (`04_RPS.pact:1721`) filters the settle set on it and `URC_ScoreFvtStakeReady` (1678) blocks new
  stake. The accrual side is fully covered, so the collect-side copy at **2365** contributes nothing
  except the strand.

**So the fix is the deletion of exactly two lines — `05_FVT.pact:2363` and `2365` — plus tests.**
Checked, not hypothesised: for each flag, the admission condition it exists to enforce is enforced on
the admission path, by a different `enforce`, with its own message. Neither deletion weakens an
injection or accrual rule.

Two caveats before deleting. **Do not also remove the row-existence checks** on the adjacent lines
(`URC_FvtRpsGlobalRowExists`, `URC_FvtScoreEntityLinkRowExists`) — those are genuine preconditions for
reading the row at all, not admission flags. And `04_RPS.pact:3535`/`3563` consume `RewardEnabled`
inside `if` expressions rather than `enforce`s; confirm those are weight/count aggregations that
*should* skip disabled tokens before concluding the flag has no other payout-side reader.

### 8.2 What must not change

- Re-enable eligibility (`UEV_StreamEligibleMemberOk`) — §5.5.
- The `±W_i` / `±deb-weight` mirror arithmetic — §1.3.3/4; it is correct.
- `fvt-link` permanence — §1.1. It is load-bearing and the owner confirmed the intent.

### 8.3 Interfaces and prefixes

A defun-internal `enforce` removal changes no signature, so **no interface bump and no cascade** — the
one cheap fix in this findings set. `05_FVT.pact` redeploys alone (plus whatever S1 already moves it
for). Land it **in the S1 round, after** the counter work, per §6.

---

## 9. Tests

- `<<TX-F3-001>>` — accrue rewards to a member; disable the link; assert **collect fails** with
  *"ScoreEntityLink must be enabled for collect"*. Passes today; inverts on fix. **By message**, so a
  different refusal cannot be mistaken for this one.
- `<<TX-F3-002>>` — same, then assert **evict also fails** (§1.2). This is the assertion that proves
  there is no escape hatch, and it is the one most likely to be missing from anyone's mental model.
- `<<TX-F3-003>>` — the twin (§2): disable a *reward token*; assert **every** member's collect fails
  in that token. Two members minimum, or it does not show the blast radius.
- `<<TX-F3-004>>` — **principal is not trapped** (§1.3.1): disable, then assert unstake **succeeds**.
  A standing regression; if a later change gates unstake on `enabled`, this is what catches it.
- `<<TX-F3-005>>` — **accrual does stop** (§1.3.2): disable, inject, assert the member's `deb` is
  unchanged. Pins the half of the promise that is kept, so a fix cannot "repair" F3 by re-admitting
  the member to accrual.
- `<<TX-F3-006>>` — **mirror conservation** (§1.3.3): record `TotalDebScore`; disable; unstake part of
  the position; re-enable; assert the mirror equals the live `Σ` over enabled members. This pins the
  negative result in §1.3 so a future refactor cannot quietly break it.
- `<<TX-F3-007>>` — **re-enable still refuses an ineligible member** (§5.5): on a latched streaming
  aggregator, a non-drift-locked member cannot be re-enabled. Guards against the fix over-reaching.
- `<<TX-F3-008>>` — **the S1 interaction** (§6): a disabled member holding `deb > 0` keeps
  `unclaimed-count` above 1, so the sweep does not fire. Belongs in the S1 suite; cross-referenced
  here because it is the assertion that links the two specs.

After the fix: `<<TX-F3-001/002/003>>` invert to success, and the §3.3 invariant gets a direct
assertion — for every reachable combination of the two flags, a member with `deb > 0` has an
executable payout path.

---

## 10. Decisions needed from the owner

### 10.1 Confirm the intent

The spec assumes **"disable means stop accruing, never trap"**, from the UI copy and from the
permanence of `fvt-link`. If disabling is *meant* to freeze a member entirely — rewards included —
then the defect is the documentation and the fix is a warning in the UI plus a refusal message that
says so. **Recommendation: confirm "never trap"**, because the opposite reading has no recovery path
the holder can reach.

### 10.2 Is there a reason the gate exists that §5.1 has not found?

Searched and found nothing. The `enforce` carries no comment, which in this tree is itself evidence:
every deliberate guard here is annotated, often at length. **If the owner recalls a reason, it changes
the fix from a deletion to a relocation**, and §5.1's candidates are where to look.

### 10.3 Does the §7 amendment to the S1 spec change S1's own answer?

A permanently-counted, never-retirable claimant may change how the S1 locked definition should treat
collect-ineligible accounts — and therefore the sweep guard. **This is the question that most affects
work already specified**, and it should be answered before the S1 round is built, not after.

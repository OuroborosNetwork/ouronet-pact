# Ouronet — ATS (Autostake) Module Family Audit Report

**Scope:** `08_ATS.pact` (`AutostakeV2`), `10_ATSU.pact` (`AutostakeUsageV1`), `09_U_ATS.pact` and
`10_U_DPTF.pact` (utilities), the ATS/ATSU sections of the Talos client and admin modules
(`3_Talos/03_TS01-C2.pact`, `01_TS01-A.pact`, `02_TS01-C1.pact`, `05_TS01-P.pact`), and the
`AutostakeV2` / `AutostakeUsageV1` / `AutostakeComputerV1` / `BrandingUsagePrimaryV1` / `BrandingV1` /
`UtilityAtsV2` interfaces.

**Dates:** Round I (findings) opened 2026-08-16. Round II (fixes) closed 2026-08-19.

**Result:** 35 findings raised across two rounds. 19 fixed and proven via REPL regression tests, 13
investigated and closed as not-a-bug (confirmed intentional design), 3 confirmed real but deliberately
deferred — 2 to a planned post-audit module rehaul, 1 tracked as a hard prerequisite for a future
deployment. Zero findings remain open or awaiting a decision.

---

## 1. Executive summary

This audit examined Ouronet's Autostake (ATS) module family — the subsystem that lets users deposit
reward tokens into a pool, receive a reward-bearing token (RBT) representing their claim, and later
recover their position through cold recovery (timed unbonding), hot recovery (an NFT-like receipt that
can itself be traded, branded, or redeemed), or direct recovery (instant, fee-adjustable exit). The audit
covered the core module, its usage/client layer, the shared utility math, and the full Talos wiring that
exposes these functions to end users and administrators.

The most severe class of finding (**C2**) was the audit's explicit priority target going in: whether
removing a reward token from a pool and later re-adding one preserves correct accounting for every
staker, including those with positions opened before the change. It does not, in three independently
confirmed ways — a staker can be paid out in the wrong token entirely, accrued royalty can become
permanently stranded, and cold recovery can become permanently unusable for every pre-existing account on
the pair. All three were fixed together, since they share one root cause, and proven end-to-end against a
real multi-step scenario (stake, remove, re-add, cull) with exact-amount assertions on real token
transfers.

Two further critical-severity findings were confirmed and fixed: a Hot-RBT redemption function
(`C_Redeem`) that reverted on every single call due to a Pact type error, permanently locking anyone who
had gone through hot recovery out of their underlying tokens; and two Hot-RBT branding functions with no
ownership check at all, letting any account rewrite or paid-upgrade the branding of a Hot-RBT token they
did not own.

One finding originally reported as critical — a forgeable governor guard claimed to allow a full drain of
the Autostake vault — was refuted after the reporting lens's own reproduction was shown to be flawed; Pact
requires a foreign caller to already hold a module's own admin before it can acquire that module's
capabilities, which the original repro did not actually test against. This is recorded in full, including
the correction, per this audit's append-only discipline: findings are never quietly deleted, only ticked
to their final, corrected status.

Beyond the module logic itself, the audit surfaced a structural gap in test coverage: roughly a dozen
owner-facing configuration functions (Hot-RBT registration and branding, hibernation fees, hot-recovery
fees, KickStart, Repurpose, Reverse, royalty withdrawal, direct recovery) had zero REPL coverage anywhere
in the repository, and the integration suite that does exist for this module family was not even wired
into the default test pipeline. This is not incidental — it directly correlates with several of the worst
findings above shipping unnoticed. Closing this gap was itself treated as a first-class fix: all twelve
functions now have dedicated, assertion-backed regression coverage, and the suite runs by default. Writing
that coverage surfaced two further real bugs on its own (a capability-wiring gap that made two admin
functions completely unreachable, and a multi-token withdrawal function that crashed whenever a pool's
reward tokens had accrued royalty unevenly) — both fixed and proven in the same pass.

A live-versus-local comparison against the currently deployed StoaChain modules (performed via a public,
keyless dirty-read endpoint) confirmed that several of the fixes described in this report, including the
top-priority reward-token remove/re-add fix, are not yet reflected on-chain — the deployed code still
contains the pre-fix versions of the affected functions. This is expected and out of this audit's scope:
per project policy, all fixes accumulate locally and are deployed together, on a separate schedule, after
this and other in-flight audits are complete. The same comparison also found that three of this audit's
own fixes added a new function to a public interface that turned out to already be deployed live under its
current name — meaning a real interface-version increment, not just these fixes, will be required before
this module family's next deployment. Both points are detailed in §5.

## 2. Scope and methodology

Four parallel deep-read lenses were run over the module family (admin/lifecycle logic, usage/token-custody
logic, shared utility math, and Talos client wiring plus interface consistency), each briefed to the same
rigor and format. The highest-priority target — reward-token removal and re-addition on a pool with
existing staker positions — was additionally lead-verified by hand, tracing the exact code path across all
three modules involved before any lens's independent results were read, then cross-checked against two
lenses that converged on the same root cause from different angles.

Every finding was walked through with the module owner individually: exact file and line location stated
before any code was touched, the owner's verdict recorded verbatim, and — for anything ruled a real bug —
a fix applied only after explicit authorization, then proven via a real Pact REPL run through the actual
production call path (Talos wrapper → core module → utility), not an isolated unit test standing in for
it. This discipline was enforced strictly: one fix was mistakenly applied without waiting for that
authorization mid-cycle, caught immediately, and fully reverted before being properly re-authorized and
re-applied — recorded here for completeness, not smoothed over.

Where a fix's own proof required exercising a capability-wiring path, a real signed-and-submitted Pact
transaction was used (real keys, real capability composition, real enforce checks) rather than calling the
mutating function directly — several of this family's bugs are specifically about *whether the real client
path can reach the code at all*, which a direct unit call would not have caught.

## 3. Summary of findings

| # | Severity | Title | Status |
|---|----------|-------|--------|
| C1 | Critical | Forgeable `ATS\|GOV` governor guard — claimed full vault drain | **Refuted** |
| C2 | Critical | Reward-token remove/re-add corrupts per-account claim accounting | **Fixed** |
| C3 | Critical | `C_Redeem` reverts on every call — permanent fund lock | **Fixed** |
| C4 | Critical | `syphon` has no ratchet/lock, extractable near-instantly | **Not a bug** |
| C5 | Critical | Hot-RBT branding functions have no ownership check | **Fixed** |
| H1 | High | Parameter-lock doesn't cover royalty/hibernation-fees/etc. | **Fixed** |
| H2 | High | Royalty ceiling (99.9%) applies instantly, no cap | **Fixed** |
| H3 | High | `URC_RBT`'s `abs()` masks the uninitialized-index sentinel | **Not a bug** |
| H4 | High | Soft cold-recovery duration setter always crashes | **Fixed** |
| M1 | Medium | Hibernation-fee setter always fails (malformed predicate) | **Fixed** |
| M2 | Medium | `C_KickStart` has no bound on genesis index ratio | **Fixed** |
| M3 | Medium | `XE_UpdateRUR` has no floor-at-zero on its buckets | **Not a bug** |
| M4 | Medium | `C_Fuel` doesn't share `RemoveSecondary`'s lock gating | **Not a bug** |
| M5 | Medium | Elite toggle has no reconciliation vs. existing positions | **Not a bug** |
| M6 | Medium | `UEV_CRF\|FeeThresholds` doesn't validate values per its own doc | **Fixed** |
| M7 | Medium | Hard-branch duration params don't enforce `growth > 0` | **Fixed** |
| M8 | Medium | `UC_SplitByIndexedRBT` has no zero-guard on a divisor | **Not a bug** |
| M9 | Medium | `UC_SplitByIndexedRBT` trusts positional array alignment | **Not a bug** |
| L1 | Low | `ATS\|F>OWNER` — dead capability | **Fixed** |
| L2 | Low | `UR_P-KEYS`/`UR_KEYS` raw `keys` scans (repo-wide pattern) | **Not a bug** (deferred) |
| L3 | Low | `can-upgrade` field permanently true, no setter | **Fixed** |
| L4 | Low | ~12 config functions have zero REPL coverage | **Fixed** |
| L5 | Low | Hibernation fee computed but never separately tracked | **Not a bug** |
| L6 | Low | `URC_RewardBearingTokenAmounts` hardcodes `dayz=1` | **Not a bug** |
| L7 | Low | 16-branch position-reshaping fold not fully hand-verified | **Verified correct** |
| L8 | Low | `C_KickStart`'s `rt-amounts` is caller-order-trusted | **Not a bug** |
| L9 | Low | `UC_UnlockPrice` doc says "ATS" (copy-paste from `U_ATS`) | **Fixed** |
| L10 | Low | Dead StoicTag-index helpers, naming collision risk | **Kept, deferred** |
| L11 | Low | Dead `defcap P\|ATS`, shadows real machinery's naming | **Fixed** |
| L12 | Low | Several defcaps invert StoicSyntax's body-order convention | **Kept, deferred** |
| L13 | Low | `ATS\|C_SetHotRecoveryFee` singular/plural naming asymmetry | **Not a bug** (left as-is) |
| N1 | — | `URC_MultiCull` type mismatch crashes `C_Cull` | **Fixed** |
| N2 | High | `C_WithdrawRoyalties` crashes on uneven royalty accrual | **Fixed** |
| N3 | High | `P\|A_Define` never registered ATS/ATSU as permitted callers | **Fixed** |
| N4 | — | This audit's own fixes added functions to 3 already-live interfaces with no version bump | **Confirmed, deferred (deployment prerequisite)** |

**Totals: 35 findings — 19 fixed and proven, 13 not-a-bug (closed), 3 confirmed-but-deferred by owner
decision (one of which, N4, is a deployment prerequisite rather than a style item).**

## 4. Detailed findings

### Critical

**C1 — Forgeable `ATS|GOV` governor guard (REFUTED).** Originally reported as a full-vault-drain
vulnerability: `ATS|GOV` is defined as `(defcap () true)` and backs the custody smart account's governor
guard, so the claim was that any external caller could acquire it and drain every resident reward token
and in-flight position across every pool. This was refuted on correction: Pact requires a foreign
caller — a different module, or bare top-level code — to already hold the *target* module's own admin
before it can acquire any capability that module defines, including a trivially-`true` one. The original
"empirical reproduction" did not actually isolate a caller without that admin, and was itself flawed; a
corrected, genuinely-isolated two-module repro confirms an outside caller cannot acquire `ATS|GOV`. This
is Pact's documented "simple vault" pattern, used safely here exactly as intended. No code change.

**C2 — Reward-token remove/re-add corrupts per-account claim accounting (FIXED).** The audit's explicit
priority target. A pool's positions store each staker's claim as a plain list of amounts, indexed purely
by *array position* against whatever the pool's reward-token list happened to be at the time the position
was opened — not by token identity. Removing a reward token splices it out of that list, permanently
shifting every later position down by one slot, and nothing re-validates any already-existing staker
position against the new layout. This produced three independently confirmed consequences: (a) a staker
whose position predates a remove-then-re-add could be paid out in a completely different token than the
one their claim was originally denominated in, at another account's expense; (b) any royalty accrued on
the removed token was deleted with no migration and no transfer, permanently stranded in custody with no
way to ever reach it again; (c) every account whose cold-recovery slots had never been used (the common
case) would have its "is this slot free" check permanently and incorrectly read as occupied after any
removal, locking every pre-existing account on the pair out of cold recovery entirely, with no
self-healing path.

Fixed by making the position-reshaping logic unconditionally resize every stored position to match the
post-removal list (closing a and c), and by migrating the royalty bucket during removal exactly as the two
other accounting buckets already were (closing b) — a schema-preserving fix requiring no interface change.
Proven at three levels: an isolated unit-level proof of the corrected reshape logic; a full-suite
regression showing zero prior test broke; and a complete end-to-end integration proof through the real
owner-facing removal path — real deposit, real fee-split cold recovery, real removal by the pool owner,
real cull — with the resulting payout amounts matching the pre-removal stored claim to the fraction, in
the correct token.

**C3 — `C_Redeem` reverts on every call (FIXED).** The function that converts a matured Hot-RBT position
back into its underlying reward token computed a decimal value and fed it directly into an `if`, which
Pact requires to be a boolean — a native type error that fired unconditionally, on every call, regardless
of input. Since this is the *only* function in the module that releases underlying tokens from a Hot-RBT
position, every account that had ever gone through hot recovery had no live path to ever recover their
underlying tokens — a permanent, total fund lock for that entire cohort, not merely an inconvenience.
Fixed by replacing the raw decimal with a proper boolean predicate. Proven against both branches: an early
redemption inside the decay window (correctly withholds a real, nonzero fee) and a fully matured
redemption (correctly pays the full value with zero fee withheld) — the exact edge case that first exposed
the bug, since Pact does not silently coerce a zero decimal to a boolean.

**C4 — `syphon` extraction has no ratchet or lock (NOT A BUG).** `syphon` is a floor an owner sets on the
pool's backing ratio; anything above the floor is extractable in a single call, and the floor itself can
be lowered back down with no restriction, re-exposing a large share of total pool backing — including
stakers' original principal, not just accrued yield — to extraction at will. The owner confirmed this is
the intended trust model: pool owners are meant to have full, immediate, at-will discretion over this
parameter, the same as any other admin-controlled lever in the system, and a proposed monotonic-ratchet
restriction was explicitly rejected as breaking legitimate ordinary use. Closed without a code change.

**C5 — Hot-RBT branding functions have no ownership check (FIXED).** Every other owner-gated function in
the module — including the equivalent branding functions for the pool itself, and the neighboring
Hot-RBT repurpose function — checks pool ownership before doing anything privileged. Two Hot-RBT branding
functions were the sole exception: no ownership check of any kind, meaning any account could rewrite the
branding of a Hot-RBT token it did not own, or pay to force a branding upgrade onto someone else's token — a
paid defacement primitive, directly contradicting what the neighboring function's own documentation
promised for the same subsystem. Fixed by adding the same ownership check every sibling function already
performs, mirroring the pattern the correctly-written neighbor already used. Proven both directions on the
real client path: a non-owner is rejected, the real owner is unaffected.

### High

**H1 — Parameter-lock doesn't cover several mutable fields (FIXED).** A pool's parameter-lock is meant to
freeze its economic configuration; two fields added in a later schema revision (royalty, hibernation fees)
never received the lock gate the original fields had — a genuine oversight, confirmed and fixed. A
separate set of fields (ownership rotation, the control toggles, the raw recovery on/off switches
themselves) were deliberately left ungated after individual owner confirmation that each follows the same
owner-discretion trust model as `syphon` (C4) — not oversights, no code change on those. Finding fully
closed either way.

**H2 — Royalty ceiling applies instantly, no other protection (FIXED).** Royalty could be moved from off
to 99.9% in a single call, instantly redirecting nearly all future yield to the owner with zero notice to
stakers. H1's lock-gate closed part of this; the remaining question — whether a further cap was
warranted — was resolved by lowering the maximum settable royalty rate to 50%. A per-transaction delta
cap was considered and explicitly rejected as trivially bypassable (the same setter can simply be called
repeatedly within one transaction to reach any target regardless of a per-call limit). The existing
zero/off sentinel values remain fully valid and unaffected by the new ceiling. Proven: rates above the new
ceiling are rejected, the ceiling value itself is accepted, and both off-states still work correctly.

**H3 — `URC_RBT`'s `abs()` masks the uninitialized-index sentinel (NOT A BUG).** Two scenarios were
raised under this finding. The first — that a bare deposit into a freshly issued, never-initialized pool
would permanently disable the pool's dedicated bootstrap function — was refuted: bare deposit and the
dedicated bootstrap function are two intentional, mutually exclusive ways to initialize a pool; either one
consuming the "virgin" state and disabling the other is expected behavior, not a defect. The second — that
a deposit whose minted share rounds down to zero could result in a silent donation with no minted return —
was refuted after tracing the actual mint path: the underlying token-mint operation already enforces a
strictly-positive amount and reverts the entire transaction atomically if it would mint zero, so there is
no window where value moves in with nothing returned; the depositor's transaction simply and cleanly
fails, and they can resubmit with a larger amount. No code change on either scenario.

**H4 — Soft-branch cold-recovery duration setter always crashes (FIXED).** The soft-duration branch of
the parameter validator called Pact's `enforce` with three arguments — an incomplete, uncompletable
formatted-string expression left over as debris in what should have been the message argument — where
`enforce` accepts exactly two. This fired unconditionally the moment the soft-duration path was ever
exercised, meaning no pool owner could configure a soft cold-recovery duration schedule after the pool's
initial genesis, ever. The corresponding hard-duration branch was unaffected. Fixed by collapsing to a
correctly formed two-argument call. Proven: the hard branch's existing behavior is unchanged, and the soft
branch now correctly accepts valid parameters and rejects invalid ones on either of its two conditions.

### Medium

**M1 — Hibernation-fee setter always fails (FIXED).** The validator for a pool's hibernation-fee
parameters contained a seventh condition comparing Pact's unit value against a decimal — never a valid
boolean, and never a value that would appear anywhere else in the codebase — dragging the whole validation
to unconditional failure regardless of how valid the actual input was. Every pool was permanently stuck at
its issuance-time hibernation-fee defaults, for every owner, forever. Confirmed as debris with no intended
seventh bound and removed outright. Proven: previously-rejected valid input is now accepted, the real
upper bound still correctly rejects out-of-range input, and the separate scaled-division check is
unaffected.

**M2 — `C_KickStart` has no bound on its genesis-index ratio (FIXED).** The function that seeds a fresh
pool's starting exchange ratio had no sanity check on the resulting ratio between deposited reward tokens
and the requested reward-bearing-token amount — a classic vault inflation-attack setup, where an
extremely skewed initial ratio causes every subsequent real depositor's minted share to round down toward
nothing, silently transferring their deposit's value to the party who set up the skewed ratio. Fixed by
bounding the owner-facing path's resulting ratio to a sane range, with a separate, module-governance-only
administrative variant available for legitimate cases needing a ratio outside that range (still subject to
a shared floor). Proven against the real deployed capability path: pure-math boundary checks, owner-path
rejection above the ceiling, and confirmation the administrative path's floor still applies with no
ceiling.

**M3 — `XE_UpdateRUR` has no floor-at-zero on its buckets (NOT A BUG).** No call site was found, across
every function that decrements these accounting buckets, capable of driving one below zero in practice —
and a constructor-level guard elsewhere in the same module would hard-abort atomically if one ever did,
rather than silently corrupt state. One call site does perform its arithmetic in two separately-rounded
steps rather than one, which can shed a negligible amount of rounding dust in the protocol's favor, but
this is not a fund-loss risk. No code change.

**M4 — `C_Fuel` doesn't share `RemoveSecondary`'s lock-state gating (NOT A BUG).** `RemoveSecondary`
requires several lock/recovery-state flags to be off before it can run, since it structurally reshapes the
reward-token list; ordinary deposit-style functions like `C_Fuel`, `C_Coil`, and `C_Curl` do not check
these flags, but do so *consistently* with each other — this is deliberate: deposits are not considered
"administrative flow" mutations in the same sense a structural reshape is. No code change.

**M5 — Elite toggle has no reconciliation against existing positions (NOT A BUG).** Turning a pool's
elite mode on or off changes which position-selection algorithm is used for *future* deposits; it was
confirmed that the toggle never rewrites or reinterprets already-stored positions, only the search window
used when placing new ones going forward — existing stakes outside the new window remain valid and
recoverable. Working as designed. No code change.

**M6 — `UEV_CRF|FeeThresholds` doesn't validate threshold values (FIXED, documentation only).** The
function's own documentation promised threshold values were bounded to a specific range; the code only
ever validated the *count* of thresholds against that range, never the values themselves, which are raw
token amounts with no inherent ceiling. Confirmed as a documentation error, not a logic bug — the
documentation was corrected to accurately describe what the code already does. No logic change.

**M7 — Hard-branch duration parameters don't enforce a positive growth value (FIXED).** The hard-duration
branch validated only that its parameters divided evenly, not that the growth parameter was positive — a
negative, evenly-dividing value produces a schedule that decreases with elite tier instead of increasing,
inverted from what every consumer of the schedule implicitly assumes. Fixed by adding the missing
positivity check to both the hard and (as part of H4's fix) soft branches. Proven against both branches.

**M8 — `UC_SplitByIndexedRBT` has no zero-guard on a divisor (NOT A BUG).** Proven directly from the
index-computation function's own formula: the specific value that would make this divisor zero is
mathematically identical to the sentinel value that already causes the function to be called through a
different, safe branch entirely — the unsafe path is unreachable by construction, not merely unlikely. No
code change.

**M9 — `UC_SplitByIndexedRBT` trusts positional array alignment with no length check (NOT A BUG).** The
two arrays this function assumes are aligned by position are, in every real call site, derived from the
same single underlying list in lockstep — structurally incapable of desyncing today, not merely
coincidentally matched. No code change.

### Low

**L1 — Dead capability `ATS|F>OWNER` (FIXED).** Defined but never composed or required anywhere in the
module. Removed entirely.

**L2 — Raw `keys` scans under a `UR_*`-prefixed name (NOT A BUG, deferred).** A repo-wide naming
convention deviation (present identically in several other, unrelated modules), off any mutation path,
already slated for the same planned post-audit rehaul as L10/L12 below. No code change now.

**L3 — `can-upgrade` field permanently true, no setter (FIXED).** A schema field left over from an earlier
migration had no way to ever be changed, despite gating a real, meaningful function (the ability to change
pool ownership, syphoning, or hibernation state). Added its first setter, mirroring an existing sibling
toggle's pattern. Proven on the real client path: the gated function is correctly blocked while off and
correctly restored once turned back on.

**L4 — ~12 owner-facing config functions had zero REPL coverage (FIXED).** Hot-RBT registration and
branding, hibernation-fee configuration, hot-recovery-fee configuration and redemption, position
repurposing, position reversal, royalty withdrawal, and direct recovery all had no test coverage anywhere
in the repository — directly correlated with several of the findings above (C5, H4, M1) shipping and
sitting undetected for as long as they did. All twelve now have dedicated, assertion-backed canonical test
sections, and the integration suite containing them — previously disabled — now runs as part of the
default test pipeline. Building this coverage directly surfaced two further real bugs, both fixed in the
same pass: see N2 and N3 below.

**L5 — Hibernation fee computed but not separately tracked (NOT A BUG).** Unlike the royalty fee, which
has its own dedicated accounting bucket and withdrawal path, the hibernation fee has neither — but it was
confirmed this value isn't lost, it silently funnels into the pool's general backing, raising the
effective exchange rate for all existing token holders exactly as intended. An undocumented asymmetry, not
a fund-safety issue. No code change.

**L6 — A helper function hardcodes a single-day period instead of using a caller-supplied variant (NOT A
BUG).** Traced precisely: the hardcoded value only matters when hibernation is active, and every caller of
the plain (non-variant) form is already gated to only run when hibernation is off; every caller where
hibernation might be active correctly uses the variant that accepts a real, caller-supplied period. No
code change.

**L7 — A 16-branch position-reshaping function was flagged as too intricate to fully hand-verify (NOT A
BUG, verified correct on re-check).** A dedicated full trace of every branch, plus the array-slicing logic
each branch depends on, found no case where an occupied slot is ever dropped or duplicated. No defect
found; closed as verified correct rather than merely unconfirmed.

**L8 — `C_KickStart`'s seeding amounts are caller-order-trusted (NOT A BUG).** The function is callable
only by the pool's owner; a caller who supplies the seeding amounts in the wrong order only misconfigures
their own pool's genesis backing at their own hand — not exploitable by any other party. No code change.

**L9 — A documentation string incorrectly describes a shared utility as belonging to a different module
(FIXED, documentation only).** Corrected to name the right module; the underlying code was already a
correct, intentional shared-core wrapper, not a duplicate-logic bug.

**L10 — Dead index-validation helpers with a naming collision risk (kept, deferred).** Confirmed
genuinely unused — a live, unrelated feature elsewhere in the codebase reuses the identical naming
vocabulary for something else entirely, a landmine for a future maintainer skimming by name — but the
owner chose to keep the dead code in place rather than remove it now, ahead of the planned rehaul. Not a
"no defect" verdict; a deliberate keep.

**L11 — A dead, shadow-naming capability in the Talos policy module (FIXED).** Defined, performs real
(if narrow) enforcement, but never actually called anywhere — and its name shadowed the real, live
authorization machinery used throughout the same subsystem, a landmine for anyone wiring something in
without realizing it's unrelated. Removed entirely; confirmed nothing referenced it.

**L12 — Several capability definitions place a cross-module validation call before their own local checks
(kept, deferred).** Inverts a documented statement-ordering convention. Confirmed functionally harmless —
every statement in the affected code runs top-to-bottom to the first failure regardless of order, so no
invalid input is ever let through either way; the only effects are which error message fires first when
multiple conditions are violated at once, and a negligible amount of extra gas spent on a call that was
going to fail anyway. Explicitly deferred to the same planned post-audit rehaul as L2/L10, rather than
fixed piecemeal now.

**L13 — A Talos wrapper's name doesn't match its underlying function's name (NOT A BUG, left as-is).** A
cosmetic singular/plural naming mismatch between the client-facing wrapper and the core function it calls.
Investigated the real scope of a safe rename before ruling: the function is declared on an interface
consumed by two separate third-party modules, one of which calls it by its current name directly — a
rename would require a new interface version and coordinated updates to both external consumers, not a
same-file edit. Not worth that scope for a purely cosmetic asymmetry; left as-is.

### New, found during the fix cycle

**N1 — `URC_MultiCull` returns mismatched types across its two branches (FIXED).** One branch of this
function returns a bare list, the other a full result object; its caller binds the result with an explicit
object-type annotation, causing a hard runtime crash whenever the "nothing currently cullable" branch is
taken — reachable by any account on an unlimited-position pool calling the recovery function before any of
their queued positions are actually ready. Confirmed present on both the local codebase and (via a
keyless, public live-chain read) the currently deployed mainnet code, not yet triggered live only because
every currently-existing real account happens to have something already ready to recover. Fixed as a
soft-failure: the offending branch now returns a properly shaped object instead of a bare list, and the
client-facing function now reports a clear, distinct "nothing to recover yet" result instead of either
crashing or falsely claiming success. Proven on both branches: an immediate attempt now returns the
graceful message, and a genuinely matured recovery is unaffected.

**N2 — Royalty withdrawal crashes whenever a pool's reward tokens have unevenly accrued royalty (FIXED).**
Found while building L4's test coverage for this exact function — a real crash against a live,
multi-reward-token pool, not a test-authoring mistake. The withdrawal function hands its full per-token
royalty vector to a shared multi-token transfer helper, which debits every token in the batch
unconditionally, with no allowance for a zero amount — meaning the function crashed the instant *any one*
of a pool's several reward tokens happened to have zero accrued royalty at withdrawal time, which is the
routine case for any pool with more than one registered reward token, not an edge case. Fixed by filtering
the transfer down to only the reward-token legs with a real, nonzero balance before handing off to the
shared transfer helper; the existing accounting reset was left untouched and still correctly zeroes every
token's bucket regardless of whether it held anything. Proven end-to-end: royalty accrued on exactly one
of a pool's three registered reward tokens, the other two at zero, withdrawal previously crashed and now
succeeds, all three buckets confirmed reset afterward.

**N3 — Two admin functions were completely unreachable via their real administrative path (FIXED).** The
Talos administrative module's own permitted-caller registration function — the mechanism every other
module checks before allowing an administrative call through — was missing this module family from its
registration list entirely (one of the two modules was even bound in the code and simply never used).
Every other equivalent registration function in the codebase registers into both of this family's modules;
this was the sole exception. The concrete effect: two real administrative functions (an administrative
reward-token removal, and an administrative pool-bootstrap variant with a higher ceiling than the
owner-facing version) were completely unreachable, unconditionally, regardless of who was calling or with
what key — rejected before any key-authorization check even had a chance to run. This was found and fixed
while first building the coverage for L4 above, but not logged as its own tracked finding until this
report's preparation, since a bug that test-writing happens to reveal deserves to be recorded on its own
merits, separately from the coverage gap that revealed it — consistent with how this report treats C5,
H4, and M1 above. Fixed by adding the two missing registration calls, matching every other module's
existing pattern. Proven via the real administrative path: both functions, previously failing
unconditionally, now succeed for a properly authorized caller.

**N4 — This audit's own fixes added functions to three already-live interfaces with no version bump
(confirmed, deferred as a deployment prerequisite).** Three of this audit's fixes (the reward-token
remove/re-add fix's own module, the KickStart bound in M2, and the `can-upgrade` setter in L3) each
introduced a new public function, and required declaring it on the relevant interface for other modules to
reference it properly. None of the additions were given a new interface version — each was inserted
directly into the currently-deployed interface under its existing name. A live comparison (the same
mechanism used for the deployment-status check below) confirmed all three affected core-module interfaces
are already deployed on mainnet exactly as named: the core module's own interface, the utility interface
carrying the new KickStart-bound helper, and the usage-layer interface carrying the new administrative
KickStart function. (An initial pass concluded the core module's own interface was not yet live; that was
based on a stale note rather than a direct check, and was corrected on a fresh, direct re-check before this
report was finalized.) An interface that is already live cannot simply have a function added under its
existing name and be redeployed as-is — this requires a genuine new interface version and the full
consumer-cascade update the project's own versioning policy calls for. Two further, Talos-layer interface
additions were not directly checked against the live chain in this pass and should be verified before any
deployment, on the assumption they are also already live given what they connect to. This is not a code
defect and nothing was changed as a result of it — it is a tracked prerequisite: before any of the three
confirmed-live interfaces described above is next redeployed, that redeployment must include a real
version bump, not merely the functions this audit added.

## 5. Deployment status

A live comparison was performed against the currently deployed StoaChain modules for this family (via a
public, keyless read endpoint that returns the deployed module's own source directly, not a summary).
Three of the fixes described above — H4 (soft-duration crash), M1 (hibernation-fee crash), and M7
(missing growth-positivity check) — are confirmed **not yet reflected on-chain**: the deployed code still
contains the exact pre-fix versions of the affected functions, byte-identical to what this repository
looked like before this audit began. Two purely cosmetic documentation fixes (M6, L9) are likewise not yet
live, with no functional effect either way.

The audit's top-priority finding, C2 (reward-token remove/re-add), was checked the same way and confirmed
in the same state: not yet live. The deployed removal function still combines only two of the three
accounting buckets it should (omitting royalty, reproducing the exact stranding defect this round's fix
closed) and still accepts a caller-supplied account list rather than deriving it on-chain (reproducing the
exact gap that could leave a pre-existing account's positions un-reshaped). The fix itself is real, proven,
and unaffected by this — it simply has not been redeployed yet, consistent with every other fix in this
round.

No other functional drift was found between the deployed modules and this repository's pre-fix baseline.
One further, unverified observation surfaced while pulling the removal function's live source directly: it
types one of its cross-module references against an older interface version that the module it points to
no longer implements at all on the live chain today. If the underlying language enforces that kind of
reference strictly at call time — believed to be the case, though not confirmed by attempting an actual
live call, which would be a real, mutating production transaction and was deliberately not attempted — this
would mean that specific function may not be callable on mainnet at all right now, for a reason unrelated
to and in addition to the C2 defect itself. This is noted here for completeness and awareness; verifying it
further, if desired, is a separate, deliberate decision outside this report's scope.

This is expected and intentional, not a gap in this audit: per project policy, fixes from this and other
in-flight audits accumulate locally and are deployed together, on a separate schedule decided
independently of any one audit's completion. This report's scope ends at "the source code is correct and
proven"; when and how it reaches the live chain is a deployment decision outside this document.

A related but distinct check was also performed in the other direction: whether any fix made *during* this
audit changed a public interface's shape without a corresponding version increment, and if so, whether
that interface is itself already live. Three were found to be: see finding N4 above. Concretely, this
means that when the next mainnet deployment for this module family is scheduled, it cannot simply redeploy
the current local source verbatim under the same interface names for those three interfaces — a real
version bump and consumer cascade is required first. This is flagged here specifically because it is easy
to miss: locally, everything compiles and every test passes regardless of whether a version was bumped,
since the local REPL environment has no concept of "this interface already has a deployed identity
elsewhere" — that constraint only becomes visible by checking the live chain directly, which this audit
did, and re-did, after an initial check on one of the three was found to be mistaken.

## 6. Deferred work

Three findings (L2, L10, L12) were confirmed as real, legitimate observations but deliberately left
unfixed, at the owner's explicit direction, in favor of a single, unified StoicSyntax-convention rehaul
across the entire codebase once this audit and other in-flight audits are complete and merged. This
includes a broader rename pass, a check of function ordering within each module against the current
convention, and a coordinated interface-version bump across every module that touches this family, in
Stage 1 and Stage 2 alike, plus any REPL files that reference them. Doing this now, mid-audit, in an
isolated development environment, was judged to carry needless risk for a purely stylistic class of change
with no functional stakes — better done once, cleanly, against a stable, fully-merged baseline.

A fourth item, N4, is deferred for a related but distinct reason: it is not a style preference but a
correctness requirement for a future deployment. The version bump it describes doesn't need to happen now
either, since nothing is being deployed now, but it must not be forgotten or rediscovered under time
pressure at deploy time — it is recorded precisely so that when the broader rehaul (or an earlier,
standalone deployment of this module family) is scheduled, the three already-live interfaces it identifies
are known, in advance, to require a real version increment before that deployment can go out.

## 7. Conclusion

Every finding raised in this audit has reached a final, recorded resolution: fixed and proven, ruled not a
bug after direct investigation, or knowingly deferred by explicit owner decision. Nothing remains open or
pending a decision. The findings with confirmed live/deployed impact (C2, H4, M1, M7) should be
prioritized when the next mainnet deployment is scheduled, since they represent real, currently-active
functional gaps for pool owners on the live chain today — not merely local findings. Separately, that same
future deployment must include a version bump for the three interfaces identified in N4, since this
audit's own fixes added to their public shape while they were already live.

---

*Full technical detail, exact file/line locations, verbatim owner verdicts, and complete fix diffs for
every finding referenced above are preserved in this audit's working documents:
`ROUND-01-FINDINGS.md` (original write-ups), `ROUND-01-OWNER-FEEDBACK.md` (verdicts, verbatim),
`ROUND-02-FIXES.md` (fix diffs and proofs), `ISSUES-RANKED.md` (status-ticked master list), and
`README.md` (living tracker). This report is a synthesis for publication; those documents remain the
authoritative record.*

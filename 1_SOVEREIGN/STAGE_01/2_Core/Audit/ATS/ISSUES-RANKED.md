# ATS Audit — issues, original order, status-ticked

The **original** ranked list (#1C → #31L, as first published) — nothing removed, nothing renumbered.
Each item is ticked **[FIXED]** / **[NOT A BUG]** / **[ONGOING]** per its current status. New items
discovered after the original list was published are appended at the end (#32+), not inserted, so the
original numbering never shifts. Cross-reference `README.md` (status tracker), `ROUND-01-FINDINGS.md`
(full write-ups), `ROUND-01-OWNER-FEEDBACK.md` (verdicts), `ROUND-02-FIXES.md` (fix diffs + proofs).

#1C — [NOT A BUG] — ATS|GOV is (defcap () true) and is wired as the ATS custody smart account's governor guard — forgeable by any caller, full drain of the Autostake vault. Empirically reproduced in an isolated Pact 5.4 REPL. (Same pattern also present on VST|GOV/LIQUID|GOV/ORBR|GOV/SWP|GOV, outside ATS scope.)
　　→ **REFUTED**, owner correction 2026-08-16, independently re-verified: Pact requires a foreign caller to hold the target module's own admin before acquiring its capability. `ATS|GOV` is `StoicSyntax.md §14.5`'s documented, safe "Simple vault" pattern — not forgeable from outside `08_ATS.pact`. See `ROUND-01-OWNER-FEEDBACK.md`.

#2C — [FIXED] — Reward-token remove-then-re-add corrupts per-account claim accounting — three confirmed sub-bugs: (a) cull payouts can pay a staker in the wrong token entirely; (b) royalty balances are permanently stranded on removal; (c) cold recovery becomes permanently unusable for every pre-existing account on the pair. The audit's flagged highest-priority mechanic.
　　→ **FIXED AND PROVEN**, 2026-08-16 (`ROUND-02-FIXES.md` Fix #1). Schema-preserving, no interface/schema change. `UC_ReshapeUnstakeObject` now unconditionally resizes (closes a+c); `X_RemoveSecondary` now self-derives the complete account list on-chain instead of trusting caller input, and migrates the royalty bucket like the other two (closes b). Proven at 3 levels: unit test (isolated reshape logic), full-suite regression (zero failures), and full end-to-end integration proof through the real Talos owner-removal path with real Coil/ColdRecovery/Cull and real DPTF transfers — exact-amount assertions matched bit-for-bit.

#3C — [FIXED] — C_Redeem passes a :decimal where Pact's if requires :bool — every call reverts. Permanent fund lock: no one who went through C_HotRecovery can ever get their RT back.
　　→ **FIXED AND PROVEN**, 2026-08-16 (`ROUND-02-FIXES.md` Fix #2). Verified under *correct* preconditions before touching any code, per owner instruction — 3 independent checks, including an empirical run that first surfaced an unrelated REPL-fixture date bug (2 years in the past) before a corrected run confirmed the real defect under honest, forward-moving time. Fix: `have-fee-rts:bool (!= are-fee-rts 0.0)` replaces the raw decimal fed into `if`. Canonical `REPL/Stage_01/[6.6]_ATS.repl`'s dead "Redeem Test" section rewritten (was: call commented out, `C_Reverse` substituted, wrong date) into two real, assertion-backed regressions: an early fee-bearing redeem (paid 111.0 of 120.0 full value) and a fully-matured zero-fee redeem (paid exactly 60.0 of 60.0). 19/19 assertions green.

#4C — [NOT A BUG] — syphon floor has no monotonicity/lock/timelock — owner can re-lower it and extract ~95%+ of total pool RT backing (principal + yield, commingled) in a single call.
　　→ **NOT A BUG**, owner confirmation 2026-08-17: full at-will discretionary control over syphon (bounded only by >= 0.1) is the intended design — stakers trust the pool owner with this parameter, same as any other admin-controlled lever. Proposed monotonic-ratchet fix explicitly rejected (0.6 → 0.5 must remain a legitimate ordinary adjustment). No timelock/notice-period alternative requested either. Closed without a code change. Narrows H1 (#6H below) — drop the "gate syphon behind parameter-lock" piece of its fix direction; H1's other parameters remain open.

#5C — [FIXED] — C_HOT-RBT|UpdatePendingBranding/UpgradeBranding have no owner/entity-linkage check at all — anyone can rewrite or paid-upgrade branding on a Hot-RBT token they don't own.
　　→ **FIXED AND PROVEN**, 2026-08-17 (`ROUND-02-FIXES.md` Fix #3). New `ATS|C>HOT-RBT-BRD` capability (08_ATS.pact, ~line 519) mirrors the already-correct `ATS|C>REPURPOSE-HOT-RBT` sibling: resolves the owning pair from the hot-rbt id, checks real ownership, then composes ATS|GOV (which remains legitimately necessary — confirmed the full DPOF-ownership chain before fixing). Both functions now call UEV_IMC + this cap instead of a bare ATS|GOV. Proven both directions on the real Talos path: non-owner rejected, real owner unaffected.

#6H — [FIXED / CLOSED] — Parameter-lock protects cold/hot/direct fee-schedule config but not royalty, syphon, hibernation-fees, ownership rotation, or the recovery on/off switches themselves.
　　→ **CLOSED**, 2026-08-17 (`ROUND-02-FIXES.md` Fix #4). Owner ruled per-field after a full schema walkthrough: royalty-promile and peak-hibernate-promile/hibernate-decay were V2 additions that never got the lock gate — oversight, fixed (both caps require UEV_ParameterLockState atspair false as their first check). syphon confirmed intentionally exempt (#4C). owner-konto (RotateOwnership), can-change-owner/syphoning/hibernate (Control), and the 3 recovery on/off switches themselves — owner confirmed these **stay as-is** too, same "owner discretion, stakers trust the owner" model. No code change on those; finding fully closed.

#7H — [PARTIALLY FIXED] — Royalty ceiling (99.9%) applies instantly — no lock, no timelock, no per-tx delta cap.
　　→ **PARTIALLY FIXED**, 2026-08-17, via #6H/Fix #4 — lock-gate applied. The delta-cap/notice-window half of this finding was never asked about separately and remains open if wanted.

#8H — [ONGOING] — URC_RBT's abs() masks the -1.0 "uninitialized index" sentinel — Coil/Curl can bootstrap a virgin pool before KickStart, permanently locking out KickStart and opening a genesis inflation-attack / zero-mint-donation path.

#9H — [ONGOING] — UEV_ColdDurationParameters soft branch calls enforce with 3 arguments (Pact's enforce takes exactly 2) — Soft cold-recovery duration can never be set after pair genesis.

#10M — [ONGOING] — UEV_HibernationFees has a malformed (= () 0.0) term — C_SetHibernationFees always fails; independently found by two lenses.

#11M — [ONGOING] — C_KickStart has no sanity bound on rt-amounts : rbt-request-amount ratio — classic vault inflation-attack setup (relates to #8H).

#12M — [ONGOING] — XE_UpdateRUR has no floor-at-zero on any of its three buckets (resident/unbonding/royalty); backstopped today by a constructor-level enforce (>= 0.0), but no defense-in-depth at the source.

#13M — [ONGOING] — C_Fuel doesn't gate on the same lock-state flags RemoveSecondary requires — inconsistent application of the "don't mutate mid-administrative-flow" concept.

#14M — [ONGOING] — Elite-mode toggle switches the position-selection algorithm on already-populated ledger rows with no reconciliation check.

#15M — [ONGOING] — UEV_CRF|FeeThresholds never validates threshold values, despite its own @doc promising a [1,100] bound.

#16M — [ONGOING] — Hard-branch cold-recovery duration params never enforce growth > 0 — a negative, evenly-dividing growth produces a monotonically decreasing duration schedule.

#17M — [ONGOING] — UC_SplitByIndexedRBT has no zero-guard on resident-sum — reachable division-by-zero abort (DoS on preview/quote flows).

#18M — [ONGOING] — UC_SplitByIndexedRBT trusts resident-amounts/rt-precisions positional alignment with no length-parity guard (math itself verified exact; this is a missing input-validation backstop — same neighborhood as #2C but not touched by that fix).

#19L — [ONGOING] — ATS|F>OWNER — dead capability, never composed anywhere.

#20L — [ONGOING] — UR_P-KEYS/UR_KEYS perform raw keys scans under a UR_* prefix (repo-wide convention, not ATS-specific; off the execution path).

#21L — [ONGOING] — can-upgrade schema field is permanently true with no setter — V1→V2 migration vestige.

#22L — [ONGOING, partially improved] — Hot-RBT surface + ~12 config C_* functions have zero REPL coverage. Fix #1 added real, assertion-backed coverage for the #2C remove/re-add/cull scenario specifically (in audit-scratch `REPL/_audit_ats_baseline.repl`, not yet migrated into the canonical suite) — the broader gap (Hot-RBT branding, hibernation fees, cold duration, KickStart, etc. still uncovered) remains.

#23L — [ONGOING] — Hibernation fee (CoilData) is computed but never separately tracked/read, unlike royalty-fee's dedicated bucket + exit path — undocumented asymmetry, not a fund-safety bug.

#24L — [ONGOING] — URC_RewardBearingTokenAmounts hardcodes dayz=1 instead of using the WithHibernation caller-supplied day-count variant.

#25L — [ONGOING] — XI_Normalize's 16-branch position-reshaping fold could not be fully hand-verified for "never drops/duplicates a slot" — flagged, not a confirmed defect.

#26L — [ONGOING] — C_KickStart's rt-amounts array is caller-order-trusted against the reward-token list, no name-based matching.

#27L — [ONGOING] — U_DPTF's UC_UnlockPrice @doc says "ATS" (copy-paste) — should say "DPTF"; the code itself is a correct shared-core wrapper, not a duplicate-logic bug.

#28L — [ONGOING] — UC_IzStoicTagIndexChar/UC_IzStoicTagIndex/UEV_StoicTagIndex are dead code with zero callers, and collide in name with the live, unrelated CODEX StoicTag feature.

#29L — [ONGOING] — defcap P|ATS in 05_TS01-P.pact is dead code (never called) that shadows the naming of the real P|ATS|CALLER machinery — a landmine, not itself exploitable.

#30L — [ONGOING] — Several ATSU master defcaps place a bare-ref validation call before local enforces, inverting StoicSyntax's body-order convention — style only.

#31L — [ONGOING] — Talos names the wrapper ATS|C_SetHotRecoveryFee (singular) while the core function is C_SetHotRecoveryFees (plural) — cosmetic naming asymmetry only.

---

## New, appended after the original list (not renumbered into it)

#32N — [ONGOING, new] — URC_MultiCull (10_ATSU.pact) returns a raw [decimal] list on its "nothing cullable yet" branch but an object on the cullable branch — XI_MultiCull's `:object` type annotation makes this a hard runtime crash. Reachable by any account on a `positions = -1` ("unlimited") pool calling C_Cull before any P0 entry reaches its cull-time. Found and reproduced 2026-08-16 while building #2C's end-to-end fix proof — recorded as finding N1 in `ROUND-01-FINDINGS.md`. Not fixed, tracked separately, out of scope for the #2C fix it surfaced during.

---

## Tally

- **FIXED:** 4 (#2C, #3C, #5C, #6H — #6H closed: 2 fields fixed, rest confirmed intentional, nothing left pending)
- **PARTIALLY FIXED:** 1 (#7H — royalty lock-gate applied; delta-cap/notice-window sub-question never separately asked, not pursued)
- **NOT A BUG:** 2 (#1C — refuted, #4C — design confirmed)
- **ONGOING:** 24 original items + 1 new (#32N) = 25

# ATS Audit — issues ranked highest to lowest

Continuous ranking #1 (highest) → #30 (lowest), letter = severity class (C=Critical, H=High, M=Medium,
L=Low). Cross-reference README.md's status tracker (module/verify-tag/verdict) and ROUND-01-FINDINGS.md
(full location/failure-scenario/fix-direction detail) for the same IDs without the sequential number.

> **Correction, 2026-08-16:** the original #1 (`ATS|GOV` "forgeable governor guard, full vault drain") was
> **REFUTED** by the owner and independently re-verified (Pact requires a foreign caller to hold the
> target module's admin before acquiring its capability — `ATS|GOV` is the documented, safe
> `StoicSyntax.md §14.5` "Simple vault" pattern, not forgeable). Removed from this ranked list. Full
> detail: `ROUND-01-OWNER-FEEDBACK.md`. Everything below is renumbered accordingly; original finding IDs
> (C2-C5, H1-H4, ...) are kept as-is for traceability against `ROUND-01-FINDINGS.md`.

#1C — FIXED ✅ (ROUND-02-FIXES.md Fix #1) — Reward-token remove-then-re-add corrupts per-account claim accounting — three confirmed sub-bugs: (a) cull payouts can pay a staker in the wrong token entirely; (b) royalty balances are permanently stranded on removal; (c) cold recovery becomes permanently unusable for every pre-existing account on the pair. The audit's flagged highest-priority mechanic. Schema-preserving fix landed 2026-08-16; unit-proof + full-suite re-run green; end-to-end integration regression still TODO. [C2]
#2C — C_Redeem passes a :decimal where Pact's if requires :bool — every call reverts. Permanent fund lock: no one who went through C_HotRecovery can ever get their RT back. [C3]
#3C — syphon floor has no monotonicity/lock/timelock — owner can re-lower it and extract ~95%+ of total pool RT backing (principal + yield, commingled) in a single call. [C4]
#4C — C_HOT-RBT|UpdatePendingBranding/UpgradeBranding have no owner/entity-linkage check at all — anyone can rewrite or paid-upgrade branding on a Hot-RBT token they don't own. [C5]
#5H — Parameter-lock protects cold/hot/direct fee-schedule config but not royalty, syphon, hibernation-fees, ownership rotation, or the recovery on/off switches themselves (relates to #3C). [H1]
#6H — Royalty ceiling (99.9%) applies instantly — no lock, no timelock, no per-tx delta cap. [H2]
#7H — URC_RBT's abs() masks the -1.0 "uninitialized index" sentinel — Coil/Curl can bootstrap a virgin pool before KickStart, permanently locking out KickStart and opening a genesis inflation-attack / zero-mint-donation path. [H3]
#8H — UEV_ColdDurationParameters soft branch calls enforce with 3 arguments (Pact's enforce takes exactly 2) — Soft cold-recovery duration can never be set after pair genesis. [H4]
#9M — UEV_HibernationFees has a malformed (= () 0.0) term — C_SetHibernationFees always fails; independently found by two lenses. [M1]
#10M — C_KickStart has no sanity bound on rt-amounts : rbt-request-amount ratio — classic vault inflation-attack setup (relates to #7H). [M2]
#11M — XE_UpdateRUR has no floor-at-zero on any of its three buckets (resident/unbonding/royalty); backstopped today by a constructor-level enforce (>= 0.0), but no defense-in-depth at the source. [M3]
#12M — C_Fuel doesn't gate on the same lock-state flags RemoveSecondary requires — inconsistent application of the "don't mutate mid-administrative-flow" concept. [M4]
#13M — Elite-mode toggle switches the position-selection algorithm on already-populated ledger rows with no reconciliation check. [M5]
#14M — UEV_CRF|FeeThresholds never validates threshold values, despite its own @doc promising a [1,100] bound. [M6]
#15M — Hard-branch cold-recovery duration params never enforce growth > 0 — a negative, evenly-dividing growth produces a monotonically decreasing duration schedule. [M7]
#16M — UC_SplitByIndexedRBT has no zero-guard on resident-sum — reachable division-by-zero abort (DoS on preview/quote flows). [M8]
#17M — UC_SplitByIndexedRBT trusts resident-amounts/rt-precisions positional alignment with no length-parity guard (math itself verified exact; this is a missing input-validation backstop, flagged given its proximity to #1C's theme). [M9]
#18L — ATS|F>OWNER — dead capability, never composed anywhere. [L1]
#19L — UR_P-KEYS/UR_KEYS perform raw keys scans under a UR_* prefix (repo-wide convention, not ATS-specific; off the execution path). [L2]
#20L — can-upgrade schema field is permanently true with no setter — V1→V2 migration vestige. [L3]
#21L — Hot-RBT surface + ~12 config C_* functions have zero REPL coverage; the one test section that does walk the #1C remove/re-add/cull sequence computes its output into a never-printed list, so it asserts nothing. [L4]
#22L — Hibernation fee (CoilData) is computed but never separately tracked/read, unlike royalty-fee's dedicated bucket + exit path — undocumented asymmetry, not a fund-safety bug. [L5]
#23L — URC_RewardBearingTokenAmounts hardcodes dayz=1 instead of using the WithHibernation caller-supplied day-count variant. [L6]
#24L — XI_Normalize's 16-branch position-reshaping fold could not be fully hand-verified for "never drops/duplicates a slot" — flagged, not a confirmed defect. [L7]
#25L — C_KickStart's rt-amounts array is caller-order-trusted against the reward-token list, no name-based matching. [L8]
#26L — U_DPTF's UC_UnlockPrice @doc says "ATS" (copy-paste) — should say "DPTF"; the code itself is a correct shared-core wrapper, not a duplicate-logic bug. [L9]
#27L — UC_IzStoicTagIndexChar/UC_IzStoicTagIndex/UEV_StoicTagIndex are dead code with zero callers, and collide in name with the live, unrelated CODEX StoicTag feature. [L10]
#28L — defcap P|ATS in 05_TS01-P.pact is dead code (never called) that shadows the naming of the real P|ATS|CALLER machinery — a landmine, not itself exploitable. [L11]
#29L — Several ATSU master defcaps place a bare-ref validation call before local enforces, inverting StoicSyntax's body-order convention — style only. [L12]
#30L — Talos names the wrapper ATS|C_SetHotRecoveryFee (singular) while the core function is C_SetHotRecoveryFees (plural) — cosmetic naming asymmetry only. [L13]

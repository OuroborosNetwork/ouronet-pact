# ATS Audit — issues ranked highest to lowest

Continuous ranking #1 (highest) → #31 (lowest), letter = severity class (C=Critical, H=High, M=Medium,
L=Low). Cross-reference README.md's status tracker (module/verify-tag/verdict) and ROUND-01-FINDINGS.md
(full location/failure-scenario/fix-direction detail) for the same IDs without the sequential number.

#1C — `ATS|GOV` is `(defcap () true)` and is wired as the ATS custody smart account's governor guard — forgeable by any caller, full drain of the Autostake vault. Empirically reproduced in an isolated Pact 5.4 REPL. (Same pattern also present on `VST|GOV`/`LIQUID|GOV`/`ORBR|GOV`/`SWP|GOV`, outside ATS scope.)
#2C — Reward-token remove-then-re-add corrupts per-account claim accounting — three confirmed sub-bugs: (a) cull payouts can pay a staker in the wrong token entirely; (b) royalty balances are permanently stranded on removal; (c) cold recovery becomes permanently unusable for every pre-existing account on the pair. The audit's flagged highest-priority mechanic.
#3C — `C_Redeem` passes a `:decimal` where Pact's `if` requires `:bool` — every call reverts. Permanent fund lock: no one who went through `C_HotRecovery` can ever get their RT back.
#4C — `syphon` floor has no monotonicity/lock/timelock — owner can re-lower it and extract ~95%+ of total pool RT backing (principal + yield, commingled) in a single call.
#5C — `C_HOT-RBT|UpdatePendingBranding`/`UpgradeBranding` have no owner/entity-linkage check at all — anyone can rewrite or paid-upgrade branding on a Hot-RBT token they don't own.
#6H — Parameter-lock protects cold/hot/direct fee-schedule config but not royalty, syphon, hibernation-fees, ownership rotation, or the recovery on/off switches themselves (relates to #4C).
#7H — Royalty ceiling (99.9%) applies instantly — no lock, no timelock, no per-tx delta cap.
#8H — `URC_RBT`'s `abs()` masks the `-1.0` "uninitialized index" sentinel — `Coil`/`Curl` can bootstrap a virgin pool before `KickStart`, permanently locking out `KickStart` and opening a genesis inflation-attack / zero-mint-donation path.
#9H — `UEV_ColdDurationParameters` soft branch calls `enforce` with 3 arguments (Pact's `enforce` takes exactly 2) — Soft cold-recovery duration can never be set after pair genesis.
#10M — `UEV_HibernationFees` has a malformed `(= () 0.0)` term — `C_SetHibernationFees` always fails; independently found by two lenses.
#11M — `C_KickStart` has no sanity bound on `rt-amounts : rbt-request-amount` ratio — classic vault inflation-attack setup (relates to #8H).
#12M — `XE_UpdateRUR` has no floor-at-zero on any of its three buckets (resident/unbonding/royalty); backstopped today by a constructor-level `enforce (>= 0.0)`, but no defense-in-depth at the source.
#13M — `C_Fuel` doesn't gate on the same lock-state flags `RemoveSecondary` requires — inconsistent application of the "don't mutate mid-administrative-flow" concept.
#14M — Elite-mode toggle switches the position-selection algorithm on already-populated ledger rows with no reconciliation check.
#15M — `UEV_CRF|FeeThresholds` never validates threshold *values*, despite its own `@doc` promising a `[1,100]` bound.
#16M — Hard-branch cold-recovery duration params never enforce `growth > 0` — a negative, evenly-dividing `growth` produces a monotonically *decreasing* duration schedule.
#17M — `UC_SplitByIndexedRBT` has no zero-guard on `resident-sum` — reachable division-by-zero abort (DoS on preview/quote flows).
#18M — `UC_SplitByIndexedRBT` trusts `resident-amounts`/`rt-precisions` positional alignment with no length-parity guard (math itself verified exact; this is a missing input-validation backstop, flagged given its proximity to #2C's theme).
#19L — `ATS|F>OWNER` — dead capability, never composed anywhere.
#20L — `UR_P-KEYS`/`UR_KEYS` perform raw `keys` scans under a `UR_*` prefix (repo-wide convention, not ATS-specific; off the execution path).
#21L — `can-upgrade` schema field is permanently `true` with no setter — V1→V2 migration vestige.
#22L — Hot-RBT surface + ~12 config `C_*` functions have zero REPL coverage; the one test section that does walk the #2C remove/re-add/cull sequence computes its output into a never-`print`ed list, so it asserts nothing.
#23L — Hibernation fee (`CoilData`) is computed but never separately tracked/read, unlike royalty-fee's dedicated bucket + exit path — undocumented asymmetry, not a fund-safety bug.
#24L — `URC_RewardBearingTokenAmounts` hardcodes `dayz=1` instead of using the `WithHibernation` caller-supplied day-count variant.
#25L — `XI_Normalize`'s 16-branch position-reshaping fold could not be fully hand-verified for "never drops/duplicates a slot" — flagged, not a confirmed defect.
#26L — `C_KickStart`'s `rt-amounts` array is caller-order-trusted against the reward-token list, no name-based matching.
#27L — `U_DPTF`'s `UC_UnlockPrice` `@doc` says "ATS" (copy-paste) — should say "DPTF"; the code itself is a correct shared-core wrapper, not a duplicate-logic bug.
#28L — `UC_IzStoicTagIndexChar`/`UC_IzStoicTagIndex`/`UEV_StoicTagIndex` are dead code with zero callers, and collide in name with the live, unrelated `CODEX` StoicTag feature.
#29L — `defcap P|ATS` in `05_TS01-P.pact` is dead code (never called) that shadows the naming of the real `P|ATS|CALLER` machinery — a landmine, not itself exploitable.
#30L — Several `ATSU` master defcaps place a bare-ref validation call before local `enforce`s, inverting StoicSyntax's body-order convention — style only.
#31L — Talos names the wrapper `ATS|C_SetHotRecoveryFee` (singular) while the core function is `C_SetHotRecoveryFees` (plural) — cosmetic naming asymmetry only.

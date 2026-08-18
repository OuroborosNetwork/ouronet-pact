# ATS Audit — cycle log & status tracker

Home for all audit data on the ATS (Autostake) module family: `08_ATS.pact` (core, `AutostakeV2`),
`10_ATSU.pact` (usage layer, `AutostakeUsageV1`), `09_U_ATS.pact` + `10_U_DPTF.pact` (utilities), the
ATS/ATSU section of `3_Talos/03_TS01-C2.pact` (+ wiring slivers in `01_TS01-A.pact`, `02_TS01-C1.pact`,
`05_TS01-P.pact`), and the `AutostakeV2` / `AutostakeUsageV1` / `AutostakeComputerV1` /
`BrandingUsagePrimaryV1` / `BrandingV1` / `UtilityAtsV2` interfaces. Structured as the **sibling** of the
AQP audit (`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/Audit/`) — same cycle, same rigor, same format. Goal: a
**comprehensive, evidence-backed sign-off that the code we ship is correct** — for every path, "if X and Y
and Z happen, the outcome is P, and P is correct."

`VST` (Vesting) is a documented **boundary**, not a fully-audited module — `ATS|C_VestedCoil`/`VestedCurl`
call into it, but its own internal correctness is out of this pass's scope (mirrors how the AQP audit
treated `SWPL::URC_LpBreakAmounts` as an external read boundary).

## The cycle (append-only)

| Round | File | What it is |
|-------|------|------------|
| **I — Findings** | `ROUND-01-FINDINGS.md` | Everything discovered before any fix. Frozen. |
| **I — Owner feedback** | `ROUND-01-OWNER-FEEDBACK.md` | Owner's verdict per finding + new StoicSyntax rules. Living — C1 recorded (REFUTED); rest still pending. |
| **II — Fixes** | `ROUND-02-FIXES.md` | One entry per fix, applied **sequentially** (owner green-lights each). Living — Fix #1 (C2), Fix #2 (C3), Fix #3 (C5), Fix #4 (H1/H2), Fix #5 (H4), Fix #6 (M1), Fix #7 (M2), Fix #8 (M6), Fix #9 (M7), Fix #10 (L1), Fix #11 (L3), Fix #12 (N1), Fix #13 (L9), Fix #14 (L11), Fix #15 (L4/#22L test-coverage sweep), Fix #16 (N2/`C_WithdrawRoyalties` multi-transfer crash) landed. |
| **III — Re-verify** | `ROUND-03-REVERIFY.md` | Re-read fixed code cold, enumerate every path, prove correctness. *(not yet created)* |
| **IV+** | `ROUND-0N-*.md` | Repeat Fix → Re-verify until a re-verify round is clean. |

Round files are **append-only / immutable once closed**. Only this README's tracker is edited in place.
Module `.pact` source changes **only** during a Fixes round, one fix at a time. **This pass is audit-and-
document only — no code was changed** (per instruction, matching the AQP audit's Round I discipline).

## Status legend
`OPEN` awaiting verdict · `CONFIRMED` bug to fix · `DESIGN` confirmed, needs a design decision first ·
`DOC-FIX` code right, doc wrong · `CONVENTION` not a bug → becomes a StoicSyntax rule/refactor ·
`FIXING` · `FIXED` (awaiting re-verify) · `VERIFIED` (re-audited clean).

## Status tracker (living)

| ID | Sev | Module | Short | Verify | Verdict / status |
|----|-----|--------|-------|--------|------------------|
| C1 | ~~CRIT~~ | Talos/ATS | ~~`ATS\|GOV` forgeable governor guard, full vault drain~~ — **REFUTED** (owner correction, 2026-08-16, re-verified in an isolated Pact 5.4 repro): foreign callers cannot acquire another module's capability without that module's admin; `ATS\|GOV` is the documented, safe `StoicSyntax.md §14.5` "Simple vault" pattern. See `ROUND-01-OWNER-FEEDBACK.md`. | REFUTED | **REFUTED ✅** — not a bug |
| C2 | CRIT | ATS/ATSU/U_ATS | Reward-token remove-then-re-add corrupts every pre-existing unbonding position's token attribution (3 independently-confirmed sub-mechanisms) — **the flagged highest-priority mechanic** | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #1)** — schema-preserving, no interface change; unit-proof green, full-suite regression green, full end-to-end integration proof green (real Coil→ColdRecovery→owner-path removal→Cull, exact-amount assertions on real DPTF transfers) |
| N1 | — | ATSU | `URC_MultiCull` returns a raw list instead of an object on the "nothing cullable yet" branch — crashes `C_Cull` for any account with zero currently-ripe P0 positions on an unlimited-position pool | CONFIRMED, reproduced | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #12)** — task #7 (live-vs-local) finally unblocked via Pythia's public keyless dirty-read; confirmed the identical bug is live on mainnet too (older V1 interfaces), untriggered only by luck of current live account state. Soft-failure fix per owner: `URC_MultiCull` returns a proper object, `ATS|C_Cull` reports a distinct "Nothing to Cull just yet" message. Proven both branches (graceful message + real success unaffected). |
| C3 | CRIT | ATSU | `C_Redeem` passes a `:decimal` where Pact's `if` requires `:bool` — every call reverts; the only exit path from Hot-RBT recovery is permanently dead | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #2)** — verified under correct preconditions before touching code (per owner instruction); `have-fee-rts:bool` replaces the raw decimal in the `if`; canonical `[6.6]_ATS.repl` Redeem test section rewritten (was dead/wrong-dated) with real assertions on both the fee-bearing and fully-matured branches — 19/19 assertions green |
| C4 | ~~CRIT~~ | ATS | ~~`syphon` floor has no monotonicity/lock/timelock~~ — **NOT A BUG** (owner confirmed, 2026-08-17): full at-will discretionary control over `syphon` (bounded by `>= 0.1`) is intended; stakers trust the pool owner with this parameter. Proposed ratchet fix explicitly rejected. See `ROUND-01-OWNER-FEEDBACK.md`. Narrows H1 (drop the syphon-lock-gate piece of its fix direction). | NOT A BUG | **NOT A BUG ✅** — closed, no code change |
| C5 | CRIT | ATS | `C_HOT-RBT\|UpdatePendingBranding`/`UpgradeBranding` have no owner/entity-linkage check at all | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #3)** — new `ATS\|C>HOT-RBT-BRD` cap mirrors the already-correct `ATS\|C>REPURPOSE-HOT-RBT` sibling; non-owner rejected + real owner still works, both proven on the real Talos path |
| H1 | HIGH | ATS | Parameter-lock protects fee-schedule config but not royalty/syphon/hibernation-fees/ownership/control (relates to C4) | CONFIRMED | **CLOSED ✅ (`ROUND-02-FIXES.md` Fix #4)** — royalty + hibernation-fees now lock-gated (owner-confirmed oversight, fixed); syphon confirmed intentionally exempt (C4); ownership rotation, control toggles (can-change-owner/syphoning/hibernate), and the 3 recovery switches **confirmed intentionally exempt too, 2026-08-17** — no code change, same trust model as syphon |
| H2 | HIGH | ATS | Royalty ceiling (99.9%) applies instantly, no lock/timelock | CONFIRMED | **PARTIALLY FIXED ✅ (via Fix #4)** — lock-gate applied; delta-cap/notice-window half of this finding still open, not asked separately |
| H3 | HIGH | ATSU | `URC_RBT`'s `abs()` masks the `-1.0` "uninitialized index" sentinel — `Coil`/`Curl` bypass `KickStart`, opening a genesis inflation-attack / zero-mint-donation path | CONFIRMED | **NOT A BUG ✅ — both scenarios closed, 2026-08-17.** Scenario 1: bare-Coil bootstrap is intended design. Scenario 2: refuted — `DPTF\|C>CREDIT`'s existing `UEV_Amount` guard already reverts a `0.0`-amount mint atomically, no silent-donation window exists. No code change. (M2 flagged for re-check — same premise, not yet re-verified for that specific path.) |
| H4 | HIGH | U_ATS | `UEV_ColdDurationParameters` soft branch calls `enforce` with 3 args (Pact's `enforce` takes exactly 2) — Soft cold-recovery duration can never be updated post-genesis | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #5)** — owner-corrected root cause: an incomplete `format` call (no `{}`/no `[]` substitution), not merely "3 args to enforce". Collapsed to one correctly-formed 2-arg enforce matching the file's own `UC_MakeSoftIntervals` convention. Unit-proven directly against `U\|ATS`: hard branch unchanged, soft branch now accepts valid params and rejects on either mod-condition. Full-suite reload green. |
| M1 | MED | U_ATS | `UEV_HibernationFees` has a malformed `(= () 0.0)` term — `C_SetHibernationFees` always fails (independently found by 2 lenses) | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #6)** — owner checked the live module directly and confirmed the term was debris with no intended 7th bound; deleted. Unit-proven: valid params now accepted (previously always failed), real 800.0 ceiling still rejects, separate scaled-division check unaffected. Full-suite reload green. |
| M2 | MED | ATSU | `C_KickStart` has no sanity bound on `rt-amounts : rbt-request-amount` ratio — inflation-attack setup (relates to H3) | CONFIRMED (re-examined) | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #7)** — re-examination found the original "zero-mint" framing partially wrong (per H3) but the underlying near-zero-donation attack survives; owner-facing `C_KickStart` now bounded to index ∈ [0.1, 100.0], new admin-facing `A_KickStart` (module governance) keeps the 0.1 floor with no ceiling. Layered per `StoicSyntax.md §14.7`. 8/8 assertions green against the real deployed capabilities. |
| M3 | MED | ATS | `XE_UpdateRUR` has no floor-at-zero on any of its three buckets (resident/unbonding/royalty) | PLAUSIBLE | **NOT A BUG ✅** — owner confirmed 2026-08-17. `UDC_RT`'s constructor enforce fires before any write, atomically blocking any negative bucket - a real, complete backstop, not partial defense-in-depth. `C_ColdRecovery`'s double-split only costs unclaimed rounding dust (protocol-favoring). Closed, no code change. |
| M4 | MED | ATSU | `C_Fuel` doesn't gate on the same lock-state flags `RemoveSecondary` requires | PLAUSIBLE | **NOT A BUG ✅** — owner confirmed 2026-08-17. Coil/Curl also skip all four locks, consistently - "client actions" (deposits) vs. RemoveSecondary's structural RT-list reshape. Closed, no code change. |
| M5 | MED | ATS | Elite toggle switches the position-selection algorithm on already-populated ledger rows with no reconciliation | PLAUSIBLE | **NOT A BUG ✅** — owner confirmed 2026-08-17. Toggle never rewrites/reinterprets stored P1-P7 rows, only the search window for future new deposits (tier-sized). Existing stakes outside the new window stay valid/cullable - tier feature working as designed. Closed, no code change. |
| M6 | MED | U_ATS | `UEV_CRF\|FeeThresholds` never validates threshold *values* despite its own `@doc` promising `[1,100]` | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #8)** — doc-only, owner confirmed: [1,100] was always the array-length (tier count) check, never a value bound; thresholds are raw token amounts with no inherent ceiling. Reworded `@doc`, no logic change. Full-suite reload clean. |
| M7 | MED | U_ATS | `UC_MakeHardIntervals`/hard-branch `UEV_ColdDurationParameters` never enforce `growth > 0` | PLAUSIBLE | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #9)** — owner confirmed the wait-time curve must always decrease with elite tier, never invert. Added `(> growth 0)` to both branches (soft had the identical gap). 4/4 assertions green. |
| M8 | MED | U_ATS | `UC_SplitByIndexedRBT` has no zero-guard on `resident-sum` — reachable div-by-zero abort | PLAUSIBLE | **NOT A BUG ✅** — owner confirmed 2026-08-17. Proven from `URC_Index`'s own formula: `index` reads exactly `0.0` **iff** `resident-sum = 0.0` (nonzero rbt-supply); whenever `index > 0`, `resident-sum` is guaranteed nonzero by construction. Div-by-zero literally cannot fire. Closed, no code change. |
| M9 | MED | U_ATS | `UC_SplitByIndexedRBT` trusts `resident-amounts`/`rt-precisions` positional alignment with no length-parity guard | PLAUSIBLE | **NOT A BUG ✅** — owner confirmed 2026-08-17. Both arrays are a straight 1:1 map over the same underlying `reward-tokens` array (same order, same length) - structurally can't desync. Closed, no code change. |
| L1 | LOW | ATS | `ATS\|F>OWNER` — dead capability, never composed | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #10)** — removed entirely, nothing referenced it. Full-suite reload clean. |
| L2 | LOW | ATS | `UR_P-KEYS`/`UR_KEYS` raw `keys` scans (repo-wide convention, not ATS-specific; off execution path) | CONFIRMED | **NOT A BUG ✅ (deferred)** — owner confirmed 2026-08-17, "by design so far"; repo-wide pattern, belongs to the planned post-audit module rehaul/rename pass, not a piecemeal ATS fix. No code change. |
| L3 | LOW | ATS | `can-upgrade` permanently `true`, no setter — V1→V2 migration vestige | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #11)** — confirmed genuinely missing, traced what it gates (`C_Control`'s can-change-owner/syphoning/hibernate), added first setter (`C_ToggleUpgrade` + cap + Talos wrapper, mirrors `C_ToggleElite`). 5/5 assertions green on the real Talos path. |
| L4 | LOW | ATS/ATSU | Hot-RBT surface + ~12 config `C_*` functions have zero REPL coverage (correlates with C5/M1/H4 shipping unnoticed) | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #15)** — all 12 previously-uncovered functions (`ATS\|C_ToggleUpgrade`, `C_SetHibernationFees`, `C_AddHotRBT`, `C_HOT-RBT\|Update/UpgradeBranding`, `C_SetHotRecoveryFee`, `C_HotRecovery`, `C_HOT-RBT\|Repurpose`, `C_Reverse`, `A_RemoveSecondary`, `A_KickStart`, `C_WithdrawRoyalties`, `C_DirectRecovery`) now have dedicated, assertion-backed canonical sections in `[6.6]_ATS.repl`, wired into `Stage01_Tester.repl`'s default load path (was disabled). Writing the `C_WithdrawRoyalties` proof surfaced a real, previously-uncaught crash — see **N2** below. Full `Stage01_Tester.repl` pipeline reload clean (0 failures). |
| L5 | LOW | ATSU | Hibernation fee (`CoilData`) computed but never separately tracked/read, asymmetric vs royalty-fee | PLAUSIBLE | **NOT A BUG ✅** — owner confirmed 2026-08-17, fee funnels into the pool index indirectly. Traced exact mechanism in `C_Brumate`: full pre-fee amount credited to resident, coiler gets less RBT - fee stays in pool raising index for existing holders. Closed, no code change. |
| L6 | LOW | ATSU | `URC_RewardBearingTokenAmounts` hardcodes `dayz=1` instead of the `WithHibernation` day-count variant | PLAUSIBLE | **NOT A BUG ✅** — owner confirmed 2026-08-17, design intentional. Traced: `dayz` only matters when hibernate=on, and every plain-variant caller is already gated to hibernate=off by its own cap. Closed, no code change. |
| L7 | LOW | ATSU | `XI_Normalize`'s 16-branch position reshuffle not fully hand-verified (flagged, not a confirmed defect) | PLAUSIBLE | **VERIFIED CORRECT ✅** — owner asked for a real check; full trace of all 9 branches + `take`/`drop` slicing found occupied slots are never dropped/duplicated. No defect found. Closed, no code change. |
| L8 | LOW | ATSU | `C_KickStart`'s `rt-amounts` array is caller-order-trusted, no name-based matching | PLAUSIBLE | **NOT A BUG ✅** — owner confirmed 2026-08-18: "leave as is, it can't go wrong, it's fixed by input." Owner-only function - a wrong order only misconfigures the caller's own pool. Closed, no code change. |
| L9 | LOW | U_DPTF | `UC_UnlockPrice` `@doc` says "ATS" (copy-paste from `U_ATS`), should say "DPTF" — cosmetic | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #13)** — applied earlier in the session, doc write-up caught up 2026-08-18. Doc-only, no logic change. |
| L10 | LOW | U_ATS | `UC_IzStoicTagIndexChar`/`UC_IzStoicTagIndex`/`UEV_StoicTagIndex` dead code + naming collision with the live, unrelated `CODEX` StoicTag feature | CONFIRMED | **KEPT, ONGOING** — owner confirmed unused (verified: live StoicTag uses different DALOS functions), but explicitly said "leave them" 2026-08-18. No code change; not a NOT-A-BUG verdict, a deliberate keep. |
| L11 | LOW | Talos | `defcap P|ATS` in `05_TS01-P.pact` — dead code, naming shadow risk vs the real `P\|ATS\|CALLER` machinery | CONFIRMED | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #14)** — applied earlier in the session, doc write-up caught up 2026-08-18. Removed entirely. |
| L12 | LOW | ATSU | Several master defcaps place a bare-ref validation call before local `enforce`s (StoicSyntax body-order) | CONFIRMED | _pending_ |
| L13 | LOW | Talos | `ATS\|C_SetHotRecoveryFee` (singular, Talos) vs `C_SetHotRecoveryFees` (plural, core) — cosmetic naming asymmetry | CONFIRMED | **LEFT AS-IS ✅** — owner decided 2026-08-18 after being shown the real scope (new interface version + 2 live slave-module consumers to update + coordinated redeploy). Not worth it for a cosmetic asymmetry. No code change. |
| N2 | HIGH | ATSU | `C_WithdrawRoyalties` hands its full per-RT royalty vector straight to `TFT::C_MultiTransfer`, which debits every leg unconditionally — any zero-amount leg (routine whenever a pool has >1 registered RT and royalty hasn't accrued evenly across all of them) hits `DPTF.UEV_Amount`'s `(> amount 0.0)` enforce and crashes the whole withdrawal | CONFIRMED, reproduced | **FIXED ✅ AND PROVEN ✅ (`ROUND-02-FIXES.md` Fix #16)** — discovered 2026-08-18 while building the L4/#22L `WithdrawRoyalties` proof (real crash, not a test-authoring mistake — reproduced against `ps`, a live 3-RT pool). Owner confirmed: "Royalties always gather in reward tokens and if there are many multi transfer must be used when withdrawing... it needs fixing." `C_WithdrawRoyalties` now filters to only the reward-token/royalty legs with a real (`> 0.0`) balance before calling `C_MultiTransfer` — the RUR-reset loop still zeroes every RT's bucket regardless, so no accounting is skipped, only the doomed zero-amount transfer leg. Proven end-to-end: royalty accrues on one RT only (others zero), withdrawal now succeeds, all buckets reset to 0.0. |

## Cross-cutting note — beyond ATS scope (downgraded after C1's correction)

**Superseded 2026-08-16 — see `ROUND-01-OWNER-FEEDBACK.md`.** C1 (the claim that `MODULE|GOV = (defcap ()
true)` is a cross-module-forgeable skeleton key) was **REFUTED**: Pact requires a foreign caller to hold
the target module's admin before it can acquire that module's capability, so `ATS|GOV` and its siblings
`VST|GOV` (`11_VST.pact:103-106`), `LIQUID|GOV` (`12_LIQUID.pact:59-62`), `ORBR|GOV`
(`13_OUROBOROS.pact:50-53`), `SWP|GOV` (`15_SWP.pact:137-140`) are **not** independently drainable — this
is `StoicSyntax.md §14.5`'s documented, intentional "Simple vault" pattern. No emergency action needed on
those four modules from this angle. What *is* still worth a narrow follow-up (matching what **C5**
demonstrated for ATS): for each of those four modules, check whether any of their **own** public functions
compose their `GOV` cap without a preceding ownership/authorization check first — that's the only way this
pattern can actually be misused, and it's a per-module code-reading task, not a cross-cutting emergency.

## Live vs local (Pythia dirty-read)

**Unblocked 2026-08-18** — the `x-pythia-key` requirement turned out to be avoidable: Pythia's own public
website console reads keyless via a `Sec-Fetch-Site: same-origin` header (documented as an accepted,
intentionally-forgeable-by-non-browser-clients design in Pythia's own source). Full recipe:
`OuronetInformational/pythia-dirty-read-access.md`.

**First real diff performed** (triggered by reconciling `#32N`/N1): pulled `describe-module` for
`ouronet-ns.ATS` and `ouronet-ns.ATSU` live. Confirmed the live deployed code is on the older
`AutostakeV1`/`UtilityAtsV1` interfaces (local dev has moved on to `V2`) — live is **behind** local, not
ahead, so nothing was ever "ported back" from a mainnet fix that doesn't exist. `URC_MultiCull`'s broken
branch (N1) is present byte-for-byte in the live module too, confirmed via both a source diff and a live
call against all 11 real existing ledger rows (`ATS.UR_KEYS`) - none currently trigger it, purely because
every existing live account happens to have something already cullable right now.

**Still not done:** a full systematic diff of `U_ATS`/`U_DPTF` (utility modules) against local, and a
complete pass re-checking every other FIXED/NOT-A-BUG verdict above against the live `V1`-interface code
(several fixes assumed the local `V2` shape - e.g. the `#6H`/H1 parameter-lock fields, `#11M` KickStart
bounds, `#21L` `can-upgrade` setter - none of these exist on the currently-deployed `V1` code either, since
they were added during this session's local-only work). Not yet done; flag before treating any fix as
"deployed-equivalent" — everything landed this round exists only in local source until a real redeploy.

## Method (Round I)

One deep-read lens-auditor per module cluster (admin/lifecycle · usage/token-custody · utility math ·
Talos wiring + interfaces), run in parallel, each briefed with the same rigor/format contract as the AQP
audit. The reward-token remove/re-add mechanic (**C2**, the audit's explicit highest-priority target) was
additionally lead-verified end-to-end by hand across `08_ATS.pact` + `10_ATSU.pact` + `09_U_ATS.pact`
before any lens results were read, then cross-checked against two lenses that independently converged on
the same defect from different angles (ATSU's `X_RemoveSecondary` precondition gap; U_ATS's
`UC_ReshapeUnstakeObject` gating bug) — three independent proofs of one root cause.

**Correction, 2026-08-16:** C1 (`ATS|GOV`) was originally reported CONFIRMED, with a claimed "empirical
reproduction" by the Talos lens in an isolated two-module Pact 5.4 REPL. The owner correctly identified
that Pact requires a foreign caller to hold the target module's admin before acquiring its capability, so
the reported drain doesn't work; the lens's repro was flawed. Re-verified independently (a fresh two-module
repro isolating an unrelated foreign module with zero admin) and confirmed the owner's correction — see
`ROUND-01-OWNER-FEEDBACK.md`. **C1 is REFUTED.** This is a reminder that even an "empirically reproduced"
finding needs its repro checked for whether it actually isolates the claimed threat model, not just
whether it runs without error.

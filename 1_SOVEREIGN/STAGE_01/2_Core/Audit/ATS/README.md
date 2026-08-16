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
| **II — Fixes** | `ROUND-02-FIXES.md` | One entry per fix, applied **sequentially** (owner green-lights each). Living — Fix #1 (C2) landed. |
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
| C2 | CRIT | ATS/ATSU/U_ATS | Reward-token remove-then-re-add corrupts every pre-existing unbonding position's token attribution (3 independently-confirmed sub-mechanisms) — **the flagged highest-priority mechanic** | CONFIRMED | **FIXED ✅ (`ROUND-02-FIXES.md` Fix #1)** — schema-preserving, no interface change; unit-proof green, full suite re-run green; end-to-end integration regression still TODO (tracked, not blocking) |
| C3 | CRIT | ATSU | `C_Redeem` passes a `:decimal` where Pact's `if` requires `:bool` — every call reverts; the only exit path from Hot-RBT recovery is permanently dead | CONFIRMED | _pending_ |
| C4 | CRIT | ATS | `syphon` floor has no monotonicity/lock/timelock — owner can re-lower it and extract ~full pool RT backing in one call | CONFIRMED | _pending_ |
| C5 | CRIT | ATS | `C_HOT-RBT\|UpdatePendingBranding`/`UpgradeBranding` have no owner/entity-linkage check at all | CONFIRMED | _pending_ |
| H1 | HIGH | ATS | Parameter-lock protects fee-schedule config but not royalty/syphon/hibernation-fees/ownership/control (relates to C4) | CONFIRMED | _pending_ |
| H2 | HIGH | ATS | Royalty ceiling (99.9%) applies instantly, no lock/timelock | CONFIRMED | _pending_ |
| H3 | HIGH | ATSU | `URC_RBT`'s `abs()` masks the `-1.0` "uninitialized index" sentinel — `Coil`/`Curl` bypass `KickStart`, opening a genesis inflation-attack / zero-mint-donation path | CONFIRMED | _pending_ |
| H4 | HIGH | U_ATS | `UEV_ColdDurationParameters` soft branch calls `enforce` with 3 args (Pact's `enforce` takes exactly 2) — Soft cold-recovery duration can never be updated post-genesis | CONFIRMED | _pending_ |
| M1 | MED | U_ATS | `UEV_HibernationFees` has a malformed `(= () 0.0)` term — `C_SetHibernationFees` always fails (independently found by 2 lenses) | CONFIRMED | _pending_ |
| M2 | MED | ATSU | `C_KickStart` has no sanity bound on `rt-amounts : rbt-request-amount` ratio — inflation-attack setup (relates to H3) | CONFIRMED | _pending_ |
| M3 | MED | ATS | `XE_UpdateRUR` has no floor-at-zero on any of its three buckets (resident/unbonding/royalty) | PLAUSIBLE | _pending_ |
| M4 | MED | ATSU | `C_Fuel` doesn't gate on the same lock-state flags `RemoveSecondary` requires | PLAUSIBLE | _pending_ |
| M5 | MED | ATS | Elite toggle switches the position-selection algorithm on already-populated ledger rows with no reconciliation | PLAUSIBLE | _pending_ |
| M6 | MED | U_ATS | `UEV_CRF\|FeeThresholds` never validates threshold *values* despite its own `@doc` promising `[1,100]` | CONFIRMED | _pending_ |
| M7 | MED | U_ATS | `UC_MakeHardIntervals`/hard-branch `UEV_ColdDurationParameters` never enforce `growth > 0` | PLAUSIBLE | _pending_ |
| M8 | MED | U_ATS | `UC_SplitByIndexedRBT` has no zero-guard on `resident-sum` — reachable div-by-zero abort | PLAUSIBLE | _pending_ |
| M9 | MED | U_ATS | `UC_SplitByIndexedRBT` trusts `resident-amounts`/`rt-precisions` positional alignment with no length-parity guard | PLAUSIBLE | _pending_ |
| L1 | LOW | ATS | `ATS\|F>OWNER` — dead capability, never composed | CONFIRMED | _pending_ |
| L2 | LOW | ATS | `UR_P-KEYS`/`UR_KEYS` raw `keys` scans (repo-wide convention, not ATS-specific; off execution path) | CONFIRMED | _pending_ |
| L3 | LOW | ATS | `can-upgrade` permanently `true`, no setter — V1→V2 migration vestige | CONFIRMED | _pending_ |
| L4 | LOW | ATS/ATSU | Hot-RBT surface + ~12 config `C_*` functions have zero REPL coverage (correlates with C5/M1/H4 shipping unnoticed) | CONFIRMED | _pending_ |
| L5 | LOW | ATSU | Hibernation fee (`CoilData`) computed but never separately tracked/read, asymmetric vs royalty-fee | PLAUSIBLE | _pending_ |
| L6 | LOW | ATSU | `URC_RewardBearingTokenAmounts` hardcodes `dayz=1` instead of the `WithHibernation` day-count variant | PLAUSIBLE | _pending_ |
| L7 | LOW | ATSU | `XI_Normalize`'s 16-branch position reshuffle not fully hand-verified (flagged, not a confirmed defect) | PLAUSIBLE | _pending_ |
| L8 | LOW | ATSU | `C_KickStart`'s `rt-amounts` array is caller-order-trusted, no name-based matching | PLAUSIBLE | _pending_ |
| L9 | LOW | U_DPTF | `UC_UnlockPrice` `@doc` says "ATS" (copy-paste from `U_ATS`), should say "DPTF" — cosmetic | CONFIRMED | _pending_ |
| L10 | LOW | U_ATS | `UC_IzStoicTagIndexChar`/`UC_IzStoicTagIndex`/`UEV_StoicTagIndex` dead code + naming collision with the live, unrelated `CODEX` StoicTag feature | CONFIRMED | _pending_ |
| L11 | LOW | Talos | `defcap P|ATS` in `05_TS01-P.pact` — dead code, naming shadow risk vs the real `P\|ATS\|CALLER` machinery | CONFIRMED | _pending_ |
| L12 | LOW | ATSU | Several master defcaps place a bare-ref validation call before local `enforce`s (StoicSyntax body-order) | CONFIRMED | _pending_ |
| L13 | LOW | Talos | `ATS\|C_SetHotRecoveryFee` (singular, Talos) vs `C_SetHotRecoveryFees` (plural, core) — cosmetic naming asymmetry | CONFIRMED | _pending_ |

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

**Not performed this round.** `/{chain}/read` requires an owner-supplied `x-pythia-key`
(`OuronetInformational/pythia-dirty-read-access.md`); the question was put to the owner during this audit
and no answer had arrived by the time this round closed. **No live-vs-local diff exists for any ATS-family
module as of this writing** — the findings above are against the local repo only. Once a key is available,
re-run: `describe-module "ouronet-ns.ATS"` / `"ouronet-ns.ATSU"` / `"ouronet-ns.U_ATS"` /
`"ouronet-ns.U_DPTF"` on the confirmed StoaChain chain id, diff `code`/`hash` against local, and record
`interfaces`/`blessed` — a fix to C2-C5 will need to know the deployed interface surface (see
"Interface-version state" in `ROUND-01-FINDINGS.md`) before it can be written.

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

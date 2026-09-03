# FVT-SPLIT-DESIGN — Phase 0 (design, needs owner approval)

**Task #75.** Split `04_FVT.pact` (module `AQP-FVT`) so every module ships under Kadena's
~150 KB deploy ceiling. Pre-mainnet, so splitting is **cheap now** (no live-data migration);
after first deploy it becomes structurally hard (tables are module-scoped). See
`OuronetInformational/MODULE-SIZING.md`.

## 1. The sizing reality (measured)

| Metric | Value |
|---|---|
| Module bytes | **424,442 (~414 KB)** |
| Lines | 7,249 |
| Kadena deploy cap | ~150 KB |
| Reduction required | **remove ~62%** (get to ≤150 KB) |

A single reduction is not enough — this needs the module to become **~3 modules of ~140 KB each**.

## 2. Byte distribution by data domain (measured, per-defun)

| Bucket | Bytes | % |
|---|---|---|
| RPS-only functions (touch only `RPS|Global/Member/User/Stream`, `ForcedFixCount`) | 49 KB | 11% |
| Structure-only functions (`ScoreEntityLink`, `MultipletFamily`, `MemberVault`, `MemberUserWeight`, `UserPresence`, `AgencyFee`, `QualitySplit`) | 86 KB | 20% |
| Shared / pure-compute / cross-domain orchestration | **288 KB** | **67%** |

**Takeaway:** the naïve "extract RPS" seam removes only 11% → FVT stays ~366 KB. The mass is the
67% of orchestration/compute (URC derivers, UC compute, UEV validators, settle/collect/inject
walks) that spans domains. The seam must cut through *that*, not around it.

## 3. Table inventory (16 tables — the partition anchors)

- **Structure/membership:** `FVT|T` (entity, class-discriminated farm/vault/treasury),
  `ScoreEntityLink`, `MultipletFamily`, `MemberVault`, `MemberUserWeight`, `UserPresence`,
  `AgencyFee`, `QualitySplit`
- **RPS reward-accounting:** `RPS|Global`, `RPS|Member`, `RPS|User`, `RPS|Stream`, `ForcedFixCount`
- **Vacate/sweep:** `VacateFreeze`, `SweepProgress`
- **DSA:** `DsaOracleConfig`

Note: `FVT|T` holds **all three entity kinds** (farm=class 0, vault=class 1, treasury) discriminated
by a class field, so a "Farms / Vaults / Treasuries" split by entity type would require splitting the
shared `FVT|T` table (separate tables per kind) — a data-model change, not a code move.

## 4. Capability-seam check (the go/no-go, per MODULE-SIZING.md §4)

> "If the split forces a capability to cross the boundary, you cut in the wrong place."

Measured: both RPS writers and structure writers **compose the shared `SECURE` cap**. Structure
writers additionally use `FVT|XE>ADMIT`, `FVT|XE>SWEEP`.

`SECURE` is module-scoped, so this is **resolvable, not fatal**, via the existing Ouronet idiom:
each split-out module defines its **own** `SECURE`; the orchestrators that write across the seam
become **`XE_` forward-entrypoints** (start with `P|UEV_IMC`, acquire the *local* SECURE-composing
cap), invoked cross-module via `(ref-M::XE_… )`, with the caller registered as an IMC caller-guard
(`P|A_Define`). This is exactly how DSA, SCORE→FVT, and Talos already compose across modules.

**Coupling is low:** only **13 functions** touch both RPS and structure tables — and most are
orchestrators or test helpers:
`CC_Collect`, `XI_1|FarmSplitInject`, `XI_2|SettleMemberTier2`, `XI_FixUserFvtDebIn`,
`WI_QualitySplit`, `C_IssueMultipletFamily`, `C_SetQualitySplit`, `UR_FVT`, `URH_FvtPresentUsers`,
`UEV_AddRewardLinkContext`, `P|A_Define`, `REPL_BootstrapVault`, `REPL_BootstrapTreasury`.
These become the cross-module call sites.

## 5. Proposed decomposition (3 modules) — for owner review

Because 67% is cross-domain compute, the cut must follow the **reward-settlement pipeline**, not
just table ownership:

1. **`AQP-FVT`** (core structure + entity lifecycle) — owns `FVT|T`, `ScoreEntityLink`,
   `MultipletFamily`, `MemberVault`, `MemberUserWeight`, `UserPresence`, `AgencyFee`,
   `QualitySplit`, `VacateFreeze`, `DsaOracleConfig`; keeps Issue / AddRewardLink / AddScoreEntity /
   RotateOwnership / SetCommonDenominator / QualitySplit / DSA config. Structure caps + own `SECURE`.
2. **`AQP-FVT-RPS`** (reward-per-share accounting) — owns `RPS|Global/Member/User/Stream`,
   `ForcedFixCount`; the ~51 RPS readers/writers + the dense settle/inject/drip math; own `SECURE`;
   exposes `XE_` writers for the coupling orchestrators. This is the densest reward-math block.
3. **`AQP-FVT-SWEEP`** (vacate + anchor-sweep) — owns `SweepProgress` (+ `VacateFreeze` if it seams
   cleanly); the vacate-drain / sweep-revoke paths (already largely re-hosted on MTX-AQP — see
   `SWEEP-VACATE-DESIGN.md`). Candidate to absorb the vacate/sweep byte mass.

Sizes must be **re-measured after each extraction** (`MODULE-SIZING.md` tooling) — the goal is three
modules each < 3,500 lines / < 150 KB with ≥ 1,000-line headroom. If the RPS + SWEEP extractions
don't get core `AQP-FVT` under cap, a further cut (the settle-walk primitives, or the URC derivers
block) is the next seam.

## 6. Interface + deploy-order + cascade

- New interfaces `AcquisitionFarmsVaultsTreasuriesRpsV1`, `…SweepV1`; `AcquisitionFarmsVaults…V2`
  loses the moved members and bumps per the **cascade rule** (every naming interface bumps in
  lockstep — `INTERFACE_VERSIONING.md`). Since pre-mainnet, edit `V1`/`V2` in place is allowed.
- **Deploy order:** leaf-first — `AQP-FVT-RPS` and `AQP-FVT-SWEEP` deploy **before** `AQP-FVT`
  (core calls their `XE_`). Confirm no back-references force a cycle; if a cycle appears, the seam is
  wrong (move it).
- IMC: register `AQP-FVT` (and SCORE/POOL/DSA as needed) as caller-guards on the new modules via
  their `P|A_Define`, in the Sovereign-Executor "Define IMC Policies" TX.

## 7. Phased execution plan (post-approval)

- **P1** — extract `AQP-FVT-RPS` (tables + schemas + 51 fns + own SECURE + XE_ writers); rewire the
  13 coupling orchestrators to `::`; wire IMC; green-gate `Z.repl` + `[6.2.4]` FVT suites. Re-measure.
- **P2** — extract `AQP-FVT-SWEEP` if core is still over cap; re-measure.
- **P3** — interface cascade + deploy-order in `[3]_Talos` / `[2.3]_EarningPools` + Sovereign-Executor.
- **P4** — full green-gate + a fresh top-to-bottom redeploy dry-run (feeds #83).

## 8. Risks

- Cross-module `XE_` calls add IGNIS/gas per hop on the settle/collect hot path — measure against the
  `[6.2.6]` GAS probe; keep hot loops single-module where possible.
- The 67% orchestration mass means the RPS/SWEEP seams may **not** be sufficient alone; P1's
  re-measurement is the real go/no-go for whether a 3rd seam is needed.
- Deploy-order cycles: if core `AQP-FVT` and `AQP-FVT-RPS` mutually call, the seam is misplaced.

**Status: DESIGN — awaiting owner approval on the 3-module boundary before any code moves.**

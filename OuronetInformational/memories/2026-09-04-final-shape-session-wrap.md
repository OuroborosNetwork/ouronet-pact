# 2026-09-04 — Final-shape push: session wrap (red-team readiness)

Large multi-task session driving toward the red-team point ("final shape"). Everything below is on
`main`, green (`Z.repl` 595 / `ZALL.repl` 787), no known deployable defects.

## Structural changes landed
- **#75 FVT→RPS split** — the undeployable 7,527-line `04_FVT` split into `04_RPS` (reward-engine
  leaf, `AcquisitionRewardPerShareV1`, deploys first) + `05_FVT` (client shell, keeps
  `AcquisitionFarmsVaultsTreasuriesV2` + 53 facade re-exports). Pattern + gotchas in
  `2026-09-03-fvt-rps-module-split-pattern.md`.
- **#104 Talos scope-first rename** — every client/admin entrypoint flipped to `<scope-path>|<Prefix>_<op>`
  (455 names, 163 files): `C_DPTF|Issue`→`DPTF|C_Issue`, `C_ATS|HOT-RBT|Repurpose`→`ATS|HOT-RBT|C_Repurpose`,
  etc. Rule = prefix moves before the LAST `|` segment. `C_2|*` (MTX phase steps) left as-is (leading-digit).
- **REPL two-variant rebuild (#106/#107)** — the test infra now = (a) `REPL/ZALL.repl` exhaustive
  top-to-bottom runner + (b) `REPL/modules/*.repl` 26 standalone per-module testers, sharing
  `REPL/deploy-stage00/01/02/zz.repl` cores. Design: `ARCHITECTURE/REPL_TEST_ARCHITECTURE.md`.

## Bugs the exhaustive-testing effort caught & fixed (all real)
1. **MTX-AQP split-IMC gap** (most important) — MTX-AQP's deb-fix/re-score defpacts drive
   `RPS::XE_FvtFixUserChunk/…SweepRecomputeChunk`, but the split registered only FVT/VCT/DSA on RPS's
   IMP, not MTX-AQP → the whole deb-staleness fix path would have failed on-chain. Fixed in MTX-AQP `P|A_Define`.
2. DSP `A_OuroMinterStageOne` returned `[string]` not its declared `[decimal]`.
3. `[6.6]_ATS` called stale `URC_ATS|Coil` (renamed `INFO_ATS|Coil` in the INFO rehaul).
4. STOAICO absolute-conservation → made delta-based (boot-position-independent).
- **Bloodshed `sclass` "bug" = NOT a bug** — passes green in a fresh boot; the ZALL failure was
  cross-suite contamination. No deployable minter defect.

## Contamination playbook (for the shared-boot ZALL)
Terminal ordering (`[6.4]_Admin` rotates ANHD guard → runs last) · covered-elsewhere (`[6.5]_DPOF` via
`[6.2.4]` self-load) · delta assertions (STOAICO) · standalone testers for contamination-prone slow
fixtures (Populate mass-mints).

## Red-team readiness state (decision-free work COMPLETE)
- Whole-chain green (ZALL) ✅ · no deployable defects ✅
- Interface freeze: big cascade already done (#85); codebase coherent at V2; new AQP/RPS interfaces
  documented in `LIVE-INTERFACE-VERSIONS.md` ✅
- Deploy-ready gate (#83): fresh deploy green + 0/93 modules over the ~6,635-line cliff (max RPS 5,617,
  ~624K gas vs 2M) → `DEPLOY-READY-GATE.md` ✅
- IGNIS (#76): full cost-vs-complexity inventory → `IGNIS-COST-INVENTORY.md` ✅ (prep only)

## The two OWNER decisions that gate the red team (nothing else does)
1. **Interface version policy** for the never-live AQP/RPS interfaces — V1 ("new work → V1") vs the
   current V2 baseline. Recommendation: keep V2 (status quo, no change needed).
2. **IGNIS pricing model (#76)** — owner's economic call (explicitly "the last item before red team").
   Inventory finding: cost model is non-uniform (only AQP charges flat `GAS|` 500/1000; 459 ops compute
   via UsagePrice/URCi) and the AQP flats don't track complexity. Proposed shape:
   `cost = category-base + k·writes + m·heavy-reads`. Needs owner constants.

## Deliberately NOT done (low value / risk pre-red-team)
- #97 CODEX/PYTHIA INFO→INFO-ONE consolidation: the 6 functions have **zero callers** — pure cosmetic
  file-shuffle touching 3 interfaces. Skip until (if ever) worth it.
- Re-verifying the mature SWP/ATS audits (#21/#23): already ranked + refuted/fixed-and-proven.

# Live interface versions on StoaChain (`ouronet-ns`)

> Snapshot 2026-08-30 via the Pythia keyless dirty-read (`describe-module` → `interfaces`).
> **Roadmap Phase 0.4.** For any interface whose code changes at Phase 7, the target suffix = **live + 1**.
> `OuronetPolicyV1` (every module implements it) omitted for brevity.

> **⚠ 2026-09-18 — THE BUMP HAS HAPPENED. This table is the LIVE (pre-bump) state and stays that way.**
> Phase 1.7.1.1 moved 7 interfaces from dev == live to live+1 (`AcquisitionAnchors`,
> `AcquisitionPools`, `AcquisitionScores`, `AcquisitionVacate`, `AqpMtx`, `Dsa`, `IgnisCollector`).
> **Do not refresh this file from the tree** — it records what is deployed ON CHAIN, and its whole
> purpose is to be the thing the tree is compared against. It becomes stale only when a redeploy
> lands, and should be re-snapshotted then, from the chain.
>
> *(A caution for whoever does that: the first bump map built from this file read `Autostake` as live
> at V3 because it took the highest version mentioned ANYWHERE in the document, including prose. The
> table says V2. Parse the live column only.)*

| Module | Live interface(s) implemented |
|--------|-------------------------------|
| `ATS` | `AutostakeComputerV1`, `AutostakeV2`, `BrandingUsagePrimaryV1` |
| `ATSU` | `AutostakeUsageV1` |
| `BRD` | `BrandingV1` |
| `CODEX` | `CodexV1` |
| `DALOS` | `OuronetDalosV1` |
| `DEMIPAD` | `DemiourgosLaunchpadV1` |
| `DEMIPAD-CUSTODIANS` | `SaleCustodiansV1` |
| `DEMIPAD-SNAKES` | `SaleSnakesV1` |
| `DEMIPAD-SPARK` | `SparksV1` |
| `DEMIPAD-STOICPAY` | `StoicPayV2` |
| `DPDC` | `BrandingUsageTertiaryV1`, `DpdcV1` |
| `DPDC-C` | `DpdcCreateV1` |
| `DPDC-F` | `DpdcFragmentsV1` |
| `DPDC-I` | `DpdcIssueV1` |
| `DPDC-MNG` | `DpdcManagementV1` |
| `DPDC-N` | `DpdcNonceV1` |
| `DPDC-R` | `DpdcRolesV1` |
| `DPDC-S` | `DpdcSetsV1` |
| `DPDC-T` | `DpdcTransferV1` |
| `DPDC-UDC` | `DpdcUdcV1` |
| `DPL-UR` | `DeployerReadsV7`, `DeployerReadsV8` |
| `DPOF` | `BrandingUsagePrimaryV1`, `DemiourgosPactOrtoFungibleV1` |
| `DPTF` | `BrandingUsagePrimaryV1`, `DemiourgosPactTrueFungibleV1` |
| `ELITE` | `EliteV1` |
| `EQUITY` | `EquityV1` |
| `IGNIS` | `IgnisCollectorV1`, `IgnisCollectorV2` |
| `INFO-ONE` | `InfoOneV1` |
| `INFO-ZERO` | `DalosInfoV1`, `OuronetInfoV1` |
| `LIQUID` | `StoaLiquidStakingV1` |
| `MTX-SWP` | `SwapperMtxV3` |
| `OUROBOROS` | `OuroborosV1` |
| `PYTHIA` | `PythiaLedgerV2`, `PythiaV4` |
| `SWP` | `BrandingUsagePrimaryV1`, `SwapperV3` |
| `SWPI` | `SwapperIssueV3` |
| `SWPL` | `SwapperLiquidityV1` |
| `SWPLC` | `BrandingUsageSecondaryV1`, `SwapperLiquidityClientV1` |
| `SWPT` | `SwapTracerV1` |
| `SWPU` | `SwapperUsageV2` |
| `TFT` | `TrueFungibleTransferV1` |
| `TS01-A` | `TalosStageOne_AdminV1` |
| `TS01-C1` | `TalosStageOne_ClientOneV1` |
| `TS01-C2` | `TalosStageOne_ClientTwoV1` |
| `TS01-C3` | `TalosStageOne_ClientThreeV3` |
| `TS01-C4` | `TalosStageOne_ClientFourV7` |
| `TS01-CP` | `TalosStageOne_ClientPactsV3` |
| `TS02-C1` | `TalosStageTwo_ClientOneV1` |
| `TS02-C2` | `TalosStageTwo_ClientTwoV1` |
| `TS02-DPAD` | `TalosStageTwo_DemiPadV1` |
| `U|ATS` | `UtilityAtsV2` |
| `U|BFS` | `BreadthFirstSearchV1` |
| `U|CT` | `DiaKdaPidV1`, `OuronetConstantsV1` |
| `U|DALOS` | `UtilityDalosGlyphsV2`, `UtilityDalosV1` |
| `U|DEC` | `OuronetDecimalsV1` |
| `U|DPTF` | `UtilityDptfV1` |
| `U|G` | `OuronetGuardsV1` |
| `U|INT` | `OuronetIntegersV1` |
| `U|LST` | `StringProcessorV1` |
| `U|RS` | `ReservedAccountsV1` |
| `U|ST` | `OuronetGasStationV1` |
| `U|SWP` | `UtilitySwpV1` |
| `U|VST` | `UtilityVstV1` |
| `VST` | `VestingV1` |

**62 modules** implement a versioned interface.

Notes: some modules implement/bless **two** versions (`IGNIS` V1+V2, `DPL-UR` DeployerReads V7+V8) — the higher is current. Talos client interfaces already carry high suffixes (`TS01-C4` V7, `TS01-CP` V3, `TS01-C3` V3, `MTX-SWP` V3, `SWP` V3, `PYTHIA` V4) from prior live revisions.

---

## New since the last live snapshot (NOT in the 62 above) — code versions, target TBD

These modules were **not** in the on-chain snapshot (2026-08-30), i.e. never deployed live. The
versioning policy ("new/active work stays on V1 until first mainnet deployment") vs the whole-codebase
V2 baseline that #85 established is an **owner call** for the redeploy — recorded here as the current
*code* interface version, not an asserted target.

| Module | Interface(s) in code | Note |
|--------|----------------------|------|
| `RPS` (04_RPS) | `AcquisitionRewardPerShareV1` | **new** interface from the #75 FVT→RPS split; only RPS implements it, only AQP-FVT names it |
| `AQP-ANK` | `AcquisitionAnchorsV1` | AQP earning-pools family (new since last deploy) |
| `AQP-SCORE` | `AcquisitionScoresV1` | |
| `AQP-POOL` | `AcquisitionPoolsV1` | |
| `AQP-FVT` (05_FVT) | `AcquisitionFarmsVaultsTreasuriesV1` | content changed by #75 split (facade re-exports) — stayed on V2 (pre-deploy edit) |
| `AQP-VCT` | `AcquisitionVacateV1` | |
| `MTX-AQP` | `AqpMtxV1` | |
| `DSA` | `DsaV1` | |
| `AQP-INFO` | (reads only) | |

**This session's interface-content changes (all pre-deploy, kept on existing suffixes):**
- #75 split: `AcquisitionFarmsVaultsTreasuriesV1` slimmed + facade re-exports; new `AcquisitionRewardPerShareV1`.
- #104 Talos scope-first rename: member *names* changed in the Talos client interfaces
  (`TalosStageOne_*`, `TalosStageTwo_*`) + `AutostakeV3`/`SwapperLiquidityClientV2` (HOT-RBT/STOA-PID
  core client fns) — all edited in place on their current suffixes; the whole codebase loads green
  (cascade-coherent), so no re-bump was triggered pre-deploy.

**RESOLVED 2026-09-19 — owner call: the never-live AQP family deploys on V1.** The table above is
updated to match the tree. What made this worth recording rather than just doing: the 2026-09-18 pass
bumped six AQP interfaces V2 -> V3 as "live + 1" when **none of them is live** — they are listed in
this very section as never deployed. That is exactly the misreading this file's own header warns
about (taking a version from the wrong part of the document), and it happened anyway. Only
`IgnisCollector` was a real bump: `IGNIS` IS live at V2, so V3 is correct and the 51-module
OutputCumulator cascade stands. The AQP six, plus `AcquisitionFarmsVaultsTreasuries`,
`AcquisitionPoolBoot` and the new `AcquisitionSchemas`, are all **V1**.

**Superseded question (kept for the reasoning):** confirm whether the never-live AQP family + RPS deploy
at V1 (strict "new work → V1") or stay at the current V2 baseline; and whether any live-and-changed
interface needs an explicit live+1 bump beyond what #85 already applied.

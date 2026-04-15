# Stage 1 — interfaces

Interfaces live primarily in `1_SOVEREIGN/STAGE_01/0_Interfaces/`. Implementations use `implements` and typed `module{InterfaceVn}` refs.

## 01_Utilities.pact

Includes: `OuronetConstantsV1`, `DiaKdaPidV1`, `OuronetGuardsV1`, `OuronetGasStationV1`, `ReservedAccountsV1`, `StringProcessorV1`, `OuronetIntegersV1`, `OuronetDecimalsV1`, `UtilityDalosV1`, `UtilityDalosGlyphsV1`, `UtilityAtsV1`, `UtilityDptfV1`, `UtilityVstV1`, `UtilitySwpV1`, `BreadthFirstSearchV1`.

## 02_Core.pact (selected)

Includes: `OuronetPolicyV1`, `IgnisCollectorV1`, `OuronetDalosV1`, `OuronetInfoV1`, `DalosInfoV1`, `BrandingV1`, `BrandingUsagePrimaryV1`, `BrandingUsageSecondaryV1`, `BrandingUsageTertiaryV1`, `DemiourgosPactTrueFungibleV1`, `TrueFungibleTransferV1`, `DemiourgosPactMetaFungibleV6`, `DpofUdcV1`, `DemiourgosPactOrtoFungibleV1`, `EliteV1`, `AutostakeV1`, `AutostakeComputerV1`, `AutostakeUsageV1`, `VestingV1`, `StoaLiquidStakingV1`, `OuroborosV1`, `SwapTracerV1`, `SwapperV2`, `SwapperV3`, `SwapperIssueV3`, `SwapperLiquidityV1`, `SwapperLiquidityClientV1`, `SwapperUsageV2`, `SwapperMtxV3`.

See [INTERFACE_VERSIONING.md](INTERFACE_VERSIONING.md) for how bumps propagate when a referenced interface version changes.

The source file is the single source of truth for full `defun` lists per interface.

## 03_Talos.pact

Includes: `TalosStageOne_AdminV1`, `TalosStageOne_ClientOneV1`, `TalosStageOne_ClientTwoV1`, `TalosStageOne_ClientThreeV3`, `TalosStageOne_ClientPactsV3`.

## Co-located

| File | Interface |
|------|-----------|
| `21_INFO-ONE+.pact` | `InfoOneV1` |

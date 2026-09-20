# Authorisation surface — every sovereign client entrypoint

> **GENERATED** by `REPL/tools/_authsurface.py`. Do not edit.
> For each `C_`/`A_`, the accounts whose ownership is enforced ANYWHERE in its call tree.
> The gate requires this set to only ever GROW: an entrypoint that stops enforcing something it used to enforce is an authorisation regression, and nothing else here would catch it.

| metric | value |
|---|---|
| entrypoints scanned | 1104 |
| reaching at least one ownership enforce | 714 |
| reaching NONE | 390 |

## Per entrypoint

| module | entrypoint | enforced ownership on |
|---|---|---|
| `00_DPMF` | `C_AddQuantity` | `client` |
| `00_DPMF` | `C_Burn` | `account`, `client` |
| `00_DPMF` | `C_Control` | — |
| `00_DPMF` | `C_Create` | `client` |
| `00_DPMF` | `C_DeployAccount` | — |
| `00_DPMF` | `C_Issue` | `account` |
| `00_DPMF` | `C_Mint` | `client` |
| `00_DPMF` | `C_MultiBatchTransfer` | `account`, `receiver`, `sender` |
| `00_DPMF` | `C_RotateOwnership` | — |
| `00_DPMF` | `C_SingleBatchTransfer` | `account`, `receiver`, `sender` |
| `00_DPMF` | `C_ToggleFreezeAccount` | — |
| `00_DPMF` | `C_TogglePause` | — |
| `00_DPMF` | `C_ToggleTransferRole` | — |
| `00_DPMF` | `C_Transfer` | `account`, `receiver`, `sender` |
| `00_DPMF` | `C_UpdatePendingBranding` | — |
| `00_DPMF` | `C_UpgradeBranding` | `entity-owner-account` |
| `00_DPMF` | `C_Wipe` | — |
| `00_DPMF` | `C_WipePartial` | — |
| `00_DPMF` | `P|A_Add` | — |
| `00_DPMF` | `P|A_AddIMP` | — |
| `00_DPMF` | `P|A_Define` | — |
| `01_DALOS` | `A_DeploySmartAccount` | — |
| `01_DALOS` | `A_DeployStandardAccount` | — |
| `01_DALOS` | `A_MigrateLiquidFunds` | — |
| `01_DALOS` | `A_SetAutoFueling` | — |
| `01_DALOS` | `A_SetIgnisSourcePrice` | — |
| `01_DALOS` | `A_ToggleAccountCreationStoa` | — |
| `01_DALOS` | `A_ToggleGAP` | — |
| `01_DALOS` | `A_ToggleGasCollection` | — |
| `01_DALOS` | `A_ToggleOAPU` | — |
| `01_DALOS` | `A_UpdatePublicKey` | — |
| `01_DALOS` | `A_UpdateUsagePrice` | — |
| `01_DALOS` | `C_ControlSmartAccount` | `account` |
| `01_DALOS` | `C_DeploySmartAccount` | — |
| `01_DALOS` | `C_DeployStandardAccount` | — |
| `01_DALOS` | `C_RotateGovernor` | `account` |
| `01_DALOS` | `C_RotateGuard` | `account` |
| `01_DALOS` | `C_RotateSovereign` | `account` |
| `01_DALOS` | `C_RotateStoa` | `account` |
| `01_DALOS` | `P|A_Add` | — |
| `01_DALOS` | `P|A_AddIMP` | — |
| `01_DALOS` | `P|A_Define` | — |
| `02_IGNIS` | `C_Collect` | `DALOS|SC_NAME`, `patron` |
| `02_IGNIS` | `C_TransferDalosFuel` | — |
| `02_IGNIS` | `P|A_Add` | — |
| `02_IGNIS` | `P|A_AddIMP` | — |
| `02_IGNIS` | `P|A_Define` | — |
| `02_IGNIS` | `STOA|C_Collect` | — |
| `02_IGNIS` | `STOA|C_CollectFull` | — |
| `02_IGNIS` | `STOA|C_CollectWT` | — |
| `02_IGNIS` | `STOA|C_CollectWTEx` | — |
| `04_BRD` | `A_Live` | — |
| `04_BRD` | `A_SetFlag` | — |
| `04_BRD` | `P|A_Add` | — |
| `04_BRD` | `P|A_AddIMP` | — |
| `04_BRD` | `P|A_Define` | — |
| `05_DPTF` | `A_UpdateTreasury` | — |
| `05_DPTF` | `A_WipeTreasuryDebt` | `client` |
| `05_DPTF` | `A_WipeTreasuryDebtPartial` | `client` |
| `05_DPTF` | `C_Burn` | `account` |
| `05_DPTF` | `C_Control` | — |
| `05_DPTF` | `C_DeployAccount` | — |
| `05_DPTF` | `C_Issue` | `account` |
| `05_DPTF` | `C_Mint` | `client` |
| `05_DPTF` | `C_RotateOwnership` | — |
| `05_DPTF` | `C_SetFee` | — |
| `05_DPTF` | `C_SetFeeTarget` | — |
| `05_DPTF` | `C_SetMinMove` | — |
| `05_DPTF` | `C_ToggleBurnRole` | — |
| `05_DPTF` | `C_ToggleFee` | — |
| `05_DPTF` | `C_ToggleFeeExemptionRole` | — |
| `05_DPTF` | `C_ToggleFeeLock` | — |
| `05_DPTF` | `C_ToggleFreezeAccount` | — |
| `05_DPTF` | `C_ToggleMintRole` | — |
| `05_DPTF` | `C_TogglePause` | — |
| `05_DPTF` | `C_ToggleReservation` | — |
| `05_DPTF` | `C_ToggleTransferRole` | — |
| `05_DPTF` | `C_UpdatePendingBranding` | — |
| `05_DPTF` | `C_UpgradeBranding` | `entity-owner-account` |
| `05_DPTF` | `C_Wipe` | `account` |
| `05_DPTF` | `C_WipeSlim` | `account` |
| `05_DPTF` | `P|A_Add` | — |
| `05_DPTF` | `P|A_AddIMP` | — |
| `05_DPTF` | `P|A_Define` | — |
| `06_DPOF` | `CC_WipeHeavy` | `account` |
| `06_DPOF` | `C_AddQuantity` | `client` |
| `06_DPOF` | `C_BulkTransfer` | `sender` |
| `06_DPOF` | `C_Burn` | `account` |
| `06_DPOF` | `C_Control` | — |
| `06_DPOF` | `C_DeployAccount` | — |
| `06_DPOF` | `C_Issue` | `account` |
| `06_DPOF` | `C_Mint` | `client` |
| `06_DPOF` | `C_MoveCreateRole` | — |
| `06_DPOF` | `C_RotateOwnership` | — |
| `06_DPOF` | `C_ToggleAddQuantityRole` | — |
| `06_DPOF` | `C_ToggleBurnRole` | — |
| `06_DPOF` | `C_ToggleFreezeAccount` | — |
| `06_DPOF` | `C_TogglePause` | — |
| `06_DPOF` | `C_ToggleTransferRole` | — |
| `06_DPOF` | `C_Transfer` | `receiver`, `sender` |
| `06_DPOF` | `C_Transmit` | `account`, `receiver` |
| `06_DPOF` | `C_UpdatePendingBranding` | — |
| `06_DPOF` | `C_UpgradeBranding` | `entity-owner-account` |
| `06_DPOF` | `C_WipeClean` | `account` |
| `06_DPOF` | `C_WipePure` | `account` |
| `06_DPOF` | `C_WipeSlim` | `account` |
| `06_DPOF` | `P|A_Add` | — |
| `06_DPOF` | `P|A_AddIMP` | — |
| `06_DPOF` | `P|A_Define` | — |
| `07_ELITE` | `P|A_Add` | — |
| `07_ELITE` | `P|A_AddIMP` | — |
| `07_ELITE` | `P|A_Define` | — |
| `08_ATS` | `C_AddHotRBT` | — |
| `08_ATS` | `C_AddSecondary` | — |
| `08_ATS` | `C_Control` | — |
| `08_ATS` | `C_ControlColdRecoveryFees` | — |
| `08_ATS` | `C_ControlHotRecoveryFee` | — |
| `08_ATS` | `C_Issue` | `account` |
| `08_ATS` | `C_RotateOwnership` | — |
| `08_ATS` | `C_SetColdRecoveryDuration` | — |
| `08_ATS` | `C_SetColdRecoveryFees` | — |
| `08_ATS` | `C_SetDirectRecoveryFee` | — |
| `08_ATS` | `C_SetHibernationFees` | — |
| `08_ATS` | `C_SetHotRecoveryFees` | — |
| `08_ATS` | `C_SwitchColdRecovery` | — |
| `08_ATS` | `C_SwitchDirectRecovery` | — |
| `08_ATS` | `C_SwitchHotRecovery` | — |
| `08_ATS` | `C_ToggleElite` | — |
| `08_ATS` | `C_ToggleParameterLock` | — |
| `08_ATS` | `C_ToggleUpgrade` | — |
| `08_ATS` | `C_UpdatePendingBranding` | — |
| `08_ATS` | `C_UpdateRoyalty` | — |
| `08_ATS` | `C_UpdateSyphon` | — |
| `08_ATS` | `C_UpgradeBranding` | `entity-owner-account` |
| `08_ATS` | `HOT-RBT|C_Repurpose` | `account`, `client`, `receiver`, `sender` |
| `08_ATS` | `HOT-RBT|C_UpdatePendingBranding` | — |
| `08_ATS` | `HOT-RBT|C_UpgradeBranding` | `entity-owner-account` |
| `08_ATS` | `P|A_Add` | — |
| `08_ATS` | `P|A_AddIMP` | — |
| `08_ATS` | `P|A_Define` | — |
| `09_TFT` | `C_ClearDispo` | `account` |
| `09_TFT` | `C_MultiBulkTransfer` | `account` |
| `09_TFT` | `C_MultiTransfer` | `account`, `receiver` |
| `09_TFT` | `C_Transfer` | `account`, `receiver`, `sender` |
| `09_TFT` | `C_Transmute` | `account` |
| `09_TFT` | `P|A_Add` | — |
| `09_TFT` | `P|A_AddIMP` | — |
| `09_TFT` | `P|A_Define` | — |
| `10_ATSU` | `AA_RemoveSecondary` | `account`, `receiver`, `sender` |
| `10_ATSU` | `A_KickStart` | `account`, `client`, `receiver`, `sender` |
| `10_ATSU` | `CC_RemoveSecondary` | `account`, `receiver`, `sender` |
| `10_ATSU` | `C_Coil` | `account`, `client`, `receiver`, `sender` |
| `10_ATSU` | `C_ColdRecovery` | `account`, `receiver`, `recoverer`, `sender` |
| `10_ATSU` | `C_Cull` | `account`, `culler`, `receiver`, `sender` |
| `10_ATSU` | `C_Curl` | `account`, `client`, `receiver`, `sender` |
| `10_ATSU` | `C_DirectRecovery` | `account`, `receiver`, `recoverer`, `sender` |
| `10_ATSU` | `C_Fuel` | `account`, `receiver`, `sender` |
| `10_ATSU` | `C_HotRecovery` | `account`, `client`, `receiver`, `recoverer`, `sender` |
| `10_ATSU` | `C_KickStart` | `account`, `client`, `receiver`, `sender` |
| `10_ATSU` | `C_Recover` | `account`, `client`, `receiver`, `sender` |
| `10_ATSU` | `C_Redeem` | `account`, `receiver`, `sender` |
| `10_ATSU` | `C_Syphon` | `account`, `receiver`, `sender` |
| `10_ATSU` | `C_WithdrawRoyalties` | `account`, `receiver` |
| `10_ATSU` | `P|A_Add` | — |
| `10_ATSU` | `P|A_AddIMP` | — |
| `10_ATSU` | `P|A_Define` | — |
| `11_VST` | `C_Awake` | `account`, `receiver`, `sender` |
| `11_VST` | `C_Brumate` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_Constrict` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_CreateFrozenLink` | `account` |
| `11_VST` | `C_CreateHibernatingLink` | `account` |
| `11_VST` | `C_CreateReservationLink` | `account` |
| `11_VST` | `C_CreateSleepingLink` | `account` |
| `11_VST` | `C_CreateVestingLink` | `account` |
| `11_VST` | `C_Freeze` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_Hibernate` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_Merge` | `account`, `client`, `merger`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeFrozen` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeHibernating` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeMerge` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeReserved` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeSleeping` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeSlumber` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_RepurposeVested` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_Reserve` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_Sleep` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_Slumber` | `account`, `client`, `merger`, `receiver`, `sender` |
| `11_VST` | `C_ToggleTransferRoleFrozenDPTF` | — |
| `11_VST` | `C_ToggleTransferRoleHibernatingDPOF` | — |
| `11_VST` | `C_ToggleTransferRoleReservedDPTF` | — |
| `11_VST` | `C_ToggleTransferRoleSleepingDPOF` | — |
| `11_VST` | `C_Unreserve` | `account`, `receiver`, `sender` |
| `11_VST` | `C_Unsleep` | `account`, `receiver`, `sender` |
| `11_VST` | `C_Unvest` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `C_Vest` | `account`, `client`, `receiver`, `sender` |
| `11_VST` | `P|A_Add` | — |
| `11_VST` | `P|A_AddIMP` | — |
| `11_VST` | `P|A_Define` | — |
| `12_LIQUID` | `A_MigrateLiquidFunds` | — |
| `12_LIQUID` | `C_UnwrapStoa` | `account`, `receiver`, `sender` |
| `12_LIQUID` | `C_UnwrapUrStoa` | `account`, `receiver`, `sender` |
| `12_LIQUID` | `C_WrapStoa` | `account`, `client`, `receiver`, `sender` |
| `12_LIQUID` | `C_WrapUrStoa` | `account`, `client`, `receiver`, `sender` |
| `12_LIQUID` | `P|A_Add` | — |
| `12_LIQUID` | `P|A_AddIMP` | — |
| `12_LIQUID` | `P|A_Define` | — |
| `13_OUROBOROS` | `C_Compress` | `account`, `client`, `receiver`, `sender` |
| `13_OUROBOROS` | `C_Fuel` | `account`, `client`, `receiver`, `sender` |
| `13_OUROBOROS` | `C_Sublimate` | `account`, `client`, `receiver`, `sender` |
| `13_OUROBOROS` | `C_SublimateV2` | `account`, `client`, `receiver`, `sender` |
| `13_OUROBOROS` | `C_WithdrawFees` | `account`, `receiver`, `sender` |
| `13_OUROBOROS` | `P|A_Add` | — |
| `13_OUROBOROS` | `P|A_AddIMP` | — |
| `13_OUROBOROS` | `P|A_Define` | — |
| `14_SWPT` | `P|A_Add` | — |
| `14_SWPT` | `P|A_AddIMP` | — |
| `14_SWPT` | `P|A_Define` | — |
| `15_SWP` | `A_DefinePrimordialPool` | — |
| `15_SWP` | `A_RotatePrincipal` | — |
| `15_SWP` | `A_ToggleAsymetricLiquidityAddition` | — |
| `15_SWP` | `A_UpdateLimit` | — |
| `15_SWP` | `A_UpdateLiquidBoost` | — |
| `15_SWP` | `A_UpdatePrincipal` | — |
| `15_SWP` | `C_ChangeOwnership` | — |
| `15_SWP` | `C_EnableFrozenLP` | `account` |
| `15_SWP` | `C_EnableSleepingLP` | `account` |
| `15_SWP` | `C_ModifyCanChangeOwner` | — |
| `15_SWP` | `C_ModifyWeights` | — |
| `15_SWP` | `C_ToggleAddOrSwap` | — |
| `15_SWP` | `C_ToggleFeeLock` | — |
| `15_SWP` | `C_UpdateAmplifier` | — |
| `15_SWP` | `C_UpdateFee` | — |
| `15_SWP` | `C_UpdatePendingBranding` | — |
| `15_SWP` | `C_UpdateSpecialFeeTargets` | — |
| `15_SWP` | `C_UpgradeBranding` | `entity-owner-account` |
| `15_SWP` | `P|A_Add` | — |
| `15_SWP` | `P|A_AddIMP` | — |
| `15_SWP` | `P|A_Define` | — |
| `16_SWPI` | `A_RebuildGraph` | — |
| `16_SWPI` | `C_Issue` | `account`, `client`, `receiver`, `sender` |
| `16_SWPI` | `P|A_Add` | — |
| `16_SWPI` | `P|A_AddIMP` | — |
| `16_SWPI` | `P|A_Define` | — |
| `17_SWPL` | `P|A_Add` | — |
| `17_SWPL` | `P|A_AddIMP` | — |
| `17_SWPL` | `P|A_Define` | — |
| `18_SWPLC` | `C_Fuel` | `account`, `receiver` |
| `18_SWPLC` | `C_RemoveLiquidity` | `account`, `receiver`, `sender` |
| `18_SWPLC` | `C_ToggleAddLiquidity` | — |
| `18_SWPLC` | `C_UpdatePendingBrandingLPs` | — |
| `18_SWPLC` | `C_UpgradeBrandingLPs` | `entity-owner-account` |
| `18_SWPLC` | `P|A_Add` | — |
| `18_SWPLC` | `P|A_AddIMP` | — |
| `18_SWPLC` | `P|A_Define` | — |
| `18_SWPLC` | `STOA-PID|C_AddFrozenLiquidity` | `account`, `client`, `receiver`, `sender` |
| `18_SWPLC` | `STOA-PID|C_AddGlacialLiquidity` | `account`, `client`, `receiver`, `sender` |
| `18_SWPLC` | `STOA-PID|C_AddIcedLiquidity` | `account`, `client`, `receiver`, `sender` |
| `18_SWPLC` | `STOA-PID|C_AddSleepingLiquidity` | `account`, `client`, `receiver`, `sender` |
| `18_SWPLC` | `STOA-PID|C_AddStandardLiquidity` | `account`, `client`, `receiver`, `sender` |
| `19_SWPU` | `CC_SmartSwap` | `account`, `receiver`, `sender` |
| `19_SWPU` | `C_SmartSwap` | `account`, `receiver`, `sender` |
| `19_SWPU` | `C_Swap` | `account`, `receiver`, `sender` |
| `19_SWPU` | `C_ToggleSwapCapability` | — |
| `19_SWPU` | `P|A_Add` | — |
| `19_SWPU` | `P|A_AddIMP` | — |
| `19_SWPU` | `P|A_Define` | — |
| `20_MTX-SWP` | `C_AddFrozenLiquidity` | — |
| `20_MTX-SWP` | `C_AddGlacialLiquidity` | — |
| `20_MTX-SWP` | `C_AddIcedLiquidity` | — |
| `20_MTX-SWP` | `C_AddSleepingLiquidity` | — |
| `20_MTX-SWP` | `C_AddStandardLiquidity` | — |
| `20_MTX-SWP` | `C_IssueStablePool` | — |
| `20_MTX-SWP` | `C_IssueStandardPool` | — |
| `20_MTX-SWP` | `C_IssueWeightedPool` | — |
| `20_MTX-SWP` | `P|A_Add` | — |
| `20_MTX-SWP` | `P|A_AddIMP` | — |
| `20_MTX-SWP` | `P|A_Define` | — |
| `21_CODEX` | `A_RegisterCodexIdentity` | — |
| `21_CODEX` | `C_RecordArweaveUpload` | — |
| `21_CODEX` | `C_RegisterStoicTag` | `account-address` |
| `21_CODEX` | `C_ReleaseStoicTag` | `account-address` |
| `21_CODEX` | `C_RotateCodexGuard` | — |
| `21_CODEX` | `P|A_Add` | — |
| `21_CODEX` | `P|A_AddIMP` | — |
| `21_CODEX` | `P|A_Define` | — |
| `22_PYTHIA` | `A_Flush` | — |
| `22_PYTHIA` | `A_LinkDualApiKey` | — |
| `22_PYTHIA` | `A_RevokeDualLink` | — |
| `22_PYTHIA` | `A_UpdateDeployPrice` | — |
| `22_PYTHIA` | `A_UpdateRenamePrice` | — |
| `22_PYTHIA` | `C_DeployApolloPythiaApiKey` | `owner-account` |
| `22_PYTHIA` | `C_LinkDualApiKey` | `owner-account` |
| `22_PYTHIA` | `C_RevokeDualLink` | `owner-account` |
| `22_PYTHIA` | `C_UpdateDualConsumerLane` | `owner-account` |
| `22_PYTHIA` | `P|A_Add` | — |
| `22_PYTHIA` | `P|A_AddIMP` | — |
| `22_PYTHIA` | `P|A_Define` | — |
| `01_TS01-A` | `ATS|AA_RemoveSecondary` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `01_TS01-A` | `ATS|A_KickStart` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `01_TS01-A` | `BRD|A_Live` | — |
| `01_TS01-A` | `BRD|A_SetFlag` | — |
| `01_TS01-A` | `DALOS|A_AccountCreationStoaToggle` | — |
| `01_TS01-A` | `DALOS|A_DeploySmartAccount` | — |
| `01_TS01-A` | `DALOS|A_DeployStandardAccount` | — |
| `01_TS01-A` | `DALOS|A_IgnisToggle` | — |
| `01_TS01-A` | `DALOS|A_MigrateLiquidFunds` | — |
| `01_TS01-A` | `DALOS|A_SetAutoFueling` | — |
| `01_TS01-A` | `DALOS|A_SetIgnisSourcePrice` | — |
| `01_TS01-A` | `DALOS|A_ToggleGAP` | — |
| `01_TS01-A` | `DALOS|A_ToggleOAPU` | — |
| `01_TS01-A` | `DALOS|A_UpdatePublicKey` | — |
| `01_TS01-A` | `DALOS|A_UpdateUsagePrice` | — |
| `01_TS01-A` | `DPOF|A_DeployAccount` | `DALOS|SC_NAME`, `patron` |
| `01_TS01-A` | `DPTF|A_DeployAccount` | `DALOS|SC_NAME`, `patron` |
| `01_TS01-A` | `DPTF|A_UpdateTreasuryDispoParameters` | — |
| `01_TS01-A` | `DPTF|A_WipeTreasuryDebt` | `client` |
| `01_TS01-A` | `DPTF|A_WipeTreasuryDebtPartial` | `client` |
| `01_TS01-A` | `LIQUID|A_MigrateLiquidFunds` | — |
| `01_TS01-A` | `ORBR|A_Fuel` | `account`, `client`, `receiver`, `sender` |
| `01_TS01-A` | `P|A_Add` | — |
| `01_TS01-A` | `P|A_AddIMP` | — |
| `01_TS01-A` | `P|A_Define` | — |
| `01_TS01-A` | `SWP|A_DefinePrimordialPool` | — |
| `01_TS01-A` | `SWP|A_RotatePrincipal` | — |
| `01_TS01-A` | `SWP|A_ToggleAsymetricLiquidityAddition` | — |
| `01_TS01-A` | `SWP|A_UpdateLimit` | — |
| `01_TS01-A` | `SWP|A_UpdateLiquidBoost` | — |
| `01_TS01-A` | `SWP|A_UpdatePrincipal` | — |
| `02_TS01-C1` | `DALOS|C_ControlSmartAccount` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DALOS|C_DeploySmartAccount` | `account`, `client`, `receiver`, `sender` |
| `02_TS01-C1` | `DALOS|C_DeployStandardAccount` | `account`, `client`, `receiver`, `sender` |
| `02_TS01-C1` | `DALOS|C_RotateGovernor` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DALOS|C_RotateGuard` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DALOS|C_RotateSovereign` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DALOS|C_RotateStoa` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DALOS|C_UpdateEliteAccount` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DALOS|C_UpdateEliteAccountSquared` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPOF|CC_WipeHeavy` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPOF|C_AddQuantity` | `DALOS|SC_NAME`, `client`, `patron` |
| `02_TS01-C1` | `DPOF|C_BulkTransfer` | `DALOS|SC_NAME`, `patron`, `sender` |
| `02_TS01-C1` | `DPOF|C_Burn` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPOF|C_Control` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPOF|C_DeployAccount` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPOF|C_Issue` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `02_TS01-C1` | `DPOF|C_Mint` | `DALOS|SC_NAME`, `client`, `patron` |
| `02_TS01-C1` | `DPOF|C_MoveCreateRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPOF|C_RotateOwnership` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPOF|C_ToggleAddQuantityRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPOF|C_ToggleBurnRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPOF|C_ToggleFreezeAccount` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPOF|C_TogglePause` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPOF|C_ToggleTransferRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPOF|C_Transfer` | `DALOS|SC_NAME`, `patron`, `receiver`, `sender` |
| `02_TS01-C1` | `DPOF|C_Transmit` | `DALOS|SC_NAME`, `account`, `patron`, `receiver` |
| `02_TS01-C1` | `DPOF|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPOF|C_UpgradeBranding` | `account`, `client`, `entity-owner-account`, `receiver`, `sender` |
| `02_TS01-C1` | `DPOF|C_WipeClean` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPOF|C_WipePure` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPOF|C_WipeSlim` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPTF|C_BulkTransfer` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPTF|C_Burn` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPTF|C_ClearDispo` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPTF|C_Control` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_DeployAccount` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPTF|C_DonateFees` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_Issue` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `02_TS01-C1` | `DPTF|C_Mint` | `DALOS|SC_NAME`, `client`, `patron` |
| `02_TS01-C1` | `DPTF|C_MultiBulkTransfer` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPTF|C_MultiTransfer` | `DALOS|SC_NAME`, `account`, `patron`, `receiver` |
| `02_TS01-C1` | `DPTF|C_ResetFeeTarget` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_RotateOwnership` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_SetFee` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_SetFeeTarget` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_SetMinMove` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleBurnRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleFee` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleFeeExemptionRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleFeeLock` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `02_TS01-C1` | `DPTF|C_ToggleFreezeAccount` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleMintRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_TogglePause` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleReservation` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_ToggleTransferRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_Transfer` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `02_TS01-C1` | `DPTF|C_Transmute` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPTF|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `patron` |
| `02_TS01-C1` | `DPTF|C_UpgradeBranding` | `account`, `client`, `entity-owner-account`, `receiver`, `sender` |
| `02_TS01-C1` | `DPTF|C_Wipe` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `DPTF|C_WipeSlim` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS01-C1` | `P|A_Add` | — |
| `02_TS01-C1` | `P|A_AddIMP` | — |
| `02_TS01-C1` | `P|A_Define` | — |
| `03_TS01-C2` | `ATS|CC_RemoveSecondary` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_AddHotRBT` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_AddSecondary` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_Brumate` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_Coil` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_ColdRecovery` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `recoverer`, `sender` |
| `03_TS01-C2` | `ATS|C_Constrict` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_Control` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_ControlColdRecoveryFees` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_ControlHotRecoveryFee` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_Cull` | `DALOS|SC_NAME`, `account`, `culler`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_Curl` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_DirectRecovery` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `recoverer`, `sender` |
| `03_TS01-C2` | `ATS|C_Fuel` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_HotRecovery` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `recoverer`, `sender` |
| `03_TS01-C2` | `ATS|C_Issue` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_KickStart` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_Redeem` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_Reverse` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_RotateOwnership` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_SetColdRecoveryDuration` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_SetColdRecoveryFees` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_SetDirectRecoveryFee` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_SetHibernationFees` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_SetHotRecoveryFee` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_SwitchColdRecovery` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_SwitchDirectRecovery` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_SwitchHotRecovery` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_Syphon` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_ToggleElite` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_ToggleParameterLock` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_ToggleUpgrade` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_UpdateRoyalty` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_UpdateSyphon` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `ATS|C_UpgradeBranding` | `account`, `client`, `entity-owner-account`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_VestedCoil` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_VestedCurl` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ATS|C_WithdrawRoyalties` | `DALOS|SC_NAME`, `account`, `patron`, `receiver` |
| `03_TS01-C2` | `LQD|C_UnwrapStoa` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `LQD|C_UnwrapUrStoa` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `LQD|C_WrapStoa` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `LQD|C_WrapUrStoa` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `ORBR|C_Compress` | `account`, `client`, `receiver`, `sender` |
| `03_TS01-C2` | `ORBR|C_Sublimate` | `account`, `client`, `receiver`, `sender` |
| `03_TS01-C2` | `ORBR|C_SublimateV2` | `account`, `client`, `receiver`, `sender` |
| `03_TS01-C2` | `ORBR|C_WithdrawFees` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `P|A_Add` | — |
| `03_TS01-C2` | `P|A_AddIMP` | — |
| `03_TS01-C2` | `P|A_Define` | — |
| `03_TS01-C2` | `VST|C_Awake` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_CreateFrozenLink` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_CreateHibernatingLink` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_CreateReservationLink` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_CreateSleepingLink` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_CreateVestingLink` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Freeze` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Hibernate` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Merge` | `DALOS|SC_NAME`, `account`, `client`, `merger`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeFrozen` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeHibernating` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeMerge` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeReserved` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeSleeping` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeSlumber` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_RepurposeVested` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Reserve` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Sleep` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Slumber` | `DALOS|SC_NAME`, `account`, `client`, `merger`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_ToggleTransferRoleFrozenDPTF` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `VST|C_ToggleTransferRoleHibernatingDPOF` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `VST|C_ToggleTransferRoleReservedDPTF` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `VST|C_ToggleTransferRoleSleepingDPOF` | `DALOS|SC_NAME`, `patron` |
| `03_TS01-C2` | `VST|C_Unreserve` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Unsleep` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Unvest` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_TS01-C2` | `VST|C_Vest` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `P|A_Add` | — |
| `04_TS01-C3` | `P|A_AddIMP` | — |
| `04_TS01-C3` | `P|A_Define` | — |
| `04_TS01-C3` | `SWP|CC_SmartSwapNoSlippage` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|CC_SmartSwapWithSlippage` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_AddFrozenLiquidity` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_AddGlacialLiquidity` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_AddIcedLiquidity` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_AddLiquidity` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_AddSleepingLiquidity` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_ChangeOwnership` | `DALOS|SC_NAME`, `patron` |
| `04_TS01-C3` | `SWP|C_EnableFrozenLP` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_EnableSleepingLP` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_Firestarter` | `account`, `client`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_Fuel` | `DALOS|SC_NAME`, `account`, `patron`, `receiver` |
| `04_TS01-C3` | `SWP|C_IssueStable` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_IssueStandard` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_IssueWeighted` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_ModifyCanChangeOwner` | `DALOS|SC_NAME`, `patron` |
| `04_TS01-C3` | `SWP|C_ModifyWeights` | `DALOS|SC_NAME`, `patron` |
| `04_TS01-C3` | `SWP|C_MultiSwapNoSlippage` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_MultiSwapWithSlippage` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_RemoveLiquidity` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_SingleSwapNoSlippage` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_SingleSwapWithSlippage` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_SmartSwapNoSlippage` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_SmartSwapWithSlippage` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_ToggleAddLiquidity` | `DALOS|SC_NAME`, `patron` |
| `04_TS01-C3` | `SWP|C_ToggleFeeLock` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_ToggleSwapCapability` | `DALOS|SC_NAME`, `patron` |
| `04_TS01-C3` | `SWP|C_UpdateAmplifier` | `DALOS|SC_NAME`, `patron` |
| `04_TS01-C3` | `SWP|C_UpdateFee` | `DALOS|SC_NAME`, `patron` |
| `04_TS01-C3` | `SWP|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `patron` |
| `04_TS01-C3` | `SWP|C_UpdatePendingBrandingLPs` | `DALOS|SC_NAME`, `patron` |
| `04_TS01-C3` | `SWP|C_UpdateSpecialFeeTargets` | `DALOS|SC_NAME`, `patron` |
| `04_TS01-C3` | `SWP|C_UpgradeBranding` | `account`, `client`, `entity-owner-account`, `receiver`, `sender` |
| `04_TS01-C3` | `SWP|C_UpgradeBrandingLPs` | `account`, `client`, `entity-owner-account`, `receiver`, `sender` |
| `05_TS01-P` | `P|A_Add` | — |
| `05_TS01-P` | `P|A_AddIMP` | — |
| `05_TS01-P` | `P|A_Define` | — |
| `05_TS01-P` | `SWP|C_AddFrozenLiquidity` | — |
| `05_TS01-P` | `SWP|C_AddGlacialLiquidity` | — |
| `05_TS01-P` | `SWP|C_AddIcedLiquidity` | — |
| `05_TS01-P` | `SWP|C_AddSleepingLiquidity` | — |
| `05_TS01-P` | `SWP|C_AddStandardLiquidity` | — |
| `05_TS01-P` | `SWP|C_IssueStablePool` | — |
| `05_TS01-P` | `SWP|C_IssueStandardPool` | — |
| `05_TS01-P` | `SWP|C_IssueWeightedPool` | — |
| `06_TS01-C4` | `CODEX|A_RegisterCodexIdentity` | — |
| `06_TS01-C4` | `CODEX|C_RecordArweaveUpload` | `DALOS|SC_NAME`, `patron` |
| `06_TS01-C4` | `CODEX|C_RegisterStoicTag` | `account-address` |
| `06_TS01-C4` | `CODEX|C_ReleaseStoicTag` | `DALOS|SC_NAME`, `account-address`, `patron` |
| `06_TS01-C4` | `CODEX|C_RotateCodexGuard` | `DALOS|SC_NAME`, `patron` |
| `06_TS01-C4` | `PYTHIA|A_Flush` | — |
| `06_TS01-C4` | `PYTHIA|A_Link` | — |
| `06_TS01-C4` | `PYTHIA|A_RevokeLink` | — |
| `06_TS01-C4` | `PYTHIA|A_UpdateDeployPrice` | — |
| `06_TS01-C4` | `PYTHIA|A_UpdateRenamePrice` | — |
| `06_TS01-C4` | `PYTHIA|C_DeployApiKey` | `owner-account` |
| `06_TS01-C4` | `PYTHIA|C_Link` | `owner-account` |
| `06_TS01-C4` | `PYTHIA|C_RevokeLink` | `DALOS|SC_NAME`, `owner-account`, `patron` |
| `06_TS01-C4` | `PYTHIA|C_UpdateDualConsumerLane` | `owner-account` |
| `06_TS01-C4` | `P|A_Add` | — |
| `06_TS01-C4` | `P|A_AddIMP` | — |
| `06_TS01-C4` | `P|A_Define` | — |
| `01_DPDC-UDC` | `P|A_Add` | — |
| `01_DPDC-UDC` | `P|A_AddIMP` | — |
| `01_DPDC-UDC` | `P|A_Define` | — |
| `02_DPDC` | `C_UpdatePendingBranding` | — |
| `02_DPDC` | `C_UpgradeBranding` | `entity-owner-account` |
| `02_DPDC` | `P|A_Add` | — |
| `02_DPDC` | `P|A_AddIMP` | — |
| `02_DPDC` | `P|A_Define` | — |
| `03_DPDC-C` | `C_CreateNewNonce` | `account`, `r-nft-create-account` |
| `03_DPDC-C` | `C_CreateNewNonces` | `account`, `r-nft-create-account` |
| `03_DPDC-C` | `P|A_Add` | — |
| `03_DPDC-C` | `P|A_AddIMP` | — |
| `03_DPDC-C` | `P|A_Define` | — |
| `04_DPDC-I` | `C_IssueDigitalCollection` | `owner-account` |
| `04_DPDC-I` | `P|A_Add` | — |
| `04_DPDC-I` | `P|A_AddIMP` | — |
| `04_DPDC-I` | `P|A_Define` | — |
| `05_DPDC-R` | `C_MoveCreateRole` | — |
| `05_DPDC-R` | `C_MoveRecreateRole` | — |
| `05_DPDC-R` | `C_MoveSetUriRole` | — |
| `05_DPDC-R` | `C_ToggleAddQuantityRole` | — |
| `05_DPDC-R` | `C_ToggleBurnRole` | — |
| `05_DPDC-R` | `C_ToggleExemptionRole` | — |
| `05_DPDC-R` | `C_ToggleFreezeAccount` | — |
| `05_DPDC-R` | `C_ToggleModifyCreatorRole` | — |
| `05_DPDC-R` | `C_ToggleModifyRoyaltiesRole` | — |
| `05_DPDC-R` | `C_ToggleTransferRole` | — |
| `05_DPDC-R` | `C_ToggleUpdateRole` | — |
| `05_DPDC-R` | `P|A_Add` | — |
| `05_DPDC-R` | `P|A_AddIMP` | — |
| `05_DPDC-R` | `P|A_Define` | — |
| `06_DPDC-MNG` | `CC_WipeHeavy` | `account` |
| `06_DPDC-MNG` | `C_AddQuantity` | `account` |
| `06_DPDC-MNG` | `C_BurnNFT` | `account` |
| `06_DPDC-MNG` | `C_BurnSFT` | `account` |
| `06_DPDC-MNG` | `C_Control` | — |
| `06_DPDC-MNG` | `C_RespawnNFT` | `account` |
| `06_DPDC-MNG` | `C_TogglePause` | — |
| `06_DPDC-MNG` | `C_WipeClean` | `account` |
| `06_DPDC-MNG` | `C_WipeDirty` | `account` |
| `06_DPDC-MNG` | `C_WipeNonce` | `account` |
| `06_DPDC-MNG` | `C_WipePure` | `account` |
| `06_DPDC-MNG` | `C_WipeSlim` | `account` |
| `06_DPDC-MNG` | `P|A_Add` | — |
| `06_DPDC-MNG` | `P|A_AddIMP` | — |
| `06_DPDC-MNG` | `P|A_Define` | — |
| `07_DPDC-T` | `C_BulkTransfer` | `account`, `sender` |
| `07_DPDC-T` | `C_IgnisRoyaltyCollector` | `sender` |
| `07_DPDC-T` | `C_RepurposeCollectable` | `account` |
| `07_DPDC-T` | `C_Transfer` | `account`, `receiver`, `sender` |
| `07_DPDC-T` | `P|A_Add` | — |
| `07_DPDC-T` | `P|A_AddIMP` | — |
| `07_DPDC-T` | `P|A_Define` | — |
| `08_DPDC-S` | `CC_BreakSemiFungibleSet` | `account`, `receiver`, `sender` |
| `08_DPDC-S` | `C_BreakNonFungibleSet` | `account`, `receiver`, `sender` |
| `08_DPDC-S` | `C_DefineCompositeSet` | `account`, `r-nft-create-account` |
| `08_DPDC-S` | `C_DefineHybridSet` | `account`, `r-nft-create-account` |
| `08_DPDC-S` | `C_DefinePrimordialSet` | `account`, `r-nft-create-account` |
| `08_DPDC-S` | `C_EnableSetClassFragmentation` | — |
| `08_DPDC-S` | `C_MakeNonFungibleSet` | `account`, `r-nft-create-account`, `receiver`, `sender` |
| `08_DPDC-S` | `C_MakeSemiFungibleSet` | `account`, `receiver`, `sender` |
| `08_DPDC-S` | `C_RenameSet` | — |
| `08_DPDC-S` | `C_ToggleSet` | — |
| `08_DPDC-S` | `P|A_Add` | — |
| `08_DPDC-S` | `P|A_AddIMP` | — |
| `08_DPDC-S` | `P|A_Define` | — |
| `09_DPDC-F` | `C_EnableNonceFragmentation` | — |
| `09_DPDC-F` | `C_MakeFragments` | `account`, `receiver`, `sender` |
| `09_DPDC-F` | `C_MergeFragments` | `account`, `receiver`, `sender` |
| `09_DPDC-F` | `C_RepurposeCollectableFragments` | `account` |
| `09_DPDC-F` | `P|A_Add` | — |
| `09_DPDC-F` | `P|A_AddIMP` | — |
| `09_DPDC-F` | `P|A_Define` | — |
| `10_DPDC-N` | `C_UpdateNonceDescription` | `account` |
| `10_DPDC-N` | `C_UpdateNonceIgnisRoyalty` | `account` |
| `10_DPDC-N` | `C_UpdateNonceMetaData` | `account` |
| `10_DPDC-N` | `C_UpdateNonceName` | `account` |
| `10_DPDC-N` | `C_UpdateNonceRoyalty` | `account` |
| `10_DPDC-N` | `C_UpdateNonceScore` | `account` |
| `10_DPDC-N` | `C_UpdateNonceURI` | `account` |
| `10_DPDC-N` | `C_UpdateNonces` | `account` |
| `10_DPDC-N` | `P|A_Add` | — |
| `10_DPDC-N` | `P|A_AddIMP` | — |
| `10_DPDC-N` | `P|A_Define` | — |
| `11_EQUITY+` | `C_IssueShareholderCollection` | `account`, `owner-account`, `r-nft-create-account` |
| `11_EQUITY+` | `C_MorphPackageShares` | `account`, `receiver`, `sender` |
| `11_EQUITY+` | `P|A_Add` | — |
| `11_EQUITY+` | `P|A_AddIMP` | — |
| `11_EQUITY+` | `P|A_Define` | — |
| `00_Demipad` | `A_DefinePrice` | — |
| `00_Demipad` | `A_RegisterAssetToLaunchpad` | — |
| `00_Demipad` | `A_ToggleOpenForBusiness` | — |
| `00_Demipad` | `A_ToggleRetrieval` | — |
| `00_Demipad` | `C_Deposit` | `account`, `client`, `receiver`, `sender` |
| `00_Demipad` | `C_TransmitNonFungibles` | `account`, `receiver`, `sender` |
| `00_Demipad` | `C_TransmitOrtoFungible` | `DALOS|SC_NAME`, `patron`, `receiver`, `sender` |
| `00_Demipad` | `C_TransmitSemiFungibles` | `account`, `receiver`, `sender` |
| `00_Demipad` | `C_TransmitTrueFungible` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `00_Demipad` | `C_Withdraw` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `00_Demipad` | `P|A_Add` | — |
| `00_Demipad` | `P|A_AddIMP` | — |
| `00_Demipad` | `P|A_Define` | — |
| `01_ANK` | `C_IssueNonFungibleAnchor` | — |
| `01_ANK` | `C_IssueNonFungibleSetAnchor` | — |
| `01_ANK` | `C_IssueSemiFungibleAnchor` | — |
| `01_ANK` | `C_IssueTrueFungibleAnchor` | `owner` |
| `01_ANK` | `C_RevokeAnchor` | `owner` |
| `01_ANK` | `C_RevokeBoostClass` | — |
| `01_ANK` | `P|A_Add` | — |
| `01_ANK` | `P|A_AddIMP` | — |
| `01_ANK` | `P|A_Define` | — |
| `02_SCORE` | `C_CombineTripletScoreModel` | — |
| `02_SCORE` | `C_Control` | `owner-konto` |
| `02_SCORE` | `C_CreateBoostClassLink` | `owner-konto` |
| `02_SCORE` | `C_CreateBoostLink` | `owner-konto` |
| `02_SCORE` | `C_EnableDebBoost` | `owner-konto` |
| `02_SCORE` | `C_IssueLiquidityScore` | `owner-konto` |
| `02_SCORE` | `C_IssueNonFungibleScore` | `owner-konto` |
| `02_SCORE` | `C_IssueNonFungibleScoreDefinition` | `owner-konto` |
| `02_SCORE` | `C_IssueNonFungibleSetScoreDefinition` | `owner-konto` |
| `02_SCORE` | `C_IssueOrtoFungibleScore` | `owner-konto` |
| `02_SCORE` | `C_IssueScoreFromModel` | `owner-konto` |
| `02_SCORE` | `C_IssueSemiFungibleScore` | `owner-konto` |
| `02_SCORE` | `C_IssueSemiFungibleScoreDefinition` | `owner-konto` |
| `02_SCORE` | `C_IssueSingleScoreModel` | — |
| `02_SCORE` | `C_IssueTriplet` | `owner-konto` |
| `02_SCORE` | `C_IssueTrueFungibleScore` | `owner-konto` |
| `02_SCORE` | `C_RotateOwnership` | `owner-now` |
| `02_SCORE` | `P|A_Add` | — |
| `02_SCORE` | `P|A_AddIMP` | — |
| `02_SCORE` | `P|A_Define` | — |
| `03_AQP` | `C_AddScore` | `owner-konto` |
| `03_AQP` | `C_DisablePoolStake` | — |
| `03_AQP` | `C_EnablePoolStake` | — |
| `03_AQP` | `C_Issue` | — |
| `03_AQP` | `C_RevokeScore` | `owner-konto` |
| `03_AQP` | `C_SyncCollectableAnchors` | — |
| `03_AQP` | `C_SyncTrueFungibleAnchors` | — |
| `03_AQP` | `P|A_Add` | — |
| `03_AQP` | `P|A_AddIMP` | — |
| `03_AQP` | `P|A_Define` | — |
| `04_RPS` | `P|A_Add` | — |
| `04_RPS` | `P|A_AddIMP` | — |
| `04_RPS` | `P|A_Define` | — |
| `05_FVT` | `CC_Collect` | `account`, `client`, `patron`, `receiver`, `sender` |
| `05_FVT` | `CC_CollectableStakeFlow` | `account`, `owner-id`, `receiver`, `sender` |
| `05_FVT` | `CC_Inject` | `account`, `receiver`, `sender` |
| `05_FVT` | `CC_InjectFinalize` | `account`, `receiver`, `sender` |
| `05_FVT` | `CC_InjectStream` | `account`, `receiver`, `sender` |
| `05_FVT` | `CC_OrtoFungibleStakeFlow` | `owner-id`, `receiver`, `sender` |
| `05_FVT` | `CC_SweepBegin` | `owner` |
| `05_FVT` | `CC_SweepRevokeAnchor` | `owner` |
| `05_FVT` | `CC_TrueFungibleStakeFlow` | `account`, `owner-id`, `receiver`, `sender` |
| `05_FVT` | `CC_UnstaleMyScores` | `patron` |
| `05_FVT` | `C_AddRewardLink` | `owner-konto` |
| `05_FVT` | `C_AddScoreEntity` | `fvt-owner`, `owner-konto` |
| `05_FVT` | `C_Control` | `owner-konto` |
| `05_FVT` | `C_Issue` | `owner-konto` |
| `05_FVT` | `C_IssueMultipletFamily` | — |
| `05_FVT` | `C_RotateOwnership` | `owner-now` |
| `05_FVT` | `C_SetCommonDenominator` | `owner-konto` |
| `05_FVT` | `C_SetMosaic` | `owner-konto` |
| `05_FVT` | `C_SetQualitySplit` | `owner-konto` |
| `05_FVT` | `C_SetSplitMode` | `owner-konto` |
| `05_FVT` | `C_ToggleRewardLink` | `owner-konto` |
| `05_FVT` | `C_ToggleScoreEntityLink` | `owner-konto` |
| `05_FVT` | `P|A_Add` | — |
| `05_FVT` | `P|A_AddIMP` | — |
| `05_FVT` | `P|A_Define` | — |
| `06_VCT` | `CC_FullVacate` | `account`, `sender` |
| `06_VCT` | `C_AbortVacate` | — |
| `06_VCT` | `C_FinalizeVacate` | — |
| `06_VCT` | `P|A_Add` | — |
| `06_VCT` | `P|A_AddIMP` | — |
| `06_VCT` | `P|A_Define` | — |
| `07_MTX-AQP` | `C_2|Inject` | — |
| `07_MTX-AQP` | `C_2|SweepRevokeAnchor` | — |
| `07_MTX-AQP` | `P|A_Add` | — |
| `07_MTX-AQP` | `P|A_AddIMP` | — |
| `07_MTX-AQP` | `P|A_Define` | — |
| `08_DSA` | `A_SetOracleValidity` | — |
| `08_DSA` | `A_ToggleExternalOracle` | — |
| `08_DSA` | `C_AdmitAgency` | `operator`, `owner-konto` |
| `08_DSA` | `C_BurnRoyalty` | `account`, `client`, `fvt-owner`, `receiver`, `sender` |
| `08_DSA` | `C_DefineDelegationVault` | `fvt-owner` |
| `08_DSA` | `C_FuelRoyalty` | `account`, `client`, `fvt-owner`, `receiver`, `sender` |
| `08_DSA` | `C_OracleWrite` | — |
| `08_DSA` | `C_RecomputeCapture` | — |
| `08_DSA` | `C_SetAgencyFee` | `fvt-owner` |
| `08_DSA` | `C_SetOracleAuth` | `fvt-owner` |
| `08_DSA` | `C_WithdrawRoyalty` | `account`, `client`, `fvt-owner`, `receiver`, `sender` |
| `08_DSA` | `P|A_Add` | — |
| `08_DSA` | `P|A_AddIMP` | — |
| `08_DSA` | `P|A_Define` | — |
| `01_TS02-C1` | `DPDC|C_BulkTransfer` | `DALOS|SC_NAME`, `account`, `patron`, `sender` |
| `01_TS02-C1` | `DPDC|C_MultiTransfer` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|CC_Break` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|CC_WipeHeavy` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_AddQuantity` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_BulkTransfer` | `DALOS|SC_NAME`, `account`, `patron`, `sender` |
| `01_TS02-C1` | `DPSF|C_Burn` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_Control` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_Create` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_TS02-C1` | `DPSF|C_DefineCompositeSet` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_TS02-C1` | `DPSF|C_DefineHybridSet` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_TS02-C1` | `DPSF|C_DefinePrimordialSet` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_TS02-C1` | `DPSF|C_EnableNonceFragmentation` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_EnableSetClassFragmentation` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_Issue` | `DALOS|SC_NAME`, `account`, `client`, `owner-account`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_IssueCompany` | `DALOS|SC_NAME`, `account`, `client`, `owner-account`, `patron`, `r-nft-create-account`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_Make` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_MakeFragments` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_MergeFragments` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_MorphEquity` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_MoveCreateRole` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_MoveRecreateRole` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_MoveSetUriRole` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_RemoveNonceScore` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_RemoveSetNonceScore` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_RenameSet` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_Repurpose` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_RepurposeFragments` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleAddQuantityRole` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleBurnRole` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleExemptionRole` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleFreezeAccount` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleModifyCreatorRole` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleModifyRoyaltiesRole` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_TogglePause` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleSet` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleTransferRole` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_ToggleUpdateRole` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_TransferNonce` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_TransferNonces` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_UpdateNonce` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceDescription` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceIgnisRoyalty` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceMetaData` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceName` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceRoyalty` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceScore` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonceURI` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateNonces` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonce` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceDescription` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceIgnisRoyalty` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceMetaData` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceName` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceRoyalty` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceScore` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonceURI` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpdateSetNonces` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_UpgradeBranding` | `account`, `client`, `entity-owner-account`, `receiver`, `sender` |
| `01_TS02-C1` | `DPSF|C_WipeClean` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_WipeDirty` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_WipeNonce` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_WipeNoncePartialy` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `DPSF|C_WipePure` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_TS02-C1` | `P|A_Add` | — |
| `01_TS02-C1` | `P|A_AddIMP` | — |
| `01_TS02-C1` | `P|A_Define` | — |
| `02_TS02-C2` | `DPNF|CC_WipeHeavy` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_Break` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_BulkTransfer` | `DALOS|SC_NAME`, `account`, `patron`, `sender` |
| `02_TS02-C2` | `DPNF|C_Burn` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_Control` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_Create` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_TS02-C2` | `DPNF|C_DefineCompositeSet` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_TS02-C2` | `DPNF|C_DefineHybridSet` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_TS02-C2` | `DPNF|C_DefinePrimordialSet` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_TS02-C2` | `DPNF|C_EnableNonceFragmentation` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_EnableSetClassFragmentation` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_Issue` | `DALOS|SC_NAME`, `account`, `client`, `owner-account`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_Make` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_MakeFragments` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_MergeFragments` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_MoveCreateRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_MoveRecreateRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_MoveSetUriRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_RemoveNonceScore` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_RemoveSetNonceScore` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_RenameSet` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_Repurpose` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_RepurposeFragments` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_Respawn` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleBurnRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleExemptionRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleFreezeAccount` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleModifyCreatorRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleModifyRoyaltiesRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_TogglePause` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleSet` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleTransferRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_ToggleUpdateRole` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_TransferNonce` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_TransferNonces` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_UpdateNonce` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceDescription` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceIgnisRoyalty` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceMetaData` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceName` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceRoyalty` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceScore` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonceURI` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateNonces` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdatePendingBranding` | `DALOS|SC_NAME`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonce` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceDescription` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceIgnisRoyalty` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceMetaData` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceName` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceRoyalty` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceScore` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonceURI` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpdateSetNonces` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_UpgradeBranding` | `account`, `client`, `entity-owner-account`, `receiver`, `sender` |
| `02_TS02-C2` | `DPNF|C_WipeClean` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_WipeDirty` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_WipeNonce` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `DPNF|C_WipePure` | `DALOS|SC_NAME`, `account`, `patron` |
| `02_TS02-C2` | `P|A_Add` | — |
| `02_TS02-C2` | `P|A_AddIMP` | — |
| `02_TS02-C2` | `P|A_Define` | — |
| `04_TS02-C3` | `AQP-ANK|C_IssueNonFungibleAnchor` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-ANK|C_IssueNonFungibleSetAnchor` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-ANK|C_IssueSemiFungibleAnchor` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-ANK|C_IssueTrueFungibleAnchor` | `DALOS|SC_NAME`, `account`, `client`, `owner`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-ANK|C_RevokeAnchor` | `DALOS|SC_NAME`, `owner`, `patron` |
| `04_TS02-C3` | `AQP-ANK|C_RevokeBoostClass` | `DALOS|SC_NAME`, `patron` |
| `04_TS02-C3` | `AQP-DSA|A_SetOracleValidity` | — |
| `04_TS02-C3` | `AQP-DSA|A_ToggleExternalOracle` | — |
| `04_TS02-C3` | `AQP-DSA|CC_OpenAgency` | `DALOS|SC_NAME`, `account`, `operator`, `owner-id`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-DSA|C_BurnRoyalty` | `DALOS|SC_NAME`, `account`, `client`, `fvt-owner`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-DSA|C_DefineDelegationVault` | `DALOS|SC_NAME`, `fvt-owner`, `patron` |
| `04_TS02-C3` | `AQP-DSA|C_FuelRoyalty` | `DALOS|SC_NAME`, `account`, `client`, `fvt-owner`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-DSA|C_OracleWrite` | `DALOS|SC_NAME`, `patron` |
| `04_TS02-C3` | `AQP-DSA|C_RecomputeCapture` | `DALOS|SC_NAME`, `patron` |
| `04_TS02-C3` | `AQP-DSA|C_SetAgencyFee` | `DALOS|SC_NAME`, `fvt-owner`, `patron` |
| `04_TS02-C3` | `AQP-DSA|C_SetOracleAuth` | `DALOS|SC_NAME`, `fvt-owner`, `patron` |
| `04_TS02-C3` | `AQP-DSA|C_WithdrawRoyalty` | `DALOS|SC_NAME`, `account`, `client`, `fvt-owner`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_Collect` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_Inject` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_InjectFinalize` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_InjectStream` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_SweepBegin` | `account`, `client`, `owner`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_SweepRevokeAnchor` | `account`, `client`, `owner`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|CC_UnstaleMyScores` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_AddRewardLink` | `DALOS|SC_NAME`, `account`, `client`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_AddScoreEntity` | `DALOS|SC_NAME`, `account`, `client`, `fvt-owner`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_Control` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_Issue` | `DALOS|SC_NAME`, `account`, `client`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_IssueGenericEarningVault` | `DALOS|SC_NAME`, `account`, `client`, `fvt-owner`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_IssueMultipletFamily` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_RotateOwnership` | `DALOS|SC_NAME`, `owner-now`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_SetCommonDenominator` | `DALOS|SC_NAME`, `account`, `client`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-FVT|C_SetMosaic` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_SetQualitySplit` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_SetSplitMode` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_ToggleRewardLink` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-FVT|C_ToggleScoreEntityLink` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-POOL|CC_FullVacate` | `DALOS|SC_NAME`, `account`, `patron`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_StakeNonFungibleCollectable` | `DALOS|SC_NAME`, `account`, `owner-id`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_StakeOrtoFungible` | `DALOS|SC_NAME`, `owner-id`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_StakeSemiFungibleCollectable` | `DALOS|SC_NAME`, `account`, `owner-id`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_StakeTrueFungible` | `DALOS|SC_NAME`, `account`, `owner-id`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_UnstakeNonFungibleCollectable` | `DALOS|SC_NAME`, `account`, `owner-id`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_UnstakeOrtoFungible` | `DALOS|SC_NAME`, `owner-id`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_UnstakeSemiFungibleCollectable` | `DALOS|SC_NAME`, `account`, `owner-id`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|CC_UnstakeTrueFungible` | `DALOS|SC_NAME`, `account`, `owner-id`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_AbortVacate` | `DALOS|SC_NAME`, `patron` |
| `04_TS02-C3` | `AQP-POOL|C_AddScore` | `DALOS|SC_NAME`, `account`, `client`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_DisablePoolStake` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_EnablePoolStake` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_FinalizeVacate` | `DALOS|SC_NAME`, `patron` |
| `04_TS02-C3` | `AQP-POOL|C_Issue` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_RevokeScore` | `DALOS|SC_NAME`, `account`, `client`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_TS02-C3` | `AQP-POOL|C_SyncNonFungibleAnchors` | `DALOS|SC_NAME`, `patron` |
| `04_TS02-C3` | `AQP-POOL|C_SyncSemiFungibleAnchors` | `DALOS|SC_NAME`, `patron` |
| `04_TS02-C3` | `AQP-POOL|C_SyncTrueFungibleAnchors` | `DALOS|SC_NAME`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_CombineTripletScoreModel` | `DALOS|SC_NAME`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_ControlScore` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_CreateScoreBoostClassLink` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_CreateScoreBoostLink` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_EnableDebBoost` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueLiquidityScore` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueNonFungibleScore` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueNonFungibleScoreDefinition` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueNonFungibleSetScoreDefinition` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueOrtoFungibleScore` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueScoreFromModel` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueSemiFungibleScore` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueSemiFungibleScoreDefinition` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueSingleScoreModel` | `DALOS|SC_NAME`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueTriplet` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_IssueTrueFungibleScore` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_TS02-C3` | `AQP-SCR|C_RotateScoreOwnership` | `DALOS|SC_NAME`, `owner-now`, `patron` |
| `04_TS02-C3` | `P|A_Add` | — |
| `04_TS02-C3` | `P|A_AddIMP` | — |
| `04_TS02-C3` | `P|A_Define` | — |
| `05_TS02-DPAD` | `A_DefinePrice` | — |
| `05_TS02-DPAD` | `A_RegisterAssetToLaunchpad` | `DALOS|SC_NAME`, `patron` |
| `05_TS02-DPAD` | `A_ToggleOpenForBusiness` | — |
| `05_TS02-DPAD` | `A_ToggleRetrieval` | — |
| `05_TS02-DPAD` | `DEMIPAD|C_Deposit` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_FuelNonFungible` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_FuelOrtoFungible` | `DALOS|SC_NAME`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_FuelSemiFungible` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_FuelTrueFungible` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_RetrieveNonFungible` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_RetrieveOrtoFungible` | `DALOS|SC_NAME`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_RetrieveSemiFungible` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_RetrieveTrueFungible` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `DEMIPAD|C_Withdraw` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `05_TS02-DPAD` | `P|A_Add` | — |
| `05_TS02-DPAD` | `P|A_AddIMP` | — |
| `05_TS02-DPAD` | `P|A_Define` | — |
| `01_AOZ+` | `A_InitialiseCounters` | — |
| `01_AOZ+` | `A_RegisterAutostakePair` | — |
| `01_AOZ+` | `A_RegisterNonFungible` | — |
| `01_AOZ+` | `A_RegisterOrtoFungible` | — |
| `01_AOZ+` | `A_RegisterPrimalOrtoFungible` | — |
| `01_AOZ+` | `A_RegisterPrimalTrueFungible` | — |
| `01_AOZ+` | `A_RegisterSemiFungible` | — |
| `01_AOZ+` | `A_RegisterTrueFungible` | — |
| `01_AOZ+` | `C_SetupKosonicATS` | `DALOS|SC_NAME`, `patron` |
| `01_BSD-L` | `A_Issue` | `DALOS|SC_NAME`, `account`, `client`, `owner-account`, `patron`, `receiver`, `sender` |
| `01_BSD-L` | `A_Legendary` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_BSD-E` | `A_Epic` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `03_BSD-R` | `A_Rare` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `04_BSD-C` | `A_Common` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Fix01` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix02a` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix02b` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix03` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix04` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix05a` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix05b` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix06` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix07` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix08` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix09` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix10` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix11` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix12` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix13` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix14` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix15` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix16` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix17` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix18` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix19` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix20` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix21` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Fix22` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `A_Step01` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step02` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step03` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step04` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step05` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step06` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step07` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step08` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step09` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step10` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step11` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step12` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step13` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step14` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step15` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step16` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step17` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step18` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step19` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step20` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step21` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `A_Step22` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `01_NOSFERATU` | `C_Fix` | `DALOS|SC_NAME`, `account`, `patron` |
| `01_NOSFERATU` | `C_Spawn` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_BunnyRGBSet` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step01` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step02` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step03` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step04` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step05` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step06` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step07` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step08` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step09` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step10` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step11` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step12` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step13` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step14` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step15` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `A_Step16` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `02_KBunnies` | `C_Spawn` | `DALOS|SC_NAME`, `account`, `patron`, `r-nft-create-account` |
| `04_AQP-BOOT` | `CC_Step14_OpenCustodiansAgency` | `DALOS|SC_NAME`, `account`, `client`, `operator`, `owner-id`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_IssueGenericEarningVault` | `DALOS|SC_NAME`, `account`, `client`, `fvt-owner`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step0_WireImcAndGovernor` | `DALOS|SC_NAME`, `account`, `patron` |
| `04_AQP-BOOT` | `C_Step10_IssueMultipletFamily` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step11_WireFarmTriplet` | `DALOS|SC_NAME`, `account`, `client`, `fvt-owner`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step12_AddFvtRewardLinks` | `DALOS|SC_NAME`, `account`, `client`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step13_CreateCustodiansVault` | `DALOS|SC_NAME`, `account`, `client`, `fvt-owner`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step1_CreateBunnySet` | — |
| `04_AQP-BOOT` | `C_Step2_CreateSnakePowerAnchorClasses` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step3_CreateBoosterAnchorClasses` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step4_CreateCoreScores` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_AQP-BOOT` | `C_Step5_CreateSubsidiaryScores` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_AQP-BOOT` | `C_Step6_CreateOuroLpTriplet` | `DALOS|SC_NAME`, `owner-konto`, `patron` |
| `04_AQP-BOOT` | `C_Step7_CreatePoolsAndScores` | `DALOS|SC_NAME`, `account`, `client`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step8_IssueFvtEntities` | `DALOS|SC_NAME`, `account`, `client`, `owner-konto`, `patron`, `receiver`, `sender` |
| `04_AQP-BOOT` | `C_Step9_AddFvtScoreEntities` | `DALOS|SC_NAME`, `account`, `client`, `fvt-owner`, `owner-konto`, `patron`, `receiver`, `sender` |
| `03_CADUCEUS` | `A_DeployBridgeSmartAccount` | `account`, `client`, `receiver`, `sender` |
| `03_CADUCEUS` | `A_ProvisionBridgeDptfRoles` | `DALOS|SC_NAME`, `patron` |
| `03_CADUCEUS` | `A_SetBridgeActive` | — |
| `03_CADUCEUS` | `A_SetBridgeConfig` | — |
| `03_CADUCEUS` | `C_BurnFromBridgeSignal` | `DALOS|SC_NAME`, `account`, `patron` |
| `03_CADUCEUS` | `C_MintToUserFromBridgeSignal` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `01_Spark` | `C_BuySparks` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `01_Spark` | `C_CustomRedemAllSparks` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `01_Spark` | `C_CustomRedemFewSparks` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `01_Spark` | `C_RedemAllSparks` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `01_Spark` | `C_RedemFewSparks` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `01_Spark` | `P|A_Add` | — |
| `01_Spark` | `P|A_AddIMP` | — |
| `01_Spark` | `P|A_Define` | — |
| `02_Snakes` | `A_UpdateSharePrice` | — |
| `02_Snakes` | `C_Acquire` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `02_Snakes` | `P|A_Add` | — |
| `02_Snakes` | `P|A_AddIMP` | — |
| `02_Snakes` | `P|A_Define` | — |
| `03_Custodians` | `A_UpdateQuintessencePrice` | — |
| `03_Custodians` | `C_Acquire` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_Custodians` | `P|A_Add` | — |
| `03_Custodians` | `P|A_AddIMP` | — |
| `03_Custodians` | `P|A_Define` | — |
| `04_STOICPAY` | `C_BuyStoicPay` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `04_STOICPAY` | `P|A_Add` | — |
| `04_STOICPAY` | `P|A_AddIMP` | — |
| `04_STOICPAY` | `P|A_Define` | — |
| `05_STOAICO` | `AA_FlushUncollected` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `05_STOAICO` | `A_InitialiseDistributionVault` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `05_STOAICO` | `A_Inject` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `05_STOAICO` | `A_Stake` | `DALOS|SC_NAME`, `client`, `patron` |
| `05_STOAICO` | `A_Unstake` | `DALOS|SC_NAME`, `account`, `patron` |
| `05_STOAICO` | `C_Collect` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `05_STOAICO` | `P|A_Add` | — |
| `05_STOAICO` | `P|A_AddIMP` | — |
| `05_STOAICO` | `P|A_Define` | — |
| `99_TS02-CPAD` | `CUSTODIANS|C_Acquire` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `99_TS02-CPAD` | `KPAY|C_BuyStoicPay` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `99_TS02-CPAD` | `P|A_Add` | — |
| `99_TS02-CPAD` | `P|A_AddIMP` | — |
| `99_TS02-CPAD` | `P|A_Define` | — |
| `99_TS02-CPAD` | `SNAKES|C_Acquire` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `99_TS02-CPAD` | `SPARK|C_BuySparks` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `99_TS02-CPAD` | `SPARK|C_RedemAllSparks` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `99_TS02-CPAD` | `SPARK|C_RedemFewSparks` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `99_TS02-CPAD` | `STOAICO|C_Collect` | — |
| `03_DSP+` | `AA_OuroMinterStageTwo` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_KosonMinterStageOne` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_KosonMinterStageOne_1of3` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_KosonMinterStageOne_2of3` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_KosonMinterStageOne_3of3` | `DALOS|SC_NAME`, `account`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_OuroMinterStageOne` | `DALOS|SC_NAME`, `account`, `client`, `patron`, `receiver`, `sender` |
| `03_DSP+` | `A_StoicismMinter` | `DALOS|SC_NAME`, `account`, `client`, `patron` |
| `03_DSP+` | `P|A_Add` | — |
| `03_DSP+` | `P|A_AddIMP` | — |
| `03_DSP+` | `P|A_Define` | — |


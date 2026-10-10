# Entrypoint catalogue

> **This page is GENERATED.** Edit `REPL/tools/_docsref.py`, never this file — the
> gate regenerates it and diffs the result. It carries no prose for that reason.

Every client entrypoint Ouronet exposes — **437** of them — with the preview
that prices it and whether the gas station pays for it.

**Bind preview arguments by NAME, never by position.** A preview's parameter list
differs from its entrypoint's in **421**
cases. Positional binding does not fail — the values are mostly strings, so a wrong
mapping type-checks and returns a confident price for a different question.

| sponsorship | entrypoints |
|---|---:|
| fully sponsored | 419 |
| step-0-only | 10 |
| not sponsored | 8 |

## ATS

| entrypoint | preview | sponsored |
|---|---|---|
| `HOT-RBT|C_Repurpose` | `INFO-ONE.INFO_ATS|HOT-RBT|Repurpose` | **no** |
| `HOT-RBT|C_UpdatePendingBranding` | `INFO-ONE.INFO_ATS|HOT-RBT|UpdatePendingBranding` | **no** |
| `HOT-RBT|C_UpgradeBranding` | `INFO-ONE.INFO_ATS|HOT-RBT|UpgradeBranding` | **no** |

## SWPLC

| entrypoint | preview | sponsored |
|---|---|---|
| `STOA-PID|C_AddFrozenLiquidity` | `INFO-ONE.INFO_SWP|AddFrozenLiquidity` | **no** |
| `STOA-PID|C_AddGlacialLiquidity` | `INFO-ONE.INFO_SWP|AddGlacialLiquidity` | **no** |
| `STOA-PID|C_AddIcedLiquidity` | `INFO-ONE.INFO_SWP|AddIcedLiquidity` | **no** |
| `STOA-PID|C_AddSleepingLiquidity` | `INFO-ONE.INFO_SWP|AddSleepingLiquidity` | **no** |
| `STOA-PID|C_AddStandardLiquidity` | `INFO-ONE.INFO_SWP|AddStandardLiquidity` | **no** |

## TS01-C1

| entrypoint | preview | sponsored |
|---|---|---|
| `DALOS|C_ControlSmartAccount` | `INFO-ONE.INFO_DALOS|ControlSmartAccount` | yes |
| `DALOS|C_DeploySmartAccount` | `INFO-ONE.INFO_DALOS|DeploySmartAccount` | yes |
| `DALOS|C_DeployStandardAccount` | `INFO-ONE.INFO_DALOS|DeployStandardAccount` | yes |
| `DALOS|C_RotateGovernor` | `INFO-ONE.INFO_DALOS|RotateGovernor` | yes |
| `DALOS|C_RotateGuard` | `INFO-ONE.INFO_DALOS|RotateGuard` | yes |
| `DALOS|C_RotateSovereign` | `INFO-ONE.INFO_DALOS|RotateSovereign` | yes |
| `DALOS|C_RotateStoa` | `INFO-ONE.INFO_DALOS|RotateStoa` | yes |
| `DALOS|C_UpdateEliteAccount` | `INFO-ONE.INFO_DALOS|UpdateEliteAccount` | yes |
| `DALOS|C_UpdateEliteAccountSquared` | `INFO-ONE.INFO_DALOS|UpdateEliteAccountSquared` | yes |
| `DPOF|CC_WipeHeavy` | `INFO-ONE.INFO_DPOF|WipeHeavy` | yes |
| `DPOF|C_AddQuantity` | `INFO-ONE.INFO_DPOF|AddQuantity` | yes |
| `DPOF|C_BulkTransfer` | `INFO-ONE.INFO_DPOF|BulkTransfer` | yes |
| `DPOF|C_Burn` | `INFO-ONE.INFO_DPOF|Burn` | yes |
| `DPOF|C_Control` | `INFO-ONE.INFO_DPOF|Control` | yes |
| `DPOF|C_DeployAccount` | `INFO-ONE.INFO_DPOF|DeployAccount` | yes |
| `DPOF|C_Issue` | `INFO-ONE.INFO_DPOF|Issue` | yes |
| `DPOF|C_Mint` | `INFO-ONE.INFO_DPOF|Mint` | yes |
| `DPOF|C_MoveCreateRole` | `INFO-ONE.INFO_DPOF|MoveCreateRole` | yes |
| `DPOF|C_RotateOwnership` | `INFO-ONE.INFO_DPOF|RotateOwnership` | yes |
| `DPOF|C_ToggleAddQuantityRole` | `INFO-ONE.INFO_DPOF|ToggleAddQuantityRole` | yes |
| `DPOF|C_ToggleBurnRole` | `INFO-ONE.INFO_DPOF|ToggleBurnRole` | yes |
| `DPOF|C_ToggleFreezeAccount` | `INFO-ONE.INFO_DPOF|ToggleFreezeAccount` | yes |
| `DPOF|C_TogglePause` | `INFO-ONE.INFO_DPOF|TogglePause` | yes |
| `DPOF|C_ToggleTransferRole` | `INFO-ONE.INFO_DPOF|ToggleTransferRole` | yes |
| `DPOF|C_Transfer` | `INFO-ONE.INFO_DPOF|Transfer` | yes |
| `DPOF|C_Transmit` | `INFO-ONE.INFO_DPOF|Transmit` | yes |
| `DPOF|C_UpdatePendingBranding` | `INFO-ONE.INFO_DPOF|UpdatePendingBranding` | yes |
| `DPOF|C_UpgradeBranding` | `INFO-ONE.INFO_DPOF|UpgradeBranding` | yes |
| `DPOF|C_WipeClean` | `INFO-ONE.INFO_DPOF|WipeClean` | yes |
| `DPOF|C_WipePure` | `INFO-ONE.INFO_DPOF|WipePure` | yes |
| `DPOF|C_WipeSlim` | `INFO-ONE.INFO_DPOF|WipeSlim` | yes |
| `DPOF|Cp_WipeSlice` | `INFO-ONE.INFO_DPOF|WipeSlice` | yes |
| `DPTF|C_BulkTransfer` | `INFO-ONE.INFO_DPTF|BulkTransfer` | yes |
| `DPTF|C_Burn` | `INFO-ONE.INFO_DPTF|Burn` | yes |
| `DPTF|C_ClearDispo` | `INFO-ONE.INFO_DPTF|ClearDispo` | yes |
| `DPTF|C_ClearDispoForeign` | `INFO-ONE.INFO_DPTF|ClearDispoForeign` | yes |
| `DPTF|C_Control` | `INFO-ONE.INFO_DPTF|Control` | yes |
| `DPTF|C_DeployAccount` | `INFO-ONE.INFO_DPTF|DeployAccount` | yes |
| `DPTF|C_DonateFees` | `INFO-ONE.INFO_DPTF|DonateFees` | yes |
| `DPTF|C_Issue` | `INFO-ONE.INFO_DPTF|Issue` | yes |
| `DPTF|C_Mint` | `INFO-ONE.INFO_DPTF|Mint` | yes |
| `DPTF|C_MultiBulkTransfer` | `INFO-ONE.INFO_DPTF|MultiBulkTransfer` | yes |
| `DPTF|C_MultiTransfer` | `INFO-ONE.INFO_DPTF|MultiTransfer` | yes |
| `DPTF|C_ResetFeeTarget` | `INFO-ONE.INFO_DPTF|ResetFeeTarget` | yes |
| `DPTF|C_RotateOwnership` | `INFO-ONE.INFO_DPTF|RotateOwnership` | yes |
| `DPTF|C_SetFee` | `INFO-ONE.INFO_DPTF|SetFee` | yes |
| `DPTF|C_SetFeeTarget` | `INFO-ONE.INFO_DPTF|SetFeeTarget` | yes |
| `DPTF|C_SetMinMove` | `INFO-ONE.INFO_DPTF|SetMinMove` | yes |
| `DPTF|C_ToggleBurnRole` | `INFO-ONE.INFO_DPTF|ToggleBurnRole` | yes |
| `DPTF|C_ToggleFee` | `INFO-ONE.INFO_DPTF|ToggleFee` | yes |
| `DPTF|C_ToggleFeeExemptionRole` | `INFO-ONE.INFO_DPTF|ToggleFeeExemptionRole` | yes |
| `DPTF|C_ToggleFeeLock` | `INFO-ONE.INFO_DPTF|ToggleFeeLock` | yes |
| `DPTF|C_ToggleFreezeAccount` | `INFO-ONE.INFO_DPTF|ToggleFreezeAccount` | yes |
| `DPTF|C_ToggleMintRole` | `INFO-ONE.INFO_DPTF|ToggleMintRole` | yes |
| `DPTF|C_TogglePause` | `INFO-ONE.INFO_DPTF|TogglePause` | yes |
| `DPTF|C_ToggleReservation` | `INFO-ONE.INFO_DPTF|ToggleReservation` | yes |
| `DPTF|C_ToggleTransferRole` | `INFO-ONE.INFO_DPTF|ToggleTransferRole` | yes |
| `DPTF|C_Transfer` | `INFO-ONE.INFO_DPTF|Transfer` | yes |
| `DPTF|C_Transmute` | `INFO-ONE.INFO_DPTF|Transmute` | yes |
| `DPTF|C_UpdatePendingBranding` | `INFO-ONE.INFO_DPTF|UpdatePendingBranding` | yes |
| `DPTF|C_UpgradeBranding` | `INFO-ONE.INFO_DPTF|UpgradeBranding` | yes |
| `DPTF|C_Wipe` | `INFO-ONE.INFO_DPTF|Wipe` | yes |
| `DPTF|C_WipeSlim` | `INFO-ONE.INFO_DPTF|WipeSlim` | yes |

## TS01-C2

| entrypoint | preview | sponsored |
|---|---|---|
| `ATS|CC_RemoveSecondary` | `INFO-ONE.INFO_ATS|RemoveSecondary` | yes |
| `ATS|C_AddHotRBT` | `INFO-ONE.INFO_ATS|AddHotRBT` | yes |
| `ATS|C_AddSecondary` | `INFO-ONE.INFO_ATS|AddSecondary` | yes |
| `ATS|C_Brumate` | `INFO-ONE.INFO_ATS|Brumate` | yes |
| `ATS|C_Coil` | `INFO-ONE.INFO_ATS|Coil` | yes |
| `ATS|C_ColdRecovery` | `INFO-ONE.INFO_ATS|ColdRecovery` | yes |
| `ATS|C_Constrict` | `INFO-ONE.INFO_ATS|Constrict` | yes |
| `ATS|C_Control` | `INFO-ONE.INFO_ATS|Control` | yes |
| `ATS|C_ControlColdRecoveryFees` | `INFO-ONE.INFO_ATS|ControlColdRecoveryFees` | yes |
| `ATS|C_ControlHotRecoveryFee` | `INFO-ONE.INFO_ATS|ControlHotRecoveryFee` | yes |
| `ATS|C_Cull` | `INFO-ONE.INFO_ATS|Cull` | yes |
| `ATS|C_Curl` | `INFO-ONE.INFO_ATS|Curl` | yes |
| `ATS|C_DirectRecovery` | `INFO-ONE.INFO_ATS|DirectRecovery` | yes |
| `ATS|C_Fuel` | `INFO-ONE.INFO_ATS|Fuel` | yes |
| `ATS|C_HotRecovery` | `INFO-ONE.INFO_ATS|HotRecovery` | yes |
| `ATS|C_Issue` | `INFO-ONE.INFO_ATS|Issue` | yes |
| `ATS|C_KickStart` | `INFO-ONE.INFO_ATS|KickStart` | yes |
| `ATS|C_Redeem` | `INFO-ONE.INFO_ATS|Redeem` | yes |
| `ATS|C_Reverse` | `INFO-ONE.INFO_ATS|Reverse` | yes |
| `ATS|C_RotateOwnership` | `INFO-ONE.INFO_ATS|RotateOwnership` | yes |
| `ATS|C_SetColdRecoveryDuration` | `INFO-ONE.INFO_ATS|SetColdRecoveryDuration` | yes |
| `ATS|C_SetColdRecoveryFees` | `INFO-ONE.INFO_ATS|SetColdRecoveryFees` | yes |
| `ATS|C_SetDirectRecoveryFee` | `INFO-ONE.INFO_ATS|SetDirectRecoveryFee` | yes |
| `ATS|C_SetHibernationFees` | `INFO-ONE.INFO_ATS|SetHibernationFees` | yes |
| `ATS|C_SetHotRecoveryFee` | `INFO-ONE.INFO_ATS|SetHotRecoveryFee` | yes |
| `ATS|C_SwitchColdRecovery` | `INFO-ONE.INFO_ATS|SwitchColdRecovery` | yes |
| `ATS|C_SwitchDirectRecovery` | `INFO-ONE.INFO_ATS|SwitchDirectRecovery` | yes |
| `ATS|C_SwitchHotRecovery` | `INFO-ONE.INFO_ATS|SwitchHotRecovery` | yes |
| `ATS|C_Syphon` | `INFO-ONE.INFO_ATS|Syphon` | yes |
| `ATS|C_ToggleElite` | `INFO-ONE.INFO_ATS|ToggleElite` | yes |
| `ATS|C_ToggleParameterLock` | `INFO-ONE.INFO_ATS|ToggleParameterLock` | yes |
| `ATS|C_ToggleUpgrade` | `INFO-ONE.INFO_ATS|ToggleUpgrade` | yes |
| `ATS|C_UpdatePendingBranding` | `INFO-ONE.INFO_ATS|UpdatePendingBranding` | yes |
| `ATS|C_UpdateRoyalty` | `INFO-ONE.INFO_ATS|UpdateRoyalty` | yes |
| `ATS|C_UpdateSyphon` | `INFO-ONE.INFO_ATS|UpdateSyphon` | yes |
| `ATS|C_UpgradeBranding` | `INFO-ONE.INFO_ATS|UpgradeBranding` | yes |
| `ATS|C_VestedCoil` | `INFO-ONE.INFO_ATS|VestedCoil` | yes |
| `ATS|C_VestedCurl` | `INFO-ONE.INFO_ATS|VestedCurl` | yes |
| `ATS|C_WithdrawRoyalties` | `INFO-ONE.INFO_ATS|WithdrawRoyalties` | yes |
| `ATS|HOT-RBT|C_Repurpose` | `INFO-ONE.INFO_ATS|HOT-RBT|Repurpose` | yes |
| `ATS|HOT-RBT|C_UpdatePendingBranding` | `INFO-ONE.INFO_ATS|HOT-RBT|UpdatePendingBranding` | yes |
| `ATS|HOT-RBT|C_UpgradeBranding` | `INFO-ONE.INFO_ATS|HOT-RBT|UpgradeBranding` | yes |
| `LQD|C_UnwrapStoa` | `INFO-ONE.INFO_LIQUID|UnwrapStoa` | yes |
| `LQD|C_UnwrapUrStoa` | `INFO-ONE.INFO_LIQUID|UnwrapUrStoa` | yes |
| `LQD|C_WrapStoa` | `INFO-ONE.INFO_LIQUID|WrapStoa` | yes |
| `LQD|C_WrapUrStoa` | `INFO-ONE.INFO_LIQUID|WrapUrStoa` | yes |
| `ORBR|C_Compress` | `INFO-ONE.INFO_ORBR|Compress` | yes |
| `ORBR|C_Sublimate` | `INFO-ONE.INFO_ORBR|Sublimate` | yes |
| `ORBR|C_SublimateV2` | `INFO-ONE.INFO_ORBR|SublimateV2` | yes |
| `ORBR|C_WithdrawFees` | `INFO-ONE.INFO_ORBR|WithdrawFees` | yes |
| `VST|C_Awake` | `INFO-ONE.INFO_VST|Awake` | yes |
| `VST|C_CreateFrozenLink` | `INFO-ONE.INFO_VST|CreateFrozenLink` | yes |
| `VST|C_CreateHibernatingLink` | `INFO-ONE.INFO_VST|CreateHibernatingLink` | yes |
| `VST|C_CreateReservationLink` | `INFO-ONE.INFO_VST|CreateReservationLink` | yes |
| `VST|C_CreateSleepingLink` | `INFO-ONE.INFO_VST|CreateSleepingLink` | yes |
| `VST|C_CreateVestingLink` | `INFO-ONE.INFO_VST|CreateVestingLink` | yes |
| `VST|C_Freeze` | `INFO-ONE.INFO_VST|Freeze` | yes |
| `VST|C_Hibernate` | `INFO-ONE.INFO_VST|Hibernate` | yes |
| `VST|C_Merge` | `INFO-ONE.INFO_VST|Merge` | yes |
| `VST|C_RepurposeFrozen` | `INFO-ONE.INFO_VST|RepurposeFrozen` | yes |
| `VST|C_RepurposeHibernating` | `INFO-ONE.INFO_VST|RepurposeHibernating` | yes |
| `VST|C_RepurposeMerge` | `INFO-ONE.INFO_VST|RepurposeMerge` | yes |
| `VST|C_RepurposeReserved` | `INFO-ONE.INFO_VST|RepurposeReserved` | yes |
| `VST|C_RepurposeSleeping` | `INFO-ONE.INFO_VST|RepurposeSleeping` | yes |
| `VST|C_RepurposeSlumber` | `INFO-ONE.INFO_VST|RepurposeSlumber` | yes |
| `VST|C_RepurposeVested` | `INFO-ONE.INFO_VST|RepurposeVested` | yes |
| `VST|C_Reserve` | `INFO-ONE.INFO_VST|Reserve` | yes |
| `VST|C_Sleep` | `INFO-ONE.INFO_VST|Sleep` | yes |
| `VST|C_Slumber` | `INFO-ONE.INFO_VST|Slumber` | yes |
| `VST|C_ToggleTransferRoleFrozenDPTF` | `INFO-ONE.INFO_VST|ToggleTransferRoleFrozenDPTF` | yes |
| `VST|C_ToggleTransferRoleHibernatingDPOF` | `INFO-ONE.INFO_VST|ToggleTransferRoleHibernatingDPOF` | yes |
| `VST|C_ToggleTransferRoleReservedDPTF` | `INFO-ONE.INFO_VST|ToggleTransferRoleReservedDPTF` | yes |
| `VST|C_ToggleTransferRoleSleepingDPOF` | `INFO-ONE.INFO_VST|ToggleTransferRoleSleepingDPOF` | yes |
| `VST|C_Unreserve` | `INFO-ONE.INFO_VST|Unreserve` | yes |
| `VST|C_Unsleep` | `INFO-ONE.INFO_VST|Unsleep` | yes |
| `VST|C_Unvest` | `INFO-ONE.INFO_VST|Unvest` | yes |
| `VST|C_Vest` | `INFO-ONE.INFO_VST|Vest` | yes |

## TS01-C3

| entrypoint | preview | sponsored |
|---|---|---|
| `SWP|CC_SmartSwapNoSlippage` | `INFO-ONE.INFO_SWP|SmartSwapNoSlippage` | yes |
| `SWP|CC_SmartSwapWithSlippage` | `INFO-ONE.INFO_SWP|SmartSwapWithSlippage` | yes |
| `SWP|C_AddFrozenLiquidity` | `INFO-ONE.INFO_SWP|AddFrozenLiquidity` | yes |
| `SWP|C_AddGlacialLiquidity` | `INFO-ONE.INFO_SWP|AddGlacialLiquidity` | yes |
| `SWP|C_AddIcedLiquidity` | `INFO-ONE.INFO_SWP|AddIcedLiquidity` | yes |
| `SWP|C_AddLiquidity` | `INFO-ONE.INFO_SWP|AddLiquidity` | yes |
| `SWP|C_AddSleepingLiquidity` | `INFO-ONE.INFO_SWP|AddSleepingLiquidity` | yes |
| `SWP|C_ChangeOwnership` | `INFO-ONE.INFO_SWP|ChangeOwnership` | yes |
| `SWP|C_EnableFrozenLP` | `INFO-ONE.INFO_SWP|EnableFrozenLP` | yes |
| `SWP|C_EnableSleepingLP` | `INFO-ONE.INFO_SWP|EnableSleepingLP` | yes |
| `SWP|C_Firestarter` | `INFO-ONE.INFO_SWP|Firestarter` | yes |
| `SWP|C_Fuel` | `INFO-ONE.INFO_SWP|Fuel` | yes |
| `SWP|C_IssueStable` | `INFO-ONE.INFO_SWP|IssueStable` | yes |
| `SWP|C_IssueStandard` | `INFO-ONE.INFO_SWP|IssueStandard` | yes |
| `SWP|C_IssueWeighted` | `INFO-ONE.INFO_SWP|IssueWeighted` | yes |
| `SWP|C_ModifyCanChangeOwner` | `INFO-ONE.INFO_SWP|ModifyCanChangeOwner` | yes |
| `SWP|C_ModifyWeights` | `INFO-ONE.INFO_SWP|ModifyWeights` | yes |
| `SWP|C_MultiSwapNoSlippage` | `INFO-ONE.INFO_SWP|MultiSwapNoSlippage` | yes |
| `SWP|C_MultiSwapWithSlippage` | `INFO-ONE.INFO_SWP|MultiSwapWithSlippage` | yes |
| `SWP|C_RemoveLiquidity` | `INFO-ONE.INFO_SWP|RemoveLiquidity` | yes |
| `SWP|C_SingleSwapNoSlippage` | `INFO-ONE.INFO_SWP|SingleSwapNoSlippage` | yes |
| `SWP|C_SingleSwapWithSlippage` | `INFO-ONE.INFO_SWP|SingleSwapWithSlippage` | yes |
| `SWP|C_SmartSwapNoSlippage` | `INFO-ONE.INFO_SWP|SmartSwapNoSlippage` | yes |
| `SWP|C_SmartSwapWithSlippage` | `INFO-ONE.INFO_SWP|SmartSwapWithSlippage` | yes |
| `SWP|C_ToggleAddLiquidity` | `INFO-ONE.INFO_SWP|ToggleAddLiquidity` | yes |
| `SWP|C_ToggleFeeLock` | `INFO-ONE.INFO_SWP|ToggleFeeLock` | yes |
| `SWP|C_ToggleSwapCapability` | `INFO-ONE.INFO_SWP|ToggleSwapCapability` | yes |
| `SWP|C_UpdateAmplifier` | `INFO-ONE.INFO_SWP|UpdateAmplifier` | yes |
| `SWP|C_UpdateFee` | `INFO-ONE.INFO_SWP|UpdateFee` | yes |
| `SWP|C_UpdatePendingBranding` | `INFO-ONE.INFO_SWP|UpdatePendingBranding` | yes |
| `SWP|C_UpdatePendingBrandingLPs` | `INFO-ONE.INFO_SWP|UpdatePendingBrandingLPs` | yes |
| `SWP|C_UpdateSpecialFeeTargets` | `INFO-ONE.INFO_SWP|UpdateSpecialFeeTargets` | yes |
| `SWP|C_UpgradeBranding` | `INFO-ONE.INFO_SWP|UpgradeBranding` | yes |
| `SWP|C_UpgradeBrandingLPs` | `INFO-ONE.INFO_SWP|UpgradeBrandingLPs` | yes |

## TS01-C4

| entrypoint | preview | sponsored |
|---|---|---|
| `CODEX|C_RecordArweaveUpload` | `CODEX.INFO_CODEX|RecordArweaveUpload` | yes |
| `CODEX|C_RegisterStoicTag` | `CODEX.INFO_CODEX|RegisterStoicTag` | yes |
| `CODEX|C_ReleaseStoicTag` | `CODEX.INFO_CODEX|ReleaseStoicTag` | yes |
| `CODEX|C_RotateCodexGuard` | `CODEX.INFO_CODEX|RotateCodexGuard` | yes |
| `PYTHIA|C_DeployApiKey` | `PYTHIA.INFO_PYTHIA|DeployApiKey` | yes |
| `PYTHIA|C_Link` | `PYTHIA.INFO_PYTHIA|Link` | yes |
| `PYTHIA|C_RevokeLink` | `PYTHIA.INFO_PYTHIA|RevokeLink` | yes |
| `PYTHIA|C_UpdateDualConsumerLane` | `PYTHIA.INFO_PYTHIA|UpdateDualConsumerLane` | yes |

## TS01-CP

| entrypoint | preview | sponsored |
|---|---|---|
| `SWP|C_AddFrozenLiquidity` | `INFO-ONE.INFO_SWP|AddFrozenLiquidity` | *step-0-only* |
| `SWP|C_AddGlacialLiquidity` | `INFO-ONE.INFO_SWP|AddGlacialLiquidity` | *step-0-only* |
| `SWP|C_AddIcedLiquidity` | `INFO-ONE.INFO_SWP|AddIcedLiquidity` | *step-0-only* |
| `SWP|C_AddSleepingLiquidity` | `INFO-ONE.INFO_SWP|AddSleepingLiquidity` | *step-0-only* |
| `SWP|C_AddStandardLiquidity` | `INFO-ONE.INFO_SWP|AddStandardLiquidity` | *step-0-only* |
| `SWP|C_IssueStablePool` | `INFO-ONE.INFO_SWP|IssueStablePool` | *step-0-only* |
| `SWP|C_IssueStandardPool` | `INFO-ONE.INFO_SWP|IssueStandardPool` | *step-0-only* |
| `SWP|C_IssueWeightedPool` | `INFO-ONE.INFO_SWP|IssueWeightedPool` | *step-0-only* |

## TS02-C1

| entrypoint | preview | sponsored |
|---|---|---|
| `DPDC|C_BulkTransfer` | `INFO-TWO.INFO_DPDC|BulkTransfer` | yes |
| `DPDC|C_MultiTransfer` | `INFO-TWO.INFO_DPDC|MultiTransfer` | yes |
| `DPSF|CC_Break` | `INFO-TWO.INFO_DPSF|Break` | yes |
| `DPSF|CC_WipeHeavy` | `INFO-TWO.INFO_DPSF|WipeHeavy` | yes |
| `DPSF|C_AddQuantity` | `INFO-TWO.INFO_DPSF|AddQuantity` | yes |
| `DPSF|C_BulkTransfer` | `INFO-TWO.INFO_DPSF|BulkTransfer` | yes |
| `DPSF|C_Burn` | `INFO-TWO.INFO_DPSF|Burn` | yes |
| `DPSF|C_Control` | `INFO-TWO.INFO_DPSF|Control` | yes |
| `DPSF|C_Create` | `INFO-TWO.INFO_DPSF|Create` | yes |
| `DPSF|C_DefineCompositeSet` | `INFO-TWO.INFO_DPSF|DefineCompositeSet` | yes |
| `DPSF|C_DefineHybridSet` | `INFO-TWO.INFO_DPSF|DefineHybridSet` | yes |
| `DPSF|C_DefinePrimordialSet` | `INFO-TWO.INFO_DPSF|DefinePrimordialSet` | yes |
| `DPSF|C_EnableNonceFragmentation` | `INFO-TWO.INFO_DPSF|EnableNonceFragmentation` | yes |
| `DPSF|C_EnableSetClassFragmentation` | `INFO-TWO.INFO_DPSF|EnableSetClassFragmentation` | yes |
| `DPSF|C_Issue` | `INFO-TWO.INFO_DPSF|Issue` | yes |
| `DPSF|C_IssueCompany` | `INFO-TWO.INFO_DPSF|IssueCompany` | yes |
| `DPSF|C_Make` | `INFO-TWO.INFO_DPSF|Make` | yes |
| `DPSF|C_MakeFragments` | `INFO-TWO.INFO_DPSF|MakeFragments` | yes |
| `DPSF|C_MergeFragments` | `INFO-TWO.INFO_DPSF|MergeFragments` | yes |
| `DPSF|C_MorphEquity` | `INFO-TWO.INFO_DPSF|MorphEquity` | yes |
| `DPSF|C_MoveCreateRole` | `INFO-TWO.INFO_DPSF|MoveCreateRole` | yes |
| `DPSF|C_MoveRecreateRole` | `INFO-TWO.INFO_DPSF|MoveRecreateRole` | yes |
| `DPSF|C_MoveSetUriRole` | `INFO-TWO.INFO_DPSF|MoveSetUriRole` | yes |
| `DPSF|C_RemoveNonceScore` | `INFO-TWO.INFO_DPSF|RemoveNonceScore` | yes |
| `DPSF|C_RemoveSetNonceScore` | `INFO-TWO.INFO_DPSF|RemoveSetNonceScore` | yes |
| `DPSF|C_RenameSet` | `INFO-TWO.INFO_DPSF|RenameSet` | yes |
| `DPSF|C_Repurpose` | `INFO-TWO.INFO_DPSF|Repurpose` | yes |
| `DPSF|C_RepurposeFragments` | `INFO-TWO.INFO_DPSF|RepurposeFragments` | yes |
| `DPSF|C_ToggleAddQuantityRole` | `INFO-TWO.INFO_DPSF|ToggleAddQuantityRole` | yes |
| `DPSF|C_ToggleBurnRole` | `INFO-TWO.INFO_DPSF|ToggleBurnRole` | yes |
| `DPSF|C_ToggleExemptionRole` | `INFO-TWO.INFO_DPSF|ToggleExemptionRole` | yes |
| `DPSF|C_ToggleFreezeAccount` | `INFO-TWO.INFO_DPSF|ToggleFreezeAccount` | yes |
| `DPSF|C_ToggleModifyCreatorRole` | `INFO-TWO.INFO_DPSF|ToggleModifyCreatorRole` | yes |
| `DPSF|C_ToggleModifyRoyaltiesRole` | `INFO-TWO.INFO_DPSF|ToggleModifyRoyaltiesRole` | yes |
| `DPSF|C_TogglePause` | `INFO-TWO.INFO_DPSF|TogglePause` | yes |
| `DPSF|C_ToggleSet` | `INFO-TWO.INFO_DPSF|ToggleSet` | yes |
| `DPSF|C_ToggleTransferRole` | `INFO-TWO.INFO_DPSF|ToggleTransferRole` | yes |
| `DPSF|C_ToggleUpdateRole` | `INFO-TWO.INFO_DPSF|ToggleUpdateRole` | yes |
| `DPSF|C_TransferNonce` | `INFO-TWO.INFO_DPSF|TransferNonce` | yes |
| `DPSF|C_TransferNonces` | `INFO-TWO.INFO_DPSF|TransferNonces` | yes |
| `DPSF|C_UpdateNonce` | `INFO-TWO.INFO_DPSF|UpdateNonce` | yes |
| `DPSF|C_UpdateNonceDescription` | `INFO-TWO.INFO_DPSF|UpdateNonceDescription` | yes |
| `DPSF|C_UpdateNonceIgnisRoyalty` | `INFO-TWO.INFO_DPSF|UpdateNonceIgnisRoyalty` | yes |
| `DPSF|C_UpdateNonceMetaData` | `INFO-TWO.INFO_DPSF|UpdateNonceMetaData` | yes |
| `DPSF|C_UpdateNonceName` | `INFO-TWO.INFO_DPSF|UpdateNonceName` | yes |
| `DPSF|C_UpdateNonceRoyalty` | `INFO-TWO.INFO_DPSF|UpdateNonceRoyalty` | yes |
| `DPSF|C_UpdateNonceScore` | `INFO-TWO.INFO_DPSF|UpdateNonceScore` | yes |
| `DPSF|C_UpdateNonceURI` | `INFO-TWO.INFO_DPSF|UpdateNonceURI` | yes |
| `DPSF|C_UpdateNonces` | `INFO-TWO.INFO_DPSF|UpdateNonces` | yes |
| `DPSF|C_UpdatePendingBranding` | `INFO-TWO.INFO_DPSF|UpdatePendingBranding` | yes |
| `DPSF|C_UpdateSetNonce` | `INFO-TWO.INFO_DPSF|UpdateSetNonce` | yes |
| `DPSF|C_UpdateSetNonceDescription` | `INFO-TWO.INFO_DPSF|UpdateSetNonceDescription` | yes |
| `DPSF|C_UpdateSetNonceIgnisRoyalty` | `INFO-TWO.INFO_DPSF|UpdateSetNonceIgnisRoyalty` | yes |
| `DPSF|C_UpdateSetNonceMetaData` | `INFO-TWO.INFO_DPSF|UpdateSetNonceMetaData` | yes |
| `DPSF|C_UpdateSetNonceName` | `INFO-TWO.INFO_DPSF|UpdateSetNonceName` | yes |
| `DPSF|C_UpdateSetNonceRoyalty` | `INFO-TWO.INFO_DPSF|UpdateSetNonceRoyalty` | yes |
| `DPSF|C_UpdateSetNonceScore` | `INFO-TWO.INFO_DPSF|UpdateSetNonceScore` | yes |
| `DPSF|C_UpdateSetNonceURI` | `INFO-TWO.INFO_DPSF|UpdateSetNonceURI` | yes |
| `DPSF|C_UpdateSetNonces` | `INFO-TWO.INFO_DPSF|UpdateSetNonces` | yes |
| `DPSF|C_UpgradeBranding` | `INFO-TWO.INFO_DPSF|UpgradeBranding` | yes |
| `DPSF|C_WipeClean` | `INFO-TWO.INFO_DPSF|WipeClean` | yes |
| `DPSF|C_WipeDirty` | `INFO-TWO.INFO_DPSF|WipeDirty` | yes |
| `DPSF|C_WipeNonce` | `INFO-TWO.INFO_DPSF|WipeNonce` | yes |
| `DPSF|C_WipeNoncePartialy` | `INFO-TWO.INFO_DPSF|WipeNoncePartialy` | yes |
| `DPSF|C_WipePure` | `INFO-TWO.INFO_DPSF|WipePure` | yes |
| `DPSF|Cp_WipeSlice` | `INFO-TWO.INFO_DPSF|WipeSlice` | yes |

## TS02-C2

| entrypoint | preview | sponsored |
|---|---|---|
| `DPNF|CC_WipeHeavy` | `INFO-TWO.INFO_DPNF|WipeHeavy` | yes |
| `DPNF|C_Break` | `INFO-TWO.INFO_DPNF|Break` | yes |
| `DPNF|C_BulkTransfer` | `INFO-TWO.INFO_DPNF|BulkTransfer` | yes |
| `DPNF|C_Burn` | `INFO-TWO.INFO_DPNF|Burn` | yes |
| `DPNF|C_Control` | `INFO-TWO.INFO_DPNF|Control` | yes |
| `DPNF|C_Create` | `INFO-TWO.INFO_DPNF|Create` | yes |
| `DPNF|C_DefineCompositeSet` | `INFO-TWO.INFO_DPNF|DefineCompositeSet` | yes |
| `DPNF|C_DefineHybridSet` | `INFO-TWO.INFO_DPNF|DefineHybridSet` | yes |
| `DPNF|C_DefinePrimordialSet` | `INFO-TWO.INFO_DPNF|DefinePrimordialSet` | yes |
| `DPNF|C_EnableNonceFragmentation` | `INFO-TWO.INFO_DPNF|EnableNonceFragmentation` | yes |
| `DPNF|C_EnableSetClassFragmentation` | `INFO-TWO.INFO_DPNF|EnableSetClassFragmentation` | yes |
| `DPNF|C_Issue` | `INFO-TWO.INFO_DPNF|Issue` | yes |
| `DPNF|C_Make` | `INFO-TWO.INFO_DPNF|Make` | yes |
| `DPNF|C_MakeFragments` | `INFO-TWO.INFO_DPNF|MakeFragments` | yes |
| `DPNF|C_MergeFragments` | `INFO-TWO.INFO_DPNF|MergeFragments` | yes |
| `DPNF|C_MoveCreateRole` | `INFO-TWO.INFO_DPNF|MoveCreateRole` | yes |
| `DPNF|C_MoveRecreateRole` | `INFO-TWO.INFO_DPNF|MoveRecreateRole` | yes |
| `DPNF|C_MoveSetUriRole` | `INFO-TWO.INFO_DPNF|MoveSetUriRole` | yes |
| `DPNF|C_RemoveNonceScore` | `INFO-TWO.INFO_DPNF|RemoveNonceScore` | yes |
| `DPNF|C_RemoveSetNonceScore` | `INFO-TWO.INFO_DPNF|RemoveSetNonceScore` | yes |
| `DPNF|C_RenameSet` | `INFO-TWO.INFO_DPNF|RenameSet` | yes |
| `DPNF|C_Repurpose` | `INFO-TWO.INFO_DPNF|Repurpose` | yes |
| `DPNF|C_RepurposeFragments` | `INFO-TWO.INFO_DPNF|RepurposeFragments` | yes |
| `DPNF|C_Respawn` | `INFO-TWO.INFO_DPNF|Respawn` | yes |
| `DPNF|C_ToggleBurnRole` | `INFO-TWO.INFO_DPNF|ToggleBurnRole` | yes |
| `DPNF|C_ToggleExemptionRole` | `INFO-TWO.INFO_DPNF|ToggleExemptionRole` | yes |
| `DPNF|C_ToggleFreezeAccount` | `INFO-TWO.INFO_DPNF|ToggleFreezeAccount` | yes |
| `DPNF|C_ToggleModifyCreatorRole` | `INFO-TWO.INFO_DPNF|ToggleModifyCreatorRole` | yes |
| `DPNF|C_ToggleModifyRoyaltiesRole` | `INFO-TWO.INFO_DPNF|ToggleModifyRoyaltiesRole` | yes |
| `DPNF|C_TogglePause` | `INFO-TWO.INFO_DPNF|TogglePause` | yes |
| `DPNF|C_ToggleSet` | `INFO-TWO.INFO_DPNF|ToggleSet` | yes |
| `DPNF|C_ToggleTransferRole` | `INFO-TWO.INFO_DPNF|ToggleTransferRole` | yes |
| `DPNF|C_ToggleUpdateRole` | `INFO-TWO.INFO_DPNF|ToggleUpdateRole` | yes |
| `DPNF|C_TransferNonce` | `INFO-TWO.INFO_DPNF|TransferNonce` | yes |
| `DPNF|C_TransferNonces` | `INFO-TWO.INFO_DPNF|TransferNonces` | yes |
| `DPNF|C_UpdateNonce` | `INFO-TWO.INFO_DPNF|UpdateNonce` | yes |
| `DPNF|C_UpdateNonceDescription` | `INFO-TWO.INFO_DPNF|UpdateNonceDescription` | yes |
| `DPNF|C_UpdateNonceIgnisRoyalty` | `INFO-TWO.INFO_DPNF|UpdateNonceIgnisRoyalty` | yes |
| `DPNF|C_UpdateNonceMetaData` | `INFO-TWO.INFO_DPNF|UpdateNonceMetaData` | yes |
| `DPNF|C_UpdateNonceName` | `INFO-TWO.INFO_DPNF|UpdateNonceName` | yes |
| `DPNF|C_UpdateNonceRoyalty` | `INFO-TWO.INFO_DPNF|UpdateNonceRoyalty` | yes |
| `DPNF|C_UpdateNonceScore` | `INFO-TWO.INFO_DPNF|UpdateNonceScore` | yes |
| `DPNF|C_UpdateNonceURI` | `INFO-TWO.INFO_DPNF|UpdateNonceURI` | yes |
| `DPNF|C_UpdateNonces` | `INFO-TWO.INFO_DPNF|UpdateNonces` | yes |
| `DPNF|C_UpdatePendingBranding` | `INFO-TWO.INFO_DPNF|UpdatePendingBranding` | yes |
| `DPNF|C_UpdateSetNonce` | `INFO-TWO.INFO_DPNF|UpdateSetNonce` | yes |
| `DPNF|C_UpdateSetNonceDescription` | `INFO-TWO.INFO_DPNF|UpdateSetNonceDescription` | yes |
| `DPNF|C_UpdateSetNonceIgnisRoyalty` | `INFO-TWO.INFO_DPNF|UpdateSetNonceIgnisRoyalty` | yes |
| `DPNF|C_UpdateSetNonceMetaData` | `INFO-TWO.INFO_DPNF|UpdateSetNonceMetaData` | yes |
| `DPNF|C_UpdateSetNonceName` | `INFO-TWO.INFO_DPNF|UpdateSetNonceName` | yes |
| `DPNF|C_UpdateSetNonceRoyalty` | `INFO-TWO.INFO_DPNF|UpdateSetNonceRoyalty` | yes |
| `DPNF|C_UpdateSetNonceScore` | `INFO-TWO.INFO_DPNF|UpdateSetNonceScore` | yes |
| `DPNF|C_UpdateSetNonceURI` | `INFO-TWO.INFO_DPNF|UpdateSetNonceURI` | yes |
| `DPNF|C_UpdateSetNonces` | `INFO-TWO.INFO_DPNF|UpdateSetNonces` | yes |
| `DPNF|C_UpgradeBranding` | `INFO-TWO.INFO_DPNF|UpgradeBranding` | yes |
| `DPNF|C_WipeClean` | `INFO-TWO.INFO_DPNF|WipeClean` | yes |
| `DPNF|C_WipeDirty` | `INFO-TWO.INFO_DPNF|WipeDirty` | yes |
| `DPNF|C_WipeNonce` | `INFO-TWO.INFO_DPNF|WipeNonce` | yes |
| `DPNF|C_WipePure` | `INFO-TWO.INFO_DPNF|WipePure` | yes |
| `DPNF|Cp_WipeSlice` | `INFO-TWO.INFO_DPNF|WipeSlice` | yes |

## TS02-C3

| entrypoint | preview | sponsored |
|---|---|---|
| `AQP-ANK|C_IssueNonFungibleAnchor` | `AQP-INFO.INFO_AQP-ANK|IssueNonFungibleAnchor` | yes |
| `AQP-ANK|C_IssueNonFungibleSetAnchor` | `AQP-INFO.INFO_AQP-ANK|IssueNonFungibleSetAnchor` | yes |
| `AQP-ANK|C_IssueSemiFungibleAnchor` | `AQP-INFO.INFO_AQP-ANK|IssueSemiFungibleAnchor` | yes |
| `AQP-ANK|C_IssueTrueFungibleAnchor` | `AQP-INFO.INFO_AQP-ANK|IssueTrueFungibleAnchor` | yes |
| `AQP-ANK|C_RevokeAnchor` | `AQP-INFO.INFO_AQP-ANK|RevokeAnchor` | yes |
| `AQP-ANK|C_RevokeBoostClass` | `AQP-INFO.INFO_AQP-ANK|RevokeBoostClass` | yes |
| `AQP-DSA|CC_OpenAgency` | `AQP-INFO.INFO_AQP-DSA|OpenAgency` | yes |
| `AQP-DSA|C_BurnRoyalty` | `AQP-INFO.INFO_AQP-DSA|BurnRoyalty` | yes |
| `AQP-DSA|C_DefineDelegationVault` | `AQP-INFO.INFO_AQP-DSA|DefineDelegationVault` | yes |
| `AQP-DSA|C_FuelRoyalty` | `AQP-INFO.INFO_AQP-DSA|FuelRoyalty` | yes |
| `AQP-DSA|C_OracleWrite` | `AQP-INFO.INFO_AQP-DSA|OracleWrite` | yes |
| `AQP-DSA|C_RecomputeCapture` | `AQP-INFO.INFO_AQP-DSA|RecomputeCapture` | yes |
| `AQP-DSA|C_SetAgencyFee` | `AQP-INFO.INFO_AQP-DSA|SetAgencyFee` | yes |
| `AQP-DSA|C_SetOracleAuth` | `AQP-INFO.INFO_AQP-DSA|SetOracleAuth` | yes |
| `AQP-DSA|C_WithdrawRoyalty` | `AQP-INFO.INFO_AQP-DSA|WithdrawRoyalty` | yes |
| `AQP-FVT|CC_ClearPoolSweep` | `AQP-INFO.INFO_AQP-FVT|ClearPoolSweep` | yes |
| `AQP-FVT|CC_Collect` | `AQP-INFO.INFO_AQP-FVT|Collect` | yes |
| `AQP-FVT|CC_Inject` | `AQP-INFO.INFO_AQP-FVT|Inject` | yes |
| `AQP-FVT|CC_InjectFinalize` | `AQP-INFO.INFO_AQP-FVT|InjectFinalize` | yes |
| `AQP-FVT|CC_InjectStream` | `AQP-INFO.INFO_AQP-FVT|InjectStream` | yes |
| `AQP-FVT|CC_SweepBegin` | `AQP-INFO.INFO_AQP-FVT|SweepBegin` | yes |
| `AQP-FVT|CC_SweepRevokeAnchor` | `AQP-INFO.INFO_AQP-FVT|SweepRevokeAnchor` | yes |
| `AQP-FVT|CC_UnstaleMyScores` | `AQP-INFO.INFO_AQP-FVT|UnstaleMyScores` | yes |
| `AQP-FVT|CCp_FvtFixSlice` | `AQP-INFO.INFO_AQP-FVT|FvtFixSlice` | yes |
| `AQP-FVT|CCp_InjectFixChunk` | `AQP-INFO.INFO_AQP-FVT|InjectFixChunk` | yes |
| `AQP-FVT|CCp_SweepRecomputeChunk` | `AQP-INFO.INFO_AQP-FVT|SweepRecomputeChunk` | yes |
| `AQP-FVT|CCp_UnstaleAll` | `AQP-INFO.INFO_AQP-FVT|UnstaleAll` | yes |
| `AQP-FVT|C_AddRewardLink` | `AQP-INFO.INFO_AQP-FVT|AddRewardLink` | yes |
| `AQP-FVT|C_AddScoreEntity` | `AQP-INFO.INFO_AQP-FVT|AddScoreEntity` | yes |
| `AQP-FVT|C_Control` | `AQP-INFO.INFO_AQP-FVT|Control` | yes |
| `AQP-FVT|C_Issue` | `AQP-INFO.INFO_AQP-FVT|Issue` | yes |
| `AQP-FVT|C_IssueGenericEarningVault` | `AQP-INFO.INFO_AQP-FVT|IssueGenericEarningVault` | yes |
| `AQP-FVT|C_IssueMultipletFamily` | `AQP-INFO.INFO_AQP-FVT|IssueMultipletFamily` | yes |
| `AQP-FVT|C_RotateOwnership` | `AQP-INFO.INFO_AQP-FVT|RotateOwnership` | yes |
| `AQP-FVT|C_SetCommonDenominator` | `AQP-INFO.INFO_AQP-FVT|SetCommonDenominator` | yes |
| `AQP-FVT|C_SetMosaic` | `AQP-INFO.INFO_AQP-FVT|SetMosaic` | yes |
| `AQP-FVT|C_SetQualitySplit` | `AQP-INFO.INFO_AQP-FVT|SetQualitySplit` | yes |
| `AQP-FVT|C_SetSplitMode` | `AQP-INFO.INFO_AQP-FVT|SetSplitMode` | yes |
| `AQP-FVT|C_ToggleRewardLink` | `AQP-INFO.INFO_AQP-FVT|ToggleRewardLink` | yes |
| `AQP-FVT|C_ToggleScoreEntityLink` | `AQP-INFO.INFO_AQP-FVT|ToggleScoreEntityLink` | yes |
| `AQP-POOL|CC_FinalizeScoreRevoke` | `AQP-INFO.INFO_AQP-POOL|FinalizeScoreRevoke` | yes |
| `AQP-POOL|CC_FullVacate` | `AQP-INFO.INFO_AQP-POOL|FullVacate` | yes |
| `AQP-POOL|CC_StakeNonFungibleCollectable` | `AQP-INFO.INFO_AQP-POOL|StakeNonFungibleCollectable` | yes |
| `AQP-POOL|CC_StakeOrtoFungible` | `AQP-INFO.INFO_AQP-POOL|StakeOrtoFungible` | yes |
| `AQP-POOL|CC_StakeSemiFungibleCollectable` | `AQP-INFO.INFO_AQP-POOL|StakeSemiFungibleCollectable` | yes |
| `AQP-POOL|CC_StakeTrueFungible` | `AQP-INFO.INFO_AQP-POOL|StakeTrueFungible` | yes |
| `AQP-POOL|CC_UnstakeNonFungibleCollectable` | `AQP-INFO.INFO_AQP-POOL|UnstakeNonFungibleCollectable` | yes |
| `AQP-POOL|CC_UnstakeOrtoFungible` | `AQP-INFO.INFO_AQP-POOL|UnstakeOrtoFungible` | yes |
| `AQP-POOL|CC_UnstakeSemiFungibleCollectable` | `AQP-INFO.INFO_AQP-POOL|UnstakeSemiFungibleCollectable` | yes |
| `AQP-POOL|CC_UnstakeTrueFungible` | `AQP-INFO.INFO_AQP-POOL|UnstakeTrueFungible` | yes |
| `AQP-POOL|CC_UpdateScoreMultipliers` | `AQP-INFO.INFO_AQP-POOL|UpdateScoreMultipliers` | yes |
| `AQP-POOL|CC_VacateNonFungible` | `AQP-INFO.INFO_AQP-POOL|VacateNonFungible` | yes |
| `AQP-POOL|CC_VacateOrtoFungible` | `AQP-INFO.INFO_AQP-POOL|VacateOrtoFungible` | yes |
| `AQP-POOL|CC_VacateSemiFungible` | `AQP-INFO.INFO_AQP-POOL|VacateSemiFungible` | yes |
| `AQP-POOL|CC_VacateTrueFungible` | `AQP-INFO.INFO_AQP-POOL|VacateTrueFungible` | yes |
| `AQP-POOL|CCp_BackfillScoreSlice` | `AQP-INFO.INFO_AQP-POOL|BackfillScoreSlice` | yes |
| `AQP-POOL|CCp_BatchDrainCollectable` | `AQP-INFO.INFO_AQP-POOL|BatchDrainCollectable` | yes |
| `AQP-POOL|CCp_BatchDrainOrtoFungible` | `AQP-INFO.INFO_AQP-POOL|BatchDrainOrtoFungible` | yes |
| `AQP-POOL|CCp_BatchDrainTrueFungible` | `AQP-INFO.INFO_AQP-POOL|BatchDrainTrueFungible` | yes |
| `AQP-POOL|CCp_BatchVacateCollectables` | `AQP-INFO.INFO_AQP-POOL|BatchVacateCollectables` | yes |
| `AQP-POOL|CCp_BatchVacateOrtoFungible` | `AQP-INFO.INFO_AQP-POOL|BatchVacateOrtoFungible` | yes |
| `AQP-POOL|CCp_BatchVacateTrueFungible` | `AQP-INFO.INFO_AQP-POOL|BatchVacateTrueFungible` | yes |
| `AQP-POOL|CCp_ReassignCustodialBeneficiary` | `AQP-INFO.INFO_AQP-POOL|ReassignCustodialBeneficiary` | yes |
| `AQP-POOL|CCp_ReleaseSpecialCustodial` | `AQP-INFO.INFO_AQP-POOL|ReleaseSpecialCustodial` | yes |
| `AQP-POOL|CCp_StakeSpecialCustodial` | `AQP-INFO.INFO_AQP-POOL|StakeSpecialCustodial` | yes |
| `AQP-POOL|C_AbortVacate` | `AQP-INFO.INFO_AQP-POOL|AbortVacate` | yes |
| `AQP-POOL|C_AddScore` | `AQP-INFO.INFO_AQP-POOL|AddScore` | yes |
| `AQP-POOL|C_BeginScoreRevoke` | `AQP-INFO.INFO_AQP-POOL|BeginScoreRevoke` | yes |
| `AQP-POOL|C_DisablePoolStake` | `AQP-INFO.INFO_AQP-POOL|DisablePoolStake` | yes |
| `AQP-POOL|C_EnablePoolStake` | `AQP-INFO.INFO_AQP-POOL|EnablePoolStake` | yes |
| `AQP-POOL|C_FinalizeVacate` | `AQP-INFO.INFO_AQP-POOL|FinalizeVacate` | yes |
| `AQP-POOL|C_Issue` | `AQP-INFO.INFO_AQP-POOL|Issue` | yes |
| `AQP-POOL|C_RevokeScore` | `AQP-INFO.INFO_AQP-POOL|RevokeScore` | yes |
| `AQP-POOL|C_SyncNonFungibleAnchors` | `AQP-INFO.INFO_AQP-POOL|SyncNonFungibleAnchors` | yes |
| `AQP-POOL|C_SyncSemiFungibleAnchors` | `AQP-INFO.INFO_AQP-POOL|SyncSemiFungibleAnchors` | yes |
| `AQP-POOL|C_SyncTrueFungibleAnchors` | `AQP-INFO.INFO_AQP-POOL|SyncTrueFungibleAnchors` | yes |
| `AQP-POOL|Cp_DrainScoreSlice` | `AQP-INFO.INFO_AQP-POOL|DrainScoreSlice` | yes |
| `AQP-SCR|C_CombineTripletScoreModel` | `AQP-INFO.INFO_AQP-SCR|CombineTripletScoreModel` | yes |
| `AQP-SCR|C_ControlScore` | `AQP-INFO.INFO_AQP-SCR|ControlScore` | yes |
| `AQP-SCR|C_CreateScoreBoostClassLink` | `AQP-INFO.INFO_AQP-SCR|CreateScoreBoostClassLink` | yes |
| `AQP-SCR|C_CreateScoreBoostLink` | `AQP-INFO.INFO_AQP-SCR|CreateScoreBoostLink` | yes |
| `AQP-SCR|C_EnableDebBoost` | `AQP-INFO.INFO_AQP-SCR|EnableDebBoost` | yes |
| `AQP-SCR|C_IssueLiquidityScore` | `AQP-INFO.INFO_AQP-SCR|IssueLiquidityScore` | yes |
| `AQP-SCR|C_IssueNonFungibleScore` | `AQP-INFO.INFO_AQP-SCR|IssueNonFungibleScore` | yes |
| `AQP-SCR|C_IssueNonFungibleScoreDefinition` | `AQP-INFO.INFO_AQP-SCR|IssueNonFungibleScoreDefinition` | yes |
| `AQP-SCR|C_IssueNonFungibleSetScoreDefinition` | `AQP-INFO.INFO_AQP-SCR|IssueNonFungibleSetScoreDefinition` | yes |
| `AQP-SCR|C_IssueOrtoFungibleScore` | `AQP-INFO.INFO_AQP-SCR|IssueOrtoFungibleScore` | yes |
| `AQP-SCR|C_IssueScoreFromModel` | `AQP-INFO.INFO_AQP-SCR|IssueScoreFromModel` | yes |
| `AQP-SCR|C_IssueSemiFungibleScore` | `AQP-INFO.INFO_AQP-SCR|IssueSemiFungibleScore` | yes |
| `AQP-SCR|C_IssueSemiFungibleScoreDefinition` | `AQP-INFO.INFO_AQP-SCR|IssueSemiFungibleScoreDefinition` | yes |
| `AQP-SCR|C_IssueSingleScoreModel` | `AQP-INFO.INFO_AQP-SCR|IssueSingleScoreModel` | yes |
| `AQP-SCR|C_IssueTriplet` | `AQP-INFO.INFO_AQP-SCR|IssueTriplet` | yes |
| `AQP-SCR|C_IssueTrueFungibleScore` | `AQP-INFO.INFO_AQP-SCR|IssueTrueFungibleScore` | yes |
| `AQP-SCR|C_RotateScoreOwnership` | `AQP-INFO.INFO_AQP-SCR|RotateScoreOwnership` | yes |
| `MTX-AQP|2|CC_Inject` | `AQP-INFO.INFO_AQP-MTX|2Inject` | *step-0-only* |
| `MTX-AQP|2|CC_SweepRevokeAnchor` | `AQP-INFO.INFO_AQP-MTX|2SweepRevokeAnchor` | *step-0-only* |

## TS02-CPAD

| entrypoint | preview | sponsored |
|---|---|---|
| `CUSTODIANS|C_Acquire` | `DEMIPAD-CUSTODIANS.INFO_Acquire` | yes |
| `KPAY|C_BuyStoicPay` | `DEMIPAD-STOICPAY.INFO_BuyStoicPay` | yes |
| `SNAKES|C_Acquire` | `DEMIPAD-SNAKES.INFO_Acquire` | yes |
| `SPARK|C_BuySparks` | `DEMIPAD-SPARK.INFO_BuySparks` | yes |
| `SPARK|C_RedemAllSparks` | `DEMIPAD-SPARK.INFO_RedeemSparks` | yes |
| `SPARK|C_RedemFewSparks` | `DEMIPAD-SPARK.INFO_RedeemSparks` | yes |
| `STOAICO|C_Collect` | `STOAICO.INFO_Collect` | yes |

## TS02-DPAD

| entrypoint | preview | sponsored |
|---|---|---|
| `DEMIPAD|C_Deposit` | `INFO-TWO.INFO_DEMIPAD|Deposit` | yes |
| `DEMIPAD|C_FuelNonFungible` | `INFO-TWO.INFO_DEMIPAD|FuelNonFungible` | yes |
| `DEMIPAD|C_FuelOrtoFungible` | `INFO-TWO.INFO_DEMIPAD|FuelOrtoFungible` | yes |
| `DEMIPAD|C_FuelSemiFungible` | `INFO-TWO.INFO_DEMIPAD|FuelSemiFungible` | yes |
| `DEMIPAD|C_FuelTrueFungible` | `INFO-TWO.INFO_DEMIPAD|FuelTrueFungible` | yes |
| `DEMIPAD|C_RetrieveNonFungible` | `INFO-TWO.INFO_DEMIPAD|RetrieveNonFungible` | yes |
| `DEMIPAD|C_RetrieveOrtoFungible` | `INFO-TWO.INFO_DEMIPAD|RetrieveOrtoFungible` | yes |
| `DEMIPAD|C_RetrieveSemiFungible` | `INFO-TWO.INFO_DEMIPAD|RetrieveSemiFungible` | yes |
| `DEMIPAD|C_RetrieveTrueFungible` | `INFO-TWO.INFO_DEMIPAD|RetrieveTrueFungible` | yes |
| `DEMIPAD|C_Withdraw` | `INFO-TWO.INFO_DEMIPAD|Withdraw` | yes |

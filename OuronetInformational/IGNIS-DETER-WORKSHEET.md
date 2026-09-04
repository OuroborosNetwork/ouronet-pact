# IGNIS deterrence worksheet (#76) — SUGGESTED, for owner revision

COMPUTE = IG|TX 1 + 2·writes + reads + scans + xcalls (module-internal transitive; approximate —
cross-module callee internals not summed, so delegating ops read low). FINAL = COMPUTE × deter.
deter default 1 (no extra). Revise the `deter` column; I green-light nothing myself.


## 01_DALOS.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_RotateStoa` | SETUP | 3 | 3 | 0 | 3 | 13 | 1 | 13 |  |
| `C_DeploySmartAccount` | ISSUE | 3 | 2 | 0 | 3 | 12 | 1 | 12 |  |
| `C_DeployStandardAccount` | ISSUE | 3 | 2 | 0 | 3 | 12 | 1 | 12 |  |
| `A_DeploySmartAccount` | ISSUE | 3 | 1 | 0 | 2 | 10 | 1 | 10 |  |
| `A_DeployStandardAccount` | ISSUE | 3 | 1 | 0 | 2 | 10 | 1 | 10 |  |
| `C_RotateGuard` | SETUP | 2 | 2 | 0 | 1 | 8 | 1 | 8 |  |
| `A_ToggleGasCollection` | USAGE | 2 | 1 | 0 | 1 | 7 | 1 | 7 |  |
| `A_MigrateLiquidFunds` | SETUP | 0 | 1 | 0 | 4 | 6 | 1 | 6 |  |
| `A_UpdateUsagePrice` | SETUP | 1 | 1 | 0 | 2 | 6 | 1 | 6 |  |
| `A_ToggleOAPU` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `A_ToggleGAP` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `A_SetIgnisSourcePrice` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `A_SetAutoFueling` | USAGE | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `A_UpdatePublicKey` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `C_ControlSmartAccount` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `C_RotateGovernor` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `C_RotateSovereign` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |

## 02_IGNIS.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Collect` | USAGE | 0 | 2 | 0 | 24 | 27 | 1 | 27 |  |
| `C_TransferDalosFuel` | USAGE | 0 | 0 | 0 | 1 | 2 | 1 | 2 |  |

## 04_BRD.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Live` | SETUP | 2 | 3 | 0 | 1 | 9 | 1 | 9 |  |
| `A_SetFlag` | SETUP | 2 | 3 | 0 | 1 | 9 | 1 | 9 |  |

## 05_DPTF.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_WipeTreasuryDebt` | SETUP | 5 | 9 | 0 | 16 | 36 | 1 | 36 |  |
| `A_WipeTreasuryDebtPartial` | SETUP | 5 | 9 | 0 | 15 | 35 | 1 | 35 |  |
| `C_Mint` | ISSUE | 5 | 9 | 0 | 13 | 33 | 1 | 33 |  |
| `C_Burn` | SETUP | 3 | 7 | 0 | 11 | 25 | 1 | 25 |  |
| `C_Issue` | ISSUE | 3 | 3 | 0 | 14 | 24 | 1 | 24 |  |
| `C_WipeSlim` | SETUP | 3 | 8 | 0 | 9 | 24 | 1 | 24 |  |
| `C_Wipe` | SETUP | 3 | 8 | 0 | 9 | 24 | 1 | 24 |  |
| `C_ToggleFreezeAccount` | SETUP | 3 | 6 | 0 | 9 | 22 | 1 | 22 |  |
| `C_ToggleBurnRole` | SETUP | 3 | 6 | 0 | 9 | 22 | 1 | 22 |  |
| `C_ToggleMintRole` | SETUP | 3 | 6 | 0 | 9 | 22 | 1 | 22 |  |
| `C_ToggleFeeExemptionRole` | SETUP | 3 | 6 | 0 | 9 | 22 | 1 | 22 |  |
| `C_ToggleTransferRole` | USAGE | 3 | 6 | 0 | 9 | 22 | 1 | 22 |  |
| `C_ToggleFeeLock` | SETUP | 2 | 4 | 0 | 7 | 16 | 1 | 16 |  |
| `C_UpgradeBranding` | SETUP | 0 | 4 | 0 | 4 | 9 | 1 | 9 |  |
| `C_DeployAccount` | ISSUE | 1 | 3 | 0 | 3 | 9 | 1 | 9 |  |
| `C_RotateOwnership` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_Control` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_TogglePause` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_ToggleReservation` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_ToggleFee` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_SetMinMove` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_SetFee` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_SetFeeTarget` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_UpdatePendingBranding` | SETUP | 0 | 2 | 0 | 3 | 6 | 1 | 6 |  |
| `A_UpdateTreasury` | SETUP | 0 | 1 | 0 | 2 | 4 | 1 | 4 |  |

## 06_DPOF.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Transmit` | SETUP | 7 | 13 | 0 | 7 | 35 | 1 | 35 |  |
| `C_Mint` | ISSUE | 6 | 11 | 0 | 4 | 28 | 1 | 28 |  |
| `C_AddQuantity` | SETUP | 6 | 11 | 0 | 3 | 27 | 1 | 27 |  |
| `C_WipeHeavy` | SETUP | 5 | 7 | 3 | 5 | 26 | 1 | 26 |  |
| `C_WipePure` | SETUP | 5 | 7 | 3 | 5 | 26 | 1 | 26 |  |
| `C_WipeClean` | SETUP | 5 | 7 | 3 | 5 | 26 | 1 | 26 |  |
| `C_Issue` | ISSUE | 3 | 4 | 0 | 13 | 24 | 1 | 24 |  |
| `C_Transfer` | USAGE | 3 | 8 | 0 | 7 | 22 | 1 | 22 |  |
| `C_BulkTransfer` | USAGE | 3 | 8 | 0 | 7 | 22 | 1 | 22 |  |
| `C_Burn` | SETUP | 5 | 7 | 0 | 2 | 20 | 1 | 20 |  |
| `C_WipeSlim` | SETUP | 5 | 7 | 0 | 2 | 20 | 1 | 20 |  |
| `C_ToggleFreezeAccount` | SETUP | 3 | 7 | 0 | 4 | 18 | 1 | 18 |  |
| `C_ToggleAddQuantityRole` | SETUP | 3 | 7 | 0 | 4 | 18 | 1 | 18 |  |
| `C_ToggleBurnRole` | SETUP | 3 | 7 | 0 | 4 | 18 | 1 | 18 |  |
| `C_MoveCreateRole` | SETUP | 4 | 6 | 0 | 3 | 18 | 1 | 18 |  |
| `C_ToggleTransferRole` | USAGE | 3 | 7 | 0 | 4 | 18 | 1 | 18 |  |
| `C_UpgradeBranding` | SETUP | 0 | 5 | 0 | 5 | 11 | 1 | 11 |  |
| `C_DeployAccount` | ISSUE | 1 | 4 | 0 | 2 | 9 | 1 | 9 |  |
| `C_RotateOwnership` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_Control` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_TogglePause` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_UpdatePendingBranding` | SETUP | 0 | 2 | 0 | 3 | 6 | 1 | 6 |  |

## 08_ATS.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 1 | 1 | 0 | 18 | 22 | 1 | 22 |  |
| `C_AddHotRBT` | SETUP | 1 | 1 | 0 | 12 | 16 | 1 | 16 |  |
| `C_ToggleParameterLock` | SETUP | 2 | 3 | 0 | 7 | 15 | 1 | 15 |  |
| `C_AddSecondary` | SETUP | 1 | 2 | 0 | 9 | 14 | 1 | 14 |  |
| `C_SetColdRecoveryDuration` | SETUP | 2 | 2 | 0 | 4 | 11 | 1 | 11 |  |
| `C_SetColdRecoveryFees` | SETUP | 1 | 1 | 0 | 6 | 10 | 1 | 10 |  |
| `C_UpgradeBranding` | SETUP | 0 | 2 | 0 | 4 | 7 | 1 | 7 |  |
| `C_RotateOwnership` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_Control` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_UpdateRoyalty` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_UpdateSyphon` | USAGE | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_SetHibernationFees` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_ControlColdRecoveryFees` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_ToggleElite` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_ToggleUpgrade` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_SwitchColdRecovery` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_ControlHotRecoveryFee` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_SetHotRecoveryFees` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_SwitchHotRecovery` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_SetDirectRecoveryFee` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_SwitchDirectRecovery` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_UpdatePendingBranding` | SETUP | 0 | 2 | 0 | 3 | 6 | 1 | 6 |  |

## 09_TFT.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_MultiBulkTransfer` | USAGE | 0 | 1 | 0 | 71 | 73 | 1 | 73 |  |
| `C_MultiTransfer` | USAGE | 0 | 1 | 0 | 69 | 71 | 1 | 71 |  |
| `C_Transfer` | USAGE | 0 | 1 | 0 | 68 | 70 | 1 | 70 |  |
| `C_Transmute` | SETUP | 0 | 1 | 0 | 50 | 52 | 1 | 52 |  |
| `C_ClearDispo` | SETUP | 0 | 1 | 0 | 25 | 27 | 1 | 27 |  |

## 10_ATSU.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Cull` | SETUP | 0 | 1 | 0 | 62 | 64 | 1 | 64 |  |
| `C_ColdRecovery` | SETUP | 0 | 1 | 0 | 61 | 63 | 1 | 63 |  |
| `A_RemoveSecondary` | SETUP | 0 | 1 | 0 | 20 | 22 | 1 | 22 |  |
| `C_RemoveSecondary` | SETUP | 0 | 1 | 0 | 20 | 22 | 1 | 22 |  |
| `C_Redeem` | SETUP | 0 | 1 | 0 | 20 | 22 | 1 | 22 |  |
| `C_DirectRecovery` | SETUP | 0 | 1 | 0 | 13 | 15 | 1 | 15 |  |
| `C_Curl` | USAGE | 0 | 1 | 0 | 12 | 14 | 1 | 14 |  |
| `C_HotRecovery` | SETUP | 0 | 1 | 0 | 12 | 14 | 1 | 14 |  |
| `A_KickStart` | SETUP | 0 | 1 | 0 | 11 | 13 | 1 | 13 |  |
| `C_Recover` | SETUP | 0 | 1 | 0 | 9 | 11 | 1 | 11 |  |
| `C_Coil` | USAGE | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |
| `C_Syphon` | USAGE | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_WithdrawRoyalties` | USAGE | 0 | 1 | 0 | 5 | 7 | 1 | 7 |  |
| `C_Fuel` | USAGE | 0 | 1 | 0 | 3 | 5 | 1 | 5 |  |
| `C_KickStart` | SETUP | 0 | 1 | 0 | 1 | 3 | 1 | 3 |  |

## 11_VST.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Merge` | SETUP | 0 | 1 | 0 | 19 | 21 | 1 | 21 |  |
| `C_RepurposeMerge` | SETUP | 0 | 1 | 0 | 19 | 21 | 1 | 21 |  |
| `C_Slumber` | SETUP | 0 | 1 | 0 | 19 | 21 | 1 | 21 |  |
| `C_RepurposeSlumber` | SETUP | 0 | 1 | 0 | 19 | 21 | 1 | 21 |  |
| `C_Unvest` | SETUP | 0 | 1 | 0 | 18 | 20 | 1 | 20 |  |
| `C_Brumate` | USAGE | 0 | 1 | 0 | 18 | 20 | 1 | 20 |  |
| `C_CreateFrozenLink` | ISSUE | 0 | 1 | 0 | 14 | 16 | 1 | 16 |  |
| `C_CreateReservationLink` | ISSUE | 0 | 1 | 0 | 14 | 16 | 1 | 16 |  |
| `C_CreateVestingLink` | ISSUE | 0 | 1 | 0 | 14 | 16 | 1 | 16 |  |
| `C_CreateSleepingLink` | ISSUE | 0 | 1 | 0 | 14 | 16 | 1 | 16 |  |
| `C_CreateHibernatingLink` | ISSUE | 0 | 1 | 0 | 14 | 16 | 1 | 16 |  |
| `C_Constrict` | USAGE | 0 | 1 | 0 | 14 | 16 | 1 | 16 |  |
| `C_Vest` | SETUP | 0 | 1 | 0 | 11 | 13 | 1 | 13 |  |
| `C_Sleep` | SETUP | 0 | 1 | 0 | 11 | 13 | 1 | 13 |  |
| `C_Awake` | SETUP | 0 | 1 | 0 | 11 | 13 | 1 | 13 |  |
| `C_RepurposeVested` | SETUP | 0 | 1 | 0 | 10 | 12 | 1 | 12 |  |
| `C_RepurposeSleeping` | SETUP | 0 | 1 | 0 | 10 | 12 | 1 | 12 |  |
| `C_RepurposeHibernating` | SETUP | 0 | 1 | 0 | 10 | 12 | 1 | 12 |  |
| `C_Unsleep` | SETUP | 0 | 1 | 0 | 9 | 11 | 1 | 11 |  |
| `C_RepurposeFrozen` | SETUP | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |
| `C_RepurposeReserved` | SETUP | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |
| `C_Hibernate` | SETUP | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |
| `C_Freeze` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_Reserve` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_Unreserve` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_ToggleTransferRoleFrozenDPTF` | USAGE | 0 | 1 | 0 | 2 | 4 | 1 | 4 |  |
| `C_ToggleTransferRoleReservedDPTF` | USAGE | 0 | 1 | 0 | 2 | 4 | 1 | 4 |  |
| `C_ToggleTransferRoleSleepingDPOF` | USAGE | 0 | 1 | 0 | 2 | 4 | 1 | 4 |  |
| `C_ToggleTransferRoleHibernatingDPOF` | USAGE | 0 | 1 | 0 | 2 | 4 | 1 | 4 |  |

## 12_LIQUID.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_UnwrapUrStoa` | SETUP | 0 | 2 | 0 | 8 | 11 | 1 | 11 |  |
| `C_UnwrapStoa` | SETUP | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |
| `C_WrapUrStoa` | USAGE | 0 | 2 | 0 | 7 | 10 | 1 | 10 |  |
| `C_WrapStoa` | USAGE | 0 | 1 | 0 | 7 | 9 | 1 | 9 |  |
| `A_MigrateLiquidFunds` | SETUP | 0 | 1 | 0 | 4 | 6 | 1 | 6 |  |

## 13_OUROBOROS.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_SublimateV2` | SETUP | 0 | 1 | 0 | 17 | 19 | 1 | 19 |  |
| `C_Sublimate` | SETUP | 0 | 1 | 0 | 15 | 17 | 1 | 17 |  |
| `C_Compress` | USAGE | 0 | 1 | 0 | 14 | 16 | 1 | 16 |  |
| `C_Fuel` | USAGE | 0 | 1 | 0 | 10 | 12 | 1 | 12 |  |
| `C_WithdrawFees` | USAGE | 0 | 1 | 0 | 7 | 9 | 1 | 9 |  |

## 15_SWP.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_ToggleAddOrSwap` | USAGE | 2 | 5 | 0 | 15 | 25 | 1 | 25 |  |
| `A_ToggleAsymetricLiquidityAddition` | USAGE | 1 | 1 | 0 | 12 | 16 | 25 | 400 | deter frequent small LP churn (your ~1000 target) |
| `C_ToggleFeeLock` | SETUP | 2 | 4 | 0 | 7 | 16 | 1 | 16 |  |
| `A_UpdatePrincipal` | SETUP | 3 | 2 | 0 | 4 | 13 | 1 | 13 |  |
| `C_EnableFrozenLP` | SETUP | 1 | 3 | 0 | 6 | 12 | 1 | 12 |  |
| `C_EnableSleepingLP` | SETUP | 1 | 3 | 0 | 6 | 12 | 1 | 12 |  |
| `C_UpdateFee` | SETUP | 2 | 2 | 0 | 2 | 9 | 1 | 9 |  |
| `A_RotatePrincipal` | SETUP | 1 | 2 | 0 | 3 | 8 | 1 | 8 |  |
| `A_UpdateLimit` | SETUP | 2 | 1 | 0 | 1 | 7 | 1 | 7 |  |
| `C_UpgradeBranding` | SETUP | 0 | 2 | 0 | 4 | 7 | 1 | 7 |  |
| `C_ChangeOwnership` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_ModifyCanChangeOwner` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_ModifyWeights` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_UpdateAmplifier` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_UpdateSpecialFeeTargets` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `C_UpdatePendingBranding` | SETUP | 0 | 2 | 0 | 3 | 6 | 1 | 6 |  |
| `A_UpdateLiquidBoost` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `A_DefinePrimordialPool` | ISSUE | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |

## 16_SWPI.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_RebuildGraph` | SETUP | 1 | 1 | 0 | 20 | 24 | 1 | 24 |  |
| `C_Issue` | ISSUE | 1 | 1 | 0 | 18 | 22 | 1 | 22 |  |

## 18_SWPLC.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_RemoveLiquidity` | USAGE | 0 | 1 | 0 | 13 | 15 | 25 | 375 | deter frequent small LP churn (your ~1000 target) |
| `C_Fuel` | USAGE | 0 | 1 | 0 | 10 | 12 | 1 | 12 |  |
| `C_UpdatePendingBrandingLPs` | SETUP | 0 | 1 | 0 | 9 | 11 | 1 | 11 |  |
| `C_UpgradeBrandingLPs` | SETUP | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |
| `C_ToggleAddLiquidity` | USAGE | 0 | 1 | 0 | 2 | 4 | 25 | 100 | deter frequent small LP churn (your ~1000 target) |

## 19_SWPU.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_SmartSwap` | USAGE | 0 | 1 | 0 | 82 | 84 | 1 | 84 |  |
| `CC_SmartSwap` | USAGE | 0 | 1 | 0 | 58 | 60 | 1 | 60 |  |
| `C_Swap` | USAGE | 0 | 1 | 0 | 52 | 54 | 1 | 54 |  |
| `C_ToggleSwapCapability` | USAGE | 0 | 1 | 0 | 2 | 4 | 1 | 4 |  |

## 20_MTX-SWP.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_AddSleepingLiquidity` | USAGE | 0 | 1 | 0 | 32 | 34 | 25 | 850 | deter frequent small LP churn (your ~1000 target) |
| `C_AddFrozenLiquidity` | USAGE | 0 | 1 | 0 | 28 | 30 | 25 | 750 | deter frequent small LP churn (your ~1000 target) |
| `C_AddStandardLiquidity` | USAGE | 0 | 1 | 0 | 25 | 27 | 25 | 675 | deter frequent small LP churn (your ~1000 target) |
| `C_AddIcedLiquidity` | USAGE | 0 | 1 | 0 | 25 | 27 | 25 | 675 | deter frequent small LP churn (your ~1000 target) |
| `C_AddGlacialLiquidity` | USAGE | 0 | 1 | 0 | 25 | 27 | 25 | 675 | deter frequent small LP churn (your ~1000 target) |
| `C_IssueStablePool` | ISSUE | 1 | 1 | 0 | 21 | 25 | 1 | 25 |  |
| `C_IssueWeightedPool` | ISSUE | 1 | 1 | 0 | 21 | 25 | 1 | 25 |  |
| `C_IssueStandardPool` | ISSUE | 1 | 1 | 0 | 21 | 25 | 1 | 25 |  |

## 21_CODEX.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_RegisterStoicTag` | SETUP | 4 | 3 | 0 | 1 | 13 | 1 | 13 |  |
| `C_ReleaseStoicTag` | SETUP | 2 | 2 | 0 | 1 | 8 | 1 | 8 |  |
| `A_RegisterCodexIdentity` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `C_RotateCodexGuard` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `C_RecordArweaveUpload` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |

## 22_PYTHIA.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Flush` | USAGE | 5 | 4 | 1 | 1 | 17 | 1 | 17 |  |
| `A_LinkDualApiKey` | SETUP | 3 | 2 | 0 | 2 | 11 | 1 | 11 |  |
| `A_RevokeDualLink` | SETUP | 2 | 1 | 0 | 1 | 7 | 1 | 7 |  |
| `C_LinkDualApiKey` | SETUP | 2 | 1 | 0 | 1 | 7 | 1 | 7 |  |
| `C_RevokeDualLink` | SETUP | 2 | 1 | 0 | 1 | 7 | 1 | 7 |  |
| `A_UpdateDeployPrice` | SETUP | 1 | 2 | 0 | 1 | 6 | 1 | 6 |  |
| `A_UpdateRenamePrice` | SETUP | 1 | 2 | 0 | 1 | 6 | 1 | 6 |  |
| `C_DeployApolloPythiaApiKey` | ISSUE | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `C_UpdateDualConsumerLane` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |

## 02_DPDC.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_UpdatePendingBranding` | SETUP | 0 | 2 | 0 | 3 | 6 | 1 | 6 |  |
| `C_UpgradeBranding` | SETUP | 0 | 2 | 0 | 3 | 6 | 1 | 6 |  |

## 03_DPDC-C.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_CreateNewNonce` | ISSUE | 0 | 2 | 0 | 23 | 26 | 1 | 26 |  |
| `C_CreateNewNonces` | ISSUE | 0 | 2 | 0 | 23 | 26 | 1 | 26 |  |

## 04_DPDC-I.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_IssueDigitalCollection` | ISSUE | 0 | 1 | 0 | 23 | 25 | 1 | 25 |  |

## 05_DPDC-R.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_MoveCreateRole` | SETUP | 0 | 1 | 0 | 9 | 11 | 1 | 11 |  |
| `C_MoveRecreateRole` | SETUP | 0 | 1 | 0 | 9 | 11 | 1 | 11 |  |
| `C_MoveSetUriRole` | SETUP | 0 | 1 | 0 | 9 | 11 | 1 | 11 |  |
| `C_ToggleAddQuantityRole` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_ToggleFreezeAccount` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_ToggleExemptionRole` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_ToggleBurnRole` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_ToggleUpdateRole` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_ToggleModifyCreatorRole` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_ToggleModifyRoyaltiesRole` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_ToggleTransferRole` | USAGE | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |

## 06_DPDC-MNG.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_WipeClean` | SETUP | 0 | 1 | 2 | 17 | 21 | 1 | 21 |  |
| `C_WipeHeavy` | SETUP | 0 | 1 | 2 | 16 | 20 | 1 | 20 |  |
| `C_WipePure` | SETUP | 0 | 1 | 2 | 16 | 20 | 1 | 20 |  |
| `C_WipeDirty` | SETUP | 0 | 1 | 2 | 16 | 20 | 1 | 20 |  |
| `C_WipeNonce` | SETUP | 0 | 1 | 0 | 12 | 14 | 1 | 14 |  |
| `C_Control` | SETUP | 0 | 1 | 0 | 7 | 9 | 1 | 9 |  |
| `C_BurnSFT` | SETUP | 0 | 1 | 0 | 7 | 9 | 1 | 9 |  |
| `C_WipeSlim` | SETUP | 0 | 1 | 0 | 7 | 9 | 1 | 9 |  |
| `C_AddQuantity` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_BurnNFT` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_TogglePause` | SETUP | 0 | 1 | 0 | 4 | 6 | 1 | 6 |  |
| `C_RespawnNFT` | SETUP | 0 | 1 | 0 | 4 | 6 | 1 | 6 |  |

## 07_DPDC-T.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Transfer` | USAGE | 0 | 1 | 0 | 27 | 29 | 1 | 29 |  |
| `C_BulkTransfer` | USAGE | 0 | 1 | 0 | 27 | 29 | 1 | 29 |  |
| `C_RepurposeCollectable` | USAGE | 0 | 1 | 0 | 18 | 20 | 1 | 20 |  |
| `C_IgnisRoyaltyCollector` | USAGE | 0 | 1 | 0 | 12 | 14 | 1 | 14 |  |

## 08_DPDC-S.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_DefineHybridSet` | ISSUE | 2 | 1 | 0 | 13 | 19 | 1 | 19 |  |
| `C_DefinePrimordialSet` | ISSUE | 2 | 1 | 0 | 12 | 18 | 1 | 18 |  |
| `C_DefineCompositeSet` | ISSUE | 2 | 1 | 0 | 12 | 18 | 1 | 18 |  |
| `C_BreakSemiFungibleSet` | SETUP | 0 | 3 | 0 | 11 | 15 | 1 | 15 |  |
| `C_MakeNonFungibleSet` | ISSUE | 0 | 3 | 0 | 10 | 14 | 1 | 14 |  |
| `C_EnableSetClassFragmentation` | SETUP | 4 | 1 | 0 | 3 | 13 | 1 | 13 |  |
| `C_BreakNonFungibleSet` | SETUP | 0 | 1 | 0 | 9 | 11 | 1 | 11 |  |
| `C_ToggleSet` | SETUP | 2 | 1 | 0 | 3 | 9 | 1 | 9 |  |
| `C_RenameSet` | SETUP | 2 | 1 | 0 | 3 | 9 | 1 | 9 |  |
| `C_MakeSemiFungibleSet` | ISSUE | 0 | 3 | 0 | 4 | 8 | 1 | 8 |  |

## 09_DPDC-F.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_RepurposeCollectableFragments` | USAGE | 0 | 1 | 0 | 18 | 20 | 1 | 20 |  |
| `C_MakeFragments` | ISSUE | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |
| `C_MergeFragments` | SETUP | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |
| `C_EnableNonceFragmentation` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |

## 10_DPDC-N.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_UpdateNonceScore` | SETUP | 0 | 3 | 0 | 8 | 12 | 1 | 12 |  |
| `C_UpdateNonceMetaData` | SETUP | 0 | 3 | 0 | 8 | 12 | 1 | 12 |  |
| `C_UpdateNonceRoyalty` | SETUP | 0 | 2 | 0 | 8 | 11 | 1 | 11 |  |
| `C_UpdateNonceIgnisRoyalty` | SETUP | 0 | 2 | 0 | 8 | 11 | 1 | 11 |  |
| `C_UpdateNonceName` | SETUP | 0 | 2 | 0 | 8 | 11 | 1 | 11 |  |
| `C_UpdateNonceDescription` | SETUP | 0 | 2 | 0 | 8 | 11 | 1 | 11 |  |
| `C_UpdateNonceURI` | SETUP | 0 | 2 | 0 | 8 | 11 | 1 | 11 |  |
| `C_UpdateNonces` | SETUP | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |

## 11_EQUITY+.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_IssueShareholderCollection` | ISSUE | 0 | 1 | 0 | 43 | 45 | 1 | 45 |  |
| `C_MorphPackageShares` | SETUP | 0 | 1 | 0 | 18 | 20 | 1 | 20 |  |

## 00_Demipad.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Deposit` | USAGE | 10 | 9 | 0 | 35 | 65 | 1 | 65 |  |
| `C_Withdraw` | USAGE | 3 | 4 | 0 | 5 | 16 | 1 | 16 |  |
| `C_TransmitSemiFungibles` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_TransmitNonFungibles` | SETUP | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_TransmitTrueFungible` | SETUP | 0 | 1 | 0 | 4 | 6 | 1 | 6 |  |
| `C_TransmitOrtoFungible` | SETUP | 0 | 1 | 0 | 4 | 6 | 1 | 6 |  |
| `A_RegisterAssetToLaunchpad` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `A_ToggleOpenForBusiness` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `A_DefinePrice` | ISSUE | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |
| `A_ToggleRetrieval` | SETUP | 1 | 1 | 0 | 1 | 5 | 1 | 5 |  |

## 01_ANK.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_IssueTrueFungibleAnchor` | ISSUE | 4 | 4 | 0 | 7 | 20 | 1 | 20 |  |
| `C_IssueSemiFungibleAnchor` | ISSUE | 4 | 4 | 0 | 7 | 20 | 1 | 20 |  |
| `C_IssueNonFungibleAnchor` | ISSUE | 4 | 4 | 0 | 7 | 20 | 1 | 20 |  |
| `C_IssueNonFungibleSetAnchor` | ISSUE | 4 | 4 | 0 | 7 | 20 | 1 | 20 |  |
| `C_RevokeAnchor` | SETUP | 3 | 6 | 0 | 6 | 19 | 1 | 19 |  |
| `C_RevokeBoostClass` | SETUP | 1 | 1 | 0 | 2 | 6 | 1 | 6 |  |

## 02_SCORE.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_IssueScoreFromModel` | ISSUE | 5 | 6 | 0 | 4 | 21 | 1 | 21 |  |
| `C_IssueNonFungibleScoreDefinition` | ISSUE | 4 | 7 | 0 | 3 | 19 | 1 | 19 |  |
| `C_IssueNonFungibleSetScoreDefinition` | ISSUE | 4 | 7 | 0 | 3 | 19 | 1 | 19 |  |
| `C_IssueTriplet` | ISSUE | 2 | 4 | 0 | 2 | 11 | 1 | 11 |  |
| `C_IssueSemiFungibleScoreDefinition` | ISSUE | 2 | 3 | 0 | 3 | 11 | 1 | 11 |  |
| `C_IssueLiquidityScore` | ISSUE | 1 | 1 | 0 | 6 | 10 | 25 | 250 | deter frequent small LP churn (your ~1000 target) |
| `C_IssueTrueFungibleScore` | ISSUE | 1 | 1 | 0 | 6 | 10 | 1 | 10 |  |
| `C_IssueOrtoFungibleScore` | ISSUE | 1 | 1 | 0 | 6 | 10 | 1 | 10 |  |
| `C_IssueSemiFungibleScore` | ISSUE | 1 | 1 | 0 | 6 | 10 | 1 | 10 |  |
| `C_IssueNonFungibleScore` | ISSUE | 1 | 1 | 0 | 6 | 10 | 1 | 10 |  |
| `C_CreateBoostClassLink` | ISSUE | 1 | 3 | 0 | 3 | 9 | 1 | 9 |  |
| `C_IssueSingleScoreModel` | ISSUE | 1 | 1 | 0 | 3 | 7 | 1 | 7 |  |
| `C_CombineTripletScoreModel` | SETUP | 1 | 1 | 0 | 3 | 7 | 1 | 7 |  |
| `C_RotateOwnership` | SETUP | 1 | 2 | 0 | 1 | 6 | 1 | 6 |  |
| `C_Control` | SETUP | 1 | 2 | 0 | 1 | 6 | 1 | 6 |  |
| `C_CreateBoostLink` | ISSUE | 1 | 2 | 0 | 1 | 6 | 1 | 6 |  |
| `C_EnableDebBoost` | SETUP | 1 | 2 | 0 | 1 | 6 | 1 | 6 |  |

## 03_AQP.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_SyncCollectableAnchors` | USAGE | 2 | 3 | 3 | 7 | 18 | 1 | 18 |  |
| `C_RevokeScore` | SETUP | 1 | 8 | 0 | 5 | 16 | 1 | 16 |  |
| `C_AddScore` | SETUP | 1 | 8 | 0 | 3 | 14 | 1 | 14 |  |
| `C_SyncTrueFungibleAnchors` | SETUP | 1 | 2 | 0 | 6 | 11 | 1 | 11 |  |
| `C_Issue` | ISSUE | 1 | 1 | 0 | 5 | 9 | 1 | 9 |  |
| `C_DisablePoolStake` | USAGE | 1 | 1 | 0 | 2 | 6 | 1 | 6 |  |
| `C_EnablePoolStake` | USAGE | 1 | 1 | 0 | 2 | 6 | 1 | 6 |  |

## 05_FVT.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `CC_Collect` | USAGE | 0 | 1 | 0 | 28 | 30 | 1 | 30 |  |
| `C_AddScoreEntity` | SETUP | 0 | 1 | 0 | 19 | 21 | 1 | 21 |  |
| `CC_TrueFungibleStakeFlow` | USAGE | 0 | 1 | 0 | 19 | 21 | 1 | 21 |  |
| `CC_CollectableStakeFlow` | USAGE | 0 | 1 | 0 | 19 | 21 | 1 | 21 |  |
| `CC_SweepRevokeAnchor` | USAGE | 0 | 1 | 0 | 14 | 16 | 1 | 16 |  |
| `CC_OrtoFungibleStakeFlow` | USAGE | 0 | 1 | 0 | 13 | 15 | 1 | 15 |  |
| `CC_SweepBegin` | USAGE | 2 | 2 | 0 | 7 | 14 | 1 | 14 |  |
| `CCp_UnstaleAll` | USAGE | 0 | 1 | 0 | 11 | 13 | 1 | 13 |  |
| `CCp_SweepRecomputeChunk` | USAGE | 2 | 2 | 0 | 6 | 13 | 1 | 13 |  |
| `CC_Inject` | USAGE | 0 | 1 | 0 | 10 | 12 | 1 | 12 |  |
| `C_Issue` | ISSUE | 1 | 1 | 0 | 6 | 10 | 1 | 10 |  |
| `C_SetCommonDenominator` | SETUP | 1 | 1 | 0 | 4 | 8 | 1 | 8 |  |
| `CCp_InjectFixChunk` | USAGE | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |
| `C_Control` | SETUP | 1 | 1 | 0 | 3 | 7 | 1 | 7 |  |
| `C_SetMosaic` | SETUP | 0 | 1 | 0 | 5 | 7 | 1 | 7 |  |
| `C_SetSplitMode` | SETUP | 0 | 1 | 0 | 5 | 7 | 1 | 7 |  |
| `C_ToggleScoreEntityLink` | SETUP | 0 | 1 | 0 | 5 | 7 | 1 | 7 |  |
| `C_AddRewardLink` | SETUP | 0 | 1 | 0 | 5 | 7 | 1 | 7 |  |
| `C_ToggleRewardLink` | SETUP | 0 | 1 | 0 | 5 | 7 | 1 | 7 |  |
| `C_SetQualitySplit` | SETUP | 0 | 1 | 0 | 5 | 7 | 1 | 7 |  |
| `CC_UnstaleMyScores` | USAGE | 0 | 1 | 0 | 5 | 7 | 1 | 7 |  |
| `C_IssueMultipletFamily` | ISSUE | 0 | 1 | 0 | 4 | 6 | 1 | 6 |  |
| `CC_InjectFinalize` | USAGE | 0 | 1 | 1 | 3 | 6 | 1 | 6 |  |
| `C_RotateOwnership` | SETUP | 0 | 1 | 0 | 3 | 5 | 1 | 5 |  |
| `CC_InjectStream` | USAGE | 0 | 1 | 0 | 2 | 4 | 1 | 4 |  |

## 06_VCT.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `CC_FullVacate` | USAGE | 0 | 1 | 0 | 48 | 50 | 1 | 50 |  |
| `CCp_BatchVacateTrueFungible` | USAGE | 0 | 1 | 0 | 32 | 34 | 1 | 34 |  |
| `CCp_BatchVacateCollectables` | USAGE | 0 | 1 | 0 | 31 | 33 | 1 | 33 |  |
| `CCp_BatchVacateOrtoFungible` | USAGE | 0 | 1 | 0 | 29 | 31 | 1 | 31 |  |
| `CCp_BatchDrainTrueFungible` | USAGE | 0 | 1 | 0 | 21 | 23 | 1 | 23 |  |
| `CCp_BatchDrainCollectable` | USAGE | 0 | 1 | 0 | 20 | 22 | 1 | 22 |  |
| `CCp_BatchDrainOrtoFungible` | USAGE | 0 | 1 | 0 | 18 | 20 | 1 | 20 |  |
| `C_FinalizeVacate` | USAGE | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |
| `C_AbortVacate` | USAGE | 0 | 1 | 0 | 6 | 8 | 1 | 8 |  |

## 07_MTX-AQP.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_2|SweepRevokeAnchor` | USAGE | 0 | 1 | 0 | 10 | 12 | 1 | 12 |  |
| `C_2|Inject` | USAGE | 0 | 1 | 0 | 5 | 7 | 1 | 7 |  |

## 08_DSA.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_OracleWrite` | SETUP | 1 | 3 | 0 | 8 | 14 | 1 | 14 |  |
| `C_RecomputeCapture` | SETUP | 0 | 3 | 0 | 8 | 12 | 1 | 12 |  |
| `A_SetOracleAuth` | SETUP | 1 | 1 | 0 | 3 | 7 | 1 | 7 |  |
| `A_SetAgencyFee` | SETUP | 1 | 2 | 0 | 2 | 7 | 1 | 7 |  |
| `A_DefineDelegationVault` | ISSUE | 1 | 1 | 0 | 2 | 6 | 1 | 6 |  |
| `C_AdmitAgency` | SETUP | 1 | 1 | 0 | 2 | 6 | 1 | 6 |  |
| `A_WithdrawRoyalty` | USAGE | 0 | 1 | 0 | 2 | 4 | 1 | 4 |  |
| `A_BurnRoyalty` | SETUP | 0 | 1 | 0 | 2 | 4 | 1 | 4 |  |
| `A_FuelRoyalty` | USAGE | 0 | 1 | 0 | 2 | 4 | 1 | 4 |  |
| `A_ToggleExternalOracle` | SETUP | 0 | 0 | 0 | 0 | 1 | 1 | 1 |  |
| `A_SetOracleValidity` | SETUP | 0 | 0 | 0 | 0 | 1 | 1 | 1 |  |

## 05_TS02-DPAD.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_RegisterAssetToLaunchpad` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_ToggleOpenForBusiness` | SETUP | 0 | 0 | 0 | 1 | 2 | 1 | 2 |  |
| `A_DefinePrice` | ISSUE | 0 | 0 | 0 | 1 | 2 | 1 | 2 |  |
| `A_ToggleRetrieval` | SETUP | 0 | 0 | 0 | 1 | 2 | 1 | 2 |  |

## 01_AOZ+.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_RegisterPrimalTrueFungible` | SETUP | 2 | 2 | 0 | 0 | 7 | 1 | 7 |  |
| `A_RegisterPrimalOrtoFungible` | SETUP | 2 | 2 | 0 | 0 | 7 | 1 | 7 |  |
| `A_RegisterAutostakePair` | SETUP | 2 | 2 | 0 | 0 | 7 | 1 | 7 |  |
| `A_RegisterTrueFungible` | SETUP | 2 | 2 | 0 | 0 | 7 | 1 | 7 |  |
| `A_RegisterOrtoFungible` | SETUP | 2 | 2 | 0 | 0 | 7 | 1 | 7 |  |
| `A_RegisterSemiFungible` | SETUP | 2 | 2 | 0 | 0 | 7 | 1 | 7 |  |
| `A_RegisterNonFungible` | SETUP | 2 | 2 | 0 | 0 | 7 | 1 | 7 |  |
| `C_SetupKosonicATS` | SETUP | 0 | 1 | 0 | 5 | 7 | 1 | 7 |  |
| `A_InitialiseCounters` | SETUP | 1 | 0 | 0 | 0 | 3 | 1 | 3 |  |

## 01_BSD-L.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Legendary` | SETUP | 0 | 0 | 0 | 8 | 9 | 1 | 9 |  |
| `A_Issue` | ISSUE | 0 | 0 | 0 | 1 | 2 | 1 | 2 |  |

## 02_BSD-E.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Epic` | SETUP | 0 | 0 | 0 | 8 | 9 | 1 | 9 |  |

## 03_BSD-R.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Rare` | SETUP | 0 | 0 | 0 | 8 | 9 | 1 | 9 |  |

## 04_BSD-C.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Common` | SETUP | 0 | 0 | 0 | 8 | 9 | 1 | 9 |  |

## 01_NOSFERATU.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Fix01` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix02a` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix02b` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix03` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix04` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix05a` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix05b` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix06` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix07` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix08` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix09` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix10` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix11` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix12` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix13` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix14` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix15` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix16` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix17` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix18` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix19` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix20` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix21` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Fix22` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step01` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step02` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step03` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step04` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step05` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step06` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step07` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step08` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step09` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step10` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step11` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step12` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step13` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step14` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step15` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step16` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step17` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step18` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step19` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step20` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step21` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step22` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `C_Spawn` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `C_Fix` | USAGE | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |

## 02_KBunnies.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_BunnyRGBSet` | SETUP | 0 | 0 | 0 | 10 | 11 | 1 | 11 |  |
| `A_Step01` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step02` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step03` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step04` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step05` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step06` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step07` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step08` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step09` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step10` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step11` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step12` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step13` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step14` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step15` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `A_Step16` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |
| `C_Spawn` | SETUP | 0 | 0 | 0 | 6 | 7 | 1 | 7 |  |

## 04_AQP-BOOT.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Step3_CreateBoosterAnchorClasses` | SETUP | 0 | 0 | 0 | 25 | 26 | 1 | 26 |  |
| `C_Step7_CreatePoolsAndScores` | SETUP | 0 | 0 | 0 | 19 | 20 | 1 | 20 |  |
| `C_Step5_CreateSubsidiaryScores` | SETUP | 0 | 0 | 0 | 15 | 16 | 1 | 16 |  |
| `C_Step2_CreateSnakePowerAnchorClasses` | SETUP | 0 | 0 | 0 | 11 | 12 | 1 | 12 |  |
| `C_Step6_CreateOuroLpTriplet` | SETUP | 0 | 0 | 0 | 11 | 12 | 1 | 12 |  |
| `C_Step8_IssueFvtEntities` | SETUP | 0 | 0 | 0 | 10 | 11 | 1 | 11 |  |
| `C_Step0_WireImcAndGovernor` | SETUP | 0 | 0 | 0 | 9 | 10 | 1 | 10 |  |
| `C_Step4_CreateCoreScores` | SETUP | 0 | 0 | 0 | 8 | 9 | 1 | 9 |  |
| `C_Step12_AddFvtRewardLinks` | SETUP | 0 | 0 | 0 | 5 | 6 | 1 | 6 |  |
| `C_Step9_AddFvtScoreEntities` | SETUP | 0 | 0 | 0 | 4 | 5 | 1 | 5 |  |
| `C_Step11_WireFarmTriplet` | SETUP | 0 | 0 | 0 | 3 | 4 | 1 | 4 |  |
| `C_Step10_IssueMultipletFamily` | SETUP | 0 | 0 | 0 | 1 | 2 | 1 | 2 |  |
| `C_Step1_CreateBunnySet` | SETUP | 0 | 0 | 0 | 0 | 1 | 1 | 1 |  |

## 03_CADUCEUS.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_MintToUserFromBridgeSignal` | ISSUE | 1 | 4 | 2 | 2 | 11 | 1 | 11 |  |
| `C_BurnFromBridgeSignal` | SETUP | 1 | 4 | 2 | 1 | 10 | 1 | 10 |  |
| `A_ProvisionBridgeDptfRoles` | SETUP | 0 | 3 | 1 | 4 | 9 | 1 | 9 |  |
| `A_DeployBridgeSmartAccount` | ISSUE | 0 | 4 | 1 | 1 | 7 | 1 | 7 |  |
| `A_SetBridgeConfig` | SETUP | 1 | 0 | 0 | 0 | 3 | 1 | 3 |  |
| `A_SetBridgeActive` | SETUP | 1 | 0 | 0 | 0 | 3 | 1 | 3 |  |

## 01_Spark.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_RedemAllSparks` | SETUP | 0 | 1 | 0 | 13 | 15 | 1 | 15 |  |
| `C_CustomRedemAllSparks` | SETUP | 0 | 1 | 0 | 12 | 14 | 1 | 14 |  |
| `C_RedemFewSparks` | SETUP | 0 | 1 | 0 | 12 | 14 | 1 | 14 |  |
| `C_CustomRedemFewSparks` | SETUP | 0 | 1 | 0 | 11 | 13 | 1 | 13 |  |
| `C_BuySparks` | SETUP | 0 | 1 | 0 | 7 | 9 | 1 | 9 |  |

## 02_Snakes.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Acquire` | SETUP | 0 | 1 | 0 | 15 | 17 | 1 | 17 |  |
| `A_UpdateSharePrice` | SETUP | 0 | 1 | 0 | 1 | 3 | 1 | 3 |  |

## 03_Custodians.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Acquire` | SETUP | 0 | 1 | 0 | 14 | 16 | 1 | 16 |  |
| `A_UpdateQuintessencePrice` | SETUP | 0 | 1 | 0 | 1 | 3 | 1 | 3 |  |

## 04_STOICPAY.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_BuyStoicPay` | SETUP | 0 | 1 | 0 | 8 | 10 | 1 | 10 |  |

## 05_STOAICO.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Stake` | USAGE | 9 | 12 | 0 | 2 | 33 | 1 | 33 |  |
| `Ap_FlushUncollectedSlice` | USAGE | 6 | 11 | 0 | 4 | 28 | 1 | 28 |  |
| `AA_FlushUncollected` | USAGE | 6 | 10 | 1 | 4 | 28 | 1 | 28 |  |
| `A_Unstake` | USAGE | 7 | 10 | 0 | 2 | 27 | 1 | 27 |  |
| `C_Collect` | USAGE | 6 | 10 | 0 | 4 | 27 | 1 | 27 |  |
| `A_Inject` | USAGE | 5 | 8 | 0 | 2 | 21 | 1 | 21 |  |
| `A_InitialiseDistributionVault` | SETUP | 1 | 0 | 0 | 7 | 10 | 1 | 10 |  |

## 03_DSP+.pact

| op | role | W | R | S | X | compute | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_KosonMinterStageOne` | SETUP | 0 | 0 | 0 | 37 | 38 | 1 | 38 |  |
| `A_KosonMinterStageOne_1of3` | SETUP | 0 | 0 | 0 | 18 | 19 | 1 | 19 |  |
| `A_OuroMinterStageOne` | SETUP | 0 | 0 | 0 | 17 | 18 | 1 | 18 |  |
| `A_KosonMinterStageOne_2of3` | SETUP | 0 | 0 | 0 | 15 | 16 | 1 | 16 |  |
| `A_KosonMinterStageOne_3of3` | SETUP | 0 | 0 | 0 | 15 | 16 | 1 | 16 |  |
| `A_StoicismMinter` | SETUP | 0 | 0 | 0 | 2 | 3 | 1 | 3 |  |

---
469 ops · 9 pre-suggested deter>1 (rest default 1). Revise & green-light.

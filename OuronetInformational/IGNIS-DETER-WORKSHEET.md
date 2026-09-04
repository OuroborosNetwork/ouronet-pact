# IGNIS deterrence worksheet (#76) — SUGGESTED, for owner revision

FINAL = deter·IG|TX(1) + [ 3·(insert/write) + 1·update + 1·read + 1·scan + 1·xcall ] (module-internal transitive; approx —
cross-module callee internals not summed, so delegating ops read low).
deter default 1 (no extra). Revise the `deter` column; I green-light nothing myself.


## 01_DALOS.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_DeploySmartAccount` | ISSUE | 3 | 0 | 2 | 0 | 3 | 14 | 1 | 15 |  |
| `C_DeployStandardAccount` | ISSUE | 3 | 0 | 2 | 0 | 3 | 14 | 1 | 15 |  |
| `C_RotateStoa` | SETUP | 2 | 1 | 3 | 0 | 3 | 13 | 1 | 14 |  |
| `A_DeploySmartAccount` | ISSUE | 3 | 0 | 1 | 0 | 2 | 12 | 1 | 13 |  |
| `A_DeployStandardAccount` | ISSUE | 3 | 0 | 1 | 0 | 2 | 12 | 1 | 13 |  |
| `A_UpdateUsagePrice` | SETUP | 1 | 0 | 1 | 0 | 2 | 6 | 1 | 7 |  |
| `A_MigrateLiquidFunds` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | 1 | 6 |  |
| `C_RotateGuard` | SETUP | 0 | 2 | 2 | 0 | 1 | 5 | 1 | 6 |  |
| `A_ToggleGasCollection` | USAGE | 0 | 2 | 1 | 0 | 1 | 4 | 1 | 5 |  |
| `A_ToggleOAPU` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |
| `A_ToggleGAP` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |
| `A_SetIgnisSourcePrice` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |
| `A_SetAutoFueling` | USAGE | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |
| `A_UpdatePublicKey` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |
| `C_ControlSmartAccount` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |
| `C_RotateGovernor` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |
| `C_RotateSovereign` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |

## 02_IGNIS.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Collect` | USAGE | 0 | 0 | 2 | 0 | 24 | 26 | 1 | 27 |  |
| `C_TransferDalosFuel` | USAGE | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 2 |  |

## 04_BRD.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Live` | SETUP | 0 | 2 | 3 | 0 | 1 | 6 | 1 | 7 |  |
| `A_SetFlag` | SETUP | 0 | 2 | 3 | 0 | 1 | 6 | 1 | 7 |  |

## 05_DPTF.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_WipeTreasuryDebt` | SETUP | 2 | 3 | 9 | 0 | 16 | 34 | 1 | 35 |  |
| `A_WipeTreasuryDebtPartial` | SETUP | 2 | 3 | 9 | 0 | 15 | 33 | 1 | 34 |  |
| `C_Mint` | ISSUE | 2 | 3 | 9 | 0 | 13 | 31 | 1 | 32 |  |
| `C_Issue` | ISSUE | 3 | 0 | 3 | 0 | 14 | 26 | 1 | 27 |  |
| `C_Burn` | SETUP | 1 | 2 | 7 | 0 | 11 | 23 | 1 | 24 |  |
| `C_WipeSlim` | SETUP | 1 | 2 | 8 | 0 | 9 | 22 | 1 | 23 |  |
| `C_Wipe` | SETUP | 1 | 2 | 8 | 0 | 9 | 22 | 1 | 23 |  |
| `C_ToggleFreezeAccount` | SETUP | 1 | 2 | 6 | 0 | 9 | 20 | 1 | 21 |  |
| `C_ToggleBurnRole` | SETUP | 1 | 2 | 6 | 0 | 9 | 20 | 1 | 21 |  |
| `C_ToggleMintRole` | SETUP | 1 | 2 | 6 | 0 | 9 | 20 | 1 | 21 |  |
| `C_ToggleFeeExemptionRole` | SETUP | 1 | 2 | 6 | 0 | 9 | 20 | 1 | 21 |  |
| `C_ToggleTransferRole` | USAGE | 1 | 2 | 6 | 0 | 9 | 20 | 1 | 21 |  |
| `C_ToggleFeeLock` | SETUP | 0 | 2 | 4 | 0 | 7 | 13 | 1 | 14 |  |
| `C_DeployAccount` | ISSUE | 1 | 0 | 3 | 0 | 3 | 9 | 1 | 10 |  |
| `C_UpgradeBranding` | SETUP | 0 | 0 | 4 | 0 | 4 | 8 | 1 | 9 |  |
| `C_UpdatePendingBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | 1 | 6 |  |
| `C_RotateOwnership` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_Control` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_TogglePause` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_ToggleReservation` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_ToggleFee` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_SetMinMove` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_SetFee` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_SetFeeTarget` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `A_UpdateTreasury` | SETUP | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |

## 06_DPOF.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Transmit` | SETUP | 2 | 5 | 13 | 0 | 7 | 31 | 1 | 32 |  |
| `C_Issue` | ISSUE | 3 | 0 | 4 | 0 | 13 | 26 | 1 | 27 |  |
| `C_Mint` | ISSUE | 2 | 4 | 11 | 0 | 4 | 25 | 1 | 26 |  |
| `C_AddQuantity` | SETUP | 2 | 4 | 11 | 0 | 3 | 24 | 1 | 25 |  |
| `C_WipeHeavy` | SETUP | 0 | 5 | 7 | 3 | 5 | 20 | 1 | 21 |  |
| `C_WipePure` | SETUP | 0 | 5 | 7 | 3 | 5 | 20 | 1 | 21 |  |
| `C_WipeClean` | SETUP | 0 | 5 | 7 | 3 | 5 | 20 | 1 | 21 |  |
| `C_Transfer` | USAGE | 1 | 2 | 8 | 0 | 7 | 20 | 1 | 21 |  |
| `C_BulkTransfer` | USAGE | 1 | 2 | 8 | 0 | 7 | 20 | 1 | 21 |  |
| `C_ToggleFreezeAccount` | SETUP | 1 | 2 | 7 | 0 | 4 | 16 | 1 | 17 |  |
| `C_ToggleAddQuantityRole` | SETUP | 1 | 2 | 7 | 0 | 4 | 16 | 1 | 17 |  |
| `C_ToggleBurnRole` | SETUP | 1 | 2 | 7 | 0 | 4 | 16 | 1 | 17 |  |
| `C_ToggleTransferRole` | USAGE | 1 | 2 | 7 | 0 | 4 | 16 | 1 | 17 |  |
| `C_MoveCreateRole` | SETUP | 1 | 3 | 6 | 0 | 3 | 15 | 1 | 16 |  |
| `C_Burn` | SETUP | 0 | 5 | 7 | 0 | 2 | 14 | 1 | 15 |  |
| `C_WipeSlim` | SETUP | 0 | 5 | 7 | 0 | 2 | 14 | 1 | 15 |  |
| `C_UpgradeBranding` | SETUP | 0 | 0 | 5 | 0 | 5 | 10 | 1 | 11 |  |
| `C_DeployAccount` | ISSUE | 1 | 0 | 4 | 0 | 2 | 9 | 1 | 10 |  |
| `C_UpdatePendingBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | 1 | 6 |  |
| `C_RotateOwnership` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_Control` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_TogglePause` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |

## 08_ATS.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 1 | 0 | 1 | 0 | 18 | 22 | 1 | 23 |  |
| `C_AddHotRBT` | SETUP | 0 | 1 | 1 | 0 | 12 | 14 | 1 | 15 |  |
| `C_ToggleParameterLock` | SETUP | 0 | 2 | 3 | 0 | 7 | 12 | 1 | 13 |  |
| `C_AddSecondary` | SETUP | 0 | 1 | 2 | 0 | 9 | 12 | 1 | 13 |  |
| `C_SetColdRecoveryFees` | SETUP | 0 | 1 | 1 | 0 | 6 | 8 | 1 | 9 |  |
| `C_SetColdRecoveryDuration` | SETUP | 0 | 2 | 2 | 0 | 4 | 8 | 1 | 9 |  |
| `C_UpgradeBranding` | SETUP | 0 | 0 | 2 | 0 | 4 | 6 | 1 | 7 |  |
| `C_UpdatePendingBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | 1 | 6 |  |
| `C_RotateOwnership` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_Control` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_UpdateRoyalty` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_UpdateSyphon` | USAGE | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_SetHibernationFees` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_ControlColdRecoveryFees` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_ToggleElite` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_ToggleUpgrade` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_SwitchColdRecovery` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_ControlHotRecoveryFee` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_SetHotRecoveryFees` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_SwitchHotRecovery` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_SetDirectRecoveryFee` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_SwitchDirectRecovery` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |

## 09_TFT.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_MultiBulkTransfer` | USAGE | 0 | 0 | 1 | 0 | 71 | 72 | 1 | 73 |  |
| `C_MultiTransfer` | USAGE | 0 | 0 | 1 | 0 | 69 | 70 | 1 | 71 |  |
| `C_Transfer` | USAGE | 0 | 0 | 1 | 0 | 68 | 69 | 1 | 70 |  |
| `C_Transmute` | SETUP | 0 | 0 | 1 | 0 | 50 | 51 | 1 | 52 |  |
| `C_ClearDispo` | SETUP | 0 | 0 | 1 | 0 | 25 | 26 | 1 | 27 |  |

## 10_ATSU.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Cull` | SETUP | 0 | 0 | 1 | 0 | 62 | 63 | 1 | 64 |  |
| `C_ColdRecovery` | SETUP | 0 | 0 | 1 | 0 | 61 | 62 | 1 | 63 |  |
| `A_RemoveSecondary` | SETUP | 0 | 0 | 1 | 0 | 20 | 21 | 1 | 22 |  |
| `C_RemoveSecondary` | SETUP | 0 | 0 | 1 | 0 | 20 | 21 | 1 | 22 |  |
| `C_Redeem` | SETUP | 0 | 0 | 1 | 0 | 20 | 21 | 1 | 22 |  |
| `C_DirectRecovery` | SETUP | 0 | 0 | 1 | 0 | 13 | 14 | 1 | 15 |  |
| `C_Curl` | USAGE | 0 | 0 | 1 | 0 | 12 | 13 | 1 | 14 |  |
| `C_HotRecovery` | SETUP | 0 | 0 | 1 | 0 | 12 | 13 | 1 | 14 |  |
| `A_KickStart` | SETUP | 0 | 0 | 1 | 0 | 11 | 12 | 1 | 13 |  |
| `C_Recover` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | 1 | 11 |  |
| `C_Coil` | USAGE | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |
| `C_Syphon` | USAGE | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_WithdrawRoyalties` | USAGE | 0 | 0 | 1 | 0 | 5 | 6 | 1 | 7 |  |
| `C_Fuel` | USAGE | 0 | 0 | 1 | 0 | 3 | 4 | 1 | 5 |  |
| `C_KickStart` | SETUP | 0 | 0 | 1 | 0 | 1 | 2 | 1 | 3 |  |

## 11_VST.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Merge` | SETUP | 0 | 0 | 1 | 0 | 19 | 20 | 1 | 21 |  |
| `C_RepurposeMerge` | SETUP | 0 | 0 | 1 | 0 | 19 | 20 | 1 | 21 |  |
| `C_Slumber` | SETUP | 0 | 0 | 1 | 0 | 19 | 20 | 1 | 21 |  |
| `C_RepurposeSlumber` | SETUP | 0 | 0 | 1 | 0 | 19 | 20 | 1 | 21 |  |
| `C_Unvest` | SETUP | 0 | 0 | 1 | 0 | 18 | 19 | 1 | 20 |  |
| `C_Brumate` | USAGE | 0 | 0 | 1 | 0 | 18 | 19 | 1 | 20 |  |
| `C_CreateFrozenLink` | ISSUE | 0 | 0 | 1 | 0 | 14 | 15 | 1 | 16 |  |
| `C_CreateReservationLink` | ISSUE | 0 | 0 | 1 | 0 | 14 | 15 | 1 | 16 |  |
| `C_CreateVestingLink` | ISSUE | 0 | 0 | 1 | 0 | 14 | 15 | 1 | 16 |  |
| `C_CreateSleepingLink` | ISSUE | 0 | 0 | 1 | 0 | 14 | 15 | 1 | 16 |  |
| `C_CreateHibernatingLink` | ISSUE | 0 | 0 | 1 | 0 | 14 | 15 | 1 | 16 |  |
| `C_Constrict` | USAGE | 0 | 0 | 1 | 0 | 14 | 15 | 1 | 16 |  |
| `C_Vest` | SETUP | 0 | 0 | 1 | 0 | 11 | 12 | 1 | 13 |  |
| `C_Sleep` | SETUP | 0 | 0 | 1 | 0 | 11 | 12 | 1 | 13 |  |
| `C_Awake` | SETUP | 0 | 0 | 1 | 0 | 11 | 12 | 1 | 13 |  |
| `C_RepurposeVested` | SETUP | 0 | 0 | 1 | 0 | 10 | 11 | 1 | 12 |  |
| `C_RepurposeSleeping` | SETUP | 0 | 0 | 1 | 0 | 10 | 11 | 1 | 12 |  |
| `C_RepurposeHibernating` | SETUP | 0 | 0 | 1 | 0 | 10 | 11 | 1 | 12 |  |
| `C_Unsleep` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | 1 | 11 |  |
| `C_RepurposeFrozen` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |
| `C_RepurposeReserved` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |
| `C_Hibernate` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |
| `C_Freeze` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_Reserve` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_Unreserve` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_ToggleTransferRoleFrozenDPTF` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |
| `C_ToggleTransferRoleReservedDPTF` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |
| `C_ToggleTransferRoleSleepingDPOF` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |
| `C_ToggleTransferRoleHibernatingDPOF` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |

## 12_LIQUID.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_UnwrapUrStoa` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | 1 | 11 |  |
| `C_UnwrapStoa` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |
| `C_WrapUrStoa` | USAGE | 0 | 0 | 2 | 0 | 7 | 9 | 1 | 10 |  |
| `C_WrapStoa` | USAGE | 0 | 0 | 1 | 0 | 7 | 8 | 1 | 9 |  |
| `A_MigrateLiquidFunds` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | 1 | 6 |  |

## 13_OUROBOROS.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_SublimateV2` | SETUP | 0 | 0 | 1 | 0 | 17 | 18 | 1 | 19 |  |
| `C_Sublimate` | SETUP | 0 | 0 | 1 | 0 | 15 | 16 | 1 | 17 |  |
| `C_Compress` | USAGE | 0 | 0 | 1 | 0 | 14 | 15 | 1 | 16 |  |
| `C_Fuel` | USAGE | 0 | 0 | 1 | 0 | 10 | 11 | 1 | 12 |  |
| `C_WithdrawFees` | USAGE | 0 | 0 | 1 | 0 | 7 | 8 | 1 | 9 |  |

## 15_SWP.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_ToggleAddOrSwap` | USAGE | 0 | 2 | 5 | 0 | 15 | 22 | 1 | 23 |  |
| `A_ToggleAsymetricLiquidityAddition` | USAGE | 0 | 1 | 1 | 0 | 12 | 14 | 1 | 15 |  |
| `C_ToggleFeeLock` | SETUP | 0 | 2 | 4 | 0 | 7 | 13 | 1 | 14 |  |
| `C_EnableFrozenLP` | SETUP | 0 | 1 | 3 | 0 | 6 | 10 | 1 | 11 |  |
| `C_EnableSleepingLP` | SETUP | 0 | 1 | 3 | 0 | 6 | 10 | 1 | 11 |  |
| `A_UpdatePrincipal` | SETUP | 0 | 3 | 2 | 0 | 4 | 9 | 1 | 10 |  |
| `A_RotatePrincipal` | SETUP | 0 | 1 | 2 | 0 | 3 | 6 | 1 | 7 |  |
| `C_UpgradeBranding` | SETUP | 0 | 0 | 2 | 0 | 4 | 6 | 1 | 7 |  |
| `C_UpdateFee` | SETUP | 0 | 2 | 2 | 0 | 2 | 6 | 1 | 7 |  |
| `C_UpdatePendingBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | 1 | 6 |  |
| `C_ChangeOwnership` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_ModifyCanChangeOwner` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_ModifyWeights` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_UpdateAmplifier` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `C_UpdateSpecialFeeTargets` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `A_UpdateLimit` | SETUP | 0 | 2 | 1 | 0 | 1 | 4 | 1 | 5 |  |
| `A_UpdateLiquidBoost` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |
| `A_DefinePrimordialPool` | ISSUE | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |

## 16_SWPI.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_RebuildGraph` | SETUP | 1 | 0 | 1 | 0 | 20 | 24 | 1 | 25 |  |
| `C_Issue` | ISSUE | 1 | 0 | 1 | 0 | 18 | 22 | 1 | 23 |  |

## 18_SWPLC.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_RemoveLiquidity` | USAGE | 0 | 0 | 1 | 0 | 13 | 14 | 1000 | 1014 | deter LP add/remove churn (flat +1000 on tx-unit) |
| `C_Fuel` | USAGE | 0 | 0 | 1 | 0 | 10 | 11 | 1 | 12 |  |
| `C_UpdatePendingBrandingLPs` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | 1 | 11 |  |
| `C_UpgradeBrandingLPs` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |
| `C_ToggleAddLiquidity` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |

## 19_SWPU.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_SmartSwap` | USAGE | 0 | 0 | 1 | 0 | 82 | 83 | 1 | 84 |  |
| `CC_SmartSwap` | USAGE | 0 | 0 | 1 | 0 | 58 | 59 | 1 | 60 |  |
| `C_Swap` | USAGE | 0 | 0 | 1 | 0 | 52 | 53 | 1 | 54 |  |
| `C_ToggleSwapCapability` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |

## 20_MTX-SWP.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_AddSleepingLiquidity` | USAGE | 0 | 0 | 1 | 0 | 32 | 33 | 1000 | 1033 | deter LP add/remove churn (flat +1000 on tx-unit) |
| `C_AddFrozenLiquidity` | USAGE | 0 | 0 | 1 | 0 | 28 | 29 | 1000 | 1029 | deter LP add/remove churn (flat +1000 on tx-unit) |
| `C_AddStandardLiquidity` | USAGE | 0 | 0 | 1 | 0 | 25 | 26 | 1000 | 1026 | deter LP add/remove churn (flat +1000 on tx-unit) |
| `C_AddIcedLiquidity` | USAGE | 0 | 0 | 1 | 0 | 25 | 26 | 1000 | 1026 | deter LP add/remove churn (flat +1000 on tx-unit) |
| `C_AddGlacialLiquidity` | USAGE | 0 | 0 | 1 | 0 | 25 | 26 | 1000 | 1026 | deter LP add/remove churn (flat +1000 on tx-unit) |
| `C_IssueStablePool` | ISSUE | 1 | 0 | 1 | 0 | 21 | 25 | 1 | 26 |  |
| `C_IssueWeightedPool` | ISSUE | 1 | 0 | 1 | 0 | 21 | 25 | 1 | 26 |  |
| `C_IssueStandardPool` | ISSUE | 1 | 0 | 1 | 0 | 21 | 25 | 1 | 26 |  |

## 21_CODEX.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_RegisterStoicTag` | SETUP | 2 | 2 | 3 | 0 | 1 | 12 | 1 | 13 |  |
| `A_RegisterCodexIdentity` | SETUP | 1 | 0 | 1 | 0 | 1 | 5 | 1 | 6 |  |
| `C_RecordArweaveUpload` | SETUP | 1 | 0 | 1 | 0 | 1 | 5 | 1 | 6 |  |
| `C_ReleaseStoicTag` | SETUP | 0 | 2 | 2 | 0 | 1 | 5 | 1 | 6 |  |
| `C_RotateCodexGuard` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |

## 22_PYTHIA.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Flush` | USAGE | 2 | 3 | 4 | 1 | 1 | 15 | 1 | 16 |  |
| `A_LinkDualApiKey` | SETUP | 1 | 2 | 2 | 0 | 2 | 9 | 1 | 10 |  |
| `A_RevokeDualLink` | SETUP | 1 | 1 | 1 | 0 | 1 | 6 | 1 | 7 |  |
| `A_UpdateDeployPrice` | SETUP | 1 | 0 | 2 | 0 | 1 | 6 | 1 | 7 |  |
| `A_UpdateRenamePrice` | SETUP | 1 | 0 | 2 | 0 | 1 | 6 | 1 | 7 |  |
| `C_LinkDualApiKey` | SETUP | 1 | 1 | 1 | 0 | 1 | 6 | 1 | 7 |  |
| `C_RevokeDualLink` | SETUP | 1 | 1 | 1 | 0 | 1 | 6 | 1 | 7 |  |
| `C_DeployApolloPythiaApiKey` | ISSUE | 1 | 0 | 1 | 0 | 1 | 5 | 1 | 6 |  |
| `C_UpdateDualConsumerLane` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |

## 02_DPDC.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_UpdatePendingBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | 1 | 6 |  |
| `C_UpgradeBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | 1 | 6 |  |

## 03_DPDC-C.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_CreateNewNonce` | ISSUE | 0 | 0 | 2 | 0 | 23 | 25 | 1 | 26 |  |
| `C_CreateNewNonces` | ISSUE | 0 | 0 | 2 | 0 | 23 | 25 | 1 | 26 |  |

## 04_DPDC-I.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_IssueDigitalCollection` | ISSUE | 0 | 0 | 1 | 0 | 23 | 24 | 1 | 25 |  |

## 05_DPDC-R.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_MoveCreateRole` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | 1 | 11 |  |
| `C_MoveRecreateRole` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | 1 | 11 |  |
| `C_MoveSetUriRole` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | 1 | 11 |  |
| `C_ToggleAddQuantityRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_ToggleFreezeAccount` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_ToggleExemptionRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_ToggleBurnRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_ToggleUpdateRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_ToggleModifyCreatorRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_ToggleModifyRoyaltiesRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_ToggleTransferRole` | USAGE | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |

## 06_DPDC-MNG.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_WipeClean` | SETUP | 0 | 0 | 1 | 2 | 17 | 20 | 1 | 21 |  |
| `C_WipeHeavy` | SETUP | 0 | 0 | 1 | 2 | 16 | 19 | 1 | 20 |  |
| `C_WipePure` | SETUP | 0 | 0 | 1 | 2 | 16 | 19 | 1 | 20 |  |
| `C_WipeDirty` | SETUP | 0 | 0 | 1 | 2 | 16 | 19 | 1 | 20 |  |
| `C_WipeNonce` | SETUP | 0 | 0 | 1 | 0 | 12 | 13 | 1 | 14 |  |
| `C_Control` | SETUP | 0 | 0 | 1 | 0 | 7 | 8 | 1 | 9 |  |
| `C_BurnSFT` | SETUP | 0 | 0 | 1 | 0 | 7 | 8 | 1 | 9 |  |
| `C_WipeSlim` | SETUP | 0 | 0 | 1 | 0 | 7 | 8 | 1 | 9 |  |
| `C_AddQuantity` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_BurnNFT` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_TogglePause` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | 1 | 6 |  |
| `C_RespawnNFT` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | 1 | 6 |  |

## 07_DPDC-T.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Transfer` | USAGE | 0 | 0 | 1 | 0 | 27 | 28 | 1 | 29 |  |
| `C_BulkTransfer` | USAGE | 0 | 0 | 1 | 0 | 27 | 28 | 1 | 29 |  |
| `C_RepurposeCollectable` | USAGE | 0 | 0 | 1 | 0 | 18 | 19 | 1 | 20 |  |
| `C_IgnisRoyaltyCollector` | USAGE | 0 | 0 | 1 | 0 | 12 | 13 | 1 | 14 |  |

## 08_DPDC-S.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_DefineHybridSet` | ISSUE | 2 | 0 | 1 | 0 | 13 | 20 | 1 | 21 |  |
| `C_DefinePrimordialSet` | ISSUE | 2 | 0 | 1 | 0 | 12 | 19 | 1 | 20 |  |
| `C_DefineCompositeSet` | ISSUE | 2 | 0 | 1 | 0 | 12 | 19 | 1 | 20 |  |
| `C_BreakSemiFungibleSet` | SETUP | 0 | 0 | 3 | 0 | 11 | 14 | 1 | 15 |  |
| `C_MakeNonFungibleSet` | ISSUE | 0 | 0 | 3 | 0 | 10 | 13 | 1 | 14 |  |
| `C_BreakNonFungibleSet` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | 1 | 11 |  |
| `C_EnableSetClassFragmentation` | SETUP | 0 | 4 | 1 | 0 | 3 | 8 | 1 | 9 |  |
| `C_MakeSemiFungibleSet` | ISSUE | 0 | 0 | 3 | 0 | 4 | 7 | 1 | 8 |  |
| `C_ToggleSet` | SETUP | 0 | 2 | 1 | 0 | 3 | 6 | 1 | 7 |  |
| `C_RenameSet` | SETUP | 0 | 2 | 1 | 0 | 3 | 6 | 1 | 7 |  |

## 09_DPDC-F.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_RepurposeCollectableFragments` | USAGE | 0 | 0 | 1 | 0 | 18 | 19 | 1 | 20 |  |
| `C_MakeFragments` | ISSUE | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |
| `C_MergeFragments` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |
| `C_EnableNonceFragmentation` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |

## 10_DPDC-N.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_UpdateNonceScore` | SETUP | 0 | 0 | 3 | 0 | 8 | 11 | 1 | 12 |  |
| `C_UpdateNonceMetaData` | SETUP | 0 | 0 | 3 | 0 | 8 | 11 | 1 | 12 |  |
| `C_UpdateNonceRoyalty` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | 1 | 11 |  |
| `C_UpdateNonceIgnisRoyalty` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | 1 | 11 |  |
| `C_UpdateNonceName` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | 1 | 11 |  |
| `C_UpdateNonceDescription` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | 1 | 11 |  |
| `C_UpdateNonceURI` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | 1 | 11 |  |
| `C_UpdateNonces` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |

## 11_EQUITY+.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_IssueShareholderCollection` | ISSUE | 0 | 0 | 1 | 0 | 43 | 44 | 1 | 45 |  |
| `C_MorphPackageShares` | SETUP | 0 | 0 | 1 | 0 | 18 | 19 | 1 | 20 |  |

## 00_Demipad.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Deposit` | USAGE | 0 | 10 | 9 | 0 | 35 | 54 | 1 | 55 |  |
| `C_Withdraw` | USAGE | 0 | 3 | 4 | 0 | 5 | 12 | 1 | 13 |  |
| `C_TransmitSemiFungibles` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_TransmitNonFungibles` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `A_RegisterAssetToLaunchpad` | SETUP | 1 | 0 | 1 | 0 | 1 | 5 | 1 | 6 |  |
| `C_TransmitTrueFungible` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | 1 | 6 |  |
| `C_TransmitOrtoFungible` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | 1 | 6 |  |
| `A_ToggleOpenForBusiness` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |
| `A_DefinePrice` | ISSUE | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |
| `A_ToggleRetrieval` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | 1 | 4 |  |

## 01_ANK.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_IssueTrueFungibleAnchor` | ISSUE | 4 | 0 | 4 | 0 | 7 | 23 | 1 | 24 |  |
| `C_IssueSemiFungibleAnchor` | ISSUE | 4 | 0 | 4 | 0 | 7 | 23 | 1 | 24 |  |
| `C_IssueNonFungibleAnchor` | ISSUE | 4 | 0 | 4 | 0 | 7 | 23 | 1 | 24 |  |
| `C_IssueNonFungibleSetAnchor` | ISSUE | 4 | 0 | 4 | 0 | 7 | 23 | 1 | 24 |  |
| `C_RevokeAnchor` | SETUP | 2 | 1 | 6 | 0 | 6 | 19 | 1 | 20 |  |
| `C_RevokeBoostClass` | SETUP | 0 | 1 | 1 | 0 | 2 | 4 | 1 | 5 |  |

## 02_SCORE.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_IssueScoreFromModel` | ISSUE | 4 | 1 | 6 | 0 | 4 | 23 | 1 | 24 |  |
| `C_IssueNonFungibleScoreDefinition` | ISSUE | 4 | 0 | 7 | 0 | 3 | 22 | 1 | 23 |  |
| `C_IssueNonFungibleSetScoreDefinition` | ISSUE | 4 | 0 | 7 | 0 | 3 | 22 | 1 | 23 |  |
| `C_IssueSemiFungibleScoreDefinition` | ISSUE | 2 | 0 | 3 | 0 | 3 | 12 | 1 | 13 |  |
| `C_IssueLiquidityScore` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1 | 11 |  |
| `C_IssueTrueFungibleScore` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1 | 11 |  |
| `C_IssueOrtoFungibleScore` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1 | 11 |  |
| `C_IssueSemiFungibleScore` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1 | 11 |  |
| `C_IssueNonFungibleScore` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1 | 11 |  |
| `C_IssueTriplet` | ISSUE | 1 | 1 | 4 | 0 | 2 | 10 | 1 | 11 |  |
| `C_CreateBoostClassLink` | ISSUE | 0 | 1 | 3 | 0 | 3 | 7 | 1 | 8 |  |
| `C_IssueSingleScoreModel` | ISSUE | 1 | 0 | 1 | 0 | 3 | 7 | 1 | 8 |  |
| `C_CombineTripletScoreModel` | SETUP | 1 | 0 | 1 | 0 | 3 | 7 | 1 | 8 |  |
| `C_RotateOwnership` | SETUP | 0 | 1 | 2 | 0 | 1 | 4 | 1 | 5 |  |
| `C_Control` | SETUP | 0 | 1 | 2 | 0 | 1 | 4 | 1 | 5 |  |
| `C_CreateBoostLink` | ISSUE | 0 | 1 | 2 | 0 | 1 | 4 | 1 | 5 |  |
| `C_EnableDebBoost` | SETUP | 0 | 1 | 2 | 0 | 1 | 4 | 1 | 5 |  |

## 03_AQP.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_SyncCollectableAnchors` | USAGE | 2 | 0 | 3 | 3 | 7 | 19 | 1 | 20 |  |
| `C_RevokeScore` | SETUP | 0 | 1 | 8 | 0 | 5 | 14 | 1 | 15 |  |
| `C_AddScore` | SETUP | 0 | 1 | 8 | 0 | 3 | 12 | 1 | 13 |  |
| `C_Issue` | ISSUE | 1 | 0 | 1 | 0 | 5 | 9 | 1 | 10 |  |
| `C_SyncTrueFungibleAnchors` | SETUP | 0 | 1 | 2 | 0 | 6 | 9 | 1 | 10 |  |
| `C_DisablePoolStake` | USAGE | 0 | 1 | 1 | 0 | 2 | 4 | 1 | 5 |  |
| `C_EnablePoolStake` | USAGE | 0 | 1 | 1 | 0 | 2 | 4 | 1 | 5 |  |

## 05_FVT.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `CC_Collect` | USAGE | 0 | 0 | 1 | 0 | 28 | 29 | 1 | 30 |  |
| `C_AddScoreEntity` | SETUP | 0 | 0 | 1 | 0 | 19 | 20 | 1 | 21 |  |
| `CC_TrueFungibleStakeFlow` | USAGE | 0 | 0 | 1 | 0 | 19 | 20 | 1 | 21 |  |
| `CC_CollectableStakeFlow` | USAGE | 0 | 0 | 1 | 0 | 19 | 20 | 1 | 21 |  |
| `CC_SweepRevokeAnchor` | USAGE | 0 | 0 | 1 | 0 | 14 | 15 | 1 | 16 |  |
| `CC_SweepBegin` | USAGE | 2 | 0 | 2 | 0 | 7 | 15 | 1 | 16 |  |
| `CCp_SweepRecomputeChunk` | USAGE | 2 | 0 | 2 | 0 | 6 | 14 | 1 | 15 |  |
| `CC_OrtoFungibleStakeFlow` | USAGE | 0 | 0 | 1 | 0 | 13 | 14 | 1 | 15 |  |
| `CCp_UnstaleAll` | USAGE | 0 | 0 | 1 | 0 | 11 | 12 | 1 | 13 |  |
| `CC_Inject` | USAGE | 0 | 0 | 1 | 0 | 10 | 11 | 1 | 12 |  |
| `C_Issue` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1 | 11 |  |
| `CCp_InjectFixChunk` | USAGE | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |
| `C_SetCommonDenominator` | SETUP | 0 | 1 | 1 | 0 | 4 | 6 | 1 | 7 |  |
| `C_SetMosaic` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 1 | 7 |  |
| `C_SetSplitMode` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 1 | 7 |  |
| `C_ToggleScoreEntityLink` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 1 | 7 |  |
| `C_AddRewardLink` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 1 | 7 |  |
| `C_ToggleRewardLink` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 1 | 7 |  |
| `C_SetQualitySplit` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 1 | 7 |  |
| `CC_UnstaleMyScores` | USAGE | 0 | 0 | 1 | 0 | 5 | 6 | 1 | 7 |  |
| `C_Control` | SETUP | 0 | 1 | 1 | 0 | 3 | 5 | 1 | 6 |  |
| `C_IssueMultipletFamily` | ISSUE | 0 | 0 | 1 | 0 | 4 | 5 | 1 | 6 |  |
| `CC_InjectFinalize` | USAGE | 0 | 0 | 1 | 1 | 3 | 5 | 1 | 6 |  |
| `C_RotateOwnership` | SETUP | 0 | 0 | 1 | 0 | 3 | 4 | 1 | 5 |  |
| `CC_InjectStream` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |

## 06_VCT.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `CC_FullVacate` | USAGE | 0 | 0 | 1 | 0 | 48 | 49 | 1 | 50 |  |
| `CCp_BatchVacateTrueFungible` | USAGE | 0 | 0 | 1 | 0 | 32 | 33 | 1 | 34 |  |
| `CCp_BatchVacateCollectables` | USAGE | 0 | 0 | 1 | 0 | 31 | 32 | 1 | 33 |  |
| `CCp_BatchVacateOrtoFungible` | USAGE | 0 | 0 | 1 | 0 | 29 | 30 | 1 | 31 |  |
| `CCp_BatchDrainTrueFungible` | USAGE | 0 | 0 | 1 | 0 | 21 | 22 | 1 | 23 |  |
| `CCp_BatchDrainCollectable` | USAGE | 0 | 0 | 1 | 0 | 20 | 21 | 1 | 22 |  |
| `CCp_BatchDrainOrtoFungible` | USAGE | 0 | 0 | 1 | 0 | 18 | 19 | 1 | 20 |  |
| `C_FinalizeVacate` | USAGE | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |
| `C_AbortVacate` | USAGE | 0 | 0 | 1 | 0 | 6 | 7 | 1 | 8 |  |

## 07_MTX-AQP.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_2|SweepRevokeAnchor` | USAGE | 0 | 0 | 1 | 0 | 10 | 11 | 1 | 12 |  |
| `C_2|Inject` | USAGE | 0 | 0 | 1 | 0 | 5 | 6 | 1 | 7 |  |

## 08_DSA.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_OracleWrite` | SETUP | 0 | 1 | 3 | 0 | 8 | 12 | 1 | 13 |  |
| `C_RecomputeCapture` | SETUP | 0 | 0 | 3 | 0 | 8 | 11 | 1 | 12 |  |
| `A_SetOracleAuth` | SETUP | 1 | 0 | 1 | 0 | 3 | 7 | 1 | 8 |  |
| `A_DefineDelegationVault` | ISSUE | 1 | 0 | 1 | 0 | 2 | 6 | 1 | 7 |  |
| `C_AdmitAgency` | SETUP | 1 | 0 | 1 | 0 | 2 | 6 | 1 | 7 |  |
| `A_SetAgencyFee` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 1 | 6 |  |
| `A_WithdrawRoyalty` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |
| `A_BurnRoyalty` | SETUP | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |
| `A_FuelRoyalty` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 1 | 4 |  |
| `A_ToggleExternalOracle` | SETUP | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 |  |
| `A_SetOracleValidity` | SETUP | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 |  |

## 05_TS02-DPAD.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_RegisterAssetToLaunchpad` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_ToggleOpenForBusiness` | SETUP | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 2 |  |
| `A_DefinePrice` | ISSUE | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 2 |  |
| `A_ToggleRetrieval` | SETUP | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 2 |  |

## 01_AOZ+.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_RegisterPrimalTrueFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | 1 | 7 |  |
| `A_RegisterPrimalOrtoFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | 1 | 7 |  |
| `A_RegisterAutostakePair` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | 1 | 7 |  |
| `A_RegisterTrueFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | 1 | 7 |  |
| `A_RegisterOrtoFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | 1 | 7 |  |
| `A_RegisterSemiFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | 1 | 7 |  |
| `A_RegisterNonFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | 1 | 7 |  |
| `C_SetupKosonicATS` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 1 | 7 |  |
| `A_InitialiseCounters` | SETUP | 1 | 0 | 0 | 0 | 0 | 3 | 1 | 4 |  |

## 01_BSD-L.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Legendary` | SETUP | 0 | 0 | 0 | 0 | 8 | 8 | 1 | 9 |  |
| `A_Issue` | ISSUE | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 2 |  |

## 02_BSD-E.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Epic` | SETUP | 0 | 0 | 0 | 0 | 8 | 8 | 1 | 9 |  |

## 03_BSD-R.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Rare` | SETUP | 0 | 0 | 0 | 0 | 8 | 8 | 1 | 9 |  |

## 04_BSD-C.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Common` | SETUP | 0 | 0 | 0 | 0 | 8 | 8 | 1 | 9 |  |

## 01_NOSFERATU.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Fix01` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix02a` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix02b` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix03` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix04` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix05a` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix05b` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix06` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix07` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix08` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix09` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix10` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix11` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix12` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix13` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix14` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix15` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix16` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix17` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix18` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix19` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix20` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix21` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Fix22` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step01` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step02` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step03` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step04` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step05` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step06` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step07` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step08` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step09` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step10` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step11` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step12` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step13` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step14` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step15` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step16` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step17` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step18` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step19` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step20` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step21` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step22` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `C_Spawn` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `C_Fix` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |

## 02_KBunnies.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_BunnyRGBSet` | SETUP | 0 | 0 | 0 | 0 | 10 | 10 | 1 | 11 |  |
| `A_Step01` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step02` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step03` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step04` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step05` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step06` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step07` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step08` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step09` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step10` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step11` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step12` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step13` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step14` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step15` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `A_Step16` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |
| `C_Spawn` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | 1 | 7 |  |

## 04_AQP-BOOT.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Step3_CreateBoosterAnchorClasses` | SETUP | 0 | 0 | 0 | 0 | 25 | 25 | 1 | 26 |  |
| `C_Step7_CreatePoolsAndScores` | SETUP | 0 | 0 | 0 | 0 | 19 | 19 | 1 | 20 |  |
| `C_Step5_CreateSubsidiaryScores` | SETUP | 0 | 0 | 0 | 0 | 15 | 15 | 1 | 16 |  |
| `C_Step2_CreateSnakePowerAnchorClasses` | SETUP | 0 | 0 | 0 | 0 | 11 | 11 | 1 | 12 |  |
| `C_Step6_CreateOuroLpTriplet` | SETUP | 0 | 0 | 0 | 0 | 11 | 11 | 1 | 12 |  |
| `C_Step8_IssueFvtEntities` | SETUP | 0 | 0 | 0 | 0 | 10 | 10 | 1 | 11 |  |
| `C_Step0_WireImcAndGovernor` | SETUP | 0 | 0 | 0 | 0 | 9 | 9 | 1 | 10 |  |
| `C_Step4_CreateCoreScores` | SETUP | 0 | 0 | 0 | 0 | 8 | 8 | 1 | 9 |  |
| `C_Step12_AddFvtRewardLinks` | SETUP | 0 | 0 | 0 | 0 | 5 | 5 | 1 | 6 |  |
| `C_Step9_AddFvtScoreEntities` | SETUP | 0 | 0 | 0 | 0 | 4 | 4 | 1 | 5 |  |
| `C_Step11_WireFarmTriplet` | SETUP | 0 | 0 | 0 | 0 | 3 | 3 | 1 | 4 |  |
| `C_Step10_IssueMultipletFamily` | SETUP | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 2 |  |
| `C_Step1_CreateBunnySet` | SETUP | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 |  |

## 03_CADUCEUS.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_MintToUserFromBridgeSignal` | ISSUE | 1 | 0 | 4 | 2 | 2 | 11 | 1 | 12 |  |
| `C_BurnFromBridgeSignal` | SETUP | 1 | 0 | 4 | 2 | 1 | 10 | 1 | 11 |  |
| `A_ProvisionBridgeDptfRoles` | SETUP | 0 | 0 | 3 | 1 | 4 | 8 | 1 | 9 |  |
| `A_DeployBridgeSmartAccount` | ISSUE | 0 | 0 | 4 | 1 | 1 | 6 | 1 | 7 |  |
| `A_SetBridgeConfig` | SETUP | 1 | 0 | 0 | 0 | 0 | 3 | 1 | 4 |  |
| `A_SetBridgeActive` | SETUP | 0 | 1 | 0 | 0 | 0 | 1 | 1 | 2 |  |

## 01_Spark.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_RedemAllSparks` | SETUP | 0 | 0 | 1 | 0 | 13 | 14 | 1 | 15 |  |
| `C_CustomRedemAllSparks` | SETUP | 0 | 0 | 1 | 0 | 12 | 13 | 1 | 14 |  |
| `C_RedemFewSparks` | SETUP | 0 | 0 | 1 | 0 | 12 | 13 | 1 | 14 |  |
| `C_CustomRedemFewSparks` | SETUP | 0 | 0 | 1 | 0 | 11 | 12 | 1 | 13 |  |
| `C_BuySparks` | SETUP | 0 | 0 | 1 | 0 | 7 | 8 | 1 | 9 |  |

## 02_Snakes.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Acquire` | SETUP | 0 | 0 | 1 | 0 | 15 | 16 | 1 | 17 |  |
| `A_UpdateSharePrice` | SETUP | 0 | 0 | 1 | 0 | 1 | 2 | 1 | 3 |  |

## 03_Custodians.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_Acquire` | SETUP | 0 | 0 | 1 | 0 | 14 | 15 | 1 | 16 |  |
| `A_UpdateQuintessencePrice` | SETUP | 0 | 0 | 1 | 0 | 1 | 2 | 1 | 3 |  |

## 04_STOICPAY.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `C_BuyStoicPay` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | 1 | 10 |  |

## 05_STOAICO.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_Stake` | USAGE | 1 | 8 | 12 | 0 | 2 | 25 | 1 | 26 |  |
| `Ap_FlushUncollectedSlice` | USAGE | 0 | 6 | 11 | 0 | 4 | 21 | 1 | 22 |  |
| `AA_FlushUncollected` | USAGE | 0 | 6 | 10 | 1 | 4 | 21 | 1 | 22 |  |
| `C_Collect` | USAGE | 0 | 6 | 10 | 0 | 4 | 20 | 1 | 21 |  |
| `A_Unstake` | USAGE | 0 | 7 | 10 | 0 | 2 | 19 | 1 | 20 |  |
| `A_Inject` | USAGE | 0 | 5 | 8 | 0 | 2 | 15 | 1 | 16 |  |
| `A_InitialiseDistributionVault` | SETUP | 1 | 0 | 0 | 0 | 7 | 10 | 1 | 11 |  |

## 03_DSP+.pact

| op | role | ins/wr | upd | R | S | X | components | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|------:|-----:|-----------|
| `A_KosonMinterStageOne` | SETUP | 0 | 0 | 0 | 0 | 37 | 37 | 1 | 38 |  |
| `A_KosonMinterStageOne_1of3` | SETUP | 0 | 0 | 0 | 0 | 18 | 18 | 1 | 19 |  |
| `A_OuroMinterStageOne` | SETUP | 0 | 0 | 0 | 0 | 17 | 17 | 1 | 18 |  |
| `A_KosonMinterStageOne_2of3` | SETUP | 0 | 0 | 0 | 0 | 15 | 15 | 1 | 16 |  |
| `A_KosonMinterStageOne_3of3` | SETUP | 0 | 0 | 0 | 0 | 15 | 15 | 1 | 16 |  |
| `A_StoicismMinter` | SETUP | 0 | 0 | 0 | 0 | 2 | 2 | 1 | 3 |  |

---
469 ops · 6 pre-suggested deter>1 (rest default 1). Revise & green-light.

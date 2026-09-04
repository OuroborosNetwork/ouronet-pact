# IGNIS deterrence worksheet (#76) — SUGGESTED, for owner revision

FINAL = deter·IG|TX(1) + [ 3·(insert/write) + 1·update + 1·read + 1·scan + 1·xcall ] (module-internal transitive; approx —
cross-module callee internals not summed, so delegating ops read low).
deter default 1 (no extra). Revise the `deter` column; I green-light nothing myself.

S1 CONSTRAINT — auto account-creation inside a transfer (recipient has no account yet) is
IGNIS-FREE: it is subsumed in the transfer (deter 1), never billed as a separate op. Only the
explicit C_DeployAccount entrypoint (deliberate token-account creation) carries an IGNIS deterrent.


## 01_DALOS.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_UpdateUsagePrice` | SETUP | 1 | 0 | 1 | 0 | 2 | 6 | · | 🟨 25x | 31 | economic-parameter change (fee/price/rate) |
| `A_SetIgnisSourcePrice` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟨 25x | 28 | economic-parameter change (fee/price/rate) |
| `C_RotateStoa` | SETUP | 2 | 1 | 3 | 0 | 3 | 13 | · | 🟪 10x | 23 | role/authority/guard setup |
| `C_RotateGuard` | SETUP | 0 | 2 | 2 | 0 | 1 | 5 | · | 🟪 10x | 15 | role/authority/guard setup |
| `C_RotateGovernor` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟪 10x | 13 | role/authority/guard setup |
| `C_RotateSovereign` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟪 10x | 13 | role/authority/guard setup |
| `A_MigrateLiquidFunds` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `A_ToggleOAPU` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |
| `A_ToggleGAP` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |
| `A_UpdatePublicKey` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |
| `C_ControlSmartAccount` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |
| `A_ToggleGasCollection` | USAGE | 0 | 2 | 1 | 0 | 1 | 4 | · | 🟩 1x | 5 | legit activity — pure compute, no deterrent |
| `A_SetAutoFueling` | USAGE | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟩 1x | 4 | legit activity — pure compute, no deterrent |
| `A_DeploySmartAccount` | ISSUE | 3 | 0 | 1 | 0 | 2 | 12 | · | ⬜ exempt | 0 | IGNIS-EXEMPT — admin account deploy: fully FREE (no STOA, no IGNIS) |
| `A_DeployStandardAccount` | ISSUE | 3 | 0 | 1 | 0 | 2 | 12 | · | ⬜ exempt | 0 | IGNIS-EXEMPT — admin account deploy: fully FREE (no STOA, no IGNIS) |
| `C_DeploySmartAccount` | ISSUE | 3 | 0 | 2 | 0 | 3 | 14 | · | ⬜ exempt | 0 | IGNIS-EXEMPT — user account deploy: STOA-priced, no IGNIS finish cost |
| `C_DeployStandardAccount` | ISSUE | 3 | 0 | 2 | 0 | 3 | 14 | · | ⬜ exempt | 0 | IGNIS-EXEMPT — user account deploy: STOA-priced, no IGNIS finish cost |

## 02_IGNIS.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_TransferDalosFuel` | USAGE | 0 | 0 | 0 | 0 | 1 | 1 | · | 🟩 1x | 2 | legit activity — pure compute, no deterrent |
| `C_Collect` | USAGE | 0 | 0 | 2 | 0 | 24 | 26 | · | ⬜ exempt | 0 | IGNIS-EXEMPT — the ignis collector itself |

## 04_BRD.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_Live` | SETUP | 0 | 2 | 3 | 0 | 1 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_SetFlag` | SETUP | 0 | 2 | 3 | 0 | 1 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |

## 05_DPTF.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Mint` | ISSUE | 2 | 3 | 9 | 0 | 13 | 31 | · | 🟧 50x | 81 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_Issue` | ISSUE | 3 | 0 | 3 | 0 | 14 | 26 | · | 🟧 50x | 76 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_DeployAccount` | ISSUE | 1 | 0 | 3 | 0 | 3 | 9 | · | 🟧 50x | 59 | explicit token-account creation — IGNIS deterrent vs on-purpose spam (auto-creation inside a transfer is FREE) |
| `C_ToggleFeeExemptionRole` | SETUP | 1 | 2 | 6 | 0 | 9 | 20 | · | 🟨 25x | 45 | economic-parameter change (fee/price/rate) |
| `A_WipeTreasuryDebt` | SETUP | 2 | 3 | 9 | 0 | 16 | 34 | · | 🟦 5x | 39 | management/config/property change — slightly expensive |
| `A_WipeTreasuryDebtPartial` | SETUP | 2 | 3 | 9 | 0 | 15 | 33 | · | 🟦 5x | 38 | management/config/property change — slightly expensive |
| `C_ToggleFeeLock` | SETUP | 0 | 2 | 4 | 0 | 7 | 13 | · | 🟨 25x | 38 | economic-parameter change (fee/price/rate) |
| `C_ToggleFee` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟨 25x | 30 | economic-parameter change (fee/price/rate) |
| `C_SetFee` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟨 25x | 30 | economic-parameter change (fee/price/rate) |
| `C_SetFeeTarget` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟨 25x | 30 | economic-parameter change (fee/price/rate) |
| `C_ToggleBurnRole` | SETUP | 1 | 2 | 6 | 0 | 9 | 20 | · | 🟪 10x | 30 | role/authority/guard setup |
| `C_ToggleMintRole` | SETUP | 1 | 2 | 6 | 0 | 9 | 20 | · | 🟪 10x | 30 | role/authority/guard setup |
| `C_Burn` | SETUP | 1 | 2 | 7 | 0 | 11 | 23 | · | 🟦 5x | 28 | management/config/property change — slightly expensive |
| `C_WipeSlim` | SETUP | 1 | 2 | 8 | 0 | 9 | 22 | · | 🟦 5x | 27 | management/config/property change — slightly expensive |
| `C_Wipe` | SETUP | 1 | 2 | 8 | 0 | 9 | 22 | · | 🟦 5x | 27 | management/config/property change — slightly expensive |
| `C_ToggleFreezeAccount` | SETUP | 1 | 2 | 6 | 0 | 9 | 20 | · | 🟦 5x | 25 | management/config/property change — slightly expensive |
| `C_ToggleTransferRole` | USAGE | 1 | 2 | 6 | 0 | 9 | 20 | · | 🟩 1x | 21 | legit activity — pure compute, no deterrent |
| `C_RotateOwnership` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟪 10x | 15 | role/authority/guard setup |
| `C_UpgradeBranding` | SETUP | 0 | 0 | 4 | 0 | 4 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |
| `C_UpdatePendingBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_Control` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_TogglePause` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_ToggleReservation` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_SetMinMove` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `A_UpdateTreasury` | SETUP | 0 | 0 | 1 | 0 | 2 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |

## 06_DPOF.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 3 | 0 | 4 | 0 | 13 | 26 | · | 🟧 50x | 76 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_Mint` | ISSUE | 2 | 4 | 11 | 0 | 4 | 25 | · | 🟧 50x | 75 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_DeployAccount` | ISSUE | 1 | 0 | 4 | 0 | 2 | 9 | · | 🟧 50x | 59 | explicit token-account creation — IGNIS deterrent vs on-purpose spam (auto-creation inside a transfer is FREE) |
| `C_Transmit` | SETUP | 2 | 5 | 13 | 0 | 7 | 31 | · | 🟦 5x | 36 | management/config/property change — slightly expensive |
| `C_AddQuantity` | SETUP | 2 | 4 | 11 | 0 | 3 | 24 | · | 🟦 5x | 29 | management/config/property change — slightly expensive |
| `C_ToggleAddQuantityRole` | SETUP | 1 | 2 | 7 | 0 | 4 | 16 | · | 🟪 10x | 26 | role/authority/guard setup |
| `C_ToggleBurnRole` | SETUP | 1 | 2 | 7 | 0 | 4 | 16 | · | 🟪 10x | 26 | role/authority/guard setup |
| `C_MoveCreateRole` | SETUP | 1 | 3 | 6 | 0 | 3 | 15 | · | 🟪 10x | 25 | role/authority/guard setup |
| `C_WipeHeavy` | SETUP | 0 | 5 | 7 | 3 | 5 | 20 | · | 🟦 5x | 25 | management/config/property change — slightly expensive |
| `C_WipePure` | SETUP | 0 | 5 | 7 | 3 | 5 | 20 | · | 🟦 5x | 25 | management/config/property change — slightly expensive |
| `C_WipeClean` | SETUP | 0 | 5 | 7 | 3 | 5 | 20 | · | 🟦 5x | 25 | management/config/property change — slightly expensive |
| `C_ToggleFreezeAccount` | SETUP | 1 | 2 | 7 | 0 | 4 | 16 | · | 🟦 5x | 21 | management/config/property change — slightly expensive |
| `C_Transfer` | USAGE | 1 | 2 | 8 | 0 | 7 | 20 | · | 🟩 1x | 21 | legit activity — pure compute, no deterrent |
| `C_BulkTransfer` | USAGE | 1 | 2 | 8 | 0 | 7 | 20 | · | 🟩 1x | 21 | legit activity — pure compute, no deterrent |
| `C_Burn` | SETUP | 0 | 5 | 7 | 0 | 2 | 14 | · | 🟦 5x | 19 | management/config/property change — slightly expensive |
| `C_WipeSlim` | SETUP | 0 | 5 | 7 | 0 | 2 | 14 | · | 🟦 5x | 19 | management/config/property change — slightly expensive |
| `C_ToggleTransferRole` | USAGE | 1 | 2 | 7 | 0 | 4 | 16 | · | 🟩 1x | 17 | legit activity — pure compute, no deterrent |
| `C_UpgradeBranding` | SETUP | 0 | 0 | 5 | 0 | 5 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_RotateOwnership` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟪 10x | 15 | role/authority/guard setup |
| `C_UpdatePendingBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_Control` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_TogglePause` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |

## 08_ATS.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 1 | 0 | 1 | 0 | 18 | 22 | · | 🟧 50x | 72 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_SetColdRecoveryFees` | SETUP | 0 | 1 | 1 | 0 | 6 | 8 | · | 🟨 25x | 33 | economic-parameter change (fee/price/rate) |
| `C_SetHibernationFees` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟨 25x | 30 | economic-parameter change (fee/price/rate) |
| `C_ControlColdRecoveryFees` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟨 25x | 30 | economic-parameter change (fee/price/rate) |
| `C_ControlHotRecoveryFee` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟨 25x | 30 | economic-parameter change (fee/price/rate) |
| `C_SetHotRecoveryFees` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟨 25x | 30 | economic-parameter change (fee/price/rate) |
| `C_SetDirectRecoveryFee` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟨 25x | 30 | economic-parameter change (fee/price/rate) |
| `C_AddHotRBT` | SETUP | 0 | 1 | 1 | 0 | 12 | 14 | · | 🟦 5x | 19 | management/config/property change — slightly expensive |
| `C_ToggleParameterLock` | SETUP | 0 | 2 | 3 | 0 | 7 | 12 | · | 🟦 5x | 17 | management/config/property change — slightly expensive |
| `C_AddSecondary` | SETUP | 0 | 1 | 2 | 0 | 9 | 12 | · | 🟦 5x | 17 | management/config/property change — slightly expensive |
| `C_RotateOwnership` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟪 10x | 15 | role/authority/guard setup |
| `C_SetColdRecoveryDuration` | SETUP | 0 | 2 | 2 | 0 | 4 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |
| `C_UpgradeBranding` | SETUP | 0 | 0 | 2 | 0 | 4 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_UpdatePendingBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_Control` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_UpdateRoyalty` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_ToggleElite` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_ToggleUpgrade` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_SwitchColdRecovery` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_SwitchHotRecovery` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_SwitchDirectRecovery` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_UpdateSyphon` | USAGE | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟩 1x | 6 | legit activity — pure compute, no deterrent |

## 09_TFT.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_MultiBulkTransfer` | USAGE | 0 | 0 | 1 | 0 | 71 | 72 | · | 🟩 1x | 73 | legit activity — pure compute, no deterrent |
| `C_MultiTransfer` | USAGE | 0 | 0 | 1 | 0 | 69 | 70 | · | 🟩 1x | 71 | legit activity — pure compute, no deterrent |
| `C_Transfer` | USAGE | 0 | 0 | 1 | 0 | 68 | 69 | · | 🟩 1x | 70 | legit activity — pure compute, no deterrent |
| `C_Transmute` | SETUP | 0 | 0 | 1 | 0 | 50 | 51 | · | 🟦 5x | 56 | management/config/property change — slightly expensive |
| `C_ClearDispo` | SETUP | 0 | 0 | 1 | 0 | 25 | 26 | · | 🟦 5x | 31 | management/config/property change — slightly expensive |

## 10_ATSU.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Cull` | SETUP | 0 | 0 | 1 | 0 | 62 | 63 | · | 🟦 5x | 68 | management/config/property change — slightly expensive |
| `C_ColdRecovery` | SETUP | 0 | 0 | 1 | 0 | 61 | 62 | · | 🟦 5x | 67 | management/config/property change — slightly expensive |
| `A_RemoveSecondary` | SETUP | 0 | 0 | 1 | 0 | 20 | 21 | · | 🟦 5x | 26 | management/config/property change — slightly expensive |
| `C_RemoveSecondary` | SETUP | 0 | 0 | 1 | 0 | 20 | 21 | · | 🟦 5x | 26 | management/config/property change — slightly expensive |
| `C_Redeem` | SETUP | 0 | 0 | 1 | 0 | 20 | 21 | · | 🟦 5x | 26 | management/config/property change — slightly expensive |
| `C_DirectRecovery` | SETUP | 0 | 0 | 1 | 0 | 13 | 14 | · | 🟦 5x | 19 | management/config/property change — slightly expensive |
| `C_HotRecovery` | SETUP | 0 | 0 | 1 | 0 | 12 | 13 | · | 🟦 5x | 18 | management/config/property change — slightly expensive |
| `A_KickStart` | SETUP | 0 | 0 | 1 | 0 | 11 | 12 | · | 🟦 5x | 17 | management/config/property change — slightly expensive |
| `C_Recover` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_Curl` | USAGE | 0 | 0 | 1 | 0 | 12 | 13 | · | 🟩 1x | 14 | legit activity — pure compute, no deterrent |
| `C_Coil` | USAGE | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟩 1x | 10 | legit activity — pure compute, no deterrent |
| `C_Syphon` | USAGE | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟩 1x | 8 | legit activity — pure compute, no deterrent |
| `C_WithdrawRoyalties` | USAGE | 0 | 0 | 1 | 0 | 5 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `C_KickStart` | SETUP | 0 | 0 | 1 | 0 | 1 | 2 | · | 🟦 5x | 7 | management/config/property change — slightly expensive |
| `C_Fuel` | USAGE | 0 | 0 | 1 | 0 | 3 | 4 | · | 🟩 1x | 5 | legit activity — pure compute, no deterrent |

## 11_VST.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_CreateFrozenLink` | ISSUE | 0 | 0 | 1 | 0 | 14 | 15 | · | 🟧 50x | 65 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateReservationLink` | ISSUE | 0 | 0 | 1 | 0 | 14 | 15 | · | 🟧 50x | 65 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateVestingLink` | ISSUE | 0 | 0 | 1 | 0 | 14 | 15 | · | 🟧 50x | 65 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateSleepingLink` | ISSUE | 0 | 0 | 1 | 0 | 14 | 15 | · | 🟧 50x | 65 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateHibernatingLink` | ISSUE | 0 | 0 | 1 | 0 | 14 | 15 | · | 🟧 50x | 65 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_Merge` | SETUP | 0 | 0 | 1 | 0 | 19 | 20 | · | 🟦 5x | 25 | management/config/property change — slightly expensive |
| `C_RepurposeMerge` | SETUP | 0 | 0 | 1 | 0 | 19 | 20 | · | 🟦 5x | 25 | management/config/property change — slightly expensive |
| `C_Slumber` | SETUP | 0 | 0 | 1 | 0 | 19 | 20 | · | 🟦 5x | 25 | management/config/property change — slightly expensive |
| `C_RepurposeSlumber` | SETUP | 0 | 0 | 1 | 0 | 19 | 20 | · | 🟦 5x | 25 | management/config/property change — slightly expensive |
| `C_Unvest` | SETUP | 0 | 0 | 1 | 0 | 18 | 19 | · | 🟦 5x | 24 | management/config/property change — slightly expensive |
| `C_Brumate` | USAGE | 0 | 0 | 1 | 0 | 18 | 19 | · | 🟩 1x | 20 | legit activity — pure compute, no deterrent |
| `C_Vest` | SETUP | 0 | 0 | 1 | 0 | 11 | 12 | · | 🟦 5x | 17 | management/config/property change — slightly expensive |
| `C_Sleep` | SETUP | 0 | 0 | 1 | 0 | 11 | 12 | · | 🟦 5x | 17 | management/config/property change — slightly expensive |
| `C_Awake` | SETUP | 0 | 0 | 1 | 0 | 11 | 12 | · | 🟦 5x | 17 | management/config/property change — slightly expensive |
| `C_RepurposeVested` | SETUP | 0 | 0 | 1 | 0 | 10 | 11 | · | 🟦 5x | 16 | management/config/property change — slightly expensive |
| `C_RepurposeSleeping` | SETUP | 0 | 0 | 1 | 0 | 10 | 11 | · | 🟦 5x | 16 | management/config/property change — slightly expensive |
| `C_RepurposeHibernating` | SETUP | 0 | 0 | 1 | 0 | 10 | 11 | · | 🟦 5x | 16 | management/config/property change — slightly expensive |
| `C_Constrict` | USAGE | 0 | 0 | 1 | 0 | 14 | 15 | · | 🟩 1x | 16 | legit activity — pure compute, no deterrent |
| `C_Unsleep` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_RepurposeFrozen` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |
| `C_RepurposeReserved` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |
| `C_Hibernate` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |
| `C_Freeze` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟦 5x | 12 | management/config/property change — slightly expensive |
| `C_Reserve` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟦 5x | 12 | management/config/property change — slightly expensive |
| `C_Unreserve` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟦 5x | 12 | management/config/property change — slightly expensive |
| `C_ToggleTransferRoleFrozenDPTF` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | · | 🟩 1x | 4 | legit activity — pure compute, no deterrent |
| `C_ToggleTransferRoleReservedDPTF` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | · | 🟩 1x | 4 | legit activity — pure compute, no deterrent |
| `C_ToggleTransferRoleSleepingDPOF` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | · | 🟩 1x | 4 | legit activity — pure compute, no deterrent |
| `C_ToggleTransferRoleHibernatingDPOF` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | · | 🟩 1x | 4 | legit activity — pure compute, no deterrent |

## 12_LIQUID.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_UnwrapUrStoa` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_UnwrapStoa` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |
| `A_MigrateLiquidFunds` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_WrapUrStoa` | USAGE | 0 | 0 | 2 | 0 | 7 | 9 | · | 🟩 1x | 10 | legit activity — pure compute, no deterrent |
| `C_WrapStoa` | USAGE | 0 | 0 | 1 | 0 | 7 | 8 | · | 🟩 1x | 9 | legit activity — pure compute, no deterrent |

## 13_OUROBOROS.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Fuel` | USAGE | 0 | 0 | 1 | 0 | 10 | 11 | · | 🟩 1x | 12 | legit activity — pure compute, no deterrent |
| `C_WithdrawFees` | USAGE | 0 | 0 | 1 | 0 | 7 | 8 | · | 🟩 1x | 9 | legit activity — pure compute, no deterrent |
| `C_Compress` | USAGE | 0 | 0 | 1 | 0 | 14 | 15 | · | ⬜ exempt | 0 | IGNIS-EXEMPT — makes/breaks ignis |
| `C_Sublimate` | SETUP | 0 | 0 | 1 | 0 | 15 | 16 | · | ⬜ exempt | 0 | IGNIS-EXEMPT — makes/breaks ignis |
| `C_SublimateV2` | SETUP | 0 | 0 | 1 | 0 | 17 | 18 | · | ⬜ exempt | 0 | IGNIS-EXEMPT — makes/breaks ignis |

## 15_SWP.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_DefinePrimordialPool` | ISSUE | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟧 50x | 53 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_ToggleFeeLock` | SETUP | 0 | 2 | 4 | 0 | 7 | 13 | · | 🟨 25x | 38 | economic-parameter change (fee/price/rate) |
| `C_UpdateFee` | SETUP | 0 | 2 | 2 | 0 | 2 | 6 | · | 🟨 25x | 31 | economic-parameter change (fee/price/rate) |
| `C_UpdateSpecialFeeTargets` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟨 25x | 30 | economic-parameter change (fee/price/rate) |
| `C_ToggleAddOrSwap` | USAGE | 0 | 2 | 5 | 0 | 15 | 22 | · | 🟩 1x | 23 | legit activity — pure compute, no deterrent |
| `A_RotatePrincipal` | SETUP | 0 | 1 | 2 | 0 | 3 | 6 | · | 🟪 10x | 16 | role/authority/guard setup |
| `A_ToggleAsymetricLiquidityAddition` | USAGE | 0 | 1 | 1 | 0 | 12 | 14 | · | 🟩 1x | 15 | legit activity — pure compute, no deterrent |
| `C_ChangeOwnership` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟪 10x | 15 | role/authority/guard setup |
| `C_EnableFrozenLP` | SETUP | 0 | 1 | 3 | 0 | 6 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_EnableSleepingLP` | SETUP | 0 | 1 | 3 | 0 | 6 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_ModifyCanChangeOwner` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟪 10x | 15 | role/authority/guard setup |
| `A_UpdatePrincipal` | SETUP | 0 | 3 | 2 | 0 | 4 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |
| `C_UpgradeBranding` | SETUP | 0 | 0 | 2 | 0 | 4 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_UpdatePendingBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_ModifyWeights` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_UpdateAmplifier` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `A_UpdateLimit` | SETUP | 0 | 2 | 1 | 0 | 1 | 4 | · | 🟦 5x | 9 | management/config/property change — slightly expensive |
| `A_UpdateLiquidBoost` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |

## 16_SWPI.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 1 | 0 | 1 | 0 | 18 | 22 | · | 🟧 50x | 72 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `A_RebuildGraph` | SETUP | 1 | 0 | 1 | 0 | 20 | 24 | · | 🟦 5x | 29 | management/config/property change — slightly expensive |

## 18_SWPLC.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_RemoveLiquidity` | USAGE | 0 | 0 | 1 | 0 | 13 | 14 | · | ⬛ 1000x | 1014 | LP add/remove churn — very big deterrent |
| `C_UpdatePendingBrandingLPs` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_UpgradeBrandingLPs` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |
| `C_Fuel` | USAGE | 0 | 0 | 1 | 0 | 10 | 11 | · | 🟩 1x | 12 | legit activity — pure compute, no deterrent |
| `C_ToggleAddLiquidity` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | · | 🟩 1x | 4 | legit activity — pure compute, no deterrent |

## 19_SWPU.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_SmartSwap` | USAGE | 0 | 0 | 1 | 0 | 82 | 83 | · | 🟩 1x | 84 | legit activity — pure compute, no deterrent |
| `CC_SmartSwap` | USAGE | 0 | 0 | 1 | 0 | 58 | 59 | · | 🟩 1x | 60 | legit activity — pure compute, no deterrent |
| `C_Swap` | USAGE | 0 | 0 | 1 | 0 | 52 | 53 | · | 🟩 1x | 54 | legit activity — pure compute, no deterrent |
| `C_ToggleSwapCapability` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | · | 🟩 1x | 4 | legit activity — pure compute, no deterrent |

## 20_MTX-SWP.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_AddSleepingLiquidity` | USAGE | 0 | 0 | 1 | 0 | 32 | 33 | · | ⬛ 1000x | 1033 | LP add/remove churn — very big deterrent |
| `C_AddFrozenLiquidity` | USAGE | 0 | 0 | 1 | 0 | 28 | 29 | · | ⬛ 1000x | 1029 | LP add/remove churn — very big deterrent |
| `C_AddStandardLiquidity` | USAGE | 0 | 0 | 1 | 0 | 25 | 26 | · | ⬛ 1000x | 1026 | LP add/remove churn — very big deterrent |
| `C_AddIcedLiquidity` | USAGE | 0 | 0 | 1 | 0 | 25 | 26 | · | ⬛ 1000x | 1026 | LP add/remove churn — very big deterrent |
| `C_AddGlacialLiquidity` | USAGE | 0 | 0 | 1 | 0 | 25 | 26 | · | ⬛ 1000x | 1026 | LP add/remove churn — very big deterrent |
| `C_IssueStablePool` | ISSUE | 1 | 0 | 1 | 0 | 21 | 25 | · | 🟧 50x | 75 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueWeightedPool` | ISSUE | 1 | 0 | 1 | 0 | 21 | 25 | · | 🟧 50x | 75 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueStandardPool` | ISSUE | 1 | 0 | 1 | 0 | 21 | 25 | · | 🟧 50x | 75 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |

## 21_CODEX.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_RegisterStoicTag` | SETUP | 2 | 2 | 3 | 0 | 1 | 12 | · | 🟦 5x | 17 | management/config/property change — slightly expensive |
| `C_RotateCodexGuard` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟪 10x | 13 | role/authority/guard setup |
| `A_RegisterCodexIdentity` | SETUP | 1 | 0 | 1 | 0 | 1 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_RecordArweaveUpload` | SETUP | 1 | 0 | 1 | 0 | 1 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_ReleaseStoicTag` | SETUP | 0 | 2 | 2 | 0 | 1 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |

## 22_PYTHIA.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_DeployApolloPythiaApiKey` | ISSUE | 1 | 0 | 1 | 0 | 1 | 5 | · | 🟧 50x | 55 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `A_UpdateDeployPrice` | SETUP | 1 | 0 | 2 | 0 | 1 | 6 | · | 🟨 25x | 31 | economic-parameter change (fee/price/rate) |
| `A_UpdateRenamePrice` | SETUP | 1 | 0 | 2 | 0 | 1 | 6 | · | 🟨 25x | 31 | economic-parameter change (fee/price/rate) |
| `A_Flush` | USAGE | 2 | 3 | 4 | 1 | 1 | 15 | · | 🟩 1x | 16 | legit activity — pure compute, no deterrent |
| `A_LinkDualApiKey` | SETUP | 1 | 2 | 2 | 0 | 2 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |
| `A_RevokeDualLink` | SETUP | 1 | 1 | 1 | 0 | 1 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_LinkDualApiKey` | SETUP | 1 | 1 | 1 | 0 | 1 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_RevokeDualLink` | SETUP | 1 | 1 | 1 | 0 | 1 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_UpdateDualConsumerLane` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |

## 02_DPDC.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_UpdatePendingBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_UpgradeBranding` | SETUP | 0 | 0 | 2 | 0 | 3 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |

## 03_DPDC-C.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_CreateNewNonce` | ISSUE | 0 | 0 | 2 | 0 | 23 | 25 | · | 🟧 50x | 75 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateNewNonces` | ISSUE | 0 | 0 | 2 | 0 | 23 | 25 | · | 🟧 50x | 75 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |

## 04_DPDC-I.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_IssueDigitalCollection` | ISSUE | 0 | 0 | 1 | 0 | 23 | 24 | · | 🟧 50x | 74 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |

## 05_DPDC-R.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_MoveCreateRole` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | · | 🟪 10x | 20 | role/authority/guard setup |
| `C_MoveRecreateRole` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | · | 🟪 10x | 20 | role/authority/guard setup |
| `C_MoveSetUriRole` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | · | 🟪 10x | 20 | role/authority/guard setup |
| `C_ToggleAddQuantityRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟪 10x | 17 | role/authority/guard setup |
| `C_ToggleExemptionRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟪 10x | 17 | role/authority/guard setup |
| `C_ToggleBurnRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟪 10x | 17 | role/authority/guard setup |
| `C_ToggleUpdateRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟪 10x | 17 | role/authority/guard setup |
| `C_ToggleModifyCreatorRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟪 10x | 17 | role/authority/guard setup |
| `C_ToggleModifyRoyaltiesRole` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟪 10x | 17 | role/authority/guard setup |
| `C_ToggleFreezeAccount` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟦 5x | 12 | management/config/property change — slightly expensive |
| `C_ToggleTransferRole` | USAGE | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟩 1x | 8 | legit activity — pure compute, no deterrent |

## 06_DPDC-MNG.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_WipeClean` | SETUP | 0 | 0 | 1 | 2 | 17 | 20 | · | 🟦 5x | 25 | management/config/property change — slightly expensive |
| `C_WipeHeavy` | SETUP | 0 | 0 | 1 | 2 | 16 | 19 | · | 🟦 5x | 24 | management/config/property change — slightly expensive |
| `C_WipePure` | SETUP | 0 | 0 | 1 | 2 | 16 | 19 | · | 🟦 5x | 24 | management/config/property change — slightly expensive |
| `C_WipeDirty` | SETUP | 0 | 0 | 1 | 2 | 16 | 19 | · | 🟦 5x | 24 | management/config/property change — slightly expensive |
| `C_WipeNonce` | SETUP | 0 | 0 | 1 | 0 | 12 | 13 | · | 🟦 5x | 18 | management/config/property change — slightly expensive |
| `C_Control` | SETUP | 0 | 0 | 1 | 0 | 7 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |
| `C_BurnSFT` | SETUP | 0 | 0 | 1 | 0 | 7 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |
| `C_WipeSlim` | SETUP | 0 | 0 | 1 | 0 | 7 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |
| `C_AddQuantity` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟦 5x | 12 | management/config/property change — slightly expensive |
| `C_BurnNFT` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟦 5x | 12 | management/config/property change — slightly expensive |
| `C_TogglePause` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_RespawnNFT` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |

## 07_DPDC-T.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Transfer` | USAGE | 0 | 0 | 1 | 0 | 27 | 28 | · | 🟩 1x | 29 | legit activity — pure compute, no deterrent |
| `C_BulkTransfer` | USAGE | 0 | 0 | 1 | 0 | 27 | 28 | · | 🟩 1x | 29 | legit activity — pure compute, no deterrent |
| `C_RepurposeCollectable` | USAGE | 0 | 0 | 1 | 0 | 18 | 19 | · | 🟩 1x | 20 | legit activity — pure compute, no deterrent |
| `C_IgnisRoyaltyCollector` | USAGE | 0 | 0 | 1 | 0 | 12 | 13 | · | 🟩 1x | 14 | legit activity — pure compute, no deterrent |

## 08_DPDC-S.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_DefineHybridSet` | ISSUE | 2 | 0 | 1 | 0 | 13 | 20 | · | 🟧 50x | 70 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_DefinePrimordialSet` | ISSUE | 2 | 0 | 1 | 0 | 12 | 19 | · | 🟧 50x | 69 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_DefineCompositeSet` | ISSUE | 2 | 0 | 1 | 0 | 12 | 19 | · | 🟧 50x | 69 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_MakeNonFungibleSet` | ISSUE | 0 | 0 | 3 | 0 | 10 | 13 | · | 🟧 50x | 63 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_MakeSemiFungibleSet` | ISSUE | 0 | 0 | 3 | 0 | 4 | 7 | · | 🟧 50x | 57 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_BreakSemiFungibleSet` | SETUP | 0 | 0 | 3 | 0 | 11 | 14 | · | 🟦 5x | 19 | management/config/property change — slightly expensive |
| `C_BreakNonFungibleSet` | SETUP | 0 | 0 | 1 | 0 | 9 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_EnableSetClassFragmentation` | SETUP | 0 | 4 | 1 | 0 | 3 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |
| `C_ToggleSet` | SETUP | 0 | 2 | 1 | 0 | 3 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_RenameSet` | SETUP | 0 | 2 | 1 | 0 | 3 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |

## 09_DPDC-F.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_MakeFragments` | ISSUE | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟧 50x | 59 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_RepurposeCollectableFragments` | USAGE | 0 | 0 | 1 | 0 | 18 | 19 | · | 🟩 1x | 20 | legit activity — pure compute, no deterrent |
| `C_MergeFragments` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |
| `C_EnableNonceFragmentation` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟦 5x | 12 | management/config/property change — slightly expensive |

## 10_DPDC-N.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_UpdateNonceScore` | SETUP | 0 | 0 | 3 | 0 | 8 | 11 | · | 🟦 5x | 16 | management/config/property change — slightly expensive |
| `C_UpdateNonceMetaData` | SETUP | 0 | 0 | 3 | 0 | 8 | 11 | · | 🟦 5x | 16 | management/config/property change — slightly expensive |
| `C_UpdateNonceRoyalty` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_UpdateNonceIgnisRoyalty` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_UpdateNonceName` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_UpdateNonceDescription` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_UpdateNonceURI` | SETUP | 0 | 0 | 2 | 0 | 8 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_UpdateNonces` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |

## 11_EQUITY+.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_IssueShareholderCollection` | ISSUE | 0 | 0 | 1 | 0 | 43 | 44 | · | 🟧 50x | 94 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_MorphPackageShares` | SETUP | 0 | 0 | 1 | 0 | 18 | 19 | · | 🟦 5x | 24 | management/config/property change — slightly expensive |

## 00_Demipad.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Deposit` | USAGE | 0 | 10 | 9 | 0 | 35 | 54 | · | 🟩 1x | 55 | legit activity — pure compute, no deterrent |
| `A_DefinePrice` | ISSUE | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟧 50x | 53 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_Withdraw` | USAGE | 0 | 3 | 4 | 0 | 5 | 12 | · | 🟩 1x | 13 | legit activity — pure compute, no deterrent |
| `C_TransmitSemiFungibles` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟦 5x | 12 | management/config/property change — slightly expensive |
| `C_TransmitNonFungibles` | SETUP | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟦 5x | 12 | management/config/property change — slightly expensive |
| `A_RegisterAssetToLaunchpad` | SETUP | 1 | 0 | 1 | 0 | 1 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_TransmitTrueFungible` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_TransmitOrtoFungible` | SETUP | 0 | 0 | 1 | 0 | 4 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `A_ToggleOpenForBusiness` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |
| `A_ToggleRetrieval` | SETUP | 0 | 1 | 1 | 0 | 1 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |

## 01_ANK.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_IssueTrueFungibleAnchor` | ISSUE | 4 | 0 | 4 | 0 | 7 | 23 | · | 🟧 50x | 73 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueSemiFungibleAnchor` | ISSUE | 4 | 0 | 4 | 0 | 7 | 23 | · | 🟧 50x | 73 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueNonFungibleAnchor` | ISSUE | 4 | 0 | 4 | 0 | 7 | 23 | · | 🟧 50x | 73 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueNonFungibleSetAnchor` | ISSUE | 4 | 0 | 4 | 0 | 7 | 23 | · | 🟧 50x | 73 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_RevokeAnchor` | SETUP | 2 | 1 | 6 | 0 | 6 | 19 | · | 🟦 5x | 24 | management/config/property change — slightly expensive |
| `C_RevokeBoostClass` | SETUP | 0 | 1 | 1 | 0 | 2 | 4 | · | 🟦 5x | 9 | management/config/property change — slightly expensive |

## 02_SCORE.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_IssueLiquidityScore` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1000 | ⬛ 1000x | 1010 | issuance — honor current flat GAS| (1000) |
| `C_IssueTrueFungibleScore` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1000 | ⬛ 1000x | 1010 | issuance — honor current flat GAS| (1000) |
| `C_IssueOrtoFungibleScore` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1000 | ⬛ 1000x | 1010 | issuance — honor current flat GAS| (1000) |
| `C_IssueSemiFungibleScore` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1000 | ⬛ 1000x | 1010 | issuance — honor current flat GAS| (1000) |
| `C_IssueNonFungibleScore` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1000 | ⬛ 1000x | 1010 | issuance — honor current flat GAS| (1000) |
| `C_IssueScoreFromModel` | ISSUE | 4 | 1 | 6 | 0 | 4 | 23 | 500 | 🟥 500x | 523 | issuance — honor current flat GAS| (500) |
| `C_IssueTriplet` | ISSUE | 1 | 1 | 4 | 0 | 2 | 10 | 500 | 🟥 500x | 510 | issuance — honor current flat GAS| (500) |
| `C_IssueSingleScoreModel` | ISSUE | 1 | 0 | 1 | 0 | 3 | 7 | 500 | 🟥 500x | 507 | issuance — honor current flat GAS| (500) |
| `C_IssueNonFungibleScoreDefinition` | ISSUE | 4 | 0 | 7 | 0 | 3 | 22 | · | 🟧 50x | 72 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueNonFungibleSetScoreDefinition` | ISSUE | 4 | 0 | 7 | 0 | 3 | 22 | · | 🟧 50x | 72 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueSemiFungibleScoreDefinition` | ISSUE | 2 | 0 | 3 | 0 | 3 | 12 | · | 🟧 50x | 62 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateBoostClassLink` | ISSUE | 0 | 1 | 3 | 0 | 3 | 7 | · | 🟧 50x | 57 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateBoostLink` | ISSUE | 0 | 1 | 2 | 0 | 1 | 4 | · | 🟧 50x | 54 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_RotateOwnership` | SETUP | 0 | 1 | 2 | 0 | 1 | 4 | · | 🟪 10x | 14 | role/authority/guard setup |
| `C_CombineTripletScoreModel` | SETUP | 1 | 0 | 1 | 0 | 3 | 7 | 500 | 🟦 5x | 12 | management/config/property change — slightly expensive |
| `C_Control` | SETUP | 0 | 1 | 2 | 0 | 1 | 4 | · | 🟦 5x | 9 | management/config/property change — slightly expensive |
| `C_EnableDebBoost` | SETUP | 0 | 1 | 2 | 0 | 1 | 4 | · | 🟦 5x | 9 | management/config/property change — slightly expensive |

## 03_AQP.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 1 | 0 | 1 | 0 | 5 | 9 | 1000 | ⬛ 1000x | 1009 | issuance — honor current flat GAS| (1000) |
| `C_SyncCollectableAnchors` | USAGE | 2 | 0 | 3 | 3 | 7 | 19 | 50 | 🟩 1x | 20 | legit activity — pure compute, no deterrent |
| `C_RevokeScore` | SETUP | 0 | 1 | 8 | 0 | 5 | 14 | 500 | 🟦 5x | 19 | management/config/property change — slightly expensive |
| `C_AddScore` | SETUP | 0 | 1 | 8 | 0 | 3 | 12 | 500 | 🟦 5x | 17 | management/config/property change — slightly expensive |
| `C_SyncTrueFungibleAnchors` | SETUP | 0 | 1 | 2 | 0 | 6 | 9 | 50 | 🟦 5x | 14 | management/config/property change — slightly expensive |
| `C_DisablePoolStake` | USAGE | 0 | 1 | 1 | 0 | 2 | 4 | 500 | 🟩 1x | 5 | legit activity — pure compute, no deterrent |
| `C_EnablePoolStake` | USAGE | 0 | 1 | 1 | 0 | 2 | 4 | 500 | 🟩 1x | 5 | legit activity — pure compute, no deterrent |

## 05_FVT.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 1 | 0 | 1 | 0 | 6 | 10 | 1000 | ⬛ 1000x | 1010 | issuance — honor current flat GAS| (1000) |
| `C_IssueMultipletFamily` | ISSUE | 0 | 0 | 1 | 0 | 4 | 5 | 500 | 🟥 500x | 505 | issuance — honor current flat GAS| (500) |
| `CC_Collect` | USAGE | 0 | 0 | 1 | 0 | 28 | 29 | · | 🟩 1x | 30 | legit activity — pure compute, no deterrent |
| `C_AddScoreEntity` | SETUP | 0 | 0 | 1 | 0 | 19 | 20 | 500 | 🟦 5x | 25 | management/config/property change — slightly expensive |
| `CC_TrueFungibleStakeFlow` | USAGE | 0 | 0 | 1 | 0 | 19 | 20 | · | 🟩 1x | 21 | legit activity — pure compute, no deterrent |
| `CC_CollectableStakeFlow` | USAGE | 0 | 0 | 1 | 0 | 19 | 20 | · | 🟩 1x | 21 | legit activity — pure compute, no deterrent |
| `CC_SweepRevokeAnchor` | USAGE | 0 | 0 | 1 | 0 | 14 | 15 | · | 🟩 1x | 16 | legit activity — pure compute, no deterrent |
| `CC_SweepBegin` | USAGE | 2 | 0 | 2 | 0 | 7 | 15 | · | 🟩 1x | 16 | legit activity — pure compute, no deterrent |
| `CCp_SweepRecomputeChunk` | USAGE | 2 | 0 | 2 | 0 | 6 | 14 | · | 🟩 1x | 15 | legit activity — pure compute, no deterrent |
| `CC_OrtoFungibleStakeFlow` | USAGE | 0 | 0 | 1 | 0 | 13 | 14 | · | 🟩 1x | 15 | legit activity — pure compute, no deterrent |
| `C_RotateOwnership` | SETUP | 0 | 0 | 1 | 0 | 3 | 4 | · | 🟪 10x | 14 | role/authority/guard setup |
| `CCp_UnstaleAll` | USAGE | 0 | 0 | 1 | 0 | 11 | 12 | · | 🟩 1x | 13 | legit activity — pure compute, no deterrent |
| `CC_Inject` | USAGE | 0 | 0 | 1 | 0 | 10 | 11 | · | 🟩 1x | 12 | legit activity — pure compute, no deterrent |
| `C_SetCommonDenominator` | SETUP | 0 | 1 | 1 | 0 | 4 | 6 | 500 | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_SetMosaic` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 500 | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_SetSplitMode` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 500 | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_ToggleScoreEntityLink` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 500 | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_AddRewardLink` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_ToggleRewardLink` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 500 | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_SetQualitySplit` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | 500 | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_Control` | SETUP | 0 | 1 | 1 | 0 | 3 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `CCp_InjectFixChunk` | USAGE | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟩 1x | 8 | legit activity — pure compute, no deterrent |
| `CC_UnstaleMyScores` | USAGE | 0 | 0 | 1 | 0 | 5 | 6 | 500 | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `CC_InjectFinalize` | USAGE | 0 | 0 | 1 | 1 | 3 | 5 | · | 🟩 1x | 6 | legit activity — pure compute, no deterrent |
| `CC_InjectStream` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | · | 🟩 1x | 4 | legit activity — pure compute, no deterrent |

## 06_VCT.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `CC_FullVacate` | USAGE | 0 | 0 | 1 | 0 | 48 | 49 | · | 🟩 1x | 50 | legit activity — pure compute, no deterrent |
| `CCp_BatchVacateTrueFungible` | USAGE | 0 | 0 | 1 | 0 | 32 | 33 | · | 🟩 1x | 34 | legit activity — pure compute, no deterrent |
| `CCp_BatchVacateCollectables` | USAGE | 0 | 0 | 1 | 0 | 31 | 32 | · | 🟩 1x | 33 | legit activity — pure compute, no deterrent |
| `CCp_BatchVacateOrtoFungible` | USAGE | 0 | 0 | 1 | 0 | 29 | 30 | · | 🟩 1x | 31 | legit activity — pure compute, no deterrent |
| `CCp_BatchDrainTrueFungible` | USAGE | 0 | 0 | 1 | 0 | 21 | 22 | · | 🟩 1x | 23 | legit activity — pure compute, no deterrent |
| `CCp_BatchDrainCollectable` | USAGE | 0 | 0 | 1 | 0 | 20 | 21 | · | 🟩 1x | 22 | legit activity — pure compute, no deterrent |
| `CCp_BatchDrainOrtoFungible` | USAGE | 0 | 0 | 1 | 0 | 18 | 19 | · | 🟩 1x | 20 | legit activity — pure compute, no deterrent |
| `C_FinalizeVacate` | USAGE | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟩 1x | 10 | legit activity — pure compute, no deterrent |
| `C_AbortVacate` | USAGE | 0 | 0 | 1 | 0 | 6 | 7 | · | 🟩 1x | 8 | legit activity — pure compute, no deterrent |

## 07_MTX-AQP.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_2|SweepRevokeAnchor` | USAGE | 0 | 0 | 1 | 0 | 10 | 11 | · | 🟩 1x | 12 | legit activity — pure compute, no deterrent |
| `C_2|Inject` | USAGE | 0 | 0 | 1 | 0 | 5 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |

## 08_DSA.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_DefineDelegationVault` | ISSUE | 1 | 0 | 1 | 0 | 2 | 6 | 500 | 🟥 500x | 506 | issuance — honor current flat GAS| (500) |
| `A_SetAgencyFee` | SETUP | 0 | 1 | 2 | 0 | 2 | 5 | 300 | 🟨 25x | 30 | economic-parameter change (fee/price/rate) |
| `A_OracleWrite` | SETUP | 0 | 1 | 3 | 0 | 8 | 12 | 200 | 🟪 10x | 22 | role/authority/guard setup |
| `A_SetOracleAuth` | SETUP | 1 | 0 | 1 | 0 | 3 | 7 | 300 | 🟪 10x | 17 | role/authority/guard setup |
| `C_AdmitAgency` | SETUP | 1 | 0 | 1 | 0 | 2 | 6 | 500 | 🟪 10x | 16 | role/authority/guard setup |
| `C_RecomputeCapture` | SETUP | 0 | 0 | 3 | 0 | 8 | 11 | 300 | 🟦 5x | 16 | management/config/property change — slightly expensive |
| `A_ToggleExternalOracle` | SETUP | 0 | 0 | 0 | 0 | 0 | 0 | · | 🟪 10x | 10 | role/authority/guard setup |
| `A_SetOracleValidity` | SETUP | 0 | 0 | 0 | 0 | 0 | 0 | · | 🟪 10x | 10 | role/authority/guard setup |
| `A_BurnRoyalty` | SETUP | 0 | 0 | 1 | 0 | 2 | 3 | 400 | 🟦 5x | 8 | management/config/property change — slightly expensive |
| `A_WithdrawRoyalty` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 400 | 🟩 1x | 4 | legit activity — pure compute, no deterrent |
| `A_FuelRoyalty` | USAGE | 0 | 0 | 1 | 0 | 2 | 3 | 500 | 🟩 1x | 4 | legit activity — pure compute, no deterrent |

## 05_TS02-DPAD.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_DefinePrice` | ISSUE | 0 | 0 | 0 | 0 | 1 | 1 | · | 🟧 50x | 51 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `A_RegisterAssetToLaunchpad` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_ToggleOpenForBusiness` | SETUP | 0 | 0 | 0 | 0 | 1 | 1 | · | 🟦 5x | 6 | management/config/property change — slightly expensive |
| `A_ToggleRetrieval` | SETUP | 0 | 0 | 0 | 0 | 1 | 1 | · | 🟦 5x | 6 | management/config/property change — slightly expensive |

## 01_AOZ+.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_RegisterPrimalTrueFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_RegisterPrimalOrtoFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_RegisterAutostakePair` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_RegisterTrueFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_RegisterOrtoFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_RegisterSemiFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_RegisterNonFungible` | SETUP | 1 | 1 | 2 | 0 | 0 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_SetupKosonicATS` | SETUP | 0 | 0 | 1 | 0 | 5 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_InitialiseCounters` | SETUP | 1 | 0 | 0 | 0 | 0 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |

## 01_BSD-L.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_Issue` | ISSUE | 0 | 0 | 0 | 0 | 1 | 1 | · | 🟧 50x | 51 | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `A_Legendary` | SETUP | 0 | 0 | 0 | 0 | 8 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |

## 02_BSD-E.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_Epic` | SETUP | 0 | 0 | 0 | 0 | 8 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |

## 03_BSD-R.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_Rare` | SETUP | 0 | 0 | 0 | 0 | 8 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |

## 04_BSD-C.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_Common` | SETUP | 0 | 0 | 0 | 0 | 8 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |

## 01_NOSFERATU.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_Step01` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step02` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step03` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step04` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step05` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step06` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step07` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step08` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step09` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step10` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step11` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step12` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step13` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step14` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step15` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step16` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step17` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step18` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step19` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step20` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step21` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step22` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_Spawn` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Fix01` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix02a` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix02b` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix03` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix04` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix05a` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix05b` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix06` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix07` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix08` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix09` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix10` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix11` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix12` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix13` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix14` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix15` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix16` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix17` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix18` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix19` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix20` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix21` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `A_Fix22` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |
| `C_Fix` | USAGE | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟩 1x | 7 | legit activity — pure compute, no deterrent |

## 02_KBunnies.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_BunnyRGBSet` | SETUP | 0 | 0 | 0 | 0 | 10 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `A_Step01` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step02` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step03` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step04` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step05` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step06` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step07` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step08` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step09` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step10` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step11` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step12` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step13` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step14` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step15` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `A_Step16` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |
| `C_Spawn` | SETUP | 0 | 0 | 0 | 0 | 6 | 6 | · | 🟦 5x | 11 | management/config/property change — slightly expensive |

## 04_AQP-BOOT.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Step3_CreateBoosterAnchorClasses` | SETUP | 0 | 0 | 0 | 0 | 25 | 25 | · | 🟦 5x | 30 | management/config/property change — slightly expensive |
| `C_Step7_CreatePoolsAndScores` | SETUP | 0 | 0 | 0 | 0 | 19 | 19 | · | 🟦 5x | 24 | management/config/property change — slightly expensive |
| `C_Step5_CreateSubsidiaryScores` | SETUP | 0 | 0 | 0 | 0 | 15 | 15 | · | 🟦 5x | 20 | management/config/property change — slightly expensive |
| `C_Step2_CreateSnakePowerAnchorClasses` | SETUP | 0 | 0 | 0 | 0 | 11 | 11 | · | 🟦 5x | 16 | management/config/property change — slightly expensive |
| `C_Step6_CreateOuroLpTriplet` | SETUP | 0 | 0 | 0 | 0 | 11 | 11 | · | 🟦 5x | 16 | management/config/property change — slightly expensive |
| `C_Step8_IssueFvtEntities` | SETUP | 0 | 0 | 0 | 0 | 10 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |
| `C_Step0_WireImcAndGovernor` | SETUP | 0 | 0 | 0 | 0 | 9 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |
| `C_Step4_CreateCoreScores` | SETUP | 0 | 0 | 0 | 0 | 8 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |
| `C_Step12_AddFvtRewardLinks` | SETUP | 0 | 0 | 0 | 0 | 5 | 5 | · | 🟦 5x | 10 | management/config/property change — slightly expensive |
| `C_Step9_AddFvtScoreEntities` | SETUP | 0 | 0 | 0 | 0 | 4 | 4 | · | 🟦 5x | 9 | management/config/property change — slightly expensive |
| `C_Step11_WireFarmTriplet` | SETUP | 0 | 0 | 0 | 0 | 3 | 3 | · | 🟦 5x | 8 | management/config/property change — slightly expensive |
| `C_Step10_IssueMultipletFamily` | SETUP | 0 | 0 | 0 | 0 | 1 | 1 | · | 🟦 5x | 6 | management/config/property change — slightly expensive |
| `C_Step1_CreateBunnySet` | SETUP | 0 | 0 | 0 | 0 | 0 | 0 | · | 🟦 5x | 5 | management/config/property change — slightly expensive |

## 01_Spark.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_RedemAllSparks` | SETUP | 0 | 0 | 1 | 0 | 13 | 14 | · | 🟦 5x | 19 | management/config/property change — slightly expensive |
| `C_CustomRedemAllSparks` | SETUP | 0 | 0 | 1 | 0 | 12 | 13 | · | 🟦 5x | 18 | management/config/property change — slightly expensive |
| `C_RedemFewSparks` | SETUP | 0 | 0 | 1 | 0 | 12 | 13 | · | 🟦 5x | 18 | management/config/property change — slightly expensive |
| `C_CustomRedemFewSparks` | SETUP | 0 | 0 | 1 | 0 | 11 | 12 | · | 🟦 5x | 17 | management/config/property change — slightly expensive |
| `C_BuySparks` | SETUP | 0 | 0 | 1 | 0 | 7 | 8 | · | 🟦 5x | 13 | management/config/property change — slightly expensive |

## 02_Snakes.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_UpdateSharePrice` | SETUP | 0 | 0 | 1 | 0 | 1 | 2 | · | 🟨 25x | 27 | economic-parameter change (fee/price/rate) |
| `C_Acquire` | SETUP | 0 | 0 | 1 | 0 | 15 | 16 | · | 🟦 5x | 21 | management/config/property change — slightly expensive |

## 03_Custodians.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_UpdateQuintessencePrice` | SETUP | 0 | 0 | 1 | 0 | 1 | 2 | · | 🟨 25x | 27 | economic-parameter change (fee/price/rate) |
| `C_Acquire` | SETUP | 0 | 0 | 1 | 0 | 14 | 15 | · | 🟦 5x | 20 | management/config/property change — slightly expensive |

## 04_STOICPAY.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_BuyStoicPay` | SETUP | 0 | 0 | 1 | 0 | 8 | 9 | · | 🟦 5x | 14 | management/config/property change — slightly expensive |

## 05_STOAICO.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_Stake` | USAGE | 1 | 8 | 12 | 0 | 2 | 25 | · | 🟩 1x | 26 | legit activity — pure compute, no deterrent |
| `Ap_FlushUncollectedSlice` | USAGE | 0 | 6 | 11 | 0 | 4 | 21 | · | 🟩 1x | 22 | legit activity — pure compute, no deterrent |
| `AA_FlushUncollected` | USAGE | 0 | 6 | 10 | 1 | 4 | 21 | · | 🟩 1x | 22 | legit activity — pure compute, no deterrent |
| `C_Collect` | USAGE | 0 | 6 | 10 | 0 | 4 | 20 | · | 🟩 1x | 21 | legit activity — pure compute, no deterrent |
| `A_Unstake` | USAGE | 0 | 7 | 10 | 0 | 2 | 19 | · | 🟩 1x | 20 | legit activity — pure compute, no deterrent |
| `A_Inject` | USAGE | 0 | 5 | 8 | 0 | 2 | 15 | · | 🟩 1x | 16 | legit activity — pure compute, no deterrent |
| `A_InitialiseDistributionVault` | SETUP | 1 | 0 | 0 | 0 | 7 | 10 | · | 🟦 5x | 15 | management/config/property change — slightly expensive |

## 03_DSP+.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_KosonMinterStageOne` | SETUP | 0 | 0 | 0 | 0 | 37 | 37 | · | 🟦 5x | 42 | management/config/property change — slightly expensive |
| `A_KosonMinterStageOne_1of3` | SETUP | 0 | 0 | 0 | 0 | 18 | 18 | · | 🟦 5x | 23 | management/config/property change — slightly expensive |
| `A_OuroMinterStageOne` | SETUP | 0 | 0 | 0 | 0 | 17 | 17 | · | 🟦 5x | 22 | management/config/property change — slightly expensive |
| `A_KosonMinterStageOne_2of3` | SETUP | 0 | 0 | 0 | 0 | 15 | 15 | · | 🟦 5x | 20 | management/config/property change — slightly expensive |
| `A_KosonMinterStageOne_3of3` | SETUP | 0 | 0 | 0 | 0 | 15 | 15 | · | 🟦 5x | 20 | management/config/property change — slightly expensive |
| `A_StoicismMinter` | SETUP | 0 | 0 | 0 | 0 | 2 | 2 | · | 🟦 5x | 7 | management/config/property change — slightly expensive |

---
## Colour legend / suggested-deter tier distribution

Deter is a multiplier on IG|TX: `25x` = 25·IG|TX added on top of the compute components.
Each colour square below tags every op of that tier in the tables above.

| colour | deter | ops | meaning |
|--------|------:|----:|---------|
| ⬜ | exempt | 8 | IGNIS-exempt (account creation + ignis machinery: collect/compress/sublimate/firestarter) |
| 🟩 | 1x | 103 | activity — no deterrent |
| 🟦 | 5x | 241 | config/property change |
| 🟪 | 10x | 32 | role/authority/guard setup |
| 🟨 | 25x | 21 | fee/price/rate change |
| 🟧 | 50x | 40 | token/collection issuance (+STOA) |
| 🟥 | 500x | 5 | issuance (current flat) |
| ⬛ | 1000x | 13 | issuance / LP — very big |

463 ops · 352 pre-suggested deter>1 (rest default 1). Revise & green-light.

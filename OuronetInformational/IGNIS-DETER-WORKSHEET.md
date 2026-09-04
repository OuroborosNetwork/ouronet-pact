# IGNIS deterrence worksheet (#76) — SUGGESTED, for owner revision

FINAL = deter·IG|TX(1) + [ 3·(insert/write) + 1·update + 1·read + 1·scan + 1·xcall ] (module-internal transitive; approx —
cross-module callee internals not summed, so delegating ops read low).
deter default 1 (no extra). Revise the `deter` column; I green-light nothing myself.

COLUMN COLOURS — each cost part has its own square (shown only when non-zero, so an op's real
cost-drivers light up at a glance):  🟥 ins/wr (×3)  ·  🟧 upd (×1)  ·  🟦 reads (×1)  ·
🟪 scans (×1)  ·  🟫 xcalls (×1)  ·  🟨 cur GAS| (current flat).  **components** & **final** are bold sums.
The `deter` column uses the tier palette (see the colour legend at the bottom).

S1 CONSTRAINT — auto account-creation inside a transfer (recipient has no account yet) is
IGNIS-FREE: it is subsumed in the transfer (deter 1), never billed as a separate op. Only the
explicit C_DeployAccount entrypoint (deliberate token-account creation) carries an IGNIS deterrent.


## 01_DALOS.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_UpdateUsagePrice` | SETUP | 🟥1 | · | 🟦1 | · | 🟫2 | **6** | · | 🟨 25x | **31** | economic-parameter change (fee/price/rate) |
| `A_SetIgnisSourcePrice` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟨 25x | **28** | economic-parameter change (fee/price/rate) |
| `C_RotateStoa` | SETUP | 🟥2 | 🟧1 | 🟦3 | · | 🟫3 | **13** | · | 🟪 10x | **23** | role/authority/guard setup |
| `C_RotateGuard` | SETUP | · | 🟧2 | 🟦2 | · | 🟫1 | **5** | · | 🟪 10x | **15** | role/authority/guard setup |
| `C_RotateGovernor` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟪 10x | **13** | role/authority/guard setup |
| `C_RotateSovereign` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟪 10x | **13** | role/authority/guard setup |
| `A_MigrateLiquidFunds` | SETUP | · | · | 🟦1 | · | 🟫4 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `A_ToggleOAPU` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟦 5x | **8** | management/config/property change — slightly expensive |
| `A_ToggleGAP` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟦 5x | **8** | management/config/property change — slightly expensive |
| `A_UpdatePublicKey` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟦 5x | **8** | management/config/property change — slightly expensive |
| `C_ControlSmartAccount` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟦 5x | **8** | management/config/property change — slightly expensive |
| `A_ToggleGasCollection` | USAGE | · | 🟧2 | 🟦1 | · | 🟫1 | **4** | · | 🟩 1x | **5** | legit activity — pure compute, no deterrent |
| `A_SetAutoFueling` | USAGE | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟩 1x | **4** | legit activity — pure compute, no deterrent |
| `A_DeploySmartAccount` | ISSUE | 🟥3 | · | 🟦1 | · | 🟫2 | **12** | · | ⬜ exempt | **0** | IGNIS-EXEMPT — admin account deploy: fully FREE (no STOA, no IGNIS) |
| `A_DeployStandardAccount` | ISSUE | 🟥3 | · | 🟦1 | · | 🟫2 | **12** | · | ⬜ exempt | **0** | IGNIS-EXEMPT — admin account deploy: fully FREE (no STOA, no IGNIS) |
| `C_DeploySmartAccount` | ISSUE | 🟥3 | · | 🟦2 | · | 🟫3 | **14** | · | ⬜ exempt | **0** | IGNIS-EXEMPT — user account deploy: STOA-priced, no IGNIS finish cost |
| `C_DeployStandardAccount` | ISSUE | 🟥3 | · | 🟦2 | · | 🟫3 | **14** | · | ⬜ exempt | **0** | IGNIS-EXEMPT — user account deploy: STOA-priced, no IGNIS finish cost |

## 02_IGNIS.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_TransferDalosFuel` | USAGE | · | · | · | · | 🟫1 | **1** | · | 🟩 1x | **2** | legit activity — pure compute, no deterrent |
| `C_Collect` | USAGE | · | · | 🟦2 | · | 🟫24 | **26** | · | ⬜ exempt | **0** | IGNIS-EXEMPT — the ignis collector itself |

## 04_BRD.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_Live` | SETUP | · | 🟧2 | 🟦3 | · | 🟫1 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `A_SetFlag` | SETUP | · | 🟧2 | 🟦3 | · | 🟫1 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |

## 05_DPTF.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Mint` | ISSUE | 🟥2 | 🟧3 | 🟦9 | · | 🟫13 | **31** | · | 🟧 50x | **81** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_Issue` | ISSUE | 🟥3 | · | 🟦3 | · | 🟫14 | **26** | · | 🟧 50x | **76** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_DeployAccount` | ISSUE | 🟥1 | · | 🟦3 | · | 🟫3 | **9** | · | 🟧 50x | **59** | explicit token-account creation — IGNIS deterrent vs on-purpose spam (auto-creation inside a transfer is FREE) |
| `C_ToggleFeeExemptionRole` | SETUP | 🟥1 | 🟧2 | 🟦6 | · | 🟫9 | **20** | · | 🟨 25x | **45** | economic-parameter change (fee/price/rate) |
| `A_WipeTreasuryDebt` | SETUP | 🟥2 | 🟧3 | 🟦9 | · | 🟫16 | **34** | · | 🟦 5x | **39** | management/config/property change — slightly expensive |
| `A_WipeTreasuryDebtPartial` | SETUP | 🟥2 | 🟧3 | 🟦9 | · | 🟫15 | **33** | · | 🟦 5x | **38** | management/config/property change — slightly expensive |
| `C_ToggleFeeLock` | SETUP | · | 🟧2 | 🟦4 | · | 🟫7 | **13** | · | 🟨 25x | **38** | economic-parameter change (fee/price/rate) |
| `C_ToggleFee` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟨 25x | **30** | economic-parameter change (fee/price/rate) |
| `C_SetFee` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟨 25x | **30** | economic-parameter change (fee/price/rate) |
| `C_SetFeeTarget` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟨 25x | **30** | economic-parameter change (fee/price/rate) |
| `C_ToggleBurnRole` | SETUP | 🟥1 | 🟧2 | 🟦6 | · | 🟫9 | **20** | · | 🟪 10x | **30** | role/authority/guard setup |
| `C_ToggleMintRole` | SETUP | 🟥1 | 🟧2 | 🟦6 | · | 🟫9 | **20** | · | 🟪 10x | **30** | role/authority/guard setup |
| `C_Burn` | SETUP | 🟥1 | 🟧2 | 🟦7 | · | 🟫11 | **23** | · | 🟦 5x | **28** | management/config/property change — slightly expensive |
| `C_WipeSlim` | SETUP | 🟥1 | 🟧2 | 🟦8 | · | 🟫9 | **22** | · | 🟦 5x | **27** | management/config/property change — slightly expensive |
| `C_Wipe` | SETUP | 🟥1 | 🟧2 | 🟦8 | · | 🟫9 | **22** | · | 🟦 5x | **27** | management/config/property change — slightly expensive |
| `C_ToggleFreezeAccount` | SETUP | 🟥1 | 🟧2 | 🟦6 | · | 🟫9 | **20** | · | 🟦 5x | **25** | management/config/property change — slightly expensive |
| `C_ToggleTransferRole` | USAGE | 🟥1 | 🟧2 | 🟦6 | · | 🟫9 | **20** | · | 🟩 1x | **21** | legit activity — pure compute, no deterrent |
| `C_RotateOwnership` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟪 10x | **15** | role/authority/guard setup |
| `C_UpgradeBranding` | SETUP | · | · | 🟦4 | · | 🟫4 | **8** | · | 🟦 5x | **13** | management/config/property change — slightly expensive |
| `C_UpdatePendingBranding` | SETUP | · | · | 🟦2 | · | 🟫3 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_Control` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_TogglePause` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_ToggleReservation` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_SetMinMove` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `A_UpdateTreasury` | SETUP | · | · | 🟦1 | · | 🟫2 | **3** | · | 🟦 5x | **8** | management/config/property change — slightly expensive |

## 06_DPOF.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 🟥3 | · | 🟦4 | · | 🟫13 | **26** | · | 🟧 50x | **76** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_Mint` | ISSUE | 🟥2 | 🟧4 | 🟦11 | · | 🟫4 | **25** | · | 🟧 50x | **75** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_DeployAccount` | ISSUE | 🟥1 | · | 🟦4 | · | 🟫2 | **9** | · | 🟧 50x | **59** | explicit token-account creation — IGNIS deterrent vs on-purpose spam (auto-creation inside a transfer is FREE) |
| `C_Transmit` | SETUP | 🟥2 | 🟧5 | 🟦13 | · | 🟫7 | **31** | · | 🟦 5x | **36** | management/config/property change — slightly expensive |
| `C_AddQuantity` | SETUP | 🟥2 | 🟧4 | 🟦11 | · | 🟫3 | **24** | · | 🟦 5x | **29** | management/config/property change — slightly expensive |
| `C_ToggleAddQuantityRole` | SETUP | 🟥1 | 🟧2 | 🟦7 | · | 🟫4 | **16** | · | 🟪 10x | **26** | role/authority/guard setup |
| `C_ToggleBurnRole` | SETUP | 🟥1 | 🟧2 | 🟦7 | · | 🟫4 | **16** | · | 🟪 10x | **26** | role/authority/guard setup |
| `C_MoveCreateRole` | SETUP | 🟥1 | 🟧3 | 🟦6 | · | 🟫3 | **15** | · | 🟪 10x | **25** | role/authority/guard setup |
| `C_WipeHeavy` | SETUP | · | 🟧5 | 🟦7 | 🟪3 | 🟫5 | **20** | · | 🟦 5x | **25** | management/config/property change — slightly expensive |
| `C_WipePure` | SETUP | · | 🟧5 | 🟦7 | 🟪3 | 🟫5 | **20** | · | 🟦 5x | **25** | management/config/property change — slightly expensive |
| `C_WipeClean` | SETUP | · | 🟧5 | 🟦7 | 🟪3 | 🟫5 | **20** | · | 🟦 5x | **25** | management/config/property change — slightly expensive |
| `C_ToggleFreezeAccount` | SETUP | 🟥1 | 🟧2 | 🟦7 | · | 🟫4 | **16** | · | 🟦 5x | **21** | management/config/property change — slightly expensive |
| `C_Transfer` | USAGE | 🟥1 | 🟧2 | 🟦8 | · | 🟫7 | **20** | · | 🟩 1x | **21** | legit activity — pure compute, no deterrent |
| `C_BulkTransfer` | USAGE | 🟥1 | 🟧2 | 🟦8 | · | 🟫7 | **20** | · | 🟩 1x | **21** | legit activity — pure compute, no deterrent |
| `C_Burn` | SETUP | · | 🟧5 | 🟦7 | · | 🟫2 | **14** | · | 🟦 5x | **19** | management/config/property change — slightly expensive |
| `C_WipeSlim` | SETUP | · | 🟧5 | 🟦7 | · | 🟫2 | **14** | · | 🟦 5x | **19** | management/config/property change — slightly expensive |
| `C_ToggleTransferRole` | USAGE | 🟥1 | 🟧2 | 🟦7 | · | 🟫4 | **16** | · | 🟩 1x | **17** | legit activity — pure compute, no deterrent |
| `C_UpgradeBranding` | SETUP | · | · | 🟦5 | · | 🟫5 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_RotateOwnership` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟪 10x | **15** | role/authority/guard setup |
| `C_UpdatePendingBranding` | SETUP | · | · | 🟦2 | · | 🟫3 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_Control` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_TogglePause` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |

## 08_ATS.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫18 | **22** | · | 🟧 50x | **72** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_SetColdRecoveryFees` | SETUP | · | 🟧1 | 🟦1 | · | 🟫6 | **8** | · | 🟨 25x | **33** | economic-parameter change (fee/price/rate) |
| `C_SetHibernationFees` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟨 25x | **30** | economic-parameter change (fee/price/rate) |
| `C_ControlColdRecoveryFees` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟨 25x | **30** | economic-parameter change (fee/price/rate) |
| `C_ControlHotRecoveryFee` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟨 25x | **30** | economic-parameter change (fee/price/rate) |
| `C_SetHotRecoveryFees` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟨 25x | **30** | economic-parameter change (fee/price/rate) |
| `C_SetDirectRecoveryFee` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟨 25x | **30** | economic-parameter change (fee/price/rate) |
| `C_AddHotRBT` | SETUP | · | 🟧1 | 🟦1 | · | 🟫12 | **14** | · | 🟦 5x | **19** | management/config/property change — slightly expensive |
| `C_ToggleParameterLock` | SETUP | · | 🟧2 | 🟦3 | · | 🟫7 | **12** | · | 🟦 5x | **17** | management/config/property change — slightly expensive |
| `C_AddSecondary` | SETUP | · | 🟧1 | 🟦2 | · | 🟫9 | **12** | · | 🟦 5x | **17** | management/config/property change — slightly expensive |
| `C_RotateOwnership` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟪 10x | **15** | role/authority/guard setup |
| `C_SetColdRecoveryDuration` | SETUP | · | 🟧2 | 🟦2 | · | 🟫4 | **8** | · | 🟦 5x | **13** | management/config/property change — slightly expensive |
| `C_UpgradeBranding` | SETUP | · | · | 🟦2 | · | 🟫4 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_UpdatePendingBranding` | SETUP | · | · | 🟦2 | · | 🟫3 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_Control` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_UpdateRoyalty` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_ToggleElite` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_ToggleUpgrade` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_SwitchColdRecovery` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_SwitchHotRecovery` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_SwitchDirectRecovery` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_UpdateSyphon` | USAGE | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟩 1x | **6** | legit activity — pure compute, no deterrent |

## 09_TFT.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_MultiBulkTransfer` | USAGE | · | · | 🟦1 | · | 🟫71 | **72** | · | 🟩 1x | **73** | legit activity — pure compute, no deterrent |
| `C_MultiTransfer` | USAGE | · | · | 🟦1 | · | 🟫69 | **70** | · | 🟩 1x | **71** | legit activity — pure compute, no deterrent |
| `C_Transfer` | USAGE | · | · | 🟦1 | · | 🟫68 | **69** | · | 🟩 1x | **70** | legit activity — pure compute, no deterrent |
| `C_Transmute` | SETUP | · | · | 🟦1 | · | 🟫50 | **51** | · | 🟦 5x | **56** | management/config/property change — slightly expensive |
| `C_ClearDispo` | SETUP | · | · | 🟦1 | · | 🟫25 | **26** | · | 🟦 5x | **31** | management/config/property change — slightly expensive |

## 10_ATSU.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Cull` | SETUP | · | · | 🟦1 | · | 🟫62 | **63** | · | 🟦 5x | **68** | management/config/property change — slightly expensive |
| `C_ColdRecovery` | SETUP | · | · | 🟦1 | · | 🟫61 | **62** | · | 🟦 5x | **67** | management/config/property change — slightly expensive |
| `A_RemoveSecondary` | SETUP | · | · | 🟦1 | · | 🟫20 | **21** | · | 🟦 5x | **26** | management/config/property change — slightly expensive |
| `C_RemoveSecondary` | SETUP | · | · | 🟦1 | · | 🟫20 | **21** | · | 🟦 5x | **26** | management/config/property change — slightly expensive |
| `C_Redeem` | SETUP | · | · | 🟦1 | · | 🟫20 | **21** | · | 🟦 5x | **26** | management/config/property change — slightly expensive |
| `C_DirectRecovery` | SETUP | · | · | 🟦1 | · | 🟫13 | **14** | · | 🟦 5x | **19** | management/config/property change — slightly expensive |
| `C_HotRecovery` | SETUP | · | · | 🟦1 | · | 🟫12 | **13** | · | 🟦 5x | **18** | management/config/property change — slightly expensive |
| `A_KickStart` | SETUP | · | · | 🟦1 | · | 🟫11 | **12** | · | 🟦 5x | **17** | management/config/property change — slightly expensive |
| `C_Recover` | SETUP | · | · | 🟦1 | · | 🟫9 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_Curl` | USAGE | · | · | 🟦1 | · | 🟫12 | **13** | · | 🟩 1x | **14** | legit activity — pure compute, no deterrent |
| `C_Coil` | USAGE | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟩 1x | **10** | legit activity — pure compute, no deterrent |
| `C_Syphon` | USAGE | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟩 1x | **8** | legit activity — pure compute, no deterrent |
| `C_WithdrawRoyalties` | USAGE | · | · | 🟦1 | · | 🟫5 | **6** | · | 🟩 1x | **7** | legit activity — pure compute, no deterrent |
| `C_KickStart` | SETUP | · | · | 🟦1 | · | 🟫1 | **2** | · | 🟦 5x | **7** | management/config/property change — slightly expensive |
| `C_Fuel` | USAGE | · | · | 🟦1 | · | 🟫3 | **4** | · | 🟩 1x | **5** | legit activity — pure compute, no deterrent |

## 11_VST.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_CreateFrozenLink` | ISSUE | · | · | 🟦1 | · | 🟫14 | **15** | · | 🟧 50x | **65** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateReservationLink` | ISSUE | · | · | 🟦1 | · | 🟫14 | **15** | · | 🟧 50x | **65** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateVestingLink` | ISSUE | · | · | 🟦1 | · | 🟫14 | **15** | · | 🟧 50x | **65** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateSleepingLink` | ISSUE | · | · | 🟦1 | · | 🟫14 | **15** | · | 🟧 50x | **65** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateHibernatingLink` | ISSUE | · | · | 🟦1 | · | 🟫14 | **15** | · | 🟧 50x | **65** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_Merge` | SETUP | · | · | 🟦1 | · | 🟫19 | **20** | · | 🟦 5x | **25** | management/config/property change — slightly expensive |
| `C_RepurposeMerge` | SETUP | · | · | 🟦1 | · | 🟫19 | **20** | · | 🟦 5x | **25** | management/config/property change — slightly expensive |
| `C_Slumber` | SETUP | · | · | 🟦1 | · | 🟫19 | **20** | · | 🟦 5x | **25** | management/config/property change — slightly expensive |
| `C_RepurposeSlumber` | SETUP | · | · | 🟦1 | · | 🟫19 | **20** | · | 🟦 5x | **25** | management/config/property change — slightly expensive |
| `C_Unvest` | SETUP | · | · | 🟦1 | · | 🟫18 | **19** | · | 🟦 5x | **24** | management/config/property change — slightly expensive |
| `C_Brumate` | USAGE | · | · | 🟦1 | · | 🟫18 | **19** | · | 🟩 1x | **20** | legit activity — pure compute, no deterrent |
| `C_Vest` | SETUP | · | · | 🟦1 | · | 🟫11 | **12** | · | 🟦 5x | **17** | management/config/property change — slightly expensive |
| `C_Sleep` | SETUP | · | · | 🟦1 | · | 🟫11 | **12** | · | 🟦 5x | **17** | management/config/property change — slightly expensive |
| `C_Awake` | SETUP | · | · | 🟦1 | · | 🟫11 | **12** | · | 🟦 5x | **17** | management/config/property change — slightly expensive |
| `C_RepurposeVested` | SETUP | · | · | 🟦1 | · | 🟫10 | **11** | · | 🟦 5x | **16** | management/config/property change — slightly expensive |
| `C_RepurposeSleeping` | SETUP | · | · | 🟦1 | · | 🟫10 | **11** | · | 🟦 5x | **16** | management/config/property change — slightly expensive |
| `C_RepurposeHibernating` | SETUP | · | · | 🟦1 | · | 🟫10 | **11** | · | 🟦 5x | **16** | management/config/property change — slightly expensive |
| `C_Constrict` | USAGE | · | · | 🟦1 | · | 🟫14 | **15** | · | 🟩 1x | **16** | legit activity — pure compute, no deterrent |
| `C_Unsleep` | SETUP | · | · | 🟦1 | · | 🟫9 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_RepurposeFrozen` | SETUP | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟦 5x | **14** | management/config/property change — slightly expensive |
| `C_RepurposeReserved` | SETUP | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟦 5x | **14** | management/config/property change — slightly expensive |
| `C_Hibernate` | SETUP | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟦 5x | **14** | management/config/property change — slightly expensive |
| `C_Freeze` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟦 5x | **12** | management/config/property change — slightly expensive |
| `C_Reserve` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟦 5x | **12** | management/config/property change — slightly expensive |
| `C_Unreserve` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟦 5x | **12** | management/config/property change — slightly expensive |
| `C_ToggleTransferRoleFrozenDPTF` | USAGE | · | · | 🟦1 | · | 🟫2 | **3** | · | 🟩 1x | **4** | legit activity — pure compute, no deterrent |
| `C_ToggleTransferRoleReservedDPTF` | USAGE | · | · | 🟦1 | · | 🟫2 | **3** | · | 🟩 1x | **4** | legit activity — pure compute, no deterrent |
| `C_ToggleTransferRoleSleepingDPOF` | USAGE | · | · | 🟦1 | · | 🟫2 | **3** | · | 🟩 1x | **4** | legit activity — pure compute, no deterrent |
| `C_ToggleTransferRoleHibernatingDPOF` | USAGE | · | · | 🟦1 | · | 🟫2 | **3** | · | 🟩 1x | **4** | legit activity — pure compute, no deterrent |

## 12_LIQUID.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_UnwrapUrStoa` | SETUP | · | · | 🟦2 | · | 🟫8 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_UnwrapStoa` | SETUP | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟦 5x | **14** | management/config/property change — slightly expensive |
| `A_MigrateLiquidFunds` | SETUP | · | · | 🟦1 | · | 🟫4 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_WrapUrStoa` | USAGE | · | · | 🟦2 | · | 🟫7 | **9** | · | 🟩 1x | **10** | legit activity — pure compute, no deterrent |
| `C_WrapStoa` | USAGE | · | · | 🟦1 | · | 🟫7 | **8** | · | 🟩 1x | **9** | legit activity — pure compute, no deterrent |

## 13_OUROBOROS.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Fuel` | USAGE | · | · | 🟦1 | · | 🟫10 | **11** | · | 🟩 1x | **12** | legit activity — pure compute, no deterrent |
| `C_WithdrawFees` | USAGE | · | · | 🟦1 | · | 🟫7 | **8** | · | 🟩 1x | **9** | legit activity — pure compute, no deterrent |
| `C_Compress` | USAGE | · | · | 🟦1 | · | 🟫14 | **15** | · | ⬜ exempt | **0** | IGNIS-EXEMPT — makes/breaks ignis |
| `C_Sublimate` | SETUP | · | · | 🟦1 | · | 🟫15 | **16** | · | ⬜ exempt | **0** | IGNIS-EXEMPT — makes/breaks ignis |
| `C_SublimateV2` | SETUP | · | · | 🟦1 | · | 🟫17 | **18** | · | ⬜ exempt | **0** | IGNIS-EXEMPT — makes/breaks ignis |

## 15_SWP.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_DefinePrimordialPool` | ISSUE | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟧 50x | **53** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_ToggleFeeLock` | SETUP | · | 🟧2 | 🟦4 | · | 🟫7 | **13** | · | 🟨 25x | **38** | economic-parameter change (fee/price/rate) |
| `C_UpdateFee` | SETUP | · | 🟧2 | 🟦2 | · | 🟫2 | **6** | · | 🟨 25x | **31** | economic-parameter change (fee/price/rate) |
| `C_UpdateSpecialFeeTargets` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟨 25x | **30** | economic-parameter change (fee/price/rate) |
| `C_ToggleAddOrSwap` | USAGE | · | 🟧2 | 🟦5 | · | 🟫15 | **22** | · | 🟩 1x | **23** | legit activity — pure compute, no deterrent |
| `A_RotatePrincipal` | SETUP | · | 🟧1 | 🟦2 | · | 🟫3 | **6** | · | 🟪 10x | **16** | role/authority/guard setup |
| `A_ToggleAsymetricLiquidityAddition` | USAGE | · | 🟧1 | 🟦1 | · | 🟫12 | **14** | · | 🟩 1x | **15** | legit activity — pure compute, no deterrent |
| `C_ChangeOwnership` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟪 10x | **15** | role/authority/guard setup |
| `C_EnableFrozenLP` | SETUP | · | 🟧1 | 🟦3 | · | 🟫6 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_EnableSleepingLP` | SETUP | · | 🟧1 | 🟦3 | · | 🟫6 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_ModifyCanChangeOwner` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟪 10x | **15** | role/authority/guard setup |
| `A_UpdatePrincipal` | SETUP | · | 🟧3 | 🟦2 | · | 🟫4 | **9** | · | 🟦 5x | **14** | management/config/property change — slightly expensive |
| `C_UpgradeBranding` | SETUP | · | · | 🟦2 | · | 🟫4 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_UpdatePendingBranding` | SETUP | · | · | 🟦2 | · | 🟫3 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_ModifyWeights` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_UpdateAmplifier` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `A_UpdateLimit` | SETUP | · | 🟧2 | 🟦1 | · | 🟫1 | **4** | · | 🟦 5x | **9** | management/config/property change — slightly expensive |
| `A_UpdateLiquidBoost` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟦 5x | **8** | management/config/property change — slightly expensive |

## 16_SWPI.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫18 | **22** | · | 🟧 50x | **72** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `A_RebuildGraph` | SETUP | 🟥1 | · | 🟦1 | · | 🟫20 | **24** | · | 🟦 5x | **29** | management/config/property change — slightly expensive |

## 18_SWPLC.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_RemoveLiquidity` | USAGE | · | · | 🟦1 | · | 🟫13 | **14** | · | ⬛ 1000x | **1014** | LP add/remove churn — very big deterrent |
| `C_UpdatePendingBrandingLPs` | SETUP | · | · | 🟦1 | · | 🟫9 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_UpgradeBrandingLPs` | SETUP | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟦 5x | **14** | management/config/property change — slightly expensive |
| `C_Fuel` | USAGE | · | · | 🟦1 | · | 🟫10 | **11** | · | 🟩 1x | **12** | legit activity — pure compute, no deterrent |
| `C_ToggleAddLiquidity` | USAGE | · | · | 🟦1 | · | 🟫2 | **3** | · | 🟩 1x | **4** | legit activity — pure compute, no deterrent |

## 19_SWPU.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_SmartSwap` | USAGE | · | · | 🟦1 | · | 🟫82 | **83** | · | 🟩 1x | **84** | legit activity — pure compute, no deterrent |
| `CC_SmartSwap` | USAGE | · | · | 🟦1 | · | 🟫58 | **59** | · | 🟩 1x | **60** | legit activity — pure compute, no deterrent |
| `C_Swap` | USAGE | · | · | 🟦1 | · | 🟫52 | **53** | · | 🟩 1x | **54** | legit activity — pure compute, no deterrent |
| `C_ToggleSwapCapability` | USAGE | · | · | 🟦1 | · | 🟫2 | **3** | · | 🟩 1x | **4** | legit activity — pure compute, no deterrent |

## 20_MTX-SWP.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_AddSleepingLiquidity` | USAGE | · | · | 🟦1 | · | 🟫32 | **33** | · | ⬛ 1000x | **1033** | LP add/remove churn — very big deterrent |
| `C_AddFrozenLiquidity` | USAGE | · | · | 🟦1 | · | 🟫28 | **29** | · | ⬛ 1000x | **1029** | LP add/remove churn — very big deterrent |
| `C_AddStandardLiquidity` | USAGE | · | · | 🟦1 | · | 🟫25 | **26** | · | ⬛ 1000x | **1026** | LP add/remove churn — very big deterrent |
| `C_AddIcedLiquidity` | USAGE | · | · | 🟦1 | · | 🟫25 | **26** | · | ⬛ 1000x | **1026** | LP add/remove churn — very big deterrent |
| `C_AddGlacialLiquidity` | USAGE | · | · | 🟦1 | · | 🟫25 | **26** | · | ⬛ 1000x | **1026** | LP add/remove churn — very big deterrent |
| `C_IssueStablePool` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫21 | **25** | · | 🟧 50x | **75** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueWeightedPool` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫21 | **25** | · | 🟧 50x | **75** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueStandardPool` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫21 | **25** | · | 🟧 50x | **75** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |

## 21_CODEX.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_RegisterStoicTag` | SETUP | 🟥2 | 🟧2 | 🟦3 | · | 🟫1 | **12** | · | 🟦 5x | **17** | management/config/property change — slightly expensive |
| `C_RotateCodexGuard` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟪 10x | **13** | role/authority/guard setup |
| `A_RegisterCodexIdentity` | SETUP | 🟥1 | · | 🟦1 | · | 🟫1 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_RecordArweaveUpload` | SETUP | 🟥1 | · | 🟦1 | · | 🟫1 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_ReleaseStoicTag` | SETUP | · | 🟧2 | 🟦2 | · | 🟫1 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |

## 22_PYTHIA.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_DeployApolloPythiaApiKey` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫1 | **5** | · | 🟧 50x | **55** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `A_UpdateDeployPrice` | SETUP | 🟥1 | · | 🟦2 | · | 🟫1 | **6** | · | 🟨 25x | **31** | economic-parameter change (fee/price/rate) |
| `A_UpdateRenamePrice` | SETUP | 🟥1 | · | 🟦2 | · | 🟫1 | **6** | · | 🟨 25x | **31** | economic-parameter change (fee/price/rate) |
| `A_Flush` | USAGE | 🟥2 | 🟧3 | 🟦4 | 🟪1 | 🟫1 | **15** | · | 🟩 1x | **16** | legit activity — pure compute, no deterrent |
| `A_LinkDualApiKey` | SETUP | 🟥1 | 🟧2 | 🟦2 | · | 🟫2 | **9** | · | 🟦 5x | **14** | management/config/property change — slightly expensive |
| `A_RevokeDualLink` | SETUP | 🟥1 | 🟧1 | 🟦1 | · | 🟫1 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_LinkDualApiKey` | SETUP | 🟥1 | 🟧1 | 🟦1 | · | 🟫1 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_RevokeDualLink` | SETUP | 🟥1 | 🟧1 | 🟦1 | · | 🟫1 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_UpdateDualConsumerLane` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟦 5x | **8** | management/config/property change — slightly expensive |

## 02_DPDC.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_UpdatePendingBranding` | SETUP | · | · | 🟦2 | · | 🟫3 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_UpgradeBranding` | SETUP | · | · | 🟦2 | · | 🟫3 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |

## 03_DPDC-C.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_CreateNewNonce` | ISSUE | · | · | 🟦2 | · | 🟫23 | **25** | · | 🟧 50x | **75** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateNewNonces` | ISSUE | · | · | 🟦2 | · | 🟫23 | **25** | · | 🟧 50x | **75** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |

## 04_DPDC-I.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_IssueDigitalCollection` | ISSUE | · | · | 🟦1 | · | 🟫23 | **24** | · | 🟧 50x | **74** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |

## 05_DPDC-R.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_MoveCreateRole` | SETUP | · | · | 🟦1 | · | 🟫9 | **10** | · | 🟪 10x | **20** | role/authority/guard setup |
| `C_MoveRecreateRole` | SETUP | · | · | 🟦1 | · | 🟫9 | **10** | · | 🟪 10x | **20** | role/authority/guard setup |
| `C_MoveSetUriRole` | SETUP | · | · | 🟦1 | · | 🟫9 | **10** | · | 🟪 10x | **20** | role/authority/guard setup |
| `C_ToggleAddQuantityRole` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟪 10x | **17** | role/authority/guard setup |
| `C_ToggleExemptionRole` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟪 10x | **17** | role/authority/guard setup |
| `C_ToggleBurnRole` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟪 10x | **17** | role/authority/guard setup |
| `C_ToggleUpdateRole` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟪 10x | **17** | role/authority/guard setup |
| `C_ToggleModifyCreatorRole` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟪 10x | **17** | role/authority/guard setup |
| `C_ToggleModifyRoyaltiesRole` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟪 10x | **17** | role/authority/guard setup |
| `C_ToggleFreezeAccount` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟦 5x | **12** | management/config/property change — slightly expensive |
| `C_ToggleTransferRole` | USAGE | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟩 1x | **8** | legit activity — pure compute, no deterrent |

## 06_DPDC-MNG.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_WipeClean` | SETUP | · | · | 🟦1 | 🟪2 | 🟫17 | **20** | · | 🟦 5x | **25** | management/config/property change — slightly expensive |
| `C_WipeHeavy` | SETUP | · | · | 🟦1 | 🟪2 | 🟫16 | **19** | · | 🟦 5x | **24** | management/config/property change — slightly expensive |
| `C_WipePure` | SETUP | · | · | 🟦1 | 🟪2 | 🟫16 | **19** | · | 🟦 5x | **24** | management/config/property change — slightly expensive |
| `C_WipeDirty` | SETUP | · | · | 🟦1 | 🟪2 | 🟫16 | **19** | · | 🟦 5x | **24** | management/config/property change — slightly expensive |
| `C_WipeNonce` | SETUP | · | · | 🟦1 | · | 🟫12 | **13** | · | 🟦 5x | **18** | management/config/property change — slightly expensive |
| `C_Control` | SETUP | · | · | 🟦1 | · | 🟫7 | **8** | · | 🟦 5x | **13** | management/config/property change — slightly expensive |
| `C_BurnSFT` | SETUP | · | · | 🟦1 | · | 🟫7 | **8** | · | 🟦 5x | **13** | management/config/property change — slightly expensive |
| `C_WipeSlim` | SETUP | · | · | 🟦1 | · | 🟫7 | **8** | · | 🟦 5x | **13** | management/config/property change — slightly expensive |
| `C_AddQuantity` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟦 5x | **12** | management/config/property change — slightly expensive |
| `C_BurnNFT` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟦 5x | **12** | management/config/property change — slightly expensive |
| `C_TogglePause` | SETUP | · | · | 🟦1 | · | 🟫4 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_RespawnNFT` | SETUP | · | · | 🟦1 | · | 🟫4 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |

## 07_DPDC-T.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Transfer` | USAGE | · | · | 🟦1 | · | 🟫27 | **28** | · | 🟩 1x | **29** | legit activity — pure compute, no deterrent |
| `C_BulkTransfer` | USAGE | · | · | 🟦1 | · | 🟫27 | **28** | · | 🟩 1x | **29** | legit activity — pure compute, no deterrent |
| `C_RepurposeCollectable` | USAGE | · | · | 🟦1 | · | 🟫18 | **19** | · | 🟩 1x | **20** | legit activity — pure compute, no deterrent |
| `C_IgnisRoyaltyCollector` | USAGE | · | · | 🟦1 | · | 🟫12 | **13** | · | 🟩 1x | **14** | legit activity — pure compute, no deterrent |

## 08_DPDC-S.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_DefineHybridSet` | ISSUE | 🟥2 | · | 🟦1 | · | 🟫13 | **20** | · | 🟧 50x | **70** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_DefinePrimordialSet` | ISSUE | 🟥2 | · | 🟦1 | · | 🟫12 | **19** | · | 🟧 50x | **69** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_DefineCompositeSet` | ISSUE | 🟥2 | · | 🟦1 | · | 🟫12 | **19** | · | 🟧 50x | **69** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_MakeNonFungibleSet` | ISSUE | · | · | 🟦3 | · | 🟫10 | **13** | · | 🟧 50x | **63** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_MakeSemiFungibleSet` | ISSUE | · | · | 🟦3 | · | 🟫4 | **7** | · | 🟧 50x | **57** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_BreakSemiFungibleSet` | SETUP | · | · | 🟦3 | · | 🟫11 | **14** | · | 🟦 5x | **19** | management/config/property change — slightly expensive |
| `C_BreakNonFungibleSet` | SETUP | · | · | 🟦1 | · | 🟫9 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_EnableSetClassFragmentation` | SETUP | · | 🟧4 | 🟦1 | · | 🟫3 | **8** | · | 🟦 5x | **13** | management/config/property change — slightly expensive |
| `C_ToggleSet` | SETUP | · | 🟧2 | 🟦1 | · | 🟫3 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_RenameSet` | SETUP | · | 🟧2 | 🟦1 | · | 🟫3 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |

## 09_DPDC-F.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_MakeFragments` | ISSUE | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟧 50x | **59** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_RepurposeCollectableFragments` | USAGE | · | · | 🟦1 | · | 🟫18 | **19** | · | 🟩 1x | **20** | legit activity — pure compute, no deterrent |
| `C_MergeFragments` | SETUP | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟦 5x | **14** | management/config/property change — slightly expensive |
| `C_EnableNonceFragmentation` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟦 5x | **12** | management/config/property change — slightly expensive |

## 10_DPDC-N.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_UpdateNonceScore` | SETUP | · | · | 🟦3 | · | 🟫8 | **11** | · | 🟦 5x | **16** | management/config/property change — slightly expensive |
| `C_UpdateNonceMetaData` | SETUP | · | · | 🟦3 | · | 🟫8 | **11** | · | 🟦 5x | **16** | management/config/property change — slightly expensive |
| `C_UpdateNonceRoyalty` | SETUP | · | · | 🟦2 | · | 🟫8 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_UpdateNonceIgnisRoyalty` | SETUP | · | · | 🟦2 | · | 🟫8 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_UpdateNonceName` | SETUP | · | · | 🟦2 | · | 🟫8 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_UpdateNonceDescription` | SETUP | · | · | 🟦2 | · | 🟫8 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_UpdateNonceURI` | SETUP | · | · | 🟦2 | · | 🟫8 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |
| `C_UpdateNonces` | SETUP | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟦 5x | **14** | management/config/property change — slightly expensive |

## 11_EQUITY+.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_IssueShareholderCollection` | ISSUE | · | · | 🟦1 | · | 🟫43 | **44** | · | 🟧 50x | **94** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_MorphPackageShares` | SETUP | · | · | 🟦1 | · | 🟫18 | **19** | · | 🟦 5x | **24** | management/config/property change — slightly expensive |

## 00_Demipad.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Deposit` | USAGE | · | 🟧10 | 🟦9 | · | 🟫35 | **54** | · | 🟩 1x | **55** | legit activity — pure compute, no deterrent |
| `A_DefinePrice` | ISSUE | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟧 50x | **53** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_Withdraw` | USAGE | · | 🟧3 | 🟦4 | · | 🟫5 | **12** | · | 🟩 1x | **13** | legit activity — pure compute, no deterrent |
| `C_TransmitSemiFungibles` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟦 5x | **12** | management/config/property change — slightly expensive |
| `C_TransmitNonFungibles` | SETUP | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟦 5x | **12** | management/config/property change — slightly expensive |
| `A_RegisterAssetToLaunchpad` | SETUP | 🟥1 | · | 🟦1 | · | 🟫1 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_TransmitTrueFungible` | SETUP | · | · | 🟦1 | · | 🟫4 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `C_TransmitOrtoFungible` | SETUP | · | · | 🟦1 | · | 🟫4 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `A_ToggleOpenForBusiness` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟦 5x | **8** | management/config/property change — slightly expensive |
| `A_ToggleRetrieval` | SETUP | · | 🟧1 | 🟦1 | · | 🟫1 | **3** | · | 🟦 5x | **8** | management/config/property change — slightly expensive |

## 01_ANK.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_IssueTrueFungibleAnchor` | ISSUE | 🟥4 | · | 🟦4 | · | 🟫7 | **23** | · | 🟧 50x | **73** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueSemiFungibleAnchor` | ISSUE | 🟥4 | · | 🟦4 | · | 🟫7 | **23** | · | 🟧 50x | **73** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueNonFungibleAnchor` | ISSUE | 🟥4 | · | 🟦4 | · | 🟫7 | **23** | · | 🟧 50x | **73** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueNonFungibleSetAnchor` | ISSUE | 🟥4 | · | 🟦4 | · | 🟫7 | **23** | · | 🟧 50x | **73** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_RevokeAnchor` | SETUP | 🟥2 | 🟧1 | 🟦6 | · | 🟫6 | **19** | · | 🟦 5x | **24** | management/config/property change — slightly expensive |
| `C_RevokeBoostClass` | SETUP | · | 🟧1 | 🟦1 | · | 🟫2 | **4** | · | 🟦 5x | **9** | management/config/property change — slightly expensive |

## 02_SCORE.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_IssueLiquidityScore` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫6 | **10** | 🟨1000 | ⬛ 1000x | **1010** | issuance — honor current flat GAS| (1000) |
| `C_IssueTrueFungibleScore` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫6 | **10** | 🟨1000 | ⬛ 1000x | **1010** | issuance — honor current flat GAS| (1000) |
| `C_IssueOrtoFungibleScore` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫6 | **10** | 🟨1000 | ⬛ 1000x | **1010** | issuance — honor current flat GAS| (1000) |
| `C_IssueSemiFungibleScore` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫6 | **10** | 🟨1000 | ⬛ 1000x | **1010** | issuance — honor current flat GAS| (1000) |
| `C_IssueNonFungibleScore` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫6 | **10** | 🟨1000 | ⬛ 1000x | **1010** | issuance — honor current flat GAS| (1000) |
| `C_IssueScoreFromModel` | ISSUE | 🟥4 | 🟧1 | 🟦6 | · | 🟫4 | **23** | 🟨500 | 🟥 500x | **523** | issuance — honor current flat GAS| (500) |
| `C_IssueTriplet` | ISSUE | 🟥1 | 🟧1 | 🟦4 | · | 🟫2 | **10** | 🟨500 | 🟥 500x | **510** | issuance — honor current flat GAS| (500) |
| `C_IssueSingleScoreModel` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫3 | **7** | 🟨500 | 🟥 500x | **507** | issuance — honor current flat GAS| (500) |
| `C_IssueNonFungibleScoreDefinition` | ISSUE | 🟥4 | · | 🟦7 | · | 🟫3 | **22** | · | 🟧 50x | **72** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueNonFungibleSetScoreDefinition` | ISSUE | 🟥4 | · | 🟦7 | · | 🟫3 | **22** | · | 🟧 50x | **72** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_IssueSemiFungibleScoreDefinition` | ISSUE | 🟥2 | · | 🟦3 | · | 🟫3 | **12** | · | 🟧 50x | **62** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateBoostClassLink` | ISSUE | · | 🟧1 | 🟦3 | · | 🟫3 | **7** | · | 🟧 50x | **57** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_CreateBoostLink` | ISSUE | · | 🟧1 | 🟦2 | · | 🟫1 | **4** | · | 🟧 50x | **54** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `C_RotateOwnership` | SETUP | · | 🟧1 | 🟦2 | · | 🟫1 | **4** | · | 🟪 10x | **14** | role/authority/guard setup |
| `C_CombineTripletScoreModel` | SETUP | 🟥1 | · | 🟦1 | · | 🟫3 | **7** | 🟨500 | 🟦 5x | **12** | management/config/property change — slightly expensive |
| `C_Control` | SETUP | · | 🟧1 | 🟦2 | · | 🟫1 | **4** | · | 🟦 5x | **9** | management/config/property change — slightly expensive |
| `C_EnableDebBoost` | SETUP | · | 🟧1 | 🟦2 | · | 🟫1 | **4** | · | 🟦 5x | **9** | management/config/property change — slightly expensive |

## 03_AQP.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫5 | **9** | 🟨1000 | ⬛ 1000x | **1009** | issuance — honor current flat GAS| (1000) |
| `C_SyncCollectableAnchors` | USAGE | 🟥2 | · | 🟦3 | 🟪3 | 🟫7 | **19** | 🟨50 | 🟩 1x | **20** | legit activity — pure compute, no deterrent |
| `C_RevokeScore` | SETUP | · | 🟧1 | 🟦8 | · | 🟫5 | **14** | 🟨500 | 🟦 5x | **19** | management/config/property change — slightly expensive |
| `C_AddScore` | SETUP | · | 🟧1 | 🟦8 | · | 🟫3 | **12** | 🟨500 | 🟦 5x | **17** | management/config/property change — slightly expensive |
| `C_SyncTrueFungibleAnchors` | SETUP | · | 🟧1 | 🟦2 | · | 🟫6 | **9** | 🟨50 | 🟦 5x | **14** | management/config/property change — slightly expensive |
| `C_DisablePoolStake` | USAGE | · | 🟧1 | 🟦1 | · | 🟫2 | **4** | 🟨500 | 🟩 1x | **5** | legit activity — pure compute, no deterrent |
| `C_EnablePoolStake` | USAGE | · | 🟧1 | 🟦1 | · | 🟫2 | **4** | 🟨500 | 🟩 1x | **5** | legit activity — pure compute, no deterrent |

## 05_FVT.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_Issue` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫6 | **10** | 🟨1000 | ⬛ 1000x | **1010** | issuance — honor current flat GAS| (1000) |
| `C_IssueMultipletFamily` | ISSUE | · | · | 🟦1 | · | 🟫4 | **5** | 🟨500 | 🟥 500x | **505** | issuance — honor current flat GAS| (500) |
| `CC_Collect` | USAGE | · | · | 🟦1 | · | 🟫28 | **29** | · | 🟩 1x | **30** | legit activity — pure compute, no deterrent |
| `C_AddScoreEntity` | SETUP | · | · | 🟦1 | · | 🟫19 | **20** | 🟨500 | 🟦 5x | **25** | management/config/property change — slightly expensive |
| `CC_TrueFungibleStakeFlow` | USAGE | · | · | 🟦1 | · | 🟫19 | **20** | · | 🟩 1x | **21** | legit activity — pure compute, no deterrent |
| `CC_CollectableStakeFlow` | USAGE | · | · | 🟦1 | · | 🟫19 | **20** | · | 🟩 1x | **21** | legit activity — pure compute, no deterrent |
| `CC_SweepRevokeAnchor` | USAGE | · | · | 🟦1 | · | 🟫14 | **15** | · | 🟩 1x | **16** | legit activity — pure compute, no deterrent |
| `CC_SweepBegin` | USAGE | 🟥2 | · | 🟦2 | · | 🟫7 | **15** | · | 🟩 1x | **16** | legit activity — pure compute, no deterrent |
| `CCp_SweepRecomputeChunk` | USAGE | 🟥2 | · | 🟦2 | · | 🟫6 | **14** | · | 🟩 1x | **15** | legit activity — pure compute, no deterrent |
| `CC_OrtoFungibleStakeFlow` | USAGE | · | · | 🟦1 | · | 🟫13 | **14** | · | 🟩 1x | **15** | legit activity — pure compute, no deterrent |
| `C_RotateOwnership` | SETUP | · | · | 🟦1 | · | 🟫3 | **4** | · | 🟪 10x | **14** | role/authority/guard setup |
| `CCp_UnstaleAll` | USAGE | · | · | 🟦1 | · | 🟫11 | **12** | · | 🟩 1x | **13** | legit activity — pure compute, no deterrent |
| `CC_Inject` | USAGE | · | · | 🟦1 | · | 🟫10 | **11** | · | 🟩 1x | **12** | legit activity — pure compute, no deterrent |
| `C_SetCommonDenominator` | SETUP | · | 🟧1 | 🟦1 | · | 🟫4 | **6** | 🟨500 | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_SetMosaic` | SETUP | · | · | 🟦1 | · | 🟫5 | **6** | 🟨500 | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_SetSplitMode` | SETUP | · | · | 🟦1 | · | 🟫5 | **6** | 🟨500 | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_ToggleScoreEntityLink` | SETUP | · | · | 🟦1 | · | 🟫5 | **6** | 🟨500 | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_AddRewardLink` | SETUP | · | · | 🟦1 | · | 🟫5 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_ToggleRewardLink` | SETUP | · | · | 🟦1 | · | 🟫5 | **6** | 🟨500 | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_SetQualitySplit` | SETUP | · | · | 🟦1 | · | 🟫5 | **6** | 🟨500 | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `C_Control` | SETUP | · | 🟧1 | 🟦1 | · | 🟫3 | **5** | · | 🟦 5x | **10** | management/config/property change — slightly expensive |
| `CCp_InjectFixChunk` | USAGE | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟩 1x | **8** | legit activity — pure compute, no deterrent |
| `CC_UnstaleMyScores` | USAGE | · | · | 🟦1 | · | 🟫5 | **6** | 🟨500 | 🟩 1x | **7** | legit activity — pure compute, no deterrent |
| `CC_InjectFinalize` | USAGE | · | · | 🟦1 | 🟪1 | 🟫3 | **5** | · | 🟩 1x | **6** | legit activity — pure compute, no deterrent |
| `CC_InjectStream` | USAGE | · | · | 🟦1 | · | 🟫2 | **3** | · | 🟩 1x | **4** | legit activity — pure compute, no deterrent |

## 06_VCT.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `CC_FullVacate` | USAGE | · | · | 🟦1 | · | 🟫48 | **49** | · | 🟩 1x | **50** | legit activity — pure compute, no deterrent |
| `CCp_BatchVacateTrueFungible` | USAGE | · | · | 🟦1 | · | 🟫32 | **33** | · | 🟩 1x | **34** | legit activity — pure compute, no deterrent |
| `CCp_BatchVacateCollectables` | USAGE | · | · | 🟦1 | · | 🟫31 | **32** | · | 🟩 1x | **33** | legit activity — pure compute, no deterrent |
| `CCp_BatchVacateOrtoFungible` | USAGE | · | · | 🟦1 | · | 🟫29 | **30** | · | 🟩 1x | **31** | legit activity — pure compute, no deterrent |
| `CCp_BatchDrainTrueFungible` | USAGE | · | · | 🟦1 | · | 🟫21 | **22** | · | 🟩 1x | **23** | legit activity — pure compute, no deterrent |
| `CCp_BatchDrainCollectable` | USAGE | · | · | 🟦1 | · | 🟫20 | **21** | · | 🟩 1x | **22** | legit activity — pure compute, no deterrent |
| `CCp_BatchDrainOrtoFungible` | USAGE | · | · | 🟦1 | · | 🟫18 | **19** | · | 🟩 1x | **20** | legit activity — pure compute, no deterrent |
| `C_FinalizeVacate` | USAGE | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟩 1x | **10** | legit activity — pure compute, no deterrent |
| `C_AbortVacate` | USAGE | · | · | 🟦1 | · | 🟫6 | **7** | · | 🟩 1x | **8** | legit activity — pure compute, no deterrent |

## 07_MTX-AQP.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_2|SweepRevokeAnchor` | USAGE | · | · | 🟦1 | · | 🟫10 | **11** | · | 🟩 1x | **12** | legit activity — pure compute, no deterrent |
| `C_2|Inject` | USAGE | · | · | 🟦1 | · | 🟫5 | **6** | · | 🟩 1x | **7** | legit activity — pure compute, no deterrent |

## 08_DSA.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_DefineDelegationVault` | ISSUE | 🟥1 | · | 🟦1 | · | 🟫2 | **6** | 🟨500 | 🟥 500x | **506** | issuance — honor current flat GAS| (500) |
| `A_SetAgencyFee` | SETUP | · | 🟧1 | 🟦2 | · | 🟫2 | **5** | 🟨300 | 🟨 25x | **30** | economic-parameter change (fee/price/rate) |
| `A_OracleWrite` | SETUP | · | 🟧1 | 🟦3 | · | 🟫8 | **12** | 🟨200 | 🟪 10x | **22** | role/authority/guard setup |
| `A_SetOracleAuth` | SETUP | 🟥1 | · | 🟦1 | · | 🟫3 | **7** | 🟨300 | 🟪 10x | **17** | role/authority/guard setup |
| `C_AdmitAgency` | SETUP | 🟥1 | · | 🟦1 | · | 🟫2 | **6** | 🟨500 | 🟪 10x | **16** | role/authority/guard setup |
| `C_RecomputeCapture` | SETUP | · | · | 🟦3 | · | 🟫8 | **11** | 🟨300 | 🟦 5x | **16** | management/config/property change — slightly expensive |
| `A_ToggleExternalOracle` | SETUP | · | · | · | · | · | **0** | · | 🟪 10x | **10** | role/authority/guard setup |
| `A_SetOracleValidity` | SETUP | · | · | · | · | · | **0** | · | 🟪 10x | **10** | role/authority/guard setup |
| `A_BurnRoyalty` | SETUP | · | · | 🟦1 | · | 🟫2 | **3** | 🟨400 | 🟦 5x | **8** | management/config/property change — slightly expensive |
| `A_WithdrawRoyalty` | USAGE | · | · | 🟦1 | · | 🟫2 | **3** | 🟨400 | 🟩 1x | **4** | legit activity — pure compute, no deterrent |
| `A_FuelRoyalty` | USAGE | · | · | 🟦1 | · | 🟫2 | **3** | 🟨500 | 🟩 1x | **4** | legit activity — pure compute, no deterrent |

## 05_TS02-DPAD.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_DefinePrice` | ISSUE | · | · | · | · | 🟫1 | **1** | · | 🟧 50x | **51** | token/collection issuance — STOA-priced (20-50) + modest IGNIS deterrent |
| `A_RegisterAssetToLaunchpad` | SETUP | · | · | · | · | 🟫6 | **6** | · | 🟦 5x | **11** | management/config/property change — slightly expensive |
| `A_ToggleOpenForBusiness` | SETUP | · | · | · | · | 🟫1 | **1** | · | 🟦 5x | **6** | management/config/property change — slightly expensive |
| `A_ToggleRetrieval` | SETUP | · | · | · | · | 🟫1 | **1** | · | 🟦 5x | **6** | management/config/property change — slightly expensive |

## 01_Spark.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_RedemAllSparks` | SETUP | · | · | 🟦1 | · | 🟫13 | **14** | · | 🟦 5x | **19** | management/config/property change — slightly expensive |
| `C_CustomRedemAllSparks` | SETUP | · | · | 🟦1 | · | 🟫12 | **13** | · | 🟦 5x | **18** | management/config/property change — slightly expensive |
| `C_RedemFewSparks` | SETUP | · | · | 🟦1 | · | 🟫12 | **13** | · | 🟦 5x | **18** | management/config/property change — slightly expensive |
| `C_CustomRedemFewSparks` | SETUP | · | · | 🟦1 | · | 🟫11 | **12** | · | 🟦 5x | **17** | management/config/property change — slightly expensive |
| `C_BuySparks` | SETUP | · | · | 🟦1 | · | 🟫7 | **8** | · | 🟦 5x | **13** | management/config/property change — slightly expensive |

## 02_Snakes.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_UpdateSharePrice` | SETUP | · | · | 🟦1 | · | 🟫1 | **2** | · | 🟨 25x | **27** | economic-parameter change (fee/price/rate) |
| `C_Acquire` | SETUP | · | · | 🟦1 | · | 🟫15 | **16** | · | 🟦 5x | **21** | management/config/property change — slightly expensive |

## 03_Custodians.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_UpdateQuintessencePrice` | SETUP | · | · | 🟦1 | · | 🟫1 | **2** | · | 🟨 25x | **27** | economic-parameter change (fee/price/rate) |
| `C_Acquire` | SETUP | · | · | 🟦1 | · | 🟫14 | **15** | · | 🟦 5x | **20** | management/config/property change — slightly expensive |

## 04_STOICPAY.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `C_BuyStoicPay` | SETUP | · | · | 🟦1 | · | 🟫8 | **9** | · | 🟦 5x | **14** | management/config/property change — slightly expensive |

## 05_STOAICO.pact

| op | role | ins/wr | upd | R | S | X | components | cur GAS\| | **deter** | final | rationale |
|----|------|--:|--:|--:|--:|--:|-------:|-----:|------:|-----:|-----------|
| `A_Stake` | USAGE | 🟥1 | 🟧8 | 🟦12 | · | 🟫2 | **25** | · | 🟩 1x | **26** | legit activity — pure compute, no deterrent |
| `Ap_FlushUncollectedSlice` | USAGE | · | 🟧6 | 🟦11 | · | 🟫4 | **21** | · | 🟩 1x | **22** | legit activity — pure compute, no deterrent |
| `AA_FlushUncollected` | USAGE | · | 🟧6 | 🟦10 | 🟪1 | 🟫4 | **21** | · | 🟩 1x | **22** | legit activity — pure compute, no deterrent |
| `C_Collect` | USAGE | · | 🟧6 | 🟦10 | · | 🟫4 | **20** | · | 🟩 1x | **21** | legit activity — pure compute, no deterrent |
| `A_Unstake` | USAGE | · | 🟧7 | 🟦10 | · | 🟫2 | **19** | · | 🟩 1x | **20** | legit activity — pure compute, no deterrent |
| `A_Inject` | USAGE | · | 🟧5 | 🟦8 | · | 🟫2 | **15** | · | 🟩 1x | **16** | legit activity — pure compute, no deterrent |
| `A_InitialiseDistributionVault` | SETUP | 🟥1 | · | · | · | 🟫7 | **10** | · | 🟦 5x | **15** | management/config/property change — slightly expensive |

---
## Colour legend / suggested-deter tier distribution

Deter is a multiplier on IG|TX: `25x` = 25·IG|TX added on top of the compute components.
Each colour square below tags every op of that tier in the tables above.

| colour | deter | ops | meaning |
|--------|------:|----:|---------|
| ⬜ | exempt | 8 | IGNIS-exempt (account creation + ignis machinery: collect/compress/sublimate/firestarter) |
| 🟩 | 1x | 78 | activity — no deterrent |
| 🟦 | 5x | 168 | config/property change |
| 🟪 | 10x | 32 | role/authority/guard setup |
| 🟨 | 25x | 21 | fee/price/rate change |
| 🟧 | 50x | 39 | token/collection issuance (+STOA) |
| 🟥 | 500x | 5 | issuance (current flat) |
| ⬛ | 1000x | 13 | issuance / LP — very big |

364 ops · 278 pre-suggested deter>1 (rest default 1). Revise & green-light.

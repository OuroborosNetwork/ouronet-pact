# REPL TEST LEDGER — what is tested, how often, and how

**GENERATED — do not edit.** `python3 REPL/_test_ledger.py > OuronetInformational/ARCHITECTURE/REPL-TEST-LEDGER.md`

This is the evidence base for the audit and documentation papers: every client entrypoint Ouronet exposes, how many times each is exercised, how many positive and adversarial assertions surround it, and which test files touch it.

> **How to read the assertion columns.** Assertions are attributed by TRANSACTION BLOCK: an assertion is credited to every op invoked in the same `(begin-tx … commit-tx)`. A block that calls three ops and asserts once credits all three. So `+asserts` / `-asserts` measure how well an op's *neighbourhood* is asserted — they are NOT proof that an assertion targets that op. **Invocation counts are exact.** Treat a high invocation count with zero `-asserts` as an op that is exercised but never adversarially probed.

## Summary

| metric | value |
|---|---:|
| client entrypoints (the auditable contract) | 448 |
| exercised at least once | 433 (96%) |
| **never exercised** | **15** |
| exercised but with NO adversarial assertion in any of its blocks | **311** |
| total invocations across the suite | 3086 |

## Never exercised — G1 gap

These entrypoints are reachable by a client and no test calls them.

* `AQP-FVT&#124;CC_SweepRevokeAnchor`
* `CUSTODIANS&#124;C_Acquire`
* `DALOS&#124;A_MigrateLiquidFunds`
* `DEMIPAD&#124;C_Deposit`
* `DEMIPAD&#124;C_Withdraw`
* `PYTHIA&#124;A_RevokeLink`
* `P&#124;A_Add`
* `SNAKES&#124;C_Acquire`
* `SPARK&#124;C_RedemAllSparks`
* `SPARK&#124;C_RedemFewSparks`
* `STOAICO&#124;C_Collect`
* `SWP&#124;C_SmartSwapWithSlippage`
* `VST&#124;C_RepurposeHibernating`
* `VST&#124;C_RepurposeSlumber`
* `VST&#124;C_ToggleTransferRoleHibernatingDPOF`

## Exercised but never adversarially probed — G2 gap

Called by at least one test, but no `expect-failure` appears in any block that calls them. Every one of these needs a rejection test per RULE 3.

| entrypoint | invocations | +asserts |
|---|---:|---:|
| <code>ATS&#124;C_ColdRecovery</code> | 275 | 0 |
| <code>VST&#124;C_Sleep</code> | 74 | 6 |
| <code>DPTF&#124;C_Transfer</code> | 60 | 60 |
| <code>P&#124;A_Define</code> | 58 | 0 |
| <code>AQP-FVT&#124;CC_Collect</code> | 55 | 146 |
| <code>AQP-FVT&#124;CC_Inject</code> | 39 | 155 |
| <code>DALOS&#124;A_UpdateUsagePrice</code> | 32 | 5 |
| <code>AQP-POOL&#124;CC_StakeNonFungibleCollectable</code> | 31 | 98 |
| <code>ATS&#124;C_Coil</code> | 29 | 3 |
| <code>DPTF&#124;C_ToggleFee</code> | 28 | 6 |
| <code>DPTF&#124;C_SetFee</code> | 26 | 6 |
| <code>DPTF&#124;C_ToggleFeeLock</code> | 25 | 0 |
| <code>DPTF&#124;C_Issue</code> | 24 | 0 |
| <code>AQP-SCR&#124;C_IssueNonFungibleScore</code> | 21 | 32 |
| <code>AQP-POOL&#124;CCp_BatchVacateCollectables</code> | 20 | 28 |
| <code>DPNF&#124;C_TransferNonces</code> | 20 | 28 |
| <code>SWP&#124;C_UpdateFee</code> | 19 | 0 |
| <code>SWP&#124;C_UpdateSpecialFeeTargets</code> | 19 | 0 |
| <code>AQP-SCR&#124;C_IssueOrtoFungibleScore</code> | 18 | 10 |
| <code>DPSF&#124;C_TransferNonces</code> | 15 | 15 |
| <code>ATS&#124;C_SwitchColdRecovery</code> | 14 | 0 |
| <code>DPSF&#124;C_Make</code> | 13 | 23 |
| <code>DALOS&#124;A_DeployStandardAccount</code> | 12 | 1 |
| <code>DALOS&#124;C_RotateGovernor</code> | 12 | 0 |
| <code>ATS&#124;C_SwitchHotRecovery</code> | 11 | 4 |
| <code>DPSF&#124;C_Break</code> | 11 | 23 |
| <code>AQP-POOL&#124;CCp_BatchVacateOrtoFungible</code> | 10 | 12 |
| <code>DPSF&#124;C_TransferNonce</code> | 10 | 17 |
| <code>DPTF&#124;A_DeployAccount</code> | 10 | 0 |
| <code>AQP-POOL&#124;CC_UnstakeTrueFungible</code> | 9 | 33 |
| <code>DPOF&#124;C_Issue</code> | 9 | 0 |
| <code>AQP-POOL&#124;CCp_BatchDrainTrueFungible</code> | 8 | 28 |
| <code>ATS&#124;C_Cull</code> | 8 | 3 |
| <code>DPNF&#124;C_TransferNonce</code> | 8 | 42 |
| <code>PYTHIA&#124;C_DeployApiKey</code> | 8 | 11 |
| <code>SWP&#124;CC_SmartSwapNoSlippage</code> | 8 | 11 |
| <code>ATS&#124;C_Issue</code> | 7 | 0 |
| <code>AQP-FVT&#124;C_ToggleScoreEntityLink</code> | 6 | 6 |
| <code>ATS&#124;C_HotRecovery</code> | 6 | 7 |
| <code>DALOS&#124;A_ToggleGAP</code> | 6 | 9 |
| <code>DPNF&#124;C_ToggleUpdateRole</code> | 6 | 3 |
| <code>DPTF&#124;C_ToggleFreezeAccount</code> | 6 | 0 |
| <code>DPTF&#124;C_Transmute</code> | 6 | 0 |
| <code>PYTHIA&#124;A_Link</code> | 6 | 13 |
| <code>AQP-FVT&#124;CCp_InjectFixChunk</code> | 5 | 10 |
| <code>AQP-FVT&#124;CCp_SweepRecomputeChunk</code> | 5 | 21 |
| <code>ATS&#124;C_Fuel</code> | 5 | 2 |
| <code>DPOF&#124;C_Control</code> | 5 | 8 |
| <code>DPTF&#124;C_DonateFees</code> | 5 | 0 |
| <code>VST&#124;C_CreateHibernatingLink</code> | 5 | 6 |
| <code>AQP-DSA&#124;A_ToggleExternalOracle</code> | 4 | 8 |
| <code>AQP-POOL&#124;CCp_BatchDrainCollectable</code> | 4 | 10 |
| <code>AQP-SCR&#124;C_ControlScore</code> | 4 | 6 |
| <code>AQP-SCR&#124;C_RotateScoreOwnership</code> | 4 | 6 |
| <code>CODEX&#124;C_RegisterStoicTag</code> | 4 | 11 |
| <code>DPNF&#124;C_BulkTransfer</code> | 4 | 4 |
| <code>DPNF&#124;C_TogglePause</code> | 4 | 5 |
| <code>DPOF&#124;C_TogglePause</code> | 4 | 5 |
| <code>DPTF&#124;C_MultiTransfer</code> | 4 | 0 |
| <code>LQD&#124;C_WrapStoa</code> | 4 | 0 |
| <code>SWP&#124;C_IssueStablePool</code> | 4 | 0 |
| <code>SWP&#124;C_UpdatePendingBrandingLPs</code> | 4 | 3 |
| <code>VST&#124;C_CreateFrozenLink</code> | 4 | 3 |
| <code>AQP-DSA&#124;A_SetOracleValidity</code> | 3 | 6 |
| <code>AQP-DSA&#124;C_SetOracleAuth</code> | 3 | 9 |
| <code>ATS&#124;C_SetColdRecoveryFees</code> | 3 | 0 |
| <code>ATS&#124;C_SwitchDirectRecovery</code> | 3 | 2 |
| <code>ATS&#124;C_ToggleParameterLock</code> | 3 | 0 |
| <code>DPNF&#124;C_ToggleBurnRole</code> | 3 | 1 |
| <code>DPOF&#124;C_MoveCreateRole</code> | 3 | 6 |
| <code>DPSF&#124;C_AddQuantity</code> | 3 | 0 |
| <code>DPSF&#124;C_DefineHybridSet</code> | 3 | 6 |
| <code>DPSF&#124;C_IssueCompany</code> | 3 | 6 |
| <code>DPSF&#124;C_MergeFragments</code> | 3 | 5 |
| <code>DPTF&#124;C_BulkTransfer</code> | 3 | 0 |
| <code>DPTF&#124;C_Control</code> | 3 | 4 |
| <code>DPTF&#124;C_ResetFeeTarget</code> | 3 | 6 |
| <code>DPTF&#124;C_RotateOwnership</code> | 3 | 4 |
| <code>DPTF&#124;C_SetFeeTarget</code> | 3 | 6 |
| <code>SWP&#124;A_DefinePrimordialPool</code> | 3 | 0 |
| <code>SWP&#124;C_AddSleepingLiquidity</code> | 3 | 0 |
| <code>SWP&#124;C_SingleSwapWithSlippage</code> | 3 | 2 |
| <code>VST&#124;C_CreateSleepingLink</code> | 3 | 0 |
| <code>VST&#124;C_CreateVestingLink</code> | 3 | 0 |
| <code>VST&#124;C_Freeze</code> | 3 | 4 |
| <code>VST&#124;C_RepurposeMerge</code> | 3 | 0 |
| <code>VST&#124;C_ToggleTransferRoleSleepingDPOF</code> | 3 | 6 |
| <code>VST&#124;C_Unsleep</code> | 3 | 0 |
| <code>VST&#124;C_Vest</code> | 3 | 0 |
| <code>AQP-DSA&#124;C_SetAgencyFee</code> | 2 | 8 |
| <code>AQP-FVT&#124;CC_SweepBegin</code> | 2 | 13 |
| <code>AQP-FVT&#124;C_ToggleRewardLink</code> | 2 | 5 |
| <code>AQP-POOL&#124;CCp_BatchDrainOrtoFungible</code> | 2 | 8 |
| <code>AQP-POOL&#124;C_FinalizeVacate</code> | 2 | 13 |
| <code>ATS&#124;A_RemoveSecondary</code> | 2 | 1 |
| <code>ATS&#124;C_AddHotRBT</code> | 2 | 2 |
| <code>ATS&#124;C_AddSecondary</code> | 2 | 2 |
| <code>ATS&#124;C_Curl</code> | 2 | 0 |
| <code>ATS&#124;C_DirectRecovery</code> | 2 | 2 |
| <code>ATS&#124;C_KickStart</code> | 2 | 0 |
| <code>ATS&#124;C_Redeem</code> | 2 | 5 |
| <code>ATS&#124;C_RemoveSecondary</code> | 2 | 0 |
| <code>ATS&#124;C_Reverse</code> | 2 | 3 |
| <code>ATS&#124;C_RotateOwnership</code> | 2 | 0 |
| <code>ATS&#124;C_SetColdRecoveryDuration</code> | 2 | 0 |
| <code>ATS&#124;C_SetDirectRecoveryFee</code> | 2 | 0 |
| <code>ATS&#124;C_SetHotRecoveryFee</code> | 2 | 4 |
| <code>ATS&#124;C_WithdrawRoyalties</code> | 2 | 2 |
| <code>ATS&#124;HOT-RBT&#124;C_Repurpose</code> | 2 | 4 |
| <code>ATS&#124;HOT-RBT&#124;C_UpgradeBranding</code> | 2 | 2 |
| <code>CODEX&#124;A_RegisterCodexIdentity</code> | 2 | 3 |
| <code>CODEX&#124;C_RecordArweaveUpload</code> | 2 | 2 |
| <code>CODEX&#124;C_ReleaseStoicTag</code> | 2 | 4 |
| <code>CODEX&#124;C_RotateCodexGuard</code> | 2 | 1 |
| <code>DALOS&#124;A_IgnisToggle</code> | 2 | 0 |
| <code>DALOS&#124;A_SetAutoFueling</code> | 2 | 4 |
| <code>DALOS&#124;A_SetIgnisSourcePrice</code> | 2 | 4 |
| <code>DPDC&#124;C_MultiTransfer</code> | 2 | 5 |
| <code>DPNF&#124;C_Break</code> | 2 | 6 |
| <code>DPNF&#124;C_MoveCreateRole</code> | 2 | 0 |
| <code>DPNF&#124;C_MoveRecreateRole</code> | 2 | 0 |
| <code>DPNF&#124;C_MoveSetUriRole</code> | 2 | 0 |
| <code>DPNF&#124;C_ToggleExemptionRole</code> | 2 | 0 |
| <code>DPNF&#124;C_ToggleModifyCreatorRole</code> | 2 | 0 |
| <code>DPNF&#124;C_ToggleModifyRoyaltiesRole</code> | 2 | 0 |
| <code>DPNF&#124;C_ToggleSet</code> | 2 | 0 |
| <code>DPNF&#124;C_ToggleTransferRole</code> | 2 | 7 |
| <code>DPOF&#124;A_DeployAccount</code> | 2 | 0 |
| <code>DPOF&#124;C_AddQuantity</code> | 2 | 2 |
| <code>DPOF&#124;C_ToggleTransferRole</code> | 2 | 0 |
| <code>DPSF&#124;C_MoveCreateRole</code> | 2 | 0 |
| <code>DPSF&#124;C_MoveRecreateRole</code> | 2 | 0 |
| <code>DPSF&#124;C_MoveSetUriRole</code> | 2 | 0 |
| <code>DPSF&#124;C_ToggleBurnRole</code> | 2 | 0 |
| <code>DPSF&#124;C_ToggleExemptionRole</code> | 2 | 0 |
| <code>DPSF&#124;C_ToggleModifyCreatorRole</code> | 2 | 0 |
| <code>DPSF&#124;C_ToggleModifyRoyaltiesRole</code> | 2 | 0 |
| <code>DPSF&#124;C_TogglePause</code> | 2 | 0 |
| <code>DPSF&#124;C_ToggleTransferRole</code> | 2 | 0 |
| <code>DPSF&#124;C_ToggleUpdateRole</code> | 2 | 0 |
| <code>DPTF&#124;C_ToggleReservation</code> | 2 | 0 |
| <code>DPTF&#124;C_UpdatePendingBranding</code> | 2 | 0 |
| <code>DPTF&#124;C_UpgradeBranding</code> | 2 | 0 |
| <code>DPTF&#124;C_Wipe</code> | 2 | 0 |
| <code>KPAY&#124;C_BuyStoicPay</code> | 2 | 2 |
| <code>MTX-AQP&#124;2&#124;C_Inject</code> | 2 | 2 |
| <code>PYTHIA&#124;A_UpdateDeployPrice</code> | 2 | 0 |
| <code>PYTHIA&#124;A_UpdateRenamePrice</code> | 2 | 0 |
| <code>PYTHIA&#124;C_Link</code> | 2 | 6 |
| <code>PYTHIA&#124;C_RevokeLink</code> | 2 | 5 |
| <code>PYTHIA&#124;C_UpdateDualConsumerLane</code> | 2 | 3 |
| <code>SPARK&#124;C_BuySparks</code> | 2 | 2 |
| <code>SWP&#124;A_ToggleAsymetricLiquidityAddition</code> | 2 | 0 |
| <code>SWP&#124;A_UpdateLimit</code> | 2 | 0 |
| <code>SWP&#124;C_AddFrozenLiquidity</code> | 2 | 0 |
| <code>SWP&#124;C_AddGlacialLiquidity</code> | 2 | 0 |
| <code>SWP&#124;C_ChangeOwnership</code> | 2 | 0 |
| <code>SWP&#124;C_IssueStandardPool</code> | 2 | 0 |
| <code>SWP&#124;C_IssueWeightedPool</code> | 2 | 0 |
| <code>SWP&#124;C_ModifyCanChangeOwner</code> | 2 | 0 |
| <code>SWP&#124;C_MultiSwapWithSlippage</code> | 2 | 0 |
| <code>SWP&#124;C_SingleSwapNoSlippage</code> | 2 | 0 |
| <code>SWP&#124;C_UpgradeBrandingLPs</code> | 2 | 3 |
| <code>VST&#124;C_Merge</code> | 2 | 0 |
| <code>VST&#124;C_RepurposeFrozen</code> | 2 | 0 |
| <code>VST&#124;C_RepurposeReserved</code> | 2 | 0 |
| <code>VST&#124;C_RepurposeSleeping</code> | 2 | 0 |
| <code>VST&#124;C_Reserve</code> | 2 | 0 |
| <code>VST&#124;C_ToggleTransferRoleFrozenDPTF</code> | 2 | 0 |
| <code>VST&#124;C_ToggleTransferRoleReservedDPTF</code> | 2 | 0 |
| <code>VST&#124;C_Unreserve</code> | 2 | 0 |
| <code>AQP-ANK&#124;C_IssueNonFungibleAnchor</code> | 1 | 0 |
| <code>AQP-ANK&#124;C_IssueNonFungibleSetAnchor</code> | 1 | 6 |
| <code>AQP-ANK&#124;C_IssueSemiFungibleAnchor</code> | 1 | 6 |
| <code>AQP-DSA&#124;C_BurnRoyalty</code> | 1 | 3 |
| <code>AQP-DSA&#124;C_FuelRoyalty</code> | 1 | 4 |
| <code>AQP-DSA&#124;C_RecomputeCapture</code> | 1 | 4 |
| <code>AQP-FVT&#124;CC_UnstaleMyScores</code> | 1 | 5 |
| <code>AQP-FVT&#124;C_IssueMultipletFamily</code> | 1 | 0 |
| <code>AQP-FVT&#124;C_RotateOwnership</code> | 1 | 0 |
| <code>AQP-FVT&#124;C_SetCommonDenominator</code> | 1 | 0 |
| <code>AQP-POOL&#124;C_SyncNonFungibleAnchors</code> | 1 | 6 |
| <code>AQP-POOL&#124;C_SyncSemiFungibleAnchors</code> | 1 | 6 |
| <code>AQP-POOL&#124;C_SyncTrueFungibleAnchors</code> | 1 | 6 |
| <code>AQP-SCR&#124;C_CreateScoreBoostClassLink</code> | 1 | 2 |
| <code>AQP-SCR&#124;C_IssueLiquidityScore</code> | 1 | 2 |
| <code>AQP-SCR&#124;C_IssueTriplet</code> | 1 | 0 |
| <code>ATS&#124;A_KickStart</code> | 1 | 2 |
| <code>ATS&#124;C_Brumate</code> | 1 | 0 |
| <code>ATS&#124;C_Constrict</code> | 1 | 6 |
| <code>ATS&#124;C_ControlColdRecoveryFees</code> | 1 | 0 |
| <code>ATS&#124;C_ControlHotRecoveryFee</code> | 1 | 0 |
| <code>ATS&#124;C_Syphon</code> | 1 | 0 |
| <code>ATS&#124;C_ToggleElite</code> | 1 | 0 |
| <code>ATS&#124;C_UpdateSyphon</code> | 1 | 0 |
| <code>ATS&#124;C_UpgradeBranding</code> | 1 | 0 |
| <code>ATS&#124;C_VestedCoil</code> | 1 | 0 |
| <code>ATS&#124;C_VestedCurl</code> | 1 | 0 |
| <code>BRD&#124;A_Live</code> | 1 | 0 |
| <code>BRD&#124;A_SetFlag</code> | 1 | 0 |
| <code>DALOS&#124;A_ToggleOAPU</code> | 1 | 4 |
| <code>DALOS&#124;A_UpdatePublicKey</code> | 1 | 0 |
| <code>DALOS&#124;C_ControlSmartAccount</code> | 1 | 0 |
| <code>DALOS&#124;C_DeployStandardAccount</code> | 1 | 0 |
| <code>DALOS&#124;C_RotateGuard</code> | 1 | 0 |
| <code>DALOS&#124;C_RotateSovereign</code> | 1 | 0 |
| <code>DALOS&#124;C_RotateStoa</code> | 1 | 0 |
| <code>DALOS&#124;C_UpdateEliteAccount</code> | 1 | 11 |
| <code>DALOS&#124;C_UpdateEliteAccountSquared</code> | 1 | 11 |
| <code>DEMIPAD&#124;C_FuelNonFungible</code> | 1 | 1 |
| <code>DEMIPAD&#124;C_FuelOrtoFungible</code> | 1 | 0 |
| <code>DEMIPAD&#124;C_FuelSemiFungible</code> | 1 | 0 |
| <code>DEMIPAD&#124;C_FuelTrueFungible</code> | 1 | 0 |
| <code>DEMIPAD&#124;C_RetrieveNonFungible</code> | 1 | 1 |
| <code>DEMIPAD&#124;C_RetrieveOrtoFungible</code> | 1 | 0 |
| <code>DEMIPAD&#124;C_RetrieveSemiFungible</code> | 1 | 0 |
| <code>DEMIPAD&#124;C_RetrieveTrueFungible</code> | 1 | 0 |
| <code>DPDC&#124;C_BulkTransfer</code> | 1 | 4 |
| <code>DPNF&#124;C_Burn</code> | 1 | 1 |
| <code>DPNF&#124;C_DefineCompositeSet</code> | 1 | 0 |
| <code>DPNF&#124;C_DefineHybridSet</code> | 1 | 0 |
| <code>DPNF&#124;C_EnableSetClassFragmentation</code> | 1 | 0 |
| <code>DPNF&#124;C_MergeFragments</code> | 1 | 1 |
| <code>DPNF&#124;C_RemoveNonceScore</code> | 1 | 0 |
| <code>DPNF&#124;C_RemoveSetNonceScore</code> | 1 | 0 |
| <code>DPNF&#124;C_RenameSet</code> | 1 | 0 |
| <code>DPNF&#124;C_Repurpose</code> | 1 | 0 |
| <code>DPNF&#124;C_RepurposeFragments</code> | 1 | 1 |
| <code>DPNF&#124;C_Respawn</code> | 1 | 1 |
| <code>DPNF&#124;C_UpdateNonce</code> | 1 | 7 |
| <code>DPNF&#124;C_UpdateNonceIgnisRoyalty</code> | 1 | 0 |
| <code>DPNF&#124;C_UpdateNonceRoyalty</code> | 1 | 7 |
| <code>DPNF&#124;C_UpdateNonceScore</code> | 1 | 7 |
| <code>DPNF&#124;C_UpdateNonces</code> | 1 | 0 |
| <code>DPNF&#124;C_UpdatePendingBranding</code> | 1 | 5 |
| <code>DPNF&#124;C_UpdateSetNonce</code> | 1 | 0 |
| <code>DPNF&#124;C_UpdateSetNonceDescription</code> | 1 | 0 |
| <code>DPNF&#124;C_UpdateSetNonceIgnisRoyalty</code> | 1 | 0 |
| <code>DPNF&#124;C_UpdateSetNonceMetaData</code> | 1 | 0 |
| <code>DPNF&#124;C_UpdateSetNonceRoyalty</code> | 1 | 0 |
| <code>DPNF&#124;C_UpdateSetNonceScore</code> | 1 | 0 |
| <code>DPNF&#124;C_UpdateSetNonceURI</code> | 1 | 0 |
| <code>DPNF&#124;C_UpdateSetNonces</code> | 1 | 0 |
| <code>DPNF&#124;C_UpgradeBranding</code> | 1 | 0 |
| <code>DPNF&#124;C_WipeClean</code> | 1 | 2 |
| <code>DPNF&#124;C_WipeDirty</code> | 1 | 2 |
| <code>DPNF&#124;C_WipeHeavy</code> | 1 | 2 |
| <code>DPNF&#124;C_WipeNonce</code> | 1 | 2 |
| <code>DPNF&#124;C_WipePure</code> | 1 | 2 |
| <code>DPOF&#124;C_BulkTransfer</code> | 1 | 0 |
| <code>DPOF&#124;C_Burn</code> | 1 | 0 |
| <code>DPOF&#124;C_DeployAccount</code> | 1 | 0 |
| <code>DPOF&#124;C_RotateOwnership</code> | 1 | 0 |
| <code>DPOF&#124;C_ToggleBurnRole</code> | 1 | 0 |
| <code>DPOF&#124;C_UpdatePendingBranding</code> | 1 | 0 |
| <code>DPOF&#124;C_UpgradeBranding</code> | 1 | 0 |
| <code>DPOF&#124;C_WipeClean</code> | 1 | 0 |
| <code>DPOF&#124;C_WipeHeavy</code> | 1 | 0 |
| <code>DPOF&#124;C_WipePure</code> | 1 | 0 |
| <code>DPOF&#124;C_WipeSlim</code> | 1 | 0 |
| <code>DPSF&#124;C_Burn</code> | 1 | 0 |
| <code>DPSF&#124;C_Control</code> | 1 | 0 |
| <code>DPSF&#124;C_RemoveSetNonceScore</code> | 1 | 0 |
| <code>DPSF&#124;C_Repurpose</code> | 1 | 0 |
| <code>DPSF&#124;C_ToggleAddQuantityRole</code> | 1 | 0 |
| <code>DPSF&#124;C_UpdateNonce</code> | 1 | 5 |
| <code>DPSF&#124;C_UpdateNonces</code> | 1 | 0 |
| <code>DPSF&#124;C_UpdatePendingBranding</code> | 1 | 5 |
| <code>DPSF&#124;C_UpdateSetNonce</code> | 1 | 0 |
| <code>DPSF&#124;C_UpdateSetNonceDescription</code> | 1 | 0 |
| <code>DPSF&#124;C_UpdateSetNonceIgnisRoyalty</code> | 1 | 0 |
| <code>DPSF&#124;C_UpdateSetNonceMetaData</code> | 1 | 0 |
| <code>DPSF&#124;C_UpdateSetNonceName</code> | 1 | 0 |
| <code>DPSF&#124;C_UpdateSetNonceRoyalty</code> | 1 | 0 |
| <code>DPSF&#124;C_UpdateSetNonceScore</code> | 1 | 0 |
| <code>DPSF&#124;C_UpdateSetNonceURI</code> | 1 | 0 |
| <code>DPSF&#124;C_UpdateSetNonces</code> | 1 | 0 |
| <code>DPSF&#124;C_UpgradeBranding</code> | 1 | 0 |
| <code>DPSF&#124;C_WipeClean</code> | 1 | 0 |
| <code>DPSF&#124;C_WipeDirty</code> | 1 | 0 |
| <code>DPSF&#124;C_WipeHeavy</code> | 1 | 0 |
| <code>DPSF&#124;C_WipeNonce</code> | 1 | 0 |
| <code>DPSF&#124;C_WipeNoncePartialy</code> | 1 | 0 |
| <code>DPSF&#124;C_WipePure</code> | 1 | 0 |
| <code>DPTF&#124;A_UpdateTreasuryDispoParameters</code> | 1 | 0 |
| <code>DPTF&#124;A_WipeTreasuryDebt</code> | 1 | 0 |
| <code>DPTF&#124;C_ClearDispo</code> | 1 | 0 |
| <code>DPTF&#124;C_MultiBulkTransfer</code> | 1 | 4 |
| <code>DPTF&#124;C_WipeSlim</code> | 1 | 0 |
| <code>LIQUID&#124;A_MigrateLiquidFunds</code> | 1 | 0 |
| <code>LQD&#124;C_UnwrapStoa</code> | 1 | 0 |
| <code>LQD&#124;C_UnwrapUrStoa</code> | 1 | 3 |
| <code>LQD&#124;C_WrapUrStoa</code> | 1 | 3 |
| <code>MTX-AQP&#124;2&#124;C_SweepRevokeAnchor</code> | 1 | 6 |
| <code>ORBR&#124;A_Fuel</code> | 1 | 0 |
| <code>ORBR&#124;C_Compress</code> | 1 | 0 |
| <code>ORBR&#124;C_SublimateV2</code> | 1 | 0 |
| <code>ORBR&#124;C_WithdrawFees</code> | 1 | 0 |
| <code>SWP&#124;CC_SmartSwapWithSlippage</code> | 1 | 1 |
| <code>SWP&#124;C_AddStandardLiquidity</code> | 1 | 0 |
| <code>SWP&#124;C_Firestarter</code> | 1 | 0 |
| <code>SWP&#124;C_Fuel</code> | 1 | 1 |
| <code>SWP&#124;C_MultiSwapNoSlippage</code> | 1 | 0 |
| <code>SWP&#124;C_ToggleFeeLock</code> | 1 | 0 |
| <code>SWP&#124;C_UpdatePendingBranding</code> | 1 | 0 |
| <code>SWP&#124;C_UpgradeBranding</code> | 1 | 0 |
| <code>VST&#124;C_Awake</code> | 1 | 0 |
| <code>VST&#124;C_CreateReservationLink</code> | 1 | 0 |
| <code>VST&#124;C_Hibernate</code> | 1 | 0 |
| <code>VST&#124;C_RepurposeVested</code> | 1 | 0 |
| <code>VST&#124;C_Slumber</code> | 1 | 0 |

## Full ledger

| entrypoint | invocations | +asserts | -asserts | test files |
|---|---:|---:|---:|---|
| <code>AQP-ANK&#124;C_IssueNonFungibleAnchor</code> | 1 | 0 | 0 | `[6.2.15]_AQP-NF-ANCHOR.repl` |
| <code>AQP-ANK&#124;C_IssueNonFungibleSetAnchor</code> | 1 | 6 | 0 | `[6.2.4]_AQP-FVT-NF.repl` |
| <code>AQP-ANK&#124;C_IssueSemiFungibleAnchor</code> | 1 | 6 | 0 | `[6.2.4]_AQP-FVT-DC.repl` |
| <code>AQP-ANK&#124;C_IssueTrueFungibleAnchor</code> | 43 | 12 | 9 | `AQP-scale-sweep.repl`, `AQP-stream-tests.repl`, `[6.2.1]_AQP-ANK.repl` +3 |
| <code>AQP-ANK&#124;C_RevokeAnchor</code> | 14 | 5 | 5 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.1]_AQP-ANK.repl` |
| <code>AQP-ANK&#124;C_RevokeBoostClass</code> | 10 | 5 | 2 | `[6.2.1]_AQP-ANK.repl` |
| <code>AQP-DSA&#124;A_SetOracleValidity</code> | 3 | 6 | 0 | `dsa-capture-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;A_ToggleExternalOracle</code> | 4 | 8 | 0 | `dsa-capture-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;C_BurnRoyalty</code> | 1 | 3 | 0 | `dsa-capture-tests.repl` |
| <code>AQP-DSA&#124;C_DefineDelegationVault</code> | 7 | 8 | 3 | `dsa-agency-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +1 |
| <code>AQP-DSA&#124;C_FuelRoyalty</code> | 1 | 4 | 0 | `dsa-capture-tests.repl` |
| <code>AQP-DSA&#124;C_OpenAgency</code> | 7 | 7 | 4 | `dsa-agency-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +1 |
| <code>AQP-DSA&#124;C_OracleWrite</code> | 11 | 24 | 1 | `dsa-capture-tests.repl`, `dsa-fee-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;C_RecomputeCapture</code> | 1 | 4 | 0 | `dsa-capture-tests.repl` |
| <code>AQP-DSA&#124;C_SetAgencyFee</code> | 2 | 8 | 0 | `dsa-fee-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;C_SetOracleAuth</code> | 3 | 9 | 0 | `dsa-capture-tests.repl`, `dsa-fee-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;C_WithdrawRoyalty</code> | 3 | 5 | 1 | `dsa-capture-tests.repl` |
| <code>AQP-FVT&#124;CC_Collect</code> | 55 | 146 | 0 | `AQP-stream-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +8 |
| <code>AQP-FVT&#124;CC_Inject</code> | 39 | 155 | 0 | `dsa-capture-tests.repl`, `dsa-fee-tests.repl`, `dsa-grand-tour.repl` +9 |
| <code>AQP-FVT&#124;CC_InjectFinalize</code> | 3 | 6 | 1 | `AQP-scale-inject.repl`, `[6.2.8c]_AQP-INJECT-CC.repl` |
| <code>AQP-FVT&#124;CC_InjectStream</code> | 10 | 22 | 3 | `AQP-stream-tests.repl`, `[6.2.4]_AQP-FVT.repl` |
| <code>AQP-FVT&#124;CC_SweepBegin</code> | 2 | 13 | 0 | `AQP-scale-sweep.repl`, `[6.2.8]_AQP-SWEEP-CC.repl` |
| <code>AQP-FVT&#124;CC_SweepRevokeAnchor</code> | 0 | 0 | 0 | — |
| <code>AQP-FVT&#124;CC_UnstaleMyScores</code> | 1 | 5 | 0 | `[6.2.8b]_AQP-UNSTALE.repl` |
| <code>AQP-FVT&#124;CCp_InjectFixChunk</code> | 5 | 10 | 0 | `AQP-scale-inject.repl`, `[6.2.8c]_AQP-INJECT-CC.repl` |
| <code>AQP-FVT&#124;CCp_SweepRecomputeChunk</code> | 5 | 21 | 0 | `AQP-scale-sweep.repl`, `[6.2.8]_AQP-SWEEP-CC.repl` |
| <code>AQP-FVT&#124;CCp_UnstaleAll</code> | 3 | 8 | 1 | `[6.2.8d]_AQP-UNSTALE-ALL-CC.repl` |
| <code>AQP-FVT&#124;C_AddRewardLink</code> | 9 | 22 | 1 | `AQP-stream-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +2 |
| <code>AQP-FVT&#124;C_AddScoreEntity</code> | 9 | 16 | 1 | `AQP-stream-tests.repl`, `[6.2.4]_AQP-FVT.repl`, `[6.2.8]_AQP-STAKE-GAS.repl` |
| <code>AQP-FVT&#124;C_Control</code> | 2 | 1 | 3 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.4]_AQP-EXHAUSTIVE-FVT-ADMIN.repl` |
| <code>AQP-FVT&#124;C_Issue</code> | 11 | 24 | 1 | `AQP-stream-tests.repl`, `dsa-agency-tests.repl`, `dsa-capture-tests.repl` +5 |
| <code>AQP-FVT&#124;C_IssueMultipletFamily</code> | 1 | 0 | 0 | `[6.2.14]_AQP-MULTIPLET.repl` |
| <code>AQP-FVT&#124;C_RotateOwnership</code> | 1 | 0 | 0 | `[6.2.12]_AQP-ANCHOR-TAIL.repl` |
| <code>AQP-FVT&#124;C_SetCommonDenominator</code> | 1 | 0 | 0 | `[6.2.12]_AQP-ANCHOR-TAIL.repl` |
| <code>AQP-FVT&#124;C_SetMosaic</code> | 4 | 6 | 1 | `[6.2.4]_AQP-FVT.repl` |
| <code>AQP-FVT&#124;C_SetQualitySplit</code> | 10 | 25 | 5 | `dsa-grand-tour.repl`, `dsa-hetero-split-tests.repl` |
| <code>AQP-FVT&#124;C_SetSplitMode</code> | 6 | 6 | 2 | `[6.2.11]_AQP-SPLIT-MODE.repl`, `[6.2.9]_AQP-BOOT-FULL.repl` |
| <code>AQP-FVT&#124;C_ToggleRewardLink</code> | 2 | 5 | 0 | `[6.4]_AQP-EXHAUSTIVE-FVT-ADMIN.repl` |
| <code>AQP-FVT&#124;C_ToggleScoreEntityLink</code> | 6 | 6 | 0 | `[6.2.4]_AQP-FVT.repl`, `[6.4]_AQP-EXHAUSTIVE-FVT-ADMIN.repl` |
| <code>AQP-POOL&#124;CC_FullVacate</code> | 19 | 33 | 5 | `[6.2.4]_AQP-FVT-DC.repl`, `[6.2.4]_AQP-FVT-OF.repl`, `[6.2.5]_AQP-VCT.repl` +2 |
| <code>AQP-POOL&#124;CC_StakeNonFungibleCollectable</code> | 31 | 98 | 0 | `dsa-hetero-split-tests.repl`, `[6.2.4]_AQP-FVT-NF.repl`, `[6.2.5]_AQP-VCT.repl` +10 |
| <code>AQP-POOL&#124;CC_StakeOrtoFungible</code> | 25 | 50 | 1 | `[6.2.4]_AQP-FVT-OF.repl`, `[6.2.5]_AQP-VCT.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl` +4 |
| <code>AQP-POOL&#124;CC_StakeSemiFungibleCollectable</code> | 46 | 84 | 1 | `dsa-capture-tests.repl`, `dsa-fee-tests.repl`, `dsa-grand-tour.repl` +11 |
| <code>AQP-POOL&#124;CC_StakeTrueFungible</code> | 53 | 139 | 3 | `AQP-stream-tests.repl`, `dsa-hetero-split-tests.repl`, `[6.2.10]_AQP-NEGATIVES.repl` +11 |
| <code>AQP-POOL&#124;CC_UnstakeNonFungibleCollectable</code> | 5 | 15 | 1 | `[6.2.4]_AQP-FVT-NF.repl`, `[6.2.7]_AQP-DEB-MTX.repl`, `[6.2.8]_AQP-STAKE-GAS.repl` |
| <code>AQP-POOL&#124;CC_UnstakeOrtoFungible</code> | 6 | 18 | 1 | `[6.2.4]_AQP-FVT-OF.repl`, `[6.2.8]_AQP-STAKE-GAS.repl` |
| <code>AQP-POOL&#124;CC_UnstakeSemiFungibleCollectable</code> | 13 | 31 | 1 | `[6.2.4]_AQP-FVT-DC.repl`, `[6.2.7]_AQP-DEB-MTX.repl`, `[6.2.8]_AQP-STAKE-GAS.repl` +1 |
| <code>AQP-POOL&#124;CC_UnstakeTrueFungible</code> | 9 | 33 | 0 | `AQP-stream-tests.repl`, `[6.2.4]_AQP-FVT.repl`, `[6.2.8]_AQP-STAKE-GAS.repl` +2 |
| <code>AQP-POOL&#124;CCp_BatchDrainCollectable</code> | 4 | 10 | 0 | `[6.2.4]_AQP-FVT-NF.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-POOL&#124;CCp_BatchDrainOrtoFungible</code> | 2 | 8 | 0 | `[6.2.4]_AQP-FVT-OF.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-POOL&#124;CCp_BatchDrainTrueFungible</code> | 8 | 28 | 0 | `AQP-scale-vacate.repl`, `[6.2.5]_AQP-VCT.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-POOL&#124;CCp_BatchVacateCollectables</code> | 20 | 28 | 0 | `[6.2.4]_AQP-FVT-DC.repl`, `[6.2.4]_AQP-FVT-NF.repl`, `[6.2.5]_AQP-VCT.repl` +3 |
| <code>AQP-POOL&#124;CCp_BatchVacateOrtoFungible</code> | 10 | 12 | 0 | `[6.2.4]_AQP-FVT-OF.repl`, `[6.2.5]_AQP-VCT.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl` +2 |
| <code>AQP-POOL&#124;CCp_BatchVacateTrueFungible</code> | 17 | 31 | 2 | `[6.2.5]_AQP-VCT.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl`, `[6.2.6]_AQP-VCT-GAS.repl` +1 |
| <code>AQP-POOL&#124;C_AbortVacate</code> | 3 | 4 | 3 | `[6.2.5]_AQP-VCT.repl` |
| <code>AQP-POOL&#124;C_AddScore</code> | 106 | 105 | 5 | `AQP-scale-inject.repl`, `AQP-scale-sweep.repl`, `AQP-scale-vacate.repl` +17 |
| <code>AQP-POOL&#124;C_DisablePoolStake</code> | 2 | 1 | 4 | `[6.2.10]_AQP-NEGATIVES.repl` |
| <code>AQP-POOL&#124;C_EnablePoolStake</code> | 32 | 71 | 5 | `AQP-scale-inject.repl`, `AQP-scale-sweep.repl`, `AQP-scale-vacate.repl` +6 |
| <code>AQP-POOL&#124;C_FinalizeVacate</code> | 2 | 13 | 0 | `AQP-scale-vacate.repl`, `[6.2.5]_AQP-VCT.repl` |
| <code>AQP-POOL&#124;C_Issue</code> | 85 | 105 | 2 | `AQP-scale-inject.repl`, `AQP-scale-sweep.repl`, `AQP-scale-vacate.repl` +15 |
| <code>AQP-POOL&#124;C_RevokeScore</code> | 10 | 14 | 4 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.3]_AQP-POOL.repl` |
| <code>AQP-POOL&#124;C_SyncNonFungibleAnchors</code> | 1 | 6 | 0 | `[6.2.4]_AQP-FVT-NF.repl` |
| <code>AQP-POOL&#124;C_SyncSemiFungibleAnchors</code> | 1 | 6 | 0 | `[6.2.4]_AQP-FVT-DC.repl` |
| <code>AQP-POOL&#124;C_SyncTrueFungibleAnchors</code> | 1 | 6 | 0 | `[6.2.4]_AQP-FVT.repl` |
| <code>AQP-SCR&#124;C_CombineTripletScoreModel</code> | 6 | 15 | 3 | `dsa-agency-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +2 |
| <code>AQP-SCR&#124;C_ControlScore</code> | 4 | 6 | 0 | `[6.2.2]_AQP-SCORE.repl` |
| <code>AQP-SCR&#124;C_CreateScoreBoostClassLink</code> | 1 | 2 | 0 | `AQP-scale-sweep.repl` |
| <code>AQP-SCR&#124;C_CreateScoreBoostLink</code> | 6 | 9 | 3 | `[6.2.3]_AQP-POOL.repl`, `[6.2.7]_AQP-DEB-MTX.repl` |
| <code>AQP-SCR&#124;C_EnableDebBoost</code> | 3 | 6 | 5 | `AQP-scale-inject.repl`, `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.7]_AQP-DEB-MTX.repl` |
| <code>AQP-SCR&#124;C_IssueLiquidityScore</code> | 1 | 2 | 0 | `AQP-stream-tests.repl` |
| <code>AQP-SCR&#124;C_IssueNonFungibleScore</code> | 21 | 32 | 0 | `[6.2.4]_AQP-FVT-NF.repl`, `[6.2.5]_AQP-VCT.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl` +4 |
| <code>AQP-SCR&#124;C_IssueNonFungibleScoreDefinition</code> | 4 | 5 | 2 | `[6.2.2]_AQP-SCORE.repl`, `[6.2.4]_AQP-FVT-NF.repl`, `[6.4]_AQP-EXHAUSTIVE-DPNF.repl` |
| <code>AQP-SCR&#124;C_IssueNonFungibleSetScoreDefinition</code> | 1 | 0 | 1 | `[6.2.10]_AQP-NEGATIVES.repl` |
| <code>AQP-SCR&#124;C_IssueOrtoFungibleScore</code> | 18 | 10 | 0 | `[6.2.4]_AQP-FVT-OF.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl`, `[6.2.6]_AQP-VCT-GAS.repl` +3 |
| <code>AQP-SCR&#124;C_IssueScoreFromModel</code> | 6 | 11 | 1 | `dsa-agency-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +2 |
| <code>AQP-SCR&#124;C_IssueSemiFungibleScore</code> | 25 | 26 | 1 | `[6.2.2]_AQP-SCORE.repl`, `[6.2.3]_AQP-POOL.repl`, `[6.2.4]_AQP-FVT-DC.repl` +5 |
| <code>AQP-SCR&#124;C_IssueSemiFungibleScoreDefinition</code> | 6 | 0 | 1 | `[6.2.2]_AQP-SCORE.repl` |
| <code>AQP-SCR&#124;C_IssueSingleScoreModel</code> | 17 | 15 | 3 | `dsa-agency-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +2 |
| <code>AQP-SCR&#124;C_IssueTriplet</code> | 1 | 0 | 0 | `[6.2.13]_AQP-TRIPLET.repl` |
| <code>AQP-SCR&#124;C_IssueTrueFungibleScore</code> | 24 | 39 | 1 | `AQP-scale-inject.repl`, `AQP-scale-sweep.repl`, `AQP-scale-vacate.repl` +9 |
| <code>AQP-SCR&#124;C_RotateScoreOwnership</code> | 4 | 6 | 0 | `[6.2.2]_AQP-SCORE.repl` |
| <code>ATS&#124;A_KickStart</code> | 1 | 2 | 0 | `[6.6]_ATS.repl` |
| <code>ATS&#124;A_RemoveSecondary</code> | 2 | 1 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_AddHotRBT</code> | 2 | 2 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_AddSecondary</code> | 2 | 2 | 0 | `[6.6]_ATS.repl` |
| <code>ATS&#124;C_Brumate</code> | 1 | 0 | 0 | `[6.6]_ATS.repl` |
| <code>ATS&#124;C_Coil</code> | 29 | 3 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl` +5 |
| <code>ATS&#124;C_ColdRecovery</code> | 275 | 0 | 0 | `[6.6]_ATS.repl`, `_audit_ats_baseline.repl` |
| <code>ATS&#124;C_Constrict</code> | 1 | 6 | 0 | `ATS.repl` |
| <code>ATS&#124;C_Control</code> | 7 | 8 | 3 | `[4.0]_Sovereign-Executor.repl`, `[6.6]_ATS.repl`, `_audit_ats_baseline.repl` +1 |
| <code>ATS&#124;C_ControlColdRecoveryFees</code> | 1 | 0 | 0 | `[6.6]_ATS.repl` |
| <code>ATS&#124;C_ControlHotRecoveryFee</code> | 1 | 0 | 0 | `[6.6]_ATS.repl` |
| <code>ATS&#124;C_Cull</code> | 8 | 3 | 0 | `[6.6]_ATS.repl`, `_audit_ats_baseline.repl` |
| <code>ATS&#124;C_Curl</code> | 2 | 0 | 0 | `[6.6]_ATS.repl`, `[6.1]_DPDC.repl` |
| <code>ATS&#124;C_DirectRecovery</code> | 2 | 2 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_Fuel</code> | 5 | 2 | 0 | `[6.6]_ATS.repl` |
| <code>ATS&#124;C_HotRecovery</code> | 6 | 7 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_Issue</code> | 7 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.2]_DPTF.repl` +1 |
| <code>ATS&#124;C_KickStart</code> | 2 | 0 | 0 | `[4.0]_Sovereign-Executor.repl` |
| <code>ATS&#124;C_Redeem</code> | 2 | 5 | 0 | `[6.6]_ATS.repl` |
| <code>ATS&#124;C_RemoveSecondary</code> | 2 | 0 | 0 | `[6.6]_ATS.repl`, `_audit_ats_baseline.repl` |
| <code>ATS&#124;C_Reverse</code> | 2 | 3 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_RotateOwnership</code> | 2 | 0 | 0 | `[6.6]_ATS.repl` |
| <code>ATS&#124;C_SetColdRecoveryDuration</code> | 2 | 0 | 0 | `[4.0]_Sovereign-Executor.repl` |
| <code>ATS&#124;C_SetColdRecoveryFees</code> | 3 | 0 | 0 | `[4.0]_Sovereign-Executor.repl` |
| <code>ATS&#124;C_SetDirectRecoveryFee</code> | 2 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_SetHibernationFees</code> | 4 | 8 | 2 | `[6.6]_ATS.repl`, `_audit_ats_baseline.repl`, `_cov_draft.repl` +1 |
| <code>ATS&#124;C_SetHotRecoveryFee</code> | 2 | 4 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_SwitchColdRecovery</code> | 14 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.6]_ATS.repl` +2 |
| <code>ATS&#124;C_SwitchDirectRecovery</code> | 3 | 2 | 0 | `[4.0]_Sovereign-Executor.repl`, `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_SwitchHotRecovery</code> | 11 | 4 | 0 | `[6.6]_ATS.repl`, `_audit_ats_baseline.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_Syphon</code> | 1 | 0 | 0 | `[6.6]_ATS.repl` |
| <code>ATS&#124;C_ToggleElite</code> | 1 | 0 | 0 | `[4.0]_Sovereign-Executor.repl` |
| <code>ATS&#124;C_ToggleParameterLock</code> | 3 | 0 | 0 | `[6.6]_ATS.repl`, `_audit_ats_baseline.repl` |
| <code>ATS&#124;C_ToggleUpgrade</code> | 8 | 2 | 4 | `[6.6]_ATS.repl`, `_audit_ats_baseline.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_UpdatePendingBranding</code> | 3 | 0 | 1 | `[6.4]_Admin.repl`, `_audit_ats_baseline.repl` |
| <code>ATS&#124;C_UpdateRoyalty</code> | 10 | 5 | 4 | `[4.0]_Sovereign-Executor.repl`, `[6.6]_ATS.repl`, `_audit_ats_baseline.repl` +1 |
| <code>ATS&#124;C_UpdateSyphon</code> | 1 | 0 | 0 | `[6.6]_ATS.repl` |
| <code>ATS&#124;C_UpgradeBranding</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>ATS&#124;C_VestedCoil</code> | 1 | 0 | 0 | `[6.7]_VST.repl` |
| <code>ATS&#124;C_VestedCurl</code> | 1 | 0 | 0 | `[6.7]_VST.repl` |
| <code>ATS&#124;C_WithdrawRoyalties</code> | 2 | 2 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;HOT-RBT&#124;C_Repurpose</code> | 2 | 4 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;HOT-RBT&#124;C_UpdatePendingBranding</code> | 4 | 3 | 1 | `[6.6]_ATS.repl`, `_audit_ats_baseline.repl`, `_cov_draft.repl` |
| <code>ATS&#124;HOT-RBT&#124;C_UpgradeBranding</code> | 2 | 2 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>BRD&#124;A_Live</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>BRD&#124;A_SetFlag</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>CODEX&#124;A_RegisterCodexIdentity</code> | 2 | 3 | 0 | `[6.9]_CODEX.repl` |
| <code>CODEX&#124;C_RecordArweaveUpload</code> | 2 | 2 | 0 | `[6.9]_CODEX.repl` |
| <code>CODEX&#124;C_RegisterStoicTag</code> | 4 | 11 | 0 | `[6.9]_CODEX.repl` |
| <code>CODEX&#124;C_ReleaseStoicTag</code> | 2 | 4 | 0 | `[6.9]_CODEX.repl` |
| <code>CODEX&#124;C_RotateCodexGuard</code> | 2 | 1 | 0 | `[6.9]_CODEX.repl` |
| <code>CUSTODIANS&#124;C_Acquire</code> | 0 | 0 | 0 | — |
| <code>DALOS&#124;A_AccountCreationStoaToggle</code> | 4 | 76 | 2 | `[6.1]_Cumulator.repl`, `DALOS-ADMIN.repl` |
| <code>DALOS&#124;A_DeploySmartAccount</code> | 16 | 0 | 1 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl`, `[2.1]_DpdcCore.repl` +1 |
| <code>DALOS&#124;A_DeployStandardAccount</code> | 12 | 1 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl`, `[5.3]_Launchpad.repl` +2 |
| <code>DALOS&#124;A_IgnisToggle</code> | 2 | 0 | 0 | `[4.0]_Sovereign-Executor.repl` |
| <code>DALOS&#124;A_MigrateLiquidFunds</code> | 0 | 0 | 0 | — |
| <code>DALOS&#124;A_SetAutoFueling</code> | 2 | 4 | 0 | `[6.12]_DALOS-ADMIN.repl`, `[6.4]_Admin.repl` |
| <code>DALOS&#124;A_SetIgnisSourcePrice</code> | 2 | 4 | 0 | `[6.12]_DALOS-ADMIN.repl`, `[6.4]_Admin.repl` |
| <code>DALOS&#124;A_ToggleGAP</code> | 6 | 9 | 0 | `[6.12]_DALOS-ADMIN.repl`, `[6.3]_SWP.repl`, `DALOS-ADMIN.repl` |
| <code>DALOS&#124;A_ToggleOAPU</code> | 1 | 4 | 0 | `[6.12]_DALOS-ADMIN.repl` |
| <code>DALOS&#124;A_UpdatePublicKey</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>DALOS&#124;A_UpdateUsagePrice</code> | 32 | 5 | 0 | `[4.0]_Sovereign-Executor.repl`, `DALOS-ADMIN.repl` |
| <code>DALOS&#124;C_ControlSmartAccount</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>DALOS&#124;C_DeploySmartAccount</code> | 4 | 0 | 1 | `[6.3]_SWP.repl`, `_scratch_dalos_m2_deploysmart_capsplit.repl` |
| <code>DALOS&#124;C_DeployStandardAccount</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>DALOS&#124;C_RotateGovernor</code> | 12 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl`, `[4.0]_Sovereign-Executor.repl` +2 |
| <code>DALOS&#124;C_RotateGuard</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>DALOS&#124;C_RotateSovereign</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>DALOS&#124;C_RotateStoa</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>DALOS&#124;C_UpdateEliteAccount</code> | 1 | 11 | 0 | `[6.11]_INFO.repl` |
| <code>DALOS&#124;C_UpdateEliteAccountSquared</code> | 1 | 11 | 0 | `[6.11]_INFO.repl` |
| <code>DEMIPAD&#124;C_Deposit</code> | 0 | 0 | 0 | — |
| <code>DEMIPAD&#124;C_FuelNonFungible</code> | 1 | 1 | 0 | `[6.1.5]_DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_FuelOrtoFungible</code> | 1 | 0 | 0 | `[6.1.5]_DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_FuelSemiFungible</code> | 1 | 0 | 0 | `[6.1.5]_DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_FuelTrueFungible</code> | 1 | 0 | 0 | `[6.1.5]_DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_RetrieveNonFungible</code> | 1 | 1 | 0 | `[6.1.5]_DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_RetrieveOrtoFungible</code> | 1 | 0 | 0 | `[6.1.5]_DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_RetrieveSemiFungible</code> | 1 | 0 | 0 | `[6.1.5]_DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_RetrieveTrueFungible</code> | 1 | 0 | 0 | `[6.1.5]_DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_Withdraw</code> | 0 | 0 | 0 | — |
| <code>DPDC&#124;C_BulkTransfer</code> | 1 | 4 | 0 | `DPDC.repl` |
| <code>DPDC&#124;C_MultiTransfer</code> | 2 | 5 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_Break</code> | 2 | 6 | 0 | `[6.1.3]_DPDC-S.repl` |
| <code>DPNF&#124;C_BulkTransfer</code> | 4 | 4 | 0 | `[6.1.4]_DPDC-NF.repl`, `[6.1.8]_DPDC-HYDRA-WIPE.repl` |
| <code>DPNF&#124;C_Burn</code> | 1 | 1 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_Control</code> | 1 | 0 | 1 | `_verify_finding_DPDC-R_13H_unfreeze_release_valve.repl` |
| <code>DPNF&#124;C_Create</code> | 37 | 34 | 19 | `_verify_finding_DPDC-C_24M_fragment_credit_amount.repl`, `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `_verify_finding_DPDC-S_15H_multiplier_bound.repl` +11 |
| <code>DPNF&#124;C_DefineCompositeSet</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_DefineHybridSet</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_DefinePrimordialSet</code> | 12 | 4 | 7 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `_verify_finding_DPDC-S_15H_multiplier_bound.repl`, `[6.1.3]_DPDC-S.repl` +1 |
| <code>DPNF&#124;C_EnableNonceFragmentation</code> | 2 | 3 | 4 | `_verify_finding_DPDC-C_24M_fragment_credit_amount.repl`, `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_EnableSetClassFragmentation</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_Issue</code> | 16 | 5 | 21 | `_verify_finding_DPDC-C_24M_fragment_credit_amount.repl`, `_verify_finding_DPDC-I_33M_makeid_same_block_collision.repl`, `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl` +8 |
| <code>DPNF&#124;C_Make</code> | 41 | 6 | 2 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[5.2]_PopulateBloodshed.repl`, `[6.1.3]_DPDC-S.repl` |
| <code>DPNF&#124;C_MakeFragments</code> | 3 | 3 | 4 | `_verify_finding_DPDC-C_24M_fragment_credit_amount.repl`, `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_MergeFragments</code> | 1 | 1 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_MoveCreateRole</code> | 2 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_MoveRecreateRole</code> | 2 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_MoveSetUriRole</code> | 2 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_RemoveNonceScore</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_RemoveSetNonceScore</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_RenameSet</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_Repurpose</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPNF&#124;C_RepurposeFragments</code> | 1 | 1 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_Respawn</code> | 1 | 1 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_ToggleBurnRole</code> | 3 | 1 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_ToggleExemptionRole</code> | 2 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_ToggleFreezeAccount</code> | 9 | 4 | 2 | `_verify_finding_DPDC-R_13H_unfreeze_release_valve.repl`, `[6.1.4]_DPDC-NF.repl`, `[6.1.8]_DPDC-HYDRA-WIPE.repl` |
| <code>DPNF&#124;C_ToggleModifyCreatorRole</code> | 2 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_ToggleModifyRoyaltiesRole</code> | 2 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_TogglePause</code> | 4 | 5 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPNF.repl` |
| <code>DPNF&#124;C_ToggleSet</code> | 2 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_ToggleTransferRole</code> | 2 | 7 | 0 | `DPNF.repl` |
| <code>DPNF&#124;C_ToggleUpdateRole</code> | 6 | 3 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_TransferNonce</code> | 8 | 42 | 0 | `dsa-hetero-split-tests.repl`, `[6.1]_DPDC.repl`, `[6.4]_AQP-EXHAUSTIVE-ANK-LP.repl` +5 |
| <code>DPNF&#124;C_TransferNonces</code> | 20 | 28 | 0 | `[5.1]_PopulateNosferatu.repl`, `[6.2.4]_AQP-FVT-NF.repl`, `[6.2.5]_AQP-VCT.repl` +3 |
| <code>DPNF&#124;C_UpdateNonce</code> | 1 | 7 | 0 | `DPNF.repl` |
| <code>DPNF&#124;C_UpdateNonceDescription</code> | 3 | 7 | 8 | `_verify_finding_DPDC_12Hb_metadata_caps.repl`, `DPNF.repl` |
| <code>DPNF&#124;C_UpdateNonceIgnisRoyalty</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpdateNonceMetaData</code> | 3 | 0 | 10 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `_verify_finding_DPDC_12Hb_metadata_caps.repl` |
| <code>DPNF&#124;C_UpdateNonceName</code> | 5 | 7 | 10 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `_verify_finding_DPDC_12Hb_metadata_caps.repl`, `DPNF.repl` |
| <code>DPNF&#124;C_UpdateNonceRoyalty</code> | 1 | 7 | 0 | `DPNF.repl` |
| <code>DPNF&#124;C_UpdateNonceScore</code> | 1 | 7 | 0 | `DPNF.repl` |
| <code>DPNF&#124;C_UpdateNonceURI</code> | 3 | 0 | 8 | `_verify_finding_DPDC_12Hb_metadata_caps.repl` |
| <code>DPNF&#124;C_UpdateNonces</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpdatePendingBranding</code> | 1 | 5 | 0 | `DPDC.repl` |
| <code>DPNF&#124;C_UpdateSetNonce</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpdateSetNonceDescription</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpdateSetNonceIgnisRoyalty</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpdateSetNonceMetaData</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpdateSetNonceName</code> | 2 | 0 | 2 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpdateSetNonceRoyalty</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpdateSetNonceScore</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpdateSetNonceURI</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpdateSetNonces</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_UpgradeBranding</code> | 1 | 0 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_WipeClean</code> | 1 | 2 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_WipeDirty</code> | 1 | 2 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_WipeHeavy</code> | 1 | 2 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_WipeNonce</code> | 1 | 2 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;C_WipePure</code> | 1 | 2 | 0 | `[6.1.4]_DPDC-NF.repl` |
| <code>DPNF&#124;Cp_WipeSlice</code> | 5 | 7 | 2 | `[6.1.8]_DPDC-HYDRA-WIPE.repl` |
| <code>DPOF&#124;A_DeployAccount</code> | 2 | 0 | 0 | `[6.1.6]_DPOF.repl` |
| <code>DPOF&#124;C_AddQuantity</code> | 2 | 2 | 0 | `[6.5]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_BulkTransfer</code> | 1 | 0 | 0 | `[6.5]_DPOF.repl` |
| <code>DPOF&#124;C_Burn</code> | 1 | 0 | 0 | `[6.5]_DPOF.repl` |
| <code>DPOF&#124;C_Control</code> | 5 | 8 | 0 | `[6.5]_DPOF.repl`, `[6.1.6]_DPOF.repl`, `_scratch_dpof_c3_noncedupe.repl` +2 |
| <code>DPOF&#124;C_DeployAccount</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>DPOF&#124;C_Issue</code> | 9 | 0 | 0 | `[5.1]_Aoz+.repl`, `[6.5]_DPOF.repl`, `[6.6]_ATS.repl` +6 |
| <code>DPOF&#124;C_Mint</code> | 25 | 19 | 1 | `[6.5]_DPOF.repl`, `[6.1.5]_DEMIPAD.repl`, `[6.2.4]_AQP-FVT-OF.repl` +8 |
| <code>DPOF&#124;C_MoveCreateRole</code> | 3 | 6 | 0 | `[6.5]_DPOF.repl`, `_scratch_dpof_c2_moverole.repl` |
| <code>DPOF&#124;C_RotateOwnership</code> | 1 | 0 | 0 | `[6.5]_DPOF.repl` |
| <code>DPOF&#124;C_ToggleAddQuantityRole</code> | 10 | 13 | 1 | `[6.5]_DPOF.repl`, `[6.1.5]_DEMIPAD.repl`, `[6.2.5]_AQP-VCT.repl` +5 |
| <code>DPOF&#124;C_ToggleBurnRole</code> | 1 | 0 | 0 | `[6.5]_DPOF.repl` |
| <code>DPOF&#124;C_ToggleFreezeAccount</code> | 31 | 42 | 2 | `[6.5]_DPOF.repl`, `[6.1.6]_DPOF.repl`, `[6.2.4]_AQP-FVT-OF.repl` +4 |
| <code>DPOF&#124;C_TogglePause</code> | 4 | 5 | 0 | `[6.5]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_ToggleTransferRole</code> | 2 | 0 | 0 | `[6.3]_SWP.repl`, `[6.5]_DPOF.repl` |
| <code>DPOF&#124;C_Transfer</code> | 20 | 8 | 1 | `[6.5]_DPOF.repl`, `[6.2.5]_AQP-VCT.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl` +4 |
| <code>DPOF&#124;C_Transmit</code> | 6 | 13 | 2 | `[6.1.6]_DPOF.repl`, `_scratch_dpof_c3_noncedupe.repl`, `_scratch_dpof_transmit_metadata_bug.repl` |
| <code>DPOF&#124;C_UpdatePendingBranding</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>DPOF&#124;C_UpgradeBranding</code> | 1 | 0 | 0 | `[6.1.6]_DPOF.repl` |
| <code>DPOF&#124;C_WipeClean</code> | 1 | 0 | 0 | `[6.1.6]_DPOF.repl` |
| <code>DPOF&#124;C_WipeHeavy</code> | 1 | 0 | 0 | `[6.1.6]_DPOF.repl` |
| <code>DPOF&#124;C_WipePure</code> | 1 | 0 | 0 | `[6.1.6]_DPOF.repl` |
| <code>DPOF&#124;C_WipeSlim</code> | 1 | 0 | 0 | `[6.1.6]_DPOF.repl` |
| <code>DPOF&#124;Cp_WipeSlice</code> | 4 | 10 | 1 | `[6.1.6]_DPOF.repl` |
| <code>DPSF&#124;C_AddQuantity</code> | 3 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_Break</code> | 11 | 23 | 0 | `[6.1.3]_DPDC-S.repl`, `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_BulkTransfer</code> | 2 | 4 | 1 | `[6.1.7]_DPSF-UPDATES.repl`, `[6.1.8]_DPDC-HYDRA-WIPE.repl` |
| <code>DPSF&#124;C_Burn</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_Control</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_Create</code> | 11 | 7 | 1 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[4.0]_Sovereign-Executor.repl`, `[6.1.2]_DPDC-FRAGMENTS.repl` +3 |
| <code>DPSF&#124;C_DefineCompositeSet</code> | 5 | 4 | 6 | `_verify_finding_DPDC-F-S_47L-51L_empty_definition_guards.repl`, `_verify_finding_DPDC-UDC-S_38M_sentinel_unreachable.repl`, `[4.0]_Sovereign-Executor.repl` +1 |
| <code>DPSF&#124;C_DefineHybridSet</code> | 3 | 6 | 0 | `_verify_finding_DPDC-S_32M_hybrid_constituent_order.repl`, `[6.1.3]_DPDC-S.repl` |
| <code>DPSF&#124;C_DefinePrimordialSet</code> | 13 | 4 | 8 | `_verify_finding_DPDC-F-S_47L-51L_empty_definition_guards.repl`, `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `_verify_finding_DPDC-S_31M_primordial_element_bounds.repl` +3 |
| <code>DPSF&#124;C_EnableNonceFragmentation</code> | 6 | 5 | 1 | `[4.0]_Sovereign-Executor.repl`, `[6.1.2]_DPDC-FRAGMENTS.repl`, `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_EnableSetClassFragmentation</code> | 5 | 4 | 2 | `_verify_finding_DPDC-S_30M_enable-frag-active-gate.repl`, `[6.1.3]_DPDC-S.repl` |
| <code>DPSF&#124;C_Issue</code> | 14 | 3 | 1 | `_verify_finding_DPDC-I_33M_makeid_same_block_collision.repl`, `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[4.0]_Sovereign-Executor.repl` +3 |
| <code>DPSF&#124;C_IssueCompany</code> | 3 | 6 | 0 | `[4.0]_Sovereign-Executor.repl`, `[6.1.1]_EQUITY.repl` |
| <code>DPSF&#124;C_Make</code> | 13 | 23 | 0 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[6.1.3]_DPDC-S.repl`, `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_MakeFragments</code> | 13 | 22 | 2 | `dsa-capture-tests.repl`, `dsa-fee-tests.repl`, `dsa-grand-tour.repl` +2 |
| <code>DPSF&#124;C_MergeFragments</code> | 3 | 5 | 0 | `[6.1.2]_DPDC-FRAGMENTS.repl`, `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_MorphEquity</code> | 16 | 10 | 5 | `[6.1.1]_EQUITY.repl`, `[6.1]_DPDC.repl`, `[6.4]_AQP-EXHAUSTIVE-PREP.repl` |
| <code>DPSF&#124;C_MoveCreateRole</code> | 2 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_MoveRecreateRole</code> | 2 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_MoveSetUriRole</code> | 2 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_RemoveNonceScore</code> | 1 | 0 | 1 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_RemoveSetNonceScore</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_RenameSet</code> | 2 | 4 | 1 | `[6.1.3]_DPDC-S.repl` |
| <code>DPSF&#124;C_Repurpose</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_RepurposeFragments</code> | 5 | 4 | 6 | `_verify_finding_DPDC-F-S_47L-51L_empty_definition_guards.repl`, `[6.1.2]_DPDC-FRAGMENTS.repl` |
| <code>DPSF&#124;C_ToggleAddQuantityRole</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_ToggleBurnRole</code> | 2 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_ToggleExemptionRole</code> | 2 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_ToggleFreezeAccount</code> | 11 | 4 | 1 | `[6.1.8]_DPDC-HYDRA-WIPE.repl`, `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_ToggleModifyCreatorRole</code> | 2 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_ToggleModifyRoyaltiesRole</code> | 2 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_TogglePause</code> | 2 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_ToggleSet</code> | 6 | 4 | 2 | `_verify_finding_DPDC-S_30M_enable-frag-active-gate.repl`, `[6.1.3]_DPDC-S.repl` |
| <code>DPSF&#124;C_ToggleTransferRole</code> | 2 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_ToggleUpdateRole</code> | 2 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_TransferNonce</code> | 10 | 17 | 0 | `dsa-fee-tests.repl`, `dsa-grand-tour.repl`, `[6.1.2]_DPDC-FRAGMENTS.repl` +3 |
| <code>DPSF&#124;C_TransferNonces</code> | 15 | 15 | 0 | `[6.1]_DPDC.repl`, `[6.2.4]_AQP-FVT-DC.repl`, `[6.2.5]_AQP-VCT.repl` +3 |
| <code>DPSF&#124;C_UpdateNonce</code> | 1 | 5 | 0 | `DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceDescription</code> | 1 | 0 | 1 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceIgnisRoyalty</code> | 1 | 0 | 1 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceMetaData</code> | 1 | 0 | 1 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceName</code> | 2 | 0 | 1 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceRoyalty</code> | 1 | 0 | 1 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceScore</code> | 2 | 0 | 1 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceURI</code> | 1 | 0 | 1 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonces</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdatePendingBranding</code> | 1 | 5 | 0 | `DPDC.repl` |
| <code>DPSF&#124;C_UpdateSetNonce</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdateSetNonceDescription</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdateSetNonceIgnisRoyalty</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdateSetNonceMetaData</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdateSetNonceName</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdateSetNonceRoyalty</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdateSetNonceScore</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdateSetNonceURI</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdateSetNonces</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpgradeBranding</code> | 1 | 0 | 0 | `[6.1.7]_DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_WipeClean</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_WipeDirty</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_WipeHeavy</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_WipeNonce</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_WipeNoncePartialy</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;C_WipePure</code> | 1 | 0 | 0 | `[6.1]_DPDC.repl` |
| <code>DPSF&#124;Cp_WipeSlice</code> | 3 | 4 | 1 | `[6.1.8]_DPDC-HYDRA-WIPE.repl` |
| <code>DPTF&#124;A_DeployAccount</code> | 10 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl` |
| <code>DPTF&#124;A_UpdateTreasuryDispoParameters</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>DPTF&#124;A_WipeTreasuryDebt</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>DPTF&#124;A_WipeTreasuryDebtPartial</code> | 2 | 0 | 1 | `[6.3]_SWP.repl`, `_scratch_ts01a_n3_treasury_gate_check.repl` |
| <code>DPTF&#124;C_BulkTransfer</code> | 3 | 0 | 0 | `[6.2]_DPTF.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl`, `[6.2.6]_AQP-VCT-GAS.repl` |
| <code>DPTF&#124;C_Burn</code> | 4 | 4 | 1 | `[6.4]_Admin.repl`, `[6.5]_DPOF.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_ClearDispo</code> | 1 | 0 | 0 | `[6.2]_DPTF.repl` |
| <code>DPTF&#124;C_Control</code> | 3 | 4 | 0 | `[6.4]_Admin.repl`, `[6.5]_DPOF.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_DeployAccount</code> | 2 | 0 | 1 | `[6.3]_SWP.repl`, `_scratch_tft_n2_deployaccount_ownership.repl` |
| <code>DPTF&#124;C_DonateFees</code> | 5 | 0 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.2]_DPTF.repl`, `[6.3]_SWP.repl` +2 |
| <code>DPTF&#124;C_Issue</code> | 24 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl` +7 |
| <code>DPTF&#124;C_Mint</code> | 98 | 7 | 1 | `AQP-scale-inject.repl`, `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl` +7 |
| <code>DPTF&#124;C_MultiBulkTransfer</code> | 1 | 4 | 0 | `DPTF.repl` |
| <code>DPTF&#124;C_MultiTransfer</code> | 4 | 0 | 0 | `[6.2]_DPTF.repl`, `[6.3]_SWP.repl` |
| <code>DPTF&#124;C_ResetFeeTarget</code> | 3 | 6 | 0 | `[6.4]_Admin.repl`, `[6.5]_DPOF.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_RotateOwnership</code> | 3 | 4 | 0 | `[6.4]_Admin.repl`, `[6.5]_DPOF.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_SetFee</code> | 26 | 6 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl` +3 |
| <code>DPTF&#124;C_SetFeeTarget</code> | 3 | 6 | 0 | `[4.0]_Sovereign-Executor.repl`, `[6.3]_SWP.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_SetMinMove</code> | 3 | 5 | 1 | `[4.0]_Sovereign-Executor.repl`, `[6.7]_VST.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_ToggleBurnRole</code> | 10 | 4 | 1 | `[4.0]_Sovereign-Executor.repl`, `[6.4]_Admin.repl`, `[6.5]_DPOF.repl` +3 |
| <code>DPTF&#124;C_ToggleFee</code> | 28 | 6 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl` +4 |
| <code>DPTF&#124;C_ToggleFeeExemptionRole</code> | 3 | 5 | 1 | `[4.0]_Sovereign-Executor.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_ToggleFeeLock</code> | 25 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl` +2 |
| <code>DPTF&#124;C_ToggleFreezeAccount</code> | 6 | 0 | 0 | `[6.4]_Admin.repl`, `[6.5]_DPOF.repl` |
| <code>DPTF&#124;C_ToggleMintRole</code> | 12 | 4 | 1 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl`, `[6.7]_VST.repl` +3 |
| <code>DPTF&#124;C_TogglePause</code> | 4 | 5 | 1 | `[6.4]_Admin.repl`, `[6.5]_DPOF.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_ToggleReservation</code> | 2 | 0 | 0 | `[6.3]_SWP.repl`, `vst-harness.repl` |
| <code>DPTF&#124;C_ToggleTransferRole</code> | 3 | 9 | 1 | `[6.3]_SWP.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_Transfer</code> | 60 | 60 | 0 | `AQP-scale-inject.repl`, `AQP-stream-tests.repl`, `[4.0]_Sovereign-Executor.repl` +21 |
| <code>DPTF&#124;C_Transmute</code> | 6 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[6.2]_DPTF.repl`, `[6.8]_Dispenser.repl` |
| <code>DPTF&#124;C_UpdatePendingBranding</code> | 2 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>DPTF&#124;C_UpgradeBranding</code> | 2 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>DPTF&#124;C_Wipe</code> | 2 | 0 | 0 | `[6.4]_Admin.repl`, `[6.5]_DPOF.repl` |
| <code>DPTF&#124;C_WipeSlim</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>KPAY&#124;C_BuyStoicPay</code> | 2 | 2 | 0 | `launchpad-groundtruth.repl` |
| <code>LIQUID&#124;A_MigrateLiquidFunds</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>LQD&#124;C_UnwrapStoa</code> | 1 | 0 | 0 | `[6.7]_VST.repl` |
| <code>LQD&#124;C_UnwrapUrStoa</code> | 1 | 3 | 0 | `[4.0]_Sovereign-Executor.repl` |
| <code>LQD&#124;C_WrapStoa</code> | 4 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>LQD&#124;C_WrapUrStoa</code> | 1 | 3 | 0 | `[4.0]_Sovereign-Executor.repl` |
| <code>MTX-AQP&#124;2&#124;C_Inject</code> | 2 | 2 | 0 | `[6.2.7]_AQP-DEB-MTX.repl` |
| <code>MTX-AQP&#124;2&#124;C_SweepRevokeAnchor</code> | 1 | 6 | 0 | `[6.2.7]_AQP-DEB-MTX.repl` |
| <code>ORBR&#124;A_Fuel</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>ORBR&#124;C_Compress</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>ORBR&#124;C_Sublimate</code> | 7 | 0 | 1 | `[4.0]_Sovereign-Executor.repl`, `[6.2]_DPTF.repl`, `[6.3]_SWP.repl` |
| <code>ORBR&#124;C_SublimateV2</code> | 1 | 0 | 0 | `[4.0]_Sovereign-Executor.repl` |
| <code>ORBR&#124;C_WithdrawFees</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>P&#124;A_Add</code> | 0 | 0 | 0 | — |
| <code>P&#124;A_AddIMP</code> | 3 | 8 | 7 | `[2.1]_Dalos.repl`, `[5.3]_Launchpad.repl`, `[6.3]_STOAICO.repl` |
| <code>P&#124;A_Define</code> | 58 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl`, `[4.0]_Sovereign-Executor.repl` +2 |
| <code>PYTHIA&#124;A_Flush</code> | 56 | 14 | 2 | `[6.10]_PYTHIA-flush-gas-probe.repl`, `[6.10b]_PYTHIA-ledger-v2.repl` |
| <code>PYTHIA&#124;A_Link</code> | 6 | 13 | 0 | `[6.10]_PYTHIA.repl` |
| <code>PYTHIA&#124;A_RevokeLink</code> | 0 | 0 | 0 | — |
| <code>PYTHIA&#124;A_UpdateDeployPrice</code> | 2 | 0 | 0 | `_scratch_pythia_h12_price_wiring.repl` |
| <code>PYTHIA&#124;A_UpdateRenamePrice</code> | 2 | 0 | 0 | `_scratch_pythia_h12_price_wiring.repl` |
| <code>PYTHIA&#124;C_DeployApiKey</code> | 8 | 11 | 0 | `[6.10]_PYTHIA.repl` |
| <code>PYTHIA&#124;C_Link</code> | 2 | 6 | 0 | `[6.10]_PYTHIA.repl` |
| <code>PYTHIA&#124;C_RevokeLink</code> | 2 | 5 | 0 | `[6.10]_PYTHIA.repl` |
| <code>PYTHIA&#124;C_UpdateDualConsumerLane</code> | 2 | 3 | 0 | `[6.10]_PYTHIA.repl` |
| <code>SNAKES&#124;C_Acquire</code> | 0 | 0 | 0 | — |
| <code>SPARK&#124;C_BuySparks</code> | 2 | 2 | 0 | `launchpad-groundtruth.repl` |
| <code>SPARK&#124;C_RedemAllSparks</code> | 0 | 0 | 0 | — |
| <code>SPARK&#124;C_RedemFewSparks</code> | 0 | 0 | 0 | — |
| <code>STOAICO&#124;C_Collect</code> | 0 | 0 | 0 | — |
| <code>SWP&#124;A_DefinePrimordialPool</code> | 3 | 0 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;A_RotatePrincipal</code> | 5 | 11 | 6 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl` |
| <code>SWP&#124;A_ToggleAsymetricLiquidityAddition</code> | 2 | 0 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;A_UpdateLimit</code> | 2 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>SWP&#124;A_UpdateLiquidBoost</code> | 21 | 10 | 4 | `[6.3]_SWP.repl`, `[6.4]_Admin.repl` |
| <code>SWP&#124;A_UpdatePrincipal</code> | 14 | 6 | 4 | `[4.0]_Sovereign-Executor.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;CC_SmartSwapNoSlippage</code> | 8 | 11 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;CC_SmartSwapWithSlippage</code> | 1 | 1 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_AddFrozenLiquidity</code> | 2 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_AddGlacialLiquidity</code> | 2 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_AddIcedLiquidity</code> | 3 | 0 | 1 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_AddLiquidity</code> | 13 | 50 | 1 | `dsa-hetero-split-tests.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` +4 |
| <code>SWP&#124;C_AddSleepingLiquidity</code> | 3 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_AddStandardLiquidity</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_ChangeOwnership</code> | 2 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_EnableFrozenLP</code> | 4 | 4 | 2 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_EnableSleepingLP</code> | 5 | 10 | 2 | `[6.3]_SWP.repl`, `[6.4]_AQP-TRIPLET-COLLECT.repl` |
| <code>SWP&#124;C_Firestarter</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_Fuel</code> | 1 | 1 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_IssueStable</code> | 25 | 0 | 1 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_IssueStablePool</code> | 4 | 0 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_IssueStandard</code> | 20 | 5 | 4 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_IssueStandardPool</code> | 2 | 0 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_IssueWeighted</code> | 9 | 0 | 3 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_IssueWeightedPool</code> | 2 | 0 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_ModifyCanChangeOwner</code> | 2 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_ModifyWeights</code> | 6 | 0 | 4 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_MultiSwapNoSlippage</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_MultiSwapWithSlippage</code> | 2 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_RemoveLiquidity</code> | 4 | 0 | 1 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_SingleSwapNoSlippage</code> | 2 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_SingleSwapWithSlippage</code> | 3 | 2 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_SmartSwapNoSlippage</code> | 8 | 8 | 4 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_SmartSwapWithSlippage</code> | 0 | 0 | 0 | — |
| <code>SWP&#124;C_ToggleAddLiquidity</code> | 22 | 0 | 1 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_ToggleFeeLock</code> | 1 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>SWP&#124;C_ToggleSwapCapability</code> | 42 | 6 | 4 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_UpdateAmplifier</code> | 10 | 0 | 4 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_UpdateFee</code> | 19 | 0 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_UpdatePendingBranding</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>SWP&#124;C_UpdatePendingBrandingLPs</code> | 4 | 3 | 0 | `[6.4]_Admin.repl` |
| <code>SWP&#124;C_UpdateSpecialFeeTargets</code> | 19 | 0 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_UpgradeBranding</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>SWP&#124;C_UpgradeBrandingLPs</code> | 2 | 3 | 0 | `[6.4]_Admin.repl` |
| <code>VST&#124;C_Awake</code> | 1 | 0 | 0 | `vst-harness.repl` |
| <code>VST&#124;C_CreateFrozenLink</code> | 4 | 3 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.3]_Launchpad.repl`, `VST.repl` +1 |
| <code>VST&#124;C_CreateHibernatingLink</code> | 5 | 6 | 0 | `[4.0]_Sovereign-Executor.repl`, `_scratch_dpof_h7_hibernation_immutability.repl`, `ATS.repl` +1 |
| <code>VST&#124;C_CreateReservationLink</code> | 1 | 0 | 0 | `[4.0]_Sovereign-Executor.repl` |
| <code>VST&#124;C_CreateSleepingLink</code> | 3 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[6.3]_SWP.repl`, `vst-harness.repl` |
| <code>VST&#124;C_CreateVestingLink</code> | 3 | 0 | 0 | `[4.0]_Sovereign-Executor.repl` |
| <code>VST&#124;C_Freeze</code> | 3 | 4 | 0 | `[6.3]_SWP.repl`, `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Hibernate</code> | 1 | 0 | 0 | `vst-harness.repl` |
| <code>VST&#124;C_Merge</code> | 2 | 0 | 0 | `[6.3]_SWP.repl` |
| <code>VST&#124;C_RepurposeFrozen</code> | 2 | 0 | 0 | `[6.3]_SWP.repl`, `vst-harness.repl` |
| <code>VST&#124;C_RepurposeHibernating</code> | 0 | 0 | 0 | — |
| <code>VST&#124;C_RepurposeMerge</code> | 3 | 0 | 0 | `[6.3]_SWP.repl`, `vst-harness.repl` |
| <code>VST&#124;C_RepurposeReserved</code> | 2 | 0 | 0 | `[6.3]_SWP.repl`, `vst-harness.repl` |
| <code>VST&#124;C_RepurposeSleeping</code> | 2 | 0 | 0 | `[6.3]_SWP.repl`, `vst-harness.repl` |
| <code>VST&#124;C_RepurposeSlumber</code> | 0 | 0 | 0 | — |
| <code>VST&#124;C_RepurposeVested</code> | 1 | 0 | 0 | `vst-harness.repl` |
| <code>VST&#124;C_Reserve</code> | 2 | 0 | 0 | `[6.3]_SWP.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Sleep</code> | 74 | 6 | 0 | `[6.3]_SWP.repl`, `[6.7]_VST.repl`, `[6.4]_AQP-TRIPLET-COLLECT.repl` +1 |
| <code>VST&#124;C_Slumber</code> | 1 | 0 | 0 | `vst-harness.repl` |
| <code>VST&#124;C_ToggleTransferRoleFrozenDPTF</code> | 2 | 0 | 0 | `[6.7]_VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_ToggleTransferRoleHibernatingDPOF</code> | 0 | 0 | 0 | — |
| <code>VST&#124;C_ToggleTransferRoleReservedDPTF</code> | 2 | 0 | 0 | `[6.7]_VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_ToggleTransferRoleSleepingDPOF</code> | 3 | 6 | 0 | `[6.7]_VST.repl`, `[6.4]_AQP-TRIPLET-COLLECT.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Unreserve</code> | 2 | 0 | 0 | `[6.3]_SWP.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Unsleep</code> | 3 | 0 | 0 | `[6.7]_VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Unvest</code> | 4 | 0 | 1 | `[6.3]_SWP.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Vest</code> | 3 | 0 | 0 | `[6.3]_SWP.repl`, `vst-harness.repl` |

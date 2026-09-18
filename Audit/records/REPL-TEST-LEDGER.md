# REPL TEST LEDGER — what is tested, how often, and how

**GENERATED — do not edit.** `python3 REPL/_test_ledger.py > Audit/records/REPL-TEST-LEDGER.md`

This is the evidence base for the audit and documentation papers: every client entrypoint Ouronet exposes, how many times each is exercised, how many positive and adversarial assertions surround it, and which test files touch it.

> **How to read the assertion columns.** Assertions are attributed by TRANSACTION BLOCK: an assertion is credited to every op invoked in the same `(begin-tx … commit-tx)` or `(begin-tx … rollback-tx)` block. A block that calls three ops and asserts once credits all three. So `+asserts` / `-asserts` measure how well an op's *neighbourhood* is asserted — they are NOT proof that an assertion targets that op. **Invocation counts are exact.** Treat a high invocation count with zero `-asserts` as an op that is exercised but never adversarially probed.

## Summary

| metric | value |
|---|---:|
| client entrypoints (the auditable contract) | 448 |
| exercised at least once | 448 (100%) |
| **never exercised** | **0** |
| **exercised by a file the GATE RUNS** | **448 (100%)** |
| exercised ONLY in an ungated file (= not protected) | **0** |
| exercised but with NO adversarial assertion in any of its blocks | **170** |
| total invocations across the suite | 4205 |

## Exercised but never adversarially probed — G2 gap

Called by at least one test, but no `expect-failure` appears in any block that calls them. Every one of these needs a rejection test per RULE 3.

| entrypoint | invocations | +asserts |
|---|---:|---:|
| <code>P&#124;A_Define</code> | 58 | 0 |
| <code>AQP-FVT&#124;CC_Inject</code> | 43 | 171 |
| <code>DPNF&#124;C_TransferNonces</code> | 21 | 34 |
| <code>AQP-SCR&#124;C_IssueOrtoFungibleScore</code> | 20 | 13 |
| <code>ATS&#124;C_SwitchColdRecovery</code> | 18 | 12 |
| <code>DPSF&#124;C_TransferNonces</code> | 16 | 21 |
| <code>DPSF&#124;C_TransferNonce</code> | 14 | 39 |
| <code>DALOS&#124;A_DeploySmartAccount</code> | 12 | 0 |
| <code>DPNF&#124;C_EnableSetClassFragmentation</code> | 12 | 22 |
| <code>DALOS&#124;A_DeployStandardAccount</code> | 11 | 1 |
| <code>ATS&#124;C_SwitchDirectRecovery</code> | 10 | 16 |
| <code>AQP-POOL&#124;CC_UnstakeTrueFungible</code> | 9 | 40 |
| <code>ORBR&#124;C_Sublimate</code> | 9 | 8 |
| <code>SWP&#124;CC_SmartSwapNoSlippage</code> | 9 | 13 |
| <code>ATS&#124;C_Cull</code> | 7 | 3 |
| <code>DPNF&#124;C_ToggleUpdateRole</code> | 7 | 5 |
| <code>DPTF&#124;C_Transmute</code> | 7 | 3 |
| <code>LQD&#124;C_WrapStoa</code> | 6 | 7 |
| <code>SWP&#124;C_SingleSwapWithSlippage</code> | 6 | 10 |
| <code>DPTF&#124;C_DonateFees</code> | 5 | 2 |
| <code>SWP&#124;CC_SmartSwapWithSlippage</code> | 5 | 8 |
| <code>SWP&#124;C_SmartSwapWithSlippage</code> | 5 | 15 |
| <code>VST&#124;C_Freeze</code> | 5 | 9 |
| <code>VST&#124;C_ToggleTransferRoleFrozenDPTF</code> | 5 | 11 |
| <code>AQP-DSA&#124;A_ToggleExternalOracle</code> | 4 | 8 |
| <code>AQP-FVT&#124;C_IssueMultipletFamily</code> | 4 | 4 |
| <code>DEMIPAD&#124;C_FuelSemiFungible</code> | 4 | 15 |
| <code>DPNF&#124;C_ToggleBurnRole</code> | 4 | 3 |
| <code>DPOF&#124;C_MoveCreateRole</code> | 4 | 12 |
| <code>DPSF&#124;C_DefineHybridSet</code> | 4 | 8 |
| <code>DPTF&#124;C_BulkTransfer</code> | 4 | 2 |
| <code>VST&#124;C_ToggleTransferRoleReservedDPTF</code> | 4 | 10 |
| <code>AQP-DSA&#124;A_SetOracleValidity</code> | 3 | 9 |
| <code>AQP-FVT&#124;C_SetCommonDenominator</code> | 3 | 3 |
| <code>AQP-POOL&#124;C_SyncNonFungibleAnchors</code> | 3 | 8 |
| <code>ATS&#124;C_RotateOwnership</code> | 3 | 2 |
| <code>ATS&#124;C_SetColdRecoveryDuration</code> | 3 | 2 |
| <code>ATS&#124;C_SetDirectRecoveryFee</code> | 3 | 2 |
| <code>ATS&#124;HOT-RBT&#124;C_Repurpose</code> | 3 | 6 |
| <code>ATS&#124;HOT-RBT&#124;C_UpgradeBranding</code> | 3 | 5 |
| <code>DPNF&#124;C_Break</code> | 3 | 8 |
| <code>DPNF&#124;C_MoveCreateRole</code> | 3 | 2 |
| <code>DPNF&#124;C_MoveRecreateRole</code> | 3 | 2 |
| <code>DPNF&#124;C_MoveSetUriRole</code> | 3 | 2 |
| <code>DPNF&#124;C_ToggleExemptionRole</code> | 3 | 3 |
| <code>DPNF&#124;C_ToggleModifyCreatorRole</code> | 3 | 2 |
| <code>DPNF&#124;C_ToggleModifyRoyaltiesRole</code> | 3 | 2 |
| <code>DPNF&#124;C_ToggleSet</code> | 3 | 2 |
| <code>DPNF&#124;C_ToggleTransferRole</code> | 3 | 9 |
| <code>DPOF&#124;C_AddQuantity</code> | 3 | 5 |
| <code>DPOF&#124;C_ToggleBurnRole</code> | 3 | 4 |
| <code>DPOF&#124;C_ToggleTransferRole</code> | 3 | 6 |
| <code>DPSF&#124;C_MoveSetUriRole</code> | 3 | 2 |
| <code>DPSF&#124;C_ToggleModifyCreatorRole</code> | 3 | 2 |
| <code>DPSF&#124;C_TogglePause</code> | 3 | 2 |
| <code>DPSF&#124;C_ToggleTransferRole</code> | 3 | 2 |
| <code>DPTF&#124;C_UpdatePendingBranding</code> | 3 | 2 |
| <code>DPTF&#124;C_UpgradeBranding</code> | 3 | 6 |
| <code>LQD&#124;C_WrapUrStoa</code> | 3 | 7 |
| <code>SWP&#124;C_AddFrozenLiquidity</code> | 3 | 3 |
| <code>SWP&#124;C_AddGlacialLiquidity</code> | 3 | 2 |
| <code>SWP&#124;C_AddSleepingLiquidity</code> | 3 | 4 |
| <code>SWP&#124;C_IssueStablePool</code> | 3 | 2 |
| <code>SWP&#124;C_MultiSwapWithSlippage</code> | 3 | 2 |
| <code>SWP&#124;C_ToggleFeeLock</code> | 3 | 3 |
| <code>SWP&#124;C_UpdatePendingBrandingLPs</code> | 3 | 5 |
| <code>VST&#124;C_Awake</code> | 3 | 19 |
| <code>VST&#124;C_RepurposeMerge</code> | 3 | 2 |
| <code>VST&#124;C_RepurposeSleeping</code> | 3 | 16 |
| <code>VST&#124;C_Unreserve</code> | 3 | 3 |
| <code>AQP-FVT&#124;CC_UnstaleMyScores</code> | 2 | 7 |
| <code>ATS&#124;AA_RemoveSecondary</code> | 2 | 1 |
| <code>ATS&#124;C_ControlColdRecoveryFees</code> | 2 | 2 |
| <code>ATS&#124;C_ControlHotRecoveryFee</code> | 2 | 2 |
| <code>ATS&#124;C_SetHotRecoveryFee</code> | 2 | 4 |
| <code>ATS&#124;C_UpgradeBranding</code> | 2 | 8 |
| <code>ATS&#124;C_VestedCurl</code> | 2 | 3 |
| <code>CODEX&#124;C_RotateCodexGuard</code> | 2 | 3 |
| <code>DALOS&#124;C_UpdateEliteAccount</code> | 2 | 13 |
| <code>DALOS&#124;C_UpdateEliteAccountSquared</code> | 2 | 13 |
| <code>DEMIPAD&#124;C_FuelNonFungible</code> | 2 | 5 |
| <code>DEMIPAD&#124;C_FuelOrtoFungible</code> | 2 | 4 |
| <code>DEMIPAD&#124;C_FuelTrueFungible</code> | 2 | 4 |
| <code>DEMIPAD&#124;C_RetrieveNonFungible</code> | 2 | 5 |
| <code>DEMIPAD&#124;C_RetrieveOrtoFungible</code> | 2 | 4 |
| <code>DEMIPAD&#124;C_RetrieveSemiFungible</code> | 2 | 4 |
| <code>DEMIPAD&#124;C_RetrieveTrueFungible</code> | 2 | 4 |
| <code>DPDC&#124;C_MultiTransfer</code> | 2 | 7 |
| <code>DPNF&#124;CC_WipeHeavy</code> | 2 | 4 |
| <code>DPNF&#124;C_DefineCompositeSet</code> | 2 | 2 |
| <code>DPNF&#124;C_DefineHybridSet</code> | 2 | 2 |
| <code>DPNF&#124;C_MergeFragments</code> | 2 | 6 |
| <code>DPNF&#124;C_RemoveNonceScore</code> | 2 | 2 |
| <code>DPNF&#124;C_RemoveSetNonceScore</code> | 2 | 2 |
| <code>DPNF&#124;C_RenameSet</code> | 2 | 2 |
| <code>DPNF&#124;C_Repurpose</code> | 2 | 8 |
| <code>DPNF&#124;C_RepurposeFragments</code> | 2 | 3 |
| <code>DPNF&#124;C_Respawn</code> | 2 | 3 |
| <code>DPNF&#124;C_UpdateNonce</code> | 2 | 9 |
| <code>DPNF&#124;C_UpdateNonceIgnisRoyalty</code> | 2 | 2 |
| <code>DPNF&#124;C_UpdateNonceRoyalty</code> | 2 | 9 |
| <code>DPNF&#124;C_UpdateNonceScore</code> | 2 | 9 |
| <code>DPNF&#124;C_UpdateNonces</code> | 2 | 2 |
| <code>DPNF&#124;C_UpdatePendingBranding</code> | 2 | 7 |
| <code>DPNF&#124;C_UpdateSetNonce</code> | 2 | 2 |
| <code>DPNF&#124;C_UpdateSetNonceDescription</code> | 2 | 2 |
| <code>DPNF&#124;C_UpdateSetNonceIgnisRoyalty</code> | 2 | 2 |
| <code>DPNF&#124;C_UpdateSetNonceMetaData</code> | 2 | 2 |
| <code>DPNF&#124;C_UpdateSetNonceRoyalty</code> | 2 | 2 |
| <code>DPNF&#124;C_UpdateSetNonceScore</code> | 2 | 2 |
| <code>DPNF&#124;C_UpdateSetNonceURI</code> | 2 | 2 |
| <code>DPNF&#124;C_UpdateSetNonces</code> | 2 | 2 |
| <code>DPNF&#124;C_UpgradeBranding</code> | 2 | 3 |
| <code>DPNF&#124;C_WipeClean</code> | 2 | 4 |
| <code>DPNF&#124;C_WipeDirty</code> | 2 | 4 |
| <code>DPNF&#124;C_WipeNonce</code> | 2 | 4 |
| <code>DPNF&#124;C_WipePure</code> | 2 | 4 |
| <code>DPOF&#124;A_DeployAccount</code> | 2 | 0 |
| <code>DPOF&#124;CC_WipeHeavy</code> | 2 | 2 |
| <code>DPOF&#124;C_Burn</code> | 2 | 2 |
| <code>DPOF&#124;C_RotateOwnership</code> | 2 | 3 |
| <code>DPOF&#124;C_UpdatePendingBranding</code> | 2 | 2 |
| <code>DPOF&#124;C_UpgradeBranding</code> | 2 | 3 |
| <code>DPOF&#124;C_WipeClean</code> | 2 | 2 |
| <code>DPOF&#124;C_WipePure</code> | 2 | 2 |
| <code>DPOF&#124;C_WipeSlim</code> | 2 | 2 |
| <code>DPSF&#124;CC_WipeHeavy</code> | 2 | 13 |
| <code>DPSF&#124;C_Burn</code> | 2 | 2 |
| <code>DPSF&#124;C_Control</code> | 2 | 2 |
| <code>DPSF&#124;C_RemoveNonceScore</code> | 2 | 7 |
| <code>DPSF&#124;C_RemoveSetNonceScore</code> | 2 | 2 |
| <code>DPSF&#124;C_ToggleAddQuantityRole</code> | 2 | 2 |
| <code>DPSF&#124;C_ToggleBurnRole</code> | 2 | 2 |
| <code>DPSF&#124;C_ToggleModifyRoyaltiesRole</code> | 2 | 2 |
| <code>DPSF&#124;C_ToggleUpdateRole</code> | 2 | 2 |
| <code>DPSF&#124;C_UpdateNonce</code> | 2 | 7 |
| <code>DPSF&#124;C_UpdateNonceURI</code> | 2 | 9 |
| <code>DPSF&#124;C_UpdatePendingBranding</code> | 2 | 7 |
| <code>DPSF&#124;C_UpdateSetNonce</code> | 2 | 2 |
| <code>DPSF&#124;C_UpdateSetNonceDescription</code> | 2 | 2 |
| <code>DPSF&#124;C_UpdateSetNonceIgnisRoyalty</code> | 2 | 2 |
| <code>DPSF&#124;C_UpdateSetNonceMetaData</code> | 2 | 2 |
| <code>DPSF&#124;C_UpdateSetNonceName</code> | 2 | 2 |
| <code>DPSF&#124;C_UpdateSetNonceRoyalty</code> | 2 | 2 |
| <code>DPSF&#124;C_UpdateSetNonceScore</code> | 2 | 2 |
| <code>DPSF&#124;C_UpdateSetNonceURI</code> | 2 | 2 |
| <code>DPSF&#124;C_UpdateSetNonces</code> | 2 | 2 |
| <code>DPSF&#124;C_UpgradeBranding</code> | 2 | 3 |
| <code>DPSF&#124;C_WipeDirty</code> | 2 | 10 |
| <code>DPSF&#124;C_WipeNonce</code> | 2 | 2 |
| <code>DPSF&#124;C_WipeNoncePartialy</code> | 2 | 2 |
| <code>DPSF&#124;C_WipePure</code> | 2 | 13 |
| <code>DPTF&#124;C_MultiBulkTransfer</code> | 2 | 6 |
| <code>LQD&#124;C_UnwrapUrStoa</code> | 2 | 5 |
| <code>MTX-AQP&#124;2&#124;CC_Inject</code> | 2 | 2 |
| <code>ORBR&#124;C_Compress</code> | 2 | 4 |
| <code>ORBR&#124;C_SublimateV2</code> | 2 | 7 |
| <code>PYTHIA&#124;A_UpdateDeployPrice</code> | 2 | 6 |
| <code>PYTHIA&#124;A_UpdateRenamePrice</code> | 2 | 6 |
| <code>PYTHIA&#124;C_RevokeLink</code> | 2 | 7 |
| <code>PYTHIA&#124;C_UpdateDualConsumerLane</code> | 2 | 5 |
| <code>SWP&#124;C_Fuel</code> | 2 | 3 |
| <code>SWP&#124;C_UpdatePendingBranding</code> | 2 | 2 |
| <code>SWP&#124;C_UpgradeBrandingLPs</code> | 2 | 6 |
| <code>AQP-ANK&#124;C_IssueSemiFungibleAnchor</code> | 1 | 6 |
| <code>AQP-DSA&#124;C_RecomputeCapture</code> | 1 | 4 |
| <code>ATS&#124;C_UpdatePendingBranding</code> | 1 | 8 |
| <code>DALOS&#124;A_ToggleOAPU</code> | 1 | 4 |
| <code>DALOS&#124;A_UpdatePublicKey</code> | 1 | 0 |
| <code>MTX-AQP&#124;2&#124;CC_SweepRevokeAnchor</code> | 1 | 6 |

## Full ledger

| entrypoint | invocations | +asserts | -asserts | test files |
|---|---:|---:|---:|---|
| <code>AQP-ANK&#124;C_IssueNonFungibleAnchor</code> | 2 | 4 | 6 | `[6.2.15]_AQP-NF-ANCHOR.repl`, `AQP.repl` |
| <code>AQP-ANK&#124;C_IssueNonFungibleSetAnchor</code> | 3 | 10 | 6 | `[6.2.4]_AQP-FVT-NF.repl`, `AQP.repl` |
| <code>AQP-ANK&#124;C_IssueSemiFungibleAnchor</code> | 1 | 6 | 0 | `[6.2.4]_AQP-FVT-DC.repl` |
| <code>AQP-ANK&#124;C_IssueTrueFungibleAnchor</code> | 49 | 26 | 17 | `AQP-scale-sweep.repl`, `AQP-stream-tests.repl`, `AQP-sweep-single-tx.repl` +6 |
| <code>AQP-ANK&#124;C_RevokeAnchor</code> | 16 | 14 | 14 | `[RT-D2]_Ownership-Collectables.repl`, `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.1]_AQP-ANK.repl` |
| <code>AQP-ANK&#124;C_RevokeBoostClass</code> | 12 | 9 | 8 | `[6.2.1]_AQP-ANK.repl`, `AQP.repl` |
| <code>AQP-DSA&#124;A_SetOracleValidity</code> | 3 | 9 | 0 | `dsa-capture-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;A_ToggleExternalOracle</code> | 4 | 8 | 0 | `dsa-capture-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;CC_OpenAgency</code> | 8 | 7 | 5 | `dsa-agency-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +1 |
| <code>AQP-DSA&#124;C_BurnRoyalty</code> | 4 | 10 | 12 | `dsa-capture-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;C_DefineDelegationVault</code> | 8 | 9 | 6 | `dsa-agency-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +2 |
| <code>AQP-DSA&#124;C_FuelRoyalty</code> | 5 | 14 | 14 | `dsa-capture-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;C_OracleWrite</code> | 15 | 31 | 13 | `dsa-capture-tests.repl`, `dsa-fee-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;C_RecomputeCapture</code> | 1 | 4 | 0 | `dsa-capture-tests.repl` |
| <code>AQP-DSA&#124;C_SetAgencyFee</code> | 6 | 19 | 12 | `dsa-fee-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;C_SetOracleAuth</code> | 4 | 16 | 12 | `dsa-capture-tests.repl`, `dsa-fee-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-DSA&#124;C_WithdrawRoyalty</code> | 4 | 10 | 13 | `dsa-capture-tests.repl`, `dsa-grand-tour.repl` |
| <code>AQP-FVT&#124;CC_Collect</code> | 63 | 169 | 4 | `AQP-scale-sweep.repl`, `AQP-stream-tests.repl`, `dsa-capture-tests.repl` +10 |
| <code>AQP-FVT&#124;CC_Inject</code> | 43 | 171 | 0 | `dsa-capture-tests.repl`, `dsa-fee-tests.repl`, `dsa-grand-tour.repl` +10 |
| <code>AQP-FVT&#124;CC_InjectFinalize</code> | 3 | 8 | 1 | `AQP-scale-inject.repl`, `[6.2.8c]_AQP-INJECT-CC.repl` |
| <code>AQP-FVT&#124;CC_InjectStream</code> | 12 | 31 | 3 | `AQP-stream-tests.repl`, `[6.2.4]_AQP-FVT.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-FVT&#124;CC_SweepBegin</code> | 3 | 18 | 4 | `AQP-scale-sweep.repl`, `[6.2.8]_AQP-SWEEP-CC.repl` |
| <code>AQP-FVT&#124;CC_SweepRevokeAnchor</code> | 2 | 16 | 1 | `AQP-sweep-single-tx.repl` |
| <code>AQP-FVT&#124;CC_UnstaleMyScores</code> | 2 | 7 | 0 | `[6.2.8b]_AQP-UNSTALE.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-FVT&#124;CCp_InjectFixChunk</code> | 7 | 16 | 5 | `AQP-scale-inject.repl`, `[6.2.8c]_AQP-INJECT-CC.repl`, `AQP.repl` |
| <code>AQP-FVT&#124;CCp_SweepRecomputeChunk</code> | 8 | 29 | 9 | `AQP-scale-sweep.repl`, `[6.2.8]_AQP-SWEEP-CC.repl`, `AQP.repl` |
| <code>AQP-FVT&#124;CCp_UnstaleAll</code> | 5 | 14 | 6 | `[6.2.8d]_AQP-UNSTALE-ALL-CC.repl`, `AQP.repl` |
| <code>AQP-FVT&#124;C_AddRewardLink</code> | 12 | 26 | 1 | `AQP-stream-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +3 |
| <code>AQP-FVT&#124;C_AddScoreEntity</code> | 11 | 18 | 1 | `AQP-stream-tests.repl`, `[6.2.4]_AQP-FVT.repl`, `[6.2.8]_AQP-STAKE-GAS.repl` +1 |
| <code>AQP-FVT&#124;C_Control</code> | 7 | 14 | 15 | `dsa-grand-tour.repl`, `[6.2.10]_AQP-NEGATIVES.repl`, `[6.4]_AQP-EXHAUSTIVE-FVT-ADMIN.repl` +1 |
| <code>AQP-FVT&#124;C_Issue</code> | 24 | 39 | 8 | `AQP-stream-tests.repl`, `dsa-agency-tests.repl`, `dsa-capture-tests.repl` +8 |
| <code>AQP-FVT&#124;C_IssueMultipletFamily</code> | 4 | 4 | 0 | `[6.2.14]_AQP-MULTIPLET.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-FVT&#124;C_RotateOwnership</code> | 5 | 17 | 14 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.12]_AQP-ANCHOR-TAIL.repl`, `[6.4]_AQP-EXHAUSTIVE-FVT-ADMIN.repl` +1 |
| <code>AQP-FVT&#124;C_SetCommonDenominator</code> | 3 | 3 | 0 | `[6.2.12]_AQP-ANCHOR-TAIL.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-FVT&#124;C_SetMosaic</code> | 6 | 9 | 1 | `[6.2.4]_AQP-FVT.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-FVT&#124;C_SetQualitySplit</code> | 12 | 27 | 6 | `dsa-grand-tour.repl`, `dsa-hetero-split-tests.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-FVT&#124;C_SetSplitMode</code> | 10 | 8 | 9 | `dsa-hetero-split-tests.repl`, `[6.2.11]_AQP-SPLIT-MODE.repl`, `[6.2.9]_AQP-BOOT-FULL.repl` +2 |
| <code>AQP-FVT&#124;C_ToggleRewardLink</code> | 5 | 17 | 14 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.4]_AQP-EXHAUSTIVE-FVT-ADMIN.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-FVT&#124;C_ToggleScoreEntityLink</code> | 15 | 21 | 14 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.4]_AQP-FVT.repl`, `[6.4]_AQP-EXHAUSTIVE-FVT-ADMIN.repl` +2 |
| <code>AQP-POOL&#124;CC_FullVacate</code> | 21 | 37 | 6 | `[6.2.4]_AQP-FVT-DC.repl`, `[6.2.4]_AQP-FVT-OF.repl`, `[6.2.5]_AQP-VCT.repl` +3 |
| <code>AQP-POOL&#124;CC_StakeNonFungibleCollectable</code> | 37 | 111 | 1 | `dsa-hetero-split-tests.repl`, `[RT-D2]_Ownership-Collectables.repl`, `[6.2.4]_AQP-FVT-NF.repl` +12 |
| <code>AQP-POOL&#124;CC_StakeOrtoFungible</code> | 27 | 54 | 1 | `[RT-D2]_Ownership-Collectables.repl`, `[6.2.4]_AQP-FVT-OF.repl`, `[6.2.5]_AQP-VCT.repl` +5 |
| <code>AQP-POOL&#124;CC_StakeSemiFungibleCollectable</code> | 49 | 93 | 1 | `dsa-capture-tests.repl`, `dsa-fee-tests.repl`, `dsa-grand-tour.repl` +12 |
| <code>AQP-POOL&#124;CC_StakeTrueFungible</code> | 54 | 156 | 3 | `AQP-stream-tests.repl`, `dsa-hetero-split-tests.repl`, `[6.2.10]_AQP-NEGATIVES.repl` +11 |
| <code>AQP-POOL&#124;CC_UnstakeNonFungibleCollectable</code> | 7 | 17 | 1 | `[6.2.4]_AQP-FVT-NF.repl`, `[6.2.7]_AQP-DEB-MTX.repl`, `[6.2.8]_AQP-STAKE-GAS.repl` +1 |
| <code>AQP-POOL&#124;CC_UnstakeOrtoFungible</code> | 9 | 20 | 2 | `[6.2.4]_AQP-FVT-OF.repl`, `[6.2.8]_AQP-STAKE-GAS.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` +1 |
| <code>AQP-POOL&#124;CC_UnstakeSemiFungibleCollectable</code> | 15 | 33 | 1 | `[6.2.4]_AQP-FVT-DC.repl`, `[6.2.7]_AQP-DEB-MTX.repl`, `[6.2.8]_AQP-STAKE-GAS.repl` +2 |
| <code>AQP-POOL&#124;CC_UnstakeTrueFungible</code> | 9 | 40 | 0 | `AQP-stream-tests.repl`, `[6.2.4]_AQP-FVT.repl`, `[6.2.8]_AQP-STAKE-GAS.repl` +2 |
| <code>AQP-POOL&#124;CCp_BatchDrainCollectable</code> | 5 | 15 | 4 | `[RT-D2]_Ownership-Collectables.repl`, `[6.2.4]_AQP-FVT-NF.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-POOL&#124;CCp_BatchDrainOrtoFungible</code> | 3 | 12 | 3 | `[RT-D2]_Ownership-Collectables.repl`, `[6.2.4]_AQP-FVT-OF.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-POOL&#124;CCp_BatchDrainTrueFungible</code> | 9 | 33 | 5 | `AQP-scale-vacate.repl`, `[RT-D2]_Ownership-Collectables.repl`, `[6.2.5]_AQP-VCT.repl` +1 |
| <code>AQP-POOL&#124;CCp_BatchVacateCollectables</code> | 23 | 34 | 4 | `[RT-D2]_Ownership-Collectables.repl`, `[6.2.4]_AQP-FVT-DC.repl`, `[6.2.4]_AQP-FVT-NF.repl` +4 |
| <code>AQP-POOL&#124;CCp_BatchVacateOrtoFungible</code> | 12 | 16 | 3 | `[RT-D2]_Ownership-Collectables.repl`, `[6.2.4]_AQP-FVT-OF.repl`, `[6.2.5]_AQP-VCT.repl` +3 |
| <code>AQP-POOL&#124;CCp_BatchVacateTrueFungible</code> | 19 | 35 | 5 | `[RT-D2]_Ownership-Collectables.repl`, `[6.2.5]_AQP-VCT.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl` +2 |
| <code>AQP-POOL&#124;C_AbortVacate</code> | 10 | 22 | 3 | `[6.2.5]_AQP-VCT.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-POOL&#124;C_AddScore</code> | 115 | 128 | 12 | `AQP-scale-inject.repl`, `AQP-scale-sweep.repl`, `AQP-scale-vacate.repl` +19 |
| <code>AQP-POOL&#124;C_DisablePoolStake</code> | 5 | 3 | 4 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl`, `AQP.repl` |
| <code>AQP-POOL&#124;C_EnablePoolStake</code> | 42 | 94 | 8 | `AQP-scale-inject.repl`, `AQP-scale-sweep.repl`, `AQP-scale-vacate.repl` +9 |
| <code>AQP-POOL&#124;C_FinalizeVacate</code> | 6 | 24 | 3 | `AQP-scale-vacate.repl`, `[6.2.5]_AQP-VCT.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-POOL&#124;C_Issue</code> | 88 | 114 | 5 | `AQP-scale-inject.repl`, `AQP-scale-sweep.repl`, `AQP-scale-vacate.repl` +17 |
| <code>AQP-POOL&#124;C_RevokeScore</code> | 12 | 16 | 4 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.3]_AQP-POOL.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-POOL&#124;C_SyncNonFungibleAnchors</code> | 3 | 8 | 0 | `[6.2.4]_AQP-FVT-NF.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-POOL&#124;C_SyncSemiFungibleAnchors</code> | 5 | 11 | 1 | `dsa-grand-tour.repl`, `[6.2.4]_AQP-FVT-DC.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-POOL&#124;C_SyncTrueFungibleAnchors</code> | 5 | 11 | 1 | `AQP-scale-vacate.repl`, `[6.2.4]_AQP-FVT.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>AQP-SCR&#124;C_CombineTripletScoreModel</code> | 12 | 20 | 6 | `dsa-agency-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +3 |
| <code>AQP-SCR&#124;C_ControlScore</code> | 10 | 20 | 12 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.2]_AQP-SCORE.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` +1 |
| <code>AQP-SCR&#124;C_CreateScoreBoostClassLink</code> | 8 | 19 | 14 | `AQP-scale-sweep.repl`, `AQP-sweep-single-tx.repl`, `[6.2.10]_AQP-NEGATIVES.repl` +2 |
| <code>AQP-SCR&#124;C_CreateScoreBoostLink</code> | 9 | 19 | 13 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.3]_AQP-POOL.repl`, `[6.2.7]_AQP-DEB-MTX.repl` +1 |
| <code>AQP-SCR&#124;C_EnableDebBoost</code> | 5 | 16 | 12 | `AQP-scale-inject.repl`, `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.7]_AQP-DEB-MTX.repl` +1 |
| <code>AQP-SCR&#124;C_IssueLiquidityScore</code> | 10 | 24 | 10 | `AQP-stream-tests.repl`, `dsa-grand-tour.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` +2 |
| <code>AQP-SCR&#124;C_IssueNonFungibleScore</code> | 25 | 43 | 4 | `[6.2.4]_AQP-FVT-NF.repl`, `[6.2.5]_AQP-VCT.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl` +6 |
| <code>AQP-SCR&#124;C_IssueNonFungibleScoreDefinition</code> | 6 | 15 | 2 | `[6.2.4]_AQP-FVT-NF.repl`, `[6.4]_AQP-EXHAUSTIVE-DPNF.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` +1 |
| <code>AQP-SCR&#124;C_IssueNonFungibleSetScoreDefinition</code> | 9 | 22 | 9 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.2]_AQP-SCORE.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` +1 |
| <code>AQP-SCR&#124;C_IssueOrtoFungibleScore</code> | 20 | 13 | 0 | `[6.2.4]_AQP-FVT-OF.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl`, `[6.2.6]_AQP-VCT-GAS.repl` +3 |
| <code>AQP-SCR&#124;C_IssueScoreFromModel</code> | 9 | 13 | 4 | `dsa-agency-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +4 |
| <code>AQP-SCR&#124;C_IssueSemiFungibleScore</code> | 33 | 36 | 7 | `[6.2.2]_AQP-SCORE.repl`, `[6.2.3]_AQP-POOL.repl`, `[6.2.4]_AQP-FVT-DC.repl` +6 |
| <code>AQP-SCR&#124;C_IssueSemiFungibleScoreDefinition</code> | 12 | 14 | 11 | `[6.2.2]_AQP-SCORE.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl`, `AQP.repl` |
| <code>AQP-SCR&#124;C_IssueSingleScoreModel</code> | 23 | 21 | 3 | `dsa-agency-tests.repl`, `dsa-capture-tests.repl`, `dsa-fee-tests.repl` +3 |
| <code>AQP-SCR&#124;C_IssueTriplet</code> | 10 | 25 | 12 | `dsa-grand-tour.repl`, `[6.2.13]_AQP-TRIPLET.repl`, `[6.2.2]_AQP-SCORE.repl` +2 |
| <code>AQP-SCR&#124;C_IssueTrueFungibleScore</code> | 40 | 60 | 2 | `AQP-scale-inject.repl`, `AQP-scale-sweep.repl`, `AQP-scale-vacate.repl` +11 |
| <code>AQP-SCR&#124;C_RotateScoreOwnership</code> | 8 | 18 | 11 | `[6.2.10]_AQP-NEGATIVES.repl`, `[6.2.2]_AQP-SCORE.repl`, `[6.5.1]_AQP-INFO-GROUNDTRUTH.repl` |
| <code>ATS&#124;AA_RemoveSecondary</code> | 2 | 1 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;A_KickStart</code> | 2 | 2 | 5 | `[6.6]_ATS.repl`, `CONFORMANCE.repl` |
| <code>ATS&#124;CC_RemoveSecondary</code> | 3 | 5 | 2 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_AddHotRBT</code> | 8 | 16 | 7 | `[6.6]_ATS.repl`, `_cov_draft.repl`, `ATS.repl` |
| <code>ATS&#124;C_AddSecondary</code> | 6 | 13 | 5 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_Brumate</code> | 4 | 4 | 3 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_Coil</code> | 35 | 25 | 16 | `[RT-A]_Economics.repl`, `[RT-K]_PreviewParity.repl`, `[4.0]_Sovereign-Executor.repl` +6 |
| <code>ATS&#124;C_ColdRecovery</code> | 280 | 16 | 20 | `[RT-K]_PreviewParity.repl`, `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_Constrict</code> | 3 | 9 | 3 | `ATS.repl` |
| <code>ATS&#124;C_Control</code> | 13 | 29 | 5 | `[4.0]_Sovereign-Executor.repl`, `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_ControlColdRecoveryFees</code> | 2 | 2 | 0 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_ControlHotRecoveryFee</code> | 2 | 2 | 0 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_Cull</code> | 7 | 3 | 0 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_Curl</code> | 4 | 5 | 3 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_DirectRecovery</code> | 4 | 7 | 10 | `[RT-K]_PreviewParity.repl`, `[6.6]_ATS.repl`, `_cov_draft.repl` +1 |
| <code>ATS&#124;C_Fuel</code> | 10 | 13 | 16 | `[RT-A]_Economics.repl`, `[RT-K]_PreviewParity.repl`, `[6.6]_ATS.repl` +1 |
| <code>ATS&#124;C_HotRecovery</code> | 13 | 20 | 14 | `[RT-H]_InputDomain.repl`, `[RT-K]_PreviewParity.repl`, `[6.6]_ATS.repl` +2 |
| <code>ATS&#124;C_Issue</code> | 22 | 27 | 2 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.2]_DPTF.repl` +3 |
| <code>ATS&#124;C_KickStart</code> | 5 | 7 | 3 | `[4.0]_Sovereign-Executor.repl`, `ATS.repl` |
| <code>ATS&#124;C_Redeem</code> | 4 | 9 | 3 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_Reverse</code> | 4 | 7 | 3 | `[6.6]_ATS.repl`, `_cov_draft.repl`, `ATS.repl` |
| <code>ATS&#124;C_RotateOwnership</code> | 3 | 2 | 0 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_SetColdRecoveryDuration</code> | 3 | 2 | 0 | `[4.0]_Sovereign-Executor.repl`, `ATS.repl` |
| <code>ATS&#124;C_SetColdRecoveryFees</code> | 6 | 2 | 2 | `_verify_finding_EMPTY-LIST_01_index_iterating_cumulators.repl`, `[4.0]_Sovereign-Executor.repl`, `ATS.repl` |
| <code>ATS&#124;C_SetDirectRecoveryFee</code> | 3 | 2 | 0 | `[4.0]_Sovereign-Executor.repl`, `_cov_draft.repl`, `ATS.repl` |
| <code>ATS&#124;C_SetHibernationFees</code> | 5 | 12 | 2 | `[6.6]_ATS.repl`, `_cov_draft.repl`, `ATS.repl` |
| <code>ATS&#124;C_SetHotRecoveryFee</code> | 2 | 4 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl` |
| <code>ATS&#124;C_SwitchColdRecovery</code> | 18 | 12 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.6]_ATS.repl` +2 |
| <code>ATS&#124;C_SwitchDirectRecovery</code> | 10 | 16 | 0 | `[4.0]_Sovereign-Executor.repl`, `[6.6]_ATS.repl`, `_cov_draft.repl` +1 |
| <code>ATS&#124;C_SwitchHotRecovery</code> | 15 | 15 | 4 | `[RT-H]_InputDomain.repl`, `[6.6]_ATS.repl`, `_cov_draft.repl` +1 |
| <code>ATS&#124;C_Syphon</code> | 9 | 15 | 6 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_ToggleElite</code> | 3 | 10 | 6 | `[4.0]_Sovereign-Executor.repl`, `ATS.repl` |
| <code>ATS&#124;C_ToggleParameterLock</code> | 8 | 10 | 5 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_ToggleUpgrade</code> | 6 | 4 | 2 | `[6.6]_ATS.repl`, `_cov_draft.repl`, `ATS.repl` |
| <code>ATS&#124;C_UpdatePendingBranding</code> | 1 | 8 | 0 | `ATS.repl` |
| <code>ATS&#124;C_UpdateRoyalty</code> | 13 | 16 | 6 | `[4.0]_Sovereign-Executor.repl`, `[6.6]_ATS.repl`, `_cov_draft.repl` +1 |
| <code>ATS&#124;C_UpdateSyphon</code> | 6 | 15 | 11 | `[6.6]_ATS.repl`, `ATS.repl` |
| <code>ATS&#124;C_UpgradeBranding</code> | 2 | 8 | 0 | `ATS.repl` |
| <code>ATS&#124;C_VestedCoil</code> | 3 | 2 | 1 | `[6.7]_VST.repl`, `ATS.repl` |
| <code>ATS&#124;C_VestedCurl</code> | 2 | 3 | 0 | `[6.7]_VST.repl`, `ATS.repl` |
| <code>ATS&#124;C_WithdrawRoyalties</code> | 5 | 6 | 3 | `_verify_finding_EMPTY-LIST_01_index_iterating_cumulators.repl`, `[6.6]_ATS.repl`, `_cov_draft.repl` +1 |
| <code>ATS&#124;HOT-RBT&#124;C_Repurpose</code> | 3 | 6 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl`, `ATS.repl` |
| <code>ATS&#124;HOT-RBT&#124;C_UpdatePendingBranding</code> | 5 | 8 | 1 | `[6.6]_ATS.repl`, `_cov_draft.repl`, `ATS.repl` |
| <code>ATS&#124;HOT-RBT&#124;C_UpgradeBranding</code> | 3 | 5 | 0 | `[6.6]_ATS.repl`, `_cov_draft.repl`, `ATS.repl` |
| <code>BRD&#124;A_Live</code> | 2 | 0 | 1 | `[6.4]_Admin.repl`, `ADMIN.repl` |
| <code>BRD&#124;A_SetFlag</code> | 6 | 14 | 14 | `[RT-C]_AdminImpersonation.repl`, `[6.4]_Admin.repl`, `SWP.repl` |
| <code>CODEX&#124;A_RegisterCodexIdentity</code> | 6 | 4 | 4 | `[6.9]_CODEX.repl`, `CODEX.repl` |
| <code>CODEX&#124;C_RecordArweaveUpload</code> | 6 | 4 | 3 | `[6.9]_CODEX.repl`, `CODEX.repl` |
| <code>CODEX&#124;C_RegisterStoicTag</code> | 7 | 16 | 4 | `[6.9]_CODEX.repl`, `CODEX.repl` |
| <code>CODEX&#124;C_ReleaseStoicTag</code> | 5 | 10 | 4 | `[6.9]_CODEX.repl`, `CODEX.repl` |
| <code>CODEX&#124;C_RotateCodexGuard</code> | 2 | 3 | 0 | `[6.9]_CODEX.repl` |
| <code>CUSTODIANS&#124;C_Acquire</code> | 7 | 16 | 3 | `[5.3]_Launchpad.repl`, `launchpad-groundtruth.repl` |
| <code>DALOS&#124;A_AccountCreationStoaToggle</code> | 6 | 78 | 14 | `[RT-C]_AdminImpersonation.repl`, `[6.1]_Cumulator.repl`, `DALOS-ADMIN.repl` |
| <code>DALOS&#124;A_DeploySmartAccount</code> | 12 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl`, `[2.1]_DpdcCore.repl` |
| <code>DALOS&#124;A_DeployStandardAccount</code> | 11 | 1 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl`, `[5.3]_Launchpad.repl` +2 |
| <code>DALOS&#124;A_IgnisToggle</code> | 5 | 5 | 8 | `[RT-C]_AdminImpersonation.repl`, `[4.0]_Sovereign-Executor.repl`, `DEFPACT-BILLING.repl` |
| <code>DALOS&#124;A_MigrateLiquidFunds</code> | 3 | 10 | 2 | `DALOS-ADMIN.repl` |
| <code>DALOS&#124;A_SetAutoFueling</code> | 3 | 4 | 8 | `[RT-C]_AdminImpersonation.repl`, `[6.12]_DALOS-ADMIN.repl`, `[6.4]_Admin.repl` |
| <code>DALOS&#124;A_SetIgnisSourcePrice</code> | 7 | 8 | 11 | `[RT-B]_PermissionlessReach.repl`, `[RT-C]_AdminImpersonation.repl`, `[6.12]_DALOS-ADMIN.repl` +2 |
| <code>DALOS&#124;A_ToggleGAP</code> | 17 | 42 | 25 | `[RT-C]_AdminImpersonation.repl`, `[6.12]_DALOS-ADMIN.repl`, `AQP.repl` +3 |
| <code>DALOS&#124;A_ToggleOAPU</code> | 1 | 4 | 0 | `[6.12]_DALOS-ADMIN.repl` |
| <code>DALOS&#124;A_UpdatePublicKey</code> | 1 | 0 | 0 | `[6.4]_Admin.repl` |
| <code>DALOS&#124;A_UpdateUsagePrice</code> | 37 | 11 | 12 | `[RT-C]_AdminImpersonation.repl`, `[4.0]_Sovereign-Executor.repl`, `AQP.repl` +1 |
| <code>DALOS&#124;C_ControlSmartAccount</code> | 3 | 4 | 5 | `[6.4]_Admin.repl`, `DALOS-ADMIN.repl` |
| <code>DALOS&#124;C_DeploySmartAccount</code> | 2 | 2 | 5 | `[6.3]_SWP.repl`, `DALOS-ADMIN.repl` |
| <code>DALOS&#124;C_DeployStandardAccount</code> | 2 | 2 | 5 | `[6.3]_SWP.repl`, `DALOS-ADMIN.repl` |
| <code>DALOS&#124;C_RotateGovernor</code> | 14 | 2 | 3 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl`, `[6.12]_DALOS-ADMIN.repl` +3 |
| <code>DALOS&#124;C_RotateGuard</code> | 4 | 22 | 4 | `[6.12]_DALOS-ADMIN.repl`, `DALOS-ADMIN.repl` |
| <code>DALOS&#124;C_RotateSovereign</code> | 3 | 18 | 1 | `[6.12]_DALOS-ADMIN.repl` |
| <code>DALOS&#124;C_RotateStoa</code> | 6 | 30 | 4 | `[6.12]_DALOS-ADMIN.repl`, `CONFORMANCE.repl`, `DALOS-ADMIN.repl` |
| <code>DALOS&#124;C_UpdateEliteAccount</code> | 2 | 13 | 0 | `[6.11]_INFO.repl`, `DALOS-ADMIN.repl` |
| <code>DALOS&#124;C_UpdateEliteAccountSquared</code> | 2 | 13 | 0 | `[6.11]_INFO.repl`, `DALOS-ADMIN.repl` |
| <code>DEMIPAD&#124;C_Deposit</code> | 10 | 31 | 14 | `[5.3]_Launchpad.repl`, `DEMIPAD.repl`, `LAUNCHPAD.repl` |
| <code>DEMIPAD&#124;C_FuelNonFungible</code> | 2 | 5 | 0 | `[6.1.5]_DEMIPAD.repl`, `DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_FuelOrtoFungible</code> | 2 | 4 | 0 | `[6.1.5]_DEMIPAD.repl`, `DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_FuelSemiFungible</code> | 4 | 15 | 0 | `[5.3]_Launchpad.repl`, `[6.1.5]_DEMIPAD.repl`, `DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_FuelTrueFungible</code> | 2 | 4 | 0 | `[6.1.5]_DEMIPAD.repl`, `DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_RetrieveNonFungible</code> | 2 | 5 | 0 | `[6.1.5]_DEMIPAD.repl`, `DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_RetrieveOrtoFungible</code> | 2 | 4 | 0 | `[6.1.5]_DEMIPAD.repl`, `DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_RetrieveSemiFungible</code> | 2 | 4 | 0 | `[6.1.5]_DEMIPAD.repl`, `DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_RetrieveTrueFungible</code> | 2 | 4 | 0 | `[6.1.5]_DEMIPAD.repl`, `DEMIPAD.repl` |
| <code>DEMIPAD&#124;C_Withdraw</code> | 6 | 9 | 6 | `[5.3]_Launchpad.repl` |
| <code>DPDC&#124;C_BulkTransfer</code> | 4 | 7 | 3 | `_verify_finding_EMPTY-LIST_01_index_iterating_cumulators.repl`, `[RT-D2]_Ownership-Collectables.repl`, `DPDC.repl` |
| <code>DPDC&#124;C_MultiTransfer</code> | 2 | 7 | 0 | `DPDC.repl` |
| <code>DPNF&#124;CC_WipeHeavy</code> | 2 | 4 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_Break</code> | 3 | 8 | 0 | `[6.1.3]_DPDC-S.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_BulkTransfer</code> | 8 | 8 | 3 | `[6.1.4]_DPDC-NF.repl`, `[6.1.8]_DPDC-HYDRA-WIPE.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_Burn</code> | 4 | 6 | 4 | `[RT-D2]_Ownership-Collectables.repl`, `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_Control</code> | 2 | 2 | 1 | `_verify_finding_DPDC-R_13H_unfreeze_release_valve.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_Create</code> | 38 | 36 | 19 | `_verify_finding_DPDC-C_24M_fragment_credit_amount.repl`, `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `_verify_finding_DPDC-S_15H_multiplier_bound.repl` +12 |
| <code>DPNF&#124;C_DefineCompositeSet</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_DefineHybridSet</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_DefinePrimordialSet</code> | 13 | 6 | 7 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `_verify_finding_DPDC-S_15H_multiplier_bound.repl`, `[6.1.3]_DPDC-S.repl` +2 |
| <code>DPNF&#124;C_EnableNonceFragmentation</code> | 6 | 14 | 4 | `_verify_finding_DPDC-C_24M_fragment_credit_amount.repl`, `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_EnableSetClassFragmentation</code> | 12 | 22 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_Issue</code> | 15 | 8 | 22 | `_verify_finding_DPDC-C_24M_fragment_credit_amount.repl`, `_verify_finding_DPDC-I_33M_makeid_same_block_collision.repl`, `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl` +9 |
| <code>DPNF&#124;C_Make</code> | 43 | 10 | 2 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[5.2]_PopulateBloodshed.repl`, `[6.1.3]_DPDC-S.repl` +1 |
| <code>DPNF&#124;C_MakeFragments</code> | 6 | 12 | 4 | `_verify_finding_DPDC-C_24M_fragment_credit_amount.repl`, `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_MergeFragments</code> | 2 | 6 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_MoveCreateRole</code> | 3 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_MoveRecreateRole</code> | 3 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_MoveSetUriRole</code> | 3 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_RemoveNonceScore</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_RemoveSetNonceScore</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_RenameSet</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_Repurpose</code> | 2 | 8 | 0 | `DPDC.repl`, `DPNF.repl` |
| <code>DPNF&#124;C_RepurposeFragments</code> | 2 | 3 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_Respawn</code> | 2 | 3 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_ToggleBurnRole</code> | 4 | 3 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_ToggleExemptionRole</code> | 3 | 3 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_ToggleFreezeAccount</code> | 17 | 22 | 2 | `_verify_finding_DPDC-R_13H_unfreeze_release_valve.repl`, `[6.1.4]_DPDC-NF.repl`, `[6.1.8]_DPDC-HYDRA-WIPE.repl` +1 |
| <code>DPNF&#124;C_ToggleModifyCreatorRole</code> | 3 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_ToggleModifyRoyaltiesRole</code> | 3 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_TogglePause</code> | 6 | 8 | 4 | `[RT-D2]_Ownership-Collectables.repl`, `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` +1 |
| <code>DPNF&#124;C_ToggleSet</code> | 3 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_ToggleTransferRole</code> | 3 | 9 | 0 | `DPDC.repl`, `DPNF.repl` |
| <code>DPNF&#124;C_ToggleUpdateRole</code> | 7 | 5 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_TransferNonce</code> | 9 | 45 | 2 | `dsa-hetero-split-tests.repl`, `[RT-D2]_Ownership-Collectables.repl`, `[6.4]_AQP-EXHAUSTIVE-ANK-LP.repl` +6 |
| <code>DPNF&#124;C_TransferNonces</code> | 21 | 34 | 0 | `[5.1]_PopulateNosferatu.repl`, `[6.2.4]_AQP-FVT-NF.repl`, `[6.2.5]_AQP-VCT.repl` +4 |
| <code>DPNF&#124;C_UpdateNonce</code> | 2 | 9 | 0 | `DPDC.repl`, `DPNF.repl` |
| <code>DPNF&#124;C_UpdateNonceDescription</code> | 4 | 9 | 8 | `_verify_finding_DPDC_12Hb_metadata_caps.repl`, `DPDC.repl`, `DPNF.repl` |
| <code>DPNF&#124;C_UpdateNonceIgnisRoyalty</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_UpdateNonceMetaData</code> | 4 | 2 | 10 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `_verify_finding_DPDC_12Hb_metadata_caps.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_UpdateNonceName</code> | 6 | 9 | 10 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `_verify_finding_DPDC_12Hb_metadata_caps.repl`, `DPDC.repl` +1 |
| <code>DPNF&#124;C_UpdateNonceRoyalty</code> | 2 | 9 | 0 | `DPDC.repl`, `DPNF.repl` |
| <code>DPNF&#124;C_UpdateNonceScore</code> | 2 | 9 | 0 | `DPDC.repl`, `DPNF.repl` |
| <code>DPNF&#124;C_UpdateNonceURI</code> | 4 | 2 | 8 | `_verify_finding_DPDC_12Hb_metadata_caps.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_UpdateNonces</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_UpdatePendingBranding</code> | 2 | 7 | 0 | `DPDC.repl` |
| <code>DPNF&#124;C_UpdateSetNonce</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_UpdateSetNonceDescription</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_UpdateSetNonceIgnisRoyalty</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_UpdateSetNonceMetaData</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_UpdateSetNonceName</code> | 3 | 2 | 2 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_UpdateSetNonceRoyalty</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_UpdateSetNonceScore</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_UpdateSetNonceURI</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_UpdateSetNonces</code> | 2 | 2 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC-S.repl` |
| <code>DPNF&#124;C_UpgradeBranding</code> | 2 | 3 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_WipeClean</code> | 2 | 4 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_WipeDirty</code> | 2 | 4 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_WipeNonce</code> | 2 | 4 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;C_WipePure</code> | 2 | 4 | 0 | `[6.1.4]_DPDC-NF.repl`, `DPDC.repl` |
| <code>DPNF&#124;Cp_WipeSlice</code> | 7 | 13 | 2 | `[6.1.8]_DPDC-HYDRA-WIPE.repl`, `DPDC.repl` |
| <code>DPOF&#124;A_DeployAccount</code> | 2 | 0 | 0 | `[6.1.6]_DPOF.repl` |
| <code>DPOF&#124;CC_WipeHeavy</code> | 2 | 2 | 0 | `[6.1.6]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_AddQuantity</code> | 3 | 5 | 0 | `[6.5]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_BulkTransfer</code> | 6 | 10 | 10 | `[6.5]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_Burn</code> | 2 | 2 | 0 | `[6.5]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_Control</code> | 15 | 30 | 7 | `[6.5]_DPOF.repl`, `[6.1.6]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_DeployAccount</code> | 3 | 4 | 4 | `[RT-K]_PreviewParity.repl`, `[6.3]_SWP.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_Issue</code> | 10 | 8 | 5 | `[RT-B]_PermissionlessReach.repl`, `[5.1]_Aoz+.repl`, `[6.5]_DPOF.repl` +6 |
| <code>DPOF&#124;C_Mint</code> | 28 | 29 | 10 | `[RT-K]_PreviewParity.repl`, `[6.5]_DPOF.repl`, `[6.1.5]_DEMIPAD.repl` +7 |
| <code>DPOF&#124;C_MoveCreateRole</code> | 4 | 12 | 0 | `DPOF.repl` |
| <code>DPOF&#124;C_RotateOwnership</code> | 2 | 3 | 0 | `[6.5]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_ToggleAddQuantityRole</code> | 11 | 19 | 1 | `[6.5]_DPOF.repl`, `[6.1.5]_DEMIPAD.repl`, `[6.2.5]_AQP-VCT.repl` +3 |
| <code>DPOF&#124;C_ToggleBurnRole</code> | 3 | 4 | 0 | `[6.5]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_ToggleFreezeAccount</code> | 39 | 60 | 2 | `[6.5]_DPOF.repl`, `[6.1.6]_DPOF.repl`, `[6.2.4]_AQP-FVT-OF.repl` +5 |
| <code>DPOF&#124;C_TogglePause</code> | 5 | 12 | 4 | `[6.5]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_ToggleTransferRole</code> | 3 | 6 | 0 | `[6.3]_SWP.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_Transfer</code> | 21 | 14 | 5 | `[6.5]_DPOF.repl`, `[6.2.5]_AQP-VCT.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl` +3 |
| <code>DPOF&#124;C_Transmit</code> | 11 | 22 | 11 | `[6.1.6]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_UpdatePendingBranding</code> | 2 | 2 | 0 | `[6.4]_Admin.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_UpgradeBranding</code> | 2 | 3 | 0 | `[6.1.6]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_WipeClean</code> | 2 | 2 | 0 | `[6.1.6]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_WipePure</code> | 2 | 2 | 0 | `[6.1.6]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;C_WipeSlim</code> | 2 | 2 | 0 | `[6.1.6]_DPOF.repl`, `DPOF.repl` |
| <code>DPOF&#124;Cp_WipeSlice</code> | 6 | 16 | 1 | `[6.1.6]_DPOF.repl`, `DPOF.repl` |
| <code>DPSF&#124;CC_Break</code> | 13 | 28 | 4 | `[6.1.3]_DPDC-S.repl`, `[6.1]_DPDC.repl`, `DPDC-S.repl` +1 |
| <code>DPSF&#124;CC_WipeHeavy</code> | 2 | 13 | 0 | `DPDC.repl` |
| <code>DPSF&#124;C_AddQuantity</code> | 8 | 8 | 5 | `[6.1.3]_DPDC-S.repl`, `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_BulkTransfer</code> | 3 | 6 | 1 | `[6.1.7]_DPSF-UPDATES.repl`, `[6.1.8]_DPDC-HYDRA-WIPE.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_Burn</code> | 2 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_Control</code> | 2 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_Create</code> | 23 | 19 | 10 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[4.0]_Sovereign-Executor.repl`, `[6.1.2]_DPDC-FRAGMENTS.repl` +4 |
| <code>DPSF&#124;C_DefineCompositeSet</code> | 6 | 6 | 6 | `_verify_finding_DPDC-F-S_47L-51L_empty_definition_guards.repl`, `_verify_finding_DPDC-UDC-S_38M_sentinel_unreachable.repl`, `[4.0]_Sovereign-Executor.repl` +2 |
| <code>DPSF&#124;C_DefineHybridSet</code> | 4 | 8 | 0 | `_verify_finding_DPDC-S_32M_hybrid_constituent_order.repl`, `[6.1.3]_DPDC-S.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_DefinePrimordialSet</code> | 14 | 6 | 8 | `_verify_finding_DPDC-F-S_47L-51L_empty_definition_guards.repl`, `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `_verify_finding_DPDC-S_31M_primordial_element_bounds.repl` +4 |
| <code>DPSF&#124;C_EnableNonceFragmentation</code> | 10 | 14 | 8 | `[4.0]_Sovereign-Executor.repl`, `[6.1.2]_DPDC-FRAGMENTS.repl`, `[6.1.3]_DPDC-S.repl` +4 |
| <code>DPSF&#124;C_EnableSetClassFragmentation</code> | 9 | 14 | 5 | `_verify_finding_DPDC-S_30M_enable-frag-active-gate.repl`, `[6.1.3]_DPDC-S.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_Issue</code> | 13 | 6 | 2 | `_verify_finding_DPDC-I_33M_makeid_same_block_collision.repl`, `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[4.0]_Sovereign-Executor.repl` +5 |
| <code>DPSF&#124;C_IssueCompany</code> | 7 | 12 | 3 | `[4.0]_Sovereign-Executor.repl`, `[6.1.1]_EQUITY.repl`, `EQUITY.repl` |
| <code>DPSF&#124;C_Make</code> | 19 | 33 | 7 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[6.1.3]_DPDC-S.repl`, `[6.1]_DPDC.repl` +1 |
| <code>DPSF&#124;C_MakeFragments</code> | 16 | 32 | 2 | `dsa-capture-tests.repl`, `dsa-fee-tests.repl`, `dsa-grand-tour.repl` +4 |
| <code>DPSF&#124;C_MergeFragments</code> | 6 | 9 | 4 | `[6.1.2]_DPDC-FRAGMENTS.repl`, `[6.1]_DPDC.repl`, `DPDC-FRAGMENTS.repl` +1 |
| <code>DPSF&#124;C_MorphEquity</code> | 17 | 13 | 5 | `[6.1.1]_EQUITY.repl`, `[6.1]_DPDC.repl`, `[6.4]_AQP-EXHAUSTIVE-PREP.repl` +1 |
| <code>DPSF&#124;C_MoveCreateRole</code> | 4 | 11 | 5 | `[6.1.3]_DPDC-S.repl`, `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_MoveRecreateRole</code> | 4 | 9 | 6 | `[6.1.3]_DPDC-S.repl`, `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_MoveSetUriRole</code> | 3 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_RemoveNonceScore</code> | 2 | 7 | 0 | `DPDC.repl`, `DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_RemoveSetNonceScore</code> | 2 | 2 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_RenameSet</code> | 7 | 14 | 9 | `[6.1.3]_DPDC-S.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_Repurpose</code> | 5 | 11 | 2 | `DPDC.repl`, `DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_RepurposeFragments</code> | 7 | 8 | 10 | `_verify_finding_DPDC-F-S_47L-51L_empty_definition_guards.repl`, `[6.1.2]_DPDC-FRAGMENTS.repl`, `DPDC-FRAGMENTS.repl` +1 |
| <code>DPSF&#124;C_ToggleAddQuantityRole</code> | 2 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_ToggleBurnRole</code> | 2 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_ToggleExemptionRole</code> | 9 | 15 | 8 | `[6.1.3]_DPDC-S.repl`, `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_ToggleFreezeAccount</code> | 18 | 40 | 1 | `[6.1.8]_DPDC-HYDRA-WIPE.repl`, `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_ToggleModifyCreatorRole</code> | 3 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_ToggleModifyRoyaltiesRole</code> | 2 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_TogglePause</code> | 3 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_ToggleSet</code> | 9 | 8 | 3 | `_verify_finding_DPDC-S_30M_enable-frag-active-gate.repl`, `[6.1.3]_DPDC-S.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_ToggleTransferRole</code> | 3 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_ToggleUpdateRole</code> | 2 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_TransferNonce</code> | 14 | 39 | 0 | `dsa-fee-tests.repl`, `dsa-grand-tour.repl`, `[6.1.2]_DPDC-FRAGMENTS.repl` +6 |
| <code>DPSF&#124;C_TransferNonces</code> | 16 | 21 | 0 | `[6.2.4]_AQP-FVT-DC.repl`, `[6.2.5]_AQP-VCT.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl` +3 |
| <code>DPSF&#124;C_UpdateNonce</code> | 2 | 7 | 0 | `DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceDescription</code> | 2 | 2 | 1 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceIgnisRoyalty</code> | 2 | 2 | 1 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceMetaData</code> | 2 | 2 | 1 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceName</code> | 3 | 2 | 1 | `_verify_finding_DPDC-N_12Hc_set_instance_lock.repl`, `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceRoyalty</code> | 2 | 2 | 1 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_UpdateNonceScore</code> | 4 | 7 | 1 | `[6.1]_DPDC.repl`, `DPDC.repl`, `DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdateNonceURI</code> | 2 | 9 | 0 | `DPDC.repl`, `DPSF-UPDATES.repl` |
| <code>DPSF&#124;C_UpdateNonces</code> | 10 | 12 | 10 | `[6.1.3]_DPDC-S.repl`, `[6.1.7]_DPSF-UPDATES.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_UpdatePendingBranding</code> | 2 | 7 | 0 | `DPDC.repl` |
| <code>DPSF&#124;C_UpdateSetNonce</code> | 2 | 2 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_UpdateSetNonceDescription</code> | 2 | 2 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_UpdateSetNonceIgnisRoyalty</code> | 2 | 2 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_UpdateSetNonceMetaData</code> | 2 | 2 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_UpdateSetNonceName</code> | 2 | 2 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_UpdateSetNonceRoyalty</code> | 2 | 2 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_UpdateSetNonceScore</code> | 2 | 2 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_UpdateSetNonceURI</code> | 2 | 2 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_UpdateSetNonces</code> | 2 | 2 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC-S.repl` |
| <code>DPSF&#124;C_UpgradeBranding</code> | 2 | 3 | 0 | `[6.1.7]_DPSF-UPDATES.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_WipeClean</code> | 2 | 2 | 1 | `DPDC.repl` |
| <code>DPSF&#124;C_WipeDirty</code> | 2 | 10 | 0 | `DPDC.repl` |
| <code>DPSF&#124;C_WipeNonce</code> | 2 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_WipeNoncePartialy</code> | 2 | 2 | 0 | `[6.1]_DPDC.repl`, `DPDC.repl` |
| <code>DPSF&#124;C_WipePure</code> | 2 | 13 | 0 | `DPDC.repl` |
| <code>DPSF&#124;Cp_WipeSlice</code> | 5 | 10 | 1 | `[6.1.8]_DPDC-HYDRA-WIPE.repl`, `DPDC.repl` |
| <code>DPTF&#124;A_DeployAccount</code> | 10 | 2 | 1 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl` |
| <code>DPTF&#124;A_UpdateTreasuryDispoParameters</code> | 4 | 6 | 6 | `[6.3]_SWP.repl`, `DPTF.repl` |
| <code>DPTF&#124;A_WipeTreasuryDebt</code> | 4 | 6 | 12 | `[RT-C]_AdminImpersonation.repl`, `[6.3]_SWP.repl`, `DPTF.repl` |
| <code>DPTF&#124;A_WipeTreasuryDebtPartial</code> | 5 | 6 | 5 | `[6.3]_SWP.repl`, `_scratch_ts01a_n3_treasury_gate_check.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_BulkTransfer</code> | 4 | 2 | 0 | `[6.2]_DPTF.repl`, `[6.2.6]_AQP-VCT-GAS-BASE.repl`, `[6.2.6]_AQP-VCT-GAS.repl` +1 |
| <code>DPTF&#124;C_Burn</code> | 7 | 12 | 7 | `[RT-K]_PreviewParity.repl`, `[6.4]_Admin.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_ClearDispo</code> | 6 | 8 | 3 | `[6.2]_DPTF.repl`, `DPTF.repl`, `OUROBOROS.repl` |
| <code>DPTF&#124;C_Control</code> | 8 | 21 | 6 | `[6.4]_Admin.repl`, `adversarial-tf.repl`, `ADVERSARIAL.repl` +2 |
| <code>DPTF&#124;C_DeployAccount</code> | 4 | 4 | 1 | `[6.3]_SWP.repl`, `DPTF.repl`, `VST.repl` |
| <code>DPTF&#124;C_DonateFees</code> | 5 | 2 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.2]_DPTF.repl`, `[6.3]_SWP.repl` +2 |
| <code>DPTF&#124;C_Issue</code> | 46 | 34 | 15 | `[RT-B]_PermissionlessReach.repl`, `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl` +10 |
| <code>DPTF&#124;C_Mint</code> | 102 | 20 | 9 | `AQP-scale-inject.repl`, `[RT-K]_PreviewParity.repl`, `[4.0]_Sovereign-Executor.repl` +11 |
| <code>DPTF&#124;C_MultiBulkTransfer</code> | 2 | 6 | 0 | `DPTF.repl` |
| <code>DPTF&#124;C_MultiTransfer</code> | 12 | 8 | 5 | `[RT-D]_Ownership.repl`, `[6.2]_DPTF.repl`, `[6.3]_SWP.repl` +1 |
| <code>DPTF&#124;C_ResetFeeTarget</code> | 2 | 6 | 1 | `[6.4]_Admin.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_RotateOwnership</code> | 3 | 10 | 2 | `[6.4]_Admin.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_SetFee</code> | 27 | 11 | 9 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl` +3 |
| <code>DPTF&#124;C_SetFeeTarget</code> | 7 | 15 | 14 | `[4.0]_Sovereign-Executor.repl`, `[6.3]_SWP.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_SetMinMove</code> | 7 | 17 | 15 | `[4.0]_Sovereign-Executor.repl`, `[6.7]_VST.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_ToggleBurnRole</code> | 5 | 7 | 1 | `[6.4]_Admin.repl`, `[5.3]_Launchpad.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_ToggleFee</code> | 31 | 18 | 13 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl` +3 |
| <code>DPTF&#124;C_ToggleFeeExemptionRole</code> | 4 | 23 | 6 | `[6.3]_SWP.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_ToggleFeeLock</code> | 25 | 5 | 8 | `[4.0]_Sovereign-Executor.repl`, `[5.1]_Aoz+.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl` +2 |
| <code>DPTF&#124;C_ToggleFreezeAccount</code> | 9 | 20 | 5 | `[6.4]_Admin.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_ToggleMintRole</code> | 8 | 7 | 1 | `[5.2]_Dispenser+.repl`, `[6.7]_VST.repl`, `[5.3]_Launchpad.repl` +1 |
| <code>DPTF&#124;C_TogglePause</code> | 4 | 10 | 4 | `[6.4]_Admin.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_ToggleReservation</code> | 6 | 18 | 3 | `[6.3]_SWP.repl`, `DPTF.repl`, `VST.repl` +1 |
| <code>DPTF&#124;C_ToggleTransferRole</code> | 5 | 16 | 4 | `[6.3]_SWP.repl`, `DPTF.repl`, `VST.repl` |
| <code>DPTF&#124;C_Transfer</code> | 69 | 113 | 8 | `AQP-scale-inject.repl`, `AQP-stream-tests.repl`, `_verify_finding_ORBR-FEE_01_withdraw_ownership.repl` +24 |
| <code>DPTF&#124;C_Transmute</code> | 7 | 3 | 0 | `[4.0]_Sovereign-Executor.repl`, `[6.2]_DPTF.repl`, `[6.8]_Dispenser.repl` +1 |
| <code>DPTF&#124;C_UpdatePendingBranding</code> | 3 | 2 | 0 | `[6.4]_Admin.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_UpgradeBranding</code> | 3 | 6 | 0 | `[6.4]_Admin.repl`, `DPTF.repl` |
| <code>DPTF&#124;C_Wipe</code> | 3 | 9 | 1 | `DPTF.repl` |
| <code>DPTF&#124;C_WipeSlim</code> | 6 | 8 | 4 | `[6.4]_Admin.repl`, `DPTF.repl` |
| <code>KPAY&#124;C_BuyStoicPay</code> | 3 | 3 | 1 | `launchpad-groundtruth.repl` |
| <code>LIQUID&#124;A_MigrateLiquidFunds</code> | 3 | 12 | 6 | `CONFORMANCE.repl`, `LIQUID.repl` |
| <code>LQD&#124;C_UnwrapStoa</code> | 4 | 6 | 2 | `LIQUID.repl` |
| <code>LQD&#124;C_UnwrapUrStoa</code> | 2 | 5 | 0 | `[4.0]_Sovereign-Executor.repl`, `LIQUID.repl` |
| <code>LQD&#124;C_WrapStoa</code> | 6 | 7 | 0 | `[4.0]_Sovereign-Executor.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` +1 |
| <code>LQD&#124;C_WrapUrStoa</code> | 3 | 7 | 0 | `[4.0]_Sovereign-Executor.repl`, `LIQUID.repl` |
| <code>MTX-AQP&#124;2&#124;CC_Inject</code> | 2 | 2 | 0 | `[6.2.7]_AQP-DEB-MTX.repl` |
| <code>MTX-AQP&#124;2&#124;CC_SweepRevokeAnchor</code> | 1 | 6 | 0 | `[6.2.7]_AQP-DEB-MTX.repl` |
| <code>ORBR&#124;A_Fuel</code> | 2 | 0 | 5 | `[6.3]_SWP.repl`, `CONFORMANCE.repl` |
| <code>ORBR&#124;C_Compress</code> | 2 | 4 | 0 | `[6.3]_SWP.repl`, `OUROBOROS.repl` |
| <code>ORBR&#124;C_Sublimate</code> | 9 | 8 | 0 | `[4.0]_Sovereign-Executor.repl`, `[6.2]_DPTF.repl`, `[6.3]_SWP.repl` +1 |
| <code>ORBR&#124;C_SublimateV2</code> | 2 | 7 | 0 | `[4.0]_Sovereign-Executor.repl`, `OUROBOROS.repl` |
| <code>ORBR&#124;C_WithdrawFees</code> | 4 | 6 | 2 | `_verify_finding_ORBR-FEE_01_withdraw_ownership.repl`, `[6.3]_SWP.repl` |
| <code>P&#124;A_Add</code> | 3 | 3 | 3 | `[6.12]_DALOS-ADMIN.repl` |
| <code>P&#124;A_AddIMP</code> | 3 | 1 | 1 | `LAUNCHPAD.repl` |
| <code>P&#124;A_Define</code> | 58 | 0 | 0 | `[4.0]_Sovereign-Executor.repl`, `[5.2]_Dispenser+.repl`, `[4.0]_Sovereign-Executor.repl` +2 |
| <code>PYTHIA&#124;A_Flush</code> | 56 | 14 | 2 | `[6.10]_PYTHIA-flush-gas-probe.repl`, `[6.10b]_PYTHIA-ledger-v2.repl` |
| <code>PYTHIA&#124;A_Link</code> | 7 | 15 | 1 | `[6.10]_PYTHIA.repl` |
| <code>PYTHIA&#124;A_RevokeLink</code> | 5 | 15 | 3 | `[6.10]_PYTHIA.repl` |
| <code>PYTHIA&#124;A_UpdateDeployPrice</code> | 2 | 6 | 0 | `PYTHIA.repl` |
| <code>PYTHIA&#124;A_UpdateRenamePrice</code> | 2 | 6 | 0 | `PYTHIA.repl` |
| <code>PYTHIA&#124;C_DeployApiKey</code> | 12 | 14 | 2 | `[6.10]_PYTHIA.repl`, `PYTHIA.repl` |
| <code>PYTHIA&#124;C_Link</code> | 4 | 11 | 2 | `[6.10]_PYTHIA.repl`, `PYTHIA.repl` |
| <code>PYTHIA&#124;C_RevokeLink</code> | 2 | 7 | 0 | `[6.10]_PYTHIA.repl` |
| <code>PYTHIA&#124;C_UpdateDualConsumerLane</code> | 2 | 5 | 0 | `[6.10]_PYTHIA.repl` |
| <code>SNAKES&#124;C_Acquire</code> | 6 | 12 | 2 | `[5.3]_Launchpad.repl`, `launchpad-groundtruth.repl` |
| <code>SPARK&#124;C_BuySparks</code> | 7 | 9 | 6 | `[RT-K2]_PreviewParity-Launchpad.repl`, `[5.3]_Launchpad.repl`, `launchpad-groundtruth.repl` +1 |
| <code>SPARK&#124;C_RedemAllSparks</code> | 2 | 5 | 2 | `[5.3]_Launchpad.repl` |
| <code>SPARK&#124;C_RedemFewSparks</code> | 2 | 12 | 2 | `[5.3]_Launchpad.repl` |
| <code>STOAICO&#124;C_Collect</code> | 3 | 21 | 1 | `[RT-E]_Sequencing.repl`, `[6.3]_STOAICO.repl` |
| <code>SWP&#124;A_DefinePrimordialPool</code> | 4 | 2 | 4 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;A_RotatePrincipal</code> | 8 | 14 | 11 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `SWP.repl` |
| <code>SWP&#124;A_ToggleAsymetricLiquidityAddition</code> | 6 | 3 | 7 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `CONFORMANCE.repl` +1 |
| <code>SWP&#124;A_UpdateLimit</code> | 3 | 0 | 5 | `[6.4]_Admin.repl`, `CONFORMANCE.repl` |
| <code>SWP&#124;A_UpdateLiquidBoost</code> | 20 | 10 | 8 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;A_UpdatePrincipal</code> | 17 | 11 | 10 | `[4.0]_Sovereign-Executor.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` +1 |
| <code>SWP&#124;CC_SmartSwapNoSlippage</code> | 9 | 13 | 0 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;CC_SmartSwapWithSlippage</code> | 5 | 8 | 0 | `[RT-A]_Economics.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_AddFrozenLiquidity</code> | 3 | 3 | 0 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_AddGlacialLiquidity</code> | 3 | 2 | 0 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_AddIcedLiquidity</code> | 5 | 5 | 2 | `[RT-A]_Economics.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_AddLiquidity</code> | 15 | 66 | 1 | `dsa-hetero-split-tests.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` +5 |
| <code>SWP&#124;C_AddSleepingLiquidity</code> | 3 | 4 | 0 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_AddStandardLiquidity</code> | 8 | 20 | 1 | `[RT-A]_Economics.repl`, `[RT-E]_Sequencing.repl`, `[RT-F]_Griefing.repl` +3 |
| <code>SWP&#124;C_ChangeOwnership</code> | 6 | 15 | 4 | `SWP.repl` |
| <code>SWP&#124;C_EnableFrozenLP</code> | 5 | 7 | 2 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_EnableSleepingLP</code> | 6 | 13 | 2 | `[6.3]_SWP.repl`, `[6.4]_AQP-TRIPLET-COLLECT.repl`, `SWP.repl` |
| <code>SWP&#124;C_Firestarter</code> | 3 | 4 | 1 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_Fuel</code> | 2 | 3 | 0 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_IssueStable</code> | 26 | 3 | 1 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_IssueStablePool</code> | 3 | 2 | 0 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `DEFPACT-BILLING.repl` |
| <code>SWP&#124;C_IssueStandard</code> | 20 | 7 | 4 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` |
| <code>SWP&#124;C_IssueStandardPool</code> | 7 | 3 | 5 | `[RT-E]_Sequencing.repl`, `[RT-F]_Griefing.repl`, `DEFPACT-BILLING.repl` +1 |
| <code>SWP&#124;C_IssueWeighted</code> | 10 | 3 | 3 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_IssueWeightedPool</code> | 4 | 2 | 2 | `DEFPACT-BILLING.repl`, `SWP.repl` |
| <code>SWP&#124;C_ModifyCanChangeOwner</code> | 8 | 10 | 8 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_ModifyWeights</code> | 13 | 7 | 12 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_MultiSwapNoSlippage</code> | 5 | 5 | 4 | `[RT-H]_InputDomain.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_MultiSwapWithSlippage</code> | 3 | 2 | 0 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_RemoveLiquidity</code> | 4 | 6 | 1 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `STAGE-Z.repl` +1 |
| <code>SWP&#124;C_SingleSwapNoSlippage</code> | 6 | 9 | 5 | `[RT-F]_Griefing.repl`, `[RT-H]_InputDomain.repl`, `[6.3]_SWP.repl` +1 |
| <code>SWP&#124;C_SingleSwapWithSlippage</code> | 6 | 10 | 0 | `[RT-A]_Economics.repl`, `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl` +1 |
| <code>SWP&#124;C_SmartSwapNoSlippage</code> | 9 | 10 | 4 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_SmartSwapWithSlippage</code> | 5 | 15 | 0 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_ToggleAddLiquidity</code> | 29 | 17 | 10 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_ToggleFeeLock</code> | 3 | 3 | 0 | `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_ToggleSwapCapability</code> | 47 | 16 | 7 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_UpdateAmplifier</code> | 14 | 8 | 5 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_UpdateFee</code> | 24 | 6 | 3 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_UpdatePendingBranding</code> | 2 | 2 | 0 | `[6.4]_Admin.repl`, `SWP.repl` |
| <code>SWP&#124;C_UpdatePendingBrandingLPs</code> | 3 | 5 | 0 | `[6.4]_Admin.repl`, `SWP.repl` |
| <code>SWP&#124;C_UpdateSpecialFeeTargets</code> | 25 | 12 | 5 | `[6.2+3]_DPTF-SWP_Issuance-Only.repl`, `[6.3]_SWP.repl`, `SWP.repl` |
| <code>SWP&#124;C_UpgradeBranding</code> | 9 | 26 | 7 | `SWP.repl` |
| <code>SWP&#124;C_UpgradeBrandingLPs</code> | 2 | 6 | 0 | `[6.4]_Admin.repl`, `SWP.repl` |
| <code>VST&#124;C_Awake</code> | 3 | 19 | 0 | `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_CreateFrozenLink</code> | 9 | 14 | 3 | `[4.0]_Sovereign-Executor.repl`, `[5.3]_Launchpad.repl`, `SWP.repl` +2 |
| <code>VST&#124;C_CreateHibernatingLink</code> | 6 | 14 | 1 | `[4.0]_Sovereign-Executor.repl`, `ATS.repl`, `VST.repl` +1 |
| <code>VST&#124;C_CreateReservationLink</code> | 3 | 3 | 3 | `[4.0]_Sovereign-Executor.repl`, `VST.repl` |
| <code>VST&#124;C_CreateSleepingLink</code> | 7 | 8 | 1 | `[4.0]_Sovereign-Executor.repl`, `[6.3]_SWP.repl`, `SWP.repl` +2 |
| <code>VST&#124;C_CreateVestingLink</code> | 5 | 3 | 1 | `[4.0]_Sovereign-Executor.repl`, `ATS.repl`, `VST.repl` |
| <code>VST&#124;C_Freeze</code> | 5 | 9 | 0 | `[6.3]_SWP.repl`, `SWP.repl`, `VST.repl` +1 |
| <code>VST&#124;C_Hibernate</code> | 11 | 43 | 7 | `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Merge</code> | 5 | 19 | 4 | `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_RepurposeFrozen</code> | 6 | 10 | 2 | `[6.3]_SWP.repl`, `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_RepurposeHibernating</code> | 5 | 15 | 2 | `VST.repl` |
| <code>VST&#124;C_RepurposeMerge</code> | 3 | 2 | 0 | `[6.3]_SWP.repl`, `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_RepurposeReserved</code> | 3 | 10 | 1 | `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_RepurposeSleeping</code> | 3 | 16 | 0 | `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_RepurposeSlumber</code> | 3 | 13 | 2 | `VST.repl` |
| <code>VST&#124;C_RepurposeVested</code> | 3 | 10 | 1 | `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Reserve</code> | 5 | 10 | 1 | `[6.3]_SWP.repl`, `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Sleep</code> | 87 | 51 | 1 | `[6.3]_SWP.repl`, `[6.7]_VST.repl`, `[6.4]_AQP-TRIPLET-COLLECT.repl` +3 |
| <code>VST&#124;C_Slumber</code> | 3 | 7 | 3 | `VST.repl` |
| <code>VST&#124;C_ToggleTransferRoleFrozenDPTF</code> | 5 | 11 | 0 | `[6.7]_VST.repl`, `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_ToggleTransferRoleHibernatingDPOF</code> | 4 | 16 | 1 | `VST.repl` |
| <code>VST&#124;C_ToggleTransferRoleReservedDPTF</code> | 4 | 10 | 0 | `[6.7]_VST.repl`, `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_ToggleTransferRoleSleepingDPOF</code> | 5 | 15 | 1 | `[6.7]_VST.repl`, `[6.4]_AQP-TRIPLET-COLLECT.repl`, `VST.repl` +1 |
| <code>VST&#124;C_Unreserve</code> | 3 | 3 | 0 | `[6.3]_SWP.repl`, `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Unsleep</code> | 6 | 22 | 6 | `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Unvest</code> | 4 | 8 | 6 | `[6.3]_SWP.repl`, `VST.repl`, `vst-harness.repl` |
| <code>VST&#124;C_Vest</code> | 7 | 14 | 1 | `[6.3]_SWP.repl`, `VST.repl`, `vst-harness.repl` |

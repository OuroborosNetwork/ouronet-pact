# ATS — the autostake pool core

## What it is for

Pools that convert a staked token into a **receipt token whose value grows**. One number does the work:

```
index = total_staked / receipt_supply
```

Rewards raise the numerator and not the denominator, so every receipt gains value simultaneously, with no transaction and nothing to claim.

Full treatment: `25-defi/01-autostake-pools.md`.

## Where it sits

A Stage-1 core above the token modules. Four live pools chain into a ladder, each pool's receipt being the next one's deposit.

## What it owns, and what it exposes

<!-- @generated:module-page:ATS -->
**On chain**

| | |
|---|---|
| module hash | `q9egSXL5o_RR7TZyMOFRO9WW3G275XQwEaFSU4aSpps` |
| deployed size | 130,920 characters |
| implements | `OuronetPolicyV2`, `BrandingUsagePrimaryV2`, `AutostakeV3`, `AutostakeComputerV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact` |

**Tables it owns** — 4

`ATS|Ledger`, `ATS|Pairs`, `P|MT`, `P|T`

**Schemas** — 2

`ATS|BalanceSchemaV2`, `ATS|PropertiesSchemaV3`

**Capabilities** — 39

`AHU`, `ATS|C>ADD-HOT-RBT`, `ATS|C>ADD-REWARD-TOKEN`, `ATS|C>ADD-TOKEN`, `ATS|C>CONTROL-COLD-FEES`, `ATS|C>CONTROL-COLD-RECOVERY`, `ATS|C>CONTROL-HOT-FEE`, `ATS|C>CONTROL-HOT-RECOVERY`, `ATS|C>HOT-RBT-BRD`, `ATS|C>HOT-RBT-UPDATE-BRD`, `ATS|C>HOT-RBT-UPGRADE-BRD`, `ATS|C>ISSUE`, `ATS|C>REPURPOSE-HOT-RBT`, `ATS|C>SET_COLD-DURATION`, `ATS|C>SET_COLD_FEES`, `ATS|C>SET_DIRECT_FEE`, `ATS|C>SET_HOT_FEES`, `ATS|C>TOGGLE-PARAMETER-LOCK`, `ATS|C>TOGGLE_ELITE`, `ATS|C>TOGGLE_UPGRADE`, `ATS|C>UPDATE-BRD`, `ATS|C>UPGRADE-BRD`, `ATS|GOV`, `ATS|S>BRD`, `ATS|S>CONTROL`, `ATS|S>CONTROL-DIRECT-RECOVERY`, `ATS|S>CONTROL-RECOVERY`, `ATS|S>ROTATE_OWNERSHIP`, `ATS|S>ROYALTY`, `ATS|S>SET-HIBERNATION-FEES`, `ATS|S>SWITCH-COLD-RECOVERY`, `ATS|S>SWITCH-DIRECT-RECOVERY`, `ATS|S>SWITCH-HOT-RECOVERY`, `ATS|S>SYPHON`, `GOV`, `GOV|ATS_ADMIN`, `P|ATS|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 202, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 24 | returns what an operation will charge | `URCi_AddHotRBT`, `URCi_AddSecondary`, `URCi_Control`, `URCi_ControlColdRecoveryFees`, `URCi_ControlHotRecoveryFee`, `URCi_IssueGas` …+18 |
| `URCv_` derived reads (validating) | 3 | read + derive, with an intrinsic guard | `URCv_ColdRecoveryFee`, `URCv_RTSplitAmounts`, `URCv_RewardTokenPosition` |
| `URH_` heavy reads | 3 | a scan -- expensive by construction | `URH_ExistingAutostakePairs`, `URH_HeldAutostakePairs`, `URH_OwnedAutostakePairs` |
| `URC_` derived reads | 12 | read and derive; no enforce | `URC_AccountUnbondingBalance`, `URC_CullColdRecoveryTime`, `URC_CullValue`, `URC_Index`, `URC_IzPresentHotRBT`, `URC_MaxSyphon` …+6 |
| `UEV_` validators | 13 | read and enforce; may abort the transaction | `UEV_CanChangeOwnerON`, `UEV_CanUpgradeON`, `UEV_ColdRecoveryState`, `UEV_DirectRecoveryState`, `UEV_EliteState`, `UEV_ExecutorIsHotRbtOwner` …+7 |
| `UDC_` constructors | 10 | named object constructors | `UDC_CanBrumate`, `UDC_CanCoil`, `UDC_CanConstrict`, `UDC_CanCurl`, `UDC_CoilData`, `UDC_ComposePrimaryRewardToken` …+4 |
| `UCx_` pure compute (auxiliary) | 3 | a private helper of the function above it | `UCx_ChainsRtRbtSecondRt`, `UCx_FilterHibernatedAts`, `UCx_RewardTokenPairsByHibernate` |
| `UC_` pure compute | 5 | arguments only -- no reads, no enforce | `UC_AtspairAccount`, `UC_CanBrumate`, `UC_CanCoil`, `UC_CanConstrict`, `UC_CanCurl` |
| `UR_` readers | 42 | table reads; no enforce, no writes | `UR_CanChangeOwner`, `UR_CanUpgrade`, `UR_ColdNativeFeeRedirection`, `UR_ColdRecoveryDuration`, `UR_ColdRecoveryFeeRedirection`, `UR_ColdRecoveryFeeTable` …+36 |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_Owner` |
| `XI_` protected (internal) | 22 | this module only | `XI_AddHotRBT`, `XI_AddSecondary`, `XI_ChangeOwnership`, `XI_Control`, `XI_ControlColdFees`, `XI_ControlHotFee` …+16 |
| `XE_` protected (external) | 12 | for other modules; opens with the IMC gate | `XE_RemoveSecondary`, `XE_ReshapeUnstakeAccount`, `XE_SpawnAutostakeAccount`, `XE_UpP0`, `XE_UpP1`, `XE_UpP2` …+6 |
| `C_` client | 25 | reached via Talos, never called directly | `C_AddHotRBT`, `C_AddSecondary`, `C_Control`, `C_ControlColdRecoveryFees`, `C_ControlHotRecoveryFee`, `C_Issue` …+19 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 18 | carries no StoicSyntax prefix | `AU_AutostakePair`, `AU_AutostakePairs`, `AU_UnstakeAccount`, `AU_UnstakeAccounts`, `CT_Bar`, `CT_EmptyCumulator` …+12 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `ATS|Hot`, `ATS|RewardTokenSchemaV2`, `CanBrumate`, `CanCoil`, `CanConstrict`, `CanCurl`, `CoilData`

**Capabilities** -- 39

`AHU`, `ATS|C>ADD-HOT-RBT`, `ATS|C>ADD-REWARD-TOKEN`, `ATS|C>ADD-TOKEN`, `ATS|C>CONTROL-COLD-FEES`, `ATS|C>CONTROL-COLD-RECOVERY`, `ATS|C>CONTROL-HOT-FEE`, `ATS|C>CONTROL-HOT-RECOVERY`, `ATS|C>HOT-RBT-BRD`, `ATS|C>HOT-RBT-UPDATE-BRD`, `ATS|C>HOT-RBT-UPGRADE-BRD`, `ATS|C>ISSUE`, `ATS|C>REPURPOSE-HOT-RBT`, `ATS|C>SET_COLD-DURATION`, `ATS|C>SET_COLD_FEES`, `ATS|C>SET_DIRECT_FEE`, `ATS|C>SET_HOT_FEES`, `ATS|C>TOGGLE-PARAMETER-LOCK`, `ATS|C>TOGGLE_ELITE`, `ATS|C>TOGGLE_UPGRADE`, `ATS|C>UPDATE-BRD`, `ATS|C>UPGRADE-BRD`, `ATS|GOV`, `ATS|S>BRD`, `ATS|S>CONTROL`, `ATS|S>CONTROL-DIRECT-RECOVERY`, `ATS|S>CONTROL-RECOVERY`, `ATS|S>ROTATE_OWNERSHIP`, `ATS|S>ROYALTY`, `ATS|S>SET-HIBERNATION-FEES`, `ATS|S>SWITCH-COLD-RECOVERY`, `ATS|S>SWITCH-DIRECT-RECOVERY`, `ATS|S>SWITCH-HOT-RECOVERY`, `ATS|S>SYPHON`, `GOV`, `GOV|ATS_ADMIN`, `P|ATS|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 202, grouped by what the prefix promises

*Cost readers* (24) — price an operation; the exec path and the preview both call these

`URCi_AddHotRBT`, `URCi_AddSecondary`, `URCi_Control`, `URCi_ControlColdRecoveryFees`, `URCi_ControlHotRecoveryFee`, `URCi_IssueGas`, `URCi_IssueStoa`, `URCi_RotateOwnership`, `URCi_SetColdRecoveryDuration`, `URCi_SetColdRecoveryFees`, `URCi_SetDirectRecoveryFee`, `URCi_SetHibernationFees`, `URCi_SetHotRecoveryFees`, `URCi_SwitchColdRecovery`, `URCi_SwitchDirectRecovery`, `URCi_SwitchHotRecovery`, `URCi_ToggleElite`, `URCi_ToggleParameterLock`, `URCi_ToggleParameterLockStoa`, `URCi_ToggleUpgrade`, `URCi_UpdatePendingBranding`, `URCi_UpdateRoyalty`, `URCi_UpdateSyphon`, `URCi_UpgradeBranding`

*Heavy reads* (3) — scan a table -- OFF the execution path, cost grows with data

`URH_ExistingAutostakePairs`, `URH_HeldAutostakePairs`, `URH_OwnedAutostakePairs`

*Derived reads* (12) — read and compute; no enforce

`URC_AccountUnbondingBalance`, `URC_CullColdRecoveryTime`, `URC_CullValue`, `URC_Index`, `URC_IzPresentHotRBT`, `URC_MaxSyphon`, `URC_PairRBTSupply`, `URC_RBT`, `URC_ResidentSum`, `URC_RewardBearingTokenAmounts`, `URC_RewardBearingTokenAmountsWithHibernation`, `URC_WhichPosition`

*Point reads* (43) — one row or field by key

`P|UR_IMP`, `UR_CanChangeOwner`, `UR_CanUpgrade`, `UR_ColdNativeFeeRedirection`, `UR_ColdRecoveryDuration`, `UR_ColdRecoveryFeeRedirection`, `UR_ColdRecoveryFeeTable`, `UR_ColdRecoveryFeeThresholds`, `UR_ColdRecoveryPositions`, `UR_ColdRewardBearingToken`, `UR_DirectRecoveryFee`, `UR_EliteMode`, `UR_Hibernate`, `UR_HibernateDecay`, `UR_HotRecoveryDecayPeriod`, `UR_HotRecoveryFeeRedirection`, `UR_HotRecoveryStartingFeePromile`, `UR_HotRewardBearingToken`, `UR_IndexDecimals`, `UR_IndexName`, `UR_KEYS`, `UR_Lock`, `UR_OwnerKonto`, `UR_P-KEYS`, `UR_P-Seven`, `UR_P0`, `UR_P1-7`, `UR_PeakHibernatePromile`, `UR_Properties`, `UR_RewardTokenList`, `UR_RewardTokenNFR`, `UR_RewardTokenRUR`, `UR_RewardTokens`, `UR_Royalty`, `UR_RtPrecisions`, `UR_SingleRewardTokenNFR`, `UR_SingleRewardTokenRUR`, `UR_Syphon`, `UR_Syphoning`, `UR_ToggleColdRecovery`, `UR_ToggleDirectRecovery`, `UR_ToggleHotRecovery`, `UR_Unlocks`

*Validators* (14) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_CanChangeOwnerON`, `UEV_CanUpgradeON`, `UEV_ColdRecoveryState`, `UEV_DirectRecoveryState`, `UEV_EliteState`, `UEV_ExecutorIsHotRbtOwner`, `UEV_ExecutorIsOwnerKonto`, `UEV_HotRecoveryState`, `UEV_IssueData`, `UEV_ParameterLockState`, `UEV_RewardBearingTokenExistance`, `UEV_RewardTokenExistance`, `UEV_id`

*Constructors* (10) — build objects

`UDC_CanBrumate`, `UDC_CanCoil`, `UDC_CanConstrict`, `UDC_CanCurl`, `UDC_CoilData`, `UDC_ComposePrimaryRewardToken`, `UDC_MakeNegativeUnstakeObject`, `UDC_MakeUnstakeObject`, `UDC_MakeZeroUnstakeObject`, `UDC_RT`

*Pure compute* (5) — arguments only; no reads, no enforce

`UC_AtspairAccount`, `UC_CanBrumate`, `UC_CanCoil`, `UC_CanConstrict`, `UC_CanCurl`

*Ownership checks* (1) — account-ownership enforcement

`CAP_Owner`

*Client entry* (25) — builds the bill; reachable only through Talos

`C_AddHotRBT`, `C_AddSecondary`, `C_Control`, `C_ControlColdRecoveryFees`, `C_ControlHotRecoveryFee`, `C_Issue`, `C_RotateOwnership`, `C_SetColdRecoveryDuration`, `C_SetColdRecoveryFees`, `C_SetDirectRecoveryFee`, `C_SetHibernationFees`, `C_SetHotRecoveryFees`, `C_SwitchColdRecovery`, `C_SwitchDirectRecovery`, `C_SwitchHotRecovery`, `C_ToggleElite`, `C_ToggleParameterLock`, `C_ToggleUpgrade`, `C_UpdatePendingBranding`, `C_UpdateRoyalty`, `C_UpdateSyphon`, `C_UpgradeBranding`, `HOT-RBT|C_Repurpose`, `HOT-RBT|C_UpdatePendingBranding`, `HOT-RBT|C_UpgradeBranding`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (12) — callable by other modules only

`XE_RemoveSecondary`, `XE_ReshapeUnstakeAccount`, `XE_SpawnAutostakeAccount`, `XE_UpP0`, `XE_UpP1`, `XE_UpP2`, `XE_UpP3`, `XE_UpP4`, `XE_UpP5`, `XE_UpP6`, `XE_UpP7`, `XE_UpdateRUR`

*Internal writes* (22) — this module only; writes under a capability

`XI_AddHotRBT`, `XI_AddSecondary`, `XI_ChangeOwnership`, `XI_Control`, `XI_ControlColdFees`, `XI_ControlHotFee`, `XI_FoldedIssue`, `XI_IncrementParameterUnlocks`, `XI_Issue`, `XI_SetCRD`, `XI_SetColdFee`, `XI_SetDirectFee`, `XI_SetHibernationFees`, `XI_SetHotFees`, `XI_SwitchColdRecovery`, `XI_SwitchDirectRecovery`, `XI_SwitchHotRecovery`, `XI_ToggleElite`, `XI_ToggleParameterLock`, `XI_ToggleUpgrade`, `XI_UpdateRoyalty`, `XI_UpdateSyphon`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (3) — keysets and protocol constants

`GOV|ATS|SC_NAME`, `GOV|AutostakeKey`, `GOV|Demiurgoi`

*Unclassified* (21) — no known prefix -- worth asking why

`AU_AutostakePair`, `AU_AutostakePairs`, `AU_UnstakeAccount`, `AU_UnstakeAccounts`, `CT_Bar`, `CT_EmptyCumulator`, `UCx_ChainsRtRbtSecondRt`, `UCx_FilterHibernatedAts`, `UCx_RewardTokenPairsByHibernate`, `UDCx_Balance`, `URCv_ColdRecoveryFee`, `URCv_RTSplitAmounts`, `URCv_RewardTokenPosition`, `URCx_ElitePosition`, `URCx_NonElitePosition`, `URCx_PSL`, `URCx_PosObjSt`, `URCx_PosSt`, `URCx_RBT-Amount`, `URCx_UnstakeObjectUnbondingValue`, `URU_UpgradeAtspairToV2`

**Client entrypoints** -- 3

| entrypoint | preview |
|---|---|
| `ATS.HOT-RBT|C_Repurpose` | `INFO-ONE.INFO_ATS|HOT-RBT|Repurpose` |
| `ATS.HOT-RBT|C_UpdatePendingBranding` | `INFO-ONE.INFO_ATS|HOT-RBT|UpdatePendingBranding` |
| `ATS.HOT-RBT|C_UpgradeBranding` | `INFO-ONE.INFO_ATS|HOT-RBT|UpgradeBranding` |
<!-- @end:module-page:ATS -->

## Traps

**Converting divides by the index, so index zero is a division by zero** — and it is reachable, not contrived: any pool whose receipt carries supply minted *outside* it reads zero stake against positive supply, which is the state the primal-asset pools are in at deploy. One entry point refused; another died inside the arithmetic, which `try` cannot catch, so it took down every caller rather than degrading one field. The guard now lives in the conversion itself.

**The reward-token and reward-bearing-token fields mean opposite things depending on which row you read** — lists of pools on a token, token identifiers on a pool. Combined with the `"|"` sentinel this produced a failure measured on mainnet: a sentinel reached a table read and killed the read an entire interface toolbar was built from.

**Nine of fifteen live pools have no hot-recovery token**, so that reader returns the sentinel for most of them.

**Hibernation mode is global to a pool**, deciding which two of four entry operations exist for everyone.

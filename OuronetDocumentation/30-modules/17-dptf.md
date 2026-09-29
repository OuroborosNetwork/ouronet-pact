# DPTF — the true-fungible token core

## What it is for

The ordinary kind of token — a balance per holder, divisible, interchangeable. The busiest asset in the system: the protocol token, virtual gas, every LP token and every autostake receipt is one.

Beyond balances it holds four grantable roles, a per-holder freeze, a two-part fee system including a progressive tax, two wipe modes, and five permanent links to derived token forms.

Full treatment: `20-assets/01-true-fungibles.md`.

## Where it sits

A Stage-1 core, deployed after the account and gas cores and before everything that moves or pools value.

## What it owns, and what it exposes

<!-- @generated:module-page:DPTF -->
**On chain**

| | |
|---|---|
| module hash | `Rqg1FTijxUvIMYG3NBiAgc0Mgeg-gN6tGGuK7-CQPTo` |
| deployed size | 122,663 characters |
| implements | `OuronetPolicyV2`, `BrandingUsagePrimaryV2`, `DemiourgosPactTrueFungibleV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact` |

**Tables it owns** — 5

`DPTF|BalanceTable`, `DPTF|PropertiesTable`, `DPTF|RoleTable`, `P|MT`, `P|T`

**Schemas** — 2

`DPTF|PropertiesSchema`, `DPTF|RoleSchema`

**Capabilities** — 40

`AHU`, `DPTF|C>BURN`, `DPTF|C>CREDIT`, `DPTF|C>DEBIT`, `DPTF|C>FREEZE`, `DPTF|C>ISSUE`, `DPTF|C>MINT`, `DPTF|C>TOGGLE-BURN-ROLE`, `DPTF|C>TOGGLE-FEE-EXEMPTION-ROLE`, `DPTF|C>TOGGLE-MINT-ROLE`, `DPTF|C>TOGGLE_FEE-LOCK`, `DPTF|C>TOGGLE_TRANSFER-ROLE`, `DPTF|C>UPDATE-BRD`, `DPTF|C>UPDATE-SPECIAL`, `DPTF|C>UPGRADE-BRD`, `DPTF|C>WIPE`, `DPTF|C>WIPE-SLIM`, `DPTF|C>X_FREEZE`, `DPTF|C>X_TOGGLE-BURN-ROLE`, `DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE`, `DPTF|C>X_TOGGLE-MINT-ROLE`, `DPTF|C>X_TOGGLE-TRANSFER-ROLE`, `DPTF|C>X_WIPE`, `DPTF|S>CONTROL`, `DPTF|S>ROTATE-OWNERSHIP`, `DPTF|S>SET_FEE`, `DPTF|S>SET_FEE-TARGET`, `DPTF|S>SET_MIN-MOVE`, `DPTF|S>TOGGLE_FEE`, `DPTF|S>TOGGLE_PAUSE`, `DPTF|S>TOGGLE_RESERVATION`, `DPTF|S>X_TG_FEE-LOCK`, `GOV`, `GOV|DPTF_ADMIN`, `GOV|SET_TREASURY-DISPO`, `GOV|WIPE_ALL-TREASURY-DEBT`, `GOV|WIPE_PARTIAL-TREASURY-DEBT`, `P|DPTF|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 200, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 25 | returns what an operation will charge | `URCi_Burn`, `URCi_Control`, `URCi_DeployAccount`, `URCi_IssueGas`, `URCi_IssueStoa`, `URCi_Mint` …+19 |
| `URCv_` derived reads (validating) | 1 | read + derive, with an intrinsic guard | `URCv_Parent` |
| `URH_` heavy reads | 3 | a scan -- expensive by construction | `URH_ExistingTrueFungibles`, `URH_HeldTrueFungibles`, `URH_OwnedTrueFungibles` |
| `URC_` derived reads | 12 | read and derive; no enforce | `URC_Fee`, `URC_HasFrozen`, `URC_HasHibernation`, `URC_HasReserved`, `URC_HasSleeping`, `URC_HasVesting` …+6 |
| `UEV_` validators | 28 | read and enforce; may abort the transaction | `UEV_AccountBurnState`, `UEV_AccountFeeExemptionState`, `UEV_AccountFreezeState`, `UEV_AccountMintState`, `UEV_AccountTransferState`, `UEV_Amount` …+22 |
| `UDC_` constructors | 2 | named object constructors | `UDC_TrueFungibleAccount`, `UDC_VerumRoles` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_IdAccount`, `UC_TreasuryLowestDispo`, `UC_VolumetricTax` |
| `UR_` readers | 45 | table reads; no enforce, no writes | `UR_AccountFrozenState`, `UR_AccountRoleBurn`, `UR_AccountRoleFeeExemption`, `UR_AccountRoleMint`, `UR_AccountRoleTransfer`, `UR_AccountSupply` …+39 |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_Owner` |
| `WW_` writers (upsert) | 1 | one write site each | `WW_UpdateBalance` |
| `XI_` protected (internal) | 23 | this module only | `XI_ChangeOwnership`, `XI_Control`, `XI_SetFee`, `XI_SetFeeTarget`, `XI_SetMinMove`, `XI_ToggleBurnRole` …+17 |
| `XE_` protected (external) | 8 | for other modules; opens with the IMC gate | `XE_IssueLP`, `XE_UpdateFeeVolume`, `XE_UpdateHibernation`, `XE_UpdateRewardBearingToken`, `XE_UpdateRewardToken`, `XE_UpdateSleeping` …+2 |
| `XB_` protected (both) | 4 | internal and external | `XB_CreditTrueFungible`, `XB_DebitTrueFungible`, `XB_DeployAccountWNE`, `XB_IssueFree` |
| `A_` admin | 3 | admin-key mutations | `A_UpdateTreasury`, `A_WipeTreasuryDebt`, `A_WipeTreasuryDebtPartial` |
| `C_` client | 21 | reached via Talos, never called directly | `C_Burn`, `C_Control`, `C_Issue`, `C_Mint`, `C_RotateOwnership`, `C_SetFee` …+15 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 11 | carries no StoicSyntax prefix | `AU_TrueFungible`, `AU_TrueFungibleAccount`, `AU_TrueFungibleAccounts`, `AU_TrueFungibles`, `CT_Bar`, `GOV|Demiurgoi` …+5 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 40

`AHU`, `DPTF|C>BURN`, `DPTF|C>CREDIT`, `DPTF|C>DEBIT`, `DPTF|C>FREEZE`, `DPTF|C>ISSUE`, `DPTF|C>MINT`, `DPTF|C>TOGGLE-BURN-ROLE`, `DPTF|C>TOGGLE-FEE-EXEMPTION-ROLE`, `DPTF|C>TOGGLE-MINT-ROLE`, `DPTF|C>TOGGLE_FEE-LOCK`, `DPTF|C>TOGGLE_TRANSFER-ROLE`, `DPTF|C>UPDATE-BRD`, `DPTF|C>UPDATE-SPECIAL`, `DPTF|C>UPGRADE-BRD`, `DPTF|C>WIPE`, `DPTF|C>WIPE-SLIM`, `DPTF|C>X_FREEZE`, `DPTF|C>X_TOGGLE-BURN-ROLE`, `DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE`, `DPTF|C>X_TOGGLE-MINT-ROLE`, `DPTF|C>X_TOGGLE-TRANSFER-ROLE`, `DPTF|C>X_WIPE`, `DPTF|S>CONTROL`, `DPTF|S>ROTATE-OWNERSHIP`, `DPTF|S>SET_FEE`, `DPTF|S>SET_FEE-TARGET`, `DPTF|S>SET_MIN-MOVE`, `DPTF|S>TOGGLE_FEE`, `DPTF|S>TOGGLE_PAUSE`, `DPTF|S>TOGGLE_RESERVATION`, `DPTF|S>X_TG_FEE-LOCK`, `GOV`, `GOV|DPTF_ADMIN`, `GOV|SET_TREASURY-DISPO`, `GOV|WIPE_ALL-TREASURY-DEBT`, `GOV|WIPE_PARTIAL-TREASURY-DEBT`, `P|DPTF|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 200, grouped by what the prefix promises

*Cost readers* (25) — price an operation; the exec path and the preview both call these

`URCi_Burn`, `URCi_Control`, `URCi_DeployAccount`, `URCi_IssueGas`, `URCi_IssueStoa`, `URCi_Mint`, `URCi_RotateOwnership`, `URCi_SetFee`, `URCi_SetFeeTarget`, `URCi_SetMinMove`, `URCi_ToggleBurnRole`, `URCi_ToggleFee`, `URCi_ToggleFeeExemptionRole`, `URCi_ToggleFeeLock`, `URCi_ToggleFeeLockStoa`, `URCi_ToggleFreezeAccount`, `URCi_ToggleMintRole`, `URCi_TogglePause`, `URCi_ToggleReservation`, `URCi_ToggleTransferRole`, `URCi_UpdatePendingBranding`, `URCi_UpdateSpecialTrueFungible`, `URCi_UpgradeBranding`, `URCi_Wipe`, `URCi_WipeSlim`

*Heavy reads* (3) — scan a table -- OFF the execution path, cost grows with data

`URH_ExistingTrueFungibles`, `URH_HeldTrueFungibles`, `URH_OwnedTrueFungibles`

*Derived reads* (12) — read and compute; no enforce

`URC_Fee`, `URC_HasFrozen`, `URC_HasHibernation`, `URC_HasReserved`, `URC_HasSleeping`, `URC_HasVesting`, `URC_IzCoreDPTF`, `URC_IzRBT`, `URC_IzRBTg`, `URC_IzRT`, `URC_IzRTg`, `URC_TreasuryLowestDispo`

*Point reads* (46) — one row or field by key

`P|UR_IMP`, `UR_AccountFrozenState`, `UR_AccountRoleBurn`, `UR_AccountRoleFeeExemption`, `UR_AccountRoleMint`, `UR_AccountRoleTransfer`, `UR_AccountSupply`, `UR_CanAddSpecialRole`, `UR_CanChangeOwner`, `UR_CanFreeze`, `UR_CanPause`, `UR_CanUpgrade`, `UR_CanWipe`, `UR_Decimals`, `UR_FeeLock`, `UR_FeePromile`, `UR_FeeTarget`, `UR_FeeToggle`, `UR_FeeUnlocks`, `UR_Frozen`, `UR_Hibernation`, `UR_IzAccount`, `UR_IzId`, `UR_IzReservationOpen`, `UR_KEYS`, `UR_Konto`, `UR_MinMove`, `UR_Name`, `UR_OriginAmount`, `UR_OriginMint`, `UR_P-KEYS`, `UR_Paused`, `UR_PrimaryFeeVolume`, `UR_Reservation`, `UR_RewardBearingToken`, `UR_RewardToken`, `UR_SecondaryFeeVolume`, `UR_Sleeping`, `UR_Supply`, `UR_Ticker`, `UR_Verum1`, `UR_Verum2`, `UR_Verum3`, `UR_Verum4`, `UR_Verum5`, `UR_Vesting`

*Validators* (29) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AccountBurnState`, `UEV_AccountFeeExemptionState`, `UEV_AccountFreezeState`, `UEV_AccountMintState`, `UEV_AccountTransferState`, `UEV_Amount`, `UEV_CanAddSpecialRoleON`, `UEV_CanChangeOwnerON`, `UEV_CanFreezeON`, `UEV_CanPauseON`, `UEV_CanUpgradeON`, `UEV_CanWipeON`, `UEV_CheckAmount`, `UEV_CheckID`, `UEV_ExecutorIsKonto`, `UEV_ExecutorIsParentKonto`, `UEV_FeeLockState`, `UEV_FeeToggleState`, `UEV_Frozen`, `UEV_Hibernation`, `UEV_ParentOwnership`, `UEV_PauseState`, `UEV_ReservationState`, `UEV_Reserved`, `UEV_Sleeping`, `UEV_Vesting`, `UEV_Virgin`, `UEV_id`

*Constructors* (2) — build objects

`UDC_TrueFungibleAccount`, `UDC_VerumRoles`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_IdAccount`, `UC_TreasuryLowestDispo`, `UC_VolumetricTax`

*Ownership checks* (1) — account-ownership enforcement

`CAP_Owner`

*Client entry* (21) — builds the bill; reachable only through Talos

`C_Burn`, `C_Control`, `C_Issue`, `C_Mint`, `C_RotateOwnership`, `C_SetFee`, `C_SetFeeTarget`, `C_SetMinMove`, `C_ToggleBurnRole`, `C_ToggleFee`, `C_ToggleFeeExemptionRole`, `C_ToggleFeeLock`, `C_ToggleFreezeAccount`, `C_ToggleMintRole`, `C_TogglePause`, `C_ToggleReservation`, `C_ToggleTransferRole`, `C_UpdatePendingBranding`, `C_UpgradeBranding`, `C_Wipe`, `C_WipeSlim`

*Admin* (8) — admin-key mutations

`A_UpdateTreasury`, `A_WipeTreasuryDebt`, `A_WipeTreasuryDebtPartial`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (8) — callable by other modules only

`XE_IssueLP`, `XE_UpdateFeeVolume`, `XE_UpdateHibernation`, `XE_UpdateRewardBearingToken`, `XE_UpdateRewardToken`, `XE_UpdateSleeping`, `XE_UpdateSpecialTrueFungible`, `XE_UpdateVesting`

*Internal + external* (4) — callable both ways

`XB_CreditTrueFungible`, `XB_DebitTrueFungible`, `XB_DeployAccountWNE`, `XB_IssueFree`

*Internal writes* (23) — this module only; writes under a capability

`XI_ChangeOwnership`, `XI_Control`, `XI_SetFee`, `XI_SetFeeTarget`, `XI_SetMinMove`, `XI_ToggleBurnRole`, `XI_ToggleFee`, `XI_ToggleFeeExemptionRole`, `XI_ToggleFeeLock`, `XI_ToggleFreezeAccount`, `XI_ToggleMintRole`, `XI_TogglePause`, `XI_ToggleReservation`, `XI_ToggleTransferRole`, `XI_UpdateBalance`, `XI_UpdateFrozen`, `XI_UpdateReserved`, `XI_UpdateVerum1`, `XI_UpdateVerum2`, `XI_UpdateVerum3`, `XI_UpdateVerum4`, `XI_UpdateVerum5`, `XI_WriteRoles`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (12) — no known prefix -- worth asking why

`AU_TrueFungible`, `AU_TrueFungibleAccount`, `AU_TrueFungibleAccounts`, `AU_TrueFungibles`, `CT_Bar`, `URCv_Parent`, `URU_UpgradeTruefungibleToV2`, `WW_UpdateBalance`, `XBv_DeployAccount`, `XBv_UpdateSupply`, `XIv_IncrementFeeUnlocks`, `XIv_Issue`
<!-- @end:module-page:DPTF -->

## Traps

**Two tokens do not use the balance table.** The protocol token and virtual gas live directly on the account row, and code that freezes an account has to branch on it. Bootstrapping: the gas token must be spendable before the token module is fully wired.

**Granting a role is gated; revoking one is not.** The issuance flag controls granting only. An issuer who switched off role-granting can still take a role away — the alternative traps a mistake permanently.

**Unset links read as `"|"`, never empty.** All five special-link fields use the sentinel.

**A special link, once created, can never be changed or removed.** The capability enforcing that is annotated as unreachable by construction and kept anyway, as a fail-closed backstop.

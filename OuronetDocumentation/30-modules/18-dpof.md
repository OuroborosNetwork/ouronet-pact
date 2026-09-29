# DPOF — the orto-fungible token core

## What it is for

The type with no equivalent in most token systems. An orto-fungible holding is not a balance — it is a **parcel**: an indivisible object with its own contents, its own quantity, and exactly one holder.

The source states it in a line: *nonces can't be separated; an orto-fungible nonce has one unique holder.* Every vested, sleeping and hibernating position in the system is one of these.

Full treatment: `20-assets/02-orto-fungibles.md`.

## Where it sits

A Stage-1 core beside the true-fungible one, and the successor to the archived metadata-fungible module.

## What it owns, and what it exposes

<!-- @generated:module-page:DPOF -->
**On chain**

| | |
|---|---|
| module hash | `ww5ZiESbMsAY8GpyC6BabJSxKb0QR75dCesJbv4JXZo` |
| deployed size | 128,815 characters |
| implements | `OuronetPolicyV2`, `BrandingUsagePrimaryV2`, `DemiourgosPactOrtoFungibleV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact` |

**Tables it owns** — 6

`DPOF|T|AccountRoles`, `DPOF|T|Nonces`, `DPOF|T|Properties`, `DPOF|T|VerumRoles`, `P|MT`, `P|T`

**Schemas** — 1

`TransmitData`

**Capabilities** — 39

`AHU`, `DPOF|C>ADD-QTY`, `DPOF|C>BULK-TRANSFER`, `DPOF|C>BURN`, `DPOF|C>CREDIT`, `DPOF|C>DEBIT`, `DPOF|C>FREEZE`, `DPOF|C>ISSUE`, `DPOF|C>MINT`, `DPOF|C>SWITCH-CREATE-ROLE`, `DPOF|C>TOGGLE-ADD-QUANTITY-ROLE`, `DPOF|C>TOGGLE-BURN-ROLE`, `DPOF|C>TOGGLE-TRANSFER-ROLE`, `DPOF|C>TRANSFER`, `DPOF|C>TRANSMIT`, `DPOF|C>UPDATE-BRD`, `DPOF|C>UPDATE-SPECIAL`, `DPOF|C>UPGRADE-BRD`, `DPOF|C>WIPE`, `DPOF|C>WIPE-SLIM`, `DPOF|C>X_WIPE`, `DPOF|S>BULK-MOVE`, `DPOF|S>CONTROL`, `DPOF|S>CREDIT-CONSECUTIVE`, `DPOF|S>CREDIT-SINGULAR`, `DPOF|S>MOVE`, `DPOF|S>PAUSE`, `DPOF|S>ROTATE-OWNERSHIP`, `DPOF|S>X_FREEZE`, `DPOF|S>X_SWITCH-CREATE-ROLE`, `DPOF|S>X_TOGGLE-ADD-QUANTITY-ROLE`, `DPOF|S>X_TOGGLE-BURN-ROLE`, `DPOF|S>X_TOGGLE-TRANSFER-ROLE`, `GOV`, `GOV|DPOF_ADMIN`, `P|DPOF|CALLER`, `P|SECURE-CALLER`, `SECURE`, `SECURE-ADMIN`

**Functions** — 197, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 20 | returns what an operation will charge | `URCi_AddQuantity`, `URCi_Burn`, `URCi_Control`, `URCi_DeployAccount`, `URCi_IssueGas`, `URCi_IssueStoa` …+14 |
| `URCv_` derived reads (validating) | 1 | read + derive, with an intrinsic guard | `URCv_Parent` |
| `URHC_` heavy derived reads | 2 | a scan, then derivation | `URHC_BuildWipeSlicePlan`, `URHC_WipePure` |
| `URH_` heavy reads | 4 | a scan -- expensive by construction | `URH_AccountNonces`, `URH_ExistingOrtoFungibles`, `URH_HeldOrtoFungibles`, `URH_OwnedOrtoFungibles` |
| `URC_` derived reads | 6 | read and derive; no enforce | `URC_BrandingKonto`, `URC_HasHibernation`, `URC_HasSleeping`, `URC_HasVesting`, `URC_IzRBT`, `URC_IzRBTg` |
| `UEV_` validators | 27 | read and enforce; may abort the transaction | `UEV_AccountAddQuantityState`, `UEV_AccountBurnState`, `UEV_AccountCreateState`, `UEV_AccountFreezeState`, `UEV_AccountTransferState`, `UEV_Amount` …+21 |
| `UDC_` constructors | 5 | named object constructors | `UDC_AccountRoles`, `UDC_NonceElement`, `UDC_RemovableNonces`, `UDC_VerumRoles`, `UDC_WipeSlicePlan` |
| `UCv_` pure compute (validating) | 1 | compute with an intrinsic guard | `UCv_TakePureWipe` |
| `UC_` pure compute | 8 | arguments only -- no reads, no enforce | `UC_BuildWipeSlicePlan`, `UC_CeilDiv`, `UC_ComputeMinWipeSliceCount`, `UC_FlattenNoncesArray`, `UC_IdAccount`, `UC_IdNonce` …+2 |
| `UR_` readers | 45 | table reads; no enforce, no writes | `UR_AccountSupply`, `UR_CanAddSpecialRole`, `UR_CanChangeOwner`, `UR_CanFreeze`, `UR_CanPause`, `UR_CanTransferOftCreateRole` …+39 |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_Owner` |
| `XI_` protected (internal) | 28 | this module only | `XI_ChangeOwnership`, `XI_Control`, `XI_CreditNonces`, `XI_DebitNonces`, `XI_IncrementNoncesExcludedBy`, `XI_InsertNewId` …+22 |
| `XE_` protected (external) | 2 | for other modules; opens with the IMC gate | `XE_UpdateRewardBearingToken`, `XE_UpdateSpecialOrtoFungible` |
| `XB_` protected (both) | 3 | internal and external | `XB_DeployAccountWNE`, `XB_InsertNewNonce`, `XB_IssueFree` |
| `CC_` client (heavy) | 1 | client entrypoint; reaches a scan | `CC_WipeHeavy` |
| `Cp_` client recipe | 1 | multi-transaction | `Cp_WipeSlice` |
| `C_` client | 20 | reached via Talos, never called directly | `C_AddQuantity`, `C_BulkTransfer`, `C_Burn`, `C_Control`, `C_Issue`, `C_Mint` …+14 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 13 | carries no StoicSyntax prefix | `AU_OrtoFungible`, `AU_OrtoFungibleAccount`, `AU_OrtoFungibleAccounts`, `AU_OrtoFungibles`, `CT_Bar`, `CT_Namespace` …+7 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `DPOF|AccountRoles`, `DPOF|NonceElement`, `DPOF|Properties`, `DPOF|VerumRoles`, `DPOF|WipeSlicePlan`, `RemovableNonces`

**Capabilities** -- 39

`AHU`, `DPOF|C>ADD-QTY`, `DPOF|C>BULK-TRANSFER`, `DPOF|C>BURN`, `DPOF|C>CREDIT`, `DPOF|C>DEBIT`, `DPOF|C>FREEZE`, `DPOF|C>ISSUE`, `DPOF|C>MINT`, `DPOF|C>SWITCH-CREATE-ROLE`, `DPOF|C>TOGGLE-ADD-QUANTITY-ROLE`, `DPOF|C>TOGGLE-BURN-ROLE`, `DPOF|C>TOGGLE-TRANSFER-ROLE`, `DPOF|C>TRANSFER`, `DPOF|C>TRANSMIT`, `DPOF|C>UPDATE-BRD`, `DPOF|C>UPDATE-SPECIAL`, `DPOF|C>UPGRADE-BRD`, `DPOF|C>WIPE`, `DPOF|C>WIPE-SLIM`, `DPOF|C>X_WIPE`, `DPOF|S>BULK-MOVE`, `DPOF|S>CONTROL`, `DPOF|S>CREDIT-CONSECUTIVE`, `DPOF|S>CREDIT-SINGULAR`, `DPOF|S>MOVE`, `DPOF|S>PAUSE`, `DPOF|S>ROTATE-OWNERSHIP`, `DPOF|S>X_FREEZE`, `DPOF|S>X_SWITCH-CREATE-ROLE`, `DPOF|S>X_TOGGLE-ADD-QUANTITY-ROLE`, `DPOF|S>X_TOGGLE-BURN-ROLE`, `DPOF|S>X_TOGGLE-TRANSFER-ROLE`, `GOV`, `GOV|DPOF_ADMIN`, `P|DPOF|CALLER`, `P|SECURE-CALLER`, `SECURE`, `SECURE-ADMIN`

**Functions** -- 197, grouped by what the prefix promises

*Cost readers* (20) — price an operation; the exec path and the preview both call these

`URCi_AddQuantity`, `URCi_Burn`, `URCi_Control`, `URCi_DeployAccount`, `URCi_IssueGas`, `URCi_IssueStoa`, `URCi_Mint`, `URCi_MoveCreateRole`, `URCi_MoveCumulator`, `URCi_RotateOwnership`, `URCi_ToggleAddQuantityRole`, `URCi_ToggleBurnRole`, `URCi_ToggleFreezeAccount`, `URCi_TogglePause`, `URCi_ToggleTransferRole`, `URCi_UpdatePendingBranding`, `URCi_UpdateSpecialOrtoFungible`, `URCi_UpgradeBranding`, `URCi_WipeCumulator`, `URCi_WipeSlim`

*Heavy derived reads* (2) — scan and derive -- OFF the execution path

`URHC_BuildWipeSlicePlan`, `URHC_WipePure`

*Heavy reads* (4) — scan a table -- OFF the execution path, cost grows with data

`URH_AccountNonces`, `URH_ExistingOrtoFungibles`, `URH_HeldOrtoFungibles`, `URH_OwnedOrtoFungibles`

*Derived reads* (6) — read and compute; no enforce

`URC_BrandingKonto`, `URC_HasHibernation`, `URC_HasSleeping`, `URC_HasVesting`, `URC_IzRBT`, `URC_IzRBTg`

*Point reads* (46) — one row or field by key

`P|UR_IMP`, `UR_AccountSupply`, `UR_CanAddSpecialRole`, `UR_CanChangeOwner`, `UR_CanFreeze`, `UR_CanPause`, `UR_CanTransferOftCreateRole`, `UR_CanUpgrade`, `UR_CanWipe`, `UR_Decimals`, `UR_Hibernation`, `UR_IsPaused`, `UR_IzAccount`, `UR_IzId`, `UR_IzNonce`, `UR_KEYS`, `UR_Konto`, `UR_N-KEYS`, `UR_Name`, `UR_NonceHolder`, `UR_NonceID`, `UR_NonceMetaData`, `UR_NonceSupply`, `UR_NonceValue`, `UR_NoncesExcluded`, `UR_NoncesMetaDatas`, `UR_NoncesSupplies`, `UR_NoncesUsed`, `UR_P-KEYS`, `UR_R-AddQuantity`, `UR_R-Burn`, `UR_R-Create`, `UR_R-Frozen`, `UR_R-Transfer`, `UR_RewardBearingToken`, `UR_Segmentation`, `UR_Sleeping`, `UR_Supply`, `UR_Ticker`, `UR_V-KEYS`, `UR_Verum1`, `UR_Verum2`, `UR_Verum3`, `UR_Verum4`, `UR_Verum5`, `UR_Vesting`

*Validators* (28) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AccountAddQuantityState`, `UEV_AccountBurnState`, `UEV_AccountCreateState`, `UEV_AccountFreezeState`, `UEV_AccountTransferState`, `UEV_Amount`, `UEV_CanAddSpecialRoleON`, `UEV_CanChangeOwnerON`, `UEV_CanFreezeON`, `UEV_CanPauseON`, `UEV_CanTransferOftCreateRoleON`, `UEV_CanUpgradeON`, `UEV_CanWipeON`, `UEV_EnforceSegmentationForTransmit`, `UEV_ExecutorIsKonto`, `UEV_ExecutorIsParentKonto`, `UEV_Hibernation`, `UEV_MoveRoleCheck`, `UEV_NoncesCirculating`, `UEV_NoncesToAccount`, `UEV_ParentOwnership`, `UEV_PauseState`, `UEV_SegmentationState`, `UEV_Sleeping`, `UEV_UpdateRewardBearingToken`, `UEV_Vesting`, `UEV_id`

*Constructors* (5) — build objects

`UDC_AccountRoles`, `UDC_NonceElement`, `UDC_RemovableNonces`, `UDC_VerumRoles`, `UDC_WipeSlicePlan`

*Pure compute (guarded)* (1) — compute with a guard intrinsic to the computation

`UCv_TakePureWipe`

*Pure compute* (8) — arguments only; no reads, no enforce

`UC_BuildWipeSlicePlan`, `UC_CeilDiv`, `UC_ComputeMinWipeSliceCount`, `UC_FlattenNoncesArray`, `UC_IdAccount`, `UC_IdNonce`, `UC_IzConsecutive`, `UC_IzSingular`

*Ownership checks* (1) — account-ownership enforcement

`CAP_Owner`

*Recipes* (1) — multi-transaction, no heavy read

`Cp_WipeSlice`

*Client entry (heavy)* (1) — reaches a heavy read somewhere in its tree

`CC_WipeHeavy`

*Client entry* (20) — builds the bill; reachable only through Talos

`C_AddQuantity`, `C_BulkTransfer`, `C_Burn`, `C_Control`, `C_Issue`, `C_Mint`, `C_MoveCreateRole`, `C_RotateOwnership`, `C_ToggleAddQuantityRole`, `C_ToggleBurnRole`, `C_ToggleFreezeAccount`, `C_TogglePause`, `C_ToggleTransferRole`, `C_Transfer`, `C_Transmit`, `C_UpdatePendingBranding`, `C_UpgradeBranding`, `C_WipeClean`, `C_WipePure`, `C_WipeSlim`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (2) — callable by other modules only

`XE_UpdateRewardBearingToken`, `XE_UpdateSpecialOrtoFungible`

*Internal + external* (4) — callable both ways

`XB_DeployAccountWNE`, `XB_InsertNewNonce`, `XB_IssueFree`, `XB_W|AccountRoles`

*Internal writes* (28) — this module only; writes under a capability

`XI_ChangeOwnership`, `XI_Control`, `XI_CreditNonces`, `XI_DebitNonces`, `XI_IncrementNoncesExcludedBy`, `XI_InsertNewId`, `XI_InsertNewNonces`, `XI_SwitchCreateRole`, `XI_ToggleAddQuantityRole`, `XI_ToggleBurnRole`, `XI_ToggleFreezeAccount`, `XI_TogglePause`, `XI_ToggleTransferRole`, `XI_TransferWholeNonces`, `XI_UpdateAccountSupply`, `XI_UpdateHibernation`, `XI_UpdateNonceHolder`, `XI_UpdateNonceSupply`, `XI_UpdateNoncesUsed`, `XI_UpdateSleeping`, `XI_UpdateSupply`, `XI_UpdateVerum1`, `XI_UpdateVerum2`, `XI_UpdateVerum3`, `XI_UpdateVerum4`, `XI_UpdateVerum5`, `XI_UpdateVesting`, `XI_WriteRoles`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|CollectiblesKey`, `GOV|Demiurgoi`

*Unclassified* (11) — no known prefix -- worth asking why

`AU_OrtoFungible`, `AU_OrtoFungibleAccount`, `AU_OrtoFungibleAccounts`, `AU_OrtoFungibles`, `CT_Bar`, `CT_Namespace`, `UDCx_TransmitData`, `URCix_NoncesCumulator`, `URCv_Parent`, `XBv_DeployAccount`, `XIv_Issue`
<!-- @end:module-page:DPOF -->

## Traps

**There is no per-account balance table.** The authoritative record is the parcel row itself. Moving part of a holding does not adjust two numbers — it **mints a new parcel**, and only if the token has segmentation enabled.

**Wiped parcels are decommissioned, not deleted** — set to a negative supply so any later debit fails validation. Deleting rows would make identifiers reusable; a negative sentinel makes a dead parcel provably dead.

**Five wipe operations exist because three axes cross**: granularity, who pays for the scan, and whether it fits one transaction. The slice ceiling is measured and deliberately conservative — 405.6 gas per parcel means about 4,907 would fit, and it is set to 1,000 because the measurement used parcels with no metadata.

**The create role is singular.** One account holds it, so it is moved rather than toggled — and only if the issuer enabled that.

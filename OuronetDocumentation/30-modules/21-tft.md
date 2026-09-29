# TFT — the transfer layer

## What it is for

Movement for true fungibles — single transfers, multi-transfers, and the bulk forms that move many tokens or many recipients in one operation.

It sits *over* the token core rather than inside it, so the rules about who may move what are in one place rather than repeated per operation.

## Where it sits

A Stage-1 core above the true-fungible token core and below everything that moves value — pools, vesting, the launchpad.

## What it owns, and what it exposes

<!-- @generated:module-page:TFT -->
**On chain**

| | |
|---|---|
| module hash | `tZGJC60jG03FvaiJmGWD9kSM_U4Ozey6jAMPZlCoKtA` |
| deployed size | 89,480 characters |
| implements | `OuronetPolicyV2`, `TrueFungibleTransferV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/09_TFT.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 26

`DPTF|C>CLASS-0-BULK`, `DPTF|C>CLASS-0-BULK-UNITY`, `DPTF|C>CLASS-1-BULK`, `DPTF|C>CLASS-1-TRANSFER`, `DPTF|C>CLASS-1-TRANSFER-UNITY`, `DPTF|C>CLASS-2-BULK`, `DPTF|C>CLASS-2-BULK-ELITE`, `DPTF|C>CLASS-2-TRANSFER`, `DPTF|C>CLASS-2-TRANSFER-ELITE`, `DPTF|C>CLASS-2-TRANSFER-UNITY`, `DPTF|C>CLASS-3-BULK-ELITE`, `DPTF|C>CLASS-3-TRANSFER-ELITE`, `DPTF|C>CLEAR-DISPO`, `DPTF|C>ELITE-TRANSMUTE`, `DPTF|C>MULTI-TRANSFER`, `DPTF|C>TRANSMUTE`, `DPTF|C>X-BULK-TRANSFER`, `DPTF|C>X-TRANSFER`, `DPTF|C>X-TRANSMUTE`, `GOV`, `GOV|TFT_ADMIN`, `P|ATS|REMOTE-GOV`, `P|DALOS|REMOTE-GOV`, `P|SECURE-CALLER`, `P|TFT|CALLER`, `SECURE`

**Functions** — 73, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 17 | returns what an operation will charge | `URCi_BulkTransferCumulator`, `URCi_ClearDispo`, `URCi_ComplexBulkTransferCumulator`, `URCi_EliteBulkTransferCumulator`, `URCi_LargeTransferCumulator`, `URCi_LargeTransmuteCumulator` …+11 |
| `URC_` derived reads | 11 | read and derive; no enforce | `URC_AreTrueFungiblesEliteAurynz`, `URC_IzSimpleTransfer`, `URC_IzSimpleTransferForBulk`, `URC_IzTrueFungibleEliteAuryn`, `URC_IzTrueFungibleUnity`, `URC_MinimumOuro` …+5 |
| `UEV_` validators | 5 | read and enforce; may abort the transaction | `UEV_DispoLocker`, `UEV_IgnisTransmuteMinimum`, `UEV_Minimum`, `UEV_MinimumMapperForBulk`, `UEV_MoveRoleCheck` |
| `UDC_` constructors | 1 | named object constructors | `UDC_GetDispoData` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_BulkFees`, `UC_BulkRemainders`, `UC_ContainsEliteAurynz` |
| `XI_` protected (internal) | 13 | this module only | `XI_BulkCredit`, `XI_BulkCreditAmounts`, `XI_BulkUpdateElite`, `XI_CPF_BurnFee`, `XI_CPF_CreditFee`, `XI_CPF_StillFee` …+7 |
| `C_` client | 5 | reached via Talos, never called directly | `C_ClearDispo`, `C_MultiBulkTransfer`, `C_MultiTransfer`, `C_Transfer`, `C_Transmute` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 9 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `UDCx_BulkTransferCumulator`, `URCx_BooleanDecimalCombiner`, `URCx_CPF_RBT` …+3 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `TransferClass`

**Capabilities** -- 26

`DPTF|C>CLASS-0-BULK`, `DPTF|C>CLASS-0-BULK-UNITY`, `DPTF|C>CLASS-1-BULK`, `DPTF|C>CLASS-1-TRANSFER`, `DPTF|C>CLASS-1-TRANSFER-UNITY`, `DPTF|C>CLASS-2-BULK`, `DPTF|C>CLASS-2-BULK-ELITE`, `DPTF|C>CLASS-2-TRANSFER`, `DPTF|C>CLASS-2-TRANSFER-ELITE`, `DPTF|C>CLASS-2-TRANSFER-UNITY`, `DPTF|C>CLASS-3-BULK-ELITE`, `DPTF|C>CLASS-3-TRANSFER-ELITE`, `DPTF|C>CLEAR-DISPO`, `DPTF|C>ELITE-TRANSMUTE`, `DPTF|C>MULTI-TRANSFER`, `DPTF|C>TRANSMUTE`, `DPTF|C>X-BULK-TRANSFER`, `DPTF|C>X-TRANSFER`, `DPTF|C>X-TRANSMUTE`, `GOV`, `GOV|TFT_ADMIN`, `P|ATS|REMOTE-GOV`, `P|DALOS|REMOTE-GOV`, `P|SECURE-CALLER`, `P|TFT|CALLER`, `SECURE`

**Functions** -- 73, grouped by what the prefix promises

*Cost readers* (17) — price an operation; the exec path and the preview both call these

`URCi_BulkTransferCumulator`, `URCi_ClearDispo`, `URCi_ComplexBulkTransferCumulator`, `URCi_EliteBulkTransferCumulator`, `URCi_LargeTransferCumulator`, `URCi_LargeTransmuteCumulator`, `URCi_MediumTransferCumulator`, `URCi_MultiBulkTransferCumulator`, `URCi_MultiTransferCumulator`, `URCi_SimpleBulkTransferCumulator`, `URCi_SmallTransferCumulator`, `URCi_SmallTransmuteCumulator`, `URCi_Transfer`, `URCi_TransferCumulator`, `URCi_Transmute`, `URCi_UnityBulkTransferCumulator`, `URCi_UnityTransferCumulator`

*Derived reads* (11) — read and compute; no enforce

`URC_AreTrueFungiblesEliteAurynz`, `URC_IzSimpleTransfer`, `URC_IzSimpleTransferForBulk`, `URC_IzTrueFungibleEliteAuryn`, `URC_IzTrueFungibleUnity`, `URC_MinimumOuro`, `URC_ReceiverAmount`, `URC_TransferClasses`, `URC_TransferClassesForBulk`, `URC_UnityTransferIgnisPrice`, `URC_VirtualOuro`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (6) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_DispoLocker`, `UEV_IgnisTransmuteMinimum`, `UEV_Minimum`, `UEV_MinimumMapperForBulk`, `UEV_MoveRoleCheck`

*Constructors* (1) — build objects

`UDC_GetDispoData`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_BulkFees`, `UC_BulkRemainders`, `UC_ContainsEliteAurynz`

*Client entry* (5) — builds the bill; reachable only through Talos

`C_ClearDispo`, `C_MultiBulkTransfer`, `C_MultiTransfer`, `C_Transfer`, `C_Transmute`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (13) — this module only; writes under a capability

`XI_BulkCredit`, `XI_BulkCreditAmounts`, `XI_BulkUpdateElite`, `XI_CPF_BurnFee`, `XI_CPF_CreditFee`, `XI_CPF_StillFee`, `XI_ComplexCredit`, `XI_ComplexTransfer`, `XI_CreditPrimaryFee`, `XI_DirectUpdateEliteAccount`, `XI_DynamicUpdateEliteAccount`, `XI_SimpleTransfer`, `XI_Transmute`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (8) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`, `UDCx_BulkTransferCumulator`, `URCx_BooleanDecimalCombiner`, `URCx_CPF_RBT`, `URCx_CPF_RT`, `URCx_CPF_RT-RBT`, `URCx_NFR-Boolean_RT-RBT`
<!-- @end:module-page:TFT -->

## Traps

**Transfer restriction is enforced by a role list, and an empty list is not the same as an unset one.** When a token's transfer-role list is non-empty, either the sender or the receiver must hold the role. A bug once emptied that list to `[]` instead of the `["|"]` sentinel, so the "is this restricted" check answered *true* for a token restricted nowhere — and every transfer routed into arithmetic that faulted. The token became permanently untransferable and unrepairable.

**A minimum-move threshold and a transmute minimum are different numbers** guarding different things, and one of them is load-bearing for the gas station's sponsored-code door. Changing either without the other breaks a tripod documented across three modules.

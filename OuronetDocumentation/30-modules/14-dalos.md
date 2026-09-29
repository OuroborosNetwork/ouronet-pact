# DALOS — the account and identity core

## What it is for

The root of the system: **every Ouronet account lives here**, along with the protocol's global settings, its gas tanks, and the gas station that pays the host chain on a user's behalf.

Two account types share one row shape — standard (a person) and smart (a contract-like actor owned by a standard account). Each row carries two separate authorities: a **guard** (which keys control it) and a **governor** (which code operates it), forced into disjoint principal protocols so the two can never be confused.

It also holds the mapping between Ouronet accounts and host-chain accounts, in both directions.

## Where it sits

The **first core module**, deployed immediately after the utilities. Everything depends on it; it depends only on them.

That position has a consequence worth knowing: DALOS deploys *before* the gas module, so it cannot construct a bill. Its own cost readers therefore live in IGNIS — an exception recorded where it applies rather than generalised.

## What it owns, and what it exposes

<!-- @generated:module-page:DALOS -->
**On chain**

| | |
|---|---|
| module hash | `ks6sIIhHoPr3y_aSoBXERCEm1deE3NMr3D8HPsPW814` |
| deployed size | 85,632 characters |
| implements | `gas-payer-v1`, `OuronetPolicyV2`, `OuronetDalosV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact` |

**Tables it owns** — 7

`DALOS|AccountTable`, `DALOS|GasManagementTable`, `DALOS|KadenaLedger`, `DALOS|PricesTable`, `DALOS|PropertiesTable`, `P|MT`, `P|T`

**Schemas** — 6

`DALOS|AccountSchemaV2`, `DALOS|EliteSchema`, `DALOS|GasManagementSchema`, `DALOS|PricesSchema`, `DALOS|PropertiesSchema`, `DALOS|StoaSchema`

**Capabilities** — 22

`AHU`, `DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT`, `DALOS|C>CONTROL-SMART-OURONET-ACCOUNT`, `DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT`, `DALOS|C>DEPLOY-STANDARD-OURONET-ACCOUNT`, `DALOS|C>ROTATE-OA-GUARD`, `DALOS|C>ROTATE-OA-STOA`, `DALOS|C>ROTATE-OA_GOVERNOR`, `DALOS|C>TOGGLE-ACCOUNT-CREATION-STOA`, `DALOS|C>TOGGLE-GAS-COLLECTION`, `DALOS|F>GOV`, `DALOS|F>OWNER`, `DALOS|NATIVE-AUTOMATIC`, `DALOS|S>ROTATE-OA-SOVEREIGN`, `DALOS|S>SET-OURO-PRICE`, `GAS_PAYER:bool`, `GOV`, `GOV|DALOS_ADMIN`, `GOV|GAP`, `GOV|MIGRATE`, `SECURE`, `SECURE-ADMIN`

**Functions** — 159, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URH_` heavy reads | 1 | a scan -- expensive by construction | `URH_AccountCounter` |
| `URC_` derived reads | 6 | read and derive; no enforce | `URC_GasDiscount`, `URC_IgnisGasDiscount`, `URC_SplitSTOAPrices`, `URC_SplitSTOAPricesFull`, `URC_StoaGasDiscount`, `URC_Transferability` |
| `UEV_` validators | 13 | read and enforce; may abort the transaction | `UEV_EnforceAccountExists`, `UEV_EnforceAccountType`, `UEV_EnforceGuardProtocol`, `UEV_EnforceTransferability`, `UEV_Glyph`, `UEV_IgnisCollectionRequirements` …+7 |
| `UDC_` constructors | 2 | named object constructors | `UDC_BlankTrueFungible`, `UDC_TrueFungibleAccount` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_GuardProtocol` |
| `UR_` readers | 52 | table reads; no enforce, no writes | `UR_AccountCreationStoa`, `UR_AccountGovernor`, `UR_AccountGuard`, `UR_AccountNonce`, `UR_AccountPayableAs`, `UR_AccountPayableBy` …+46 |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_EnforceAccountOwnership` |
| `XI_` protected (internal) | 11 | this module only | `XI_DeploySmartAccount`, `XI_DeployStandardAccount`, `XI_GasToggle`, `XI_RotateGovernor`, `XI_RotateGuard`, `XI_RotateSovereign` …+5 |
| `XE_` protected (external) | 9 | for other modules; opens with the IMC gate | `XE_IgnisIncrement`, `XE_IncrementOuronetAccountNonce`, `XE_UpdateBurnRole`, `XE_UpdateElite`, `XE_UpdateFeeExemptionRole`, `XE_UpdateFreeze` …+3 |
| `XB_` protected (both) | 2 | internal and external | `XB_UpdateBalance`, `XB_UpdateOuroPrice` |
| `A_` admin | 11 | admin-key mutations | `A_DeploySmartAccount`, `A_DeployStandardAccount`, `A_MigrateLiquidFunds`, `A_SetAutoFueling`, `A_SetIgnisSourcePrice`, `A_ToggleAccountCreationStoa` …+5 |
| `C_` client | 7 | reached via Talos, never called directly | `C_ControlSmartAccount`, `C_DeploySmartAccount`, `C_DeployStandardAccount`, `C_RotateGovernor`, `C_RotateGuard`, `C_RotateSovereign` …+1 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 34 | carries no StoicSyntax prefix | `AU_OuronetAccount`, `AU_OuronetAccounts`, `AUx_UpdateTrueFungibleObject`, `CT_Bar`, `CT_Info`, `CT_Namespace` …+28 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `CanonicalStoaIds`, `DPTF|BalanceSchema`, `P|MS`, `P|S`

**Capabilities** -- 22

`AHU`, `DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT`, `DALOS|C>CONTROL-SMART-OURONET-ACCOUNT`, `DALOS|C>DEPLOY-SMART-OURONET-ACCOUNT`, `DALOS|C>DEPLOY-STANDARD-OURONET-ACCOUNT`, `DALOS|C>ROTATE-OA-GUARD`, `DALOS|C>ROTATE-OA-STOA`, `DALOS|C>ROTATE-OA_GOVERNOR`, `DALOS|C>TOGGLE-ACCOUNT-CREATION-STOA`, `DALOS|C>TOGGLE-GAS-COLLECTION`, `DALOS|F>GOV`, `DALOS|F>OWNER`, `DALOS|NATIVE-AUTOMATIC`, `DALOS|S>ROTATE-OA-SOVEREIGN`, `DALOS|S>SET-OURO-PRICE`, `GAS_PAYER:bool`, `GOV`, `GOV|DALOS_ADMIN`, `GOV|GAP`, `GOV|MIGRATE`, `SECURE`, `SECURE-ADMIN`

**Functions** -- 159, grouped by what the prefix promises

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_AccountCounter`

*Derived reads* (6) — read and compute; no enforce

`URC_GasDiscount`, `URC_IgnisGasDiscount`, `URC_SplitSTOAPrices`, `URC_SplitSTOAPricesFull`, `URC_StoaGasDiscount`, `URC_Transferability`

*Point reads* (53) — one row or field by key

`P|UR_IMP`, `UR_AccountCreationStoa`, `UR_AccountGovernor`, `UR_AccountGuard`, `UR_AccountNonce`, `UR_AccountPayableAs`, `UR_AccountPayableBy`, `UR_AccountPayableByMethod`, `UR_AccountProperties`, `UR_AccountPublicKey`, `UR_AccountSovereign`, `UR_AccountStoa`, `UR_AccountType`, `UR_AurynID`, `UR_AutoFuel`, `UR_AutonomicRoles`, `UR_CanonicalStoaIds`, `UR_DemiurgoiID`, `UR_DispoTDP`, `UR_DispoTDS`, `UR_DispoType`, `UR_Elite`, `UR_Elite-Class`, `UR_Elite-DEB`, `UR_Elite-Name`, `UR_Elite-Tier`, `UR_Elite-Tier-Major`, `UR_Elite-Tier-Minor`, `UR_EliteAurynID`, `UR_GAP`, `UR_GoldenStoaID`, `UR_IgnisID`, `UR_NativeSpent`, `UR_NativeToggle`, `UR_OuroAutoPriceUpdate`, `UR_OuroborosID`, `UR_OuroborosPrice`, `UR_SilverStoaID`, `UR_StoaLedger`, `UR_TF_AccountFreezeState`, `UR_TF_AccountRoleBurn`, `UR_TF_AccountRoleFeeExemption`, `UR_TF_AccountRoleMint`, `UR_TF_AccountRoleTransfer`, `UR_TF_AccountSupply`, `UR_Tanker`, `UR_TrueFungible`, `UR_UnityID`, `UR_UrStoaID`, `UR_UsagePrice`, `UR_VirtualSpent`, `UR_VirtualToggle`, `UR_WrappedStoaID`

*Validators* (14) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_EnforceAccountExists`, `UEV_EnforceAccountType`, `UEV_EnforceGuardProtocol`, `UEV_EnforceTransferability`, `UEV_Glyph`, `UEV_IgnisCollectionRequirements`, `UEV_IgnisCollectionState`, `UEV_NotSmartOuronetAccount`, `UEV_SenderWithReceiver`, `UEV_SmartAccOwn`, `UEV_StandardAccOwn`, `UEV_StoaCollectionState`, `UEV_enforce-notional-at-floor`

*Constructors* (2) — build objects

`UDC_BlankTrueFungible`, `UDC_TrueFungibleAccount`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_GuardProtocol`

*Ownership checks* (1) — account-ownership enforcement

`CAP_EnforceAccountOwnership`

*Client entry* (7) — builds the bill; reachable only through Talos

`C_ControlSmartAccount`, `C_DeploySmartAccount`, `C_DeployStandardAccount`, `C_RotateGovernor`, `C_RotateGuard`, `C_RotateSovereign`, `C_RotateStoa`

*Admin* (16) — admin-key mutations

`A_DeploySmartAccount`, `A_DeployStandardAccount`, `A_MigrateLiquidFunds`, `A_SetAutoFueling`, `A_SetIgnisSourcePrice`, `A_ToggleAccountCreationStoa`, `A_ToggleGAP`, `A_ToggleGasCollection`, `A_ToggleOAPU`, `A_UpdatePublicKey`, `A_UpdateUsagePrice`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (9) — callable by other modules only

`XE_IgnisIncrement`, `XE_IncrementOuronetAccountNonce`, `XE_UpdateBurnRole`, `XE_UpdateElite`, `XE_UpdateFeeExemptionRole`, `XE_UpdateFreeze`, `XE_UpdateMintRole`, `XE_UpdateTransferRole`, `XE_UpdateTreasury`

*Internal + external* (2) — callable both ways

`XB_UpdateBalance`, `XB_UpdateOuroPrice`

*Internal writes* (11) — this module only; writes under a capability

`XI_DeploySmartAccount`, `XI_DeployStandardAccount`, `XI_GasToggle`, `XI_RotateGovernor`, `XI_RotateGuard`, `XI_RotateSovereign`, `XI_RotateStoa`, `XI_ToggleAccountCreationStoa`, `XI_UpdateSmartAccountParameters`, `XI_UpdateStoaLedger`, `XI_UpdateTF`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (26) — keysets and protocol constants

`GOV|AQP|SC_NAME`, `GOV|ATS|PBL`, `GOV|ATS|SC_NAME`, `GOV|AutostakeKey`, `GOV|DALOS|GUARD`, `GOV|DALOS|PBL`, `GOV|DALOS|SC_NAME`, `GOV|DALOS|SC_STOA-NAME`, `GOV|DHV1|SC_NAME`, `GOV|DHV2|SC_NAME`, `GOV|DHVKey`, `GOV|DHV|PBL`, `GOV|DalosKey`, `GOV|Demiurgoi`, `GOV|LIQUID|PBL`, `GOV|LIQUID|SC_NAME`, `GOV|LiquidKey`, `GOV|OUROBOROS|PBL`, `GOV|OUROBOROS|SC_NAME`, `GOV|OuroborosKey`, `GOV|SWP|PBL`, `GOV|SWP|SC_NAME`, `GOV|SwapKey`, `GOV|VST|PBL`, `GOV|VST|SC_NAME`, `GOV|VestingKey`

*Unclassified* (8) — no known prefix -- worth asking why

`AU_OuronetAccount`, `AU_OuronetAccounts`, `AUx_UpdateTrueFungibleObject`, `CT_Bar`, `CT_Info`, `CT_Namespace`, `CT_VirtualGasData`, `create-gas-payer-guard`
<!-- @end:module-page:DALOS -->

## Traps

**Account existence is an economic question, not a structural one.** There is no row-exists test; the check reads an elite-debt field and requires it to be at least 1. A missing row defaults to zero. Existence and standing are the same question, asked once.

**An unset ledger row defaults to `["|"]`, not `[]`.** Code assuming an empty list sees one phantom entry.

**Rotating the host-chain link must read the old value first.** Read it after the row is overwritten and the cleanup deletes from the wrong key, orphaning a ledger row permanently. The fix is documented at the site.

**A column rename once broke every account.** A Pact upgrade replaces code and leaves rows untouched, so renaming `kadena-konto` to `stoa-konto` made the reader throw for *every* account — 33 call sites across 9 modules. The column was reverted; the table rename was missed in the same pass because a renamed table does not throw, it merely reports as uncreated. Function names may be renamed freely; **column names may not**.

**And the gas station's exemption used to be far wider.** The check asked whether the payer was *any* smart account — and anyone may create one permissionlessly. It now compares against one named constant. The source's own phrasing: *a convention that is honoured is indistinguishable from a rule that is enforced, until someone does not honour it.*

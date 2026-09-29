# DPDC-S

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:DPDC-S -->
**On chain**

| | |
|---|---|
| module hash | `itgzaFgxE5Egd4GWHObP4_8u0eyqek10ubfnid4V6Tg` |
| deployed size | 78,077 characters |
| implements | `OuronetPolicyV2`, `DpdcSetsV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/08_DPDC-S.pact` |

**Tables it owns** — 4

`DPNF|SetsTable`, `DPSF|SetsTable`, `P|MT`, `P|T`

**Capabilities** — 15

`DPDC-S|C>BREAK`, `DPDC-S|C>DEFINE-COMPOSITE`, `DPDC-S|C>DEFINE-HYBRID`, `DPDC-S|C>DEFINE-PRIMORDIAL`, `DPDC-S|C>ENABLE-FRAGMENTATION`, `DPDC-S|C>MAKE`, `DPDC-S|C>RENAME`, `DPDC-S|C>TOGGLE`, `DPDC-S|CX>DEFINE`, `GOV`, `GOV|DPDC-S_ADMIN`, `P|DPDC-S|CALLER`, `P|DPDC-S|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 74, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 10 | returns what an operation will charge | `URCi_BreakNonFungibleSet`, `URCi_BreakSemiFungibleSet`, `URCi_DefineCompositeSet`, `URCi_DefineHybridSet`, `URCi_DefinePrimordialSet`, `URCi_EnableSetClassFragmentation` …+4 |
| `URCv_` derived reads (validating) | 1 | read + derive, with an intrinsic guard | `URCv_NonFungibleConstituents` |
| `URH_` heavy reads | 1 | a scan -- expensive by construction | `URH_NonceListFromCSD` |
| `URC_` derived reads | 4 | read and derive; no enforce | `URC_NoncesSummedScore`, `URC_PrimordialOrComposite`, `URC_SemiFungibleConstituents`, `URC_SetExists` |
| `UEV_` validators | 12 | read and enforce; may abort the transaction | `UEV_Composite`, `UEV_CompositeSetDefinition`, `UEV_ExecutorIsCollectionOwner`, `UEV_Fragmentation`, `UEV_IzSetClassFragmented`, `UEV_NoncesForSetClass` …+6 |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_FirstNoncesFromPSD` |
| `UR_` readers | 12 | table reads; no enforce, no writes | `UR_CSD`, `UR_IzSetActive`, `UR_IzSetComposite`, `UR_IzSetPrimordial`, `UR_NonceOfSet`, `UR_PSD` …+6 |
| `XI_` protected (internal) | 6 | this module only | `XI_CompositeSet`, `XI_FragmentSetClass`, `XI_HybridSet`, `XI_PrimordialSet`, `XI_RenameSet`, `XI_ToggleSetClass` |
| `CC_` client (heavy) | 1 | client entrypoint; reaches a scan | `CC_BreakSemiFungibleSet` |
| `C_` client | 9 | reached via Talos, never called directly | `C_BreakNonFungibleSet`, `C_DefineCompositeSet`, `C_DefineHybridSet`, `C_DefinePrimordialSet`, `C_EnableSetClassFragmentation`, `C_MakeNonFungibleSet` …+3 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 8 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `URC_N|Score`, `XB_U|NonceOrSplitData`, `XI_I|CollectionSet` …+2 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 15

`DPDC-S|C>BREAK`, `DPDC-S|C>DEFINE-COMPOSITE`, `DPDC-S|C>DEFINE-HYBRID`, `DPDC-S|C>DEFINE-PRIMORDIAL`, `DPDC-S|C>ENABLE-FRAGMENTATION`, `DPDC-S|C>MAKE`, `DPDC-S|C>RENAME`, `DPDC-S|C>TOGGLE`, `DPDC-S|CX>DEFINE`, `GOV`, `GOV|DPDC-S_ADMIN`, `P|DPDC-S|CALLER`, `P|DPDC-S|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 74, grouped by what the prefix promises

*Cost readers* (10) — price an operation; the exec path and the preview both call these

`URCi_BreakNonFungibleSet`, `URCi_BreakSemiFungibleSet`, `URCi_DefineCompositeSet`, `URCi_DefineHybridSet`, `URCi_DefinePrimordialSet`, `URCi_EnableSetClassFragmentation`, `URCi_MakeNonFungibleSet`, `URCi_MakeSemiFungibleSet`, `URCi_RenameSet`, `URCi_ToggleSet`

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_NonceListFromCSD`

*Derived reads* (5) — read and compute; no enforce

`URC_NoncesSummedScore`, `URC_N|Score`, `URC_PrimordialOrComposite`, `URC_SemiFungibleConstituents`, `URC_SetExists`

*Point reads* (13) — one row or field by key

`P|UR_IMP`, `UR_CSD`, `UR_IzSetActive`, `UR_IzSetComposite`, `UR_IzSetPrimordial`, `UR_NonceOfSet`, `UR_PSD`, `UR_Set`, `UR_SetClass`, `UR_SetMultiplier`, `UR_SetName`, `UR_SetNonceData`, `UR_SetSplitData`

*Validators* (13) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_Composite`, `UEV_CompositeSetDefinition`, `UEV_ExecutorIsCollectionOwner`, `UEV_Fragmentation`, `UEV_IzSetClassFragmented`, `UEV_NoncesForSetClass`, `UEV_Primordial`, `UEV_PrimordialSetDefinition`, `UEV_PrimordialSetElement`, `UEV_ScoreMultiplier`, `UEV_SetActiveState`, `UEV_SetClass`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_FirstNoncesFromPSD`

*Client entry (heavy)* (1) — reaches a heavy read somewhere in its tree

`CC_BreakSemiFungibleSet`

*Client entry* (9) — builds the bill; reachable only through Talos

`C_BreakNonFungibleSet`, `C_DefineCompositeSet`, `C_DefineHybridSet`, `C_DefinePrimordialSet`, `C_EnableSetClassFragmentation`, `C_MakeNonFungibleSet`, `C_MakeSemiFungibleSet`, `C_RenameSet`, `C_ToggleSet`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal + external* (1) — callable both ways

`XB_U|NonceOrSplitData`

*Internal writes* (9) — this module only; writes under a capability

`XI_CompositeSet`, `XI_FragmentSetClass`, `XI_HybridSet`, `XI_I|CollectionSet`, `XI_PrimordialSet`, `XI_RenameSet`, `XI_ToggleSetClass`, `XI_U|IzActive`, `XI_U|SetName`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (3) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`, `URCv_NonFungibleConstituents`
<!-- @end:module-page:DPDC-S -->

## Traps

_To be written._

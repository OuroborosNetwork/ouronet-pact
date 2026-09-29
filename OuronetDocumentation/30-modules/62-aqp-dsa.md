# AQP-DSA

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-DSA -->
**On chain**

| | |
|---|---|
| module hash | `CXL_PKoU2eykZHVnCkFnMuOO04a-a6MsXh_9CGYwu8s` |
| deployed size | 53,651 characters |
| implements | `OuronetPolicyV2`, `DsaV1` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08_DSA.pact` |

**Tables it owns** — 5

`DSA|T|Agency`, `DSA|T|OracleAuth`, `DSA|T|Template`, `P|MT`, `P|T`

**Capabilities** — 16

`DSA|A>ORACLE-WRITE`, `DSA|C>BURN-ROYALTY`, `DSA|C>DEFINE-VAULT`, `DSA|C>FUEL-ROYALTY`, `DSA|C>OPEN-AGENCY`, `DSA|C>RECOMPUTE-CAPTURE`, `DSA|C>SET-AGENCY-FEE`, `DSA|C>SET-ORACLE-AUTH`, `DSA|C>WITHDRAW-ROYALTY`, `GOV`, `GOV|DSA_ADMIN`, `P|DSA|CALLER`, `P|DSA|REMOTE-GOV`, `P|DT`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 61, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 12 | returns what an operation will charge | `URCi_BurnRoyalty`, `URCi_BurnRoyaltyFull`, `URCi_DefineDelegationVault`, `URCi_FuelRoyalty`, `URCi_FuelRoyaltyFull`, `URCi_OpenAgency` …+6 |
| `URC_` derived reads | 4 | read and derive; no enforce | `URC_AgencyQuintessence`, `URC_CaptureUnits`, `URC_DsaTemplateActive`, `URC_DsaTemplateExists` |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_OpenGate` |
| `UCk_` pure compute (key) | 1 | builds a composite table key | `UCk_Agency` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_CaptureWeight` |
| `WI_` writers (insert) | 3 | one write site each | `WI_Agency`, `WI_OracleAuth`, `WI_Template` |
| `WU_` writers (update) | 2 | one write site each | `WU_Agency-Fee`, `WU_Agency-Oracle` |
| `XI_` protected (internal) | 1 | this module only | `XI_ApplyCapture` |
| `A_` admin | 2 | admin-key mutations | `A_SetOracleValidity`, `A_ToggleExternalOracle` |
| `C_` client | 9 | reached via Talos, never called directly | `C_AdmitAgency`, `C_BurnRoyalty`, `C_DefineDelegationVault`, `C_FuelRoyalty`, `C_OracleWrite`, `C_RecomputeCapture` …+3 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 16 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `UDC_DSA|Agency`, `UDC_DSA|OracleAuth`, `UDC_DSA|Template` …+10 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 16

`DSA|A>ORACLE-WRITE`, `DSA|C>BURN-ROYALTY`, `DSA|C>DEFINE-VAULT`, `DSA|C>FUEL-ROYALTY`, `DSA|C>OPEN-AGENCY`, `DSA|C>RECOMPUTE-CAPTURE`, `DSA|C>SET-AGENCY-FEE`, `DSA|C>SET-ORACLE-AUTH`, `DSA|C>WITHDRAW-ROYALTY`, `GOV`, `GOV|DSA_ADMIN`, `P|DSA|CALLER`, `P|DSA|REMOTE-GOV`, `P|DT`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 61, grouped by what the prefix promises

*Cost readers* (12) — price an operation; the exec path and the preview both call these

`URCi_BurnRoyalty`, `URCi_BurnRoyaltyFull`, `URCi_DefineDelegationVault`, `URCi_FuelRoyalty`, `URCi_FuelRoyaltyFull`, `URCi_OpenAgency`, `URCi_OracleWrite`, `URCi_RecomputeCapture`, `URCi_SetAgencyFee`, `URCi_SetOracleAuth`, `URCi_WithdrawRoyalty`, `URCi_WithdrawRoyaltyFull`

*Derived reads* (4) — read and compute; no enforce

`URC_AgencyQuintessence`, `URC_CaptureUnits`, `URC_DsaTemplateActive`, `URC_DsaTemplateExists`

*Point reads* (11) — one row or field by key

`P|UR_IMP`, `UR_DSA-AGN|Agency`, `UR_DSA-AGN|FeePerMille`, `UR_DSA-AGN|Nodes`, `UR_DSA-AGN|Operator`, `UR_DSA-AGN|Uptime`, `UR_DSA-ORA|Guard`, `UR_DSA-TMP|Active`, `UR_DSA-TMP|ModelId`, `UR_DSA-TMP|Template`, `UR_DSA-TMP|UnitScore`

*Validators* (2) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_OpenGate`

*Constructors* (3) — build objects

`UDC_DSA|Agency`, `UDC_DSA|OracleAuth`, `UDC_DSA|Template`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_CaptureWeight`

*Client entry* (9) — builds the bill; reachable only through Talos

`C_AdmitAgency`, `C_BurnRoyalty`, `C_DefineDelegationVault`, `C_FuelRoyalty`, `C_OracleWrite`, `C_RecomputeCapture`, `C_SetAgencyFee`, `C_SetOracleAuth`, `C_WithdrawRoyalty`

*Admin* (7) — admin-key mutations

`A_SetOracleValidity`, `A_ToggleExternalOracle`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (1) — this module only; writes under a capability

`XI_ApplyCapture`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (8) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`, `UCk_Agency`, `WI_Agency`, `WI_OracleAuth`, `WI_Template`, `WU_Agency-Fee`, `WU_Agency-Oracle`
<!-- @end:module-page:AQP-DSA -->

## Traps

_To be written._

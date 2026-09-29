# CODEX — name registration

## What it is for

Registration of human-readable names, priced **per character** in native currency.

## Where it sits

A Stage-1 core near the top, below its Talos wrapper.

## What it owns, and what it exposes

<!-- @generated:module-page:CODEX -->
**On chain**

| | |
|---|---|
| module hash | `L3H75v1TeU8IG6LUbweAXjw4KwV5AufNkBjgpsf4F5I` |
| deployed size | 47,794 characters |
| implements | `CodexV2`, `OuronetPolicyV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/21_CODEX.pact` |

**Tables it owns** — 6

`CODEX|T|ArweaveTracker`, `CODEX|T|Identities`, `CODEX|T|StoicTags`, `CODEX|T|StoicTagsByAccount`, `P|MT`, `P|T`

**Schemas** — 4

`CODEX|S|ArweaveTracker`, `CODEX|S|Identity`, `CODEX|S|StoicTag`, `CODEX|S|StoicTagByAccount`

**Capabilities** — 12

`CODEX|A>REGISTER-IDENTITY`, `CODEX|ADMIN`, `CODEX|C>RECORD-ARWEAVE`, `CODEX|C>REGISTER-STOICTAG`, `CODEX|C>RELEASE-STOICTAG`, `CODEX|C>ROTATE-GUARD`, `CODEX|OWNER`, `CODEX|STOICTAG-DALOS-OWNER`, `GOV`, `GOV|CODEX_ADMIN`, `P|CODEX|CALLER`, `SECURE`

**Functions** — 82, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 4 | returns what an operation will charge | `URCi_RecordArweaveUpload`, `URCi_RegisterStoicTag`, `URCi_ReleaseStoicTag`, `URCi_RotateCodexGuard` |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_ExecutorIsTagAccount` |
| `UC_` pure compute | 8 | arguments only -- no reads, no enforce | `UC_ArweaveTrackerKey`, `UC_CodexIdSmart`, `UC_CodexIdStandard`, `UC_IsBase64urlChar`, `UC_StoicTagStoaFee`, `UC_ValidateArweaveTxId` …+2 |
| `XI_` protected (internal) | 5 | this module only | `XI_DeactivateStoicTag`, `XI_InsertArweaveTracker`, `XI_InsertIdentity`, `XI_UpdateCodexGuard`, `XI_UpsertStoicTag` |
| `A_` admin | 1 | admin-key mutations | `A_RegisterCodexIdentity` |
| `C_` client | 4 | reached via Talos, never called directly | `C_RecordArweaveUpload`, `C_RegisterStoicTag`, `C_ReleaseStoicTag`, `C_RotateCodexGuard` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 50 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Namespace`, `GOV|CodexKey`, `GOV|Demiurgoi`, `INFO_CODEX|RecordArweaveUpload`, `INFO_CODEX|RegisterStoicTag` …+44 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 12

`CODEX|A>REGISTER-IDENTITY`, `CODEX|ADMIN`, `CODEX|C>RECORD-ARWEAVE`, `CODEX|C>REGISTER-STOICTAG`, `CODEX|C>RELEASE-STOICTAG`, `CODEX|C>ROTATE-GUARD`, `CODEX|OWNER`, `CODEX|STOICTAG-DALOS-OWNER`, `GOV`, `GOV|CODEX_ADMIN`, `P|CODEX|CALLER`, `SECURE`

**Functions** -- 82, grouped by what the prefix promises

*Cost readers* (4) — price an operation; the exec path and the preview both call these

`URCi_RecordArweaveUpload`, `URCi_RegisterStoicTag`, `URCi_ReleaseStoicTag`, `URCi_RotateCodexGuard`

*Derived reads* (1) — read and compute; no enforce

`URC_AWT|LatestUpload`

*Point reads* (28) — one row or field by key

`P|UR_IMP`, `UR_AWT|ArweaveTxId`, `UR_AWT|CodexId`, `UR_AWT|Data`, `UR_AWT|ListByCodex`, `UR_AWT|UploadTime`, `UR_AWT|UploadedBytes`, `UR_CIX|CodexGuard`, `UR_CIX|CodexId`, `UR_CIX|CodexIdSmart`, `UR_CIX|CodexIdStandard`, `UR_CIX|Data`, `UR_CIX|DataOrNull`, `UR_CIX|PublicSmart`, `UR_CIX|PublicStandard`, `UR_CIX|RegisteredAt`, `UR_CIX|RegisteredBy`, `UR_STBA|AccountAddress`, `UR_STBA|Data`, `UR_STBA|DataOrNull`, `UR_STBA|IzActive`, `UR_STBA|TagName`, `UR_STG|AccountAddress`, `UR_STG|Data`, `UR_STG|DataOrNull`, `UR_STG|IzActive`, `UR_STG|RegisteredAt`, `UR_STG|TagName`

*Validators* (2) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_ExecutorIsTagAccount`

*Constructors* (14) — build objects

`UDC_AWT|EmptyLatest`, `UDC_AWT|Tracker`, `UDC_CIX|GuardUpdate`, `UDC_CIX|Identity`, `UDC_CIX|Unregistered`, `UDC_CIX|WithRegisteredFlag`, `UDC_STBA|IzActiveUpdate`, `UDC_STBA|StoicTagByAccount`, `UDC_STBA|Unregistered`, `UDC_STBA|WithHasStoicTagFlag`, `UDC_STG|IzActiveUpdate`, `UDC_STG|StoicTag`, `UDC_STG|Unregistered`, `UDC_STG|WithRegisteredFlag`

*Pure compute* (8) — arguments only; no reads, no enforce

`UC_ArweaveTrackerKey`, `UC_CodexIdSmart`, `UC_CodexIdStandard`, `UC_IsBase64urlChar`, `UC_StoicTagStoaFee`, `UC_ValidateArweaveTxId`, `UC_ValidateCompositeCodexId`, `UC_ValidateStoicTagName`

*Client entry* (4) — builds the bill; reachable only through Talos

`C_RecordArweaveUpload`, `C_RegisterStoicTag`, `C_ReleaseStoicTag`, `C_RotateCodexGuard`

*Admin* (6) — admin-key mutations

`A_RegisterCodexIdentity`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (5) — this module only; writes under a capability

`XI_DeactivateStoicTag`, `XI_InsertArweaveTracker`, `XI_InsertIdentity`, `XI_UpdateCodexGuard`, `XI_UpsertStoicTag`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|CodexKey`, `GOV|Demiurgoi`

*Previews* (4) — operation previews for clients

`INFO_CODEX|RecordArweaveUpload`, `INFO_CODEX|RegisterStoicTag`, `INFO_CODEX|ReleaseStoicTag`, `INFO_CODEX|RotateCodexGuard`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_Namespace`
<!-- @end:module-page:CODEX -->

## Traps

**Its fee is the one price in the system not derived from a dollar figure.** Everything else divides a dollar amount by the current market price; this is fixed in native units per glyph, non-discountable, recorded as an owner ruling with an explicit instruction not to normalise it.

A rule with one documented exception is more trustworthy than one with none, because the exception proves someone checked.

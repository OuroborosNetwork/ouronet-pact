# DPDC-N — nonce metadata

## What it is for

Updating the mutable metadata on an existing nonce — names, descriptions, traits, and the URI slots.

Part of the **collectables family** — eleven modules serving BOTH semi-fungible and non-fungible assets through one boolean discriminator. There is no module named DPSF or DPNF anywhere; the two are mirrored table sets, not separate implementations. See `20-assets/03-semi-fungibles.md` and `04-non-fungibles.md`.

## Where it sits

Above the state core.

## What it owns, and what it exposes

<!-- @generated:module-page:DPDC-N -->
**On chain**

| | |
|---|---|
| module hash | `sDeOCTlLRtTR5-2g2Q6FyqwyLbj7IMiBCO_T2Fs2-9E` |
| deployed size | 39,058 characters |
| implements | `OuronetPolicyV2`, `DpdcNonceV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/10_DPDC-N.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 15

`DPDC-N|C>DATA`, `DPDC-N|C>SET-DATA`, `DPDC-N|C>SET-DESCRIPTION`, `DPDC-N|C>SET-IGNIS-ROYALTY`, `DPDC-N|C>SET-META-DATA`, `DPDC-N|C>SET-NAME`, `DPDC-N|C>SET-ROYALTY`, `DPDC-N|C>SET-SCORE`, `DPDC-N|C>SET-URI`, `DPDC-N|C>UPDATE`, `GOV`, `GOV|DPDC-N_ADMIN`, `P|DPDC-N|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 35, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 2 | returns what an operation will charge | `URCi_UpdateNonceField`, `URCi_UpdateNonces` |
| `UEV_` validators | 7 | read and enforce; may abort the transaction | `UEV_NonceDataUpdater`, `UEV_NotSetInstance`, `UEV_RoleModifyRoyaltiesON`, `UEV_RoleNftRecreateON`, `UEV_RoleNftUpdateON`, `UEV_RoleSetNewUriON` …+1 |
| `UR_` readers | 1 | table reads; no enforce, no writes | `UR_Nonce` |
| `XI_` protected (internal) | 1 | this module only | `XI_NonceMetaData` |
| `C_` client | 8 | reached via Talos, never called directly | `C_UpdateNonceDescription`, `C_UpdateNonceIgnisRoyalty`, `C_UpdateNonceMetaData`, `C_UpdateNonceName`, `C_UpdateNonceRoyalty`, `C_UpdateNonceScore` …+2 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 7 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi`, `XI_U|NonceNoD`, `XI_U|NonceRoyalty`, `XI_U|NonceScore`, `XI_U|NonceUri` …+1 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 15

`DPDC-N|C>DATA`, `DPDC-N|C>SET-DATA`, `DPDC-N|C>SET-DESCRIPTION`, `DPDC-N|C>SET-IGNIS-ROYALTY`, `DPDC-N|C>SET-META-DATA`, `DPDC-N|C>SET-NAME`, `DPDC-N|C>SET-ROYALTY`, `DPDC-N|C>SET-SCORE`, `DPDC-N|C>SET-URI`, `DPDC-N|C>UPDATE`, `GOV`, `GOV|DPDC-N_ADMIN`, `P|DPDC-N|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 35, grouped by what the prefix promises

*Cost readers* (2) — price an operation; the exec path and the preview both call these

`URCi_UpdateNonceField`, `URCi_UpdateNonces`

*Point reads* (2) — one row or field by key

`P|UR_IMP`, `UR_Nonce`

*Validators* (8) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_NonceDataUpdater`, `UEV_NotSetInstance`, `UEV_RoleModifyRoyaltiesON`, `UEV_RoleNftRecreateON`, `UEV_RoleNftUpdateON`, `UEV_RoleSetNewUriON`, `UEV_Score`

*Client entry* (8) — builds the bill; reachable only through Talos

`C_UpdateNonceDescription`, `C_UpdateNonceIgnisRoyalty`, `C_UpdateNonceMetaData`, `C_UpdateNonceName`, `C_UpdateNonceRoyalty`, `C_UpdateNonceScore`, `C_UpdateNonceURI`, `C_UpdateNonces`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (6) — this module only; writes under a capability

`XI_NonceMetaData`, `XI_U|NonceNoD`, `XI_U|NonceRoyalty`, `XI_U|NonceScore`, `XI_U|NonceUri`, `XI_U|NoncesData`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Bar`
<!-- @end:module-page:DPDC-N -->

## Traps

**A set instance's contents were once editable.** A non-fungible set records what went into it, and the break operation trusts that record to decide what to hand back — while this module's update path could overwrite it arbitrarily. The fix blocks edits to set *instances* while leaving the *recipe* editable, a distinction that took a specific test to pin because the two look alike from outside.

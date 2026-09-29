# DPDC-I

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:DPDC-I -->
**On chain**

| | |
|---|---|
| module hash | `WI9qGgIJXiwgpyAIoyiCRX7QcWQdivj_oMaV0x4eeDk` |
| deployed size | 23,598 characters |
| implements | `OuronetPolicyV2`, `DpdcIssueV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/04_DPDC-I.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 6

`DPDC-I|C>ISSUE`, `GOV`, `GOV|DPDC-I_ADMIN`, `P|DPDC-I|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 16, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 3 | returns what an operation will charge | `URCi_IssueCollectionPrice`, `URCi_IssueCollectionStoa`, `URCi_IssueDigitalCollection` |
| `XI_` protected (internal) | 1 | this module only | `XI_IssueDigitalCollection` |
| `C_` client | 1 | reached via Talos, never called directly | `C_IssueDigitalCollection` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 2 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 6

`DPDC-I|C>ISSUE`, `GOV`, `GOV|DPDC-I_ADMIN`, `P|DPDC-I|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 16, grouped by what the prefix promises

*Cost readers* (3) — price an operation; the exec path and the preview both call these

`URCi_IssueCollectionPrice`, `URCi_IssueCollectionStoa`, `URCi_IssueDigitalCollection`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Client entry* (1) — builds the bill; reachable only through Talos

`C_IssueDigitalCollection`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (1) — this module only; writes under a capability

`XI_IssueDigitalCollection`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Bar`
<!-- @end:module-page:DPDC-I -->

## Traps

_To be written._

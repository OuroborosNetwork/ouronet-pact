# DPDC-I — collection issuance

## What it is for

Issuing a new collection — the operation that creates a collectable's identity and its flags.

Part of the **collectables family** — eleven modules serving BOTH semi-fungible and non-fungible assets through one boolean discriminator. There is no module named DPSF or DPNF anywhere; the two are mirrored table sets, not separate implementations. See `20-assets/03-semi-fungibles.md` and `04-non-fungibles.md`.

## Where it sits

A small module above the create engine.

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

**Identifiers derive from the previous block hash**, which is per block rather than per transaction. Two collections issued with the same ticker in one block collide, and the second aborts. Investigated and closed as by-design: atomic, self-healing, and surfacing first in a shared branding table.

**Issuance is one of the few operations charging both currencies** — $20 for a semi-fungible collection, $25 for a non-fungible one.

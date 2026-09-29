# BRD — branding, shared across entity types

## What it is for

Name, description, website and social links for **every kind of Ouronet entity** — tokens of all four types, autostake pools and swap pools — with a paid premium tier renewable by the month.

## Where it sits

A Stage-1 core deployed early, because four different module families implement its interface and each needs it present.

## What it owns, and what it exposes

<!-- @generated:module-page:BRD -->
**On chain**

| | |
|---|---|
| module hash | `p6Cjo5-TwpVd2n_pb3o3fvsCen46MP07yJAKdD4a_KA` |
| deployed size | 24,498 characters |
| implements | `OuronetPolicyV2`, `BrandingV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/04_BRD.pact` |

**Tables it owns** — 3

`BRD|BrandingTable`, `P|MT`, `P|T`

**Schemas** — 1

`BRD|PropertiesSchema`

**Capabilities** — 7

`BRD|C>ADMIN_SET`, `BRD|C>LIVE`, `BRD|C>UPGRADE`, `GOV`, `GOV|BRD_ADMIN`, `P|BRD|CALLER`, `SECURE`

**Functions** — 34, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 1 | returns what an operation will charge | `URCi_UpgradeBranding` |
| `URC_` derived reads | 1 | read and derive; no enforce | `URC_MaxBluePayment` |
| `UDC_` constructors | 7 | named object constructors | `UDC_BrandingDescription`, `UDC_BrandingFlag`, `UDC_BrandingGenesis`, `UDC_BrandingLogo`, `UDC_BrandingPremium`, `UDC_BrandingSocial` …+1 |
| `UR_` readers | 8 | table reads; no enforce, no writes | `UR_Branding`, `UR_Description`, `UR_Flag`, `UR_Genesis`, `UR_Logo`, `UR_PremiumUntil` …+2 |
| `XI_` protected (internal) | 1 | this module only | `XI_UpdateBrandingData` |
| `XE_` protected (external) | 3 | for other modules; opens with the IMC gate | `XE_Issue`, `XE_UpdatePendingBranding`, `XE_UpgradeBranding` |
| `A_` admin | 2 | admin-key mutations | `A_Live`, `A_SetFlag` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 2 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `Schema`, `SocialSchema`

**Capabilities** -- 7

`BRD|C>ADMIN_SET`, `BRD|C>LIVE`, `BRD|C>UPGRADE`, `GOV`, `GOV|BRD_ADMIN`, `P|BRD|CALLER`, `SECURE`

**Functions** -- 34, grouped by what the prefix promises

*Cost readers* (1) — price an operation; the exec path and the preview both call these

`URCi_UpgradeBranding`

*Derived reads* (1) — read and compute; no enforce

`URC_MaxBluePayment`

*Point reads* (9) — one row or field by key

`P|UR_IMP`, `UR_Branding`, `UR_Description`, `UR_Flag`, `UR_Genesis`, `UR_Logo`, `UR_PremiumUntil`, `UR_Social`, `UR_Website`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Constructors* (7) — build objects

`UDC_BrandingDescription`, `UDC_BrandingFlag`, `UDC_BrandingGenesis`, `UDC_BrandingLogo`, `UDC_BrandingPremium`, `UDC_BrandingSocial`, `UDC_BrandingWebsite`

*Admin* (7) — admin-key mutations

`A_Live`, `A_SetFlag`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (3) — callable by other modules only

`XE_Issue`, `XE_UpdatePendingBranding`, `XE_UpgradeBranding`

*Internal writes* (1) — this module only; writes under a capability

`XI_UpdateBrandingData`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Bar`
<!-- @end:module-page:BRD -->

## Traps

**One interface, four implementors, and that count is the cascade's cost.** A deployed interface can never change, so a signature change here means a new version and every implementor bumping with it. The count was five until the legacy metadata module was archived — dropping an `implements` removed it from every future cascade, which is a real saving nobody plans for.

**Collectables need a different signature** because their operations take a type discriminator. So branding is split across two interfaces rather than one, and the split exists purely because of that extra parameter.

# U|DALOS

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:U|DALOS -->
**On chain**

| | |
|---|---|
| module hash | `BJFkS-BFMSL_gSnUunOJq8WuWl7JQhh8sODNRLVrkKI` |
| deployed size | 22,186 characters |
| implements | `UtilityDalosV2`, `UtilityDalosGlyphsV3` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/08_U_DALOS.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|DALOS_ADMIN`

**Functions** — 22, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 9 | read and enforce; may abort the transaction | `GLYPH|UEV_ApolloAccount`, `GLYPH|UEV_ApolloAccountCheck`, `GLYPH|UEV_DalosAccount`, `GLYPH|UEV_DalosAccountCheck`, `GLYPH|UEV_MsDc`, `UEV_Decimals` …+3 |
| `UDC_` constructors | 2 | named object constructors | `UDC_MakeMVXNonce`, `UDC_Makeid` |
| `UCv_` pure compute (validating) | 1 | compute with an intrinsic guard | `UCv_NewRoleList` |
| `UC_` pure compute | 10 | arguments only -- no reads, no enforce | `UC_ConcatWithBar`, `UC_DirectFilterId`, `UC_GasCost`, `UC_GasDiscount`, `UC_InverseFilterId`, `UC_IzCharacterANC` …+4 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|U|DALOS_ADMIN`

**Functions** -- 22, grouped by what the prefix promises

*Validators* (9) — read and enforce; failure aborts

`GLYPH|UEV_ApolloAccount`, `GLYPH|UEV_ApolloAccountCheck`, `GLYPH|UEV_DalosAccount`, `GLYPH|UEV_DalosAccountCheck`, `GLYPH|UEV_MsDc`, `UEV_Decimals`, `UEV_Fee`, `UEV_NameOrTicker`, `UEV_StoicTagName`

*Constructors* (2) — build objects

`UDC_MakeMVXNonce`, `UDC_Makeid`

*Pure compute (guarded)* (1) — compute with a guard intrinsic to the computation

`UCv_NewRoleList`

*Pure compute* (10) — arguments only; no reads, no enforce

`UC_ConcatWithBar`, `UC_DirectFilterId`, `UC_GasCost`, `UC_GasDiscount`, `UC_InverseFilterId`, `UC_IzCharacterANC`, `UC_IzStoicTagName`, `UC_IzStringANC`, `UC_StageTwoEmissionSplit`, `UC_TenTwentyThirtyFourtySplit`
<!-- @end:module-page:U|DALOS -->

## Traps

_To be written._

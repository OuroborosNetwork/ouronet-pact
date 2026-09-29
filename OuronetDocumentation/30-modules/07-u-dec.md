# U|DEC

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:U|DEC -->
**On chain**

| | |
|---|---|
| module hash | `3XUY-8yg-46W6YS_mCsBCByK-51pgcYdLFtnJdXOolw` |
| deployed size | 5,316 characters |
| implements | `OuronetDecimalsV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/07_U_DEC.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|DEC_ADMIN`

**Functions** — 6, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_DecimalArray` |
| `UCv_` pure compute (validating) | 2 | compute with an intrinsic guard | `UCv_Percent`, `UCv_Promille` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_AddArray`, `UC_AddHybridArray`, `UC_Max` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|U|DEC_ADMIN`

**Functions** -- 6, grouped by what the prefix promises

*Validators* (1) — read and enforce; failure aborts

`UEV_DecimalArray`

*Pure compute (guarded)* (2) — compute with a guard intrinsic to the computation

`UCv_Percent`, `UCv_Promille`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_AddArray`, `UC_AddHybridArray`, `UC_Max`
<!-- @end:module-page:U|DEC -->

## Traps

_To be written._

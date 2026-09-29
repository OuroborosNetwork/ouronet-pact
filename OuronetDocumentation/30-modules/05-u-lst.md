# U|LST

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:U|LST -->
**On chain**

| | |
|---|---|
| module hash | `uOWz0AL3JLrAF9xacPe4esSFFMcIZzz6dDHgBW_tvjg` |
| deployed size | 7,609 characters |
| implements | `StringProcessorV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/05_U_LST.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|LST_ADMIN`

**Functions** — 16, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 3 | read and enforce; may abort the transaction | `UEV_IzUnique`, `UEV_NotEmpty`, `UEV_StringPresence` |
| `UC_` pure compute | 13 | arguments only -- no reads, no enforce | `UC_AppL`, `UC_Chain`, `UC_FE`, `UC_InsertFirst`, `UC_IsNotEmpty`, `UC_LE` …+7 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|U|LST_ADMIN`

**Functions** -- 16, grouped by what the prefix promises

*Validators* (3) — read and enforce; failure aborts

`UEV_IzUnique`, `UEV_NotEmpty`, `UEV_StringPresence`

*Pure compute* (13) — arguments only; no reads, no enforce

`UC_AppL`, `UC_Chain`, `UC_FE`, `UC_InsertFirst`, `UC_IsNotEmpty`, `UC_LE`, `UC_RemoveItem`, `UC_RemoveItemAt`, `UC_ReplaceAt`, `UC_ReplaceItem`, `UC_Search`, `UC_SecondListElement`, `UC_SplitString`
<!-- @end:module-page:U|LST -->

## Traps

_To be written._

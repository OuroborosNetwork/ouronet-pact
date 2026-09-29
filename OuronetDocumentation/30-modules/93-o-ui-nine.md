# O-UI-NINE

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:O-UI-NINE -->
**On chain**

| | |
|---|---|
| module hash | `IobZ5by7UBZgJxykAbHiv0k_PhCk1_RD61XT01Y5ZYI` |
| deployed size | 20,620 characters |
| implements | `OUiNineV2` |
| repository source | `2_CITIZEN/Stage_Z/AppReads/OuronetUI/09_O-UI-NINE.pact` |

**Capabilities** — 2

`GOV`, `GOV|O_UI_NINE_ADMIN`

**Functions** — 14, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URC_` derived reads | 2 | read and derive; no enforce | `URC_LpValuation`, `URC_TokenValuation` |
| `UDC_` constructors | 1 | named object constructors | `UDC_ZeroValuation` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_Price` |
| *(unclassified)* | 10 | carries no StoicSyntax prefix | `GOV|Demiurgoi`, `URC_02|TokenEntry`, `URC_03|TokenList`, `URC_05|SleepingLpList`, `URC_06|Buttons`, `URC_07|HibernatingNonce` …+4 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|O_UI_NINE_ADMIN`

**Functions** -- 14, grouped by what the prefix promises

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_01|Header`

*Derived reads* (9) — read and compute; no enforce

`URC_02|TokenEntry`, `URC_03|TokenList`, `URC_05|SleepingLpList`, `URC_06|Buttons`, `URC_07|HibernatingNonce`, `URC_08|Wallet`, `URC_09|SuppliesOnly`, `URC_LpValuation`, `URC_TokenValuation`

*Constructors* (1) — build objects

`UDC_ZeroValuation`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_Price`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`URCv_04|LpEntry`
<!-- @end:module-page:O-UI-NINE -->

## Traps

_To be written._

# O-UI-NINE — orto-fungible reads

## What it is for

Reads serving the orto-fungible token pages — entries, lists, and sleeping LP.

A **read module** — no tables, a projection over sovereign state. That is what makes it freely redeployable: nothing is lost because nothing is stored. Full treatment: `10-architecture/08-the-read-layer.md`.

## Where it sits

One read module per display entity, deployed after everything it reads. Numbered rather than named, because a deployed module cannot be renamed — only superseded — and a descriptive name is a promise about content that content eventually breaks.

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

**Its header read scans**, so it cannot participate in a `try`-composed group.

**Sleeping and hibernating parcels are one family with two prefixes.** A reader testing only for one sends the other down the wrong branch and fails looking up an identifier in the wrong table.

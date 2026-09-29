# O-UI-EIGHT — page reads — tokens

## What it is for

Reads serving token display data in the interface.

A **read module**. It owns no tables — it is a projection over sovereign state, which is what makes it freely redeployable. Full treatment: `10-architecture/08-the-read-layer.md`.

## Where it sits

One read module per display entity, deployed after everything it reads. Numbered rather than named, because a deployed module cannot be renamed — only superseded — and a descriptive name is a promise about content that content eventually breaks.

## What it owns, and what it exposes

<!-- @generated:module-page:O-UI-EIGHT -->
**On chain**

| | |
|---|---|
| module hash | `7DDsHeKwHDnsiqaiOHEBZLO3i_rQGgcRDjgOzu0R0N0` |
| deployed size | 18,918 characters |
| implements | `OUiEightV2` |
| repository source | `2_CITIZEN/Stage_Z/AppReads/OuronetUI/08_O-UI-EIGHT.pact` |

**Capabilities** — 2

`GOV`, `GOV|O_UI_EIGHT_ADMIN`

**Functions** — 12, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UDC_` constructors | 1 | named object constructors | `UDC_ZeroEntry` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_Price` |
| *(unclassified)* | 10 | carries no StoicSyntax prefix | `GOV|Demiurgoi`, `URC_02|TokenEntry`, `URC_03|TokenList`, `URC_05|NativeLpList`, `URC_06|FrozenLpList`, `URC_07|Buttons` …+4 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|O_UI_EIGHT_ADMIN`

**Functions** -- 12, grouped by what the prefix promises

*Heavy reads* (1) — scan a table -- OFF the execution path, cost grows with data

`URH_01|Header`

*Derived reads* (7) — read and compute; no enforce

`URC_02|TokenEntry`, `URC_03|TokenList`, `URC_05|NativeLpList`, `URC_06|FrozenLpList`, `URC_07|Buttons`, `URC_08|Wallet`, `URC_09|SuppliesOnly`

*Constructors* (1) — build objects

`UDC_ZeroEntry`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_Price`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`URCv_04|LpEntry`
<!-- @end:module-page:O-UI-EIGHT -->

## Traps

**No tables, by rule.** Owning nothing is what allows redeployment without migration.

**Formatters are copied per module rather than shared**, deliberately: a shared helper would be a deploy dependency for every read module and destroy the single property the split buys.

**A scanning read cannot sit inside a `try`**, because Pact evaluates `try` in read-only mode where unbounded operations are disallowed. That decides whether a read can join a page that degrades gracefully.

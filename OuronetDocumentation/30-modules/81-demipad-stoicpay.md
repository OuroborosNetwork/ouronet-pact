# DEMIPAD-STOICPAY

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:DEMIPAD-STOICPAY -->
**On chain**

| | |
|---|---|
| module hash | `csRhpwj30XRuSWKSJ-yAMf2c5n1RSzTwZMXWvUuP744` |
| deployed size | 25,109 characters |
| implements | `OuronetPolicyV2`, `StoicPayV3` |
| repository source | `2_CITIZEN/7_Launchpad/4_StoicPay/04_STOICPAY.pact` |

**Tables it owns** — 3

`KPAY|T|Properties`, `P|MT`, `P|T`

**Schemas** — 1

`KPAY|PropertiesSchema`

**Capabilities** — 7

`GOV`, `GOV|KPAY_ADMIN`, `KPAY|C>BUY`, `P|KPAY|CALLER`, `P|PAD-KPAY|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 31, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 1 | returns what an operation will charge | `URCi_BuyStoicPay` |
| `URC_` derived reads | 3 | read and derive; no enforce | `URC_Acquire`, `URC_GetMaxBuy`, `URC_KpayAmountCosts` |
| `UR_` readers | 5 | table reads; no enforce, no writes | `UR_GetPeriod`, `UR_KpayID`, `UR_KpayLeft`, `UR_KpayPID`, `UR_PAD_LEDGER_ACCOUNT` |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_Acquire` |
| `INFO_` cost previews | 1 | client-facing price preview | `INFO_BuyStoicPay` |
| `C_` client | 1 | reached via Talos, never called directly | `C_BuyStoicPay` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 10 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Info`, `GOV|COMPANY`, `GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi`, `GOV|VENTURE1` …+4 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 7

`GOV`, `GOV|KPAY_ADMIN`, `KPAY|C>BUY`, `P|KPAY|CALLER`, `P|PAD-KPAY|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 31, grouped by what the prefix promises

*Cost readers* (1) — price an operation; the exec path and the preview both call these

`URCi_BuyStoicPay`

*Derived reads* (3) — read and compute; no enforce

`URC_Acquire`, `URC_GetMaxBuy`, `URC_KpayAmountCosts`

*Point reads* (6) — one row or field by key

`P|UR_IMP`, `UR_GetPeriod`, `UR_KpayID`, `UR_KpayLeft`, `UR_KpayPID`, `UR_PAD_LEDGER_ACCOUNT`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Ownership checks* (1) — account-ownership enforcement

`CAP_Acquire`

*Client entry* (1) — builds the bill; reachable only through Talos

`C_BuyStoicPay`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (7) — keysets and protocol constants

`GOV|COMPANY`, `GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi`, `GOV|VENTURE1`, `GOV|VENTURE2`, `GOV|VENTURE3`, `GOV|VENTURE4`

*Previews* (1) — operation previews for clients

`INFO_BuyStoicPay`

*Unclassified* (3) — no known prefix -- worth asking why

`CT_Bar`, `CT_Info`, `URv_PeriodAllocation`
<!-- @end:module-page:DEMIPAD-STOICPAY -->

## Traps

_To be written._

# DEMIPAD-SNAKES — the Snakes sale

## What it is for

Sells **equity shares**, priced from the live equity module rather than a hard-coded ladder, so package tiers track the company.

A **pure-citizen sale** on the sovereign launchpad venue. It owns what a unit costs and what is available; the venue owns custody, the money-in leg and the royalty. Billed Σ-wise — once per sovereign operation it composes. Full treatment: `25-defi/04-the-launchpad.md`.

## Where it sits

A citizen module above the launchpad venue and the equity module.

## What it owns, and what it exposes

<!-- @generated:module-page:DEMIPAD-SNAKES -->
**On chain**

| | |
|---|---|
| module hash | `4yM3Yf4_ZbQN6xhd1dOB1aHcOottQqy9Y2cGUVkTRto` |
| deployed size | 22,323 characters |
| implements | `OuronetPolicyV2`, `SaleSnakesV2` |
| repository source | `2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact` |

**Tables it owns** — 3

`P|MT`, `P|T`, `SNAKES|T|Properties`

**Schemas** — 1

`SNAKES|PropertiesSchema`

**Capabilities** — 8

`GOV`, `GOV|SNAKES_ADMIN`, `P|SECURE-CALLER`, `P|SNAKES|CALLER`, `P|SNAKES|REMOTE-GOV`, `SECURE`, `SNAKES|ACQUIRE`, `SNAKES|C>INITIALISE`

**Functions** — 27, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 1 | returns what an operation will charge | `URCi_Acquire` |
| `URC_` derived reads | 5 | read and derive; no enforce | `URC_Acquire`, `URC_NonceAmountCosts`, `URC_NonceCosts`, `URC_NonceValueInShares`, `URC_ShareCosts` |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_AcquisitionNonce` |
| `UR_` readers | 3 | table reads; no enforce, no writes | `UR_AssetID`, `UR_DollarSharePrice`, `UR_NonceSaleAvailability` |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_Acquire` |
| `INFO_` cost previews | 1 | client-facing price preview | `INFO_Acquire` |
| `A_` admin | 1 | admin-key mutations | `A_UpdateSharePrice` |
| `C_` client | 1 | reached via Talos, never called directly | `C_Acquire` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 4 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Info`, `GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 8

`GOV`, `GOV|SNAKES_ADMIN`, `P|SECURE-CALLER`, `P|SNAKES|CALLER`, `P|SNAKES|REMOTE-GOV`, `SECURE`, `SNAKES|ACQUIRE`, `SNAKES|C>INITIALISE`

**Functions** -- 27, grouped by what the prefix promises

*Cost readers* (1) — price an operation; the exec path and the preview both call these

`URCi_Acquire`

*Derived reads* (5) — read and compute; no enforce

`URC_Acquire`, `URC_NonceAmountCosts`, `URC_NonceCosts`, `URC_NonceValueInShares`, `URC_ShareCosts`

*Point reads* (4) — one row or field by key

`P|UR_IMP`, `UR_AssetID`, `UR_DollarSharePrice`, `UR_NonceSaleAvailability`

*Validators* (2) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AcquisitionNonce`

*Ownership checks* (1) — account-ownership enforcement

`CAP_Acquire`

*Client entry* (1) — builds the bill; reachable only through Talos

`C_Acquire`

*Admin* (6) — admin-key mutations

`A_UpdateSharePrice`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (2) — keysets and protocol constants

`GOV|DEMIPAD|SC_NAME`, `GOV|Demiurgoi`

*Previews* (1) — operation previews for clients

`INFO_Acquire`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_Info`
<!-- @end:module-page:DEMIPAD-SNAKES -->

## Traps

**Its preview once omitted a leg** — the royalty a collectable transfer pays out of the payer. Measured: **89.002 quoted against 89.004 charged** on a two-share purchase. Found because preview and charge are separately computed from a shared definition.

**A missing validity check once made an unsellable nonce report "insufficient assets"** — indistinguishable from a genuine over-buy, and the implied remedy (wait for restock) could never work.

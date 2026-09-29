# TS02-DPAD — the sovereign launchpad orchestration

## What it is for

The sovereign half of the launchpad: deposits, withdrawals and inventory movement.

Talos is the only supported client path and the only gas-funded one. See `10-architecture/01-the-layer-cake.md`.

## Where it sits

Above the launchpad venue. The **citizen** sale wrappers live in a separate module deployed after the sales themselves.

## What it owns, and what it exposes

<!-- @generated:module-page:TS02-DPAD -->
**On chain**

| | |
|---|---|
| module hash | `dLztzfE3wr8Rv2uTgBd8LOJx7OVW79Rr0LO7UvPKQ1c` |
| deployed size | 22,210 characters |
| implements | `OuronetPolicyV2`, `TalosStageTwo_DemiPadV2` |
| repository source | `1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 5

`GOV`, `GOV|TS02-DPAD_ADMIN`, `P|TALOS-SUMMONER`, `P|TS`, `SECURE`

**Functions** — 25, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_ShortAccount` |
| `A_` admin | 4 | admin-key mutations | `A_DefinePrice`, `A_RegisterAssetToLaunchpad`, `A_ToggleOpenForBusiness`, `A_ToggleRetrieval` |
| `C_` client | 10 | reached via Talos, never called directly | `DEMIPAD|C_Deposit`, `DEMIPAD|C_FuelNonFungible`, `DEMIPAD|C_FuelOrtoFungible`, `DEMIPAD|C_FuelSemiFungible`, `DEMIPAD|C_FuelTrueFungible`, `DEMIPAD|C_RetrieveNonFungible` …+4 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 1 | carries no StoicSyntax prefix | `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 5

`GOV`, `GOV|TS02-DPAD_ADMIN`, `P|TALOS-SUMMONER`, `P|TS`, `SECURE`

**Functions** -- 25, grouped by what the prefix promises

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_ShortAccount`

*Client entry* (10) — builds the bill; reachable only through Talos

`DEMIPAD|C_Deposit`, `DEMIPAD|C_FuelNonFungible`, `DEMIPAD|C_FuelOrtoFungible`, `DEMIPAD|C_FuelSemiFungible`, `DEMIPAD|C_FuelTrueFungible`, `DEMIPAD|C_RetrieveNonFungible`, `DEMIPAD|C_RetrieveOrtoFungible`, `DEMIPAD|C_RetrieveSemiFungible`, `DEMIPAD|C_RetrieveTrueFungible`, `DEMIPAD|C_Withdraw`

*Admin* (9) — admin-key mutations

`A_DefinePrice`, `A_RegisterAssetToLaunchpad`, `A_ToggleOpenForBusiness`, `A_ToggleRetrieval`, `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

**Client entrypoints** -- 10

| entrypoint | preview |
|---|---|
| `TS02-DPAD.DEMIPAD|C_Deposit` | `INFO-TWO.INFO_DEMIPAD|Deposit` |
| `TS02-DPAD.DEMIPAD|C_FuelNonFungible` | `INFO-TWO.INFO_DEMIPAD|FuelNonFungible` |
| `TS02-DPAD.DEMIPAD|C_FuelOrtoFungible` | `INFO-TWO.INFO_DEMIPAD|FuelOrtoFungible` |
| `TS02-DPAD.DEMIPAD|C_FuelSemiFungible` | `INFO-TWO.INFO_DEMIPAD|FuelSemiFungible` |
| `TS02-DPAD.DEMIPAD|C_FuelTrueFungible` | `INFO-TWO.INFO_DEMIPAD|FuelTrueFungible` |
| `TS02-DPAD.DEMIPAD|C_RetrieveNonFungible` | `INFO-TWO.INFO_DEMIPAD|RetrieveNonFungible` |
| `TS02-DPAD.DEMIPAD|C_RetrieveOrtoFungible` | `INFO-TWO.INFO_DEMIPAD|RetrieveOrtoFungible` |
| `TS02-DPAD.DEMIPAD|C_RetrieveSemiFungible` | `INFO-TWO.INFO_DEMIPAD|RetrieveSemiFungible` |
| `TS02-DPAD.DEMIPAD|C_RetrieveTrueFungible` | `INFO-TWO.INFO_DEMIPAD|RetrieveTrueFungible` |
| `TS02-DPAD.DEMIPAD|C_Withdraw` | `INFO-TWO.INFO_DEMIPAD|Withdraw` |
<!-- @end:module-page:TS02-DPAD -->

## Traps

**This holds only the sovereign operations.** The per-sale wrappers moved to the citizen Talos, and one letter separates the two module names. This project's own instruction file once described the wrong one as sovereign.

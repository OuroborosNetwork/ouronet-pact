# TS02-CPAD — the citizen launchpad orchestration

## What it is for

All seven citizen sale wrappers in one module, so they can be granted gas-station access together.

## Where it sits

Deployed **last** — after the sales it wraps.

## What it owns, and what it exposes

<!-- @generated:module-page:TS02-CPAD -->
**On chain**

| | |
|---|---|
| module hash | `DvLbtKVBl02gLcsLCq4NQKlnqGZdGRCTH7Fg3S6UIK8` |
| deployed size | 12,333 characters |
| implements | `OuronetPolicyV2`, `CitizenLaunchpadTalosV1` |
| repository source | `2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 5

`GOV`, `GOV|TS02-CPAD_ADMIN`, `P|TALOS-SUMMONER`, `P|TS`, `SECURE`

**Functions** — 18, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_ShortAccount` |
| `C_` client | 7 | reached via Talos, never called directly | `CUSTODIANS|C_Acquire`, `KPAY|C_BuyStoicPay`, `SNAKES|C_Acquire`, `SPARK|C_BuySparks`, `SPARK|C_RedemAllSparks`, `SPARK|C_RedemFewSparks` …+1 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 1 | carries no StoicSyntax prefix | `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 5

`GOV`, `GOV|TS02-CPAD_ADMIN`, `P|TALOS-SUMMONER`, `P|TS`, `SECURE`

**Functions** -- 18, grouped by what the prefix promises

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_ShortAccount`

*Client entry* (7) — builds the bill; reachable only through Talos

`CUSTODIANS|C_Acquire`, `KPAY|C_BuyStoicPay`, `SNAKES|C_Acquire`, `SPARK|C_BuySparks`, `SPARK|C_RedemAllSparks`, `SPARK|C_RedemFewSparks`, `STOAICO|C_Collect`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

**Client entrypoints** -- 7

| entrypoint | preview |
|---|---|
| `TS02-CPAD.CUSTODIANS|C_Acquire` | `DEMIPAD-CUSTODIANS.INFO_Acquire` |
| `TS02-CPAD.KPAY|C_BuyStoicPay` | `DEMIPAD-STOICPAY.INFO_BuyStoicPay` |
| `TS02-CPAD.SNAKES|C_Acquire` | `DEMIPAD-SNAKES.INFO_Acquire` |
| `TS02-CPAD.SPARK|C_BuySparks` | `DEMIPAD-SPARK.INFO_BuySparks` |
| `TS02-CPAD.SPARK|C_RedemAllSparks` | `DEMIPAD-SPARK.INFO_RedeemSparks` |
| `TS02-CPAD.SPARK|C_RedemFewSparks` | `DEMIPAD-SPARK.INFO_RedeemSparks` |
| `TS02-CPAD.STOAICO|C_Collect` | `STOAICO.INFO_Collect` |
<!-- @end:module-page:TS02-CPAD -->

## Traps

**Callable and sponsored are different things.** Its own header states it: the citizen functions stay callable directly from their own modules, but **only these wrappers are the gas-funded path**. A direct call works and is not paid for.

**Only the four buy wrappers top up the gas station** afterwards; the redeem and collect wrappers do not.

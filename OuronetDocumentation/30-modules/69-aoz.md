# AOZ — the primal-asset registrar

## What it is for

Registers the system's primal assets and their pools.

A **citizen module** — an extension anyone could have written. It calls only finished sovereign operations, adds no capabilities to the core, and is billed **Σ-wise**: once per operation, because a citizen cannot fold a bill. See `40-journeys/04-as-a-builder.md`. It is one of the purest examples: it calls **only** autostake orchestration.

## Where it sits

A citizen module above Stage 1.

## What it owns, and what it exposes

<!-- @generated:module-page:AOZ -->
**On chain**

| | |
|---|---|
| module hash | `UgDNqvR2Khy4A1ZQEK9ic0Kdetuoc_kDsgD_2_mOL88` |
| deployed size | 14,340 characters |
| implements | `AgeOfZalmoxis` |
| repository source | `2_CITIZEN/1_AOZ/01_AOZ+.pact` |

**Tables it owns** — 8

`AOZ|T|AssetCounter`, `AOZ|T|AutostakePairs`, `AOZ|T|NonFungibles`, `AOZ|T|OrtoFungibles`, `AOZ|T|PrimalOrtoFungibles`, `AOZ|T|PrimalTrueFungibles`, `AOZ|T|SemiFungibles`, `AOZ|T|TrueFungibles`

**Schemas** — 8

`AOZ|AssetCounter`, `AOZ|AutostakePairs`, `AOZ|NonFungibles`, `AOZ|OrtoFungibles`, `AOZ|PrimalOrtoFungibles`, `AOZ|PrimalTrueFungibles`, `AOZ|SemiFungibles`, `AOZ|TrueFungibles`

**Capabilities** — 4

`GOV`, `GOV|AOZ_ADMIN`, `SECURE`, `SECURE-ADMIN`

**Functions** — 40, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_Str` |
| `UR_` readers | 14 | table reads; no enforce, no writes | `UR_AutostakePair`, `UR_CountATSPairs`, `UR_CountNonFungibles`, `UR_CountOrtoFungibles`, `UR_CountPrimalOrtoFungibles`, `UR_CountPrimalTrueFungibles` …+8 |
| `XI_` protected (internal) | 7 | this module only | `XI_IncrementATSPairsCounter`, `XI_IncrementNonFungiblesCounter`, `XI_IncrementOrtoFungiblesCounter`, `XI_IncrementPrimalOrtoFungiblesCounter`, `XI_IncrementPrimalTrueFungiblesCounter`, `XI_IncrementSemiFungiblesCounter` …+1 |
| `A_` admin | 8 | admin-key mutations | `A_InitialiseCounters`, `A_RegisterAutostakePair`, `A_RegisterNonFungible`, `A_RegisterOrtoFungible`, `A_RegisterPrimalOrtoFungible`, `A_RegisterPrimalTrueFungible` …+2 |
| `C_` client | 1 | reached via Talos, never called directly | `C_SetupKosonicATS` |
| *(unclassified)* | 9 | carries no StoicSyntax prefix | `CT_Namespace`, `GOV|Demiurgoi`, `XI_W|AutostakePair`, `XI_W|NonFungible`, `XI_W|OrtoFungible`, `XI_W|PrimalOrtoFungible` …+3 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 4

`GOV`, `GOV|AOZ_ADMIN`, `SECURE`, `SECURE-ADMIN`

**Functions** -- 40, grouped by what the prefix promises

*Point reads* (14) — one row or field by key

`UR_AutostakePair`, `UR_CountATSPairs`, `UR_CountNonFungibles`, `UR_CountOrtoFungibles`, `UR_CountPrimalOrtoFungibles`, `UR_CountPrimalTrueFungibles`, `UR_CountSemiFungibles`, `UR_CountTrueFungibles`, `UR_NonFungible`, `UR_OrtoFungible`, `UR_PrimalOrtoFungible`, `UR_PrimalTrueFungible`, `UR_SemiFungible`, `UR_TrueFungible`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_Str`

*Client entry* (1) — builds the bill; reachable only through Talos

`C_SetupKosonicATS`

*Admin* (8) — admin-key mutations

`A_InitialiseCounters`, `A_RegisterAutostakePair`, `A_RegisterNonFungible`, `A_RegisterOrtoFungible`, `A_RegisterPrimalOrtoFungible`, `A_RegisterPrimalTrueFungible`, `A_RegisterSemiFungible`, `A_RegisterTrueFungible`

*Internal writes* (14) — this module only; writes under a capability

`XI_IncrementATSPairsCounter`, `XI_IncrementNonFungiblesCounter`, `XI_IncrementOrtoFungiblesCounter`, `XI_IncrementPrimalOrtoFungiblesCounter`, `XI_IncrementPrimalTrueFungiblesCounter`, `XI_IncrementSemiFungiblesCounter`, `XI_IncrementTrueFungiblesCounter`, `XI_W|AutostakePair`, `XI_W|NonFungible`, `XI_W|OrtoFungible`, `XI_W|PrimalOrtoFungible`, `XI_W|PrimalTrueFungible`, `XI_W|SemiFungible`, `XI_W|TrueFungible`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Namespace`
<!-- @end:module-page:AOZ -->

## Traps

**The five pools it registers are the ones that read a zero index at deploy** — receipt supply minted outside the pool against no stake. That is the reachable division-by-zero described in the autostake core's traps, and these pools are why it was reachable rather than theoretical.

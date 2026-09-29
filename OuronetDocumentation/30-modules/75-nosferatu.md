# NOSFERATU

> **PROSE NOT YET WRITTEN.** This page currently carries only its generated
> enumeration. What this module is *for*, how it works and what has bitten
> people are written by hand and are missing.

## What it is for

_To be written._

## Where it sits

_To be written._

## What it owns, and what it exposes

<!-- @generated:module-page:NOSFERATU -->
**On chain**

| | |
|---|---|
| module hash | `0ZoO1ZLQ-EgpjmkuCt3HK3-BgULd28lneI8s07_KTB4` |
| deployed size | 12,520 characters |
| implements | — |
| repository source | `2_CITIZEN/3_NosferatuMinter/01_NOSFERATU.pact` |

**Schemas** — 1, with no tables of its own

`NosferatuMetaData`

**Capabilities** — 3

`GOV`, `GOV|DPL_NFT_ADMIN`, `SECURE`

**Functions** — 31, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UC_` pure compute | 2 | arguments only -- no reads, no enforce | `UC_IpfsLink`, `UC_PaddedNumber` |
| `A_` admin | 22 | admin-key mutations | `A_Step01`, `A_Step02`, `A_Step03`, `A_Step04`, `A_Step05`, `A_Step06` …+16 |
| *(unclassified)* | 7 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi`, `GOV|NS_Use`, `N`, `NonceComputer`, `NosferatuNonceDataMaker` …+1 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **functions** on chain only: `GOV|NS_Use`, `N`, `NonceComputer`, `NosferatuNonceDataMaker`, `NosferatuSpawner`
> - **functions** in the repository only: `A_Fix01`, `A_Fix02a`, `A_Fix02b`, `A_Fix03`, `A_Fix04`, `A_Fix05a`, `A_Fix05b`, `A_Fix06`

**Capabilities** -- 3

`GOV`, `GOV|DPL_NFT_ADMIN`, `SECURE`

**Functions** -- 31, grouped by what the prefix promises

*Pure compute* (2) — arguments only; no reads, no enforce

`UC_IpfsLink`, `UC_PaddedNumber`

*Admin* (22) — admin-key mutations

`A_Step01`, `A_Step02`, `A_Step03`, `A_Step04`, `A_Step05`, `A_Step06`, `A_Step07`, `A_Step08`, `A_Step09`, `A_Step10`, `A_Step11`, `A_Step12`, `A_Step13`, `A_Step14`, `A_Step15`, `A_Step16`, `A_Step17`, `A_Step18`, `A_Step19`, `A_Step20`, `A_Step21`, `A_Step22`

*Governance* (2) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|NS_Use`

*Unclassified* (5) — no known prefix -- worth asking why

`CT_Bar`, `N`, `NonceComputer`, `NosferatuNonceDataMaker`, `NosferatuSpawner`
<!-- @end:module-page:NOSFERATU -->

## Traps

_To be written._

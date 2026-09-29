# U|CT — constants, and the price oracle

## What it is for

Protocol-wide constants — token name and ticker lengths, decimal bounds, fee precision, the `"|"` sentinel every unset reference reads as — and the reader that fetches **STOA's dollar price from an external oracle**.

That second job is why a constants module matters more than it sounds: every native-currency price in Ouronet is a dollar figure divided by this number. It is the single point where the protocol's prices meet the outside world.

## Where it sits

The **first** utility, and therefore the first thing deployed. Everything above it depends on its constants; it depends on nothing.

## What it owns, and what it exposes

<!-- @generated:module-page:U|CT -->
**On chain**

| | |
|---|---|
| module hash | `KstTE0JIluSgmTF2kcCWFhLuMKwh9SSDSlgb0QtZYLs` |
| deployed size | 7,938 characters |
| implements | `OuronetConstantsV2`, `DiaStoaPidV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/01_U_CT.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|CT_ADMIN`

**Functions** — 81, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| *(unclassified)* | 81 | carries no StoicSyntax prefix | `CT_ACCOUNT_ID_MAX_LENGTH`, `CT_ACCOUNT_ID_PROH-CHAR`, `CT_ATS-FeeLock`, `CT_BAR`, `CT_C1`, `CT_C2` …+75 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|U|CT_ADMIN`

**Functions** -- 81, grouped by what the prefix promises

*Point reads* (1) — one row or field by key

`UR_STOA-PID|Price`

*Unclassified* (80) — no known prefix -- worth asking why

`CT_ACCOUNT_ID_MAX_LENGTH`, `CT_ACCOUNT_ID_PROH-CHAR`, `CT_ATS-FeeLock`, `CT_BAR`, `CT_C1`, `CT_C2`, `CT_C3`, `CT_C4`, `CT_C5`, `CT_C6`, `CT_C7`, `CT_CAPITAL_LETTERS`, `CT_DEB`, `CT_DPTF-FeeLock`, `CT_ET`, `CT_FEE_PRECISION`, `CT_GOV|UTILS`, `CT_MAX_PRECISION`, `CT_MAX_TOKEN_NAME_LENGTH`, `CT_MAX_TOKEN_TICKER_LENGTH`, `CT_MIN_DESIGNATION_LENGTH`, `CT_MIN_PRECISION`, `CT_N00`, `CT_N01`, `CT_N11`, `CT_N12`, `CT_N13`, `CT_N14`, `CT_N15`, `CT_N16`, `CT_N17`, `CT_N21`, `CT_N22`, `CT_N23`, `CT_N24`, `CT_N25`, `CT_N26`, `CT_N27`, `CT_N31`, `CT_N32`, `CT_N33`, `CT_N34`, `CT_N35`, `CT_N36`, `CT_N37`, `CT_N41`, `CT_N42`, `CT_N43`, `CT_N44`, `CT_N45`, `CT_N46`, `CT_N47`, `CT_N51`, `CT_N52`, `CT_N53`, `CT_N54`, `CT_N55`, `CT_N56`, `CT_N57`, `CT_N61`, `CT_N62`, `CT_N63`, `CT_N64`, `CT_N65`, `CT_N66`, `CT_N67`, `CT_N71`, `CT_N72`, `CT_N73`, `CT_N74`, `CT_N75`, `CT_N76`, `CT_N77`, `CT_NON_CAPITAL_LETTERS`, `CT_NS_USE`, `CT_NUMBERS`, `CT_NamespaceMain`, `CT_NamespaceTest`, `CT_SPECIAL`, `CT_STOA_PRECISION`
<!-- @end:module-page:U|CT -->

## Traps

**The fee-lock duration differs between environments** — a small value in tests, a large one on mainnet. Test output about lock expiry says nothing about production behaviour.

**The `"|"` sentinel is defined here** and is the most-repeated trap in the system: an unset reference reads as `"|"`, not as an empty string or list. Code testing for emptiness gets the wrong answer, and code passing it onward uses it as a table key — which fails uncatchably. See `20-assets/07-pool-positions.md` for a case measured on mainnet.

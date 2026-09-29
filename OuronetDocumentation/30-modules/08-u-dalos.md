# U|DALOS — the account alphabet and format

## What it is for

The **256-glyph alphabet** and the validators that check an Ouronet account is well-formed.

The alphabet is assembled from ten named sub-constants — digits, currency signs, Latin, Latin Extended, Greek and Cyrillic in both cases — totalling exactly **256**. That number is the design: 256 symbols over 160 body positions is exactly one byte per character, so an account carries **1,280 bits**.

It also generates the identifiers for every token, pool and anchor in the system: a ticker, a hyphen, and twelve characters of the previous block hash.

## Where it sits

A utility, deployed before the account core that uses it. It is where the account *format* lives; the account *table* lives one layer up.

## What it owns, and what it exposes

<!-- @generated:module-page:U|DALOS -->
**On chain**

| | |
|---|---|
| module hash | `BJFkS-BFMSL_gSnUunOJq8WuWl7JQhh8sODNRLVrkKI` |
| deployed size | 22,186 characters |
| implements | `UtilityDalosV2`, `UtilityDalosGlyphsV3` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/08_U_DALOS.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|DALOS_ADMIN`

**Functions** — 22, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 9 | read and enforce; may abort the transaction | `GLYPH|UEV_ApolloAccount`, `GLYPH|UEV_ApolloAccountCheck`, `GLYPH|UEV_DalosAccount`, `GLYPH|UEV_DalosAccountCheck`, `GLYPH|UEV_MsDc`, `UEV_Decimals` …+3 |
| `UDC_` constructors | 2 | named object constructors | `UDC_MakeMVXNonce`, `UDC_Makeid` |
| `UCv_` pure compute (validating) | 1 | compute with an intrinsic guard | `UCv_NewRoleList` |
| `UC_` pure compute | 10 | arguments only -- no reads, no enforce | `UC_ConcatWithBar`, `UC_DirectFilterId`, `UC_GasCost`, `UC_GasDiscount`, `UC_InverseFilterId`, `UC_IzCharacterANC` …+4 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|U|DALOS_ADMIN`

**Functions** -- 22, grouped by what the prefix promises

*Validators* (9) — read and enforce; failure aborts

`GLYPH|UEV_ApolloAccount`, `GLYPH|UEV_ApolloAccountCheck`, `GLYPH|UEV_DalosAccount`, `GLYPH|UEV_DalosAccountCheck`, `GLYPH|UEV_MsDc`, `UEV_Decimals`, `UEV_Fee`, `UEV_NameOrTicker`, `UEV_StoicTagName`

*Constructors* (2) — build objects

`UDC_MakeMVXNonce`, `UDC_Makeid`

*Pure compute (guarded)* (1) — compute with a guard intrinsic to the computation

`UCv_NewRoleList`

*Pure compute* (10) — arguments only; no reads, no enforce

`UC_ConcatWithBar`, `UC_DirectFilterId`, `UC_GasCost`, `UC_GasDiscount`, `UC_InverseFilterId`, `UC_IzCharacterANC`, `UC_IzStoicTagName`, `UC_IzStringANC`, `UC_StageTwoEmissionSplit`, `UC_TenTwentyThirtyFourtySplit`
<!-- @end:module-page:U|DALOS -->

## Traps

**The separator cannot appear in a body.** The `.` lives in a different constant that is deliberately not part of the alphabet, so splitting an account into its parts never needs to guess.

**162 characters is 287 bytes.** Most of the alphabet is outside ASCII. Code that treats those as the same number is wrong by 125.

**Identifiers derive from the previous block hash, which is per block, not per transaction.** Two issuances of the same ticker in one block produce byte-identical identifiers and the second aborts. Accepted as by-design after investigation: it is atomic and self-healing, and fixing it properly would need a utility deployed *before* the core reading a core table, which the deploy order forbids.

**And the derivation of an account from a key is not here, or anywhere on chain.** This module validates shape only. See `80-cryptography/04-what-is-not-on-chain.md`.

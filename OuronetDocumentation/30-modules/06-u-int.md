# U|INT — integer mathematics

## What it is for

Integer helpers — bounds, comparisons, and the exponentiation used by the swap curves.

## Where it sits

A leaf utility. Its exponentiation is used by the stable-pool solver.

## What it owns, and what it exposes

<!-- @generated:module-page:U|INT -->
**On chain**

| | |
|---|---|
| module hash | `2mnBRENEaaR5nqTfUMEBKKV6fvWzSsSFWDRKKMFTeAk` |
| deployed size | 6,969 characters |
| implements | `OuronetIntegersV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/06_U_INT.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|INT_ADMIN`

**Functions** — 9, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 4 | read and enforce; may abort the transaction | `UEV_ContainsAll`, `UEV_MaxInteger`, `UEV_PositionalVariable`, `UEV_UniformList` |
| `UDC_` constructors | 2 | named object constructors | `UDC_NonceSplitter`, `UDC_SplitIntegers` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_NonceSplitter`, `UC_SplitAuxiliaryIntegerList`, `UC_SplitIntegerList` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `NonceSplitter`, `SplitIntegers`

**Capabilities** -- 2

`GOV`, `GOV|U|INT_ADMIN`

**Functions** -- 9, grouped by what the prefix promises

*Validators* (4) — read and enforce; failure aborts

`UEV_ContainsAll`, `UEV_MaxInteger`, `UEV_PositionalVariable`, `UEV_UniformList`

*Constructors* (2) — build objects

`UDC_NonceSplitter`, `UDC_SplitIntegers`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_NonceSplitter`, `UC_SplitAuxiliaryIntegerList`, `UC_SplitIntegerList`
<!-- @end:module-page:U|INT -->

## Traps

**Repeated multiplication exists here because the native power operator is not exact.** Pact's `^` drops to double precision for decimal exponents. For whole-number exponents this module works around it; for the genuinely fractional exponents weighted pools need, it cannot — an accepted, documented limitation described in `25-defi/02-swap-pools.md`.

# U|DEC — decimal mathematics

## What it is for

Decimal helpers — rounding, splitting an amount by per-mille shares, and the precision handling every price and fee depends on.

## Where it sits

A leaf utility, used by every module that computes money.

## What it owns, and what it exposes

<!-- @generated:module-page:U|DEC -->
**On chain**

| | |
|---|---|
| module hash | `3XUY-8yg-46W6YS_mCsBCByK-51pgcYdLFtnJdXOolw` |
| deployed size | 5,316 characters |
| implements | `OuronetDecimalsV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/07_U_DEC.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|DEC_ADMIN`

**Functions** — 6, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_DecimalArray` |
| `UCv_` pure compute (validating) | 2 | compute with an intrinsic guard | `UCv_Percent`, `UCv_Promille` |
| `UC_` pure compute | 3 | arguments only -- no reads, no enforce | `UC_AddArray`, `UC_AddHybridArray`, `UC_Max` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|U|DEC_ADMIN`

**Functions** -- 6, grouped by what the prefix promises

*Validators* (1) — read and enforce; failure aborts

`UEV_DecimalArray`

*Pure compute (guarded)* (2) — compute with a guard intrinsic to the computation

`UCv_Percent`, `UCv_Promille`

*Pure compute* (3) — arguments only; no reads, no enforce

`UC_AddArray`, `UC_AddHybridArray`, `UC_Max`
<!-- @end:module-page:U|DEC -->

## Traps

**Rounding direction is a design decision, not a detail.** Where an amount is split, the last share absorbs the remainder by construction, so the parts always sum to the whole. Where a swap settles, the output is floored and the input is ceilinged — always in the pool's favour. Reversing either leaks value in a direction nobody notices immediately.

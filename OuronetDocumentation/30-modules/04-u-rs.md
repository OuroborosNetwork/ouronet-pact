# U|RS — reserved account prefixes

## What it is for

Validation for the host chain's **reserved account prefixes** — `k:`, `c:`, `u:` and the rest, which encode what kind of principal an account name refers to.

## Where it sits

A leaf utility. Concerns host-chain account names only.

## What it owns, and what it exposes

<!-- @generated:module-page:U|RS -->
**On chain**

| | |
|---|---|
| module hash | `rjakin4Uhr8ZQIT2KZirrVlxG0GW3LLNWrO0rxKzbBM` |
| deployed size | 3,152 characters |
| implements | `ReservedAccountsV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/04_U_RS.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|RS_ADMIN`

**Functions** — 2, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 2 | read and enforce; may abort the transaction | `UEV_CheckReserved`, `UEV_EnforceReserved` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|U|RS_ADMIN`

**Functions** -- 2, grouped by what the prefix promises

*Validators* (2) — read and enforce; failure aborts

`UEV_CheckReserved`, `UEV_EnforceReserved`
<!-- @end:module-page:U|RS -->

## Traps

**This is about host-chain accounts, not Ouronet accounts.** The two namespaces are unrelated: an Ouronet account is a 162-glyph identifier with its own alphabet, validated elsewhere. Confusing the two is easy because both are called "accounts".

# U|LST — list and string processing

## What it is for

List and string utilities — searching, deduplication, slicing, formatting. The plumbing that Pact does not provide.

## Where it sits

A leaf utility, used almost everywhere above it.

## What it owns, and what it exposes

<!-- @generated:module-page:U|LST -->
**On chain**

| | |
|---|---|
| module hash | `uOWz0AL3JLrAF9xacPe4esSFFMcIZzz6dDHgBW_tvjg` |
| deployed size | 7,609 characters |
| implements | `StringProcessorV2` |
| repository source | `1_SOVEREIGN/STAGE_01/1_Utilities/05_U_LST.pact` |

**Capabilities** — 2

`GOV`, `GOV|U|LST_ADMIN`

**Functions** — 16, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UEV_` validators | 3 | read and enforce; may abort the transaction | `UEV_IzUnique`, `UEV_NotEmpty`, `UEV_StringPresence` |
| `UC_` pure compute | 13 | arguments only -- no reads, no enforce | `UC_AppL`, `UC_Chain`, `UC_FE`, `UC_InsertFirst`, `UC_IsNotEmpty`, `UC_LE` …+7 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|U|LST_ADMIN`

**Functions** -- 16, grouped by what the prefix promises

*Validators* (3) — read and enforce; failure aborts

`UEV_IzUnique`, `UEV_NotEmpty`, `UEV_StringPresence`

*Pure compute* (13) — arguments only; no reads, no enforce

`UC_AppL`, `UC_Chain`, `UC_FE`, `UC_InsertFirst`, `UC_IsNotEmpty`, `UC_LE`, `UC_RemoveItem`, `UC_RemoveItemAt`, `UC_ReplaceAt`, `UC_ReplaceItem`, `UC_Search`, `UC_SecondListElement`, `UC_SplitString`
<!-- @end:module-page:U|LST -->

## Traps

**Uniqueness checking here is load-bearing further up.** The swap layer's protection against a pool containing the same token twice is not in the swap layer at all — it is this module's uniqueness check, reached several calls down. An audit finding traced exactly that path and closed as verified-safe by design rather than by a local guard.

**`(enumerate 0 -1)` returns `[0 -1]`, not `[]`.** Several guards derived from it treated an empty input as a one-element one, and failed with an index error instead of a clean refusal.

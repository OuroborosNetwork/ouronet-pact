# INFO-ZERO — an empty tombstone

## What it is for

Nothing. It is an **obsolete module kept deployed because Pact cannot remove one**.

Its contents moved into the gas module during an early refactor, and what remains is a marker.

## Where it sits

Nominally the first read-layer module. In practice a historical artefact.

## What it owns, and what it exposes

<!-- @generated:module-page:INFO-ZERO -->
**On chain**

| | |
|---|---|
| module hash | `rztvKQOaSR6KvKN3CJYBKfZWF5HgpVbT5I_W3fdLMm4` |
| deployed size | 1,854 characters |
| implements | — |
| repository source | `1_SOVEREIGN/STAGE_01/Z_Reads/01_INFO-ZERO.pact` |

**Capabilities** — 1

`GOV`

**Functions** — 1, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| *(unclassified)* | 1 | carries no StoicSyntax prefix | `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 1

`GOV`

**Functions** -- 1, grouped by what the prefix promises

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`
<!-- @end:module-page:INFO-ZERO -->

## Traps

**A deployed module can never be removed**, so retirement means emptying rather than deleting. This is the smallest example of the archive pattern described in `20-assets/02-orto-fungibles.md`, where a much larger module was retired the same way — every reader kept so history stays readable, every writer deleted.

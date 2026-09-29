# KBN — a citizen minter

## What it is for

Mints a collection in batches.

A **citizen module** — an extension anyone could have written. It calls only finished sovereign operations, adds no capabilities to the core, and is billed **Σ-wise**: once per operation, because a citizen cannot fold a bill. See `40-journeys/04-as-a-builder.md`.

## Where it sits

A citizen module above the collectables family.

## What it owns, and what it exposes

<!-- @generated:module-page:KBN -->
**On chain**

| | |
|---|---|
| module hash | `5nVlXL2e0s3PFdhxzwWFmIgcl52ka49pIeIDJEjsqZs` |
| deployed size | 11,486 characters |
| implements | — |
| repository source | `2_CITIZEN/4_BunniesMinter/02_KBunnies.pact` |

**Schemas** — 1, with no tables of its own

`BunnyMetaData`

**Capabilities** — 3

`GOV`, `GOV|DPL_NFT_ADMIN`, `SECURE`

**Functions** — 23, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UDC_` constructors | 1 | named object constructors | `UDC_MetaData` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_IpfsLink` |
| `A_` admin | 17 | admin-key mutations | `A_BunnyRGBSet`, `A_Step01`, `A_Step02`, `A_Step03`, `A_Step04`, `A_Step05` …+11 |
| `C_` client | 1 | reached via Talos, never called directly | `C_Spawn` |
| *(unclassified)* | 3 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Namespace`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 3

`GOV`, `GOV|DPL_NFT_ADMIN`, `SECURE`

**Functions** -- 23, grouped by what the prefix promises

*Constructors* (1) — build objects

`UDC_MetaData`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_IpfsLink`

*Client entry* (1) — builds the bill; reachable only through Talos

`C_Spawn`

*Admin* (17) — admin-key mutations

`A_BunnyRGBSet`, `A_Step01`, `A_Step02`, `A_Step03`, `A_Step04`, `A_Step05`, `A_Step06`, `A_Step07`, `A_Step08`, `A_Step09`, `A_Step10`, `A_Step11`, `A_Step12`, `A_Step13`, `A_Step14`, `A_Step15`, `A_Step16`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_Namespace`
<!-- @end:module-page:KBN -->

## Traps

See the sibling minter's traps — the same batch-billing property applies, and the same bounded exception to the self-call rule.

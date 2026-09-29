# DPL-UR — an emptied read module

## What it is for

Nothing. It was the system's single read module — 71 public reads in one contract, about 11% of a block to deploy — and it was **emptied** when the read layer was split.

## Where it sits

A tombstone. Its successors are the per-page read modules.

## What it owns, and what it exposes

<!-- @generated:module-page:DPL-UR -->
**On chain**

| | |
|---|---|
| module hash | `CrjYQUkBpQkpqanjdJvh7AAPtko0jbkcOv_jQvVzBVY` |
| deployed size | 1,960 characters |
| implements | — |
| repository source | `2_CITIZEN/Stage_Z/01_DPL-UR.pact` |

**Capabilities** — 2

`GOV`, `GOV|DPL_UR_ADMIN`

**Functions** — 3, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| *(unclassified)* | 3 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Namespace`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 2

`GOV`, `GOV|DPL_UR_ADMIN`

**Functions** -- 3, grouped by what the prefix promises

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_Namespace`
<!-- @end:module-page:DPL-UR -->

## Traps

**It was emptied rather than left in place**, and the reasoning is the useful part: *a migrated read left in place is a second source of truth answering the same question, and the two drift the moment either is touched.*

**An earlier attempt kept functions by dependency closure** and produced a closed cluster of dead code that kept itself alive by citation — each survivor referenced only by another survivor, none reachable from any entry point. Reachability from *something* is not reachability.

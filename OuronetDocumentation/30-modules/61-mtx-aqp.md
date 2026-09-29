# MTX-AQP — multi-step acquisition operations

## What it is for

Continuation forms of injection and anchor revocation, for cases too large for one transaction.

Part of the **acquisition-pool family** — ten modules, the largest subsystem in the system. Full treatment: `25-defi/03-acquisition-pools.md`.

## Where it sits

Beside the distributor, for the operations that must be split.

## What it owns, and what it exposes

<!-- @generated:module-page:MTX-AQP -->
**On chain**

| | |
|---|---|
| module hash | `GnaBHgIWqnoLahra8cBN_0dLMdCAqAFmL1wi1NmJdzo` |
| deployed size | 26,317 characters |
| implements | `OuronetPolicyV2`, `AqpMtxV1` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/07_MTX-AQP.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 9

`GOV`, `GOV|MTX-AQP_ADMIN`, `MTX-AQP|C>INJECT`, `MTX-AQP|C>SWEEP-REVOKE`, `P|DT`, `P|MTX-AQP|CALLER`, `P|MTX-AQP|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 16, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URC_` derived reads | 1 | read and derive; no enforce | `URC_SweepTotalPresent` |
| `XI_` protected (internal) | 1 | this module only | `XI_SweepRecomputeWindow` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 5 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `C_2|Inject`, `C_2|SweepRevokeAnchor`, `GOV|Demiurgoi` |

**Multi-transaction (`defpact`)** — `MTX|2|C_Inject`, `MTX|2|C_SweepRevokeAnchor`

> Repository and chain agree on every declared shape.

**Capabilities** -- 9

`GOV`, `GOV|MTX-AQP_ADMIN`, `MTX-AQP|C>INJECT`, `MTX-AQP|C>SWEEP-REVOKE`, `P|DT`, `P|MTX-AQP|CALLER`, `P|MTX-AQP|REMOTE-GOV`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 16, grouped by what the prefix promises

*Derived reads* (1) — read and compute; no enforce

`URC_SweepTotalPresent`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Client entry* (2) — builds the bill; reachable only through Talos

`C_2|Inject`, `C_2|SweepRevokeAnchor`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (1) — this module only; writes under a capability

`XI_SweepRecomputeWindow`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`
<!-- @end:module-page:MTX-AQP -->

## Traps

**One of these is vault-and-treasury only** and is described in its own source as a *spike fallback*, bounded by how many stale stakers it can fix.

**These and the swap equivalents are the only places virtual gas is collected outside Talos** — sixteen call sites in total. Intended, and it contradicts a sentence in this project's own documentation claiming Talos is the sole collector.

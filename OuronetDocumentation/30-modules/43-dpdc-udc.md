# DPDC-UDC — collectable schemas and constructors

## What it is for

The shared data shapes for the whole collectables family — fourteen schemas defining what a nonce, a set, an account holding and a metadata record are — and the constructors that build them.

Part of the **collectables family** — eleven modules serving BOTH semi-fungible and non-fungible assets through one boolean discriminator. There is no module named DPSF or DPNF anywhere; the two are mirrored table sets, not separate implementations. See `20-assets/03-semi-fungibles.md` and `04-non-fungibles.md`.

## Where it sits

The family's first module, holding the types everything above it uses.

## What it owns, and what it exposes

<!-- @generated:module-page:DPDC-UDC -->
**On chain**

| | |
|---|---|
| module hash | `Ka0Ycln3JwoNGVkbeOOpzN18yenzIyNGEz0dnWshCuo` |
| deployed size | 15,430 characters |
| implements | `OuronetPolicyV2`, `DpdcUdcV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/01_DPDC-UDC.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 5

`GOV`, `GOV|DPDC-UDC_ADMIN`, `P|DPDC-UDC|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 33, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `UDC_` constructors | 10 | named object constructors | `UDC_AccountRoles`, `UDC_MetaData`, `UDC_NoCompositeSet`, `UDC_NoMetaData`, `UDC_NoPrimordialSet`, `UDC_NonceData` …+4 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 14 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi`, `UDC_DPDC|AccountSupply`, `UDC_DPDC|AllowedClassForSetPosition`, `UDC_DPDC|AllowedNonceForSetPosition`, `UDC_DPDC|Properties` …+8 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `AccountRoles`, `DPDC|AccountSupply`, `DPDC|AllowedClassForSetPosition`, `DPDC|AllowedNonceForSetPosition`, `DPDC|NonceData`, `DPDC|NonceElement`, `DPDC|Properties`, `DPDC|Set`

**Capabilities** -- 5

`GOV`, `GOV|DPDC-UDC_ADMIN`, `P|DPDC-UDC|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 33, grouped by what the prefix promises

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Constructors* (22) — build objects

`UDC_AccountRoles`, `UDC_DPDC|AccountSupply`, `UDC_DPDC|AllowedClassForSetPosition`, `UDC_DPDC|AllowedNonceForSetPosition`, `UDC_DPDC|Properties`, `UDC_DPDC|Set`, `UDC_DPDC|VerumRoles`, `UDC_DPNF|AccountRoles`, `UDC_DPSF|AccountRoles`, `UDC_MetaData`, `UDC_NoCompositeSet`, `UDC_NoMetaData`, `UDC_NoPrimordialSet`, `UDC_NonceData`, `UDC_NonceElement`, `UDC_NonceMetaData`, `UDC_URI|Data`, `UDC_URI|Type`, `UDC_ZeroNonceData`, `UDC_ZeroNonceElement`, `UDC_ZeroURI|Data`, `UDC_ZeroURI|Type`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Bar`
<!-- @end:module-page:DPDC-UDC -->

## Traps

**One field reads nothing.** The royalty field carries an in-source note that it is a forward-looking hook for a marketplace that does not exist, with no on-chain consumer — unlike its sibling, which transfer pricing actively reads. Recording that in the schema is what stops the next reader assuming both are live.

**The sentinels for "no set definition" are `[0]` and `-1`**, and both became unreachable from user input as a side effect of tightening a bounds check elsewhere. Nobody targeted them.

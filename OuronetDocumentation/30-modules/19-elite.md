# ELITE — account tiers and discounts

## What it is for

The **elite tier** system: an account's standing, expressed as a major and minor level, which discounts everything it pays.

The maximum discount is **49%** on virtual gas and exactly half that on native charges — computed by one function with a boolean rather than two.

## Where it sits

A small Stage-1 core holding no domain tables of its own. It reads the account core and derives.

## What it owns, and what it exposes

<!-- @generated:module-page:ELITE -->
**On chain**

| | |
|---|---|
| module hash | `wKvH9cF7zORiYHJ_FGj5rK4bm_ovDQUv5b7bpo_b4wY` |
| deployed size | 12,832 characters |
| implements | `OuronetPolicyV2`, `EliteV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/07_ELITE.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 5

`GOV`, `GOV|ELITE_ADMIN`, `P|ELITE|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 16, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URC_` derived reads | 2 | read and derive; no enforce | `URC_EliteAurynzSupply`, `URC_IzIdEA` |
| `XE_` protected (external) | 2 | for other modules; opens with the IMC gate | `XE_UpdateElite`, `XE_UpdateEliteSingle` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 3 | carries no StoicSyntax prefix | `CT_Bar`, `CT_Namespace`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 5

`GOV`, `GOV|ELITE_ADMIN`, `P|ELITE|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 16, grouped by what the prefix promises

*Derived reads* (2) — read and compute; no enforce

`URC_EliteAurynzSupply`, `URC_IzIdEA`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (1) — read and enforce; failure aborts

`P|UEV_IMC`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (2) — callable by other modules only

`XE_UpdateElite`, `XE_UpdateEliteSingle`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (2) — no known prefix -- worth asking why

`CT_Bar`, `CT_Namespace`
<!-- @end:module-page:ELITE -->

## Traps

**A docstring here claims 49.5%; the code computes 49.** At the top tier the arithmetic is `7 × 6 + 7 = 49`. The pricing reference has it right and the docstring does not — a half-point discrepancy that has survived because nothing tests a docstring.

**The discount applies to the whole bill before it is split**, so two users see genuinely different prices for the same operation. An interface showing only one number invites a support question.

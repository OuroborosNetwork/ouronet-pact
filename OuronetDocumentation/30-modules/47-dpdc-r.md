# DPDC-R — collectable roles

## What it is for

Ten account-level roles — richer than either fungible type — plus the distinction between a collection's **owner** and its **creator**, so a collection can be administratively owned by one party and minted by another.

Part of the **collectables family** — eleven modules serving BOTH semi-fungible and non-fungible assets through one boolean discriminator. There is no module named DPSF or DPNF anywhere; the two are mirrored table sets, not separate implementations. See `20-assets/03-semi-fungibles.md` and `04-non-fungibles.md`.

## Where it sits

Above the state core.

## What it owns, and what it exposes

<!-- @generated:module-page:DPDC-R -->
**On chain**

| | |
|---|---|
| module hash | `U3KIFJDj3akYpm662y5JjozuBZvgFSnTeuOlCzTYBYQ` |
| deployed size | 39,844 characters |
| implements | `OuronetPolicyV2`, `DpdcRolesV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/05_DPDC-R.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 16

`DPDC|C>FRZ-ACC`, `DPDC|C>MV_CREATE-R`, `DPDC|C>MV_RECREATE-R`, `DPDC|C>MV_SET-URI-R`, `DPDC|C>TG_ADD-QTY-R`, `DPDC|C>TG_BURN-R`, `DPDC|C>TG_EXEMPTION-R`, `DPDC|C>TG_MODIFY-CREATOR-R`, `DPDC|C>TG_MODIFY-ROYALTIES-R`, `DPDC|C>TG_TRANSFER-R`, `DPDC|C>TG_UPDATE-R`, `GOV`, `GOV|DPDC-R_ADMIN`, `P|DPDC-R|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 45, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 11 | returns what an operation will charge | `URCi_MoveCreateRole`, `URCi_MoveRecreateRole`, `URCi_MoveSetUriRole`, `URCi_ToggleAddQuantityRole`, `URCi_ToggleBurnRole`, `URCi_ToggleExemptionRole` …+5 |
| `UEV_` validators | 1 | read and enforce; may abort the transaction | `UEV_ExecutorIsCollectionOwner` |
| `XI_` protected (internal) | 11 | this module only | `XI_MoveCreateRole`, `XI_MoveRecreateRole`, `XI_MoveSetUriRole`, `XI_ToggleAddQuantityRole`, `XI_ToggleBurnRole`, `XI_ToggleExemptionRole` …+5 |
| `C_` client | 11 | reached via Talos, never called directly | `C_MoveCreateRole`, `C_MoveRecreateRole`, `C_MoveSetUriRole`, `C_ToggleAddQuantityRole`, `C_ToggleBurnRole`, `C_ToggleExemptionRole` …+5 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 2 | carries no StoicSyntax prefix | `CT_Bar`, `GOV|Demiurgoi` |

> Repository and chain agree on every declared shape.

**Capabilities** -- 16

`DPDC|C>FRZ-ACC`, `DPDC|C>MV_CREATE-R`, `DPDC|C>MV_RECREATE-R`, `DPDC|C>MV_SET-URI-R`, `DPDC|C>TG_ADD-QTY-R`, `DPDC|C>TG_BURN-R`, `DPDC|C>TG_EXEMPTION-R`, `DPDC|C>TG_MODIFY-CREATOR-R`, `DPDC|C>TG_MODIFY-ROYALTIES-R`, `DPDC|C>TG_TRANSFER-R`, `DPDC|C>TG_UPDATE-R`, `GOV`, `GOV|DPDC-R_ADMIN`, `P|DPDC-R|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 45, grouped by what the prefix promises

*Cost readers* (11) — price an operation; the exec path and the preview both call these

`URCi_MoveCreateRole`, `URCi_MoveRecreateRole`, `URCi_MoveSetUriRole`, `URCi_ToggleAddQuantityRole`, `URCi_ToggleBurnRole`, `URCi_ToggleExemptionRole`, `URCi_ToggleFreezeAccount`, `URCi_ToggleModifyCreatorRole`, `URCi_ToggleModifyRoyaltiesRole`, `URCi_ToggleTransferRole`, `URCi_ToggleUpdateRole`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (2) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_ExecutorIsCollectionOwner`

*Client entry* (11) — builds the bill; reachable only through Talos

`C_MoveCreateRole`, `C_MoveRecreateRole`, `C_MoveSetUriRole`, `C_ToggleAddQuantityRole`, `C_ToggleBurnRole`, `C_ToggleExemptionRole`, `C_ToggleFreezeAccount`, `C_ToggleModifyCreatorRole`, `C_ToggleModifyRoyaltiesRole`, `C_ToggleTransferRole`, `C_ToggleUpdateRole`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (11) — this module only; writes under a capability

`XI_MoveCreateRole`, `XI_MoveRecreateRole`, `XI_MoveSetUriRole`, `XI_ToggleAddQuantityRole`, `XI_ToggleBurnRole`, `XI_ToggleExemptionRole`, `XI_ToggleFreezeAccount`, `XI_ToggleModifyCreatorRole`, `XI_ToggleModifyRoyaltiesRole`, `XI_ToggleTransferRole`, `XI_ToggleUpdateRole`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (1) — keysets and protocol constants

`GOV|Demiurgoi`

*Unclassified* (1) — no known prefix -- worth asking why

`CT_Bar`
<!-- @end:module-page:DPDC-R -->

## Traps

**One role is semi-fungible-only.** Non-fungibles cannot carry an add-quantity role because their quantity is fixed at one — so the operation toggling it is the only one in this module that does not take the type discriminator. It hardcodes the semi-fungible path because there is no other.

**A frozen account could once be bricked permanently** when the unfreeze and upgrade flags were both off, leaving no release valve.

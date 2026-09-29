# VST — vesting, locking and the special variants

## What it is for

Every transition into and out of a locked state: **vested**, **sleeping**, **hibernating**, **frozen**, **reserved** — plus the two autostake entries that produce hibernated receipts.

The single fact that makes it comprehensible: a special variant is **not a flag on a balance**. The original goes into escrow and a prefixed wrapper token is minted to you. "My tokens are vested" means you hold `V|`-prefixed parcels.

Full treatment: `20-assets/06-the-special-variants.md`.

## Where it sits

A Stage-1 core above the token modules. It owns the transitions; the link fields live on the tokens themselves.

## What it owns, and what it exposes

<!-- @generated:module-page:VST -->
**On chain**

| | |
|---|---|
| module hash | `gxaPbZBT7U-dYYdnrmA-2fH7V-CCtiuC8bxvPDsGQEs` |
| deployed size | 117,864 characters |
| implements | `OuronetPolicyV2`, `VestingV2` |
| repository source | `1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact` |

**Tables it owns** — 2

`P|MT`, `P|T`

**Capabilities** — 42

`ATSU|C>BRUMATE`, `ATSU|C>CONSTRICT`, `GOV`, `GOV|VESTING_ADMIN`, `P|TT`, `P|VST|CALLER`, `P|VST|REMOTE-GOV`, `SECURE`, `VST|C>AWAKE`, `VST|C>CULL`, `VST|C>FREEZE`, `VST|C>FROZEN-LINK`, `VST|C>HIBERNATE`, `VST|C>LINK`, `VST|C>MERGE`, `VST|C>REPURPOSE-FROZEN-TF`, `VST|C>REPURPOSE-HIBERNATING-MF`, `VST|C>REPURPOSE-MERGE`, `VST|C>REPURPOSE-ORTO-FUNGIBLE`, `VST|C>REPURPOSE-RESERVED-TF`, `VST|C>REPURPOSE-SLEEPING-MF`, `VST|C>REPURPOSE-SLUMBER`, `VST|C>REPURPOSE-TRUE-FUNGIBLE`, `VST|C>REPURPOSE-VESTING-MF`, `VST|C>RESERVATION-LINK`, `VST|C>RESERVE`, `VST|C>SLEEP`, `VST|C>SLEEPING-LINK`, `VST|C>SLUMBER`, `VST|C>TOGGLE-FROZEN-TF-TR`, `VST|C>TOGGLE-HIBERNATING-OF-TR`, `VST|C>TOGGLE-RESERVED-TF-TR`, `VST|C>TOGGLE-SLEEPING-OF-TR`, `VST|C>UNRESERVE`, `VST|C>UNSLEEP`, `VST|C>VEST`, `VST|C>VESTING-LINK`, `VST|GOV`, `VST|X>MERGE`, `VST|X>REPURPOSE-ORTO-FUNGIBLE`, `VST|X>TOGGLE-SPECIAL-OF-TR`, `VST|X>TOGGLE-SPECIAL-TF-TR`

**Functions** — 81, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 26 | returns what an operation will charge | `URCi_Awake`, `URCi_Brumate`, `URCi_Constrict`, `URCi_CreateSpecialOrtoFungibleLink`, `URCi_CreateSpecialOrtoFungibleLinkDeterrence`, `URCi_CreateSpecialOrtoFungibleLinkStoa` …+20 |
| `URC_` derived reads | 3 | read and derive; no enforce | `URC_CullMetaDataAmountWithObject`, `URC_SecondsToUnlock`, `URC_SpecialTransferRoleKonto` |
| `UEV_` validators | 2 | read and enforce; may abort the transaction | `UEV_NoncesForMerging`, `UEV_StillHasSleeping` |
| `UDC_` constructors | 1 | named object constructors | `UDC_ComposeVestingMetaData` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_MergeAll` |
| `XI_` protected (internal) | 4 | this module only | `XI_CreateSpecialOrtoFungibleLink`, `XI_CreateSpecialTrueFungibleLink`, `XI_RepurposeOrtoFungible`, `XI_RepurposeTrueFungible` |
| `C_` client | 29 | reached via Talos, never called directly | `C_Awake`, `C_Brumate`, `C_Constrict`, `C_CreateFrozenLink`, `C_CreateHibernatingLink`, `C_CreateReservationLink` …+23 |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 6 | carries no StoicSyntax prefix | `CT_Bar`, `CT_EmptyCumulator`, `GOV|Demiurgoi`, `GOV|VST|SC_NAME`, `GOV|VestingKey`, `XIv_MergeNonces` |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **schemas** in the repository only: `VST|HibernatingSchema`, `VST|MetaDataSchema`

**Capabilities** -- 42

`ATSU|C>BRUMATE`, `ATSU|C>CONSTRICT`, `GOV`, `GOV|VESTING_ADMIN`, `P|TT`, `P|VST|CALLER`, `P|VST|REMOTE-GOV`, `SECURE`, `VST|C>AWAKE`, `VST|C>CULL`, `VST|C>FREEZE`, `VST|C>FROZEN-LINK`, `VST|C>HIBERNATE`, `VST|C>LINK`, `VST|C>MERGE`, `VST|C>REPURPOSE-FROZEN-TF`, `VST|C>REPURPOSE-HIBERNATING-MF`, `VST|C>REPURPOSE-MERGE`, `VST|C>REPURPOSE-ORTO-FUNGIBLE`, `VST|C>REPURPOSE-RESERVED-TF`, `VST|C>REPURPOSE-SLEEPING-MF`, `VST|C>REPURPOSE-SLUMBER`, `VST|C>REPURPOSE-TRUE-FUNGIBLE`, `VST|C>REPURPOSE-VESTING-MF`, `VST|C>RESERVATION-LINK`, `VST|C>RESERVE`, `VST|C>SLEEP`, `VST|C>SLEEPING-LINK`, `VST|C>SLUMBER`, `VST|C>TOGGLE-FROZEN-TF-TR`, `VST|C>TOGGLE-HIBERNATING-OF-TR`, `VST|C>TOGGLE-RESERVED-TF-TR`, `VST|C>TOGGLE-SLEEPING-OF-TR`, `VST|C>UNRESERVE`, `VST|C>UNSLEEP`, `VST|C>VEST`, `VST|C>VESTING-LINK`, `VST|GOV`, `VST|X>MERGE`, `VST|X>REPURPOSE-ORTO-FUNGIBLE`, `VST|X>TOGGLE-SPECIAL-OF-TR`, `VST|X>TOGGLE-SPECIAL-TF-TR`

**Functions** -- 81, grouped by what the prefix promises

*Cost readers* (26) — price an operation; the exec path and the preview both call these

`URCi_Awake`, `URCi_Brumate`, `URCi_Constrict`, `URCi_CreateSpecialOrtoFungibleLink`, `URCi_CreateSpecialOrtoFungibleLinkDeterrence`, `URCi_CreateSpecialOrtoFungibleLinkStoa`, `URCi_CreateSpecialOrtoFungibleLinkToggle`, `URCi_CreateSpecialTrueFungibleLink`, `URCi_CreateSpecialTrueFungibleLinkDeterrence`, `URCi_CreateSpecialTrueFungibleLinkStoa`, `URCi_CreateSpecialTrueFungibleLinkToggle`, `URCi_Freeze`, `URCi_Hibernate`, `URCi_MergeNonces`, `URCi_RepurposeOrtoFungible`, `URCi_RepurposeTrueFungible`, `URCi_Reserve`, `URCi_Sleep`, `URCi_ToggleTransferRoleFrozenDPTF`, `URCi_ToggleTransferRoleHibernatingDPOF`, `URCi_ToggleTransferRoleReservedDPTF`, `URCi_ToggleTransferRoleSleepingDPOF`, `URCi_Unreserve`, `URCi_Unsleep`, `URCi_Unvest`, `URCi_Vest`

*Derived reads* (3) — read and compute; no enforce

`URC_CullMetaDataAmountWithObject`, `URC_SecondsToUnlock`, `URC_SpecialTransferRoleKonto`

*Point reads* (1) — one row or field by key

`P|UR_IMP`

*Validators* (3) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_NoncesForMerging`, `UEV_StillHasSleeping`

*Constructors* (1) — build objects

`UDC_ComposeVestingMetaData`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_MergeAll`

*Client entry* (29) — builds the bill; reachable only through Talos

`C_Awake`, `C_Brumate`, `C_Constrict`, `C_CreateFrozenLink`, `C_CreateHibernatingLink`, `C_CreateReservationLink`, `C_CreateSleepingLink`, `C_CreateVestingLink`, `C_Freeze`, `C_Hibernate`, `C_Merge`, `C_RepurposeFrozen`, `C_RepurposeHibernating`, `C_RepurposeMerge`, `C_RepurposeReserved`, `C_RepurposeSleeping`, `C_RepurposeSlumber`, `C_RepurposeVested`, `C_Reserve`, `C_Sleep`, `C_Slumber`, `C_ToggleTransferRoleFrozenDPTF`, `C_ToggleTransferRoleHibernatingDPOF`, `C_ToggleTransferRoleReservedDPTF`, `C_ToggleTransferRoleSleepingDPOF`, `C_Unreserve`, `C_Unsleep`, `C_Unvest`, `C_Vest`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*Internal writes* (4) — this module only; writes under a capability

`XI_CreateSpecialOrtoFungibleLink`, `XI_CreateSpecialTrueFungibleLink`, `XI_RepurposeOrtoFungible`, `XI_RepurposeTrueFungible`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (3) — keysets and protocol constants

`GOV|Demiurgoi`, `GOV|VST|SC_NAME`, `GOV|VestingKey`

*Unclassified* (3) — no known prefix -- worth asking why

`CT_Bar`, `CT_EmptyCumulator`, `XIv_MergeNonces`
<!-- @end:module-page:VST -->

## Traps

**Only the token's owner can create a link, and a link is permanent.** A holder cannot vest a token whose owner never enabled vesting.

**Hibernating is the only freely transferable variant.** The other four are transfer-restricted — deliberate, because hibernation is a bond with a decaying exit penalty and a bond needs a secondary market. A tradeable lock is not a lock.

**The 80% exit penalty is burned, not collected.** Nobody earns it. A penalty paid *to* someone creates an incentive to design for early exits.

**Metadata shape was once chosen by an argument rather than by the token.** Pointing the hibernation merge at a sleeping token stamped the wrong shape on it, and the unsleep operation then died on a runtime type check *before any guard could run* — leaving the parcel permanently un-unsleepable while still in circulation. Prefix checks were added to both merges, and deliberately **not** to the two repurpose paths, because those are the only remaining exit for parcels the bug already mis-minted.

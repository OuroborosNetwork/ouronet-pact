# DPDC — the collectables state core

## What it is for

The central state: what collections exist, their flags, their nonces, their per-account holdings, and the ten mirrored tables that hold all of it.

Part of the **collectables family** — eleven modules serving BOTH semi-fungible and non-fungible assets through one boolean discriminator. There is no module named DPSF or DPNF anywhere; the two are mirrored table sets, not separate implementations. See `20-assets/03-semi-fungibles.md` and `04-non-fungibles.md`.

## Where it sits

The family's state module. Everything else reads it.

## What it owns, and what it exposes

<!-- @generated:module-page:DPDC -->
**On chain**

| | |
|---|---|
| module hash | `XnlPyILDe7wvmX6sfo4XxQyGwhQWjfuQF1ERIoNzL0s` |
| deployed size | 70,519 characters |
| implements | `OuronetPolicyV2`, `BrandingUsageTertiaryV2`, `DpdcV2` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact` |

**Tables it owns** — 12

`DPNF|T|Account`, `DPNF|T|AccountSupplies`, `DPNF|T|Nonces`, `DPNF|T|Properties`, `DPNF|T|VerumRoles`, `DPSF|T|Account`, `DPSF|T|AccountSupplies`, `DPSF|T|Nonces`, `DPSF|T|Properties`, `DPSF|T|VerumRoles`, `P|MT`, `P|T`

**Capabilities** — 9

`AHU`, `DPDC|C>UPDATE-BRD`, `DPDC|C>UPGRADE-BRD`, `DPDC|GOV`, `GOV`, `GOV|DPDC_ADMIN`, `P|DPDC|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 171, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 2 | returns what an operation will charge | `URCi_UpdatePendingBranding`, `URCi_UpgradeBranding` |
| `URH_` heavy reads | 6 | a scan -- expensive by construction | `URH_AS-Keys`, `URH_AccountNonces`, `URH_AccountNoncesWithSupplies`, `URH_ExistingCollectables`, `URH_HeldCollectables`, `URH_OwnedCollectables` |
| `UEV_` validators | 32 | read and enforce; may abort the transaction | `UEV_AccountAddQuantityState`, `UEV_AccountBurnState`, `UEV_AccountCreateState`, `UEV_AccountExemptionState`, `UEV_AccountFreezeState`, `UEV_AccountModifyCreatorState` …+26 |
| `UDC_` constructors | 1 | named object constructors | `UDC_Control` |
| `UC_` pure compute | 1 | arguments only -- no reads, no enforce | `UC_ParseSignedInteger` |
| `UR_` readers | 40 | table reads; no enforce, no writes | `UR_AccountNonceSupply`, `UR_AccountNoncesSupplies`, `UR_AccountSupply`, `UR_CanAddSpecialRole`, `UR_CanChangeCreator`, `UR_CanChangeOwner` …+34 |
| `CAP_` ownership gates | 3 | account-ownership enforcement | `CAP_Creator`, `CAP_Owner`, `CAP_OwnerOrCreator` |
| `XE_` protected (external) | 1 | for other modules; opens with the IMC gate | `XE_DeployAccountWNE` |
| `C_` client | 2 | reached via Talos, never called directly | `C_UpdatePendingBranding`, `C_UpgradeBranding` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 74 | carries no StoicSyntax prefix | `AU_Account`, `AU_Accounts`, `AU_NFTs`, `AU_Properties`, `AU_Property`, `AU_SFTs` …+68 |

> Repository and chain agree on every declared shape.

**Capabilities** -- 9

`AHU`, `DPDC|C>UPDATE-BRD`, `DPDC|C>UPGRADE-BRD`, `DPDC|GOV`, `GOV`, `GOV|DPDC_ADMIN`, `P|DPDC|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 171, grouped by what the prefix promises

*Cost readers* (2) — price an operation; the exec path and the preview both call these

`URCi_UpdatePendingBranding`, `URCi_UpgradeBranding`

*Heavy reads* (6) — scan a table -- OFF the execution path, cost grows with data

`URH_AS-Keys`, `URH_AccountNonces`, `URH_AccountNoncesWithSupplies`, `URH_ExistingCollectables`, `URH_HeldCollectables`, `URH_OwnedCollectables`

*Point reads* (65) — one row or field by key

`P|UR_IMP`, `UR_AccountNonceSupply`, `UR_AccountNoncesSupplies`, `UR_AccountSupply`, `UR_CA|R`, `UR_CA|R-AddQuantity`, `UR_CA|R-Burn`, `UR_CA|R-Create`, `UR_CA|R-Exemption`, `UR_CA|R-Frozen`, `UR_CA|R-ModifyCreator`, `UR_CA|R-ModifyRoyalties`, `UR_CA|R-Recreate`, `UR_CA|R-SetUri`, `UR_CA|R-Transfer`, `UR_CA|R-Update`, `UR_CanAddSpecialRole`, `UR_CanChangeCreator`, `UR_CanChangeOwner`, `UR_CanFreeze`, `UR_CanPause`, `UR_CanTransferNftCreateRole`, `UR_CanUpgrade`, `UR_CanWipe`, `UR_CreatorKonto`, `UR_IsPaused`, `UR_IzAccount`, `UR_Name`, `UR_NativeNonceData`, `UR_NonceClass`, `UR_NonceData`, `UR_NonceElement`, `UR_NonceHolder`, `UR_NonceSupply`, `UR_NonceValue`, `UR_NoncesUsed`, `UR_N|AssetType`, `UR_N|Composition`, `UR_N|Description`, `UR_N|IgnisRoyalty`, `UR_N|MetaData`, `UR_N|Name`, `UR_N|Primary`, `UR_N|RawMetaData`, `UR_N|RawScore`, `UR_N|Royalty`, `UR_N|Secondary`, `UR_N|Tertiary`, `UR_OwnerKonto`, `UR_Properties`, `UR_SetClassesUsed`, `UR_SplitNonceData`, `UR_Ticker`, `UR_Verum1`, `UR_Verum10`, `UR_Verum11`, `UR_Verum2`, `UR_Verum3`, `UR_Verum4`, `UR_Verum5`, `UR_Verum6`, `UR_Verum7`, `UR_Verum8`, `UR_Verum9`, `UR_VerumRoles`

*Validators* (33) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AccountAddQuantityState`, `UEV_AccountBurnState`, `UEV_AccountCreateState`, `UEV_AccountExemptionState`, `UEV_AccountFreezeState`, `UEV_AccountModifyCreatorState`, `UEV_AccountModifyRoyaltiesState`, `UEV_AccountRecreateState`, `UEV_AccountSetUriState`, `UEV_AccountTransferState`, `UEV_AccountUpdateState`, `UEV_AssetType`, `UEV_CanAddSpecialRoleON`, `UEV_CanFreezeON`, `UEV_CanPauseON`, `UEV_CanUpgradeON`, `UEV_CanWipeON`, `UEV_Description`, `UEV_ExecutorIsOwnerKonto`, `UEV_IgnisRoyalty`, `UEV_MetaDataBag`, `UEV_Name`, `UEV_NftNonceExistance`, `UEV_Nonce`, `UEV_NonceMapper`, `UEV_NonceQuantityInclusion`, `UEV_NonceQuantityInclusionMapper`, `UEV_PauseState`, `UEV_Royalty`, `UEV_ToggleSpecialRole`, `UEV_UriData`, `UEV_id`

*Constructors* (1) — build objects

`UDC_Control`

*Pure compute* (1) — arguments only; no reads, no enforce

`UC_ParseSignedInteger`

*Ownership checks* (3) — account-ownership enforcement

`CAP_Creator`, `CAP_Owner`, `CAP_OwnerOrCreator`

*Client entry* (2) — builds the bill; reachable only through Talos

`C_UpdatePendingBranding`, `C_UpgradeBranding`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (24) — callable by other modules only

`XE_DeployAccountWNE`, `XE_I|Collection`, `XE_I|CollectionElement`, `XE_I|VerumRoles`, `XE_U|Burn`, `XE_U|Create`, `XE_U|Exemption`, `XE_U|Frozen`, `XE_U|IsPaused`, `XE_U|ModifyCreator`, `XE_U|ModifyRoyalties`, `XE_U|NonceHolder`, `XE_U|NonceOrSplitData`, `XE_U|NonceSupply`, `XE_U|NoncesUsed`, `XE_U|Recreate`, `XE_U|Rnaq`, `XE_U|SetClassesUsed`, `XE_U|SetNewUri`, `XE_U|Specs`, `XE_U|Transfer`, `XE_U|Update`, `XE_U|VerumRoles`, `XE_W|Supply`

*Internal writes* (12) — this module only; writes under a capability

`XI_U|AccountRoles`, `XI_U|VerumRole1`, `XI_U|VerumRole10`, `XI_U|VerumRole11`, `XI_U|VerumRole2`, `XI_U|VerumRole3`, `XI_U|VerumRole4`, `XI_U|VerumRole5`, `XI_U|VerumRole6`, `XI_U|VerumRole7`, `XI_U|VerumRole8`, `XI_U|VerumRole9`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (4) — keysets and protocol constants

`GOV|CollectiblesKey`, `GOV|DPDC|PBL`, `GOV|DPDC|SC_NAME`, `GOV|Demiurgoi`

*Unclassified* (11) — no known prefix -- worth asking why

`AU_Account`, `AU_Accounts`, `AU_NFTs`, `AU_Properties`, `AU_Property`, `AU_SFTs`, `CT_Bar`, `CT_Namespace`, `URv_GetVerumChain`, `XBv_DeployAccountNFT`, `XBv_DeployAccountSFT`
<!-- @end:module-page:DPDC -->

## Traps

**The discriminator is part of the key, not decoration.** The two asset types are separate tables and the same identifier can exist in both, so a lookup without it does not degrade — it answers about a different token.

**A non-fungible's stored holder is an 11-character abbreviation** — five leading characters, an ellipsis, three trailing — so it distinguishes 162-character accounts by six body characters out of 160. Any two accounts sharing those collide. Found by red-teaming; the fix is a **second check against the full-key table**, with deliberately different messages so which one fired is visible.

The general lesson: *a truncated identifier is a display convenience, and the moment it decides something it is a collision.*

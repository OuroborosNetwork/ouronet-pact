# AQP-ANK — anchors

## What it is for

Rules that convert holding **one** asset into a per-mille boost on a score for a **different** one.

For fungibles the boost is pro-rated rather than a threshold: hold two and a half times the anchor amount, get two and a half times the boost. For collectables it counts whole units matching a nonce, a trait or a set class.

Part of the **acquisition-pool family** — ten modules, the largest subsystem in the system. Full treatment: `25-defi/03-acquisition-pools.md`.

## Where it sits

Below the scoring module, which reads a single aggregated value from it.

## What it owns, and what it exposes

<!-- @generated:module-page:AQP-ANK -->
**On chain**

| | |
|---|---|
| module hash | `9eFnctlln356ylLHbnCCkGiHb-qNcygdAy3-eNkqn00` |
| deployed size | 121,847 characters |
| implements | `OuronetPolicyV2`, `AcquisitionAnchorsV1` |
| repository source | `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact` |

**Tables it owns** — 8

`ANK|T|Anchor`, `ANK|T|Anchors`, `ANK|T|AssetAnchors`, `ANK|T|BoostClass`, `ANK|T|BoostClassScoreLinks`, `ANK|T|UserBoost`, `P|MT`, `P|T`

**Capabilities** — 21

`ANK|C>BUMP-BOOST-CLASS-LINKS`, `ANK|C>ISSUE-DPNF`, `ANK|C>ISSUE-DPNF-SET`, `ANK|C>ISSUE-DPSF`, `ANK|C>ISSUE-DPTF`, `ANK|C>REVOKE`, `ANK|C>REVOKE-BOOST-CLASS`, `ANK|C>REVOKE-BOOST-CLASS-ENTRY`, `ANK|C>UPDATE-DPDC`, `ANK|C>UPDATE-DPNF`, `ANK|C>UPDATE-DPSF`, `ANK|C>UPDATE-DPTF`, `ANK|XE>SWEEP`, `ANK|XE>SWEEP-REVOKE`, `ANK|XI>ISSUE-DPNF-COMMON`, `AQP|GOV`, `GOV`, `GOV|ANK_ADMIN`, `P|ANK|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** — 124, grouped by what their prefix promises

| family | n | the promise | names |
|---|---:|---|---|
| `URCi_` cost readers | 4 | returns what an operation will charge | `URCi_IssueAnchor`, `URCi_IssueAnchorStoa`, `URCi_RevokeAnchor`, `URCi_RevokeBoostClass` |
| `URCv_` derived reads (validating) | 1 | read + derive, with an intrinsic guard | `URCv_CoreDptf` |
| `URC_` derived reads | 10 | read and derive; no enforce | `URC_AnchorableAssetOwner`, `URC_ConformNonces`, `URC_ConformNoncesByClass`, `URC_NonFungibleAnchorPromile`, `URC_NonFungibleAnchorPromileAbsolute`, `URC_SemiFungibleAnchorPromile` …+4 |
| `UEV_` validators | 8 | read and enforce; may abort the transaction | `UEV_AnkFungibility`, `UEV_AssetAnchorCap`, `UEV_ExecutorIzAnchorAuthority`, `UEV_ExecutorIzAssetAuthority`, `UEV_ExecutorIzClassOwner`, `UEV_IssueAnchor` …+2 |
| `UDC_` constructors | 4 | named object constructors | `UDC_AccountAnchor`, `UDC_BoostClass`, `UDC_EmptyInternalGroup`, `UDC_UserBoost` |
| `UCk_` pure compute (key) | 2 | builds a composite table key | `UCk_Anchors`, `UCk_UserBoost` |
| `CAP_` ownership gates | 1 | account-ownership enforcement | `CAP_Owner` |
| `WI_` writers (insert) | 2 | one write site each | `WI_Anchor`, `WI_BoostClass` |
| `WW_` writers (upsert) | 4 | one write site each | `WW_Anchors`, `WW_AssetAnchors`, `WW_BoostClass`, `WW_UserBoost` |
| `XI_` protected (internal) | 4 | this module only | `XI_IssueAnchor`, `XI_IssueBoostClass`, `XI_PlaceAnchorInBookkeeping`, `XI_RevokeAnchorBookkeeping` |
| `XE_` protected (external) | 9 | for other modules; opens with the IMC gate | `XE_BumpBoostClassScoreLinks`, `XE_RecomputeUserBoostAggregates`, `XE_ResyncNonFungibleUserAnchorValues`, `XE_ResyncSemiFungibleUserAnchorValues`, `XE_SweepRevokeAnchor`, `XE_UnbumpBoostClassScoreLinks` …+3 |
| `C_` client | 6 | reached via Talos, never called directly | `C_IssueNonFungibleAnchor`, `C_IssueNonFungibleSetAnchor`, `C_IssueSemiFungibleAnchor`, `C_IssueTrueFungibleAnchor`, `C_RevokeAnchor`, `C_RevokeBoostClass` |
| `P|` policy | 9 | inter-module authorisation | `P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`, `P|Info` …+3 |
| *(unclassified)* | 60 | carries no StoicSyntax prefix | `CAP_TF|Owner`, `CT_Bar`, `CT_Namespace`, `GOV|AQP|PBL`, `GOV|AQP|SC_NAME`, `GOV|AqpKey` …+54 |

> **The repository differs from what is deployed.** Everything above describes the CHAIN, which is what a caller actually reaches. The difference is stated rather than resolved:
>
> - **functions** in the repository only: `UEV_ExecutorNotCustodial`, `URCv_AnchorableDptfAuthority`

**Capabilities** -- 21

`ANK|C>BUMP-BOOST-CLASS-LINKS`, `ANK|C>ISSUE-DPNF`, `ANK|C>ISSUE-DPNF-SET`, `ANK|C>ISSUE-DPSF`, `ANK|C>ISSUE-DPTF`, `ANK|C>REVOKE`, `ANK|C>REVOKE-BOOST-CLASS`, `ANK|C>REVOKE-BOOST-CLASS-ENTRY`, `ANK|C>UPDATE-DPDC`, `ANK|C>UPDATE-DPNF`, `ANK|C>UPDATE-DPSF`, `ANK|C>UPDATE-DPTF`, `ANK|XE>SWEEP`, `ANK|XE>SWEEP-REVOKE`, `ANK|XI>ISSUE-DPNF-COMMON`, `AQP|GOV`, `GOV`, `GOV|ANK_ADMIN`, `P|ANK|CALLER`, `P|SECURE-CALLER`, `SECURE`

**Functions** -- 124, grouped by what the prefix promises

*Cost readers* (4) — price an operation; the exec path and the preview both call these

`URCi_IssueAnchor`, `URCi_IssueAnchorStoa`, `URCi_RevokeAnchor`, `URCi_RevokeBoostClass`

*Heavy reads* (2) — scan a table -- OFF the execution path, cost grows with data

`URH_ANK|AllAnchorIds`, `URH_BC|AllBoostClassIds`

*Derived reads* (15) — read and compute; no enforce

`URC_AA|GroupAtSlot`, `URC_AA|SetGroupAtSlot`, `URC_AnchorableAssetOwner`, `URC_BC|AnchorIdAtSlot`, `URC_ConformNonces`, `URC_ConformNoncesByClass`, `URC_IG|AnchorIdAtSlot`, `URC_IG|ContainsAnchor`, `URC_NonFungibleAnchorPromile`, `URC_NonFungibleAnchorPromileAbsolute`, `URC_SemiFungibleAnchorPromile`, `URC_SemiFungibleAnchorPromileAbsolute`, `URC_TraitOrClass`, `URC_TrueFungibleAnchorPromile`, `URC_TrueFungibleStakeAnchorRefreshIgnis`

*Point reads* (30) — one row or field by key

`P|UR_IMP`, `UR_AA|AnchorsActive`, `UR_AA|Data`, `UR_AA|GroupsActive`, `UR_ANK-U|Account`, `UR_ANK-U|Data`, `UR_ANK-U|ID`, `UR_ANK-U|Promile`, `UR_ANK|AnchoredAsset`, `UR_ANK|AnchorsForAsset`, `UR_ANK|BoostClassId`, `UR_ANK|Data`, `UR_ANK|Fungibility`, `UR_ANK|ID`, `UR_ANK|NFNonceClass`, `UR_ANK|NFTraitKey`, `UR_ANK|NFTraitValue`, `UR_ANK|Precision`, `UR_ANK|Promile`, `UR_ANK|SFNonce`, `UR_ANK|State`, `UR_ANK|TFAmount`, `UR_BC|Active`, `UR_BC|Anchors`, `UR_BC|Data`, `UR_BC|ID`, `UR_BC|ScoreLinkCount`, `UR_BC|ScoreLinks`, `UR_UB|AggregatePromile`, `UR_UB|Data`

*Validators* (9) — read and enforce; failure aborts

`P|UEV_IMC`, `UEV_AnkFungibility`, `UEV_AssetAnchorCap`, `UEV_ExecutorIzAnchorAuthority`, `UEV_ExecutorIzAssetAuthority`, `UEV_ExecutorIzClassOwner`, `UEV_IssueAnchor`, `UEV_LiveAnchor`, `UEV_Promile`

*Constructors* (11) — build objects

`UDC_AA|PlaceAnchor`, `UDC_AA|RemoveAnchor`, `UDC_ANK|Schema`, `UDC_AccountAnchor`, `UDC_BC|WithAddedAnchor`, `UDC_BC|WithRemovedAnchor`, `UDC_BoostClass`, `UDC_EmptyInternalGroup`, `UDC_IG|WithAddedAnchor`, `UDC_IG|WithRemovedAnchor`, `UDC_UserBoost`

*Ownership checks* (2) — account-ownership enforcement

`CAP_Owner`, `CAP_TF|Owner`

*Client entry* (6) — builds the bill; reachable only through Talos

`C_IssueNonFungibleAnchor`, `C_IssueNonFungibleSetAnchor`, `C_IssueSemiFungibleAnchor`, `C_IssueTrueFungibleAnchor`, `C_RevokeAnchor`, `C_RevokeBoostClass`

*Admin* (5) — admin-key mutations

`P|A_Add`, `P|A_AddIMP`, `P|A_Define`, `P|A_RemoveIMP`, `P|A_SetIMP`

*External entry* (9) — callable by other modules only

`XE_BumpBoostClassScoreLinks`, `XE_RecomputeUserBoostAggregates`, `XE_ResyncNonFungibleUserAnchorValues`, `XE_ResyncSemiFungibleUserAnchorValues`, `XE_SweepRevokeAnchor`, `XE_UnbumpBoostClassScoreLinks`, `XE_UpdateNonFungibleUserAnchorValues`, `XE_UpdateSemiFungibleUserAnchorValues`, `XE_UpdateTrueFungibleUserAnchorValues`

*Internal writes* (10) — this module only; writes under a capability

`XI_1|ResyncNonFungibleUserAnchorValues`, `XI_1|ResyncSemiFungibleUserAnchorValues`, `XI_1|UpdateNonFungibleUserAnchorValues`, `XI_1|UpdateSemiFungibleUserAnchorValues`, `XI_1|UpdateTrueFungibleUserAnchorValues`, `XI_2|RecomputeAffectedBoostAggregates`, `XI_IssueAnchor`, `XI_IssueBoostClass`, `XI_PlaceAnchorInBookkeeping`, `XI_RevokeAnchorBookkeeping`

*Policy* (2) — inter-module authorisation

`P|Info`, `P|UR`

*Governance* (4) — keysets and protocol constants

`GOV|AQP|PBL`, `GOV|AQP|SC_NAME`, `GOV|AqpKey`, `GOV|Demiurgoi`

*Unclassified* (15) — no known prefix -- worth asking why

`CT_Bar`, `CT_Namespace`, `UCk_Anchors`, `UCk_UserBoost`, `URCv_CoreDptf`, `WI_Anchor`, `WI_BoostClass`, `WU_Anchor|State`, `WU_BC|AddScoreLink`, `WU_BC|RemoveScoreLink`, `WU_BoostClass|Active`, `WW_Anchors`, `WW_AssetAnchors`, `WW_BoostClass`, `WW_UserBoost`
<!-- @end:module-page:AQP-ANK -->

## Traps

**Boost classes originally had no owner.** Anyone owning any anchorable asset could anchor it into someone else's class and hand their holders a boost inside that vault's scoring — *six free slots on a seven-slot class is six such grants.* An owner field was added.

**Two different sevens exist here and they are not related.** A boost class holds up to seven anchors; separately, each asset tracks seven groups of seven, giving 49. The first is a grouping, the second is bookkeeping that lets one read enumerate everything anchored to an asset.

**The result is uncapped; the definition is bounded.** Per-unit leverage is fixed at issue, but accumulated boost still grows by staking more.

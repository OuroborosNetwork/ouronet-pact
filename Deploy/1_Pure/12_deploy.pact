;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 12 of 24
;; This is STEP 12 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-11 must have run first, including the init steps between deploys.
;; 5 source file(s), 300,922 gas measured in the REPL gas model, 281,807 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/04_DPDC-I.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/05_DPDC-R.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/06_DPDC-MNG.pact
;;
;; TOTAL: 6 interface(s), 5 module(s), 20 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact
;;      interface  BrandingUsageTertiaryV2
;;      interface  DpdcV2
;;      module     DPDC
;;      table      P|T
;;      table      P|MT
;;      table      DPSF|T|Properties
;;      table      DPSF|T|Nonces
;;      table      DPSF|T|VerumRoles
;;      table      DPSF|T|Account
;;      table      DPSF|T|AccountSupplies
;;      table      DPNF|T|Properties
;;      table      DPNF|T|Nonces
;;      table      DPNF|T|VerumRoles
;;      table      DPNF|T|Account
;;      table      DPNF|T|AccountSupplies
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact
;;      interface  DpdcCreateV2
;;      module     DPDC-C
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/04_DPDC-I.pact
;;      interface  DpdcIssueV2
;;      module     DPDC-I
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/05_DPDC-R.pact
;;      interface  DpdcRolesV2
;;      module     DPDC-R
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/06_DPDC-MNG.pact
;;      interface  DpdcManagementV2
;;      module     DPDC-MNG
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/02_DPDC.pact ============
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface BrandingUsageTertiaryV2
    @doc "Exposes Branding Functions for Semi-Fungibles (S) and Non-Fungibles (N)"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string entity-id:string son:bool logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun C_UpgradeBranding (patron:string executor:string entity-id:string son:bool months:integer))

)

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcV2
    @doc "Exposes Collectables Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|DPDC|SC_NAME ())

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;; [UDC]
    ;;
    (defun UDC_Control:object{DpdcUdcV2.DPDC|Properties} (id:string son:bool cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UR]
    ;;
    ;;  [1]
    (defun UR_Properties:object{DpdcUdcV2.DPDC|Properties} (id:string son:bool))
    (defun UR_OwnerKonto:string (id:string son:bool))
    (defun UR_CreatorKonto:string (id:string son:bool))
    (defun UR_Name:string (id:string son:bool))
    (defun UR_Ticker:string (id:string son:bool))
    (defun UR_CanUpgrade:bool (id:string son:bool))
    (defun UR_CanChangeOwner:bool (id:string son:bool))
    (defun UR_CanChangeCreator:bool (id:string son:bool))
    (defun UR_CanAddSpecialRole:bool (id:string son:bool))
    (defun UR_CanTransferNftCreateRole:bool (id:string son:bool))
    (defun UR_CanFreeze:bool (id:string son:bool))
    (defun UR_CanWipe:bool (id:string son:bool))
    (defun UR_CanPause:bool (id:string son:bool))
    (defun UR_IsPaused:bool (id:string son:bool))
    (defun UR_NoncesUsed:integer (id:string son:bool))
    (defun UR_SetClassesUsed:integer (id:string son:bool))
    ;;  [2]
    (defun UR_NonceElement:object{DpdcUdcV2.DPDC|NonceElement} (id:string son:bool nonce:integer))
    (defun UR_NonceClass:integer (id:string son:bool nonce:integer))
    (defun UR_NonceValue:integer (id:string son:bool nonce:integer))
    (defun UR_NonceSupply:integer (id:string son:bool nonce:integer))
    (defun UR_NonceHolder:string (id:string son:bool nonce:integer))
    (defun UR_NativeNonceData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool nonce:integer))
    (defun UR_SplitNonceData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool nonce:integer))
    (defun UR_NonceData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool nonce:integer))
    ;;  [2.1]
    (defun UR_N|Royalty:decimal (n:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UR_N|IgnisRoyalty:decimal (n:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UR_N|Name:string (n:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UR_N|Description:string (n:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UR_N|MetaData:object{DpdcUdcV2.NonceMetaData} (n:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UR_N|AssetType:object{DpdcUdcV2.URI|Type} (n:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UR_N|Primary:object{DpdcUdcV2.URI|Data} (n:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UR_N|Secondary:object{DpdcUdcV2.URI|Data} (n:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UR_N|Tertiary:object{DpdcUdcV2.URI|Data} (n:object{DpdcUdcV2.DPDC|NonceData}))
    ;;  [2.1.1]
    (defun UR_N|RawScore:decimal (n:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UR_N|Composition:[integer] (n:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UR_N|RawMetaData:object (n:object{DpdcUdcV2.DPDC|NonceData}))
    ;;  [3]
    (defun UR_VerumRoles:object{DpdcUdcV2.DPDC|VerumRoles} (id:string son:bool))
    (defun UR_Verum1:[string] (id:string son:bool))
    (defun UR_Verum2:[string] (id:string son:bool))
    (defun UR_Verum3:[string] (id:string son:bool))
    (defun UR_Verum4:[string] (id:string son:bool))
    (defun UR_Verum5:string (id:string son:bool))
    (defun UR_Verum6:string (id:string son:bool))
    (defun UR_Verum7:[string] (id:string son:bool))
    (defun UR_Verum8:[string] (id:string son:bool))
    (defun UR_Verum9:[string] (id:string son:bool))
    (defun UR_Verum10:string (id:string son:bool))
    (defun UR_Verum11:[string] (id:string son:bool))
    (defun URv_GetVerumChain:[string] (id:string son:bool rp:integer))
    ;;  [4]
    (defun UR_IzAccount:bool (account:string id:string son:bool))
    (defun UR_CA|R:object{DpdcUdcV2.AccountRoles} (id:string son:bool account:string))
    (defun UR_CA|R-AddQuantity:bool (id:string account:string))
    (defun UR_CA|R-Frozen:bool (id:string son:bool account:string))
    (defun UR_CA|R-Exemption:bool (id:string son:bool account:string))
    (defun UR_CA|R-Burn:bool (id:string son:bool account:string))
    (defun UR_CA|R-Create:bool (id:string son:bool account:string))
    (defun UR_CA|R-Recreate:bool (id:string son:bool account:string))
    (defun UR_CA|R-Update:bool (id:string son:bool account:string))
    (defun UR_CA|R-ModifyCreator:bool (id:string son:bool account:string))
    (defun UR_CA|R-ModifyRoyalties:bool (id:string son:bool account:string))
    (defun UR_CA|R-SetUri:bool (id:string son:bool account:string))
    (defun UR_CA|R-Transfer:bool (id:string son:bool account:string))
    ;;  [5]
    (defun UR_AccountSupply:object{DpdcUdcV2.DPDC|AccountSupply} (account:string id:string son:bool nonce:integer))
    (defun UR_AccountNonceSupply:integer (account:string id:string son:bool nonce:integer))
    (defun UR_AccountNoncesSupplies:[integer] (account:string id:string son:bool nonces:[integer]))
    ;;
    (defun URH_HeldCollectables:[string] (account:string son:bool))
    (defun URH_ExistingCollectables:[string] (dpdc:string son:bool))
    (defun URH_OwnedCollectables:[string] (account:string son:bool))
    (defun URH_AccountNonces:[integer] (account:string id:string son:bool))
    (defun URH_AccountNoncesWithSupplies:[object] (account:string id:string son:bool))
    ;;
    ;;  [URCi]  Branding cost readers — single source for exec billing + INFO preview
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string son:bool))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_id (id:string son:bool))
    (defun UEV_NonceMapper (id:string son:bool nonces:[integer]))
    (defun UEV_Nonce (id:string son:bool nonce:integer))
        ;;
    (defun UEV_CanUpgradeON (id:string son:bool))
    (defun UEV_CanPauseON (id:string son:bool))
    (defun UEV_CanAddSpecialRoleON (id:string son:bool))
    (defun UEV_ToggleSpecialRole (id:string son:bool toggle:bool))
    (defun UEV_CanFreezeON (id:string son:bool))
    (defun UEV_CanWipeON (id:string son:bool))
    (defun UEV_PauseState (id:string son:bool state:bool))
    (defun UEV_AccountAddQuantityState (id:string account:string state:bool))
    (defun UEV_AccountFreezeState (id:string son:bool account:string state:bool))
    (defun UEV_AccountExemptionState (id:string son:bool account:string state:bool))
    (defun UEV_AccountBurnState (id:string son:bool account:string state:bool))
    (defun UEV_AccountUpdateState (id:string son:bool account:string state:bool))
    (defun UEV_AccountModifyCreatorState (id:string son:bool account:string state:bool))
    (defun UEV_AccountModifyRoyaltiesState (id:string son:bool account:string state:bool))
    (defun UEV_AccountTransferState (id:string son:bool account:string state:bool))
    (defun UEV_AccountCreateState (id:string son:bool account:string state:bool))
    (defun UEV_AccountRecreateState (id:string son:bool account:string state:bool))
    (defun UEV_AccountSetUriState (id:string son:bool account:string state:bool))
    (defun UEV_Royalty (royalty:decimal))
    (defun UEV_IgnisRoyalty (royalty:decimal))
    (defun UEV_Name (name:string))
    (defun UEV_Description (description:string))
    (defun UEV_MetaDataBag (meta-data:object))
    (defun UEV_AssetType (asset-type:object{DpdcUdcV2.URI|Type}))
    (defun UEV_UriData (u:object{DpdcUdcV2.URI|Data}))
    (defun UEV_NftNonceExistance (id:string nonce:integer existance:bool))
    (defun UEV_NonceQuantityInclusion (account:string id:string son:bool nonce:integer amount:integer))
    (defun UEV_NonceQuantityInclusionMapper (account:string id:string son:bool nonces:[integer] amounts:[integer]))
    ;;
    ;;  [CAP]
    ;;
    (defun UEV_ExecutorIsOwnerKonto (executor:string entity-id:string son:bool))
    (defun CAP_Owner (id:string son:bool))
    (defun CAP_Creator (id:string son:bool))
    (defun CAP_OwnerOrCreator (id:string son:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    ;; [<AccountsTable> Writings] [0]
    ;;
    (defun XBv_DeployAccountSFT
        (
            account:string id:string
            input-rnaq:bool f:bool re:bool rnb:bool rnc:bool rnr:bool
            rnu:bool rmc:bool rmr:bool rsnu:bool rt:bool
        )
    )
    (defun XBv_DeployAccountNFT 
        (
            account:string id:string
            f:bool re:bool rnb:bool rnc:bool rnr:bool
            rnu:bool rmc:bool rmr:bool rsnu:bool rt:bool
        )
    )
    (defun XE_DeployAccountWNE (account:string id:string son:bool))
    (defun XE_U|Rnaq (id:string account:string toggle))
    (defun XI_U|AccountRoles (id:string son:bool account:string new-roles:object{DpdcUdcV2.AccountRoles}))
    ;;
    ;; [<PropertiesTable> Writings] [1]
    ;;
    (defun XE_I|Collection (id:string son:bool idp:object{DpdcUdcV2.DPDC|Properties}))
    (defun XE_U|Specs (id:string son:bool specs:object{DpdcUdcV2.DPDC|Properties}))
    (defun XE_U|IsPaused (id:string son:bool toggle:bool))
    (defun XE_U|NoncesUsed (id:string son:bool new-nv:integer))
    (defun XE_U|SetClassesUsed (id:string son:bool new-nsc:integer))
    ;;
    ;; [<NoncesTable> Writings] [2]
    ;;
    (defun XE_I|CollectionElement (id:string son:bool nonce-value:integer ned:object{DpdcUdcV2.DPDC|NonceElement}))
    (defun XE_U|NonceSupply (id:string nonce-value:integer new-supply:integer))
    (defun XE_U|NonceHolder (id:string nonce-value:integer new-holder-account:string))
    (defun XE_U|NonceOrSplitData (id:string son:bool nonce-value:integer nos:bool nd:object{DpdcUdcV2.DPDC|NonceData}))
    ;;
    ;; [<VerumRolesTable> Writings] [3]
    ;;
    (defun XE_I|VerumRoles (id:string son:bool verum-chain:object{DpdcUdcV2.DPDC|VerumRoles}))
    ;;
    ;;  [Indirect Writings]
    ;;
    (defun XE_U|Frozen (id:string son:bool account:string toggle:bool))
    (defun XE_U|Exemption (id:string son:bool account:string toggle:bool))
    (defun XE_U|Burn (id:string son:bool account:string toggle:bool))
    (defun XE_U|Create (id:string son:bool account:string toggle:bool))
    (defun XE_U|Recreate (id:string son:bool account:string toggle:bool))
    (defun XE_U|Update (id:string son:bool account:string toggle:bool))
    (defun XE_U|ModifyCreator (id:string son:bool account:string toggle:bool))
    (defun XE_U|ModifyRoyalties (id:string son:bool account:string toggle:bool))
    (defun XE_U|SetNewUri (id:string son:bool account:string toggle:bool))
    (defun XE_U|Transfer (id:string son:bool account:string toggle:bool))
    (defun XE_U|VerumRoles (id:string son:bool rp:integer aor:bool account:string))
    ;;
    ;; [<AccountSuppliesTable> Writings] [4]
    ;;
    (defun XE_W|Supply (account:string id:string son:bool nonce-value:integer amount:integer))
    ;;{5.7}  User [A/C]

)
;;
(module DPDC GOV
    @doc "DPDC is the central collectables (NFT/SFT) state module, implementing DpdcV2, \
        \ BrandingUsageTertiaryV2 and OuronetPolicyV2. It owns all the domain tables — \
        \ separate DPSF (SFT) and DPNF (NFT) tables for Properties, Nonces, VerumRoles, \
        \ per-account Roles and AccountSupplies — and is the sole home of the UR_/URH_ \
        \ readers, UEV_ validators, CAP_Owner/Creator gates, and the XE_/XI_/XB_ write \
        \ primitives every other DPDC module routes persistence through. It also handles \
        \ collection branding and exposes the DPDC smart-account governor."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsageTertiaryV2)
    (implements DpdcV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC_ADMIN)))
    (defcap GOV|DPDC_ADMIN ()                           (enforce-guard GOV|MD_DPDC))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|CollectiblesKey ()                       (+ (CT_Namespace) ".dh_sc_dpdc-keyset"))
    ;;
    ;; [SC-Names]
    (defun GOV|DPDC|SC_NAME ()                          (at 0 ["Σ.μЖâAáпδÃàźфнMAŸôIÌjȘЛδεЬÍБЮoзξ4κΩøΠÒçѺłœщÌĘчoãueUøVlßHšδLτε£σž£ЙLÛòCÎcďьčfğÅηвČïnÊвÞIwÇÝмÉŠвRмWć5íЮzGWYвьżΨπûEÃdйdGЫŁŤČçПχĘŚślьЙŤğLУ0SýЭψȘÔÜнìÆkČѺȘÍÍΛ4шεнÄtИςȘ4"]))
    ;;
    ;;
    ;; [PBLs]
    (defun GOV|DPDC|PBL ()                              (at 0 ["9G.2j95rkomKqd207CDg5yycyKcAy1AqFhjy6D0rCr0Kbwe9E6libtveIHsAIw9F2c43v6IHILIBf62r2LD58xHE09kypyoevL62E81wHL4zj9tIyspf5df82upuBGGKmIsHGuvH86fHMMi99n0htsypL9h3dMHFCIx8ogeynkmCIghxK871rlkas8iDfce7AwAbiajr7H1LHi17mLD7aJu6m7xmcAABkhxtwb4Kqbk8xLpehakyu3AvajgJvtfeysoH67irvplA0as86Jls1r3d3oHms9Maaja9856wzybpthMGs6qDAzacE24skcA30wvm77BLhrdh0ymkl3vbJ9lG641J7ofg5K9gEbHD4ioFHLEajL28qsD4cFEhdDthDzwF8EnBBc74Dikqn9xixFap5Jxhl7D0owz5d9MDJzfjgx3jbdpD3zglsq83iC4fhcpbz3KeAi11Ig2pgIqnmwwqA0Exr5073w7lgzlrw3Ff7Co9uuxbnLuJvlFzgfGeIwM2Dmev1JskqEGK0Ck0B87iagsHFI76HC6sKnwrHnkl0sl8pAf0pbBaw9MbqLs"]))

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|DPDC|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DPDC_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPDC_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|DPDC_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|DPDC_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|DPDC|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DPDC|SC_KEY                               (GOV|CollectiblesKey))
    (defconst DPDC|SC_NAME                              (GOV|DPDC|SC_NAME))
    (defconst DPDC|SC_STOA-NAME                         "k:xxx")
    (defconst BAR                                       (CT_Bar))
    (defconst FRG                                       1000)
    ;;{3.2}  schemas
    ;;{3.3}  tables
    ;;
    (deftable DPSF|T|Properties:{DpdcUdcV2.DPDC|Properties})            ;;Key = <DPSF-id>      
    (deftable DPSF|T|Nonces:{DpdcUdcV2.DPDC|NonceElement})              ;;Key = <DPSF-id> + BAR + <nonce>
    (deftable DPSF|T|VerumRoles:{DpdcUdcV2.DPDC|VerumRoles})            ;;Key = <DPSF-id>
    (deftable DPSF|T|Account:{DpdcUdcV2.DPSF|AccountRoles})             ;;Key = <DPSF-id> + BAR + <account>
    (deftable DPSF|T|AccountSupplies:{DpdcUdcV2.DPDC|AccountSupply})    ;;Key = <account> + BAR + <DPSF-id> + BAR + <nonce>
    ;;
    (deftable DPNF|T|Properties:{DpdcUdcV2.DPDC|Properties})            ;;Key = <DPNF-id>      
    (deftable DPNF|T|Nonces:{DpdcUdcV2.DPDC|NonceElement})              ;;Key = <DSNF-id> + BAR + <nonce>
    (deftable DPNF|T|VerumRoles:{DpdcUdcV2.DPDC|VerumRoles})            ;;Key = <DPNF-id>
    (deftable DPNF|T|Account:{DpdcUdcV2.DPNF|AccountRoles})             ;;Key = <DPNF-id> + BAR + <account> 
    (deftable DPNF|T|AccountSupplies:{DpdcUdcV2.DPDC|AccountSupply})    ;;Key = <account> + BAR + <DPNF-id> + BAR + <nonce>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap DPDC|GOV ()
        @doc "Governor Capability for the DPDC Smart DALOS Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;
    ;;
    (defcap AHU ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ah:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
            )
            (ref-DALOS::CAP_EnforceAccountOwnership ah)
            (compose-capability (SECURE))
        )
    )
    (defcap DPDC|C>UPDATE-BRD (entity-id:string son:bool)
        @event
        (CAP_Owner entity-id son)
        (compose-capability (P|DPDC|CALLER))
    )
    (defcap DPDC|C>UPGRADE-BRD (entity-id:string son:bool)
        @event
        (CAP_Owner entity-id son)
        (compose-capability (P|DPDC|CALLER))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;; [Keys]
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    (defun UDC_Control:object{DpdcUdcV2.DPDC|Properties}
        (id:string son:bool cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
            )
            (ref-DPDC-UDC::UDC_DPDC|Properties
                id
                (UR_OwnerKonto id son)
                (UR_CreatorKonto id son)
                (UR_Name id son)
                (UR_Ticker id son)
                cu cco ccc casr ctncr cf cw cp
                (UR_IsPaused id son)
                (UR_NoncesUsed id son)
                (UR_SetClassesUsed id son)
            )
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_ParseSignedInteger:integer (value:string)
        @doc "Converts an integer written as string, to integer, working for negative values aswell."
        (let
            (
                (is-negative:bool (= (take 1 value) "-"))
                (abs-str:string (if is-negative (drop 1 value) value))
                (parsed-int:integer (str-to-int abs-str))
            )
            (if is-negative
                (- parsed-int)
                parsed-int
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;prefix (dirty/scan-tier reads), not UR_ (point reads); matches this file's other URH_* scans.
    (defun URH_AS-Keys:[string] (son:bool)
        (keys (if son DPSF|T|AccountSupplies DPNF|T|AccountSupplies))
    )
    ;;
    ;; [1] - [Properties]
    (defun UR_Properties:object{DpdcUdcV2.DPDC|Properties} (id:string son:bool)
        (read (if son DPSF|T|Properties DPNF|T|Properties) id)
    )
    (defun UR_OwnerKonto:string (id:string son:bool)
        (at "owner-konto" (UR_Properties id son))
    )
    (defun UR_CreatorKonto:string (id:string son:bool)
        (at "creator-konto" (UR_Properties id son))
    )
    (defun UR_Name:string (id:string son:bool)
        (at "name" (UR_Properties id son))
    )
    (defun UR_Ticker:string (id:string son:bool)
        (at "ticker" (UR_Properties id son))
    )
    (defun UR_CanUpgrade:bool (id:string son:bool)
        (at "can-upgrade" (UR_Properties id son))
    )
    (defun UR_CanChangeOwner:bool (id:string son:bool)
        (at "can-change-owner" (UR_Properties id son))
    )
    (defun UR_CanChangeCreator:bool (id:string son:bool)
        (at "can-change-creator" (UR_Properties id son))
    )
    (defun UR_CanAddSpecialRole:bool (id:string son:bool)
        (at "can-add-special-role" (UR_Properties id son))
    )
    (defun UR_CanTransferNftCreateRole:bool (id:string son:bool)
        (at "can-transfer-nft-create-role" (UR_Properties id son))
    )
    (defun UR_CanFreeze:bool (id:string son:bool)
        (at "can-freeze" (UR_Properties id son))
    )
    (defun UR_CanWipe:bool (id:string son:bool)
        (at "can-wipe" (UR_Properties id son))
    )
    (defun UR_CanPause:bool (id:string son:bool)
        (at "can-pause" (UR_Properties id son))
    )
    (defun UR_IsPaused:bool (id:string son:bool)
        (at "is-paused" (UR_Properties id son))
    )
    (defun UR_NoncesUsed:integer (id:string son:bool)
        (at "nonces-used" (UR_Properties id son))
    )
    (defun UR_SetClassesUsed:integer (id:string son:bool)
        (at "set-classes-used" (UR_Properties id son))
    )
    ;; [2] - [Nonce Element] - Only positive nonces can be read this way; Negative Nonces will error out except for <UR_NonceSupply>
    (defun UR_NonceElement:object{DpdcUdcV2.DPDC|NonceElement} (id:string son:bool nonce:integer)
        (read (if son DPSF|T|Nonces DPNF|T|Nonces) (concat [id BAR (format "{}" [nonce])]))
    )
    (defun UR_NonceClass:integer (id:string son:bool nonce:integer)
        (at "nonce-class" (UR_NonceElement id son (abs nonce)))
    )
    (defun UR_NonceValue:integer (id:string son:bool nonce:integer)
        (at "nonce-value" (UR_NonceElement id son nonce))
    )
    (defun UR_NonceSupply:integer (id:string son:bool nonce:integer)
        @doc "Can be used with negative Nonce Value"
        (if son
            (if (< nonce 0)
                (* FRG (UR_AccountNonceSupply DPDC|SC_NAME id son (abs nonce)))
                (at "nonce-supply" (UR_NonceElement id son (abs nonce)))
            )
            (if (< nonce 0)
                FRG
                (at "nonce-supply" (UR_NonceElement id son (abs nonce)))
            )
        )
    )
    (defun UR_NonceHolder:string (id:string son:bool nonce:integer)
        (at "nonce-holder" (UR_NonceElement id son nonce))
    )
    (defun UR_NativeNonceData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool nonce:integer)
        (at "nonce-data" (UR_NonceElement id son nonce))
    )
    (defun UR_SplitNonceData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool nonce:integer)
        (at "split-data" (UR_NonceElement id son nonce))
    )
    (defun UR_NonceData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool nonce:integer)
        (if (< nonce 0)
            (UR_SplitNonceData id son (abs nonce))
            (UR_NativeNonceData id son nonce)
        )
    )
    ;;
    ;; [2.1] - [Generic Nonce-Data Read]
    (defun UR_N|Royalty:decimal (n:object{DpdcUdcV2.DPDC|NonceData})
        @doc "Forward-looking hook for the upcoming Escrow/NFT marketplace (not yet built) — no on-chain \
            \ consumer reads this today, unlike UR_N|IgnisRoyalty below, which DPDC-T's transfer pricing \
            \ actively consumes. Confirmed intentional, not dead/unfinished code. DPDC Audit #26M."
        (at "royalty" n)
    )
    (defun UR_N|IgnisRoyalty:decimal (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "ignis" n)
    )
    (defun UR_N|Name:string (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "name" n)
    )
    (defun UR_N|Description:string (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "description" n)
    )
    (defun UR_N|MetaData:object{DpdcUdcV2.NonceMetaData} (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "meta-data" n)
    )
    (defun UR_N|AssetType:object{DpdcUdcV2.URI|Type} (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "asset-type" n)
    )
    (defun UR_N|Primary:object{DpdcUdcV2.URI|Data} (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "uri-primary" n)
    )
    (defun UR_N|Secondary:object{DpdcUdcV2.URI|Data} (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "uri-secondary" n)
    )
    (defun UR_N|Tertiary:object{DpdcUdcV2.URI|Data} (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "uri-tertiary" n)
    )
    ;;  [2.1.1] - [Generic Nonce-MetaData Read]
    (defun UR_N|RawScore:decimal (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "score" (UR_N|MetaData n))
    )
    (defun UR_N|Composition:[integer] (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "composition" (UR_N|MetaData n))
    )
    (defun UR_N|RawMetaData:object (n:object{DpdcUdcV2.DPDC|NonceData})
        (at "meta-data" (UR_N|MetaData n))
    )
    ;;  [2.2] - [Existing Nonce-Data Read]
    ;;  [Uses Above Functions, instead of <n> would use <(UR_NativeNonceData id son nonce)> or <(UR_SplitNonceData id son nonce)>]
    ;;
    ;;  [3] - [VerumRoles]
    (defun UR_VerumRoles:object{DpdcUdcV2.DPDC|VerumRoles} (id:string son:bool)
        (if son
            (read DPSF|T|VerumRoles id)
            (read DPNF|T|VerumRoles id)
        )
    )
    (defun UR_Verum1:[string] (id:string son:bool)
        (at "a-frozen" (UR_VerumRoles id son))
    )
    (defun UR_Verum2:[string] (id:string son:bool)
        (at "r-exemption" (UR_VerumRoles id son))
    )
    (defun UR_Verum3:[string] (id:string son:bool)
        (at "r-nft-add-quantity" (UR_VerumRoles id son))
    )
    (defun UR_Verum4:[string] (id:string son:bool)
        (at "r-nft-burn" (UR_VerumRoles id son))
    )
    (defun UR_Verum5:string (id:string son:bool)
        (at "r-nft-create" (UR_VerumRoles id son))
    )
    (defun UR_Verum6:string (id:string son:bool)
        (at "r-nft-recreate" (UR_VerumRoles id son))
    )
    (defun UR_Verum7:[string] (id:string son:bool)
        (at "r-nft-update" (UR_VerumRoles id son))
    )
    (defun UR_Verum8:[string] (id:string son:bool)
        (at "r-modify-creator" (UR_VerumRoles id son))
    )
    (defun UR_Verum9:[string] (id:string son:bool)
        (at "r-modify-royalties" (UR_VerumRoles id son))
    )
    (defun UR_Verum10:string (id:string son:bool)
        (at "r-set-new-uri" (UR_VerumRoles id son))
    )
    (defun UR_Verum11:[string] (id:string son:bool)
        (at "r-transfer" (UR_VerumRoles id son))
    )
    (defun URv_GetVerumChain:[string] (id:string son:bool rp:integer)
        (enforce (contains rp [1 2 3 4 7 8 9 11]) "Invalid Position for Multi Verum")
        (cond
            ((= rp 1) (UR_Verum1 id son))
            ((= rp 2) (UR_Verum2 id son))
            ((= rp 3) (UR_Verum3 id son))
            ((= rp 4) (UR_Verum4 id son))
            ((= rp 7) (UR_Verum7 id son))
            ((= rp 8) (UR_Verum8 id son))
            ((= rp 9) (UR_Verum9 id son))
            ((= rp 11) (UR_Verum11 id son))
            [BAR]
        )
    )
    ;; [4] - [Account]
    (defun UR_IzAccount:bool (account:string id:string son:bool)
        (let
            (
                (trial 
                    (if son
                        (try false (read DPSF|T|Account (concat [id BAR account])))
                        (try false (read DPNF|T|Account (concat [id BAR account])))
                    )
                ) 
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun UR_CA|R:object{DpdcUdcV2.AccountRoles} (id:string son:bool account:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (f:bool false)
            )
            (if son
                (with-default-read DPSF|T|Account (concat [id BAR account])
                    { "roles" : (ref-DPDC-UDC::UDC_AccountRoles f f f f f f f f f f)}
                    { "roles" := rolez}
                    rolez
                )
                (with-default-read DPNF|T|Account (concat [id BAR account])
                    { "roles" : (ref-DPDC-UDC::UDC_AccountRoles f f f f f f f f f f)}
                    { "roles" := rolez}
                    rolez
                )
            )
        )
    )
    (defun UR_CA|R-AddQuantity:bool (id:string account:string)
        (with-default-read DPSF|T|Account (concat [id BAR account])
            { "role-nft-add-quantity" : false}
            { "role-nft-add-quantity" := rnaq }
            rnaq
        )
    )
    (defun UR_CA|R-Frozen:bool (id:string son:bool account:string)
        (at "frozen" (UR_CA|R id son account))
    )
    (defun UR_CA|R-Exemption:bool (id:string son:bool account:string)
        (at "role-exemption" (UR_CA|R id son account))
    )
    (defun UR_CA|R-Burn:bool (id:string son:bool account:string)
        (at "role-nft-burn" (UR_CA|R id son account))
    )
    (defun UR_CA|R-Create:bool (id:string son:bool account:string)
        (at "role-nft-create" (UR_CA|R id son account))
    )
    (defun UR_CA|R-Recreate:bool (id:string son:bool account:string)
        (at "role-nft-recreate" (UR_CA|R id son account))
    )
    (defun UR_CA|R-Update:bool (id:string son:bool account:string)
        (at "role-nft-update" (UR_CA|R id son account))
    )
    (defun UR_CA|R-ModifyCreator:bool (id:string son:bool account:string)
        (at "role-modify-creator" (UR_CA|R id son account))
    )
    (defun UR_CA|R-ModifyRoyalties:bool (id:string son:bool account:string)
        (at "role-modify-royalties" (UR_CA|R id son account))
    )
    (defun UR_CA|R-SetUri:bool (id:string son:bool account:string)
        (at "role-set-new-uri" (UR_CA|R id son account))
    )
    (defun UR_CA|R-Transfer:bool (id:string son:bool account:string)
        (at "role-transfer" (UR_CA|R id son account))
    )
    ;; [5] - [AccountSupplies]
    (defun UR_AccountSupply:object{DpdcUdcV2.DPDC|AccountSupply} (account:string id:string son:bool nonce:integer)
        (read
            (if son DPSF|T|AccountSupplies DPNF|T|AccountSupplies)
            (concat [account BAR id BAR (format "{}" [nonce])])
        )
    )
    (defun UR_AccountNonceSupply:integer (account:string id:string son:bool nonce:integer)
        @doc "Returns the Supply of a Nonce on an account, returning -1 if no supply is detected \
        \ If the Account exists and has no supply, it would return as 0."
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (zs:object{DpdcUdcV2.DPDC|AccountSupply} (ref-DPDC-UDC::UDC_DPDC|AccountSupply BAR BAR -1 -1))
            )
            (at "supply" (try zs (UR_AccountSupply account id son nonce)))
        )
    )
    (defun UR_AccountNoncesSupplies:[integer] (account:string id:string son:bool nonces:[integer])
        @doc "Returns the Supplies of the <nonces> used in the input"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[integer] element:integer)
                    (ref-U|LST::UC_AppL acc (UR_AccountNonceSupply account id son element))
                )
                []
                nonces
            )
        ) 
    )
    ;;
    ;;  [URD]
    ;;
    ;;1] Returns Collectables held by Account
    (defun URH_HeldCollectables:[string] (account:string son:bool)
        @doc "Returns all Collectables that are registered for a given <account>"
        (map (at "id")
            (select (if son DPSF|T|Account DPNF|T|Account) ["id"]
                (where "account" (= account))
            )
        )
    )
    ;;2]Returns Accounts that are registered for a given Collectable
    (defun URH_ExistingCollectables:[string] (dpdc:string son:bool)
        @doc "Returns all Ouronet Accounts that are registered for a given <dpdc>"
        (map (at "account")
            (select (if son DPSF|T|Account DPNF|T|Account) ["account"]
                (where "id" (= dpdc))
            )
        )
    )
    ;;3]Returns a List of DPTFs that are owned by a given Account for Management Purposes
    (defun URH_OwnedCollectables:[string] (account:string son:bool)
        @doc "Returns all Collectables that can be managed by the given <account>"
        (map (at "id")
            (select (if son DPSF|T|Properties DPNF|T|Properties) ["id"]
                (where "owner-konto" (= account))
            )
        )
    )
    ;;
    (defun URH_AccountNonces:[integer] (account:string id:string son:bool)
        (let 
            (
                (tbl (if son DPSF|T|AccountSupplies DPNF|T|AccountSupplies))
                (results 
                    (map (at "nonce")
                        (filter
                            (lambda (x) (> (at "supply" x) 0))
                            (select tbl ["nonce" "supply"]
                                (and?
                                    (where "id" (= id))
                                    (where "account" (= account))
                                )
                            )
                        )
                        
                    )
                )
            )
            (if (= (length results) 0) 
                [] 
                results
            )
        )
    )
    (defun URH_AccountNoncesWithSupplies:[object] (account:string id:string son:bool)
        @doc "Returns an object with keys <nonce> and <supply> with the required data"
        (let 
            (
                (tbl (if son DPSF|T|AccountSupplies DPNF|T|AccountSupplies))
                (results 
                    (select tbl ["nonce" "supply"]
                        (and?
                            (where "id" (= id))
                            (where "account" (= account))
                        )
                    )
                )
            )
            ;;DPDC Audit #34M: was [{}] (a 1-element list of an empty object with no "nonce"/"supply"
            ;;keys) -- a phantom result that inflates any caller's (length ...) count by 1 for an
            ;;account holding zero nonces. Mirror URH_AccountNonces's correct [] for the empty case.
            (if (= (length results) 0)
                []
                (filter (lambda (x) (> (at "supply" x) 0)) results)
            )
        )
    )
    ;;
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (entity-id:string son:bool)
        @doc "Cost preview for C_UpdatePendingBranding (Branding tier; son->4.0 else 5.0)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (owner:string (UR_OwnerKonto entity-id son))
                (multiplier:decimal (if son 4.0 5.0))
            )
            (ref-IGNIS::UDC_BrandingCumulator owner multiplier)
        )
    )
    (defun URCi_UpgradeBranding:decimal (months:integer)
        @doc "Cost preview for C_UpgradeBranding (delegates to BRD single source; \
            \ the exec path bills the same value via ref-BRD::XE_UpgradeBranding)."
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (ref-BRD::URCi_UpgradeBranding months)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_id (id:string son:bool)
        (if son
            (with-default-read DPSF|T|Properties id
                { "nonces-used"   : -1 }
                { "nonces-used"   := ne }
                (enforce (>= ne 0) (format "DPSF ID {} does not exist" [id]))
            )
            (with-default-read DPNF|T|Properties id
                { "nonces-used"   : -1 }
                { "nonces-used"   := ne }
                (enforce (>= ne 0) (format "DPNF ID {} does not exist" [id]))
            )
        )
    )
    (defun UEV_NonceMapper (id:string son:bool nonces:[integer])
        (map
            (lambda
                (idx:integer)
                (UEV_Nonce id son (at idx nonces))
            )
            (enumerate 0 (- (length nonces) 1))
        )
    )
    (defun UEV_Nonce (id:string son:bool nonce:integer)
        @doc "Validates a nonce for the given DPDC id. \
            \ SHADOWED-GUARD FIX: all three predicates used to sit in ONE enforce BELOW a \
            \ <UR_NonceValue> binding. That reader hard-reads DPSF|T|Nonces / DPNF|T|Nonces \
            \ keyed by the nonce itself, and Pact evaluates let bindings before the body - so \
            \ nonce 0 or any nonce above <nonces-used> aborted on 'row not found' and NONE of \
            \ the three predicates was reachable for any input. \
            \ The two INPUT guards now run before the keyed read; the third is kept after it as \
            \ a data-integrity assertion. Message is unchanged on every path."
        (let
            (
                (an:integer (abs nonce))
                (nu:integer (UR_NoncesUsed id son))
            )
            ;;Split rather than folded into one enforce on purpose: the second predicate needs a
            ;;read keyed BY <an>, so it can only be evaluated once <an> is known to be in range.
            (enforce (and (!= an 0) (<= an nu)) "Invalid Nonce Value")
            (enforce (= an (UR_NonceValue id son an)) "Invalid Nonce Value")
        )
    )
    (defun UEV_CanUpgradeON (id:string son:bool)
        (let
            (
                (x:bool (UR_CanUpgrade id son))
            )
            (enforce x (format "{} properties cannot be upgraded" [id]))
        )
    )
    (defun UEV_CanPauseON (id:string son:bool)
        (let
            (
                (x:bool (UR_CanPause id son))
            )
            (enforce x (format "{} cannot be paused" [id]))
        )
    )
    (defun UEV_CanAddSpecialRoleON (id:string son:bool)
        (let
            (
                (x:bool (UR_CanAddSpecialRole id son))
            )
            (enforce x (format "For {} no special roles can be added" [id]))
        )
    )
    (defun UEV_ToggleSpecialRole (id:string son:bool toggle:bool)
        (if toggle
            (UEV_CanAddSpecialRoleON id son)
            true
        )
    )
    (defun UEV_CanFreezeON (id:string son:bool)
        (let
            (
                (x:bool (UR_CanFreeze id son))
            )
            (enforce x (format "{} cannot be freezed" [id]))
        )
    )
    (defun UEV_CanWipeON (id:string son:bool)
        (let
            (
                (x:bool (UR_CanWipe id son))
            )
            (enforce x (format "{} cannot be wiped" [id]))
        )
    )
    (defun UEV_PauseState (id:string son:bool state:bool)
        (let
            (
                (x:bool (UR_IsPaused id son)) ;;false
            )
            (if state
                (enforce x (format "{} is already unpaused" [id]))
                (enforce (not x) (format "{} is already paused" [id]))
            )
        )
    )
    (defun UEV_AccountAddQuantityState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-AddQuantity id account))
            )
            (enforce (= x state) (format "Add Quantity Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountFreezeState (id:string son:bool account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-Frozen id son account))
            )
            (enforce (= x state) (format "Frozen for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountExemptionState (id:string son:bool account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-Exemption id son account))
            )
            (enforce (= x state) (format "Exemption Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountBurnState (id:string son:bool account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-Burn id son account))
            )
            (enforce (= x state) (format "NFT Burn Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountUpdateState (id:string son:bool account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-Update id son account))
            )
            (enforce (= x state) (format "NFT Update Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountModifyCreatorState (id:string son:bool account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-ModifyCreator id son account))
            )
            (enforce (= x state) (format "Modify Creator Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountModifyRoyaltiesState (id:string son:bool account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-ModifyRoyalties id son account))
            )
            (enforce (= x state) (format "Modify Royalties Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountTransferState (id:string son:bool account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-Transfer id son account))
            )
            (enforce (= x state) (format "Transfer Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountCreateState (id:string son:bool account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-Create id son account))
            )
            (enforce (= x state) (format "Create Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountRecreateState (id:string son:bool account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-Recreate id son account))
            )
            (enforce (= x state) (format "Recreate Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountSetUriState (id:string son:bool account:string state:bool)
        (let
            (
                (x:bool (UR_CA|R-SetUri id son account))
            )
            (enforce (= x state) (format "Set Uri Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_Royalty (royalty:decimal)
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
            )
            (ref-U|DALOS::UEV_Fee royalty)
        )
    )
    (defun UEV_IgnisRoyalty (royalty:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ignis-pr:integer (ref-DPTF::UR_Decimals ignis-id))
            )
            (enforce
                (= (floor royalty ignis-pr) royalty)
                (format "The Ignis input amount of {} is not conform with its precision" [royalty])
            )
        )
    )
    (defun UEV_Name (name:string)
        @doc "Bounds a nonce's free-text name. See DPDC Audit #12Hb."
        (enforce
            (<= (length name) 256)
            (format "Nonce name cannot exceed 256 characters (got {})" [(length name)])
        )
    )
    (defun UEV_Description (description:string)
        @doc "Bounds a nonce's free-text description: max 1024 words, max 256 characters per \
            \ word. See DPDC Audit #12Hb."
        (let*
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (words:[string]
                    (if (= (length description) 0)
                        []
                        (ref-U|LST::UC_SplitString " " description)
                    )
                )
                (word-count:integer (length words))
            )
            (enforce
                (<= word-count 1024)
                (format "Nonce description cannot exceed 1024 words (got {})" [word-count])
            )
            (enforce
                (fold (and) true (map (lambda (w:string) (<= (length w) 256)) words))
                "Every word in a nonce description must be 256 characters or fewer"
            )
        )
    )
    (defun UEV_MetaDataBag (meta-data:object)
        @doc "Coarse anti-bloat ceiling on the free-form NFT trait bag consumed by AQP-ANK/AQP-SCORE \
            \ for trait scoring — total serialized size, since Pact cannot enumerate an untyped \
            \ object's keys for a precise per-key/per-value check. See DPDC Audit #12Hb."
        (enforce
            (<= (length (format "{}" [meta-data])) 8192)
            "Nonce meta-data is too large (8192 character serialized ceiling)"
        )
    )
    (defun UEV_AssetType (asset-type:object{DpdcUdcV2.URI|Type})
        @doc "At least one of the 7 asset-type flags must be set; any combination up to all 7 \
            \ simultaneously is valid. See DPDC Audit #12Hb."
        (enforce
            (fold (or) false
                [
                    (at "image" asset-type)    (at "audio" asset-type)
                    (at "video" asset-type)    (at "document" asset-type)
                    (at "archive" asset-type)  (at "model" asset-type)
                    (at "exotic" asset-type)
                ]
            )
            "At least one asset-type flag must be set"
        )
    )
    (defun UEV_UriData (u:object{DpdcUdcV2.URI|Data})
        @doc "Bounds every link string in a URI|Data bundle (uri-primary/secondary/tertiary each \
            \ carry one — primary/high-res/thumbnail tiers of the same element) to 2048 characters — \
            \ generous for any real link/CID, blocks raw payloads hiding in a link field. \
            \ See DPDC Audit #12Hb."
        (enforce
            (fold (and) true
                (map (lambda (l:string) (<= (length l) 2048))
                    [
                        (at "image" u)    (at "audio" u)
                        (at "video" u)    (at "document" u)
                        (at "archive" u)  (at "model" u)
                        (at "exotic" u)
                    ]
                )
            )
            "A URI link string exceeds the 2048 character limit"
        )
    )
    (defun UEV_NftNonceExistance (id:string nonce:integer existance:bool)
        (let
            (
                (x:string (UR_NonceHolder id false nonce))
                (ft:string (format "NFT {} Nonce {} must have Existance set to {} for Operation" [id nonce existance]))
            )
            (if (> nonce 0)
                (if existance
                    (enforce (!= x BAR) ft)
                    (enforce (= x BAR) ft)
                )
                (let
                    (
                        (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                        (split-data:object{DpdcUdcV2.DPDC|NonceData} (UR_SplitNonceData id false nonce))
                        (znd:object{DpdcUdcV2.DPDC|NonceData} (ref-DPDC-UDC::UDC_ZeroNonceData))
                    )
                    (if existance
                        (enforce (!= split-data znd) ft)
                        (enforce (= split-data znd) ft)
                    )
                )
            )
        )
    )
    (defun UEV_NonceQuantityInclusion (account:string id:string son:bool nonce:integer amount:integer)
        (let
            (
                (nonce-supply:integer (UR_AccountNonceSupply account id son nonce))
            )
            (if (or son (< nonce 0))
                (enforce 
                    (<= amount nonce-supply) 
                    (format 
                        "Account {} doesnt hold {} {} Nonce {} in sufficient quantity for Operation!" 
                        [account (if son "SFT" "NFT") id nonce]
                    )
                )
                (let
                    (
                        (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                        (nft-holder:string (UR_NonceHolder id false nonce))
                        (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                    )
                    ;;1] ACTIVE-NONCE check, and the ORIGINAL check on this branch. Kept FIRST and
                    ;;with its ORIGINAL MESSAGE, so every refusal that fired here before still fires
                    ;;here, with the same wording: [6.4]_AQP-EXHAUSTIVE-DPNF <<TX-AQP-NF01>> pins it
                    ;;by message, and reordering these two broke that pin the first time round. It
                    ;;is also the only check that distinguishes an INACTIVATED nonce, which stores
                    ;;BAR here. But it must never be the ONLY gate, because it compares an
                    ;;ABBREVIATION, not an identity. <nonce-holder> stores
                    ;;OI|UC_ShortAccount = (take 5) + "..." + (take -3) = 11 characters, two of
                    ;;which are the fixed `Ѻ.` prefix. Any two glyph-valid accounts sharing three
                    ;;leading and three trailing body characters are IDENTICAL to it, and the
                    ;;account string is chosen freely by whoever deploys it -- GLYPH|UEV_DalosAccount
                    ;;checks length, prefix, separator and charset, and does not bind the string to
                    ;;the guard.
                    ;;2] FULL-ACCOUNT possession, and the fix. <nonce-supply> is read from the
                    ;;AccountSupplies table, whose key carries the COMPLETE 162-character account
                    ;;string, so it is the only value in scope that can tell two accounts apart. It
                    ;;was already bound at the top of this function and, on this branch alone, was
                    ;;never spent. Added AFTER line 1 and with a DISTINCT message, so the two
                    ;;refusals stay tellable apart -- the RT-C-001 lesson.
                    ;;Pinned by RedTeam/[RT-D2]_Ownership-Collectables.repl <<RT-D-002d>>.
                    (enforce (= sa nft-holder)
                        (format "Account {} doesnt hold NFT {} Nonce {}" [account id nonce]))
                    (enforce (<= amount nonce-supply)
                        (format "Account {} is not the full-account holder of NFT {} Nonce {}"
                            [account id nonce]))
                )
            )
        )
    )
    (defun UEV_NonceQuantityInclusionMapper (account:string id:string son:bool nonces:[integer] amounts:[integer])
        (map
            (lambda
                (idx:integer)
                (UEV_NonceQuantityInclusion account id son (at idx nonces) (at idx amounts))
            )
            (enumerate 0 (- (length nonces) 1))
        )
    )
    ;;
    (defun UEV_ExecutorIsOwnerKonto (executor:string entity-id:string son:bool)
        @doc "BINDS <executor> to <entity-id>'s owner, across BOTH collectable kinds. \
            \ \
            \ Ownership is proven INDIRECTLY: DPDC|C>UPDATE-BRD / C>UPGRADE-BRD call CAP_Owner, \
            \ which enforces ownership of the DERIVED (UR_OwnerKonto entity-id son) -- HANDOFF \
            \ 4g. This supplies the other half, that the account the caller NAMED is that owner. \
            \ \
            \ <son> IS PART OF THE KEY, not decoration. DPSF and DPNF are separate tables and a \
            \ given id can exist in both, so an owner lookup without <son> is a lookup of a \
            \ different token. Reading through UR_OwnerKonto with the same pair the capability \
            \ uses is what stops the binder and the enforce disagreeing about which token they \
            \ are talking about. \
            \ (patron/executor canon 2.2, indirect route named.)"
        (enforce (= executor (UR_OwnerKonto entity-id son))
            "Executor is not the Entity Owner")
    )
    (defun CAP_Owner (id:string son:bool)
        @doc "Enforces DPSF or DPNF Token ID Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_OwnerKonto id son))
        )
    )
    (defun CAP_Creator (id:string son:bool)
        @doc "Enforces DPSF or DPNF Token ID Creator Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_CreatorKonto id son))
        )
    )
    (defun CAP_OwnerOrCreator (id:string son:bool)
        @doc "Enforces DPSF or DPNF Token ID Owner or Creator Ownership"
        (enforce-one
            (format "Owner or Creator for {} {} not verified" [(if son "DPSF" "DPNF") id])
            [
                (enforce-guard (create-user-guard (CAP_Owner id son)))
                (enforce-guard (create-user-guard (CAP_Creator id son)))
            ]
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;; [<AccountsTable> Writings] [0]
    ;;Enforce: 5 call sites (C_IssueDigitalCollection, A_RegisterAssetToLaunchpad, XE_DeployAccountWNE,
    ;;          DPDC-I, TS02-DPAD) -- relocating UEV_EnforceAccountExists duplicates it 5x.
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XBv_DeployAccountSFT
        (
            account:string id:string
            input-rnaq:bool f:bool re:bool rnb:bool rnc:bool rnr:bool
            rnu:bool rmc:bool rmr:bool rsnu:bool rt:bool
        )
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (UEV_id id true)
            (with-default-read DPSF|T|Account (concat [id BAR account])
                (ref-DPDC-UDC::UDC_DPSF|AccountRoles
                    (ref-DPDC-UDC::UDC_AccountRoles f re rnb rnc rnr rnu rmc rmr rsnu rt)
                    input-rnaq
                    id account
                )
                {"roles"                    := r
                ,"role-nft-add-quantity"    := rnaq
                ,"id"                       := i
                ,"account"                  := a}
                (write DPSF|T|Account (concat [id BAR account])
                    (ref-DPDC-UDC::UDC_DPSF|AccountRoles r rnaq i a)
                )
            )
        )
    )
    ;;Enforce: 5 call sites (C_IssueDigitalCollection, A_RegisterAssetToLaunchpad, XE_DeployAccountWNE,
    ;;          DPDC-I, TS02-DPAD) -- relocating UEV_EnforceAccountExists duplicates it 5x.
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XBv_DeployAccountNFT 
        (
            account:string id:string
            f:bool re:bool rnb:bool rnc:bool rnr:bool
            rnu:bool rmc:bool rmr:bool rsnu:bool rt:bool
        )
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (UEV_id id false)
            (with-default-read DPNF|T|Account (concat [id BAR account])
                (ref-DPDC-UDC::UDC_DPNF|AccountRoles
                    (ref-DPDC-UDC::UDC_AccountRoles f re rnb rnc rnr rnu rmc rmr rsnu rt)
                    id account
                )
                {"roles"                    := r
                ,"id"                       := i
                ,"account"                  := a}
                (write DPNF|T|Account (concat [id BAR account])
                    (ref-DPDC-UDC::UDC_DPNF|AccountRoles r i a)
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_DeployAccountWNE (account:string id:string son:bool)
        (P|UEV_IMC)
        (let
            (
                (collection-account-exists:bool (UR_IzAccount account id son))
                (f:bool false)
            )
            (if (not collection-account-exists)
                (if son
                    (XBv_DeployAccountSFT account id f f f f f f f f f f f)
                    (XBv_DeployAccountNFT account id f f f f f f f f f f)
                )
                true
            )
        )
    )
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|Rnaq (id:string account:string toggle)
        (P|UEV_IMC)
        (update DPSF|T|Account (concat [id BAR account])
            {"role-nft-add-quantity" : toggle}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|AccountRoles (id:string son:bool account:string new-roles:object{DpdcUdcV2.AccountRoles})
        (require-capability (SECURE))
        (if son
            (update DPSF|T|Account (concat [id BAR account])
                {"roles" : new-roles}
            )
            (update DPNF|T|Account (concat [id BAR account])
                {"roles" : new-roles}
            )
        )
    )
    ;; [<PropertiesTable> Writings] [1]
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_I|Collection
        (id:string son:bool idp:object{DpdcUdcV2.DPDC|Properties})
        (P|UEV_IMC)
        (if son
            (insert DPSF|T|Properties id idp)
            (insert DPNF|T|Properties id idp)
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|Specs (id:string son:bool specs:object{DpdcUdcV2.DPDC|Properties})
        (P|UEV_IMC)
        (if son
            (update DPSF|T|Properties id specs)
            (update DPNF|T|Properties id specs)
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|IsPaused (id:string son:bool toggle:bool)
        (P|UEV_IMC)
        (if son
            (update DPSF|T|Properties id {"is-paused" : toggle})
            (update DPNF|T|Properties id {"is-paused" : toggle})
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|NoncesUsed (id:string son:bool new-nv:integer)
        (P|UEV_IMC)
        (if son
            (update DPSF|T|Properties id {"nonces-used" : new-nv})
            (update DPNF|T|Properties id {"nonces-used" : new-nv})
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|SetClassesUsed (id:string son:bool new-nsc:integer)
        (P|UEV_IMC)
        (if son
            (update DPSF|T|Properties id {"set-classes-used" : new-nsc})
            (update DPNF|T|Properties id {"set-classes-used" : new-nsc})
        )
    )
    ;; [<NoncesTable> Writings] [2]
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_I|CollectionElement (id:string son:bool nonce-value:integer ned:object{DpdcUdcV2.DPDC|NonceElement})
        (P|UEV_IMC)
        (if son
            (insert DPSF|T|Nonces (concat [id BAR (format "{}" [nonce-value])]) ned)
            (insert DPNF|T|Nonces (concat [id BAR (format "{}" [nonce-value])]) ned)
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|NonceSupply (id:string nonce-value:integer new-supply:integer)
        (P|UEV_IMC)
        (update DPSF|T|Nonces (concat [id BAR (format "{}" [nonce-value])]) {"nonce-supply" : new-supply})
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|NonceHolder (id:string nonce-value:integer new-holder-account:string)
        (P|UEV_IMC)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (iz-bar:bool (if (= new-holder-account BAR) true false))
                (sh:string
                    (if iz-bar
                        BAR
                        (ref-I|OURONET::OI|UC_ShortAccount new-holder-account)
                    )
                )
            )
            (update DPNF|T|Nonces (concat [id BAR (format "{}" [nonce-value])]) {"nonce-holder" : sh})
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|NonceOrSplitData (id:string son:bool nonce-value:integer nos:bool nd:object{DpdcUdcV2.DPDC|NonceData} )
        (P|UEV_IMC)
        (if nos
            (if son
                (update DPSF|T|Nonces (concat [id BAR (format "{}" [nonce-value])]) {"nonce-data" : nd})
                (update DPNF|T|Nonces (concat [id BAR (format "{}" [nonce-value])]) {"nonce-data" : nd})
            )
            (if son
                (update DPSF|T|Nonces (concat [id BAR (format "{}" [nonce-value])]) {"split-data" : nd})
                (update DPNF|T|Nonces (concat [id BAR (format "{}" [nonce-value])]) {"split-data" : nd})
            )
        )
    )
    ;; [<VerumRolesTable> Writings] [3]
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_I|VerumRoles (id:string son:bool verum-chain:object{DpdcUdcV2.DPDC|VerumRoles})
        (P|UEV_IMC)
        (if son
            (insert DPSF|T|VerumRoles id verum-chain)
            (insert DPNF|T|VerumRoles id verum-chain)
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole1 (id:string son:bool ul:[string])
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"a-frozen" : ul})
            (update DPNF|T|VerumRoles id {"a-frozen" : ul})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole2 (id:string son:bool ul:[string])
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"r-exemption" : ul})
            (update DPNF|T|VerumRoles id {"r-exemption" : ul})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole3 (id:string son:bool ul:[string])
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"r-nft-add-quantity" : ul})
            (update DPNF|T|VerumRoles id {"r-nft-add-quantity" : ul})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole4 (id:string son:bool ul:[string])
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"r-nft-burn" : ul})
            (update DPNF|T|VerumRoles id {"r-nft-burn" : ul})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole5 (id:string son:bool ul:string)
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"r-nft-create" : ul})
            (update DPNF|T|VerumRoles id {"r-nft-create" : ul})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole6 (id:string son:bool ul:string)
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"r-nft-recreate" : ul})
            (update DPNF|T|VerumRoles id {"r-nft-recreate" : ul})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole7 (id:string son:bool ul:[string])
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"r-nft-update" : ul})
            (update DPNF|T|VerumRoles id {"r-nft-update" : ul})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole8 (id:string son:bool ul:[string])
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"r-modify-creator" : ul})
            (update DPNF|T|VerumRoles id {"r-modify-creator" : ul})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole9 (id:string son:bool ul:[string])
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"r-modify-royalties" : ul})
            (update DPNF|T|VerumRoles id {"r-modify-royalties" : ul})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole10 (id:string son:bool ul:string)
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"r-set-new-uri" : ul})
            (update DPNF|T|VerumRoles id {"r-set-new-uri" : ul})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|VerumRole11 (id:string son:bool ul:[string])
        (require-capability (SECURE))
        (if son
            (update DPSF|T|VerumRoles id {"r-transfer" : ul})
            (update DPNF|T|VerumRoles id {"r-transfer" : ul})
        )
    )
    ;;
    ;;  [Indirect Writings]
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|Frozen (id:string son:bool account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SECURE) 
            (XI_U|AccountRoles id son account
                (+
                    {"frozen" : toggle}
                    (remove "frozen" (UR_CA|R id son account))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|Exemption (id:string son:bool account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SECURE) 
            (XI_U|AccountRoles id son account
                (+
                    {"role-exemption" : toggle}
                    (remove "role-exemption" (UR_CA|R id son account))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|Burn (id:string son:bool account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SECURE) 
            (XI_U|AccountRoles id son account
                (+
                    {"role-nft-burn" : toggle}
                    (remove "role-nft-burn" (UR_CA|R id son account))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|Create (id:string son:bool account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SECURE) 
            (XI_U|AccountRoles id son account
                (+
                    {"role-nft-create" : toggle}
                    (remove "role-nft-create" (UR_CA|R id son account))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|Recreate (id:string son:bool account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SECURE) 
            (XI_U|AccountRoles id son account
                (+
                    {"role-nft-recreate" : toggle}
                    (remove "role-nft-recreate" (UR_CA|R id son account))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|Update (id:string son:bool account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SECURE) 
            (XI_U|AccountRoles id son account
                (+
                    {"role-nft-update" : toggle}
                    (remove "role-nft-update" (UR_CA|R id son account))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|ModifyCreator (id:string son:bool account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SECURE) 
            (XI_U|AccountRoles id son account
                (+
                    {"role-modify-creator" : toggle}
                    (remove "role-modify-creator" (UR_CA|R id son account))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|ModifyRoyalties (id:string son:bool account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SECURE) 
            (XI_U|AccountRoles id son account
                (+
                    {"role-modify-royalties" : toggle}
                    (remove "role-modify-royalties" (UR_CA|R id son account))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|SetNewUri (id:string son:bool account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SECURE) 
            (XI_U|AccountRoles id son account
                (+
                    {"role-set-new-uri" : toggle}
                    (remove "role-set-new-uri" (UR_CA|R id son account))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|Transfer (id:string son:bool account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SECURE) 
            (XI_U|AccountRoles id son account
                (+
                    {"role-transfer" : toggle}
                    (remove "role-transfer" (UR_CA|R id son account))
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_U|VerumRoles (id:string son:bool rp:integer aor:bool account:string)
        (P|UEV_IMC)
        (if (contains rp [5 6 10])
            (if aor
                (with-capability (SECURE)
                    (cond
                        ((= rp 5) (XI_U|VerumRole5 id son account))
                        ((= rp 6) (XI_U|VerumRole6 id son account))
                        ((= rp 10) (XI_U|VerumRole10 id son account))
                        true
                    )
                )
                true
            )
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (current-verum-chain:[string] (URv_GetVerumChain id son rp))
                    (ul:[string] (ref-U|DALOS::UCv_NewRoleList current-verum-chain account aor))
                )
                (with-capability (SECURE)
                    (cond
                        ((= rp 1) (XI_U|VerumRole1 id son ul))
                        ((= rp 2) (XI_U|VerumRole2 id son ul))
                        ((= rp 3) (XI_U|VerumRole3 id son ul))
                        ((= rp 4) (XI_U|VerumRole4 id son ul))
                        ((= rp 7) (XI_U|VerumRole7 id son ul))
                        ((= rp 8) (XI_U|VerumRole8 id son ul))
                        ((= rp 9) (XI_U|VerumRole9 id son ul))
                        ((= rp 11) (XI_U|VerumRole11 id son ul))
                        true
                    )
                )
            )
        )
    )
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_W|Supply (account:string id:string son:bool nonce-value:integer amount:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (tbl (if son DPSF|T|AccountSupplies DPNF|T|AccountSupplies))
                (ki:string (concat [account BAR id BAR (format "{}" [nonce-value])]) )
            )
            (with-default-read tbl ki
                (ref-DPDC-UDC::UDC_DPDC|AccountSupply account id nonce-value -1)
                {"account"  := a
                ,"id"       := b
                ,"nonce"    := c
                ,"supply"   := d}
                (write tbl ki
                    (ref-DPDC-UDC::UDC_DPDC|AccountSupply a b c amount)
                )
            )
            
        )
    )
    ;;{5.7}  User [A/C]
    ;;get keys with (URH_AS-Keys son)
    (defun AU_SFTs (kis:[string])
        (with-capability (AHU)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (map
                    (lambda
                        (ki:string)
                        (let
                            (
                                (str-lst:[string] (ref-U|LST::UC_SplitString BAR ki))
                                (l:integer (length str-lst))
                                (account:string 
                                    (at 0 str-lst))
                                
                                (id:string 
                                    (if (= l 3)
                                        (at 1 str-lst)
                                        (concat [(at 1 str-lst) BAR (at 2 str-lst)])
                                    )
                                )
                                (read-nonce:string
                                    (if (= l 3)
                                        (at 2 str-lst)
                                        (at 3 str-lst)
                                    )
                                )   
                                (nonce:integer (UC_ParseSignedInteger read-nonce))
                            )
                            (update DPSF|T|AccountSupplies ki
                                {"account"  : account
                                ,"id"       : id
                                ,"nonce"    : nonce}
                            )
                        )
                    )
                    kis
                )
            )
        )
    )
    (defun AU_NFTs (kis:[string])
        (with-capability (AHU)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (map
                    (lambda
                        (ki:string)
                        (let
                            (
                                (str-lst:[string] (ref-U|LST::UC_SplitString BAR ki))
                                (account:string (at 0 str-lst))
                                (id:string  (at 1 str-lst)) 
                                (nonce:integer (UC_ParseSignedInteger (at 2 str-lst)))
                            )
                            (update DPNF|T|AccountSupplies ki
                                {"account"  : account
                                ,"id"       : id
                                ,"nonce"    : nonce}
                            )
                        )
                    )
                    kis
                )
            )
        )
    )
    (defun AU_Accounts (keyz:[string] son:bool)
        @doc "Get <keyz> with <(keys (if son DPSF|T|Account DPNF|T|Account))>, or update one a time"
        (with-capability (AHU)
            (map
                (lambda
                    (idx:integer)
                    (AU_Account (at idx keyz) son)
                )
                (enumerate 0 (- (length keyz) 1))
            )
        )
    )
    (defun AU_Account (ky:string son:bool)
        (require-capability (SECURE))
        (update (if son DPSF|T|Account DPNF|T|Account) ky
            {"id"       : (drop -163 ky)
            ,"account"  : (take -162 ky)}
        )
    )
    (defun AU_Properties (ids:[string] son:bool)
        @doc "Get <ids> with <(keys (if son DPSF|T|Properties DPNF|T|Properties))>, or update one a time"
        (with-capability (AHU)
            (map
                (lambda
                    (idx:integer)
                    (AU_Property (at idx ids) son)
                )
                (enumerate 0 (- (length ids) 1))
            )
        )
    )
    (defun AU_Property (id:string son:bool)
        (require-capability (SECURE))
        (update (if son DPSF|T|Properties DPNF|T|Properties) id
            {"id"       : id}
        )
    )
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string entity-id:string son:bool logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is collectable \
            \ ownership -- DPDC|C>UPDATE-BRD calls CAP_Owner, which enforces on the DERIVED \
            \ (UR_OwnerKonto entity-id son) and names no actor: HANDOFF 4g. \
            \ UEV_ExecutorIsOwnerKonto supplies the missing half and the ownership enforce is \
            \ KEPT, not replaced."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor entity-id son)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
                (owner:string (UR_OwnerKonto entity-id son))
                (multiplier:decimal (if son 4.0 5.0))
            )
            (with-capability (DPDC|C>UPDATE-BRD entity-id son)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (URCi_UpdatePendingBranding entity-id son)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string executor:string entity-id:string son:bool months:integer)
        @doc "ATTRIBUTION: as C_UpdatePendingBranding -- CAP_Owner enforces on the DERIVED \
            \ (UR_OwnerKonto entity-id son), so the actor is supplied by \
            \ UEV_ExecutorIsOwnerKonto. (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor entity-id son)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
                (owner:string (UR_OwnerKonto entity-id son))
                (stoa-payment:decimal
                    (with-capability (DPDC|C>UPGRADE-BRD entity-id son)
                        (ref-BRD::XE_UpgradeBranding entity-id owner months)
                    )
                )
            )
            (ref-IGNIS::XB_CollectStoaWithTrigger patron stoa-payment false)
        )
    )

)



;;DPSF





;;DPNF

;; --- tables for 02_DPDC.pact (12 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table DPSF|T|Properties)
;; (create-table DPSF|T|Nonces)
;; (create-table DPSF|T|VerumRoles)
;; (create-table DPSF|T|Account)
;; (create-table DPSF|T|AccountSupplies)
;; (create-table DPNF|T|Properties)
;; (create-table DPNF|T|Nonces)
;; (create-table DPNF|T|VerumRoles)
;; (create-table DPNF|T|Account)
;; (create-table DPNF|T|AccountSupplies)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact ==========
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcCreateV2
    @doc "Exposes Collectables Create Functions, containining the Credit and Debit Variants"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;
    ;;  [UC]
    ;;
    (defun UC_AndTruths:bool (truths:[bool]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URCi]
    ;;
    (defun URCi_RegisterCollectablesPrice:decimal (id:string son:bool amounts:[integer]))
    (defun URCi_CreateNewNonces:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool amounts:[integer]))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_NonceDataForCreation (ind:object{DpdcUdcV2.DPDC|NonceData}))
    (defun UEV_NonceType (nonce:integer fragments-or-native:bool))
    (defun UEV_NonceTypeMapper (nonces:[integer] fragments-or-native:bool))
    (defun UEV_HybridNonces:object{OuronetIntegersV2.SplitIntegers} (nonces:[integer]))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XE_CreditSFT-FragmentNonce (account:string id:string nonce:integer amount:integer))
    (defun XE_CreditNFT-FragmentNonce (account:string id:string nonce:integer amount:integer))
    (defun XE_DebitSFT-FragmentNonce (account:string id:string nonce:integer amount:integer wipe-mode:bool))
    (defun XE_DebitNFT-FragmentNonce (account:string id:string nonce:integer amount:integer wipe-mode:bool))
    ;;
    (defun XB_CreditSFT-Nonce (account:string id:string nonce:integer amount:integer))
    (defun XB_CreditNFT-Nonce (account:string id:string nonce:integer amount:integer))
    (defun XE_DebitSFT-Nonce (account:string id:string nonce:integer amount:integer wipe-mode:bool))
    (defun XE_DebitNFT-Nonce (account:string id:string nonce:integer amount:integer wipe-mode:bool))
    ;;
    (defun XE_CreditSFT-FragmentNonces (account:string id:string nonces:[integer] amounts:[integer]))
    (defun XE_CreditNFT-FragmentNonces (account:string id:string nonces:[integer] amounts:[integer]))
    (defun XE_DebitSFT-FragmentNonces (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool))
    (defun XE_DebitNFT-FragmentNonces (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool))
    ;;
    (defun XB_CreditSFT-Nonces (account:string id:string nonces:[integer] amounts:[integer]))
    (defun XB_CreditNFT-Nonces (account:string id:string nonces:[integer] amounts:[integer]))
    (defun XE_DebitSFT-Nonces (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool))
    (defun XE_DebitNFT-Nonces (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool))
    ;;
    (defun XE_CreditSFT-HybridNonces (account:string id:string nonces:[integer] amounts:[integer]))
    (defun XE_CreditNFT-HybridNonces (account:string id:string nonces:[integer] amounts:[integer]))
    (defun XE_DebitSFT-HybridNonces (account:string id:string nonces:[integer] amounts:[integer]))
    (defun XE_DebitNFT-HybridNonces (account:string id:string nonces:[integer] amounts:[integer]))
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_CreateNewNonce:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string
            id:string son:bool nonce-class:integer amount:integer
            input-nonce-data:object{DpdcUdcV2.DPDC|NonceData} sft-set-mode:bool
        )
    )
    (defun C_CreateNewNonces:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string
            id:string son:bool amounts:[integer]
            input-nonce-datas:[object{DpdcUdcV2.DPDC|NonceData}]
        )
    )

)
;;
(module DPDC-C GOV
    @doc "DPDC-C is the collectables create/credit/debit engine, implementing DpdcCreateV2 \
        \ and OuronetPolicyV2. It registers new nonces on a collection \
        \ (C_CreateNewNonce/C_CreateNewNonces) and provides the XE_/XB_ credit and debit \
        \ primitives for native and fragment (negative, /1000) nonces across SFT and NFT, \
        \ single/multi/hybrid, with a capability-dispatch matrix that selects the right \
        \ guard per nonce/amount shape. Supply writes go through DPDC and NFT-holder \
        \ updates; it returns IGNIS OutputCumulators for billing."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcCreateV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-C                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-C_ADMIN)))
    (defcap GOV|DPDC-C_ADMIN ()                         (enforce-guard GOV|MD_DPDC-C))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|DPDC-C|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-C|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DPDC-C_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPDC-C_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|DPDC-C_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|DPDC-C_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (mg:guard (create-capability-guard (P|DPDC-C|CALLER)))
            )
            (ref-P|DPDC::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;Register Nonces
    (defcap DPDC-C|C>REGISTER-SINGLE-NONCE
        (executor:string id:string son:bool amount:integer ind:object{DpdcUdcV2.DPDC|NonceData} sft-set-mode:bool)
        @event
        (compose-capability (DPDC-C|C>REGISTER-NONCES executor id son [amount] [ind] sft-set-mode))
    )
    (defcap DPDC-C|C>REGISTER-MULTIPLE-NONCES
        (executor:string id:string son:bool amounts:[integer] input-nonce-datas:[object{DpdcUdcV2.DPDC|NonceData}])
        @event
        (let
            (
                (l1:integer (length amounts))
            )
            (enforce (> l1 1) "Invalid Input variable length for a Multi Nonce Creation Capability")
            (compose-capability (DPDC-C|C>REGISTER-NONCES executor id son amounts input-nonce-datas false))
        )
    )
    (defun UEV_ExecutorIsCreateRole (executor:string id:string son:bool)
        @doc "BINDS <executor> to the collectable's CREATE-ROLE account, (UR_Verum5 id son). \
            \ \
            \ WHY THIS IS UNCONDITIONAL WHILE THE OWNERSHIP ENFORCE BESIDE IT IS NOT. \
            \ DPDC-C|C>REGISTER-NONCES runs CAP_EnforceAccountOwnership on that same derived \
            \ account only when NOT (son=false AND sft-set-mode) -- the bypass exists for \
            \ 08_DPDC-S's NFT-set path, where a nonce is spawned as an internal consequence of \
            \ an action DPDC-S has already authorised, and demanding the role holder's SIGNATURE \
            \ there would be wrong: the module is acting, not the role holder. \
            \ \
            \ A BINDER IS AN EQUALITY CHECK, NOT A SIGNATURE CHECK. Running it on both branches \
            \ therefore adds no authority requirement whatsoever -- it demands only that the \
            \ caller NAME the account the operation is really attributed to, which the internal \
            \ caller can compute as easily as this function can. So attribution becomes total \
            \ while the deliberate signature bypass is left exactly as it was. \
            \ \
            \ Mirroring the condition instead would have left the executor DECORATIVE on the \
            \ internal path -- a name nobody checks, which the canon rates worse than absent. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (enforce (= executor (ref-DPDC::UR_Verum5 id son))
                "Executor is not the Collectable Create-Role account")
        )
    )
    (defcap DPDC-C|C>REGISTER-NONCES
        (executor:string id:string son:bool amounts:[integer] input-nonce-datas:[object{DpdcUdcV2.DPDC|NonceData}] sft-set-mode:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (l1:integer (length amounts))
                (l2:integer (length input-nonce-datas))
                (msg:string
                    (if (= l1 1)
                        "a single Nonce"
                        "multiple Nonces"
                    )
                )
                (r-nft-create-account:string (ref-DPDC::UR_Verum5 id son))
            )
            (enforce (= l1 l2) (format "Incompatible Input Data for Registering {}" [msg]))
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (amount:integer (at idx amounts))
                            (input-nonce-data:object{DpdcUdcV2.DPDC|NonceData} (at idx input-nonce-datas))
                        )
                        (UEV_NonceDataForCreation input-nonce-data)
                        ;;Amount enforcement
                        (if son
                            (if sft-set-mode
                                ;;UNREACHABLE -- needs son=TRUE *and* sft-set-mode=TRUE, a combination
                                ;;no caller passes: the only sft-set-mode=TRUE site is the NFT set path
                                ;;(08_DPDC-S.pact:1345), where son is FALSE. And the SFT set path does
                                ;;not come through here at all -- C_MakeSemiFungibleSet credits an
                                ;;already-existing set nonce via XB_CreditSFT-Nonce rather than creating
                                ;;one, so the case this guard names is handled by another function.
                                ;;Proof in REPL/modules/DPDC.repl, the note after <<DPDC-G15>>.
                                (enforce (= amount 0) (format "When Defining an SFT Set, {} must be equal to 0" [amount]))
                                (enforce (>= amount 0) (format "For an SFT Collectable the {} must be greater or equal to 0" [amount]))
                            )
                            ;;UNREACHABLE -- needs son=FALSE with amount != 1, and both son=FALSE
                            ;;callers pass the LITERAL 1 (TS02-C2.pact:397 and 08_DPDC-S.pact:1345).
                            ;;Proof in REPL/modules/DPDC.repl, the note after <<DPDC-G15>>.
                            (enforce (= amount 1) (format "For an NFT Collectable the {} must be equal to 1" [amount]))
                        )
                    )
                )
                (enumerate 0 (- l2 1))
            )
            ;;ATTRIBUTION runs on BOTH branches; the SIGNATURE check keeps its bypass. See
            ;;UEV_ExecutorIsCreateRole's @doc -- an equality check adds no authority requirement,
            ;;so making it total costs the internal NFT-set path nothing and stops the executor
            ;;being decorative on exactly the branch where nothing else looks at it.
            (UEV_ExecutorIsCreateRole executor id son)
            (if (not (and (not son) sft-set-mode))
                (ref-DALOS::CAP_EnforceAccountOwnership r-nft-create-account)                    
                true
            )
            (compose-capability (P|DPDC-C|CALLER))
        )
    )
    ;;Single-Credit
    (defcap DPSF|C>CREDIT-FRAGMENT-NONCE (id:string nonce:integer)
        (compose-capability (DPDC-C|C>SINGLE-CREDIT id true nonce true))
    )
    (defcap DPNF|C>CREDIT-FRAGMENT-NONCE (id:string nonce:integer amount:integer)
        (UEV_FragmentCreditAmount amount)
        (compose-capability (DPDC-C|C>SINGLE-CREDIT id false nonce true))
    )
    (defcap DPSF|C>CREDIT-NONCE (id:string nonce:integer)
        (compose-capability (DPDC-C|C>SINGLE-CREDIT id true nonce false))
    )
    (defcap DPNF|C>CREDIT-NONCE (id:string nonce:integer amount:integer)
        (enforce (= amount 1) "Credit amount is must be 1 for NFTs")
        (compose-capability (DPDC-C|C>SINGLE-CREDIT id false nonce false))
    )
    (defcap DPDC-C|C>SINGLE-CREDIT (id:string son:bool nonce:integer fragments-or-native:bool)
        (UEV_NonceType nonce fragments-or-native)
        (compose-capability (P|DPDC-C|CALLER))
    )
    ;;
    ;;Multi-Credit
    (defcap DPSF|C>CREDIT-FRAGMENT-NONCES (id:string nonces:[integer] amounts:[integer])
        (compose-capability (DPDC-C|C>MULTI-CREDIT id true nonces amounts true))
    )
    (defcap DPNF|C>CREDIT-FRAGMENT-NONCES (id:string nonces:[integer] amounts:[integer])
        (map (lambda (a:integer) (UEV_FragmentCreditAmount a)) amounts)
        (compose-capability (DPDC-C|C>MULTI-CREDIT id false nonces amounts true))
    )
    (defcap DPSF|C>CREDIT-NONCES (id:string nonces:[integer] amounts:[integer])
        (compose-capability (DPDC-C|C>MULTI-CREDIT id true nonces amounts false))
    )
    (defcap DPNF|C>CREDIT-NONCES (id:string nonces:[integer] amounts:[integer])
        (compose-capability (DPDC-C|C>MULTI-CREDIT id false nonces amounts false))
        (enforce (= amounts (make-list (length amounts) 1)) "Invalid Amounts for NFT Crediting")
    )
    (defcap DPDC-C|C>MULTI-CREDIT (id:string son:bool nonces:[integer] amounts:[integer] fragments-or-native:bool)
        (UEV_NonceTypeMapper nonces fragments-or-native)
        (compose-capability (DPDC-C|CX>MULTI-CREDIT id son nonces amounts))
    )
    ;;
    ;;Hybrid Multi Credit
    (defcap DPSF|C>CREDIT-HYBRID-NONCES (id:string nonces:[integer] amounts:[integer])
        (compose-capability (DPDC|C>HYBRID-MULTI-CREDIT id true nonces amounts))
    )
    (defcap DPNF|C>CREDIT-HYBRID-NONCES (id:string nonces:[integer] amounts:[integer])
        ;; DPDC Audit #24M: only the fragment (negative) legs carry a real, amount-driven credit —
        ;; the native (positive) legs are unaffected by <amounts> here (XI_MappedUpdateOwnerNFT hardcodes
        ;; native NFT supply to 1 regardless of the input value), so only the fragment legs need the
        ;; positive-multiple-of-1000 check.
        (map
            (lambda
                (idx:integer)
                (if (< (at idx nonces) 0)
                    (UEV_FragmentCreditAmount (at idx amounts))
                    true
                )
            )
            (enumerate 0 (- (length nonces) 1))
        )
        (compose-capability (DPDC|C>HYBRID-MULTI-CREDIT id false nonces amounts))
    )
    (defcap DPDC|C>HYBRID-MULTI-CREDIT (id:string son:bool nonces:[integer] amounts:[integer])
        (UEV_HybridNonces nonces)
        (compose-capability (DPDC-C|CX>MULTI-CREDIT id son nonces amounts))
    )
    (defcap DPDC-C|CX>MULTI-CREDIT (id:string son:bool nonces:[integer] amounts:[integer])
        (let
            (
                (l1:integer (length nonces))
                (l2:integer (length amounts))
            )
            (enforce (= l1 l2) (format "Nonces {} are incompatible with {} Amounts for Crediting" [nonces amounts]))
            (compose-capability (P|DPDC-C|CALLER))
        )
    )
    ;;
    ;;
    ;;Single Debit
    (defcap DPSF|C>DEBIT-FRAGMENT-NONCE (account:string id:string nonce:integer amount:integer wipe-mode:bool)
        (compose-capability (DPDC-C|C>SINGLE-DEBIT account id true nonce amount true wipe-mode))
    )
    (defcap DPNF|C>DEBIT-FRAGMENT-NONCE (account:string id:string nonce:integer amount:integer wipe-mode:bool)
        (compose-capability (DPDC-C|C>SINGLE-DEBIT account id false nonce amount true wipe-mode))
    )
    ;;
    (defcap DPSF|C>DEBIT-NONCE (account:string id:string nonce:integer amount:integer wipe-mode:bool)
        (compose-capability (DPDC-C|C>SINGLE-DEBIT account id true nonce amount false wipe-mode))
    )
    (defcap DPNF|C>DEBIT-NONCE (account:string id:string nonce:integer amount:integer wipe-mode:bool)
        (compose-capability (DPDC-C|C>SINGLE-DEBIT account id false nonce amount false wipe-mode))
    )
    (defcap DPDC-C|C>SINGLE-DEBIT 
        (account:string id:string son:bool nonce:integer amount:integer fragments-or-native:bool wipe-mode:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (if wipe-mode
                (ref-DPDC::CAP_Owner id son)
                (ref-DALOS::CAP_EnforceAccountOwnership account)
            )
            (ref-DPDC::UEV_NonceQuantityInclusion account id son nonce amount)
            ;;
            (UEV_NonceType nonce fragments-or-native)
            ;;
            (compose-capability (P|DPDC-C|CALLER))
        )
    )
    ;;Multi-Debit
    (defcap DPSF|C>DEBIT-FRAGMENT-NONCES (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        (compose-capability (DPDC|C>MULTI-DEBIT account id true nonces amounts true wipe-mode))
    )
    (defcap DPNF|C>DEBIT-FRAGMENT-NONCES (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        (compose-capability (DPDC|C>MULTI-DEBIT account id false nonces amounts true wipe-mode))
    )
    (defcap DPSF|C>DEBIT-NONCES (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        (compose-capability (DPDC|C>MULTI-DEBIT account id true nonces amounts false wipe-mode))
    )
    (defcap DPNF|C>DEBIT-NONCES (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        (compose-capability (DPDC|C>MULTI-DEBIT account id false nonces amounts false wipe-mode))
    )
    (defcap DPDC|C>MULTI-DEBIT 
        (account:string id:string son:bool nonces:[integer] amounts:[integer] fragments-or-native:bool wipe-mode:bool)
        (UEV_NonceTypeMapper nonces fragments-or-native)
        (compose-capability (DPDC|CX>MULTI-DEBIT account id son nonces amounts wipe-mode))
        
    )
    ;;Hybrid Multi Debit
    (defcap DPSF|C>DEBIT-HYBRID-NONCES (account:string id:string nonces:[integer] amounts:[integer])
        (compose-capability (DPDC|CX>MULTI-DEBIT account id true nonces amounts false))
    )
    (defcap DPNF|C>DEBIT-HYBRID-NONCES (account:string id:string nonces:[integer] amounts:[integer])
        (compose-capability (DPDC|CX>MULTI-DEBIT account id false nonces amounts false))
    )
    (defcap DPDC|CX>MULTI-DEBIT 
        (account:string id:string son:bool nonces:[integer] amounts:[integer] wipe-mode:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (l1:integer (length nonces))
                (l2:integer (length amounts))
            )
            (enforce (= l1 l2) (format "Nonces {} and Amounts {} are invalid for Operation" [nonces amounts]))
            (if wipe-mode
                (ref-DPDC::CAP_Owner id son)
                (ref-DALOS::CAP_EnforceAccountOwnership account)
            )
            (ref-DPDC::UEV_NonceQuantityInclusionMapper account id son nonces amounts)
            (compose-capability (P|DPDC-C|CALLER))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_AndTruths:bool (truths:[bool])
        (fold (and) true truths)
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URCi_RegisterCollectablesPrice:decimal
        (id:string son:bool amounts:[integer])
        @doc "Single-source issue price for collectable creation: \
            \ smallest * sum(amounts), with a /1000 discount for a first Elite (E|) \
            \ SFT nonce (son & NoncesUsed = 0). Used by both the XI_RegisterCollectables \
            \ exec write and the INFO preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (nu:integer (ref-DPDC::UR_NoncesUsed id son))
                (s-amounts:integer (fold (+) 0 amounts))
                (smallest:decimal (ref-IGNIS::UC_IgnisLeg "tier-smallest"))
                (ft:string (take 2 id))
                (raw-price:decimal (* smallest (dec s-amounts)))
            )
            (if (fold (and) true [(= ft "E|") son (= nu 0)])
                (/ raw-price 1000.0)
                raw-price
            )
        )
    )
    (defun URCi_CreateNewNonces:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool amounts:[integer])
        @doc "Cost preview for C_CreateNewNonce/C_CreateNewNonces: issue construct \
            \ priced via URCi_RegisterCollectablesPrice on the owner-konto payer, \
            \ empty output list (created collectable names are exec-only write products)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URCi_RegisterCollectablesPrice id son amounts)
                (ref-DPDC::UR_OwnerKonto id son)
                (ref-IGNIS::URC_IsVirtualGasZero)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_NonceDataForCreation (ind:object{DpdcUdcV2.DPDC|NonceData})
        @doc "Validates the ind for creation of new nonce"
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (empty-data-dc:object{DpdcUdcV2.DPDC|NonceData}
                    (ref-DPDC-UDC::UDC_ZeroNonceData)
                )
                (royalty:decimal (at "royalty" ind))
                (ignis:decimal (at "ignis" ind))
            )
            (enforce (!= empty-data-dc ind) "Incorrect Fragmentation Data")
            (ref-DPDC::UEV_Royalty royalty)     ;; Royalty can be set at -1.0 enabling Volumetric Royalty Fee.
            (ref-DPDC::UEV_IgnisRoyalty ignis)
            ;; DPDC Audit #12Hb — bound the previously-unvalidated free-text/metadata fields.
            (ref-DPDC::UEV_Name (at "name" ind))
            (ref-DPDC::UEV_Description (at "description" ind))
            (ref-DPDC::UEV_MetaDataBag (at "meta-data" (at "meta-data" ind)))
            (ref-DPDC::UEV_AssetType (at "asset-type" ind))
            (ref-DPDC::UEV_UriData (at "uri-primary" ind))
            (ref-DPDC::UEV_UriData (at "uri-secondary" ind))
            (ref-DPDC::UEV_UriData (at "uri-tertiary" ind))
        )
    )
    ;;
    (defun UEV_NonceType (nonce:integer fragments-or-native:bool)
        (if fragments-or-native
            (enforce (< nonce 0) "Only Negative Nonces Allowed for Operation")
            (enforce (> nonce 0) "Only Positive Nonces Allowed for Operation")
        )
    )
    ;;
    (defun UEV_NonceTypeMapper (nonces:[integer] fragments-or-native:bool)
        (map
            (lambda
                (idx:integer)
                (UEV_NonceType (at idx nonces) fragments-or-native)
            )
            (enumerate 0 (- (length nonces) 1))
        )
    )
    (defun UEV_HybridNonces:object{OuronetIntegersV2.SplitIntegers} (nonces:[integer])
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                ;;
                (split-nonces:object{OuronetIntegersV2.SplitIntegers} (ref-U|INT::UC_SplitIntegerList nonces))
                (negative-nonces:[integer] (at "negative" split-nonces))
                (positive-nonces:[integer] (at "positive" split-nonces))
                (l3:integer (length negative-nonces))
                (l4:integer (length positive-nonces))
            )
            (enforce (and (!= l3 0) (!= l4 0)) (format "Nonces {} are invalid Hybrid Nonces" [nonces]))
            split-nonces
        )
    )
    (defun UEV_Amount (amount:integer)
        @doc "Floor for every SFT/fragment credit or debit quantity. Zero is legal (nonce-creation \
            \ genesis supply, e.g. EQUITY's zero-initial-supply tier nonces) — negative is never legal, \
            \ it inverts the credit/debit direction in XIv_CreditOrDebitDPDC. See DPDC Audit #1C."
        (enforce (>= amount 0) "Amount cannot be negative")
    )
    (defun UEV_FragmentCreditAmount (amount:integer)
        @doc "An NFT itself is always quantity 1, but its fragments exist in units of 1000 per whole \
            \ NFT (see DPDC-F::C_MakeFragments' <f-amount = 1000 * amount>) — every NFT fragment \
            \ credit amount must be a positive multiple of 1000. Today's only caller (C_MakeFragments) \
            \ can only ever produce exactly 1000 (forced by the upstream native amount=1 rule), so this \
            \ is a defense-in-depth backstop, not a live-exploit fix. See DPDC Audit #24M."
        (enforce
            (and (> amount 0) (= (mod amount 1000) 0))
            (format "NFT fragment credit amount of {} must be a positive multiple of 1000" [amount])
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;T3x20
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPSF|C>CREDIT-FRAGMENT-NONCE
    (defun XE_CreditSFT-FragmentNonce (account:string id:string nonce:integer amount:integer)
        (P|UEV_IMC)
        (with-capability (DPSF|C>CREDIT-FRAGMENT-NONCE id nonce)
            (XI_CreditSFT account id [nonce] [amount])
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPNF|C>CREDIT-FRAGMENT-NONCE
    (defun XE_CreditNFT-FragmentNonce (account:string id:string nonce:integer amount:integer)
        (P|UEV_IMC)
        (with-capability (DPNF|C>CREDIT-FRAGMENT-NONCE id nonce amount)
            (XI_CreditNFT account id [nonce] [amount])
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPSF|C>DEBIT-FRAGMENT-NONCE
    (defun XE_DebitSFT-FragmentNonce (account:string id:string nonce:integer amount:integer wipe-mode:bool)
        (P|UEV_IMC)
        (with-capability (DPSF|C>DEBIT-FRAGMENT-NONCE account id nonce amount wipe-mode)
            (XI_DebitSFT account id [nonce] [amount] wipe-mode)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPNF|C>DEBIT-FRAGMENT-NONCE
    (defun XE_DebitNFT-FragmentNonce (account:string id:string nonce:integer amount:integer wipe-mode:bool)
        (P|UEV_IMC)
        (with-capability (DPNF|C>DEBIT-FRAGMENT-NONCE account id nonce amount wipe-mode)
            (XI_DebitNFT account id [nonce] [amount] wipe-mode)
        )
    )
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPSF|C>CREDIT-NONCE
    (defun XB_CreditSFT-Nonce (account:string id:string nonce:integer amount:integer)
        (P|UEV_IMC)
        (with-capability (DPSF|C>CREDIT-NONCE id nonce)
            (XI_CreditSFT account id [nonce] [amount])
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPNF|C>CREDIT-NONCE
    (defun XB_CreditNFT-Nonce (account:string id:string nonce:integer amount:integer)
        (P|UEV_IMC)
        (with-capability (DPNF|C>CREDIT-NONCE id nonce amount)
            (XI_CreditNFT account id [nonce] [amount])
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPSF|C>DEBIT-NONCE
    (defun XE_DebitSFT-Nonce (account:string id:string nonce:integer amount:integer wipe-mode:bool)
        (P|UEV_IMC)
        (with-capability (DPSF|C>DEBIT-NONCE account id nonce amount wipe-mode)
            (XI_DebitSFT account id [nonce] [amount] wipe-mode)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPNF|C>DEBIT-NONCE
    (defun XE_DebitNFT-Nonce (account:string id:string nonce:integer amount:integer wipe-mode:bool)
        (P|UEV_IMC)
        (with-capability (DPNF|C>DEBIT-NONCE account id nonce amount wipe-mode)
            (XI_DebitNFT account id [nonce] [amount] wipe-mode)
        )
    )
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPSF|C>CREDIT-FRAGMENT-NONCES
    (defun XE_CreditSFT-FragmentNonces (account:string id:string nonces:[integer] amounts:[integer])
        (P|UEV_IMC)
        (with-capability (DPSF|C>CREDIT-FRAGMENT-NONCES id nonces amounts)
            (XI_CreditSFT account id nonces amounts)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPNF|C>CREDIT-FRAGMENT-NONCES
    (defun XE_CreditNFT-FragmentNonces (account:string id:string nonces:[integer] amounts:[integer])
        (P|UEV_IMC)
        (with-capability (DPNF|C>CREDIT-FRAGMENT-NONCES id nonces amounts)
            (XI_CreditNFT account id nonces amounts)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPSF|C>DEBIT-FRAGMENT-NONCES
    (defun XE_DebitSFT-FragmentNonces (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        (P|UEV_IMC)
        (with-capability (DPSF|C>DEBIT-FRAGMENT-NONCES account id nonces amounts wipe-mode)
            (XI_DebitSFT account id nonces amounts wipe-mode)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPNF|C>DEBIT-FRAGMENT-NONCES
    (defun XE_DebitNFT-FragmentNonces (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        (P|UEV_IMC)
        (with-capability (DPNF|C>DEBIT-FRAGMENT-NONCES account id nonces amounts wipe-mode)
            (XI_DebitNFT account id nonces amounts wipe-mode)
        )
    )
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPSF|C>CREDIT-NONCES
    (defun XB_CreditSFT-Nonces (account:string id:string nonces:[integer] amounts:[integer])
        (P|UEV_IMC)
        (with-capability (DPSF|C>CREDIT-NONCES id nonces amounts)
            (XI_CreditSFT account id nonces amounts)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPNF|C>CREDIT-NONCES
    (defun XB_CreditNFT-Nonces (account:string id:string nonces:[integer] amounts:[integer])
        (P|UEV_IMC)
        (with-capability (DPNF|C>CREDIT-NONCES id nonces amounts)
            (XI_CreditNFT account id nonces amounts)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPSF|C>DEBIT-NONCES
    (defun XE_DebitSFT-Nonces (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        (P|UEV_IMC)
        (with-capability (DPSF|C>DEBIT-NONCES account id nonces amounts wipe-mode)
            (XI_DebitSFT account id nonces amounts wipe-mode)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPNF|C>DEBIT-NONCES
    (defun XE_DebitNFT-Nonces (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        (P|UEV_IMC)
        (with-capability (DPNF|C>DEBIT-NONCES account id nonces amounts wipe-mode)
            (XI_DebitNFT account id nonces amounts wipe-mode)
        )
    )
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPSF|C>CREDIT-HYBRID-NONCES
    (defun XE_CreditSFT-HybridNonces (account:string id:string nonces:[integer] amounts:[integer])
        (P|UEV_IMC)
        (with-capability (DPSF|C>CREDIT-HYBRID-NONCES id nonces amounts)
            (XI_CreditSFT account id nonces amounts)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPNF|C>CREDIT-HYBRID-NONCES
    (defun XE_CreditNFT-HybridNonces (account:string id:string nonces:[integer] amounts:[integer])
        (P|UEV_IMC)
        (with-capability (DPNF|C>CREDIT-HYBRID-NONCES id nonces amounts)
            (XI_CreditNFT account id nonces amounts)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPSF|C>DEBIT-HYBRID-NONCES
    (defun XE_DebitSFT-HybridNonces (account:string id:string nonces:[integer] amounts:[integer])
        (P|UEV_IMC)
        (with-capability (DPSF|C>DEBIT-HYBRID-NONCES account id nonces amounts)
            (XI_DebitSFT account id nonces amounts false)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPNF|C>DEBIT-HYBRID-NONCES
    (defun XE_DebitNFT-HybridNonces (account:string id:string nonces:[integer] amounts:[integer])
        (P|UEV_IMC)
        (with-capability (DPNF|C>DEBIT-HYBRID-NONCES account id nonces amounts)
            (XI_DebitNFT account id nonces amounts false)
        )
    )
    ;;
    ;;T2x4
    ;;Protection: Class 1 — Innate protection offered by XI_CreditCollectables
    (defun XI_CreditSFT (account:string id:string nonces:[integer] amounts:[integer])
        (XI_CreditCollectables account id true nonces amounts)
    )
    ;;Protection: Class 1 — Innate protection offered by XI_CreditCollectables
    (defun XI_CreditNFT (account:string id:string nonces:[integer] amounts:[integer])
        (XI_CreditCollectables account id false nonces amounts)
    )
    ;;
    ;;Protection: Class 1 — Innate protection offered by XI_DebitCollectables
    (defun XI_DebitSFT (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        (XI_DebitCollectables account id true nonces amounts wipe-mode)
    )
    ;;Protection: Class 1 — Innate protection offered by XI_DebitCollectables
    (defun XI_DebitNFT (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        (XI_DebitCollectables account id false nonces amounts wipe-mode)
    )
    ;;T1x2
    ;;Protection: Class 1 — Innate protection offered by XI_CreditOrDebitCollectables
    (defun XI_CreditCollectables (account:string id:string son:bool nonces:[integer] amounts:[integer])
        (XI_CreditOrDebitCollectables account id son nonces amounts true false)
    )
    ;;Protection: Class 1 — Innate protection offered by XI_CreditOrDebitCollectables
    (defun XI_DebitCollectables (account:string id:string son:bool nonces:[integer] amounts:[integer] wipe-mode:bool)
        (XI_CreditOrDebitCollectables account id son nonces amounts false wipe-mode)
    )
    ;;T0x1
    ;;Protection: Class 3 — Custom: DPNF|C>CREDIT-FRAGMENT-NONCE,
    ;;Protection:          DPNF|C>CREDIT-FRAGMENT-NONCES, DPNF|C>CREDIT-HYBRID-NONCES,
    ;;Protection:          DPNF|C>CREDIT-NONCE, DPNF|C>CREDIT-NONCES,
    ;;Protection:          DPNF|C>DEBIT-FRAGMENT-NONCE, DPNF|C>DEBIT-FRAGMENT-NONCES,
    ;;Protection:          DPNF|C>DEBIT-HYBRID-NONCES, DPNF|C>DEBIT-NONCE,
    ;;Protection:          DPNF|C>DEBIT-NONCES, DPSF|C>CREDIT-FRAGMENT-NONCE,
    ;;Protection:          DPSF|C>CREDIT-FRAGMENT-NONCES, DPSF|C>CREDIT-HYBRID-NONCES,
    ;;Protection:          DPSF|C>CREDIT-NONCE, DPSF|C>CREDIT-NONCES,
    ;;Protection:          DPSF|C>DEBIT-FRAGMENT-NONCE, DPSF|C>DEBIT-FRAGMENT-NONCES,
    ;;Protection:          DPSF|C>DEBIT-HYBRID-NONCES, DPSF|C>DEBIT-NONCE,
    ;;Protection:          DPSF|C>DEBIT-NONCES
    (defun XI_CreditOrDebitCollectables (account:string id:string son:bool nonces:[integer] amounts:[integer] cod:bool wipe-mode:bool)
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (split:object{OuronetIntegersV2.NonceSplitter} (ref-U|INT::UC_NonceSplitter nonces amounts))
                (negative-nonces:[integer] (at "negative-nonces" split))
                (positive-nonces:[integer] (at "positive-nonces" split))
                (negative-counterparts:[integer] (at "negative-counterparts" split))
                (positive-counterparts:[integer] (at "positive-counterparts" split))
                ;;
                (n0:integer (at 0 nonces))
                (a0:integer (at 0 amounts))
                (l1:integer (length nonces))
                (l2:integer (length amounts))
                (negatives:integer (length negative-nonces))
                (positives:integer (length positive-nonces))
                ;;
                (isg:bool (and (= l1 1) (= l2 1)))                  ;;iz-single
                (inn:bool (< n0 0))                                 ;;iz-nonce-negative
                (ong:bool (and (> negatives 0) (= positives 0)))    ;;only-negatives
                (onp:bool (and (> positives 0) (= negatives 0)))    ;;only-positives
            )
            (cond
                ;;SINGLE
                ;;Native Nonce
                ((UC_AndTruths [isg (not inn) cod son])                             (require-capability (DPSF|C>CREDIT-NONCE id n0)))
                ((UC_AndTruths [isg (not inn) cod (not son)])                       (require-capability (DPNF|C>CREDIT-NONCE id n0 a0)))
                ((UC_AndTruths [isg (not inn) (not cod) son])                       (require-capability (DPSF|C>DEBIT-NONCE account id n0 a0 wipe-mode)))
                ((UC_AndTruths [isg (not inn) (not cod) (not son)])                 (require-capability (DPNF|C>DEBIT-NONCE account id n0 a0 wipe-mode)))
                ;;Fragment Nonce
                ((UC_AndTruths [isg inn cod son])                                   (require-capability (DPSF|C>CREDIT-FRAGMENT-NONCE id n0)))
                ((UC_AndTruths [isg inn cod (not son)])                             (require-capability (DPNF|C>CREDIT-FRAGMENT-NONCE id n0 a0)))
                ((UC_AndTruths [isg inn (not cod) son])                             (require-capability (DPSF|C>DEBIT-FRAGMENT-NONCE account id n0 a0 wipe-mode)))
                ((UC_AndTruths [isg inn (not cod) (not son)])                       (require-capability (DPNF|C>DEBIT-FRAGMENT-NONCE account id n0 a0 wipe-mode)))
                ;;
                ;;MULTI
                ;;Native Nonces
                ((UC_AndTruths [(not isg) (not ong) onp cod son])                   (require-capability (DPSF|C>CREDIT-NONCES id nonces amounts)))
                ((UC_AndTruths [(not isg) (not ong) onp cod (not son)])             (require-capability (DPNF|C>CREDIT-NONCES id nonces amounts)))
                ((UC_AndTruths [(not isg) (not ong) onp (not cod) son])             (require-capability (DPSF|C>DEBIT-NONCES account id nonces amounts wipe-mode)))
                ((UC_AndTruths [(not isg) (not ong) onp (not cod) (not son)])       (require-capability (DPNF|C>DEBIT-NONCES account id nonces amounts wipe-mode)))
                ;;Fragment Nonces
                ((UC_AndTruths [(not isg) ong cod son])                             (require-capability (DPSF|C>CREDIT-FRAGMENT-NONCES id nonces amounts)))
                ((UC_AndTruths [(not isg) ong cod (not son)])                       (require-capability (DPNF|C>CREDIT-FRAGMENT-NONCES id nonces amounts)))
                ((UC_AndTruths [(not isg) ong (not cod) son])                       (require-capability (DPSF|C>DEBIT-FRAGMENT-NONCES account id nonces amounts wipe-mode)))
                ((UC_AndTruths [(not isg) ong (not cod) (not son)])                 (require-capability (DPNF|C>DEBIT-FRAGMENT-NONCES account id nonces amounts wipe-mode)))
                ;;Hybrid (Native and Fragment) Nonces
                ((UC_AndTruths [(not isg) (not ong) (not onp) cod son])             (require-capability (DPSF|C>CREDIT-HYBRID-NONCES id nonces amounts)))
                ((UC_AndTruths [(not isg) (not ong) (not onp) cod (not son)])       (require-capability (DPNF|C>CREDIT-HYBRID-NONCES id nonces amounts)))
                ((UC_AndTruths [(not isg) (not ong) (not onp) (not cod) son])       (require-capability (DPSF|C>DEBIT-HYBRID-NONCES account id nonces amounts)))
                ((UC_AndTruths [(not isg) (not ong) (not onp) (not cod) (not son)]) (require-capability (DPNF|C>DEBIT-HYBRID-NONCES account id nonces amounts)))
                ;; DPDC Audit #23M: fail closed, not open. The 16 branches above are exhaustive given
                ;; today's upstream invariants (UEV_NonceType/UEV_NonceTypeMapper) — this default only
                ;; fires if a future change weakens that guarantee, and it must hard-abort rather than
                ;; silently skip every require-capability check above and fall through to the write.
                ;;UNREACHABLE: an (enforce false) fail-closed DEFAULT. The 16 branches above are
                ;;exhaustive under UEV_NonceType / UEV_NonceTypeMapper, so no input reaches it --
                ;;which is the sanctioned failsafe shape (owner ruling, 2026-09-10: a default that
                ;;fires only if a branch is ever missed). Correct as written and not coverage.
                (enforce false (format "Unreachable nonce/amount shape for {} {}" [nonces amounts]))
            )
            (if cod
                (ref-DPDC::XE_DeployAccountWNE account id son)
                true
            )
            (if (and (> negatives 0) (= positives 0))
                ;; only negative nonces
                (XIv_MappedCreditOrDebitDPDC account id son negative-nonces negative-counterparts cod)
                (if (and (> positives 0) (= negatives 0))
                    ;;only positive nonces
                    (if son
                        ;;If SFT
                        (XIv_MappedCreditOrDebitDPDC account id son positive-nonces positive-counterparts cod)
                        ;;If NFT
                        (if cod
                            ;;If Credit
                            (XI_MappedUpdateOwnerNFT id positive-nonces account false)
                            ;;If Debit
                            (XI_MappedUpdateOwnerNFT id positive-nonces account true)
                        )
                    )
                    ;;positive and negative nonces
                    (do
                        (XIv_MappedCreditOrDebitDPDC account id son negative-nonces negative-counterparts cod)
                        (if son
                            (XIv_MappedCreditOrDebitDPDC account id son positive-nonces positive-counterparts cod)
                            (if cod
                                (XI_MappedUpdateOwnerNFT id positive-nonces account false)
                                (XI_MappedUpdateOwnerNFT id positive-nonces account true)
                            )
                        )
                    )
                )
            )
        )
    )
    ;;
    ;;Protection: Class 1 — Innate protection offered by XI_RegisterSingleNonce,
    ;;Protection:          XI_RegisterMultipleNonces, XB_CreditSFT-Nonce,
    ;;Protection:          XB_CreditNFT-Nonce, XB_CreditSFT-Nonces, XB_CreditNFT-Nonces
    (defun XI_RegisterCollectables:object{IgnisCollectorV3.OutputCumulator}
        (
            executor:string
            id:string son:bool nonce-classes:[integer] amounts:[integer]
            input-nonce-datas:[object{DpdcUdcV2.DPDC|NonceData}] sft-set-mode:bool
        )
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (owner:string (ref-DPDC::UR_OwnerKonto id son))
                ;;
                (l:integer (length amounts))
                (fnc:integer (at 0 nonce-classes))
                (isg:bool (= l 1))
                (output-account:string
                    (if (!= fnc 0)
                        (ref-DPDC::GOV|DPDC|SC_NAME)
                        (ref-DPDC::UR_Verum5 id son)
                    )
                )
                ;;
                ;;Compute Cumulator Parameters (price single-sourced via URCi)
                (price:decimal (URCi_RegisterCollectablesPrice id son amounts))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                ;;
                ;;Computing Nonces that will be generated
                (current-nonce:integer (ref-DPDC::UR_NoncesUsed id son))
                (nonces-to-be-created:[integer]
                    (take (- 0 l) (enumerate 0 (+ current-nonce l)))
                )
                (n0:integer (at 0 nonces-to-be-created))
                (a0:integer (at 0 amounts))
                ;;
                ;;Generating Collection Elements Names, by registering them
                (collectable-names:[string]
                    (if (= l 1)
                        [(XI_RegisterSingleNonce executor id son fnc (at 0 amounts) (at 0 input-nonce-datas) sft-set-mode)]
                        (XI_RegisterMultipleNonces executor id son nonce-classes amounts input-nonce-datas)
                    )
                )
            )
            ;;Credit Created Elements to <output-account>, which is either <creator-account> or <dpdc> account
            (cond
                ((UC_AndTruths [isg son ])              (XB_CreditSFT-Nonce output-account id n0 a0))
                ((UC_AndTruths [isg (not son)])         (XB_CreditNFT-Nonce output-account id n0 a0))
                ((UC_AndTruths [(not isg) son])         (XB_CreditSFT-Nonces output-account id nonces-to-be-created amounts))
                ((UC_AndTruths [(not isg) (not son)])   (XB_CreditNFT-Nonces output-account id nonces-to-be-created amounts))
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price owner trigger collectable-names)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC-C|C>REGISTER-MULTIPLE-NONCES
    (defun XI_RegisterMultipleNonces:[string]
        (
            executor:string
            id:string son:bool nonce-classes:[integer] amounts:[integer]
            input-nonce-datas:[object{DpdcUdcV2.DPDC|NonceData}]
        )
        ;;<executor> IS THREADED ONLY TO SATISFY THE CAPABILITY, and that is the whole reason
        ;;it is here. DPDC-C|C>REGISTER-*-NONCES gained an <executor> parameter at 03_DPDC-C's
        ;;turn, and a `require-capability` must name the capability EXACTLY as it was granted --
        ;;so every internal hop between the entrypoint and the require has to carry it. Missing
        ;;one does not fail the arity checker (which reads function calls, not capability
        ;;acquisitions); it fails at LOAD with "Attempted to apply a closure to too many
        ;;arguments", which is how this was found.
        (require-capability (DPDC-C|C>REGISTER-MULTIPLE-NONCES executor id son amounts input-nonce-datas))
        (with-capability (SECURE)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[string] idx:integer)
                        (let
                            (
                                (nonce-class:integer (at idx nonce-classes))
                                (amount:integer (at idx amounts))
                                (input-nonce-data:object{DpdcUdcV2.DPDC|NonceData} (at idx input-nonce-datas))
                            )
                            (ref-U|LST::UC_AppL acc
                                (XI_RegisterCollectionElement id son nonce-class amount input-nonce-data)
                            )
                        )
                    )
                    []
                    (enumerate 0 (- (length amounts) 1))
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPDC-C|C>REGISTER-SINGLE-NONCE
    (defun XI_RegisterSingleNonce:string
        (
            executor:string
            id:string son:bool nonce-class:integer amount:integer
            input-nonce-data:object{DpdcUdcV2.DPDC|NonceData} sft-set-mode:bool
        )
        (require-capability (DPDC-C|C>REGISTER-SINGLE-NONCE executor id son amount input-nonce-data sft-set-mode))
        (with-capability (SECURE)
            (XI_RegisterCollectionElement id son nonce-class amount input-nonce-data)
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RegisterCollectionElement:string
        (
            id:string son:bool nonce-class:integer amount:integer
            input-nonce-data:object{DpdcUdcV2.DPDC|NonceData}
        )
        (require-capability (SECURE))
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (new-element-nonce:integer (+ (ref-DPDC::UR_NoncesUsed id son) 1))
                (account-for-supply-registering:string (ref-DPDC::UR_Verum5 id son))
                (nonce-holder:string
                    (if son
                        BAR
                        (ref-I|OURONET::OI|UC_ShortAccount account-for-supply-registering)
                    )
                )
                (element:object{DpdcUdcV2.DPDC|NonceElement} 
                    (ref-DPDC-UDC::UDC_NonceElement
                        nonce-class
                        new-element-nonce
                        amount
                        nonce-holder
                        input-nonce-data
                        (ref-DPDC-UDC::UDC_ZeroNonceData)
                    )
                )
            )
            (ref-DPDC::XE_I|CollectionElement id son new-element-nonce element)
            (ref-DPDC::XE_U|NoncesUsed id son new-element-nonce)
            (format "{} <{}>" [amount (at "name" input-nonce-data)])
        )
    )
    ;;===========================================
    ;;
    ;;Protection: Class 1 — Innate protection offered by XE_U|NonceHolder, XE_W|Supply
    (defun XI_MappedUpdateOwnerNFT (id:string nonces:[integer] account:string iz-bar:bool)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (new-owner:string
                    (if iz-bar
                        BAR
                        account
                    )
                )
                (supply:integer
                    (if iz-bar 0 1)
                )
            )
            (map
                (lambda
                    (element:integer)
                    (do
                        (ref-DPDC::XE_U|NonceHolder id element new-owner)
                        (ref-DPDC::XE_W|Supply account id false element supply)
                        ;;
                    )
                    
                )
                nonces
                ;(enumerate 0 (- (length nonces) 1))
            )
        )
    )
    ;;Must account for exist/not-exist
    ;;Enforce: per-element-in-map -- XIv_MappedCreditOrDebitDPDC maps this over (at idx amounts), so
    ;;          UEV_Amount validates one element. Upstream, XI_CreditOrDebitCollectables dispatches to 16
    ;;          different require-capability branches; relocating would duplicate the check 16x.
    ;;Protection: Class 1 — Innate protection offered by XE_W|Supply
    (defun XIv_CreditOrDebitDPDC (account:string id:string son:bool nonce:integer amount:integer cod:bool)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (read-current-supply:integer (ref-DPDC::UR_AccountNonceSupply account id son nonce))
                (current-supply:integer 
                    (if (= read-current-supply -1)
                        0
                        read-current-supply
                    )
                )
                (new-supply:integer
                    (if cod
                        (+ current-supply amount)
                        (- current-supply amount)
                    )
                )
            )
            (UEV_Amount amount)
            (if (= current-supply 0)
                (enforce cod "Cannot Debit 0 Amounts!")
                true
            )
            (ref-DPDC::XE_W|Supply account id son nonce new-supply)
        )
    )
    ;;Enforce: 4 call sites inside XI_CreditOrDebitCollectables -- relocating the (= l1 l2) length check
    ;;          duplicates it 4x, which is strictly more code.
    ;;Protection: Class 1 — Innate protection offered by XIv_CreditOrDebitDPDC
    (defun XIv_MappedCreditOrDebitDPDC (account:string id:string son:bool nonces:[integer] amounts:[integer] cod:bool)
        (let
            (
                (l1:integer (length nonces))
                (l2:integer (length amounts))
            )
            (enforce (= l1 l2) "Invalid <nonces> and <amounts> lengths for CreditOrDebit Operation")
            (map
                (lambda
                    (idx:integer)
                    (XIv_CreditOrDebitDPDC account id son (at idx nonces) (at idx amounts) cod)
                )
                (enumerate 0 (- l1 1))
            )
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_CreateNewNonce:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string
            id:string son:bool nonce-class:integer amount:integer
            input-nonce-data:object{DpdcUdcV2.DPDC|NonceData} sft-set-mode:bool
        )
        @doc "Registers a single nonce on <id>. \
            \ \
            \ HANDOFF 4g: the authority is CAP_EnforceAccountOwnership on the DERIVED \
            \ (UR_Verum5 id son) -- the collectable create-role account -- and it names no actor. \
            \ UEV_ExecutorIsCreateRole supplies the missing half, and runs on BOTH branches of the \
            \ conditional ownership enforce because an equality check adds no authority \
            \ requirement. See that function @doc for why the signature bypass is left intact. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DPDC-C|C>REGISTER-SINGLE-NONCE executor id son amount input-nonce-data sft-set-mode)
            (XI_RegisterCollectables executor id son [nonce-class] [amount] [input-nonce-data] sft-set-mode)
        )
    )
    (defun C_CreateNewNonces:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string
            id:string son:bool amounts:[integer]
            input-nonce-datas:[object{DpdcUdcV2.DPDC|NonceData}]
        )
        @doc "Registers multiple nonces on <id>. \
            \ \
            \ HANDOFF 4g: the authority is CAP_EnforceAccountOwnership on the DERIVED \
            \ (UR_Verum5 id son) -- the collectable create-role account -- and it names no actor. \
            \ UEV_ExecutorIsCreateRole supplies the missing half, and runs on BOTH branches of the \
            \ conditional ownership enforce because an equality check adds no authority \
            \ requirement. See that function @doc for why the signature bypass is left intact. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DPDC-C|C>REGISTER-MULTIPLE-NONCES executor id son amounts input-nonce-datas)
            (XI_RegisterCollectables executor id son 
                (make-list (length input-nonce-datas) 0) 
                amounts input-nonce-datas false
            )
        )
    )

)

;; --- tables for 03_DPDC-C.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/04_DPDC-I.pact ==========
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcIssueV2
    @doc "Exposes Collectables Issue Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URCi]
    ;;
    (defun URCi_IssueCollectionPrice:decimal (son:bool))
    (defun URCi_IssueCollectionStoa:decimal (son:bool))
    (defun URCi_IssueDigitalCollection:object{IgnisCollectorV3.OutputCumulator} (son:bool owner-account:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    ;; C_DeployAccountSFT/NFT removed — DPDC Audit #35M: standalone deployment, reachable via a public
    ;; Talos entrypoint with no ownership check, let any signer force any existing account to associate
    ;; with any collection. Real auto-association always calls DPDC::XBv_DeployAccountSFT/NFT directly,
    ;; module-to-module (see DPDC-C/DPDC-F/DPDC-R/DPDC-S and this module's own Issue flow below).
    (defun C_IssueDigitalCollection:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string executee:string son:bool
            collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
            iz-special:bool
        )
    )

)
;;
(module DPDC-I GOV
    @doc "DPDC-I is the Collectables Issue module of the DPDC family, implementing \
        \ DpdcIssueV2 and OuronetPolicyV2. Its flagship entrypoint C_IssueDigitalCollection \
        \ creates a new digital collection (SFT if son=true, else NFT): it charges IGNIS and \
        \ STOA usage fees, writes the collection record and its initial Verum role-chain via \
        \ DPDC, and auto-deploys owner and creator collection accounts with distinct default \
        \ role sets. URCi_ functions provide cost previews; it manages only its own policy \
        \ tables and gates issuance on owner-account ownership."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcIssueV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-I                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-I_ADMIN)))
    (defcap GOV|DPDC-I_ADMIN ()                         (enforce-guard GOV|MD_DPDC-I))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|DPDC-I|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-I|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DPDC-I_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPDC-I_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|DPDC-I_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|DPDC-I_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|DPDC-I|CALLER)))
            )
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap DPDC-I|C>ISSUE (owner-account:string creator-account:string collection-name:string collection-ticker:string iz-special:bool)
        @doc "DPDC Audit #53L: <creator-account> is intentionally NOT ownership-checked, unlike \
            \ <owner-account> (real CAP_EnforceAccountOwnership below). The collection owner is meant \
            \ to be able to freely designate any account -- e.g. a trusted associate -- as the \
            \ collection's creator without that account's separate consent/signature, the same way an \
            \ owner has complete dominion over their own collection's admin structure elsewhere in this \
            \ module family (#4C/#17H/#20H/#25M). Only the type/prefix is validated \
            \ (UEV_EnforceAccountType) so <creator-account> is at least a real, well-formed account."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-U|DALOS::UEV_NameOrTicker collection-name true iz-special)
            (ref-U|DALOS::UEV_NameOrTicker collection-ticker false iz-special)
            (ref-DALOS::CAP_EnforceAccountOwnership owner-account)
            (ref-DALOS::UEV_EnforceAccountType creator-account false)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;
    (defun URCi_IssueCollectionPrice:decimal
        (son:bool)
        @doc "IGNIS issue price for a digital collection, from the CENTRAL IG|DETER map in the \
            \ IGNIS module (rehaul substage 5, 1 ignis = 1 cent): son=true (SFT) = $20 = 2000 \
            \ ignis, son=false (NFT) = $25 = 2500 ignis (owner 2026-09-05). \
            \ Single source for the exec construct and the INFO preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_Issue" "issue-sft")
                    (ref-IGNIS::UC_IgnisPrice "DPNF|C_Issue" "issue-nft"))
        )
    )
    (defun URCi_IssueCollectionStoa:decimal
        (son:bool)
        @doc "STOA side-cost for a digital-collection issue (dpsf for SFT, dpnf for NFT). \
            \ Single source for XE_CollectStoa and the INFO preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if son (ref-IGNIS::UC_StoaPrice "issue-sft") (ref-IGNIS::UC_StoaPrice "issue-nft"))
        )
    )
    (defun URCi_IssueDigitalCollection:object{IgnisCollectorV3.OutputCumulator}
        (son:bool owner-account:string)
        @doc "Cost preview for C_IssueDigitalCollection: IGNIS construct priced via \
            \ URCi_IssueCollectionPrice on the owner payer, empty output (the created \
            \ collection id is an exec-only write product). The STOA side-cost previews \
            \ separately via URCi_IssueCollectionStoa."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URCi_IssueCollectionPrice son)
                owner-account
                (ref-IGNIS::URC_IsVirtualGasZero)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: DPDC-I|C>ISSUE
    (defun XI_IssueDigitalCollection:string
        (
            son:bool
            owner-account:string creator-account:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
            iz-special:bool
        )
        (require-capability (DPDC-I|C>ISSUE owner-account creator-account collection-name collection-ticker iz-special))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (id:string (ref-U|DALOS::UDC_Makeid collection-ticker))
                (specifications:object{DpdcUdcV2.DPDC|Properties}
                    (ref-DPDC-UDC::UDC_DPDC|Properties
                        id owner-account creator-account collection-name collection-ticker
                        can-upgrade can-change-owner can-change-creator can-add-special-role
                        can-transfer-nft-create-role can-freeze can-wipe can-pause
                        false 0 0
                    )
                )
                (zne:[object{DpdcUdcV2.DPDC|NonceElement}]
                    [(ref-DPDC-UDC::UDC_ZeroNonceElement)]
                )
                (ca:string creator-account)
                (oa:string owner-account)
                (verum-chain:object{DpdcUdcV2.DPDC|VerumRoles}
                    (if son
                        (if (!= owner-account creator-account)
                            (ref-DPDC-UDC::UDC_DPDC|VerumRoles 
                                [BAR]   ;;a-frozen
                                [ca]    ;;r-exemption
                                [oa]    ;;r-nft-add-quantity
                                [oa]    ;;r-nft-burn
                                ca      ;;r-nft-create
                                ca      ;;r-nft-recreate
                                [ca oa] ;;r-nft-update
                                [ca]    ;;r-modify-creator
                                [ca]    ;;r-modify-royalties
                                ca      ;;r-set-new-uri
                                [BAR]   ;;r-transfer
                            )
                            (ref-DPDC-UDC::UDC_DPDC|VerumRoles 
                                [BAR]   ;;a-frozen
                                [oa]    ;;r-exemption
                                [oa]    ;;r-nft-add-quantity
                                [oa]    ;;r-nft-burn
                                oa      ;;r-nft-create
                                oa      ;;r-nft-recreate
                                [oa] ;;r-nft-update
                                [oa]    ;;r-modify-creator
                                [oa]    ;;r-modify-royalties
                                oa      ;;r-set-new-uri
                                [BAR]   ;;r-transfer
                            )
                        )
                        (if (!= owner-account creator-account)
                            (ref-DPDC-UDC::UDC_DPDC|VerumRoles 
                                [BAR]   ;;a-frozen
                                [ca]    ;;r-exemption
                                [BAR]   ;;r-nft-add-quantity
                                [oa]    ;;r-nft-burn
                                ca      ;;r-nft-create
                                ca      ;;r-nft-recreate
                                [ca oa] ;;r-nft-update
                                [ca]    ;;r-modify-creator
                                [ca]    ;;r-modify-royalties
                                ca      ;;r-set-new-uri
                                [BAR]   ;;r-transfer
                            )
                            (ref-DPDC-UDC::UDC_DPDC|VerumRoles 
                                [BAR]   ;;a-frozen
                                [oa]    ;;r-exemption
                                [BAR]   ;;r-nft-add-quantity
                                [oa]    ;;r-nft-burn
                                oa      ;;r-nft-create
                                oa      ;;r-nft-recreate
                                [oa]    ;;r-nft-update
                                [oa]    ;;r-modify-creator
                                [oa]    ;;r-modify-royalties
                                oa      ;;r-set-new-uri
                                [BAR]   ;;r-transfer
                            )
                        )
                        
                    )
                )
            )
            (ref-DPDC::XE_I|Collection id son specifications)
            (ref-DPDC::XE_I|VerumRoles id son verum-chain)
            id
        )
    )
    ;;{5.7}  User [A/C]
    ;; C_DeployAccountSFT/NFT removed — DPDC Audit #35M: see interface-side removal note above.
    (defun C_IssueDigitalCollection:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string executee:string son:bool
            collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
            iz-special:bool
        )
        @doc "Issues a DPSF or DPNF digital collection. \
            \ \
            \ BOTH ROLES WERE ALREADY HERE UNDER OTHER NAMES (patron/executor canon 2.2, \
            \ 2026-09-22), and the module had already argued the distinction without naming it. \
            \ DPDC-I|C>ISSUE runs CAP_EnforceAccountOwnership on <owner-account> -- a PARAMETER, \
            \ proven directly -- so that is the EXECUTOR. \
            \ \
            \ <creator-account> is the EXECUTEE, and the capability @doc says why in its own words: \
            \ audit #53L ruled it deliberately NOT ownership-checked, so an owner may designate a \
            \ trusted associate as creator WITHOUT that account separate consent or signature. Acted \
            \ upon, needing no signature, only type-validated -- the executee test verbatim, decided \
            \ by an audit two rounds before this canon existed. \
            \ \
            \ A RENAME AND A REORDER, not an addition: nothing about who may call this has changed."
        (P|UEV_IMC)
        (with-capability (DPDC-I|C>ISSUE executor executee collection-name collection-ticker iz-special)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-BRD:module{BrandingV2} BRD)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    ;;
                    (ignis-price:decimal (URCi_IssueCollectionPrice son))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    ;;
                    (stoa-cost:decimal (URCi_IssueCollectionStoa son))
                    (id:string
                        (XI_IssueDigitalCollection
                            son
                            executor executee collection-name collection-ticker
                            can-upgrade can-change-owner can-change-creator can-add-special-role 
                            can-transfer-nft-create-role can-freeze can-wipe can-pause
                            iz-special
                        )
                    )
                    (t:bool true)
                    (f:bool false)
                )
                (ref-BRD::XE_Issue id)
                ;;Deploy Collection Accounts for Owner and Creator
                (if son
                    ;;SFT New Account Roles
                    (if (!= executor executee)
                        (do
                            (ref-DPDC::XBv_DeployAccountSFT executor id
                                true    ;;role-nft-add-quantity
                                false   ;;frozen
                                false   ;;role-exemption
                                true    ;;role-nft-burn
                                false   ;;role-nft-create
                                false   ;;role-nft-recreate
                                true    ;;role-nft-update
                                false   ;;role-modify-creator
                                false   ;;role-modify-royalties
                                false   ;;role-set-new-uri
                                false   ;;role-transfer
                            )
                            (ref-DPDC::XBv_DeployAccountSFT executee id
                                false   ;;role-nft-add-quantity
                                false   ;;frozen
                                true    ;;role-exemption
                                false   ;;role-nft-burn
                                true    ;;role-nft-create
                                true    ;;role-nft-recreate
                                true    ;;role-nft-update
                                true    ;;role-modify-creator
                                true    ;;role-modify-royalties
                                true    ;;role-set-new-uri
                                false   ;;role-transfer
                            )
                        )
                        (ref-DPDC::XBv_DeployAccountSFT executor id
                            true    ;;role-nft-add-quantity
                            false   ;;frozen
                            true    ;;role-exemption
                            true    ;;role-nft-burn
                            true    ;;role-nft-create
                            true    ;;role-nft-recreate
                            true    ;;role-nft-update
                            true    ;;role-modify-creator
                            true    ;;role-modify-royalties
                            true    ;;role-set-new-uri
                            false   ;;role-transfer
                        )
                    )
                    (if (!= executor executee)
                        (do
                            (ref-DPDC::XBv_DeployAccountNFT executor id
                                false   ;;frozen
                                false   ;;role-exemption
                                true    ;;role-nft-burn
                                false   ;;role-nft-create
                                false   ;;role-nft-recreate
                                true    ;;role-nft-update
                                false   ;;role-modify-creator
                                false   ;;role-modify-royalties
                                false   ;;role-set-new-uri
                                false   ;;role-transfer
                            )
                            (ref-DPDC::XBv_DeployAccountNFT executee id
                                false   ;;frozen
                                true    ;;role-exemption
                                false   ;;role-nft-burn
                                true    ;;role-nft-create
                                true    ;;role-nft-recreate
                                true    ;;role-nft-update
                                true    ;;role-modify-creator
                                true    ;;role-modify-royalties
                                true    ;;role-set-new-uri
                                false   ;;role-transfer
                            )
                        )
                        (ref-DPDC::XBv_DeployAccountNFT executor id
                            false   ;;frozen
                            true    ;;role-exemption
                            true    ;;role-nft-burn
                            true    ;;role-nft-create
                            true    ;;role-nft-recreate
                            true    ;;role-nft-update
                            true    ;;role-modify-creator
                            true    ;;role-modify-royalties
                            true    ;;role-set-new-uri
                            false   ;;role-transfer
                        )
                    )
                )
                (ref-IGNIS::XE_CollectStoa patron stoa-cost)
                (ref-IGNIS::UDC_ConstructOutputCumulator ignis-price executor trigger [id])
            )
        )
    )

)

;; --- tables for 04_DPDC-I.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/05_DPDC-R.pact ==========
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcRolesV2
    @doc "Exposes Collectables Role Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URCi]
    ;;
    (defun URCi_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleExemptionRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleUpdateRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleModifyCreatorRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleModifyRoyaltiesRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_MoveRecreateRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_MoveSetUriRole:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;

    (defun C_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleExemptionRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleUpdateRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleModifyCreatorRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleModifyRoyaltiesRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool toggle:bool))
    (defun C_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool))
    (defun C_MoveRecreateRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool))
    (defun C_MoveSetUriRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool))

)
;;
(module DPDC-R GOV
    @doc "DPDC-R is the Collectables Roles module of the DPDC family, implementing \
        \ DpdcRolesV2 and OuronetPolicyV2, managing the special roles on a collection's \
        \ accounts. Its C_ entrypoints toggle per-account roles (add-quantity, freeze, \
        \ exemption, burn, update, modify-creator, modify-royalties, transfer) and move \
        \ singleton roles (create, recreate, set-URI) between accounts. Each op is \
        \ owner-gated via DPDC::CAP_Owner plus role/state validators, ensures the target \
        \ account is deployed, then writes state and updates the Verum role-chain through \
        \ DPDC; URCi_ give IGNIS cost previews."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcRolesV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-R                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-R_ADMIN)))
    (defcap GOV|DPDC-R_ADMIN ()                         (enforce-guard GOV|MD_DPDC-R))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|DPDC-R|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-R|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DPDC-R_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPDC-R_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|DPDC-R_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|DPDC-R_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (mg:guard (create-capability-guard (P|DPDC-R|CALLER)))
            )
            (ref-P|DPDC::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap DPDC|C>TG_ADD-QTY-R (id:string account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id true toggle)
            (ref-DPDC::UEV_AccountAddQuantityState id account (not toggle))
            (ref-DPDC::CAP_Owner id true)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>FRZ-ACC (id:string son:bool account:string frozen:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;; DPDC Audit #13H: <can-freeze> gates new freezes only — unfreeze is a release valve and
            ;; must stay available even after <can-freeze> has been renounced, or an already-frozen
            ;; account (combined with <can-upgrade=false>) would be bricked with no recovery path.
            (if frozen
                (ref-DPDC::UEV_CanFreezeON id son)
                true
            )
            (ref-DPDC::UEV_AccountFreezeState id son account (not frozen))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_EXEMPTION-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (type:bool (ref-DALOS::UR_AccountType account))
            )
            (enforce type "Only Smart Ouronet Accounts can get this role")
            (ref-DPDC::UEV_AccountExemptionState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_BURN-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id son toggle)
            (ref-DPDC::UEV_AccountBurnState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_UPDATE-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id son toggle)
            (ref-DPDC::UEV_AccountUpdateState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_MODIFY-CREATOR-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id son toggle)
            (ref-DPDC::UEV_AccountModifyCreatorState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_MODIFY-ROYALTIES-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id son toggle)
            (ref-DPDC::UEV_AccountModifyRoyaltiesState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>TG_TRANSFER-R (id:string son:bool account:string toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ToggleSpecialRole id son toggle)
            (ref-DPDC::UEV_AccountTransferState id son account (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    ;;
    (defcap DPDC|C>MV_CREATE-R (id:string son:bool old-account:string new-account:string)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_CanAddSpecialRoleON id son)
            (ref-DPDC::UEV_AccountCreateState id son old-account true)
            (ref-DPDC::UEV_AccountCreateState id son new-account false)
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    (defcap DPDC|C>MV_RECREATE-R (id:string son:bool old-account:string new-account:string)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_CanAddSpecialRoleON id son)
            (ref-DPDC::UEV_AccountRecreateState id son old-account true)
            (ref-DPDC::UEV_AccountRecreateState id son new-account false)
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        ) 
    )
    (defcap DPDC|C>MV_SET-URI-R (id:string son:bool old-account:string new-account:string)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_CanAddSpecialRoleON id son)
            (ref-DPDC::UEV_AccountSetUriState id son old-account true)
            (ref-DPDC::UEV_AccountSetUriState id son new-account false)
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (P|DPDC-R|CALLER))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    (defun URCi_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_ToggleAddQuantityRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleAddQuantityRole" "auth")
                (ref-DPDC::UR_OwnerKonto id true) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleFreezeAccount (Biggest tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleFreezeAccount" "setup")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleFreezeAccount" "setup"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleExemptionRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleExemptionRole (Biggest tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleExemptionRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleExemptionRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleBurnRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleBurnRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleBurnRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleUpdateRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleUpdateRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleUpdateRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleUpdateRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleModifyCreatorRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleModifyCreatorRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleModifyCreatorRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleModifyCreatorRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleModifyRoyaltiesRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleModifyRoyaltiesRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleModifyRoyaltiesRole" "fee")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleModifyRoyaltiesRole" "fee"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleTransferRole (Big tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleTransferRole" "usage")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleTransferRole" "usage"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_MoveCreateRole (Biggest tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_MoveCreateRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_MoveCreateRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MoveRecreateRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_MoveRecreateRole (Biggest tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_MoveRecreateRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_MoveRecreateRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MoveSetUriRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_MoveSetUriRole (Biggest tier on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_MoveSetUriRole" "auth")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_MoveSetUriRole" "auth"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: DPDC|C>TG_ADD-QTY-R
    (defun XI_ToggleAddQuantityRole (id:string account:string toggle:bool)
        (require-capability (DPDC|C>TG_ADD-QTY-R id account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Rnaq id account toggle)
            (ref-DPDC::XE_U|VerumRoles id true 3 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>FRZ-ACC
    (defun XI_ToggleFreezeAccount (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>FRZ-ACC id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
            )
            (ref-DPDC::XE_U|Frozen id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 1 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_EXEMPTION-R
    (defun XI_ToggleExemptionRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_EXEMPTION-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
            )
            (ref-DPDC::XE_U|Exemption id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 2 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_BURN-R
    (defun XI_ToggleBurnRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_BURN-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Burn id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 4 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_UPDATE-R
    (defun XI_ToggleUpdateRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_UPDATE-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Update id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 7 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_MODIFY-CREATOR-R
    (defun XI_ToggleModifyCreatorRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_MODIFY-CREATOR-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|ModifyCreator id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 8 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_MODIFY-ROYALTIES-R
    (defun XI_ToggleModifyRoyaltiesRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_MODIFY-ROYALTIES-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|ModifyRoyalties id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 9 toggle account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>TG_TRANSFER-R
    (defun XI_ToggleTransferRole (id:string son:bool account:string toggle:bool)
        (require-capability (DPDC|C>TG_TRANSFER-R id son account toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Transfer id son account toggle)
            (ref-DPDC::XE_U|VerumRoles id son 11 toggle account)
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPDC|C>MV_CREATE-R
    (defun XI_MoveCreateRole (id:string son:bool old-account:string new-account:string)
        (require-capability (DPDC|C>MV_CREATE-R id son old-account new-account))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Create id son old-account false)
            (ref-DPDC::XE_U|VerumRoles id son 5 false old-account)
            (ref-DPDC::XE_U|Create id son new-account true)
            (ref-DPDC::XE_U|VerumRoles id son 5 true new-account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>MV_RECREATE-R
    (defun XI_MoveRecreateRole (id:string son:bool old-account:string new-account:string)
        (require-capability (DPDC|C>MV_RECREATE-R id son old-account new-account))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Recreate id son old-account false)
            (ref-DPDC::XE_U|VerumRoles id son 6 false old-account)
            (ref-DPDC::XE_U|Recreate id son new-account true)
            (ref-DPDC::XE_U|VerumRoles id son 6 true new-account)
        )
    )
    ;;Protection: Class 3 — Custom: DPDC|C>MV_SET-URI-R
    (defun XI_MoveSetUriRole (id:string son:bool old-account:string new-account:string)
        (require-capability (DPDC|C>MV_SET-URI-R id son old-account new-account))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|SetNewUri id son old-account false)
            (ref-DPDC::XE_U|VerumRoles id son 10 false old-account)
            (ref-DPDC::XE_U|SetNewUri id son new-account true)
            (ref-DPDC::XE_U|VerumRoles id son 10 true new-account)
        )
    )
    ;;{5.7}  User [A/C]
    ;;Role Toggling
    (defun UEV_ExecutorIsOwnerKontoLocal (executor:string id:string son:bool)
        @doc "Thin local wrapper over DPDC::UEV_ExecutorIsOwnerKonto. \
            \ \
            \ Exists so the DPDC modref is bound in ONE place rather than at eleven call sites. \
            \ Every entrypoint in this module is gated by DPDC::CAP_Owner, which enforces on the \
            \ DERIVED (UR_OwnerKonto id son) -- HANDOFF 4g, across the whole module -- so all \
            \ eleven need the same binder against the same pair. \
            \ \
            \ <son> travels with <id> because DPSF and DPNF are separate tables and the same id \
            \ can live in both; an owner lookup without it is a lookup of a different token. \
            \ C_ToggleAddQuantityRole passes the literal TRUE, matching its own capability, \
            \ which already hardcodes (CAP_Owner id true) because add-quantity is semi-fungible \
            \ only. (patron/executor canon 2.2, indirect route named.)"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ExecutorIsOwnerKonto executor id son)
        )
    )
    (defun C_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id true)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_ADD-QTY-R id executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id true)
                (XI_ToggleAddQuantityRole id executee toggle)
                (URCi_ToggleAddQuantityRole id)
            )
        )
    )
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>FRZ-ACC id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleFreezeAccount id son executee toggle)
                (URCi_ToggleFreezeAccount id son)
            )
        )
    )
    (defun C_ToggleExemptionRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_EXEMPTION-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleExemptionRole id son executee toggle)
                (URCi_ToggleExemptionRole id son)
            )
        )
    )
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_BURN-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleBurnRole id son executee toggle)
                (URCi_ToggleBurnRole id son)
            )
        )
    )
    (defun C_ToggleUpdateRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_UPDATE-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleUpdateRole id son executee toggle)
                (URCi_ToggleUpdateRole id son)
            )
        )
    )
    (defun C_ToggleModifyCreatorRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_MODIFY-CREATOR-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleModifyCreatorRole id son executee toggle)
                (URCi_ToggleModifyCreatorRole id son)
            )
        )
    )
    (defun C_ToggleModifyRoyaltiesRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_MODIFY-ROYALTIES-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleModifyRoyaltiesRole id son executee toggle)
                (URCi_ToggleModifyRoyaltiesRole id son)
            )
        )
    )
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool toggle:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (with-capability (DPDC|C>TG_TRANSFER-R id son executee toggle)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_ToggleTransferRole id son executee toggle)
                (URCi_ToggleTransferRole id son)
            )
        )
    )
    ;;
    (defun C_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (old-account:string (ref-DPDC::UR_Verum5 id son))
            )
            (with-capability (DPDC|C>MV_CREATE-R id son old-account executee)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_MoveCreateRole id son old-account executee)
                (URCi_MoveCreateRole id son)
            )
        )
    )
    (defun C_MoveRecreateRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (old-account:string (ref-DPDC::UR_Verum6 id son))
            )
            (with-capability (DPDC|C>MV_RECREATE-R id son old-account executee)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_MoveRecreateRole id son old-account executee)
                (URCi_MoveRecreateRole id son)
            )
        )
    )
    (defun C_MoveSetUriRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool)
        @doc "HANDOFF 4g (patron/executor canon 2.2, 2026-09-22). DPDC::CAP_Owner enforces on \
            \ the DERIVED (UR_OwnerKonto id son) and names no actor; UEV_ExecutorIsOwnerKonto \
            \ supplies it and the ownership enforce is KEPT. The role recipient became <executee>: \
            \ the capability validates its STATE but never its ownership, so it is acted upon and \
            \ needs no signature -- the executee test. A rename and a reorder, plus the two new \
            \ leading parameters."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKontoLocal executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (old-account:string (ref-DPDC::UR_Verum10 id son))
            )
            (with-capability (DPDC|C>MV_SET-URI-R id son old-account executee)
                (ref-DPDC::XE_DeployAccountWNE executee id son)
                (XI_MoveSetUriRole id son old-account executee)
                (URCi_MoveSetUriRole id son)
            )
        )
    )

)

;; --- tables for 05_DPDC-R.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/06_DPDC-MNG.pact ========
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcManagementV2
    @doc "Exposes Collectables Management Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;
    (defschema RemovableNonces
        @doc "Removable Nonces are Class 0 Nonces held by a given Account with greater than 0 supply \
        \ Given an <account>, a dpdc <id>, and a list of <nonces>, they can be filtered to Removable Nonces"
        r-nonces:[integer]
        r-amounts:[integer]
    )
    (defschema DPDC-MNG|WipeSlicePlan
        @doc "Hydra wipe slice plan: the URHC_WipePure output partitioned into <slice-count> \
        \ disjoint contiguous |RemovableNonces| slices, each fed to one <Cp_WipeSlice> tx. \
        \ Offline plan only (UI dirty-read) — never persisted on-chain."
        account:string
        id:string
        son:bool
        slice-count:integer
        slices:[object{RemovableNonces}]
    )
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_RemovableNonces:object{RemovableNonces} (a:[integer] b:[integer]))
    (defun UDC_WipeSlicePlan:object{DPDC-MNG|WipeSlicePlan}
        (a:string b:string c:bool d:integer e:[object{RemovableNonces}]))
    ;;{5.2}  Compute [UC]
    (defun UC_ComputeMinWipeSliceCount:integer (nonce-count:integer))
    (defun UC_BuildWipeSlicePlan:object{DPDC-MNG|WipeSlicePlan}
        (account:string id:string son:bool removable-nonces-obj:object{RemovableNonces} slice-count:integer))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URCi]
    ;;
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_AddQuantity:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_RespawnNFT:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_BurnSFT:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_BurnNFT:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_WipeNonce:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_WipeCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool removable-nonces-obj:object{RemovableNonces}))
    ;;
    ;;  [URDC/URC/UDC]  RemovableNonces builders (dirty-read helpers, also used by INFO preview)
    (defun URHC_WipePure:object{RemovableNonces} (account:string id:string son:bool))
    (defun URHC_BuildWipeSlicePlan:object{DPDC-MNG|WipeSlicePlan} (account:string id:string son:bool slice-count:integer))
    (defun URC_FilterAccountViableNonces:object{RemovableNonces} (account:string id:string son:bool nonces:[integer]))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]
    ;;
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string son:bool cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool))
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string son:bool toggle:bool))
    ;;
    ;;  [CREDIT-SINGLE]
    ;;  [SFT]
    (defun C_AddQuantity:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string nonce:integer amount:integer))
    ;;  [NFT]
    (defun C_RespawnNFT:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string nonce:integer))
    ;;
    ;;  [DEBIT-SINGLE]
    ;;  [SFT]
    (defun C_BurnSFT:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string nonce:integer amount:integer))
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string nonce:integer amount:integer))
    ;;  [NFT]
    (defun C_BurnNFT:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string nonce:integer))
    ;;  [SFT+NFT]
    (defun C_WipeNonce:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool nonce:integer))
    ;;
    ;;  [DEBIT-MULTIPLE]
    ;;  [SFT+NFT]
    (defun CC_WipeHeavy:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool))
    (defun C_WipePure:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool removable-nonces-obj:object{RemovableNonces}))
    (defun C_WipeClean:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool nonces:[integer]))
    (defun C_WipeDirty:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string son:bool nonces:[integer]))
    (defun Cp_WipeSlice:object{IgnisCollectorV3.OutputCumulator} (account:string id:string son:bool removable-nonces-obj:object{RemovableNonces}))

)
;;
(module DPDC-MNG GOV
    @doc "Management module for the DPDC collectables (NFT/SFT) family, implementing \
        \ DpdcManagementV2 and OuronetPolicyV2. Its client entrypoints let a collectable \
        \ owner control specs and roles (C_Control, C_TogglePause), credit supply \
        \ (C_AddQuantity for SFTs, C_RespawnNFT), and debit/burn/wipe holdings (C_BurnSFT, \
        \ C_BurnNFT, C_WipeSlim, C_WipeNonce, plus multi-nonce wipes). It only operates on \
        \ Class-0 nonces, updates nonce supplies via DPDC-C, guards the DPDC system account \
        \ against wiping collateral backing outstanding fragments, and returns IGNIS gas \
        \ cumulators."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcManagementV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-MNG                           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-MNG_ADMIN)))
    (defcap GOV|DPDC-MNG_ADMIN ()                       (enforce-guard GOV|MD_DPDC-MNG))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|DPDC-MNG|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-MNG|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DPDC-MNG_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPDC-MNG_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|DPDC-MNG_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|DPDC-MNG_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (mg:guard (create-capability-guard (P|DPDC-MNG|CALLER)))
            )
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst WIPE-SLICE-MAX-NONCES                     500
        "Hydra wipe: max nonces per <Cp_WipeSlice> tx. UI SEED + generous backstop, NOT the \
        \ optimizer — the UI /local-simulates each slice and adds slices when one does not fit; \
        \ the node gas meter is the real enforcement (an oversized slice aborts atomically). \
        \ CALIBRATED REPL/Kursan/DPDC-scale-wipe.repl: measured 952.4 gas per nonce wiped => ~2091 nonces fit a \
        \ 2,000,000-gas tx. Set well under that because the probe used the LIGHTEST possible \
        \ nonces (zero URI data, no metadata); real nonces carry more payload per row.")
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap DPDC-MNG|S>CTRL (id:string son:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::CAP_Owner id son)
            (ref-DPDC::UEV_CanUpgradeON id son)
        )
    )
    (defcap DPDC-MNG|S>TG_PAUSE (id:string son:bool toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (if toggle
                (ref-DPDC::UEV_CanPauseON id son)
                true
            )
            (ref-DPDC::CAP_Owner id son)
            (ref-DPDC::UEV_PauseState id son (not toggle))
        )
    )
    (defcap DPDC-MNG|C>IZ-CLASS-ZERO (id:string son:bool nonces:[integer])
        (let
            (
                (class-zero-nonces:[integer] (URC_FilterClassZeroNonces id son nonces))
            )
            (enforce (= nonces class-zero-nonces) "Invalid Class Zero Nonces")
        )
    )
    ;;{C3}  Composed
    (defcap DPDC-MNG|C>ADD-QUANTITY (account:string id:string nonce:integer amount:integer)
        @event
        ;;PARTIALLY-SHADOWED GUARD FIX: <nonce> used to be validated INSIDE the let, below the
        ;;UR_NonceClass binding. That reader hard-reads keyed by the nonce, so nonce 0 aborted on
        ;;'row not found' and never reached the guard. (A NEGATIVE nonce did reach it, because
        ;;UR_NonceClass keys on (abs nonce) and so reads a row that exists - which is why only the
        ;;zero case was shadowed, not the whole predicate.) Hoisted; message unchanged on every
        ;;path, so only its reachability at nonce=0 changed.
        (enforce (> nonce 0) "Invalid Data for Adding Quantity for an SFT Nonce")
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (nonce-class:integer (ref-DPDC::UR_NonceClass id true nonce))
            )
            (enforce
                (and
                    (> amount 0)
                    (= nonce-class 0)
                )
                "Invalid Data for Adding Quantity for an SFT Nonce"
            )
            ;;Account Ownership
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            ;;Correct add quantity role
            (ref-DPDC::UEV_AccountAddQuantityState id account true)
            ;;Req cap
            (compose-capability (P|DPDC-MNG|CALLER))
        )
    )
    (defcap DPDC-MNG|C>BURN-SFT (account:string id:string nonce:integer amount:integer)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;;Account Ownership - via Debit Function
            ;;Correct burn role
            (ref-DPDC::UEV_AccountBurnState id true account true)
            ;;Remove Nonces Capability (also enforces nonces are held by account)
            (compose-capability (DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES account id true [nonce] [amount]))
        )
    )
    (defcap DPDC-MNG|C>WIPE-SFT-NONCE-PARTIALLY (account:string id:string nonce:integer amount:integer)
        @event
        (compose-capability (DPDC-MNG|C>WIPE-SFT account id [nonce] [amount]))
    )
    (defcap DPDC-MNG|C>WIPE-SFT-NONCE-TOTALLY (account:string id:string nonce:integer amount:integer)
        @event
        (compose-capability (DPDC-MNG|C>WIPE-SFT account id [nonce] [amount]))
    )
    (defcap DPDC-MNG|C>WIPE-SFT-NONCES (account:string id:string nonces:[integer])
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (amounts:[integer] (ref-DPDC::UR_AccountNoncesSupplies account id true nonces))
            )
            (compose-capability (DPDC-MNG|C>WIPE-SFT account id nonces amounts))
        )
    )
    (defcap DPDC-MNG|C>WIPE-SFT (account:string id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;;Semi-Fungible <id> is frozen on <account>
            (ref-DPDC::UEV_AccountFreezeState id true account true)
            ;;Semi-Fungible has <can-wipe> set to ON
            (ref-DPDC::UEV_CanWipeON id true)
            ;;Wiping requires <id> ownership via debit function
            ;;Remove Nonces Capability (also enforces nonces are held by account)
            (compose-capability (DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES account id true nonces amounts))
        )
    )
    ;;
    ;;
    (defcap DPDC-MNG|C>RESPAWN-NFT (account:string id:string nonce:integer)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;;Account Ownership
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            ;;Correct Role
            (ref-DPDC::UEV_AccountCreateState id false account true)
            ;;NFT Nonce must not exist, to respawn it
            (ref-DPDC::UEV_NftNonceExistance id nonce false)
            ;;Req Cap
            (compose-capability (P|DPDC-MNG|CALLER))
        )
    )
    (defcap DPDC-MNG|C>BURN-NFT (account:string id:string nonce:integer)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;;Collection Must Exist. Placed FIRST because the role check below reports on a
            ;;collection it has not established: for an id that does not exist it answered
            ;;"NFT Burn Role for <id> on Account <acct> must be set to true for exec", which is
            ;;true and useless -- there is no collection to hold a role on. It also disagreed with
            ;;INFO_DPNF|Burn, which died on a raw DPNF|T|Properties read at the same input.
            ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-004a/b>>.
            (ref-DPDC::UEV_id id false)
            ;;Account Ownership - via Debit Function
            ;;Correct Role
            (ref-DPDC::UEV_AccountBurnState id false account true)
            ;;Nonce Must Exist to Burn it
            (ref-DPDC::UEV_NftNonceExistance id nonce true)
            ;;Remove Nonces Capability (also enforces nonces are held by account)
            (compose-capability (DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES account id false [nonce] [1]))
        )
    )
    (defcap DPDC-MNG|C>WIPE-NFT-NONCE (account:string id:string nonce:integer)
        @event
        (compose-capability (DPDC-MNG|C>WIPE-NFT account id [nonce] [1]))
    )
    (defcap DPDC-MNG|C>WIPE-NFT-NONCES (account:string id:string nonces:[integer])
        @event
        (compose-capability (DPDC-MNG|C>WIPE-NFT account id nonces (make-list (length nonces) 1)))
    )
    (defcap DPDC-MNG|C>WIPE-NFT (account:string id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;;Semi-Fungible <id> is frozen on <account>
            (ref-DPDC::UEV_AccountFreezeState id false account true)
            ;;Semi-Fungible has <can-wipe> set to ON
            (ref-DPDC::UEV_CanWipeON id false)
            ;;Wiping requires <id> ownership - via Debit Function
            ;;Remove Nonces Capability (also enforces nonces are held by account)
            (compose-capability (DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES account id false nonces amounts))
        )
    )
    ;;
    ;;
    (defcap DPDC-MNG|C>REMOVE-CLASS-ZERO-NONCES
        (account:string id:string son:bool nonces:[integer] amounts:[integer])
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (l1:integer (length nonces))
                (l2:integer (length amounts))
                (zd:object{DpdcUdcV2.DPDC|NonceData} (ref-DPDC-UDC::UDC_ZeroNonceData))
            )
            (enforce (= l1 l2) "Invalid Nonces and Amount for Class Zero Nonce Removal")
            ;; DPDC Audit #5C follow-up: the DPDC system account is only protected from burn/wipe when
            ;; the nonce being removed is currently backing an outstanding fragment claim -- that's the
            ;; actual invariant #5C protects (burning collateral out from under fragment holders). EQUITY
            ;; legitimately uses <dpdc> as a same-transaction escrow for its Convert/Break package-share
            ;; flows (transfer in, burn old tier, credit new tier, transfer out) -- never fragmentation --
            ;; and must not be blocked by this check. This capability only ever handles Class-0 nonces
            ;; (enforced below, via the composed DPDC-MNG|C>IZ-CLASS-ZERO), so "is it fragmented" reduces
            ;; to "does it have non-zero split-data" — checked directly here, without needing a forward
            ;; reference to DPDC-F (which deploys after this module and cannot be referenced by interface
            ;; type this early — confirmed live: referencing module{DpdcFragmentsV2} here throws "Cannot
            ;; find module" at DPDC-MNG's own deploy step).
            (if (= account (ref-DPDC::GOV|DPDC|SC_NAME))
                (enforce
                    (not
                        (fold (or) false
                            (map
                                (lambda (n:integer) (!= (ref-DPDC::UR_SplitNonceData id son n) zd))
                                nonces
                            )
                        )
                    )
                    "Not allowed for the DPDC system account when backing outstanding fragments"
                )
                true
            )
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (amount:integer (at idx amounts))
                            (account-nonce-supply:integer (ref-DPDC::UR_AccountNonceSupply account id son nonce))
                        )
                        (enforce
                            (and
                                (> amount 0)
                                (<= amount account-nonce-supply)
                            )
                            (format "Amount {} is invalid for Debiting Nonce {} of {} on Account" [amount nonce id account])
                        )
                    )
                )
                (enumerate 0 (- l1 1))
            )
            (compose-capability (DPDC-MNG|C>IZ-CLASS-ZERO id son nonces))
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    (defun UDC_RemovableNonces:object{DpdcManagementV2.RemovableNonces}
        (a:[integer] b:[integer])
        {"r-nonces"     : a
        ,"r-amounts"    : b}
    )
    (defun UDC_WipeSlicePlan:object{DpdcManagementV2.DPDC-MNG|WipeSlicePlan}
        (a:string b:string c:bool d:integer e:[object{DpdcManagementV2.RemovableNonces}])
        {"account"      : a
        ,"id"           : b
        ,"son"          : c
        ,"slice-count"  : d
        ,"slices"       : e}
    )
    ;;{5.2}  Compute [UC]
    (defun UCv_TakePureWipe:object{DpdcManagementV2.RemovableNonces} (input:object{DpdcManagementV2.RemovableNonces} size:integer)
        @doc "Takes <size> and returns a smaller |object{DpdcManagementV2.RemovableNonces}|"
        (let
            (
                (nonces:[integer] (at "r-nonces" input))
                (amounts:[integer] (at "r-amounts" input))
                (l:integer (length nonces))
            )
            (enforce (< size l) (format "Size of {} is larger than the Data set of the Removable Nonces Object" [size]))
            (UDC_RemovableNonces
                (take size nonces)
                (take size amounts)
            )
        )
    )
    (defun UC_CeilDiv:integer (numerator:integer denominator:integer)
        @doc "Integer ceiling division: smallest integer >= numerator/denominator."
        (if (= (mod numerator denominator) 0)
            (/ numerator denominator)
            (+ 1 (/ numerator denominator))
        )
    )
    (defun UC_ComputeMinWipeSliceCount:integer (nonce-count:integer)
        @doc "Hydra wipe UI SEED: the minimum <Cp_WipeSlice> count for <nonce-count> nonces \
            \ under the <WIPE-SLICE-MAX-NONCES> per-tx backstop; minimum 1. NOT the optimizer — \
            \ the UI /local-simulates each candidate slice and adds slices when one does not fit."
        (let
            (
                (raw:integer (UC_CeilDiv nonce-count WIPE-SLICE-MAX-NONCES))
            )
            (if (> raw 1) raw 1)
        )
    )
    (defun UC_BuildWipeSlicePlan:object{DpdcManagementV2.DPDC-MNG|WipeSlicePlan}
        (account:string id:string son:bool removable-nonces-obj:object{DpdcManagementV2.RemovableNonces} slice-count:integer)
        @doc "Hydra wipe partitioner (pure compute, no table reads): splits a |RemovableNonces| \
            \ object into disjoint CONTIGUOUS slices via take/drop index ranges. The requested \
            \ <slice-count> is clamped to [1, nonce-count] and then recomputed from the per-slice \
            \ width, so the returned plan NEVER contains an empty slice (an empty nonce list \
            \ aborts the executor); the plan's own <slice-count> field is the authoritative count."
        (let*
            (
                (nonces:[integer] (at "r-nonces" removable-nonces-obj))
                (amounts:[integer] (at "r-amounts" removable-nonces-obj))
                (l:integer (length nonces))
                (n-clamped:integer (if (< slice-count 1) 1 (if (> slice-count l) (if (> l 0) l 1) slice-count)))
                (per-slice:integer (UC_CeilDiv (if (> l 0) l 1) n-clamped))
                (n-final:integer (UC_CeilDiv (if (> l 0) l 1) per-slice))
            )
            (UDC_WipeSlicePlan account id son n-final
                (map
                    (lambda
                        (slice-idx:integer)
                        (let*
                            (
                                (start:integer (* slice-idx per-slice))
                                (rest:integer (- l start))
                                (count:integer (if (< per-slice rest) per-slice rest))
                            )
                            (UDC_RemovableNonces
                                (take count (drop start nonces))
                                (take count (drop start amounts))
                            )
                        )
                    )
                    (enumerate 0 (- n-final 1))
                )
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCi_WipeCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (no-of-nonces:integer (length (at "r-nonces" removable-nonces-obj)))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (*  ;;5 IGNIS per nonce wiped (owner 2026-09-05; central IG|WEIGHTS wipe-nonce).
                    ;;Collectible wipe MIRRORS the DPOF ortofungible rule, per owner confirmation.
                    (ref-IGNIS::UC_IgnisWeight "wipe-nonce")
                    (dec no-of-nonces)
                )
                (ref-DPDC::UR_OwnerKonto id son)
                (ref-IGNIS::URC_IsVirtualGasZero)
                [removable-nonces-obj]
            )
        )
    )
    (defun URHC_WipePure:object{DpdcManagementV2.RemovableNonces} (account:string id:string son:bool)
        @doc "Uses Expensive Read Functions to obtain a |object{DpdcManagementV2.RemovableNonces}| that can be used \
        \ to execute a <C_WipePure>, bypassing the expensive gas costs of using (keys...) or (select...) functions"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (URC_FilterAccountViableNonces account id son (ref-DPDC::URH_AccountNonces account id son))
        )
    )
    (defun URHC_BuildWipeSlicePlan:object{DpdcManagementV2.DPDC-MNG|WipeSlicePlan}
        (account:string id:string son:bool slice-count:integer)
        @doc "Hydra wipe PREFLIGHT (UI /local ONLY — the one heavy read of the flow): dirty-reads \
            \ the full viable wipeable set via <URHC_WipePure> and partitions it into the slice \
            \ plan. The UI fires one <Cp_WipeSlice> tx per slice, all in parallel; a re-read after \
            \ a partial campaign naturally returns the outstanding remains (re-plan is implicit). \
            \ Seed <slice-count> with <UC_ComputeMinWipeSliceCount>."
        (UC_BuildWipeSlicePlan account id son (URHC_WipePure account id son) slice-count)
    )
    (defun URC_FilterClassZeroNonces:[integer] (id:string son:bool nonces:[integer])
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (filter 
                (lambda 
                    (element:integer)
                    (= (ref-DPDC::UR_NonceClass id son element) 0)
                ) 
                nonces
            )
        )
    )
    (defun URC_FilterAccountViableNonces:object{DpdcManagementV2.RemovableNonces}
        (account:string id:string son:bool nonces:[integer])
        ;;Empty input short-circuit: (enumerate 0 -1) DESCENDS ([0 -1]), so the fold below
        ;;would (at 0) an empty list. A finished Hydra campaign re-reads to an empty object.
        (if (= (length nonces) 0)
        (UDC_RemovableNonces [] [])
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (matrix:[[integer]]
                    (fold
                        (lambda
                            (acc:[[integer]] idx:integer)
                            (let
                                (
                                    (acc-nonces:[integer] (at 0 acc))
                                    (acc-amounts:[integer] (at 1 acc))
                                    (nonce:integer (at idx nonces))
                                    (nonce-class:integer (ref-DPDC::UR_NonceClass id son nonce))
                                    (account-nonce-supply:integer (ref-DPDC::UR_AccountNonceSupply account id son nonce))
                                )
                                (if
                                    (and
                                        (= nonce-class 0)
                                        (> account-nonce-supply 0)
                                    )
                                    [
                                        (ref-U|LST::UC_AppL acc-nonces nonce)
                                        (ref-U|LST::UC_AppL acc-amounts account-nonce-supply)
                                    ]
                                    [
                                        acc-nonces
                                        acc-amounts
                                    ]
                                )
                            )
                        )
                        [[][]]
                        (enumerate 0 (- (length nonces) 1))
                    )
                )
            )
            (UDC_RemovableNonces
                (at 0 matrix)
                (at 1 matrix)
            )
        )
        )
    )
    ;;
    ;;  (URCi_WipeCumulator, above, covers the multiple-debit wipe family.)
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_Control (Big if son else Biggest, on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;RESTORED 2026-09-22. This binding IS read, two lines down, as the cumulator's
                ;;active account. A blanket removal of `(owner:string (UR_OwnerKonto id son))`
                ;;-- aimed at the two genuinely DEAD copies in C_Control and C_WipeNonce -- took
                ;;this one and its twin as well. Dead-binding cleanup has to be per SITE, never
                ;;per TEXT: the same expression is waste in one function and load-bearing in
                ;;another, and the only difference is whether the body reads it.
                (owner:string (ref-DPDC::UR_OwnerKonto id son))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_Control" "setup")
                        (ref-IGNIS::UC_IgnisPrice "DPNF|C_Control" "setup"))
                owner (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_TogglePause:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_TogglePause (Medium on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_TogglePause" "setup")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_TogglePause" "setup"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_AddQuantity:object{IgnisCollectorV3.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_AddQuantity (Small on SFT owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;minting-type op: NO special issuance price (owner 2026-09-06) — generic tier
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_AddQuantity" "setup")
                (ref-DPDC::UR_OwnerKonto id true) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_RespawnNFT:object{IgnisCollectorV3.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_RespawnNFT (Medium on NFT owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;minting-type op: NO special issuance price (owner 2026-09-06) — generic tier
                (ref-IGNIS::UC_IgnisPrice "DPNF|C_Respawn" "setup")
                (ref-DPDC::UR_OwnerKonto id false) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_BurnSFT:object{IgnisCollectorV3.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_BurnSFT (Small on SFT owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;NOTE: core reader name != Talos op name — billed as DPSF|C_Burn
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_Burn" "setup")
                (ref-DPDC::UR_OwnerKonto id true) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_WipeSlim:object{IgnisCollectorV3.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_WipeSlim (Smallest on SFT owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;NOTE: core reader name != Talos op name — billed as DPSF|C_WipeNoncePartialy
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_WipeNoncePartialy" "setup")
                (ref-DPDC::UR_OwnerKonto id true) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_BurnNFT:object{IgnisCollectorV3.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_BurnNFT (Medium on NFT owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;NOTE: core reader name != Talos op name — billed as DPNF|C_Burn
                (ref-IGNIS::UC_IgnisPrice "DPNF|C_Burn" "setup")
                (ref-DPDC::UR_OwnerKonto id false) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_WipeNonce:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_WipeNonce (Small if son else Big, on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;RESTORED 2026-09-22. This binding IS read, two lines down, as the cumulator's
                ;;active account. A blanket removal of `(owner:string (UR_OwnerKonto id son))`
                ;;-- aimed at the two genuinely DEAD copies in C_Control and C_WipeNonce -- took
                ;;this one and its twin as well. Dead-binding cleanup has to be per SITE, never
                ;;per TEXT: the same expression is waste in one function and load-bearing in
                ;;another, and the only difference is whether the body reads it.
                (owner:string (ref-DPDC::UR_OwnerKonto id son))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_WipeNonce" "setup")
                        (ref-IGNIS::UC_IgnisPrice "DPNF|C_WipeNonce" "setup"))
                owner (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: DPDC-MNG|S>CTRL
    (defun XI_Control (id:string son:bool cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        (require-capability (DPDC-MNG|S>CTRL id son))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|Specs id son 
                (ref-DPDC::UDC_Control id son cu cco ccc casr ctncr cf cw cp)
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPDC-MNG|S>TG_PAUSE
    (defun XI_TogglePause (id:string son:bool toggle:bool)
        (require-capability (DPDC-MNG|S>TG_PAUSE id son toggle))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|IsPaused id son toggle)
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPDC-MNG|C>ADD-QUANTITY
    (defun XI_IncreaseClassZeroSemiFungible (account:string id:string nonce:integer amount:integer)
        (require-capability (DPDC-MNG|C>ADD-QUANTITY account id nonce amount))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (nonce-supply:integer (ref-DPDC::UR_NonceSupply id true nonce))
            )
            ;;Credit SFT Nonce
            (ref-DPDC-C::XB_CreditSFT-Nonce account id nonce amount)
            ;;Update Nonce Supplies
            (ref-DPDC::XE_U|NonceSupply id nonce (+ amount nonce-supply))
        )
    )
    ;;Protection: Class 3 — Custom: DPDC-MNG|C>IZ-CLASS-ZERO
    (defun XI_DecreaseClassZeroSemiFungibles
        (account:string id:string nonces:[integer] amounts:[integer] wipe-mode:bool)
        @doc "Only Positive, Class 0 Nonces can be burned directly with this function \
            \ Negative (Fragment Nonces) and Class Non-0 Nonces (Set Nonces) are protected by direct burning."
        (require-capability (DPDC-MNG|C>IZ-CLASS-ZERO id true nonces))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                ;;
                (l1:integer (length nonces))
            )
            ;;Debit SFT Nonce(s)
            (if (= l1 1)
                (ref-DPDC-C::XE_DebitSFT-Nonce account id (at 0 nonces) (at 0 amounts) wipe-mode)
                (ref-DPDC-C::XE_DebitSFT-Nonces account id nonces amounts wipe-mode)
            )
            ;;Update Nonce Supplies
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (amount:integer (at idx amounts))
                            (nonce-supply:integer (ref-DPDC::UR_NonceSupply id true nonce))
                        )
                        ;;Update Nonce Supply
                        (ref-DPDC::XE_U|NonceSupply id nonce (- nonce-supply amount))
                    )
                )
                (enumerate 0 (- l1 1))
            )
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPDC-MNG|C>IZ-CLASS-ZERO
    (defun XI_DecreaseClassZeroNonFungibles
        (account:string id:string nonces:[integer] wipe-mode:bool)
        (require-capability (DPDC-MNG|C>IZ-CLASS-ZERO id false nonces))
        (let
            (
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                ;;
                (l1:integer (length nonces))
            )
            ;;Debit NFT Nonce(s)
            (if (= l1 1)
                (ref-DPDC-C::XE_DebitNFT-Nonce account id (at 0 nonces) 1 wipe-mode)
                (ref-DPDC-C::XE_DebitNFT-Nonces account id nonces (make-list l1 1) wipe-mode)
            )
        )
    )
    ;;{5.7}  User [A/C]
    (defun UEV_ExecutorIsCollectionOwner (executor:string id:string son:bool)
        @doc "BINDS <executor> to the collection owner, (UR_OwnerKonto id son), via DPDC. \
            \ \
            \ Used by the two spec entrypoints and by all six WIPE entrypoints, and by nothing \
            \ else in this module -- which is the distinction that matters here. The BURN \
            \ entrypoints have the same shapes and do NOT call it, because their authority is \
            \ the account's own signature: DPDC-C's DPDC|CX>MULTI-DEBIT runs \
            \ (if wipe-mode (CAP_Owner id son) (CAP_EnforceAccountOwnership account)), and the \
            \ burns pass wipe-mode FALSE. \
            \ \
            \ So whether a given account in this module is the ACTOR or the TARGET is decided \
            \ by a boolean handed to a capability two modules away. Reading these twelve \
            \ signatures cannot tell you; only following wipe-mode can. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_ExecutorIsOwnerKonto executor id son)
        )
    )
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string son:bool cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        @doc "Updates a collection's mutable specification flags. \
            \ \
            \ HANDOFF 4g: DPDC::CAP_Owner enforces on the DERIVED (UR_OwnerKonto id son) and names \
            \ no actor. UEV_ExecutorIsCollectionOwner supplies it; the ownership enforce is KEPT. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        ;;THE `let` THAT WAS HERE IS GONE, AND SO IS ITS ref-DPDC. It existed only to bind
        ;;(owner (UR_OwnerKonto id son)), which the body never read -- a table read on a live
        ;;path for nothing. Removing the dead binding left the modref with no consumer, and
        ;;_conformance's [dead-modref-binding] rule said so immediately. Two dead things, one
        ;;of which only became visible once the other went.
        (with-capability (DPDC-MNG|S>CTRL id son)
            (XI_Control id son cu cco ccc casr ctncr cf cw cp)
            (URCi_Control id son)
        )
    )
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string son:bool toggle:bool)
        @doc "Pauses or unpauses a collection. \
            \ \
            \ HANDOFF 4g: DPDC::CAP_Owner enforces on the DERIVED (UR_OwnerKonto id son) and names \
            \ no actor. UEV_ExecutorIsCollectionOwner supplies it; the ownership enforce is KEPT. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (with-capability (DPDC-MNG|S>TG_PAUSE id son toggle)
            (XI_TogglePause id son toggle)
            (URCi_TogglePause id son)
        )
    )
    ;;
    ;;  [CREDIT-SINGLE]
    ;;  [SFT]
    (defun C_AddQuantity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "Adds quantity to an existing SFT nonce. \
            \ \
            \ Executor: PROVEN DIRECTLY, and in THIS module rather than down the debit chain. The \
            \ old <account> WAS the actor: the entrypoint capability runs \
            \ CAP_EnforceAccountOwnership on it outright, so this is a pure RENAME. \
            \ \
            \ A CREDIT, NOT A DEBIT -- which is why it does not share its siblings' route. The burn \
            \ and wipe entrypoints defer authority to DPDC-C's DPDC|CX>MULTI-DEBIT and are told apart \
            \ by <wipe-mode>; nothing here goes through that. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DPDC-MNG|C>ADD-QUANTITY executor id nonce amount)
            (XI_IncreaseClassZeroSemiFungible executor id nonce amount)
            (URCi_AddQuantity id)
        )
    )
    ;;  [NFT]
    (defun C_RespawnNFT:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string nonce:integer)
        @doc "Respawns a previously burned NFT. \
            \ \
            \ Executor: PROVEN DIRECTLY, and in THIS module rather than down the debit chain. The \
            \ old <account> WAS the actor: the entrypoint capability runs \
            \ CAP_EnforceAccountOwnership on it outright, so this is a pure RENAME. \
            \ \
            \ A CREDIT, NOT A DEBIT -- which is why it does not share its siblings' route. The burn \
            \ and wipe entrypoints defer authority to DPDC-C's DPDC|CX>MULTI-DEBIT and are told apart \
            \ by <wipe-mode>; nothing here goes through that. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
            )
            (with-capability (DPDC-MNG|C>RESPAWN-NFT executor id nonce)
                (ref-DPDC-C::XB_CreditNFT-Nonce executor id nonce 1)
                (URCi_RespawnNFT id)
            )
        )
    )
    ;;
    ;;  [DEBIT-SINGLE]
    ;;  [SFT]
    (defun C_BurnSFT:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "Burns SFT quantity from the executor's own account. \
            \ \
            \ Executor: PROVEN DIRECTLY. The old <account> WAS the actor -- the debit chain bottoms \
            \ out in DPDC-C's DPDC|CX>MULTI-DEBIT, whose authority is \
            \ (if wipe-mode (CAP_Owner id son) (CAP_EnforceAccountOwnership account)), and this \
            \ entrypoint passes wipe-mode FALSE. So the account signs for itself. A RENAME. \
            \ \
            \ ITS WIPE TWIN HAS THE SAME SIGNATURE AND THE OPPOSITE ACTOR. C_WipeSlim takes exactly \
            \ these parameters and passes wipe-mode TRUE, which selects CAP_Owner -- so there the \
            \ account is the EXECUTEE and the collection owner is the executor. The discriminator \
            \ is a boolean two modules away. (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DPDC-MNG|C>BURN-SFT executor id nonce amount)
            ;;Burn Semifungible and Update Supplies
            (XI_DecreaseClassZeroSemiFungibles executor id [nonce] [amount] false)
            ;;Costs 2 IGNIS per Burn Event
            (URCi_BurnSFT id)
        )
    )
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string nonce:integer amount:integer)
        @doc "Partially wipes an SFT nonce from the executee. \
            \ \
            \ HANDOFF 4g. Nothing in THIS module proves any account: the capability chain runs only \
            \ STATE checks (UEV_AccountFreezeState, UEV_CanWipeON, supply bounds). Authority lives \
            \ in DPDC-C's DPDC|CX>MULTI-DEBIT -- (if wipe-mode (CAP_Owner id son) ...) -- and this \
            \ entrypoint passes wipe-mode TRUE, so the authority is the COLLECTION OWNER, derived as \
            \ (UR_OwnerKonto id son) and naming no actor. \
            \ \
            \ <account> became <executee>: it is wiped, not consulted. Its twin C_BurnSFT/C_BurnNFT \
            \ has the SAME signature and passes wipe-mode FALSE, which makes that same parameter the \
            \ EXECUTOR. Identical shapes, opposite roles, decided by a boolean two modules away. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id true)
        (with-capability (DPDC-MNG|C>WIPE-SFT-NONCE-PARTIALLY executee id nonce amount)
            ;;Burn Semifungible and Update Supplies
            (XI_DecreaseClassZeroSemiFungibles executee id [nonce] [amount] true)
            ;;Costs 1 IGNIS for Partial Nonce Wipe Event
            (URCi_WipeSlim id)
        )
    )
    ;;  [NFT]
    (defun C_BurnNFT:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string nonce:integer)
        @doc "Burns an NFT from the executor's own account. \
            \ \
            \ Executor: PROVEN DIRECTLY. The old <account> WAS the actor -- the debit chain bottoms \
            \ out in DPDC-C's DPDC|CX>MULTI-DEBIT, whose authority is \
            \ (if wipe-mode (CAP_Owner id son) (CAP_EnforceAccountOwnership account)), and this \
            \ entrypoint passes wipe-mode FALSE. So the account signs for itself. A RENAME. \
            \ \
            \ ITS WIPE TWIN HAS THE SAME SIGNATURE AND THE OPPOSITE ACTOR. C_WipeSlim takes exactly \
            \ these parameters and passes wipe-mode TRUE, which selects CAP_Owner -- so there the \
            \ account is the EXECUTEE and the collection owner is the executor. The discriminator \
            \ is a boolean two modules away. (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DPDC-MNG|C>BURN-NFT executor id nonce)
            ;; #79: TWO latent bugs here, never triggered because DPNF|C_Burn had no test coverage:
            ;;  (1) called via ref-DPDC-C:: but XI_DecreaseClassZeroNonFungibles is a LOCAL XI_ of
            ;;      DPDC-MNG (defined above) — must be a local call;
            ;;  (2) args were (id executor …) but the signature is (executor id nonces wipe-mode), so
            ;;      executor/id were swapped → the composed IZ-CLASS-ZERO cap check used the executor
            ;;      as the collection id and failed. Correct order is executor first, then id.
            (XI_DecreaseClassZeroNonFungibles executor id [nonce] false)
            (URCi_BurnNFT id)
        )
    )
    ;;  [SFT+NFT]
    (defun C_WipeNonce:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool nonce:integer)
        @doc "Totally wipes one nonce from the executee. \
            \ \
            \ HANDOFF 4g. Nothing in THIS module proves any account: the capability chain runs only \
            \ STATE checks (UEV_AccountFreezeState, UEV_CanWipeON, supply bounds). Authority lives \
            \ in DPDC-C's DPDC|CX>MULTI-DEBIT -- (if wipe-mode (CAP_Owner id son) ...) -- and this \
            \ entrypoint passes wipe-mode TRUE, so the authority is the COLLECTION OWNER, derived as \
            \ (UR_OwnerKonto id son) and naming no actor. \
            \ \
            \ <account> became <executee>: it is wiped, not consulted. Its twin C_BurnSFT/C_BurnNFT \
            \ has the SAME signature and passes wipe-mode FALSE, which makes that same parameter the \
            \ EXECUTOR. Identical shapes, opposite roles, decided by a boolean two modules away. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (if son
                (let
                    (
                        (amount:integer (ref-DPDC::UR_AccountNonceSupply executee id true nonce))
                    )
                    (with-capability (DPDC-MNG|C>WIPE-SFT-NONCE-TOTALLY executee id nonce amount)
                        (XI_DecreaseClassZeroSemiFungibles executee id [nonce] [amount] true)
                        (URCi_WipeNonce id son)
                    )
                )
                (with-capability (DPDC-MNG|C>WIPE-NFT-NONCE executee id nonce)
                    (XI_DecreaseClassZeroNonFungibles executee id [nonce] true)
                    (URCi_WipeNonce id son)
                )
            )
        )
    )
    ;;
    ;;  [DEBIT-MULTIPLE]
    ;;  [SFT+NFT]
    (defun CC_WipeHeavy:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool)
        @doc "Wipes every viable nonce from the executee (heavy scan). \
            \ \
            \ HANDOFF 4g. Nothing in THIS module proves any account: the capability chain runs only \
            \ STATE checks (UEV_AccountFreezeState, UEV_CanWipeON, supply bounds). Authority lives \
            \ in DPDC-C's DPDC|CX>MULTI-DEBIT -- (if wipe-mode (CAP_Owner id son) ...) -- and this \
            \ entrypoint passes wipe-mode TRUE, so the authority is the COLLECTION OWNER, derived as \
            \ (UR_OwnerKonto id son) and naming no actor. \
            \ \
            \ <account> became <executee>: it is wiped, not consulted. Its twin C_BurnSFT/C_BurnNFT \
            \ has the SAME signature and passes wipe-mode FALSE, which makes that same parameter the \
            \ EXECUTOR. Identical shapes, opposite roles, decided by a boolean two modules away. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (C_WipePure patron executor executee id son (URHC_WipePure executee id son))
    )
    (defun C_WipePure:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        @doc "Wipes a pre-computed removable-nonce set from the executee. \
            \ \
            \ HANDOFF 4g. Nothing in THIS module proves any account: the capability chain runs only \
            \ STATE checks (UEV_AccountFreezeState, UEV_CanWipeON, supply bounds). Authority lives \
            \ in DPDC-C's DPDC|CX>MULTI-DEBIT -- (if wipe-mode (CAP_Owner id son) ...) -- and this \
            \ entrypoint passes wipe-mode TRUE, so the authority is the COLLECTION OWNER, derived as \
            \ (UR_OwnerKonto id son) and naming no actor. \
            \ \
            \ <account> became <executee>: it is wiped, not consulted. Its twin C_BurnSFT/C_BurnNFT \
            \ has the SAME signature and passes wipe-mode FALSE, which makes that same parameter the \
            \ EXECUTOR. Identical shapes, opposite roles, decided by a boolean two modules away. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (viable-nonces:[integer] (at "r-nonces" removable-nonces-obj))
                (viable-amounts:[integer] (at "r-amounts" removable-nonces-obj))
            )
            (if son
                (with-capability (DPDC-MNG|C>WIPE-SFT-NONCES executee id viable-nonces)
                    ;;Burn SemiFungible and Update Nonce Supplies
                    (XI_DecreaseClassZeroSemiFungibles executee id viable-nonces viable-amounts true)
                )
                (with-capability (DPDC-MNG|C>WIPE-NFT-NONCES executee id viable-nonces)
                    ;;Burn NonFungible
                    (XI_DecreaseClassZeroNonFungibles executee id viable-nonces true)
                )
            )
            ;;Costs 2 IGNIS per Nonce Wiped
            (URCi_WipeCumulator id son removable-nonces-obj)
        )
    )
    (defun C_WipeClean:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool nonces:[integer])
        @doc "Wipes the named nonces from the executee. \
            \ \
            \ HANDOFF 4g. Nothing in THIS module proves any account: the capability chain runs only \
            \ STATE checks (UEV_AccountFreezeState, UEV_CanWipeON, supply bounds). Authority lives \
            \ in DPDC-C's DPDC|CX>MULTI-DEBIT -- (if wipe-mode (CAP_Owner id son) ...) -- and this \
            \ entrypoint passes wipe-mode TRUE, so the authority is the COLLECTION OWNER, derived as \
            \ (UR_OwnerKonto id son) and naming no actor. \
            \ \
            \ <account> became <executee>: it is wiped, not consulted. Its twin C_BurnSFT/C_BurnNFT \
            \ has the SAME signature and passes wipe-mode FALSE, which makes that same parameter the \
            \ EXECUTOR. Identical shapes, opposite roles, decided by a boolean two modules away. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (C_WipePure patron executor executee id son
                (UDC_RemovableNonces
                    nonces
                    (ref-DPDC::UR_AccountNoncesSupplies executee id son nonces)
                )
            )
        )
    )
    (defun C_WipeDirty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool nonces:[integer])
        @doc "Wipes the viable subset of the named nonces from the executee. \
            \ \
            \ HANDOFF 4g. Nothing in THIS module proves any account: the capability chain runs only \
            \ STATE checks (UEV_AccountFreezeState, UEV_CanWipeON, supply bounds). Authority lives \
            \ in DPDC-C's DPDC|CX>MULTI-DEBIT -- (if wipe-mode (CAP_Owner id son) ...) -- and this \
            \ entrypoint passes wipe-mode TRUE, so the authority is the COLLECTION OWNER, derived as \
            \ (UR_OwnerKonto id son) and naming no actor. \
            \ \
            \ <account> became <executee>: it is wiped, not consulted. Its twin C_BurnSFT/C_BurnNFT \
            \ has the SAME signature and passes wipe-mode FALSE, which makes that same parameter the \
            \ EXECUTOR. Identical shapes, opposite roles, decided by a boolean two modules away. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIsCollectionOwner executor id son)
        (C_WipePure patron executor executee id son (URC_FilterAccountViableNonces executee id son nonces))
    )
    (defun Cp_WipeSlice:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string son:bool removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes exactly ONE <URHC_BuildWipeSlicePlan> slice of \
            \ <account>'s <id> nonces (SFT if <son>, else NFT). Order-independent and retryable: \
            \ slices are disjoint by construction, the frozen target account cannot move nonces \
            \ mid-campaign, and a replayed/duplicate slice REVERTS (a wiped nonce's account \
            \ supply is 0, failing the 0 < amount enforce in REMOVE-CLASS-ZERO-NONCES) — no job \
            \ state, the live table is the completion ledger. Same authority chain as \
            \ <C_WipePure>: collection owner via wipe-mode debit, can-wipe ON, target frozen, \
            \ escrow split-data guard intact. True Cp_ — no heavy read anywhere in its tree \
            \ (SFT amounts are re-read LIVE inside the cap; a stale plan cannot over-wipe)."
        (P|UEV_IMC)
        (let
            (
                (viable-nonces:[integer] (at "r-nonces" removable-nonces-obj))
                (viable-amounts:[integer] (at "r-amounts" removable-nonces-obj))
            )
            (if son
                (with-capability (DPDC-MNG|C>WIPE-SFT-NONCES account id viable-nonces)
                    ;;Burn SemiFungible and Update Nonce Supplies
                    (XI_DecreaseClassZeroSemiFungibles account id viable-nonces viable-amounts true)
                )
                (with-capability (DPDC-MNG|C>WIPE-NFT-NONCES account id viable-nonces)
                    ;;Burn NonFungible
                    (XI_DecreaseClassZeroNonFungibles account id viable-nonces true)
                )
            )
            ;;Costs 2 IGNIS per Nonce Wiped
            (URCi_WipeCumulator id son removable-nonces-obj)
        )
    )

)

;; --- tables for 06_DPDC-MNG.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)


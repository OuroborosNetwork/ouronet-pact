;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 3 of 22
;; This is STEP 3 of 23 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-2 must have run first, including the init steps between deploys.
;; 3 source file(s), 350,668 gas measured in the REPL gas model, 308,356 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/07_ELITE.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact
;;
;; TOTAL: 5 interface(s), 3 module(s), 12 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact
;;      interface  DpofUdcV2
;;      interface  DemiourgosPactOrtoFungibleV2
;;      module     DPOF
;;      table      P|T
;;      table      P|MT
;;      table      DPOF|T|Properties
;;      table      DPOF|T|Nonces
;;      table      DPOF|T|VerumRoles
;;      table      DPOF|T|AccountRoles
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/07_ELITE.pact
;;      interface  EliteV2
;;      module     ELITE
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact
;;      interface  AutostakeV3
;;      interface  AutostakeComputerV2
;;      module     ATS
;;      table      P|T
;;      table      P|MT
;;      table      ATS|Pairs
;;      table      ATS|Ledger
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact ====================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpofUdcV2
    @doc "Exposes DPOF UDC Constructors"

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
    ;;  SCHEMAS
    ;;
    (defschema DPOF|Properties
        id:string
        owner-konto:string
        name:string
        ticker:string
        decimals:integer
        ;;
        can-upgrade:bool
        can-change-owner:bool
        can-add-special-role:bool
        can-transfer-oft-create-role:bool
        can-freeze:bool
        can-wipe:bool
        can-pause:bool
        segmentation:bool
        ;;
        is-paused:bool
        nonces-used:integer
        nonces-excluded:integer
        ;;
        supply:decimal
        ;;
        reward-bearing-token:string
        vesting-link:string
        sleeping-link:string
        hibernation-link:string
        ;;
    )
    ;;Nonces cant be separated. A Ortofungible Nonce has one unique holder.
    (defschema DPOF|NonceElement
        holder:string                       ;;Stores the <OuronetAccount> holding the nonce - mutable
        id:string                           ;;ID of the Ortofungible - immutable.
        value:integer                       ;;Stores the Nonce value itself - immutable.
        supply:decimal                      ;;Nonce Supply - mutable
        meta-data-chain:[object]            ;;Stores Nonce Metadata - immutable
    )
    (defschema DPOF|VerumRoles
        a-frozen:[string]
        r-oft-add-quantity:[string]
        r-oft-burn:[string]
        r-oft-create:string
        r-transfer:[string]
    )
    (defschema DPOF|AccountRoles
        total-account-supply:decimal        ;; Holds the Total Account Supply for id
        frozen:bool                         ;; multiple
        role-oft-add-quantity:bool          ;; multiple
        role-oft-burn:bool                  ;; multiple
        role-oft-create:bool                ;; single
        role-transfer:bool                  ;; multiple
        ;;
        ;;ForSelect, store Key Make-up
        id:string
        account:string
    )
    (defschema RemovableNonces
        @doc "Removable Nonces are Class 0 Nonces held by a given Account with greater than 0 supply \
        \ Given an <account>, a dpdc <id>, and a list of <nonces>, they can be filtered to Removable Nonces"
        r-nonces:[integer]
        r-amounts:[decimal]
    )
    (defschema DPOF|WipeSlicePlan
        @doc "Hydra wipe slice plan: the URHC_WipePure output partitioned into <slice-count> \
        \ disjoint contiguous |RemovableNonces| slices, each fed to one <Cp_WipeSlice> tx. \
        \ Offline plan only (UI dirty-read) — never persisted on-chain."
        account:string
        id:string
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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DemiourgosPactOrtoFungibleV2
    @doc "Exposes Functions related to Orto-Fungibles \
        \ Orto-Fungibles are the next Evoloution of the Meta-Fungibles \
        \ using a newer and more efficient Architecture, and fixing discovered bugs \
        \ \
        \ The most important functionality is the ability for an Ouronet Account to own \
        \ as many Nonces (Elements) as needed without any limitations \
        \ which was the main reason Orto-Fungible was created \
        \ \
        \ Existing Meta-Fungible <id> and <accounts> will have to be migrated to Orto-Fungibles \
        \ Luckily Meta-Fungible usage hasnt properly started at the time of Orto-Fungible Deployment"

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
    ;;
    ;;  [UDC]
    ;;
    (defun UDC_NonceElement:object{DpofUdcV2.DPOF|NonceElement}
        (a:string b:string c:integer d:decimal e:[object])
    )
    (defun UDC_VerumRoles:object{DpofUdcV2.DPOF|VerumRoles}
        (a:[string] b:[string] c:[string] d:string e:[string])
    )
    (defun UDC_AccountRoles:object{DpofUdcV2.DPOF|AccountRoles}
        (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string)
    )
    (defun UDC_RemovableNonces:object{DpofUdcV2.RemovableNonces}
        (a:[integer] b:[decimal])
    )
    (defun UDC_WipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan}
        (a:string b:string c:integer d:[object{DpofUdcV2.RemovableNonces}])
    )
    ;;{5.2}  Compute [UC]
    ;;
    ;;  [UC]
    ;;
    (defun UC_IdNonce:string (id:string nonce:integer))
    (defun UC_IdAccount:string (id:string account:string))
    (defun UC_IzSingular:bool (id:string nonces:[integer]))
    (defun UC_IzConsecutive:bool (id:string nonces:[integer]))
    (defun UCv_TakePureWipe:object{DpofUdcV2.RemovableNonces} (input:object{DpofUdcV2.RemovableNonces} size:integer))
    (defun UC_ComputeMinWipeSliceCount:integer (nonce-count:integer))
    (defun UC_BuildWipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan}
        (account:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces} slice-count:integer))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCi_MoveCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string nonces:[integer] transmit-or-transfer:bool))
    (defun URCi_WipeCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
    ;;  [URCi] composer/price cost readers — single source per op (the C_/XE_ bills them, INFO previews from them)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string))
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_AddQuantity:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_UpdateSpecialOrtoFungible:object{IgnisCollectorV3.OutputCumulator} (main-dptf:string))
    (defun URCi_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_IssueGas:decimal (token-count:integer))
    (defun URCi_IssueStoa:decimal (token-count:integer))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    (defun URCi_DeployAccount:object{IgnisCollectorV3.OutputCumulator} (account:string))
    ;;
    ;;  [UR]
    ;;
    (defun UR_P-KEYS:[string] ())
    (defun UR_N-KEYS:[string] ())
    (defun UR_V-KEYS:[string] ())
    (defun UR_KEYS:[string] ())
    ;;
    ;;  [0] DPOF|T|Properties:{DpofUdcV2.DPOF|Properties}
    (defun UR_Konto:string (id:string))
    (defun UR_Name:string (id:string))
    (defun UR_Ticker:string (id:string))
    (defun UR_Decimals:integer (id:string))
    (defun UR_CanUpgrade:bool (id:string))
    (defun UR_CanChangeOwner:bool (id:string))
    (defun UR_CanAddSpecialRole:bool (id:string))
    (defun UR_CanTransferOftCreateRole:bool (id:string))
    (defun UR_CanFreeze:bool (id:string))
    (defun UR_CanWipe:bool (id:string))
    (defun UR_CanPause:bool (id:string))
    (defun UR_IsPaused:bool (id:string))
    (defun UR_Segmentation:bool (id:string))
    (defun UR_NoncesUsed:integer (id:string))
    (defun UR_NoncesExcluded:integer (id:string))
    (defun UR_Supply:decimal (id:string))
    (defun UR_RewardBearingToken:string (id:string))
    (defun UR_Vesting:string (id:string))
    (defun UR_Sleeping:string (id:string))
    (defun UR_Hibernation:string (id:string))
    (defun UR_IzId:bool (id:string))
    ;;
    ;;  [1] DPOF|T|Nonces:{DpofUdcV2.DPOF|NonceElement}
    (defun UR_NonceHolder:string (id:string nonce:integer))
    (defun UR_NonceID:string (id:string nonce:integer))
    (defun UR_NonceValue:integer (id:string nonce:integer))
    (defun UR_NonceSupply:decimal (id:string nonce:integer))
    (defun UR_NonceMetaData:[object] (id:string nonce:integer))
    (defun UR_NoncesSupplies:[decimal] (id:string nonces:[integer]))
    (defun UR_NoncesMetaDatas:[[object]] (id:string nonces:[integer]))
    (defun UR_IzNonce:bool (id:string nonce:integer))
    ;;
    ;;  [2] DPOF|T|VerumRoles:{DpofUdcV2.DPOF|VerumRoles}
    (defun UR_Verum1:[string] (id:string))
    (defun UR_Verum2:[string] (id:string))
    (defun UR_Verum3:[string] (id:string))
    (defun UR_Verum4:string (id:string))
    (defun UR_Verum5:[string] (id:string))
    ;;
    ;;  [3] DPOF|T|AccountRoles:{DpofUdcV2.DPOF|AccountRoles}
    (defun UR_R-Frozen:bool (id:string account:string))
    (defun UR_R-AddQuantity:bool (id:string account:string))
    (defun UR_R-Burn:bool (id:string account:string))
    (defun UR_R-Create:bool (id:string account:string))
    (defun UR_R-Transfer:bool (id:string account:string))
    (defun UR_AccountSupply:decimal (id:string account:string))
    (defun UR_IzAccount:bool (id:string account:string))
    ;;
    ;;  [URC]
    ;;
    (defun URHC_WipePure:object{DpofUdcV2.RemovableNonces} (account:string id:string))
    (defun URHC_BuildWipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan} (account:string id:string slice-count:integer))
    (defun URC_IzRBT:bool (reward-bearing-token:string))
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string))
        ;;
    (defun URC_HasVesting:bool (id:string))
    (defun URC_HasSleeping:bool (id:string))
    (defun URC_HasHibernation:bool (id:string))
    (defun URCv_Parent:string (dpof:string))
    (defun URC_BrandingKonto:string (entity-id:string))
    ;;
    ;;  [URD]
    ;;
    (defun URH_HeldOrtoFungibles:[string] (account:string))
    (defun URH_ExistingOrtoFungibles:[string] (dotf:string))
    (defun URH_OwnedOrtoFungibles:[string] (account:string))
    (defun URH_AccountNonces:[integer] (account:string dpof-id:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_id (id:string))
    (defun UEV_NoncesCirculating (id:string nonces:[integer]))
    (defun UEV_ParentOwnership (id:string))
    (defun UEV_ExecutorIsParentKonto (executor:string entity-id:string))
    (defun UEV_ExecutorIsKonto (executor:string id:string))
    (defun UEV_NoncesToAccount (id:string account:string nonces:[integer]))
    (defun UEV_Amount (id:string amount:decimal))
        ;;
    (defun UEV_UpdateRewardBearingToken (id:string))
    (defun UEV_CanUpgradeON (id:string))
    (defun UEV_CanChangeOwnerON (id:string))
    (defun UEV_CanAddSpecialRoleON (id:string))
    (defun UEV_CanTransferOftCreateRoleON (id:string))
    (defun UEV_CanFreezeON (id:string))
    (defun UEV_CanWipeON (id:string))
    (defun UEV_CanPauseON (id:string))
    (defun UEV_PauseState (id:string state:bool))
        ;;
    (defun UEV_SegmentationState (id:string state:bool))
    (defun UEV_AccountFreezeState (id:string account:string state:bool))
    (defun UEV_AccountAddQuantityState (id:string account:string state:bool))
    (defun UEV_AccountBurnState (id:string account:string state:bool))
    (defun UEV_AccountCreateState (id:string account:string state:bool))
    (defun UEV_AccountTransferState (id:string account:string state:bool))
        ;;
    (defun UEV_Vesting (id:string existance:bool))
    (defun UEV_Sleeping (id:string existance:bool))
    (defun UEV_Hibernation (id:string existance:bool))
    (defun UEV_MoveRoleCheck (id:string sender:string receiver:string))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_Owner (id:string))
    (defun UEV_EnforceSegmentationForTransmit (id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XB_IssueFree:object{IgnisCollectorV3.OutputCumulator}
        (
            account:string
            ;;
            name:[string]
            ticker:[string]
            decimals:[integer]
            ;;
            can-upgrade:[bool]
            can-change-owner:[bool]
            can-add-special-role:[bool]
            can-transfer-oft-create-role:[bool]
            ;;
            can-freeze:[bool]
            can-wipe:[bool]
            can-pause:[bool]
            ;;
            iz-special:[bool]
        )
    )
    (defun XBv_DeployAccount (id:string account:string))
    (defun XB_DeployAccountWNE (account:string id:string))
    (defun XB_InsertNewNonce (nonce-owner:string id:string nonce:integer amount:decimal meta-data-chain:[object]))
    (defun XE_UpdateRewardBearingToken (atspair:string hot-rbt:string))
    (defun XE_UpdateSpecialOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (main-dptf:string secondary-dpof:string vzh-tag:integer)
    )
    (defun XB_W|AccountRoles (id:string account:string account-data:object{DpofUdcV2.DPOF|AccountRoles}))
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string 
            name:[string] ticker:[string] decimals:[integer]
            can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool]
            can-freeze:[bool] can-wipe:[bool] can-pause:[bool]
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string))
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool))
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string toggle:bool))
        ;;
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
    (defun C_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string))
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string toggle:bool))
        ;;
    (defun C_AddQuantity:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string nonce:integer amount:decimal))
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string nonce:integer amount:decimal))
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string id:string amount:decimal meta-data-chain:[object]))
        ;;
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string nonce:integer amount:decimal))
    (defun CC_WipeHeavy:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string))
    (defun C_WipePure:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
    (defun C_WipeClean:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string nonces:[integer]))
    (defun Cp_WipeSlice:object{IgnisCollectorV3.OutputCumulator} (id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
        ;;
    (defun C_Transmit:object{IgnisCollectorV3.OutputCumulator} (patron:string sender:string receiver:string id:string nonces:[integer] amounts:[decimal] method:bool))
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator} (patron:string sender:string receiver:string id:string nonces:[integer] method:bool))
    (defun C_BulkTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string sender:string receiver-lst:[string] id:string nonces-array:[[integer]] method:bool)
    )

)
;;
(module DPOF GOV
    @doc "DPOF — the OrtoFungible token core, the modern successor to DPMF for \
        \ metadata-rich, NFT-like fungibles; implements DemiourgosPactOrtoFungibleV2 and \
        \ DpofUdcV2. Tables hold token properties, per-nonce elements \
        \ (holder/value/supply/metadata, each nonce single-held), verum roles and \
        \ per-account roles. Client ops cover issue, mint, add-quantity, burn, \
        \ transfer/transmit/bulk-transfer, move-create-role, role and pause/freeze toggles, \
        \ several wipe variants and ownership rotation."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsagePrimaryV2)
    (implements DemiourgosPactOrtoFungibleV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPOF                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPOF_ADMIN)))
    (defcap GOV|DPOF_ADMIN ()                           (enforce-guard GOV|MD_DPOF))
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
    (defcap P|DPOF|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPOF|CALLER))
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
        (with-capability (GOV|DPOF_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPOF_ADMIN)
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
        (with-capability (GOV|DPOF_ADMIN)
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
        (with-capability (GOV|DPOF_ADMIN)
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
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|DPOF|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst OF                                        (at 0 ["Orto-Fungible"]))
    (defconst WIPE-SLICE-MAX-NONCES                     1000
        "Hydra wipe: max nonces per <Cp_WipeSlice> tx. UI SEED + generous backstop, NOT the \
        \ optimizer — the UI /local-simulates each slice and adds slices when one does not fit; \
        \ the node gas meter is the real enforcement (an oversized slice aborts atomically). \
        \ CALIBRATED REPL/Kursan/DPOF-scale-wipe.repl: measured 405.6 gas per nonce wiped => ~4907 nonces fit a \
        \ 2,000,000-gas tx. Set well under that because the probe used the LIGHTEST possible \
        \ nonces (zero URI data, no metadata); real nonces carry more payload per row.")
    (defconst ATS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|ATS|SC_NAME)
        )
    )
    ;;{3.2}  schemas
    ;;
    (defschema TransmitData
        input-nonces:[integer]
        input-amounts:[decimal]
        output-nonces:[integer]
        meta-data-array:[[object]]
    )
    ;;{3.3}  tables
    (deftable DPOF|T|Properties:{DpofUdcV2.DPOF|Properties})        ;;Key = <DPOF-id>      
    (deftable DPOF|T|Nonces:{DpofUdcV2.DPOF|NonceElement})          ;;Key = <DSOF-id> + BAR + <nonce>
    (deftable DPOF|T|VerumRoles:{DpofUdcV2.DPOF|VerumRoles})        ;;Key = <DPOF-id>
    (deftable DPOF|T|AccountRoles:{DpofUdcV2.DPOF|AccountRoles})    ;;Key = <DPOF-id> + BAR + <account> 

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap DPOF|S>ROTATE-OWNERSHIP (id:string new-owner:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_SenderWithReceiver (UR_Konto id) new-owner)
            (ref-DALOS::UEV_EnforceAccountExists new-owner)
            (CAP_Owner id)
            (UEV_CanChangeOwnerON id)
        )
    )
    (defcap DPOF|S>CONTROL (id:string)
        @event
        (CAP_Owner id )
        (UEV_CanUpgradeON id)
    )
    (defcap DPOF|S>CREDIT-SINGULAR (account:string id:string nonce:integer amount:decimal)
        ;;Nonce must be held by Account (also indirectly validates that account exists)
        (UEV_NoncesToAccount id account [nonce])
        ;;Amount must be validated
        (UEV_Amount id amount)
        ;;Nonce must be in circulation
        (UEV_NoncesCirculating id [nonce])
    )
    (defcap DPOF|S>CREDIT-CONSECUTIVE (account:string id:string nonces:[integer] amounts:[decimal])
        (map
            (lambda
                (idx:integer)
                (let
                    (
                        (amount:decimal (at idx amounts))
                    )
                    (UEV_Amount id amount)
                )
            )
            (enumerate 0 (- (length nonces) 1))
        )
    )
    ;;
    (defcap DPOF|S>PAUSE (id:string pause:bool)
        @doc "Pause and Unpause a DPOF <id>"
        @event
        (CAP_Owner id)
        (UEV_PauseState id (not pause))
        (if pause
            (UEV_CanPauseON id)
            true
        )
    )
    (defcap DPOF|S>X_FREEZE (id:string account:string frozen:bool)
        @doc "Toggle Verum 1"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountFreezeState id account (not frozen))
            (if frozen
                (UEV_CanFreezeON id)
                true
            )
        )
    )
    (defcap DPOF|S>X_TOGGLE-ADD-QUANTITY-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 2"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountAddQuantityState id account (not toggle))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
        )
    )
    (defcap DPOF|S>X_TOGGLE-BURN-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 4"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountBurnState id account (not toggle))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
        )
    )
    (defcap DPOF|S>X_SWITCH-CREATE-ROLE (id:string receiver:string)
        @doc "Switch Verum 4"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (current:string (UR_Verum4 id))
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount receiver)
            (ref-DALOS::UEV_SenderWithReceiver current receiver)
            (CAP_Owner id)
            (UEV_CanTransferOftCreateRoleON id)
        )
    )
    (defcap DPOF|S>X_TOGGLE-TRANSFER-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 5"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (special:[string] ["V|" "Z|"])
                (ft:string (take 2 id))
                (iz-special:bool (contains ft special))
            )
            ;;Vested and Sleeping Special Tokens can use Core Smart Ouronet Accounts for Transfer Roles Setup.
            (if (not iz-special)
                (do
                    (ref-DALOS::UEV_NotSmartOuronetAccount account)
                    (UEV_AccountTransferState id account (not toggle))
                )
                true
            )
            (CAP_Owner id)
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
        )
    )
    (defcap DPOF|S>MOVE (id:string sender:string receiver:string method:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            ;;1]Ownership
            (if (and method (ref-DALOS::UR_AccountType receiver))
                (ref-DALOS::CAP_EnforceAccountOwnership receiver)
                true
            )
            ;;2]Transferability
            (ref-DALOS::UEV_EnforceTransferability sender receiver method)
            ;;3]<id> Pause State and <sender> <receiver> Frozen State
            (UEV_PauseState id false)
            (UEV_AccountFreezeState id sender false)
            (UEV_AccountFreezeState id receiver false)
            ;;4]Transfer Roles Check
            (UEV_MoveRoleCheck id sender receiver)
        )
    )
    (defcap DPOF|S>BULK-MOVE
        (id:string sender:string receiver-lst:[string] method:bool)
        @doc "Bulk move guards — same family as DPOF|S>MOVE over receiver-lst. \
            \ Standard Ouronet accounts only (no smart accounts in receiver-lst)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (l:integer (length receiver-lst))
            )
            (ref-U|LST::UEV_IzUnique receiver-lst)
            (UEV_PauseState id false)
            (UEV_AccountFreezeState id sender false)
            (map
                (lambda (idx:integer)
                    (let
                        (
                            (receiver:string (at idx receiver-lst))
                        )
                        (ref-DALOS::UEV_EnforceAccountType receiver false)
                        (ref-DALOS::UEV_EnforceTransferability sender receiver method)
                        (UEV_AccountFreezeState id receiver false)
                        (UEV_MoveRoleCheck id sender receiver)
                    )
                )
                (enumerate 0 (- l 1))
            )
        )
    )
    ;;{C3}  Composed
    ;;
    ;;#33M (audit note, 2026-08-28): AHU/AU_OrtoFungible(s)/AU_OrtoFungibleAccount(s) are a
    ;;orto-fungible) migration, to batch-repair "id"/"account" key fields on rows carried over
    ;;from that migration. Not a general-purpose admin backdoor: the hardcoded account (AH,
    ;;"AncientHodler"/patron) was intentionally scoped to that one-time historical operation,
    ;;which is now complete - not a substitute for GOV|DPOF_ADMIN and not meant to be a
    ;;permanent alternate admin path. Owner (2026-08-28): "It's that way by design, and I think
    ;;everything is migrated anyway... this was used when migrating from meta to orto fungible."
    ;;Kept for historical reference, same retention rationale as DPMF itself (see #1C). No
    ;;functional change made - documentation only.
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
    ;;UNUSED here. DALOS defines the same cap and DOES use it (with-capability (SECURE-ADMIN));
    ;;DPOF's admin paths acquire GOV|DPOF_ADMIN directly instead, so this composite is never
    ;;reached. It sits beside AHU, the migration-era admin cap the owner explicitly retained for
    ;;historical reference (#33M), which is why it is documented rather than deleted: the same
    ;;retention rationale may apply. Flagged 2026-09-10.
    (defcap SECURE-ADMIN ()
        (compose-capability (SECURE))
        (compose-capability (GOV|DPOF_ADMIN))
    )
    (defcap DPOF|C>UPDATE-BRD (dpof:string)
        @event
        (UEV_ParentOwnership dpof)
        (compose-capability (P|DPOF|CALLER))
    )
    (defcap DPOF|C>UPGRADE-BRD (dpof:string)
        @event
        (UEV_ParentOwnership dpof)
        (compose-capability (P|DPOF|CALLER))
    )
    ;;
    (defcap DPOF|C>ISSUE 
        (
            account:string name:[string] ticker:[string] decimals:[integer]
            can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool]
            can-freeze:[bool] can-wipe:[bool] can-pause:[bool]
        )
        @event
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-U|INT::UEV_UniformList 
                [
                    (length name)
                    (length ticker)
                    (length decimals)
                    (length can-upgrade)
                    (length can-change-owner)
                    (length can-add-special-role)
                    (length can-transfer-oft-create-role)
                    (length can-freeze)
                    (length can-wipe)
                    (length can-pause)
                ]
            )
            (ref-U|LST::UEV_IzUnique name)
            (ref-U|LST::UEV_IzUnique ticker)
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;
    (defcap DPOF|C>ADD-QTY (client:string id:string nonce:integer amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership client)
            (UEV_AccountAddQuantityState id client true)
            (compose-capability (DPOF|C>CREDIT client id [nonce] [amount] [[{}]]))
        )
    )
    (defcap DPOF|C>BURN (client:string id:string nonce:integer amount:decimal)
        @event
        (let
            (
                (nonce-supply:decimal (UR_NonceSupply id nonce))
            )
            (UEV_AccountBurnState id client true)
            (if (< amount nonce-supply)
                (UEV_SegmentationState id true)
                true
            )
            (compose-capability (DPOF|C>DEBIT client id [nonce] [amount] false))
        )
    )
    (defcap DPOF|C>MINT (client:string id:string amount:decimal meta-data-chain:[object])
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (nonces-used:integer (UR_NoncesUsed id))
                (owner:string (UR_Konto id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership client)
            (UEV_AccountAddQuantityState id client true)
            (if (and (= owner ATS|SC_NAME) (!= client owner))
                (enforce false "Only the ATS owner can mint when the owner is ATS")
                (UEV_AccountCreateState id client true)
            )
            (compose-capability (DPOF|C>CREDIT client id [(+ nonces-used 1)] [amount] [meta-data-chain]))
        )
    )
    (defcap DPOF|C>WIPE-SLIM (account:string id:string nonce:integer amount:decimal)
        @event
        (UEV_SegmentationState id true)
        (compose-capability (DPOF|C>X_WIPE account id [nonce] [amount]))
    )
    (defcap DPOF|C>WIPE (account:string id:string nonces:[integer])
        @event
        (compose-capability (DPOF|C>X_WIPE account id nonces (UR_NoncesSupplies id nonces)))
    )
    (defcap DPOF|C>X_WIPE (account:string id:string nonces:[integer] amounts:[decimal])
        ;;Nonces must be held by <account>
        (UEV_NoncesToAccount id account nonces)
        ;;Orto-Fungible is frozen on target account
        (UEV_AccountFreezeState id account true)
        ;;Orto-Fungible has <can-wipe> on
        (UEV_CanWipeON id)
        ;;Neeeded Capabilities
        (compose-capability (DPOF|C>DEBIT account id nonces amounts true))
    )
    ;;
    (defcap DPOF|C>DEBIT (account:string id:string nonces:[integer] amounts:[decimal] wipe-mode:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (l1:integer (length nonces))
                (l2:integer (length amounts))
            )
            (enforce (= l1 l2) "Invalid Inputs for Debitation")
            ;;A repeated nonce would let each index's pre-write <= nonce-supply check pass against the
            ;;same stale supply value, then debit it more than once at write time — supply-negative
            ;;corruption (DALOS audit #3C). Single shared gate for C_Transmit/C_WipePure/C_WipeClean/etc.
            ;;UEV_IzUnique is [string]-typed; nonces are integers, so stringify first.
            (ref-U|LST::UEV_IzUnique (map (lambda (n:integer) (int-to-str 10 n)) nonces))
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (amount:decimal (at idx amounts))
                            (nonce-supply:decimal (UR_NonceSupply id nonce))
                        )
                        (enforce
                            ;;Cannot Debit into the negatives
                            (<= amount nonce-supply)
                            (format "Cannot Debit into the Negatives for {} {} Nonce {} on Account {}" [OF id nonce account])
                        )
                        (UEV_Amount id amount)
                        ;;<UEV_CirculatingNonce> is indirectly verified via the <enforce> above and <UEV_Amount> 
                        ;;(since non circulating nonce have supply -1.0 and amount must be greater than 0 and smaller than <nonce-supply>)
                    )
                    
                )
                (enumerate 0 (- l1 1))
            )
            ;;Enforces <account> ownership needed for Debitation
            (if wipe-mode
                (CAP_Owner id)
                (ref-DALOS::CAP_EnforceAccountOwnership account)
            )
            ;;Checks all <nonces> are owned by Account
            (UEV_NoncesToAccount id account nonces)
            ;:For XI Functions
            (compose-capability (SECURE))
        )
    )
    (defcap DPOF|C>CREDIT (account:string id:string nonces:[integer] amounts:[decimal] meta-data-array:[[object]])
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (iz-singular:bool (UC_IzSingular id nonces))
                (iz-consecutive:bool (UC_IzConsecutive id nonces))
                (l1:integer (length nonces))
                (l2:integer (length amounts))
                (l3:integer (length meta-data-array))
            )
            (ref-U|INT::UEV_UniformList [l1 l2 l3])
            (enforce-one
                "Invalid Nonce Chain for Creditation"
                [
                    (enforce iz-singular "Nonce Chain is not Singular")
                    (enforce iz-consecutive "Nonce Chain is not Consecutive")
                ]
            )
            ;;UNREACHABLE (both this enforce and its mirror in the iz-consecutive branch below):
            ;;each fires only if BOTH predicates hold at once, and they are mutually exclusive.
            ;;UC_IzSingular = length 1 AND the nonce EXISTS; UC_IzConsecutive = the run starts at
            ;;nonces-used + 1, i.e. the nonces DO NOT exist yet. At length 1 "consecutive" means
            ;;exactly nonces-used + 1, which is by definition unused, so UR_IzNonce is false and
            ;;singular is false; at length > 1 singular is false anyway. Fail-closed backstops.
            ;;Demonstrated in REPL/modules/DPOF.repl <<DPOF-G3b>>.
            (if iz-singular
                (do
                    (enforce (not iz-consecutive) "Nonce Chain must compute false for Consecutive")
                    (compose-capability (DPOF|S>CREDIT-SINGULAR account id (at 0 nonces) (at 0 amounts)))
                )
                true
            )
            (if iz-consecutive
                (do
                    ;;UNREACHABLE: the mirror of the backstop above -- iz-singular and
                    ;;iz-consecutive are mutually exclusive for every input, so this enforce can
                    ;;never see both true. See the note on the iz-singular branch for the proof,
                    ;;and REPL/modules/DPOF.repl <<DPOF-G3b>> for the demonstration.
                    (enforce (not iz-singular) "Nonce Chain must compute false for Singular")
                    (compose-capability (DPOF|S>CREDIT-CONSECUTIVE account id nonces amounts))
                )
                true
            )
            (compose-capability (SECURE))
        )
    )
    ;;
    (defcap DPOF|C>FREEZE (id:string account:string frozen:bool)
        @doc "Toggle Verum 1"
        @event
        (compose-capability (DPOF|S>X_FREEZE id account frozen))
        (compose-capability (SECURE))
    )
    (defcap DPOF|C>TOGGLE-ADD-QUANTITY-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 2"
        @event
        (compose-capability (DPOF|S>X_TOGGLE-ADD-QUANTITY-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPOF|C>TOGGLE-BURN-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 3"
        @event
        (compose-capability (DPOF|S>X_TOGGLE-BURN-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPOF|C>SWITCH-CREATE-ROLE (id:string receiver:string)
        @doc "Switch Verum 4"
        @event
        (compose-capability (DPOF|S>X_SWITCH-CREATE-ROLE id receiver))
        (compose-capability (SECURE))
    )
    (defcap DPOF|C>TOGGLE-TRANSFER-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 5"
        @event
        (compose-capability (DPOF|S>X_TOGGLE-TRANSFER-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    ;;
    (defcap DPOF|C>TRANSMIT (id:string td:object{TransmitData} sender:string receiver:string method:bool)
        @event
        (let
            (   
                (input-nonces:[integer] (at "input-nonces" td))
                (input-amounts:[decimal] (at "input-amounts" td))
                (output-nonces:[integer] (at "output-nonces" td))
                (meta-data-array:[[object]] (at "meta-data-array" td))
            )
            (UEV_SegmentationState id true)
            (compose-capability (DPOF|C>DEBIT sender id input-nonces input-amounts false))
            (compose-capability (DPOF|C>CREDIT receiver id output-nonces input-amounts meta-data-array))
            (compose-capability (DPOF|S>MOVE id sender receiver method))
        )
    )
    (defcap DPOF|C>TRANSFER (id:string nonces:[integer] sender:string receiver:string method:bool)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership sender)
            ;;A repeated nonce would let XI_TransferWholeNonces sum its supply more than once into
            ;;sender/receiver total-account-supply while only moving the nonce itself once — fabricated
            ;;supply inflation/deflation (DALOS audit #3C). UEV_IzUnique is [string]-typed; stringify first.
            (ref-U|LST::UEV_IzUnique (map (lambda (n:integer) (int-to-str 10 n)) nonces))
            (UEV_NoncesToAccount id sender nonces)
            (UEV_NoncesCirculating id nonces)
            (compose-capability (DPOF|S>MOVE id sender receiver method))
            (compose-capability (SECURE))
        )
    )
    (defcap DPOF|C>BULK-TRANSFER
        (id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        @doc "Whole-nonce bulk transfer (multiple receivers). Composes DPOF|S>BULK-MOVE like C>TRANSFER composes S>MOVE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (l:integer (length receiver-lst))
                (all-nonces:[integer] (UC_FlattenNoncesArray nonces-array))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership sender)
            (enforce
                (fold (and) true
                    [
                        (> l 0)
                        (= l (length nonces-array))
                        (> (length all-nonces) 0)
                    ]
                )
                "Invalid DPOF bulk transfer: receiver/nonces legs or nonce list"
            )
            ;;Uniqueness across the FULL flattened set — blocks both a duplicate within one receiver's
            ;;own leg and the same nonce appearing in two different receivers' legs (each leg calls
            ;;XI_TransferWholeNonces independently; either case fabricates supply — DALOS audit #3C).
            ;;UEV_IzUnique is [string]-typed; stringify first.
            (ref-U|LST::UEV_IzUnique (map (lambda (n:integer) (int-to-str 10 n)) all-nonces))
            (UEV_NoncesToAccount id sender all-nonces)
            (UEV_NoncesCirculating id all-nonces)
            (compose-capability (DPOF|S>BULK-MOVE id sender receiver-lst method))
            (compose-capability (SECURE))
        )
    )
    (defcap DPOF|C>UPDATE-SPECIAL (main-dptf:string secondary-dpof:string vzh-tag:integer)
        (enforce (contains vzh-tag [1 2 3]) "Invalid Vesting|Sleeping|Hibernation Tag")
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (main-special-id:string
                    (cond
                        ((= vzh-tag 1) (ref-DPTF::UR_Vesting main-dptf))
                        ((= vzh-tag 2) (ref-DPTF::UR_Sleeping main-dptf))
                        ((= vzh-tag 3) (ref-DPTF::UR_Hibernation main-dptf))
                        BAR
                    )
                )
                (secondary-special-id:string
                    (cond
                        ((= vzh-tag 1) (UR_Vesting secondary-dpof))
                        ((= vzh-tag 2) (UR_Sleeping secondary-dpof))
                        ((= vzh-tag 3) (UR_Hibernation secondary-dpof))
                        BAR
                    )
                )
                (iz-secondary-rbt:bool (URC_IzRBT secondary-dpof))
                (main-dptf-ftc:string (take 2 main-dptf))
            )
            (ref-DPTF::CAP_Owner main-dptf)
            (CAP_Owner secondary-dpof)
            (enforce
                (and (= main-special-id BAR) (= secondary-special-id BAR) )
                "Special Orto Fungible Links (Vesting, Sleeping or Hibernation) are immutable !"
            )
            ;;UNREACHABLE -- `secondary-dpof` is ALWAYS a DPOF issued moments earlier, and a
            ;;just-issued ortofungible cannot be a Hot-RBT (that requires registration on an ATS
            ;;pair, which cannot have happened yet). The single caller,
            ;;VST::XI_CreateSpecialOrtoFungibleLink, takes the id straight out of its own
            ;;XB_IssueFree cumulator and passes it into XE_UpdateSpecialOrtoFungible in the same
            ;;expression -- no client ever names the secondary.
            ;;EXACT TWIN of 05_DPTF.pact:1004 ("Special True Fungible cannot be RTs or Cold-RBTs"),
            ;;same caller shape, same proof. Fail-closed backstop for a future caller that does
            ;;supply its own secondary.
            (enforce
                (not iz-secondary-rbt)
                "Special Orto Fungible cannot be a Hot-RBT"
            )
            (cond
                ((= vzh-tag 1)
                    (enforce
                        (not (contains main-dptf-ftc ["R|" "F|" "S|" "W|" "P|"]))
                        (format "When setting a Vesting Link, the main DPTF {} cannot be a Special or LP Token" [main-dptf])
                    )
                )
                ((= vzh-tag 2)
                    (enforce
                        (not (contains main-dptf-ftc ["R|" "F|"]))
                        (format "When setting a Sleeping Link, the main DPTF {} cannot be a Special Token" [main-dptf])
                        ;;But can be an LP Token
                    )
                )
                ((= vzh-tag 3)
                    (enforce
                        (not (contains main-dptf-ftc ["R|" "F|" "S|" "W|" "P|"]))
                        (format "When setting a Hibernation Link, the main DPTF {} cannot be a Special or LP Token" [main-dptf])
                    )
                )
                true
            )
            (compose-capability (P|SECURE-CALLER))
        )
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
    (defun UDC_NonceElement:object{DpofUdcV2.DPOF|NonceElement}
        (a:string b:string c:integer d:decimal e:[object])
        {"holder"           : a
        ,"id"               : b
        ,"value"            : c
        ,"supply"           : d
        ,"meta-data-chain"  : e}
    )
    (defun UDC_VerumRoles:object{DpofUdcV2.DPOF|VerumRoles}
        (a:[string] b:[string] c:[string] d:string e:[string])
        {"a-frozen"             : a
        ,"r-oft-add-quantity"   : b
        ,"r-oft-burn"           : c
        ,"r-oft-create"         : d
        ,"r-transfer"           : e}
    )
    (defun UDC_AccountRoles:object{DpofUdcV2.DPOF|AccountRoles}
        (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string)
        {"total-account-supply"     : a
        ,"frozen"                   : b
        ,"role-oft-add-quantity"    : c
        ,"role-oft-burn"            : d
        ,"role-oft-create"          : e
        ,"role-transfer"            : f
        ,"id"                       : g
        ,"account"                  : h}
    )
    (defun UDC_RemovableNonces:object{DpofUdcV2.RemovableNonces}
        (a:[integer] b:[decimal])
        {"r-nonces"     : a
        ,"r-amounts"    : b}
    )
    (defun UDC_WipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan}
        (a:string b:string c:integer d:[object{DpofUdcV2.RemovableNonces}])
        {"account"      : a
        ,"id"           : b
        ,"slice-count"  : c
        ,"slices"       : d}
    )
    (defun UDCx_TransmitData:object{TransmitData}
        (a:[integer] b:[decimal] c:[integer] d:[[object]])
        {"input-nonces"     : a
        ,"input-amounts"    : b
        ,"output-nonces"    : c
        ,"meta-data-array"  : d}
    )
    ;;{5.2}  Compute [UC]
    (defun UC_IdNonce:string (id:string nonce:integer)
        (format "{}{}{}" [id BAR nonce])
    )
    (defun UC_IdAccount:string (id:string account:string)
        (format "{}{}{}" [id BAR account])
    )
    (defun UC_IzSingular:bool (id:string nonces:[integer])
        @doc "Checks if the <[nonces]> is singular; \
        \ Singular <[nonces]> means length is 1, and the nonce exists"
        (let
            (
                (l:integer (length nonces))
                (first-nonce:integer (at 0 nonces))
                (iz-nonce:bool (UR_IzNonce id first-nonce))
            )
            (if (and (= l 1) iz-nonce)
                true
                false
            )
        )
    )
    (defun UC_IzConsecutive:bool (id:string nonces:[integer])
        @doc "Checks if <[nonces]> are consecutive; \
        \ Consecutive means they need to be consecutive, dont exist yet, \
        \ and start imediatly after tha last used nonce"
        (let
            (
                (l:integer (length nonces))
                (nonces-used:integer (UR_NoncesUsed id))
                (last-nonce:integer (at 0 (take -1 nonces)))
                (enumerated:[integer] (enumerate (+ nonces-used 1) last-nonce))
            )
            (if 
                (fold (and) true
                    [
                        (= (+ nonces-used l) last-nonce)
                        (= enumerated nonces)
                        (>= l 1)
                    ]
                )
                true
                false
            )
        )
    )
    (defun UCv_TakePureWipe:object{DpofUdcV2.RemovableNonces} 
        (input:object{DpofUdcV2.RemovableNonces} size:integer)
        @doc "Takes <size> and returns a smaller |object{DpofUdcV2.RemovableNonces}|"
        (let
            (
                (nonces:[integer] (at "r-nonces" input))
                (amounts:[decimal] (at "r-amounts" input))
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
    (defun UC_BuildWipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan}
        (account:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces} slice-count:integer)
        @doc "Hydra wipe partitioner (pure compute, no table reads): splits a |RemovableNonces| \
            \ object into disjoint CONTIGUOUS slices via take/drop index ranges. The requested \
            \ <slice-count> is clamped to [1, nonce-count] and then recomputed from the per-slice \
            \ width, so the returned plan NEVER contains an empty slice (an empty nonce list \
            \ aborts the executor); the plan's own <slice-count> field is the authoritative count."
        (let*
            (
                (nonces:[integer] (at "r-nonces" removable-nonces-obj))
                (amounts:[decimal] (at "r-amounts" removable-nonces-obj))
                (l:integer (length nonces))
                (n-clamped:integer (if (< slice-count 1) 1 (if (> slice-count l) (if (> l 0) l 1) slice-count)))
                (per-slice:integer (UC_CeilDiv (if (> l 0) l 1) n-clamped))
                (n-final:integer (UC_CeilDiv (if (> l 0) l 1) per-slice))
            )
            (UDC_WipeSlicePlan account id n-final
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
    (defun UC_FlattenNoncesArray:[integer] (nonces-array:[[integer]])
        @doc "Concatenate per-receiver nonce slices into one list for bulk custody + IGNIS cumulator."
        (fold
            (lambda (acc:[integer] ns:[integer])
                (+ acc ns)
            )
            []
            nonces-array
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCix_NoncesCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string number-of-nonces:integer price-per-nonce:decimal output-obj:object)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (*
                    (dec number-of-nonces)
                    price-per-nonce
                )
                (UR_Konto id)
                (ref-IGNIS::URC_IsVirtualGasZero)
                [output-obj]
            )
        )
    )
    (defun URCi_MoveCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string nonces:[integer] transmit-or-transfer:bool)
        @doc "PER-NONCE unit for an ortofungible move: transmit costs the small unit, transfer \
            \ the smallest, multiplied by the nonce count in URCix_NoncesCumulator. Units come \
            \ from the IG|LEGS constants, not a DALOS table (owner 2026-09-07)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (URCix_NoncesCumulator 
                id 
                (length nonces)
                (if transmit-or-transfer
                    (ref-IGNIS::UC_IgnisLeg "tier-small")
                    (ref-IGNIS::UC_IgnisLeg "tier-smallest")
                )
                {}
            )
        )
    )
    (defun URCi_WipeCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Wipe IGNIS = 5 ignis PER NONCE WIPED (owner 2026-09-05: ortofungible wiping scales \
            \ with nonce count), sourced from the central IG|WEIGHTS map in the IGNIS module. \
            \ Linear in N, so a Hydra wipe slice bills exactly its own slice. Shared by the exec \
            \ path (C_WipeClean/Heavy/Pure + Cp_WipeSlice) and their INFO_* previews."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (URCix_NoncesCumulator 
                id 
                (length (at "r-nonces" removable-nonces-obj))
                (ref-IGNIS::UC_IgnisWeight "wipe-nonce")
                removable-nonces-obj
            )
        )
    )
    (defun UR_P-KEYS:[string] ()
        (keys DPOF|T|Properties)
    )
    (defun UR_N-KEYS:[string] ()
        (keys DPOF|T|Nonces)
    )
    (defun UR_V-KEYS:[string] ()
        (keys DPOF|T|VerumRoles)
    )
    (defun UR_KEYS:[string] ()
        (keys DPOF|T|AccountRoles)
    )
    ;;
    ;;
    (defun UR_Konto:string (id:string)
        (at "owner-konto" (read DPOF|T|Properties id ["owner-konto"]))
    )
    (defun UR_Name:string (id:string)
        (at "name" (read DPOF|T|Properties id ["name"]))
    )
    (defun UR_Ticker:string (id:string)
        (at "ticker" (read DPOF|T|Properties id ["ticker"]))
    )
    (defun UR_Decimals:integer (id:string)
        (at "decimals" (read DPOF|T|Properties id ["decimals"]))
    )
    ;;
    (defun UR_CanUpgrade:bool (id:string)
        (at "can-upgrade" (read DPOF|T|Properties id ["can-upgrade"]))
    )
    (defun UR_CanChangeOwner:bool (id:string)
        (at "can-change-owner" (read DPOF|T|Properties id ["can-change-owner"]))
    )
    (defun UR_CanAddSpecialRole:bool (id:string)
        (at "can-add-special-role" (read DPOF|T|Properties id ["can-add-special-role"]))
    )
    (defun UR_CanTransferOftCreateRole:bool (id:string)
        (at "can-transfer-oft-create-role" (read DPOF|T|Properties id ["can-transfer-oft-create-role"]))
    )
    (defun UR_CanFreeze:bool (id:string)
        (at "can-freeze" (read DPOF|T|Properties id ["can-freeze"]))
    )
    (defun UR_CanWipe:bool (id:string)
        (at "can-wipe" (read DPOF|T|Properties id ["can-wipe"]))
    )
    (defun UR_CanPause:bool (id:string)
        (at "can-pause" (read DPOF|T|Properties id ["can-pause"]))
    )
    (defun UR_Segmentation:bool (id:string)
        (at "segmentation" (read DPOF|T|Properties id ["segmentation"]))
    )
    ;;
    (defun UR_IsPaused:bool (id:string)
        (at "is-paused" (read DPOF|T|Properties id ["is-paused"]))
    )
    (defun UR_NoncesUsed:integer (id:string)
        (at "nonces-used" (read DPOF|T|Properties id ["nonces-used"]))
    )
    (defun UR_NoncesExcluded:integer (id:string)
        (at "nonces-excluded" (read DPOF|T|Properties id ["nonces-excluded"]))
    )
    ;;
    (defun UR_Supply:decimal (id:string)
        (at "supply" (read DPOF|T|Properties id ["supply"]))
    )
    ;;
    (defun UR_RewardBearingToken:string (id:string)
        (at "reward-bearing-token" (read DPOF|T|Properties id ["reward-bearing-token"]))
    )
    (defun UR_Vesting:string (id:string)
        (at "vesting-link" (read DPOF|T|Properties id ["vesting-link"]))
    )
    (defun UR_Sleeping:string (id:string)
        (at "sleeping-link" (read DPOF|T|Properties id ["sleeping-link"]))
    )
    (defun UR_Hibernation:string (id:string)
        (at "hibernation-link" (read DPOF|T|Properties id ["hibernation-link"]))
    )
    ;;
    (defun UR_IzId:bool (id:string)
        (let
            (
                (trial (try false (read DPOF|T|Properties id))) 
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    ;;
    ;;
    (defun UR_NonceHolder:string (id:string nonce:integer)
        (at "holder" (read DPOF|T|Nonces (UC_IdNonce id nonce) ["holder"]))
    )
    (defun UR_NonceID:string (id:string nonce:integer)
        (at "id" (read DPOF|T|Nonces (UC_IdNonce id nonce) ["id"]))
    )
    (defun UR_NonceValue:integer (id:string nonce:integer)
        (at "value" (read DPOF|T|Nonces (UC_IdNonce id nonce) ["value"]))
    )
    (defun UR_NonceSupply:decimal (id:string nonce:integer)
        (at "supply" (read DPOF|T|Nonces (UC_IdNonce id nonce) ["supply"]))
    )
    (defun UR_NonceMetaData:[object] (id:string nonce:integer)
        (at "meta-data-chain" (read DPOF|T|Nonces (UC_IdNonce id nonce) ["meta-data-chain"]))
    )
    (defun UR_NoncesSupplies:[decimal] (id:string nonces:[integer])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] element:integer)
                    (ref-U|LST::UC_AppL acc (UR_NonceSupply id element))
                )
                []
                nonces
            )
        )
    )
    (defun UR_NoncesMetaDatas:[[object]] (id:string nonces:[integer])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[[object]] element:integer)
                    (ref-U|LST::UC_AppL acc (UR_NonceMetaData id element))
                )
                []
                nonces
            )
        )
    )
    (defun UR_IzNonce:bool (id:string nonce:integer)
        (let
            (
                (trial (try false (read DPOF|T|Nonces (UC_IdNonce id nonce))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    ;;
    ;;
    (defun UR_Verum1:[string] (id:string)
        (at "a-frozen" (read DPOF|T|VerumRoles id ["a-frozen"]))
    )
    (defun UR_Verum2:[string] (id:string)
        (at "r-oft-add-quantity" (read DPOF|T|VerumRoles id ["r-oft-add-quantity"]))
    )
    (defun UR_Verum3:[string] (id:string)
        (at "r-oft-burn" (read DPOF|T|VerumRoles id ["r-oft-burn"]))
    )
    (defun UR_Verum4:string (id:string)
        (at "r-oft-create" (read DPOF|T|VerumRoles id ["r-oft-create"]))
    )
    (defun UR_Verum5:[string] (id:string)
        (at "r-transfer" (read DPOF|T|VerumRoles id ["r-transfer"]))
    )
    ;;
    ;;
    (defun UR_R-Frozen:bool (id:string account:string)
        ;;(at "frozen" (read DPOF|T|AccountRoles (UC_IdAccount id account) ["frozen"]))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (and
                (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                    { "frozen" : false}
                    { "frozen" := fr }
                    fr
                )
                (not (ref-DALOS::UR_AutonomicRoles account))
            )
        )
    )
    (defun UR_R-AddQuantity:bool (id:string account:string)
        ;;(at "role-oft-add-quantity" (read DPOF|T|AccountRoles (UC_IdAccount id account) ["role-oft-add-quantity"]))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                    { "role-oft-add-quantity" : false}
                    { "role-oft-add-quantity" := roaq }
                    roaq
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
        )
    )
    (defun UR_R-Burn:bool (id:string account:string)
        ;;(at "role-oft-burn" (read DPOF|T|AccountRoles (UC_IdAccount id account) ["role-oft-burn"]))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                    { "role-oft-burn" : false}
                    { "role-oft-burn" := rob }
                    rob
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
        )
    )
    (defun UR_R-Create:bool (id:string account:string)
        ;;(at "role-oft-create" (read DPOF|T|AccountRoles (UC_IdAccount id account) ["role-oft-create"]))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (owner:string (UR_Konto id))
            )
            (fold (or) false
                [
                    (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                        { "role-oft-create" : false}
                        { "role-oft-create" := roc }
                        roc
                    )
                    (= account owner)
                    (ref-DALOS::UR_AutonomicRoles account)
                ]
            )
        )
    )
    (defun UR_R-Transfer:bool (id:string account:string)
        ;;(at "role-transfer" (read DPOF|T|AccountRoles (UC_IdAccount id account) ["role-transfer"]))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                    { "role-transfer" : false}
                    { "role-transfer" := rt }
                    rt
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
        )
    )
    ;;
    (defun UR_AccountSupply:decimal (id:string account:string)
        (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
            { "total-account-supply" : 0.0 }
            { "total-account-supply" := tas}
            tas
        )
    )
    (defun UR_IzAccount:bool (id:string account:string)
        (let
            (
                (trial (try false (read DPOF|T|AccountRoles (UC_IdAccount id account))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    ;;
    ;;
    (defun URHC_WipePure:object{DpofUdcV2.RemovableNonces} (account:string id:string)
        @doc "Uses Expensive Read Functions to obtain a |object{DpofUdcV2.RemovableNonces}| that can be used \
            \ to execute a <C_WipePure>, bypassing the expensive gas costs of using (keys...) or (select...) functions"
        (let
            (
                (nonces:[integer] (URH_AccountNonces account id))
                (amounts:[decimal] (UR_NoncesSupplies id nonces))
            )
            (UDC_RemovableNonces nonces amounts)
        )
    )
    (defun URHC_BuildWipeSlicePlan:object{DpofUdcV2.DPOF|WipeSlicePlan}
        (account:string id:string slice-count:integer)
        @doc "Hydra wipe PREFLIGHT (UI /local ONLY — the one heavy read of the flow): dirty-reads \
            \ the full wipeable set via <URHC_WipePure> and partitions it into the slice plan. \
            \ The UI fires one <Cp_WipeSlice> tx per slice, all in parallel; a re-read after a \
            \ partial campaign naturally returns the outstanding remains (re-plan is implicit). \
            \ Seed <slice-count> with <UC_ComputeMinWipeSliceCount>."
        (UC_BuildWipeSlicePlan account id (URHC_WipePure account id) slice-count)
    )
    (defun URC_IzRBT:bool (reward-bearing-token:string)
        @doc "Returns a boolean, if token id is RBT in any atspair"
        (UEV_id reward-bearing-token)
        (if (= (UR_RewardBearingToken reward-bearing-token) BAR)
            false
            true
        )
    )
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string)
        @doc "Returns a boolean, if token id is RBT in a specific atspair"
        (UEV_id reward-bearing-token)
        (if (= (UR_RewardBearingToken reward-bearing-token) BAR)
            false
            (if (= (UR_RewardBearingToken reward-bearing-token) atspair)
                true
                false
            )
        )
    )
    ;;
    (defun URC_HasVesting:bool (id:string)
        @doc "Returns a boolean if DPOF has a vesting counterpart"
        (if (= (UR_Vesting id) BAR)
            false
            true
        )
    )
    (defun URC_HasSleeping:bool (id:string)
        @doc "Returns a boolean if DPOF has a sleeping counterpart"
        (if (= (UR_Sleeping id) BAR)
            false
            true
        )
    )
    (defun URC_HasHibernation:bool (id:string)
        @doc "Returns a boolean if DPOF has a hibernation counterpart"
        (if (= (UR_Hibernation id) BAR)
            false
            true
        )
    )
    (defun URCv_Parent:string (dpof:string)
        ;;#31M fix: dropped the "Sleeping LP Tokens not allowed" enforce (moved to
        ;;UEV_ParentOwnership, the only caller that actually needs it - see its own @doc). A
        ;;URC_* must never enforce; the read-context caller (DPL-UR's wallet-listing helper)
        ;;needs a pure derivation and the existing "Z|" branch below already handles a
        ;;Sleeping-LP-shaped id correctly, same as any other Sleeping token.
        @doc "Computes <dpof> parent"
        (let
            (
                (first-two:string (take 2 dpof))
            )
            (cond
                ((= first-two "V|") (UR_Vesting dpof))
                ((= first-two "Z|") (UR_Sleeping dpof))
                ((= first-two "H|") (UR_Hibernation dpof))
                dpof
            )
        )
    )
    (defun URC_BrandingKonto:string (entity-id:string)
        @doc "The account with BRANDING AUTHORITY over <entity-id>: the PARENT token's owner, \
            \ or the entity's own owner when it IS its own parent. \
            \ \
            \ Exists because that rule was being retyped at call sites, and got retyped WRONG: \
            \ the patron/executor migration inserted `(UR_Konto (URCv_Parent x))` as the \
            \ executor for the branding entrypoints, which is right only for a PURE entity. \
            \ For a derived one -- `Z|VST-...` -- the parent is a DPTF id, so the read hit \
            \ DPOF's own properties table and died with \
            \ `No value found in table ... for key: VST-...`. \
            \ UEV_ExecutorIsParentKonto already computed this correctly; this is that \
            \ computation, named once and callable, so a call site never has to branch."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (parent:string (URCv_Parent entity-id))
            )
            (if (= parent entity-id) (UR_Konto entity-id) (ref-DPTF::UR_Konto parent))
        )
    )

    ;;
    ;;  [URD]
    ;;
    ;;1] Returns True Fungibles held by Account
    (defun URH_HeldOrtoFungibles:[string] (account:string)
        @doc "Returns all Orto Fungibles that are registered for a given <account>"
        (map (at "id")
            (select DPOF|T|AccountRoles ["id"]
                (where "account" (= account))
            )
        )
    )
    ;;2]Returns Accounts that are registered for a given DPTF
    (defun URH_ExistingOrtoFungibles:[string] (dotf:string)
        @doc "Returns all Ouronet Accounts that are registered for a given <dotf>"
        (map (at "account")
            (select DPOF|T|AccountRoles ["account"]
                (where "id" (= dotf))
            )
        )
    )
    ;;3]Returns a List of DPOFs that are owned by a given Account for Management Purposes
    (defun URH_OwnedOrtoFungibles:[string] (account:string)
        @doc "Returns all Orto Fungibles that can be managed by the given <account>"
        (map (at "id")
            (select DPOF|T|Properties ["id"]
                (where "owner-konto" (= account))
            )
        )
    )
    ;;4]
    (defun URH_AccountNonces:[integer] (account:string dpof-id:string)
        (map (at "value")
            (select DPOF|T|Nonces ["value"]
                (and?
                    (where "id" (= dpof-id))
                    (where "holder" (= account))
                )
            )
        )
    )
    ;;
    ;;
    ;;[URCi] cost readers — single cost source per op. The C_/XE_ returns/bills its URCi; Phase 1.2 INFO
    ;;  previews from the same reader. (Per-nonce wipe/move costs are URCi_WipeCumulator/URCi_MoveCumulator.)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_BrandingCumulator (UR_Konto entity-id) 1.5)
        )
    )
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_RotateOwnership" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_Control" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_TogglePause" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_ToggleFreezeAccount" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_ToggleAddQuantityRole" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_ToggleBurnRole" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_MoveCreateRole" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_ToggleTransferRole" "usage")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_AddQuantity:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_AddQuantity" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_Burn" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_WipeSlim" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateSpecialOrtoFungible:object{IgnisCollectorV3.OutputCumulator} (main-dptf:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-IGNIS::UDC_LegCumulator "special-of-link" (ref-DPTF::UR_Konto main-dptf))
        )
    )
    ;;  Mint: URCi is the Medium price part; C_Mint concatenates the created-nonce output onto it.
    (defun URCi_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_Mint" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;  Issue/UpgradeBranding: :decimal price rails (the cumulator output/side-effect stays in the write).
    (defun URCi_IssueGas:decimal (token-count:integer)
        @doc "IGNIS issuance price per token. Sourced from the CENTRAL IG|DETER map in the \
            \ IGNIS module (rehaul substage 5, 1 ignis = 1 cent): ortofungible issuance = $10 = 1000 ignis/token (owner 2026-09-05); VST links inherit this. \
            \ Shared by the exec path and its INFO_* preview, so both move as one."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            ;;deterrence scales PER TOKEN; the op's own compute is charged ONCE
            (+ (* (dec token-count) (ref-IGNIS::UC_IgnisDeter "issue-of"))
               (ref-IGNIS::UC_IgnisComponents "DPOF|C_Issue"))
        )
    )
    (defun URCi_IssueStoa:decimal (token-count:integer)
        @doc "STOA leg of issuance, per token. Carries the SAME DOLLAR VALUE as the IGNIS deter \
            \ (ortofungible = $10 => 100 STOA), converted at the live STOA price by UC_StoaPrice — so \
            \ when a real STOA price replaces the $0.10 peg the AMOUNT moves but the value the \
            \ user pays does not. Shared by the exec path and its INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (* (dec token-count) (ref-IGNIS::UC_StoaPrice "issue-of"))
        )
    )
    (defun URCi_UpgradeBranding:decimal (months:integer)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (ref-BRD::URCi_UpgradeBranding months)
        )
    )
    ;;  DeployAccount: CORE C_DeployAccount returns no cumulator; the ignis|small toll is billed
    ;;  by Talos keyed on the deployed account. This reader single-sources that toll for exec + INFO.
    (defun URCi_DeployAccount:object{IgnisCollectorV3.OutputCumulator} (account:string)
        @doc "IGNIS cost of DELIBERATE token-account creation (the explicit C_DeployAccount \
            \ entrypoint, billed at its Talos wrapper): the central IG|DETER token-account tier \
            \ (50) — an anti-spam deterrent per owner 2026-09-05. Auto-creation inside a transfer \
            \ never reaches this reader and stays FREE (S1 constraint). Shared by exec + INFO_*."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_DeployAccount" "token-account")
                account (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;3]Returns a 
    (defun UEV_id (id:string)
        (with-default-read DPOF|T|Properties id
            { "supply" : -1.0 }
            { "supply" := s }
            (enforce
                (>= s 0.0)
                (format "DPOF ID {} does not exist" [id])
            )
        )
    )
    (defun UEV_NoncesCirculating (id:string nonces:[integer])
        @doc "Validates that <nonces> are in circulation"
        (map
            (lambda
                (element:integer)
                (let
                    (
                        (nonce-supply:decimal (UR_NonceSupply id element))
                    )
                    (enforce 
                        (!= nonce-supply -1.0) 
                        (format "{} {} Nonce {} must be in Circulation for exec"[OF id element])
                    )
                )
            )
            nonces
        )
    )
    (defun UEV_ExecutorIsParentKonto (executor:string entity-id:string)
        @doc "BINDS <executor> to the branding authority for <entity-id>: the PARENT token's \
            \ owner, or the entity's own owner when it IS its own parent. Ownership is proven \
            \ by UEV_ParentOwnership inside the branding capability; this supplies the other \
            \ half -- that the account the caller NAMED is that owner."
        (enforce (= executor (URC_BrandingKonto entity-id)) "Executor is not the Parent Token Owner")
    )
    (defun UEV_ExecutorIsKonto (executor:string id:string)
        @doc "BINDS the named <executor> to DPOF <id>'s owner. Ownership of <executor> is proven \
            \ INDIRECTLY -- every entrypoint calling this reaches <CAP_Owner id>, which enforces \
            \ ownership of <(UR_Konto id)>. This supplies the other half: that the account the \
            \ caller NAMED is that same owner. Without it the executor parameter would be \
            \ decorative, which is worse than absent because it reads as verified. \
            \ (patron/executor canon 2.2 -- an indirect route is permitted and MUST be named.) \
            \ \
            \ NOT used by C_Mint / C_AddQuantity / C_Burn: their capabilities enforce \
            \ CAP_EnforceAccountOwnership on the executor DIRECTLY, so it is already proven."
        (enforce (= executor (UR_Konto id)) "Executor is not the Token Owner")
    )
    (defun UEV_ParentOwnership (id:string)
        @doc "Enforces: \
            \ <id> Ownership, if <id> is pure \
            \ <(UR_Vesting id)>, if its a Vested ID \
            \ <(UR_Sleeping id)>, if its a Sleeping ID \
            \ <(UR_Hibernation id)>, if its a Hibernation ID \
            \ While ensuring a Sleeping LP cant be used for this operation."
        (let
            (
                (fourth:string (drop 3 (take 4 id)))
            )
            ;;#31M fix: moved here from URCv_Parent, which must never enforce - this is the only
            ;;caller that actually needs this rejection (per this function's own @doc).
            ;;
            ;;HOISTED 2026-09-17, ABOVE the <parent> binding, and the note that used to sit here was
            ;;half wrong in a way worth recording. It said flatly that this enforce was UNPINNED and
            ;;UNREACHABLE -- that <parent>, bound eagerly by URCv_Parent, READS the properties table,
            ;;so any sleeping-LP id aborts in that read first, and that reaching it "needs a REAL
            ;;issued sleeping-LP token, which no suite creates".
            ;;
            ;;Measured, both halves: `URCv_Parent` only reads for ids prefixed `V|`, `Z|` or `H|`;
            ;;every other shape falls through to its `dpof` default with NO read at all. So
            ;;`Z|X|NOSUCH-…` did abort on the raw table key exactly as described, while
            ;;`ABC|NOSUCH-…` reached this enforce and produced its written message. A PARTIAL shadow,
            ;;not a total one -- the same shape as DEFECT-LEDGER G-10.
            ;;
            ;;<fourth> is a pure string slice of <id> and needs no table access, so the guard is
            ;;simply hoisted above the binding. Both shapes now refuse in the written words, which is
            ;;also what the DPTF twin does (it enforces before its read) -- the twin is pinned by
            ;;REPL/modules/DPTF.repl <<DPTF-G5>>, and this one by <<DPOF-G16>>.
            (enforce (!= fourth BAR) "Sleeping LP Tokens not allowed for this operation")
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (parent:string (URCv_Parent id))
                )
                (if (= parent id)
                    (CAP_Owner id)
                    (ref-DPTF::CAP_Owner parent)
                )
            )
        )
    )
    (defun UEV_NoncesToAccount (id:string account:string nonces:[integer])
        @doc "Enforces <nonces> of <id> are held by <account>"
        (map
            (lambda
                (idx:integer)
                (let
                    (
                        (nonce:integer (at idx nonces))
                        (nonce-holder:string (UR_NonceHolder id nonce))
                    )
                    (enforce (= account nonce-holder) (format "Nonce {} of DPOF {} is not owned by account" [nonce id account]))
                )
            )
            (enumerate 0 (- (length nonces)1))
        )
    )
    (defun UEV_Amount (id:string amount:decimal)
        (let
            (
                (decimals:integer (UR_Decimals id))
            )
            (enforce
                (= (floor amount decimals) amount)
                (format "{} is not conform with the {} prec" [amount id])
            )
            (enforce
                (> amount 0.0)
                (format "{} is not a Valid Transaction amount" [amount])
            )
        )
    )
    ;;
    (defun UEV_UpdateRewardBearingToken (id:string)
        (let
            (
                (rbt:string (UR_RewardBearingToken id))
            )
            (enforce (= rbt BAR) (format "{} as an RBT is immutable tied to an ATS-Pair" [OF]))
        )
    )
    ;;
    (defun UEV_CanUpgradeON (id:string)
        (let
            (
                (x:bool (UR_CanUpgrade id))
            )
            (enforce (= x true) (format "{} {} properties cannot be upgraded" [OF id]))
        )
    )
    (defun UEV_CanChangeOwnerON (id:string)
        (let
            (
                (x:bool (UR_CanChangeOwner id))
            )
            (enforce (= x true) (format "{} {} ownership cannot be changed" [OF id]))
        )
    )
    (defun UEV_CanAddSpecialRoleON (id:string)
        (let
            (
                (x:bool (UR_CanAddSpecialRole id))
            )
            (enforce (= x true) (format "For {} {} no special roles can be added" [OF id]))
        )
    )
    (defun UEV_CanTransferOftCreateRoleON (id:string)
        (let
            (
                (x:bool (UR_CanTransferOftCreateRole id))
            )
            (enforce (= x true) (format "{} Token {} cannot have its create role transfered" [OF id]))
        )
    )
    (defun UEV_CanFreezeON (id:string)
        (let
            (
                (x:bool (UR_CanFreeze id))
            )
            (enforce (= x true) (format "{} {} cannot be freezed" [OF id]))
        )
    )
    (defun UEV_CanWipeON (id:string)
        (let
            (
                (x:bool (UR_CanWipe id))
            )
            (enforce (= x true) (format "{} {} cannot be wiped" [OF id]))
        )
    )
    (defun UEV_CanPauseON (id:string)
        (let
            (
                (x:bool (UR_CanPause id))
            )
            (enforce (= x true) (format "{} {} cannot be paused" [OF id])
            )
        )
    )
    (defun UEV_PauseState (id:string state:bool)
        (let
            (
                (x:bool (UR_IsPaused id))
            )
            (if state
                (enforce x (format "{} {} is already unpaused" [OF id]))
                (enforce (= x false) (format "{} {} is already paused" [OF id]))
            )
        )
    )
    ;;
    (defun UEV_SegmentationState (id:string state:bool)
        (let
            (
                (x:bool (UR_Segmentation id))
            )
            (enforce (= x state) (format "Segmentation state for {} {} must be set to {} for exec" [OF id state]))
        )
    )
    (defun UEV_EnforceSegmentationForTransmit (id:string)
        @doc "C_Transmit and AQP OrtoFungible Transmit stake/unstake: issued DPOF id with segmentation enabled."
        (UEV_id id)
        (UEV_SegmentationState id true)
    )
    (defun UEV_AccountFreezeState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_R-Frozen id account))
            )
            (enforce (= x state) (format "Frozen for {} {} on Account {} must be set to {} for exec" [OF id account state]))
        )
    )
    (defun UEV_AccountAddQuantityState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_R-AddQuantity id account))
            )
            (enforce (= x state) (format "Add Quantity Role for {} {} on Account {} must be set to {} for exec" [OF id account state]))
        )
    )
    (defun UEV_AccountBurnState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_R-Burn id account))
            )
            (enforce (= x state) (format "Burn Role for {} {} on Account {} must be set to {} for exec" [OF id account state]))
        )
    )
    (defun UEV_AccountCreateState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_R-Create id account))
            )
            (enforce (= x state) (format "Create Role for {} {} on Account {} must be set to {} for exec" [OF id account state]))
        )
    )
    (defun UEV_AccountTransferState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_R-Transfer id account))
            )
            (enforce (= x state) (format "Transfer Role for {} {} on Account {} must be set to {} for exec" [OF id account state]))
        )
    )
    ;;
    (defun UEV_Vesting (id:string existance:bool)
        (let
            (
                (has-vesting:bool (URC_HasVesting id))
            )
            (enforce (= has-vesting existance) (format "Vesting for the Token {} {} is not satisfied with existance {}" [OF id existance]))
        )
    )
    (defun UEV_Sleeping (id:string existance:bool)
        (let
            (
                (has-sleeping:bool (URC_HasSleeping id))
            )
            (enforce (= has-sleeping existance) (format "Sleeping for the Token {} {} is not satisfied with existance {}" [OF id existance]))
        )
    )
    (defun UEV_Hibernation (id:string existance:bool)
        (let
            (
                (has-hibernation:bool (URC_HasHibernation id))
            )
            (enforce (= has-hibernation existance) (format "Hibernation for the Token {} {} is not satisfied with existance {}" [OF id existance]))
        )
    )
    (defun UEV_MoveRoleCheck (id:string sender:string receiver:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (verum-five:[string] (UR_Verum5 id))
                (lvf:integer (length verum-five))
                (transfer-roles:integer
                    (if (and (= lvf 1) (= verum-five [BAR]))
                        0 lvf
                    )
                )
                (are-transfer-roles-active:bool (if (> transfer-roles 0) true false))
                (ss:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sr:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                (allow:string (format "{} Transfer from {} to {} is allowed" [OF ss sr]))
            )
            (if are-transfer-roles-active
                (let
                    (
                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                        (ouroboros:string (ref-DALOS::GOV|OUROBOROS|SC_NAME))
                        (dalos:string (ref-DALOS::GOV|DALOS|SC_NAME))
                        ;;
                        (sender-transfer-role:bool (UR_R-Transfer id sender))
                        (receiver-transfer-role:bool (UR_R-Transfer id receiver))
                    )
                    (enforce-one
                        (format "Incompatible Transfer Roles from {} to {}" [ss sr])
                        [
                            (enforce sender-transfer-role (format "Incompatible Transfer Role for Sender {}" [ss]))
                            (enforce receiver-transfer-role (format "Incompatible Transfer Role for Receiver {}" [sr]))
                        ]
                    )
                )
                allow
            )
        )
    )
    (defun CAP_Owner (id:string)
        @doc "Enforces DPOF Token ID Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_Konto id))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_TransferWholeNonces
        (id:string sender:string receiver:string nonces:[integer])
        @doc "Move whole <nonces> from <sender> to <receiver> — shared by C_Transfer and C_BulkTransfer."
        (require-capability (SECURE))
        (let
            (
                (sender-supply:decimal (UR_AccountSupply id sender))
                (receiver-supply:decimal (UR_AccountSupply id receiver))
                (nonces-supplies:[decimal] (UR_NoncesSupplies id nonces))
                (sum:decimal (fold (+) 0.0 nonces-supplies))
            )
            (XB_DeployAccountWNE receiver id)
            (XI_UpdateAccountSupply id sender (- sender-supply sum))
            (XI_UpdateAccountSupply id receiver (+ receiver-supply sum))
            (map
                (lambda
                    (element:integer)
                    (XI_UpdateNonceHolder id element receiver)
                )
                nonces
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPOF|C>ISSUE
    (defun XB_IssueFree:object{IgnisCollectorV3.OutputCumulator}
        (
            account:string
            ;;
            name:[string]
            ticker:[string]
            decimals:[integer]
            ;;
            can-upgrade:[bool]
            can-change-owner:[bool]
            can-add-special-role:[bool]
            can-transfer-oft-create-role:[bool]
            ;;
            can-freeze:[bool]
            can-wipe:[bool]
            can-pause:[bool]
            ;;
            iz-special:[bool]
        )
        (P|UEV_IMC)
        (with-capability 
            (DPOF|C>ISSUE 
                account name ticker decimals    
                can-upgrade can-change-owner can-add-special-role can-transfer-oft-create-role
                can-freeze can-wipe can-pause
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-BRD:module{BrandingV2} BRD)
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (l1:integer (length name))
                    (gas-costs:decimal (URCi_IssueGas l1))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (folded-lst:[string]
                        (fold
                            (lambda
                                (acc:[string] index:integer)
                                (let
                                    (
                                        (id:string
                                            (XIv_Issue
                                                account
                                                (at index name)
                                                (at index ticker)
                                                (at index decimals)
                                                ;;
                                                (at index can-upgrade)
                                                (at index can-change-owner)
                                                (at index can-add-special-role)
                                                (at index can-transfer-oft-create-role)
                                                ;;
                                                (at index can-freeze)
                                                (at index can-wipe)
                                                (at index can-pause)
                                                ;;
                                                (at index iz-special)
                                            )
                                        )
                                    )
                                    (ref-BRD::XE_Issue id)
                                    (ref-U|LST::UC_AppL acc id)
                                )
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs account trigger folded-lst)
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_DeployAccountWNE (account:string id:string)
        (P|UEV_IMC)
        (let
            (
                (iz-account:bool (UR_IzAccount account id))
            )
            (if (not iz-account)
                (XBv_DeployAccount id account)
                true
            )
        )
    )
    ;;
    ;;Enforce: per-element-in-map -- XB_IssueFree maps this over LISTS, so UEV_Decimals validates one
    ;;          element. DPOF|C>ISSUE validates only UniformList/IzUnique/account-ownership and has no
    ;;          per-element loop; adding one purely for decimals is more code.
    ;;Protection: Class 2 — SECURE
    (defun XIv_Issue:string
        (
            account:string
            name:string
            ticker:string
            decimals:integer
            ;;
            can-upgrade:bool
            can-change-owner:bool
            can-add-special-role:bool
            can-transfer-oft-create-role:bool
            ;;
            can-freeze:bool
            can-wipe:bool
            can-pause:bool
            ;;
            iz-special:bool
        )
        (require-capability (SECURE))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (id:string (ref-U|DALOS::UDC_Makeid ticker))
            )
            (ref-U|DALOS::UEV_Decimals decimals)
            (ref-U|DALOS::UEV_NameOrTicker name true iz-special)
            (ref-U|DALOS::UEV_NameOrTicker ticker false iz-special)
            ;;
            (XI_InsertNewId id
                {"id"                           : id
                ,"owner-konto"                  : account
                ,"name"                         : name
                ,"ticker"                       : ticker
                ,"decimals"                     : decimals
                ;;
                ,"can-upgrade"                  : can-upgrade                           ;;false
                ,"can-change-owner"             : can-change-owner                      ;;false
                ,"can-add-special-role"         : can-add-special-role                  ;;true
                ,"can-transfer-oft-create-role" : can-transfer-oft-create-role          ;;false
                ;;
                ,"can-freeze"                   : can-freeze                            ;;true
                ,"can-wipe"                     : can-wipe                              ;;true
                ,"can-pause"                    : can-pause                             ;;false
                ,"segmentation"                 : false
                ;;
                ,"is-paused"                    : false
                ,"nonces-used"                  : 0
                ,"nonces-excluded"              : 0
                ;;
                ,"supply"                       : 0.0
                ;;
                ,"reward-bearing-token"         : BAR
                ,"vesting-link"                 : BAR
                ,"sleeping-link"                : BAR
                ,"hibernation-link"             : BAR}
            )
            (XI_WriteRoles id
                (UDC_VerumRoles
                    [BAR]
                    [BAR]
                    [BAR]
                    account
                    [BAR]
                )
            )
            (XBv_DeployAccount id account)
            id
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>CONTROL
    (defun XI_Control
        (
            id:string
            can-upgrade:bool
            can-change-owner:bool
            can-add-special-role:bool
            can-transfer-oft-create-role:bool
            can-freeze:bool
            can-wipe:bool
            can-pause:bool
            segmentation:bool
        )
        (require-capability (DPOF|S>CONTROL id))
        (update DPOF|T|Properties id
            {"can-upgrade"                  : can-upgrade
            ,"can-change-owner"             : can-change-owner
            ,"can-add-special-role"         : can-add-special-role
            ,"can-transfer-oft-create-role" : can-transfer-oft-create-role
            ,"can-freeze"                   : can-freeze
            ,"can-wipe"                     : can-wipe
            ,"can-pause"                    : can-pause
            ,"segmentation"                 : segmentation}
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPOF|C>DEBIT
    (defun XI_DebitNonces (account:string id:string nonces:[integer] amounts:[decimal] wipe-mode:bool)
        @doc "Debit DPOF <id> <nonces> on <account> with <amounts> \
            \ Will Take Nonce out of circulation if all <nonce> supply is debited. \
            \ Only Performs debitation, does not update supply. \
            \ All <nonces> must be held by <account>"
        (require-capability (DPOF|C>DEBIT account id nonces amounts wipe-mode))
        (let
            (
                (tas:decimal (UR_AccountSupply id account))
                (sum:decimal (fold (+) 0.0 amounts))
            )
            (XI_UpdateAccountSupply id account (- tas sum))
            ;;Per-nonce debit; each full debit yields 1 so the exclusion counter is
            ;;bumped ONCE per batch (single hot-row write) instead of once per nonce
            (XI_IncrementNoncesExcludedBy id
                (fold (+) 0
                    (map
                        (lambda
                            (idx:integer)
                            (let
                                (
                                    (nonce:integer (at idx nonces))
                                    (amount:decimal (at idx amounts))
                                    (nonce-supply:decimal (UR_NonceSupply id nonce))
                                )
                                (if (= amount nonce-supply)
                                    ;;Take Nonce out of Circulation;
                                    (do
                                        (XI_UpdateNonceSupply id nonce -1.0)
                                        (XI_UpdateNonceHolder id nonce BAR)
                                        1
                                    )
                                    ;;Only Debit Nonce without taking it out of circulation
                                    (do
                                        (XI_UpdateNonceSupply id nonce (- nonce-supply amount))
                                        0
                                    )
                                )
                            )
                        )
                        (enumerate 0 (- (length nonces) 1))
                    )
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|C>CREDIT
    (defun XI_CreditNonces (account:string id:string nonces:[integer] amounts:[decimal] meta-data-array:[[object]])
        @doc "Credit a DPOF <id> <nonces> on <account> with <amounts> and <meta-datas> \
            \ Only Performs creditation, does not update supply\
            \ Designed to Process <nonces> in two variants \
            \ Either the nonce exists already, in which case length must be 1; <iz-singular> true\
            \ Or ALL the nonce dont exist, in which case the length must be greater than 1; <iz-singular> false"
        (require-capability (DPOF|C>CREDIT account id nonces amounts meta-data-array))
        ;;Deploy Account WNE
        (XB_DeployAccountWNE account id)
        (let
            (
                (iz-singular:bool (UC_IzSingular id nonces))
                (iz-consecutive:bool (UC_IzConsecutive id nonces))
                (tas:decimal (UR_AccountSupply id account))
                (sum:decimal (fold (+) 0.0 amounts))
            )
            ;;Update Total Individual Account Supply
            (XI_UpdateAccountSupply id account (+ tas sum))
            (if iz-singular
                (XI_UpdateNonceSupply id (at 0 nonces) (+ (UR_NonceSupply id (at 0 nonces)) (at 0 amounts)))
                true
            )
            (if iz-consecutive
                (do
                    ;;Update <nonces-used> in properties of <id>
                    (XI_UpdateNoncesUsed id (at 0 (take -1 nonces)))
                    ;;Insert New Nonces
                    (XI_InsertNewNonces account id nonces amounts meta-data-array)
                )
                true
            )
        )
    )
    ;;
    ;;Pure Write/Update Functions
    ;;1]DPOF|T|Properties
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XI_InsertNewId (id:string id-data:object{DpofUdcV2.DPOF|Properties})
        (P|UEV_IMC)
        (insert DPOF|T|Properties id id-data)
    )
    ;;Protection: Class 3 — Custom: DPOF|S>ROTATE-OWNERSHIP
    (defun XI_ChangeOwnership (id:string new-owner:string)
        (require-capability (DPOF|S>ROTATE-OWNERSHIP id new-owner))
        (update DPOF|T|Properties id
            {"owner-konto" : new-owner}
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>PAUSE
    (defun XI_TogglePause (id:string toggle:bool)
        (require-capability (DPOF|S>PAUSE id toggle))
        (update DPOF|T|Properties id
            { "is-paused" : toggle}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateSupply (id:string new-supply:decimal)
        (require-capability (SECURE))
        (update DPOF|T|Properties id
            {"supply" : new-supply}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateNoncesUsed (id:string new-value:integer)
        (require-capability (SECURE))
        (update DPOF|T|Properties id
            {"nonces-used" : new-value}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IncrementNoncesExcludedBy (id:string count:integer)
        @doc "Bumps the <id> excluded-nonce counter by <count> in ONE write (batched per debit \
            \ call instead of once per fully-wiped nonce); no-op when <count> is zero."
        (require-capability (SECURE))
        (if (> count 0)
            (let
                (
                    (excluded:integer (UR_NoncesExcluded id))
                )
                (update DPOF|T|Properties id
                    {"nonces-excluded" : (+ excluded count)}
                )
            )
            "no-excluded-nonces"
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateRewardBearingToken (atspair:string hot-rbt:string)
        (P|UEV_IMC)
        (with-read DPOF|T|Properties hot-rbt
            {"reward-bearing-token" := rbt}
            ;;SHADOWED BY A ONE-WAY LATCH IN THE ONLY CALLER. This function has exactly one caller in
            ;;the whole codebase: ATS::C_AddHotRBT (08_ATS.pact:3196). That caller's `let` binds
            ;;<ico2> to (DPOF::C_Control hot-rbt false false false false true true false false) --
            ;;whose FIRST argument is <can-upgrade>, set to false. Pact evaluates let bindings
            ;;eagerly, so on the first successful registration can-upgrade is latched off BEFORE this
            ;;line runs, and it can never be turned back on: C_Control itself requires can-upgrade to
            ;;be true (06_DPOF.pact:2076, "{} {} properties cannot be upgraded").
            ;;
            ;;So a second registration of the same DPOF is refused -- but by C_Control, one binding
            ;;earlier, with the can-upgrade message rather than this one. The state this enforce
            ;;tests for (rbt != BAR) is therefore unreachable here: the only way a DPOF's
            ;;reward-bearing-token becomes non-BAR is through this very function, and the same
            ;;transaction latches the door behind it.
            ;;
            ;;NOT REMOVED, and deliberately so: it is the invariant the latch happens to enforce, and
            ;;it would become live again the moment C_AddHotRBT's ico2 stopped clearing can-upgrade.
            ;;Demonstrated, not assumed, by REPL/modules/ATS.repl <<ATS-G23>>, which drives the full
            ;;re-registration route to the wall and reads the message that actually comes back.
            ;;UNREACHABLE
            (enforce (= rbt BAR) (format "RBT-Data for DPOF {} is already set as ATS-Pair {}" [hot-rbt rbt]))
            (update DPOF|T|Properties hot-rbt
                {"reward-bearing-token" : atspair}
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVesting (dptf:string dpof:string)
        (require-capability (SECURE))
        (update DPOF|T|Properties dpof
            {"vesting-link" : dptf}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateSleeping (dptf:string dpof:string)
        (require-capability (SECURE))
        (update DPOF|T|Properties dpof
            {"sleeping-link" : dptf}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateHibernation (dptf:string dpof:string)
        (require-capability (SECURE))
        (update DPOF|T|Properties dpof
            {"hibernation-link" : dptf}
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPOF|C>UPDATE-SPECIAL
    (defun XE_UpdateSpecialOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (main-dptf:string secondary-dpof:string vzh-tag:integer)
        (P|UEV_IMC)
        (with-capability (DPOF|C>UPDATE-SPECIAL main-dptf secondary-dpof vzh-tag)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (cond
                    ((= vzh-tag 1)
                        (do
                            (ref-DPTF::XE_UpdateVesting main-dptf secondary-dpof)
                            (XI_UpdateVesting main-dptf secondary-dpof)
                        )
                    )
                    ((= vzh-tag 2)
                        (do
                            (ref-DPTF::XE_UpdateSleeping main-dptf secondary-dpof)
                            (XI_UpdateSleeping main-dptf secondary-dpof)
                        )
                    )
                    ((= vzh-tag 3)
                        (do
                            (ref-DPTF::XE_UpdateHibernation main-dptf secondary-dpof)
                            (XI_UpdateHibernation main-dptf secondary-dpof)
                        )
                    )
                    true
                )
                (URCi_UpdateSpecialOrtoFungible main-dptf)
            )
        )
    )
    ;;2]DPOF|T|Nonces
    ;;Protection: Class 2 — SECURE
    (defun XI_InsertNewNonces (nonce-owner:string id:string nonces:[integer] amounts:[decimal] meta-data-array:[[object]])
        (require-capability (SECURE))
        (with-capability (SECURE)
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (amount:decimal (at idx amounts))
                            (meta-data-chain:[object] (at idx meta-data-array))
                        )
                        (XB_InsertNewNonce nonce-owner id nonce amount meta-data-chain)
                    )
                )
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_InsertNewNonce (nonce-owner:string id:string nonce:integer amount:decimal meta-data-chain:[object])
        (P|UEV_IMC)
        (insert DPOF|T|Nonces (UC_IdNonce id nonce)
            (UDC_NonceElement nonce-owner id nonce amount meta-data-chain)
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateNonceSupply (id:string nonce:integer new-nonce-supply:decimal)
        (require-capability (SECURE))
        (update DPOF|T|Nonces (UC_IdNonce id nonce)
            {"supply" : new-nonce-supply}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateNonceHolder (id:string nonce:integer new-nonce-holder:string)
        (require-capability (SECURE))
        (update DPOF|T|Nonces (UC_IdNonce id nonce)
            {"holder" : new-nonce-holder}
        )
    )
    ;;3]DPOF|T|VerumRoles
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XI_WriteRoles (id:string verum-roles:object{DpofUdcV2.DPOF|VerumRoles})
        (P|UEV_IMC)
        (write DPOF|T|VerumRoles id verum-roles)
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum1 (id:string new-verum1:[string])
        (require-capability (SECURE))  
        (update DPOF|T|VerumRoles id
            {"a-frozen" : new-verum1}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum2 (id:string new-verum2:[string])
        (require-capability (SECURE))  
        (update DPOF|T|VerumRoles id
            {"r-oft-add-quantity" : new-verum2}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum3 (id:string new-verum3:[string])
        (require-capability (SECURE))  
        (update DPOF|T|VerumRoles id
            {"r-oft-burn" : new-verum3}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum4 (id:string new-r-oft-create-account:string)
        (require-capability (SECURE))  
        (update DPOF|T|VerumRoles id
            {"r-oft-create" : new-r-oft-create-account}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum5 (id:string new-verum5:[string])
        (require-capability (SECURE))  
        (update DPOF|T|VerumRoles id
            {"r-transfer" : new-verum5}
        )
    )
    ;;4]DPOF|T|AccountRoles
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_W|AccountRoles (id:string account:string account-data:object{DpofUdcV2.DPOF|AccountRoles})
        (P|UEV_IMC)
        (write DPOF|T|AccountRoles (UC_IdAccount id account)
            account-data
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>X_FREEZE
    (defun XI_ToggleFreezeAccount (id:string account:string toggle:bool)
        (require-capability (DPOF|S>X_FREEZE id account toggle))
        (update DPOF|T|AccountRoles (UC_IdAccount id account)
            { "frozen" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>X_TOGGLE-ADD-QUANTITY-ROLE
    (defun XI_ToggleAddQuantityRole (id:string account:string toggle:bool)
        (require-capability (DPOF|S>X_TOGGLE-ADD-QUANTITY-ROLE id account toggle))
        (update DPOF|T|AccountRoles (UC_IdAccount id account)
            { "role-oft-add-quantity" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>X_TOGGLE-BURN-ROLE
    (defun XI_ToggleBurnRole (id:string account:string toggle:bool)
        (require-capability (DPOF|S>X_TOGGLE-BURN-ROLE id account toggle))
        (update DPOF|T|AccountRoles (UC_IdAccount id account)
            { "role-oft-burn" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>X_SWITCH-CREATE-ROLE
    (defun XI_SwitchCreateRole (id:string receiver:string)
        (require-capability (DPOF|S>X_SWITCH-CREATE-ROLE id receiver))
        (update DPOF|T|AccountRoles (UC_IdAccount id (UR_Verum4 id))
            { "role-oft-create" : false}
        )
        (update DPOF|T|AccountRoles (UC_IdAccount id receiver)
            { "role-oft-create" : true}
        )
    )
    ;;Protection: Class 3 — Custom: DPOF|S>X_TOGGLE-TRANSFER-ROLE
    (defun XI_ToggleTransferRole (id:string account:string toggle:bool)
        (require-capability (DPOF|S>X_TOGGLE-TRANSFER-ROLE id account toggle))
        (update DPOF|T|AccountRoles (UC_IdAccount id account)
            { "role-transfer" : toggle}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateAccountSupply (id:string account:string new-tas:decimal)
        (require-capability (SECURE))
        (update  DPOF|T|AccountRoles (UC_IdAccount id account)
            {"total-account-supply" : new-tas}
        )
    )
    ;;{5.7}  User [A/C]
    (defun AU_OrtoFungibleAccounts (keyz:[string])
        @doc "Get <keyz> with <(UR_KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_OrtoFungibleAccount) keyz)
        )
    )
    (defun AU_OrtoFungibleAccount (ky:string)
        (require-capability (SECURE))
        (update DPOF|T|AccountRoles ky
            {"id"       : (drop -163 ky)
            ,"account"  : (take -162 ky)}
        )
    )
    (defun AU_OrtoFungibles (ids:[string])
        @doc "Get <ids> with <(UR_P-KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_OrtoFungible) ids)
        )
    )
    (defun AU_OrtoFungible (id:string)
        (require-capability (SECURE))
        (update DPOF|T|Properties id
            {"id"       : id}
        )
    )
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <entity-id>'s pending branding. <executor> is bound to the PARENT token's \
            \ owner -- branding a derived entity is the parent owner's right. Ownership itself \
            \ is proven by DPOF|C>UPDATE-BRD via UEV_ParentOwnership; the binding is what keeps \
            \ the named executor from being a name nobody reads."
        (P|UEV_IMC)
        (UEV_ExecutorIsParentKonto executor entity-id)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (with-capability (DPOF|C>UPDATE-BRD entity-id)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (URCi_UpdatePendingBranding entity-id)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        (P|UEV_IMC)
        (UEV_ExecutorIsParentKonto executor entity-id)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (parent:string (URCv_Parent entity-id))
                (parent-owner:string
                    (if (= parent entity-id)
                        (UR_Konto entity-id)
                        (ref-DPTF::UR_Konto parent)
                    )
                )
            )
            ;;Perform the branding upgrade (side effect); bill the STOA via the URCi (== XE_UpgradeBranding's price)
            (with-capability (DPOF|C>UPGRADE-BRD entity-id)
                (ref-BRD::XE_UpgradeBranding entity-id executor months)
            )
            (ref-IGNIS::XB_CollectStoaWithTrigger patron (URCi_UpgradeBranding months) false)
        )
    )
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string 
            name:[string] ticker:[string] decimals:[integer]
            can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool]
            can-freeze:[bool] can-wipe:[bool] can-pause:[bool]
        )
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l1:integer (length name))
                (stoa-costs:decimal (URCi_IssueStoa l1))
                (iz-special:[bool] (make-list l1 false))
                (ico:object{IgnisCollectorV3.OutputCumulator}
                    (with-capability (SECURE)
                        (XB_IssueFree 
                            executor name ticker decimals 
                            can-upgrade can-change-owner can-add-special-role can-transfer-oft-create-role
                            can-freeze can-wipe can-pause iz-special
                        )
                    )
                )
            )
            (ref-IGNIS::XE_CollectStoa patron stoa-costs)
            ico
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|S>ROTATE-OWNERSHIP id executee)
            (XI_ChangeOwnership id executee)
            (URCi_RotateOwnership id)
        )
    )
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|S>CONTROL id)
            (XI_Control id cu cco casr ctocr cf cw cp sg)
            (URCi_Control id)
        )
    )
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|S>PAUSE id toggle)
            ;;Pause|Unpause <id>
            (XI_TogglePause id toggle)
            ;;Output
            (URCi_TogglePause id)
        )
    )
    ;;
    ;;Enforce: <account> existence cannot be relocated -- there is no defcap on this path to
    ;;          host it, and the ADMIN Talos door deliberately has NO ownership check on the
    ;;          target, which is its reason to exist. See the DPTF twin for the full argument.
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XBv_DeployAccount (id:string account:string)
        @doc "Activates DPOF <id> on <account>. RECLASSIFIED from `C_DeployAccount` 2026-09-21, \
            \ the twin of the DPTF change: it builds no OutputCumulator and was called from \
            \ INSIDE its own module, which a C_ may never be -- a C_ and an A_ are a module's \
            \ FINAL functions, the ones Talos wraps. Both Talos doors wrap this X_ now, and \
            \ they are where the policies differ: DPOF|C_DeployAccount is self-service and \
            \ PAYS; DPOF|A_DeployAccount is admin-only and deploys for SOMEONE ELSE."
        (P|UEV_IMC)
        ;;<id> IS CHECKED BEFORE THE BINDING GROUP, and that ordering is load-bearing. This call
        ;;used to sit three lines below, inside the `let` body -- and the binding
        ;;`(create-role-account (UR_Verum4 id))` reads DPOF|T|VerumRoles, so for an id that does not
        ;;exist the function died with `No value found in table ouronet-ns.DPOF_DPOF|T|VerumRoles
        ;;for key: <id>` and this check, written for exactly that input, was never reached.
        ;;Third occurrence of the same eager-`let` shape: C_Recover (2026-09-12), C_HotRecovery
        ;;(RT-H-003), and here. Pact evaluates every binding in a group before the body, so a
        ;;validation placed in the body cannot protect a read placed in the bindings.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-003b>>.
        (UEV_id id)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (create-role-account:string (UR_Verum4 id))
                (f:bool false)
                (role-oft-create-boolean:bool (if (= create-role-account account) true f))
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (with-default-read DPOF|T|AccountRoles (UC_IdAccount id account)
                (UDC_AccountRoles 0.0 f f f role-oft-create-boolean f id account)
                {"total-account-supply"     := tas
                ,"frozen"                   := fz
                ,"role-oft-add-quantity"    := roaq
                ,"role-oft-burn"            := rob
                ,"role-oft-create"          := roc
                ,"role-transfer"            := rt
                ,"id"                       := i
                ,"account"                  := a}
                (with-capability (SECURE)
                    (XB_W|AccountRoles id account
                        (UDC_AccountRoles tas fz roaq rob roc rt i a)
                    )
                )
            )
        )
    )
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 1"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|C>FREEZE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-one:[string] (UR_Verum1 id))
                    (updated-verum-one:[string] (ref-U|DALOS::UCv_NewRoleList verum-one executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum1 id updated-verum-one)
                ;;Update Account Roles
                (XI_ToggleFreezeAccount id executee toggle)
                ;;Output
                (URCi_ToggleFreezeAccount id)
            )
        )
    )
    (defun C_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 2"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|C>TOGGLE-ADD-QUANTITY-ROLE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-two:[string] (UR_Verum2 id))
                    (updated-verum-two:[string] (ref-U|DALOS::UCv_NewRoleList verum-two executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum2 id updated-verum-two)
                ;;Update Account Roles
                (XI_ToggleAddQuantityRole id executee toggle)
                ;;Output
                (URCi_ToggleAddQuantityRole id)
            )
        )
    )
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 3"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|C>TOGGLE-BURN-ROLE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-three:[string] (UR_Verum3 id))
                    (updated-verum-three:[string] (ref-U|DALOS::UCv_NewRoleList verum-three executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum3 id updated-verum-three)
                ;;Update Account Roles
                (XI_ToggleBurnRole id executee toggle)
                ;;Output
                (URCi_ToggleBurnRole id)
            )
        )
    )
    (defun C_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string)
        @doc "Switch Verum 4"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|C>SWITCH-CREATE-ROLE id executee)
            ;;Deploy WNE
            (XB_DeployAccountWNE executee id)
            ;;Update Account Roles — MUST run before Verum Roles below: XI_SwitchCreateRole
            ;;reads the CURRENT (pre-write) Verum4 internally to find the account to revoke.
            ;;Running XI_UpdateVerum4 first would overwrite that value to <executee> before
            ;;XI_SwitchCreateRole ever reads it, so the real previous holder would never be
            ;;revoked (DALOS audit #2C).
            (XI_SwitchCreateRole id executee)
            ;;Update Verum Roles
            (XI_UpdateVerum4 id executee)
            ;;Output
            (URCi_MoveCreateRole id)
        )
    )
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggle Verum 5"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (with-capability (DPOF|C>TOGGLE-TRANSFER-ROLE id executee toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-five:[string] (UR_Verum5 id))
                    (updated-verum-five:[string] (ref-U|DALOS::UCv_NewRoleList verum-five executee toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE executee id)
                ;;Update Verum Roles
                (XI_UpdateVerum5 id updated-verum-five)
                ;;Update Account Roles
                (XI_ToggleTransferRole id executee toggle)
                ;;Output
                (URCi_ToggleTransferRole id)
            )
        )
        
    )
    ;;
    (defun C_AddQuantity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string nonce:integer amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (supply:decimal (UR_Supply id))
            )
            (with-capability (DPOF|C>ADD-QTY executor id nonce amount)
                ;;Credit <nonce> held on <executor> by <amount> 
                (XI_CreditNonces executor id [nonce] [amount] [[{}]])
                ;;Update <id> Supply
                (XI_UpdateSupply id (+ supply amount))
                ;;Output
                (URCi_AddQuantity id)
            )
        )
    )
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string nonce:integer amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (supply:decimal (UR_Supply id))
            )
            (with-capability (DPOF|C>BURN executor id nonce amount)
                ;;Debit <nonce> held on <executor> by <amount>
                (XI_DebitNonces executor id [nonce] [amount] false)
                ;;Update <id> Supply
                (XI_UpdateSupply id (- supply amount))
                ;;Output
                (URCi_Burn id)
            )
        )
    )
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string id:string amount:decimal meta-data-chain:[object])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (supply:decimal (UR_Supply id))
                (nonces-used:integer (UR_NoncesUsed id))
            )
            (with-capability (DPOF|C>MINT executor id amount meta-data-chain)
                ;;Credit <nonce> held on <executor> by <amount>
                (XI_CreditNonces executor id [(+ nonces-used 1)] [amount] [meta-data-chain])
                ;;Update <id> Supply
                (XI_UpdateSupply id (+ supply amount))
                ;;Output
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [(URCi_Mint id)]
                    [(UR_NoncesUsed id)]
                )
            )
        )
    )
    ;;Wipes
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string nonce:integer amount:decimal)
        @doc "Wipes a specific DPOF <id> <nonce> on <executee> by <amount> \
        \ Amount may be lower or equal to the nonce amount. \
        \ Requires <id> has <segmentation> set to true"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (let
            (
                (supply:decimal (UR_Supply id))
            )
            (with-capability (DPOF|C>WIPE-SLIM executee id nonce amount)
                ;;Debit <nonce> held on <executee> by <amount>
                (XI_DebitNonces executee id [nonce] [amount] true)
                ;;Update <id> Supply
                (XI_UpdateSupply id (- supply amount))
                ;;Output 2 IGNIS
                (URCi_WipeSlim id)
            )
        )
    )
    (defun CC_WipeHeavy:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string id:string)
        @doc "Wipes all viable <id> Nonces of an DPOF <executee> \
            \ \
            \ |Heavy| reffers to the usage of expensive functions like <select> or <keys> \
            \ (that arent meant to be used in transactional context) to get the Account Nonces; \
            \ May fit in a single Transaction for Small Data Sets"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (C_WipePure patron executor executee id (URHC_WipePure executee id))
    )
    (defun C_WipePure:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Wipes all <id> Nonces of an DPOF <executee>, presented via an <removable-nonces-obj> object \
            \ \
            \ The object must be pre-read (dirty read) \
            \ \
            \ Example to retrieve the <removable-nonces-obj> \
            \ <(URHC_WipePure executee id)> ; to get the whole object \
            \ <(UCv_TakePureWipe (URHC_WipePure executee id) 165)> ; to get only the first 165 units \
            \ Aproximately xx Individual Wipes fit inside one TX (for NFTs)."
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (let
            (
                (supply:decimal (UR_Supply id))
                (nonces:[integer] (at "r-nonces" removable-nonces-obj))
                (amounts:[decimal] (at "r-amounts" removable-nonces-obj))
                (sum:decimal (fold (+) 0.0 amounts))
            )
            (with-capability (DPOF|C>WIPE executee id nonces)
                ;;Debit <nonces> by <amounts> on <executee> for <id>
                (XI_DebitNonces executee id nonces amounts true)
                ;;Update <id> Supply
                (XI_UpdateSupply id (- supply sum))
                ;;Output (2 IGNIS per Nonce Wiped)
                (URCi_WipeCumulator id removable-nonces-obj)
            )
        )
    )
    (defun C_WipeClean:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string nonces:[integer])
        @doc "Wipes <id> select <nonces> of a DPOF <executee>"
        (P|UEV_IMC)
        (UEV_ExecutorIsKonto executor id)
        (C_WipePure patron executor executee id
            (UDC_RemovableNonces
                nonces
                (UR_NoncesSupplies id nonces)
            )
        )
    )
    (defun Cp_WipeSlice:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes exactly ONE <URHC_BuildWipeSlicePlan> slice of \
            \ <account>'s <id> nonces. Order-independent and retryable: slices are disjoint by \
            \ construction, the frozen target account cannot move nonces mid-campaign, and a \
            \ replayed/duplicate slice REVERTS (a wiped nonce is decommissioned to supply -1.0, \
            \ failing debit validation) — no job state, the live table is the completion ledger. \
            \ Same authority chain as <C_WipePure>: token owner via wipe-mode, can-wipe ON, \
            \ target frozen. True Cp_ — no heavy read anywhere in its tree."
        (P|UEV_IMC)
        (let
            (
                (supply:decimal (UR_Supply id))
                (nonces:[integer] (at "r-nonces" removable-nonces-obj))
                (amounts:[decimal] (at "r-amounts" removable-nonces-obj))
                (sum:decimal (fold (+) 0.0 amounts))
            )
            (with-capability (DPOF|C>WIPE account id nonces)
                ;;Debit slice <nonces> by <amounts> on <account> for <id>
                (XI_DebitNonces account id nonces amounts true)
                ;;Update <id> Supply (read fresh per slice; decrements compose in any order)
                (XI_UpdateSupply id (- supply sum))
                ;;Output (2 IGNIS per Nonce Wiped)
                (URCi_WipeCumulator id removable-nonces-obj)
            )
        )
    )
    ;;Transfers
    (defun C_Transmit:object{IgnisCollectorV3.OutputCumulator}
        (patron:string sender:string receiver:string id:string nonces:[integer] amounts:[decimal] method:bool)
        @doc "Transfer DPOF <id> <nonces> from <sender> to <receiver> by a specific <amount> \
            \ This debits the <sender> nonces by <amount> and creates new nonces on receiver of <amount> \
            \ Requires <segmentation> set to <true> \
            \ Using an <amount> equal to the nonce supply, will take nonce out of the circulation"
        (P|UEV_IMC)
        (let
            (
                (nonces-used:integer (UR_NoncesUsed id))
                (how-many:integer (length nonces))
                (output-nonces:[integer] (enumerate (+ nonces-used 1) (+ nonces-used how-many)))
                (meta-data-array:[[object]] (UR_NoncesMetaDatas id nonces))
                (td:object{TransmitData}
                    (UDCx_TransmitData nonces amounts output-nonces meta-data-array)
                )
            )
            (with-capability (DPOF|C>TRANSMIT id td sender receiver method)
                ;;1]Debit sender
                (XI_DebitNonces sender id nonces amounts false)
                ;;2]Credit receiver
                (XI_CreditNonces receiver id output-nonces amounts meta-data-array)
                ;;3]Output Costs 2 IGNIS per Nonce Transmitted
                (URCi_MoveCumulator id nonces true)
            )
        )
    )
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string sender:string receiver:string id:string nonces:[integer] method:bool)
        @doc "Transfer DPOF <id> <nonces> from <sender> to <receiver> by changing their Ownership"
        (P|UEV_IMC)
        (with-capability (DPOF|C>TRANSFER id nonces sender receiver method)
            (do
                (XI_TransferWholeNonces id sender receiver nonces)
                (URCi_MoveCumulator id nonces false)
            )
        )
    )
    (defun C_BulkTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string sender:string receiver-lst:[string] id:string nonces-array:[[integer]] method:bool)
        @doc "Bulk whole-nonce transfer: one sender, many receivers (DemiourgosPactOrtoFungibleV2). \
            \ One IGNIS cumulator for total nonce count — not N× C_Transfer collection overhead."
        (P|UEV_IMC)
        (with-capability (DPOF|C>BULK-TRANSFER id nonces-array sender receiver-lst method)
            (let
                (
                    (all-nonces:[integer] (UC_FlattenNoncesArray nonces-array))
                )
                (do
                    (map
                        (lambda (idx:integer)
                            (XI_TransferWholeNonces
                                id
                                sender
                                (at idx receiver-lst)
                                (at idx nonces-array)
                            )
                        )
                        (enumerate 0 (- (length receiver-lst) 1))
                    )
                    (URCi_MoveCumulator id all-nonces false)
                )
            )
        )
    )

)



;;

;; --- tables for 06_DPOF.pact (6 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table DPOF|T|Properties)
;; (create-table DPOF|T|Nonces)
;; (create-table DPOF|T|VerumRoles)
;; (create-table DPOF|T|AccountRoles)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/07_ELITE.pact ===================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface EliteV2
    @doc "Exposes Elite Account Related Functions"

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
    ;;  [URC]
    ;;
    (defun URC_EliteAurynzSupply (account:string))
    (defun URC_IzIdEA:bool (id:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XE_UpdateEliteSingle (id:string account:string))
    (defun XE_UpdateElite (id:string sender:string receiver:string))
    ;;{5.7}  User [A/C]

)
;;
(module ELITE GOV
    @doc "ELITE — the Elite-account helper core, implementing EliteV2. It holds no domain \
        \ tables of its own, instead providing Elite-Aurynz supply reads (summing the \
        \ Elite-Auryn token plus its frozen/reserved/vesting/sleeping counterparts) and \
        \ XE_UpdateElite entrypoints that recompute an account's Elite tier when Elite-Auryn \
        \ balances move. Other modules call it on transfers/mints to keep Elite tiers \
        \ current."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements EliteV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_ELITE                              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ELITE_ADMIN)))
    (defcap GOV|ELITE_ADMIN ()                          (enforce-guard GOV|MD_ELITE))
    ;;{G5}  functions
    ;;#56L fix: removed GOV|ELITE_ADMIN-CALLER (defcap) and GOV|CollectiblesKey (defun,
    ;;referencing an unrelated "dpdc-keyset") - two vestigial boilerplate items copied from the
    ;;module sample template, confirmed zero references anywhere in the repo (including from
    ;;other modules via ref-ELITE::). No functional change.
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
    (defcap P|ELITE|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|ELITE|CALLER))
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
        (with-capability (GOV|ELITE_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|ELITE_ADMIN)
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
        (with-capability (GOV|ELITE_ADMIN)
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
        (with-capability (GOV|ELITE_ADMIN)
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
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (mg:guard (create-capability-guard (P|ELITE|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
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
    (defun URC_EliteAurynzSupply (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
            )
            (if (!= ea-id BAR)
                (let
                    (
                        (ea-supply:decimal (ref-DPTF::UR_AccountSupply ea-id account))
                        (fea:string (ref-DPTF::UR_Frozen ea-id))
                        (rea:string (ref-DPTF::UR_Reservation ea-id))
                        (vea:string (ref-DPTF::UR_Vesting ea-id))
                        (sea:string (ref-DPTF::UR_Sleeping ea-id))
                        (hea:string (ref-DPTF::UR_Hibernation ea-id))
                        (fea-supply:decimal
                            (if (!= fea BAR)
                                (ref-DPTF::UR_AccountSupply fea account)
                                0.0
                            )
                        )
                        (rea-supply:decimal
                            (if (!= rea BAR)
                                (ref-DPTF::UR_AccountSupply rea account)
                                0.0
                            )
                        )
                        (vea-supply:decimal
                            (if (!= vea BAR)
                                (ref-DPOF::UR_AccountSupply vea account)
                                0.0
                            )
                        )
                        (sea-supply:decimal
                            (if (!= sea BAR)
                                (ref-DPOF::UR_AccountSupply sea account)
                                0.0
                            )
                        )
                        (hea-supply:decimal
                            (if (!= hea BAR)
                                (ref-DPOF::UR_AccountSupply hea account)
                                0.0
                            )
                        )
                    )
                    (fold (+) 0.0 [ea-supply fea-supply rea-supply vea-supply sea-supply hea-supply])
                )
                0.0
            )
        )
    )
    (defun URC_IzIdEA:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (fea:string (ref-DPTF::UR_Frozen ea-id))
                (rea:string (ref-DPTF::UR_Reservation ea-id))
                (vea:string (ref-DPTF::UR_Vesting ea-id))
                (sea:string (ref-DPTF::UR_Sleeping ea-id))
                (hea:string (ref-DPTF::UR_Hibernation ea-id))
            )
            (contains id [ea-id fea rea vea sea hea])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateEliteSingle (id:string account:string)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-elite-auryn:bool (URC_IzIdEA id))
                (a-type:bool (ref-DALOS::UR_AccountType account))
            )
            (if iz-elite-auryn
                (with-capability (P|ELITE|CALLER)
                    (if (not a-type)
                        (ref-DALOS::XE_UpdateElite account (URC_EliteAurynzSupply account))
                        true
                    )
                )
                true
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateElite (id:string sender:string receiver:string)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-elite-auryn:bool (URC_IzIdEA id))
                (s-type:bool (ref-DALOS::UR_AccountType sender))
                (r-type:bool (ref-DALOS::UR_AccountType receiver))
            )
            (if iz-elite-auryn
                (with-capability (P|ELITE|CALLER)
                    (if (not s-type)
                        (ref-DALOS::XE_UpdateElite sender (URC_EliteAurynzSupply sender))
                        true
                    )
                    (if (not r-type)
                        (ref-DALOS::XE_UpdateElite receiver (URC_EliteAurynzSupply receiver))
                        true
                    )
                )
                true
            )
        )
    )
    ;;{5.7}  User [A/C]

)

;; --- tables for 07_ELITE.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact =====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface AutostakeV3
    @doc "AutostakeV3 — same surface as AutostakeV1 with UtilityAtsV3.Awo typing for unstake objects."

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
    ;;  SCHEMAS
    ;;
    (defschema ATS|RewardTokenSchemaV2
        token:string
        nfr:bool
        resident:decimal
        unbonding:decimal
        royalty:decimal
    )
    (defschema ATS|Hot
        mint-time:time
    )
    (defschema CoilData
        primal-input-amount:decimal
        first-input-amount:decimal
        royalty-fee:decimal
        last-input-amount:decimal
        hibernation-fee:decimal
        rbt-amount:decimal
        rbt-id:string
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
    ;;
    ;;  [UDC]
    ;;
    (defun UDC_MakeUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string tm:time))
    (defun UDC_MakeZeroUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string))
    (defun UDC_MakeNegativeUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string))
    (defun UDC_ComposePrimaryRewardToken:object{ATS|RewardTokenSchemaV2} (token:string nfr:bool))
    (defun UDC_RT:object{ATS|RewardTokenSchemaV2} (a:string b:bool c:decimal d:decimal e:decimal))
    (defun UDC_CoilData:object{CoilData} (a:decimal b:decimal c:decimal d:decimal e:decimal f:decimal g:string))
    ;;{5.2}  Compute [UC]
    (defun UC_AtspairAccount:string (atspair:string account:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UC]
    ;;
    (defun URU_UpgradeAtspairToV2 (atspairs:[string]))
    ;;
    ;;  [UR]
    ;;
    (defun UR_P-KEYS:[string] ())
    (defun UR_KEYS:[string] ())
    ;;
    ;;  [UR]
    ;;
    ;;  [0    ATS|Pairs:{ATS|PropertiesSchema}
    (defun UR_OwnerKonto:string (atspair:string))
    (defun UR_CanUpgrade:bool (atspair:string))
    (defun UR_CanChangeOwner:bool (atspair:string))
    (defun UR_Syphoning:bool (atspair:string))
    (defun UR_Hibernate:bool (atspair:string))
    (defun UR_IndexName:string (atspair:string))
    (defun UR_IndexDecimals:integer (atspair:string))
    (defun UR_Royalty:decimal (atspair:string))
    (defun UR_Syphon:decimal (atspair:string))
        ;;
    (defun UR_PeakHibernatePromile:decimal (atspair:string))
    (defun UR_HibernateDecay:decimal (atspair:string))
        ;;
    (defun UR_Lock:bool (atspair:string))
    (defun UR_Unlocks:integer (atspair:string))
        ;;
    (defun UR_RewardTokens:[object{ATS|RewardTokenSchemaV2}] (atspair:string))
    (defun UR_RewardTokenList:[string] (atspair:string))
    (defun UR_RewardTokenNFR:[bool] (atspair:string))
    (defun UR_RewardTokenRUR:[decimal] (atspair:string rur:integer))
    (defun UR_SingleRewardTokenNFR:bool (atspair:string rt:string))
    (defun UR_SingleRewardTokenRUR:decimal (atspair:string rt:string rur:integer))
        ;;
    (defun UR_ColdRewardBearingToken:string (atspair:string))
    (defun UR_ColdNativeFeeRedirection:bool (atspair:string))
    (defun UR_ColdRecoveryPositions:integer (atspair:string))
    (defun UR_ColdRecoveryFeeThresholds:[decimal] (atspair:string))
    (defun UR_ColdRecoveryFeeTable:[[decimal]] (atspair:string))
    (defun UR_ColdRecoveryFeeRedirection:bool (atspair:string))
    (defun UR_ColdRecoveryDuration:[integer] (atspair:string))
    (defun UR_EliteMode:bool (atspair:string))
        ;;
    (defun UR_HotRewardBearingToken:string (atspair:string))
    (defun UR_HotRecoveryStartingFeePromile:decimal (atspair:string))
    (defun UR_HotRecoveryDecayPeriod:integer (atspair:string))
    (defun UR_HotRecoveryFeeRedirection:bool (atspair:string))
        ;;
    (defun UR_DirectRecoveryFee:decimal (atspair:string))
        ;;
    (defun UR_ToggleColdRecovery:bool (atspair:string))
    (defun UR_ToggleHotRecovery:bool (atspair:string))
    (defun UR_ToggleDirectRecovery:bool (atspair:string))
    ;;
    (defun UR_RtPrecisions:[integer] (atspair:string))
    (defun UR_P0:[object{UtilityAtsV3.Awo}] (atspair:string account:string))
    (defun UR_P1-7:object{UtilityAtsV3.Awo} (atspair:string account:string position:integer))
    ;;
    ;;  [URC]
    ;;
    (defun URC_Index (atspair:string))
    (defun URC_ResidentSum:decimal (atspair:string))
    (defun URC_PairRBTSupply:decimal (atspair:string))
    (defun URC_RBT:decimal (atspair:string rt:string rt-amount:decimal))
    (defun URCv_RTSplitAmounts:[decimal] (atspair:string rbt-amount:decimal))
    (defun URC_MaxSyphon:[decimal] (atspair:string))
        ;;
    (defun URCv_RewardTokenPosition:integer (atspair:string reward-token:string))
        ;;
    (defun URC_AccountUnbondingBalance:decimal (atspair:string account:string reward-token:string))
    (defun URC_CullValue:[decimal] (atspair:string input:object{UtilityAtsV3.Awo}))
    (defun URC_WhichPosition:integer (atspair:string c-rbt-amount:decimal account:string))
    (defun URCv_ColdRecoveryFee (atspair:string c-rbt-amount:decimal input-position:integer))
    (defun URC_CullColdRecoveryTime:time (atspair:string account:string))
    (defun URC_IzPresentHotRBT:bool (atspair:string))
        ;;
    (defun URC_RewardBearingTokenAmounts:object{CoilData} (ats:string rt:string amount:decimal))
    (defun URC_RewardBearingTokenAmountsWithHibernation:object{CoilData} (ats:string rt:string amount:decimal hibernation-dayz:integer))
    ;;
    ;;  [URD]
    ;;
    (defun URH_HeldAutostakePairs:[string] (account:string))
    (defun URH_ExistingAutostakePairs:[string] (ats:string))
    (defun URH_OwnedAutostakePairs:[string] (account:string))
    ;;  [URCi] cost readers — single source per op (the C_ bills them, INFO previews from them)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string))
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_UpdateRoyalty:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_UpdateSyphon:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SetHibernationFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_ControlColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SetColdRecoveryDuration:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_ToggleElite:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_ToggleUpgrade:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SwitchColdRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_ControlHotRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SetHotRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SwitchHotRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SetDirectRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_SwitchDirectRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string))
    (defun URCi_AddSecondary:object{IgnisCollectorV3.OutputCumulator} ())
    (defun URCi_AddHotRBT:object{IgnisCollectorV3.OutputCumulator} (atspair:string hot-rbt:string))
    (defun URCi_SetColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} ())
    (defun URCi_ToggleParameterLock:object{IgnisCollectorV3.OutputCumulator} (atspair:string toggle:bool))
    (defun URCi_ToggleParameterLockStoa:decimal (atspair:string toggle:bool))
    (defun URCi_IssueGas:decimal (token-count:integer))
    (defun URCi_IssueStoa:decimal (token-count:integer))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_ExecutorIsOwnerKonto (executor:string entity-id:string))
    (defun UEV_ExecutorIsHotRbtOwner (executor:string hot-rbt:string))
    (defun UEV_id (atspair:string))
    (defun UEV_CanUpgradeON (atspair:string))
    (defun UEV_CanChangeOwnerON (atspair:string))
    (defun UEV_RewardTokenExistance (atspair:string reward-token:string existance:bool))
    (defun UEV_RewardBearingTokenExistance (atspair:string reward-bearing-token:string existance:bool cold-or-hot:bool))
    (defun UEV_ParameterLockState (atspair:string state:bool))
    (defun UEV_EliteState (atspair:string state:bool))
    (defun UEV_ColdRecoveryState (atspair:string state:bool))
    (defun UEV_HotRecoveryState (atspair:string state:bool))
    (defun UEV_DirectRecoveryState (atspair:string state:bool))
    (defun UEV_IssueData (atspair:string index-decimals:integer reward-token:string reward-bearing-token:string))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_Owner (id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XE_RemoveSecondary (atspair:string reward-token:string))
    (defun XE_UpdateRUR (atspair:string reward-token:string rur:integer direction:bool amount:decimal))
    (defun XE_SpawnAutostakeAccount (atspair:string account:string))
    (defun XE_ReshapeUnstakeAccount (atspair:string account:string rp:integer))
    (defun XE_UpP0 (atspair:string account:string obj:[object{UtilityAtsV3.Awo}]))
    (defun XE_UpP1 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP2 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP3 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP4 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP5 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP6 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    (defun XE_UpP7 (atspair:string account:string obj:object{UtilityAtsV3.Awo}))
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun HOT-RBT|C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun HOT-RBT|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer))
    (defun HOT-RBT|C_Repurpose:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string hot-rbt:string nonce:integer))
        ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string
            executor:string
            atspair:[string]
            index-decimals:[integer]
            reward-token:[string]
            rt-nfr:[bool]
            reward-bearing-token:[string]
            rbt-nfr:[bool]
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string executee:string atspair:string))
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string can-change-owner:bool syphoning:bool hibernate:bool))
    (defun C_UpdateRoyalty:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string royalty:decimal))
    (defun C_UpdateSyphon:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string syphon:decimal))
    (defun C_SetHibernationFees:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string peak:decimal decay:decimal))
        ;;
    (defun C_ToggleParameterLock:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string toggle:bool))
    (defun C_AddSecondary:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string reward-token:string rt-nfr:bool))
        ;;
    (defun C_ControlColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string c-nfr:bool c-fr:bool))
    (defun C_SetColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]]))
    (defun C_SetColdRecoveryDuration:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string soft-or-hard:bool base:integer growth:integer))
    (defun C_ToggleElite:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string toggle:bool))
    (defun C_ToggleUpgrade:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string toggle:bool))
    (defun C_SwitchColdRecovery:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string toggle:bool))
        ;;
    (defun C_AddHotRBT:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string hot-rbt:string))
    (defun C_ControlHotRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string h-fr:bool))
    (defun C_SetHotRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string promile:decimal decay:integer))
    (defun C_SwitchHotRecovery:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string toggle:bool))
        ;;
    (defun C_SetDirectRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string promile:decimal))
    (defun C_SwitchDirectRecovery:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string atspair:string toggle:bool))

)
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AutostakeComputerV2
    @doc "AutostakeComputerV2 — the read/compute interface for ATS staking eligibility. It \
        \ defines the CanCoil/CanConstrict/CanCurl/CanBrumate schemas (a boolean plus \
        \ where-lists of eligible pools), exposing the pure computation surface the ATS \
        \ module and Talos consult to decide which autostake pools an account may coil, \
        \ constrict, curl or brumate into."

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
    (defschema CanCoil
        can-coil:bool
        where-coil:[string]
    )
    (defschema CanConstrict
        can-constrict:bool
        where-constrict:[string]
    )
    (defschema CanCurl
        can-curl:bool
        where-curl:[[string]]
    )
    (defschema CanBrumate
        can-brumate:bool
        where-brumate:[[string]]
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
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_CanCoil:object{CanCoil} (dptf:string))
    (defun UC_CanConstrict:object{CanConstrict} (dptf:string))
    (defun UC_CanCurl:object{CanCurl} (dptf:string))
    (defun UC_CanBrumate:object{CanBrumate} (dptf:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
;;
(module ATS GOV
    @doc "ATS — the autostake pool core, implementing AutostakeV3, AutostakeComputerV2 and \
        \ branding. It owns ATS|Pairs (pool config: owner, reward tokens, royalty/syphon, \
        \ cold/hot/direct recovery settings, hibernation, parameter locks) and ATS|Ledger \
        \ (per-account staked positions P0-P7). Owner/admin client ops configure pairs — \
        \ issue, control, royalty/syphon, recovery fees/durations/toggles, secondary reward \
        \ tokens, hot-RBT, elite mode and locks — while token-moving stake actions live in \
        \ ATSU."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsagePrimaryV2)
    (implements AutostakeV3)
    ;;
    ;; [AutostakeComputer]
    ;;
    (implements AutostakeComputerV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_ATS                                (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_ATS                                (keyset-ref-guard ATS|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ATS_ADMIN)))
    (defcap GOV|ATS_ADMIN ()
        (enforce-one
            "ATS Autostake Admin not satisfed"
            [
                (enforce-guard GOV|MD_ATS)
                (enforce-guard GOV|SC_ATS)
            ]
        )
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|AutostakeKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|AutostakeKey)
        )
    )
    (defun GOV|ATS|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|ATS|SC_NAME)
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
    (defcap P|ATS|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|ATS|CALLER))
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
        (with-capability (GOV|ATS_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|ATS_ADMIN)
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
        (with-capability (GOV|ATS_ADMIN)
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
        (with-capability (GOV|ATS_ADMIN)
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
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|ATS|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst ATS|SC_KEY                                (GOV|AutostakeKey))
    (defconst ATS|SC_NAME                               (GOV|ATS|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst NULLTIME                                  (time "1984-10-11T11:10:00Z"))
    (defconst ANTITIME                                  (time "1983-08-07T11:10:00Z"))
    ;;{3.2}  schemas
    ;;
    (defschema ATS|PropertiesSchemaV3
        id:string                       ;[x] Added in V3
        owner-konto:string
        can-upgrade:bool                ;[x] Added in V2. Gates C_Control (can-change-owner/
                                         ;    syphoning/hibernate) via UEV_CanUpgradeON - false
                                         ;    blocks C_Control entirely until set back to true.
                                         ;    Fix (audit finding #21L / L3): now settable via
                                         ;    C_ToggleUpgrade (was permanently true, no setter).
        can-change-owner:bool
        syphoning:bool
        hibernate:bool                  ;[x] Added in V2
        pair-index-name:string
        index-decimals:integer
        royalty-promile:decimal         ;[x] Added in V2
        syphon:decimal
        ;;
        peak-hibernate-promile:decimal  ;[x] Added in V2
        hibernate-decay:decimal         ;[x] Added in V2
        ;;
        parameter-lock:bool
        unlocks:integer
        ;;
        reward-tokens:[object{AutostakeV3.ATS|RewardTokenSchemaV2}]
        ;;
        ;;Cold Recovery
        c-rbt:string
        c-nfr:bool
        c-positions:integer
        c-limits:[decimal]
        c-array:[[decimal]]
        c-fr:bool
        c-duration:[integer]
        c-elite-mode:bool
        ;;
        ;;Hot Recovery
        h-rbt:string
        h-fr:bool
        h-promile:decimal
        h-decay:integer
        ;;
        ;;Direct Recovery
        d-promile:decimal               ;[x] Added in V2
        ;;
        ;;Toggle Recoveries
        cold-recovery:bool
        hot-recovery:bool
        direct-recovery:bool            ;[x] Added in V2
    )
    (defschema ATS|BalanceSchemaV2
        @doc "Key = <ATS-Pair> + BAR + <account>"
        P0:[object{UtilityAtsV3.Awo}]
        P1:object{UtilityAtsV3.Awo}
        P2:object{UtilityAtsV3.Awo}
        P3:object{UtilityAtsV3.Awo}
        P4:object{UtilityAtsV3.Awo}
        P5:object{UtilityAtsV3.Awo}
        P6:object{UtilityAtsV3.Awo}
        P7:object{UtilityAtsV3.Awo}
        ;;
        ;;ForSelect, store Key Make-up
        id:string
        account:string
    )
    ;;{3.3}  tables
    (deftable ATS|Pairs:{ATS|PropertiesSchemaV3})   ;;Key = <ATS-Pair-id>
    (deftable ATS|Ledger:{ATS|BalanceSchemaV2})     ;;Key = <ATS-Pair-id> + BAR + <account>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap ATS|GOV ()
        @doc "Governor Capability for the Autostake Smart DALOS Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap ATS|S>ROTATE_OWNERSHIP (atspair:string new-owner:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_SenderWithReceiver (UR_OwnerKonto atspair) new-owner)
            (ref-DALOS::UEV_EnforceAccountExists new-owner)
            (UEV_CanChangeOwnerON atspair)
            (CAP_Owner atspair)
        )
    )
    (defcap ATS|S>CONTROL (atspair:string hibernate:bool)
        @event
        (if hibernate
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (c-rbt:string (UR_ColdRewardBearingToken atspair))
                )
                (ref-DPTF::UEV_Hibernation c-rbt true)
            )
            true
        )
        (CAP_Owner atspair)
        (UEV_CanUpgradeON atspair)
    )
    (defcap ATS|S>SYPHON (atspair:string syphon:decimal)
        @event
        (let
            (
                (precision:integer (UR_IndexDecimals atspair))
            )
            (enforce (>= syphon 0.1) "Syphon cannot be set lower than 0.1")
            (enforce
                (= (floor syphon precision) syphon)
                (format "The syphon value of {} is not a valid Index Value for the {} ATS Pair" [syphon atspair])
            )
            (CAP_Owner atspair)
        )
    )
    ;; Fix (audit finding #6H / H1, owner-confirmed 2026-08-17): peak-hibernate-promile/hibernate-decay
    ;; were added later (V2) and never got the parameter-lock gate the original fields have. Added here.
    (defcap ATS|S>SET-HIBERNATION-FEES (atspair:string peak:decimal decay:decimal)
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (UEV_ParameterLockState atspair false)
            (ref-U|ATS::UEV_HibernationFees peak decay)
            (CAP_Owner atspair)
        )
    )
    ;; Fix (audit finding #6H / H1, owner-confirmed 2026-08-17): royalty-promile was added later (V2)
    ;; and never got the parameter-lock gate. Added here. (syphon stays intentionally un-gated — #4C —
    ;; it's designed to fluctuate; do not add a lock check there.)
    ;; Fix (audit finding #7H / H2, owner-confirmed 2026-08-18): shared UEV_Fee (U_DALOS) allows up to
    ;; 999.0 promile (99.9%) - deliberately left untouched here since it's shared with DPTF's own fee
    ;; validation (05_DPTF.pact), outside this audit's scope. A per-tx delta cap was considered and
    ;; explicitly rejected by the owner (trivially bypassable by calling C_UpdateRoyalty repeatedly
    ;; within the same transaction). Instead, a royalty-specific ceiling: 500.0 promile (50%) max,
    ;; layered on top of UEV_Fee's existing {-1.0, 0.0} off-sentinels / [1.0, 999.0] active-range /
    ;; 4-decimal-precision check - -1.0 and 0.0 both still mean "off" and are always <= 500.0, so this
    ;; single enforce correctly narrows only the active [1.0, 999.0] range down to [1.0, 500.0].
    (defcap ATS|S>ROYALTY (atspair:string royalty:decimal)
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
            )
            (UEV_ParameterLockState atspair false)
            (ref-U|DALOS::UEV_Fee royalty)
            (enforce (<= royalty 500.0) "Royalty cannot exceed 500.0 promile (50%)")
            (CAP_Owner atspair)
        )
    )
    ;;
    (defcap ATS|S>CONTROL-RECOVERY (atspair:string)
        (CAP_Owner atspair)
        (UEV_ParameterLockState atspair false)
    )
    (defcap ATS|S>SWITCH-COLD-RECOVERY (atspair:string toggle:bool)
        @event
        (CAP_Owner atspair)
        (UEV_ColdRecoveryState atspair (not toggle))
    )
    (defcap ATS|S>SWITCH-HOT-RECOVERY (atspair:string toggle:bool)
        @event
        (CAP_Owner atspair)
        (UEV_HotRecoveryState atspair (not toggle))
    )
    (defcap ATS|S>SWITCH-DIRECT-RECOVERY (atspair:string toggle:bool)
        @event
        (CAP_Owner atspair)
        (UEV_DirectRecoveryState atspair (not toggle))
    )
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
    ;; Core (unevented) — StoicSyntax §14.7 layered-composition pattern: shared body, distinct leaf
    ;; events. Was two @event caps with the identical body pasted twice; refactored alongside the
    ;; C5 fix (ATS|C>HOT-RBT-BRD, below) that introduced this pattern's documentation.
    (defcap ATS|S>BRD (atspair:string)
        (CAP_Owner atspair)
        (compose-capability (P|ATS|CALLER))
    )
    (defcap ATS|C>UPDATE-BRD (atspair:string)
        @event
        (compose-capability (ATS|S>BRD atspair))
    )
    (defcap ATS|C>UPGRADE-BRD (atspair:string)
        @event
        (compose-capability (ATS|S>BRD atspair))
    )
    ;;
    (defcap ATS|C>REPURPOSE-HOT-RBT (hot-rbt:string)
        @event
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (atspair:string (ref-DPOF::UR_RewardBearingToken hot-rbt))
            )
            (CAP_Owner atspair)
            (compose-capability (ATS|GOV))
        )
    )
    ;; Fix (audit finding #5C / C5): HOT-RBT|C_UpdatePendingBranding/UpgradeBranding composed ATS|GOV
    ;; directly with no preceding ownership check — ATS|GOV is legitimately required (the hot-rbt's
    ;; DPOF owner-konto is ATS|SC_NAME, so DPOF's own UEV_ParentOwnership resolves to "prove you own
    ;; ats-sc", which only ATS's own code can do), but nothing gated *which caller* could trigger it.
    ;; Mirrors ATS|C>REPURPOSE-HOT-RBT's exact shape: resolve the pair from the hot-rbt, check real
    ;; ownership, THEN compose ATS|GOV.
    ;; Core (unevented) — shared validation body, StoicSyntax §14.7 layered-composition pattern
    ;; (mirrors ATS|S>CONTROL-RECOVERY / ATS|C>CONTROL-COLD-RECOVERY just above): resolve the pair,
    ;; check real ownership, compose ATS|GOV. Composed by both named leaf caps below — one body,
    ;; two distinctly-named events.
    (defcap ATS|C>HOT-RBT-BRD (entity-id:string)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (atspair:string (ref-DPOF::UR_RewardBearingToken entity-id))
            )
            (CAP_Owner atspair)
            (compose-capability (ATS|GOV))
        )
    )
    (defcap ATS|C>HOT-RBT-UPDATE-BRD (entity-id:string)
        @event
        (compose-capability (ATS|C>HOT-RBT-BRD entity-id))
    )
    (defcap ATS|C>HOT-RBT-UPGRADE-BRD (entity-id:string)
        @event
        (compose-capability (ATS|C>HOT-RBT-BRD entity-id))
    )
    (defcap ATS|C>ISSUE (account:string atspair:[string] index-decimals:[integer] reward-token:[string] rt-nfr:[bool] reward-bearing-token:[string]rbt-nfr:[bool])
        @event
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (l1:integer (length atspair))
                (l2:integer (length index-decimals))
                (l3:integer (length reward-token))
                (l4:integer (length rt-nfr))
                (l5:integer (length reward-bearing-token))
                (l6:integer (length rbt-nfr))
                (lengths:[integer] [l1 l2 l3 l4 l5 l6])
            )
            (ref-U|INT::UEV_UniformList lengths)
            (ref-U|LST::UEV_IzUnique atspair)
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (map
                (lambda
                    (index:integer)
                    (UEV_IssueData (at index atspair) (at index index-decimals) (at index reward-token) (at index reward-bearing-token))
                )
                (enumerate 0 (- l1 1))
            )
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap ATS|C>TOGGLE-PARAMETER-LOCK (atspair:string toggle:bool)
        @event
        (let
            (
                (cr:bool (UR_ToggleColdRecovery atspair))
                (hr:bool (UR_ToggleHotRecovery atspair))
                (dr:bool (UR_ToggleDirectRecovery atspair))
            )
            (CAP_Owner atspair)
            (UEV_ParameterLockState atspair (not toggle))
            (if toggle
                ;;When turned on, at least one Recovery must be set to true
                (enforce-one
                    (format "When Parameter Lock is set to {}, at least One Recovery must be on" [toggle])
                    [
                        (enforce cr "Cold Recovery must be active for exec")
                        (enforce hr "Hot Recovery must be active for exec")
                        (enforce dr "Direct Recovery must be active for exec")
                    ]
                )
                ;;When turned off, all Recoveries must be set to false
                (enforce 
                    (fold (and) true [(not cr) (not hr) (not dr)]) 
                    (format "ATSPair {} Recoveries must be stopped for exec" [atspair])
                )
            )
            (compose-capability (SECURE))
        )
    )
    ;;
    (defcap ATS|C>ADD-REWARD-TOKEN (atspair:string reward-token:string)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (n:integer (length (UR_RewardTokens atspair)))
            )
            (enforce (<= n 6) "An ATS Pair can have a maximum of 7 RTs")
            (ref-DPTF::CAP_Owner reward-token)
            ;;
            (CAP_Owner atspair)
            (UEV_RewardTokenExistance atspair reward-token false)
            (compose-capability (ATS|C>ADD-TOKEN atspair))
        )
    )
    (defcap ATS|C>ADD-TOKEN (atspair:string)
        (UEV_ParameterLockState atspair false)
        (UEV_ColdRecoveryState atspair false)
        (UEV_HotRecoveryState atspair false)
        (UEV_DirectRecoveryState atspair false)
        (compose-capability (P|ATS|CALLER))
    )
    ;;
    (defcap ATS|C>CONTROL-COLD-FEES (atspair:string)
        @event
        (compose-capability (ATS|C>CONTROL-COLD-RECOVERY atspair))
    )
    (defcap ATS|C>SET_COLD_FEES (atspair:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (c-rbt-prec:integer (ref-DPTF::UR_Decimals (UR_ColdRewardBearingToken atspair)))
            )
            (ref-U|ATS::UEV_CRF|Positions fee-positions)
            (ref-U|ATS::UEV_CRF|FeeThresholds fee-thresholds c-rbt-prec)
            (ref-U|ATS::UEV_CRF|FeeArray fee-positions fee-thresholds fee-array)
            (compose-capability (ATS|C>CONTROL-COLD-RECOVERY atspair))
        )
    )
    (defcap ATS|C>SET_COLD-DURATION (atspair:string soft-or-hard:bool base:integer growth:integer)
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (ref-U|ATS::UEV_ColdDurationParameters soft-or-hard base growth)
            (compose-capability (ATS|C>CONTROL-COLD-RECOVERY atspair))
        )
    )
    (defcap ATS|C>TOGGLE_ELITE (atspair:string toggle:bool)
        @event
        (if toggle
            (let
                (
                    (x:integer (UR_ColdRecoveryPositions atspair))
                )
                (enforce 
                    (= x 7)
                    "Turning Elite Mode requires 7 Cold Recovery Positions"
                )
            )
            true
        )
        (UEV_EliteState atspair (not toggle))
        (compose-capability (ATS|C>CONTROL-COLD-RECOVERY atspair))
    )
    (defcap ATS|C>CONTROL-COLD-RECOVERY (atspair:string)
        (UEV_ColdRecoveryState atspair false)
        (compose-capability (ATS|S>CONTROL-RECOVERY atspair))
    )
    ;;
    (defcap ATS|C>ADD-HOT-RBT (atspair:string hot-rbt:string)
        @event
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (hot-rbt-supply:decimal (ref-DPOF::UR_Supply hot-rbt))
                (hot-rbt-ftc:string (take 2 hot-rbt))
            )
            ;;1]Token Ownership
            (ref-DPOF::CAP_Owner hot-rbt)
            (CAP_Owner atspair)
            ;;2]Hot-RBT cannot be V|, Z| or H| -Tokens
            ;;FIXED 2026-09-12: the third entry was "H" (one character) while <hot-rbt-ftc> is
            ;;ALWAYS (take 2 hot-rbt) -- two characters -- so it could never match and HIBERNATION
            ;;tokens were not excluded at all. The comment above stated the intent correctly and
            ;;every other prefix test in the tree writes the pipe (02_SCORE.pact:2522/:2526 use
            ;;["Z|" "H|"]); this was the only site missing it. Pinned by modules/ATS.repl <<ATS-G15>>.
            (enforce 
                (not (contains hot-rbt-ftc ["V|" "Z|" "H|"]))
                "Special Orto-Fungibles cannot be registered as Hot-RBTs"
            )
            ;;3]ATS Pair must not have a Hot-RBT, when registering a Hot-RBT to it
            (UEV_RewardBearingTokenExistance atspair hot-rbt false false)
            ;;4]Only Zero Supply Orto-Fungibles can be registered as Hot-RBTs
            (enforce 
                (= hot-rbt-supply 0.0) 
                "Cannot Add OrtoFungible with non Zero Supply as ATS-Pair Hot RBT"
            )
            (compose-capability (ATS|C>ADD-TOKEN atspair))
            (compose-capability (ATS|GOV))
        )
    )
    (defcap ATS|C>CONTROL-HOT-FEE (atspair:string)
        @event
        (compose-capability (ATS|C>CONTROL-HOT-RECOVERY atspair))
    )
    (defcap ATS|C>SET_HOT_FEES (atspair:string promile:decimal decay:integer)
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (ref-U|ATS::UEV_Fee promile)
            (ref-U|ATS::UEV_Decay decay)
            (compose-capability (ATS|C>CONTROL-HOT-RECOVERY atspair))
        )
    )
    (defcap ATS|C>CONTROL-HOT-RECOVERY (atspair:string)
        (UEV_HotRecoveryState atspair false)    
        (compose-capability (ATS|S>CONTROL-RECOVERY atspair))
    )
    ;;
    (defcap ATS|C>SET_DIRECT_FEE (atspair:string promile:decimal)
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (ref-U|ATS::UEV_Fee promile)
            ;;Deliberately NOT ATS|S>CONTROL-DIRECT-RECOVERY -- see the note on that cap below.
            ;;The direct-recovery fee is adjustable while direct recovery is LIVE, unlike the hot
            ;;twin. Tested 2026-09-10: composing the state-checking cap here breaks the sovereign
            ;;init, which enables direct recovery and then sets the fee.
            (compose-capability (ATS|S>CONTROL-RECOVERY atspair))
        )
    )
    ;;NEVER COMPOSED, and the asymmetry it would close is INTENTIONAL. Investigated 2026-09-10.
    ;;
    ;;It is the direct-recovery twin of ATS|C>CONTROL-HOT-RECOVERY (just above), which IS composed
    ;;by ATS|C>CONTROL-HOT-FEE / ATS|C>SET_HOT_FEES and so forbids changing the hot fee while hot
    ;;recovery is live. The direct side has no such link, which looked like a missing wiring --
    ;;especially next to ATS|C>ADD-TOKEN, which requires all four recovery states off.
    ;;
    ;;TESTED, AND THE HYPOTHESIS WAS WRONG. Composing this cap from ATS|C>SET_DIRECT_FEE breaks
    ;;the sovereign init: REPL/Stage_01/[4.0]_Sovereign-Executor.repl enables direct recovery on
    ;;KORIndex (line 1592) and THEN sets its fee to 100.0 (line 1595). The direct-recovery fee is
    ;;therefore adjustable while direct recovery is live BY DESIGN -- a real behavioural
    ;;difference from hot recovery, not an oversight. The change was reverted.
    ;;
    ;;Left in place as the record of that investigation: it is unreachable, it guards nothing
    ;;today, and re-wiring it would break the deploy chain.
    (defcap ATS|S>CONTROL-DIRECT-RECOVERY (atspair:string)
        (UEV_DirectRecoveryState atspair false)
        (compose-capability (ATS|S>CONTROL-RECOVERY atspair))
    )
    ;;{C4}  Ownership [gold]
    (defcap ATS|C>TOGGLE_UPGRADE (atspair:string toggle:bool)
        @doc "Fix (audit finding #21L / L3): can-upgrade previously had no setter at all - \
            \ this is the first one. Gates C_Control (can-change-owner/syphoning/hibernate) \
            \ via UEV_CanUpgradeON; turning this off blocks C_Control entirely until it's \
            \ turned back on."
        @event
        (CAP_Owner atspair)
    )

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    ;;
    (defun UDC_MakeUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string tm:time)
        {"reward-tokens"    : (make-list (length (UR_RewardTokenList atspair)) 0.0)
        ,"cull-time"        : tm}
    )
    (defun UDC_MakeZeroUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string)
        (UDC_MakeUnstakeObject atspair NULLTIME)
    )
    (defun UDC_MakeNegativeUnstakeObject:object{UtilityAtsV3.Awo} (atspair:string)
        (UDC_MakeUnstakeObject atspair ANTITIME)
    )
    (defun UDC_ComposePrimaryRewardToken:object{AutostakeV3.ATS|RewardTokenSchemaV2} (token:string nfr:bool)
        (UDC_RT token nfr 0.0 0.0 0.0)
    )
    (defun UDC_RT:object{AutostakeV3.ATS|RewardTokenSchemaV2} 
        (a:string b:bool c:decimal d:decimal e:decimal)
        (enforce 
            (fold (and) true [(>= c 0.0)(>= d 0.0)(>= e 0.0)]) 
            "Negative Decimals unallowed for Reward Token Object"
        )
        {"token"        : a
        ,"nfr"          : b
        ,"resident"     : c
        ,"unbonding"    : d
        ,"royalty"      : e}
    )
    (defun UDCx_Balance:object{ATS|BalanceSchemaV2}
        (
            a:[object{UtilityAtsV3.Awo}] b:object{UtilityAtsV3.Awo} 
            c:object{UtilityAtsV3.Awo} d:object{UtilityAtsV3.Awo}
            e:object{UtilityAtsV3.Awo} f:object{UtilityAtsV3.Awo}
            g:object{UtilityAtsV3.Awo} h:object{UtilityAtsV3.Awo}
            i:string j:string
        )
        {"P0"       : a
        ,"P1"       : b
        ,"P2"       : c
        ,"P3"       : d
        ,"P4"       : e
        ,"P5"       : f
        ,"P6"       : g
        ,"P7"       : h
        ,"id"       : i
        ,"account"  : j}
    )
    (defun UDC_CoilData:object{AutostakeV3.CoilData}
        (a:decimal b:decimal c:decimal d:decimal e:decimal f:decimal g:string)
        {"primal-input-amount"  : a
        ,"first-input-amount"   : b
        ,"royalty-fee"          : c
        ,"last-input-amount"    : d
        ,"hibernation-fee"      : e
        ,"rbt-amount"           : f
        ,"rbt-id"               : g}
    )
    (defun UDC_CanCoil:object{AutostakeComputerV2.CanCoil} (a:bool b:[string])
        {"can-coil"     : a
        ,"where-coil"   : b}
    )
    (defun UDC_CanConstrict:object{AutostakeComputerV2.CanConstrict} (a:bool b:[string])
        {"can-constrict"    : a
        ,"where-constrict"  : b}
    )
    (defun UDC_CanCurl:object{AutostakeComputerV2.CanCurl} (a:bool b:[[string]])
        {"can-curl"     : a
        ,"where-curl"   : b}
    )
    (defun UDC_CanBrumate:object{AutostakeComputerV2.CanBrumate} (a:bool b:[[string]])
        {"can-brumate"      : a
        ,"where-brumate"   : b}
    )
    ;;{5.2}  Compute [UC]
    (defun UC_AtspairAccount:string (atspair:string account:string)
        (format "{}{}{}" [atspair BAR account])
    )
    ;;
    ;;
    (defun UC_CanCoil:object{AutostakeComputerV2.CanCoil} (dptf:string)
        @doc "Computes if a DPTF can be coiled, and outputs a <CanCoil> object. \
            \ This object also points the ats-pairs towards which the <dptf> can be coiled."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (can-coil:bool (ref-DPTF::URC_IzRT dptf))
            )
            (if (not can-coil)
                (UDC_CanCoil can-coil [])
                (UDC_CanCoil can-coil (UCx_RewardTokenPairsByHibernate dptf true))
            )
        )
    )
    (defun UC_CanConstrict:object{AutostakeComputerV2.CanConstrict} (dptf:string)
        @doc "Like coil, but <where-constrict> lists only hibernating ATS pairs where <dptf> is RT."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (can-constrict:bool (ref-DPTF::URC_IzRT dptf))
            )
            (if (not can-constrict)
                (UDC_CanConstrict can-constrict [])
                (UDC_CanConstrict can-constrict (UCx_RewardTokenPairsByHibernate dptf false))
            )
        )
    )
    (defun UC_CanCurl:object{AutostakeComputerV2.CanCurl} (dptf:string)
        @doc "Computes if a DPTF can be curled. <dptf> is a reward token in non-hibernating \
            \ ats-pair-1; that pair's cold RBT is a reward token in non-hibernating ats-pair-2."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (if (not (ref-DPTF::URC_IzRT dptf))
                (UDC_CanCurl false [])
                (let
                    (
                        (chains:[[string]] (UCx_ChainsRtRbtSecondRt dptf true))
                    )
                    (UDC_CanCurl (< 0 (length chains)) chains)
                )
            )
        )
    )
    (defun UC_CanBrumate:object{AutostakeComputerV2.CanBrumate} (dptf:string)
        @doc "Like curl, but ats-pair-1 is non-hibernating and ats-pair-2 must be hibernating."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (if (not (ref-DPTF::URC_IzRT dptf))
                (UDC_CanBrumate false [])
                (let
                    (
                        (chains:[[string]] (UCx_ChainsRtRbtSecondRt dptf false))
                    )
                    (UDC_CanBrumate (< 0 (length chains)) chains)
                )
            )
        )
    )
    ;;
    (defun UCx_ChainsRtRbtSecondRt:[[string]] (dptf:string second-pairs-non-hibernate:bool)
        @doc "Two-hop chains [ats1 ats2]: <dptf> is RT on non-hibernating ats1; cold RBT of ats1 \
            \ is RT on ats2. Second hop uses <second-pairs-non-hibernate> (true: non-hibernate ats2 \
            \ only; false: hibernating ats2 only). Enforces ats1 != ats2."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (pair1-candidates:[string] (UCx_RewardTokenPairsByHibernate dptf true))
            )
            (fold
                (lambda (acc:[[string]] ats1:string)
                    (let
                        (
                            (rbt:string (UR_ColdRewardBearingToken ats1))
                            (pair2-candidates:[string]
                                (UCx_FilterHibernatedAts
                                    (ref-DPTF::UR_RewardToken rbt)
                                    second-pairs-non-hibernate
                                )
                            )
                        )
                        (+
                            acc
                            (fold
                                (lambda (row:[[string]] ats2:string)
                                    (if (!= ats1 ats2)
                                        (+ row [[ats1 ats2]])
                                        row
                                    )
                                )
                                []
                                pair2-candidates
                            )
                        )
                    )
                )
                []
                pair1-candidates
            )
        )
    )
    (defun UCx_RewardTokenPairsByHibernate:[string] (dptf:string non-hibernate:bool)
        @doc "ATS pairs where <dptf> is a reward token, filtered by hibernation: \
            \ <non-hibernate> true keeps non-hibernating pairs only; false keeps hibernating only."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (UCx_FilterHibernatedAts (ref-DPTF::UR_RewardToken dptf) non-hibernate)
        )
    )
    (defun UCx_FilterHibernatedAts:[string] (ats-pairs:[string] out-or-in:bool)
        @doc "If <out-or-in> is true, return <ats-pairs> with hibernating pairs removed; \
            \ if false, return only hibernating pairs."
        (if out-or-in
            (filter (lambda (ats-pair:string) (not (UR_Hibernate ats-pair))) ats-pairs)
            (filter (lambda (ats-pair:string) (UR_Hibernate ats-pair)) ats-pairs)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URU_UpgradeAtspairToV2 (atspairs:[string])
        (map
            (lambda
                (atspair:string)
                [
                    (UR_CanUpgrade atspair)
                    (UR_Hibernate atspair)
                    (UR_PeakHibernatePromile atspair)
                    (UR_HibernateDecay atspair)
                    (UR_Royalty atspair)
                    (UR_DirectRecoveryFee atspair)
                    (UR_ToggleDirectRecovery atspair)
                    (UR_RewardTokens atspair)
                ]
            )
            atspairs
        )
    )
    (defun UR_P-KEYS:[string] ()
        (keys ATS|Pairs)
    )
    (defun UR_KEYS:[string] ()
        (keys ATS|Ledger)
    )
    ;;
    (defun UR_Properties (atspair:string)
        (read ATS|Pairs atspair)
    )
    (defun UR_OwnerKonto:string (atspair:string)
        (at "owner-konto" (read ATS|Pairs atspair ["owner-konto"]))
    )
    (defun UR_CanUpgrade:bool (atspair:string)
        ;;#ATSm fix: this used to backfill a missing <can-upgrade> with a live table <update> --
        ;;an ungated write as a side effect of a nominal UR_* read, at the caller's gas expense,
        ;;and a read/write-separation violation of the UR_* prefix contract (same defect class as
        ;;DPTF's #30M <UR_Hibernation> and SWP's #50L <UR_StoaValue>, both already fixed).
        ;;Confirmed dead via a live StoaChain dirty-read (2026-09-10): all 4 deployed ATS pairs
        ;;already carry every one of these 8 fields, so the backfill branch never fires. The
        ;;write is dropped; the in-memory default fallback is kept, so the return value is
        ;;unchanged for every caller.
        (let 
            (
                (default-value:bool true)
                (temp (read ATS|Pairs atspair ["can-upgrade"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "can-upgrade" temp))
        )
    )
    (defun UR_CanChangeOwner:bool (atspair:string)
        (at "can-change-owner" (read ATS|Pairs atspair ["can-change-owner"]))
    )
    (defun UR_Syphoning:bool (atspair:string)
        (at "syphoning" (read ATS|Pairs atspair ["syphoning"]))
    )
    (defun UR_Hibernate:bool (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:bool false)
                (temp (read ATS|Pairs atspair ["hibernate"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "hibernate" temp))
        )
    )
    (defun UR_IndexName:string (atspair:string)
        (at "pair-index-name" (read ATS|Pairs atspair ["pair-index-name"]))
    )
    (defun UR_IndexDecimals:integer (atspair:string)
        (at "index-decimals" (read ATS|Pairs atspair ["index-decimals"]))
    )
    (defun UR_Royalty:decimal (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:decimal 0.0)
                (temp (read ATS|Pairs atspair ["royalty-promile"]))
                (needs-populate:bool (= temp {}))
                (link:decimal (if needs-populate default-value (at "royalty-promile" temp)))
            )
            (if (= link -1.0)
                0.0
                link
            )
        )
    )
    (defun UR_Syphon:decimal (atspair:string)
        (at "syphon" (read ATS|Pairs atspair ["syphon"]))
    )
    ;;
    (defun UR_PeakHibernatePromile:decimal (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:decimal 120.0)
                (temp (read ATS|Pairs atspair ["peak-hibernate-promile"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "peak-hibernate-promile" temp))
        )
    )
    (defun UR_HibernateDecay:decimal (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:decimal 0.008 )
                (temp (read ATS|Pairs atspair ["hibernate-decay"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "hibernate-decay" temp))
        )
    )
    ;;
    (defun UR_Lock:bool (atspair:string)
        (at "parameter-lock" (read ATS|Pairs atspair ["parameter-lock"]))
    )
    (defun UR_Unlocks:integer (atspair:string)
        (at "unlocks" (read ATS|Pairs atspair ["unlocks"]))
    )
    ;;
    (defun UR_RewardTokens:[object{AutostakeV3.ATS|RewardTokenSchemaV2}] (atspair:string)
        ;;#ATSm fix: migration backfill <update> dropped -- see <UR_CanUpgrade>. The write WAS
        ;;load-bearing here (the old body re-read the row afterwards), so the populate branch now
        ;;yields the royalty-augmented list directly instead of persisting then re-reading.
        (let
            (
                (temp:list (at "reward-tokens" (read ATS|Pairs atspair ["reward-tokens"])))
                (first-element (at 0 temp))
                (has-royalty:bool (contains "royalty" first-element))
                (needs-populate:bool (not has-royalty))
            )
            (if needs-populate
                (let
                    (
                        (default-royalty:decimal 0.0)
                        (ref-U|LST:module{StringProcessorV2} U|LST)
                    )
                    (fold
                        (lambda
                            (acc:[object{AutostakeV3.ATS|RewardTokenSchemaV2}] idx:integer)
                            (ref-U|LST::UC_AppL acc
                                (+
                                    (at idx temp)
                                    {"royalty" : default-royalty}
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length temp) 1))
                    )
                )
                temp
            )
        )
    )
    (defun UR_RewardTokenList:[string] (atspair:string)
        (fold
            (lambda
                (acc:[string] item:object{AutostakeV3.ATS|RewardTokenSchemaV2})
                (+ acc [(at "token" item)])
            )
            []
            (UR_RewardTokens atspair)
        )
    )
    (defun UR_RewardTokenNFR:[bool] (atspair:string)
        (fold
            (lambda
                (acc:[bool] item:object{AutostakeV3.ATS|RewardTokenSchemaV2})
                (+ acc [(at "nfr" item)])
            )
            []
            (UR_RewardTokens atspair)
        )
    )
    (defun UR_RewardTokenRUR:[decimal] (atspair:string rur:integer)
        @doc "Returns the RUR variables of a RewardToken Object \
            \ <rur> = 1: <resident> \
            \ <rur> = 2: <unbonding> \
            \ <rur> = 3: <royalty>"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
            )
            (ref-U|INT::UEV_PositionalVariable rur 3 "Invalid RUR Integer")
            (fold
                (lambda
                    (acc:[decimal] item:object{AutostakeV3.ATS|RewardTokenSchemaV2})
                    (ref-U|LST::UC_AppL acc
                        (cond
                            ((= rur 1) (at "resident" item))
                            ((= rur 2) (at "unbonding" item))
                            ((= rur 3) (at "royalty" item))
                            0.0
                        )
                    )
                )
                []
                (UR_RewardTokens atspair)
            )
        )
    )
    (defun UR_SingleRewardTokenNFR:bool (atspair:string rt:string)
        @doc "Read NFR of a Reward Token, Fails if <rt> is not Reward Token for <atspair>"
        (at (URCv_RewardTokenPosition atspair rt) (UR_RewardTokenNFR atspair))
    )
    (defun UR_SingleRewardTokenRUR:decimal (atspair:string rt:string rur:integer)
        @doc "Read RUR of a Reward Token, Fails if <rt> is not Reward Token for <atspair>"
        (at (URCv_RewardTokenPosition atspair rt) (UR_RewardTokenRUR atspair rur))
    )
    ;;Cold Recovery
    (defun UR_ColdRewardBearingToken:string (atspair:string)
        (at "c-rbt" (read ATS|Pairs atspair ["c-rbt"]))
    )
    (defun UR_ColdNativeFeeRedirection:bool (atspair:string)
        (at "c-nfr" (read ATS|Pairs atspair ["c-nfr"]))
    )
    (defun UR_ColdRecoveryPositions:integer (atspair:string)
        (at "c-positions" (read ATS|Pairs atspair ["c-positions"]))
    )
    (defun UR_ColdRecoveryFeeThresholds:[decimal] (atspair:string)
        (at "c-limits" (read ATS|Pairs atspair ["c-limits"]))
    )
    (defun UR_ColdRecoveryFeeTable:[[decimal]] (atspair:string)
        (at "c-array" (read ATS|Pairs atspair ["c-array"]))
    )
    (defun UR_ColdRecoveryFeeRedirection:bool (atspair:string)
        (at "c-fr" (read ATS|Pairs atspair ["c-fr"]))
    )
    (defun UR_ColdRecoveryDuration:[integer] (atspair:string)
        (at "c-duration" (read ATS|Pairs atspair ["c-duration"]))
    )
    (defun UR_EliteMode:bool (atspair:string)
        (at "c-elite-mode" (read ATS|Pairs atspair ["c-elite-mode"]))
    )
    ;;Hot Recovery
    (defun UR_HotRewardBearingToken:string (atspair:string)
        (at "h-rbt" (read ATS|Pairs atspair ["h-rbt"]))
    )
    (defun UR_HotRecoveryStartingFeePromile:decimal (atspair:string)
        (at "h-promile" (read ATS|Pairs atspair ["h-promile"]))
    )
    (defun UR_HotRecoveryDecayPeriod:integer (atspair:string)
        (at "h-decay" (read ATS|Pairs atspair ["h-decay"]))
    )
    (defun UR_HotRecoveryFeeRedirection:bool (atspair:string)
        (at "h-fr" (read ATS|Pairs atspair ["h-fr"]))
    )
    ;;Direct Recovery
    (defun UR_DirectRecoveryFee:decimal (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:decimal 0.0)
                (temp (read ATS|Pairs atspair ["d-promile"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "d-promile" temp))
        )
    )
    ;;Toggle Recoveries
    (defun UR_ToggleColdRecovery:bool (atspair:string)
        (at "cold-recovery" (read ATS|Pairs atspair ["cold-recovery"]))
    )
    (defun UR_ToggleHotRecovery:bool (atspair:string)
        (at "hot-recovery" (read ATS|Pairs atspair ["hot-recovery"]))
    )
    (defun UR_ToggleDirectRecovery:bool (atspair:string)
        ;;#ATSm fix: ungated migration backfill <update> dropped -- see <UR_CanUpgrade>.
        (let 
            (
                (default-value:bool false)
                (temp (read ATS|Pairs atspair ["direct-recovery"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "direct-recovery" temp))
        )
    )
    ;;
    ;;
    (defun UR_RtPrecisions:[integer] (atspair:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (fold
                (lambda
                    (acc:[integer] rt:string)
                    (ref-U|LST::UC_AppL acc (ref-DPTF::UR_Decimals rt))
                )
                []
                (UR_RewardTokenList atspair)
            )
        )
    )
    (defun UR_P0:[object{UtilityAtsV3.Awo}] (atspair:string account:string)
        (at "P0" (read ATS|Ledger (UC_AtspairAccount atspair account) ["P0"]))
    )
    (defun UR_P1-7:object{UtilityAtsV3.Awo} (atspair:string account:string position:integer)
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (k:string (UC_AtspairAccount atspair account))
            )
            (ref-U|INT::UEV_PositionalVariable position 7 "Invalid Position Number")
            (cond
                ((= position 1) (at "P1" (read ATS|Ledger k ["P1"])))
                ((= position 2) (at "P2" (read ATS|Ledger k ["P2"])))
                ((= position 3) (at "P3" (read ATS|Ledger k ["P3"])))
                ((= position 4) (at "P4" (read ATS|Ledger k ["P4"])))
                ((= position 5) (at "P5" (read ATS|Ledger k ["P5"])))
                ((= position 6) (at "P6" (read ATS|Ledger k ["P6"])))
                ((= position 7) (at "P7" (read ATS|Ledger k ["P7"])))
                (UDC_MakeNegativeUnstakeObject atspair)
            )
        )
    )
    (defun UR_P-Seven:[object{UtilityAtsV3.Awo}]
        (atspair:string account:string)
        (let
            (
                (k:string (UC_AtspairAccount atspair account))
            )
            [
                (at "P1" (read ATS|Ledger k ["P1"]))
                (at "P2" (read ATS|Ledger k ["P2"]))
                (at "P3" (read ATS|Ledger k ["P3"]))
                (at "P4" (read ATS|Ledger k ["P4"]))
                (at "P5" (read ATS|Ledger k ["P5"]))
                (at "P6" (read ATS|Ledger k ["P6"]))
                (at "P7" (read ATS|Ledger k ["P7"]))
            ]
        )
        
    )
    (defun URC_Index (atspair:string)
        @doc "Computes the Index of an <atspair>"
        (let
            (
                (p:integer (UR_IndexDecimals atspair))
                (rs:decimal (URC_ResidentSum atspair))
                (rbt-supply:decimal (URC_PairRBTSupply atspair))
            )
            (if
                (= rbt-supply 0.0)
                -1.0
                (floor (/ rs rbt-supply) p)
            )
        )
    )
    (defun URC_ResidentSum:decimal (atspair:string)
        @doc "Computes the Residend Sum of all <atspair> Reward Tokens"
        (fold (+) 0.0 (UR_RewardTokenRUR atspair 1))
    )
    (defun URC_PairRBTSupply:decimal (atspair:string)
        @doc "Computed the Total Sum of Reward Bearing Tokens of an <atspair> \
            \ Also inludes the Hot-RBT amount"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (c-rbt:string (UR_ColdRewardBearingToken atspair))
                (c-rbt-supply:decimal (ref-DPTF::UR_Supply c-rbt))
            )
            (if (= (URC_IzPresentHotRBT atspair) false)
                c-rbt-supply
                (let
                    (
                        (h-rbt:string (UR_HotRewardBearingToken atspair))
                        (h-rbt-supply:decimal (ref-DPOF::UR_Supply h-rbt))
                    )
                    (+ c-rbt-supply h-rbt-supply)
                )
            )
        )
    )
    (defun URC_RBT:decimal (atspair:string rt:string rt-amount:decimal)
        @doc "Computes the value in RBT of a given <rt> Token <rt-amount> for an <atspair>"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (index:decimal (abs (URC_Index atspair)))
                (c-rbt:string (UR_ColdRewardBearingToken atspair))
                (p-rbt:integer (ref-DPTF::UR_Decimals c-rbt))
            )
            (enforce
                (= (floor rt-amount p-rbt) rt-amount)
                (format "Input amount of {} must have at most a precision equal to that of the Cold-RBT ({})" [rt-amount p-rbt])
            )
            ;;THE SINGULARITY. <index> is a share price and the line below inverts it, so a zero
            ;;index is a division by zero -- and zero is a REACHABLE LIVE STATE, not a contrived
            ;;input: any pair whose reward-bearing token carries supply minted OUTSIDE the pool
            ;;reads resident-sum 0 against a positive rbt-supply, which is exactly the state the
            ;;five AOZ primal-asset pools are in at deploy.
            ;;
            ;;The sibling op already refuses this: ATSU|C>FUEL enforces (>= index 0.1) and its
            ;;message was reworded on 2026-09-13 specifically so the caller is told something true
            ;;about their own pair. ATSU|C>COIL has no index check at all, so the coil door -- the
            ;;one an ordinary user reaches -- died inside the arithmetic with
            ;;"Arithmetic exception: div by zero, decimal", which names neither the pool nor the
            ;;cause, and which `try` cannot even catch.
            ;;
            ;;Guarded HERE rather than in ATSU|C>COIL deliberately: this is the function that
            ;;divides, and it is shared by the exec path and by the INFO cost previews, so a quote
            ;;for an impossible coil now refuses in the same words instead of throwing.
            ;;Pinned by RedTeam/[RT-A]_Economics.repl <<RT-A-003c>>/<<RT-A-003d>>.
            (enforce
                (> index 0.0)
                (format "Coiling requires an ATS-Pair Index greater than zero; {} has none" [atspair])
            )
            (floor (/ rt-amount index) p-rbt)
        )
    )
    (defun URCv_RTSplitAmounts:[decimal] (atspair:string rbt-amount:decimal)
        @doc "Computes the amount of RT Tokens an <rbt-amount> of RBT would yield for an <atspair>"
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (rbt-supply:decimal (URC_PairRBTSupply atspair))
                (index:decimal (URC_Index atspair))
                (resident-amounts:[decimal] (UR_RewardTokenRUR atspair 1))
                (rt-precision-lst:[integer] (UR_RtPrecisions atspair))
            )
            (enforce (<= rbt-amount rbt-supply) "Cannot compute for amounts greater than the pairs rbt supply")
            ;;Same singularity URC_RBT carries, same reasoning: the split divides by <index>, and a
            ;;zero index is a reachable live state (rbt-supply minted outside the pool). Guarded
            ;;HERE because ten call sites across ATSU and the INFO readers share this function --
            ;;one enforce covers every one of them, and they all refuse in the same words.
            (enforce
                (> index 0.0)
                (format "ATS-Pair {} has a zero Index; reward-token amounts cannot be derived" [atspair])
            )
            (ref-U|ATS::UC_SplitByIndexedRBT rbt-amount rbt-supply index resident-amounts rt-precision-lst)
        )
    )
    (defun URC_MaxSyphon:[decimal] (atspair:string)
        @doc "Computes the maximum amount of RTs that can be syphoned from the <atspair>"
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (index:decimal (URC_Index atspair))
                (syphon:decimal (UR_Syphon atspair))
                (resident-amounts:[decimal] (UR_RewardTokenRUR atspair 1))
                (precisions:[integer] (UR_RtPrecisions atspair))
                (max-precision:integer (ref-U|INT::UEV_MaxInteger precisions))
                (max-pp:integer (at 0 (ref-U|LST::UC_Search precisions max-precision)))
                (pair-rbt-supply:decimal (URC_PairRBTSupply atspair))
            )
            (if (<= index syphon)
                (make-list (length precisions) 0.0)
                (let
                    (
                        (index-diff:decimal (- index syphon))
                        (rbt:string (UR_ColdRewardBearingToken atspair))
                        (rbt-precision:integer (ref-DPTF::UR_Decimals rbt))
                        (max-sum:decimal (floor (* pair-rbt-supply index-diff) rbt-precision))
                        (prelim:[decimal]
                            (fold
                                (lambda
                                    (acc:[decimal] idx:integer)
                                    (ref-U|LST::UC_AppL acc
                                        (floor (/ (* (- index syphon) (at idx resident-amounts)) index) (at idx precisions))
                                    )
                                )
                                []
                                (enumerate 0 (- (length precisions) 1))
                            )
                        )
                        (prelim-sum:decimal (fold (+) 0.0 prelim))
                        (diff:decimal (- max-sum prelim-sum))
                    )
                    (if (= diff 0.0)
                        prelim
                        (ref-U|LST::UC_ReplaceAt prelim max-pp (+ diff (at max-pp prelim)))
                    )
                )
            )
        )
    )
    ;;
    (defun URCv_RewardTokenPosition:integer (atspair:string reward-token:string)
        @doc "Computes the position of a RT in the <atspair> definition"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (reward-token-lst:[string] (UR_RewardTokenList atspair))
                (iz-on-lst:bool (contains reward-token reward-token-lst))
            )
            (enforce iz-on-lst (format "RT {} isnt not an RT in the ATS-Pair {}" [reward-token atspair]))
            (at 0 (ref-U|LST::UC_Search reward-token-lst reward-token))
        )
    )
    ;;Autostake Account
    (defun URC_AccountUnbondingBalance:decimal (atspair:string account:string reward-token:string)
        @doc "Computes the unbonding amount for a given <account> and specific <atspair> and <reward-token>"
        (+
            (fold
                (lambda
                    (acc:decimal item:object{UtilityAtsV3.Awo})
                    (+ acc (URCx_UnstakeObjectUnbondingValue atspair reward-token item))
                )
                0.0
                (UR_P0 atspair account)
            )
            (fold
                (lambda
                    (acc:decimal item:integer)
                    (+ acc (URCx_UnstakeObjectUnbondingValue atspair reward-token (UR_P1-7 atspair account item)))
                )
                0.0
                (enumerate 1 7)
            )
        )
    )
    (defun URCx_UnstakeObjectUnbondingValue (atspair:string reward-token:string io:object{UtilityAtsV3.Awo})
        (let
            (
                (rtp:integer (URCv_RewardTokenPosition atspair reward-token))
                (rt:[decimal] (at "reward-tokens" io))
                (rb:decimal (at rtp rt))
            )
            (if (= rb -1.0)
                0.0
                rb
            )
        )
    )
    (defun URC_CullValue:[decimal] (atspair:string input:object{UtilityAtsV3.Awo})
        @doc "Computes the Cull value of an <input> unstake objected, given a specific <atspair> \
        \ Returns a list of decimal, the list having as many decimal as the <atspair> has reward tokens \
        \ Returns a list of 0.0 is nothing can be culled"
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (rt-lst:[string] (UR_RewardTokenList atspair))
                (rt-amounts:[decimal] (at "reward-tokens" input))
                (l:integer (length rt-lst))
                (iz:bool (ref-U|ATS::UC_IzCullable input))
            )
            (if iz
                rt-amounts
                (make-list l 0.0)
            )
        )
    )
    (defun URC_WhichPosition:integer (atspair:string c-rbt-amount:decimal account:string)
        @doc "Computes which Position can be used next for uncoiling"
        (let
            (
                (elite:bool (UR_EliteMode atspair))
            )
            (if elite
                (URCx_ElitePosition atspair c-rbt-amount account)
                (URCx_NonElitePosition atspair account)
            )
        )
    )
    (defun URCx_ElitePosition:integer (atspair:string c-rbt-amount:decimal account:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ELITE:module{EliteV2} ELITE)
                (positions:integer (UR_ColdRecoveryPositions atspair))
                (c-rbt:string (UR_ColdRewardBearingToken atspair))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
            )
            (if (!= ea-id BAR)
                (let
                    (
                        (iz-ea-id:bool (if (= ea-id c-rbt) true false))
                        (pstate:[integer] (URCx_PSL atspair account))
                        (met:integer (ref-DALOS::UR_Elite-Tier-Major account))
                        (ea-supply:decimal (ref-DPTF::UR_AccountSupply ea-id account))
                        (t-ea-supply:decimal (ref-ELITE::URC_EliteAurynzSupply account))
                        (virtual-met:integer (str-to-int (take 1 (at "tier" (ref-U|ATS::UDC_Elite (- t-ea-supply c-rbt-amount))))))
                        ;;(available:[integer] (if iz-ea-id (take virtual-met pstate) (take met pstate)))
                        ;;Resulting tier after uncoil must support the position we use; tier 0 still allows 1 position.
                        (positions-after:integer (if (= virtual-met 0) 1 virtual-met))
                        (available:[integer] (if iz-ea-id (take positions-after pstate) (take met pstate)))
                        (search-res:[integer] (ref-U|LST::UC_Search available 1))
                    )
                    (if iz-ea-id
                        (enforce (<= c-rbt-amount ea-supply) "Amount of EA used for Cold Recovery cannot be greater than what exists on Account")
                        true
                    )
                    (if (= (length search-res) 0)
                        0
                        (+ (at 0 search-res) 1)
                    )
                )
                (URCx_NonElitePosition atspair account)
            )
        )
    )
    (defun URCx_NonElitePosition:integer (atspair:string account:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (positions:integer (UR_ColdRecoveryPositions atspair))
            )
            (if (= positions -1)
                -1
                (let
                    (
                        (pstate:[integer] (URCx_PSL atspair account))
                        (available:[integer] (take positions pstate))
                        (search-res:[integer] (ref-U|LST::UC_Search available 1))
                    )
                    (if (= (length search-res) 0)
                        0
                        (+ (at 0 search-res) 1)
                    )
                )
            )
        )
    )
    (defun URCx_PSL:[integer] (atspair:string account:string)
        (fold
            (lambda
                (acc:[integer] idx:integer)
                (+ acc [(URCx_PosSt atspair account idx)])
            )
            []
            (enumerate 1 7)
        )
    )
    (defun URCx_PosSt:integer (atspair:string account:string position:integer)
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (zero:object{UtilityAtsV3.Awo} 
                    ;;Opened
                    (UDC_MakeZeroUnstakeObject atspair)
                )
                (negative:object{UtilityAtsV3.Awo} 
                    ;;Closed
                    (UDC_MakeNegativeUnstakeObject atspair)
                )
                (elite:bool (UR_EliteMode atspair))
                (hybrid:object{UtilityAtsV3.Awo}
                    (if elite negative zero)
                )
            )
            (ref-U|INT::UEV_PositionalVariable position 7 "Input Position out of bounds")
            (with-default-read ATS|Ledger (UC_AtspairAccount atspair account)
                {"P1"   : zero
                ,"P2"   : hybrid
                ,"P3"   : hybrid
                ,"P4"   : hybrid
                ,"P5"   : hybrid
                ,"P6"   : hybrid
                ,"P7"   : hybrid}
                { "P1" := p1, "P2" := p2, "P3" := p3, "P4" := p4, "P5" := p5, "P6" := p6, "P7" := p7 }
                (cond
                    ((= position 1) (URCx_PosObjSt atspair p1))
                    ((= position 2) (URCx_PosObjSt atspair p2))
                    ((= position 3) (URCx_PosObjSt atspair p3))
                    ((= position 4) (URCx_PosObjSt atspair p4))
                    ((= position 5) (URCx_PosObjSt atspair p5))
                    ((= position 6) (URCx_PosObjSt atspair p6))
                    ((= position 7) (URCx_PosObjSt atspair p7))
                    0
                )
            )
        )
    )
    (defun URCx_PosObjSt:integer (atspair:string input-obj:object{UtilityAtsV3.Awo})
        @doc "Computes the state of an uncoil positional object, \
        \ to see if it the position it is on can be used for uncoiling \
        \ <-1> = closed; <0> = occupied; <1> = opened"
        (let
            (
                (zero:object{UtilityAtsV3.Awo} (UDC_MakeZeroUnstakeObject atspair))
                (negative:object{UtilityAtsV3.Awo} (UDC_MakeNegativeUnstakeObject atspair))
            )
            (if (= input-obj zero)
                1
                (if (= input-obj negative)
                    -1
                    0
                )
            )
        )
    )
    (defun URCv_ColdRecoveryFee (atspair:string c-rbt-amount:decimal input-position:integer)
        @doc "Computes the Cold Recovery Fee for a given <c-rbt-amount> of a given <atspair> on a given <input-position>"
        (enforce (!= input-position 0) "Cannot Compute Cold Recovery Fee as no more Cold Recovery Positions are available")
        (let
            (
                (ats-limit-values:[decimal] (UR_ColdRecoveryFeeThresholds atspair))
                (ats-limits:integer (length ats-limit-values))
                (ats-fee-array:[[decimal]] (UR_ColdRecoveryFeeTable atspair))
                (ats-fee-array-length:integer (length ats-fee-array))
                (ats-fee-array-length-length:integer (length (at 0 ats-fee-array)))
                (zc1:bool (if (= ats-limits 1) true false))
                (zc2:bool (if (= (at 0 ats-limit-values) 0.0) true false))
                (zc3:bool (and zc1 zc2))
                (zc4:bool (if (= ats-fee-array-length 1) true false))
                (zc5:bool (if (= ats-fee-array-length-length 1) true false))
                (zc6:bool (and zc4 zc5))
                (zc7:bool (if (= (at 0 (at 0 ats-fee-array)) 0.0) true false))
                (zc8:bool (and zc6 zc7))
                (zc9:bool (and zc3 zc8))
            )
            (if zc9
                0.0
                (let
                    (
                        (limit:integer
                            (fold
                                (lambda
                                    (acc:integer tv:decimal)
                                    (if (< c-rbt-amount tv)
                                        acc
                                        (+ acc 1)
                                    )
                                )
                                0
                                ats-limit-values
                            )
                        )
                        (qlst:[decimal]
                            (if (= input-position -1)
                                (at 0 ats-fee-array)
                                (at (- input-position 1) ats-fee-array)
                            )
                        )
                    )
                    (at limit qlst)
                )
            )
        )
    )
    (defun URC_CullColdRecoveryTime:time (atspair:string account:string)
        @doc "Computes the Cull Time for Cold Recovery for a given <atspair> and <account>"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
                (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
                (position:integer
                    (if (= major 0)
                        0
                        (+ (* (- major 1) 7) minor)
                    )
                )
                (crd:[integer] (UR_ColdRecoveryDuration atspair))
                (h:integer (at position crd))
                (present-time:time (at "block-time" (chain-data)))
            )
            (add-time present-time (hours h))
        )
    )
    (defun URC_IzPresentHotRBT:bool (atspair:string)
        @doc "Returns a Boolean if an <atspair> has a Hot-RBT or not"
        (if (= (UR_HotRewardBearingToken atspair) BAR)
            false
            true
        )
    )
    ;;
    (defun URC_RewardBearingTokenAmounts:object{AutostakeV3.CoilData}
        (ats:string rt:string amount:decimal)
        (URCx_RBT-Amount ats rt amount 1)
    )
    (defun URC_RewardBearingTokenAmountsWithHibernation:object{AutostakeV3.CoilData}
        (ats:string rt:string amount:decimal hibernation-dayz:integer)
        (URCx_RBT-Amount ats rt amount hibernation-dayz)
    )
    (defun URCx_RBT-Amount:object{AutostakeV3.CoilData} 
        (ats:string rt:string amount:decimal dayz:integer)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (h:bool (ref-ATS::UR_Hibernate ats))
                (royalty:decimal (ref-ATS::UR_Royalty ats))
                (rt-prec:integer (ref-DPTF::UR_Decimals rt))
                (royalty-split:[decimal] (ref-U|ATS::UC_PromilleSplit royalty amount rt-prec))
                (input-amount:decimal (at 0 royalty-split))
                (royalty-fee:decimal (at 1 royalty-split))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
            )
            (if (not h)
                (UDC_CoilData
                    amount
                    input-amount
                    royalty-fee
                    input-amount
                    0.0
                    (ref-ATS::URC_RBT ats rt input-amount)
                    c-rbt
                )
                (let
                    (
                        (php:decimal (ref-ATS::UR_PeakHibernatePromile ats))
                        (hd:decimal (ref-ATS::UR_HibernateDecay ats))
                        (raw-hibernation-fee-promile:decimal (- php (* hd (dec dayz))))
                        (hibernation-fee-promile:decimal 
                            (if (<= raw-hibernation-fee-promile 0.0)
                                0.0
                                raw-hibernation-fee-promile
                            )
                        )
                        (hibernating-split:[decimal] (ref-U|ATS::UC_PromilleSplit hibernation-fee-promile input-amount rt-prec))
                        (last-input-amount:decimal (at 0 hibernating-split))
                        (hibernation-fee:decimal (at 1 hibernating-split))
                    )
                    (UDC_CoilData
                        amount
                        input-amount
                        royalty-fee
                        last-input-amount
                        hibernation-fee
                        (ref-ATS::URC_RBT ats rt last-input-amount)
                        c-rbt
                    )
                )
            )
        )
    )
    ;;
    ;;  [URD]
    ;;
    ;;1] Returns ATSPairs that Have the Account registered in the ATS|Ledger (has used unstake)
    (defun URH_HeldAutostakePairs:[string] (account:string)
        @doc "Returns all ATSpairs for which the <account> existsin the ATS|Ledger Table"
        (map (at "id")
            (select ATS|Ledger ["id"]
                (where "account" (= account))
            )
        )
    )
    ;;2]Returns Accounts have used a given ATSpair Unstaking
    (defun URH_ExistingAutostakePairs:[string] (ats:string)
        @doc "Returns all Ouronet Accounts that exist in a given <ats> ATS|Ledger"
        (map (at "account")
            (select ATS|Ledger ["account"]
                (where "id" (= ats))
            )
        )
    )
    ;;3]Returns a List of ATSPairs that are owned by a given Account for Management Purposes
    (defun URH_OwnedAutostakePairs:[string] (account:string)
        @doc "Returns all ATSPairs that can be managed by the given <account>"
        (map (at "id")
            (select ATS|Pairs ["id"]
                (where "owner-konto" (= account))
            )
        )
    )
    ;;
    ;;
    ;;[URCi] cost readers — single cost source per op. The C_ returns/bills its URCi; Phase 1.2 INFO
    ;;  previews from the same reader. (HOT-RBT branding/Repurpose forward DPOF costs — no own URCi.)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_BrandingCumulator (UR_OwnerKonto entity-id) 5.0)
        )
    )
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_RotateOwnership" "auth")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_Control" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateRoyalty:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_UpdateRoyalty" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateSyphon:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_UpdateSyphon" "usage")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetHibernationFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SetHibernationFees" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ControlColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_ControlColdRecoveryFees" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetColdRecoveryDuration:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SetColdRecoveryDuration" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleElite:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_ToggleElite" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleUpgrade:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_ToggleUpgrade" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SwitchColdRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SwitchColdRecovery" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ControlHotRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_ControlHotRecoveryFee" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetHotRecoveryFees:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        @doc "Cost preview for the ATS|C_SetHotRecoveryFee client (core fn is plural, the \
            \ Talos op is singular — billed under the TALOS name like every other key)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SetHotRecoveryFee" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SwitchHotRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SwitchHotRecovery" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetDirectRecoveryFee:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SetDirectRecoveryFee" "fee")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SwitchDirectRecovery:object{IgnisCollectorV3.OutputCumulator} (atspair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "ATS|C_SwitchDirectRecovery" "setup")
                (UR_OwnerKonto atspair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;  Construct-with-price (pure): also reused for C_AddHotRBT's ico0 (identical token-issue construct).
    (defun URCi_AddSecondary:object{IgnisCollectorV3.OutputCumulator} ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "ATS|C_AddSecondary" "ats-secondary") ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_AddHotRBT:object{IgnisCollectorV3.OutputCumulator} (atspair:string hot-rbt:string)
        @doc "Cost preview for C_AddHotRBT — pure re-derivation of its 3-leg concat: an \
            \ AddSecondary leg + a conditional hot-rbt RotateOwnership (only when the hot-rbt \
            \ is not already owned by ATS|SC_NAME) + the hot-rbt Control lock."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (hot-rbt-owner:string (ref-DPOF::UR_Konto hot-rbt))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (URCi_AddSecondary)
                    (if (!= hot-rbt-owner ATS|SC_NAME) (ref-DPOF::URCi_RotateOwnership hot-rbt) EOC)
                    (ref-DPOF::URCi_Control hot-rbt)
                ]
                []
            )
        )
    )
    (defun URCi_SetColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (* (ref-IGNIS::UC_IgnisLeg "tier-biggest") 20.0) ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;  ToggleParameterLock: full cumulator re-derived from unlocks (read PRE-increment — see C_).
    (defun URCi_ToggleParameterLock:object{IgnisCollectorV3.OutputCumulator} (atspair:string toggle:bool)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (unlock-costs:[decimal] (if toggle [0.0 0.0] (ref-IGNIS::UC_FeeUnlockPrice)))
                (gas-costs:decimal (+ (ref-IGNIS::UC_IgnisLeg "tier-small") (at 0 unlock-costs)))
                (output:bool (> (at 1 unlock-costs) 0.0))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [output])
        )
    )
    (defun URCi_ToggleParameterLockStoa:decimal (atspair:string toggle:bool)
        @doc "STOA leg of a parameter-lock toggle: locking is free, unlocking costs the \
            \ fee-unlock price. Read-only twin of the <XI_ToggleParameterLock> return that \
            \ <C_ToggleParameterLock> hands to <XE_CollectStoa>, so the INFO_ preview and the \
            \ charge move as one. Mirrors DPTF's <URCi_ToggleFeeLockStoa>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if toggle 0.0 (at 1 (ref-IGNIS::UC_FeeUnlockPrice)))
        )
    )
    ;;  Issue/UpgradeBranding: :decimal price rails (cumulator output / write side-effect stays in the C_/XI).
    (defun URCi_IssueGas:decimal (token-count:integer)
        @doc "IGNIS issuance price per token. Sourced from the CENTRAL IG|DETER map in the \
            \ IGNIS module (rehaul substage 5, 1 ignis = 1 cent): autostake pair issuance = $40 = 4000 ignis/pair (owner 2026-09-05). \
            \ Shared by the exec path and its INFO_* preview, so both move as one."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            ;;deterrence scales PER TOKEN; the op's own compute is charged ONCE
            (+ (* (dec token-count) (ref-IGNIS::UC_IgnisDeter "issue-ats-pair"))
               (ref-IGNIS::UC_IgnisComponents "ATS|C_Issue"))
        )
    )
    (defun URCi_IssueStoa:decimal (token-count:integer)
        @doc "STOA leg of issuance, per token. Carries the SAME DOLLAR VALUE as the IGNIS deter \
            \ (autostake pair = $40 => 400 STOA), converted at the live STOA price by UC_StoaPrice — so \
            \ when a real STOA price replaces the $0.10 peg the AMOUNT moves but the value the \
            \ user pays does not. Shared by the exec path and its INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (* (dec token-count) (ref-IGNIS::UC_StoaPrice "issue-ats-pair"))
        )
    )
    (defun URCi_UpgradeBranding:decimal (months:integer)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (ref-BRD::URCi_UpgradeBranding months)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_id (atspair:string)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (ref-U|ATS::UEV_UniqueAtspair atspair)
            (with-default-read ATS|Pairs atspair
                { "unlocks" : -1 }
                { "unlocks" := u }
                (enforce
                    (>= u 0)
                    (format "ATS-Pair {} does not exist" [atspair])
                )
            )
        )
    )
    (defun UEV_CanUpgradeON (atspair:string)
        @doc "Gates ATS|S>CONTROL (C_Control: can-change-owner/syphoning/hibernate). \
            \ can-upgrade is settable via C_ToggleUpgrade (audit finding #21L / L3)."
        (let
            (
                (x:bool (UR_CanUpgrade atspair))
            )
            (enforce x (format "{} properties cannot be upgraded" [atspair]))
        )
    )
    (defun UEV_CanChangeOwnerON (atspair:string)
        (UEV_id atspair)
        (let
            (
                (x:bool (UR_CanChangeOwner atspair))
            )
            (enforce (= x true) (format "ATS Pair {} ownership cannot be changed" [atspair]))
        )
    )
    (defun UEV_RewardTokenExistance (atspair:string reward-token:string existance:bool)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (existance-check:bool (ref-DPTF::URC_IzRTg atspair reward-token))
            )
            (enforce 
                (= existance-check existance) 
                (format "{} Existance isnt verified for Token {} as RT with ATS Pair {}" [existance reward-token atspair])
            )
        )
    )
    (defun UEV_RewardBearingTokenExistance (atspair:string reward-bearing-token:string existance:bool cold-or-hot:bool)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (existance-check:bool
                    (if cold-or-hot
                        (ref-DPTF::URC_IzRBTg atspair reward-bearing-token)
                        (ref-DPOF::URC_IzRBTg atspair reward-bearing-token)
                    )
                )
            )
            (enforce (= existance-check existance) (format "{} Existance isnt verified for Token {} as RBT with ATS Pair {}" [existance reward-bearing-token atspair]))
        )
    )
    (defun UEV_ParameterLockState (atspair:string state:bool)
        (let
            (
                (x:bool (UR_Lock atspair))
            )
            (enforce (= x state) (format "Parameter-lock for ATS Pair {} must be set to {} for this operation" [atspair state]))
        )
    )
    (defun UEV_EliteState (atspair:string state:bool)
        (let
            (
                (x:bool (UR_EliteMode atspair))
            )
            (enforce (= x state) (format "Elite-Mode for ATS Pair {} must be set to {} for this operation" [atspair state]))
        )
    )
    (defun UEV_ColdRecoveryState (atspair:string state:bool)
        (let
            (
                (x:bool (UR_ToggleColdRecovery atspair))
            )
            (enforce (= x state) (format "Cold Recovery for ATS Pair {} must be set to {} for exec" [atspair state]))
        )
    )
    (defun UEV_HotRecoveryState (atspair:string state:bool)
        (let
            (
                (x:bool (UR_ToggleHotRecovery atspair))
            )
            (enforce (= x state) (format "Hot Recovery for ATS Pair {} must be set to {} for exec" [atspair state]))
        )
    )
    (defun UEV_DirectRecoveryState (atspair:string state:bool)
        (let
            (
                (x:bool (UR_ToggleDirectRecovery atspair))
            )
            (enforce (= x state) (format "Direct Recovery for ATS Pair {} must be set to {} for exec" [atspair state]))
        )
    )
    (defun UEV_IssueData (atspair:string index-decimals:integer reward-token:string reward-bearing-token:string)
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (rt-ftc:string (take 2 reward-token))
                (rbt-ftc:string (take 2 reward-bearing-token))
            )
            ;;0]Index name shape - relocated here from XI_Issue (StoicSyntax §7.20 step 1: an
            ;;  enforcement does not belong in an X_). Runs per element inside ATS|C>ISSUE, the
            ;;  single place it belongs. <atspair> was a DEAD parameter until now, and the caller
            ;;  no longer burns a UDC_Makeid per element to build a value nothing read.
            (ref-U|ATS::UEV_AutostakeIndex atspair)
            (ref-U|DALOS::UEV_Decimals index-decimals)
            ;;1]Token Ownership
            (ref-DPTF::CAP_Owner reward-token)
            (ref-DPTF::CAP_Owner reward-bearing-token)
            ;;2]Cannot register the Same Token as RT and RBT
            (enforce (!= reward-token reward-bearing-token) "RT must be different from RBT")
            ;;3]RTs and RBTs cannot be F|, R|, or LP Tokens (S|, W|, P|, - Tokens)
            (enforce
                (and
                    (not (contains rt-ftc ["F|" "R|" "S|" "W|" "P|"]))
                    (not (contains rbt-ftc ["F|" "R|" "S|" "W|" "P|"]))
                )
                "An Autostake Pool cannot be issued when either the RT or RBT are Special or LP Tokens"
            )
        )
    )
    (defun CAP_Owner (id:string)
        @doc "Enforces Atspair Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_OwnerKonto id))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 1 — Innate protection offered by XI_Issue, XE_Issue,
    ;;Protection:          XE_UpdateRewardToken, XE_UpdateRewardBearingToken
    (defun XI_FoldedIssue:[string]
        (
            account:string
            atspair:[string]
            index-decimals:[integer]
            reward-token:[string]
            rt-nfr:[bool]
            reward-bearing-token:[string]
            rbt-nfr:[bool]
        )
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-BRD:module{BrandingV2} BRD)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (fold
                (lambda
                    (acc:[string] index:integer)
                    (let
                        (
                            (ats-id:string
                                (XI_Issue
                                    account
                                    (at index atspair)
                                    (at index index-decimals)
                                    (at index reward-token)
                                    (at index rt-nfr)
                                    (at index reward-bearing-token)
                                    (at index rbt-nfr)
                                )
                            )
                        )
                        (ref-BRD::XE_Issue ats-id)
                        (ref-DPTF::XE_UpdateRewardToken ats-id (at index reward-token) true)
                        (ref-DPTF::XE_UpdateRewardBearingToken ats-id (at index reward-bearing-token))
                        (ref-U|LST::UC_AppL acc ats-id)
                    )
                )
                []
                (enumerate 0 (- (length atspair) 1))
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_Issue:string
        (
            account:string
            atspair:string
            index-decimals:integer
            reward-token:string
            rt-nfr:bool
            reward-bearing-token:string
            rbt-nfr:bool
        )
        (require-capability (SECURE))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ats-sc:string ATS|SC_NAME)
                (id:string (ref-U|DALOS::UDC_Makeid atspair))
            )
            (insert ATS|Pairs id
                {"id"                       : id
                ,"owner-konto"              : account
                ,"can-upgrade"              : true
                ,"can-change-owner"         : true
                ,"syphoning"                : false
                ,"hibernate"                : false
                ,"pair-index-name"          : atspair
                ,"index-decimals"           : index-decimals
                ,"royalty-promile"          : 0.0
                ,"syphon"                   : 1.0
                ;;
                ,"peak-hibernate-promile"   : 120.0
                ,"hibernate-decay"          : 0.008
                ;;
                ,"parameter-lock"           : false
                ,"unlocks"                  : 0
                ;;
                ,"reward-tokens"            : [(UDC_ComposePrimaryRewardToken reward-token rt-nfr)]
                ;;
                ;;Cold Recovery
                ,"c-rbt"                    : reward-bearing-token
                ,"c-nfr"                    : rbt-nfr
                ,"c-positions"              : -1
                ,"c-limits"                 : [0.0]
                ,"c-array"                  : [[0.0]]
                ,"c-fr"                     : true
                ,"c-duration"               : (ref-U|ATS::UCv_MakeSoftIntervals 300 6)
                ,"c-elite-mode"             : false
                ;;
                ;;Hot Recovery
                ,"h-rbt"                    : BAR
                ,"h-fr"                     : true
                ,"h-promile"                : 100.0
                ,"h-decay"                  : 1
                ;;
                ;;Direct Recovery
                ,"d-promile"                : 0.0
                ;;
                ;;Toggle Recoveries
                ,"cold-recovery"            : false
                ,"hot-recovery"             : false
                ,"direct-recovery"          : false                
                }
            )
            (ref-DPTF::XBv_DeployAccount reward-token account)
            (ref-DPTF::XBv_DeployAccount reward-bearing-token account)
            (ref-DPTF::XBv_DeployAccount reward-token ats-sc)
            (ref-DPTF::XBv_DeployAccount reward-bearing-token ats-sc)
            id
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>ROTATE_OWNERSHIP
    (defun XI_ChangeOwnership (atspair:string new-owner:string)
        (require-capability (ATS|S>ROTATE_OWNERSHIP atspair new-owner))
        (update ATS|Pairs atspair
            {"owner-konto" : new-owner}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>CONTROL
    (defun XI_Control (atspair:string can-change-owner:bool syphoning:bool hibernate:bool)
        (require-capability (ATS|S>CONTROL atspair hibernate))
        (update ATS|Pairs atspair
            {"can-change-owner" : can-change-owner
            ,"syphoning"        : syphoning
            ,"hibernate"        : hibernate}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>ROYALTY
    (defun XI_UpdateRoyalty (atspair:string royalty:decimal)
        (require-capability (ATS|S>ROYALTY atspair royalty))
        (update ATS|Pairs atspair
            {"royalty-promile" : royalty}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>SYPHON
    (defun XI_UpdateSyphon (atspair:string syphon:decimal)
        (require-capability (ATS|S>SYPHON atspair syphon))
        (update ATS|Pairs atspair
            {"syphon" : syphon}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>SET-HIBERNATION-FEES
    (defun XI_SetHibernationFees (atspair:string peak:decimal decay:decimal)
        (require-capability (ATS|S>SET-HIBERNATION-FEES atspair peak decay))
        (update ATS|Pairs atspair
            {"peak-hibernate-promile"   : peak
            ,"hibernate-decay"          : decay}
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_ToggleParameterLock:[decimal] (atspair:string toggle:bool)
        (require-capability (SECURE))
        (update ATS|Pairs atspair
            { "parameter-lock" : toggle}
        )
        (if toggle
            [0.0 0.0]
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::UC_FeeUnlockPrice)
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IncrementParameterUnlocks (atspair:string)
        (require-capability (SECURE))
        (with-read ATS|Pairs atspair
            { "unlocks" := u }
            (update ATS|Pairs atspair
                {"unlocks" : (+ u 1)}
            )
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: ATS|C>ADD-REWARD-TOKEN
    (defun XI_AddSecondary (atspair:string reward-token:string rt-nfr:bool)
        (require-capability (ATS|C>ADD-REWARD-TOKEN atspair reward-token))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (with-read ATS|Pairs atspair
                { "reward-tokens" := rt }
                (update ATS|Pairs atspair
                    {"reward-tokens" : (ref-U|LST::UC_AppL rt (UDC_ComposePrimaryRewardToken reward-token rt-nfr))}
                )
            )
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: ATS|C>CONTROL-COLD-FEES
    (defun XI_ControlColdFees (atspair:string c-nfr:bool c-fr:bool)
        (require-capability (ATS|C>CONTROL-COLD-FEES atspair))
        (update ATS|Pairs atspair
            {"c-nfr"    : c-nfr
            ,"c-fr"     : c-fr}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>SET_COLD_FEES
    (defun XI_SetColdFee (atspair:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        (require-capability (ATS|C>SET_COLD_FEES atspair fee-positions fee-thresholds fee-array))
        (update ATS|Pairs atspair
            {"c-positions"  : fee-positions
            ,"c-limits"     : fee-thresholds
            ,"c-array"      : fee-array}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>SET_COLD-DURATION
    (defun XI_SetCRD (atspair:string soft-or-hard:bool base:integer growth:integer)
        (require-capability (ATS|C>SET_COLD-DURATION atspair soft-or-hard base growth))
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (if soft-or-hard
                (update ATS|Pairs atspair
                    { "c-duration" : (ref-U|ATS::UCv_MakeSoftIntervals base growth)}
                )
                (update ATS|Pairs atspair
                    { "c-duration" : (ref-U|ATS::UCv_MakeHardIntervals base growth)}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>TOGGLE_ELITE
    (defun XI_ToggleElite (atspair:string toggle:bool)
        (require-capability (ATS|C>TOGGLE_ELITE atspair toggle))
        (update ATS|Pairs atspair
            { "c-elite-mode" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>TOGGLE_UPGRADE
    (defun XI_ToggleUpgrade (atspair:string toggle:bool)
        (require-capability (ATS|C>TOGGLE_UPGRADE atspair toggle))
        (update ATS|Pairs atspair
            { "can-upgrade" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>SWITCH-COLD-RECOVERY
    (defun XI_SwitchColdRecovery (atspair:string toggle:bool)
        (require-capability (ATS|S>SWITCH-COLD-RECOVERY atspair toggle))
        (update ATS|Pairs atspair
            { "cold-recovery" : toggle}
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: ATS|C>ADD-HOT-RBT
    (defun XI_AddHotRBT (atspair:string hot-rbt:string)
        (require-capability (ATS|C>ADD-HOT-RBT atspair hot-rbt))
        (update ATS|Pairs atspair
            {"h-rbt" : hot-rbt}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>CONTROL-HOT-FEE
    (defun XI_ControlHotFee (atspair:string h-fr:bool)
        (require-capability (ATS|C>CONTROL-HOT-FEE atspair))
        (update ATS|Pairs atspair
            {"h-fr"    : h-fr}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|C>SET_HOT_FEES
    (defun XI_SetHotFees (atspair:string promile:decimal decay:integer)
        (require-capability (ATS|C>SET_HOT_FEES atspair promile decay))
        (update ATS|Pairs atspair
            {"h-promile"    : promile
            ,"h-decay"      : decay}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>SWITCH-HOT-RECOVERY
    (defun XI_SwitchHotRecovery (atspair:string toggle:bool)
        (require-capability (ATS|S>SWITCH-HOT-RECOVERY atspair toggle))
        (update ATS|Pairs atspair
            { "hot-recovery" : toggle}
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: ATS|C>SET_DIRECT_FEE
    (defun XI_SetDirectFee (atspair:string promile:decimal)
        (require-capability (ATS|C>SET_DIRECT_FEE atspair promile))
        (update ATS|Pairs atspair
            {"d-promile"    : promile}
        )
    )
    ;;Protection: Class 3 — Custom: ATS|S>SWITCH-DIRECT-RECOVERY
    (defun XI_SwitchDirectRecovery (atspair:string toggle:bool)
        (require-capability (ATS|S>SWITCH-DIRECT-RECOVERY atspair toggle))
        (update ATS|Pairs atspair
            { "direct-recovery" : toggle}
        )
    )
    ;;
    ;;
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_RemoveSecondary (atspair:string reward-token:string)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (rtp:integer (URCv_RewardTokenPosition atspair reward-token))
            )
            (with-read ATS|Pairs atspair
                { "reward-tokens" := rt }
                (update ATS|Pairs atspair
                    {"reward-tokens" :
                        (ref-U|LST::UC_RemoveItem  rt (at rtp rt))
                    }
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateRUR (atspair:string reward-token:string rur:integer direction:bool amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (rtp:integer (URCv_RewardTokenPosition atspair reward-token))
                (nfr:bool (at rtp (UR_RewardTokenNFR atspair)))
                (resident:decimal (at rtp (UR_RewardTokenRUR atspair 1)))
                (unbonding:decimal (at rtp (UR_RewardTokenRUR atspair 2)))
                (royalty:decimal (at rtp (UR_RewardTokenRUR atspair 3)))
                ;;
                (rur-amount:decimal
                    (cond
                        ((= rur 1) (if direction (+ resident amount) (- resident amount)))
                        ((= rur 2) (if direction (+ unbonding amount) (- unbonding amount)))
                        ((= rur 3) (if direction (+ royalty amount) (- royalty amount)))
                        0.0
                    )
                )
                (new-rt-obj:object{AutostakeV3.ATS|RewardTokenSchemaV2}
                    (cond
                        ((= rur 1) (UDC_RT reward-token nfr rur-amount unbonding royalty))
                        ((= rur 2) (UDC_RT reward-token nfr resident rur-amount royalty))
                        ((= rur 3) (UDC_RT reward-token nfr resident unbonding rur-amount))
                        (UDC_RT reward-token nfr 0.0 0.0 0.0)
                    )
                )
            )
            (with-read ATS|Pairs atspair
                { "reward-tokens" := rt }
                (update ATS|Pairs atspair
                    { "reward-tokens" : (ref-U|LST::UC_ReplaceItem rt (at rtp rt) new-rt-obj)}
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_SpawnAutostakeAccount (atspair:string account:string)
        (P|UEV_IMC)
        (let
            (
                (zero:object{UtilityAtsV3.Awo} (UDC_MakeZeroUnstakeObject atspair))
                (n:object{UtilityAtsV3.Awo} (UDC_MakeNegativeUnstakeObject atspair))
            )
            (with-default-read ATS|Ledger (UC_AtspairAccount atspair account)
                (UDCx_Balance [zero] n n n n n n n atspair account)
                {"P0"       := p0
                ,"P1"       := p1
                ,"P2"       := p2
                ,"P3"       := p3
                ,"P4"       := p4
                ,"P5"       := p5
                ,"P6"       := p6
                ,"P7"       := p7
                ,"id"       := i
                ,"account"  := a}
                (write ATS|Ledger (UC_AtspairAccount atspair account)
                    (UDCx_Balance p0 p1 p2 p3 p4 p5 p6 p7 i a)
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_ReshapeUnstakeAccount (atspair:string account:string rp:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            (with-read ATS|Ledger (UC_AtspairAccount atspair account)
                {"P0" := p0, "P1" := p1, "P2" := p2, "P3" := p3, "P4" := p4, "P5" := p5, "P6" := p6, "P7" := p7, "id" := id, "account" := acc}
                (update ATS|Ledger (UC_AtspairAccount atspair account)
                    (UDCx_Balance
                        (ref-U|ATS::UC_MultiReshapeUnstakeObject p0 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p1 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p2 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p3 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p4 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p5 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p6 rp)
                        (ref-U|ATS::UC_ReshapeUnstakeObject p7 rp)
                        id
                        acc
                    )
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP0 (atspair:string account:string obj:[object{UtilityAtsV3.Awo}])
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P0" : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP1 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P1"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP2 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P2"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP3 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P3"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP4 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P4"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP5 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P5"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP6 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P6"  : obj}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpP7 (atspair:string account:string obj:object{UtilityAtsV3.Awo})
        (P|UEV_IMC)
        (update ATS|Ledger (UC_AtspairAccount atspair account)
            { "P7"  : obj}
        )
    )
    ;;{5.7}  User [A/C]
    (defun AU_UnstakeAccounts (keyz:[string])
        @doc "Get <keyz> with <(UR_KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_UnstakeAccount) keyz)
        )
    )
    (defun AU_UnstakeAccount (ky:string)
        (require-capability (SECURE))
        (update ATS|Ledger ky
            {"id"       : (drop -163 ky)
            ,"account"  : (take -162 ky)}
        )
    )
    (defun AU_AutostakePairs (ids:[string])
        @doc "Get <ids> with <(UR_P-KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_AutostakePair) ids)
        )
    )
    (defun AU_AutostakePair (id:string)
        (require-capability (SECURE))
        (update ATS|Pairs id
            {"id"       : id}
        )
    )
    (defun UEV_ExecutorIsOwnerKonto (executor:string entity-id:string)
        @doc "BINDS <executor> to <entity-id>'s owner. Ownership is proven INDIRECTLY by the \
            \ branding capability; this supplies the other half -- that the account the caller \
            \ NAMED is that owner. (patron/executor canon 2.2, indirect route named.)"
        (enforce (= executor (UR_OwnerKonto entity-id)) "Executor is not the Entity Owner")
    )    (defun UEV_ExecutorIsHotRbtOwner (executor:string hot-rbt:string)
        @doc "BINDS <executor> to the owner of the ATS pair that issued <hot-rbt>. \
            \ \
            \ A hot-RBT does not name its pool directly -- the pool is read back through DPOF \
            \ (<UR_RewardBearingToken>), which is exactly what ATS|C>REPURPOSE-HOT-RBT does \
            \ before its <CAP_Owner atspair>. That capability gates WHICH CALLER may act; the \
            \ <ATS|GOV> it then composes supplies the MODULE authority, needed because the \
            \ hot-RBT's DPOF owner-konto is ATS|SC_NAME and only ATS's own code can prove that. \
            \ Two different jobs, and only the first one is about the executor. \
            \ This supplies the binding half: that the account the caller NAMED is that owner."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (enforce
                (= executor (UR_OwnerKonto (ref-DPOF::UR_RewardBearingToken hot-rbt)))
                "Executor is not the ATS-Pair Owner"
            )
        )
    )

    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <entity-id>'s pending branding. <executor> is bound to the entity OWNER; \
            \ ownership itself is proven by ATS|C>UPDATE-BRD. The binding is what keeps the \
            \ parameter from being a name nobody reads."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor entity-id)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (with-capability (ATS|C>UPDATE-BRD entity-id)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (URCi_UpdatePendingBranding entity-id)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor entity-id)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
            )
            ;;Perform the branding upgrade (side effect); bill the STOA via the URCi (== XE_UpgradeBranding's price)
            (with-capability (ATS|C>UPGRADE-BRD entity-id)
                (ref-BRD::XE_UpgradeBranding entity-id executor months)
            )
            (ref-IGNIS::XB_CollectStoaWithTrigger patron (URCi_UpgradeBranding months) false)
        )
    )
    ;;Hot RBT Management
    (defun HOT-RBT|C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (P|UEV_IMC)
        (let
            (
                (ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)
            )
            (with-capability (ATS|C>HOT-RBT-UPDATE-BRD entity-id)
                (ref-B|DPOF::C_UpdatePendingBranding patron executor entity-id logo description website social)
            )
        )
    )
    (defun HOT-RBT|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)
            )
            (with-capability (ATS|C>HOT-RBT-UPGRADE-BRD entity-id)
                (ref-B|DPOF::C_UpgradeBranding patron executor entity-id months)
            )
        )
    )
    (defun HOT-RBT|C_Repurpose:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string hot-rbt:string nonce:integer)
        @doc "Fix (audit finding #22L test-coverage sweep): UR_NonceMetaData was called \
            \ with zero arguments where it requires (id nonce) - an unconditional crash, \
            \ never caught because this function had zero test coverage before now. \
            \ Fetches the ORIGINAL nonce's own metadata, so the replacement mint carries \
            \ forward the same mint-time (and any other metadata-derived math stays \
            \ correct) rather than fabricating fresh metadata for a seized position."
        (P|UEV_IMC)
        (UEV_ExecutorIsHotRbtOwner executor hot-rbt)
        (with-capability (ATS|C>REPURPOSE-HOT-RBT hot-rbt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    ;;
                    (nonce-holder:string (ref-DPOF::UR_NonceHolder hot-rbt nonce))
                    (nonce-supply:decimal (ref-DPOF::UR_NonceSupply hot-rbt nonce))
                    (nonce-meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData hot-rbt nonce))
                    (nonces-used:integer (ref-DPOF::UR_NoncesUsed hot-rbt))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [
                        ;;1]Freeze <nonce> owner
                        (ref-DPOF::C_ToggleFreezeAccount patron (ref-DPOF::UR_Konto hot-rbt) nonce-holder hot-rbt true)
                        ;;2]Wipe <nonce> on owner
                        (ref-DPOF::C_WipeClean patron (ref-DPOF::UR_Konto hot-rbt) nonce-holder hot-rbt [nonce])
                        ;;3]Unfreeze <nonce> owner
                        (ref-DPOF::C_ToggleFreezeAccount patron (ref-DPOF::UR_Konto hot-rbt) nonce-holder hot-rbt false)
                        ;;4]Mint new DPOF on ATS|SC_NAME
                        (ref-DPOF::C_Mint patron ATS|SC_NAME hot-rbt nonce-supply nonce-meta-data-chain)
                        ;;5]Transfer it to <executee>
                        (ref-DPOF::C_Transfer patron ATS|SC_NAME executee hot-rbt [(+ nonces-used 1)] true)
                    ] 
                    []
                )
            )
        )
    )
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string
            executor:string
            atspair:[string]
            index-decimals:[integer]
            reward-token:[string]
            rt-nfr:[bool]
            reward-bearing-token:[string]
            rbt-nfr:[bool]
        )
        (P|UEV_IMC)
        (with-capability (ATS|C>ISSUE executor atspair index-decimals reward-token rt-nfr reward-bearing-token rbt-nfr)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (l1:integer (length atspair))
                    (gas-costs:decimal (URCi_IssueGas l1))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (stoa-costs:decimal (URCi_IssueStoa l1))
                    (ats-ids:[string]
                        (XI_FoldedIssue executor atspair index-decimals reward-token rt-nfr reward-bearing-token rbt-nfr)
                    )
                )
                (ref-IGNIS::XE_CollectStoa patron stoa-costs)
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs ATS|SC_NAME trigger ats-ids)
                
            )
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string atspair:string)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|S>ROTATE_OWNERSHIP atspair executee)
            (XI_ChangeOwnership atspair executee)
            (URCi_RotateOwnership atspair)
        )
    )
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string can-change-owner:bool syphoning:bool hibernate:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|S>CONTROL atspair hibernate)
            (XI_Control atspair can-change-owner syphoning hibernate)
            (URCi_Control atspair)
        )
    )
    (defun C_UpdateRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string royalty:decimal)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|S>ROYALTY atspair royalty)
            (XI_UpdateRoyalty atspair royalty)
            (URCi_UpdateRoyalty atspair)
        )
    )
    (defun C_UpdateSyphon:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string syphon:decimal)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|S>SYPHON atspair syphon)
            (XI_UpdateSyphon atspair syphon)
            (URCi_UpdateSyphon atspair)
        )
    )
    ;;
    (defun C_SetHibernationFees:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string peak:decimal decay:decimal)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|S>SET-HIBERNATION-FEES atspair peak decay)
            (XI_SetHibernationFees atspair peak decay)
            (URCi_SetHibernationFees atspair)
        )
    )
    ;;
    (defun C_ToggleParameterLock:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|C>TOGGLE-PARAMETER-LOCK atspair toggle)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (toggle-costs:[decimal] (XI_ToggleParameterLock atspair toggle))
                    (stoa-costs:decimal (at 1 toggle-costs))
                    ;;URCi computed HERE — reads unlocks BEFORE XI_IncrementParameterUnlocks below mutates it
                    (cumulator:object{IgnisCollectorV3.OutputCumulator} (URCi_ToggleParameterLock atspair toggle))
                )
                (if (> stoa-costs 0.0)
                    (do
                        (XI_IncrementParameterUnlocks atspair)
                        (ref-IGNIS::XE_CollectStoa patron stoa-costs)
                    )
                    true
                )
                cumulator
            )
        )
    )
    (defun C_AddSecondary:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string reward-token:string rt-nfr:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_AddSecondary" "ats-secondary"))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (ATS|C>ADD-REWARD-TOKEN atspair reward-token)
                (ref-DPTF::XB_DeployAccountWNE ATS|SC_NAME reward-token)
                (ref-DPTF::XE_UpdateRewardToken atspair reward-token true)
                (XI_AddSecondary atspair reward-token rt-nfr)
                (URCi_AddSecondary)
            )
        )
    )
    ;;Cold Recovery Management
    (defun C_ControlColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator} 
        (patron:string executor:string atspair:string c-nfr:bool c-fr:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|C>CONTROL-COLD-FEES atspair)
            (XI_ControlColdFees atspair c-nfr c-fr)
            (URCi_ControlColdRecoveryFees atspair)
        )
    )
    (defun C_SetColdRecoveryFees:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (gas-costs:decimal (* (ref-IGNIS::UC_IgnisLeg "tier-biggest") 20.0))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (ATS|C>SET_COLD_FEES atspair fee-positions fee-thresholds fee-array)
                (XI_SetColdFee atspair fee-positions fee-thresholds fee-array)
                (URCi_SetColdRecoveryFees)
            )
        )
    )
    (defun C_SetColdRecoveryDuration:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string soft-or-hard:bool base:integer growth:integer)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|C>SET_COLD-DURATION atspair soft-or-hard base growth)
            (XI_SetCRD atspair soft-or-hard base growth)
            (URCi_SetColdRecoveryDuration atspair)
        )
    )
    (defun C_ToggleElite:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|C>TOGGLE_ELITE atspair toggle)
            (XI_ToggleElite atspair toggle)
            (URCi_ToggleElite atspair)
        )
    )
    (defun C_ToggleUpgrade:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string toggle:bool)
        @doc "Fix (audit finding #21L / L3): sets can-upgrade, which was previously \
            \ permanently true with no setter. Gates C_Control (can-change-owner/ \
            \ syphoning/hibernate) - false blocks C_Control entirely until true again."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|C>TOGGLE_UPGRADE atspair toggle)
            (XI_ToggleUpgrade atspair toggle)
            (URCi_ToggleUpgrade atspair)
        )
    )
    (defun C_SwitchColdRecovery:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|S>SWITCH-COLD-RECOVERY atspair toggle)
            (XI_SwitchColdRecovery atspair toggle)
            (URCi_SwitchColdRecovery atspair)
        )
    )
    ;;Hot Recovery Management
    ;;Must be modified to either add a 0 supply Orto Fungible or Issue One
    (defun C_AddHotRBT:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string hot-rbt:string)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|C>ADD-HOT-RBT atspair hot-rbt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    ;;
                    (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_AddHotRBT" "ats-secondary"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (hot-rbt-owner:string (ref-DPOF::UR_Konto hot-rbt))
                    ;;
                    (ico0:object{IgnisCollectorV3.OutputCumulator}
                        (URCi_AddSecondary)
                    )
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        ;;Change Ownership to ATS|SC_NAME if it is not
                        (if (!= hot-rbt-owner ATS|SC_NAME)
                            (ref-DPOF::C_RotateOwnership patron (ref-DPOF::UR_Konto hot-rbt) ATS|SC_NAME hot-rbt)
                            EOC
                        )
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        ;;Lock Properties   <cu>    <cco>   <casr>  <ctocr> <cf>    <cw>    <cp>    <sg> to
                        ;;                  <false> <false> <false> <false> <true>  <true>  <false> <false>
                        (ref-DPOF::C_Control patron (ref-DPOF::UR_Konto hot-rbt) hot-rbt false false false false true true false false)
                    )
                )
                (ref-DPOF::XB_DeployAccountWNE ATS|SC_NAME hot-rbt)
                (ref-DPOF::XE_UpdateRewardBearingToken atspair hot-rbt)
                (XI_AddHotRBT atspair hot-rbt)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1 ico2] [])  
            ) 
        )
    )
    (defun C_ControlHotRecoveryFee:object{IgnisCollectorV3.OutputCumulator} 
        (patron:string executor:string atspair:string h-fr:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|C>CONTROL-HOT-FEE atspair)
            (XI_ControlHotFee atspair h-fr)
            (URCi_ControlHotRecoveryFee atspair)
        )
    )
    (defun C_SetHotRecoveryFees:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string promile:decimal decay:integer)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|C>SET_HOT_FEES atspair promile decay)
            (XI_SetHotFees atspair promile decay)
            (URCi_SetHotRecoveryFees atspair)
        )
    )
    (defun C_SwitchHotRecovery:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|S>SWITCH-HOT-RECOVERY atspair toggle)
            (XI_SwitchHotRecovery atspair toggle)
            (URCi_SwitchHotRecovery atspair)
        )
    )
    ;;Direct Recovery Management
    (defun C_SetDirectRecoveryFee:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string promile:decimal)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|C>SET_DIRECT_FEE atspair promile)
            (XI_SetDirectFee atspair promile)
            (URCi_SetDirectRecoveryFee atspair)
        )
    )
    (defun C_SwitchDirectRecovery:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string atspair:string toggle:bool)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor atspair)
        (with-capability (ATS|S>SWITCH-DIRECT-RECOVERY atspair toggle)
            (XI_SwitchDirectRecovery atspair toggle)
            (URCi_SwitchDirectRecovery atspair)
        )
    )

)

;; --- tables for 08_ATS.pact (4 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table ATS|Pairs)
;; (create-table ATS|Ledger)


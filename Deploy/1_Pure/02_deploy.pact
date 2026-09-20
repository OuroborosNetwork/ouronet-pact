;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 2 of 20
;; This is STEP 2 of 21 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-1 must have run first, including the init steps between deploys.
;; 2 module(s), 289,772 gas measured in the REPL gas model, 236,854 bytes
;;
;; Modules in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/00_DPMF.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/06_DPOF.pact
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/00_DPMF.pact ====================
;;<=============================================================================================>
;;  DEPRECATED — HISTORICAL ONLY. SUPERSEDED BY DPOF (06_DPOF.pact).
;;<=============================================================================================>
;;  DPMF is the original MetaFungible module. Live metadata-rich fungible behaviour is DPOF
;;  (OrtoFungible); the rename separated the active path from legacy meta-fungible semantics.
;;  Owner ruling 2026-09-15: KEEP AS IS, as dead material, with commentary only. Nothing below
;;  this banner has been restructured.
;;
;;  MEASURED STATE (2026-09-15) — this module is INERT, not merely unused:
;;
;;    * `create-table` is called ZERO times against FIVE `deftable` declarations. Every other
;;      module in the tree creates its tables at the end of the file. So DPMF is deployed with
;;      NO STORAGE, and every storage-backed function in it errors on contact. Pinned by
;;      REPL/modules/CONFORMANCE.repl <<CONF-06>>, which asserts the exact failure
;;      `Table ouronet-ns.DPMF_P|MT not found`.
;;    * ZERO inbound callers: `ref-DPMF::` appears nowhere in 1_SOVEREIGN/ or 2_CITIZEN/, and no
;;      module names the `DemiourgosPactMetaFungible*` interface. The Talos mentions of "DPMF"
;;      are @doc prose only.
;;    * It carries 13 DEAD MODULE-REFERENCE CALLS (`_audit_modref_calls.py`): eleven
;;      `UDC_<tier>Cumulator` refs that no longer exist on IGNIS, plus
;;      `ref-DALOS::STOA|C_CollectWT` and `ref-DALOS::STOA|C_Collect` — members that live on
;;      IGNIS, not DALOS. `OuronetDalosV2` declares no `STOA|*` members at all. They would abort
;;      if reached; they cannot be reached.
;;    * 95,601 bytes — about 64% of a ~150k deploy slot, in a system whose deploy-size cap
;;      dictates module ordering.
;;
;;  DO NOT "FIX" ANY OF THE ABOVE IN PLACE. Creating the tables without wiring the callers would
;;  turn an inert module into a live one with dead calls inside it; <<CONF-06>> goes red on
;;  exactly that half-migration, by design.
;;<=============================================================================================>
;;
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v6   ·   dev: v7   ;; bumped by the StoicSyntax refactor — deploy v7 then set net: v7
(interface DemiourgosPactMetaFungibleV7
    @doc "Exposes most of the Functions of the DPMF Module. \
    \ The ATS Module contains 3 more DPTF Functions that couldnt be brought here logisticaly \
    \ UR(Utility-Read), URC(Utility-Read-Compute), UEV(Utility-Enforce-Validate) and \
    \ UDC(Utility-Data-Composition) are NOT sorted alphabetically \
    \ \
    \ V2 switches to IgnisCumulatorV2 Architecture repairing the collection of Ignis for Smart Ouronet Accounts \
    \ Removes the 2 Branding Functions from this Interface, since they are in their own interface. \
    \ \
    \ V3 adds 2 Functions related to single Elite Account Update. \
    \ \
    \ V4 Removes <patron> input variable where it is not needed"

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
    ;;
    (defschema DPMF|Schema
        nonce:integer
        balance:decimal
        meta-data:[object]
    )
    (defschema DPMF|Nonce-Balance
        nonce:integer
        balance:decimal
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
    (defun UDC_Compose:object{DPMF|Schema} (nonce:integer balance:decimal meta-data:[object]))
    (defun UDC_Nonce-Balance:[object{DPMF|Nonce-Balance}] (nonce-lst:[integer] balance-lst:[decimal]))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    (defun UR_P-KEYS:[string] ())
    (defun UR_KEYS:[string] ())
    ;;
    (defun UR_Konto:string (id:string))
    (defun UR_Name:string (id:string))
    (defun UR_Ticker:string (id:string))
    (defun UR_Decimals:integer (id:string))
    (defun UR_CanChangeOwner:bool (id:string))
    (defun UR_CanUpgrade:bool (id:string))
    (defun UR_CanAddSpecialRole:bool (id:string))
    (defun UR_CanFreeze:bool (id:string))
    (defun UR_CanWipe:bool (id:string))
    (defun UR_CanPause:bool (id:string))
    (defun UR_Paused:bool (id:string))
    (defun UR_Supply:decimal (id:string))
    (defun UR_TransferRoleAmount:integer (id:string))
    (defun UR_Vesting:string (id:string))
    (defun UR_Sleeping:string (id:string))
    (defun UR_Roles:[string] (id:string rp:integer))
    (defun UR_CanTransferNFTCreateRole:bool (id:string))
    (defun UR_CreateRoleAccount:string (id:string))
    (defun UR_NoncesUsed:integer (id:string))
    (defun UR_RewardBearingToken:string (id:string))
    (defun UR_AccountSupply:decimal (id:string account:string))
    (defun UR_AccountRoleBurn:bool (id:string account:string))
    (defun UR_AccountRoleCreate:bool (id:string account:string))
    (defun UR_AccountRoleNFTAQ:bool (id:string account:string))
    (defun UR_AccountRoleTransfer:bool (id:string account:string))
    (defun UR_AccountFrozenState:bool (id:string account:string))
    ;;
    (defun UR_AccountUnit:[object{DPMF|Schema}] (id:string account:string))
    (defun UR_AccountNonces:[integer] (id:string account:string))
    (defun UR_AccountBalances:[decimal] (id:string account:string))
    (defun UR_AccountMetaDatas:[[object]] (id:string account:string))
        ;;
    (defun UR_AccountNonceBalance:decimal (id:string nonce:integer account:string))
    (defun UR_AccountNonceMetaData:[object] (id:string nonce:integer account:string))
        ;;
    (defun UR_AccountNoncesBalances:[decimal] (id:string nonces:[integer] account:string))
    (defun UR_AccountNoncesMetaDatas:[[object]] (id:string nonces:[integer] account:string))
    ;;
    (defun URC_IzRBT:bool (reward-bearing-token:string))
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string))
    (defun URC_EliteAurynzSupply (account:string))
    (defun URC_AccountExist:bool (id:string account:string))
    (defun URC_HasVesting:bool (id:string))
    (defun URC_HasSleeping:bool (id:string))
    (defun URCv_Parent:string (dpmf:string))
    (defun URC_IzIdEA:bool (id:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_ParentOwnership (dpmf:string))
    (defun UEV_NoncesToAccount (id:string account:string nonces:[integer]))
    (defun UEV_id (id:string))
    (defun UEV_CheckID:bool (id:string))
    (defun UEV_Amount (id:string amount:decimal))
    (defun UEV_CheckAmount:bool (id:string amount:decimal))
    (defun UEV_UpdateRewardBearingToken (id:string))
    (defun UEV_CanChangeOwnerON (id:string))
    (defun UEV_CanUpgradeON (id:string))
    (defun UEV_CanAddSpecialRoleON (id:string))
    (defun UEV_CanFreezeON (id:string))
    (defun UEV_CanWipeON (id:string))
    (defun UEV_CanPauseON (id:string))
    (defun UEV_PauseState (id:string state:bool))
    (defun UEV_AccountBurnState (id:string account:string state:bool))
    (defun UEV_AccountTransferState (id:string account:string state:bool))
    (defun UEV_AccountFreezeState (id:string account:string state:bool))
    (defun UEV_CanTransferNFTCreateRoleON (id:string))
    (defun UEV_AccountAddQuantityState (id:string account:string state:bool))
    (defun UEV_AccountCreateState (id:string account:string state:bool))
    (defun UEV_Vesting (id:string existance:bool))
    (defun UEV_Sleeping (id:string existance:bool))
    ;;
    ;;
    (defun CAP_Owner (id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    (defun XB_DeployAccountWNE (id:string account:string))
    (defun XB_IssueFree:object{IgnisCollectorV3.OutputCumulator} (account:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool] can-transfer-nft-create-role:[bool] iz-special:[bool]))
    (defun XB_UpdateEliteSingle (id:string account:string))
    (defun XB_UpdateElite (id:string sender:string receiver:string))
    (defun XB_WriteRoles (id:string account:string rp:integer d:bool))
    ;;
    (defun XE_MoveCreateRole (id:string receiver:string))
    (defun XE_ToggleAddQuantityRole (id:string account:string toggle:bool))
    (defun XE_ToggleBurnRole (id:string account:string toggle:bool))
    (defun XE_UpdateRewardBearingToken (atspair:string id:string))
    (defun XE_UpdateSpecialMetaFungible:object{IgnisCollectorV3.OutputCumulator} (main-dptf:string secondary-dpmf:string vesting-or-sleeping:bool))
    ;;{5.7}  User [A/C]
    ;;
    (defun C_AddQuantity:object{IgnisCollectorV3.OutputCumulator} (id:string nonce:integer account:string amount:decimal))
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string nonce:integer account:string amount:decimal))
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator} (id:string cco:bool cu:bool casr:bool cf:bool cw:bool cp:bool ctncr:bool))
    (defun C_Create:object{IgnisCollectorV3.OutputCumulator} (id:string account:string meta-data:[object]))
    (defun C_DeployAccount (id:string account:string))
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool] can-transfer-nft-create-role:[bool]))
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string account:string amount:decimal meta-data:[object]))
    (defun C_MultiBatchTransfer:object{IgnisCollectorV3.OutputCumulator} (id:string nonces:[integer] sender:string receiver:string method:bool))
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string new-owner:string))
    (defun C_SingleBatchTransfer:object{IgnisCollectorV3.OutputCumulator} (id:string nonce:integer sender:string receiver:string method:bool))
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string toggle:bool))
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator} (id:string nonce:integer sender:string receiver:string transfer-amount:decimal method:bool))
    (defun C_Wipe:object{IgnisCollectorV3.OutputCumulator} (id:string atbw:string))
    (defun C_WipePartial:object{IgnisCollectorV3.OutputCumulator} (id:string atbw:string nonces:[integer]))

)
;;
(module DPMF GOV
    @doc "DPMF — the legacy MetaFungible token core, implementing \
        \ DemiourgosPactMetaFungibleV7. Owns a properties table (ownership, \
        \ name/ticker/decimals, control flags, supply, nonces-used, vesting/sleeping links), \
        \ a per-account balance table of nonce units, and a role table. Client ops cover \
        \ issue, mint, add-quantity, burn, single/multi batch transfer, pause, freeze, \
        \ roles, wipe and ownership rotation. Superseded by DPOF (OrtoFungible) for live \
        \ use; retained for history and migration."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsagePrimaryV2)
    (implements DemiourgosPactMetaFungibleV7)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPMF                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPMF_ADMIN)))
    (defcap GOV|DPMF_ADMIN ()                           (enforce-guard GOV|MD_DPMF))
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
    (defcap P|DPMF|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPMF|CALLER))
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
        (with-capability (GOV|DPMF_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|DPMF_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)}
                    )
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
                (mg:guard (create-capability-guard (P|DPMF|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst DPMF|NEUTRAL
        {"nonce": 0
        ,"balance": 0.0
        ,"meta-data": [{}] }
    )
    (defconst DPMF|NEGATIVE
        {"nonce": -1
        ,"balance": -1.0
        ,"meta-data": [{}] }
    )
    ;;{3.2}  schemas
    ;;
    (defschema DPMF|PropertiesSchema
        owner-konto:string
        name:string
        ticker:string
        decimals:integer
        can-change-owner:bool
        can-upgrade:bool
        can-add-special-role:bool
        can-freeze:bool
        can-wipe:bool
        can-pause:bool
        is-paused:bool
        can-transfer-nft-create-role:bool
        supply:decimal
        create-role-account:string
        role-transfer-amount:integer
        nonces-used:integer
        reward-bearing-token:string
        vesting-link:string
        sleeping-link:string
    )
    (defschema DPMF|BalanceSchema
        @doc "Key = <DPMF id> + BAR + <account>"
        exist:bool
        unit:[object{DemiourgosPactMetaFungibleV7.DPMF|Schema}]
        role-nft-add-quantity:bool
        role-nft-burn:bool
        role-nft-create:bool
        role-transfer:bool
        frozen:bool
    )
    (defschema DPMF|RoleSchema
        r-nft-burn:[string]
        r-nft-create:[string]
        r-nft-add-quantity:[string]
        r-transfer:[string]
        a-frozen:[string]
    )
    ;;{3.3}  tables
    (deftable DPMF|PropertiesTable:{DPMF|PropertiesSchema})
    (deftable DPMF|BalanceTable:{DPMF|BalanceSchema})
    (deftable DPMF|RoleTable:{DPMF|RoleSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap DPMF|S>CTRL (id:string)
        @event
        (CAP_Owner id )
        (UEV_CanUpgradeON id)
    )
    (defcap DPMF|S>X_FRZ-ACC (id:string account:string frozen:bool)
        (CAP_Owner id)
        (UEV_CanFreezeON id)
        (UEV_AccountFreezeState id account (not frozen))
    )
    (defcap DPMF|S>RT_OWN (id:string new-owner:string)
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
    (defcap DPMF|S>TG_BURN-R (id:string account:string toggle:bool)
        @event
        (if toggle
            (UEV_CanAddSpecialRoleON id)
            true
        )
        (CAP_Owner id)
        (UEV_AccountBurnState id account (not toggle))
    )
    (defcap DPMF|S>TG_PAUSE (id:string pause:bool)
        @event
        (if pause
            (UEV_CanPauseON id)
            true
        )
        (CAP_Owner id)
        (UEV_PauseState id (not pause))
    )
    (defcap DPMF|S>MULTI-BATCH-TRANSFER (id:string nonces:[integer] sender:string)
        @event
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (account-nonces:[integer] (UR_AccountNonces id sender))
                (contains-all:bool (ref-U|INT::UEV_ContainsAll nonces account-nonces))
            )
            (enforce contains-all "Invalid Nonce List for DPMF Multi Batch Transfer")
        )
    )
    (defcap DPMF|S>X_TG_TRANSFER-R (id:string account:string toggle:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouroboros:string (ref-DALOS::GOV|OUROBOROS|SC_NAME))
                (dalos:string (ref-DALOS::GOV|DALOS|SC_NAME))
            )
            (enforce (!= account ouroboros) (format "{} Account is immune to transfer roles" [ouroboros]))
            (enforce (!= account dalos) (format "{} Account is immune to transfer roles" [dalos]))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
            (CAP_Owner id)
            (UEV_AccountTransferState id account (not toggle))
        )
    )
    (defcap DPMF|S>MOVE_CREATE-R (id:string receiver:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_SenderWithReceiver (UR_CreateRoleAccount id) receiver)
            (CAP_Owner id)
            (UEV_CanTransferNFTCreateRoleON id)
            (UEV_AccountCreateState id (UR_CreateRoleAccount id) true)
            (UEV_AccountCreateState id receiver false)
        )

    )
    (defcap DPMF|S>TG_ADD-QTY-R (id:string account:string toggle:bool)
        @event
        (CAP_Owner id)
        (UEV_AccountAddQuantityState id account (not toggle))
        (if toggle
            (UEV_CanAddSpecialRoleON id)
            true
        )
    )
    ;;{C3}  Composed
    (defcap DPMF|C>UPDATE-BRD (dpmf:string)
        @event
        (UEV_ParentOwnership dpmf)
        (compose-capability (P|DPMF|CALLER))
    )
    (defcap DPMF|C>UPGRADE-BRD (dpmf:string)
        @event
        (UEV_ParentOwnership dpmf)
        (compose-capability (P|DPMF|CALLER))
    )
    (defcap BASIS|C>X_WRITE-ROLES (id:string account:string rp:integer)
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-U|INT::UEV_PositionalVariable rp 5 "Invalid Role Position")
            (ref-DALOS::UEV_EnforceAccountExists account)
            (UEV_id id)
            (compose-capability (SECURE))
        )
    )
    (defcap DPMF|C>BURN (id:string client:string amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership client)
            (UEV_Amount id amount)
            (UEV_AccountBurnState id client true)
            (compose-capability (SECURE))
        )
    )
    (defcap DPMF|C>FRZ-ACC (id:string account:string frozen:bool)
        @event
        (compose-capability (DPMF|S>X_FRZ-ACC id account frozen))
        (compose-capability (BASIS|C>X_WRITE-ROLES id account 5))
    )
    (defcap DPMF|C>ISSUE (account:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool] can-transfer-nft-create-role:[bool])
        @event
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (l1:integer (length name))
                (l2:integer (length ticker))
                (l3:integer (length decimals))
                (l4:integer (length can-change-owner))
                (l5:integer (length can-upgrade))
                (l6:integer (length can-add-special-role))
                (l7:integer (length can-freeze))
                (l8:integer (length can-wipe))
                (l9:integer (length can-pause))
                (l0:integer (length can-transfer-nft-create-role))
                (lengths:[integer] [l1 l2 l3 l4 l5 l6 l7 l8 l9 l0])
            )
            (ref-U|INT::UEV_UniformList lengths)
            (ref-U|LST::UEV_IzUnique name)
            (ref-U|LST::UEV_IzUnique ticker)
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap DPMF|C>TG_TRANSFER-R (id:string account:string toggle:bool)
        @event
        (compose-capability (DPMF|S>X_TG_TRANSFER-R id account toggle))
        (compose-capability (BASIS|C>X_WRITE-ROLES id account 4))
        (compose-capability (SECURE))
    )
    (defcap DPMF|C>TOTAL-WIPE (id:string account-to-be-wiped:string)
        @event
        (compose-capability (DPMF|X>WIPE id account-to-be-wiped))
    )
    (defcap DPMF|C>PARTIAL-WIPE (id:string account-to-be-wiped:string nonces:[integer])
        @event
        (UEV_NoncesToAccount id account-to-be-wiped nonces)
        (compose-capability (DPMF|X>WIPE id account-to-be-wiped))

    )
    (defcap DPMF|X>WIPE (id:string account-to-be-wiped:string)
        (UEV_CanWipeON id)
        (UEV_AccountFreezeState id account-to-be-wiped true)
        (compose-capability (SECURE))
    )
    (defcap DPMF|C>ADD-QTY (id:string client:string amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership client)
            (UEV_Amount id amount)
            (UEV_AccountAddQuantityState id client true)
            (compose-capability (SECURE))
        )
    )
    (defcap DPMF|C>CREATE (id:string client:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership client)
            (UEV_AccountCreateState id client true)
            (compose-capability (SECURE))
        )
    )
    (defcap DPMF|C>MINT (id:string client:string amount:decimal)
        @event
        (compose-capability (DPMF|C>CREATE id client))
        (compose-capability (DPMF|C>ADD-QTY id client amount))
    )
    (defcap DPMF|C>TRANSFER (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouroboros:string (ref-DALOS::GOV|OUROBOROS|SC_NAME))
                (dalos:string (ref-DALOS::GOV|DALOS|SC_NAME))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership sender)
            (if (and method (ref-DALOS::UR_AccountType receiver))
                (ref-DALOS::CAP_EnforceAccountOwnership receiver)
                true
            )
            (UEV_Amount id transfer-amount)
            (ref-DALOS::UEV_EnforceTransferability sender receiver method)
            (UEV_PauseState id false)
            (UEV_AccountFreezeState id sender false)
            (UEV_AccountFreezeState id receiver false)
            (if
                (and
                    (> (UR_TransferRoleAmount id) 0)
                    (not (or (= sender ouroboros)(= sender dalos)))
                )
                (let
                    (
                        (s:bool (UR_AccountRoleTransfer id sender))
                        (r:bool (UR_AccountRoleTransfer id receiver))
                    )
                    (enforce-one
                        (format "Neither the sender {} nor the receiver {} have an active transfer role" [sender receiver])
                        [
                            (enforce (= s true) (format "Transfer-Role doesnt check for sender {}" [sender]))
                            (enforce (= r true) (format "Transfer-Role doesnt check for sender {}" [sender]))
                        ]
                    )
                )
                (format "No transfer restrictions exist when transfering {} from {} to {}" [id sender receiver])
            )
            (compose-capability (SECURE))
        )
    )
    (defcap DPMF|C>UPDATE-SPECIAL (main-dptf:string secondary-dpmf:string vesting-or-sleeping:bool)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (main-special-id:string
                    (if vesting-or-sleeping
                        (ref-DPTF::UR_Vesting main-dptf)
                        (ref-DPTF::UR_Sleeping main-dptf)
                    )
                )
                (secondary-special-id:string
                    (if vesting-or-sleeping
                        (UR_Vesting secondary-dpmf)
                        (UR_Sleeping secondary-dpmf)
                    )
                )
                (iz-secondary-rbt:bool (URC_IzRBT secondary-dpmf))
                (main-dptf-first-character:string (take 1 main-dptf))
                (main-dptf-second-character:string (drop 1 (take 2 main-dptf)))
            )
            (ref-DPTF::CAP_Owner main-dptf)
            (CAP_Owner secondary-dpmf)
            (enforce
                (and (= main-special-id BAR) (= secondary-special-id BAR) )
                "Special Meta Fungible Links (vesting or sleeping) are immutable !"
            )
            (enforce
                (not iz-secondary-rbt)
                "Special Meta Fungible cannot be a Hot-RBT"
            )
            (if (= main-dptf-second-character BAR)
                (if vesting-or-sleeping
                    (enforce
                        (not (contains main-dptf-first-character ["R" "F" "S" "W" "P"]))
                        (format "When setting a Vesting Link, the main DPTF {} cannot be a Special DPTF" )
                    )
                    (enforce
                        (not (contains main-dptf-first-character ["R" "F"]))
                        (format "When setting a Sleeping Link, the main DPTF {} cannot be a Reserved or Frozen Token" )
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
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    (defun UDC_Compose:object{DemiourgosPactMetaFungibleV7.DPMF|Schema} (nonce:integer balance:decimal meta-data:[object])
        @doc "Composes a DPMF Object"
        {"nonce" : nonce, "balance": balance, "meta-data" : meta-data}
    )
    (defun UDC_Nonce-Balance:[object{DemiourgosPactMetaFungibleV7.DPMF|Nonce-Balance}] (nonce-lst:[integer] balance-lst:[decimal])
        @doc "Composes a Nonce-Balance Object, needed for Wiping functionality"
        (let
            (
                (nonce-length:integer (length nonce-lst))
                (balance-length:integer (length balance-lst))
            )
            (enforce (= nonce-length balance-length) "Nonce and Balance Lists are not of equal length")
            (zip (lambda (x:integer y:decimal) { "nonce": x, "balance": y }) nonce-lst balance-lst)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_P-KEYS:[string] ()
        (keys DPMF|PropertiesTable)
    )
    (defun UR_KEYS:[string] ()
        (keys DPMF|BalanceTable)
    )
    ;;
    (defun UR_Konto:string (id:string)
        (at "owner-konto" (read DPMF|PropertiesTable id ["owner-konto"]))
    )
    (defun UR_Name:string (id:string)
        (at "name" (read DPMF|PropertiesTable id ["name"]))
    )
    (defun UR_Ticker:string (id:string)
        (at "ticker" (read DPMF|PropertiesTable id ["ticker"]))
    )
    (defun UR_Decimals:integer (id:string)
        (at "decimals" (read DPMF|PropertiesTable id ["decimals"]))
    )
    (defun UR_CanChangeOwner:bool (id:string)
        (at "can-change-owner" (read DPMF|PropertiesTable id ["can-change-owner"]))
    )
    (defun UR_CanUpgrade:bool (id:string)
        (at "can-upgrade" (read DPMF|PropertiesTable id ["can-upgrade"]))
    )
    (defun UR_CanAddSpecialRole:bool (id:string)
        (at "can-add-special-role" (read DPMF|PropertiesTable id ["can-add-special-role"]))
    )
    (defun UR_CanFreeze:bool (id:string)
        (at "can-freeze" (read DPMF|PropertiesTable id ["can-freeze"]))
    )
    (defun UR_CanWipe:bool (id:string)
        (at "can-wipe" (read DPMF|PropertiesTable id ["can-wipe"]))
    )
    (defun UR_CanPause:bool (id:string)
        (at "can-pause" (read DPMF|PropertiesTable id ["can-pause"]))
    )
    (defun UR_Paused:bool (id:string)
        (at "is-paused" (read DPMF|PropertiesTable id ["is-paused"]))
    )
    (defun UR_Supply:decimal (id:string)
        (at "supply" (read DPMF|PropertiesTable id ["supply"]))
    )
    (defun UR_TransferRoleAmount:integer (id:string)
        (at "role-transfer-amount" (read DPMF|PropertiesTable id ["role-transfer-amount"]))
    )
    (defun UR_Vesting:string (id:string)
        (at "vesting-link" (read DPMF|PropertiesTable id ["vesting-link"]))
    )
    (defun UR_Sleeping:string (id:string)
        (at "sleeping-link" (read DPMF|PropertiesTable id ["sleeping-link"]))
    )
    (defun UR_Roles:[string] (id:string rp:integer)
        (if (= rp 1)
            (with-default-read DPMF|RoleTable id
                { "r-nft-burn" : [BAR]}
                { "r-nft-burn" := rb }
                rb
            )
            (if (= rp 2)
                (with-default-read DPMF|RoleTable id
                    { "r-nft-create" : [BAR]}
                    { "r-nft-create" := rnc }
                    rnc
                )
                (if (= rp 3)
                    (with-default-read DPMF|RoleTable id
                        { "r-nft-add-quantity" : [BAR]}
                        { "r-nft-add-quantity" := rnaq }
                        rnaq
                    )
                    (if (= rp 4)
                        (with-default-read DPMF|RoleTable id
                            { "r-transfer" : [BAR]}
                            { "r-transfer" := rt }
                            rt
                        )
                        (with-default-read DPMF|RoleTable id
                            { "a-frozen" : [BAR]}
                            { "a-frozen" := af }
                            af
                        )
                    )
                )
            )
        )
    )
    (defun UR_CanTransferNFTCreateRole:bool (id:string)
        (at "can-transfer-nft-create-role" (read DPMF|PropertiesTable id ["can-transfer-nft-create-role"]))
    )
    (defun UR_CreateRoleAccount:string (id:string)
        (at "create-role-account" (read DPMF|PropertiesTable id ["create-role-account"]))
    )
    (defun UR_NoncesUsed:integer (id:string)
        (at "nonces-used" (read DPMF|PropertiesTable id ["nonces-used"]))
    )
    (defun UR_RewardBearingToken:string (id:string)
        (at "reward-bearing-token" (read DPMF|PropertiesTable id ["reward-bearing-token"]))
    )
    (defun UR_AccountSupply:decimal (id:string account:string)
        (fold (+) 0.0 (UR_AccountBalances id account))
    )
    (defun UR_AccountRoleBurn:bool (id:string account:string)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "role-nft-burn" : false}
            { "role-nft-burn" := rb }
            rb
        )
    )
    (defun UR_AccountRoleCreate:bool (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "role-nft-create" : false}
            { "role-nft-create" := rnc }
            rnc
        )
    )
    (defun UR_AccountRoleNFTAQ:bool (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "role-nft-add-quantity" : false}
            { "role-nft-add-quantity" := rnaq }
            rnaq
        )
    )
    (defun UR_AccountRoleTransfer:bool (id:string account:string)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "role-transfer" : false }
            { "role-transfer" := rt }
            rt
        )
    )
    (defun UR_AccountFrozenState:bool (id:string account:string)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "frozen" : false}
            { "frozen" := fr }
            fr
        )
    )
    ;;
    (defun UR_AccountUnit:[object{DemiourgosPactMetaFungibleV7.DPMF|Schema}] (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "unit" : [DPMF|NEGATIVE]}
            { "unit" := u }
            u
        )
    )
    (defun UR_AccountNonces:[integer] (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            {"unit" : [DPMF|NEUTRAL]}
            {"unit" := read-unit}
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[integer] item:object{DemiourgosPactMetaFungibleV7.DPMF|Schema})
                        (if (> (at "nonce" item) 0)
                                (ref-U|LST::UC_AppL acc (at "nonce" item))
                                acc
                        )
                    )
                    []
                    read-unit
                )
            )
        )
    )
    (defun UR_AccountBalances:[decimal] (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            {"unit" : [DPMF|NEUTRAL]}
            {"unit" := read-unit}
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[decimal] item:object{DemiourgosPactMetaFungibleV7.DPMF|Schema})
                        (if (> (at "nonce" item) 0)
                                (ref-U|LST::UC_AppL acc (at "balance" item))
                                acc
                        )
                    )
                    []
                    read-unit
                )
            )
        )
    )
    (defun UR_AccountMetaDatas:[[object]] (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "unit" : [DPMF|NEUTRAL] }
            { "unit" := read-unit}
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[[object]] item:object{DemiourgosPactMetaFungibleV7.DPMF|Schema})
                        (if (> (at "nonce" item) 0)
                                (ref-U|LST::UC_AppL acc (at "meta-data" item))
                                acc
                        )
                    )
                    []
                    read-unit
                )
            )
        )
    )
    (defun UR_AccountNonceBalance:decimal (id:string nonce:integer account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            {"unit" : [DPMF|NEUTRAL]}
            {"unit" := read-unit}
            (fold
                (lambda
                    (acc:decimal item:object{DemiourgosPactMetaFungibleV7.DPMF|Schema})
                    (let
                        (
                            (nonce-val:integer (at "nonce" item))
                            (balance-val:decimal (at "balance" item))
                        )
                        (if (= nonce-val nonce)
                            balance-val
                            acc
                        )
                    )
                )
                0.0
                read-unit
            )
        )
    )
    (defun UR_AccountNonceMetaData:[object]
        (id:string nonce:integer account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "unit" : [DPMF|NEUTRAL] }
            { "unit" := read-unit}
            (fold
                (lambda
                    (acc item:object{DemiourgosPactMetaFungibleV7.DPMF|Schema})
                    (let
                        (
                            (nonce-val:integer (at "nonce" item))
                            (meta-data-val (at "meta-data" item))
                        )
                        (if (= nonce-val nonce)
                            meta-data-val
                            acc
                        )
                    )
                )
                []
                read-unit
            )
        )
    )
    (defun UR_AccountNoncesBalances:[decimal] (id:string nonces:[integer] account:string)
        (UEV_id id)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (all-nonce-lst:[integer] (UR_AccountNonces id account))
                (all-balance-lst:[decimal] (UR_AccountBalances id account))
            )
            (UEV_NoncesToAccount id account nonces)
            (fold
                (lambda
                    (acc:[decimal] nonce:integer)
                    (ref-U|LST::UC_AppL acc (at (at 0 (ref-U|LST::UC_Search all-nonce-lst nonce)) all-balance-lst))
                )
                []
                nonces
            )
        )
    )
    (defun UR_AccountNoncesMetaDatas:[[object]] (id:string nonces:[integer] account:string)
        (UEV_id id)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (all-nonce-lst:[integer] (UR_AccountNonces id account))
                (all-metadata-lst:[[object]] (UR_AccountMetaDatas id account))
            )
            (UEV_NoncesToAccount id account nonces)
            (fold
                (lambda
                    (acc:[[object]] nonce:integer)
                    (ref-U|LST::UC_AppL acc (at (at 0 (ref-U|LST::UC_Search all-nonce-lst nonce)) all-metadata-lst))
                )
                []
                nonces
            )
        )
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
    (defun URC_EliteAurynzSupply (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
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
                                (UR_AccountSupply vea account)
                                0.0
                            )
                        )
                        (sea-supply:decimal
                            (if (!= sea BAR)
                                (UR_AccountSupply sea account)
                                0.0
                            )
                        )
                    )
                    (fold (+) 0.0 [ea-supply fea-supply rea-supply vea-supply sea-supply])
                )
                0.0
            )
        )
    )
    (defun URC_AccountExist:bool (id:string account:string)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "exist"   : false }
            { "exist"   := e}
            e
        )
    )
    (defun URC_HasVesting:bool (id:string)
        @doc "Returns a boolean if DPMF has a vesting counterpart"
        (if (= (UR_Vesting id) BAR)
            false
            true
        )
    )
    (defun URC_HasSleeping:bool (id:string)
        @doc "Returns a boolean if DPMF has a sleeping counterpart"
        (if (= (UR_Sleeping id) BAR)
            false
            true
        )
    )
    (defun URCv_Parent:string (dpmf:string)
        @doc "Computes <dpmf> parent"
        (let
            (
                (fourth:string (drop 3 (take 4 dpmf)))
            )
            (enforce (!= fourth BAR) "Sleeping LP Tokens not allowed for this operation")
            (let
                (
                    (first-two:string (take 2 dpmf))
                )
                (if (= first-two "V|")
                    (UR_Vesting dpmf)
                    (if (= first-two "Z|")
                        (UR_Sleeping dpmf)
                        dpmf
                    )
                )
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
            )
            (contains id [ea-id fea rea vea sea])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_ParentOwnership (dpmf:string)
        @doc "Enforces: \
            \ <dpmf> Ownership, if <dpmf> is pure \
            \ <(UR_Vesting dpmf)>, if its a v|dpmf \
            \ <(UR_Sleeping dpmf)>, if its a s|dpmf \
            \ While ensuring a Sleeping LP cant be used for this operation."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (parent:string (URCv_Parent dpmf))
            )
            (if (= parent dpmf)
                (CAP_Owner dpmf)
                (ref-DPTF::CAP_Owner parent)
            )
        )
    )
    (defun UEV_NoncesToAccount (id:string account:string nonces:[integer])
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (all-nonce-lst:[integer] (UR_AccountNonces id account))
                (validate-nonces:bool (ref-U|INT::UEV_ContainsAll nonces all-nonce-lst))
            )
            (enforce validate-nonces (format "Input nonces {} for {} dont all exist on {}" [nonces id account]))
        )
    )
    (defun UEV_id (id:string)
        (with-default-read DPMF|PropertiesTable id
            { "supply" : -1.0 }
            { "supply" := s }
            (enforce
                (>= s 0.0)
                (format "DPMF ID {} does not exist" [id])
            )
        )
    )
    (defun UEV_CheckID:bool (id:string)
        (with-default-read DPMF|PropertiesTable id
            { "supply" : -1.0 }
            { "supply" := s }
            (if (>= s 0.0)
                true
                false
            )
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
    (defun UEV_CheckAmount:bool (id:string amount:decimal)
        (let
            (
                (decimals:integer (UR_Decimals id))
                (decimal-check:bool (if (= (floor amount decimals) amount) true false))
                (positivity-check:bool (if (> amount 0.0) true false))
                (result:bool (and decimal-check positivity-check))
            )
            result
        )
    )
    (defun UEV_UpdateRewardBearingToken (id:string)
        (let
            (
                (rbt:string (UR_RewardBearingToken id))
            )
            (enforce (= rbt BAR) "RBT for a DPMF is immutable")
        )
    )
    (defun UEV_CanChangeOwnerON (id:string)
        (let
            (
                (x:bool (UR_CanChangeOwner id))
            )
            (enforce (= x true) (format "{} ownership cannot be changed" [id]))
        )
    )
    (defun UEV_CanUpgradeON (id:string)
        (let
            (
                (x:bool (UR_CanUpgrade id))
            )
            (enforce (= x true) (format "{} properties cannot be upgraded" [id])
            )
        )
    )
    (defun UEV_CanAddSpecialRoleON (id:string)
        (let
            (
                (x:bool (UR_CanAddSpecialRole id))
            )
            (enforce (= x true) (format "For {} no special roles can be added" [id])
            )
        )
    )
    (defun UEV_CanFreezeON (id:string)
        (let
            (
                (x:bool (UR_CanFreeze id))
            )
            (enforce (= x true) (format "{} cannot be freezed" [id])
            )
        )
    )
    (defun UEV_CanWipeON (id:string)
        (let
            (
                (x:bool (UR_CanWipe id))
            )
            (enforce (= x true) (format "{} cannot be wiped" [id])
            )
        )
    )
    (defun UEV_CanPauseON (id:string)
        (let
            (
                (x:bool (UR_CanPause id))
            )
            (enforce (= x true) (format "{} cannot be paused" [id])
            )
        )
    )
    (defun UEV_PauseState (id:string state:bool)
        (let
            (
                (x:bool (UR_Paused id))
            )
            (if state
                (enforce x (format "{} is already unpaused" [id]))
                (enforce (= x false) (format "{} is already paused" [id]))
            )
        )
    )
    (defun UEV_AccountBurnState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleBurn id account))
            )
            (enforce (= x state) (format "Burn Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountTransferState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleTransfer id account))
            )
            (enforce (= x state) (format "Transfer Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountFreezeState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountFrozenState id account))
            )
            (enforce (= x state) (format "Frozen for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_CanTransferNFTCreateRoleON (id:string)
        (let
            (
                (x:bool (UR_CanTransferNFTCreateRole id))
            )
            (enforce (= x true) (format "DPMF Token {} cannot have its create role transfered" [id])
            )
        )
    )
    (defun UEV_AccountAddQuantityState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleNFTAQ id account))
            )
            (enforce (= x state) (format "Add Quantity Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountCreateState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleCreate id account))
            )
            (enforce (= x state) (format "Create Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_Vesting (id:string existance:bool)
        (let
            (
                (has-vesting:bool (URC_HasVesting id))
            )
            (enforce (= has-vesting existance) (format "Vesting for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun UEV_Sleeping (id:string existance:bool)
        (let
            (
                (has-sleeping:bool (URC_HasSleeping id))
            )
            (enforce (= has-sleeping existance) (format "Sleeping for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun CAP_Owner (id:string)
        @doc "Enforces DPMF Token ID Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_Konto id))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_DeployAccountWNE (id:string account:string)
        (P|UEV_IMC)
        (let
            (
                (exist-account:bool (URC_AccountExist id account))
            )
            (if (not exist-account)
                (C_DeployAccount id account)
                true
            )
        )
    )
    ;;Protection: Class 5 — IMC + Custom: DPMF|C>ISSUE
    (defun XB_IssueFree:object{IgnisCollectorV3.OutputCumulator}
        (
            account:string
            name:[string]
            ticker:[string]
            decimals:[integer]
            can-change-owner:[bool]
            can-upgrade:[bool]
            can-add-special-role:[bool]
            can-freeze:[bool]
            can-wipe:[bool]
            can-pause:[bool]
            can-transfer-nft-create-role:[bool]
            iz-special:[bool]
        )
        (P|UEV_IMC)
        (with-capability (DPMF|C>ISSUE account name ticker decimals can-change-owner can-upgrade can-add-special-role can-freeze can-wipe can-pause can-transfer-nft-create-role)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-BRD:module{BrandingV2} BRD)
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (l1:integer (length name))
                    (gas-costs:decimal (* (dec l1) (ref-DALOS::UR_UsagePrice "ignis|token-issue")))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (folded-lst:[string]
                        (fold
                            (lambda
                                (acc:[string] index:integer)
                                (let
                                    (
                                        (id:string
                                            (XI_Issue
                                                account
                                                (at index name)
                                                (at index ticker)
                                                (at index decimals)
                                                (at index can-change-owner)
                                                (at index can-upgrade)
                                                (at index can-add-special-role)
                                                (at index can-freeze)
                                                (at index can-wipe)
                                                (at index can-pause)
                                                (at index can-transfer-nft-create-role)
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
    ;;Protection: Class 5 — IMC + Custom: P|DPMF|CALLER
    (defun XB_UpdateEliteSingle (id:string account:string)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-elite-auryn:bool (URC_IzIdEA id))
                (a-type:bool (ref-DALOS::UR_AccountType account))
            )
            (if iz-elite-auryn
                (with-capability (P|DPMF|CALLER)
                    (if (not a-type)
                        (ref-DALOS::XE_UpdateElite account (URC_EliteAurynzSupply account))
                        true
                    )
                )
                true
            )
        )
    )
    ;;Protection: Class 5 — IMC + Custom: P|DPMF|CALLER
    (defun XB_UpdateElite (id:string sender:string receiver:string)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-elite-auryn:bool (URC_IzIdEA id))
                (s-type:bool (ref-DALOS::UR_AccountType sender))
                (r-type:bool (ref-DALOS::UR_AccountType receiver))
            )
            (if iz-elite-auryn
                (with-capability (P|DPMF|CALLER)
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
    ;;Protection: Class 5 — IMC + Custom: BASIS|C>X_WRITE-ROLES
    (defun XB_WriteRoles (id:string account:string rp:integer d:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
            )
            (with-capability (BASIS|C>X_WRITE-ROLES id account rp)
                (with-default-read DPMF|RoleTable id
                    {"r-nft-burn"           : [BAR]
                    ,"r-nft-create"         : [BAR]
                    ,"r-nft-add-quantity"   : [BAR]
                    ,"r-transfer"           : [BAR]
                    ,"a-frozen"             : [BAR]}
                    {"r-nft-burn"           := rb
                    ,"r-nft-create"         := rnc
                    ,"r-nft-add-quantity"   := rnaq
                    ,"r-transfer"           := rt
                    ,"a-frozen"             := af}
                    (if (= rp 1)
                        (write DPMF|RoleTable id
                            {"r-nft-burn"           : (ref-U|DALOS::UCv_NewRoleList rb account d)
                            ,"r-nft-create"         : rnc
                            ,"r-nft-add-quantity"   : rnaq
                            ,"r-transfer"           : rt
                            ,"a-frozen"             : af}
                        )
                        (if (= rp 2)
                            (write DPMF|RoleTable id
                                {"r-nft-burn"           : rb
                                ,"r-nft-create"         : (ref-U|DALOS::UCv_NewRoleList rnc account d)
                                ,"r-nft-add-quantity"   : rnaq
                                ,"r-transfer"           : rt
                                ,"a-frozen"             : af}
                            )
                            (if (= rp 3)
                                (write DPMF|RoleTable id
                                    {"r-nft-burn"           : rb
                                    ,"r-nft-create"         : rnc
                                    ,"r-nft-add-quantity"   : (ref-U|DALOS::UCv_NewRoleList rnaq account d)
                                    ,"r-transfer"           : rt
                                    ,"a-frozen"             : af}
                                )
                                (if (= rp 4)
                                    (write DPMF|RoleTable id
                                        {"r-nft-burn"           : rb
                                        ,"r-nft-create"         : rnc
                                        ,"r-nft-add-quantity"   : rnaq
                                        ,"r-transfer"           : (ref-U|DALOS::UCv_NewRoleList rt account d)
                                        ,"a-frozen"             : af}
                                    )
                                    (write DPMF|RoleTable id
                                        {"r-nft-burn"          : rb
                                        ,"r-nft-create"        : rnc
                                        ,"r-nft-add-quantity"  : rnaq
                                        ,"r-transfer"          : rt
                                        ,"a-frozen"            : (ref-U|DALOS::UCv_NewRoleList af account d)}
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
    ;;
    ;;Protection: Class 5 — IMC + Custom: DPMF|S>MOVE_CREATE-R
    (defun XE_MoveCreateRole (id:string receiver:string)
        (P|UEV_IMC)
        (with-capability (DPMF|S>MOVE_CREATE-R id receiver)
            (let
                (
                    (initial-create-role-account:string (UR_CreateRoleAccount id))
                )
                (update DPMF|BalanceTable (concat [id BAR initial-create-role-account])
                    {"role-nft-create" : false}
                )
                (update DPMF|BalanceTable (concat [id BAR receiver])
                    {"role-nft-create" : true}
                )
                (update DPMF|PropertiesTable id
                    {"create-role-account" : receiver}
                )
            )
        )
    )
    ;;Protection: Class 5 — IMC + Custom: DPMF|S>TG_ADD-QTY-R
    (defun XE_ToggleAddQuantityRole (id:string account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (DPMF|S>TG_ADD-QTY-R id account toggle)
            (update DPMF|BalanceTable (concat [id BAR account])
                {"role-nft-add-quantity" : toggle}
            )
        )
    )
    ;;Protection: Class 5 — IMC + Custom: DPMF|S>TG_BURN-R
    (defun XE_ToggleBurnRole (id:string account:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (DPMF|S>TG_BURN-R id account toggle)
            (update DPMF|BalanceTable (concat [id BAR account])
                {"role-nft-burn" : toggle}
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateRewardBearingToken (atspair:string id:string)
        (P|UEV_IMC)
        (UEV_UpdateRewardBearingToken id)
        (update DPMF|PropertiesTable id
            {"reward-bearing-token" : atspair}
        )
    )
    ;;Protection: Class 5 — IMC + Custom: DPMF|C>UPDATE-SPECIAL
    (defun XE_UpdateSpecialMetaFungible:object{IgnisCollectorV3.OutputCumulator}
        (main-dptf:string secondary-dpmf:string vesting-or-sleeping:bool)
        (P|UEV_IMC)
        (with-capability (DPMF|C>UPDATE-SPECIAL main-dptf secondary-dpmf vesting-or-sleeping)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (if vesting-or-sleeping
                    (do
                        (ref-DPTF::XE_UpdateVesting main-dptf secondary-dpmf)
                        (XI_UpdateVesting main-dptf secondary-dpmf)
                    )
                    (do
                        (ref-DPTF::XE_UpdateSleeping main-dptf secondary-dpmf)
                        (XI_UpdateSleeping main-dptf secondary-dpmf)
                    )
                )
                (ref-IGNIS::UDC_BiggestCumulator (ref-DPTF::UR_Konto main-dptf))
            )
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPMF|C>ADD-QTY
    (defun XI_AddQuantity (id:string nonce:integer account:string amount:decimal)
        (require-capability (DPMF|C>ADD-QTY id account amount))
        (with-read DPMF|BalanceTable (concat [id BAR account])
            { "unit" := unit }
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (current-nonce-balance:decimal (UR_AccountNonceBalance id nonce account))
                    (current-nonce-meta-data:[object] (UR_AccountNonceMetaData id nonce account))
                    (updated-balance:decimal (+ current-nonce-balance amount))
                    (meta-fungible-to-be-replaced:object{DemiourgosPactMetaFungibleV7.DPMF|Schema} (UDC_Compose nonce current-nonce-balance current-nonce-meta-data))
                    (updated-meta-fungible:object{DemiourgosPactMetaFungibleV7.DPMF|Schema} (UDC_Compose nonce updated-balance current-nonce-meta-data))
                    (processed-unit:[object{DemiourgosPactMetaFungibleV7.DPMF|Schema}] (ref-U|LST::UC_ReplaceItem unit meta-fungible-to-be-replaced updated-meta-fungible))
                )
                (update DPMF|BalanceTable (concat [id BAR account])
                    {"unit" : processed-unit}
                )
            )
        )
        (XI_UpdateSupply id amount true)
    )
    ;;Protection: Class 3 — Custom: DPMF|C>BURN
    (defun XI_Burn (id:string nonce:integer account:string amount:decimal)
        (require-capability (DPMF|C>BURN id account amount))
        (XI_DebitStandard id nonce account amount)
        (XI_UpdateSupply id amount false)
    )
    ;;Protection: Class 3 — Custom: DPMF|S>RT_OWN
    (defun XI_ChangeOwnership (id:string new-owner:string)
        (require-capability (DPMF|S>RT_OWN id new-owner))
        (update DPMF|PropertiesTable id
            {"owner-konto"                      : new-owner}
        )
    )
    ;;Protection: Class 3 — Custom: DPMF|S>CTRL
    (defun XI_Control
        (
            id:string
            can-change-owner:bool
            can-upgrade:bool
            can-add-special-role:bool
            can-freeze:bool
            can-wipe:bool
            can-pause:bool
            can-transfer-nft-create-role:bool
        )
        (require-capability (DPMF|S>CTRL id))
        (update DPMF|PropertiesTable id
            {"can-change-owner"             : can-change-owner
            ,"can-upgrade"                  : can-upgrade
            ,"can-add-special-role"         : can-add-special-role
            ,"can-freeze"                   : can-freeze
            ,"can-wipe"                     : can-wipe
            ,"can-pause"                    : can-pause
            ,"can-transfer-nft-create-role" : can-transfer-nft-create-role}
        )
    )
    ;;Protection: Class 3 — Custom: DPMF|C>CREATE
    (defun XI_Create:integer (id:string account:string meta-data:[object])
        (require-capability (DPMF|C>CREATE id account))
        (let
            (
                (new-nonce:integer (+ (UR_NoncesUsed id) 1))
                (create-role-account:string (UR_CreateRoleAccount id))
                (role-nft-create-boolean:bool (if (= create-role-account account) true false))
            )
            (with-default-read DPMF|BalanceTable (concat [id BAR account])
                {"exist"                    : true
                ,"unit"                     : [DPMF|NEUTRAL]
                ,"role-nft-add-quantity"    : false
                ,"role-nft-burn"            : false
                ,"role-nft-create"          : role-nft-create-boolean
                ,"role-transfer"            : false
                ,"frozen"                   : false}
                {"exist"                    := e
                ,"unit"                     := u
                ,"role-nft-add-quantity"    := rnaq
                ,"role-nft-burn"            := rb
                ,"role-nft-create"          := rnc
                ,"role-transfer"            := rt
                ,"frozen"                   := f}
                (let
                    (
                        (ref-U|LST:module{StringProcessorV2} U|LST)
                        (new-nonce:integer (+ (UR_NoncesUsed id) 1))
                        (meta-fungible:object{DemiourgosPactMetaFungibleV7.DPMF|Schema} (UDC_Compose new-nonce 0.0 meta-data))
                        (appended-meta-fungible:[object{DemiourgosPactMetaFungibleV7.DPMF|Schema}] (ref-U|LST::UC_AppL u meta-fungible))
                    )
                    (write DPMF|BalanceTable (concat [id BAR account])
                        {"exist"                    : e
                        ,"unit"                     : appended-meta-fungible
                        ,"role-nft-add-quantity"    : rnaq
                        ,"role-nft-burn"            : rb
                        ,"role-nft-create"          : rnc
                        ,"role-transfer"            : rt
                        ,"frozen"                   : f}
                    )
                    (XI_IncrementNonce id)
                    new-nonce
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_Credit (id:string nonce:integer meta-data:[object] account:string amount:decimal)
        (require-capability (SECURE))
        (let
            (
                (create-role-account:string (UR_CreateRoleAccount id))
                (role-nft-create-boolean:bool (if (= create-role-account account) true false))
            )
            (with-default-read DPMF|BalanceTable (concat [id BAR account])
                {"exist"                    : true
                ,"unit"                     : [DPMF|NEGATIVE]
                ,"role-nft-add-quantity"    : false
                ,"role-nft-burn"            : false
                ,"role-nft-create"          : role-nft-create-boolean
                ,"role-transfer"            : false
                ,"frozen"                   : false}
                { "unit"                    := unit
                ,"role-nft-add-quantity"    := rnaq
                ,"role-nft-burn"            := rb
                ,"role-nft-create"          := rnc
                ,"role-transfer"            := rt
                ,"frozen"                   := f}
                (let
                    (
                        (ref-U|LST:module{StringProcessorV2} U|LST)
                        (next-unit:[object] (if (= unit [DPMF|NEGATIVE]) [DPMF|NEUTRAL] unit))
                        (is-new:bool (if (= unit [DPMF|NEGATIVE]) true false))
                        (current-nonce-balance:decimal (UR_AccountNonceBalance id nonce account))
                        (credited-balance:decimal (+ current-nonce-balance amount))
                        (present-meta-fungible:object{DemiourgosPactMetaFungibleV7.DPMF|Schema} (UDC_Compose nonce current-nonce-balance meta-data))
                        (credited-meta-fungible:object{DemiourgosPactMetaFungibleV7.DPMF|Schema} (UDC_Compose nonce credited-balance meta-data))
                        (processed-unit-with-replace:[object{DemiourgosPactMetaFungibleV7.DPMF|Schema}] (ref-U|LST::UC_ReplaceItem next-unit present-meta-fungible credited-meta-fungible))
                        (processed-unit-with-append:[object{DemiourgosPactMetaFungibleV7.DPMF|Schema}] (ref-U|LST::UC_AppL next-unit credited-meta-fungible))
                    )
                    (if (= current-nonce-balance 0.0)
                        (write DPMF|BalanceTable (concat [id BAR account])
                            {"exist"                    : true
                            ,"unit"                     : processed-unit-with-append
                            ,"role-nft-add-quantity"    : (if is-new false rnaq)
                            ,"role-nft-burn"            : (if is-new false rb)
                            ,"role-nft-create"          : (if is-new role-nft-create-boolean rnc)
                            ,"role-transfer"            : (if is-new false rt)
                            ,"frozen"                   : (if is-new false f)}
                        )
                        (write DPMF|BalanceTable (concat [id BAR account])
                            {"exist"                    : true
                            ,"unit"                     : processed-unit-with-replace
                            ,"role-nft-add-quantity"    : (if is-new false rnaq)
                            ,"role-nft-burn"            : (if is-new false rb)
                            ,"role-nft-create"          : (if is-new role-nft-create-boolean rnc)
                            ,"role-transfer"            : (if is-new false rt)
                            ,"frozen"                   : (if is-new false f)}
                        )
                    )
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_DebitAdmin (id:string nonce:integer account:string amount:decimal)
        (require-capability (SECURE))
        (CAP_Owner id)
        (XI_DebitPure id nonce account amount)
    )
    ;;Protection: Class 1 — Innate protection offered by XI_DebitPaired
    (defun XI_DebitMultiple (id:string nonce-lst:[integer] account:string balance-lst:[decimal])
        (let
            (
                (nonce-balance-obj-lst:[object{DemiourgosPactMetaFungibleV7.DPMF|Nonce-Balance}] (UDC_Nonce-Balance nonce-lst balance-lst))
            )
            (map (lambda (x:object{DemiourgosPactMetaFungibleV7.DPMF|Nonce-Balance}) (XI_DebitPaired id account x)) nonce-balance-obj-lst)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XI_DebitAdmin
    (defun XI_DebitPaired (id:string account:string nonce-balance-obj:object{DemiourgosPactMetaFungibleV7.DPMF|Nonce-Balance})
        (let
            (
                (nonce:integer (at "nonce" nonce-balance-obj))
                (balance:decimal (at "balance" nonce-balance-obj))
            )
            (XI_DebitAdmin id nonce account balance)
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_DebitPure (id:string nonce:integer account:string amount:decimal)
        (require-capability (SECURE))
        (with-read DPMF|BalanceTable (concat [id BAR account])
            {"exist"                    := e
            ,"unit"                     := unit
            ,"role-nft-add-quantity"    := rnaq
            ,"role-nft-burn"            := rnb
            ,"role-nft-create"          := rnc
            ,"role-transfer"            := rt
            ,"frozen"                   := f}
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (current-nonce-balance:decimal (UR_AccountNonceBalance id nonce account))
                    (current-nonce-meta-data (UR_AccountNonceMetaData id nonce account))
                    (debited-balance:decimal (- current-nonce-balance amount))
                    (meta-fungible-to-be-replaced:object{DemiourgosPactMetaFungibleV7.DPMF|Schema} (UDC_Compose nonce current-nonce-balance current-nonce-meta-data))
                    (debited-meta-fungible:object{DemiourgosPactMetaFungibleV7.DPMF|Schema} (UDC_Compose nonce debited-balance current-nonce-meta-data))
                    (processed-unit-with-remove:[object{DemiourgosPactMetaFungibleV7.DPMF|Schema}] (ref-U|LST::UC_RemoveItem unit meta-fungible-to-be-replaced))
                    (processed-unit-with-replace:[object{DemiourgosPactMetaFungibleV7.DPMF|Schema}] (ref-U|LST::UC_ReplaceItem unit meta-fungible-to-be-replaced debited-meta-fungible))
                )
                (enforce (>= debited-balance 0.0) "Insufficient Funds for debiting")
                (if (= debited-balance 0.0)
                    (update DPMF|BalanceTable (concat [id BAR account])
                        {"exist"                    : e
                        ,"unit"                     : processed-unit-with-remove
                        ,"role-nft-add-quantity"    : rnaq
                        ,"role-nft-burn"            : rnb
                        ,"role-nft-create"          : rnc
                        ,"role-transfer"            : rt
                        ,"frozen"                   : f}
                    )
                    (update DPMF|BalanceTable (concat [id BAR account])
                        {"exist"                    : e
                        ,"unit"                     : processed-unit-with-replace
                        ,"role-nft-add-quantity"    : rnaq
                        ,"role-nft-burn"            : rnb
                        ,"role-nft-create"          : rnc
                        ,"role-transfer"            : rt
                        ,"frozen"                   : f}
                    )
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_DebitStandard (id:string nonce:integer account:string amount:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (XI_DebitPure id nonce account amount)
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IncrementNonce (id:string)
        (require-capability (SECURE))
        (with-read DPMF|PropertiesTable id
            { "nonces-used" := nu }
            (update DPMF|PropertiesTable id { "nonces-used" : (+ nu 1)})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_Issue:string
        (
            account:string
            name:string
            ticker:string
            decimals:integer
            can-change-owner:bool
            can-upgrade:bool
            can-add-special-role:bool
            can-freeze:bool
            can-wipe:bool
            can-pause:bool
            can-transfer-nft-create-role:bool
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
            (insert DPMF|PropertiesTable id
                {"owner-konto"          : account
                ,"name"                 : name
                ,"ticker"               : ticker
                ,"decimals"             : decimals
                ,"can-change-owner"     : can-change-owner
                ,"can-upgrade"          : can-upgrade
                ,"can-add-special-role" : can-add-special-role
                ,"can-freeze"           : can-freeze
                ,"can-wipe"             : can-wipe
                ,"can-pause"            : can-pause
                ,"is-paused"            : false
                ,"can-transfer-nft-create-role" : can-transfer-nft-create-role
                ,"supply"               : 0.0
                ,"create-role-account"  : account
                ,"role-transfer-amount" : 0
                ,"nonces-used"          : 0
                ,"reward-bearing-token" : BAR
                ,"vesting-link"         : BAR
                ,"sleeping-link"        : BAR}
            )
            (XB_WriteRoles id account 2 true)
            (C_DeployAccount id account)
            id
        )
    )
    ;;Protection: Class 3 — Custom: DPMF|C>MINT
    (defun XI_Mint:integer (id:string account:string amount:decimal meta-data:[object])
        (require-capability (DPMF|C>MINT id account amount))
        (let
            (
                (new-nonce:integer (+ (UR_NoncesUsed id) 1))

            )
            (XI_Create id account meta-data)
            (XI_AddQuantity id new-nonce account amount)
            new-nonce
        )
    )
    ;;Protection: Class 3 — Custom: DPMF|S>X_FRZ-ACC
    (defun XI_ToggleFreezeAccount (id:string account:string toggle:bool)
        (require-capability (DPMF|S>X_FRZ-ACC id account toggle))
        (update DPMF|BalanceTable (concat [id BAR account])
            { "frozen" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPMF|S>TG_PAUSE
    (defun XI_TogglePause (id:string toggle:bool)
        (require-capability (DPMF|S>TG_PAUSE id toggle))
        (update DPMF|PropertiesTable id
            { "is-paused" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPMF|S>X_TG_TRANSFER-R
    (defun XI_ToggleTransferRole (id:string account:string toggle:bool)
        (require-capability (DPMF|S>X_TG_TRANSFER-R id account toggle))
        (update DPMF|BalanceTable (concat [id BAR account])
            {"role-transfer" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPMF|C>TRANSFER
    (defun XI_Transfer (id:string nonce:integer sender:string receiver:string transfer-amount:decimal method:bool)
        (require-capability (DPMF|C>TRANSFER id sender receiver transfer-amount method))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (current-nonce-meta-data (UR_AccountNonceMetaData id nonce sender))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
            )
            (XI_DebitStandard id nonce sender transfer-amount)
            (XI_Credit id nonce current-nonce-meta-data receiver transfer-amount)
            (XB_UpdateElite id sender receiver)
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateRoleTransferAmount (id:string direction:bool)
        (require-capability (SECURE))
        (if (= direction true)
            (with-read DPMF|PropertiesTable id
                { "role-transfer-amount" := rta }
                (update DPMF|PropertiesTable id
                    {"role-transfer-amount" : (+ rta 1)}
                )
            )
            (with-read DPMF|PropertiesTable id
                { "role-transfer-amount" := rta }
                (update DPMF|PropertiesTable id
                    {"role-transfer-amount" : (- rta 1)}
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVesting (dptf:string dpmf:string)
        (require-capability (SECURE))
        (update DPMF|PropertiesTable dpmf
            {"vesting-link" : dptf}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateSleeping (dptf:string dpmf:string)
        (require-capability (SECURE))
        (update DPMF|PropertiesTable dpmf
            {"sleeping-link" : dptf}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateSupply (id:string amount:decimal direction:bool)
        (require-capability (SECURE))
        (UEV_Amount id amount)
        (if (= direction true)
            (with-read DPMF|PropertiesTable id
                { "supply" := s }
                (enforce (>= (+ s amount) 0.0) "DPMF Token Supply cannot be updated to negative values!")
                (update DPMF|PropertiesTable id { "supply" : (+ s amount)})
            )
            (with-read DPMF|PropertiesTable id
                { "supply" := s }
                (enforce (>= (- s amount) 0.0) "DPMF Token Supply cannot be updated to negative values!")
                (update DPMF|PropertiesTable id { "supply" : (- s amount)})
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPMF|C>TOTAL-WIPE
    (defun XI_Wipe (id:string account-to-be-wiped:string)
        (require-capability (DPMF|C>TOTAL-WIPE id account-to-be-wiped))
        (let
            (
                (nonce-lst:[integer] (UR_AccountNonces id account-to-be-wiped))
                (balance-lst:[decimal] (UR_AccountBalances id account-to-be-wiped))
                (sum:decimal (fold (+) 0.0 balance-lst))
            )
            (XI_DebitMultiple id nonce-lst account-to-be-wiped balance-lst)
            (XI_UpdateSupply id sum false)
        )
    )
    ;;Protection: Class 3 — Custom: DPMF|C>PARTIAL-WIPE
    (defun XI_WipePartial (id:string account-to-be-wiped:string nonces:[integer])
        (require-capability (DPMF|C>PARTIAL-WIPE id account-to-be-wiped nonces))
        (let
            (
                (balances:[decimal] (UR_AccountNoncesBalances id nonces account-to-be-wiped))
                (sum:decimal (fold (+) 0.0 balances))
            )
            (XI_DebitMultiple id nonces account-to-be-wiped balances)
            (XI_UpdateSupply id sum false)
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
            )
            (with-capability (DPMF|C>UPDATE-BRD entity-id)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (ref-IGNIS::UDC_BrandingCumulator (UR_Konto entity-id) 1.5)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string entity-id:string months:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-BRD:module{BrandingV2} BRD)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (parent:string (URCv_Parent entity-id))
                (parent-owner:string
                    (if (= parent entity-id)
                        (UR_Konto entity-id)
                        (ref-DPTF::UR_Konto parent)
                    )
                )
                (stoa-payment:decimal
                    (with-capability (DPMF|C>UPGRADE-BRD entity-id)
                        (ref-BRD::XE_UpgradeBranding entity-id parent-owner months)
                    )
                )
            )
            (ref-DALOS::STOA|C_CollectWT patron stoa-payment false)
        )
    )
    ;;
    (defun C_AddQuantity:object{IgnisCollectorV3.OutputCumulator}
        (id:string nonce:integer account:string amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-capability (DPMF|C>ADD-QTY id account amount)
                (XI_AddQuantity id nonce account amount)
                (ref-IGNIS::UDC_SmallCumulator (UR_Konto id))
            )
        )
    )
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator}
        (id:string nonce:integer account:string amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-capability (DPMF|C>BURN id account amount)
                (XI_Burn id nonce account amount)
                (ref-IGNIS::UDC_SmallCumulator (UR_Konto id))
            )
        )
    )
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator}
        (id:string cco:bool cu:bool casr:bool cf:bool cw:bool cp:bool ctncr:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-capability (DPMF|S>CTRL id)
                (XI_Control id cco cu casr cf cw cp ctncr)
                (ref-IGNIS::UDC_MediumCumulator (UR_Konto id))
            )
        )
    )
    (defun C_Create:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string meta-data:[object])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (price:decimal (ref-DALOS::UR_UsagePrice "ignis|medium"))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (new-nonce:integer
                    (with-capability (DPMF|C>CREATE id account)
                        (XI_Create id account meta-data)
                    )
                )
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price (UR_Konto id) trigger [new-nonce])
        )
    )
    (defun C_DeployAccount (id:string account:string)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (create-role-account:string (UR_CreateRoleAccount id))
                (role-nft-create-boolean:bool (if (= create-role-account account) true false))
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (UEV_id id)
            (with-default-read DPMF|BalanceTable (concat [id BAR account])
                {"exist"                               : true
                ,"unit"                                : [DPMF|NEUTRAL]
                ,"role-nft-add-quantity"               : false
                ,"role-nft-burn"                       : false
                ,"role-nft-create"                     : role-nft-create-boolean
                ,"role-transfer"                       : false
                ,"frozen"                              : false}
                {"exist"                               := e
                ,"unit"                                := u
                ,"role-nft-add-quantity"               := rnaq
                ,"role-nft-burn"                       := rb
                ,"role-nft-create"                     := rnc
                ,"role-transfer"                       := rt
                ,"frozen"                              := f }
                (write DPMF|BalanceTable (concat [id BAR account])
                    {"exist"                           : e
                    ,"unit"                            : u
                    ,"role-nft-add-quantity"           : rnaq
                    ,"role-nft-burn"                   : rb
                    ,"role-nft-create"                 : rnc
                    ,"role-transfer"                   : rt
                    ,"frozen"                          : f}
                )
            )
        )
    )
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool] can-transfer-nft-create-role:[bool])
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (l1:integer (length name))
                (mf-cost:decimal (ref-DALOS::UR_UsagePrice "dpmf"))
                (stoa-costs:decimal (* (dec l1) mf-cost))
                (iz-special:[bool] (make-list l1 false))
                (ico:object{IgnisCollectorV3.OutputCumulator}
                    (with-capability (SECURE)
                        (XB_IssueFree executor name ticker decimals can-change-owner can-upgrade can-add-special-role can-freeze can-wipe can-pause can-transfer-nft-create-role iz-special)
                    )
                )
            )
            (ref-DALOS::STOA|C_Collect patron stoa-costs)
            ico
        )
    )
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string amount:decimal meta-data:[object])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (new-nonce:integer
                    (with-capability (DPMF|C>MINT id account amount)
                        (XI_Mint id account amount meta-data)
                    )
                )
                (medium:decimal (ref-DALOS::UR_UsagePrice "ignis|medium"))
                (small:decimal (ref-DALOS::UR_UsagePrice "ignis|small"))
                (price:decimal (+ medium small))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price (UR_Konto id) trigger [new-nonce])
        )
    )
    (defun C_MultiBatchTransfer:object{IgnisCollectorV3.OutputCumulator}
        (id:string nonces:[integer] sender:string receiver:string method:bool)
        (P|UEV_IMC)
        (with-capability (DPMF|S>MULTI-BATCH-TRANSFER id nonces sender)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                        (fold
                            (lambda
                                (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                (ref-U|LST::UC_AppL
                                    acc
                                    (C_SingleBatchTransfer id (at idx nonces) sender receiver method)
                                )
                            )
                            []
                            (enumerate 0 (- (length nonces) 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
            )
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator}
        (id:string new-owner:string)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-capability (DPMF|S>RT_OWN id new-owner)
                (XI_ChangeOwnership id new-owner)
                (ref-IGNIS::UDC_BiggestCumulator (UR_Konto id))
            )
        )
    )
    (defun C_SingleBatchTransfer:object{IgnisCollectorV3.OutputCumulator}
        (id:string nonce:integer sender:string receiver:string method:bool)
        (P|UEV_IMC)
        (C_Transfer id nonce sender receiver (UR_AccountNonceBalance id nonce sender) method)
    )
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string toggle:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-capability (DPMF|C>FRZ-ACC id account toggle)
                (XI_ToggleFreezeAccount id account toggle)
                (XB_WriteRoles id account 5 toggle)
                (ref-IGNIS::UDC_BiggestCumulator (UR_Konto id))
            )
        )
    )
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator}
        (id:string toggle:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-capability (DPMF|S>TG_PAUSE id toggle)
                (XI_TogglePause id toggle)
                (ref-IGNIS::UDC_MediumCumulator (UR_Konto id))
            )
        )
    )
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string toggle:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-capability (DPMF|C>TG_TRANSFER-R id account toggle)
                (XB_DeployAccountWNE id account)
                (XI_ToggleTransferRole id account toggle)
                (XI_UpdateRoleTransferAmount id toggle)
                (XB_WriteRoles id account 4 toggle)
                (ref-IGNIS::UDC_BiggestCumulator (UR_Konto id))
            )
        )
    )
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator}
        (id:string nonce:integer sender:string receiver:string transfer-amount:decimal method:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-capability (DPMF|C>TRANSFER id sender receiver transfer-amount method)
                (XI_Transfer id nonce sender receiver transfer-amount method)
                (ref-IGNIS::UDC_SmallCumulator (UR_Konto id))
            )
        )
    )
    (defun C_Wipe:object{IgnisCollectorV3.OutputCumulator}
        (id:string atbw:string)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-capability (DPMF|C>TOTAL-WIPE id atbw)
                (XI_Wipe id atbw)
                (ref-IGNIS::UDC_BiggestCumulator (UR_Konto id))
            )
        )
    )
    (defun C_WipePartial:object{IgnisCollectorV3.OutputCumulator}
        (id:string atbw:string nonces:[integer])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-capability (DPMF|C>PARTIAL-WIPE id atbw nonces)
                (XI_WipePartial id atbw nonces)
                (ref-IGNIS::UDC_BiggestCumulator (UR_Konto id))
            )
        )
    )

)

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
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string new-owner:string))
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator} (id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool))
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string toggle:bool))
        ;;
    (defun C_DeployAccount (id:string account:string))
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
    (defun C_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
    (defun C_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator} (id:string receiver:string))
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
        ;;
    (defun C_AddQuantity:object{IgnisCollectorV3.OutputCumulator} (id:string account:string nonce:integer amount:decimal))
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string account:string nonce:integer amount:decimal))
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string account:string amount:decimal meta-data-chain:[object]))
        ;;
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string account:string nonce:integer amount:decimal))
    (defun CC_WipeHeavy:object{IgnisCollectorV3.OutputCumulator} (id:string account:string))
    (defun C_WipePure:object{IgnisCollectorV3.OutputCumulator} (id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
    (defun C_WipeClean:object{IgnisCollectorV3.OutputCumulator} (id:string account:string nonces:[integer]))
    (defun Cp_WipeSlice:object{IgnisCollectorV3.OutputCumulator} (id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
        ;;
    (defun C_Transmit:object{IgnisCollectorV3.OutputCumulator} (id:string nonces:[integer] amounts:[decimal] sender:string receiver:string method:bool))
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator} (id:string nonces:[integer] sender:string receiver:string method:bool))
    (defun C_BulkTransfer:object{IgnisCollectorV3.OutputCumulator}
        (id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool)
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
        (with-capability (GOV|DPOF_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)}
                    )
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
                (mg:guard (create-capability-guard (P|DPOF|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
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
    ;;Protection: Class 5 — IMC + Custom: DPOF|C>ISSUE
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
                (C_DeployAccount id account)
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
            (C_DeployAccount id account)
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
    ;;Protection: Class 5 — IMC + Custom: DPOF|C>UPDATE-SPECIAL
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
        (entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (P|UEV_IMC)
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
    (defun C_UpgradeBranding (patron:string entity-id:string months:integer)
        (P|UEV_IMC)
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
                (ref-BRD::XE_UpgradeBranding entity-id parent-owner months)
            )
            (ref-IGNIS::STOA|C_CollectWT patron (URCi_UpgradeBranding months) false)
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
            (ref-IGNIS::STOA|C_Collect patron stoa-costs)
            ico
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator}
        (id:string new-owner:string)
        (P|UEV_IMC)
        (with-capability (DPOF|S>ROTATE-OWNERSHIP id new-owner)
            (XI_ChangeOwnership id new-owner)
            (URCi_RotateOwnership id)
        )
    )
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator}
        (id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool)
        (P|UEV_IMC)
        (with-capability (DPOF|S>CONTROL id)
            (XI_Control id cu cco casr ctocr cf cw cp sg)
            (URCi_Control id)
        )
    )
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator}
        (id:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (DPOF|S>PAUSE id toggle)
            ;;Pause|Unpause <id>
            (XI_TogglePause id toggle)
            ;;Output
            (URCi_TogglePause id)
        )
    )
    ;;
    (defun C_DeployAccount (id:string account:string)
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
        (id:string account:string toggle:bool)
        @doc "Toggle Verum 1"
        (P|UEV_IMC)
        (with-capability (DPOF|C>FREEZE id account toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-one:[string] (UR_Verum1 id))
                    (updated-verum-one:[string] (ref-U|DALOS::UCv_NewRoleList verum-one account toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE account id)
                ;;Update Verum Roles
                (XI_UpdateVerum1 id updated-verum-one)
                ;;Update Account Roles
                (XI_ToggleFreezeAccount id account toggle)
                ;;Output
                (URCi_ToggleFreezeAccount id)
            )
        )
    )
    (defun C_ToggleAddQuantityRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string toggle:bool)
        @doc "Toggle Verum 2"
        (P|UEV_IMC)
        (with-capability (DPOF|C>TOGGLE-ADD-QUANTITY-ROLE id account toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-two:[string] (UR_Verum2 id))
                    (updated-verum-two:[string] (ref-U|DALOS::UCv_NewRoleList verum-two account toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE account id)
                ;;Update Verum Roles
                (XI_UpdateVerum2 id updated-verum-two)
                ;;Update Account Roles
                (XI_ToggleAddQuantityRole id account toggle)
                ;;Output
                (URCi_ToggleAddQuantityRole id)
            )
        )
    )
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string toggle:bool)
        @doc "Toggle Verum 3"
        (P|UEV_IMC)
        (with-capability (DPOF|C>TOGGLE-BURN-ROLE id account toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-three:[string] (UR_Verum3 id))
                    (updated-verum-three:[string] (ref-U|DALOS::UCv_NewRoleList verum-three account toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE account id)
                ;;Update Verum Roles
                (XI_UpdateVerum3 id updated-verum-three)
                ;;Update Account Roles
                (XI_ToggleBurnRole id account toggle)
                ;;Output
                (URCi_ToggleBurnRole id)
            )
        )
    )
    (defun C_MoveCreateRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string receiver:string)
        @doc "Switch Verum 4"
        (P|UEV_IMC)
        (with-capability (DPOF|C>SWITCH-CREATE-ROLE id receiver)
            ;;Deploy WNE
            (XB_DeployAccountWNE receiver id)
            ;;Update Account Roles — MUST run before Verum Roles below: XI_SwitchCreateRole
            ;;reads the CURRENT (pre-write) Verum4 internally to find the account to revoke.
            ;;Running XI_UpdateVerum4 first would overwrite that value to <receiver> before
            ;;XI_SwitchCreateRole ever reads it, so the real previous holder would never be
            ;;revoked (DALOS audit #2C).
            (XI_SwitchCreateRole id receiver)
            ;;Update Verum Roles
            (XI_UpdateVerum4 id receiver)
            ;;Output
            (URCi_MoveCreateRole id)
        )
    )
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string toggle:bool)
        @doc "Toggle Verum 5"
        (P|UEV_IMC)
        (with-capability (DPOF|C>TOGGLE-TRANSFER-ROLE id account toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-five:[string] (UR_Verum5 id))
                    (updated-verum-five:[string] (ref-U|DALOS::UCv_NewRoleList verum-five account toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE account id)
                ;;Update Verum Roles
                (XI_UpdateVerum5 id updated-verum-five)
                ;;Update Account Roles
                (XI_ToggleTransferRole id account toggle)
                ;;Output
                (URCi_ToggleTransferRole id)
            )
        )
        
    )
    ;;
    (defun C_AddQuantity:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string nonce:integer amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (supply:decimal (UR_Supply id))
            )
            (with-capability (DPOF|C>ADD-QTY account id nonce amount)
                ;;Credit <nonce> held on <account> by <amount> 
                (XI_CreditNonces account id [nonce] [amount] [[{}]])
                ;;Update <id> Supply
                (XI_UpdateSupply id (+ supply amount))
                ;;Output
                (URCi_AddQuantity id)
            )
        )
    )
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string nonce:integer amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (supply:decimal (UR_Supply id))
            )
            (with-capability (DPOF|C>BURN account id nonce amount)
                ;;Debit <nonce> held on <account> by <amount>
                (XI_DebitNonces account id [nonce] [amount] false)
                ;;Update <id> Supply
                (XI_UpdateSupply id (- supply amount))
                ;;Output
                (URCi_Burn id)
            )
        )
    )
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string amount:decimal meta-data-chain:[object])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (supply:decimal (UR_Supply id))
                (nonces-used:integer (UR_NoncesUsed id))
            )
            (with-capability (DPOF|C>MINT account id amount meta-data-chain)
                ;;Credit <nonce> held on <account> by <amount>
                (XI_CreditNonces account id [(+ nonces-used 1)] [amount] [meta-data-chain])
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
        (id:string account:string nonce:integer amount:decimal)
        @doc "Wipes a specific DPOF <id> <nonce> on <account> by <amount> \
        \ Amount may be lower or equal to the nonce amount. \
        \ Requires <id> has <segmentation> set to true"
        (P|UEV_IMC)
        (let
            (
                (supply:decimal (UR_Supply id))
            )
            (with-capability (DPOF|C>WIPE-SLIM account id nonce amount)
                ;;Debit <nonce> held on <account> by <amount>
                (XI_DebitNonces account id [nonce] [amount] true)
                ;;Update <id> Supply
                (XI_UpdateSupply id (- supply amount))
                ;;Output 2 IGNIS
                (URCi_WipeSlim id)
            )
        )
    )
    (defun CC_WipeHeavy:object{IgnisCollectorV3.OutputCumulator} (id:string account:string)
        @doc "Wipes all viable <id> Nonces of an DPOF <account> \
            \ \
            \ |Heavy| reffers to the usage of expensive functions like <select> or <keys> \
            \ (that arent meant to be used in transactional context) to get the Account Nonces; \
            \ May fit in a single Transaction for Small Data Sets"
        (P|UEV_IMC)
        (C_WipePure id account (URHC_WipePure account id))
    )
    (defun C_WipePure:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Wipes all <id> Nonces of an DPOF <account>, presented via an <removable-nonces-obj> object \
            \ \
            \ The object must be pre-read (dirty read) \
            \ \
            \ Example to retrieve the <removable-nonces-obj> \
            \ <(URHC_WipePure account id)> ; to get the whole object \
            \ <(UCv_TakePureWipe (URHC_WipePure account id) 165)> ; to get only the first 165 units \
            \ Aproximately xx Individual Wipes fit inside one TX (for NFTs)."
        (P|UEV_IMC)
        (let
            (
                (supply:decimal (UR_Supply id))
                (nonces:[integer] (at "r-nonces" removable-nonces-obj))
                (amounts:[decimal] (at "r-amounts" removable-nonces-obj))
                (sum:decimal (fold (+) 0.0 amounts))
            )
            (with-capability (DPOF|C>WIPE account id nonces)
                ;;Debit <nonces> by <amounts> on <account> for <id>
                (XI_DebitNonces account id nonces amounts true)
                ;;Update <id> Supply
                (XI_UpdateSupply id (- supply sum))
                ;;Output (2 IGNIS per Nonce Wiped)
                (URCi_WipeCumulator id removable-nonces-obj)
            )
        )
    )
    (defun C_WipeClean:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string nonces:[integer])
        @doc "Wipes <id> select <nonces> of a DPOF <account>"
        (P|UEV_IMC)
        (C_WipePure id account
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
        (id:string nonces:[integer] amounts:[decimal] sender:string receiver:string method:bool)
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
        (id:string nonces:[integer] sender:string receiver:string method:bool)
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
        (id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool)
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


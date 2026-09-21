;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 4 of 22
;; This is STEP 4 of 23 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-3 must have run first, including the init steps between deploys.
;; 2 source file(s), 261,798 gas measured in the REPL gas model, 207,661 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/09_TFT.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact
;;
;; TOTAL: 2 interface(s), 2 module(s), 4 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/09_TFT.pact
;;      interface  TrueFungibleTransferV2
;;      module     TFT
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact
;;      interface  AutostakeUsageV2
;;      module     ATSU
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/09_TFT.pact =====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TrueFungibleTransferV2
    @doc "Exposes True Fungible Transfer Functions"

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
    (defschema TransferClass
        type:integer
        iz-it-simple:bool
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
    (defun UDC_GetDispoData:object{UtilityDptfV2.DispoData} (account:string))
    ;;{5.2}  Compute [UC]
    ;;
    ;;  [UC]
    ;;
    (defun UC_ContainsEliteAurynz:bool (id-lst:[string]))
    (defun UC_BulkRemainders:[decimal] (id:string transfer-amount-lst:[decimal]))
    (defun UC_BulkFees:[decimal] (id:string transfer-amount-lst:[decimal]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URC]
    ;;
    (defun URC_MinimumOuro:decimal (account:string))
    (defun URC_VirtualOuro:decimal (account:string))
    (defun URC_ReceiverAmount:decimal (id:string sender:string receiver:string amount:decimal))
    (defun URC_UnityTransferIgnisPrice (transfer-amount:decimal))
        ;;
    (defun URC_TransferClasses:object{TransferClass} (id:string sender:string receiver:string amount:decimal))
    (defun URC_IzSimpleTransfer:bool (id:string sender:string receiver:string amount:decimal))
    (defun URC_TransferClassesForBulk:object{TransferClass} (id:string sender:string transfer-amount-lst:[decimal]))
    (defun URC_IzSimpleTransferForBulk:bool (id:string sender:string transfer-amount-lst:[decimal]))
        ;;
    (defun URC_IzTrueFungibleEliteAuryn:bool (id:string))
    (defun URC_IzTrueFungibleUnity:bool (id:string))
    (defun URC_AreTrueFungiblesEliteAurynz:bool (id:string))
    (defun URCi_SmallTransmuteCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string transmuter:string))
    (defun URCi_LargeTransmuteCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string transmuter:string))
    (defun URCi_Transmute:object{IgnisCollectorV3.OutputCumulator} (id:string transmuter:string))
    (defun URCi_ClearDispo:object{IgnisCollectorV3.OutputCumulator} (account:string))
    (defun URCi_UnityTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (sender:string receiver:string amount:decimal))
        ;;
    (defun URCi_TransferCumulator:object{IgnisCollectorV3.OutputCumulator} (type:integer id:string sender:string receiver:string))
    (defun URCi_Transfer:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string receiver:string transfer-amount:decimal))
    (defun URCi_SmallTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string receiver:string))
    (defun URCi_MediumTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string receiver:string))
    (defun URCi_LargeTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (sender:string receiver:string))
        ;;
    (defun URCi_MultiTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal]))
        ;;
    (defun URCi_MultiBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]]))
    (defun URCi_BulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal]))
    (defun URCi_UnityBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (sender:string receiver-lst:[string] transfer-amount-lst:[decimal]))
    (defun URCi_SimpleBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string size:integer))
    (defun URCi_ComplexBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string size:integer))
    (defun URCi_EliteBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string size:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_MinimumMapperForBulk (id:string transfer-amount-lst:[decimal]))
    (defun UEV_IgnisTransmuteMinimum (id:string amount:decimal))
    (defun UEV_Minimum (id:string amount:decimal))
    (defun UEV_DispoLocker (id:string account:string))
    (defun UEV_MoveRoleCheck (id:string sender:string receiver:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_ClearDispo:object{IgnisCollectorV3.OutputCumulator} (patron:string account:string))
    (defun C_Transmute:object{IgnisCollectorV3.OutputCumulator} (id:string transmuter:string transmute-amount:decimal))
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator} (id:string sender:string receiver:string transfer-amount:decimal method:bool))
    (defun C_MultiTransfer:object{IgnisCollectorV3.OutputCumulator} (id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal] method:bool))
    (defun C_MultiBulkTransfer:object{IgnisCollectorV3.OutputCumulator} (id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]]))

)
;;
(module TFT GOV
    @doc "TFT — the True-Fungible transfer core, the movement layer over DPTF, implementing \
        \ TrueFungibleTransferV2. It computes transfer classes, fees and remainders \
        \ (including Elite-Auryn detection) and exposes client ops C_Transfer, \
        \ C_MultiTransfer, C_MultiBulkTransfer, C_Transmute (mint/burn conversion) and \
        \ C_ClearDispo, handling fee-bearing transfers and multi-token batched sends."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TrueFungibleTransferV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TFT                                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TFT_ADMIN)))
    (defcap GOV|TFT_ADMIN ()                            (enforce-guard GOV|MD_TFT))
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
    (defcap P|TFT|CALLER ()
        true
    )
    (defcap P|ATS|REMOTE-GOV ()
        @doc "Autostake Remote Governor Capability"
        true
    )
    (defcap P|DALOS|REMOTE-GOV ()
        @doc "Dalos Remote Governor Capability"
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|TFT|CALLER))
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
        (with-capability (GOV|TFT_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TFT_ADMIN)
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
        (with-capability (GOV|TFT_ADMIN)
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
        (with-capability (GOV|TFT_ADMIN)
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
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (mg:guard (create-capability-guard (P|TFT|CALLER)))
            )
            (ref-P|DALOS::P|A_Add
                "TFT|RemoteDalosGov"
                (create-capability-guard (P|DALOS|REMOTE-GOV))
            )
            (ref-P|ATS::P|A_Add
                "TFT|RemoteAtsGov"
                (create-capability-guard (P|ATS|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst TF                                        (at 0 ["True-Fungible"]))
    ;;THE GAS-STATION FLOOR. Transmuting the IGNIS DPTF is deliberately IGNIS-FREE
    ;;(URC_IsVirtualGasZeroAbsolutely zeroes the leg when id = gas-id) and its STOA gas is paid by
    ;;the Ouronet gas station. Free + sponsored + NO MINIMUM = a free sponsored transaction for a
    ;;0.001 transmute, repeatable until the station is drained. The 1000 min-move that guards
    ;;TRANSFERS does not apply, because transmute is not a transfer and never calls UEV_Minimum --
    ;;measured 2026-09-20: a 25.0 transmute moved exactly 25.0 against a min-move of 1000.0.
    ;;This floor closes that, and 25 is also what the sponsored-let form charges: same number,
    ;;on purpose.
    (defconst CT_IGNIS_TRANSMUTE_MINIMUM:decimal 25.0)
    (defconst DALOS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|DALOS|SC_NAME)
        )
    )
    (defconst ATS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|ATS|SC_NAME)
        )
    )
    (defconst OUROBOROS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|OUROBOROS|SC_NAME)
        )
    )
    (defconst VST|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|VST|SC_NAME)
        )
    )
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
    ;;1]    Clear Dispo
    (defcap DPTF|C>CLEAR-DISPO (account:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-amount:decimal (ref-DALOS::UR_TF_AccountSupply account true))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (account-type:bool (ref-DALOS::UR_AccountType account))
            )
            (enforce (< ouro-amount 0.0) "Dispo Clear requires Negative OURO")
            (enforce (not account-type) "Standard Dispo can only be cleared on Standard Ouronet Accounts")
            (compose-capability (P|DALOS|REMOTE-GOV))
            (compose-capability (P|ATS|REMOTE-GOV))
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;2]    Transmute
    (defcap DPTF|C>TRANSMUTE (id:string transmuter:string amount:decimal)
        @event
        (compose-capability (DPTF|C>X-TRANSMUTE id transmuter amount))
    )
    (defcap DPTF|C>ELITE-TRANSMUTE (id:string transmuter:string amount:decimal)
        @event
        (UEV_DispoLocker id transmuter)
        (compose-capability (DPTF|C>X-TRANSMUTE id transmuter amount))
    )
    (defcap DPTF|C>X-TRANSMUTE (id:string transmuter:string amount:decimal) 
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            ;;1]Ownership (included in the <XB_DebitTrueFungible>)
            ;;2]Transferability (not needed for transmute)
            ;;3];;3]<id> Pause State and <sender> Frozen State
            (UEV_IgnisTransmuteMinimum id amount)
            (ref-DPTF::UEV_PauseState id false)
            (ref-DPTF::UEV_AccountFreezeState id transmuter false)
            ;;4]Only Standard Ouronet Account can transmute,
            ;;Amount is not subject to <min-move> amount, and transfer-role restrictions --
            ;;EXCEPT for the IGNIS DPTF, which carries its own floor (see
            ;;UEV_IgnisTransmuteMinimum above). That exception exists because an IGNIS transmute
            ;;is BOTH ignis-free and gas-station-sponsored, so without a floor it is a free
            ;;transaction pump.
            (ref-DALOS::UEV_EnforceAccountType transmuter false)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;3]    TRANSFER
    (defcap DPTF|C>CLASS-1-TRANSFER 
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
    )
    (defcap DPTF|C>CLASS-1-TRANSFER-UNITY
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
    )
    (defcap DPTF|C>CLASS-2-TRANSFER
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (UEV_Minimum id transfer-amount)
        (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
    )
    (defcap DPTF|C>CLASS-2-TRANSFER-UNITY
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (UEV_Minimum id transfer-amount)
        (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
    )
    (defcap DPTF|C>CLASS-2-TRANSFER-ELITE
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (UEV_DispoLocker id sender)
        (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
    )
    (defcap DPTF|C>CLASS-3-TRANSFER-ELITE
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (min-move:decimal (ref-DPTF::UR_MinMove id))
            )
            (if (!= min-move 0.0)
                (UEV_Minimum id transfer-amount)
                true
            )
            (UEV_DispoLocker id sender)
            (compose-capability (DPTF|C>X-TRANSFER id sender receiver method))
        )
    )
    ;;
    (defcap DPTF|C>X-TRANSFER
        (id:string sender:string receiver:string method:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            ;;1]Ownership
            (ref-DALOS::CAP_EnforceAccountOwnership sender)
            (if (and method (ref-DALOS::UR_AccountType receiver))
                (ref-DALOS::CAP_EnforceAccountOwnership receiver)
                true
            )
            ;;2]Transferability
            (ref-DALOS::UEV_EnforceTransferability sender receiver method)
            ;;3]<id> Pause State and <sender> <receiver> Frozen State
            (ref-DPTF::UEV_PauseState id false)
            (ref-DPTF::UEV_AccountFreezeState id sender false)
            (ref-DPTF::UEV_AccountFreezeState id receiver false)
            ;;4]Transfer Roles Check
            (UEV_MoveRoleCheck id sender receiver)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;4]    MULTI-TRANSFER
    (defcap DPTF|C>MULTI-TRANSFER
        (id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal] method:bool)
        @event
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (l1:integer (length id-lst))
                (l2:integer (length transfer-amount-lst))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (has-ea:bool (contains ea-id id-lst))
            )
            ;;A]SINGLE VALIDATIONS
            ;;0]General
            (ref-U|LST::UEV_IzUnique id-lst)
            (enforce (= l1 l2) "Invalid Multi Transfer Lists")
            ;;1]Dispo Locker if EA is involved
            (if has-ea
                (UEV_DispoLocker ea-id sender)
                true
            )
            ;;2]Ownership (sender ownership within the DPTF Debit Function)
            (if (and method (ref-DALOS::UR_AccountType receiver))
                (ref-DALOS::CAP_EnforceAccountOwnership receiver)
                true
            )
            ;;3]Transferability
            (ref-DALOS::UEV_EnforceTransferability sender receiver method)
            ;;B]MULTI VALIDATIONS (mapper)
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (id:string (at idx id-lst))
                        )
                        ;;4]<id> Pause State and <sender> <receiver> Frozen State
                        (ref-DPTF::UEV_PauseState id false)
                        (ref-DPTF::UEV_AccountFreezeState id sender false)
                        (ref-DPTF::UEV_AccountFreezeState id receiver false)
                        ;;5]Transfer Role Checker
                        (UEV_MoveRoleCheck id sender receiver)
                    )
                )
                (enumerate 0 (- l2 1))
            )
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;5]    BULK-TRANSFER
    (defcap DPTF|C>CLASS-0-BULK (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal] iz-it-simple:bool)
        @event
        (if (not iz-it-simple)
            (UEV_MinimumMapperForBulk id transfer-amount-lst)
            true
        )
        (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
    )
    (defcap DPTF|C>CLASS-0-BULK-UNITY (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal] iz-it-simple:bool)
        @event
        (if (not iz-it-simple)
            (UEV_MinimumMapperForBulk id transfer-amount-lst)
            true
        )
        (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
    )
    (defcap DPTF|C>CLASS-1-BULK (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        @event
        (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
    )
    (defcap DPTF|C>CLASS-2-BULK (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        @event
        (UEV_MinimumMapperForBulk id transfer-amount-lst)
        (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
    )
    (defcap DPTF|C>CLASS-2-BULK-ELITE (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        @event
        (UEV_DispoLocker id sender)
        (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
    )
    (defcap DPTF|C>CLASS-3-BULK-ELITE (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (min-move:decimal (ref-DPTF::UR_MinMove id))
            )
            (if (!= min-move 0.0)
                (UEV_MinimumMapperForBulk id transfer-amount-lst)
                true
            )
            (UEV_DispoLocker id sender)
            (compose-capability (DPTF|C>X-BULK-TRANSFER id sender receiver-lst transfer-amount-lst))
        )
    )
    ;;
    (defcap DPTF|C>X-BULK-TRANSFER
        (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (l1:integer (length receiver-lst))
                (l2:integer (length transfer-amount-lst))
            )
            ;;A]SINGLE VALIDATIONS
            ;;0]General
            (ref-U|LST::UEV_IzUnique receiver-lst)
            (enforce (= l1 l2) "Invalid Bulk Transfer Lists")
            ;;1]<id> Pause State and <sender> Frozen State
            (ref-DPTF::UEV_PauseState id false)
            (ref-DPTF::UEV_AccountFreezeState id sender false)
            ;;B]MULTI VALIDATIONS (mapper)
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (receiver:string (at idx receiver-lst))
                        )
                        ;;1]<receiver> Frozen State
                        (ref-DPTF::UEV_AccountFreezeState id receiver false)
                        ;;2]Transfer Role Checker
                        (UEV_MoveRoleCheck id sender receiver)
                        ;;3]All Receivers must be Standard Ouronet Accounts
                        (ref-DALOS::UEV_EnforceAccountType receiver false)
                    )
                )
                (enumerate 0 (- l2 1))
            )
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
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    (defun UDC_GetDispoData:object{UtilityDptfV2.DispoData} (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (a-id:string (ref-DALOS::UR_AurynID))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (auryndex:string (at 0 (ref-DPTF::UR_RewardToken ouro-id)))
                (elite-auryndex:string (at 0 (ref-DPTF::UR_RewardToken a-id)))
            )
            {"elite-auryn-amount"   : (ref-DPTF::UR_AccountSupply ea-id account)
            ,"auryndex-value"       : (ref-ATS::URC_Index auryndex)
            ,"elite-auryndex-value" : (ref-ATS::URC_Index elite-auryndex)
            ,"major-tier"           : (ref-DALOS::UR_Elite-Tier-Major account)
            ,"minor-tier"           : (ref-DALOS::UR_Elite-Tier-Minor account)
            ,"ouroboros-precision"  : (ref-DPTF::UR_Decimals ouro-id)}
        )
    )
    (defun UDCx_BulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string size:integer price:decimal)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l-dec:decimal (dec size))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (* l-dec price) sender
                (ref-IGNIS::URC_ZeroGAS id sender ) []
            )
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_ContainsEliteAurynz:bool (id-lst:[string])
        (fold
            (lambda
                (acc:bool idx:integer)
                (or acc (URC_AreTrueFungiblesEliteAurynz (at idx id-lst)))
            )
            false
            (enumerate 0 (- (length id-lst) 1))
        )
    )
    (defun UC_BulkRemainders:[decimal] (id:string transfer-amount-lst:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL acc (at 2 (ref-DPTF::URC_Fee id (at idx transfer-amount-lst))))
                )
                []
                (enumerate 0 (- (length transfer-amount-lst) 1))
            )
        )
    )
    (defun UC_BulkFees:[decimal] (id:string transfer-amount-lst:[decimal])
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (zip (+) acc (ref-DPTF::URC_Fee id (at idx transfer-amount-lst)))
                )
                [0.0 0.0 0.0]
                (enumerate 0 (- (length transfer-amount-lst) 1))
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_MinimumOuro:decimal (account:string)
        @doc "Computes the minimum Negative Ouroboros amount an Account is able to overconsume \
        \ Using the Standard Dispo mechanics"
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData account))
                (max-dispo:decimal (ref-U|DPTF::UC_OuroDispo dispo-data))
                (account-type:bool (ref-DALOS::UR_AccountType account))
            )
            (if account-type
                0.0
                (- 0.0 max-dispo)
            )
        )
    )
    (defun URC_VirtualOuro:decimal (account:string)
        @doc "Computes the Account Virtual Ouro. \
            \ The Virtual Ouro is the maximum Ouro the Account is able to spend"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro:decimal (ref-DPTF::UR_AccountSupply ouro-id account))
                (smart-treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (zero:decimal 
                    (if (= account smart-treasury)
                        (ref-DPTF::URC_TreasuryLowestDispo)
                        (URC_MinimumOuro account)
                    )
                ) 
            )
            (+ (abs zero) ouro)
        )
    )
    ;;
    (defun URC_ReceiverAmount:decimal (id:string sender:string receiver:string amount:decimal)
        @doc "Computes the amount the <receiver> gets when transfering DPTFs"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (tc:integer (at "type" (URC_TransferClasses id sender receiver amount)))
            )
            (if (contains tc [1 2 5])
                amount
                (at 2 (ref-DPTF::URC_Fee id amount))
            )
        )
    )
    (defun URC_UnityTransferIgnisPrice (transfer-amount:decimal)
        @doc "UNITY will only be used with Complex Transfers, as it will have a VTT"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if (<= transfer-amount 10.0) (ref-IGNIS::UC_IgnisLeg "tier-small") 0.0)
        )
    )
    (defun URC_TransferClasses:object{TrueFungibleTransferV2.TransferClass}
        (id:string sender:string receiver:string amount:decimal)
        @doc "Computes the Transfer Class \
        \ Class 1   : [DPTF|C>CLASS-1-TRANSFER]         [1]     Simple (T)\
        \           : [DPTF|C>CLASS-1-TRANSFER-UNITY]   [2]     Free Unity (T) \
        \ Class 2   : [DPTF|C>CLASS-2-TRANSFER]         [3]     Complex (T + F) \
        \           : [DPTF|C>CLASS-2-TRANSFER-UNITY]   [4]     Unity (T + F) \
        \           : [DPTF|C>CLASS-2-TRANSFER-ELITE]   [5]     Free Elite (T + U) \
        \ Class 3   : [DPTF|C>CLASS-3-TRANSFER-ELITE]   [6]     Elite (T + F + U)"
        (let
            (
                (iz-simple-transfer:bool (URC_IzSimpleTransfer id sender receiver amount))
                (are-e:bool (URC_AreTrueFungiblesEliteAurynz id))
                (iz-un:bool (URC_IzTrueFungibleUnity id))
                (output-type:integer
                    (if iz-simple-transfer
                        (if are-e 5 (if iz-un 2 1))
                        (if are-e 6 (if iz-un 4 3))
                    )
                )
            )
            {"type"         : output-type
            ,"iz-it-simple" : iz-simple-transfer}
        )
    )
    (defun URC_IzSimpleTransfer:bool (id:string sender:string receiver:string amount:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (fee-toggle:bool (ref-DPTF::UR_FeeToggle id))
                (fee-promile:decimal (ref-DPTF::UR_FeePromile id))
                (fee-unlocks:integer (ref-DPTF::UR_FeeUnlocks id))
            )
            (cond
                ((not fee-toggle) true)
                ((and (= fee-promile 0.0) (= fee-unlocks 0)) true)
                ((and (= fee-promile -1.0) (< amount 10.0)) true)
                ((ref-DPTF::UR_AccountRoleFeeExemption id sender) true)
                ((ref-DPTF::UR_AccountRoleFeeExemption id receiver) true)
                false
            )
        )
    )
    (defun URC_TransferClassesForBulk:object{TrueFungibleTransferV2.TransferClass}
        (id:string sender:string transfer-amount-lst:[decimal])
        @doc "Computes the Bulk Transfer Class, assuming Elite Auryns will never have VTT \
        \ Class 0   : VTT (Volumetric Transfer Tax) Class \
        \           : [DPTF|C>CLASS-0-BULK]             [1]     (T + vF) Variable Fee \
        \           : [DPTF|C>CLASS-0-BULK-UNITY]       [2]     (T + vF) Variable Fee Unity \
        \ Class 1   : [DPTF|C>CLASS-1-BULK]             [3]     (T) No Fee \
        \ Class 2   : [DPTF|C>CLASS-2-BULK]             [4]     (T + F) With Fee \
        \           : [DPTF|C>CLASS-2-BULK-ELITE]       [5]     (T + U) No Fee + Update Elite \
        \ Class 3   : [DPTF|C>CLASS-3-BULK-ELITE]       [6]     (T + F + U) With Fee + Update"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (iz-simple-transfer-for-bulk:bool 
                    (URC_IzSimpleTransferForBulk id sender transfer-amount-lst)
                )
                (are-e:bool (URC_AreTrueFungiblesEliteAurynz id))
                (fee-promile:decimal (ref-DPTF::UR_FeePromile id))
                (iz-un:bool (URC_IzTrueFungibleUnity id))
                (not-vtt:bool (not (= -1.0 fee-promile)))
                (vtt-type:integer (if iz-un 2 1))
                ;;
                (output-type:integer
                    (if iz-simple-transfer-for-bulk
                        (if are-e 5 (if not-vtt 3 vtt-type))
                        (if are-e 6 (if not-vtt 4 vtt-type))
                    )
                )
            )
            {"type"         : output-type
            ,"iz-it-simple" : iz-simple-transfer-for-bulk}
        )
    )
    (defun URC_IzSimpleTransferForBulk:bool (id:string sender:string transfer-amount-lst:[decimal])
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (fee-toggle:bool (ref-DPTF::UR_FeeToggle id))
                (fee-promile:decimal (ref-DPTF::UR_FeePromile id))
                (fee-unlocks:integer (ref-DPTF::UR_FeeUnlocks id))
            )
            (or 
                (cond
                    ((not fee-toggle) true)
                    ((and (= fee-promile 0.0) (= fee-unlocks 0)) true)
                    ((ref-DPTF::UR_AccountRoleFeeExemption id sender) true)
                    false
                ) 
                (fold
                    (lambda
                        (acc:[bool] amount:decimal)
                        (or acc
                            (and (= fee-promile -1.0) (< amount 10.0))
                        )
                    )
                    false
                    transfer-amount-lst
                )
            )
        )
    )
    ;;
    (defun URC_IzTrueFungibleEliteAuryn:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
            )
            (if (= id ea-id) true false)
        )
    )
    (defun URC_IzTrueFungibleUnity:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (u-id:string (ref-DALOS::UR_UnityID))
            )
            (if (= id u-id) true false)
        )
    )
    (defun URC_AreTrueFungiblesEliteAurynz:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (fea:string (ref-DPTF::UR_Frozen ea-id))
                (rea:string (ref-DPTF::UR_Reservation ea-id))
            )
            (contains id [ea-id fea rea])
        )
    )
    ;;
    (defun URCx_CPF_RT-RBT:[decimal] (id:string native-fee-amount:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (rt-ats-pairs:[string] (ref-DPTF::UR_RewardToken id))
                (rbt-ats-pairs:[string] (ref-DPTF::UR_RewardBearingToken id))
                (length-rt:integer (length rt-ats-pairs))
                (length-rbt:integer (length rbt-ats-pairs))
                (rt-boolean:[bool] (URCx_NFR-Boolean_RT-RBT id rt-ats-pairs true))
                (rbt-boolean:[bool] (URCx_NFR-Boolean_RT-RBT id rbt-ats-pairs false))
                (rt-milestones:integer (length (ref-U|LST::UC_Search rt-boolean true)))
                (rbt-milestones:integer (length (ref-U|LST::UC_Search rbt-boolean true)))
                (milestones:integer (+ rt-milestones rbt-milestones))
            )
            (if (!= milestones 0)
                (let
                    (
                        (truths:[bool] (+ rt-boolean rbt-boolean))
                        (split-with-truths:[decimal] (URCx_BooleanDecimalCombiner id native-fee-amount milestones truths))
                    )
                    (if (!= rt-milestones 0)
                        (let
                            (
                                (credit-sum:decimal
                                    (fold
                                        (lambda
                                            (acc:decimal index:integer)
                                            (if (at index rt-boolean)
                                                (do
                                                    (ref-ATS::XE_UpdateRUR (at index rt-ats-pairs) id 1 true (at index split-with-truths))
                                                    (+ acc (at index split-with-truths))
                                                )
                                                acc
                                            )
                                        )
                                        0.0
                                        (enumerate 0 (- (length rt-ats-pairs) 1))
                                    )
                                )
                            )
                            (if (= credit-sum 0.0)
                                [0.0 0.0 native-fee-amount]
                                [0.0 credit-sum (- native-fee-amount credit-sum)]
                            )
                        )
                        [0.0 0.0 native-fee-amount]
                    )
                )
                [native-fee-amount 0.0 0.0]
            )
        )
    )
    (defun URCx_CPF_RBT:decimal (id:string native-fee-amount:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ats-pairs:[string] (ref-DPTF::UR_RewardBearingToken id))
                (ats-pairs-bool:[bool] (URCx_NFR-Boolean_RT-RBT id ats-pairs false))
                (milestones:integer (length (ref-U|LST::UC_Search ats-pairs-bool true)))
            )
            (if (!= milestones 0)
                0.0
                native-fee-amount
            )
        )
    )
    (defun URCx_CPF_RT:decimal (id:string native-fee-amount:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ats-pairs:[string] (ref-DPTF::UR_RewardToken id))
                (ats-pairs-bool:[bool] (URCx_NFR-Boolean_RT-RBT id ats-pairs true))
                (milestones:integer (length (ref-U|LST::UC_Search ats-pairs-bool true)))
            )
            (if (!= milestones 0)
                (let
                    (
                        (rt-split-with-boolean:[decimal] (URCx_BooleanDecimalCombiner id native-fee-amount milestones ats-pairs-bool))
                        (number-of-zeroes:integer (length (ref-U|LST::UC_Search rt-split-with-boolean 0.0)))
                    )
                    (map
                        (lambda
                            (index:integer)
                            (if (at index ats-pairs-bool)
                                (ref-ATS::XE_UpdateRUR (at index ats-pairs) id 1 true (at index rt-split-with-boolean))
                                true
                            )
                        )
                        (enumerate 0 (- (length ats-pairs) 1))
                    )
                    0.0
                )
                native-fee-amount
            )
        )
    )
    (defun URCx_NFR-Boolean_RT-RBT:[bool] (id:string ats-pairs:[string] rt-or-rbt:bool)
        @doc "Makes a [bool] using RT or RBT <nfr> values from a list of ATS Pair"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (fold
                (lambda
                    (acc:[bool] index:integer)
                    (if rt-or-rbt
                        (if (ref-ATS::UR_SingleRewardTokenNFR (at index ats-pairs) id)
                            (ref-U|LST::UC_AppL acc true)
                            (ref-U|LST::UC_AppL acc false)
                        )
                        (if (ref-ATS::UR_ColdNativeFeeRedirection (at index ats-pairs))
                            (ref-U|LST::UC_AppL acc true)
                            (ref-U|LST::UC_AppL acc false)
                        )
                    )
                )
                []
                (enumerate 0 (- (length ats-pairs) 1))
            )
        )
    )
    (defun URCx_BooleanDecimalCombiner:[decimal] (id:string amount:decimal milestones:integer boolean:[bool])
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (prec:integer (ref-DPTF::UR_Decimals id))
            )
            (ref-U|ATS::UCv_SplitBalanceWithBooleans prec amount milestones boolean)
        )
    )
    ;;
    (defun URCi_SmallTransmuteCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string transmuter:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisLeg "tier-small") transmuter
                (ref-IGNIS::URC_IsVirtualGasZeroAbsolutely id) []
            )
        )
    )
    (defun URCi_LargeTransmuteCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string transmuter:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisLeg "tier-medium") transmuter
                (ref-IGNIS::URC_IsVirtualGasZeroAbsolutely id) []
            )
        )
    )
    (defun URCi_Transmute:object{IgnisCollectorV3.OutputCumulator}
        (id:string transmuter:string)
        @doc "Cost single-source for C_Transmute — the same class choice C_Transmute makes: \
            \ Elite-Auryn transmute bills the Large (ignis|medium) rail, else the Small \
            \ (ignis|small) rail. Consumed by INFO (C_Transmute already returns this cumulator)."
        (if (URC_IzTrueFungibleEliteAuryn id)
            (URCi_LargeTransmuteCumulator id transmuter)
            (URCi_SmallTransmuteCumulator id transmuter)
        )
    )
    (defun URCi_ClearDispo:object{IgnisCollectorV3.OutputCumulator}
        (account:string)
        @doc "Cost single-source for C_ClearDispo — pure re-derivation of the 5-leg concat: \
            \ (conditional EA freeze) + EA WipeSlim + (conditional EA unfreeze) + Auryn burn + \
            \ Ouroboros burn. Freeze legs are EOC when the EA account is already frozen."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (a-id:string (ref-DALOS::UR_AurynID))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (ats-sc:string (ref-DALOS::GOV|ATS|SC_NAME))
                (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ea-id account))
                (toggle-leg:object{IgnisCollectorV3.OutputCumulator}
                    (if (not frozen-state) (ref-DPTF::URCi_ToggleFreezeAccount ea-id) EOC)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    toggle-leg
                    (ref-DPTF::URCi_WipeSlim ea-id)
                    toggle-leg
                    (ref-DPTF::URCi_Burn a-id ats-sc)
                    (ref-DPTF::URCi_Burn ouro-id ats-sc)
                ]
                []
            )
        )
    )
    ;;
    (defun URCi_UnityTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (sender:string receiver:string amount:decimal)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (price:decimal
                    (if (< amount 10.0)
                        (ref-IGNIS::UC_IgnisLeg "tier-smallest")
                        0.0
                    )
                )
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                price sender
                (ref-IGNIS::URC_ZeroEliteGAZ sender receiver) []
            )
        )
    )
    ;;
    (defun URCi_Transfer:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string receiver:string transfer-amount:decimal)
        @doc "Pure cost of a single C_Transfer, keyed on the SAME inputs C_Transfer takes: \
            \ compute the transfer class then dispatch via URCi_TransferCumulator. Lets \
            \ composers (e.g. ATSU URCi_Coil) total transfer cost WITHOUT performing the \
            \ transfer — the flavor-B preview counterpart of C_Transfer's billed cost."
        (URCi_TransferCumulator
            (at "type" (URC_TransferClasses id sender receiver transfer-amount))
            id sender receiver
        )
    )
    (defun URCi_TransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (type:integer id:string sender:string receiver:string)
        (cond
            ((contains type [1 2]) (URCi_SmallTransferCumulator id sender receiver))
            ((contains type [3 4 5]) (URCi_MediumTransferCumulator id sender receiver))
            ((= type 6) (URCi_LargeTransferCumulator sender receiver))
            EOC
        )
    )
    (defun URCi_SmallTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string receiver:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisLeg "tier-smallest")  sender
                (ref-IGNIS::URC_ZeroGAZ id sender receiver) []
            )
        )
    )
    (defun URCi_MediumTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string receiver:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisLeg "tier-small") sender
                (ref-IGNIS::URC_ZeroGAZ id sender receiver) []
            )
        )
    )
    (defun URCi_LargeTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (sender:string receiver:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisLeg "tier-medium") sender
                (ref-IGNIS::URC_ZeroEliteGAZ sender receiver) []
            )
        )
    )
    ;;Multi
    (defun URCi_MultiTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l:integer (length id-lst))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                            (let
                                (
                                    (id:string (at idx id-lst))
                                    (transfer-amount:decimal (at idx transfer-amount-lst))
                                    (what-type:integer (at "type" (URC_TransferClasses id sender receiver transfer-amount)))
                                    (ico:object{IgnisCollectorV3.OutputCumulator}
                                        (URCi_TransferCumulator what-type id sender receiver)
                                    )
                                )
                                (ref-U|LST::UC_AppL acc ico)
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
        )
    )
    ;;Bulk
    (defun URCi_MultiBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l:integer (length id-lst))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                            (ref-U|LST::UC_AppL acc
                                (URCi_BulkTransferCumulator
                                    (at idx id-lst)
                                    sender
                                    (at idx receiver-array)
                                    (at idx transfer-amount-array)
                                )
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
        )
    )
    (defun URCi_BulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        (let
            (
                (what-type:integer (at "type" (URC_TransferClassesForBulk id sender transfer-amount-lst)))
                (size:integer (length receiver-lst))
            )
            (cond
                ((contains what-type [1 4 5]) (URCi_ComplexBulkTransferCumulator id sender size))
                ((= what-type 2) (URCi_UnityBulkTransferCumulator sender receiver-lst transfer-amount-lst))
                ((= what-type 3) (URCi_SimpleBulkTransferCumulator id sender size))
                ((= what-type 6) (URCi_EliteBulkTransferCumulator id sender size))
                EOC
            )
        )
    )
    ;;
    (defun URCi_UnityBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l:integer (length receiver-lst))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                            (let
                                (
                                    (transfer-amount:decimal (at idx transfer-amount-lst))
                                    (receiver:string (at idx receiver-lst))
                                    (ico:object{IgnisCollectorV3.OutputCumulator}
                                        (URCi_UnityTransferCumulator sender receiver transfer-amount)
                                    )
                                )
                                (ref-U|LST::UC_AppL acc ico)
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
        )
    )
    (defun URCi_SimpleBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string size:integer)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (UDCx_BulkTransferCumulator id sender size (ref-IGNIS::UC_IgnisLeg "tier-smallest"))
        )
    )
    (defun URCi_ComplexBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string size:integer)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (UDCx_BulkTransferCumulator id sender size (ref-IGNIS::UC_IgnisLeg "tier-small"))
        )
    )
    (defun URCi_EliteBulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string size:integer)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (UDCx_BulkTransferCumulator id sender size (ref-IGNIS::UC_IgnisLeg "tier-medium"))
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_MinimumMapperForBulk
        (id:string transfer-amount-lst:[decimal])
        (map
            (lambda
                (idx:integer)
                (UEV_Minimum id (at idx transfer-amount-lst))
            )
            (enumerate 0 (- (length transfer-amount-lst) 1))
        )
    )
    (defun UEV_IgnisTransmuteMinimum (id:string amount:decimal)
        @doc "Floor for transmuting the IGNIS DPTF: at least CT_IGNIS_TRANSMUTE_MINIMUM. Applies \
            \ ONLY to the gas id -- every other DPTF transmutes as before. See the constant for \
            \ why an operation that costs nothing still needs a minimum."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (= id (ref-DALOS::UR_IgnisID))
                (enforce (>= amount CT_IGNIS_TRANSMUTE_MINIMUM)
                    (format "Transmuting IGNIS requires at least {} -- it is gas-station sponsored and costs no IGNIS, so a floor is what stops it being a free transaction pump" [CT_IGNIS_TRANSMUTE_MINIMUM]))
                true
            )
        )
    )
    (defun UEV_Minimum (id:string amount:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (min-move-read:decimal (ref-DPTF::UR_MinMove id))
                (precision:integer (ref-DPTF::UR_Decimals id))
                (min-move:decimal
                    (if (= min-move-read -1.0)
                        (floor (/ 1.0 (^ 10.0 (dec precision))) precision)
                        min-move-read
                    )
                )
            )
            (enforce (>= amount min-move) (format "{} is not a valid {} min move amount" [amount id]))
        )
    )
    (defun UEV_DispoLocker (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (type:bool (ref-DALOS::UR_AccountType account))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (ouro-amount:decimal (ref-DALOS::UR_TF_AccountSupply account true))
            )
            (if (and (= id ea-id) (not type))
                (enforce (not (< ouro-amount 0.0)) "When Account has negative OURO, Elite-Auryn is dispo-locked and cannot be moved")
                true
            )
        )
    )
    (defun UEV_MoveRoleCheck (id:string sender:string receiver:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (verum-five:[string] (ref-DPTF::UR_Verum5 id))
                (lvf:integer (length verum-five))
                (transfer-roles:integer
                    (if (and (= lvf 1) (= verum-five [BAR]))
                        0 lvf
                    )
                )
                (are-transfer-roles-active:bool (if (> transfer-roles 0) true false))
                (ss:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sr:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                (allow:string (format "{} Transfer from {} to {} is allowed" [TF ss sr]))
            )
            (if are-transfer-roles-active
                (let
                    (
                        (ouroboros:string OUROBOROS|SC_NAME)
                        (dalos:string DALOS|SC_NAME)
                        ;;
                        (sender-transfer-role:bool (ref-DPTF::UR_AccountRoleTransfer id sender))
                        (receiver-transfer-role:bool (ref-DPTF::UR_AccountRoleTransfer id receiver))
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
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: DPTF|C>X-TRANSMUTE
    (defun XI_Transmute (id:string transmuter:string transmute-amount:decimal)
        (require-capability (DPTF|C>X-TRANSMUTE id transmuter transmute-amount))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData transmuter))
            )
            (ref-DPTF::XB_DebitTrueFungible id transmuter transmute-amount dispo-data false)
            (XI_CreditPrimaryFee id transmute-amount false)
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPTF|C>X-TRANSFER
    (defun XI_SimpleTransfer (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        (require-capability (DPTF|C>X-TRANSFER id sender receiver method))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData sender))
            )
            (ref-DPTF::XB_DebitTrueFungible id sender transfer-amount dispo-data false)
            (ref-DPTF::XB_CreditTrueFungible id receiver transfer-amount)
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|C>X-TRANSFER
    (defun XI_ComplexTransfer (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        (require-capability (DPTF|C>X-TRANSFER id sender receiver method))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData sender))
            )
            (ref-DPTF::XB_DebitTrueFungible id sender transfer-amount dispo-data false)
            (XI_ComplexCredit id receiver transfer-amount)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XB_CreditTrueFungible,
    ;;Protection:          XE_UpdateFeeVolume
    (defun XI_ComplexCredit (id:string receiver:string transfer-amount:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dalos:string DALOS|SC_NAME)
                (fees:[decimal] (ref-DPTF::URC_Fee id transfer-amount))
                (primary-fee:decimal (at 0 fees))
                (secondary-fee:decimal (at 1 fees))
                (remainder:decimal (at 2 fees))
            )
            (if (!= primary-fee 0.0)
                (XI_CreditPrimaryFee id primary-fee true)
                true
            )
            (if (!= secondary-fee 0.0)
                (do
                    (ref-DPTF::XB_CreditTrueFungible id dalos secondary-fee)
                    (ref-DPTF::XE_UpdateFeeVolume id secondary-fee false)
                )
                true
            )
            (ref-DPTF::XB_CreditTrueFungible id receiver remainder)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XI_DirectUpdateEliteAccount
    (defun XI_DynamicUpdateEliteAccount (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (type:bool (ref-DALOS::UR_AccountType account))
            )
            (if (not type)
                (XI_DirectUpdateEliteAccount account)
                true
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_UpdateElite
    (defun XI_DirectUpdateEliteAccount (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ELITE:module{EliteV2} ELITE)
                (elite-aurynz:decimal (ref-ELITE::URC_EliteAurynzSupply account))
            )
            (ref-DALOS::XE_UpdateElite account elite-aurynz)
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_BulkCredit
        (id:string receiver-lst:[string] transfer-amount-lst:[decimal] complexity:bool elite:bool)
        (require-capability (SECURE))
        (let
            (
                (size:integer (length receiver-lst))
            )
            (if (not complexity)
                (do
                    (XI_BulkCreditAmounts id receiver-lst transfer-amount-lst)
                    (if elite (XI_BulkUpdateElite receiver-lst) true)
                )
                (let
                    (
                        (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                        (dalos:string DALOS|SC_NAME)
                        (fees:[decimal] (UC_BulkFees id transfer-amount-lst))
                        (primary-fee:decimal (at 0 fees))
                        (secondary-fee:decimal (at 1 fees))
                        (bulk-remainders:[decimal] (UC_BulkRemainders id transfer-amount-lst))
                    )
                    (if (!= primary-fee 0.0)
                        (XI_CreditPrimaryFee id primary-fee true)
                        true
                    )
                    (if (!= secondary-fee 0.0)
                        (do
                            (ref-DPTF::XB_CreditTrueFungible id dalos secondary-fee)
                            (ref-DPTF::XE_UpdateFeeVolume id secondary-fee false)
                        )
                        true
                    )
                    (XI_BulkCreditAmounts id receiver-lst bulk-remainders)
                    (if elite (XI_BulkUpdateElite receiver-lst) true)
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_BulkCreditAmounts (id:string receiver-lst:[string] amounts:[decimal])
        (require-capability (SECURE))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (map
                (lambda
                    (idx:integer)
                    (ref-DPTF::XB_CreditTrueFungible id (at idx receiver-lst) (at idx amounts))
                )
                (enumerate 0 (- (length receiver-lst) 1))
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_BulkUpdateElite (receiver-lst:[string])
        (require-capability (SECURE))
        (map
            (lambda
                (idx:integer)
                (XI_DirectUpdateEliteAccount (at idx receiver-lst))
            )
            (enumerate 0 (- (length receiver-lst) 1))
        )
    )
    ;;  [Aux Credit-Primary-Fee]
    ;;Protection: Class 1 — Innate protection offered by XI_CPF_StillFee, XI_CPF_CreditFee,
    ;;Protection:          XI_CPF_BurnFee, XB_CreditTrueFungible, XE_UpdateFeeVolume
    (defun XI_CreditPrimaryFee (id:string pf:decimal native:bool)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (rt:bool (ref-DPTF::URC_IzRT id))
                (rbt:bool (ref-DPTF::URC_IzRBT id))
                (target:string (ref-DPTF::UR_FeeTarget id))
            )
            (if (and rt rbt)
                (let
                    (
                        (v:[decimal] (URCx_CPF_RT-RBT id pf))
                        (v1:decimal (at 0 v))
                        (v2:decimal (at 1 v))
                        (v3:decimal (at 2 v))
                    )
                    (XI_CPF_StillFee id target v1)
                    (XI_CPF_CreditFee id target v2)
                    (XI_CPF_BurnFee id target v3)
                )
                (if rt
                    (let
                        (
                            (v1:decimal (URCx_CPF_RT id pf))
                            (v2:decimal (- pf v1))
                        )
                        (XI_CPF_StillFee id target v1)
                        (XI_CPF_CreditFee id target v2)
                    )
                    (if rbt
                        (let
                            (
                                (v1:decimal (URCx_CPF_RBT id pf))
                                (v2:decimal (- pf v1))
                            )
                            (XI_CPF_StillFee id target v1)
                            (XI_CPF_BurnFee id target v2)
                        )
                        (ref-DPTF::XB_CreditTrueFungible id target pf)
                    )
                )
            )
            (if native
                (ref-DPTF::XE_UpdateFeeVolume id pf true)
                true
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_CPF_StillFee (id:string target:string still-fee:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (if (!= still-fee 0.0)
                (ref-DPTF::XB_CreditTrueFungible id target still-fee)
                true
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_CPF_BurnFee (id:string target:string burn-fee:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (if (!= burn-fee 0.0)
                (ref-DPTF::XBv_UpdateSupply id burn-fee false)
                true
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_CPF_CreditFee (id:string target:string credit-fee:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ats:string (ref-ATS::GOV|ATS|SC_NAME))
            )
            (if (!= credit-fee 0.0)
                (ref-DPTF::XB_CreditTrueFungible id ats credit-fee)
                true
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;;Clear Dispo
    (defun C_ClearDispo:object{IgnisCollectorV3.OutputCumulator}
        (patron:string account:string)
        (P|UEV_IMC)
        (with-capability (DPTF|C>CLEAR-DISPO account)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ATS:module{AutostakeV3} ATS)
                    ;;
                    (ouro-id:string (ref-DALOS::UR_OuroborosID))
                    (a-id:string (ref-DALOS::UR_AurynID))
                    (ea-id:string (ref-DALOS::UR_EliteAurynID))
                    (ouro-amount:decimal (abs (ref-DPTF::UR_AccountSupply ouro-id account)))
                    ;;#58L fix: removed the dead `account-ea-supply` binding (bound, never
                    ;;referenced anywhere in the function body). No functional change.
                    (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ea-id account))
                    ;;
                    (auryndex:string (at 0 (ref-DPTF::UR_RewardToken ouro-id)))
                    (elite-auryndex:string (at 0 (ref-DPTF::UR_RewardToken a-id)))
                    (auryndex-value:decimal (ref-ATS::URC_Index auryndex))
                    (elite-auryndex-value:decimal (ref-ATS::URC_Index elite-auryndex))
                    ;;
                    (o-prec:integer (ref-DPTF::UR_Decimals ouro-id))
                    (a-prec:integer (ref-DPTF::UR_Decimals a-id))
                    (ea-prec:integer (ref-DPTF::UR_Decimals ea-id))
                    ;;
                    (burn-auryn-amount:decimal (floor (/ ouro-amount auryndex-value) a-prec))
                    (burn-elite-auryn-amount:decimal (floor (/ burn-auryn-amount elite-auryndex-value) ea-prec))
                    (total-ea:decimal (floor (* burn-elite-auryn-amount 2.5) ea-prec))
                    (ats-sc:string (ref-DALOS::GOV|ATS|SC_NAME))
                    ;;
                    ;;Ignis Cumulation
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (if (not frozen-state)
                            (ref-DPTF::C_ToggleFreezeAccount patron (ref-DPTF::UR_Konto ea-id) account ea-id true)
                            EOC
                        )
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_WipeSlim patron (ref-DPTF::UR_Konto ea-id) account ea-id total-ea)
                    )
                    ;;#28M fix: only unfreeze if this function was the one that froze it (mirrors
                    ;;ico1's own condition) - otherwise a pre-existing, unrelated freeze on this
                    ;;account gets silently lifted by ClearDispo.
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (if (not frozen-state)
                            (ref-DPTF::C_ToggleFreezeAccount patron (ref-DPTF::UR_Konto ea-id) account ea-id false)
                            EOC
                        )
                    )
                    (ico4:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Burn patron ats-sc a-id burn-auryn-amount)
                    )
                    (ico5:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Burn patron ats-sc ouro-id ouro-amount)
                    )
                )
            ;;1] Freeze EA on account
                ;;via ico1
            ;;2] Partial Wipe EA on account
                ;;via ico2
            ;;3] Unfreeze EA on account
                ;;via ico3
            ;;4] <ATS|SC-NAME> burns <burn-auryn-amount> Auryn amount and decrease Resident Amount by it on <elite-auryndex>
                ;via ico4
                (ref-ATS::XE_UpdateRUR elite-auryndex a-id 1 false burn-auryn-amount)
            ;;5] <ATS|SC-NAME> burns <ouro-amount> OURO amount and decrease Resident Amount by it on <auryndex>
                ;;via ico5
                (ref-ATS::XE_UpdateRUR auryndex ouro-id 1 false ouro-amount)
            ;;6] Finally clears dispo setting OURO <acount> amount to zero
                ;;A dispo IS a negative OURO balance -- the defcap above refuses anything else --
                ;;and <UR_Supply> counts it as negative: the sublimation that opened the dispo
                ;;decremented supply by the very amount it drove the balance below zero. So
                ;;zeroing the balance RETURNS <ouro-amount> to the ledger and supply must follow
                ;;it. Without the second line, ico5's burn is the only supply move in this
                ;;function and it is counted TWICE -- once against ATS's real OURO, once against
                ;;the phantom OURO the dispo represented -- leaving total supply permanently
                ;;BELOW the sum of all balances, by the amount of every dispo ever cleared.
                ;;This is the ONLY one-sided call to DALOS::XB_UpdateBalance in the tree; the
                ;;other four sites are the two halves of a transfer, or DPTF's own dispatch.
                ;;Pinned by RedTeam/[RT-J]_Conservation.repl <<RT-J-001c>>/<<RT-J-001d>>.
                (ref-DALOS::XB_UpdateBalance account true 0.0)
                (ref-DPTF::XBv_UpdateSupply ouro-id ouro-amount true)
            ;;7] Updating Elite Account and Constructing the Output: Pleasure doing business with you !
                (XI_DirectUpdateEliteAccount account)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3  ico4 ico5] [])
            )
        )
    )
    ;;Transmute
    (defun C_Transmute:object{IgnisCollectorV3.OutputCumulator}
        (id:string transmuter:string transmute-amount:decimal)
        @doc "Convert <transmute-amount> of <id> out of <transmuter>'s balance and into the \
            \ protocol's primary fee pool -- a DEBIT plus XI_CreditPrimaryFee, which is exactly \
            \ what a collected fee does. That equivalence is the point: transmuting is how a \
            \ holder gives value to the protocol voluntarily. \
            \ \
            \ TRANSMUTING THE IGNIS DPTF IS THE IGNIS DONATION, and it has three properties that \
            \ only make sense read together -- they live in three different files, so this \
            \ paragraph is where they are written down as one thing: \
            \ \
            \   1. it costs NO IGNIS. URC_IsVirtualGasZeroAbsolutely zeroes the leg when the id \
            \      IS the gas id, so the 101-IGNIS price on DPTF|C_Transmute does not apply. \
            \      Charging IGNIS to donate IGNIS would be absurd. \
            \   2. its minimum is 25, not the 1000 min-move. Transmute is not a transfer and \
            \      never calls UEV_Minimum; the floor is UEV_IgnisTransmuteMinimum, and it exists \
            \      BECAUSE of (1) -- free plus gas-station-sponsored plus no minimum is a free \
            \      transaction pump. \
            \   3. the Ouronet gas station whitelists this call as the paid door to a SPONSORED \
            \      ARBITRARY LET BLOCK. Pay 25 IGNIS here, and the station funds whatever the \
            \      appended form does. That is the product, not a leak. \
            \ \
            \ Anyone tightening UEV_Minimum, repricing DPTF|C_Transmute, or editing the gas \
            \ station's form list is touching one leg of that tripod. All three legs are needed."
        (P|UEV_IMC)
        (let
            (
                (iz-ea:bool (URC_IzTrueFungibleEliteAuryn id))
            )
            (if iz-ea
                (with-capability (DPTF|C>ELITE-TRANSMUTE id transmuter transmute-amount)
                    (XI_Transmute id transmuter transmute-amount)
                    (XI_DirectUpdateEliteAccount transmuter)
                    (URCi_LargeTransmuteCumulator id transmuter)
                )
                (with-capability (DPTF|C>TRANSMUTE id transmuter transmute-amount)
                    (XI_Transmute id transmuter transmute-amount)
                    (URCi_SmallTransmuteCumulator id transmuter)
                )
            )
        )
    )
    ;;Transfer
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator}
        (id:string sender:string receiver:string transfer-amount:decimal method:bool)
        (P|UEV_IMC)
        (let
            (
                (what-type:integer (at "type" (URC_TransferClasses id sender receiver transfer-amount)))
            )
            (cond
                ((= what-type 1) 
                    (with-capability (DPTF|C>CLASS-1-TRANSFER id sender receiver transfer-amount method)
                        (XI_SimpleTransfer id sender receiver transfer-amount method)
                    )
                )
                ((= what-type 2) 
                    (with-capability (DPTF|C>CLASS-1-TRANSFER-UNITY id sender receiver transfer-amount method)
                        (XI_SimpleTransfer id sender receiver transfer-amount method)
                    )
                )
                ((= what-type 3) 
                    (with-capability (DPTF|C>CLASS-2-TRANSFER id sender receiver transfer-amount method)
                        (XI_ComplexTransfer id sender receiver transfer-amount method)
                    )
                )
                ((= what-type 4) 
                    (with-capability (DPTF|C>CLASS-2-TRANSFER-UNITY id sender receiver transfer-amount method)
                        (XI_ComplexTransfer id sender receiver transfer-amount method)
                    )
                )
                ((= what-type 5) 
                    (with-capability (DPTF|C>CLASS-2-TRANSFER-ELITE id sender receiver transfer-amount method)    
                        (XI_SimpleTransfer id sender receiver transfer-amount method)
                        (XI_DynamicUpdateEliteAccount sender)
                        (XI_DynamicUpdateEliteAccount receiver)
                    )
                )
                ((= what-type 6) 
                    (with-capability (DPTF|C>CLASS-3-TRANSFER-ELITE id sender receiver transfer-amount method)   
                        (XI_ComplexTransfer id sender receiver transfer-amount method)
                        (XI_DynamicUpdateEliteAccount sender)
                        (XI_DynamicUpdateEliteAccount receiver)
                    )
                )
                true
            )
            (URCi_TransferCumulator what-type id sender receiver)
        )
    )
    ;;Multi Transfer
    (defun C_MultiTransfer:object{IgnisCollectorV3.OutputCumulator}
        (id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal] method:bool)
        (P|UEV_IMC)
        (with-capability (DPTF|C>MULTI-TRANSFER id-lst sender receiver transfer-amount-lst method)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (contains-eazs:bool (UC_ContainsEliteAurynz id-lst))
                    (l:integer (length id-lst))
                    (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                        (fold
                            (lambda
                                (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                (let
                                    (
                                        (id:string (at idx id-lst))
                                        (transfer-amount:decimal (at idx transfer-amount-lst))
                                        (what-type-obj:object{TrueFungibleTransferV2.TransferClass} (URC_TransferClasses id sender receiver transfer-amount))
                                        (what-type:integer (at "type" what-type-obj))
                                        (ico:object{IgnisCollectorV3.OutputCumulator}
                                            (URCi_TransferCumulator what-type id sender receiver)
                                        )
                                        (iz-simple-transfer:bool (at "iz-it-simple" what-type-obj))
                                        ;;#29M fix: recompute dispo-data fresh for EACH leg (was
                                        ;;snapshotted once before the fold and reused for every
                                        ;;leg) - otherwise an earlier/later leg in this same batch
                                        ;;that reduces sender's Elite-Auryn holdings leaves this
                                        ;;leg's OURO-overdraft check using a stale, too-generous
                                        ;;dispo limit.
                                        (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData sender))
                                    )
                                    ;;Debit
                                    (ref-DPTF::XB_DebitTrueFungible id sender transfer-amount dispo-data false)
                                    ;;Credit
                                    (if iz-simple-transfer
                                        (ref-DPTF::XB_CreditTrueFungible id receiver transfer-amount)
                                        (XI_ComplexCredit id receiver transfer-amount)
                                    )
                                    (ref-U|LST::UC_AppL acc ico)
                                )
                            )
                            []
                            (enumerate 0 (- l 1))
                        )
                    )
                )
                (if contains-eazs
                    (do
                        (XI_DynamicUpdateEliteAccount sender)
                        (XI_DynamicUpdateEliteAccount receiver)
                    )
                    true
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
            )
        )
    )
    ;;Bulk Transfer
    (defun C_MultiBulkTransfer:object{IgnisCollectorV3.OutputCumulator}
        (id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]])
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (contains-eazs:bool (UC_ContainsEliteAurynz id-lst))
                (l:integer (length id-lst))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                            (let
                                (
                                    (id:string (at idx id-lst))
                                    (receiver-lst:[string] (at idx receiver-array))
                                    (transfer-amount-lst:[decimal] (at idx transfer-amount-array))
                                    (size:integer (length receiver-lst))
                                    (what-type-obj:object{TrueFungibleTransferV2.TransferClass}
                                        (URC_TransferClassesForBulk id sender transfer-amount-lst)
                                    )
                                    (what-type:integer (at "type" what-type-obj))
                                    (iz-it-simple:bool (at "iz-it-simple" what-type-obj))
                                    (total-debit:decimal (fold (+) 0.0 transfer-amount-lst))
                                    (ico:object{IgnisCollectorV3.OutputCumulator}
                                        (cond
                                            ((contains what-type [1 4 5]) (URCi_ComplexBulkTransferCumulator id sender size))
                                            ((= what-type 2) (URCi_UnityBulkTransferCumulator sender receiver-lst transfer-amount-lst))
                                            ((= what-type 3) (URCi_SimpleBulkTransferCumulator id sender size))
                                            ((= what-type 6) (URCi_EliteBulkTransferCumulator id sender size))
                                            EOC
                                        )
                                    )
                                    ;;#29M fix: recompute dispo-data fresh for EACH leg, same
                                    ;;reasoning as C_MultiTransfer above.
                                    (dispo-data:object{UtilityDptfV2.DispoData} (UDC_GetDispoData sender))
                                )
                                ;;Debit
                                (with-capability (P|TFT|CALLER)
                                    (ref-DPTF::XB_DebitTrueFungible id sender total-debit dispo-data false)
                                )
                                ;;Credit
                                (cond
                                    ((= what-type 1) 
                                        (with-capability (DPTF|C>CLASS-0-BULK id sender receiver-lst transfer-amount-lst iz-it-simple) 
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst true false)
                                        )
                                    )
                                    ((= what-type 2) 
                                        (with-capability (DPTF|C>CLASS-0-BULK-UNITY id sender receiver-lst transfer-amount-lst iz-it-simple)
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst true false)
                                        )
                                    )
                                    ((= what-type 3) 
                                        (with-capability (DPTF|C>CLASS-1-BULK id sender receiver-lst transfer-amount-lst)
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst false false)
                                        )
                                    )
                                    ((= what-type 4) 
                                        (with-capability (DPTF|C>CLASS-2-BULK id sender receiver-lst transfer-amount-lst)
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst true false)
                                        )
                                    )
                                    ((= what-type 5) 
                                        (with-capability (DPTF|C>CLASS-2-BULK-ELITE id sender receiver-lst transfer-amount-lst)    
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst false true)
                                        )
                                    )
                                    ((= what-type 6) 
                                        (with-capability (DPTF|C>CLASS-3-BULK-ELITE id sender receiver-lst transfer-amount-lst)    
                                            (XI_BulkCredit id receiver-lst transfer-amount-lst true true)
                                        )
                                    )
                                    true
                                )
                                (ref-U|LST::UC_AppL acc ico)
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            ;;Refresh the sender's own Elite tier once, if any leg touched an Elite-Auryn
            ;;class token — the receiver side is already refreshed per-leg inside
            ;;XI_BulkCredit (via its `elite` flag -> XI_BulkUpdateElite).
            (if contains-eazs
                (XI_DynamicUpdateEliteAccount sender)
                true
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
        )
    )

)

;; --- tables for 09_TFT.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact ====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AutostakeUsageV2
    @doc "Exposes Autostake Usage Functions, which involve Token Transfers"

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
    (defun URC_MultiCull:object (ats:string acc:string))
    (defun URC_SingleCull:[decimal] (ats:string acc:string position:integer))
    ;;
    ;;  [UDC]
    ;;
    (defun URCi_UnlimitedUncoilCumulator:object{IgnisCollectorV3.OutputCumulator} (ats:string account:string))
    (defun URCi_WithdrawRoyalties:object{IgnisCollectorV3.OutputCumulator} (ats:string target:string))
    (defun URCi_KickStart:object{IgnisCollectorV3.OutputCumulator} (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator} (fueler:string ats:string reward-token:string amount:decimal))
    (defun URCi_Coil:object{IgnisCollectorV3.OutputCumulator} (coiler:string ats:string rt:string amount:decimal))
    (defun URCi_Curl:object{IgnisCollectorV3.OutputCumulator} (curler:string ats1:string ats2:string rt:string amount:decimal))
    (defun URCi_ColdRecovery:object{IgnisCollectorV3.OutputCumulator} (recoverer:string ats:string ra:decimal))
    (defun URCi_Cull:object{IgnisCollectorV3.OutputCumulator} (culler:string ats:string))
    (defun URCi_HotRecovery:object{IgnisCollectorV3.OutputCumulator} (recoverer:string ats:string ra:decimal))
    (defun URCi_Recover:object{IgnisCollectorV3.OutputCumulator} (recoverer:string id:string nonce:integer))
    (defun URCi_Redeem:object{IgnisCollectorV3.OutputCumulator} (redeemer:string id:string nonce:integer))
    (defun URCi_DirectRecovery:object{IgnisCollectorV3.OutputCumulator} (recoverer:string ats:string ra:decimal))
    (defun URCi_Syphon:object{IgnisCollectorV3.OutputCumulator} (syphon-target:string ats:string syphon-amounts:[decimal]))
    (defun URCi_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator} (remover:string ats:string reward-token:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun AA_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string accounts-with-ats-data:[string])
    )
    (defun A_KickStart:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
    )
    ;;
    ;;  [C]
    ;;
    (defun CC_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string)
    )
    (defun C_WithdrawRoyalties:object{IgnisCollectorV3.OutputCumulator}(ats:string target:string))
        ;;
    (defun C_KickStart:object{IgnisCollectorV3.OutputCumulator} (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator} (fueler:string ats:string reward-token:string amount:decimal))
    (defun C_Coil:object{IgnisCollectorV3.OutputCumulator} (patron:string coiler:string ats:string rt:string amount:decimal))
    (defun C_Curl:object{IgnisCollectorV3.OutputCumulator} (patron:string curler:string ats1:string ats2:string rt:string amount:decimal))
        ;;
    (defun C_ColdRecovery:object{IgnisCollectorV3.OutputCumulator} (patron:string recoverer:string ats:string ra:decimal))
    (defun C_Cull:object{IgnisCollectorV3.OutputCumulator}(culler:string ats:string))
        ;;
    (defun C_HotRecovery:object{IgnisCollectorV3.OutputCumulator} (patron:string recoverer:string ats:string ra:decimal))
    (defun C_Recover:object{IgnisCollectorV3.OutputCumulator} (patron:string recoverer:string id:string nonce:integer))
    (defun C_Redeem:object{IgnisCollectorV3.OutputCumulator} (patron:string redeemer:string id:string nonce:integer))
        ;;
    (defun C_DirectRecovery:object{IgnisCollectorV3.OutputCumulator} (patron:string recoverer:string ats:string ra:decimal))
        ;;
    (defun C_Syphon:object{IgnisCollectorV3.OutputCumulator} (syphon-target:string ats:string syphon-amounts:[decimal]))

)
;;
(module ATSU GOV
    @doc "ATSU — the Autostake usage core, performing the token-moving operations on ATS \
        \ pools; implements AutostakeUsageV2. It provides URCi cost readers plus client ops \
        \ KickStart, Fuel, Coil, Curl, ColdRecovery, Cull, HotRecovery, Recover, Redeem, \
        \ DirectRecovery, Syphon, WithdrawRoyalties and RemoveSecondary. It complements ATS \
        \ (pool configuration) by executing the actual reward-token staking, recovery and \
        \ reward withdrawals."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements AutostakeUsageV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_ATSU                               (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_ATSU                               (keyset-ref-guard (GOV|AutostakeKey)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ATSU_ADMIN)))
    (defcap GOV|ATSU_ADMIN ()
        (enforce-one
            "ATSU Autostake Admin not satisfed"
            [
                (enforce-guard GOV|MD_ATSU)
                (enforce-guard GOV|SC_ATSU)
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
    (defcap P|ATSU|CALLER ()
        true
    )
    (defcap P|ATSU|REMOTE-GOV ()
        true
    )
    (defcap P|TT ()
        (compose-capability (P|ATSU|REMOTE-GOV))
        (compose-capability (P|ATSU|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT1 ()
        (compose-capability (P|ATSU|REMOTE-GOV))
        (compose-capability (SECURE))
    )
    (defcap P|DT2 ()
        (compose-capability (P|ATSU|REMOTE-GOV))
        (compose-capability (P|ATSU|CALLER))
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
        (with-capability (GOV|ATSU_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|ATSU_ADMIN)
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
        (with-capability (GOV|ATSU_ADMIN)
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
        (with-capability (GOV|ATSU_ADMIN)
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
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (mg:guard (create-capability-guard (P|ATSU|CALLER)))
            )
            (ref-P|ATS::P|A_Add
                "ATSU|RemoteAtsGov"
                (create-capability-guard (P|ATSU|REMOTE-GOV))
            )

            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst ATS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|ATS|SC_NAME)
        )
    )
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
    (defcap ATSU|C>ADMINISTRATIVE-REMOVE-SECONDARY (ats:string reward-token:string)
        @event
        (compose-capability (GOV|ATSU_ADMIN))
        (compose-capability (ATSU|C>X_REMOVE-SECONDARY ats reward-token))
    )
    (defcap ATSU|C>REMOVE-SECONDARY (ats:string reward-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-ATS::CAP_Owner ats)
            (compose-capability (ATSU|C>X_REMOVE-SECONDARY ats reward-token))
        )
    )
    (defcap ATSU|C>X_REMOVE-SECONDARY (ats:string reward-token:string)
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (rt-position:integer (ref-ATS::URCv_RewardTokenPosition ats reward-token))
            )
            (enforce (> rt-position 0) "Primal RT cannot be removed")
            (ref-ATS::UEV_ParameterLockState ats false)
            (ref-ATS::UEV_ColdRecoveryState ats false)
            (ref-ATS::UEV_HotRecoveryState ats false)
            (ref-ATS::UEV_DirectRecoveryState ats false)
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>WITHDRAW-ROYALTIES (ats:string target:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
                (royalties:[decimal] (ref-ATS::UR_RewardTokenRUR ats 3))
                (sum:decimal (fold (+) 0.0 royalties))
            )
            (ref-DALOS::UEV_EnforceAccountType target false)
            (ref-ATS::CAP_Owner ats)
            (enforce (!= sum 0.0) (format "No Royalties to withdraw for ATS-Pair {}" [ats]))
            (compose-capability (P|DT2))
        )
    )
    ;;
    (defcap ATSU|C>KICKSTART (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Fix (audit finding #11M / M2): bounds the resulting KickStart index to \
            \ <= 100.0 on the owner-facing path, closing the unbounded genesis-ratio \
            \ inflation-attack surface against depositors who coil in after this pair \
            \ is kickstarted. Owners needing a higher ratio use A_KickStart, gated by \
            \ module governance instead of pool ownership. Layered per StoicSyntax \
            \ §14.7: thin event leaf, shared validation lives in ATSU|C>X_KICKSTART."
        @event
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (would-be-index:decimal (ref-U|ATS::UC_KickStartIndex rt-amounts rbt-request-amount))
            )
            (ref-ATS::CAP_Owner ats)
            (enforce (<= would-be-index 100.0) "KickStart index cannot exceed 100.0 via the owner path - use A_KickStart via module governance for a higher ratio")
            (compose-capability (ATSU|C>X_KICKSTART kickstarter ats rt-amounts rbt-request-amount))
        )
    )
    (defcap ATSU|C>ADMINISTRATIVE-KICKSTART (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Administrative KickStart variant (audit finding #11M / M2, owner- \
            \ specified fix direction): forgoes pool ownership in favor of module \
            \ governance (GOV|ATSU_ADMIN), with no upper bound on the resulting index \
            \ (still subject to the same 0.1 floor as the owner path, via the shared \
            \ ATSU|C>X_KICKSTART core) - for legitimate ratios above the owner path's \
            \ 100.0 ceiling."
        @event
        (compose-capability (GOV|ATSU_ADMIN))
        (compose-capability (ATSU|C>X_KICKSTART kickstarter ats rt-amounts rbt-request-amount))
    )
    (defcap ATSU|C>X_KICKSTART (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Unevented core - shared validation for both ATSU|C>KICKSTART (owner) and \
            \ ATSU|C>ADMINISTRATIVE-KICKSTART (module governance). Fix (audit finding \
            \ #11M / M2): adds a shared >= 0.1 floor on the resulting index, same value \
            \ as syphon's own floor, on top of the pre-existing checks."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (index:decimal (ref-ATS::URC_Index ats))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (l1:integer (length rt-amounts))
                (l2:integer (length rt-lst))
                (would-be-index:decimal (ref-U|ATS::UC_KickStartIndex rt-amounts rbt-request-amount))
            )
            (ref-DALOS::UEV_EnforceAccountType kickstarter false)
            ;; Caller-input-only checks first (independent of live pool state), pool-state
            ;; checks last - lets bound violations be rejected before ever touching state.
            (enforce (= l1 l2) "RT-Amounts list does not correspond with the Number of the ATS-Pair Reward Tokens")
            (enforce (> rbt-request-amount 0.0) "RBT Request Amount must be greater than zero!")
            (enforce (>= would-be-index 0.1) "KickStart index must be at least 0.1")
            (enforce (= index -1.0) "Kickstarting can only be done on ATS-Pairs with -1 Index")
            (compose-capability (P|TT))
        )
    )
    ;;Module-local (no interface change): the single source for "can this pair be fuelled".
    ;;Shared by ATSU|C>FUEL and URCi_Fuel so the quote and the op refuse in the same words.
    (defun UEV_FuelableIndex (ats:string)
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (enforce
                (>= (ref-ATS::URC_Index ats) 0.1)
                "Fueling requires an ATS-Pair Index of at least 0.1"
            )
        )
    )
    (defcap ATSU|C>FUEL (ats:string reward-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (index:decimal (ref-ATS::URC_Index ats))
            )
            (ref-ATS::UEV_RewardTokenExistance ats reward-token true)
            ;;WORDING FIX (owner-authorised 2026-09-13). This read "Fueling cannot take place on a
            ;;negative Index", which described only part of its own condition: the bound is 0.1, so
            ;;an index of 0.05 is POSITIVE and still rejected, and that caller was told something
            ;;untrue about their own pair. The BOUND is correct and stays -- 0.1 is a deliberate
            ;;system floor, the same one ATSU|C>KICKSTART applies to <would-be-index> twelve lines
            ;;above, where it is already worded honestly as "KickStart index must be at least 0.1".
            ;;The two states this rejects are the -1.0 sentinel (URC_Index's "no RBT supply at all")
            ;;and a live pair whose index has fallen under the floor; the new message covers both.
            ;;Pinned in BOTH states by REPL/modules/ATS.repl <<ATS-G17>>.
            ;;REFUSAL PARITY (2026-09-15): this enforce used to be written out here, which meant
            ;;URCi_Fuel had no way to share it and quoted a confident "Succesfully fueled ..." for
            ;;pairs this line refuses. It now lives in UEV_FuelableIndex, called by BOTH, so the
            ;;preview and the exec cannot drift apart or word the same refusal differently.
            (UEV_FuelableIndex ats)
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>COIL (ats:string coil-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (h:bool (ref-ATS::UR_Hibernate ats))
            )
            (ref-ATS::UEV_RewardTokenExistance ats coil-token true)
            (enforce (not h) (format "Cannot Coil when {} has Hibernation turned on" [ats]))
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>CURL (ats1:string ats2:string curl-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (h1:bool (ref-ATS::UR_Hibernate ats1))
                (h2:bool (ref-ATS::UR_Hibernate ats2))
            )
            (ref-ATS::UEV_RewardTokenExistance ats1 curl-token true)
            (enforce (and (not h1) (not h2)) (format "Curl requires both {} and {} to have Hibernation set to off" [ats1 ats2]))
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>COLD_RECOVERY (recoverer:string ats:string ra:decimal usable-cold-recovery-position:integer)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
                (cold-recovery-positions:integer (ref-ATS::UR_ColdRecoveryPositions ats))
            )
            (enforce (<= usable-cold-recovery-position cold-recovery-positions) 
                "Unavailable Positions for Cold Recovery!"
            )
            (ref-DALOS::CAP_EnforceAccountOwnership recoverer)
            (ref-ATS::UEV_ColdRecoveryState ats true)
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>DEPLOY (ats:string acc:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists acc)
            (compose-capability (ATSU|C>NORMALIZE_LEDGER ats acc))
        )
    )
    (defcap ATSU|C>NORMALIZE_LEDGER (ats:string acc:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
                (dalos-admin:guard GOV|MD_ATSU)
                (autos-admin:guard GOV|SC_ATSU)
                (acc-g:guard (ref-DALOS::UR_AccountGuard acc))
                (sov:string (ref-DALOS::UR_AccountSovereign acc))
                (sov-g:guard (ref-DALOS::UR_AccountGuard sov))
                (gov-g:guard (ref-DALOS::UR_AccountGovernor acc))
            )
            (ref-ATS::UEV_id ats)
            (enforce-one
                "Invalid permission for normalizing ATS|Ledger Account Operations"
                [
                    (enforce-guard dalos-admin)
                    (enforce-guard autos-admin)
                    (enforce-guard acc-g)
                    (enforce-guard sov-g)
                    (enforce-guard gov-g)
                ]
            )
            (compose-capability (P|ATSU|CALLER))
        )
    )
    (defcap ATSU|C>CULL (culler:string ats:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership culler)
            (compose-capability (ATSU|C>NORMALIZE_LEDGER ats culler))
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap ATS|C>HOT_RECOVERY (recoverer:string ats:string ra:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership recoverer)
            (ref-ATS::UEV_HotRecoveryState ats true)
            ;;The toggle and the Hot-RBT are INDEPENDENT: ATS|S>SWITCH-HOT-RECOVERY checks only
            ;;CAP_Owner and the previous toggle value, so a pool owner may switch recovery ON for a
            ;;pair that has no Hot-RBT. In that state the line above passes and the body would read
            ;;the DPOF properties table keyed by the BAR sentinel. Pinned by <<RT-H-003e>>, which
            ;;constructs exactly that state through the owner's own client op.
            (enforce
                (ref-ATS::URC_IzPresentHotRBT ats)
                (format "ATS-Pair {} has no Hot-RBT, so Hot Recovery is impossible" [ats])
            )
            (compose-capability (P|TT))
        )
    )
    (defcap ATS|C>RECOVER (recoverer:string id:string nonce:integer)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (iz-rbt:bool (ref-DPOF::URC_IzRBT id))
            )
            (ref-DALOS::UEV_EnforceAccountType recoverer false)
            (enforce iz-rbt "Invalid Hot-RBT")
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>REDEEM (redeemer:string id:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (iz-rbt:bool (ref-DPOF::URC_IzRBT id))
            )
            (ref-DALOS::UEV_EnforceAccountType redeemer false)
            (enforce iz-rbt "Invalid Hot-RBT")
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap ATS|C>DIRECT_RECOVERY (recoverer:string ats:string ra:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership recoverer)
            (ref-ATS::UEV_DirectRecoveryState ats true)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap ATSU|C>SYPHON (ats:string syphon-amounts:[decimal])
        @event
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (l0:integer (length syphon-amounts))
                (l1:integer (length rt-lst))
                (syphoning:bool (ref-ATS::UR_Syphoning ats))
                (max-syphon:[decimal] (ref-ATS::URC_MaxSyphon ats))
                (max-syphon-sum:decimal (fold (+) 0.0 max-syphon))
                (input-syphon-sum:decimal (fold (+) 0.0 syphon-amounts))
                (resident-amounts:[decimal] (ref-ATS::UR_RewardTokenRUR ats 1))
                (supply-check:[bool] (zip (lambda (x:decimal y:decimal) (<= x y)) syphon-amounts resident-amounts))
                (tr-nr:integer (length (ref-U|LST::UC_Search supply-check true)))
            )
            (ref-ATS::CAP_Owner ats)
            (enforce syphoning "Syphoning must be turned ON for exec")
            (enforce (= l0 l1) "Invalid Amounts of Syphon Values")
            (enforce (> input-syphon-sum 0.0) "Invalid Syphon Amounts")
            (map
                (lambda
                    (sv:decimal)
                    (enforce (>= sv 0.0) "Unallowed Negative Syphon Values Detected !")
                )
                syphon-amounts
            )
            (enforce (<= input-syphon-sum max-syphon-sum) "Syphon Amounts surpassing pairs Syphon-Index")
            (enforce (= l0 tr-nr) "Invalid syphon amounts surpassing present resident Amounts")
            (compose-capability (P|TT))
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
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_MultiCull:object (ats:string acc:string)
        @doc "Outputs <after-cull> <to-be-culled> <culled-values> and <summed-culled-values> values in an object. \
            \ Fix (audit finding #32N / N1): the 'nothing cullable yet' branch used to return a bare \
            \ [decimal] list instead of an object, violating this function's own declared :object \
            \ return type - XI_MultiCull's :object-typed binding made that a hard runtime crash \
            \ instead of a graceful 'nothing to cull yet' result. Confirmed live on mainnet via Pythia \
            \ dirty read (identical bug present in the deployed ouronet-ns.ATSU, on V1 interfaces) - \
            \ not yet triggered there only because every existing live account currently has something \
            \ already past its cull-time. This is a soft-failure fix: the outcome (nothing culled) is \
            \ unchanged, only the failure mode changes from a raw crash to a well-formed empty result."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-ATS:module{AutostakeV3} ATS)
                ;;
                (zr:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeZeroUnstakeObject ats))
                (ng:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeNegativeUnstakeObject ats))
                (p0:[object{UtilityAtsV3.Awo}] (ref-ATS::UR_P0 ats acc))
                (p0l:integer (length p0))
                (boolean-lst:[bool]
                    (fold
                        (lambda
                            (acc:[bool] item:object{UtilityAtsV3.Awo})
                            (ref-U|LST::UC_AppL acc (ref-U|ATS::UC_IzCullable item))
                        )
                        []
                        p0
                    )
                )
                (zr-output:[decimal] (make-list (length (ref-ATS::UR_RewardTokens ats)) 0.0))
                (cullables:[integer] (ref-U|LST::UC_Search boolean-lst true))
                (immutables:[integer] (ref-U|LST::UC_Search boolean-lst false))
                (how-many-cullables:integer (length cullables))
            )
            (if (= how-many-cullables 0)
                {"after-cull"           : p0
                ,"to-be-culled"         : []
                ,"culled-values"        : []
                ,"summed-culled-values" : zr-output}
                (let
                    (
                        (after-cull:[object{UtilityAtsV3.Awo}]
                            (if (< how-many-cullables p0l)
                                (fold
                                    (lambda
                                        (acc:[object{UtilityAtsV3.Awo}] idx:integer)
                                        (ref-U|LST::UC_AppL acc (at (at idx immutables) p0))
                                    )
                                    []
                                    (enumerate 0 (- (length immutables) 1))
                                )
                                [zr]
                            )
                        )
                        (to-be-culled:[object{UtilityAtsV3.Awo}]
                            (fold
                                (lambda
                                    (acc:[object{UtilityAtsV3.Awo}] idx:integer)
                                    (ref-U|LST::UC_AppL acc (at (at idx cullables) p0))
                                )
                                []
                                (enumerate 0 (- (length cullables) 1))
                            )
                        )
                        (culled-values:[[decimal]]
                            (fold
                                (lambda
                                    (acc:[[decimal]] idx:integer)
                                    (ref-U|LST::UC_AppL acc (ref-ATS::URC_CullValue ats (at idx to-be-culled)))
                                )
                                []
                                (enumerate 0 (- (length to-be-culled) 1))
                            )
                        )
                        (summed-culled-values:[decimal] (ref-U|DEC::UC_AddHybridArray culled-values))
                    )
                    {"after-cull"           : after-cull
                    ,"to-be-culled"         : to-be-culled
                    ,"culled-values"        : culled-values
                    ,"summed-culled-values" : summed-culled-values}
                )
            )
        )
    )
    (defun URC_SingleCull:[decimal] (ats:string acc:string position:integer)
        @doc "Outputs <cull-output> as a value of RTs"
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                ;;
                (unstake-obj:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc position))
                (cull-output:[decimal] (ref-ATS::URC_CullValue ats unstake-obj))
            )
            cull-output
        )
    )
    (defun URCi_UnlimitedUncoilCumulator:object{IgnisCollectorV3.OutputCumulator}
        (ats:string account:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                ;;
                (p0:[object{UtilityAtsV3.Awo}] (ref-ATS::UR_P0 ats account))
                (size:decimal (dec (length p0)))
                (smallest:decimal (ref-IGNIS::UC_IgnisLeg "tier-smallest"))
                (price:decimal (* size smallest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price account trigger [])
        )
    )
    (defun URCi_WithdrawRoyalties:object{IgnisCollectorV3.OutputCumulator}
        (ats:string target:string)
        @doc "Cost preview for C_WithdrawRoyalties — a single multi-transfer of the \
            \ pool's nonzero-royalty reward-token legs to <target>, re-derived purely \
            \ via TFT URCi_MultiTransferCumulator (same nonzero-royalty filter as exec)."
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (reward-tokens:[string] (ref-ATS::UR_RewardTokenList ats))
                (royalties:[decimal] (ref-ATS::UR_RewardTokenRUR ats 3))
                (nonzero-idx:[integer]
                    (filter
                        (lambda (index:integer) (> (at index royalties) 0.0))
                        (enumerate 0 (- (length reward-tokens) 1))
                    )
                )
            )
            (ref-TFT::URCi_MultiTransferCumulator
                (map (lambda (index:integer) (at index reward-tokens)) nonzero-idx)
                ATS|SC_NAME
                target
                (map (lambda (index:integer) (at index royalties)) nonzero-idx)
            )
        )
    )
    (defun URCi_KickStart:object{IgnisCollectorV3.OutputCumulator}
        (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Cost preview for C_KickStart / A_KickStart (both delegate to XI_KickStart): \
            \ one reward-token transfer per rt (mapped purely), plus cold-mint + \
            \ cold-transfer. Cost-equivalent to XI_KickStart; the [index] output is the \
            \ pre-kickstart index (the exec value reflects post-write state)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (rbt-id:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (map
                        (lambda (idx:integer)
                            (ref-TFT::URCi_Transfer (at idx rt-lst) kickstarter ATS|SC_NAME (at idx rt-amounts))
                        )
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                )
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint rbt-id ATS|SC_NAME false)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer rbt-id ATS|SC_NAME kickstarter rbt-request-amount)
                )
                (index:decimal (ref-ATS::URC_Index ats))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [index])
        )
    )
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator}
        (fueler:string ats:string reward-token:string amount:decimal)
        @doc "Cost preview for C_Fuel — a single reward-token transfer into the ATS SC."
        ;;The op's own gate, not a copy of it. Without this the quote succeeded -- returning a
        ;;cost AND the post-text "Succesfully fueled ..." -- for a pair C_Fuel refuses outright.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-001b>>.
        (UEV_FuelableIndex ats)
        (let
            (
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
            )
            (ref-TFT::URCi_Transfer reward-token fueler ATS|SC_NAME amount)
        )
    )
    (defun URCi_Coil:object{IgnisCollectorV3.OutputCumulator}
        (coiler:string ats:string rt:string amount:decimal)
        @doc "Cost preview for C_Coil (flavor-B composer). Re-derives C_Coil's \
            \ Concatenate[transfer, mint, transfer] purely — calling each sub-op's \
            \ own cost reader (TFT URCi_Transfer, DPTF URCi_Mint) instead of the write \
            \ C_ — so it totals the IGNIS cost WITHOUT performing the coil. \
            \ Cost-equivalent to C_Coil's billed cumulator (same IGNIS; output list \
            \ mirrors the exec [c-rbt-amount])."
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (coil-data:object{AutostakeV3.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats rt amount)
                )
                (c-rbt:string (at "rbt-id" coil-data))
                (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer rt coiler ATS|SC_NAME amount)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt ATS|SC_NAME false)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt ATS|SC_NAME coiler c-rbt-amount)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [c-rbt-amount])
        )
    )
    (defun URCi_Curl:object{IgnisCollectorV3.OutputCumulator}
        (curler:string ats1:string ats2:string rt:string amount:decimal)
        @doc "Cost preview for C_Curl (flavor-B composer): two chained coils across \
            \ ats1/ats2, re-derived purely via sub-op cost readers (no writes). \
            \ Cost-equivalent to C_Curl's billed cumulator; output mirrors [c-rbt2-amount]."
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (coil1-data:object{AutostakeV3.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                )
                (c-rbt1:string (at "rbt-id" coil1-data))
                (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                (coil2-data:object{AutostakeV3.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats2 c-rbt1 c-rbt1-amount)
                )
                (c-rbt2:string (at "rbt-id" coil2-data))
                (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer rt curler ATS|SC_NAME amount)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt1 ATS|SC_NAME false)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt2 ATS|SC_NAME false)
                )
                (ico4:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt2 ATS|SC_NAME curler c-rbt2-amount)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [c-rbt2-amount])
        )
    )
    ;;
    (defun URCi_ColdRecovery:object{IgnisCollectorV3.OutputCumulator}
        (recoverer:string ats:string ra:decimal)
        @doc "Cost preview for C_ColdRecovery: flat 2x-biggest construct + cold-transfer \
            \ + cold-burn + (unlimited-uncoil when position=-1) + (fee-leg burns when a \
            \ non-redirected c-rbt fee exists). Re-derived purely via URC_ reads + sub-op \
            \ cost readers; the exec fold's XE_UpdateRUR side-writes don't affect cost."
        ;;The exec's OWN state guard, called rather than re-typed -- UEV_ColdRecoveryState is the very
        ;;function ATSU|C>COLD_RECOVERY uses, so the refusal is identical by construction and
        ;;cannot drift. It must precede the binding group below: Pact evaluates every binding in a
        ;;group before the body, and those bindings read state that does not exist for a pair in
        ;;this condition. Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-001d>>.
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-ATS::UEV_ColdRecoveryState ats true)
        )
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (usable-cold-recovery-position:integer (ref-ATS::URC_WhichPosition ats ra recoverer))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (c-rbt-precision:integer (ref-DPTF::UR_Decimals c-rbt))
                (fee-promile:decimal (ref-ATS::URCv_ColdRecoveryFee ats ra usable-cold-recovery-position))
                (c-rbt-fee-split:[decimal] (ref-U|ATS::UC_PromilleSplit fee-promile ra c-rbt-precision))
                (c-rbt-fee:decimal (at 1 c-rbt-fee-split))
                (c-fr:bool (ref-ATS::UR_ColdRecoveryFeeRedirection ats))
                (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_ColdRecovery" "usage"))
                ;;
                (ico0:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                )
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt recoverer ATS|SC_NAME ra)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Burn c-rbt ATS|SC_NAME)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (if (!= usable-cold-recovery-position -1)
                        EOC
                        (URCi_UnlimitedUncoilCumulator ats recoverer)
                    )
                )
                (ico4:object{IgnisCollectorV3.OutputCumulator}
                    (if (= c-rbt-fee 0.0)
                        EOC
                        (if c-fr
                            EOC
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                (map
                                    (lambda (idx:integer)
                                        (ref-DPTF::URCi_Burn (at idx rt-lst) ATS|SC_NAME)
                                    )
                                    (enumerate 0 (- (length rt-lst) 1))
                                )
                                []
                            )
                        )
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1 ico2 ico3 ico4] [])
        )
    )
    (defun URCi_Cull:object{IgnisCollectorV3.OutputCumulator}
        (culler:string ats:string)
        @doc "Cost preview for C_Cull: flat 2x-biggest construct + one transfer per \
            \ reward-token whose cumulative cull weight is nonzero. Cull weights are \
            \ derived purely via URC_MultiCull/URC_SingleCull (the same values the exec \
            \ XI_*Cull writers return), so this is output-exact, not just cost-equivalent."
        (let
            (
                (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (c0:[decimal] (at "summed-culled-values" (URC_MultiCull ats culler)))
                (c1:[decimal] (URC_SingleCull ats culler 1))
                (c2:[decimal] (URC_SingleCull ats culler 2))
                (c3:[decimal] (URC_SingleCull ats culler 3))
                (c4:[decimal] (URC_SingleCull ats culler 4))
                (c5:[decimal] (URC_SingleCull ats culler 5))
                (c6:[decimal] (URC_SingleCull ats culler 6))
                (c7:[decimal] (URC_SingleCull ats culler 7))
                (ca:[[decimal]] [c0 c1 c2 c3 c4 c5 c6 c7])
                (cw:[decimal] (ref-U|DEC::UC_AddHybridArray ca))
                ;;
                (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_Cull" "usage"))
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                )
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (map
                        (lambda (idx:integer)
                            (if (!= (at idx cw) 0.0)
                                (ref-TFT::URCi_Transfer (at idx rt-lst) ATS|SC_NAME culler (at idx cw))
                                EOC
                            )
                        )
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] cw)
        )
    )
    ;;
    (defun URCi_HotRecovery:object{IgnisCollectorV3.OutputCumulator}
        (recoverer:string ats:string ra:decimal)
        @doc "Cost preview for C_HotRecovery (flavor-B composer): fixed 3x-biggest \
            \ construct + cold-transfer + cold-burn + hot-mint + hot-transfer, re-derived \
            \ purely via sub-op cost readers. Cost-equivalent to C_HotRecovery."
        ;;THE PREVIEW NEEDS ITS OWN COPY OF THE GUARD, and that is the whole lesson of this repair.
        ;;C_HotRecovery was fixed by hoisting its capability above the binding group -- but this
        ;;reader has its OWN eager `let` with the same two lines, so a QUOTE for a pair with no
        ;;Hot-RBT still died with `No value found in table ouronet-ns.DPOF_DPOF|T|Properties for
        ;;key: |` after the exec path was clean. A preview is what a UI calls before it ever
        ;;submits; it must refuse in the SAME WORDS as the op it previews, not louder and not
        ;;differently. (URC_RBT carries its guard for exactly this reason -- it is shared by both
        ;;paths, so one enforce covered both. Here the two paths do not share a reader, so the
        ;;guard has to be written twice.)
        ;;Pinned by RedTeam/[RT-H]_InputDomain.repl <<RT-H-003f>>.
        ;;Own let for the modref: the guard must run BEFORE the main binding group, and Pact
        ;;evaluates every binding in a group before its body -- so it cannot live in the let below.
        ;;Cross-module calls go through the interface modref (`::`), never `module.function`.
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
            )
            ;;ORDER MATTERS FOR PARITY, not just for safety. ATS|C>HOT_RECOVERY checks the
            ;;toggle first and the Hot-RBT second; a preview that checked them the other way round
            ;;refused for a TRUE but DIFFERENT reason than the op would give, which is its own kind
            ;;of lie. Same guards, same order, same message.
            (ref-ATS::UEV_HotRecoveryState ats true)
            (enforce
                (ref-ATS::URC_IzPresentHotRBT ats)
                (format "ATS-Pair {} has no Hot-RBT, so Hot Recovery is impossible" [ats])
            )
        )
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (h-rbt:string (ref-ATS::UR_HotRewardBearingToken ats))
                (new-nonce:integer (+ (ref-DPOF::UR_NoncesUsed h-rbt) 1))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "ATS|C_HotRecovery" "usage")
                        ATS|SC_NAME
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        []
                    )
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt recoverer ATS|SC_NAME ra)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Burn c-rbt ATS|SC_NAME)
                )
                (ico4:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_Mint h-rbt)
                )
                (ico5:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_MoveCumulator h-rbt [new-nonce] false)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4 ico5] [])
        )
    )
    (defun URCi_Recover:object{IgnisCollectorV3.OutputCumulator}
        (recoverer:string id:string nonce:integer)
        @doc "Cost preview for C_Recover (flavor-B composer): DPOF nonce-transfer + \
            \ DPOF burn + cold-mint + cold-transfer, re-derived purely via sub-op cost \
            \ readers. Cost-equivalent to C_Recover."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ats:string (ref-DPOF::UR_RewardBearingToken id))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply id nonce))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_MoveCumulator id [nonce] false)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_Burn id)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt ATS|SC_NAME false)
                )
                (ico4:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt ATS|SC_NAME recoverer nonce-supply)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [])
        )
    )
    (defun URCi_Redeem:object{IgnisCollectorV3.OutputCumulator}
        (redeemer:string id:string nonce:integer)
        @doc "Cost preview for C_Redeem: DPOF nonce-transfer + DPOF burn + a \
            \ multi-transfer of the decay-earned reward-token split, plus (when a decay \
            \ fee is retained and not redirected) fee-leg burns. Re-derives the decay math \
            \ purely (same as exec); sub-op costs via URCi readers, no writes."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (precision:integer (ref-DPOF::UR_Decimals id))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply id nonce))
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData id nonce))
                (birth-date:time (at "mint-time" (at 0 meta-data-chain)))
                (present-time:time (at "block-time" (chain-data)))
                (elapsed-time:decimal (diff-time present-time birth-date))
                ;;
                (ats:string (ref-DPOF::UR_RewardBearingToken id))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (h-promile:decimal (ref-ATS::UR_HotRecoveryStartingFeePromile ats))
                (h-decay:integer (ref-ATS::UR_HotRecoveryDecayPeriod ats))
                (h-fr:bool (ref-ATS::UR_HotRecoveryFeeRedirection ats))
                (total-time:decimal (* 86400.0 (dec h-decay)))
                (earned-rbt:decimal
                    (if (>= elapsed-time total-time)
                        nonce-supply
                        (floor (* nonce-supply (/ (- 1000.0 (* h-promile (- 1.0 (/ elapsed-time total-time)))) 1000.0)) precision)
                    )
                )
                (earned-rts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats earned-rbt))
                (total-rts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats nonce-supply))
                (fee-rts:[decimal] (zip (lambda (x:decimal y:decimal) (- x y)) total-rts earned-rts))
                (have-fee-rts:bool (!= (fold (+) 0.0 fee-rts) 0.0))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_MoveCumulator id [nonce] false)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_Burn id)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_MultiTransferCumulator rt-lst ATS|SC_NAME redeemer earned-rts)
                )
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (if have-fee-rts
                        (map
                            (lambda (idx:integer)
                                (ref-DPTF::URCi_Burn (at idx rt-lst) ATS|SC_NAME)
                            )
                            (enumerate 0 (- (length rt-lst) 1))
                        )
                        [EOC]
                    )
                )
                (ico4:object{IgnisCollectorV3.OutputCumulator}
                    (if (and (not h-fr) (!= earned-rbt nonce-supply))
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                        EOC
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [])
        )
    )
    ;;
    (defun URCi_DirectRecovery:object{IgnisCollectorV3.OutputCumulator}
        (recoverer:string ats:string ra:decimal)
        @doc "Cost preview for C_DirectRecovery: cold-transfer + cold-burn + a \
            \ multi-transfer of the fee-adjusted reward-token split back to recoverer, \
            \ re-derived purely via sub-op cost readers."
        ;;The exec's OWN state guard, called rather than re-typed -- UEV_DirectRecoveryState is the very
        ;;function ATSU|C>DIRECT_RECOVERY uses, so the refusal is identical by construction and
        ;;cannot drift. It must precede the binding group below: Pact evaluates every binding in a
        ;;group before the body, and those bindings read state that does not exist for a pair in
        ;;this condition. Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-001f>>.
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-ATS::UEV_DirectRecoveryState ats true)
        )
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (fee:decimal (ref-ATS::UR_DirectRecoveryFee ats))
                (c-rbt-remainder:decimal
                    (if (= fee 0.0)
                        ra
                        (at 0 (ref-U|ATS::UC_PromilleSplit fee ra (ref-DPTF::UR_Decimals c-rbt)))
                    )
                )
                (reward-tokens:[string] (ref-ATS::UR_RewardTokenList ats))
                (release-amounts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats c-rbt-remainder))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt recoverer ATS|SC_NAME ra)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Burn c-rbt ATS|SC_NAME)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_MultiTransferCumulator reward-tokens ATS|SC_NAME recoverer release-amounts)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
        )
    )
    ;;
    (defun URCi_Syphon:object{IgnisCollectorV3.OutputCumulator}
        (syphon-target:string ats:string syphon-amounts:[decimal])
        @doc "Cost preview for C_Syphon: one transfer per reward-token whose \
            \ syphon-amount is > 0 (EOC for zero legs), mapped purely over the pool's \
            \ reward-token list. Cost-equivalent to C_Syphon."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (map
                        (lambda (idx:integer)
                            (if (> (at idx syphon-amounts) 0.0)
                                (ref-TFT::URCi_Transfer (at idx rt-lst) ATS|SC_NAME syphon-target (at idx syphon-amounts))
                                EOC
                            )
                        )
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
        )
    )
    (defun URCi_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string)
        @doc "Cost preview for CC_RemoveSecondary — pure re-derivation of its 3-leg concat: one \
            \ ignis|token-issue construct + two full-amount transfers (reward-token in to \
            \ remover, primal-rt out from remover), moving the combined resident+unbound+ \
            \ royalty balance at the removed reward-token position."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (remove-position:integer (at 0 (ref-U|LST::UC_Search rt-lst reward-token)))
                (primal-rt:string (at 0 rt-lst))
                (resident-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 1)))
                (unbound-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 2)))
                (royalty-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 3)))
                (remove-sum:decimal (+ (+ resident-sum unbound-sum) royalty-sum))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "ATS|CC_RemoveSecondary" "ats-secondary") ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (ref-TFT::URCi_Transfer reward-token ATS|SC_NAME remover remove-sum)
                    (ref-TFT::URCi_Transfer primal-rt remover ATS|SC_NAME remove-sum)
                ]
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_KickStart:object{IgnisCollectorV3.OutputCumulator}
        (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Shared write path for both the owner (C_KickStart) and administrative \
            \ (A_KickStart) entrypoints (audit finding #11M / M2 fix). All bound and \
            \ authorization checks live in the composed capability chain \
            \ (ATSU|C>X_KICKSTART plus each leaf) - nothing here enforces."
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (rbt-id:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                ;;
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                            (do
                                (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 true (at idx rt-amounts))
                                (ref-U|LST::UC_AppL acc
                                    (ref-TFT::C_Transfer (at idx rt-lst) kickstarter ATS|SC_NAME (at idx rt-amounts) true)
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                )
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::C_Mint patron ATS|SC_NAME rbt-id rbt-request-amount false)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::C_Transfer rbt-id ATS|SC_NAME kickstarter rbt-request-amount true)
                )
                (index:decimal (ref-ATS::URC_Index ats))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [index])
        )
    )
    ;;Protection: Class 3 — Custom: ATSU|C>DEPLOY
    (defun XI_DeployAccount (ats:string acc:string)
        (require-capability (ATSU|C>DEPLOY ats acc))
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-ATS::XE_SpawnAutostakeAccount ats acc)
            (XI_Normalize ats acc)
        )
    )
    ;;Protection: Class 3 — Custom: ATSU|C>NORMALIZE_LEDGER
    (defun XI_Normalize (ats:string acc:string)
        (require-capability (ATSU|C>NORMALIZE_LEDGER ats acc))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
                (p0:[object{UtilityAtsV3.Awo}] (ref-ATS::UR_P0 ats acc))
                (p1:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 1))
                (p2:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 2))
                (p3:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 3))
                (p4:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 4))
                (p5:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 5))
                (p6:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 6))
                (p7:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 7))
                (zr:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeZeroUnstakeObject ats))
                (ng:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeNegativeUnstakeObject ats))
                (positions:integer (ref-ATS::UR_ColdRecoveryPositions ats))
                (elite:bool (ref-ATS::UR_EliteMode ats))
                (major-tier:integer (ref-DALOS::UR_Elite-Tier-Major acc))
                ;;
                (p0-znn:[object{UtilityAtsV3.Awo}] (if (and (!= p0 [zr]) (!= p0 [ng])) p0 [ng]))
                (p0-znz:[object{UtilityAtsV3.Awo}] (if (and (!= p0 [zr]) (!= p0 [ng])) p0 [zr]))
                (p1-znn:object{UtilityAtsV3.Awo} (if (and (!= p1 zr) (!= p1 ng)) p1 ng))
                (p1-znz:object{UtilityAtsV3.Awo} (if (and (!= p1 zr) (!= p1 ng)) p1 zr))
                (p2-znn:object{UtilityAtsV3.Awo} (if (and (!= p2 zr) (!= p2 ng)) p2 ng))
                (p2-znz:object{UtilityAtsV3.Awo} (if (and (!= p2 zr) (!= p2 ng)) p2 zr))
                (p3-znn:object{UtilityAtsV3.Awo} (if (and (!= p3 zr) (!= p3 ng)) p3 ng))
                (p3-znz:object{UtilityAtsV3.Awo} (if (and (!= p3 zr) (!= p3 ng)) p3 zr))
                (p4-znn:object{UtilityAtsV3.Awo} (if (and (!= p4 zr) (!= p4 ng)) p4 ng))
                (p4-znz:object{UtilityAtsV3.Awo} (if (and (!= p4 zr) (!= p4 ng)) p4 zr))
                (p5-znn:object{UtilityAtsV3.Awo} (if (and (!= p5 zr) (!= p5 ng)) p5 ng))
                (p5-znz:object{UtilityAtsV3.Awo} (if (and (!= p5 zr) (!= p5 ng)) p5 zr))
                (p6-znn:object{UtilityAtsV3.Awo} (if (and (!= p6 zr) (!= p6 ng)) p6 ng))
                (p6-znz:object{UtilityAtsV3.Awo} (if (and (!= p6 zr) (!= p6 ng)) p6 zr))
                (p7-znn:object{UtilityAtsV3.Awo} (if (and (!= p7 zr) (!= p7 ng)) p7 ng))
                (p7-znz:object{UtilityAtsV3.Awo} (if (and (!= p7 zr) (!= p7 ng)) p7 zr))
                (p2-zne:object{UtilityAtsV3.Awo} (if (and (!= p2 zr) (!= p2 ng)) p2 (if (>= major-tier 2) zr ng)))
                (p3-zne:object{UtilityAtsV3.Awo} (if (and (!= p3 zr) (!= p3 ng)) p3 (if (>= major-tier 3) zr ng)))
                (p4-zne:object{UtilityAtsV3.Awo} (if (and (!= p4 zr) (!= p4 ng)) p4 (if (>= major-tier 4) zr ng)))
                (p5-zne:object{UtilityAtsV3.Awo} (if (and (!= p5 zr) (!= p5 ng)) p5 (if (>= major-tier 5) zr ng)))
                (p6-zne:object{UtilityAtsV3.Awo} (if (and (!= p6 zr) (!= p6 ng)) p6 (if (>= major-tier 6) zr ng)))
                (p7-zne:object{UtilityAtsV3.Awo} (if (and (!= p7 zr) (!= p7 ng)) p7 (if (>= major-tier 7) zr ng)))
                ;;
                (c-pm1:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znz [p1-znn] [p2-znn] [p3-znn] [p4-znn] [p5-znn] [p6-znn] [p7-znn]]))
                (c-p1:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znn] [p3-znn] [p4-znn] [p5-znn] [p6-znn] [p7-znn]]))
                (c-p2:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znn] [p4-znn] [p5-znn] [p6-znn] [p7-znn]]))
                (c-p3:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znz] [p4-znn] [p5-znn] [p6-znn] [p7-znn]]))
                (c-p4:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znz] [p4-znz] [p5-znn] [p6-znn] [p7-znn]]))
                (c-p5:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znz] [p4-znz] [p5-znz] [p6-znn] [p7-znn]]))
                (c-p6:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znz] [p4-znz] [p5-znz] [p6-znz] [p7-znn]]))
                (c-ne:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znz] [p4-znz] [p5-znz] [p6-znz] [p7-znz]]))
                (c-el:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-zne] [p3-zne] [p4-zne] [p5-zne] [p6-zne] [p7-zne]]))

            )
            (cond
                ((= positions -1) (XI_UUP ats acc c-pm1))
                ((= positions 1) (XI_UUP ats acc c-p1))
                ((= positions 2) (XI_UUP ats acc c-p2))
                ((= positions 3) (XI_UUP ats acc c-p3))
                ((= positions 4) (XI_UUP ats acc c-p4))
                ((= positions 5) (XI_UUP ats acc c-p5))
                ((= positions 6) (XI_UUP ats acc c-p6))
                ((not elite) (XI_UUP ats acc c-ne))
                (elite (XI_UUP ats acc c-el))
                true
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_UpP0, XE_UpP1, XE_UpP2, XE_UpP3,
    ;;Protection:          XE_UpP4, XE_UpP5, XE_UpP6, XE_UpP7
    (defun XI_UUP (ats:string acc:string data:[object{UtilityAtsV3.Awo}])
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-ATS::XE_UpP0 ats acc (drop -7 data))
            (ref-ATS::XE_UpP1 ats acc (at 0 (take 1 (take -7 data))))
            (ref-ATS::XE_UpP2 ats acc (at 0 (take 1 (take -6 data))))
            (ref-ATS::XE_UpP3 ats acc (at 0 (take 1 (take -5 data))))
            (ref-ATS::XE_UpP4 ats acc (at 0 (take 1 (take -4 data))))
            (ref-ATS::XE_UpP5 ats acc (at 0 (take 1 (take -3 data))))
            (ref-ATS::XE_UpP6 ats acc (at 0 (take 1 (take -2 data))))
            (ref-ATS::XE_UpP7 ats acc (at 0 (take -1 data)))
        )
    )
    ;;Enforce: read-and-write-in-one -- <size> is (length p0), and p0 is the list the write is built
    ;;          from. Relocating the bound means re-reading and re-measuring the same list.
    ;;Protection: Class 2 — SECURE
    (defun XIv_StoreUnstakeObject (ats:string acc:string position:integer obj:object{UtilityAtsV3.Awo})
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-ATS:module{AutostakeV3} ATS)
                (p0:[object{UtilityAtsV3.Awo}] (ref-ATS::UR_P0 ats acc))
                (size:integer (length p0))
            )
            
            (if (= position -1)
                (do
                    ;;UNTESTABLE-EXTERNALLY: XIv_StoreUnstakeObject sits behind (require-capability (SECURE)), and SECURE cannot be acquired from outside
                    ;;this module -- so no REPL negative test can reach this line. The guard is LIVE and
                    ;;does real work on the in-module path; it is NOT dead code. Distinguished from
                    ;;the UNREACHABLE marker deliberately: that marker means no input can trip the guard at all.
                    (enforce (< size 250) "Unstake Storage limited to 250 Elements. Cull your list to add more !")
                    (if (and
                            (= size 1)
                            (=
                                (at 0 p0)
                                (ref-ATS::UDC_MakeZeroUnstakeObject ats)
                            )
                        )
                        (ref-ATS::XE_UpP0 ats acc [obj])
                        (ref-ATS::XE_UpP0 ats acc (ref-U|LST::UC_AppL p0 obj))
                    )
                )
                
                (cond
                    ((= position 1) (ref-ATS::XE_UpP1 ats acc obj))
                    ((= position 2) (ref-ATS::XE_UpP2 ats acc obj))
                    ((= position 3) (ref-ATS::XE_UpP3 ats acc obj))
                    ((= position 4) (ref-ATS::XE_UpP4 ats acc obj))
                    ((= position 5) (ref-ATS::XE_UpP5 ats acc obj))
                    ((= position 6) (ref-ATS::XE_UpP6 ats acc obj))
                    ((= position 7) (ref-ATS::XE_UpP7 ats acc obj))
                    true
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_MultiCull:[decimal] (ats:string acc:string)
        (require-capability (SECURE))
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (multi-cull-obj:object (URC_MultiCull ats acc))
                (after-cull:[object{UtilityAtsV3.Awo}] (at "after-cull" multi-cull-obj))
                (culled-values:[[decimal]] (at "culled-values" multi-cull-obj))
                (summed-culled-values:[decimal] (at "summed-culled-values" multi-cull-obj))
            )
            (ref-ATS::XE_UpP0 ats acc after-cull)
            summed-culled-values
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XIv_StoreUnstakeObject
    (defun XI_SingleCull:[decimal] (ats:string acc:string position:integer)
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                ;;
                (cull-output:[decimal] (URC_SingleCull ats acc position))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (l:integer (length rt-lst))
                (empty:[decimal] (make-list l 0.0))
                (zr:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeZeroUnstakeObject ats))
            )
            (if (!= cull-output empty)
                (XIv_StoreUnstakeObject ats acc position zr)
                true
            )
            cull-output
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string)
        @doc "Fix (audit finding #1C / C2): (1) the account list to reshape is ALWAYS derived on-chain \
            \ here via <ATS.URH_ExistingAutostakePairs ats> — never trusted from a caller — so removal can \
            \ no longer skip an account and leave its stored positions desynced from the live reward-token \
            \ list (was C2b/C2c's root enabler). (2) the royalty bucket (RUR 3) is now migrated into the \
            \ primal RT exactly like resident/unbonding (RUR 1/2) — previously it was silently deleted with \
            \ the removed row and permanently stranded in ATS|SC_NAME custody with no reward-token entry \
            \ left to reference it (was C2b). <remove-sum> now covers all three buckets on both transfer \
            \ legs, preserving the existing 1:1 primal-RT buyout design without altering it."
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ats-sc:string (ref-ATS::GOV|ATS|SC_NAME))
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (remove-position:integer (at 0 (ref-U|LST::UC_Search rt-lst reward-token)))
                (primal-rt:string (at 0 rt-lst))
                (resident-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 1)))
                (unbound-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 2)))
                (royalty-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 3)))
                (remove-sum:decimal (+ (+ resident-sum unbound-sum) royalty-sum))
                ;; Complete, on-chain-derived account list — never trusted from a caller (fix #1C/C2).
                (accounts-with-ats-data:[string] (ref-ATS::URH_ExistingAutostakePairs ats))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "ATS|CC_RemoveSecondary" "ats-secondary")
                        ATS|SC_NAME
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        []
                    )
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::C_Transfer reward-token ATS|SC_NAME remover remove-sum true)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::C_Transfer primal-rt remover ATS|SC_NAME remove-sum true)
                )
            )
            ;;1]The RT to be removed, is transfered to the remover, from the ATS|SC_NAME
                ;via ico2
            ;;2]The amount removed (resident + unbonding + royalty) is added back as Primal-RT
                ;via ico3
            ;;3]ROU Table is updated with the new DATA, now as primal RT — all three buckets
            (ref-ATS::XE_UpdateRUR ats primal-rt 1 true resident-sum)
            (ref-ATS::XE_UpdateRUR ats primal-rt 2 true unbound-sum)
            (ref-ATS::XE_UpdateRUR ats primal-rt 3 true royalty-sum)
            ;;4]EVERY client account with ledger data for this pair is reshaped to remove the RT
                ;position and keep balances aligned with the post-removal reward-token list
            (map
                (lambda
                    (kontos:string)
                    (ref-ATS::XE_ReshapeUnstakeAccount ats kontos remove-position)
                )
                accounts-with-ats-data
            )
            ;;5]Actually Remove the RT from the ATS-Pair
            (ref-ATS::XE_RemoveSecondary ats reward-token)
            ;;6]Update Data in the DPTF Token Properties
            (ref-DPTF::XE_UpdateRewardToken ats reward-token false)
            ;;7]Output ICO
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun AA_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string accounts-with-ats-data:[string])
        @doc "Administrative Variant. Fix (audit finding #1C / C2b): <accounts-with-ats-data> is now \
            \ IGNORED — XI_RemoveSecondary always re-derives the complete account list on-chain via \
            \ <ATS.URH_ExistingAutostakePairs ats> itself, so a caller-supplied list can no longer be \
            \ incomplete/stale and silently desync some accounts' stored positions. The parameter is kept \
            \ only for interface-signature compatibility (AutostakeUsageV2 is unchanged); do not rely on \
            \ its contents."
        (P|UEV_IMC)
        (with-capability (ATSU|C>ADMINISTRATIVE-REMOVE-SECONDARY ats reward-token)
            (XI_RemoveSecondary remover ats reward-token)
        )
    )
    (defun A_KickStart:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Administrative variant (audit finding #11M / M2): forgoes pool ownership \
            \ for module governance (GOV|ATSU_ADMIN); resulting index is only bound by \
            \ the shared 0.1 floor, no ceiling - for legitimate ratios above 100.0."
        (P|UEV_IMC)
        (with-capability (ATSU|C>ADMINISTRATIVE-KICKSTART executor ats rt-amounts rbt-request-amount)
            (XI_KickStart patron executor ats rt-amounts rbt-request-amount)
        )
    )
    (defun CC_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string)
        @doc "Client Variant. XI_RemoveSecondary derives the complete account list itself via \
            \ <ATS.URH_ExistingAutostakePairs ats>."
        (P|UEV_IMC)
        (with-capability (ATSU|C>REMOVE-SECONDARY ats reward-token)
            (XI_RemoveSecondary remover ats reward-token)
        )
    )
    (defun C_WithdrawRoyalties:object{IgnisCollectorV3.OutputCumulator}
        (ats:string target:string)
        @doc "Fix (audit finding #33N): C_MultiTransfer debits every leg unconditionally - a \
            \ reward-token with a zero accrued royalty (routine whenever a pool has more than \
            \ one registered RT and royalty hasn't accrued evenly across all of them) hit \
            \ DPTF's UEV_Amount (amount > 0.0) enforce and crashed the whole withdrawal. Now \
            \ filters to only the reward-token/royalty legs with a real (> 0.0) balance before \
            \ handing off to C_MultiTransfer - the RUR-reset loop below still zeroes every RT's \
            \ bucket, zero or not, so no accounting is skipped, only the doomed zero-amount leg."
        (P|UEV_IMC)
        (with-capability (ATSU|C>WITHDRAW-ROYALTIES ats target)
            (let
                (
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (reward-tokens:[string] (ref-ATS::UR_RewardTokenList ats))
                    (royalties:[decimal] (ref-ATS::UR_RewardTokenRUR ats 3))
                    (nonzero-idx:[integer]
                        (filter
                            (lambda (index:integer) (> (at index royalties) 0.0))
                            (enumerate 0 (- (length reward-tokens) 1))
                        )
                    )
                )
                ;;1]Set Royalties Values back to 0.0 for all RTs
                (map
                    (lambda
                        (index:integer)
                        (ref-ATS::XE_UpdateRUR ats (at index reward-tokens) 3 false (at index royalties))
                    )
                    (enumerate 0 (- (length reward-tokens) 1))
                )
                ;;2]Withdraw Royalties to Target - only the reward-tokens with a nonzero balance
                (ref-TFT::C_MultiTransfer
                    (map (lambda (index:integer) (at index reward-tokens)) nonzero-idx)
                    ATS|SC_NAME
                    target
                    (map (lambda (index:integer) (at index royalties)) nonzero-idx)
                    true
                )
            )
        )
    )
    (defun C_KickStart:object{IgnisCollectorV3.OutputCumulator}
        (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Owner-facing variant. Fix (audit finding #11M / M2): resulting index now \
            \ bounded to [0.1, 100.0] via ATSU|C>KICKSTART / ATSU|C>X_KICKSTART."
        (P|UEV_IMC)
        (with-capability (ATSU|C>KICKSTART kickstarter ats rt-amounts rbt-request-amount)
            (XI_KickStart patron kickstarter ats rt-amounts rbt-request-amount)
        )
    )
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator}
        (fueler:string ats:string reward-token:string amount:decimal)
        @doc "Fuels an <ats> ATS-Pair, increasing it Index."
        (P|UEV_IMC)
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
            )
            (with-capability (ATSU|C>FUEL ats reward-token)
                (ref-ATS::XE_UpdateRUR ats reward-token 1 true amount)
                (ref-TFT::C_Transfer reward-token fueler ATS|SC_NAME amount true)
            )
        )
    )
    (defun C_Coil:object{IgnisCollectorV3.OutputCumulator}
        (patron:string coiler:string ats:string rt:string amount:decimal)
        @doc "Autostakes an <rt> Token on <ats> ATS-Pair. \
            \ If Hibernate is on, retains the <c-rbt-amount>, which will then be hibernated \
            \ from the TALOS module, and sent as Hibernated H| Token to the <coiler>"
        (P|UEV_IMC)
        (with-capability (ATSU|C>COIL ats rt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    ;;
                    ;;<ats>
                    (coil-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats rt amount)
                    )
                    (input-amount:decimal (at "first-input-amount" coil-data))
                    (royalty-fee:decimal (at "royalty-fee" coil-data))
                    (c-rbt:string (at "rbt-id" coil-data))
                    (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer rt coiler ATS|SC_NAME amount true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt c-rbt-amount false)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer c-rbt ATS|SC_NAME coiler c-rbt-amount true)
                    )
                )
                (ref-ATS::XE_UpdateRUR ats rt 1 true input-amount)
                (if (!= royalty-fee 0.0)
                    (ref-ATS::XE_UpdateRUR ats rt 3 true royalty-fee)
                    true
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [c-rbt-amount])
            )  
        )
    )
    (defun C_Curl:object{IgnisCollectorV3.OutputCumulator}
        (patron:string curler:string ats1:string ats2:string rt:string amount:decimal)
        @doc "Coils through 2 ATS-Pairs, outputting the <c-rbt2> to the <curler> \
            \ Both <ats1> and <ats2> must have <hibernation> off"
        (P|UEV_IMC)
        (with-capability (ATSU|C>CURL ats1 ats2 rt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    ;;
                    ;;<ats1>
                    (coil1-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                    )
                    (input1-amount:decimal (at "first-input-amount" coil1-data))
                    (royalty1-fee:decimal (at "royalty-fee" coil1-data))
                    (c-rbt1:string (at "rbt-id" coil1-data))
                    (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                    ;;
                    ;;<ats2>
                    (coil2-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats2 c-rbt1 c-rbt1-amount)
                    )
                    (input2-amount:decimal (at "first-input-amount" coil2-data))
                    (royalty2-fee:decimal (at "royalty-fee" coil2-data))
                    (c-rbt2:string (at "rbt-id" coil2-data))
                    (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer rt curler ATS|SC_NAME amount true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt1 c-rbt1-amount false)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt2 c-rbt2-amount false)
                    )
                    (ico4:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer c-rbt2 ATS|SC_NAME curler c-rbt2-amount true)
                    )
                )
                (ref-ATS::XE_UpdateRUR ats1 rt 1 true input1-amount)
                (ref-ATS::XE_UpdateRUR ats2 c-rbt1 1 true input2-amount)
                (if (!= royalty1-fee 0.0)
                    (ref-ATS::XE_UpdateRUR ats1 rt 3 true royalty1-fee)
                    true
                )
                (if (!= royalty2-fee 0.0)
                    (ref-ATS::XE_UpdateRUR ats2 c-rbt1 3 true royalty2-fee)
                    true
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [c-rbt2-amount])
            )
        )
    )
    (defun C_ColdRecovery:object{IgnisCollectorV3.OutputCumulator}
        (patron:string recoverer:string ats:string ra:decimal)
        (P|UEV_IMC)
        (with-capability (ATSU|C>DEPLOY ats recoverer)
            (XI_DeployAccount ats recoverer)
            (let
                (
                    (ref-ATS:module{AutostakeV3} ATS)
                    (usable-cold-recovery-position:integer (ref-ATS::URC_WhichPosition ats ra recoverer))
                )
                (enforce (!= usable-cold-recovery-position 0) "Cold Recovery Unavailable! All existing Positions are used!")
                (with-capability (ATSU|C>COLD_RECOVERY recoverer ats ra usable-cold-recovery-position)
                    (let
                        (
                            (ref-U|LST:module{StringProcessorV2} U|LST)
                            (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                            (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (ref-TFT:module{TrueFungibleTransferV2} TFT)
                            ;;
                            (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                            (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                            (c-rbt-precision:integer (ref-DPTF::UR_Decimals c-rbt))
                            (fee-promile:decimal (ref-ATS::URCv_ColdRecoveryFee ats ra usable-cold-recovery-position))
                            (c-rbt-fee-split:[decimal] (ref-U|ATS::UC_PromilleSplit fee-promile ra c-rbt-precision))
                            (c-rbt-remainder:decimal (at 0 c-rbt-fee-split))
                            (c-rbt-fee:decimal (at 1 c-rbt-fee-split))
                            ;;
                            (positive-c-fr:[decimal]
                                ;;For true <c-fr>
                                ;:Remainder
                                (ref-ATS::URCv_RTSplitAmounts ats c-rbt-remainder)
                            )
                            (ng-c-fr:[decimal]
                                ;For false <c-fre>
                                ;Fee-Part
                                (ref-ATS::URCv_RTSplitAmounts ats c-rbt-fee)
                            )
                            ;;
                            (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_ColdRecovery" "usage"))
                            (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                            ;;

                            (ico0:object{IgnisCollectorV3.OutputCumulator}
                                ;;10 Flat IGNIS cost for Cold Recovery
                                (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME trigger [])
                            )
                            (ico1:object{IgnisCollectorV3.OutputCumulator}
                                (ref-TFT::C_Transfer c-rbt recoverer ATS|SC_NAME ra true)
                            )
                            (ico2:object{IgnisCollectorV3.OutputCumulator}
                                (ref-DPTF::C_Burn patron ATS|SC_NAME c-rbt ra)
                            )
                            ;;
                            (c-fr:bool (ref-ATS::UR_ColdRecoveryFeeRedirection ats))
                            (cull-time:time (ref-ATS::URC_CullColdRecoveryTime ats recoverer))
                            ;;
                            (ico3:object{IgnisCollectorV3.OutputCumulator}
                                (if (!= usable-cold-recovery-position -1)
                                    EOC
                                    (URCi_UnlimitedUncoilCumulator ats recoverer)
                                )
                            )
                            (ico4:object{IgnisCollectorV3.OutputCumulator}
                                ;;Handle the Fee Part
                                (if (= c-rbt-fee 0.0)
                                    EOC
                                    (if c-fr
                                        EOC
                                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                            (fold
                                                (lambda
                                                    (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                                    (do
                                                        (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 false (at idx ng-c-fr))
                                                        (ref-U|LST::UC_AppL acc 
                                                            (ref-DPTF::C_Burn patron ATS|SC_NAME (at idx rt-lst) (at idx ng-c-fr))
                                                        )
                                                    )
                                                )
                                                []
                                                (enumerate 0 (- (length rt-lst) 1))
                                            )
                                            []
                                        )
                                    )
                                )
                            )
                        )
                        ;;Handle The Remainder
                        (map
                            (lambda
                                (index:integer)
                                (ref-ATS::XE_UpdateRUR ats (at index rt-lst) 2 true (at index positive-c-fr))
                                (ref-ATS::XE_UpdateRUR ats (at index rt-lst) 1 false (at index positive-c-fr))
                            )
                            (enumerate 0 (- (length rt-lst) 1))
                        )
                        (XIv_StoreUnstakeObject ats recoverer usable-cold-recovery-position
                            { "reward-tokens"   : positive-c-fr
                            , "cull-time"       : cull-time}
                        )
                        (XI_Normalize ats recoverer)
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1 ico2 ico3 ico4] [])
                    )
                )
            )
        )
    )
    (defun C_Cull:object{IgnisCollectorV3.OutputCumulator}
        (culler:string ats:string)
        (P|UEV_IMC)
        (with-capability (ATSU|C>CULL culler ats)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                    (c0:[decimal] (XI_MultiCull ats culler))
                    (c1:[decimal] (XI_SingleCull ats culler 1))
                    (c2:[decimal] (XI_SingleCull ats culler 2))
                    (c3:[decimal] (XI_SingleCull ats culler 3))
                    (c4:[decimal] (XI_SingleCull ats culler 4))
                    (c5:[decimal] (XI_SingleCull ats culler 5))
                    (c6:[decimal] (XI_SingleCull ats culler 6))
                    (c7:[decimal] (XI_SingleCull ats culler 7))
                    (ca:[[decimal]] [c0 c1 c2 c3 c4 c5 c6 c7])
                    (cw:[decimal] (ref-U|DEC::UC_AddHybridArray ca))
                    ;;
                    (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_Cull" "usage"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME trigger [])
                    )
                    (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                        (fold
                            (lambda
                                (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                (ref-U|LST::UC_AppL acc
                                    (if (!= (at idx cw) 0.0)
                                        (do
                                            (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 2 false (at idx cw))
                                            (ref-TFT::C_Transfer (at idx rt-lst) ATS|SC_NAME culler (at idx cw) true)
                                        )
                                        EOC
                                    )
                                )
                            )
                            []
                            (enumerate 0 (- (length rt-lst) 1))
                        )
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                    )
                )
                (XI_Normalize ats culler)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] cw)
            )
        )
    )
    (defun C_HotRecovery:object{IgnisCollectorV3.OutputCumulator}
        (patron:string recoverer:string ats:string ra:decimal)
        (P|UEV_IMC)
        ;;THE CAPABILITY IS ACQUIRED BEFORE THE `let`, and that ordering is load-bearing -- the same
        ;;repair C_Recover received on 2026-09-12, for the same reason, twenty lines below.
        ;;`UR_HotRewardBearingToken` returns the BAR sentinel for a pair with no Hot-RBT (nine of
        ;;the fifteen live pairs), and the `new-nonce` binding then read the DPOF properties table
        ;;keyed by "|", dying with `No value found in table ouronet-ns.DPOF_DPOF|T|Properties for
        ;;key: |` before any guard in ATS|C>HOT_RECOVERY could run. All three cap arguments are
        ;;plain defun parameters, so hoisting costs nothing and is the shape StoicSyntax asks for:
        ;;validation in the defcap, work in the body.
        ;;Pinned by RedTeam/[RT-H]_InputDomain.repl <<RT-H-003c>>/<<RT-H-003e>>.
        (with-capability (ATS|C>HOT_RECOVERY recoverer ats ra)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (h-rbt:string (ref-ATS::UR_HotRewardBearingToken ats))
                (present-time:time (at "block-time" (chain-data)))
                (meta-data-obj:object{AutostakeV3.ATS|Hot} {"mint-time" : present-time})
                (new-nonce:integer (+ (ref-DPOF::UR_NoncesUsed h-rbt) 1))
                ;;
            )
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-IGNIS::UDC_ConstructOutputCumulator 
                                (ref-IGNIS::UC_IgnisPrice "ATS|C_HotRecovery" "usage")
                                ATS|SC_NAME
                                (ref-IGNIS::URC_IsVirtualGasZero)
                                []
                            )
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer c-rbt recoverer ATS|SC_NAME ra true)
                        )
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPTF::C_Burn patron ATS|SC_NAME c-rbt ra)
                        )
                        (ico4:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Mint h-rbt ATS|SC_NAME ra [meta-data-obj])
                        )
                        (ico5:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Transfer h-rbt [new-nonce] ATS|SC_NAME recoverer true)
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4 ico5] [])
                )
        )
        )
    )
    (defun C_Recover:object{IgnisCollectorV3.OutputCumulator}
        (patron:string recoverer:string id:string nonce:integer)
        (P|UEV_IMC)
        ;;THE CAPABILITY IS ACQUIRED BEFORE THE `let`, and that ordering is load-bearing.
        ;;FIXED 2026-09-12: it used to sit INSIDE the let body, so the eager binding group ran first
        ;;-- and for a token that is not reward-bearing `UR_RewardBearingToken` returns the BAR
        ;;sentinel, so the next binding looked up ATS pair `|` and died with
        ;;`No value found in table ouronet-ns.ATS_ATS|Pairs for key: |`. The cap's own
        ;;`(enforce iz-rbt "Invalid Hot-RBT")` -- written for exactly that input -- was never reached.
        ;;Both cap arguments are plain defun parameters, so hoisting costs nothing, and it is also the
        ;;shape StoicSyntax asks for: validation in the defcap, work in the body.
        (with-capability (ATS|C>RECOVER recoverer id nonce)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ats:string (ref-DPOF::UR_RewardBearingToken id))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply id nonce))
            )
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Transfer id [nonce] recoverer ATS|SC_NAME true)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Burn id ATS|SC_NAME nonce nonce-supply)
                        )
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt nonce-supply false)
                        )
                        (ico4:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer c-rbt ATS|SC_NAME recoverer nonce-supply true)
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [])
                )
            )
        )
    )
    (defun C_Redeem:object{IgnisCollectorV3.OutputCumulator}
        (patron:string redeemer:string id:string nonce:integer)
        (P|UEV_IMC)
        ;;CAPABILITY BEFORE THE `let` -- same fix as C_Recover above, same cause.
        ;;FIXED 2026-09-12: it used to sit inside the let body, and the eager binding group reads
        ;;`(ats (UR_RewardBearingToken id))` then immediately `(rt-lst (UR_RewardTokenList ats))`.
        ;;For a token that is not reward-bearing `ats` is the BAR sentinel, so that second read looks
        ;;up ATS pair `|` and aborts before the cap can raise its own "Invalid Hot-RBT". Both cap
        ;;arguments are plain defun parameters, so the hoist is free.
        (with-capability (ATSU|C>REDEEM redeemer id)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (precision:integer (ref-DPOF::UR_Decimals id))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply id nonce))
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData id nonce))
                ;;
                (birth-date:time (at "mint-time" (at 0 meta-data-chain)))
                (present-time:time (at "block-time" (chain-data)))
                (elapsed-time:decimal (diff-time present-time birth-date))
                ;;
                (ats:string (ref-DPOF::UR_RewardBearingToken id))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (h-promile:decimal (ref-ATS::UR_HotRecoveryStartingFeePromile ats))
                (h-decay:integer (ref-ATS::UR_HotRecoveryDecayPeriod ats))
                (h-fr:bool (ref-ATS::UR_HotRecoveryFeeRedirection ats))
                ;;
                (total-time:decimal (* 86400.0 (dec h-decay)))
                (end-time:time (add-time birth-date (hours (* 24 h-decay))))
                (earned-rbt:decimal
                    (if (>= elapsed-time total-time)
                        nonce-supply
                        (floor (* nonce-supply (/ (- 1000.0 (* h-promile (- 1.0 (/ elapsed-time total-time)))) 1000.0)) precision)
                    )
                )
                (total-rts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats nonce-supply))
                (earned-rts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats earned-rbt))
                (fee-rts:[decimal] (zip (lambda (x:decimal y:decimal) (- x y)) total-rts earned-rts))
                (are-fee-rts:decimal (fold (+) 0.0 fee-rts))
                ;; Fix (audit finding #3C / C3): `are-fee-rts` is a summed :decimal fee amount, not a
                ;; predicate — feeding it straight into `if` (which requires :bool) made every call to
                ;; C_Redeem revert unconditionally, regardless of input (confirmed: Pact does not coerce
                ;; a decimal to bool either way, 0.0 included). `have-fee-rts` is the real boolean gate:
                ;; true only when the decay fee actually took a nonzero slice off the redemption.
                (have-fee-rts:bool (!= are-fee-rts 0.0))
            )
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Transfer id [nonce] redeemer ATS|SC_NAME true)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Burn id ATS|SC_NAME nonce nonce-supply)
                        )
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_MultiTransfer rt-lst ATS|SC_NAME redeemer earned-rts true)
                        )
                        (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                            (if have-fee-rts
                                (fold
                                    (lambda
                                        (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                        (do
                                            (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 false (at idx fee-rts))
                                            (ref-U|LST::UC_AppL acc
                                                (ref-DPTF::C_Burn patron ATS|SC_NAME (at idx rt-lst) (at idx fee-rts))
                                            )
                                        )
                                    )
                                    []
                                    (enumerate 0 (- (length rt-lst) 1))
                                )
                                [EOC]
                            )
                        )
                        (ico4:object{IgnisCollectorV3.OutputCumulator}
                            (if (and (not h-fr) (!= earned-rbt nonce-supply))
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                                EOC
                            )
                        )
                    )
                    (map
                        (lambda
                            (idx:integer)
                            (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 false (at idx earned-rts))
                        )
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [])
                )
            )
        )
    )
    (defun C_DirectRecovery:object{IgnisCollectorV3.OutputCumulator}
        (patron:string recoverer:string ats:string ra:decimal)
        (P|UEV_IMC)
        (with-capability (ATS|C>DIRECT_RECOVERY recoverer ats ra)
            (let
                (
                    (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                    (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                    (fee:decimal (ref-ATS::UR_DirectRecoveryFee ats))
                    (c-rbt-remainder:decimal
                        (if (= fee 0.0)
                            ra
                            (at 0 (ref-U|ATS::UC_PromilleSplit fee ra (ref-DPTF::UR_Decimals c-rbt)))
                        )
                    )
                    (reward-tokens:[string] (ref-ATS::UR_RewardTokenList ats))
                    (release-amounts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats c-rbt-remainder))
                )
                ;;0]Update ATS Data
                (map
                    (lambda
                        (index:integer)
                        (ref-ATS::XE_UpdateRUR ats (at index rt-lst) 1 false (at index release-amounts))
                    )
                    (enumerate 0 (- (length reward-tokens) 1))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [
                        ;;1]Transfer c-rbt to ATS|SC_NAME
                        (ref-TFT::C_Transfer c-rbt recoverer ATS|SC_NAME ra true)
                        ;;2]Burn it
                        (ref-DPTF::C_Burn patron ATS|SC_NAME c-rbt ra)
                        ;;3]Release equivalnet RTs (minus fee)
                        (ref-TFT::C_MultiTransfer reward-tokens ATS|SC_NAME recoverer release-amounts true)
                    ] 
                    []
                )
            )
        )
    )
    (defun C_Syphon:object{IgnisCollectorV3.OutputCumulator}
        (syphon-target:string ats:string syphon-amounts:[decimal])
        (P|UEV_IMC)
        (with-capability (ATSU|C>SYPHON ats syphon-amounts)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                    (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                        (fold
                            (lambda
                                (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                (ref-U|LST::UC_AppL acc
                                    (if (> (at idx syphon-amounts) 0.0)
                                        (do
                                            (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 false (at idx syphon-amounts))
                                            (ref-TFT::C_Transfer (at idx rt-lst) ATS|SC_NAME syphon-target (at idx syphon-amounts) true)
                                        )
                                        EOC
                                    )

                                )
                            )
                            []
                            (enumerate 0 (- (length rt-lst) 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
            )
        )
    )

)

;; --- tables for 10_ATSU.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)


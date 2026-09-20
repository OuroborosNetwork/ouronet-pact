;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 11 of 20
;; This is STEP 11 of 21 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-10 must have run first, including the init steps between deploys.
;; 5 module(s), 320,565 gas measured in the REPL gas model, 249,160 bytes
;;
;; Modules in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/08_DPDC-S.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/09_DPDC-F.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/10_DPDC-N.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/08_DPDC-S.pact ==========
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcSetsV2
    @doc "Exposes Collectables Set related Functions"

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
    ;;  [UR]
    ;;
    (defun UR_Set:object{DpdcUdcV2.DPDC|Set} (id:string son:bool set-class:integer))
    (defun URC_SetExists:bool (id:string son:bool set-class:integer))
    (defun UR_SetClass:integer (id:string son:bool set-class:integer))
    (defun UR_SetName:string (id:string son:bool set-class:integer))
    (defun UR_SetMultiplier:decimal (id:string son:bool set-class:integer))
    (defun UR_NonceOfSet:integer (id:string set-class:integer))
    (defun UR_IzSetActive:bool (id:string son:bool set-class:integer))
    (defun UR_IzSetPrimordial:bool (id:string son:bool set-class:integer))
    (defun UR_IzSetComposite:bool (id:string son:bool set-class:integer))
    (defun UR_PSD:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] (id:string son:bool set-class:integer))
    (defun UR_CSD:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] (id:string son:bool set-class:integer))
    (defun UR_SetNonceData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool set-class:integer))
    (defun UR_SetSplitData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool set-class:integer))
    ;;
    ;;  [URC]
    ;;
    ;; URC_N|Score renamed from UR_N|Score — DPDC Audit #19H follow-up: it reads UR_NonceClass/
    ;; UR_N|RawScore/UR_SetMultiplier and derives a computed "cooked" value from them (sentinel
    ;; check, multiply, fragment-divide), which is the URC_* ("read + derive") contract, not a
    ;; plain UR_* table read. Zero callers anywhere, so the rename touches no call site.
    (defun URC_N|Score:decimal (id:string son:bool nonce:integer))
    (defun URC_PrimordialOrComposite:[bool] (id:string son:bool set-class:integer))
    (defun URC_NoncesSummedScore:decimal (id:string son:bool nonces:[integer]))
    (defun URC_SemiFungibleConstituents:[integer] (id:string set-class:integer))
    (defun URCv_NonFungibleConstituents:[integer] (id:string nonce:integer))
        ;;  [URCi] cost readers — single source per op
    (defun URCi_MakeSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator} (account:string id:string nonces:[integer] how-many-sets:integer))
    (defun URCi_BreakSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator} (account:string id:string nonce:integer how-many-sets:integer))
    (defun URCi_MakeNonFungibleSet:object{IgnisCollectorV3.OutputCumulator} (account:string id:string nonces:[integer]))
    (defun URCi_BreakNonFungibleSet:object{IgnisCollectorV3.OutputCumulator} (account:string id:string nonce:integer))
    (defun URCi_DefinePrimordialSet:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_DefineCompositeSet:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_DefineHybridSet:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_EnableSetClassFragmentation:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleSet:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_RenameSet:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
        ;;
    (defun UEV_PrimordialSetDefinition (id:string son:bool set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]))
    (defun UEV_PrimordialSetElement (son:bool element:object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}))
    (defun UEV_CompositeSetDefinition (id:string son:bool set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]))
    (defun UEV_SetClass (id:string son:bool set-class:integer))
    (defun UEV_IzSetClassFragmented:bool (id:string son:bool set-class:integer))
    (defun UEV_Fragmentation (id:string son:bool set-class:integer))
    (defun UEV_SetActiveState (id:string son:bool set-class:integer state:bool))
        ;;
    (defun UEV_NoncesForSetClass (id:string son:bool nonces:[integer] set-class:integer))
    (defun UEV_Primordial (nonces:[integer] psd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]))
    (defun UEV_Composite (id:string son:bool nonces:[integer] csd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;; C_UpdateSetMultiplier removed — DPDC Audit #15H: score-multiplier is now immutable after Define,
    ;; matching the Set-Class recipe's own immutability. A wrong multiplier means disabling that
    ;; Set-Class and defining a new one, same recovery path as a wrong recipe.
    ;;
    (defun XB_U|NonceOrSplitData (id:string son:bool set-class:integer nos:bool nd:object{DpdcUdcV2.DPDC|NonceData}))
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_MakeSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator} (account:string id:string nonces:[integer] set-class:integer how-many-sets:integer))
    (defun CC_BreakSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator} (account:string id:string nonce:integer how-many-sets:integer))
    (defun C_MakeNonFungibleSet:object{IgnisCollectorV3.OutputCumulator} (account:string id:string nonces:[integer] set-class:integer))
    (defun C_BreakNonFungibleSet:object{IgnisCollectorV3.OutputCumulator} (account:string id:string nonce:integer))
        ;;
    (defun C_DefinePrimordialSet:object{IgnisCollectorV3.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun C_DefineCompositeSet:object{IgnisCollectorV3.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun C_DefineHybridSet:object{IgnisCollectorV3.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun C_EnableSetClassFragmentation:object{IgnisCollectorV3.OutputCumulator}
        (
            id:string son:bool set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun C_ToggleSet:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool set-class:integer toggle:bool))
    (defun C_RenameSet:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool set-class:integer new-name:string))

)
;;
(module DPDC-S GOV
    @doc "DPDC-S is the Sets module of the DPDC collectables family, managing groups of \
        \ nonces composed into higher-order set-classes. It stores set definitions in \
        \ DPSF/DPNF SetsTables (Primordial, Composite, or Hybrid, each with a \
        \ score-multiplier). Owners define set-classes via \
        \ C_DefinePrimordialSet/C_DefineCompositeSet/C_DefineHybridSet and can enable \
        \ fragmentation, toggle and rename them. Users compose and decompose via \
        \ C_MakeSemiFungibleSet/CC_BreakSemiFungibleSet (SFT, quantity) and \
        \ C_MakeNonFungibleSet/C_BreakNonFungibleSet (NFT, minting/burning a set nonce whose \
        \ score sums its constituents)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcSetsV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-S                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-S_ADMIN)))
    (defcap GOV|DPDC-S_ADMIN ()                         (enforce-guard GOV|MD_DPDC-S))
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
    (defcap P|DPDC-S|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-S|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DPDC-S|REMOTE-GOV ()
        @doc "DPDC Remote Governor Capability"
        true
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
        (with-capability (GOV|DPDC-S_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|DPDC-S_ADMIN)
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
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (mg:guard (create-capability-guard (P|DPDC-S|CALLER)))
            )
            (ref-P|DPDC::P|A_Add
                "DPDC-S|RemoteDpdcGov"
                (create-capability-guard (P|DPDC-S|REMOTE-GOV))
            )
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;;list previously crashed with an opaque out-of-bounds error, since (enumerate 0 -1) returns [0 -1],
    ;;not [] -- see UEV_PrimordialSetDefinition/UEV_CompositeSetDefinition) and at most this many, so an
    ;;unreasonably large definition can't push Make/Break gas past the practical ceiling and permanently
    ;;brick that set-class for its owner.
    (defconst MAX_SET_DEFINITION_SIZE 20)
    ;;{3.2}  schemas
    ;;{3.3}  tables
    ;;
    (deftable DPSF|SetsTable:{DpdcUdcV2.DPDC|Set})                ;;Key = <DPSF-id> + BAR + <set-class>
    ;;
    (deftable DPNF|SetsTable:{DpdcUdcV2.DPDC|Set})                ;;Key = <DPNF-id> + BAR + <set-class>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap DPDC-S|C>MAKE (id:string son:bool nonces:[integer] set-class:integer how-many-sets:integer)
        @event
        ;;G-44 FIX (2026-09-17). This guard is ABOVE the let deliberately. <iz-active> binds
        ;;UR_IzSetActive, which funnels to UR_Set's bare <read>, and Pact evaluates let bindings
        ;;before the body -- so a set-class that does not exist aborted on the raw table key and the
        ;;"is not active" enforce below could never speak for it. Measured at 0 and at 99.
        (enforce (URC_SetExists id son set-class)
            (format "Set-Class {} does not exist for this DPDC" [set-class]))
        (let
            (
                (iz-active:bool (UR_IzSetActive id son set-class))
            )
            (enforce iz-active (format "Set-Class {} is not active for Set Composition" [set-class]))
            (enforce (> how-many-sets 0) "How-Many-Sets must be a positive, non-zero integer")
            (UEV_NoncesForSetClass id son nonces set-class)
            (compose-capability (P|DPDC-S|CALLER))
            (compose-capability (P|DPDC-S|REMOTE-GOV))
        )
    )
    (defcap DPDC-S|C>BREAK (id:string son:bool nonce:integer how-many-sets:integer)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (nonce-class:integer (ref-DPDC::UR_NonceClass id son nonce))
            )
            ;;Nonces of Inactive Sets can still be broken down.
            (enforce (!= nonce-class 0) "Only Class Non-0 Nonces can be broken Down")
            (enforce (> how-many-sets 0) "How-Many-Sets must be a positive, non-zero integer")
            (compose-capability (P|DPDC-S|CALLER))
            (compose-capability (P|DPDC-S|REMOTE-GOV))
        )
    )
    (defcap DPDC-S|C>DEFINE-PRIMORDIAL
        (
            id:string son:bool score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @event
        (UEV_PrimordialSetDefinition id son set-definition)
        (UEV_ScoreMultiplier score-multiplier)     ;; DPDC Audit #15H
        (compose-capability (DPDC-S|CX>DEFINE id son ind))
    )
    (defcap DPDC-S|C>DEFINE-COMPOSITE
        (
            id:string son:bool score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @event
        (UEV_CompositeSetDefinition id son set-definition)
        (UEV_ScoreMultiplier score-multiplier)     ;; DPDC Audit #15H
        (compose-capability (DPDC-S|CX>DEFINE id son ind))
    )
    (defcap DPDC-S|C>DEFINE-HYBRID
        (
            id:string son:bool score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @event
        (UEV_PrimordialSetDefinition id son primordial-sd)
        (UEV_CompositeSetDefinition id son composite-sd)
        (UEV_ScoreMultiplier score-multiplier)     ;; DPDC Audit #15H
        (compose-capability (DPDC-S|CX>DEFINE id son ind))
    )
    (defcap DPDC-S|CX>DEFINE (id:string son:bool ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
            )
            (ref-DPDC::CAP_Owner id son)
            (ref-DPDC-C::UEV_NonceDataForCreation ind)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap DPDC-S|C>ENABLE-FRAGMENTATION
        (
            id:string son:bool set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (iz-fragmented:bool (UEV_IzSetClassFragmented id son set-class))
            )
            (enforce (not iz-fragmented) "Set Class must not be fragmented in order to enable fragmentation for it !")
            (UEV_SetClass id son set-class)
            ;;DPDC Audit #30M: require the set-class be active, consistent with its C>TOGGLE/C>RENAME
            ;;siblings — this was the only one of the owner-gated set mutations that skipped the check.
            (UEV_SetActiveState id son set-class true)
            (ref-DPDC::CAP_Owner id son)
            (ref-DPDC-C::UEV_NonceDataForCreation fragmentation-ind)
            (compose-capability (SECURE))
        )
    )
    (defcap DPDC-S|C>TOGGLE (id:string son:bool set-class:integer toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (UEV_SetActiveState id son set-class (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (SECURE))
        )
    )
    (defcap DPDC-S|C>RENAME (id:string son:bool set-class:integer new-name:string)
        @event
        ;;G-45 FIX (2026-09-17). RENAME had NO set-class domain guard: <current-name> binds
        ;;UR_SetName, the same bare read, so both a nonexistent class and the 1-based off-by-one 0
        ;;surfaced a raw table key rather than any sentence this module contains.
        (enforce (URC_SetExists id son set-class)
            (format "Set-Class {} does not exist for this DPDC" [set-class]))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (current-name:string (UR_SetName id son set-class))
            )
            (enforce (!= new-name current-name) (format "The Set Name of <{}> must be different from the current name of <{}> for operation" [new-name current-name]))
            (UEV_SetActiveState id son set-class true)
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (SECURE))
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
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;{5.2}  Compute [UC]
    ;; DPDC-S|C>MULTIPLIER removed — DPDC Audit #15H: score-multiplier is immutable after Define.
    ;;
    (defun UC_FirstNoncesFromPSD:[integer] (psd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}])
        @doc "Returns a list of Nonces that composed the PSD, only works for SFTs, \
            \ since the 1st Nonce of the <allowed-nonces> is used"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (let
                        (
                            (element:object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition} (at idx psd))
                            (allowed-nonces:[integer] (at "allowed-nonces" element))
                            (first-allowed-nonce:integer (at 0 allowed-nonces))
                        )
                        (ref-U|LST::UC_AppL acc first-allowed-nonce)
                    )
                )
                []
                (enumerate 0 (- (length psd) 1))
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;  [6] - [Set]
    (defun UR_Set:object{DpdcUdcV2.DPDC|Set} (id:string son:bool set-class:integer)
        (if son
            (read DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]))
            (read DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]))
        )
    )

    (defun URC_SetExists:bool (id:string son:bool set-class:integer)
        @doc "True when the <set-class> row exists for <id>. TOTAL: answers FALSE for a missing \
            \ row instead of aborting. UR_Set cannot do this -- it is a bare <read>, and every \
            \ set reader funnels through it, so a set-class that does not exist dies in the \
            \ reader before any guard written for it can speak. Set classes are 1-BASED, which \
            \ makes 0 the likeliest caller error and puts it squarely in that mute case. \
            \ Added 2026-09-17 for DEFECT-LEDGER G-44/G-45; URC_TripletExists is the precedent."
        (let
            (
                (k:string (concat [id BAR (format "{}" [set-class])]))
            )
            (if son
                (with-default-read DPSF|SetsTable k
                    { "set-name" : BAR } { "set-name" := sn } (!= sn BAR))
                (with-default-read DPNF|SetsTable k
                    { "set-name" : BAR } { "set-name" := sn } (!= sn BAR))
            )
        )
    )
    (defun UR_SetClass:integer (id:string son:bool set-class:integer)
        (at "set-class" (UR_Set id son set-class))
    )
    (defun UR_SetName:string (id:string son:bool set-class:integer)
        (at "set-name" (UR_Set id son set-class))
    )
    (defun UR_SetMultiplier:decimal (id:string son:bool set-class:integer)
        (at "set-score-multiplier" (UR_Set id son set-class))
    )
    (defun UR_NonceOfSet:integer (id:string set-class:integer)
        (at "nonce-of-set" (UR_Set id true set-class))
    )
    (defun UR_IzSetActive:bool (id:string son:bool set-class:integer)
        (at "iz-active" (UR_Set id son set-class))
    )
    (defun UR_IzSetPrimordial:bool (id:string son:bool set-class:integer)
        (at "iz-primordial" (UR_Set id son set-class))
    )
    (defun UR_IzSetComposite:bool (id:string son:bool set-class:integer)
        (at "iz-composite" (UR_Set id son set-class))
    )
    (defun UR_PSD:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
        (id:string son:bool set-class:integer)
        (at "primordial-set-definition" (UR_Set id son set-class))
    )
    (defun UR_CSD:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] 
        (id:string son:bool set-class:integer)
        (at "composite-set-definition" (UR_Set id son set-class))
    )
    (defun UR_SetNonceData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool set-class:integer)
        (at "nonce-data" (UR_Set id son set-class))
    )
    (defun UR_SetSplitData:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool set-class:integer)
        (at "split-data" (UR_Set id son set-class))
    )
    ;;Score Read for Nonce — renamed from UR_N|Score, DPDC Audit #19H follow-up: reads
    ;;UR_NonceClass/UR_N|RawScore/UR_SetMultiplier and derives a computed value from them
    ;;(sentinel check, multiply, fragment-divide) — the URC_* contract, not a plain UR_* read.
    (defun URC_N|Score:decimal (id:string son:bool nonce:integer)
        @doc "Cooked score reader: applies the Set-Class multiplier (for Set-member nonces) and the \
            \ 1/1000 fragment split (for negative/fragment nonces) to a nonce's raw stored score. \
            \ DPDC Audit #19H: the -1.0 <unscored> sentinel is now checked once, on the untouched raw \
            \ value, before any multiply/divide — the previous per-branch checks either omitted the \
            \ check entirely (fragment arms) or compared against the wrong constant (-1000.0 instead \
            \ of -1.0, a copy-paste leftover), letting the sentinel leak through as a real negative \
            \ score in 3 of the 4 branches."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (nonce-class:integer (ref-DPDC::UR_NonceClass id son nonce))
                (raw-nonce-score:decimal (ref-DPDC::UR_N|RawScore (ref-DPDC::UR_NativeNonceData id son (abs nonce))))
            )
            (if (= raw-nonce-score -1.0)
                0.0
                (if (= nonce-class 0)
                    (if (< nonce 0)
                        (/ raw-nonce-score 1000.0)
                        raw-nonce-score
                    )
                    (let
                        (
                            (multiplier:decimal (UR_SetMultiplier id son nonce-class))
                            (multiplied-score:decimal (* raw-nonce-score multiplier))
                        )
                        (if (< nonce 0)
                            (/ multiplied-score 1000.0)
                            multiplied-score
                        )
                    )
                )
            )
        )
    )
    ;:Requires rethinking
    (defun URC_PrimordialOrComposite:[bool] (id:string son:bool set-class:integer)
        (UEV_SetClass id son set-class)
        [
            (UR_IzSetPrimordial id son set-class)
            (UR_IzSetComposite id son set-class)
        ]
    )
    (defun URC_NoncesSummedScore:decimal (id:string son:bool nonces:[integer])
        @doc "Bakes a new NFT set instance's own raw score from the RAW (unmultiplied) scores of its \
            \ constituent nonces -- deliberately via UR_N|RawScore, not the multiplier-applying \
            \ URC_N|Score. DPDC Audit #52L: confirmed intentional design, owner-verified against real \
            \ mainnet Bloodshed set-NFT scores. A set-class's own score-multiplier is meant to apply \
            \ exactly once, at that set's own level, when ITS score is later read (via URC_N|Score) -- \
            \ not per-constituent here at Make-time. For a Composite/Hybrid set whose constituent is \
            \ itself a previously-Made, already-multiplied set instance from another set-class, this \
            \ correctly sums that constituent's pre-multiplier raw value, so multipliers don't compound \
            \ across nested sets."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (summed-score:decimal
                    (fold
                        (lambda
                            (acc:decimal idx:integer)
                            (+ acc (ref-DPDC::UR_N|RawScore (ref-DPDC::UR_NativeNonceData id son (at idx nonces))))
                        )
                        0.0
                        (enumerate 0 (- (length nonces) 1))
                    )
                )
            )
            (if (< summed-score 0.0)
                0.0
                summed-score
            )
        )
    )
    ;;
    (defun URC_SemiFungibleConstituents:[integer] (id:string set-class:integer)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (psd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] (UR_PSD id true set-class))
                (csd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] (UR_CSD id true set-class))
                (npsd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] (ref-DPDC-UDC::UDC_NoPrimordialSet))
                (ncsd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] (ref-DPDC-UDC::UDC_NoCompositeSet))
                (l-psd:integer
                    (if (= psd npsd)
                        0
                        (length psd)
                    )
                )
                (l-csd:integer
                    (if (= csd ncsd)
                        0
                        (length csd)
                    )
                )
            )
            (if (= l-psd 0)
                ;;Composite Set
                (URH_NonceListFromCSD id csd)
                (if (= l-csd 0)
                    ;;Primordial Set
                    (UC_FirstNoncesFromPSD psd)
                    ;;Hybrid Set — DPDC Audit #32M: order must be [primordial..., composite...], matching
                    ;;the Make-time convention in UEV_NoncesForSetClass's hybrid branch below (which does
                    ;;(take l-psd nonces) for primordial, (drop l-psd nonces) for composite). The two were
                    ;;previously reversed relative to each other — harmless today only because every leg
                    ;;gets the same uniform <how-many-sets> scalar, but a future non-uniform per-position
                    ;;quantity would silently misattribute between legs. Keep both in this same order.
                    (+ (UC_FirstNoncesFromPSD psd) (URH_NonceListFromCSD id csd))
                )
            )
        )
    )
    (defun URH_NonceListFromCSD:[integer] (id:string csd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}])
        @doc "Returns a list of Nonces that composed the CSD, only works for SFTs \
            \ since SFTs save the Nonce of the Set Class"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (let
                        (
                            (element:object{DpdcUdcV2.DPDC|AllowedClassForSetPosition} (at idx csd))
                            (allowed-sclass:integer (at "allowed-sclass" element))
                            (nonce-of-set:integer (UR_NonceOfSet id allowed-sclass))
                        )
                        (ref-U|LST::UC_AppL acc nonce-of-set)
                    )
                )
                []
                (enumerate 0 (- (length csd) 1))
            )
        )
    )
    (defun URCv_NonFungibleConstituents:[integer] (id:string nonce:integer)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (nonce-class:integer (ref-DPDC::UR_NonceClass id false nonce))
            )
            (enforce (!= nonce-class 0) "Invalid NFT Nonce to Read Constituents")
            (ref-DPDC::UR_N|Composition (ref-DPDC::UR_NativeNonceData id false nonce))
        )
    )
    ;;
    ;;
    (defun URCi_MakeSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonces:[integer] how-many-sets:integer)
        @doc "Cost preview for C_MakeSemiFungibleSet: only the account->DPDC set-element transfer \
            \ is billed (the XB_CreditSFT-Nonce write's cumulator is discarded). Purely derived."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
            )
            (ref-DPDC-T::URCi_MultiTransferCumulator
                [id] [true] account dpdc [nonces] [(make-list (length nonces) how-many-sets)])
        )
    )
    (defun URCi_BreakSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonce:integer how-many-sets:integer)
        @doc "Cost preview for CC_BreakSemiFungibleSet: account->DPDC set transfer + DPDC->account \
            \ constituents release (the XE_DebitSFT-Nonce burn is discarded). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (constituents:[integer]
                    (URC_SemiFungibleConstituents id (ref-DPDC::UR_NonceClass id true nonce)))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] account dpdc [[nonce]] [[how-many-sets]])
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] dpdc account [constituents] [(make-list (length constituents) how-many-sets)])
                ]
                []
            )
        )
    )
    (defun URCi_MakeNonFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonces:[integer])
        @doc "Cost preview for C_MakeNonFungibleSet: account->DPDC transfer + creation of the new \
            \ set nonce + DPDC->account transfer of that new nonce. Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [false] account dpdc [nonces] [(make-list (length nonces) 1)])
                    (ref-DPDC-C::URCi_CreateNewNonces id false [1])
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [false] dpdc account [[(+ 1 (ref-DPDC::UR_NoncesUsed id false))]] [[1]])
                ]
                []
            )
        )
    )
    (defun URCi_BreakNonFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonce:integer)
        @doc "Cost preview for C_BreakNonFungibleSet: account->DPDC transfer + DPDC->account \
            \ constituents release (the XE_DebitNFT-Nonce burn is discarded). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (constituents:[integer] (URCv_NonFungibleConstituents id nonce))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [false] account dpdc [[nonce]] [[1]])
                    (ref-DPDC-T::URCi_MultiTransferCumulator [id] [false] dpdc account [constituents] [(make-list (length constituents) 1)])
                ]
                []
            )
        )
    )
    ;;
    (defun URCi_DefinePrimordialSet:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_DefinePrimordialSet (same shape for Composite/Hybrid): the base \
            \ token-issue IGNIS price on the creator + (for SFT sets) the zero-supply set-nonce \
            \ creation; NFT sets add no nonce cost (EOC). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (creator:string (ref-DPDC::UR_CreatorKonto id son))
                (price:decimal (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_DefinePrimordialSet" "define-set")
                                (ref-IGNIS::UC_IgnisPrice "DPNF|C_DefinePrimordialSet" "define-set")))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    (if son
                        (ref-DPDC-C::URCi_CreateNewNonces id son [0])
                        EOC
                    )
                ]
                []
            )
        )
    )
    (defun URCi_DefineCompositeSet:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_DefineCompositeSet: identical cost shape to \
            \ URCi_DefinePrimordialSet."
        (URCi_DefinePrimordialSet id son)
    )
    (defun URCi_DefineHybridSet:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_DefineHybridSet: the same SHAPE as URCi_DefinePrimordialSet -- base \
            \ token-issue price on the creator + (SFT only) the zero-supply set-nonce creation, the NFT \
            \ XE_DeployAccountWNE leg being a free write -- but NOT the same PRICE. \
            \ PRICE-KEY FIX (2026-09-14): this delegated to URCi_DefinePrimordialSet, which reads the \
            \ <DP*|C_DefinePrimordialSet> key at 43.0, while C_DefineHybridSet bills its own \
            \ <DP*|C_DefineHybridSet> key at 45.0 (02_IGNIS.pact:682/764). The preview therefore \
            \ under-quoted a hybrid set-class definition by 2.0 raw IGNIS on BOTH fungibility sides. \
            \ Composite really is 43.0, so that sibling's delegation stays correct -- which is exactly \
            \ why only this one drifted and why the old @doc's claim of an identical cost read as true. \
            \ Measured against a real charge by modules/DPDC-S.repl <<DPDC-S-I27>> and <<DPDC-S-I33>>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (creator:string (ref-DPDC::UR_CreatorKonto id son))
                (price:decimal (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_DefineHybridSet" "define-set")
                                (ref-IGNIS::UC_IgnisPrice "DPNF|C_DefineHybridSet" "define-set")))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    (if son
                        (ref-DPDC-C::URCi_CreateNewNonces id son [0])
                        EOC
                    )
                ]
                []
            )
        )
    )
    (defun URCi_EnableSetClassFragmentation:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_EnableSetClassFragmentation: the biggest IGNIS cumulator on the \
            \ set creator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_EnableSetClassFragmentation" "setup")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_EnableSetClassFragmentation" "setup"))
                (ref-DPDC::UR_CreatorKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleSet:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleSet: the biggest IGNIS cumulator on the set creator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_ToggleSet" "setup")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_ToggleSet" "setup"))
                (ref-DPDC::UR_CreatorKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_RenameSet:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_RenameSet: the small IGNIS cumulator on the set creator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_RenameSet" "setup")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_RenameSet" "setup"))
                (ref-DPDC::UR_CreatorKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_PrimordialSetDefinition (id:string son:bool set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}])
        ;;DPDC Audit #51L: reject empty/oversized definitions with a clear message before any
        ;;enumerate-based fold runs (an empty list would otherwise crash with an opaque
        ;;out-of-bounds error several lines below).
        (enforce
            (and (> (length set-definition) 0) (<= (length set-definition) MAX_SET_DEFINITION_SIZE))
            (format "Set-Definition length must be between 1 and {} positions" [MAX_SET_DEFINITION_SIZE])
        )
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (nonces-used-in-set-definition:[integer]
                    (fold
                        (lambda
                            (acc:[integer] idx:integer)
                            (+ acc (at "allowed-nonces" (at idx set-definition)))
                        )
                        []
                        (enumerate 0 (- (length set-definition) 1))
                    )
                )
                (nu:integer (ref-DPDC::UR_NoncesUsed id son))
            )
            ;;DPDC Audit #31M: check every individual allowed-nonce value, not just the running max of
            ;;the whole list (the old (<= max nu) check let an out-of-range negative "fragment" value
            ;;hide behind any legitimately-small value elsewhere in the same definition, since a large
            ;;negative number is always <= a small positive max). A value is only plausible if it
            ;;references an existing native nonce (positive, 1..nu) or a fragment encoding of one
            ;;(negative, magnitude 1..nu) -- 0 is never valid either way.
            (enforce
                (fold (and) true
                    (map
                        (lambda (n:integer) (and (> (abs n) 0) (<= (abs n) nu)))
                        nonces-used-in-set-definition
                    )
                )
                (format "Invalid Set-Definition for a Primordial Set: every allowed-nonce must reference \
                    \ an existing native nonce (magnitude 1-{}) or its fragment encoding" [nu])
            )
            (map
                (lambda
                    (idx:integer)
                    (UEV_PrimordialSetElement son (at idx set-definition))
                )
                (enumerate 0 (- (length set-definition) 1))
            )
        )
    )
    (defun UEV_PrimordialSetElement (son:bool element:object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition})
        (let
            (
                (allowed-nonces:[integer] (at "allowed-nonces" element))
                (size:integer (length allowed-nonces))
            )
            (if son
                (enforce (= size 1) "SFT Set Elements must have only 1 allowed element")
                (enforce (> size 1) "NFT Set Elements must have more than 1 allowed element")
            )
        )
    )
    (defun UEV_CompositeSetDefinition (id:string son:bool set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}])
        ;;DPDC Audit #51L: same empty/oversized-definition guard as UEV_PrimordialSetDefinition above.
        (enforce
            (and (> (length set-definition) 0) (<= (length set-definition) MAX_SET_DEFINITION_SIZE))
            (format "Set-Definition length must be between 1 and {} positions" [MAX_SET_DEFINITION_SIZE])
        )
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DPDC:module{DpdcV2} DPDC)
                (set-classes-used-in-set-definition:[integer]
                    (fold
                        (lambda
                            (acc:[integer] idx:integer)
                            (+ acc [(at "allowed-sclass" (at idx set-definition))])
                        )
                        []
                        (enumerate 0 (- (length set-definition) 1))
                    )
                )
                (max:integer (ref-U|INT::UEV_MaxInteger (distinct set-classes-used-in-set-definition)))
                (scu:integer (ref-DPDC::UR_SetClassesUsed id son))
            )
            (enforce
                (fold (and) true (map (lambda (sc:integer) (> sc 0)) set-classes-used-in-set-definition))
                "Invalid Set-Definition: allowed-sclass must be greater than 0 for every position (0 is reserved)"
            )
            (enforce (<= max scu) "Invalid Set-Definition for a Composite Set with non existent Set-Classes")
        )
    )
    (defun UEV_SetClass (id:string son:bool set-class:integer)
        @doc "Validates <set-class> for the given DPDC id. \
            \ SHADOWED-GUARD FIX: the domain guard used to sit INSIDE the let, below the \
            \ <UR_SetClass> binding. Pact evaluates let bindings before the body, and \
            \ UR_Set does a HARD read keyed by <set-class> - so any out-of-domain value \
            \ aborted on 'row not found' and this enforce was unreachable for every input. \
            \ Hoisted above the let, matching UEV_IzSetClassFragmented directly below."
        (enforce (> set-class 0) "Invalid Set-Class Value")
        (let
            (
                (sc:integer (UR_SetClass id son set-class))
            )
            ;;Data-integrity assertion, not an input guard: <sc> is the set-class FIELD of the row
            ;;keyed BY set-class, so this can only fire on a corrupt row. Fail-closed by design.
            ;;UNREACHABLE: no argument can trip it. For any EXISTING row the two values are equal
            ;;by construction (the row is keyed by the field it is compared against), and for a
            ;;non-existent row UR_SetClass hard-reads and aborts on "row not found" before this
            ;;enforce runs. The only way to fire it is to corrupt the table, which no caller can
            ;;do. Worth keeping — it fails closed if a migration ever writes a mismatched row —
            ;;but it is not coverage.
            (enforce (= set-class sc) "Invalid DPDC Set Data")
        )
    )
    (defun UEV_IzSetClassFragmented:bool (id:string son:bool set-class:integer)
        (enforce (> set-class 0) "Only greater than 0 set-classes can be checked for fragmentation")
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (sd:object{DpdcUdcV2.DPDC|NonceData} (UR_SetSplitData id son set-class))
                (zd:object{DpdcUdcV2.DPDC|NonceData} (ref-DPDC-UDC::UDC_ZeroNonceData))
            )
            (if (!= sd zd) true false)
        )
    )
    (defun UEV_Fragmentation (id:string son:bool set-class:integer)
        (let
            (
                (iz-fragmented:bool (UEV_IzSetClassFragmented id son set-class))
            )
            (enforce iz-fragmented "Set-Class must be fragmented for operation")
        )
    )
    (defun UEV_SetActiveState (id:string son:bool set-class:integer state:bool)
        (let
            (
                (x:bool (UR_IzSetActive id son set-class))
            )
            (enforce (= x state) (format "Set Class {} of {} ID {} must be set to {} for operation" [set-class (if son "SFT" "NFT") id state]))
        )
    )
    (defun UEV_ScoreMultiplier (new-multiplier:decimal)
        @doc "Bounds a Set-Class score-multiplier: max 3 decimals precision (unchanged from the \
            \ original Update-time check), and a [1.0, 100.0] magnitude range — a multiplier can \
            \ boost a score (up to 100x) or leave it unchanged (1.0, the neutral no-op value), but \
            \ never reduce it below the raw score — to prevent an unbounded, instantly-retroactive \
            \ re-pricing of every outstanding member of the Set-Class. Enforced only at Define \
            \ (Primordial/Composite/Hybrid) — score-multiplier is immutable thereafter, see #15H \
            \ follow-up (Fix #14). See DPDC Audit #15H."
        (enforce
            (= (floor new-multiplier 3) new-multiplier)
            (format "Input Set-Multiplier of {} is not conform with its designed precision of only 3 decimals" [new-multiplier])
        )
        (enforce
            (and (>= new-multiplier 1.0) (<= new-multiplier 100.0))
            (format "Set-Multiplier of {} must be between 1.0 and 100.0 inclusive" [new-multiplier])
        )
    )
    ;;
    (defun UEV_NoncesForSetClass (id:string son:bool nonces:[integer] set-class:integer)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (psd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] (UR_PSD id son set-class))
                (csd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] (UR_CSD id son set-class))
                (npsd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] (ref-DPDC-UDC::UDC_NoPrimordialSet))
                (ncsd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] (ref-DPDC-UDC::UDC_NoCompositeSet))
                (l-psd:integer
                    (if (= psd npsd)
                        0
                        (length psd)
                    )
                )
                (l-csd:integer
                    (if (= csd ncsd)
                        0
                        (length csd)
                    )
                )
                (tl:integer (+ l-psd l-csd))
                (nl:integer (length nonces))
            )
            (enforce (= tl nl) (format "Nonces list {} are invalid for making a Set of Class {}" [nonces set-class]))
            (if (= l-psd 0)
                ;;Composite Set
                (UEV_Composite id son nonces csd)
                (if (= l-csd 0)
                    ;;Primordial Set
                    (UEV_Primordial nonces psd)
                    ;;Hybrid Set — expects <nonces> ordered [primordial..., composite...]. DPDC Audit
                    ;;#32M: URC_SemiFungibleConstituents's hybrid branch (Break-time reconstruction,
                    ;;above in [F1]) must keep the same ordering convention if either function's order
                    ;;ever changes.
                    (do
                        (UEV_Primordial (take l-psd nonces) psd)
                        (UEV_Composite id son (drop l-psd nonces) csd)
                    )
                )
            )
        )
    )
    (defun UEV_Primordial (nonces:[integer] psd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}])
        (let
            (
                (l1:integer (length nonces))
                (l2:integer (length psd))
            )
            (enforce (= l1 l2) "Incompatible Input for <UEV_Composite> Validation")
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (set-element:object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition} (at idx psd))
                            (allowed-nonces:[integer] (at "allowed-nonces" set-element))
                            (nonce:integer (at idx nonces))
                            (iz-nonce-allowed:bool (contains nonce allowed-nonces))
                        )
                        (enforce iz-nonce-allowed (format "Nonce {} not compatible with Set-Element {} for Set Definition" [nonce set-element]))
                    )
                )
                (enumerate 0 (- (length psd) 1))
            )
        )
    )
    (defun UEV_Composite (id:string son:bool nonces:[integer] csd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}])
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (l1:integer (length nonces))
                (l2:integer (length csd))
            )
            (enforce (= l1 l2) "Incompatible Input for <UEV_Composite> Validation")
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (set-element:object{DpdcUdcV2.DPDC|AllowedClassForSetPosition} (at idx csd))
                            (allowed-sclass:integer (at "allowed-sclass" set-element))
                            (nonce:integer (at idx nonces))
                            (nonce-class:integer (ref-DPDC::UR_NonceClass id son nonce))
                            (iz-nonce-allowed:bool (= nonce-class allowed-sclass))
                        )
                        (enforce iz-nonce-allowed (format "Nonce {} not compatible with Set-Element {} for Set Definition" [nonce set-element]))
                    )
                )
                (enumerate 0 (- (length csd) 1))
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;; C_UpdateSetMultiplier removed — DPDC Audit #15H.
    ;;Protection: Class 3 — Custom: DPDC-S|C>DEFINE-PRIMORDIAL
    (defun XI_PrimordialSet:integer
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (require-capability (DPDC-S|C>DEFINE-PRIMORDIAL id son score-multiplier set-definition ind))
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (set-classes-used:integer (ref-DPDC::UR_SetClassesUsed id son))
                (set-class:integer (+ set-classes-used 1))
                (nonces-used:integer (ref-DPDC::UR_NoncesUsed id son))
                (nonce-of-set:integer
                    (if son
                        (+ nonces-used 1)
                        0
                    )
                )
            )
            (XI_I|CollectionSet id son set-class
                (ref-DPDC-UDC::UDC_DPDC|Set
                    set-class
                    set-name
                    score-multiplier
                    nonce-of-set
                    true
                    true
                    false
                    set-definition
                    (ref-DPDC-UDC::UDC_NoCompositeSet)
                    ind
                    (ref-DPDC-UDC::UDC_ZeroNonceData)
                )
            )
            (ref-DPDC::XE_U|SetClassesUsed id son set-class)
            set-class
        )
    )
    ;;Protection: Class 3 — Custom: DPDC-S|C>DEFINE-COMPOSITE
    (defun XI_CompositeSet:integer
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (require-capability (DPDC-S|C>DEFINE-COMPOSITE id son score-multiplier set-definition ind))
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (set-classes-used:integer (ref-DPDC::UR_SetClassesUsed id son))
                (set-class:integer (+ set-classes-used 1))
                (nonces-used:integer (ref-DPDC::UR_NoncesUsed id son))
                (nonce-of-set:integer
                    (if son
                        (+ nonces-used 1)
                        0
                    )
                )
            )
            (XI_I|CollectionSet id son set-class
                (ref-DPDC-UDC::UDC_DPDC|Set
                    set-class
                    set-name
                    score-multiplier
                    nonce-of-set
                    true
                    false
                    true
                    (ref-DPDC-UDC::UDC_NoPrimordialSet)
                    set-definition
                    ind
                    (ref-DPDC-UDC::UDC_ZeroNonceData)
                )
            )
            (ref-DPDC::XE_U|SetClassesUsed id son set-class)
            set-class
        )
    )
    ;;Protection: Class 3 — Custom: DPDC-S|C>DEFINE-HYBRID
    (defun XI_HybridSet:integer
        (
            id:string son:bool set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (require-capability (DPDC-S|C>DEFINE-HYBRID id son score-multiplier primordial-sd composite-sd ind))
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (set-classes-used:integer (ref-DPDC::UR_SetClassesUsed id son))
                (set-class:integer (+ set-classes-used 1))
                (nonces-used:integer (ref-DPDC::UR_NoncesUsed id son))
                (nonce-of-set:integer
                    (if son
                        (+ nonces-used 1)
                        0
                    )
                )
            )
            (XI_I|CollectionSet id son set-class
                (ref-DPDC-UDC::UDC_DPDC|Set
                    set-class
                    set-name
                    score-multiplier
                    nonce-of-set
                    true
                    true
                    true
                    primordial-sd
                    composite-sd
                    ind
                    (ref-DPDC-UDC::UDC_ZeroNonceData)
                )
            )
            (ref-DPDC::XE_U|SetClassesUsed id son set-class)
            set-class
        )
    )
    ;;Protection: Class 3 — Custom: DPDC-S|C>ENABLE-FRAGMENTATION
    (defun XI_FragmentSetClass
        (id:string son:bool set-class:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        (require-capability (DPDC-S|C>ENABLE-FRAGMENTATION id son set-class fragmentation-ind))
        (XB_U|NonceOrSplitData id son set-class false fragmentation-ind)
    )
    ;;Protection: Class 3 — Custom: DPDC-S|C>TOGGLE
    (defun XI_ToggleSetClass (id:string son:bool set-class:integer toggle:bool)
        (require-capability (DPDC-S|C>TOGGLE id son set-class toggle))
        (XI_U|IzActive id son set-class toggle)
    )
    ;;Protection: Class 3 — Custom: DPDC-S|C>RENAME
    (defun XI_RenameSet (id:string son:bool set-class:integer new-name:string)
        (require-capability (DPDC-S|C>RENAME id son set-class new-name))
        (XI_U|SetName id son set-class new-name)
    )
    ;; XI_Multiplier removed — DPDC Audit #15H.
    ;;
    ;; [<SetsTable> Writings] [3]
    ;;Protection: Class 2 — SECURE
    (defun XI_I|CollectionSet (id:string son:bool set-class:integer set:object{DpdcUdcV2.DPDC|Set})
        (require-capability (SECURE))
        (if son
            (insert DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) set)
            (insert DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) set)
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_U|NonceOrSplitData (id:string son:bool set-class:integer nos:bool nd:object{DpdcUdcV2.DPDC|NonceData})
        ;;(require-capability (SECURE))
        (P|UEV_IMC)
        (if nos
            (if son
                (update DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"nonce-data" : nd})
                (update DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"nonce-data" : nd})
            )
            (if son
                (update DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"split-data" : nd})
                (update DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"split-data" : nd})
            )
        )  
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|IzActive (id:string son:bool set-class:integer toggle:bool)
        (require-capability (SECURE))
        (if son
            (update DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"iz-active" : toggle})
            (update DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"iz-active" : toggle})
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|SetName (id:string son:bool set-class:integer new-name:string)
        (require-capability (SECURE))
        (if son
            (update DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"set-name" : new-name})
            (update DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"set-name" : new-name})
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_MakeSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonces:[integer] set-class:integer how-many-sets:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool true)
            )
            (with-capability (DPDC-S|C>MAKE id son nonces set-class how-many-sets)
                ;;1]SFT Set Nonce is already created with the Set Definition,
                ;;it only needs a quantity of <how-many-sets> to be added to target <account>
                (ref-DPDC-C::XB_CreditSFT-Nonce account id (UR_NonceOfSet id set-class) how-many-sets)
                ;;2]Transfer <nonces> to <dpdc> last to return the cumulator.
                (ref-DPDC-T::C_Transfer [id] [son] account dpdc [nonces] [(make-list (length nonces) how-many-sets)] true)
            )
        )
    )
    (defun CC_BreakSemiFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonce:integer how-many-sets:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool true)
            )
            (with-capability (DPDC-S|C>BREAK id son nonce how-many-sets)
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            ;;1]Transfer the SFT Sets from <account> to <dpdc>
                            (ref-DPDC-T::C_Transfer [id] [son] account dpdc [[nonce]] [[how-many-sets]] true)
                        )
                        (constituents:[integer]
                            (URC_SemiFungibleConstituents id (ref-DPDC::UR_NonceClass id son nonce))
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            ;;2]Release the Set Elements from <dpdc> to <account>
                            (ref-DPDC-T::C_Transfer [id] [son] dpdc account [constituents] [(make-list (length constituents) how-many-sets)] true)
                        )
                    )
                    ;;3]Burn the Input SFT Set Nonces
                    (ref-DPDC-C::XE_DebitSFT-Nonce dpdc id nonce how-many-sets false)
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] [])
                )
            )
        )
    )
    (defun C_MakeNonFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonces:[integer] set-class:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool false)
            )
            (with-capability (DPDC-S|C>MAKE id son nonces set-class 1)
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            ;;1]Transfer <nonces> to <dpdc>
                            (ref-DPDC-T::C_Transfer [id] [son] account dpdc [nonces] [(make-list (length nonces) 1)] true)
                        )
                        ;;
                        (set-nd:object{DpdcUdcV2.DPDC|NonceData} (UR_SetNonceData id son set-class))
                        (summed-score:decimal (URC_NoncesSummedScore id son nonces))
                        (spawned-nonce-md:object{DpdcUdcV2.NonceMetaData}
                            (ref-DPDC-UDC::UDC_NonceMetaData
                                summed-score
                                nonces
                                {}
                                )
                        )
                        (spawned-nd:object{DpdcUdcV2.DPDC|NonceData}
                            (+
                                {"meta-data" : spawned-nonce-md}
                                (remove "meta-data" set-nd)
                            )
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            ;;2]When one nonce of class non-0 is created, is automatically created on <dpdc> account
                            (ref-DPDC-C::C_CreateNewNonce id son set-class 1 spawned-nd true)
                        )
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            ;;3]Transfer new set nonce to <account>
                            (ref-DPDC-T::C_Transfer [id] [son] dpdc account [[(ref-DPDC::UR_NoncesUsed id son)]] [[1]] true)
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
                )
            )
        )
    )
    (defun C_BreakNonFungibleSet:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string nonce:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool false)
            )
            (with-capability (DPDC-S|C>BREAK id son nonce 1)
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            ;;1]Transfer the SFT|NFT from <account> to <dpdc>
                            (ref-DPDC-T::C_Transfer [id] [son] account dpdc [[nonce]] [[1]] true)
                        )
                        (constituents:[integer]
                            (URCv_NonFungibleConstituents id nonce)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            ;;2]Release the Set Elements from <dpdc> to <account>
                            (ref-DPDC-T::C_Transfer [id] [son] dpdc account [constituents] [(make-list (length constituents) 1)] true)
                        )
                    )
                    ;;3]Burn the Input SFT Set Nonces
                    (ref-DPDC-C::XE_DebitNFT-Nonce dpdc id nonce 1 false)
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] [])
                )
            )
        )
    )
    (defun C_DefinePrimordialSet:object{IgnisCollectorV3.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (P|UEV_IMC)
        (with-capability (DPDC-S|C>DEFINE-PRIMORDIAL id son score-multiplier set-definition ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    ;;
                    (creator:string (ref-DPDC::UR_CreatorKonto id son))
                    (price:decimal (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_DefinePrimordialSet" "define-set")
                                (ref-IGNIS::UC_IgnisPrice "DPNF|C_DefinePrimordialSet" "define-set")))
                    (set-class:integer (XI_PrimordialSet id son set-name score-multiplier set-definition ind))
                    (ico0:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    )
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (if son
                            (ref-DPDC-C::C_CreateNewNonce id son set-class 0 ind true)
                            EOC
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [])
            )
        )
    )
    (defun C_DefineCompositeSet:object{IgnisCollectorV3.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (P|UEV_IMC)
        (with-capability (DPDC-S|C>DEFINE-COMPOSITE id son score-multiplier set-definition ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    ;;
                    (creator:string (ref-DPDC::UR_CreatorKonto id son))
                    (price:decimal (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_DefineCompositeSet" "define-set")
                                (ref-IGNIS::UC_IgnisPrice "DPNF|C_DefineCompositeSet" "define-set")))
                    (set-class:integer (XI_CompositeSet id son set-name score-multiplier set-definition ind))
                    (ico0:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    )
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (if son
                            (ref-DPDC-C::C_CreateNewNonce id son set-class 0 ind true)
                            EOC
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [])
            )
        )
    )
    (defun C_DefineHybridSet:object{IgnisCollectorV3.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (P|UEV_IMC)
        (with-capability (DPDC-S|C>DEFINE-HYBRID id son score-multiplier primordial-sd composite-sd ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (creator:string (ref-DPDC::UR_CreatorKonto id son))
                    (price:decimal (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_DefineHybridSet" "define-set")
                                (ref-IGNIS::UC_IgnisPrice "DPNF|C_DefineHybridSet" "define-set")))
                    (set-class:integer (XI_HybridSet id son set-name score-multiplier primordial-sd composite-sd ind))
                    (ico0:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    )
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (if son
                            (ref-DPDC-C::C_CreateNewNonce id son set-class 0 ind true)
                            (do
                                (ref-DPDC::XE_DeployAccountWNE dpdc id false)
                                EOC
                            )
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [])
            )
        )
    )
    (defun C_EnableSetClassFragmentation:object{IgnisCollectorV3.OutputCumulator}
        (
            id:string son:bool set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (P|UEV_IMC)
        (with-capability (DPDC-S|C>ENABLE-FRAGMENTATION id son set-class fragmentation-ind)
            (XI_FragmentSetClass id son set-class fragmentation-ind)
            (URCi_EnableSetClassFragmentation id son)
        )
    )
    (defun C_ToggleSet:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool set-class:integer toggle:bool)
        (P|UEV_IMC)
        (with-capability (DPDC-S|C>TOGGLE id son set-class toggle)
            (XI_ToggleSetClass id son set-class toggle)
            (URCi_ToggleSet id son)
        )
    )
    (defun C_RenameSet:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool set-class:integer new-name:string)
        (P|UEV_IMC)
        (with-capability (DPDC-S|C>RENAME id son set-class new-name)
            (XI_RenameSet id son set-class new-name)
            (URCi_RenameSet id son)
        )
    )

)



;;DPSF

;;DPNF

;; --- tables for 08_DPDC-S.pact (4 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table DPSF|SetsTable)
;; (create-table DPNF|SetsTable)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/09_DPDC-F.pact ==========
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcFragmentsV2
    @doc "Exposes Collectables Fragmentation related Functions"

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
    (defun URCi_RepurposeCollectableFragments:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool fragment-amounts:[integer]))
    (defun URCi_MakeFragments:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_MergeFragments:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    (defun URCi_EnableNonceFragmentation:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;; [UEV]
    ;;
    (defun UEV_IzNonceFragmented:bool (id:string son:bool nonce:integer))
    (defun UEV_Fragmentation (id:string son:bool nonce:integer))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]
    ;;
    (defun C_RepurposeCollectableFragments:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool repurpose-from:string repurpose-to:string fragment-nonces:[integer] fragment-amounts:[integer])
    )
    (defun C_MakeFragments:object{IgnisCollectorV3.OutputCumulator} (account:string id:string son:bool nonce:integer amount:integer))
    (defun C_MergeFragments:object{IgnisCollectorV3.OutputCumulator} (account:string id:string son:bool nonce:integer amount:integer))
    (defun C_EnableNonceFragmentation:object{IgnisCollectorV3.OutputCumulator}
        (
            id:string son:bool nonce:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )

)
;;
(module DPDC-F GOV
    @doc "DPDC-F is the Fragments module of the DPDC collectables family, handling \
        \ fractionalization of class-0 collectable nonces into fragment pieces in units of \
        \ 1000. Owners first enable per-nonce fragmentation via C_EnableNonceFragmentation. \
        \ Users then fractionalize and defractionalize with C_MakeFragments (locks a native \
        \ nonce, credits 1000x negative fragment nonces) and C_MergeFragments (burns \
        \ multiples of 1000 to reclaim whole nonces), plus C_RepurposeCollectableFragments \
        \ to move fragment balances. It carries no persistent set state, delegating \
        \ reads/writes to the core DPDC modules."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcFragmentsV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-F                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-F_ADMIN)))
    (defcap GOV|DPDC-F_ADMIN ()                         (enforce-guard GOV|MD_DPDC-F))
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
    (defcap P|DPDC-F|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-F|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DPDC-F|REMOTE-GOV ()
        @doc "DPDC Remote Governor Capability"
        true
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
        (with-capability (GOV|DPDC-F_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|DPDC-F_ADMIN)
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
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (mg:guard (create-capability-guard (P|DPDC-F|CALLER)))
            )
            (ref-P|DPDC::P|A_Add
                "DPDC-F|RemoteDpdcGov"
                (create-capability-guard (P|DPDC-F|REMOTE-GOV))
            )
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
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
    (defcap DPDC-F|C>REPURPOSE (id:string son:bool repurpose-from:string repurpose-to:string fragment-nonces:[integer] fragment-amounts:[integer])
        @event
        (let
            (
                (l1:integer (length fragment-nonces))
                (l2:integer (length fragment-amounts))
            )
            ;;DPDC Audit #47L: reject an empty repurpose here, with a clear message, instead of letting
            ;;it fall through to an unfriendly out-of-bounds error several call-hops downstream.
            (enforce (and (= l1 l2) (> l1 0)) "Invalid Repurpose data")
        )
    )
    ;;{C3}  Composed
    (defcap DPDC-F|C>ENABLE-FRAGMENTATION
        (
            id:string son:bool nonce:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (nonce-class:integer (ref-DPDC::UR_NonceClass id son nonce))
                (iz-fragmented:bool (UEV_IzNonceFragmented id son nonce))
            )
            (enforce (= nonce-class 0) "Only Class 0 Nonces can be fragmented")
            (enforce (not iz-fragmented) "Nonce must not be fragmented in order to enable fragmentation for it !")
            (ref-DPDC::UEV_Nonce id son nonce)
            (ref-DPDC::CAP_Owner id son)
            (ref-DPDC-C::UEV_NonceDataForCreation fragmentation-ind)
            (compose-capability (P|DPDC-F|CALLER))
        )
    )
    (defcap DPDC-F|C>NONCE
        (id:string son:bool nonce:integer)
        @event
        (UEV_Fragmentation id son nonce)
        (compose-capability (P|DPDC-F|CALLER))
        (compose-capability (P|DPDC-F|REMOTE-GOV))
    )
    (defcap DPDC-F|C>MERGE
        ;;DPDC Audit #48L: added id/son (were missing, inconsistent with every sibling cap in this file)
        ;;and @event, so this capability carries the same audit-trail visibility as C>NONCE/C>REPURPOSE.
        (id:string son:bool nonce:integer amount:integer)
        @event
        (let
            (
                (divided:integer (mod amount 1000))
            )
            (enforce (< nonce 0) "Only negative nonces can be used for merging")
            (enforce (= divided 0) "Only multiple of 1000 can be used for Merging")
            (compose-capability (P|DPDC-F|CALLER))
            (compose-capability (P|DPDC-F|REMOTE-GOV))
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
    (defun URCi_RepurposeCollectableFragments:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool fragment-amounts:[integer])
        @doc "Cost preview for C_RepurposeCollectableFragments: per-fragment construct \
            \ priced ((if son small else medium)/1000) * (1 + sum fragment-amounts), \
            \ empty output list."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (owner:string (ref-DPDC::UR_OwnerKonto id son))
                (s:decimal (ref-IGNIS::UC_IgnisLeg "tier-small"))
                (m:decimal (ref-IGNIS::UC_IgnisLeg "tier-medium"))
                (p:decimal (/ (if son s m) 1000.0))
                (sum-amounts:decimal (dec (fold (+) 1 fragment-amounts)))
                (price:decimal (* p sum-amounts))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price owner (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MakeFragments:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_MakeFragments (Biggest on creator-konto; the internal \
            \ transfers are not separately billed)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;minting-type op: NO special issuance price (owner 2026-09-06) — generic tier
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_MakeFragments" "usage")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_MakeFragments" "usage"))
                (ref-DPDC::UR_CreatorKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MergeFragments:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_MergeFragments (Biggest on creator-konto; the internal \
            \ transfers are not separately billed)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;USAGE, not setup — pairs with C_MakeFragments; the issue gate of the
                ;;fragmentation family is C_EnableNonceFragmentation (owner directive, recorded
                ;;in REPL/_ignis_deter_worksheet.py OWNER_DECISIONS)
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_MergeFragments" "usage")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_MergeFragments" "usage"))
                (ref-DPDC::UR_CreatorKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_EnableNonceFragmentation:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_EnableNonceFragmentation — the ISSUE gate of the fragmentation \
            \ family (owner 2026-09-05: MakeFragments/MergeFragments are USAGE; THIS is the issue \
            \ op). 100x deterrence = $1 in IGNIS per nonce defined as fragmented; this entrypoint \
            \ enables exactly ONE nonce per call, so the charge is one unit of the central \
            \ IG|DETER frag-enable tier. Shared by exec and the INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_EnableNonceFragmentation" "frag-enable")
                        (ref-IGNIS::UC_IgnisPrice "DPNF|C_EnableNonceFragmentation" "frag-enable"))
                (ref-DPDC::UR_CreatorKonto id son)
                (ref-IGNIS::URC_IsVirtualGasZero)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_IzNonceFragmented:bool (id:string son:bool nonce:integer)
        @doc "Checks if a nonce is fragmented. For non 0 nonce-classes, the set class is checked instead for fragmentation"
        (enforce (> nonce 0) "Only greater than 0 nonces can be checked for fragmentation")
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (sd:object{DpdcUdcV2.DPDC|NonceData} (ref-DPDC::UR_SplitNonceData id son nonce))
                (zd:object{DpdcUdcV2.DPDC|NonceData} (ref-DPDC-UDC::UDC_ZeroNonceData))
                (nonce-class:integer (ref-DPDC::UR_NonceClass id son nonce))
            )
            (if (!= sd zd) 
                true
                (if (!= nonce-class 0)
                    (let
                        (
                            (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                        )
                        (ref-DPDC-S::UEV_IzSetClassFragmented id son nonce-class)
                    )
                    false
                )
            )
        )
    )
    (defun UEV_Fragmentation (id:string son:bool nonce:integer)
        (let
            (
                (iz-fragmented:bool (UEV_IzNonceFragmented id son nonce))
            )
            (enforce iz-fragmented "Nonce must be fragmented for operation")
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: DPDC-F|C>ENABLE-FRAGMENTATION
    (defun XI_EnableNonceFragmentation 
        (
            id:string son:bool nonce:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (require-capability (DPDC-F|C>ENABLE-FRAGMENTATION id son nonce fragmentation-ind))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::XE_U|NonceOrSplitData id son nonce false fragmentation-ind)
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_RepurposeCollectableFragments:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool repurpose-from:string repurpose-to:string fragment-nonces:[integer] fragment-amounts:[integer])
        (P|UEV_IMC)
        (with-capability (DPDC-F|C>REPURPOSE id son repurpose-from repurpose-to fragment-nonces fragment-amounts)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    ;;
                    (l:integer (length fragment-nonces))
                    (owner:string (ref-DPDC::UR_OwnerKonto id son))
                    (s:decimal (ref-IGNIS::UC_IgnisLeg "tier-small"))
                    (m:decimal (ref-IGNIS::UC_IgnisLeg "tier-medium"))
                    (p:decimal (/ (if son s m) 1000.0))
                    (sum-amounts:decimal (dec (fold (+) 1 fragment-amounts)))
                    (price:decimal (* p sum-amounts))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (if (= l 1)
                    ;;Single Mode
                    (let
                        (
                            (fragment-nonce:integer (at 0 fragment-nonces))
                            (fragment-amount:integer (at 0 fragment-amounts))
                        )
                        ;;1]Debit from <repurpose-from>
                        (if son
                            (ref-DPDC-C::XE_DebitSFT-FragmentNonce repurpose-from id fragment-nonce fragment-amount true)
                            (ref-DPDC-C::XE_DebitNFT-FragmentNonce repurpose-from id fragment-nonce fragment-amount true)
                        )
                        ;;2]Credit to <repurpose-to>
                        (if son
                            (ref-DPDC-C::XE_CreditSFT-FragmentNonce repurpose-to id fragment-nonce fragment-amount)
                            (ref-DPDC-C::XE_CreditNFT-FragmentNonce repurpose-to id fragment-nonce fragment-amount)
                        )
                    )
                    ;;Multi Mode
                    (do
                        (if son
                            ;;1]Debit from <repurpose-from>
                            (ref-DPDC-C::XE_DebitSFT-FragmentNonces repurpose-from id fragment-nonces fragment-amounts true)
                            (ref-DPDC-C::XE_DebitNFT-FragmentNonces repurpose-from id fragment-nonces fragment-amounts true)
                        )
                        (if son
                            ;;2]Credit to <repurpose-to>
                            (ref-DPDC-C::XE_CreditSFT-FragmentNonces repurpose-to id fragment-nonces fragment-amounts)
                            (ref-DPDC-C::XE_CreditNFT-FragmentNonces repurpose-to id fragment-nonces fragment-amounts)
                        )
                    )
                )
                ;;3]Output Cumulator
                (URCi_RepurposeCollectableFragments id son fragment-amounts)
            )
        )
    )
    (defun C_MakeFragments:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string son:bool nonce:integer amount:integer)
        (P|UEV_IMC)
        (with-capability (DPDC-F|C>NONCE id son nonce)
            (let
                (
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    (neg-nonce:integer (- 0 nonce))
                    (f-amount:integer (* 1000 amount))
                )
                ;;1]Transfer <nonce> <amount> from <account> to <DPDC|SC_NAME>
                (ref-DPDC-T::C_Transfer [id] [son] account dpdc [[nonce]] [[amount]] true)
                ;;2]Fragment Nonces are credited to the <DPDC|SC_NAME>
                (if son
                    (ref-DPDC-C::XE_CreditSFT-FragmentNonce dpdc id neg-nonce f-amount)
                    (ref-DPDC-C::XE_CreditNFT-FragmentNonce dpdc id neg-nonce f-amount)
                )
                ;;3]They are then transfered to the <account>
                (ref-DPDC-T::C_Transfer [id] [son] dpdc account [[neg-nonce]] [[f-amount]] true)
                ;;4]Output Cumulator
                (URCi_MakeFragments id son)
            )
        )
    )
    (defun C_MergeFragments:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string son:bool nonce:integer amount:integer)
        (P|UEV_IMC)
        (with-capability (DPDC-F|C>MERGE id son nonce amount)
            (let
                (
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    (pos-nonce:integer (abs nonce))
                    (merged-amount:integer (/ amount 1000))
                )
                ;;1]Transfer <nonce> <amount> from <account> to <DPDC|SC_NAME>
                (ref-DPDC-T::C_Transfer [id] [son] account dpdc [[nonce]] [[amount]] true)
                ;;2]Fragment Nonces are debited from the <DPDC|SC_NAME>
                (if son
                    (ref-DPDC-C::XE_DebitSFT-FragmentNonce dpdc id nonce amount false)
                    (ref-DPDC-C::XE_DebitNFT-FragmentNonce dpdc id nonce amount false)
                )
                ;;3]Native <nonces> are transfered from <DPDC|SC_NAME> to <account>
                (ref-DPDC-T::C_Transfer [id] [son] dpdc account [[pos-nonce]] [[merged-amount]] true)
                ;;4]Output Cumulator
                (URCi_MergeFragments id son)
            )
        )
    )
    (defun C_EnableNonceFragmentation:object{IgnisCollectorV3.OutputCumulator}
        (
            id:string son:bool nonce:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (P|UEV_IMC)
        (with-capability (DPDC-F|C>ENABLE-FRAGMENTATION id son nonce fragmentation-ind)
            (let
                (
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                )
                (XI_EnableNonceFragmentation id son nonce fragmentation-ind)
                (ref-DPDC::XE_DeployAccountWNE dpdc id son)
                (URCi_EnableNonceFragmentation id son)
            )
        )
    )

)

;; --- tables for 09_DPDC-F.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/10_DPDC-N.pact ==========
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcNonceV2
    @doc "Exposes Collectables Nonce Management related Functions"

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
    ;; [UR]
    ;;
    (defun UR_Nonce:object{DpdcUdcV2.DPDC|NonceData} (id:string son:bool nosc:integer nos:bool nost:bool))
    ;;
    ;;  [URCi]
    ;;
    (defun URCi_UpdateNonces:object{IgnisCollectorV3.OutputCumulator} (account:string count:integer))
    (defun URCi_UpdateNonceField:object{IgnisCollectorV3.OutputCumulator} (account:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;; [UEV]
    ;;
    (defun UEV_NonceDataUpdater (id:string son:bool account:string nosc:integer nos:bool nost:bool))
    (defun UEV_RoleNftRecreateON (id:string son:bool account:string))
    (defun UEV_RoleNftUpdateON (id:string son:bool account:string))
    (defun UEV_RoleModifyRoyaltiesON (id:string son:bool account:string))
    (defun UEV_RoleSetNewUriON (id:string son:bool account:string))
    (defun UEV_Score (score:decimal))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]
    ;;
    (defun C_UpdateNonces                               (id:string son:bool account:string nosc:[integer] nos:bool nost:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]))
    (defun C_UpdateNonceRoyalty                         (id:string son:bool account:string nosc:integer nos:bool nost:bool royalty-value:decimal))
    (defun C_UpdateNonceIgnisRoyalty                    (id:string son:bool account:string nosc:integer nos:bool nost:bool royalty-value:decimal))
    (defun C_UpdateNonceName                            (id:string son:bool account:string nosc:integer nos:bool nost:bool name:string))
    (defun C_UpdateNonceDescription                     (id:string son:bool account:string nosc:integer nos:bool nost:bool description:string))
    (defun C_UpdateNonceScore                           (id:string son:bool account:string nosc:integer nos:bool nost:bool score:decimal))
    (defun C_UpdateNonceMetaData                        (id:string son:bool account:string nosc:integer nos:bool nost:bool meta-data:object))
    (defun C_UpdateNonceURI                             (id:string son:bool account:string nosc:integer nos:bool nost:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}))

)
;;
(module DPDC-N GOV
    @doc "DPDC-N is the DPDC-family module for updating the mutable metadata of existing \
        \ NFT/SFT nonces (and set-classes). It exposes C_ entrypoints to update full nonce \
        \ data in bulk plus single fields — native/ignis royalty, name, description, score, \
        \ meta-data and URIs — each gated by role checks \
        \ (Recreate/Update/ModifyRoyalties/SetUri), account-ownership enforcement, and a \
        \ guard blocking edits to already-minted NFT Set instances. It implements \
        \ OuronetPolicyV2 and DpdcNonceV2, owns policy tables, routes writes through SECURE \
        \ XI_ helpers into DPDC/DPDC-S/DPDC-F, and computes IGNIS cost previews via URCi_."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcNonceV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-N                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-N_ADMIN)))
    (defcap GOV|DPDC-N_ADMIN ()                         (enforce-guard GOV|MD_DPDC-N))
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
    (defcap P|DPDC-N|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-N|CALLER))
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
        (with-capability (GOV|DPDC-N_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|DPDC-N_ADMIN)
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
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-S:module{OuronetPolicyV2} DPDC-S)
                (mg:guard (create-capability-guard (P|DPDC-N|CALLER)))
            )
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-S::P|A_AddIMP mg)
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
    (defcap DPDC-N|C>SET-DATA
        (id:string son:bool account:string nosc:[integer] nos:bool nost:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Controls Full Noce Updating, for multiple Nonces at a time"
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (l1:integer (length nosc))
                (l2:integer (length new-nonces-data))
            )
            (enforce (= l1 l2) "Invalid Inputs for Updating Nonces")
            (UEV_RoleNftRecreateON id son account)
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (map
                (lambda
                    (idx:integer)
                    (do
                        (ref-DPDC-C::UEV_NonceDataForCreation (at idx new-nonces-data))
                        (UEV_NonceDataUpdater id son account (at idx nosc) nos nost)
                        (UEV_NotSetInstance id son (at idx nosc) nost)     ;; DPDC Audit #12Hc
                    )
                )
                (enumerate 0 (- l1 1))
            )
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap DPDC-N|C>SET-ROYALTY
        (id:string son:bool account:string nosc:integer nos:bool nost:bool royalty-value:decimal)
        @doc "[1] Controls Nonce Native Royalty Updating"
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (UEV_RoleModifyRoyaltiesON id son account)
            (ref-DPDC::UEV_Royalty royalty-value)
            (compose-capability (DPDC-N|C>DATA id son account nosc nos nost))
        )
    )
    (defcap DPDC-N|C>SET-IGNIS-ROYALTY
        (id:string son:bool account:string nosc:integer nos:bool nost:bool royalty-value:decimal)
        @doc "[2] Controls Nonce Native Ignis Royalty Updating"
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (UEV_RoleModifyRoyaltiesON id son account)
            (ref-DPDC::UEV_IgnisRoyalty royalty-value)
            (compose-capability (DPDC-N|C>DATA id son account nosc nos nost))
        )
    )
    (defcap DPDC-N|C>SET-NAME
        (id:string son:bool account:string nosc:integer nos:bool nost:bool name:string)
        @doc "[3] Controls Nonce Name Updating"
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_Name name)     ;; DPDC Audit #12Hb
            (compose-capability (DPDC-N|C>UPDATE id son account nosc nos nost))
        )
    )
    (defcap DPDC-N|C>SET-DESCRIPTION
        (id:string son:bool account:string nosc:integer nos:bool nost:bool description:string)
        @doc "[4] Controls Nonce Description Updating"
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_Description description)     ;; DPDC Audit #12Hb
            (compose-capability (DPDC-N|C>UPDATE id son account nosc nos nost))
        )
    )
    (defcap DPDC-N|C>SET-SCORE
        (id:string son:bool account:string nosc:integer nos:bool nost:bool score:decimal)
        @doc "[5] Controls Nonce Score Updating"
        @event
        (UEV_Score score)
        (compose-capability (DPDC-N|C>UPDATE id son account nosc nos nost))
    )
    (defcap DPDC-N|C>SET-META-DATA
        (id:string son:bool account:string nosc:integer nos:bool nost:bool meta-data:object)
        @doc "[6] Controls Nonce Meta-Data Updating"
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_MetaDataBag meta-data)     ;; DPDC Audit #12Hb
            (compose-capability (DPDC-N|C>UPDATE id son account nosc nos nost))
        )
    )
    (defcap DPDC-N|C>SET-URI
        (
            id:string son:bool account:string nosc:integer nos:bool nost:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data}
            u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Controls Nonce Uri Updating"
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (UEV_RoleSetNewUriON id son account)
            ;; DPDC Audit #12Hb
            (ref-DPDC::UEV_AssetType ay)
            (ref-DPDC::UEV_UriData u1)
            (ref-DPDC::UEV_UriData u2)
            (ref-DPDC::UEV_UriData u3)
            (compose-capability (DPDC-N|C>DATA id son account nosc nos nost))
        )
    )
    ;;
    (defcap DPDC-N|C>UPDATE 
        (id:string son:bool account:string nosc:integer nos:bool nost:bool)
        (UEV_RoleNftUpdateON id son account)
        (compose-capability (DPDC-N|C>DATA id son account nosc nos nost))
    )
    (defcap DPDC-N|C>DATA
        (id:string son:bool account:string nosc:integer nos:bool nost:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (UEV_NonceDataUpdater id son account nosc nos nost)
            (UEV_NotSetInstance id son nosc nost)     ;; DPDC Audit #12Hc
            (ref-DALOS::CAP_EnforceAccountOwnership account)
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
    (defun UR_Nonce:object{DpdcUdcV2.DPDC|NonceData}
        (id:string son:bool nosc:integer nos:bool nost:bool)
        @doc "nosc = <Nonce-Or-Set-Class> ; value of either a Nonce or Set-Class \
            \ nos  = <Native-Or-Split>    ; designates either native or split for Nonce-Data \
            \ nost = <NoNCe-Or-SET>       ; designates if <nosc> is either a <nonce> or <set-class> value"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
            )
            (if nost
                (if nos
                    (ref-DPDC::UR_NativeNonceData id son nosc)
                    (ref-DPDC::UR_SplitNonceData id son nosc)
                )
                (if nos
                    (ref-DPDC-S::UR_SetNonceData id son nosc)
                    (ref-DPDC-S::UR_SetSplitData id son nosc)
                )
            )
        )
    )
    ;;
    (defun URCi_UpdateNonces:object{IgnisCollectorV3.OutputCumulator}
        (account:string count:integer)
        @doc "Cost preview for C_UpdateNonces (count * UsagePrice ignis|smallest; \
            \ construct with empty output list)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (price:decimal (* (dec count) (ref-IGNIS::UC_IgnisLeg "tier-smallest")))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price account (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateNonceField:object{IgnisCollectorV3.OutputCumulator}
        (account:string)
        @doc "Cost preview for the single-field nonce updates (Royalty, IgnisRoyalty, Name, \
            \ Description, Score, MetaData, URI) — ONE uniform price for all ~20 C_UpdateNonce* \
            \ wrappers (owner 2026-09-06). A single component key is EXACT here because every \
            \ DPSF|/DPNF| UpdateNonce* entry in IG|COMPONENTS is 17.0; if those ever diverge \
            \ this reader must take <son> and branch. Tier is setup, not usage: a nonce field \
            \ update is a config/property change per the IG|DETER rubric."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPNF|C_UpdateNonce" "setup")
                account (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_NonceDataUpdater
        (id:string son:bool account:string nosc:integer nos:bool nost:bool)
        (enforce (> nosc 0) "Operation requires greater than zero <nonce-or-set-class>")
        (if nost
            ;;Nonce
            (let
                (
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-DPDC::UEV_Nonce id son nosc)
                (if (not nos)
                    (ref-DPDC-F::UEV_Fragmentation id son nosc)
                    true
                )
            )
            ;;Sets
            (let
                (
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-DPDC-S::UEV_SetClass id son nosc)
                (if (not nos)
                    (ref-DPDC-S::UEV_Fragmentation id son nosc)
                    true
                )
            )
        )
    )
    (defun UEV_NotSetInstance (id:string son:bool nosc:integer nost:bool)
        @doc "Blocks direct edits to an already-minted NFT Set instance's own NonceData. NFT Set \
            \ instances are individually unique combinations — each Make can combine different \
            \ constituent nonces, so each instance carries its own composition record that must \
            \ stay fixed once minted; only the Set-Class definition/template (the <nost=false> \
            \ Sets path) may be touched afterward. SFT Sets are unaffected: an SFT set-class has \
            \ exactly one shared nonce, never re-derived per Make, so its data legitimately stays \
            \ editable. See DPDC Audit #12Hc."
        (if (and nost (not son))
            (let
                (
                    (ref-DPDC:module{DpdcV2} DPDC)
                )
                (enforce
                    (= (ref-DPDC::UR_NonceClass id son nosc) 0)
                    "NFT Set instance nonces cannot have their data directly modified — edit the \
                        \ Set-Class definition instead"
                )
            )
            true
        )
    )
    (defun UEV_RoleNftRecreateON (id:string son:bool account:string)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (x:bool (ref-DPDC::UR_CA|R-Recreate id son account))
            )
            (enforce x (format "{} Collection {} Element Data cannot be Updated while using the {} Ouronet Account" [(if son "SFT" "NFT") id account]))
        )
    )
    (defun UEV_RoleNftUpdateON (id:string son:bool account:string)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (x:bool (ref-DPDC::UR_CA|R-Update id son account))
            )
            (enforce x (format "{} Collection {} Element Data cannot be Updated while using the {} Ouronet Account" [(if son "SFT" "NFT") id account]))
        )
    )
    (defun UEV_RoleModifyRoyaltiesON (id:string son:bool account:string)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (x:bool (ref-DPDC::UR_CA|R-ModifyRoyalties id son account))
            )
            (enforce x (format "{} Collection {} Element Data Royalties cannot be Updated while using the {} Ouronet Account" [(if son "SFT" "NFT") id account]))
        )
    )
    (defun UEV_RoleSetNewUriON (id:string son:bool account:string)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (x:bool (ref-DPDC::UR_CA|R-SetUri id son account))
            )
            (enforce x (format "{} Collection {} Element Data URIs cannot be Updated while using the {} Ouronet Account" [(if son "SFT" "NFT") id account]))
        )
    )
    ;;
    (defun UEV_Score (score:decimal)
        (enforce
            (= (floor score 24) score)
            (format "The score {} can have up to 24 decimals precision" [score])
        )
        (enforce
            ;; L7 #19: exactly -1.0 is the "unscored" sentinel; otherwise the score must be NON-negative and
            ;; below 100 billion. (Was `>= -1.0`, which wrongly admitted the whole [-1.0, 0) range of real
            ;; negatives — negative nonce scores mangle AQP reward weighting.)
            (and
                (or (= score -1.0) (>= score 0.0))
                (<= score 100000000000.0)
            )
            "Score must be the -1.0 unscored sentinel or a non-negative value below 100 billion"
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_U|NoncesData
        (id:string son:bool account:string nosc:[integer] nos:bool nost:bool new-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}])
        (require-capability (SECURE))
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
            )
            (map
                (lambda
                    (idx:integer)
                    (if nost
                        ;;Nonce
                        (ref-DPDC::XE_U|NonceOrSplitData id son (at idx nosc) nos (at idx new-nonce-data))
                        ;;Sets
                        (ref-DPDC-S::XB_U|NonceOrSplitData id son (at idx nosc) nos (at idx new-nonce-data))
                    )
                )
                (enumerate 0 (- (length nosc) 1))
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|NonceRoyalty
        (id:string son:bool account:string nosc:integer nos:bool nost:bool r-or-ir:bool royalty-value:decimal)
        (require-capability (SECURE))
        (let
            (
                (read-nonce-data:object{DpdcUdcV2.DPDC|NonceData} (UR_Nonce id son nosc nos nost))
                (new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}
                    (if r-or-ir
                        (+
                            {"royalty" : royalty-value}
                            (remove "royalty" read-nonce-data)
                        )
                        (+
                            {"ignis" : royalty-value}
                            (remove "ignis" read-nonce-data)
                        )
                    ) 
                )
            )
            (XI_U|NoncesData id son account [nosc] nos nost [new-nonce-data])
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|NonceNoD 
        (id:string son:bool account:string nosc:integer nos:bool nost:bool name-or-description:bool name-description:string)
        (require-capability (SECURE))
        (let
            (
                (read-nonce-data:object{DpdcUdcV2.DPDC|NonceData} (UR_Nonce id son nosc nos nost))
                (new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}
                    (if name-or-description
                        (+
                            {"name" : name-description}
                            (remove "name" read-nonce-data)
                        )
                        (+
                            {"description" : name-description}
                            (remove "description" read-nonce-data)
                        )
                    ) 
                )
            )
            (XI_U|NoncesData id son account [nosc] nos nost [new-nonce-data])
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|NonceScore
        (id:string son:bool account:string nosc:integer nos:bool nost:bool score:decimal)
        (require-capability (SECURE))
        (let
            (
                (read-nonce-data:object{DpdcUdcV2.DPDC|NonceData} (UR_Nonce id son nosc nos nost))
                (read-md:object{DpdcUdcV2.NonceMetaData} (at "meta-data" read-nonce-data))
                ;;
                (updated-md:object{DpdcUdcV2.NonceMetaData}
                    (+
                        {"score" : score}
                        (remove "score" read-md)
                    )
                )
                (new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}
                    (+
                        {"meta-data" : updated-md}
                        (remove "meta-data" read-nonce-data)
                    )
                )
            )
            (XI_U|NoncesData id son account [nosc] nos nost [new-nonce-data])
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_NonceMetaData 
        (id:string son:bool account:string nosc:integer nos:bool nost:bool meta-data:object)
        (require-capability (SECURE))
        (let
            (
                (read-nonce-data:object{DpdcUdcV2.DPDC|NonceData} (UR_Nonce id son nosc nos nost))
                (read-md:object{DpdcUdcV2.NonceMetaData} (at "meta-data" read-nonce-data))
                ;;
                (updated-md:object{DpdcUdcV2.NonceMetaData}
                    (+
                        {"meta-data" : meta-data}
                        (remove "meta-data" read-md)
                    )
                )
                (new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}
                    (+
                        {"meta-data" : updated-md}
                        (remove "meta-data" read-nonce-data)
                    )
                )
            )
            (XI_U|NoncesData id son account [nosc] nos nost [new-nonce-data])
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|NonceUri
        (
            id:string son:bool account:string nosc:integer nos:bool nost:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        (require-capability (SECURE))
        (let
            (
                (read-nonce-data:object{DpdcUdcV2.DPDC|NonceData} (UR_Nonce id son nosc nos nost))
                (new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}
                    (+
                        {"uri-tertiary" : u3}
                        (+
                            {"uri-secondary" : u2}
                            (+
                                {"uri-primary" : u1}
                                (+
                                    {"asset-type" : ay}
                                    (remove "asset-type" read-nonce-data)
                                )
                            )
                        )
                    ) 
                )
            )
            (XI_U|NoncesData id son account [nosc] nos nost [new-nonce-data])
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_UpdateNonces
        (id:string son:bool account:string nosc:[integer] nos:bool nost:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Nonce Data for multiple Nonces at a time"
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (smallest:decimal (ref-IGNIS::UC_IgnisLeg "tier-smallest"))
                (how-many:decimal (dec (length nosc)))
                (price:decimal (* how-many smallest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (DPDC-N|C>SET-DATA id son account nosc nos nost new-nonces-data)
                (XI_U|NoncesData id son account nosc nos nost new-nonces-data)
                ;;Cumulator
                (URCi_UpdateNonces account (length nosc))
            )
        )
    )
    (defun C_UpdateNonceRoyalty
        (id:string son:bool account:string nosc:integer nos:bool nost:bool royalty-value:decimal)
        @doc "[1] Updates Nonce Native Royalty Value. This field is a forward-looking hook for the \
            \ upcoming Escrow/NFT marketplace (not yet built) — no on-chain consumer reads it today; \
            \ confirmed intentional, not dead/unfinished code. See DPDC Audit #26M."
        (P|UEV_IMC)
        (with-capability (DPDC-N|C>SET-ROYALTY id son account nosc nos nost royalty-value)
            (XI_U|NonceRoyalty id son account nosc nos nost true royalty-value)
            (URCi_UpdateNonceField account)
        )
    )
    (defun C_UpdateNonceIgnisRoyalty
        (id:string son:bool account:string nosc:integer nos:bool nost:bool royalty-value:decimal)
        @doc "[2] Updates Nonce Ignis Royalty Value"
        (P|UEV_IMC)
        (with-capability (DPDC-N|C>SET-IGNIS-ROYALTY id son account nosc nos nost royalty-value)
            (XI_U|NonceRoyalty id son account nosc nos nost false royalty-value)
            (URCi_UpdateNonceField account)
        )
    )
    (defun C_UpdateNonceName
        (id:string son:bool account:string nosc:integer nos:bool nost:bool name:string)
        @doc "[3] Updates Nonce Name"
        (P|UEV_IMC)
        (with-capability (DPDC-N|C>SET-NAME id son account nosc nos nost name)
            (XI_U|NonceNoD id son account nosc nos nost true name)
            (URCi_UpdateNonceField account)
        )
    )
    (defun C_UpdateNonceDescription
        (id:string son:bool account:string nosc:integer nos:bool nost:bool description:string)
        @doc "[4] Updates Nonce Description"
        (P|UEV_IMC)
        (with-capability (DPDC-N|C>SET-DESCRIPTION id son account nosc nos nost description)
            (XI_U|NonceNoD id son account nosc nos nost false description)
            (URCi_UpdateNonceField account)
        )
    )
    (defun C_UpdateNonceScore
        (id:string son:bool account:string nosc:integer nos:bool nost:bool score:decimal)
        @doc "[5] Updates Nonce Score"
        (P|UEV_IMC)
        (with-capability (DPDC-N|C>SET-SCORE id son account nosc nos nost score)
            (XI_U|NonceScore id son account nosc nos nost score)
            (URCi_UpdateNonceField account)
        )
    )
    (defun C_UpdateNonceMetaData
        (id:string son:bool account:string nosc:integer nos:bool nost:bool meta-data:object)
        @doc "[6] Updates Nonce Meta-Data"
        (P|UEV_IMC)
        (with-capability (DPDC-N|C>SET-META-DATA id son account nosc nos nost meta-data)
            (XI_NonceMetaData id son account nosc nos nost meta-data)
            (URCi_UpdateNonceField account)
        )
    )
    (defun C_UpdateNonceURI
        (
            id:string son:bool account:string nosc:integer nos:bool nost:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Nonce URIs"
        (P|UEV_IMC)
        (with-capability (DPDC-N|C>SET-URI id son account nosc nos nost ay u1 u2 u3)
            (XI_U|NonceUri id son account nosc nos nost ay u1 u2 u3)
            (URCi_UpdateNonceField account)
        )
    )

)

;; --- tables for 10_DPDC-N.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact =========
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface EquityV2
    @doc "EquityV2 is the interface contract for the EQUITY shareholder/equity-collection \
        \ policy, declaring the signatures every implementer must provide. It specifies \
        \ compute helpers, read/cost-preview functions (tier supplies, share \
        \ package/per-million math, combine capacity, URCi_ cost readers), validators (share \
        \ package tier, share amounts, equity SF id, convert, morph), and the two user \
        \ entrypoints C_IssueShareholderCollection and C_MorphPackageShares. It defines no \
        \ tables or state, only the equity API surface."

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
    (defun UC_Name:[string] (collection-name:string))
    (defun UC_Description:[string] (collection-name:string))
    (defun UC_Convert:integer (id:string input-tier:integer input-tier-amount:integer output-tier:integer))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UR]
    ;;
    (defun UR_TierSupplies:[integer] (id:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_MakeSharePackage:integer (id:string shares-amount:integer package-share-tier:integer))
    (defun URC_SharesPerMillion:[integer] (id:string))
    (defun URC_SingleSharePerMillions:integer (id:string package-share-tier:integer))
    (defun URC_CombineCapacity:integer (id:string))
    (defun URCi_MorphPackageShares:object{IgnisCollectorV3.OutputCumulator} (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer))
    (defun URCi_IssueShareholderCollection:object{IgnisCollectorV3.OutputCumulator} ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_SharePackageTier (package-share-tier:integer))
    (defun UEV_ShareAmountsForMaking (id:string shares-amount:integer package-share-tier:integer))
    (defun UEV_EquitySemiFungibleID (id:string))
    (defun UEV_Convert (id:string input-tier:integer input-tier-amount:integer output-tier:integer))
    (defun UEV_Morph (input-nonce:integer output-nonce:integer))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_IssueShareholderCollection:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string creator-account:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
    )
    (defun C_MorphPackageShares:object{IgnisCollectorV3.OutputCumulator} (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer))

)
(module EQUITY GOV
    @doc "EQUITY implements OuronetPolicyV2 and EquityV2 to create and manage Shareholder \
        \ DPSF (SFT) collections representing company equity, where nonce 1 is the barebone \
        \ share and nonces 2-8 are packaged share tiers. Its main entrypoints are \
        \ C_IssueShareholderCollection (issues an Elite equity SFT collection via \
        \ DPDC-I/DPDC-C, populating 8 nonces with tiered royalties) and C_MorphPackageShares \
        \ (Make/Break/Convert between share tiers via SECURE-gated XI_ helpers over \
        \ DPDC-MNG/DPDC-T). It enforces packaging caps, tier/divisibility validators, owns \
        \ policy tables, acts as a remote DPDC governor, and returns IGNIS cost cumulators."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements EquityV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_EQUITY                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|EQUITY_ADMIN)))
    (defcap GOV|EQUITY_ADMIN ()                         (enforce-guard GOV|MD_EQUITY))
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
    (defcap P|EQUITY|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|EQUITY|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|EQUITY|REMOTE-GOV ()
        @doc "DPDC Remote Governor Capability"
        true
    )
    (defcap P|GOV-CALLER ()
        (compose-capability (P|EQUITY|CALLER))
        (compose-capability (P|EQUITY|REMOTE-GOV))
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
        (with-capability (GOV|EQUITY_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|EQUITY_ADMIN)
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
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (ref-P|DPDC-I:module{OuronetPolicyV2} DPDC-I)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (mg:guard (create-capability-guard (P|EQUITY|CALLER)))
            )
            (ref-P|DPDC::P|A_Add
                "EQUITY|RemoteDpdcGov"
                (create-capability-guard (P|EQUITY|REMOTE-GOV))
            )
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
            (ref-P|DPDC-I::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst P                                         ["0.1‰" "0.2‰" "0.5‰" "1‰" "2‰" "5‰" "1%"])
    (defconst S                                         [100 200 500 1000 2000 5000 10000])
    ;;ever be packaged into tradeable tier-units (nonces 2-8) at once; the remainder must stay as loose,
    ;;unpackaged barebone shares. See URC_CombineCapacity below, the sole consumer of this constant.
    (defconst PACKAGING_CAP_DIVISOR 2)
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
    (defcap EQUITY|C>MAKE (id:string shares-amount:integer package-share-tier:integer)
        @event
        (UEV_EquitySemiFungibleID id)
        (UEV_ShareAmountsForMaking id shares-amount package-share-tier)
        (compose-capability (P|GOV-CALLER))
    )
    (defcap EQUITY|C>BREAK (id:string package-share-tier:integer)
        @event
        (UEV_EquitySemiFungibleID id)
        (UEV_SharePackageTier package-share-tier)
        (compose-capability (P|GOV-CALLER))
    )
    (defcap EQUITY|C>CONVERT (id:string input-package-share-tier:integer input-package-share-tier-amount:integer output-package-share-tier:integer)
        @event
        (UEV_EquitySemiFungibleID id)
        (UEV_Convert id input-package-share-tier input-package-share-tier-amount output-package-share-tier)
        (compose-capability (P|GOV-CALLER))
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
    (defun UC_Name:[string] (collection-name:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL acc
                        (if (= idx 0)
                            (format "{} Share" [collection-name])
                            (format "{} {} Share Package" [collection-name (at (- idx 1) P)] )
                        )
                    )
                )
                []
                (enumerate 0 7 1)
            )
        )
    )
    (defun UC_Description:[string] (collection-name:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL acc
                        (if (= idx 0)
                            (format "An SFT representing 1 Share of {}" [collection-name])
                            (format "An SFT representing {} of all {} Shares" [(at (- idx 1) P) collection-name])
                        )
                    )
                )
                []
                (enumerate 0 7 1)
            )
        )
    )
    (defun UC_Convert:integer (id:string input-tier:integer input-tier-amount:integer output-tier:integer)
        (let
            (
                (spm:[integer] (URC_SharesPerMillion id))
            )
            (/
                (* (at (- input-tier 1) spm) input-tier-amount)
                (at (- output-tier 1) spm)
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_TierSupplies:[integer] (id:string)
        @doc "Total outstanding supply of each package tier (nonces 2-8, in tier-unit counts, not \
            \ share-equivalents), in tier order."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL acc
                        (ref-DPDC::UR_NonceSupply id true idx)
                    )
                )
                []
                (enumerate 2 8)
            )
        )
    )
    (defun URC_MakeSharePackage:integer (id:string shares-amount:integer package-share-tier:integer)
        @doc "Converts a raw <shares-amount> into the equivalent whole number of <package-share-tier> \
            \ units. Assumes even divisibility -- UEV_ShareAmountsForMaking enforces that before this \
            \ result is trusted."
        (/ shares-amount (URC_SingleSharePerMillions id package-share-tier))
    )
    (defun URC_SharesPerMillion:[integer] (id:string)
        @doc "Computes Tier Shares; Example for 5 mil Company Shares it would output 5*[100 200 500 1000 2000 5000 10000]"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (tcs-in-millions:integer (/ (ref-DPDC::UR_NonceSupply id true 1) 1000000))
            )
            (map (* tcs-in-millions) S)
        )
    )
    (defun URC_SingleSharePerMillions:integer (id:string package-share-tier:integer)
        @doc "Share-per-unit value for a single <package-share-tier> (1-7), scaled to this collection's \
            \ total share count. See URC_SharesPerMillion."
        (at (- package-share-tier 1) (URC_SharesPerMillion id))

    )
    (defun URC_CombineCapacity:integer (id:string)
        @doc "Remaining share-equivalent headroom that may still be packaged into tier-units (nonces \
            \ 2-8) before hitting the 1/PACKAGING_CAP_DIVISOR (50%) packaging cap on total shares \
            \ (nonce 1). DPDC Audit #29M."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (shares:integer (ref-DPDC::UR_NonceSupply id true 1))
                (half-shares:integer (/ shares PACKAGING_CAP_DIVISOR))
                (spm:[integer] (URC_SharesPerMillion id))
                (supplies:[integer] (UR_TierSupplies id))
                (supplies-as-shares:[integer] (zip (*) supplies spm))
                (shares-in-package-nonces:integer (fold (+) 0 supplies-as-shares))
            )
            (- half-shares shares-in-package-nonces)
        )
    )
    ;;
    (defun URCi_IssueShareholderCollection:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "Cost preview for C_IssueShareholderCollection's IGNIS cumulator (the collection- \
            \ issue STOA price previews separately via DPDC-I::URCi_IssueCollectionStoa). Three legs, \
            \ ARG-INDEPENDENT: \
            \ ico1 = the digital-collection issue (URCi_IssueDigitalCollection son=true on the DPDC \
            \ SC, which owns every Equity collection — owner-account is C_IssueDigitalCollection's \
            \ 3rd arg = dpdc); \
            \ ico2 = the $100 equity premium (central IG|DETER key issue-shareholder, owner 2026-09-05); \
            \ ico3 = the 8-nonce populate at the DISCOUNTED first-Elite-SFT price. \
            \ The discount is CODE-PROVEN to fire at exec time: XI_IssueDigitalCollection inits the \
            \ collection with nonces-used=0 and creates NO nonce, so the immediately-following \
            \ C_CreateNewNonces runs while nonces-used is still 0; the id is Elite (UC_EquityID forces \
            \ an 'E|' ticker and UDC_Makeid=concat[ticker '-' hash] so take-2 of the id is 'E|'); and \
            \ son=true. So URCi_RegisterCollectablesPrice's [ft='E|' & son & nu=0] branch applies the \
            \ /1000 discount: populate = smallest * 1,000,000 / 1000 = smallest * 1000 (only Nonce 1 \
            \ carries supply; Nonces 2-8 are 0). Output ([equity-id]) is empty here (write product). \
            \ NOTE: the SWPI-style ground-truth (compare vs the real reader post-issue) does NOT apply \
            \ — post-populate nonces-used=8, so a live URCi_CreateNewNonces reads the UNdiscounted \
            \ price; the equality is code-proven, not test-arbitrated. A GAS-delta harness on the \
            \ real DPSF|C_IssueCompany would confirm empirically. The discount itself (equity always \
            \ Elite) is intended-behavior to confirm under task #76 (IGNIS re-pricing)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-I:module{DpdcIssueV2} DPDC-I)
                ;;
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (populate-price:decimal (/ (* (ref-IGNIS::UC_IgnisLeg "tier-smallest") 1000000.0) 1000.0))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPDC-I::URCi_IssueDigitalCollection true dpdc)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_IssueCompany" "issue-shareholder")
                dpdc (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (ref-IGNIS::UDC_ConstructOutputCumulator populate-price dpdc (ref-IGNIS::URC_IsVirtualGasZero) [])
                ]
                []
            )
        )
    )
    (defun URCi_MorphPackageShares:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        @doc "Cost preview for C_MorphPackageShares, mirroring its three branches: Make \
            \ (input-nonce=1: transfer-in + add-quantity + transfer-out), Break (output-nonce=1: \
            \ transfer-in + burn + transfer-out) and Convert (transfer-in + burn + add-quantity + \
            \ transfer-out). Output matches exec ([[in-nonce out-nonce][in-amt out-amt]]). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
            )
            (if (= input-nonce 1)
                ;;Make: shares (nonce 1) -> package-share-tier (output-nonce)
                (let
                    (
                        (output-amount:integer (URC_MakeSharePackage id input-amount (- output-nonce 1)))
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] account dpdc [[1]] [[input-amount]])
                            (ref-DPDC-MNG::URCi_AddQuantity id)
                            (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] dpdc account [[output-nonce]] [[output-amount]])
                        ]
                        [[1 output-nonce] [input-amount output-amount]]
                    )
                )
                (if (= output-nonce 1)
                    ;;Break: package-share-tier (input-nonce) -> shares (nonce 1)
                    (let
                        (
                            (output-shares:integer (* (URC_SingleSharePerMillions id (- input-nonce 1)) input-amount))
                        )
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators
                            [
                                (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] account dpdc [[input-nonce]] [[input-amount]])
                                (ref-DPDC-MNG::URCi_BurnSFT id)
                                (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] dpdc account [[1]] [[output-shares]])
                            ]
                            [[input-nonce 1] [input-amount output-shares]]
                        )
                    )
                    ;;Convert: package-share-tier (input-nonce) -> package-share-tier (output-nonce)
                    (let
                        (
                            (output-amount:integer (UC_Convert id (- input-nonce 1) input-amount (- output-nonce 1)))
                        )
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators
                            [
                                (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] account dpdc [[input-nonce]] [[input-amount]])
                                (ref-DPDC-MNG::URCi_BurnSFT id)
                                (ref-DPDC-MNG::URCi_AddQuantity id)
                                (ref-DPDC-T::URCi_MultiTransferCumulator [id] [true] dpdc account [[output-nonce]] [[output-amount]])
                            ]
                            [[input-nonce output-nonce] [input-amount output-amount]]
                        )
                    )
                )
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_SharePackageTier (package-share-tier:integer)
        (let
            (
                (share-tiers:[integer] (enumerate 1 7))
                (iz-contained:bool (contains package-share-tier share-tiers))
            )
            (enforce iz-contained "Invalid Package Share Tier")
        )
    )
    (defun UEV_ShareAmountsForMaking (id:string shares-amount:integer package-share-tier:integer)
        (UEV_SharePackageTier package-share-tier)
        (let
            (
                (sspm:integer (URC_SingleSharePerMillions id package-share-tier))
                (mod-check:integer (mod shares-amount sspm))
                (capacity:integer (URC_CombineCapacity id))
            )
            (enforce 
                (<= shares-amount capacity) 
                (format "Insufficient Capacity Left ({}) to combine {} Individual Shares" [capacity shares-amount])
            )
            (enforce 
                (= mod-check 0) 
                (format "{} Shares is an invalid amount for making a Tier {} Share Packge for EQUITY-SFT Collection {}" [shares-amount package-share-tier id])
            )
        )
    )
    (defun UEV_EquitySemiFungibleID (id:string)
        (let
            (
                (ft:string (take 2 id))
                (sh:string "E|")
            )
            (enforce (= ft sh) "Only EQUITY SFT Collections allowed")
        )
    )
    (defun UEV_Convert (id:string input-tier:integer input-tier-amount:integer output-tier:integer)
        (UEV_SharePackageTier input-tier)
        (UEV_SharePackageTier output-tier)
        (let
            (
                (spm:[integer] (URC_SharesPerMillion id))
                (input-share-value:integer (at (- input-tier 1) spm))
                (output-share-value:integer (at (- output-tier 1) spm))
                (total-input-shares:integer (* input-share-value input-tier-amount))
                (mod-check (mod total-input-shares output-share-value))
            )
            (enforce (!= input-tier output-tier) "Input Tier and Output Tier must be different for Conversion")
            (enforce 
                (= mod-check 0) 
                (format "{} Tier {} Shares cannot be completly Converted to Tier {} Shares For Equity ID {}" [input-tier input-tier-amount output-tier id])
            )
        )
    )
    (defun UEV_Morph (input-nonce:integer output-nonce:integer)
        (let
            (
                (allowed-nonces:[integer] (enumerate 1 8))
                (iz-input:bool (contains input-nonce allowed-nonces))
                (iz-output:bool (contains output-nonce allowed-nonces))
            )
            (enforce (and iz-input iz-output) "Invalid Input or Output Nonces for Morphing")
            (enforce (!= input-nonce output-nonce) "Input and Output Nonces must be different for Morphing")
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_ConvertPackageShares:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string input-package-share-tier:integer input-package-share-tier-amount:integer output-package-share-tier:integer)
        @doc "Converts any Nonce to [2 3 4 5 6 7 8] to any Nonce [2 3 4 5 6 7 8]"
        (require-capability (SECURE))
        (with-capability (EQUITY|C>CONVERT id input-package-share-tier input-package-share-tier-amount output-package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (input-nonce:integer (+ 1 input-package-share-tier))
                    (output-nonce:integer (+ 1 output-package-share-tier))
                    (output-amount:integer (UC_Convert id input-package-share-tier input-package-share-tier-amount output-package-share-tier))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        ;;1]Transfer <input-package-share-tier> with <input-package-share-tier-amount> to <dpdc>
                        (ref-DPDC-T::C_Transfer [id] [true] account dpdc [[input-nonce]] [[input-package-share-tier-amount]] true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        ;;2]Burn it
                        (ref-DPDC-MNG::C_BurnSFT dpdc id input-nonce input-package-share-tier-amount)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        ;;3]Add Quantity <output-quantity> for the <output-nonce> on <dpdc> Account
                        (ref-DPDC-MNG::C_AddQuantity dpdc id output-nonce output-amount)
                    )
                    (ico4:object{IgnisCollectorV3.OutputCumulator}
                        ;;4]Transfer it to <account>
                        (ref-DPDC-T::C_Transfer [id] [true] dpdc account [[output-nonce]] [[output-amount]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [ico1 ico2 ico3 ico4] 
                    [[input-nonce output-nonce][input-package-share-tier-amount output-amount]]
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_MakePackageShares:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string shares-amount:integer package-share-tier:integer)
        @doc "Combines Nonce 1 to Nonce 2,3,4,5,6,7,8. \
            \ DPDC Audit #49L: this is an intentionally separate, bespoke implementation of the \
            \ same conceptual pattern as DPDC-S::C_MakeSemiFungibleSet/CC_BreakSemiFungibleSet -- EQUITY \
            \ wants freely-transferable tier tokens, not opaque set-bundles, so it shares no code with \
            \ DPDC-S. A future DPDC-S invariant fix will NOT automatically propagate here; cross-link \
            \ any such change to this pair of functions for manual review."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>MAKE id shares-amount package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (output-nonce:integer (+ 1 package-share-tier))
                    (output-amount:integer (URC_MakeSharePackage id shares-amount package-share-tier))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        ;;1]Transfer Shares to <dpdc>
                        (ref-DPDC-T::C_Transfer [id] [true] account dpdc [[1]] [[shares-amount]] true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        ;;2]Add Quantity for the Package-Share on <dpdc> Account
                        (ref-DPDC-MNG::C_AddQuantity dpdc id output-nonce output-amount)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        ;;3]Transfer it to <account>
                        (ref-DPDC-T::C_Transfer [id] [true] dpdc account [[output-nonce]] [[output-amount]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [ico1 ico2 ico3] 
                    [[1 output-nonce][shares-amount output-amount]]
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_BreakPackageShares:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string package-share-tier:integer amount:integer)
        @doc "Brakes Nonce 2,3,4,5,6,7,8 to Nonce 1. \
            \ DPDC Audit #49L: see XI_MakePackageShares's @doc -- intentionally bespoke vs. DPDC-S, \
            \ cross-link any DPDC-S Make/Break invariant change here for manual review."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>BREAK id package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (sspm:integer (URC_SingleSharePerMillions id package-share-tier))
                    (nonce-to-break:integer (+ package-share-tier 1))
                    (output-shares:integer (* sspm amount))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        ;;1]Transfer Package-Share-Tier nonce to dpdc
                        (ref-DPDC-T::C_Transfer [id] [true] account dpdc [[nonce-to-break]] [[amount]] true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        ;;2]Burn it
                        (ref-DPDC-MNG::C_BurnSFT dpdc id nonce-to-break amount)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        ;;3]Release Shares to <account>
                        (ref-DPDC-T::C_Transfer [id] [true] dpdc account [[1]] [[output-shares]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [ico1 ico2 ico3] 
                    [[nonce-to-break 1][amount output-shares]]
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_IssueShareholderCollection:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string creator-account:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
        @doc "Royalty is the standard Royalty for the Whole Collection \
            \ While <ignis-royalty> is the ignis Royalty for 1% of Company Shares"
        (P|UEV_IMC)
        ;;MUTE-GUARD FIX: this check used to live BELOW the let, and the let's <ico> binding ISSUES
        ;;the collection (DPDC-I::C_IssueDigitalCollection). Pact evaluates let bindings eagerly, so a
        ;;caller who passed the wrong number of links paid for a full collection issuance before the
        ;;link count was ever looked at -- and whenever that issuance failed first for its own reasons
        ;;(a duplicate collection name being the common one) this message could never be the one the
        ;;caller saw. It is a pure argument-shape check on a parameter, so it belongs here, ahead of
        ;;every read and every write. Pinned by REPL/modules/DPDC.repl <<DPDC-G20>>.
        (enforce (= (length ipfs-links) 24)
            "24 IPFS links must be provided for an Equity Collection")
        (let
            (
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                (ref-DPDC-I:module{DpdcIssueV2} DPDC-I)
                ;;
                (special-sft:[string] (ref-U|VST::UC_EquityID collection-name collection-ticker))
                (name:string (at 0 special-sft))
                (ticker:string (at 1 special-sft))
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                ;;
                (b:string BAR)
                (zd:object{DpdcUdcV2.URI|Data} (ref-DPDC-UDC::UDC_ZeroURI|Data))
                (md:object{DpdcUdcV2.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (n:[string] (UC_Name collection-name))
                (d:[string] (UC_Description collection-name))
                (type:object{DpdcUdcV2.URI|Type} (ref-DPDC-UDC::UDC_URI|Type true false false false false false false))
                ;;
                (ico:object{IgnisCollectorV3.OutputCumulator}
                    ;;1]Issue Equity SFT Collection; <dpdc> automatically gets <role-nft-add-quantity> and <role-nft-burn>
                    (ref-DPDC-I::C_IssueDigitalCollection
                        patron true
                        dpdc creator-account name ticker
                        false false true true
                        true true true false
                        true
                    )
                )
                (equity-id:string (at 0 (at "output" ico)))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                [
                    ico
                    ;;2]Equity premium: $100 flat in IGNIS (owner 2026-09-05), central IG|DETER
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_IssueCompany" "issue-shareholder")
                dpdc (ref-IGNIS::URC_IsVirtualGasZero) [])
                    ;;3]Populate Equity SFT Collection
                    (ref-DPDC-C::C_CreateNewNonces
                        equity-id true [1000000 0 0 0 0 0 0 0]
                        [
                            ;;Barebone Share, Nonce 1
                            (ref-DPDC-UDC::UDC_NonceData royalty 0.001 (at 0 n) (at 0 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 0 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 8 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 16 ipfs-links) b b b b b b)
                            )
                            ;;0.1 Promille representing 100 Shares per Million, Nonce 2
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 100.0) (at 1 n) (at 1 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 1 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 9 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 17 ipfs-links) b b b b b b)
                            )
                            ;;0.2 Promille representing 200 Shares per Million, Nonce 3
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 50.0) (at 2 n) (at 2 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 2 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 10 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 18 ipfs-links) b b b b b b)
                            )
                            ;;0.5 Promille representing 500 Shares per Million, Nonce 4
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 20.0) (at 3 n) (at 3 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 3 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 11 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 19 ipfs-links) b b b b b b)
                            )
                            ;;1 Promille representing 1000 Shares per Million, Nonce 5
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 10.0) (at 4 n) (at 4 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 4 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 12 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 20 ipfs-links) b b b b b b)
                            )
                            ;;2 Promille representing 2000 Shares per Million, Nonce 6
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 5.0) (at 5 n) (at 5 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 5 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 13 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 21 ipfs-links) b b b b b b)
                            )
                            ;;5 Promille representing 5000 Shares per Million, Nonce 7
                            (ref-DPDC-UDC::UDC_NonceData royalty (/ ignis-royalty 2.0) (at 6 n) (at 6 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 6 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 14 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 22 ipfs-links) b b b b b b)
                            )
                            ;;1 Percent representing 10000 Shares per Million, Nonce 8
                            (ref-DPDC-UDC::UDC_NonceData royalty ignis-royalty (at 7 n) (at 7 d) md type
                                (ref-DPDC-UDC::UDC_URI|Data (at 7 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 15 ipfs-links) b b b b b b)
                                (ref-DPDC-UDC::UDC_URI|Data (at 23 ipfs-links) b b b b b b)
                            )
                        ]
                    )
                ]
                [equity-id]
            )
        )
    )
    (defun C_MorphPackageShares:object{IgnisCollectorV3.OutputCumulator}
        (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        (P|UEV_IMC)
        (UEV_Morph input-nonce output-nonce)
        (with-capability (SECURE)
            (if (= input-nonce 1)
                ;;Make Package Shares
                (XI_MakePackageShares account id input-amount (- output-nonce 1))
                (if (= output-nonce 1)
                    ;;Brake Package Shares
                    (XI_BreakPackageShares account id (- input-nonce 1) input-amount)
                    ;;Convert Package Shares
                    (XI_ConvertPackageShares account id (- input-nonce 1) input-amount (- output-nonce 1))
                )
            )
        )
    )

)

;; --- tables for 11_EQUITY+.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact ======
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DemiourgosLaunchpadV2
    @doc "Sovereign interface defining the API for the DemiPad launchpad, a permissioned \
        \ venue where Demiourgos.Holdings sells assets (true/orto/semi/non-fungibles) for \
        \ WSTOA, SSTOA or OURO while retaining a decreasing royalty fee. It declares schemas \
        \ for Costs, launchpad Properties, per-asset Holdings, Prices and RoyaltyInterval, \
        \ plus constructors, compute helpers (royalty intervals, deposit royalty, \
        \ environment split), and readers for launchpad and asset state. It also exposes \
        \ acquire/price computation, IGNIS cost-preview deposit/transmit functions, \
        \ fungibility validators, owner capabilities, admin operations (register asset, \
        \ toggle sale/retrieval, define price), and client deposit/withdraw/transmit \
        \ entrypoints."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    ;;
    (defun GOV|DEMIPAD|SC_NAME ())

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
    ;;  [Schemas]
    ;;
    (defschema Costs
        pid:decimal
        wstoa:decimal
    )
    ;;
    (defschema DEMIPAD|Properties
        direct-injection:bool
        resident-wstoa:decimal
        resident-sstoa:decimal
        resident-ouro:decimal
    )
    (defschema DEMIPAD|Holdings
        total-dollarz-raised:decimal
        total-wstoa-raised:decimal
        total-sstoa-raised:decimal
        total-ouro-raised:decimal
        funds-wstoa:decimal
        funds-sstoa:decimal
        funds-ouro:decimal
        ;;
        iz-sstoa:bool
        iz-ouro:bool
        ;;
        fungibility:[bool]
        open-for-business:bool
        price:object
        retrieval:bool
    )
    (defschema DEMIPAD|Prices
        receiver-one:string
        receiver-two:string
        receiver-three:string
        receiver-four:string
        amount-one:decimal
        amount-two:decimal
        amount-three:decimal
        amount-four:decimal
        enviroment-amount:decimal
        coding-amount:decimal
        remainder-amount:decimal
    )
    (defschema RoyaltyInterval
        "Schema for fee intervals"
        start:decimal
        end:decimal
        fee-promille:decimal
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
    (defun UDC_Costs:object{Costs} (a:decimal b:decimal))
    (defun UDC_DEMIPAD|Holdings:object{DEMIPAD|Holdings}
        (
            a:decimal b:decimal c:decimal d:decimal
            e:decimal f:decimal g:decimal
            h:bool i:bool
            j:[bool] k:bool l:object m:bool
        )
    )
    (defun UDC_LaunchpadPrices:object{DEMIPAD|Prices}
        (
            a:string b:string c:string d:string
            e:decimal f:decimal g:decimal h:decimal
            j:decimal k:decimal l:decimal
        )
    )
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    (defun UC_Type:string (asset-id:string fungibility:[bool]))
    (defun UC_GenerateRoyaltyIntervals:[object{RoyaltyInterval}] ())
    (defun UCv_ComputeDepositRoyalty:decimal (current-balance:decimal deposit-amount:decimal))
    (defun UC_LaunchpadEnviromentSplit:[decimal] (amount-in-stoa:decimal))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UR]
    ;;
    (defun UR_LaunchpadState:object{DEMIPAD|Properties} ())
    (defun UR_DirectInjection:bool ())
    (defun UR_WSTOA:decimal ())
    (defun UR_SSTOA:decimal ())
    (defun UR_OURO:decimal ())
        ;;
    (defun UR_AssetState:object{DEMIPAD|Holdings} (asset-id:string))
    (defun UR_TotalDollarzRaised:decimal (asset-id:string))
    (defun UR_TotalWSTOARaised:decimal (asset-id:string))
    (defun UR_TotalSSTOARaised:decimal (asset-id:string))
    (defun UR_TotalOURORaised:decimal (asset-id:string))
    (defun UR_WSTOA|Funds:decimal (asset-id:string))
    (defun UR_SSTOA|Funds:decimal (asset-id:string))
    (defun UR_OURO|Funds:decimal (asset-id:string))
        ;;
    (defun UR_IzSSTOA:bool (asset-id:string))
    (defun UR_IzOURO:bool (asset-id:string))
    (defun UR_Fungibility:[bool] (asset-id:string))
    (defun UR_OpenForBusiness:bool (asset-id:string))
    (defun UR_Price:object (asset-id:string))
    (defun UR_Retrieval:bool (asset-id:string))
    (defun UR_CheckRegistration:bool (asset-id:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_Prices:object{DEMIPAD|Prices} (asset-id:string amount-in-dollars:decimal type:integer))
    (defun URC_Acquire:[string] (buyer:string asset-id:string buy-amount-in-dollarz:decimal type:integer slippage:decimal))
    (defun URCi_Deposit:object{IgnisCollectorV3.OutputCumulator}
        (donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool)
    )
    (defun URCi_TransmitSemiFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
    )
    (defun URCi_TransmitNonFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire (buyer:string asset-id:string buy-amount-in-dollarz:decimal type:integer))
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_AssetFungibility (asset-id:string fungibility-to-check:[bool]))
    (defun UEV_Fungibility (fungibility:[bool]))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_Owner (asset-id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun A_RegisterAssetToLaunchpad (patron:string asset-id:string fungibility:[bool]))
    (defun A_ToggleOpenForBusiness (asset-id:string toggle:bool))
    (defun A_DefinePrice (asset-id:string price:object))
    (defun A_ToggleRetrieval (asset-id:string toggle:bool))
    ;;
    ;;  [C]
    ;;
    (defun C_Deposit:object{IgnisCollectorV3.OutputCumulator}
        (donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
    )
    (defun C_Withdraw (patron:string asset-id:string type:integer destination:string)
    )
    ;;
    (defun C_TransmitTrueFungible (patron:string client:string asset-id:string amount:decimal fuel-or-retrieve:bool))
    (defun C_TransmitOrtoFungible (patron:string client:string asset-id:string nonces:[integer] fuel-or-retrieve:bool))
    (defun C_TransmitSemiFungibles:object{IgnisCollectorV3.OutputCumulator} 
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
    )
    (defun C_TransmitNonFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
    )

)
(module DEMIPAD GOV
    @doc "Demiourgos Launchpad, is a permissioned Launchpad operated by Demiourgos.Holdings  \
        \ allowing the Company to sell Assets (DPTFs, DPMFs, DPSFs and DPNFs) \
        \ \
        \ HOW IT WORKS: \
        \ The Launchpad Admin registers an Asset for Sale, this Asset is then Permanently registered to the Launchpad \
        \ Sale is executed via Functions, in Modules created by Demiourgos Holdings, specific to each Asset \
        \ \
        \ For Sale, both Native STOA and WSTOA are accepted, but also SSTOA or OURO \
        \ \
        \ From the incoming funds, The Launchpad Retains a Royalty Fee. This starts at 15%. \
        \ The Royalty Decreases going as low as 0.3% the more an asset sales for. \
        \ One THIRD of Royalty goes to the Enviroment as Native STOA (Unwrap would be executed if WSTOA Input is used): \
        \       = 10% to Ouronet Gas Station \
        \       = 20% to Demiourgos.Holdings Treasury \
        \       = 30$ to Launchpad Maintanance \
        \       = 40% to Liquid Staking \
        \ TWO THIRDS is injected to Coding Division Pot (half to Coding Division Collection, half to Shareholders Collection) \
        \       when acquisitions pool are coming Live \
        \       Until then, it will be retained in the Pool as Resident WSTOA, SSTOA or OURO \
        \ \
        \ If Assets are Sold for SSTOA or OURO, then a third of the Royalty Fee, must be supplied as Native Stoa to satisfy the Enviroment \
        \ \
        \ Remaining Tokens (after Royalty deduction) can be withdrawn by Asset Owner or Creator (for SFTs and NFTs), or Launchpad Admin \
        \ \
        \ Launchpad Admin can update <open-for-business>, <price> and <retrieval> for each registered Asset \
        \ \
        \ <open-for-business>   = Determines if the Asset is on sale and if it can be bought by those that want to acquire it \
        \ <price> object        = Holds information regarding the Sale Price. This is then used by the Individual Asset Modules in the Sale Function \
        \ <retrieval> parameter = Defines if Asset Owners or Creators can withdraw their Assets from the Launchpad (default false) \
        \                       If set to <false> the only way to retrieve Assets is to execute a buy(sale). \
        \ \
        \ Each Asset has its own Sale Module, that defines the logic of the Buy Functions, allowing for individual custom logic to be implemented for each Sale \
        \ Which is the reason this is a permissioned Launchpad, as each Sale can have its own specific logic regarding Asset Acquisition \
        \ \
        \ \
        \ \
        \ Permissioned Launchpad, means its part of the Core Modules from Stage 2 \
        \ A permissionless Launchpad, in the form of the IGNIS Market Place will be launched after the Acquisition Pools Deployment"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DemiourgosLaunchpadV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DEMIPAD                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DEMIPAD_ADMIN)))
    (defcap GOV|DEMIPAD_ADMIN ()                        (enforce-guard GOV|MD_DEMIPAD))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|LaunchpadKey ()                          (+ (CT_Namespace) ".dh_sc_mb-keyset"))
    ;;(defun GOV|LaunchpadKey ()              (+ (CT_Namespace) ".dh_sc_demipad-keyset"))
    ;;
    ;; [SC-Names]
    (defun GOV|DEMIPAD|SC_NAME ()                       (at 0 ["Σ.Îäć$ЬчýφVεÎÿůпΨÖůηüηŞйnюŽXΣşpЩß5ςĂκ£RäbE₳èËłŹŘYшÆgлoюýRαѺÑÏρζt∇ŹÏýжIŒațэVÞÛщŹЭδźvëȘĂтPЖÃÇЭiërđÈÝДÖšжzČđзUĚĂsкιnãñOÔIKпŞΛI₳zÄû$ρśθ6ΨЬпYпĞHöÝйÏюşí2ćщÞΔΔŻTж€₿ŞhTțŽ"]))
    ;;
    ;; [PBLs]
    (defun GOV|DEMIPAD|PBL ()                           (at 0 ["9F.gGCkuc2wMAnFAjuFphikftLdl6qFqBD4yfeMEe9u65yMqf4r340Jd6dphh1d7E1cE20btMwl4HJ2cBEMvp209GA1eD4syB96hu4nmpFbB7dKnJEMz4p8fGLcmhvrBCfDmM0axnGin8qedl5vDtwbgL3l1aK5BsmjkEEJartqCH8qG8ialtjxwCcIMf50t2lkeww6Dct5LlmmLG25FmfpcgnwMMnkJl4Gfn9gwoA6vm0jKebjhodeJLjxnh9L11ss8f26866dqv1tEphxFFqutGetH4Itj3rHkrcrGsnlqpf4gfJp94b0gBwIBe4vCj6ha8jm6kd3f8B6pEaJtkJ3fbs6rCcGibltz1BAMn0vvKME5ddFyGBnzssk1s2s0vFzwxs6vjC61Ma2l1xDxqdg1thAk2u01hDiGndLhzK73HAfgtk7bxscn0qKhymG6JAqnEFt282pyHAq5nIthK9bA8nH76x7FEpLz4eK9tLIBsyjb8M5DxaeEei6pEnLxFCAg7ulacgtjjpjMiAaqhpmM1jEHqjt4G85q4L33zrME7whgIkIpIgwnF2qKd4"]))

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
    (defcap P|DEMIPAD|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DEMIPAD|CALLER))
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
        (with-capability (GOV|DEMIPAD_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|DEMIPAD_ADMIN)
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
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (mg:guard (create-capability-guard (P|DEMIPAD|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_KEY                            (GOV|LaunchpadKey))
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst MB|SC_STOA-NAME                           "k:xxx")
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst TF                                        [true true])
    (defconst OF                                        [true false])
    (defconst SF                                        [false true])
    (defconst NF                                        [false false])
    ;;
    (defconst PP                                        "Launchpad-Properties")
    ;;{3.2}  schemas
    ;;{3.3}  tables
    ;;
    (deftable DEMIPAD|T|Properties:{DemiourgosLaunchpadV2.DEMIPAD|Properties})
    (deftable DEMIPAD|T|Ledger:{DemiourgosLaunchpadV2.DEMIPAD|Holdings})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap DEMIPAD|GOV ()
        @doc "Governor Capability for the DEMIPAD Smart DALOS Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;
    ;;#2H: the retrieval lock the launchpad advertises to buyers. A non-admin Owner/Creator may pull
    ;;    deposited assets back out ONLY when retrieval is enabled; the Launchpad admin may always
    ;;    retrieve. FUEL (deposit) is never gated — only RETRIEVE composes this. (Option A: admin override.)
    (defcap DEMIPAD|C>RETRIEVAL-GATE (asset-id:string)
        (enforce-one
            (format "Asset {} retrieval is LOCKED (retrieval=false) — only the Launchpad admin may retrieve until a sale or an admin re-enable" [asset-id])
            [
                (enforce-guard GOV|MD_DEMIPAD)
                (enforce (UR_Retrieval asset-id) "retrieval disabled")
            ]
        )
    )
    ;;{C3}  Composed
    (defcap DEMIPAD|C>REGISTER (asset-id:string fungibility:[bool])
        @event
        (compose-capability (DEMIPAD|C>SECURE-ADMIN))
        (UEV_Fungibility fungibility)
    )
    (defcap DEMIPAD|C>SECURE-ADMIN ()
        (compose-capability (GOV|DEMIPAD_ADMIN))
        (compose-capability (SECURE))
    )
    ;;
    (defcap DEMIPAD|C>TOGGLE-SALE (asset-id:string toggle:bool)
        @event
        (compose-capability (DEMIPAD|C>SECURE-ADMIN))
        (let
            (
                (ofb:bool (UR_OpenForBusiness asset-id))
            )
            (enforce (!= toggle ofb) (format "Open for business is already {} for Asset {}" [toggle asset-id]))
        )
    )
    (defcap DEMIPAD|C>DEFINE-PRICE (asset-id:string price:object)
        @event
        (compose-capability (DEMIPAD|C>SECURE-ADMIN))
    )
    (defcap DEMIPAD|C>TOGGLE-RETRIEVAL (asset-id:string toggle:bool)
        @event
        (compose-capability (DEMIPAD|C>SECURE-ADMIN))
        (let
            (
                (rtr:bool (UR_Retrieval asset-id))
            )
            (enforce (!= toggle rtr) (format "Retrieval is already {} for Asset {}" [toggle asset-id]))
        )
    )
    ;;
    ;;
    (defcap DEMIPAD|C>FUEL-TRUE-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [true true]))
    )
    (defcap DEMIPAD|C>FUEL-ORTO-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [true false]))
    )
    (defcap DEMIPAD|C>FUEL-SEMI-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [false true]))
    )
    (defcap DEMIPAD|C>FUEL-NON-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [false false]))
    )
    ;;
    (defcap DEMIPAD|C>RETRIEVE-TRUE-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>RETRIEVAL-GATE asset-id))
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [true true]))
    )
    (defcap DEMIPAD|C>RETRIEVE-ORTO-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>RETRIEVAL-GATE asset-id))
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [true false]))
    )
    (defcap DEMIPAD|C>RETRIEVE-SEMI-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>RETRIEVAL-GATE asset-id))
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [false true]))
    )
    (defcap DEMIPAD|C>RETRIEVE-NON-FUNGIBLE (asset-id:string)
        @event
        (compose-capability (DEMIPAD|C>RETRIEVAL-GATE asset-id))
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE asset-id [false false]))
    )
    ;;
    (defcap DEMIPAD|C>REGISTERED-ACCESS-BY-TYPE (asset-id:string fungibility:[bool])
        (compose-capability (DEMIPAD|C>REGISTERED-ACCESS asset-id))
        (UEV_AssetFungibility asset-id fungibility)
    )
    ;;
    (defcap DEMIPAD|C>REGISTERED-ACCESS (asset-id:string)
        @doc "Fails is <asset-id> is not registered to Launchpad"
        (enforce-one
            (format "Only LPAD Admin or {} Owner|Creator may acces the Launchpad" [asset-id])
            [
                (enforce-guard (create-user-guard (CAP_Owner asset-id)))
                (enforce-guard GOV|MD_DEMIPAD)
            ]
        )
        (compose-capability (DEMIPAD|GOV))
        (compose-capability (SECURE))
    )
    ;;Deposti and Withdrawal
    ;;Module-local (no interface change): the single source for "is this a spendable dollar
    ;;amount". Shared by DEMIPAD|C>DEPOSIT and URCi_Deposit so every launchpad quote and the
    ;;deposit it previews refuse the same inputs, in the same words.
    ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-006b/c>>.
    (defun UEV_DepositDollarAmount (amount-in-dollars:decimal)
        (enforce
            (and
                (= (floor amount-in-dollars 24) amount-in-dollars)
                (> amount-in-dollars 0.0)
            )
            "Invalid Dollar Amount for Deposit"
        )
    )
    (defcap DEMIPAD|C>DEPOSIT (donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-type:bool (contains type [0 1 2 3]))
                (iz-registered:bool (UR_CheckRegistration asset-id))
                (ofb:bool (UR_OpenForBusiness asset-id))
                (iz-sstoa:bool (UR_IzSSTOA asset-id))
                (iz-ouro:bool (UR_IzOURO asset-id))
            )
            ;;Validate <donor> to be Standard Ouronet Account
            (ref-DALOS::UEV_EnforceAccountType donor false)
            ;;Validate <asset-id> to be a Launchpad registered Asset
            ;;FIXED 2026-09-12, owner-ruled. This message used to be UNREACHABLE: the `let` above
            ;;binds FOUR reads of this same Ledger row and a `let` is EAGER, so `ofb`, `iz-sstoa` and
            ;;`iz-ouro` -- then bare `read`s -- ran BEFORE this enforce and aborted the transaction
            ;;with `No value found in table ... DEMIPAD|T|Ledger for key: <asset>`. The deposit was
            ;;still refused (never a funds hole), but the sentence written for exactly that case
            ;;never arrived. Owner ruling: make every reader SUCCEED to true/false rather than abort.
            ;;All three are now `with-default-read`, matching what UR_CheckRegistration already did
            ;;with its `(try false ...)`. Pinned by REPL/Stage_02/[5.3]_Launchpad.repl <<TX-DEP-02>>
            ;;01b. See memories/2026-09-12-eager-let-mute-guards.md
            (enforce iz-registered (format "Asset {} is not registered to the Demiourgos Lauchpad. Deposit unallowed" [asset-id]))
            ;;Validate the <amount-in-dollars> to be greater than zero with 3 decimals.
            ;;REFUSAL PARITY (family K, 2026-09-16): this enforce used to be written out here, so
            ;;URCi_Deposit -- and therefore EVERY launchpad preview that prices a purchase through
            ;;it -- had no way to share it. INFO_BuySparks quoted a buy of ZERO Sparks that this
            ;;line refuses, and for a NEGATIVE amount the preview refused with someone else's
            ;;message ("Deposit amount must be non-negative", reached incidentally from
            ;;UCv_ComputeDepositRoyalty). Now in UEV_DepositDollarAmount, called by both.
            (UEV_DepositDollarAmount amount-in-dollars)
            ;;Slippage bound (Variant 1): the live-computed dollar cost must not exceed the buyer's
            ;;signed ceiling <max-cost>. Sentinel <max-cost> < 0 = no bound (Variant 2, slippage off).
            (UEV_SlippageCost amount-in-dollars max-cost)
            ;;Validate <type> to be either 0, 1, 2 or 3, and that the required Token Deposit is turned on
            (enforce iz-type "Invalid Deposit type")
            ;;MESSAGE FIXED 2026-09-14. The type-3 branch enforces <iz-ouro> and used to report
            ;;"SSTOA Deposits must be turned on" -- naming a DIFFERENT, separately-togglable admin
            ;;flag. That is the actively-misleading shape, not merely a terse one: the operator CAN
            ;;carry out the suggested remedy, turn SSTOA deposits on, observe nothing change, and
            ;;retry forever. Same class as DALOS GOV|MIGRATE's inverted pause message, fixed the
            ;;same day. Each branch now names the flag it actually reads.
            (if (not (or (= type 0) (= type 1)))
                (if (= type 2)
                    (enforce iz-sstoa "SSTOA Deposits must be turned on for exec")
                    (enforce iz-ouro "OURO Deposits must be turned on for exec")
                )
                true
            )
            ;;Direct-Injection is an unbuilt feature (routes the <cod> royalty into an
            ;;injection profile once AQP vaults are live). It is HARD-BLOCKED here so no
            ;;admin flag can half-enable the unfinished path (prevents phantom seller funds).
            (UEV_DirectInjection direct-injection)
            ;;<open-for-business> must be turned on to allow Deposits
            (enforce ofb (format "{} is not open for business, to allow deposits" [asset-id]))
            ;;Acces Capabilities
            (compose-capability (DEMIPAD|GOV))
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap DEMIPAD|C>WITHDRAW (asset-id:string type:integer retrieval-amount:decimal destination:string )
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-type:bool (contains type [1 2 3]))
            )
            ;;Validate <type> to be either 1, 2 or 3, and that the required Token Deposit is on.
            ;;
            ;;SHADOWED AT TODAY'S ONLY CALL SITE - kept deliberately. C_Withdraw binds
            ;;(URv_Funds asset-id type) BEFORE acquiring this capability, and URv_Funds opens with
            ;;the IDENTICAL predicate under a different message, so an out-of-range <type> always
            ;;aborts there with "Invalid Read Type" and this line never fires. It is NOT a hole:
            ;;the input is still rejected, only the message is less specific.
            ;;
            ;;Not removed, and not "fixed" by restructuring: <retrieval-amount> is a parameter of
            ;;this @event capability and the body needs it for the transfer, so the read must
            ;;happen first - and moving it inside would change an EVENT SIGNATURE that indexers
            ;;consume. This enforce is the defence-in-depth that makes the capability correct on
            ;;its own terms for any FUTURE caller that does not read first. Pinned as-is in
            ;;REPL/Stage_02/[5.3]_Launchpad.repl <<TX-DEP-02>>.
            ;;UNREACHABLE (shadowed) -- the analysis above is the proof; this marker is what keeps
            ;;it out of the pinning worklist. Same category as 05_DPTF:1004: not dead, not a hole,
            ;;simply answered earlier by an identical predicate on every path that exists today.
            ;;Revisit if a call site is ever added that does NOT read URv_Funds first.
            (enforce iz-type "Invalid Withdrawal type")
            ;;Validate <retrieval-amount> to be non-zero
            (enforce 
                (> retrieval-amount 0.0) 
                (format "There is nothing to retrieve for Asset-Id {} and Token Type {} ({})." 
                    [
                        asset-id
                        type
                        (if (= type 1) "WSTOA" (if (= type 2) "SSTOA" "OURO"))
                    ]
                )
            )
            ;;Validate <destination> to be Standard Ouronet Account
            (ref-DALOS::UEV_EnforceAccountType destination false)
            ;;Only <asset-id> Owner|Creator, or Launchpad Admin can retrieve Launchpad Funds
            (compose-capability (DEMIPAD|C>REGISTERED-ACCESS asset-id))
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
    (defun UDC_Costs:object{DemiourgosLaunchpadV2.Costs} 
        (a:decimal b:decimal)
        {"pid"  : a
        ,"wstoa" : b}
    )
    (defun UDC_DEMIPAD|Holdings:object{DemiourgosLaunchpadV2.DEMIPAD|Holdings}
        (
            a:decimal b:decimal c:decimal d:decimal
            e:decimal f:decimal g:decimal
            h:bool i:bool
            j:[bool] k:bool l:object m:bool
        )
        {"total-dollarz-raised"         : a
        ,"total-wstoa-raised"            : b
        ,"total-sstoa-raised"            : c
        ,"total-ouro-raised"            : d
        ,"funds-wstoa"                   : e
        ,"funds-sstoa"                   : f
        ,"funds-ouro"                   : g
        ;;
        ,"iz-sstoa"                      : h
        ,"iz-ouro"                      : i
        ;;
        ,"fungibility"                  : j
        ,"open-for-business"            : k
        ,"price"                        : l
        ,"retrieval"                    : m
        }
    )
    (defun UDC_LaunchpadPrices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices}
        (
            a:string b:string c:string d:string
            e:decimal f:decimal g:decimal h:decimal
            j:decimal k:decimal l:decimal
        )
        {"receiver-one"         : a
        ,"receiver-two"         : b
        ,"receiver-three"       : c
        ,"receiver-four"        : d
        ,"amount-one"           : e
        ,"amount-two"           : f
        ,"amount-three"         : g
        ,"amount-four"          : h
        ,"enviroment-amount"    : j
        ,"coding-amount"        : k
        ,"remainder-amount"     : l}
    )
    ;;{5.2}  Compute [UC]
    (defun UC_Type:string (asset-id:string fungibility:[bool])
        (cond
            ((= fungibility TF) "True Fungible")
            ((= fungibility OF) "Orto-Fungible")
            ((= fungibility SF) "Semi-Fungible")
            ((= fungibility NF) "Non-Fungible")
            ""
        )
    )
    (defun UC_GenerateRoyaltyIntervals:[object{DemiourgosLaunchpadV2.RoyaltyInterval}] ()
        @doc "Generate list of fee intervals until fee reaches 3 promille"
        (let* 
            (
                (first-interval-size:decimal 10000.0)
                (initial-increment:decimal 5000.0)
                (fee-decrement:decimal 3.0)
                (min-fee:decimal 3.0)
            )
            (fold
                (lambda 
                    (acc:[object{DemiourgosLaunchpadV2.RoyaltyInterval}] idx:integer)
                    (let* 
                        (
                            (start:decimal
                                (if (= idx 0)
                                    0.0
                                    (at "end" (at 0 (take -1 acc)))
                                )
                            )
                            (increment-velocity:decimal 
                                (if (= idx 0)
                                    0.0
                                    (+ initial-increment (* 100.0 (dec (- idx 1)))))
                                )
                                
                            (prev-interval-size:decimal
                                (if (= idx 0)
                                    first-interval-size
                                    (-
                                        (at "end" (at 0 (take -1 acc)))
                                        (at "start" (at 0 (take -1 acc)))
                                    )
                                )
                            )
                            (increment:decimal (+ increment-velocity prev-interval-size))
                            (end:decimal 
                                (if (= idx 0)
                                    first-interval-size
                                    (+ start increment)
                                )
                            )
                            (fee-promille (- 150.0 (* fee-decrement (dec idx))))
                        )
                        (if (>= fee-promille min-fee)
                            (+ acc [{"start": start, "end": end, "fee-promille": fee-promille}])
                            acc
                        )
                    )
                )
                []
                (enumerate 0 49)
            )
        )
    )
    (defun UC_SlippageFactor:decimal (slippage:decimal)
        @doc "Pure slippage multiplier: (1 + slippage/100). slippage is a percent (1.0 = 1%). Used to pad \
            \ the signed coin.TRANSFER cap ceilings in URC_Acquire (Variant 1)."
        (+ 1.0 (/ slippage 100.0))
    )
    (defun UCv_ComputeDepositRoyalty:decimal (current-balance:decimal deposit-amount:decimal)
        @doc "Compute fee for a deposit given current balance and deposit amount"
        (enforce (>= current-balance 0.0) "Current balance must be non-negative")
        (enforce (>= deposit-amount 0.0) "Deposit amount must be non-negative")
        (let* 
            (
                (deposit-start:decimal current-balance)
                (deposit-end:decimal (+ current-balance deposit-amount))
                (intervals:[object{DemiourgosLaunchpadV2.RoyaltyInterval}] (UC_GenerateRoyaltyIntervals))
                (last-interval:object{DemiourgosLaunchpadV2.RoyaltyInterval} (at (- (length intervals) 1) intervals) )
                (last-interval-end:decimal (at "end" last-interval))
                (min-fee:decimal (at "fee-promille" last-interval))
                (min-fee-rate:decimal (/ min-fee 1000.0))
            )
            (+
                ;;Interval Fees
                (fold
                    (lambda (total-fee:decimal interval:object{DemiourgosLaunchpadV2.RoyaltyInterval})
                        (let 
                            (
                                (interval-start (at "start" interval))
                                (interval-end (at "end" interval))
                                (fee-rate (/ (at "fee-promille" interval) 1000.0))
                            )
                            (if (and (< deposit-start interval-end) (> deposit-end interval-start))
                                (+ 
                                    total-fee
                                    (* 
                                        fee-rate
                                        (- 
                                            (if (<= deposit-end interval-end) deposit-end interval-end)
                                            (if (>= deposit-start interval-start) deposit-start interval-start)
                                        )
                                    )
                                )
                                total-fee
                            )
                        )
                    )
                    0.0
                    intervals
                )
                ;;Beyond Fees
                (if (> deposit-end last-interval-end)
                    (* 
                        min-fee-rate
                        (- 
                            deposit-end 
                            (if (>= deposit-start last-interval-end) deposit-start last-interval-end)
                        )
                    )
                    0.0
                )
            )
        )
    )
    (defun UC_LaunchpadEnviromentSplit:[decimal] (amount-in-stoa:decimal)
        @doc "Outputs the Launchpad Enviroment Split, whic is a \
        \ 10%, 20%, 30%, 40% Split, outputed as a 4 element list."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
            )
            (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit amount-in-stoa stoa-prec)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_LaunchpadState:object{DemiourgosLaunchpadV2.DEMIPAD|Properties} ()
        (read DEMIPAD|T|Properties PP)
    )
    (defun UR_DirectInjection:bool ()
        (at "direct-injection" (UR_LaunchpadState))
    )
    (defun UR_WSTOA:decimal ()
        (at "resident-wstoa" (UR_LaunchpadState))
    )
    (defun UR_SSTOA:decimal ()
        (at "resident-sstoa" (UR_LaunchpadState))
    )
    (defun UR_OURO:decimal ()
        (at "resident-ouro" (UR_LaunchpadState))
    )
    ;;
    (defun UR_AssetState:object{DemiourgosLaunchpadV2.DEMIPAD|Holdings} (asset-id:string)
        (read DEMIPAD|T|Ledger asset-id)
    )
    (defun UR_TotalDollarzRaised:decimal (asset-id:string)
        (at "total-dollarz-raised" (read DEMIPAD|T|Ledger asset-id ["total-dollarz-raised"]))
    )
    (defun URv_TotalRaised:decimal (asset-id:string type:integer)
        (enforce (contains type [1 2 3]) "Invalid Read Type")
        (cond
            ((= type 1) (UR_TotalWSTOARaised asset-id))
            ((= type 2) (UR_TotalSSTOARaised asset-id))
            ((= type 3) (UR_TotalOURORaised asset-id))
            0.0
        )
    )
    (defun URv_Funds:decimal (asset-id:string type:integer)
        (enforce (contains type [1 2 3]) "Invalid Read Type")
        (cond
            ((= type 1) (UR_WSTOA|Funds asset-id))
            ((= type 2) (UR_SSTOA|Funds asset-id))
            ((= type 3) (UR_OURO|Funds asset-id))
            0.0
        )
    )
    (defun UR_TotalWSTOARaised:decimal (asset-id:string)
        (at "total-wstoa-raised" (read DEMIPAD|T|Ledger asset-id ["total-wstoa-raised"]))
    )
    (defun UR_TotalSSTOARaised:decimal (asset-id:string)
        (at "total-sstoa-raised" (read DEMIPAD|T|Ledger asset-id ["total-sstoa-raised"]))
    )
    (defun UR_TotalOURORaised:decimal (asset-id:string)
        (at "total-ouro-raised" (read DEMIPAD|T|Ledger asset-id ["total-ouro-raised"]))
    )
    (defun UR_WSTOA|Funds:decimal (asset-id:string)
        (at "funds-wstoa" (read DEMIPAD|T|Ledger asset-id ["funds-wstoa"]))
    )
    (defun UR_SSTOA|Funds:decimal (asset-id:string)
        (at "funds-sstoa" (read DEMIPAD|T|Ledger asset-id ["funds-sstoa"]))
    )
    (defun UR_OURO|Funds:decimal (asset-id:string)
        (at "funds-ouro" (read DEMIPAD|T|Ledger asset-id ["funds-ouro"]))
    )
    ;;
    (defun UR_IzSSTOA:bool (asset-id:string)
        ;;with-default-read, not read: an UNREGISTERED asset has no row, and a bare read would abort
        ;;the transaction before any caller's `enforce` could speak. See the note on UR_CheckRegistration.
        (with-default-read DEMIPAD|T|Ledger asset-id
            { "iz-sstoa" : false } { "iz-sstoa" := x } x)
    )
    (defun UR_IzOURO:bool (asset-id:string)
        ;;with-default-read, not read -- same reason as UR_IzSSTOA above.
        (with-default-read DEMIPAD|T|Ledger asset-id
            { "iz-ouro" : false } { "iz-ouro" := x } x)
    )
    (defun UR_Fungibility:[bool] (asset-id:string)
        (at "fungibility" (read DEMIPAD|T|Ledger asset-id ["fungibility"]))
    )
    (defun UR_OpenForBusiness:bool (asset-id:string)
        ;;with-default-read, not read. FALSE is the semantically correct answer for an asset with no
        ;;Ledger row -- a thing that is not registered is certainly not open for business -- and it
        ;;lets DEMIPAD|C>DEPOSIT's registration enforce actually be reached. All four call sites were
        ;;checked: the two in this module, 2_CITIZEN/.../01_Spark.pact and Stage_Z/01_DPL-UR.pact;
        ;;every one of them is better served by `false` than by an aborted transaction.
        (with-default-read DEMIPAD|T|Ledger asset-id
            { "open-for-business" : false } { "open-for-business" := x } x)
    )
    (defun UR_Price:object (asset-id:string)
        (at "price" (read DEMIPAD|T|Ledger asset-id ["price"]))
    )
    (defun UR_Retrieval:bool (asset-id:string)
        (at "retrieval" (read DEMIPAD|T|Ledger asset-id ["retrieval"]))
    )
    ;;
    (defun UR_CheckRegistration:bool (asset-id:string)
        (try
            false
            (with-read DEMIPAD|T|Ledger asset-id 
                { "price" := dummy }
                true
            )
        )
    )
    (defun URC_Prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices} 
        (asset-id:string amount-in-dollars:decimal type:integer)
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (sstoa-id:string (ref-DALOS::UR_SilverStoaID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                ;;
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
                (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa-id))
                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (total-dollarz-raised:decimal (UR_TotalDollarzRaised asset-id))
                (deposit-royalty:decimal (UCv_ComputeDepositRoyalty total-dollarz-raised amount-in-dollars))
                (five-percent-dollarz:decimal (floor (/ deposit-royalty 3.0) 5))
                (ten-percent-dollarz:decimal (- deposit-royalty five-percent-dollarz))
                (remainder-percent-dollarz:decimal (- amount-in-dollars deposit-royalty))

                ;;
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (wstoa-pid:decimal (ref-SWPI::URC_TokenDollarPrice wstoa-id stoa-pid))
                (sstoa-pid:decimal (ref-SWPI::URC_TokenDollarPrice sstoa-id stoa-pid))
                (ouro-pid:decimal (ref-SWPI::URC_OuroPrimordialPrice))
                ;;
                (five-percent-dollarz-as-stoa:decimal (floor (/ five-percent-dollarz wstoa-pid) wstoa-prec))
                (env-split:[decimal] (UC_LaunchpadEnviromentSplit five-percent-dollarz-as-stoa))
                ;;
                (type-pid:decimal 
                    (if (or (= type 0) (= type 1))
                        wstoa-pid
                        (if (= type 2)
                            sstoa-pid
                            ouro-pid
                        )
                    )
                )
                (type-prec:integer
                    (if (or (= type 0) (= type 1))
                        wstoa-prec
                        (if (= type 2)
                            sstoa-prec
                            ouro-prec
                        )
                    )
                )
            )
            (UDC_LaunchpadPrices
                ;;Enviroment Split with native STOA amounts
                (ref-DALOS::UR_AccountStoa (ref-DALOS::GOV|DALOS|SC_NAME))      ;;Gas-Station 10%
                (ref-DALOS::UR_AccountStoa (at 2 (ref-DALOS::UR_DemiurgoiID)))  ;;HOV 20%
                (ref-DALOS::UR_AccountStoa (at 1 (ref-DALOS::UR_DemiurgoiID)))  ;;CTO 30%
                (ref-DALOS::UR_AccountStoa (ref-DALOS::GOV|OUROBOROS|SC_NAME))  ;;Liquid Staking 40%
                (at 0 env-split)
                (at 1 env-split)
                (at 2 env-split)
                (at 3 env-split)
                ;;Total Enviroment Amount in native STOA
                five-percent-dollarz-as-stoa
                ;;CodingDivision and Remainder Split in WSTOA, SSTOA or OURO, depending on <type>
                (floor (/ ten-percent-dollarz type-pid) type-prec)
                (floor (/ remainder-percent-dollarz type-pid) type-prec)
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string asset-id:string buy-amount-in-dollarz:decimal type:integer slippage:decimal)
        @doc "Variant 1 (with slippage) — returns the coin.TRANSFER cap descriptions the UI must SIGN. \
            \ Each leg is padded by (1 + slippage/100) so the signed managed cap is a ceiling with \
            \ headroom: at execution the launchpad transfers the real (possibly-moved) price <= the \
            \ padded cap, succeeding within tolerance and failing safely beyond it. Pass slippage 0.0 \
            \ for exact caps. The buyer's on-chain cost ceiling is enforced separately by <max-cost> in \
            \ C_Deposit; the UI sets max-cost = displayed-cost x (1 + slippage/100), slippage <= 50 by UI \
            \ policy. The install-based, no-ceiling counterpart is CAP_Acquire (Variant 2, slippage off)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                ;;
                (buyer-stoa:string (ref-DALOS::UR_AccountStoa buyer))
                (lq-stoa:string (ref-LIQUID::GOV|LIQUID|SC_STOA-NAME))
                (prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices} (URC_Prices asset-id buy-amount-in-dollarz type))
                (kp:integer (ref-U|CT::CT_STOA_PRECISION))
                (f:decimal (UC_SlippageFactor slippage))
                ;;Slippage-padded per-leg ceilings (floored to STOA precision so the signed caps are valid)
                (a1:decimal (floor (* (at "amount-one" prices) f) kp))
                (a2:decimal (floor (* (at "amount-two" prices) f) kp))
                (a3:decimal (floor (* (at "amount-three" prices) f) kp))
                (a4:decimal (floor (* (at "amount-four" prices) f) kp))
                (non-env:decimal (floor (* (+ (at "coding-amount" prices) (at "remainder-amount" prices)) f) kp))
                (env-amt:decimal (floor (* (at "enviroment-amount" prices) f) kp))
                ;;
                (s1:string (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [buyer-stoa (at "receiver-one" prices) a1]))
                (s2:string (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [buyer-stoa (at "receiver-two" prices) a2]))
                (s3:string (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [buyer-stoa (at "receiver-three" prices) a3]))
                (s4:string (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [buyer-stoa (at "receiver-four" prices) a4]))
            )
            (if (= type 0)
                [
                    (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [buyer-stoa lq-stoa non-env])
                    s1 s2 s3 s4
                ]
                (if (= type 1)
                    [
                        (format "<(coin.TRANSFER \"{}\" \"{}\" {})>" [lq-stoa buyer-stoa env-amt])
                        s1 s2 s3 s4
                    ]
                    [s1 s2 s3 s4]
                )
            )
        )
    )
    (defun URCi_Deposit:object{IgnisCollectorV3.OutputCumulator}
        (donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool)
        @doc "Cost preview for C_Deposit: (type 0) wrap-STOA of the non-environment amount, \
            \ (type 1) unwrap-STOA of the environment amount, and (unless direct-injection) the \
            \ donor->launchpad transfer of the working token. The Satisfy/Deposit writes are \
            \ free. Re-derived purely from URC_Prices."
        ;;The op's own gate, not a copy of it -- see UEV_DepositDollarAmount above.
        (UEV_DepositDollarAmount amount-in-dollars)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                ;;
                (prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices} (URC_Prices asset-id amount-in-dollars type))
                (working-id:string
                    (if (or (= type 0) (= type 1))
                        (ref-DALOS::UR_WrappedStoaID)
                        (if (= type 2)
                            (ref-DALOS::UR_SilverStoaID)
                            (ref-DALOS::UR_OuroborosID)
                        )
                    )
                )
                (env:decimal (at "enviroment-amount" prices))
                (non-enviroment:decimal (+ (at "coding-amount" prices) (at "remainder-amount" prices)))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (if (= type 0)
                        (ref-LIQUID::URCi_WrapStoa donor non-enviroment)
                        EOC
                    )
                    (if (= type 1)
                        (ref-LIQUID::URCi_UnwrapStoa donor env)
                        EOC
                    )
                    (if (not direct-injection)
                        (ref-TFT::URCi_Transfer working-id donor DEMIPAD|SC_NAME non-enviroment)
                        EOC
                    )
                ]
                []
            )
        )
    )
    (defun URCi_TransmitSemiFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        @doc "Cost preview for C_TransmitSemiFungibles: the single collectable multi-transfer \
            \ (client->launchpad on fuel, launchpad->client on retrieve), son=true."
        (URCi_TransmitCollectables client asset-id true nonces amounts fuel-or-retrieve)
    )
    (defun URCi_TransmitNonFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        @doc "Cost preview for C_TransmitNonFungibles: as URCi_TransmitSemiFungibles with son=false."
        (URCi_TransmitCollectables client asset-id false nonces amounts fuel-or-retrieve)
    )
    (defun URCi_TransmitCollectables:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string son:bool nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        @doc "Shared cost preview for the collectable transmit legs (mirrors XI_TransmitCollectables): \
            \ one DPDC-T multi-transfer, sender/receiver flipped by fuel-or-retrieve."
        (let
            (
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (lpad:string DEMIPAD|SC_NAME)
            )
            (if fuel-or-retrieve
                (ref-DPDC-T::URCi_MultiTransferCumulator [asset-id] [son] client lpad [nonces] [amounts])
                (ref-DPDC-T::URCi_MultiTransferCumulator [asset-id] [son] lpad client [nonces] [amounts])
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string asset-id:string buy-amount-in-dollarz:decimal type:integer)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                ;;
                (buyer-stoa:string (ref-DALOS::UR_AccountStoa buyer))
                (lq-stoa:string (ref-LIQUID::GOV|LIQUID|SC_STOA-NAME))
                (prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices} (URC_Prices asset-id buy-amount-in-dollarz type))
                ;;

                (r1:string (at "receiver-one" prices))
                (r2:string (at "receiver-two" prices))
                (r3:string (at "receiver-three" prices))
                (r4:string (at "receiver-four" prices))
                (a1:decimal (at "amount-one" prices))
                (a2:decimal (at "amount-two" prices))
                (a3:decimal (at "amount-three" prices))
                (a4:decimal (at "amount-four" prices))
                (enviroment:decimal (at "enviroment-amount" prices))
                (coding:decimal (at "coding-amount" prices))
                (remainder:decimal (at "remainder-amount" prices))
            )
            (if (= type 0)
                (do
                    (install-capability (ref-coin::TRANSFER buyer-stoa lq-stoa (+ coding remainder)))
                    (install-capability (ref-coin::TRANSFER buyer-stoa r1 a1))
                    (install-capability (ref-coin::TRANSFER buyer-stoa r2 a2))
                    (install-capability (ref-coin::TRANSFER buyer-stoa r3 a3))
                    (install-capability (ref-coin::TRANSFER buyer-stoa r4 a4))

                )
                (if (= type 1)
                    (do
                        (install-capability (ref-coin::TRANSFER lq-stoa buyer-stoa enviroment))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r1 a1))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r2 a2))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r3 a3))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r4 a4))
                    )
                    (do
                        (install-capability (ref-coin::TRANSFER buyer-stoa r1 a1))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r2 a2))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r3 a3))
                        (install-capability (ref-coin::TRANSFER buyer-stoa r4 a4))
                    )
                )
            )
        )
    )
    (defun UEV_AssetFungibility (asset-id:string fungibility-to-check:[bool])
        (let
            (
                (type:string (UC_Type asset-id fungibility-to-check))
                (fungibility:[bool] (UR_Fungibility asset-id))
            )
            (enforce (= fungibility fungibility-to-check) (format "ID {} fungibility as {} is invalid" [asset-id type]))
        )
    )
    (defun UEV_Fungibility (fungibility:[bool])
        (let
            (
                (l:integer (length fungibility))
            )
            (enforce (= l 2) "Invalid Fungibility variable")
        )
    )
    (defun UEV_DirectInjection (direct-injection:bool)
        @doc "Direct-Injection is an unbuilt feature: once AQP vaults are live it will route the \
            \ <cod> royalty portion of a deposit into an injection profile (or collect-then-drip \
            \ once/day via an automaton). Until it is built it is HARD-BLOCKED here — this enforces \
            \ a deposit does not request it, UNCONDITIONALLY (no admin flag can enable the \
            \ unfinished path). This is what prevents the half-wired branch from crediting seller \
            \ funds with no tokens in custody (phantom funds). The <UR_DirectInjection> state is \
            \ kept reserved to gate the real path when it is implemented."
        (enforce (not direct-injection) "Direct Injection is not yet available")
    )
    (defun UEV_SlippageCost (amount-in-dollars:decimal max-cost:decimal)
        @doc "Slippage guard for a buy (Variant 1). The dollar cost computed live at execution \
            \ (<amount-in-dollars>) must not exceed the buyer's signed ceiling <max-cost>, which the UI \
            \ sets to displayed-cost x (1 + slippage/100). A sentinel <max-cost> below zero means NO \
            \ bound — the slippage-off path (Variant 2), where the buyer accepts the live price via \
            \ install-capability and is warned by the UI. Mirrors SWP's slippage protection, adapted to \
            \ bound a cost instead of a min output; the 50%% tolerance ceiling is a UI policy (the \
            \ on-chain code holds no poll-time baseline to recover the percent from)."
        (enforce
            (or (< max-cost 0.0) (<= amount-in-dollars max-cost))
            (format "Slippage: live cost {} exceeds the accepted maximum {}" [amount-in-dollars max-cost])
        )
    )
    (defun CAP_Owner (asset-id:string)
        @doc "Enforces <asset-id> ownership \
        \ Automaticaly enforces <asset-id> is registered, via <UR_Fungibility>"
        (let
            (
                (fungibility:[bool] (UR_Fungibility asset-id))
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (cond
                ((= fungibility TF) (ref-DPTF::CAP_Owner asset-id))
                ((= fungibility OF) (ref-DPOF::CAP_Owner asset-id))
                ((= fungibility SF) (ref-DPDC::CAP_OwnerOrCreator asset-id true))
                ((= fungibility NF) (ref-DPDC::CAP_OwnerOrCreator asset-id false))
                true
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_RegisterAsset (asset-id:string fungibility:[bool])
        (require-capability (SECURE))
        (insert DEMIPAD|T|Ledger asset-id 
            (UDC_DEMIPAD|Holdings 
                0.0 0.0 0.0 0.0
                0.0 0.0 0.0
                false false
                fungibility false {} false
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|TotalDollarzRaised (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"total-dollarz-raised" : value})
    )
    ;;Protection: Class 1 — Innate protection offered by XI_U|TotalWSTOARaised,
    ;;Protection:          XI_U|TotalSSTOARaised, XI_U|TotalOURORaised
    (defun XI_U|TotalRaised (asset-id:string value:decimal type:integer)
        (cond
            ((= type 1) (XI_U|TotalWSTOARaised asset-id value))
            ((= type 2) (XI_U|TotalSSTOARaised asset-id value))
            ((= type 3) (XI_U|TotalOURORaised asset-id value))
            true
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XI_U|FundsWSTOA, XI_U|FundsSSTOA,
    ;;Protection:          XI_U|FundsOURO
    (defun XI_U|Funds (asset-id:string value:decimal type:integer)
        (cond
            ((= type 1) (XI_U|FundsWSTOA asset-id value))
            ((= type 2) (XI_U|FundsSSTOA asset-id value))
            ((= type 3) (XI_U|FundsOURO asset-id value))
            true
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|TotalWSTOARaised (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"total-wstoa-raised" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|TotalSSTOARaised (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"total-sstoa-raised" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|TotalOURORaised (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"total-ouro-raised" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|FundsWSTOA (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"funds-wstoa" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|FundsSSTOA (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"funds-sstoa" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|FundsOURO (asset-id:string value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"funds-ouro" : value})
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_U|OpenForBusiness (asset-id:string toggle:bool)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"open-for-business" : toggle})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|Price (asset-id:string price:object)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"price" : price})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|Retrieval (asset-id:string retrieval:bool)
        (require-capability (SECURE))
        (update DEMIPAD|T|Ledger asset-id {"retrieval" : retrieval})
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_W|DirectInjection (value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Properties PP {"direct-injection" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|WSTOA (value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Properties PP {"resident-wstoa" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|SSTOA (value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Properties PP {"resident-sstoa" : value})
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_U|OURO (value:decimal)
        (require-capability (SECURE))
        (update DEMIPAD|T|Properties PP {"resident-ouro" : value})
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_SatisfyEnviroment (donor:string prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices})
        (require-capability (SECURE))
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (donor-stoa:string (ref-DALOS::UR_AccountStoa donor))
            )
            (ref-coin::transfer donor-stoa (at "receiver-one" prices)    (at "amount-one" prices))       ;;for GasStation
            (ref-coin::transfer donor-stoa (at "receiver-two" prices)    (at "amount-two" prices))       ;;for HOV
            (ref-coin::transfer donor-stoa (at "receiver-three" prices)  (at "amount-three" prices))     ;;for CTO
            (ref-coin::transfer donor-stoa (at "receiver-four" prices)   (at "amount-four" prices))      ;;for LQ-St
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_DepositResidents (prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices} type:integer)
        (require-capability (SECURE))
        (with-capability (SECURE)
            (let
                (
                    (v0:decimal (at "coding-amount" prices))
                    (v1:decimal (UR_WSTOA))
                    (v2:decimal (UR_SSTOA))
                    (v3:decimal (UR_OURO))
                )
                (if (or (= type 0) (= type 1))
                    (XI_U|WSTOA (+ v0 v1))
                    (if (= type 2)
                        (XI_U|SSTOA (+ v0 v2))
                        (XI_U|OURO (+ v0 v3))
                    )
                )
            )
        ) 
    )
    ;;Protection: Class 1 — Innate protection offered by XI_U|TotalDollarzRaised
    (defun XI_DepositForAsset 
        (asset-id:string amount-in-dollars:decimal remainder:decimal type:integer)
        (let
            (
                (used-type:integer (if (= type 0) 1 type))
            )
            (XI_U|TotalDollarzRaised asset-id (+ (UR_TotalDollarzRaised asset-id) amount-in-dollars))
            (XI_U|TotalRaised asset-id (+ remainder (URv_TotalRaised asset-id used-type)) used-type)
            (XI_U|Funds asset-id (+ remainder (URv_Funds asset-id used-type)) used-type)
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_TransmitCollectables:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string son:bool nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        (require-capability (SECURE))
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (lpad:string DEMIPAD|SC_NAME)
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            ;;#7M: open the capability matching the collectable KIND (son true = Semi-Fungible [false true],
            ;;     false = Non-Fungible [false false]). Previously both branches hardcoded the SEMI cap, so a
            ;;     real NF asset always failed UEV_AssetFungibility (dead) and an SF routed via the NF entry
            ;;     transferred with son=false (type mismatch). The NON caps existed but were wired to nothing.
            (if fuel-or-retrieve
                ;;FUEL — deposit collectables INTO the launchpad
                (if son
                    (with-capability (DEMIPAD|C>FUEL-SEMI-FUNGIBLE asset-id)
                        (ref-DPDC-T::C_Transfer [asset-id] [son] client lpad [nonces] [amounts] true)
                    )
                    (with-capability (DEMIPAD|C>FUEL-NON-FUNGIBLE asset-id)
                        (ref-DPDC-T::C_Transfer [asset-id] [son] client lpad [nonces] [amounts] true)
                    )
                )
                ;;RETRIEVE — withdraw collectables FROM the launchpad (NF path now also inherits the #2H lock)
                (if son
                    (with-capability (DEMIPAD|C>RETRIEVE-SEMI-FUNGIBLE asset-id)
                        (ref-DPDC-T::C_Transfer [asset-id] [son] lpad client [nonces] [amounts] true)
                    )
                    (with-capability (DEMIPAD|C>RETRIEVE-NON-FUNGIBLE asset-id)
                        (ref-DPDC-T::C_Transfer [asset-id] [son] lpad client [nonces] [amounts] true)
                    )
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_RegisterAssetToLaunchpad (patron:string asset-id:string fungibility:[bool])
        (P|UEV_IMC)
        (with-capability (DEMIPAD|C>REGISTER asset-id fungibility)
            (XI_RegisterAsset asset-id fungibility)
            (format "{} {} registered succesfuly to Demiourgos Launchpad!" [(UC_Type asset-id fungibility) asset-id])
        )
    )
    ;;
    (defun A_ToggleOpenForBusiness (asset-id:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (DEMIPAD|C>TOGGLE-SALE asset-id toggle)
            (XI_U|OpenForBusiness asset-id toggle)
            (format "Asset {} sale succesfully toggled to {}" [asset-id toggle])
        )
    )
    (defun A_DefinePrice (asset-id:string price:object)
        (P|UEV_IMC)
        (with-capability (DEMIPAD|C>DEFINE-PRICE asset-id price)
            (XI_U|Price asset-id price)
            (format "Asset {} price succesfully updated with the Price Object {}" [asset-id price])
        )
    )
    (defun A_ToggleRetrieval (asset-id:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (DEMIPAD|C>TOGGLE-RETRIEVAL asset-id toggle)
            (XI_U|Retrieval asset-id toggle)
            (format "Asset {} Retrieval succesfuly set to {}" [asset-id toggle])
        )
    )
    (defun C_Deposit:object{IgnisCollectorV3.OutputCumulator}
        (donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
        @doc "Deposits Funds into the Launchpad, for a registered Asset \
            \ Type 0 = Native Stoa \
            \ Type 1 = WSTOA \
            \ Type 2 = SSTOA \
            \ Type 3 = OURO \
            \ \
            \ <max-cost> is the buyer's slippage ceiling in dollars (Variant 1): the live-computed \
            \ <amount-in-dollars> must be <= <max-cost>. Pass a sentinel below zero for the slippage-off \
            \ path (Variant 2). \
            \ \
            \ Outputs: \
            \ <type 0> = STOA Split ENV + WSTOA for CD (needs wrapping) + WSTOA for Sale (needs wrapping) \
            \ <type 1> = STOA Split ENV (needs unwrapping) + WSTOA for CD + WSTOA for Sale \
            \ <type 2> = STOA Split ENV + SSTOA for CD + SSTOA for Sale \
            \ <type 3> = STOA Split ENV + OURO for CD + OURO for Sale "
        (P|UEV_IMC)
        (with-capability (DEMIPAD|C>DEPOSIT donor asset-id amount-in-dollars type direct-injection max-cost)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                    ;;
                    (prices:object{DemiourgosLaunchpadV2.DEMIPAD|Prices}  (URC_Prices asset-id amount-in-dollars type))
                    (working-id:string
                        (if (or (= type 0) (= type 1))
                            (ref-DALOS::UR_WrappedStoaID)
                            (if (= type 2)
                                (ref-DALOS::UR_SilverStoaID)
                                (ref-DALOS::UR_OuroborosID)
                            )
                        )
                    )
                    ;;
                    (env:decimal (at "enviroment-amount" prices))
                    (cod:decimal (at "coding-amount" prices))
                    (rem:decimal (at "remainder-amount" prices))
                    (non-enviroment:decimal (+ cod rem))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (if (= type 0)
                            (ref-LIQUID::C_WrapStoa donor non-enviroment)
                            EOC
                        )
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (if (= type 1)
                            (ref-LIQUID::C_UnwrapStoa donor env)
                            EOC
                        )
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (if (not direct-injection)
                            (ref-TFT::C_Transfer working-id donor DEMIPAD|SC_NAME non-enviroment true)
                            EOC
                            ;;When AQP LIVE, to be replaced by:
                            ;;(ref-AQP::C_Inject <pool-id> <working-id> <cod> <injection-type>)
                            ;;(ref-TFT::C_Transfer working-id donor DEMIPAD|SC_NAME rem true)
                        )
                    )
                )
                ;;1]Satisfy Enviroment (Stoa was Unwraped prior if <type> = 1)
                (XI_SatisfyEnviroment donor prices)
                ;;2]Update Internal Launchpad with deposit Data
                    ;;2.1]When (not direct-injection) save <cod> amount in Launchpad Properties
                (if (not direct-injection)
                    ;;Update Resident Amounts in DEMIPAD|Properties (they may be later injected to Acquisition Pool)
                    (XI_DepositResidents prices type)
                    true
                )
                    ;;2.2]Save <rem> in <DEMIPAD|T|Ledger> (so that it may be withdrawed by Asset Seller)
                    ;;    Guarded on (not direct-injection): crediting the seller ledger is only
                    ;;    valid once <rem> tokens actually enter custody (ico3 above). The cap
                    ;;    hard-blocks direct-injection today, so this branch is unreachable; the
                    ;;    guard stays as defense-in-depth so the future direct-injection build
                    ;;    must wire the <rem> transfer before this credit can ever fire (no
                    ;;    phantom funds).
                (if (not direct-injection)
                    (XI_DepositForAsset asset-id amount-in-dollars rem type)
                    true
                )
                ;;3]Output Cumulator
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
            )
        )
    )
    (defun C_Withdraw
        (patron:string asset-id:string type:integer destination:string)
        @doc "Withdraws all cumulated Tokens in the Launchpad, gathered through sale \
        \ Type 1 = WSTOA \
        \ Type 2 = SSTOA \
        \ Type 3 = OURO "
        (P|UEV_IMC)
        (let
            (
                (retrieval-amount:decimal (URv_Funds asset-id type))
            )
            (with-capability (DEMIPAD|C>WITHDRAW asset-id type retrieval-amount destination)
                (let
                    (
                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                        (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                        (working-id:string
                            (if (= type 1)
                                (ref-DALOS::UR_WrappedStoaID)
                                (if (= type 2)
                                    (ref-DALOS::UR_SilverStoaID)
                                    (ref-DALOS::UR_OuroborosID)
                                )
                            )
                        )
                    )
                    ;;1]Withdraw Tokens to Destination
                    (ref-TS01-C1::DPTF|C_Transfer patron working-id DEMIPAD|SC_NAME destination retrieval-amount true)
                    ;;2]Reset Holdings to 0.0 after withdrawal
                    (XI_U|Funds asset-id 0.0 type)
                )
            )
        )
    )
    ;;Fuel|Retrieve Assets to|from Launchpad to be made after Upgrade.
    (defun C_TransmitTrueFungible (patron:string client:string asset-id:string amount:decimal fuel-or-retrieve:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                (lpad:string DEMIPAD|SC_NAME)
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (if fuel-or-retrieve
                (with-capability (DEMIPAD|C>FUEL-TRUE-FUNGIBLE asset-id)
                    (ref-TS01-C1::DPTF|C_Transfer patron asset-id client lpad amount true)
                    (format "Succesfuly fueled {} {} to Demiourgos Launchpad from Account {}" [amount asset-id sa-s])
                )
                (with-capability (DEMIPAD|C>RETRIEVE-TRUE-FUNGIBLE asset-id)
                    (ref-TS01-C1::DPTF|C_Transfer patron asset-id lpad client amount true)
                    (format "Succesfuly retrieved {} {} from Demiourgos Launchpad to Account {}" [amount asset-id sa-s])
                )
            )
        )
    )
    (defun C_TransmitOrtoFungible (patron:string client:string asset-id:string nonces:[integer] fuel-or-retrieve:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                (lpad:string DEMIPAD|SC_NAME)
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (if fuel-or-retrieve
                (with-capability (DEMIPAD|C>FUEL-ORTO-FUNGIBLE asset-id)
                    (ref-TS01-C1::DPOF|C_Transfer patron asset-id nonces client lpad true)
                    (format "Succesfuly fueled {} Nonces {} to Demiourgos Launchpad from Account {}" [asset-id nonces sa-s])
                )
                (with-capability (DEMIPAD|C>RETRIEVE-ORTO-FUNGIBLE asset-id)
                    (ref-TS01-C1::DPOF|C_Transfer patron asset-id nonces lpad client true)
                    (format "Succesfuly retrieved {} Nonces {} from Demiourgos Launchpad to Account {}" [asset-id nonces sa-s])
                )
            )
        )
    )
    (defun C_TransmitSemiFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_TransmitCollectables client asset-id true nonces amounts fuel-or-retrieve)
        )
    )
    (defun C_TransmitNonFungibles:object{IgnisCollectorV3.OutputCumulator}
        (client:string asset-id:string nonces:[integer] amounts:[integer] fuel-or-retrieve:bool)
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_TransmitCollectables client asset-id false nonces amounts fuel-or-retrieve)
        )
    )

)

;; --- tables for 00_Demipad.pact (4 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table DEMIPAD|T|Ledger)
;; (create-table DEMIPAD|T|Properties)


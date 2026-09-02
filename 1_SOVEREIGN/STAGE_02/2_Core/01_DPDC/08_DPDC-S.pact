;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
(interface DpdcSetsV1
    @doc "Exposes Collectables Set related Functions"
    ;;
    ;;  [UR]
    ;;
    (defun UR_Set:object{DpdcUdcV1.DPDC|Set} (id:string son:bool set-class:integer))
    (defun UR_SetClass:integer (id:string son:bool set-class:integer))
    (defun UR_SetName:string (id:string son:bool set-class:integer))
    (defun UR_SetMultiplier:decimal (id:string son:bool set-class:integer))
    (defun UR_NonceOfSet:integer (id:string set-class:integer))
    (defun UR_IzSetActive:bool (id:string son:bool set-class:integer))
    (defun UR_IzSetPrimordial:bool (id:string son:bool set-class:integer))
    (defun UR_IzSetComposite:bool (id:string son:bool set-class:integer))
    (defun UR_PSD:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}] (id:string son:bool set-class:integer))
    (defun UR_CSD:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] (id:string son:bool set-class:integer))
    (defun UR_SetNonceData:object{DpdcUdcV1.DPDC|NonceData} (id:string son:bool set-class:integer))
    (defun UR_SetSplitData:object{DpdcUdcV1.DPDC|NonceData} (id:string son:bool set-class:integer))
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
    (defun URC_NonFungibleConstituents:[integer] (id:string nonce:integer))
    ;;
    ;;  [UEV]
    ;;
    
        ;;
    (defun UEV_PrimordialSetDefinition (id:string son:bool set-definition:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]))
    (defun UEV_PrimordialSetElement (son:bool element:object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}))
    (defun UEV_CompositeSetDefinition (id:string son:bool set-definition:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]))
    (defun UEV_SetClass (id:string son:bool set-class:integer))
    (defun UEV_IzSetClassFragmented:bool (id:string son:bool set-class:integer))
    (defun UEV_Fragmentation (id:string son:bool set-class:integer))
    (defun UEV_SetActiveState (id:string son:bool set-class:integer state:bool))
        ;;
    (defun UEV_NoncesForSetClass (id:string son:bool nonces:[integer] set-class:integer))
    (defun UEV_Primordial (nonces:[integer] psd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]))
    (defun UEV_Composite (id:string son:bool nonces:[integer] csd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]))
    ;;
    ;;  [C]
    ;;
    (defun C_MakeSemiFungibleSet:object{IgnisCollectorV1.OutputCumulator} (account:string id:string nonces:[integer] set-class:integer how-many-sets:integer))
    (defun C_BreakSemiFungibleSet:object{IgnisCollectorV1.OutputCumulator} (account:string id:string nonce:integer how-many-sets:integer))
    (defun C_MakeNonFungibleSet:object{IgnisCollectorV1.OutputCumulator} (account:string id:string nonces:[integer] set-class:integer))
    (defun C_BreakNonFungibleSet:object{IgnisCollectorV1.OutputCumulator} (account:string id:string nonce:integer))
        ;;
    (defun C_DefinePrimordialSet:object{IgnisCollectorV1.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
    )
    (defun C_DefineCompositeSet:object{IgnisCollectorV1.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
    )
    (defun C_DefineHybridSet:object{IgnisCollectorV1.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
    )
    (defun C_EnableSetClassFragmentation:object{IgnisCollectorV1.OutputCumulator}
        (
            id:string son:bool set-class:integer
            fragmentation-ind:object{DpdcUdcV1.DPDC|NonceData}
        )
    )
    (defun C_ToggleSet:object{IgnisCollectorV1.OutputCumulator} (id:string son:bool set-class:integer toggle:bool))
    (defun C_RenameSet:object{IgnisCollectorV1.OutputCumulator} (id:string son:bool set-class:integer new-name:string))
        ;;  [URCi] cost readers — single source per op
    (defun URCi_MakeSemiFungibleSet:object{IgnisCollectorV1.OutputCumulator} (account:string id:string nonces:[integer] how-many-sets:integer))
    (defun URCi_BreakSemiFungibleSet:object{IgnisCollectorV1.OutputCumulator} (account:string id:string nonce:integer how-many-sets:integer))
    (defun URCi_MakeNonFungibleSet:object{IgnisCollectorV1.OutputCumulator} (account:string id:string nonces:[integer]))
    (defun URCi_BreakNonFungibleSet:object{IgnisCollectorV1.OutputCumulator} (account:string id:string nonce:integer))
    (defun URCi_DefinePrimordialSet:object{IgnisCollectorV1.OutputCumulator} (id:string son:bool))
    (defun URCi_DefineCompositeSet:object{IgnisCollectorV1.OutputCumulator} (id:string son:bool))
    (defun URCi_DefineHybridSet:object{IgnisCollectorV1.OutputCumulator} (id:string son:bool))
    (defun URCi_EnableSetClassFragmentation:object{IgnisCollectorV1.OutputCumulator} (id:string son:bool))
    (defun URCi_ToggleSet:object{IgnisCollectorV1.OutputCumulator} (id:string son:bool))
    (defun URCi_RenameSet:object{IgnisCollectorV1.OutputCumulator} (id:string son:bool))
    ;; C_UpdateSetMultiplier removed — DPDC Audit #15H: score-multiplier is now immutable after Define,
    ;; matching the Set-Class recipe's own immutability. A wrong multiplier means disabling that
    ;; Set-Class and defining a new one, same recovery path as a wrong recipe.
    ;;
    (defun XB_U|NonceOrSplitData (id:string son:bool set-class:integer nos:bool nd:object{DpdcUdcV1.DPDC|NonceData}))
)
;;
(module DPDC-S GOV
    ;;
    (implements OuronetPolicyV1)
    (implements DpdcSetsV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_DPDC-S                 (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|DPDC-S_ADMIN)))
    (defcap GOV|DPDC-S_ADMIN ()             (enforce-guard GOV|MD_DPDC-S))
    ;;{G3}
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
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
    ;;{P4}
    (defconst P|I                   (P|Info))
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
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
                    (ref-U|LST:module{StringProcessorV1} U|LST)
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
                (ref-P|DPDC:module{OuronetPolicyV1} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV1} DPDC-C)
                (ref-P|DPDC-T:module{OuronetPolicyV1} DPDC-T)
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
    (defun UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    ;;{2}
    (deftable DPSF|SetsTable:{DpdcUdcV1.DPDC|Set})                ;;Key = <DPSF-id> + BAR + <set-class>
    ;;
    (deftable DPNF|SetsTable:{DpdcUdcV1.DPDC|Set})                ;;Key = <DPNF-id> + BAR + <set-class>
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defun CT_EmptyCumulator ()     (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::DALOS|EmptyOutputCumulatorV2)))
    (defconst BAR                   (CT_Bar))
    (defconst EOC                   (CT_EmptyCumulator))
    ;;DPDC Audit #51L: a Primordial/Composite set-definition must have at least 1 position (an empty
    ;;list previously crashed with an opaque out-of-bounds error, since (enumerate 0 -1) returns [0 -1],
    ;;not [] -- see UEV_PrimordialSetDefinition/UEV_CompositeSetDefinition) and at most this many, so an
    ;;unreasonably large definition can't push Make/Break gas past the practical ceiling and permanently
    ;;brick that set-class for its owner.
    (defconst MAX_SET_DEFINITION_SIZE 20)
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    ;;{C3}
    ;;{C4}
    (defcap DPDC-S|C>MAKE (id:string son:bool nonces:[integer] set-class:integer how-many-sets:integer)
        @event
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
                (ref-DPDC:module{DpdcV1} DPDC)
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
            set-definition:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        @event
        (UEV_PrimordialSetDefinition id son set-definition)
        (UEV_ScoreMultiplier score-multiplier)     ;; DPDC Audit #15H
        (compose-capability (DPDC-S|CX>DEFINE id son ind))
    )
    (defcap DPDC-S|C>DEFINE-COMPOSITE
        (
            id:string son:bool score-multiplier:decimal
            set-definition:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        @event
        (UEV_CompositeSetDefinition id son set-definition)
        (UEV_ScoreMultiplier score-multiplier)     ;; DPDC Audit #15H
        (compose-capability (DPDC-S|CX>DEFINE id son ind))
    )
    (defcap DPDC-S|C>DEFINE-HYBRID
        (
            id:string son:bool score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        @event
        (UEV_PrimordialSetDefinition id son primordial-sd)
        (UEV_CompositeSetDefinition id son composite-sd)
        (UEV_ScoreMultiplier score-multiplier)     ;; DPDC Audit #15H
        (compose-capability (DPDC-S|CX>DEFINE id son ind))
    )
    (defcap DPDC-S|CX>DEFINE (id:string son:bool ind:object{DpdcUdcV1.DPDC|NonceData})
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
            )
            (ref-DPDC::CAP_Owner id son)
            (ref-DPDC-C::UEV_NonceDataForCreation ind)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap DPDC-S|C>ENABLE-FRAGMENTATION
        (
            id:string son:bool set-class:integer
            fragmentation-ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        @event
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
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
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (UEV_SetActiveState id son set-class (not toggle))
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (SECURE))
        )
    )
    (defcap DPDC-S|C>RENAME (id:string son:bool set-class:integer new-name:string)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (current-name:string (UR_SetName id son set-class))
            )
            (enforce (!= new-name current-name) (format "The Set Name of <{}> must be different from the current name of <{}> for operation" [new-name current-name]))
            (UEV_SetActiveState id son set-class true)
            (ref-DPDC::CAP_Owner id son)
            (compose-capability (SECURE))
        )
    )
    ;; DPDC-S|C>MULTIPLIER removed — DPDC Audit #15H: score-multiplier is immutable after Define.
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F1}  Construct [UDC]
    ;;{F2}  Compute [UC]
    (defun UC_FirstNoncesFromPSD:[integer] (psd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}])
        @doc "Returns a list of Nonces that composed the PSD, only works for SFTs, \
            \ since the 1st Nonce of the <allowed-nonces> is used"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (let
                        (
                            (element:object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition} (at idx psd))
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
    ;;{F3}  Read [UR/URC/URH/URCi/INFO]
    ;;  [6] - [Set]
    (defun UR_Set:object{DpdcUdcV1.DPDC|Set} (id:string son:bool set-class:integer)
        (if son
            (read DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]))
            (read DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]))
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
    (defun UR_PSD:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]
        (id:string son:bool set-class:integer)
        (at "primordial-set-definition" (UR_Set id son set-class))
    )
    (defun UR_CSD:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] 
        (id:string son:bool set-class:integer)
        (at "composite-set-definition" (UR_Set id son set-class))
    )
    (defun UR_SetNonceData:object{DpdcUdcV1.DPDC|NonceData} (id:string son:bool set-class:integer)
        (at "nonce-data" (UR_Set id son set-class))
    )
    (defun UR_SetSplitData:object{DpdcUdcV1.DPDC|NonceData} (id:string son:bool set-class:integer)
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
                (ref-DPDC:module{DpdcV1} DPDC)
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
                (ref-DPDC:module{DpdcV1} DPDC)
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
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (psd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}] (UR_PSD id true set-class))
                (csd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] (UR_CSD id true set-class))
                (npsd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}] (ref-DPDC-UDC::UDC_NoPrimordialSet))
                (ncsd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] (ref-DPDC-UDC::UDC_NoCompositeSet))
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
    (defun URH_NonceListFromCSD:[integer] (id:string csd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}])
        @doc "Returns a list of Nonces that composed the CSD, only works for SFTs \
            \ since SFTs save the Nonce of the Set Class"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (let
                        (
                            (element:object{DpdcUdcV1.DPDC|AllowedClassForSetPosition} (at idx csd))
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
    (defun URC_NonFungibleConstituents:[integer] (id:string nonce:integer)
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (nonce-class:integer (ref-DPDC::UR_NonceClass id false nonce))
            )
            (enforce (!= nonce-class 0) "Invalid NFT Nonce to Read Constituents")
            (ref-DPDC::UR_N|Composition (ref-DPDC::UR_NativeNonceData id false nonce))
        )
    )
    ;;
    ;;
    (defun URCi_MakeSemiFungibleSet:object{IgnisCollectorV1.OutputCumulator}
        (account:string id:string nonces:[integer] how-many-sets:integer)
        @doc "Cost preview for C_MakeSemiFungibleSet: only the account->DPDC set-element transfer \
            \ is billed (the XB_CreditSFT-Nonce write's cumulator is discarded). Purely derived."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
            )
            (ref-DPDC-T::URCi_MultiTransferCumulator
                [id] [true] account dpdc [nonces] [(make-list (length nonces) how-many-sets)])
        )
    )
    (defun URCi_BreakSemiFungibleSet:object{IgnisCollectorV1.OutputCumulator}
        (account:string id:string nonce:integer how-many-sets:integer)
        @doc "Cost preview for C_BreakSemiFungibleSet: account->DPDC set transfer + DPDC->account \
            \ constituents release (the XE_DebitSFT-Nonce burn is discarded). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
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
    (defun URCi_MakeNonFungibleSet:object{IgnisCollectorV1.OutputCumulator}
        (account:string id:string nonces:[integer])
        @doc "Cost preview for C_MakeNonFungibleSet: account->DPDC transfer + creation of the new \
            \ set nonce + DPDC->account transfer of that new nonce. Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
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
    (defun URCi_BreakNonFungibleSet:object{IgnisCollectorV1.OutputCumulator}
        (account:string id:string nonce:integer)
        @doc "Cost preview for C_BreakNonFungibleSet: account->DPDC transfer + DPDC->account \
            \ constituents release (the XE_DebitNFT-Nonce burn is discarded). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (constituents:[integer] (URC_NonFungibleConstituents id nonce))
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
    (defun URCi_DefinePrimordialSet:object{IgnisCollectorV1.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_DefinePrimordialSet (same shape for Composite/Hybrid): the base \
            \ token-issue IGNIS price on the creator + (for SFT sets) the zero-supply set-nonce \
            \ creation; NFT sets add no nonce cost (EOC). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
                (creator:string (ref-DPDC::UR_CreatorKonto id son))
                (price:decimal (ref-DALOS::UR_UsagePrice "ignis|token-issue"))
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
    (defun URCi_DefineCompositeSet:object{IgnisCollectorV1.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_DefineCompositeSet: identical cost shape to \
            \ URCi_DefinePrimordialSet."
        (URCi_DefinePrimordialSet id son)
    )
    (defun URCi_DefineHybridSet:object{IgnisCollectorV1.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_DefineHybridSet: identical cost shape to \
            \ URCi_DefinePrimordialSet (the NFT XE_DeployAccountWNE leg is a free write)."
        (URCi_DefinePrimordialSet id son)
    )
    (defun URCi_EnableSetClassFragmentation:object{IgnisCollectorV1.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_EnableSetClassFragmentation: the biggest IGNIS cumulator on the \
            \ set creator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (ref-IGNIS::UDC_BiggestCumulator (ref-DPDC::UR_CreatorKonto id son))
        )
    )
    (defun URCi_ToggleSet:object{IgnisCollectorV1.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_ToggleSet: the biggest IGNIS cumulator on the set creator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (ref-IGNIS::UDC_BiggestCumulator (ref-DPDC::UR_CreatorKonto id son))
        )
    )
    (defun URCi_RenameSet:object{IgnisCollectorV1.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_RenameSet: the small IGNIS cumulator on the set creator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (ref-IGNIS::UDC_SmallCumulator (ref-DPDC::UR_CreatorKonto id son))
        )
    )
    ;;{F4}  Validate [UEV/CAP]
    (defun UEV_PrimordialSetDefinition (id:string son:bool set-definition:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}])
        ;;DPDC Audit #51L: reject empty/oversized definitions with a clear message before any
        ;;enumerate-based fold runs (an empty list would otherwise crash with an opaque
        ;;out-of-bounds error several lines below).
        (enforce
            (and (> (length set-definition) 0) (<= (length set-definition) MAX_SET_DEFINITION_SIZE))
            (format "Set-Definition length must be between 1 and {} positions" [MAX_SET_DEFINITION_SIZE])
        )
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
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
    (defun UEV_PrimordialSetElement (son:bool element:object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition})
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
    (defun UEV_CompositeSetDefinition (id:string son:bool set-definition:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}])
        ;;DPDC Audit #51L: same empty/oversized-definition guard as UEV_PrimordialSetDefinition above.
        (enforce
            (and (> (length set-definition) 0) (<= (length set-definition) MAX_SET_DEFINITION_SIZE))
            (format "Set-Definition length must be between 1 and {} positions" [MAX_SET_DEFINITION_SIZE])
        )
        (let
            (
                (ref-U|INT:module{OuronetIntegersV1} U|INT)
                (ref-DPDC:module{DpdcV1} DPDC)
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
        (let
            (
                (sc:integer (UR_SetClass id son set-class))
            )
            (enforce (> set-class 0) "Invalid Set-Class Value")
            (enforce (= set-class sc) "Invalid DPDC Set Data")
        )
    )
    (defun UEV_IzSetClassFragmented:bool (id:string son:bool set-class:integer)
        (enforce (> set-class 0) "Only greater than 0 set-classes can be checked for fragmentation")
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (sd:object{DpdcUdcV1.DPDC|NonceData} (UR_SetSplitData id son set-class))
                (zd:object{DpdcUdcV1.DPDC|NonceData} (ref-DPDC-UDC::UDC_ZeroNonceData))
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
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (psd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}] (UR_PSD id son set-class))
                (csd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] (UR_CSD id son set-class))
                (npsd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}] (ref-DPDC-UDC::UDC_NoPrimordialSet))
                (ncsd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}] (ref-DPDC-UDC::UDC_NoCompositeSet))
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
    (defun UEV_Primordial (nonces:[integer] psd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}])
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
                            (set-element:object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition} (at idx psd))
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
    (defun UEV_Composite (id:string son:bool nonces:[integer] csd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}])
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (l1:integer (length nonces))
                (l2:integer (length csd))
            )
            (enforce (= l1 l2) "Incompatible Input for <UEV_Composite> Validation")
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (set-element:object{DpdcUdcV1.DPDC|AllowedClassForSetPosition} (at idx csd))
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
    ;;{F5}  Write [W]
    ;;{F6}  Aux/Protected [X]
    ;; C_UpdateSetMultiplier removed — DPDC Audit #15H.
    (defun XI_PrimordialSet:integer
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        (require-capability (DPDC-S|C>DEFINE-PRIMORDIAL id son score-multiplier set-definition ind))
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-DPDC:module{DpdcV1} DPDC)
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
    (defun XI_CompositeSet:integer
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        (require-capability (DPDC-S|C>DEFINE-COMPOSITE id son score-multiplier set-definition ind))
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-DPDC:module{DpdcV1} DPDC)
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
    (defun XI_HybridSet:integer
        (
            id:string son:bool set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        (require-capability (DPDC-S|C>DEFINE-HYBRID id son score-multiplier primordial-sd composite-sd ind))
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-DPDC:module{DpdcV1} DPDC)
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
    (defun XI_FragmentSetClass
        (id:string son:bool set-class:integer fragmentation-ind:object{DpdcUdcV1.DPDC|NonceData})
        (require-capability (DPDC-S|C>ENABLE-FRAGMENTATION id son set-class fragmentation-ind))
        (XB_U|NonceOrSplitData id son set-class false fragmentation-ind)
    )
    (defun XI_ToggleSetClass (id:string son:bool set-class:integer toggle:bool)
        (require-capability (DPDC-S|C>TOGGLE id son set-class toggle))
        (XI_U|IzActive id son set-class toggle)
    )
    (defun XI_RenameSet (id:string son:bool set-class:integer new-name:string)
        (require-capability (DPDC-S|C>RENAME id son set-class new-name))
        (XI_U|SetName id son set-class new-name)
    )
    ;; XI_Multiplier removed — DPDC Audit #15H.
    ;;
    ;; [<SetsTable> Writings] [3]
    (defun XI_I|CollectionSet (id:string son:bool set-class:integer set:object{DpdcUdcV1.DPDC|Set})
        (require-capability (SECURE))
        (if son
            (insert DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) set)
            (insert DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) set)
        )
    )
    (defun XB_U|NonceOrSplitData (id:string son:bool set-class:integer nos:bool nd:object{DpdcUdcV1.DPDC|NonceData})
        ;;(require-capability (SECURE))
        (UEV_IMC)
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
    (defun XI_U|IzActive (id:string son:bool set-class:integer toggle:bool)
        (require-capability (SECURE))
        (if son
            (update DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"iz-active" : toggle})
            (update DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"iz-active" : toggle})
        )
    )
    (defun XI_U|SetName (id:string son:bool set-class:integer new-name:string)
        (require-capability (SECURE))
        (if son
            (update DPSF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"set-name" : new-name})
            (update DPNF|SetsTable (concat [id BAR (format "{}" [set-class])]) {"set-name" : new-name})
        )
    )
    ;;{F7}  User [A]
    ;;{F8}  User [C]
    (defun C_MakeSemiFungibleSet:object{IgnisCollectorV1.OutputCumulator}
        (account:string id:string nonces:[integer] set-class:integer how-many-sets:integer)
        (UEV_IMC)
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
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
    (defun C_BreakSemiFungibleSet:object{IgnisCollectorV1.OutputCumulator}
        (account:string id:string nonce:integer how-many-sets:integer)
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool true)
            )
            (with-capability (DPDC-S|C>BREAK id son nonce how-many-sets)
                (let
                    (
                        (ico1:object{IgnisCollectorV1.OutputCumulator}
                            ;;1]Transfer the SFT Sets from <account> to <dpdc>
                            (ref-DPDC-T::C_Transfer [id] [son] account dpdc [[nonce]] [[how-many-sets]] true)
                        )
                        (constituents:[integer]
                            (URC_SemiFungibleConstituents id (ref-DPDC::UR_NonceClass id son nonce))
                        )
                        (ico2:object{IgnisCollectorV1.OutputCumulator}
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
    (defun C_MakeNonFungibleSet:object{IgnisCollectorV1.OutputCumulator}
        (account:string id:string nonces:[integer] set-class:integer)
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool false)
            )
            (with-capability (DPDC-S|C>MAKE id son nonces set-class 1)
                (let
                    (
                        (ico1:object{IgnisCollectorV1.OutputCumulator}
                            ;;1]Transfer <nonces> to <dpdc>
                            (ref-DPDC-T::C_Transfer [id] [son] account dpdc [nonces] [(make-list (length nonces) 1)] true)
                        )
                        ;;
                        (set-nd:object{DpdcUdcV1.DPDC|NonceData} (UR_SetNonceData id son set-class))
                        (summed-score:decimal (URC_NoncesSummedScore id son nonces))
                        (spawned-nonce-md:object{DpdcUdcV1.NonceMetaData}
                            (ref-DPDC-UDC::UDC_NonceMetaData
                                summed-score
                                nonces
                                {}
                                )
                        )
                        (spawned-nd:object{DpdcUdcV1.DPDC|NonceData}
                            (+
                                {"meta-data" : spawned-nonce-md}
                                (remove "meta-data" set-nd)
                            )
                        )
                        (ico2:object{IgnisCollectorV1.OutputCumulator}
                            ;;2]When one nonce of class non-0 is created, is automatically created on <dpdc> account
                            (ref-DPDC-C::C_CreateNewNonce id son set-class 1 spawned-nd true)
                        )
                        (ico3:object{IgnisCollectorV1.OutputCumulator}
                            ;;3]Transfer new set nonce to <account>
                            (ref-DPDC-T::C_Transfer [id] [son] dpdc account [[(ref-DPDC::UR_NoncesUsed id son)]] [[1]] true)
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
                )
            )
        )
    )
    (defun C_BreakNonFungibleSet:object{IgnisCollectorV1.OutputCumulator}
        (account:string id:string nonce:integer)
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
                (ref-DPDC-T:module{DpdcTransferV1} DPDC-T)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (son:bool false)
            )
            (with-capability (DPDC-S|C>BREAK id son nonce 1)
                (let
                    (
                        (ico1:object{IgnisCollectorV1.OutputCumulator}
                            ;;1]Transfer the SFT|NFT from <account> to <dpdc>
                            (ref-DPDC-T::C_Transfer [id] [son] account dpdc [[nonce]] [[1]] true)
                        )
                        (constituents:[integer]
                            (URC_NonFungibleConstituents id nonce)
                        )
                        (ico2:object{IgnisCollectorV1.OutputCumulator}
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
    (defun C_DefinePrimordialSet:object{IgnisCollectorV1.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        (UEV_IMC)
        (with-capability (DPDC-S|C>DEFINE-PRIMORDIAL id son score-multiplier set-definition ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-DPDC:module{DpdcV1} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
                    ;;
                    (creator:string (ref-DPDC::UR_CreatorKonto id son))
                    (price:decimal (ref-DALOS::UR_UsagePrice "ignis|token-issue"))
                    (set-class:integer (XI_PrimordialSet id son set-name score-multiplier set-definition ind))
                    (ico0:object{IgnisCollectorV1.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    )
                    (ico1:object{IgnisCollectorV1.OutputCumulator}
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
    (defun C_DefineCompositeSet:object{IgnisCollectorV1.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        (UEV_IMC)
        (with-capability (DPDC-S|C>DEFINE-COMPOSITE id son score-multiplier set-definition ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-DPDC:module{DpdcV1} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
                    ;;
                    (creator:string (ref-DPDC::UR_CreatorKonto id son))
                    (price:decimal (ref-DALOS::UR_UsagePrice "ignis|token-issue"))
                    (set-class:integer (XI_CompositeSet id son set-name score-multiplier set-definition ind))
                    (ico0:object{IgnisCollectorV1.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    )
                    (ico1:object{IgnisCollectorV1.OutputCumulator}
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
    (defun C_DefineHybridSet:object{IgnisCollectorV1.OutputCumulator}
        (
            id:string son:bool set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV1.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        (UEV_IMC)
        (with-capability (DPDC-S|C>DEFINE-HYBRID id son score-multiplier primordial-sd composite-sd ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-DPDC:module{DpdcV1} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (creator:string (ref-DPDC::UR_CreatorKonto id son))
                    (price:decimal (ref-DALOS::UR_UsagePrice "ignis|token-issue"))
                    (set-class:integer (XI_HybridSet id son set-name score-multiplier primordial-sd composite-sd ind))
                    (ico0:object{IgnisCollectorV1.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price creator false [])
                    )
                    (ico1:object{IgnisCollectorV1.OutputCumulator}
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
    (defun C_EnableSetClassFragmentation:object{IgnisCollectorV1.OutputCumulator}
        (
            id:string son:bool set-class:integer
            fragmentation-ind:object{DpdcUdcV1.DPDC|NonceData}
        )
        (UEV_IMC)
        (with-capability (DPDC-S|C>ENABLE-FRAGMENTATION id son set-class fragmentation-ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPDC:module{DpdcV1} DPDC)
                )
                (XI_FragmentSetClass id son set-class fragmentation-ind)
                (ref-IGNIS::UDC_BiggestCumulator (ref-DPDC::UR_CreatorKonto id son))
            )
        )
    )
    (defun C_ToggleSet:object{IgnisCollectorV1.OutputCumulator} (id:string son:bool set-class:integer toggle:bool)
        (UEV_IMC)
        (with-capability (DPDC-S|C>TOGGLE id son set-class toggle)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPDC:module{DpdcV1} DPDC)
                )
                (XI_ToggleSetClass id son set-class toggle)
                (ref-IGNIS::UDC_BiggestCumulator (ref-DPDC::UR_CreatorKonto id son))
            )
        )
    )
    (defun C_RenameSet:object{IgnisCollectorV1.OutputCumulator} (id:string son:bool set-class:integer new-name:string)
        (UEV_IMC)
        (with-capability (DPDC-S|C>RENAME id son set-class new-name)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPDC:module{DpdcV1} DPDC)
                )
                (XI_RenameSet id son set-class new-name)
                (ref-IGNIS::UDC_SmallCumulator (ref-DPDC::UR_CreatorKonto id son))
            )
        )
    )
    ;;{F9}  REPL (test-only, stripped at mainnet) [REPL]
    ;;
)

(create-table P|T)
(create-table P|MT)
;;DPSF
(create-table DPSF|SetsTable)
;;DPNF
(create-table DPNF|SetsTable)
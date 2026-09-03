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
    (defun URCi_RepurposeCollectableFragments:object{IgnisCollectorV2.OutputCumulator} (id:string son:bool fragment-amounts:[integer]))
    (defun URCi_MakeFragments:object{IgnisCollectorV2.OutputCumulator} (id:string son:bool))
    (defun URCi_MergeFragments:object{IgnisCollectorV2.OutputCumulator} (id:string son:bool))
    (defun URCi_EnableNonceFragmentation:object{IgnisCollectorV2.OutputCumulator} (id:string son:bool))
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
    (defun C_RepurposeCollectableFragments:object{IgnisCollectorV2.OutputCumulator}
        (id:string son:bool repurpose-from:string repurpose-to:string fragment-nonces:[integer] fragment-amounts:[integer])
    )
    (defun C_MakeFragments:object{IgnisCollectorV2.OutputCumulator} (account:string id:string son:bool nonce:integer amount:integer))
    (defun C_MergeFragments:object{IgnisCollectorV2.OutputCumulator} (account:string id:string son:bool nonce:integer amount:integer))
    (defun C_EnableNonceFragmentation:object{IgnisCollectorV2.OutputCumulator}
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
        (at "m-policies" (read P|MT P|I ["m-policies"]))
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
    (defun URCi_RepurposeCollectableFragments:object{IgnisCollectorV2.OutputCumulator}
        (id:string son:bool fragment-amounts:[integer])
        @doc "Cost preview for C_RepurposeCollectableFragments: per-fragment construct \
            \ priced ((if son small else medium)/1000) * (1 + sum fragment-amounts), \
            \ empty output list."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (owner:string (ref-DPDC::UR_OwnerKonto id son))
                (s:decimal (ref-DALOS::UR_UsagePrice "ignis|small"))
                (m:decimal (ref-DALOS::UR_UsagePrice "ignis|medium"))
                (p:decimal (/ (if son s m) 1000.0))
                (sum-amounts:decimal (dec (fold (+) 1 fragment-amounts)))
                (price:decimal (* p sum-amounts))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price owner (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_MakeFragments:object{IgnisCollectorV2.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_MakeFragments (Biggest on creator-konto; the internal \
            \ transfers are not separately billed)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_BiggestCumulator (ref-DPDC::UR_CreatorKonto id son))
        )
    )
    (defun URCi_MergeFragments:object{IgnisCollectorV2.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_MergeFragments (Biggest on creator-konto; the internal \
            \ transfers are not separately billed)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_BiggestCumulator (ref-DPDC::UR_CreatorKonto id son))
        )
    )
    (defun URCi_EnableNonceFragmentation:object{IgnisCollectorV2.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_EnableNonceFragmentation (Smallest on creator-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-IGNIS::UDC_SmallestCumulator (ref-DPDC::UR_CreatorKonto id son))
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
    (defun C_RepurposeCollectableFragments:object{IgnisCollectorV2.OutputCumulator}
        (id:string son:bool repurpose-from:string repurpose-to:string fragment-nonces:[integer] fragment-amounts:[integer])
        (P|UEV_IMC)
        (with-capability (DPDC-F|C>REPURPOSE id son repurpose-from repurpose-to fragment-nonces fragment-amounts)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    ;;
                    (l:integer (length fragment-nonces))
                    (owner:string (ref-DPDC::UR_OwnerKonto id son))
                    (s:decimal (ref-DALOS::UR_UsagePrice "ignis|small"))
                    (m:decimal (ref-DALOS::UR_UsagePrice "ignis|medium"))
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
    (defun C_MakeFragments:object{IgnisCollectorV2.OutputCumulator}
        (account:string id:string son:bool nonce:integer amount:integer)
        (P|UEV_IMC)
        (with-capability (DPDC-F|C>NONCE id son nonce)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
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
    (defun C_MergeFragments:object{IgnisCollectorV2.OutputCumulator}
        (account:string id:string son:bool nonce:integer amount:integer)
        (P|UEV_IMC)
        (with-capability (DPDC-F|C>MERGE id son nonce amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
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
    (defun C_EnableNonceFragmentation:object{IgnisCollectorV2.OutputCumulator}
        (
            id:string son:bool nonce:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        (P|UEV_IMC)
        (with-capability (DPDC-F|C>ENABLE-FRAGMENTATION id son nonce fragmentation-ind)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
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

(create-table P|T)
(create-table P|MT)
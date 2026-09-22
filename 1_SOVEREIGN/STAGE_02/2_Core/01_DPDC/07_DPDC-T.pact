;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DpdcTransferV2
    @doc "Exposes Collectables Transfer Functions"

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
    ;;  [Schemas]
    ;;
    (defschema AggregatedRoyalties
        creators:[string]
        ignis-royalties:[decimal]
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
    (defun UC_AndTruths:bool (truths:[bool]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URC]
    ;;
    (defun URC_TransferRoleChecker:bool (id:string son:bool sender:string))
    (defun URC_SummedIgnisRoyalty:decimal (sender:string id:string son:bool nonces:[integer] amounts:[integer]))
    (defun URC_TotalTransferPrice:decimal (id:string son:bool nonces:[integer] amounts:[integer]))
    ;;
    ;;  [UDC]
    ;;
    (defun URCi_MultiTransferCumulator:object{IgnisCollectorV3.OutputCumulator} (ids:[string] sons:[bool] sender:string receiver:string nonces-array:[[integer]] amounts-array:[[integer]]))
    (defun URCi_RepurposeCollectable:object{IgnisCollectorV3.OutputCumulator} (id:string son:bool amounts:[integer]))
    (defun URCi_BulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool sender:string receiver-lst:[string] nonces-array:[[integer]] amounts-array:[[integer]])
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_TransferRoles (id:string son:bool sender:string receiver:string))
    (defun UEV_TransferRoleChecker (trc:bool s:bool r:bool))
    (defun UEV_AmountsForTransfer (id:string son:bool nonces:[integer] amounts:[integer]))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_RepurposeCollectable:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool repurpose-to:string nonces:[integer] amounts:[integer])
    )
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string ids:[string] sons:[bool] nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
    )
    (defun C_IgnisRoyaltyCollector:object{AggregatedRoyalties}
        (patron:string executor:string ids:[string] sons:[bool] nonces-array:[[integer]] amounts-array:[[integer]])
    )
    (defun C_BulkTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee-lst:[string] id:string son:bool nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
    )

)
;;
(module DPDC-T GOV
    @doc "Transfer module for the DPDC collectables (NFT/SFT) family, implementing \
        \ DpdcTransferV2 and OuronetPolicyV2. Client entrypoints move native and fragment \
        \ nonces between accounts: C_Transfer (multi id/son, single receiver), \
        \ C_BulkTransfer (one id/son, many receivers), and C_RepurposeCollectable. It \
        \ enforces transfer roles, pause/freeze states, transferability and account \
        \ ownership, computes and collects IGNIS creator royalties \
        \ (C_IgnisRoyaltyCollector), and returns IGNIS gas cumulators."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DpdcTransferV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-T                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPDC-T_ADMIN)))
    (defcap GOV|DPDC-T_ADMIN ()                         (enforce-guard GOV|MD_DPDC-T))
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
    (defcap P|DPDC-T|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-T|CALLER))
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
        (with-capability (GOV|DPDC-T_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DPDC-T_ADMIN)
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
        (with-capability (GOV|DPDC-T_ADMIN)
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
        (with-capability (GOV|DPDC-T_ADMIN)
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
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (mg:guard (create-capability-guard (P|DPDC-T|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
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
    (defcap IGNIS|C>NO-ROYALTY ()
        true
    )
    ;;{C2}  Simple
    (defcap DPDC-T|C>REPURPOSE
        (executor:string id:string son:bool repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Forced move of <id> nonces from <repurpose-from> to <repurpose-to>. \
            \ \
            \ HANDOFF 4g. This capability proves no account and never did: the authority is the \
            \ COLLECTION OWNER, enforced three hops downstream in DPDC-C's DPDC|CX>MULTI-DEBIT, \
            \ (if wipe-mode (CAP_Owner id son) (CAP_EnforceAccountOwnership account)) -- and \
            \ C_RepurposeCollectable reaches it with wipe-mode TRUE. CAP_Owner enforces on the \
            \ DERIVED (UR_OwnerKonto id son) and so names no actor; the binder below supplies \
            \ the other half, that the executor the caller DECLARED is that owner. \
            \ \
            \ <repurpose-from> is the EXECUTEE: it is debited without being consulted. That is \
            \ the whole point of a repurpose and the reason it cannot be the executor. Mirrors \
            \ VST|C>REPURPOSE-TRUE-FUNGIBLE, which resolved the identical shape. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (l1:integer (length nonces))
                (l2:integer (length amounts))
            )
            (ref-DPDC::UEV_ExecutorIsOwnerKonto executor id son)
            (enforce (= l1 l2) "Invalid Repurpose data")
        )
    )
    (defcap DPDC-T|S>BULK-TRANSFER
        (id:string son:bool sender:string receiver-lst:[string] method:bool)
        @doc "Bulk transfer guards — same family as DPDC-T|C>TRANSFER over receiver-lst. \
            \ Standard Ouronet accounts only (no smart accounts in receiver-lst)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (l:integer (length receiver-lst))
            )
            (ref-U|LST::UEV_IzUnique receiver-lst)
            (ref-DPDC::UEV_PauseState id son false)
            (ref-DPDC::UEV_AccountFreezeState id son sender false)
            (map
                (lambda (idx:integer)
                    (let
                        (
                            (receiver:string (at idx receiver-lst))
                        )
                        (ref-DALOS::UEV_EnforceAccountType receiver false)
                        (ref-DALOS::UEV_EnforceTransferability sender receiver method)
                        (ref-DPDC::UEV_AccountFreezeState id son receiver false)
                        (UEV_TransferRoles id son sender receiver)
                    )
                )
                (enumerate 0 (- l 1))
            )
        )
    )
    ;;{C3}  Composed
    (defcap DPDC-T|C>TRANSFER (ids:[string] sons:[bool] sender:string receiver:string nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @event
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (l1:integer (length ids))
                (l2:integer (length sons))
                (l3:integer (length nonces-array))
                (l4:integer (length amounts-array))
            )
            ;;Single
            (ref-U|INT::UEV_UniformList [l1 l2 l3 l4])
            (if (and method (ref-DALOS::UR_AccountType receiver))
                (ref-DALOS::CAP_EnforceAccountOwnership receiver)
                true
            )
            (ref-DALOS::CAP_EnforceAccountOwnership sender)
            (ref-DALOS::UEV_EnforceTransferability sender receiver method)
            ;;Multi
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (id:string (at idx ids))
                            (son:bool (at idx sons))
                            (nonces:[integer] (at idx nonces-array))
                            (amounts:[integer] (at idx amounts-array))
                        )
                        (ref-DPDC::UEV_PauseState id son false)
                        (ref-DPDC::UEV_AccountFreezeState id son sender false)
                        (ref-DPDC::UEV_AccountFreezeState id son receiver false)
                        (UEV_TransferRoles id son sender receiver)
                        (UEV_AmountsForTransfer id son nonces amounts)
                    )
                )
                (enumerate 0 (- l1 1))
            )
            ;;Capabilities
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap DPDC-T|C>BULK-TRANSFER
        (id:string son:bool nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        @doc "Bulk collectable transfer (one id/son, many receivers). Composes DPDC-T|S>BULK-TRANSFER like C>TRANSFER."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (l:integer (length receiver-lst))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership sender)
            (enforce
                (fold (and) true
                    [
                        (> l 0)
                        (= l (length nonces-array))
                        (= l (length amounts-array))
                    ]
                )
                "Invalid DPDC bulk transfer: receiver/nonces/amounts legs"
            )
            (map
                (lambda (idx:integer)
                    (UEV_AmountsForTransfer
                        id
                        son
                        (at idx nonces-array)
                        (at idx amounts-array)
                    )
                )
                (enumerate 0 (- l 1))
            )
            (compose-capability (DPDC-T|S>BULK-TRANSFER id son sender receiver-lst method))
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap IGNIS|C>ROYALTY (sender:string receiver:string ta:decimal)
        @event
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (enforce (!= sender receiver) "Sender and Receiver must be different")
            ;;`ta` is not a client argument. The ONLY acquirer is C_IgnisRoyaltyCollector, which
            ;;reaches this cap through two filters that together make a non-positive `ta` impossible:
            ;;  1. `(if (or ivgz (= sum 0.0)) <NO-ROYALTY branch> ...)` -- a zero TOTAL never gets here;
            ;;  2. `UC_CleanseAggregatedRoyalties` drops every entry whose royalty is 0.0, so the
            ;;     per-creator amounts this cap is handed are all non-zero by construction.
            ;;Royalties are summed from unsigned per-nonce prices, so non-zero means positive.
            ;;Kept as defence-in-depth for a future acquirer that does not cleanse first.
            ;;Pinned by REPL/modules/DPDC.repl <<DPDC-G16>>, which drives the cleanse directly -- pure
            ;;compute, no fixture -- so this annotation cannot rot if the filter is ever weakened.
            ;;UNREACHABLE via its only caller.
            (enforce (> ta 0.0) "Cannot debit|credit 0.0 or negative IGNIS amounts")
            (ref-IGNIS::UEV_TwentyFourPrecision ta)
            (compose-capability (IGNIS|C>DEBIT sender ta))
            (compose-capability (IGNIS|C>CREDIT receiver))
        )
    )
    (defcap IGNIS|C>CREDIT (receiver:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists receiver)
            (compose-capability (P|DPDC-T|CALLER))
        )
    )
    (defcap IGNIS|C>DEBIT (sender:string ta:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (read-gas:decimal (ref-DALOS::UR_TF_AccountSupply sender false))
            )
            (enforce (<= ta read-gas) "Insufficient IGNIS for Debiting")
            (ref-DALOS::UEV_EnforceAccountExists sender)
            (ref-DALOS::UEV_EnforceAccountType sender false)
            (ref-DALOS::CAP_EnforceAccountOwnership sender)
            (compose-capability (P|DPDC-T|CALLER))
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
    (defun UDCx_AggregatedRoyalties:object{DpdcTransferV2.AggregatedRoyalties}
        (a:[string] b:[decimal])
        {"creators"         : a
        ,"ignis-royalties"  : b}
    )
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_AndTruths:bool (truths:[bool])
        (fold (and) true truths)
    )
    (defun UC_CleanseAggregatedRoyalties:object{DpdcTransferV2.AggregatedRoyalties} (agg:object{DpdcTransferV2.AggregatedRoyalties})
        (let
            (
                (agg-creators:[string] (at "creators" agg))
                (agg-royalties:[decimal] (at "ignis-royalties" agg))
                (non-zero-indices:[integer]
                    (filter
                        (lambda 
                            (idx:integer) 
                            (!= (at idx agg-royalties) 0.0)
                        )
                        (enumerate 0 (- (length agg-royalties) 1))
                    )
                )
                (how-many-non-zeroes:integer (length non-zero-indices))
                (how-many-zeroes:integer (- (length agg-royalties) how-many-non-zeroes))
            )
            (if (= how-many-zeroes 0)
                agg
                (UDCx_AggregatedRoyalties
                    ;;Creators
                    (map
                        (lambda (idx:integer) (at idx agg-creators))
                        non-zero-indices
                    )
                    ;;Royalties
                    (map
                        (lambda (idx:integer) (at idx agg-royalties))
                        non-zero-indices
                    )
                )
            )
        )
    )
    (defun UC_AggregateRoyalties:object{DpdcTransferV2.AggregatedRoyalties}
        (creators:[string] id-ignis-royalties:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (d-creators:[string] (distinct creators))
            )
            (UDCx_AggregatedRoyalties
                d-creators
                (fold
                    (lambda
                        (acc:[decimal] idx:integer)
                        (let
                            (
                                (creator:string (at idx d-creators))
                                (c-idxes:[integer] (ref-U|LST::UC_Search creators creator))
                            )
                            (ref-U|LST::UC_AppL acc
                                (fold
                                    (lambda
                                        (accc:decimal idx:integer)
                                        (+ accc (at (at idx c-idxes) id-ignis-royalties))
                                    )
                                    0.0
                                    (enumerate 0 (- (length c-idxes) 1))
                                )
                            )
                        )
                    )
                    []
                    (enumerate 0 (- (length d-creators) 1))
                )
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_TransferRoleChecker:bool (id:string son:bool sender:string)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                (verum:[string] (ref-DPDC::UR_Verum11 id son))
                (lv:integer (length verum))
                (tra:integer
                    (if (and (= lv 1) (= verum [BAR]))
                        0
                        lv
                    )
                )
            )
            (and
                (> tra 0)
                (not (= sender dpdc))
            )
        )
    )
    (defun URC_SummedIgnisRoyalty:decimal (sender:string id:string son:bool nonces:[integer] amounts:[integer])
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (creator:string (ref-DPDC::UR_CreatorKonto id son))
            )
            (if (= sender creator)
                0.0
                (fold
                    (lambda
                        (acc:decimal idx:integer)
                        (+ 
                            acc 
                            (* 
                                (dec (at idx amounts)) 
                                (ref-DPDC::UR_N|IgnisRoyalty (ref-DPDC::UR_NonceData id son (at idx nonces)))
                            )
                        )
                    )
                    0.0
                    (enumerate 0 (- (length nonces) 1))
                )
            )
        )
    )
    (defun URC_TotalTransferPrice:decimal
        (id:string son:bool nonces:[integer] amounts:[integer])
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ft:string (take 2 id))
                (sh:string "E|")
                (sl:decimal (ref-IGNIS::UC_IgnisLeg "tier-smallest"))
                (s:decimal (ref-IGNIS::UC_IgnisLeg "tier-small"))
                (m:decimal (ref-IGNIS::UC_IgnisLeg "tier-medium"))
                (th:decimal (/ sl 1000.0))
            )
            (fold
                (lambda
                    (acc:decimal idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (amount:integer (at idx amounts))
                            (price-per-nonce:decimal
                                (if (or (< nonce 0) (fold (and) true [(= ft sh) son (= nonce 1)]))
                                    th
                                    (if son s m)
                                )
                            )
                            (total-price-per-nonce:decimal (* price-per-nonce (dec amount)))
                            (flat-price-per-nonce:decimal
                                (if (> nonce 0)
                                    0.0
                                    (if (= (mod amount 1000) 0)
                                        (dec (/ amount 1000))
                                        (dec (+ (/ amount 1000) 1))
                                    )
                                )
                            )
                        )
                        (fold (+) 0.0 [acc total-price-per-nonce flat-price-per-nonce])
                    )
                )
                0.0
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    (defun URCi_MultiTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (ids:[string] sons:[bool] sender:string receiver:string nonces-array:[[integer]] amounts-array:[[integer]])
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (fold
                    (lambda
                        (acc:decimal idx:integer)
                        (+ acc (URC_TotalTransferPrice (at idx ids) (at idx sons) (at idx nonces-array) (at idx amounts-array)))
                    )
                    0.0
                    (enumerate 0 (- (length ids) 1))
                )
                sender
                (ref-IGNIS::URC_ZeroEliteGAZ sender receiver) []
            )
        )
    )
    (defun URCi_BulkTransferCumulator:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool sender:string receiver-lst:[string] nonces-array:[[integer]] amounts-array:[[integer]])
        @doc "Single IGNIS output for bulk transfer — sum URC_TotalTransferPrice per receiver leg once."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (l:integer (length receiver-lst))
                ;;FIXED 2026-09-12: the fold is guarded on l=0.
                ;;`(enumerate 0 (- l 1))` for l=0 is `[0, -1]` -- a DESCENDING PAIR, not an empty
                ;;list -- so an empty receiver list indexed `(at 0 nonces-array)` on empty arrays and
                ;;raised `Array index out of bounds. Length (0), Index (0)` out of a COST PREVIEW.
                ;;This is a `URCi_` reader, so it must stay a pure derivation and cannot `enforce`
                ;;(StoicSyntax: validation belongs in the defcap). Making it TOTAL is the correct
                ;;shape: an empty bulk transfer has no legs, so it has no cost. The CLIENT still
                ;;refuses the input -- DPDC-T|C>BULK-TRANSFER's shape guard now answers, since
                ;;TS02-C1 calls the core before deriving anything (both fixed in the same pass).
                (total:decimal
                    (if (= l 0)
                        0.0
                        (fold
                            (lambda (acc:decimal idx:integer)
                                (+ acc
                                    (URC_TotalTransferPrice
                                        id
                                        son
                                        (at idx nonces-array)
                                        (at idx amounts-array)
                                    )
                                )
                            )
                            0.0
                            (enumerate 0 (- l 1))
                        )
                    )
                )
                ;;FIXED 2026-09-12, same cause as `total` above: this mapped over
                ;;`(enumerate 0 (- l 1))` purely to index back into `receiver-lst`, so an empty list
                ;;became `[0, -1]` and `(at 0 receiver-lst)` faulted. There is nothing to zip here --
                ;;only one list is read -- so mapping over `receiver-lst` ITSELF is both simpler and
                ;;total. `(fold (or) false [])` is correctly `false`: no receivers, no zero-elite leg.
                (zero-elite:bool
                    (fold
                        (or)
                        false
                        (map
                            (lambda (rcv:string)
                                (ref-IGNIS::URC_ZeroEliteGAZ sender rcv)
                            )
                            receiver-lst
                        )
                    )
                )
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator total sender zero-elite [])
        )
    )
    ;;
    ;;  (URCi_MultiTransferCumulator / URCi_BulkTransferCumulator, below, cover the transfers.)
    (defun URCi_RepurposeCollectable:object{IgnisCollectorV3.OutputCumulator}
        (id:string son:bool amounts:[integer])
        @doc "Cost preview for C_RepurposeCollectable: per-nonce construct priced \
            \ (if son small else medium) * (1 + sum amounts) on owner-konto, empty output."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                (owner:string (ref-DPDC::UR_OwnerKonto id son))
                (p:decimal (if son (ref-IGNIS::UC_IgnisLeg "tier-small") (ref-IGNIS::UC_IgnisLeg "tier-medium")))
                (sum-amounts:decimal (dec (fold (+) 1 amounts)))
                (price:decimal (* p sum-amounts))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price owner (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_TransferRoles (id:string son:bool sender:string receiver:string)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (trc:bool (URC_TransferRoleChecker id son sender))
                (s:bool (ref-DPDC::UR_CA|R-Transfer id son sender))
                ;; DPDC Audit #16H: was reading <sender> twice (copy-paste) — the receiver-side check
                ;; needs the receiver's own role, matching DPOF's correct sibling pattern
                ;; (UEV_MoveRoleCheck, 06_DPOF.pact:1618-1619).
                (r:bool (ref-DPDC::UR_CA|R-Transfer id son receiver))
            )
            (UEV_TransferRoleChecker trc s r)
        )
    )
    (defun UEV_TransferRoleChecker (trc:bool s:bool r:bool)
        (if
            trc
            (enforce-one
                "Invalid TR"
                [
                    (enforce s "Invalid TR Sender")
                    (enforce r "Invalid TR Receiver")
                ]
            )
            true
        )
    )
    (defun UEV_AmountsForTransfer (id:string son:bool nonces:[integer] amounts:[integer])
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (l1:integer (length nonces))
                (l2:integer (length amounts))
            )
            (enforce (= l1 l2) "Invalid Nonces|Amounts Pair for Collectable Transfer")
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (amount:integer (at idx amounts))
                            (nonce-supply:integer (ref-DPDC::UR_NonceSupply id son nonce))
                        )
                        (if (and (not son) (> nonce 0))
                            (enforce (= amount 1) "When transfering Native NFT Nonces, their amount must be 1")
                            true
                        )
                    )
                )
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 1 — Innate protection offered by XE_DebitSFT-Nonce,
    ;;Protection:          XB_CreditSFT-Nonce, XE_DebitNFT-Nonce, XB_CreditNFT-Nonce,
    ;;Protection:          XE_DebitSFT-FragmentNonce, XE_CreditSFT-FragmentNonce,
    ;;Protection:          XE_DebitNFT-FragmentNonce, XE_CreditNFT-FragmentNonce,
    ;;Protection:          XE_DebitSFT-Nonces, XB_CreditSFT-Nonces, XE_DebitNFT-Nonces,
    ;;Protection:          XB_CreditNFT-Nonces, XE_DebitSFT-FragmentNonces,
    ;;Protection:          XE_CreditSFT-FragmentNonces, XE_DebitNFT-FragmentNonces,
    ;;Protection:          XE_CreditNFT-FragmentNonces, XE_DebitSFT-HybridNonces,
    ;;Protection:          XE_CreditSFT-HybridNonces, XE_DebitNFT-HybridNonces,
    ;;Protection:          XE_CreditNFT-HybridNonces
    (defun XI_TransferNonces (id:string son:bool sender:string receiver:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
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
                ;;Transfer Native Nonce
                ((UC_AndTruths [isg (not inn) son])
                    (do
                        (ref-DPDC-C::XE_DebitSFT-Nonce sender id n0 a0 false)
                        (ref-DPDC-C::XB_CreditSFT-Nonce receiver id n0 a0)
                    )
                )
                ((UC_AndTruths [isg (not inn) (not son)])
                    (do
                        (ref-DPDC-C::XE_DebitNFT-Nonce sender id n0 a0 false)
                        (ref-DPDC-C::XB_CreditNFT-Nonce receiver id n0 a0)
                    )
                )
                ;;Trasnfer Fragment Nonce
                ((UC_AndTruths [isg inn son])
                    (do
                        (ref-DPDC-C::XE_DebitSFT-FragmentNonce sender id n0 a0 false)
                        (ref-DPDC-C::XE_CreditSFT-FragmentNonce receiver id n0 a0)
                    )
                )
                ((UC_AndTruths [isg inn (not son)])
                    (do
                        (ref-DPDC-C::XE_DebitNFT-FragmentNonce sender id n0 a0 false)
                        (ref-DPDC-C::XE_CreditNFT-FragmentNonce receiver id n0 a0)
                    )
                )
                ;;
                ;;MULTI
                ;;Transfer Native Nonces
                ((UC_AndTruths [(not isg) (not ong) onp son])
                    (do
                        (ref-DPDC-C::XE_DebitSFT-Nonces sender id nonces amounts false)
                        (ref-DPDC-C::XB_CreditSFT-Nonces receiver id nonces amounts)
                    )
                )
                ((UC_AndTruths [(not isg) (not ong) onp (not son)])
                    (do
                        (ref-DPDC-C::XE_DebitNFT-Nonces sender id nonces amounts false)
                        (ref-DPDC-C::XB_CreditNFT-Nonces receiver id nonces amounts)
                    )
                )
                ;;Transfer Fragment Nonces
                ((UC_AndTruths [(not isg) ong son])
                    (do
                        (ref-DPDC-C::XE_DebitSFT-FragmentNonces sender id nonces amounts false)
                        (ref-DPDC-C::XE_CreditSFT-FragmentNonces receiver id nonces amounts)
                    )
                )
                ((UC_AndTruths [(not isg) ong (not son)])
                    (do
                        (ref-DPDC-C::XE_DebitNFT-FragmentNonces sender id nonces amounts false)
                        (ref-DPDC-C::XE_CreditNFT-FragmentNonces receiver id nonces amounts)
                    )
                )
                ;;Transfer Hybrid (Native and Fragment) Nonces
                ((UC_AndTruths [(not isg) (not ong) (not onp) son])
                    (do
                        (ref-DPDC-C::XE_DebitSFT-HybridNonces sender id nonces amounts)
                        (ref-DPDC-C::XE_CreditSFT-HybridNonces receiver id nonces amounts)
                    )
                )
                ((UC_AndTruths [(not isg) (not ong) (not onp) (not son)])
                    (do
                        (ref-DPDC-C::XE_DebitNFT-HybridNonces sender id nonces amounts)
                        (ref-DPDC-C::XE_CreditNFT-HybridNonces receiver id nonces amounts)
                    )
                )
            )
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: IGNIS|C>ROYALTY
    (defun XI_IgnisTransfer (sender:string receiver:string ta:decimal)
        (require-capability (IGNIS|C>ROYALTY sender receiver ta))
        (XI_IgnisDebit sender ta)
        (XI_IgnisCredit receiver ta)
    )
    ;;Protection: Class 3 — Custom: IGNIS|C>CREDIT
    (defun XI_IgnisCredit (receiver:string ta:decimal)
        (require-capability (IGNIS|C>CREDIT receiver))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::XB_UpdateBalance receiver false (+ (ref-DALOS::UR_TF_AccountSupply receiver false) ta))
        )
    )
    ;;Protection: Class 3 — Custom: IGNIS|C>DEBIT
    (defun XI_IgnisDebit (sender:string ta:decimal)
        (require-capability (IGNIS|C>DEBIT sender ta))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::XB_UpdateBalance sender false (- (ref-DALOS::UR_TF_AccountSupply sender false) ta))
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_RepurposeCollectable:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Forcibly moves <id> nonces from <executee> to <repurpose-to>, on the collection \
            \ owner's authority. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. The debit legs below pass wipe-mode TRUE \
            \ to DPDC-C::XE_Debit*-Nonce(s), which selects (CAP_Owner id son) in \
            \ DPDC|CX>MULTI-DEBIT -- ownership of the DERIVED collection owner, HANDOFF 4g. \
            \ DPDC-T|C>REPURPOSE binds <executor> to that same (UR_OwnerKonto id son). \
            \ Executee: NOT consulted, by design -- <executee> is debited whether or not it \
            \ agrees, which is what makes this a repurpose rather than a transfer. Its \
            \ consent gate is the collection's, not its own. \
            \ \
            \ The three-argument shape it replaces read (id son repurpose-from repurpose-to ...) \
            \ and recorded no actor at all; the account that LOOKED like one was the target. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DPDC-T|C>REPURPOSE executor id son executee repurpose-to nonces amounts)
            ;;DEAD PRE-COMPUTATION REMOVED (2026-09-22). This `let` also bound
            ;;<owner>/<s>/<m>/<p>/<sum-amounts>/<price>/<trigger> and read NONE of them --
            ;;_deadbind reported <price> and <trigger>, and <owner> fell out with them once the
            ;;4g binder replaced it. Every one is recomputed, identically, inside the
            ;;URCi_RepurposeCollectable call that ends this function: it derives the same owner
            ;;konto, the same tier leg, the same (1 + Sum amounts) and the same virtual-gas
            ;;trigger. So this was the cost model left behind when the cumulator was factored
            ;;out, not a second one -- deleting it drops two table reads and changes no price.
            (let
                (
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    ;;
                    (l:integer (length nonces))
                )
                (if (= l 1)
                    ;;Single Mode
                    (let
                        (
                            (nonce:integer (at 0 nonces))
                            (amount:integer (at 0 amounts))
                        )
                        ;;1]Debit from <repurpose-from>
                        (if son
                            (ref-DPDC-C::XE_DebitSFT-Nonce executee id nonce amount true)
                            (ref-DPDC-C::XE_DebitNFT-Nonce executee id nonce amount true)
                        )
                        ;;2]Credit to <repurpose-to>
                        (if son
                            (ref-DPDC-C::XB_CreditSFT-Nonce repurpose-to id nonce amount)
                            (ref-DPDC-C::XB_CreditNFT-Nonce repurpose-to id nonce amount)
                        )
                    )
                    ;;Multi Mode
                    (do
                        (if son
                            ;;1]Debit from <repurpose-from>
                            (ref-DPDC-C::XE_DebitSFT-Nonces executee id nonces amounts true)
                            (ref-DPDC-C::XE_DebitNFT-Nonces executee id nonces amounts true)
                        )
                        (if son
                            ;;2]Credit to <repurpose-to>
                            (ref-DPDC-C::XB_CreditSFT-Nonces repurpose-to id nonces amounts)
                            (ref-DPDC-C::XB_CreditNFT-Nonces repurpose-to id nonces amounts)
                        )
                    )
                )
                ;;3]Output Cumulator
                (URCi_RepurposeCollectable id son amounts)
            )
        )
    )
    (defun C_Transfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string ids:[string] sons:[bool] nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Moves nonce slices of several collectables from <executor> to <executee> in one \
            \ call. \
            \ \
            \ Executor: ENFORCED DIRECTLY -- DPDC-T|C>TRANSFER opens on \
            \ (CAP_EnforceAccountOwnership sender) unconditionally, on the parameter itself. \
            \ Executee: ENFORCED CONDITIONALLY, in the same capability -- only when <method> is \
            \ true AND the executee is a SMART account, because crediting a contract-owned \
            \ account is an act upon that contract. A standard executee is merely credited. \
            \ Same rule, same shape, as TFT::C_Transfer on the true-fungible side. \
            \ (patron/executor canon 2.2, conditional executee named, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DPDC-T|C>TRANSFER ids sons executor executee nonces-array amounts-array method)
            (map
                (lambda
                    (idx:integer)
                    (XI_TransferNonces (at idx ids) (at idx sons) executor executee (at idx nonces-array) (at idx amounts-array))
                )
                (enumerate 0 (- (length ids) 1))
            )
            (URCi_MultiTransferCumulator ids sons executor executee nonces-array amounts-array)
        )
    )
    (defun C_BulkTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee-lst:[string] id:string son:bool nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Bulk collectable transfer: one id/son, one executor, many standard-account \
            \ executees (DpdcTransferV2). \
            \ \
            \ Executor: ENFORCED DIRECTLY -- DPDC-T|C>BULK-TRANSFER opens on \
            \ (CAP_EnforceAccountOwnership sender), on the parameter itself. \
            \ Executees: NOT enforced, and unlike C_Transfer they cannot be: \
            \ DPDC-T|S>BULK-TRANSFER runs (UEV_EnforceAccountType receiver false) over the \
            \ whole list, so every executee here is by construction a STANDARD account, which \
            \ is the exact case C_Transfer's conditional arm also declines to check. A plural \
            \ executee slot takes the plural name, as DPTF|C_BulkTransfer does. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability
            (DPDC-T|C>BULK-TRANSFER id son nonces-array amounts-array executor executee-lst method)
            (do
                (map
                    (lambda (idx:integer)
                        (XI_TransferNonces
                            id
                            son
                            executor
                            (at idx executee-lst)
                            (at idx nonces-array)
                            (at idx amounts-array)
                        )
                    )
                    (enumerate 0 (- (length executee-lst) 1))
                )
                (URCi_BulkTransferCumulator id son executor executee-lst nonces-array amounts-array)
            )
        )
    )
    (defun C_IgnisRoyaltyCollector:object{DpdcTransferV2.AggregatedRoyalties}
        (patron:string executor:string ids:[string] sons:[bool] nonces-array:[[integer]] amounts-array:[[integer]])
        @doc "Pays each collectable creator their IGNIS royalty for a move <executor> is making, \
            \ OUT OF THE PATRON, and returns the aggregate for the caller's result string. \
            \ \
            \ Executor: ENFORCED DIRECTLY, and the enforce is NEW (2026-09-22). The old <sender> \
            \ was read and never proven, and it is not decoration: URC_SummedIgnisRoyalty \
            \ short-circuits to 0.0 when the sender IS the creator, so a caller free to name \
            \ any sender is a caller free to name the creator and pay no royalty at all. \
            \ Unreachable from a client today -- P|UEV_IMC admits only registered modules, and \
            \ all five call sites pass an account a sibling call in the same transaction \
            \ proves -- but 'proven by my caller's other call' is not a property this function \
            \ holds, and §4f is explicit that an unenforced executor is worse than none. \
            \ The check is a no-op at every existing site by construction. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (ivgz:bool (ref-IGNIS::URC_IsVirtualGasZero))
                ;;
                (creators:[string]
                    (map
                        (lambda
                            (idx:integer)
                            (ref-DPDC::UR_CreatorKonto (at idx ids) (at idx sons))
                        )
                        (enumerate 0 (- (length ids) 1))
                    )
                )
                (ids-ignis-royalties:[decimal]
                    (map
                        (lambda
                            (idx:integer)
                            (URC_SummedIgnisRoyalty executor (at idx ids) (at idx sons) (at idx nonces-array) (at idx amounts-array))
                        )
                        (enumerate 0 (- (length ids) 1))
                    )
                )
                (sum:decimal (fold (+) 0.0 ids-ignis-royalties))
            )
            ;;ATTRIBUTION (canon 2.2): the royalty is computed FROM the executor, so the
            ;;executor has to be real. See the @doc.
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
            (if (or ivgz (= sum 0.0))
                (with-capability (IGNIS|C>NO-ROYALTY )
                    (UDCx_AggregatedRoyalties [""] [0.0])
                )
                (let
                    (
                        (agg:object{DpdcTransferV2.AggregatedRoyalties} (UC_AggregateRoyalties creators ids-ignis-royalties))
                        (cleansed-agg:object{DpdcTransferV2.AggregatedRoyalties} (UC_CleanseAggregatedRoyalties agg))
                        (agg-creators:[string] (at "creators" cleansed-agg))
                        (agg-royalties:[decimal] (at "ignis-royalties" cleansed-agg))
                    )
                    (map
                        (lambda
                            (idx:integer)
                            (with-capability (IGNIS|C>ROYALTY patron (at idx agg-creators) (at idx agg-royalties))
                                (XI_IgnisTransfer patron (at idx agg-creators) (at idx agg-royalties))
                            )
                        )
                        (enumerate 0 (- (length agg-creators) 1))
                    )
                    (UDCx_AggregatedRoyalties agg-creators agg-royalties)
                )
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)
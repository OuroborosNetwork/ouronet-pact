;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 1 of 4
;; This is STEP 1 of 4 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-0 must have run first, including the init steps between deploys.
;; 3 source file(s), 199,700 gas measured in the REPL gas model, 217,116 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/06_DPDC-MNG.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact
;;
;; TOTAL: 1 interface(s), 3 module(s), 6 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact
;;      module     DPDC-C
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/06_DPDC-MNG.pact
;;      module     DPDC-MNG
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact
;;      interface  EquityV5
;;      module     EQUITY
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/03_DPDC-C.pact ==========
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; DpdcCreateV3: already deployed and unchanged -- see LIVE_INTERFACES

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
    (implements DpdcCreateV3)

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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (enforce (= executor (ref-DPDC::UR_Verum5 id son))
                "Executor is not the Collectable Create-Role account")
        )
    )
    (defcap DPDC-C|C>REGISTER-NONCES
        (executor:string id:string son:bool amounts:[integer] input-nonce-datas:[object{DpdcUdcV2.DPDC|NonceData}] sft-set-mode:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPDC:module{DpdcV3} DPDC)
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
            ;;THE EQUITY NONCE SET IS SEALED AT ISSUANCE. 2026-11-07.
            ;;
            ;;An `E|` collection is a tokenised company: nonce 1 is the barebone share and nonces
            ;;2-8 are the seven PERCENTAGE tiers (0.1 promille .. 1%). The tier table `EQUITY.S`
            ;;has exactly seven entries, so a ninth nonce has no tier, no share-equivalent, and is
            ;;invisible to `UR_TierSupplies` and therefore to the 50% packaging cap -- while still
            ;;being a transferable unit inside a share register that a buyer cannot tell from a
            ;;real tier.
            ;;
            ;;MEASURED, NOT ASSUMED. `TS02-C1::DPSF|C_IssueCompany`'s @doc has always claimed
            ;;"Only 8 Elements can exist in this Collection, and no more can be added". Nothing
            ;;enforced it. `REPL/_probe_equity_nonce_lock.repl` drove the real call and got
            ;;`nonces-used` 8 -> 9 with a success string. The claim was prose.
            ;;
            ;;WHY `nonces-used = 0` IS THE DISCRIMINATOR rather than a role or a flag. EQUITY
            ;;populates all eight in ONE call, from `C_IssueShareholderCollection`, while the
            ;;collection still reports zero nonces used. So this admits the issuing transaction
            ;;and refuses every later one -- for EVERY caller, the DPDC smart account included.
            ;;A role can be moved and a flag can be argued about; a closed door cannot.
            (if (UC_IzEquityCollectionId id)
                (enforce
                    (= (ref-DPDC::UR_NoncesUsed id son) 0)
                    (format
                        "{} is an EQUITY collection: its eight elements are sealed at issuance and no further nonce can be created"
                        [id]))
                true
            )
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun UC_IzEquityCollectionId:bool (id:string)
        @doc "True when <id> names an EQUITY (shareholder) collection. \
            \ \
            \ A DELIBERATE SECOND HOME FOR THE `E|` RULE, and the duplication is forced rather \
            \ than careless. The canonical predicate is `EQUITY::URC_IzEquitySemiFungible`, and \
            \ its @doc rightly says a rule copied four times is a rule that will be changed in \
            \ three. But EQUITY is `11_EQUITY+.pact` and this is `03_DPDC-C.pact`: EQUITY deploys \
            \ LAST in the DPDC family precisely because it calls into this module, so a modref \
            \ the other way is a dependency cycle, not a style choice. \
            \ \
            \ The alternative was to host it in `02_DPDC` and publish it through `DpdcV3` -- a \
            \ bump that rebinds TWENTY-FOUR modules to centralise a two-token string compare. \
            \ This file already hand-writes the same test for pricing (URCi_RegisterCollectables \
            \ Price's Elite discount), so the copy count does not change by adding this. \
            \ \
            \ IF THE PREFIX EVER MOVES, the sites are: here, EQUITY's own two, and DPDC-T's \
            \ royalty branch."
        (= (take 2 id) "E|")
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
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun URCi_CreateNewNonces:object{IgnisCollectorV4.OutputCumulator}
        (id:string son:bool amounts:[integer])
        @doc "Cost preview for C_CreateNewNonce/C_CreateNewNonces: issue construct \
            \ priced via URCi_RegisterCollectablesPrice on the owner-konto payer, \
            \ empty output list (created collectable names are exec-only write products)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun XI_RegisterCollectables:object{IgnisCollectorV4.OutputCumulator}
        (
            executor:string
            id:string son:bool nonce-classes:[integer] amounts:[integer]
            input-nonce-datas:[object{DpdcUdcV2.DPDC|NonceData}] sft-set-mode:bool
        )
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun C_CreateNewNonce:object{IgnisCollectorV4.OutputCumulator}
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
    (defun C_CreateNewNonces:object{IgnisCollectorV4.OutputCumulator}
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

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/06_DPDC-MNG.pact ========
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; DpdcManagementV3: already deployed and unchanged -- see LIVE_INTERFACES

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
    (implements DpdcManagementV3)

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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-DPDC::CAP_Owner id son)
            (ref-DPDC::UEV_CanUpgradeON id son)
        )
    )
    (defcap DPDC-MNG|S>TG_PAUSE (id:string son:bool toggle:bool)
        @event
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPDC:module{DpdcV3} DPDC)
                (nonce-class:integer (ref-DPDC::UR_NonceClass id true nonce))
            )
            (enforce
                (and
                    (> amount 0)
                    (= nonce-class 0)
                )
                "Invalid Data for Adding Quantity for an SFT Nonce"
            )
            ;;EQUITY SHARES HAVE EXACTLY TWO DOORS, AND THIS IS NOT ONE OF THEM. 2026-11-07.
            ;;
            ;;Nonce 1 of an `E|` collection is the company's share count. It may only change
            ;;through `EQUITY::C_IssueShares` and `EQUITY::C_RetireShares`, because a share
            ;;movement is not a mint -- it has to settle the ESCROW at the same time, pro-rata,
            ;;or the packages outlive their collateral (see EQUITY's `escrow = m x K` note).
            ;;A raw add or burn here would move one side of that equation and not the other.
            ;;
            ;;NONCE 1 ONLY. Tiers 2-8 keep using this path: Make, Break and Convert mint and burn
            ;;package units through <dpdc>, and those operations maintain the invariant by
            ;;construction.
            ;;
            ;;UNCONDITIONAL -- NO ACCOUNT IS EXEMPT, <dpdc> INCLUDED.
            ;;
            ;;The first cut admitted <dpdc>, because EQUITY reached this entrypoint to do its own
            ;;minting and burning. That left the rule true of everyone except the one signature
            ;;that could act as <dpdc> directly, which is a strange shape for an invariant.
            ;;
            ;;`XI_IssueShares` / `XI_RetireShares` now perform the two underlying writes
            ;;themselves -- `XB_CreditSFT-Nonce` / `XE_DebitSFT-Nonce` plus `XE_U|NonceSupply`,
            ;;exactly what this module's own XI_ helpers do -- so nothing needs to come through
            ;;here and the refusal can be total. That was worth the rewiring: it removes an
            ;;exemption rather than documenting one, and it needs no `DpdcManagementV3` bump,
            ;;which would have cascaded into three interfaces that name it.
            (enforce
                (not (and (UC_IzEquityCollectionId id) (= nonce 1)))
                (format "{} is an EQUITY collection: its share count changes only through EQUITY::C_IssueShares / C_RetireShares"
                    [id])
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
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            ;;EQUITY SHARES HAVE EXACTLY TWO DOORS, AND THIS IS NOT ONE OF THEM. 2026-11-07.
            ;;
            ;;Nonce 1 of an `E|` collection is the company's share count. It may only change
            ;;through `EQUITY::C_IssueShares` and `EQUITY::C_RetireShares`, because a share
            ;;movement is not a mint -- it has to settle the ESCROW at the same time, pro-rata,
            ;;or the packages outlive their collateral (see EQUITY's `escrow = m x K` note).
            ;;A raw add or burn here would move one side of that equation and not the other.
            ;;
            ;;NONCE 1 ONLY. Tiers 2-8 keep using this path: Make, Break and Convert mint and burn
            ;;package units through <dpdc>, and those operations maintain the invariant by
            ;;construction.
            ;;
            ;;UNCONDITIONAL -- NO ACCOUNT IS EXEMPT, <dpdc> INCLUDED.
            ;;
            ;;The first cut admitted <dpdc>, because EQUITY reached this entrypoint to do its own
            ;;minting and burning. That left the rule true of everyone except the one signature
            ;;that could act as <dpdc> directly, which is a strange shape for an invariant.
            ;;
            ;;`XI_IssueShares` / `XI_RetireShares` now perform the two underlying writes
            ;;themselves -- `XB_CreditSFT-Nonce` / `XE_DebitSFT-Nonce` plus `XE_U|NonceSupply`,
            ;;exactly what this module's own XI_ helpers do -- so nothing needs to come through
            ;;here and the refusal can be total. That was worth the rewiring: it removes an
            ;;exemption rather than documenting one, and it needs no `DpdcManagementV3` bump,
            ;;which would have cascaded into three interfaces that name it.
            (enforce
                (not (and (UC_IzEquityCollectionId id) (= nonce 1)))
                (format "{} is an EQUITY collection: its share count changes only through EQUITY::C_IssueShares / C_RetireShares"
                    [id])
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
                (ref-DPDC:module{DpdcV3} DPDC)
                (amounts:[integer] (ref-DPDC::UR_AccountNoncesSupplies account id true nonces))
            )
            (compose-capability (DPDC-MNG|C>WIPE-SFT account id nonces amounts))
        )
    )
    (defcap DPDC-MNG|C>WIPE-SFT (account:string id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
            ;; type this early — confirmed live: referencing module{DpdcFragmentsV3} here throws "Cannot
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
    (defun UDC_RemovableNonces:object{DpdcManagementV3.RemovableNonces}
        (a:[integer] b:[integer])
        {"r-nonces"     : a
        ,"r-amounts"    : b}
    )
    (defun UDC_WipeSlicePlan:object{DpdcManagementV3.DPDC-MNG|WipeSlicePlan}
        (a:string b:string c:bool d:integer e:[object{DpdcManagementV3.RemovableNonces}])
        {"account"      : a
        ,"id"           : b
        ,"son"          : c
        ,"slice-count"  : d
        ,"slices"       : e}
    )
    ;;{5.2}  Compute [UC]
    (defun UCv_TakePureWipe:object{DpdcManagementV3.RemovableNonces} (input:object{DpdcManagementV3.RemovableNonces} size:integer)
        @doc "Takes <size> and returns a smaller |object{DpdcManagementV3.RemovableNonces}|"
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
    (defun UC_IzEquityCollectionId:bool (id:string)
        @doc "True when <id> names an EQUITY (shareholder) collection. \
            \ \
            \ A FORCED SECOND HOME for the `E|` rule, the same way `DPDC-C` carries one. The \
            \ canonical predicate is `EQUITY::URC_IzEquitySemiFungible`, but EQUITY is \
            \ `11_EQUITY+.pact` and calls INTO this module, so it necessarily deploys after it \
            \ and a modref back would be a cycle. Hosting it in `02_DPDC` instead means \
            \ publishing it through `DpdcV3` -- twenty-four modules rebound for a two-token \
            \ string compare. \
            \ \
            \ THE SITES, so this is findable: here, `DPDC-C::UC_IzEquityCollectionId`, EQUITY's \
            \ own `URC_IzEquitySemiFungible` and `UEV_EquitySemiFungibleID`, DPDC-C's pricing \
            \ branch and DPDC-T's royalty branch."
        (= (take 2 id) "E|")
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
    (defun UC_BuildWipeSlicePlan:object{DpdcManagementV3.DPDC-MNG|WipeSlicePlan}
        (account:string id:string son:bool removable-nonces-obj:object{DpdcManagementV3.RemovableNonces} slice-count:integer)
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
    (defun URCi_WipeCumulator:object{IgnisCollectorV4.OutputCumulator}
        (id:string son:bool removable-nonces-obj:object{DpdcManagementV3.RemovableNonces})
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun URHC_WipePure:object{DpdcManagementV3.RemovableNonces} (account:string id:string son:bool)
        @doc "Uses Expensive Read Functions to obtain a |object{DpdcManagementV3.RemovableNonces}| that can be used \
        \ to execute a <C_WipePure>, bypassing the expensive gas costs of using (keys...) or (select...) functions"
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (URC_FilterAccountViableNonces account id son (ref-DPDC::URH_AccountNonces account id son))
        )
    )
    (defun URHC_BuildWipeSlicePlan:object{DpdcManagementV3.DPDC-MNG|WipeSlicePlan}
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun URC_FilterAccountViableNonces:object{DpdcManagementV3.RemovableNonces}
        (account:string id:string son:bool nonces:[integer])
        ;;Empty input short-circuit: (enumerate 0 -1) DESCENDS ([0 -1]), so the fold below
        ;;would (at 0) an empty list. A finished Hydra campaign re-reads to an empty object.
        (if (= (length nonces) 0)
        (UDC_RemovableNonces [] [])
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun URCi_Control:object{IgnisCollectorV4.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_Control (Big if son else Biggest, on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun URCi_TogglePause:object{IgnisCollectorV4.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_TogglePause (Medium on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (if son (ref-IGNIS::UC_IgnisPrice "DPSF|C_TogglePause" "setup")
                       (ref-IGNIS::UC_IgnisPrice "DPNF|C_TogglePause" "setup"))
                (ref-DPDC::UR_OwnerKonto id son) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_AddQuantity:object{IgnisCollectorV4.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_AddQuantity (Small on SFT owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;minting-type op: NO special issuance price (owner 2026-09-06) — generic tier
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_AddQuantity" "setup")
                (ref-DPDC::UR_OwnerKonto id true) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_RespawnNFT:object{IgnisCollectorV4.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_RespawnNFT (Medium on NFT owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;minting-type op: NO special issuance price (owner 2026-09-06) — generic tier
                (ref-IGNIS::UC_IgnisPrice "DPNF|C_Respawn" "setup")
                (ref-DPDC::UR_OwnerKonto id false) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_BurnSFT:object{IgnisCollectorV4.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_BurnSFT (Small on SFT owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;NOTE: core reader name != Talos op name — billed as DPSF|C_Burn
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_Burn" "setup")
                (ref-DPDC::UR_OwnerKonto id true) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_WipeSlim:object{IgnisCollectorV4.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_WipeSlim (Smallest on SFT owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;NOTE: core reader name != Talos op name — billed as DPSF|C_WipeNoncePartialy
                (ref-IGNIS::UC_IgnisPrice "DPSF|C_WipeNoncePartialy" "setup")
                (ref-DPDC::UR_OwnerKonto id true) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_BurnNFT:object{IgnisCollectorV4.OutputCumulator}
        (id:string)
        @doc "Cost preview for C_BurnNFT (Medium on NFT owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                ;;NOTE: core reader name != Talos op name — billed as DPNF|C_Burn
                (ref-IGNIS::UC_IgnisPrice "DPNF|C_Burn" "setup")
                (ref-DPDC::UR_OwnerKonto id false) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_WipeNonce:object{IgnisCollectorV4.OutputCumulator}
        (id:string son:bool)
        @doc "Cost preview for C_WipeNonce (Small if son else Big, on owner-konto)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
                (ref-DPDC-C:module{DpdcCreateV3} DPDC-C)
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
                (ref-DPDC:module{DpdcV3} DPDC)
                (ref-DPDC-C:module{DpdcCreateV3} DPDC-C)
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
                (ref-DPDC-C:module{DpdcCreateV3} DPDC-C)
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
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-DPDC::UEV_ExecutorIsOwnerKonto executor id son)
        )
    )
    (defun C_Control:object{IgnisCollectorV4.OutputCumulator}
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
    (defun C_TogglePause:object{IgnisCollectorV4.OutputCumulator}
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
    (defun C_AddQuantity:object{IgnisCollectorV4.OutputCumulator}
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
    (defun C_RespawnNFT:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string nonce:integer)
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
                (ref-DPDC-C:module{DpdcCreateV3} DPDC-C)
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
    (defun C_BurnSFT:object{IgnisCollectorV4.OutputCumulator}
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
    (defun C_WipeSlim:object{IgnisCollectorV4.OutputCumulator}
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
    (defun C_BurnNFT:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string nonce:integer)
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
    (defun C_WipeNonce:object{IgnisCollectorV4.OutputCumulator}
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun CC_WipeHeavy:object{IgnisCollectorV4.OutputCumulator}
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
    (defun C_WipePure:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string executee:string id:string son:bool removable-nonces-obj:object{DpdcManagementV3.RemovableNonces})
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
    (defun C_WipeClean:object{IgnisCollectorV4.OutputCumulator}
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
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (C_WipePure patron executor executee id son
                (UDC_RemovableNonces
                    nonces
                    (ref-DPDC::UR_AccountNoncesSupplies executee id son nonces)
                )
            )
        )
    )
    (defun C_WipeDirty:object{IgnisCollectorV4.OutputCumulator}
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
    (defun Cp_WipeSlice:object{IgnisCollectorV4.OutputCumulator}
        (account:string id:string son:bool removable-nonces-obj:object{DpdcManagementV3.RemovableNonces})
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

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact =========
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface EquityV5
    @doc "EquityV5 is the interface contract for the EQUITY shareholder/equity-collection \
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
    ;; THE ONE PLACE THE "E|" RULE LIVES, from 2026-10-07. The prefix test was written out by hand
    ;; in three separate modules (DPDC-C and DPDC-T for pricing, and this module's own
    ;; UEV_EquitySemiFungibleID), and AQP-SCORE was about to be a fourth. A rule copied four times
    ;; is a rule that will be changed in three places.
    (defun URC_IzEquitySemiFungible:bool (id:string))
    (defun URC_MakeSharePackage:integer (id:string shares-amount:integer package-share-tier:integer))
    (defun URC_SharesPerMillion:[integer] (id:string))
    (defun URC_SingleSharePerMillions:integer (id:string package-share-tier:integer))
    (defun URC_CombineCapacity:integer (id:string))
    ;;THE BACKING INVARIANT, V5: escrow == m x K. See the module body for the full account.
    (defun UC_ShareSplit:[integer] (millions:integer k:integer))
    (defun URC_ShareMillions:integer (id:string))
    (defun URC_PackageConstant:integer (id:string))
    (defun URC_RequiredEscrow:integer (id:string))
    (defun URC_EscrowHeld:integer (id:string))
    (defun URCi_MorphPackageShares:object{IgnisCollectorV4.OutputCumulator} (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer))
    (defun URCi_IssueShareholderCollection:object{IgnisCollectorV4.OutputCumulator} ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_SharePackageTier (package-share-tier:integer))
    (defun UEV_ExecutorIzCompanyCreator (executor:string id:string))
    (defun UEV_ShareMillions (millions:integer))
    (defun UEV_EscrowBacked (id:string))
    (defun UEV_RetireFloor (id:string millions:integer))
    (defun UEV_RetireHolding (id:string account:string millions:integer))
    (defun UEV_CreatorRotation (id:string old-creator:string new-creator:string))
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
    (defun C_IssueShareholderCollection:object{IgnisCollectorV4.OutputCumulator}
        (
            patron:string executor:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
    )
    (defun C_MorphPackageShares:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string input-nonce:integer input-amount:integer output-nonce:integer))
    ;;COMPANY GOVERNANCE, added at V5 (2026-11-07). An equity collection's owner-account is the
    ;;DPDC smart account, so every owner-gated DPDC operation names a contract rather than the
    ;;human who founded the company. These five prove the CREATOR and then act as <dpdc>.
    (defun C_IssueShares:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string millions:integer))
    (defun C_RetireShares:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string millions:integer))
    (defun C_TogglePauseShares:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string toggle:bool))
    (defun C_SetCompanyBranding:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}]))
    (defun C_UpgradeCompanyBranding (patron:string executor:string id:string months:integer))
    (defun C_RotateCompanyCreator:string (patron:string executor:string id:string new-creator:string))

)
(module EQUITY GOV
    @doc "EQUITY implements OuronetPolicyV2 and EquityV5 to create and manage Shareholder \
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
    (implements EquityV5)

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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|EQUITY_ADMIN)
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
        (with-capability (GOV|EQUITY_ADMIN)
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
        (with-capability (GOV|EQUITY_ADMIN)
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
    ;;ONE MILLION. The share unit: issuance and retirement move whole millions and nothing else.
    ;;It is not a style choice -- `URC_SharesPerMillion` divides the share count by this with
    ;;INTEGER division, so a supply that is not a whole number of millions truncates and every
    ;;tier value collapses with it. The divisibility rule is what keeps that division exact.
    (defconst SHARE_UNIT 1000000)
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
    (defcap EQUITY|C>ISSUE-SHARES (id:string executor:string millions:integer)
        @doc "Authorises creating <millions> million new shares. \
            \ \
            \ THE CREATOR, NOT THE OWNER. An equity collection's owner-account is the DPDC smart \
            \ account -- that is how the collection is automanaged and how its nonce set stays \
            \ sealed -- so owner-gated management names an account no company director can sign \
            \ for. The creator is the only party to the company that is not a contract."
        @event
        ;;1]AUTHORISATION, before every validation below (owner ruling 2026-09-14).
        (CAP_EquityCreator executor id)
        (UEV_EquitySemiFungibleID id)
        (UEV_ShareMillions millions)
        (UEV_EscrowBacked id)
        (compose-capability (P|GOV-CALLER))
    )
    (defcap EQUITY|C>RETIRE-SHARES (id:string executor:string millions:integer)
        @doc "Authorises retiring <millions> million shares -- a permissioned burn, split \
            \ pro-rata between the retirer's own holding and the escrow."
        @event
        ;;1]AUTHORISATION, before every validation below (owner ruling 2026-09-14).
        (CAP_EquityCreator executor id)
        (UEV_EquitySemiFungibleID id)
        (UEV_ShareMillions millions)
        (UEV_EscrowBacked id)
        (UEV_RetireFloor id millions)
        (UEV_RetireHolding id executor millions)
        (compose-capability (P|GOV-CALLER))
    )
    (defcap EQUITY|C>COMPANY-ACT (executor:string id:string)
        @doc "Authorises a COMPANY-bucket act on an equity collection -- one the creator must be \
            \ able to perform and the DPDC smart account must be the one to execute. \
            \ \
            \ WHY A WRAPPER AND NOT A RE-GATE. These operations are owner-gated inside DPDC, and \
            \ for an equity collection the owner is <dpdc>. Rather than teach six DPDC modules \
            \ about `E|` -- which would mean publishing the predicate through DpdcV3 and \
            \ rebinding twenty-four modules -- EQUITY proves the CREATOR here and then ACTS AS \
            \ <dpdc>, which it may do because `P|EQUITY|REMOTE-GOV` is registered as a DPDC \
            \ governor guard (see P|A_Define). \
            \ \
            \ The consequence is the valuable part: every DPDC management operation NOT wrapped \
            \ here stays sealed BY CONSTRUCTION. Wipes, forced repurposes, set definitions and \
            \ fragmentation remain unreachable to a company director, because confiscating or \
            \ redefining shareholders' shares is not a directorial power."
        @event
        ;;1]AUTHORISATION, before every validation below (owner ruling 2026-09-14).
        (CAP_EquityCreator executor id)
        (UEV_EquitySemiFungibleID id)
        (compose-capability (P|GOV-CALLER))
    )
    (defcap EQUITY|C>ROTATE-CREATOR (id:string executor:string new-creator:string)
        @doc "Authorises handing a company to a new creator. \
            \ \
            \ BOTH PARTIES SIGN, and that is the whole difficulty of this operation. The \
            \ outgoing creator must authorise the handover and the INCOMING one must accept it \
            \ -- because `creator-account` is NOT consent-checked at issuance (DPDC Audit #53L, \
            \ 04_DPDC-I.pact:263-269), so an unchecked rotation would let anyone saddle any \
            \ account with a company it never agreed to run. Now that the creator actually \
            \ CONTROLS something, that stops being harmless. \
            \ \
            \ Two signatures in one transaction needs a client that can collect them before \
            \ sending. Owner, 2026-11-07: *'we do creator rotation at the pact level now, we'll \
            \ settle the UI problematic later.'* The chain requires both; however the wallet \
            \ learns to gather them, this does not change."
        @event
        ;;1]AUTHORISATION, before every validation below (owner ruling 2026-09-14). The OUTGOING
        ;;creator, bound and owned.
        (CAP_EquityCreator executor id)
        ;;2]...and the INCOMING creator, who must own the account being handed the company.
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership new-creator)
        )
        (UEV_EquitySemiFungibleID id)
        (UEV_CreatorRotation id executor new-creator)
        (compose-capability (P|GOV-CALLER))
    )
    ;;{C4}  Ownership [gold]
    (defun CAP_EquityCreator (executor:string id:string)
        @doc "Proves the company's creator: BOTH that <executor> IS the creator and that the \
            \ caller owns that account. Either half alone is a hole -- see \
            \ UEV_ExecutorIzCompanyCreator. \
            \ \
            \ A defun, not a defcap, for the reason AQP-VCT's CAP_VctVacatePoolOwner records: a \
            \ defcap bare-called does NOT run its body, which silently no-ops the gate on the \
            \ whole surface that calls it that way."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (UEV_ExecutorIzCompanyCreator executor id)
            (ref-DPDC::CAP_Creator id true)
        )
    )

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
                (ref-DPDC:module{DpdcV3} DPDC)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
    ;; ─────────────────────────────────────────────────────────────────────────────────────────
    ;; THE BACKING INVARIANT:  escrow  ==  m x K
    ;;
    ;; Making a package does NOT burn shares -- `XI_MakePackageShares` TRANSFERS them to <dpdc>
    ;; and mints the tier units against them. So nonce 1's total supply is the company's share
    ;; count at all times, and <dpdc>'s nonce-1 balance is the collateral behind every
    ;; outstanding package.
    ;;
    ;;   m = total shares / SHARE_UNIT          (the scale)
    ;;   K = SUM over tiers (units x S_tier)    (the PERCENTAGE -- invariant under supply change)
    ;;
    ;; A tier unit is worth `m x S_tier` shares (URC_SharesPerMillion), so all outstanding
    ;; packages redeem for `m x K`. That is exactly what <dpdc> must hold.
    ;;
    ;; WHY K IS THE RIGHT ABSTRACTION. It is constant under issuance and retirement, which is the
    ;; formal content of "a package is a percentage of the company". Two consequences follow:
    ;;
    ;;   - the 50% packaging cap becomes `K <= SHARE_UNIT / 2`, with no reference to m at all,
    ;;     so issuing or retiring shares can never breach it;
    ;;   - escrow is always a multiple of m, so the pro-rata split below is always whole shares.
    ;;     No rounding, no dust, no truncation.
    ;;
    ;; MAKE, BREAK AND CONVERT ALREADY MAINTAIN IT. Make moves `shares-amount` into escrow and
    ;; raises K by `shares-amount / m`, so d(escrow) = m x dK exactly; Break is its mirror; and
    ;; Convert leaves K alone because `UEV_Convert` enforces `mod(total-input-shares,
    ;; output-share-value) = 0`, making the tier division exact. Issue and Retire were the only
    ;; two operations missing -- which is why the model was incomplete rather than wrong.
    ;; ─────────────────────────────────────────────────────────────────────────────────────────
    (defun UC_ShareSplit:[integer] (millions:integer k:integer)
        @doc "How <millions> million shares divide when issued or retired: [to-escrow, to-holder]. \
            \ Per million, K goes to or from the escrow and (SHARE_UNIT - K) to or from the \
            \ holder -- which is what keeps `escrow = m x K` true across the change. Both legs \
            \ are whole shares because K is an integer."
        [(* millions k) (* millions (- SHARE_UNIT k))]
    )
    (defun URC_ShareMillions:integer (id:string)
        @doc "m -- the company's share count in whole millions."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (/ (ref-DPDC::UR_NonceSupply id true 1) SHARE_UNIT)
        )
    )
    (defun URC_PackageConstant:integer (id:string)
        @doc "K -- SUM over tiers of (outstanding units x S_tier). The packaged PERCENTAGE of the \
            \ company, in share-equivalents per million. Invariant under issuance and retirement."
        (fold (+) 0 (zip (*) (UR_TierSupplies id) S))
    )
    (defun URC_RequiredEscrow:integer (id:string)
        @doc "m x K -- what <dpdc> must hold of nonce 1 to back every outstanding package."
        (* (URC_ShareMillions id) (URC_PackageConstant id))
    )
    (defun URC_EscrowHeld:integer (id:string)
        @doc "What <dpdc> actually holds of nonce 1."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-DPDC::UR_AccountNonceSupply (ref-DPDC::GOV|DPDC|SC_NAME) id true 1)
        )
    )
    (defun URC_IzEquitySemiFungible:bool (id:string)
        @doc "True when <id> names an EQUITY (shareholder) SFT collection. \
            \ \
            \ PREDICATE, NOT AN ENFORCE -- which is why it is not UEV_EquitySemiFungibleID. A caller \
            \ that must DISPATCH on the answer (AQP-SCORE weights an equity collection by live share \
            \ value and everything else by its own tables) needs a boolean; an enforce can only \
            \ abort, and wrapping one in `try` to recover the boolean would make an ordinary branch \
            \ look like an error path. \
            \ \
            \ Identity is the NAME PREFIX, which is the same test the three existing sites use; \
            \ there is no flag on the collection row to consult."
        (= (take 2 id) "E|")
    )
    (defun URC_CombineCapacity:integer (id:string)
        @doc "Remaining share-equivalent headroom that may still be packaged into tier-units (nonces \
            \ 2-8) before hitting the 1/PACKAGING_CAP_DIVISOR (50%) packaging cap on total shares \
            \ (nonce 1). DPDC Audit #29M."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun URCi_IssueShareholderCollection:object{IgnisCollectorV4.OutputCumulator} ()
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
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
                (ref-DPDC-I:module{DpdcIssueV3} DPDC-I)
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
    (defun URCi_MorphPackageShares:object{IgnisCollectorV4.OutputCumulator}
        (account:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        @doc "Cost preview for C_MorphPackageShares, mirroring its three branches: Make \
            \ (input-nonce=1: transfer-in + add-quantity + transfer-out), Break (output-nonce=1: \
            \ transfer-in + burn + transfer-out) and Convert (transfer-in + burn + add-quantity + \
            \ transfer-out). Output matches exec ([[in-nonce out-nonce][in-amt out-amt]]). Purely derived."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC:module{DpdcV3} DPDC)
                (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
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
    (defun UEV_ExecutorIzCompanyCreator (executor:string id:string)
        @doc "Binds the DECLARED executor to the collection's creator. \
            \ \
            \ WITHOUT THIS, `CAP_EquityCreator` PROVES A KEY AND NOT AN ACTOR. It enforces \
            \ ownership of the DERIVED creator account and names nobody, so any caller could \
            \ pass any <executor> and the gate would pass as long as the creator's key happened \
            \ to be in the signing environment -- which it is, routinely, because the creator is \
            \ usually also the patron. \
            \ \
            \ MEASURED, NOT REASONED: `EQUITY-MANAGEMENT.repl` <<EQM-2>> had a stranger issue \
            \ shares successfully against the first cut of this code. The two halves are the \
            \ patron/executor canon's point -- the account a function NAMES is the account it \
            \ must prove."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (enforce
                (= executor (ref-DPDC::UR_CreatorKonto id true))
                (format "Executor is not the Creator of Company {}" [id])
            )
        )
    )
    (defun UEV_CreatorRotation (id:string old-creator:string new-creator:string)
        @doc "Guards a change of company creator. \
            \ \
            \ `can-change-creator` FINALLY GATES SOMETHING. It is stored at issuance and, until \
            \ this round, was read by NOTHING anywhere in the tree -- as were `can-change-owner` \
            \ and `can-transfer-nft-create-role`, while DPTF, DPOF, ATS and SWP all consult \
            \ theirs. Every equity collection carried `can-change-creator = true` and it meant \
            \ nothing. \
            \ \
            \ The new creator must be a STANDARD account: a smart account cannot sign, and the \
            \ point of routing company governance to the creator is that it is the one party to \
            \ the collection that is not a contract."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (enforce
                (ref-DPDC::UR_CanChangeCreator id true)
                (format "Company {} was issued with creator rotation disabled" [id])
            )
            (enforce
                (!= old-creator new-creator)
                (format "{} is already the creator of Company {}" [new-creator id])
            )
            (ref-DALOS::UEV_EnforceAccountType new-creator false)
        )
    )
    (defun UEV_ShareMillions (millions:integer)
        @doc "Issuance and retirement move WHOLE MILLIONS. Not a rounding convenience: \
            \ `URC_SharesPerMillion` divides the share count by SHARE_UNIT with integer \
            \ division, so any other amount truncates and every tier value collapses."
        (enforce (> millions 0) "Share millions must be a positive whole number of millions")
    )
    (defun UEV_EscrowBacked (id:string)
        @doc "The backing invariant, enforced as a PRECONDITION: <dpdc>'s nonce-1 balance must \
            \ equal m x K before shares move. \
            \ \
            \ Checked rather than assumed because a silent drift here is unrecoverable -- the \
            \ packages would outlive their collateral and a Break would fail for whoever broke \
            \ last, which is the worst possible party to discover it."
        (let
            (
                (held:integer (URC_EscrowHeld id))
                (needed:integer (URC_RequiredEscrow id))
            )
            (enforce
                (= held needed)
                (format "Equity escrow is not backed for {}: dpdc holds {} shares, outstanding packages require {}"
                    [id held needed])
            )
        )
    )
    (defun UEV_RetireFloor (id:string millions:integer)
        @doc "A company cannot be retired out of existence: the founding million is the floor."
        (let
            (
                (m:integer (URC_ShareMillions id))
            )
            (enforce
                (>= (- m millions) 1)
                (format "Retiring {} million would leave {} million shares; {} must keep at least 1 million"
                    [millions (- m millions) id])
            )
        )
    )
    (defun UEV_RetireHolding (id:string account:string millions:integer)
        @doc "To retire shares you must HOLD the holder's leg of them. \
            \ \
            \ Not the whole amount: the escrow's leg comes out of <dpdc>, because package holders \
            \ own a PERCENTAGE and a percentage does not change when the company shrinks. At a \
            \ packaged fraction of 30%, retiring 1 million costs the retirer 700,000 of their own \
            \ shares and 300,000 of the collateral."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
                (needed:integer (at 1 (UC_ShareSplit millions (URC_PackageConstant id))))
                (held:integer (ref-DPDC::UR_AccountNonceSupply account id true 1))
            )
            (enforce
                (>= held needed)
                (format "Retiring {} million requires holding {} shares; {} holds {}"
                    [millions needed account held])
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
    (defun XI_ConvertPackageShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string input-package-share-tier:integer input-package-share-tier-amount:integer output-package-share-tier:integer)
        @doc "Converts any Nonce to [2 3 4 5 6 7 8] to any Nonce [2 3 4 5 6 7 8]"
        (require-capability (SECURE))
        (with-capability (EQUITY|C>CONVERT id input-package-share-tier input-package-share-tier-amount output-package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (input-nonce:integer (+ 1 input-package-share-tier))
                    (output-nonce:integer (+ 1 output-package-share-tier))
                    (output-amount:integer (UC_Convert id input-package-share-tier input-package-share-tier-amount output-package-share-tier))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        ;;1]Transfer <input-package-share-tier> with <input-package-share-tier-amount> to <dpdc>
                        (ref-DPDC-T::C_Transfer patron executor dpdc [id] [true] [[input-nonce]] [[input-package-share-tier-amount]] true)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        ;;2]Burn it These three XI_
                        ;;helpers have NO <patron> -- I assumed one and the module stopped
                        ;;loading with "Cannot find module: ouronet-ns.patron", the second time
                        ;;that assumption has cost a load in this sweep. They do have <executor>,
                        ;;the user whose shares are being converted, which is the executor that
                        ;;actually initiates. It becomes this module's own <patron> at its turn.
                        (ref-DPDC-MNG::C_BurnSFT patron dpdc id input-nonce input-package-share-tier-amount)
                    )
                    (ico3:object{IgnisCollectorV4.OutputCumulator}
                        ;;3]Add Quantity <output-quantity> for the <output-nonce> on <dpdc> Account
                        (ref-DPDC-MNG::C_AddQuantity patron dpdc id output-nonce output-amount)
                    )
                    (ico4:object{IgnisCollectorV4.OutputCumulator}
                        ;;4]Transfer it to <executor>
                        (ref-DPDC-T::C_Transfer patron dpdc executor [id] [true] [[output-nonce]] [[output-amount]] true)
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
    (defun XI_MakePackageShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string shares-amount:integer package-share-tier:integer)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (output-nonce:integer (+ 1 package-share-tier))
                    (output-amount:integer (URC_MakeSharePackage id shares-amount package-share-tier))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        ;;1]Transfer Shares to <dpdc>
                        (ref-DPDC-T::C_Transfer patron executor dpdc [id] [true] [[1]] [[shares-amount]] true)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        ;;2]Add Quantity for the Package-Share on <dpdc> Account
                        (ref-DPDC-MNG::C_AddQuantity patron dpdc id output-nonce output-amount)
                    )
                    (ico3:object{IgnisCollectorV4.OutputCumulator}
                        ;;3]Transfer it to <executor>
                        (ref-DPDC-T::C_Transfer patron dpdc executor [id] [true] [[output-nonce]] [[output-amount]] true)
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
    (defun XI_BreakPackageShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string package-share-tier:integer amount:integer)
        @doc "Brakes Nonce 2,3,4,5,6,7,8 to Nonce 1. \
            \ DPDC Audit #49L: see XI_MakePackageShares's @doc -- intentionally bespoke vs. DPDC-S, \
            \ cross-link any DPDC-S Make/Break invariant change here for manual review."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>BREAK id package-share-tier)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (sspm:integer (URC_SingleSharePerMillions id package-share-tier))
                    (nonce-to-break:integer (+ package-share-tier 1))
                    (output-shares:integer (* sspm amount))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        ;;1]Transfer Package-Share-Tier nonce to dpdc
                        (ref-DPDC-T::C_Transfer patron executor dpdc [id] [true] [[nonce-to-break]] [[amount]] true)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        ;;2]Burn it
                        (ref-DPDC-MNG::C_BurnSFT patron dpdc id nonce-to-break amount)
                    )
                    (ico3:object{IgnisCollectorV4.OutputCumulator}
                        ;;3]Release Shares to <executor>
                        (ref-DPDC-T::C_Transfer patron dpdc executor [id] [true] [[1]] [[output-shares]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [ico1 ico2 ico3] 
                    [[nonce-to-break 1][amount output-shares]]
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IssueShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string millions:integer)
        @doc "Creates <millions> million shares, split so the backing invariant survives. \
            \ \
            \ MINT ALL TO <dpdc>, THEN RELEASE THE HOLDER'S LEG. The whole amount is added on the \
            \ DPDC account because <dpdc> is the only holder of role-nft-add-quantity on an \
            \ equity collection; what stays behind IS the escrow's share, so the invariant is \
            \ maintained by what is NOT transferred rather than by a second write. \
            \ \
            \ The holder's leg is always positive -- K <= SHARE_UNIT/2 by the packaging cap -- so \
            \ there is no empty-transfer branch to get wrong."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>ISSUE-SHARES id executor millions)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV3} DPDC-C)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (split:[integer] (UC_ShareSplit millions (URC_PackageConstant id)))
                    (to-holder:integer (at 1 split))
                    (total:integer (* millions SHARE_UNIT))
                    ;;
                    ;;1]MINT THE WHOLE ISSUANCE ON <dpdc>, by writing the two rows directly
                    ;;rather than through `DPDC-MNG::C_AddQuantity`.
                    ;;
                    ;;THIS IS WHAT MAKES THE TWO DOORS THE ONLY DOORS. The first cut called
                    ;;`C_AddQuantity` here, which meant the guard in DPDC-MNG had to ADMIT a
                    ;;caller acting as <dpdc> -- so the entrypoint stayed open to the project
                    ;;signature, and "shares can only move through these two functions" was true
                    ;;of everyone except the one account that could ignore it.
                    ;;
                    ;;Writing the rows here lets that guard refuse nonce 1 UNCONDITIONALLY. These
                    ;;are the same two writes `XI_IncreaseClassZeroSemiFungible` performs, in the
                    ;;same order, and EQUITY may call both because it holds an IMP guard on DPDC
                    ;;and DPDC-C (see P|A_Define). The price is taken from DPDC-MNG's own reader,
                    ;;so the IGNIS charge is identical to the path it replaces.
                    (supply-before:integer (ref-DPDC::UR_NonceSupply id true 1))
                    ;;UNTYPED, DELIBERATELY: these two bindings exist for their WRITE, not their value, and
                    ;;the credit/debit helpers do not agree on a return type. Annotating them is
                    ;;how the first cut failed -- "argument is list, but expected type string".
                    (credited (ref-DPDC-C::XB_CreditSFT-Nonce dpdc id 1 total))
                    (resupplied (ref-DPDC::XE_U|NonceSupply id 1 (+ total supply-before)))
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::URCi_AddQuantity id)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        ;;2]Release the holder's leg; the escrow's leg stays where it was minted
                        (ref-DPDC-T::C_Transfer patron dpdc executor [id] [true] [[1]] [[to-holder]] true)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] [[1][total]])
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RetireShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string millions:integer)
        @doc "Retires <millions> million shares -- a permissioned burn against the retirer's own \
            \ holding plus the escrow's proportional leg. \
            \ \
            \ COLLECT THEN BURN ONCE. The holder's leg is moved to <dpdc> first and the whole \
            \ amount burned there, because <dpdc> is the only holder of role-nft-burn. What \
            \ remains on <dpdc> afterwards is exactly the new m x K."
        (require-capability (SECURE))
        (with-capability (EQUITY|C>RETIRE-SHARES id executor millions)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-C:module{DpdcCreateV3} DPDC-C)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
                    ;;
                    (split:[integer] (UC_ShareSplit millions (URC_PackageConstant id)))
                    (from-holder:integer (at 1 split))
                    (total:integer (* millions SHARE_UNIT))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        ;;1]Collect the retirer's leg into <dpdc>
                        (ref-DPDC-T::C_Transfer patron executor dpdc [id] [true] [[1]] [[from-holder]] true)
                    )
                    ;;2]BURN BOTH LEGS, written directly for the same reason the mint is -- see
                    ;;XI_IssueShares. Same two writes as `XI_DecreaseClassZeroSemiFungibles`,
                    ;;`wipe-mode` FALSE because this is a burn against <dpdc>'s own balance and
                    ;;not a confiscation.
                    (supply-before:integer (ref-DPDC::UR_NonceSupply id true 1))
                    ;;UNTYPED for the same reason as XI_IssueShares' pair.
                    (debited (ref-DPDC-C::XE_DebitSFT-Nonce dpdc id 1 total false))
                    (resupplied (ref-DPDC::XE_U|NonceSupply id 1 (- supply-before total)))
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::URCi_BurnSFT id)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] [[1][total]])
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RotateCompanyCreator:string
        (id:string old-creator:string new-creator:string)
        @doc "Hands a company to a new creator: the authority itself, then every role that rides \
            \ with it. \
            \ \
            \ MOVING `creator-konto` ALONE WOULD BE A HALF-HANDOVER. It transfers what the \
            \ creator CONTROLS -- share issuance and retirement, pause, branding, and the AQP \
            \ pool governor, all of which derive from `UR_CreatorKonto`. It would NOT transfer \
            \ what the creator HOLDS: the per-account role flags authorising nonce metadata, \
            \ royalties and URIs. The outgoing founder would keep the power to rewrite the \
            \ company's tokens after selling it. \
            \ \
            \ So both layers move, and they are genuinely two: the role GATES read the \
            \ per-account row (`UR_CA|R-*`), while `UR_Verum5/6/10` read the single-holder \
            \ positions of the Verum chain. Updating one and not the other leaves a collection \
            \ that disagrees with itself about who may act. \
            \ \
            \ `role-nft-add-quantity` and `role-nft-burn` are NOT moved -- they belong to <dpdc> \
            \ and are the mechanism by which share supply has exactly two doors."
        (require-capability (SECURE))
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
                (props:object{DpdcUdcV2.DPDC|Properties} (ref-DPDC::UR_Properties id true))
            )
            ;;1]THE AUTHORITY. `+` on objects is left-biased, so this is the row with one field
            ;;replaced -- there is no creator-konto updater in DPDC and never has been.
            (ref-DPDC::XE_U|Specs id true (+ {"creator-konto": new-creator} props))
            ;;2]The incoming creator needs a collection account row to carry roles on. Idempotent.
            (ref-DPDC::XE_DeployAccountWNE new-creator id true)
            ;;3]SINGLE-HOLDER Verum positions: create (5), recreate (6), set-new-uri (10). Setting
            ;;the holder displaces the old one, so there is nothing to clear.
            (map
                (lambda (rp:integer) (ref-DPDC::XE_U|VerumRoles id true rp true new-creator))
                [5 6 10]
            )
            ;;4]LIST Verum positions: exemption (2), update (7), modify-creator (8),
            ;;modify-royalties (9). Remove the old holder, add the new.
            (map
                (lambda (rp:integer)
                    (ref-DPDC::XE_U|VerumRoles id true rp false old-creator)
                    (ref-DPDC::XE_U|VerumRoles id true rp true new-creator)
                )
                [2 7 8 9]
            )
            ;;5]THE PER-ACCOUNT ROLE ROW -- what every role gate actually reads.
            (ref-DPDC::XE_U|Create          id true old-creator false)
            (ref-DPDC::XE_U|Create          id true new-creator true)
            (ref-DPDC::XE_U|Recreate        id true old-creator false)
            (ref-DPDC::XE_U|Recreate        id true new-creator true)
            (ref-DPDC::XE_U|Update          id true old-creator false)
            (ref-DPDC::XE_U|Update          id true new-creator true)
            (ref-DPDC::XE_U|ModifyCreator   id true old-creator false)
            (ref-DPDC::XE_U|ModifyCreator   id true new-creator true)
            (ref-DPDC::XE_U|ModifyRoyalties id true old-creator false)
            (ref-DPDC::XE_U|ModifyRoyalties id true new-creator true)
            (ref-DPDC::XE_U|SetNewUri       id true old-creator false)
            (ref-DPDC::XE_U|SetNewUri       id true new-creator true)
            (ref-DPDC::XE_U|Exemption       id true old-creator false)
            (ref-DPDC::XE_U|Exemption       id true new-creator true)
            (format "Company {} handed over to a new creator" [id])
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_RotateCompanyCreator:string
        (patron:string executor:string id:string new-creator:string)
        @doc "Hands company <id> from its current creator to <new-creator>. \
            \ \
            \ BOTH ACCOUNTS MUST SIGN -- the outgoing creator to authorise and the incoming one \
            \ to accept. See EQUITY|C>ROTATE-CREATOR for why acceptance is not optional. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (EQUITY|C>ROTATE-CREATOR id executor new-creator)
            (with-capability (SECURE)
                (XI_RotateCompanyCreator id executor new-creator)
            )
        )
    )
    (defun C_IssueShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string millions:integer)
        @doc "Creates <millions> million new company shares. One of exactly TWO doors through \
            \ which an equity collection's share count may ever change; the other is \
            \ C_RetireShares. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_IssueShares patron executor id millions)
        )
    )
    (defun C_RetireShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string millions:integer)
        @doc "Retires <millions> million company shares. The retirer must hold the holder's leg \
            \ of the amount; the escrow's leg is burned from <dpdc> alongside it, so every \
            \ package holder's PERCENTAGE is unchanged by the operation. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_RetireShares patron executor id millions)
        )
    )
    (defun C_TogglePauseShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string toggle:bool)
        @doc "Halts or resumes all movement of a company's shares -- a trading halt. \
            \ \
            \ Pausing stops TRANSFERS and, with them, Make, Break and Convert: all three move \
            \ shares or tier units through <dpdc> with DPDC-T::C_Transfer, so a halt that left \
            \ packaging running would not be a halt. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (EQUITY|C>COMPANY-ACT executor id)
            (let
                (
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                )
                (ref-DPDC-MNG::C_TogglePause patron (ref-DPDC::GOV|DPDC|SC_NAME) id true toggle)
            )
        )
    )
    (defun C_SetCompanyBranding:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string logo:string description:string website:string
         social:[object{BrandingV3.SocialSchema}])
        @doc "Sets the company's public identity -- logo, description, website, socials. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (EQUITY|C>COMPANY-ACT executor id)
            (let
                (
                    (ref-DPDC:module{DpdcV3} DPDC)
                )
                (ref-DPDC::C_UpdatePendingBranding
                    patron (ref-DPDC::GOV|DPDC|SC_NAME) id true logo description website social)
            )
        )
    )
    (defun C_UpgradeCompanyBranding
        (patron:string executor:string id:string months:integer)
        @doc "Extends the company's branding subscription by <months>. \
            \ \
            \ Executor: ENFORCED IN PLACE by CAP_EquityCreator, which both BINDS <executor> to \
            \ the collection's creator and proves ownership of it. (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (with-capability (EQUITY|C>COMPANY-ACT executor id)
            (let
                (
                    (ref-DPDC:module{DpdcV3} DPDC)
                )
                (ref-DPDC::C_UpgradeBranding
                    patron (ref-DPDC::GOV|DPDC|SC_NAME) id true months)
            )
        )
    )
    (defun C_IssueShareholderCollection:object{IgnisCollectorV4.OutputCumulator}
        (
            patron:string executor:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
        @doc "Issues an eight-element Equity SFT collection -- a tokenised company. Royalty is \
            \ the standard royalty for the whole collection, <ignis-royalty> the IGNIS royalty \
            \ for 1% of company shares. \
            \ \
            \ Executor: ENFORCED DIRECTLY, and THE ENFORCE IS NEW (2026-09-22). It changes \
            \ WHEN and WITH WHAT MESSAGE the wrong caller is refused, NOT WHETHER -- and that \
            \ distinction is measured, not assumed. See EQUITY.repl <<EQ-G2>>. \
            \ \
            \ WHAT WAS ALREADY TRUE. This module contains no ownership check of any kind -- not \
            \ one CAP_EnforceAccountOwnership, not one CAP_Owner -- and DPDC-I|C>ISSUE runs its \
            \ on the collection OWNER, which for an equity collection is <dpdc>, the DPDC smart \
            \ account, because the collection is automanaged. So that check proves a MODULE. But \
            \ the named creator was reached anyway, three modules later: the ico3 leg calls \
            \ DPDC-C::C_CreateNewNonces, whose authority is CAP_EnforceAccountOwnership on the \
            \ DERIVED (UR_Verum5 id son) -- the create-role account -- and on a freshly issued \
            \ collection that resolves to the creator. Disabling this enforce and re-running \
            \ <<EQ-G2>> still produced a keys-all keyset failure naming EMMA's own key. \
            \ \
            \ WHY IT IS STILL WORTH HAVING. That proof is incidental and late. It is incidental \
            \ because it holds only while the create-role account IS the named creator -- an \
            \ invariant of issuance, not of this function -- and late because it fires after the \
            \ collection has been issued and its branding written. The new enforce makes the \
            \ refusal direct, first, and by name, which is what the canon asks for: the account \
            \ this function NAMES is the account it proves. It also runs ahead of the \
            \ ipfs-links shape check, per the 2026-09-14 ruling that authorisation precedes \
            \ validation; <<EQ-G1>> signs as the account it names, so that fixture still \
            \ exercises the shape guard rather than being shadowed by this one. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        ;;1]AUTHORISATION, before every validation below (owner ruling 2026-09-14). See the @doc:
        ;;this is the only account-ownership check on the entire equity-issuance path.
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
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
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-DPDC:module{DpdcV3} DPDC)
                (ref-DPDC-C:module{DpdcCreateV3} DPDC-C)
                (ref-DPDC-I:module{DpdcIssueV3} DPDC-I)
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
                (ico:object{IgnisCollectorV4.OutputCumulator}
                    ;;1]Issue Equity SFT Collection; <dpdc> automatically gets <role-nft-add-quantity> and <role-nft-burn>
                    (ref-DPDC-I::C_IssueDigitalCollection
                        ;;FLAGS, in signature order (04_DPDC-I.pact:448-466):
                        ;;  can-upgrade                  FALSE -- the spec is sealed; C_Control is dead
                        ;;  can-change-owner             FALSE -- the DPDC smart account owns it forever
                        ;;  can-change-creator           TRUE  -- a company outlives its founder
                        ;;  can-add-special-role         TRUE
                        ;;  can-transfer-nft-create-role FALSE (2026-11-07) -- was TRUE. The nonce set
                        ;;    is sealed at issuance (DPDC-C|C>REGISTER-NONCES), so a movable create
                        ;;    role could only ever be a way to argue with that seal.
                        ;;  can-freeze                   TRUE
                        ;;  can-wipe                     TRUE
                        ;;  can-pause                    TRUE  (2026-11-07) -- was FALSE, which made
                        ;;    C_TogglePause dead for EVERYONE and a trading halt impossible. Now
                        ;;    routed to the creator through C_TogglePauseShares.
                        ;;  iz-special                   TRUE
                        patron dpdc executor true
                        name ticker
                        false false true true
                        false true true true
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
                    ;;PROVISIONAL PATRON/EXECUTOR SLOTS (HANDOFF 4e, 2026-09-22). 03_DPDC-C's
                    ;;turn gave C_CreateNewNonces a <patron> and an <executor> bound to
                    ;;(UR_Verum5 id son). This module's own turn has not come, so <patron> stands
                    ;;in and the executor is READ -- the same expression the binder evaluates, on
                    ;;a collection this function has just issued, so it is exact rather than a
                    ;;placeholder. Both become real parameters at 11_EQUITY+'s turn.
                    (ref-DPDC-C::C_CreateNewNonces
                        patron (ref-DPDC::UR_Verum5 equity-id true)
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
    (defun C_MorphPackageShares:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        @doc "Combines, breaks or converts <executor>'s equity share tiers. \
            \ \
            \ Executor: PROVEN FORWARDED. Nothing here or in the three XI_ helpers proves an \
            \ account; each helper moves the shares through the <dpdc> custodial account with \
            \ DPDC-T::C_Transfer, whose capability opens on \
            \ (CAP_EnforceAccountOwnership sender) unconditionally, and <executor> occupies \
            \ that slot on the outbound leg of every branch. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_Morph input-nonce output-nonce)
        (with-capability (SECURE)
            (if (= input-nonce 1)
                ;;Make Package Shares
                (XI_MakePackageShares patron executor id input-amount (- output-nonce 1))
                (if (= output-nonce 1)
                    ;;Brake Package Shares
                    (XI_BreakPackageShares patron executor id (- input-nonce 1) input-amount)
                    ;;Convert Package Shares
                    (XI_ConvertPackageShares patron executor id (- input-nonce 1) input-amount (- output-nonce 1))
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


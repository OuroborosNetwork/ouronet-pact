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

(create-table P|T)
(create-table P|MT)
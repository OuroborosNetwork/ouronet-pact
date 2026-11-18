;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 2 of 2
;; This is STEP 2 of 2 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-1 must have run first, including the init steps between deploys.
;; 4 source file(s), 235,433 gas measured in the REPL gas model, 215,228 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact
;;   1_SOVEREIGN/STAGE_02/3_Talos/02_TS02-C2.pact
;;   2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact
;;   2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact
;;
;; TOTAL: 1 interface(s), 4 module(s), 10 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact
;;      interface  TalosStageTwo_ClientOneV5
;;      module     TS02-C1
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/3_Talos/02_TS02-C2.pact
;;      module     TS02-C2
;;      table      P|T
;;      table      P|MT
;;   -- 2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact
;;      module     DEMIPAD-SNAKES
;;      table      P|T
;;      table      P|MT
;;      table      SNAKES|T|Properties
;;   -- 2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact
;;      module     DEMIPAD-CUSTODIANS
;;      table      P|T
;;      table      P|MT
;;      table      CUSTODIANS|T|Properties
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact ================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageTwo_ClientOneV5
    @doc "Exposes Stage Two First Batch of Client Functions: \
        \ the SemiFungible Client Functions"

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
    ;;  [2] DPDC
    ;;
    (defun DPDC|C_MultiTransfer (patron:string executor:string executee:string ids:[string] sons:[bool] nonces-array:[[integer]] amounts-array:[[integer]] method:bool))
    (defun DPSF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}]))
    (defun DPSF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer))
    ;;
    ;;  [3] DPDC-C
    ;;
    (defun DPSF|C_Create:string
        (
            patron:string executor:string id:string amount:[integer]
            input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}]
        )
    )
    ;;
    ;;  [4] DPDC-I
    ;;
    ;; DPSF|C_DeployAccount removed — DPDC Audit #35M: standalone deployment let any signer force any
    ;; existing account to associate with any collection, with no ownership check. Real auto-association
    ;; (on transfer, role-toggle, Issue, set-fragmentation) always calls DPDC::XBv_DeployAccountSFT
    ;; directly, module-to-module, bypassing this public entrypoint entirely.
    (defun DPSF|C_Issue:string 
        (
            patron:string 
            executor:string executee:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
        )
    )
    ;;
    ;;  [5] DPDC-R
    ;;
    (defun DPSF|C_ToggleAddQuantityRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPSF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPSF|C_ToggleExemptionRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPSF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPSF|C_ToggleUpdateRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPSF|C_ToggleModifyCreatorRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPSF|C_ToggleModifyRoyaltiesRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPSF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool))
    (defun DPSF|C_MoveCreateRole (patron:string executor:string executee:string id:string))
    (defun DPSF|C_MoveRecreateRole (patron:string executor:string executee:string id:string))
    (defun DPSF|C_MoveSetUriRole (patron:string executor:string executee:string id:string))
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun DPSF|C_Control (patron:string executor:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool))
    (defun DPSF|C_TogglePause (patron:string executor:string id:string toggle:bool))
        ;;
    (defun DPSF|C_AddQuantity (patron:string executor:string id:string nonce:integer amount:integer))
    (defun DPSF|C_Burn (patron:string executor:string id:string nonce:integer amount:integer))
    (defun DPSF|C_WipeNoncePartialy (patron:string executor:string executee:string id:string nonce:integer amount:integer))
    (defun DPSF|C_WipeNonce (patron:string executor:string executee:string id:string nonce:integer))
        ;;
    (defun DPSF|CC_WipeHeavy (patron:string executor:string executee:string id:string))
    (defun DPSF|C_WipePure (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpdcManagementV3.RemovableNonces}))
    (defun DPSF|C_WipeClean (patron:string executor:string executee:string id:string nonces:[integer]))
    (defun DPSF|C_WipeDirty (patron:string executor:string executee:string id:string nonces:[integer]))
    (defun DPSF|Cp_WipeSlice (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV3.RemovableNonces}))
    ;;
    ;;  [7] DPDC-T
    ;;
    (defun DPSF|C_Repurpose (patron:string executor:string executee:string id:string repurpose-to:string nonces:[integer] amounts:[integer]))
    (defun DPSF|C_TransferNonce (patron:string executor:string executee:string id:string nonce:integer amount:integer method:bool))
    (defun DPSF|C_TransferNonces (patron:string executor:string executee:string id:string nonces:[integer] amounts:[integer] method:bool))
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun DPSF|C_Make (patron:string executor:string id:string nonces:[integer] set-class:integer how-many-sets:integer))
    (defun DPSF|CC_Break (patron:string executor:string id:string nonce:integer how-many-sets:integer))
    (defun DPSF|C_DefinePrimordialSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPSF|C_DefineCompositeSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPSF|C_DefineHybridSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPSF|C_EnableSetClassFragmentation
        (
            patron:string executor:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPSF|C_ToggleSet (patron:string executor:string id:string set-class:integer toggle:bool))
    (defun DPSF|C_RenameSet (patron:string executor:string id:string set-class:integer new-name:string))
    ;; DPSF|C_UpdateSetMultiplier removed — DPDC Audit #15H: score-multiplier is immutable after Define.
    ;;
    (defun DPSF|C_UpdateSetNonce                        (patron:string executor:string id:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}))
    (defun DPSF|C_UpdateSetNonces                       (patron:string executor:string id:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]))
    (defun DPSF|C_UpdateSetNonceRoyalty                 (patron:string executor:string id:string set-class:integer nos:bool royalty-value:decimal))
    (defun DPSF|C_UpdateSetNonceIgnisRoyalty            (patron:string executor:string id:string set-class:integer nos:bool royalty-value:decimal))
    (defun DPSF|C_UpdateSetNonceName                    (patron:string executor:string id:string set-class:integer nos:bool name:string))
    (defun DPSF|C_UpdateSetNonceDescription             (patron:string executor:string id:string set-class:integer nos:bool description:string))
    (defun DPSF|C_UpdateSetNonceScore                   (patron:string executor:string id:string set-class:integer nos:bool score:decimal))
    (defun DPSF|C_RemoveSetNonceScore                   (patron:string executor:string id:string set-class:integer nos:bool))
    (defun DPSF|C_UpdateSetNonceMetaData                (patron:string executor:string id:string set-class:integer nos:bool meta-data:object))
    (defun DPSF|C_UpdateSetNonceURI                     (patron:string executor:string id:string set-class:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}))
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun DPSF|C_RepurposeFragments (patron:string executor:string executee:string id:string repurpose-to:string nonces:[integer] amounts:[integer]))
    (defun DPSF|C_MakeFragments (patron:string executor:string id:string nonce:integer amount:integer))
    (defun DPSF|C_MergeFragments (patron:string executor:string id:string nonce:integer amount:integer))
    (defun DPSF|C_EnableNonceFragmentation (patron:string executor:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}))
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun DPSF|C_UpdateNonce                           (patron:string executor:string id:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}))
    (defun DPSF|C_UpdateNonces                          (patron:string executor:string id:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]))
    (defun DPSF|C_UpdateNonceRoyalty                    (patron:string executor:string id:string nonce:integer nos:bool royalty-value:decimal))
    (defun DPSF|C_UpdateNonceIgnisRoyalty               (patron:string executor:string id:string nonce:integer nos:bool royalty-value:decimal))
    (defun DPSF|C_UpdateNonceName                       (patron:string executor:string id:string nonce:integer nos:bool name:string))
    (defun DPSF|C_UpdateNonceDescription                (patron:string executor:string id:string nonce:integer nos:bool description:string))
    (defun DPSF|C_UpdateNonceScore                      (patron:string executor:string id:string nonce:integer nos:bool score:decimal))
    (defun DPSF|C_RemoveNonceScore                      (patron:string executor:string id:string nonce:integer nos:bool))
    (defun DPSF|C_UpdateNonceMetaData                   (patron:string executor:string id:string nonce:integer nos:bool meta-data:object))
    (defun DPSF|C_UpdateNonceURI                        (patron:string executor:string id:string nonce:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}))
    ;;
    ;;
    ;;  [10] EQUITY
    ;;
    (defun DPSF|C_IssueCompany:string
        (
            patron:string executor:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
    )
    (defun DPSF|C_MorphEquity (patron:string executor:string id:string input-nonce:integer input-amount:integer output-nonce:integer))
    (defun DPSF|CC_IssueShares (patron:string executor:string id:string millions:integer))
    (defun DPSF|CC_RetireShares (patron:string executor:string id:string millions:integer))
    (defun DPSF|C_PauseCompany (patron:string executor:string id:string toggle:bool))
    (defun DPSF|C_SetCompanyBranding (patron:string executor:string id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}]))
    (defun DPSF|C_UpgradeCompanyBranding (patron:string executor:string id:string months:integer))
    (defun DPSF|C_RotateCompanyCreator (patron:string executor:string id:string new-creator:string))
    (defun DPDC|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string son:bool nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
    )
    (defun DPSF|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
    )


    ;;<=========================================================================>
    ;; ADDED 2026-10-12 -- interface-membership sweep (StoicSyntax-Prefixes.md Sec5,
    ;; owner ruling). Every one of these was already live in the module body; this
    ;; closes the gap between what the module DOES and what its interface SAYS it does.
    ;;<=========================================================================>
    (defun UC_ShortAccount:string (account:string))
)
;;
(module TS02-C1 GOV
    @doc "TALOS Stage 2 Client Functiones Part 1 - SFT Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_ClientOneV5)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS02-C1                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS02-C1_ADMIN)))
    (defcap GOV|TS02-C1_ADMIN ()                        (enforce-guard GOV|MD_TS02-C1))
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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (gap:bool (ref-DALOS::UR_GAP))
            )
            (enforce (not gap) "While Global Administrative Pause is online, no client Functions can be executed")
            (compose-capability (P|TALOS-SUMMONER))
        )
    )
    (defcap P|TALOS-SUMMONER ()
        @doc "Talos Summoner Capability"
        true
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
        (with-capability (GOV|TS02-C1_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS02-C1_ADMIN)
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
        (with-capability (GOV|TS02-C1_ADMIN)
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
        (with-capability (GOV|TS02-C1_ADMIN)
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
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (ref-P|DPDC-I:module{OuronetPolicyV2} DPDC-I)
                (ref-P|DPDC-R:module{OuronetPolicyV2} DPDC-R)
                (ref-P|DPDC-MNG:module{OuronetPolicyV2} DPDC-MNG)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPDC-F:module{OuronetPolicyV2} DPDC-F)
                (ref-P|DPDC-S:module{OuronetPolicyV2} DPDC-S)
                (ref-P|DPDC-N:module{OuronetPolicyV2} DPDC-N)
                (ref-P|EQUITY:module{OuronetPolicyV2} EQUITY)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|TS01-A::P|A_AddIMP mg)
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
            (ref-P|DPDC-I::P|A_AddIMP mg)
            (ref-P|DPDC-R::P|A_AddIMP mg)
            (ref-P|DPDC-MNG::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|DPDC-F::P|A_AddIMP mg)
            (ref-P|DPDC-S::P|A_AddIMP mg)
            (ref-P|DPDC-N::P|A_AddIMP mg)
            (ref-P|EQUITY::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
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
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_ShortAccount:string (account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UC_ShortAccount account)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [2] DPDC
    ;;
    (defun DPDC|C_MultiTransfer (patron:string executor:string executee:string ids:[string] sons:[bool] nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Transfer multiple collectable <ids> from <executor> to <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (hm:integer (length ids))
                    ;;
                    (irs:object{DpdcTransferV3.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor ids sons nonces-array amounts-array)
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                    (l:integer (length c))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer patron executor executee ids sons nonces-array amounts-array method)
                )
                [
                    (format "Successfully transfered DPDC(s) {} Nonce-Array {} using Amount-Array {} from {} to {}" [ids nonces-array amounts-array sa ra])
                    (if (= s 0.0)
                        (format "Transfer executed without collecting any IGNIS Royalties for the Collectable(s) {}" [ids])
                        (format "Transfer executed while collecting {} IGNIS Royalty to {} Collectable Creator(s)" [s l])
                    )
                ]
            )
        )
    )
    (defun DPSF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}])
        @doc "Updates <pending-branding> for DPSF Token <entity-id> costing 400 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC::C_UpdatePendingBranding patron executor entity-id true logo description website social)
                )
            )
        )
    )
    (defun DPSF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Upgrades Branding for DPSF Token, making it a premium BrandingV2. \
            \ Also sets pending-branding to live branding if its branding is not live yet"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DPDC::C_UpgradeBranding patron executor entity-id true months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    ;;
    ;;  [3] DPDC-C
    ;;
    (defun DPSF|C_Create:string
        (
            patron:string executor:string id:string amount:[integer]
            input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}]
        )
        @doc "Creates a new SFT Collection Element(s), having a new nonce, \
            \ of amount <amount>, on the Account that has <r-nft-create> \
            \ As this account is the only Account that is allowed to create new SFTs in the Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-C:module{DpdcCreateV3} DPDC-C)
                    (l:integer (length input-nonce-data))
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (if (= l 1)
                            (ref-DPDC-C::C_CreateNewNonce
                                patron executor id true 0 (at 0 amount) (at 0 input-nonce-data) false
                            )
                            (ref-DPDC-C::C_CreateNewNonces
                                patron executor id true amount input-nonce-data
                            )
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Created {} Clas 0 SemiFungible(s) within the {} DPSF Collection"
                    [(at "output" ico) id]
                )
            )
        )
    )
    ;;
    ;;  [4] DPDC-I
    ;;
    ;; DPSF|C_DeployAccount removed — DPDC Audit #35M: see interface-side removal note above.
    (defun DPSF|C_Issue:string
        (
            patron:string 
            executor:string executee:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
        )
        @doc "Issues a new DPSF (Demiourgos Pact Semi-Fungible) Digital Collection: <SFT> \
            \ Costs 5x<ignis|token-issue> = 2500 IGNIS and 400 STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-I:module{DpdcIssueV3} DPDC-I)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-I::C_IssueDigitalCollection
                            patron executor executee true
                            collection-name collection-ticker
                            can-upgrade can-change-owner can-change-creator can-add-special-role
                            can-transfer-nft-create-role can-freeze can-wipe can-pause
                            false
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at 0 (at "output" ico))
            )
        )
    )
    ;;
    ;;  [5] DPDC-R
    ;;
    (defun DPSF|C_ToggleAddQuantityRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles the add quantity role for a DPTF Token on a given Ouronet Account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleAddQuantityRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Freezes a given account for a given DPSF Token. Frozen Accounts can no longer send or receive that DPSF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleFreezeAccount patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleExemptionRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles exemption Role for a given DPSF on a given Smart Ouronet Account (Only Smart Ouronet Accounts can accept this role) \
            \ When sending to or receiving from such Accounts, the flat IGNIS Royalty fee must not be paid."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleExemptionRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles burn Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can then burn the DPSF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleBurnRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleUpdateRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles update Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can then update (modify) the Metadata on any DPSF nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleUpdateRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleModifyCreatorRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Modify Creator Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Creator of the DPSF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyCreatorRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleModifyRoyaltiesRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Modify Royalties Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Permille Royalty of any nonce in the  DPSF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyRoyaltiesRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Transfer Role for a given DPSF on any Ouronet Account. \
            \ Transfers for any Nonce in the DPSF Collection are then restricted only to and from these accounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleTransferRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_MoveCreateRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Create Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can issue new SFTs in the Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveCreateRole patron executor executee id true)
                )
            )
        )
    )
    (defun DPSF|C_MoveRecreateRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Recreate Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can recreate any existing SFT in the Collection \
            \ Recreation reffers to a complete update (modification) of all SFT properties of a given nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveRecreateRole patron executor executee id true)
                )
            )
        )
    )
    (defun DPSF|C_MoveSetUriRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Set URI Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can modify the URIs of any nonce in the SFT Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveSetUriRole patron executor executee id true)
                )
            )
        )
    )
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun DPSF|C_Control (patron:string executor:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        @doc "Controls DPSF Properties"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_Control patron executor id true cu cco ccc casr ctncr cf cw cp)
                )
            )
        )
    )
    (defun DPSF|C_TogglePause (patron:string executor:string id:string toggle:bool)
        @doc "Pauses a DPSF Collection. Paused Collections can no longer be transfered"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_TogglePause patron executor id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_AddQuantity (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "Increases the Quantity for SFT <id> <nonce> by <amount> on <executor>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_AddQuantity patron executor id nonce amount)
                )
                (format "Successfully added {} Units for SFT {} Nonce {} on Account {}" [amount id nonce (UC_ShortAccount executor)])
            )
        )
    )
    (defun DPSF|C_Burn (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "Decreases the Quantity for SFT <id> <nonce> by <amount> on <executor>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_BurnSFT patron executor id nonce amount)
                )
                (format "Successfully burned {} Units for SFT {} Nonce {} on Account {}" [amount id nonce (UC_ShortAccount executor)])
            )
        )
    )
    (defun DPSF|C_WipeNoncePartialy (patron:string executor:string executee:string id:string nonce:integer amount:integer)
        @doc "Wipes a partial <amount> of SFT <id> <nonce> from <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_WipeSlim patron executor executee id nonce amount)
                )
                (format "Successfully wiped {} Units for SFT {} Nonce {} from Account {}" [amount id nonce (UC_ShortAccount executee)])
            )
        )
    )
    (defun DPSF|C_WipeNonce (patron:string executor:string executee:string id:string nonce:integer)
        @doc "Wipes the SFT <id> <nonce> from <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_WipeNonce patron executor executee id true nonce)
                )
                (format "Successfully wiped SFT {} Nonce {} from Account {}" [id nonce (UC_ShortAccount executee)])
            )
        )
    )
    (defun DPSF|CC_WipeHeavy (patron:string executor:string executee:string id:string)
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::CC_WipeHeavy patron executor executee id true)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Successfully executed Heavy Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|C_WipePure (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpdcManagementV3.RemovableNonces})
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::C_WipePure patron executor executee id true removable-nonces-obj) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Successfully executed Pure Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|C_WipeClean (patron:string executor:string executee:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeClean patron executor executee id true nonces) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Successfully executed Clean Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|C_WipeDirty (patron:string executor:string executee:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeDirty patron executor executee id true nonces)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format
                    "Successfully executed Dirty Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}"
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|Cp_WipeSlice (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV3.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes ONE <URHC_BuildWipeSlicePlan> slice of the SFT \
            \ <account>'s <id> nonces. The UI dirty-reads the plan and fires one such tx per \
            \ slice, all in parallel; slices are disjoint, order-independent and retryable \
            \ (replay REVERTS on the zeroed account supply)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::Cp_WipeSlice account id true removable-nonces-obj)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format
                    "Successfully executed Hydra Wipe Slice of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}"
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    ;;
    ;;  [7] DPDC-T
    ;;
    (defun DPSF|C_Repurpose (patron:string executor:string executee:string id:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose SFT(s) from <executee> to <repurpose-to>. The <executor> must BE the \
            \ collection owner -- that is the authority the whole op rests on, and DPDC-T now \
            \ binds the name to it rather than deriving it silently."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_RepurposeCollectable patron executor executee id true repurpose-to nonces amounts)
                )
                (format "Successfully repurposed SFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPSF|C_TransferNonce (patron:string executor:string executee:string id:string nonce:integer amount:integer method:bool)
        @doc "Transfer an SFT <nonce> of <amount> from <executor> to <executee> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    ;;
                    (irs:object{DpdcTransferV3.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor [id] [true] [[nonce]] [[amount]])
                    )
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer patron executor executee [id] [true] [[nonce]] [[amount]] method)
                )
                [
                    (format "Successfully transfered SFT {} Nonce {} and Amount {} from {} to {}" [id nonce amount sa ra])
                    (if (= s 0.0)
                        (format "Transfer executed without collecting any IGNIS Royalties for the Collectable {}" [id])
                        (format "Transfer executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                    )
                ]
            )
        )
    )
    (defun DPSF|C_TransferNonces (patron:string executor:string executee:string id:string nonces:[integer] amounts:[integer] method:bool)
        @doc "Transfer SFT <nonces> of <amounts> from <executor> to <executee> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    ;;
                    (irs:object{DpdcTransferV3.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor [id] [true] [nonces] [amounts])
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer patron executor executee [id] [true] [nonces] [amounts] method)
                )
                [
                    (format "Successfully transfered SFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sa ra])
                    (if (= s 0.0)
                        (format "Transfer executed without collecting any IGNIS Royalties for the Collectable {}" [id])
                        (format "Transfer executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                    )
                ]
            )
        )
    )
    (defun DPDC|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string son:bool nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Bulk whole collectable transfer — one executor, many standard-account executees (TalosStageTwo_ClientOneV2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    ;;
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (l:integer (length executee-lst))
                    ;;FIXED 2026-09-12: these two used to map over `(enumerate 0 (- l 1))`.
                    ;;**In Pact `(enumerate 0 -1)` is `[0, -1]` -- a DESCENDING pair, not an empty
                    ;;list.** So an EMPTY receiver list produced TWO ids, `C_IgnisRoyaltyCollector`
                    ;;below indexed past the one-element arrays, and the caller got
                    ;;`Array index out of bounds` instead of DPDC-T|C>BULK-TRANSFER's own shape
                    ;;message -- which is bound in that cap and never got the chance to speak.
                    ;;Mapping over `receiver-lst` ITSELF yields exactly `l` elements and is genuinely
                    ;;empty when the list is, so the hazard is removed rather than worked around.
                    ;;Chosen over reordering the call: the royalty collector must still run BEFORE the
                    ;;transfer, and moving it would change what is charged, not just what is said.
                    (ids:[string]  (map (lambda (rcv:string) id)  executee-lst))
                    (sons:[bool]   (map (lambda (rcv:string) son) executee-lst))
                )
                ;;THE CORE TRANSFER RUNS FIRST, and the ordering is the fix.
                ;;FIXED 2026-09-12: the royalty collector used to be bound in the `let` ABOVE this
                ;;call. It iterates `(enumerate 0 (- (length ids) 1))` and indexes
                ;;`(at idx nonces-array)` -- so for an EMPTY receiver list, or for MORE receivers than
                ;;nonce legs, it ran off the end and raised `Array index out of bounds` before
                ;;DPDC-T|C>BULK-TRANSFER's shape guard could say what was actually wrong. Only the
                ;;opposite mismatch (more legs than receivers) stayed in bounds and reached the
                ;;message, which is what made it a defect rather than a dead guard.
                ;;Calling the core first lets its capability validate the shapes, after which every
                ;;downstream `enumerate` is operating on lists already proven to agree.
                ;;`TS01-C1::DPOF|C_BulkTransfer` has always been in this order and is not mute
                ;;(pinned by DPOF-G12) -- so this follows an in-repo precedent rather than inventing
                ;;an order. Royalties are computed from the collectable's creator settings and the
                ;;amounts, not from balances, so moving the call does not change what is charged.
                (let
                    (
                        (core-ico:object{IgnisCollectorV4.OutputCumulator}
                            (ref-DPDC-T::C_BulkTransfer patron executor executee-lst id son nonces-array amounts-array method)
                        )
                    )
                (let
                    (
                    (irs:object{DpdcTransferV3.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor ids sons nonces-array amounts-array)
                    )
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron core-ico)
                [
                    (format "Successfully bulk-transferred collectable {} from {} to {} receivers" [id sa l])
                    (if (= s 0.0)
                        (format "Bulk transfer executed without collecting any IGNIS Royalties for the Collectable {}" [id])
                        (format "Bulk transfer executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                    )
                ]
            )))
        )
    )
    (defun DPSF|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Bulk SFT transfer — son=true wrapper over DPDC|C_BulkTransfer. \
        \ \
        \ Executor: PROVEN INDIRECTLY, and named. This is a thin alias: it delegates to \
        \ DPDC|C_BulkTransfer in THIS module, and that wrapper's own call chain is what \
        \ proves the account. FORWARDED matches cross-module `ref-X::` calls by design, so an \
        \ intra-Talos delegation has to be traced by a human and written down. \
        \ (patron/executor canon 2.2, 2026-09-22.)"
        (DPDC|C_BulkTransfer patron executor executee-lst id true nonces-array amounts-array method)
    )
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun DPSF|C_Make
        (patron:string executor:string id:string nonces:[integer] set-class:integer how-many-sets:integer)
        @doc "Makes a Set SFT of Class <set-class>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                ;;G-44 FIX (2026-09-17), and the G-14 shape exactly: <nonce> used to be bound HERE,
                ;;eagerly, purely to be printed in the success message below. `UR_NonceOfSet`
                ;;funnels to `UR_Set`'s bare `read`, so a set-class that does not exist aborted on
                ;;the raw table key IN THIS WRAPPER -- before the core was called and therefore
                ;;before `DPDC-S|C>MAKE`'s own guard could speak. Fixing the defcap alone left this
                ;;path unchanged, which is how the fix was caught as incomplete.
                ;;Reading it AFTER the core call is value-identical: "nonce-of-set" is written once,
                ;;when the set-class is DEFINED, and never updated by a make. Inlined rather than
                ;;re-bound because it is used exactly once (CLAUDE.md let-vs-inline rule).
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_MakeSemiFungibleSet patron executor id nonces set-class how-many-sets)
                )
                (format "Successfully generated {} Class {} Sets (Nonce {}) of SFT Collection {} on Account {}"
                    [how-many-sets set-class (ref-DPDC-S::UR_NonceOfSet id set-class) id sa])
            )
        )
    )
    (defun DPSF|CC_Break
        (patron:string executor:string id:string nonce:integer how-many-sets:integer)
        @doc "Brakes an SFT Nonce representing an SFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                    (set-class:integer (ref-DPDC::UR_NonceClass id true nonce))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::CC_BreakSemiFungibleSet patron executor id nonce how-many-sets)
                )
                (format "Successfully broken {} Class {} Sets (Nonce {}) of SFT Collection {} on Account {}" [how-many-sets set-class nonce id sa])
            )
        )
    )
    (defun DPSF|C_DefinePrimordialSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Primordial SFT Set. Primordial Sets are composed of Class 0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-S::C_DefinePrimordialSet patron executor id true set-name score-multiplier set-definition ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Primordial Set <{}> (set-class {}) for SFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPSF|C_DefineCompositeSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Composite SFT Set. Composite Sets are composed of Class (!=0) Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-S::C_DefineCompositeSet patron executor id true set-name score-multiplier set-definition ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Composite Set <{}> (set-class {}) for SFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPSF|C_DefineHybridSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Hybrid SFT Set. Hybrid Sets are composed of both Class 0 and Non-0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-S::C_DefineHybridSet patron executor id true set-name score-multiplier primordial-sd composite-sd ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Hybrid Set <{}> (set-class {}) for SFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPSF|C_EnableSetClassFragmentation
        (
            patron:string executor:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Enables Fragmentation for a given Set Class. This allows all SFTs of the given Set Class to be Fragmented"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_EnableSetClassFragmentation patron executor id true set-class fragmentation-ind)
                )
                (format "Set Class {} for SFT {} succesfully fragmented" [set-class id])
            )
        )
    )
    (defun DPSF|C_ToggleSet (patron:string executor:string id:string set-class:integer toggle:bool)
        @doc "Enables or Disables a Set. A disabled Set allows only for decomposition of Set Elements, but not for composition"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_ToggleSet patron executor id true set-class toggle)
                )
                (format "SFT {} Set Class {} succesfully turned {}" [id set-class (if toggle "ON" "OFF")])
            )
        )
    )
    (defun DPSF|C_RenameSet (patron:string executor:string id:string set-class:integer new-name:string)
        @doc "Renames an SFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_RenameSet patron executor id true set-class new-name)
                )
                (format "SFT {} Set Class {} succesfuly renamed to <{}>" [id set-class new-name])
            )
        )
    )
    ;; DPSF|C_UpdateSetMultiplier removed — DPDC Audit #15H.
    ;;
    (defun DPSF|C_UpdateSetNonce 
        (patron:string executor:string id:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id true [set-class] nos false [new-nonce-data])
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonces
        (patron:string executor:string id:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id true set-classes nos false new-nonces-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceRoyalty
        (patron:string executor:string id:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Set Nonce Native Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty patron executor id true set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceIgnisRoyalty
        (patron:string executor:string id:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Set Nonce IGNIS Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty patron executor id true set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceName
        (patron:string executor:string id:string set-class:integer nos:bool name:string)
        @doc "[3] Updates Set Nonce Name, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName patron executor id true set-class nos false name)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceDescription
        (patron:string executor:string id:string set-class:integer nos:bool description:string)
        @doc "[4] Updates Set Nonce Description, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription patron executor id true set-class nos false description)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceScore
        (patron:string executor:string id:string set-class:integer nos:bool score:decimal)
        @doc "[5] Updates Set Nonce Score, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore patron executor id true set-class nos false score)
                )
            )
        )
    )
    (defun DPSF|C_RemoveSetNonceScore (patron:string executor:string id:string set-class:integer nos:bool)
        @doc "[5b] Removes Set Nonce Score, setting it to -1.0, either Native or Split, for an SFT \
        \ \
        \ Executor: PROVEN INDIRECTLY, and named. This is a thin alias: it delegates to \
        \ DPSF|C_UpdateSetNonceScore in THIS module, and that wrapper's own call chain is what \
        \ proves the account. FORWARDED matches cross-module `ref-X::` calls by design, so an \
        \ intra-Talos delegation has to be traced by a human and written down. \
        \ (patron/executor canon 2.2, 2026-09-22.)"
        (DPSF|C_UpdateSetNonceScore patron executor id set-class nos -1.0)
    )
    (defun DPSF|C_UpdateSetNonceMetaData
        (patron:string executor:string id:string set-class:integer nos:bool meta-data:object)
        @doc "[6] Updates Set Nonce Meta-Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData patron executor id true set-class nos false meta-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceURI
        (
            patron:string executor:string id:string set-class:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Set Nonce URI, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI patron executor id true set-class nos false ay u1 u2 u3)
                )
            )
        )
    )
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun DPSF|C_RepurposeFragments (patron:string executor:string executee:string id:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose SFT Fragment(s) from <executee> to <repurpose-to>. The <executor> must \
            \ BE the collection owner -- that is the authority the whole op rests on, and \
            \ DPDC-F now binds the name to it rather than deriving it silently."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV3} DPDC-F)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_RepurposeCollectableFragments patron executor executee id true repurpose-to nonces amounts)
                )
                (format "Successfully repurposed SFT {} Fragment-Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPSF|C_MakeFragments (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "Fragments SFT nonce of the given amount into its respective Fragments."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV3} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MakeFragments patron executor id true nonce amount)
                )
                (format "Successfully Fragmented {} SFT(s) {} of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPSF|C_MergeFragments (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "MErges SFT Fragments nonces of the given amount into the original SFT nonce."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV3} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MergeFragments patron executor id true nonce amount)
                )
                (format "Successfully merged {} {} SFT(s) Fragments of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPSF|C_EnableNonceFragmentation (patron:string executor:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        @doc "Enables Fragmentation for a given SFT Nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV3} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_EnableNonceFragmentation patron executor id true nonce fragmentation-ind)
                )
                (format "Fragmentation for SFT {} Nonce {} enabled succesfully" [id nonce])
            )
        )
    )
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun DPSF|C_UpdateNonce
        (patron:string executor:string id:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id true [nonce] nos true [new-nonce-data])
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonces
        (patron:string executor:string id:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an SFT, for multiple Nonces at a time"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id true nonces nos true new-nonces-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceRoyalty
        (patron:string executor:string id:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Nonce Native Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty patron executor id true nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceIgnisRoyalty
        (patron:string executor:string id:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Nonce IGNIS Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty patron executor id true nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceName
        (patron:string executor:string id:string nonce:integer nos:bool name:string)
        @doc "[3] Updates Nonce Name, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName patron executor id true nonce nos true name)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceDescription
        (patron:string executor:string id:string nonce:integer nos:bool description:string)
        @doc "[4] Updates Nonce Description, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription patron executor id true nonce nos true description)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceScore
        (patron:string executor:string id:string nonce:integer nos:bool score:decimal)
        @doc "[5] Updates Nonce Score, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore patron executor id true nonce nos true score)
                )
            )
        )
    )
    (defun DPSF|C_RemoveNonceScore (patron:string executor:string id:string nonce:integer nos:bool)
        @doc "[5b] Removes Nonce Score, setting it to -1.0, either Native or Split, for an SFT \
        \ \
        \ Executor: PROVEN INDIRECTLY, and named. This is a thin alias: it delegates to \
        \ DPSF|C_UpdateNonceScore in THIS module, and that wrapper's own call chain is what \
        \ proves the account. FORWARDED matches cross-module `ref-X::` calls by design, so an \
        \ intra-Talos delegation has to be traced by a human and written down. \
        \ (patron/executor canon 2.2, 2026-09-22.)"
        (DPSF|C_UpdateNonceScore patron executor id nonce nos -1.0)
    )
    (defun DPSF|C_UpdateNonceMetaData
        (patron:string executor:string id:string nonce:integer nos:bool meta-data:object)
        @doc "[6] Updates Nonce Meta-Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData patron executor id true nonce nos true meta-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceURI
        (
            patron:string executor:string id:string nonce:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Nonce URI, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI patron executor id true nonce nos true ay u1 u2 u3)
                )
            )
        )
    )
    ;;
    ;;  [11] EQUITY
    ;;
    (defun DPSF|C_IssueCompany:string
        (
            patron:string executor:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
        @doc "Issues an SFT Equity Collection to tokenize Company Shares on Ouronet. \
            \ Royalty is the standard Royalty for the Whole Collection \
            \ While <ignis-royalty> is the ignis Royalty for 1% of Company Shares \
            \ This makes the value of <ignis-royalty> in $ the Price to transfer All Existing Shares as Package Shares \
            \ \
            \ <ipfs-links> must be 8 elements long.\
            \ The Collection is an Image SFT Collection, automanaged by the <dpdc> Smart Ouronet Account as Collection Owner \
            \ Only 8 Elements can exist in this Collection, and no more can be added. \
            \ \
            \ Equity Collections Costs 0.001 IGNIS per Share for Pure Share Transfers as GAS Fees. \
            \ Package Share cost the normal <ignis|small> price per unit as GAS Fees, as for all SFTs.\
            \ \
            \ <ipfs-links> must contain a 24 string list, 8 links for each element in the primary secondarz and tertiary uri list"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-EQUITY:module{EquityV5} EQUITY)
                    ;;
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-EQUITY::C_IssueShareholderCollection 
                            patron executor collection-name collection-ticker
                            royalty ignis-royalty ipfs-links
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;Issuing a COMPANY is $100 in IGNIS deter and $100 in STOA (spec): the equity
                ;;premium leg. The underlying SFT collection issue carries its own cost on top,
                ;;in both currencies — same composition rule as the VST links.
                (ref-IGNIS::XE_CollectStoa patron (ref-IGNIS::UC_StoaPrice "issue-shareholder"))
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at 0 (at "output" ico))
            )
        )
    )
    ;; ─── EQUITY COMPANY GOVERNANCE ───────────────────────────────────────────────────────
    ;; Five wrappers over EQUITY's creator-gated entrypoints. They add no authorisation of
    ;; their own -- EQUITY proves the CREATOR in each capability, then acts as the DPDC smart
    ;; account to perform the DPDC-side write. See `EQUITY|C>COMPANY-ACT`.
    (defun DPSF|CC_IssueShares (patron:string executor:string id:string millions:integer)
        @doc "Creates <millions> million new shares in the company <id>. The company's CREATOR \
            \ is the only account that may call this; <millions> whole millions only. \
            \ \
            \ HEAVY, AND THE GATE IS WHY. `UEV_AQP|NoLiveStakeOfAsset` scans the DPSF tracker by \
            \ asset and refuses issuance while any pool still holds a live stake -- see that \
            \ function for the measured -10,000 it exists to prevent. The scan is unavoidable \
            \ here (StoicSyntax 19.3) and share issuance is a rare creator-only governance act, \
            \ not a daily-hot path. \
            \ \
            \ THE GATE LIVES HERE, ONE LAYER UP, BECAUSE IT CANNOT LIVE IN EQUITY. EQUITY deploys \
            \ at tx 13 and AQP at tx 16, so EQUITY can never ask AQP what is staked -- and EQUITY \
            \ stays pure logic over DPDC state, with no domain tables of its own. This is the same \
            \ placement `SCR|C>UPDATE-MULTIPLIERS` uses for the identical problem one input over: \
            \ its emptiness gate sits in AQP-POOL rather than AQP-SCORE, for the same reason."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EQUITY:module{EquityV5} EQUITY)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-AQP::UEV_AQP|NoLiveStakeOfAsset id)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EQUITY::C_IssueShares patron executor id millions)
                )
                (format "Successfully issued {} million new shares for Company {}" [millions id])
            )
        )
    )
    (defun DPSF|CC_RetireShares (patron:string executor:string id:string millions:integer)
        @doc "Retires <millions> million shares of company <id> -- a permissioned burn. The \
            \ retirer must hold the holder's leg of the amount; the escrow's leg is burned \
            \ alongside it so every package holder's percentage is unchanged. \
            \ \
            \ HEAVY FOR THE SAME REASON AS DPSF|CC_IssueShares, and gated by the same validator. \
            \ RETIREMENT IS NOT THE SAFE DIRECTION. Lowering the share count re-values every \
            \ package DOWNWARD, so an unstake after a retirement subtracts LESS than its stake \
            \ added and the row keeps a positive residue -- a holder credited for weight they no \
            \ longer carry. The sign differs from issuance; the corruption does not."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EQUITY:module{EquityV5} EQUITY)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-AQP::UEV_AQP|NoLiveStakeOfAsset id)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EQUITY::C_RetireShares patron executor id millions)
                )
                (format "Successfully retired {} million shares of Company {}" [millions id])
            )
        )
    )
    (defun DPSF|C_PauseCompany (patron:string executor:string id:string toggle:bool)
        @doc "Halts or resumes all movement of company <id>'s shares -- transfers, and with \
            \ them Make, Break and Convert."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EQUITY:module{EquityV5} EQUITY)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EQUITY::C_TogglePauseShares patron executor id toggle)
                )
                (if toggle
                    (format "Company {} shares are now HALTED" [id])
                    (format "Company {} shares are trading again" [id])
                )
            )
        )
    )
    (defun DPSF|C_SetCompanyBranding
        (patron:string executor:string id:string logo:string description:string website:string
         social:[object{BrandingV3.SocialSchema}])
        @doc "Sets company <id>'s public identity."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EQUITY:module{EquityV5} EQUITY)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EQUITY::C_SetCompanyBranding patron executor id logo description website social)
                )
                (format "Successfully updated the branding of Company {}" [id])
            )
        )
    )
    (defun DPSF|C_UpgradeCompanyBranding (patron:string executor:string id:string months:integer)
        @doc "Extends company <id>'s branding subscription by <months>."
        (with-capability (P|TS)
            (let
                (
                    (ref-EQUITY:module{EquityV5} EQUITY)
                )
                (ref-EQUITY::C_UpgradeCompanyBranding patron executor id months)
                (format "Successfully extended the branding of Company {} by {} months" [id months])
            )
        )
    )
    (defun DPSF|C_RotateCompanyCreator (patron:string executor:string id:string new-creator:string)
        @doc "Hands company <id> to <new-creator>. BOTH the outgoing creator and the incoming one \
            \ must sign the transaction -- the handover is authorised by the first and ACCEPTED \
            \ by the second, because `creator-account` is not consent-checked at issuance and a \
            \ creator now actually controls something."
        (with-capability (P|TS)
            (let
                (
                    (ref-EQUITY:module{EquityV5} EQUITY)
                )
                (ref-EQUITY::C_RotateCompanyCreator patron executor id new-creator)
            )
        )
    )
    (defun DPSF|C_MorphEquity
        (patron:string executor:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        @doc "Converts any Nonce to [1 2 3 4 5 6 7 8] to any Nonce [1 2 3 4 5 6 7 8] \
            \ Input-Nonce must be different from Output-Nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (ref-EQUITY:module{EquityV5} EQUITY)
                    ;;
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-EQUITY::C_MorphPackageShares
                            patron executor id input-nonce input-amount output-nonce
                        )
                    )
                    (output:list (at "output" ico))
                    (ir-nonces:[integer] (at 0 output))
                    (ir-amounts:[integer] (at 1 output))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    ;;
                    (irs:object{DpdcTransferV3.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor [id] [true] [ir-nonces] [ir-amounts])
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (if (= input-nonce 1)
                    [
                        ;;Make Package Shares
                        (format "Successfully combined {} Shares to Tier {} Package Share on Account {}" [input-amount (- output-nonce 1) sa])
                        (if (= s 0.0)
                            (format "Combining Shares executed witout collecting any IGNIS Royalties for the Collectable {}" [id])
                            (format "Combining Shares executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                        )
                    ]
                    (if (= output-nonce 1)
                        [
                            ;;Brake Package Shares
                            (format "Successfully broke {} Tier {} Package Share to {} Shares on Account {}" [input-amount (- input-nonce 1) (at 1 ir-amounts) sa])
                            (if (= s 0.0)
                                (format "Breaking Package Shares executed witout collecting any IGNIS Royalties for the Collectable {}" [id])
                                (format "Breaking Package Shares executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                            )
                        ]
                        [
                            ;;Convert Package Shares
                            (format "Successfully Converter Tier {} to Tier {} Package Shares on Account {}" [(- input-nonce 1) (- output-nonce 1) sa])
                            (if (= s 0.0)
                                (format "Converting Package Shares executed witout collecting any IGNIS Royalties for the Collectable {}" [id])
                                (format "Converting Package Shares executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                            )
                        ]
                        
                        
                    )
                )
            )
        )
    )

)

;; --- tables for 01_TS02-C1.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/3_Talos/02_TS02-C2.pact ================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; TalosStageTwo_ClientTwoV3: already deployed and unchanged -- see LIVE_INTERFACES

;;
(module TS02-C2 GOV
    @doc "TALOS Stage 2 Client Functiones Part 2 - NFT Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_ClientTwoV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS02-C2                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS02-C2_ADMIN)))
    (defcap GOV|TS02-C2_ADMIN ()                        (enforce-guard GOV|MD_TS02-C2))
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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (gap:bool (ref-DALOS::UR_GAP))
            )
            (enforce (not gap) "While Global Administrative Pause is online, no client Functions can be executed")
            (compose-capability (P|TALOS-SUMMONER))
        )
    )
    (defcap P|TALOS-SUMMONER ()
        @doc "Talos Summoner Capability"
        true
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
        (with-capability (GOV|TS02-C2_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS02-C2_ADMIN)
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
        (with-capability (GOV|TS02-C2_ADMIN)
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
        (with-capability (GOV|TS02-C2_ADMIN)
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
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (ref-P|DPDC-I:module{OuronetPolicyV2} DPDC-I)
                (ref-P|DPDC-R:module{OuronetPolicyV2} DPDC-R)
                (ref-P|DPDC-MNG:module{OuronetPolicyV2} DPDC-MNG)
                (ref-P|DPDC-N:module{OuronetPolicyV2} DPDC-N)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPDC-F:module{OuronetPolicyV2} DPDC-F)
                (ref-P|DPDC-S:module{OuronetPolicyV2} DPDC-S)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|TS01-A::P|A_AddIMP mg)
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
            (ref-P|DPDC-I::P|A_AddIMP mg)
            (ref-P|DPDC-R::P|A_AddIMP mg)
            (ref-P|DPDC-MNG::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|DPDC-F::P|A_AddIMP mg)
            (ref-P|DPDC-S::P|A_AddIMP mg)
            (ref-P|DPDC-N::P|A_AddIMP mg)
            ;;IGNIS RESTRUCTURE 2026-09-20: the collectors became protected X_ functions
            ;;behind `P|UEV_IMC`, so every module that bills must be a registered IMP peer
            ;;of IGNIS or the fee call dies with "None of the guards passed".
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
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
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_ShortAccount:string (account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UC_ShortAccount account)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [2] DPDC
    ;;
    (defun DPNF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}])
        @doc "Updates <pending-branding> for DPNF Token <entity-id> costing 500 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC::C_UpdatePendingBranding patron executor entity-id false logo description website social)
                )
            )
        )
    )
    (defun DPNF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Upgrades Branding for DPNF Token, making it a premium BrandingV2. \
            \ Also sets pending-branding to live branding if its branding is not live yet"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DPDC::C_UpgradeBranding patron executor entity-id false months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    ;;
    ;;  [3] DPDC-C
    ;;
    (defun DPNF|C_Create:string
        (
            patron:string executor:string id:string
            input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}]
        )
        @doc "Creates a new NFT Collection Element(s), having a new nonce, \
            \ of amount 1, on the <creator> account."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-C:module{DpdcCreateV3} DPDC-C)
                    (l:integer (length input-nonce-data))
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (if (= l 1)
                            (ref-DPDC-C::C_CreateNewNonce
                                patron executor id false 0 1 (at 0 input-nonce-data) false
                            )
                            (ref-DPDC-C::C_CreateNewNonces
                                patron executor id false (make-list l 1) input-nonce-data
                            )
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Created {} Clas 0 NonFungible(s) within the {} DPNF Collection"
                    [(at "output" ico) id]
                )
            )
        )
    )
    ;;
    ;;  [4] DPDC-I
    ;;
    ;; DPNF|C_DeployAccount removed — DPDC Audit #35M: see interface-side removal note above.
    (defun DPNF|C_Issue:string
        (
            patron:string 
            executor:string executee:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
        )
        @doc "Issues a new DPNF (Demiourgos Pact Non-Fungible) Digital Collection: <NFT> \
            \ Costs 10x<ignis|token-issue> = 5000 IGNIS and 500 STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-I:module{DpdcIssueV3} DPDC-I)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-I::C_IssueDigitalCollection
                            patron executor executee false
                            collection-name collection-ticker
                            can-upgrade can-change-owner can-change-creator can-add-special-role
                            can-transfer-nft-create-role can-freeze can-wipe can-pause
                            false
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at 0 (at "output" ico))
            )
        )
    )
    ;;
    ;;  [5] DPDC-R
    ;;
    (defun DPNF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Freezes a given account for a given DPNF Token. Frozen Accounts can no longer send or receive that DPNF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleFreezeAccount patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleExemptionRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles exemption Role for a given DPNF on a given Smart Ouronet Account (Only Smart Ouronet Accounts can accept this role) \
            \ When sending to or receiving from such Accounts, the flat IGNIS Royalty fee must not be paid."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleExemptionRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles burn Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can then burn the DPNF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleBurnRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleUpdateRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles update Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can then update (modify) the Metadata on any DPNF nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleUpdateRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleModifyCreatorRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Modify Creator Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Creator of the DPNF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyCreatorRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleModifyRoyaltiesRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Modify Royalties Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Permille Royalty of any nonce in the  DPNF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyRoyaltiesRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Transfer Role for a given DPNF on any Ouronet Account. \
            \ Transfers for any Nonce in the DPNF Collection are then restricted only to and from these accounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleTransferRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_MoveCreateRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Create Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can issue new NFTs in the Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveCreateRole patron executor executee id false)
                )
            )
        )
    )
    (defun DPNF|C_MoveRecreateRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Recreate Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can recreate any existing NFT in the Collection \
            \ Recreation reffers to a complete update (modification) of all NFT properties of a given nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveRecreateRole patron executor executee id false)
                )
            )
        )
    )
    (defun DPNF|C_MoveSetUriRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Set URI Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can modify the URIs of any nonce in the NFT Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV3} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveSetUriRole patron executor executee id false)
                )
            )
        )
    )
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun DPNF|C_Control (patron:string executor:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        @doc "Controls DPNF Properties"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_Control patron executor id false cu cco ccc casr ctncr cf cw cp)
                )
            )
        )
    )
    (defun DPNF|C_TogglePause (patron:string executor:string id:string toggle:bool)
        @doc "Pauses a DPNF Collection. Paused Collections can no longer be transfered"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_TogglePause patron executor id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_Respawn (patron:string executor:string id:string nonce:integer)
        @doc "Respawns NFT <id> <nonce> on <executor>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_RespawnNFT patron executor id nonce)
                )
                (format "Succesfuly respawned NFT {} Nonce {} on Account {}" [id nonce (UC_ShortAccount executor)])
            )
        )
    )
    (defun DPNF|C_Burn (patron:string executor:string id:string nonce:integer)
        @doc "Burns NFT <id> <nonce> on <executor>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_BurnNFT patron executor id nonce)
                )
                (format "Succesfuly burned NFT {} Nonce {} on Account {}" [id nonce (UC_ShortAccount executor)])
            )
        )
    )
    (defun DPNF|C_WipeNonce (patron:string executor:string executee:string id:string nonce:integer)
        @doc "Wipes NFT <id> <nonce> on <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_WipeNonce patron executor executee id false nonce)
                )
                (format "Succesfuly wiped NFT {} Nonce {} from Account {}" [id nonce (UC_ShortAccount executee)])
            )
        )
    )
    (defun DPNF|CC_WipeHeavy (patron:string executor:string executee:string id:string)
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::CC_WipeHeavy patron executor executee id false)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Succesfuly executed Heavy Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|C_WipePure (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpdcManagementV3.RemovableNonces})
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::C_WipePure patron executor executee id false removable-nonces-obj) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Succesfuly executed Pure Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|C_WipeClean (patron:string executor:string executee:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeClean patron executor executee id false nonces) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Succesfuly executed Clean Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|C_WipeDirty (patron:string executor:string executee:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeDirty patron executor executee id false nonces)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format
                    "Succesfuly executed Dirty Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}"
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|Cp_WipeSlice (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV3.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes ONE <URHC_BuildWipeSlicePlan> slice of the NFT \
            \ <account>'s <id> nonces. The UI dirty-reads the plan and fires one such tx per \
            \ slice, all in parallel; slices are disjoint, order-independent and retryable \
            \ (replay REVERTS on the zeroed account supply)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV3} DPDC-MNG)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-MNG::Cp_WipeSlice account id false removable-nonces-obj)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format
                    "Succesfuly executed Hydra Wipe Slice of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}"
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    ;;
    ;;  [7] DPDC-T
    ;;
    (defun DPNF|C_Repurpose (patron:string executor:string executee:string id:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose NFT(s) from <executee> to <repurpose-to>. The <executor> must BE the \
            \ collection owner -- that is the authority the whole op rests on, and DPDC-T now \
            \ binds the name to it rather than deriving it silently."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_RepurposeCollectable patron executor executee id false repurpose-to nonces amounts)
                )
                (format "Successfully repurposed NFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPNF|C_TransferNonce (patron:string executor:string executee:string id:string nonce:integer amount:integer method:bool)
        @doc "Transfer an NFT <nonce> of <amount> from <executor> to <executee> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    ;;
                    (irs:object{DpdcTransferV3.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor [id] [false] [[nonce]] [[amount]])
                    )
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer patron executor executee [id] [false] [[nonce]] [[amount]] method)
                )
                [
                    (format "Successfully transfered NFT {} Nonce {} and Amount {} from {} to {}" [id nonce amount sa ra])
                    (if (= s 0.0)
                        (format "Transfer executed without collecting any IGNIS Royalties for the Collectable {}" [id])
                        (format "Transfer executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                    )
                ]
            )
        )
    )
    (defun DPNF|C_TransferNonces (patron:string executor:string executee:string id:string nonces:[integer] amounts:[integer] method:bool)
        @doc "Transfer NFT <nonces> of <amounts> from <executor> to <executee> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    ;;
                    (irs:object{DpdcTransferV3.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor [id] [false] [nonces] [amounts])
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer patron executor executee [id] [false] [nonces] [amounts] method)
                )
                [
                    (format "Successfully transfered NFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sa ra])
                    (if (= s 0.0)
                        (format "Transfer executed without collecting any IGNIS Royalties for the Collectable {}" [id])
                        (format "Transfer executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                    )
                ]
            )
        )
    )
    (defun DPNF|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Bulk NFT transfer — son=false wrapper over TS02-C1.DPDC|C_BulkTransfer."
        (let
            (
                (ref-TS02-C1:module{TalosStageTwo_ClientOneV5} TS02-C1)
            )
            (ref-TS02-C1::DPDC|C_BulkTransfer patron executor executee-lst id false nonces-array amounts-array method)
        )
    )
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun DPNF|C_Make
        (patron:string executor:string id:string nonces:[integer] set-class:integer)
        @doc "Makes a Set NFT of Class <set-class>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (nonce:integer (+ 1 (ref-DPDC::UR_NoncesUsed id false)))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_MakeNonFungibleSet patron executor id nonces set-class)
                )
                (format "Successfully generated Class {} Set (Nonce {}) of NFT Collection {} on Account {}" [set-class nonce id sa])
            )
        )
    )
    (defun DPNF|C_Break
        (patron:string executor:string id:string nonce:integer)
        @doc "Brakes an NFT Nonce representing an NFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                    (set-class:integer (ref-DPDC::UR_NonceClass id false nonce))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_BreakNonFungibleSet patron executor id nonce)
                )
                (format "Successfully broken Class {} Set (Nonce {}) of NFT Collection {} on Account {}" [set-class nonce id sa])
            )
        )
    )
    (defun DPNF|C_DefinePrimordialSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Primordial NFT Set. Primordial Sets are composed of Class 0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-S::C_DefinePrimordialSet patron executor id false set-name score-multiplier set-definition ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Primordial Set <{}> (set-class {}) for NFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPNF|C_DefineCompositeSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Composite NFT Set. Composite Sets are composed of Class (!=0) Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-S::C_DefineCompositeSet patron executor id false set-name score-multiplier set-definition ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Composite Set <{}> (set-class {}) for NFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPNF|C_DefineHybridSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Hybrid NFT Set. Hybrid Sets are composed of both Class 0 and Non-0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPDC-S::C_DefineHybridSet patron executor id false set-name score-multiplier primordial-sd composite-sd ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Hybrid Set <{}> (set-class {}) for NFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPNF|C_EnableSetClassFragmentation
        (
            patron:string executor:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Enables Fragmentation for a given Set Class. This allows all NFTs of the given Set Class to be Fragmented"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_EnableSetClassFragmentation patron executor id false set-class fragmentation-ind)
                )
                (format "Set Class {} for NFT {} succesfully fragmented" [set-class id])
            )
        )
    )
    (defun DPNF|C_ToggleSet (patron:string executor:string id:string set-class:integer toggle:bool)
        @doc "Enables or Disables a Set. A disabled Set allows only for decomposition of Set Elements, but not for composition"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_ToggleSet patron executor id false set-class toggle)
                )
                (format "NFT {} Set Class {} succesfully turned {}" [id set-class (if toggle "ON" "OFF")])
            )
        )
    )
    (defun DPNF|C_RenameSet (patron:string executor:string id:string set-class:integer new-name:string)
        @doc "Renames an NFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV3} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_RenameSet patron executor id false set-class new-name)
                )
                (format "NFT {} Set Class {} succesfuly renamed to <{}>" [id set-class new-name])
            )
        )
    )
    ;; DPNF|C_UpdateSetMultiplier removed — DPDC Audit #15H.
    ;;
    (defun DPNF|C_UpdateSetNonce 
        (patron:string executor:string id:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id false [set-class] nos false [new-nonce-data])
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonces
        (patron:string executor:string id:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id false set-classes nos false new-nonces-data)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceRoyalty
        (patron:string executor:string id:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Set Nonce Native Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty patron executor id false set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceIgnisRoyalty
        (patron:string executor:string id:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Set Nonce IGNIS Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty patron executor id false set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceName
        (patron:string executor:string id:string set-class:integer nos:bool name:string)
        @doc "[3] Updates Set Nonce Name, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName patron executor id false set-class nos false name)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceDescription
        (patron:string executor:string id:string set-class:integer nos:bool description:string)
        @doc "[4] Updates Set Nonce Description, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription patron executor id false set-class nos false description)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceScore
        (patron:string executor:string id:string set-class:integer nos:bool score:decimal)
        @doc "[5] Updates Set Nonce Score, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore patron executor id false set-class nos false score)
                )
            )
        )
    )
    (defun DPNF|C_RemoveSetNonceScore (patron:string executor:string id:string set-class:integer nos:bool)
        @doc "[5b] Removes Set Nonce Score, setting it to -1.0, either Native or Split, for an NFT \
        \ \
        \ Executor: PROVEN INDIRECTLY, and named. This is a thin alias: it delegates to \
        \ DPNF|C_UpdateSetNonceScore in THIS module, and that wrapper's own call chain is what \
        \ proves the account. FORWARDED matches cross-module `ref-X::` calls by design, so an \
        \ intra-Talos delegation has to be traced by a human and written down. \
        \ (patron/executor canon 2.2, 2026-09-22.)"
        (DPNF|C_UpdateSetNonceScore patron executor id set-class nos -1.0)
    )
    (defun DPNF|C_UpdateSetNonceMetaData
        (patron:string executor:string id:string set-class:integer nos:bool meta-data:object)
        @doc "[6] Updates Set Nonce Meta-Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData patron executor id false set-class nos false meta-data)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceURI
        (
            patron:string executor:string id:string set-class:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Set Nonce URI, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI patron executor id false set-class nos false ay u1 u2 u3)
                )
            )
        )
    )
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun DPNF|C_RepurposeFragments (patron:string executor:string executee:string id:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose NFT Fragment(s) from <executee> to <repurpose-to>. The <executor> must \
            \ BE the collection owner -- that is the authority the whole op rests on, and \
            \ DPDC-F now binds the name to it rather than deriving it silently."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV3} DPDC-F)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    ;; #79: this is the NFT (C_DPNF|) wrapper — son MUST be false. Was hardcoded `true`
                    ;; (SFT), so it read CNF from the DPSF table and failed. Never caught: no test coverage.
                    (ref-DPDC-F::C_RepurposeCollectableFragments patron executor executee id false repurpose-to nonces amounts)
                )
                (format "Successfully repurposed NFT {} Fragment-Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPNF|C_MakeFragments (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "Fragments NFT nonce of the given amount into its respective Fragments."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV3} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MakeFragments patron executor id false nonce amount)
                )
                (format "Succesfuly Fragmented {} NFT(s) {} of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPNF|C_MergeFragments (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "MErges NFT Fragments nonces of the given amount into the original NFT nonce."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV3} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MergeFragments patron executor id false nonce amount)
                )
                (format "Succesfuly merged {} {} NFT(s) Fragments of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPNF|C_EnableNonceFragmentation (patron:string executor:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        @doc "Enables Fragmentation for a given NFT Nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV3} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_EnableNonceFragmentation patron executor id false nonce fragmentation-ind)
                )
                (format "Fragmentation for NFT {} Nonce {} enabled succesfully" [id nonce])
            )
        )
    )
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun DPNF|C_UpdateNonce 
        (patron:string executor:string id:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id false [nonce] nos true [new-nonce-data])
                )
                (format "Nonce {} updated successfully!" [nonce])
            )
        )
    )
    (defun DPNF|C_UpdateNonces
        (patron:string executor:string id:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id false nonces nos true new-nonces-data)
                )
                (format "Nonces {} updated successfully!" [nonces])
            )
        )
    )
    (defun DPNF|C_UpdateNonceRoyalty
        (patron:string executor:string id:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Nonce Native Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty patron executor id false nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceIgnisRoyalty
        (patron:string executor:string id:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Nonce IGNIS Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty patron executor id false nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceName
        (patron:string executor:string id:string nonce:integer nos:bool name:string)
        @doc "[3] Updates Nonce Name, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName patron executor id false nonce nos true name)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceDescription
        (patron:string executor:string id:string nonce:integer nos:bool description:string)
        @doc "[4] Updates Nonce Description, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription patron executor id false nonce nos true description)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceScore
        (patron:string executor:string id:string nonce:integer nos:bool score:decimal)
        @doc "[5] Updates Nonce Score, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore patron executor id false nonce nos true score)
                )
            )
        )
    )
    (defun DPNF|C_RemoveNonceScore (patron:string executor:string id:string nonce:integer nos:bool)
        @doc "[5b] Removes Nonce Score, setting it to -1.0, either Native or Split, for an NFT \
        \ \
        \ Executor: PROVEN INDIRECTLY, and named. This is a thin alias: it delegates to \
        \ DPNF|C_UpdateNonceScore in THIS module, and that wrapper's own call chain is what \
        \ proves the account. FORWARDED matches cross-module `ref-X::` calls by design, so an \
        \ intra-Talos delegation has to be traced by a human and written down. \
        \ (patron/executor canon 2.2, 2026-09-22.)"
        (DPNF|C_UpdateNonceScore patron executor id nonce nos -1.0)
    )
    (defun DPNF|C_UpdateNonceMetaData
        (patron:string executor:string id:string nonce:integer nos:bool meta-data:object)
        @doc "[6] Updates Nonce Meta-Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData patron executor id false nonce nos true meta-data)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceURI
        (
            patron:string executor:string id:string nonce:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Nonce URI, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV3} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI patron executor id false nonce nos true ay u1 u2 u3)
                )
            )
        )
    )

)

;; --- tables for 02_TS02-C2.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact ===============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; SaleSnakesV3: already deployed and unchanged -- see LIVE_INTERFACES

(module DEMIPAD-SNAKES GOV
    @doc "Module defining the Sale Mechanics for Demiourgos Share Holder Collection"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SaleSnakesV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SNAKES                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SNAKES_ADMIN)))
    (defcap GOV|SNAKES_ADMIN ()                         (enforce-guard GOV|MD_SNAKES))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|DEMIPAD|SC_NAME ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
            )
            (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)
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
    (defcap P|SNAKES|CALLER ()
        true
    )
    (defcap P|SNAKES|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SNAKES|CALLER))
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
        (with-capability (GOV|SNAKES_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SNAKES_ADMIN)
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
        (with-capability (GOV|SNAKES_ADMIN)
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
        (with-capability (GOV|SNAKES_ADMIN)
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
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|SNAKES|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "SNAKES|RemoteGov"
                (create-capability-guard (P|SNAKES|REMOTE-GOV))
            )
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst SNAKES|INFO                               (CT_Info))
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema SNAKES|PropertiesSchema
        asset-id:string
    )
    ;;{3.3}  tables
    (deftable SNAKES|T|Properties:{SNAKES|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap SNAKES|C>INITIALISE ()
        @event
        (compose-capability (GOV|SNAKES_ADMIN))
    )
    (defcap SNAKES|ACQUIRE (nonce:integer amount:integer)
        @event
        (let
            (
                (available-supply-to-acquire:integer (UR_NonceSaleAvailability nonce))
            )
            ;;nonce validity FIRST, so an unsellable nonce is named as such rather than reported as
            ;;a stock shortage it can never recover from. Order matters: UR_NonceSaleAvailability
            ;;answers 0 for an unknown nonce, so the supply check below would otherwise absorb it.
            (UEV_AcquisitionNonce nonce)
            (enforce (<= amount available-supply-to-acquire) "Insufficient Assets for Acquisiton!")
            (compose-capability (P|SNAKES|CALLER))
            (compose-capability (P|SNAKES|REMOTE-GOV))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                                   (at 0 ["Shareholders"]))
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
    (defun UR_AssetID ()
        (at "asset-id" (read SNAKES|T|Properties SNAKES|INFO ["asset-id"]))
    )
    (defun UR_DollarSharePrice:decimal ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
            )
            (at "price-per-share-in-dollars" (ref-DEMIPAD::UR_Price (UR_AssetID)))
        )
    )
    (defun UR_NonceSaleAvailability:integer (nonce:integer)
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (asset:string (UR_AssetID))
            )
            (ref-DPDC::UR_AccountNonceSupply lpad asset true nonce)
        )
    )
    (defun URC_NonceValueInShares:integer (nonce:integer)
        (if (= nonce 1)
            1
            (let
                (
                    (ref-EQUITY:module{EquityV5} EQUITY)
                    (asset:string (UR_AssetID))
                    (tier:integer (- nonce 1))
                )
                (ref-EQUITY::URC_SingleSharePerMillions asset tier)
            )
        )
    )
    (defun URC_ShareCosts:object{DemiourgosLaunchpadV3.Costs} ()
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                ;;
                (share-pid:decimal (UR_DollarSharePrice))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                share-pid
                (floor (/ share-pid stoa-pid) wstoa-prec)
            )
        )
    )
    (defun URC_NonceCosts:object{DemiourgosLaunchpadV3.Costs} (nonce:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                ;;
                (share-costs:object{DemiourgosLaunchpadV3.Costs} (URC_ShareCosts))
                (nonce-value-in-shares:integer (URC_NonceValueInShares nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" share-costs) (dec nonce-value-in-shares)) 2)
                (floor (* (at "wstoa" share-costs) (dec nonce-value-in-shares)) wstoa-prec)
            )
        )
    )
    (defun URC_NonceAmountCosts:object{DemiourgosLaunchpadV3.Costs} (nonce:integer amount:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                ;;
                (nonce-costs:object{DemiourgosLaunchpadV3.Costs} (URC_NonceCosts nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" nonce-costs) (dec amount)) 2)
                (floor (* (at "wstoa" nonce-costs) (dec amount)) wstoa-prec)
            )
        )
    )
    (defun URCi_Acquire:decimal (buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_Acquire = Sigma of the two SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): DEMIPAD deposit + DPDC-T SFT nonce transfer. Amount-independent \
            \ deposit; the transfer cost depends only on the collectable fee class."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                (asset:string (UR_AssetID))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
                (type:integer (if iz-native 0 1))
            )
            (+ (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DEMIPAD::URCi_Deposit buyer asset pid type false))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DPDC-T::URCi_MultiTransferCumulator [asset] [true] DEMIPAD|SC_NAME buyer [[nonce]] [[amount]])))
               ;;MISSING LEG FIXED (2026-09-14). The Sigma counted the deposit and the transfer GAS but
               ;;not the IGNIS ROYALTY. `DPDC|C_MultiTransfer` runs `C_IgnisRoyaltyCollector patron ...`
               ;;before its own collect, and that pays the collection creator OUT OF THE PATRON — so a
               ;;buyer of a royalty-bearing nonce is charged more than this preview quoted. Measured
               ;;89.002 quoted against 89.004 charged on a 2-share buy (0.001/share).
               ;;The `(if virtual-gas-zero 0.0 ...)` mirrors the collector's own short-circuit, so the
               ;;preview stays correct when virtual gas is switched off.
               (if (ref-IGNIS::URC_IsVirtualGasZero)
                   0.0
                   (ref-DPDC-T::URC_SummedIgnisRoyalty DEMIPAD|SC_NAME asset true [nonce] [amount])))
        )
    )
    (defun INFO_Acquire:object{OuronetInfoV3.ClientInfo} (patron:string buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Cost preview for the SNAKES|C_Acquire pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_Acquire (Sigma of the two Talos ops). Launchpad ops \
            \ carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) is declared in \
            \ the description as the good bought, not a fee-to-execute (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (asset:string (UR_AssetID))
                (costs:object{DemiourgosLaunchpadV3.Costs} (URC_NonceAmountCosts nonce amount))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Acquire {} of {} nonce {} for {} (pure-citizen, Sigma-billed)." [amount asset nonce sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.SNAKES|C_Acquire (the sole gas-funded path)." ]
                [ (format "Acquired {} of {} nonce {}." [amount asset nonce]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_Acquire buyer nonce amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string nonce:integer amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — coin.TRANSFER caps the UI signs, padded by (1 + slippage/100)."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::URC_Acquire buyer asset-id pid type slippage)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_AcquisitionNonce (nonce:integer)
        @doc "The nonces this pad actually sells: 1 = Pure Shares, 2-8 = Tier 1-7 PackageShares. \
            \ ADDED 2026-09-14, mirroring the Custodians twin's UEV_AcquisitionNonce, which had it \
            \ from the start. Without it a nonexistent nonce was refused by the SUPPLY cap instead \
            \ -- UR_NonceSaleAvailability returns 0 for an unknown nonce, so any amount exceeds it \
            \ -- and reported \"Insufficient Assets for Acquisiton!\". That is actively misleading, \
            \ not merely terse: the implied remedy is to wait for restocking, which can NEVER work \
            \ for a nonce the pad does not sell, and the text was identical to a genuine over-buy, \
            \ so the two were indistinguishable to a client."
        (let
            (
                (acquisition-nonces:[integer] (enumerate 1 8))
                (iz-acquisition-nonce:bool (contains nonce acquisition-nonces))
            )
            (enforce iz-acquisition-nonce "Invalid Snakes Acquisition Nonce")
        )
    )
    (defun CAP_Acquire
        (buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Variant 2 (slippage off) — installs the coin.TRANSFER caps in-code at the live price."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer asset-id pid type)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_UpdateSharePrice (patron:string executor:string price:decimal)
        @doc "Updates the Share Price. \
            \ FIXED 2026-09-14 -- this was DEAD ON ARRIVAL. DEMIPAD::A_DefinePrice opens with \
            \ P|UEV_IMC, a UEV_Any over the caller-policy guards DEMIPAD has registered, and the \
            \ one that admits this module is (create-capability-guard (P|SNAKES|CALLER)). A \
            \ capability guard only passes while its capability is IN SCOPE, and this defun \
            \ acquired nothing at all -- so every invocation died on P|UEV_IMC with \
            \ \"None of the guards passed\", admin signature and all. Its sibling C_Acquire earns \
            \ the same gate because its defcap composes P|SNAKES|CALLER; this now does the same \
            \ through P|SECURE-CALLER. NOTE this grants no authority: P|SECURE-CALLER only \
            \ proves the call originates inside this module. The ACTUAL authorization is \
            \ DEMIPAD|C>DEFINE-PRICE -> DEMIPAD|C>SECURE-ADMIN -> GOV|DEMIPAD_ADMIN, which was \
            \ previously UNREACHABLE and is now the gate that decides. Pinned by \
            \ modules/LAUNCHPAD.repl."
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (asset:string (UR_AssetID))
                )
                ;;PATRON AND EXECUTOR THREADED, 2026-09-22 (00_Demipad's canon turn). DEMIPAD's
                ;;four admin ops now take both: the GOV|DEMIPAD_ADMIN keyset still decides whether
                ;;the call proceeds, and the executor records WHICH keyholder made it. This
                ;;function had neither, so both had to become parameters rather than be invented
                ;;here -- HANDOFF 4e: never put a placeholder in a patron slot.
                (ref-DEMIPAD::A_DefinePrice patron executor asset
                    {"price-per-share-in-dollars" : price}
                )
            )
        )
    )
    (defun C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal)
        @doc "Nonce 1 are Pure Shares, Nonces 2-8 are Tier 1-7 PackageShares \
            \ When <iz-native> is set to true, Native STOA is used for buy, which must be wrapped to WSTOA \
            \ <max-cost> is the buyer's slippage ceiling in dollars (sentinel < 0 = slippage off)."
        (with-capability (SNAKES|ACQUIRE nonce amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV4} TS02-DPAD)
                    (ref-TS02-C1:module{TalosStageTwo_ClientOneV5} TS02-C1)
                    ;;
                    (asset:string (UR_AssetID))
                    (costs:object{DemiourgosLaunchpadV3.Costs} (URC_NonceAmountCosts nonce amount))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::DEMIPAD|C_Deposit patron buyer asset pid type false max-cost)
                ;;2] SOVEREIGN DPDC collectable transfer Talos op — SFT nonce(s) from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS02-C1::DPDC|C_MultiTransfer patron DEMIPAD|SC_NAME buyer [asset] [true] [[nonce]] [[amount]] true)
                (format "User {} succesfuly acquired {} Nonce {} {} SFTs" [sb amount nonce asset])
            )
        )
    )

)

;; --- tables for 02_Snakes.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table SNAKES|T|Properties)

;; ===== 2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact =======
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; SaleCustodiansV3: already deployed and unchanged -- see LIVE_INTERFACES

(module DEMIPAD-CUSTODIANS GOV
    @doc "Module defining the Sale Mechanics for Ouronet Custodians Collection"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SaleCustodiansV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_CUSTODIANS                         (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|CUSTODIANS_ADMIN)))
    (defcap GOV|CUSTODIANS_ADMIN ()                     (enforce-guard GOV|MD_CUSTODIANS))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|DEMIPAD|SC_NAME ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
            )
            (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)
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
    (defcap P|CUSTODIANS|CALLER ()
        true
    )
    (defcap P|CUSTODIANS|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|CUSTODIANS|CALLER))
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
        (with-capability (GOV|CUSTODIANS_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|CUSTODIANS_ADMIN)
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
        (with-capability (GOV|CUSTODIANS_ADMIN)
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
        (with-capability (GOV|CUSTODIANS_ADMIN)
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
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|CUSTODIANS|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "CUSTODIANS|RemoteGov"
                (create-capability-guard (P|CUSTODIANS|REMOTE-GOV))
            )
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst CUSTODIANS|INFO                           (CT_Info))
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema CUSTODIANS|PropertiesSchema
        asset-id:string
    )
    ;;{3.3}  tables
    (deftable CUSTODIANS|T|Properties:{CUSTODIANS|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap CUSTODIANS|C>INITIALISE ()
        @event
        (compose-capability (GOV|CUSTODIANS_ADMIN))
    )
    (defcap CUSTODIANS|ACQUIRE (nonce:integer amount:integer)
        @event
        ;;#10M: nonce validation is enforced HERE (was buried in the UR_ read, which must not enforce).
        (UEV_AcquisitionNonce nonce)
        (let
            (
                (available-supply-to-acquire:integer (UR_NonceSaleAvailability nonce))
            )
            (enforce (<= amount available-supply-to-acquire) "Insufficient Assets for Acquisiton!")
            (compose-capability (P|CUSTODIANS|CALLER))
            (compose-capability (P|CUSTODIANS|REMOTE-GOV))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                                   (at 0 ["Custodians"]))
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
    (defun UC_NonceQuintessence:integer (nonce:integer)
        @doc "Pure nonce->quintessence mapping for the three Custodian fragment nonces: \
            \ -1 (Bronze) = 1, -2 (Silver) = 10, -3 (Golden) = 100. No enforce: nonce validity \
            \ is enforced by the CUSTODIANS|ACQUIRE cap on the mutation path (UEV_AcquisitionNonce)."
        (if (= nonce -1)
            1
            (if (= nonce -2)
                10
                100
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_AssetID ()
        (at "asset-id" (read CUSTODIANS|T|Properties CUSTODIANS|INFO ["asset-id"]))
    )
    (defun UR_QuitessencePrice:decimal ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
            )
            (at "quintessence-price" (ref-DEMIPAD::UR_Price (UR_AssetID)))
        )
    )
    (defun UR_NonceSaleAvailability:integer (nonce:integer)
        ;;#10M: pure DPDC supply read (no enforce — matches the Snakes twin). Nonce validity is enforced
        ;;      by the CUSTODIANS|ACQUIRE cap on the mutation path.
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                ;;#4H: was the non-existent GOV|LAUNCHPAD|SC_NAME → the real member (matches Snakes twin)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (asset:string (UR_AssetID))
            )
            (ref-DPDC::UR_AccountNonceSupply lpad asset true nonce)
        )
    )
    (defun URC_QuintessenceCosts:object{DemiourgosLaunchpadV3.Costs} ()
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                ;;
                (q-pid:decimal (UR_QuitessencePrice))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                q-pid
                (floor (/ q-pid stoa-pid) wstoa-prec)
            )
        )
    )
    (defun URC_NonceCosts:object{DemiourgosLaunchpadV3.Costs} (nonce:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                ;;
                (q-costs:object{DemiourgosLaunchpadV3.Costs} (URC_QuintessenceCosts))
                (nonce-value-in-quintessence:integer (UC_NonceQuintessence nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" q-costs) (dec nonce-value-in-quintessence)) 2)
                (floor (* (at "wstoa" q-costs) (dec nonce-value-in-quintessence)) wstoa-prec)
            )
        )
    )
    (defun URC_NonceAmountCosts:object{DemiourgosLaunchpadV3.Costs} (nonce:integer amount:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                ;;
                (nonce-costs:object{DemiourgosLaunchpadV3.Costs} (URC_NonceCosts nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" nonce-costs) (dec amount)) 2)
                (floor (* (at "wstoa" nonce-costs) (dec amount)) wstoa-prec)
            )
        )
    )
    (defun URCi_Acquire:decimal (buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_Acquire = Sigma of the two SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): DEMIPAD deposit + DPDC-T SFT nonce transfer."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (ref-DPDC-T:module{DpdcTransferV3} DPDC-T)
                (asset:string (UR_AssetID))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
                (type:integer (if iz-native 0 1))
            )
            (+ (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DEMIPAD::URCi_Deposit buyer asset pid type false))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DPDC-T::URCi_MultiTransferCumulator [asset] [true] DEMIPAD|SC_NAME buyer [[nonce]] [[amount]])))
               ;;MISSING LEG FIXED (2026-09-14). The Sigma counted the deposit and the transfer GAS but
               ;;not the IGNIS ROYALTY. `DPDC|C_MultiTransfer` runs `C_IgnisRoyaltyCollector patron ...`
               ;;before its own collect, and that pays the collection creator OUT OF THE PATRON — so a
               ;;buyer of a royalty-bearing nonce is charged more than this preview quoted. Measured
               ;;89.002 quoted against 89.004 charged on a 2-share buy (0.001/share).
               ;;The `(if virtual-gas-zero 0.0 ...)` mirrors the collector's own short-circuit, so the
               ;;preview stays correct when virtual gas is switched off.
               (if (ref-IGNIS::URC_IsVirtualGasZero)
                   0.0
                   (ref-DPDC-T::URC_SummedIgnisRoyalty DEMIPAD|SC_NAME asset true [nonce] [amount])))
        )
    )
    (defun INFO_Acquire:object{OuronetInfoV3.ClientInfo} (patron:string buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Cost preview for the CUSTODIANS|C_Acquire pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_Acquire (Sigma of the two Talos ops). Launchpad ops \
            \ carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) is declared as \
            \ the good bought (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (asset:string (UR_AssetID))
                (costs:object{DemiourgosLaunchpadV3.Costs} (URC_NonceAmountCosts nonce amount))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Acquire {} of {} nonce {} for {} (pure-citizen, Sigma-billed)." [amount asset nonce sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.CUSTODIANS|C_Acquire (the sole gas-funded path)." ]
                [ (format "Acquired {} of {} nonce {}." [amount asset nonce]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_Acquire buyer nonce amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string nonce:integer amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — coin.TRANSFER caps the UI signs, padded by (1 + slippage/100)."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::URC_Acquire buyer asset-id pid type slippage)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string nonce:integer amount:integer iz-native:bool)
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer asset-id pid type)
        )
    )
    (defun UEV_AcquisitionNonce (nonce:integer)
        (let
            (
                (acquisition-nonces:[integer] [-3 -2 -1])
                (iz-acquisition-nonce:bool (contains nonce acquisition-nonces))
            )
            (enforce iz-acquisition-nonce "Invalid Custodian Acquisition Nonce")
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: GOV|CUSTODIANS_ADMIN
    (defun XI_I|AssetId (asset-id:string)
        (require-capability (GOV|CUSTODIANS_ADMIN))
        (insert CUSTODIANS|T|Properties CUSTODIANS|INFO
            {"asset-id"     : asset-id}
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_UpdateQuintessencePrice (patron:string executor:string price:decimal)
        @doc "Updates the Quintessence Price. \
            \ FIXED 2026-09-14 -- this was DEAD ON ARRIVAL. DEMIPAD::A_DefinePrice opens with \
            \ P|UEV_IMC, a UEV_Any over the caller-policy guards DEMIPAD has registered, and the \
            \ one that admits this module is (create-capability-guard (P|CUSTODIANS|CALLER)). A \
            \ capability guard only passes while its capability is IN SCOPE, and this defun \
            \ acquired nothing at all -- so every invocation died on P|UEV_IMC with \
            \ \"None of the guards passed\", admin signature and all. Its sibling C_Acquire earns \
            \ the same gate because its defcap composes P|CUSTODIANS|CALLER; this now does the same \
            \ through P|SECURE-CALLER. NOTE this grants no authority: P|SECURE-CALLER only \
            \ proves the call originates inside this module. The ACTUAL authorization is \
            \ DEMIPAD|C>DEFINE-PRICE -> DEMIPAD|C>SECURE-ADMIN -> GOV|DEMIPAD_ADMIN, which was \
            \ previously UNREACHABLE and is now the gate that decides. Pinned by \
            \ modules/LAUNCHPAD.repl."
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (asset:string (UR_AssetID))
                )
                ;;PATRON AND EXECUTOR THREADED, 2026-09-22 (00_Demipad's canon turn). DEMIPAD's
                ;;four admin ops now take both: the GOV|DEMIPAD_ADMIN keyset still decides whether
                ;;the call proceeds, and the executor records WHICH keyholder made it. This
                ;;function had neither, so both had to become parameters rather than be invented
                ;;here -- HANDOFF 4e: never put a placeholder in a patron slot.
                (ref-DEMIPAD::A_DefinePrice patron executor asset
                    {"quintessence-price" : price}
                )
            )
        )
    )
    (defun C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal)
        @doc "Only Nonce -3 -2 -1 can be used, and these are Bronze/Silver/Golden Fragment Nonces. \
            \ <max-cost> is the buyer's slippage ceiling in dollars (sentinel < 0 = slippage off)."
        ;;#3H: open CUSTODIANS|ACQUIRE (was missing — the twin Snakes wraps SNAKES|ACQUIRE). This restores
        ;;    the per-nonce supply cap (enforce amount <= available) + composes the P|CUSTODIANS caller
        ;;    policies the downstream DPDC-T transfer needs, and fires the @event.
        (with-capability (CUSTODIANS|ACQUIRE nonce amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV4} TS02-DPAD)
                    (ref-TS02-C1:module{TalosStageTwo_ClientOneV5} TS02-C1)
                    ;;
                    (asset:string (UR_AssetID))
                    (costs:object{DemiourgosLaunchpadV3.Costs} (URC_NonceAmountCosts nonce amount))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::DEMIPAD|C_Deposit patron buyer asset pid type false max-cost)
                ;;2] SOVEREIGN DPDC collectable transfer Talos op — SFT nonce(s) from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS02-C1::DPDC|C_MultiTransfer patron DEMIPAD|SC_NAME buyer [asset] [true] [[nonce]] [[amount]] true)
                (format "User {} succesfuly acquired {} Nonce {} {} SFTs" [sb amount nonce asset])
            )
        )
    )

)

;; --- tables for 03_Custodians.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table CUSTODIANS|T|Properties)


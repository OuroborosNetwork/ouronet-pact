;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 4 of 4
;; This is STEP 4 of 4 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-3 must have run first, including the init steps between deploys.
;; 5 source file(s), 438,382 gas measured in the REPL gas model, 290,491 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact
;;   1_SOVEREIGN/STAGE_02/3_Talos/02_TS02-C2.pact
;;   2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact
;;   2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact
;;   1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact
;;
;; TOTAL: 1 interface(s), 5 module(s), 10 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact
;;      interface  TalosStageTwo_ClientOneV4
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
;;   -- 1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact
;;      module     INFO-TWO
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
(interface TalosStageTwo_ClientOneV4
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
    (defun DPSF|C_IssueShares (patron:string executor:string id:string millions:integer))
    (defun DPSF|C_RetireShares (patron:string executor:string id:string millions:integer))
    (defun DPSF|C_PauseCompany (patron:string executor:string id:string toggle:bool))
    (defun DPSF|C_SetCompanyBranding (patron:string executor:string id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}]))
    (defun DPSF|C_UpgradeCompanyBranding (patron:string executor:string id:string months:integer))
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
    (implements TalosStageTwo_ClientOneV4)

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
    (defun DPSF|C_IssueShares (patron:string executor:string id:string millions:integer)
        @doc "Creates <millions> million new shares in the company <id>. The company's CREATOR \
            \ is the only account that may call this; <millions> whole millions only."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EQUITY:module{EquityV5} EQUITY)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EQUITY::C_IssueShares patron executor id millions)
                )
                (format "Successfully issued {} million new shares for Company {}" [millions id])
            )
        )
    )
    (defun DPSF|C_RetireShares (patron:string executor:string id:string millions:integer)
        @doc "Retires <millions> million shares of company <id> -- a permissioned burn. The \
            \ retirer must hold the holder's leg of the amount; the escrow's leg is burned \
            \ alongside it so every package holder's percentage is unchanged."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EQUITY:module{EquityV5} EQUITY)
                )
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
                (ref-TS02-C1:module{TalosStageTwo_ClientOneV4} TS02-C1)
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
                    (ref-TS02-C1:module{TalosStageTwo_ClientOneV4} TS02-C1)
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
                    (ref-TS02-C1:module{TalosStageTwo_ClientOneV4} TS02-C1)
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

;; ===== 1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact ===============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; InfoTwoV3: already deployed and unchanged -- see LIVE_INTERFACES

;;INFO_LIQUID|UnwrapStoa
;;INFO_LIQUID|WrapStoa
;;INFO_LIQUID|UnwrapUrStoa
(module INFO-TWO GOV
    @doc "INFO-TWO (InfoTwoV2) is the read-only Stage-2 UI info module exposing INFO_ \
        \ preview functions returning ClientInfo objects (description, result, IGNIS/STOA \
        \ cost) for Stage-2 client ops: DPDC collectables (roles, management, nonce/set \
        \ updates, wipes, burns, transfers, sets), the DEMIPAD sovereign launchpad, EQUITY, \
        \ and AQP. Each preview wraps the corresponding core module's URCi_ cost reader via \
        \ shared helpers; it holds no tables and does no writes."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    ;;(implements InfoTwoV3)
    ;;
    (defconst GOV|MD_INFO|DPTF                          (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|INFO|DPTF_ADMIN)))
    (defcap GOV|INFO|DPTF_ADMIN ()                      (enforce-guard GOV|MD_INFO|DPTF))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|SWP|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|SWP|SC_NAME)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    ;;{3.2}  schemas
    ;;{3.3}  tables

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
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;
    ;;  [SIP|URC] - Simple Ignis Price >> dependent on a single trigger
    ;;
    ;;
    ;;  [SKP|URC] - Simple Stoa Price 
    ;;
    ;;
    ;;  [INFO] - Informational URC Functions
    ;;
    ;;
    ;;  [DPDC roles/toggles] — DPDC-R (son = false for DPNF, true for DPSF)
    (defun INFO_DPDC-R|Toggle:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string son:bool label:string ico:object{IgnisCollectorV4.OutputCumulator} toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(if toggle (format "Operation: Adds {} Role for {} {} to {}" [label (if son "SFT" "NFT") id sa]) (format "Operation: Removes {} Role for {} {} to {}" [label (if son "SFT" "NFT") id sa]))]
                [(if toggle (format "{} Role added for {} to {}" [label id sa]) (format "{} Role removed for {} to {}" [label id sa]))]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [toggle])
        ))
    (defun INFO_DPNF|ToggleBurnRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Burn" (r::URCi_ToggleBurnRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleBurnRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Burn" (r::URCi_ToggleBurnRole id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleExemptionRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Fee-Exemption" (r::URCi_ToggleExemptionRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleExemptionRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Fee-Exemption" (r::URCi_ToggleExemptionRole id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleFreezeAccount:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Freeze" (r::URCi_ToggleFreezeAccount id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleFreezeAccount:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Freeze" (r::URCi_ToggleFreezeAccount id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleModifyCreatorRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Modify-Creator" (r::URCi_ToggleModifyCreatorRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleModifyCreatorRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Modify-Creator" (r::URCi_ToggleModifyCreatorRole id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleModifyRoyaltiesRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Modify-Royalties" (r::URCi_ToggleModifyRoyaltiesRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleModifyRoyaltiesRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Modify-Royalties" (r::URCi_ToggleModifyRoyaltiesRole id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleTransferRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Transfer" (r::URCi_ToggleTransferRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleTransferRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Transfer" (r::URCi_ToggleTransferRole id true) toggle)
        )
    )
    (defun INFO_DPNF|ToggleUpdateRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account false "Update" (r::URCi_ToggleUpdateRole id false) toggle)
        )
    )
    (defun INFO_DPSF|ToggleUpdateRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Update" (r::URCi_ToggleUpdateRole id true) toggle)
        )
    )
    (defun INFO_DPSF|ToggleAddQuantityRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string toggle:bool)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Toggle patron id account true "Add-Quantity" (r::URCi_ToggleAddQuantityRole id) toggle)
        )
    )
    ;;  [DPDC role moves] — DPDC-R Move* (patron id new-account)
    (defun INFO_DPDC-R|Move:object{OuronetInfoV3.ClientInfo} (patron:string id:string new-account:string son:bool label:string ico:object{IgnisCollectorV4.OutputCumulator})
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount new-account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Moves the {} Role of {} {} to {}" [label (if son "SFT" "NFT") id sa])]
                [(format "{} Role of {} succesfully moved to {}" [label id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DPNF|MoveCreateRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account false "Create" (r::URCi_MoveCreateRole id false))
        )
    )
    (defun INFO_DPSF|MoveCreateRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account true "Create" (r::URCi_MoveCreateRole id true))
        )
    )
    (defun INFO_DPNF|MoveRecreateRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account false "Recreate" (r::URCi_MoveRecreateRole id false))
        )
    )
    (defun INFO_DPSF|MoveRecreateRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account true "Recreate" (r::URCi_MoveRecreateRole id true))
        )
    )
    (defun INFO_DPNF|MoveSetUriRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account false "Set-URI" (r::URCi_MoveSetUriRole id false))
        )
    )
    (defun INFO_DPSF|MoveSetUriRole:object{OuronetInfoV3.ClientInfo} (patron:string id:string new-account:string)
        (let
            (
                (r:module{DpdcRolesV3} DPDC-R)
            )
            (INFO_DPDC-R|Move patron id new-account true "Set-URI" (r::URCi_MoveSetUriRole id true))
        )
    )
    ;;  [DPDC management] — DPDC-MNG Control / Pause / Respawn / AddQuantity
    (defun INFO_DPDC-MNG|Simple:object{OuronetInfoV3.ClientInfo} (patron:string desc:string result:string ico:object{IgnisCollectorV4.OutputCumulator})
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo [desc] [result]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DPNF|Control:object{OuronetInfoV3.ClientInfo} (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Controls Boolean Properties of NFT {}" [id]) (format "Succesfully controlled Properties of NFT {}" [id]) (r::URCi_Control id false))
        )
    )
    (defun INFO_DPSF|Control:object{OuronetInfoV3.ClientInfo} (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Controls Boolean Properties of SFT {}" [id]) (format "Succesfully controlled Properties of SFT {}" [id]) (r::URCi_Control id true))
        )
    )
    (defun INFO_DPNF|TogglePause:object{OuronetInfoV3.ClientInfo} (patron:string id:string toggle:bool)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (if toggle (format "Operation: Pauses NFT {}" [id]) (format "Operation: Unpauses NFT {}" [id])) (format "NFT {} pause toggled" [id]) (r::URCi_TogglePause id false))
        )
    )
    (defun INFO_DPSF|TogglePause:object{OuronetInfoV3.ClientInfo} (patron:string id:string toggle:bool)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (if toggle (format "Operation: Pauses SFT {}" [id]) (format "Operation: Unpauses SFT {}" [id])) (format "SFT {} pause toggled" [id]) (r::URCi_TogglePause id true))
        )
    )
    (defun INFO_DPNF|Respawn:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Respawns NFT {} Nonce {}" [id nonce]) (format "Succesfully respawned NFT {} Nonce {}" [id nonce]) (r::URCi_RespawnNFT id))
        )
    )
    (defun INFO_DPSF|AddQuantity:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer amount:integer)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Adds {} quantity to SFT {} Nonce {}" [amount id nonce]) (format "Succesfully added {} quantity to SFT {} Nonce {}" [amount id nonce]) (r::URCi_AddQuantity id))
        )
    )
    ;;  [DPDC updates] — DPDC-N single-field (URCi_UpdateNonceField) + bulk (URCi_UpdateNonces)
    (defun INFO_DPDC-N|Field:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string son:bool label:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (r:module{DpdcNonceV3} DPDC-N)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates the {} of {} {}" [label (if son "SFT" "NFT") id])]
                [(format "{} of {} {} succesfully updated" [label (if son "SFT" "NFT") id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_UpdateNonceField account)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DPDC-N|Bulk:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string son:bool label:string count:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (r:module{DpdcNonceV3} DPDC-N)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Updates {} {} of {} {}" [count label (if son "SFT" "NFT") id])]
                [(format "{} {} of {} {} succesfully updated" [count label (if son "SFT" "NFT") id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_UpdateNonces account count)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    ;;   NF single-field
    (defun INFO_DPNF|UpdateNonceName:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool name:string) (INFO_DPDC-N|Field patron id account false (format "Name (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceDescription:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool description:string) (INFO_DPDC-N|Field patron id account false (format "Description (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceRoyalty:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account false (format "Royalty (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceIgnisRoyalty:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account false (format "Ignis-Royalty (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceURI:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}) (INFO_DPDC-N|Field patron id account false (format "URI (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceMetaData:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool meta-data:object) (INFO_DPDC-N|Field patron id account false (format "Meta-Data (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateNonceScore:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool score:decimal) (INFO_DPDC-N|Field patron id account false (format "Score (Nonce {})" [nonce])))
    (defun INFO_DPNF|RemoveNonceScore:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool) (INFO_DPDC-N|Field patron id account false (format "Score-Removal (Nonce {})" [nonce])))
    (defun INFO_DPNF|UpdateSetNonceName:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool name:string) (INFO_DPDC-N|Field patron id account false (format "Name (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceDescription:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool description:string) (INFO_DPDC-N|Field patron id account false (format "Description (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceRoyalty:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account false (format "Royalty (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceIgnisRoyalty:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account false (format "Ignis-Royalty (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceURI:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}) (INFO_DPDC-N|Field patron id account false (format "URI (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceMetaData:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool meta-data:object) (INFO_DPDC-N|Field patron id account false (format "Meta-Data (Set-Class {})" [set-class])))
    (defun INFO_DPNF|UpdateSetNonceScore:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool score:decimal) (INFO_DPDC-N|Field patron id account false (format "Score (Set-Class {})" [set-class])))
    (defun INFO_DPNF|RemoveSetNonceScore:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool) (INFO_DPDC-N|Field patron id account false (format "Score-Removal (Set-Class {})" [set-class])))
    ;;   NF bulk
    (defun INFO_DPNF|UpdateNonce:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}) (INFO_DPDC-N|Bulk patron id account false "Nonce" 1))
    (defun INFO_DPNF|UpdateNonces:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]) (INFO_DPDC-N|Bulk patron id account false "Nonces" (length nonces)))
    (defun INFO_DPNF|UpdateSetNonce:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}) (INFO_DPDC-N|Bulk patron id account false "Set-Nonce" 1))
    (defun INFO_DPNF|UpdateSetNonces:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]) (INFO_DPDC-N|Bulk patron id account false "Set-Nonces" (length set-classes)))
    ;;   SF single-field
    (defun INFO_DPSF|UpdateNonceName:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool name:string) (INFO_DPDC-N|Field patron id account true (format "Name (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceDescription:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool description:string) (INFO_DPDC-N|Field patron id account true (format "Description (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceRoyalty:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account true (format "Royalty (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceIgnisRoyalty:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account true (format "Ignis-Royalty (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceURI:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}) (INFO_DPDC-N|Field patron id account true (format "URI (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceMetaData:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool meta-data:object) (INFO_DPDC-N|Field patron id account true (format "Meta-Data (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateNonceScore:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool score:decimal) (INFO_DPDC-N|Field patron id account true (format "Score (Nonce {})" [nonce])))
    (defun INFO_DPSF|RemoveNonceScore:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool) (INFO_DPDC-N|Field patron id account true (format "Score-Removal (Nonce {})" [nonce])))
    (defun INFO_DPSF|UpdateSetNonceName:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool name:string) (INFO_DPDC-N|Field patron id account true (format "Name (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceDescription:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool description:string) (INFO_DPDC-N|Field patron id account true (format "Description (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceRoyalty:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account true (format "Royalty (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceIgnisRoyalty:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal) (INFO_DPDC-N|Field patron id account true (format "Ignis-Royalty (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceURI:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}) (INFO_DPDC-N|Field patron id account true (format "URI (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceMetaData:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool meta-data:object) (INFO_DPDC-N|Field patron id account true (format "Meta-Data (Set-Class {})" [set-class])))
    (defun INFO_DPSF|UpdateSetNonceScore:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool score:decimal) (INFO_DPDC-N|Field patron id account true (format "Score (Set-Class {})" [set-class])))
    (defun INFO_DPSF|RemoveSetNonceScore:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool) (INFO_DPDC-N|Field patron id account true (format "Score-Removal (Set-Class {})" [set-class])))
    ;;   SF bulk
    (defun INFO_DPSF|UpdateNonce:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}) (INFO_DPDC-N|Bulk patron id account true "Nonce" 1))
    (defun INFO_DPSF|UpdateNonces:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]) (INFO_DPDC-N|Bulk patron id account true "Nonces" (length nonces)))
    (defun INFO_DPSF|UpdateSetNonce:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}) (INFO_DPDC-N|Bulk patron id account true "Set-Nonce" 1))
    (defun INFO_DPSF|UpdateSetNonces:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]) (INFO_DPDC-N|Bulk patron id account true "Set-Nonces" (length set-classes)))
    ;;  [DPDC wipes] — DPDC-MNG single (URCi_WipeNonce/WipeSlim) + multi (URCi_WipeCumulator)
    (defun INFO_DPDC-MNG|WipeMulti:object{OuronetInfoV3.ClientInfo} (patron:string id:string son:bool obj:object{DpdcManagementV3.RemovableNonces} label:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (r:module{DpdcManagementV3} DPDC-MNG)
                (n:integer (length (at "r-nonces" obj)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: {} wipe of {} {} Nonces of {}" [label (if son "SFT" "NFT") n id])]
                [(format "{} wipe of {} {} Nonces of {} succesful" [label (if son "SFT" "NFT") n id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_WipeCumulator id son obj)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DPNF|WipeNonce:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Wipes NFT {} Nonce {}" [id nonce]) (format "NFT {} Nonce {} wiped" [id nonce]) (r::URCi_WipeNonce id false))
        )
    )
    (defun INFO_DPSF|WipeNonce:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Wipes SFT {} Nonce {}" [id nonce]) (format "SFT {} Nonce {} wiped" [id nonce]) (r::URCi_WipeNonce id true))
        )
    )
    (defun INFO_DPSF|WipeNoncePartialy:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer amount:integer)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Partially wipes {} of SFT {} Nonce {}" [amount id nonce]) (format "Partially wiped {} of SFT {} Nonce {}" [amount id nonce]) (r::URCi_WipeSlim id))
        )
    )
    (defun INFO_DPNF|WipeHeavy:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|WipeMulti patron id false (r::URHC_WipePure account id false) "Heavy")
        )
    )
    (defun INFO_DPSF|WipeHeavy:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|WipeMulti patron id true (r::URHC_WipePure account id true) "Heavy")
        )
    )
    (defun INFO_DPNF|WipePure:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV3.RemovableNonces}) (INFO_DPDC-MNG|WipeMulti patron id false removable-nonces-obj "Pure"))
    (defun INFO_DPSF|WipePure:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV3.RemovableNonces}) (INFO_DPDC-MNG|WipeMulti patron id true removable-nonces-obj "Pure"))
    (defun INFO_DPNF|WipeClean:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonces:[integer])
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
                (d:module{DpdcV3} DPDC)
            )
            (INFO_DPDC-MNG|WipeMulti patron id false (r::UDC_RemovableNonces nonces (d::UR_AccountNoncesSupplies account id false nonces)) "Clean")
        )
    )
    (defun INFO_DPSF|WipeClean:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonces:[integer])
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
                (d:module{DpdcV3} DPDC)
            )
            (INFO_DPDC-MNG|WipeMulti patron id true (r::UDC_RemovableNonces nonces (d::UR_AccountNoncesSupplies account id true nonces)) "Clean")
        )
    )
    (defun INFO_DPNF|WipeDirty:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonces:[integer])
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|WipeMulti patron id false (r::URC_FilterAccountViableNonces account id false nonces) "Dirty")
        )
    )
    (defun INFO_DPSF|WipeDirty:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonces:[integer])
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|WipeMulti patron id true (r::URC_FilterAccountViableNonces account id true nonces) "Dirty")
        )
    )
    (defun INFO_DPNF|WipeSlice:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV3.RemovableNonces}) (INFO_DPDC-MNG|WipeMulti patron id false removable-nonces-obj "Hydra-Slice"))
    (defun INFO_DPSF|WipeSlice:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV3.RemovableNonces}) (INFO_DPDC-MNG|WipeMulti patron id true removable-nonces-obj "Hydra-Slice"))
    (defun INFO_DPDC-MNG|WipeFull:object{OuronetInfoV3.ClientInfo} (patron:string id:string son:bool plan:object{DpdcManagementV3.DPDC-MNG|WipeSlicePlan})
        @doc "Hydra wipe FULL preview: grand-total IGNIS across the whole <URHC_BuildWipeSlicePlan> \
            \ plan = the sum of every slice's own ifp (mirrors the per-slice executor byte-for-byte)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (r:module{DpdcManagementV3} DPDC-MNG)
                (slice-count:integer (at "slice-count" plan))
                (total-ifp:decimal
                    (fold (+) 0.0
                        (map
                            (lambda
                                (slice:object{DpdcManagementV3.RemovableNonces})
                                (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (r::URCi_WipeCumulator id son slice))
                            )
                            (at "slices" plan)
                        )
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Hydra wipe campaign of {} {} over {} slice tx(s)" [(if son "SFT" "NFT") id slice-count])]
                [(format "Hydra wipe campaign of {} {} over {} slice tx(s) succesful" [(if son "SFT" "NFT") id slice-count])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron total-ifp)
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [slice-count])
        ))
    (defun INFO_DPNF|WipeFull:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string plan:object{DpdcManagementV3.DPDC-MNG|WipeSlicePlan}) (INFO_DPDC-MNG|WipeFull patron id false plan))
    (defun INFO_DPSF|WipeFull:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string plan:object{DpdcManagementV3.DPDC-MNG|WipeSlicePlan}) (INFO_DPDC-MNG|WipeFull patron id true plan))
    ;;  [DPDC burn] — DPDC-MNG single-nonce burn
    (defun INFO_DPNF|Burn:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
                (d:module{DpdcV3} DPDC)
            )
            ;;STRUCTURAL check only -- the SAME function the exec's capability calls, so the two
            ;;refuse in one wording. Deliberately NOT the burn-ROLE check the exec also runs: a role
            ;;is transient state that changes between quote and submission, and family K's rule
            ;;(RT-K-002) is that previews validate what the caller cannot change, not what they can.
            ;;Without this the quote died on a raw DPNF|T|Properties read while the op refused
            ;;cleanly. Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-004a>>.
            (d::UEV_id id false)
            (INFO_DPDC-MNG|Simple patron (format "Operation: Burns NFT {} Nonce {}" [id nonce]) (format "NFT {} Nonce {} burned" [id nonce]) (r::URCi_BurnNFT id))
        )
    )
    (defun INFO_DPSF|Burn:object{OuronetInfoV3.ClientInfo} (patron:string id:string account:string nonce:integer amount:integer)
        (let
            (
                (r:module{DpdcManagementV3} DPDC-MNG)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Burns {} of SFT {} Nonce {}" [amount id nonce]) (format "Burned {} of SFT {} Nonce {}" [amount id nonce]) (r::URCi_BurnSFT id))
        )
    )
    ;;  [DPDC transfers] — DPDC-T Multi/Bulk transfer + Repurpose (DPDC-T / DPDC-F)
    (defun INFO_DPNF|TransferNonce:object{OuronetInfoV3.ClientInfo} (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (t:module{DpdcTransferV3} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Transfers {} of NFT {} Nonce {} to {}" [amount id nonce (ref-I|OURONET::OI|UC_ShortAccount receiver)]) (format "Transferred {} of NFT {} Nonce {}" [amount id nonce]) (t::URCi_MultiTransferCumulator [id] [false] sender receiver [[nonce]] [[amount]]))
        )
    )
    (defun INFO_DPSF|TransferNonce:object{OuronetInfoV3.ClientInfo} (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (t:module{DpdcTransferV3} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Transfers {} of SFT {} Nonce {} to {}" [amount id nonce (ref-I|OURONET::OI|UC_ShortAccount receiver)]) (format "Transferred {} of SFT {} Nonce {}" [amount id nonce]) (t::URCi_MultiTransferCumulator [id] [true] sender receiver [[nonce]] [[amount]]))
        )
    )
    (defun INFO_DPNF|TransferNonces:object{OuronetInfoV3.ClientInfo} (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (t:module{DpdcTransferV3} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Transfers {} Nonces of NFT {} to {}" [(length nonces) id (ref-I|OURONET::OI|UC_ShortAccount receiver)]) (format "Transferred {} Nonces of NFT {}" [(length nonces) id]) (t::URCi_MultiTransferCumulator [id] [false] sender receiver [nonces] [amounts]))
        )
    )
    (defun INFO_DPSF|TransferNonces:object{OuronetInfoV3.ClientInfo} (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (t:module{DpdcTransferV3} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Transfers {} Nonces of SFT {} to {}" [(length nonces) id (ref-I|OURONET::OI|UC_ShortAccount receiver)]) (format "Transferred {} Nonces of SFT {}" [(length nonces) id]) (t::URCi_MultiTransferCumulator [id] [true] sender receiver [nonces] [amounts]))
        )
    )
    (defun INFO_DPDC|MultiTransfer:object{OuronetInfoV3.ClientInfo} (patron:string ids:[string] sons:[bool] sender:string receiver:string nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (t:module{DpdcTransferV3} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Multi-transfers {} Collectable(s) to {}" [(length ids) (ref-I|OURONET::OI|UC_ShortAccount receiver)]) (format "Multi-transferred {} Collectable(s) to {}" [(length ids) (ref-I|OURONET::OI|UC_ShortAccount receiver)]) (t::URCi_MultiTransferCumulator ids sons sender receiver nonces-array amounts-array))
        )
    )
    (defun INFO_DPDC|BulkTransfer:object{OuronetInfoV3.ClientInfo} (patron:string id:string son:bool nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        (let
            (
                (t:module{DpdcTransferV3} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Bulk-transfers Collectable {} to {} receivers" [id (length receiver-lst)]) (format "Bulk-transferred Collectable {} to {} receivers" [id (length receiver-lst)]) (t::URCi_BulkTransferCumulator id son sender receiver-lst nonces-array amounts-array))
        )
    )
    (defun INFO_DPNF|BulkTransfer:object{OuronetInfoV3.ClientInfo} (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        (let
            (
                (t:module{DpdcTransferV3} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Bulk-transfers NFT {} to {} receivers" [id (length receiver-lst)]) (format "Bulk-transferred NFT {} to {} receivers" [id (length receiver-lst)]) (t::URCi_BulkTransferCumulator id false sender receiver-lst nonces-array amounts-array))
        )
    )
    (defun INFO_DPSF|BulkTransfer:object{OuronetInfoV3.ClientInfo} (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        (let
            (
                (t:module{DpdcTransferV3} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Bulk-transfers SFT {} to {} receivers" [id (length receiver-lst)]) (format "Bulk-transferred SFT {} to {} receivers" [id (length receiver-lst)]) (t::URCi_BulkTransferCumulator id true sender receiver-lst nonces-array amounts-array))
        )
    )
    (defun INFO_DPNF|Repurpose:object{OuronetInfoV3.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        (let
            (
                (t:module{DpdcTransferV3} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Nonces of NFT {}" [(length nonces) id]) (format "Repurposed {} Nonces of NFT {}" [(length nonces) id]) (t::URCi_RepurposeCollectable id false amounts))
        )
    )
    (defun INFO_DPSF|Repurpose:object{OuronetInfoV3.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        (let
            (
                (t:module{DpdcTransferV3} DPDC-T)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Nonces of SFT {}" [(length nonces) id]) (format "Repurposed {} Nonces of SFT {}" [(length nonces) id]) (t::URCi_RepurposeCollectable id true amounts))
        )
    )
    (defun INFO_DPNF|RepurposeFragments:object{OuronetInfoV3.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        (let
            (
                (fr:module{DpdcFragmentsV3} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Fragment-Nonces of NFT {}" [(length nonces) id]) (format "Repurposed {} Fragment-Nonces of NFT {}" [(length nonces) id]) (fr::URCi_RepurposeCollectableFragments id false amounts))
        )
    )
    (defun INFO_DPSF|RepurposeFragments:object{OuronetInfoV3.ClientInfo} (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        (let
            (
                (fr:module{DpdcFragmentsV3} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Repurposes {} Fragment-Nonces of SFT {}" [(length nonces) id]) (format "Repurposed {} Fragment-Nonces of SFT {}" [(length nonces) id]) (fr::URCi_RepurposeCollectableFragments id true amounts))
        )
    )
    ;;  [DPDC sets] — DpdcSetsV2 Make/Break/Define/Rename/Toggle
    (defun INFO_DPNF|Make:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonces:[integer] set-class:integer)
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Makes an NFT {} Set (class {}) from {} Nonces" [id set-class (length nonces)]) (format "NFT {} Set (class {}) made" [id set-class]) (s::URCi_MakeNonFungibleSet account id nonces))
        )
    )
    (defun INFO_DPSF|Make:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonces:[integer] set-class:integer how-many-sets:integer)
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Makes {} SFT {} Sets (class {}) from {} Nonces" [how-many-sets id set-class (length nonces)]) (format "{} SFT {} Sets (class {}) made" [how-many-sets id set-class]) (s::URCi_MakeSemiFungibleSet account id nonces how-many-sets))
        )
    )
    (defun INFO_DPNF|Break:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonce:integer)
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Breaks NFT {} Set-Nonce {}" [id nonce]) (format "NFT {} Set-Nonce {} broken" [id nonce]) (s::URCi_BreakNonFungibleSet account id nonce))
        )
    )
    (defun INFO_DPSF|Break:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonce:integer how-many-sets:integer)
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Breaks {} SFT {} Set-Nonce {}" [how-many-sets id nonce]) (format "{} SFT {} Set-Nonce {} broken" [how-many-sets id nonce]) (s::URCi_BreakSemiFungibleSet account id nonce how-many-sets))
        )
    )
    (defun INFO_DPNF|DefinePrimordialSet:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Primordial Set '{}' for NFT {}" [set-name id]) (format "Primordial Set '{}' defined for NFT {}" [set-name id]) (s::URCi_DefinePrimordialSet id false))
        )
    )
    (defun INFO_DPSF|DefinePrimordialSet:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Primordial Set '{}' for SFT {}" [set-name id]) (format "Primordial Set '{}' defined for SFT {}" [set-name id]) (s::URCi_DefinePrimordialSet id true))
        )
    )
    (defun INFO_DPNF|DefineCompositeSet:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Composite Set '{}' for NFT {}" [set-name id]) (format "Composite Set '{}' defined for NFT {}" [set-name id]) (s::URCi_DefineCompositeSet id false))
        )
    )
    (defun INFO_DPSF|DefineCompositeSet:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Composite Set '{}' for SFT {}" [set-name id]) (format "Composite Set '{}' defined for SFT {}" [set-name id]) (s::URCi_DefineCompositeSet id true))
        )
    )
    (defun INFO_DPNF|DefineHybridSet:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Hybrid Set '{}' for NFT {}" [set-name id]) (format "Hybrid Set '{}' defined for NFT {}" [set-name id]) (s::URCi_DefineHybridSet id false))
        )
    )
    (defun INFO_DPSF|DefineHybridSet:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-name:string score-multiplier:decimal primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}] composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}] ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Defines Hybrid Set '{}' for SFT {}" [set-name id]) (format "Hybrid Set '{}' defined for SFT {}" [set-name id]) (s::URCi_DefineHybridSet id true))
        )
    )
    (defun INFO_DPNF|RenameSet:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-class:integer new-name:string)
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Renames NFT {} Set-Class {} to '{}'" [id set-class new-name]) (format "NFT {} Set-Class {} renamed to '{}'" [id set-class new-name]) (s::URCi_RenameSet id false))
        )
    )
    (defun INFO_DPSF|RenameSet:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-class:integer new-name:string)
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Renames SFT {} Set-Class {} to '{}'" [id set-class new-name]) (format "SFT {} Set-Class {} renamed to '{}'" [id set-class new-name]) (s::URCi_RenameSet id true))
        )
    )
    (defun INFO_DPNF|ToggleSet:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-class:integer toggle:bool)
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Toggles NFT {} Set-Class {}" [id set-class]) (format "NFT {} Set-Class {} toggled" [id set-class]) (s::URCi_ToggleSet id false))
        )
    )
    (defun INFO_DPSF|ToggleSet:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-class:integer toggle:bool)
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Toggles SFT {} Set-Class {}" [id set-class]) (format "SFT {} Set-Class {} toggled" [id set-class]) (s::URCi_ToggleSet id true))
        )
    )
    ;;  [DPDC fragments] — DpdcFragmentsV2 (+ EnableSetClassFragmentation on DpdcSetsV2)
    (defun INFO_DPNF|EnableNonceFragmentation:object{OuronetInfoV3.ClientInfo} (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (fr:module{DpdcFragmentsV3} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of NFT {} Nonce {}" [id nonce]) (format "Fragmentation enabled for NFT {} Nonce {}" [id nonce]) (fr::URCi_EnableNonceFragmentation id false))
        )
    )
    (defun INFO_DPSF|EnableNonceFragmentation:object{OuronetInfoV3.ClientInfo} (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (fr:module{DpdcFragmentsV3} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of SFT {} Nonce {}" [id nonce]) (format "Fragmentation enabled for SFT {} Nonce {}" [id nonce]) (fr::URCi_EnableNonceFragmentation id true))
        )
    )
    (defun INFO_DPNF|EnableSetClassFragmentation:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-class:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of NFT {} Set-Class {}" [id set-class]) (format "Fragmentation enabled for NFT {} Set-Class {}" [id set-class]) (s::URCi_EnableSetClassFragmentation id false))
        )
    )
    (defun INFO_DPSF|EnableSetClassFragmentation:object{OuronetInfoV3.ClientInfo} (patron:string id:string set-class:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        (let
            (
                (s:module{DpdcSetsV3} DPDC-S)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Enables Fragmentation of SFT {} Set-Class {}" [id set-class]) (format "Fragmentation enabled for SFT {} Set-Class {}" [id set-class]) (s::URCi_EnableSetClassFragmentation id true))
        )
    )
    (defun INFO_DPNF|MakeFragments:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer)
        (let
            (
                (fr:module{DpdcFragmentsV3} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Makes {} Fragments of NFT {} Nonce {}" [amount id nonce]) (format "{} Fragments made of NFT {} Nonce {}" [amount id nonce]) (fr::URCi_MakeFragments id false))
        )
    )
    (defun INFO_DPSF|MakeFragments:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer)
        (let
            (
                (fr:module{DpdcFragmentsV3} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Makes {} Fragments of SFT {} Nonce {}" [amount id nonce]) (format "{} Fragments made of SFT {} Nonce {}" [amount id nonce]) (fr::URCi_MakeFragments id true))
        )
    )
    (defun INFO_DPNF|MergeFragments:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer)
        (let
            (
                (fr:module{DpdcFragmentsV3} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Merges {} Fragments of NFT {} Nonce {}" [amount id nonce]) (format "{} Fragments merged of NFT {} Nonce {}" [amount id nonce]) (fr::URCi_MergeFragments id false))
        )
    )
    (defun INFO_DPSF|MergeFragments:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string nonce:integer amount:integer)
        (let
            (
                (fr:module{DpdcFragmentsV3} DPDC-F)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Merges {} Fragments of SFT {} Nonce {}" [amount id nonce]) (format "{} Fragments merged of SFT {} Nonce {}" [amount id nonce]) (fr::URCi_MergeFragments id true))
        )
    )
    ;;  [DPDC create/issue] — DpdcCreateV2 / DpdcIssueV2
    (defun INFO_DPNF|Create:object{OuronetInfoV3.ClientInfo} (patron:string id:string input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}])
        (let
            (
                (c:module{DpdcCreateV3} DPDC-C)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Creates {} new Nonces for NFT {}" [(length input-nonce-data) id]) (format "{} new Nonces created for NFT {}" [(length input-nonce-data) id]) (c::URCi_CreateNewNonces id false (make-list (length input-nonce-data) 1)))
        )
    )
    (defun INFO_DPSF|Create:object{OuronetInfoV3.ClientInfo} (patron:string id:string amount:[integer] input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}])
        (let
            (
                (c:module{DpdcCreateV3} DPDC-C)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Creates {} new Nonces for SFT {}" [(length input-nonce-data) id]) (format "{} new Nonces created for SFT {}" [(length input-nonce-data) id]) (c::URCi_CreateNewNonces id true amount))
        )
    )
    (defun INFO_DPDC-I|Issue:object{OuronetInfoV3.ClientInfo} (patron:string owner-account:string collection-name:string son:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (i:module{DpdcIssueV3} DPDC-I)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues a new {} Collection '{}' for {}" [(if son "SemiFungible" "NonFungible") collection-name (ref-I|OURONET::OI|UC_ShortAccount owner-account)])]
                [(format "{} Collection '{}' succesfully issued" [(if son "SemiFungible" "NonFungible") collection-name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (i::URCi_IssueDigitalCollection son owner-account)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (i::URCi_IssueCollectionStoa son)) [])
        ))
    (defun INFO_DPNF|Issue:object{OuronetInfoV3.ClientInfo} (patron:string owner-account:string creator-account:string collection-name:string collection-ticker:string can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool) (INFO_DPDC-I|Issue patron owner-account collection-name false))
    (defun INFO_DPSF|Issue:object{OuronetInfoV3.ClientInfo} (patron:string owner-account:string creator-account:string collection-name:string collection-ticker:string can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool) (INFO_DPDC-I|Issue patron owner-account collection-name true))
    ;;  [DPDC branding] — DpdcV2 UpdatePendingBranding (IGNIS) + UpgradeBranding (STOA)
    (defun INFO_DPNF|UpdatePendingBranding:object{OuronetInfoV3.ClientInfo} (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}])
        (let
            (
                (d:module{DpdcV3} DPDC)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Updates pending Branding of NFT {}" [entity-id]) (format "Pending Branding of NFT {} updated" [entity-id]) (d::URCi_UpdatePendingBranding entity-id false))
        )
    )
    (defun INFO_DPSF|UpdatePendingBranding:object{OuronetInfoV3.ClientInfo} (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}])
        (let
            (
                (d:module{DpdcV3} DPDC)
            )
            (INFO_DPDC-MNG|Simple patron (format "Operation: Updates pending Branding of SFT {}" [entity-id]) (format "Pending Branding of SFT {} updated" [entity-id]) (d::URCi_UpdatePendingBranding entity-id true))
        )
    )
    (defun INFO_DPDC|UpgradeBranding:object{OuronetInfoV3.ClientInfo} (patron:string entity-id:string months:integer son:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (d:module{DpdcV3} DPDC)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Upgrades Branding of {} {} for {} months" [(if son "SFT" "NFT") entity-id months])]
                [(format "Branding of {} {} upgraded for {} months" [(if son "SFT" "NFT") entity-id months])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (d::URCi_UpgradeBranding months)) [])
        ))
    (defun INFO_DPNF|UpgradeBranding:object{OuronetInfoV3.ClientInfo} (patron:string entity-id:string months:integer) (INFO_DPDC|UpgradeBranding patron entity-id months false))
    (defun INFO_DPSF|UpgradeBranding:object{OuronetInfoV3.ClientInfo} (patron:string entity-id:string months:integer) (INFO_DPDC|UpgradeBranding patron entity-id months true))
    ;;  [DPSF equity aliases] — Talos surfaces EQUITY ops under the DPSF| client namespace
    (defun INFO_DPSF|IssueCompany:object{OuronetInfoV3.ClientInfo} (patron:string creator-account:string collection-name:string collection-ticker:string royalty:decimal ignis-royalty:decimal ipfs-links:[string]) (INFO_EQUITY|IssueCompany patron creator-account collection-name))
    (defun INFO_DPSF|MorphEquity:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string input-nonce:integer input-amount:integer output-nonce:integer) (INFO_EQUITY|MorphEquity patron account id input-nonce input-amount output-nonce))
    ;;
    ;;  [DEMIPAD] — sovereign launchpad ops (deposit + fuel/retrieve TF/OF/SF/NF + withdraw)
    (defun INFO_DEMIPAD|Deposit:object{OuronetInfoV3.ClientInfo} (patron:string donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (sd:string (ref-I|OURONET::OI|UC_ShortAccount donor))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Deposits {} $ worth against {} into the Launchpad from {}" [amount-in-dollars asset-id sd])]
                [(format "Succesfully deposited {} $ worth against {} into Demipad from {}" [amount-in-dollars asset-id sd])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_Deposit donor asset-id amount-in-dollars type direct-injection)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DEMIPAD|Withdraw:object{OuronetInfoV3.ClientInfo} (patron:string asset-id:string type:integer destination:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (amount:decimal (ref-DEMIPAD::URv_Funds asset-id type))
                (working-id:string (if (= type 1) (ref-DALOS::UR_WrappedStoaID) (if (= type 2) (ref-DALOS::UR_SilverStoaID) (ref-DALOS::UR_OuroborosID))))
                (sd:string (ref-I|OURONET::OI|UC_ShortAccount destination))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Withdraws {} {} accumulated in the Launchpad to {}" [amount working-id sd])]
                [(format "Succesfully withdrawn {} {} from Demipad to {}" [amount working-id sd])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_Transfer working-id lpad destination amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DEMIPAD|FuelTrueFungible:object{OuronetInfoV3.ClientInfo} (patron:string client:string asset-id:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} {} (TrueFungible) to the Launchpad from {}" [amount asset-id sa])]
                [(format "Succesfully fueled {} {} to the Launchpad from {}" [amount asset-id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_Transfer asset-id client lpad amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DEMIPAD|RetrieveTrueFungible:object{OuronetInfoV3.ClientInfo} (patron:string client:string asset-id:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} {} (TrueFungible) from the Launchpad to {}" [amount asset-id sa])]
                [(format "Succesfully retrieved {} {} from the Launchpad to {}" [amount asset-id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-TFT::URCi_Transfer asset-id lpad client amount)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    (defun INFO_DEMIPAD|FuelOrtoFungible:object{OuronetInfoV3.ClientInfo} (patron:string client:string asset-id:string nonces:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} Nonces {} (OrtoFungible) to the Launchpad from {}" [asset-id nonces sa])]
                [(format "Succesfully fueled {} Nonces {} to the Launchpad from {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_MoveCumulator asset-id nonces false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])
        ))
    (defun INFO_DEMIPAD|RetrieveOrtoFungible:object{OuronetInfoV3.ClientInfo} (patron:string client:string asset-id:string nonces:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} Nonces {} (OrtoFungible) from the Launchpad to {}" [asset-id nonces sa])]
                [(format "Succesfully retrieved {} Nonces {} from the Launchpad to {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPOF::URCi_MoveCumulator asset-id nonces false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])
        ))
    (defun INFO_DEMIPAD|FuelSemiFungible:object{OuronetInfoV3.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} Nonces {} Amounts {} (SemiFungible) to the Launchpad from {}" [asset-id nonces amounts sa])]
                [(format "Succesfully fueled {} Nonces {} to the Launchpad from {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitSemiFungibles client asset-id nonces amounts true)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [amounts])
        ))
    (defun INFO_DEMIPAD|RetrieveSemiFungible:object{OuronetInfoV3.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} Nonces {} Amounts {} (SemiFungible) from the Launchpad to {}" [asset-id nonces amounts sa])]
                [(format "Succesfully retrieved {} Nonces {} from the Launchpad to {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitSemiFungibles client asset-id nonces amounts false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [amounts])
        ))
    (defun INFO_DEMIPAD|FuelNonFungible:object{OuronetInfoV3.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Fuels {} Nonces {} (NonFungible) to the Launchpad from {}" [asset-id nonces sa])]
                [(format "Succesfully fueled {} Nonces {} to the Launchpad from {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitNonFungibles client asset-id nonces amounts true)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])
        ))
    (defun INFO_DEMIPAD|RetrieveNonFungible:object{OuronetInfoV3.ClientInfo} (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Retrieves {} Nonces {} (NonFungible) from the Launchpad to {}" [asset-id nonces sa])]
                [(format "Succesfully retrieved {} Nonces {} from the Launchpad to {}" [asset-id nonces sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DEMIPAD::URCi_TransmitNonFungibles client asset-id nonces amounts false)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [nonces])
        ))
    ;;
    ;;  [EQUITY] — shareholder/company SFT collection (exposed via DPSF Talos)
    (defun INFO_EQUITY|IssueCompany:object{OuronetInfoV3.ClientInfo} (patron:string creator-account:string collection-name:string)
        ;;MISSING STOA LEG FIXED (2026-09-14). This reported `OI|UDC_NoStoaCosts` -- a LITERAL ZERO,
        ;;rendered to the client as "Operation is free of native Stoa (STOA)". It is not free. The
        ;;exec charges TWO currencies (`01_TS02-C1.pact:1556-1560`):
        ;;    (ref-IGNIS::XE_CollectIgnis patron ico)
        ;;    (ref-IGNIS::XE_CollectStoa patron (ref-IGNIS::UC_StoaPrice "issue-shareholder"))
        ;;with the source comment "Issuing a COMPANY is $100 in IGNIS deter and $100 in STOA (spec)".
        ;;
        ;;MEASURED, not inferred: a live `DPSF|C_IssueCompany` charged **918.0 STOA** while this
        ;;preview reported **0.0**. The IGNIS leg was already correct (6965.26 predicted == charged),
        ;;which is why the gap survived -- half the quote was right.
        ;;
        ;;A UI showing this preview told the user an Equity issue cost no STOA at all.
        ;;
        ;;THE CHARGE HAS TWO LEGS, which is why a first repair reporting only the premium still came
        ;;up short (765 quoted vs 918 charged). `DPDC-I::C_IssueDigitalCollection` runs its OWN
        ;;`XE_CollectStoa patron (URCi_IssueCollectionStoa son)` at `04_DPDC-I.pact:502`, nested
        ;;inside `C_IssueShareholderCollection`, and the Talos wrapper then adds the equity premium
        ;;on top. `11_EQUITY+.pact:385` already said so -- "the collection-issue STOA price previews
        ;;SEPARATELY via DPDC-I::URCi_IssueCollectionStoa" -- but nothing ever added the two together
        ;;for the client. Both legs are summed here, raw, before the patron discount is applied.
        ;;Pinned by REPL/modules/EQUITY.repl <<EQ-I1>>, which asserts BOTH currencies against a
        ;;measured charge.
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPDC-I:module{DpdcIssueV3} DPDC-I)
                (ref-EQUITY:module{EquityV5} EQUITY)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount creator-account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Issues the 8-element Shareholder (Equity) SFT Collection '{}' on Account {}" [collection-name sa])]
                [(format "Shareholder Collection '{}' issued succesfully on Account {}" [collection-name sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-EQUITY::URCi_IssueShareholderCollection)))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron
                    (+ (ref-DPDC-I::URCi_IssueCollectionStoa true)
                       (ref-IGNIS::UC_StoaPrice "issue-shareholder"))) [])
        ))
    (defun INFO_EQUITY|MorphEquity:object{OuronetInfoV3.ClientInfo} (patron:string account:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-EQUITY:module{EquityV5} EQUITY)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Morphs {} shares of {} Nonce {} into Nonce {} on Account {}" [input-amount id input-nonce output-nonce sa])]
                [(format "Succesfully morphed {} {} Nonce {} shares into Nonce {} on {}" [input-amount id input-nonce output-nonce sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-EQUITY::URCi_MorphPackageShares account id input-nonce input-amount output-nonce)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts) [])
        ))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)


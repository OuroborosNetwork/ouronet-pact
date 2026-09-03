;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageTwo_ClientTwoV2
    @doc "Exposes Stage Two Second Batch of Client Functions: \
        \ the NonFungible Client Functions"

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
    (defun C_DPNF|UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun C_DPNF|UpgradeBranding (patron:string entity-id:string months:integer))
    ;;
    ;;  [3] DPDC-C
    ;;
    (defun C_DPNF|Create:string
        (
            patron:string id:string
            input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}]
        )
    )
    ;;
    ;;  [4] DPDC-I
    ;;
    ;; DPNF|C_DeployAccount removed — DPDC Audit #35M: standalone deployment let any signer force any
    ;; existing account to associate with any collection, with no ownership check. Real auto-association
    ;; (on transfer, role-toggle, Issue, set-fragmentation) always calls DPDC::XB_DeployAccountNFT
    ;; directly, module-to-module, bypassing this public entrypoint entirely.
    (defun C_DPNF|Issue:string
        (
            patron:string 
            owner-account:string creator-account:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
        )
    )
    ;;
    ;;  [5] DPDC-R
    ;;
    (defun C_DPNF|ToggleFreezeAccount (patron:string id:string account:string toggle:bool))
    (defun C_DPNF|ToggleExemptionRole (patron:string id:string account:string toggle:bool))
    (defun C_DPNF|ToggleBurnRole (patron:string id:string account:string toggle:bool))
    (defun C_DPNF|ToggleUpdateRole (patron:string id:string account:string toggle:bool))
    (defun C_DPNF|ToggleModifyCreatorRole (patron:string id:string account:string toggle:bool))
    (defun C_DPNF|ToggleModifyRoyaltiesRole (patron:string id:string account:string toggle:bool))
    (defun C_DPNF|ToggleTransferRole (patron:string id:string account:string toggle:bool))
    (defun C_DPNF|MoveCreateRole (patron:string id:string new-account:string))
    (defun C_DPNF|MoveRecreateRole (patron:string id:string new-account:string))
    (defun C_DPNF|MoveSetUriRole (patron:string id:string new-account:string))
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun C_DPNF|Control (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool))
    (defun C_DPNF|TogglePause (patron:string id:string toggle:bool))
        ;;
    (defun C_DPNF|Respawn (patron:string id:string account:string nonce:integer))
    (defun C_DPNF|Burn (patron:string id:string account:string nonce:integer))
    (defun C_DPNF|WipeNonce (patron:string id:string account:string nonce:integer))
        ;;
    (defun C_DPNF|WipeHeavy (patron:string account:string id:string))
    (defun C_DPNF|WipePure (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces}))
    (defun C_DPNF|WipeClean (patron:string account:string id:string nonces:[integer]))
    (defun C_DPNF|WipeDirty (patron:string account:string id:string nonces:[integer]))
    ;;
    ;;  [7] DPDC-T
    ;;
    (defun C_DPNF|Repurpose (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer]))
    (defun C_DPNF|TransferNonce (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool))
    (defun C_DPNF|TransferNonces (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool)) 
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun C_DPNF|Make (patron:string account:string id:string nonces:[integer] set-class:integer))
    (defun C_DPNF|Break (patron:string account:string id:string nonce:integer))
    (defun C_DPNF|DefinePrimordialSet 
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun C_DPNF|DefineCompositeSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun C_DPNF|DefineHybridSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun C_DPNF|EnableSetClassFragmentation
        (
            patron:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun C_DPNF|ToggleSet (patron:string id:string set-class:integer toggle:bool))
    (defun C_DPNF|RenameSet (patron:string id:string set-class:integer new-name:string))
    ;; DPNF|C_UpdateSetMultiplier removed — DPDC Audit #15H: score-multiplier is immutable after Define.
    ;;
    (defun C_DPNF|UpdateSetNonce                        (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}))
    (defun C_DPNF|UpdateSetNonces                       (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]))
    (defun C_DPNF|UpdateSetNonceRoyalty                 (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal))
    (defun C_DPNF|UpdateSetNonceIgnisRoyalty            (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal))
    (defun C_DPNF|UpdateSetNonceName                    (patron:string id:string account:string set-class:integer nos:bool name:string))
    (defun C_DPNF|UpdateSetNonceDescription             (patron:string id:string account:string set-class:integer nos:bool description:string))
    (defun C_DPNF|UpdateSetNonceScore                   (patron:string id:string account:string set-class:integer nos:bool score:decimal))
    (defun C_DPNF|RemoveSetNonceScore                   (patron:string id:string account:string set-class:integer nos:bool))
    (defun C_DPNF|UpdateSetNonceMetaData                (patron:string id:string account:string set-class:integer nos:bool meta-data:object))
    (defun C_DPNF|UpdateSetNonceURI                     (patron:string id:string account:string set-class:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}))
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun C_DPNF|RepurposeFragments (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer]))
    (defun C_DPNF|MakeFragments (patron:string account:string id:string nonce:integer amount:integer))
    (defun C_DPNF|MergeFragments (patron:string account:string id:string nonce:integer amount:integer))
    (defun C_DPNF|EnableNonceFragmentation (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}))
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun C_DPNF|UpdateNonce                           (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}))
    (defun C_DPNF|UpdateNonces                          (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]))
    (defun C_DPNF|UpdateNonceRoyalty                    (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal))
    (defun C_DPNF|UpdateNonceIgnisRoyalty               (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal))
    (defun C_DPNF|UpdateNonceName                       (patron:string id:string account:string nonce:integer nos:bool name:string))
    (defun C_DPNF|UpdateNonceDescription                (patron:string id:string account:string nonce:integer nos:bool description:string))
    (defun C_DPNF|UpdateNonceScore                      (patron:string id:string account:string nonce:integer nos:bool score:decimal))
    (defun C_DPNF|RemoveNonceScore                      (patron:string id:string account:string nonce:integer nos:bool))
    (defun C_DPNF|UpdateNonceMetaData                   (patron:string id:string account:string nonce:integer nos:bool meta-data:object))
    (defun C_DPNF|UpdateNonceURI                        (patron:string id:string account:string nonce:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}))
    (defun C_DPNF|BulkTransfer
        (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
    )

)
;;
(module TS02-C2 GOV
    @doc "TALOS Stage 2 Client Functiones Part 2 - NFT Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_ClientTwoV2)

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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
        (with-capability (GOV|TS02-C2_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|TS02-C2_ADMIN)
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
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
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
    (defun C_DPNF|UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPNF Token <entity-id> costing 500 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC::C_UpdatePendingBranding entity-id false logo description website social)
                )
            )
        )
    )
    (defun C_DPNF|UpgradeBranding (patron:string entity-id:string months:integer)
        @doc "Upgrades Branding for DPNF Token, making it a premium BrandingV2. \
            \ Also sets pending-branding to live branding if its branding is not live yet"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DPDC::C_UpgradeBranding patron entity-id false months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    ;;
    ;;  [3] DPDC-C
    ;;
    (defun C_DPNF|Create:string
        (
            patron:string id:string
            input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}]
        )
        @doc "Creates a new NFT Collection Element(s), having a new nonce, \
            \ of amount 1, on the <creator> account."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    (l:integer (length input-nonce-data))
                    (ico:object{IgnisCollectorV2.OutputCumulator}
                        (if (= l 1)
                            (ref-DPDC-C::C_CreateNewNonce
                                id false 0 1 (at 0 input-nonce-data) false
                            )
                            (ref-DPDC-C::C_CreateNewNonces
                                id false (make-list l 1) input-nonce-data
                            )
                        )
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
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
    (defun C_DPNF|Issue:string
        (
            patron:string 
            owner-account:string creator-account:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
        )
        @doc "Issues a new DPNF (Demiourgos Pact Non-Fungible) Digital Collection: <NFT> \
            \ Costs 10x<ignis|token-issue> = 5000 IGNIS and 500 STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-I:module{DpdcIssueV2} DPDC-I)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV2.OutputCumulator}
                        (ref-DPDC-I::C_IssueDigitalCollection
                            patron false 
                            owner-account creator-account collection-name collection-ticker
                            can-upgrade can-change-owner can-change-creator can-add-special-role
                            can-transfer-nft-create-role can-freeze can-wipe can-pause
                            false
                        )
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at 0 (at "output" ico))
            )
        )
    )
    ;;
    ;;  [5] DPDC-R
    ;;
    (defun C_DPNF|ToggleFreezeAccount (patron:string id:string account:string toggle:bool)
        @doc "Freezes a given account for a given DPNF Token. Frozen Accounts can no longer send or receive that DPNF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-R::C_ToggleFreezeAccount id false account toggle)
                )
            )
        )
    )
    (defun C_DPNF|ToggleExemptionRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles exemption Role for a given DPNF on a given Smart Ouronet Account (Only Smart Ouronet Accounts can accept this role) \
            \ When sending to or receiving from such Accounts, the flat IGNIS Royalty fee must not be paid."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-R::C_ToggleExemptionRole id false account toggle)
                )
            )
        )
    )
    (defun C_DPNF|ToggleBurnRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles burn Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can then burn the DPNF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-R::C_ToggleBurnRole id false account toggle)
                )
            )
        )
    )
    (defun C_DPNF|ToggleUpdateRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles update Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can then update (modify) the Metadata on any DPNF nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-R::C_ToggleUpdateRole id false account toggle)
                )
            )
        )
    )
    (defun C_DPNF|ToggleModifyCreatorRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles Modify Creator Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Creator of the DPNF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-R::C_ToggleModifyCreatorRole id false account toggle)
                )
            )
        )
    )
    (defun C_DPNF|ToggleModifyRoyaltiesRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles Modify Royalties Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Permille Royalty of any nonce in the  DPNF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-R::C_ToggleModifyRoyaltiesRole id false account toggle)
                )
            )
        )
    )
    (defun C_DPNF|ToggleTransferRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles Transfer Role for a given DPNF on any Ouronet Account. \
            \ Transfers for any Nonce in the DPNF Collection are then restricted only to and from these accounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-R::C_ToggleTransferRole id false account toggle)
                )
            )
        )
    )
    (defun C_DPNF|MoveCreateRole (patron:string id:string new-account:string)
        @doc "Moves the Create Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can issue new NFTs in the Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-R::C_MoveCreateRole id false new-account)
                )
            )
        )
    )
    (defun C_DPNF|MoveRecreateRole (patron:string id:string new-account:string)
        @doc "Moves the Recreate Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can recreate any existing NFT in the Collection \
            \ Recreation reffers to a complete update (modification) of all NFT properties of a given nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-R::C_MoveRecreateRole id false new-account)
                )
            )
        )
    )
    (defun C_DPNF|MoveSetUriRole (patron:string id:string new-account:string)
        @doc "Moves the Set URI Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can modify the URIs of any nonce in the NFT Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-R::C_MoveSetUriRole id false new-account)
                )
            )
        )
    )
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun C_DPNF|Control (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        @doc "Controls DPNF Properties"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-MNG::C_Control id false cu cco ccc casr ctncr cf cw cp)
                )
            )
        )
    )
    (defun C_DPNF|TogglePause (patron:string id:string toggle:bool)
        @doc "Pauses a DPNF Collection. Paused Collections can no longer be transfered"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-MNG::C_TogglePause id false toggle)
                )
            )
        )
    )
    (defun C_DPNF|Respawn (patron:string id:string account:string nonce:integer)
        @doc "Respawns NFT <id> <nonce> on <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-MNG::C_RespawnNFT account id nonce)
                )
                (format "Succesfuly respawned NFT {} Nonce {} on Account {}" [id nonce (UC_ShortAccount account)])
            )
        )
    )
    (defun C_DPNF|Burn (patron:string id:string account:string nonce:integer)
        @doc "Burns NFT <id> <nonce> on <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-MNG::C_BurnNFT account id nonce)
                )
                (format "Succesfuly burned NFT {} Nonce {} on Account {}" [id nonce (UC_ShortAccount account)])
            )
        )
    )
    (defun C_DPNF|WipeNonce (patron:string id:string account:string nonce:integer)
        @doc "Wipes NFT <id> <nonce> on <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-MNG::C_WipeNonce account id false nonce)
                )
                (format "Succesfuly wiped NFT {} Nonce {} from Account {}" [id nonce (UC_ShortAccount account)])
            )
        )
    )
    (defun C_DPNF|WipeHeavy (patron:string account:string id:string)
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV2.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeHeavy account id false)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::C_Collect patron ico)
                (format 
                    "Succesfuly executed Heavy Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun C_DPNF|WipePure (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV2.OutputCumulator}
                        (ref-DPDC-MNG::C_WipePure account id false removable-nonces-obj) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::C_Collect patron ico)
                (format 
                    "Succesfuly executed Pure Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun C_DPNF|WipeClean (patron:string account:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV2.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeClean account id false nonces) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::C_Collect patron ico)
                (format 
                    "Succesfuly executed Clean Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun C_DPNF|WipeDirty (patron:string account:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV2.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeDirty account id false nonces)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::C_Collect patron ico)
                (format 
                    "Succesfuly executed Dirty Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    ;;
    ;;  [7] DPDC-T
    ;;
    (defun C_DPNF|Repurpose (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose NFT(s) from <repurpose-from> to <repurpose-to>. Requires <id> ownerhsip"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-T::C_RepurposeCollectable id false repurpose-from repurpose-to nonces amounts)
                )
                (format "Successfully repurposed NFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun C_DPNF|TransferNonce (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool)
        @doc "Transfer an NFT <nonce> of <amount> from <sender> to <receiver> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron sender [id] [false] [[nonce]] [[amount]])
                    )
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-T::C_Transfer [id] [false] sender receiver [[nonce]] [[amount]] method)
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
    (defun C_DPNF|TransferNonces (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool)
        @doc "Transfer an NFT <nonce> of <amount> from <sender> to <receiver> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron sender [id] [false] [nonces] [amounts])
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-T::C_Transfer [id] [false] sender receiver [nonces] [amounts] method)
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
    (defun C_DPNF|BulkTransfer
        (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        @doc "Bulk NFT transfer — son=false wrapper over TS02-C1.C_DPDC|BulkTransfer."
        (let
            (
                (ref-TS02-C1:module{TalosStageTwo_ClientOneV2} TS02-C1)
            )
            (ref-TS02-C1::C_DPDC|BulkTransfer patron id false nonces-array amounts-array sender receiver-lst method)
        )
    )
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun C_DPNF|Make
        (patron:string account:string id:string nonces:[integer] set-class:integer)
        @doc "Makes a Set NFT of Class <set-class>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                    (nonce:integer (+ 1 (ref-DPDC::UR_NoncesUsed id false)))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-S::C_MakeNonFungibleSet account id nonces set-class)
                )
                (format "Successfully generated Class {} Set (Nonce {}) of NFT Collection {} on Account {}" [set-class nonce id sa])
            )
        )
    )
    (defun C_DPNF|Break
        (patron:string account:string id:string nonce:integer)
        @doc "Brakes an NFT Nonce representing an NFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (set-class:integer (ref-DPDC::UR_NonceClass id false nonce))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-S::C_BreakNonFungibleSet account id nonce)
                )
                (format "Successfully broken Class {} Set (Nonce {}) of NFT Collection {} on Account {}" [set-class nonce id sa])
            )
        )
    )
    (defun C_DPNF|DefinePrimordialSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Primordial NFT Set. Primordial Sets are composed of Class 0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-S::C_DefinePrimordialSet id false set-name score-multiplier set-definition ind)
                )
                (format "Primordial Set <{}> for NFT Collection {} defined succesfully" [set-name id])
            )
        )
    )
    (defun C_DPNF|DefineCompositeSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Composite NFT Set. Composite Sets are composed of Class (!=0) Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-S::C_DefineCompositeSet id false set-name score-multiplier set-definition ind)
                )
                (format "Composite Set <{}> for NFT Collection {} defined succesfully" [set-name id])
            )
        )
    )
    (defun C_DPNF|DefineHybridSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Hybrid NFT Set. Hybrid Sets are composed of both Class 0 and Non-0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-S::C_DefineHybridSet id false set-name score-multiplier primordial-sd composite-sd ind)
                )
                (format "Hybrid Set <{}> for NFT Collection {} defined succesfully" [set-name id])
            )
        )
    )
    (defun C_DPNF|EnableSetClassFragmentation
        (
            patron:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Enables Fragmentation for a given Set Class. This allows all NFTs of the given Set Class to be Fragmented"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-S::C_EnableSetClassFragmentation id false set-class fragmentation-ind)
                )
                (format "Set Class {} for NFT {} succesfully fragmented" [set-class id])
            )
        )
    )
    (defun C_DPNF|ToggleSet (patron:string id:string set-class:integer toggle:bool)
        @doc "Enables or Disables a Set. A disabled Set allows only for decomposition of Set Elements, but not for composition"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-S::C_ToggleSet id false set-class toggle)
                )
                (format "NFT {} Set Class {} succesfully turned {}" [id set-class (if toggle "ON" "OFF")])
            )
        )
    )
    (defun C_DPNF|RenameSet (patron:string id:string set-class:integer new-name:string)
        @doc "Renames an NFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-S::C_RenameSet id false set-class new-name)
                )
                (format "NFT {} Set Class {} succesfuly renamed to <{}>" [id set-class new-name])
            )
        )
    )
    ;; DPNF|C_UpdateSetMultiplier removed — DPDC Audit #15H.
    ;;
    (defun C_DPNF|UpdateSetNonce 
        (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonces id false account [set-class] nos false [new-nonce-data])
                )
            )
        )
    )
    (defun C_DPNF|UpdateSetNonces
        (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonces id false account set-classes nos false new-nonces-data)
                )
            )
        )
    )
    (defun C_DPNF|UpdateSetNonceRoyalty
        (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Set Nonce Native Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty id false account set-class nos false royalty-value)
                )
            )
        )
    )
    (defun C_DPNF|UpdateSetNonceIgnisRoyalty
        (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Set Nonce IGNIS Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty id false account set-class nos false royalty-value)
                )
            )
        )
    )
    (defun C_DPNF|UpdateSetNonceName
        (patron:string id:string account:string set-class:integer nos:bool name:string)
        @doc "[3] Updates Set Nonce Name, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceName id false account set-class nos false name)
                )
            )
        )
    )
    (defun C_DPNF|UpdateSetNonceDescription
        (patron:string id:string account:string set-class:integer nos:bool description:string)
        @doc "[4] Updates Set Nonce Description, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceDescription id false account set-class nos false description)
                )
            )
        )
    )
    (defun C_DPNF|UpdateSetNonceScore
        (patron:string id:string account:string set-class:integer nos:bool score:decimal)
        @doc "[5] Updates Set Nonce Score, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceScore id false account set-class nos false score)
                )
            )
        )
    )
    (defun C_DPNF|RemoveSetNonceScore (patron:string id:string account:string set-class:integer nos:bool)
        @doc "[5b] Removes Set Nonce Score, setting it to -1.0, either Native or Split, for an NFT"
        (C_DPNF|UpdateNonceScore patron id account set-class nos -1.0)
    )
    (defun C_DPNF|UpdateSetNonceMetaData
        (patron:string id:string account:string set-class:integer nos:bool meta-data:object)
        @doc "[6] Updates Set Nonce Meta-Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceMetaData id false account set-class nos false meta-data)
                )
            )
        )
    )
    (defun C_DPNF|UpdateSetNonceURI
        (
            patron:string id:string account:string set-class:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Set Nonce URI, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceURI id false account set-class nos false ay u1 u2 u3)
                )
            )
        )
    )
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun C_DPNF|RepurposeFragments (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose NFT Fragment(s) from <repurpose-from> to <repurpose-to>. Requires <id> ownerhsip"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::C_Collect patron
                    ;; #79: this is the NFT (C_DPNF|) wrapper — son MUST be false. Was hardcoded `true`
                    ;; (SFT), so it read CNF from the DPSF table and failed. Never caught: no test coverage.
                    (ref-DPDC-F::C_RepurposeCollectableFragments id false repurpose-from repurpose-to nonces amounts)
                )
                (format "Successfully repurposed NFT {} Fragment-Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun C_DPNF|MakeFragments (patron:string account:string id:string nonce:integer amount:integer)
        @doc "Fragments NFT nonce of the given amount into its respective Fragments."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-F::C_MakeFragments account id false nonce amount)
                )
                (format "Succesfuly Fragmented {} NFT(s) {} of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun C_DPNF|MergeFragments (patron:string account:string id:string nonce:integer amount:integer)
        @doc "MErges NFT Fragments nonces of the given amount into the original NFT nonce."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-F::C_MergeFragments account id false nonce amount)
                )
                (format "Succesfuly merged {} {} NFT(s) Fragments of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun C_DPNF|EnableNonceFragmentation (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        @doc "Enables Fragmentation for a given NFT Nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-F::C_EnableNonceFragmentation id false nonce fragmentation-ind)
                )
                (format "Fragmentation for NFT {} Nonce {} enabled succesfully" [id nonce])
            )
        )
    )
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun C_DPNF|UpdateNonce 
        (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonces id false account [nonce] nos true [new-nonce-data])
                )
                (format "Nonce {} updated successfully!" [nonce])
            )
        )
    )
    (defun C_DPNF|UpdateNonces
        (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonces id false account nonces nos true new-nonces-data)
                )
                (format "Nonces {} updated successfully!" [nonces])
            )
        )
    )
    (defun C_DPNF|UpdateNonceRoyalty
        (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Nonce Native Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty id false account nonce nos true royalty-value)
                )
            )
        )
    )
    (defun C_DPNF|UpdateNonceIgnisRoyalty
        (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Nonce IGNIS Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty id false account nonce nos true royalty-value)
                )
            )
        )
    )
    (defun C_DPNF|UpdateNonceName
        (patron:string id:string account:string nonce:integer nos:bool name:string)
        @doc "[3] Updates Nonce Name, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceName id false account nonce nos true name)
                )
            )
        )
    )
    (defun C_DPNF|UpdateNonceDescription
        (patron:string id:string account:string nonce:integer nos:bool description:string)
        @doc "[4] Updates Nonce Description, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceDescription id false account nonce nos true description)
                )
            )
        )
    )
    (defun C_DPNF|UpdateNonceScore
        (patron:string id:string account:string nonce:integer nos:bool score:decimal)
        @doc "[5] Updates Nonce Score, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceScore id false account nonce nos true score)
                )
            )
        )
    )
    (defun C_DPNF|RemoveNonceScore (patron:string id:string account:string nonce:integer nos:bool)
        @doc "[5b] Removes Nonce Score, setting it to -1.0, either Native or Split, for an NFT"
        (C_DPNF|UpdateNonceScore patron id account nonce nos -1.0)
    )
    (defun C_DPNF|UpdateNonceMetaData
        (patron:string id:string account:string nonce:integer nos:bool meta-data:object)
        @doc "[6] Updates Nonce Meta-Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceMetaData id false account nonce nos true meta-data)
                )
            )
        )
    )
    (defun C_DPNF|UpdateNonceURI
        (
            patron:string id:string account:string nonce:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Nonce URI, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPDC-N::C_UpdateNonceURI id false account nonce nos true ay u1 u2 u3)
                )
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)
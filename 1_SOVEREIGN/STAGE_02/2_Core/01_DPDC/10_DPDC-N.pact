;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/02_Core.pact
;;
(interface DpdcNonceV1
    @doc "Exposes Collectables Nonce Management related Functions"
    ;;
    ;; [UR]
    ;;
    (defun UR_Nonce:object{DpdcUdcV1.DPDC|NonceData} (id:string son:bool nosc:integer nos:bool nost:bool))
    ;;
    ;; [UEV]
    ;;
    (defun UEV_NonceDataUpdater (id:string son:bool account:string nosc:integer nos:bool nost:bool))
    (defun UEV_RoleNftRecreateON (id:string son:bool account:string))
    (defun UEV_RoleNftUpdateON (id:string son:bool account:string))
    (defun UEV_RoleModifyRoyaltiesON (id:string son:bool account:string))
    (defun UEV_RoleSetNewUriON (id:string son:bool account:string))
    (defun UEV_Score (score:decimal))
    ;;
    ;; [C]
    ;;
    (defun C_UpdateNonces               (id:string son:bool account:string nosc:[integer] nos:bool nost:bool new-nonces-data:[object{DpdcUdcV1.DPDC|NonceData}]))
    (defun C_UpdateNonceRoyalty         (id:string son:bool account:string nosc:integer nos:bool nost:bool royalty-value:decimal))
    (defun C_UpdateNonceIgnisRoyalty    (id:string son:bool account:string nosc:integer nos:bool nost:bool royalty-value:decimal))
    (defun C_UpdateNonceName            (id:string son:bool account:string nosc:integer nos:bool nost:bool name:string))
    (defun C_UpdateNonceDescription     (id:string son:bool account:string nosc:integer nos:bool nost:bool description:string))
    (defun C_UpdateNonceScore           (id:string son:bool account:string nosc:integer nos:bool nost:bool score:decimal))
    (defun C_UpdateNonceMetaData        (id:string son:bool account:string nosc:integer nos:bool nost:bool meta-data:object))
    (defun C_UpdateNonceURI             (id:string son:bool account:string nosc:integer nos:bool nost:bool ay:object{DpdcUdcV1.URI|Type} u1:object{DpdcUdcV1.URI|Data} u2:object{DpdcUdcV1.URI|Data} u3:object{DpdcUdcV1.URI|Data}))
    ;;
    ;;  [URCi]
    ;;
    (defun URCi_UpdateNonces:object{IgnisCollectorV1.OutputCumulator} (account:string count:integer))
    (defun URCi_UpdateNonceField:object{IgnisCollectorV1.OutputCumulator} (account:string))
)
;;
(module DPDC-N GOV

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV1)
    (implements DpdcNonceV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPDC-N                 (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                          (compose-capability (GOV|DPDC-N_ADMIN)))
    (defcap GOV|DPDC-N_ADMIN ()             (enforce-guard GOV|MD_DPDC-N))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                   (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P4}  capabilities
    (defcap P|DPDC-N|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPDC-N|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                   (CT_Bar))
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
        (id:string son:bool account:string nosc:[integer] nos:bool nost:bool new-nonces-data:[object{DpdcUdcV1.DPDC|NonceData}])
        @doc "[0] Controls Full Noce Updating, for multiple Nonces at a time"
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
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
                (ref-DPDC:module{DpdcV1} DPDC)
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
                (ref-DPDC:module{DpdcV1} DPDC)
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
                (ref-DPDC:module{DpdcV1} DPDC)
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
                (ref-DPDC:module{DpdcV1} DPDC)
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
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (ref-DPDC::UEV_MetaDataBag meta-data)     ;; DPDC Audit #12Hb
            (compose-capability (DPDC-N|C>UPDATE id son account nosc nos nost))
        )
    )
    (defcap DPDC-N|C>SET-URI
        (
            id:string son:bool account:string nosc:integer nos:bool nost:bool
            ay:object{DpdcUdcV1.URI|Type} u1:object{DpdcUdcV1.URI|Data}
            u2:object{DpdcUdcV1.URI|Data} u3:object{DpdcUdcV1.URI|Data}
        )
        @doc "[7] Controls Nonce Uri Updating"
        @event
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
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
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPDC-C:module{DpdcCreateV1} DPDC-C)
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
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_Nonce:object{DpdcUdcV1.DPDC|NonceData}
        (id:string son:bool nosc:integer nos:bool nost:bool)
        @doc "nosc = <Nonce-Or-Set-Class> ; value of either a Nonce or Set-Class \
            \ nos  = <Native-Or-Split>    ; designates either native or split for Nonce-Data \
            \ nost = <NoNCe-Or-SET>       ; designates if <nosc> is either a <nonce> or <set-class> value"
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-S:module{DpdcSetsV1} DPDC-S)
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
    (defun URCi_UpdateNonces:object{IgnisCollectorV1.OutputCumulator}
        (account:string count:integer)
        @doc "Cost preview for C_UpdateNonces (count * UsagePrice ignis|smallest; \
            \ construct with empty output list)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (price:decimal (* (dec count) (ref-DALOS::UR_UsagePrice "ignis|smallest")))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price account (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateNonceField:object{IgnisCollectorV1.OutputCumulator}
        (account:string)
        @doc "Cost preview for the single-field nonce updates (Royalty, IgnisRoyalty, \
            \ Name, Description, Score, MetaData, URI) — all flat Small(account)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-IGNIS::UDC_SmallCumulator account)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun UEV_NonceDataUpdater
        (id:string son:bool account:string nosc:integer nos:bool nost:bool)
        (enforce (> nosc 0) "Operation requires greater than zero <nonce-or-set-class>")
        (if nost
            ;;Nonce
            (let
                (
                    (ref-DPDC:module{DpdcV1} DPDC)
                    (ref-DPDC-F:module{DpdcFragmentsV1} DPDC-F)
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
                    (ref-DPDC-S:module{DpdcSetsV1} DPDC-S)
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
                    (ref-DPDC:module{DpdcV1} DPDC)
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
                (ref-DPDC:module{DpdcV1} DPDC)
                (x:bool (ref-DPDC::UR_CA|R-Recreate id son account))
            )
            (enforce x (format "{} Collection {} Element Data cannot be Updated while using the {} Ouronet Account" [(if son "SFT" "NFT") id account]))
        )
    )
    (defun UEV_RoleNftUpdateON (id:string son:bool account:string)
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (x:bool (ref-DPDC::UR_CA|R-Update id son account))
            )
            (enforce x (format "{} Collection {} Element Data cannot be Updated while using the {} Ouronet Account" [(if son "SFT" "NFT") id account]))
        )
    )
    (defun UEV_RoleModifyRoyaltiesON (id:string son:bool account:string)
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (x:bool (ref-DPDC::UR_CA|R-ModifyRoyalties id son account))
            )
            (enforce x (format "{} Collection {} Element Data Royalties cannot be Updated while using the {} Ouronet Account" [(if son "SFT" "NFT") id account]))
        )
    )
    (defun UEV_RoleSetNewUriON (id:string son:bool account:string)
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
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
    (defun XI_U|NoncesData
        (id:string son:bool account:string nosc:[integer] nos:bool nost:bool new-nonce-data:[object{DpdcUdcV1.DPDC|NonceData}])
        (require-capability (SECURE))
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-S:module{DpdcSetsV1} DPDC-S)
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
    (defun XI_U|NonceRoyalty
        (id:string son:bool account:string nosc:integer nos:bool nost:bool r-or-ir:bool royalty-value:decimal)
        (require-capability (SECURE))
        (let
            (
                (read-nonce-data:object{DpdcUdcV1.DPDC|NonceData} (UR_Nonce id son nosc nos nost))
                (new-nonce-data:object{DpdcUdcV1.DPDC|NonceData}
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
    (defun XI_U|NonceNoD 
        (id:string son:bool account:string nosc:integer nos:bool nost:bool name-or-description:bool name-description:string)
        (require-capability (SECURE))
        (let
            (
                (read-nonce-data:object{DpdcUdcV1.DPDC|NonceData} (UR_Nonce id son nosc nos nost))
                (new-nonce-data:object{DpdcUdcV1.DPDC|NonceData}
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
    (defun XI_U|NonceScore
        (id:string son:bool account:string nosc:integer nos:bool nost:bool score:decimal)
        (require-capability (SECURE))
        (let
            (
                (read-nonce-data:object{DpdcUdcV1.DPDC|NonceData} (UR_Nonce id son nosc nos nost))
                (read-md:object{DpdcUdcV1.NonceMetaData} (at "meta-data" read-nonce-data))
                ;;
                (updated-md:object{DpdcUdcV1.NonceMetaData}
                    (+
                        {"score" : score}
                        (remove "score" read-md)
                    )
                )
                (new-nonce-data:object{DpdcUdcV1.DPDC|NonceData}
                    (+
                        {"meta-data" : updated-md}
                        (remove "meta-data" read-nonce-data)
                    )
                )
            )
            (XI_U|NoncesData id son account [nosc] nos nost [new-nonce-data])
        )
    )
    (defun XI_NonceMetaData 
        (id:string son:bool account:string nosc:integer nos:bool nost:bool meta-data:object)
        (require-capability (SECURE))
        (let
            (
                (read-nonce-data:object{DpdcUdcV1.DPDC|NonceData} (UR_Nonce id son nosc nos nost))
                (read-md:object{DpdcUdcV1.NonceMetaData} (at "meta-data" read-nonce-data))
                ;;
                (updated-md:object{DpdcUdcV1.NonceMetaData}
                    (+
                        {"meta-data" : meta-data}
                        (remove "meta-data" read-md)
                    )
                )
                (new-nonce-data:object{DpdcUdcV1.DPDC|NonceData}
                    (+
                        {"meta-data" : updated-md}
                        (remove "meta-data" read-nonce-data)
                    )
                )
            )
            (XI_U|NoncesData id son account [nosc] nos nost [new-nonce-data])
        )
    )
    (defun XI_U|NonceUri
        (
            id:string son:bool account:string nosc:integer nos:bool nost:bool
            ay:object{DpdcUdcV1.URI|Type} u1:object{DpdcUdcV1.URI|Data} u2:object{DpdcUdcV1.URI|Data} u3:object{DpdcUdcV1.URI|Data}
        )
        (require-capability (SECURE))
        (let
            (
                (read-nonce-data:object{DpdcUdcV1.DPDC|NonceData} (UR_Nonce id son nosc nos nost))
                (new-nonce-data:object{DpdcUdcV1.DPDC|NonceData}
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
    (defun A_P|Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DPDC-N_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun A_P|AddIMP (policy-guard:guard)
        (with-capability (GOV|DPDC-N_ADMIN)
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
    (defun A_P|Define ()
        (let
            (
                (ref-P|DPDC:module{OuronetPolicyV1} DPDC)
                (ref-P|DPDC-S:module{OuronetPolicyV1} DPDC-S)
                (mg:guard (create-capability-guard (P|DPDC-N|CALLER)))
            )
            (ref-P|DPDC::A_P|AddIMP mg)
            (ref-P|DPDC-S::A_P|AddIMP mg)
        )
    )
    (defun C_UpdateNonces
        (id:string son:bool account:string nosc:[integer] nos:bool nost:bool new-nonces-data:[object{DpdcUdcV1.DPDC|NonceData}])
        @doc "[0] Updates Full Nonce Data for multiple Nonces at a time"
        (UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (smallest:decimal (ref-DALOS::UR_UsagePrice "ignis|smallest"))
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
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (DPDC-N|C>SET-ROYALTY id son account nosc nos nost royalty-value)
                (XI_U|NonceRoyalty id son account nosc nos nost true royalty-value)
                (URCi_UpdateNonceField account)
            )
        )
    )
    (defun C_UpdateNonceIgnisRoyalty
        (id:string son:bool account:string nosc:integer nos:bool nost:bool royalty-value:decimal)
        @doc "[2] Updates Nonce Ignis Royalty Value"
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (DPDC-N|C>SET-IGNIS-ROYALTY id son account nosc nos nost royalty-value)
                (XI_U|NonceRoyalty id son account nosc nos nost false royalty-value)
                (URCi_UpdateNonceField account)
            )
        )
    )
    (defun C_UpdateNonceName
        (id:string son:bool account:string nosc:integer nos:bool nost:bool name:string)
        @doc "[3] Updates Nonce Name"
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (DPDC-N|C>SET-NAME id son account nosc nos nost name)
                (XI_U|NonceNoD id son account nosc nos nost true name)
                (URCi_UpdateNonceField account)
            )
        )
    )
    (defun C_UpdateNonceDescription
        (id:string son:bool account:string nosc:integer nos:bool nost:bool description:string)
        @doc "[4] Updates Nonce Description"
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (DPDC-N|C>SET-DESCRIPTION id son account nosc nos nost description)
                (XI_U|NonceNoD id son account nosc nos nost false description)
                (URCi_UpdateNonceField account)
            )
        )
    )
    (defun C_UpdateNonceScore
        (id:string son:bool account:string nosc:integer nos:bool nost:bool score:decimal)
        @doc "[5] Updates Nonce Score"
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (DPDC-N|C>SET-SCORE id son account nosc nos nost score)
                (XI_U|NonceScore id son account nosc nos nost score)
                (URCi_UpdateNonceField account)
            )
        )
    )
    (defun C_UpdateNonceMetaData
        (id:string son:bool account:string nosc:integer nos:bool nost:bool meta-data:object)
        @doc "[6] Updates Nonce Meta-Data"
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (DPDC-N|C>SET-META-DATA id son account nosc nos nost meta-data)
                (XI_NonceMetaData id son account nosc nos nost meta-data)
                (URCi_UpdateNonceField account)
            )
        )
    )
    (defun C_UpdateNonceURI
        (
            id:string son:bool account:string nosc:integer nos:bool nost:bool
            ay:object{DpdcUdcV1.URI|Type} u1:object{DpdcUdcV1.URI|Data} u2:object{DpdcUdcV1.URI|Data} u3:object{DpdcUdcV1.URI|Data}
        )
        @doc "[7] Updates Nonce URIs"
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (DPDC-N|C>SET-URI id son account nosc nos nost ay u1 u2 u3)
                (XI_U|NonceUri id son account nosc nos nost ay u1 u2 u3)
                (URCi_UpdateNonceField account)
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)
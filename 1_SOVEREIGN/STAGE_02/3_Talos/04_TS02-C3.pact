;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact
;;
(interface TalosStageTwo_ClientThreeV1
    @doc "Exposes Stage Two Third Batch of Client Functions: \
        \ the AcquisitionPools Client Functions"
    ;;
    ;;  [ANK]
    ;;
    (defun AQP-ANK|C_RevokeBoostClass:string (patron:string boost-class-id:string))
    (defun AQP-ANK|C_IssueTrueFungibleAnchor:string
        (patron:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
    )
    (defun AQP-ANK|C_IssueSemiFungibleAnchor:string
        (patron:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
    )
    (defun AQP-ANK|C_IssueNonFungibleAnchor:string
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
    )
    (defun AQP-ANK|C_IssueNonFungibleSetAnchor:string
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
    )
    (defun AQP-ANK|C_RevokeAnchor:string (patron:string anchor-id:string))
    ;;
    ;;  [AQP-SCORE]
    ;;
    (defun AQP-SCR|C_IssueLiquidityScore:string
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
    )
    (defun AQP-SCR|C_IssueTrueFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
    )
    (defun AQP-SCR|C_IssueOrtoFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
    )
    (defun AQP-SCR|C_IssueSemiFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
    )
    (defun AQP-SCR|C_IssueNonFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
    )
    (defun AQP-SCR|C_RotateScoreOwnership:string (patron:string score-id:string new-owner-konto:string))
    (defun AQP-SCR|C_ControlScore:string (patron:string score-id:string new-can-upgrade:bool new-can-change-owner:bool))
    (defun AQP-SCR|C_CreateScoreBoostClassLink:string (patron:string score-id:string boost-class-id:string))
    (defun AQP-SCR|C_CreateScoreBoostLink:string (patron:string score-id:string boost-score-id:string))
    (defun AQP-SCR|C_EnableDebBoost:string (patron:string score-id:string))
    (defun AQP-SCR|C_IssueTriplet:string
        (patron:string bronze-score-id:string silver-score-id:string golden-score-id:string)
    )
    (defun AQP-SCR|C_IssueSemiFungibleScoreDefinition:string
        (patron:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
    )
    (defun AQP-SCR|C_IssueNonFungibleScoreDefinition:string
        (patron:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
    )
    (defun AQP-SCR|C_IssueNonFungibleSetScoreDefinition:string
        (patron:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
    )
    ;;
    ;;  [AQP-POOL]
    ;;
    (defun AQP-POOL|C_Issue:string
        (patron:string pool-name:string asset-id:string aqp-class:integer)
    )
    (defun AQP-POOL|C_AddScore:string
        (patron:string pool-id:string score-id:string)
    )
    (defun AQP-POOL|C_RevokeScore:string
        (patron:string pool-id:string score-id:string)
    )
    (defun AQP-POOL|C_DisablePoolStake:string
        (patron:string pool-id:string)
    )
    (defun AQP-POOL|C_EnablePoolStake:string
        (patron:string pool-id:string)
    )
    ;;
    (defun AQP-POOL|C_StakeSemiFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|C_UnstakeSemiFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
    )
    (defun AQP-POOL|C_StakeNonFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|C_UnstakeNonFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
    )
    ;;
    (defun AQP-POOL|C_StakeTrueFungible:string
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
    )
    (defun AQP-POOL|C_UnstakeTrueFungible:string
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
    )
    (defun AQP-POOL|C_StakeOrtoFungible:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|C_UnstakeOrtoFungible:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|C_SyncTrueFungibleAnchors:string
        (patron:string beneficiary-id:string dptf-id:string)
    )
    (defun AQP-POOL|C_SyncSemiFungibleAnchors:string
        (patron:string beneficiary-id:string dpsf-id:string)
    )
    (defun AQP-POOL|C_SyncNonFungibleAnchors:string
        (patron:string beneficiary-id:string dpnf-id:string)
    )
    (defun AQP-POOL|C_VacateTrueFungibleLegs:string
        (
            patron:string
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
            finalize:bool
        )
    )
    (defun AQP-POOL|C_VacateOrtoFungibleLegs:string
        (
            patron:string
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
    )
    (defun AQP-POOL|C_VacateSemiFungibleLegs:string
        (
            patron:string
            pool-id:string
            dpsf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
    )
    (defun AQP-POOL|C_VacateNonFungibleLegs:string
        (
            patron:string
            pool-id:string
            dpnf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
    )
    (defun AQP-POOL|C_AbortVacate:string
        (patron:string pool-id:string)
    )
    (defun AQP-POOL|C_FullVacateTrueFungible:string
        (
            patron:string
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
    )
    (defun AQP-POOL|C_FullVacateOrtoFungible:string
        (
            patron:string
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
    )
    (defun AQP-POOL|C_FullVacateSemiFungible:string
        (
            patron:string
            pool-id:string
            dpsf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
    )
    (defun AQP-POOL|C_FullVacateNonFungible:string
        (
            patron:string
            pool-id:string
            dpnf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
    )
    ;;
    ;;  [AQP-FVT]
    ;;
    (defun AQP-FVT|C_Issue:string
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
    )
    (defun AQP-FVT|C_IssueMultipletFamily:string
        (
            patron:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
    )
    (defun AQP-FVT|C_AddScoreEntity:string
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
    )
    (defun AQP-FVT|C_AddRewardLink:string
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
    )
    (defun AQP-FVT|C_ToggleScoreEntityLink:string
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
    )
    (defun AQP-FVT|C_ToggleRewardLink:string
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
    )
    (defun AQP-FVT|C_Control:string
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
    )
    (defun AQP-FVT|C_RotateOwnership:string
        (patron:string fvt-id:string new-owner-konto:string)
    )
    (defun AQP-FVT|C_SetCommonDenominator:string
        (patron:string fvt-id:string common-denominator:string)
    )
    (defun AQP-FVT|C_SetMosaic:string
        (patron:string fvt-id:string mosaic:bool)
    )
    (defun AQP-FVT|C_Inject:string
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun AQP-FVT|CC_Inject:string
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun MTX-AQP|C_2|Inject:string
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun AQP-FVT|C_Collect:string
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    )
)
;;
(module TS02-C3 GOV
    @doc "TALOS Stage 2 Client Functiones Part 3 - Acquisition Pools Functions"
    ;;
    (implements OuronetPolicyV1)
    (implements TalosStageTwo_ClientThreeV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_TS02-C3        (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|TS02-C3_ADMIN)))
    (defcap GOV|TS02-C3_ADMIN ()    (enforce-guard GOV|MD_TS02-C3))
    ;;{G3}
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})
    (deftable P|MT:{OuronetPolicyV1.P|MS})
    ;;{P3}
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
    ;;{P4}
    (defconst P|I                   (P|Info))
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                   (CT_Bar))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|TS02-C3_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|TS02-C3_ADMIN)
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
                (ref-P|TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                (ref-P|ANK:module{OuronetPolicyV1} AQP-ANK)
                (ref-P|SCR:module{OuronetPolicyV1} AQP-SCORE)
                (ref-P|AQP:module{OuronetPolicyV1} AQP-POOL)
                (ref-P|FVT:module{OuronetPolicyV1} AQP-FVT)
                (ref-P|VCT:module{OuronetPolicyV1} AQP-VCT)
                (ref-P|ATSU:module{OuronetPolicyV1} ATSU)
                (ref-P|MTX-AQP:module{OuronetPolicyV1} MTX-AQP)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|TS01-A::P|A_AddIMP mg)
            (ref-P|ANK::P|A_AddIMP mg)
            (ref-P|SCR::P|A_AddIMP mg)
            (ref-P|AQP::P|A_AddIMP mg)
            (ref-P|FVT::P|A_AddIMP mg)
            (ref-P|VCT::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            ;; MTX-AQP defpact wrapper below — register the Talos summoner as an allowed IMC caller of MTX-AQP.
            (ref-P|MTX-AQP::P|A_AddIMP mg)
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
    ;;{3}
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    (defcap AQP|C>STAKE-TRUE-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "AQP client event: stake TrueFungible. Composes P|TS only; sovereign recipe in FVT::C_TrueFungibleStakeFlow."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-TRUE-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "AQP client event: unstake TrueFungible. Composes P|TS only; sovereign recipe in FVT::C_TrueFungibleStakeFlow."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>STAKE-ORTO-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "AQP client event: stake OrtoFungible. nonces and nonce-amounts are resolved before this cap \
            \ (DPOF::UR_NoncesSupplies — whole nonce only) so the explorer records the exact legs moved."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-ORTO-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "AQP client event: unstake OrtoFungible. nonces and nonce-amounts resolved before this cap \
            \ (DPOF::UR_NoncesSupplies — whole nonce only) for explorer visibility."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>STAKE-SEMI-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: stake DPSF collectable (son=true). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-SEMI-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: unstake DPSF collectable (son=true). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>STAKE-NON-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: stake DPNF collectable (son=false). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-NON-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: unstake DPNF collectable (son=false). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-TF-ANCHORS
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "AQP client event: pool-agnostic TF anchor repair. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-SEMI-FUNGIBLE-ANCHORS
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "AQP client event: pool-agnostic DPSF anchor repair. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-NON-FUNGIBLE-ANCHORS
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "AQP client event: pool-agnostic DPNF anchor repair. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>VACATE-TRUE-FUNGIBLE-LEGS
        (
            patron:string
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
            finalize:bool
        )
        @doc "AQP client event: stateless TF vacate legs batch. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>VACATE-ORTO-FUNGIBLE-LEGS
        (
            patron:string
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
        @doc "AQP client event: stateless OF vacate legs batch. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>VACATE-SEMI-FUNGIBLE-LEGS
        (
            patron:string
            pool-id:string
            dpsf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
        @doc "AQP client event: stateless DPSF vacate legs batch. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>VACATE-NON-FUNGIBLE-LEGS
        (
            patron:string
            pool-id:string
            dpnf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
        @doc "AQP client event: stateless DPNF vacate legs batch. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>ABORT-VACATE
        (patron:string pool-id:string)
        @doc "AQP client event: clear vacate-in-progress (stake stays disabled). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>FULL-VACATE-TRUE-FUNGIBLE
        (
            patron:string
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
        @doc "AQP client event: full TF vacate (UI-supplied Legs payload). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>FULL-VACATE-ORTO-FUNGIBLE
        (
            patron:string
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "AQP client event: full OF vacate. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>FULL-VACATE-SEMI-FUNGIBLE
        (
            patron:string
            pool-id:string
            dpsf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "AQP client event: full DPSF vacate. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>FULL-VACATE-NON-FUNGIBLE
        (
            patron:string
            pool-id:string
            dpnf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "AQP client event: full DPNF vacate. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    ;;{C3}
    ;;{C4}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    (defun UC_ShortAccount:string (account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UC_ShortAccount account)
        )
    )
    (defun UC_FormatStakeTrueFungibleResult:string
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Stake success text: self-stake when owner=beneficiary; else names short owner and beneficiary."
        (if (= owner-id beneficiary-id)
            (format "Successfully staked TrueFungible {} amount {} into Pool {} (self-stake, {}). "
                [dptf-id amount pool-id (UC_ShortAccount owner-id)]
            )
            (format "Successfully staked TrueFungible {} amount {} into Pool {} for beneficiary {} (owner {}). "
                [dptf-id amount pool-id (UC_ShortAccount beneficiary-id) (UC_ShortAccount owner-id)]
            )
        )
    )
    (defun UC_FormatUnstakeTrueFungibleResult:string
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Unstake success text: self-stake when owner=beneficiary; else names short owner and beneficiary."
        (if (= owner-id beneficiary-id)
            (format "Successfully unstaked TrueFungible {} amount {} from Pool {} (self-stake, {}). "
                [dptf-id amount pool-id (UC_ShortAccount owner-id)]
            )
            (format "Successfully unstaked TrueFungible {} amount {} from Pool {} for beneficiary {} (owner {}). "
                [dptf-id amount pool-id (UC_ShortAccount beneficiary-id) (UC_ShortAccount owner-id)]
            )
        )
    )
    (defun UC_FormatStakeOrtoFungibleResult:string
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonce-count:integer)
        @doc "Stake OF success text (whole-nonce Transfer)."
        (if (= owner-id beneficiary-id)
            (format "Successfully staked OrtoFungible {} ({} whole nonces) into Pool {} (self-stake, {}). "
                [
                    dpof-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount owner-id)
                ]
            )
            (format "Successfully staked OrtoFungible {} ({} whole nonces) into Pool {} for beneficiary {} (owner {}). "
                [
                    dpof-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount beneficiary-id)
                    (UC_ShortAccount owner-id)
                ]
            )
        )
    )
    (defun UC_FormatUnstakeOrtoFungibleResult:string
        (pool-id:string owner-id:string dpof-id:string nonce-count:integer)
        @doc "Unstake OF success text; beneficiary resolved from tracker in sovereign phase 1."
        (format "Successfully unstaked OrtoFungible {} ({} whole nonces) from Pool {} (owner {}). "
            [
                dpof-id
                nonce-count
                pool-id
                (UC_ShortAccount owner-id)
            ]
        )
    )
    (defun UC_FormatStakeCollectableResult:string
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce-count:integer
        )
        @doc "Stake collectable success text."
        (if (= owner-id beneficiary-id)
            (format "Successfully staked {} {} ({} nonces) into Pool {} (self-stake, {}). "
                [
                    (if son "DPSF" "DPNF")
                    collectable-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount owner-id)
                ]
            )
            (format "Successfully staked {} {} ({} nonces) into Pool {} for beneficiary {} (owner {}). "
                [
                    (if son "DPSF" "DPNF")
                    collectable-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount beneficiary-id)
                    (UC_ShortAccount owner-id)
                ]
            )
        )
    )
    (defun UC_FormatUnstakeCollectableResult:string
        (pool-id:string owner-id:string collectable-id:string son:bool nonce-count:integer)
        @doc "Unstake collectable success text."
        (format "Successfully unstaked {} {} ({} nonces) from Pool {} (owner {}). "
            [
                (if son "DPSF" "DPNF")
                collectable-id
                nonce-count
                pool-id
                (UC_ShortAccount owner-id)
            ]
        )
    )
    (defun UC_FormatVacateCollectableResult:string
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce-count:integer
        )
        @doc "Vacate collectable success text (pool-owner forced unstake)."
        (format "Successfully vacated {} {} ({} nonces) from Pool {} (owner {} → beneficiary {}). "
            [
                (if son "DPSF" "DPNF")
                collectable-id
                nonce-count
                pool-id
                (UC_ShortAccount owner-id)
                (UC_ShortAccount beneficiary-id)
            ]
        )
    )
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    (defun AQP-ANK|C_RevokeBoostClass:string
        (patron:string boost-class-id:string)
        @doc "Revokes an empty BoostClass."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-ANK::C_RevokeBoostClass boost-class-id)
                )
                (format "Successfully revoked BoostClass {}." [boost-class-id])
            )
        )
    )
    (defun AQP-ANK|C_IssueTrueFungibleAnchor:string
        (patron:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Issues a DPTF Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-ANK::C_IssueTrueFungibleAnchor 
                            patron anchor-name dptf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dptf-amount
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelKDA)
                (if acnoi
                    (format "Successfully issued TrueFungible Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dptf-id])
                    (format "Successfully issued TrueFungible Anchor {} for {}." [anchor-id dptf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_IssueSemiFungibleAnchor:string
        (patron:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Issues a DPSF Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-ANK::C_IssueSemiFungibleAnchor 
                            patron anchor-name dpsf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpsf-nonce
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelKDA)
                (if acnoi
                    (format "Successfully issued SemiFungible Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dpsf-id])
                    (format "Successfully issued SemiFungible Anchor {} for {}." [anchor-id dpsf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_IssueNonFungibleAnchor:string
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Issues a DPNF trait-Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-ANK::C_IssueNonFungibleAnchor 
                            patron anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-trait-key dpnf-trait-value
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelKDA)
                (if acnoi
                    (format "Successfully issued NonFungible Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dpnf-id])
                    (format "Successfully issued NonFungible Anchor {} for {}." [anchor-id dpnf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_IssueNonFungibleSetAnchor:string
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Issues a DPNF set-Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-ANK::C_IssueNonFungibleSetAnchor
                            patron anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-nonce-class
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelKDA)
                (if acnoi
                    (format "Successfully issued NonFungible Set Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dpnf-id])
                    (format "Successfully issued NonFungible Set Anchor {} for {}." [anchor-id dpnf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_RevokeAnchor:string (patron:string anchor-id:string)
        @doc "Revokes an existing Anchor, removing it from its BoostClass and AssetAnchors bookkeeping."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                )
                (ref-IGNIS::C_Collect patron 
                    (ref-ANK::C_RevokeAnchor anchor-id)
                )
                (format "Successfully revoked Anchor {}." [anchor-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueLiquidityScore:string
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Issues score-class 0 (LP) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SCR::C_IssueLiquidityScore patron owner-konto score-name precision lp-denominator mx-frozen mx-sleeping)
                )
                (format "Successfully issued Liquidity Score {} for owner {}." [score-name owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_IssueTrueFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Issues score-class 1 (DPTF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SCR::C_IssueTrueFungibleScore patron owner-konto score-name precision mx-frozen)
                )
                (format "Successfully issued TrueFungible Score {} for owner {}." [score-name owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_IssueOrtoFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Issues score-class 2 (DPOF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SCR::C_IssueOrtoFungibleScore patron owner-konto score-name precision mx-sleeping mx-hibernated)
                )
                (format "Successfully issued OrtoFungible Score {} for owner {}." [score-name owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_IssueSemiFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Issues score-class 3 (DPSF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SCR::C_IssueSemiFungibleScore patron owner-konto score-name precision sft-equality)
                )
                (format "Successfully issued SemiFungible Score {} for owner {}." [score-name owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Issues score-class 4 (DPNF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SCR::C_IssueNonFungibleScore patron owner-konto score-name precision nft-score-model)
                )
                (format "Successfully issued NonFungible Score {} for owner {}." [score-name owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_RotateScoreOwnership:string (patron:string score-id:string new-owner-konto:string)
        @doc "Rotates score ownership in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron (ref-SCR::C_RotateOwnership score-id new-owner-konto))
                (format "Successfully rotated ownership for score {} to {}." [score-id new-owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_ControlScore:string (patron:string score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Updates score control flags in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SCR::C_Control score-id new-can-upgrade new-can-change-owner)
                )
                (format "Successfully updated control flags for score {}." [score-id])
            )
        )
    )
    (defun AQP-SCR|C_CreateScoreBoostClassLink:string (patron:string score-id:string boost-class-id:string)
        @doc "Creates score -> boost-class link in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron (ref-SCR::C_CreateBoostClassLink score-id boost-class-id))
                (format "Successfully linked score {} to BoostClass {}." [score-id boost-class-id])
            )
        )
    )
    (defun AQP-SCR|C_CreateScoreBoostLink:string (patron:string score-id:string boost-score-id:string)
        @doc "Creates score -> boost-score link in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron (ref-SCR::C_CreateBoostLink score-id boost-score-id))
                (format "Successfully linked score {} to boost score {}." [score-id boost-score-id])
            )
        )
    )
    (defun AQP-SCR|C_EnableDebBoost:string (patron:string score-id:string)
        @doc "Enables irreversible DEB boost on the score row. Medium IGNIS cost; no native STOA."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron (ref-SCR::C_EnableDebBoost score-id))
                (format "Successfully enabled DEB boost for score {}." [score-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueTriplet:string
        (patron:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Issues SCR triplet bundle T|bronze|silver|golden and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-SCR::C_IssueTriplet patron bronze-score-id silver-score-id golden-score-id)
                    )
                    (out:[string] (at "output" ico))
                    (triplet-id:string (at 0 out))
                )
                (ref-IGNIS::C_Collect patron ico)
                (format "Successfully issued triplet {}." [triplet-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueSemiFungibleScoreDefinition:string
        (patron:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Writes DPSF nonce score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SCR::C_IssueSemiFungibleScoreDefinition score-id dpsf-id nonces nonce-score-values)
                )
                (format "Successfully issued SemiFungible score definitions for score {} and dpsf-id {}." [score-id dpsf-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleScoreDefinition:string
        (patron:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Writes DPNF trait score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SCR::C_IssueNonFungibleScoreDefinition score-id dpnf-id trait-keys trait-values trait-score-values)
                )
                (format "Successfully issued NonFungible score definitions for score {} and dpnf-id {}." [score-id dpnf-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleSetScoreDefinition:string
        (patron:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Writes DPNF set-mode (nonce-class) score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-SCR::C_IssueNonFungibleSetScoreDefinition score-id dpnf-id dpnf-nonce-classes class-score-values)
                )
                (format "Successfully issued NonFungible set score definitions for score {} and dpnf-id {}." [score-id dpnf-id])
            )
        )
    )
    (defun AQP-POOL|C_Issue:string
        (patron:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Issues an acquisition pool (aqp-class + canonical native asset-id) and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-AQP::C_Issue patron pool-name asset-id aqp-class)
                    )
                    (out:[string] (at "output" ico))
                    (pool-id:string (at 0 out))
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully issued Acquisition Pool {} (class {} for asset {})." [pool-id aqp-class asset-id])
            )
        )
    )
    (defun AQP-POOL|C_AddScore:string
        (patron:string pool-id:string score-id:string)
        @doc "Assigns score-id to the first free slot on pool-id; collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-AQP::C_AddScore patron pool-id score-id)
                )
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully assigned Score {} to Pool {}." [score-id pool-id])
            )
        )
    )
    (defun AQP-POOL|C_RevokeScore:string
        (patron:string pool-id:string score-id:string)
        @doc "Revokes score-id from pool-id (compact slots, clear aqpool-link); collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-AQP::C_RevokeScore patron pool-id score-id)
                )
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully revoked Score {} from Pool {}." [score-id pool-id])
            )
        )
    )
    (defun AQP-POOL|C_DisablePoolStake:string
        (patron:string pool-id:string)
        @doc "Pool owner pauses new stakes (stake-enabled → false); collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-AQP::C_DisablePoolStake patron pool-id)
                )
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully disabled staking on Pool {}." [pool-id])
            )
        )
    )
    (defun AQP-POOL|C_EnablePoolStake:string
        (patron:string pool-id:string)
        @doc "Pool owner re-enables new stakes (stake-enabled → true); collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-AQP::C_EnablePoolStake patron pool-id)
                )
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully enabled staking on Pool {}." [pool-id])
            )
        )
    )
    ;;
    (defun AQP-POOL|C_StakeTrueFungible:string
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Stake DPTF (or native|F| LP) into pool-id. Talos client shell: event cap + FVT::C_TrueFungibleStakeFlow direction=true."
        (with-capability (AQP|C>STAKE-TRUE-FUNGIBLE patron pool-id owner-id beneficiary-id dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount true)
                )
                (UC_FormatStakeTrueFungibleResult pool-id owner-id beneficiary-id dptf-id amount)
            )
        )
    )
    (defun AQP-POOL|C_UnstakeTrueFungible:string
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Unstake DPTF from pool-id. Talos client shell: event cap + FVT::C_TrueFungibleStakeFlow direction=false."
        (with-capability (AQP|C>UNSTAKE-TRUE-FUNGIBLE patron pool-id owner-id beneficiary-id dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount false)
                )
                (UC_FormatUnstakeTrueFungibleResult pool-id owner-id beneficiary-id dptf-id amount)
            )
        )
    )
    (defun AQP-POOL|C_StakeOrtoFungible:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
        )
        @doc "Stake whole DPOF nonces via C_Transfer. Poll DPOF::UR_NoncesSupplies, then @event cap with resolved legs."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>STAKE-ORTO-FUNGIBLE patron pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::C_Collect patron
                        (ref-FVT::C_OrtoFungibleStakeFlow
                            pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeOrtoFungibleResult pool-id owner-id beneficiary-id dpof-id nonce-count)
                )
            )
        )
    )
    (defun AQP-POOL|C_UnstakeOrtoFungible:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
        )
        @doc "Unstake whole DPOF nonces via C_Transfer from the (owner, beneficiary) row. M5: beneficiary-id is \
            \ caller-supplied (self OR foreign) so the exact staked row is located — mirrors TF. Poll UR_NoncesSupplies, \
            \ then @event cap with resolved legs."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>UNSTAKE-ORTO-FUNGIBLE patron pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::C_Collect patron
                        (ref-FVT::C_OrtoFungibleStakeFlow
                            pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeOrtoFungibleResult pool-id owner-id dpof-id nonce-count)
                )
            )
        )
    )
    ;;
    (defun AQP-POOL|C_StakeSemiFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
        )
        @doc "Stake DPSF collectable (son=true). Poll DPDC::UR_AccountNoncesSupplies, then FVT::C_CollectableStakeFlow."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[integer] (ref-DPDC::UR_AccountNoncesSupplies owner-id collectable-id true nonces))
            )
            (with-capability
                (AQP|C>STAKE-SEMI-FUNGIBLE-COLLECTABLE
                    patron pool-id owner-id beneficiary-id collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::C_Collect patron
                        (ref-FVT::C_CollectableStakeFlow
                            pool-id owner-id beneficiary-id collectable-id true nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeCollectableResult
                        pool-id owner-id beneficiary-id collectable-id true nonce-count
                    )
                )
            )
        )
    )
    (defun AQP-POOL|C_UnstakeSemiFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Unstake DPSF collectable (son=true) from the (owner, beneficiary) row. M5: beneficiary-id caller-supplied \
            \ (self OR foreign) so the exact staked row is located — mirrors TF."
        (let
            (
                (nonce-count:integer (length nonces))
            )
            (with-capability
                (AQP|C>UNSTAKE-SEMI-FUNGIBLE-COLLECTABLE
                    patron pool-id owner-id beneficiary-id collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::C_Collect patron
                        (ref-FVT::C_CollectableStakeFlow
                            pool-id owner-id beneficiary-id collectable-id true nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeCollectableResult pool-id owner-id collectable-id true nonce-count)
                )
            )
        )
    )
    (defun AQP-POOL|C_StakeNonFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
        )
        @doc "Stake DPNF collectable (son=false). Poll DPDC::UR_AccountNoncesSupplies, then FVT::C_CollectableStakeFlow."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[integer] (ref-DPDC::UR_AccountNoncesSupplies owner-id collectable-id false nonces))
            )
            (with-capability
                (AQP|C>STAKE-NON-FUNGIBLE-COLLECTABLE
                    patron pool-id owner-id beneficiary-id collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::C_Collect patron
                        (ref-FVT::C_CollectableStakeFlow
                            pool-id owner-id beneficiary-id collectable-id false nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeCollectableResult
                        pool-id owner-id beneficiary-id collectable-id false nonce-count
                    )
                )
            )
        )
    )
    (defun AQP-POOL|C_UnstakeNonFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Unstake DPNF collectable (son=false) from the (owner, beneficiary) row. M5: beneficiary-id caller-supplied \
            \ (self OR foreign) so the exact staked row is located — mirrors TF."
        (let
            (
                (nonce-count:integer (length nonces))
            )
            (with-capability
                (AQP|C>UNSTAKE-NON-FUNGIBLE-COLLECTABLE
                    patron pool-id owner-id beneficiary-id collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::C_Collect patron
                        (ref-FVT::C_CollectableStakeFlow
                            pool-id owner-id beneficiary-id collectable-id false nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeCollectableResult pool-id owner-id collectable-id false nonce-count)
                )
            )
        )
    )
    ;;
    ;; Vacate — Full (1 tx) or Stateless Legs (N txs; auto-begin; finalize on last)
    ;;
    (defun AQP-POOL|C_VacateTrueFungibleLegs:string
        (
            patron:string
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
            finalize:bool
        )
        @doc "Stateless TF vacate legs batch. Auto-begins; finalize=true when asset empty."
        (with-capability
            (AQP|C>VACATE-TRUE-FUNGIBLE-LEGS
                patron pool-id dptf-id owner-ids beneficiary-ids amounts finalize
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-VCT::C_VacateTrueFungibleLegs
                        pool-id dptf-id owner-ids beneficiary-ids amounts finalize
                    )
                )
                (format "Successfully vacated TF legs on Pool {} ({} owner leg(s){}; asset {})."
                    [pool-id (length owner-ids) (if finalize " finalize" "") dptf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_VacateOrtoFungibleLegs:string
        (
            patron:string
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
        @doc "Stateless OF vacate legs batch. Amounts may be zero-sentinels."
        (with-capability
            (AQP|C>VACATE-ORTO-FUNGIBLE-LEGS
                patron pool-id dpof-id owner-ids beneficiary-ids nonces-array amounts-array finalize
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-VCT::C_VacateOrtoFungibleLegs
                        pool-id dpof-id owner-ids beneficiary-ids nonces-array amounts-array finalize
                    )
                )
                (format "Successfully vacated OF legs on Pool {} ({} owner leg(s){}; asset {})."
                    [pool-id (length owner-ids) (if finalize " finalize" "") dpof-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_VacateSemiFungibleLegs:string
        (
            patron:string
            pool-id:string
            dpsf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
        @doc "Stateless DPSF vacate legs batch."
        (with-capability
            (AQP|C>VACATE-SEMI-FUNGIBLE-LEGS
                patron pool-id dpsf-id owner-ids beneficiary-ids nonces-array amounts-array finalize
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-VCT::C_VacateSemiFungibleLegs
                        pool-id dpsf-id owner-ids beneficiary-ids nonces-array amounts-array finalize
                    )
                )
                (format "Successfully vacated DPSF legs on Pool {} ({} owner leg(s){}; asset {})."
                    [pool-id (length owner-ids) (if finalize " finalize" "") dpsf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_VacateNonFungibleLegs:string
        (
            patron:string
            pool-id:string
            dpnf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
        @doc "Stateless DPNF vacate legs batch."
        (with-capability
            (AQP|C>VACATE-NON-FUNGIBLE-LEGS
                patron pool-id dpnf-id owner-ids beneficiary-ids nonces-array amounts-array finalize
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-VCT::C_VacateNonFungibleLegs
                        pool-id dpnf-id owner-ids beneficiary-ids nonces-array amounts-array finalize
                    )
                )
                (format "Successfully vacated DPNF legs on Pool {} ({} owner leg(s){}; asset {})."
                    [pool-id (length owner-ids) (if finalize " finalize" "") dpnf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_AbortVacate:string
        (patron:string pool-id:string)
        @doc "Clear vacate-in-progress; stake stays disabled. Talos → AQP-VCT::C_AbortVacate."
        (with-capability (AQP|C>ABORT-VACATE patron pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-VCT::C_AbortVacate pool-id)
                )
                (format "Successfully aborted vacate-in-progress on Pool {} (stake remains disabled)."
                    [pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_FullVacateTrueFungible:string
        (
            patron:string
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
        @doc "Pool-owner full TF vacate (one tx). UI dirty-reads inventory → Legs arrays → VCT."
        (with-capability
            (AQP|C>FULL-VACATE-TRUE-FUNGIBLE
                patron pool-id dptf-id owner-ids beneficiary-ids amounts
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-VCT::C_FullVacateTrueFungible
                        pool-id dptf-id owner-ids beneficiary-ids amounts
                    )
                )
                (format "Successfully full-vacated TrueFungible {} from Pool {}."
                    [dptf-id pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_FullVacateOrtoFungible:string
        (
            patron:string
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Pool-owner full OF vacate (one tx). UI dirty-reads inventory → Legs arrays → VCT."
        (with-capability
            (AQP|C>FULL-VACATE-ORTO-FUNGIBLE
                patron pool-id dpof-id owner-ids beneficiary-ids nonces-array amounts-array
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-VCT::C_FullVacateOrtoFungible
                        pool-id dpof-id owner-ids beneficiary-ids nonces-array amounts-array
                    )
                )
                (format "Successfully full-vacated OrtoFungible {} from Pool {}."
                    [dpof-id pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_FullVacateSemiFungible:string
        (
            patron:string
            pool-id:string
            dpsf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Pool-owner full DPSF vacate (one tx). UI dirty-reads inventory → Legs arrays → VCT."
        (with-capability
            (AQP|C>FULL-VACATE-SEMI-FUNGIBLE
                patron pool-id dpsf-id owner-ids beneficiary-ids nonces-array amounts-array
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-VCT::C_FullVacateSemiFungible
                        pool-id dpsf-id owner-ids beneficiary-ids nonces-array amounts-array
                    )
                )
                (format "Successfully full-vacated SemiFungible {} from Pool {}."
                    [dpsf-id pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_FullVacateNonFungible:string
        (
            patron:string
            pool-id:string
            dpnf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Pool-owner full DPNF vacate (one tx). UI dirty-reads inventory → Legs arrays → VCT."
        (with-capability
            (AQP|C>FULL-VACATE-NON-FUNGIBLE
                patron pool-id dpnf-id owner-ids beneficiary-ids nonces-array amounts-array
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-VCT::C_FullVacateNonFungible
                        pool-id dpnf-id owner-ids beneficiary-ids nonces-array amounts-array
                    )
                )
                (format "Successfully full-vacated NonFungible {} from Pool {}."
                    [dpnf-id pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncTrueFungibleAnchors:string
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Pool-agnostic TF anchor repair for beneficiary × dptf-id. Talos shell → AQP-POOL::C_SyncTrueFungibleAnchors."
        (with-capability (AQP|C>SYNC-TF-ANCHORS patron beneficiary-id dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-AQP::C_SyncTrueFungibleAnchors patron beneficiary-id dptf-id)
                )
                (format "Successfully synced TrueFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount beneficiary-id) dptf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncSemiFungibleAnchors:string
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "Pool-agnostic DPSF anchor repair. Talos shell → AQP-POOL::C_SyncCollectableAnchors son=true."
        (with-capability (AQP|C>SYNC-SEMI-FUNGIBLE-ANCHORS patron beneficiary-id dpsf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-AQP::C_SyncCollectableAnchors patron beneficiary-id dpsf-id true)
                )
                (format "Successfully synced SemiFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount beneficiary-id) dpsf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncNonFungibleAnchors:string
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "Pool-agnostic DPNF anchor repair. Talos shell → AQP-POOL::C_SyncCollectableAnchors son=false."
        (with-capability (AQP|C>SYNC-NON-FUNGIBLE-ANCHORS patron beneficiary-id dpnf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-AQP::C_SyncCollectableAnchors patron beneficiary-id dpnf-id false)
                )
                (format "Successfully synced NonFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount beneficiary-id) dpnf-id]
                )
            )
        )
    )
    ;;
    ;; --- AQP-FVT lifecycle (Talos client shell → AQP-FVT::C_*) ---
    (defun AQP-FVT|C_Issue:string
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Issues an FVT (farm/vault/treasury) and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-FVT::C_Issue patron fvt-name owner-konto fvt-class common-denominator)
                    )
                    (out:[string] (at "output" ico))
                    (fvt-id:string (at 0 out))
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully issued FVT {} (class {})." [fvt-id fvt-class])
            )
        )
    )
    (defun AQP-FVT|C_IssueMultipletFamily:string
        (
            patron:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "Issues chain-wide MultipletFamily F|t0|t1|t2 (rank 3) with ATS ladder validation."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ico:object{IgnisCollectorV1.OutputCumulator}
                        (ref-FVT::C_IssueMultipletFamily
                            patron token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id
                        )
                    )
                    (out:[string] (at "output" ico))
                    (family-id:string (at 0 out))
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully issued MultipletFamily {}." [family-id])
            )
        )
    )
    (defun AQP-FVT|C_AddScoreEntity:string
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Admits score (type 1) or triplet (type 3) to fvt-id via ScoreEntityLink."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_AddScoreEntity patron fvt-id score-entity-type score-entity-id)
                )
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully added score-entity type {} id {} to FVT {}."
                    [score-entity-type score-entity-id fvt-id]
                )
            )
        )
    )
    (defun AQP-FVT|C_AddRewardLink:string
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Registers one reward DPTF on fvt-id (multiplet-family-id BAR for plain tokens). Collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_AddRewardLink patron fvt-id reward-dptf-id segmentation multiplet-family-id)
                )
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully added reward link {} on FVT {} (family={})."
                    [reward-dptf-id fvt-id multiplet-family-id]
                )
            )
        )
    )
    (defun AQP-FVT|C_ToggleScoreEntityLink:string
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Toggles ScoreEntityLink.enabled and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_ToggleScoreEntityLink patron fvt-id score-entity-type score-entity-id enabled)
                )
                (format "Successfully toggled score-entity type {} id {} on FVT {} to enabled={}."
                    [score-entity-type score-entity-id fvt-id enabled]
                )
            )
        )
    )
    (defun AQP-FVT|C_ToggleRewardLink:string
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Toggles reward-enabled and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_ToggleRewardLink patron fvt-id reward-dptf-id enabled)
                )
                (format "Successfully toggled reward link {} on FVT {} to enabled={}." [reward-dptf-id fvt-id enabled])
            )
        )
    )
    (defun AQP-FVT|C_Control:string
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Updates FVT control flags and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_Control patron fvt-id new-can-upgrade new-can-change-owner)
                )
                (format "Successfully updated control flags for FVT {}." [fvt-id])
            )
        )
    )
    (defun AQP-FVT|C_RotateOwnership:string
        (patron:string fvt-id:string new-owner-konto:string)
        @doc "Rotates FVT ownership and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_RotateOwnership patron fvt-id new-owner-konto)
                )
                (format "Successfully rotated ownership for FVT {} to {}." [fvt-id new-owner-konto])
            )
        )
    )
    (defun AQP-FVT|C_SetCommonDenominator:string
        (patron:string fvt-id:string common-denominator:string)
        @doc "Sets farm common-denominator (before ScoreEntityLinks) and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_SetCommonDenominator patron fvt-id common-denominator)
                )
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully set common-denominator on FVT {} to {}." [fvt-id common-denominator])
            )
        )
    )
    (defun AQP-FVT|C_SetMosaic:string
        (patron:string fvt-id:string mosaic:bool)
        @doc "Sets mosaic membership policy when FVT has no member links; collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_SetMosaic patron fvt-id mosaic)
                )
                (format "Successfully set mosaic on FVT {} to {}." [fvt-id mosaic])
            )
        )
    )
    (defun AQP-FVT|C_Inject:string
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Injects reward DPTF into fvt-id (RPS G + available-rewards) and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_Inject patron fvt-id reward-dptf-id amount)
                )
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully injected {} {} into FVT {}." [amount reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-FVT|CC_Inject:string
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "HEAVY enforced-FRESH inject for ANY FVT class (farm/vault/treasury; M3 #12): refreshes every stale \
            \ staker's deb so the divisor is live before injecting, then injects + collects IGNIS on patron. Same \
            \ shape as C_Inject. Farms are covered too — a mosaic farm's singular/non-true-triplet members are \
            \ deb-stale-exposed via SCR|ScoreTotalDebScore just like a vault."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::CC_Inject patron fvt-id reward-dptf-id amount)
                )
                (ref-TS01-A::XB_DynamicFuelKDA)
                (format "Successfully FRESH-injected {} {} into FVT {}." [amount reward-dptf-id fvt-id])
            )
        )
    )
    (defun MTX-AQP|C_2|Inject:string
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Starts the 2-step enforced-fresh inject defpact (MTX-AQP — spike fallback for AQP-FVT|CC_Inject when \
            \ the stale set exceeds one tx). Step 0 runs here; advance with (continue-pact 1). Each defpact step \
            \ collects its own IGNIS on patron, so this wrapper only summons the pact."
        (with-capability (P|TS)
            (let
                (
                    (ref-MTX-AQP:module{AqpMtxV1} MTX-AQP)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                )
                (let ((r:string (ref-MTX-AQP::C_2|Inject patron fvt-id reward-dptf-id amount)))
                    (ref-TS01-A::XB_DynamicFuelKDA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|C_Collect:string
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Collects pending reward DPTF for patron on one score-entity from fvt-id; collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV1} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (bal-before:decimal (ref-DPTF::UR_AccountSupply reward-dptf-id patron))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-FVT::C_Collect patron fvt-id score-entity-type score-entity-id reward-dptf-id)
                )
                (ref-TS01-A::XB_DynamicFuelKDA)
                (let
                    (
                        (bal-after:decimal (ref-DPTF::UR_AccountSupply reward-dptf-id patron))
                        (payout:decimal (- bal-after bal-before))
                    )
                    (format "Successfully collected {} {} rewards from FVT {} for score-entity type {} id {}."
                        [payout reward-dptf-id fvt-id score-entity-type score-entity-id]
                    )
                )
            )
        )
    )
    ;;
    ;; --- REPL dry-run (P|TS client shell → AQP-FVT::REPL_BootstrapVault under GOV|FVT_ADMIN) ---
    (defun AQP-FVT|REPL_BootstrapVault:string
        (patron:string fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only Talos shell: composes P|TS for SCR XE IMC; forwards to AQP-FVT::REPL_BootstrapVault."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-FVT::REPL_BootstrapVault fvt-id owner-konto score-id reward-dptf-id)
            )
        )
    )
    (defun AQP-FVT|REPL_BootstrapTreasury:string
        (patron:string fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only Talos shell: class-2 treasury bootstrap for OF score pools."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-FVT::REPL_BootstrapTreasury fvt-id owner-konto score-id reward-dptf-id)
            )
        )
    )
    ;;{F7}  [X]
    ;;
)

(create-table P|T)
(create-table P|MT)
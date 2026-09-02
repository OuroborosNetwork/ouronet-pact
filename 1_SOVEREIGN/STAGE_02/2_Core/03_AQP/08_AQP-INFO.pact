;; ================================================================================
;; AQP-INFO — pre-execution COST PREVIEW surface for the AQP modules.
;;
;; Each AQP-<MOD>|INFO_<Fn> is the read-only counterpart of a TS02-C3 execution
;; wrapper. It returns object{OuronetInfoV1.ClientInfo} describing what the op does,
;; which execution function runs it, and the EXACT IGNIS + STOA price for a given
;; account (mirroring the execution's own cost logic byte-for-byte — same GAS| const,
;; same UsagePrice tier, same multipliers/branches, same zero-gas toggle gate).
;;
;; Procedure: OuronetInformational/skills/aqp-info-module-procedure.md
;; Surface  : OuronetInformational/skills/aqp-entrypoint-surface.md
;; Deploys AFTER 01_ANK..07_DSA + TS02-C3 (reads their state + GAS| constants; never writes).
;; No interface: this is a leaf read-only preview module — nothing references it via module{}.
;; ================================================================================
(module AQP-INFO GOV

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_INFO|AQP       (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                  (compose-capability (GOV|INFO|AQP_ADMIN)))
    (defcap GOV|INFO|AQP_ADMIN ()   (enforce-guard GOV|MD_INFO|AQP))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

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
    (defconst BAR                   (CT_Bar))
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
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;   (AQP-{ANK,SCORE,POOL,FVT,VCT,DSA}.URCi_*, via OI|UC_IfpFromOutputCumulator / OI|UDC_DynamicStoaCost),
    ;;   so the local price-tier gates (UC_GasPrice / SIP|URC_* / SKP|URC_*) are no longer used here.
    ;;
    ;;[AQP-ANK] Anchors
    (defun INFO_AQP-ANK|IssueTrueFungibleAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Cost preview for C_AQP-ANK|IssueTrueFungibleAnchor. IGNIS 1000 (inline) + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a True-Fungible (DPTF) anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.C_AQP-ANK|IssueTrueFungibleAnchor."]
                [(format "Anchor '{}' issued on DPTF {}." [anchor-name dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|IssueSemiFungibleAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Cost preview for C_AQP-ANK|IssueSemiFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Semi-Fungible (DPSF) anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.C_AQP-ANK|IssueSemiFungibleAnchor."]
                [(format "Anchor '{}' issued on DPSF {} nonce {}." [anchor-name dpsf-id dpsf-nonce])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|IssueNonFungibleAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Cost preview for C_AQP-ANK|IssueNonFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Non-Fungible (DPNF) trait-anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.C_AQP-ANK|IssueNonFungibleAnchor."]
                [(format "Anchor '{}' issued on DPNF {} trait {}={}." [anchor-name dpnf-id dpnf-trait-key dpnf-trait-value])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|IssueNonFungibleSetAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Cost preview for C_AQP-ANK|IssueNonFungibleSetAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Non-Fungible (DPNF) set-anchor (by nonce-class) for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.C_AQP-ANK|IssueNonFungibleSetAnchor."]
                [(format "Anchor '{}' issued on DPNF {} nonce-class {}." [anchor-name dpnf-id dpnf-nonce-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|RevokeAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for C_AQP-ANK|RevokeAnchor. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Revoke an anchor and update its BoostClass bookkeeping."
                 "Executes via TS02-C3.C_AQP-ANK|RevokeAnchor."]
                [(format "Anchor {} revoked." [anchor-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_RevokeAnchor)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_AQP-ANK|RevokeBoostClass:object{OuronetInfoV1.ClientInfo}
        (patron:string boost-class-id:string)
        @doc "Cost preview for C_AQP-ANK|RevokeBoostClass. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Revoke an empty BoostClass."
                 "Executes via TS02-C3.C_AQP-ANK|RevokeBoostClass."]
                [(format "BoostClass {} revoked." [boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_RevokeBoostClass)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    ;;[AQP-SCR] Scores
    (defun INFO_AQP-SCR|IssueLiquidityScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Cost preview for C_AQP-SCR|IssueLiquidityScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-0 (Liquidity) score." "Executes via TS02-C3.C_AQP-SCR|IssueLiquidityScore."]
                [(format "Liquidity score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                []))
    )
    (defun INFO_AQP-SCR|IssueTrueFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Cost preview for C_AQP-SCR|IssueTrueFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-1 (True-Fungible) score." "Executes via TS02-C3.C_AQP-SCR|IssueTrueFungibleScore."]
                [(format "True-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                []))
    )
    (defun INFO_AQP-SCR|IssueOrtoFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Cost preview for C_AQP-SCR|IssueOrtoFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-2 (Orto-Fungible / special) score." "Executes via TS02-C3.C_AQP-SCR|IssueOrtoFungibleScore."]
                [(format "Orto-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                []))
    )
    (defun INFO_AQP-SCR|IssueSemiFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Cost preview for C_AQP-SCR|IssueSemiFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-3 (Semi-Fungible) score." "Executes via TS02-C3.C_AQP-SCR|IssueSemiFungibleScore."]
                [(format "Semi-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                []))
    )
    (defun INFO_AQP-SCR|IssueNonFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Cost preview for C_AQP-SCR|IssueNonFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-4 (Non-Fungible) score." "Executes via TS02-C3.C_AQP-SCR|IssueNonFungibleScore."]
                [(format "Non-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                []))
    )
    (defun INFO_AQP-SCR|RotateScoreOwnership:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string new-owner-konto:string)
        @doc "Cost preview for C_AQP-SCR|RotateScoreOwnership. IGNIS 'ignis|medium' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer a score's owner-konto." "Executes via TS02-C3.C_AQP-SCR|RotateScoreOwnership."]
                [(format "Score {} ownership moved to {}." [score-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_RotateOwnership score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|ControlScore:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for C_AQP-SCR|ControlScore. IGNIS 'ignis|medium' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a score's can-upgrade / can-change-owner flags." "Executes via TS02-C3.C_AQP-SCR|ControlScore."]
                [(format "Score {} control flags updated." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_Control score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|CreateScoreBoostClassLink:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string boost-class-id:string)
        @doc "Cost preview for C_AQP-SCR|CreateScoreBoostClassLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a BoostClass (once)." "Executes via TS02-C3.C_AQP-SCR|CreateScoreBoostClassLink."]
                [(format "Score {} linked to BoostClass {}." [score-id boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CreateBoostClassLink score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|CreateScoreBoostLink:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string boost-score-id:string)
        @doc "Cost preview for C_AQP-SCR|CreateScoreBoostLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a boost-score (once)." "Executes via TS02-C3.C_AQP-SCR|CreateScoreBoostLink."]
                [(format "Score {} boost-linked to {}." [score-id boost-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CreateBoostLink score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|EnableDebBoost:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string)
        @doc "Cost preview for C_AQP-SCR|EnableDebBoost. IGNIS 'ignis|medium' tier; no STOA. Irreversible."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable deb-boost on a score (irreversible)." "Executes via TS02-C3.C_AQP-SCR|EnableDebBoost."]
                [(format "Score {} deb-boost enabled." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_EnableDebBoost score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|IssueTriplet:object{OuronetInfoV1.ClientInfo}
        (patron:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Cost preview for C_AQP-SCR|IssueTriplet. IGNIS GAS|ISSUE-TRIPLET; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bundle three scores into one triplet (T|bronze|silver|golden)." "Executes via TS02-C3.C_AQP-SCR|IssueTriplet."]
                [(format "Triplet issued from {} / {} / {}." [bronze-score-id silver-score-id golden-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueTriplet silver-score-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|IssueSingleScoreModel:object{OuronetInfoV1.ClientInfo}
        (patron:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for C_AQP-SCR|IssueSingleScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Define a SINGLE score-entity model." "Executes via TS02-C3.C_AQP-SCR|IssueSingleScoreModel."]
                [(format "Single score model '{}' defined (class {})." [model-name score-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScoreModel patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|CombineTripletScoreModel:object{OuronetInfoV1.ClientInfo}
        (patron:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
        @doc "Cost preview for C_AQP-SCR|CombineTripletScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Combine three SINGLE models into a TRIPLET model." "Executes via TS02-C3.C_AQP-SCR|CombineTripletScoreModel."]
                [(format "Triplet score model '{}' combined." [model-name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScoreModel patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|IssueScoreFromModel:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string model-id:string agency-name:string)
        @doc "Cost preview for C_AQP-SCR|IssueScoreFromModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a score/triplet entity conforming to a model." "Executes via TS02-C3.C_AQP-SCR|IssueScoreFromModel."]
                [(format "Entity '{}' issued from model {} for {}." [agency-name model-id owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScoreModel patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|IssueSemiFungibleScoreDefinition:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for C_AQP-SCR|IssueSemiFungibleScoreDefinition. IGNIS = count × 'ignis|big'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Semi-Fungible score definition rows (one per nonce)." "Executes via TS02-C3.C_AQP-SCR|IssueSemiFungibleScoreDefinition."]
                [(format "Wrote {} SF score-definition rows on score {}." [(length nonces) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueSemiFungibleScoreDefinition score-id nonces)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|IssueNonFungibleScoreDefinition:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Cost preview for C_AQP-SCR|IssueNonFungibleScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible trait-score definition rows (one per trait)." "Executes via TS02-C3.C_AQP-SCR|IssueNonFungibleScoreDefinition."]
                [(format "Wrote {} NF trait-score rows on score {}." [(length trait-keys) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueNonFungibleScoreDefinition score-id trait-keys)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-SCR|IssueNonFungibleSetScoreDefinition:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Cost preview for C_AQP-SCR|IssueNonFungibleSetScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible SET score definition rows (one per nonce-class)." "Executes via TS02-C3.C_AQP-SCR|IssueNonFungibleSetScoreDefinition."]
                [(format "Wrote {} NF set score-definition rows on score {}." [(length dpnf-nonce-classes) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueNonFungibleSetScoreDefinition score-id dpnf-nonce-classes)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;
    ;;[AQP-POOL] Pools (config)
    (defun INFO_AQP-POOL|Issue:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Cost preview for C_AQP-POOL|Issue. IGNIS GAS|ISSUE-POOL + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a new staking pool over an asset." "Executes via TS02-C3.C_AQP-POOL|Issue."]
                [(format "Pool '{}' created over asset {} (class {})." [pool-name asset-id aqp-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_Issue [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-POOL.URCi_IssueStoa))
                []))
    )
    (defun INFO_AQP-POOL|AddScore:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for C_AQP-POOL|AddScore. IGNIS GAS|ADD-SCORE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Assign a score to the pool's first free slot." "Executes via TS02-C3.C_AQP-POOL|AddScore."]
                [(format "Score {} added to pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_AddScore [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|RevokeScore:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for C_AQP-POOL|RevokeScore. IGNIS GAS|REVOKE-SCORE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Clear a score from its pool slot." "Executes via TS02-C3.C_AQP-POOL|RevokeScore."]
                [(format "Score {} revoked from pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_RevokeScore [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|EnablePoolStake:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for C_AQP-POOL|EnablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Re-enable new stakes on a pool." "Executes via TS02-C3.C_AQP-POOL|EnablePoolStake."]
                [(format "Pool {} staking enabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_SetPoolStake [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|DisablePoolStake:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for C_AQP-POOL|DisablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Pause new stakes on a pool." "Executes via TS02-C3.C_AQP-POOL|DisablePoolStake."]
                [(format "Pool {} staking disabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_SetPoolStake [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|SyncTrueFungibleAnchors:object{OuronetInfoV1.ClientInfo}
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Cost preview for C_AQP-POOL|SyncTrueFungibleAnchors. FULL IGNIS: GAS|SYNC-TF-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live TF anchors) + biggest-tier sync-count stamp; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's True-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.C_AQP-POOL|SyncTrueFungibleAnchors."]
                [(format "TF anchors synced for {} on DPTF {}." [beneficiary-id dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncTrueFungibleAnchorsFull beneficiary-id dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|SyncSemiFungibleAnchors:object{OuronetInfoV1.ClientInfo}
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "Cost preview for C_AQP-POOL|SyncSemiFungibleAnchors. FULL IGNIS: GAS|SYNC-COLLECTABLE-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live SF anchors) + biggest-tier sync-count stamp; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Semi-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.C_AQP-POOL|SyncSemiFungibleAnchors."]
                [(format "SF anchors synced for {} on DPSF {}." [beneficiary-id dpsf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncCollectableAnchorsFull beneficiary-id dpsf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|SyncNonFungibleAnchors:object{OuronetInfoV1.ClientInfo}
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "Cost preview for C_AQP-POOL|SyncNonFungibleAnchors. FULL IGNIS: GAS|SYNC-COLLECTABLE-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live NF anchors) + biggest-tier sync-count stamp; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Non-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.C_AQP-POOL|SyncNonFungibleAnchors."]
                [(format "NF anchors synced for {} on DPNF {}." [beneficiary-id dpnf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncCollectableAnchorsFull beneficiary-id dpnf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;<---- stake / unstake (multi-leg reconstructed cost) ---->
    (defun INFO_AQP-POOL|StakeTrueFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Cost preview for CC_AQP-POOL|StakeTrueFungible. Full multi-leg IGNIS (transfer + tracker + rollup \
            \ + RPS + anchor + score-delta + book + checkpoint); no STOA. Cost reconstructed byte-for-byte."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake a True-Fungible amount into the pool for a beneficiary."
                 "Executes via TS02-C3.CC_AQP-POOL|StakeTrueFungible."]
                [(format "Staked {} of {} into pool {} for {}." [amount dptf-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun INFO_AQP-POOL|UnstakeTrueFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Cost preview for CC_AQP-POOL|UnstakeTrueFungible. Same legs as stake with the custody transfer \
            \ reversed (vault→owner); no STOA. Cost reconstructed byte-for-byte."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake a True-Fungible amount from the pool."
                 "Executes via TS02-C3.CC_AQP-POOL|UnstakeTrueFungible."]
                [(format "Unstaked {} of {} from pool {} for {}." [amount dptf-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun INFO_AQP-POOL|StakeOrtoFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for CC_AQP-POOL|StakeOrtoFungible. Multi-leg IGNIS (transfer + tracker×|nonces| + RPS \
            \ + class-matched score-delta + book + checkpoint); no STOA. Reconstructed byte-for-byte."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake whole Orto-Fungible nonces into the pool for a beneficiary."
                 "Executes via TS02-C3.CC_AQP-POOL|StakeOrtoFungible."]
                [(format "Staked {} nonces of {} into pool {} for {}." [(length nonces) dpof-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_OrtoFungibleStakeFlow pool-id owner-id beneficiary-id dpof-id nonces true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    (defun INFO_AQP-POOL|UnstakeOrtoFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for CC_AQP-POOL|UnstakeOrtoFungible. Same legs as OF stake; no STOA. Reconstructed byte-for-byte."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake whole Orto-Fungible nonces from the pool."
                 "Executes via TS02-C3.CC_AQP-POOL|UnstakeOrtoFungible."]
                [(format "Unstaked {} nonces of {} from pool {} for {}." [(length nonces) dpof-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_OrtoFungibleStakeFlow pool-id owner-id beneficiary-id dpof-id nonces false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    (defun INFO_AQP-POOL|StakeSemiFungibleCollectable:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer])
        @doc "Cost preview for CC_AQP-POOL|StakeSemiFungibleCollectable (DPSF, son=true / class-3). Multi-leg IGNIS \
            \ (transfer + tracker×|nonces| + rollup×|nonces| + RPS + flat anchor + class-3 score-delta + book + checkpoint); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake Semi-Fungible collectable nonces (DPSF) into the pool for a beneficiary."
                 "Executes via TS02-C3.CC_AQP-POOL|StakeSemiFungibleCollectable."]
                [(format "Staked {} DPSF nonces of {} into pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id true nonces
                        (DPDC.UR_AccountNoncesSupplies owner-id collectable-id true nonces) true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    (defun INFO_AQP-POOL|UnstakeSemiFungibleCollectable:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Cost preview for CC_AQP-POOL|UnstakeSemiFungibleCollectable (DPSF, son=true / class-3). Same legs as SF stake; \
            \ nonce-amounts is caller-supplied (the staked quantities — owner no longer holds them). No STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake Semi-Fungible collectable nonces (DPSF) from the pool."
                 "Executes via TS02-C3.CC_AQP-POOL|UnstakeSemiFungibleCollectable."]
                [(format "Unstaked {} DPSF nonces of {} from pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id true nonces nonce-amounts false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    (defun INFO_AQP-POOL|StakeNonFungibleCollectable:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer])
        @doc "Cost preview for CC_AQP-POOL|StakeNonFungibleCollectable (DPNF, son=false / class-4). Multi-leg IGNIS \
            \ (transfer + tracker×|nonces| + rollup×|nonces| + RPS + flat anchor + class-4 score-delta + book + checkpoint); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake Non-Fungible collectable nonces (DPNF) into the pool for a beneficiary."
                 "Executes via TS02-C3.CC_AQP-POOL|StakeNonFungibleCollectable."]
                [(format "Staked {} DPNF nonces of {} into pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id false nonces
                        (DPDC.UR_AccountNoncesSupplies owner-id collectable-id false nonces) true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    (defun INFO_AQP-POOL|UnstakeNonFungibleCollectable:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Cost preview for CC_AQP-POOL|UnstakeNonFungibleCollectable (DPNF, son=false / class-4). Same legs as NF stake; \
            \ nonce-amounts is caller-supplied (the staked quantities — owner no longer holds them). No STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake Non-Fungible collectable nonces (DPNF) from the pool."
                 "Executes via TS02-C3.CC_AQP-POOL|UnstakeNonFungibleCollectable."]
                [(format "Unstaked {} DPNF nonces of {} from pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id false nonces nonce-amounts false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)]))
    )
    ;;<---- vacate lifecycle (fixed-cost endpoints) ---->
    (defun INFO_AQP-POOL|BatchVacateTrueFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string dptf-id:string legs:[object{AQP-VCT.VCT|VacateTfLeg}])
        @doc "Cost preview for CCp_AQP-POOL|BatchVacateTrueFungible. Multi-leg IGNIS (per-leg \
            \ tracker-zero + per-beneficiary unwind + one bulk transfer); no STOA. Fed the same \
            \ dirty-read <legs> slice the exec is fed."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one DPTF asset's owner-legs out of the pool."
                 "Executes via TS02-C3.CCp_AQP-POOL|BatchVacateTrueFungible."]
                [(format "Batch-vacated {} legs of {} from pool {}." [(length legs) dptf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchVacateTrueFungible pool-id dptf-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|BatchVacateOrtoFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string dpof-id:string legs:[object{AQP-VCT.VCT|VacateNonceLeg}])
        @doc "Cost preview for CCp_AQP-POOL|BatchVacateOrtoFungible. Multi-leg IGNIS (bulk DPOF \
            \ transfer + per-nonce tracker + per-beneficiary score unwind); no STOA. Fed the same \
            \ dirty-read nonce <legs> slice the exec is fed."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one DPOF asset's owner nonce-legs out of the pool."
                 "Executes via TS02-C3.CCp_AQP-POOL|BatchVacateOrtoFungible."]
                [(format "Batch-vacated {} nonce-legs of {} from pool {}." [(length legs) dpof-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchVacateOrtoFungible pool-id dpof-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|BatchVacateCollectables:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string collectable-id:string son:bool legs:[object{AQP-VCT.VCT|VacateNonceLeg}])
        @doc "Cost preview for CCp_AQP-POOL|BatchVacateCollectables (son=DPSF true / DPNF false). \
            \ Multi-leg IGNIS (bulk transfer + per-nonce tracker + rollup + flat anchor + per- \
            \ beneficiary class-matched score unwind); no STOA. Fed the dirty-read nonce <legs>."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one collectable collection's owner nonce-legs out of the pool."
                 "Executes via TS02-C3.CCp_AQP-POOL|BatchVacateCollectables."]
                [(format "Batch-vacated {} nonce-legs of {} (son={}) from pool {}." [(length legs) collectable-id son pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchVacateCollectables pool-id collectable-id son legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|BatchDrainTrueFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string dptf-id:string legs:[object{AQP-VCT.VCT|VacateTfLeg}])
        @doc "Cost preview for CCp_AQP-POOL|BatchDrainTrueFungible. Score-free drain: per-leg \
            \ tracker-zero + rollup, settle-on-last-drain only for beneficiaries fully drained \
            \ this round (live UserUnn), then one bulk transfer; no STOA. Fed the dirty-read legs."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-drain one DPTF asset's owner-legs out of the pool (score-free)."
                 "Executes via TS02-C3.CCp_AQP-POOL|BatchDrainTrueFungible."]
                [(format "Batch-drained {} legs of {} from pool {}." [(length legs) dptf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchDrainTrueFungible pool-id dptf-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|BatchDrainOrtoFungible:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string dpof-id:string legs:[object{AQP-VCT.VCT|VacateNonceLeg}])
        @doc "Cost preview for CCp_AQP-POOL|BatchDrainOrtoFungible. Score-free drain: bulk DPOF \
            \ transfer + per-nonce tracker + settle-on-last-drain (no anchor); no STOA. Fed the legs."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-drain one DPOF asset's owner nonce-legs out of the pool (score-free)."
                 "Executes via TS02-C3.CCp_AQP-POOL|BatchDrainOrtoFungible."]
                [(format "Batch-drained {} nonce-legs of {} from pool {}." [(length legs) dpof-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchDrainOrtoFungible pool-id dpof-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|BatchDrainCollectable:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string collectable-id:string son:bool legs:[object{AQP-VCT.VCT|VacateNonceLeg}])
        @doc "Cost preview for CCp_AQP-POOL|BatchDrainCollectable (son=DPSF true / DPNF false). \
            \ Score-free drain: bulk transfer + per-leg tracker + rollup + flat anchor + settle- \
            \ on-last-drain; no STOA. Fed the dirty-read nonce <legs>."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-drain one collectable collection's owner nonce-legs out of the pool (score-free)."
                 "Executes via TS02-C3.CCp_AQP-POOL|BatchDrainCollectable."]
                [(format "Batch-drained {} nonce-legs of {} (son={}) from pool {}." [(length legs) collectable-id son pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchDrainCollectable pool-id collectable-id son legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|FullVacate:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string
         tf-lanes:[object{AQP-VCT.VCT|VacateTfLane}]
         of-lanes:[object{AQP-VCT.VCT|VacateNonceLane}]
         coll-lanes:[object{AQP-VCT.VCT|VacateNonceLane}]
         coll-son:bool)
        @doc "Cost preview for CC_AQP-POOL|FullVacate — the single-tx whole-pool vacate. Sums the \
            \ per-asset vacate cost across every dirty-read lane (TF + OF satellites + collectables); \
            \ no STOA. Fed the same lane plan the exec's phase-1 scan builds."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Fully vacate a pool in a single transaction (all assets, all owners)."
                 "Executes via TS02-C3.CC_AQP-POOL|FullVacate."]
                [(format "Fully vacated pool {} ({} TF + {} OF + {} collectable lanes)."
                    [pool-id (length tf-lanes) (length of-lanes) (length coll-lanes)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_FullVacate pool-id tf-lanes of-lanes coll-lanes coll-son))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|FinalizeVacate:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for C_AQP-POOL|FinalizeVacate. IGNIS one flat 'ignis|medium' tier (05_VCT:3016); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Finalize a vacate — nuke employed scores, unfreeze FVTs, re-enable stake."
                 "Executes via TS02-C3.C_AQP-POOL|FinalizeVacate."]
                [(format "Finalized vacate on pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-VCT.URCi_FinalizeVacate)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-POOL|AbortVacate:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for C_AQP-POOL|AbortVacate. Empty cumulator (05_VCT:2989) — costs you nothing."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Abort an in-progress vacate (clear the in-progress flag; stake stays disabled)."
                 "Costs you nothing."
                 "Executes via TS02-C3.C_AQP-POOL|AbortVacate."]
                [(format "Aborted vacate on pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;
    ;;[AQP-FVT] Farms / Vaults / Treasuries (config + rewards)
    (defun INFO_AQP-FVT|Issue:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Cost preview for C_AQP-FVT|Issue. IGNIS GAS|ISSUE-FVT + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a Farm / Vault / Treasury." "Executes via TS02-C3.C_AQP-FVT|Issue."]
                [(format "FVT '{}' created (class {}) for {}." [fvt-name fvt-class owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_Issue owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-FVT.URCi_IssueStoa))
                []))
    )
    (defun INFO_AQP-FVT|RotateOwnership:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string new-owner-konto:string)
        @doc "Cost preview for C_AQP-FVT|RotateOwnership. IGNIS 'ignis|medium'; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer an FVT's owner-konto." "Executes via TS02-C3.C_AQP-FVT|RotateOwnership."]
                [(format "FVT {} ownership moved to {}." [fvt-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_RotateOwnership fvt-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|Control:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for C_AQP-FVT|Control. IGNIS 'ignis|medium'; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set an FVT's can-upgrade / can-change-owner flags." "Executes via TS02-C3.C_AQP-FVT|Control."]
                [(format "FVT {} control flags updated." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_Control fvt-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|SetCommonDenominator:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string common-denominator:string)
        @doc "Cost preview for C_AQP-FVT|SetCommonDenominator. IGNIS GAS|SET-COMMON-DENOMINATOR; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a farm's common-denominator (before any links)." "Executes via TS02-C3.C_AQP-FVT|SetCommonDenominator."]
                [(format "FVT {} common-denominator set to {}." [fvt-id common-denominator])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_SetCommonDenominator fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|SetMosaic:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string mosaic:bool)
        @doc "Cost preview for C_AQP-FVT|SetMosaic. IGNIS GAS|SET-MOSAIC; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Toggle a farm's mosaic membership policy." "Executes via TS02-C3.C_AQP-FVT|SetMosaic."]
                [(format "FVT {} mosaic set to {}." [fvt-id mosaic])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_SetMosaic fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|SetSplitMode:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string split-mode:string)
        @doc "Cost preview for C_AQP-FVT|SetSplitMode. IGNIS GAS|SET-SPLIT-MODE; no STOA. Reports the farm's current \
            \ reward-split mode alongside the requested one."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a farm's reward-split mode (SPLIT|STAKED participation | SPLIT|TVL pool-size)." "Executes via TS02-C3.C_AQP-FVT|SetSplitMode."]
                [(format "Farm {} reward-split mode: {} -> {}." [fvt-id (AQP-FVT.UR_FVT|SplitMode fvt-id) split-mode])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_SetSplitMode fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|AddScoreEntity:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Cost preview for C_AQP-FVT|AddScoreEntity. IGNIS GAS|ADD-SCORE-ENTITY; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Register a score (type 1) or triplet (type 3) on an FVT." "Executes via TS02-C3.C_AQP-FVT|AddScoreEntity."]
                [(format "Score-entity {} (type {}) registered on FVT {}." [score-entity-id score-entity-type fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_AddScoreEntity fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|ToggleScoreEntityLink:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Cost preview for C_AQP-FVT|ToggleScoreEntityLink. IGNIS GAS|TOGGLE-SCORE-ENTITY-LINK; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable/disable a ScoreEntityLink on an FVT." "Executes via TS02-C3.C_AQP-FVT|ToggleScoreEntityLink."]
                [(format "FVT {} score-entity {} enabled={}." [fvt-id score-entity-id enabled])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_ToggleScoreEntityLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|IssueMultipletFamily:object{OuronetInfoV1.ClientInfo}
        (patron:string token-0-id:string token-1-id:string token-2-id:string ats-0-1-id:string ats-1-2-id:string)
        @doc "Cost preview for C_AQP-FVT|IssueMultipletFamily. IGNIS GAS|ISSUE-MULTIPLET-FAMILY; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a chain-wide MultipletFamily reward ladder." "Executes via TS02-C3.C_AQP-FVT|IssueMultipletFamily."]
                [(format "MultipletFamily issued: {} -> {} -> {}." [token-0-id token-1-id token-2-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_IssueMultipletFamily patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|AddRewardLink:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Cost preview for C_AQP-FVT|AddRewardLink. IGNIS GAS|ADD-REWARD-LINK; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Register a reward DPTF on an FVT." "Executes via TS02-C3.C_AQP-FVT|AddRewardLink."]
                [(format "Reward {} linked on FVT {} (family {})." [reward-dptf-id fvt-id multiplet-family-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_AddRewardLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|ToggleRewardLink:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Cost preview for C_AQP-FVT|ToggleRewardLink. IGNIS GAS|TOGGLE-REWARD-LINK; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Toggle a reward link's enabled flag." "Executes via TS02-C3.C_AQP-FVT|ToggleRewardLink."]
                [(format "FVT {} reward {} enabled={}." [fvt-id reward-dptf-id enabled])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_ToggleRewardLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|SetQualitySplit:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Cost preview for C_AQP-FVT|SetQualitySplit. IGNIS GAS|SET-QUALITY-SPLIT; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a MULTIPLET_BASE reward's quality-split mode + matrix." "Executes via TS02-C3.C_AQP-FVT|SetQualitySplit."]
                [(format "FVT {} reward {} quality-split mode={}." [fvt-id reward-dptf-id mode])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_SetQualitySplit fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|InjectStream:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Cost preview for CC_AQP-FVT|InjectStream. IGNIS GAS|INJECT; STOA none (custody transfer)."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Inject reward tokens as a linear time-stream over the given duration."
                 "Executes via TS02-C3.CC_AQP-FVT|InjectStream."]
                [(format "Streaming {} of {} into FVT {} over {}s." [amount reward-dptf-id fvt-id duration])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_Inject fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun INFO_AQP-FVT|Inject:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for CC_AQP-FVT|Inject (enforced-fresh single-tx inject). IGNIS GAS|INJECT; STOA none."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enforced-fresh single-tx inject (fixes all stale members first)."
                 "Executes via TS02-C3.CC_AQP-FVT|Inject."]
                [(format "Fresh-injected {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_Inject fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun INFO_AQP-FVT|InjectFinalize:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for CC_AQP-FVT|InjectFinalize. IGNIS GAS|INJECT; STOA none."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Finalize a paginated fresh inject (zero-stale gate, then inject)."
                 "Executes via TS02-C3.CC_AQP-FVT|InjectFinalize."]
                [(format "Finalized fresh inject of {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_Inject fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun INFO_AQP-FVT|InjectFixChunk:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Cost preview for CCp_AQP-FVT|InjectFixChunk. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Page the enforced-fresh FIX phase (up to `chunk` stale members)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.CCp_AQP-FVT|InjectFixChunk."]
                [(format "Fixed up to {} stale members on FVT {} reward {}." [chunk fvt-id reward-dptf-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|UnstaleAll:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Cost preview for CCp_AQP-FVT|UnstaleAll. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Owner mass deb-unstale (make injection-ready; no inject)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.CCp_AQP-FVT|UnstaleAll."]
                [(format "Unstaled up to {} members on FVT {}." [chunk fvt-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|UnstaleMyScores:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-ids:[string])
        @doc "Cost preview for CC_AQP-FVT|UnstaleMyScores. IGNIS GAS|UNSTALE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Self-service deb-unstale of your own scores across FVTs." "Executes via TS02-C3.CC_AQP-FVT|UnstaleMyScores."]
                [(format "Unstaled your scores across {} FVTs." [(length fvt-ids)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_UnstaleMyScores patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|Collect:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Cost preview for CC_AQP-FVT|Collect. FULL IGNIS: reward-payout leg (plain TFT transfer, or a \
            \ MULTIPLET_BASE triplet Coil/Curl ladder) + Phase-7 forced-fix penalty + GAS|COLLECT; STOA none. \
            \ Reconstructed on the current claimable state (exact for un-streamed / settled lanes)."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Collect your claimable reward from this FVT membership."
                 "Full IGNIS shown: payout transfer/ladder + any forced-fix penalty + gas (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.CC_AQP-FVT|Collect."]
                [(format "Collected reward token {} from score-entity {}." [reward-dptf-id score-entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-FVT.URCi_CollectFull patron fvt-id score-entity-type score-entity-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|SweepRevokeAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for CC_AQP-FVT|SweepRevokeAnchor. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Single-tx re-score sweep retiring an employed anchor."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.CC_AQP-FVT|SweepRevokeAnchor."]
                [(format "Swept + retired anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|SweepBegin:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for CC_AQP-FVT|SweepBegin. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Open a paginated re-score sweep (freeze + swept-revoke + cursor)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.CC_AQP-FVT|SweepBegin."]
                [(format "Opened sweep on anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-FVT|SweepRecomputeChunk:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string chunk:integer)
        @doc "Cost preview for CCp_AQP-FVT|SweepRecomputeChunk. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Page a re-score sweep (recompute the next `chunk` holders; final page unfreezes)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.CCp_AQP-FVT|SweepRecomputeChunk."]
                [(format "Recomputed up to {} holders on anchor {}'s sweep." [chunk anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;
    ;;[AQP-DSA] Delegated Staking Agencies
    (defun INFO_AQP-DSA|DefineDelegationVault:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string model-id:string unit-score:integer)
        @doc "Cost preview for A_AQP-DSA|DefineDelegationVault. IGNIS GAS|DEFINE-VAULT; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bind a class-0 FVT as a DSA delegation vault." "Executes via TS02-C3.A_AQP-DSA|DefineDelegationVault."]
                [(format "FVT {} bound as delegation vault (model {})." [fvt-id model-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_DefineDelegationVault patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-DSA|OpenAgency:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string pool-id:string score-entity-id:string fee-per-mille:integer collectable-id:string stake-nonces:[integer])
        @doc "Cost preview for C_AQP-DSA|OpenAgency. IGNIS GAS|OPEN-AGENCY base; the atomic open also stakes the \
            \ operator's collateral (staking legs added at execution). No STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Open a delegation agency (admit + operator-stake + terminal gate)."
                 "Base IGNIS shown; the operator collateral stake adds its legs at execution."
                 "Executes via TS02-C3.C_AQP-DSA|OpenAgency."]
                [(format "Agency {} opened on vault {} (fee {} per-mille)." [score-entity-id fvt-id fee-per-mille])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_OpenAgency patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-DSA|RecomputeCapture:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string)
        @doc "Cost preview for C_AQP-DSA|RecomputeCapture. IGNIS GAS|RECOMPUTE-CAPTURE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Recompute an agency's capture (permissionless; preserves oracle-ts)." "Executes via TS02-C3.C_AQP-DSA|RecomputeCapture."]
                [(format "Agency {} capture recomputed on vault {}." [score-entity-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_RecomputeCapture patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-DSA|SetOracleAuth:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string oracle-guard:guard)
        @doc "Cost preview for A_AQP-DSA|SetOracleAuth. IGNIS GAS|SET-ORACLE-AUTH; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Authorize the delegated oracle key + arm the capture expiry." "Executes via TS02-C3.A_AQP-DSA|SetOracleAuth."]
                [(format "Oracle authority set on vault {}." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_SetOracleAuth patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-DSA|OracleWrite:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "Cost preview for A_AQP-DSA|OracleWrite. IGNIS GAS|ORACLE-WRITE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Oracle writes an agency's daily {nodes, uptime} + recomputes its capture." "Executes via TS02-C3.A_AQP-DSA|OracleWrite."]
                [(format "Oracle wrote nodes {} / uptime {} for agency {}." [nodes uptime score-entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_OracleWrite patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-DSA|ToggleExternalOracle:object{OuronetInfoV1.ClientInfo}
        (on:bool)
        @doc "Cost preview for A_AQP-DSA|ToggleExternalOracle. Chain-wide GOV switch — no IGNIS/STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Flip the SINGULAR GLOBAL external-oracle switch for ALL agencies (governance)."
                 "Master-signed governance action — no gas."
                 "Executes via TS02-C3.A_AQP-DSA|ToggleExternalOracle."]
                [(format "Global external-oracle switch set to {}." [on])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-DSA|SetOracleValidity:object{OuronetInfoV1.ClientInfo}
        (seconds:integer)
        @doc "Cost preview for A_AQP-DSA|SetOracleValidity. Chain-wide GOV switch — no IGNIS/STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set the GLOBAL oracle-validity window (freshness horizon; governance)."
                 "Master-signed governance action — no gas."
                 "Executes via TS02-C3.A_AQP-DSA|SetOracleValidity."]
                [(format "Global oracle-validity window set to {} seconds." [seconds])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-DSA|WithdrawRoyalty:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Cost preview for A_AQP-DSA|WithdrawRoyalty. FULL IGNIS: GAS|WITHDRAW-ROYALTY gas leg + the state- \
            \ dependent custody-move leg (normalize + TFT transfer of the live royalty pool to the FVT owner); STOA none."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Withdraw the whole royalty pool to the FVT owner."
                 "Full IGNIS shown: gas + custody move (reconstructed from the live royalty balance)."
                 "Executes via TS02-C3.A_AQP-DSA|WithdrawRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} withdrawn to owner." [reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-DSA.URCi_WithdrawRoyaltyFull patron fvt-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-DSA|BurnRoyalty:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Cost preview for A_AQP-DSA|BurnRoyalty. FULL IGNIS: GAS|BURN-ROYALTY gas leg + the state-dependent \
            \ custody-burn leg (normalize + DPTF burn of the live royalty pool); STOA none."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Burn the whole royalty pool."
                 "Full IGNIS shown: gas + custody burn (reconstructed from the live royalty balance)."
                 "Executes via TS02-C3.A_AQP-DSA|BurnRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} burned." [reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-DSA.URCi_BurnRoyaltyFull patron fvt-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-DSA|FuelRoyalty:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Cost preview for A_AQP-DSA|FuelRoyalty. FULL IGNIS: GAS|FUEL-ROYALTY gas leg + the state-dependent \
            \ custody-fuel leg (normalize + SWPLC fuel of the live royalty pool into the swpair); STOA none."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Fuel a swap pair with the whole royalty pool (no LP mint)."
                 "Full IGNIS shown: gas + custody fuel (reconstructed from the live royalty balance)."
                 "Executes via TS02-C3.A_AQP-DSA|FuelRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} fueled into {}." [reward-dptf-id fvt-id swpair])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-DSA.URCi_FuelRoyaltyFull patron fvt-id reward-dptf-id swpair))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    (defun INFO_AQP-DSA|SetAgencyFee:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Cost preview for A_AQP-DSA|SetAgencyFee. IGNIS GAS|SET-AGENCY-FEE; no STOA. O(1) reprice."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Change a delegation agency's operator fee (reprices only future injects)." "Executes via TS02-C3.A_AQP-DSA|SetAgencyFee."]
                [(format "Agency {} fee set to {} per-mille." [score-entity-id fee-per-mille])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_SetAgencyFee patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;
    ;;[AQP-MTX] Matrix drivers (spike-fallback defpacts)
    (defun INFO_AQP-MTX|2Inject:object{OuronetInfoV1.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for C_MTX-AQP|2|Inject (2-step enforced-fresh inject). IGNIS GAS|INJECT (inner XB_FvtInject); STOA none."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: 2-step enforced-fresh inject (spike fallback for CC_Inject on vault/treasury)."
                 "Executes via TS02-C3.C_MTX-AQP|2|Inject."]
                [(format "2-step fresh-injected {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_Inject fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount]))
    )
    (defun INFO_AQP-MTX|2SweepRevokeAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for C_MTX-AQP|2|SweepRevokeAnchor. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let ((ref-I|OURONET:module{OuronetInfoV1} IGNIS))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: 2-step paginated sweep retiring an employed anchor (spike fallback for CC_SweepRevokeAnchor)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.C_MTX-AQP|2|SweepRevokeAnchor."]
                [(format "2-step swept + retired anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []))
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

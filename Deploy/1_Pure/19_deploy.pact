;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 19 of 22
;; This is STEP 19 of 23 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-18 must have run first, including the init steps between deploys.
;; 3 source file(s), 149,410 gas measured in the REPL gas model, 236,546 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact
;;   1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact
;;   1_SOVEREIGN/STAGE_02/3_Talos/02_TS02-C2.pact
;;
;; TOTAL: 2 interface(s), 3 module(s), 4 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact
;;      module     AQP-INFO
;;   -- 1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact
;;      interface  TalosStageTwo_ClientOneV2
;;      module     TS02-C1
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/3_Talos/02_TS02-C2.pact
;;      interface  TalosStageTwo_ClientTwoV2
;;      module     TS02-C2
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact =========
;; ================================================================================
;; AQP-INFO — pre-execution COST PREVIEW surface for the AQP modules.
;;
;; Each AQP-<MOD>|INFO_<Fn> is the read-only counterpart of a TS02-C3 execution
;; wrapper. It returns object{OuronetInfoV2.ClientInfo} describing what the op does,
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
    @doc "Read-only pre-execution cost-preview module for the AQP family. Each INFO_ \
        \ function mirrors a TS02-C3 execution wrapper and returns an \
        \ OuronetInfoV2.ClientInfo describing the operation, its execution function, and the \
        \ exact IGNIS+STOA price for an account — sourced from each AQP module's URCi_ cost \
        \ readers so previews match execution byte-for-byte. A leaf module with no \
        \ interface; never writes; deploys after all AQP cores and TS02-C3."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_INFO|AQP                           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|INFO|AQP_ADMIN)))
    (defcap GOV|INFO|AQP_ADMIN ()                       (enforce-guard GOV|MD_INFO|AQP))
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
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;   (AQP-{ANK,SCORE,POOL,FVT,VCT,DSA}.URCi_*, via OI|UC_IfpFromOutputCumulator / OI|UDC_DynamicStoaCost),
    ;;   so the local price-tier gates (UC_GasPrice / SIP|URC_* / SKP|URC_*) are no longer used here.
    ;;
    ;;[AQP-ANK] Anchors
    (defun INFO_AQP-ANK|IssueTrueFungibleAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Cost preview for AQP-ANK|C_IssueTrueFungibleAnchor. IGNIS 1000 (inline) + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a True-Fungible (DPTF) anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueTrueFungibleAnchor."]
                [(format "Anchor '{}' issued on DPTF {}." [anchor-name dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor "AQP-ANK|C_IssueTrueFungibleAnchor" [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|IssueSemiFungibleAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Cost preview for AQP-ANK|C_IssueSemiFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Semi-Fungible (DPSF) anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueSemiFungibleAnchor."]
                [(format "Anchor '{}' issued on DPSF {} nonce {}." [anchor-name dpsf-id dpsf-nonce])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor "AQP-ANK|C_IssueSemiFungibleAnchor" [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|IssueNonFungibleAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Cost preview for AQP-ANK|C_IssueNonFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Non-Fungible (DPNF) trait-anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueNonFungibleAnchor."]
                [(format "Anchor '{}' issued on DPNF {} trait {}={}." [anchor-name dpnf-id dpnf-trait-key dpnf-trait-value])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor "AQP-ANK|C_IssueNonFungibleAnchor" [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|IssueNonFungibleSetAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Cost preview for AQP-ANK|C_IssueNonFungibleSetAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Non-Fungible (DPNF) set-anchor (by nonce-class) for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueNonFungibleSetAnchor."]
                [(format "Anchor '{}' issued on DPNF {} nonce-class {}." [anchor-name dpnf-id dpnf-nonce-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_IssueAnchor "AQP-ANK|C_IssueNonFungibleSetAnchor" [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (ref-ANK::URCi_IssueAnchorStoa acnoi))
                []
            )
        )
    )
    (defun INFO_AQP-ANK|RevokeAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-ANK|C_RevokeAnchor. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Revoke an anchor and update its BoostClass bookkeeping."
                 "Executes via TS02-C3.AQP-ANK|C_RevokeAnchor."]
                [(format "Anchor {} revoked." [anchor-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_RevokeAnchor)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_AQP-ANK|RevokeBoostClass:object{OuronetInfoV2.ClientInfo}
        (patron:string boost-class-id:string)
        @doc "Cost preview for AQP-ANK|C_RevokeBoostClass. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Revoke an empty BoostClass."
                 "Executes via TS02-C3.AQP-ANK|C_RevokeBoostClass."]
                [(format "BoostClass {} revoked." [boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ANK::URCi_RevokeBoostClass)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;
    ;;[AQP-SCR] Scores
    (defun INFO_AQP-SCR|IssueLiquidityScore:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueLiquidityScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-0 (Liquidity) score." "Executes via TS02-C3.AQP-SCR|C_IssueLiquidityScore."]
                [(format "Liquidity score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueTrueFungibleScore:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueTrueFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-1 (True-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueTrueFungibleScore."]
                [(format "True-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueOrtoFungibleScore:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueOrtoFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-2 (Orto-Fungible / special) score." "Executes via TS02-C3.AQP-SCR|C_IssueOrtoFungibleScore."]
                [(format "Orto-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueSemiFungibleScore:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Cost preview for AQP-SCR|C_IssueSemiFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-3 (Semi-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueSemiFungibleScore."]
                [(format "Semi-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueNonFungibleScore:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-4 (Non-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleScore."]
                [(format "Non-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|RotateScoreOwnership:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string new-owner-konto:string)
        @doc "Cost preview for AQP-SCR|C_RotateScoreOwnership. IGNIS 'ignis|medium' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer a score's owner-konto." "Executes via TS02-C3.AQP-SCR|C_RotateScoreOwnership."]
                [(format "Score {} ownership moved to {}." [score-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_RotateOwnership score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|ControlScore:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for AQP-SCR|C_ControlScore. IGNIS 'ignis|medium' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a score's can-upgrade / can-change-owner flags." "Executes via TS02-C3.AQP-SCR|C_ControlScore."]
                [(format "Score {} control flags updated." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_Control score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|CreateScoreBoostClassLink:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string boost-class-id:string)
        @doc "Cost preview for AQP-SCR|C_CreateScoreBoostClassLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a BoostClass (once)." "Executes via TS02-C3.AQP-SCR|C_CreateScoreBoostClassLink."]
                [(format "Score {} linked to BoostClass {}." [score-id boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CreateBoostClassLink score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|CreateScoreBoostLink:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string boost-score-id:string)
        @doc "Cost preview for AQP-SCR|C_CreateScoreBoostLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a boost-score (once)." "Executes via TS02-C3.AQP-SCR|C_CreateScoreBoostLink."]
                [(format "Score {} boost-linked to {}." [score-id boost-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CreateBoostLink score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|EnableDebBoost:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string)
        @doc "Cost preview for AQP-SCR|C_EnableDebBoost. IGNIS 'ignis|medium' tier; no STOA. Irreversible."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable deb-boost on a score (irreversible)." "Executes via TS02-C3.AQP-SCR|C_EnableDebBoost."]
                [(format "Score {} deb-boost enabled." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_EnableDebBoost score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueTriplet:object{OuronetInfoV2.ClientInfo}
        (patron:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Cost preview for AQP-SCR|C_IssueTriplet. IGNIS GAS|ISSUE-TRIPLET; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bundle three scores into one triplet (T|bronze|silver|golden)." "Executes via TS02-C3.AQP-SCR|C_IssueTriplet."]
                [(format "Triplet issued from {} / {} / {}." [bronze-score-id silver-score-id golden-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueTriplet silver-score-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueSingleScoreModel:object{OuronetInfoV2.ClientInfo}
        (patron:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueSingleScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Define a SINGLE score-entity model." "Executes via TS02-C3.AQP-SCR|C_IssueSingleScoreModel."]
                [(format "Single score model '{}' defined (class {})." [model-name score-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScoreModel "AQP-SCR|C_IssueSingleScoreModel" patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|CombineTripletScoreModel:object{OuronetInfoV2.ClientInfo}
        (patron:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
        @doc "Cost preview for AQP-SCR|C_CombineTripletScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Combine three SINGLE models into a TRIPLET model." "Executes via TS02-C3.AQP-SCR|C_CombineTripletScoreModel."]
                [(format "Triplet score model '{}' combined." [model-name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CombineTripletModel patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueScoreFromModel:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string model-id:string agency-name:string)
        @doc "Cost preview for AQP-SCR|C_IssueScoreFromModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a score/triplet entity conforming to a model." "Executes via TS02-C3.AQP-SCR|C_IssueScoreFromModel."]
                [(format "Entity '{}' issued from model {} for {}." [agency-name model-id owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScoreModel "AQP-SCR|C_IssueScoreFromModel" patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueSemiFungibleScoreDefinition:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueSemiFungibleScoreDefinition. IGNIS = count × 'ignis|big'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Semi-Fungible score definition rows (one per nonce)." "Executes via TS02-C3.AQP-SCR|C_IssueSemiFungibleScoreDefinition."]
                [(format "Wrote {} SF score-definition rows on score {}." [(length nonces) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueSemiFungibleScoreDefinition score-id nonces)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueNonFungibleScoreDefinition:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible trait-score definition rows (one per trait)." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleScoreDefinition."]
                [(format "Wrote {} NF trait-score rows on score {}." [(length trait-keys) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueNonFungibleScoreDefinition score-id trait-keys)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueNonFungibleSetScoreDefinition:object{OuronetInfoV2.ClientInfo}
        (patron:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleSetScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible SET score definition rows (one per nonce-class)." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleSetScoreDefinition."]
                [(format "Wrote {} NF set score-definition rows on score {}." [(length dpnf-nonce-classes) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueNonFungibleSetScoreDefinition score-id dpnf-nonce-classes)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;
    ;;[AQP-POOL] Pools (config)
    (defun INFO_AQP-POOL|Issue:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Cost preview for AQP-POOL|C_Issue. IGNIS GAS|ISSUE-POOL + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a new staking pool over an asset." "Executes via TS02-C3.AQP-POOL|C_Issue."]
                [(format "Pool '{}' created over asset {} (class {})." [pool-name asset-id aqp-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_Issue [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-POOL.URCi_IssueStoa))
                [])
        )
    )
    (defun INFO_AQP-POOL|AddScore:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|C_AddScore. IGNIS GAS|ADD-SCORE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Assign a score to the pool's first free slot." "Executes via TS02-C3.AQP-POOL|C_AddScore."]
                [(format "Score {} added to pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_AddScore [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|RevokeScore:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|C_RevokeScore. IGNIS GAS|REVOKE-SCORE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Clear a score from its pool slot." "Executes via TS02-C3.AQP-POOL|C_RevokeScore."]
                [(format "Score {} revoked from pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_RevokeScore [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|EnablePoolStake:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_EnablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Re-enable new stakes on a pool." "Executes via TS02-C3.AQP-POOL|C_EnablePoolStake."]
                [(format "Pool {} staking enabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_SetPoolStake [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|DisablePoolStake:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_DisablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Pause new stakes on a pool." "Executes via TS02-C3.AQP-POOL|C_DisablePoolStake."]
                [(format "Pool {} staking disabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_SetPoolStake [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|SyncTrueFungibleAnchors:object{OuronetInfoV2.ClientInfo}
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncTrueFungibleAnchors. FULL IGNIS: GAS|SYNC-TF-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live TF anchors) + biggest-tier sync-count stamp; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's True-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-POOL|C_SyncTrueFungibleAnchors."]
                [(format "TF anchors synced for {} on DPTF {}." [beneficiary-id dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncTrueFungibleAnchorsFull beneficiary-id dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|SyncSemiFungibleAnchors:object{OuronetInfoV2.ClientInfo}
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncSemiFungibleAnchors. FULL IGNIS: GAS|SYNC-COLLECTABLE-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live SF anchors) + biggest-tier sync-count stamp; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Semi-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-POOL|C_SyncSemiFungibleAnchors."]
                [(format "SF anchors synced for {} on DPSF {}." [beneficiary-id dpsf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncCollectableAnchorsFull beneficiary-id dpsf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|SyncNonFungibleAnchors:object{OuronetInfoV2.ClientInfo}
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncNonFungibleAnchors. FULL IGNIS: GAS|SYNC-COLLECTABLE-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live NF anchors) + biggest-tier sync-count stamp; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Non-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-POOL|C_SyncNonFungibleAnchors."]
                [(format "NF anchors synced for {} on DPNF {}." [beneficiary-id dpnf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncCollectableAnchorsFull beneficiary-id dpnf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;<---- stake / unstake (multi-leg reconstructed cost) ---->
    (defun INFO_AQP-POOL|StakeTrueFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-POOL|CC_StakeTrueFungible. Full multi-leg IGNIS (transfer + tracker + rollup \
            \ + RPS + anchor + score-delta + book + checkpoint); no STOA. Cost reconstructed byte-for-byte."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake a True-Fungible amount into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeTrueFungible."]
                [(format "Staked {} of {} into pool {} for {}." [amount dptf-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-POOL|UnstakeTrueFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-POOL|CC_UnstakeTrueFungible. Same legs as stake with the custody transfer \
            \ reversed (vault→owner); no STOA. Cost reconstructed byte-for-byte."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake a True-Fungible amount from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeTrueFungible."]
                [(format "Unstaked {} of {} from pool {} for {}." [amount dptf-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-POOL|StakeOrtoFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeOrtoFungible. Multi-leg IGNIS (transfer + tracker×|nonces| + RPS \
            \ + class-matched score-delta + book + checkpoint); no STOA. Reconstructed byte-for-byte."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake whole Orto-Fungible nonces into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeOrtoFungible."]
                [(format "Staked {} nonces of {} into pool {} for {}." [(length nonces) dpof-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_OrtoFungibleStakeFlow pool-id owner-id beneficiary-id dpof-id nonces true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|UnstakeOrtoFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeOrtoFungible. Same legs as OF stake; no STOA. Reconstructed byte-for-byte."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake whole Orto-Fungible nonces from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeOrtoFungible."]
                [(format "Unstaked {} nonces of {} from pool {} for {}." [(length nonces) dpof-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_OrtoFungibleStakeFlow pool-id owner-id beneficiary-id dpof-id nonces false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|StakeSemiFungibleCollectable:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeSemiFungibleCollectable (DPSF, son=true / class-3). Multi-leg IGNIS \
            \ (transfer + tracker×|nonces| + rollup×|nonces| + RPS + flat anchor + class-3 score-delta + book + checkpoint); no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake Semi-Fungible collectable nonces (DPSF) into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeSemiFungibleCollectable."]
                [(format "Staked {} DPSF nonces of {} into pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id true nonces
                        (DPDC.UR_AccountNoncesSupplies owner-id collectable-id true nonces) true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|UnstakeSemiFungibleCollectable:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeSemiFungibleCollectable (DPSF, son=true / class-3). Same legs as SF stake; \
            \ nonce-amounts is caller-supplied (the staked quantities — owner no longer holds them). No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake Semi-Fungible collectable nonces (DPSF) from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeSemiFungibleCollectable."]
                [(format "Unstaked {} DPSF nonces of {} from pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id true nonces nonce-amounts false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|StakeNonFungibleCollectable:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeNonFungibleCollectable (DPNF, son=false / class-4). Multi-leg IGNIS \
            \ (transfer + tracker×|nonces| + rollup×|nonces| + RPS + flat anchor + class-4 score-delta + book + checkpoint); no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake Non-Fungible collectable nonces (DPNF) into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeNonFungibleCollectable."]
                [(format "Staked {} DPNF nonces of {} into pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id false nonces
                        (DPDC.UR_AccountNoncesSupplies owner-id collectable-id false nonces) true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|UnstakeNonFungibleCollectable:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeNonFungibleCollectable (DPNF, son=false / class-4). Same legs as NF stake; \
            \ nonce-amounts is caller-supplied (the staked quantities — owner no longer holds them). No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake Non-Fungible collectable nonces (DPNF) from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeNonFungibleCollectable."]
                [(format "Unstaked {} DPNF nonces of {} from pool {} for {}." [(length nonces) collectable-id pool-id beneficiary-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (RPS.URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id false nonces nonce-amounts false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    ;;<---- vacate lifecycle (fixed-cost endpoints) ---->
    (defun INFO_AQP-POOL|BatchVacateTrueFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateTrueFungible. Multi-leg IGNIS (per-leg \
            \ tracker-zero + per-beneficiary unwind + one bulk transfer); no STOA. Fed the same \
            \ dirty-read <legs> slice the exec is fed."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one DPTF asset's owner-legs out of the pool."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchVacateTrueFungible."]
                [(format "Batch-vacated {} legs of {} from pool {}." [(length legs) dptf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchVacateTrueFungible pool-id dptf-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BatchVacateOrtoFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dpof-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateOrtoFungible. Multi-leg IGNIS (bulk DPOF \
            \ transfer + per-nonce tracker + per-beneficiary score unwind); no STOA. Fed the same \
            \ dirty-read nonce <legs> slice the exec is fed."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one DPOF asset's owner nonce-legs out of the pool."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchVacateOrtoFungible."]
                [(format "Batch-vacated {} nonce-legs of {} from pool {}." [(length legs) dpof-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchVacateOrtoFungible pool-id dpof-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BatchVacateCollectables:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string collectable-id:string son:bool legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateCollectables (son=DPSF true / DPNF false). \
            \ Multi-leg IGNIS (bulk transfer + per-nonce tracker + rollup + flat anchor + per- \
            \ beneficiary class-matched score unwind); no STOA. Fed the dirty-read nonce <legs>."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-vacate one collectable collection's owner nonce-legs out of the pool."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchVacateCollectables."]
                [(format "Batch-vacated {} nonce-legs of {} (son={}) from pool {}." [(length legs) collectable-id son pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchVacateCollectables pool-id collectable-id son legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BatchDrainTrueFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchDrainTrueFungible. Score-free drain: per-leg \
            \ tracker-zero + rollup, settle-on-last-drain only for beneficiaries fully drained \
            \ this round (live UserUnn), then one bulk transfer; no STOA. Fed the dirty-read legs."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-drain one DPTF asset's owner-legs out of the pool (score-free)."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchDrainTrueFungible."]
                [(format "Batch-drained {} legs of {} from pool {}." [(length legs) dptf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchDrainTrueFungible pool-id dptf-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BatchDrainOrtoFungible:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string dpof-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchDrainOrtoFungible. Score-free drain: bulk DPOF \
            \ transfer + per-nonce tracker + settle-on-last-drain (no anchor); no STOA. Fed the legs."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-drain one DPOF asset's owner nonce-legs out of the pool (score-free)."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchDrainOrtoFungible."]
                [(format "Batch-drained {} nonce-legs of {} from pool {}." [(length legs) dpof-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchDrainOrtoFungible pool-id dpof-id legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BatchDrainCollectable:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string collectable-id:string son:bool legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchDrainCollectable (son=DPSF true / DPNF false). \
            \ Score-free drain: bulk transfer + per-leg tracker + rollup + flat anchor + settle- \
            \ on-last-drain; no STOA. Fed the dirty-read nonce <legs>."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Batch-drain one collectable collection's owner nonce-legs out of the pool (score-free)."
                 "Executes via TS02-C3.AQP-POOL|CCp_BatchDrainCollectable."]
                [(format "Batch-drained {} nonce-legs of {} (son={}) from pool {}." [(length legs) collectable-id son pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_BatchDrainCollectable pool-id collectable-id son legs))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|FullVacate:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string
         tf-lanes:[object{AcquisitionSchemasV1.VCT|VacateTfLane}]
         of-lanes:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}]
         coll-lanes:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}]
         coll-son:bool)
        @doc "Cost preview for AQP-POOL|CC_FullVacate — the single-tx whole-pool vacate. Sums the \
            \ per-asset vacate cost across every dirty-read lane (TF + OF satellites + collectables); \
            \ no STOA. Fed the same lane plan the exec's phase-1 scan builds."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Fully vacate a pool in a single transaction (all assets, all owners)."
                 "Executes via TS02-C3.AQP-POOL|CC_FullVacate."]
                [(format "Fully vacated pool {} ({} TF + {} OF + {} collectable lanes)."
                    [pool-id (length tf-lanes) (length of-lanes) (length coll-lanes)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_FullVacate pool-id tf-lanes of-lanes coll-lanes coll-son))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|FinalizeVacate:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_FinalizeVacate. IGNIS one flat 'ignis|medium' tier (05_VCT:3016); no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Finalize a vacate — nuke employed scores, unfreeze FVTs, re-enable stake."
                 "Executes via TS02-C3.AQP-POOL|C_FinalizeVacate."]
                [(format "Finalized vacate on pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-VCT.URCi_FinalizeVacate)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|AbortVacate:object{OuronetInfoV2.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_AbortVacate. Empty cumulator (05_VCT:2989) — costs you nothing."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Abort an in-progress vacate (clear the in-progress flag; stake stays disabled)."
                 "Costs you nothing."
                 "Executes via TS02-C3.AQP-POOL|C_AbortVacate."]
                [(format "Aborted vacate on pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;
    ;;[AQP-FVT] Farms / Vaults / Treasuries (config + rewards)
    (defun INFO_AQP-FVT|Issue:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Cost preview for AQP-FVT|C_Issue. IGNIS GAS|ISSUE-FVT + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a Farm / Vault / Treasury." "Executes via TS02-C3.AQP-FVT|C_Issue."]
                [(format "FVT '{}' created (class {}) for {}." [fvt-name fvt-class owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_Issue owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-FVT.URCi_IssueStoa))
                [])
        )
    )
    (defun INFO_AQP-FVT|RotateOwnership:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string new-owner-konto:string)
        @doc "Cost preview for AQP-FVT|C_RotateOwnership. IGNIS 'ignis|medium'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer an FVT's owner-konto." "Executes via TS02-C3.AQP-FVT|C_RotateOwnership."]
                [(format "FVT {} ownership moved to {}." [fvt-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_RotateOwnership fvt-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|Control:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for AQP-FVT|C_Control. IGNIS 'ignis|medium'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set an FVT's can-upgrade / can-change-owner flags." "Executes via TS02-C3.AQP-FVT|C_Control."]
                [(format "FVT {} control flags updated." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_Control fvt-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetCommonDenominator:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string common-denominator:string)
        @doc "Cost preview for AQP-FVT|C_SetCommonDenominator. IGNIS GAS|SET-COMMON-DENOMINATOR; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a farm's common-denominator (before any links)." "Executes via TS02-C3.AQP-FVT|C_SetCommonDenominator."]
                [(format "FVT {} common-denominator set to {}." [fvt-id common-denominator])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_SetCommonDenominator fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetMosaic:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string mosaic:bool)
        @doc "Cost preview for AQP-FVT|C_SetMosaic. IGNIS GAS|SET-MOSAIC; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Toggle a farm's mosaic membership policy." "Executes via TS02-C3.AQP-FVT|C_SetMosaic."]
                [(format "FVT {} mosaic set to {}." [fvt-id mosaic])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_SetMosaic fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetSplitMode:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string split-mode:string)
        @doc "Cost preview for AQP-FVT|C_SetSplitMode. IGNIS GAS|SET-SPLIT-MODE; no STOA. Reports the farm's current \
            \ reward-split mode alongside the requested one."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a farm's reward-split mode (SPLIT|STAKED participation | SPLIT|TVL pool-size)." "Executes via TS02-C3.AQP-FVT|C_SetSplitMode."]
                [(format "Farm {} reward-split mode: {} -> {}." [fvt-id (RPS.UR_FVT|SplitMode fvt-id) split-mode])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_SetSplitMode fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|AddScoreEntity:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Cost preview for AQP-FVT|C_AddScoreEntity. IGNIS GAS|ADD-SCORE-ENTITY; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Register a score (type 1) or triplet (type 3) on an FVT." "Executes via TS02-C3.AQP-FVT|C_AddScoreEntity."]
                [(format "Score-entity {} (type {}) registered on FVT {}." [score-entity-id score-entity-type fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_AddScoreEntity fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|ToggleScoreEntityLink:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Cost preview for AQP-FVT|C_ToggleScoreEntityLink. IGNIS GAS|TOGGLE-SCORE-ENTITY-LINK; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable/disable a ScoreEntityLink on an FVT." "Executes via TS02-C3.AQP-FVT|C_ToggleScoreEntityLink."]
                [(format "FVT {} score-entity {} enabled={}." [fvt-id score-entity-id enabled])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_ToggleScoreEntityLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|IssueMultipletFamily:object{OuronetInfoV2.ClientInfo}
        (patron:string token-0-id:string token-1-id:string token-2-id:string ats-0-1-id:string ats-1-2-id:string)
        @doc "Cost preview for AQP-FVT|C_IssueMultipletFamily. IGNIS GAS|ISSUE-MULTIPLET-FAMILY; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a chain-wide MultipletFamily reward ladder." "Executes via TS02-C3.AQP-FVT|C_IssueMultipletFamily."]
                [(format "MultipletFamily issued: {} -> {} -> {}." [token-0-id token-1-id token-2-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_IssueMultipletFamily patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|IssueGenericEarningVault:object{OuronetInfoV2.ClientInfo}
        (patron:string owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-FVT|C_IssueGenericEarningVault -- the whole six-operation vault \
            \ as ONE charge. IGNIS only; no STOA."
        ;;The cost comes from TS02-C3.URCi_IssueGenericEarningVault, which concatenates the SAME six
        ;;component readers the operation's own cumulators come from. Preview and charge therefore
        ;;agree by construction rather than by a number kept in step by hand.
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stand up a complete earning Vault in one transaction -- score, pool, pool-score link, FVT entity, score admission and reward link."
                 "Executes via TS02-C3.AQP-FVT|C_IssueGenericEarningVault."]
                [(format "Vault {}: stake {} to earn {}. Creates {}Score, {}Pool, {}Vault."
                    [vault-name stake-dptf-id reward-dptf-id vault-name vault-name vault-name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                        (TS02-C3.URCi_IssueGenericEarningVault owner-konto vault-name stake-dptf-id reward-dptf-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|AddRewardLink:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Cost preview for AQP-FVT|C_AddRewardLink. IGNIS GAS|ADD-REWARD-LINK; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Register a reward DPTF on an FVT." "Executes via TS02-C3.AQP-FVT|C_AddRewardLink."]
                [(format "Reward {} linked on FVT {} (family {})." [reward-dptf-id fvt-id multiplet-family-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_AddRewardLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|ToggleRewardLink:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Cost preview for AQP-FVT|C_ToggleRewardLink. IGNIS GAS|TOGGLE-REWARD-LINK; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Toggle a reward link's enabled flag." "Executes via TS02-C3.AQP-FVT|C_ToggleRewardLink."]
                [(format "FVT {} reward {} enabled={}." [fvt-id reward-dptf-id enabled])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_ToggleRewardLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetQualitySplit:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Cost preview for AQP-FVT|C_SetQualitySplit. IGNIS GAS|SET-QUALITY-SPLIT; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a MULTIPLET_BASE reward's quality-split mode + matrix." "Executes via TS02-C3.AQP-FVT|C_SetQualitySplit."]
                [(format "FVT {} reward {} quality-split mode={}." [fvt-id reward-dptf-id mode])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (RPS.URCi_SetQualitySplit fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|InjectStream:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Cost preview for AQP-FVT|CC_InjectStream. IGNIS GAS|INJECT; STOA none (custody transfer)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Inject reward tokens as a linear time-stream over the given duration."
                 "Executes via TS02-C3.AQP-FVT|CC_InjectStream."]
                [(format "Streaming {} of {} into FVT {} over {}s." [amount reward-dptf-id fvt-id duration])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14) — same defect as INFO_AQP-FVT|Inject, same cause.
                    ;;This quoted only RPS.URCi_Inject (the gas leg) while the exec also collects the
                    ;;custody transfer of the reward principal: XIv_FvtAddStream PHASE 1 runs
                    ;;`(ref-TFT::C_Transfer reward-dptf-id patron AQP|SC_NAME amount true)` ahead of the
                    ;;gas leg, and that transfer carries its own cumulator. All FOUR members of the
                    ;;inject family shared this. Measured and pinned for CC_Inject at
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`; the other
                    ;;three route through the identical core, so the same reader fixes them.
                    (RPS.URCi_InjectFull "AQP-FVT|CC_InjectStream" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-FVT|Inject:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-FVT|CC_Inject (enforced-fresh single-tx inject). IGNIS GAS|INJECT; STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enforced-fresh single-tx inject (fixes all stale members first)."
                 "Executes via TS02-C3.AQP-FVT|CC_Inject."]
                [(format "Fresh-injected {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14). This quoted only RPS.URCi_Inject -- the gas leg --
                    ;;while CC_Inject also collects the custody transfer of the reward principal
                    ;;(XI_FvtInjectCore PHASE 1, 04_RPS.pact). Measured short by exactly the transfer
                    ;;cumulator. URCi_InjectFull counts both, matching how URCi_CollectFull and
                    ;;URCi_TrueFungibleStakeFlow already count theirs. Pinned by
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`.
                    (RPS.URCi_InjectFull "AQP-FVT|CC_Inject" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-FVT|InjectFinalize:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-FVT|CC_InjectFinalize. IGNIS GAS|INJECT; STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Finalize a paginated fresh inject (zero-stale gate, then inject)."
                 "Executes via TS02-C3.AQP-FVT|CC_InjectFinalize."]
                [(format "Finalized fresh inject of {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14) — same defect as INFO_AQP-FVT|Inject, same cause.
                    ;;This quoted only RPS.URCi_Inject (the gas leg) while the exec also collects the
                    ;;custody transfer of the reward principal: XI_FvtInjectCore PHASE 1, via XE_XI_FvtInjectCore runs
                    ;;`(ref-TFT::C_Transfer reward-dptf-id patron AQP|SC_NAME amount true)` ahead of the
                    ;;gas leg, and that transfer carries its own cumulator. All FOUR members of the
                    ;;inject family shared this. Measured and pinned for CC_Inject at
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`; the other
                    ;;three route through the identical core, so the same reader fixes them.
                    (RPS.URCi_InjectFull "AQP-FVT|CC_InjectFinalize" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-FVT|InjectFixChunk:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_InjectFixChunk. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Page the enforced-fresh FIX phase (up to `chunk` stale members)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CCp_InjectFixChunk."]
                [(format "Fixed up to {} stale members on FVT {} reward {}." [chunk fvt-id reward-dptf-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|UnstaleAll:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_UnstaleAll. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Owner mass deb-unstale (make injection-ready; no inject)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CCp_UnstaleAll."]
                [(format "Unstaled up to {} members on FVT {}." [chunk fvt-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|UnstaleMyScores:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-ids:[string])
        @doc "Cost preview for AQP-FVT|CC_UnstaleMyScores. IGNIS GAS|UNSTALE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Self-service deb-unstale of your own scores across FVTs." "Executes via TS02-C3.AQP-FVT|CC_UnstaleMyScores."]
                [(format "Unstaled your scores across {} FVTs." [(length fvt-ids)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_UnstaleMyScores patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|Collect:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-FVT|CC_Collect. FULL IGNIS: reward-payout leg (plain TFT transfer, or a \
            \ MULTIPLET_BASE triplet Coil/Curl ladder) + Phase-7 forced-fix penalty + GAS|COLLECT; STOA none. \
            \ Reconstructed on the current claimable state (exact for un-streamed / settled lanes)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Collect your claimable reward from this FVT membership."
                 "Full IGNIS shown: payout transfer/ladder + any forced-fix penalty + gas (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-FVT|CC_Collect."]
                [(format "Collected reward token {} from score-entity {}." [reward-dptf-id score-entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (RPS.URCi_CollectFull patron fvt-id score-entity-type score-entity-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SweepRevokeAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-FVT|CC_SweepRevokeAnchor. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Single-tx re-score sweep retiring an employed anchor."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CC_SweepRevokeAnchor."]
                [(format "Swept + retired anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SweepBegin:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-FVT|CC_SweepBegin. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Open a paginated re-score sweep (freeze + swept-revoke + cursor)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CC_SweepBegin."]
                [(format "Opened sweep on anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SweepRecomputeChunk:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_SweepRecomputeChunk. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Page a re-score sweep (recompute the next `chunk` holders; final page unfreezes)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CCp_SweepRecomputeChunk."]
                [(format "Recomputed up to {} holders on anchor {}'s sweep." [chunk anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;
    ;;[AQP-DSA] Delegated Staking Agencies
    (defun INFO_AQP-DSA|DefineDelegationVault:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string model-id:string unit-score:integer)
        @doc "Cost preview for AQP-DSA|C_DefineDelegationVault. IGNIS GAS|DEFINE-VAULT; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bind a class-0 FVT as a DSA delegation vault." "Executes via TS02-C3.AQP-DSA|C_DefineDelegationVault."]
                [(format "FVT {} bound as delegation vault (model {})." [fvt-id model-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_DefineDelegationVault patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|OpenAgency:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string pool-id:string score-entity-id:string fee-per-mille:integer collectable-id:string stake-nonces:[integer])
        @doc "Cost preview for AQP-DSA|CC_OpenAgency. IGNIS GAS|OPEN-AGENCY base; the atomic open also stakes the \
            \ operator's collateral (staking legs added at execution). No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Open a delegation agency (admit + operator-stake + terminal gate)."
                 "Base IGNIS shown; the operator collateral stake adds its legs at execution."
                 "Executes via TS02-C3.AQP-DSA|CC_OpenAgency."]
                [(format "Agency {} opened on vault {} (fee {} per-mille)." [score-entity-id fvt-id fee-per-mille])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_OpenAgency patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|RecomputeCapture:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string)
        @doc "Cost preview for AQP-DSA|C_RecomputeCapture. IGNIS GAS|RECOMPUTE-CAPTURE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Recompute an agency's capture (permissionless; preserves oracle-ts)." "Executes via TS02-C3.AQP-DSA|C_RecomputeCapture."]
                [(format "Agency {} capture recomputed on vault {}." [score-entity-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_RecomputeCapture patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|SetOracleAuth:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string oracle-guard:guard)
        @doc "Cost preview for AQP-DSA|C_SetOracleAuth. IGNIS GAS|SET-ORACLE-AUTH; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Authorize the delegated oracle key + arm the capture expiry." "Executes via TS02-C3.AQP-DSA|C_SetOracleAuth."]
                [(format "Oracle authority set on vault {}." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_SetOracleAuth patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|OracleWrite:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "Cost preview for AQP-DSA|C_OracleWrite. IGNIS GAS|ORACLE-WRITE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Oracle writes an agency's daily {nodes, uptime} + recomputes its capture." "Executes via TS02-C3.AQP-DSA|C_OracleWrite."]
                [(format "Oracle wrote nodes {} / uptime {} for agency {}." [nodes uptime score-entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_OracleWrite patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|ToggleExternalOracle:object{OuronetInfoV2.ClientInfo}
        (on:bool)
        @doc "Cost preview for AQP-DSA|A_ToggleExternalOracle. Chain-wide GOV switch — no IGNIS/STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Flip the SINGULAR GLOBAL external-oracle switch for ALL agencies (governance)."
                 "Master-signed governance action — no gas."
                 "Executes via TS02-C3.AQP-DSA|A_ToggleExternalOracle."]
                [(format "Global external-oracle switch set to {}." [on])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|SetOracleValidity:object{OuronetInfoV2.ClientInfo}
        (seconds:integer)
        @doc "Cost preview for AQP-DSA|A_SetOracleValidity. Chain-wide GOV switch — no IGNIS/STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set the GLOBAL oracle-validity window (freshness horizon; governance)."
                 "Master-signed governance action — no gas."
                 "Executes via TS02-C3.AQP-DSA|A_SetOracleValidity."]
                [(format "Global oracle-validity window set to {} seconds." [seconds])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|WithdrawRoyalty:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-DSA|C_WithdrawRoyalty. FULL IGNIS: GAS|WITHDRAW-ROYALTY gas leg + the state- \
            \ dependent custody-move leg (normalize + TFT transfer of the live royalty pool to the FVT owner); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Withdraw the whole royalty pool to the FVT owner."
                 "Full IGNIS shown: gas + custody move (reconstructed from the live royalty balance)."
                 "Executes via TS02-C3.AQP-DSA|C_WithdrawRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} withdrawn to owner." [reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-DSA.URCi_WithdrawRoyaltyFull patron fvt-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|BurnRoyalty:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-DSA|C_BurnRoyalty. FULL IGNIS: GAS|BURN-ROYALTY gas leg + the state-dependent \
            \ custody-burn leg (normalize + DPTF burn of the live royalty pool); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Burn the whole royalty pool."
                 "Full IGNIS shown: gas + custody burn (reconstructed from the live royalty balance)."
                 "Executes via TS02-C3.AQP-DSA|C_BurnRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} burned." [reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-DSA.URCi_BurnRoyaltyFull patron fvt-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|FuelRoyalty:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Cost preview for AQP-DSA|C_FuelRoyalty. FULL IGNIS: GAS|FUEL-ROYALTY gas leg + the state-dependent \
            \ custody-fuel leg (normalize + SWPLC fuel of the live royalty pool into the swpair); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Fuel a swap pair with the whole royalty pool (no LP mint)."
                 "Full IGNIS shown: gas + custody fuel (reconstructed from the live royalty balance)."
                 "Executes via TS02-C3.AQP-DSA|C_FuelRoyalty."]
                [(format "Royalty pool of reward {} on FVT {} fueled into {}." [reward-dptf-id fvt-id swpair])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-DSA.URCi_FuelRoyaltyFull patron fvt-id reward-dptf-id swpair))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|SetAgencyFee:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Cost preview for AQP-DSA|C_SetAgencyFee. IGNIS GAS|SET-AGENCY-FEE; no STOA. O(1) reprice."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Change a delegation agency's operator fee (reprices only future injects)." "Executes via TS02-C3.AQP-DSA|C_SetAgencyFee."]
                [(format "Agency {} fee set to {} per-mille." [score-entity-id fee-per-mille])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_SetAgencyFee patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;
    ;;[AQP-MTX] Matrix drivers (spike-fallback defpacts)
    (defun INFO_AQP-MTX|2Inject:object{OuronetInfoV2.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for MTX-AQP|2|CC_Inject (2-step enforced-fresh inject). IGNIS GAS|INJECT (inner XB_FvtInject); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: 2-step enforced-fresh inject (spike fallback for CC_Inject on vault/treasury)."
                 "Executes via TS02-C3.MTX-AQP|2|CC_Inject."]
                [(format "2-step fresh-injected {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14) — same defect as INFO_AQP-FVT|Inject, same cause.
                    ;;This quoted only RPS.URCi_Inject (the gas leg) while the exec also collects the
                    ;;custody transfer of the reward principal: XI_FvtInjectCore PHASE 1, via XB_FvtInject runs
                    ;;`(ref-TFT::C_Transfer reward-dptf-id patron AQP|SC_NAME amount true)` ahead of the
                    ;;gas leg, and that transfer carries its own cumulator. All FOUR members of the
                    ;;inject family shared this. Measured and pinned for CC_Inject at
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`; the other
                    ;;three route through the identical core, so the same reader fixes them.
                    (RPS.URCi_InjectFull "MTX-AQP|2|CC_Inject" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-MTX|2SweepRevokeAnchor:object{OuronetInfoV2.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for MTX-AQP|2|CC_SweepRevokeAnchor. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: 2-step paginated sweep retiring an employed anchor (spike fallback for CC_SweepRevokeAnchor)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.MTX-AQP|2|CC_SweepRevokeAnchor."]
                [(format "2-step swept + retired anchor {}." [anchor-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact ================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageTwo_ClientOneV2
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
    (defun DPDC|C_MultiTransfer (patron:string ids:[string] sons:[bool] sender:string receiver:string nonces-array:[[integer]] amounts-array:[[integer]] method:bool))
    (defun DPSF|C_UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun DPSF|C_UpgradeBranding (patron:string entity-id:string months:integer))
    ;;
    ;;  [3] DPDC-C
    ;;
    (defun DPSF|C_Create:string
        (
            patron:string id:string amount:[integer]
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
            owner-account:string creator-account:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
        )
    )
    ;;
    ;;  [5] DPDC-R
    ;;
    (defun DPSF|C_ToggleAddQuantityRole (patron:string id:string account:string toggle:bool))
    (defun DPSF|C_ToggleFreezeAccount (patron:string id:string account:string toggle:bool))
    (defun DPSF|C_ToggleExemptionRole (patron:string id:string account:string toggle:bool))
    (defun DPSF|C_ToggleBurnRole (patron:string id:string account:string toggle:bool))
    (defun DPSF|C_ToggleUpdateRole (patron:string id:string account:string toggle:bool))
    (defun DPSF|C_ToggleModifyCreatorRole (patron:string id:string account:string toggle:bool))
    (defun DPSF|C_ToggleModifyRoyaltiesRole (patron:string id:string account:string toggle:bool))
    (defun DPSF|C_ToggleTransferRole (patron:string id:string account:string toggle:bool))
    (defun DPSF|C_MoveCreateRole (patron:string id:string new-account:string))
    (defun DPSF|C_MoveRecreateRole (patron:string id:string new-account:string))
    (defun DPSF|C_MoveSetUriRole (patron:string id:string new-account:string))
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun DPSF|C_Control (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool))
    (defun DPSF|C_TogglePause (patron:string id:string toggle:bool))
        ;;
    (defun DPSF|C_AddQuantity (patron:string id:string account:string nonce:integer amount:integer))
    (defun DPSF|C_Burn (patron:string id:string account:string nonce:integer amount:integer))
    (defun DPSF|C_WipeNoncePartialy (patron:string id:string account:string nonce:integer amount:integer))
    (defun DPSF|C_WipeNonce (patron:string id:string account:string nonce:integer))
        ;;
    (defun DPSF|CC_WipeHeavy (patron:string account:string id:string))
    (defun DPSF|C_WipePure (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces}))
    (defun DPSF|C_WipeClean (patron:string account:string id:string nonces:[integer]))
    (defun DPSF|C_WipeDirty (patron:string account:string id:string nonces:[integer]))
    (defun DPSF|Cp_WipeSlice (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces}))
    ;;
    ;;  [7] DPDC-T
    ;;
    (defun DPSF|C_Repurpose (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer]))
    (defun DPSF|C_TransferNonce (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool))
    (defun DPSF|C_TransferNonces (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool))
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun DPSF|C_Make (patron:string account:string id:string nonces:[integer] set-class:integer how-many-sets:integer))
    (defun DPSF|CC_Break (patron:string account:string id:string nonce:integer how-many-sets:integer))
    (defun DPSF|C_DefinePrimordialSet 
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPSF|C_DefineCompositeSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPSF|C_DefineHybridSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPSF|C_EnableSetClassFragmentation
        (
            patron:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPSF|C_ToggleSet (patron:string id:string set-class:integer toggle:bool))
    (defun DPSF|C_RenameSet (patron:string id:string set-class:integer new-name:string))
    ;; DPSF|C_UpdateSetMultiplier removed — DPDC Audit #15H: score-multiplier is immutable after Define.
    ;;
    (defun DPSF|C_UpdateSetNonce                        (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}))
    (defun DPSF|C_UpdateSetNonces                       (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]))
    (defun DPSF|C_UpdateSetNonceRoyalty                 (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal))
    (defun DPSF|C_UpdateSetNonceIgnisRoyalty            (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal))
    (defun DPSF|C_UpdateSetNonceName                    (patron:string id:string account:string set-class:integer nos:bool name:string))
    (defun DPSF|C_UpdateSetNonceDescription             (patron:string id:string account:string set-class:integer nos:bool description:string))
    (defun DPSF|C_UpdateSetNonceScore                   (patron:string id:string account:string set-class:integer nos:bool score:decimal))
    (defun DPSF|C_RemoveSetNonceScore                   (patron:string id:string account:string set-class:integer nos:bool))
    (defun DPSF|C_UpdateSetNonceMetaData                (patron:string id:string account:string set-class:integer nos:bool meta-data:object))
    (defun DPSF|C_UpdateSetNonceURI                     (patron:string id:string account:string set-class:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}))
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun DPSF|C_RepurposeFragments (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer]))
    (defun DPSF|C_MakeFragments (patron:string account:string id:string nonce:integer amount:integer))
    (defun DPSF|C_MergeFragments (patron:string account:string id:string nonce:integer amount:integer))
    (defun DPSF|C_EnableNonceFragmentation (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}))
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun DPSF|C_UpdateNonce                           (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}))
    (defun DPSF|C_UpdateNonces                          (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]))
    (defun DPSF|C_UpdateNonceRoyalty                    (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal))
    (defun DPSF|C_UpdateNonceIgnisRoyalty               (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal))
    (defun DPSF|C_UpdateNonceName                       (patron:string id:string account:string nonce:integer nos:bool name:string))
    (defun DPSF|C_UpdateNonceDescription                (patron:string id:string account:string nonce:integer nos:bool description:string))
    (defun DPSF|C_UpdateNonceScore                      (patron:string id:string account:string nonce:integer nos:bool score:decimal))
    (defun DPSF|C_RemoveNonceScore                      (patron:string id:string account:string nonce:integer nos:bool))
    (defun DPSF|C_UpdateNonceMetaData                   (patron:string id:string account:string nonce:integer nos:bool meta-data:object))
    (defun DPSF|C_UpdateNonceURI                        (patron:string id:string account:string nonce:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}))
    ;;
    ;;
    ;;  [10] EQUITY
    ;;
    (defun DPSF|C_IssueCompany:string
        (
            patron:string creator-account:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
    )
    (defun DPSF|C_MorphEquity (patron:string account:string id:string input-nonce:integer input-amount:integer output-nonce:integer))
    (defun DPDC|C_BulkTransfer
        (patron:string id:string son:bool nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
    )
    (defun DPSF|C_BulkTransfer
        (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
    )

)
;;
(module TS02-C1 GOV
    @doc "TALOS Stage 2 Client Functiones Part 1 - SFT Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_ClientOneV2)

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
    (defun DPDC|C_MultiTransfer (patron:string ids:[string] sons:[bool] sender:string receiver:string nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Transfer multiple SFT <ids> from <sender> to <receiver>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                    (hm:integer (length ids))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron sender ids sons nonces-array amounts-array)
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                    (l:integer (length c))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer ids sons sender receiver nonces-array amounts-array method)
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
    (defun DPSF|C_UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPSF Token <entity-id> costing 400 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC::C_UpdatePendingBranding entity-id true logo description website social)
                )
            )
        )
    )
    (defun DPSF|C_UpgradeBranding (patron:string entity-id:string months:integer)
        @doc "Upgrades Branding for DPSF Token, making it a premium BrandingV2. \
            \ Also sets pending-branding to live branding if its branding is not live yet"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DPDC::C_UpgradeBranding patron entity-id true months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    ;;
    ;;  [3] DPDC-C
    ;;
    (defun DPSF|C_Create:string
        (
            patron:string id:string amount:[integer]
            input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}]
        )
        @doc "Creates a new SFT Collection Element(s), having a new nonce, \
            \ of amount <amount>, on the Account that has <r-nft-create> \
            \ As this account is the only Account that is allowed to create new SFTs in the Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    (l:integer (length input-nonce-data))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (if (= l 1)
                            (ref-DPDC-C::C_CreateNewNonce
                                id true 0 (at 0 amount) (at 0 input-nonce-data) false
                            )
                            (ref-DPDC-C::C_CreateNewNonces
                                id true amount input-nonce-data
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
            owner-account:string creator-account:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
        )
        @doc "Issues a new DPSF (Demiourgos Pact Semi-Fungible) Digital Collection: <SFT> \
            \ Costs 5x<ignis|token-issue> = 2500 IGNIS and 400 STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-I:module{DpdcIssueV2} DPDC-I)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-I::C_IssueDigitalCollection
                            patron true 
                            owner-account creator-account collection-name collection-ticker
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
    (defun DPSF|C_ToggleAddQuantityRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles the add quantity role for a DPTF Token on a given Ouronet Account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleAddQuantityRole id account toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleFreezeAccount (patron:string id:string account:string toggle:bool)
        @doc "Freezes a given account for a given DPSF Token. Frozen Accounts can no longer send or receive that DPSF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleFreezeAccount id true account toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleExemptionRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles exemption Role for a given DPSF on a given Smart Ouronet Account (Only Smart Ouronet Accounts can accept this role) \
            \ When sending to or receiving from such Accounts, the flat IGNIS Royalty fee must not be paid."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleExemptionRole id true account toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleBurnRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles burn Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can then burn the DPSF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleBurnRole id true account toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleUpdateRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles update Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can then update (modify) the Metadata on any DPSF nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleUpdateRole id true account toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleModifyCreatorRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles Modify Creator Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Creator of the DPSF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyCreatorRole id true account toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleModifyRoyaltiesRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles Modify Royalties Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Permille Royalty of any nonce in the  DPSF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyRoyaltiesRole id true account toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleTransferRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles Transfer Role for a given DPSF on any Ouronet Account. \
            \ Transfers for any Nonce in the DPSF Collection are then restricted only to and from these accounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleTransferRole id true account toggle)
                )
            )
        )
    )
    (defun DPSF|C_MoveCreateRole (patron:string id:string new-account:string)
        @doc "Moves the Create Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can issue new SFTs in the Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveCreateRole id true new-account)
                )
            )
        )
    )
    (defun DPSF|C_MoveRecreateRole (patron:string id:string new-account:string)
        @doc "Moves the Recreate Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can recreate any existing SFT in the Collection \
            \ Recreation reffers to a complete update (modification) of all SFT properties of a given nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveRecreateRole id true new-account)
                )
            )
        )
    )
    (defun DPSF|C_MoveSetUriRole (patron:string id:string new-account:string)
        @doc "Moves the Set URI Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can modify the URIs of any nonce in the SFT Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveSetUriRole id true new-account)
                )
            )
        )
    )
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun DPSF|C_Control (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        @doc "Controls DPSF Properties"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_Control id true cu cco ccc casr ctncr cf cw cp)
                )
            )
        )
    )
    (defun DPSF|C_TogglePause (patron:string id:string toggle:bool)
        @doc "Pauses a DPSF Collection. Paused Collections can no longer be transfered"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_TogglePause id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_AddQuantity (patron:string id:string account:string nonce:integer amount:integer)
        @doc "Increases the Quantity for SFT <id> <nonce> by <amount> on <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_AddQuantity account id nonce amount)
                )
                (format "Successfully added {} Units for SFT {} Nonce {} on Account {}" [amount id nonce (UC_ShortAccount account)])
            )
        )
    )
    (defun DPSF|C_Burn (patron:string id:string account:string nonce:integer amount:integer)
        @doc "Decreases the Quantity for SFT <id> <nonce> by <amount> on <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_BurnSFT account id nonce amount)
                )
                (format "Successfully burned {} Units for SFT {} Nonce {} on Account {}" [amount id nonce (UC_ShortAccount account)])
            )
        )
    )
    (defun DPSF|C_WipeNoncePartialy (patron:string id:string account:string nonce:integer amount:integer)
        @doc "Wipes a partial <amount> of SFT <id> <nonce> from <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_WipeSlim account id nonce amount)
                )
                (format "Successfully wiped {} Units for SFT {} Nonce {} from Account {}" [amount id nonce (UC_ShortAccount account)])
            )
        )
    )
    (defun DPSF|C_WipeNonce (patron:string id:string account:string nonce:integer)
        @doc "Wipes the SFT <id> <nonce> from <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_WipeNonce account id true nonce)
                )
                (format "Successfully wiped SFT {} Nonce {} from Account {}" [id nonce (UC_ShortAccount account)])
            )
        )
    )
    (defun DPSF|CC_WipeHeavy (patron:string account:string id:string)
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::CC_WipeHeavy account id true)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Successfully executed Heavy Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|C_WipePure (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipePure account id true removable-nonces-obj) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Successfully executed Pure Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|C_WipeClean (patron:string account:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeClean account id true nonces) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Successfully executed Clean Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|C_WipeDirty (patron:string account:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeDirty account id true nonces)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format
                    "Successfully executed Dirty Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}"
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|Cp_WipeSlice (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes ONE <URHC_BuildWipeSlicePlan> slice of the SFT \
            \ <account>'s <id> nonces. The UI dirty-reads the plan and fires one such tx per \
            \ slice, all in parallel; slices are disjoint, order-independent and retryable \
            \ (replay REVERTS on the zeroed account supply)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
    (defun DPSF|C_Repurpose (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose SFT(s) from <repurpose-from> to <repurpose-to>. Requires <id> ownerhsip"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_RepurposeCollectable id true repurpose-from repurpose-to nonces amounts)
                )
                (format "Successfully repurposed SFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPSF|C_TransferNonce (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool)
        @doc "Transfer an SFT <nonce> of <amount> from <sender> to <receiver> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron sender [id] [true] [[nonce]] [[amount]])
                    )
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer [id] [true] sender receiver [[nonce]] [[amount]] method)
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
    (defun DPSF|C_TransferNonces (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool)
        @doc "Transfer an SFT <nonce> of <amount> from <sender> to <receiver> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron sender [id] [true] [nonces] [amounts])
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer [id] [true] sender receiver [nonces] [amounts] method)
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
        (patron:string id:string son:bool nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        @doc "Bulk whole collectable transfer — one sender, many standard-account receivers (TalosStageTwo_ClientOneV2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    ;;
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (l:integer (length receiver-lst))
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
                    (ids:[string]  (map (lambda (rcv:string) id)  receiver-lst))
                    (sons:[bool]   (map (lambda (rcv:string) son) receiver-lst))
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
                        (core-ico:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPDC-T::C_BulkTransfer id son nonces-array amounts-array sender receiver-lst method)
                        )
                    )
                (let
                    (
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron sender ids sons nonces-array amounts-array)
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
        (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        @doc "Bulk SFT transfer — son=true wrapper over DPDC|C_BulkTransfer."
        (DPDC|C_BulkTransfer patron id true nonces-array amounts-array sender receiver-lst method)
    )
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun DPSF|C_Make
        (patron:string account:string id:string nonces:[integer] set-class:integer how-many-sets:integer)
        @doc "Makes a Set SFT of Class <set-class>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
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
                    (ref-DPDC-S::C_MakeSemiFungibleSet account id nonces set-class how-many-sets)
                )
                (format "Successfully generated {} Class {} Sets (Nonce {}) of SFT Collection {} on Account {}"
                    [how-many-sets set-class (ref-DPDC-S::UR_NonceOfSet id set-class) id sa])
            )
        )
    )
    (defun DPSF|CC_Break
        (patron:string account:string id:string nonce:integer how-many-sets:integer)
        @doc "Brakes an SFT Nonce representing an SFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (set-class:integer (ref-DPDC::UR_NonceClass id true nonce))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::CC_BreakSemiFungibleSet account id nonce how-many-sets)
                )
                (format "Successfully broken {} Class {} Sets (Nonce {}) of SFT Collection {} on Account {}" [how-many-sets set-class nonce id sa])
            )
        )
    )
    (defun DPSF|C_DefinePrimordialSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Primordial SFT Set. Primordial Sets are composed of Class 0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_DefinePrimordialSet id true set-name score-multiplier set-definition ind)
                )
                (format "Primordial Set <{}> for SFT Collection {} defined succesfully" [set-name id])
            )
        )
    )
    (defun DPSF|C_DefineCompositeSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Composite SFT Set. Composite Sets are composed of Class (!=0) Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_DefineCompositeSet id true set-name score-multiplier set-definition ind)
                )
                (format "Composite Set <{}> for SFT Collection {} defined succesfully" [set-name id])
            )
        )
    )
    (defun DPSF|C_DefineHybridSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Hybrid SFT Set. Hybrid Sets are composed of both Class 0 and Non-0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_DefineHybridSet id true set-name score-multiplier primordial-sd composite-sd ind)
                )
                (format "Hybrid Set <{}> for SFT Collection {} defined succesfully" [set-name id])
            )
        )
    )
    (defun DPSF|C_EnableSetClassFragmentation
        (
            patron:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Enables Fragmentation for a given Set Class. This allows all SFTs of the given Set Class to be Fragmented"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_EnableSetClassFragmentation id true set-class fragmentation-ind)
                )
                (format "Set Class {} for SFT {} succesfully fragmented" [set-class id])
            )
        )
    )
    (defun DPSF|C_ToggleSet (patron:string id:string set-class:integer toggle:bool)
        @doc "Enables or Disables a Set. A disabled Set allows only for decomposition of Set Elements, but not for composition"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_ToggleSet id true set-class toggle)
                )
                (format "SFT {} Set Class {} succesfully turned {}" [id set-class (if toggle "ON" "OFF")])
            )
        )
    )
    (defun DPSF|C_RenameSet (patron:string id:string set-class:integer new-name:string)
        @doc "Renames an SFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_RenameSet id true set-class new-name)
                )
                (format "SFT {} Set Class {} succesfuly renamed to <{}>" [id set-class new-name])
            )
        )
    )
    ;; DPSF|C_UpdateSetMultiplier removed — DPDC Audit #15H.
    ;;
    (defun DPSF|C_UpdateSetNonce 
        (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces id true account [set-class] nos false [new-nonce-data])
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonces
        (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces id true account set-classes nos false new-nonces-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceRoyalty
        (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Set Nonce Native Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty id true account set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceIgnisRoyalty
        (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Set Nonce IGNIS Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty id true account set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceName
        (patron:string id:string account:string set-class:integer nos:bool name:string)
        @doc "[3] Updates Set Nonce Name, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName id true account set-class nos false name)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceDescription
        (patron:string id:string account:string set-class:integer nos:bool description:string)
        @doc "[4] Updates Set Nonce Description, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription id true account set-class nos false description)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceScore
        (patron:string id:string account:string set-class:integer nos:bool score:decimal)
        @doc "[5] Updates Set Nonce Score, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore id true account set-class nos false score)
                )
            )
        )
    )
    (defun DPSF|C_RemoveSetNonceScore (patron:string id:string account:string set-class:integer nos:bool)
        @doc "[5b] Removes Set Nonce Score, setting it to -1.0, either Native or Split, for an SFT"
        (DPSF|C_UpdateSetNonceScore patron id account set-class nos -1.0)
    )
    (defun DPSF|C_UpdateSetNonceMetaData
        (patron:string id:string account:string set-class:integer nos:bool meta-data:object)
        @doc "[6] Updates Set Nonce Meta-Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData id true account set-class nos false meta-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceURI
        (
            patron:string id:string account:string set-class:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Set Nonce URI, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI id true account set-class nos false ay u1 u2 u3)
                )
            )
        )
    )
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun DPSF|C_RepurposeFragments (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose SFT Fragment(s) from <repurpose-from> to <repurpose-to>. Requires <id> ownerhsip"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_RepurposeCollectableFragments id true repurpose-from repurpose-to nonces amounts)
                )
                (format "Successfully repurposed SFT {} Fragment-Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPSF|C_MakeFragments (patron:string account:string id:string nonce:integer amount:integer)
        @doc "Fragments SFT nonce of the given amount into its respective Fragments."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MakeFragments account id true nonce amount)
                )
                (format "Successfully Fragmented {} SFT(s) {} of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPSF|C_MergeFragments (patron:string account:string id:string nonce:integer amount:integer)
        @doc "MErges SFT Fragments nonces of the given amount into the original SFT nonce."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MergeFragments account id true nonce amount)
                )
                (format "Successfully merged {} {} SFT(s) Fragments of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPSF|C_EnableNonceFragmentation (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        @doc "Enables Fragmentation for a given SFT Nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_EnableNonceFragmentation id true nonce fragmentation-ind)
                )
                (format "Fragmentation for SFT {} Nonce {} enabled succesfully" [id nonce])
            )
        )
    )
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun DPSF|C_UpdateNonce
        (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces id true account [nonce] nos true [new-nonce-data])
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonces
        (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an SFT, for multiple Nonces at a time"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces id true account nonces nos true new-nonces-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceRoyalty
        (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Nonce Native Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty id true account nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceIgnisRoyalty
        (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Nonce IGNIS Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty id true account nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceName
        (patron:string id:string account:string nonce:integer nos:bool name:string)
        @doc "[3] Updates Nonce Name, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName id true account nonce nos true name)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceDescription
        (patron:string id:string account:string nonce:integer nos:bool description:string)
        @doc "[4] Updates Nonce Description, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription id true account nonce nos true description)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceScore
        (patron:string id:string account:string nonce:integer nos:bool score:decimal)
        @doc "[5] Updates Nonce Score, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore id true account nonce nos true score)
                )
            )
        )
    )
    (defun DPSF|C_RemoveNonceScore (patron:string id:string account:string nonce:integer nos:bool)
        @doc "[5b] Removes Nonce Score, setting it to -1.0, either Native or Split, for an SFT"
        (DPSF|C_UpdateNonceScore patron id account nonce nos -1.0)
    )
    (defun DPSF|C_UpdateNonceMetaData
        (patron:string id:string account:string nonce:integer nos:bool meta-data:object)
        @doc "[6] Updates Nonce Meta-Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData id true account nonce nos true meta-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceURI
        (
            patron:string id:string account:string nonce:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Nonce URI, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI id true account nonce nos true ay u1 u2 u3)
                )
            )
        )
    )
    ;;
    ;;  [11] EQUITY
    ;;
    (defun DPSF|C_IssueCompany:string
        (
            patron:string creator-account:string collection-name:string collection-ticker:string
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-EQUITY:module{EquityV2} EQUITY)
                    ;;
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-EQUITY::C_IssueShareholderCollection 
                            patron creator-account collection-name collection-ticker
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
    (defun DPSF|C_MorphEquity
        (patron:string account:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        @doc "Converts any Nonce to [1 2 3 4 5 6 7 8] to any Nonce [1 2 3 4 5 6 7 8] \
            \ Input-Nonce must be different from Output-Nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (ref-EQUITY:module{EquityV2} EQUITY)
                    ;;
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-EQUITY::C_MorphPackageShares
                            account id input-nonce input-amount output-nonce
                        )
                    )
                    (output:list (at "output" ico))
                    (ir-nonces:[integer] (at 0 output))
                    (ir-amounts:[integer] (at 1 output))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron account [id] [true] [ir-nonces] [ir-amounts])
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
    (defun DPNF|C_UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun DPNF|C_UpgradeBranding (patron:string entity-id:string months:integer))
    ;;
    ;;  [3] DPDC-C
    ;;
    (defun DPNF|C_Create:string
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
    ;; (on transfer, role-toggle, Issue, set-fragmentation) always calls DPDC::XBv_DeployAccountNFT
    ;; directly, module-to-module, bypassing this public entrypoint entirely.
    (defun DPNF|C_Issue:string
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
    (defun DPNF|C_ToggleFreezeAccount (patron:string id:string account:string toggle:bool))
    (defun DPNF|C_ToggleExemptionRole (patron:string id:string account:string toggle:bool))
    (defun DPNF|C_ToggleBurnRole (patron:string id:string account:string toggle:bool))
    (defun DPNF|C_ToggleUpdateRole (patron:string id:string account:string toggle:bool))
    (defun DPNF|C_ToggleModifyCreatorRole (patron:string id:string account:string toggle:bool))
    (defun DPNF|C_ToggleModifyRoyaltiesRole (patron:string id:string account:string toggle:bool))
    (defun DPNF|C_ToggleTransferRole (patron:string id:string account:string toggle:bool))
    (defun DPNF|C_MoveCreateRole (patron:string id:string new-account:string))
    (defun DPNF|C_MoveRecreateRole (patron:string id:string new-account:string))
    (defun DPNF|C_MoveSetUriRole (patron:string id:string new-account:string))
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun DPNF|C_Control (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool))
    (defun DPNF|C_TogglePause (patron:string id:string toggle:bool))
        ;;
    (defun DPNF|C_Respawn (patron:string id:string account:string nonce:integer))
    (defun DPNF|C_Burn (patron:string id:string account:string nonce:integer))
    (defun DPNF|C_WipeNonce (patron:string id:string account:string nonce:integer))
        ;;
    (defun DPNF|CC_WipeHeavy (patron:string account:string id:string))
    (defun DPNF|C_WipePure (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces}))
    (defun DPNF|C_WipeClean (patron:string account:string id:string nonces:[integer]))
    (defun DPNF|C_WipeDirty (patron:string account:string id:string nonces:[integer]))
    (defun DPNF|Cp_WipeSlice (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces}))
    ;;
    ;;  [7] DPDC-T
    ;;
    (defun DPNF|C_Repurpose (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer]))
    (defun DPNF|C_TransferNonce (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool))
    (defun DPNF|C_TransferNonces (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool)) 
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun DPNF|C_Make (patron:string account:string id:string nonces:[integer] set-class:integer))
    (defun DPNF|C_Break (patron:string account:string id:string nonce:integer))
    (defun DPNF|C_DefinePrimordialSet 
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPNF|C_DefineCompositeSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPNF|C_DefineHybridSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPNF|C_EnableSetClassFragmentation
        (
            patron:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
    )
    (defun DPNF|C_ToggleSet (patron:string id:string set-class:integer toggle:bool))
    (defun DPNF|C_RenameSet (patron:string id:string set-class:integer new-name:string))
    ;; DPNF|C_UpdateSetMultiplier removed — DPDC Audit #15H: score-multiplier is immutable after Define.
    ;;
    (defun DPNF|C_UpdateSetNonce                        (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}))
    (defun DPNF|C_UpdateSetNonces                       (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]))
    (defun DPNF|C_UpdateSetNonceRoyalty                 (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal))
    (defun DPNF|C_UpdateSetNonceIgnisRoyalty            (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal))
    (defun DPNF|C_UpdateSetNonceName                    (patron:string id:string account:string set-class:integer nos:bool name:string))
    (defun DPNF|C_UpdateSetNonceDescription             (patron:string id:string account:string set-class:integer nos:bool description:string))
    (defun DPNF|C_UpdateSetNonceScore                   (patron:string id:string account:string set-class:integer nos:bool score:decimal))
    (defun DPNF|C_RemoveSetNonceScore                   (patron:string id:string account:string set-class:integer nos:bool))
    (defun DPNF|C_UpdateSetNonceMetaData                (patron:string id:string account:string set-class:integer nos:bool meta-data:object))
    (defun DPNF|C_UpdateSetNonceURI                     (patron:string id:string account:string set-class:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}))
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun DPNF|C_RepurposeFragments (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer]))
    (defun DPNF|C_MakeFragments (patron:string account:string id:string nonce:integer amount:integer))
    (defun DPNF|C_MergeFragments (patron:string account:string id:string nonce:integer amount:integer))
    (defun DPNF|C_EnableNonceFragmentation (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}))
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun DPNF|C_UpdateNonce                           (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData}))
    (defun DPNF|C_UpdateNonces                          (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}]))
    (defun DPNF|C_UpdateNonceRoyalty                    (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal))
    (defun DPNF|C_UpdateNonceIgnisRoyalty               (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal))
    (defun DPNF|C_UpdateNonceName                       (patron:string id:string account:string nonce:integer nos:bool name:string))
    (defun DPNF|C_UpdateNonceDescription                (patron:string id:string account:string nonce:integer nos:bool description:string))
    (defun DPNF|C_UpdateNonceScore                      (patron:string id:string account:string nonce:integer nos:bool score:decimal))
    (defun DPNF|C_RemoveNonceScore                      (patron:string id:string account:string nonce:integer nos:bool))
    (defun DPNF|C_UpdateNonceMetaData                   (patron:string id:string account:string nonce:integer nos:bool meta-data:object))
    (defun DPNF|C_UpdateNonceURI                        (patron:string id:string account:string nonce:integer nos:bool ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}))
    (defun DPNF|C_BulkTransfer
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
    (defun DPNF|C_UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPNF Token <entity-id> costing 500 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC::C_UpdatePendingBranding entity-id false logo description website social)
                )
            )
        )
    )
    (defun DPNF|C_UpgradeBranding (patron:string entity-id:string months:integer)
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
    (defun DPNF|C_Create:string
        (
            patron:string id:string
            input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}]
        )
        @doc "Creates a new NFT Collection Element(s), having a new nonce, \
            \ of amount 1, on the <creator> account."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    (l:integer (length input-nonce-data))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
            owner-account:string creator-account:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
        )
        @doc "Issues a new DPNF (Demiourgos Pact Non-Fungible) Digital Collection: <NFT> \
            \ Costs 10x<ignis|token-issue> = 5000 IGNIS and 500 STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-I:module{DpdcIssueV2} DPDC-I)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-I::C_IssueDigitalCollection
                            patron false 
                            owner-account creator-account collection-name collection-ticker
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
    (defun DPNF|C_ToggleFreezeAccount (patron:string id:string account:string toggle:bool)
        @doc "Freezes a given account for a given DPNF Token. Frozen Accounts can no longer send or receive that DPNF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleFreezeAccount id false account toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleExemptionRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles exemption Role for a given DPNF on a given Smart Ouronet Account (Only Smart Ouronet Accounts can accept this role) \
            \ When sending to or receiving from such Accounts, the flat IGNIS Royalty fee must not be paid."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleExemptionRole id false account toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleBurnRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles burn Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can then burn the DPNF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleBurnRole id false account toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleUpdateRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles update Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can then update (modify) the Metadata on any DPNF nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleUpdateRole id false account toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleModifyCreatorRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles Modify Creator Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Creator of the DPNF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyCreatorRole id false account toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleModifyRoyaltiesRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles Modify Royalties Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Permille Royalty of any nonce in the  DPNF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyRoyaltiesRole id false account toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleTransferRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles Transfer Role for a given DPNF on any Ouronet Account. \
            \ Transfers for any Nonce in the DPNF Collection are then restricted only to and from these accounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleTransferRole id false account toggle)
                )
            )
        )
    )
    (defun DPNF|C_MoveCreateRole (patron:string id:string new-account:string)
        @doc "Moves the Create Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can issue new NFTs in the Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveCreateRole id false new-account)
                )
            )
        )
    )
    (defun DPNF|C_MoveRecreateRole (patron:string id:string new-account:string)
        @doc "Moves the Recreate Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can recreate any existing NFT in the Collection \
            \ Recreation reffers to a complete update (modification) of all NFT properties of a given nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveRecreateRole id false new-account)
                )
            )
        )
    )
    (defun DPNF|C_MoveSetUriRole (patron:string id:string new-account:string)
        @doc "Moves the Set URI Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can modify the URIs of any nonce in the NFT Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveSetUriRole id false new-account)
                )
            )
        )
    )
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun DPNF|C_Control (patron:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        @doc "Controls DPNF Properties"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_Control id false cu cco ccc casr ctncr cf cw cp)
                )
            )
        )
    )
    (defun DPNF|C_TogglePause (patron:string id:string toggle:bool)
        @doc "Pauses a DPNF Collection. Paused Collections can no longer be transfered"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_TogglePause id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_Respawn (patron:string id:string account:string nonce:integer)
        @doc "Respawns NFT <id> <nonce> on <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_RespawnNFT account id nonce)
                )
                (format "Succesfuly respawned NFT {} Nonce {} on Account {}" [id nonce (UC_ShortAccount account)])
            )
        )
    )
    (defun DPNF|C_Burn (patron:string id:string account:string nonce:integer)
        @doc "Burns NFT <id> <nonce> on <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_BurnNFT account id nonce)
                )
                (format "Succesfuly burned NFT {} Nonce {} on Account {}" [id nonce (UC_ShortAccount account)])
            )
        )
    )
    (defun DPNF|C_WipeNonce (patron:string id:string account:string nonce:integer)
        @doc "Wipes NFT <id> <nonce> on <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_WipeNonce account id false nonce)
                )
                (format "Succesfuly wiped NFT {} Nonce {} from Account {}" [id nonce (UC_ShortAccount account)])
            )
        )
    )
    (defun DPNF|CC_WipeHeavy (patron:string account:string id:string)
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::CC_WipeHeavy account id false)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Succesfuly executed Heavy Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|C_WipePure (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipePure account id false removable-nonces-obj) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Succesfuly executed Pure Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|C_WipeClean (patron:string account:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeClean account id false nonces) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Succesfuly executed Clean Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|C_WipeDirty (patron:string account:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeDirty account id false nonces)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format
                    "Succesfuly executed Dirty Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}"
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|Cp_WipeSlice (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes ONE <URHC_BuildWipeSlicePlan> slice of the NFT \
            \ <account>'s <id> nonces. The UI dirty-reads the plan and fires one such tx per \
            \ slice, all in parallel; slices are disjoint, order-independent and retryable \
            \ (replay REVERTS on the zeroed account supply)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
    (defun DPNF|C_Repurpose (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose NFT(s) from <repurpose-from> to <repurpose-to>. Requires <id> ownerhsip"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_RepurposeCollectable id false repurpose-from repurpose-to nonces amounts)
                )
                (format "Successfully repurposed NFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPNF|C_TransferNonce (patron:string id:string sender:string receiver:string nonce:integer amount:integer method:bool)
        @doc "Transfer an NFT <nonce> of <amount> from <sender> to <receiver> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
                (ref-IGNIS::XE_CollectIgnis patron
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
    (defun DPNF|C_TransferNonces (patron:string id:string sender:string receiver:string nonces:[integer] amounts:[integer] method:bool)
        @doc "Transfer an NFT <nonce> of <amount> from <sender> to <receiver> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
                (ref-IGNIS::XE_CollectIgnis patron
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
    (defun DPNF|C_BulkTransfer
        (patron:string id:string nonces-array:[[integer]] amounts-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        @doc "Bulk NFT transfer — son=false wrapper over TS02-C1.DPDC|C_BulkTransfer."
        (let
            (
                (ref-TS02-C1:module{TalosStageTwo_ClientOneV2} TS02-C1)
            )
            (ref-TS02-C1::DPDC|C_BulkTransfer patron id false nonces-array amounts-array sender receiver-lst method)
        )
    )
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun DPNF|C_Make
        (patron:string account:string id:string nonces:[integer] set-class:integer)
        @doc "Makes a Set NFT of Class <set-class>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                    (nonce:integer (+ 1 (ref-DPDC::UR_NoncesUsed id false)))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_MakeNonFungibleSet account id nonces set-class)
                )
                (format "Successfully generated Class {} Set (Nonce {}) of NFT Collection {} on Account {}" [set-class nonce id sa])
            )
        )
    )
    (defun DPNF|C_Break
        (patron:string account:string id:string nonce:integer)
        @doc "Brakes an NFT Nonce representing an NFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (set-class:integer (ref-DPDC::UR_NonceClass id false nonce))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_BreakNonFungibleSet account id nonce)
                )
                (format "Successfully broken Class {} Set (Nonce {}) of NFT Collection {} on Account {}" [set-class nonce id sa])
            )
        )
    )
    (defun DPNF|C_DefinePrimordialSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Primordial NFT Set. Primordial Sets are composed of Class 0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_DefinePrimordialSet id false set-name score-multiplier set-definition ind)
                )
                (format "Primordial Set <{}> for NFT Collection {} defined succesfully" [set-name id])
            )
        )
    )
    (defun DPNF|C_DefineCompositeSet
        (
            patron:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Composite NFT Set. Composite Sets are composed of Class (!=0) Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_DefineCompositeSet id false set-name score-multiplier set-definition ind)
                )
                (format "Composite Set <{}> for NFT Collection {} defined succesfully" [set-name id])
            )
        )
    )
    (defun DPNF|C_DefineHybridSet
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_DefineHybridSet id false set-name score-multiplier primordial-sd composite-sd ind)
                )
                (format "Hybrid Set <{}> for NFT Collection {} defined succesfully" [set-name id])
            )
        )
    )
    (defun DPNF|C_EnableSetClassFragmentation
        (
            patron:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Enables Fragmentation for a given Set Class. This allows all NFTs of the given Set Class to be Fragmented"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_EnableSetClassFragmentation id false set-class fragmentation-ind)
                )
                (format "Set Class {} for NFT {} succesfully fragmented" [set-class id])
            )
        )
    )
    (defun DPNF|C_ToggleSet (patron:string id:string set-class:integer toggle:bool)
        @doc "Enables or Disables a Set. A disabled Set allows only for decomposition of Set Elements, but not for composition"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_ToggleSet id false set-class toggle)
                )
                (format "NFT {} Set Class {} succesfully turned {}" [id set-class (if toggle "ON" "OFF")])
            )
        )
    )
    (defun DPNF|C_RenameSet (patron:string id:string set-class:integer new-name:string)
        @doc "Renames an NFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_RenameSet id false set-class new-name)
                )
                (format "NFT {} Set Class {} succesfuly renamed to <{}>" [id set-class new-name])
            )
        )
    )
    ;; DPNF|C_UpdateSetMultiplier removed — DPDC Audit #15H.
    ;;
    (defun DPNF|C_UpdateSetNonce 
        (patron:string id:string account:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces id false account [set-class] nos false [new-nonce-data])
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonces
        (patron:string id:string account:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces id false account set-classes nos false new-nonces-data)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceRoyalty
        (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Set Nonce Native Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty id false account set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceIgnisRoyalty
        (patron:string id:string account:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Set Nonce IGNIS Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty id false account set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceName
        (patron:string id:string account:string set-class:integer nos:bool name:string)
        @doc "[3] Updates Set Nonce Name, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName id false account set-class nos false name)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceDescription
        (patron:string id:string account:string set-class:integer nos:bool description:string)
        @doc "[4] Updates Set Nonce Description, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription id false account set-class nos false description)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceScore
        (patron:string id:string account:string set-class:integer nos:bool score:decimal)
        @doc "[5] Updates Set Nonce Score, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore id false account set-class nos false score)
                )
            )
        )
    )
    (defun DPNF|C_RemoveSetNonceScore (patron:string id:string account:string set-class:integer nos:bool)
        @doc "[5b] Removes Set Nonce Score, setting it to -1.0, either Native or Split, for an NFT"
        (DPNF|C_UpdateSetNonceScore patron id account set-class nos -1.0)
    )
    (defun DPNF|C_UpdateSetNonceMetaData
        (patron:string id:string account:string set-class:integer nos:bool meta-data:object)
        @doc "[6] Updates Set Nonce Meta-Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData id false account set-class nos false meta-data)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceURI
        (
            patron:string id:string account:string set-class:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Set Nonce URI, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI id false account set-class nos false ay u1 u2 u3)
                )
            )
        )
    )
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun DPNF|C_RepurposeFragments (patron:string id:string repurpose-from:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose NFT Fragment(s) from <repurpose-from> to <repurpose-to>. Requires <id> ownerhsip"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-from))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    ;; #79: this is the NFT (C_DPNF|) wrapper — son MUST be false. Was hardcoded `true`
                    ;; (SFT), so it read CNF from the DPSF table and failed. Never caught: no test coverage.
                    (ref-DPDC-F::C_RepurposeCollectableFragments id false repurpose-from repurpose-to nonces amounts)
                )
                (format "Successfully repurposed NFT {} Fragment-Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPNF|C_MakeFragments (patron:string account:string id:string nonce:integer amount:integer)
        @doc "Fragments NFT nonce of the given amount into its respective Fragments."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MakeFragments account id false nonce amount)
                )
                (format "Succesfuly Fragmented {} NFT(s) {} of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPNF|C_MergeFragments (patron:string account:string id:string nonce:integer amount:integer)
        @doc "MErges NFT Fragments nonces of the given amount into the original NFT nonce."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MergeFragments account id false nonce amount)
                )
                (format "Succesfuly merged {} {} NFT(s) Fragments of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPNF|C_EnableNonceFragmentation (patron:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        @doc "Enables Fragmentation for a given NFT Nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_EnableNonceFragmentation id false nonce fragmentation-ind)
                )
                (format "Fragmentation for NFT {} Nonce {} enabled succesfully" [id nonce])
            )
        )
    )
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun DPNF|C_UpdateNonce 
        (patron:string id:string account:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces id false account [nonce] nos true [new-nonce-data])
                )
                (format "Nonce {} updated successfully!" [nonce])
            )
        )
    )
    (defun DPNF|C_UpdateNonces
        (patron:string id:string account:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces id false account nonces nos true new-nonces-data)
                )
                (format "Nonces {} updated successfully!" [nonces])
            )
        )
    )
    (defun DPNF|C_UpdateNonceRoyalty
        (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Nonce Native Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty id false account nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceIgnisRoyalty
        (patron:string id:string account:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Nonce IGNIS Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty id false account nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceName
        (patron:string id:string account:string nonce:integer nos:bool name:string)
        @doc "[3] Updates Nonce Name, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName id false account nonce nos true name)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceDescription
        (patron:string id:string account:string nonce:integer nos:bool description:string)
        @doc "[4] Updates Nonce Description, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription id false account nonce nos true description)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceScore
        (patron:string id:string account:string nonce:integer nos:bool score:decimal)
        @doc "[5] Updates Nonce Score, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore id false account nonce nos true score)
                )
            )
        )
    )
    (defun DPNF|C_RemoveNonceScore (patron:string id:string account:string nonce:integer nos:bool)
        @doc "[5b] Removes Nonce Score, setting it to -1.0, either Native or Split, for an NFT"
        (DPNF|C_UpdateNonceScore patron id account nonce nos -1.0)
    )
    (defun DPNF|C_UpdateNonceMetaData
        (patron:string id:string account:string nonce:integer nos:bool meta-data:object)
        @doc "[6] Updates Nonce Meta-Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData id false account nonce nos true meta-data)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceURI
        (
            patron:string id:string account:string nonce:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Nonce URI, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI id false account nonce nos true ay u1 u2 u3)
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


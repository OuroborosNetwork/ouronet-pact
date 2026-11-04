;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 7 of 8
;; This is STEP 7 of 8 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-6 must have run first, including the init steps between deploys.
;; 4 source file(s), 228,487 gas measured in the REPL gas model, 289,306 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact
;;   1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact
;;   2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact
;;   1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact
;;
;; TOTAL: 0 interface(s), 4 module(s), 6 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact
;;      module     AQP-INFO
;;   -- 1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact
;;      module     TS02-DPAD
;;      table      P|T
;;      table      P|MT
;;   -- 2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact
;;      module     STOAICO
;;      table      P|T
;;      table      P|MT
;;      table      STOAICO|T|User
;;      table      STOAICO|T|General
;;   -- 1_SOVEREIGN/STAGE_02/Z_Reads/01_INFO-TWO.pact
;;      module     INFO-TWO
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
;; wrapper. It returns object{OuronetInfoV3.ClientInfo} describing what the op does,
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
    (defun INFO_AQP-ANK|IssueTrueFungibleAnchor:object{OuronetInfoV3.ClientInfo}
        (patron:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Cost preview for AQP-ANK|C_IssueTrueFungibleAnchor. IGNIS 1000 (inline) + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
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
    (defun INFO_AQP-ANK|IssueSemiFungibleAnchor:object{OuronetInfoV3.ClientInfo}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Cost preview for AQP-ANK|C_IssueSemiFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
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
    (defun INFO_AQP-ANK|IssueNonFungibleAnchor:object{OuronetInfoV3.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Cost preview for AQP-ANK|C_IssueNonFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
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
    (defun INFO_AQP-ANK|IssueNonFungibleSetAnchor:object{OuronetInfoV3.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Cost preview for AQP-ANK|C_IssueNonFungibleSetAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
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
    (defun INFO_AQP-ANK|RevokeAnchor:object{OuronetInfoV3.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-ANK|C_RevokeAnchor. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
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
    (defun INFO_AQP-ANK|RevokeBoostClass:object{OuronetInfoV3.ClientInfo}
        (patron:string boost-class-id:string)
        @doc "Cost preview for AQP-ANK|C_RevokeBoostClass. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
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
    (defun INFO_AQP-SCR|IssueLiquidityScore:object{OuronetInfoV3.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueLiquidityScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-0 (Liquidity) score." "Executes via TS02-C3.AQP-SCR|C_IssueLiquidityScore."]
                [(format "Liquidity score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueTrueFungibleScore:object{OuronetInfoV3.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueTrueFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-1 (True-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueTrueFungibleScore."]
                [(format "True-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueOrtoFungibleScore:object{OuronetInfoV3.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueOrtoFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-2 (Orto-Fungible / special) score." "Executes via TS02-C3.AQP-SCR|C_IssueOrtoFungibleScore."]
                [(format "Orto-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueSemiFungibleScore:object{OuronetInfoV3.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Cost preview for AQP-SCR|C_IssueSemiFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-3 (Semi-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueSemiFungibleScore."]
                [(format "Semi-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueNonFungibleScore:object{OuronetInfoV3.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-4 (Non-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleScore."]
                [(format "Non-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScore owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-SCORE.URCi_IssueScoreStoa))
                [])
        )
    )
    (defun INFO_AQP-SCR|RotateScoreOwnership:object{OuronetInfoV3.ClientInfo}
        (patron:string score-id:string new-owner-konto:string)
        @doc "Cost preview for AQP-SCR|C_RotateScoreOwnership. IGNIS 'ignis|medium' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer a score's owner-konto." "Executes via TS02-C3.AQP-SCR|C_RotateScoreOwnership."]
                [(format "Score {} ownership moved to {}." [score-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_RotateOwnership score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|ControlScore:object{OuronetInfoV3.ClientInfo}
        (patron:string score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for AQP-SCR|C_ControlScore. IGNIS 'ignis|medium' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a score's can-upgrade / can-change-owner flags." "Executes via TS02-C3.AQP-SCR|C_ControlScore."]
                [(format "Score {} control flags updated." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_Control score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|CreateScoreBoostClassLink:object{OuronetInfoV3.ClientInfo}
        (patron:string score-id:string boost-class-id:string)
        @doc "Cost preview for AQP-SCR|C_CreateScoreBoostClassLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a BoostClass (once)." "Executes via TS02-C3.AQP-SCR|C_CreateScoreBoostClassLink."]
                [(format "Score {} linked to BoostClass {}." [score-id boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CreateBoostClassLink score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|CreateScoreBoostLink:object{OuronetInfoV3.ClientInfo}
        (patron:string score-id:string boost-score-id:string)
        @doc "Cost preview for AQP-SCR|C_CreateScoreBoostLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a boost-score (once)." "Executes via TS02-C3.AQP-SCR|C_CreateScoreBoostLink."]
                [(format "Score {} boost-linked to {}." [score-id boost-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CreateBoostLink score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|EnableDebBoost:object{OuronetInfoV3.ClientInfo}
        (patron:string score-id:string)
        @doc "Cost preview for AQP-SCR|C_EnableDebBoost. IGNIS 'ignis|medium' tier; no STOA. Irreversible."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable deb-boost on a score (irreversible)." "Executes via TS02-C3.AQP-SCR|C_EnableDebBoost."]
                [(format "Score {} deb-boost enabled." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_EnableDebBoost score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|LockScoreDrift:object{OuronetInfoV3.ClientInfo}
        (patron:string score-id:string)
        @doc "Cost preview for AQP-SCR|C_LockScoreDrift. IGNIS only; no STOA. IRREVERSIBLE -- and \
            \ the preview says what it costs the score afterwards, not just what it costs now: a \
            \ locked score can never acquire deb-boost or a boost-class link."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Permanently mark a score drift-proof (irreversible)." "Executes via TS02-C3.AQP-SCR|C_LockScoreDrift."]
                [(format "Score {} drift-locked: {} -> true. It then refuses deb-boost and any boost-class link, for good."
                    [score-id (AQP-SCORE.UR_SCR|ScoreDriftLocked score-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_LockScoreDrift score-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueTriplet:object{OuronetInfoV3.ClientInfo}
        (patron:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Cost preview for AQP-SCR|C_IssueTriplet. IGNIS GAS|ISSUE-TRIPLET; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bundle three scores into one triplet (T|bronze|silver|golden)." "Executes via TS02-C3.AQP-SCR|C_IssueTriplet."]
                [(format "Triplet issued from {} / {} / {}." [bronze-score-id silver-score-id golden-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueTriplet silver-score-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueSingleScoreModel:object{OuronetInfoV3.ClientInfo}
        (patron:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueSingleScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Define a SINGLE score-entity model." "Executes via TS02-C3.AQP-SCR|C_IssueSingleScoreModel."]
                [(format "Single score model '{}' defined (class {})." [model-name score-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScoreModel "AQP-SCR|C_IssueSingleScoreModel" patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|CombineTripletScoreModel:object{OuronetInfoV3.ClientInfo}
        (patron:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
        @doc "Cost preview for AQP-SCR|C_CombineTripletScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Combine three SINGLE models into a TRIPLET model." "Executes via TS02-C3.AQP-SCR|C_CombineTripletScoreModel."]
                [(format "Triplet score model '{}' combined." [model-name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_CombineTripletModel patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueScoreFromModel:object{OuronetInfoV3.ClientInfo}
        (patron:string owner-konto:string model-id:string agency-name:string)
        @doc "Cost preview for AQP-SCR|C_IssueScoreFromModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a score/triplet entity conforming to a model." "Executes via TS02-C3.AQP-SCR|C_IssueScoreFromModel."]
                [(format "Entity '{}' issued from model {} for {}." [agency-name model-id owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueScoreModel "AQP-SCR|C_IssueScoreFromModel" patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueSemiFungibleScoreDefinition:object{OuronetInfoV3.ClientInfo}
        (patron:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueSemiFungibleScoreDefinition. IGNIS = count × 'ignis|big'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Semi-Fungible score definition rows (one per nonce)." "Executes via TS02-C3.AQP-SCR|C_IssueSemiFungibleScoreDefinition."]
                [(format "Wrote {} SF score-definition rows on score {}." [(length nonces) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueSemiFungibleScoreDefinition score-id nonces)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueNonFungibleScoreDefinition:object{OuronetInfoV3.ClientInfo}
        (patron:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible trait-score definition rows (one per trait)." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleScoreDefinition."]
                [(format "Wrote {} NF trait-score rows on score {}." [(length trait-keys) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-SCORE.URCi_IssueNonFungibleScoreDefinition score-id trait-keys)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-SCR|IssueNonFungibleSetScoreDefinition:object{OuronetInfoV3.ClientInfo}
        (patron:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleSetScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-POOL|Issue:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Cost preview for AQP-POOL|C_Issue. IGNIS GAS|ISSUE-POOL + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a new staking pool over an asset." "Executes via TS02-C3.AQP-POOL|C_Issue."]
                [(format "Pool '{}' created over asset {} (class {})." [pool-name asset-id aqp-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_Issue [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-POOL.URCi_IssueStoa))
                [])
        )
    )
    (defun INFO_AQP-POOL|AddScore:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|C_AddScore. IGNIS GAS|ADD-SCORE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Assign a score to the pool's first free slot." "Executes via TS02-C3.AQP-POOL|C_AddScore."]
                [(format "Score {} added to pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_AddScore [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|RevokeScore:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|C_RevokeScore. IGNIS GAS|REVOKE-SCORE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Clear a score from its pool slot." "Executes via TS02-C3.AQP-POOL|C_RevokeScore."]
                [(format "Score {} revoked from pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_RevokeScore [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|EnablePoolStake:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_EnablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Re-enable new stakes on a pool." "Executes via TS02-C3.AQP-POOL|C_EnablePoolStake."]
                [(format "Pool {} staking enabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_SetPoolStake [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|DisablePoolStake:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_DisablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Pause new stakes on a pool." "Executes via TS02-C3.AQP-POOL|C_DisablePoolStake."]
                [(format "Pool {} staking disabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_SetPoolStake [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|SyncTrueFungibleAnchors:object{OuronetInfoV3.ClientInfo}
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncTrueFungibleAnchors. FULL IGNIS: GAS|SYNC-TF-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live TF anchors) + biggest-tier sync-count stamp; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's True-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-POOL|C_SyncTrueFungibleAnchors."]
                [(format "TF anchors synced for {} on DPTF {}." [(ref-I|OURONET::OI|UC_ShortAccount beneficiary-id) dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncTrueFungibleAnchorsFull beneficiary-id dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|SyncSemiFungibleAnchors:object{OuronetInfoV3.ClientInfo}
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncSemiFungibleAnchors. FULL IGNIS: GAS|SYNC-COLLECTABLE-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live SF anchors) + biggest-tier sync-count stamp; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Semi-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-POOL|C_SyncSemiFungibleAnchors."]
                [(format "SF anchors synced for {} on DPSF {}." [(ref-I|OURONET::OI|UC_ShortAccount beneficiary-id) dpsf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncCollectableAnchorsFull beneficiary-id dpsf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|SyncNonFungibleAnchors:object{OuronetInfoV3.ClientInfo}
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncNonFungibleAnchors. FULL IGNIS: GAS|SYNC-COLLECTABLE-ANCHORS gas leg + \
            \ state-dependent ANK anchor-repair (ignis|small x live NF anchors) + biggest-tier sync-count stamp; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Non-Fungible anchor slots after a stake."
                 "Full IGNIS shown: gas + per-anchor repair + sync-count stamp (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-POOL|C_SyncNonFungibleAnchors."]
                [(format "NF anchors synced for {} on DPNF {}." [(ref-I|OURONET::OI|UC_ShortAccount beneficiary-id) dpnf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (AQP-POOL.URCi_SyncCollectableAnchorsFull beneficiary-id dpnf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;<---- stake / unstake (multi-leg reconstructed cost) ---->
    (defun INFO_AQP-POOL|StakeTrueFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-POOL|CC_StakeTrueFungible. Full multi-leg IGNIS (transfer + tracker + rollup \
            \ + RPS + anchor + score-delta + book + checkpoint); no STOA. Cost reconstructed byte-for-byte."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake a True-Fungible amount into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeTrueFungible."]
                [(format "Staked {} of {} into pool {} for {}." [amount dptf-id pool-id (ref-I|OURONET::OI|UC_ShortAccount beneficiary-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-RPSC::URCi_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-POOL|UnstakeTrueFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-POOL|CC_UnstakeTrueFungible. Same legs as stake with the custody transfer \
            \ reversed (vault→owner); no STOA. Cost reconstructed byte-for-byte."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake a True-Fungible amount from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeTrueFungible."]
                [(format "Unstaked {} of {} from pool {} for {}." [amount dptf-id pool-id (ref-I|OURONET::OI|UC_ShortAccount beneficiary-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-RPSC::URCi_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-POOL|StakeOrtoFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeOrtoFungible. Multi-leg IGNIS (transfer + tracker×|nonces| + RPS \
            \ + class-matched score-delta + book + checkpoint); no STOA. Reconstructed byte-for-byte."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake whole Orto-Fungible nonces into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeOrtoFungible."]
                [(format "Staked {} nonces of {} into pool {} for {}." [(length nonces) dpof-id pool-id (ref-I|OURONET::OI|UC_ShortAccount beneficiary-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-RPSC::URCi_OrtoFungibleStakeFlow pool-id owner-id beneficiary-id dpof-id nonces true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|UnstakeOrtoFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeOrtoFungible. Same legs as OF stake; no STOA. Reconstructed byte-for-byte."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake whole Orto-Fungible nonces from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeOrtoFungible."]
                [(format "Unstaked {} nonces of {} from pool {} for {}." [(length nonces) dpof-id pool-id (ref-I|OURONET::OI|UC_ShortAccount beneficiary-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-RPSC::URCi_OrtoFungibleStakeFlow pool-id owner-id beneficiary-id dpof-id nonces false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|StakeSpecialCustodial:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CCp_StakeSpecialCustodial. \
            \ IDENTICAL IGNIS TO AN ORDINARY ORTO STAKE, and that is a fact about the code rather \
            \ than an approximation: custody runs the SAME phase chain (`XI_OrtoStakePhases`) and \
            \ differs only in which account goes in the tracker's owner column. \
            \ `URCi_OrtoFungibleStakeFlow` does not read that column -- its legs are the transfer, \
            \ the per-nonce tracker write, the settle bundle, the score delta, the book and the \
            \ checkpoint -- so the quote is exact, not a stand-in. No STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake sleeping (Z|) LP nonces under POOL CUSTODY — held until the lock matures."
                 "Scores and rewards still accrue to the beneficiary; release is permissionless once matured."
                 "Executes via TS02-C3.AQP-POOL|CCp_StakeSpecialCustodial."]
                [(format "Staked {} sleeping nonce(s) of {} into pool {} under custody for {}."
                    [(length nonces) dpof-id pool-id (ref-I|OURONET::OI|UC_ShortAccount beneficiary-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-RPSC::URCi_OrtoFungibleStakeFlow pool-id owner-id beneficiary-id dpof-id nonces true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|ReleaseSpecialCustodial:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string beneficiary-id:string dpof-id:string nonce:integer)
        @doc "Cost preview for AQP-POOL|CCp_ReleaseSpecialCustodial. TWO LEGS, because the release \
            \ does two things: it unwinds the stake (the orto flow in the UNSTAKE direction, over \
            \ the single nonce) and it dissolves the batch through `VST::XE_Unsleep`. Both legs \
            \ are reconstructed from the same cost readers the execution path calls. No STOA. \
            \ \
            \ PERMISSIONLESS, so the patron quoted here need not be the beneficiary -- anyone may \
            \ pay to finish a matured release, and the native tokens still go to the staker."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Release a MATURED custodial sleeping position — dissolve the batch, send the native asset to the staker."
                 "Permissionless once the lock has matured; refused before."
                 "Executes via TS02-C3.AQP-POOL|CCp_ReleaseSpecialCustodial."]
                [(format "Released nonce {} of {} from pool {} to {}." [nonce dpof-id pool-id (ref-I|OURONET::OI|UC_ShortAccount beneficiary-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_ReleaseSpecialCustodial pool-id beneficiary-id dpof-id nonce))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [nonce])
        )
    )
    (defun INFO_AQP-POOL|ReassignOrtoStakeBeneficiary:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner:string current-beneficiary:string
         new-beneficiary:string dpof-id:string nonce:integer)
        @doc "Cost preview for AQP-POOL|CC_ReassignOrtoStakeBeneficiary. RENAMED from \
            \ INFO_AQP-POOL|ReassignCustodialBeneficiary, 2026-10-11 -- custody is retired, \
            \ this covers any staked sleeping position. The orto phase chain priced TWICE over \
            \ one nonce, reconstructed from the same reader the execution path uses. No STOA. \
            \ \
            \ NO ASSET MOVES, but the quote still carries a transfer leg per run, because \
            \ `URCi_OrtoFungibleStakeFlow` prices that leg direction-independently."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Redirect who earns from an already-staked sleeping position — the owner and the position are unchanged."
                 "Requires the OWNER's signature — they decide who earns, as they did at the original stake."
                 "Executes via TS02-C3.AQP-POOL|CC_ReassignOrtoStakeBeneficiary."]
                [(format "Nonce {} of {} in pool {} now earns for {} instead of {}." [nonce dpof-id pool-id (ref-I|OURONET::OI|UC_ShortAccount new-beneficiary) (ref-I|OURONET::OI|UC_ShortAccount current-beneficiary)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_ReassignOrtoStakeBeneficiary pool-id owner current-beneficiary new-beneficiary dpof-id nonce))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [nonce])
        )
    )
    (defun INFO_AQP-POOL|ReassignCollectableStakeBeneficiary:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner:string current-beneficiary:string
         new-beneficiary:string collectable-id:string son:bool nonce:integer nonce-amount:integer)
        @doc "Cost preview for AQP-POOL|CC_ReassignCollectableStakeBeneficiary -- the NFT/SFT \
            \ counterpart of INFO_AQP-POOL|ReassignOrtoStakeBeneficiary. No maturity lock applies \
            \ to a collectable; this previews redirecting earnings on an already-staked nonce. \
            \ No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Redirect who earns from an already-staked NFT/SFT — the owner and the position are unchanged."
                 "Requires the OWNER's signature — they decide who earns, as they did at the original stake."
                 "Executes via TS02-C3.AQP-POOL|CC_ReassignCollectableStakeBeneficiary."]
                [(format "Nonce {} of {} in pool {} now earns for {} instead of {}." [nonce collectable-id pool-id (ref-I|OURONET::OI|UC_ShortAccount new-beneficiary) (ref-I|OURONET::OI|UC_ShortAccount current-beneficiary)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_ReassignCollectableStakeBeneficiary pool-id owner current-beneficiary new-beneficiary collectable-id son nonce nonce-amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [nonce])
        )
    )
    (defun INFO_AQP-POOL|ReassignTrueFungibleStakeBeneficiary:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner:string current-beneficiary:string
         new-beneficiary:string dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-POOL|CC_ReassignTrueFungibleStakeBeneficiary -- the TF \
            \ counterpart of INFO_AQP-POOL|ReassignOrtoStakeBeneficiary. The TF phase chain priced \
            \ TWICE over <amount>, reconstructed from the same reader the execution path uses. \
            \ No STOA. \
            \ \
            \ NO ASSET MOVES, but the quote still carries a transfer leg per run, because \
            \ `URCi_TrueFungibleStakeFlow` prices that leg direction-independently."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Redirect who earns from an already-staked true-fungible position — the owner and the position are unchanged."
                 "Requires the OWNER's signature — they decide who earns, as they did at the original stake."
                 "Executes via TS02-C3.AQP-POOL|CC_ReassignTrueFungibleStakeBeneficiary."]
                [(format "{} of {} in pool {} now earns for {} instead of {}." [amount dptf-id pool-id (ref-I|OURONET::OI|UC_ShortAccount new-beneficiary) (ref-I|OURONET::OI|UC_ShortAccount current-beneficiary)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-FVT.URCi_ReassignTrueFungibleStakeBeneficiary pool-id owner current-beneficiary new-beneficiary dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-POOL|StakeSemiFungibleCollectable:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeSemiFungibleCollectable (DPSF, son=true / class-3). Multi-leg IGNIS \
            \ (transfer + tracker×|nonces| + rollup×|nonces| + RPS + flat anchor + class-3 score-delta + book + checkpoint); no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake Semi-Fungible collectable nonces (DPSF) into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeSemiFungibleCollectable."]
                [(format "Staked {} DPSF nonces of {} into pool {} for {}." [(length nonces) collectable-id pool-id (ref-I|OURONET::OI|UC_ShortAccount beneficiary-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-RPSC::URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id true nonces
                        (DPDC.UR_AccountNoncesSupplies owner-id collectable-id true nonces) true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|UnstakeSemiFungibleCollectable:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeSemiFungibleCollectable (DPSF, son=true / class-3). Same legs as SF stake; \
            \ nonce-amounts is caller-supplied (the staked quantities — owner no longer holds them). No STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake Semi-Fungible collectable nonces (DPSF) from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeSemiFungibleCollectable."]
                [(format "Unstaked {} DPSF nonces of {} from pool {} for {}." [(length nonces) collectable-id pool-id (ref-I|OURONET::OI|UC_ShortAccount beneficiary-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-RPSC::URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id true nonces nonce-amounts false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|StakeNonFungibleCollectable:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer])
        @doc "Cost preview for AQP-POOL|CC_StakeNonFungibleCollectable (DPNF, son=false / class-4). Multi-leg IGNIS \
            \ (transfer + tracker×|nonces| + rollup×|nonces| + RPS + flat anchor + class-4 score-delta + book + checkpoint); no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Stake Non-Fungible collectable nonces (DPNF) into the pool for a beneficiary."
                 "Executes via TS02-C3.AQP-POOL|CC_StakeNonFungibleCollectable."]
                [(format "Staked {} DPNF nonces of {} into pool {} for {}." [(length nonces) collectable-id pool-id (ref-I|OURONET::OI|UC_ShortAccount beneficiary-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-RPSC::URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id false nonces
                        (DPDC.UR_AccountNoncesSupplies owner-id collectable-id false nonces) true))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    (defun INFO_AQP-POOL|UnstakeNonFungibleCollectable:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Cost preview for AQP-POOL|CC_UnstakeNonFungibleCollectable (DPNF, son=false / class-4). Same legs as NF stake; \
            \ nonce-amounts is caller-supplied (the staked quantities — owner no longer holds them). No STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Unstake Non-Fungible collectable nonces (DPNF) from the pool."
                 "Executes via TS02-C3.AQP-POOL|CC_UnstakeNonFungibleCollectable."]
                [(format "Unstaked {} DPNF nonces of {} from pool {} for {}." [(length nonces) collectable-id pool-id (ref-I|OURONET::OI|UC_ShortAccount beneficiary-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-RPSC::URCi_CollectableStakeFlow pool-id owner-id beneficiary-id collectable-id false nonces nonce-amounts false))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length nonces)])
        )
    )
    ;;<---- vacate lifecycle (fixed-cost endpoints) ---->
    (defun INFO_AQP-POOL|BatchVacateTrueFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV3.VCT|VacateTfLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateTrueFungible. Multi-leg IGNIS (per-leg \
            \ tracker-zero + per-beneficiary unwind + one bulk transfer); no STOA. Fed the same \
            \ dirty-read <legs> slice the exec is fed."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-POOL|BatchVacateOrtoFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string dpof-id:string legs:[object{AcquisitionSchemasV3.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateOrtoFungible. Multi-leg IGNIS (bulk DPOF \
            \ transfer + per-nonce tracker + per-beneficiary score unwind); no STOA. Fed the same \
            \ dirty-read nonce <legs> slice the exec is fed."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-POOL|BatchVacateCollectables:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string collectable-id:string son:bool legs:[object{AcquisitionSchemasV3.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchVacateCollectables (son=DPSF true / DPNF false). \
            \ Multi-leg IGNIS (bulk transfer + per-nonce tracker + rollup + flat anchor + per- \
            \ beneficiary class-matched score unwind); no STOA. Fed the dirty-read nonce <legs>."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-POOL|BatchDrainTrueFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV3.VCT|VacateTfLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchDrainTrueFungible. Score-free drain: per-leg \
            \ tracker-zero + rollup, settle-on-last-drain only for beneficiaries fully drained \
            \ this round (live UserUnn), then one bulk transfer; no STOA. Fed the dirty-read legs."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-POOL|BatchDrainOrtoFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string dpof-id:string legs:[object{AcquisitionSchemasV3.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchDrainOrtoFungible. Score-free drain: bulk DPOF \
            \ transfer + per-nonce tracker + settle-on-last-drain (no anchor); no STOA. Fed the legs."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-POOL|BatchDrainCollectable:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string collectable-id:string son:bool legs:[object{AcquisitionSchemasV3.VCT|VacateNonceLeg}])
        @doc "Cost preview for AQP-POOL|CCp_BatchDrainCollectable (son=DPSF true / DPNF false). \
            \ Score-free drain: bulk transfer + per-leg tracker + rollup + flat anchor + settle- \
            \ on-last-drain; no STOA. Fed the dirty-read nonce <legs>."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-POOL|VacateTrueFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|CC_VacateTrueFungible -- the pool's WHOLE TrueFungible \
            \ side, every live DPTF lane including the F| frozen ones. No STOA. \
            \ \
            \ TAKES ONLY A POOL ID, unlike INFO_AQP-POOL|FullVacate, which is handed its lane \
            \ plan because its caller has already scanned. `URCi_VacateTrueFungible` performs \
            \ the same scan the exec does, so this is previewable from what the user has in \
            \ front of them."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Vacate every TrueFungible lane of a pool, for all owners."
                 "Executes via TS02-C3.AQP-POOL|CC_VacateTrueFungible."]
                [(format "Vacated the TrueFungible side of Pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_VacateTrueFungible pool-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|VacateOrtoFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string dpof-id:string)
        @doc "Cost preview for AQP-POOL|CC_VacateOrtoFungible -- ONE OrtoFungible satellite of a \
            \ pool, not the pool. A class-1 pool has a TF leg plus one or more OF satellites; \
            \ this prices one of them. No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Vacate ONE OrtoFungible satellite of a pool, for all owners."
                 "Executes via TS02-C3.AQP-POOL|CC_VacateOrtoFungible."]
                [(format "Vacated OrtoFungible {} of Pool {}." [dpof-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_VacateOrtoFungible pool-id dpof-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|VacateSemiFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string dpsf-id:string)
        @doc "Cost preview for AQP-POOL|CC_VacateSemiFungible -- ONE DPSF collection of a pool. \
            \ The DPSF and DPNF previews differ only in which side of the shared reader they \
            \ select, so they are separate functions rather than one with a flag: a client that \
            \ passed the wrong flag would quote the other asset's cost and never know."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Vacate ONE semi-fungible collection of a pool, for all owners."
                 "Executes via TS02-C3.AQP-POOL|CC_VacateSemiFungible."]
                [(format "Vacated SemiFungible {} of Pool {}." [dpsf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_VacateSemiFungible pool-id dpsf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|VacateNonFungible:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string dpnf-id:string)
        @doc "Cost preview for AQP-POOL|CC_VacateNonFungible -- ONE DPNF collection of a pool. \
            \ See the DPSF sibling for why these are two functions and not one."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Vacate ONE non-fungible collection of a pool, for all owners."
                 "Executes via TS02-C3.AQP-POOL|CC_VacateNonFungible."]
                [(format "Vacated NonFungible {} of Pool {}." [dpnf-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (AQP-VCT.URCi_VacateNonFungible pool-id dpnf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|FullVacate:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string
         tf-lanes:[object{AcquisitionSchemasV3.VCT|VacateTfLane}]
         of-lanes:[object{AcquisitionSchemasV3.VCT|VacateNonceLane}]
         coll-lanes:[object{AcquisitionSchemasV3.VCT|VacateNonceLane}]
         coll-son:bool)
        @doc "Cost preview for AQP-POOL|CC_FullVacate — the single-tx whole-pool vacate. Sums the \
            \ per-asset vacate cost across every dirty-read lane (TF + OF satellites + collectables); \
            \ no STOA. Fed the same lane plan the exec's phase-1 scan builds."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-POOL|FinalizeVacate:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_FinalizeVacate. IGNIS one flat 'ignis|medium' tier (05_VCT:3016); no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-POOL|AbortVacate:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_AbortVacate. Empty cumulator (05_VCT:2989) — costs you nothing."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-POOL|UpdateScoreMultipliers:object{OuronetInfoV3.ClientInfo}
        (patron:string score-id:string mx-frozen:decimal mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Cost preview for AQP-POOL|CC_UpdateScoreMultipliers. Flat 'setup' component — a \
            \ settings write, priced with the other one-shot score settings. No STOA. \
            \ \
            \ THE OP IS REFUSED while any frozen or sleeping position exists on the score, and \
            \ this quote does not try to predict that: a preview prices the transaction, and the \
            \ emptiness gate is a condition the caller discovers by reading the pool. Quoting \
            \ zero for a call that will abort would be worse than quoting its real price."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Re-set a score's frozen, sleeping and hibernating multipliers."
                 "Refused while any frozen or sleeping position exists on the score."
                 "Executes via TS02-C3.AQP-POOL|CC_UpdateScoreMultipliers."]
                [(format "Score {} multipliers set to frozen={} sleeping={} hibernated={}."
                    [score-id mx-frozen mx-sleeping mx-hibernated])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_UpdateScoreMultipliers [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|BackfillScoreSlice:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string score-id:string beneficiaries:[string])
        @doc "Cost preview for AQP-POOL|CCp_BackfillScoreSlice — one fed slice of the re-rate sweep. \
            \ PRICED PER HOLDER, matching the execution path exactly: the transaction recomputes \
            \ one target and writes one delta per account. So the quote SCALES with the slice the \
            \ caller intends to send, which is what makes it usable for sizing -- a flat price \
            \ would make a 1-account slice cost what a 40-account slice costs. No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Re-rate one slice of holders after a score was added to a pool."
                 "Order-independent and replay-safe — fire slices in parallel; a converged holder is a no-op."
                 "Executes via TS02-C3.AQP-POOL|CCp_BackfillScoreSlice."]
                [(format "Re-rated {} holder(s) on score {} of pool {}." [(length beneficiaries) score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                        (AQP-POOL.URCi_BackfillScoreSlice beneficiaries [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length beneficiaries)])
        )
    )
    (defun INFO_AQP-POOL|BeginScoreRevoke:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string score-id:string slot-index:integer)
        @doc "Cost preview for AQP-POOL|C_BeginScoreRevoke — phase 1 of 3. Flat 'setup' component: \
            \ vacate the score's pool slot and freeze the pool. No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Begin revoking a score from a pool (phase 1/3 — vacate the slot, freeze the pool)."
                 "Then drain with Cp_DrainScoreSlice, and finish with CC_FinalizeScoreRevoke."
                 "Executes via TS02-C3.AQP-POOL|C_BeginScoreRevoke."]
                [(format "Score {} vacated from slot {} of pool {}; pool frozen pending drain." [score-id slot-index pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_BeginScoreRevoke [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-POOL|DrainScoreSlice:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string score-id:string accounts:[string])
        @doc "Cost preview for AQP-POOL|Cp_DrainScoreSlice — phase 2 of 3, one fed slice. \
            \ PRICED PER HOLDER for the same reason as the re-rate slice: one read and one delta \
            \ write each, so the quote tracks the slice the caller means to send. No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Drain one slice of holders' bases for a score being revoked (phase 2/3)."
                 "Order-independent and replay-safe — fire slices in parallel."
                 "Executes via TS02-C3.AQP-POOL|Cp_DrainScoreSlice."]
                [(format "Drained {} holder(s) of score {} on pool {}." [(length accounts) score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                        (AQP-POOL.URCi_DrainScoreSlice accounts [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length accounts)])
        )
    )
    (defun INFO_AQP-POOL|FinalizeScoreRevoke:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|CC_FinalizeScoreRevoke — phase 3 of 3. Flat 'setup' \
            \ component: cut the aqpool-link once the drain has reached zero. Refused while any \
            \ holder still carries a base for the score. No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Finish revoking a score from a pool (phase 3/3 — cut the link, release the freeze)."
                 "Refused while any holder still carries a base for the score."
                 "Executes via TS02-C3.AQP-POOL|CC_FinalizeScoreRevoke."]
                [(format "Score {} unlinked from pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-POOL.URCi_FinalizeScoreRevoke [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    ;;
    ;;[AQP-FVT] Farms / Vaults / Treasuries (config + rewards)
    (defun INFO_AQP-FVT|Issue:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Cost preview for AQP-FVT|C_Issue. IGNIS GAS|ISSUE-FVT + STOA 'smart'."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a Farm / Vault / Treasury." "Executes via TS02-C3.AQP-FVT|C_Issue."]
                [(format "FVT '{}' created (class {}) for {}." [fvt-name fvt-class owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_Issue owner-konto [])))
                (ref-I|OURONET::OI|UDC_DynamicStoaCost patron (AQP-FVT.URCi_IssueStoa))
                [])
        )
    )
    (defun INFO_AQP-FVT|RotateOwnership:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string new-owner-konto:string)
        @doc "Cost preview for AQP-FVT|C_RotateOwnership. IGNIS 'ignis|medium'; no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer an FVT's owner-konto." "Executes via TS02-C3.AQP-FVT|C_RotateOwnership."]
                [(format "FVT {} ownership moved to {}." [fvt-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_RotateOwnership fvt-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|Control:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for AQP-FVT|C_Control. IGNIS 'ignis|medium'; no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set an FVT's can-upgrade / can-change-owner flags." "Executes via TS02-C3.AQP-FVT|C_Control."]
                [(format "FVT {} control flags updated." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_Control fvt-id)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetCommonDenominator:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string common-denominator:string)
        @doc "Cost preview for AQP-FVT|C_SetCommonDenominator. IGNIS GAS|SET-COMMON-DENOMINATOR; no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a farm's common-denominator (before any links)." "Executes via TS02-C3.AQP-FVT|C_SetCommonDenominator."]
                [(format "FVT {} common-denominator set to {}." [fvt-id common-denominator])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_SetCommonDenominator fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetMosaic:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string mosaic:bool)
        @doc "Cost preview for AQP-FVT|C_SetMosaic. IGNIS GAS|SET-MOSAIC; no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Toggle a farm's mosaic membership policy." "Executes via TS02-C3.AQP-FVT|C_SetMosaic."]
                [(format "FVT {} mosaic set to {}." [fvt-id mosaic])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_SetMosaic fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetSplitMode:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string split-mode:string)
        @doc "Cost preview for AQP-FVT|C_SetSplitMode. IGNIS GAS|SET-SPLIT-MODE; no STOA. Reports the farm's current \
            \ reward-split mode alongside the requested one."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a farm's reward-split mode (SPLIT|STAKED participation | SPLIT|TVL pool-size)." "Executes via TS02-C3.AQP-FVT|C_SetSplitMode."]
                [(format "Farm {} reward-split mode: {} -> {}." [fvt-id (RPS.UR_FVT|SplitMode fvt-id) split-mode])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_SetSplitMode fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetMinInjectAmount:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string min-inject-amount:decimal)
        @doc "Cost preview for AQP-FVT|C_SetMinInjectAmount. Reports the lane's current floor \
            \ alongside the requested one. \
            \ \
            \ ADDED 2026-10-25, and it is a GAP BEING CLOSED rather than a new feature: the \
            \ entrypoint shipped in the 2026-10-23 round with no preview at all, which is why the \
            \ registry carried 440 entrypoints against 439 previews. \
            \ \
            \ QUOTES URCi_ToggleRewardLink BECAUSE THE CLIENT DOES. C_SetMinInjectAmount builds \
            \ its cumulator from that same reader (it is a one-field write on the same lane row, \
            \ priced as AQP-FVT|C_ToggleRewardLink), so quoting anything else here would preview a \
            \ number the execution does not charge -- which is the one thing a preview must never \
            \ do."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set the per-injection floor on one reward lane (future injections only)." "Executes via TS02-C3.AQP-FVT|C_SetMinInjectAmount."]
                [(format "Lane {} on FVT {} minimum inject: {} -> {}."
                    [reward-dptf-id fvt-id (RPS.UR_FVT-RG|MinInjectAmount fvt-id reward-dptf-id) min-inject-amount])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_ToggleRewardLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|LatchStreamEligible:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string)
        @doc "Cost preview for AQP-FVT|CC_LatchStreamEligible -- the one-way streaming latch. HEAVY: \
            \ latching scans every enabled member and requires each to be drift-locked, so the \
            \ quoted cost carries that scan. Irreversible, and it permanently narrows what the FVT \
            \ may admit afterwards."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Permanently latch an FVT as eligible for time-streamed injects (irreversible)." "Executes via TS02-C3.AQP-FVT|CC_LatchStreamEligible."]
                [(format "FVT {} stream-eligible: {} -> true. Afterwards it admits only drift-locked members."
                    [fvt-id (AQP-FVT.UR_FVT|StreamEligible fvt-id)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_LatchStreamEligible fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|AddScoreEntity:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Cost preview for AQP-FVT|C_AddScoreEntity. IGNIS GAS|ADD-SCORE-ENTITY; no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Register a score (type 1) or triplet (type 3) on an FVT." "Executes via TS02-C3.AQP-FVT|C_AddScoreEntity."]
                [(format "Score-entity {} (type {}) registered on FVT {}." [score-entity-id score-entity-type fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_AddScoreEntity fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|ToggleScoreEntityLink:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Cost preview for AQP-FVT|C_ToggleScoreEntityLink. IGNIS GAS|TOGGLE-SCORE-ENTITY-LINK; no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable/disable a ScoreEntityLink on an FVT." "Executes via TS02-C3.AQP-FVT|C_ToggleScoreEntityLink."]
                [(format "FVT {} score-entity {} enabled={}." [fvt-id score-entity-id enabled])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_ToggleScoreEntityLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|IssueMultipletFamily:object{OuronetInfoV3.ClientInfo}
        (patron:string token-0-id:string token-1-id:string token-2-id:string ats-0-1-id:string ats-1-2-id:string)
        @doc "Cost preview for AQP-FVT|C_IssueMultipletFamily. IGNIS GAS|ISSUE-MULTIPLET-FAMILY; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a chain-wide MultipletFamily reward ladder." "Executes via TS02-C3.AQP-FVT|C_IssueMultipletFamily."]
                [(format "MultipletFamily issued: {} -> {} -> {}." [token-0-id token-1-id token-2-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_IssueMultipletFamily patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|IssueGenericEarningVault:object{OuronetInfoV3.ClientInfo}
        (patron:string owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-FVT|C_IssueGenericEarningVault -- the whole six-operation vault \
            \ as ONE charge. IGNIS only; no STOA."
        ;;The cost comes from TS02-C3.URCi_IssueGenericEarningVault, which concatenates the SAME six
        ;;component readers the operation's own cumulators come from. Preview and charge therefore
        ;;agree by construction rather than by a number kept in step by hand.
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-FVT|AddRewardLink:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Cost preview for AQP-FVT|C_AddRewardLink. IGNIS GAS|ADD-REWARD-LINK; no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Register a reward DPTF on an FVT." "Executes via TS02-C3.AQP-FVT|C_AddRewardLink."]
                [(format "Reward {} linked on FVT {} (family {})." [reward-dptf-id fvt-id multiplet-family-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_AddRewardLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|ToggleRewardLink:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Cost preview for AQP-FVT|C_ToggleRewardLink. IGNIS GAS|TOGGLE-REWARD-LINK; no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Toggle a reward link's enabled flag." "Executes via TS02-C3.AQP-FVT|C_ToggleRewardLink."]
                [(format "FVT {} reward {} enabled={}." [fvt-id reward-dptf-id enabled])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_ToggleRewardLink fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SetQualitySplit:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Cost preview for AQP-FVT|C_SetQualitySplit. IGNIS GAS|SET-QUALITY-SPLIT; no STOA."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a MULTIPLET_BASE reward's quality-split mode + matrix." "Executes via TS02-C3.AQP-FVT|C_SetQualitySplit."]
                [(format "FVT {} reward {} quality-split mode={}." [fvt-id reward-dptf-id mode])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-RPSC::URCi_SetQualitySplit fvt-id [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|InjectStream:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Cost preview for AQP-FVT|CC_InjectStream. IGNIS GAS|INJECT; STOA none (custody transfer)."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Inject reward tokens as a linear time-stream over the given duration."
                 "Executes via TS02-C3.AQP-FVT|CC_InjectStream."]
                [(format "Streaming {} of {} into FVT {} over {}s." [amount reward-dptf-id fvt-id duration])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14) — same defect as INFO_AQP-FVT|Inject, same cause.
                    ;;This quoted only RPS.URCi_Inject (the gas leg) while the exec also collects the
                    ;;custody transfer of the reward principal: XIv_FvtAddStream PHASE 1 runs
                    ;;`(ref-TFT::C_Transfer patron patron AQP|SC_NAME reward-dptf-id amount true)` ahead of the
                    ;;gas leg, and that transfer carries its own cumulator. All FOUR members of the
                    ;;inject family shared this. Measured and pinned for CC_Inject at
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`; the other
                    ;;three route through the identical core, so the same reader fixes them.
                    (ref-RPSC::URCi_InjectFull "AQP-FVT|CC_InjectStream" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-FVT|Inject:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-FVT|CC_Inject (enforced-fresh single-tx inject). IGNIS GAS|INJECT; STOA none."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
                    (ref-RPSC::URCi_InjectFull "AQP-FVT|CC_Inject" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-FVT|InjectFinalize:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for AQP-FVT|CC_InjectFinalize. IGNIS GAS|INJECT; STOA none."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Finalize a paginated fresh inject (zero-stale gate, then inject)."
                 "Executes via TS02-C3.AQP-FVT|CC_InjectFinalize."]
                [(format "Finalized fresh inject of {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14) — same defect as INFO_AQP-FVT|Inject, same cause.
                    ;;This quoted only RPS.URCi_Inject (the gas leg) while the exec also collects the
                    ;;custody transfer of the reward principal: XI_FvtInjectCore PHASE 1, via XE_XI_FvtInjectCore runs
                    ;;`(ref-TFT::C_Transfer patron patron AQP|SC_NAME reward-dptf-id amount true)` ahead of the
                    ;;gas leg, and that transfer carries its own cumulator. All FOUR members of the
                    ;;inject family shared this. Measured and pinned for CC_Inject at
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`; the other
                    ;;three route through the identical core, so the same reader fixes them.
                    (ref-RPSC::URCi_InjectFull "AQP-FVT|CC_InjectFinalize" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-FVT|InjectFixChunk:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_InjectFixChunk. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-FVT|UnstaleAll:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_UnstaleAll. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-FVT|UnstaleMyScores:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-ids:[string])
        @doc "Cost preview for AQP-FVT|CC_UnstaleMyScores. IGNIS GAS|UNSTALE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Self-service deb-unstale of your own scores across FVTs." "Executes via TS02-C3.AQP-FVT|CC_UnstaleMyScores."]
                [(format "Unstaled your scores across {} FVTs." [(length fvt-ids)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_UnstaleMyScores patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|Collect:object{OuronetInfoV3.ClientInfo}
        (patron:string collector:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-FVT|CC_Collect. FULL IGNIS: reward-payout leg (plain TFT transfer, or a \
            \ MULTIPLET_BASE triplet ladder) + Phase-7 forced-fix penalty + GAS|COLLECT; STOA none. \
            \ Reconstructed on the current claimable state (exact for un-streamed / settled lanes). \
            \ \
            \ <collector> ADDED 2026-10-29, and it is the parameter this preview was missing. Every figure \
            \ here is a property of the account being PAID -- its claimable, its triplet lane split read \
            \ from its own deb scores, its fee-exemption deciding the transfer class, its forced-fix count \
            \ -- while <patron> only supplies the IGNIS discount. Quoting one account for both was correct \
            \ for a self-collect and wrong for a sponsored one. It mirrors the execution's <executor>, \
            \ which is what AQP-FVT|CC_Collect credits."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Collect your claimable reward from this FVT membership."
                 "Full IGNIS shown: payout transfer/ladder + any forced-fix penalty + gas (reconstructed byte-for-byte)."
                 "Executes via TS02-C3.AQP-FVT|CC_Collect."]
                [(format "Collected reward token {} from score-entity {}." [reward-dptf-id score-entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-RPSC::URCi_CollectFull patron collector fvt-id score-entity-type score-entity-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|SweepRevokeAnchor:object{OuronetInfoV3.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-FVT|CC_SweepRevokeAnchor. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-FVT|SweepBegin:object{OuronetInfoV3.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-FVT|CC_SweepBegin. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-FVT|SweepRecomputeChunk:object{OuronetInfoV3.ClientInfo}
        (patron:string anchor-id:string chunk:integer)
        @doc "Cost preview for AQP-FVT|CCp_SweepRecomputeChunk. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-FVT|ClearPoolSweep:object{OuronetInfoV3.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-FVT|CC_ClearPoolSweep. Flat 'backfill' component — priced as \
            \ sweep maintenance rather than a settings change, because it is the last step of a \
            \ job ANYBODY may finish. No STOA. \
            \ \
            \ IT LIVES IN AQP-FVT, not AQP-POOL, and the preview sits here for the same reason: \
            \ the pool's sweep flag has two owners (the add-score re-rate and the FVT anchor \
            \ sweep) and AQP-FVT is the only module that can see both, so it is the only one that \
            \ can refuse to lift a freeze whose other owner is still running."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Release a pool's sweep freeze once the outstanding work list is empty."
                 "Permissionless — anyone may finish the job; refused while either owner still has work."
                 "Executes via TS02-C3.AQP-FVT|CC_ClearPoolSweep."]
                [(format "Sweep freeze lifted on pool {}." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-FVT.URCi_ClearPoolSweep [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-FVT|FvtFixSlice:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string accounts:[string])
        @doc "Cost preview for AQP-FVT|CCp_FvtFixSlice. Gas-station subsidised — no IGNIS/STOA to \
            \ the patron, exactly like the sequential fixer it parallelises. \
            \ \
            \ THE FED-SLICE FORM IS WHY IT EXISTS: the cursor pager takes a `chunk` and computes \
            \ its own window, so two concurrent sends pick the SAME members and charge the \
            \ forced-fix penalty twice. This one takes the accounts explicitly and re-checks \
            \ staleness in-transaction, so an overlapping or replayed slice skips rather than \
            \ re-penalising."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Fix one explicit slice of deb-stale FVT members (parallel-safe)."
                 "Gas-station subsidised — costs you nothing."
                 "Executes via TS02-C3.AQP-FVT|CCp_FvtFixSlice."]
                [(format "Fixed up to {} stale member(s) on FVT {}." [(length accounts) fvt-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [(length accounts)])
        )
    )
    ;;
    ;;[AQP-DSA] Delegated Staking Agencies
    (defun INFO_AQP-DSA|DefineDelegationVault:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string model-id:string unit-score:integer)
        @doc "Cost preview for AQP-DSA|C_DefineDelegationVault. IGNIS GAS|DEFINE-VAULT; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bind a class-0 FVT as a DSA delegation vault." "Executes via TS02-C3.AQP-DSA|C_DefineDelegationVault."]
                [(format "FVT {} bound as delegation vault (model {})." [fvt-id model-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_DefineDelegationVault patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|OpenAgency:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string pool-id:string score-entity-id:string fee-per-mille:integer collectable-id:string stake-nonces:[integer])
        @doc "Cost preview for AQP-DSA|CC_OpenAgency. IGNIS GAS|OPEN-AGENCY base; the atomic open also stakes the \
            \ operator's collateral (staking legs added at execution). No STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-DSA|RecomputeCapture:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string)
        @doc "Cost preview for AQP-DSA|C_RecomputeCapture. IGNIS GAS|RECOMPUTE-CAPTURE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Recompute an agency's capture (permissionless; preserves oracle-ts)." "Executes via TS02-C3.AQP-DSA|C_RecomputeCapture."]
                [(format "Agency {} capture recomputed on vault {}." [score-entity-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_RecomputeCapture patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|SetOracleAuth:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string oracle-guard:guard)
        @doc "Cost preview for AQP-DSA|C_SetOracleAuth. IGNIS GAS|SET-ORACLE-AUTH; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Authorize the delegated oracle key + arm the capture expiry." "Executes via TS02-C3.AQP-DSA|C_SetOracleAuth."]
                [(format "Oracle authority set on vault {}." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_SetOracleAuth patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|OracleWrite:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "Cost preview for AQP-DSA|C_OracleWrite. IGNIS GAS|ORACLE-WRITE; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Oracle writes an agency's daily {nodes, uptime} + recomputes its capture." "Executes via TS02-C3.AQP-DSA|C_OracleWrite."]
                [(format "Oracle wrote nodes {} / uptime {} for agency {}." [nodes uptime score-entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (AQP-DSA.URCi_OracleWrite patron [])))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-DSA|ToggleExternalOracle:object{OuronetInfoV3.ClientInfo}
        (on:bool)
        @doc "Cost preview for AQP-DSA|A_ToggleExternalOracle. Chain-wide GOV switch — no IGNIS/STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-DSA|SetOracleValidity:object{OuronetInfoV3.ClientInfo}
        (seconds:integer)
        @doc "Cost preview for AQP-DSA|A_SetOracleValidity. Chain-wide GOV switch — no IGNIS/STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-DSA|WithdrawRoyalty:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-DSA|C_WithdrawRoyalty. FULL IGNIS: GAS|WITHDRAW-ROYALTY gas leg + the state- \
            \ dependent custody-move leg (normalize + TFT transfer of the live royalty pool to the FVT owner); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-DSA|BurnRoyalty:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-DSA|C_BurnRoyalty. FULL IGNIS: GAS|BURN-ROYALTY gas leg + the state-dependent \
            \ custody-burn leg (normalize + DPTF burn of the live royalty pool); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-DSA|FuelRoyalty:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Cost preview for AQP-DSA|C_FuelRoyalty. FULL IGNIS: GAS|FUEL-ROYALTY gas leg + the state-dependent \
            \ custody-fuel leg (normalize + SWPLC fuel of the live royalty pool into the swpair); STOA none."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-DSA|SetAgencyFee:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Cost preview for AQP-DSA|C_SetAgencyFee. IGNIS GAS|SET-AGENCY-FEE; no STOA. O(1) reprice."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun INFO_AQP-MTX|2Inject:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Cost preview for MTX-AQP|2|CC_Inject (2-step enforced-fresh inject). IGNIS GAS|INJECT (inner XB_FvtInject); STOA none."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: 2-step enforced-fresh inject (spike fallback for CC_Inject on vault/treasury)."
                 "Executes via TS02-C3.MTX-AQP|2|CC_Inject."]
                [(format "2-step fresh-injected {} of {} into FVT {}." [amount reward-dptf-id fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    ;;MISSING LEG FIXED (2026-09-14) — same defect as INFO_AQP-FVT|Inject, same cause.
                    ;;This quoted only RPS.URCi_Inject (the gas leg) while the exec also collects the
                    ;;custody transfer of the reward principal: XI_FvtInjectCore PHASE 1, via XB_FvtInject runs
                    ;;`(ref-TFT::C_Transfer patron patron AQP|SC_NAME reward-dptf-id amount true)` ahead of the
                    ;;gas leg, and that transfer carries its own cumulator. All FOUR members of the
                    ;;inject family shared this. Measured and pinned for CC_Inject at
                    ;;`Stage_02/[6.5.1]_AQP-INFO-GROUNDTRUTH.repl <<TX-INFO-GT-INJECT>>`; the other
                    ;;three route through the identical core, so the same reader fixes them.
                    (ref-RPSC::URCi_InjectFull "MTX-AQP|2|CC_Inject" patron fvt-id reward-dptf-id amount))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [amount])
        )
    )
    (defun INFO_AQP-MTX|2SweepRevokeAnchor:object{OuronetInfoV3.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for MTX-AQP|2|CC_SweepRevokeAnchor. Gas-station subsidised — no IGNIS/STOA to the patron."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    ;;
    ;;  [AQP-EVCT — Reward Eviction, 2026-10-29]
    ;;
    ;;FOUR WRAPPERS, FOUR PREVIEWS, and two of them quote ZERO on purpose. The gasless admin pair
    ;;charges the patron nothing because the core's patron slot carries the Ouronet system account,
    ;;which IGNIS::XE_CollectIgnis exempts -- so a preview that reported the C-variant's figure for
    ;;them would be wrong in the direction that matters, telling the daily automaton it cannot
    ;;afford the run it is about to make for free. The IGNIS still has a shape; it just is not
    ;;billed, which is what the FREE note in each says.
    (defun INFO_AQP-EVCT|EvictMultiRewards:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string beneficiaries:[string]
         score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
        @doc "Cost preview for AQP-EVCT|CCp_EvictMultiRewards -- one eviction slice. FULL IGNIS: the sum of \
            \ each leg's collect cost, read PER BENEFICIARY rather than per patron; no STOA. Fed the \
            \ same four parallel arrays the exec is fed, from the same \
            \ AQP-EVCT::URHC_BuildEvictSlicePlan dirty read. \
            \ \
            \ RESIDUAL inherited from the collect preview, stated rather than hidden: exact for \
            \ un-streamed or already-settled lanes, and able to shift a transfer tier on a lane with a \
            \ live stream, because the payout is read pre-drip."
        (let
            (
                (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Evict one slice of this FVT's outstanding rewards to their beneficiaries."
                 "You are paying the IGNIS for collects the beneficiaries would otherwise pay themselves."
                 "Executes via TS02-C3.AQP-EVCT|CCp_EvictMultiRewards."]
                [(format "Evicted {} reward leg(s) on FVT {}." [(length beneficiaries) fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-EVCT::URCi_EvictMultiRewards patron fvt-id beneficiaries
                        score-entity-types score-entity-ids reward-dptf-ids))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-EVCT|EvictSingleReward:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string beneficiary:string score-entity-type:integer
         score-entity-id:string reward-dptf-id:string)
        @doc "Cost preview for AQP-EVCT|CC_EvictSingleReward — ONE leg, one transaction. FULL IGNIS \
            \ for that leg, read per BENEFICIARY rather than per patron; no STOA. \
            \ \
            \ THE ONE A FAN-OUT MULTIPLIES. A client sending 120 of these shows 120 x this figure, \
            \ and that total equals INFO_AQP-EVCT|EvictMultiRewards' quote for the same 120 legs — \
            \ both resolve to AQP-RPSC::URCi_CollectFull per leg with no cross-leg term, so the \
            \ choice between the two paths is not a choice between two prices. \
            \ \
            \ RESIDUAL inherited from the collect preview: exact for un-streamed or already-settled \
            \ lanes, and able to shift a transfer tier on a lane with a live stream, because the \
            \ payout is read pre-drip."
        (let
            (
                (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Evict ONE reward leg to its beneficiary."
                 "One leg per transaction — the transaction count is the leg count, and no single one can exceed the gas limit."
                 "Executes via TS02-C3.AQP-EVCT|CC_EvictSingleReward."]
                [(format "Evicted {} on FVT {} to {}." [reward-dptf-id fvt-id beneficiary])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-EVCT::URCi_EvictSingleReward patron fvt-id beneficiary
                        score-entity-type score-entity-id reward-dptf-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-EVCT|AdminEvictSingleReward:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string beneficiary:string reward-dptf-id:string)
        @doc "Cost preview for AQP-EVCT|AA_EvictSingleReward — the GASLESS single-leg eviction. FREE: \
            \ the core's patron slot carries the Ouronet system account, the one account \
            \ IGNIS::XE_CollectIgnis exempts, so no IGNIS and no STOA reach <patron>. \
            \ \
            \ THE AUTOMATON'S PREVIEW, and the figure it shows for a 120-leg campaign is zero rather \
            \ than 120 x something. <patron> stays in the signature and is deliberately unused: every \
            \ INFO_ here takes it first, and the score-entity is omitted because it cannot change a \
            \ figure that is zero."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Evict ONE reward leg as the Ouronet administrator."
                 "Gasless admin path — costs you nothing. Requires the admin keyset AND FVT ownership."
                 "Executes via TS02-C3.AQP-EVCT|AA_EvictSingleReward."]
                [(format "Evicted {} on FVT {} to {} (gasless)." [reward-dptf-id fvt-id beneficiary])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-EVCT|FullEvictRewards:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string)
        @doc "Cost preview for AQP-EVCT|CC_FullEvictRewards -- the whole-FVT, single-transaction variant. \
            \ HEAVY: it runs the same leg scan the exec runs, then prices every leg. `/local` only. \
            \ \
            \ Unlike INFO_AQP-POOL|FullVacate, which is HANDED its lane plan, this one scans. The \
            \ asymmetry follows the cores: AQP-VCT::URCi_FullVacate takes lanes, AQP-EVCT's takes an \
            \ fvt-id, because a vacate's lanes come from several asset classes while an eviction's legs \
            \ come from one reader."
        (let
            (
                (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Evict EVERY outstanding reward on this FVT in one transaction."
                 "Small FVTs only — the node gas meter is the real ceiling, and this scans before it pays."
                 "Executes via TS02-C3.AQP-EVCT|CC_FullEvictRewards."]
                [(format "Evicted every outstanding reward leg on FVT {}." [fvt-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-EVCT::URCi_FullEvictRewards patron fvt-id))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-EVCT|AdminEvictMultiRewards:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string beneficiaries:[string])
        @doc "Cost preview for AQP-EVCT|AAp_EvictMultiRewards -- the GASLESS admin eviction slice. FREE: the \
            \ core's patron slot carries the Ouronet system account, the one account \
            \ IGNIS::XE_CollectIgnis exempts, so no IGNIS and no STOA reach <patron>. \
            \ \
            \ <patron> is still in the signature, and is deliberately unused: every INFO_ reader in \
            \ this module takes it first, and a preview that dropped it would need its own call shape \
            \ in every client. <beneficiaries> is taken for the result line only -- the other three \
            \ arrays cannot change a figure that is zero."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Evict one slice of this FVT's rewards as the Ouronet administrator."
                 "Gasless admin path — costs you nothing. Requires the admin keyset AND FVT ownership."
                 "Executes via TS02-C3.AQP-EVCT|AAp_EvictMultiRewards."]
                [(format "Evicted {} reward leg(s) on FVT {} (gasless)." [(length beneficiaries) fvt-id])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                [])
        )
    )
    (defun INFO_AQP-EVCT|AdminFullEvictRewards:object{OuronetInfoV3.ClientInfo}
        (patron:string fvt-id:string)
        @doc "Cost preview for AQP-EVCT|AA_FullEvictRewards -- the GASLESS admin whole-FVT eviction. \
            \ FREE, for the reason INFO_AQP-EVCT|AdminEvictMultiRewards gives."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Evict EVERY outstanding reward on this FVT as the Ouronet administrator."
                 "Gasless admin path — costs you nothing. Requires the admin keyset AND FVT ownership."
                 "Executes via TS02-C3.AQP-EVCT|AA_FullEvictRewards."]
                [(format "Evicted every outstanding reward leg on FVT {} (gasless)." [fvt-id])]
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

;; ===== 1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact ==============
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact
;;
;; SOVEREIGN launchpad Talos. Holds ONLY the sovereign DEMIPAD orchestration
;; (asset registration/config + deposit/fuel/retrieve/withdraw). The per-sale
;; CITIZEN user wrappers (SPARK|/SNAKES|/CUSTODIANS|/KPAY|/STOAICO|) live in the
;; citizen Talos 2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact, deployed AFTER the
;; citizen sales. Deploy order: DEMIPAD core -> TS02-C1/C2/C3 -> THIS (sovereign)
;; -> citizen sales -> TS02-CPAD (citizen Talos).
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; TalosStageTwo_DemiPadV4: already deployed and unchanged -- see LIVE_INTERFACES

;;
(module TS02-DPAD GOV
    @doc "TALOS Stage 2 Demiourgos Launchpad SOVEREIGN Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_DemiPadV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS02-DPAD                          (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS02-DPAD_ADMIN)))
    (defcap GOV|TS02-DPAD_ADMIN ()                      (enforce-guard GOV|MD_TS02-DPAD))
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
            (enforce (not gap) "While Global Administrative Pause is online, no executor Functions can be executed")
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
        (with-capability (GOV|TS02-DPAD_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS02-DPAD_ADMIN)
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
        (with-capability (GOV|TS02-DPAD_ADMIN)
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
        (with-capability (GOV|TS02-DPAD_ADMIN)
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
        @doc "Registers THIS sovereign launchpad Talos' summoner guard as a trusted IMP peer of the \
            \ sovereign modules it drives (DEMIPAD core + DPDC for direct XB_DeployAccount). The \
            \ per-sale CITIZEN modules are registered by the citizen Talos (TS02-CPAD)."
        (let
            (
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|TS01-A::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
            ;;DPDC Audit #35M: TS02-DPAD calls DPDC::XBv_DeployAccountSFT/NFT directly (the removed
            ;;DPSF|C_DeployAccount/DPNF|C_DeployAccount Talos wrappers previously carried TS02-C1/C2's
            ;;own registered guard through the call chain instead) -- register this module's own guard
            ;;as a trusted DPDC peer so P|UEV_IMC recognizes the direct call.
            (ref-P|DPDC::P|A_AddIMP mg)
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
    (defun A_RegisterAssetToLaunchpad (patron:string executor:string asset-id:string fungibility:[bool])
        @doc "Registers an Asset to Launchpad; \
            \ An Asset can be a DPTF, DPMF, DPSF or DPNF \
            \   Asset-type can be designated via the double-boolean <fungibility> \
            \   \
            \   DPFT >> [true true] \
            \   DPMF >> [true false] \
            \   DPSF >> [false true] \
            \   DPNF >> [false false]"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                    (tf:[bool] [true true])
                    (of:[bool] [true false])
                    (sf:[bool] [false true])
                    (nf:[bool] [false false])
                    (f:bool false)
                )
                (ref-DEMIPAD::A_RegisterAssetToLaunchpad patron executor asset-id fungibility)
                ;;Reconciles two audits' DeployAccount hardening (dptf-dpof #N2 + DPDC #35M):
                ;; #N2: lpad is DEMIPAD's own system smart account (not patron's) — tf/of use the ADMIN
                ;;   variant (TS01-A, no ownership check on <account>); the self-service C_ variant now
                ;;   requires the caller to own <account>, which they don't for lpad.
                ;; #35M: the public DPSF|C_DeployAccount/DPNF|C_DeployAccount Talos wrappers were REMOVED
                ;;   (any signer could force any account onto any collection); sf/nf now call
                ;;   DPDC::XBv_DeployAccountSFT/NFT directly, module-to-module — the pattern every
                ;;   legitimate internal caller (DPDC-C/DPDC-F/DPDC-R/DPDC-S) already uses.
                ;;PROVISIONAL EXECUTOR SLOTS (HANDOFF 4e, 2026-09-22). 01_TS01-A's turn gave the
                ;;two admin DeployAccount wrappers an <executor>, proven by
                ;;CAP_EnforceAccountOwnership, and an <executee> -- the account deployed FOR,
                ;;which is <lpad> here. This module's own turn has not come, so there is no
                ;;<executor> parameter to thread and the rule is to pass the account that
                ;;actually initiates. That is <patron>: the @doc above records that running this
                ;;requires TS01-A's admin keyset, so the caller IS the admin and the admin is
                ;;paying. Correct today, and it must become this module's own <executor> at its
                ;;turn -- `executor = patron` is a considered choice here, never a default.
                (cond
                    ((= fungibility tf) (ref-TS01-A::DPTF|A_DeployAccount patron patron lpad asset-id))
                    ((= fungibility of) (ref-TS01-A::DPOF|A_DeployAccount patron patron lpad asset-id))
                    ((= fungibility sf) (ref-DPDC::XBv_DeployAccountSFT lpad asset-id f f f f f f f f f f f))
                    ((= fungibility nf) (ref-DPDC::XBv_DeployAccountNFT lpad asset-id f f f f f f f f f f))
                    true
                )
            )
        )
    )
    (defun A_ToggleOpenForBusiness (executor:string asset-id:string toggle:bool)
        @doc "Toggle Open For Bussines. Must be on to acquire Assets"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                )
                ;;GASLESS admin path: this Talos A_ wrapper takes no patron, so the core's patron
                ;;slot carries the Ouronet system account, read from the same source
                ;;TS01-A's GASLESS-PATRON constant resolves to. The EXECUTOR is threaded: the
                ;;admin keyset says the call MAY happen, the executor says who made it happen.
                (ref-DEMIPAD::A_ToggleOpenForBusiness (ref-DALOS-G::GOV|DALOS|SC_NAME) executor asset-id toggle)
            )
        )
    )
    (defun A_DefinePrice (executor:string asset-id:string price:object)
        @doc "Updates Price Object for an Asset"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                )
                ;;GASLESS admin path: this Talos A_ wrapper takes no patron, so the core's patron
                ;;slot carries the Ouronet system account, read from the same source
                ;;TS01-A's GASLESS-PATRON constant resolves to. The EXECUTOR is threaded: the
                ;;admin keyset says the call MAY happen, the executor says who made it happen.
                (ref-DEMIPAD::A_DefinePrice (ref-DALOS-G::GOV|DALOS|SC_NAME) executor asset-id price)
            )
        )
    )
    (defun A_ToggleRetrieval (executor:string asset-id:string toggle:bool)
        @doc "Retrieval ON allows Asset Owners to retrieve their Asssets that still exist on the Launchpad"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                )
                ;;GASLESS admin path: this Talos A_ wrapper takes no patron, so the core's patron
                ;;slot carries the Ouronet system account, read from the same source
                ;;TS01-A's GASLESS-PATRON constant resolves to. The EXECUTOR is threaded: the
                ;;admin keyset says the call MAY happen, the executor says who made it happen.
                (ref-DEMIPAD::A_ToggleRetrieval (ref-DALOS-G::GOV|DALOS|SC_NAME) executor asset-id toggle)
            )
        )
    )
    (defun DEMIPAD|C_Deposit (patron:string executor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
        @doc "Sovereign launchpad DEPOSIT Talos op — the citizen sales call this to move a buyer's \
            \ STOA/OURS working-token into the Launchpad against <asset-id>. <type> 0 = Native STOA \
            \ (wrapped), 1 = OWS; <max-cost> is the buyer's dollar slippage ceiling (sentinel < 0 = \
            \ slippage off). IGNIS billed on patron here; the sale composes it Sigma-wise with its \
            \ asset-transfer Talos op."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (sd:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_Deposit patron executor asset-id amount-in-dollars type direct-injection max-cost)
                )
                (format "Succesfuly deposited {} $ worth against {} into Demipad from {}." [amount-in-dollars asset-id sd])
            )
        )
    )
    ;;
    (defun DEMIPAD|C_Withdraw (patron:string executor:string asset-id:string type:integer destination:string)
        @doc "Withdraws all cumulated Tokens in the Launchpad, gathered through sale \
            \ Type 1 = WSTOA \
            \ Type 2 = SSTOA \
            \ Type 3 = OURO "
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (retrieval-amount:decimal (ref-DEMIPAD::URv_Funds asset-id type))
                    (working-id:string
                        (if (= type 1)
                            (ref-DALOS::UR_WrappedStoaID)
                            (if (= type 2)
                                (ref-DALOS::UR_SilverStoaID)
                                (ref-DALOS::UR_OuroborosID)
                            )
                        )
                    )
                    (sd:string (ref-I|OURONET::OI|UC_ShortAccount destination))
                )
                (ref-DEMIPAD::C_Withdraw patron executor asset-id type destination)
                (format "Succesfuly withdrawn {} {} from Demipad to {}." [retrieval-amount working-id sd])
            )
        )
    )
    ;;
    (defun DEMIPAD|C_FuelTrueFungible (patron:string executor:string asset-id:string amount:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DEMIPAD::C_TransmitTrueFungible patron executor asset-id amount true)
                (format "Succesfuly fueled {} {} to Demiourgos Launchpad from Account {}" [amount asset-id sa-s])
            )
        )
    )
    (defun DEMIPAD|C_FuelOrtoFungible (patron:string executor:string asset-id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DEMIPAD::C_TransmitOrtoFungible patron executor asset-id nonces true)
                (format "Succesfuly fueled {} Nonces {} to Demiourgos Launchpad from Account {}" [asset-id nonces sa-s])
            )
        )
    )
    (defun DEMIPAD|C_FuelSemiFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitSemiFungibles patron executor asset-id nonces amounts true)
                )
                (format "Succesfuly fueled {} Nonces {} with Amounts {} to Demiourgos Launchpad from Account {}" [asset-id nonces amounts c])
            )
        )
    )
    (defun DEMIPAD|C_FuelNonFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitNonFungibles patron executor asset-id nonces amounts true)
                )
                (format "Succesfuly fueled {} Nonces {} with Amounts {} to Demiourgos Launchpad from Account {}" [asset-id nonces amounts c])
            )
        )
    )
    ;;
    (defun DEMIPAD|C_RetrieveTrueFungible (patron:string executor:string asset-id:string amount:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DEMIPAD::C_TransmitTrueFungible patron executor asset-id amount false)
                (format "Succesfuly retrieved {} {} from Demiourgos Launchpad to Account {}" [amount asset-id sa-s])
            )
        )
    )
    (defun DEMIPAD|C_RetrieveOrtoFungible (patron:string executor:string asset-id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DEMIPAD::C_TransmitOrtoFungible patron executor asset-id nonces false)
                (format "Succesfuly retrieved {} Nonces {} from Demiourgos Launchpad to Account {}" [asset-id nonces sa-s])
            )
        )
    )
    (defun DEMIPAD|C_RetrieveSemiFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitSemiFungibles patron executor asset-id nonces amounts false)
                )
                (format "Succesfuly retrieved {} Nonces {} with Amounts {} from Demiourgos Launchpad to Account {}" [asset-id nonces amounts c])
            )
        )
    )
    (defun DEMIPAD|C_RetrieveNonFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV3} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitNonFungibles patron executor asset-id nonces amounts false)
                )
                (format "Succesfuly retrieved {} Nonces {} with Amounts {} from Demiourgos Launchpad to Account {}" [asset-id nonces amounts c])
            )
        )
    )

)

;; --- tables for 05_TS02-DPAD.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact ============
(module STOAICO GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_STOAICO                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|STOAICO_ADMIN)))
    (defcap GOV|STOAICO_ADMIN ()                        (enforce-guard GOV|MD_STOAICO))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|LaunchpadKey ()                          (+ (CT_Namespace) ".dh_sc_mb-keyset"))
    ;;
    ;; [SC-Names]
    (defun GOV|DEMIPAD|SC_NAME ()                       (at 0 ["Σ.Îäć$ЬчýφVεÎÿůпΨÖůηüηŞйnюŽXΣşpЩß5ςĂκ£RäbE₳èËłŹŘYшÆgлoюýRαѺÑÏρζt∇ŹÏýжIŒațэVÞÛщŹЭδźvëȘĂтPЖÃÇЭiërđÈÝДÖšжzČđзUĚĂsкιnãñOÔIKпŞΛI₳zÄû$ρśθ6ΨЬпYпĞHöÝйÏюşí2ćщÞΔΔŻTж€₿ŞhTțŽ"]))
    ;;
    ;; [PBLs]
    (defun GOV|DEMIPAD|PBL ()                           (at 0 ["9F.gGCkuc2wMAnFAjuFphikftLdl6qFqBD4yfeMEe9u65yMqf4r340Jd6dphh1d7E1cE20btMwl4HJ2cBEMvp209GA1eD4syB96hu4nmpFbB7dKnJEMz4p8fGLcmhvrBCfDmM0axnGin8qedl5vDtwbgL3l1aK5BsmjkEEJartqCH8qG8ialtjxwCcIMf50t2lkeww6Dct5LlmmLG25FmfpcgnwMMnkJl4Gfn9gwoA6vm0jKebjhodeJLjxnh9L11ss8f26866dqv1tEphxFFqutGetH4Itj3rHkrcrGsnlqpf4gfJp94b0gBwIBe4vCj6ha8jm6kd3f8B6pEaJtkJ3fbs6rCcGibltz1BAMn0vvKME5ddFyGBnzssk1s2s0vFzwxs6vjC61Ma2l1xDxqdg1thAk2u01hDiGndLhzK73HAfgtk7bxscn0qKhymG6JAqnEFt282pyHAq5nIthK9bA8nH76x7FEpLz4eK9tLIBsyjb8M5DxaeEei6pEnLxFCAg7ulacgtjjpjMiAaqhpmM1jEHqjt4G85q4L33zrME7whgIkIpIgwnF2qKd4"]))

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
    (defcap P|STOAICO|CALLER ()
        true
    )
    (defcap P|PAD-STOAICO|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|STOAICO|CALLER))
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
        (with-capability (GOV|STOAICO_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|STOAICO_ADMIN)
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
        (with-capability (GOV|STOAICO_ADMIN)
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
        (with-capability (GOV|STOAICO_ADMIN)
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
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|STOAICO|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "STOAICO|RemoteGov"
                (create-capability-guard (P|PAD-STOAICO|REMOTE-GOV))
            )
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst STOAICO|INFO                              (CT_Info))
    (defconst STOA_PREC                                 12)
    ;;{3.2}  schemas
    ;;
    (defschema UserContributionSchema
        dollarz:decimal             ;;Adds dollars contributed
        urstoa-earned:integer       ;;Adds Urstoa earned (WURSTOA bought with 5$ Contributions)
        ;;
        ;;Distribution-Vault-Data
        ;;v-dollarz                 ;;Stores the amount of Dollarz Contributed by Account; same as <dollarz>
        last-rps:decimal            ;;Value of the Users last RPS
        pending-rewards:decimal     ;;Amount of pending rewards the user can claim (amount of WSTOA user can still claim)
        last-collected-round:integer ;;#1C: the distribution-round this account last collected. Collect allowed only when < the vault distribution-round (one collect per round; a new A_Inject opens the next round).
        ;;
        ;;Select Keyz
        owner-id:string             ;;Ouronet Account
    )
    (defschema GeneralContributionSchema
        dollarz:decimal             ;;Adds dollars contributed
        urstoa-left:integer         ;;Subtracts, storing UrStoa left
        users:integer               ;;Stores number of participants
        ;;
        ;;Distribution-Vault-Data
        ;;v-dollarz-supply          ;;Stores the total amount of Virtual Dollars in the Vault; same as <dollarz>; Functions as global score
        wstoa-supply:decimal        ;;Stores the total WSTOA held by the distribution Vault (10 mil wSTOA of ICO sale)
        nzs-count:integer           ;;Stores the number of users with non zero score.
        current-rps:decimal         ;;Stores current RPS decimal
        unclaimed-count:integer     ;;Stores the total number of user with unclaimed Rewards.
        distribution-round:integer  ;;#1C: monotonic distribution-round counter, ++ on every A_Inject. Gates collect eligibility (per-round idempotency) and the inject barrier (a new round opens only when unclaimed-count == 0).
        zombie-rewards:decimal      ;;#5M: escrow-on-empty (mirrors AQP). wSTOA injected while vault-score==0 (no stakers) is parked here (not divided) and flushed by the next non-zero-score inject (eff = amount + zombie).
        ;;
        ;;IDs
        wstoa:string
        wurstoa:string
        vusd:string
    )
    ;;{3.3}  tables
    (deftable STOAICO|T|User:{UserContributionSchema})          ;;Key = <Ouronet-Account>
    (deftable STOAICO|T|General:{GeneralContributionSchema})    ;;Key = <STOAICO|INFO>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap INIT-ICO-DISTRIBUTION ()
        @event
        (compose-capability (SECURE))
        (compose-capability (GOV))
    )
    (defcap GOV|MIGRATE-GENERAL-FIELDS ()
        @event
        ;;ADDED 2026-10-12, hotfix. `GeneralContributionSchema` gained `distribution-round` and
        ;;`zombie-rewards` (the #1C / #5M fixes) in a module upgrade that was never followed by a
        ;;row migration -- confirmed directly against the LIVE chain (UR_Global0 returns only the
        ;;original 10 fields; describe-module confirms the LIVE code already reads the new two),
        ;;so every path touching distribution-round (A_Stake, A_Unstake, A_Inject, collect, the
        ;;dust-sweep) aborts with "Key distribution-round not found in object" since that upgrade
        ;;landed. AUTHORISATION FIRST per the 2026-09-14 ruling, then the safety check: refuse a
        ;;SECOND call outright (rather than silently resetting real escrowed state back to 0)
        ;;instead of trying to make the migration itself idempotent.
        ;;TWO DEAD ENDS, BOTH VERIFIED LIVE 2026-10-12 BEFORE LANDING ON THE THIRD. `(try false
        ;;(UR_Global11))` does not work: the explicit-column `read` behind it throws an EvalError
        ;;("Key ... not found in object") that `try` cannot catch on this chain -- confirmed by
        ;;firing the exact expression at the real node and getting the SAME uncaught failure
        ;;back, and then confirming the SAME is true of bare `(at "k" obj)` on a plain in-memory
        ;;literal with no database involved at all, which rules out "it's a database thing."
        ;;`with-default-read` looked like the fix (it exists for exactly this) but is NOT: it
        ;;substitutes its default only when the ROW is entirely absent, not when the row EXISTS
        ;;and is merely missing the one requested COLUMN -- which is our actual shape, and it
        ;;throws the identical uncaught error for it, confirmed live. `(contains key obj)` is the
        ;;one that actually works: tested live against this exact row, both ways (false for the
        ;;missing field, true for one that exists), with no error either time.
        (compose-capability (SECURE))
        (compose-capability (GOV))
        (let
            (
                (already-migrated:bool (contains "distribution-round" (UR_Global0)))
            )
            (enforce (not already-migrated)
                "STOAICO: distribution-round already present -- migration already applied, refusing a second run")
        )
    )
    (defcap STOAICO|INJECT (account:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (STOAICO|ADMIN))
        )
    )
    (defcap STOAICO|ADD-CONTRIBUTION (account:string v-usd-amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (v-usd-id:string (UR_Global10))
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (ref-DPTF::UEV_Amount v-usd-id v-usd-amount)
            (compose-capability (STOAICO|ADMIN))
        )
    )
    (defcap STOAICO|REMOVE-CONTRIBUTION (account:string v-usd-amount:decimal)
        @event
        (compose-capability (STOAICO|ADMIN))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (v-usd-id:string (UR_Global10))
                (user-score:decimal (UR_User1 account))
            )
            (ref-DPTF::UEV_Amount v-usd-id v-usd-amount)
            (enforce 
                (<= v-usd-amount user-score) 
                (format "Removing {} from Account {} exceeds its existing balance" [v-usd-amount account])
            )
        )
    )
    (defcap STOAICO|REDEEM-CONTRIBUTION (account:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (iz-account:bool (UR_IzAccount account))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (enforce iz-account (format "Account {} cannot be redeemed" [account]))
            ;;#1C: per-round idempotency — an account may collect at most once per distribution-round.
            ;;     This is the guard that kills the drain (the unclaimed-count can no longer be walked
            ;;     down to the whole-supply dust-sweep by repeated zero-value re-collects).
            (enforce
                (< (UR_User5 account) (UR_Global11))
                (format "Account {} has already collected this distribution round" [account]))
            (compose-capability (SECURE))
            (compose-capability (P|PAD-STOAICO|REMOTE-GOV))
        )
    )
    (defcap STOAICO|ADMIN ()
        (compose-capability (GOV))
        (compose-capability (SECURE))
        (compose-capability (P|PAD-STOAICO|REMOTE-GOV))
    )
    (defcap STOAICO|FLUSH ()
        @doc "#1C admin flush authorization — push-collect uncollected stragglers on their behalf (delivered \
            \ to them). Composes STOAICO|ADMIN, so XI_CollectFor runs in the same SECURE + REMOTE-GOV context \
            \ as a self-collect, plus admin. Evented."
        @event
        (compose-capability (STOAICO|ADMIN))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;; [Keys]
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_Info ()                                   (at 0 ["StoaIcoInformation"]))
    ;;
    (defun UDC_UserData:object{UserContributionSchema}
        (a:decimal b:integer c:decimal d:decimal f:integer e:string)
        {"dollarz"              : a
        ,"urstoa-earned"        : b
        ,"last-rps"             : c
        ,"pending-rewards"      : d
        ,"last-collected-round" : f
        ,"owner-id"             : e}
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_User0:object{UserContributionSchema} (account:string)
        (let
            (
                (current-rps:decimal (UR_Global6))
            )
            (with-default-read STOAICO|T|User account
                (UDC_UserData 0.0 0 current-rps 0.0 0 account)
                {"dollarz":= d, "urstoa-earned" := ue, "last-rps" := lrps, "pending-rewards" := pr, "last-collected-round" := lcr, "owner-id" := id}
                (UDC_UserData d ue lrps pr lcr id)
            )
        )   
    )
    (defun UR_User1:decimal (account:string)
        (with-default-read STOAICO|T|User account
            {"dollarz" : 0.0}
            {"dollarz" := d}
            d
        )
    )
    (defun UR_User2:integer (account:string)
        (with-default-read STOAICO|T|User account
            {"urstoa-earned" : 0}
            {"urstoa-earned" := ue}
            ue
        )
    )
    (defun UR_User3:decimal (account:string)
        (let
            (
                (current-rps:decimal (UR_Global6))
            )
            (with-default-read STOAICO|T|User account
                {"last-rps" : current-rps}
                {"last-rps" := l-rps}
                l-rps
            )
        )
    )
    (defun UR_User4:decimal (account:string)
        (with-default-read STOAICO|T|User account
            {"pending-rewards" : 0.0}
            {"pending-rewards" := pr}
            pr
        )
    )
    (defun UR_User5:integer (account:string)
        @doc "#1C: the distribution-round this account last collected (0 default)."
        (with-default-read STOAICO|T|User account
            {"last-collected-round" : 0}
            {"last-collected-round" := lcr}
            lcr
        )
    )
    ;;
    (defun UR_Global0:object{GeneralContributionSchema} ()
        (read STOAICO|T|General STOAICO|INFO)
    )
    (defun UR_Global1:decimal ()
        (at "dollarz" (read STOAICO|T|General STOAICO|INFO ["dollarz"]))
    )
    (defun UR_Global2:integer ()
        (at "urstoa-left" (read STOAICO|T|General STOAICO|INFO ["urstoa-left"]))
    )
    (defun UR_Global3:integer ()
        (at "users" (read STOAICO|T|General STOAICO|INFO ["users"]))
    )
    (defun UR_Global4:decimal ()
        (at "wstoa-supply" (read STOAICO|T|General STOAICO|INFO ["wstoa-supply"]))
    )
    (defun UR_Global5:integer ()
        (at "nzs-count" (read STOAICO|T|General STOAICO|INFO ["nzs-count"]))
    )
    (defun UR_Global6:decimal ()
        (at "current-rps" (read STOAICO|T|General STOAICO|INFO ["current-rps"]))
    )
    (defun UR_Global7:integer ()
        (at "unclaimed-count" (read STOAICO|T|General STOAICO|INFO ["unclaimed-count"]))
    )
    (defun UR_Global8:string ()
        (at "wstoa" (read STOAICO|T|General STOAICO|INFO ["wstoa"]))
    )
    (defun UR_Global9:string ()
        (at "wurstoa" (read STOAICO|T|General STOAICO|INFO ["wurstoa"]))
    )
    (defun UR_Global10:string ()
        (at "vusd" (read STOAICO|T|General STOAICO|INFO ["vusd"]))
    )
    (defun UR_Global11:integer ()
        @doc "#1C: the vault distribution-round (monotonic, ++ on every A_Inject)."
        (at "distribution-round" (read STOAICO|T|General STOAICO|INFO ["distribution-round"]))
    )
    (defun UR_Global12:decimal ()
        @doc "#5M: escrowed zombie-rewards — wSTOA injected while the vault had no stakers, awaiting the next non-zero-score inject."
        (at "zombie-rewards" (read STOAICO|T|General STOAICO|INFO ["zombie-rewards"]))
    )
    ;;
    (defun UR_IzAccount:bool (account:string)
        @doc "Checks if an account exists"
        (let
            (
                (trial (try false (read STOAICO|T|User account)))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_IzDustSweepClaimant:bool (account:string)
        @doc "Is ACCOUNT the one remaining unclaimed claimant, and therefore the one the dust \
            \ sweep should pay the whole vault to? Three conditions, all O(1): exactly one \
            \ unclaimed position remains; this account is a real staker; and this account has \
            \ not already collected in the current distribution-round. \
            \ ADDED 2026-09-14. URC_ClaimableRewards used to test only the FIRST of the three, \
            \ so it answered a question about the VAULT and used it as an answer about the \
            \ ACCOUNT -- see the comment there."
        (fold (and) true
            [
                (= (UR_Global7) 1)
                (> (UR_User1 account) 0.0)
                (< (UR_User5 account) (UR_Global11))
            ]
        )
    )
    (defun URC_ClaimableRewards (account:string)
        @doc "Computes Claimable Reward of Account. When exactly one unclaimed position remains, \
            \ that claimant is paid the WHOLE remaining vault -- a dust sweep, so rounding \
            \ residue is never stranded."
        ;;DEFECT FIXED 2026-09-14 (red team RT-E-001). This read:
        ;;
        ;;    (if (= (UR_Global7) 1) (UR_Global4) (URC_AvailableRewards account))
        ;;
        ;;<UR_Global7> is unclaimed-count -- a property of the VAULT. The branch asked "is exactly
        ;;one claimant left?" and never "is THIS account that claimant?", so it offered the entire
        ;;vault to ANY caller whenever the count happened to be 1. The guard tested a global and
        ;;returned a per-account figure.
        ;;
        ;;It was reachable by a LEGITIMATE admin action, not an attack: unclaimed-count is set to
        ;;nzs-count only at inject, so recording a late contribution moves nzs-count and leaves
        ;;unclaimed-count behind. Measured at RedTeam/[RT-E]_Sequencing.repl <<RT-E-001>> --
        ;;counters diverged to 1 vs 3, and an account owed 0.000000000000 was offered
        ;;690.525983513596.
        ;;
        ;;NO THEFT WAS POSSIBLE, and the reason is worth keeping: A_Stake stamps a new contributor's
        ;;<last-collected-round> to the CURRENT round, and the collect capability enforces
        ;;(< last-collected-round distribution-round) -- a newcomer is born already-collected for
        ;;the round they joined. So the money never moved. But this reader also feeds URCi_Collect
        ;;and INFO_Collect, which told such an account it would receive the whole vault; and the
        ;;theft was prevented by a stamp written in a DIFFERENT function, with nothing connecting
        ;;the two. A number that is wrong everywhere except where one unrelated guard happens to
        ;;stop it is a defect, not a defence.
        (if (URC_IzDustSweepClaimant account)
            (UR_Global4)
            (URC_AvailableRewards account)
        )
    )
    (defun URC_AvailableRewards (account:string)
        (let
            (
                (current-pending-rewards:decimal (UR_User4 account))
                (current-score:decimal (UR_User1 account))
                (last-rps:decimal (UR_User3 account))
                (current-rps:decimal (UR_Global6))
                ;;
                (diff-rps:decimal (- current-rps last-rps))
                (gained-pending-rewards:decimal (floor (* current-score diff-rps) STOA_PREC))
            )
            (+ current-pending-rewards gained-pending-rewards)
        )
    )
    (defun URH_UncollectedAccounts:[string] ()
        @doc "#1C Hydra preflight — the ONE heavy read: every account that still holds an UNCOLLECTED \
            \ position this distribution-round, i.e. an actual staker (dollarz > 0) whose \
            \ last-collected-round is behind the vault distribution-round. The UI slices this list into \
            \ capacity-bounded Ap_FlushUncollectedSlice legs; AA_FlushUncollected consumes it whole."
        (let
            (
                (cur-round:integer (UR_Global11))
            )
            (map
                (lambda (row:object{UserContributionSchema}) (at "owner-id" row))
                (select STOAICO|T|User
                    (and?
                        (where "last-collected-round" (> cur-round))
                        (where "dollarz" (< 0.0))
                    )
                )
            )
        )
    )
    (defun URCi_Collect:decimal (account:string)
        @doc "Pure-citizen IGNIS cost preview for C_Collect = Sigma of the sovereign Talos ops XI_CollectFor \
            \ fires: DPTF remint of urSTOA + the reward payout — a MultiTransfer (wSTOA+urSTOA) when urSTOA \
            \ is non-zero, else a single wSTOA Transfer. Data-dependent, dirty-read-fed from the live vault."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (wSTOA-id:string (UR_Global8))
                (urSTOA-id:string (UR_Global9))
            )
            ;;PREVIEW/EXEC PARITY FIX (2026-09-17). The mint leg used to sit OUTSIDE this `if`,
            ;;added unconditionally — exactly where `XI_CollectFor`'s mint used to sit before the
            ;;2026-09-14 vault-deadlock fix moved it INSIDE the `(!= urSTOA-supply 0.0)` guard.
            ;;That fix repaired the EXECUTOR and left this READER alone, so the two disagreed on
            ;;every collect after an account's first — and the first collect is what zeroes urSTOA,
            ;;which makes the disagreeing case the NORMAL one, not an edge.
            ;;
            ;;Measured before the fix: preview 88.0 (mint 87.0 + transfer 1.0) for an operation
            ;;that charged 1.0. An 88x overstatement in the number a client is shown BEFORE
            ;;committing. Pinned by REPL/RedTeam/[RT-K]_PreviewParity.repl <<RT-K-008>>.
            (if (!= urSTOA-supply 0.0)
                (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Mint urSTOA-id DEMIPAD|SC_NAME false))
                   (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                       (ref-TFT::URCi_MultiTransferCumulator [wSTOA-id urSTOA-id] DEMIPAD|SC_NAME account [wSTOA-supply urSTOA-supply])))
                (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                    (ref-TFT::URCi_Transfer wSTOA-id DEMIPAD|SC_NAME account wSTOA-supply)))
        )
    )
    (defun INFO_Collect:object{OuronetInfoV3.ClientInfo} (patron:string account:string)
        @doc "Cost preview for the STOAICO|C_Collect pure-citizen reward collect (sole gas-funded path = \
            \ the TS02-CPAD Talos wrapper). IGNIS = URCi_Collect. No protocol STOA fee; the collect DELIVERS \
            \ wSTOA + urSTOA rewards to the account (a payout, not a cost)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Collect distribution rewards for {} (pure-citizen, Sigma-billed)." [sa])
                  (format "Delivers {} wSTOA + {} urSTOA to the account (a payout, not a cost)." [wSTOA-supply urSTOA-supply]) ]
                [ (format "Collected {} wSTOA + {} urSTOA." [wSTOA-supply urSTOA-supply]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_Collect account))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_CollectFor:string (patron:string account:string)
        @doc "#1C shared settle+deliver core: pays <account> its OWN wSTOA (its RPS delta, or the whole \
            \ remaining wstoa-supply when it is the round's last unclaimed staker — the dust sweep) plus its \
            \ urSTOA, then stamps it collected for the current distribution-round and decrements \
            \ unclaimed-count. Used by C_Collect (self-collect, gated by STOAICO|REDEEM-CONTRIBUTION) and by \
            \ the admin flush (push-collect on behalf of a straggler, gated by STOAICO|FLUSH). SECURE."
        (require-capability (SECURE))
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV3} TS01-C1)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (wSTOA-id:string (UR_Global8))
                (urSTOA-id:string (UR_Global9))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            ;;1]Collect wSTOA and URSTOA Rewards — delivered to <account>, the rightful owner
            ;;
            ;;VAULT-DEADLOCK FIX (2026-09-14). The urSTOA mint used to sit ABOVE this `if`,
            ;;UNCONDITIONAL, while only the DELIVERY was guarded on (!= urSTOA-supply 0.0). But a
            ;;zero-amount mint is refused: C_Mint -> DPTF|C>MINT -> DPTF|C>CREDIT -> UEV_Amount ->
            ;;(enforce (> amount 0.0)). And step 6 below (XI_ResetUrstoaEarned) zeroes the account's
            ;;urSTOA entitlement as part of its FIRST collect. So on the account's SECOND
            ;;distribution-round -- when a fresh A_Inject has advanced <current-rps> and real wSTOA
            ;;IS owed -- the whole transaction aborted on the mint.
            ;;
            ;;It was a DEADLOCK, not a nuisance, because all three exits share this core and shut
            ;;together: C_Collect aborts; AA_FlushUncollected maps XI_CollectFor over the stragglers
            ;;and fails identically; and A_Inject refuses to open a new round while
            ;;(!= unclaimed-count 0). The vault stops paying and cannot be restarted from ANY
            ;;entrypoint. IGNIS::XB_MoveDalosFuel documents this exact lesson in its own @doc --
            ;;it simply was not applied here.
            ;;
            ;;The fix is the guard the delivery already had, moved to cover the mint as well. The
            ;;wSTOA leg is guarded on the same principle: a staker whose RPS delta is zero has
            ;;nothing to transfer either, and a zero transfer is refused by the same UEV_Amount.
            ;;Steps 2-6 still run in every branch, which is what actually clears the straggler out
            ;;of <unclaimed-count> and lets the next round open.
            (if (!= urSTOA-supply 0.0)
                (do
                    (ref-TS01-C1::DPTF|C_Mint patron DEMIPAD|SC_NAME urSTOA-id urSTOA-supply false)
                    (if (!= wSTOA-supply 0.0)
                        (ref-TS01-C1::DPTF|C_MultiTransfer patron DEMIPAD|SC_NAME account [wSTOA-id urSTOA-id] [wSTOA-supply urSTOA-supply] true)
                        (ref-TS01-C1::DPTF|C_Transfer patron DEMIPAD|SC_NAME account urSTOA-id urSTOA-supply true)
                    )
                )
                (if (!= wSTOA-supply 0.0)
                    (ref-TS01-C1::DPTF|C_Transfer patron DEMIPAD|SC_NAME account wSTOA-id wSTOA-supply true)
                    "STOAICO: nothing owed this round -- settle-only, no delivery"
                )
            )
            ;;2]Reset <pending-rewards> to 0
            (XI_ResetPendingRewards account)
            ;;3]Decrement <unclaimed-count>
            (XI_UpdateUnclaimedCount false)
            ;;4]Update <last-rps> with the D-Vault <current-rps>
            (XI_UpdateUserRPS account (UR_Global6))
            ;;5]Update Vault Supply
            (XI_UpdateVaultSupply wSTOA-supply false)
            (XI_ResetUrstoaEarned account)
            ;;6]#1C: stamp this account as collected for the current distribution-round
            (XI_MarkCollected account)
            ;;7]Return claimed amounts
            (if (!= urSTOA-supply 0.0)
                (format
                    "Account {} succesfully claimed {} {} and {} {}"
                    [sa wSTOA-supply wSTOA-id urSTOA-supply urSTOA-id]
                )
                (format
                    "Account {} succesfully claimed {} {} and no {}"
                    [sa wSTOA-supply wSTOA-id urSTOA-id]
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_ResetPendingRewards (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"pending-rewards" : 0.0}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateUnclaimedCount (direction:bool)
        (require-capability (SECURE))
        (let
            (
                (uc:integer (UR_Global7))
                (new-uc:integer
                    (if direction
                        (+ uc 1)
                        (- uc 1)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"unclaimed-count" : new-uc}
            )
        )
    )
    ;;Admin
    ;;Protection: Class 2 — SECURE
    (defun XI_InitialiseDistributionVault (dptf-ids:[string])
        (require-capability (SECURE))
        (insert STOAICO|T|General STOAICO|INFO
            {"dollarz"          : 0.0
            ,"urstoa-left"      : 250000
            ,"users"            : 0
            ,"wstoa-supply"     : 0.0
            ,"nzs-count"        : 0
            ,"current-rps"      : 0.0
            ,"unclaimed-count"  : 0
            ,"distribution-round" : 0
            ,"zombie-rewards"   : 0.0
            ,"wstoa"            : (at 0 dptf-ids)
            ,"wurstoa"          : (at 1 dptf-ids)
            ,"vusd"             : (at 2 dptf-ids)
            }
        )
    )
    ;;User
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateUserScore (account:string amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (user-score:decimal (UR_User1 account))
                (new-user-score:decimal
                    (if direction
                        (+ user-score amount)
                        (- user-score amount)
                    )
                )
            )
            (update STOAICO|T|User account
                {"dollarz" : new-user-score}
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateUserRPS (account:string new-rps:decimal)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"last-rps" : new-rps}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_MarkCollected (account:string)
        @doc "#1C: stamp the account as having collected the CURRENT distribution-round."
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"last-collected-round" : (UR_Global11)}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdatePendingRewards (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"pending-rewards" : (URC_AvailableRewards account)}
        )
    )
    ;;D-Vault
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVaultScore (amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (vault-score:decimal (UR_Global1))
                (new-vault-score:decimal
                    (if direction
                        (+ vault-score amount)
                        (- vault-score amount)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"dollarz" : new-vault-score}
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVaultSupply (amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (vault-supply:decimal (UR_Global4))
                (new-vault-supply:decimal
                    (if direction
                        (+ vault-supply amount)
                        (- vault-supply amount)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"wstoa-supply" : new-vault-supply}
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateNZS (direction:bool)
        (require-capability (SECURE))
        (let
            (
                (nzs:integer (UR_Global5))
                (new-nzs:integer
                    (if direction
                        (+ nzs 1)
                        (- nzs 1)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"nzs-count" : new-nzs}
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVaultRPS (new-rps:decimal)
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"current-rps" : new-rps}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_ResetUnclaimedCount ()
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"unclaimed-count" : (UR_Global5)}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IncrementDistributionRound ()
        @doc "#1C: advance the vault to the next distribution-round (called by A_Inject)."
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"distribution-round" : (+ 1 (UR_Global11))}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_SetZombieRewards (amount:decimal)
        @doc "#5M: set the escrowed zombie-rewards (escrow adds to it; a flush zeroes it)."
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"zombie-rewards" : amount}
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_ResetUrstoaEarned (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"urstoa-earned"    : 0}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateUrstoaEarned (account:string v-usd-amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (user-score:decimal (UR_User1 account))
                (new-user-score:decimal
                    (if direction
                        (+ user-score v-usd-amount)
                        (- user-score v-usd-amount)
                    )
                )
                (vault-score:decimal (UR_Global1))
                (new-vault-score:decimal
                    (if direction
                        (+ vault-score v-usd-amount)
                        (- vault-score v-usd-amount)
                    )
                )
                (urstoa-left:integer (UR_Global2))
                (present-urstoa-earned:integer (UR_User2 account))
                (new-urstoa-earned:integer (floor (/ new-user-score 5.0)))
                (diff-urstoa:integer (- new-urstoa-earned present-urstoa-earned))
            )
            (if (= diff-urstoa 0)
                ;;do nothing
                true
                (let
                    (
                        (final-urstoa-earned:integer
                            (if (< urstoa-left diff-urstoa)
                                (+ present-urstoa-earned urstoa-left)
                                new-urstoa-earned
                            )


                        )
                        (final-urstoa-left:integer
                            (if (< urstoa-left diff-urstoa)
                                0
                                (- urstoa-left diff-urstoa)
                            )
                        )
                    )
                    (update STOAICO|T|User account
                        {"urstoa-earned"    : final-urstoa-earned}
                    )
                    (update STOAICO|T|General STOAICO|INFO
                        {"urstoa-left"      : final-urstoa-left}
                    )
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_InitialiseDistributionVault (account:string)
        @doc "Initialises the Distribuition Vault by creating and filling all necesary prerequisites"
        (with-capability (INIT-ICO-DISTRIBUTION)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV3} TS01-C1)
                    (dptf-ids:list 
                        (ref-TS01-C1::DPTF|C_Issue account account
                            ["WrappedUrStoa" "VirtualIcoDollars"]
                            ["WURSTOA" "VUSDC"]
                            [3 2]
                            [true true]
                            [true true]
                            [true true]
                            [false false]
                            [false false]
                            [false false]
                        )
                    )
                    (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                    (wurstoa-id:string (at 0 dptf-ids))
                    (vusd-id:string (at 1 dptf-ids))
                )
                ;;1]Issue wURSTOA as DPTF
                ;;2]Issue vUSD as mockup virtual Dollarz
                ;;3]Toggle mint and burn roles
                (ref-TS01-C1::DPTF|C_ToggleMintRole account (DPTF.UR_Konto vusd-id) DEMIPAD|SC_NAME vusd-id true)
                (ref-TS01-C1::DPTF|C_ToggleBurnRole account (DPTF.UR_Konto vusd-id) DEMIPAD|SC_NAME vusd-id true)
                (ref-TS01-C1::DPTF|C_ToggleMintRole account (DPTF.UR_Konto wstoa-id) account wstoa-id true)
                (ref-TS01-C1::DPTF|C_ToggleMintRole account (DPTF.UR_Konto wurstoa-id) DEMIPAD|SC_NAME wurstoa-id true)
                ;;4]Mint 10 mil wSTOA (injection will follow after ICO concludes)    
                (ref-TS01-C1::DPTF|C_Mint account account wstoa-id 10000000.0 true)
                ;;5]Initialises the distribution Vault
                (XI_InitialiseDistributionVault [wstoa-id wurstoa-id vusd-id])
                ;;6]Output Message
                [wurstoa-id vusd-id]
            )
        )
    )
    (defun A_MigrateGeneralFields:string ()
        @doc "ONE-TIME admin hotfix, not a normal operation. `GeneralContributionSchema` gained \
            \ `distribution-round` and `zombie-rewards` (the #1C / #5M fixes) in a module upgrade \
            \ that was never followed by a row migration -- the live STOAICO|T|General row still \
            \ holds only the original 10 fields it was inserted with. Every path that reads a \
            \ distribution-round (A_Stake, A_Unstake, A_Inject, collect, the dust-sweep) has \
            \ aborted with \"Key distribution-round not found in object\" since that upgrade \
            \ landed -- confirmed directly against the live row (UR_Global0) and the live module \
            \ code (describe-module), 2026-10-12. The values written here are the actual, \
            \ chain-confirmed starting values, not a guess: the live row's current-rps and \
            \ wstoa-supply both read 0, meaning no A_Inject has ever landed, so \
            \ distribution-round=0 and zombie-rewards=0.0 are exactly what genesis would have \
            \ written had the field existed at insert time. GOV|MIGRATE-GENERAL-FIELDS refuses a \
            \ second call outright, so running this twice is a clean abort, not a silent reset."
        (with-capability (GOV|MIGRATE-GENERAL-FIELDS)
            (update STOAICO|T|General STOAICO|INFO
                {"distribution-round" : 0
                ,"zombie-rewards"     : 0.0
                }
            )
            "STOAICO: migrated -- distribution-round and zombie-rewards added to the General row"
        )
    )
    (defun A_Inject (patron:string account:string wstoa-amount:decimal)
        @doc "Injects the ICO wSTOA amount into the Distribution-Vault (D-Vault); \
            \ the 10 mil from the ICO sale, from <account> \
            \ Can only be done by the ADMIN"
        (with-capability (STOAICO|INJECT account)
            (let
                (
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV3} TS01-C1)
                    (wSTOA-ID:string (UR_Global8))
                    ;;
                    (vault-score:decimal (UR_Global1))
                    (zombie:decimal (UR_Global12))
                )
                (if (> vault-score 0.0)
                    ;;=== FLUSH — stakers present: distribute (new amount + any escrowed zombie), open next round.
                    (let
                        (
                            (eff:decimal (+ wstoa-amount zombie))
                        )
                        ;;#1C] Inject barrier — a new distribution-round may open ONLY when the previous one is
                        ;;     fully collected (unclaimed-count == 0). Stragglers are cleared by the admin flush.
                        (enforce
                            (= (UR_Global7) 0)
                            "STOAICO: previous distribution-round not fully collected — flush the stragglers (or wait for collections) before injecting again")
                        ;;0]Move wSTOA from <account> to the D-Vault
                        (ref-TS01-C1::DPTF|C_Transfer patron account DEMIPAD|SC_NAME wSTOA-ID wstoa-amount true)
                        ;;1]Count it in <wstoa-supply> (total held by the vault)
                        (XI_UpdateVaultSupply wstoa-amount true)
                        ;;2]Advance <current-rps> by the EFFECTIVE amount (new + escrowed zombie) / vault-score.
                        ;;  vault-score > 0 here, so the reward-per-share division can never divide by zero.
                        (XI_UpdateVaultRPS (+ (UR_Global6) (floor (/ eff vault-score) STOA_PREC)))
                        ;;3]#5M: the escrowed zombie is fully consumed by this flush
                        (if (> zombie 0.0) (XI_SetZombieRewards 0.0) true)
                        ;;4]Reset <unclaimed-count> (set it to <nzs-count>)
                        (XI_ResetUnclaimedCount)
                        ;;5]#1C: advance the vault to the next distribution-round (opens collection for this round)
                        (XI_IncrementDistributionRound)
                    )
                    ;;=== ESCROW — #5M no stakers (vault-score 0): park the amount as zombie for the NEXT non-zero
                    ;;    inject (eff = amount + zombie). Nothing is distributed (no rps/round/unclaimed change),
                    ;;    so the division is never reached with a zero denominator.
                    (do
                        ;;0]Move wSTOA from <account> to the D-Vault (held, not yet distributed)
                        (ref-TS01-C1::DPTF|C_Transfer patron account DEMIPAD|SC_NAME wSTOA-ID wstoa-amount true)
                        ;;1]Count it in <wstoa-supply> (held by the vault)
                        (XI_UpdateVaultSupply wstoa-amount true)
                        ;;2]Escrow: postpone distribution to the next injection when vault-score is non-zero
                        (XI_SetZombieRewards (+ zombie wstoa-amount))
                    )
                )
            )
        )
    )
    (defun A_Stake (patron:string account:string v-usd-amount:decimal)
        @doc "Adds a contribution in virtual $ to the Distribution Vault \
            \ Contributing with v-dollars allows for a piece of the 10 mil wSTOA \
            \ placed for distribution in this Vault.\
            \ Also earns urSTOA (up to 300k) \
            \ Can only be done by the Admin"
        (with-capability (STOAICO|ADD-CONTRIBUTION account v-usd-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV3} TS01-C1)
                    (v-usd-id:string (UR_Global10))
                    (user-score:decimal (UR_User1 account))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                ;;0]Mint the v-USD amount to the <DEMIPAD|SC_NAME>
                (ref-TS01-C1::DPTF|C_Mint patron DEMIPAD|SC_NAME v-usd-id v-usd-amount false)
                ;;0.1]If New Account
                (if (not (UR_IzAccount account))
                    (do
                        (insert STOAICO|T|User account
                            ;;#1C: new contributor starts at the CURRENT distribution-round, so a (mis-ordered)
                            ;;     post-inject stake is not eligible for the already-injected round.
                            (UDC_UserData 0.0 0 (UR_Global6) 0.0 (UR_Global11) account)
                        )
                        ;;Increment Users by one
                        (update STOAICO|T|General STOAICO|INFO
                            {"users" : (+ 1 (UR_Global3))}
                        )
                    )                
                    true
                )
                ;;1.1]Update Pending Rewards
                (XI_UpdatePendingRewards account)
                ;;1.2]If initial <user-score> was 0, increment <nzs-count>
                (if (= user-score 0.0)
                    (XI_UpdateNZS true)
                    true
                )
                ;;1.3]Update <last-rps> with D-Vault <current-rps>
                (XI_UpdateUserRPS account (UR_Global6))
                ;;1.4]#6M: Earn urSTOA ONLY during the ICO phase (distribution-round 0). After the ICO
                ;;    concludes (first inject → round >= 1) contributions no longer earn urSTOA; the unsold
                ;;    remainder of the 250k budget stays unminted (returns to the foundation).
                (if (= (UR_Global11) 0)
                    (XI_UpdateUrstoaEarned account v-usd-amount true)
                    true)
                ;;1.5]Update Vault Score and User Score
                (XI_UpdateVaultScore v-usd-amount true)
                (XI_UpdateUserScore account v-usd-amount true)
                (format "Succesfully contributed {} $ for Ouronet Account {}"
                    [v-usd-amount sa]
                )
            )
        )
    )
    (defun A_Unstake (patron:string account:string v-usd-amount:decimal)
        @doc "Removes a contribution of virtual $ from the Distribution Vault for an <account> \
            \ Can only be done by the ADMIN"
        (with-capability (STOAICO|REMOVE-CONTRIBUTION account v-usd-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV3} TS01-C1)
                    (v-usd-id:string (UR_Global10))
                    (user-score:decimal (UR_User1 account))
                    (remaining:decimal (- user-score v-usd-amount))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                ;;0]Burn the v-USD amount from the <DEMIPAD|SC_NAME> that is to be removed
                (ref-TS01-C1::DPTF|C_Burn patron DEMIPAD|SC_NAME v-usd-id v-usd-amount)
                ;;1.1]Update Pending Rewards
                (XI_UpdatePendingRewards account)
                ;;1.2]If remaining <user-score> becomes 0, decrement <nzs-count>
                (if (= remaining 0.0)
                    (XI_UpdateNZS false)
                    true
                )
                ;;1.3]Update <last-rps> with D-Vault <current-rps>
                (XI_UpdateUserRPS account (UR_Global6))
                ;;1.4]#6M: adjust urSTOA earning ONLY during the ICO phase (distribution-round 0); after the
                ;;    ICO concludes, contributions/withdrawals no longer touch urSTOA earning.
                (if (= (UR_Global11) 0)
                    (XI_UpdateUrstoaEarned account v-usd-amount false)
                    true)
                ;;1.5]Update Vault Score and User Score
                (XI_UpdateVaultScore v-usd-amount false)
                (XI_UpdateUserScore account v-usd-amount false)
                (format "Succesfully uncontributed {} $ for Ouronet Account {}"
                    [v-usd-amount sa]
                )
            )
        )
    )
    (defun Ap_FlushUncollectedSlice:string (patron:string accounts:[string])
        @doc "#1C Hydra parallel slice: the admin push-collects ONE slice of uncollected accounts, delivering \
            \ each its OWN wSTOA + urSTOA (identical to a self-collect — not to the admin, not burned). \
            \ Order-independent and retryable — an account already collected this round is skipped, so re-runs \
            \ are idempotent. Drives unclaimed-count toward 0 so the next A_Inject can open the following round."
        (with-capability (STOAICO|FLUSH)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (cur-round:integer (UR_Global11))
                )
                (map
                    (lambda (account:string)
                        (if (< (UR_User5 account) cur-round)
                            (XI_CollectFor patron account)
                            (format "Account {} already collected — skipped" [(ref-I|OURONET::OI|UC_ShortAccount account)])
                        )
                    )
                    accounts
                )
                (format "Flush slice processed {} account(s)" [(length accounts)])
            )
        )
    )
    (defun AA_FlushUncollected:string (patron:string)
        @doc "#1C solo/heavy admin flush: push-collect ALL uncollected stragglers in one transaction (reaches \
            \ the URH_UncollectedAccounts heavy scan — hence AA_). For large contributor sets prefer the \
            \ parallel URH_UncollectedAccounts preflight + Ap_FlushUncollectedSlice legs. Delivers each \
            \ straggler its own rewards and clears unclaimed-count so the next inject can proceed."
        (with-capability (STOAICO|FLUSH)
            (let
                (
                    (accounts:[string] (URH_UncollectedAccounts))
                )
                (map (lambda (account:string) (XI_CollectFor patron account)) accounts)
                (format "Flushed {} uncollected account(s)" [(length accounts)])
            )
        )
    )
    (defun C_Collect (patron:string account:string)
        @doc "Self-collect from the distribution Vault — once per distribution-round, by the <account> owner. \
            \ A new A_Inject opens the next round and re-enables collection (the RPS delta since last collect)."
        (with-capability (STOAICO|REDEEM-CONTRIBUTION account)
            (XI_CollectFor patron account)
        )
    )

)

;; --- tables for 05_STOAICO.pact (4 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table STOAICO|T|User)
;; (create-table STOAICO|T|General)

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
                (ref-EQUITY:module{EquityV4} EQUITY)
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
                (ref-EQUITY:module{EquityV4} EQUITY)
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


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
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_INFO|AQP       (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|INFO|AQP_ADMIN)))
    (defcap GOV|INFO|AQP_ADMIN ()   (enforce-guard GOV|MD_INFO|AQP))
    ;;{G3}
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    ;;{P3}
    ;;{P4}
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    ;;{2}
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defconst BAR                   (CT_Bar))
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    ;;{C2}
    ;;{C3}
    ;;{C4}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UC]  — gas-price gate (mirrors INFO-ONE UC|GasPrice: zero when the toggle is off)
    (defun UC|GasPrice:decimal (full-price:decimal trigger:bool)
        @doc "Full price when live billing is on (trigger=false); 0.0 when the gas toggle zeroes it."
        (if trigger 0.0 full-price)
    )
    ;;{F1}  [SIP|URC]  — Simple Ignis Price: one named UsagePrice tier behind the virtual-gas gate
    (defun SIP|URC_Small:decimal ()
        @doc "IGNIS tier 'ignis|small' behind the virtual-gas toggle."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (ref-DALOS::UR_UsagePrice "ignis|small") (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun SIP|URC_Medium:decimal ()
        @doc "IGNIS tier 'ignis|medium' behind the virtual-gas toggle (score/FVT rotate & control, enable-deb-boost)."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (ref-DALOS::UR_UsagePrice "ignis|medium") (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun SIP|URC_Big:decimal ()
        @doc "IGNIS tier 'ignis|big' behind the virtual-gas toggle."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (ref-DALOS::UR_UsagePrice "ignis|big") (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun SIP|URC_Biggest:decimal ()
        @doc "IGNIS tier 'ignis|biggest' behind the virtual-gas toggle (anchor/boost-class revokes, score boost-links)."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (ref-DALOS::UR_UsagePrice "ignis|biggest") (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun SIP|URC_Fixed:decimal (gas-cost:decimal)
        @doc "A FIXED GAS| constant (read cross-module from the executing core) behind the virtual-gas toggle."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS))
            (UC|GasPrice gas-cost (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    ;;{F2}  [SKP|URC]  — Simple Kadena Price: a native UsagePrice charge behind the native-gas gate
    (defun SKP|URC_Standard:decimal (multiplier:decimal)
        @doc "Native STOA 'standard' × multiplier behind the native-gas toggle (anchor issue: mult 2 when acnoi)."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (* (ref-DALOS::UR_UsagePrice "standard") multiplier) (ref-IGNIS::URC_IsNativeGasZero)))
    )
    (defun SKP|URC_Smart:decimal ()
        @doc "Native STOA 'smart' behind the native-gas toggle (score/pool/FVT issue)."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC|GasPrice (ref-DALOS::UR_UsagePrice "smart") (ref-IGNIS::URC_IsNativeGasZero)))
    )
    ;;{F3}  [INFO]  — one per AQP user/admin entrypoint, grouped by source module
    ;;
    ;;<====================>
    ;;[AQP-ANK] Anchors
    ;;<====================>
    (defun AQP-ANK|INFO_IssueTrueFungibleAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Cost preview for AQP-ANK|C_IssueTrueFungibleAnchor. IGNIS 1000 (inline) + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a True-Fungible (DPTF) anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueTrueFungibleAnchor."]
                [(format "Anchor '{}' issued on DPTF {}." [anchor-name dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed 1000.0))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Standard (if acnoi 2.0 1.0)))
                []
            )
        )
    )
    (defun AQP-ANK|INFO_IssueSemiFungibleAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Cost preview for AQP-ANK|C_IssueSemiFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Semi-Fungible (DPSF) anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueSemiFungibleAnchor."]
                [(format "Anchor '{}' issued on DPSF {} nonce {}." [anchor-name dpsf-id dpsf-nonce])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed 1000.0))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Standard (if acnoi 2.0 1.0)))
                []
            )
        )
    )
    (defun AQP-ANK|INFO_IssueNonFungibleAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Cost preview for AQP-ANK|C_IssueNonFungibleAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Non-Fungible (DPNF) trait-anchor for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueNonFungibleAnchor."]
                [(format "Anchor '{}' issued on DPNF {} trait {}={}." [anchor-name dpnf-id dpnf-trait-key dpnf-trait-value])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed 1000.0))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Standard (if acnoi 2.0 1.0)))
                []
            )
        )
    )
    (defun AQP-ANK|INFO_IssueNonFungibleSetAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Cost preview for AQP-ANK|C_IssueNonFungibleSetAnchor. IGNIS 1000 + STOA 'standard' x(2 if acnoi else 1)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a Non-Fungible (DPNF) set-anchor (by nonce-class) for pool boosting."
                 (if acnoi "Creates a new BoostClass inline (2x STOA)." "Links to an existing BoostClass (1x STOA).")
                 "Executes via TS02-C3.AQP-ANK|C_IssueNonFungibleSetAnchor."]
                [(format "Anchor '{}' issued on DPNF {} nonce-class {}." [anchor-name dpnf-id dpnf-nonce-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed 1000.0))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Standard (if acnoi 2.0 1.0)))
                []
            )
        )
    )
    (defun AQP-ANK|INFO_RevokeAnchor:object{OuronetInfoV1.ClientInfo}
        (patron:string anchor-id:string)
        @doc "Cost preview for AQP-ANK|C_RevokeAnchor. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Revoke an anchor and update its BoostClass bookkeeping."
                 "Executes via TS02-C3.AQP-ANK|C_RevokeAnchor."]
                [(format "Anchor {} revoked." [anchor-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun AQP-ANK|INFO_RevokeBoostClass:object{OuronetInfoV1.ClientInfo}
        (patron:string boost-class-id:string)
        @doc "Cost preview for AQP-ANK|C_RevokeBoostClass. IGNIS 'ignis|biggest' tier; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Revoke an empty BoostClass."
                 "Executes via TS02-C3.AQP-ANK|C_RevokeBoostClass."]
                [(format "BoostClass {} revoked." [boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    ;;
    ;;<====================>
    ;;[AQP-SCR] Scores
    ;;<====================>
    (defun AQP-SCR|INFO_IssueLiquidityScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueLiquidityScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-0 (Liquidity) score." "Executes via TS02-C3.AQP-SCR|C_IssueLiquidityScore."]
                [(format "Liquidity score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-SCR|INFO_IssueTrueFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueTrueFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-1 (True-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueTrueFungibleScore."]
                [(format "True-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-SCR|INFO_IssueOrtoFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Cost preview for AQP-SCR|C_IssueOrtoFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-2 (Orto-Fungible / special) score." "Executes via TS02-C3.AQP-SCR|C_IssueOrtoFungibleScore."]
                [(format "Orto-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-SCR|INFO_IssueSemiFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Cost preview for AQP-SCR|C_IssueSemiFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-3 (Semi-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueSemiFungibleScore."]
                [(format "Semi-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-SCR|INFO_IssueNonFungibleScore:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleScore. IGNIS GAS|ISSUE-SCORE + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a class-4 (Non-Fungible) score." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleScore."]
                [(format "Non-Fungible score '{}' issued for {}." [score-name owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-SCR|INFO_RotateScoreOwnership:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string new-owner-konto:string)
        @doc "Cost preview for AQP-SCR|C_RotateScoreOwnership. IGNIS 'ignis|medium' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Transfer a score's owner-konto." "Executes via TS02-C3.AQP-SCR|C_RotateScoreOwnership."]
                [(format "Score {} ownership moved to {}." [score-id new-owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_ControlScore:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Cost preview for AQP-SCR|C_ControlScore. IGNIS 'ignis|medium' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Set a score's can-upgrade / can-change-owner flags." "Executes via TS02-C3.AQP-SCR|C_ControlScore."]
                [(format "Score {} control flags updated." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_CreateScoreBoostClassLink:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string boost-class-id:string)
        @doc "Cost preview for AQP-SCR|C_CreateScoreBoostClassLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a BoostClass (once)." "Executes via TS02-C3.AQP-SCR|C_CreateScoreBoostClassLink."]
                [(format "Score {} linked to BoostClass {}." [score-id boost-class-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_CreateScoreBoostLink:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string boost-score-id:string)
        @doc "Cost preview for AQP-SCR|C_CreateScoreBoostLink. IGNIS 'ignis|biggest' tier; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Link a score to a boost-score (once)." "Executes via TS02-C3.AQP-SCR|C_CreateScoreBoostLink."]
                [(format "Score {} boost-linked to {}." [score-id boost-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_EnableDebBoost:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string)
        @doc "Cost preview for AQP-SCR|C_EnableDebBoost. IGNIS 'ignis|medium' tier; no STOA. Irreversible."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Enable deb-boost on a score (irreversible)." "Executes via TS02-C3.AQP-SCR|C_EnableDebBoost."]
                [(format "Score {} deb-boost enabled." [score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueTriplet:object{OuronetInfoV1.ClientInfo}
        (patron:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Cost preview for AQP-SCR|C_IssueTriplet. IGNIS GAS|ISSUE-TRIPLET; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Bundle three scores into one triplet (T|bronze|silver|golden)." "Executes via TS02-C3.AQP-SCR|C_IssueTriplet."]
                [(format "Triplet issued from {} / {} / {}." [bronze-score-id silver-score-id golden-score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-TRIPLET))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueSingleScoreModel:object{OuronetInfoV1.ClientInfo}
        (patron:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueSingleScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Define a SINGLE score-entity model." "Executes via TS02-C3.AQP-SCR|C_IssueSingleScoreModel."]
                [(format "Single score model '{}' defined (class {})." [model-name score-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE-MODEL))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_CombineTripletScoreModel:object{OuronetInfoV1.ClientInfo}
        (patron:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
        @doc "Cost preview for AQP-SCR|C_CombineTripletScoreModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Combine three SINGLE models into a TRIPLET model." "Executes via TS02-C3.AQP-SCR|C_CombineTripletScoreModel."]
                [(format "Triplet score model '{}' combined." [model-name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE-MODEL))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueScoreFromModel:object{OuronetInfoV1.ClientInfo}
        (patron:string owner-konto:string model-id:string agency-name:string)
        @doc "Cost preview for AQP-SCR|C_IssueScoreFromModel. IGNIS GAS|ISSUE-SCORE-MODEL; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Issue a score/triplet entity conforming to a model." "Executes via TS02-C3.AQP-SCR|C_IssueScoreFromModel."]
                [(format "Entity '{}' issued from model {} for {}." [agency-name model-id owner-konto])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-SCORE.GAS|ISSUE-SCORE-MODEL))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueSemiFungibleScoreDefinition:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueSemiFungibleScoreDefinition. IGNIS = count × 'ignis|big'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;; mirror C_IssueSemiFungibleScoreDefinition: (* (dec (length nonces)) (UsagePrice "ignis|big"))
                (ifp:decimal (UC|GasPrice (* (dec (length nonces)) (ref-DALOS::UR_UsagePrice "ignis|big")) (ref-IGNIS::URC_IsVirtualGasZero)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Semi-Fungible score definition rows (one per nonce)." "Executes via TS02-C3.AQP-SCR|C_IssueSemiFungibleScoreDefinition."]
                [(format "Wrote {} SF score-definition rows on score {}." [(length nonces) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueNonFungibleScoreDefinition:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ifp:decimal (UC|GasPrice (* (dec (length trait-keys)) (ref-DALOS::UR_UsagePrice "ignis|biggest")) (ref-IGNIS::URC_IsVirtualGasZero)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible trait-score definition rows (one per trait)." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleScoreDefinition."]
                [(format "Wrote {} NF trait-score rows on score {}." [(length trait-keys) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-SCR|INFO_IssueNonFungibleSetScoreDefinition:object{OuronetInfoV1.ClientInfo}
        (patron:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Cost preview for AQP-SCR|C_IssueNonFungibleSetScoreDefinition. IGNIS = count × 'ignis|biggest'; no STOA."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ifp:decimal (UC|GasPrice (* (dec (length dpnf-nonce-classes)) (ref-DALOS::UR_UsagePrice "ignis|biggest")) (ref-IGNIS::URC_IsVirtualGasZero)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Write Non-Fungible SET score definition rows (one per nonce-class)." "Executes via TS02-C3.AQP-SCR|C_IssueNonFungibleSetScoreDefinition."]
                [(format "Wrote {} NF set score-definition rows on score {}." [(length dpnf-nonce-classes) score-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    ;;
    ;;<====================>
    ;;[AQP-POOL] Pools (config)
    ;;<====================>
    (defun AQP-POOL|INFO_Issue:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Cost preview for AQP-POOL|C_Issue. IGNIS GAS|ISSUE-POOL + STOA 'smart'."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Create a new staking pool over an asset." "Executes via TS02-C3.AQP-POOL|C_Issue."]
                [(format "Pool '{}' created over asset {} (class {})." [pool-name asset-id aqp-class])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|ISSUE-POOL))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Smart))
                []))
    )
    (defun AQP-POOL|INFO_AddScore:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|C_AddScore. IGNIS GAS|ADD-SCORE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Assign a score to the pool's first free slot." "Executes via TS02-C3.AQP-POOL|C_AddScore."]
                [(format "Score {} added to pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|ADD-SCORE))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-POOL|INFO_RevokeScore:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string score-id:string)
        @doc "Cost preview for AQP-POOL|C_RevokeScore. IGNIS GAS|REVOKE-SCORE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Clear a score from its pool slot." "Executes via TS02-C3.AQP-POOL|C_RevokeScore."]
                [(format "Score {} revoked from pool {}." [score-id pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|REVOKE-SCORE))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-POOL|INFO_EnablePoolStake:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_EnablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Re-enable new stakes on a pool." "Executes via TS02-C3.AQP-POOL|C_EnablePoolStake."]
                [(format "Pool {} staking enabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|SET-POOL-STAKE))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-POOL|INFO_DisablePoolStake:object{OuronetInfoV1.ClientInfo}
        (patron:string pool-id:string)
        @doc "Cost preview for AQP-POOL|C_DisablePoolStake. IGNIS GAS|SET-POOL-STAKE; no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Pause new stakes on a pool." "Executes via TS02-C3.AQP-POOL|C_DisablePoolStake."]
                [(format "Pool {} staking disabled." [pool-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|SET-POOL-STAKE))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-POOL|INFO_SyncTrueFungibleAnchors:object{OuronetInfoV1.ClientInfo}
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncTrueFungibleAnchors. IGNIS GAS|SYNC-TF-ANCHORS base (+ state-dependent ANK repair); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's True-Fungible anchor slots after a stake."
                 "Base IGNIS shown; any per-anchor repair legs are added at execution."
                 "Executes via TS02-C3.AQP-POOL|C_SyncTrueFungibleAnchors."]
                [(format "TF anchors synced for {} on DPTF {}." [beneficiary-id dptf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|SYNC-TF-ANCHORS))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-POOL|INFO_SyncSemiFungibleAnchors:object{OuronetInfoV1.ClientInfo}
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncSemiFungibleAnchors. IGNIS GAS|SYNC-COLLECTABLE-ANCHORS base (+ state-dependent ANK repair); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Semi-Fungible anchor slots after a stake."
                 "Base IGNIS shown; any per-anchor repair legs are added at execution."
                 "Executes via TS02-C3.AQP-POOL|C_SyncSemiFungibleAnchors."]
                [(format "SF anchors synced for {} on DPSF {}." [beneficiary-id dpsf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|SYNC-COLLECTABLE-ANCHORS))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    (defun AQP-POOL|INFO_SyncNonFungibleAnchors:object{OuronetInfoV1.ClientInfo}
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "Cost preview for AQP-POOL|C_SyncNonFungibleAnchors. IGNIS GAS|SYNC-COLLECTABLE-ANCHORS base (+ state-dependent ANK repair); no STOA."
        (let ((ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO))
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Repair a beneficiary's Non-Fungible anchor slots after a stake."
                 "Base IGNIS shown; any per-anchor repair legs are added at execution."
                 "Executes via TS02-C3.AQP-POOL|C_SyncNonFungibleAnchors."]
                [(format "NF anchors synced for {} on DPNF {}." [beneficiary-id dpnf-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Fixed AQP-POOL.GAS|SYNC-COLLECTABLE-ANCHORS))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []))
    )
    ;;{F4}  [CAP]
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
)

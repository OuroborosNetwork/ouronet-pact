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
    ;;{F4}  [CAP]
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
)

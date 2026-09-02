;; EXPLORER — read-only aggregate module for chain explorer / block explorer UI.
;; Load after Stage 1 (+ Stage 2 when reads depend on it). See REPL/StageZZ_Tester.repl.
;; No interface — poll ouronet-ns.EXPLORER::<UR|URC> directly. Add reads under ;;{F0} [UC] / ;;{F0b} [UR] / ;;{F1} [URC].
;;
(module EXPLORER GOV


    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_EXPLORER               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                          (compose-capability (GOV|EXPLORER_ADMIN)))
    (defcap GOV|EXPLORER_ADMIN ()           (enforce-guard GOV|MD_EXPLORER))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

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
    (defconst BAR                           (CT_Bar))
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
    (defun CT_Namespace ()                    (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE)))
    ;;
    ;;
    (defun CT_Bar ()                        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    (defun UC_FormatTokenAmount:string (amount:decimal)
        @doc "Token amount display helper (aligned with DPL-UR)."
        (let
            (
                (formated-value:string (format "{}" [(floor amount 4)]))
            )
            (if (= formated-value 0.0)
                "<0.0001"
                formated-value
            )
        )
    )
    (defun UC_FormatIndex:string (index:decimal)
        @doc "Index display helper (aligned with DPL-UR HeaderV3)."
        (let
            (
                (fi:decimal (floor index 12))
                (fis:string (format "{}" [fi]))
                (l1:string (take -3 fis))
                (l2:string (take -3 (drop -3 fis)))
                (l3:string (take -3 (drop -6 fis)))
                (l4:string (take -3 (drop -9 fis)))
                (whole:string (drop -13 fis))
            )
            (concat
                [whole ",[" l4 "." l3 "." l2 "." l1 "]"]
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_0001_AccountNonce:integer (account:string)
        @doc "Patron IGNIS client-op counter (proxies DALOS|UR_AccountNonce)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::UR_AccountNonce account)
        )
    )
    (defun URC_0001_LandingPage ()
        @doc "Explorer landing: global z3 stats, OURO/AURYN/ELITEAURYN/IGNIS supplies, Auryn index pair."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (auryn-id:string (ref-DALOS::UR_AurynID))
                (elite-auryn-id:string (ref-DALOS::UR_EliteAurynID))
                ;;
                (Auryndex:string "Auryndex-O136CBn22ncY")
                (EAuryndex:string "EliteAuryndex-O136CBn22ncY")
                (ih-auryndex:decimal (ref-ATS::URC_Index Auryndex))
                (ih-elite-auryndex:decimal (ref-ATS::URC_Index EAuryndex))
                ;;
                (ignis-collection:bool (ref-DALOS::UR_VirtualToggle))
                (stoa-collection:bool (ref-DALOS::UR_NativeToggle))
                (it:string (if ignis-collection "ON" "OFF"))
                (st:string (if stoa-collection "ON" "OFF"))
                ;;
                (asymmetric-prov:bool (ref-SWP::UR_Asymetric))
                (liq-boost:bool (ref-SWP::UR_LiquidBoost))
                (a-t:string (if asymmetric-prov "ON" "OFF"))
                (b-t:string (if liq-boost "ON" "OFF"))
            )
            {"z2-t1"                            : (ref-ATS::UR_IndexName Auryndex)
            ,"z2-v1"                            : (UC_FormatIndex ih-auryndex)
            ,"z2-t2"                            : (ref-ATS::UR_IndexName EAuryndex)
            ,"z2-v2"                            : (UC_FormatIndex ih-elite-auryndex)
            ,"z3-t1"                            : "Ouronet Accounts:"
            ,"z3-v1"                            : (length (keys DALOS.DALOS|AccountTable))
            ,"z3-t2"                            : "IGNIS / STOA Gas Collection:"
            ,"z3-v2"                            : (format "{} / {}" [it st])
            ,"z3-t3"                            : "Asym. Liq. Prov. / Liq. Boost:"
            ,"z3-v3"                            : (format "{} / {}" [a-t b-t])
            ,"z3-t4"                            : "Ouronet IGNIS spent:"
            ,"z3-v4"                            : (ref-DALOS::UR_VirtualSpent)
            ,"z3-t5"                            : "Ouronet STOA spent"
            ,"z3-v5"                            : (ref-DALOS::UR_NativeSpent)
            ,"ouro-supply"                      : (UC_FormatTokenAmount (ref-DPTF::UR_Supply ouro-id))
            ,"auryn-supply"                     : (UC_FormatTokenAmount (ref-DPTF::UR_Supply auryn-id))
            ,"elite-auryn-supply"               : (UC_FormatTokenAmount (ref-DPTF::UR_Supply elite-auryn-id))
            ,"ignis-supply"                     : (UC_FormatTokenAmount (ref-DPTF::UR_Supply ignis-id))
            }
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

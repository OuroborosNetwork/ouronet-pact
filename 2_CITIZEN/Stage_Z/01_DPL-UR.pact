;; DPL-UR — single deployer read module (canonical; keep aligned with live net).
;; Load only after Stage 1 and Stage 2 (REPL/StageZZ_Tester.repl after Stage02_Tester.repl).
;; Implements DeployerReadsV7 + V8 (StoicTag) + V9 (PYTHIA Apollo) + V10 (Elite) + V11 (Dual API + Pythia prices) + V12 (Elite rich list).
;;
(interface DeployerReadsV12
    @doc "Elite Account rich-list scan (V12 additive — all Standard Ouronet accounts)."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;{G5}  functions

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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_0035_EliteAccountRichList:[object] ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
(module DPL-UR GOV



    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements DeployerReadsV12)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPL-UR                 (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                          (compose-capability (GOV|DPL_UR_ADMIN)))
    (defcap GOV|DPL_UR_ADMIN ()             (enforce-guard GOV|MD_DPL-UR))
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
    (defun UC_TrimDecimalTrailingZeros:string (number:decimal)
        @doc "Trims trailing zeros from a decimal number"
        (let* 
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (number-as-string:string (format "{}" [number]))
                (split-nas:[string] (ref-U|LST::UC_SplitString "." number-as-string))
                (integer-part:string (at 0 split-nas))
                (decimal-part:string (at 1 split-nas))
                (ldp:integer (length decimal-part))
                ;;
                (trimmed-decimal-part:string
                    (fold
                        (lambda
                            (acc:string idx:integer)
                            (if (= (take -1 acc) "0")
                                (drop -1 acc)
                                acc
                            )    
                        )
                        decimal-part
                        (enumerate 0 (- ldp 1))
                    )
                )
                (resulted-string:string
                    (if (= trimmed-decimal-part "")
                        (+ integer-part ".0")
                        (concat [integer-part "." trimmed-decimal-part])
                    )
                )
            )
            resulted-string
        )
    )
    (defun UC_ConvertPrice:string (input-price:decimal)
        (let
            (
                (number-of-decimals:integer (if (<= input-price 1.00) 3 2))
                (converted:decimal
                    (if (< input-price 1.00)
                        (floor (* input-price 100.0) 3)
                        (floor input-price 2)
                    )
                )
                (s:string
                    (if (< input-price 1.00)
                        "¢"
                        "$"
                    )
                )
                (ss:string "<0.001¢")
            )
            (if (< input-price 0.00001)
                (format "{}" [ss])
                (format "{}{}" [converted s])    
            )
        )
    )
    (defun UC_FormatIndex:string (index:decimal)
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
    (defun UC_FormatTokenAmount:string (amount:decimal)
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
    (defun UC_LpFuelToLpStrings:[string] (input-ids:[string] lp-fuel:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (l1:integer (length input-ids))
                (l2:integer (length lp-fuel))
            )
            (enforce (= l1 l2) "Invalid Input Data for making LP Strings")
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (if (!= (at idx lp-fuel) 0.0) 
                        (ref-U|LST::UC_AppL acc 
                            (format "{} from Input to Liquidity Providers: {}" 
                                [
                                    (at idx input-ids) 
                                    (UC_TrimDecimalTrailingZeros (at idx lp-fuel))
                                ]
                            )
                        )
                        acc
                    )
                )
                []
                (enumerate 0 (- (length input-ids) 1))
            )
        )
    )
    (defun UC_FormatDecimals:[string] (input:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL acc (UC_FormatTokenAmount (at idx input)))
                )
                []
                (enumerate 0 (- (length input) 1))
            )
        )
    )
    (defun UC_FormatAccountsShort:[string] (input-accounts:[string])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL acc (ref-I|OURONET::OI|UC_ShortAccount (at idx input-accounts)))
                )
                []
                (enumerate 0 (- (length input-accounts) 1))
            )
        )
    )
    (defun UC_PoolTypeWord:[string] (swpair:string)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-type-word:string
                    (if (= pool-type "S")
                        "Stable"
                        (if (= pool-type "W")
                            "Weigthed"
                            "Product"
                        )
                    )
                )
            )
            [pool-type pool-type-word]
        )
    )
    (defun UCx_NonFungibleNonceExistance:bool (dpdc-id:string nonce:integer existance:bool)
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (x:string (ref-DPDC::UR_NonceHolder dpdc-id false nonce))
            )
            (if (> nonce 0)
                (if existance
                    (!= x BAR)
                    (= x BAR)
                )
                (let
                    (
                        (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                        (split-data:object{DpdcUdcV1.DPDC|NonceData} (ref-DPDC::UR_SplitNonceData dpdc-id false nonce))
                        (znd:object{DpdcUdcV1.DPDC|NonceData} (ref-DPDC-UDC::UDC_ZeroNonceData))
                    )
                    (if existance
                        (!= split-data znd)
                        (= split-data znd)
                    )
                )
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_TrueFungibleAmountPrice:decimal (id:string amount:decimal price:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (idp:integer (ref-DPTF::UR_Decimals id))
            )
            (floor (* amount price) idp)
        )
    )
    (defun URC_PrimordialIDs:[string] ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (ignis:string (ref-DALOS::UR_IgnisID))
                (auryn:string (ref-DALOS::UR_AurynID))
                (elite-auryn:string (ref-DALOS::UR_EliteAurynID))
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
            )
            [ouro ignis auryn elite-auryn wstoa sstoa]
        )
    )
    (defun URC_PrimordialPrices:[decimal] ()
        @doc "Returns the Prices for Ouronet Primordial Tokens \
        \ [WSTOA SSTOA OURO AURYN ELITEAURYN]"
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                ;;
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (p-ids:[string] (URC_PrimordialIDs))
                (ouro:string (at 0 p-ids))
                (ignis:string (at 1 p-ids))
                (auryn:string (at 2 p-ids))
                (elite-auryn:string (at 3 p-ids))
                (wstoa:string (at 4 p-ids))
                (sstoa:string (at 5 p-ids))
                ;;
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (auryn:string (ref-DALOS::UR_AurynID))
                (elite-auryn:string (ref-DALOS::UR_EliteAurynID))
                ;;
                (auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken auryn)))
                (elite-auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken elite-auryn)))
                (auryndex-value:decimal (ref-ATS::URC_Index auryndex))
                (elite-auryndex-value:decimal (ref-ATS::URC_Index elite-auryndex))
                ;;
                (dollar-ouro:decimal (ref-SWPI::URC_OuroPrimordialPrice))
                (dollar-ignis:decimal 0.01)
                (dollar-auryn:decimal (floor (* auryndex-value dollar-ouro) 24))
                (dollar-elite-auryn:decimal (floor (* elite-auryndex-value dollar-auryn) 24))
                (dollar-wstoa:decimal (ref-SWPI::URC_TokenDollarPrice wstoa stoa-pid))
                (dollar-sstoa:decimal (ref-SWPI::URC_TokenDollarPrice sstoa stoa-pid))
            )
            [dollar-ouro dollar-ignis dollar-auryn dollar-elite-auryn dollar-wstoa dollar-sstoa]
        )
    )
    (defun URC_StoaCollectionReceivers:[string] ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (r1:string (ref-DALOS::UR_AccountStoa (at 2 (ref-DALOS::UR_DemiurgoiID))))
                (r2:string (ref-DALOS::UR_AccountStoa (ref-DALOS::GOV|DALOS|SC_NAME)))
                (r3:string (ref-DALOS::UR_AccountStoa (at 1 (ref-DALOS::UR_DemiurgoiID))))
                (r4:string (ref-DALOS::UR_AccountStoa (ref-DALOS::GOV|OUROBOROS|SC_NAME)))
            )
            [r1 r2 r3 r4]
        )
    )
    (defun URC_SplitStoaPriceForReceivers (price:decimal)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (kp:integer (ref-U|CT::CT_STOA_PRECISION))
                (receivers:[string] (URC_StoaCollectionReceivers))
                (prices:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit price kp))
            )
            {"10%-r"    : (at 0 receivers)
            ,"20%-r"    : (at 1 receivers)
            ,"30%-r"    : (at 2 receivers)
            ,"40%-r"    : (at 3 receivers)
            ,"10%-p"    : (at 0 prices)
            ,"20%-p"    : (at 1 prices)
            ,"30%-p"    : (at 2 prices)
            ,"40%-p"    : (at 3 prices)}
        )
    )
    (defun URC_ReverseSwapOutputAmount:decimal (swpair:string output-id:string promille:decimal)
        @doc "Computes an UI allowed <output-id> amount as a <promille> relative to its total <swpair> supply"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (output-id-supply:decimal (ref-SWP::UR_PoolTokenSupply swpair output-id))
                (output-id-prec:integer (ref-DPTF::UR_Decimals output-id))
            )
            (floor (* (/ promille 1000.0) output-id-supply) output-id-prec)
        )
    )
    (defun URC_SWPairCoreRead (swpair:string)
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                ;;
                (ptp:[string] (UC_PoolTypeWord swpair))
                (glsb:bool (ref-SWP::UR_LiquidBoost))
                (lp-fee:decimal (ref-SWP::UR_FeeLP swpair))
                (pool-value:[decimal] (ref-SWPI::URC_PoolValue swpair))
                (pool-value-in-dwk:decimal (at 0 pool-value))
                (lp-value-in-dwk:decimal (at 1 pool-value))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
            )
            {"pool-type"                        : (at 0 ptp)
            ,"pool-type-word"                   : (at 1 ptp)
            ,"pool-token-supplies"              : (ref-SWP::UR_PoolTokenSupplies swpair)
            ,"lp-supply"                        : (ref-SWP::URC_LpCapacity swpair)
            ,"lp-fee"                           : lp-fee
            ,"liquid-fee"                       : (if glsb lp-fee 0.0)
            ,"special-fee-targets"              : (ref-SWP::UR_SpecialFeeTargets swpair)
            ,"pool-value-in-dwk"                : pool-value-in-dwk
            ,"lp-value-in-dwk"                  : lp-value-in-dwk
            ,"pool-value-pid"                   : (UC_ConvertPrice (* pool-value-in-dwk stoa-pid))
            ,"lp-value-pid"                     : (UC_ConvertPrice (* lp-value-in-dwk stoa-pid))
            }
        )
    )
    (defun URC_MaxRecoveryAmount:decimal (ats:string recoverer:string)
        @doc "Elite Auryn only: max RBT that can be cold-recovered. \
            \ Uses occupied-position count: if n positions are occupied, you need tier (n+1) to have one free; \
            \ max uncoil = supply - threshold_for_tier(n+1). Returns 0.0 if not Elite EA pool."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (elite:bool (ref-ATS::UR_EliteMode ats))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (iz-ea:bool (= c-rbt ea-id))
            )
            (if (and elite iz-ea)
                (let
                    (
                        (supply:decimal (ref-DPTF::UR_AccountSupply c-rbt recoverer))
                        (met:integer (ref-DALOS::UR_Elite-Tier-Major recoverer))
                        (pstate:[integer] (ref-ATS::URCx_PSL ats recoverer))
                        (slots-in-use:[integer] (take met pstate))
                        (occupied-count:integer
                            (fold
                                (lambda (acc:integer st:integer)
                                    (if (= st 0) (+ acc 1) acc)
                                )
                                0
                                slots-in-use
                            )
                        )
                        (required-tier:integer (+ occupied-count 1))
                        (thresholds:[decimal] (ref-U|CT::CT_ET))
                    )
                    (if (> required-tier 7)
                        0.0
                        (let
                            (
                                (threshold-index:integer (+ (* (- required-tier 1) 7) 1))
                                (must-remain:decimal (at threshold-index thresholds))
                                (candidate:decimal (- supply must-remain))
                            )
                            (if (< candidate 0.0)
                                0.0
                                candidate
                            )
                        )
                    )
                )
                0.0
            )
        )
    )
    ;;
    (defun URC_0001_HeaderV3 (account:string)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-ELITE:module{EliteV1} ELITE)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                ;;
                (IgnisID:string "GAS-8Nh-JO8JO4F5")
                (OuroID:string "OURO-8Nh-JO8JO4F5")
                (AurynID:string "AURYN-8Nh-JO8JO4F5")
                (EAurynID:string "ELITEAURYN-8Nh-JO8JO4F5")
                (WstoaID:string "WSTOA-8Nh-JO8JO4F5")
                (SstoaID:string "SSTOA-8Nh-JO8JO4F5")
                (PstoaID:string "GSTOA-8Nh-JO8JO4F5")
                (HpstoaID:string "H|GSTOA-8Nh-JO8JO4F5")
                ;;
                (Auryndex:string "Auryndex-O136CBn22ncY")
                (EAuryndex:string "EliteAuryndex-O136CBn22ncY")
                (LiquidIndex:string "SilverStoaPillar-O136CBn22ncY")
                (KoriIndex:string "GoldenStoaPillar-O136CBn22ncY")
                ;;
                (ih-auryndex:decimal (ref-ATS::URC_Index Auryndex))
                (ih-elite-auryndex:decimal (ref-ATS::URC_Index EAuryndex))
                (ih-liquid:decimal (ref-ATS::URC_Index LiquidIndex))
                (ih-kori:decimal (ref-ATS::URC_Index KoriIndex))
                ;;
                (price-ouro:decimal (ref-SWPI::URC_OuroPrimordialPrice))
                (price-auryn:decimal (floor (* price-ouro ih-auryndex) 24))
                (price-elite-auryn:decimal (floor (* price-auryn ih-elite-auryndex) 24))
                (price-wstoa:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (price-sstoa:decimal (floor (* price-wstoa ih-liquid) 24))
                (price-gstoa:decimal (floor (* price-sstoa ih-kori) 24))
                ;;
                (total-elite-aurynz:decimal (ref-ELITE::URC_EliteAurynzSupply account))
                (et:[decimal] (ref-U|CT::CT_ET))
                (et-last:decimal (at (- (length et) 1) et))
                (elite-aurynz-next:decimal
                    (if (>= total-elite-aurynz et-last)
                        0.0
                        (-
                            (fold
                                (lambda
                                    (acc:decimal tier:decimal)
                                    (if (and (> tier total-elite-aurynz) (< tier acc))
                                        tier
                                        acc
                                    )
                                )
                                et-last
                                et
                            )
                            total-elite-aurynz
                        )
                    )
                )
                
                (ouro-next:decimal (floor (fold (*) 1.0 [elite-aurynz-next ih-auryndex ih-elite-auryndex]) 24))
                (price-next:decimal (floor (* price-ouro ouro-next) 24))
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
            ;;Zone 1
            {"z1-t1"                            : (ref-DALOS::UR_Elite-Name account)
            ,"z1-v1"                            : (ref-DALOS::UR_Elite-Tier account)
            ,"z1-t2"                            : "Total Ξ₳"
            ,"z1-v2"                            : (UC_FormatTokenAmount total-elite-aurynz)
            ,"z1-t3"                            : "Ξ₳ for Next Tier"
            ,"z1-v3"                            : (UC_FormatTokenAmount elite-aurynz-next)
            ,"z1-t4"                            : "OURO for Next Tier"
            ,"z1-v4"                            : (UC_FormatTokenAmount ouro-next)
            ,"z1-t5"                            : "$ for Next Tier"
            ,"z1-v5"                            : (UC_ConvertPrice price-next)
            ;;Zone 2
            ,"z2-t1"                            : (ref-ATS::UR_IndexName Auryndex)
            ,"z2-v1"                            : (UC_FormatIndex ih-auryndex)
            ,"z2-t2"                            : (ref-ATS::UR_IndexName EAuryndex)
            ,"z2-v2"                            : (UC_FormatIndex ih-elite-auryndex)
            ,"z2-t3"                            : (ref-ATS::UR_IndexName LiquidIndex)
            ,"z2-v3"                            : (UC_FormatIndex ih-liquid)
            ,"z2-t4"                            : (ref-ATS::UR_IndexName KoriIndex)
            ,"z2-v4"                            : (UC_FormatIndex ih-kori)
            ,"z2-t5"                            : (format "{} Global Nonces:" [HpstoaID])
            ,"z2-v5"                            : (ref-DPOF::UR_NoncesUsed HpstoaID)
            ;;Zone 3
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
            ;;Zone 4
            ,"z4-t1"                            : "IGNIS"
            ,"z4-v1"                            : (UC_ConvertPrice 0.01)
            ,"z4-t2"                            : "OURO"
            ,"z4-v2"                            : (UC_ConvertPrice price-ouro)
            ,"z4-t3"                            : "AURYN / ELITEAURYN"
            ,"z4-v3"                            : (format "{} / {}" [(UC_ConvertPrice price-auryn) (UC_ConvertPrice price-elite-auryn)])
            ,"z4-t4"                            : "STOA"
            ,"z4-v4"                            : (UC_ConvertPrice price-wstoa)
            ,"z4-t5"                            : "SSTOA / GSTOA"
            ,"z4-v5"                            : (format "{} / {}" [(UC_ConvertPrice price-sstoa) (UC_ConvertPrice price-gstoa)])
            ;;
            ;;Resident Ignis
            ,"resident-ignis"                   : (UC_FormatTokenAmount (ref-DALOS::UR_TF_AccountSupply account false))
            }
        )
    )
    (defun URC_0002_Primordials (current-account:string codex-accounts:[string])
        [(URC_0002_PrimordialsSingle current-account) (URC_0002_PrimordialsMulti codex-accounts)]
    )
    (defun URC_0002_PrimordialsMulti (codex-accounts:[string])
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (codex-supplies:[decimal]
                    (map
                        (lambda
                            (index:integer)
                            (ref-DALOS::UR_TF_AccountSupply (at index codex-accounts) false)
                        )
                        (enumerate 0 (- (length codex-accounts) 1))
                    )
                )
                (ignis-codex-supply:decimal (fold (+) 0.0 codex-supplies))
                (dollar-ignis:decimal 0.01)
                (ignis-codex-supply-value:decimal (URC_TrueFungibleAmountPrice ignis-id ignis-codex-supply dollar-ignis))
            )
            {"codex-balance"                    : (UC_FormatTokenAmount ignis-codex-supply)
            ,"codex-balance-hover"              : ignis-codex-supply
            ,"codex-balance-vid"                : (UC_ConvertPrice ignis-codex-supply-value)}
        )
    )
    (defun URC_0002_PrimordialsSingle (account:string)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-ELITE:module{EliteV1} ELITE)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-ATS:module{AutostakeV2} ATS)
                ;;
                (p-ids:[string] (URC_PrimordialIDs))
                (pp:[decimal] (URC_PrimordialPrices))
                ;;
                (ouro-id:string (at 0 p-ids))
                (ignis-id:string (at 1 p-ids))
                (auryn-id:string (at 2 p-ids))
                (elite-auryn-id:string (at 3 p-ids))
                (wstoa-id:string (at 4 p-ids))
                (sstoa-id:string (at 5 p-ids))
                (gstoa-id:string (ref-DALOS::UR_GoldenStoaID))
                (hgstoa-id:string (ref-DPTF::UR_Hibernation gstoa-id))
                (wurstoa-id:string (ref-DALOS::UR_UrStoaID))
                ;;
                (p0:decimal (at 0 pp))
                (p1:decimal (at 1 pp))
                (p2:decimal (at 2 pp))
                (p3:decimal (at 3 pp))
                (p4:decimal (at 4 pp))
                (p5:decimal (at 5 pp))
                (golden-stoa-pillar:string (at 0 (ref-DPTF::UR_RewardToken sstoa-id)))
                (golden-stoa-pillar-value:decimal (ref-ATS::URC_Index golden-stoa-pillar))
                (p6:decimal (floor (* p5 golden-stoa-pillar-value) 24))
                ;;
                (wallet-ouro:decimal (ref-DPTF::UR_AccountSupply ouro-id account))
                (wallet-ouro-value:decimal (URC_TrueFungibleAmountPrice ouro-id wallet-ouro p0))
                (wallet-vouro:decimal (ref-TFT::URC_VirtualOuro account))
                (wallet-vouro-value:decimal (URC_TrueFungibleAmountPrice ouro-id wallet-vouro p0))
                (wallet-douro:decimal (abs (ref-TFT::URC_MinimumOuro account)))
                (wallet-douro-value:decimal (URC_TrueFungibleAmountPrice ouro-id wallet-douro p0))
                (ouro-supply:decimal (ref-DPTF::UR_Supply ouro-id))
                (ouro-supply-value:decimal (URC_TrueFungibleAmountPrice ouro-id ouro-supply p0))
                ;;
                (wallet-gas:decimal (ref-DPTF::UR_AccountSupply ignis-id account))
                (wallet-gas-value:decimal (URC_TrueFungibleAmountPrice ignis-id wallet-gas p1))
                (gas-supply:decimal (ref-DPTF::UR_Supply ignis-id))
                (gas-supply-value:decimal (URC_TrueFungibleAmountPrice ignis-id gas-supply p1))
                (ignis-discount:decimal (ref-DALOS::URC_IgnisGasDiscount account))
                (ignis-discount-text:string
                    (format 
                        "IGNIS Discount {}% (You pay only {}% of IGNIS costs)"
                        [(* (- 1.0 ignis-discount) 100.0) (* ignis-discount 100.0)]
                    )
                )
                (stoa-discount:decimal (ref-DALOS::URC_StoaGasDiscount account))
                (stoa-discount-text:string
                    (format 
                        "STOA Discount {}% (You pay only {}% of STOA costs)"
                        [(* (- 1.0 stoa-discount) 100.0) (* stoa-discount 100.0)]
                    )
                )
                ;;
                (wallet-auryn:decimal (ref-DPTF::UR_AccountSupply auryn-id account))
                (wallet-auryn-value:decimal (URC_TrueFungibleAmountPrice auryn-id wallet-auryn p2))
                (auryn-supply:decimal (ref-DPTF::UR_Supply auryn-id))
                (auryn-supply-value:decimal (URC_TrueFungibleAmountPrice auryn-id auryn-supply p2))
                ;;
                (wallet-eauryn:decimal (ref-DPTF::UR_AccountSupply elite-auryn-id account))
                (wallet-eauryn-value:decimal (URC_TrueFungibleAmountPrice elite-auryn-id wallet-eauryn p3))
                (eauryn-supply:decimal (ref-DPTF::UR_Supply elite-auryn-id))
                (eauryn-supply-value:decimal (URC_TrueFungibleAmountPrice elite-auryn-id eauryn-supply p3))
                ;;
                (wsh-elite-aurynz:decimal (ref-ELITE::URC_EliteAurynzSupply account))
                (et:[decimal] (ref-U|CT::CT_ET))
                (et-last:decimal (at (- (length et) 1) et))
                (wsh-elite-aurynz-next:decimal
                    (if (>= wsh-elite-aurynz et-last)
                        0.0
                        (-
                            (fold
                                (lambda
                                    (acc:decimal tier:decimal)
                                    (if (and (> tier wsh-elite-aurynz) (< tier acc))
                                        tier
                                        acc
                                    )
                                )
                                et-last
                                et
                            )
                            wsh-elite-aurynz
                        )
                    )
                )
                (eauryn-next-value:decimal (URC_TrueFungibleAmountPrice elite-auryn-id wsh-elite-aurynz-next p3))
                ;;
                (wallet-wurstoa:decimal (ref-DPTF::UR_AccountSupply wurstoa-id account))
                (ref-coin:module{stoa-ns.stoic-fungible-v1} coin)
                (ref-urcoin:module{stoa-ns.ur-stoic-fungible-v1} coin)
                (payment-key:string (ref-DALOS::UR_AccountStoa account))
                (urstoa-vault-earnings:decimal (coin.URC_URV|ClaimableRewards payment-key))
                (urstoa-vault:string "c:GjYbBFM0vxMs5FcmnFUW-LFoycd3Ef8wuP28vR6FG3k")
                (urstoa-vault-stoa-supply:decimal (ref-coin::UR_Balance urstoa-vault))
                ;;
                (wallet-stoa:decimal (try 0.0 (ref-coin::UR_Balance payment-key)))
                (wallet-stoa-value:decimal (URC_TrueFungibleAmountPrice wstoa-id wallet-stoa p4))
                (wallet-wstoa:decimal (ref-DPTF::UR_AccountSupply wstoa-id account))
                (wallet-wstoa-value:decimal (URC_TrueFungibleAmountPrice wstoa-id wallet-wstoa p4))
                (wstoa-supply:decimal (ref-DPTF::UR_Supply wstoa-id))
                (wstoa-supply-value:decimal (URC_TrueFungibleAmountPrice wstoa-id wstoa-supply p4))
                ;;
                (wallet-sstoa:decimal (ref-DPTF::UR_AccountSupply sstoa-id account))
                (wallet-sstoa-value:decimal (URC_TrueFungibleAmountPrice sstoa-id wallet-sstoa p5))
                (sstoa-supply:decimal (ref-DPTF::UR_Supply sstoa-id))
                (sstoa-supply-value:decimal (URC_TrueFungibleAmountPrice sstoa-id sstoa-supply p5))
                (gstoa-supply:decimal (ref-DPTF::UR_Supply gstoa-id))
                (gstoa-supply-value:decimal (URC_TrueFungibleAmountPrice gstoa-id gstoa-supply p6))
                ;;
                (wallet-gstoa:decimal (ref-DPTF::UR_AccountSupply gstoa-id account))
                (wallet-gstoa-value:decimal (URC_TrueFungibleAmountPrice gstoa-id wallet-gstoa p6))
                (wallet-hgstoa:decimal (ref-DPOF::UR_AccountSupply hgstoa-id account))
                (wallet-hgstoa-value:decimal (URC_TrueFungibleAmountPrice gstoa-id wallet-hgstoa p6))
                (wallet-hgstoa-nonces-count:integer (length (ref-DPOF::URH_AccountNonces account hgstoa-id)))
                (wallet-gstoa-total:decimal (+ wallet-gstoa wallet-hgstoa))
                (wallet-gstoa-total-value:decimal (URC_TrueFungibleAmountPrice gstoa-id wallet-gstoa-total p6))
                ;;
                (core-total-value:decimal (fold (+) 0.0 [wallet-gas-value wallet-auryn-value wallet-eauryn-value wallet-stoa-value wallet-wstoa-value wallet-sstoa-value wallet-gstoa-total-value]))
                (with-ouro-value:decimal (+ core-total-value wallet-ouro-value))
                (with-vouro-value:decimal (+ with-ouro-value wallet-douro-value))
            )
            ;;Ouro Cardboard
            {"ouro-id"                          : ouro-id
            ,"ouro-name"                        : (ref-DPTF::UR_Name ouro-id)
            ,"ouro-price"                       : (UC_ConvertPrice p0)
            ,"ouro-balance"                     : (UC_FormatTokenAmount wallet-ouro)
            ,"ouro-balance-hover"               : wallet-ouro
            ,"ouro-balance-vid"                 : (UC_ConvertPrice wallet-ouro-value)
            ,"ouro-v-balance"                   : (UC_FormatTokenAmount wallet-vouro)
            ,"ouro-v-balance-hover"             : wallet-vouro
            ,"ouro-v-balance-vid"               : (UC_ConvertPrice wallet-vouro-value)
            ,"ouro-dispo-capacity"              : (UC_FormatTokenAmount wallet-douro)
            ,"ouro-dispo-capacity-hover"        : wallet-douro
            ,"ouro-dispo-capacity-vid"          : (UC_ConvertPrice wallet-douro-value)
            ,"ouro-supply"                      : (UC_FormatTokenAmount ouro-supply)
            ,"ouro-supply-hover"                : ouro-supply
            ,"ouro-supply-vid"                  : (UC_ConvertPrice ouro-supply-value)
            ;;Ignis Cardboard
            ,"gas-id"                           : ignis-id
            ,"gas-name"                         : (ref-DPTF::UR_Name ignis-id)
            ,"gas-price"                        : (UC_ConvertPrice p1)
            ,"gas-balance"                      : (UC_FormatTokenAmount wallet-gas)
            ,"gas-balance-hover"                : wallet-gas
            ,"gas-balance-vid"                  : (UC_ConvertPrice wallet-gas-value)
            ,"gas-supply"                       : (UC_FormatTokenAmount gas-supply)
            ,"gas-supply-hover"                 : gas-supply
            ,"gas-supply-vid"                   : (UC_ConvertPrice gas-supply-value)
            ,"gas-discount-text"                : ignis-discount-text
            ;;Auryn Cardboard
            ,"auryn-id"                         : auryn-id
            ,"auryn-name"                       : (ref-DPTF::UR_Name auryn-id)
            ,"auryn-price"                      : (UC_ConvertPrice p2)
            ,"auryn-balance"                    : (UC_FormatTokenAmount wallet-auryn)
            ,"auryn-balance-hover"              : wallet-auryn
            ,"auryn-balance-vid"                : (UC_ConvertPrice wallet-auryn-value)
            ,"auryn-supply"                     : (UC_FormatTokenAmount auryn-supply)
            ,"auryn-supply-hover"               : auryn-supply
            ,"auryn-supply-vid"                 : (UC_ConvertPrice auryn-supply-value)
            ;;EliteAuryn
            ,"eauryn-id"                        : elite-auryn-id
            ,"eauryn-name"                      : (ref-DPTF::UR_Name elite-auryn-id)
            ,"eauryn-price"                     : (UC_ConvertPrice p3)
            ,"eauryn-balance"                   : (UC_FormatTokenAmount wallet-eauryn)
            ,"eauryn-balance-hover"             : wallet-eauryn
            ,"eauryn-balance-vid"               : (UC_ConvertPrice wallet-eauryn-value)
            ,"eauryn-next"                      : (UC_FormatTokenAmount wsh-elite-aurynz-next)
            ,"eauryn-next-hover"                : wsh-elite-aurynz-next
            ,"eauryn-next-vid"                  : (UC_ConvertPrice eauryn-next-value)
            ,"eauryn-supply"                    : (UC_FormatTokenAmount eauryn-supply)
            ,"eauryn-supply-hover"              : eauryn-supply
            ,"eauryn-supply-vid"                : (UC_ConvertPrice eauryn-supply-value)
            ;;UrStoa
            ,"urstoa-payment-key-balance"       : (try 0.0 (ref-urcoin::UR_UR|Balance payment-key))
            ,"urstoa-vault-balance"             : (coin.UR_URV|UserSupply payment-key)
            ,"urstoa-vault-earnings"            : (UC_FormatTokenAmount urstoa-vault-earnings)
            ,"urstoa-vault-earning-hover"       : urstoa-vault-earnings
            ,"urstoa-vault-stoa-supply"         : (UC_FormatTokenAmount urstoa-vault-stoa-supply)
            ,"urstoa-vault-stoa-supply-hover"   : urstoa-vault-stoa-supply
            ,"urstoa-wrapped-balance"           : wallet-wurstoa
            ,"urstoa-wrapped-id"                : wurstoa-id
            ;;WrappedStoa
            ,"wstoa-id"                         : wstoa-id
            ,"wstoa-name"                       : (ref-DPTF::UR_Name wstoa-id)
            ,"wstoa-price"                      : (UC_ConvertPrice p4)
            ,"wstoa-native-balance"             : (UC_FormatTokenAmount wallet-stoa)
            ,"wstoa-native-balance-hover"       : wallet-stoa
            ,"wstoa-native-balance-vid"         : (UC_ConvertPrice wallet-stoa-value)
            ,"wstoa-wrapped-balance"            : (UC_FormatTokenAmount wallet-wstoa)
            ,"wstoa-wrapped-balance-hover"      : wallet-wstoa
            ,"wstoa-wrapped-balance-vid"        : (UC_ConvertPrice wallet-wstoa-value)
            ,"wstoa-wrapped-total-supply"       : (UC_FormatTokenAmount wstoa-supply)
            ,"wstoa-wrapped-total-supply-hover" : wstoa-supply
            ,"wstoa-wrapped-total-supply-vid"   : (UC_ConvertPrice wstoa-supply-value)
            ,"stoa-discount-text"               : stoa-discount-text
            ;;SilverStoa
            ,"sstoa-id"                         : sstoa-id
            ,"sstoa-name"                       : (ref-DPTF::UR_Name sstoa-id)
            ,"sstoa-price"                      : (UC_ConvertPrice p5)
            ,"sstoa-balance"                    : (UC_FormatTokenAmount wallet-sstoa)
            ,"sstoa-balance-hover"              : wallet-sstoa
            ,"sstoa-balance-vid"                : (UC_ConvertPrice wallet-sstoa-value)
            ,"sstoa-supply"                     : (UC_FormatTokenAmount sstoa-supply)
            ,"sstoa-supply-hover"               : sstoa-supply
            ,"sstoa-supply-vid"                 : (UC_ConvertPrice sstoa-supply-value)
            ,"gstoa-supply"                     : (UC_FormatTokenAmount gstoa-supply)
            ,"gstoa-supply-hover"               : gstoa-supply
            ,"gstoa-supply-vid"                 : (UC_ConvertPrice gstoa-supply-value)
            ;;GoldenStoa
            ,"gstoa-id"                         : gstoa-id
            ,"hgstoa-id"                        : hgstoa-id
            ,"gstoa-name"                       : (ref-DPTF::UR_Name gstoa-id)
            ,"gstoa-price"                      : (UC_ConvertPrice p6)
            ,"gstoa-balance"                    : (UC_FormatTokenAmount wallet-gstoa)
            ,"gstoa-balance-hover"              : wallet-gstoa
            ,"gstoa-balance-vid"                : (UC_ConvertPrice wallet-gstoa-value)
            ,"hgstoa-balance-nonces"            : (format "{} ({})" [(UC_FormatTokenAmount wallet-hgstoa) wallet-hgstoa-nonces-count])
            ,"hgstoa-balance-nonces-hover"      : (format "Exactly {} Hibernated GoldenStoa over {} {}" [wallet-hgstoa wallet-hgstoa-nonces-count (if (= 1 wallet-hgstoa-nonces-count) "single Nonce" "Nonces")])
            ,"hgstoa-balance-nonces-vid"        : (UC_ConvertPrice wallet-hgstoa-value)
            ,"gstoa-total-balance"              : (UC_FormatTokenAmount wallet-gstoa-total)
            ,"gstoa-total-balance-hover"        : wallet-gstoa-total
            ,"gstoa-total-balance-vid"          : (UC_ConvertPrice wallet-gstoa-total-value)
            ;;Header
            ,"total-value"                      : (UC_ConvertPrice with-ouro-value)
            ,"total-value-with-vouro"           : (UC_ConvertPrice with-vouro-value)
            }
        )
    )
    (defun URC_0003_SWPairGeneralInfo ()
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
                (glsb:bool (ref-SWP::UR_LiquidBoost))
                (glsb-word:string (if glsb "ON" "OFF"))
                (asm:bool (ref-SWP::UR_Asymetric))
                (asm-word:string (if asm "ON" "OFF"))
                (pools:[string] (ref-SWP::URC_Swpairs))
                (number-of-pools:integer (length pools))
            )   
            {"global-liquid-staking-boost"      : glsb
            ,"global-liquid-staking-boost-word" : glsb-word
            ,"asymmetric"                       : asm
            ,"asymmetric-word"                  : asm-word
            ;;
            ,"pools"                            : pools
            ,"number-of-pools"                  : number-of-pools
            }
        )
    )
    (defun URC_0004_SWPairDashboardInfo (swpair:string)
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (core:object (URC_SWPairCoreRead swpair))
                (pool-token-supplies:[decimal] (at "pool-token-supplies" core))
                (lp-supply:decimal (at "lp-supply" core))
                (special-fee-targets:[string] (at "special-fee-targets" core))
                (pool-value-in-dwk:decimal (at "pool-value-in-dwk" core))
                (lp-value-in-dwk:decimal (at "lp-value-in-dwk" core))
            )
            ;;Dollar Values
            {"tvl-in-$"                         : (at "pool-value-pid" core)
            ,"lp-value-in-$"                    : (at "lp-value-pid" core)
            ;;Values and Token Values
            ,"pool-token-supplies"              : pool-token-supplies
            ,"lp-supply"                        : lp-supply
            ,"pool-value-in-dwk"                : pool-value-in-dwk
            ,"lp-value-in-dwk"                  : lp-value-in-dwk
            ,"weigths"                          : (ref-SWP::UR_Weigths swpair)
            ,"special-fee-targets-proportions"  : (ref-SWP::UR_SpecialFeeTargetsProportions swpair)
            ,"total-fee"                        : (ref-SWP::URC_PoolTotalFee swpair)
            ,"lp-fee"                           : (at "lp-fee" core)
            ,"liquid-fee"                       : (at "liquid-fee" core)
            ,"special-fee"                      : (ref-SWP::UR_FeeSP swpair)
            ;;Formated Token Values
            ,"ft-pool-token-supplies"           : (UC_FormatDecimals pool-token-supplies)
            ,"ft-lp-supply"                     : (UC_FormatTokenAmount lp-supply)
            ,"ft-pool-value-in-dwk"             : (UC_FormatTokenAmount pool-value-in-dwk)
            ,"ft-lp-value-in-dwk"               : (UC_FormatTokenAmount lp-value-in-dwk)
            ;;String Values
            ,"pool-tokens"                      : (ref-SWP::UR_PoolTokens swpair)
            ,"pool-type"                        : (at "pool-type" core)
            ,"pool-type-word"                   : (at "pool-type-word" core)
            ,"special-fee-targets"              : special-fee-targets
            ,"special-fee-targets-short"        : (UC_FormatAccountsShort special-fee-targets)
            }
        )
    )
    (defun URC_0005_SWPairMultiDashboardInfo (swpairs:[string])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[object] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (URC_0004_SWPairDashboardInfo (at idx swpairs))
                    )
                )
                []
                (enumerate 0 (- (length swpairs) 1))
            )
        )
    )
    (defun URC_0006b_DirectSwap:decimal
        (account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string)
        @doc "Computes the <o-id-netto> of a Direct Pool Swap"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                ;;
                (dsid:object{UtilitySwpV1.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id)
                )
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (fees:object{UtilitySwpV1.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (input-positions:[integer] (ref-SWPI::URC_PoolTokenPositions swpair input-ids))
                (output-position:integer (ref-SWP::UR_PoolTokenPosition swpair output-id))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
                ;;
                (dtso:object{UtilitySwpV1.DirectTaxedSwapOutput}
                    (ref-SWPI::UC_BareboneSwapWithFeez account pool-type dsid fees A X X-prec input-positions output-position W)
                )
            )
            (at "o-id-netto" dtso)
        )
    )
    (defun URC_0007b_InverseSwap:decimal
        (account:string swpair:string output-id:string output-amount:decimal input-id:string)
        @doc "Computes the <i-id-brutto> of an Inverse Pool Swap"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                ;;
                (rsid:object{UtilitySwpV1.ReverseSwapInputData}
                    (ref-U|SWP::UDC_ReverseSwapInputData
                        output-id output-amount input-id
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (fees:object{UtilitySwpV1.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (input-position:integer (ref-SWP::UR_PoolTokenPosition swpair input-id))
                (output-position:integer (ref-SWP::UR_PoolTokenPosition swpair output-id))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
                ;;Do Inverse Swap Computation and Unwrap Object Data
                (itso:object{UtilitySwpV1.InverseTaxedSwapOutput}
                    (ref-SWPI::UC_InverseBareboneSwapWithFeez
                        account pool-type rsid fees A X X-prec output-position input-position W
                    )
                )
            )
            (at "i-id-brutto" itso)
        )
    )
    (defun URC_0008a_TrueFungibleEntry (account:string dptf:string)
        @doc "Supports native DPTFs, Frozen DPTFs, and Reserved DPTFs"
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (dptf-id:string (ref-DPTF::URC_Parent dptf))
                (wallet-supply:decimal (ref-DPTF::UR_AccountSupply dptf account))
                (dptf-supply:decimal (ref-DPTF::UR_Supply dptf))
                ;;
                (token-worth-in-dollarz:decimal
                    (if (= dptf-id ignis-id)
                        0.01
                        (ref-SWPI::URC_TokenDollarPrice dptf-id stoa-pid)
                    )
                )
                (token-worth-in-stoa:decimal
                    (if (= dptf-id ignis-id)
                        (/ 0.01 stoa-pid)
                        (if (= token-worth-in-dollarz 0.0)
                            0.0
                            (ref-SWPI::URC_SingleWorthWSTOA dptf-id)
                        )
                    )
                )
                (wallet-worth-in-stoa:decimal (floor (* wallet-supply token-worth-in-stoa) 12))
                (wallet-worth-in-dollarz:decimal (* wallet-supply token-worth-in-dollarz))

            )
            {"t1"                       : (ref-DPTF::UR_Name dptf)
            ,"t2"                       : dptf
            ;;Data needed for <t3>
            ,"wallet-supply"            : wallet-supply
            ,"dptf-supply"              : dptf-supply
            ;;Data needed for <t4>
            ;;<wallet-supply> above
            ;;Data needed for <t5>
            ,"wallet-worth-in-stoa"     : wallet-worth-in-stoa
            ,"wallet-worth-in-dollarz"  : (UC_ConvertPrice wallet-worth-in-dollarz)
            ;;Data needed for <t6>
            ,"token-worth-in-stoa"      : token-worth-in-stoa
            ,"token-worth-in-dollarz"   : (UC_ConvertPrice token-worth-in-dollarz)
            }
        )
    )
    (defun URC_0008a_TrueFungibleEntryMapper (account:string dptfs:[string])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[object] dptf:string)
                    (ref-U|LST::UC_AppL acc (URC_0008a_TrueFungibleEntry account dptf))
                )
                []
                dptfs
            )
        )
    )
    (defun URC_0008b_TrueFungibleLPEntry (account:string swpair:string iz-native:bool)
        @doc "Supports native and Frozen LPs \
            \ <iz-native=true> reffers to the native DPTF LP \
            \ <iz-native=true> reffers to the frozen DPTF LP"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (lp-id-frozen-counterpart:string (ref-DPTF::UR_Frozen lp-id))
            )
            (if (not iz-native)
                (enforce (!= BAR lp-id-frozen-counterpart) "Frozen LP must be defined for this usage")
                true
            )
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    ;;
                    (lp-id-used:string
                        (if iz-native
                            lp-id
                            lp-id-frozen-counterpart
                        )
                    )
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (wallet-supply:decimal (ref-DPTF::UR_AccountSupply lp-id-used account))
                    (lp-supply:decimal (ref-DPTF::UR_Supply lp-id-used))
                    ;;
                    (pool-value:[decimal] (ref-SWPI::URC_PoolValue swpair))
                    (token-worth-in-stoa:decimal (at 1 pool-value))
                    (token-worth-in-dollarz:decimal (* stoa-pid token-worth-in-stoa))
                    (wallet-worth-in-stoa:decimal (floor (* wallet-supply token-worth-in-stoa) 12))
                    (wallet-worth-in-dollarz:decimal (* wallet-supply token-worth-in-dollarz))
    
                )
                {"t1"                       : (ref-DPTF::UR_Name lp-id-used)
                ,"t2"                       : lp-id-used
                ;;Data needed for <t3>
                ,"wallet-supply"            : wallet-supply
                ,"dptf-supply"              : lp-supply
                ;;Data needed for <t4>
                ;;<wallet-supply> above
                ;;Data needed for <t5>
                ,"wallet-worth-in-stoa"     : wallet-worth-in-stoa
                ,"wallet-worth-in-dollarz"  : (UC_ConvertPrice wallet-worth-in-dollarz)
                ;;Data needed for <t6>
                ,"token-worth-in-stoa"      : token-worth-in-stoa
                ,"token-worth-in-dollarz"   : (UC_ConvertPrice token-worth-in-dollarz)
                }
            )
        )
    )
    (defun URC_0008b_TrueFungibleNativeLPMapper (account:string lp-ids:[string])
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
                (swpairs:[string]
                    (map (ref-SWP::UR_GetLpSwpair) lp-ids)
                )
            )
            (map
                (lambda
                    (swpair:string)
                    (URC_0008b_TrueFungibleLPEntry account swpair true)
                )
                swpairs
            )
        )
    )
    (defun URC_0008b_TrueFungibleFrozenLPMapper (account:string lp-ids:[string])
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
                (swpairs:[string]
                    (map (ref-SWP::UR_GetLpSwpair) lp-ids)
                )
            )
            (map
                (lambda
                    (swpair:string)
                    (URC_0008b_TrueFungibleLPEntry account swpair false)
                )
                swpairs
            )
        )
    )
    (defun URC_0009a_OrtoFungibleEntry (account:string dpof-id:string)
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                ;;
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (dptf-id:string (ref-DPOF::URC_Parent dpof-id))
                (wallet-supply:decimal (ref-DPOF::UR_AccountSupply dpof-id account))
                (dpof-supply:decimal (ref-DPOF::UR_Supply dpof-id))
                (dpof-total-nonces:integer (ref-DPOF::UR_NoncesUsed dpof-id))
                (dpof-excluded-nonces:integer (ref-DPOF::UR_NoncesExcluded dpof-id))
                (wallet-nonces:[integer] (ref-DPOF::URH_AccountNonces account dpof-id))
                ;;
                (token-worth-in-dollarz:decimal
                    (ref-SWPI::URC_TokenDollarPrice dptf-id stoa-pid)
                )
                (token-worth-in-stoa:decimal
                    (if (= token-worth-in-dollarz 0.0)
                        0.0
                        (ref-SWPI::URC_SingleWorthWSTOA dptf-id)
                    )
                )
                (wallet-worth-in-stoa:decimal (floor (* wallet-supply token-worth-in-stoa) 12))
                (wallet-worth-in-dollarz:decimal (* wallet-supply token-worth-in-dollarz))
            )
            {"t1"                       : (ref-DPOF::UR_Name dpof-id)
            ,"t2"                       : dpof-id
            ;;Data needed for <t3>
            ,"wallet-supply"            : wallet-supply
            ,"dpof-supply"              : dpof-supply
            ;;Data needed for <t4>
            ;;<wallet-supply> above
            ,"wallet-nonces"            : wallet-nonces
            ,"wallet-nonces-no"         : (length wallet-nonces)
            ;;Data needed for <t5>
            ,"wallet-worth-in-stoa"     : wallet-worth-in-stoa
            ,"wallet-worth-in-dollarz"  : (UC_ConvertPrice wallet-worth-in-dollarz)
            ;;Data needed for <t6>
            ,"token-worth-in-stoa"      : token-worth-in-stoa
            ,"token-worth-in-dollarz"   : (UC_ConvertPrice token-worth-in-dollarz)
            }
        )
    )
    (defun URC_0009a_OrtoFungibleEntryMapper (account:string dpofs:[string])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[object] dpof:string)
                    (ref-U|LST::UC_AppL acc (URC_0009a_OrtoFungibleEntry account dpof))
                )
                []
                dpofs
            )
        )
    )
    (defun URC_0009b_OrtoFungibleLPEntry (account:string swpair:string)
        @doc "Supports sleeping LPs"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (lp-id-sleeping-counterpart:string (ref-DPTF::UR_Sleeping lp-id))
            )
            (enforce (!= BAR lp-id-sleeping-counterpart) "Sleeping LP must be defined for this usage")
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV1} U|CT)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                    ;;
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (wallet-supply:decimal (ref-DPOF::UR_AccountSupply lp-id-sleeping-counterpart account))
                    (lp-supply:decimal(ref-DPOF::UR_Supply lp-id-sleeping-counterpart))
                    (wallet-nonces:[integer] (ref-DPOF::URH_AccountNonces account lp-id-sleeping-counterpart))
                    ;;
                    (pool-value:[decimal] (ref-SWPI::URC_PoolValue swpair))
                    (token-worth-in-stoa:decimal (at 1 pool-value))
                    (token-worth-in-dollarz:decimal (* stoa-pid token-worth-in-stoa))
                    (wallet-worth-in-stoa:decimal (floor (* wallet-supply token-worth-in-stoa) 12))
                    (wallet-worth-in-dollarz:decimal (* wallet-supply token-worth-in-dollarz))
                )
                {"t1"                       : (ref-DPTF::UR_Name lp-id-sleeping-counterpart)
                ,"t2"                       : lp-id-sleeping-counterpart
                ;;Data needed for <t3>
                ,"wallet-supply"            : wallet-supply
                ,"dpof-supply"              : lp-supply
                ;;Data needed for <t4>
                ;;<wallet-supply> above
                ,"wallet-nonces"            : wallet-nonces
                ,"wallet-nonces-no"         : (length wallet-nonces)
                ;;Data needed for <t5>
                ,"wallet-worth-in-stoa"     : wallet-worth-in-stoa
                ,"wallet-worth-in-dollarz"  : (UC_ConvertPrice wallet-worth-in-dollarz)
                ;;Data needed for <t6>
                ,"token-worth-in-stoa"      : token-worth-in-stoa
                ,"token-worth-in-dollarz"   : (UC_ConvertPrice token-worth-in-dollarz)
                }
            )
        )
    )
    (defun URC_0009b_OrtoFungibleSleepingLPMapper (account:string lp-ids:[string])
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
                (swpairs:[string]
                    (map (ref-SWP::UR_GetLpSwpair) lp-ids)
                )
            )
            (map
                (lambda
                    (swpair:string)
                    (URC_0009b_OrtoFungibleLPEntry account swpair)
                )
                swpairs
            )
        )
    )
    (defun URC_0010_SwpairInternalDashboard (swpair:string)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (core:object (URC_SWPairCoreRead swpair))
                (read-pool-token-supplies:[decimal] (at "pool-token-supplies" core))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (pool-token-supplies:[decimal]
                    (map
                        (lambda
                            (idx:integer)
                            (floor (at idx read-pool-token-supplies) (ref-DPTF::UR_Decimals (at idx pool-tokens)))
                        )
                        (enumerate 0 (- (length read-pool-token-supplies) 1))
                    )
                )
                (lp-supply:decimal (at "lp-supply" core))
                (special-fee-targets:[string] (at "special-fee-targets" core))
                (pool-value-in-dwk:decimal (at "pool-value-in-dwk" core))
                (lp-value-in-dwk:decimal (at "lp-value-in-dwk" core))
                ;;
                (genesis-supplies:[decimal] (ref-SWP::UR_PoolGenesisSupplies swpair))
            )
            ;;Dollar Values
            {"tvl-in-$"                         : (at "pool-value-pid" core)
            ,"lp-value-in-$"                    : (at "lp-value-pid" core)
            ;;Values and Token Values
            ,"genesis-supplies"                 : genesis-supplies
            ,"pool-token-supplies"              : pool-token-supplies
            ,"lp-supply"                        : lp-supply
            ,"pool-value-in-dwk"                : pool-value-in-dwk
            ,"lp-value-in-dwk"                  : lp-value-in-dwk
            ,"weigths"                          : (ref-SWP::UR_Weigths swpair)
            ,"genesis-weights"                  : (ref-SWP::UR_GenesisWeigths swpair)
            ,"amplifier"                        : (ref-SWP::UR_Amplifier swpair)
            ,"fee-unlocks"                      : (ref-SWP::UR_FeeUnlocks swpair)
            ,"special-fee-target-proportions"   : (ref-SWP::UR_SpecialFeeTargetsProportions swpair)
            ,"total-fee"                        : (ref-SWP::URC_PoolTotalFee swpair)
            ,"lp-fee"                           : (at "lp-fee" core)
            ,"liquid-fee"                       : (at "liquid-fee" core)
            ,"special-fee"                      : (ref-SWP::UR_FeeSP swpair)
            ;;Formated Token Values
            ,"ft-genesis-supplies"              : (UC_FormatDecimals genesis-supplies)
            ,"ft-pool-token-supplies"           : (UC_FormatDecimals read-pool-token-supplies)
            ,"ft-lp-supply"                     : (UC_FormatTokenAmount lp-supply)
            ,"ft-pool-value-in-dwk"             : (UC_FormatTokenAmount pool-value-in-dwk)
            ,"ft-lp-value-in-dwk"               : (UC_FormatTokenAmount lp-value-in-dwk)
            ;;String Values
            ,"lp-id"                            : (ref-SWP::UR_TokenLP swpair)
            ,"pool-tokens"                      : pool-tokens
            ,"pool-type"                        : (at "pool-type" core)
            ,"pool-type-word"                   : (at "pool-type-word" core)
            ,"primality"                        : (if (ref-SWP::UR_Primality swpair) "Primal" "Standard")
            ,"swapping-enabled"                 : (if (ref-SWP::UR_CanSwap swpair) "ON" "OFF")
            ,"liquidity-enabled"                : (if (ref-SWP::UR_CanAdd swpair) "ON" "OFF")
            ,"frozen-and-sleeping"              : (format "{} | {}" [(if (ref-SWP::UR_IzFrozenLP swpair) "ON" "OFF") (if (ref-SWP::UR_IzSleepingLP swpair) "ON" "OFF")])
            ,"fee-lockup"                       : (if (ref-SWP::UR_FeeLock swpair) "Locked" "Unlocked")
            ,"special-fee-targets"              : special-fee-targets
            ,"special-fee-targets-short"        : (UC_FormatAccountsShort special-fee-targets)
            }
        )
    )
    (defun URC_0011_AccountSuppliesForSwpair (account:string swpair:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (account-pool-tokens-supplies:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (ref-DPTF::UR_AccountSupply (at idx pool-tokens) account)
                            )
                        )
                        []
                        (enumerate 0 (- (length pool-tokens) 1))
                    )
                )
                (virtual-ouro:decimal (ref-TFT::URC_VirtualOuro account))
                (pool-token-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
            )
            {"pool-tokens"                      : pool-tokens
            ,"pool-token-prec"                  : pool-token-prec
            ,"wallet-pool-tokens-supplies"      : account-pool-tokens-supplies
            ,"wallet-virtual-ouro"              : (ref-TFT::URC_VirtualOuro account)
            ,"wallet-ignis"                     : (ref-DALOS::UR_TF_AccountSupply account false)}
        )
    )
    ;;
    (defun URC_0012_RecoveryPrimordial (ats:string account:string)
        (let
            (
                (ref-U|DEC:module{OuronetDecimalsV1} U|DEC)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                ;;
                (toggle-cold:bool (ref-ATS::UR_ToggleColdRecovery ats))
                (toggle-hot:bool (ref-ATS::UR_ToggleHotRecovery ats))
                (toggle-direct:bool (ref-ATS::UR_ToggleDirectRecovery ats))
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (rts:[string] (ref-ATS::UR_RewardTokenList ats))
                (rts-no:integer (length rts))
                (cold-positions:integer (ref-ATS::UR_ColdRecoveryPositions ats))
                (iz-elite:bool (ref-ATS::UR_EliteMode ats))
                (major-tier:integer (ref-DALOS::UR_Elite-Tier-Major account))
                (iz-free-or-seven:bool
                    (if (= cold-positions -1)
                        true false
                    )
                )
                ;;
                (free-positions-data:[object{UtilityAtsV2.Awo}] (try [] (ref-ATS::UR_P0 ats account)))
                (seven-positions-data:[object{UtilityAtsV2.Awo}] (try [] (ref-ATS::UR_P-Seven ats account)))
                (how-many-free-positions:integer (length free-positions-data))
                ;;
                (zr-output:[decimal] (make-list (length (ref-ATS::UR_RewardTokens ats)) 0.0))
                (multi-cull-result (try zr-output (ref-ATSU::URC_MultiCull ats account)))
                (summed-culled-values:[decimal]
                    (if (= (typeof multi-cull-result) "list")
                        multi-cull-result
                        (at "summed-culled-values" multi-cull-result)
                    )
                )
                (zl:[decimal] (make-list rts-no 0.0))
                (cull-values:[decimal]
                    (if iz-free-or-seven
                        summed-culled-values
                        (ref-U|DEC::UC_AddHybridArray
                            (map
                                (lambda
                                    (i:integer)
                                    (try zl (ref-ATSU::URC_SingleCull ats account i))
                                )
                                (enumerate 1 cold-positions)
                            )
                        )
                    )
                )
                (total-to-cull:decimal (fold (+) 0.0 cull-values))
                ;;
                (zr:object{UtilityAtsV2.Awo} (ref-ATS::UDC_MakeZeroUnstakeObject ats))
                (ng:object{UtilityAtsV2.Awo} (ref-ATS::UDC_MakeNegativeUnstakeObject ats))
                ;;
                (default-1:object{UtilityAtsV2.Awo} zr)
                (default-2:object{UtilityAtsV2.Awo} (if (not iz-elite) (if (<= 2 cold-positions ) zr ng) (if (> major-tier 1) zr ng)))
                (default-3:object{UtilityAtsV2.Awo} (if (not iz-elite) (if (<= 3 cold-positions ) zr ng) (if (> major-tier 2) zr ng)))
                (default-4:object{UtilityAtsV2.Awo} (if (not iz-elite) (if (<= 4 cold-positions ) zr ng) (if (> major-tier 3) zr ng)))
                (default-5:object{UtilityAtsV2.Awo} (if (not iz-elite) (if (<= 5 cold-positions ) zr ng) (if (> major-tier 4) zr ng)))
                (default-6:object{UtilityAtsV2.Awo} (if (not iz-elite) (if (<= 6 cold-positions ) zr ng) (if (> major-tier 5) zr ng)))
                (default-7:object{UtilityAtsV2.Awo} (if (not iz-elite) (if (<= 7 cold-positions ) zr ng) (if (> major-tier 6) zr ng)))
                ;;
                (p1-obj:object{UtilityAtsV2.Awo} (try default-1 (ref-ATS::UR_P1-7 ats account 1)))
                (p2-obj:object{UtilityAtsV2.Awo} (try default-2 (ref-ATS::UR_P1-7 ats account 2)))
                (p3-obj:object{UtilityAtsV2.Awo} (try default-3 (ref-ATS::UR_P1-7 ats account 3)))
                (p4-obj:object{UtilityAtsV2.Awo} (try default-4 (ref-ATS::UR_P1-7 ats account 4)))
                (p5-obj:object{UtilityAtsV2.Awo} (try default-5 (ref-ATS::UR_P1-7 ats account 5)))
                (p6-obj:object{UtilityAtsV2.Awo} (try default-6 (ref-ATS::UR_P1-7 ats account 6)))
                (p7-obj:object{UtilityAtsV2.Awo} (try default-7 (ref-ATS::UR_P1-7 ats account 7)))
                ;;
                (iz-button:bool
                    (or
                        (fold (or) false [toggle-cold toggle-hot toggle-direct])
                        (>= total-to-cull 0.0)
                    )
                )
            )
            {"iz-button"                        : iz-button
            ,"toggle-cold"                      : toggle-cold
            ,"toggle-hot"                       : toggle-hot
            ,"toggle-direct"                    : toggle-direct
            ;;
            ,"c-rbt"                            : c-rbt
            ,"rts"                              : rts
            ,"free-position-data"               : free-positions-data
            ;;
            ,"iz-free-or-seven"                 : iz-free-or-seven
            ,"cull-values"                      : cull-values
            ,"how-many-free-positions"          : how-many-free-positions
            ,"elite"                            : iz-elite
            ;;
            ,"p1-obj"                           : p1-obj
            ,"p2-obj"                           : p2-obj
            ,"p3-obj"                           : p3-obj
            ,"p4-obj"                           : p4-obj
            ,"p5-obj"                           : p5-obj
            ,"p6-obj"                           : p6-obj
            ,"p7-obj"                           : p7-obj
            ;;
            ,"pos1-type"                        : (URC_0012b_PosObjSt ats p1-obj)
            ,"pos2-type"                        : (URC_0012b_PosObjSt ats p2-obj)
            ,"pos3-type"                        : (URC_0012b_PosObjSt ats p3-obj)
            ,"pos4-type"                        : (URC_0012b_PosObjSt ats p4-obj)
            ,"pos5-type"                        : (URC_0012b_PosObjSt ats p5-obj)
            ,"pos6-type"                        : (URC_0012b_PosObjSt ats p6-obj)
            ,"pos7-type"                        : (URC_0012b_PosObjSt ats p7-obj)
            }
        )
    )
    (defun URC_0012b_PosObjSt:integer (atspair:string input-obj:object{UtilityAtsV2.Awo})
        @doc "Computes the state of an uncoil positional object, \
            \ to see if it the position it is on can be used for uncoiling \
            \ <-1> = closed; <0> = occupied; <1> = opened"
        (let
            (
                (ref-ATS:module{AutostakeV2} ATS)
                (zero:object{UtilityAtsV2.Awo} (ref-ATS::UDC_MakeZeroUnstakeObject atspair))
                (negative:object{UtilityAtsV2.Awo} (ref-ATS::UDC_MakeNegativeUnstakeObject atspair))
            )
            (if (= input-obj zero)
                1
                (if (= input-obj negative)
                    -1
                    0
                )
            )
        )
    )
    (defun URC_0013_StoaICO (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (dollarz-contributed:decimal (STOAICO.UR_User1 account))
                (ico-dollarz-contributed:decimal (STOAICO.UR_Global1))
                (discovered-price:decimal (/ ico-dollarz-contributed 10000000))
                (stoa-for-redemption:decimal (floor (* 10000000.0 (/ dollarz-contributed ico-dollarz-contributed)) 12))
                (iz-activated:bool
                    (if 
                        (= 
                            "bool" 
                            (typeof 
                                (try false (ref-DALOS::UR_AccountPublicKey account))
                            )
                        )
                        false 
                        true
                    )
                )
            )
            {"dollarz-contributed"              : dollarz-contributed
            ,"ur-stoa-earned"                   : (STOAICO.UR_User2 account)
            ;;
            ,"urstoa-left"                      : (STOAICO.UR_Global2)
            ,"ico-dollarz"                      : ico-dollarz-contributed
            ,"participants"                     : (STOAICO.UR_Global3)
            ;;
            ,"vault-wstoa"                      : (STOAICO.UR_Global4)
            ,"ico-end"                          : (time "2026-15-05T20:00:00Z")
            ,"price-discovery"                  : (UC_ConvertPrice discovered-price)
            ,"stoa-for-redemption"              : stoa-for-redemption
            ,"iz-activated"                     : iz-activated
            }
        )
    )
    (defun URC_0014_SwpairManagementPoolSettings (swpair:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPI:module{SwapperIssueV3} SWPI)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (pool-value:[decimal] (ref-SWPI::URC_PoolValue swpair))
                (pool-value-in-stoa:decimal (at 0 pool-value))
                (lp-value-in-stoa:decimal (at 1 pool-value))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (all-tokens:[string] (+ [lp-id] pool-tokens))
                (ptfs:[object]
                    (fold
                        (lambda
                            (acc:[object] idx:integer)
                            (let
                                (
                                    (pool-token:string (at idx all-tokens))
                                    (frozen-link:string (ref-DPTF::UR_Frozen pool-token))
                                    (sleeping-link:string (ref-DPTF::UR_Sleeping pool-token))
                                )
                                (ref-U|LST::UC_AppL
                                    acc
                                    {"pool-token"       : pool-token
                                    ,"frozen-link"      : frozen-link
                                    ,"sleeping-link"    : sleeping-link}
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length all-tokens) 1))
                    )
                )
            )
            {"pool-owner"                       : (ref-SWP::UR_OwnerKonto swpair)
            ,"can-change-owner"                 : (ref-SWP::UR_CanChangeOwner swpair)
            ,"frozen"                           : (ref-SWP::UR_IzFrozenLP swpair)
            ,"sleeping"                         : (ref-SWP::UR_IzSleepingLP swpair)
            ,"weights"                          : (ref-SWP::UR_Weigths swpair)
            ,"amplifier"                        : (ref-SWP::UR_Amplifier swpair)
            ,"swapping"                         : (ref-SWP::UR_CanSwap swpair)
            ,"provisioning"                     : (ref-SWP::UR_CanAdd swpair)
            ,"primality"                        : (ref-SWP::UR_Primality swpair)
            ,"pool-value-in-stoa"               : pool-value-in-stoa
            ,"lp-value-in-stoa"                 : lp-value-in-stoa
            ,"ptfs"                             : ptfs
            ,"pool-type"                        : (at 0 (UC_PoolTypeWord swpair))}
        )
    )
    (defun URC_0015_SwpairManagementFeeSettings (swpair:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-SWP:module{SwapperV3} SWP)
                ;;
                (owner:string (ref-SWP::UR_OwnerKonto swpair))
                (major:integer (ref-DALOS::UR_Elite-Tier-Major owner))
                (max:integer
                    (cond
                        ((= major 2) 2)
                        ((= major 3) 3)
                        ((= major 4) 4)
                        ((fold (or) true [(= major 5)(= major 6)(= major 7)]) 7)
                        1
                    )
                )
                ;;
                (iz-liquid-boost:bool (ref-SWP::UR_LiquidBoost))
                (total-fee:decimal (ref-SWP::URC_PoolTotalFee swpair))
                (lp-fee:decimal (ref-SWP::UR_FeeLP swpair))
                (special-fee:decimal (ref-SWP::UR_FeeSP swpair))
                (liquid-boost-fee:decimal (- total-fee (+ lp-fee special-fee)))
            )
            {"fee-unlocks"                      : (ref-SWP::UR_FeeUnlocks swpair)
            ,"fee-lock"                         : (ref-SWP::UR_FeeLock swpair)
            ;;
            ,"total-fee"                        : total-fee
            ,"lp-fee"                           : lp-fee
            ,"special-fee"                      : special-fee
            ,"liquid-boost-fee"                 : liquid-boost-fee
            ;;
            ,"special-fee-targets"              : (ref-SWP::UR_FeeSPT swpair)
            ,"max-special-fee-targets"          : max
            }
        )
    )
    (defun URC_0016_TruefungibleHeader (account:string)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (total-tf-number:integer (length (keys DPTF.DPTF|PropertiesTable)))
                (held-tf:[string] (ref-DPTF::URH_HeldTrueFungibles account))
                (mngd-tf:[string] (ref-DPTF::URH_OwnedTrueFungibles account))
            )
            {"total-true-fungible-number"       : total-tf-number
            ,"held-tf"                          : held-tf
            ,"held-tf-number"                   : (length held-tf)
            ,"mngd-tf"                          : mngd-tf
            ,"mngd-tf-number"                   : (length mngd-tf)}
        )
    )
    (defun URC_0017_TruefungibleButton (account:string dptf:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS-C:module{AutostakeComputerV1} ATS)
                ;;
                (owner:string (ref-DPTF::UR_Konto dptf))
                (balance:decimal (ref-DPTF::UR_AccountSupply dptf account))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (elite-auryn-id:string (ref-DALOS::UR_EliteAurynID))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (ustoa-id:string (ref-DALOS::UR_UrStoaID))
                (iz-ea:bool (= dptf elite-auryn-id))
                (ouro-balance:decimal (ref-DPTF::UR_AccountSupply ouro-id account))
                ;;
                (mint-role:bool (ref-DPTF::UR_AccountRoleMint dptf account))
                (burn-role:bool (ref-DPTF::UR_AccountRoleBurn dptf account))
                (can-wipe:bool (ref-DPTF::UR_CanWipe dptf))
                (iz-owner:bool (= account owner))
                ;;
                (first-two:string (take 2 dptf))
                (iz-frozen-token:bool (= first-two "F|"))
                (freeze:bool
                    (if iz-frozen-token
                        false
                        (ref-DPTF::URC_HasFrozen dptf)
                    )
                )
                (iz-lp:bool (fold (or) false [(= first-two "S|")(= first-two "W|")(= first-two "P|")]))
                (can-vest:bool (and iz-owner (ref-DPTF::URC_HasReserved dptf)))
                ;;
                ;;
                (can-coil-obj:object{AutostakeComputerV1.CanCoil} (ref-ATS-C::UC_CanCoil dptf))
                (can-coil:bool (at "can-coil" can-coil-obj))
                ;;
                (can-curl-obj:object{AutostakeComputerV1.CanCurl} (ref-ATS-C::UC_CanCurl dptf))
                (can-curl:bool (at "can-curl" can-curl-obj))
                ;;
                (can-constrict-obj:object{AutostakeComputerV1.CanConstrict} (ref-ATS-C::UC_CanConstrict dptf))
                (can-brumate-obj:object{AutostakeComputerV1.CanBrumate} (ref-ATS-C::UC_CanBrumate dptf))
                ;;
                (transmute:bool
                    (if iz-frozen-token
                        false
                        (if iz-ea
                            (if (>= ouro-balance 0.0)
                                true
                                false
                            )
                            true
                        )
                    )
                )
                ;;
                ;;Transfer Check
                (dptf-fee-toggle:bool (ref-DPTF::UR_FeeToggle dptf))
                (min-move:decimal (ref-DPTF::UR_MinMove dptf))
                (iz-balance-sufficient-for-transfer:bool
                    (if dptf-fee-toggle
                        (>= balance min-move)
                        true
                    )
                )
                (iz-dptf-paused:bool (ref-DPTF::UR_Paused dptf))
                (iz-account-frozen:bool (ref-DPTF::UR_AccountFrozenState dptf account))
                (transfer:bool
                    (fold (and) true 
                        [
                            iz-balance-sufficient-for-transfer 
                            (not iz-dptf-paused) 
                            (not iz-account-frozen)
                        ]
                    )
                )
                (can-transfer:bool
                    (if iz-frozen-token
                        false
                        (if iz-ea
                            (if (>= ouro-balance 0.0)
                                transfer
                                false
                            )
                            transfer
                        )
                    )
                )
            )
            {"mint"                             : mint-role
            ,"burn"                             : burn-role
            ,"wipe"                             : (and can-wipe iz-owner)
            ,"unfold"                           : iz-lp
            ,"freeze"                           : freeze
            ,"reserve"                          : (and (ref-DPTF::URC_HasReserved dptf) (ref-DPTF::UR_IzReservationOpen dptf))
            ,"vest"                             : can-vest
            ,"sleep"                            : (ref-DPTF::URC_HasSleeping dptf)
            ,"hibernate"                        : (ref-DPTF::URC_HasHibernation dptf)
            ,"coil"                             : can-coil
            ,"curl"                             : can-curl
            ,"constrict"                        : (at "can-constrict" can-constrict-obj)
            ,"brumate"                          : (at "can-brumate" can-brumate-obj)
            ,"recover"                          : (ref-DPTF::URC_IzRBT dptf)
            ,"sublimate"                        : (= dptf ouro-id)
            ,"compress"                         : (= dptf ignis-id)
            ,"transmute"                        : transmute
            ,"unwrap"                           : (or (= dptf wstoa-id) (= dptf ustoa-id))
            ,"transfer"                         : can-transfer
            ;;
            ,"where-coil"                       : (at "where-coil" can-coil-obj)
            ,"where-curl"                       : (at "where-curl" can-curl-obj)
            ,"where-constrict"                  : (at "where-constrict" can-constrict-obj)
            ,"where-brumate"                    : (at "where-brumate" can-brumate-obj)
            }
        )
    )
    (defun URC_0018_OrtofungibleHeader (account:string)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (total-of-number:integer (length (keys DPOF.DPOF|T|Properties)))
                (total-of-nonces:integer (length (keys DPOF.DPOF|T|Nonces)))
                (held-of:[string] (ref-DPOF::URH_HeldOrtoFungibles account))
                (mngd-of:[string] (ref-DPOF::URH_OwnedOrtoFungibles account))
            )
            {"total-orto-fungible-number"       : total-of-number
            ,"total-orto-fungible-nonces"       : total-of-nonces
            ,"held-of"                          : held-of
            ,"held-of-number"                   : (length held-of)
            ,"mngd-of"                          : mngd-of
            ,"mngd-of-number"                   : (length mngd-of)}
        )
    )
    (defun URC_0019_OrtofungibleButton (account:string dpof:string selected-nonces:[integer])
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-VST:module{VestingV1} VST)
                ;;
                (iz-smart:bool (ref-DALOS::UR_AccountType account))
                (ats-sc:string (ref-DALOS::GOV|ATS|SC_NAME))
                (owner:string (ref-DPOF::UR_Konto dpof))
                (iz-owner-ats:bool (= owner ats-sc))
                (iz-owner:bool (= account owner))
                (has-addq:bool (ref-DPOF::UR_R-AddQuantity dpof account))
                (has-create:bool (ref-DPOF::UR_R-Create dpof account))
                (has-burn:bool (ref-DPOF::UR_R-Burn dpof account))
                (has-segmentation:bool (ref-DPOF::UR_Segmentation dpof))
                (can-wipe:bool (ref-DPOF::UR_CanWipe dpof))
                ;;
                (l:integer (length selected-nonces))
                (iz-empty:bool (if (= l 0) true false))
                (iz-single:bool (if (= l 1) true false))
                (iz-multiple:bool (if (> l 1) true false))
                ;;
                (first-two:string (take 2 dpof))
                (iz-vested:bool (= first-two "V|"))
                (iz-sleeping:bool (= first-two "Z|"))
                (iz-hibernated:bool (= first-two "H|"))
                ;;
                (unvest-amount:decimal
                    (if (and iz-vested iz-single)
                        (at 0 (ref-VST::URC_CullMetaDataAmountWithObject dpof (at 0 selected-nonces)))
                        0.0
                    )
                )
                (can-unvest:bool (if (> unvest-amount 0.0) true false))
                (unsleep-amount:decimal
                    (if (and iz-sleeping iz-single)
                        (at 0 (ref-VST::URC_CullMetaDataAmountWithObject dpof (at 0 selected-nonces)))
                        0.0
                    )
                )
                (nonce-supply:decimal 
                    (if iz-single
                        (ref-DPOF::UR_NonceSupply dpof (at 0 selected-nonces))
                        -1.0
                    )
                )
                (can-unsleep:bool
                    (if (= unsleep-amount nonce-supply) true false)
                )
                ;;
                (iz-rbt:bool (ref-DPOF::URC_IzRBT dpof))
                (redeem-and-revert:bool 
                    (fold (and) true [iz-single (not iz-smart) iz-owner-ats iz-rbt])
                )
            )
            {"add-quantity"                     : (fold (and) true [iz-single has-addq])
            ,"mint"                             : (fold (and) true [iz-empty has-addq has-create])
            ,"burn"                             : (fold (and) true [iz-single has-burn])
            ,"wipe"                             : (fold (and) true [iz-empty can-wipe iz-owner])
            ,"unvest"                           : (fold (and) true [iz-single iz-vested (not iz-smart) can-unvest])
            ,"unsleep"                          : (fold (and) true [iz-single iz-sleeping (not iz-smart) can-unsleep])
            ,"merge"                            : (fold (and) true [(not iz-empty) iz-sleeping])
            ,"awake"                            : (fold (and) true [iz-single iz-hibernated])
            ,"slumber"                          : (fold (and) true [(not iz-single) iz-hibernated])
            ,"redeem"                           : redeem-and-revert
            ,"revert"                           : redeem-and-revert
            ,"transmit"                         : (fold (and) true [(not iz-empty) has-segmentation])
            ,"transfer"                         : (not iz-empty)
            }
        )
    )
    (defun URC_0020_HibernatingNonceData (dpof:string nonce:integer)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (dptf-id:string (ref-DPOF::UR_Hibernation dpof))
                (precision:integer (ref-DPOF::UR_Decimals dpof))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData dpof nonce))
                ;;
                (mint-time:time (at "mint-time" (at 0 meta-data-chain)))
                (release-time:time (at "release-date" (at 0 meta-data-chain)))
                (hibernating-period:decimal (diff-time release-time mint-time))
                ;;
                (present-time:time (at "block-time" (chain-data)))
                (elapsed-time:decimal (diff-time present-time mint-time))
                ;;
                (hibernating-fee-promile:decimal
                    (if (>= elapsed-time hibernating-period)
                        0.0
                        (floor (- 800.0 (* 800.0 (/ elapsed-time hibernating-period))) 4)
                    )
                )
                (remainder:decimal 
                    (if (= hibernating-fee-promile 0.0)
                        nonce-supply
                        (at 0 (ref-U|ATS::UC_PromilleSplit hibernating-fee-promile nonce-supply precision))
                    )
                )
                (hibernating-fee:decimal (- nonce-supply remainder))
            )
            {"dptf-id"                          : dptf-id
            ,"nonce-supply"                     : nonce-supply
            ,"mint-time"                        : mint-time
            ,"release-time"                     : release-time
            ,"hibernating-fee-promile"          : hibernating-fee-promile
            ,"remainder"                        : remainder
            ,"hibernating-fee"                  : hibernating-fee}
        )
    )
    (defun URC_0021_CollectablesHeader (account:string)
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (tsfn:integer (length (keys DPDC.DPSF|T|Properties)))
                (tsfnn:integer (length (keys DPDC.DPSF|T|Nonces)))
                (held-sf:[string] (ref-DPDC::URH_HeldCollectables account true))
                (held-sf-no:integer (length held-sf))
                (mngd-sf:[string] (ref-DPDC::URH_OwnedCollectables account true))
                (mngd-sf-no:integer (length mngd-sf))
                ;;
                (tnfn:integer (length (keys DPDC.DPNF|T|Properties)))
                (tnfnn:integer (length (keys DPDC.DPNF|T|Nonces)))
                (held-nf:[string] (ref-DPDC::URH_HeldCollectables account false))
                (held-nf-no:integer (length held-nf))
                (mngd-nf:[string] (ref-DPDC::URH_OwnedCollectables account false))
                (mngd-nf-no:integer (length mngd-nf))
            )
            {"total-semi-fungible-number"       : tsfn
            ,"total-semi-fungible-nonces"       : tsfnn
            ,"held-sf"                          : held-sf
            ,"held-sf-number"                   : held-sf-no
            ,"mngd-sf"                          : mngd-sf
            ,"mngd-sf-no"                       : mngd-sf-no
            ;;
            ,"total-non-fungible-number"        : tnfn
            ,"total-non-fungible-nonces"        : tnfnn
            ,"held-nf"                          : held-nf
            ,"held-nf-number"                   : held-nf-no
            ,"mngd-nf"                          : mngd-nf
            ,"mngd-nf-no"                       : mngd-nf-no
            }
        )
    )
    (defun URC_0022_CollectableEntry (account:string dpdc-id:string son:bool)
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                ;;
                (wallet-nonces:[object] (ref-DPDC::URH_AccountNoncesWithSupplies account dpdc-id son))
            )
            {"t1"                               : (ref-DPDC::UR_Name dpdc-id son)
            ,"t2"                               : dpdc-id
            ,"wallet-nonces"                    : wallet-nonces
            ,"wallet-nonces-no"                 : (length wallet-nonces)
            }
        )
    )
    (defun URC_0022a_SemifungibleEntryMapper (account:string dpdc-ids:[string])
        (map
            (lambda
                (dpdc-id:string)
                (URC_0022_CollectableEntry account dpdc-id true)
            )
            dpdc-ids
        )
    )
    (defun URC_0022a_NonfungibleEntryMapper (account:string dpdc-ids:[string])
        (map
            (lambda
                (dpdc-id:string)
                (URC_0022_CollectableEntry account dpdc-id false)
            )
            dpdc-ids
        )
    )
    (defun URC_0023_CollectablesNonceData (dpdc-id:string son:bool nonces:[integer])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (fold
                (lambda
                    (acc:[object] nonce:integer)
                    (ref-U|LST::UC_AppL acc
                        (if (< nonce 0)
                            (at "split-data" (ref-DPDC::UR_NonceElement dpdc-id son (abs nonce)))
                            (at "nonce-data" (ref-DPDC::UR_NonceElement dpdc-id son nonce))
                        )
                    )
                )
                []
                nonces
            )
        )
    )
    (defun URC_0024_SetReader:[object{DpdcUdcV1.DPDC|Set}] (dpdc-id:string son:bool)
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-S:module{DpdcSetsV1} DPDC-S)
                (set-classes-used:integer (ref-DPDC::UR_SetClassesUsed dpdc-id son))
            )
            (map
                (lambda
                    (set-class:integer)
                    (ref-DPDC-S::UR_Set dpdc-id son set-class)
                )
                (enumerate 1 set-classes-used)
            )
        )
    )
    (defun URC_0025_FilterNoncesByClass:[integer] 
        (dpdc-id:string son:bool nonces:[integer] nonce-class:integer)
        @doc "Keeps only nonces whose (DPDC.UR_NonceClass dpdc-id son nonce) equals <nonce-class>. \
            \ Returns [] when no nonce matches."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (filter
                (lambda (nonce:integer)
                    (= (ref-DPDC::UR_NonceClass dpdc-id son nonce) nonce-class)
                )
                nonces
            )
        )
    )
    (defun URC_0025a_FilterNoncesByClasses:[[integer]]
        (dpdc-id:string son:bool nonces:[integer] nonce-classes:[integer])
        @doc "For each entry in <nonce-classes>, keeps only nonces in <nonces> whose \
            \ (DPDC.UR_NonceClass dpdc-id son nonce) equals that class. \
            \ Result[i] is the filtered list for nonce-classes[i]; same read discipline as \
            \ URC_0025_FilterNoncesByClass."
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
            )
            (map
                (lambda (nonce-class:integer)
                    (filter
                        (lambda (nonce:integer)
                            (= (ref-DPDC::UR_NonceClass dpdc-id son nonce) nonce-class)
                        )
                        nonces
                    )
                )
                nonce-classes
            )
        )
    )
    (defun URC_0026_CollectablesButtons (account:string dpdc-id:string son:bool selected-nonces:[integer])
        (let
            (
                (ref-DPDC:module{DpdcV1} DPDC)
                (ref-DPDC-F:module{DpdcFragmentsV1} DPDC-F)
                ;;
                (l:integer (length selected-nonces))
                (iz-empty:bool (if (= l 0) true false))
                (iz-single:bool (if (= l 1) true false))
                (iz-multiple:bool (if (> l 1) true false))
                ;;
                (fn:integer (at 0 selected-nonces))
                (first-two:string (take 2 dpdc-id))
                (iz-equity:bool (if (= first-two "E|") true false))
                (add-quantity:bool
                    (if (not iz-single)
                        false
                        (if (not son)
                            false
                            (fold (and) true 
                                [
                                    (> fn 0) 
                                    (= (ref-DPDC::UR_NonceClass dpdc-id true fn) 0)
                                    (ref-DPDC::UR_CA|R-AddQuantity dpdc-id account)
                                ]
                            )
                        )
                    )
                )
                (burn-role:bool (ref-DPDC::UR_CA|R-Burn dpdc-id son account))
                (burn:bool
                    (if (not iz-single)
                        false
                        (if son
                            burn-role
                            (and burn-role (UCx_NonFungibleNonceExistance dpdc-id fn true))
                        )
                    )
                )
                (respawn:bool
                    (if (or (not iz-single) son)
                        false
                        (fold (and) true 
                            [
                                (ref-DPDC::UR_CA|R-Create dpdc-id son account)
                                (UCx_NonFungibleNonceExistance dpdc-id fn false)
                            ]
                        )
                    )
                )
                (can-wipe:bool (ref-DPDC::UR_CanWipe dpdc-id son))
                (owner:string (ref-DPDC::UR_OwnerKonto dpdc-id son))
                (iz-owner:bool (= account owner))
                (fuse:bool
                    (if (not iz-single)
                        false
                        (fold (and) true 
                            [
                                (< fn 0)
                                (>= (ref-DPDC::UR_AccountNonceSupply account dpdc-id son fn) 1000)
                            ]
                        )
                    )
                )
                (split:bool
                    (if (not iz-single)
                        false
                        (if (< fn 0)
                            false
                            (ref-DPDC-F::UEV_IzNonceFragmented dpdc-id son fn)
                        )
                    )
                )
                (break-set:bool
                    (if (not iz-single)
                        false
                        (> (ref-DPDC::UR_NonceClass dpdc-id son fn) 0)
                    )
                )
            )
            {"morph"                            : (fold (and) true [iz-equity iz-single son])
            ,"add-quantity"                     : add-quantity
            ,"burn"                             : burn
            ,"respawn"                          : respawn
            ,"wipe"                             : (fold (and) true [iz-empty can-wipe iz-owner])
            ,"fuse"                             : fuse
            ,"split"                            : split
            ,"break-set"                        : break-set
            ,"transfer"                         : (fold (or) false [iz-single iz-multiple])
            }
        )
    )
    (defun URC_0027_AccountSelectorMapper (accounts:[string])
        (map
            (lambda
                (account:string)
                (URC_0027a_AccountSelectorSingle account)
            )
            accounts
        )
    )
    (defun URC_0027a_AccountSelectorSingle (account:string)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (public-key:string (try BAR (ref-DALOS::UR_AccountPublicKey account)))
                (iz-activated:bool
                    (if (= public-key BAR) false true)
                )
                (oag
                    (if iz-activated
                        (ref-DALOS::UR_AccountGuard account)
                        false
                    )
                )
                (smart
                    (if iz-activated
                        (ref-DALOS::UR_AccountType account)
                        -1
                    )
                )
                (ob
                    (if iz-activated
                        (ref-DALOS::UR_TF_AccountSupply account true)
                        0.0
                    )
                )
                (ib
                    (if iz-activated
                        (ref-DALOS::UR_TF_AccountSupply account false)
                        0.0
                    )
                )
                (payment-key:string
                    (if iz-activated
                        (ref-DALOS::UR_AccountStoa account)
                        BAR
                    )
                )
                (pke-sample 
                    (if (= payment-key BAR)
                        false
                        (try false (ref-coin::get-balance payment-key))
                    )
                )
                (pke-sample-type (typeof pke-sample))
                (pke:bool
                    (if (= pke-sample-type "decimal") true false)
                )
                (pkb:decimal
                    (if pke
                        (ref-coin::get-balance payment-key)
                        -1.0
                    )
                )
                (pkg
                    (if pke
                        (at "guard" (ref-coin::details payment-key))
                        false
                    )
                )
                (ignis-d
                    (if iz-activated
                        (ref-DALOS::URC_IgnisGasDiscount account)
                        false
                    )
                )
                (stoa-d
                    (if iz-activated
                        (ref-DALOS::URC_StoaGasDiscount account)
                        false
                    )
                )
                ;;
                (public-key
                    (if iz-activated
                        (ref-DALOS::UR_AccountPublicKey account)
                        BAR
                    )
                )
                (sovereign
                    (if iz-activated
                        (ref-DALOS::UR_AccountSovereign account)
                        BAR
                    )
                )
                (governor
                    (if iz-activated
                        (ref-DALOS::UR_AccountGovernor account)
                        false
                    )
                )
                (ref-CODEX:module{CodexV1} CODEX)
                (stba-data:object
                    (if iz-activated
                        (ref-CODEX::UR_STBA|DataOrNull account)
                        {"has-stoictag": false, "tag-name": BAR}
                    )
                )
                (stoic-tag-has:bool (at "has-stoictag" stba-data))
                (stoic-tag-name:string
                    (if stoic-tag-has
                        (at "tag-name" stba-data)
                        "No StoicTag yet"
                    )
                )
                (stoic-tag-registered-at
                    (if stoic-tag-has
                        (ref-CODEX::UR_STG|RegisteredAt (at "tag-name" stba-data))
                        false
                    )
                )
            )
            {"iz-activated"                     : iz-activated  ;;if account is activate
            ,"ouronet-account"                  : account       ;;the account string itself
            ,"ouronet-account-guard"            : oag           ;;the account guard; <false> for accounts that dont exist (non-existance)
            ,"iz-smart"                         : smart         ;;true for smart, false for standard -1 for non existance
            ,"ouro-balance"                     : ob            ;;balance in OURO, 0.0 for non existance
            ,"ignis-balance"                    : ib            ;;balance in IGNIS, 0.0 for non-existance
            ,"payment-key-existance"            : pke           ;;if the payment key is registered in the coin.table
            ,"payment-key"                      : payment-key   ;;payment KEY, BAR for non-existance
            ,"payment-key-balance"              : pkb           ;;balance in STOA of Payment Key; -1.0 for non-existance
            ,"payment-key-guard"                : pkg           ;;guard of payment key; false for non-existance
            ,"ignis-discount"                   : ignis-d       ;;the IGNIS discount; false for non-existance
            ,"stoa-discount"                    : stoa-d        ;;the STOA discount; false for non-existance
            ;;
            ,"public-key"                       : public-key    ;;the public key of the account; BAR for non-existance
            ,"sovereign"                        : sovereign     ;;the sovereign of the account; BAR for non-existance
            ,"governor"                         : governor      ;;the governor of the account; false for non-existance
            ;;
            ,"stoic-tag-has"                    : stoic-tag-has             ;;true when account has an active StoicTag
            ,"stoic-tag"                        : stoic-tag-name            ;;tag name or "No StoicTag yet"
            ,"stoic-tag-registered-at"          : stoic-tag-registered-at   ;;block time at registration; false if none
            }
        )
    )
    (defun URC_0027b_StoicTagSelectorMapper (tag-names:[string])
        @doc "Inverse StoicTag selector: batch read for tag-name list (Mnemosyne tag picker)."
        (map
            (lambda
                (tag-name:string)
                (URC_0027c_StoicTagSelectorSingle tag-name)
            )
            tag-names
        )
    )
    (defun URC_0027c_StoicTagSelectorSingle (tag-name:string)
        @doc "Inverse StoicTag selector: existence, active/released, bound Ouronet account."
        (let
            (
                (ref-CODEX:module{CodexV1} CODEX)
                (row-exists:bool (not (= (try false (ref-CODEX::UR_STG|Data tag-name)) false)))
                (iz-active:bool
                    (if row-exists
                        (ref-CODEX::UR_STG|IzActive tag-name)
                        false
                    )
                )
                (iz-released:bool (and row-exists (not iz-active)))
                (bound-account:string
                    (if iz-active
                        (ref-CODEX::UR_STG|AccountAddress tag-name)
                        BAR
                    )
                )
                (registered-at
                    (if row-exists
                        (ref-CODEX::UR_STG|RegisteredAt tag-name)
                        false
                    )
                )
            )
            {"stoic-tag"                        : tag-name
            ,"iz-row-exists"                    : row-exists    ;;row in CODEX|T|StoicTags (incl. released)
            ,"iz-active"                        : iz-active     ;;true = tied to an Ouronet account
            ,"iz-released"                      : iz-released   ;;row exists but iz-active false
            ,"iz-never-registered"              : (not row-exists)
            ,"ouronet-account"                  : bound-account ;;account when active; BAR otherwise
            ,"registered-at"                    : registered-at ;;immutable row timestamp; false if never registered
            }
        )
    )
    (defun URC_0028_StoaAccountSelectorMapper (stoa-accounts:[string])
        (map
            (lambda
                (stoa-account:string)
                (URC_0028a_StoaAccountSelectorSingle stoa-account)
            )
            stoa-accounts
        )
    )
    (defun URC_0028a_StoaAccountSelectorSingle (stoa-account:string)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (stoa-sample
                    (try false (ref-coin::details stoa-account))
                )
                (stoa-sample-type (typeof stoa-sample))
                (iz-activated:bool 
                    (if (= stoa-sample-type "bool") false true)
                )
                (stoa-account-balance:decimal
                    (if iz-activated
                        (at "balance" stoa-sample)
                        -1.0
                    )
                )
                (stoa-account-guard
                    (if iz-activated
                        (at "guard" stoa-sample)
                        false
                    )
                )
            )
            {"iz-activated"                     : iz-activated
            ,"account"                          : stoa-account
            ,"balance"                          : stoa-account-balance
            ,"guard"                            : stoa-account-guard
            }
        )
    )
    (defun URC_0029_AccountOverview (selected-ouronet-account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                ;;
                (public-key:string (try BAR (ref-DALOS::UR_AccountPublicKey selected-ouronet-account)))
                (iz-activated:bool
                    (if (= public-key BAR) false true)
                )
                (is-stoa-zero:bool (ref-IGNIS::URC_IsNativeGasZero))
                (kfp:decimal (ref-DALOS::UR_UsagePrice "standard"))
                (no-costs:object{OuronetInfoV1.ClientStoaCosts} (ref-I|OURONET::OI|UDC_NoStoaCosts))
                (stoa-costs:object{OuronetInfoV1.ClientStoaCosts}
                    (if iz-activated
                        no-costs
                        (if is-stoa-zero no-costs (ref-I|OURONET::OI|UDC_FullStoaCosts kfp))
                    )
                )
            )
            {"global-administrative-pause"      : (ref-DALOS::UR_GAP)
            ,"iz-selected-activated"            : iz-activated
            ,"stoa-costs"                       : (at "stoa-need" stoa-costs)}
        )
    )
    (defun URC_0030_StoicPay (account:string)
        @doc "StoicPay / DEMIPAD-STOICPAY sale UI read bundle (delegates to StoicPayV2 for on-chain data)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SP:module{StoicPayV2} DEMIPAD-STOICPAY)
                (ref-DPAD:module{DemiourgosLaunchpadV1} DEMIPAD)
                ;;
                (KpayID:string (ref-SP::UR_KpayID))
                (pad-ledger:string (ref-SP::UR_PAD_LEDGER_ACCOUNT))
                (resident-amount:decimal (ref-DPTF::UR_AccountSupply KpayID pad-ledger))
                (left-for-sale:decimal (* 0.4 resident-amount))
                (sold:decimal (- 100000000.0 left-for-sale))
                (period:integer (ref-SP::UR_GetPeriod))
                (period-ceiling:decimal (ref-SP::UR_PeriodAllocation period))
                (remaining:decimal (ref-SP::UR_KpayLeft))
                (bought:decimal
                    (if (or (= period -1)(= period 0))
                        sold
                        (- period-ceiling remaining)
                    )
                )
                (circulating:decimal (* 2.5 bought))
                ;;
                (starting-tm:time (at "starting-time" (ref-DPAD::UR_Price KpayID)))
                ;;
                (single-costs:object{DemiourgosLaunchpadV1.Costs} (ref-SP::URC_KpayAmountCosts 1 0.0))
                (stage-text:string
                    (if (= period -1)
                        "Stage 1 Starts in:"
                        (if (= period 0)
                            (format "KPay Sale has concluded")
                            (format "Stage {}/25" [period])
                        )

                    )
                )
                (next-stage-text:string
                    (if (= period -1)
                        (format "Genesis Period Ceiling: {} KPAY" [(ref-SP::UR_PeriodAllocation 1)])
                        (if (= period 0)
                            (format "KPAY Circulating supply is {}" [circulating])
                            (if (!= period 25)
                                (format "Next  Stage Ceiling: {} KPAY" [(ref-SP::UR_PeriodAllocation (+ 1 period))])
                                (format "Final Stage Ceiling: {} KPAY" [period-ceiling])
                            )
                        )
                    )
                )
                (percent-value:string
                    (if (or (= period -1) (= period 0))
                        (UC_FormatTokenAmount 0.0)
                        (UC_FormatTokenAmount (* (/ bought period-ceiling) 100.0))
                    )
                )
                (percent-text:string
                    (if (= period -1)
                        "Sale hasn't started yet."
                        (if (= period 0)
                            (format "Sale has Concluded: {}% has been sold." [percent-value])
                            (format "Sale Progress: {}% of Current Ceiling." [percent-value])
                        )
                    )
                )
                (ceiling-text:string
                    (if (= period -1)
                        "Sale hasn't started yet."
                        (if (= period 0)
                            "Kpay Sale has concluded"
                            (format "Stage {} Celing: {} KPAY" [period period-ceiling])
                        )
                    )
                )
            )
            {"stage-text"           : stage-text
            ,"next-stage-text"      : next-stage-text
            ;;
            ,"sale-progress"        : percent-text
            ,"ceiling-text"         : ceiling-text
            ,"sold-text"            : (format "{} KPAY Sold" [bought])
            ,"remaining-text"       : (format "{} KPAY left for Sale" [(if (= period -1) left-for-sale remaining)])
            ;;
            ,"your-balance"         : (ref-DPTF::UR_AccountSupply KpayID account)
            ,"circulating-supply"   : circulating
            ;;
            ;;Single Costs
            ,"kpay-pid"             : (at "pid" single-costs)
            ,"kpay-wstoa"            : (at "wstoa" single-costs)
            ;;
            ;;Native Buy Maxes
            ,"native-buy-max"       : (ref-SP::URC_GetMaxBuy account true)
            ,"wstoa-buy-max"         : (ref-SP::URC_GetMaxBuy account false)
            ;;
            ;;Misc and Direct Values
            ,"kpay-id"              : KpayID
            ,"remaining-for-mint"   : remaining
            ,"minted"               : bought
            ,"start-date"           : starting-tm
            ,"period"               : period
            ,"period-ceiling"       : period-ceiling
            ,"account-kpay"         : (ref-DPTF::UR_AccountSupply KpayID account)
            ,"account-ignis"        : (ref-DPTF::UR_AccountSupply (ref-DALOS::UR_IgnisID) account)
            ,"ignis-collection"     : (ref-DALOS::UR_VirtualToggle)
            ,"open-for-business"    : (ref-DPAD::UR_OpenForBusiness KpayID)
            }
        )
    )
    (defun URC_0031:[object] (apollo-accounts:[string])
        @doc "Map PYTHIA.UR_ApiKeyRowOrNull over each Apollo account string (₱./Π.)."
        (let ((ref-PYTHIA:module{PythiaV4} PYTHIA))
            (map
                (lambda (apollo-account:string)
                    (ref-PYTHIA::UR_ApiKeyRowOrNull apollo-account)
                )
                apollo-accounts
            )
        )
    )
    (defun URC_0032_EliteAccount (account:string)
        @doc "Elite Account panel: DALOS elite row, all Elite-Auryn variant supplies, \
            \ Auryndex/EliteAuryndex, OURO dispo-credit (tier overspend % on native EA), \
            \ IGNIS/STOA gas discounts, DEX swap-fee discount (same curve as IGNIS), \
            \ DEB multiplier, and coded Elite unlocks (SWP special-fee targets, branding months, \
            \ Elite-ATS cold-recovery positions). Extend this object as further Elite bonuses appear."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (ref-U|DPTF:module{UtilityDptfV1} U|DPTF)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-ELITE:module{EliteV1} ELITE)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-BRD:module{BrandingV1} BRD)
                ;;
                (elite-class:string (ref-DALOS::UR_Elite-Class account))
                (elite-name:string (ref-DALOS::UR_Elite-Name account))
                (elite-tier:string (ref-DALOS::UR_Elite-Tier account))
                (elite-deb:decimal (ref-DALOS::UR_Elite-DEB account))
                (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
                (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (auryn-id:string (ref-DALOS::UR_AurynID))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (fea-id:string (if (!= ea-id BAR) (ref-DPTF::UR_Frozen ea-id) BAR))
                (rea-id:string (if (!= ea-id BAR) (ref-DPTF::UR_Reservation ea-id) BAR))
                (vea-id:string (if (!= ea-id BAR) (ref-DPTF::UR_Vesting ea-id) BAR))
                (sea-id:string (if (!= ea-id BAR) (ref-DPTF::UR_Sleeping ea-id) BAR))
                (hea-id:string (if (!= ea-id BAR) (ref-DPTF::UR_Hibernation ea-id) BAR))
                (ea-supply:decimal
                    (if (!= ea-id BAR) (ref-DPTF::UR_AccountSupply ea-id account) 0.0)
                )
                (fea-supply:decimal
                    (if (!= fea-id BAR) (ref-DPTF::UR_AccountSupply fea-id account) 0.0)
                )
                (rea-supply:decimal
                    (if (!= rea-id BAR) (ref-DPTF::UR_AccountSupply rea-id account) 0.0)
                )
                (vea-supply:decimal
                    (if (!= vea-id BAR) (ref-DPOF::UR_AccountSupply vea-id account) 0.0)
                )
                (sea-supply:decimal
                    (if (!= sea-id BAR) (ref-DPOF::UR_AccountSupply sea-id account) 0.0)
                )
                (hea-supply:decimal
                    (if (!= hea-id BAR) (ref-DPOF::UR_AccountSupply hea-id account) 0.0)
                )
                (total-elite-aurynz:decimal (ref-ELITE::URC_EliteAurynzSupply account))
                (et:[decimal] (ref-U|CT::CT_ET))
                (et-last:decimal (at (- (length et) 1) et))
                (elite-aurynz-next:decimal
                    (if (>= total-elite-aurynz et-last)
                        0.0
                        (-
                            (fold
                                (lambda
                                    (acc:decimal tier:decimal)
                                    (if (and (> tier total-elite-aurynz) (< tier acc))
                                        tier
                                        acc
                                    )
                                )
                                et-last
                                et
                            )
                            total-elite-aurynz
                        )
                    )
                )
                ;; Indices — same ATS resolution as TFT.UDC_GetDispoData
                (auryndex-id:string (at 0 (ref-DPTF::UR_RewardToken ouro-id)))
                (elite-auryndex-id:string (at 0 (ref-DPTF::UR_RewardToken auryn-id)))
                (auryndex-value:decimal (ref-ATS::URC_Index auryndex-id))
                (elite-auryndex-value:decimal (ref-ATS::URC_Index elite-auryndex-id))
                ;; OURO dispo-credit: tier % of native EA value in OURO (U|DPTF.UC_OuroDispo / TFT.URC_*)
                (dispo-data:object{UtilityDptfV1.DispoData} (ref-TFT::UDC_GetDispoData account))
                (dispo-overspend-percent:decimal
                    (if (< (dec major) 3.0)
                        0.0
                        (floor (+ (/ (- (+ (* (- (dec major) 1.0) 7.0) (dec minor)) 15.0) 10.0) 11.5) 1)
                    )
                )
                (ouro-dispo-capacity:decimal (ref-U|DPTF::UC_OuroDispo dispo-data))
                (ouro-minimum:decimal (ref-TFT::URC_MinimumOuro account))
                (ouro-balance:decimal (ref-DPTF::UR_AccountSupply ouro-id account))
                (ouro-virtual:decimal (ref-TFT::URC_VirtualOuro account))
                (elite-auryn-dispo-locked:bool (< ouro-balance 0.0))
                ;;
                (ignis-cost-multiplier:decimal (ref-DALOS::URC_IgnisGasDiscount account))
                (stoa-cost-multiplier:decimal (ref-DALOS::URC_StoaGasDiscount account))
                (ignis-discount-percent:decimal (ref-U|DALOS::UC_GasDiscount major minor false))
                (stoa-discount-percent:decimal (ref-U|DALOS::UC_GasDiscount major minor true))
                ;; DEX LP/special/boost fees use the IGNIS (non-native) gas curve — SWPI.URC_EliteFeeReduction
                (dex-fee-cost-multiplier:decimal ignis-cost-multiplier)
                (dex-fee-discount-percent:decimal ignis-discount-percent)
                ;;
                (max-swp-special-fee-targets:integer
                    (cond
                        ((= major 2) 2)
                        ((= major 3) 3)
                        ((= major 4) 4)
                        ((fold (or) false [(= major 5) (= major 6) (= major 7)]) 7)
                        1
                    )
                )
                (max-branding-blue-months:integer (ref-BRD::URC_MaxBluePayment account))
                (elite-ats-cold-recovery-positions:integer
                    (if (= major 0) 1 major)
                )
                (elite-ats-cold-recovery-duration-index:integer
                    (if (= major 0)
                        0
                        (+ (* (- major 1) 7) minor)
                    )
                )
            )
            {"account"                              : account
            ;; DALOS Elite Account
            ,"elite-class"                          : elite-class
            ,"elite-name"                           : elite-name
            ,"elite-tier"                           : elite-tier
            ,"elite-tier-major"                     : major
            ,"elite-tier-minor"                     : minor
            ,"elite-deb"                            : elite-deb
            ;; Elite Auryn variants (ELITE.URC_EliteAurynzSupply constituents)
            ,"ea-id"                                : ea-id
            ,"ea-supply"                            : (UC_FormatTokenAmount ea-supply)
            ,"ea-supply-hover"                      : ea-supply
            ,"fea-id"                               : fea-id
            ,"fea-supply"                           : (UC_FormatTokenAmount fea-supply)
            ,"fea-supply-hover"                     : fea-supply
            ,"rea-id"                               : rea-id
            ,"rea-supply"                           : (UC_FormatTokenAmount rea-supply)
            ,"rea-supply-hover"                     : rea-supply
            ,"vea-id"                               : vea-id
            ,"vea-supply"                           : (UC_FormatTokenAmount vea-supply)
            ,"vea-supply-hover"                     : vea-supply
            ,"sea-id"                               : sea-id
            ,"sea-supply"                           : (UC_FormatTokenAmount sea-supply)
            ,"sea-supply-hover"                     : sea-supply
            ,"hea-id"                               : hea-id
            ,"hea-supply"                           : (UC_FormatTokenAmount hea-supply)
            ,"hea-supply-hover"                     : hea-supply
            ,"total-elite-aurynz"                   : (UC_FormatTokenAmount total-elite-aurynz)
            ,"total-elite-aurynz-hover"             : total-elite-aurynz
            ,"elite-aurynz-for-next-tier"           : (UC_FormatTokenAmount elite-aurynz-next)
            ,"elite-aurynz-for-next-tier-hover"     : elite-aurynz-next
            ;; Auryndex / EliteAuryndex (feed dispo math)
            ,"auryndex-id"                          : auryndex-id
            ,"auryndex-name"                        : (ref-ATS::UR_IndexName auryndex-id)
            ,"auryndex-value"                       : (UC_FormatIndex auryndex-value)
            ,"auryndex-value-hover"                 : auryndex-value
            ,"elite-auryndex-id"                    : elite-auryndex-id
            ,"elite-auryndex-name"                  : (ref-ATS::UR_IndexName elite-auryndex-id)
            ,"elite-auryndex-value"                 : (UC_FormatIndex elite-auryndex-value)
            ,"elite-auryndex-value-hover"           : elite-auryndex-value
            ;; OURO dispo-credit (native EA × indices × tier overspend %)
            ,"dispo-overspend-percent"              : dispo-overspend-percent
            ,"dispo-overspend-text"                 :
                (format
                    "{}% of native Elite-Auryn OURO-value may be overspent (requires Major Tier ≥ 3)"
                    [dispo-overspend-percent]
                )
            ,"ouro-id"                              : ouro-id
            ,"ouro-balance"                         : (UC_FormatTokenAmount ouro-balance)
            ,"ouro-balance-hover"                   : ouro-balance
            ,"ouro-dispo-capacity"                  : (UC_FormatTokenAmount ouro-dispo-capacity)
            ,"ouro-dispo-capacity-hover"            : ouro-dispo-capacity
            ,"ouro-minimum"                         : (UC_FormatTokenAmount ouro-minimum)
            ,"ouro-minimum-hover"                   : ouro-minimum
            ,"ouro-virtual"                         : (UC_FormatTokenAmount ouro-virtual)
            ,"ouro-virtual-hover"                   : ouro-virtual
            ,"elite-auryn-dispo-locked"             : elite-auryn-dispo-locked
            ,"elite-auryn-dispo-locked-text"        :
                (if elite-auryn-dispo-locked
                    "Native Elite-Auryn is dispo-locked until OURO balance returns to ≥ 0"
                    "Native Elite-Auryn is transferable (OURO not negative)"
                )
            ;; IGNIS / STOA / DEX fee discounts (multiplier 1.0 = no discount)
            ,"ignis-cost-multiplier"                : ignis-cost-multiplier
            ,"ignis-discount-percent"               : ignis-discount-percent
            ,"ignis-discount-text"                  :
                (format
                    "IGNIS Discount {}% (You pay only {}% of IGNIS costs)"
                    [ignis-discount-percent (* ignis-cost-multiplier 100.0)]
                )
            ,"stoa-cost-multiplier"                 : stoa-cost-multiplier
            ,"stoa-discount-percent"                : stoa-discount-percent
            ,"stoa-discount-text"                   :
                (format
                    "STOA Discount {}% (You pay only {}% of STOA costs)"
                    [stoa-discount-percent (* stoa-cost-multiplier 100.0)]
                )
            ,"dex-fee-cost-multiplier"              : dex-fee-cost-multiplier
            ,"dex-fee-discount-percent"             : dex-fee-discount-percent
            ,"dex-fee-discount-text"                :
                (format
                    "DEX Fee Discount {}% (LP/Special/Boost fees; same curve as IGNIS)"
                    [dex-fee-discount-percent]
                )
            ;; Other Elite bonuses coded on-chain
            ,"deb-bonus-text"                       :
                (format
                    "DEB ×{} on AQP scores when deb-boost is enabled"
                    [elite-deb]
                )
            ,"max-swp-special-fee-targets"          : max-swp-special-fee-targets
            ,"max-branding-blue-months"             : max-branding-blue-months
            ,"elite-ats-cold-recovery-positions"    : elite-ats-cold-recovery-positions
            ,"elite-ats-cold-recovery-duration-index" : elite-ats-cold-recovery-duration-index
            }
        )
    )
    (defun URC_0033_DualApiKeyMapper:[object] (dual-api-keys:[string])
        @doc "Map PYTHIA.UR_DualLinkRowOrNull over each dual-API key (Standard|Smart composite)."
        (let ((ref-PYTHIA:module{PythiaV4} PYTHIA))
            (map
                (lambda (dual-api-key:string)
                    (ref-PYTHIA::UR_DualLinkRowOrNull dual-api-key)
                )
                dual-api-keys
            )
        )
    )
    (defun URC_0034_PythiaPrices ()
        @doc "PYTHIA Config deploy/rename STOA prices (UR_DeployPrice / UR_RenamePrice)."
        (let
            (
                (ref-PYTHIA:module{PythiaV4} PYTHIA)
                ;;
                (deploy-price:decimal (ref-PYTHIA::UR_DeployPrice))
                (rename-price:decimal (ref-PYTHIA::UR_RenamePrice))
            )
            {"deploy-price"         : deploy-price
            ,"rename-price"         : rename-price
            ,"deploy-price-text"    : (format "{} STOA per Apollo half deploy" [deploy-price])
            ,"rename-price-text"    : (format "{} STOA to rename dual-link consumer lane" [rename-price])
            }
        )
    )
    (defun URC_0035_EliteAccountRichList:[object] ()
        @doc "Elite rich-list scan: all Standard Ouronet accounts (excludes Smart), \
            \ with StoicTag (BAR if none/inactive), native/frozen/reservation/vesting/sleeping/hibernation \
            \ Elite-Auryn supplies and total (same constituents as ELITE.URC_EliteAurynzSupply), \
            \ dispo-lock flag when OURO < 0 (native EA immovable), and movable native EA amount. \
            \ Output ordered highest→lowest by total-elite-aurynz."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-CODEX:module{CodexV1} CODEX)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (fea-id:string (if (!= ea-id BAR) (ref-DPTF::UR_Frozen ea-id) BAR))
                (rea-id:string (if (!= ea-id BAR) (ref-DPTF::UR_Reservation ea-id) BAR))
                (vea-id:string (if (!= ea-id BAR) (ref-DPTF::UR_Vesting ea-id) BAR))
                (sea-id:string (if (!= ea-id BAR) (ref-DPTF::UR_Sleeping ea-id) BAR))
                (hea-id:string (if (!= ea-id BAR) (ref-DPTF::UR_Hibernation ea-id) BAR))
                (standard-accounts:[string]
                    (filter
                        (lambda (account:string)
                            (not (ref-DALOS::UR_AccountType account))
                        )
                        (keys DALOS.DALOS|AccountTable)
                    )
                )
                (unsorted:[object]
                    (map
                        (lambda (account:string)
                            (let
                                (
                                    (ouro-balance:decimal
                                        (if (!= ouro-id BAR) (ref-DPTF::UR_AccountSupply ouro-id account) 0.0)
                                    )
                                    (ea-supply:decimal
                                        (if (!= ea-id BAR) (ref-DPTF::UR_AccountSupply ea-id account) 0.0)
                                    )
                                    (fea-supply:decimal
                                        (if (!= fea-id BAR) (ref-DPTF::UR_AccountSupply fea-id account) 0.0)
                                    )
                                    (rea-supply:decimal
                                        (if (!= rea-id BAR) (ref-DPTF::UR_AccountSupply rea-id account) 0.0)
                                    )
                                    (vea-supply:decimal
                                        (if (!= vea-id BAR) (ref-DPOF::UR_AccountSupply vea-id account) 0.0)
                                    )
                                    (sea-supply:decimal
                                        (if (!= sea-id BAR) (ref-DPOF::UR_AccountSupply sea-id account) 0.0)
                                    )
                                    (hea-supply:decimal
                                        (if (!= hea-id BAR) (ref-DPOF::UR_AccountSupply hea-id account) 0.0)
                                    )
                                    (total-elite-aurynz:decimal
                                        (fold (+) 0.0 [ea-supply fea-supply rea-supply vea-supply sea-supply hea-supply])
                                    )
                                    (elite-auryn-dispo-locked:bool (< ouro-balance 0.0))
                                    (ea-movable:decimal
                                        (if elite-auryn-dispo-locked
                                            0.0
                                            ea-supply
                                        )
                                    )
                                    (stba-data:object (ref-CODEX::UR_STBA|DataOrNull account))
                                    (stoic-tag:string
                                        (if (at "has-stoictag" stba-data)
                                            (at "tag-name" stba-data)
                                            BAR
                                        )
                                    )
                                )
                                {"account"                  : account
                                ,"stoic-tag"                : stoic-tag
                                ,"elite-class"              : (ref-DALOS::UR_Elite-Class account)
                                ,"elite-name"               : (ref-DALOS::UR_Elite-Name account)
                                ,"elite-tier"               : (ref-DALOS::UR_Elite-Tier account)
                                ,"ouro-balance"             : ouro-balance
                                ,"elite-auryn-dispo-locked" : elite-auryn-dispo-locked
                                ,"ea-id"                    : ea-id
                                ,"ea-supply"                : ea-supply
                                ,"ea-movable"               : ea-movable
                                ,"fea-id"                   : fea-id
                                ,"fea-supply"               : fea-supply
                                ,"rea-id"                   : rea-id
                                ,"rea-supply"               : rea-supply
                                ,"vea-id"                   : vea-id
                                ,"vea-supply"               : vea-supply
                                ,"sea-id"                   : sea-id
                                ,"sea-supply"               : sea-supply
                                ,"hea-id"                   : hea-id
                                ,"hea-supply"               : hea-supply
                                ,"total-elite-aurynz"       : total-elite-aurynz
                                }
                            )
                        )
                        standard-accounts
                    )
                )
            )
            ;; Insertion-sort descending by total-elite-aurynz
            (fold
                (lambda (sorted:[object] row:object)
                    (let
                        (
                            (t:decimal (at "total-elite-aurynz" row))
                            (higher:[object]
                                (filter
                                    (lambda (x:object) (> (at "total-elite-aurynz" x) t))
                                    sorted
                                )
                            )
                            (rest:[object]
                                (filter
                                    (lambda (x:object) (<= (at "total-elite-aurynz" x) t))
                                    sorted
                                )
                            )
                        )
                        (+ higher (+ [row] rest))
                    )
                )
                []
                unsorted
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)
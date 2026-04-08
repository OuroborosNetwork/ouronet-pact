(interface InfoOneV1
    @doc "Exposes Functions from Information One Module"
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun UC|GasPrice:decimal (full-price:decimal trigger:bool))
    ;;
    ;;
    ;;  [SIP|URC] Functions
    ;;
    (defun SIP|URC_Small:decimal ())
    (defun SIP|URC_Medium ())
    (defun SIP|URC_Big:decimal ())
    (defun SIP|URC_Biggest ())
    (defun SIP|URC_UpdatePendingBranding:decimal (m:decimal))
    (defun SIP|URC_Burn:decimal (id:string account:string))
    (defun SIP|URC_Issue:decimal (name:[string]))
    (defun SIP|URC_Mint:decimal (id:string account:string origin:bool))
    ;;
    ;;
    ;;  [SKP|URC] Functions
    ;;
    (defun SKP|URC_UpgradeBranding (months:integer))
    (defun SKP|URC_Issue (name:[string] dptf-or-dpof:bool))
    (defun SKP|URC_ToggleFeeLock (id:string toggle:bool fee-unlocks:integer))
    ;;
    ;;
    ;;  [INFO] Functions
    ;;
    (defun DPTF|INFO_UpdatePendingBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string))
    (defun DPTF|INFO_UpgradeBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string months:integer))
    (defun DPTF|INFO_Burn:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string amount:decimal))
    (defun DPTF|INFO_Control:object{OuronetInfoV1.ClientInfo} (patron:string id:string))
    (defun DPTF|INFO_DeployAccount:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string))
    (defun DPTF|INFO_DonateFees:object{OuronetInfoV1.ClientInfo} (patron:string id:string))
    (defun DPTF|INFO_Issue:object{OuronetInfoV1.ClientInfo} (patron:string account:string name:[string]))
    (defun DPTF|INFO_Mint:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string amount:decimal origin:bool))
    (defun DPTF|INFO_ResetFeeTarget:object{OuronetInfoV1.ClientInfo} (patron:string id:string))
    (defun DPTF|INFO_RotateOwnership:object{OuronetInfoV1.ClientInfo} (patron:string id:string new-owner:string))
    (defun DPTF|INFO_SetFee:object{OuronetInfoV1.ClientInfo} (patron:string id:string fee:decimal))
    (defun DPTF|INFO_SetFeeTarget:object{OuronetInfoV1.ClientInfo} (patron:string id:string target:string))
    (defun DPTF|INFO_SetMinMove:object{OuronetInfoV1.ClientInfo} (patron:string id:string min-move-value:decimal))
    (defun DPTF|INFO_ToggleFee:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool))
    (defun DPTF|INFO_ToggleFeeLock:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool fee-unlocks:integer))
    (defun DPTF|INFO_ToggleFreezeAccount:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun DPTF|INFO_TogglePause:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool))
    (defun DPTF|INFO_ToggleReservation:object{OuronetInfoV1.ClientInfo} (patron:string id:string toggle:bool))
    (defun DPTF|INFO_ToggleTransferRole:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string toggle:bool))
    (defun DPTF|INFO_Wipe:object{OuronetInfoV1.ClientInfo} (patron:string id:string atbw:string))
    (defun DPTF|INFO_WipePartial:object{OuronetInfoV1.ClientInfo} (patron:string id:string atbw:string amtbw:decimal))
    (defun DPTF|INFO_Transfer:object{OuronetInfoV1.ClientInfo} (patron:string id:string sender:string receiver:string transfer-amount:decimal))
    (defun DPTF|INFO_MultiTransfer:object{OuronetInfoV1.ClientInfo} (patron:string id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal]))
    (defun DPTF|INFO_BulkTransfer:object{OuronetInfoV1.ClientInfo} (patron:string id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal]))
    (defun DPTF|INFO_MultiBulkTransfer:object{OuronetInfoV1.ClientInfo} (patron:string id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]]))
    ;;
    (defun DPOF|INFO_UpdatePendingBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string))
    (defun DPOF|INFO_UpgradeBranding:object{OuronetInfoV1.ClientInfo} (patron:string entity-id:string months:integer))
    (defun DPOF|INFO_AddQuantity:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonce:integer account:string amount:decimal))
    (defun DPOF|INFO_Burn:object{OuronetInfoV1.ClientInfo} (patron:string id:string nonce:integer account:string amount:decimal))
    (defun DPOF|INFO_Control:object{OuronetInfoV1.ClientInfo} (patron:string id:string))
    (defun DPOF|INFO_Create:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string))
    (defun DPOF|INFO_DeployAccount:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string))
    (defun DPOF|INFO_Issue:object{OuronetInfoV1.ClientInfo} (patron:string account:string name:[string]))
    (defun DPOF|INFO_Mint:object{OuronetInfoV1.ClientInfo} (patron:string id:string account:string amount:decimal))
    ;;
    (defun VST|INFO_Hibernate:object{OuronetInfoV1.ClientInfo} (patron:string hibernator:string target-account:string dptf:string amount:decimal dayz:integer))
    ;;
    (defun ATS|INFO_Coil:object{OuronetInfoV1.ClientInfo} (patron:string coiler:string ats:string rt:string amount:decimal))
    (defun ATS|INFO_Constrict:object{OuronetInfoV1.ClientInfo}(patron:string constricter:string ats:string rt:string amount:decimal dayz:integer))
    (defun ATS|INFO_Curl:object{OuronetInfoV1.ClientInfo} (patron:string curler:string ats1:string ats2:string rt:string amount:decimal))
    (defun ATS|INFO_Brumate:object{OuronetInfoV1.ClientInfo} (patron:string brumator:string ats1:string ats2:string rt:string amount:decimal dayz:integer))
    (defun ATS|INFO_ColdRecovery:object{OuronetInfoV1.ClientInfo} (patron:string recoverer:string ats:string ra:decimal))
    (defun ATS|INFO_Cull:object{OuronetInfoV1.ClientInfo} (patron:string culler:string ats:string))
    (defun ATS|INFO_DirectRecovery:object{OuronetInfoV1.ClientInfo} (patron:string recoverer:string ats:string ra:decimal))
    ;;
    (defun SWP|INFO_AddLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string input-amounts:[decimal] kda-pid:decimal))
    (defun SWP|INFO_IcedLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string input-amounts:[decimal] kda-pid:decimal))
    (defun SWP|INFO_GlacialLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string input-amounts:[decimal] kda-pid:decimal))
    (defun SWP|INFO_FrozenLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal kda-pid:decimal))
    (defun SWP|INFO_SleepingLiquidity:object{OuronetInfoV1.ClientInfo} (patron:string account:string swpair:string sleeping-dpof:string nonce:integer kda-pid:decimal))
)
;;LIQUID|INFO_UnwrapStoa
;;LIQUID|INFO_WrapStoa
;;LIQUID|INFO_UnwrapUrStoa
(module INFO-ONE GOV
    ;;
    (implements InfoOneV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_INFO|DPTF      (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|INFO|DPTF_ADMIN)))
    (defcap GOV|INFO|DPTF_ADMIN ()  (enforce-guard GOV|MD_INFO|DPTF))
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
    (defschema HibernatedNoncesView
        nonce-supply:decimal
        mint-time:time
        release-time:time
        hibernating-fee-promile:decimal
        remainder:decimal
        hibernating-fee:decimal
    )
    ;;{2}
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defun CT_EmptyCumulator ()     (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::DALOS|EmptyOutputCumulatorV2)))
    (defun GOV|SWP|SC_NAME ()       (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|SWP|SC_NAME)))
    (defconst BAR                   (CT_Bar))
    (defconst EOC                   (CT_EmptyCumulator))
    (defconst SWP|SC_NAME           (GOV|SWP|SC_NAME))
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
    (defun UC|GasPrice:decimal (full-price:decimal trigger:bool)
        (if trigger 0.0 full-price)
    )
    (defun UCX_AddLiquidity:object{OuronetInfoV1.ClientInfo} 
        (
            patron:string account:string swpair:string input-amounts:[decimal]
            asymmetric-collection:bool gaseous-collection:bool kda-pid:decimal
        )
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-SWP:module{SwapperV2} SWP)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                ;;
                (swp-sc:string (ref-DALOS::GOV|SWP|SC_NAME))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (ld:object{SwapperLiquidityV1.LiquidityData}
                    (ref-SWPL::URC_LD swpair input-amounts)
                )
                ;;
                ;;Compute Liquidity Addition Data
                (clad:object{SwapperLiquidityV1.CompleteLiquidityAdditionData}
                    (ref-SWPL::URC|KDA-PID_CLAD account swpair ld asymmetric-collection gaseous-collection kda-pid)
                )
                (native-lp-transfer-amount:decimal (at "primary-lp" clad))
                (ifp1:decimal 
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator 
                        (at "perfect-ignis-fee" (at "clad-op" clad))
                    )
                )
                (ifp2:decimal
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                        (ref-TFT::UDC_TransferCumulator 
                            (at "type" (ref-TFT::URC_TransferClasses lp-id swp-sc account native-lp-transfer-amount))
                            lp-id 
                            swp-sc 
                            account
                        )
                    )
                )
                (ifp:decimal (+ ifp1 ifp2))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (UCXX_AddLiquidityClientInfo patron ifp swpair (ref-DALOS::UR_IgnisID) clad asymmetric-collection false false)
        )
    )
    (defun UCXX_AddLiquidityClientInfo
        (
            patron:string ifp:decimal swpair:string ignis-id:string 
            clad:object{SwapperLiquidityV1.CompleteLiquidityAdditionData}
            asymmetric-collection:bool iz-for-sleeping:bool iz-for-frozen:bool
        )
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (primary:decimal (at "primary-lp" clad))
                (secondary:decimal (at "secondary-lp" clad))
                (sum:decimal (+ primary secondary))
                (ignis-discount:decimal (ref-DALOS::URC_IgnisGasDiscount patron))
                (discount-percent:string (format "{}%" [(* 100.0 (- 1.0 ignis-discount))]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Adding Liquidity with the following Parameters and {} costs:" [ignis-id])
                    (format "Fees are discounted by {} - your IGNIS discount, Taxes are paid in Full." [discount-percent])
                    (format "{}" [(at "gaseous-text" clad)])
                    (format "{}" [(at "deficit-text" clad)])
                    (format "{}" [(at "special-text" clad)])
                    (format "{}" [(at "lqboost-text" clad)])
                    (format "{}" [(at "fueling-text" clad)])
                    (format "Fitting Operation in a single TX is {} IGNIS cheaper" [100.0])
                ]
                [
                    (if (not asymmetric-collection)
                        (if iz-for-frozen
                            (format "Succesfully added Liquidity and generated {} Frozen LP." [secondary])
                            (format "Succesfully added Liquidity and generated {} Native LP and {} Frozen LP." [primary secondary])
                        )
                        (if iz-for-sleeping
                            (format "Succesfully added Liquidity and generated {} Sleeping LP" [primary])
                            (format "Succesfully added Liquidity and generated {} Native LP" [primary])
                        )
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun UCX_Swap:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string dsid:object{UtilitySwpV1.DirectSwapInputData})
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-SWP:module{SwapperV2} SWP)
                (ref-SWPI:module{SwapperIssueV2} SWPI)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                (ref-SWPU:module{SwapperUsageV2} SWPU)
                ;;
                (lkda:string (ref-DALOS::UR_SilverStoaID))
                (swp-sc:string (ref-DALOS::GOV|SWP|SC_NAME))
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (fees:object{UtilitySwpV1.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                (input-positions:[integer] (ref-SWPI::URC_PoolTokenPositions swpair input-ids))
                (output-position:integer (ref-SWP::UR_PoolTokenPosition swpair output-id))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
                ;;
                ;;Do Swap Computation and Unwrap Object Data
                (dtso:object{UtilitySwpV1.DirectTaxedSwapOutput}
                    (ref-SWPI::UC_BareboneSwapWithFeez account pool-type dsid fees A X X-prec input-positions output-position W)
                )
                (lp-fuel:[decimal] (at "lp-fuel" dtso))
                (o-id-special:decimal (at "o-id-special" dtso))
                (o-id-liquid:decimal (at "o-id-liquid" dtso))
                (o-id-netto:decimal (at "o-id-netto" dtso))
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_MultiTransferCumulator input-ids account swp-sc input-amounts)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ico2:object{IgnisCollectorV1.OutputCumulator}
                    (if (!= o-id-special 0.0)
                        (let
                            (
                                (o-prec:integer (at output-position X-prec))
                                (special-fee-targets:[string] (ref-SWP::UR_SpecialFeeTargets swpair))
                                (target-proportions:[decimal] (ref-SWP::UR_SpecialFeeTargetsProportions swpair))
                                (target-amounts:[decimal] (ref-U|SWP::UC_SpecialFeeOutputs target-proportions o-id-special o-prec))
                                (fsft:list (ref-SWPU::UC_FilterSelfFromTargets account special-fee-targets target-amounts))
                                (f-targets:[string] (at 0 fsft))
                                (f-amounts:[decimal] (at 1 fsft))
                                (retained:decimal (at 2 fsft))
                                (adjusted-netto:decimal (+ o-id-netto retained))
                            )
                            (if (!= (length f-targets) 0)
                                (ref-TFT::UDC_MultiBulkTransferCumulator 
                                    [output-id] 
                                    swp-sc
                                    [(+ [account] f-targets)] 
                                    [(+ [adjusted-netto] f-amounts)]
                                )
                                (ref-TFT::UDC_TransferCumulator 
                                    (at "type" (ref-TFT::URC_TransferClasses output-id swp-sc account adjusted-netto))
                                    output-id 
                                    swp-sc 
                                    account
                                )
                            )
                        )
                        (ref-TFT::UDC_TransferCumulator 
                            (at "type" (ref-TFT::URC_TransferClasses output-id swp-sc account o-id-netto))
                            output-id 
                            swp-sc 
                            account
                        )
                    )
                )
                (ifp2:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico2))
                    (ifp3:decimal
                        (if (!= o-id-liquid 0.0)
                            (SIP|URC_Burn lkda swp-sc)
                            0.0
                        )
                    )
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3]))
                (lp-strings:[string] (UC_LpFuelToLpStrings pool-tokens lp-fuel))
                (o-id-netto-str:string (UC_TrimDecimalTrailingZeros o-id-netto))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Swaps {} with amounts {} to the Output-Token {}" [input-ids input-amounts output-id])
                    (format "From Input, {} go to LP Providers" [lp-strings])
                    (format "{} from Raw Output to Special Targets: {}" [output-id (UC_TrimDecimalTrailingZeros o-id-special)])
                    (format "{} from Raw Output to Liquid Boost: {}" [output-id (UC_TrimDecimalTrailingZeros o-id-liquid)])
                    (format "{} Output: {}" [output-id o-id-netto-str])
                ]
                [
                    (format "Succesfully swapped {} {} to {} {}" [input-amounts input-ids o-id-netto-str output-id])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
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
                            (format "{} {}" 
                                [
                                    (UC_TrimDecimalTrailingZeros (at idx lp-fuel))
                                    (at idx input-ids)
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
    ;;{F0}  [UR]
    ;;{F1}  [URC]
    ;;
    ;;  [SIP|URC] - Simple Ignis Price >> dependent on a single trigger
    ;;
    (defun SIP|URC_Small:decimal ()
        @doc "<DPTF|C_Control> \
            \ <DPTF|C_DeployAccount> \
            \ <DPTF|C_SetFee> \
            \ <DPTF|C_SetFeeTarget> \
            \ <DPTF|C_SetMinMove> \
            \ <DPTF|C_ToggleFee> \
            \ <DPTF|C_ToggleFeeLock> \
            \ <DPOF|C_AddQuantity> \
            \ <DPOF|C_Burn> \
            \ <DPOF|C_DeployAccount>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (ref-DALOS::UR_UsagePrice "ignis|small")
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_Medium ()
        @doc "<DPTF|C_TogglePause> \
            \ <DPTF|C_ToggleReservation>\
            \ <DPOF|C_Control> \
            \ <DPOF|C_Mint>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (ref-DALOS::UR_UsagePrice "ignis|medium")
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_Big:decimal ()
        @doc "<DPTF|C_RotateOwnership>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (ref-DALOS::UR_UsagePrice "ignis|big")
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_Biggest ()
        @doc "<DPTF|C_ToggleFreezeAccount> \
            \ <DPOF|C_ToggleFreezeAccount> \
            \ <DPTF|C_ToggleTransferRole> \
            \ <DPTF|C_Wipe> \
            \ <DPTF|C_WipePartial>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (ref-DALOS::UR_UsagePrice "ignis|biggest")
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_UpdatePendingBranding:decimal (m:decimal)
        @doc "<DPTF|C_UpdatePendingBranding> >> m = 1"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (* m (ref-DALOS::UR_UsagePrice "ignis|branding"))
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_Burn:decimal (id:string account:string)
        @doc "<DPTF|C_Burn>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (ref-DALOS::UR_UsagePrice "ignis|small")
                (ref-IGNIS::URC_ZeroGAS id account)
            )
        )
    )
    (defun SIP|URC_Issue:decimal (name:[string])
        @doc "<DPTF|C_Issue"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (* (dec (length name)) (ref-DALOS::UR_UsagePrice "ignis|token-issue"))
                (ref-IGNIS::URC_IsVirtualGasZero)
            )
        )
    )
    (defun SIP|URC_Mint:decimal (id:string account:string origin:bool)
        @doc "<DPTF|C_Mint>"
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (UC|GasPrice 
                (if origin (ref-DALOS::UR_UsagePrice "ignis|biggest") (ref-DALOS::UR_UsagePrice "ignis|small"))
                (ref-IGNIS::URC_ZeroGAS id account)
            )
        )
    )
    ;;
    ;;  [SKP|URC] - Simple Kadena Price 
    ;;
    (defun SKP|URC_UpgradeBranding (months:integer)
        @doc "<DPTF|C_UpgradeBranding>"
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (blue:decimal (ref-DALOS::UR_UsagePrice "blue"))
            )
            (* (dec months) blue)
        )
    )
    (defun SKP|URC_Issue (name:[string] dptf-or-dpof:bool)
        @doc "<DPTF|C_Issue> \
            \ <DPOF|C_Issue>"                
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (l1:integer (length name))
                (dptf:decimal (ref-DALOS::UR_UsagePrice "dptf"))
                (dpof:decimal (ref-DALOS::UR_UsagePrice "dpmf"))
                (kfp:decimal (if dptf-or-dpof dptf dpof))
            )
            (UC|GasPrice
                (* (dec l1) kfp)
                (ref-IGNIS::URC_IsNativeGasZero)
            )
        )
    )
    (defun SKP|URC_ToggleFeeLock (id:string toggle:bool fee-unlocks:integer)
        @doc "<DPTF|ToggleFeeLock>"
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV1} U|DPTF)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (prices:[decimal]
                    (if toggle
                        [0.0 0.0]
                        (ref-U|DPTF::UC_UnlockPrice fee-unlocks)
                    )
                )
            )
            (UC|GasPrice
                (at 1 prices)
                (ref-IGNIS::URC_IsNativeGasZero)
            )
        )
    )
    ;;
    ;;  [INFO] - Informational URC Functions
    ;;
    ;;  [DPTF]
    (defun DPTF|INFO_UpdatePendingBranding:object{OuronetInfoV1.ClientInfo}
        (patron:string entity-id:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Update Pending Branding for {} DPTF" [entity-id])]
                [(format "Pending Branding for DPTF {} updated succesfully" [entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_UpdatePendingBranding 1.0))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun DPTF|INFO_UpgradeBranding:object{OuronetInfoV1.ClientInfo}
        (patron:string entity-id:string months:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Upgrade Branding for {} DPTF for {} month(s)" [entity-id months])]
                [(format "DPTF {} succesfully upgraded for {} months(s)!" [entity-id months])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_UpgradeBranding months))
                []
            )
        )
    )
    (defun DPTF|INFO_Burn:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Burn {} {} on Account {}" [amount id sa])]
                [(format "Succesfully burned {} {} on Account {}" [amount id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Burn id account))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [amount]
            )
        )
    )
    (defun DPTF|INFO_Control:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Control DPTF {} Boolean Properties" [id])]
                [(format "Succesfully controlled Properties of {}" [id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun DPTF|INFO_DeployAccount:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string)
        (let
            (
                
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Deploys a new {} DPTF Account." [id])
                    (format "Deploys Token {} on the Ouronet Account {}" [id sa])
                ]
                [(format "DPTF {} added to {} Ouronet Account succesfully!" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun DPTF|INFO_DonateFees:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|DALOS|SC_NAME)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Donates {} collected Fees" [id])
                    (format "Collection Location: Ouronet Gas Station: {}" [sa])
                ]
                [(format "Fee Collection succesfully set to {}" [sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun DPTF|INFO_Issue:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string name:[string])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Issues {} DPTF(s)" [name])
                    (format "Also issues DPTF Accounts on {} Account" [sa])
                ]
                [(format "DPTF Issuance of {} succesfully completed" [name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Issue name))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Issue name true))
                []
            )
        )
    )
    (defun DPTF|INFO_Mint:object{OuronetInfoV1.ClientInfo} 
        (patron:string id:string account:string amount:decimal origin:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if origin
                        (format "Operation: Premine {} {} on Account {}" [amount id sa])
                        (format "Operation: Mint {} {} on Account {}" [amount id sa])
                    )
                ]
                [
                    (if origin
                        (format "Succesfully premined {} {} on Account {}" [amount id sa])
                        (format "Succesfully minted {} {} on Account {}" [amount id sa])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Mint id account origin))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [amount]
            )
        )
    )
    (defun DPTF|INFO_ResetFeeTarget:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|OUROBOROS|SC_NAME)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Resets Collection of Fees for {}" [id])
                    (format "Collection Location: Ouroboros Smart Ouronet Account {}" [sa])
                ]
                [(format "Fee Collection succesfully set to {}" [sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun DPTF|INFO_RotateOwnership:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string new-owner:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount new-owner))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Changes Ownership for {} to {}" [id sa])]
                [(format "ID {} Ownership succesfully set to {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun DPTF|INFO_SetFee:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string fee:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets fee for {} to {} Promille" [id fee])]
                [(format "Fee Promille succesfully set to {} Promille for {}" [fee id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [fee]
            )
        )
    )
    (defun DPTF|INFO_SetFeeTarget:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string target:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount target))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets fee target for {} to {} " [id sa])]
                [(format "Fee Target succesfully set for {} to {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [target]
            )
        )
    )
    (defun DPTF|INFO_SetMinMove:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string min-move-value:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Sets MinMove Value target for {} to {} " [id min-move-value])]
                [(format "MinMove Value succesfully set for {} to {}" [id min-move-value])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [min-move-value]
            )
        )
    )
    (defun DPTF|INFO_ToggleFee:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Activates Fee Collection for {}" [id])
                        (format "Operation: Deactivates Fee Collection for {}" [id])
                    )
                ]
                [
                    (if toggle
                        (format "Fee Collection activated succesfully for {}" [id])
                        (format "Fee Collection deactivated succesfully for {}" [id])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [toggle]
            )
        )
    )
    (defun DPTF|INFO_ToggleFeeLock:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string toggle:bool fee-unlocks:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Locks Fee Settings for {}" [id])
                        (format "Operation: Unlocks Fee Collection for {}" [id])
                    )
                ]
                [
                    (if toggle
                        (format "Fee Settings succesfully locked for {}" [id])
                        (format "Fee Settings succesfully unlocked  for {}" [id])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_ToggleFeeLock id toggle fee-unlocks))
                [toggle]
            )
        )
    )
    (defun DPTF|INFO_ToggleFreezeAccount:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Freezes ID {} on Account" [id sa])
                        (format "Operation: Unfreezes ID {} on Account" [id sa])
                    )
                ]
                [
                    (if toggle
                        (format "Account {} succesfully frozen for {}" [sa id])
                        (format "Account {} succesfuly unfrozen for {}" [sa id])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [toggle]
            )
        )
    )
    (defun DPTF|INFO_TogglePause:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Pauses ID {}" [id])
                        (format "Operation: Unpauses ID {}" [id])
                    )
                ]
                [
                    (if toggle
                        (format "ID {} succesfully pauses" [id])
                        (format "ID {} succesfully unpauses" [id])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [toggle]
            )
        )
    )
    (defun DPTF|INFO_ToggleReservation:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Opens Reservations for {}" [id])
                        (format "Operation: Closes Reservations for {}" [id])
                    )
                ]
                [
                    (if toggle
                        (format "Reservations succesfully opened for {}" [id])
                        (format "Reservations succesfully closed for {}" [id])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [toggle]
            )
        )
    )
    (defun DPTF|INFO_ToggleTransferRole:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string toggle:bool)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if toggle
                        (format "Operation: Adds Transfer Role for {} to {}" [id sa])
                        (format "Operation: Removes Transfer Role for {} to {}" [id sa])
                    )
                ]
                [
                    (if toggle
                        (format "Transfer Role succesfuly added for {} to {}" [id sa])
                        (format "Transfer Role succesfuly removed for {} to {}" [id sa])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [toggle]
            )
        )
    )
    (defun DPTF|INFO_Wipe:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string atbw:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount atbw))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Wipes all {} from account {}" [id sa])]
                [(format "Succesfully wiped all {} from account {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [atbw]
            )
        )
    )
    (defun DPTF|INFO_WipePartial:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string atbw:string amtbw:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount atbw))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Wipes {} {} from account {}" [amtbw id sa])]
                [(format "Succesfully wiped {} {} from account {}" [amtbw id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Biggest))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [atbw amtbw]
            )
        )
    )
    (defun DPTF|INFO_Transfer:object{OuronetInfoV1.ClientInfo} 
        (patron:string id:string sender:string receiver:string transfer-amount:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (what-type:integer (at "type" (ref-TFT::URC_TransferClasses id sender receiver transfer-amount)))
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator what-type id sender receiver)
                )
                (receiver-amount:decimal (ref-TFT::URC_ReceiverAmount id sender receiver transfer-amount))
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                ;;
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                ;;
                (ea:string (ref-DALOS::UR_EliteAurynID))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (sender-ouro-supply:decimal (ref-DALOS::UR_TF_AccountSupply sender true))
                (dispo-check:bool (fold (and) true [(= id ea) (< sender-ouro-supply 0.0)]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                (if dispo-check
                    [
                        (format "Operation: Attempts to transfer {} {} from {} to {}" [transfer-amount id sa-s sa-r])
                        (format "This operation cannot execute for {} when {} {} Supply is Negative (current supply {})" [ea sa-s ouro sender-ouro-supply])
                        (format "In order to transfer {}, an {} supply of at least 0.0 is required." [ea ouro])
                    ]
                    [
                        (format "Operation: Transfers {} {} from {} to {}" [transfer-amount id sa-s sa-r])
                        (if (= receiver-amount transfer-amount)
                            (format "Receiver will receiver the full amount of {} {}" [transfer-amount id])
                            (format "Due to Fee Settings, Receiver will receive only {} {}" [receiver-amount id])
                        )
                    ]
                )
                [
                    (if (= receiver-amount transfer-amount)
                        (format "Succesfully transfered {} {} from {} to {}, moving the Full Amount to the Receiver" [transfer-amount id sa-s sa-r])
                        (format "Succesfully transfered {} {} from {} to {}, moving only {} to the Receiver due to DPTF Fee Settings" [transfer-amount id sa-s sa-r receiver-amount])
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount receiver-amount)]
            )
        )
    )
    (defun DPTF|INFO_MultiTransfer:object{OuronetInfoV1.ClientInfo} 
        (patron:string id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal])
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_MultiTransferCumulator id-lst sender receiver transfer-amount-lst)
                )
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                ;;
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                ;;
                (ea:string (ref-DALOS::UR_EliteAurynID))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (sender-ouro-supply:decimal (ref-DALOS::UR_TF_AccountSupply sender true))
                (has-ea:bool (contains ea id-lst))
                (dispo-check:bool (fold (and) true [has-ea (< sender-ouro-supply 0.0)]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                (if dispo-check
                    [
                        (format "Operation: Transfers {} DPTFs as a Multi-Transfer" [(length id-lst)])
                        (format "DPTFs are: {}" [id-lst])
                        (format "Transfer cannot execute, as moving {} requires at least 0.0 {} Balance on {}" [ea ouro sa-s])
                        (format "To proceed, either remove {} from the list, or bring the {} Balance on {} to at least 0.0" [ea ouro sa-s])
                    ]
                    [
                        (format "Operation: Transfers {} DPTFs as a Multi-Transfer" [(length id-lst)])
                        (format "DPTFs are: {}" [id-lst])
                        (format "Amounts are in their order: {}" [transfer-amount-lst])
                        (format "Movement occurs from {} to {}" [sa-s sa-r])
                    ]
                )
                
                [(format "Succesfully multi-transfered {} DPTFs from {} to {}" [(length id-lst) sa-s sa-r])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [id-lst transfer-amount-lst]
            )
        )
    )
    (defun DPTF|INFO_BulkTransfer:object{OuronetInfoV1.ClientInfo} 
        (patron:string id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_BulkTransferCumulator id sender receiver-lst transfer-amount-lst)
                )
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                ;;
                (ea:string (ref-DALOS::UR_EliteAurynID))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (sender-ouro-supply:decimal (ref-DALOS::UR_TF_AccountSupply sender true))
                (dispo-check:bool (fold (and) true [(= id ea) (< sender-ouro-supply 0.0)]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                (if dispo-check
                    [
                        (format "Operation: Transfers {} DPTF in Bulk" [id])
                        (format "Operation cannot execute, as moving {} requires at least 0.0 {} Balance on {}" [ea ouro sa-s])
                        (format "To proceed, bring the {} Balance on {} to at least 0.0" [ouro sa-s])
                    ]
                    [
                        (format "Operation: Transfers {} DPTF in Bulk" [id])
                        (format "Bulk Transfer means from one Sender, {} to multiple receivers" [sa-s])
                    ]
                )
                [(format "Succesfully bulk-transfered {} DPTF from {} to {} Receivers" [id sa-s (length receiver-lst)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [receiver-lst transfer-amount-lst]
            )
        )
    )
    (defun DPTF|INFO_MultiBulkTransfer:object{OuronetInfoV1.ClientInfo} 
        (patron:string id-lst:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]])
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_MultiBulkTransferCumulator id-lst sender receiver-array transfer-amount-array)
                )
                (ifp:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico))
                (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                ;;
                (ea:string (ref-DALOS::UR_EliteAurynID))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (sender-ouro-supply:decimal (ref-DALOS::UR_TF_AccountSupply sender true))
                (has-ea:bool (contains ea id-lst))
                (dispo-check:bool (fold (and) true [has-ea (< sender-ouro-supply 0.0)]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                (if dispo-check
                    [
                        (format "Operation: Transfers {} DPTFs in MultiBulk at once" [(length id-lst)])
                        (format "DPTFs are: {}" [id-lst])
                        (format "MultiBulkTransfer cannot execute, as moving {} requires at least 0.0 {} Balance on {}" [ea ouro sa-s])
                        (format "To proceed, either remove {} from the list, or bring the {} Balance on {} to at least 0.0" [ea ouro sa-s])
                    ]
                    [
                        (format "Operation: Transfers {} DPTFs in Bulk at once" [(length id-lst)])
                        (format "DPTFs are: {}" [id-lst])
                        (format "Transfer occurs from Sender, {} to multiple receivers, specific for each DPTF" [sa-s])
                        (format "Bulk Transfer DPTFs are {}" [id-lst])
                    ]
                )
                [(format "Succesfully multi-bulk-transfered {} DPTFs from Sender {} to {} Individual Receiver Lists" [(length id-lst) sa-s (length receiver-array)])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [id-lst receiver-array transfer-amount-array]
            )
        )
    )
    (defun DPTF|INFO_ClearDispo:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV1} ATS)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (a-id:string (ref-DALOS::UR_AurynID))
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (ouro-amount:decimal (abs (ref-DPTF::UR_AccountSupply ouro-id account)))
            )
            (enforce (< ouro-amount 0.0) "Dispo Clear requires Negative OURO")
            (let
                (
                    (account-ea-supply:decimal (ref-DPTF::UR_AccountSupply ea-id account))
                    (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ea-id account))
                    ;;
                    (auryndex:string (at 0 (ref-DPTF::UR_RewardToken ouro-id)))
                    (elite-auryndex:string (at 0 (ref-DPTF::UR_RewardToken a-id)))
                    (auryndex-value:decimal (ref-ATS::URC_Index auryndex))
                    (elite-auryndex-value:decimal (ref-ATS::URC_Index elite-auryndex))
                    ;;
                    (o-prec:integer (ref-DPTF::UR_Decimals ouro-id))
                    (a-prec:integer (ref-DPTF::UR_Decimals a-id))
                    (ea-prec:integer (ref-DPTF::UR_Decimals ea-id))
                    ;;
                    (burn-auryn-amount:decimal (floor (/ ouro-amount auryndex-value) a-prec))
                    (burn-elite-auryn-amount:decimal (floor (/ burn-auryn-amount elite-auryndex-value) ea-prec))
                    (total-ea:decimal (floor (* burn-elite-auryn-amount 2.5) ea-prec))
                    (ats-sc:string (ref-DALOS::GOV|ATS|SC_NAME))
                    ;;
                    (ifp1:decimal
                        (if (not frozen-state)
                            (SIP|URC_Biggest)
                            0.0
                        )
                    )
                    (ifp2:decimal (SIP|URC_Biggest))
                    (ifp3:decimal (SIP|URC_Biggest))
                    (ifp4:decimal (SIP|URC_Burn a-id ats-sc))
                    (ifp5:decimal (SIP|URC_Burn ouro-id ats-sc))
                    (ifp:decimal (fold [+] 0.0 [ifp1 ifp2 ifp3 ifp4 ifp5]))
                )
                (ref-I|OURONET::OI|UDC_ClientInfo
                    [
                        (format "Operation: Clear the Negative Dispo of {} {} by leveraging EliteAuryn Supply" [ouro-amount ouro-id])
                        (format "{} {} is used to cover the Debt" [burn-elite-auryn-amount ea-id])
                        (format "{} {} is used as extra cost for the operation set to increase the {} Index" [(- total-ea burn-elite-auryn-amount) ea-id elite-auryndex])
                    ]
                    [(format "Succesfully cleared negative {} using {} {}" [ouro-id total-ea ea-id])]
                    (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                    (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                    []
                )
            )
        )
    )
    ;;  [DPOF]
    (defun DPOF|INFO_UpdatePendingBranding:object{OuronetInfoV1.ClientInfo}
        (patron:string entity-id:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Update Pending Branding for {} DPOF" [entity-id])]
                [(format "Pending Branding for DPOF {} updated succesfully" [entity-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_UpdatePendingBranding 1.5))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun DPOF|INFO_UpgradeBranding:object{OuronetInfoV1.ClientInfo}
        (patron:string entity-id:string months:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Upgrade Branding for {} DPOF for {} month(s)" [entity-id months])]
                [(format "DPOF {} succesfully upgraded for {} months(s)!" [entity-id months])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|OI|UDC_DynamicKadenaCost patron (SKP|URC_UpgradeBranding months))
                []
            )
        )
    )
    (defun DPOF|INFO_AddQuantity:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string nonce:integer account:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Adds {} to DPOF {} Nonce {} on Account {}" [amount id nonce sa])]
                [(format "Succesfully increased DPOF {} nonce {} quantity on Account {} by {}" [id nonce sa amount])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [amount]
            )
        )
    )
    (defun DPOF|INFO_Burn:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string nonce:integer account:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Burns {} Units of DPOF {} Nonce {} on Account {}" [amount id nonce sa])]
                [(format "Succesfully burned {} Units of DPOF {} Nonce {} on Account {}" [amount id nonce sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [amount]
            )
        )
    )
    (defun DPOF|INFO_Control:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Controls DPOF {} Boolean Properties" [id])]
                [(format "Succesfully controlled DPOF {} Boolean Properties" [id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun DPOF|INFO_Create:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Creates a new Batch for the DPOF {} without quantity on Account {}" [id sa])]
                [(format "Succesfully created a new Batch for DPOF {} on Account {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Medium))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun DPOF|INFO_DeployAccount:object{OuronetInfoV1.ClientInfo}
        (patron:string id:string account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Deploy a DPOF Account for DPOF {} on Ouronet Account {}" [id sa])]
                [(format "Succesfully deployed a New DPOF Account for DPOF {} on Ouronet Account {}" [id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Small))
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun DPOF|INFO_Issue:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string name:[string])
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Issues {} DPOF(s)" [name])
                    (format "Also issues DPTF Accounts on {} Account" [sa])
                ]
                [(format "DPOF Issuance of {} succesfully completed" [name])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (SIP|URC_Issue name))
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron (SKP|URC_Issue name false))
                []
            )
        )
    )
    (defun DPOF|INFO_Mint:object{OuronetInfoV1.ClientInfo} 
        (patron:string id:string account:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                ;;
                (medium:decimal (SIP|URC_Medium))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Mint {} {} on Account {}, on a new Nonce" [amount id sa])]
                [(format "Succesfully minted {} {} on Account {}, on a new Nonce" [amount id sa])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron medium)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount amount)]
            )
        )
    )
    ;;  [VST]
    (defun VST|INFO_Hibernate:object{OuronetInfoV1.ClientInfo}
        (patron:string hibernator:string target-account:string dptf:string amount:decimal dayz:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-VST:module{VestingV1} VST)
                (vst-sc:string (ref-VST::GOV|VST|SC_NAME))
                ;;
                ;;Operation 1 Mint DPOF
                (ifp1:decimal (SIP|URC_Medium))
                ;;Operation 2 Transfer DPTF
                (wt2:integer (at "type" (ref-TFT::URC_TransferClasses dptf hibernator vst-sc amount)))
                (ico2:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator wt2 dptf hibernator vst-sc)
                )
                (ifp2:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico2))
                ;;Operation 3 Transfer DPOF
                (ifp3:decimal (SIP|URC_Small))
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3]))
                ;;
                (sa-hibernator:string (ref-I|OURONET::OI|UC_ShortAccount hibernator))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Hibernates {} {} for {} Days" [amount dptf dayz])
                ]
                [
                    (format "Sucesfully hibernated {} {} on Account {} for a Duration of {} days." [amount dptf sa-hibernator dayz])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount amount) dayz]
            )
        )
    )
    (defun VST|INFO_Awake:object{OuronetInfoV1.ClientInfo}
        (patron:string awaker:string dpof:string nonce:integer)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV1} U|ATS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
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
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-DPOF::UC_MoveCumulator dpof [nonce] false)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (SIP|URC_Small))
                (wt3:integer (at "type" (ref-TFT::URC_TransferClasses dptf-id vst-sc awaker remainder)))
                (ico3:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator wt3 dptf-id vst-sc awaker)
                )
                (ifp3:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico3))
                (ifp4:decimal
                    (if (!= hibernating-fee 0.0)
                        (SIP|URC_Burn dptf-id vst-sc)
                        0.0
                    )
                )
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3 ifp4]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Awakens {} Nonce {}, returning its underlying DPTF, {}." [dpof nonce dptf-id])
                    (format "The maximum awakening fee of 800‰ is currently at {}‰." [hibernating-fee-promile])
                    (if (= hibernating-fee 0.0)
                        (format "This will release {} DPTF Tokens, with no awakening fee." [remainder])  
                        (format "This will release {} DPTF Tokens, while witholding {} as awakening fee." [remainder hibernating-fee])
                    )
                ]
                [
                    (format "Succesfully awakend {} Nonce {} returning {} {}." [dpof nonce dptf-id remainder])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun VST|INFO_Slumber:object{OuronetInfoV1.ClientInfo}
        (patron:string merger:string dpof:string nonces:[integer])
        (let
            (
                
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-VST:module{VestingV1} VST)
                ;;
                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                (dptf:string (ref-DPOF::UR_Hibernation dpof))
                (sm:string (ref-I|OURONET::OI|UC_ShortAccount merger))
                ;;
                (nonces-used:integer (ref-DPOF::UR_NoncesUsed dpof))
                (nonces-supplies:[decimal] (ref-DPOF::UR_NoncesSupplies dpof nonces))
                (sum:decimal (fold (+) 0.0 nonces-supplies))
                (how-many:decimal (dec (length nonces)))
                (biggest:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (price:decimal (* how-many biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                ;;
                (stu:[decimal] (ref-VST::URC_SecondsToUnlock dpof nonces))
                (compute-merge-all:[decimal] (ref-VST::UC_MergeAll nonces-supplies stu))
                ;;
                (free-amount:decimal (at 0 compute-merge-all))
                (locked-amount:decimal (at 1 compute-merge-all))
                (weigthed-locked-amount-in-seconds:integer (floor (at 2 compute-merge-all)))
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price vst-sc trigger [])
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (* 2.0 (SIP|URC_Biggest)))
                (ico3:object{IgnisCollectorV1.OutputCumulator}
                    (ref-DPOF::UC_WipeCumulator dpof 
                        (ref-DPOF::UDC_RemovableNonces nonces nonces-supplies )
                    )
                )
                (ifp3:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico3))
                (ifp4:decimal
                    (if (!= free-amount 0.0)
                        (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                            (ref-TFT::UDC_TransferCumulator 
                                (at "type" (ref-TFT::URC_TransferClasses dptf vst-sc merger free-amount))
                                dptf vst-sc merger
                            )
                        )
                        0.0
                    )
                )
                (ifp5:decimal
                    (if (!= locked-amount 0.0)
                        (+
                            (SIP|URC_Medium)
                            (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                                (ref-DPOF::UC_MoveCumulator dpof [(+ 1 nonces-used)] false)
                            )
                        )
                        0.0
                    )
                )
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3 ifp4 ifp5]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Slumbers {} {} Nonces {}, merging and awakening then." [how-many dpof nonces])
                    (format "Awakening happens automatically for all nonces at {}% fee" [0.0])
                    (if (!= free-amount 0.0)
                        (format "Released Amount will be {}!" [free-amount])
                        "There will be no release amount, as none of the selected Nonces are ripe!"
                    )
                    (if (!= locked-amount 0.0)
                        (let
                            (
                                (ref-U|VST:module{UtilityVstV1} U|VST)
                                (release-date:time (at 0 (ref-U|VST::UC_MakeVestingDateList 0 weigthed-locked-amount-in-seconds 1)))
                            )
                            (format "An amount of {} due for release at {} still remains locked!" [locked-amount release-date])
                        )
                        "There will be no locked amount, as all selected Nonces are ripe!"
                    )
                ]
                [
                    (format "Succesfully merged Hibernated DPOF {} Nonces {} to Account {}" [dpof nonces sm])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun VST|INFO-HibernatedNoncesDisplay:[object{HibernatedNoncesView}]
        (account:string dpof:string)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
                (owned-nonces:[integer] (ref-DPOF::URD_AccountNonces account dpof))
                (l:integer (length owned-nonces))
            )
            (map
                (lambda
                    (idx:integer)
                    (VST|INFO-HibernatedNonceDisplay dpof (at idx owned-nonces))
                )
                (enumerate 0 (- l 1))
            )
        )
    )
    (defun VST|INFO-HibernatedNonceDisplay:object{HibernatedNoncesView}
        (dpof:string nonce:integer)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV1} U|ATS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                ;;
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
            (UDC_HibernatedNoncesView
                nonce-supply mint-time release-time hibernating-fee-promile remainder hibernating-fee
            )
        )
    )
    ;;  [ATS]
    (defun ATS|INFO_Coil:object{OuronetInfoV1.ClientInfo}
        (patron:string coiler:string ats:string rt:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-ATS:module{AutostakeV1} ATS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ats-sc:string (ref-ATS::GOV|ATS|SC_NAME))
                ;;
                (coil-data:object{AutostakeV1.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats rt amount)
                )
                (input-amount:decimal (at "first-input-amount" coil-data))
                (royalty-fee:decimal (at "royalty-fee" coil-data))
                (c-rbt:string (at "rbt-id" coil-data))
                (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                ;;
                ;;Operation 1 - Transfer
                (wt1:integer (at "type" (ref-TFT::URC_TransferClasses rt coiler ats-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator wt1 rt coiler ats-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                ;;Operation 2 - Mint
                (ifp2:decimal (SIP|URC_Mint c-rbt ats-sc false))
                ;;Operation 3 - Transfer
                (wt3:integer (at "type" (ref-TFT::URC_TransferClasses c-rbt ats-sc coiler c-rbt-amount)))
                (ico3:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator wt3 rt coiler ats-sc)
                )
                (ifp3:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico3))
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3]))
                ;;
                (sa-coiler:string (ref-I|OURONET::OI|UC_ShortAccount coiler))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    ;;<ATS1>
                    (format "Operation: Autostakes {} {} on the {} ATS-Pair." [amount rt ats])
                    (if (= royalty-fee 0.0)
                        (format "Deposit will be executed without any {} Royalty." [rt])
                        (format "{} {} will be retained as Royalty on the Autostake Pool." [royalty-fee rt])
                    )
                    (format "Coil will generate {} {} as final output." [c-rbt-amount c-rbt])
                ]
                [
                    (format "Succesfully coiled {} {} on ATS-Pair {} generating {} {} on {} Account." [amount rt ats c-rbt-amount c-rbt sa-coiler])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount c-rbt-amount)]
            )
        )
    )
    (defun ATS|INFO_Constrict:object{OuronetInfoV1.ClientInfo}
        (patron:string constricter:string ats:string rt:string amount:decimal dayz:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV1} ATS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ats-sc:string (ref-ATS::GOV|ATS|SC_NAME))
                ;;
                (coil-data:object{AutostakeV1.CoilData} 
                    (ref-ATS::URC_RewardBearingTokenAmountsWithHibernation ats rt amount dayz)
                )
                (input-amount:decimal (at "first-input-amount" coil-data))
                (royalty-fee:decimal (at "royalty-fee" coil-data))
                (c-rbt:string (at "rbt-id" coil-data))
                (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                ;;
                (peak:decimal (ref-ATS::UR_PeakHibernatePromile ats))
                (decay:decimal (ref-ATS::UR_HibernateDecay ats))
                (dec-dayz:decimal (dec dayz))
                (v1:decimal (* dec-dayz decay))
                (v2:decimal (- peak v1))
                (fee-promile:decimal 
                    (if (<= v2 0.0)
                        0.0
                        v2
                    )
                )
                (hibernate-entry-percent:string (format "{}%" [(/ fee-promile 10.0)]))
                ;;
                ;;Operation 1 - Transfer
                (wt1:integer (at "type" (ref-TFT::URC_TransferClasses rt constricter ats-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator wt1 rt constricter ats-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                ;;Operation 2 - Mint
                (ifp2:decimal (SIP|URC_Mint c-rbt ats-sc false))
                ;;Operation 3 - Hibernate
                (ifp3:decimal (at "ignis-full" (at "ignis" (VST|INFO_Hibernate patron ats-sc constricter c-rbt c-rbt-amount dayz))))
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3]))
                ;;
                (sa-constricter:string (ref-I|OURONET::OI|UC_ShortAccount constricter))
                (ht:string (ref-DPTF::UR_Hibernation c-rbt))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    ;;<ATS1>
                    (format "Operation: Autostakes {} {} on the {} ATS-Pair." [amount rt ats])
                    (if (= royalty-fee 0.0)
                        (format "Deposit will be executed without any {} Royalty." [rt])
                        (format "{} {} will be retained as Royalty on the Autostake Pool." [royalty-fee rt])
                    )
                    (format "Constricting for {} Days will incurr a hibernation fee of {} on the Input {} after Royalty" [dayz hibernate-entry-percent c-rbt])
                    (format "Constricting will generate {} {} as final output." [c-rbt-amount ht])
                ]
                [
                    (format "Succesfully constricted {} {} on ATS-Pair {} generating {} {} on {} Account." [amount rt ats c-rbt-amount ht sa-constricter])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount c-rbt-amount)]
            )
        )
    )
    (defun ATS|INFO_Curl:object{OuronetInfoV1.ClientInfo}
        (patron:string curler:string ats1:string ats2:string rt:string amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-ATS:module{AutostakeV1} ATS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ats-sc:string (ref-ATS::GOV|ATS|SC_NAME))
                ;;
                ;;<ats1>
                (coil1-data:object{AutostakeV1.CoilData} 
                    (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                )
                (input1-amount:decimal (at "first-input-amount" coil1-data))
                (royalty1-fee:decimal (at "royalty-fee" coil1-data))
                (c-rbt1:string (at "rbt-id" coil1-data))
                (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                ;;
                ;;<ats2>
                (coil2-data:object{AutostakeV1.CoilData} 
                    (ref-ATS::URC_RewardBearingTokenAmounts ats2 c-rbt1 c-rbt1-amount)
                )
                (input2-amount:decimal (at "first-input-amount" coil2-data))
                (royalty2-fee:decimal (at "royalty-fee" coil2-data))
                (c-rbt2:string (at "rbt-id" coil2-data))
                (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                ;;
                ;;Operation 1 - Transfer
                (wt1:integer (at "type" (ref-TFT::URC_TransferClasses rt curler ats-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator wt1 rt curler ats-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                ;;Operation 2 - Mint
                (ifp2:decimal (SIP|URC_Mint c-rbt1 ats-sc false))
                ;;Operation 3 - Mint
                (ifp3:decimal (SIP|URC_Mint c-rbt2 ats-sc false))
                ;;Operation 4 - Transfer
                (wt4:integer (at "type" (ref-TFT::URC_TransferClasses c-rbt2 ats-sc curler c-rbt2-amount)))
                (ico4:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator wt4 c-rbt2 ats-sc curler)
                )
                (ifp4:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico4))
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3 ifp4]))
                ;;
                (sa-curler:string (ref-I|OURONET::OI|UC_ShortAccount curler))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    ;;<ATS1>
                    (format "Operation: Autostakes {} {} on the {} ATS-Pair." [amount rt ats1])
                    (if (= royalty1-fee 0.0)
                        (format "Deposit in the first Autostake Pool will be executed without any {} Royalty." [rt])
                        (format "{} {} will be retained as Royalty on the First Autostake Pool." [royalty1-fee rt])
                    )
                    (format "An Intermediary Output of {} {} will be generated" [c-rbt1-amount c-rbt1])
                    ;;<ATS2>
                    (format "The Output {} will then be further autostaked on the second ATS-Pair, the {}." [c-rbt1 ats2])
                    (if (= royalty2-fee 0.0)
                        (format "Deposit in the second Autostake Pool will be executed without any {} Royalty." [c-rbt1])
                        (format "{} {} will be retained as Royalty on the Second Autostake Pool." [royalty2-fee c-rbt1])
                    )
                    (format "Curl will generate {} {} as final output." [c-rbt2-amount c-rbt2])
                ]
                [
                    (format "Succesfully curled {} {} on ATS-Pairs {} and {} generating {} {} on {} Account." [amount rt ats1 ats2 c-rbt2-amount c-rbt2 sa-curler])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount c-rbt2-amount)]
            )
        )
    )
    (defun ATS|INFO_Brumate:object{OuronetInfoV1.ClientInfo}
        (patron:string brumator:string ats1:string ats2:string rt:string amount:decimal dayz:integer)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV1} ATS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ats-sc:string (ref-ATS::GOV|ATS|SC_NAME))
                ;;
                ;;<ats1>
                (coil1-data:object{AutostakeV1.CoilData} 
                    (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                )
                (input1-amount:decimal (at "first-input-amount" coil1-data))
                (royalty1-fee:decimal (at "royalty-fee" coil1-data))
                (c-rbt1:string (at "rbt-id" coil1-data))
                (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                ;;
                ;;<ats2>
                (coil2-data:object{AutostakeV1.CoilData} 
                    (ref-ATS::URC_RewardBearingTokenAmountsWithHibernation ats2 c-rbt1 c-rbt1-amount dayz)
                )
                (input2-amount:decimal (at "first-input-amount" coil2-data))
                (royalty2-fee:decimal (at "royalty-fee" coil2-data))
                (c-rbt2:string (at "rbt-id" coil2-data))
                (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                ;;
                (peak:decimal (ref-ATS::UR_PeakHibernatePromile ats2))
                (decay:decimal (ref-ATS::UR_HibernateDecay ats2))
                (dec-dayz:decimal (dec dayz))
                (v1:decimal (* dec-dayz decay))
                (v2:decimal (- peak v1))
                (fee-promile:decimal 
                    (if (<= v2 0.0)
                        0.0
                        v2
                    )
                )
                (hibernate-entry-percent:string (format "{}%" [(/ fee-promile 10.0)]))
                ;;
                ;;Operation 1 - Transfer
                (wt1:integer (at "type" (ref-TFT::URC_TransferClasses rt brumator ats-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator wt1 rt brumator ats-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                ;;Operation 2 - Mint
                (ifp2:decimal (SIP|URC_Mint c-rbt1 ats-sc false))
                ;;Operation 3 - Mint
                (ifp3:decimal (SIP|URC_Mint c-rbt2 ats-sc false))
                ;;Operation 4 - Hibernate
                (ifp4:decimal (at "ignis-full" (at "ignis" (VST|INFO_Hibernate patron ats-sc brumator c-rbt2 c-rbt2-amount dayz))))
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3 ifp4]))
                ;;
                (sa-brumator:string (ref-I|OURONET::OI|UC_ShortAccount brumator))
                (ht:string (ref-DPTF::UR_Hibernation c-rbt2))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    ;;<ATS1>
                    (format "Operation: Autostakes {} {} on the {} ATS-Pair." [amount rt ats1])
                    (if (= royalty1-fee 0.0)
                        (format "Deposit in the first Autostake Pool will be executed without any {} Royalty." [rt])
                        (format "{} {} will be retained as Royalty on the First Autostake Pool." [royalty1-fee rt])
                    )
                    (format "An Intermediary Output of {} {} will be generated" [c-rbt1-amount c-rbt1])
                    ;;<ATS2>
                    (format "The Output {} will then be further autostaked on the second ATS-Pair, the {}." [c-rbt1 ats2])
                    (if (= royalty2-fee 0.0)
                        (format "Deposit in the second Autostake Pool will be executed without any {} Royalty." [c-rbt1])
                        (format "{} {} will be retained as Royalty on the Second Autostake Pool." [royalty2-fee c-rbt1])
                    )
                    (format "Brumating for {} Days will incurr a hibernation fee of {} on the Input {} after Royalty" [dayz hibernate-entry-percent c-rbt1])
                    (format "Brumating will generate {} {} as final output." [c-rbt2-amount ht])
                ]
                [
                    (format "Succesfully brumated {} {} on ATS-Pairs {} and {} generating {} {} on {} Account." [amount rt ats1 ats2 c-rbt2-amount ht sa-brumator])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount c-rbt2-amount)]
            )
        )
    )
    (defun ATS|INFO_ColdRecovery:object{OuronetInfoV1.ClientInfo}
        (patron:string recoverer:string ats:string ra:decimal)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV1} U|ATS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV1} ATS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                (ats-sc:string (ref-ATS::GOV|ATS|SC_NAME))
                ;;
                (index-name:string (ref-ATS::UR_IndexName ats))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (c-fr:bool (ref-ATS::UR_ColdRecoveryFeeRedirection ats))
                (elite:bool (ref-ATS::UR_EliteMode ats))
                ;;
                (c-rbt-precision:integer (ref-DPTF::UR_Decimals c-rbt))
                (usable-cold-recovery-position:integer (ref-ATS::URC_WhichPosition ats ra recoverer))
                (fee-promile:decimal (ref-ATS::URC_ColdRecoveryFee ats ra usable-cold-recovery-position))
                (c-rbt-fee-split:[decimal] (ref-U|ATS::UC_PromilleSplit fee-promile ra c-rbt-precision))
                (c-rbt-remainder:decimal (at 0 c-rbt-fee-split))
                (c-rbt-fee:decimal (at 1 c-rbt-fee-split))
                ;;
                ;;Time Computation for Cold Recovery
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (major:integer (ref-DALOS::UR_Elite-Tier-Major recoverer))
                (minor:integer (ref-DALOS::UR_Elite-Tier-Minor recoverer))
                (position:integer
                    (if (= major 0)
                        0
                        (+ (* (- major 1) 7) minor)
                    )
                )
                (crd:[integer] (ref-ATS::UR_ColdRecoveryDuration ats))
                (h:integer (at position crd))
                ;;
                ;;IGNIS Costs
                ;;Operation 1 10 IGNIS Flat Fee for Cold Recovery
                (ifp1:decimal 10.0)
                ;;Operation 2 - 1 IGNIS per existing used Recovery Positions when in unlimited Mode
                (ico2:object{IgnisCollectorV1.OutputCumulator}
                    (if (!= usable-cold-recovery-position -1)
                        EOC
                        (ref-ATSU::UDC_UnlimitedUncoilCumulator ats recoverer)
                    )
                )
                (ifp2:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico2))
                ;;Operation 3 - Transfer
                (wt3:integer (at "type" (ref-TFT::URC_TransferClasses c-rbt recoverer ats-sc ra)))
                (ico3:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator wt3 c-rbt recoverer ats-sc)
                )
                (ifp3:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico3))
                ;;Operation 3 - Burn
                (ifp3:decimal (SIP|URC_Burn c-rbt ats-sc))
                (ifp4:decimal
                    (if (= c-rbt-fee 0.0)
                        0.0
                        (if c-fr
                            0.0
                            (* (dec (length rt-lst)) ifp3)
                        )
                    )
                )
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3 ifp4]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Places {} {} into Cold Recovery" [ra c-rbt])
                    (if (= usable-cold-recovery-position -1)
                        (format "You have 250 Recovery Slots")
                        (if elite
                            (format "You have up to 7 Recovery Slots")
                            (format "You have 7 Recovery Slots ")
                        )
                    )
                    (if (!= c-rbt-fee 0.0)
                        (format "{}\n{}\n{}"
                            [
                                (format "Cold Recovery will incurr a Col-Recovery-Fee of {}‰ (promile)" [fee-promile])
                                (if c-fr
                                    (format "This Fee is collected by strengthening the {}" [index-name])
                                    (format "This Fee is collected by burning the Reward Tokens {}" [rt-lst])
                                )
                                (format "And Amounts to {} {}" [(ref-ATS::URC_RTSplitAmounts ats c-rbt-fee) rt-lst])
                            ]
                        )
                        (format "Cold Recovery will be executed without any Cold-Recovery-Fee")
                    )
                    (format "{} {} will be recovarable after {} hour(s)" [(ref-ATS::URC_RTSplitAmounts ats c-rbt-remainder) rt-lst h])
                ]
                [
                    (format "Succesfully placed {} {} ATS-Pair RBT into Cold Recovery" [ra ats])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [(ref-I|OURONET::OI|UC_FormatTokenAmount ra)]
            )

        )
    )
    (defun ATS|INFO_Cull:object{OuronetInfoV1.ClientInfo}
        (patron:string culler:string ats:string)
        (let
            (
                (ref-U|DEC:module{OuronetDecimalsV1} U|DEC)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-ATS:module{AutostakeV1} ATS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                (ats-sc:string (ref-ATS::GOV|ATS|SC_NAME))
                ;;
                (c0:[decimal] (at "summed-culled-values" (ref-ATSU::URC_MultiCull ats culler)))
                (c1:[decimal] (ref-ATSU::URC_SingleCull ats culler 1))
                (c2:[decimal] (ref-ATSU::URC_SingleCull ats culler 2))
                (c3:[decimal] (ref-ATSU::URC_SingleCull ats culler 3))
                (c4:[decimal] (ref-ATSU::URC_SingleCull ats culler 4))
                (c5:[decimal] (ref-ATSU::URC_SingleCull ats culler 5))
                (c6:[decimal] (ref-ATSU::URC_SingleCull ats culler 6))
                (c7:[decimal] (ref-ATSU::URC_SingleCull ats culler 7))
                (ca:[[decimal]] [c0 c1 c2 c3 c4 c5 c6 c7])
                (cw:[decimal] (ref-U|DEC::UC_AddHybridArray ca))
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (how-many-tokens:integer (length rt-lst))
                (empty:[decimal] (make-list how-many-tokens 0.0))
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (if (= cw empty)
                        EOC
                        (ref-TFT::UDC_MultiTransferCumulator rt-lst ats-sc culler cw)
                    )
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (* 2.0 (ref-DALOS::UR_UsagePrice "ignis|biggest")))
                (ifp:decimal (+ ifp1 ifp2))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Culls the Cold Recovery Positions, recovering RTs")
                    (if (= cw empty)
                        "Currently no RTs can be collected"
                        (format "Currently RTs {} can be recovered with amounts of: {}" [rt-lst cw])
                    )
                ]
                [
                    (format "Succesfully Culled {} RT(s) Tokens with amounts of {} from ATS-Pair {}" [how-many-tokens cw ats])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [(map (ref-I|OURONET::OI|UC_FormatTokenAmount) cw)]
            )
        )
    )
    (defun ATS|INFO_DirectRecovery:object{OuronetInfoV1.ClientInfo}
        (patron:string recoverer:string ats:string ra:decimal)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV1} U|ATS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV1} ATS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ats-sc:string (ref-ATS::GOV|ATS|SC_NAME))
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (fee:decimal (ref-ATS::UR_DirectRecoveryFee ats))
                (c-rbt-remainder:decimal
                    (if (= fee 0.0)
                        ra
                        (at 0 (ref-U|ATS::UC_PromilleSplit fee ra (ref-DPTF::UR_Decimals c-rbt)))
                    )
                )
                (reward-tokens:[string] (ref-ATS::UR_RewardTokenList ats))
                (release-amounts:[decimal] (ref-ATS::URC_RTSplitAmounts ats c-rbt-remainder))
                ;;
                ;;Operation 1 Transfer
                (wt1:integer (at "type" (ref-TFT::URC_TransferClasses c-rbt recoverer ats-sc ra)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator c-rbt recoverer ats-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                ;;Operation 2 Burn DPTF
                (ifp2:decimal (SIP|URC_Burn c-rbt ats-sc))
                ;;Operation 3 Multi Transfer
                (ico3:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_MultiTransferCumulator reward-tokens ats-sc recoverer release-amounts)
                )
                (ifp3:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico3))
                (ifp:decimal (fold (+) 0.0 [ifp1 ifp2 ifp3]))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Directly Recovers {} {}" [ra c-rbt])
                    (if (= fee 0.0)
                        "Direct Recovery will be executed without any Direct-Recovery Fee"
                        (format "Direct Recovery will be executed with {}‰ (promile) Direct Recovery Fee" [fee])
                    )
                    (format "Direct Recovery will yield {} {} Tokens" [release-amounts reward-tokens])
                ]
                [
                    (format "Succesfully recovered directly {} RBT Token on ATS-Pair" [ra ats])
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                [(map (ref-I|OURONET::OI|UC_FormatTokenAmount) release-amounts)]
            )
        )
    )
    ;; [LIQUID]
    (defun LIQUID|INFO_UnwrapUrStoa:object{OuronetInfoV1.ClientInfo}
        (patron:string unwrapper:string amount:decimal)
        (let
            (
                (ref-urcoin:module{stoa-ns.ur-stoic-fungible-v1} coin)
                ;;
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (uw:string (ref-I|OURONET::OI|UC_ShortAccount unwrapper))
                ;;
                (trial (try false (ref-urcoin::UR_UR|Balance (ref-DALOS::UR_AccountKadena unwrapper))))
                (iz-target-unregistered (= (typeof trial) "bool"))
                (lq-sc:string (ref-DALOS::GOV|LIQUID|SC_NAME))
                (w-urstoa-id:string (ref-DALOS::UR_UrStoaID))
                (what-type:integer (at "type" (ref-TFT::URC_TransferClasses w-urstoa-id unwrapper lq-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator what-type w-urstoa-id unwrapper lq-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (SIP|URC_Burn w-urstoa-id lq-sc))
                (ifp:decimal (+ ifp1 ifp2))
                (final-ifp:decimal
                    (if iz-target-unregistered
                        (+ ifp (* 5.0 (ref-DALOS::UR_UsagePrice "ignis|biggest")))
                        ifp
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Unwraps {} UrStoa to the Payment Key of the Unwrapper {}" [amount uw])]
                [(format "Succesfully unwrapped {} UrStoa to the Payment Key of the Unwrapper {}" [amount uw])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron final-ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
            (if (= (typeof ()) "bool") false true)
        )
    )
    (defun LIQUID|INFO_WrapUrStoa:object{OuronetInfoV1.ClientInfo}
        (patron:string wrapper:string amount:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS) 
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (uw:string (ref-I|OURONET::OI|UC_ShortAccount wrapper))
                ;;
                (lq-sc:string (ref-DALOS::GOV|LIQUID|SC_NAME))
                (w-urstoa-id:string (ref-DALOS::UR_UrStoaID))
                (what-type:integer (at "type" (ref-TFT::URC_TransferClasses w-urstoa-id wrapper lq-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator what-type w-urstoa-id wrapper lq-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (SIP|URC_Mint w-urstoa-id lq-sc false))
                (ifp:decimal (+ ifp1 ifp2))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Wraps {} UrStoa to the Payment Key of the Wrapper {}" [amount uw])]
                [(format "Succesfully wrapped {} UrStoa to the Payment Key of the Unwrapper {}" [amount uw])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun LIQUID|INFO_UnwrapStoa:object{OuronetInfoV1.ClientInfo}
        (patron:string unwrapper:string amount:decimal)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                ;;
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (uw:string (ref-I|OURONET::OI|UC_ShortAccount unwrapper))
                ;;
                (trial (try false (ref-coin::get-balance (ref-DALOS::UR_AccountKadena unwrapper))))
                (iz-target-unregistered (= (typeof trial) "bool"))
                (lq-sc:string (ref-DALOS::GOV|LIQUID|SC_NAME))
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (what-type:integer (at "type" (ref-TFT::URC_TransferClasses w-stoa-id unwrapper lq-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator what-type w-stoa-id unwrapper lq-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (SIP|URC_Burn w-stoa-id lq-sc))
                (ifp:decimal (+ ifp1 ifp2))
                (final-ifp:decimal
                    (if iz-target-unregistered
                        (+ ifp (* 5.0 (ref-DALOS::UR_UsagePrice "ignis|biggest")))
                        ifp
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Unwraps {} Stoa to the Payment Key of the Unwrapper {}" [amount uw])]
                [(format "Succesfully unwrapped {} Stoa to the Payment Key of the Unwrapper {}" [amount uw])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron final-ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun LIQUID|INFO_WrapStoa:object{OuronetInfoV1.ClientInfo}
        (patron:string wrapper:string amount:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS) 
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (uw:string (ref-I|OURONET::OI|UC_ShortAccount wrapper))
                ;;
                (lq-sc:string (ref-DALOS::GOV|LIQUID|SC_NAME))
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (what-type:integer (at "type" (ref-TFT::URC_TransferClasses w-stoa-id wrapper lq-sc amount)))
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator what-type w-stoa-id wrapper lq-sc)
                )
                (ifp1:decimal (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico1))
                (ifp2:decimal (SIP|URC_Mint w-stoa-id lq-sc false))
                (ifp:decimal (+ ifp1 ifp2))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Wraps {} Stoa to the Payment Key of the Wrapper {}" [amount uw])]
                [(format "Succesfully wrapped {} Stoa to the Payment Key of the Unwrapper {}" [amount uw])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    ;;
    (defun ORBR|INFO_Compress:object{OuronetInfoV1.ClientInfo}
        (client:string ignis-amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-ORBR:module{OuroborosV1} OUROBOROS)
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount client))
                (ignis-to-ouro:[decimal] (ref-ORBR::URC_Compress ignis-amount))
                (ouro-remainder-amount:decimal (at 0 ignis-to-ouro))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Compresses {} Ignis GAS generating Ouroboros on {} with 98.5% efficiency; 1.5% is lost as Compression Fee" [ignis-amount sa])
                    "Only whole Ignis GAS Amounts greater than or equal to 1.0 can be used for Compression"
                    "Output depends on Ouroboros Price. A price of less than 1.00$ is treated as 1.00$ for Compression Math."
                ]
                [(format "Succesfully compressed {} Ignis GAS generating {} Ouroboros on {}" [ignis-amount ouro-remainder-amount sa])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun ORBR|INFO_Sublimate:object{OuronetInfoV1.ClientInfo}
        (client:string target:string ouro-amount:decimal)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV1} U|ATS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ORBR:module{OuroborosV1} OUROBOROS)
                (sa1:string (ref-I|OURONET::OI|UC_ShortAccount client))
                (sa2:string (ref-I|OURONET::OI|UC_ShortAccount client))
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                (ouro-split:[decimal] (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision))
                (ouro-remainder-amount:decimal (at 0 ouro-split))
                (ignis-amount:decimal (ref-ORBR::URC_Sublimate ouro-remainder-amount))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (if (= client target)
                        (format "Operation: Sublimates {} Ouroboros from {} for self usage, generating IGNIS with 99.0% efficiency; 1.0% is lost as Sublimation Fee" [ouro-amount sa1])
                        (format "Operation: Sublimates {} Ouroboros from {}, generating IGNIS on {} with 99.0% efficiency; 1.0% is lost as Sublimation Fee." [ouro-amount sa1 sa2])
                    )
                    "Only Ouroboros Amounts greater than or equal to 1.0 can be used for Sublimation"
                    "Output depends on Ouroboros Price. A price of less than 1.00$ is treated as 1.00$ for Sublimation Math."
                ]
                [
                    (if (= client target)
                        (format "Succesfully sublimated {} Ouro for self usage, generating {} Ignis GAS on {}" [ouro-amount ignis-amount sa1])
                        (format "Succesfully sublimated {} Ouro from {} to {}, generating {} Ignis GAS" [ouro-amount sa1 sa2 ignis-amount])
                    )
                   
                ]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    ;;  [SWP]
    (defun SWP|INFO_EnableFrozenLP:object{OuronetInfoV1.ClientInfo}
        (patron:string swpair:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV2} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (current-frozen-link:string (ref-DPTF::UR_Frozen lp-id))
                (is-stoa-zero:bool (ref-IGNIS::URC_IsNativeGasZero))
                ;;
                (ifp-m:decimal (ref-DALOS::UR_UsagePrice "ignis|medium"))
                (ifp0:decimal (ref-DALOS::UR_UsagePrice "ignis|token-issue"))
                (ifp1:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (ifp2:decimal (ref-DALOS::UR_UsagePrice "ignis|big"))
                (ifp-issue:decimal (fold (+) 0.0 [ifp0 ifp1 ifp2]))
                (kfp-issue:decimal (ref-DALOS::UR_UsagePrice "dptf"))
                (ifp:decimal
                    (if (= current-frozen-link BAR)
                        (+ ifp-m ifp-issue)
                        ifp-m
                    )
                )
                (kfp:decimal
                    (if is-stoa-zero
                        0.0
                        (if (= current-frozen-link BAR)
                            kfp-issue 0.0
                        )
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    
                    (format "Operation: Enables the Frozen LP Functionality for the SWP-Pair {} " [swpair])
                    (if (= current-frozen-link BAR)
                        (format "Also Issues a Frozen Link for the LP {}" [lp-id])
                        (format "Doesnt Issue a Frozen Link for the LP {} as it already exists with {}" 
                            [lp-id current-frozen-link]
                        )
                    )
                ]
                [
                    (if (= current-frozen-link BAR)
                        (format 
                            "Succesfully Issued Frozen LP and enabled Frozen LP Functionality on SWP-Pair {}" 
                            [swpair]
                        )
                        (format 
                            "Succesfully enabled Frozen LP Functionality on SWP-Pair {}, without issuing a Frozen LP, as it allready exists with id {}" 
                            [swpair current-frozen-link]
                        )
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron kfp)
                []
            )
        )
    )
    (defun SWP|INFO_EnableSleepingLP:object{OuronetInfoV1.ClientInfo}
        (patron:string swpair:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV2} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (current-sleeping-link:string (ref-DPTF::UR_Sleeping lp-id))
                (is-stoa-zero:bool (ref-IGNIS::URC_IsNativeGasZero))
                ;;
                (ifp-m:decimal (ref-DALOS::UR_UsagePrice "ignis|medium"))
                (ifp0:decimal (ref-DALOS::UR_UsagePrice "ignis|token-issue"))
                (ifp1:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (ifp2:decimal (ref-DALOS::UR_UsagePrice "ignis|big"))
                (ifp-issue:decimal (fold (+) 0.0 [ifp0 ifp1 ifp2]))
                (kfp-issue:decimal (ref-DALOS::UR_UsagePrice "dpof"))
                (ifp:decimal
                    (if (= current-sleeping-link BAR)
                        (+ ifp-m ifp-issue)
                        ifp-m
                    )
                )
                (kfp:decimal
                    (if is-stoa-zero
                        0.0
                        (if (= current-sleeping-link BAR)
                            kfp-issue 0.0
                        )
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    
                    (format "Operation: Enables the Sleeping LP Functionality for the SWP-Pair {} " [swpair])
                    (if (= current-sleeping-link BAR)
                        (format "Also Issues a Sleeping Link for the LP {}" [lp-id])
                        (format "Doesnt Issue a Sleeping Link for the LP {} as it already exists with {}" 
                            [lp-id current-sleeping-link]
                        )
                    )
                ]
                [
                    (if (= current-sleeping-link BAR)
                        (format 
                            "Succesfully Issued Sleeping LP and enabled Sleeping LP Functionality on SWP-Pair {}" 
                            [swpair]
                        )
                        (format 
                            "Succesfully enabled Sleeping LP Functionality on SWP-Pair {}, without issuing a Sleeping LP, as it allready exists with id {}" 
                            [swpair current-sleeping-link]
                        )
                    )
                ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_DynamicKadenaCost patron kfp)
                []
            )
        )
    )
    (defun SWP|INFO_Fuel:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-amounts:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-SWP:module{SwapperV2} SWP)
                (ref-SWPI:module{SwapperIssueV2} SWPI)
                ;;
                (swp-sc:string (ref-DALOS::GOV|SWP|SC_NAME))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (has-zeros:bool (contains 0.0 input-amounts))
                (input-ids-for-transfer:[string]
                    (if has-zeros
                        (ref-SWPI::URC_TrimIdsWithZeroAmounts swpair input-amounts)
                        pool-tokens
                    )
                )
                (input-amounts-for-transfer:[decimal]
                    (if has-zeros
                        (ref-U|LST::UC_RemoveItem input-amounts 0.0)
                        input-amounts
                    )
                )
                (ico:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_MultiTransferCumulator 
                        input-ids-for-transfer account swp-sc input-amounts-for-transfer
                    )
                )
                (ifp:decimal
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator ico)
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    
                    (format "Operation: Fuels SWP-Pair {} " [swpair])
                    (format "Fueling with {} {} without issuing LP Tokens, increases LP Value" [input-amounts pool-tokens])
                    "WARNING: Spent tokens can never be recovered, permanently increasing LP Value"
                ]
                [(format "Succesfully fueled SWP-Pair {} with Token Amounts {}" [swpair input-amounts])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    (defun SWP|INFO_Firestarter:object{OuronetInfoV1.ClientInfo}
        (firestarter:string)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV1} U|ATS)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ORBR:module{OuroborosV1} OUROBOROS)
                (ref-SWP:module{SwapperV2} SWP)
                (ref-SWPI:module{SwapperIssueV2} SWPI)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                ;;
                (input-ids:[string] [wstoa-id])
                (input-amounts:[decimal] [10.0])
                (output-id:string ouro-id)
                ;;
                (swpair:string (ref-SWP::UR_PrimordialPool))
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (dsid:object{UtilitySwpV1.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id)
                )
                ;;
                (fees:object{UtilitySwpV1.SwapFeez} (ref-SWPL::UDC_PoolFees swpair))
                (A:decimal (ref-SWP::UR_Amplifier swpair))
                (X:[decimal] (ref-SWP::UR_PoolTokenSupplies swpair))
                (X-prec:[integer] (ref-SWP::UR_PoolTokenPrecisions swpair))
                
                (input-positions:[integer] (ref-SWPI::URC_PoolTokenPositions swpair input-ids))
                (output-position:integer (ref-SWP::UR_PoolTokenPosition swpair output-id))
                (W:[decimal] (ref-SWP::UR_Weigths swpair))
                (dtso:object{UtilitySwpV1.DirectTaxedSwapOutput}
                    (ref-SWPI::UC_BareboneSwapWithFeez firestarter pool-type dsid fees A X X-prec input-positions output-position W)
                )
                (gained-ouro:decimal (at "o-id-netto" dtso))
                ;;
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                (ouro-split:[decimal] (ref-U|ATS::UC_PromilleSplit 10.0 gained-ouro ouro-precision))
                (ouro-remainder-amount:decimal (at 0 ouro-split))
                (ignis-amount:decimal (ref-ORBR::URC_Sublimate ouro-remainder-amount))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                ["Operation: Uses 10 Native Stoa as Fuel to create Ignis GAS"]
                [(format "Succesfully used 10 Stoa to generate {} IGNIS with no IGNIS Costs" [ignis-amount])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    ;;
    (defun SWP|INFO_SinglePoolSwap:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-id:string input-amount:decimal output-id:string)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (dsid:object{UtilitySwpV1.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData [input-id] [input-amount] output-id)
                )
            )
            (UCX_Swap patron account swpair dsid)
        )
    )
    (defun SWP|INFO_MultiPoolSwap:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (dsid:object{UtilitySwpV1.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id)
                )
            )
            (UCX_Swap patron account swpair dsid)
        )
    )
    ;;
    (defun SWP|INFO_AddLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-amounts:[decimal] kda-pid:decimal)
        (UCX_AddLiquidity patron account swpair input-amounts true true kda-pid)
    )
    (defun SWP|INFO_IcedLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-amounts:[decimal] kda-pid:decimal)
        (UCX_AddLiquidity patron account swpair input-amounts false true kda-pid)
    )
    (defun SWP|INFO_GlacialLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string input-amounts:[decimal] kda-pid:decimal)
        (UCX_AddLiquidity patron account swpair input-amounts false false kda-pid)
    )
    (defun SWP|INFO_FrozenLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal kda-pid:decimal)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SWP:module{SwapperV2} SWP)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                ;;
                (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
                (ptp:integer (ref-SWP::UR_PoolTokenPosition swpair dptf))
                (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp input-amount))
                (ld:object{SwapperLiquidityV1.LiquidityData}
                    (ref-SWPL::URC_LD swpair lq-lst)
                )
                ;;
                ;;Compute Liquidity Addition Data
                (clad:object{SwapperLiquidityV1.CompleteLiquidityAdditionData}
                    (ref-SWPL::URC|KDA-PID_CLAD account swpair ld false false kda-pid)
                )
                (ifp:decimal 
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator 
                        (at "perfect-ignis-fee" (at "clad-op" clad))
                    )
                )
            )
            (UCXX_AddLiquidityClientInfo patron ifp swpair (ref-DALOS::UR_IgnisID) clad false false true)
        )
    )
    (defun SWP|INFO_SleepingLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string sleeping-dpof:string nonce:integer kda-pid:decimal)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                (ref-SWP:module{SwapperV2} SWP)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                ;;
                (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
                (ptp:integer (ref-SWP::UR_PoolTokenPosition swpair dptf))
                (batch-amount:decimal (ref-DPOF::UR_NonceSupply sleeping-dpof nonce))
                (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp batch-amount))
                (ld:object{SwapperLiquidityV1.LiquidityData}
                    (ref-SWPL::URC_LD swpair lq-lst)
                )
                ;;
                ;;Compute Liquidity Addition Data
                (clad:object{SwapperLiquidityV1.CompleteLiquidityAdditionData}
                    (ref-SWPL::URC|KDA-PID_CLAD account swpair ld true true kda-pid)
                )
                (ifp:decimal 
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator 
                        (at "perfect-ignis-fee" (at "clad-op" clad))
                    )
                )
            )
            (UCXX_AddLiquidityClientInfo patron ifp swpair (ref-DALOS::UR_IgnisID) clad true true false)
        )
    )
    (defun SWP|INFO_RemoveLiquidity:object{OuronetInfoV1.ClientInfo}
        (patron:string account:string swpair:string lp-amount:decimal)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} INFO-ZERO)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-SWP:module{SwapperV2} SWP)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                ;;
                (pool-token-ids:[string] (ref-SWP::UR_PoolTokens swpair))
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
                (pt-output-amounts:[decimal] (ref-SWPL::URC_LpBreakAmounts swpair lp-amount))
                ;;
                (swp-sc:string (ref-DALOS::GOV|SWP|SC_NAME))
                (flat-ignis-lq-rm-fee:decimal 1000.0)
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ico-flat:object{IgnisCollectorV1.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator flat-ignis-lq-rm-fee swp-sc trigger [])
                )
                ;;
                (ico1:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_TransferCumulator 
                        (at "type" (ref-TFT::URC_TransferClasses lp-id account swp-sc lp-amount))
                        lp-id account swp-sc
                    )
                )
                (ifp2:decimal (SIP|URC_Burn lp-id swp-sc))
                (ico3:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::UDC_MultiTransferCumulator pool-token-ids swp-sc account pt-output-amounts)
                )
                (ifp:decimal 
                    (+
                        ifp2
                        (ref-I|OURONET::OI|UC_IfpFromOutputCumulator 
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-flat ico1 ico3] [])
                        )
                    )
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    
                    (format "Operation: Removes Liquidity on SWP-Pair {}" [swpair])
                    (format "Unfolding {} {} (LP-Tokens)." [lp-amount lp-id])
                    (format "This generates {} {}" [pt-output-amounts pool-token-ids])
                ]
                [(format "Removed {} LP Tokens from SWP-Pair {}, yielding {} of all Pool Tokens" [lp-amount swpair pt-output-amounts])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron ifp)
                (ref-I|OURONET::OI|UDC_NoKadenaCosts)
                []
            )
        )
    )
    ;;
    ;;{F2}  [UEV]
    ;;{F3}  [UDC]
    (defun UDC_HibernatedNoncesView:object{HibernatedNoncesView}
        (a:decimal b:time c:time d:decimal e:decimal f:decimal)
        {"nonce-supply"             : a
        ,"mint-time"                : b
        ,"release-time"             : c
        ,"hibernating-fee-promile"  : d
        ,"remainder"                : e
        ,"hibernating-fee"          : f
        }
    )
    ;;{F4}  [CAP]
    ;;
    ;;{F5}  [A]
    ;;{F6}  [C]
    ;;{F7}  [X]
    ;;
)
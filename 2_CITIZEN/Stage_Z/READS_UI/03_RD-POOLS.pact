;; ===========================================================================================
;; RD-POOLS -- the SWP pages: pool list, per-pool dashboards, management and fee settings.
;; ===========================================================================================
;; Module 03 of the READS_UI split. Template: 01_RD-HEADER.pact. Rules: READS_UI/README.md.
;;
;; REPLACES DPL-UR::URC_0003 / _0004 / _0005 / _0010 / _0011 / _0014 / _0015 and the shared
;; URC_SWPairCoreRead they lean on -- seven public reads plus a helper, the largest group in
;; the roster.
;;
;; ------------------------------------------------------------------------------------------
;; A DEFECT FOUND WHILE PORTING, AND FIXED HERE -- read this before diffing against DPL-UR
;; ------------------------------------------------------------------------------------------
;; DPL-UR carries the Elite-tier -> max-special-fee-targets rule TWICE, and the two copies
;; DISAGREE:
;;
;;     URC_0032_EliteAccount           (fold (or) false [(= major 5) (= major 6) (= major 7)])
;;     URC_0015_SwpairManagementFee    (fold (or) true  [(= major 5) (= major 6) (= major 7)])
;;
;; The identity for `or` is FALSE. Seeding the fold with TRUE makes it return true regardless of
;; its contents, so that `cond` branch always fires and the trailing `1` is UNREACHABLE.
;;
;; Measured, not reasoned: for major = 1 the seeded-true form yields 7 where the correct form
;; yields 1. So every pool owner below tier 2 has been told they may set SEVEN special-fee
;; targets when the rule allows ONE.
;;
;; That is not cosmetic, and it is exactly the carve-out in READS_UI/README.md's testing
;; posture: `max-special-fee-targets` decides how many targets the UI lets a user ADD. A wrong
;; 7 walks them into a transaction the contract refuses.
;;
;; FIXED HERE, and fixed STRUCTURALLY: the rule now exists once, in UC_MaxSpecialFeeTargets,
;; because two copies of a rule is how the two copies came to disagree. RD-ELITE must call this
;; same function when URC_0032 is ported -- do not write a third copy.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface ReadsPoolsV1
    @doc "SWP page reads: global pool state, per-pool dashboards, internal and management \
        \ views, and per-account pool balances. Complete surface."

    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroPanel:object ())
    ;;{5.2}  Compute [UC]
    (defun UC_Amount:string (amount:decimal))
    (defun UC_Price:string (input-price:decimal))
    (defun UC_AmountList:[string] (input:[decimal]))
    (defun UC_MaxSpecialFeeTargets:integer (major:integer))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_PoolTypeWord:[string] (swpair:string))
    (defun URC_ShortAccounts:[string] (accounts:[string]))
    (defun URC_PoolCore:object (swpair:string))
    (defun URC_Global:object ())
    (defun URC_PoolDashboard:object (swpair:string))
    (defun URC_PoolsDashboard:[object] (swpairs:[string]))
    (defun URC_PoolInternal:object (swpair:string))
    (defun URC_AccountSupplies:object (account:string swpair:string))
    (defun URC_PoolSettings:object (swpair:string))
    (defun URC_FeeSettings:object (swpair:string))
    (defun URC_Pool:object (swpair:string))
)

(module RD-POOLS GOV

    ;;{0}  IMPLEMENTERS
    (implements ReadsPoolsV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_RD-POOLS               (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|RD_POOLS_ADMIN)))
    (defcap GOV|RD_POOLS_ADMIN ()           (enforce-guard GOV|MD_RD-POOLS))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroPanel:object ()
        @doc "What a failing panel yields from URC_Pool. `panel-ok` false tells a dead panel \
            \ from one whose values are legitimately zero."
        {"panel-ok" : false}
    )

    ;;{5.2}  Compute [UC]
    (defun UC_Amount:string (amount:decimal)
        @doc "Four-decimal display form; sub-threshold reads as <0.0001 rather than 0.0."
        (let ((v:string (format "{}" [(floor amount 4)])))
            (if (= v "0.0") "<0.0001" v)
        )
    )
    (defun UC_Price:string (input-price:decimal)
        @doc "Dollar/cent display form with a floor below which a price reads as <0.001c."
        (if (< input-price 0.00001)
            "<0.001c"
            (if (< input-price 1.00)
                (format "{}c" [(floor (* input-price 100.0) 3)])
                (format "{}$" [(floor input-price 2)])
            )
        )
    )
    (defun UC_AmountList:[string] (input:[decimal])
        @doc "UC_Amount across a list, for the formatted-supply fields. \
            \ \
            \ NAMED `AmountList`, NOT `Amounts`, because the obvious name CAPTURED SOMEONE \
            \ ELSE'S CALL SITE. `_callarity.py` resolves a call by bare function name across \
            \ the whole tree -- including into modules defined INLINE inside `.repl` files -- \
            \ and when a name has exactly one definition it enforces that arity everywhere. \
            \ `SKB5K.UC_Amounts count unit` in Stage00b_StoaBulkGasTests.repl takes two \
            \ arguments; this took one; and because this was the only `UC_Amounts` in any \
            \ `.pact`, the gate reported the sandbox call as the error. \
            \ \
            \ The rule for every read module: a helper name is tree-global to the arity \
            \ checker. Pick one nothing else could plausibly own."
        (map (lambda (d:decimal) (UC_Amount d)) input)
    )
    (defun UC_MaxSpecialFeeTargets:integer (major:integer)
        @doc "How many special-fee targets an Elite major tier permits: 1 below tier 2, then \
            \ 2/3/4 at tiers 2/3/4, then 7 from tier 5 up. \
            \ \
            \ THE SINGLE IMPLEMENTATION OF THIS RULE, on purpose. DPL-UR had two -- \
            \ URC_0032_EliteAccount seeded its fold with `false` and \
            \ URC_0015_SwpairManagementFeeSettings with `true`. The identity for `or` is FALSE, \
            \ so the seeded-true copy always took the tier-5 branch and reported 7 for every \
            \ tier below 2, leaving its own `1` fallback unreachable. Measured: major = 1 gave \
            \ 7 instead of 1. \
            \ \
            \ Written as an explicit comparison rather than a fold, so there is no seed to get \
            \ wrong. RD-ELITE must call THIS when URC_0032 is ported -- a third copy is how the \
            \ second one came to disagree."
        (cond
            ((= major 2) 2)
            ((= major 3) 3)
            ((= major 4) 4)
            ((>= major 5) 7)
            1
        )
    )

    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_PoolTypeWord:[string] (swpair:string)
        @doc "The pool's type code and its display word: S -> Stable, W -> Weigthed, else Product."
        (let*
            ( (ref-U|SWP:module{UtilitySwpV2} U|SWP)
              (t:string (ref-U|SWP::UC_PoolType swpair)) )
            [t (if (= t "S") "Stable" (if (= t "W") "Weigthed" "Product"))]
        )
    )

    (defun URC_ShortAccounts:[string] (accounts:[string])
        @doc "Abbreviated account strings for display, via the INFO-ZERO shortener."
        (let ((ref-INFO:module{OuronetInfoV2} IGNIS))
            (map (lambda (a:string) (ref-INFO::OI|UC_ShortAccount a)) accounts)
        )
    )

    (defun URC_PoolCore:object (swpair:string)
        @doc "The shared read every pool panel needs: type, supplies, LP capacity, fees and \
            \ both dollar values. Public rather than internal -- a panel that fails is easier \
            \ to diagnose when the thing all of them share can be called on its own."
        (let*
            ( (ref-DIA:module{DiaStoaPidV2} U|CT)
              (ref-SWP:module{SwapperV4} SWP)
              (ref-SWPI:module{SwapperIssueV4} SWPI)
              (ptp:[string] (URC_PoolTypeWord swpair))
              (glsb:bool (ref-SWP::UR_LiquidBoost))
              (lp-fee:decimal (ref-SWP::UR_FeeLP swpair))
              (pv:[decimal] (ref-SWPI::URC_PoolValue swpair))
              (pool-dwk:decimal (at 0 pv))
              (lp-dwk:decimal (at 1 pv))
              (pid:decimal (ref-DIA::UR_STOA-PID|Price)) )
            {"panel-ok" : true
            ,"pool-type" : (at 0 ptp), "pool-type-word" : (at 1 ptp)
            ,"pool-token-supplies" : (ref-SWP::UR_PoolTokenSupplies swpair)
            ,"lp-supply" : (ref-SWP::URC_LpCapacity swpair)
            ,"lp-fee" : lp-fee, "liquid-fee" : (if glsb lp-fee 0.0)
            ,"special-fee-targets" : (ref-SWP::UR_SpecialFeeTargets swpair)
            ,"pool-value-in-dwk" : pool-dwk, "lp-value-in-dwk" : lp-dwk
            ,"pool-value-pid" : (UC_Price (* pool-dwk pid))
            ,"lp-value-pid" : (UC_Price (* lp-dwk pid))}
        )
    )

    (defun URC_Global:object ()
        @doc "Chain-wide swap state and the list of every pool. \
            \ \
            \ URC_Swpairs is safe inside a `try` -- its own doc says it is cheaper than \
            \ `keys SWP|Pairs`, i.e. an index read rather than a scan. That distinction is the \
            \ one that matters for composability; see READS_UI/README.md rule 5."
        (let*
            ( (ref-SWP:module{SwapperV4} SWP)
              (glsb:bool (ref-SWP::UR_LiquidBoost))
              (asm:bool (ref-SWP::UR_Asymetric))
              (pools:[string] (ref-SWP::URC_Swpairs)) )
            {"panel-ok" : true
            ,"global-liquid-staking-boost" : glsb
            ,"global-liquid-staking-boost-word" : (if glsb "ON" "OFF")
            ,"asymmetric" : asm, "asymmetric-word" : (if asm "ON" "OFF")
            ,"pools" : pools, "number-of-pools" : (length pools)}
        )
    )

    (defun URC_PoolDashboard:object (swpair:string)
        @doc "The public per-pool panel: value, supplies, weights and the fee breakdown."
        (let*
            ( (ref-SWP:module{SwapperV4} SWP)
              (core:object (URC_PoolCore swpair))
              (sup:[decimal] (at "pool-token-supplies" core))
              (lp:decimal (at "lp-supply" core))
              (sft:[string] (at "special-fee-targets" core))
              (pool-dwk:decimal (at "pool-value-in-dwk" core))
              (lp-dwk:decimal (at "lp-value-in-dwk" core)) )
            {"panel-ok" : true
            ,"tvl-in-$" : (at "pool-value-pid" core), "lp-value-in-$" : (at "lp-value-pid" core)
            ,"pool-token-supplies" : sup, "lp-supply" : lp
            ,"pool-value-in-dwk" : pool-dwk, "lp-value-in-dwk" : lp-dwk
            ,"weigths" : (ref-SWP::UR_Weigths swpair)
            ,"special-fee-targets-proportions" : (ref-SWP::UR_SpecialFeeTargetsProportions swpair)
            ,"total-fee" : (ref-SWP::URC_PoolTotalFee swpair)
            ,"lp-fee" : (at "lp-fee" core), "liquid-fee" : (at "liquid-fee" core)
            ,"special-fee" : (ref-SWP::UR_FeeSP swpair)
            ,"ft-pool-token-supplies" : (UC_AmountList sup), "ft-lp-supply" : (UC_Amount lp)
            ,"ft-pool-value-in-dwk" : (UC_Amount pool-dwk)
            ,"ft-lp-value-in-dwk" : (UC_Amount lp-dwk)
            ,"pool-tokens" : (ref-SWP::UR_PoolTokens swpair)
            ,"pool-type" : (at "pool-type" core), "pool-type-word" : (at "pool-type-word" core)
            ,"special-fee-targets" : sft
            ,"special-fee-targets-short" : (URC_ShortAccounts sft)}
        )
    )

    (defun URC_PoolsDashboard:[object] (swpairs:[string])
        @doc "URC_PoolDashboard across a list, EACH UNDER `try`. \
            \ \
            \ The original mapper had no guard, so one unreadable pool emptied the entire pool \
            \ list -- a single bad row taking out a page that shows dozens. A failed entry now \
            \ comes back as UDC_ZeroPanel and the list still renders, which is the same property \
            \ the per-panel split buys one level up."
        (map (lambda (s:string) (try (UDC_ZeroPanel) (URC_PoolDashboard s))) swpairs)
    )

    (defun URC_PoolInternal:object (swpair:string)
        @doc "The internal/admin panel: genesis state, amplifier, fee unlocks and the toggles, \
            \ on top of everything the public dashboard shows. Supplies are floored to each \
            \ token's own precision here, which the public panel does not do."
        (let*
            ( (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-SWP:module{SwapperV4} SWP)
              (core:object (URC_PoolCore swpair))
              (raw:[decimal] (at "pool-token-supplies" core))
              (tokens:[string] (ref-SWP::UR_PoolTokens swpair))
              (sup:[decimal]
                (map (lambda (i:integer)
                        (floor (at i raw) (ref-DPTF::UR_Decimals (at i tokens))))
                     (enumerate 0 (- (length raw) 1))))
              (lp:decimal (at "lp-supply" core))
              (sft:[string] (at "special-fee-targets" core))
              (pool-dwk:decimal (at "pool-value-in-dwk" core))
              (lp-dwk:decimal (at "lp-value-in-dwk" core))
              (gen:[decimal] (ref-SWP::UR_PoolGenesisSupplies swpair)) )
            {"panel-ok" : true
            ,"tvl-in-$" : (at "pool-value-pid" core), "lp-value-in-$" : (at "lp-value-pid" core)
            ,"genesis-supplies" : gen, "pool-token-supplies" : sup, "lp-supply" : lp
            ,"pool-value-in-dwk" : pool-dwk, "lp-value-in-dwk" : lp-dwk
            ,"weigths" : (ref-SWP::UR_Weigths swpair)
            ,"genesis-weights" : (ref-SWP::UR_GenesisWeigths swpair)
            ,"amplifier" : (ref-SWP::UR_Amplifier swpair)
            ,"fee-unlocks" : (ref-SWP::UR_FeeUnlocks swpair)
            ,"special-fee-target-proportions" : (ref-SWP::UR_SpecialFeeTargetsProportions swpair)
            ,"total-fee" : (ref-SWP::URC_PoolTotalFee swpair)
            ,"lp-fee" : (at "lp-fee" core), "liquid-fee" : (at "liquid-fee" core)
            ,"special-fee" : (ref-SWP::UR_FeeSP swpair)
            ,"ft-genesis-supplies" : (UC_AmountList gen)
            ,"ft-pool-token-supplies" : (UC_AmountList raw)
            ,"ft-lp-supply" : (UC_Amount lp)
            ,"ft-pool-value-in-dwk" : (UC_Amount pool-dwk)
            ,"ft-lp-value-in-dwk" : (UC_Amount lp-dwk)
            ,"lp-id" : (ref-SWP::UR_TokenLP swpair), "pool-tokens" : tokens
            ,"pool-type" : (at "pool-type" core), "pool-type-word" : (at "pool-type-word" core)
            ,"primality" : (if (ref-SWP::UR_Primality swpair) "Primal" "Standard")
            ,"swapping-enabled" : (if (ref-SWP::UR_CanSwap swpair) "ON" "OFF")
            ,"liquidity-enabled" : (if (ref-SWP::UR_CanAdd swpair) "ON" "OFF")
            ,"frozen-and-sleeping" :
                (format "{} | {}" [(if (ref-SWP::UR_IzFrozenLP swpair) "ON" "OFF")
                                   (if (ref-SWP::UR_IzSleepingLP swpair) "ON" "OFF")])
            ,"fee-lockup" : (if (ref-SWP::UR_FeeLock swpair) "Locked" "Unlocked")
            ,"special-fee-targets" : sft
            ,"special-fee-targets-short" : (URC_ShortAccounts sft)}
        )
    )

    (defun URC_AccountSupplies:object (account:string swpair:string)
        @doc "What the account holds of each of this pool's tokens, plus its virtual OURO and \
            \ resident IGNIS -- everything the add-liquidity form needs to bound its inputs."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-TFT:module{TrueFungibleTransferV2} TFT)
              (ref-SWP:module{SwapperV4} SWP)
              (tokens:[string] (ref-SWP::UR_PoolTokens swpair)) )
            {"panel-ok" : true
            ,"pool-tokens" : tokens
            ,"pool-token-prec" : (ref-SWP::UR_PoolTokenPrecisions swpair)
            ,"wallet-pool-tokens-supplies" :
                (map (lambda (t:string) (ref-DPTF::UR_AccountSupply t account)) tokens)
            ,"wallet-virtual-ouro" : (ref-TFT::URC_VirtualOuro account)
            ,"wallet-ignis" : (ref-DALOS::UR_TF_AccountSupply account false)}
        )
    )

    (defun URC_PoolSettings:object (swpair:string)
        @doc "The management panel: ownership, toggles, and the frozen/sleeping links of the LP \
            \ token and every pool token."
        (let*
            ( (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-SWP:module{SwapperV4} SWP)
              (ref-SWPI:module{SwapperIssueV4} SWPI)
              (lp-id:string (ref-SWP::UR_TokenLP swpair))
              (pv:[decimal] (ref-SWPI::URC_PoolValue swpair))
              (all:[string] (+ [lp-id] (ref-SWP::UR_PoolTokens swpair))) )
            {"panel-ok" : true
            ,"pool-owner" : (ref-SWP::UR_OwnerKonto swpair)
            ,"can-change-owner" : (ref-SWP::UR_CanChangeOwner swpair)
            ,"frozen" : (ref-SWP::UR_IzFrozenLP swpair)
            ,"sleeping" : (ref-SWP::UR_IzSleepingLP swpair)
            ,"weights" : (ref-SWP::UR_Weigths swpair)
            ,"amplifier" : (ref-SWP::UR_Amplifier swpair)
            ,"swapping" : (ref-SWP::UR_CanSwap swpair)
            ,"provisioning" : (ref-SWP::UR_CanAdd swpair)
            ,"primality" : (ref-SWP::UR_Primality swpair)
            ,"pool-value-in-stoa" : (at 0 pv), "lp-value-in-stoa" : (at 1 pv)
            ,"ptfs" :
                (map (lambda (t:string)
                        {"pool-token" : t
                        ,"frozen-link" : (ref-DPTF::UR_Frozen t)
                        ,"sleeping-link" : (ref-DPTF::UR_Sleeping t)})
                     all)
            ,"pool-type" : (at 0 (URC_PoolTypeWord swpair))}
        )
    )

    (defun URC_FeeSettings:object (swpair:string)
        @doc "The fee panel, including how many special-fee targets the owner's Elite tier \
            \ permits. \
            \ \
            \ `max-special-fee-targets` comes from UC_MaxSpecialFeeTargets, which CORRECTS a \
            \ live defect: DPL-UR's copy of this rule seeded its `or`-fold with `true`, so the \
            \ tier-5 branch always fired and every owner below tier 2 was shown 7 instead of 1. \
            \ See this file's header. It is a decision-feeding number -- it bounds what the UI \
            \ lets a user add -- so it is fixed rather than ported faithfully."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-SWP:module{SwapperV4} SWP)
              (owner:string (ref-SWP::UR_OwnerKonto swpair))
              (total:decimal (ref-SWP::URC_PoolTotalFee swpair))
              (lp:decimal (ref-SWP::UR_FeeLP swpair))
              (sp:decimal (ref-SWP::UR_FeeSP swpair)) )
            {"panel-ok" : true
            ,"fee-unlocks" : (ref-SWP::UR_FeeUnlocks swpair)
            ,"fee-lock" : (ref-SWP::UR_FeeLock swpair)
            ,"total-fee" : total, "lp-fee" : lp, "special-fee" : sp
            ,"liquid-boost-fee" : (- total (+ lp sp))
            ,"special-fee-targets" : (ref-SWP::UR_FeeSPT swpair)
            ,"max-special-fee-targets" :
                (UC_MaxSpecialFeeTargets (ref-DALOS::UR_Elite-Tier-Major owner))}
        )
    )

    (defun URC_Pool:object (swpair:string)
        @doc "Every per-pool panel in one call, each under `try`. A failing panel yields \
            \ UDC_ZeroPanel and the rest still render. \
            \ \
            \ Deliberately NOT including URC_AccountSupplies -- that one takes an account and \
            \ is therefore a different question. Mixing a per-account read into a per-pool \
            \ composer would make the whole object account-scoped and uncacheable across users."
        {"core"     : (try (UDC_ZeroPanel) (URC_PoolCore swpair))
        ,"dashboard": (try (UDC_ZeroPanel) (URC_PoolDashboard swpair))
        ,"internal" : (try (UDC_ZeroPanel) (URC_PoolInternal swpair))
        ,"settings" : (try (UDC_ZeroPanel) (URC_PoolSettings swpair))
        ,"fees"     : (try (UDC_ZeroPanel) (URC_FeeSettings swpair))}
    )
)

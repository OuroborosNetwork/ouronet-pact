;; ===========================================================================================
;; RD-SWAP -- swap previews: what a user is shown before they sign.
;; ===========================================================================================
;; Module 04 of the READS_UI split. Template: 01_RD-HEADER.pact. Rules: READS_UI/README.md.
;;
;; REPLACES DPL-UR::URC_0006b_DirectSwap, URC_0007b_InverseSwap and
;; URC_ReverseSwapOutputAmount.
;;
;; ------------------------------------------------------------------------------------------
;; THIS MODULE IS THE CARVE-OUT, AND IT IS THE WHOLE REASON THE CARVE-OUT EXISTS
;; ------------------------------------------------------------------------------------------
;; READS_UI/README.md's testing posture says display reads need no audit: if the numbers render
;; and the arithmetic is right, they work. Correct -- for a balance card. NOT for this module.
;;
;; These three functions produce the number a user reads immediately before signing a trade.
;; A wrong balance on the dashboard is a cosmetic bug someone reports. A wrong preview here is
;; a user agreeing to a swap whose output does not match what they were shown. The money moves
;; either way; only the consent was wrong.
;;
;; So: no capability audit (there are no capabilities), but ARITHMETIC ASSERTIONS are mandatory,
;; and they must pin RELATIONSHIPS rather than smoke-test that a call returned. RDUI-08 is that
;; block. The specific property worth pinning is ROUND-TRIP CONSISTENCY -- a forward preview and
;; an inverse preview of the same trade must agree -- because that is the one thing a
;; plausible-but-wrong implementation fails and a "did it return a decimal?" test does not.
;;
;; ------------------------------------------------------------------------------------------
;; THESE ARE SINGLE-POOL PREVIEWS, NOT SMARTSWAP -- and the distinction matters right now
;; ------------------------------------------------------------------------------------------
;; Both take an explicit `swpair`, so they preview a trade THROUGH ONE NAMED POOL. They pair
;; with SWP|C_SingleSwap* / C_MultiSwap*, not with SmartSwap.
;;
;; That means this module is INDEPENDENT of the open `CC_` vs `C_` SmartSwap decision
;; (HANDOFF-ui-rewire-map.md). SmartSwap discovers a route across pools; if its bundle path is
;; chosen, its preview must be computed against the SAME route the transaction will take, and
;; that is a different function shape which does not exist yet. It is deliberately NOT in this
;; module: adding a multi-hop preview before the routing decision is made would mean building
;; against a shape that may not survive the ruling.
;;
;; ------------------------------------------------------------------------------------------
;; WHY NOTHING HERE IS `try`-WRAPPED
;; ------------------------------------------------------------------------------------------
;; There is no composer. Both previews reach `URCv_PoolTokenPositions` / `URv_PoolTokenPosition`
;; -- `v`-prefixed, meaning the enforce is intrinsic to the computation -- which REFUSE a token
;; that is not in the pool. That refusal is the correct answer to a bad pair, and swallowing it
;; into a zero-object would turn "this trade is impossible" into "this trade yields nothing",
;; which is the same number a user would read as a valid quote of zero.
;;
;; A failed preview must fail loudly. This is the one module in the roster where degradation is
;; the wrong behaviour.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface ReadsSwapV1
    @doc "Single-pool swap previews. No composer and no try-wrapping, by design -- an \
        \ impossible trade must refuse rather than quote zero."

    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCv_DirectSwap:decimal
        (account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string))
    (defun URCv_InverseSwap:decimal
        (account:string swpair:string output-id:string output-amount:decimal input-id:string))
    (defun URC_MaxOutputAmount:decimal (swpair:string output-id:string promille:decimal))
)

(module RD-SWAP GOV

    ;;{0}  IMPLEMENTERS
    (implements ReadsSwapV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_RD-SWAP                (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|RD_SWAP_ADMIN)))
    (defcap GOV|RD_SWAP_ADMIN ()            (enforce-guard GOV|MD_RD-SWAP))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{5}  FUNCTIONS
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCv_DirectSwap:decimal
        (account:string swpair:string input-ids:[string] input-amounts:[decimal] output-id:string)
        @doc "FORWARD preview: how much <output-id> comes out, net of fees, for the given \
            \ inputs through <swpair>. This is the figure shown beside \"You receive\". \
            \ \
            \ `URCv_` NOT `URC_`, which is a correction to the original. DPL-UR named this \
            \ URC_0006b_DirectSwap -- the URC_ prefix promises NO enforce -- while it reaches \
            \ SWPI::URCv_PoolTokenPositions and SWP::URv_PoolTokenPosition, both of which \
            \ refuse a token absent from the pool. The enforce was always there; only the name \
            \ denied it. Per StoicSyntax the `v` says the guard is intrinsic to the computation, \
            \ which is exactly what a position lookup's is: there is no output to compute for a \
            \ token the pool does not hold. \
            \ \
            \ <account> is passed to UC_BareboneSwapWithFeez because the fee is Elite-tier \
            \ discounted -- the same trade previews differently for different callers, which is \
            \ correct and is why this cannot be cached across users."
        (let*
            ( (ref-U|SWP:module{UtilitySwpV2} U|SWP)
              (ref-SWP:module{SwapperV4} SWP)
              (ref-SWPI:module{SwapperIssueV4} SWPI)
              (ref-SWPL:module{SwapperLiquidityV2} SWPL)
              (dsid:object{UtilitySwpV2.DirectSwapInputData}
                (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts output-id)) )
            (at "o-id-netto"
                (ref-SWPI::UC_BareboneSwapWithFeez
                    account
                    (ref-U|SWP::UC_PoolType swpair)
                    dsid
                    (ref-SWPL::UDC_PoolFees swpair)
                    (ref-SWP::UR_Amplifier swpair)
                    (ref-SWP::UR_PoolTokenSupplies swpair)
                    (ref-SWP::UR_PoolTokenPrecisions swpair)
                    (ref-SWPI::URCv_PoolTokenPositions swpair input-ids)
                    (ref-SWP::URv_PoolTokenPosition swpair output-id)
                    (ref-SWP::UR_Weigths swpair)))
        )
    )

    (defun URCv_InverseSwap:decimal
        (account:string swpair:string output-id:string output-amount:decimal input-id:string)
        @doc "INVERSE preview: how much <input-id> must go in, gross of fees, to receive exactly \
            \ <output-amount> of <output-id>. The figure shown beside \"You pay\" when a user \
            \ types the amount they WANT rather than the amount they have. \
            \ \
            \ Brutto, not netto: this is what leaves the wallet, fees included. Pairing it \
            \ against URCv_DirectSwap's netto in a UI without reading both docs is how a \
            \ preview ends up off by the fee."
        (let*
            ( (ref-U|SWP:module{UtilitySwpV2} U|SWP)
              (ref-SWP:module{SwapperV4} SWP)
              (ref-SWPI:module{SwapperIssueV4} SWPI)
              (ref-SWPL:module{SwapperLiquidityV2} SWPL)
              (rsid:object{UtilitySwpV2.ReverseSwapInputData}
                (ref-U|SWP::UDC_ReverseSwapInputData output-id output-amount input-id)) )
            (at "i-id-brutto"
                (ref-SWPI::UC_InverseBareboneSwapWithFeez
                    account
                    (ref-U|SWP::UC_PoolType swpair)
                    rsid
                    (ref-SWPL::UDC_PoolFees swpair)
                    (ref-SWP::UR_Amplifier swpair)
                    (ref-SWP::UR_PoolTokenSupplies swpair)
                    (ref-SWP::UR_PoolTokenPrecisions swpair)
                    (ref-SWP::URv_PoolTokenPosition swpair output-id)
                    (ref-SWP::URv_PoolTokenPosition swpair input-id)
                    (ref-SWP::UR_Weigths swpair)))
        )
    )

    (defun URC_MaxOutputAmount:decimal (swpair:string output-id:string promille:decimal)
        @doc "A per-mille slice of <output-id>'s pool supply, floored to its precision -- the \
            \ cap a UI puts on the inverse-swap field so a user cannot ask for more output than \
            \ the pool could plausibly give. \
            \ \
            \ ADVISORY, NOT A GUARANTEE. It bounds the FIELD, not the trade: the pool's own \
            \ refusal is the real limit, and this number does not consult it. A UI that treats \
            \ it as a promise will let a user submit a swap that the contract still declines."
        (let ((ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-SWP:module{SwapperV4} SWP))
            (floor (* (/ promille 1000.0) (ref-SWP::UR_PoolTokenSupply swpair output-id))
                   (ref-DPTF::UR_Decimals output-id))
        )
    )
)

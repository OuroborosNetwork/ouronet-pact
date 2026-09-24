;; ===========================================================================================
;; O-UI-NINE -- the Orto Fungibles page: wallet entries, sleeping LPs, buttons, hibernation.
;; ===========================================================================================
;; OuronetUI entity 9. Template: 01_O-UI-ONE.pact. Rules: ../RULES.md.
;;
;; REPLACES DPL-UR::URC_0018 / _0009a_OrtoFungibleEntry / _0009a_OrtoFungibleEntryMapper /
;; _0009b_OrtoFungibleLPEntry / _0009b_OrtoFungibleSleepingLPMapper / _0019_OrtofungibleButton /
;; _0020_HibernatingNonceData -- seven reads, every argument list and key shape preserved.
;;
;; ------------------------------------------------------------------------------------------
;; WHY THIS MODULE IS SHAPED DIFFERENTLY FROM O-UI-EIGHT
;; ------------------------------------------------------------------------------------------
;; An orto-fungible entry carries `wallet-nonces`, which comes from DPOF::URH_AccountNonces --
;; and that is a `select`. `try` runs its body in READ-ONLY mode, where `select` is DISALLOWED,
;; so the whole-entry `try` that guards O-UI-EIGHT's list CANNOT be used here. This is the same
;; constraint that forced URH_GoldenStoaNonces out of O-UI-TWO's dashboard composer, and it is
;; ../RULES.md rule 5.
;;
;; The answer is not to give up the guard, it is to put the guard where the failure is.
;; A nonce `select` does not throw -- a token with no rows returns `[]`. What throws is the
;; VALUATION: an unpriceable pool, a token whose parent has no market. So the valuation is
;; split into its own function, the `try` wraps THAT, and the nonce read stays outside in
;; normal mode. One broken price degrades one row; its neighbours still render.
;;
;; The sleeping-LP list needs no `try` at all. Its failure mode is an LP with no sleeping
;; counterpart, and whether one exists is a plain `UR_Sleeping` read -- so the list CHECKS
;; first and emits a dead row, instead of calling a function it knows will refuse. A guard you
;; can evaluate beforehand beats a refusal you have to catch.
;;
;; ------------------------------------------------------------------------------------------
;; THE HEADER IS `URH_` AND UNCOMPOSABLE
;; ------------------------------------------------------------------------------------------
;; URC_0018 holds TWO cross-module `keys` scans (`DPOF|T|Properties`, `DPOF|T|Nonces`). Same
;; quarantine as O-UI-EIGHT: nothing here calls URH_01|Header, because `_conformance.py`
;; tolerates a cross-module scan only in a function with zero Pact callers, and because a scan
;; inside `try` is the read-only-mode failure above.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface OUiNineV1
    @doc "Orto Fungibles page reads: per-token wallet entries with their nonce lists, sleeping \
        \ LP entries, the per-token button map, and hibernation release maths."

    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroValuation:object ())
    ;;{5.2}  Compute [UC]
    (defun UC_Price:string (input-price:decimal))
    ;;{5.3}  Read [UR/URC/URH]
    (defun URC_TokenValuation:object (account:string dpof-id:string))
    (defun URC_LpValuation:object (account:string swpair:string sleeping-id:string))
    ;;  CLIENT READS -- see the banner in the module body.
    (defun URH_01|Header:object (account:string))
    (defun URC_02|TokenEntry:object (account:string dpof-id:string))
    (defun URC_03|TokenList:[object] (account:string dpofs:[string]))
    (defun URCv_04|LpEntry:object (account:string swpair:string))
    (defun URC_05|SleepingLpList:[object] (account:string lp-ids:[string]))
    (defun URC_06|Buttons:object (account:string dpof:string selected-nonces:[integer]))
    (defun URC_07|HibernatingNonce:object (dpof:string nonce:integer))
    (defun URC_08|Wallet:object (account:string))
)

(module O-UI-NINE GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiNineV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-NINE              (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_NINE_ADMIN)))
    (defcap GOV|O_UI_NINE_ADMIN ()          (enforce-guard GOV|MD_O-UI-NINE))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroValuation:object ()
        @doc "What an unpriceable row degrades to. Every key the live valuation returns, so a \
            \ consumer indexing the merged entry cannot hit a key-not-found."
        {"t1"                       : "--"
        ,"wallet-supply"            : 0.0
        ,"dpof-supply"              : 0.0
        ,"wallet-worth-in-stoa"     : 0.0
        ,"wallet-worth-in-dollarz"  : "--"
        ,"token-worth-in-stoa"      : 0.0
        ,"token-worth-in-dollarz"   : "--"
        ,"entry-ok"                 : false}
    )

    ;;{5.2}  Compute [UC]
    (defun UC_Price:string (input-price:decimal)
        @doc "Dollar/cent display form. Copied, not shared -- ../RULES.md rule 7."
        (if (< input-price 0.00001)
            "<0.001¢"
            (if (< input-price 1.00)
                (format "{}¢" [(floor (* input-price 100.0) 3)])
                (format "{}$" [(floor input-price 2)])
            )
        )
    )

    ;;{5.3}  Read [UR/URC/URH]
    (defun URC_TokenValuation:object (account:string dpof-id:string)
        @doc "The priceable half of a wallet row -- everything that can throw. Kept separate \
            \ so its caller can wrap it in `try` without dragging the nonce `select` into \
            \ read-only mode. Contains NO select and NO keys; that is the whole point."
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (dptf-id:string (ref-DPOF::URCv_Parent dpof-id))
                (wallet-supply:decimal (ref-DPOF::UR_AccountSupply dpof-id account))
            )
            (let
                (
                    (token-worth-in-dollarz:decimal
                        (ref-SWPI::URC_TokenDollarPrice dptf-id stoa-pid))
                )
                (let
                    (
                        (token-worth-in-stoa:decimal
                            (if (= token-worth-in-dollarz 0.0)
                                0.0
                                (ref-SWPI::URC_SingleWorthWSTOA dptf-id)
                            )
                        )
                    )
                    {"t1"                       : (ref-DPOF::UR_Name dpof-id)
                    ,"wallet-supply"            : wallet-supply
                    ,"dpof-supply"              : (ref-DPOF::UR_Supply dpof-id)
                    ,"wallet-worth-in-stoa"     : (floor (* wallet-supply token-worth-in-stoa) 12)
                    ,"wallet-worth-in-dollarz"  :
                        (UC_Price (* wallet-supply token-worth-in-dollarz))
                    ,"token-worth-in-stoa"      : token-worth-in-stoa
                    ,"token-worth-in-dollarz"   : (UC_Price token-worth-in-dollarz)
                    ,"entry-ok"                 : true}
                )
            )
        )
    )
    (defun URC_LpValuation:object (account:string swpair:string sleeping-id:string)
        @doc "The priceable half of a sleeping-LP row. Same contract as URC_TokenValuation -- \
            \ same keys, no select, safe under `try` -- but priced off the pool rather than \
            \ off the parent token's market."
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (wallet-supply:decimal (ref-DPOF::UR_AccountSupply sleeping-id account))
                (token-worth-in-stoa:decimal (at 1 (ref-SWPI::URC_PoolValue swpair)))
            )
            (let
                (
                    (token-worth-in-dollarz:decimal (* stoa-pid token-worth-in-stoa))
                )
                {"t1"                       : (ref-DPTF::UR_Name sleeping-id)
                ,"wallet-supply"            : wallet-supply
                ,"dpof-supply"              : (ref-DPOF::UR_Supply sleeping-id)
                ,"wallet-worth-in-stoa"     : (floor (* wallet-supply token-worth-in-stoa) 12)
                ,"wallet-worth-in-dollarz"  : (UC_Price (* wallet-supply token-worth-in-dollarz))
                ,"token-worth-in-stoa"      : token-worth-in-stoa
                ,"token-worth-in-dollarz"   : (UC_Price token-worth-in-dollarz)
                ,"entry-ok"                 : true}
            )
        )
    )
    ;; ---------------------------------------------------------------------------------------
    ;; CLIENT READS -- everything below is called BY NAME from OuronetUI. The `NN|` designator
    ;; is the pin: argument list and key shape are a wire contract.
    ;; ---------------------------------------------------------------------------------------
    (defun URH_01|Header:object (account:string)
        @doc "Page header. HEAVY and UNCOMPOSABLE -- holds two cross-module `keys` scans; see \
            \ the module header. \
            \ \
            \ Replaces DPL-UR::URC_0018_OrtofungibleHeader, key-for-key."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (held-of:[string] (ref-DPOF::URH_HeldOrtoFungibles account))
                (mngd-of:[string] (ref-DPOF::URH_OwnedOrtoFungibles account))
            )
            {"total-orto-fungible-number"       : (length (keys DPOF.DPOF|T|Properties))
            ,"total-orto-fungible-nonces"       : (length (keys DPOF.DPOF|T|Nonces))
            ,"held-of"                          : held-of
            ,"held-of-number"                   : (length held-of)
            ,"mngd-of"                          : mngd-of
            ,"mngd-of-number"                   : (length mngd-of)}
        )
    )
    (defun URC_02|TokenEntry:object (account:string dpof-id:string)
        @doc "One wallet row: the nonce list, read in normal mode, merged over a valuation \
            \ that is allowed to fail. \
            \ \
            \ Replaces DPL-UR::URC_0009a_OrtoFungibleEntry, key-for-key, plus `entry-ok`."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (wallet-nonces:[integer] (ref-DPOF::URH_AccountNonces account dpof-id))
            )
            (+  {"t2"               : dpof-id
                ,"wallet-nonces"    : wallet-nonces
                ,"wallet-nonces-no" : (length wallet-nonces)}
                (try (UDC_ZeroValuation) (URC_TokenValuation account dpof-id))
            )
        )
    )
    (defun URC_03|TokenList:[object] (account:string dpofs:[string])
        @doc "URC_02|TokenEntry across a list. Degradation is per-row and lives inside the \
            \ entry, not here, because the nonce `select` cannot be wrapped. \
            \ \
            \ Replaces DPL-UR::URC_0009a_OrtoFungibleEntryMapper."
        (map (lambda (dpof:string) (URC_02|TokenEntry account dpof)) dpofs)
    )
    (defun URCv_04|LpEntry:object (account:string swpair:string)
        @doc "One sleeping-LP row. \
            \ \
            \ `v`, NOT `URC_`: a pool with no sleeping counterpart has no row, and returning \
            \ the native LP instead would show a user a balance that is not theirs. The list \
            \ below never provokes this refusal -- it checks first -- so the enforce exists \
            \ for the direct caller. \
            \ \
            \ Replaces DPL-UR::URCv_0009b_OrtoFungibleLPEntry, key-for-key, plus `entry-ok`."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (sleeping-id:string (ref-DPTF::UR_Sleeping (ref-SWP::UR_TokenLP swpair)))
            )
            (enforce
                (!= (ref-U|CT::CT_BAR) sleeping-id)
                "Sleeping LP must be defined for this usage")
            (let
                (
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    ;;
                    (wallet-nonces:[integer] (ref-DPOF::URH_AccountNonces account sleeping-id))
                )
                (+  {"t2"               : sleeping-id
                    ,"wallet-nonces"    : wallet-nonces
                    ,"wallet-nonces-no" : (length wallet-nonces)}
                    (try (UDC_ZeroValuation) (URC_LpValuation account swpair sleeping-id))
                )
            )
        )
    )
    (defun URC_05|SleepingLpList:[object] (account:string lp-ids:[string])
        @doc "Sleeping-LP rows for a list of LP token ids. \
            \ \
            \ DPL-UR's mapper called the entry unconditionally, so ONE pool without a sleeping \
            \ counterpart made the entry REFUSE and emptied the whole list. Here the presence \
            \ of the counterpart is checked first -- it is a plain read -- and an absent one \
            \ yields a dead row while its neighbours render. \
            \ \
            \ Replaces DPL-UR::URC_0009b_OrtoFungibleSleepingLPMapper."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
            )
            (map
                (lambda (lp-id:string)
                    (if (= (ref-U|CT::CT_BAR) (ref-DPTF::UR_Sleeping lp-id))
                        (+ {"t2" : (ref-U|CT::CT_BAR), "wallet-nonces" : [], "wallet-nonces-no" : 0}
                           (UDC_ZeroValuation))
                        (URCv_04|LpEntry account (ref-SWP::UR_GetLpSwpair lp-id))
                    )
                )
                lp-ids
            )
        )
    )
    (defun URC_06|Buttons:object (account:string dpof:string selected-nonces:[integer])
        @doc "Which nonce actions the chain will accept, given the account, the token and the \
            \ nonces the user has ticked. Every flag is a function of the SELECTION as well as \
            \ the token, which is why this takes a nonce list and the true-fungible twin does \
            \ not. \
            \ \
            \ Replaces DPL-UR::URC_0019_OrtofungibleButton, key-for-key."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-VST:module{VestingV2} VST)
                ;;
                (iz-smart:bool (ref-DALOS::UR_AccountType account))
                (iz-owner-ats:bool (= (ref-DPOF::UR_Konto dpof) (ref-DALOS::GOV|ATS|SC_NAME)))
                (iz-owner:bool (= account (ref-DPOF::UR_Konto dpof)))
                (has-addq:bool (ref-DPOF::UR_R-AddQuantity dpof account))
                (has-create:bool (ref-DPOF::UR_R-Create dpof account))
                (has-burn:bool (ref-DPOF::UR_R-Burn dpof account))
                (has-segmentation:bool (ref-DPOF::UR_Segmentation dpof))
                (can-wipe:bool (ref-DPOF::UR_CanWipe dpof))
                ;;
                (l:integer (length selected-nonces))
                (first-two:string (take 2 dpof))
                (iz-rbt:bool (ref-DPOF::URC_IzRBT dpof))
            )
            (let
                (
                    (iz-empty:bool (= l 0))
                    (iz-single:bool (= l 1))
                    (iz-vested:bool (= first-two "V|"))
                    (iz-sleeping:bool (= first-two "Z|"))
                    (iz-hibernated:bool (= first-two "H|"))
                )
                (let
                    (
                        (cull-amount:decimal
                            (if (and iz-single (or iz-vested iz-sleeping))
                                (at 0 (ref-VST::URC_CullMetaDataAmountWithObject
                                          dpof (at 0 selected-nonces)))
                                0.0
                            )
                        )
                        (nonce-supply:decimal
                            (if iz-single
                                (ref-DPOF::UR_NonceSupply dpof (at 0 selected-nonces))
                                -1.0
                            )
                        )
                        (redeem-and-revert:bool
                            (fold (and) true
                                [iz-single (not iz-smart) iz-owner-ats iz-rbt]))
                    )
                    {"add-quantity" : (fold (and) true [iz-single has-addq])
                    ,"mint"         : (fold (and) true [iz-empty has-addq has-create])
                    ,"burn"         : (fold (and) true [iz-single has-burn])
                    ,"wipe"         : (fold (and) true [iz-empty can-wipe iz-owner])
                    ,"unvest"       : (fold (and) true
                                        [iz-single iz-vested (not iz-smart) (> cull-amount 0.0)])
                    ,"unsleep"      : (fold (and) true
                                        [iz-single iz-sleeping (not iz-smart)
                                         (= cull-amount nonce-supply)])
                    ,"merge"        : (fold (and) true [(not iz-empty) iz-sleeping])
                    ,"awake"        : (fold (and) true [iz-single iz-hibernated])
                    ,"slumber"      : (fold (and) true [(not iz-single) iz-hibernated])
                    ,"redeem"       : redeem-and-revert
                    ,"revert"       : redeem-and-revert
                    ,"transmit"     : (fold (and) true [(not iz-empty) has-segmentation])
                    ,"transfer"     : (not iz-empty)
                    }
                )
            )
        )
    )
    (defun URC_07|HibernatingNonce:object (dpof:string nonce:integer)
        @doc "What it costs to wake a hibernating nonce NOW. The fee decays linearly from 800 \
            \ promille at mint to zero at the release date; past release it is zero. \
            \ \
            \ Replaces DPL-UR::URC_0020_HibernatingNonceData, key-for-key."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (precision:integer (ref-DPOF::UR_Decimals dpof))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData dpof nonce))
            )
            (let
                (
                    (mint-time:time (at "mint-time" (at 0 meta-data-chain)))
                    (release-time:time (at "release-date" (at 0 meta-data-chain)))
                )
                (let
                    (
                        (hibernating-period:decimal (diff-time release-time mint-time))
                        (elapsed-time:decimal
                            (diff-time (at "block-time" (chain-data)) mint-time))
                    )
                    (let
                        (
                            (hibernating-fee-promile:decimal
                                (if (>= elapsed-time hibernating-period)
                                    0.0
                                    (floor
                                        (- 800.0
                                           (* 800.0 (/ elapsed-time hibernating-period)))
                                        4)
                                )
                            )
                        )
                        (let
                            (
                                (remainder:decimal
                                    (if (= hibernating-fee-promile 0.0)
                                        nonce-supply
                                        (at 0 (ref-U|ATS::UC_PromilleSplit
                                                  hibernating-fee-promile
                                                  nonce-supply precision))
                                    )
                                )
                            )
                            {"dptf-id"                  : (ref-DPOF::UR_Hibernation dpof)
                            ,"nonce-supply"             : nonce-supply
                            ,"mint-time"                : mint-time
                            ,"release-time"             : release-time
                            ,"hibernating-fee-promile"  : hibernating-fee-promile
                            ,"remainder"                : remainder
                            ,"hibernating-fee"          : (- nonce-supply remainder)}
                        )
                    )
                )
            )
        )
    )
    (defun URC_08|Wallet:object (account:string)
        @doc "THE ONE READ FOR THE PAGE. Held and managed token lists, their counts, and a \
            \ fully-populated row -- nonces included -- for every held token. \
            \ \
            \ It does NOT carry the two `total-*` counts. Those are the only fields in the \
            \ header needing a cross-module `keys` scan, and composing a scan makes the \
            \ composer both undegradable and non-conformant. Fetch them from URH_01|Header \
            \ when they are wanted."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (held-of:[string] (ref-DPOF::URH_HeldOrtoFungibles account))
                (mngd-of:[string] (ref-DPOF::URH_OwnedOrtoFungibles account))
            )
            {"held-of"          : held-of
            ,"held-of-number"   : (length held-of)
            ,"mngd-of"          : mngd-of
            ,"mngd-of-number"   : (length mngd-of)
            ,"entries"          : (URC_03|TokenList account held-of)
            ,"list-ok"          : true}
        )
    )
)

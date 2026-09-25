;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 17
;; OUiEightV2 + OUiNineV2 (interfaces) + both modules -- a balance must not need a price
;; =========================================================================================
;; TWO NEW INTERFACES AND TWO MODULE UPGRADES. V1 of each is already deployed and cannot be
;; changed, so the added read arrives as V2 carrying the full surface.
;;
;; ADDS ONE FUNCTION TO EACH: URC_09|SuppliesOnly. Name, id, both supplies -- and for the orto
;; side the nonce list -- with the four worth fields present but blank and `priced` false.
;;
;; ------------------------------------------------------------------------------------------
;; WHY, AND WHAT IT FIXES THAT PureV2/15 DOES NOT
;; ------------------------------------------------------------------------------------------
;; The True Fungibles and Orto Fungibles pages showed no amounts. Measured on chain, for the
;; very token rendering blank:
;;
;;     DPTF::UR_AccountSupply   ->  837.746616997242327801585125     OK
;;     DPTF::UR_Supply          ->  652417.137589419785010087782731  OK
;;     DPTF::UR_Name            ->  "Auryn"                          OK
;;     SWPI::URC_TokenDollarPrice -> Table ... SWPT|PathCache was not found   FAIL
;;
;; THE BALANCES WERE NEVER BROKEN. URC_02|TokenEntry computes supply and price in a single
;; `let`, so one failing price erased a row that was otherwise entirely readable.
;;
;; PureV2/15 creates the missing table and the prices start working -- that is the immediate
;; repair and it is still required. This file fixes the STRUCTURE, so the next pricing outage
;; costs prices instead of costing balances.
;;
;; ------------------------------------------------------------------------------------------
;; WHY A SEPARATE READ, AND NOT A `try`
;; ------------------------------------------------------------------------------------------
;; Because `try` does not work here, and that was verified rather than assumed. A module whose
;; deftable was never created, read inside `(try "CAUGHT" ...)`, does not yield "CAUGHT" -- the
;; error escapes:
;;
;;     Error during database operation: Table tns.TT_TT|NeverCreated not found
;;
;; Same class as the arithmetic exception that made the ICO read undefendable. O-UI-NINE already
;; splits its valuation out and wraps it in `try`, which handles an unpriceable TOKEN; it does
;; nothing against an unavailable pricing ENGINE, which is why that page went blank too despite
;; the split.
;;
;; No guard inside a read can survive this. The only structural answer is a read that never asks
;; for a price, and that is URC_09|SuppliesOnly. It touches DPTF/DPOF and nothing else.
;;
;; ------------------------------------------------------------------------------------------
;; HOW THE CLIENT REACHES IT
;; ------------------------------------------------------------------------------------------
;; OuronetUI's transport redirect now carries a DEGRADED table: when a priced read fails, it
;; retries the same rows through URC_09|SuppliesOnly before giving up. Balances render, prices
;; dash, every row says `priced: false`. That replaces a fallback which re-issued the LEGACY
;; DPL-UR call -- correct while DPL-UR answered, worthless since PureV2/14 emptied it, because
;; the retry was then guaranteed to fail as well.
;;
;; The key shape is unchanged, so `formatTFEntry` and `formatOFEntry` in @ouronet/ouronet-core
;; need no edit: the worth fields are present and blank rather than absent.
;;
;; SIGNING -- namespace keyset AND the Demiurgoi keyset. The interfaces are first deploys and
;; check nothing; the module UPGRADES run GOV|O_UI_EIGHT_ADMIN and GOV|O_UI_NINE_ADMIN, both
;; keyset-ref-guard(GOV|Demiurgoi).
;; =========================================================================================

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/08_O-UI-EIGHT.pact
(interface OUiEightV2
    @doc "True Fungibles page reads: per-token wallet entries, native and frozen LP entries, \
        \ the per-token button map, and the page header. Complete surface."

    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroEntry:object ())
    ;;{5.2}  Compute [UC]
    (defun UC_Price:string (input-price:decimal))
    ;;{5.3}  Read [UR/URC/URH]
    ;;  CLIENT READS -- see the banner in the module body.
    (defun URH_01|Header:object (account:string))
    (defun URC_02|TokenEntry:object (account:string dptf:string))
    (defun URC_03|TokenList:[object] (account:string dptfs:[string]))
    (defun URCv_04|LpEntry:object (account:string swpair:string iz-native:bool))
    (defun URC_05|NativeLpList:[object] (account:string lp-ids:[string]))
    (defun URC_06|FrozenLpList:[object] (account:string lp-ids:[string]))
    (defun URC_07|Buttons:object (account:string dptf:string))
    (defun URC_08|Wallet:object (account:string))
    (defun URC_09|SuppliesOnly:[object] (account:string dptfs:[string]))
)

(module O-UI-EIGHT GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiEightV2)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-EIGHT             (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_EIGHT_ADMIN)))
    (defcap GOV|O_UI_EIGHT_ADMIN ()         (enforce-guard GOV|MD_O-UI-EIGHT))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroEntry:object ()
        @doc "What an unreadable list member degrades to. Carries EVERY key a real entry \
            \ carries, so a consumer indexing the object cannot hit a key-not-found; \
            \ `entry-ok` false is what distinguishes a dead entry from a genuinely empty one."
        {"t1"                       : "--"
        ,"t2"                       : "--"
        ,"wallet-supply"            : 0.0
        ,"dptf-supply"              : 0.0
        ,"wallet-worth-in-stoa"     : 0.0
        ,"wallet-worth-in-dollarz"  : "--"
        ,"token-worth-in-stoa"      : 0.0
        ,"token-worth-in-dollarz"   : "--"
        ,"entry-ok"                 : false}
    )

    ;;{5.2}  Compute [UC]
    (defun UC_Price:string (input-price:decimal)
        @doc "Dollar/cent display form. Copied from DPL-UR::UC_ConvertPrice rather than \
            \ shared: a formatter shared across read modules makes every module that uses it \
            \ a redeploy dependency of the one that owns it (../RULES.md rule 7)."
        (if (< input-price 0.00001)
            "<0.001¢"
            (if (< input-price 1.00)
                (format "{}¢" [(floor (* input-price 100.0) 3)])
                (format "{}$" [(floor input-price 2)])
            )
        )
    )

    ;;{5.3}  Read [UR/URC/URH]
    ;; ---------------------------------------------------------------------------------------
    ;; CLIENT READS -- everything below is called BY NAME from OuronetUI. The `NN|` designator
    ;; is the pin: it says this exact function is a wire contract, and its argument list and
    ;; key shape may not be changed without changing the consumer in the same breath.
    ;; ---------------------------------------------------------------------------------------
    (defun URH_01|Header:object (account:string)
        @doc "Page header. HEAVY and UNCOMPOSABLE -- it holds the cross-module `keys` scan; \
            \ see the module header for why nothing may call it. \
            \ \
            \ Replaces DPL-UR::URC_0016_TruefungibleHeader, key-for-key."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
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
    (defun URC_02|TokenEntry:object (account:string dptf:string)
        @doc "One wallet row: name, id, supplies, and worth in both STOA and dollars. \
            \ Supports native, Frozen and Reserved DPTFs. \
            \ \
            \ Replaces DPL-UR::URC_0008a_TrueFungibleEntry, key-for-key, plus `entry-ok`."
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (dptf-id:string (ref-DPTF::URCv_Parent dptf))
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
            ,"wallet-supply"            : wallet-supply
            ,"dptf-supply"              : dptf-supply
            ,"wallet-worth-in-stoa"     : wallet-worth-in-stoa
            ,"wallet-worth-in-dollarz"  : (UC_Price wallet-worth-in-dollarz)
            ,"token-worth-in-stoa"      : token-worth-in-stoa
            ,"token-worth-in-dollarz"   : (UC_Price token-worth-in-dollarz)
            ,"entry-ok"                 : true}
        )
    )
    (defun URC_03|TokenList:[object] (account:string dptfs:[string])
        @doc "URC_02|TokenEntry across a list, each member degradable. \
            \ \
            \ Replaces DPL-UR::URC_0008a_TrueFungibleEntryMapper."
        (map
            (lambda (dptf:string) (try (UDC_ZeroEntry) (URC_02|TokenEntry account dptf)))
            dptfs
        )
    )
    (defun URCv_04|LpEntry:object (account:string swpair:string iz-native:bool)
        @doc "One LP row. `iz-native` true selects the native LP token, false the frozen \
            \ counterpart. \
            \ \
            \ `v`, NOT `URC_`: the enforce is intrinsic to the computation -- asking for the \
            \ frozen counterpart of a pool that has none has no answer, and returning the \
            \ native row instead would silently show a user the wrong token's balance. \
            \ \
            \ Called BOTH directly by the UI and by the two list mappers below. \
            \ Replaces DPL-UR::URCv_0008b_TrueFungibleLPEntry, key-for-key, plus `entry-ok`."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (lp-id:string (ref-SWP::UR_TokenLP swpair))
            )
            (let
                (
                    (lp-id-frozen-counterpart:string (ref-DPTF::UR_Frozen lp-id))
                )
                (if (not iz-native)
                    (enforce
                        (!= (ref-U|CT::CT_BAR) lp-id-frozen-counterpart)
                        "Frozen LP must be defined for this usage")
                    true
                )
                (let
                    (
                        (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        ;;
                        (lp-id-used:string (if iz-native lp-id lp-id-frozen-counterpart))
                        (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                        (token-worth-in-stoa:decimal (at 1 (ref-SWPI::URC_PoolValue swpair)))
                    )
                    (let
                        (
                            (wallet-supply:decimal
                                (ref-DPTF::UR_AccountSupply lp-id-used account))
                            (token-worth-in-dollarz:decimal (* stoa-pid token-worth-in-stoa))
                        )
                        {"t1"                       : (ref-DPTF::UR_Name lp-id-used)
                        ,"t2"                       : lp-id-used
                        ,"wallet-supply"            : wallet-supply
                        ,"dptf-supply"              : (ref-DPTF::UR_Supply lp-id-used)
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
    )
    (defun URC_05|NativeLpList:[object] (account:string lp-ids:[string])
        @doc "Native LP rows for a list of LP token ids, each member degradable. \
            \ \
            \ Replaces DPL-UR::URC_0008b_TrueFungibleNativeLPMapper."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (map
                (lambda (lp-id:string)
                    (try
                        (UDC_ZeroEntry)
                        (URCv_04|LpEntry account (ref-SWP::UR_GetLpSwpair lp-id) true)
                    )
                )
                lp-ids
            )
        )
    )
    (defun URC_06|FrozenLpList:[object] (account:string lp-ids:[string])
        @doc "Frozen LP rows for a list of LP token ids, each member degradable. \
            \ \
            \ A pool with no frozen counterpart makes URCv_04|LpEntry REFUSE, and here that \
            \ refusal is the right thing to swallow: the list is display, and one pool without \
            \ a frozen LP is a normal state, not an error the user must see. \
            \ \
            \ Replaces DPL-UR::URC_0008b_TrueFungibleFrozenLPMapper."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (map
                (lambda (lp-id:string)
                    (try
                        (UDC_ZeroEntry)
                        (URCv_04|LpEntry account (ref-SWP::UR_GetLpSwpair lp-id) false)
                    )
                )
                lp-ids
            )
        )
    )
    (defun URC_07|Buttons:object (account:string dptf:string)
        @doc "Which token actions the chain will accept for this account and token, plus the \
            \ four `where-*` target lists the Coil/Curl/Constrict/Brumate modals are built \
            \ from. \
            \ \
            \ Replaces DPL-UR::URC_0017_TruefungibleButton, key-for-key."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS-C:module{AutostakeComputerV2} ATS)
                ;;
                (owner:string (ref-DPTF::UR_Konto dptf))
                (balance:decimal (ref-DPTF::UR_AccountSupply dptf account))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (elite-auryn-id:string (ref-DALOS::UR_EliteAurynID))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (ustoa-id:string (ref-DALOS::UR_UrStoaID))
                (ouro-balance:decimal (ref-DPTF::UR_AccountSupply ouro-id account))
                ;;
                (can-wipe:bool (ref-DPTF::UR_CanWipe dptf))
                (iz-owner:bool (= account owner))
                ;;
                (first-two:string (take 2 dptf))
                ;;
                (can-coil-obj:object{AutostakeComputerV2.CanCoil} (ref-ATS-C::UC_CanCoil dptf))
                (can-curl-obj:object{AutostakeComputerV2.CanCurl} (ref-ATS-C::UC_CanCurl dptf))
                (can-constrict-obj:object{AutostakeComputerV2.CanConstrict}
                    (ref-ATS-C::UC_CanConstrict dptf))
                (can-brumate-obj:object{AutostakeComputerV2.CanBrumate}
                    (ref-ATS-C::UC_CanBrumate dptf))
                ;;
                ;;Transfer Check
                (min-move:decimal (ref-DPTF::UR_MinMove dptf))
            )
            (let
                (
                    (iz-ea:bool (= dptf elite-auryn-id))
                    (iz-frozen-token:bool (= first-two "F|"))
                    (iz-lp:bool
                        (fold (or) false
                            [(= first-two "S|") (= first-two "W|") (= first-two "P|")]))
                    (transfer:bool
                        (fold (and) true
                            [
                                (if (ref-DPTF::UR_FeeToggle dptf) (>= balance min-move) true)
                                (not (ref-DPTF::UR_Paused dptf))
                                (not (ref-DPTF::UR_AccountFrozenState dptf account))
                            ]
                        )
                    )
                )
                {"mint"         : (ref-DPTF::UR_AccountRoleMint dptf account)
                ,"burn"         : (ref-DPTF::UR_AccountRoleBurn dptf account)
                ,"wipe"         : (and can-wipe iz-owner)
                ,"unfold"       : iz-lp
                ,"freeze"       : (if iz-frozen-token false (ref-DPTF::URC_HasFrozen dptf))
                ,"reserve"      : (and (ref-DPTF::URC_HasReserved dptf)
                                       (ref-DPTF::UR_IzReservationOpen dptf))
                ,"vest"         : (and iz-owner (ref-DPTF::URC_HasReserved dptf))
                ,"sleep"        : (ref-DPTF::URC_HasSleeping dptf)
                ,"hibernate"    : (ref-DPTF::URC_HasHibernation dptf)
                ,"coil"         : (at "can-coil" can-coil-obj)
                ,"curl"         : (at "can-curl" can-curl-obj)
                ,"constrict"    : (at "can-constrict" can-constrict-obj)
                ,"brumate"      : (at "can-brumate" can-brumate-obj)
                ,"recover"      : (ref-DPTF::URC_IzRBT dptf)
                ,"sublimate"    : (= dptf ouro-id)
                ,"compress"     : (= dptf ignis-id)
                ,"transmute"    : (if iz-frozen-token false (if iz-ea (>= ouro-balance 0.0) true))
                ,"unwrap"       : (or (= dptf wstoa-id) (= dptf ustoa-id))
                ,"transfer"     : (if iz-frozen-token
                                    false
                                    (if iz-ea (and (>= ouro-balance 0.0) transfer) transfer))
                ;;
                ,"where-coil"       : (at "where-coil" can-coil-obj)
                ,"where-curl"       : (at "where-curl" can-curl-obj)
                ,"where-constrict"  : (at "where-constrict" can-constrict-obj)
                ,"where-brumate"    : (at "where-brumate" can-brumate-obj)
                }
            )
        )
    )
    (defun URC_08|Wallet:object (account:string)
        @doc "THE ONE READ FOR THE PAGE. Held and managed token lists, their counts, and the \
            \ fully-populated wallet rows for every held token -- what today costs four \
            \ round trips (header, token list, native LPs, frozen LPs). \
            \ \
            \ It does NOT carry `total-true-fungible-number`. That single integer is the only \
            \ thing in the header that needs the cross-module `keys` scan, and composing the \
            \ scan is what makes a composer both undegradable and non-conformant. A count of \
            \ every token that exists is page furniture; fetch it from URH_01|Header when it \
            \ is wanted, or leave it dashed. \
            \ \
            \ `list-ok` is false when the held-token read itself failed, which is different \
            \ from a wallet that legitimately holds nothing."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (held-tf:[string] (ref-DPTF::URH_HeldTrueFungibles account))
                (mngd-tf:[string] (ref-DPTF::URH_OwnedTrueFungibles account))
            )
            {"held-tf"          : held-tf
            ,"held-tf-number"   : (length held-tf)
            ,"mngd-tf"          : mngd-tf
            ,"mngd-tf-number"   : (length mngd-tf)
            ,"entries"          : (URC_03|TokenList account held-tf)
            ,"list-ok"          : true}
        )
    )
    (defun URC_09|SuppliesOnly:[object] (account:string dptfs:[string])
        @doc "THE SAME ROWS, WITH THE PRICING ENGINE LEFT OUT. Name, id and both supplies; the \
            \ four worth fields are present but blank, and `priced` is false. \
            \ \
            \ WHY THIS HAS TO BE A SEPARATE READ RATHER THAN A `try`. On 2026-09-25 the True \
            \ Fungibles page showed no amounts at all, and the balances were never the problem \
            \ -- UR_AccountSupply answered 837.7467 for the very token that rendered blank. \
            \ What failed was SWPI::URC_TokenDollarPrice, because SWPT|PathCache did not exist \
            \ on chain. URC_02|TokenEntry computes supply and price in one `let`, so the price \
            \ took the balance down with it. \
            \ \
            \ And `try` CANNOT fix that, which is the part worth knowing: a missing table raises \
            \ `Error during database operation`, and like an arithmetic exception it passes \
            \ straight THROUGH `try` -- measured, in a module whose deftable was never created. \
            \ So the guard cannot live inside the read. The only structural defence is to not \
            \ ask for the price in the first place. \
            \ \
            \ A BALANCE MUST NOT DEPEND ON A SWAP ROUTER. This read touches DPTF only."
        (map
            (lambda (dptf:string)
                (let
                    (
                        (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    )
                    {"t1"                       : (ref-DPTF::UR_Name dptf)
                    ,"t2"                       : dptf
                    ,"wallet-supply"            : (ref-DPTF::UR_AccountSupply dptf account)
                    ,"dptf-supply"              : (ref-DPTF::UR_Supply dptf)
                    ;;present so a consumer indexing the object still finds every key it knows
                    ,"wallet-worth-in-stoa"     : 0.0
                    ,"wallet-worth-in-dollarz"  : "--"
                    ,"token-worth-in-stoa"      : 0.0
                    ,"token-worth-in-dollarz"   : "--"
                    ,"entry-ok"                 : true
                    ,"priced"                   : false}
                )
            )
            dptfs
        )
    )
)

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/09_O-UI-NINE.pact
(interface OUiNineV2
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
    (defun URC_09|SuppliesOnly:[object] (account:string dpofs:[string]))
)

(module O-UI-NINE GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiNineV2)

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
    (defun URC_09|SuppliesOnly:[object] (account:string dpofs:[string])
        @doc "O-UI-EIGHT's URC_09|SuppliesOnly for orto-fungibles: name, id, both supplies and \
            \ the nonce list, with the four worth fields blank and `priced` false. \
            \ \
            \ This module already splits the valuation out and wraps it in `try`, which handles \
            \ an unpriceable TOKEN -- but not an unavailable pricing ENGINE. A missing table \
            \ raises an error that passes straight through `try`, so when SWPT|PathCache did \
            \ not exist the whole page went blank despite the split. The only defence against \
            \ that is a read that never asks for a price, which is this one."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (map
                (lambda (dpof:string)
                    (let
                        (
                            (wallet-nonces:[integer] (ref-DPOF::URH_AccountNonces account dpof))
                        )
                        {"t1"                       : (ref-DPOF::UR_Name dpof)
                        ,"t2"                       : dpof
                        ,"wallet-supply"            : (ref-DPOF::UR_AccountSupply dpof account)
                        ,"dpof-supply"              : (ref-DPOF::UR_Supply dpof)
                        ,"wallet-nonces"            : wallet-nonces
                        ,"wallet-nonces-no"         : (length wallet-nonces)
                        ,"wallet-worth-in-stoa"     : 0.0
                        ,"wallet-worth-in-dollarz"  : "--"
                        ,"token-worth-in-stoa"      : 0.0
                        ,"token-worth-in-dollarz"   : "--"
                        ,"entry-ok"                 : true
                        ,"priced"                   : false}
                    )
                )
                dpofs
            )
        )
    )
)


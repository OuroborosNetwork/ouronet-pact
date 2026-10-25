;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- PureV12, file 1 of 1.  ONE transaction. Send it and stop.
;;
;; WHAT IT FIXES. URC_06|FrozenLpList asked SWP|LP for a swpair using the FROZEN
;; LP id. That table is keyed by the NATIVE id, so the read found no row, the
;; function's own `try` swallowed the failure, and EVERY frozen LP degraded to
;; UDC_ZeroEntry. A holder with a real 134,224.0642 fLP position saw
;; "0.0000 held" in My Liquidity Positions and "No Existing Supply" under
;; True Fungibles -> Holdings -> Frozen LP, while the AQP stake page -- which
;; reads the balance directly and never needs a swpair -- showed the true figure.
;; Reported 2026-10-17.
;;
;; THE FIX, one expression: resolve the swpair through the LINK.
;;     (UR_GetLpSwpair (UR_Frozen lp-id))
;; `frozen-link` is written bidirectionally, so UR_Frozen on a frozen id returns
;; the native one. NOT an "F|" prefix strip -- a frozen counterpart is separately
;; minted with its own suffix (native ...LP-6D_MJJXmhuz3 vs frozen
;; F|...LP-_MYr9VcKUkBx). Same defect and resolution as commit aaa67eea.
;;
;; BUILT FROM Deploy/PureV10/06_deploy.pact, byte for byte, PLUS that one
;; expression. V10 is what the chain accepted, so the interface pins here are the
;; ones that are live: DemiourgosPactTrueFungibleV3, SwapperV5, OuronetDalosV3.
;;
;; A FIRST ATTEMPT PINNED V2/V4 AND FAILED TYPE CHECK ("the argument is modref but
;; the expected type is modref"). It was built against Deploy/LIVE-MODULES.json,
;; which is dated 2026-09-29 -- two weeks and two deploy rounds stale, PureV10
;; (the 38-interface membership sweep) and PureV11 among them. The snapshot said
;; V2/V4; the chain had moved to V3/V5. Run `_registrylive.py --record` after a
;; deploy, and do not read that file as the state of the world.
;;
;; THE INTERFACE IS OMITTED ON PURPOSE. OUiEightV2 is already on chain and Pact
;; refuses to deploy an interface name twice, identical bytes included. V10
;; omitted it the same way; only the module is upgraded, and modules upgrade
;; freely.
;;
;; SIGNER: the Ouronet admin (GOV|MD_O-UI-EIGHT -> GOV|Demiurgoi keyset).
;; Paste this whole file as ONE transaction, in the ouronet-ns namespace.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

(module O-UI-EIGHT GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiEightV2)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-EIGHT             (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_EIGHT_ADMIN)))
    (defcap GOV|O_UI_EIGHT_ADMIN ()         (enforce-guard GOV|MD_O-UI-EIGHT))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV3} DALOS)) (ref-DALOS::GOV|Demiurgoi))
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
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-SWPI:module{SwapperIssueV5} SWPI)
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
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-SWP:module{SwapperV5} SWP)
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
                        (ref-SWPI:module{SwapperIssueV5} SWPI)
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
                (ref-SWP:module{SwapperV5} SWP)
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
                (ref-SWP:module{SwapperV5} SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
            )
            (map
                (lambda (lp-id:string)
                    (try
                        (UDC_ZeroEntry)
                        (URCv_04|LpEntry account
                            (ref-SWP::UR_GetLpSwpair (ref-DPTF::UR_Frozen lp-id)) false)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-ATS-C:module{AutostakeComputerV3} ATS)
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
                (can-coil-obj:object{AutostakeComputerV3.CanCoil} (ref-ATS-C::UC_CanCoil dptf))
                (can-curl-obj:object{AutostakeComputerV3.CanCurl} (ref-ATS-C::UC_CanCurl dptf))
                (can-constrict-obj:object{AutostakeComputerV3.CanConstrict}
                    (ref-ATS-C::UC_CanConstrict dptf))
                (can-brumate-obj:object{AutostakeComputerV3.CanBrumate}
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
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
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
                        (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
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

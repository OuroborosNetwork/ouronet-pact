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
    (defconst GOV|MD_EXPLORER                           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|EXPLORER_ADMIN)))
    (defcap GOV|EXPLORER_ADMIN ()                       (enforce-guard GOV|MD_EXPLORER))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

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
    (defconst BAR                                       (CT_Bar))
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
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    ;;
    ;;
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::UR_AccountNonce account)
        )
    )
    (defun URC_0001_LandingPage ()
        @doc "Explorer landing: global z3 stats, OURO/AURYN/ELITEAURYN/IGNIS supplies, Auryn index pair."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-SWP:module{SwapperV5} SWP)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (auryn-id:string (ref-DALOS::UR_AurynID))
                (elite-auryn-id:string (ref-DALOS::UR_EliteAurynID))
                ;;
                ;; DERIVED, NOT HARDCODED. These two were mainnet Auryndex / EliteAuryndex
                ;; pair-id literals whose suffix is the block hash of the transaction that
                ;; created the pool -- correct for one issuance, wrong after any re-issuance.
                ;;
                ;; WHAT THEY ACTUALLY COST, stated accurately: NOT the 2026-09-24 dashboard
                ;; outage. That was the pre-sweep DPL-UR failing to bind `module{OuronetDalosV1}`
                ;; and friends, and the round that caused it ran in UPGRADE mode, so no table was
                ;; recreated and no id moved. What these literals cost is a TEST: a mainnet id
                ;; does not exist in a sandbox, so this function aborted on its first read and
                ;; could never be asserted against on any chain but mainnet.
                ;;
                ;; Note the four lines directly above, which derive their token ids correctly:
                ;; the derivation was right here all along and stopped two lines short.
                ;;
                ;; RBT direction on purpose -- a reward-BEARING token belongs to exactly one
                ;; pool, whereas a reward token may be paid by several.
                ;;
                ;; The literals are DESCRIBED above rather than QUOTED, and that is not fussiness:
                ;; _stagez_variant.py rewrote this module by exact string match and counted
                ;; occurrences across the whole file, comments included. Quoting the old ids in a
                ;; comment fed its substitution a target and let it report success while changing
                ;; no code -- the exact no-op it was built to refuse.
                (Auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken auryn-id)))
                (EAuryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken elite-auryn-id)))
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
    (defun URC_0002_AccountHeader (account:string)
        @doc "THE ACCOUNT HEADER, IN ONE CALL — identity + Ouro/Ignis balance + payment-key (STOA)
            \ sample + discounts + StoicTag, for an EXPLORER account-lookup page (search any
            \ account, not just the connected wallet, which is why this lives here and not in
            \ AppReads/OuronetUI: see 10-architecture/08-the-read-layer.md — 'an app's reads are
            \ its own').
            \ \
            \ RESTORED, NOT NEW. This is DPL-UR::URC_0027a_AccountSelectorSingle, field-for-field,
            \ from the revision before DPL-UR went to archive mode (commit bd9af23d,
            \ 2026-09-25) — the function the explorer backend has been calling by that dead path
            \ ever since, silently failing every account header read (see 01_DPL-UR.pact's own
            \ archive-mode banner: its 64 readers were deleted outright, not aliased, and the
            \ account-selector family was never in its own 'replacements' list because no other
            \ consumer needed it — AppReads/OuronetUI only ever reads the CONNECTED wallet, never
            \ an arbitrary one). Only the module-ref versions moved forward (OuronetDalosV2 ->
            \ OuronetDalosV3, CodexV2 -> CodexV3); every UR_/URC_ member this calls still exists
            \ under the same name and signature on the current interfaces — checked against
            \ 01_DALOS.pact / 21_CODEX.pact before porting, not assumed."
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-CODEX:module{CodexV3} CODEX)
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
    (defun URC_0003_TrueFungibleEntry (account:string dptf:string)
        @doc "RESTORED from DPL-UR::URC_0008a_TrueFungibleEntry (commit bd9af23d, before archive
            \ mode) — same provenance note as URC_0002_AccountHeader above. Module-ref versions
            \ moved forward (DemiourgosPactTrueFungibleV2 -> V3, SwapperIssueV4 -> V5,
            \ OuronetDalosV2 -> V3); every member called still exists under the same name and
            \ signature on the current interfaces. One true-fungible holding, enriched with its
            \ STOA/USD worth via the same SWP price reader the exec path prices swaps with —
            \ supports native DPTFs, Frozen DPTFs and Reserved DPTFs alike (they are all DPTF ids)."
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
            ,"wallet-worth-in-dollarz"  : wallet-worth-in-dollarz
            ,"token-worth-in-stoa"      : token-worth-in-stoa
            ,"token-worth-in-dollarz"   : token-worth-in-dollarz
            }
        )
    )
    (defun URC_0003a_TrueFungibleEntryMapper (account:string dptfs:[string])
        @doc "Batch form of URC_0003_TrueFungibleEntry, ONE read for a candidate id list — see
            \ its @doc for provenance."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[object] dptf:string)
                    (ref-U|LST::UC_AppL acc (URC_0003_TrueFungibleEntry account dptf))
                )
                []
                dptfs
            )
        )
    )
    (defun URC_0004_OrtoFungibleEntry (account:string dpof-id:string)
        @doc "RESTORED from DPL-UR::URC_0009a_OrtoFungibleEntry — see URC_0002_AccountHeader's
            \ @doc for provenance. Module-ref versions moved forward
            \ (DemiourgosPactOrtoFungibleV2 -> V3, SwapperIssueV4 -> V5); every member called
            \ still exists under the same name and signature on the current interfaces."
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (ref-SWPI:module{SwapperIssueV5} SWPI)
                ;;
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (dptf-id:string (ref-DPOF::URCv_Parent dpof-id))
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
            ,"wallet-supply"            : wallet-supply
            ,"dpof-supply"              : dpof-supply
            ,"wallet-nonces"            : wallet-nonces
            ,"wallet-nonces-no"         : (length wallet-nonces)
            ,"wallet-worth-in-stoa"     : wallet-worth-in-stoa
            ,"wallet-worth-in-dollarz"  : wallet-worth-in-dollarz
            ,"token-worth-in-stoa"      : token-worth-in-stoa
            ,"token-worth-in-dollarz"   : token-worth-in-dollarz
            }
        )
    )
    (defun URC_0004a_OrtoFungibleEntryMapper (account:string dpofs:[string])
        @doc "Batch form of URC_0004_OrtoFungibleEntry, ONE read for a candidate id list — see
            \ its @doc for provenance."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[object] dpof:string)
                    (ref-U|LST::UC_AppL acc (URC_0004_OrtoFungibleEntry account dpof))
                )
                []
                dpofs
            )
        )
    )
    (defun URC_0005_CollectableEntry (account:string dpdc-id:string son:bool)
        @doc "RESTORED from DPL-UR::URC_0022_CollectableEntry — see URC_0002_AccountHeader's
            \ @doc for provenance. Module-ref version moved forward (DpdcV2 -> V3); every member
            \ called still exists under the same name and signature on the current interface.
            \ `son` picks the family: true = DPSF (semi-fungible), false = DPNF (non-fungible) —
            \ same table, same reader, the family is a parameter not a different function."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
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
    (defun URC_0005a_SemifungibleEntryMapper (account:string dpdc-ids:[string])
        @doc "Batch form of URC_0005_CollectableEntry with son=true (DPSF) — see its @doc for
            \ provenance."
        (map
            (lambda
                (dpdc-id:string)
                (URC_0005_CollectableEntry account dpdc-id true)
            )
            dpdc-ids
        )
    )
    (defun URC_0005b_NonfungibleEntryMapper (account:string dpdc-ids:[string])
        @doc "Batch form of URC_0005_CollectableEntry with son=false (DPNF) — see its @doc for
            \ provenance."
        (map
            (lambda
                (dpdc-id:string)
                (URC_0005_CollectableEntry account dpdc-id false)
            )
            dpdc-ids
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

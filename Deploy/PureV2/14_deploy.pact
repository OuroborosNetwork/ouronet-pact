;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 14
;; DPL-UR (module UPGRADE)  --  ARCHIVE MODE. The read layer is retired.
;; =========================================================================================
;; *** DEPLOY THIS LAST, AND ONLY AFTER EVERY PAGE HAS BEEN CHECKED. ***
;;
;; This removes 57 of DPL-UR's 75 definitions. Until now the transport redirect in OuronetUI has
;; had a SAFETY NET: if an AppReads module refused, the shim re-issued the ORIGINAL call and the
;; page kept working on the legacy read. After this transaction that net is gone -- the original
;; no longer exists, so a failure in a new module is a visible failure rather than a silent
;; downgrade.
;;
;; That is the POINT, not a side effect. A migrated read left in place is a second source of
;; truth answering the same question, and the two drift the moment either is touched, so a
;; consumer nobody remembered keeps working quietly on last month's logic. But it does mean the
;; verification has to happen BEFORE this file, not after it.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT GOES, AND ON WHAT RULE
;; ------------------------------------------------------------------------------------------
;;     DELETED IF AND ONLY IF IT MOVED TO AppReads.  Everything else stays.
;;
;; The deleted set is exactly the 47-entry redirect table in OuronetUI's
;; `src/kadena/appReadRedirect.ts`, plus the internals that moved with those reads, plus five
;; display formatters whose successors were verified BY OUTPUT rather than by name. The 18
;; survivors are then the DEPENDENCY CLOSURE of what is left -- computed, not chosen -- so
;; nothing kept can reference something deleted.
;;
;; Surviving: URC_0030_StoicPay and the three PYTHIA reads (no successors, and the oracle
;; console that would pull them does not exist yet); URC_PrimordialIDs, URC_PrimordialPrices,
;; URC_TrueFungibleAmountPrice, URC_StoaCollectionReceivers and URC_SplitStoaPriceForReceivers
;; (never ported -- and the last two carry the STOA-split CONSERVATION invariant that
;; STAGEZ-08 asserts, which deleting them would delete); two helpers and three constants.
;;
;; `implements DeployerReadsV14` is dropped -- Pact requires a module to define every member of
;; an interface it implements. No successor interface is declared, departing from the DPMF
;; precedent deliberately: a tree-wide scan finds DeployerReadsV14 bound by NOTHING, so a V15
;; restating eighteen survivors would be a permanent artefact describing an archive.
;;
;; ------------------------------------------------------------------------------------------
;; HOW THE MIGRATION WAS PROVEN BEFORE THIS FILE WAS WRITTEN
;; ------------------------------------------------------------------------------------------
;; Every replacement was called on MAINNET alongside the function it replaces and the returned
;; objects compared key by key. That is what found the four flattened glyphs (¢ × ≥ Ξ₳), the
;; unreachable Wipe button, the ICO division by zero, and a call to
;; `URC_0008b_TrueFungibleLPEntry` -- a member DPL-UR does not have, which means the LP balance
;; panel on the SWP Pairs page has never once rendered.
;;
;; Parity cannot outlive this transaction, so its durable half was preserved first: RDUI-16 in
;; `REPL/modules/APPREADS-OuronetUI.repl` pins 177 keys across 10 client reads, READ OFF MAINNET
;; rather than copied from the sources. And the 162 assertions in `modules/STAGE-Z.repl` were
;; RETARGETED at the replacements rather than deleted with the originals.
;;
;; SIGNING -- namespace keyset AND the Demiurgoi keyset (GOV|DPL_UR_ADMIN).
;;
;; MEASURED in the REPL fixture: 3,026 lines -> 436. Upgrade gas is far below the first deploy's,
;; since upgrade mode ships no tables and DPL-UR declares none.
;; =========================================================================================

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/01_DPL-UR.pact (module only -- its interface is already live)
(module DPL-UR GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPL-UR                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|DPL_UR_ADMIN)))
    (defcap GOV|DPL_UR_ADMIN ()                         (enforce-guard GOV|MD_DPL-UR))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun UC_TrimDecimalTrailingZeros:string (number:decimal)
        @doc "Trims trailing zeros from a decimal number"
        (let* 
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
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
    (defun URC_TrueFungibleAmountPrice:decimal (id:string amount:decimal price:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (idp:integer (ref-DPTF::UR_Decimals id))
            )
            (floor (* amount price) idp)
        )
    )
    (defun URC_PrimordialIDs:[string] ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-SWPI:module{SwapperIssueV4} SWPI)
                ;;
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;DEAD BLOCK REMOVED 2026-09-13. This used to bind p-ids := (URC_PrimordialIDs) and
                ;;destructure all six ids out of it positionally, immediately above the five named
                ;;reads below. Every one of the six was then dead: five were shadowed by the named
                ;;binding that follows, and <ignis> was never read at all (dollar-ignis is a literal).
                ;;URC_PrimordialIDs performs the SAME six DALOS reads internally, so the block cost a
                ;;helper call plus six table reads per invocation and its result was discarded.
                ;;Behaviour is unchanged -- the named bindings already won the shadowing.
                ;;The equivalence of the positional and named forms is pinned independently by
                ;;REPL/modules/STAGE-Z.repl <<STAGEZ-10>>, which asserts against URC_PrimordialIDs
                ;;directly and so still guards that function's element ORDER for its other consumers.
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
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
    (defun URC_0030_StoicPay (account:string)
        @doc "StoicPay / DEMIPAD-STOICPAY sale UI read bundle (delegates to StoicPayV3 for on-chain data)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SP:module{StoicPayV3} DEMIPAD-STOICPAY)
                (ref-DPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (KpayID:string (ref-SP::UR_KpayID))
                (pad-ledger:string (ref-SP::UR_PAD_LEDGER_ACCOUNT))
                (resident-amount:decimal (ref-DPTF::UR_AccountSupply KpayID pad-ledger))
                (left-for-sale:decimal (* 0.4 resident-amount))
                (sold:decimal (- 100000000.0 left-for-sale))
                (period:integer (ref-SP::UR_GetPeriod))
                (period-ceiling:decimal (ref-SP::URv_PeriodAllocation period))
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
                (single-costs:object{DemiourgosLaunchpadV2.Costs} (ref-SP::URC_KpayAmountCosts 1 0.0))
                (stage-text:string
                    (if (= period -1)
                        "Stage 1 Starts in:"
                        (if (= period 0)
                            "KPay Sale has concluded"
                            (format "Stage {}/25" [period])
                        )

                    )
                )
                (next-stage-text:string
                    (if (= period -1)
                        (format "Genesis Period Ceiling: {} KPAY" [(ref-SP::URv_PeriodAllocation 1)])
                        (if (= period 0)
                            (format "KPAY Circulating supply is {}" [circulating])
                            (if (!= period 25)
                                (format "Next  Stage Ceiling: {} KPAY" [(ref-SP::URv_PeriodAllocation (+ 1 period))])
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
        (let
            (
                (ref-PYTHIA:module{PythiaV5} PYTHIA)
            )
            (map
                (lambda (apollo-account:string)
                    (ref-PYTHIA::UR_ApiKeyRowOrNull apollo-account)
                )
                apollo-accounts
            )
        )
    )
    (defun URC_0033_DualApiKeyMapper:[object] (dual-api-keys:[string])
        @doc "Map PYTHIA.UR_DualLinkRowOrNull over each dual-API key (Standard|Smart composite)."
        (let
            (
                (ref-PYTHIA:module{PythiaV5} PYTHIA)
            )
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
                (ref-PYTHIA:module{PythiaV5} PYTHIA)
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
)


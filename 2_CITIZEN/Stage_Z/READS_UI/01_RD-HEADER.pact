;; ===========================================================================================
;; RD-HEADER -- the dashboard top strip. REFERENCE READ MODULE.
;; ===========================================================================================
;; Mirror this file when adding a read module. It is the worked example for the split described
;; in OuronetInformational/HANDOFFS/HANDOFF-read-layer-split.md.
;;
;; ------------------------------------------------------------------------------------------
;; THE DESIGN DEFECT THIS EXISTS TO FIX
;; ------------------------------------------------------------------------------------------
;; DPL-UR::URC_0001_HeaderV3 binds roughly forty values in ONE EAGER `let` and returns them as
;; one object. Pact's `let` is eager, so a single failing dependency -- one missing token row,
;; one unpopulated index -- aborts the whole call. The dashboard then renders NOTHING, and the
;; error names the innermost form rather than the zone that owns it.
;;
;; That is what made 2026-09-24 hard. The page was blank, which is the same symptom for "the
;; module cannot bind its modrefs", "an ATS pair id is wrong" and "SWP has no pools to price
;; against". Three very different faults, one indistinguishable blank screen, and no way to ask
;; the chain a narrower question without writing a new probe by hand.
;;
;; ------------------------------------------------------------------------------------------
;; THE SHAPE, AND WHY
;; ------------------------------------------------------------------------------------------
;; ONE FUNCTION PER ZONE, each self-contained, each independently callable:
;;     URC_Zone1_Elite      URC_Zone2_Indices      URC_Zone3_Network
;;     URC_Zone4_Prices     URC_ResidentIgnis
;; plus URC_Header, which composes them.
;;
;; Each zone RECOMPUTES the dependencies it needs rather than receiving them. That costs
;; duplicate reads when all four are called together, and it is worth it twice over: reads run
;; in /local where gas is simulated, and a shared prelude would restore exactly the
;; all-or-nothing coupling this split removes.
;;
;; URC_Header wraps every zone in `try`. A failing zone yields its zero-object; the other four
;; still render. A UI showing four zones and one placeholder is strictly better than a blank
;; page, AND it localises the fault without a single extra query -- the zone that came back
;; zero IS the diagnosis.
;;
;; ------------------------------------------------------------------------------------------
;; RULES FOR EVERY READ MODULE IN THIS FOLDER
;; ------------------------------------------------------------------------------------------
;;  1. NO TABLES. A read module is a projection over sovereign state. Owning nothing is what
;;     makes it freely redeployable -- there is no migration, because there is nothing to move.
;;  2. NO HARDCODED IDS. Import OuronetIdsV1. Gate-enforced by REPL/tools/_hardcodedids.py.
;;  3. NO CROSS-MODULE `keys`. `(keys OTHER.Table)` is admin-gated in transactional mode and
;;     works in /local only on a node started with --allowReadsInLocal. DPL-UR relies on that
;;     in five functions and it does work live -- but it is a node-configuration dependency,
;;     not a Pact guarantee. Zone 3 below therefore OMITS the account count rather than
;;     inheriting the dependency silently; see the note there.
;;  4. EVERY FUNCTION MUST BE CALLABLE IN THE FIXTURE. The two functions that broke had never
;;     once executed in a test, because their hardcoded mainnet ids do not exist in a sandbox.
;;     A read nothing can call is a read whose staleness is invisible until a user finds it.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface ReadsHeaderV1
    @doc "Dashboard header reads, one function per zone plus a composer. Complete surface: a \
        \ consumer reads this and knows everything the module offers."

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroZone:object ())
    ;;{5.2}  Compute [UC]
    (defun UC_PickId:string (derived:[string] fallback:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_IndexIds:[string] ())
    (defun URC_Zone1_Elite:object (account:string))
    (defun URC_Zone2_Indices:object ())
    (defun URC_Zone3_Network:object ())
    (defun URC_Zone4_Prices:object ())
    (defun URC_ResidentIgnis:string (account:string))
    (defun URC_Header:object (account:string))
)

(module RD-HEADER GOV

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    (implements ReadsHeaderV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    (defconst GOV|MD_RD-HEADER              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G4}  capabilities
    (defcap GOV ()                          (compose-capability (GOV|RD_HEADER_ADMIN)))
    (defcap GOV|RD_HEADER_ADMIN ()          (enforce-guard GOV|MD_RD-HEADER))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroZone:object ()
        @doc "The fallback a failing zone returns from URC_Header. Its `zone-ok` is false, \
            \ which is how a caller tells a dead zone from a zone whose values happen to be \
            \ zero -- a distinction the old all-or-nothing header could not express at all."
        {"zone-ok" : false}
    )

    ;;{5.2}  Compute [UC]
    (defun UC_Amount:string (amount:decimal)
        @doc "Four-decimal display form; sub-threshold values read as <0.0001 rather than 0.0."
        (let ((v:string (format "{}" [(floor amount 4)])))
            (if (= v "0.0") "<0.0001" v)
        )
    )
    (defun UC_Index:string (index:decimal)
        @doc "Index display form: whole part, then four 3-digit groups of the fraction."
        (let*
            ( (fis:string (format "{}" [(floor index 12)]))
              (l1:string (take -3 fis))
              (l2:string (take -3 (drop -3 fis)))
              (l3:string (take -3 (drop -6 fis)))
              (l4:string (take -3 (drop -9 fis)))
              (whole:string (drop -13 fis)) )
            (concat [whole ",[" l4 "." l3 "." l2 "." l1 "]"])
        )
    )
    (defun UC_Price:string (input-price:decimal)
        @doc "Dollar/cent display form, with a floor below which a price reads as <0.001c."
        (if (< input-price 0.00001)
            "<0.001c"
            (if (< input-price 1.00)
                (format "{}c" [(floor (* input-price 100.0) 3)])
                (format "{}$" [(floor input-price 2)])
            )
        )
    )

    (defun UC_PickId:string (derived:[string] fallback:string)
        @doc "DERIVED FIRST, REGISTRY AS FALLBACK -- the resolution of a day-long argument \
            \ about which of the two is correct. Neither is, alone. \
            \ \
            \ A DERIVED id is right on every chain and is the only form a sandbox can test, \
            \ but it depends on DPTF's reverse index being populated -- and an unset index \
            \ returns [\"|\"] rather than [], so it does not fail loudly, it hands a BAR to \
            \ the next call and fails somewhere else. A REGISTRY id is known-good on mainnet \
            \ and provably wrong in a sandbox, which makes every function using one \
            \ untestable, which is exactly how fourteen stale literals shipped unnoticed. \
            \ \
            \ Taking the derivation when it yields a real id and the registry when it does \
            \ not gives a function that runs in the fixture AND on chain, with no branch the \
            \ caller has to know about. The BAR check is explicit because `try` cannot catch \
            \ a sentinel -- nothing was thrown."
        (let ((ref-U|CT:module{OuronetConstantsV2} U|CT))
            (if (= (length derived) 0)
                fallback
                (if (= (at 0 derived) (ref-U|CT::CT_BAR)) fallback (at 0 derived))
            )
        )
    )

    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]

    (defun URC_IndexIds:[string] ()
        @doc "The four primordial ATS pair ids, derived where the reverse index is populated \
            \ and taken from OuronetIdsV1 where it is not. Order: Auryndex, EliteAuryndex, \
            \ SilverStoaPillar, GoldenStoaPillar. Every zone that needs a pair id calls this, \
            \ so the policy lives in exactly one place."
        (let
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF) )
            [ (UC_PickId (ref-DPTF::UR_RewardBearingToken (ref-DALOS::UR_AurynID))
                         OuronetIdsV1.IDX_AURYNDEX)
              (UC_PickId (ref-DPTF::UR_RewardBearingToken (ref-DALOS::UR_EliteAurynID))
                         OuronetIdsV1.IDX_EAURYNDEX)
              (UC_PickId (ref-DPTF::UR_RewardBearingToken (ref-DALOS::UR_SilverStoaID))
                         OuronetIdsV1.IDX_SILVERPILLAR)
              (UC_PickId (ref-DPTF::UR_RewardToken (ref-DALOS::UR_SilverStoaID))
                         OuronetIdsV1.IDX_GOLDENPILLAR) ]
        )
    )

    (defun URC_Zone2_Indices:object ()
        @doc "The four primordial ATS indices, by name and value. \
            \ \
            \ IDS COME FROM OuronetIdsV1, NOT FROM A DERIVATION, and that is deliberate. \
            \ DPTF::UR_RewardBearingToken reads a reverse index whose UNSET value is [\"|\"] \
            \ rather than [] -- so an unpopulated index does not abort, it hands a BAR to \
            \ ATS::URC_Index and fails several frames later naming the wrong thing. These \
            \ literals were known-good on mainnet for months; the derivation is unproven there."
        (let*
            ( (ref-ATS:module{AutostakeV3} ATS)
              (ids:[string] (URC_IndexIds))
              (a:string (at 0 ids))
              (e:string (at 1 ids))
              (s:string (at 2 ids))
              (g:string (at 3 ids)) )
            {"zone-ok"  : true
            ,"auryndex-name"        : (ref-ATS::UR_IndexName a)
            ,"auryndex"             : (UC_Index (ref-ATS::URC_Index a))
            ,"eauryndex-name"       : (ref-ATS::UR_IndexName e)
            ,"eauryndex"            : (UC_Index (ref-ATS::URC_Index e))
            ,"silverpillar-name"    : (ref-ATS::UR_IndexName s)
            ,"silverpillar"         : (UC_Index (ref-ATS::URC_Index s))
            ,"goldenpillar-name"    : (ref-ATS::UR_IndexName g)
            ,"goldenpillar"         : (UC_Index (ref-ATS::URC_Index g))
            }
        )
    )

    (defun URC_Zone4_Prices:object ()
        @doc "Dollar prices for the primordials. Depends on live SWP pools for the OURO price \
            \ and on the STOA PID oracle -- the two things most likely to be absent on a fresh \
            \ chain, which is why this is its own zone rather than folded into zone 1."
        (let*
            ( (ref-ATS:module{AutostakeV3} ATS)
              (ref-SWPI:module{SwapperIssueV4} SWPI)
              (ref-DIA:module{DiaStoaPidV2} U|CT)
              (ids:[string] (URC_IndexIds))
              (ih-a:decimal (ref-ATS::URC_Index (at 0 ids)))
              (ih-e:decimal (ref-ATS::URC_Index (at 1 ids)))
              (ih-s:decimal (ref-ATS::URC_Index (at 2 ids)))
              (ih-g:decimal (ref-ATS::URC_Index (at 3 ids)))
              (p-ouro:decimal (ref-SWPI::URC_OuroPrimordialPrice))
              (p-auryn:decimal (floor (* p-ouro ih-a) 24))
              (p-eauryn:decimal (floor (* p-auryn ih-e) 24))
              (p-wstoa:decimal (ref-DIA::UR_STOA-PID|Price))
              (p-sstoa:decimal (floor (* p-wstoa ih-s) 24))
              (p-gstoa:decimal (floor (* p-sstoa ih-g) 24)) )
            {"zone-ok"      : true
            ,"ignis"        : (UC_Price 0.01)
            ,"ouro"         : (UC_Price p-ouro)
            ,"auryn"        : (UC_Price p-auryn)
            ,"eauryn"       : (UC_Price p-eauryn)
            ,"wstoa"        : (UC_Price p-wstoa)
            ,"sstoa"        : (UC_Price p-sstoa)
            ,"gstoa"        : (UC_Price p-gstoa)
            }
        )
    )

    (defun URC_Zone1_Elite:object (account:string)
        @doc "The account's Elite standing and what the next tier costs. Account-specific, so \
            \ it is the only zone that can fail for one user and work for another -- another \
            \ reason it is not folded in with the global zones."
        (let*
            ( (ref-U|CT:module{OuronetConstantsV2} U|CT)
              (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-ELITE:module{EliteV2} ELITE)
              (ref-ATS:module{AutostakeV3} ATS)
              (ref-SWPI:module{SwapperIssueV4} SWPI)
              (total:decimal (ref-ELITE::URC_EliteAurynzSupply account))
              (et:[decimal] (ref-U|CT::CT_ET))
              (et-last:decimal (at (- (length et) 1) et))
              (next:decimal
                (if (>= total et-last)
                    0.0
                    (- (fold (lambda (acc:decimal tier:decimal)
                                (if (and (> tier total) (< tier acc)) tier acc))
                             et-last et)
                       total)))
              (ids:[string] (URC_IndexIds))
              (ih-a:decimal (ref-ATS::URC_Index (at 0 ids)))
              (ih-e:decimal (ref-ATS::URC_Index (at 1 ids)))
              (ouro-next:decimal (floor (fold (*) 1.0 [next ih-a ih-e]) 24)) )
            {"zone-ok"          : true
            ,"elite-name"       : (ref-DALOS::UR_Elite-Name account)
            ,"elite-tier"       : (ref-DALOS::UR_Elite-Tier account)
            ,"total-aurynz"     : (UC_Amount total)
            ,"aurynz-next"      : (UC_Amount next)
            ,"ouro-next"        : (UC_Amount ouro-next)
            ,"price-next"       : (UC_Price
                                    (floor (* (ref-SWPI::URC_OuroPrimordialPrice) ouro-next) 24))
            }
        )
    )

    (defun URC_Zone3_Network:object ()
        @doc "Network-wide toggles and spend counters. \
            \ \
            \ THE ACCOUNT COUNT IS DELIBERATELY ABSENT. The old header carried \
            \ (length (keys DALOS.DALOS|AccountTable)) here -- a scan of ANOTHER module's \
            \ table, which Pact admin-gates in transactional mode and a node permits in /local \
            \ only when started with --allowReadsInLocal. It does work live today, so this is \
            \ not a bug being fixed; it is a dependency being made deliberate. If the count is \
            \ wanted, it belongs in its own function so that needing it cannot take the rest \
            \ of the zone down with it."
        (let
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-SWP:module{SwapperV4} SWP) )
            {"zone-ok"          : true
            ,"ignis-collection" : (if (ref-DALOS::UR_VirtualToggle) "ON" "OFF")
            ,"stoa-collection"  : (if (ref-DALOS::UR_NativeToggle) "ON" "OFF")
            ,"asymmetric"       : (if (ref-SWP::UR_Asymetric) "ON" "OFF")
            ,"liquid-boost"     : (if (ref-SWP::UR_LiquidBoost) "ON" "OFF")
            ,"ignis-spent"      : (ref-DALOS::UR_VirtualSpent)
            ,"stoa-spent"       : (ref-DALOS::UR_NativeSpent)
            }
        )
    )

    (defun URC_ResidentIgnis:string (account:string)
        @doc "The account's resident IGNIS. One read, no composition -- kept separate because \
            \ it is the single value the header needs that cannot fail for any global reason."
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS))
            (UC_Amount (ref-DALOS::UR_TF_AccountSupply account false))
        )
    )

    (defun URC_Header:object (account:string)
        @doc "All five reads in one call, each under `try`. A failing zone yields UDC_ZeroZone \
            \ (zone-ok false) and the rest still render. \
            \ \
            \ This is the whole point of the module: the old header was one eager `let`, so any \
            \ single failure blanked the page and named the innermost form rather than the zone \
            \ that owned it. Here the zone that comes back with zone-ok false IS the diagnosis, \
            \ at no extra query. Callers wanting a hard failure should call the zone directly."
        {"zone1" : (try (UDC_ZeroZone) (URC_Zone1_Elite account))
        ,"zone2" : (try (UDC_ZeroZone) (URC_Zone2_Indices))
        ,"zone3" : (try (UDC_ZeroZone) (URC_Zone3_Network))
        ,"zone4" : (try (UDC_ZeroZone) (URC_Zone4_Prices))
        ,"resident-ignis" : (try "<unavailable>" (URC_ResidentIgnis account))
        }
    )
)

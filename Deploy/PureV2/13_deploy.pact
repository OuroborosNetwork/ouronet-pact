;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 13
;; O-UI-ONE + O-UI-TWO + O-UI-THREE + O-UI-TWELVE (module UPGRADES) -- display defects
;; =========================================================================================
;; NO NEW INTERFACES. All four are already deployed and may not be redeployed; module bodies
;; only. Two independent defects, both found by comparing live output rather than by reading code.
;;
;; ------------------------------------------------------------------------------------------
;; DEFECT 1 -- FIVE GLYPHS FLATTENED TO ASCII  (O-UI-ONE, O-UI-THREE)
;; ------------------------------------------------------------------------------------------
;; Porting DPL-UR's reads transcribed five user-facing strings with their Unicode lost:
;;
;;   O-UI-ONE   z1-t2              "Total Xi-A"          should be  "Total Ξ₳"
;;   O-UI-ONE   z1-t3              "Xi-A for Next Tier"  should be  "Ξ₳ for Next Tier"
;;   O-UI-THREE deb-bonus-text     "DEB x4.50 ..."       should be  "DEB ×4.50 ..."
;;   O-UI-THREE dispo-overspend    "... Major Tier >= 3" should be  "... Major Tier ≥ 3"
;;   O-UI-THREE dispo-locked-text  "... returns to >= 0" should be  "... returns to ≥ 0"
;;
;; `Ξ₳` is the ELITE-AURYN SYMBOL. "Total Xi-A" is not a subtle rendering difference, it is
;; the wrong words in the header.
;;
;; This is the SECOND fix of the kind -- PureV2/06 restored the CENT SIGN to the price
;; formatters. Four distinct glyphs across four modules, all rendering plausibly, two of them
;; already shipped. No test caught any of it and none could: a test written from the port agrees
;; with the port. They were found by calling the old and the new function on MAINNET and
;; comparing the returned objects key by key.
;;
;; The class is now closed mechanically. `REPL/tools/_glyphparity.py` holds the retired read
;; layer's emitted non-ASCII literals and requires each to appear byte-identically in some
;; AppReads module, with a RETIRED registry for deliberate drops. Its reference is a PINNED
;; LIST, not a file read at runtime -- it read the file first, and stubbing DPL-UR made it
;; report "clean" over zero literals. An empty reference is now fatal.
;;
;; ------------------------------------------------------------------------------------------
;; DEFECT 2 -- A SUB-THRESHOLD SENTINEL THAT HAS NEVER FIRED  (all four modules)
;; ------------------------------------------------------------------------------------------
;; UC_Amount is meant to show `<0.0001` for an amount too small to render at four decimals, so a
;; holder of dust is not told they hold nothing. It reads:
;;
;;     (let ((v (format "{}" [(floor amount 4)]))) (if (= v "0.0") "<0.0001" v))
;;
;; `(floor x 4)` ALWAYS formats to four decimal places. The string is "0.0000", never "0.0", so
;; the branch is unreachable. Measured on chain: UC_Amount 0.00001 returns "0.0000".
;;
;; It was inherited. DPL-UR::UC_FormatTokenAmount had the same dead branch by a different route
;; -- it compared the formatted STRING against the DECIMAL literal 0.0, which cannot match
;; either. The port copied the shape and changed the bug without fixing it.
;;
;; Fixed as `(if (and (> amount 0.0) (= v "0.0000")) "<0.0001" v)`. The `> 0.0` guard matters: a
;; genuine zero must keep reading 0.0000, because dust and nothing are different facts and
;; collapsing them is exactly what the sentinel exists to prevent. Both branches are now pinned
;; by STAGEZ-01.
;;
;; NO OTHER BEHAVIOUR CHANGES. String literals and one comparison. Deploy order is free.
;;
;; SIGNING -- namespace keyset AND the Demiurgoi keyset. A module UPGRADE runs the module's own
;; governance capability -- GOV|O_UI_ONE_ADMIN, GOV|O_UI_TWO_ADMIN, GOV|O_UI_THREE_ADMIN,
;; GOV|O_UI_TWELVE_ADMIN -- each keyset-ref-guard(GOV|Demiurgoi).
;; =========================================================================================

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/01_O-UI-ONE.pact (module only -- its interface is already live)
(module O-UI-ONE GOV

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    (implements OUiOneV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    (defconst GOV|MD_O-UI-ONE              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G4}  capabilities
    (defcap GOV ()                          (compose-capability (GOV|O_UI_ONE_ADMIN)))
    (defcap GOV|O_UI_ONE_ADMIN ()      (enforce-guard GOV|MD_O-UI-ONE))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroZone:object ()
        @doc "The fallback a failing zone returns from URC_01|Header. Its `zone-ok` is false, \
            \ which is how a caller tells a dead zone from a zone whose values happen to be \
            \ zero -- a distinction the old all-or-nothing header could not express at all."
        {"zone-ok" : false}
    )

    ;;{5.2}  Compute [UC]
    (defun UC_Amount:string (amount:decimal)
        @doc "Four-decimal display form. A NON-ZERO amount too small to show at four decimals \
            \ reads as <0.0001; a genuine zero reads as 0.0000, because those are different \
            \ facts and a holder of dust should not be told they hold nothing. \
            \ \
            \ THE COMPARISON IS AGAINST \"0.0000\", NOT \"0.0\", AND THAT IS THE WHOLE FUNCTION. \
            \ `(floor x 4)` always formats to four decimal places, so the string is never \
            \ \"0.0\" and the sentinel branch was UNREACHABLE -- in every copy of this \
            \ function, and in DPL-UR::UC_FormatTokenAmount before them, which compared the \
            \ formatted STRING against the DECIMAL literal 0.0 and so could never match \
            \ either. Verified on chain: UC_Amount 0.00001 returned \"0.0000\"."
        (let ((v:string (format "{}" [(floor amount 4)])))
            (if (and (> amount 0.0) (= v "0.0000")) "<0.0001" v)
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
        @doc "Dollar/cent display form, with a floor below which a price reads as <0.001¢."
        (if (< input-price 0.00001)
            "<0.001¢"
            (if (< input-price 1.00)
                (format "{}¢" [(floor (* input-price 100.0) 3)])
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
              (g:string (at 3 ids))
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (hid:string (ref-DPTF::UR_Hibernation
                            (ref-ATS::UR_ColdRewardBearingToken g))) )
            {"zone-ok"  : true
            ,"auryndex-name"        : (ref-ATS::UR_IndexName a)
            ,"auryndex"             : (UC_Index (ref-ATS::URC_Index a))
            ,"eauryndex-name"       : (ref-ATS::UR_IndexName e)
            ,"eauryndex"            : (UC_Index (ref-ATS::URC_Index e))
            ,"silverpillar-name"    : (ref-ATS::UR_IndexName s)
            ,"silverpillar"         : (UC_Index (ref-ATS::URC_Index s))
            ,"goldenpillar-name"    : (ref-ATS::UR_IndexName g)
            ,"goldenpillar"         : (UC_Index (ref-ATS::URC_Index g))
            ;;The hibernated-GoldenStoa id and its global nonce count. UR_NoncesUsed is a
            ;;bounded `read` of a counter column, NOT a scan -- verified at 06_DPOF.pact:1515 --
            ;;so it is safe inside the composer's `try`. A `select` here would not be.
            ,"hibernated-gstoa-id"      : hid
            ,"hibernated-gstoa-nonces"  : (ref-DPOF::UR_NoncesUsed hid)
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

    ;;=======================================================================================
    ;;  THE ACCOUNT COUNT IS NOT HERE, AND THAT IS THE GATE'S RULING, NOT A PREFERENCE.
    ;;
    ;;  DPL-UR::URC_0001_HeaderV3 reported it as `z3-v1` via
    ;;  `(length (keys DALOS.DALOS|AccountTable))` -- a scan of ANOTHER module's table. Pact
    ;;  admin-gates those on the OWNING module, so the call is LOCAL-ONLY: it aborts in
    ;;  transactional mode and works in `/local` only on a node started with
    ;;  `--allowReadsInLocal`.
    ;;
    ;;  `_conformance.py`'s `cross-module-scan` rule tolerates that ONLY while such a function
    ;;  has ZERO Pact callers -- "a premise nobody re-checks is a premise that quietly stops
    ;;  being true". Factoring the scan into a named `URH_AccountCount` and CALLING it from the
    ;;  composer broke exactly that premise and turned the observation into a violation. The
    ;;  rule's own prescribed fix is to move the scan into the owning module as a `URH_*` and
    ;;  reach it by modref -- and DALOS does have `URH_AccountCounter`, but it is NOT declared
    ;;  in DALOS's interface, so no modref can reach it, and it returns the sentence
    ;;  "Ouronet has N real Accounts!" rather than a number.
    ;;
    ;;  So the field is dropped, and the header is BETTER for it on every axis but one:
    ;;    - no cross-module scan, so no `--allowReadsInLocal` dependency at all;
    ;;    - no module-admin grant needed to call or to test it;
    ;;    - EVERY zone now degrades, where `z3-v1` was the one field that could take the whole
    ;;      page down because a scan cannot live inside a `try`.
    ;;
    ;;  A UI that wants the number calls `ouronet-ns.DALOS.URH_AccountCounter` directly. That
    ;;  is DALOS scanning its OWN table -- same-module, not admin-gated -- so it is cheaper
    ;;  there than it ever was here. It costs one extra round trip for one vanity statistic,
    ;;  which is the honest price of the header never blanking again.
    ;;=======================================================================================

    (defun URC_01|Header:object (account:string)
        @doc "THE HEADER, IN ONE CALL. Flat, with exactly the keys DPL-UR::URC_0001_HeaderV3 \
            \ returned, so a consumer swaps the module path and changes nothing else. \
            \ \
            \ ONE READ PER PAGE is the rule (owner, 2026-09-24): a page should cost one \
            \ round trip, not five. The per-zone functions above are internal structure that \
            \ happens to be callable -- they are for diagnosis, not for the page to assemble. \
            \ A UI calling four of them would pay four round trips for the same answer. \
            \ \
            \ EACH ZONE IS STILL WRAPPED IN `try`, so the split still buys what it was for: a \
            \ zone that cannot read leaves its fields at placeholder and sets its `zN-ok` \
            \ false, while the other three render. The old header was one eager `let` -- any \
            \ single failure returned nothing at all and named the innermost form rather than \
            \ the zone that owned it. \
            \ \
            \ EVERY FIELD DEGRADES. There is no exception, which there was until the account \
            \ count was dropped -- see the banner above URC_01|Header for why it went and \
            \ where a UI gets it instead. `z3-v1` is now a placeholder."
        (let*
            ( (z1:object (try (UDC_ZeroZone) (URC_Zone1_Elite account)))
              (z2:object (try (UDC_ZeroZone) (URC_Zone2_Indices)))
              (z3:object (try (UDC_ZeroZone) (URC_Zone3_Network)))
              (z4:object (try (UDC_ZeroZone) (URC_Zone4_Prices)))
              (k1:bool (at "zone-ok" z1)) (k2:bool (at "zone-ok" z2))
              (k3:bool (at "zone-ok" z3)) (k4:bool (at "zone-ok" z4))
              (dash:string "--") )
            {"z1-ok" : k1, "z2-ok" : k2, "z3-ok" : k3, "z4-ok" : k4
            ;;Zone 1 -- Elite standing
            ,"z1-t1" : (if k1 (at "elite-name" z1) dash)
            ,"z1-v1" : (if k1 (at "elite-tier" z1) dash)
            ,"z1-t2" : "Total Ξ₳"
            ,"z1-v2" : (if k1 (at "total-aurynz" z1) dash)
            ,"z1-t3" : "Ξ₳ for Next Tier"
            ,"z1-v3" : (if k1 (at "aurynz-next" z1) dash)
            ,"z1-t4" : "OURO for Next Tier"
            ,"z1-v4" : (if k1 (at "ouro-next" z1) dash)
            ,"z1-t5" : "$ for Next Tier"
            ,"z1-v5" : (if k1 (at "price-next" z1) dash)
            ;;Zone 2 -- the four indices
            ,"z2-t1" : (if k2 (at "auryndex-name" z2) dash)
            ,"z2-v1" : (if k2 (at "auryndex" z2) dash)
            ,"z2-t2" : (if k2 (at "eauryndex-name" z2) dash)
            ,"z2-v2" : (if k2 (at "eauryndex" z2) dash)
            ,"z2-t3" : (if k2 (at "silverpillar-name" z2) dash)
            ,"z2-v3" : (if k2 (at "silverpillar" z2) dash)
            ,"z2-t4" : (if k2 (at "goldenpillar-name" z2) dash)
            ,"z2-v4" : (if k2 (at "goldenpillar" z2) dash)
            ,"z2-t5" : (if k2 (format "{} Global Nonces:" [(at "hibernated-gstoa-id" z2)]) dash)
            ,"z2-v5" : (if k2 (at "hibernated-gstoa-nonces" z2) 0)
            ;;Zone 3 -- network. z3-v1 is a placeholder; see the banner above this function.
            ,"z3-t1" : "Ouronet Accounts:"
            ,"z3-v1" : dash
            ,"z3-t2" : "IGNIS / STOA Gas Collection:"
            ,"z3-v2" : (if k3 (format "{} / {}"
                                [(at "ignis-collection" z3) (at "stoa-collection" z3)]) dash)
            ,"z3-t3" : "Asym. Liq. Prov. / Liq. Boost:"
            ,"z3-v3" : (if k3 (format "{} / {}"
                                [(at "asymmetric" z3) (at "liquid-boost" z3)]) dash)
            ,"z3-t4" : "Ouronet IGNIS spent:"
            ,"z3-v4" : (if k3 (at "ignis-spent" z3) 0.0)
            ,"z3-t5" : "Ouronet STOA spent"
            ,"z3-v5" : (if k3 (at "stoa-spent" z3) 0.0)
            ;;Zone 4 -- prices
            ,"z4-t1" : "IGNIS"
            ,"z4-v1" : (if k4 (at "ignis" z4) dash)
            ,"z4-t2" : "OURO"
            ,"z4-v2" : (if k4 (at "ouro" z4) dash)
            ,"z4-t3" : "AURYN / ELITEAURYN"
            ,"z4-v3" : (if k4 (format "{} / {}" [(at "auryn" z4) (at "eauryn" z4)]) dash)
            ,"z4-t4" : "STOA"
            ,"z4-v4" : (if k4 (at "wstoa" z4) dash)
            ,"z4-t5" : "SSTOA / GSTOA"
            ,"z4-v5" : (if k4 (format "{} / {}" [(at "sstoa" z4) (at "gstoa" z4)]) dash)
            ;;
            ,"resident-ignis" : (try "<unavailable>" (URC_ResidentIgnis account))
            }
        )
    )
)

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/02_O-UI-TWO.pact (module only -- its interface is already live)
(module O-UI-TWO GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiTwoV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-TWO              (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_TWO_ADMIN)))
    (defcap GOV|O_UI_TWO_ADMIN ()          (enforce-guard GOV|MD_O-UI-TWO))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{3}  CST
    (defconst URSTOA-VAULT "c:GjYbBFM0vxMs5FcmnFUW-LFoycd3Ef8wuP28vR6FG3k")

    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroCard:object ()
        @doc "What a failing card yields from URC_01|Dashboard. `card-ok` false distinguishes a DEAD \
            \ card from one whose balances are legitimately zero -- a distinction the original \
            \ flat object could not express, because a failure produced no object at all."
        {"card-ok" : false}
    )

    ;;{5.2}  Compute [UC]
    (defun UC_Amount:string (amount:decimal)
        @doc "Four-decimal display form; sub-threshold reads as <0.0001 rather than 0.0."
        (let ((v:string (format "{}" [(floor amount 4)])))
            ;;AGAINST "0.0000", NOT "0.0". `(floor x 4)` always formats to four decimals, so
            ;;the string is never "0.0" and this branch was UNREACHABLE -- in every copy here,
            ;;and in DPL-UR::UC_FormatTokenAmount before them, which compared the formatted
            ;;STRING against the DECIMAL 0.0 and so could never match either. The `> 0.0` guard
            ;;keeps a genuine zero showing 0.0000: dust and nothing are different facts.
            (if (and (> amount 0.0) (= v "0.0000")) "<0.0001" v)
        )
    )
    (defun UC_Price:string (input-price:decimal)
        @doc "Dollar/cent display form with a floor below which a price reads as <0.001¢."
        (if (< input-price 0.00001)
            "<0.001¢"
            (if (< input-price 1.00)
                (format "{}¢" [(floor (* input-price 100.0) 3)])
                (format "{}$" [(floor input-price 2)])
            )
        )
    )
    (defun UC_PickId:string (derived:[string] fallback:string)
        @doc "Derived first, registry as fallback. See O-UI-ONE's copy for the full reasoning: \
            \ a derived id is the only form a sandbox can test, a registry id is the only form \
            \ proven on mainnet, and an unset reverse index returns [\"|\"] rather than [] -- a \
            \ sentinel, which is why this is an explicit check and not a `try`."
        (let ((ref-U|CT:module{OuronetConstantsV2} U|CT))
            (if (= (length derived) 0)
                fallback
                (if (= (at 0 derived) (ref-U|CT::CT_BAR)) fallback (at 0 derived))
            )
        )
    )

    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_Value:decimal (id:string amount:decimal price:decimal)
        @doc "Amount times price, floored to the token's own precision."
        (let ((ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF))
            (floor (* amount price) (ref-DPTF::UR_Decimals id))
        )
    )

    (defun URC_Prices:[decimal] ()
        @doc "Dollar prices for the seven priced primordials, in order: \
            \ OURO, IGNIS, AURYN, ELITEAURYN, WSTOA, SSTOA, GSTOA. \
            \ \
            \ Public and called per card rather than computed once and passed down -- see the \
            \ file header. IGNIS is a fixed 0.01 by definition, not a market price."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-ATS:module{AutostakeV3} ATS)
              (ref-SWPI:module{SwapperIssueV4} SWPI)
              (ref-DIA:module{DiaStoaPidV2} U|CT)
              (idx-a:string (UC_PickId (ref-DPTF::UR_RewardBearingToken (ref-DALOS::UR_AurynID))
                                       OuronetIdsV1.IDX_AURYNDEX))
              (idx-e:string (UC_PickId (ref-DPTF::UR_RewardBearingToken (ref-DALOS::UR_EliteAurynID))
                                       OuronetIdsV1.IDX_EAURYNDEX))
              (idx-s:string (UC_PickId (ref-DPTF::UR_RewardBearingToken (ref-DALOS::UR_SilverStoaID))
                                       OuronetIdsV1.IDX_SILVERPILLAR))
              (idx-g:string (UC_PickId (ref-DPTF::UR_RewardToken (ref-DALOS::UR_SilverStoaID))
                                       OuronetIdsV1.IDX_GOLDENPILLAR))
              (p-ouro:decimal (ref-SWPI::URC_OuroPrimordialPrice))
              (p-auryn:decimal (floor (* p-ouro (ref-ATS::URC_Index idx-a)) 24))
              (p-eauryn:decimal (floor (* p-auryn (ref-ATS::URC_Index idx-e)) 24))
              (p-wstoa:decimal (ref-DIA::UR_STOA-PID|Price))
              (p-sstoa:decimal (floor (* p-wstoa (ref-ATS::URC_Index idx-s)) 24))
              (p-gstoa:decimal (floor (* p-sstoa (ref-ATS::URC_Index idx-g)) 24)) )
            [p-ouro 0.01 p-auryn p-eauryn p-wstoa p-sstoa p-gstoa]
        )
    )

    (defun URC_Ouro:object (account:string)
        @doc "The OURO card: held, virtual, dispo capacity, and global supply. \
            \ `dispo-capacity` is the ABSOLUTE value of URC_MinimumOuro -- a negative minimum \
            \ is a credit, and the card shows it as a positive capacity."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-TFT:module{TrueFungibleTransferV2} TFT)
              (id:string (ref-DALOS::UR_OuroborosID))
              (p:decimal (at 0 (URC_Prices)))
              (held:decimal (ref-DPTF::UR_AccountSupply id account))
              (virtual:decimal (ref-TFT::URC_VirtualOuro account))
              (dispo:decimal (abs (ref-TFT::URC_MinimumOuro account)))
              (supply:decimal (ref-DPTF::UR_Supply id)) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount held)      , "balance-hover" : held
            ,"balance-vid" : (UC_Price (URC_Value id held p))
            ,"v-balance" : (UC_Amount virtual) , "v-balance-hover" : virtual
            ,"v-balance-vid" : (UC_Price (URC_Value id virtual p))
            ,"dispo-capacity" : (UC_Amount dispo), "dispo-capacity-hover" : dispo
            ,"dispo-capacity-vid" : (UC_Price (URC_Value id dispo p))
            ,"supply" : (UC_Amount supply)     , "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URC_Ignis:object (account:string)
        @doc "The IGNIS card, plus both gas-discount strings. IGNIS is priced at a flat 0.01 by \
            \ definition rather than by a pool, so this card cannot fail on pricing."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (id:string (ref-DALOS::UR_IgnisID))
              (p:decimal 0.01)
              (held:decimal (ref-DPTF::UR_AccountSupply id account))
              (supply:decimal (ref-DPTF::UR_Supply id))
              (i-d:decimal (ref-DALOS::URC_IgnisGasDiscount account))
              (s-d:decimal (ref-DALOS::URC_StoaGasDiscount account)) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount held)  , "balance-hover" : held
            ,"balance-vid" : (UC_Price (URC_Value id held p))
            ,"supply" : (UC_Amount supply) , "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))
            ,"ignis-discount-text" :
                (format "IGNIS Discount {}% (You pay only {}% of IGNIS costs)"
                        [(* (- 1.0 i-d) 100.0) (* i-d 100.0)])
            ,"stoa-discount-text" :
                (format "STOA Discount {}% (You pay only {}% of STOA costs)"
                        [(* (- 1.0 s-d) 100.0) (* s-d 100.0)])}
        )
    )

    (defun URC_Auryn:object (account:string)
        @doc "The AURYN card: held and global supply."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (id:string (ref-DALOS::UR_AurynID))
              (p:decimal (at 2 (URC_Prices)))
              (held:decimal (ref-DPTF::UR_AccountSupply id account))
              (supply:decimal (ref-DPTF::UR_Supply id)) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount held)  , "balance-hover" : held
            ,"balance-vid" : (UC_Price (URC_Value id held p))
            ,"supply" : (UC_Amount supply) , "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URC_EliteAuryn:object (account:string)
        @doc "The ELITEAURYN card, including how much more is needed for the next Elite tier. \
            \ `next` counts across ALL Elite-Auryn variants (ELITE::URC_EliteAurynzSupply), not \
            \ just the native balance on this card -- which is why the two numbers differ."
        (let*
            ( (ref-U|CT:module{OuronetConstantsV2} U|CT)
              (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-ELITE:module{EliteV2} ELITE)
              (id:string (ref-DALOS::UR_EliteAurynID))
              (p:decimal (at 3 (URC_Prices)))
              (held:decimal (ref-DPTF::UR_AccountSupply id account))
              (supply:decimal (ref-DPTF::UR_Supply id))
              (total:decimal (ref-ELITE::URC_EliteAurynzSupply account))
              (et:[decimal] (ref-U|CT::CT_ET))
              (et-last:decimal (at (- (length et) 1) et))
              (next:decimal
                (if (>= total et-last)
                    0.0
                    (- (fold (lambda (acc:decimal tier:decimal)
                                (if (and (> tier total) (< tier acc)) tier acc))
                             et-last et)
                       total))) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount held)  , "balance-hover" : held
            ,"balance-vid" : (UC_Price (URC_Value id held p))
            ,"next" : (UC_Amount next)     , "next-hover" : next
            ,"next-vid" : (UC_Price (URC_Value id next p))
            ,"supply" : (UC_Amount supply) , "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URC_UrStoa:object (account:string)
        @doc "The UrStoa card: the vault's claimable rewards and total STOA, plus this \
            \ account's wrapped UrStoa. \
            \ \
            \ THE VAULT ADDRESS IS A HARDCODED PRINCIPAL (URSTOA-VAULT). It is a `coin` account, \
            \ not an Ouronet entity id, so OuronetIdsV1 is the wrong home for it and \
            \ _hardcodedids.py does not match its shape. Carried over from \
            \ DPL-UR::URC_0002_PrimordialsSingle verbatim and named so it is visible."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-coin:module{stoa-ns.stoic-fungible-v1} coin)
              (ref-urcoin:module{stoa-ns.ur-stoic-fungible-v1} coin)
              (id:string (ref-DALOS::UR_UrStoaID))
              (payment-key:string (ref-DALOS::UR_AccountStoa account))
              (earnings:decimal (coin.URC_URV|ClaimableRewards payment-key))
              (vault-supply:decimal (ref-coin::UR_Balance URSTOA-VAULT)) )
            {"card-ok" : true, "id" : id
            ,"payment-key-balance" : (try 0.0 (ref-urcoin::UR_UR|Balance payment-key))
            ,"vault-balance" : (coin.UR_URV|UserSupply payment-key)
            ,"vault-earnings" : (UC_Amount earnings), "vault-earnings-hover" : earnings
            ,"vault-stoa-supply" : (UC_Amount vault-supply)
            ,"vault-stoa-supply-hover" : vault-supply
            ,"wrapped-balance" : (ref-DPTF::UR_AccountSupply id account)}
        )
    )

    (defun URC_Stoa:object (account:string)
        @doc "The STOA card: the NATIVE coin balance on the account's payment key and the \
            \ WRAPPED WSTOA balance inside Ouronet. Two different ledgers, one card -- which is \
            \ why the native read is wrapped in `try`: an account with no coin row is normal, \
            \ not an error."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-coin:module{stoa-ns.stoic-fungible-v1} coin)
              (id:string (ref-DALOS::UR_WrappedStoaID))
              (p:decimal (at 4 (URC_Prices)))
              (payment-key:string (ref-DALOS::UR_AccountStoa account))
              (native:decimal (try 0.0 (ref-coin::UR_Balance payment-key)))
              (wrapped:decimal (ref-DPTF::UR_AccountSupply id account))
              (supply:decimal (ref-DPTF::UR_Supply id)) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"native-balance" : (UC_Amount native), "native-balance-hover" : native
            ,"native-balance-vid" : (UC_Price (URC_Value id native p))
            ,"wrapped-balance" : (UC_Amount wrapped), "wrapped-balance-hover" : wrapped
            ,"wrapped-balance-vid" : (UC_Price (URC_Value id wrapped p))
            ,"wrapped-total-supply" : (UC_Amount supply)
            ,"wrapped-total-supply-hover" : supply
            ,"wrapped-total-supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URC_SilverStoa:object (account:string)
        @doc "The SSTOA card: held and global supply."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (id:string (ref-DALOS::UR_SilverStoaID))
              (p:decimal (at 5 (URC_Prices)))
              (held:decimal (ref-DPTF::UR_AccountSupply id account))
              (supply:decimal (ref-DPTF::UR_Supply id)) )
            {"card-ok" : true, "id" : id, "name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount held)  , "balance-hover" : held
            ,"balance-vid" : (UC_Price (URC_Value id held p))
            ,"supply" : (UC_Amount supply) , "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URC_GoldenStoa:object (account:string)
        @doc "The GSTOA card: liquid held, HIBERNATED held (a DPOF, counted across nonces), and \
            \ the two summed. \
            \ \
            \ GSTOA IS DERIVED THROUGH THE POOL, not DALOS::UR_GoldenStoaID, and that is \
            \ deliberate -- UR_GoldenStoaID reads BAR in the REPL fixture, so the DALOS route \
            \ leaves this card unrunnable in test. Measured 2026-09-24: \
            \ SSTOA -> KORIndex -> PSTOA -> H|PSTOA resolves in the fixture and on chain alike. \
            \ \
            \ THE NONCE COUNT IS NOT HERE. It needs DPOF::URH_AccountNonces, which is a `select`, \
            \ and a `select` cannot run inside a `try` -- see URH_GoldenStoaNonces below. Keeping \
            \ it here would make this card untriable and take the whole composer down with it."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-ATS:module{AutostakeV3} ATS)
              (idx-g:string (UC_PickId (ref-DPTF::UR_RewardToken (ref-DALOS::UR_SilverStoaID))
                                       OuronetIdsV1.IDX_GOLDENPILLAR))
              (id:string (ref-ATS::UR_ColdRewardBearingToken idx-g))
              (hid:string (ref-DPTF::UR_Hibernation id))
              (p:decimal (at 6 (URC_Prices)))
              (liquid:decimal (ref-DPTF::UR_AccountSupply id account))
              (hib:decimal (ref-DPOF::UR_AccountSupply hid account))
              (total:decimal (+ liquid hib))
              (supply:decimal (ref-DPTF::UR_Supply id)) )
            {"card-ok" : true, "id" : id, "hibernated-id" : hid
            ,"name" : (ref-DPTF::UR_Name id), "price" : (UC_Price p)
            ,"balance" : (UC_Amount liquid), "balance-hover" : liquid
            ,"balance-vid" : (UC_Price (URC_Value id liquid p))
            ,"hibernated-balance" : (UC_Amount hib), "hibernated-balance-hover" : hib
            ,"hibernated-balance-vid" : (UC_Price (URC_Value id hib p))
            ,"total-balance" : (UC_Amount total), "total-balance-hover" : total
            ,"total-balance-vid" : (UC_Price (URC_Value id total p))
            ,"supply" : (UC_Amount supply), "supply-hover" : supply
            ,"supply-vid" : (UC_Price (URC_Value id supply p))}
        )
    )

    (defun URH_GoldenStoaNonces:object (account:string)
        @doc "How many distinct nonces the account's hibernated GoldenStoa is spread across. \
            \ \
            \ SEPARATE, AND `URH_` PREFIXED, FOR A HARD REASON. This calls \
            \ DPOF::URH_AccountNonces, which is a `select` -- a full table scan. Pact evaluates \
            \ a `try` body in READ-ONLY mode, and `select` and `keys` are disallowed there. So \
            \ any card containing this could not be wrapped in `try`, and an untriable card in \
            \ the composer aborts the WHOLE object -- which is exactly the all-or-nothing \
            \ behaviour this module exists to remove. \
            \ \
            \ Measured 2026-09-24: with the scan inline, URC_01|Dashboard died on \
            \ \"Operation disallowed in read-only or sys-only mode\" at 06_DPOF.pact:1857, while \
            \ every card still passed when called individually. \
            \ \
            \ Deliberately NOT in URC_01|Dashboard. A caller that wants the count asks for it, and \
            \ pays a scan to get it."
        (let*
            ( (ref-U|CT:module{OuronetConstantsV2} U|CT)
              (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-ATS:module{AutostakeV3} ATS)
              ;;THE DERIVATION IS GUARDED, THE SELECT IS NOT, AND THAT SPLIT IS THE WHOLE POINT.
              ;;Everything needed to reach the hibernated id is plain reads, so it fits inside a
              ;;`try`; the nonce `select` that follows cannot, because `try` runs its body in
              ;;read-only mode. Guarding the half that CAN be guarded is what lets the composer
              ;;call this function outside a try without risking the whole dashboard.
              (hid:string
                (try (ref-U|CT::CT_BAR)
                     (ref-DPTF::UR_Hibernation
                       (ref-ATS::UR_ColdRewardBearingToken
                         (UC_PickId (ref-DPTF::UR_RewardToken (ref-DALOS::UR_SilverStoaID))
                                    OuronetIdsV1.IDX_GOLDENPILLAR))))) )
            (if (= hid (ref-U|CT::CT_BAR))
                {"card-ok" : false
                ,"hibernated-id" : (ref-U|CT::CT_BAR)
                ,"nonces" : 0
                ,"balance-nonces" : "--"
                ,"balance-nonces-hover" : "--"}
                (let
                    ( (hib:decimal (ref-DPOF::UR_AccountSupply hid account))
                      (n:integer (length (ref-DPOF::URH_AccountNonces account hid))) )
                    {"card-ok" : true
                    ,"hibernated-id" : hid
                    ,"nonces" : n
                    ,"balance-nonces" : (format "{} ({})" [(UC_Amount hib) n])
                    ,"balance-nonces-hover" :
                        (format "Exactly {} Hibernated GoldenStoa over {} {}"
                                [hib n (if (= 1 n) "single Nonce" "Nonces")])}
                )
            )
        )
    )

    (defun URC_Totals:object (account:string)
        @doc "Net worth, in the two forms the original produced: with OURO, and with OURO plus \
            \ the dispo credit. \
            \ \
            \ This recomputes every balance rather than summing the cards, and that is the one \
            \ place in this module where duplication is load-bearing: a total assembled from \
            \ cards would silently UNDERCOUNT whenever a card failed, reporting a smaller net \
            \ worth as though it were a real one. Recomputing means the total either is correct \
            \ or fails outright -- and a failed total is visible, where a quiet undercount is not."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-TFT:module{TrueFungibleTransferV2} TFT)
              (ref-ATS:module{AutostakeV3} ATS)
              (ref-coin:module{stoa-ns.stoic-fungible-v1} coin)
              (pp:[decimal] (URC_Prices))
              (ouro:string (ref-DALOS::UR_OuroborosID))
              (ignis:string (ref-DALOS::UR_IgnisID))
              (auryn:string (ref-DALOS::UR_AurynID))
              (eauryn:string (ref-DALOS::UR_EliteAurynID))
              (wstoa:string (ref-DALOS::UR_WrappedStoaID))
              (sstoa:string (ref-DALOS::UR_SilverStoaID))
              (gstoa:string (ref-ATS::UR_ColdRewardBearingToken
                              (UC_PickId (ref-DPTF::UR_RewardToken sstoa)
                                         OuronetIdsV1.IDX_GOLDENPILLAR)))
              (gstoa-total:decimal (+ (ref-DPTF::UR_AccountSupply gstoa account)
                                      (ref-DPOF::UR_AccountSupply
                                        (ref-DPTF::UR_Hibernation gstoa) account)))
              (core:decimal
                (fold (+) 0.0
                    [ (URC_Value ignis  (ref-DPTF::UR_AccountSupply ignis account)  (at 1 pp))
                      (URC_Value auryn  (ref-DPTF::UR_AccountSupply auryn account)  (at 2 pp))
                      (URC_Value eauryn (ref-DPTF::UR_AccountSupply eauryn account) (at 3 pp))
                      (URC_Value wstoa  (try 0.0 (ref-coin::UR_Balance
                                          (ref-DALOS::UR_AccountStoa account)))     (at 4 pp))
                      (URC_Value wstoa  (ref-DPTF::UR_AccountSupply wstoa account)  (at 4 pp))
                      (URC_Value sstoa  (ref-DPTF::UR_AccountSupply sstoa account)  (at 5 pp))
                      (URC_Value gstoa  gstoa-total                                 (at 6 pp)) ]))
              (with-ouro:decimal
                (+ core (URC_Value ouro (ref-DPTF::UR_AccountSupply ouro account) (at 0 pp))))
              (with-vouro:decimal
                (+ with-ouro
                   (URC_Value ouro (abs (ref-TFT::URC_MinimumOuro account)) (at 0 pp)))) )
            {"card-ok" : true
            ,"total-value" : (UC_Price with-ouro)
            ,"total-value-with-vouro" : (UC_Price with-vouro)}
        )
    )

    (defun URC_Codex:object (codex-accounts:[string])
        @doc "Aggregate resident IGNIS across a Codex's accounts. Takes the account LIST from \
            \ the caller -- the Codex membership lives client-side, and a read module has no \
            \ business scanning for it."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (id:string (ref-DALOS::UR_IgnisID))
              (total:decimal
                (fold (+) 0.0
                    (map (lambda (a:string) (ref-DALOS::UR_TF_AccountSupply a false))
                         codex-accounts))) )
            {"card-ok" : true
            ,"codex-balance" : (UC_Amount total)
            ,"codex-balance-hover" : total
            ,"codex-balance-vid" : (UC_Price (URC_Value id total 0.01))}
        )
    )

    ;;=======================================================================================
    ;;  CLIENT READS -- the numbered `URC_NN|Name` functions below are the ONLY ones a UI
    ;;  calls. Everything above this line is an internal component they compose.
    ;;
    ;;  ONE READ PER PAGE. A page costs one round trip, not five. The components are public
    ;;  because they are the diagnosis tool -- when a client read comes back with a zone or
    ;;  card flagged dead, you call that component directly to find out why -- but a UI that
    ;;  assembles a page from components is paying N round trips for one answer.
    ;;
    ;;  The numbering is a watchlist. These are the functions with external consumers, so
    ;;  these are the ones whose SHAPE is a contract: renaming a field here breaks an app,
    ;;  renaming one above breaks nothing. Keeping them in a numbered block at the bottom of
    ;;  the URC section means that surface is countable at a glance rather than inferred.
    ;;=======================================================================================
    (defun URC_01|Dashboard:[object] (account:string codex-accounts:[string])
        @doc "THE DASHBOARD BODY, IN ONE CALL. Returns a TWO-ELEMENT LIST -- [single, codex] -- \
            \ with exactly the keys DPL-UR::URC_0002_Primordials returned, so a consumer swaps \
            \ the module path and changes nothing else. \
            \ \
            \ THE LIST SHAPE IS THE CONTRACT, not a style choice: ouronet-core's parseResponse \
            \ reads `data[0]` for the account object and `data[1]` for the Codex balance. An \
            \ object with two members would be cleaner and would break every caller. \
            \ \
            \ ONE READ PER PAGE. The ten card functions above are internal components that \
            \ happen to be callable -- they are the diagnosis tool, not the page's assembly \
            \ kit. A UI calling ten of them pays ten round trips for one answer. \
            \ \
            \ EVERY CARD IS WRAPPED IN `try`, so a card that cannot read leaves its fields at \
            \ placeholder and flags itself in `<name>-ok`, while the rest render. The original \
            \ was a single eager `let` of ~60 bindings: one missing token row returned NOTHING \
            \ and blanked the whole wallet view. \
            \ \
            \ `hgstoa-balance-nonces` READS \"<amount> (<nonce-count>)\", and getting that right \
            \ took two attempts. The count needs DPOF::URH_AccountNonces, a `select`, and a \
            \ `select` cannot run inside a `try` -- so the first cut moved it out to \
            \ URH_GoldenStoaNonces and left this key carrying the amount ALONE, calling the loss \
            \ deliberate. It was not defensible: the key is a WIRE FORMAT the dashboard renders \
            \ verbatim, so dropping half its content is a visible regression, and no caller was \
            \ ever wired to the replacement. \"12847.2547\" where \"12847.2547 (3)\" belongs. \
            \ \
            \ The constraint was real and the conclusion was wrong. `try` forbids a select in \
            \ its BODY; it does not forbid a select in the same `let` as other try-wrapped \
            \ bindings. So URH_GoldenStoaNonces is bound here OUTSIDE any try, and it guards \
            \ its own id derivation internally -- answering card-ok false instead of throwing \
            \ -- which is what makes calling it from a composer safe. Same shape as \
            \ O-UI-NINE::URC_02|TokenEntry, which had already solved this."
        (let*
            ( (o:object (try (UDC_ZeroCard) (URC_Ouro account)))
              (i:object (try (UDC_ZeroCard) (URC_Ignis account)))
              (a:object (try (UDC_ZeroCard) (URC_Auryn account)))
              (e:object (try (UDC_ZeroCard) (URC_EliteAuryn account)))
              (u:object (try (UDC_ZeroCard) (URC_UrStoa account)))
              (w:object (try (UDC_ZeroCard) (URC_Stoa account)))
              (sv:object (try (UDC_ZeroCard) (URC_SilverStoa account)))
              (g:object (try (UDC_ZeroCard) (URC_GoldenStoa account)))
              ;;NOT in a `try` -- it holds a select, and it guards its own
              ;;derivation so it answers card-ok false rather than throwing.
              (gn:object (URH_GoldenStoaNonces account))
              (t:object (try (UDC_ZeroCard) (URC_Totals account)))
              (cx:object (try (UDC_ZeroCard) (URC_Codex codex-accounts)))
              (ko:bool (at "card-ok" o)) (ki:bool (at "card-ok" i))
              (ka:bool (at "card-ok" a)) (ke:bool (at "card-ok" e))
              (ku:bool (at "card-ok" u)) (kw:bool (at "card-ok" w))
              (ks:bool (at "card-ok" sv)) (kg:bool (at "card-ok" g))
              (kt:bool (at "card-ok" t)) (kc:bool (at "card-ok" cx))
              (d:string "--") (z:decimal 0.0) )
            [
            {"ouro-ok" : ko, "gas-ok" : ki, "auryn-ok" : ka, "eauryn-ok" : ke
            ,"urstoa-ok" : ku, "wstoa-ok" : kw, "sstoa-ok" : ks, "gstoa-ok" : kg
            ,"totals-ok" : kt
            ;;OURO
            ,"ouro-id" : (if ko (at "id" o) d), "ouro-name" : (if ko (at "name" o) d)
            ,"ouro-price" : (if ko (at "price" o) d)
            ,"ouro-balance" : (if ko (at "balance" o) d)
            ,"ouro-balance-hover" : (if ko (at "balance-hover" o) z)
            ,"ouro-balance-vid" : (if ko (at "balance-vid" o) d)
            ,"ouro-v-balance" : (if ko (at "v-balance" o) d)
            ,"ouro-v-balance-hover" : (if ko (at "v-balance-hover" o) z)
            ,"ouro-v-balance-vid" : (if ko (at "v-balance-vid" o) d)
            ,"ouro-dispo-capacity" : (if ko (at "dispo-capacity" o) d)
            ,"ouro-dispo-capacity-hover" : (if ko (at "dispo-capacity-hover" o) z)
            ,"ouro-dispo-capacity-vid" : (if ko (at "dispo-capacity-vid" o) d)
            ,"ouro-supply" : (if ko (at "supply" o) d)
            ,"ouro-supply-hover" : (if ko (at "supply-hover" o) z)
            ,"ouro-supply-vid" : (if ko (at "supply-vid" o) d)
            ;;IGNIS
            ,"gas-id" : (if ki (at "id" i) d), "gas-name" : (if ki (at "name" i) d)
            ,"gas-price" : (if ki (at "price" i) d)
            ,"gas-balance" : (if ki (at "balance" i) d)
            ,"gas-balance-hover" : (if ki (at "balance-hover" i) z)
            ,"gas-balance-vid" : (if ki (at "balance-vid" i) d)
            ,"gas-supply" : (if ki (at "supply" i) d)
            ,"gas-supply-hover" : (if ki (at "supply-hover" i) z)
            ,"gas-supply-vid" : (if ki (at "supply-vid" i) d)
            ,"gas-discount-text" : (if ki (at "ignis-discount-text" i) d)
            ,"stoa-discount-text" : (if ki (at "stoa-discount-text" i) d)
            ;;AURYN
            ,"auryn-id" : (if ka (at "id" a) d), "auryn-name" : (if ka (at "name" a) d)
            ,"auryn-price" : (if ka (at "price" a) d)
            ,"auryn-balance" : (if ka (at "balance" a) d)
            ,"auryn-balance-hover" : (if ka (at "balance-hover" a) z)
            ,"auryn-balance-vid" : (if ka (at "balance-vid" a) d)
            ,"auryn-supply" : (if ka (at "supply" a) d)
            ,"auryn-supply-hover" : (if ka (at "supply-hover" a) z)
            ,"auryn-supply-vid" : (if ka (at "supply-vid" a) d)
            ;;ELITEAURYN
            ,"eauryn-id" : (if ke (at "id" e) d), "eauryn-name" : (if ke (at "name" e) d)
            ,"eauryn-price" : (if ke (at "price" e) d)
            ,"eauryn-balance" : (if ke (at "balance" e) d)
            ,"eauryn-balance-hover" : (if ke (at "balance-hover" e) z)
            ,"eauryn-balance-vid" : (if ke (at "balance-vid" e) d)
            ,"eauryn-next" : (if ke (at "next" e) d)
            ,"eauryn-next-hover" : (if ke (at "next-hover" e) z)
            ,"eauryn-next-vid" : (if ke (at "next-vid" e) d)
            ,"eauryn-supply" : (if ke (at "supply" e) d)
            ,"eauryn-supply-hover" : (if ke (at "supply-hover" e) z)
            ,"eauryn-supply-vid" : (if ke (at "supply-vid" e) d)
            ;;UrStoa -- note `urstoa-vault-earning-hover` is singular in the original contract
            ,"urstoa-wrapped-id" : (if ku (at "id" u) d)
            ,"urstoa-payment-key-balance" : (if ku (at "payment-key-balance" u) z)
            ,"urstoa-vault-balance" : (if ku (at "vault-balance" u) z)
            ,"urstoa-vault-earnings" : (if ku (at "vault-earnings" u) d)
            ,"urstoa-vault-earning-hover" : (if ku (at "vault-earnings-hover" u) z)
            ,"urstoa-vault-stoa-supply" : (if ku (at "vault-stoa-supply" u) d)
            ,"urstoa-vault-stoa-supply-hover" : (if ku (at "vault-stoa-supply-hover" u) z)
            ,"urstoa-wrapped-balance" : (if ku (at "wrapped-balance" u) z)
            ;;STOA / WSTOA
            ,"wstoa-id" : (if kw (at "id" w) d), "wstoa-name" : (if kw (at "name" w) d)
            ,"wstoa-price" : (if kw (at "price" w) d)
            ,"wstoa-native-balance" : (if kw (at "native-balance" w) d)
            ,"wstoa-native-balance-hover" : (if kw (at "native-balance-hover" w) z)
            ,"wstoa-native-balance-vid" : (if kw (at "native-balance-vid" w) d)
            ,"wstoa-wrapped-balance" : (if kw (at "wrapped-balance" w) d)
            ,"wstoa-wrapped-balance-hover" : (if kw (at "wrapped-balance-hover" w) z)
            ,"wstoa-wrapped-balance-vid" : (if kw (at "wrapped-balance-vid" w) d)
            ,"wstoa-wrapped-total-supply" : (if kw (at "wrapped-total-supply" w) d)
            ,"wstoa-wrapped-total-supply-hover" : (if kw (at "wrapped-total-supply-hover" w) z)
            ,"wstoa-wrapped-total-supply-vid" : (if kw (at "wrapped-total-supply-vid" w) d)
            ;;SSTOA
            ,"sstoa-id" : (if ks (at "id" sv) d), "sstoa-name" : (if ks (at "name" sv) d)
            ,"sstoa-price" : (if ks (at "price" sv) d)
            ,"sstoa-balance" : (if ks (at "balance" sv) d)
            ,"sstoa-balance-hover" : (if ks (at "balance-hover" sv) z)
            ,"sstoa-balance-vid" : (if ks (at "balance-vid" sv) d)
            ,"sstoa-supply" : (if ks (at "supply" sv) d)
            ,"sstoa-supply-hover" : (if ks (at "supply-hover" sv) z)
            ,"sstoa-supply-vid" : (if ks (at "supply-vid" sv) d)
            ;;GSTOA -- hgstoa-balance-nonces carries the AMOUNT ONLY; see the @doc
            ,"gstoa-id" : (if kg (at "id" g) d), "gstoa-name" : (if kg (at "name" g) d)
            ,"hgstoa-id" : (if kg (at "hibernated-id" g) d)
            ,"gstoa-price" : (if kg (at "price" g) d)
            ,"gstoa-balance" : (if kg (at "balance" g) d)
            ,"gstoa-balance-hover" : (if kg (at "balance-hover" g) z)
            ,"gstoa-balance-vid" : (if kg (at "balance-vid" g) d)
            ,"hgstoa-balance-nonces" :
                (if (at "card-ok" gn) (at "balance-nonces" gn) (if kg (at "hibernated-balance" g) d))
            ,"hgstoa-balance-nonces-hover" :
                (if (at "card-ok" gn) (at "balance-nonces-hover" gn)
                                      (if kg (at "hibernated-balance-hover" g) z))
            ,"hgstoa-balance-nonces-vid" : (if kg (at "hibernated-balance-vid" g) d)
            ,"gstoa-total-balance" : (if kg (at "total-balance" g) d)
            ,"gstoa-total-balance-hover" : (if kg (at "total-balance-hover" g) z)
            ,"gstoa-total-balance-vid" : (if kg (at "total-balance-vid" g) d)
            ,"gstoa-supply" : (if kg (at "supply" g) d)
            ,"gstoa-supply-hover" : (if kg (at "supply-hover" g) z)
            ,"gstoa-supply-vid" : (if kg (at "supply-vid" g) d)
            ;;Totals
            ,"total-value" : (if kt (at "total-value" t) d)
            ,"total-value-with-vouro" : (if kt (at "total-value-with-vouro" t) d)
            }
            {"codex-ok" : kc
            ,"codex-balance" : (if kc (at "codex-balance" cx) d)
            ,"codex-balance-hover" : (if kc (at "codex-balance-hover" cx) z)
            ,"codex-balance-vid" : (if kc (at "codex-balance-vid" cx) d)}
            ]
        )
    )

)

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/03_O-UI-THREE.pact (module only -- its interface is already live)
(module O-UI-THREE GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiThreeV2)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-THREE             (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_THREE_ADMIN)))
    (defcap GOV|O_UI_THREE_ADMIN ()         (enforce-guard GOV|MD_O-UI-THREE))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{3}  CST
    (defconst BAR (let ((ref-U|CT:module{OuronetConstantsV2} U|CT)) (ref-U|CT::CT_BAR)))

    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroCard:object ()
        @doc "What a failing card yields from URC_01|EliteAccount; `card-ok` false."
        {"card-ok" : false}
    )

    ;;{5.2}  Compute [UC]
    (defun UC_Amount:string (amount:decimal)
        @doc "Four-decimal display form; sub-threshold reads as <0.0001."
        (let ((v:string (format "{}" [(floor amount 4)])))
            ;;AGAINST "0.0000", NOT "0.0". `(floor x 4)` always formats to four decimals, so
            ;;the string is never "0.0" and this branch was UNREACHABLE -- in every copy here,
            ;;and in DPL-UR::UC_FormatTokenAmount before them, which compared the formatted
            ;;STRING against the DECIMAL 0.0 and so could never match either. The `> 0.0` guard
            ;;keeps a genuine zero showing 0.0000: dust and nothing are different facts.
            (if (and (> amount 0.0) (= v "0.0000")) "<0.0001" v)
        )
    )
    (defun UC_Index:string (index:decimal)
        @doc "Index display form: whole part, then four 3-digit groups of the fraction."
        (let*
            ( (fis:string (format "{}" [(floor index 12)]))
              (l1:string (take -3 fis)) (l2:string (take -3 (drop -3 fis)))
              (l3:string (take -3 (drop -6 fis))) (l4:string (take -3 (drop -9 fis)))
              (whole:string (drop -13 fis)) )
            (concat [whole ",[" l4 "." l3 "." l2 "." l1 "]"])
        )
    )
    (defun UC_MaxSpecialFeeTargets:integer (major:integer)
        @doc "How many SWP special-fee targets an Elite major tier permits. \
            \ \
            \ A DELIBERATE COPY of O-UI-TWELVE's function -- see the module header. Written as \
            \ an explicit comparison rather than an `or`-fold so there is no seed to get wrong, \
            \ which is precisely how DPL-UR's two copies came to disagree. RDUI-09 pins this \
            \ against O-UI-TWELVE's for every tier, so a divergence fails the gate rather than \
            \ waiting to be noticed by a user who was shown 7 where the rule says 1."
        (cond
            ((= major 2) 2)
            ((= major 3) 3)
            ((= major 4) 4)
            ((>= major 5) 7)
            1
        )
    )

    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_Standing:object (account:string)
        @doc "Class, name, tier and DEB -- the account's Elite identity."
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS))
            {"card-ok" : true
            ,"elite-class" : (ref-DALOS::UR_Elite-Class account)
            ,"elite-name" : (ref-DALOS::UR_Elite-Name account)
            ,"elite-tier" : (ref-DALOS::UR_Elite-Tier account)
            ,"elite-tier-major" : (ref-DALOS::UR_Elite-Tier-Major account)
            ,"elite-tier-minor" : (ref-DALOS::UR_Elite-Tier-Minor account)
            ,"elite-deb" : (ref-DALOS::UR_Elite-DEB account)}
        )
    )

    (defun URC_Variants:object (account:string)
        @doc "Every Elite-Auryn variant the account holds, and what the next tier costs. \
            \ \
            \ Six variants: native, Frozen, Reservation, Vesting, Sleeping, Hibernation. The \
            \ first three are DPTF balances, the last three DPOF -- which is why they are read \
            \ through different modules. Each id is guarded against BAR: a variant that has \
            \ never been linked reads as absent rather than throwing, which is the difference \
            \ between a card that renders six rows and a card that renders none."
        (let*
            ( (ref-U|CT:module{OuronetConstantsV2} U|CT)
              (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-ELITE:module{EliteV2} ELITE)
              (ea:string (ref-DALOS::UR_EliteAurynID))
              (fea:string (if (!= ea BAR) (ref-DPTF::UR_Frozen ea) BAR))
              (rea:string (if (!= ea BAR) (ref-DPTF::UR_Reservation ea) BAR))
              (vea:string (if (!= ea BAR) (ref-DPTF::UR_Vesting ea) BAR))
              (sea:string (if (!= ea BAR) (ref-DPTF::UR_Sleeping ea) BAR))
              (hea:string (if (!= ea BAR) (ref-DPTF::UR_Hibernation ea) BAR))
              (eas:decimal (if (!= ea BAR) (ref-DPTF::UR_AccountSupply ea account) 0.0))
              (feas:decimal (if (!= fea BAR) (ref-DPTF::UR_AccountSupply fea account) 0.0))
              (reas:decimal (if (!= rea BAR) (ref-DPTF::UR_AccountSupply rea account) 0.0))
              (veas:decimal (if (!= vea BAR) (ref-DPOF::UR_AccountSupply vea account) 0.0))
              (seas:decimal (if (!= sea BAR) (ref-DPOF::UR_AccountSupply sea account) 0.0))
              (heas:decimal (if (!= hea BAR) (ref-DPOF::UR_AccountSupply hea account) 0.0))
              (total:decimal (ref-ELITE::URC_EliteAurynzSupply account))
              (et:[decimal] (ref-U|CT::CT_ET))
              (et-last:decimal (at (- (length et) 1) et))
              (next:decimal
                (if (>= total et-last)
                    0.0
                    (- (fold (lambda (acc:decimal tier:decimal)
                                (if (and (> tier total) (< tier acc)) tier acc))
                             et-last et)
                       total))) )
            {"card-ok" : true
            ,"ea-id" : ea,   "ea-supply" : (UC_Amount eas),   "ea-supply-hover" : eas
            ,"fea-id" : fea, "fea-supply" : (UC_Amount feas), "fea-supply-hover" : feas
            ,"rea-id" : rea, "rea-supply" : (UC_Amount reas), "rea-supply-hover" : reas
            ,"vea-id" : vea, "vea-supply" : (UC_Amount veas), "vea-supply-hover" : veas
            ,"sea-id" : sea, "sea-supply" : (UC_Amount seas), "sea-supply-hover" : seas
            ,"hea-id" : hea, "hea-supply" : (UC_Amount heas), "hea-supply-hover" : heas
            ,"total-elite-aurynz" : (UC_Amount total)
            ,"total-elite-aurynz-hover" : total
            ,"elite-aurynz-for-next-tier" : (UC_Amount next)
            ,"elite-aurynz-for-next-tier-hover" : next}
        )
    )

    (defun URC_Indices:object ()
        @doc "Auryndex and EliteAuryndex, which feed the dispo arithmetic. \
            \ \
            \ Resolved through UR_RewardToken on OURO and AURYN -- the pool that REWARDS each \
            \ token. Account-independent, so this card is identical for every caller and is the \
            \ one here worth caching across users."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-ATS:module{AutostakeV3} ATS)
              (a:string (at 0 (ref-DPTF::UR_RewardToken (ref-DALOS::UR_OuroborosID))))
              (e:string (at 0 (ref-DPTF::UR_RewardToken (ref-DALOS::UR_AurynID))))
              (av:decimal (ref-ATS::URC_Index a))
              (ev:decimal (ref-ATS::URC_Index e)) )
            {"card-ok" : true
            ,"auryndex-id" : a, "auryndex-name" : (ref-ATS::UR_IndexName a)
            ,"auryndex-value" : (UC_Index av), "auryndex-value-hover" : av
            ,"elite-auryndex-id" : e, "elite-auryndex-name" : (ref-ATS::UR_IndexName e)
            ,"elite-auryndex-value" : (UC_Index ev), "elite-auryndex-value-hover" : ev}
        )
    )

    (defun URC_Dispo:object (account:string)
        @doc "The OURO dispo credit: how far the account may overspend against its native \
            \ Elite-Auryn, and whether that credit is currently locked. \
            \ \
            \ `elite-auryn-dispo-locked` is TRUE when the OURO balance is NEGATIVE -- the \
            \ account has already spent into its credit, and native Elite-Auryn cannot move \
            \ until it is back at zero. A negative OURO balance is normal here, not an error."
        (let*
            ( (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
              (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-TFT:module{TrueFungibleTransferV2} TFT)
              (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
              (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
              (ouro:string (ref-DALOS::UR_OuroborosID))
              (bal:decimal (ref-DPTF::UR_AccountSupply ouro account))
              (cap:decimal (ref-U|DPTF::UC_OuroDispo (ref-TFT::UDC_GetDispoData account)))
              (minimum:decimal (ref-TFT::URC_MinimumOuro account))
              (virtual:decimal (ref-TFT::URC_VirtualOuro account))
              (locked:bool (< bal 0.0))
              (pct:decimal
                (if (< (dec major) 3.0)
                    0.0
                    (floor (+ (/ (- (+ (* (- (dec major) 1.0) 7.0) (dec minor)) 15.0) 10.0) 11.5)
                           1))) )
            {"card-ok" : true
            ,"dispo-overspend-percent" : pct
            ,"dispo-overspend-text" :
                (format "{}% of native Elite-Auryn OURO-value may be overspent (requires Major Tier ≥ 3)"
                        [pct])
            ,"ouro-id" : ouro
            ,"ouro-balance" : (UC_Amount bal), "ouro-balance-hover" : bal
            ,"ouro-dispo-capacity" : (UC_Amount cap), "ouro-dispo-capacity-hover" : cap
            ,"ouro-minimum" : (UC_Amount minimum), "ouro-minimum-hover" : minimum
            ,"ouro-virtual" : (UC_Amount virtual), "ouro-virtual-hover" : virtual
            ,"elite-auryn-dispo-locked" : locked
            ,"elite-auryn-dispo-locked-text" :
                (if locked
                    "Native Elite-Auryn is dispo-locked until OURO balance returns to ≥ 0"
                    "Native Elite-Auryn is transferable (OURO not negative)")}
        )
    )

    (defun URC_Discounts:object (account:string)
        @doc "IGNIS, STOA and DEX fee discounts. \
            \ \
            \ Two numbers per discount and they are NOT the same thing: the MULTIPLIER is what \
            \ the account pays (1.0 = full price), the PERCENT is what it saves. Reporting only \
            \ one invites a UI showing 'discount 0.85' where it means 15%. \
            \ \
            \ DEX fees intentionally reuse the IGNIS curve -- SWPI::URC_EliteFeeReduction applies \
            \ the non-native gas discount to LP/special/boost fees -- so the two are equal by \
            \ construction rather than by coincidence."
        (let*
            ( (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
              (ref-DALOS:module{OuronetDalosV2} DALOS)
              (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
              (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
              (im:decimal (ref-DALOS::URC_IgnisGasDiscount account))
              (sm:decimal (ref-DALOS::URC_StoaGasDiscount account))
              (ip:decimal (ref-U|DALOS::UC_GasDiscount major minor false))
              (sp:decimal (ref-U|DALOS::UC_GasDiscount major minor true)) )
            {"card-ok" : true
            ,"ignis-cost-multiplier" : im, "ignis-discount-percent" : ip
            ,"ignis-discount-text" :
                (format "IGNIS Discount {}% (You pay only {}% of IGNIS costs)" [ip (* im 100.0)])
            ,"stoa-cost-multiplier" : sm, "stoa-discount-percent" : sp
            ,"stoa-discount-text" :
                (format "STOA Discount {}% (You pay only {}% of STOA costs)" [sp (* sm 100.0)])
            ,"dex-fee-cost-multiplier" : im, "dex-fee-discount-percent" : ip
            ,"dex-fee-discount-text" :
                (format "DEX Fee Discount {}% (LP/Special/Boost fees; same curve as IGNIS)" [ip])}
        )
    )

    (defun URC_Unlocks:object (account:string)
        @doc "What the account's tier unlocks elsewhere: SWP special-fee targets, branding \
            \ months, and Elite-ATS cold-recovery positions."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-BRD:module{BrandingV2} BRD)
              (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
              (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
              (deb:decimal (ref-DALOS::UR_Elite-DEB account)) )
            {"card-ok" : true
            ,"deb-bonus-text" :
                (format "DEB ×{} on AQP scores when deb-boost is enabled" [deb])
            ,"max-swp-special-fee-targets" : (UC_MaxSpecialFeeTargets major)
            ,"max-branding-blue-months" : (ref-BRD::URC_MaxBluePayment account)
            ,"elite-ats-cold-recovery-positions" : (if (= major 0) 1 major)
            ,"elite-ats-cold-recovery-duration-index" :
                (if (= major 0) 0 (+ (* (- major 1) 7) minor))}
        )
    )

    ;;=======================================================================================
    ;;  CLIENT READS -- the only two a UI calls. Everything above is an internal component.
    ;;=======================================================================================

    (defun URC_01|EliteAccount:object (account:string)
        @doc "THE ELITE PANEL, IN ONE CALL. Flat, with exactly the keys \
            \ DPL-UR::URC_0032_EliteAccount returned, so a consumer swaps the module path and \
            \ changes nothing else. \
            \ \
            \ Six cards under `try`: a card that cannot read flags itself in `<name>-ok` and \
            \ leaves its fields at placeholder, while the rest render. \
            \ \
            \ THE RICH LIST IS NOT IN HERE. It scans, a scan cannot live inside a `try`, and \
            \ folding it in would make this panel abort wholesale on the heaviest read in the \
            \ app. Call URH_02|RichList separately -- in parallel, it costs no extra latency."
        (let*
            ( (st:object (try (UDC_ZeroCard) (URC_Standing account)))
              (v:object (try (UDC_ZeroCard) (URC_Variants account)))
              (ix:object (try (UDC_ZeroCard) (URC_Indices)))
              (dp:object (try (UDC_ZeroCard) (URC_Dispo account)))
              (dc:object (try (UDC_ZeroCard) (URC_Discounts account)))
              (un:object (try (UDC_ZeroCard) (URC_Unlocks account))) )
            (+ {"account" : account
               ,"standing-ok" : (at "card-ok" st), "variants-ok" : (at "card-ok" v)
               ,"indices-ok" : (at "card-ok" ix),  "dispo-ok" : (at "card-ok" dp)
               ,"discounts-ok" : (at "card-ok" dc),"unlocks-ok" : (at "card-ok" un)}
               (+ (remove "card-ok" st)
                  (+ (remove "card-ok" v)
                     (+ (remove "card-ok" ix)
                        (+ (remove "card-ok" dp)
                           (+ (remove "card-ok" dc) (remove "card-ok" un)))))))
        )
    )

    (defun URH_02|RichList:[object] ()
        @doc "Every Standard Ouronet account ranked by total Elite-Auryn, highest first. \
            \ \
            \ `URH_` AND STANDALONE, both forced. It runs `(keys DALOS.DALOS|AccountTable)` -- a \
            \ CROSS-MODULE scan, which Pact admin-gates in transactional mode and a node permits \
            \ in `/local` only with `--allowReadsInLocal`. It therefore cannot sit inside a \
            \ `try`, and so cannot join URC_01|EliteAccount's composer. \
            \ \
            \ IT IS ALSO THE HEAVIEST READ IN THE APPLICATION and grows worse than linearly: it \
            \ walks every account, then INSERTION-SORTS the result, which is O(n^2) in accounts \
            \ under a 10,000,000 gas /local ceiling. At ~195 accounts that is comfortable. It \
            \ will not always be. When it stops fitting the answer is pagination in the caller, \
            \ not a bigger ceiling -- and the time to notice is before a page depends on it \
            \ loading synchronously."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-CODEX:module{CodexV2} CODEX)
              (ouro:string (ref-DALOS::UR_OuroborosID))
              (ea:string (ref-DALOS::UR_EliteAurynID))
              (fea:string (if (!= ea BAR) (ref-DPTF::UR_Frozen ea) BAR))
              (rea:string (if (!= ea BAR) (ref-DPTF::UR_Reservation ea) BAR))
              (vea:string (if (!= ea BAR) (ref-DPTF::UR_Vesting ea) BAR))
              (sea:string (if (!= ea BAR) (ref-DPTF::UR_Sleeping ea) BAR))
              (hea:string (if (!= ea BAR) (ref-DPTF::UR_Hibernation ea) BAR))
              (standard:[string]
                (filter (lambda (a:string) (not (ref-DALOS::UR_AccountType a)))
                        (keys DALOS.DALOS|AccountTable)))
              (rows:[object]
                (map (lambda (a:string)
                    (let*
                        ( (ob:decimal (if (!= ouro BAR) (ref-DPTF::UR_AccountSupply ouro a) 0.0))
                          (s1:decimal (if (!= ea BAR) (ref-DPTF::UR_AccountSupply ea a) 0.0))
                          (s2:decimal (if (!= fea BAR) (ref-DPTF::UR_AccountSupply fea a) 0.0))
                          (s3:decimal (if (!= rea BAR) (ref-DPTF::UR_AccountSupply rea a) 0.0))
                          (s4:decimal (if (!= vea BAR) (ref-DPOF::UR_AccountSupply vea a) 0.0))
                          (s5:decimal (if (!= sea BAR) (ref-DPOF::UR_AccountSupply sea a) 0.0))
                          (s6:decimal (if (!= hea BAR) (ref-DPOF::UR_AccountSupply hea a) 0.0))
                          (tot:decimal (fold (+) 0.0 [s1 s2 s3 s4 s5 s6]))
                          (locked:bool (< ob 0.0))
                          (stba:object (ref-CODEX::UR_STBA|DataOrNull a)) )
                        {"account" : a
                        ,"stoic-tag" : (if (at "has-stoictag" stba) (at "tag-name" stba) BAR)
                        ,"elite-class" : (ref-DALOS::UR_Elite-Class a)
                        ,"elite-name" : (ref-DALOS::UR_Elite-Name a)
                        ,"elite-tier" : (ref-DALOS::UR_Elite-Tier a)
                        ,"ouro-balance" : ob
                        ,"elite-auryn-dispo-locked" : locked
                        ,"ea-id" : ea, "ea-supply" : s1
                        ,"ea-movable" : (if locked 0.0 s1)
                        ,"fea-id" : fea, "fea-supply" : s2
                        ,"rea-id" : rea, "rea-supply" : s3
                        ,"vea-id" : vea, "vea-supply" : s4
                        ,"sea-id" : sea, "sea-supply" : s5
                        ,"hea-id" : hea, "hea-supply" : s6
                        ,"total-elite-aurynz" : tot}))
                    standard)) )
            ;;Insertion sort, descending. O(n^2) and named as such in the @doc rather than
            ;;hidden -- a reader deciding whether to call this deserves to know.
            (fold (lambda (sorted:[object] row:object)
                    (let ( (t:decimal (at "total-elite-aurynz" row)) )
                        (+ (filter (lambda (x:object) (> (at "total-elite-aurynz" x) t)) sorted)
                           (+ [row]
                              (filter (lambda (x:object) (<= (at "total-elite-aurynz" x) t))
                                      sorted)))))
                  [] rows)
        )
    )
    (defun URC_PosObjSt:integer (atspair:string input-obj:object{UtilityAtsV3.Awo})
        @doc "Classifies one uncoil position: 1 = OPEN, 0 = OCCUPIED, -1 = CLOSED. \
            \ \
            \ The three states are told apart by comparing the stored object against two \
            \ sentinel objects the pool itself constructs, because an uncoil position has no \
            \ status field -- its state IS its shape. Anything matching neither sentinel holds \
            \ a real pending uncoil and is therefore occupied. \
            \ \
            \ Replaces DPL-UR::URC_0012b_PosObjSt."
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (if (= input-obj (ref-ATS::UDC_MakeZeroUnstakeObject atspair))
                1
                (if (= input-obj (ref-ATS::UDC_MakeNegativeUnstakeObject atspair)) -1 0)
            )
        )
    )
    (defun URC_03|Recovery:object (ats:string account:string)
        @doc "THE RECOVERY PANEL: which recovery modes the pool allows, what is currently \
            \ cullable, and the state of all seven uncoil positions. \
            \ \
            \ EVERY POSITION READ IS `try`-GUARDED WITH A COMPUTED DEFAULT, and the defaults \
            \ are the interesting part. An account that has never used position N has no row \
            \ there, and `read` throws -- but the ABSENCE means different things in the two \
            \ pool modes. In a non-elite pool a position exists if the pool declares that many; \
            \ in an elite pool it exists if the account's own major tier reaches it. So the \
            \ default is ZERO (open) when the position should exist and NEGATIVE (closed) when \
            \ it should not, which is how an unused-but-available slot is told from one the \
            \ account has not earned. Collapsing these to a single default would offer users \
            \ positions they cannot use. \
            \ \
            \ Replaces DPL-UR::URC_0012_RecoveryPrimordial, key-for-key. \
            \ \
            \ CARRIED THROUGH UNCHANGED, AND SUSPECT: `iz-button` ends in \
            \ `(>= total-to-cull 0.0)`, and total-to-cull is a sum of cull amounts that are \
            \ never negative -- so that disjunct is ALWAYS TRUE and iz-button can never be \
            \ false. The likely intent is `>`. Not changed here: it governs whether a button \
            \ appears, and turning one off is the owner's call, not a porting decision."
        (let
            (
                (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-ATSU:module{AutostakeUsageV2} ATSU)
                ;;
                (toggle-cold:bool (ref-ATS::UR_ToggleColdRecovery ats))
                (toggle-hot:bool (ref-ATS::UR_ToggleHotRecovery ats))
                (toggle-direct:bool (ref-ATS::UR_ToggleDirectRecovery ats))
                ;;
                (rts:[string] (ref-ATS::UR_RewardTokenList ats))
                (cold-positions:integer (ref-ATS::UR_ColdRecoveryPositions ats))
                (iz-elite:bool (ref-ATS::UR_EliteMode ats))
                (major-tier:integer (ref-DALOS::UR_Elite-Tier-Major account))
                ;;
                (free-positions-data:[object{UtilityAtsV3.Awo}]
                    (try [] (ref-ATS::UR_P0 ats account)))
                ;;
                (zr:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeZeroUnstakeObject ats))
                (ng:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeNegativeUnstakeObject ats))
            )
            (let
                (
                    (iz-free-or-seven:bool (= cold-positions -1))
                    (zl:[decimal] (make-list (length rts) 0.0))
                    ;;The default for position N: open when the account should have it,
                    ;;closed when it should not. See the @doc.
                    (dflt:[object{UtilityAtsV3.Awo}]
                        (map
                            (lambda (n:integer)
                                (if iz-elite
                                    (if (> major-tier (- n 1)) zr ng)
                                    (if (<= n cold-positions) zr ng)
                                )
                            )
                            [1 2 3 4 5 6 7]
                        )
                    )
                )
                (let
                    (
                        (cull-values:[decimal]
                            (if iz-free-or-seven
                                (let
                                    (
                                        (mc (try (make-list
                                                     (length (ref-ATS::UR_RewardTokens ats))
                                                     0.0)
                                                 (ref-ATSU::URC_MultiCull ats account)))
                                    )
                                    (if (= (typeof mc) "list")
                                        mc
                                        (at "summed-culled-values" mc))
                                )
                                (ref-U|DEC::UC_AddHybridArray
                                    (map
                                        (lambda (i:integer)
                                            (try zl (ref-ATSU::URC_SingleCull ats account i)))
                                        (enumerate 1 cold-positions)
                                    )
                                )
                            )
                        )
                        ;;POSITION 1 IS ALWAYS OPEN BY DEFAULT -- every account has a first
                        ;;position regardless of tier, so it does not take the computed default.
                        (pobj:[object{UtilityAtsV3.Awo}]
                            (map
                                (lambda (n:integer)
                                    (try (if (= n 1) zr (at (- n 1) dflt))
                                         (ref-ATS::UR_P1-7 ats account n)))
                                [1 2 3 4 5 6 7]
                            )
                        )
                    )
                    {"iz-button"                : (or (fold (or) false
                                                        [toggle-cold toggle-hot toggle-direct])
                                                      (>= (fold (+) 0.0 cull-values) 0.0))
                    ,"toggle-cold"              : toggle-cold
                    ,"toggle-hot"               : toggle-hot
                    ,"toggle-direct"            : toggle-direct
                    ;;
                    ,"c-rbt"                    : (ref-ATS::UR_ColdRewardBearingToken ats)
                    ,"rts"                      : rts
                    ,"free-position-data"       : free-positions-data
                    ;;
                    ,"iz-free-or-seven"         : iz-free-or-seven
                    ,"cull-values"              : cull-values
                    ,"how-many-free-positions"  : (length free-positions-data)
                    ,"elite"                    : iz-elite
                    ;;
                    ,"p1-obj"                   : (at 0 pobj)
                    ,"p2-obj"                   : (at 1 pobj)
                    ,"p3-obj"                   : (at 2 pobj)
                    ,"p4-obj"                   : (at 3 pobj)
                    ,"p5-obj"                   : (at 4 pobj)
                    ,"p6-obj"                   : (at 5 pobj)
                    ,"p7-obj"                   : (at 6 pobj)
                    ;;
                    ,"pos1-type"                : (URC_PosObjSt ats (at 0 pobj))
                    ,"pos2-type"                : (URC_PosObjSt ats (at 1 pobj))
                    ,"pos3-type"                : (URC_PosObjSt ats (at 2 pobj))
                    ,"pos4-type"                : (URC_PosObjSt ats (at 3 pobj))
                    ,"pos5-type"                : (URC_PosObjSt ats (at 4 pobj))
                    ,"pos6-type"                : (URC_PosObjSt ats (at 5 pobj))
                    ,"pos7-type"                : (URC_PosObjSt ats (at 6 pobj))
                    }
                )
            )
        )
    )
    (defun URC_04|MaxRecovery:decimal (ats:string recoverer:string)
        @doc "Elite Auryn only: the largest amount that may be cold-recovered right now. \
            \ Zero for any pool that is not an elite Elite-Auryn pool. \
            \ \
            \ THE RULE: recovering opens a position, so if n of your positions are already \
            \ occupied you must hold tier n+1 to have one free. The tier threshold for n+1 is \
            \ the balance that must REMAIN, and the recoverable amount is whatever sits above \
            \ it. Above tier 7 there is no next tier, so the answer is zero. \
            \ \
            \ Replaces DPL-UR::URC_MaxRecoveryAmount."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
            )
            (if (and (ref-ATS::UR_EliteMode ats) (= c-rbt (ref-DALOS::UR_EliteAurynID)))
                (let
                    (
                        (met:integer (ref-DALOS::UR_Elite-Tier-Major recoverer))
                        (pstate:[integer] (ref-ATS::URCx_PSL ats recoverer))
                    )
                    (let
                        (
                            (required-tier:integer
                                (+ 1 (length (filter (lambda (st:integer) (= st 0))
                                                    (take met pstate)))))
                        )
                        (if (> required-tier 7)
                            0.0
                            (let
                                (
                                    (candidate:decimal
                                        (- (ref-DPTF::UR_AccountSupply c-rbt recoverer)
                                           (at (+ (* (- required-tier 1) 7) 1)
                                               (ref-U|CT::CT_ET))))
                                )
                                (if (< candidate 0.0) 0.0 candidate)
                            )
                        )
                    )
                )
                0.0
            )
        )
    )
)

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/12_O-UI-TWELVE.pact (module only -- its interface is already live)
(module O-UI-TWELVE GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiTwelveV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-TWELVE               (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_TWELVE_ADMIN)))
    (defcap GOV|O_UI_TWELVE_ADMIN ()           (enforce-guard GOV|MD_O-UI-TWELVE))
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
            ;;AGAINST "0.0000", NOT "0.0". `(floor x 4)` always formats to four decimals, so
            ;;the string is never "0.0" and this branch was UNREACHABLE -- in every copy here,
            ;;and in DPL-UR::UC_FormatTokenAmount before them, which compared the formatted
            ;;STRING against the DECIMAL 0.0 and so could never match either. The `> 0.0` guard
            ;;keeps a genuine zero showing 0.0000: dust and nothing are different facts.
            (if (and (> amount 0.0) (= v "0.0000")) "<0.0001" v)
        )
    )
    (defun UC_Price:string (input-price:decimal)
        @doc "Dollar/cent display form with a floor below which a price reads as <0.001¢."
        (if (< input-price 0.00001)
            "<0.001¢"
            (if (< input-price 1.00)
                (format "{}¢" [(floor (* input-price 100.0) 3)])
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
            \ wrong. O-UI-THREE (EliteAccount) must call THIS when URC_0032 is ported -- a third copy is how the \
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

    (defun URC_01|Global:object ()
        @doc "Chain-wide swap state and the list of every pool. \
            \ \
            \ URC_Swpairs is safe inside a `try` -- its own doc says it is cheaper than \
            \ `keys SWP|Pairs`, i.e. an index read rather than a scan. That distinction is the \
            \ one that matters for composability; see ../RULES.md rule 5."
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

    (defun URC_02|PoolList:[object] (swpairs:[string])
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

    (defun URC_04|AccountSupplies:object (account:string swpair:string)
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

    (defun URC_03|Pool:object (swpair:string)
        @doc "Every per-pool panel in one call, each under `try`. A failing panel yields \
            \ UDC_ZeroPanel and the rest still render. \
            \ \
            \ Deliberately NOT including URC_04|AccountSupplies -- that one takes an account and \
            \ is therefore a different question. Mixing a per-account read into a per-pool \
            \ composer would make the whole object account-scoped and uncacheable across users."
        {"core"     : (try (UDC_ZeroPanel) (URC_PoolCore swpair))
        ,"dashboard": (try (UDC_ZeroPanel) (URC_PoolDashboard swpair))
        ,"internal" : (try (UDC_ZeroPanel) (URC_PoolInternal swpair))
        ,"settings" : (try (UDC_ZeroPanel) (URC_PoolSettings swpair))
        ,"fees"     : (try (UDC_ZeroPanel) (URC_FeeSettings swpair))}
    )

    ;;=======================================================================================
    ;;  SWAP PREVIEWS -- THE CARVE-OUT. Everything above this line is display and degrades
    ;;  under `try`. These three do not, and must not.
    ;;
    ;;  They produce the number a user reads IMMEDIATELY BEFORE SIGNING A TRADE. A wrong panel
    ;;  above is a cosmetic bug someone reports; a wrong preview here is a user consenting to
    ;;  something other than what they saw. The money moves either way -- only the consent was
    ;;  wrong.
    ;;
    ;;  So: no composer, no try-wrapping, and arithmetic assertions are mandatory (RDUI-08 --
    ;;  round trip, curvature, refusal). A token absent from the pool must REFUSE, because a
    ;;  swallowed refusal reads to a user as a valid quote of zero.
    ;;
    ;;  Independent of the open CC_ vs C_ SmartSwap ruling: both take an explicit swpair and
    ;;  preview ONE pool. A multi-hop preview is deliberately absent until that is decided.
    ;;=======================================================================================
    (defun URCv_05|DirectSwap:decimal
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

    (defun URCv_06|InverseSwap:decimal
        (account:string swpair:string output-id:string output-amount:decimal input-id:string)
        @doc "INVERSE preview: how much <input-id> must go in, gross of fees, to receive exactly \
            \ <output-amount> of <output-id>. The figure shown beside \"You pay\" when a user \
            \ types the amount they WANT rather than the amount they have. \
            \ \
            \ Brutto, not netto: this is what leaves the wallet, fees included. Pairing it \
            \ against URCv_05|DirectSwap's netto in a UI without reading both docs is how a \
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

    (defun URC_07|MaxOutputAmount:decimal (swpair:string output-id:string promille:decimal)
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


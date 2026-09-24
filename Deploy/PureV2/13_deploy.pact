;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 13
;; O-UI-ONE + O-UI-THREE (module UPGRADES)  --  five glyphs flattened to ASCII
;; =========================================================================================
;; NO NEW INTERFACES. Both are already deployed and may not be redeployed; module bodies only.
;;
;; WHAT IS WRONG ON MAINNET RIGHT NOW. Porting DPL-UR's reads transcribed five user-facing
;; strings with their Unicode flattened to ASCII. Measured by calling both modules on chain and
;; diffing the objects field by field:
;;
;;   O-UI-ONE   z1-t2              "Total Xi-A"          should be  "Total Ξ₳"
;;   O-UI-ONE   z1-t3              "Xi-A for Next Tier"  should be  "Ξ₳ for Next Tier"
;;   O-UI-THREE deb-bonus-text     "DEB x4.50 ..."       should be  "DEB ×4.50 ..."
;;   O-UI-THREE dispo-overspend    "... Major Tier >= 3" should be  "... Major Tier ≥ 3"
;;   O-UI-THREE dispo-locked-text  "... returns to >= 0" should be  "... returns to ≥ 0"
;;
;; `Ξ₳` is the ELITE-AURYN SYMBOL. "Total Xi-A" is not a subtle rendering difference, it is the
;; wrong words in the header. The others are a multiplication sign and two greater-or-equal
;; signs, spelled out.
;;
;; THIS IS THE SECOND FIX OF THE SAME KIND -- PureV2/06 restored the CENT SIGN to the price
;; formatters. Four distinct glyphs lost across four modules, every one of them rendering
;; plausibly, two of them already shipped. No test caught any of it, and no test could have:
;; a test written from the port agrees with the port. They were found by calling the old and
;; the new function on MAINNET and comparing the returned objects key by key.
;;
;; SO THE CLASS IS NOW CLOSED MECHANICALLY. `REPL/tools/_glyphparity.py` takes DPL-UR as the
;; reference, extracts every non-ASCII literal it can EMIT (`@doc` prose excluded), and requires
;; each to appear byte-identically in some AppReads module. Anything deliberately dropped goes
;; in its RETIRED registry with a reason, because "absent because we meant it" and "absent
;; because someone retyped it" are indistinguishable otherwise. Fatal inside the gate.
;;
;; NO BEHAVIOUR CHANGES. Five string literals, nothing else. Deploy order is free.
;;
;; SIGNING -- namespace keyset AND the Demiurgoi keyset. A module UPGRADE runs the module's own
;; governance capability: GOV|O_UI_ONE_ADMIN and GOV|O_UI_THREE_ADMIN, both
;; keyset-ref-guard(GOV|Demiurgoi).
;;
;; MEASURED in the REPL fixture: upgrade 26,781 + 42,903 gas (unchanged -- only literals moved).
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
            (if (= v "0.0") "<0.0001" v)
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


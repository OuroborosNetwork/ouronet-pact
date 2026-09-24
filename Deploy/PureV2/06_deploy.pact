;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 6
;; O-UI-ONE + O-UI-TWO (module UPGRADES)  --  one-character fix to a live display bug
;; =========================================================================================
;; NO NEW INTERFACES. Both interfaces are already deployed and MAY NOT be redeployed; this file
;; ships module bodies only, which upgrade freely.
;;
;; WHAT IS WRONG ON MAINNET RIGHT NOW. Both modules carry a private copy of DPL-UR's price
;; formatter, and both copies were transcribed with an ASCII `c` where the original has the
;; CENT SIGN `¢` (U+00A2). So every price on the header and the dashboard currently renders
;;
;;     0.253c      instead of      0.253¢
;;     <0.001c     instead of      <0.001¢
;;
;; It is cosmetic and it is still a wire format: the string is what the user reads, and a
;; consumer that ever matches on the suffix would silently stop matching. It was found by
;; diffing the port's output against DPL-UR's field by field, which is the only reason it was
;; found at all -- both values render, and neither looks obviously wrong on its own.
;;
;; THIS IS WHY `REPL/tools/_purev2.py` NOW EXISTS. The defect entered through a hand-copied
;; deploy file, and nothing compared a deploy file to the module it claims to deploy. From
;; this file onward the body below the marker is GENERATED from the module source and diffed
;; by the gate.
;;
;; DEPLOY ORDER IS FREE -- the two modules do not reference each other.
;;
;; SIGNING -- namespace keyset AND the Demiurgoi keyset. A module UPGRADE runs the module's governance
;; capability: GOV|O_UI_ONE_ADMIN and GOV|O_UI_TWO_ADMIN, both keyset-ref-guard(GOV|Demiurgoi).
;;
;; MEASURED in the REPL fixture (Stage 1 + Stage 2, nothing else from this round):
;;   upgrade 26,781 + 45,143 gas (unchanged -- the fix is one character)
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
            ,"z1-t2" : "Total Xi-A"
            ,"z1-v2" : (if k1 (at "total-aurynz" z1) dash)
            ,"z1-t3" : "Xi-A for Next Tier"
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
            (if (= v "0.0") "<0.0001" v)
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
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-ATS:module{AutostakeV3} ATS)
              (id:string (ref-ATS::UR_ColdRewardBearingToken
                           (UC_PickId (ref-DPTF::UR_RewardToken (ref-DALOS::UR_SilverStoaID))
                                      OuronetIdsV1.IDX_GOLDENPILLAR)))
              (hid:string (ref-DPTF::UR_Hibernation id))
              (hib:decimal (ref-DPOF::UR_AccountSupply hid account))
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
            \ ONE FIELD LOSES DATA, deliberately. `hgstoa-balance-nonces` used to read \
            \ \"<amount> (<nonce-count>)\". The count needs DPOF::URH_AccountNonces, a `select`, \
            \ and a `select` cannot run inside a `try` -- keeping it would make this composer \
            \ abort wholesale rather than degrade. It now carries the amount alone; a caller \
            \ wanting the count asks URH_GoldenStoaNonces, which is exactly why that function \
            \ is public."
        (let*
            ( (o:object (try (UDC_ZeroCard) (URC_Ouro account)))
              (i:object (try (UDC_ZeroCard) (URC_Ignis account)))
              (a:object (try (UDC_ZeroCard) (URC_Auryn account)))
              (e:object (try (UDC_ZeroCard) (URC_EliteAuryn account)))
              (u:object (try (UDC_ZeroCard) (URC_UrStoa account)))
              (w:object (try (UDC_ZeroCard) (URC_Stoa account)))
              (sv:object (try (UDC_ZeroCard) (URC_SilverStoa account)))
              (g:object (try (UDC_ZeroCard) (URC_GoldenStoa account)))
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
            ,"hgstoa-balance-nonces" : (if kg (at "hibernated-balance" g) d)
            ,"hgstoa-balance-nonces-hover" : (if kg (at "hibernated-balance-hover" g) z)
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


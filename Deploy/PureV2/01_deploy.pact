;; ===========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 1
;; OuronetIdsV1 + OUiOneV1 (interfaces) + O-UI-ONE (module)
;; ===========================================================================================
;; FIRST TRANSACTION OF THE APPREADS ROUND. Round V1 -- the 24 transactions in ../1_Pure/ --
;; is finished and kept as it shipped. This folder is the next round and starts from 1 again;
;; the two are siblings, not a sequence, and the old one is history rather than context.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT THIS IS
;; ------------------------------------------------------------------------------------------
;; The first slice of the read-layer split: the entity-id registry every AppReads module
;; imports, and OuronetUI entity 1 (HEADER). It replaces nothing on chain -- DPL-UR keeps
;; serving the old header until the UI moves off it, deliberately, so that both are live and a
;; rollback is a UI change rather than a redeploy.
;;
;; ------------------------------------------------------------------------------------------
;; ORDER WITHIN THE TRANSACTION IS LOAD-BEARING -- do not reorder
;; ------------------------------------------------------------------------------------------
;;   1. OuronetIdsV1   -- O-UI-ONE resolves OuronetIdsV1.IDX_* at MODULE LOAD, so the interface
;;                        must already exist when the module is read. Same transaction is fine;
;;                        the order inside it is not optional.
;;   2. OUiOneV1       -- O-UI-ONE `implements` it.
;;   3. O-UI-ONE
;;
;; ------------------------------------------------------------------------------------------
;; ALL THREE ARE FIRST DEPLOYS
;; ------------------------------------------------------------------------------------------
;; None of these names is on chain, so there is no "Interface cannot be upgraded" risk -- the
;; error that stopped transactions 11 and 21 of round V1. It also means NO module governance is
;; checked: a module's first deploy has nothing to govern. Only the NAMESPACE keyset signs.
;;
;; That asymmetry matters the next time this module is touched: an UPGRADE of O-UI-ONE WILL
;; check GOV|O_UI_ONE_ADMIN, so the key that ships it today is not automatically the key that
;; can change it tomorrow.
;;
;; ------------------------------------------------------------------------------------------
;; PREREQUISITES -- all satisfied by round V1
;; ------------------------------------------------------------------------------------------
;; O-UI-ONE modrefs OuronetDalosV2, EliteV2, DemiourgosPactTrueFungibleV2,
;; DemiourgosPactOrtoFungibleV2, AutostakeV3, SwapperV4, SwapperIssueV4, OuronetConstantsV2 and
;; DiaStoaPidV2. Every one landed in transactions 1-24.
;;
;; ------------------------------------------------------------------------------------------
;; AFTER IT LANDS
;; ------------------------------------------------------------------------------------------
;; Confirm the registry against chain before anything trusts it. Its eleven literals were copied
;; from source that PREDATES the Stage-1/2 redeploy and none has been verified live:
;;     (ouronet-ns.DALOS.UR_OuroborosID)
;;     (ouronet-ns.DPTF.UR_RewardBearingToken (ouronet-ns.DALOS.UR_AurynID))
;; A registry exists so nobody has to re-check it, and it earns that only by being right the
;; first time. UC_PickId derives first and falls back to these, so a wrong literal is masked
;; wherever the derivation works -- which makes it MORE important to check, not less.
;;
;; Then read the header:
;;     (ouronet-ns.O-UI-ONE.URC_01|Header "<a live Ouronet account>")
;; Flat, with exactly the keys DPL-UR::URC_0001_HeaderV3 returned, plus z1-ok..z4-ok. `z3-v1`
;; is a placeholder -- see the banner in the module for where the account count went and why.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface OuronetIdsV1
    @doc "Mainnet entity ids that cannot be computed: primordial tokens and the four primordial \
        \ ATS pairs. Literals on purpose -- see the header. Import these; never retype them."

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants

    ;;  PRIMORDIAL TOKENS -- the DPTF ids. Each is also readable from DALOS
    ;;  (UR_OuroborosID, UR_IgnisID, ...); they are duplicated here so that a
    ;;  consumer has ONE import rather than two sources of truth.
    (defconst ID_OURO           "OURO-8Nh-JO8JO4F5")
    (defconst ID_IGNIS          "GAS-8Nh-JO8JO4F5")
    (defconst ID_AURYN          "AURYN-8Nh-JO8JO4F5")
    (defconst ID_ELITEAURYN     "ELITEAURYN-8Nh-JO8JO4F5")
    (defconst ID_WSTOA          "WSTOA-8Nh-JO8JO4F5")
    (defconst ID_SSTOA          "SSTOA-8Nh-JO8JO4F5")
    (defconst ID_GSTOA          "GSTOA-8Nh-JO8JO4F5")

    ;;  HIBERNATED GOLDENSTOA -- a DPOF id, not a DPTF one. Derivable as
    ;;  (DPTF::UR_Hibernation ID_GSTOA); listed because the header reads it directly.
    (defconst ID_HGSTOA         "H|GSTOA-8Nh-JO8JO4F5")

    ;;  PRIMORDIAL ATS PAIRS. These are the ids whose derivation was in question on
    ;;  2026-09-24: DPTF::UR_RewardBearingToken reads a reverse index, and an unset
    ;;  index returns ["|"] rather than [] -- it does not abort, it leaks a BAR into
    ;;  the next call. The literals were known-good on mainnet for months. Use them.
    (defconst IDX_AURYNDEX      "Auryndex-O136CBn22ncY")
    (defconst IDX_EAURYNDEX     "EliteAuryndex-O136CBn22ncY")
    (defconst IDX_SILVERPILLAR  "SilverStoaPillar-O136CBn22ncY")
    (defconst IDX_GOLDENPILLAR  "GoldenStoaPillar-O136CBn22ncY")

    ;;  NO GROUPED CONSTANTS, and the reason is a Pact constraint worth knowing rather than
    ;;  rediscovering. This interface first carried
    ;;      (defconst IDS_PRIMORDIAL [ID_OURO ID_IGNIS ...])
    ;;  and loading it died with:
    ;;      "Fatal execution error, invariant violated: Defconst was not evaluated prior to
    ;;       execution: ouronet-ns.OuronetIdsV1.ID_OURO"
    ;;  An interface's defconsts are not ordered relative to one another, so one cannot
    ;;  reference a sibling. The options were to duplicate the seven literals inside the list --
    ;;  reintroducing the exact duplication this file exists to end -- or to leave the grouping
    ;;  to consumers. Consumers group. A registry with two spellings of the same id is not a
    ;;  registry.
)


(interface OUiOneV1
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
    (defun URC_01|Header:object (account:string))
)

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

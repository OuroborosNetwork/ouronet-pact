;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 1 of 24
;; This is STEP 1 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-0 must have run first, including the init steps between deploys.
;; 13 source file(s), 183,286 gas measured in the REPL gas model, 214,478 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/1_Utilities/01_U_CT.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/02_U_G.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/03_U_ST.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/04_U_RS.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/05_U_LST.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/06_U_INT.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/07_U_DEC.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/08_U_DALOS.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/09_U_ATS.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/10_U_DPTF.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/11_U_VST.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact
;;   1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact
;;
;; TOTAL: 15 interface(s), 13 module(s), 0 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/01_U_CT.pact
;;      interface  DiaStoaPidV2
;;      interface  OuronetConstantsV2
;;      module     U|CT
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/02_U_G.pact
;;      interface  OuronetGuardsV2
;;      module     U|G
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/03_U_ST.pact
;;      interface  OuronetGasStationV2
;;      module     U|ST
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/04_U_RS.pact
;;      interface  ReservedAccountsV2
;;      module     U|RS
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/05_U_LST.pact
;;      interface  StringProcessorV2
;;      module     U|LST
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/06_U_INT.pact
;;      interface  OuronetIntegersV2
;;      module     U|INT
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/07_U_DEC.pact
;;      interface  OuronetDecimalsV2
;;      module     U|DEC
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/08_U_DALOS.pact
;;      interface  UtilityDalosGlyphsV3
;;      interface  UtilityDalosV2
;;      module     U|DALOS
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/09_U_ATS.pact
;;      interface  UtilityAtsV3
;;      module     U|ATS
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/10_U_DPTF.pact
;;      interface  UtilityDptfV2
;;      module     U|DPTF
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/11_U_VST.pact
;;      interface  UtilityVstV2
;;      module     U|VST
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact
;;      interface  UtilitySwpV2
;;      module     U|SWP
;;   -- 1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact
;;      interface  BreadthFirstSearchV2
;;      module     U|BFS
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/01_U_CT.pact ===============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DiaStoaPidV2
    @doc "Exposes the UR Function that Reads STOA Price in Dollars (STOA-PID) via Dia Oracle on Chain 2"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_STOA-PID|Price:decimal ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuronetConstantsV2
    @doc "Exported Constants as Functions from this Module via interface"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun CT_NS_USE ())
    (defun CT_GOV|UTILS ())
    ;;
    (defun CT_DPTF-FeeLock ())
    (defun CT_ATS-FeeLock ())
    ;;
    (defun CT_STOA_PRECISION ())
    (defun CT_MIN_PRECISION ())
    (defun CT_MAX_PRECISION ())
    (defun CT_FEE_PRECISION ())
    (defun CT_MIN_DESIGNATION_LENGTH ())
    (defun CT_MAX_TOKEN_NAME_LENGTH ())
    (defun CT_MAX_TOKEN_TICKER_LENGTH ())
    (defun CT_ACCOUNT_ID_PROH-CHAR ())
    (defun CT_ACCOUNT_ID_MAX_LENGTH ())
    (defun CT_BAR ())
    (defun CT_NUMBERS ())
    (defun CT_CAPITAL_LETTERS ())
    (defun CT_NON_CAPITAL_LETTERS ())
    (defun CT_SPECIAL ())
    ;;
    (defun CT_ET ())
    (defun CT_DEB ())
    ;;
    (defun CT_C1 ())
    (defun CT_C2 ())
    (defun CT_C3 ())
    (defun CT_C4 ())
    (defun CT_C5 ())
    (defun CT_C6 ())
    (defun CT_C7 ())
    ;;
    (defun CT_N00 ())
    (defun CT_N01 ())
    (defun CT_N11 ())
    (defun CT_N12 ())
    (defun CT_N13 ())
    (defun CT_N14 ())
    (defun CT_N15 ())
    (defun CT_N16 ())
    (defun CT_N17 ())
    ;;
    (defun CT_N21 ())
    (defun CT_N22 ())
    (defun CT_N23 ())
    (defun CT_N24 ())
    (defun CT_N25 ())
    (defun CT_N26 ())
    (defun CT_N27 ())
    ;;
    (defun CT_N31 ())
    (defun CT_N32 ())
    (defun CT_N33 ())
    (defun CT_N34 ())
    (defun CT_N35 ())
    (defun CT_N36 ())
    (defun CT_N37 ())
    ;;
    (defun CT_N41 ())
    (defun CT_N42 ())
    (defun CT_N43 ())
    (defun CT_N44 ())
    (defun CT_N45 ())
    (defun CT_N46 ())
    (defun CT_N47 ())
    ;;
    (defun CT_N51 ())
    (defun CT_N52 ())
    (defun CT_N53 ())
    (defun CT_N54 ())
    (defun CT_N55 ())
    (defun CT_N56 ())
    (defun CT_N57 ())
    ;;
    (defun CT_N61 ())
    (defun CT_N62 ())
    (defun CT_N63 ())
    (defun CT_N64 ())
    (defun CT_N65 ())
    (defun CT_N66 ())
    (defun CT_N67 ())
    ;;
    (defun CT_N71 ())
    (defun CT_N72 ())
    (defun CT_N73 ())
    (defun CT_N74 ())
    (defun CT_N75 ())
    (defun CT_N76 ())
    (defun CT_N77 ())
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|CT GOV
    @doc "Constants library: exposes Ouronet's global constants as nullary functions \
        \ (implements OuronetConstantsV2 and DiaStoaPidV2). Provides namespace/keyset roots, \
        \ fee locks, precision/length limits, the alphabet and prohibited-char sets, the ET \
        \ (elite-auryn thresholds) and DEB (elite bonus multipliers) arrays, and elite \
        \ class/tier name strings. Also holds UR_STOA-PID|Price, a stubbed STOA/USD oracle \
        \ price."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetConstantsV2)
    (implements DiaStoaPidV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|DEMIURGOI                             (+ (CT_NS_USE) ".dh_master-keyset"))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|U|CT_ADMIN)))
    (defcap GOV|U|CT_ADMIN ()                           (enforce-guard (CT_GOV|UTILS)))
    ;;{G5}  functions

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
    ;;
    (defun CT_NamespaceMain ()                          (at 0 ["ouronet-ns"]))
    (defun CT_NamespaceTest ()                          (at 0 ["free"]))
    (defun CT_NS_USE                                    ()            (CT_NamespaceMain))
    (defun CT_GOV|UTILS ()                              (keyset-ref-guard GOV|DEMIURGOI))
    ;;
    ;;
    ;;#73L fix: removed the tautological `or` - `(CT_NamespaceTest)` is itself defined as
    ;;`(at 0 ["free"])` = "free" (line 10), so `(= (CT_NS_USE) (CT_NamespaceTest))` and
    ;;`(= (CT_NS_USE) "free")` were checking the exact same condition twice. Kept the named
    ;;`(CT_NamespaceTest)` form (clearer, doesn't hardcode the literal). No behavioral change.
    (defun CT_DPTF-FeeLock ()
        (if
            (= (CT_NS_USE) (CT_NamespaceTest))
            1.0
            10000.0
        )
    )
    (defun CT_ATS-FeeLock ()
        (/ (CT_DPTF-FeeLock) 10.0)
    )
    (defun CT_STOA_PRECISION () 12)
    (defun CT_MIN_PRECISION () 2)
    (defun CT_MAX_PRECISION () 24)
    (defun CT_FEE_PRECISION () 4)
    (defun CT_MIN_DESIGNATION_LENGTH () 2)
    (defun CT_MAX_TOKEN_NAME_LENGTH () 50)
    (defun CT_MAX_TOKEN_TICKER_LENGTH () 30)
    (defun CT_ACCOUNT_ID_PROH-CHAR () ["$" "¢" "£"])
    (defun CT_ACCOUNT_ID_MAX_LENGTH () 256)
    (defun CT_BAR () (at 0 ["|"]))
    (defun CT_NUMBERS ()
        ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"]
    )
    (defun CT_CAPITAL_LETTERS ()
        ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"]
    )
    (defun CT_NON_CAPITAL_LETTERS ()
        ["a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"]
    )
    (defun CT_SPECIAL () ["|" "-" "^"])
    (defun CT_ET ()
        @doc "Represents the Total-Elite-Auryn (vested and non-vested) to increase in Elite-Account Rank"
        [0.0 1.0 2.0 5.0 10.0 20.0 50.0 100.0
        105.0 110.0 125.0 150.0 200.0 350.0 600.0
        610.0 620.0 650.0 700.0 800.0 1100.0 1600.0
        1650.0 1700.0 1850.0 2100.0 2600.0 4100.0 6600.0
        6700.0 6800.0 7100.0 7600.0 8600.0 11600.0 16600.0
        17100.0 17600.0 19100.0 21600.0 26600.0 41600.0 66600.0
        67600.0 68600.0 71600.0 76600.0 86600.0 116600.0 166600.0]
    )
    (defun CT_DEB ()
        @doc "Represents the Demiourgos Elite Bonus as non-percentual, direct multipler"
        [1.0 1.01 1.02 1.03 1.04 1.05 1.06 1.07
        1.09 1.11 1.13 1.15 1.17 1.19 1.21
        1.24 1.27 1.30 1.33 1.36 1.39 1.42
        1.47 1.52 1.57 1.62 1.67 1.72 1.77
        1.85 1.93 2.01 2.09 2.17 2.25 2.33
        2.46 2.59 2.72 2.85 2.98 3.11 3.24
        3.45 3.66 3.87 4.08 4.29 4.50 4.71]
    )
    ;;
    (defun CT_C1 () (at 0 ["NOVICE"]))
    (defun CT_C2 () (at 0 ["INVESTOR"]))
    (defun CT_C3 () (at 0 ["ENTREPRENEUR"]))
    (defun CT_C4 () (at 0 ["MOGUL"]))
    (defun CT_C5 () (at 0 ["MAGNATE"]))
    (defun CT_C6 () (at 0 ["TYCOON"]))
    (defun CT_C7 () (at 0 ["DEMIURG"]))
    ;;
    (defun CT_N00 () (at 0 ["Infidel"]))
    (defun CT_N01 () (at 0 ["Indigent"]))
    (defun CT_N11 () (at 0 ["Fledgling"]))
    (defun CT_N12 () (at 0 ["Amateur"]))
    (defun CT_N13 () (at 0 ["Beginner"]))
    (defun CT_N14 () (at 0 ["Dabler"]))
    (defun CT_N15 () (at 0 ["Aspirant"]))
    (defun CT_N16 () (at 0 ["Enthusiast"]))
    (defun CT_N17 () (at 0 ["Partner"]))
    ;;
    (defun CT_N21 () (at 0 ["Novice Investor"]))
    (defun CT_N22 () (at 0 ["Associate Investor"]))
    (defun CT_N23 () (at 0 ["Junior Investor"]))
    (defun CT_N24 () (at 0 ["Senior Investor"]))
    (defun CT_N25 () (at 0 ["Adept Investor"]))
    (defun CT_N26 () (at 0 ["Expert Investor"]))
    (defun CT_N27 () (at 0 ["Elite Investor"]))
    ;;
    (defun CT_N31 () (at 0 ["Novice Entrepreneur"]))
    (defun CT_N32 () (at 0 ["Associate Entrepreneur"]))
    (defun CT_N33 () (at 0 ["Junior Entrepreneur"]))
    (defun CT_N34 () (at 0 ["Senior Entrepreneur"]))
    (defun CT_N35 () (at 0 ["Adept Entrepreneur"]))
    (defun CT_N36 () (at 0 ["Expert Entrepreneur"]))
    (defun CT_N37 () (at 0 ["Elite Entrepreneur"]))
    ;;
    (defun CT_N41 () (at 0 ["Associate Mogul"]))
    (defun CT_N42 () (at 0 ["Junior Mogul"]))
    (defun CT_N43 () (at 0 ["Senior Mogul"]))
    (defun CT_N44 () (at 0 ["Adept Mogul"]))
    (defun CT_N45 () (at 0 ["Expert Mogul"]))
    (defun CT_N46 () (at 0 ["Elite Mogul"]))
    (defun CT_N47 () (at 0 ["Master Mogul"]))
    ;;
    (defun CT_N51 () (at 0 ["Associate Magnate"]))
    (defun CT_N52 () (at 0 ["Junior Magnate"]))
    (defun CT_N53 () (at 0 ["Senior Magnate"]))
    (defun CT_N54 () (at 0 ["Adept Magnate"]))
    (defun CT_N55 () (at 0 ["Expert Magnate"]))
    (defun CT_N56 () (at 0 ["Elite Magnate"]))
    (defun CT_N57 () (at 0 ["Master Magnate"]))
    ;;
    (defun CT_N61 () (at 0 ["Junior Tycoon"]))
    (defun CT_N62 () (at 0 ["Senior Tycoon"]))
    (defun CT_N63 () (at 0 ["Adept Tycoon"]))
    (defun CT_N64 () (at 0 ["Expert Tycoon"]))
    (defun CT_N65 () (at 0 ["Elite Tycoon"]))
    (defun CT_N66 () (at 0 ["Master Tycoon"]))
    (defun CT_N67 () (at 0 ["Grand-Master Tycoon"]))
    ;;
    (defun CT_N71 () (at 0 ["Neophyte Demiurg"]))
    (defun CT_N72 () (at 0 ["Acolyte Demiurg"]))
    (defun CT_N73 () (at 0 ["Adept Demiurg"]))
    (defun CT_N74 () (at 0 ["Expert Demiurg"]))
    (defun CT_N75 () (at 0 ["Elite Demiurg"]))
    (defun CT_N76 () (at 0 ["Master Demiurg"]))
    (defun CT_N77 () (at 0 ["Grand-Master Demiurg"]))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    (defun UR_STOA-PID|Price:decimal ()
        ;;(at "value" (n_bfb76eab37bf8c84359d6552a1d96a309e030b71.dia-oracle.get-value "STOA/USD"))
        ;;#19H: no live oracle wired up yet - hardcoded to mainnet's approximate STOA/USD price
        ;;(owner, 2026-08-27) as an interim placeholder. Wire the real oracle call above once
        ;;one is available, and remove this stub.
        0.1
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/02_U_G.pact ================
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuronetGuardsV2
    @doc "Exported Functions from this Module via interface"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_Try (g:guard))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_All:bool (guards:[guard]))
    (defun UEV_Any:bool (guards:[guard]))
    (defun UEV_GuardOfAll:guard (guards:[guard]))
    (defun UEV_GuardOfAny:guard (guards:[guard]))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|G GOV
    @doc "Guard-combinator helpers (implements OuronetGuardsV2). Provides UEV_All (enforce \
        \ every guard in a list), UEV_Any (succeed if at least one passes, via the UC_Try \
        \ try-wrapper), and UEV_GuardOfAll / UEV_GuardOfAny which package those into \
        \ composite user-guards. Used wherever multiple guards must be enforced together or \
        \ as an either/or."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetGuardsV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|G_ADMIN)))
    (defcap GOV|U|G_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    ;;
    ;;
    (defun UC_Try (g:guard)
        @doc "Helper function used in <UEV_Any>"
        (try false (enforce-guard g))
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_All:bool (guards:[guard])
        @doc "Enforces all guards in GUARDS"
        (map (enforce-guard) guards)
        true
    )
    (defun UEV_Any:bool (guards:[guard])
        @doc "Will succeed if at least one guard in GUARDS is successfully enforced."
        (enforce
            (< 0 (length (filter (= true) (map (UC_Try) guards))))
            "None of the guards passed"
        )
    )
    (defun UEV_GuardOfAll:guard (guards:[guard])
        @doc "Create a guard that only succeeds if every guard in GUARDS is successfully enforced."
        (enforce (< 0 (length guards)) "Guard list cannot be empty")
        (create-user-guard (UEV_All guards))
    )
    (defun UEV_GuardOfAny:guard (guards:[guard])
        @doc "Create a guard that succeeds if at least one guard in GUARDS is successfully enforced."
        (enforce (< 0 (length guards)) "Guard list cannot be empty")
        (create-user-guard (UEV_Any guards))
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/03_U_ST.pact ===============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuronetGasStationV2
    @doc "Exported Ouronet Gas Station Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_chain-gas-price ())
    (defun UR_chain-gas-limit ())
    ;;
    (defun URC_chain-gas-notional ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_max-gas-notional:guard (gasNotional:decimal))
    (defun UEV_enforce-below-gas-notional (gasNotional:decimal))
    (defun UEV_enforce-below-or-at-gas-notional (gasNotional:decimal))
    (defun UEV_max-gas-price:guard (gasPrice:decimal))
    (defun UEV_enforce-below-gas-price:bool (gasPrice:decimal))
    (defun UEV_enforce-below-or-at-gas-price:bool (gasPrice:decimal))
    (defun UEV_max-gas-limit:guard (gasLimit:integer))
    (defun UEV_enforce-below-gas-limit:bool (gasLimit:integer))
    (defun UEV_enforce-below-or-at-gas-limit:bool (gasLimit:integer))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|ST GOV
    @doc "Gas-station helper library (implements OuronetGasStationV2). Reads gas price and \
        \ gas limit from chain-data, derives the gas notional (price * limit), and exposes a \
        \ family of UEV_ enforcers and user-guard builders that cap gas notional, gas price, \
        \ and gas limit (below vs below-or-at variants). Underpins Ouronet gas-station \
        \ spending limits."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetGasStationV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|ST_ADMIN)))
    (defcap GOV|U|ST_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;
    ;;
    (defun UR_chain-gas-price ()
        @doc "Return gas price from chain-data"
        (at 'gas-price (chain-data))
    )
    (defun UR_chain-gas-limit ()
        @doc "Return gas limit from chain-data"
        (at 'gas-limit (chain-data))
    )
    (defun URC_chain-gas-notional ()
        @doc "Return gas limit * gas price from chain-data"
        (* (UR_chain-gas-price) (UR_chain-gas-limit))
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_max-gas-notional:guard (gasNotional:decimal)
        @doc "Guard to enforce gas price * gas limit is smaller than or equal to GAS"
        (create-user-guard
            (UEV_enforce-below-or-at-gas-notional gasNotional)
        )
    )
    (defun UEV_enforce-below-gas-notional (gasNotional:decimal)
        (enforce (< (URC_chain-gas-notional) gasNotional)
            (format "Gas Limit * Gas Price must be smaller than {}" [gasNotional])
        )
    )
    (defun UEV_enforce-below-or-at-gas-notional (gasNotional:decimal)
        (enforce (<= (URC_chain-gas-notional) gasNotional)
            (format "Gas Limit * Gas Price must be smaller than or equal to {}" [gasNotional])
        )
    )
    (defun UEV_max-gas-price:guard (gasPrice:decimal)
        @doc "Guard to enforce gas price is smaller than or equal to GAS PRICE"
        (create-user-guard
            (UEV_enforce-below-or-at-gas-price gasPrice)
        )
    )
    (defun UEV_enforce-below-gas-price:bool (gasPrice:decimal)
        (enforce (< (UR_chain-gas-price) gasPrice)
            (format "Gas Price must be smaller than {}" [gasPrice])
        )
    )
    (defun UEV_enforce-below-or-at-gas-price:bool (gasPrice:decimal)
        (enforce (<= (UR_chain-gas-price) gasPrice)
            (format "Gas Price must be smaller than or equal to {}" [gasPrice])
        )
    )
    (defun UEV_max-gas-limit:guard (gasLimit:integer)
        @doc "Guard to enforce gas limit is smaller than or equal to GAS LIMIT"
        (create-user-guard
            (UEV_enforce-below-or-at-gas-limit gasLimit)
        )
    )
    (defun UEV_enforce-below-gas-limit:bool (gasLimit:integer)
        (enforce (< (UR_chain-gas-limit) gasLimit)
            (format "Gas Limit must be smaller than {}" [gasLimit])
        )
    )
    (defun UEV_enforce-below-or-at-gas-limit:bool (gasLimit:integer)
        (enforce (<= (UR_chain-gas-limit) gasLimit)
            (format "Gas Limit must be smaller than or equal to {}" [gasLimit])
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/04_U_RS.pact ===============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface ReservedAccountsV2
    @doc "Exported Reserved Account Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_CheckReserved:string (account:string))
    (defun UEV_EnforceReserved:bool (account:string guard:guard))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|RS GOV
    @doc "Reserved-account helpers (implements ReservedAccountsV2). UEV_CheckReserved \
        \ detects a single-char reserved prefix like 'c:foo' and returns its type; \
        \ UEV_EnforceReserved validates an account against principal/reserved-name \
        \ protocols, rejecting single-key and other reserved-guard violations. Guards \
        \ Ouronet account-name conventions."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements ReservedAccountsV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|RS_ADMIN)))
    (defcap GOV|U|RS_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;
    ;;
    ;;
    (defun UEV_CheckReserved:string (account:string)
        @doc "Checks account for reserved name and returns type if \
            \ found or empty string. Reserved names start with a \
            \ single char and colon, e.g. 'c:foo', which would return 'c' as type."
        (let
            (
                (pfx (take 2 account))
            )
            (if (= ":" (take -1 pfx))
                (take 1 pfx)
                ""
            )
        )
    )
    (defun UEV_EnforceReserved:bool (account:string guard:guard)
        @doc "Enforce reserved account name protocols"
        (if
            (validate-principal guard account)
            true
            (let
                (
                    (r (UEV_CheckReserved account))
                )
                (if
                    (= r "")
                    true
                    (if
                        (= r "k")
                        (enforce false "Single-key account protocol violation")
                        (enforce false (format "Reserved protocol guard violation: {}" [r]))
                    )
                )
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/05_U_LST.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface StringProcessorV2
    @doc "Exported List and String Processor Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_AppL:list (in:list item))
    (defun UC_Chain:list (in:list))
    (defun UC_FE (in:list))
    (defun UC_InsertFirst:list (in:list item))
    (defun UC_IsNotEmpty:bool (x:list))
    (defun UC_LE (in:list))
    (defun UC_RemoveItem:list (in:list item))
    (defun UC_RemoveItemAt:list (in:list position:integer))
    (defun UC_ReplaceAt:list (in:list idx:integer item))
    (defun UC_ReplaceItem:list (in:list old-item new-item))
    (defun UC_Search:[integer] (searchee:list item))
    (defun UC_SecondListElement (in:list))
    (defun UC_SplitString:[string] (splitter:string splitee:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_NotEmpty:bool (x:list))
    (defun UEV_StringPresence (item:string item-lst:[string]))
    ;;#44M fix: moved from [UC] - was UC_IzUnique, enforces (violates UC_ contract), renamed.
    (defun UEV_IzUnique (lst:[string]))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|LST GOV
    @doc "List and string processing library (implements StringProcessorV2). Provides pure \
        \ list ops (append, chain, insert, first/last, remove, replace, search) plus \
        \ UC_SplitString for tokenizing on a separator. Validators include UEV_NotEmpty, \
        \ UEV_StringPresence, and UEV_IzUnique (aborts on duplicates). Heavily reused across \
        \ the codebase for building and filtering lists."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements StringProcessorV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|LST_ADMIN)))
    (defcap GOV|U|LST_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    ;;
    ;;
    (defun UC_AppL:list (in:list item)
        @doc "Append an item at the end of the list"
        (+ in [item])
    )
    (defun UC_Chain:list (in:list)
        @doc "Chain list of lists"
        (fold (+) [] in)
    )
    (defun UC_FE (in:list)
        @doc "Returns the first item of a list"
        (UEV_NotEmpty in)
        (at 0 in)
    )
    (defun UC_InsertFirst:list (in:list item)
        @doc "Insert an item at the left of the list"
        (+ [item] in)
    )
    (defun UC_IsNotEmpty:bool (x:list)
        @doc "Return true if the list is not empty"
        (< 0 (length x))
    )
    (defun UC_LE (in:list)
        @doc "Returns the last item of the list"
        (UEV_NotEmpty in)
        (at (- (length in) 1) in)
    )
    (defun UC_RemoveItem:list (in:list item)
        @doc "Remove an item from a list"
        (filter (!= item) in)
    )
    (defun UC_RemoveItemAt:list (in:list position:integer)
        @doc "Removes and item from a list existing at a given position"
        (enforce (and (>= position 0) (< position (length in))) "Position must be non-negative and within the bounds of the list")
        (let
            (
                (before (take position in))
                (after (drop (+ position 1) in))
            )
            (+ before after)
        )
    )
    (defun UC_ReplaceAt:list (in:list idx:integer item)
        @doc "Replace the item at position idx"
        (enforce (and? (<= 0) (> (length in)) idx) "Index out of bounds")
        (UC_Chain
            [
                (take idx in),
                [item],
                (drop (+ 1 idx) in)
            ]
        )
    )
    (defun UC_ReplaceItem:list (in:list old-item new-item)
        @doc "Replace each occurrence of old-item by new-item"
        (map (lambda (x) (if (= x old-item) new-item x)) in)
    )
    (defun UC_Search:[integer] (searchee:list item)
        @doc "Search an item into the list and returns a list of index"
        (if (contains item searchee)
            (let
                (
                    (indexes (enumerate 0 (length searchee)))
                    (match (lambda (v i) (if (= item v) i -1)))
                )
                (UC_RemoveItem (zip (match) searchee indexes) -1)
            )
            []
        )
    )
    (defun UC_SecondListElement (in:list)
        @doc "Returns the second item of a list"
        (UEV_NotEmpty in)
        (at 1 in)
    )
    (defun UC_SplitString:[string] (splitter:string splitee:string)
        @doc "Splits a string using a single string as splitter"
        (if (= 0 (length splitee))
            [] ;If the string is empty return a zero length list
            (let*
                (
                    (sep-pos (UC_Search (str-to-list splitee) splitter))
                    (substart (map (+ 1) (UC_InsertFirst sep-pos -1)))
                    (sublen  (zip (-) (UC_AppL sep-pos 10000000) substart))
                    (cut (lambda (start len) (take len (drop start splitee))))
                )
                (zip (cut) substart sublen)
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;#44M fix: renamed UC_IzUnique -> UEV_IzUnique (was a UC_-prefixed function that enforces,
    ;;violating the UC_ pure-compute contract - same root cause as #43M). There is no "not
    ;;unique" case to return false for: a duplicate aborts the whole transaction via enforce,
    ;;there is no graceful path. The old inline comment ("If all items are unique, the function
    ;;returns true") misleadingly implied a real false-returning predicate contract that never
    ;;existed - fixed to state the actual contract plainly.
    (defun UEV_IzUnique (lst:[string])
        @doc "Enforces that <lst> is composed of unique elements. Aborts the transaction on the \
            \ first duplicate found - there is no false-returning case; always returns true."
        (let
            (
                (unique-set
                    (fold
                        (lambda
                            (acc:[string] item:string)
                            (enforce
                                (not (contains item acc))
                                (format "Unique Items Required, duplicate item found: {}" [item])
                            )
                            (UC_AppL acc item)
                        )
                        []
                        lst
                    )
                )
            )
            true
        )
    )
    (defun UEV_NotEmpty:bool (x:list)
        @doc "Verify and Enforces that a list is not empty"
        (enforce (UC_IsNotEmpty x) "List cannot be empty")
    )
    ;;#75L fix: the [bar]-sentinel check alone let a genuinely empty list [] fall through to
    ;;the generic "not present" message instead of the specific "Empty List detected!" one -
    ;;both cases still correctly aborted the transaction either way (no functional bug), just
    ;;with an inconsistent/less helpful message for the real-[] case. Added `(UC_IsNotEmpty
    ;;item-lst)` to the same enforce so both the [bar] sentinel and a real [] get the specific
    ;;message.
    (defun UEV_StringPresence (item:string item-lst:[string])
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (bar:string (ref-U|CT::CT_BAR))
                (iz-present:bool (contains item item-lst))
            )
            (enforce (and (!= item-lst [bar]) (UC_IsNotEmpty item-lst)) "Empty List detected!")
            (enforce iz-present (format "String {} is not present in list {}." [item item-lst]))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/06_U_INT.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuronetIntegersV2
    @doc "Exported Integer Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    (defschema NonceSplitter
        negative-nonces:[integer]
        positive-nonces:[integer]
        negative-counterparts:[integer]
        positive-counterparts:[integer]
    )
    (defschema SplitIntegers
        negative:[integer]
        positive:[integer]
    )
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun UDC_SplitIntegers:object{SplitIntegers} (neg:[integer] pos:[integer]))
    (defun UDC_NonceSplitter:object{NonceSplitter} (a:[integer] b:[integer] c:[integer] d:[integer]))
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_SplitAuxiliaryIntegerList:object{SplitIntegers} (primary:[integer] auxiliary:[integer]))
    (defun UC_SplitIntegerList:object{SplitIntegers} (input:[integer]))
    (defun UC_NonceSplitter:object{NonceSplitter} (nonces:[integer] amounts:[integer]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_ContainsAll:bool (l1:[integer] l2:[integer]))
    (defun UEV_PositionalVariable (integer-to-validate:integer positions:integer message:string))
    (defun UEV_UniformList (input:[integer]))
    ;;#45M fix: moved from [UC] - was UC_MaxInteger, crashed uncatchably (raw array-bounds
    ;;error, not even `try`-catchable) on an empty list via `(at 0 lst)`. There is no safe
    ;;benign default for "max of nothing" (unlike #20H/Fix #18's HybridArray sum-of-nothing=[]
    ;;case), so the correct fix is a real `enforce`, not a silent default - same root cause/fix
    ;;shape as #44M's UC_IzUnique -> UEV_IzUnique rename.
    (defun UEV_MaxInteger:integer (lst:[integer]))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|INT GOV
    @doc "Integer-list utilities (implements OuronetIntegersV2). Splits integer lists into \
        \ negative/positive partitions and pairs nonces with amounts (UC_NonceSplitter), \
        \ returning SplitIntegers / NonceSplitter objects built by UDC constructors. \
        \ Validators cover UEV_ContainsAll, UEV_PositionalVariable, UEV_UniformList, and \
        \ UEV_MaxInteger (enforced max, rejecting empty lists)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetIntegersV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|INT_ADMIN)))
    (defcap GOV|U|INT_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    ;;
    ;;
    ;;
    ;;
    (defun UDC_SplitIntegers:object{OuronetIntegersV2.SplitIntegers} (neg:[integer] pos:[integer])
        {"negative" : neg
        ,"positive" : pos}
    )
    (defun UDC_NonceSplitter:object{OuronetIntegersV2.NonceSplitter}
        (a:[integer] b:[integer] c:[integer] d:[integer])
        {"negative-nonces"          : a
        ,"positive-nonces"          : b
        ,"negative-counterparts"    : c
        ,"positive-counterparts"    : d}
    )
    ;;{5.2}  Compute [UC]
    (defun UC_SplitAuxiliaryIntegerList:object{OuronetIntegersV2.SplitIntegers} (primary:[integer] auxiliary:[integer])
        @doc "Splits an auxiliary integer list into 2 integers list, according to the negatives and positives of the primary"
        (let 
            (
                (indices (enumerate 0 (- (length primary) 1)))
                (neg-indices (filter (lambda (i:integer) (< (at i primary) 0)) indices))
                (pos-indices (filter (lambda (i:integer) (> (at i primary) 0)) indices))
                (neg-counterparts (map (lambda (i:integer) (at i auxiliary)) neg-indices))
                (pos-counterparts (map (lambda (i:integer) (at i auxiliary)) pos-indices))
            )
            (UDC_SplitIntegers neg-counterparts pos-counterparts)
        )
    )
    (defun UC_SplitIntegerList:object{OuronetIntegersV2.SplitIntegers} (input:[integer])
        @doc "Splits an integer list into a negative and postive integer list"
        (let 
            (
                (negatives (filter (lambda (x:integer) (< x 0)) input))
                (positives (filter (lambda (x:integer) (> x 0)) input))
            )
            (UDC_SplitIntegers negatives positives)
        )
    )
    (defun UC_NonceSplitter:object{OuronetIntegersV2.NonceSplitter} (nonces:[integer] amounts:[integer])
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (split-nonces:object{OuronetIntegersV2.SplitIntegers} (ref-U|INT::UC_SplitIntegerList nonces))
                (negative-nonces:[integer] (at "negative" split-nonces))
                (positive-nonces:[integer] (at "positive" split-nonces))
                (split-amounts:object{OuronetIntegersV2.SplitIntegers} (ref-U|INT::UC_SplitAuxiliaryIntegerList nonces amounts))
                (negative-counterparts:[integer] (at "negative" split-amounts))
                (positive-counterparts:[integer] (at "positive" split-amounts))
            )
            (UDC_NonceSplitter
                negative-nonces
                positive-nonces
                negative-counterparts
                positive-counterparts
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;#45M fix: renamed UC_MaxInteger -> UEV_MaxInteger (was a UC_-prefixed function that crashed
    ;;uncatchably - a raw array-bounds runtime error, not even `try`-catchable - on an empty
    ;;list via `(at 0 lst)`). There's no safe benign default for "max of an empty list," so the
    ;;fix is a real `enforce` converting the crash into a clean, catchable rejection - same
    ;;root-cause/fix shape as #44M. Body below the enforce is byte-for-byte unchanged.
    (defun UEV_MaxInteger:integer (lst:[integer])
        (enforce (> (length lst) 0) "UEV_MaxInteger: list cannot be empty")
        (fold
            (lambda
                (acc:integer element:integer)
                (if (> element acc) element acc)
            )
            (at 0 lst)
            (drop 1 lst)
        )
    )
    (defun UEV_ContainsAll:bool (l1:[integer] l2:[integer])
        (let*
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (tl:[bool]
                    (fold
                        (lambda
                            (acc:[bool] item:integer)
                            (ref-U|LST::UC_AppL acc (contains item l2))
                        )
                        []
                        l1
                    )
                )
                (sl:[integer] (ref-U|LST::UC_Search tl true))
                (tl2:integer (length sl))
            )
            (if (= tl2 (length l1))
                true
                false
            )
        )
    )
    (defun UEV_PositionalVariable (integer-to-validate:integer positions:integer message:string)
        @doc "Validates a number (positions-number) as positional variable"
        (enforce (= (contains integer-to-validate (enumerate 1 positions)) true) message)
    )
    (defun UEV_UniformList (input:[integer])
        @doc "Enforces that all elements in the integer list are the same."
        (let
            (
                (fe:integer (at 0 input))
            )  ;; Get the first element in the list
            (map
                (lambda
                    (index:integer)
                    (enforce (= fe (at index input)) "List elements are not the same")
                    true
                )
                (enumerate 0 (- (length input) 1))
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/07_U_DEC.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuronetDecimalsV2
    @doc "Exported Decimal Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_AddArray:[decimal] (array:[[decimal]]))
    (defun UC_AddHybridArray (lists)) ;;2
    (defun UC_Max (x y))
    (defun UCv_Percent:decimal (x:decimal percent:decimal precision:integer)) ;;3
    (defun UCv_Promille:decimal (x:decimal promille:decimal precision:integer)) ;;1
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_DecimalArray (array:[[decimal]])) ;;1
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|DEC GOV
    @doc "Decimal math helpers (implements OuronetDecimalsV2). Column-wise adds decimal \
        \ arrays (equal-length and ragged rows), plus UC_Max, UCv_Percent and UCv_Promille. \
        \ UEV_DecimalArray enforces that all inner fee-array lists share one length."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetDecimalsV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()
        (compose-capability (GOV|U|DEC_ADMIN))
    )
    (defcap GOV|U|DEC_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    ;;
    ;;
    (defun UC_AddArray:[decimal] (array:[[decimal]])
        @doc "Adds all column elements in an array of decimal elements, while ensuring all rows are of equal length"
        (UEV_DecimalArray array)
        (fold
            (lambda
                (acc:[decimal] item:[decimal])
                (zip (+) acc item)
            )
            (make-list (length (at 0 array)) 0.0)
            array
        )
    )
    (defun UC_AddHybridArray (lists)
        @doc "Adds all column elements in an array of numbers, even if the inner lists are of unequal lengths"
        (let
            (
                (maxl
                    (fold
                        (lambda
                            (acc lst)
                            (UC_Max acc (length lst))
                        )
                        0
                        lists
                    )
                )
            )
            ;;#20H fix: empty <lists> (or a set of all-empty inner lists) makes maxl=0, and
            ;;(enumerate 0 -1) returns [0 -1] rather than [], not [] as one might assume - the
            ;;same enumerate/negative-range footgun class as #N2's IGNIS UC_FindKeyIndex fix.
            ;;Guarded explicitly rather than touching the (already-correct, per every real
            ;;caller) non-empty path below.
            (if (= maxl 0)
                []
                (map
                    (lambda
                        (i)
                        (fold
                            (+)
                            0.0
                            (map
                                (lambda
                                    (inner-lst)
                                    (if (< i (length inner-lst))
                                        (at i inner-lst)
                                        0.0
                                    )
                                )
                                lists
                            )
                        )
                    )
                    (enumerate 0 (- maxl 1))
                )
            )
        )
    )
    (defun UC_Max (x y)
        (if (> x y) x y)
    )
    (defun UCv_Percent:decimal (x:decimal percent:decimal precision:integer)
        (enforce (and (>= percent 0.0)(<= percent 100.0)) "Invalid percent amount")
        (floor (* (/ percent 100.0) x) precision)
    )
    (defun UCv_Promille:decimal (x:decimal promille:decimal precision:integer)
        (enforce (and (>= promille 0.0)(<= promille 1000.0)) "Invalid permille amount")
        (floor (* (/ promille 1000.0) x) precision)
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_DecimalArray (array:[[decimal]])
        @doc "Enforces all inner list inside an array of decimal elements are of equal size"
        (enforce
            (=
                true
                (fold
                    (lambda
                        (acc:bool inner-lst:[decimal])
                        (and
                            acc
                            (if (=
                                    (length inner-lst)
                                    (length (at 0 array))
                                )
                                true
                                false
                            )
                        )
                    )
                    true
                    array
                )
            )
            "All Fee-Array Lists must be of equal length !"
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/08_U_DALOS.pact ============
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface UtilityDalosGlyphsV3
    @doc "Interface for DALOS glyph/account-format helpers implemented by U|DALOS. Declares \
        \ StoicTag name checks and account-string validators for DALOS accounts and Apollo \
        \ accounts, plus a multi-char DALOS-charset verifier. Separated from UtilityDalosV2 \
        \ as the glyph-validation half of the DALOS utility surface."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    (defun UC_IzStoicTagName:bool (name:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    (defun GLYPH|UEV_DalosAccountCheck (account:string))
    (defun GLYPH|UEV_DalosAccount (account:string))
    (defun GLYPH|UEV_ApolloAccountCheck (account:string smart:bool))
    (defun GLYPH|UEV_ApolloAccount (account:string smart:bool))
    (defun GLYPH|UEV_MsDc:bool (multi-s:string))
    (defun UEV_StoicTagName (name:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface UtilityDalosV2
    @doc "Exported Utility Functions for the DALOS Module"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun UDC_Makeid:string (ticker:string))
    (defun UDC_MakeMVXNonce:string (nonce:integer))
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_TenTwentyThirtyFourtySplit:[decimal] (input:decimal ip:integer))
    (defun UC_StageTwoEmissionSplit:[decimal] (input:decimal ip:integer))
    (defun UC_DirectFilterId:[string] (listoflists:[[string]] account:string))
    (defun UC_InverseFilterId:[string] (listoflists:[[string]] account:string))
    (defun UC_ConcatWithBar:string (input:[string]))
    ;;
    (defun UC_GasCost (base-cost:decimal major:integer minor:integer native:bool))
    (defun UC_GasDiscount (major:integer minor:integer native:bool))
    (defun UC_IzCharacterANC:bool (c:string capital:bool iz-special:bool))
    (defun UC_IzStringANC:bool (s:string capital:bool iz-special:bool))
    (defun UCv_NewRoleList (current-lst:[string] account:string direction:bool))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_Decimals:bool (decimals:integer))
    (defun UEV_Fee (fee:decimal))
    (defun UEV_NameOrTicker:bool (name-ticker:string name-or-ticker:bool iz-special:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|DALOS GOV
    @doc "DALOS glyph/format utility (implements UtilityDalosV2 and UtilityDalosGlyphsV3). \
        \ Defines the DALOS charset constants and helpers to build token ids/nonces, concat \
        \ with the bar separator, compute elite gas costs/discounts, split amounts, and \
        \ manage role lists. Validators enforce 162-char DALOS/Apollo account formats, \
        \ StoicTag names, decimals, fees, and token name/ticker rules."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements UtilityDalosV2)
    (implements UtilityDalosGlyphsV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|DALOS_ADMIN)))
    (defcap GOV|U|DALOS_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    ;;
    ;;
    (defconst DALOS|CHR_AUX
        [ " " "!" "#" "%" "&" "'" "(" ")" "*" "+" "," "-" "." "/" ":" ";" "<" "=" ">" "?" "@" "[" "]" "^" "_" "`" "{" "|" "}" "~" "‰" ]
    )
    (defconst DALOS|CHR_DIGITS
        ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"]
    )
    (defconst DALOS|CHR_CURRENCIES
        [ "Ѻ" "₿" "$" "¢" "€" "£" "¥" "₱" "₳" "∇" ]
    )
    (defconst DALOS|CHR_LATIN-B
        [ "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" ]
    )
    (defconst DALOS|CHR_LATIN-S
        [ "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z" ]
    )
    (defconst DALOS|CHR_LATIN-EXT-B
        [ "Æ" "Œ" "Á" "Ă" "Â" "Ä" "À" "Ą" "Å" "Ã" "Ć" "Č" "Ç" "Ď" "Đ" "É" "Ě" "Ê" "Ë" "È" "Ę" "Ğ" "Í" "Î" "Ï" "Ì" "Ł" "Ń" "Ñ" "Ó" "Ô" "Ö" "Ò" "Ø" "Õ" "Ř" "Ś" "Š" "Ş" "Ș" "Þ" "Ť" "Ț" "Ú" "Û" "Ü" "Ù" "Ů" "Ý" "Ÿ" "Ź" "Ž" "Ż" ]
    )
    (defconst DALOS|CHR_LATIN-EXT-S
        [ "æ" "œ" "á" "ă" "â" "ä" "à" "ą" "å" "ã" "ć" "č" "ç" "ď" "đ" "é" "ě" "ê" "ë" "è" "ę" "ğ" "í" "î" "ï" "ì" "ł" "ń" "ñ" "ó" "ô" "ö" "ò" "ø" "õ" "ř" "ś" "š" "ş" "ș" "þ" "ť" "ț" "ú" "û" "ü" "ù" "ů" "ý" "ÿ" "ź" "ž" "ż" "ß" ]
    )
    (defconst DALOS|CHR_GREEK-B
        [ "Γ" "Δ" "Θ" "Λ" "Ξ" "Π" "Σ" "Φ" "Ψ" "Ω" ]
    )
    (defconst DALOS|CHR_GREEK-S
        [ "α" "β" "γ" "δ" "ε" "ζ" "η" "θ" "ι" "κ" "λ" "μ" "ν" "ξ" "π" "ρ" "σ" "ς" "τ" "φ" "χ" "ψ" "ω" ]
    )
    (defconst DALOS|CHR_CYRILLIC-B
        [ "Б" "Д" "Ж" "З" "И" "Й" "Л" "П" "У" "Ц" "Ч" "Ш" "Щ" "Ъ" "Ы" "Ь" "Э" "Ю" "Я" ]
    )
    (defconst DALOS|CHR_CYRILLIC-S
        [ "б" "в" "д" "ж" "з" "и" "й" "к" "л" "м" "н" "п" "т" "у" "ф" "ц" "ч" "ш" "щ" "ъ" "ы" "ь" "э" "ю" "я" ]
    )
    (defconst DALOS|CHARSET
        (fold (+) []
            [
                DALOS|CHR_DIGITS
                DALOS|CHR_CURRENCIES
                DALOS|CHR_LATIN-B
                DALOS|CHR_LATIN-S
                DALOS|CHR_LATIN-EXT-B
                DALOS|CHR_LATIN-EXT-S
                DALOS|CHR_GREEK-B
                DALOS|CHR_GREEK-S
                DALOS|CHR_CYRILLIC-B
                DALOS|CHR_CYRILLIC-S
            ]
        )
    )
    (defconst DALOS|EXTENDED                            (+ DALOS|CHR_AUX DALOS|CHARSET))
    (defconst GLYPH|STOICTAG-MIN-LEN:integer            3)
    (defconst GLYPH|STOICTAG-MAX-LEN:integer            256)
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
    ;;
    ;;
    (defun UDC_Makeid:string (ticker:string)
        @doc "Creates a Token Id from a string source as the Token Ticker \
            \ using the first 12 Characters of the prev-block-hash of (chain-data) as \
            \ randomness source. \
            \ NOTE (DPDC Audit #33M, accepted/by-design, 2026-08-23): <prev-block-hash> is \
            \ block-level, identical for every tx in the same block -- not a per-tx nonce. \
            \ Two issuances with the SAME <ticker> landing in the SAME block (regardless of \
            \ caller/module -- DPDC-I, DPTF, ATS, MTX-SWP, DPOF, DPMF, SWPI all key off this \
            \ id, and all share the single BRD|BrandingTable) produce byte-identical ids and \
            \ the second hard-aborts on a raw table-insert collision. This cannot be fixed \
            \ inside this function: doing so would require this Utility (deployed before \
            \ Core) to read a Core-module table (e.g. BRD|BrandingTable) to detect/retry a \
            \ collision, which is a deploy-order violation. Accepted as-is: the failure is \
            \ atomic, self-healing (the next block has a different <prev-block-hash>), and \
            \ not exploitable beyond a same-block retry -- callers hitting this should \
            \ simply resubmit in a later block."
        (let
            (
                (dash "-")
                (twelve (take 12 (at "prev-block-hash" (chain-data))))
            )
            (concat [ticker dash twelve])
        )
    )
    (defun UDC_MakeMVXNonce:string (nonce:integer)
        @doc "Creates a MultiversX specific NFT nonce from an integer"
        (let*
            (
                (hexa:string (int-to-str 16 nonce))
                (hexalength:integer (length hexa))
            )
            (if (= (mod hexalength 2) 1 )
                (concat ["0" hexa])
                hexa
            )
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_TenTwentyThirtyFourtySplit:[decimal] (input:decimal ip:integer)
        (let
            (
                (v1:decimal (floor (* 0.1 input) ip))
                (v2:decimal (* 2.0 v1))
                (v3:decimal (* 3.0 v1))
                (v4:decimal (- input(fold (+) 0.0 [v1 v2 v3])))
            )
            [v1 v2 v3 v4]
        )
    )
    (defun UC_StageTwoEmissionSplit:[decimal] (input:decimal ip:integer)
        @doc "Stage Two daily OURO emission split, in DESTINATION ORDER: \
            \ [custodians-20 treasury-10 shareholders-10 liquidity-farm-20 autostake-20 subsidiary-20]. \
            \ Mirrors UC_TenTwentyThirtyFourtySplit exactly: every share is derived from ONE floored \
            \ 10% unit, and the LAST share absorbs the rounding remainder so the parts always sum to \
            \ `input` with nothing minted-but-unassigned. Sums to 100%: 20+10+10+20+20+20."
        (let
            (
                (u:decimal (floor (* 0.1 input) ip))           ;;one 10% unit, floored once
                (v20a:decimal (* 2.0 u))                       ;;custodians
                (v10a:decimal u)                               ;;demiourgos treasury
                (v10b:decimal u)                               ;;shareholders
                (v20b:decimal (* 2.0 u))                       ;;ouroboros liquidity farming
                (v20c:decimal (* 2.0 u))                       ;;autostaking — auryndex fuel
                (v20d:decimal (- input (fold (+) 0.0 [(* 2.0 u) u u (* 2.0 u) (* 2.0 u)])))
            )
            [v20a v10a v10b v20b v20c v20d]
        )
    )
    (defun UC_DirectFilterId:[string] (listoflists:[[string]] account:string)
        @doc "Helper Function needed for returning DALOS ids for Account <account>"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (result
                    (fold
                        (lambda
                            (acc:[string] item:[string])
                            (if (= (ref-U|LST::UC_LE item) account)
                                (ref-U|LST::UC_AppL acc
                                    (if (= (length item) 2)
                                        (ref-U|LST::UC_FE item)
                                        (UC_ConcatWithBar (drop -1 item))
                                    )
                                )
                                acc
                            )
                        )
                        []
                        listoflists
                    )
                )
            )
            result
        )
    )
    (defun UC_InverseFilterId:[string] (listoflists:[[string]] account:string)
        @doc "Helper Function needed for returning DALOS ids for Account <account>"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (result
                    (fold
                        (lambda
                            (acc:[string] item:[string])
                            (if (= (UC_ConcatWithBar (drop -1 item)) account)
                                (ref-U|LST::UC_AppL acc
                                    (ref-U|LST::UC_LE item)
                                )
                                acc
                            )  
                        )
                        []
                        listoflists
                    )
                )
            )
            result
        )
    )
    (defun UC_ConcatWithBar:string (input:[string])
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (b:string (ref-U|CT::CT_BAR))
                (folded-lst:[string]
                    (fold
                        (lambda
                            (acc:[string] idx:integer)
                            (if (!= idx (- (length input) 1))
                                (ref-U|LST::UC_AppL acc (+ (at idx input) b))
                                (ref-U|LST::UC_AppL acc (at idx input))
                            )
                        )
                        []
                        (enumerate 0 (- (length input) 1))
                    )
                )
            )
            (fold (+) "" folded-lst)
            
        )
    )
    (defun UC_GasCost (base-cost:decimal major:integer minor:integer native:bool)
        @doc "Computes gas costs (ignis or stoa) based on input <base-cost> and <minor> and <major> Elite Tier"
        (* (/ (- 100.0 (UC_GasDiscount major minor native)) 100.0) base-cost)
    )
    (defun UC_GasDiscount (major:integer minor:integer native:bool)
        @doc "Computes the discount applied to base gas cost \
        \ Native <true> = 24.5% Reduction maximum at Tier 7.7 for STOA Costs \
        \ Not Native <false> = 49.5% Reduction maximum at Tier 7.7 for IGNIS Costs"
        (if (= major 0)
            0.0
            (let
                (
                    (ignis:decimal (+ (* 7.0 (- (dec major) 1.0)) (dec minor)))
                )
                (if native
                    (* 0.5 ignis)
                    ignis
                )
            )
        )
    )
    (defun UC_IzCharacterANC:bool (c:string capital:bool iz-special:bool)
        @doc "Checks if a character is alphanumeric with or without Uppercase Only"
        (let*
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)

                (cl:[string] (ref-U|CT::CT_CAPITAL_LETTERS))
                (n:[string] (ref-U|CT::CT_NUMBERS))
                (ncl:[string] (ref-U|CT::CT_NON_CAPITAL_LETTERS))
                (s:[string] (ref-U|CT::CT_SPECIAL))

                (c1:bool (or (contains c cl)(contains c n)))
                (c2:bool (or c1 (contains c ncl) ))
                (c3:bool (or c1 (contains c s)))
                (c4:bool (or c3 (contains c ncl)))
            )
            (if iz-special
                (if capital c3 c4)
                (if capital c1 c2)
            )
        )
    )
    (defun UC_IzStringANC:bool (s:string capital:bool iz-special:bool)
        @doc "Checks if a string is alphanumeric with or without Uppercase Only \
        \ Uppercase Only toggle is used by setting the capital boolean to true"
        (fold
            (lambda
                (acc:bool c:string)
                (and acc (UC_IzCharacterANC c capital iz-special))
            )
            true
            (str-to-list s)
        )
    )
    (defun UCv_NewRoleList (current-lst:[string] account:string direction:bool)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (b:string (ref-U|CT::CT_BAR))
                (l:integer (length current-lst))
                (iz-within:bool (contains account current-lst))
            )
            (if direction
                (if
                    (and (= l 1) (= current-lst [b]))
                    [account]
                    (ref-U|LST::UC_AppL current-lst account)
                )
                (do
                    (enforce iz-within "When removing an Account, it must exist within!")
                    (if
                        (and (= l 1) (!= current-lst [b]))
                        [b]
                        (ref-U|LST::UC_RemoveItem current-lst account)
                    )
                )
            )
        )
    )
    (defun UC_IzStoicTagName:bool (name:string)
        @doc "True when <name> is 3–256 chars and every glyph is in DALOS|CHARSET."
        (let 
            (
                (nlen:integer (length name))
            )
            (fold (and) true
                [
                    (>= nlen GLYPH|STOICTAG-MIN-LEN)
                    (<= nlen GLYPH|STOICTAG-MAX-LEN)
                    (fold
                        (lambda (ok:bool c:string) (and ok (contains c DALOS|CHARSET)))
                        true
                        (str-to-list name)
                    )
                ]
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    (defun GLYPH|UEV_DalosAccountCheck (account:string)
        @doc "Checks if a string is a valid DALOS Account, using no enforcements "
        (let
            (
                (account-len:integer (length account))
                (ouroboros:string "Ѻ")
                (sigma:string "Σ")
                (first:string (take 1 account))
                (second:string (drop 1 (take 2 account)))
                (point:string ".")
                (iz-prefix:bool (or (= first ouroboros) (= first sigma)))
            )
            (fold (and) true
                [
                    (= account-len 162)
                    iz-prefix
                    (= second point)
                    (GLYPH|UEV_MsDc (drop 2 account))
                ]
            )
        )
    )
    (defun GLYPH|UEV_DalosAccount (account:string)
        @doc "Enforces that a Dalos Account (Address) has the proper format"
        (let
            (
                (account-len:integer (length account))
                (ouroboros:string "Ѻ")
                (sigma:string "Σ")
                (first:string (take 1 account))
                (second:string (drop 1 (take 2 account)))
                (point:string ".")
            )
            (enforce (= account-len 162) "Address|Account does not conform to the DALOS Standard for Addresses|Accounts")
            (enforce-one
                "Address|Account format is invalid"
                [
                    (enforce (= first ouroboros) "Account|Address Identifier is invalid, while checking for a Standard Account|Address")
                    (enforce (= first sigma) "Account|Address Identifier is invalid, while checking for a Smart Account|Address")
                ]
            )
            (enforce (= second point) "Account|Address Format is invalid, second Character must be a <.>")
            (let
                (
                    (checkup:bool (GLYPH|UEV_MsDc (drop 2 account)))
                )
                (enforce checkup "Characters do not conform to the DALOS|CHARSET")
            )
        )
    )
    (defun GLYPH|UEV_ApolloAccountCheck (account:string smart:bool)
        @doc "True when <account> is a 162-char Apollo string: Standard ₱. or Smart Π. plus DALOS|CHARSET body."
        (let
            (
                (account-len:integer (length account))
                (apollo-standard:string "₱")
                (apollo-smart:string "Π")
                (first:string (take 1 account))
                (second:string (drop 1 (take 2 account)))
                (point:string ".")
                (iz-prefix:bool
                    (if smart
                        (= first apollo-smart)
                        (= first apollo-standard)
                    )
                )
            )
            (fold (and) true
                [
                    (= account-len 162)
                    iz-prefix
                    (= second point)
                    (GLYPH|UEV_MsDc (drop 2 account))
                ]
            )
        )
    )
    (defun GLYPH|UEV_ApolloAccount (account:string smart:bool)
        @doc "Enforces Apollo Codex identity half (Standard ₱. or Smart Π.) — same length and charset as DALOS accounts."
        (let
            (
                (account-len:integer (length account))
                (apollo-standard:string "₱")
                (apollo-smart:string "Π")
                (first:string (take 1 account))
                (second:string (drop 1 (take 2 account)))
                (point:string ".")
            )
            (enforce (= account-len 162) "Apollo account string does not conform to length 162")
            (if smart
                (enforce (= first apollo-smart) "Apollo Smart account must begin with Π")
                (enforce (= first apollo-standard) "Apollo Standard account must begin with ₱")
            )
            (enforce (= second point) "Apollo account format is invalid, second character must be <.>")
            (let
                (
                    (checkup:bool (GLYPH|UEV_MsDc (drop 2 account)))
                )
                (enforce checkup "Apollo account characters do not conform to the DALOS|CHARSET")
            )
        )
    )
    (defun GLYPH|UEV_MsDc:bool (multi-s:string)
        @doc "Enforce a multistring is part of the DALOS|CHARSET"
        (let
            (
                (str-lst:[string] (str-to-list multi-s))
            )
            (fold
                (lambda
                    (acc:bool idx:integer)
                    (let
                        (
                            (checkup:bool (contains (at idx str-lst) DALOS|CHARSET))
                        )
                        (and acc checkup)
                    )
                )
                true
                (enumerate 0 (- (length str-lst) 1))
            )
        )
    )
    (defun UEV_StoicTagName (name:string)
        @doc "Enforces CODEX StoicTag name length and DALOS|CHARSET."
        (enforce
            (UC_IzStoicTagName name)
            (format "StoicTag name {} must be 3–256 glyphs from DALOS|CHARSET" [name])
        )
    )
    (defun UEV_Decimals:bool (decimals:integer)
        @doc "Enforces the decimal size is DALOS precision conform"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (min:integer (ref-U|CT::CT_MIN_PRECISION))
                (max:integer (ref-U|CT::CT_MAX_PRECISION))
            )
            (enforce
                (and
                    (>= decimals min)
                    (<= decimals max)
                )
                "Decimal Size is not between 2 and 24 as per DALOS Standard!"
            )
        )
    )
    (defun UEV_Fee (fee:decimal)
        @doc "Validate input decimal as a fee value"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (fp:integer (ref-U|CT::CT_FEE_PRECISION))
            )
            (enforce
                (= (floor fee fp) fee)
                (format "The fee amount of {} is not a valid fee amount decimal wise" [fee])
            )
            (enforce
                (or
                    (or (= fee -1.0) (= fee 0.0))
                    (and (>= fee 1.0) (<= fee 999.0))
                )
                (format "The fee amount of {} is not a valid fee amount value wise" [fee])
            )
        )
    )
    (defun UEV_NameOrTicker:bool (name-ticker:string name-or-ticker:bool iz-special:bool)
        @doc "Enforces correct DALOS Token Name and/or Ticker specifications"
        (let*
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (nl (length name-ticker))
                (min:integer (ref-U|CT::CT_MIN_DESIGNATION_LENGTH))
                (max-n-standard:integer (ref-U|CT::CT_MAX_TOKEN_NAME_LENGTH))
                (max-t-standard:integer (ref-U|CT::CT_MAX_TOKEN_TICKER_LENGTH))
                (max-n-lp:integer (+ (* max-n-standard 7) 8))
                (max-t-lp:integer (+ (* max-t-standard 7) 11))
                (max-n:integer (if iz-special max-n-lp max-n-standard))
                (max-t:integer (if iz-special max-t-lp max-t-standard))
                (max:integer (if name-or-ticker max-n max-t))
            )
            (enforce
                (and
                    (>= nl min)
                    (<= nl max)
                )
            "Designation does not conform to the DALOS Name Standard for Size!"
            )
            (enforce
                (UC_IzStringANC name-ticker (not name-or-ticker) iz-special)
                "Designation does not conform character-wise"
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/09_U_ATS.pact ==============
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface UtilityAtsV3
    @doc "Exported Utility Functions for the ATS and ATSU Modules (V2: StoicTag index helpers)"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;
    (defschema Awo
        reward-tokens:[decimal]
        cull-time:time
    )
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun UDC_Elite (x:decimal))
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_IzCullable:bool (input:object{Awo}))
    (defun UC_IzUnstakeObjectValid:bool (input:object{Awo}))
    (defun UC_KickStartIndex:decimal (rt-amounts:[decimal] rbt-request-amount:decimal))
    (defun UCv_MakeHardIntervals:[integer] (start:integer growth:integer))
    (defun UCv_MakeSoftIntervals:[integer] (start:integer growth:integer))
    (defun UC_MultiReshapeUnstakeObject:[object{Awo}] (input:[object{Awo}] remove-position:integer))
    (defun UC_PromilleSplit:[decimal] (promille:decimal input:decimal input-precision:integer))
    (defun UC_ReshapeUnstakeObject:object{Awo} (input:object{Awo} remove-position:integer))
    (defun UCv_SolidifyUnstakeObject:object{Awo} (input:object{Awo} remove-position:integer))
    (defun UCv_SplitBalanceWithBooleans:[decimal] (precision:integer amount:decimal milestones:integer boolean:[bool]))
    (defun UC_SplitByIndexedRBT:[decimal] (rbt-amount:decimal pair-rbt-supply:decimal index:decimal resident-amounts:[decimal] rt-precisions:[integer]))
    (defun UC_IzStoicTagIndexChar:bool (c:string))
    (defun UC_IzStoicTagIndex:bool (name:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_AutostakeIndex (ats:string))
    (defun UEV_StoicTagIndex (name:string))
    (defun UEV_UniqueAtspair (ats:string))
        ;;
    (defun UEV_CRF|Positions (fee-positions:integer))
    (defun UEV_CRF|FeeThresholds (fee-thresholds:[decimal] c-rbt-prec:integer))
    (defun UEV_CRF|FeeArray (fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]]))
    (defun UEV_Fee (fee:decimal))
    (defun UEV_Decay (decay:integer))
    (defun UEV_HibernationFees (peak:decimal decay:decimal))
        ;;
    (defun UEV_ColdDurationParameters (soft-or-hard:bool base:integer growth:integer))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|ATS GOV
    @doc "Autostake (ATS/ATSU) utility library (implements UtilityAtsV3). Core piece is \
        \ UDC_Elite, mapping a decimal auryn amount to an elite class/name/tier/DEB object. \
        \ Provides unstake-object reshaping, reward-token splitting, cold-recovery interval \
        \ builders, unlock pricing, StoicTag index checks, and a large set of UEV validators \
        \ for atspair ids, cold-recovery fees/thresholds/arrays, decay, and hibernation \
        \ fees."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements UtilityAtsV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|ATS_ADMIN)))
    (defcap GOV|U|ATS_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    ;;
    ;;
    ;;
    ;;
    (defun UDC_Elite (x:decimal)
        @doc "Returns an Object following DALOS|EliteSchema given a decimal input amount"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (et:[decimal] (ref-U|CT::CT_ET))
                (deb:[decimal] (ref-U|CT::CT_DEB))
                ;;
                (c1:string (ref-U|CT::CT_C1))
                (c2:string (ref-U|CT::CT_C2))
                (c3:string (ref-U|CT::CT_C3))
                (c4:string (ref-U|CT::CT_C4))
                (c5:string (ref-U|CT::CT_C5))
                (c6:string (ref-U|CT::CT_C6))
                (c7:string (ref-U|CT::CT_C7))
                ;;
                (n00:string (ref-U|CT::CT_N00))
                (n01:string (ref-U|CT::CT_N01))
                ;;
                (n11:string (ref-U|CT::CT_N11))
                (n12:string (ref-U|CT::CT_N12))
                (n13:string (ref-U|CT::CT_N13))
                (n14:string (ref-U|CT::CT_N14))
                (n15:string (ref-U|CT::CT_N15))
                (n16:string (ref-U|CT::CT_N16))
                (n17:string (ref-U|CT::CT_N17))
                ;;
                (n21:string (ref-U|CT::CT_N21))
                (n22:string (ref-U|CT::CT_N22))
                (n23:string (ref-U|CT::CT_N23))
                (n24:string (ref-U|CT::CT_N24))
                (n25:string (ref-U|CT::CT_N25))
                (n26:string (ref-U|CT::CT_N26))
                (n27:string (ref-U|CT::CT_N27))
                ;;
                (n31:string (ref-U|CT::CT_N31))
                (n32:string (ref-U|CT::CT_N32))
                (n33:string (ref-U|CT::CT_N33))
                (n34:string (ref-U|CT::CT_N34))
                (n35:string (ref-U|CT::CT_N35))
                (n36:string (ref-U|CT::CT_N36))
                (n37:string (ref-U|CT::CT_N37))
                ;;
                (n41:string (ref-U|CT::CT_N41))
                (n42:string (ref-U|CT::CT_N42))
                (n43:string (ref-U|CT::CT_N43))
                (n44:string (ref-U|CT::CT_N44))
                (n45:string (ref-U|CT::CT_N45))
                (n46:string (ref-U|CT::CT_N46))
                (n47:string (ref-U|CT::CT_N47))
                ;;
                (n51:string (ref-U|CT::CT_N51))
                (n52:string (ref-U|CT::CT_N52))
                (n53:string (ref-U|CT::CT_N53))
                (n54:string (ref-U|CT::CT_N54))
                (n55:string (ref-U|CT::CT_N55))
                (n56:string (ref-U|CT::CT_N56))
                (n57:string (ref-U|CT::CT_N57))
                ;;
                (n61:string (ref-U|CT::CT_N61))
                (n62:string (ref-U|CT::CT_N62))
                (n63:string (ref-U|CT::CT_N63))
                (n64:string (ref-U|CT::CT_N64))
                (n65:string (ref-U|CT::CT_N65))
                (n66:string (ref-U|CT::CT_N66))
                (n67:string (ref-U|CT::CT_N67))
                ;;
                (n71:string (ref-U|CT::CT_N71))
                (n72:string (ref-U|CT::CT_N72))
                (n73:string (ref-U|CT::CT_N73))
                (n74:string (ref-U|CT::CT_N74))
                (n75:string (ref-U|CT::CT_N75))
                (n76:string (ref-U|CT::CT_N76))
                (n77:string (ref-U|CT::CT_N77))
            )
            (cond
                ;;Class Novice
                ((<= x (at 0 et)) { "class": c1, "name": n00, "tier": "0.0", "deb": (at 0 deb)})
                ((and (> x (at 0 et))(< x (at 1 et))) { "class": c1, "name": n01, "tier": "0.1", "deb": (at 0 deb)})
                ((and (>= x (at 1 et))(< x (at 2 et))) { "class": c1, "name": n11, "tier": "1.1", "deb": (at 1 deb)})
                ((and (>= x (at 2 et))(< x (at 3 et))) { "class": c1, "name": n12, "tier": "1.2", "deb": (at 2 deb)})
                ((and (>= x (at 3 et))(< x (at 4 et))) { "class": c1, "name": n13, "tier": "1.3", "deb": (at 3 deb)})
                ((and (>= x (at 4 et))(< x (at 5 et))) { "class": c1, "name": n14, "tier": "1.4", "deb": (at 4 deb)})
                ((and (>= x (at 5 et))(< x (at 6 et))) { "class": c1, "name": n15, "tier": "1.5", "deb": (at 5 deb)})
                ((and (>= x (at 6 et))(< x (at 7 et))) { "class": c1, "name": n16, "tier": "1.6", "deb": (at 6 deb)})
                ((and (>= x (at 7 et))(< x (at 8 et))) { "class": c1, "name": n17, "tier": "1.7", "deb": (at 7 deb)})
                ;;Class INVESTOR
                ((and (>= x (at 8 et))(< x (at 9 et))) { "class": c2, "name": n21, "tier": "2.1", "deb": (at 8 deb)})
                ((and (>= x (at 9 et))(< x (at 10 et))) { "class": c2, "name": n22, "tier": "2.2", "deb": (at 9 deb)})
                ((and (>= x (at 10 et))(< x (at 11 et))) { "class": c2, "name": n23, "tier": "2.3", "deb": (at 10 deb)})
                ((and (>= x (at 11 et))(< x (at 12 et))) { "class": c2, "name": n24, "tier": "2.4", "deb": (at 11 deb)})
                ((and (>= x (at 12 et))(< x (at 13 et))) { "class": c2, "name": n25, "tier": "2.5", "deb": (at 12 deb)})
                ((and (>= x (at 13 et))(< x (at 14 et))) { "class": c2, "name": n26, "tier": "2.6", "deb": (at 13 deb)})
                ((and (>= x (at 14 et))(< x (at 15 et))) { "class": c2, "name": n27, "tier": "2.7", "deb": (at 14 deb)})
                ;;Class ENTREPRENEUR
                ((and (>= x (at 15 et))(< x (at 16 et))) { "class": c3, "name": n31, "tier": "3.1", "deb": (at 15 deb)})
                ((and (>= x (at 16 et))(< x (at 17 et))) { "class": c3, "name": n32, "tier": "3.2", "deb": (at 16 deb)})
                ((and (>= x (at 17 et))(< x (at 18 et))) { "class": c3, "name": n33, "tier": "3.3", "deb": (at 17 deb)})
                ((and (>= x (at 18 et))(< x (at 19 et))) { "class": c3, "name": n34, "tier": "3.4", "deb": (at 18 deb)})
                ((and (>= x (at 19 et))(< x (at 20 et))) { "class": c3, "name": n35, "tier": "3.5", "deb": (at 19 deb)})
                ((and (>= x (at 20 et))(< x (at 21 et))) { "class": c3, "name": n36, "tier": "3.6", "deb": (at 20 deb)})
                ((and (>= x (at 21 et))(< x (at 22 et))) { "class": c3, "name": n37, "tier": "3.7", "deb": (at 21 deb)})
                ;;Class MOGUL
                ((and (>= x (at 22 et))(< x (at 23 et))) { "class": c4, "name": n41, "tier": "4.1", "deb": (at 22 deb)})
                ((and (>= x (at 23 et))(< x (at 24 et))) { "class": c4, "name": n42, "tier": "4.2", "deb": (at 23 deb)})
                ((and (>= x (at 24 et))(< x (at 25 et))) { "class": c4, "name": n43, "tier": "4.3", "deb": (at 24 deb)})
                ((and (>= x (at 25 et))(< x (at 26 et))) { "class": c4, "name": n44, "tier": "4.4", "deb": (at 25 deb)})
                ((and (>= x (at 26 et))(< x (at 27 et))) { "class": c4, "name": n45, "tier": "4.5", "deb": (at 26 deb)})
                ((and (>= x (at 27 et))(< x (at 28 et))) { "class": c4, "name": n46, "tier": "4.6", "deb": (at 27 deb)})
                ((and (>= x (at 28 et))(< x (at 29 et))) { "class": c4, "name": n47, "tier": "4.7", "deb": (at 28 deb)})
                ;;Class MAGNATE
                ((and (>= x (at 29 et))(< x (at 30 et))) { "class": c5, "name": n51, "tier": "5.1", "deb": (at 29 deb)})
                ((and (>= x (at 30 et))(< x (at 31 et))) { "class": c5, "name": n52, "tier": "5.2", "deb": (at 30 deb)})
                ((and (>= x (at 31 et))(< x (at 32 et))) { "class": c5, "name": n53, "tier": "5.3", "deb": (at 31 deb)})
                ((and (>= x (at 32 et))(< x (at 33 et))) { "class": c5, "name": n54, "tier": "5.4", "deb": (at 32 deb)})
                ((and (>= x (at 33 et))(< x (at 34 et))) { "class": c5, "name": n55, "tier": "5.5", "deb": (at 33 deb)})
                ((and (>= x (at 34 et))(< x (at 35 et))) { "class": c5, "name": n56, "tier": "5.6", "deb": (at 34 deb)})
                ((and (>= x (at 35 et))(< x (at 36 et))) { "class": c5, "name": n57, "tier": "5.7", "deb": (at 35 deb)})
                ;;Class TYCOON
                ((and (>= x (at 36 et))(< x (at 37 et))) { "class": c6, "name": n61, "tier": "6.1", "deb": (at 36 deb)})
                ((and (>= x (at 37 et))(< x (at 38 et))) { "class": c6, "name": n62, "tier": "6.2", "deb": (at 37 deb)})
                ((and (>= x (at 38 et))(< x (at 39 et))) { "class": c6, "name": n63, "tier": "6.3", "deb": (at 38 deb)})
                ((and (>= x (at 39 et))(< x (at 40 et))) { "class": c6, "name": n64, "tier": "6.4", "deb": (at 39 deb)})
                ((and (>= x (at 40 et))(< x (at 41 et))) { "class": c6, "name": n65, "tier": "6.5", "deb": (at 40 deb)})
                ((and (>= x (at 41 et))(< x (at 42 et))) { "class": c6, "name": n66, "tier": "6.6", "deb": (at 41 deb)})
                ((and (>= x (at 42 et))(< x (at 43 et))) { "class": c6, "name": n67, "tier": "6.7", "deb": (at 42 deb)})
                ;;Class DEMIURG
                ((and (>= x (at 43 et))(< x (at 44 et))) { "class": c7, "name": n71, "tier": "7.1", "deb": (at 43 deb)})
                ((and (>= x (at 44 et))(< x (at 45 et))) { "class": c7, "name": n72, "tier": "7.2", "deb": (at 44 deb)})
                ((and (>= x (at 45 et))(< x (at 46 et))) { "class": c7, "name": n73, "tier": "7.3", "deb": (at 45 deb)})
                ((and (>= x (at 46 et))(< x (at 47 et))) { "class": c7, "name": n74, "tier": "7.4", "deb": (at 46 deb)})
                ((and (>= x (at 47 et))(< x (at 48 et))) { "class": c7, "name": n75, "tier": "7.5", "deb": (at 47 deb)})
                ((and (>= x (at 48 et))(< x (at 49 et))) { "class": c7, "name": n76, "tier": "7.6", "deb": (at 48 deb)})
                { "class": c7, "name": n77, "tier": "7.7", "deb": (at 49 deb)}
            )
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_IzCullable:bool (input:object{UtilityAtsV3.Awo})
        (let*
            (
                (present-time:time (at "block-time" (chain-data)))
                (stored-time:time (at "cull-time" input))
                (diff:decimal (diff-time present-time stored-time))
            )
            (if (>= diff 0.0)
                true
                false
            )
        )
    )
    (defun UC_IzUnstakeObjectValid:bool (input:object{UtilityAtsV3.Awo})
        (let*
            (
                (values:[decimal] (at "reward-tokens" input))
                (sum-values:decimal (fold (+) 0.0 values))
            )
            (if (> sum-values 0.0)
                true
                false
            )
        )
    )
    (defun UC_KickStartIndex:decimal (rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Pure compute (audit finding #11M / M2): the index a KickStart with these \
            \ inputs would produce (sum(rt-amounts) / rbt-request-amount). Returns -1.0 \
            \ if rbt-request-amount is not strictly positive, so callers can bound-check \
            \ the result without a raw division-by-zero crash before their own \
            \ (> rbt-request-amount 0.0) enforce gets a chance to fire with a clearer \
            \ message - -1.0 trivially fails a >= floor and trivially passes a <= \
            \ ceiling, deferring to that later, better-worded rejection either way."
        (if
            (> rbt-request-amount 0.0)
            (/ (fold (+) 0.0 rt-amounts) rbt-request-amount)
            -1.0
        )
    )
    (defun UCv_MakeHardIntervals:[integer] (start:integer growth:integer)
        @doc "Creates a Soft Interval List"
        (enforce (= (mod start growth) 0) (format "{} must be divisible by {} and it is not" [start growth]))
        (let*
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (chain:[integer]
                    (fold
                        (lambda
                            (acc:[integer] item:integer)
                            (ref-U|LST::UC_AppL acc (+ (ref-U|LST::UC_LE acc) item))
                        )
                        [start]
                        (make-list 48 growth)
                    )
                )
                (big:integer (* 7 growth))
                (last:integer (ref-U|LST::UC_LE chain))
                (very-last:integer (+ last big))
                (final-lst:[integer] (ref-U|LST::UC_AppL chain very-last))
            )
            (reverse final-lst)
        )
    )
    (defun UCv_MakeSoftIntervals:[integer] (start:integer growth:integer)
        @doc "Creates a Soft Interval List of Integers \
            \ Used when creating|setting-up an Autostake Pair"
        (enforce (= (mod start growth) 0) (format "{} must be divisible by {} and it is not" [start growth]))
        (enforce (= (mod growth 3) 0) (format "{} must be divisible by 3 and it is not" [growth]))
        (let*
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (small:integer (/ growth 3))
                (medium:integer (* small 2))
                (chain1:[integer] (fold (lambda (acc:[integer] item:integer) (ref-U|LST::UC_AppL acc (+ (ref-U|LST::UC_LE acc) item))) [start] (make-list 6 growth)))
                (chain2:[integer] (fold (lambda (acc:[integer] item:integer) (ref-U|LST::UC_AppL acc (+ (ref-U|LST::UC_LE acc) item))) chain1 (+ (make-list 5 medium) (make-list 2 small))))
                (chain3:[integer] (fold (lambda (acc:[integer] item:integer) (ref-U|LST::UC_AppL acc (+ (ref-U|LST::UC_LE acc) item))) chain2 (+ (make-list 5 medium) (make-list 2 small))))
                (chain4:[integer] (fold (lambda (acc:[integer] item:integer) (ref-U|LST::UC_AppL acc (+ (ref-U|LST::UC_LE acc) item))) chain3 (+ (make-list 5 medium) (make-list 2 small))))
                (chain5:[integer] (fold (lambda (acc:[integer] item:integer) (ref-U|LST::UC_AppL acc (+ (ref-U|LST::UC_LE acc) item))) chain4 (+ (make-list 5 medium) (make-list 2 small))))
                (chain6:[integer] (fold (lambda (acc:[integer] item:integer) (ref-U|LST::UC_AppL acc (+ (ref-U|LST::UC_LE acc) item))) chain5 (+ (make-list 5 medium) (make-list 2 small))))
                (chain7:[integer] (fold (lambda (acc:[integer] item:integer) (ref-U|LST::UC_AppL acc (+ (ref-U|LST::UC_LE acc) item))) chain6 (+ (make-list 5 medium) (make-list 2 small))))
                (last:integer (ref-U|LST::UC_LE chain7))
                (very-last:integer (+ last 24))
                (final-lst:[integer] (ref-U|LST::UC_AppL chain7 very-last))
            )
            (reverse final-lst)
        )
    )
    (defun UC_MultiReshapeUnstakeObject:[object{UtilityAtsV3.Awo}] (input:[object{UtilityAtsV3.Awo}] remove-position:integer)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[object{UtilityAtsV3.Awo}] item:object{UtilityAtsV3.Awo})
                    (ref-U|LST::UC_AppL
                        acc
                        (UC_ReshapeUnstakeObject item remove-position)
                    )
                )
                []
                input
            )
        )
    )
    (defun UC_PromilleSplit:[decimal] (promille:decimal input:decimal input-precision:integer)
        @doc "Helper Function used in the <ATS|C_ColdRecovery> Function"
        (let*
            (
                (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                (fee:decimal (ref-U|DEC::UCv_Promille input promille input-precision))
                (remainder:decimal (- input fee))
            )
            [remainder fee]
        )
    )
    (defun UC_ReshapeUnstakeObject:object{UtilityAtsV3.Awo} (input:object{UtilityAtsV3.Awo} remove-position:integer)
        @doc "Drops <remove-position> from <input>'s reward-tokens array and folds its value into slot 0 \
            \ (the primal RT), mirroring the pool-level primal-RT swap in ATSU.XI_RemoveSecondary. \
            \ Fix (audit finding #1C / C2c): this MUST run unconditionally — an all-zero (never-touched) \
            \ Awo still needs its array shrunk to match the post-removal reward-token list, or every later \
            \ read (URCx_PosObjSt, XIv_StoreUnstakeObject) that structurally compares it against a freshly \
            \ length-derived zero/negative sentinel will see a stale, longer array and misclassify an \
            \ empty slot as permanently occupied. UCv_SolidifyUnstakeObject is safe to run unconditionally: \
            \ merging a 0.0 removee into slot 0 is a no-op on the value, it only ever needs to shrink the array."
        (UCv_SolidifyUnstakeObject input remove-position)
    )
    (defun UCv_SolidifyUnstakeObject:object{UtilityAtsV3.Awo} (input:object{UtilityAtsV3.Awo} remove-position:integer)
        (let*
            (
                (values:[decimal] (at "reward-tokens" input))
                (cull-time:time (at "cull-time" input))
                (how-many-rts:integer (length values))
            )
            (enforce (and (> remove-position 0) (< remove-position how-many-rts)) "Invalid <remove-position>")
            (let*
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (primal:decimal (at 0 (at "reward-tokens" input)))
                    (removee:decimal (at remove-position (at "reward-tokens" input)))
                    (remove-lst:[decimal] (ref-U|LST::UC_RemoveItemAt values remove-position))
                    (new-values:[decimal] (ref-U|LST::UC_ReplaceAt remove-lst 0 (+ primal removee)))
                )
                { "reward-tokens"   : new-values
                , "cull-time"       : cull-time}
            )
        )
    )
    (defun UCv_SplitBalanceWithBooleans:[decimal] (precision:integer amount:decimal milestones:integer boolean:[bool])
        @doc "Splits an Amount according to specific ATS-Pair Parameters related to the list of Reward Tokens \
            \ Helper function used in the Autostake Module"
        (enforce (> milestones 0) "Cannot split with zero milestones")
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (split:decimal (floor (/ amount (dec milestones)) precision))
                (tr-nr:integer (length (ref-U|LST::UC_Search boolean true)))
                (multiply:integer (- milestones 1))
            )
            (enforce (> split 0.0) (format "Amount {} to small to split into {} milestones" [amount milestones]))
            (enforce (= milestones tr-nr) "Input Lists do not sync")
            (let*
                (
                    (big-chunk:decimal (floor (* split (dec multiply)) precision))
                    (last-split:decimal (floor (- amount big-chunk) precision))
                )
                (enforce (= (+ big-chunk last-split) amount) (format "Amount of {} could not be split into {} milestones succesfully" [amount milestones]))
                (let*
                    (
                        (output-without-last:[decimal]
                            (fold
                                (lambda
                                    (acc:[decimal] truth:bool)
                                    (if truth
                                        (ref-U|LST::UC_AppL acc split)
                                        (ref-U|LST::UC_AppL acc 0.0)
                                    )
                                )
                                []
                                boolean
                            )
                        )
                        (positions-lst:[integer] (ref-U|LST::UC_Search output-without-last split))
                        (last-element-value-position:integer (at (- (length positions-lst) 1) positions-lst) )
                        (output:[decimal] (ref-U|LST::UC_ReplaceAt output-without-last last-element-value-position last-split))
                    )
                    output
                )
            )
        )
    )
    (defun UC_SplitByIndexedRBT:[decimal]
        (
            rbt-amount:decimal
            pair-rbt-supply:decimal
            index:decimal
            resident-amounts:[decimal]
            rt-precisions:[integer]
        )
        @doc "Called from ATS.ATS|UC_RTSplitAmounts: Splits a RBT value, the <rbt-amount>, using following inputs: \
            \ Reward-Bearing-Token supply <rbt-supply> of an <atspair> (read below) \
            \ The <index> of the <atspair> (read below) \
            \ A list <resident-amounts> respresenting amounts of resident Reward-Tokens of the <atpsair> \
            \ A list <rt-precision-lst> representing the precision of these Reward-Tokens \
            \ \
            \ Resulting a decimal list of Reward-Token Values coresponding to the input <rbt-amount> \
            \ The Actual computation takes place in the UTILITY Module in the <UC_SplitByIndexedRBT> Function"
        (if (= rbt-amount pair-rbt-supply)
            resident-amounts
            (let*
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-U|INT:module{OuronetIntegersV2} U|INT)
                    (max-precision:integer (ref-U|INT::UEV_MaxInteger rt-precisions))
                    (max-pp:integer (at 0 (ref-U|LST::UC_Search rt-precisions max-precision)))
                    (indexed-rbt:decimal (floor (* rbt-amount index) max-precision))
                    (resident-sum:decimal (fold (+) 0.0 resident-amounts))
                    (preliminary-output:[decimal]
                        (fold
                            (lambda
                                (acc:[decimal] index:integer)
                                (ref-U|LST::UC_AppL acc (floor (* (/ (at index resident-amounts) resident-sum) indexed-rbt) (at index rt-precisions)))
                            )
                            []
                            (enumerate 0 (- (length resident-amounts) 1))
                        )
                    )
                    (po-sum:decimal (fold (+) 0.0 preliminary-output))
                    (black-sheep:decimal (at max-pp preliminary-output))
                    (white-sheep:decimal (- indexed-rbt (- po-sum black-sheep)))
                    (output:[decimal] (ref-U|LST::UC_ReplaceAt preliminary-output max-pp white-sheep))
                )
                output
            )
        )
    )
    (defun UC_IzStoicTagIndexChar:bool (c:string)
        @doc "True when <c> is a lowercase letter or digit (StoicTag index charset)."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ncl:[string] (ref-U|CT::CT_NON_CAPITAL_LETTERS))
                (n:[string] (ref-U|CT::CT_NUMBERS))
            )
            (or (contains c ncl) (contains c n))
        )
    )
    (defun UC_IzStoicTagIndex:bool (name:string)
        @doc "True when <name> meets Autostake index rules (charset 0, prohibited chars, length) but lowercase letters and digits only."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (aipc:[string] (ref-U|CT::CT_ACCOUNT_ID_PROH-CHAR))
                (min:integer (ref-U|CT::CT_MIN_DESIGNATION_LENGTH))
                (max:integer (ref-U|CT::CT_ACCOUNT_ID_MAX_LENGTH))
                (al:integer (length name))
            )
            (fold (and) true
                [
                    (is-charset 0 name)
                    (not (contains name aipc))
                    (fold
                        (lambda (ok:bool c:string) (and ok (UC_IzStoicTagIndexChar c)))
                        true
                        (str-to-list name)
                    )
                    (>= al min)
                    (<= al max)
                ]
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_AutostakeIndex (ats:string)
        @doc "Enforces that ATS Index Name <account> ID meets charset and length requirements"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (aipc:[string] (ref-U|CT::CT_ACCOUNT_ID_PROH-CHAR))
                (min:integer (ref-U|CT::CT_MIN_DESIGNATION_LENGTH))
                (max:integer (ref-U|CT::CT_ACCOUNT_ID_MAX_LENGTH))
                (al:integer (length ats))
            )
            (enforce
                (is-charset 0 ats)
                (format "Account ID does not conform to the required charset: {}" [ats])
            )
            (enforce
                (not (contains ats aipc))
                (format "Account ID contained a prohibited character: {}" [ats])
            )
            (enforce
                (ref-U|DALOS::UC_IzStringANC ats false false)
                "Atspair does not conform character-wise (Alphanumeric)"
            )
            (enforce
                (and
                    (>= al min)
                    (<= al max)
                )
                "Atspair does not conform to the ATS-Pair Standards for Size!"
            )
        )
    )
    (defun UEV_StoicTagIndex (name:string)
        @doc "Enforces StoicTag name: same rules as UEV_AutostakeIndex, but no capital letters."
        (enforce
            (UC_IzStoicTagIndex name)
            (format "StoicTag name {} does not conform to index standards (Autostake rules, lowercase only)" [name])
        )
    )
    (defun UEV_UniqueAtspair (ats:string)
        @doc "Enforces that an Unique Account designating an <ats> ID meets charset and length requirements \
            \ Unique Accounts are ATS-IDs (composed of the Index Name - Unique Identifier)"
        (UEV_AutostakeIndex (take (- (length ats) 13) ats))
    )
    ;;
    (defun UEV_CRF|Positions (fee-positions:integer)
        @doc "Enforces <fee-positions> are either -1 or betwee 1 and 7 inclusive"
        (enforce (contains fee-positions (+ [-1] (enumerate 1 7))) (format "Fee Position {} is invalid" [fee-positions]))
    )
    (defun UEV_CRF|FeeThresholds (fee-thresholds:[decimal] c-rbt-prec:integer)
        @doc "Enforces <fee-thresholds> has between 1 and 100 entries (a doc-wording \
            \ fix, audit finding #15M / M6 - this bounds the COUNT of thresholds, not \
            \ their values; thresholds are raw cold-RBT token amounts with no inherent \
            \ value ceiling), each entry conforms with the C-RBT precision, and entries \
            \ are strictly increasing one after another."
        (let
            (
                (size:integer (length fee-thresholds))
            )
            (enforce
                (and
                    (>= size 1)
                    (<= size 100)
                )
                "Between 1 and 100 Cold Recovery Fee Threhsolds allowed"
            )
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (fee-threshold:decimal (at idx fee-thresholds))
                        )
                        (if (<= idx (- size 2))
                            (let
                                (
                                    (next-fee-threshold:decimal (at (+ idx 1) fee-thresholds))
                                )
                                (enforce (< fee-threshold next-fee-threshold) "Invalid Fee Threhsolds Chain")
                            )
                            true
                        )
                        (enforce (= (floor fee-threshold c-rbt-prec) fee-threshold) "Invalid Fee Threshold Precision")
                    )
                )
                (enumerate 0 (- size 1))
            )
        )
    )
    (defun UEV_CRF|FeeArray (fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        (let
            (
                (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                (l-ft:integer (length fee-thresholds))
                (l-fa:integer (length fee-array))
                (not-zero-fee-array:bool
                    (not
                        (fold (and) true
                            [
                                (= l-ft 1)
                                (= (at 0 fee-thresholds) 0.0)
                                (= l-fa 1)
                                (= (length (at 0 fee-array)) 1)
                                (= (at 0 (at 0 fee-array)) 0.0)
                            ]
                        )
                    )
                )
            )
            (ref-U|DEC::UEV_DecimalArray fee-array)
            (if not-zero-fee-array
                (do
                    (if (= fee-positions -1)
                        (enforce (= l-fa 1) "The input <fee-array> must be of length 1")
                        (enforce (= l-fa fee-positions) (format "The input <fee-array> must be of length {}" [fee-positions]))
                    )
                    (enforce
                        (= (length (at 0 fee-array)) (+ l-ft 1))
                        "Inner Lists of the <fee-array> are incompatible with the <fee-thresholds> length"
                    )
                )
                true
            )
            (map
                (lambda
                    (fee:decimal)
                    (UEV_Fee fee)
                )
                (fold (+) [] fee-array)
            )
        )
    )
    (defun UEV_Fee (fee:decimal)
        (enforce
            (fold (and) true [(>= fee 0.0)(<= fee 999.0)(= (floor fee 4) fee)])
            "Invalid Autostake Fee Value"
        )
    )
    (defun UEV_Decay (decay:integer)
        (enforce
            (and
                (>= decay 1)
                (<= decay 9125)
            )
            "No More than 25 years (9125 days) can be set for Decay Period"
        )
    )
    (defun UEV_HibernationFees (peak:decimal decay:decimal)
        @doc "Fix (audit finding #10M / M1): removed a stray, malformed 7th predicate \
            \ (`(= () 0.0)` - comparing Pact's unit value against 0.0, always false) that \
            \ made this enforce fail unconditionally for every input. Owner confirmed \
            \ (2026-08-17) there was no intended 7th bound - simple debris, deleted."
        (enforce
            (fold (and) true
                [
                    (= (floor peak 4) peak)
                    (> peak 0.0)
                    (<= peak 800.0)
                    (= (floor decay 4) decay)
                    (> decay 0.0)
                    (< decay 1.0)
                ]
            )
            "Invalid Hibernation Fees"
        )
        (let
            (
                (scale:decimal 10000.0)
                (scaled-a:integer (floor (* peak scale)))
                (scaled-b:integer (floor (* decay scale)))
            )
            (enforce
                (= (mod scaled-a scaled-b ) 0)
                "Invalid Hibernation Fees via Scaled Division"
            )
        )
    )
    ;;
    (defun UEV_ColdDurationParameters (soft-or-hard:bool base:integer growth:integer)
        @doc "Fix (audit finding #9H / H4): the soft branch's enforce carried a stray \
            \ 3rd argument built from an incomplete `format` call (no {} placeholder, \
            \ no substitution list) - a hard arity error that made the soft-duration \
            \ path unconditionally uncallable. Collapsed to a single, correctly-formed \
            \ 2-arg enforce, matching the UCv_MakeSoftIntervals convention above. Fix \
            \ (audit finding #16M / M7): neither branch required growth > 0. The \
            \ duration table these parameters build (UCv_MakeSoftIntervals / \
            \ UCv_MakeHardIntervals) is designed to always decrease wait-time as elite \
            \ tier increases, never the reverse; a negative growth silently inverted \
            \ that curve, so added an explicit floor to both branches."
        (if soft-or-hard
            (enforce
                (fold (and) true
                    [
                        (> growth 0)
                        (= (mod base growth) 0)
                        (= (mod growth 3) 0)
                    ]
                )
                (format "Invalid Soft Cold Recovery Duration Parameters: Base {} Growth {}" [base growth])
            )
            (enforce
                (and
                    (> growth 0)
                    (= (mod base growth) 0)
                )
                "Invalid Hard Cold Recovery Duration Parameters"
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/10_U_DPTF.pact =============

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface UtilityDptfV2
    @doc "Exported Utility Functions for the DPTF Module \
        \ Commented Functions are internal use only and have no use outside the module"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;
    (defschema DispoData
        @doc "Stores the information needed to compute the maximum Negative Ouro an Account is allowed to overconsume"
        elite-auryn-amount:decimal
        auryndex-value:decimal
        elite-auryndex-value:decimal
        major-tier:integer
        minor-tier:integer
        ouroboros-precision:integer
    )
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    (defun UDC_EmptyDispo:object{DispoData} ())
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_TwoSplitter:[integer] (input:integer))
    (defun UC_FourSplitter:[integer] (input:integer))
    (defun UC_EightSplitter:[integer] (input:integer))
    ;;
    (defun UC_OuroDispo:decimal (input:object{DispoData}))
    (defun UC_VolumetricTax (precision:integer amount:decimal))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|DPTF GOV
    @doc "DPTF fungible-token utility library (implements UtilityDptfV2). Provides \
        \ even-split helpers that divide an integer into 2/4/8 near-equal parts, the \
        \ DispoData schema plus helpers for computing an account's max negative-Ouro \
        \ overconsumption, and UC_VolumetricTax for \
        \ the logarithmic volumetric transaction tax."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements UtilityDptfV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|DPTF_ADMIN)))
    (defcap GOV|U|DPTF_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    ;;
    ;;
    (defun UDC_EmptyDispo:object{UtilityDptfV2.DispoData} ()
        {"elite-auryn-amount"           :0.0
        ,"auryndex-value"               :-1.0
        ,"elite-auryndex-value"         :-1.0
        ,"major-tier"                   :0
        ,"minor-tier"                   :0
        ,"ouroboros-precision"          :24}
    )
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    (defun UC_TwoSplitter:[integer] (input:integer)
        (let
            (
                (dec-in:decimal (dec input))
                (div:decimal (/ dec-in 2.0))
                (rest:decimal (- div (dec (floor div))))
            )
            (cond
                ((= rest 0.0) (make-list 2 (floor div)))
                ((= rest 0.5) (+ (make-list 1 (+ 1 (floor div))) (make-list 1 (floor div))))
                [0 0 0 0]
            )
        )
    )
    (defun UC_FourSplitter:[integer] (input:integer)
        (let
            (
                (dec-in:decimal (dec input))
                (div:decimal (/ dec-in 4.0))
                (rest:decimal (- div (dec (floor div))))
            )
            (cond
                ((= rest 0.0) (make-list 4 (floor div)))
                ((= rest 0.25) (+ (make-list 1 (+ 1 (floor div))) (make-list 3 (floor div))))
                ((= rest 0.5) (+ (make-list 2 (+ 1 (floor div))) (make-list 2 (floor div))))
                ((= rest 0.75) (+ (make-list 3 (+ 1 (floor div))) (make-list 1 (floor div))))
                [0 0 0 0]
            )
        )
    )
    (defun UC_EightSplitter:[integer] (input:integer)
        (let
            (
                (dec-in:decimal (dec input))
                (div:decimal (/ dec-in 8.0))
                (rest:decimal (- div (dec (floor div))))
            )
            (cond
                ((= rest 0.0) (make-list 8 (floor div)))
                ((= rest 0.125) (+ (make-list 1 (+ 1 (floor div))) (make-list 7 (floor div))))
                ((= rest 0.25) (+ (make-list 2 (+ 1 (floor div))) (make-list 6 (floor div))))
                ((= rest 0.375) (+ (make-list 3 (+ 1 (floor div))) (make-list 5 (floor div))))
                ((= rest 0.5) (+ (make-list 4 (+ 1 (floor div))) (make-list 4 (floor div))))
                ((= rest 0.625) (+ (make-list 5 (+ 1 (floor div))) (make-list 3 (floor div))))
                ((= rest 0.75) (+ (make-list 6 (+ 1 (floor div))) (make-list 2 (floor div))))
                ((= rest 0.875) (+ (make-list 7 (+ 1 (floor div))) (make-list 1 (floor div))))
                [0 0 0 0]
            )
        )
    )
    (defun UC_OuroDispo:decimal (input:object{UtilityDptfV2.DispoData})
        (let
            (
                (ea-amount:decimal (at "elite-auryn-amount" input))
                (a-idx:decimal (at "auryndex-value" input))
                (ea-idx:decimal (at "elite-auryndex-value" input))
                (major:decimal (dec (at "major-tier" input)))
                (minor:decimal (dec (at "minor-tier" input)))
                (o-prec:integer (at "ouroboros-precision" input))

                (olp:decimal
                    (if (< major 3.0)
                        0.0
                        (floor (+ (/ (- (+ (* (- major 1) 7.0) minor) 15.0) 10.0) 11.5) 1)
                    )
                )
                (olpd:decimal (floor (/ olp 100.0) 3))
            )
            (if (or (= -1.0 a-idx) (= -1.0 ea-idx))
                0.0
                (floor (fold (*) 1.0 [a-idx ea-idx ea-amount olpd]) o-prec)
            )
        )
    )
    (defun UC_VolumetricTax (precision:integer amount:decimal)
        @doc "Computes Volumetric-Transaction-Tax (VTT) value, given an Input Decimal <amount>"
        (let*
            (
                (amount-int:integer (floor amount))
                (amount-str:string (int-to-str 10 amount-int))
                (amount-str-rev-lst:[string] (reverse (str-to-list amount-str)))
                (amount-dec-rev-lst:[decimal] (map (lambda (x:string) (dec (str-to-int 10 x))) amount-str-rev-lst))
                (integer-lst:[integer] (enumerate 0 (- (length amount-dec-rev-lst) 1)))
                (logarithm-lst:[decimal] (map (lambda (u:integer) (UCx_VolumetricPermile precision u)) integer-lst))
                (multiply-lst:[decimal] (zip (lambda (x:decimal y:decimal) (* x y)) amount-dec-rev-lst logarithm-lst))
                (volumetric-fee:decimal (floor (fold (+) 0.0 multiply-lst) precision))
            )
            volumetric-fee
        )
    )
    (defun UCx_VolumetricPermile:decimal (precision:integer unit:integer)
        @doc "Auxiliary computation function needed to compute the volumetric the VTT"
        (let*
            (
                (logarithm-base:decimal (if (= unit 0) 0.0 (dec (str-to-int 10 (concat (make-list unit "7"))))))
                (logarithm-number:decimal (dec (^ 10 unit)))
                (logarithm:decimal (floor (log logarithm-base logarithm-number) precision))
                (volumetric-permile:decimal (floor (* logarithm-number (/ logarithm 1000.0)) precision))
            )
            volumetric-permile
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/11_U_VST.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface UtilityVstV2
    @doc "Exported Utility Functions for the VST Module"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_MakeVestingDateList:[time] (offset:integer duration:integer milestones:integer))
    (defun UCv_SplitBalanceForVesting:[decimal] (precision:integer amount:decimal milestones:integer))
    (defun UC_VestingID:[string] (dptf-name:string dptf-ticker:string))
    (defun UC_SleepingID:[string] (dptf-name:string dptf-ticker:string))
    (defun UC_HibernationID:[string] (dptf-name:string dptf-ticker:string))
        ;;
    (defun UC_FrozenID:[string] (dptf-name:string dptf-ticker:string))
    (defun UC_ReservedID:[string] (dptf-name:string dptf-ticker:string))
        ;;
    (defun UC_EquityID:[string] (sft-name:string sft-ticker:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_Milestone (milestones:integer))
    (defun UEV_MilestoneWithTime (offset:integer duration:integer milestones:integer upper-limit-in-seconds:integer))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|VST GOV
    @doc "Vesting (VST) utility library (implements UtilityVstV2). Builds milestone date \
        \ lists and splits balances across milestones, and generates special token \
        \ name/ticker id pairs for the various locked states — Vested, Sleeping, \
        \ Hibernating, Frozen, Reserved, and Equity — via a shared helper. Validators bound \
        \ milestone counts (1-250) and durations (max 25 years)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements UtilityVstV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|VST_ADMIN)))
    (defcap GOV|U|VST_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    (defun UC_MakeVestingDateList:[time] (offset:integer duration:integer milestones:integer)
        @doc "Makes a Times list with unvesting milestones according to vesting parameters"
        (let*
            (
                (present-time:time (at "block-time" (chain-data)))
                (first-time:time (add-time present-time offset))
                (times:[time] [first-time])
            )
            (if (= milestones 1)
                [(add-time first-time duration)]
                (fold
                    (lambda
                        (acc:[time] idx:integer)
                        (let*
                            (
                                (to-add:integer (* idx duration))
                                (new-time:time (add-time first-time to-add))
                            )
                            (+ acc [new-time])
                        )
                    )
                    times
                    (enumerate 1 (- milestones 1))
                )
            )

        )
    )
    (defun UCv_SplitBalanceForVesting:[decimal] (precision:integer amount:decimal milestones:integer)
        @doc "Splits an Amount according to vesting parameters"
        (UEV_Milestone milestones)
        ;;UNREACHABLE: UEV_Milestone on the line above restricts <milestones> to [1,250], so the
        ;;zero case is already rejected with "Milestone splitting number 0 is out of bounds"
        ;;before this line is reached. Fail-closed backstop, not a live guard - no input can pin
        ;;it. Verified in REPL/modules/UTILITIES.repl <<UTIL-13>>.
        (enforce (!= milestones 0) "Cannot split with zero milestones")
        (let
            (
                (split:decimal (floor (/ amount (dec milestones)) precision))
                (multiply:integer (- milestones 1))
            )
            ;;#74L fix: typo "to small" -> "too small" (message text only, no logic change).
            (enforce (> split 0.0) (format "Amount {} too small to split into {} milestones" [amount milestones]))
            (let*
                (
                    (big-chunk:decimal (floor (* split (dec multiply)) precision))
                    (last-split:decimal (floor (- amount big-chunk) precision))
                )
                (enforce (= (+ big-chunk last-split) amount) (format "Amount of {} could not be split into {} milestones succesfully" [amount milestones]))
                (+ (make-list multiply split) [last-split])
            )
        )
    )
    ;;
    (defun UC_VestingID:[string] (dptf-name:string dptf-ticker:string)
        (UCx_SpecialID dptf-name dptf-ticker "Vested" "V")
    )
    (defun UC_SleepingID:[string] (dptf-name:string dptf-ticker:string)
        (UCx_SpecialID dptf-name dptf-ticker "Sleeping" "Z")
    )
    (defun UC_HibernationID:[string] (dptf-name:string dptf-ticker:string)
        (UCx_SpecialID dptf-name dptf-ticker "Hibernating" "H")
    )
    ;;
    (defun UC_FrozenID:[string] (dptf-name:string dptf-ticker:string)
        (UCx_SpecialID dptf-name dptf-ticker "Frozen" "F")
    )
    (defun UC_ReservedID:[string] (dptf-name:string dptf-ticker:string)
        (UCx_SpecialID dptf-name dptf-ticker "Reserved" "R")
    )
    ;;
    (defun UC_EquityID:[string] (sft-name:string sft-ticker:string)
        (UCx_SpecialID sft-name sft-ticker "Equity" "E")  
    )
    ;;
    (defun UCx_SpecialID:[string] (dptf-name:string dptf-ticker:string special-name:string special-prefix:string)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (max-name:integer (ref-U|CT::CT_MAX_TOKEN_NAME_LENGTH))
                (max-ticker:integer (ref-U|CT::CT_MAX_TOKEN_TICKER_LENGTH))
                (caron:string "^")
                (s1:string (+ special-name caron))
                (s2:string (+ special-prefix BAR))
                (l1:integer (- max-name (length s1)))
                (l2:integer (- max-ticker (length s2)))
                (vested-name:string (concat [s1 (take l1 dptf-name)]))
                (vested-ticker:string (concat [s2 (take l2 dptf-ticker)]))
            )
            [vested-name vested-ticker]
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_Milestone (milestones:integer)
        @doc "Restrict Milestone integer between 1 and 250 Milestones"
        (enforce
            (and (>= milestones 1) (<= milestones 250))
            (format "Milestone splitting number {} is out of bounds"[milestones])
        )
    )
    (defun UEV_MilestoneWithTime (offset:integer duration:integer milestones:integer upper-limit-in-seconds:integer)
        @doc "Validates Milestone duration to be lower than 25 years"
        (UEV_Milestone milestones)
        (enforce
            (and (>= offset 0) (>= duration 0))
            "Offset and Duration cannot be negative"
        )
        (enforce
            (<= (+ (* milestones duration ) offset) upper-limit-in-seconds)
            "Upper Lock Time Exceeded"
        )
        ;;<upper-limit-in-seconds> = 788400000 for Vesting and Sleeping
        ;;<upper-limit-in-seconds> = 3153600000 for Hibernating
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/12_U_SWP.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface UtilitySwpV2
    @doc "Exported Utility Functions for the SWP Module"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;
    ;;Raw Swap INPUT Data - <drsi> and <irsi>
    ;;Data needed to perform the actual swap computation with no fees.
    (defschema DirectRawSwapInput
        A:decimal
        X:[decimal]
        input-amounts:[decimal]
        input-positions:[integer]
        output-position:integer
        output-precision:integer
        weights:[decimal]
    )
    (defschema InverseRawSwapInput
        A:decimal
        X:[decimal]
        output-amount:decimal
        output-position:integer
        input-position:integer
        input-precision:integer
        weights:[decimal]
    )
    ;;Swap INPUT Data - <dsid> and <rsid>
    (defschema DirectSwapInputData
        ;;Stores Input Data for a Direct Swap
        input-ids:[string]
        input-amounts:[decimal]
        output-id:string
    )
    (defschema ReverseSwapInputData
        ;;Stores Input Data fora Reverse Swap
        output-id:string
        output-amount:decimal
        input-id:string
    )
    ;;Swap OUTPUT Data - Always Taxed (with swap fees)
    (defschema DirectTaxedSwapOutput
        ;;Direct Taxed Swap starts from <Brutto Input-IDs Amounts>:[decimal] and yields in this order:
        lp-fuel:[decimal]           ;;<Input-IDs-Amounts> going fueling the Pool, in a full List, that is:
                                    ;;Contains 0.0 for Pool Token IDs not involved in the Input.
        o-id:string                 ;;Output-ID of the Direct-Swap
        o-id-special:decimal        ;;Output-ID-amount that goes to Special-Targets
        o-id-liquid:decimal         ;;Output-ID-amount that is used for Stoa Liquid Staking Boost
        o-id-netto:decimal          ;;Output-ID-amount resulted after the Direct Taxed Swap (END-RESULT)
    )
    (defschema InverseTaxedSwapOutput
        ;;Reverse Taxed Swap starts from <Netto Output-ID Amount>:decimal and yields
        o-id-liquid:decimal         ;;Output-ID-amount that would be used by Stoa Liquid Staking
        o-id-special:decimal        ;;Output-ID-amount that would go to Special-Targets
        lp-fuel:[decimal]           ;;Since the Inverse Swap can be computed for a single Input,
                                    ;;Contains the <Input-ID-Amount> of the Pool Token the Reverse Swap computes for
                                    ;;Therefore the List contains a single non zero element, 
                                    ;;filled with 0.0 for the rest of the Pool Tokens
        i-id:string                 ;;Input-ID of the Reverse Swap; It is also the id of the Single non Zero Value in <lp-fuel>
        i-id-brutto:decimal         ;;Input-ID-amount of the Token the Reverse Taxed Swap computed for (END-RESULT).
    )
    ;;
    (defschema SwapFeez
        lp:decimal
        special:decimal
        boost:decimal
    )
    ;;Virtual Swap Engine (VSE) Schema
    ;;The Virtual Swap Engine is used to perform Swap Computations on Data 
    ;;(that can be either true Swap Pool Data or Virtual Data), Performing always Direct Swaps, 
    ;;The Swaps being carried out are stored in the <swaps> field in an Object{VirtualSwap}
    ;;with their Input-Ids, Input-Amounts, and Output-ID;
    ;;As Supply, it always stores the "current" state of the virtual swap in the <account-supply> and <pool-supply>
    (defschema VirtualSwapEngine
        ;;Virtual Token IDs
        v-tokens:[string]           ;;Stores the Token IDs the VSE is operating with.
                                    ;;These are also the Pool Tokens, in this exact order
        v-prec:[integer]            ;;Decimal Precision of the Pool Tokens
        ;;
        ;;Virtual Account
        account:string              ;;The Account Performing the Virtual Swap (needed to fetch its Tier for Fee Reduction Purposes)
        account-supply:[decimal]    ;;The Virtual Token Supply of the Virtual Account. Gets updated with every Virtual Swap being executed
        ;;
        ;;Virtual Pool
        swpair:string               ;;While the VirtualSwapEngine doesnt operate on Swpair Data, storing the swpair ID is necesary
                                    ;;Because through it, the Pool Tokens can be known, and through them
                                    ;;the positions of the <input-ids>
        X:[decimal]                 ;;Token Supply of the Virtual Pool
        A:decimal                   ;;Amplifier supply of the Virtual Pool
        W:[decimal]                 ;;Weights of the Virtual Pool
        F:object{SwapFeez}          ;;Fee Values of the Virtual Pool
        ;;
        ;;Swap-Results - use <v-tokens> ID Order
        fuel:[decimal]              ;;Stores the Amounts that would go as Fuel for the Pool, boosting LP Token Value
        special:[decimal]           ;;Stores the Amounts that would go to the Pool Special Targets
        boost:[decimal]             ;;Stores the Amounts that would go to Stoa Liquid Staking Boost
        ;;
        ;;Virtual Swap Chains
        swaps:[object{DirectSwapInputData}] ;;Stores the Data of the Swaps in a Chain
    )
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;;
    (defun UDC_DirectRawSwapInput:object{DirectRawSwapInput} (a:decimal b:[decimal] c:[decimal] d:[integer] e:integer f:integer g:[decimal]))
    (defun UDC_InverseRawSwapInput:object{InverseRawSwapInput} (a:decimal b:[decimal] c:decimal d:integer e:integer f:integer g:[decimal]))
    (defun UDC_DirectSwapInputData:object{DirectSwapInputData} (a:[string] b:[decimal] c:string))
    (defun UDC_ReverseSwapInputData:object{ReverseSwapInputData} (a:string b:decimal c:string))
    (defun UDC_DirectTaxedSwapOutput:object{DirectTaxedSwapOutput} (a:[decimal] b:string c:decimal d:decimal e:decimal))
    (defun UDC_InverseTaxedSwapOutput:object{InverseTaxedSwapOutput} (a:decimal b:decimal c:[decimal] d:string e:decimal))
    (defun UDC_SwapFeez:object{SwapFeez} (a:decimal b:decimal c:decimal))
    (defun UDC_VirtualSwapEngine:object{VirtualSwapEngine} (a:[string] b:[integer] c:string d:[decimal] e:string f:[decimal] g:decimal h:[decimal] i:object{SwapFeez} j:[decimal] k:[decimal] l:[decimal] m:[object{DirectSwapInputData}]))
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_ComputeY (drsi:object{DirectRawSwapInput}))
    (defun UCv_ComputeInverseY (irsi:object{InverseRawSwapInput}))
    (defun UC_YNext (Y:decimal A:decimal D:decimal n:decimal S-Prime:decimal P-Prime:decimal))
    (defun UC_ZNext (Y:decimal A:decimal D:decimal n:decimal S-Prime:decimal P-Prime:decimal))
    (defun UC_ComputeD:decimal (A:decimal X:[decimal]))
    (defun UC_DNext (D:decimal A:decimal X:[decimal]))
        ;;
    (defun UC_ComputeWP (drsi:object{DirectRawSwapInput}))
    (defun UC_ComputeInverseWP (irsi:object{InverseRawSwapInput}))
        ;;
    (defun UC_ComputeEP:decimal (drsi:object{DirectRawSwapInput}))
    (defun UC_ComputeInverseEP:decimal (irsi:object{InverseRawSwapInput}))
    ;;
    ;;
    (defun UC_BalancedLiquidity:[decimal] (ia:decimal ip:integer i-prec X:[decimal] Xp:[integer]))
    (defun UC_LP:decimal (input-amounts:[decimal] pts:[decimal] lps:decimal lpp:integer))
    (defun UC_LpID:[string] (token-names:[string] token-tickers:[string] weights:[decimal] amp:decimal))
    (defun UC_AddSupply:[decimal] (X:[decimal] input-amounts:[decimal] ip:[integer]))
    (defun UC_RemoveSupply:[decimal] (X:[decimal] output-amount:decimal op:integer))
    (defun UC_PoolID:string (token-ids:[string] weights:[decimal] amp:decimal))
    (defun UC_Prefix:string (weights:[decimal] amp:decimal))
    ;;
    (defun UC_AreOnPools:[bool] (id1:string id2:string swpairs:[string]))
    (defun UC_FilterOne:[string] (swpairs:[string] id:string))
    (defun UC_FilterTwo:[string] (swpairs:[string] id1:string id2:string))
    (defun UC_IzOnPool:bool (id:string swpair:string))
    (defun UC_IzOnPools:[bool] (id:string swpairs:[string]))
    (defun UC_MakeGraphNodes:[string] (input-id:string output-id:string swpairs:[string]))
    (defun UC_PoolTokensFromPairs:[[string]] (swpairs:[string]))
    (defun UC_SpecialFeeOutputs:[decimal] (sftp:[decimal] input-amount:decimal output-precision:integer))
    (defun UC_TokensFromSwpairString:[string] (swpair:string))
    (defun UC_UniqueTokens:[string] (swpairs:[string]))
    (defun UC_MakeLiquidityList (swpair:string ptp:integer amount:decimal))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|SWP GOV
    @doc "Swap-pool math and helper library (implements UtilitySwpV2). Defines swap \
        \ input/output schemas with UDC constructors, and implements the pool invariant \
        \ solvers: Curve-style stable-pool math, weighted and equal-weight constant-product \
        \ swaps and inverses, plus LP and pool-id helpers and swpair/token routing \
        \ utilities."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements UtilitySwpV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|SWP_ADMIN)))
    (defcap GOV|U|SWP_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    ;;
    ;;
    (defun UDC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput}
        (a:decimal b:[decimal] c:[decimal] d:[integer] e:integer f:integer g:[decimal])
        {"A"                : a
        ,"X"                : b
        ,"input-amounts"    : c
        ,"input-positions"  : d
        ,"output-position"  : e
        ,"output-precision" : f
        ,"weights"          : g}
    )
    (defun UDC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput}
        (a:decimal b:[decimal] c:decimal d:integer e:integer f:integer g:[decimal])
        {"A"                : a
        ,"X"                : b
        ,"output-amount"    : c
        ,"output-position"  : d
        ,"input-position"   : e
        ,"input-precision"  : f
        ,"weights"          : g}
    )
    ;;
    (defun UDC_DirectSwapInputData:object{UtilitySwpV2.DirectSwapInputData}
        (a:[string] b:[decimal] c:string)
        {"input-ids"        : a
        ,"input-amounts"    : b
        ,"output-id"        : c}
    )
    (defun UDC_ReverseSwapInputData:object{UtilitySwpV2.ReverseSwapInputData}
        (a:string b:decimal c:string)
        {"output-id"        : a
        ,"output-amount"    : b
        ,"input-id"         : c}
    )
    ;;
    (defun UDC_DirectTaxedSwapOutput:object{UtilitySwpV2.DirectTaxedSwapOutput}
        (a:[decimal] b:string c:decimal d:decimal e:decimal)
        {"lp-fuel"          : a
        ,"o-id"             : b
        ,"o-id-special"     : c
        ,"o-id-liquid"      : d
        ,"o-id-netto"       : e}
    )
    (defun UDC_InverseTaxedSwapOutput:object{UtilitySwpV2.InverseTaxedSwapOutput}
        (a:decimal b:decimal c:[decimal] d:string e:decimal)
        {"o-id-liquid"      : a
        ,"o-id-special"     : b
        ,"lp-fuel"          : c
        ,"i-id"             : d
        ,"i-id-brutto"      : e}
    )
    (defun UDC_SwapFeez:object{UtilitySwpV2.SwapFeez}
        (a:decimal b:decimal c:decimal)
        {"lp"               : a
        ,"special"          : b
        ,"boost"            : c}
    )
    (defun UDC_VirtualSwapEngine:object{UtilitySwpV2.VirtualSwapEngine}
        (a:[string] b:[integer] c:string d:[decimal] e:string f:[decimal] g:decimal h:[decimal] i:object{UtilitySwpV2.SwapFeez} j:[decimal] k:[decimal] l:[decimal] m:[object{UtilitySwpV2.DirectSwapInputData}])
        {"v-tokens"         : a
        ,"v-prec"           : b
        ,"account"          : c
        ,"account-supply"   : d
        ,"swpair"           : e
        ,"X"                : f
        ,"A"                : g
        ,"W"                : h
        ,"F"                : i
        ,"fuel"             : j
        ,"special"          : k
        ,"boost"            : l
        ,"swaps"            : m}
    )
    ;;{5.2}  Compute [UC]
    ;;S - Stable Pools Computation using Curve Finance original math.
    (defun UC_ComputeY 
        (drsi:object{UtilitySwpV2.DirectRawSwapInput})
        @doc "Computes <output-amount> of the Swap given the <input-amount>"
        (let
            (
                ;;Unwrap Object Data
                (A:decimal (at "A" drsi))
                (X:[decimal] (at "X" drsi))
                (input-amount:decimal (at 0 (at "input-amounts" drsi)))
                (ip:integer (at 0 (at "input-positions" drsi)))
                (op:integer (at "output-position" drsi))
                (o-prec:integer (at "output-precision" drsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (prec:integer 24)
                (D:decimal (UC_ComputeD A X))
                (n:decimal (dec (length X)))
                (xo:decimal (at op X))
                (xi:decimal (at ip X))
                (xi-plus:decimal (+ xi input-amount))
                (X1:[decimal] (ref-U|LST::UC_ReplaceAt X ip xi-plus))
                (X2:[decimal] (ref-U|LST::UC_ReplaceAt X1 op -1.0))
                (X3:[decimal] (ref-U|LST::UC_RemoveItem X2 -1.0))
                (S-Prime:decimal (floor (fold (+) 0.0 X3) prec))
                (P-Prime:decimal (floor (fold (*) 1.0 X3) prec))
                ;;Y0 Initial Assumption
                ;;Seeded at <D> (matching the Curve-style reference `get_y`), not <xo - input-amount> \
                ;;<xo - input-amount> goes negative once <input-amount> >= <xo>, walking Newton into the \
                ;;non-physical negative root of the same quadratic; <D> is always in the correct root's \
                ;;basin regardless of trade size (C2 fix)
                (y0:decimal D)
                (output-lst:[decimal]
                    (fold
                        (lambda
                            (y-values:[decimal] idx:integer)
                            (let
                                (
                                    (prev-y:decimal (at idx y-values))
                                    (y-value:decimal (UC_YNext prev-y A D n S-Prime P-Prime))
                                )
                                (ref-U|LST::UC_AppL y-values y-value)
                            )
                        )
                        [y0]
                        ;;#24H fix: 11 -> 12 iterations, for uniformity with UC_ComputeD's bumped
                        ;;count (owner direction) — measured fully converged at 11 already (proven
                        ;;via a 255-iteration reference at 1000x reserve skew), so this is pure
                        ;;margin, not a measured shortfall like UC_ComputeD's was.
                        (enumerate 0 11)
                    )
                )
            )
            ;;C3 fix: floor the FINAL output, not the intermediate solved balance. Flooring <Y> before
            ;;subtracting it from <xo> made <output> systematically LARGER than the exact invariant value
            ;;(favoring the trader); flooring the final <xo - Y> instead rounds what's actually paid out
            ;;down, favoring the pool, matching the Curve reference convention.
            (floor (- xo (ref-U|LST::UC_LE output-lst)) o-prec)
        )
    )
    (defun UCv_ComputeInverseY
        (irsi:object{UtilitySwpV2.InverseRawSwapInput})
        @doc "Computes the <input-amount> for the Swap given the <output-amount>"
        (let        
            (
                ;;Unwrap Object Data
                (A:decimal (at "A" irsi))
                (X:[decimal] (at "X" irsi))
                (output-amount:decimal (at "output-amount" irsi))
                (op:integer (at "output-position" irsi))
                (ip:integer (at "input-position" irsi))
                (i-prec:integer (at "input-precision" irsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (prec:integer 24)
                (D:decimal (UC_ComputeD A X))
                (n:decimal (dec (length X)))
                (xo:decimal (at op X))
                (xi:decimal (at ip X))
                ;;#72C fix (C2's still-open sibling): <xo-minus> feeds <P-Prime> as a plain factor
                ;;(not just an addend), so at <output-amount> == <xo> it is exactly 0.0, making
                ;;<P-Prime> == 0.0 and dividing by zero inside <UC_YNext>'s `c` term — an ugly,
                ;;uncatchable-via-`try` native crash (confirmed live). Past that (<output-amount>
                ;;> <xo>) <xo-minus> goes negative, flips the sign on every coefficient chained off
                ;;<P-Prime>/<S-Prime>, and the solver does NOT crash — it silently converges to a
                ;;plausible-looking but mathematically meaningless number (confirmed live: asking
                ;;for 1.01x/1.5x/5x a pool's real output reserve returned ~1.01x/~1.5x/~5x back as
                ;;the "required input," when no finite input can ever buy more than 100% of a
                ;;pool's own reserve of a token). Unlike <UC_ComputeY>'s C2 fix (a reseed was
                ;;enough there, because the physical root exists for ANY positive input), no seed
                ;;choice can fix this: the coefficients themselves are invalid before Newton ever
                ;;starts, for a request that has no valid answer by construction. Rejecting it here,
                ;;before <xo-minus>/<P-Prime> are computed, is the only correct fix — mirrors the
                ;;same load-bearing, computation-intrinsic bounds-guard treatment StoicSyntax §6.1
                ;;already documents for this exact function (the <U|LST> bounds-guard exception).
                (domain-guard:bool
                    (enforce (< output-amount xo)
                        "UCv_ComputeInverseY: output-amount must be strictly less than the pool's current output-token reserve"))
                (xo-minus:decimal (- xo output-amount))
                (X1:[decimal] (ref-U|LST::UC_ReplaceAt X op xo-minus))
                (X2:[decimal] (ref-U|LST::UC_ReplaceAt X1 ip -1.0))
                (X3:[decimal] (ref-U|LST::UC_RemoveItem X2 -1.0))
                (S-Prime:decimal (floor (fold (+) 0.0 X3) prec))
                (P-Prime:decimal (floor (fold (*) 1.0 X3) prec))
                ;;Y0 Initial Assumption
                ;;For best results <output-amount> < 0.9975 * xi
                (y0:decimal (+ xi output-amount))
                (output-lst:[decimal]
                    (fold
                        (lambda
                            (y-values:[decimal] idx:integer)
                            (let
                                (
                                    (prev-y:decimal (at idx y-values))
                                    (y-value:decimal (UC_ZNext prev-y A D n S-Prime P-Prime))
                                )
                                (ref-U|LST::UC_AppL y-values y-value)
                            )
                        )
                        [y0]
                        ;;#24H fix: 11 -> 12 iterations, mirroring UC_ComputeY (see its comment).
                        (enumerate 0 11)
                    )
                )
            )
            ;;C3 fix: ceiling the FINAL input-needed, not the intermediate solved balance. Flooring <Y>
            ;;before subtracting <xi> made <input-needed> systematically SMALLER than the exact invariant
            ;;value (favoring the trader); ceiling-ing the final <Y - xi> instead rounds what's actually
            ;;required in up, favoring the pool.
            (ceiling (- (ref-U|LST::UC_LE output-lst) xi) i-prec)
        )
    )
    (defun UC_YNext (Y:decimal A:decimal D:decimal n:decimal S-Prime:decimal P-Prime:decimal)
        @doc "Swapping 100B for y amount of C >> Equation in a stable swap pool: \
            \ How much C do you get from swapping 100B ? \
            \ D-of-[A B C] = D-of-[A (B + 100) (C - y)] \
            \ Function solves for Y iteratively, where Y = (C - y) [y  = swap value] \
            \ \
            \ <input> = 100 ; <output> = ?? \
            \ \
            \ S-Prime = A + (B + 100) without (C - ??) \
            \ P-Prime = A * (B + 100) without (C - ??) \
            \ \
            \ c = (D^(n+1))/(n^n * Pp * A * n^n) \
            \ b = Sp + (D/(A * n^n)) \
            \ Numerator = Y^2 + c \
            \ Denominator = 2*Y + b - D \
            \ YNext = Numerator / Denominator"
        (let
            (
                (prec:integer 24)
                (n1:decimal (+ 1.0 n))
                ;;C3 fix: <n>/<n1>/<Y^2> are always whole-number powers — use exact UC_IntPow / plain
                ;;multiplication, not native <^> (see UC_IntPow @doc for why <^> isn't safe here).
                (ni:integer (round n))
                (nn:decimal (UC_IntPow n ni))
                (c:decimal (floor (/ (UC_IntPow D (+ ni 1)) (fold (*) 1.0 [nn P-Prime A nn])) prec))
                (b:decimal (floor (+ S-Prime (/ D (* A nn))) prec))
                (Ysq:decimal (* Y Y))
                (numerator:decimal (floor (+ Ysq c) prec))
                (denominator:decimal (floor (- (+ (* Y 2.0) b) D) prec))
            )
            (floor (/ numerator denominator) prec)
        )
    )
    (defun UC_ZNext (Y:decimal A:decimal D:decimal n:decimal S-Prime:decimal P-Prime:decimal)
        @doc "Swapping ??B for 100C  >> Equation in a stable swap pool: \
            \ How much B do you need to swap to get 100C ? \
            \ D-of-[A B C] = D-of-[A (B + y) (C - 100)] \
            \ Function solves for Y iteratively, where Y = (B + y) [y  = swap value] \
            \ \
            \ <input> = ?? ; <output> = 100 \
            \ \
            \ S-Prime = A + (C - 100) without (B + ??) \
            \ P-Prime = A * (C - 100) without (B + ??) \
            \ \
            \ c = (D^(n+1))/(n^n * Pp * A * n^n) \
            \ b = Sp + (D/(A * n^n)) \
            \ Numerator = Y^2 + c \
            \ Denominator = 2*Y + b - D \
            \ YNext = Numerator / Denominator"
        (UC_YNext Y A D n S-Prime P-Prime)
    )
    (defun UC_IntPow:decimal (base:decimal power:integer)
        @doc "Computes <base>^<power> for a non-negative INTEGER <power> via exact repeated multiplication. \
            \ C3 fix: Pact's native <^> silently drops to IEEE-754 double precision for decimal \
            \ exponentiation (confirmed empirically — a ~2550.0 base raised to a whole-number power via \
            \ <^> differs from the exact repeated-multiplication result by ~1e-2 in absolute terms), which \
            \ was the true source of the stable-pool round-trip rounding bias, not the floor/ceiling \
            \ placement. Use this instead of <^> everywhere the exponent is a whole number (token-count- \
            \ derived powers); genuinely fractional exponents (weighted-pool <x^weight>) still route \
            \ through native <^> and are NOT fixed by this helper."
        (fold (*) 1.0 (make-list power base))
    )
    (defun UC_ComputeD:decimal (A:decimal X:[decimal])
        @doc "Computes D Parameter given an amplifier <A> and a value of Pool Tokens \
        \ Uses <UC_DNext> for aproximation over 12 fixed iterations. \
        \ #24H fix: was 6 (docstring claimed 5, itself a doc/code mismatch) — measured \
        \ directly against a 255-iteration reference at 1000x reserve skew \
        \ (X=[500000,500,500], A=85, a legally reachable pool state): 6 iterations left \
        \ D off by 0.0078 absolute, while the same computation is already fully \
        \ converged (bit-identical to 255 iterations) by iteration 10. Pact has no \
        \ dynamic-length loop / early-exit-on-convergence construct (Turing-incomplete — \
        \ the iteration count must be a fixed number decided in advance, not runtime- \
        \ dependent), so the fix is a plain static bump, not an adaptive break: 12 \
        \ gives 2 iterations of margin past the measured convergence point, for a small, \
        \ fixed, uniform gas cost on every call regardless of pool state."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (output-lst:[decimal]
                    (fold
                        (lambda
                            (d-values:[decimal] idx:integer)
                            (let
                                (
                                    (prev-d:decimal (at idx d-values))
                                    (d-value:decimal (UC_DNext prev-d A X))
                                )
                                (ref-U|LST::UC_AppL d-values d-value)
                            )
                        )
                        [(fold (+) 0.0 X)]
                        (enumerate 0 11)
                    )
                )
            )
            (ref-U|LST::UC_LE output-lst)
        )
    )
    (defun UC_DNext (D:decimal A:decimal X:[decimal])
        @doc "Computes Dnext: \
        \ n = (length X) \
        \ S=x1+x2+x3+... \
        \ P=x1*x2*x3*... \
        \ Dp = (D^(n+1))/(P*n^n) \
        \ Numerator = (A*n^n*S + Dp*n)*D \
        \ Denominator = (A*n^n-1)*D + (n+1)*Dp \
        \ DNext = Numerator / Denominator"
        (let
            (
                (prec:integer 24)
                (n:decimal (dec (length X)))
                (S:decimal (fold (+) 0.0 X))
                (P:decimal (floor (fold (*) 1.0 X) prec))
                (n1:decimal (+ 1.0 n))
                ;;C3 fix: <n>/<n1> are always whole numbers (token count / +1) — use exact UC_IntPow,
                ;;not native <^>, which silently loses precision through a float64 path (see UC_IntPow @doc).
                (nn:decimal (UC_IntPow n (length X)))
                (Dp:decimal (floor (/ (UC_IntPow D (+ (length X) 1)) (* nn P)) prec))
                ;;
                (v1:decimal (floor (fold (*) 1.0 [A nn S]) prec))
                (v2:decimal (* Dp n))
                (v3:decimal (+ v1 v2))
                (numerator:decimal (floor (* v3 D) prec))
                ;;
                (v4:decimal (- (* A nn) 1.0))
                (v5:decimal (* v4 D))
                (v6:decimal (floor (* n1 Dp) prec))
                (denominator:decimal (+ v5 v6))
            )
            (floor (/ numerator denominator) prec)
        )
    )
    ;;W - Weigthed Constant Product Pools Computations
    ;;
    ;;<x^weight> below routes through Pact's native <^>, which computes decimal exponentiation via
    ;;power via <^> differs from the exact repeated-multiplication result by ~1e-2 absolute) — unlike
    ;;+/-/*// on Pact decimals, which genuinely are exact/arbitrary-precision. <UC_IntPow> works around
    ;;this for the STABLE-pool math (UC_ComputeD/UC_YNext), which only ever needs whole-number exponents.
    ;;It cannot work around this here: <weight> is a genuine fraction (e.g. 0.3), so this needs a real
    ;;fractional power, and no exact-multiplication trick exists for that in pure Pact. Fixing this fully
    ;;would mean writing a from-scratch high-precision power routine (Newton's method / power series) —
    ;;assessed and explicitly declined as disproportionate to the residual risk: the resulting bias scales
    ;;with float64's ~1e-16 *relative* precision times the magnitude of the numbers involved, is many
    ;;orders of magnitude below anything resembling pool insolvency, stays internally consistent (the same
    ;;computed value backs both the transfer and the tracked-reserve update), and for realistic (non-24-
    ;;decimal) token precisions is routinely swallowed entirely by the final settlement-precision rounding.
    ;;Accepted as a bounded, documented limitation of the underlying language, not tracked as an open bug.
    (defun UC_ComputeWP
        (drsi:object{UtilitySwpV2.DirectRawSwapInput})
        @doc "Swapping 100A for y amount of C >> Equation in a weighted constant product pool: \
            \ How much C do you get for swapping 100A ? \
            \ xA^wA * xB^wB * xC^wC * xD^wD = (xA + 100)^wA * xB^wB * (xC - y)^wC * xD^wD \
            \ This functions solves for y"
        (let
            (
                ;;Unwrap Object Data
                (X:[decimal] (at "X" drsi))
                (input-amounts:[decimal] (at "input-amounts" drsi))
                (ip:[integer] (at "input-positions" drsi))
                (op:integer (at "output-position" drsi))
                (o-prec:integer (at "output-precision" drsi))
                (w:[decimal] (at "weights" drsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (raised:[decimal] (zip (lambda (x:decimal y:decimal) (floor (^ x y) 24)) X w))
                (pool-product:decimal (floor (fold (*) 1.0 raised) 24))
                (added-supplies:[decimal] (UC_AddSupply X input-amounts ip))
                (rm-output:[decimal] (ref-U|LST::UC_RemoveItemAt added-supplies op))
                (rw:[decimal] (ref-U|LST::UC_RemoveItemAt w op))
                (rm-output-raised:[decimal] (zip (lambda (x:decimal y:decimal) (^ x y)) rm-output rw))
                (rm-output-raised-multiplied:decimal (floor (fold (*) 1.0 rm-output-raised) 24))
                (ow:decimal (at op w))
                (inverse-ow:decimal (floor (/ 1.0 ow) 24))
                (output-missing-term-raised:decimal (floor (/ pool-product rm-output-raised-multiplied) 24))
                ;;C3 fix: keep this intermediate at internal precision (24), not <o-prec> — the final
                ;;<output> rounding happens once, below, on the actual amount paid out.
                (output-missing-term:decimal (floor (^ output-missing-term-raised inverse-ow) 24))
            )
            ;;C3 fix: floor the FINAL output, not the intermediate missing-term. Flooring the missing-term
            ;;before subtracting it from <X[op]> made <output> systematically larger than the exact
            ;;invariant value (favoring the trader); flooring the final subtraction favors the pool.
            (floor (- (at op X) output-missing-term) o-prec)
        )
    )
    (defun UC_ComputeInverseWP
        (irsi:object{UtilitySwpV2.InverseRawSwapInput})
        @doc "Swapping ??A for 100C >> Equation in a weighted constant product pool: \
            \ How much A do you need to swap to get 100C ?  \
            \ xA^wA * xB^wB * xC^wC * xD^wD = (xA + y)^wA * xB^wB * (xC - 100)^wC * xD^wD \
            \ This functions solves for y"
        (let
            (
                ;;Unwrap Object Data
                (X:[decimal] (at "X" irsi))
                (output-amount:decimal (at "output-amount" irsi))
                (op:integer (at "output-position" irsi))
                (ip:integer (at "input-position" irsi))
                (i-prec:integer (at "input-precision" irsi))
                (w:[decimal] (at "weights" irsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (raised:[decimal] (zip (lambda (x:decimal y:decimal) (floor (^ x y) 24)) X w))
                (pool-product:decimal (floor (fold (*) 1.0 raised) 24))
                (removed-supplies:[decimal] (UC_RemoveSupply X output-amount op))
                (rm-input:[decimal] (ref-U|LST::UC_RemoveItemAt removed-supplies ip))
                (rw:[decimal] (ref-U|LST::UC_RemoveItemAt w ip))
                (rm-input-raised:[decimal] (zip (lambda (x:decimal y:decimal) (^ x y)) rm-input rw))
                (rm-input-raised-multiplied:decimal (floor (fold (*) 1.0 rm-input-raised) 24))
                (iw:decimal (at ip w))
                (inverse-iw:decimal (floor (/ 1.0 iw) 24))
                (input-missing-term-raised:decimal (floor (/ pool-product rm-input-raised-multiplied) 24))
                ;;C3 fix: keep this intermediate at internal precision (24), not <i-prec> — the final
                ;;<input-needed> rounding happens once, below, on the actual amount required in.
                (input-missing-term:decimal (floor (^ input-missing-term-raised inverse-iw) 24))
            )
            ;;C3 fix: ceiling the FINAL input-needed, not the intermediate missing-term. Flooring the
            ;;missing-term before subtracting <X[ip]> made <input-needed> systematically smaller than the
            ;;exact invariant value (favoring the trader); ceiling-ing the final subtraction favors the
            ;;pool.
            (ceiling (- input-missing-term (at ip X)) i-prec)
        )
    )
    ;;W - Equal Weight Constant Product Pools Computations
    (defun UC_ComputeEP:decimal 
        (drsi:object{UtilitySwpV2.DirectRawSwapInput})
        @doc "Swapping 100A for y amount of C >> Equation in an equal weight constant product pool: \
            \ xA * xB * xC * xD = (xA + 100) * xB * (xC - y) * xD \
            \ This Functions solves for y"
        (let
            (
                ;;Unwrap Object Data
                (X:[decimal] (at "X" drsi))
                (input-amounts:[decimal] (at "input-amounts" drsi))
                (ip:[integer] (at "input-positions" drsi))
                (op:integer (at "output-position" drsi))
                (o-prec:integer (at "output-precision" drsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (pool-product:decimal (floor (fold (*) 1.0 X) 24))
                (added-supplies:[decimal] (UC_AddSupply X input-amounts ip))
                (rm-output:[decimal] (ref-U|LST::UC_RemoveItemAt added-supplies op))
                (rm-output-multiplied:decimal (floor (fold (*) 1.0 rm-output) 24))
                ;;C3 fix: keep this intermediate at internal precision (24), not <o-prec> — see UC_ComputeY.
                (output-missing-term:decimal (floor (/ pool-product rm-output-multiplied) 24))
            )
            ;;C3 fix: floor the FINAL output, not the intermediate missing-term (see UC_ComputeWP).
            (floor (- (at op X) output-missing-term) o-prec)
        )
    )
    (defun UC_ComputeInverseEP:decimal
        (irsi:object{UtilitySwpV2.InverseRawSwapInput})
        @doc "How Much A is needed to get 100C >> Equation in an equal weight constant product pool: \
            \ xA * xB * xC * xD = (xA + y) * xB * (xC - 100) * xD \
            \ This function solves for Y"
        (let
            (
                ;;Unwrap Object Data
                (X:[decimal] (at "X" irsi))
                (output-amount:decimal (at "output-amount" irsi))
                (op:integer (at "output-position" irsi))
                (ip:integer (at "input-position" irsi))
                (i-prec:integer (at "input-precision" irsi))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (pool-product:decimal (floor (fold (*) 1.0 X) 24))
                (removed-supplies:[decimal] (UC_RemoveSupply X output-amount op))
                (rm-input:[decimal] (ref-U|LST::UC_RemoveItemAt removed-supplies ip))
                (rm-input-multiplied:decimal (floor (fold (*) 1.0 rm-input) 24))
                ;;C3 fix: keep this intermediate at internal precision (24), not <i-prec> — see UC_ComputeInverseWP.
                (input-missing-term:decimal (floor (/ pool-product rm-input-multiplied) 24))
            )
            ;;C3 fix: ceiling the FINAL input-needed, not the intermediate missing-term (see UC_ComputeInverseWP).
            (ceiling (- input-missing-term (at ip X)) i-prec)
        )
    )
    ;;LP Computations
    (defun UC_BalancedLiquidity:[decimal] (ia:decimal ip:integer i-prec X:[decimal] Xp:[integer])
        @doc "Computes Balanced Liquidity Amounts from input sources"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ratio:decimal (floor (/ ia (at ip X)) i-prec))
                (output:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (if (= idx ip)
                                    ia
                                    (floor (* ratio (at idx X)) (at idx Xp))
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length X) 1))
                    )
                )
            )
            output
        )
    )
    (defun UC_LP:decimal (input-amounts:[decimal] pts:[decimal] lps:decimal lpp:integer)
        @doc "Computes the amount of LP that would result from <input-amounts> of tokens added to the pool, when \
            \ the pools has <pts> token supply, and the lp amounts is <lps> and the lp token has <lpp> precision \
            \ Must only be used when <input-amounts> are balanced, otherwise LP computation results in an inccorect value"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (nz:[decimal] (ref-U|LST::UC_RemoveItem input-amounts 0.0))
                (fnz:decimal (at 0 nz))
                (fnzp:integer (at 0 (ref-U|LST::UC_Search input-amounts fnz)))
            )
            (floor (* (/ (at fnzp input-amounts) (at fnzp pts)) lps) lpp)
        )
    )
    (defun UC_LpID:[string] (token-names:[string] token-tickers:[string] weights:[decimal] amp:decimal)
        @doc "Creates a LP Id from input sources. \
            \ #40L fix: dropped the cross-module UEV_UniformList length-parity enforce \
            \ that used to live here — a UC_* purity violation (UC_* may not enforce, \
            \ even transitively via another module's UEV_*). Confirmed dead defense, \
            \ not load-bearing: the only real caller (SWP::URC_LpComposer) builds both \
            \ <token-names> and <token-tickers> from the exact same source list via the \
            \ exact same enumerate range, so they can never actually differ in length. \
            \ Residual, not pursued: UC_LpID is declared on the public UtilitySwpV2 \
            \ interface, so a hypothetical future caller passing mismatched-length \
            \ lists would hit a plain out-of-bounds crash inside the folds below \
            \ instead of a clean enforce message — same class of residual risk as M1's \
            \ own write-up, not a live path today."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (prefix:string (UC_Prefix weights amp))
                (l1:integer (length token-names))
                (minus:string "-")
                (caron:string "^")
            )
            (let
                (
                    (lp-name-elements:[string]
                        (fold
                            (lambda
                                (acc:[string] idx:integer)
                                (if (!= idx (- l1 1))
                                    (ref-U|LST::UC_AppL acc (+ (at idx token-names) caron))
                                    (ref-U|LST::UC_AppL acc (at idx token-names))
                                )
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                    (lp-ticker-elements:[string]
                        (fold
                            (lambda
                                (acc:[string] idx:integer)
                                (if (!= idx (- l1 1))
                                    (ref-U|LST::UC_AppL acc (+ (at idx token-tickers) minus))
                                    (ref-U|LST::UC_AppL acc (at idx token-tickers))
                                )
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                    (lp-name:string (concat [prefix BAR (concat lp-name-elements)]))
                    (lp-ticker:string (concat [prefix BAR (concat lp-ticker-elements) BAR "LP"]))
                )
                [lp-name lp-ticker]
            )
        )
    )
    (defun UC_AddSupply:[decimal] (X:[decimal] input-amounts:[decimal] ip:[integer])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (+
                            (if (contains idx ip)
                                (at (at 0 (ref-U|LST::UC_Search ip idx)) input-amounts)
                                0.0
                            )
                            (at idx X)
                        )
                    )
                )
                []
                (enumerate 0 (- (length X) 1))
            )
        )
    )
    (defun UC_RemoveSupply:[decimal] (X:[decimal] output-amount:decimal op:integer)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (-
                            (at idx X)
                            (if (= idx op)
                                output-amount
                                0.0
                            )
                        )
                    )
                )
                []
                (enumerate 0 (- (length X) 1))
            )
        )
    )
    (defun UC_PoolID:string (token-ids:[string] weights:[decimal] amp:decimal)
        @doc "Creates a Swap Pool Id from input sources"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (prefix:string (UC_Prefix weights amp))
                (swpair-elements:[string]
                    (fold
                        (lambda
                            (acc:[string] idx:integer)
                            (if (!= idx (- (length token-ids) 1))
                                (ref-U|LST::UC_AppL acc (+ (at idx token-ids) BAR))
                                (ref-U|LST::UC_AppL acc (at idx token-ids))
                            )
                        )
                        []
                        (enumerate 0 (- (length token-ids) 1))
                    )
                )
            )
            (concat [prefix BAR (concat swpair-elements)])
        )
    )
    (defun UC_Prefix:string (weights:[decimal] amp:decimal)
        (let
            (
                (ws:decimal (fold (+) 0.0 weights))
            )
            (if (= amp -1.0)
                (if (= ws 1.0)
                    "W"
                    "P"
                )
                "S"
            )
        )
    )
    ;;
    (defun UC_AreOnPools:[bool] (id1:string id2:string swpairs:[string])
        ;;#37M/M3 fix: empty <swpairs> short-circuits to [] instead of the
        ;;<enumerate 0 -1> / <at 0 []> "Array index out of bounds" crash.
        (if (= 0 (length swpairs))
            []
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[bool] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            (let*
                                (
                                    (pool-tokens:[string] (UC_TokensFromSwpairString (at idx swpairs)))
                                    (iz-id1:bool (contains id1 pool-tokens))
                                    (iz-id2:bool (contains id2 pool-tokens))
                                )
                                (and iz-id1 iz-id2)
                            )
                        )
                    )
                    []
                    (enumerate 0 (- (length swpairs) 1))
                )
            )
        )
    )
    (defun UC_FilterOne:[string] (swpairs:[string] id:string)
        (let*
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (l1:[bool] (UC_IzOnPools id swpairs))
                (l2:[string] (zip (lambda (s:string b:bool) (if b s BAR)) swpairs l1))
                (l3:[string] (ref-U|LST::UC_RemoveItem l2 BAR))
            )
            l3
        )
    )
    (defun UC_FilterTwo:[string] (swpairs:[string] id1:string id2:string)
        (let*
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (l1:[bool] (UC_AreOnPools id1 id2 swpairs))
                (l2:[string] (zip (lambda (s:string b:bool) (if b s BAR)) swpairs l1))
                (l3:[string] (ref-U|LST::UC_RemoveItem l2 BAR))
            )
            l3
        )
    )
    (defun UC_IzOnPool:bool (id:string swpair:string)
        (contains id (UC_TokensFromSwpairString swpair))
    )
    (defun UC_IzOnPools:[bool] (id:string swpairs:[string])
        ;;#37M/M3 fix: empty <swpairs> short-circuits to [] instead of the
        ;;<enumerate 0 -1> / <at 0 []> "Array index out of bounds" crash.
        (if (= 0 (length swpairs))
            []
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[bool] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            (UC_IzOnPool id (at idx swpairs))
                        )
                    )
                    []
                    (enumerate 0 (- (length swpairs) 1))
                )
            )
        )
    )
    (defun UC_MakeGraphNodes:[string] (input-id:string output-id:string swpairs:[string])
        @doc "Builds the BFS node set as every token appearing across the FULL \
            \ passed-down <swpairs> list (the caller is expected to already have \
            \ narrowed <swpairs> to whatever universe should be routable, e.g. \
            \ active-only via <SWP::URC_ActiveSwpairs> — see <SWPI::URC_Hopper>). \
            \ \
            \ #13C fix: previously this only kept swpairs directly touching \
            \ <input-id> or <output-id> (<=1 hop from either end), while \
            \ <SWPT::URC_TokenNeighbours> (post-#21H: reads SWPT|Graph directly) \
            \ read the FULL unrestricted set for each node's links — a node envelope \
            \ narrower than the live edge-set, so BFS could expand into a token \
            \ with no <GraphNode> entry and corrupt/lose the chain. Building nodes \
            \ from the full <swpairs> list makes the envelope equal to the \
            \ edge-set by construction, so that mismatch is now structurally \
            \ impossible. <input-id>/<output-id> stay in the signature (unused) so \
            \ this remains a zero-interface-change fix. \
            \ \
            \ Uses p2-p7 s2-s7 Swpair Information Data via passed down <swpairs>"
        (let*
            (
                (non-distinct-nodes-array:[[string]] (UC_PoolTokensFromPairs swpairs))
                (non-distinct-nodes:[string] (fold (+) [] non-distinct-nodes-array))
            )
            (distinct non-distinct-nodes)
        )
    )
    (defun UC_PoolTokensFromPairs:[[string]] (swpairs:[string])
        ;;#37M/M3 fix: empty <swpairs> short-circuits to [] instead of the
        ;;<enumerate 0 -1> / <at 0 []> "Array index out of bounds" crash. Real,
        ;;live path: SWPU|X>SMART-SWAP's defcap calls this (via UC_UniqueTokens
        ;;-> URC_AllPoolTokens) unconditionally, and <swpairs> is genuinely []
        ;;before the first pool is ever issued.
        (if (= 0 (length swpairs))
            []
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[[string]] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            (UC_TokensFromSwpairString (at idx swpairs))
                        )
                    )
                    []
                    (enumerate 0 (- (length swpairs) 1))
                )
            )
        )
    )
    (defun UC_SpecialFeeOutputs:[decimal] (sftp:[decimal] input-amount:decimal output-precision:integer)
        (if (= (length sftp) 1)
            [input-amount]
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (sftp-sum:decimal (fold (+) 0.0 sftp))
                    (sftp-wl:[decimal] (drop -1 sftp))
                    (ipl:[decimal]
                        (fold
                            (lambda
                                (acc:[decimal] idx:integer)
                                (ref-U|LST::UC_AppL
                                    acc
                                    (floor (* (/ (at idx sftp-wl) sftp-sum) input-amount) output-precision)
                                )
                            )
                            []
                            (enumerate 0 (- (length sftp-wl) 1))
                        )
                    )
                    (ipl-sum:decimal (fold (+) 0.0 ipl))
                    (last:decimal (- input-amount ipl-sum))
                )
                (ref-U|LST::UC_AppL ipl last)
            )
        )
    )
    (defun UC_TokensFromSwpairString:[string] (swpair:string)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (bar:string (ref-U|CT::CT_BAR))
            )
            (drop 1 (ref-U|LST::UC_SplitString bar swpair))
        )
    )
    (defun UC_UniqueTokens:[string] (swpairs:[string])
        (distinct (fold (+) [] (UC_PoolTokensFromPairs swpairs)))
    )
    (defun UC_MakeLiquidityList (swpair:string ptp:integer amount:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (how-many-pts:integer (length (UC_TokensFromSwpairString swpair)))
                (zeroes:[decimal] (make-list how-many-pts 0.0))
            )
            (ref-U|LST::UC_ReplaceAt zeroes ptp amount)
        )
    )
    (defun UC_PoolType:string (swpair:string)
        (take 1 swpair)
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

;; ===== 1_SOVEREIGN/STAGE_01/1_Utilities/13_U_BFS.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface BreadthFirstSearchV2
    @doc "Interface exposing a Breadth-First-Search Implementation on Pact \
    \ Used in the SWP Modules to compute Paths between SWPair Tokens."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;
    (defschema GraphNode
        node:string
        links:[string]
    )
    (defschema BFS
        visited:[string]
        que:[object{QE}]
        chains:[[string]]
    )
    (defschema QE
        node:string
        chain:[string]
    )
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_BFS:object{BFS} (graph:[object{GraphNode}] in:string))
    ;;#65hL: UC_BFS, with an early-exit once <target> has been reached — see the
    ;;defun's own doc for the full rationale. Additive, not a replacement.
    (defun UC_BFSTargeted:object{BFS} (graph:[object{GraphNode}] in:string target:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module U|BFS GOV
    @doc "Breadth-first-search library over token graphs (implements BreadthFirstSearchV2), \
        \ used by the SWP modules to find swap paths between pool tokens. UC_BFS folds over \
        \ a graph-node list from a start node, building a BFS object (visited set, queue, \
        \ discovered chains); UC_BFSTargeted adds early-exit once a target node is reached. \
        \ Backed by internal queue/chain constructors and node-lookup/filter helpers."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements BreadthFirstSearchV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|U|BFS_ADMIN)))
    (defcap GOV|U|BFS_ADMIN ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (g:guard (ref-U|CT::CT_GOV|UTILS))
            )
            (enforce-guard g)
        )
    )
    ;;{G5}  functions

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
    (defconst BAR (CT_Bar))
    (defconst EQE
        [
            {
                "node":     BAR,
                "chain":    [BAR]
            }
        ]
    )
    (defconst EBFS
        {
            "visited":  [BAR],
            "que":      EQE,
            "chains":   [[BAR]]
        }
    )
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
    (defun UDCx_ExtendChain:object{BreadthFirstSearchV2.QE} (input:object{BreadthFirstSearchV2.QE} element:string)
        @doc "Extends a Que Element with a new element"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            {
                "node": element,
                "chain": (ref-U|LST::UC_AppL (at "chain" input) element)
            }
        )
    )
    (defun UDCx_AddVisited:object{BreadthFirstSearchV2.BFS} (input:object{BreadthFirstSearchV2.BFS} visited:[string])
        {
            "visited":  (UCx_ExStrLst (at "visited" input) visited),
            "que":      (at "que" input),
            "chains":   (at "chains" input)
        }
    )
    (defun UDCx_AddToQue:object{BreadthFirstSearchV2.BFS} (input:object{BreadthFirstSearchV2.BFS} que:[object{BreadthFirstSearchV2.QE}])
        {
            "visited":  (at "visited" input),
            "que":      (UCx_ExQeLst (at "que" input) que),
            "chains":   (at "chains" input)
        }
    )
    (defun UDCx_RmFromQue:object{BreadthFirstSearchV2.BFS} (input:object{BreadthFirstSearchV2.BFS})
        {
            "visited":  (at "visited" input),
            "que":      (UCx_RmFirstQeList (at "que" input)),
            "chains":   (at "chains" input)
        }
    )
    (defun UDCx_AddChains:object{BreadthFirstSearchV2.BFS} (input:object{BreadthFirstSearchV2.BFS} chains-to-add:[[string]])
        {
            "visited":  (at "visited" input),
            "que":      (at "que" input),
            "chains":   (UCx_ExStrArrLst (at "chains" input) chains-to-add)
        }
    )
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    (defun UC_BFS:object{BreadthFirstSearchV2.BFS} (graph:[object{BreadthFirstSearchV2.GraphNode}] in:string)
        @doc "Implementation of the Breadth First Search Method, outputing a BFS Object, \
        \ which ultimately contains all chains, starting from a specific <in> node"
        (fold
            (lambda
                (acc:object{BreadthFirstSearchV2.BFS} idx:integer)
                (if (= idx 0)
                    (let
                        (
                            (links:[string] (UCx_GraphNodeLinks graph in))
                        )
                        (if (!= links [BAR])
                            (let
                                (
                                    (primal-que:[object{BreadthFirstSearchV2.QE}] (UCx_PrimalQE links in))
                                    (chains-to-add:[[string]] (UCx_GetChains primal-que))
                                    (acc1-visited:object{BreadthFirstSearchV2.BFS} (UDCx_AddVisited acc (+ [in] links)))
                                    (acc2-que:object{BreadthFirstSearchV2.BFS} (UDCx_AddToQue acc1-visited primal-que))
                                    (acc3-chains:object{BreadthFirstSearchV2.BFS} (UDCx_AddChains acc2-que chains-to-add))
                                )
                                acc3-chains
                            )
                            EBFS
                        )
                    )
                    (if (!= acc EBFS)
                        (let
                            (
                                (first-qe:object{BreadthFirstSearchV2.QE} (at 0 (at "que" acc)))
                                (first-qe-node:string (at "node" first-qe))
                            )
                            (if (!= first-qe-node BAR)
                                (let
                                    (
                                        (ref-U|LST:module{StringProcessorV2} U|LST)
                                        (first-qe-node-links:[string] (UCx_GraphNodeLinks graph first-qe-node))
                                        (visited:[string] (at "visited" acc))
                                        (not-visited:[string] (UCx_FilterVisited visited first-qe-node-links))
                                        (lnv:integer (length not-visited))
                                        (acc0-rm:object{BreadthFirstSearchV2.BFS} (UDCx_RmFromQue acc))
                                        (new-que:[object{BreadthFirstSearchV2.QE}]
                                            (if (= lnv 0)
                                                EQE
                                                (fold
                                                    (lambda
                                                        (acc:[object{BreadthFirstSearchV2.QE}] idx2:integer)
                                                        (ref-U|LST::UC_AppL
                                                            acc
                                                            (UDCx_ExtendChain first-qe (at idx2 not-visited))
                                                        )
                                                    )
                                                    []
                                                    (enumerate 0 (- (length not-visited) 1))
                                                )
                                            )
                                        )
                                        (chains-to-add:[[string]] (UCx_GetChains new-que))
                                        (acc1-visited:object{BreadthFirstSearchV2.BFS} (UDCx_AddVisited acc0-rm not-visited))
                                        (acc2-que:object{BreadthFirstSearchV2.BFS}
                                            (if (!= chains-to-add [[BAR]])
                                                (UDCx_AddToQue acc1-visited new-que)
                                                acc1-visited
                                            )
                                        )
                                        (acc3-chains:object{BreadthFirstSearchV2.BFS}
                                            (if (!= chains-to-add [[BAR]])
                                                (UDCx_AddChains acc2-que chains-to-add)
                                                acc2-que
                                            )
                                        )
                                    )
                                    acc3-chains
                                )
                                acc
                            )
                        )
                        EBFS
                    )
                )
            )
            EBFS
            (enumerate 0 (- (length graph) 1))
        )
    )
    (defun UC_BFSTargeted:object{BreadthFirstSearchV2.BFS} (graph:[object{BreadthFirstSearchV2.GraphNode}] in:string target:string)
        @doc "#65hL: <UC_BFS>, with one addition — once <target> has been reached \
            \ (added to <visited>), every remaining fold iteration becomes a cheap \
            \ no-op instead of doing real BFS-expansion work, mirroring exactly how \
            \ this same fold ALREADY short-circuits once the queue naturally empties \
            \ (the <first-qe-node == BAR> branch below) — this just makes that same \
            \ short-circuit trigger EARLIER, the moment the caller's actual target is \
            \ found, instead of only once the full reachable set has been exhausted. \
            \ <UC_BFS> itself is unchanged — this is additive, for callers \
            \ (SWPT::URC_ComputeGraphPath and its FromRaw/FromGraph siblings) that \
            \ only ever want ONE specific target's shortest chain, not chains to \
            \ every reachable node — <UC_BFS>'s own callers (and any future one) keep \
            \ getting the full all-chains result, unaffected. \
            \ Correctness: BFS visits nodes in strictly non-decreasing distance order, \
            \ so a node's shortest chain is fixed the FIRST time it's visited — \
            \ skipping further work after <target> is already visited never changes \
            \ what its own chain entry says, only stops recording chains for nodes \
            \ that would have been discarded by the caller's own post-filter anyway. \
            \ Gas shape: the fold itself still always runs exactly <length graph> \
            \ times (Pact's fold has no native early-return) — the win is in how many \
            \ of those iterations do REAL (expensive, O(V) neighbor-lookup) work \
            \ before the cheap no-op path takes over, which is proportional to how \
            \ many BFS rounds it takes to reach <target> — the closer the target, \
            \ the fewer real iterations run, not a reduction in total iteration count."
        (fold
            (lambda
                (acc:object{BreadthFirstSearchV2.BFS} idx:integer)
                (if (= idx 0)
                    (let
                        (
                            (links:[string] (UCx_GraphNodeLinks graph in))
                        )
                        (if (!= links [BAR])
                            (let
                                (
                                    (primal-que:[object{BreadthFirstSearchV2.QE}] (UCx_PrimalQE links in))
                                    (chains-to-add:[[string]] (UCx_GetChains primal-que))
                                    (acc1-visited:object{BreadthFirstSearchV2.BFS} (UDCx_AddVisited acc (+ [in] links)))
                                    (acc2-que:object{BreadthFirstSearchV2.BFS} (UDCx_AddToQue acc1-visited primal-que))
                                    (acc3-chains:object{BreadthFirstSearchV2.BFS} (UDCx_AddChains acc2-que chains-to-add))
                                )
                                acc3-chains
                            )
                            EBFS
                        )
                    )
                    (if (contains target (at "visited" acc))
                        acc
                        (if (!= acc EBFS)
                            (let
                                (
                                    (first-qe:object{BreadthFirstSearchV2.QE} (at 0 (at "que" acc)))
                                    (first-qe-node:string (at "node" first-qe))
                                )
                                (if (!= first-qe-node BAR)
                                    (let
                                        (
                                            (ref-U|LST:module{StringProcessorV2} U|LST)
                                            (first-qe-node-links:[string] (UCx_GraphNodeLinks graph first-qe-node))
                                            (visited:[string] (at "visited" acc))
                                            (not-visited:[string] (UCx_FilterVisited visited first-qe-node-links))
                                            (lnv:integer (length not-visited))
                                            (acc0-rm:object{BreadthFirstSearchV2.BFS} (UDCx_RmFromQue acc))
                                            (new-que:[object{BreadthFirstSearchV2.QE}]
                                                (if (= lnv 0)
                                                    EQE
                                                    (fold
                                                        (lambda
                                                            (acc:[object{BreadthFirstSearchV2.QE}] idx2:integer)
                                                            (ref-U|LST::UC_AppL
                                                                acc
                                                                (UDCx_ExtendChain first-qe (at idx2 not-visited))
                                                            )
                                                        )
                                                        []
                                                        (enumerate 0 (- (length not-visited) 1))
                                                    )
                                                )
                                            )
                                            (chains-to-add:[[string]] (UCx_GetChains new-que))
                                            (acc1-visited:object{BreadthFirstSearchV2.BFS} (UDCx_AddVisited acc0-rm not-visited))
                                            (acc2-que:object{BreadthFirstSearchV2.BFS}
                                                (if (!= chains-to-add [[BAR]])
                                                    (UDCx_AddToQue acc1-visited new-que)
                                                    acc1-visited
                                                )
                                            )
                                            (acc3-chains:object{BreadthFirstSearchV2.BFS}
                                                (if (!= chains-to-add [[BAR]])
                                                    (UDCx_AddChains acc2-que chains-to-add)
                                                    acc2-que
                                                )
                                            )
                                        )
                                        acc3-chains
                                    )
                                    acc
                                )
                            )
                            EBFS
                        )
                    )
                )
            )
            EBFS
            (enumerate 0 (- (length graph) 1))
        )
    )
    (defun UCx_GraphNodeLinks:[string] (graph:[object{BreadthFirstSearchV2.GraphNode}] node:string)
        @doc "Scans a Graph for a Node, outputing its links. \
            \ #38M/M4 fix: single-pass <filter> directly over <graph>, matching by \
            \ the \"node\" field, replacing the old rebuild-the-whole-name-list \
            \ (UCx_GraphNodes) + linear search (UC_Search) + re-index-by-position \
            \ chain — that old path did two full O(V) passes plus a reindex per \
            \ call; this does one. Same O(V) cost per lookup either way (Pact has \
            \ no O(1) hash-index over a plain list argument, so a full BFS \
            \ traversal stays O(V^2) overall), but roughly halves the constant \
            \ factor, measured live (see ROUND-02-FIXES.md Fix #24). Tie-break \
            \ preserved exactly: first matching entry by original <graph> order, \
            \ same as the old UC_Search-based lookup. <filter> is empty-list-safe \
            \ by construction, so the #37M/M3-style length guard isn't needed \
            \ here. UCx_GraphNodes (its only caller) removed as dead code."
        (let
            (
                (matches:[object{BreadthFirstSearchV2.GraphNode}]
                    (filter
                        (lambda (gn:object{BreadthFirstSearchV2.GraphNode}) (= (at "node" gn) node))
                        graph
                    )
                )
            )
            (if (= 0 (length matches))
                [BAR]
                (at "links" (at 0 matches))
            )
        )
    )
    (defun UCx_PrimalQE:[object{BreadthFirstSearchV2.QE}] (links:[string] node:string)
        @doc "Computes the Primal Que Elements in a BFS Object, which is the first Que Element that is created"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[object{BreadthFirstSearchV2.QE}] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        {
                            "node":     (at idx links),
                            "chain":    [node, (at idx links)]
                        }
                    )
                )
                []
                (enumerate 0 (- (length links) 1))
            )
        )
    )
    (defun UCx_GetChains:[[string]] (input:[object{BreadthFirstSearchV2.QE}])
        @doc "Extracts a list of chains from a list of Que Objects"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[[string]] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (at "chain" (at idx input))
                    )
                )
                []
                (enumerate 0 (- (length input) 1))
            )
        )
    )
    (defun UCx_FilterVisited:[string] (visited:[string] new-nodes:[string])
        @doc "Filters a list of new-nodes by a list of visited nodes"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (let
                        (
                            (elem:string (at idx new-nodes))
                            (iz-visited:bool (contains elem visited))
                        )
                        (if iz-visited
                            (ref-U|LST::UC_RemoveItem acc elem)
                            acc
                        )
                    )
                )
                new-nodes
                (enumerate 0 (- (length new-nodes) 1))
            )
        )
    )
    (defun UCx_ExStrLst:[string] (to-extend:[string] elements:[string])
        (if (= [BAR] to-extend)
            elements
            (+ to-extend elements)
        )
    )
    (defun UCx_ExQeLst:[object{BreadthFirstSearchV2.QE}] (input:[object{BreadthFirstSearchV2.QE}] que-element:[object{BreadthFirstSearchV2.QE}])
        (if (and (= (at 0 EQE) (at 0 input)) (= (length input) 1))
            que-element
            (+ input que-element)
        )
    )
    (defun UCx_RmFirstQeList:[object{BreadthFirstSearchV2.QE}] (input:[object{BreadthFirstSearchV2.QE}])
        (if (> (length input) 1)
            (drop 1 input)
            EQE
        )
    )
    (defun UCx_ExStrArrLst:[[string]] (to-extend:[[string]] elements:[[string]])
        (if (= [[BAR]] to-extend)
            elements
            (+ to-extend elements)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)


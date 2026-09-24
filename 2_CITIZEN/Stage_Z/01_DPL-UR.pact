;; ===========================================================================================
;; DPL-UR -- ARCHIVE MODE since 2026-09-25. StoicSyntax-Prefixes.md §7.21.
;; ===========================================================================================
;; This module WAS the read layer for every Ouronet front end: one file, 3,025 lines, 64
;; definitions, every page's data behind a single `implements`. It now holds a governance
;; capability and three constants. Nothing else.
;;
;; ------------------------------------------------------------------------------------------
;; WHY A READ MODULE IS EMPTIED, WHEN ARCHIVE MODE NORMALLY KEEPS READS
;; ------------------------------------------------------------------------------------------
;; §7.21 retires a module by deleting everything that CHANGES state and keeping every reader, so
;; whatever history its tables hold stays legible. DPL-UR owns no tables and is reads end to
;; end, so applied literally that rule would delete nothing.
;;
;; The hazard here is the opposite one. A migrated read left in place is a SECOND SOURCE OF
;; TRUTH answering the same question, and the two drift the moment either is touched -- so a
;; consumer nobody remembered keeps working, quietly, on last month's logic. Worse than a loud
;; failure; it is how a wrong number survives a migration.
;;
;; ------------------------------------------------------------------------------------------
;; THE FIRST CUT KEPT SEVEN READS. IT SHOULD NOT HAVE.
;; ------------------------------------------------------------------------------------------
;; An earlier version of this stub deleted only what had moved to `AppReads/` and kept the rest
;; by DEPENDENCY CLOSURE -- URC_0030_StoicPay, the three PYTHIA reads, URC_PrimordialIDs,
;; URC_PrimordialPrices, URC_TrueFungibleAmountPrice, URC_StoaCollectionReceivers,
;; URC_SplitStoaPriceForReceivers, plus two helpers. That reasoning was wrong, and the way it
;; was wrong is worth recording: the closure kept them because they reference EACH OTHER, not
;; because anything uses them. Counting call sites properly settled it --
;;
;;   URC_PrimordialIDs            1 caller: URC_PrimordialPrices, itself uncalled
;;   URC_StoaCollectionReceivers  1 caller: URC_SplitStoaPriceForReceivers, itself uncalled
;;   UC_FormatTokenAmount         2 callers: URC_0030_StoicPay, itself uncalled
;;   every other survivor         0 callers
;;
;; -- and a workspace-wide search found no caller outside this module either: not OuronetUI,
;; not @ouronet/ouronet-core, not another Pact module. A closed cluster of dead code that kept
;; itself alive by citation.
;;
;; Two were also already SUPERSEDED, which the closure could not see. O-UI-TWO::URC_Prices
;; returns the same six prices as URC_PrimordialPrices and a seventh besides. UC_Amount is
;; UC_FormatTokenAmount with its sub-threshold branch actually reachable -- the original
;; compared a formatted STRING against the DECIMAL literal 0.0, so `<0.0001` could never fire.
;;
;; And the two STOA-split readers were being kept to preserve a test, which inverts the
;; dependency: a test exists to pin behaviour, not to pin code in place. The behaviour it
;; guards -- the 10/20/30/40 conservation -- belongs to U|DALOS::UC_TenTwentyThirtyFourtySplit,
;; not to a display wrapper over it, and STAGEZ-08 now asserts it there. That is a better test
;; than the one it replaces, because it reaches the arithmetic instead of a caller of it.
;;
;; WHERE THE DELETED READS GO WHEN SOMETHING WANTS THEM. Not into this module again:
;;   URC_0030_StoicPay        -> OuronetUI slot 14 (Launchpad), when that page reads the chain.
;;                               It has a surface today -- launchpads.tsx, StoicPayInfo.tsx --
;;                               and that surface reads DEMIPAD-SPARK directly, never this.
;;   URC_0031 / _0033 / _0034 -> AppReads/Pythia/, when an oracle console exists. See its README.
;;   the rest                 -> rebuilt from the screen that needs them, which is the rule
;;                               that produced every module in AppReads/ and the reason their
;;                               shapes could be verified against something real.
;; Their bodies are in git, at the revision before this one.
;;
;; `implements DeployerReadsV14` IS DROPPED, as archive mode requires and as Pact forces: a
;; module must define every member of an interface it implements. NO successor interface is
;; declared, departing from the DPMF precedent deliberately -- a tree-wide scan finds
;; DeployerReadsV14 bound by NOTHING, so a V15 would be a permanent, un-removable artefact
;; describing an archive. It stays deployed and unimplemented; that costs nothing.
;;
;; WHAT IS LEFT, AND WHY ANYTHING IS:
;;   GOV / GOV|DPL_UR_ADMIN / GOV|MD_DPL-UR / GOV|Demiurgoi   a module cannot exist without
;;                            governance, and this is what authorises any future upgrade.
;;   CT_Namespace / CT_Bar / BAR   the namespace and the field separator this module built every
;;                            key from. Free, and they document the format its output used.
;;
;; THE REPLACEMENTS, for anyone arriving from a dead call site:
;;   header, dashboard           AppReads/OuronetUI/01_O-UI-ONE, 02_O-UI-TWO
;;   elite account + recovery    03_O-UI-THREE          stoa ICO        04_O-UI-FOUR
;;   codex / selectors           07_O-UI-SEVEN          true fungibles  08_O-UI-EIGHT
;;   orto fungibles              09_O-UI-NINE           collectables    10_O-UI-TEN
;;   SWP pools + swap previews   12_O-UI-TWELVE
;; ===========================================================================================

(namespace "ouronet-ns")

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
)

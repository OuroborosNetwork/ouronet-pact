;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 14
;; DPL-UR (module UPGRADE) -- ARCHIVE MODE. The read layer is emptied.
;; =========================================================================================
;; *** DEPLOY THIS LAST, AND ONLY AFTER EVERY PAGE HAS BEEN CHECKED. ***
;;
;; 3,025 lines to 158. Sixty-four definitions to four: a governance capability and three
;; constants. Every read is gone.
;;
;; Until now the transport redirect in OuronetUI has had a SAFETY NET: if an AppReads module
;; refused, the shim re-issued the ORIGINAL call and the page kept working on the legacy read.
;; After this transaction that net is gone. A failure in a new module becomes a visible failure
;; rather than a silent downgrade -- which is the POINT, but it means the verification happens
;; BEFORE this file, not after it.
;;
;; ------------------------------------------------------------------------------------------
;; THE FIRST DRAFT OF THIS FILE KEPT SEVEN READS. IT SHOULD NOT HAVE.
;; ------------------------------------------------------------------------------------------
;; It deleted only what had moved to `AppReads/` and kept the remainder by DEPENDENCY CLOSURE.
;; That reasoning was wrong, and the way it was wrong is the interesting part: the closure kept
;; those functions because they reference EACH OTHER, not because anything uses them. Counting
;; call sites in the result settled it --
;;
;;   URC_PrimordialIDs            1 caller: URC_PrimordialPrices, itself uncalled
;;   URC_StoaCollectionReceivers  1 caller: URC_SplitStoaPriceForReceivers, itself uncalled
;;   UC_FormatTokenAmount         2 callers: URC_0030_StoicPay, itself uncalled
;;   every other survivor         0 callers
;;
;; -- and a workspace-wide search found no caller outside the module either: not OuronetUI, not
;; @ouronet/ouronet-core, not another Pact module, not a website. A closed cluster of dead code
;; keeping itself alive by citation.
;;
;; Two were also already SUPERSEDED, which a closure cannot see. O-UI-TWO::URC_Prices returns
;; the same six prices as URC_PrimordialPrices and a seventh besides. UC_Amount is
;; UC_FormatTokenAmount with its sub-threshold branch made reachable (PureV2/13).
;;
;; And two were being kept to preserve a TEST, which inverts the dependency -- a test pins
;; behaviour, it does not pin code in place. The behaviour in question, the 10/20/30/40 STOA
;; conservation, belongs to U|DALOS::UC_TenTwentyThirtyFourtySplit rather than to a display
;; wrapper over it, and STAGEZ-08 now asserts it there. That is a better test than the one it
;; replaced, because it reaches the arithmetic instead of a caller of it.
;;
;; WHERE THE DELETED READS GO WHEN SOMETHING WANTS THEM -- not back into this module:
;;   URC_0030_StoicPay        -> OuronetUI slot 14 (Launchpad) when that page reads the chain.
;;                               It has a surface today (launchpads.tsx, StoicPayInfo.tsx) and
;;                               that surface reads DEMIPAD-SPARK directly, never this.
;;   URC_0031 / _0033 / _0034 -> AppReads/Pythia/ when an oracle console exists.
;;   the rest                 -> rebuilt from the screen that needs them, which is the rule that
;;                               produced every AppReads module and the reason their shapes
;;                               could be checked against something real.
;; Their bodies are in git, one revision back.
;;
;; `implements DeployerReadsV14` is dropped -- Pact requires a module to define every member of
;; an interface it implements. NO successor interface, departing from the DPMF precedent on
;; evidence: a tree-wide scan finds DeployerReadsV14 bound by nothing, so a V15 restating an
;; archive would be a permanent, un-removable artefact.
;;
;; ------------------------------------------------------------------------------------------
;; HOW THE MIGRATION WAS PROVEN BEFORE THIS FILE WAS WRITTEN
;; ------------------------------------------------------------------------------------------
;; Every replacement was called on MAINNET alongside the function it replaces and the objects
;; compared key by key. That found the flattened glyphs, the unreachable Wipe button, the ICO
;; division by zero, the dead `<0.0001` sentinel, and a call to
;; `URC_0008b_TrueFungibleLPEntry` -- a member DPL-UR does not have, meaning the LP balance
;; panel on the SWP Pairs page had never once rendered.
;;
;; Parity cannot outlive this transaction, so its durable half was preserved first: RDUI-16 in
;; `REPL/modules/APPREADS-OuronetUI.repl` pins 177 keys across 10 client reads, READ OFF MAINNET
;; rather than copied from the sources. The 150 assertions in `modules/STAGE-Z.repl` were
;; RETARGETED at the replacements rather than deleted with the originals.
;;
;; SIGNING -- namespace keyset AND the Demiurgoi keyset (GOV|DPL_UR_ADMIN).
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
)


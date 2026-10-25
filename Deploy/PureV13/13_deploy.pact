;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- ROUND V13, file 13
;; DPL-UR -- ONE-TOKEN CASCADE FIX: OuronetDalosV2 -> OuronetDalosV3
;;
;; WHAT THIS IS NOT. It is not the stubbing of DPL-UR -- that already happened and is
;; already LIVE. Measured against the chain 2026-10-24: live DPL-UR is 76 lines, three
;; defuns (`GOV|Demiurgoi`, `CT_Namespace`, `CT_Bar`), and ZERO `implements`. It is
;; byte-for-byte the archive-mode stub except for a single token.
;;
;; WHAT ACTUALLY BROKE. After the stub shipped, DALOS bumped OuronetDalosV2 -> V3, and
;; DPL-UR was MISSED IN THAT CASCADE. It still declares
;;
;;     (ref-DALOS:module{OuronetDalosV2} DALOS)
;;
;; and live DALOS now implements only `OuronetDalosV3` (plus OuronetPolicyV2). So:
;;
;;     Runtime typecheck failure, argument is modref, but expected
;;     type module{ouronet-ns.OuronetDalosV2}
;;
;; NOTE THE INTERFACE IS NOT MISSING. `OuronetDalosV2` is still deployed and always will
;; be -- a deployed interface is never removed. What it no longer has is an IMPLEMENTOR.
;; `module{I}` is a type whose only inhabitants are modules declaring `implements I`, and
;; the cascade rule has implementing modules carry only the LATEST version. So V2 is a
;; present, permanently uninhabited type, and any modref still naming it cannot bind.
;; DALOS *is* a modref; it is simply not that one.
;;
;; WHY IT MATTERS DESPITE THE MODULE DOING NOTHING. The failure is at BIND time, so the
;; whole module is unusable on chain -- and the round simulator has to exclude it to
;; build a working sandbox, which is how it was found.
;;
;; UPGRADE-SAFE: no `create-table`, no `implements`, governance unchanged, so the existing
;; admin guard authorises the upgrade.
;; Source: 2_CITIZEN/Stage_Z/01_DPL-UR.pact
;; ---------------------------------------------------------------------------

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
)

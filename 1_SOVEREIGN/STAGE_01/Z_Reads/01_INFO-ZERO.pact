;; Deploy: load THIS file — module ships alone.
;; ============================================================================
;;  OBSOLETE TOMBSTONE — INFO-ZERO
;; ============================================================================
;;  This module has been made OBSOLETE and retained only as a documented,
;;  deployable placeholder (it may already hold a deploy slot / namespace name).
;;  It defines NO client-facing functions and implements NO interfaces.
;;
;;  HISTORY — why it is empty:
;;   - Phase 1.1 (URCi reposition, 2026-08-30): the shared OI|* cost/format
;;     vocabulary that once lived here (OI|UC_ShortAccount, OI|UDC_ClientInfo,
;;     OI|UDC_*IgnisCosts / *StoaCosts, OI|UC_IfpFromOutputCumulator, …) was
;;     RELOCATED into the IGNIS module (02_IGNIS.pact) — the pre-Talos cost hub,
;;     so Talos + every cost module + the Z_Reads presentation layer can reach it.
;;     Callers now bind `module{OuronetInfoV1} IGNIS`.
;;   - Phase 1.2 (INFO consolidation): the 9 DALOS client-op previews that then
;;     lived here (DALOS-INFO|URC_ControlSmartAccount / DeploySmartAccount /
;;     DeployStandardAccount / RotateGovernor / RotateGuard / RotateStoa /
;;     RotateSovereign / UpdateEliteAccount / UpdateEliteAccountSquared) were
;;     RELOCATED into INFO-ONE (Z_Reads/02_INFO-ONE+.pact, InfoOneV1) — the single
;;     Stage-1 INFO module. The `DalosInfoV1` interface was retired with them.
;;
;;  => Nothing references INFO-ZERO. Do not add functions here; new INFO wrappers
;;     go in INFO-ONE (Stage 1) or INFO-TWO (Stage 2), each wrapping its URCi_ reader.
;; ============================================================================
(module INFO-ZERO GOV
    @doc "OBSOLETE TOMBSTONE. Empty by design — OI|* moved to IGNIS (Phase 1.1); DALOS-INFO \
        \ previews moved to INFO-ONE (Phase 1.2). Retained only as a documented deploy-slot \
        \ placeholder; defines no functions and implements no interfaces."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_INFO-ZERO              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                          (enforce-guard GOV|MD_INFO-ZERO))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

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
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

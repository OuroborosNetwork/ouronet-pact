;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuronetGuardsV2
    @doc "Exported Functions from this Module via interface"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
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
    (defcap GOV ()                  (compose-capability (GOV|U|G_ADMIN)))
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

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
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuronetGasStationV2
    @doc "Exported Ouronet Gas Station Functions"

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
    (defcap GOV ()                  (compose-capability (GOV|U|ST_ADMIN)))
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

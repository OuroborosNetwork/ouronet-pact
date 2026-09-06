;;  stoic-xchainV2.pact
;;
;;  V2 of <stoa-ns.stoic-xchain>. The V1 FILE (stoic-xchain.pact) is left intact
;;  for reference. This file redefines the SAME module name, so deploying it is
;;  an in-place MODULE UPGRADE (governed by ns-admin-keyset), not a second
;;  module: every existing reference to <stoa-ns.stoic-xchain> keeps resolving,
;;  and V1's broken creator stops existing rather than lingering on-chain.
;;
;;  ---------------------------------------------------------------------------
;;  WHY V2 EXISTS  (the bug, empirically proven -- not a code-read claim)
;;  ---------------------------------------------------------------------------
;;  V1 built the gas-station price ceiling like this:
;;
;;      (minimum-gas-price-anu:integer (coin.UC_MinimumGasPriceANU))          ; <- evaluated ONCE
;;      (minimum-stoa-gas-price:decimal (/ (dec minimum-gas-price-anu) 1e12)) ; <- evaluated ONCE
;;      (create-user-guard
;;          (util.gas-guards.enforce-below-or-at-gas-price minimum-stoa-gas-price))
;;
;;  create-user-guard STRICTLY EVALUATES AND FREEZES its arguments at guard-
;;  creation time. At enforcement it re-runs the *function* against those
;;  *frozen* arguments. So the ceiling was baked in as "the floor at the moment
;;  the account was created" and never moved again.
;;
;;  Proven on pact 5.4.1 (the version StoaChain pins):
;;      proof-user-guard-freezes.repl   -> passes (exit 0)
;;      show-frozen.repl                -> pact prints its own error:
;;        "FROZEN: guard captured 1 but live block-height is 500"
;;        at(frozen.eq-live.{...} 1)   <- interpreter shows the frozen literal
;;
;;  Consequence, for BOTH stations:
;;    * <kadena-xchain-gas> was given a literal ceiling of 0.00000001 STOA
;;      = 10,000 ANU.
;;    * <stoa-xchain-gas> froze UC_MinimumGasPriceANU as evaluated in the
;;      genesis payload, i.e. GENESIS-MIN-GAS-PRICE = 10,000 ANU = the same
;;      0.00000001 STOA.
;;  They are therefore the SAME frozen ceiling. The live floor today is already
;;  ~11,500 ANU and rises 1 ANU / 3h. The moment the Yin engine (v3.2.1-stoa.3)
;;  enforces gasPrice >= floor at consensus, every admissible transaction is
;;  priced ABOVE both frozen ceilings and NEITHER station can pay for anything.
;;  Cross-chain transfers stop.
;;
;;  ---------------------------------------------------------------------------
;;  THE FIX
;;  ---------------------------------------------------------------------------
;;  The price predicate takes NO ARGUMENT. It reads the floor from coin in its
;;  own BODY, at enforcement time, so the ceiling tracks the live floor instead
;;  of freezing. Nothing else about the guard shape changes -- it is still
;;  enforce-or(admin, all-of[gas-only, price, gas-limit<=850]).
;;
;;  update-xchain-gas-account rotates an ALREADY-LIVE account onto the new guard
;;  in place, so the stations do not have to be recreated or refunded.
;;
;;  ---------------------------------------------------------------------------
;;  DEPLOY / USE  (all of this BEFORE the v3.2.1-stoa.3 fork height)
;;  ---------------------------------------------------------------------------
;;   1. Deploy this file (tx signed with ns-admin-keyset) -> upgrades the module.
;;   2. Rotate both live stations:
;;        (stoa-ns.stoic-xchain.update-xchain-gas-account true)   ; kadena-xchain-gas
;;        (stoa-ns.stoic-xchain.update-xchain-gas-account false)  ; stoa-xchain-gas
;;      Signed with ns-admin-keyset. That single keyset satisfies BOTH gates:
;;      GOVERNANCE here, and the account's existing enforce-or(ns-admin-keyset, ..)
;;      admin branch, which is what coin.rotate -> ROTATE -> UEV_Rotate ->
;;      CAP_Account enforces.
;;   3. Fund the stations with STOA.
;;
;;  ---------------------------------------------------------------------------
;;  OPEN DESIGN POINT -- read before deploying
;;  ---------------------------------------------------------------------------
;;  The station ceiling is EXACTLY the live floor, so a station-paid transaction
;;  must satisfy  F(creationTime) <= gasPrice <= F(blockTime).
;;    * Priced at exactly the floor, mined in the same tick or any later tick:
;;      passes (the ceiling only ever rises).
;;    * Priced ABOVE the floor as a safety margin -- which the Yin design tells
;;      clients to do for ordinary transactions -- and mined promptly: the FLOOR
;;      check passes but this CEILING check REJECTS it.
;;  So either (a) clients price station-paid cross-chain transactions at exactly
;;  F(creationTime) with no headroom, or (b) this predicate needs an explicit
;;  headroom allowance of K ANU. (a) is what is implemented here. Decide before
;;  rollout.
;;
;;  NOTE ON UNITS: the comparison is scaled UP into ANU by multiplying, never by
;;  dividing. Pact decimals are exact (not IEEE floats), but multiplication of
;;  exact decimals is exact whereas division can truncate at the precision
;;  bound -- so this keeps the comparison in whole ANU. (F-13 lesson: no lossy
;;  arithmetic anywhere near a consensus-relevant threshold.)

(module stoic-xchain GOVERNANCE
    ;;
    @doc "V2 - Module for initializing and MAINTAINING the <kadena-xchain-gas> and \
        \ <stoa-xchain-gas> Accounts needed to autonomously pay crosschain-transactions. \
        \ V2 replaces the frozen gas-price ceiling of V1 with one read live at enforcement \
        \ time, and adds an in-place guard upgrade for the already-existing accounts."

    (use coin)
    (use util.guards)
    (use util.gas-guards)

    ; -- Define the private/admin-only capability ---
    (defcap GOVERNANCE ()
        @doc "This is the Key Governing this module"
        (enforce-guard (keyset-ref-guard "ns-admin-keyset"))
    )

    ; -- Account name helper (single source of truth for both entrypoints) --
    (defun UC_XChainGasAccountName:string (kadena-or-stoa:bool)
        @doc "Legacy Kadena name when true, StoaChain name when false"
        (if kadena-or-stoa
            "kadena-xchain-gas"
            "stoa-xchain-gas"
        )
    )

    ; -- The dynamic price predicate (THE FIX) --
    (defun enforce-at-or-below-current-min-gas-price:bool ()
        @doc "Enforces the transaction gas price is at or below the CURRENT protocol \
            \ minimum. Takes NO argument on purpose: coin.UC_MinimumGasPriceANU is read \
            \ live in this body on every enforcement, so the ceiling rises with the floor \
            \ instead of freezing at guard-creation time the way the V1 one did."
        (let
            (
                (tx-gas-price-anu:decimal (* (chain-gas-price) 1000000000000.0))
                (minimum-gas-price-anu:integer (coin.UC_MinimumGasPriceANU))
            )
            (enforce
                (<= tx-gas-price-anu (dec minimum-gas-price-anu))
                (format "Gas Price {} ANU must be smaller than or equal to the current protocol minimum {} ANU"
                    [tx-gas-price-anu minimum-gas-price-anu])
            )
        )
    )

    ; -- The full gas-station guard, shared by create + update --
    ; Structurally identical to V1: admin OR (gas-only AND price AND limit<=850).
    ; Only the price sub-guard changed, and it is now the same guard for BOTH
    ; accounts -- there is no longer a kadena/stoa branch, because the two V1
    ; branches froze to the same 10,000 ANU value anyway.
    (defun UDC_XChainGasGuard:guard ()
        @doc "Builds the final gas-station guard: enforce-or(ns-admin, gas-restrictions)"
        (let
            (
                (gas-restriction-guard:guard
                    (create-user-guard
                        (util.gas-guards.enforce-guard-all
                            [
                                (create-user-guard (coin.gas-only))
                                (create-user-guard (enforce-at-or-below-current-min-gas-price))
                                (create-user-guard (util.gas-guards.enforce-below-or-at-gas-limit 850))
                            ]
                        )
                    )
                )
            )
            (create-user-guard
                (util.guards.enforce-or
                    (keyset-ref-guard "ns-admin-keyset")
                    gas-restriction-guard
                )
            )
        )
    )

    ; -- Create the xchain gas account (admin-only) --
    ; Signature deliberately unchanged from V1 so the module upgrade stays
    ; call-compatible. Not needed for the already-live accounts; use
    ; update-xchain-gas-account for those.
    (defun create-xchain-gas-account:string (kadena-or-stoa:bool)
        @doc "Creates the CrossChain Gas Paying Account, either in the legacy name of \
            \ <kadena-xchain-gas> or in the new StoaChain name, now being <stoa-xchain-gas>, \
            \ carrying the V2 live-floor guard."
        (with-capability (GOVERNANCE)
            (let
                (
                    (account-name:string (UC_XChainGasAccountName kadena-or-stoa))
                )
                (coin.C_CreateAccount account-name (UDC_XChainGasGuard))
                (format "Account <{}> succesfully created with live-floor guard" [account-name])
            )
        )
    )

    ; -- Upgrade an EXISTING account guard, in place (admin-only) --
    (defun update-xchain-gas-account:string (kadena-or-stoa:bool)
        @doc "Rotates an already-live CrossChain Gas Paying Account off the frozen price \
            \ ceiling of V1 and onto the V2 live-floor guard, in place. The account keeps \
            \ its name and its balance. Sign with ns-admin-keyset: it satisfies GOVERNANCE \
            \ here and the admin branch of the existing account guard, which is what \
            \ coin.rotate -> ROTATE -> UEV_Rotate -> CAP_Account enforces."
        (with-capability (GOVERNANCE)
            (let
                (
                    (account-name:string (UC_XChainGasAccountName kadena-or-stoa))
                )
                (coin.C_RotateAccount account-name (UDC_XChainGasGuard))
                (format "Account <{}> succesfully rotated onto the live-floor guard" [account-name])
            )
        )
    )
    ;;
)

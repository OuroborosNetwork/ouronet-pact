;;  stoic-xchainV3.pact
;;
;;  V3 of <stoa-ns.stoic-xchain>. Same module name as V1 and V2, so deploying
;;  this file is a second in-place MODULE UPGRADE, governed by ns-admin-keyset.
;;  The V1 and V2 files are left on disk for reference.
;;
;;  ---------------------------------------------------------------------------
;;  WHAT CHANGED FROM V2
;;  ---------------------------------------------------------------------------
;;  V2 fixed the frozen ceiling (see HISTORY below) but pinned the ceiling to
;;  EXACTLY the live floor:
;;
;;      gasPrice <= F(blockTime)
;;
;;  That rejects a small but real class of correctly-priced transactions.
;;  Chainweb permits a transaction's creationTime to run AHEAD of its parent
;;  block by defaultLenientTimeSlop = 95 seconds
;;  (chainweb: src/Chainweb/Pact5/Validations.hs:256), while the Stoa block delay
;;  is 30 seconds (src/Chainweb/Version/Stoa.hs:71). So creationTime can
;;  legitimately be up to ~65 s LATER than the block that mines the transaction.
;;  If a 3-hour tick boundary falls inside that window then
;;
;;      F(creationTime) = F(blockTime) + 1
;;
;;  and a transaction priced at F(creationTime) -- which is exactly what the Yin
;;  engine's consensus floor will require -- fails this ceiling. Roughly 1 in 700
;;  cross-chain transfers, non-reproducible, and invisible in ordinary testing.
;;
;;  Because 95 s is far smaller than the 10,800 s tick, at most ONE boundary can
;;  ever fall inside that window, so a buffer of 1 ANU is provably sufficient.
;;  V3 uses 10 ANU: an order of magnitude over the provable requirement, and
;;  still only ~0.09% of today's floor, so the added drain exposure is nil.
;;
;;      gasPrice <= F(blockTime) + GAS-PRICE-BUFFER-ANU
;;
;;  ---------------------------------------------------------------------------
;;  WHY THE PREDICATE KEEPS ITS EXACT NAME  (do not rename it)
;;  ---------------------------------------------------------------------------
;;  The live account guards store a reference to
;;      (stoic-xchain, enforce-at-or-below-current-min-gas-price, [])
;;  It is not yet settled whether a Pact user guard resolves that reference
;;  against the CURRENT module version, or pins the module version it was created
;;  with. Keeping the function name byte-identical makes BOTH cases safe:
;;
;;    * if guards resolve dynamically, the module upgrade alone applies the fix
;;      and the rotation is belt-and-braces;
;;    * if guards pin the module version, the existing guard keeps working with
;;      V2 behaviour right up until the rotation lands.
;;
;;  Either way there is NO window in which the stations are unable to pay.
;;  Renaming the predicate would destroy that guarantee. The name is therefore
;;  load-bearing even though it now reads slightly narrower than what it does.
;;
;;  ---------------------------------------------------------------------------
;;  HISTORY
;;  ---------------------------------------------------------------------------
;;  V1  Froze the floor at account-creation time. `create-user-guard` strictly
;;      evaluates and FREEZES its arguments, so
;;      (enforce-below-or-at-gas-price <computed floor>) baked in the floor as of
;;      genesis -- 10,000 ANU -- and never moved. Both stations therefore shared
;;      the same dead 0.00000001 STOA ceiling. Proven on pact 5.4.1:
;;      proof-user-guard-freezes.repl (passes) and show-frozen.repl, which prints
;;      pact's own "FROZEN: guard captured 1 but live block-height is 500".
;;  V2  Replaced it with an ARGUMENT-LESS predicate that reads the floor live at
;;      enforcement time, and added update-xchain-gas-account so live accounts
;;      could be rotated in place rather than recreated.
;;  V3  Adds the 10 ANU buffer described above.
;;
;;  ---------------------------------------------------------------------------
;;  DEPLOY / USE  (all of this BEFORE the v3.2.1-stoa.3 fork height)
;;  ---------------------------------------------------------------------------
;;   1. Deploy this file, signed with ns-admin-keyset -> upgrades the module.
;;   2. Rotate both live stations:
;;        (stoa-ns.stoic-xchain.update-xchain-gas-account true)   ; kadena-xchain-gas
;;        (stoa-ns.stoic-xchain.update-xchain-gas-account false)  ; stoa-xchain-gas
;;      ns-admin-keyset satisfies BOTH gates: GOVERNANCE here, and the account's
;;      existing enforce-or(ns-admin-keyset, ..) admin branch, which is what
;;      coin.rotate -> ROTATE -> UEV_Rotate -> CAP_Account enforces.
;;   3. Confirm both stations still pay a cross-chain transfer.
;;   4. Drain kadena-xchain-gas into stoa-xchain-gas once it is no longer needed.

(module stoic-xchain GOVERNANCE
    ;;
    @doc "V3 - Module for initializing and MAINTAINING the <kadena-xchain-gas> and \
        \ <stoa-xchain-gas> Accounts needed to autonomously pay crosschain-transactions. \
        \ The gas-price ceiling is read live at enforcement time and carries a small \
        \ buffer above the protocol minimum, so a transaction priced at its own \
        \ creation-time floor is never rejected for having crossed a tick boundary."

    (use coin)
    (use util.guards)
    (use util.gas-guards)

    ;; -- Constants --
    ;; ANU permitted ABOVE the live protocol minimum. 1 is provably sufficient
    ;; (the 95 s creation-time slop cannot span more than one 10,800 s tick);
    ;; 10 gives an order of magnitude of margin at ~0.09% of today's floor.
    (defconst GAS-PRICE-BUFFER-ANU                  10)

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

    ; -- The live-floor price predicate --
    ; !! THE NAME OF THIS FUNCTION IS LOAD-BEARING. The already-created account
    ; !! guards reference it by name. See the header before touching it.
    (defun enforce-at-or-below-current-min-gas-price:bool ()
        @doc "Enforces the transaction gas price is at or below the CURRENT protocol \
            \ minimum plus GAS-PRICE-BUFFER-ANU. Takes NO argument on purpose: \
            \ coin.UC_MinimumGasPriceANU is read live in this body on every enforcement, \
            \ so the ceiling rises with the floor instead of freezing at guard-creation \
            \ time the way the V1 one did. The buffer absorbs the case where a tick \
            \ boundary falls between a transaction's creationTime and the block that \
            \ mines it."
        (let
            (
                (tx-gas-price-anu:decimal   (* (chain-gas-price) 1000000000000.0))
                (ceiling-anu:integer        (+ (coin.UC_MinimumGasPriceANU) GAS-PRICE-BUFFER-ANU))
            )
            (enforce
                (<= tx-gas-price-anu (dec ceiling-anu))
                (format "Gas Price {} ANU must be smaller than or equal to the current protocol minimum plus the {} ANU buffer, i.e. {} ANU"
                    [tx-gas-price-anu GAS-PRICE-BUFFER-ANU ceiling-anu])
            )
        )
    )

    ; -- The full gas-station guard, shared by create + update --
    ; Structurally identical to V1 and V2: admin OR (gas-only AND price AND
    ; limit<=850). Only the price sub-guard has ever changed, and it is the same
    ; guard for BOTH accounts -- there is no kadena/stoa branch, because the two
    ; V1 branches froze to the same 10,000 ANU value anyway.
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
            \ carrying the V3 live-floor guard."
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
        @doc "Rotates an already-live CrossChain Gas Paying Account onto the current \
            \ live-floor guard, in place. The account keeps its name and its balance. \
            \ Sign with ns-admin-keyset: it satisfies GOVERNANCE here and the admin branch \
            \ of the existing account guard, which is what coin.rotate -> ROTATE -> \
            \ UEV_Rotate -> CAP_Account enforces."
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

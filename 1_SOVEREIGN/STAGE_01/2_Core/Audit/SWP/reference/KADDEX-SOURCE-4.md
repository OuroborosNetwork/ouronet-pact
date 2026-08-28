# Kaddex source dump — part 4 of 4: `gas-station`, `liquidity-helper`, `staking`, `wrapper`

> Same provenance note as `KADDEX-SOURCE-1.md` — external Kadena-mainnet reference material,
> pasted verbatim by the owner. Read `KADDEX-COMPARISON-HANDOFF.md` first.
>
> Note: `wrapper` as pasted has most of its public surface replaced with `(enforce-disabled)` —
> it reads as a module that was live once (real schemas/tables/caps for a fee-boosting LP wrapper
> with TWAP-based reward claims) and has since been turned off in place, keeping state/read
> functions but killing every mutating entrypoint. `staking` and `liquidity-helper` are both live.

---

## `kaddex.gas-station`

```pact
(module gas-station GOVERNANCE
  (defcap GOVERNANCE ()
    (enforce-guard (keyset-ref-guard 'kaddex-gas-admin)))

  (implements gas-payer-v1)
  (use coin)
  (use kaddex.gas-guards)

  (defconst GAS_STATION:string "kaddex-free-gas")

  (defconst MIN_GAS_PRICE:decimal 0.0000001)
  (defconst MAX_GAS_LIMIT:integer 100000) ;; TODO: use a better value based on what transactions actually cost
  (defconst MAX_TX_CALLS:integer 5)

  (defcap GAS_PAYER:bool
    ( user:string
      limit:integer
      price:decimal
    )
    (enforce (= "exec" (at "tx-type" (read-msg))) "Inside an exec")
    (enforce (> (length (at "exec-code" (read-msg))) 0) "Tx at least one pact function")
    (enforce (<= (length (at "exec-code" (read-msg))) MAX_TX_CALLS) "Tx has too many pact functions")
    (let
      ( (enforce-ns (lambda (i) (enforce (= "(kaddex." (take 8 (at i (at "exec-code" (read-msg))))) "only kaddex namespace on top level")))
        (len (length (at "exec-code" (read-msg))))
      )
      (map (enforce-ns) (enumerate 0 (- len 1)))
    )
    (enforce-below-or-at-gas-price MIN_GAS_PRICE)
    (enforce-below-or-at-gas-limit MAX_GAS_LIMIT)
    (compose-capability (ALLOW_GAS))
  )

  (defcap ALLOW_GAS () true)

  (defun init ()
    (coin.create-account GAS_STATION
      (guard-any
        [
          (create-gas-payer-guard)
          (keyset-ref-guard 'kaddex-gas-admin)
        ]))
  )

  (defun create-gas-payer-guard:guard ()
    (create-user-guard (gas-payer-guard))
  )

  (defun gas-payer-guard ()
    (require-capability (GAS))
    (require-capability (ALLOW_GAS))
  )
)
```

---

## `kaddex.liquidity-helper`

```pact
(module liquidity-helper GOVERNANCE

  (defcap GOVERNANCE ()
    (enforce-guard (keyset-ref-guard 'kaddex-wrapper-admin)))

  (defschema account
      account:string
    guard:guard)
  (deftable temporary-accounts:{account}) ;; keyed by exchange pair key

  (defcap ACCOUNT_ACCESS (pair-key:string)
    true)
  (defun enforce-account-access (pair-key:string seed:integer)
    (require-capability (ACCOUNT_ACCESS pair-key)))
  (defun create-account-guard (pair-key:string seed:integer)
    (create-user-guard (enforce-account-access pair-key seed)))

  (defun get-pair-key:string (tokenA:module{fungible-v2} tokenB:module{fungible-v2})
    (exchange.get-pair-key tokenA tokenB))

  (defun get-or-create-temp-account:{account} (tokenA:module{fungible-v2} tokenB:module{fungible-v2})
         (let ((pair-key (get-pair-key tokenA tokenB)))
           (with-default-read temporary-accounts pair-key
             { 'account: "", 'guard: (create-account-guard "" -1) }
             { 'account := account, 'guard := guard }
             (if (!= account "")
                 { 'account: account, 'guard: guard }
                 (create-temp-account-with-seed tokenA tokenB 0))
             )
           ))

  (defun create-temp-account-with-seed:{account} (tokenA:module{fungible-v2} tokenB:module{fungible-v2} seed:integer)
         (let ((pair-key (get-pair-key tokenA tokenB)))
           (with-default-read temporary-accounts pair-key
             { 'account: "" }
             { 'account := account }
             (enforce (= account "") "liquidity-helper: temporary account already exists for pair")
             (let* ((account-guard (create-account-guard pair-key seed))
                    (account-name (create-principal account-guard))
                    (account-rec { 'account: account-name, 'guard: account-guard }))
               (tokenA::create-account account-name account-guard)
               (tokenB::create-account account-name account-guard)
               (with-capability (ACCOUNT_ACCESS pair-key)
                 (enforce-guard (at 'guard (tokenA::details account-name)))
                 (enforce-guard (at 'guard (tokenB::details account-name))))
               (insert temporary-accounts pair-key account-rec)
               account-rec
               )
             )
           ))

  (defun get-one-sided-liquidity-swap-amount:decimal (
                                                      A:decimal ;; reserves of tokenA
                                                      T:decimal ;; total amount of tokens (A)
                                                      )
    "Internal low-level function used for calculating one-sided liquidity swap amounts."
    ;; this returns an input amount of tokens to swap for B that satisfies:
    ;; (= (quote (- T x) A B) (compute-out x A B))
    ;; this value needs to be truncated to the token precision (and may not
    ;; be exact and leave some dust behind)
    (let ((fee (- 1.0 exchange.FEE)))
      (/ (+ (* (sqrt A)
               (sqrt (+ (* A (* fee fee))
                        (+ (* 2 (* A fee))
                           (+ A
                              (* 4 (* fee T)))))))
            (+ (* A (* fee -1))
               (* A -1)))
         (* 2 fee))))

  (defun get-add-liquidity-token-amount-after-swap:decimal (
                                                            amountA-total:decimal
                                                            tokenA:module{fungible-v2}
                                                            tokenB:module{fungible-v2}
                                                            slippage:decimal ;; this value needs to be greater than or equal to 1
                                                            ;; a value of 1.01 gives a 1% slippage
                                                            )
    "Returns the tokenB amount to use for signing a TRANSFER capability when doing an `add-liquidity-one-sided` call."
    ;; this function is used for signing a TRANSFER capability for tokenB
    ;; for use with add-liquidity-one-sided. We transfer the swapped tokens
    ;; back to the sender and then transfer from the sender to the liquidity
    ;; pool (and thus need the TRANSFER cap for the final step)
    (enforce (>= slippage 1.0) "get-add-liquidity-token-amount-after-swap: Slippage values below 1.0 will cause the transaction to fail")
    (let*
        ( (p (exchange.get-pair tokenA tokenB))
         (reserveA (exchange.reserve-for p tokenA))
          (amountB-in (exchange.truncate tokenB (get-one-sided-liquidity-swap-amount reserveA amountA-total)))
          (alloc {  'token-out: tokenA
                                , 'token-in: tokenA
                                , 'out: amountB-in
                                , 'in: 0.0
                                , 'idx: 0
                                , 'pair: p
                                , 'path: [tokenB]
                                })
          (out-result (exchange.compute-out [alloc] tokenB))
          )
      ;; multiply by the slippage in case the price changes between the user
      ;; querying this function and calling the function below
      (exchange.truncate tokenB (* slippage (at 'out (at 0 out-result))))
      )
    )

  (defun add-liquidity-one-sided:object (
                                         token-in:module{fungible-v2}
                                         token-other:module{fungible-v2}
                                         amount-in-total:decimal
                                         amount-in-min:decimal
                                         amount-other-min:decimal
                                         sender:string
                                         sender-guard:guard
                                         to:string
                                         to-guard:guard
                                         use-wrapper:bool
                                         )
    "Adds liquidity to the tokenA/tokenB pair using only tokenA. Will automatically swap about half of the amountA-total into tokenB to provide the liquidity."
    (enforce (and (and (> amount-in-total 0.0) (>= amount-in-min 0.0)) (>= amount-other-min 0.0)) "add-liquidity-one-sided: Values must be positive")
    (enforce (!= sender "") "Invalid sender")
    (enforce (!= to "") "Invalid target")
    (token-in::enforce-unit amount-in-total)
    (token-in::enforce-unit amount-in-min)
    (token-other::enforce-unit amount-other-min)
    (let* ( (order-ok (exchange.is-canonical token-in token-other))
           (p (exchange.get-pair token-in token-other))
            (reserve-in (exchange.reserve-for p token-in))
            (swap-amount-in (exchange.truncate token-in (get-one-sided-liquidity-swap-amount reserve-in amount-in-total)))
            (amount-in-liq (exchange.truncate token-in (- amount-in-total swap-amount-in)))
            )
      (enforce (>= amount-in-liq amount-in-min) "Insufficient A amount")
      (let* ( ;; perform the swap
             (swap-result (exchange.swap-exact-in swap-amount-in 0.0 [token-in token-other] sender sender sender-guard))
             (amount-other (at 'amount (at 1 swap-result)))
             )
        (enforce (>= amount-other amount-other-min) "Insufficient B amount")
        ;; add the liquidity as normal
        (if use-wrapper
            (if order-ok
                (wrapper.add-liquidity token-in token-other amount-in-liq amount-other amount-in-min amount-other-min sender to to-guard)
                (wrapper.add-liquidity token-other token-in amount-other amount-in-liq amount-other-min amount-in-min sender to to-guard))
            (if order-ok
                (exchange.add-liquidity token-in token-other amount-in-liq amount-other amount-in-min amount-other-min sender to to-guard)
                (exchange.add-liquidity token-other token-in amount-other amount-in-liq amount-other-min amount-in-min sender to to-guard))
            )
        )
      )
    )

  (defun remove-liquidity-one-sided:object (
                                            token-out:module{fungible-v2}   ;; the token the user wants to receive
                                            token-other:module{fungible-v2} ;; the other token of the pool
                                            requested-liquidity:decimal     ;; liquidity being removed
                                            amount-out-min-liquidity:decimal          ;; minimum amount of `token-out` that needs to be received after remove-liquidity
                                            amount-other-min-liquidity:decimal        ;; minimum amount of `token-other` that needs to be received after remove-liquidity
                                            swap-slippage:decimal           ;; the max slippage used for the swap of token-other for token-out. a value of 0.95 gives 5% slippage (1 - slippage)
                                            sender:string
                                            to:string
                                            to-guard:guard
                                            use-wrapper:bool                ;; whether to use kaddex.wrapper or kaddex.exchange
                                            wants-kdx-rewards:bool          ;; if using the wrapper, whether the user wants the kdx rewards or not
                                            )
    "Removes liquidity from the tokenA/tokenB pair and swaps all tokenB for tokenA afterwards."
    (enforce (> requested-liquidity 0.0) "remove-liquidity-one-sided: Liquidity must be positive")
    (enforce (!= sender "") "Invalid sender")
    (enforce (!= to "") "Invalid target")
    (enforce (or (not wants-kdx-rewards) (and use-wrapper wants-kdx-rewards)) "KDX rewards are only available via the wrapper")
    (enforce (and (> swap-slippage 0.0) (<= swap-slippage 1.0)) "remove-liquidity-one-sided: Invalid slippage")
    (tokens.enforce-unit (exchange.get-pair-key token-out token-other) requested-liquidity)
    (token-out::enforce-unit amount-out-min-liquidity)
    (token-other::enforce-unit amount-other-min-liquidity)
    (let* (
           (pair-key (get-pair-key token-out token-other))
           (temp-account (get-or-create-temp-account token-out token-other))
           (tmp-acc (at 'account temp-account))
           (tmp-guard (at 'guard temp-account))
           (initial-temp-out-balance (token-out::get-balance tmp-acc))
           (initial-temp-other-balance (token-other::get-balance tmp-acc))
           (order-ok (exchange.is-canonical token-out token-other))
           (remove-result (if use-wrapper
                              (if order-ok
                                  (wrapper.remove-liquidity-extended token-out token-other requested-liquidity amount-out-min-liquidity amount-other-min-liquidity sender tmp-acc tmp-guard wants-kdx-rewards to to-guard)
                                  (wrapper.remove-liquidity-extended token-other token-out requested-liquidity amount-other-min-liquidity amount-out-min-liquidity sender tmp-acc tmp-guard wants-kdx-rewards to to-guard))
                              (if order-ok
                                  (exchange.remove-liquidity token-out token-other requested-liquidity amount-out-min-liquidity amount-other-min-liquidity sender tmp-acc tmp-guard)
                                  (exchange.remove-liquidity token-other token-out requested-liquidity amount-other-min-liquidity amount-out-min-liquidity sender tmp-acc tmp-guard))
                              ))
           )
      (let* ( ;; perform the swap
             (amount-out-before (if use-wrapper (if order-ok (at 'amountA remove-result) (at 'amountB remove-result)) (if order-ok (at 'amount0 remove-result) (at 'amount1 remove-result))))
             (amount-other (if use-wrapper (if order-ok (at 'amountB remove-result) (at 'amountA remove-result)) (if order-ok (at 'amount1 remove-result) (at 'amount0 remove-result))))
             (pair (exchange.get-pair token-out token-other))
             (reserve-out (exchange.reserve-for pair token-out))
             (reserve-other (exchange.reserve-for pair token-other))
             (quote-out (exchange.quote amount-other reserve-other reserve-out))
             (amount-out-min-swap (exchange.truncate token-out (* swap-slippage quote-out)))
             (pair-account (at 'account (exchange.get-pair token-out token-other)))
             )

        (install-capability (token-other::TRANSFER tmp-acc pair-account amount-other))
        (with-capability (ACCOUNT_ACCESS pair-key)
          (let* ((swap-result (exchange.swap-exact-in amount-other amount-out-min-swap [token-other token-out] tmp-acc to to-guard))
                 (swap-amount (at 'amount (at 1 swap-result))))
            (install-capability (token-out::TRANSFER tmp-acc to amount-out-before))
            (token-out::transfer-create tmp-acc to to-guard amount-out-before)
            (let (
                  (final-temp-out-balance (token-out::get-balance tmp-acc))
                  (final-temp-other-balance (token-other::get-balance tmp-acc))
                  )
              (enforce (and (= initial-temp-out-balance final-temp-out-balance)
                            (= initial-temp-other-balance final-temp-other-balance)) "Conservation of mass")
              { 'remove-result: remove-result, 'swap-result: swap-result, 'total-amount: (exchange.truncate token-out (+ swap-amount amount-out-before)) }
              )
            )
          )
        )
      )
    )
  )
```

---

## `kaddex.staking`

```pact
(module staking GOVERNANCE
  (defcap GOVERNANCE () (enforce-guard (keyset-ref-guard 'kaddex-staking-admin)))

  (defcap OPS () (enforce-guard (keyset-ref-guard 'kaddex-staking-ops)))

  ;; this is a simple global lock that can be toggled by the operators to pause the contract if necessary
  (defschema contract-lock-status
      lock:bool)
  (deftable contract-lock:{contract-lock-status})
  (defconst CONTRACT_LOCK_KEY 'lock)
  (defun enforce-contract-unlocked ()
    "Asserts that the contract is not in a paused state."
    (with-read contract-lock CONTRACT_LOCK_KEY { 'lock := lock }
      (enforce (not lock) "Contract is paused")))
  (defun set-contract-lock
    ( lock:bool )
    (with-capability (OPS)
      (write contract-lock CONTRACT_LOCK_KEY {'lock: lock })))

  (defcap REWARD_BURN (from:string amount:decimal)
    "Emitted when some rewards are burnt due to early claim."
    @event
    true)
  (defcap STAKE_BURN (from:string amount:decimal)
    "Emitted when some staked amount is burnt due to early unstake."
    @event
    true)

  (defcap BASE_GUARD (account:string)
    "Base used to enforce KDX guard for staking operations."
    (enforce-contract-unlocked)
    (enforce-guard (at 'guard (kdx.details account))))

  (defcap UNSTAKE (account:string)
    "Capability to unstake some amount of KDX from the given account."
    (compose-capability (BASE_GUARD account)))
  (defcap STAKE (account:string amount:decimal)
    "Capability to stake the given amount of KDX into the given account."
    (compose-capability (BASE_GUARD account)))
  (defcap CLAIM (account:string)
    "Capability to claim staking rewards."
    (compose-capability (BASE_GUARD account)))
  (defcap ROLLUP (account:string)
    "Capability to realize staking rewards into staking record."
    (compose-capability (BASE_GUARD account)))

  (defun format-token:string (token:module{fungible-v2})
    (format "{}" [token]))

  (defcap WRAPPING () true)
  (defcap HOLDING_ACCOUNT (token:string name:string) true)
  (defcap SWEEPING (tokenA:string tokenB:string) true)
  (defcap AGGREGATOR_NOTIFY () true)

  (defun enforce-wrapping () (require-capability (WRAPPING)))
  (defun enforce-account-access (token:string name:string)
    (require-capability (HOLDING_ACCOUNT token name)))
  (defun enforce-sweeping (tokenA:string tokenB:string)
    (require-capability (SWEEPING tokenA tokenB)))
  (defun enforce-aggregator-update () (require-capability (AGGREGATOR_NOTIFY)))

  (defcap INTERNAL ()
    "Used for contract internal operations."
    true)

  (defschema stake-lock
    "A lock placed on a staked amount."
    amount:decimal
    until:time)

  (defschema stake-record
    "Staking participants."
    account:string
    amount:decimal
    rollover:decimal
    effective-start:time
    last-stake:time
    last-claim:time
    start-cumulative:decimal
    pending-add:decimal
    last-add-request:time
    locks:[object{stake-lock}])

  ; Pending adds get piled up until operator decides to include into pool
  ; Inclusion into pool triggers same logic as currently
  ; Unstake works the same; only works on added amount

  (deftable stake-table:{stake-record})

  (defschema pair-record
    "Pairs participating in the staking program."
    key:string
    fee-account:string
    fee-guard:guard
    pair-account:string
    pair-guard:guard)

  (deftable pair-table:{pair-record})

  (defschema token-record
    "Tokens participating in the staking program."
    token:module{fungible-v2}
    account:string
    guard:guard)

  (deftable token-table:{token-record})

  (defschema pool-state
    "Global pool state."
    revenue-per-kdx:decimal
    staked-kdx:decimal
    burnt-kdx:decimal)

  (deftable state-table:{pool-state})

  ;; Row key for the single entry in state-table.
  (defconst STATE_KEY:string "state")

  ;; Name of the KDX account for the staking contract.
  (defconst KDX_BANK:string "kdx-staking")

  ;; The stake penalty period from the last stake add request. Within this period,
  ;; unstakes are penalized by PENALTY_FRACTION.
  (defconst PENALTY_PERIOD:decimal (days 3))
  ;; The reward penalty period from the "effective start date". Within this period,
  ;; reward claims are penalized by:
  ;; (1 - (seconds-since-add / MATURATION_PERIOD)) ^ MATURATION_COEFFICIENT
  (defconst MATURATION_PERIOD:decimal (days 60))
  ;; Cooldown period between reward claims.
  (defconst CLAIM_EVERY:decimal (days 7))

  ;; Stake penalty incurred when unstaking within the PENALTY_PERIOD after
  ;; adding a staked amount.
  (defconst PENALTY_FRACTION:decimal 0.03)
  ;; Coefficient for the reward penalty curve.
  (defconst MATURATION_COEFFICIENT:decimal 0.66)

  ;; Used as a "far back in the past" value in timestamp fields.
  (defconst PAST_EPOCH:time (time "1970-01-01T00:00:00Z"))

  ;; Module guard for fungible-v2 accounts.
  (defun token-guard:guard (token:string account:string)
    (create-user-guard (enforce-account-access token account)))
  ;; Module guard for Alchemist permission.
  (defun wrap-guard:guard () (create-user-guard (enforce-wrapping)))
  ;; Module guard for feeTo LP token accounts.
  (defun fee-guard:guard (tokenA:string tokenB:string)
    (create-user-guard (enforce-sweeping tokenA tokenB)))
  (defun aggregator-guard:guard () (create-user-guard (enforce-aggregator-update)))

  (defun get-kdx-guard:guard (account:string)
    "Extract account guard for a given KDX account."
    (at 'guard (kdx.details account)))

  (defun init ()
    "Initialize the module."
    ;; Create KDX and sKDX accounts.
    (kdx.create-account KDX_BANK (token-guard (format-token kdx) KDX_BANK))
    (with-capability (HOLDING_ACCOUNT (format-token kdx) KDX_BANK) ;; We need to pass the kdx guard here
      (skdx.create-account KDX_BANK (token-guard (format-token skdx) KDX_BANK)))
    ;; Insert the contract lock row.
    (insert contract-lock CONTRACT_LOCK_KEY {'lock: false})
    ;; Insert the pool state row. Also makes sure init can't be called more than
    ;; once, as insert would fail.
    (insert state-table STATE_KEY { 'revenue-per-kdx: 0.0, 'staked-kdx: 0.0, 'burnt-kdx: 0.0 }))

  (defun calculate-reward:decimal
    (start:decimal
     amount:decimal)
    "Given a cumulative start amount (start-cumulative in stake-record) and a \
    \ staked KDX amount, calculate current deserved rewards."
    (if (= amount 0.0) 0.0 ;; short-circuit if amount 0
      (with-read state-table STATE_KEY { 'revenue-per-kdx := revenue }
        (if (>= start revenue) 0.0 ;; short circuit if start-cumulative is "in the future"
          ;; given staked amount and cumulative/monotonic revenue-per-kdx, deserved
          ;; reward is (current-revenue-per-kdx - start-revenue-per-kdx) * staked-amount
          (floor (* (- revenue start) amount) (kdx.precision))))))

  (defun calculate-penalty:decimal
    (seconds:decimal
     amount:decimal)
    "Given a reward amount and seconds passed since effective-start, calculate \
    \ reward penalty. Applies the reward penalty curve as described above \
    \ defconst MATURATION_COEFFICIENT."
    (enforce (>= seconds 0.0) ;; Enforce that some time has passed from effective-start.
      (format "Violation of causality ({} seconds staked)" [seconds]))
    (if (> seconds MATURATION_PERIOD) 0.0 ;; No penalty after maturation.
      (if (= MATURATION_COEFFICIENT 0.0) 0.0 ;; No penalties if MATURATION_COEFFICIENT is 0.
        (let*
          ( (maturation-fraction (/ seconds MATURATION_PERIOD))
            (penalty-base (- 1.0 maturation-fraction))
            (penalty-exp (^ penalty-base MATURATION_COEFFICIENT)))
          (floor (* amount penalty-exp) (kdx.precision))))))

  (defun calculate-unlocked-stake:decimal (amount:decimal locks:[object{stake-lock}])
    "Given a stake amount and a list of stake locks, calculate the unlocked amount \
    \ at the current block time."
    (let*
      ( (now (at 'block-time (chain-data)))
        (is-lock-active (lambda (lock:object{stake-lock}) (< now (at 'until lock))))
        (active-locks (filter (is-lock-active) locks)) ;; filter input locks by validity
        (locked-amount (fold (+) 0.0 (map (at 'amount) active-locks)))
      )
      (if (> locked-amount amount) 0.0
        (- amount locked-amount))))

  (defun read-unlocked-stake:decimal (account:string)
    "Given an account name, fetch and calculate the unlocked stake amount at the \
    \ current block time."
    (with-read stake-table account
      { 'amount := amount
      , 'locks := locks }
      (calculate-unlocked-stake amount locks)))

  (defun onboard-with-lock (from:string to:string to-guard:guard amount:decimal locks:[object{stake-lock}])
    "Operator-only function to create a stake record with a given account name \
    \ and guard, staked amount, and stake locks. The backing KDX must be provided \
    \ to the contract at this time (from the _from_ account) to be locked up with \
    \ Alchemist."
    (with-capability (OPS)
      (enforce (> amount 0.0) "amount must be positive")
      (enforce (= [] (filter (compose (at 'amount) (> 0.0)) locks)) "locks must have positive amounts")
      (enforce (>= amount (fold (+) 0.0 (map (at 'amount) locks))) "locks cannot exceed provided amount")
      (with-capability (WRAPPING)
        (alchemist.wrap amount kaddex.skdx from to to-guard)) ;; Lock up backing KDX provided by _from_
      (let ((now (at 'block-time (chain-data))))
        (with-default-read stake-table to
          { 'account: ""
          , 'amount: 0.0
          , 'last-claim: PAST_EPOCH
          , 'effective-start: PAST_EPOCH
          , 'last-stake: PAST_EPOCH
          , 'start-cumulative: 0.0
          , 'pending-add: 0.0
          , 'rollover: 0.0
          , 'locks: [] }
          { 'account := account
          , 'amount := prev-amount
          , 'rollover := prev-rollover
          , 'last-claim := last-claim
          , 'last-stake := last-stake
          , 'effective-start := effective-start
          , 'start-cumulative := start-cumulative
          , 'pending-add := prev-pending-add
          , 'locks := prev-locks }
          (write stake-table to
            { 'account: to
            , 'amount: prev-amount
            , 'last-stake: last-stake
            , 'last-add-request: now
            , 'pending-add: (+ amount prev-pending-add)
            , 'effective-start: effective-start
            , 'start-cumulative: start-cumulative
            , 'rollover: prev-rollover
            , 'last-claim: last-claim
            , 'locks: (+ prev-locks locks) })))))

  (defun calculate-out:decimal
    (start:decimal
     seconds:decimal
     amount:decimal)
    "Given a start-cumulative value, seconds passed since effective-start, and \
    \ a staked KDX amount, calculate a net reward amount (deserved reward - reward penalty)"
    (let ((reward (calculate-reward start amount)))
      (- reward (calculate-penalty seconds reward))))

  (defun inspect-staker (account:string)
    "Return an object containing various properties of the given staking account. \
    \ Used by the frontend."
    (let ((stake-record (get-stake-record account)))
      (bind stake-record
        { 'amount := stake-amount
        , 'locks := locks
        , 'rollover := rollover
        , 'effective-start := effective-start
        , 'start-cumulative := start-cumulative
        , 'last-claim := last-claim }
        (let*
          ( (now (at 'block-time (chain-data)))
            (available-amount (calculate-unlocked-stake stake-amount locks))
            (seconds (diff-time now effective-start))
            (seconds-since-claim (diff-time now last-claim))
            (reward (calculate-reward start-cumulative stake-amount))
            (current-cumulative (at 'revenue-per-kdx (read state-table STATE_KEY)))
            (new-rollover (+ rollover reward))
            (reward-penalty (calculate-penalty seconds new-rollover))
            (stake-penalty (if (< seconds PENALTY_PERIOD) (floor (* available-amount PENALTY_FRACTION) (kdx.precision)) 0.0))
            (can-claim (>= seconds-since-claim CLAIM_EVERY)))
          { 'current-time: now
          , 'can-claim: can-claim
          , 'reward-accrued: new-rollover
          , 'reward-penalty: reward-penalty
          , 'staked: stake-amount
          , 'staked-unlocked: available-amount
          , 'unstake-penalty: stake-penalty
          , 'stake-record: stake-record }))))

  (defun rollup:decimal (account:string)
    "Realize a given account's deserved reward amount into the rollover field of \
    \ their stake record, resetting start-cumulative to the current revenue-per-kdx \
    \ number. Should be done before any unstake or reward claim."
    (with-capability (ROLLUP account)
    (with-read stake-table account
      { 'amount := amount
      , 'rollover := rollover
      , 'effective-start := effective-start
      , 'start-cumulative := start-cumulative }
      (let*
        ( ;; Calculate the gross deserved reward. Do not factor in penalties at
          ;; this stage, because the user isn't claiming their reward yet.
          (reward (calculate-reward start-cumulative amount))
          ;; Since we're "using up" the collected rewards between current-cumulative
          ;; and start-cumulative, update the start-cumulative field of the record
          ;; to avoid double dipping.
          (current-cumulative (at 'revenue-per-kdx (read state-table STATE_KEY)))
          ;; Rollover is a field that contains all realized and unclaimed rewards.
          (new-rollover (+ rollover reward)))
        (enforce (>= reward 0.0) "Reward must be nonnegative")
        (update stake-table account
          { 'start-cumulative: current-cumulative
          , 'rollover: new-rollover })
        ;; Return the new rollover value.
        new-rollover))))

  (defun claim (account:string)
    "Claim (withdraw) the rolled over rewards for a given staking participant. \
    \ rollup must be called before this to realize the user's reward to be withdrawn. \
    \ The reward penalty is incurred at this point."
    (with-capability (CLAIM account)
    (with-read stake-table account
      { 'rollover := rollover
      , 'effective-start := effective-start
      , 'last-claim := last-claim }
      (let*
        ( (g (at 'guard (kdx.details account)))
          (now (at 'block-time (chain-data)))
          ;; seconds is the time passed since effective-start. Used to calculate
          ;; the reward penalty.
          (seconds (diff-time now effective-start))
          ;; seconds-since-claim is the time passed since the last reward claim.
          ;; Used to calculate the claim cooldown.
          (seconds-since-claim (diff-time now last-claim))
          ;; The reward penalty to incur.
          (penalty (calculate-penalty seconds rollover))
          ;; Net rewards out.
          (net-out (- rollover penalty))
        )
        ;; The user must have some rewards realized into the rollover field.
        (enforce (> rollover 0.0) "Pre-penalty amount must be positive")
        ;; Enforce the claim cooldown period.
        (enforce (>= seconds-since-claim CLAIM_EVERY)
          (format "Can only claim every {} seconds ({} left)"
           [ CLAIM_EVERY (- CLAIM_EVERY seconds-since-claim) ]))
        ;; If the user is incurring any reward penalties, record the penalty as
        ;; burned.
        (if (<= penalty 0.0) "Skipping zero penalty"
          (with-capability (INTERNAL) (record-burn 'reward account penalty)))
        ;; If net-out is 0.0 for whatever reason, avoid making a call to unwrap.
        ;; Otherwise, unwrap some sKDX held in KDX_BANK to the staking participant's
        ;; KDX account.
        (if (<= net-out 0.0) "Skipping zero out transfer"
          (with-capability (HOLDING_ACCOUNT (format-token kaddex.skdx) KDX_BANK)
          (with-capability (WRAPPING)
            (install-capability (kdx.UNWRAP "kaddex.skdx" KDX_BANK account net-out))
            (alchemist.unwrap net-out kaddex.skdx KDX_BANK account g))))
        ;; Reset rollover to 0. Mark last claim event.
        (update stake-table account
          { 'rollover: 0.0
          , 'last-claim: now })
        true))))

  (defun unstake (account:string unstake-amount:decimal)
    "Unstake some amount from the given staking account. This will call rollup \
    \ in order to realize deserved rewards with the pre-unstake stake amount. \
    \ Partial unstaking is supported, and will reset effective-start to the current \
    \ block time. If the last stake add was less than PENALTY_PERIOD ago, apply \
    \ an unstake penalty of PENALTY_FRACTION."
    (with-capability (UNSTAKE account)
    ;; Since we will be changing the user's staked amount, ensure that their
    ;; deserved rewards are realized.
    (rollup account)
    (with-read stake-table account
      { 'amount := stake-amount
      , 'locks := locks
      , 'rollover := rollover
      , 'last-stake := last-stake
      , 'effective-start := effective-start
      , 'last-claim := last-claim }
      (let*
        ( (g (get-kdx-guard account))
          ;; The maximum KDX amount that can be unstaked given any stake locks.
          (available-amount (calculate-unlocked-stake stake-amount locks))
          ;; The current pool state.
          (state (read state-table STATE_KEY))
          ;; Current amount of staked KDX in the pool.
          (total-staked-kdx (at 'staked-kdx state))
          ;; Current block time.
          (now (at 'block-time (chain-data)))
          ;; Seconds passed since last stake add. Used to calculate whether the
          ;; user is within PENALTY_PERIOD.
          (seconds (diff-time now last-stake))
          ;; Unstake penalty amount to be incurred, if any.
          (stake-penalty (if (< seconds PENALTY_PERIOD) (floor (* unstake-amount PENALTY_FRACTION) (kdx.precision)) 0.0))
          ;; The net KDX amount to be transferred to the user.
          (net-unstake (- unstake-amount stake-penalty))
        )
        ;; The user must have enough unlocked staked KDX to unstake the requested amount.
        (enforce (>= available-amount unstake-amount)
          (format "Insufficient unlocked stake ({} available {} requested)" [available-amount unstake-amount]))
        ;; The user must request a positive unstake amount.
        (enforce (> unstake-amount 0.0) "Unstake amount must be positive")
        ;; If the user is incurring an unstake penalty, unwrap their penalty from
        ;; their sKDX account into the KDX_BANK KDX account and record it as burnt
        ;; in the pool state.
        (if (<= stake-penalty 0.0) "Skipping zero penalty"
          (with-capability (INTERNAL)
          (with-capability (HOLDING_ACCOUNT (format-token kaddex.skdx) KDX_BANK)
          (with-capability (WRAPPING)
            (alchemist.unwrap stake-penalty kaddex.skdx account KDX_BANK (token-guard (format-token kdx) KDX_BANK))
            (record-burn 'stake account stake-penalty)))))
        ;; If the user has any net KDX out, unwrap that amount from their sKDX
        ;; account into their KDX account.
        (if (<= net-unstake 0.0) "Skipping zero out transfer"
          (with-capability (HOLDING_ACCOUNT (format-token kaddex.skdx) KDX_BANK)
          (with-capability (WRAPPING)
            (alchemist.unwrap net-unstake kaddex.skdx account account g))))
        ;; Inform the aggregator of an unstake event. Commented in the REPL as
        ;; the aggregator isn't integrated into here.
        (with-capability (AGGREGATOR_NOTIFY)
          (kaddex.aggregator.aggregate-unstake account unstake-amount))
        ;; Reset the user's effective-start, and decrement their staked amount
        ;; by their requested unstake amount.
        (update stake-table account
          { 'amount: (- stake-amount unstake-amount)
          , 'effective-start: now })
        ;; Update the pool state to mark a decrease in total KDX staked.
        (update state-table STATE_KEY
          { 'staked-kdx: (- total-staked-kdx unstake-amount) })
        true))))

  (defun register-token-if-unregistered (token:module{fungible-v2} hint:string)
    "Internal function to register a given fungible-v2 token within the staking \
    \ contract. Not called directly; register-pair calls this function. If a \
    \ previously unknown token is passed to this function, a corresponding token-record \
    \ row is created, and two accounts are created with the same name: one with \
    \ the given token, and another with KDX. The token account is used to receive \
    \ remove-liquidity outputs when sweeping fees, and the KDX account is used \
    \ when swapping the collected token amounts into KDX."
    ;; require-capability to avoid operators calling this function on its own
    (require-capability (OPS))
    (let
      ( (token-name (format "{}" [token]))
        ;; Generate an opaque account name given the token name and hint string.
        (account-name (hash (format "{}_{}" [token hint]))))
      (with-default-read token-table token-name
        { 'account: "" }
        { 'account := current-account }
        (if (= current-account "") ;; Continue only if the token isn't already registered
          (let ((x 0)) ;; throwaway let for many-statement if clause
            (token::create-account account-name (token-guard (format-token token) account-name)) ;; Create token account
            (if (!= token kdx) ;; If token isn't KDX, create KDX account with same name/guard.
              (kdx.create-account account-name (token-guard (format-token kdx) account-name)) {})
            (write token-table token-name ;; Create the token record.
              { 'account: account-name, 'token: token, 'guard: (token-guard (format-token token) account-name) }))
          {}))))

  (defun register-pair
    (token0:module{fungible-v2}
     token1:module{fungible-v2}
     hint:string)
    "Operator function to register a trading pair with the staking contract. \
    \ Registers the component tokens if unregistered, and takes ownership of the \
    \ exchange feeTo LP token accounts. Creates a pair-record row for the pair."
    (with-capability (OPS)
      (let*
        ( (p (exchange.get-pair token0 token1))
          (key (exchange.get-pair-key token0 token1))
          (token0-name (format "{}" [token0]))
          (token1-name (format "{}" [token1]))
          (is-canonical (< token0-name token1-name))
          (tokenA (if is-canonical token0 token1))
          (tokenB (if is-canonical token1 token0))
          (pair-account-name (hash (format "{}_{}_{}" [token0 token1 hint])))
          (fee-account (at 'fee-account p)))
        ;; Create token accounts (per-token place for remove-liq consolidation)
        (register-token-if-unregistered token0 hint)
        (register-token-if-unregistered token1 hint)
        ;; Create pair accounts (per-pair 2x accounts to receive funds
        ;; immediately from remove-liquidity, which only takes single recipient.)
        ;; The guards for these accounts are identical, as remove-liquidity takes
        ;; one guard and one account name for the output. We choose the canonical
        ;; left-hand-side token to create the guard.
        (token0::create-account pair-account-name (token-guard (format-token tokenA) pair-account-name))
        (token1::create-account pair-account-name (token-guard (format-token tokenA) pair-account-name))
        ;; Take ownership of feeTo account if not owned already.
        (exchange.rotate-fee-guard key (fee-guard (format-token tokenA) (format-token tokenB)))
        ;; Create pair record.
        (insert pair-table key
          { 'key: key
          , 'fee-account: fee-account
          , 'fee-guard: (fee-guard (format-token tokenA) (format-token tokenB))
          , 'pair-account: pair-account-name
          , 'pair-guard: (token-guard (format-token tokenA) pair-account-name)}))))

  ;; Utility functions
  (defun max:decimal (a:decimal b:decimal) (if (> a b) a b))
  (defun min:decimal (a:decimal b:decimal) (if (< a b) a b))

  (defun calculate-new-start:decimal
    (now:time
     old-start:time
     old-stake:decimal
     added:decimal)
    "Given a current effective-start, current staked amount, the current time \
    \ and an amount to be added to the user's stake, calculate a new effective-start \
    \ value. This shifts the user's position back on the reward penalty curve \
    \ proportional to their current stake and the amount being added to their stake."
    (enforce (> now old-start) "Violation of causality")
    (let*
      ( ;; The amount of time that has passed since the user's current effective-start.
        ;; (the user's current x position along the reward penalty curve). At most,
        ;; is equal to MATURATION_PERIOD (ex. if old-start is the same as
        ;; PAST_EPOCH or the user is out of the reward penalty period.)
        (penalty-passed (min MATURATION_PERIOD (diff-time now old-start)))
        ;; current-time - penalty-passed. Either the same as old-start (if user
        ;; is still in reward penalty period) or the time at which the user's
        ;; reward penalty period would have just ended.
        (base-date (add-time now (- 0.0 penalty-passed)))
        ;; The proportion of the added stake amount to the total new stake amount.
        (ratio (/ added (+ added old-stake)))
        ;; On top of base-date, the "punishment" we are applying.
        ;;   - In the base cases of "user is out of penalty period" or "user has
        ;;     no prior stake" this will be the same as MATURATION_PERIOD,
        ;;     i.e. we're starting the reward penalty period from scratch.
        ;;   - Otherwise, this will be some positive amount that will shift the
        ;;     user back on the reward penalty curve.
        (additional-penalty (* penalty-passed ratio))
        ;; Calculate the new effective-start.
        (new-start-date (add-time base-date additional-penalty))
      )
      ;; Return the new effective-start.
      new-start-date
    )
  )

  (defun read-waiting:[string] ()
    "Utility function to read the list of stakers waiting to be added to the pool. \
    \ In production, will only be called on /local due to gas costs."
    (map (at 'account) (select stake-table (where 'pending-add (< 0.0))))
  )

  (defun include-batch (accounts:[string])
    "Operator only function to include a given list of accounts into the stake \
    \ pool. This will transfer a pending-add value into the user's staked amount, \
    \ calculate their new effective-start, roll over their previous deserved \
    \ reward amount, and finally update the pool state (once) with all of the \
    \ KDX added to the pool."
    (with-capability (OPS)
      (with-read state-table STATE_KEY
        { 'revenue-per-kdx := current-cumulative
        , 'staked-kdx := staked-kdx }
        (let*
          ( ;; Call include-one with all of the accounts being included into the
            ;; pool. include-one returns the KDX added for each person, so
            ;; include-all is a list of decimals.
            (include-all (map (include-one current-cumulative) accounts))
            ;; Calculate the total amount of KDX being added to the pool.
            (total-added (fold (+) 0.0 include-all))
          )
          ;; Update the pool state with the added KDX amount.
          (update state-table STATE_KEY { 'staked-kdx: (+ staked-kdx total-added) })
        )
      )
    )
  )

  (defun include-one:decimal (current-cumulative:decimal account:string)
    "Internal, operator only function to include one staker into the pool. This \
    \ will transfer a pending-add value into the user's staked amount, calculate \
    \ their new effective-start, and roll over their previous deserved reward amount."
    (require-capability (OPS))
    (with-read stake-table account
      { 'amount := prev-amount
      , 'rollover := prev-rollover
      , 'effective-start := effective-start
      , 'start-cumulative := start-cumulative
      , 'pending-add := to-add }
      (let
        ( ;; Roll rewards up without calling out to rollup.
          (next-rollover (+ prev-rollover (calculate-reward start-cumulative prev-amount)))
          (now (at 'block-time (chain-data)))
        )
        ;; Inform the aggregator of a stake being added. Commented out in the REPL
        ;; as the aggregator isn't integrated into this repo.
        (with-capability (AGGREGATOR_NOTIFY)
          (kaddex.aggregator.aggregate-stake account to-add))
        (update stake-table account
          { 'amount: (+ to-add prev-amount)
          , 'last-stake: now
          , 'effective-start: (calculate-new-start now effective-start prev-amount to-add)
          , 'start-cumulative: current-cumulative
          , 'rollover: next-rollover
          , 'pending-add: 0.0 })
        to-add)))

  (defun stake
    (from:string
     amount:decimal)
    "Request to add a certain amount of KDX to the stake pool. This function \
    \ immediately wraps the provided KDX to sKDX, and adds the requested amount \
    \ to the stake record's pending-add field. This amount isn't yet included \
    \ into the stake pool, see include-some and include-batch for when this queued \
    \ amount is actually included into the pool. \
    \ The queue system is to mitigate unfairness, as fee sweeping is a discrete \
    \ event, and letting people into the pool at any arbitrary period would let \
    \ them unfairly partake in fees accrued between the last fee sweep and their \
    \ entry time. With the queue, the operator includes waiting participants into \
    \ the pool right after a fee sweep."
    (with-capability (STAKE from amount)
      (enforce (> amount 0.0) "amount must be positive")
      ;; Wrap the provided KDX into a sKDX account belonging to the user.
      (with-capability (WRAPPING)
        (alchemist.wrap amount kaddex.skdx from from (get-kdx-guard from)))
      ;; Write the stake-record. If no prior stake-record exists, create one
      ;; with default values.
      (with-default-read stake-table from
        { 'account: ""
        , 'amount: 0.0
        , 'last-claim: PAST_EPOCH
        , 'effective-start: PAST_EPOCH
        , 'last-stake: PAST_EPOCH
        , 'start-cumulative: 0.0
        , 'pending-add: 0.0
        , 'rollover: 0.0
        , 'locks: [] }
        { 'account := account
        , 'amount := prev-amount
        , 'rollover := prev-rollover
        , 'last-claim := last-claim
        , 'last-stake := last-stake
        , 'effective-start := effective-start
        , 'start-cumulative := start-cumulative
        , 'pending-add := prev-pending-add
        , 'locks := locks }
        (write stake-table from
          { 'account: from
          , 'amount: prev-amount
          , 'last-stake: last-stake
          , 'last-add-request: (at 'block-time (chain-data))
          , 'pending-add: (+ amount prev-pending-add)
          , 'effective-start: effective-start
          , 'start-cumulative: start-cumulative
          , 'rollover: prev-rollover
          , 'last-claim: last-claim
          , 'locks: locks }))))

  (defun swap-to-kdx:decimal
    (token-in:module{fungible-v2}
     amount-in:decimal
     from:string
     to:string
     to-guard:guard)
    "Given an arbitrary amount of some arbitrary token, yield KDX out to the \
    \ provided to account."
    (require-capability (INTERNAL))
    (if (= "kaddex.kdx" (format-token token-in)) ;; If asked to swap KDX to KDX, just transfer it.
      (if (= from to) amount-in ;; completely skip if from == to
        (let ((x 0))
          (install-capability (kdx.TRANSFER from to amount-in))
          (kdx.transfer-create from to to-guard amount-in)
          amount-in
        ))
      ;; Get optimal path and execute a swap.
      (let*
        ( (path (get-path token-in kdx))
          (token-destination (at 'account (at 0 path)))
        )
        (install-capability (token-in::TRANSFER from token-destination amount-in))
        (let ((swap-result (exchange.swap-exact-in
            amount-in 0.0 ;; TODO: Supply a minimum amount out
            (unroll-path token-in path) from to to-guard)))
          (enforce (= (format-token kdx) (at 'token (at (length path) swap-result))) "Swap output must be kdx")
          (at 'amount (at (length path) swap-result)) ;; Extract amount out from swap result
        ))))

  (defun sweep-all:decimal ()
    "Operator only function to sweep fees from all pairs in the pair table. \
    \ Not used in practice due to high gas cost of keys, as well as wanting to \
    \ sweep only fee-yielding pairs at a given point."
    (with-capability (OPS)
      (sweep-some (keys pair-table))))

  (defun sweep-some:decimal (pairs:[string])
    "Operator only function to sweep fees from a given list of pairs. This \
    \ extracts collected feeTo LP tokens from the fee accounts for each pair, \
    \ removes those LP tokens from their respective pools, and swaps the resulting \
    \ tokens into KDX, and lazily distributes this KDX amount pro rata to the pool \
    \ using the revenue-per-kdx system. \
    \ revenue-per-kdx is a monotonically growing amount. This is a single field \
    \ representing all fees gathered, incremented by (fees-collected / kdx-staked) \
    \ at each sweep. By keeping the pool's revenue-per-kdx values at a user's \
    \ entry and exit times, one can efficiently calculate the user's fair share \
    \ of fees collected during the entry-exit interval."
    (with-capability (OPS)
      (with-read state-table STATE_KEY
        { 'staked-kdx := staked-kdx, 'revenue-per-kdx := prev-revenue }
        (if (= staked-kdx 0.0) 0.0 ;; If no KDX is staked, short circuit early.
        (let*
          ( ;; Retrieve the KDX value in the bank before the sweep/swap. Helps
            ;; us keep an invariant between expected KDX out and actual KDX out.
            (balance-before (kdx.get-balance KDX_BANK))
            ;; Call sweep-one for all provided pair keys.
            (sweep-result (map (sweep-one) pairs))
            ;; sweep-one returns a list of token accounts which have received
            ;; remove-liquidity outputs. By fold-summing the return values and
            ;; deduplicating that result, we have a list of tokens and token
            ;; accounts which we need to drain by swapping their balance into
            ;; KDX.
            (accounts (distinct (fold (+) [] sweep-result)))
            ;; drain-account takes a token and an account name packed in the way
            ;; sweep-one returns them, swapping the account's balance for KDX
            ;; into the corresponding per-token KDX account, and finally transferring
            ;; the balance of that per-token KDX account into the KDX_BANK central
            ;; account.
            (drain-account (lambda (account-object)
              (bind account-object { 'token := token:module{fungible-v2}, 'account := account }
                ;; Allow access to both token and KDX accounts inside this lambda
                (with-capability (HOLDING_ACCOUNT (format-token token) account)
                (with-capability (HOLDING_ACCOUNT (format-token kdx) account)
                  (let ((swap-out ;; swap-to-kdx returns a KDX amount (the output)
                    (with-capability (INTERNAL)
                      (swap-to-kdx
                        token
                        (token::get-balance account)
                        account
                        account (token-guard (format-token kdx) account)))))
                    ;; Transfer swap-out KDX from the per-token KDX account to the
                    ;; KDX_BANK KDX account.
                    (install-capability (kdx.TRANSFER account KDX_BANK swap-out))
                    (kdx.transfer account KDX_BANK swap-out)
                    ;; Return the swap output.
                    swap-out))))))
            ;; Sum the value of all the swaps.
            (drain-result (map (drain-account) accounts))
            (total-out (fold (+) 0.0 drain-result))
            ;; Enforce that the KDX balance of KDX_BANK after the swapping is
            ;; equal to the KDX balance before + the swap outputs.
            (balance-after (kdx.get-balance KDX_BANK))
            (effective-out (- balance-after balance-before)))
          (enforce (= total-out effective-out) (format "Accounting mismatch (expected {} out, received {})" [total-out effective-out]))
          (if (= (floor total-out (kdx.precision)) 0.0)
            0.0 ;; short circuit when 0
            (let ((x 0)) ;; let for multi-statement if clause
              ;; Wrap cumulative swap output to sKDX.
              (install-capability (kdx.TRANSFER KDX_BANK (alchemist.get-holder-account kaddex.skdx) total-out))
              (with-capability (HOLDING_ACCOUNT (format-token kaddex.kdx) KDX_BANK)
              (with-capability (WRAPPING)
                (install-capability (kdx.WRAP "kaddex.skdx" KDX_BANK KDX_BANK total-out))
                (alchemist.wrap total-out kaddex.skdx KDX_BANK KDX_BANK (token-guard (format-token skdx) KDX_BANK))))
              ;; Record fees collected. revenue-per-kdx is increased by the KDX
              ;; output divided by the amount of KDX staked in the pool.
              (update state-table STATE_KEY
                { 'revenue-per-kdx: (+ prev-revenue (/ total-out staked-kdx)) })
              total-out)))))))

  (defun sweep-one (key:string)
    "Internal operator-only function to sweep fees from one trading pair. This \
    \ extracts collected the feeTo LP token amount from the fee account for this \
    \ pair, and removes the LP token from the liquidity pool. Returns a list of \
    \ 'touched' token accounts (ones containing fee outputs)."
    (require-capability (OPS))
    (with-read pair-table key
      { 'fee-account := fee-account
      , 'fee-guard := fee-guard
      , 'pair-account := pair-account
      , 'pair-guard := pair-guard}
      (let*
        ( (pair (exchange.get-pair-by-key key))
          (token0:module{fungible-v2} (at 'token (at 'leg0 pair)))
          (token1:module{fungible-v2} (at 'token (at 'leg1 pair)))
          (is-canonical (< (format "{}" [token0]) (format "{}" [token1])))
          (tokenA (if is-canonical token0 token1))
          (tokenB (if is-canonical token1 token0))
          (token0-account (at 'account (get-token-record token0)))
          (token1-account (at 'account (get-token-record token1)))
          (liquidity-recipient (at 'account pair))
          (accrued (tokens.get-balance key fee-account)))
        (if (= accrued 0.0) [] ;; short circuit with no fees
          (let ((x 0)) ;; empty let for multi-statement if clause
            (install-capability (tokens.TRANSFER key fee-account liquidity-recipient accrued))
            (bind
              ;; Remove the LP token amount from the pool, extracting fees into
              ;; per-pool token accounts.
              (with-capability (SWEEPING (format-token tokenA) (format-token tokenB))
                (exchange.remove-liquidity
                  token0 token1 accrued
                  0.0 0.0 ;; TODO: Provide actual minimums? Even feasible?
                  fee-account
                  pair-account pair-guard))
              ;; Bind to remove-liquidity amounts out.
              { 'amount0 := amount0
              , 'amount1 := amount1 }
              ;; Transfer remove-liquidity output from per-pool token accounts
              ;; to shared token accounts.
              (install-capability (token0::TRANSFER pair-account token0-account amount0))
              ;; the pair guard always checks for access to canonically left-hand
              ;; token in trading pair, so install cap for tokenA
              (with-capability (HOLDING_ACCOUNT (format-token tokenA) pair-account)
                (token0::transfer pair-account token0-account amount0))

              (install-capability (token1::TRANSFER pair-account token1-account amount1))

              (with-capability (HOLDING_ACCOUNT (format-token tokenA) pair-account)
                (token1::transfer pair-account token1-account amount1))
              ;; Return accounts containing remove-liquidity output.
              [ { 'token: token0, 'account: token0-account }
                { 'token: token1, 'account: token1-account } ]))))))

  (defun get-pool-state:object{pool-state} ()
    "Retrieve the current pool state."
    (read state-table STATE_KEY))

  (defun get-stake-record:object{stake-record} (account:string)
    "Retrieve the raw stake record for a given account."
    (read stake-table account))

  (defun get-token-record:object{token-record} (token:module{fungible-v2})
    "Retrieve the token record for a given token."
    (read token-table (format "{}" [token])))

  (defun get-pair-record:object{pair-record} (tokenA:module{fungible-v2} tokenB:module{fungible-v2})
    "Retrieve the pair for a given trading pair."
    (read pair-table (exchange.get-pair-key tokenA tokenB))  )

  (defun get-path:[object{exchange.pair}]
    (token-in:module{fungible-v2}
     token-out:module{fungible-v2})
    "Retrieve a trading path from token-in to token-out. We only use this for \
    \ paths to KDX."
    ;; TODO: Either try more than the basic single-hop path, or
    ;; operators should register optimal token paths to take.
    (if (exchange.pair-exists token-in token-out)
      [ (exchange.get-pair token-in token-out) ]
      ;; Fall back to in -> KDA -> out. According to our design, this should always
      ;; exist for KDX out.
      [ (exchange.get-pair token-in coin) (exchange.get-pair coin token-out) ]))

  (defun unroll-path:[module{fungible-v2}]
    (token-in:module{fungible-v2}
     path:[object{exchange.pair}])
    "Given a trading path as a list of pairs and the token being swapped in, \
    \ return a list of tokens representing each hop of the path."
    (fold
      (lambda (tokens:[module{fungible-v2}] pair:object{exchange.pair})
        (let*
          ( (last-token (at (- (length tokens) 1) tokens))
            (is-leg0 (exchange.is-leg0 pair last-token))
            (leg-key (if is-leg0 'leg1 'leg0))
          )
          (+ tokens [(at 'token (at leg-key pair))])
        )
      )
      [token-in]
      path)
  )

  (defun record-burn (type:string from:string amount:decimal)
    "Record some burned amount into the pool state. Used when penalties are burned. \
    \ Doesn't actually burn any tokens, plan is to burn these manually periodically."
    (require-capability (INTERNAL))
    (enforce (cond
      ((= type "reward") (emit-event (REWARD_BURN from amount)))
      ((= type "stake") (emit-event (STAKE_BURN from amount)))
      false) "Unrecognized burn type")
    (with-read state-table STATE_KEY { 'burnt-kdx := prev-burnt }
      (update state-table STATE_KEY { 'burnt-kdx: (+ amount prev-burnt) })))

)
```

---

## `kaddex.wrapper`

```pact
(module wrapper GOVERNANCE
  (defschema liquidity-position
      "Tracks liquidity positions of users of the wrapper contract."
    key:string                          ;; key for this row, used for convenience
    pair:string                         ;; pair-key for this position, returned by exchange.get-pair-key
    account:string                      ;; user account that controls the liquidity tokens (`to` parameter from `add-liquidity`)
    guard:guard                         ;; guard for controlling the liquidity tokens
    liquidity-tokens:decimal            ;; amount of liquidity tokens the user can remove with `remove-liquidity`
    tokenA-pooled:decimal               ;; amount of tokenAs initially added (or later IL-adjusted)
    tokenB-pooled:decimal               ;; amount of tokenBs initially added (or later IL-adjusted)

    updated-at:time                     ;; last time the settled fee values were updated
    settled-multiplier:decimal          ;; the accumulated multiplier for the settled fees
    settled-liquidity-for-fees:decimal) ;; the amount of liquidity set aside for settled fees with the settled-multiplier
  (deftable liquidity-positions:{liquidity-position})

  (defschema liquidity-account
      "Tracks liquidity positions owned by the wrapper contract in the underlying pools."
    pair:string                         ;; pair-key for this account, returned by exchange.get-pair-key
    account:string                      ;; account created and managed by the wrapper to hold liquidity tokens
    guard:guard                         ;; module guard used to protect the held liquidity tokens
    tokenA:module{fungible-v2}          ;; module references to the two tokens of the pair
    tokenB:module{fungible-v2}
    liquidity-tokens:decimal)           ;; total amount of liquidity tokens held by the wrapper for the pair
  (deftable liquidity-accounts:{liquidity-account})

  (defschema trading-pair
      "Tracks information about supported wrapped trading pairs."
    pair:string                             ;; pair-key for this pair
    account:string                          ;; account created and managed by the wrapper to hold both tokenA/tokenB temporarily
    guard:guard                             ;; module guard used to protect the account
    fee-multiplier:decimal                  ;; the currently active KDX boosted fee multiplier for this pair
    last-fee-multiplier:decimal             ;; the last active fee multiplier for this pair
    updated-at:time                         ;; the time when the multiplier was last updated
    tokenA:module{fungible-v2}              ;; module reference to the pair token
    tokenA-base-path:[module{fungible-v2}]  ;; swap path for tokenA into KDX, e.g. [token-abc coin kaddex.kdx]
    tokenB:module{fungible-v2}
    tokenB-base-path:[module{fungible-v2}])
  (deftable trading-pairs:{trading-pair})

  (defschema reward-claim-request
      "Tracks information for pending boosted KDX reward claims."
    request-id:string  ;; key for this row, for convenience
    account:string     ;; user account claiming rewards
    to:string          ;; user account to receive the rewards
    to-guard:guard     ;; guard to receive the rewards

    liquidity-position-key:string ;; key into the liquidity-positions-table
    pair-key:string               ;; key into trading-pairs table
    tokenA-fees:decimal           ;; amount of tokenA collected as fees (not counting settled fees)
    tokenB-fees:decimal           ;; amount of tokenB collected as fees (not counting settled fees)

    tokenA-observations:[object{exchange.observation}] ;; list of TWAP observations for the tokenA swap path
    tokenB-observations:[object{exchange.observation}] ;; list of TWAP observations for the tokenB swap path
    total-kdx-swapped:decimal                          ;; total amount of KDX received from selling the fees

    fee-multiplier:decimal ;; the active multiplier the user is gonna get (not counting settled fees)

    settled-tokenA-fees:decimal ;; amount of tokenA collected as settled fees only
    settled-tokenB-fees:decimal ;; amount of tokenB collected as settled fees only
    settled-multiplier:decimal  ;; the multiplier for the settled fee amounts

    start-time:time ;; when the user initiated the request
    end-time:time   ;; when the request is available to be claimed
    status:string)  ;; current status of the request, see below for possible values
  (deftable reward-claim-requests:{reward-claim-request})


  (defschema pending-request-schema
      requests:[string])
  (deftable pending-requests:{pending-request-schema})
  ;; if the key is account name, then requests is a list of pending requests for that account

  ;; this is a simple global lock that can be toggled by the operators to pause the contract if necessary
  (defschema contract-lock-status
      lock:bool)
  (deftable contract-lock:{contract-lock-status})
  (defconst CONTRACT_LOCK_KEY 'lock)

  (defcap RESERVE_ACCESS
    ( pair:string )
    true)
  (defcap LIQUIDITY_ACCESS
    ( token:string )
    true)
  (defcap BANK_ACCESS
    ( token:string )
    true)
  (defcap MINTING
    ( token:string )
    true)
  (defcap BURNING
    ( token:string )
    true)

  (defun format-token:string (token:module{fungible-v2})
    (format "{}" [token]))

  (defun enforce-bank-access (token:string)
    (require-capability (BANK_ACCESS token)))
  (defun enforce-reserve-access (pair:string)
    (require-capability (RESERVE_ACCESS pair)))
  (defun enforce-minting (token:string)
    (require-capability (MINTING token)))
  (defun enforce-burning (token:string)
    (require-capability (BURNING token)))
  (defun enforce-liquidity-access (pair:string)
    (require-capability (LIQUIDITY_ACCESS pair)))

  (defun create-reserve-guard (pair-key:string)
    (create-user-guard (enforce-reserve-access pair-key)))
  (defun create-mint-guard (token:module{fungible-v2})
    (create-user-guard (enforce-minting (format-token token))))
  (defun create-burn-guard (token:module{fungible-v2})
    (create-user-guard (enforce-burning (format-token token))))
  (defun create-liquidity-guard (pair:string)
    (create-user-guard (enforce-liquidity-access pair)))
  (defun create-bank-guard ()
    (create-user-guard (enforce-bank-access (format-token (get-base-token)))))

  (defcap GOVERNANCE ()
    (enforce-guard (keyset-ref-guard 'kaddex-wrapper-admin)))

  (defcap OPS ()
    (enforce-guard (keyset-ref-guard 'kaddex-wrapper-ops)))

  (defcap LIQUIDITY_POS_GUARD
    ( token0:module{fungible-v2}
      token1:module{fungible-v2}
      account:string
    )
    "Capability for enforcing the user's liquidity-position guard"
    (enforce-guard (at 'guard (get-liquidity-position token0 token1 account)))
  )

  (defcap FEE_BUYBACK
    ( token:module{fungible-v2}
      token-accrued:decimal
    )
    "Private capability for processing KDX buybacks."
    true
  )

  (defcap SWAPPING_FEES ()
    "Private capability for swapping KDX."
    true
  )

  (defcap FEE_REWARD
    ( token0:module{fungible-v2}
      token1:module{fungible-v2}
      token0-accrued:decimal
      token1-accrued:decimal
      base-token-paid:decimal
      reward-multiplier:decimal
      bonus-reward:decimal
      to:string
    )
    "Event for reporting fee payouts."
    @event
    true
  )

  ;; account name for the wrapper KDX holding account, holds the KDX from swapping user fees
  (defconst WRAPPER_KDX_BANK 'kaddex-kdx-wrapper-bank)

  ;; account name for holding pre-minted KDX for booster distribution. needs to be regularly monitored and possibly refilled
  ;; this is used instead of giving mint permissions to the wrapper to minimize attack surface
  (defconst WRAPPER_KDX_MINT_BANK 'kaddex-kdx-wrapper-mint-bank)


  ;; utility function to get a module reference to KDX
  (defun get-base-token:module{fungible-v2} () kaddex.kdx)

  (defun tokens-equal:bool
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
    )
    "Token equality defined by comparing the fully qualified contract names."
    ;; Module references are equal if and only if they implement exactly the same interfaces.
    ;; Updates to tokens (such as implementing the new fungible-xchain-v1 interface) can
    ;; break this, so we only check if the fully qualified name is the same.
    (= (format "{}" [tokenA])
       (format "{}" [tokenB]))
  )

  (defun get-pair-account:string
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
    )
    (at 'account (read trading-pairs (exchange.get-pair-key tokenA tokenB) ['account]))
  )

  (defun get-pair-multiplier:decimal
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
    )
    (at 'fee-multiplier (read trading-pairs (exchange.get-pair-key tokenA tokenB) ['fee-multiplier]))
  )

  (defun get-liquidity-position-key
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
      account:string
    )
    (format "{}:{}" [(exchange.get-pair-key tokenA tokenB) account])
  )

  (defun get-liquidity-position-key*
    ( pair-key:string
      account:string
    )
    (format "{}:{}" [pair-key account])
  )

  (defun get-liquidity-account:object
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
    )
    (read liquidity-accounts (exchange.get-pair-key tokenA tokenB))
  )

  (defun get-liquidity-position:object
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
      account:string
    )
    (read liquidity-positions (get-liquidity-position-key tokenA tokenB account))
  )

  (defun pair-registered:bool
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
    )
    (with-default-read trading-pairs (exchange.get-pair-key tokenA tokenB)
      { 'pair: "" }
      { 'pair := read-pair-key }
      (!= 0 (length read-pair-key))
    )
  )

  (defun enforce-disabled:bool ()
    (enforce false "Wrapper module is disabled"))

  (defun register-pair-only
    ( tokenAA:module{fungible-v2}
      tokenBB:module{fungible-v2}
      tokenAA-base-path:[module{fungible-v2}]
      tokenBB-base-path:[module{fungible-v2}]
      hint:string
    )
    (enforce-disabled)
  )

  (defun register-pair
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
      tokenA-base-path:[module{fungible-v2}]
      tokenB-base-path:[module{fungible-v2}]
      amountA-desired:decimal
      amountB-desired:decimal
      amountA-min:decimal
      amountB-min:decimal
      sender:string
      hint:string
    )
    (enforce-disabled)
  )

  (defun set-fee-multiplier-for-pair
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
      new-multiplier:decimal
    )
    (enforce-disabled)
  )

  (defun update-single-position-for-new-multiplier
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
      account:string
    )
    (enforce-disabled)
  )

  (defun update-positions-for-new-multiplier
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
      accounts:[string]
    )
    (enforce-disabled)
  )


  (defun remove-liquidity:object
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
      requested-liquidity:decimal
      amountA-min:decimal
      amountB-min:decimal
      sender:string
      to:string
      to-guard:guard
      wants-kdx-rewards:bool
    )
    (enforce-disabled)
    )

  (defun remove-liquidity-extended:object
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
      requested-liquidity:decimal
      amountA-min:decimal
      amountB-min:decimal
      sender:string
      to:string
      to-guard:guard
      wants-kdx-rewards:bool
      rewards-to:string
      rewards-to-guard:guard
    )
  (enforce-disabled)
  )



  (defun add-liquidity-one-sided:object
    ( token-in:module{fungible-v2}
      token-other:module{fungible-v2}
      amount-in-total:decimal
      amount-in-min:decimal
      amount-other-min:decimal
      sender:string
      sender-guard:guard
      to:string
      to-guard:guard
    )
  (enforce-disabled)
  )

  (defun add-liquidity:object
    ( tokenA:module{fungible-v2}
      tokenB:module{fungible-v2}
      amountA-desired:decimal
      amountB-desired:decimal
      amountA-min:decimal
      amountB-min:decimal
      sender:string
      to:string
      to-guard:guard
    )
    (enforce-disabled)
  )

  (defun dump-positions () ;; CLEANUP: testing function, do we want to remove?
    (select liquidity-positions (constantly true)))

  (defun dump-liquidity () ;; CLEANUP: testing function, do we want to remove?
    (select liquidity-accounts (constantly true)))

  (defun withdraw-claim:string
    ( sender:string
      request-id:string
    )
    (enforce-disabled)
  )


  (defun process-claim-request-if-necessary:bool
    ( request-id:string
    )
    (enforce-disabled)
  )

  (defun init (initial-lock:bool)
    (enforce-disabled)
  )

  (defun transfer-from-bank (dst:string dst-guard:guard)
    (with-capability (OPS)
      (install-capability (kdx.TRANSFER WRAPPER_KDX_BANK dst (kdx.get-balance WRAPPER_KDX_BANK)))
      (install-capability (kdx.TRANSFER WRAPPER_KDX_MINT_BANK dst (kdx.get-balance WRAPPER_KDX_MINT_BANK)))

      (with-capability (BANK_ACCESS "kaddex.kdx")
        (kdx.transfer-create WRAPPER_KDX_BANK dst dst-guard (kdx.get-balance WRAPPER_KDX_BANK))
        (kdx.transfer-create WRAPPER_KDX_MINT_BANK dst dst-guard (kdx.get-balance WRAPPER_KDX_MINT_BANK))))
  )

  (defun unwrap-account (pair-key:string account:string)
    (with-capability (OPS)
      (with-read liquidity-positions (get-liquidity-position-key* pair-key account) {'liquidity-tokens:=amount,
                                                                                    'account:=owner-account,
                                                                                    'guard:=owner-guard}
        (with-read liquidity-accounts pair-key {'liquidity-tokens:=total-wrapped, 'account:=wrapper-account}
          (if (> amount 0.0)
              (do (install-capability (tokens.TRANSFER pair-key wrapper-account owner-account amount))
                  (with-capability (LIQUIDITY_ACCESS pair-key)
                    (tokens.transfer-create pair-key wrapper-account owner-account owner-guard amount)))

              "")
          (update liquidity-accounts pair-key {'liquidity-tokens: (- total-wrapped amount)})))

        (update liquidity-positions (get-liquidity-position-key* pair-key account)
                {'liquidity-tokens:0.0,
                 'tokenA-pooled:0.0,
                 'tokenB-pooled:0.0,
                 'updated-at:(at 'block-time (chain-data)),
                 'settled-multiplier:0.0,
                 'settled-liquidity-for-fees:0.0}))
  )

  (defun unwrap-account-object (data:object)
    (bind data {'a:=account, 'p:=pair}
      (unwrap-account pair account))
  )
)
```

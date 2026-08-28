# Kaddex source dump — part 2 of 4: `dao`, `fungible-util`, `gas-guards`, `noop-callable`

> Same provenance note as `KADDEX-SOURCE-1.md` — external Kadena-mainnet reference material,
> pasted verbatim by the owner. Read `KADDEX-COMPARISON-HANDOFF.md` first.

---

## `kaddex.dao`

```pact
(module dao GOVERNANCE

  ; ------------------ Contracts -----------------------------

  (use coin)


  ; ------------------ Schemas --------------------------------

  (defschema proposal
    id:string
    title:string
    description:string
    account:string
    tot-approved:decimal
    tot-refused:decimal
    start-date:time
    end-date:time
    creation-date:time
    )
  (defschema vote
    proposal-id:string
    account:string
    vp:decimal
    action:string
    )

  ; ------------------ Tables ------------------------------------

  (deftable proposals-table:{proposal})
  (deftable votes-table:{vote})

  ; ------------------ Constants ---------------------------------

  (defconst MAX_PROPOSAL_DEBATE_PERIOD (days 14))

  (defconst VOTE_APPROVED "approved")
  (defconst VOTE_REFUSED "refused")

  ; ------------------ Capabilities -----------------------------

  (defcap GOVERNANCE ()
    (enforce-guard
      (keyset-ref-guard 'kaddex-dao-admin )))

  (defcap OPS ()
    (enforce-guard
      (keyset-ref-guard 'kaddex-dao-ops )))

  (defcap INTERNAL ()
    "mark some functions as internal only"
    true)

  (defcap ACCOUNT_GUARD ( account:string )
    @doc " Look up the guard for an account, required to withdraw from the contract. "
    (enforce-guard (at 'guard (kaddex.kdx.details account))) "Keyset Failure")

  (defcap PROPOSAL_PERIOD
      ( proposal-id:string
        timestamp:time)
      "Reserve event for kdx reservation"
      @event
      (with-read proposals-table proposal-id {
        "start-date":=start-date,
       "end-date":=end-date
       }
       (enforce (>= timestamp start-date) "Proposal is not yet open")
       (enforce (<= timestamp end-date) "The proposal is closed")
     )
    )

  ; ------------------ Utility Functions -----------------------------


  (defun votes-table-key (account:string proposal-id:string)
    @doc "create id for insert and update vote-table"
    (format "{}-{}" [account proposal-id])
  )

  (defun curr-time:time ()
    @doc "Returns current chain's block-time in time type"
    (at 'block-time (chain-data)))

  (defun check-account-voted (account:string proposal-id:string)
    @doc "Checks if an account has already voted a specific proposal"
    (with-default-read votes-table (votes-table-key account proposal-id)
      {"account":""}
      {"account":=account}
      (if (= account "") false true)
      )
  )

  ; ------------------ Functions ------------------------------------


  (defun create-proposal:string
    (title:string description:string owner-account:string start-date:time end-date:time)
    @doc "Creates proposal with the parameters: `title` `description` `owner-account` `start-date` `end-date` and insert it into proposals-table"
    (with-capability (OPS)
    (enforce (< (curr-time) start-date) "Start Date shouldn't be in the past")
    (enforce (< start-date end-date) "End Date should be later than start date")
    (enforce (< (diff-time end-date start-date) MAX_PROPOSAL_DEBATE_PERIOD)
      "proposal period is too long")
    (enforce (!= "" title) "Title should be decleared")
    (enforce (!= "" description) "Description should be decleared")
    (enforce (= "k:" (take 2 owner-account)) "only k: accounts allowed")

    (let
      (
        (id (hash title))
        )
      (insert proposals-table id{
        "id":id,
        "title": title,
        "description":description,
        "account":owner-account,
        "start-date":start-date,
        "creation-date":(curr-time),
        "end-date":end-date,
        "tot-approved": 0.0,
        "tot-refused":0.0
        })
        (format "{} - {} proposal from {} to {} has been created" [id title start-date end-date])
      )
    )
    )


  (defun vote-proposal-helper (proposal-id:string account:string action:string )
    @doc "Helper function for inserting vote of an account on a proposal"
    (require-capability (INTERNAL))
    (with-capability (PROPOSAL_PERIOD proposal-id (curr-time))
      (let ((vp (kaddex.aggregator.get-voting-power account)))
       (enforce (> vp 0.0) "You can not vote")
       (insert votes-table (votes-table-key account proposal-id) {
         "proposal-id":proposal-id
         ,"account":account
         ,"vp":vp
         ,"action":action
       })
      )
    )
  )

  (defun approved-vote:string (proposal-id:string account:string)
    @doc "Vote for a proposal as approved"
    (with-capability (ACCOUNT_GUARD account)
    (with-capability (INTERNAL)
    (with-capability (PROPOSAL_PERIOD proposal-id (curr-time))
    (let ((check-already-voted (check-account-voted account proposal-id)))
      (enforce (not check-already-voted)
        "This account has already voted to this proposal")
      )
    (let* (
      (vp (kaddex.aggregator.get-voting-power account))
    )
    (enforce (> vp 0.0)
      "This account does not have voting power")
    (with-read proposals-table proposal-id {
       "tot-approved":= tot-approved
       }
        (update proposals-table proposal-id
          {"tot-approved": (+ tot-approved (floor (sqrt vp) 2))}) ;; Quadratic Voting
      )
        (vote-proposal-helper proposal-id account VOTE_APPROVED)
      (format "Account {} APPROVED the '{}' proposal" [account proposal-id])
      )
    )
    )
    )
  )

  (defun refused-vote:string (proposal-id:string account:string)
    @doc "Vote for a proposal as refused"
    (with-capability (ACCOUNT_GUARD account)
    (with-capability (INTERNAL)
    (with-capability (PROPOSAL_PERIOD proposal-id (curr-time))
    (let ((check-already-voted (check-account-voted account proposal-id)))
      (enforce (not check-already-voted)
        "This account has already voted to this proposal")
      )
    (let* (
      (vp (kaddex.aggregator.get-voting-power account))
    )
    (enforce (> vp 0.0)
       "This account does not have voting power")
    (with-read proposals-table proposal-id {
       "tot-refused":= tot-refused
       }
       (update proposals-table proposal-id
         {"tot-refused": (+ tot-refused (floor (sqrt vp) 2))})  ;; Quadratic Voting
      )
        (vote-proposal-helper proposal-id account VOTE_REFUSED)
      (format "Account {} REFUSED the '{}' proposal" [account proposal-id])
      )
    )
    )
    )
  )

  (defun get-account-data:object (account:string)
    @doc "Function that returns information (voting-power, multiplier and staked-amount) about a specific account"
    (let*
      (
        (account-data (kaddex.aggregator.get-account-data account))
        (vp (at 'vp account-data))
        )
        {'vp:(floor (sqrt vp) 5), 'multiplier:(at 'multiplier account-data), 'staked-amount:(at 'staked-amount account-data)}
      )
  )

  (defun read-proposal (proposal-id:string)
    @doc "Get proposal info giving a specific proposal-id"
    (read proposals-table proposal-id)
  )

  (defun read-all-proposals ()
    @doc "Get all proposals info"
    (map (read proposals-table) (get-proposals-ids))
  )

  (defun get-proposals-ids ()
    @doc "read-all-proposals helper function"
    (keys proposals-table)
  )

  (defun read-account-votes (account:string)
    @doc "get vote info for each proposal that account has voted in the votes-table"
    (select votes-table (where 'account (= account)) )
  )

  (defun read-account-vote-proposal (account:string proposal:string)
    @doc "Get vote info of account on a specific proposal"
    (select votes-table (and? (where 'account (= account)) (where 'proposal-id (= proposal))))
  )
)
```

---

## `kaddex.fungible-util`

```pact
(module fungible-util GOVERNANCE

  (defcap GOVERNANCE ()
    (enforce-guard (keyset-ref-guard 'kaddex-exchange-admin)))

  (defun enforce-valid-amount
    ( precision:integer
      amount:decimal
    )
    (enforce (> amount 0.0) "Positive non-zero amount")
    (enforce-precision precision amount)
  )

  (defun enforce-valid-account (account:string)
    (enforce (> (length account) 2) "minimum account length")
  )

  (defun enforce-precision
    ( precision:integer
      amount:decimal
    )
    (enforce
      (= (floor amount precision) amount)
      "precision violation")
  )

  (defun enforce-valid-transfer
    ( sender:string
      receiver:string
      precision:integer
      amount:decimal)
    (enforce (!= sender receiver)
      "sender cannot be the receiver of a transfer")
    (enforce-valid-amount precision amount)
    (enforce-valid-account sender)
    (enforce-valid-account receiver)
  )

  (defun check-reserved:string (account:string)
    " Checks ACCOUNT for reserved name and returns type if \
    \ found or empty string. Reserved names start with a \
    \ single char and colon, e.g. 'c:foo', which would return 'c' as type."
    (let ((pfx (take 2 account)))
      (if (= ":" (take -1 pfx)) (take 1 pfx) "")))

  (defun enforce-reserved:bool (account:string guard:guard)
    @doc "Enforce reserved account name protocols."
    (if (validate-principal guard account)
      true
      (let ((r (check-reserved account)))
        (if (= r "")
          true
          (if (= r "k")
            (enforce false "Single-key account protocol violation")
            (enforce false
              (format "Reserved protocol guard violation: {}" [r]))
            )))))

)
```

---

## `kaddex.gas-guards`

```pact
(module gas-guards GOVERNANCE
  "************************WARNING******************************\
  \ This module is currently governed by 'kaddex-exchange-admin \
  \ and should not be in use by others until the governance is  \
  \ replaced with AUTONOMOUS, meaning that the module           \
  \ will be non-upgradable.                                     \
  \ ************************************************************\
  \ Functions for implementing gas guards."

  (defcap GOVERNANCE ()
      (enforce-guard (keyset-ref-guard 'kaddex-gas-admin)))

  (defun guard-all:guard (guards:[guard])
    "Create a guard that only succeeds if every guard in GUARDS is successfully enforced."
    (enforce (< 0 (length guards)) "Guard list cannot be empty")
    (create-user-guard (enforce-guard-all guards)))

  (defun enforce-guard-all:bool (guards:[guard])
    "Enforces all guards in GUARDS"
    (map (enforce-guard) guards)
  )

  (defun guard-any:guard (guards:[guard])
    "Create a guard that succeeds if at least one guard in GUARDS is successfully enforced."
    (enforce (< 0 (length guards)) "Guard list cannot be empty")
    (create-user-guard (enforce-guard-any guards)))

  (defun enforce-guard-any:bool (guards:[guard])
    "Will succeed if at least one guard in GUARDS is successfully enforced."
    (enforce (< 0
      (length
        (filter
          (= true)
          (map (try-enforce-guard) guards))))
      "None of the guards passed")
  )

  (defun try-enforce-guard (g:guard)
    (try false (enforce-guard g))
  )

  (defun max-gas-notional:guard (gasNotional:decimal)
    "Guard to enforce gas price * gas limit is smaller than or equal to GAS"
    (create-user-guard
      (enforce-below-or-at-gas-notional gasNotional)))

  (defun enforce-below-gas-notional (gasNotional:decimal)
    (enforce (< (chain-gas-notional) gasNotional)
      (format "Gas Limit * Gas Price must be smaller than {}" [gasNotional])))

  (defun enforce-below-or-at-gas-notional (gasNotional:decimal)
    (enforce (<= (chain-gas-notional) gasNotional)
      (format "Gas Limit * Gas Price must be smaller than or equal to {}" [gasNotional])))

  (defun max-gas-price:guard (gasPrice:decimal)
    "Guard to enforce gas price is smaller than or equal to GAS PRICE"
    (create-user-guard
      (enforce-below-or-at-gas-price gasPrice)))

  (defun enforce-below-gas-price:bool (gasPrice:decimal)
    (enforce (< (chain-gas-price) gasPrice)
      (format "Gas Price must be smaller than {}" [gasPrice])))

  (defun enforce-below-or-at-gas-price:bool (gasPrice:decimal)
    (enforce (<= (chain-gas-price) gasPrice)
      (format "Gas Price must be smaller than or equal to {}" [gasPrice])))

  (defun max-gas-limit:guard (gasLimit:integer)
    "Guard to enforce gas limit is smaller than or equal to GAS LIMIT"
    (create-user-guard
      (enforce-below-or-at-gas-limit gasLimit)))

  (defun enforce-below-gas-limit:bool (gasLimit:integer)
    (enforce (< (chain-gas-limit) gasLimit)
      (format "Gas Limit must be smaller than {}" [gasLimit])))

  (defun enforce-below-or-at-gas-limit:bool (gasLimit:integer)
    (enforce (<= (chain-gas-limit) gasLimit)
      (format "Gas Limit must be smaller than or equal to {}" [gasLimit])))

  (defun chain-gas-price ()
    "Return gas price from chain-data"
    (at 'gas-price (chain-data)))

  (defun chain-gas-limit ()
    "Return gas limit from chain-data"
    (at 'gas-limit (chain-data)))

  (defun chain-gas-notional ()
    "Return gas limit * gas price from chain-data"
    (* (chain-gas-price) (chain-gas-limit)))
)
```

---

## `kaddex.noop-callable`

```pact
(module noop-callable GOVERNANCE
  "Noop implementation of swap-callable-v1"
  (implements swap-callable-v1)
  (defcap GOVERNANCE () (enforce-guard (keyset-ref-guard 'kaddex-exchange-admin)))
  (defun swap-call:bool
    ( token-in:module{fungible-v2}
      token-out:module{fungible-v2}
      amount-out:decimal
      sender:string
      recipient:string
      recipient-guard:guard
    )
    "Noop implementation"
    true
  )
)
```

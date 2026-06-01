(interface fungible-v1
    @doc "Standard for fungible coins as specified in KIP-0002 \
    \ STOA Coin follows this standard"
    
    ;; [0] Schemas
    (defschema account-details
        @doc "Schema for results of Account Operation"
        account:string
        balance:decimal
        guard:guard
    )
    ;; [1] CAPS
    ;; [On Chain Transfers]
    (defcap TRANSFER:bool (sender:string receiver:string amount:decimal)
        @doc "Evented Capability that allows transsfer of <amount> from <sender> to <receiver>"
        @managed amount TRANSFER-mgr
    )
    (defun TRANSFER-mgr:decimal (managed:decimal requested:decimal)
        @doc "Manages TRANSFER AMOUNT linearly, \
            \ such that a request for 1.0 amount on a 3.0 \
            \ managed quantity emits updated amount 2.0."
    )
    ;; [2] Functions
    (defun get-balance:decimal (account:string)
        @doc "Gets balance for <account>, failing if it doesnt exist"
    )
    (defun details:object{account-details} (account:string)
        ;@doc "Gets an objects with details of <account>, failing if it doesnt exist"
        @doc "<ORIGINAL> - Gets full details of a Stoa Account"
    )
    (defun precision:integer ()
        @doc "Returns maximum allowed decimal precision"
    )
    ;;
    (defun enforce-unit:bool (amount:decimal)
        @doc "Enforce minimum precision allowed for transactions."
    )
    ;;
    (defun create-account:string (account:string guard:guard)
        @doc "Creates an <account> with 0.0 balance. with <guard> controlling acces"
    )
    (defun rotate:string (account:string new-guard:guard)
        @doc "Rotates guard for <account>, with <new-guard> \
        \ Existing guard of <account> is enforced"
    )
    (defun transfer:string (sender:string receiver:string amount:decimal)
        @doc "Transfers <amount> from <sender> to <receiver> \
            \ Fails if either <sender> or <receiver> does not exist"
    )
    (defun transfer-create:string 
        (sender:string receiver:string receiver-guard:guard amount:decimal)
        @doc "Transfers <amount> from <sender> to <receiver> \
            \ Fails if <sender> does not exist \
            \ If <receiver> exist, guard must match existing value \
            \ If <receiver> does not exist, it is created using <receiver-guard> \
            \ No longer subject to management by [TRANSFER] capability"
    )
    (defpact transfer-crosschain:string
        (sender:string receiver:string receiver-guard:guard target-chain:string amount:decimal)
        @doc "2 Step pact to transfer <amount> from <sender> to <receiver> on <target-chain> via SPV Proof \
            \ <target-chain> must be different from current chain-id \
            \ 1.Step debits <amount> from <sender> and yields <receiver>, <receiver-guard> and <amount> to <target-chain> \
            \ 2.Step continuation is sent into <target-chain> with proof obtained from the spv output endpoint of Chainweb \
            \ Proof is validated and <receiver> is credited the <amount>, creating account with <receiver-guard> as needed"
    )
)
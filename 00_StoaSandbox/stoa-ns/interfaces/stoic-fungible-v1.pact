(interface stoic-fungible-v1
    @doc "Standard Interface for Stoa based True Fungibles \
        \ Stoa based true fungibles must adhere to a special syntax and architecture, \
        \ that incorporate <fungible-v1> and <fungible-xchain-v1> interfaces functionality, \
        \ while adding additional functionality, such as Supply Tracking, \
        \ Transmit functions (unmanaged Transfer function) \
        \ Must allways allow for crosschain-transfers."
    ;; [0] Schemas
    (defschema account-details
        @doc "Schema for results of Account Operation"
        account:string
        balance:decimal
        guard:guard
    )
    (defschema LocalSupplySchema
        local-circulating:decimal
    )
    ;; [0.1] Constants
    (defconst CSK "chain-supply-key")
    (defun CoinSupplyKey ()
        @doc "Must point to <StoaFungibleV1.CSK>"
    )
    ;; [1] CAPS
    ;; [On Chain Transfers]
    (defcap TRANSFER:bool (sender:string receiver:string amount:decimal)
        @doc "Managed Capability that allows transsfer of <amount> from <sender> to <receiver>"
        @managed amount TRANSFER-mgr
    )
    (defun TRANSFER-mgr:decimal (managed:decimal requested:decimal)
        @doc "Manages TRANSFER AMOUNT linearly, \
            \ such that a request for 1.0 amount on a 3.0 \
            \ managed quantity emits updated amount 2.0."
    )
    (defcap TRANSMIT:bool (sender:string receiver:string amount:decimal)
        @doc "Evented Capability that allows transfer of <amount> from <sender> to <receiver>"
        @event
    )
    ;;  [Cross Chain Transfers]
    (defcap TRANSFER_XCHAIN:bool
        (sender:string receiver:string amount:decimal target-chain:string)
        @doc "Transfer Capability used for transfer from sender to receiver on target chain."
        @managed amount TRANSFER_XCHAIN-mgr
    )
    (defun TRANSFER_XCHAIN-mgr:decimal (managed:decimal requested:decimal)
        @doc "Allows TRANSFER-XCHAIN AMOUNT to be less than or \
           \ equal managed quantity as a one-shot, returning 0.0."
    )
    (defcap TRANSFER_XCHAIN_RECD:bool (sender:string receiver:string amount:decimal source-chain:string)
        @doc "Event emitted on receipt of cross-chain transfer."
        @event
    )
    ;;  [Other]
    (defcap UPDATE-LOCAL-SUPPLY:bool ()
        @doc "Simple <true> capability needed to update the local supply"
    )
    ;; [2] Functions
    ;;
    ;;  [UR]
    ;;
    (defun UR_Precision:integer ())
    (defun UR_Details:object{stoa-ns.fungible-v1.account-details} (account:string))
    (defun UR_Balance:decimal (account:string))
    (defun UR_Guard:guard (account:string))
    (defun UR_LocalCoinSupply:decimal ())
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_CoinPrecision:bool (amount:decimal)
        @doc "Should validate Coin Precision"
    )
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_Account (account:string)
        @doc "Should enforce account wonership"
    )
    ;;
    ;;  [C]
    ;;
    (defun C_CreateAccount:string (account:string guard:guard)
        @doc "Should create a new coin account"
    )
    (defun C_RotateAccount:string (account:string new-guard:guard)
        @doc "Should rotate the guard oan existing account"
    )
    (defun C_Transfer:string (sender:string receiver:string amount:decimal)
        @doc "Should transfer <amount> from <sender> to <receiver>"
    )
    (defun C_TransferAnew:string (sender:string receiver:string receiver-guard:guard amount:decimal)
        @doc "Should transfer <amount> from <sender> to <receiver> with account creation using <receiver-guard>"
    )
    (defun C_TransferAcross:string (sender:string receiver:string receiver-guard:guard target-chain:string amount:decimal)
        @doc "Should execute a crosschain transfer using the <transfer-crosschain> defpact"
    )
    (defun C_Transmit:string (sender:string receiver:string amount:decimal)
        @doc "Should be similar to <C_Transfer> but unmanaged"
    )
    (defun C_TransmitAnew:string (sender:string receiver:string receiver-guard:guard amount:decimal)
        @doc "Should be similar to <C_TransferAnew> but unmanaged"
    )
    (defpact transfer-crosschain:string (sender:string receiver:string receiver-guard:guard target-chain:string amount:decimal)
        @doc "Should execute a crosschain transfer using 2 steps"
    )
    ;;
    ;;  [X]
    ;;
    (defun X_UpdateLocalSupply (amount:decimal direction:bool)
        @doc "Used to update coin local supply. \
        \ Must require [UPDATE-LOCAL-SUPPLY] for the supply to be updated safely"
    )
)
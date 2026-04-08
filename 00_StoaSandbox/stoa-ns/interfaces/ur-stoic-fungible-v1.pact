(interface ur-stoic-fungible-v1
	@doc "Exposes UrStoa and UrStoaVault Functions \
		\ While present on every chain, UrStoa and UrStoaVault functionality \
		\ is restricted to Chain 0"
	;;
	;;	[UrStoa Capabilities and Functions]
	;;
	(defcap UR|TRANSFER:bool (sender:string receiver:string amount:decimal)
        @managed amount UR|TRANSFER-mgr
    )
	(defun UR|TRANSFER-mgr:decimal (managed:decimal requested:decimal))
	;;
	;;  [UR]
	;;
	(defun UR_UR|Details:object{stoa-ns.fungible-v1.account-details} (account:string))
	(defun UR_UR|Balance:decimal (account:string))
	(defun UR_UR|Guard:guard (account:string))
	(defun UR_UR|LocalStoaSupply:decimal ())
	;;
	;;  [C]
	;;
	(defun C_UR|CreateAccount:string (account:string guard:guard))
	(defun C_UR|RotateAccount:string (account:string new-guard:guard))
	(defun C_UR|Transfer:string (sender:string receiver:string amount:decimal))
	(defun C_UR|TransferAnew:string (sender:string receiver:string receiver-guard:guard amount:decimal))
	(defun C_UR|Transmit:string (sender:string receiver:string amount:decimal))
	(defun C_UR|TransmitAnew:string (sender:string receiver:string receiver-guard:guard amount:decimal))
	;;
	;;  	[UrStoaVault Capabilties and Functions]
	;;
	(defcap URV|STAKE (account:string amount:decimal)
        @managed
	)
	(defcap URV|UNSTAKE (account:string amount:decimal)
        @managed
	)
	(defcap URV|COLLECT (account:string)
        @managed
	)
	;;
	;;  [UR]
	;;
	(defun UR_URV|VaultUrSupply:decimal ())
	(defun UR_URV|VaultSupply:decimal ())
	(defun UR_URV|VaultNZS:integer ())
	(defun UR_URV|VaultRPS:decimal ())
	(defun UR_URV|VaultUnclaimedCount:integer ())
	(defun UR_URV|UserSupply:decimal (account:string))
	(defun UR_URV|UserLastRps:decimal (account:string))
	(defun UR_URV|UserPendingRewards:decimal (account:string))
	(defun UR_URV|IzAccount:bool (account:string))
	;;
	;;  [URC]
	;;
	(defun URC_URV|ClaimableRewards:decimal (account:string))
	;;
	;;  [C]
	;;
	(defun C_URV|Inject:string (account:string stoa-amount:decimal))
	(defun C_URV|Stake:string (account:string urstoa-amount:decimal))
	(defun C_URV|Unstake:string (account:string urstoa-amount:decimal))
	(defun C_URV|Collect:string (account:string))
	;;
)
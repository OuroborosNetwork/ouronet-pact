(interface stoic-bulk-fungible-v2
    @doc "Bulk transfer extension for Stoa native fungibles (v2). \
        \ Superset of stoic-bulk-fungible-v1 plus partitioned hybrid bulk transmit. \
        \ Authorizes aggregate spend via TRANSFER_BULK(sender,total) — the signature \
        \ binds budget only, not specific recipients."

    ;; [1] CAPS
    (defcap TRANSFER_BULK:bool (sender:string total:decimal)
        @doc "Managed capability authorizing aggregate bulk spend from <sender>"
        @managed total TRANSFER_BULK-mgr
    )
    (defun TRANSFER_BULK-mgr:decimal (managed:decimal requested:decimal)
        @doc "One-shot manager: authorized <total> is consumed by a single bulk call"
    )
    (defcap TRANSMIT_BULK:bool (sender:string total:decimal)
        @doc "Unmanaged bulk transfer capability (Transmit analogue)"
        @event
    )

    ;; [2] Functions
    (defun C_BulkTransfer:string
        (sender:string receivers:[string] amounts:[decimal])
        @doc "Bulk transfer to existing accounts on this chain"
    )
    (defun C_BulkTransferAnew:string
        (sender:string receivers:[string] receiver-guards:[guard] amounts:[decimal])
        @doc "Bulk transfer with account creation when recipients are absent"
    )
    (defun C_BulkTransmit:string
        (sender:string receivers:[string] amounts:[decimal])
        @doc "Unmanaged bulk transfer to existing accounts"
    )
    (defun C_BulkTransmitAnew:string
        (sender:string receivers:[string] receiver-guards:[guard] amounts:[decimal])
        @doc "Unmanaged bulk transfer with account creation when recipients are absent"
    )
    (defun C_HybridBulkTransmit:string
        (sender:string receivers:[[string]] receiver-guards:[guard] amounts:[[decimal]])
        @doc "Unmanaged bulk transmit: receivers [[existing][anew]], amounts [[existing][anew]], \
            \ guards for anew partition only; both partitions non-empty; total recipients <= 5000"
    )
)
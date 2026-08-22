;; Stage 01 Talos Interface Registry — HISTORICAL ClientFour versions only.
;; Latest Talos client interfaces live in each 3_Talos/*.pact file (deploy with module).
;; ClientFourV1–V5 + V6BlockTime historical below; ClientFourV6 shipped only in 06_TS01-C4
;; (not frozen here — A_Flush typed to module-owned PythiaLedgerV2). Latest: ClientFourV7 in 06_TS01-C4.
;; #39M/M14 fix: ClientThreeV2/ClientPactsV2 (frozen, pre-V3) live in 04_TS01-C3.pact /
;; 05_TS01-P.pact instead of here — same module-owned-type-dependency reason as ClientFourV6
;; above (V2's Smart Swap functions type against SwapperUsageV2.Slippage, not resolvable at
;; this registry's early Interfaces-load point). Latest: ClientThreeV3/ClientPactsV3, same files.
;;
(interface TalosStageOne_ClientFourV1
    @doc "Exposes Ouronet Stage One fourth client batch — CODEX (Mnemosyne Codex Identity + StoicTags)."
    ;;
    (defun CODEX|A_RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string ))
    (defun CODEX|C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun CODEX|C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun CODEX|C_RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun CODEX|C_ReleaseStoicTag:string (patron:string tag-name:string))
)
(interface TalosStageOne_ClientFourV2
    @doc "Frozen — PYTHIA Apollo API-key registry initial surface (deactivate had no patron fee arg)."
    ;;
    (defun CODEX|A_RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string ))
    (defun CODEX|C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun CODEX|C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun CODEX|C_RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun CODEX|C_ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun PYTHIA|C_DeployApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun PYTHIA|A_DeploySmartApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun PYTHIA|C_UpdateApiConsumerName:string
        ( patron:string
          owner-account:string
          apollo-account:string
          new-name:string ))
    (defun PYTHIA|A_ActivateApiKey:string (apollo-account:string))
    (defun PYTHIA|C_DeactivateApiKey:string (owner-account:string apollo-account:string))
    (defun PYTHIA|A_DeactivateApiKey:string (apollo-account:string))
)
(interface TalosStageOne_ClientFourV3
    @doc "Talos Stage One Client Four V3 — PYTHIA deactivate collects 1 IGNIS via patron."
    ;;
    (defun CODEX|A_RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string ))
    (defun CODEX|C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun CODEX|C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun CODEX|C_RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun CODEX|C_ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun PYTHIA|C_DeployApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun PYTHIA|A_DeploySmartApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun PYTHIA|C_UpdateApiConsumerName:string
        ( patron:string
          owner-account:string
          apollo-account:string
          new-name:string ))
    (defun PYTHIA|A_ActivateApiKey:string (apollo-account:string))
    (defun PYTHIA|C_DeactivateApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string ))
    (defun PYTHIA|A_DeactivateApiKey:string (patron:string apollo-account:string))
)
(interface TalosStageOne_ClientFourV4
    @doc "Frozen — PYTHIA dual-Apollo (deploy 500 STOA/half, link free, revoke 1 IGNIS); pre-ledger."
    ;;
    (defun CODEX|A_RegisterCodexIdentity:string
        (
            codex-id:string
            public-standard:string
            public-smart:string
            codex-guard:guard
            registered-by:string
        ))
    (defun CODEX|C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun CODEX|C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun CODEX|C_RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun CODEX|C_ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun PYTHIA|C_DeployApiKey:string
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        ))
    (defun PYTHIA|C_UpdateDualConsumerLane:string
        (
            patron:string
            dual-link-key:string
            new-name:string
        ))
    (defun PYTHIA|C_Link:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun PYTHIA|A_Link:string (standard-apollo:string smart-apollo:string))
    (defun PYTHIA|C_RevokeLink:string
        (
            patron:string
            dual-link-key:string
        ))
    (defun PYTHIA|A_RevokeLink:string (patron:string dual-link-key:string))
)
(interface TalosStageOne_ClientFourV5
    @doc "Frozen — PYTHIA dual-Apollo + insert-only Pyth ledger flush (day + flushed-at args)."
    ;;
    (defun CODEX|A_RegisterCodexIdentity:string
        (
            codex-id:string
            public-standard:string
            public-smart:string
            codex-guard:guard
            registered-by:string
        ))
    (defun CODEX|C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun CODEX|C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun CODEX|C_RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun CODEX|C_ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun PYTHIA|C_DeployApiKey:string
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        ))
    (defun PYTHIA|C_UpdateDualConsumerLane:string
        (
            patron:string
            dual-link-key:string
            new-name:string
        ))
    (defun PYTHIA|C_Link:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun PYTHIA|A_Link:string (standard-apollo:string smart-apollo:string))
    (defun PYTHIA|C_RevokeLink:string
        (
            patron:string
            dual-link-key:string
        ))
    (defun PYTHIA|A_RevokeLink:string (patron:string dual-link-key:string))
    (defun PYTHIA|A_Flush:string
        (
            day:integer
            flushed-at:time
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        ))
)
(interface TalosStageOne_ClientFourV6BlockTime
    @doc "Frozen — never deployed. Block-time calendar A_Flush (single six-metric arg; superseded by batch ClientFourV6 in 06_TS01-C4.pact)."
    ;;
    (defun CODEX|A_RegisterCodexIdentity:string
        (
            codex-id:string
            public-standard:string
            public-smart:string
            codex-guard:guard
            registered-by:string
        ))
    (defun CODEX|C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun CODEX|C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun CODEX|C_RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun CODEX|C_ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun PYTHIA|C_DeployApiKey:string
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        ))
    (defun PYTHIA|C_UpdateDualConsumerLane:string
        (
            patron:string
            dual-link-key:string
            new-name:string
        ))
    (defun PYTHIA|C_Link:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun PYTHIA|A_Link:string (standard-apollo:string smart-apollo:string))
    (defun PYTHIA|C_RevokeLink:string
        (
            patron:string
            dual-link-key:string
        ))
    (defun PYTHIA|A_RevokeLink:string (patron:string dual-link-key:string))
    (defun PYTHIA|A_Flush:string
        (
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        ))
)

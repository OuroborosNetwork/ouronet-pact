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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_CODEX|RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string ))
    (defun C_CODEX|RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun C_CODEX|RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun C_CODEX|RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun C_CODEX|ReleaseStoicTag:string (patron:string tag-name:string))

)
(interface TalosStageOne_ClientFourV2
    @doc "Frozen — PYTHIA Apollo API-key registry initial surface (deactivate had no patron fee arg)."

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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_CODEX|RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string ))
    (defun C_CODEX|RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun C_CODEX|RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun C_CODEX|RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun C_CODEX|ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun C_PYTHIA|DeployApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun A_PYTHIA|DeploySmartApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun C_PYTHIA|UpdateApiConsumerName:string
        ( patron:string
          owner-account:string
          apollo-account:string
          new-name:string ))
    (defun A_PYTHIA|ActivateApiKey:string (apollo-account:string))
    (defun C_PYTHIA|DeactivateApiKey:string (owner-account:string apollo-account:string))
    (defun A_PYTHIA|DeactivateApiKey:string (apollo-account:string))

)
(interface TalosStageOne_ClientFourV3
    @doc "Talos Stage One Client Four V3 — PYTHIA deactivate collects 1 IGNIS via patron."

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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_CODEX|RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string ))
    (defun C_CODEX|RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun C_CODEX|RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun C_CODEX|RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun C_CODEX|ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun C_PYTHIA|DeployApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun A_PYTHIA|DeploySmartApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string
          public:string
          consumer-lane:string ))
    (defun C_PYTHIA|UpdateApiConsumerName:string
        ( patron:string
          owner-account:string
          apollo-account:string
          new-name:string ))
    (defun A_PYTHIA|ActivateApiKey:string (apollo-account:string))
    (defun C_PYTHIA|DeactivateApiKey:string
        ( patron:string
          owner-account:string
          apollo-account:string ))
    (defun A_PYTHIA|DeactivateApiKey:string (patron:string apollo-account:string))

)
(interface TalosStageOne_ClientFourV4
    @doc "Frozen — PYTHIA dual-Apollo (deploy 500 STOA/half, link free, revoke 1 IGNIS); pre-ledger."

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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_CODEX|RegisterCodexIdentity:string
        (
            codex-id:string
            public-standard:string
            public-smart:string
            codex-guard:guard
            registered-by:string
        ))
    (defun C_CODEX|RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun C_CODEX|RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun C_CODEX|RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun C_CODEX|ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun C_PYTHIA|DeployApiKey:string
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        ))
    (defun C_PYTHIA|UpdateDualConsumerLane:string
        (
            patron:string
            dual-link-key:string
            new-name:string
        ))
    (defun C_PYTHIA|Link:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun A_PYTHIA|Link:string (standard-apollo:string smart-apollo:string))
    (defun C_PYTHIA|RevokeLink:string
        (
            patron:string
            dual-link-key:string
        ))
    (defun A_PYTHIA|RevokeLink:string (patron:string dual-link-key:string))

)
(interface TalosStageOne_ClientFourV5
    @doc "Frozen — PYTHIA dual-Apollo + insert-only Pyth ledger flush (day + flushed-at args)."

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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_CODEX|RegisterCodexIdentity:string
        (
            codex-id:string
            public-standard:string
            public-smart:string
            codex-guard:guard
            registered-by:string
        ))
    (defun C_CODEX|RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun C_CODEX|RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun C_CODEX|RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun C_CODEX|ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun C_PYTHIA|DeployApiKey:string
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        ))
    (defun C_PYTHIA|UpdateDualConsumerLane:string
        (
            patron:string
            dual-link-key:string
            new-name:string
        ))
    (defun C_PYTHIA|Link:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun A_PYTHIA|Link:string (standard-apollo:string smart-apollo:string))
    (defun C_PYTHIA|RevokeLink:string
        (
            patron:string
            dual-link-key:string
        ))
    (defun A_PYTHIA|RevokeLink:string (patron:string dual-link-key:string))
    (defun A_PYTHIA|Flush:string
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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_CODEX|RegisterCodexIdentity:string
        (
            codex-id:string
            public-standard:string
            public-smart:string
            codex-guard:guard
            registered-by:string
        ))
    (defun C_CODEX|RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun C_CODEX|RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun C_CODEX|RegisterStoicTag:string (patron:string tag-name:string account-address:string))
    (defun C_CODEX|ReleaseStoicTag:string (patron:string tag-name:string))
    ;;
    (defun C_PYTHIA|DeployApiKey:string
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        ))
    (defun C_PYTHIA|UpdateDualConsumerLane:string
        (
            patron:string
            dual-link-key:string
            new-name:string
        ))
    (defun C_PYTHIA|Link:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun A_PYTHIA|Link:string (standard-apollo:string smart-apollo:string))
    (defun C_PYTHIA|RevokeLink:string
        (
            patron:string
            dual-link-key:string
        ))
    (defun A_PYTHIA|RevokeLink:string (patron:string dual-link-key:string))
    (defun A_PYTHIA|Flush:string
        (
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        ))

)

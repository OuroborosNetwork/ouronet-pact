;; Deploy: load THIS file — interface + module ship together (model: 07_MTX-AQP.pact).
;; DSA — Delegated Staking Agencies. A delegated node-staking layer on the FVT two-tier farm settle:
;;   an agency = one FVT member (a triplet for Custodians); delegators stake into it; the operator runs
;;   nodes to CAPTURE reward units and takes a fee. Depends on AQP-FVT (deploys first; DSA writes the
;;   member's delegation/capture fields via FVT XE_ and reads its own at inject). First client: Custodians.
;; Spec: Audit/DSA-DELEGATED-STAKING-DESIGN.md (v1 LOCKED). Built in phases: data model + vault define +
;;   agency open (Phase 2); capture recompute + delegated oracle (Phase 3); royalty disposal + collect (later).
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DsaV2
    @doc "Delegated Staking Agencies — client/reader surface (v1; grows as the module is built)."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

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
    ;;
    (defun UR_DSA-TMP|UnitScore:integer (fvt-id:string))
    (defun UR_DSA-TMP|Active:bool (fvt-id:string))
    (defun UR_DSA-AGN|Operator:string (fvt-id:string score-entity-id:string))
    (defun UR_DSA-AGN|Nodes:integer (fvt-id:string score-entity-id:string))
    (defun UR_DSA-AGN|Uptime:integer (fvt-id:string score-entity-id:string))
    ;;
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    (defun URCi_DefineDelegationVault:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    (defun URCi_OpenAgency:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    (defun URCi_RecomputeCapture:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    (defun URCi_SetOracleAuth:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    (defun URCi_OracleWrite:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    (defun URCi_WithdrawRoyalty:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    (defun URCi_BurnRoyalty:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    (defun URCi_FuelRoyalty:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    (defun URCi_SetAgencyFee:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_OpenGate:bool (fvt-id:string score-entity-id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_DefineDelegationVault:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string model-id:string unit-score:integer))
    (defun C_AdmitAgency:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer))
    (defun C_RecomputeCapture:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string))
    (defun A_SetOracleAuth:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string oracle-guard:guard))
    (defun A_OracleWrite:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer))
    (defun A_WithdrawRoyalty:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string))
    (defun A_BurnRoyalty:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string))
    (defun A_FuelRoyalty:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string swpair:string))
    (defun A_SetAgencyFee:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer))
    (defun A_ToggleExternalOracle:string (on:bool))
    (defun A_SetOracleValidity:string (seconds:integer))

)
;;
(module AQP-DSA GOV
    @doc "Delegated Staking Agencies — a delegation layer over AQP-FVT's two-tier farm \
        \ settle. An agency is one FVT member (a triplet for Custodians): delegators stake \
        \ into it, an operator runs nodes to capture reward units and takes a per-mille fee. \
        \ Provides A_DefineDelegationVault, C_AdmitAgency, C_RecomputeCapture, oracle \
        \ auth/write, and royalty withdraw/burn/fuel/fee ops; it writes the member's \
        \ delegation/capture fields through FVT XE_ and reads them at inject. First client: \
        \ Custodians."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DsaV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DSA                                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DSA_ADMIN)))
    (defcap GOV|DSA_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_DSA)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "DSA Ownership not verified"
                [
                    (enforce-guard g1)
                    (enforce-guard g2)
                ]
            )
        )
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|DSA|CALLER ()
        true
    )
    (defcap P|DSA|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DSA|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|DSA|REMOTE-GOV))
        (compose-capability (P|DSA|CALLER))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|DSA_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|DSA_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                (mg:guard (create-capability-guard (P|DSA|CALLER)))
            )
            ;; DSA calls AQP-FVT's XE_ building blocks (SetMemberCapture / SetMemberDelegation / SetFvtOracleOn,
            ;; all P|UEV_IMC-gated) — register DSA as an allowed IMC caller of AQP-FVT. (SCORE/POOL calls for
            ;; agency-open are added here when that path is built.)
            (ref-P|FVT::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;; Operator fee bounds (flat, per-mille): 1%..50%.
    (defconst DSA_FEE_MIN:integer 10)
    (defconst DSA_FEE_MAX:integer 500)
    ;; Full-uptime promile (the oracle scale; capture-weight = capture-units × uptime / DSA_UPTIME_FULL).
    (defconst DSA_UPTIME_FULL:integer 1000)
    (defconst GAS|DEFINE-VAULT:decimal 500.0)
    (defconst GAS|OPEN-AGENCY:decimal 500.0)
    (defconst GAS|RECOMPUTE-CAPTURE:decimal 300.0)
    (defconst GAS|SET-ORACLE-AUTH:decimal 300.0)
    (defconst GAS|ORACLE-WRITE:decimal 200.0)
    (defconst GAS|WITHDRAW-ROYALTY:decimal 400.0)
    (defconst GAS|BURN-ROYALTY:decimal 400.0)
    (defconst GAS|FUEL-ROYALTY:decimal 500.0)
    (defconst GAS|SET-AGENCY-FEE:decimal 300.0)
    (defconst DSA_UPTIME_MIN:integer 0)
    ;;{3.2}  schemas
    ;;
    (defschema DSA|Template
        @doc "Key = <FVT-ID>. Per DSA vault: binds a class-0 FVT to the score-entity MODEL every agency \
            \ instantiates (SCR|ScoreEntityModel) + the unit-score (1 staking unit = 1 node; open gate = \
            \ unit-score/2). The model fixes the scoring (Custodians nonce→quintessence) so all agencies are comparable."
        model-id:string                                         ;;[.]   the SCR|ScoreEntityModel agencies instantiate (SCORE)
        unit-score:integer                                      ;;[.]   quintessence per capture unit (e.g. 20000)
        active:bool                                             ;;[M]
        ;;Select Keys
        fvt-id:string
    )
    (defschema DSA|Agency
        @doc "Key = <FVT-ID> | <Score-Entity-ID>. One agency = one FVT member (its triplet). Operator is an \
            \ ownership role independent of stake; fee is skimmed from delegators only. nodes + uptime are the \
            \ oracle inputs to the capture transform (the derived capture-units/weight live on the FVT member)."
        operator-konto:string                                   ;;[..]  the agency operator (runs nodes, takes the fee)
        fee-per-mille:integer                                   ;;[M]   flat fee 10..500 (= 1%..50%) on delegators
        nodes:integer                                           ;;[M]   oracle: nodes the operator runs (capture cap)
        uptime:integer                                          ;;[M]   oracle: promile 1..1000 (1000 = full)
        ;;Select Keys
        fvt-id:string
        score-entity-id:string
    )
    (defschema DSA|OracleAuth
        @doc "Key = <FVT-ID>. The FVT-owner-delegated key allowed to write the daily {nodes, uptime} oracle values \
            \ for every agency on this vault."
        oracle-guard:guard                                      ;;[M]
        ;;Select Keys
        fvt-id:string
    )
    ;;{3.3}  tables
    (deftable DSA|T|Template:{DSA|Template})                    ;; Key = <FVT-ID>
    (deftable DSA|T|Agency:{DSA|Agency})                        ;; Key = <FVT-ID> | <Score-Entity-ID>
    (deftable DSA|T|OracleAuth:{DSA|OracleAuth})                ;; Key = <FVT-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap DSA|C>DEFINE-VAULT (patron:string fvt-id:string model-id:string unit-score:integer)
        @doc "Bind a class-0 FVT as a DSA delegation vault. Enforces: the FVT exists + is class-0, patron IS the \
            \ FVT owner (+ signs), unit-score positive, no template yet. Composes SECURE for the template write. \
            \ (The model-id's validity is enforced when C_OpenAgency calls the SCORE factory.)"
        @event
        (let
            (
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (ref-FVT::UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (= (ref-FVT::UR_FVT|FvtClass fvt-id) 0) "DSA vault must be a class-0 FVT")
            (enforce (= patron fvt-owner) "Only the FVT owner may define the delegation vault")
            (enforce (> unit-score 0) "unit-score must be positive")
            (enforce (not (URC_DsaTemplateExists fvt-id)) "This FVT is already a DSA vault")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (SECURE))
    )
    (defcap DSA|C>OPEN-AGENCY (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Authorize opening a delegation agency on an active DSA vault. Enforces the vault template exists + \
            \ active and the fee is in [DSA_FEE_MIN, DSA_FEE_MAX]. Composes P|SECURE-CALLER so DSA's registered IMC \
            \ guard + SECURE are active for the FVT admit/delegation/stake calls + the DSA|Agency write. The \
            \ one-time quintessence ≥ unit-score/2 OPEN GATE is NOT here — it is a TERMINAL enforce at the END of \
            \ C_OpenAgency's body, AFTER the operator's initial stake (the cap runs before the body, when Q is still \
            \ 0; a score can only be staked once admission has linked it, so the stake must live inside open). \
            \ Operator account-ownership is enforced downstream in FVT|XE>ADMIT-DELEGATION."
        @event
        (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
        (enforce (and (>= fee-per-mille DSA_FEE_MIN) (<= fee-per-mille DSA_FEE_MAX)) "Operator fee out of range (1%..50%)")
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>RECOMPUTE-CAPTURE (patron:string fvt-id:string score-entity-id:string)
        @doc "Recompute an agency's capture from its CURRENT quintessence / nodes / uptime (permissionless — any \
            \ patron may keep an agency's capture fresh after a delegator stake/unstake changed Q). Enforces the \
            \ FVT is a DSA vault + the score entity is a delegation member. Composes P|SECURE-CALLER for the FVT \
            \ XE_SetMemberCapture write."
        @event
        (let
            (
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (ref-FVT::UR_FVT-SEL|Delegation fvt-id score-entity-id) "Score entity is not a delegation member")
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>SET-ORACLE-AUTH (patron:string fvt-id:string)
        @doc "Authorize the delegated oracle key for a DSA vault + arm the FVT oracle-on expiry. Owner-gated \
            \ (patron IS the FVT owner + signs). Composes P|SECURE-CALLER for the FVT XE_SetFvtOracleOn write."
        @event
        (let
            (
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (ref-FVT::UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= patron fvt-owner) "Only the FVT owner may set the oracle authority")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>WITHDRAW-ROYALTY (patron:string fvt-id:string)
        @doc "Owner-only: withdraw the whole royalty pool of a DSA vault to the FVT owner. Enforces the vault is a \
            \ live DSA vault + patron IS the FVT owner (+ signs). Composes P|SECURE-CALLER so DSA's registered IMC \
            \ guard is active for the FVT XE_WithdrawRoyalty custody call."
        @event
        (let
            (
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (ref-FVT::UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= patron fvt-owner) "Only the FVT owner may withdraw royalty")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>BURN-ROYALTY (patron:string fvt-id:string)
        @doc "Owner-only: BURN the whole royalty pool of a DSA vault. Enforces the vault is a live DSA vault + \
            \ patron IS the FVT owner (+ signs). Composes P|SECURE-CALLER so DSA's registered IMC guard is active \
            \ for the FVT XE_BurnRoyalty custody-burn call."
        @event
        (let
            (
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (ref-FVT::UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= patron fvt-owner) "Only the FVT owner may burn royalty")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>FUEL-ROYALTY (patron:string fvt-id:string swpair:string)
        @doc "Owner-only: FUEL a swpair with the whole royalty pool of a DSA vault (add liquidity, no LP mint). \
            \ Enforces the vault is a live DSA vault + patron IS the FVT owner (+ signs). Composes P|SECURE-CALLER \
            \ so DSA's registered IMC guard is active for the FVT XE_FuelRoyalty custody-fuel call."
        @event
        (let
            (
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (ref-FVT::UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= patron fvt-owner) "Only the FVT owner may fuel with royalty")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>SET-AGENCY-FEE (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Owner-only: change a delegation agency's operator fee. Enforces the vault is live, patron IS the FVT \
            \ owner (+ signs), fee in [DSA_FEE_MIN, DSA_FEE_MAX]. A fee change is O(1) — it reprices only FUTURE \
            \ injects (the fee is never baked into a stored weight). Composes P|SECURE-CALLER for the FVT mirror."
        @event
        (let
            (
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (ref-FVT::UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= patron fvt-owner) "Only the FVT owner may change the agency fee")
            (enforce (and (>= fee-per-mille DSA_FEE_MIN) (<= fee-per-mille DSA_FEE_MAX)) "Operator fee out of range (1%..50%)")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|A>ORACLE-WRITE (fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "The delegated oracle writes an agency's daily {nodes, uptime}. Enforces the registered oracle guard \
            \ (DSA|OracleAuth), the score entity is a delegation member, nodes non-negative, uptime in \
            \ [DSA_UPTIME_MIN, DSA_UPTIME_FULL]. Composes P|SECURE-CALLER for the recompute + FVT capture write."
        @event
        (let
            (
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
            )
            (enforce-guard (UR_DSA-ORA|Guard fvt-id))
            (enforce (ref-FVT::UR_FVT-SEL|Delegation fvt-id score-entity-id) "Score entity is not a delegation member")
            (enforce (fold (and) true
                [ (>= nodes 0)
                  (>= uptime DSA_UPTIME_MIN)
                  (<= uptime DSA_UPTIME_FULL) ]) "Oracle values out of range (nodes >= 0, uptime 0..1000)")
        )
        (compose-capability (P|SECURE-CALLER))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    ;; [UDC] construct
    (defun UDC_DSA|Template:object{DSA|Template}
        (model-id:string unit-score:integer active:bool fvt-id:string)
        @doc "Core constructor for object{DSA|Template}."
        {"model-id"            : model-id
        ,"unit-score"          : unit-score
        ,"active"              : active
        ,"fvt-id"              : fvt-id}
    )
    (defun UDC_DSA|Agency:object{DSA|Agency}
        (operator-konto:string fee-per-mille:integer nodes:integer uptime:integer fvt-id:string score-entity-id:string)
        @doc "Core constructor for object{DSA|Agency}."
        {"operator-konto" : operator-konto
        ,"fee-per-mille"  : fee-per-mille
        ,"nodes"          : nodes
        ,"uptime"         : uptime
        ,"fvt-id"         : fvt-id
        ,"score-entity-id": score-entity-id}
    )
    (defun UDC_DSA|OracleAuth:object{DSA|OracleAuth}
        (oracle-guard:guard fvt-id:string)
        @doc "Core constructor for object{DSA|OracleAuth}."
        {"oracle-guard" : oracle-guard
        ,"fvt-id"       : fvt-id}
    )
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    (defun UCk_Agency:string (fvt-id:string score-entity-id:string)
        @doc "Composite key for DSA|T|Agency: fvt-id | score-entity-id."
        (concat [fvt-id BAR score-entity-id])
    )
    (defun UC_CaptureWeight:decimal (capture-units:decimal uptime:integer)
        @doc "The capture-weight (inject numerator) = capture-units × uptime / DSA_UPTIME_FULL. Uptime is a \
            \ per-mille [0..1000]; /1000 is exact in decimal, so no rounding is needed."
        (* capture-units (/ (dec uptime) (dec DSA_UPTIME_FULL)))
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    (defun UR_DSA-TMP|Template:object{DSA|Template} (fvt-id:string)
        @doc "Reads the full DSA template row for a vault."
        (read DSA|T|Template fvt-id)
    )
    (defun UR_DSA-TMP|ModelId:string (fvt-id:string)
        @doc "Reads the score-entity model-id bound to a DSA vault."
        (at "model-id" (read DSA|T|Template fvt-id ["model-id"]))
    )
    (defun UR_DSA-TMP|UnitScore:integer (fvt-id:string)
        @doc "Reads the unit-score (quintessence per capture unit; open gate = unit-score/2) for a DSA vault."
        (at "unit-score" (read DSA|T|Template fvt-id ["unit-score"]))
    )
    (defun UR_DSA-TMP|Active:bool (fvt-id:string)
        @doc "Reads whether a DSA vault template is active."
        (at "active" (read DSA|T|Template fvt-id ["active"]))
    )
    (defun UR_DSA-AGN|Agency:object{DSA|Agency} (fvt-id:string score-entity-id:string)
        @doc "Reads the full agency row (absent ⇒ defaults: no operator, min fee, no nodes, full uptime)."
        (with-default-read DSA|T|Agency (UCk_Agency fvt-id score-entity-id)
            {"operator-konto": "", "fee-per-mille": DSA_FEE_MIN, "nodes": 0, "uptime": DSA_UPTIME_FULL
            ,"fvt-id": fvt-id, "score-entity-id": score-entity-id}
            {"operator-konto":= op, "fee-per-mille":= fee, "nodes":= n, "uptime":= u, "fvt-id":= fid, "score-entity-id":= seid}
            (UDC_DSA|Agency op fee n u fid seid)
        )
    )
    (defun UR_DSA-AGN|Operator:string (fvt-id:string score-entity-id:string)
        @doc "Reads an agency's operator konto."
        (at "operator-konto" (UR_DSA-AGN|Agency fvt-id score-entity-id))
    )
    (defun UR_DSA-AGN|FeePerMille:integer (fvt-id:string score-entity-id:string)
        @doc "Reads an agency's flat operator fee (per-mille, on delegators only)."
        (at "fee-per-mille" (UR_DSA-AGN|Agency fvt-id score-entity-id))
    )
    (defun UR_DSA-AGN|Nodes:integer (fvt-id:string score-entity-id:string)
        @doc "Reads an agency's oracle node count (the capture-unit cap)."
        (at "nodes" (UR_DSA-AGN|Agency fvt-id score-entity-id))
    )
    (defun UR_DSA-AGN|Uptime:integer (fvt-id:string score-entity-id:string)
        @doc "Reads an agency's oracle uptime promile (1..1000)."
        (at "uptime" (UR_DSA-AGN|Agency fvt-id score-entity-id))
    )
    (defun UR_DSA-ORA|Guard:guard (fvt-id:string)
        @doc "Reads the delegated oracle-write guard for a DSA vault."
        (at "oracle-guard" (read DSA|T|OracleAuth fvt-id ["oracle-guard"]))
    )
    (defun URC_DsaTemplateExists:bool (fvt-id:string)
        @doc "True when a DSA vault template exists for this FVT."
        (with-default-read DSA|T|Template fvt-id {"fvt-id" : BAR} {"fvt-id" := f} (!= f BAR))
    )
    (defun URC_DsaTemplateActive:bool (fvt-id:string)
        @doc "True when a DSA vault template exists AND is active."
        (with-default-read DSA|T|Template fvt-id {"fvt-id" : BAR, "active" : false} {"fvt-id" := f, "active" := a} (and (!= f BAR) a))
    )
    (defun URC_AgencyQuintessence:decimal (score-entity-id:string)
        @doc "An agency's total quintessence = Σ the triplet's three scores' total-base-score (staked collectable × \
            \ the model's nonce values). The open gate + the capture divisor read this."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (+ (ref-SCR::UR_SCR|ScoreTotalBaseScore (ref-SCR::UR_SCR|TripletBronzeScoreId score-entity-id))
               (+ (ref-SCR::UR_SCR|ScoreTotalBaseScore (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                  (ref-SCR::UR_SCR|ScoreTotalBaseScore (ref-SCR::UR_SCR|TripletGoldenScoreId score-entity-id))))
        )
    )
    (defun URC_CaptureUnits:decimal (fvt-id:string score-entity-id:string)
        @doc "How many whole capture units this agency currently commands = min(⌊Q / unit-score⌋, nodes): the \
            \ stake supports ⌊Q/unit-score⌋ units, capped by the oracle-reported node count."
        (let
            (
                (raw:integer (floor (/ (URC_AgencyQuintessence score-entity-id) (dec (UR_DSA-TMP|UnitScore fvt-id)))))
                (nodes:integer (UR_DSA-AGN|Nodes fvt-id score-entity-id))
            )
            (dec (if (< raw nodes) raw nodes))
        )
    )
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    ;;   (flat GAS legs; the 3 royalty readers return the GAS leg the exec concats with the custody-move XE_)
    (defun URCi_DefineDelegationVault:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|DEFINE-VAULT patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_OpenAgency:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg for the core admit (C_AdmitAgency); the Talos open flow additionally stakes operator collateral."
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|OPEN-AGENCY patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_RecomputeCapture:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|RECOMPUTE-CAPTURE patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetOracleAuth:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|SET-ORACLE-AUTH patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_OracleWrite:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|ORACLE-WRITE patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_WithdrawRoyalty:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg only; exec concats this with the custody-move IGNIS (FVT::XE_WithdrawRoyalty, state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|WITHDRAW-ROYALTY patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_BurnRoyalty:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg only; exec concats this with the burn's IGNIS (FVT::XE_BurnRoyalty, state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|BURN-ROYALTY patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_FuelRoyalty:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg only; exec concats this with the fuel's IGNIS (FVT::XE_FuelRoyalty, state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|FUEL-ROYALTY patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_WithdrawRoyaltyFull:decimal (patron:string fvt-id:string reward-dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of A_WithdrawRoyalty: GAS|WITHDRAW-ROYALTY gas leg + the FVT custody-move \
            \ leg (FVT::URCi_WithdrawRoyaltyCustody mirroring XE_WithdrawRoyalty to the FVT owner). Read-only mirror \
            \ of the exec's UDC_ConcatenateOutputCumulators [gas custody]."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_WithdrawRoyalty patron [fvt-id]))
               (ref-FVT::URCi_WithdrawRoyaltyCustody fvt-id reward-dptf-id (ref-FVT::UR_FVT|OwnerKonto fvt-id)))
        ))
    (defun URCi_BurnRoyaltyFull:decimal (patron:string fvt-id:string reward-dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of A_BurnRoyalty: GAS|BURN-ROYALTY gas leg + the FVT custody-burn leg \
            \ (FVT::URCi_BurnRoyaltyCustody mirroring XE_BurnRoyalty). Read-only mirror of the exec's concat."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_BurnRoyalty patron [fvt-id]))
               (ref-FVT::URCi_BurnRoyaltyCustody fvt-id reward-dptf-id))
        ))
    (defun URCi_FuelRoyaltyFull:decimal (patron:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "FULL reconstructed IGNIS ifp of A_FuelRoyalty: GAS|FUEL-ROYALTY gas leg + the FVT custody-fuel leg \
            \ (FVT::URCi_FuelRoyaltyCustody mirroring XE_FuelRoyalty into <swpair>). Read-only mirror of the exec's concat."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_FuelRoyalty patron [fvt-id]))
               (ref-FVT::URCi_FuelRoyaltyCustody fvt-id reward-dptf-id swpair))
        ))
    (defun URCi_SetAgencyFee:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|SET-AGENCY-FEE patron (r::URC_IsVirtualGasZero) output)
        ))
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_OpenGate:bool (fvt-id:string score-entity-id:string)
        @doc "Terminal open gate — after the operator's initial stake, the agency quintessence must clear \
            \ unit-score/2. The Talos C_AQP-DSA|OpenAgency flow calls this at the END of the atomic open (admit → \
            \ stake → THIS); a short operator stake fails here and rolls the whole open back. Unprotected read+enforce."
        (enforce (>= (URC_AgencyQuintessence score-entity-id) (/ (dec (UR_DSA-TMP|UnitScore fvt-id)) 2.0))
            "Open gate: operator must stake quintessence >= unit-score/2 to open")
    )
    ;;{5.5}  Write [W]
    ;; [W]   write
    (defun WI_Template:string (fvt-id:string row:object{DSA|Template})
        @doc "Insert a DSA vault template row. require SECURE."
        (require-capability (SECURE))
        (insert DSA|T|Template fvt-id row)
    )
    (defun WI_Agency:string (fvt-id:string score-entity-id:string row:object{DSA|Agency})
        @doc "Insert a DSA agency row. require SECURE."
        (require-capability (SECURE))
        (insert DSA|T|Agency (UCk_Agency fvt-id score-entity-id) row)
    )
    (defun WU_Agency-Oracle:string (fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "Update an agency's oracle inputs {nodes, uptime}. require SECURE."
        (require-capability (SECURE))
        (update DSA|T|Agency (UCk_Agency fvt-id score-entity-id) {"nodes" : nodes, "uptime" : uptime})
    )
    (defun WU_Agency-Fee:string (fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Update an agency's operator fee-per-mille. require SECURE."
        (require-capability (SECURE))
        (update DSA|T|Agency (UCk_Agency fvt-id score-entity-id) {"fee-per-mille" : fee-per-mille})
    )
    (defun WI_OracleAuth:string (fvt-id:string row:object{DSA|OracleAuth})
        @doc "Write (set / rotate) a DSA vault's oracle authority row. require SECURE."
        (require-capability (SECURE))
        (write DSA|T|OracleAuth fvt-id row)
    )
    ;;{5.6}  Aux/X
    ;; [XI]
    (defun XI_ApplyCapture:string (fvt-id:string score-entity-id:string oracle-ts:time)
        @doc "Recompute an agency's capture from CURRENT Q / nodes / uptime and write it onto the FVT member \
            \ (XE_SetMemberCapture), stamping the given oracle-ts. Callers hold P|SECURE-CALLER (⇒ SECURE + the \
            \ DSA IMC guard the FVT XE_ requires); a stake recompute passes the PRESERVED oracle-ts, an oracle \
            \ write passes NOW."
        (require-capability (SECURE))
        (let
            (
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                (units:decimal (URC_CaptureUnits fvt-id score-entity-id))
            )
            (ref-FVT::XE_SetMemberCapture fvt-id score-entity-id
                units (UC_CaptureWeight units (UR_DSA-AGN|Uptime fvt-id score-entity-id)) oracle-ts)
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [A]   admin
    (defun A_DefineDelegationVault:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string model-id:string unit-score:integer)
        @doc "Bind a class-0 FVT as a DSA delegation vault: record the score-entity model + unit-score (active). \
            \ Only the FVT owner may define it. P|UEV_IMC + DSA|C>DEFINE-VAULT. Bills GAS|DEFINE-VAULT."
        (P|UEV_IMC)
        (with-capability (DSA|C>DEFINE-VAULT patron fvt-id model-id unit-score)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WI_Template fvt-id (UDC_DSA|Template model-id unit-score true fvt-id))
                (URCi_DefineDelegationVault patron [fvt-id])
            )
        )
    )
    (defun A_SetOracleAuth:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string oracle-guard:guard)
        @doc "Owner-only: authorize the delegated oracle key for this DSA vault (DSA|OracleAuth) and ARM the FVT \
            \ oracle-on expiry, so stale oracle data (>25h) captures nothing. P|UEV_IMC + DSA|C>SET-ORACLE-AUTH. \
            \ Bills GAS|SET-ORACLE-AUTH."
        (P|UEV_IMC)
        (with-capability (DSA|C>SET-ORACLE-AUTH patron fvt-id)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WI_OracleAuth fvt-id (UDC_DSA|OracleAuth oracle-guard fvt-id))
                (ref-FVT::XE_SetFvtOracleOn fvt-id true)
                (URCi_SetOracleAuth patron [fvt-id])
            )
        )
    )
    (defun A_OracleWrite:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "Delegated-oracle-only: write an agency's daily {nodes, uptime}, then recompute its capture stamped \
            \ with NOW (fresh oracle-ts resets the 25h expiry). Authorized by the registered oracle guard. \
            \ P|UEV_IMC + DSA|A>ORACLE-WRITE. Bills GAS|ORACLE-WRITE."
        (P|UEV_IMC)
        (with-capability (DSA|A>ORACLE-WRITE fvt-id score-entity-id nodes uptime)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WU_Agency-Oracle fvt-id score-entity-id nodes uptime)
                (XI_ApplyCapture fvt-id score-entity-id (at "block-time" (chain-data)))
                (URCi_OracleWrite patron [score-entity-id])
            )
        )
    )
    (defun A_ToggleExternalOracle:string (on:bool)
        @doc "DSA MODULE ADMIN (GOV): flip the SINGULAR GLOBAL external-oracle switch for ALL operators at once. \
            \ OFF ⇒ external oracling is bypassed protocol-wide — every agency captures its STORED weight (oracle \
            \ entries, fresh or stale, are ignored); ON ⇒ the oracle-validity freshness gate applies (an operator \
            \ with no/stale entry captures 0). Composes P|SECURE-CALLER for the FVT global-config write."
        (with-capability (GOV|DSA_ADMIN)
            (with-capability (P|SECURE-CALLER)
                (let
                    (
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                    )
                    (ref-FVT::XE_SetExternalOracle on)
                )
            )
        )
    )
    (defun A_SetOracleValidity:string (seconds:integer)
        @doc "DSA MODULE ADMIN (GOV): set the GLOBAL oracle-validity window (seconds; the freshness horizon an \
            \ oracle write is honored for while external-oracle is ON). Must be positive. Composes P|SECURE-CALLER \
            \ for the FVT global-config write."
        (enforce (> seconds 0) "oracle-validity must be positive")
        (with-capability (GOV|DSA_ADMIN)
            (with-capability (P|SECURE-CALLER)
                (let
                    (
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                    )
                    (ref-FVT::XE_SetOracleValidity seconds)
                )
            )
        )
    )
    (defun A_WithdrawRoyalty:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Owner-only: dispose the whole royalty pool (uptime-shortfall custody) of <reward-dptf-id> on a DSA \
            \ vault by WITHDRAWING it to the FVT owner (delegates the AQP-custody move + zero to the FVT primitive \
            \ FVT::XE_WithdrawRoyalty, which holds the custody-governor authority). P|UEV_IMC + DSA|C>WITHDRAW-ROYALTY. \
            \ Bills GAS|WITHDRAW-ROYALTY merged with the custody transfer's IGNIS."
        (P|UEV_IMC)
        (with-capability (DSA|C>WITHDRAW-ROYALTY patron fvt-id)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [ (URCi_WithdrawRoyalty patron [fvt-id])
                      (ref-FVT::XE_WithdrawRoyalty fvt-id reward-dptf-id (ref-FVT::UR_FVT|OwnerKonto fvt-id)) ]
                    [fvt-id])
            )
        )
    )
    (defun A_BurnRoyalty:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string)
        @doc "Owner-only: dispose the whole royalty pool of <reward-dptf-id> on a DSA vault by BURNING it (delegates \
            \ the AQP-custody burn + zero to FVT::XE_BurnRoyalty; AQP|SC_NAME holds the autonomic burn role). \
            \ P|UEV_IMC + DSA|C>BURN-ROYALTY. Bills GAS|BURN-ROYALTY merged with the burn's IGNIS."
        (P|UEV_IMC)
        (with-capability (DSA|C>BURN-ROYALTY patron fvt-id)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [ (URCi_BurnRoyalty patron [fvt-id])
                      (ref-FVT::XE_BurnRoyalty fvt-id reward-dptf-id) ]
                    [fvt-id])
            )
        )
    )
    (defun A_FuelRoyalty:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Owner-only: dispose the whole royalty pool of <reward-dptf-id> on a DSA vault by FUELING <swpair> \
            \ (add liquidity WITHOUT minting LP — delegates to FVT::XE_FuelRoyalty; the reward-dptf must be a token \
            \ of the swpair). P|UEV_IMC + DSA|C>FUEL-ROYALTY. Bills GAS|FUEL-ROYALTY merged with the fuel's IGNIS."
        (P|UEV_IMC)
        (with-capability (DSA|C>FUEL-ROYALTY patron fvt-id swpair)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [ (URCi_FuelRoyalty patron [fvt-id])
                      (ref-FVT::XE_FuelRoyalty fvt-id reward-dptf-id swpair) ]
                    [fvt-id])
            )
        )
    )
    (defun A_SetAgencyFee:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Owner-only: change a delegation agency's operator fee-per-mille. Updates DSA|Agency + mirrors it onto \
            \ the FVT member (FVT::XE_SetAgencyFee) so the next inject uses the new split. Safe + O(1) — the fee is \
            \ never in a stored weight, so this reprices only FUTURE injects, no per-delegator recompute. P|UEV_IMC + \
            \ DSA|C>SET-AGENCY-FEE. Bills GAS|SET-AGENCY-FEE."
        (P|UEV_IMC)
        (with-capability (DSA|C>SET-AGENCY-FEE patron fvt-id score-entity-id fee-per-mille)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WU_Agency-Fee fvt-id score-entity-id fee-per-mille)
                (ref-FVT::XE_SetAgencyFee fvt-id score-entity-id (UR_DSA-AGN|Operator fvt-id score-entity-id) fee-per-mille)
                (URCi_SetAgencyFee patron [score-entity-id])
            )
        )
    )
    ;; [C]   client
    (defun C_AdmitAgency:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Core admit of the ATOMIC open (the Talos C_AQP-DSA|OpenAgency flow drives the full sequence): admit \
            \ the operator's BLANK triplet as a delegation member of the class-0 vault FVT (XE_AdmitDelegationMember \
            \ — requires the sub-scores' fvt-links BAR, i.e. unstaked) + flip delegation on + record DSA|Agency. \
            \ Does NOT stake or gate: the deep DPDC custody transfer of the operator's stake needs the caller's \
            \ guard registered in DPDC-T's IMP, which is P|TS (Talos) — so the Talos flow performs the stake under \
            \ P|TS after this admit, then calls UEV_OpenGate as the terminal atomic check (a short stake reverts the \
            \ whole open). P|UEV_IMC + DSA|C>OPEN-AGENCY. Bills GAS|OPEN-AGENCY."
        (P|UEV_IMC)
        (with-capability (DSA|C>OPEN-AGENCY patron fvt-id score-entity-id fee-per-mille)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-FVT::XE_AdmitDelegationMember fvt-id score-entity-id patron)
                (ref-FVT::XE_SetMemberDelegation fvt-id score-entity-id true)
                (WI_Agency fvt-id score-entity-id (UDC_DSA|Agency patron fee-per-mille 0 DSA_UPTIME_FULL fvt-id score-entity-id))
                ;; mirror the operator + fee onto the FVT member so the inject settle can apply the fee split locally
                (ref-FVT::XE_SetAgencyFee fvt-id score-entity-id patron fee-per-mille)
                (URCi_OpenAgency patron [score-entity-id])
            )
        )
    )
    (defun C_RecomputeCapture:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string)
        @doc "Permissionless: recompute an agency's capture from its CURRENT quintessence (after a delegator \
            \ stake/unstake changed Q), PRESERVING the stored oracle-ts (a stake must not refresh oracle freshness). \
            \ P|UEV_IMC + DSA|C>RECOMPUTE-CAPTURE. Bills GAS|RECOMPUTE-CAPTURE."
        (P|UEV_IMC)
        (with-capability (DSA|C>RECOMPUTE-CAPTURE patron fvt-id score-entity-id)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV2} AQP-FVT)
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (XI_ApplyCapture fvt-id score-entity-id (ref-FVT::UR_FVT-SEL|OracleTs fvt-id score-entity-id))
                (URCi_RecomputeCapture patron [score-entity-id])
            )
        )
    )

)
(create-table P|T)
(create-table P|MT)
(create-table DSA|T|Template)
(create-table DSA|T|Agency)
(create-table DSA|T|OracleAuth)

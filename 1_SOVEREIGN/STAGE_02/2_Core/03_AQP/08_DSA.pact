;; Deploy: load THIS file — interface + module ship together (model: 07_MTX-AQP.pact).
;; DSA — Delegated Staking Agencies. A delegated node-staking layer on the FVT two-tier farm settle:
;;   an agency = one FVT member (a triplet for Custodians); delegators stake into it; the operator runs
;;   nodes to CAPTURE reward units and takes a fee. Depends on AQP-FVT (deploys first; DSA writes the
;;   member's delegation/capture fields via FVT XE_ and reads its own at inject). First client: Custodians.
;; Spec: Audit/DSA-DELEGATED-STAKING-DESIGN.md (v1 LOCKED). Built in phases: data model + vault define +
;;   agency open (Phase 2); capture recompute + delegated oracle (Phase 3); royalty disposal + collect (later).
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DsaV1
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
    (defun URCi_DefineDelegationVault:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string]))
    (defun URCi_OpenAgency:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string]))
    (defun URCi_RecomputeCapture:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string]))
    (defun URCi_SetOracleAuth:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string]))
    (defun URCi_OracleWrite:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string]))
    (defun URCi_WithdrawRoyalty:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string]))
    (defun URCi_BurnRoyalty:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string]))
    (defun URCi_FuelRoyalty:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string]))
    (defun URCi_SetAgencyFee:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string]))
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_OpenGate:bool (fvt-id:string score-entity-id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_DefineDelegationVault:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string model-id:string unit-score:integer))
    (defun C_AdmitAgency:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer))
    (defun C_RecomputeCapture:object{IgnisCollectorV3.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string))
    (defun C_SetOracleAuth:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string oracle-guard:guard))
    (defun C_OracleWrite:object{IgnisCollectorV3.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer))
    (defun C_WithdrawRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string))
    (defun C_BurnRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string))
    (defun C_FuelRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string swpair:string))
    (defun C_SetAgencyFee:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer))
    (defun A_ToggleExternalOracle:string (patron:string executor:string on:bool))
    (defun A_SetOracleValidity:string (patron:string executor:string seconds:integer))

)
;;
(module AQP-DSA GOV
    @doc "Delegated Staking Agencies — a delegation layer over AQP-FVT's two-tier farm \
        \ settle. An agency is one FVT member (a triplet for Custodians): delegators stake \
        \ into it, an operator runs nodes to capture reward units and takes a per-mille fee. \
        \ Provides C_DefineDelegationVault, C_AdmitAgency, C_RecomputeCapture, oracle \
        \ auth/write, and royalty withdraw/burn/fuel/fee ops; it writes the member's \
        \ delegation/capture fields through FVT XE_ and reads them at inject. First client: \
        \ Custodians."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DsaV1)

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
        ;;DEFAULT ADDED 2026-09-14 (owner ruling). This was a bare `read`, which RAISES
        ;;`No value found in table <M>_P|MT for key: InterModulePolicies` when the row does not
        ;;exist -- i.e. before ANY module has registered. P|UEV_IMC is built on this, so in that
        ;;window the inter-module gate answered with a raw table error naming a row key instead of
        ;;refusing cleanly. Surfaced by the X-01 repair, which removed the harness registration
        ;;that had been creating the row as a side effect.
        ;;
        ;;The default is the module's OWN SECURE capability guard, which is exactly what
        ;;P|A_AddIMP already seeds the row with. So reader and writer now agree on what an
        ;;unregistered policy list contains, and the gate's answer is the same before and after
        ;;the first registration: satisfiable only from inside this module.
        (with-default-read P|MT P|I
            {"m-policies" : [(create-capability-guard (SECURE))]}
            {"m-policies" := mp}
            mp
        )
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
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DSA_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \
            \ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \
            \ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (GOV|DSA_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \
            \ Deduplicates, and enforces that the module's own SECURE seed survives: without it \
            \ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (GOV|DSA_ADMIN)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                (ref-P|RPS:module{OuronetPolicyV2} RPS)
                (mg:guard (create-capability-guard (P|DSA|CALLER)))
            )
            ;; DSA calls AQP-FVT's XE_ building blocks (SetMemberCapture / SetMemberDelegation / SetFvtOracleOn,
            ;; all P|UEV_IMC-gated) — register DSA as an allowed IMC caller of AQP-FVT. (SCORE/POOL calls for
            ;; agency-open are added here when that path is built.)
            (ref-P|FVT::P|A_AddIMP mg)
            ;; #75 B': DSA's capture/oracle/royalty XE_ building blocks moved to the RPS reward engine — register on RPS IMP.
            (ref-P|RPS::P|A_AddIMP mg)
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
    (defconst GAS|DEFINE-VAULT:decimal                      (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "issue-dsa-vault")))
    (defconst GAS|OPEN-AGENCY:decimal                       (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "issue-dsa-agency")))
    (defconst GAS|RECOMPUTE-CAPTURE:decimal                 (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "recompute-capture")))
    (defconst GAS|SET-ORACLE-AUTH:decimal                   (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "set-oracle-auth")))
    (defconst GAS|ORACLE-WRITE:decimal                      (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "oracle-write")))
    (defconst GAS|WITHDRAW-ROYALTY:decimal                  (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "royalty-dispose")))
    (defconst GAS|BURN-ROYALTY:decimal                      (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "royalty-dispose")))
    (defconst GAS|FUEL-ROYALTY:decimal                      (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "royalty-fuel")))
    (defconst GAS|SET-AGENCY-FEE:decimal                    (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "set-agency-fee")))
    (defconst DSA_UPTIME_MIN:integer 0)
    ;;{3.2}  schemas
    ;;
    ;;{3.3}  tables
    (deftable DSA|T|Template:{AcquisitionSchemasV1.DSA|Template})                    ;; Key = <FVT-ID>
    (deftable DSA|T|Agency:{AcquisitionSchemasV1.DSA|Agency})                        ;; Key = <FVT-ID> | <Score-Entity-ID>
    (deftable DSA|T|OracleAuth:{AcquisitionSchemasV1.DSA|OracleAuth})                ;; Key = <FVT-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap DSA|C>DEFINE-VAULT (patron:string executor:string fvt-id:string model-id:string unit-score:integer)
        @doc "Bind a class-0 FVT as a DSA delegation vault. Enforces: the FVT exists + is class-0, patron IS the \
            \ FVT owner (+ signs), unit-score positive, no template yet. Composes SECURE for the template write. \
            \ (The model-id's validity is enforced when CC_OpenAgency calls the SCORE factory.)"
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (= (RPS.UR_FVT|FvtClass fvt-id) 0) "DSA vault must be a class-0 FVT")
            (enforce (= executor fvt-owner) "Only the FVT owner may define the delegation vault")
            (enforce (> unit-score 0) "unit-score must be positive")
            (enforce (not (URC_DsaTemplateExists fvt-id)) "This FVT is already a DSA vault")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (SECURE))
    )
    (defcap DSA|C>OPEN-AGENCY (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Authorize opening a delegation agency on an active DSA vault. Enforces the vault template exists + \
            \ active and the fee is in [DSA_FEE_MIN, DSA_FEE_MAX]. Composes P|SECURE-CALLER so DSA's registered IMC \
            \ guard + SECURE are active for the FVT admit/delegation/stake calls + the DSA|Agency write. The \
            \ one-time quintessence ≥ unit-score/2 OPEN GATE is NOT here — it is a TERMINAL enforce at the END of \
            \ CC_OpenAgency's body, AFTER the operator's initial stake (the cap runs before the body, when Q is still \
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
        (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
        (enforce (RPS.UR_FVT-SEL|Delegation fvt-id score-entity-id) "Score entity is not a delegation member")
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>SET-ORACLE-AUTH (patron:string executor:string fvt-id:string)
        @doc "Authorize the delegated oracle key for a DSA vault + arm the FVT oracle-on expiry. Owner-gated \
            \ (patron IS the FVT owner + signs). Composes P|SECURE-CALLER for the FVT XE_SetFvtOracleOn write."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= executor fvt-owner) "Only the FVT owner may set the oracle authority")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>WITHDRAW-ROYALTY (patron:string executor:string fvt-id:string)
        @doc "Owner-only: withdraw the whole royalty pool of a DSA vault to the FVT owner. Enforces the vault is a \
            \ live DSA vault + patron IS the FVT owner (+ signs). Composes P|SECURE-CALLER so DSA's registered IMC \
            \ guard is active for the FVT XE_WithdrawRoyalty custody call."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= executor fvt-owner) "Only the FVT owner may withdraw royalty")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>BURN-ROYALTY (patron:string executor:string fvt-id:string)
        @doc "Owner-only: BURN the whole royalty pool of a DSA vault. Enforces the vault is a live DSA vault + \
            \ patron IS the FVT owner (+ signs). Composes P|SECURE-CALLER so DSA's registered IMC guard is active \
            \ for the FVT XE_BurnRoyalty custody-burn call."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= executor fvt-owner) "Only the FVT owner may burn royalty")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>FUEL-ROYALTY (patron:string executor:string fvt-id:string swpair:string)
        @doc "Owner-only: FUEL a swpair with the whole royalty pool of a DSA vault (add liquidity, no LP mint). \
            \ Enforces the vault is a live DSA vault + patron IS the FVT owner (+ signs). Composes P|SECURE-CALLER \
            \ so DSA's registered IMC guard is active for the FVT XE_FuelRoyalty custody-fuel call."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= executor fvt-owner) "Only the FVT owner may fuel with royalty")
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap DSA|C>SET-AGENCY-FEE (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Owner-only: change a delegation agency's operator fee. Enforces the vault is live, patron IS the FVT \
            \ owner (+ signs), fee in [DSA_FEE_MIN, DSA_FEE_MAX]. A fee change is O(1) — it reprices only FUTURE \
            \ injects (the fee is never baked into a stored weight). Composes P|SECURE-CALLER for the FVT mirror."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (RPS.UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_DsaTemplateActive fvt-id) "DSA vault not defined or inactive")
            (enforce (= executor fvt-owner) "Only the FVT owner may change the agency fee")
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
        (enforce-guard (UR_DSA-ORA|Guard fvt-id))
        (enforce (RPS.UR_FVT-SEL|Delegation fvt-id score-entity-id) "Score entity is not a delegation member")
        (enforce (fold (and) true
            [ (>= nodes 0)
              (>= uptime DSA_UPTIME_MIN)
              (<= uptime DSA_UPTIME_FULL) ]) "Oracle values out of range (nodes >= 0, uptime 0..1000)")
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    ;; [UDC] construct
    (defun UDC_DSA|Template:object{AcquisitionSchemasV1.DSA|Template}
        (model-id:string unit-score:integer active:bool fvt-id:string)
        @doc "Core constructor for object{AcquisitionSchemasV1.DSA|Template}."
        {"model-id"            : model-id
        ,"unit-score"          : unit-score
        ,"active"              : active
        ,"fvt-id"              : fvt-id}
    )
    (defun UDC_DSA|Agency:object{AcquisitionSchemasV1.DSA|Agency}
        (operator-konto:string fee-per-mille:integer nodes:integer uptime:integer fvt-id:string score-entity-id:string)
        @doc "Core constructor for object{AcquisitionSchemasV1.DSA|Agency}."
        {"operator-konto" : operator-konto
        ,"fee-per-mille"  : fee-per-mille
        ,"nodes"          : nodes
        ,"uptime"         : uptime
        ,"fvt-id"         : fvt-id
        ,"score-entity-id": score-entity-id}
    )
    (defun UDC_DSA|OracleAuth:object{AcquisitionSchemasV1.DSA|OracleAuth}
        (oracle-guard:guard fvt-id:string)
        @doc "Core constructor for object{AcquisitionSchemasV1.DSA|OracleAuth}."
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
    (defun UR_DSA-TMP|Template:object{AcquisitionSchemasV1.DSA|Template} (fvt-id:string)
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
    (defun UR_DSA-AGN|Agency:object{AcquisitionSchemasV1.DSA|Agency} (fvt-id:string score-entity-id:string)
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
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
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
    (defun URCi_DefineDelegationVault:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_DefineDelegationVault" "issue-dsa-vault")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_OpenAgency:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg for the core admit (C_AdmitAgency); the Talos open flow additionally stakes operator collateral."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|CC_OpenAgency" "issue-dsa-agency")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_RecomputeCapture:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_RecomputeCapture" "recompute-capture")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetOracleAuth:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_SetOracleAuth" "set-oracle-auth")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_OracleWrite:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_OracleWrite" "oracle-write")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_WithdrawRoyalty:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg only; exec concats this with the custody-move IGNIS (FVT::XE_WithdrawRoyalty, state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_WithdrawRoyalty" "royalty-dispose")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_BurnRoyalty:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg only; exec concats this with the burn's IGNIS (FVT::XE_BurnRoyalty, state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_BurnRoyalty" "royalty-dispose")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_FuelRoyalty:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        @doc "GAS leg only; exec concats this with the fuel's IGNIS (FVT::XE_FuelRoyalty, state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_FuelRoyalty" "royalty-fuel")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_WithdrawRoyaltyFull:decimal (patron:string fvt-id:string reward-dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of C_WithdrawRoyalty: GAS|WITHDRAW-ROYALTY gas leg + the FVT custody-move \
            \ leg (FVT::URCi_WithdrawRoyaltyCustody mirroring XE_WithdrawRoyalty to the FVT owner). Read-only mirror \
            \ of the exec's UDC_ConcatenateOutputCumulators [gas custody]."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_WithdrawRoyalty patron [fvt-id]))
               (RPS.URCi_WithdrawRoyaltyCustody fvt-id reward-dptf-id (RPS.UR_FVT|OwnerKonto fvt-id)))
        ))
    (defun URCi_BurnRoyaltyFull:decimal (patron:string fvt-id:string reward-dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of C_BurnRoyalty: GAS|BURN-ROYALTY gas leg + the FVT custody-burn leg \
            \ (FVT::URCi_BurnRoyaltyCustody mirroring XE_BurnRoyalty). Read-only mirror of the exec's concat."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_BurnRoyalty patron [fvt-id]))
               (RPS.URCi_BurnRoyaltyCustody fvt-id reward-dptf-id))
        ))
    (defun URCi_FuelRoyaltyFull:decimal (patron:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "FULL reconstructed IGNIS ifp of C_FuelRoyalty: GAS|FUEL-ROYALTY gas leg + the FVT custody-fuel leg \
            \ (FVT::URCi_FuelRoyaltyCustody mirroring XE_FuelRoyalty into <swpair>). Read-only mirror of the exec's concat."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_FuelRoyalty patron [fvt-id]))
               (RPS.URCi_FuelRoyaltyCustody fvt-id reward-dptf-id swpair))
        ))
    (defun URCi_SetAgencyFee:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-DSA|C_SetAgencyFee" "set-agency-fee")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_OpenGate:bool (fvt-id:string score-entity-id:string)
        @doc "Terminal open gate — after the operator's initial stake, the agency quintessence must clear \
            \ unit-score/2. The Talos AQP-DSA|CC_OpenAgency flow calls this at the END of the atomic open (admit → \
            \ stake → THIS); a short operator stake fails here and rolls the whole open back. Unprotected read+enforce. \
            \ \
            \ THE HALF IS FIXED BY DESIGN — owner ruling 2026-09-19, recorded because it LOOKS like a \
            \ missing knob. Opening an agency costs exactly half of one earning unit; the module implies \
            \ that ratio everywhere and it is deliberately not configurable. A second DSA|Template field \
            \ was considered and REJECTED: flexibility is not wanted at this variable, and a settable gate \
            \ could be raised above unit-score, which would make agencies unopenable while looking valid. \
            \ So `unit-score 20000` publishes BOTH thresholds — 20000 per earning unit, 10000 to open."
        (enforce (>= (URC_AgencyQuintessence score-entity-id) (/ (dec (UR_DSA-TMP|UnitScore fvt-id)) 2.0))
            "Open gate: operator must stake quintessence >= unit-score/2 to open")
    )
    ;;{5.5}  Write [W]
    ;; [W]   write
    (defun WI_Template:string (fvt-id:string row:object{AcquisitionSchemasV1.DSA|Template})
        @doc "Insert a DSA vault template row. require SECURE."
        (require-capability (SECURE))
        (insert DSA|T|Template fvt-id row)
    )
    (defun WI_Agency:string (fvt-id:string score-entity-id:string row:object{AcquisitionSchemasV1.DSA|Agency})
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
    (defun WI_OracleAuth:string (fvt-id:string row:object{AcquisitionSchemasV1.DSA|OracleAuth})
        @doc "Write (set / rotate) a DSA vault's oracle authority row. require SECURE."
        (require-capability (SECURE))
        (write DSA|T|OracleAuth fvt-id row)
    )
    ;;{5.6}  Aux/X
    ;; [XI]
    ;;Protection: Class 2 — SECURE
    (defun XI_ApplyCapture:string (fvt-id:string score-entity-id:string oracle-ts:time)
        @doc "Recompute an agency's capture from CURRENT Q / nodes / uptime and write it onto the FVT member \
            \ (XE_SetMemberCapture), stamping the given oracle-ts. Callers hold P|SECURE-CALLER (⇒ SECURE + the \
            \ DSA IMC guard the FVT XE_ requires); a stake recompute passes the PRESERVED oracle-ts, an oracle \
            \ write passes NOW."
        (require-capability (SECURE))
        (let
            (
                (units:decimal (URC_CaptureUnits fvt-id score-entity-id))
            )
            (RPS.XE_SetMemberCapture fvt-id score-entity-id
                units (UC_CaptureWeight units (UR_DSA-AGN|Uptime fvt-id score-entity-id)) oracle-ts)
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [A]   admin
    (defun C_DefineDelegationVault:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string model-id:string unit-score:integer)
        @doc "Bind a class-0 FVT as a DSA delegation vault: record the score-entity model + unit-score (active). \
            \ Only the FVT owner may define it. P|UEV_IMC + DSA|C>DEFINE-VAULT. Bills GAS|DEFINE-VAULT. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>DEFINE-VAULT resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>DEFINE-VAULT patron executor fvt-id model-id unit-score)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WI_Template fvt-id (UDC_DSA|Template model-id unit-score true fvt-id))
                (URCi_DefineDelegationVault patron [fvt-id])
            )
        )
    )
    (defun C_SetOracleAuth:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string oracle-guard:guard)
        @doc "Owner-only: authorize the delegated oracle key for this DSA vault (DSA|OracleAuth) and ARM the FVT \
            \ oracle-on expiry, so stale oracle data (>25h) captures nothing. P|UEV_IMC + DSA|C>SET-ORACLE-AUTH. \
            \ Bills GAS|SET-ORACLE-AUTH. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>SET-ORACLE-AUTH resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>SET-ORACLE-AUTH patron executor fvt-id)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WI_OracleAuth fvt-id (UDC_DSA|OracleAuth oracle-guard fvt-id))
                (ref-FVT::XE_SetFvtOracleOn fvt-id true)
                (URCi_SetOracleAuth patron [fvt-id])
            )
        )
    )
    (defun C_OracleWrite:object{IgnisCollectorV3.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "Delegated-oracle-only: write an agency's daily {nodes, uptime}, then recompute its capture stamped \
            \ \
            \ EXECUTORLESS BY DESIGN (canon 2.2, 2026-09-22). The authority here is \
            \ (enforce-guard (UR_DSA-ORA|Guard fvt-id)) -- a GUARD, not an account. There is no \
            \ Ouronet account to bind an executor to, and inventing one would be a name nothing \
            \ checks, which 4f rates worse than none. \
            \ \
            \ The attribution exists ONE LEVEL UP and is recorded there: C_SetOracleAuth is what \
            \ registers this guard, and it takes an <executor> proven against the vault owner. \
            \ So the ledger can answer WHO AUTHORISED this oracle, which is the question that \
            \ has an account-shaped answer. \
            \ with NOW (fresh oracle-ts resets the 25h expiry). Authorized by the registered oracle guard. \
            \ P|UEV_IMC + DSA|A>ORACLE-WRITE. Bills GAS|ORACLE-WRITE."
        (P|UEV_IMC)
        (with-capability (DSA|A>ORACLE-WRITE fvt-id score-entity-id nodes uptime)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WU_Agency-Oracle fvt-id score-entity-id nodes uptime)
                (XI_ApplyCapture fvt-id score-entity-id (at "block-time" (chain-data)))
                (URCi_OracleWrite patron [score-entity-id])
            )
        )
    )
    (defun A_ToggleExternalOracle:string (patron:string executor:string on:bool)
        @doc "DSA MODULE ADMIN (GOV): flip the SINGULAR GLOBAL external-oracle switch for ALL operators at once. \
            \ OFF ⇒ external oracling is bypassed protocol-wide — every agency captures its STORED weight (oracle \
            \ entries, fresh or stale, are ignored); ON ⇒ the oracle-validity freshness gate applies (an operator \
            \ with no/stale entry captures 0). Composes P|SECURE-CALLER for the FVT global-config write. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the admin \
            \ key: GOV|DSA_ADMIN decides whether the call proceeds. The EXECUTOR is the ACTOR \
            \ among the keyholders, proven by CAP_EnforceAccountOwnership -- authority and \
            \ attribution are orthogonal and neither substitutes for the other. This switch is \
            \ SINGULAR AND GLOBAL, so the audit trail for WHICH keyholder flipped it matters \
            \ more here than for a per-entity admin op, not less. Same treatment as DEMIPAD's \
            \ four admin ops and LIQUID::A_MigrateLiquidFunds."
        (let
            (
                (ref-DALOS-X:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS-X::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (GOV|DSA_ADMIN)
            (with-capability (P|SECURE-CALLER)
                (RPS.XE_SetExternalOracle on)
            )
        )
    )
    (defun A_SetOracleValidity:string (patron:string executor:string seconds:integer)
        @doc "DSA MODULE ADMIN (GOV): set the GLOBAL oracle-validity window (seconds; the freshness horizon an \
            \ oracle write is honored for while external-oracle is ON). Must be positive. Composes P|SECURE-CALLER \
            \ for the FVT global-config write. \
            \ \
            \ ATTRIBUTION (patron/executor canon 2.2, 2026-09-22). The AUTHORITY is the admin \
            \ key: GOV|DSA_ADMIN decides whether the call proceeds. The EXECUTOR is the ACTOR \
            \ among the keyholders, proven by CAP_EnforceAccountOwnership -- authority and \
            \ attribution are orthogonal and neither substitutes for the other. This switch is \
            \ SINGULAR AND GLOBAL, so the audit trail for WHICH keyholder flipped it matters \
            \ more here than for a per-entity admin op, not less. Same treatment as DEMIPAD's \
            \ four admin ops and LIQUID::A_MigrateLiquidFunds."
        (let
            (
                (ref-DALOS-X:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS-X::CAP_EnforceAccountOwnership executor)
        )
        (enforce (> seconds 0) "oracle-validity must be positive")
        (with-capability (GOV|DSA_ADMIN)
            (with-capability (P|SECURE-CALLER)
                (RPS.XE_SetOracleValidity seconds)
            )
        )
    )
    (defun C_WithdrawRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
        @doc "Owner-only: dispose the whole royalty pool (uptime-shortfall custody) of <reward-dptf-id> on a DSA \
            \ vault by WITHDRAWING it to the FVT owner (delegates the AQP-custody move + zero to the FVT primitive \
            \ FVT::XE_WithdrawRoyalty, which holds the custody-governor authority). P|UEV_IMC + DSA|C>WITHDRAW-ROYALTY. \
            \ Bills GAS|WITHDRAW-ROYALTY merged with the custody transfer's IGNIS. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>WITHDRAW-ROYALTY resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>WITHDRAW-ROYALTY patron executor fvt-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [ (URCi_WithdrawRoyalty patron [fvt-id])
                      (RPS.XE_WithdrawRoyalty patron fvt-id reward-dptf-id (RPS.UR_FVT|OwnerKonto fvt-id)) ]
                    [fvt-id])
            )
        )
    )
    (defun C_BurnRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
        @doc "Owner-only: dispose the whole royalty pool of <reward-dptf-id> on a DSA vault by BURNING it (delegates \
            \ the AQP-custody burn + zero to FVT::XE_BurnRoyalty; AQP|SC_NAME holds the autonomic burn role). \
            \ P|UEV_IMC + DSA|C>BURN-ROYALTY. Bills GAS|BURN-ROYALTY merged with the burn's IGNIS. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>BURN-ROYALTY resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>BURN-ROYALTY patron executor fvt-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [ (URCi_BurnRoyalty patron [fvt-id])
                      (RPS.XE_BurnRoyalty patron fvt-id reward-dptf-id) ]
                    [fvt-id])
            )
        )
    )
    (defun C_FuelRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Owner-only: dispose the whole royalty pool of <reward-dptf-id> on a DSA vault by FUELING <swpair> \
            \ (add liquidity WITHOUT minting LP — delegates to FVT::XE_FuelRoyalty; the reward-dptf must be a token \
            \ of the swpair). P|UEV_IMC + DSA|C>FUEL-ROYALTY. Bills GAS|FUEL-ROYALTY merged with the fuel's IGNIS. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>FUEL-ROYALTY resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>FUEL-ROYALTY patron executor fvt-id swpair)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [ (URCi_FuelRoyalty patron [fvt-id])
                      (RPS.XE_FuelRoyalty patron fvt-id reward-dptf-id swpair) ]
                    [fvt-id])
            )
        )
    )
    (defun C_SetAgencyFee:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Owner-only: change a delegation agency's operator fee-per-mille. Updates DSA|Agency + mirrors it onto \
            \ the FVT member (FVT::XE_SetAgencyFee) so the next inject uses the new split. Safe + O(1) — the fee is \
            \ never in a stored weight, so this reprices only FUTURE injects, no per-delegator recompute. P|UEV_IMC + \
            \ DSA|C>SET-AGENCY-FEE. Bills GAS|SET-AGENCY-FEE. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- DSA|C>SET-AGENCY-FEE resolves it IN \
            \ PLACE. The capability binds (= executor fvt-owner) and separately runs \
            \ (CAP_EnforceAccountOwnership fvt-owner) on that same DERIVED account, so both \
            \ halves of HANDOFF 4g are present: the authority is proven and the actor is named \
            \ against it. The matcher looks for the enforce applied to `executor`; here it is \
            \ applied to the name `executor` was just proven equal to. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>SET-AGENCY-FEE patron executor fvt-id score-entity-id fee-per-mille)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (WU_Agency-Fee fvt-id score-entity-id fee-per-mille)
                (RPS.XE_SetAgencyFee fvt-id score-entity-id (UR_DSA-AGN|Operator fvt-id score-entity-id) fee-per-mille)
                (URCi_SetAgencyFee patron [score-entity-id])
            )
        )
    )
    ;; [C]   client
    (defun C_AdmitAgency:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "Core admit of the ATOMIC open (the Talos AQP-DSA|CC_OpenAgency flow drives the full sequence): admit \
            \ the operator's BLANK triplet as a delegation member of the class-0 vault FVT (XE_AdmitDelegationMember \
            \ — requires the sub-scores' fvt-links BAR, i.e. unstaked) + flip delegation on + record DSA|Agency. \
            \ Does NOT stake or gate: the deep DPDC custody transfer of the operator's stake needs the caller's \
            \ guard registered in DPDC-T's IMP, which is P|TS (Talos) — so the Talos flow performs the stake under \
            \ P|TS after this admit, then calls UEV_OpenGate as the terminal atomic check (a short stake reverts the \
            \ whole open). P|UEV_IMC + DSA|C>OPEN-AGENCY. Bills GAS|OPEN-AGENCY. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. DSA|C>OPEN-AGENCY validates the vault \
            \ template and the fee range; the OPERATOR's account ownership is enforced \
            \ downstream in FVT|XE>ADMIT-DELEGATION, which its own @doc already said. Stated \
            \ here too, because the canon requires the route to be written in the FUNCTION. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (DSA|C>OPEN-AGENCY patron executor fvt-id score-entity-id fee-per-mille)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (RPS.XE_AdmitDelegationMember fvt-id score-entity-id executor)
                (RPS.XE_SetMemberDelegation fvt-id score-entity-id true)
                (WI_Agency fvt-id score-entity-id (UDC_DSA|Agency executor fee-per-mille 0 DSA_UPTIME_FULL fvt-id score-entity-id))
                ;; mirror the operator + fee onto the FVT member so the inject settle can apply the fee split locally
                (RPS.XE_SetAgencyFee fvt-id score-entity-id executor fee-per-mille)
                (URCi_OpenAgency patron [score-entity-id])
            )
        )
    )
    (defun C_RecomputeCapture:object{IgnisCollectorV3.OutputCumulator}
        (patron:string fvt-id:string score-entity-id:string)
        @doc "EXECUTORLESS BY DESIGN (canon 2.2, 2026-09-22): DSA|C>RECOMPUTE-CAPTURE validates \
            \ that the template is active and the score entity is a delegation member, and \
            \ proves NO account. It recomputes a DERIVED aggregate from stored weight and the \
            \ oracle entry -- idempotent truth-restoration, paid for by the patron -- so it is \
            \ deliberately permissionless, the same disposition 03_AQP's anchor syncs and \
            \ DALOS|C_UpdateEliteAccount carry. Neither parameter is an account: <fvt-id> and \
            \ <score-entity-id> are entities, so there is no executee either. \
            \ \
            \ Permissionless: recompute an agency's capture from its CURRENT quintessence (after a delegator \
            \ stake/unstake changed Q), PRESERVING the stored oracle-ts (a stake must not refresh oracle freshness). \
            \ P|UEV_IMC + DSA|C>RECOMPUTE-CAPTURE. Bills GAS|RECOMPUTE-CAPTURE."
        (P|UEV_IMC)
        (with-capability (DSA|C>RECOMPUTE-CAPTURE patron fvt-id score-entity-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (XI_ApplyCapture fvt-id score-entity-id (RPS.UR_FVT-SEL|OracleTs fvt-id score-entity-id))
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

;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 6 of 22
;; This is STEP 6 of 23 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-5 must have run first, including the init steps between deploys.
;; 2 source file(s), 254,885 gas measured in the REPL gas model, 252,064 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact
;;
;; TOTAL: 2 interface(s), 2 module(s), 9 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact
;;      interface  SwapperV4
;;      module     SWP
;;      table      P|T
;;      table      P|MT
;;      table      SWP|Properties
;;      table      SWP|Asymmetry
;;      table      SWP|Pairs
;;      table      SWP|Pools
;;      table      SWP|LP
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact
;;      interface  SwapperIssueV4
;;      module     SWPI
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact =====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v3   ·   dev: v4   ;; bumped by the StoicSyntax refactor — deploy v4 then set net: v4
(interface SwapperV4
    @doc "Swapper forward surface for module SWP (successor to SwapperV4). \
        \ Row shapes use this interface's PoolTokens and FeeSplit schemas (field-compatible with SwapperV4). \
        \ V3: UR_StoaValue and XE_UpdateStoaValue for STOA pool ledger on SWP|Pairs."

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
    ;;
    (defschema PoolTokens
        token-id:string
        token-supply:decimal
    )
    (defschema FeeSplit
        target:string
        value:integer
    )
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
    ;;
    (defun CT_Info ())
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    (defun UC_ExtractTokens:[string] (input:[object{PoolTokens}]))
    (defun UC_ExtractTokenSupplies:[decimal] (input:[object{PoolTokens}]))
    (defun UC_CustomSpecialFeeTargets:[string] (io:[object{FeeSplit}]))
    (defun UC_CustomSpecialFeeTargetsProportions:[decimal] (io:[object{FeeSplit}]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_Asymetric:bool ())
    (defun UR_Principals:[string] ())
    (defun UR_PrimordialPool:string ())
    (defun UR_LiquidBoost:bool ())
    (defun UR_SpawnLimit:decimal ())
    (defun UR_InactiveLimit:decimal ())
        ;;
    (defun UR_OwnerKonto:string (swpair:string))
    (defun UR_CanChangeOwner:bool (swpair:string))
    (defun UR_CanAdd:bool (swpair:string))
    (defun UR_CanSwap:bool (swpair:string))
    (defun UR_GenesisWeigths:[decimal] (swpair:string))
    (defun UR_Weigths:[decimal] (swpair:string))
    (defun UR_GenesisRatio:[object{PoolTokens}] (swpair:string))
    (defun UR_PoolTokenObject:[object{PoolTokens}] (swpair:string))
    (defun UR_TokenLP:string (swpair:string))
    (defun UR_FeeLP:decimal (swpair:string))
    (defun UR_FeeSP:decimal (swpair:string))
    (defun UR_FeeSPT:[object{FeeSplit}] (swpair:string))
    (defun UR_FeeLock:bool (swpair:string))
    (defun UR_FeeUnlocks:integer (swpair:string))
    (defun UR_Amplifier:decimal (swpair:string))
    (defun UR_Primality:bool (swpair:string))
    (defun UR_IzFrozenLP:bool (swpair:string))
    (defun UR_IzSleepingLP:bool (swpair:string))
    (defun UR_StoaValue:decimal (swpair:string))
    (defun UR_Pools:[string] (pool-category:string))
        ;;
    (defun UR_PoolTokens:[string] (swpair:string))
    (defun UR_GetLpSwpair:string (lp-id:string))
    (defun UR_PoolTokenSupplies:[decimal] (swpair:string))
    (defun UR_PoolGenesisSupplies:[decimal] (swpair:string))
    (defun URv_PoolTokenPosition:integer (swpair:string id:string))
    (defun UR_PoolTokenSupply:decimal (swpair:string id:string))
    (defun UR_PoolTokenPrecisions:[integer] (swpair:string))
    (defun UR_SpecialFeeTargets:[string] (swpair:string))
    (defun UR_SpecialFeeTargetsProportions:[decimal] (swpair:string))
    ;;
    ;;#65eL: "major" principal = currently a member of the primordial pool's own
    ;;token list (always exactly OURO/WSTOA/SSTOA in practice, enforced at
    ;;A_DefinePrimordialPool's own capability gate) — fixed, never
    ;;removable/rotatable via A_UpdatePrincipal/A_RotatePrincipal. Any other
    ;;principal is "minor" and unaffected by this distinction.
    (defun URC_IsMajorPrincipal:bool (token:string))
    (defun URC_LpCapacity:decimal (swpair:string))
    (defun URC_CheckID:bool (swpair:string))
    (defun URC_PoolTotalFee:decimal (swpair:string))
    (defun URC_LiquidityFee:decimal (swpair:string))
    (defun URC_AllPoolTokens:[string] ())
    (defun URC_Swpairs:[string] ())
    (defun URC_LpComposer:[string] (pool-tokens:[object{PoolTokens}] weights:[decimal] amp:decimal))
    ;;
    (defun URH_OwnedSwapPairs:[string] (account:string))
    ;;  [URCi] cost readers — single source per op (EnableFrozen/Sleeping/ToggleAddOrSwap composers -> Phase 1.2)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string))
    (defun URCi_ChangeOwnership:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_ModifyCanChangeOwner:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_ModifyWeights:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_UpdateAmplifier:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_UpdateFee:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_UpdateSpecialFeeTargets:object{IgnisCollectorV3.OutputCumulator} (swpair:string))
    (defun URCi_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (swpair:string toggle:bool))
    (defun URCi_ToggleFeeLockStoa:decimal (swpair:string toggle:bool))
    (defun URCi_EnableFrozenLP:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string))
    (defun URCi_EnableSleepingLP:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string))
    (defun URCi_ToggleAddOrSwap:object{IgnisCollectorV3.OutputCumulator} (swpair:string toggle:bool add-or-swap:bool))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_ExecutorIsOwnerKonto (executor:string entity-id:string))
    (defun UEV_FeeSplit (input:object{FeeSplit}))
    (defun UEV_id (swpair:string))
    (defun UEV_CanChangeOwnerON (swpair:string))
    (defun UEV_FeeLockState (swpair:string state:bool))
    (defun UEV_PoolFee (fee:decimal))
    (defun UEV_New (t-ids:[string] w:[decimal] amp:decimal))
    (defun UEV_CheckTwo (token-ids:[string] w:[decimal] amp:decimal))
    (defun UEV_CheckAgainstMass:bool (token-ids:[string] present-pools:[string]))
    (defun UEV_CheckAgainst:bool (token-ids:[string] pool-tokens:[string]))
    (defun UEV_FrozenLP (swpair:string state:bool))
    (defun UEV_SleepingLP (swpair:string state:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    (defun XE_AddLPTracker (lp-id:string swpair:string))
    ;;
    (defun XB_ModifyWeights (swpair:string new-weights:[decimal]))
    ;;
    (defun XE_UpdateSupplies (swpair:string new-supplies:[decimal]))
    (defun XE_UpdateSupply (swpair:string id:string new-supply:decimal))
    (defun XE_UpdateStoaValue (swpair:string new-stoa-value:decimal))
    (defun XE_Issue:string (account:string pool-tokens:[object{PoolTokens}] token-lp:string fee-lp:decimal weights:[decimal] amp:decimal p:bool))
    (defun XE_CanAddOrSwapToggle (swpair:string toggle:bool add-or-swap:bool))
    ;;{5.7}  User [A/C]
    ;;
    ;;
    (defun A_UpdatePrincipal (principal:string add-or-remove:bool))
    (defun A_RotatePrincipal (old:string new:string))
    (defun A_UpdateLimit (limit:decimal spawn:bool))
    (defun A_UpdateLiquidBoost (new-boost-variable:bool))
    (defun A_DefinePrimordialPool (primordial-pool:string))
    (defun A_ToggleAsymetricLiquidityAddition (patron:string toggle:bool))
    ;;
    (defun C_ChangeOwnership:object{IgnisCollectorV3.OutputCumulator} (swpair:string new-owner:string))
    (defun C_EnableFrozenLP:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string))
    (defun C_EnableSleepingLP:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string))
    (defun C_ModifyCanChangeOwner:object{IgnisCollectorV3.OutputCumulator} (swpair:string new-boolean:bool))
    (defun C_ModifyWeights:object{IgnisCollectorV3.OutputCumulator} (swpair:string new-weights:[decimal]))
    (defun C_ToggleAddOrSwap:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string toggle:bool add-or-swap:bool))
    (defun C_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (patron:string swpair:string toggle:bool))
    (defun C_UpdateAmplifier:object{IgnisCollectorV3.OutputCumulator} (swpair:string amp:decimal))
    (defun C_UpdateFee:object{IgnisCollectorV3.OutputCumulator} (swpair:string new-fee:decimal lp-or-special:bool))
    (defun C_UpdateSpecialFeeTargets:object{IgnisCollectorV3.OutputCumulator} (swpair:string targets:[object{FeeSplit}]))

)
;;
(module SWP GOV
    @doc "SWP (SwapperV4) is the core swapper/liquidity-pool module holding all per-pool \
        \ state in SWP|Pairs (owner, weights, token supplies, fees, amplifier, STOA value, \
        \ flags) plus global properties (principals, primordial pool, limits) and pool/LP \
        \ indexes. It provides the pool read surface (UR_/URC_ for tokens, supplies, fees, \
        \ LP capacity, swpairs) and admin/owner client ops: change ownership, modify \
        \ weights/amplifier/fees/special-fee targets, toggle add-or-swap, enable \
        \ frozen/sleeping LP, and manage principals and the primordial pool. Serves Stable, \
        \ Weighted, and standard pool curves."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsagePrimaryV2)
    (implements SwapperV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    (defconst GOV|MD_SWP                                (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_SWP                                (keyset-ref-guard SWP|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWP_ADMIN)))
    (defcap GOV|SWP_ADMIN ()
        (enforce-one
            "SWP Swapper Admin not satisfed"
            [
                (enforce-guard GOV|MD_SWP)
                (enforce-guard GOV|SC_SWP)
            ]
        )
    )
    ;;{G5}  functions
    ;;
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|SwapKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|SwapKey)
        )
    )
    (defun GOV|SWP|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|SWP|SC_NAME)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV2.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P4}  capabilities
    (defcap P|SWP|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SWP|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|GOVERNING-CALLER ()
        (compose-capability (P|SWP|CALLER))
        (compose-capability (SWP|GOV))
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
                (mp:[guard] (P|UR_IMP))
                (g:guard (ref-U|G::UEV_GuardOfAny mp))
            )
            (enforce-guard g)
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|SWP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWP_ADMIN)
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
        (with-capability (GOV|SWP_ADMIN)
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
        (with-capability (GOV|SWP_ADMIN)
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                ;(ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|SWP|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            ;(ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst SWP|SC_KEY                                (GOV|SwapKey))
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst SWP|INFO                                  (CT_Info))
    (defconst P2 "P2")
    (defconst P3 "P3")
    (defconst P4 "P4")
    (defconst P5 "P5")
    (defconst P6 "P6")
    (defconst P7 "P7")
    (defconst S2 "S2")
    (defconst S3 "S3")
    (defconst S4 "S4")
    (defconst S5 "S5")
    (defconst S6 "S6")
    (defconst S7 "S7")
    (defconst SWP|EMPTY-TARGET
        { "target": BAR
        , "value": 1 }
    )
    ;;{3.2}  schemas
    ;;
    (defschema SWP|PropertiesSchema
        principals:[string]
        primordial-pool:string
        liquid-boost:bool
        spawn-limit:decimal
        inactive-limit:decimal
    )
    (defschema SWP|PairsSchemaV3
        @doc "Per liquidity pool. Table row key is <swpair> (see UC_PoolID in UtilitySwpV2); \
            \ stored <id> equals that key. V3 adds stoa-value for STOA ledger attribution on \
            \ the pool; legacy V2 rows omit the column until UR_StoaValue backfills 0.0."
        ;;
        ;;Management
        owner-konto:string                              ;;[M]   Pool owner konto
        can-change-owner:bool                           ;;[M]
        can-add:bool                                    ;;[M]
        can-swap:bool                                   ;;[M]
        ;;
        ;;Weights and token composition
        genesis-weights:[decimal]                       ;;[.]   Weights at issue
        weights:[decimal]                               ;;[M]   Current weights
        genesis-ratio:[object{SwapperV4.PoolTokens}]    ;;[.]   Token supplies at issue
        pool-tokens:[object{SwapperV4.PoolTokens}]      ;;[M]   Current per-token supplies
        token-lp:string                                 ;;[.]   LP DPTF id for this pool
        ;;
        ;;Fees
        fee-lp:decimal                                  ;;[M]   LP fee (promille semantics per module)
        fee-special:decimal                             ;;[M]
        fee-special-targets:[object{SwapperV4.FeeSplit}];;[M]
        fee-lock:bool                                   ;;[M]
        unlocks:integer                                 ;;[M]   Fee-target edit generation counter
        ;;
        ;;Curve / flags
        amplifier:decimal                               ;;[M]
        primality:bool                                  ;;[.]   Pool construction (primality) at issue
        frozen-lp:bool                                  ;;[.]   Once true, frozen LP path enabled
        sleeping-lp:bool                                ;;[.]   Once true, sleeping LP path enabled
        ;;
        ;;STOA (V3)
        stoa-value:decimal                              ;;[M]   STOA amount attributed to this pool; 0.0 at issue
        ;;
        ;;Select Keys
        id:string                                       ;;[.]   Pool id (= SWP|Pairs row key <swpair>)
    )
    (defschema SWP|PoolsSchema
        pools:[string]
    )
    (defschema SWP|AsymmetrySchema
        asymmetric:bool
    )
    (defschema SWP|LpTracker
        swpair:string
    )
    ;;{3.3}  tables
    (deftable SWP|Properties:{SWP|PropertiesSchema})    ;;Key = SWP|INFO
    (deftable SWP|Pairs:{SWP|PairsSchemaV3})            ;;Key = <swpair>
    (deftable SWP|Pools:{SWP|PoolsSchema})              ;;Key = <pool-category>
    (deftable SWP|Asymmetry:{SWP|AsymmetrySchema})      ;;Key = SWP|INFO
    (deftable SWP|LP:{SWP|LpTracker})                   ;;Key = <LP-string>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap SWP|GOV ()
        @doc "Governor Capability for the Swapper Smart DALOS Account"
        true
    )
    ;;UNUSED -- a leftover of a pattern SWP did not adopt. DALOS, LIQUID and OUROBOROS each pair
    ;;an X|NATIVE-AUTOMATIC cap with a GOV|X|GUARD that turns it into the smart account's guard via
    ;;<create-capability-guard>. SWP has no such guard function: it builds its account guards from
    ;;(create-capability-guard (SECURE)) and (create-capability-guard (P|SWP|CALLER)) instead, so
    ;;nothing ever reaches this cap. Left in place rather than deleted -- unlike ATS's orphan
    ;;(ATS|S>CONTROL-DIRECT-RECOVERY) it guards nothing and its removal changes no behaviour, but
    ;;it is also not evidence of a gap. Flagged 2026-09-10.
    (defcap SWP|NATIVE-AUTOMATIC ()
        @doc "Autonomic management of <stoa-konto> of SWAPPER Smart Account"
        true
    )
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap SWP|S>RT_OWN (swpair:string new-owner:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (current-owner:string (UR_OwnerKonto swpair))
                (current-special-targets:integer (length (UR_FeeSPT swpair)))
                (major:integer (ref-DALOS::UR_Elite-Tier-Major new-owner))
                (max-new-owner:integer
                    (cond
                        ((= major 2) 2)
                        ((= major 3) 3)
                        ((= major 4) 4)
                        ((fold (or) true [(= major 5)(= major 6)(= major 7)]) 7)
                        1
                    )
                )
            )
            (enforce 
                (>= max-new-owner current-special-targets) 
                (format "Insufficient Major Elite Tier for NewOwner to support CurrentOwner \
                        \existing SpecialFeeTargets of {}" [current-special-targets])
            )
            (ref-DALOS::UEV_SenderWithReceiver (UR_OwnerKonto swpair) new-owner)
            (ref-DALOS::UEV_EnforceAccountExists new-owner)
            (UEV_CanChangeOwnerON swpair)
            (CAP_Owner swpair)
        )
    )
    (defcap SWP|S>RT_CAN-CHANGE (swpair:string new-boolean:bool)
        @event
        (let
            (
                (current:bool (UR_CanChangeOwner swpair))
            )
            (enforce (!= current new-boolean) "Similar boolean unallowed for <can-change-owner>")
            (CAP_Owner swpair)
        )
    )
    (defcap SWP|S>WEIGHTS (swpair:string new-weights:[decimal])
        @event
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (pp:string (take 1 swpair))
                (ws:decimal (fold (+) 0.0 new-weights))
                (fee-precision:integer (ref-U|CT::CT_FEE_PRECISION))
                (l0:integer (length (UR_PoolTokens swpair)))
                (l1:integer (length new-weights))
            )
            ;;C7 fix: length-parity, mirroring the sibling SWP|S>UPDATE-SUPPLIES cap.
            (ref-U|INT::UEV_UniformList [l0 l1])
            ;;C7 fix: real per-weight enforce inside the map lambda (the original code computed this exact
            ;;check via `=` and threw the result away — matching UEV_UniformList's working idiom, not the
            ;;original dead-map one). Combines the precision check with a >= 0.1 floor per weight (also
            ;;rules out negative weights) into a single `enforce` per element.
            (map
                (lambda
                    (w:decimal)
                    (enforce
                        (fold (and) true [(= (floor w fee-precision) w) (>= w 0.1)])
                        (format "Weight {} must respect fee precision and be at least 0.1" [w])
                    )
                )
                new-weights
            )
            (enforce (= pp "W") "Changing weights available only for weighted Pools")
            (enforce (= ws 1.0) "All weights must add to exactly 1.0")
            (CAP_Owner swpair)
        )
    )
    (defcap SWP|S>UPDATE-SUPPLIES (swpair:string new-supplies:[decimal])
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (pool-tokens:[string] (UR_PoolTokens swpair))
                (l0:integer (length pool-tokens))
                (l1:integer (length new-supplies))
                (lengths:[integer] [l0 l1])
            )
            (UEV_id swpair)
            (ref-U|INT::UEV_UniformList lengths)
            ;;H12 fix: the old code only validated a new supply when it was already > 0.0, silently
            ;;skipping any check at all for <= 0.0 (letting a negative supply persist unenforced). Added
            ;;an unconditional non-negativity enforce inside the lambda, real-guard-style (matches the
            ;;C7/UEV_UniformList idiom), on top of the pre-existing positive-value precision check.
            (map
                (lambda
                    (idx:integer)
                    (let
                        (
                            (val:decimal (at idx new-supplies))
                        )
                        (enforce
                            (>= val 0.0)
                            (format "New supply {} for pool token {} cannot be negative" [val (at idx pool-tokens)])
                        )
                        (if (> val 0.0)
                            (ref-DPTF::UEV_Amount (at idx pool-tokens) val)
                            true
                        )
                    )
                )
                (enumerate 0 (- l0 1))
            )
        )
    )
    (defcap SWP|S>UPDATE-SUPPLY (swpair:string id:string new-supply:decimal)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::UEV_Amount id new-supply)
            (UEV_id swpair)
        )
    )
    (defcap SWP|S>UPDATE-FEE (swpair:string new-fee:decimal )
        @event
        (UEV_FeeLockState swpair false)
        (UEV_PoolFee new-fee)
        (CAP_Owner swpair)
    )
    (defcap SWP|S>UPDATE-AMPLIFIER (swpair:string new-amplifier:decimal)
        @event
        (CAP_Owner swpair)
        (let
            (
                (current-amp:decimal (UR_Amplifier swpair))
            )
            (enforce (> current-amp 0.0) "Amplifier can only be updated for Stable Pools")
            ;;C8 fix: <new-amplifier> was never validated at all — no bound, and critically no exclusion
            ;;of the module's own -1.0 "not a stable pool" sentinel. Mirrors UEV_Issue's own >= 1.0 floor
            ;;at creation (16_SWPI.pact:1267); ceiling of 2000.0 is evidence-backed, not arbitrary — REPL-
            ;;verified: round-trip convergence on a skewed pool stays excellent (~1e-13) through the low
            ;;hundreds, then measurably degrades (~1e-7 by A=5000+) because the Newton solver's fixed
            ;;11-iteration limit (H1, separately tracked, still open) stops fully converging at high A on
            ;;skewed reserves. 2000.0 covers realistic real-world stable-pool ranges with margin to spare
            ;;below that degradation. A single range check also excludes -1.0/0.0/negatives with no
            ;;separate sentinel check needed.
            (enforce
                (and (>= new-amplifier 1.0) (<= new-amplifier 2000.0))
                (format "Amplifier {} must be between 1.0 and 2000.0" [new-amplifier])
            )
        )
    )
    (defcap SPW|S>UPDATE_SPECIAL-FEE-TARGETS (swpair:string targets:[object{SwapperV4.FeeSplit}])
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (target-no:integer (length targets))
                (owner:string (UR_OwnerKonto swpair))
                (major:integer (ref-DALOS::UR_Elite-Tier-Major owner))
                (max:integer
                    (cond
                        ((= major 2) 2)
                        ((= major 3) 3)
                        ((= major 4) 4)
                        ((fold (or) true [(= major 5)(= major 6)(= major 7)]) 7)
                        1
                    )
                )
            )
            (enforce (and (>= target-no 1) (<= target-no max)) "Increase Major Elite Tier to add more Special Targets")
            (CAP_Owner swpair)
            (map
                (lambda
                    (obj:object{SwapperV4.FeeSplit})
                    (UEV_FeeSplit obj)
                )
                targets
            )
        )
    )
    (defcap SWP|C>ADD-OR-SWAP (swpair:string toggle:bool add-or-swap:bool)
        @event
        (let
            (
                (add:bool (UR_CanAdd swpair))
                (swap:bool (UR_CanSwap swpair))
            )
            (if add-or-swap
                (enforce (!= add toggle) "Similar boolean unallowed for <can-add> or <can-swap>")
                (enforce (!= swap toggle) "Similar boolean unallowed for <can-add> or <can-swap>")
            )
            (CAP_Owner swpair)
        )
    )
    ;;{C3}  Composed
    ;;
    ;;
    (defcap AHU ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ah:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
            )
            (ref-DALOS::CAP_EnforceAccountOwnership ah)
            (compose-capability (SECURE))
        )
    )
    ;{C3}
    ;{C4}
    (defcap SWP|C>UPDATE-BRD (swpair:string)
        @event
        (CAP_Owner swpair)
        (compose-capability (P|SWP|CALLER))
    )
    (defcap SWP|C>UPGRADE-BRD (swpair:string)
        @event
        (CAP_Owner swpair)
        (compose-capability (P|SWP|CALLER))
    )
    (defcap SWP|C>PRINCIPAL (principal:string add-or-remove:bool)
        @doc "Adds are capped at 7 total and must not duplicate an existing \
            \ principal. Removes must leave at least 2 principals defined — SWPT's \
            \ storage is principal-agnostic (#21H), so removal itself is safe; the \
            \ floor exists so issuance-time principal-anchoring validation \
            \ (SWPI::UEV_Issue) always has somewhere real to anchor a new W/P pool. \
            \ #65eL: removal also rejects a 'major' principal (currently a member \
            \ of the primordial pool — URC_IsMajorPrincipal) outright, regardless \
            \ of the floor — major principals are fixed, retirable only by \
            \ redefining the primordial pool itself (SWP|C>DEFINE-PRIMORDIAL-POOL), \
            \ never by this function. A 'minor' principal is unaffected. Gated by \
            \ the same GOV|SWP_ADMIN admin capability as SWP|C>ROTATE-PRINCIPAL."
        @event
        (compose-capability (GOV|SWP_ADMIN))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (current:[string] (UR_Principals))
                (current-count:integer (if (= current [BAR]) 0 (length current)))
            )
            (ref-DPTF::UEV_id principal)
            (if add-or-remove
                (and
                    (enforce (not (contains principal current)) (format "{} is already a principal" [principal]))
                    (enforce (< current-count 7) (format "Cannot add principal — {} of 7 maximum already defined" [current-count]))
                )
                (and
                    (enforce (contains principal current) (format "{} is not currently a principal" [principal]))
                    (and
                        (enforce (> current-count 2) (format "Cannot remove principal — at least 2 must remain defined ({} currently)" [current-count]))
                        (enforce (not (URC_IsMajorPrincipal principal)) (format "{} is a major (primordial-pool) principal — cannot be removed" [principal]))
                    )
                )
            )
        )
    )
    (defcap SWP|C>ROTATE-PRINCIPAL (old:string new:string)
        @doc "Validates an atomic principal replacement. Each rejection reason gets \
            \ its own distinct enforce, not a combined boolean, since they're \
            \ separate concerns with separate causes: <old> must currently be a \
            \ principal, <old> must not be a 'major' (primordial-pool) principal \
            \ (#65eL — majors are fixed, retirable only by redefining the \
            \ primordial pool itself, never by rotation), <new> must not already \
            \ be one, and rotating a principal into itself is never allowed \
            \ regardless of whether it's already a principal (it always would be, \
            \ since <old> = <new>). Count-preserving — never interacts with the \
            \ 7-principal cap. Gated by the same GOV|SWP_ADMIN admin capability as \
            \ SWP|C>PRINCIPAL."
        @event
        (compose-capability (GOV|SWP_ADMIN))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (current:[string] (UR_Principals))
            )
            (ref-DPTF::UEV_id new)
            (ref-U|LST::UEV_StringPresence old current)
            (enforce (not (URC_IsMajorPrincipal old)) (format "{} is a major (primordial-pool) principal — cannot be rotated" [old]))
            (enforce (!= old new) "Cannot rotate a principal into itself")
            (enforce (not (contains new current)) (format "{} is already a principal" [new]))
        )
    )
    (defcap SWP|C>LQBOOST (new-boost-variable:bool)
        @event
        (compose-capability (GOV|SWP_ADMIN))
        (let
            (
                (lqb:bool (UR_LiquidBoost))
            )
            (enforce (!= new-boost-variable lqb) (format "Liquid Boost already set to {}" [new-boost-variable]))
        )
    )
    (defcap SWP|C>LIMIT ()
        @event
        (compose-capability (GOV|SWP_ADMIN))
    )
    (defcap SWP|C>TG_FEE-LOCK (swpair:string toggle:bool)
        @event
        (UEV_FeeLockState swpair (not toggle))
        (CAP_Owner swpair)
        (compose-capability (SECURE))
    )
    (defcap SWP|C>ENABLE-FROZEN (swpair:string)
        @event
        ;;#31M/M7 fix: was missing CAP_Owner — any caller routed through
        ;;P|GOVERNING-CALLER could permanently enable Frozen LP on any pool,
        ;;not just their own. Only the pool's own owner may trigger this
        ;;(and it's irreversible by design — no XI ever writes it back to
        ;;false).
        (UEV_FrozenLP swpair false)
        (CAP_Owner swpair)
        (compose-capability (P|GOVERNING-CALLER))
    )
    (defcap SWP|C>ENABLE-SLEEPING (swpair:string)
        @event
        ;;#31M/M7 fix: same as SWP|C>ENABLE-FROZEN above — owner-only,
        ;;irreversible.
        (UEV_SleepingLP swpair false)
        (CAP_Owner swpair)
        (compose-capability (P|GOVERNING-CALLER))
    )
    (defcap SWP|C>DEFINE-PRIMORDIAL-POOL (primordial-pool:string)
        (compose-capability (GOV|SWP_ADMIN))
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (primality:bool (UR_Primality primordial-pool))
                (pt:[string] (UR_PoolTokens primordial-pool))
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (pool-type:string (ref-U|SWP::UC_PoolType primordial-pool))
                (iz-weigthed:bool (= pool-type "W"))
                (has-ouro:bool (contains ouro pt))
                (has-wstoa:bool (contains wstoa pt))
                (has-sstoa:bool (contains sstoa pt))
                (iz-three:bool (= (length pt) 3))
            )
            ;;H6 fix: <primality> was bound above but never included in this fold, so the only checks
            ;;actually enforced were the 5 composable "does it look like the right shape" conditions —
            ;;the issuance-time eligibility flag that's supposed to gate this (owner: also means exempt
            ;;from low-liquidity gates / never autonomously disabled) was read and silently unused.
            (enforce (fold (and) true [iz-weigthed has-ouro has-wstoa has-sstoa iz-three primality]) "Pool is not the primordial pool")
        )
    )
    (defcap SWP|C>TG-ASYMETRIC-LQ (toggle:bool)
        (compose-capability (GOV|SWP_ADMIN))
        (let
            (
                (pp:string (UR_PrimordialPool))
            )
            (enforce (!= pp BAR) "PrimordialPool must be set for this operation")
            (UEV_AsymetricState (not toggle))
            (compose-capability (P|SWP|CALLER))
        )
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
    (defun CT_Info ()                                   (at 0 ["SwapperInformation"]))
    ;;{5.2}  Compute [UC]
    (defun UC_ExtractTokens:[string] (input:[object{SwapperV4.PoolTokens}])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] item:object{SwapperV4.PoolTokens})
                    (ref-U|LST::UC_AppL acc (at "token-id" item))
                )
                []
                input
            )
        )
    )
    (defun UC_ExtractTokenSupplies:[decimal] (input:[object{SwapperV4.PoolTokens}])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] item:object{SwapperV4.PoolTokens})
                    (ref-U|LST::UC_AppL acc (at "token-supply" item))
                )
                []
                input
            )
        )
    )
    (defun UC_CustomSpecialFeeTargets:[string] (io:[object{SwapperV4.FeeSplit}])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (at "target" (at idx io))
                    )
                )
                []
                (enumerate 0 (- (length io) 1))
            )
        )
    )
    (defun UC_CustomSpecialFeeTargetsProportions:[decimal] (io:[object{SwapperV4.FeeSplit}])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (dec (at "value" (at idx io)))
                    )
                )
                []
                (enumerate 0 (- (length io) 1))
            )
        )
    )
    (defun UCv_PoolTokenPosition:integer (swpair:string id:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (iz-on-pool:bool (contains id pool-tokens))
            )
            (enforce iz-on-pool (format "Token {} is not part of the Pool String {}" [id swpair]))
            (at 0 (ref-U|LST::UC_Search pool-tokens id))
        )
    )
    (defun UC_PoolTokenPrecisions:[integer] (swpair:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (l:integer (length pool-tokens))
                (Xp:[integer]
                    (fold
                        (lambda
                            (acc:[integer] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (ref-DPTF::UR_Decimals (at idx pool-tokens))
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            Xp
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_Asymetric:bool ()
        (at "asymmetric" (read SWP|Asymmetry SWP|INFO ["asymmetric"]))
    )
    (defun UR_Principals:[string] ()
        (at "principals" (read SWP|Properties SWP|INFO ["principals"]))
    )
    (defun UR_PrimordialPool:string ()
        (at "primordial-pool" (read SWP|Properties SWP|INFO ["primordial-pool"]))
    )
    (defun UR_LiquidBoost:bool ()
        (at "liquid-boost" (read SWP|Properties SWP|INFO ["liquid-boost"]))
    )
    (defun UR_SpawnLimit:decimal ()
        (at "spawn-limit" (read SWP|Properties SWP|INFO ["spawn-limit"]))
    )
    (defun UR_InactiveLimit:decimal ()
        (at "inactive-limit" (read SWP|Properties SWP|INFO ["inactive-limit"]))
    )
    ;;
    (defun UR_OwnerKonto:string (swpair:string)
        (at "owner-konto" (read SWP|Pairs swpair ["owner-konto"]))
    )
    (defun UR_CanChangeOwner:bool (swpair:string)
        (at "can-change-owner" (read SWP|Pairs swpair ["can-change-owner"]))
    )
    (defun UR_CanAdd:bool (swpair:string)
        (at "can-add" (read SWP|Pairs swpair ["can-add"]))
    )
    (defun UR_CanSwap:bool (swpair:string)
        (at "can-swap" (read SWP|Pairs swpair ["can-swap"]))
    )
    (defun UR_GenesisWeigths:[decimal] (swpair:string)
        (at "genesis-weights" (read SWP|Pairs swpair ["genesis-weights"]))
    )
    (defun UR_Weigths:[decimal] (swpair:string)
        (at "weights" (read SWP|Pairs swpair ["weights"]))
    )
    (defun UR_GenesisRatio:[object{SwapperV4.PoolTokens}] (swpair:string)
        (at "genesis-ratio" (read SWP|Pairs swpair ["genesis-ratio"]))
    )
    (defun UR_PoolTokenObject:[object{SwapperV4.PoolTokens}] (swpair:string)
        (at "pool-tokens" (read SWP|Pairs swpair ["pool-tokens"]))
    )
    (defun UR_TokenLP:string (swpair:string)
        (at "token-lp" (read SWP|Pairs swpair ["token-lp"]))
    )
    (defun UR_FeeLP:decimal (swpair:string)
        (at "fee-lp" (read SWP|Pairs swpair ["fee-lp"]))
    )
    (defun UR_FeeSP:decimal (swpair:string)
        (at "fee-special" (read SWP|Pairs swpair ["fee-special"]))
    )
    (defun UR_FeeSPT:[object{SwapperV4.FeeSplit}] (swpair:string)
        (at "fee-special-targets" (read SWP|Pairs swpair ["fee-special-targets"]))
    )
    (defun UR_FeeLock:bool (swpair:string)
        (at "fee-lock" (read SWP|Pairs swpair ["fee-lock"]))
    )
    (defun UR_FeeUnlocks:integer (swpair:string)
        (at "unlocks" (read SWP|Pairs swpair ["unlocks"]))
    )
    (defun UR_Amplifier:decimal (swpair:string)
        (at "amplifier" (read SWP|Pairs swpair ["amplifier"]))
    )
    (defun UR_Primality:bool (swpair:string)
        (at "primality" (read SWP|Pairs swpair ["primality"]))
    )
    (defun UR_IzFrozenLP:bool (swpair:string)
        (at "frozen-lp" (read SWP|Pairs swpair ["frozen-lp"]))
    )
    (defun UR_IzSleepingLP:bool (swpair:string)
        (at "sleeping-lp" (read SWP|Pairs swpair ["sleeping-lp"]))
    )
    (defun UR_StoaValue:decimal (swpair:string)
        @doc "STOA pool ledger scalar. Same row existence semantics as other UR_* on SWP|Pairs: \
            \ <read SWP|Pairs swpair …> fails if <swpair> is not a pool. Legacy V2 rows without \
            \ stoa-value (narrow read returns {}) return 0.0 directly, computed fresh on every \
            \ read — never persisted here. \
            \ #50L fix: this used to backfill 0.0 into storage on first read as a migration \
            \ artifact/optimization — a real ungated write as a side effect of a nominal UR_* \
            \ read, at the caller's own gas expense. Confirmed safe to drop: traced every read \
            \ of \"stoa-value\" anywhere in the codebase (including cross-module, AQP's FVT) — \
            \ this function is the only one that ever reads the field directly, so nothing \
            \ depends on it being physically present in storage. A real price update \
            \ (<XE_UpdateStoaValue>) still writes the genuine value whenever one actually \
            \ occurs; genesis pools already seed the field from day one, so this only ever \
            \ applied to pre-V3 legacy rows anyway."
        (let
            (
                (temp (read SWP|Pairs swpair ["stoa-value"]))
            )
            (if (= temp {}) 0.0 (at "stoa-value" temp))
        )
    )
    (defun UR_Pools:[string] (pool-category:string)
        (at "pools" (read SWP|Pools pool-category ["pools"]))
    )
    (defun UR_PoolTokens:[string] (swpair:string)
        (UC_ExtractTokens (UR_PoolTokenObject swpair))
    )
    (defun UR_PoolTokenSupplies:[decimal] (swpair:string)
        (UC_ExtractTokenSupplies (UR_PoolTokenObject swpair))
    )
    (defun UR_PoolGenesisSupplies:[decimal] (swpair:string)
        (UC_ExtractTokenSupplies (UR_GenesisRatio swpair))
    )
    (defun URv_PoolTokenPosition:integer (swpair:string id:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (pool-tokens:[string] (UR_PoolTokens swpair))
                (iz-on-pool:bool (contains id pool-tokens))
            )
            (enforce iz-on-pool (format "Token {} is not part of Pool {}" [id swpair]))
            (at 0 (ref-U|LST::UC_Search pool-tokens id))
        )
    )
    (defun UR_PoolTokenSupply:decimal (swpair:string id:string)
        (at (URv_PoolTokenPosition swpair id) (UR_PoolTokenSupplies swpair))
    )
    (defun UR_PoolTokenPrecisions:[integer] (swpair:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (pool-tokens:[string] (UR_PoolTokens swpair))
                (l:integer (length pool-tokens))
                (Xp:[integer]
                    (fold
                        (lambda
                            (acc:[integer] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (ref-DPTF::UR_Decimals (at idx pool-tokens))
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            Xp
        )
    )
    (defun UR_SpecialFeeTargets:[string] (swpair:string)
        (UC_CustomSpecialFeeTargets (UR_FeeSPT swpair))
    )
    (defun UR_SpecialFeeTargetsProportions:[decimal] (swpair:string)
        (UC_CustomSpecialFeeTargetsProportions (UR_FeeSPT swpair))
    )
    (defun UR_GetLpSwpair:string (lp-id:string)
        (at "swpair" (read SWP|LP lp-id ["swpair"]))
    )
    (defun URC_IsMajorPrincipal:bool (token:string)
        @doc "True if <token> is currently a member of the primordial pool's own \
            \ token list — the 'major principal' concept: fixed, always exactly \
            \ OURO/WSTOA/SSTOA in practice (A_DefinePrimordialPool's own capability \
            \ gate enforces exactly these 3 tokens, always, regardless of which \
            \ physical pool backs it), never removable or rotatable-away via \
            \ A_UpdatePrincipal/A_RotatePrincipal — as opposed to any other \
            \ ('minor') principal, which both freely allow. Returns false (never \
            \ major) if no primordial pool has been defined yet, or if <token> \
            \ isn't currently a member of the one that has been — this doesn't \
            \ require <token> to already be a registered principal at all, callers \
            \ combine that check separately where it matters."
        (let
            (
                (pp:string (UR_PrimordialPool))
            )
            (if (= pp BAR)
                false
                (contains token (UR_PoolTokens pp))
            )
        )
    )
    (defun URC_LpCapacity:decimal (swpair:string)
        @doc "Computes the LP Capacity of a Given Swap Pair"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::UR_Supply (UR_TokenLP swpair))
        )
    )
    (defun URC_CheckID:bool (swpair:string)
        (with-default-read SWP|Pairs swpair
            { "unlocks" : -1 }
            { "unlocks" := u }
            (if (< u 0)
                false
                true
            )
        )
    )
    (defun URC_PoolTotalFee:decimal (swpair:string)
        @doc "Computes Total Pool Fee in Promille"
        (let
            (
                (lb:bool (UR_LiquidBoost))
                (current-fee-lp:decimal (UR_FeeLP swpair))
                (current-fee-special:decimal (UR_FeeSP swpair))
                (tf1:decimal (+ current-fee-lp current-fee-special))
                (tf2:decimal (+ (* current-fee-lp 2.0) current-fee-special))
            )
            (if lb
                tf2
                tf1
            )
        )
    )
    (defun URC_LiquidityFee:decimal (swpair:string)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (n:decimal (dec (length (UR_PoolTokens swpair))))
                (swap-fee:decimal (URC_PoolTotalFee swpair))
            )
            (floor (/ (* n swap-fee) (* 4.0 (- n 1.0))) (ref-U|CT::CT_FEE_PRECISION))
        )
    )
    (defun URC_AllPoolTokens:[string] ()
        @doc "Outputs all unique tokens existing across all Swap Pools"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_UniqueTokens (URC_Swpairs))
        )
    )
    (defun URC_Swpairs:[string] ()
        @doc "Outputs all current Existing Swpairs. Cheaper than <keys SWP|Pairs>"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (pl:[string] [P2 P3 P4 P5 P6 P7 S2 S3 S4 S5 S6 S7])
                (fl:[[string]]
                    (fold
                        (lambda
                            (acc:[[string]] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (UR_Pools (at idx pl))
                            )
                        )
                        []
                        (enumerate 0 (- (length pl) 1))
                    )
                )
            )
            (fold (+) [] (ref-U|LST::UC_RemoveItem fl [BAR]))
        )
    )
    (defun URC_ActiveSwpairs:[string] ()
        @doc "Outputs all current Existing Swpairs where <can-swap> = true. Used by \
            \ routing (<SWPI::URC_Hopper>) so a disabled pool never enters the BFS \
            \ graph as a hop candidate in the first place, instead of being picked \
            \ by BFS and only rejected afterwards deep inside \
            \ <SPWU|X>SMART-SWAP> with no fallback. Audit ref: #19H."
        (filter (lambda (swpair:string) (UR_CanSwap swpair)) (URC_Swpairs))
    )
    (defun URC_LpComposer:[string] (pool-tokens:[object{SwapperV4.PoolTokens}] weights:[decimal] amp:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (pool-token-ids:[string] (UC_ExtractTokens pool-tokens))
                (l:integer (length pool-token-ids))
                (pool-token-names:[string]
                    (fold
                        (lambda
                            (acc:[string] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (ref-DPTF::UR_Name (at idx pool-token-ids))
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
                (pool-token-tickers:[string]
                    (fold
                        (lambda
                            (acc:[string] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (ref-DPTF::UR_Ticker (at idx pool-token-ids))
                            )
                        )
                        []
                        (enumerate 0 (- l 1))
                    )
                )
            )
            (ref-U|SWP::UC_LpID pool-token-names pool-token-tickers weights amp)
        )
    )
    ;;
    ;;  [URD]
    ;;
    ;;1]Returns a List of SWPPairs that are owned by a given Account for Management Purposes
    (defun URH_OwnedSwapPairs:[string] (account:string)
        @doc "Returns all SWPPairs that can be managed by the given <account>"
        (map (at "id")
            (select SWP|Pairs ["id"]
                (where "owner-konto" (= account))
            )
        )
    )
    ;;
    ;;[URCi] cost readers — single cost source per op. Enable*/ToggleAddOrSwap composers -> Phase 1.2.
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_BrandingCumulator (UR_OwnerKonto entity-id) 4.0)
        )
    )
    (defun URCi_ChangeOwnership:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_ChangeOwnership" "auth")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ModifyCanChangeOwner:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_ModifyCanChangeOwner" "auth")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ModifyWeights:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_ModifyWeights" "fee")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateAmplifier:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_UpdateAmplifier" "fee")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateFee:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_UpdateFee" "fee")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_UpdateSpecialFeeTargets:object{IgnisCollectorV3.OutputCumulator} (swpair:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "SWP|C_UpdateSpecialFeeTargets" "fee")
                (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (swpair:string toggle:bool)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (unlock-costs:[decimal] (if toggle [0.0 0.0] (ref-IGNIS::UC_FeeUnlockPrice)))
                (gas-costs:decimal (+ (ref-IGNIS::UC_IgnisLeg "tier-small") (at 0 unlock-costs)))
                (output:bool (> (at 1 unlock-costs) 0.0))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [output])
        )
    )
    (defun URCi_ToggleFeeLockStoa:decimal (swpair:string toggle:bool)
        @doc "STOA leg of a fee-lock toggle: locking is free, unlocking costs the fee-unlock \
            \ price. Read-only twin of the <XI_ToggleFeeLock> return that <C_ToggleFeeLock> \
            \ hands to <XE_CollectStoa>, so the INFO_ preview and the charge move as one. \
            \ Mirrors DPTF's <URCi_ToggleFeeLockStoa>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if toggle 0.0 (at 1 (ref-IGNIS::UC_FeeUnlockPrice)))
        )
    )
    (defun URCi_UpgradeBranding:decimal (months:integer)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (ref-BRD::URCi_UpgradeBranding months)
        )
    )
    (defun URCi_EnableFrozenLP:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string)
        @doc "Cost preview for C_EnableFrozenLP: if no frozen link exists yet, the VST \
            \ create-frozen-link cost; otherwise the medium IGNIS price on the pool owner \
            \ (output == existing link). Re-derived purely (XI_EnableFrozenLP is a free write)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-VST:module{VestingV2} VST)
                (lp-id:string (UR_TokenLP swpair))
                (current-frozen-link:string (ref-DPTF::UR_Frozen lp-id))
            )
            (if (= current-frozen-link BAR)
                (ref-VST::URCi_CreateSpecialTrueFungibleLink lp-id)
                (ref-IGNIS::UDC_ConstructOutputCumulator
                    (ref-IGNIS::UC_IgnisLeg "tier-medium")
                    (UR_OwnerKonto swpair)
                    (ref-IGNIS::URC_IsVirtualGasZero)
                    [current-frozen-link]
                )
            )
        )
    )
    (defun URCi_EnableSleepingLP:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string)
        @doc "Cost preview for C_EnableSleepingLP: if no sleeping link exists yet, the VST \
            \ create-sleeping-link (vzh-tag 2) cost; otherwise the medium IGNIS price on the \
            \ pool owner (output == existing link). Re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-VST:module{VestingV2} VST)
                (lp-id:string (UR_TokenLP swpair))
                (current-sleeping-link:string (ref-DPTF::UR_Sleeping lp-id))
            )
            (if (= current-sleeping-link BAR)
                (ref-VST::URCi_CreateSpecialOrtoFungibleLink lp-id 2)
                (ref-IGNIS::UDC_ConstructOutputCumulator
                    (ref-IGNIS::UC_IgnisLeg "tier-medium")
                    (UR_OwnerKonto swpair)
                    (ref-IGNIS::URC_IsVirtualGasZero)
                    [current-sleeping-link]
                )
            )
        )
    )
    (defun URCi_ToggleAddOrSwap:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string toggle:bool add-or-swap:bool)
        @doc "Cost preview for C_ToggleAddOrSwap: the base 5x-biggest IGNIS price (ico0) plus, \
            \ when enabling add-liquidity (toggle), the one-time LP burn/mint + per-pool-token \
            \ fee-exemption role bootstrap that only bills for roles not already set (ico1). \
            \ Role costs use DPTF's own toggle-role cumulators; XE_CanAddOrSwapToggle is a free \
            \ write. Re-derived purely from the live role states."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (biggest:decimal (ref-IGNIS::UC_IgnisLeg "tier-biggest"))
                (price:decimal (* 5.0 biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ico0:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price (UR_OwnerKonto swpair) trigger [])
                )
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (if toggle
                        (let
                            (
                                (pt-ids:[string] (UR_PoolTokens swpair))
                                (amp:decimal (UR_Amplifier swpair))
                                (ptts:[string]
                                    (if (= amp -1.0)
                                        (drop 1 pt-ids)
                                        pt-ids
                                    )
                                )
                                (lp-id:string (UR_TokenLP swpair))
                                (lp-burn-role:bool (ref-DPTF::UR_AccountRoleBurn lp-id SWP|SC_NAME))
                                (lp-mint-role:bool (ref-DPTF::UR_AccountRoleMint lp-id SWP|SC_NAME))
                                (ico2:object{IgnisCollectorV3.OutputCumulator}
                                    (if (not lp-burn-role)
                                        (ref-DPTF::URCi_ToggleBurnRole lp-id)
                                        EOC
                                    )
                                )
                                (ico3:object{IgnisCollectorV3.OutputCumulator}
                                    (if (not lp-mint-role)
                                        (ref-DPTF::URCi_ToggleMintRole lp-id)
                                        EOC
                                    )
                                )
                                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                                    (fold
                                        (lambda
                                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                            (ref-U|LST::UC_AppL
                                                acc
                                                (if (not (ref-DPTF::UR_AccountRoleFeeExemption (at idx ptts) SWP|SC_NAME))
                                                    (ref-DPTF::URCi_ToggleFeeExemptionRole (at idx ptts))
                                                    EOC
                                                )
                                            )
                                        )
                                        []
                                        (enumerate 0 (- (length ptts) 1))
                                    )
                                )
                                (ico4:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                                )
                            )
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico2 ico3 ico4] [])
                        )
                        EOC
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_FeeSplit (input:object{SwapperV4.FeeSplit})
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (tg:string (at "target" input))
                (v:integer (at "value" input))
            )
            (ref-DALOS::UEV_EnforceAccountExists tg)
            (enforce (and (>= v 1)(<= v 100000)) "Invalid Splitting Value in Split Object")
        )
    )
    (defun UEV_id (swpair:string)
        (with-default-read SWP|Pairs swpair
            { "unlocks" : -1 }
            { "unlocks" := u }
            (enforce
                (>= u 0)
                (format "SWP-Pair {} does not exist." [swpair])
            )
        )
    )
    (defun UEV_CanChangeOwnerON (swpair:string)
        (UEV_id swpair)
        (let
            (
                (x:bool (UR_CanChangeOwner swpair))
            )
            (enforce (= x true) (format "SWP Pair {} ownership cannot be changed" [swpair]))
        )
    )
    (defun UEV_AsymetricState (state:bool)
        (let
            (
                (x:bool (UR_Asymetric))
            )
            (enforce (= x state) (format "Asymetric Liquidity must be set to {} for this operation" [state]))
        )
    )
    (defun UEV_FeeLockState (swpair:string state:bool)
        (let
            (
                (x:bool (UR_FeeLock swpair))
            )
            (enforce (= x state) (format "Fee-lock for SWP Pair {} must be set to {} for this operation" [swpair state]))
        )
    )
    (defun UEV_PoolFee (fee:decimal)
        @doc "Enforces <fee> is a valid pool fee amount. \
            \ #53L fix: units are per-mille (parts per 1000) — the actual swap math \
            \ (16_SWPI.pact's <fselp>/<ofs>) treats 1000.0 as the full-fee basis, so \
            \ e.g. fee=10.0 means 1%. The 320.0 max (32%) is deliberate, not arbitrary: \
            \ this same bound gates all three fee components a pool can carry — LP fee, \
            \ special-target fee, and liquid-boost fee — mirrored to the identical cap, \
            \ so their combined worst case is 320.0*3 = 960 promille, always leaving at \
            \ least 40 promille (4%) of every swap that fees can never fully consume."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (fee-prec:integer (ref-U|CT::CT_FEE_PRECISION))
            )
            (enforce
                (= (floor fee fee-prec) fee)
                (format "SWP Pool Fee amount of {} is invalid decimal wise" [fee])
            )
            (enforce (and (>= fee 0.0001) (<= fee 320.0)) (format "SWP Pool Fee amount of {} is invalid size wise" [fee]))
        )
    )
    (defun UEV_New (t-ids:[string] w:[decimal] amp:decimal)
        (let
            (
                (n:integer (length t-ids))
                (SP3:[string] (if (= amp -1.0) (UR_Pools P3) (UR_Pools S3)))
                (SP4:[string] (if (= amp -1.0) (UR_Pools P4) (UR_Pools S4)))
                (SP5:[string] (if (= amp -1.0) (UR_Pools P5) (UR_Pools S5)))
                (SP6:[string] (if (= amp -1.0) (UR_Pools P6) (UR_Pools S6)))
                (SP7:[string] (if (= amp -1.0) (UR_Pools P7) (UR_Pools S7)))
                (msg:string "Pool already exists for given Tokens!")
            )
            (cond
                ((= n 2) (UEV_CheckTwo t-ids w amp))
                ((= n 3) (enforce (not (UEV_CheckAgainstMass t-ids SP3)) msg))
                ((= n 4) (enforce (not (UEV_CheckAgainstMass t-ids SP4)) msg))
                ((= n 5) (enforce (not (UEV_CheckAgainstMass t-ids SP5)) msg))
                ((= n 6) (enforce (not (UEV_CheckAgainstMass t-ids SP6)) msg))
                ((= n 7) (enforce (not (UEV_CheckAgainstMass t-ids SP7)) msg))
                true
            )
        )
    )
    (defun UEV_CheckTwo (token-ids:[string] w:[decimal] amp:decimal)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (e0:string (at 0 token-ids))
                (e1:string (at 1 token-ids))
                (swp1:string (ref-U|SWP::UC_PoolID token-ids w amp))
                (swp2:string (ref-U|SWP::UC_PoolID [e1 e0] w amp))
                (t1:bool (URC_CheckID swp1))
                (t2:bool (URC_CheckID swp2))
            )
            (enforce (not t1) (format "Pair {} must not exist" [swp1]))
            (enforce (not t2) (format "Pair {} must not exist" [swp2]))
        )
    )
    (defun UEV_CheckAgainstMass:bool (token-ids:[string] present-pools:[string])
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (fold
                (lambda
                    (acc:bool idx:integer)
                    (or
                        acc
                        (UEV_CheckAgainst token-ids (ref-U|SWP::UC_TokensFromSwpairString (at idx present-pools)))
                    )
                )
                false
                (enumerate 0 (- (length present-pools) 1))
            )
        )
    )
    (defun UEV_CheckAgainst:bool (token-ids:[string] pool-tokens:[string])
        (fold
            (lambda
                (acc:bool idx:integer)
                (and acc (contains (at idx token-ids) pool-tokens))
            )
            true
            (enumerate 0 (- (length token-ids) 1))
        )
    )
    (defun UEV_FrozenLP (swpair:string state:bool)
        (let
            (
                (frozen-lp:bool (UR_IzFrozenLP swpair))
            )
            (enforce (= state frozen-lp) (format "Swpair {} must have its Frozen-LP set to {} for this operation" [swpair state]))
        )
    )
    (defun UEV_SleepingLP (swpair:string state:bool)
        (let
            (
                (sleeping-lp:bool (UR_IzSleepingLP swpair))
            )
            (enforce (= state sleeping-lp) (format "Swpair {} must have its Sleeping-LP set to {} for this operation" [swpair state]))
        )
    )
    (defun CAP_Owner (swpair:string)
        @doc "Enforces SWPair Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_OwnerKonto swpair))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          SWP|S>WEIGHTS
    (defun XB_ModifyWeights (swpair:string new-weights:[decimal])
        (P|UEV_IMC)
        (with-capability (SWP|S>WEIGHTS swpair new-weights)
            (update SWP|Pairs swpair
                {"weights"  : new-weights}
            )
        )
    )
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          SWP|S>UPDATE-SUPPLIES
    (defun XE_UpdateSupplies (swpair:string new-supplies:[decimal])
        (P|UEV_IMC)
        (with-capability (SWP|S>UPDATE-SUPPLIES swpair new-supplies)
            (let
                (
                    (pool-tokens:[string] (UR_PoolTokens swpair))
                    (new-pool-tokens:[object{SwapperV4.PoolTokens}]
                        (zip (lambda (x:string y:decimal) { "token-id": x, "token-supply": y }) pool-tokens new-supplies)
                    )
                )
                (update SWP|Pairs swpair
                    {"pool-tokens" : new-pool-tokens}
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateSupply (swpair:string id:string new-supply:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (current-pool-tokens:[object{SwapperV4.PoolTokens}] (UR_PoolTokenObject swpair))
                (id-pos:integer (URv_PoolTokenPosition swpair id))
                (new:object{SwapperV4.PoolTokens} { "token-id" : id, "token-supply" : new-supply})
                (new-pool-tokens:[object{SwapperV4.PoolTokens}] (ref-U|LST::UC_ReplaceAt current-pool-tokens id-pos new))
            )
            (with-capability (SWP|S>UPDATE-SUPPLY swpair id new-supply)
                (update SWP|Pairs swpair
                    {"pool-tokens" : new-pool-tokens}
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateStoaValue (swpair:string new-stoa-value:decimal)
        @doc "Forward writer: sets stoa-value on SWP|Pairs. Requires P|UEV_IMC; pool row must exist (UEV_id)."
        (P|UEV_IMC)
        (update SWP|Pairs swpair
            {"stoa-value" : new-stoa-value}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_Issue:string (account:string pool-tokens:[object{SwapperV4.PoolTokens}] token-lp:string fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "Forward writer: inserts the new SWP|Pairs row, registers the LP tracker \
            \ (C9 fix), saves the pool, and deploys token accounts. \
            \ #52L fix (R4): returns the newly-constructed <swpair> ID — callers \
            \ (e.g. SWPI::C_Issue, MTX-SWP::MTX|C_Issue) need it back to finish \
            \ building their own response/continue the issuance flow."
        (P|UEV_IMC)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (n:integer (length pool-tokens))
                (what:bool (if (= amp -1.0) true false))
                (pool-token-ids:[string] (UC_ExtractTokens pool-tokens))
                (swpair:string (ref-U|SWP::UC_PoolID pool-token-ids weights amp))
                (ptte:[string]
                    (if (= amp -1.0)
                        (drop 1 pool-token-ids)
                        pool-token-ids
                    )
                )
            )
            (insert SWP|Pairs swpair
                {"id"                   : swpair
                ,"owner-konto"          : account
                ,"can-change-owner"     : true
                ,"can-add"              : false
                ,"can-swap"             : false

                ,"genesis-weights"      : weights
                ,"weights"              : weights
                ,"genesis-ratio"        : pool-tokens
                ,"pool-tokens"          : pool-tokens
                ,"token-lp"             : token-lp

                ,"fee-lp"               : fee-lp
                ,"fee-special"          : 0.0
                ,"fee-special-targets"  : [SWP|EMPTY-TARGET]
                ,"fee-lock"             : false
                ,"unlocks"              : 0

                ,"amplifier"            : amp
                ,"primality"            : p
                ,"frozen-lp"            : false
                ,"sleeping-lp"          : false
                ,"stoa-value"           : 0.0
                }
            )
            ;;C9 fix: SWP|LP must be populated by EVERY issuance path. Folded here (both <token-lp> and
            ;;<swpair> are already in scope) instead of leaving it a standalone call each caller must
            ;;remember — 16_SWPI.pact::C_Issue did remember; 20_MTX-SWP.pact::MTX|C_Issue (the defpact
            ;;path, which also calls XE_Issue) never did, so every pool issued through it had an LP token
            ;;that could never be resolved back to its swpair (UR_GetLpSwpair hard-aborts on the missing
            ;;row), permanently blocking AQP LP-stake admission for that pool.
            (XE_AddLPTracker token-lp swpair)
            (with-capability (P|SECURE-CALLER)
                (XI_SavePool n what swpair)
                (ref-DPTF::XBv_DeployAccount token-lp account)
                (map
                    (lambda
                        (id:string)
                        (ref-DPTF::XBv_DeployAccount id SWP|SC_NAME)
                    )
                    ptte
                )
                swpair
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_CanAddOrSwapToggle (swpair:string toggle:bool add-or-swap:bool)
        @doc "#55L fix: removed a redundant second guard check that used to sit here — \
            \ it re-ran UEV_Any against [local-guard] + (P|UR_IMP), the exact same list \
            \ P|UEV_IMC (above) already checked, plus one extra local guard. Since P|UEV_IMC \
            \ is a bare statement (not wrapped in try) and aborts the whole tx on \
            \ failure, reaching this point already proves (P|UR_IMP) alone contains a \
            \ passing guard — adding local-guard to an already-guaranteed-passing OR-set \
            \ can never change the outcome. Pure dead weight, safely removed."
        (P|UEV_IMC)
        (if add-or-swap
            (update SWP|Pairs swpair
                {"can-add"                      : toggle}
            )
            (update SWP|Pairs swpair
                {"can-swap"                     : toggle}
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_AddLPTracker (lp-id:string swpair:string)
        (P|UEV_IMC)
        (insert SWP|LP lp-id
            {"swpair"                           : swpair}
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: SWP|S>RT_OWN
    (defun XI_ChangeOwnership (swpair:string new-owner:string)
        (require-capability (SWP|S>RT_OWN swpair new-owner))
        (update SWP|Pairs swpair
            {"owner-konto"                      : new-owner}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IncrementFeeUnlocks (swpair:string)
        (require-capability (SECURE))
        (with-read SWP|Pairs swpair
            { "unlocks" := u }
            (update SWP|Pairs swpair
                {"unlocks" : (+ u 1)}
            )
        )
    )
    ;;Protection: Class 3 — Custom: SWP|S>RT_CAN-CHANGE
    (defun XI_ModifyCanChangeOwner (swpair:string new-boolean:bool)
        (require-capability (SWP|S>RT_CAN-CHANGE swpair new-boolean))
        (update SWP|Pairs swpair
            {"can-change-owner"                 : new-boolean}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_SavePool (n:integer what:bool swpair:string)
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (vars
                    (cond
                        ((= n 2) (if what [(UR_Pools P2) P2] [(UR_Pools S2) S2]))
                        ((= n 3) (if what [(UR_Pools P3) P3] [(UR_Pools S3) S3]))
                        ((= n 4) (if what [(UR_Pools P4) P4] [(UR_Pools S4) S4]))
                        ((= n 5) (if what [(UR_Pools P5) P5] [(UR_Pools S5) S5]))
                        ((= n 6) (if what [(UR_Pools P6) P6] [(UR_Pools S6) S6]))
                        ((= n 7) (if what [(UR_Pools P7) P7] [(UR_Pools S7) S7]))
                        true
                    )
                )
                (sp-n:[string] (at 0 vars))
                (SPN:string (at 1 vars))
            )
            (if (= sp-n [BAR])
                (update SWP|Pools SPN
                    {"pools" : [swpair]}
                )
                (update SWP|Pools SPN
                    {"pools" : (ref-U|LST::UC_AppL sp-n swpair)}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: SWP|C>TG_FEE-LOCK
    (defun XI_ToggleFeeLock:[decimal] (swpair:string toggle:bool)
        @doc "Writes the new fee-lock state. \
            \ #52L fix (R4): returns [virtual-gas-cost(IGNIS) native-gas-cost(STOA)] — \
            \ [0.0 0.0] when locking (toggle=true, free); the unlock price when unlocking \
            \ (toggle=false). The caller (C_ToggleFeeLock) bills this back to the patron. \
            \ NOT scaled by <UR_FeeUnlocks>: the escalating ladder was retired 2026-09-06 for \
            \ a FLAT IGNIS::UC_FeeUnlockPrice, and this doc described the dead model."
        (require-capability (SWP|C>TG_FEE-LOCK swpair toggle))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (update SWP|Pairs swpair
                { "fee-lock" : toggle}
            )
            (if (= toggle true)
                [0.0 0.0]
                (ref-IGNIS::UC_FeeUnlockPrice)
            )
        )
    )
    ;;Protection: Class 3 — Custom: SWP|S>UPDATE-AMPLIFIER
    (defun XI_UpdateAmplifier (swpair:string new-amplifier:decimal)
        (with-capability (SWP|S>UPDATE-AMPLIFIER swpair new-amplifier)
            (update SWP|Pairs swpair
                {"amplifier" : new-amplifier}
            )
        )
    )
    ;;Protection: Class 3 — Custom: SWP|S>UPDATE-FEE
    (defun XI_UpdateFee (swpair:string new-fee:decimal lp-or-special:bool)
        (require-capability (SWP|S>UPDATE-FEE swpair new-fee))
        (if lp-or-special
            (update SWP|Pairs swpair
                {"fee-lp"                         : new-fee}
            )
            (update SWP|Pairs swpair
                {"fee-special"                    : new-fee}
            )
        )
    )
    ;;Protection: Class 3 — Custom: SPW|S>UPDATE_SPECIAL-FEE-TARGETS
    (defun XI_UpdateSpecialFeeTargets (swpair:string targets:[object{SwapperV4.FeeSplit}])
        (require-capability (SPW|S>UPDATE_SPECIAL-FEE-TARGETS swpair targets))
        (update SWP|Pairs swpair
            {"fee-special-targets"                : targets}
        )
    )
    ;;Protection: Class 3 — Custom: SWP|C>ENABLE-FROZEN
    (defun XI_EnableFrozenLP (swpair:string)
        (require-capability (SWP|C>ENABLE-FROZEN swpair))
        (update SWP|Pairs swpair
            {"frozen-lp"    : true}
        )
    )
    ;;Protection: Class 3 — Custom: SWP|C>ENABLE-SLEEPING
    (defun XI_EnableSleepingLP (swpair:string)
        (require-capability (SWP|C>ENABLE-SLEEPING swpair))
        (update SWP|Pairs swpair
            {"sleeping-lp"    : true}
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_UpdatePrincipal (principal:string add-or-remove:bool)
        @doc "Adds <principal> (while under the 7 maximum) or removes it (while at \
            \ least 2 would remain defined, AND <principal> isn't currently a \
            \ 'major' principal — #65eL, URC_IsMajorPrincipal). SWPT's storage is \
            \ principal-agnostic (#21H), so removal of a minor principal is safe \
            \ — it only affects future SWPI::UEV_Issue principal-anchoring \
            \ validation, never existing routing. Major principals (currently a \
            \ member of the primordial pool — always OURO/WSTOA/SSTOA in practice) are \
            \ never removable here regardless of the floor; retiring one requires \
            \ redefining the primordial pool itself (SWP|A_DefinePrimordialPool). \
            \ A_RotatePrincipal remains available as an atomic, count-preserving \
            \ alternative for minor principals — it never touches the floor or \
            \ cap, but is equally blocked from rotating a major principal away."
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (with-read SWP|Properties SWP|INFO
                { "principals" := pp }
                (with-capability (SWP|C>PRINCIPAL principal add-or-remove)
                    (if add-or-remove
                        (if (= pp [BAR])
                            (update SWP|Properties SWP|INFO
                                {"principals" : [principal]}
                            )
                            (update SWP|Properties SWP|INFO
                                {"principals" : (ref-U|LST::UC_AppL pp principal)}
                            )
                        )
                        (let
                            (
                                (pp-position:integer (at 0 (ref-U|LST::UC_Search pp principal)))
                            )
                            (update SWP|Properties SWP|INFO
                                {"principals" : (ref-U|LST::UC_RemoveItem pp (at pp-position pp))}
                            )
                        )
                    )
                )
            )
        )
    )
    (defun A_RotatePrincipal (old:string new:string)
        @doc "Atomically replaces principal <old> with <new> in one call — the \
            \ count-preserving alternative to a separate remove-then-add via \
            \ A_UpdatePrincipal (Fix #14/#21H second follow-up re-allowed standalone \
            \ removal, floor-gated at 2 remaining; this doc previously claimed \
            \ removal was disabled entirely, stale since that fix — #65dL). Never \
            \ interacts with the 7-principal cap either way. Safe with respect to \
            \ SWPT's routing graph (#21H fix) — SWPT's storage is principal-agnostic, \
            \ so rotating (or removing) a MINOR principal never orphans anything \
            \ there; the only effect is on future SWPI::UEV_Issue principal- \
            \ anchoring validation. <old> being a 'major' principal (currently a \
            \ member of the primordial pool — always OURO/WSTOA/SSTOA in practice) is \
            \ rejected outright regardless of everything else (#65eL, \
            \ URC_IsMajorPrincipal) — majors are fixed, retirable only by \
            \ redefining the primordial pool itself (SWP|A_DefinePrimordialPool)."
        (P|UEV_IMC)
        (with-read SWP|Properties SWP|INFO
            { "principals" := pp }
            (with-capability (SWP|C>ROTATE-PRINCIPAL old new)
                (let
                    (
                        (ref-U|LST:module{StringProcessorV2} U|LST)
                        (pos:integer (at 0 (ref-U|LST::UC_Search pp old)))
                    )
                    (update SWP|Properties SWP|INFO
                        {"principals" : (ref-U|LST::UC_ReplaceAt pp pos new)}
                    )
                )
            )
        )
    )
    (defun A_UpdateLimit (limit:decimal spawn:bool)
        (P|UEV_IMC)
        (with-capability (SWP|C>LIMIT)
            (if spawn
                (update SWP|Properties SWP|INFO
                    {"spawn-limit" : limit}
                )
                (update SWP|Properties SWP|INFO
                    {"inactive-limit" : limit}
                )
            )
        )
    )
    (defun A_UpdateLiquidBoost (new-boost-variable:bool)
        (P|UEV_IMC)
        (with-capability (SWP|C>LQBOOST new-boost-variable)
            (update SWP|Properties SWP|INFO
                {"liquid-boost" : new-boost-variable}
            )
        )
    )
    (defun A_DefinePrimordialPool (primordial-pool:string)
        (P|UEV_IMC)
        (with-capability (SWP|C>DEFINE-PRIMORDIAL-POOL primordial-pool)
            (update SWP|Properties SWP|INFO
                {"primordial-pool" : primordial-pool}
            )
        )
    )
    (defun A_ToggleAsymetricLiquidityAddition (patron:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SWP|C>TG-ASYMETRIC-LQ toggle)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    ;;
                    (ignis-id:string (ref-DALOS::UR_IgnisID))
                    (ouro-id:string (ref-DALOS::UR_OuroborosID))
                    (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                    ;;
                    (ignis-burn-role:bool (ref-DPTF::UR_AccountRoleBurn ignis-id SWP|SC_NAME))
                    (ouro-mint-role:bool (ref-DPTF::UR_AccountRoleMint ouro-id SWP|SC_NAME))
                    (ignis-fee-exemption-role:bool (ref-DPTF::UR_AccountRoleFeeExemption ignis-id SWP|SC_NAME))
                    (ignis-fee-exemption-roleV2:bool (ref-DPTF::UR_AccountRoleFeeExemption ignis-id vst-sc))
                )
                (if (not ignis-burn-role)
                    (ref-DPTF::C_ToggleBurnRole patron (ref-DPTF::UR_Konto ignis-id) SWP|SC_NAME ignis-id true)
                    true
                )
                (if (not ouro-mint-role)
                    (ref-DPTF::C_ToggleMintRole patron (ref-DPTF::UR_Konto ouro-id) SWP|SC_NAME ouro-id true)
                    true
                )
                (if (not ignis-fee-exemption-role)
                    (ref-DPTF::C_ToggleFeeExemptionRole patron (ref-DPTF::UR_Konto ignis-id) SWP|SC_NAME ignis-id true)
                    true
                )
                (if (not ignis-fee-exemption-role)
                    (ref-DPTF::C_ToggleFeeExemptionRole patron (ref-DPTF::UR_Konto ignis-id) vst-sc ignis-id true)
                    true
                )
                (update SWP|Asymmetry SWP|INFO
                    {"asymmetric" : toggle}
                )
            )
        )
    )
    (defun UEV_ExecutorIsOwnerKonto (executor:string entity-id:string)
        @doc "BINDS <executor> to <entity-id>'s owner. Ownership is proven INDIRECTLY by the \
            \ branding capability; this supplies the other half -- that the account the caller \
            \ NAMED is that owner. (patron/executor canon 2.2, indirect route named.)"
        (enforce (= executor (UR_OwnerKonto entity-id)) "Executor is not the Entity Owner")
    )
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <entity-id>'s pending branding. <executor> is bound to the entity OWNER; \
            \ ownership itself is proven by SWP|C>UPDATE-BRD. The binding is what keeps the \
            \ parameter from being a name nobody reads."
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor entity-id)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (with-capability (SWP|C>UPDATE-BRD entity-id)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (URCi_UpdatePendingBranding entity-id)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        (P|UEV_IMC)
        (UEV_ExecutorIsOwnerKonto executor entity-id)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
            )
            ;;Perform the branding upgrade (side effect); bill the STOA via the URCi (== XE_UpgradeBranding's price)
            (with-capability (SWP|C>UPGRADE-BRD entity-id)
                (ref-BRD::XE_UpgradeBranding entity-id executor months)
            )
            (ref-IGNIS::XB_CollectStoaWithTrigger patron (URCi_UpgradeBranding months) false)
        )
    )
    ;;
    (defun C_ChangeOwnership:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string new-owner:string)
        (P|UEV_IMC)
        (with-capability (SWP|S>RT_OWN swpair new-owner)
            (XI_ChangeOwnership swpair new-owner)
            (URCi_ChangeOwnership swpair)
        )
    )
    (defun C_EnableFrozenLP:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string)
        (P|UEV_IMC)
        (with-capability (SWP|C>ENABLE-FROZEN swpair)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-VST:module{VestingV2} VST)
                    (lp-id:string (UR_TokenLP swpair))
                    (current-frozen-link:string (ref-DPTF::UR_Frozen lp-id))
                )
                (XI_EnableFrozenLP swpair)
                (if (= current-frozen-link BAR)
                    (ref-VST::C_CreateFrozenLink patron lp-id)    
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisLeg "tier-medium")
                        (UR_OwnerKonto swpair)
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        [current-frozen-link]
                    )
                )
            )
        )
    )
    (defun C_EnableSleepingLP:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string)
        (P|UEV_IMC)
        (with-capability (SWP|C>ENABLE-SLEEPING swpair)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-VST:module{VestingV2} VST)
                    (lp-id:string (UR_TokenLP swpair))
                    (current-sleeping-link:string (ref-DPTF::UR_Sleeping lp-id))
                )
                (XI_EnableSleepingLP swpair)
                (if (= current-sleeping-link BAR)
                    (ref-VST::C_CreateSleepingLink patron lp-id)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisLeg "tier-medium")
                        (UR_OwnerKonto swpair)
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        [current-sleeping-link]
                    )
                )
            )
        )
    )
    (defun C_ModifyCanChangeOwner:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string new-boolean:bool)
        (P|UEV_IMC)
        (with-capability (SWP|S>RT_CAN-CHANGE swpair new-boolean)
            (XI_ModifyCanChangeOwner swpair new-boolean)
            (URCi_ModifyCanChangeOwner swpair)
        )
    )
    (defun C_ModifyWeights:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string new-weights:[decimal])
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XB_ModifyWeights swpair new-weights)
            (URCi_ModifyWeights swpair)
        )
    )
    (defun C_ToggleAddOrSwap:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string toggle:bool add-or-swap:bool)
        @doc "#71L: called directly (cross-module C_->C_) by SWPU::C_ToggleSwapCapability and \
            \ SWPLC::C_ToggleAddLiquidity, instead of through an XE_* forward entrypoint — \
            \ intentional, DESIGN-accepted, not an oversight. This function is not a plain \
            \ toggle write: it bills real IGNIS (ico0), bootstraps LP burn/mint/fee-exemption \
            \ roles the first time add-liquidity is enabled (ico1-ico4), and — critically — is \
            \ the ONLY place in this call chain that enforces pool ownership, via \
            \ SWP|C>ADD-OR-SWAP's composed CAP_Owner. The existing XE_CanAddOrSwapToggle does \
            \ none of that (only P|UEV_IMC + a raw update, no ownership check) and would need to \
            \ replicate all of the above to be a safe drop-in replacement for either caller — \
            \ neither SWPU::SPWU|C>TOGGLE-SWAP nor SWPLC::P|SWPLC|CALLER re-derives ownership \
            \ independently, so rerouting through the bare XE_* today would silently strip \
            \ authorization. Left as-is; a properly-capped XE_* replacement is real design work, \
            \ not a mechanical rename — deferred, not attempted here."
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (biggest:decimal (ref-IGNIS::UC_IgnisLeg "tier-biggest"))
                (price:decimal (* 5.0 biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ico0:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price (UR_OwnerKonto swpair) trigger [])
                )
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (with-capability (P|GOVERNING-CALLER)
                        (if toggle
                            (let
                                (
                                    (pt-ids:[string] (UR_PoolTokens swpair))
                                    (amp:decimal (UR_Amplifier swpair))
                                    (ptts:[string]
                                        (if (= amp -1.0)
                                            (drop 1 pt-ids)
                                            pt-ids
                                        )
                                    )
                                    (lp-id:string (UR_TokenLP swpair))
                                    (lp-burn-role:bool (ref-DPTF::UR_AccountRoleBurn lp-id SWP|SC_NAME))
                                    (lp-mint-role:bool (ref-DPTF::UR_AccountRoleMint lp-id SWP|SC_NAME))
                                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                                        (if (not lp-burn-role)
                                            (ref-DPTF::C_ToggleBurnRole patron (ref-DPTF::UR_Konto lp-id) SWP|SC_NAME lp-id true)
                                            EOC
                                        )
                                    )
                                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                                        (if (not lp-mint-role)
                                            (ref-DPTF::C_ToggleMintRole patron (ref-DPTF::UR_Konto lp-id) SWP|SC_NAME lp-id true)
                                            EOC
                                        )
                                    )
                                    (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                                        (fold
                                            (lambda
                                                (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                                (ref-U|LST::UC_AppL
                                                    acc
                                                    (if (not (ref-DPTF::UR_AccountRoleFeeExemption (at idx ptts) SWP|SC_NAME))
                                                        (ref-DPTF::C_ToggleFeeExemptionRole patron (ref-DPTF::UR_Konto (at idx ptts)) SWP|SC_NAME (at idx ptts) true)
                                                        EOC
                                                    )
                                                )
                                            )
                                            []
                                            (enumerate 0 (- (length ptts) 1))
                                        )
                                    )
                                    (ico4:object{IgnisCollectorV3.OutputCumulator}
                                        (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                                    )
                                )
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico2 ico3 ico4] [])
                            )
                            EOC
                        )
                    )
                )
            )
            (with-capability (SWP|C>ADD-OR-SWAP swpair toggle add-or-swap)
                (XE_CanAddOrSwapToggle swpair toggle add-or-swap)
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [])
        )
    )
    (defun C_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator}
        (patron:string swpair:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (SWP|C>TG_FEE-LOCK swpair toggle)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (toggle-costs:[decimal] (XI_ToggleFeeLock swpair toggle))
                    (stoa-costs:decimal (at 1 toggle-costs))
                    ;;URCi computed HERE — reads fee-unlocks BEFORE XI_IncrementFeeUnlocks below mutates it
                    (cumulator:object{IgnisCollectorV3.OutputCumulator} (URCi_ToggleFeeLock swpair toggle))
                )
                (if (> stoa-costs 0.0)
                    (do
                        (XI_IncrementFeeUnlocks swpair)
                        (ref-IGNIS::XE_CollectStoa patron stoa-costs)
                    )
                    true
                )
                cumulator
            )
        )
    )
    (defun C_UpdateAmplifier:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string amp:decimal)
        (P|UEV_IMC)
        (with-capability (SWP|S>UPDATE-AMPLIFIER swpair amp)
            (XI_UpdateAmplifier swpair amp)
            (URCi_UpdateAmplifier swpair)
        )
    )
    (defun C_UpdateFee:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string new-fee:decimal lp-or-special:bool)
        (P|UEV_IMC)
        (with-capability (SWP|S>UPDATE-FEE swpair new-fee)
            (XI_UpdateFee swpair new-fee lp-or-special)
            (URCi_UpdateFee swpair)
        )
    )
    (defun C_UpdateSpecialFeeTargets:object{IgnisCollectorV3.OutputCumulator}
        (swpair:string targets:[object{SwapperV4.FeeSplit}])
        (P|UEV_IMC)
        (with-capability (SPW|S>UPDATE_SPECIAL-FEE-TARGETS swpair targets)
            (XI_UpdateSpecialFeeTargets swpair targets)
            (URCi_UpdateSpecialFeeTargets swpair)
        )
    )
    (defun AU_SwapPairs (ids:[string])
        @doc "Get <ids> with <(keys SWP|Pairs)>, or update one a time"
        (with-capability (AHU)
            (map (AU_SwapPair) ids)
        )
    )
    (defun AU_SwapPair (id:string)
        (require-capability (SECURE))
        (update SWP|Pairs id
            {"id"       : id}
        )
    )

)

;; --- tables for 15_SWP.pact (7 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table SWP|Properties)
;; (create-table SWP|Asymmetry)
;; (create-table SWP|Pairs)
;; (create-table SWP|Pools)
;; (create-table SWP|LP)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/16_SWPI.pact ====================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v3   ·   dev: v4   ;; bumped by the StoicSyntax refactor — deploy v4 then set net: v4
(interface SwapperIssueV4
    @doc "Exposes SWP Issuing Functions. \
        \ Also contains Swap Computation Functions, and the Hopper Function. \
        \ V3: UEV_Issue and C_Issue use SwapperV4.PoolTokens (bumped when Swapper row types moved to SwapperV4)."

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
    ;;
    ;;
    ;;  SCHEMAS
    ;;
    (defschema Hopper
        nodes:[string]
        edges:[string]
        output-values:[decimal]    
    )
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
    ;;
    ;;
    ;;  [UDC] Functions
    ;;
    (defun UDC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput} 
        (dsid:object{UtilitySwpV2.DirectSwapInputData} A:decimal X:[decimal] input-positions:[integer] output-position:integer weights:[decimal])
    )
    (defun UDC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput} 
        (rsid:object{UtilitySwpV2.ReverseSwapInputData} A:decimal X:[decimal] output-position:integer input-position:integer weights:[decimal])
    )
    (defun UDC_Hopper:object{Hopper} (a:[string] b:[string] c:[decimal]))
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun UCv_DeviationInValueShares:decimal (pool-reserves:[decimal] asymmetric-liq:[decimal] w:[decimal]))
    (defun UC_DeviatedShares:[decimal] (pool-reserves:[decimal] pool-shares:[decimal] new-total-shares:decimal))
    (defun UC_PoolShares:[decimal] (pool-reserves:[decimal] w:[decimal]))
    (defun UC_VirtualSwap:object{UtilitySwpV2.VirtualSwapEngine} 
        (vse:object{UtilitySwpV2.VirtualSwapEngine} dsid:object{UtilitySwpV2.DirectSwapInputData})
    )
    (defun UC_BareboneSwapWithFeez:object{UtilitySwpV2.DirectTaxedSwapOutput}
        (
            account:string pool-type:string 
            dsid:object{UtilitySwpV2.DirectSwapInputData} fees:object{UtilitySwpV2.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] input-positions:[integer] output-position:integer weights:[decimal]
        )
    )
    (defun UC_InverseBareboneSwapWithFeez:object{UtilitySwpV2.InverseTaxedSwapOutput}
        (
            account:string pool-type:string 
            rsid:object{UtilitySwpV2.ReverseSwapInputData} fees:object{UtilitySwpV2.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] output-position:integer input-position:integer weights:[decimal]
        )
    )
    (defun UCv_BareboneSwap:decimal (pool-type:string drsi:object{UtilitySwpV2.DirectRawSwapInput}))
    (defun UC_BareboneInverseSwap:decimal (pool-type:string irsi:object{UtilitySwpV2.InverseRawSwapInput}))
    (defun UCv_PoolTokenPositions:[integer] (swpair:string input-ids:[string]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;  [URC] Functions
    ;;
    (defun URC_EliteFeeReduction:object{UtilitySwpV2.SwapFeez} (account:string fees:object{UtilitySwpV2.SwapFeez}))
    (defun URCv_PoolTokenPositions:[integer] (swpair:string input-ids:[string]))
    (defun URC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput} (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}))
    (defun URC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput} (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData}))
        ;;
    (defun URCv_Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} validation:bool))
    (defun URC_S-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}))
    (defun URC_W-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}))
    (defun URC_P-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}))
        ;;
    (defun URC_InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData} validation:bool))
    (defun URC_S-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData}))
    (defun URC_W-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData}))
    (defun URC_P-InverseSwap (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData}))
        ;;
    (defun URC_Hopper:object{Hopper} (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal))
    (defun URC_HopperActive:object{Hopper} (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal))
    (defun URC_HopperActiveShortest:object{Hopper} (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal))
    ;;#65bL Phase 4: URC_Hopper, sourcing its graph from an ALREADY-FETCHED <raw-graph>
    ;;(SWPT::URC_FetchRawGraph) instead of URCx_Hopper's own self-fetch — lets a caller
    ;;doing MULTIPLE unrelated Hopper queries in the same transaction (e.g. the
    ;;topology's raw graph exactly ONCE and reuse it across every query, instead of
    ;;each query independently re-reading and rebuilding it.
    (defun URC_HopperFromRaw:object{Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal raw-graph:[object{SwapTracerV3.RawGraphNode}])
    )
    ;;#65bL Phase 7: URC_HopperFromRaw again, but sourcing its graph from an
    ;;from <raw-graph> on every call — the STOA-repricing loop's own
    ;;graph structure once per distinct pool touched; this lets that shared build
    ;;happen once and be reused, same shape of win one layer deeper than Phase 4's
    ;;raw-graph sharing.
    (defun URC_HopperFromGraph:object{Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            graph:[object{BreadthFirstSearchV2.GraphNode}]
        )
    )
    ;;#34 Phase 11 — the original #34 ask: genuine exhaustive route discovery. Mirrors
    ;;calls SWPT::URC_ComputeAllRoutes instead of the K=3-capped
    ;;an off-chain caller can choose the routing universe (active-only, full, or any
    ;;subset for Phase 12's varying-scale measurement) and search depth explicitly.
    ;;Meant for off-chain dirty-read use only (see the defun's own @doc).
    (defun URC_HopperExhaustive:object{Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal swpairs:[string] max-attempts:integer)
    )
    ;;#34 Phase 7: active-required path validation — wraps SWPT's exists-only structural
    ;;check with an extra can-swap pass. Lives here, not in SWPT, because SWPT deploys
    ;;before SWP and can't reach SWP::UR_CanSwap directly (same reason URC_EdgesActive's
    ;;own whitelist check couldn't live there either).
    (defun URC_ValidatePathActive:bool (nodes:[string] edges:[string]))
    ;;#34 Phase 8: computes a Hopper (feeless output-values) for an ALREADY-CHOSEN
    ;;nodes+edges route (a dirty-read-injected bundle's swap-route or a pricing path),
    ;;walking the EXACT supplied edges — unlike URCx_HopperForNodes (used by the
    ;;self-searching URC_Hopper/URC_HopperActive), this never re-selects a "best" edge
    ;;per hop, since the real execution will use these exact edges regardless. Caller's
    ;;responsibility to validate nodes/edges first (URC_ValidatePathStructure/Active) —
    ;;this function only computes, it does not validate.
    (defun URC_HopperForKnownRoute:object{Hopper}
        (nodes:[string] edges:[string] hopper-input-amount:decimal)
    )
    (defun URC_BestEdge:string (ia:decimal i:string o:string))
    (defun URC_BestEdgeFiltered:string (ia:decimal i:string o:string swpairs:[string]))
        ;;
    (defun URC_OuroPrimordialPrice:decimal ())
    ;;#73C fix: OURO's own worth in WSTOA, per unit — a real 1-unit weighted-pool swap
    ;;through the primordial pool (URC_W-Swap), not the old hand-rolled reserve ratio
    ;;(which silently ignored the pool's own weights). Still zero graph search — OURO
    ;;and WSTOA sit in the same primordial pool, one hop. <ouro>/<wstoa> are accepted
    ;;as params instead of self-fetched, so callers that already hold them (every real
    ;;caller does, via DALOS::UR_CanonicalStoaIds) don't pay for a redundant read — the
    ;;exact regression Phase 8b's own DALOS combined-reader fix was about avoiding.
    ;;Used by URC_WorthWSTOA's own id==OURO shortcut (see that function's own doc).
    (defun URC_SingleOuroWorthWSTOA:decimal (ouro:string wstoa:string))
    ;;#65fL Phase 8b: SSTOA's own worth in WSTOA, per unit, via the ATS autostake index
    ;;— extracted so URC_WorthWSTOA's own id==SSTOA branch and URCx_PrimordialValueAndOuroSupply
    ;;share it without a static recursive-cycle compile error (see the defun's own doc).
    (defun URC_SingleSSTOAWorthWSTOA:decimal ())
    (defun URC_TokenDollarPrice (id:string stoa-pid:decimal))
    (defun URC_SingleWorthWSTOA (id:string))
    (defun URC_WorthWSTOA (id:string amount:decimal))
    (defun URC_PoolValue:[decimal] (swpair:string))
    ;;#65bL Phase 4: URC_WorthWSTOA/URC_PoolValue, sourcing any graph search they need
    ;;via an ALREADY-FETCHED <raw-graph> instead of a fresh self-fetch per call — see
    (defun URC_WorthWSTOAFromRaw (id:string amount:decimal raw-graph:[object{SwapTracerV3.RawGraphNode}]))
    (defun URC_PoolValueFromRaw:[decimal] (swpair:string raw-graph:[object{SwapTracerV3.RawGraphNode}]))
    ;;#65bL Phase 7: URC_WorthWSTOA/URC_PoolValue again, sourcing any graph search via
    ;;an ALREADY-BUILT [GraphNode] instead of rebuilding it from <raw-graph> per
    ;;call — see URC_HopperFromGraph's own doc for the full rationale.
    (defun URC_WorthWSTOAFromGraph (id:string amount:decimal graph:[object{BreadthFirstSearchV2.GraphNode}]))
    (defun URC_PoolValueFromGraph:[decimal] (swpair:string graph:[object{BreadthFirstSearchV2.GraphNode}]))
        ;;
    (defun URC_DirectRefillAmounts:[decimal] (swpair:string ids:[string] amounts:[decimal]))
    (defun URC_IndirectRefillAmounts:[decimal] (X:[decimal] positions:[integer] amounts:[decimal]))
    (defun URC_TrimIdsWithZeroAmounts:[string] (swpair:string input-amounts:[decimal]))
    (defun URC_IssuePoolIgnis:decimal ())
    (defun URCi_Issue:object{IgnisCollectorV3.OutputCumulator} (account:string pool-tokens:[object{SwapperV4.PoolTokens}]))
    (defun URCi_IssuePool:object{IgnisCollectorV3.OutputCumulator} (account:string pool-tokens:[object{SwapperV4.PoolTokens}]))
    (defun URCi_IssueStoa:decimal ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;
    ;;  [UEV] Functions
    ;;
    (defun UEV_SwapData (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData}))
    (defun UEV_InverseSwapData (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData}))
        ;;
    (defun UEV_Issue (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;
    ;;  [X] Functions
    ;;
    ;;#36M/M5 fix: forward-module entrypoint for the shared pool-issuance write
    ;;sequence — SWPI's own C_Issue and MTX-SWP::MTX|C_Issue's Step 3 both call this
    ;;instead of each independently reimplementing the same mint/transfer/tracker
    ;;writes. Returns [swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out]
    ;;— a wider list, not an IgnisCollectorV3.OutputCumulator (matches this codebase's
    ;;XE_* convention: the forward module's own C_ composes IGNIS, not this function) —
    ;;so C_Issue can still aggregate every sub-call's own cumulator into its single
    ;;billed response exactly as before, while MTX|C_Issue (which already bills
    ;;separately in its own Step 2) can just take swpair/token-lp and ignore the rest.
    (defun XE_IssueWrite:list (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool))
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  []C] Functions
    ;;
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool))

)
;;
(module SWPI GOV
    @doc "SWPI (SwapperIssueV4) handles SWP pool issuance and the swap-math/pricing engine. \
        \ It computes direct and inverse swaps with fees across Stable/Weighted/standard \
        \ pool types, runs the Hopper multi-hop router (best-of-candidate selection), and \
        \ prices tokens/pools in WSTOA. C_Issue/XE_IssueWrite mint the LP token and register \
        \ the pool (folding in XE_AddLPTracker so every issuance path registers)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SwapperIssueV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SWPI                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWPI_ADMIN)))
    (defcap GOV|SWPI_ADMIN ()                           (enforce-guard GOV|MD_SWPI))
    ;;{G5}  functions
    ;;
    (defun GOV|SWP|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|SWP|SC_NAME)
        )
    )
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
    (deftable P|T:{OuronetPolicyV2.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV2.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P4}  capabilities
    (defcap P|SWPI|CALLER ()
        true
    )
    (defcap P|SWPI|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SWPI|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|SWPI|REMOTE-GOV))
        (compose-capability (P|SWPI|CALLER))
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
        (with-capability (GOV|SWPI_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWPI_ADMIN)
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
        (with-capability (GOV|SWPI_ADMIN)
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
        (with-capability (GOV|SWPI_ADMIN)
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|SWPI|CALLER)))
            )
            (ref-P|SWP::P|A_Add
                "SWPI|RemoteSwpGov"
                (create-capability-guard (P|SWPI|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    ;;
    (defconst EMPTY_HOPPER
        [
            {
                "nodes" : [],
                "edges" : [],
                "output-values" : []
            }
        ]
    )
    (defconst BAR                                       (CT_Bar))
    ;;#36M/M5 fix: named, single source of truth for the genesis LP mint amount —
    ;;was a bare 10000000.0 literal duplicated independently in both C_Issue and
    ;;MTX|C_Issue's own write sequences; now lives once, inside the shared
    ;;XE_IssueWrite both call.
    (defconst GENESIS_LP_SUPPLY                         10000000.0)
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;#36M/M5 fix: local cap for XE_IssueWrite (forward-module entrypoint) — no
    ;;checks of its own beyond P|UEV_IMC in the defun itself. Real validation
    ;;(UEV_Issue) already ran in whichever caller's own defcap got here first
    ;;(SWPI|C>ISSUE for C_Issue, or MTX-SWP's own Step 1) — this function only
    ;;performs the already-validated writes, matching the XE_* contract of no
    ;;enforce/UEV_* beyond P|UEV_IMC.
    (defcap SWPI|XE>ISSUE-WRITE (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @event
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap SWPI|C>ISSUE (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @event
        ;;CONDITIONAL authorisation, hoisted 2026-09-14: only a PRIMORDIAL issuance (p) needs the
        ;;admin key, so this cannot become an unconditional gate -- but when it does apply it must
        ;;apply BEFORE UEV_Issue, or a stranger's refusal comes from a shape rule and the admin
        ;;check is never the thing that stopped them. The branch is preserved exactly.
        (if p
            (compose-capability (GOV|SWPI_ADMIN))
            true
        )
        (UEV_Issue account pool-tokens fee-lp weights amp p)
        (compose-capability (P|DT))
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
    ;;
    (defun UDC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput}
        (
            dsid:object{UtilitySwpV2.DirectSwapInputData}
            A:decimal X:[decimal] input-positions:[integer] output-position:integer weights:[decimal]
        )
        (let
            (
                ;;Unwrap Object Data
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-U|SWP::UDC_DirectRawSwapInput
                A
                X
                input-amounts 
                input-positions
                output-position
                (ref-DPTF::UR_Decimals output-id)
                weights
            )
        )
    )
    (defun UDC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput}
        (
            rsid:object{UtilitySwpV2.ReverseSwapInputData}
            A:decimal X:[decimal] output-position:integer input-position:integer weights:[decimal]
        )
        (let
            (
                ;;Unwrap Object Data
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-U|SWP::UDC_InverseRawSwapInput
                A
                X
                output-amount
                output-position
                input-position
                (ref-DPTF::UR_Decimals input-id)
                weights
            )
        )
    )
    (defun UDC_Hopper:object{SwapperIssueV4.Hopper} (a:[string] b:[string] c:[decimal])
        {"nodes"            : a
        ,"edges"            : b
        ,"output-values"    : c}
    )
    ;;{5.2}  Compute [UC]
    (defun UCv_DeviationInValueShares:decimal (pool-reserves:[decimal] asymmetric-liq:[decimal] w:[decimal])
        @doc "Maximum Pool Deviation is (n-1)/n, and max allowed deviation for asymmetric liq is 40% of this value"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (l1:integer (length pool-reserves))
                (l2:integer (length asymmetric-liq))
                (l3:integer (length w))
                (iz-asymmetric:bool (contains 0.0 asymmetric-liq))
            )
            (ref-U|INT::UEV_UniformList [l1 l2 l3])
            (enforce iz-asymmetric "Invalid Values to Compute Deviation In Value Shares")
            (let
                (
                    (ref-U|VST:module{UtilityVstV2} U|VST)
                    (sw:decimal (fold (+) 0.0 w))
                    (iz-weigthed:bool (if (= sw 1.0) true false))
                    ;;
                    (initial-shares:[decimal] (UC_PoolShares pool-reserves w))
                    (asymmetric-shares:[decimal] (zip (*) initial-shares asymmetric-liq))
                    (new-total-shares:decimal (+ 5040000.0 (fold (+) 0.0 asymmetric-shares)))
                    (new-supply:[decimal] (zip (+) pool-reserves asymmetric-liq))
                    ;;
                    (aw:[decimal] (if iz-weigthed w (ref-U|VST::UCv_SplitBalanceForVesting 24 1.0 l1)))
                    (deviated-shares:[decimal] (UC_DeviatedShares new-supply initial-shares new-total-shares))
                    (diff-with-deviated-shares:[decimal] (zip (-) aw deviated-shares))
                    (abs-dwds:[decimal]
                        (fold
                            (lambda
                                (acc:[decimal] idx:integer)
                                (ref-U|LST::UC_AppL acc (abs (at idx diff-with-deviated-shares )))
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                    ;;Total Deviation must be divided by 2, to account for gain and losses in share variation
                    (total-deviation:decimal (floor (/ (fold (+) 0.0 abs-dwds) 2.0) 24))
                )
                total-deviation
            )
        )
    )
    (defun UC_DeviatedShares:[decimal] (pool-reserves:[decimal] pool-shares:[decimal] new-total-shares:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL acc
                        (floor (/ (* (at idx pool-reserves)(at idx pool-shares)) new-total-shares) 24)
                    )
                )
                []
                (enumerate 0 (- (length pool-reserves) 1))
            )
        )
    )
    (defun UC_PoolShares:[decimal] (pool-reserves:[decimal] w:[decimal])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (size:decimal (dec (length pool-reserves)))
                (sw:decimal (fold (+) 0.0 w))
                (iz-weigthed:bool (if (= sw 1.0) true false))
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (let
                        (
                            (amount:decimal (at idx pool-reserves))
                            (position-share:decimal
                                (if iz-weigthed
                                    (* 5040000.0 (at idx w))
                                    (/ 5040000.0 size)
                                )
                            )
                            (amount-share:decimal
                                (floor (/ position-share amount) 24)
                            )
                        )
                        (ref-U|LST::UC_AppL acc amount-share)
                    )
                )
                []
                (enumerate 0 (- (length w) 1))
            )
        )
    )
    (defun UC_VirtualSwap:object{UtilitySwpV2.VirtualSwapEngine} 
        (vse:object{UtilitySwpV2.VirtualSwapEngine} dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Executes a Virtual Swap, saving data in the Output Object"
        (let
            (
                ;;Unwrap Input Objects
                (v-tokens:[string] (at "v-tokens" vse))
                (v-prec:[integer] (at "v-prec" vse))
                (account:string (at "account" vse))
                (account-supply:[decimal] (at "account-supply" vse))
                (swpair:string (at "swpair" vse))
                (X:[decimal] (at "X" vse))
                (A:decimal (at "A" vse))
                (W:[decimal] (at "W" vse))
                (F:object{UtilitySwpV2.SwapFeez} (at "F" vse))
                (fuel:[decimal] (at "fuel" vse))
                (special:[decimal] (at "special" vse))
                (boost:[decimal] (at "boost" vse))
                (swaps:[object{UtilitySwpV2.DirectSwapInputData}] (at "swaps" vse))
                ;;
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (input-positions:[integer] (UCv_PoolTokenPositions swpair input-ids))
                (output-position:integer (at 0 (UCv_PoolTokenPositions swpair [output-id])))
                ;;
                (swap-result:object{UtilitySwpV2.DirectTaxedSwapOutput}
                    (UC_BareboneSwapWithFeez account pool-type dsid F A X v-prec input-positions output-position W)
                )
                (tsoa:decimal (fold (+) 0.0 [(at "o-id-special" swap-result) (at "o-id-liquid" swap-result) (at "o-id-netto" swap-result)]))
                (tsoa-filled:[decimal] (URC_IndirectRefillAmounts X [output-position] [tsoa]))
                (remainder-filled:[decimal] (URC_IndirectRefillAmounts X [output-position] [(at "o-id-netto" swap-result)]))
                (input-amounts-filled:[decimal] (URC_IndirectRefillAmounts X input-positions input-amounts))
            )
            (ref-U|SWP::UDC_VirtualSwapEngine
                v-tokens v-prec account
                (zip (+) remainder-filled (zip (-) account-supply input-amounts-filled)) 
                swpair 
                (zip (-) (zip (+) X input-amounts-filled) remainder-filled)
                A W F
                (zip (+) fuel (at "lp-fuel" swap-result))
                (ref-U|LST::UC_ReplaceAt special output-position (+ (at output-position special) (at "o-id-special" swap-result)))
                (ref-U|LST::UC_ReplaceAt boost output-position (+ (at output-position boost) (at "o-id-liquid" swap-result)))
                (ref-U|LST::UC_AppL swaps dsid)
            )
        )
    )
    (defun UC_BareboneSwapWithFeez:object{UtilitySwpV2.DirectTaxedSwapOutput}
        (
            account:string pool-type:string 
            dsid:object{UtilitySwpV2.DirectSwapInputData} fees:object{UtilitySwpV2.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] input-positions:[integer] output-position:integer weights:[decimal]
        )
        @doc "Performs a Direct Swap with Fees Computation, outputing results in an object{UtilitySwpV2.DirectTaxedSwapOutput} \
            \ Given proper inputs, can be used for an actual Swap Functions, to save redundant code."
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                ;;Get Working fees
                (reduced-fees:object{UtilitySwpV2.SwapFeez} (URC_EliteFeeReduction account fees))
                (f1:decimal (at "lp" reduced-fees))
                (f2:decimal (at "special" reduced-fees))
                (f3:decimal (at "boost" reduced-fees))
                (o-prec:integer (at output-position X-prec))
                ;;
                ;;From the input amounts, compute FeeSharesExcludingLpFee <fselp>
                (fselp:decimal (- 1000.0 f1))
                (input-amounts-for-swap:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (floor
                                    (* (at idx input-amounts) (/ fselp 1000.0))
                                    (at (at idx input-positions) X-prec)
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length input-amounts) 1))
                    )
                )
                (dsid-for-swap:object{UtilitySwpV2.DirectSwapInputData}
                    (ref-U|SWP::UDC_DirectSwapInputData input-ids input-amounts-for-swap output-id)
                )
                (drsi:object{UtilitySwpV2.DirectRawSwapInput}
                    (UDC_DirectRawSwapInput dsid-for-swap A X input-positions output-position weights)
                )
                (input-amounts-for-lp:[decimal] (zip (-) input-amounts input-amounts-for-swap))
                (input-amounts-for-lp-filled:[decimal] (URC_IndirectRefillAmounts X input-positions input-amounts-for-lp))
                ;;
                ;;Total-Swap-Output-Amount <tsoa> is computed without them, then splited into 3 parts: 
                ;;special, boost, remainder
                (tsoa:decimal (UCv_BareboneSwap pool-type drsi))
                (special:decimal (floor (* (/ f2 fselp) tsoa) o-prec))
                (boost:decimal (floor (* (/ f3 fselp) tsoa) o-prec))
                (remainder:decimal (- tsoa (+ special boost)))
                (output:object{UtilitySwpV2.DirectTaxedSwapOutput}
                    (ref-U|SWP::UDC_DirectTaxedSwapOutput
                        input-amounts-for-lp-filled
                        output-id
                        special
                        boost
                        remainder
                    )
                )
            )
            output
        )
    )
    (defun UC_InverseBareboneSwapWithFeez:object{UtilitySwpV2.InverseTaxedSwapOutput}
        
        (
            account:string pool-type:string 
            rsid:object{UtilitySwpV2.ReverseSwapInputData} fees:object{UtilitySwpV2.SwapFeez}
            A:decimal X:[decimal] X-prec:[integer] output-position:integer input-position:integer weights:[decimal]
        )
        @doc "Performs a Reverse Swap with Fees Computation, outputing results in an object{UtilitySwpV2.InverseTaxedSwapOutput} \
            \ Use Case is displaying Input Amounts for a Swap when the desired Output Amount of a Token is entered first. \
            \ However not only the input required can be displayed, but also the susequent fees that would be incurred"
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                ;;
                ;;Get Working fees
                (reduced-fees:object{UtilitySwpV2.SwapFeez} (URC_EliteFeeReduction account fees))
                (f1:decimal (at "lp" reduced-fees))
                (f2:decimal (at "special" reduced-fees))
                (f3:decimal (at "boost" reduced-fees))
                (o-prec:integer (at output-position X-prec))
                (i-prec:integer (at input-position X-prec))
                ;;
                ;;Star by computing the Output fee shares <ofs>
                (ofs:decimal (- 1000.0 (fold (+) 0.0 [f1 f2 f3])))
                ;;Compute Output-Amount per fee Share <oapfs>
                (oapfs:decimal (floor (/ output-amount ofs) o-prec))
                (boost:decimal (floor (* f3 oapfs) o-prec))
                (special:decimal (floor (* f2 oapfs) o-prec))
                ;;Then Compute Total-Swap-Output-Amount <tsoa>
                (tsoa:decimal (fold (+) 0.0 [output-amount boost special]))
                ;:Remake a new rsid
                (new-rsid:object{UtilitySwpV2.ReverseSwapInputData} 
                    (ref-U|SWP::UDC_ReverseSwapInputData output-id tsoa input-id)
                )
                (irsi:object{UtilitySwpV2.InverseRawSwapInput}
                    (UDC_InverseRawSwapInput new-rsid A X output-position input-position weights)
                )
                ;;Now Compute the Input Amount needed to get the <tsoa>, the Partial-Input-Amount <pia>
                ;;<pia> is part of the TotalInputAmount, that would be used for a direct swap, after LP fees have been retained
                (pia:decimal (UC_BareboneInverseSwap pool-type irsi))
                ;;Now Compute the Total-Input-Amouant <tia>
                (tia:decimal (floor (/ (* 1000.0 pia) (- 1000.0 f1)) i-prec))
                (output:object{UtilitySwpV2.InverseTaxedSwapOutput}
                    (ref-U|SWP::UDC_InverseTaxedSwapOutput
                        boost
                        special
                        (URC_IndirectRefillAmounts X [input-position] [(- tia pia)])
                        input-id
                        tia
                    )
                )
            )
            output
        )
    )
    ;;
    (defun UCv_BareboneSwap:decimal
        (pool-type:string drsi:object{UtilitySwpV2.DirectRawSwapInput})
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (l1:integer (length (at "input-amounts" drsi)))
            )
            (if (= pool-type "S")
                (enforce (= l1 1) "Only a single Input can be used in Stable Swap")
                true
            )
            (cond
                ((= pool-type "S") (ref-U|SWP::UC_ComputeY drsi))
                ((= pool-type "W") (ref-U|SWP::UC_ComputeWP drsi))
                ((= pool-type "P") (ref-U|SWP::UC_ComputeEP drsi))
                -1.0
            )
        )
    )
    (defun UC_BareboneInverseSwap:decimal 
        (pool-type:string irsi:object{UtilitySwpV2.InverseRawSwapInput})
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (cond
                ((= pool-type "S") (ref-U|SWP::UCv_ComputeInverseY irsi))
                ((= pool-type "W") (ref-U|SWP::UC_ComputeInverseWP irsi))
                ((= pool-type "P") (ref-U|SWP::UC_ComputeInverseEP irsi))
                -1.0
            )
        )
    )
    (defun UCv_PoolTokenPositions:[integer] (swpair:string input-ids:[string])
        @doc "Same result as <URCv_PoolTokenPositions> but being done without reading <swpair> data \
        \ Result is simply computed, through the <swpair> string"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (are-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
            )
            (enforce are-on-pool (format "Input Token IDs {} arent on pool {}" [input-ids swpair]))
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (ref-SWP::UCv_PoolTokenPosition swpair (at idx input-ids))
                    )
                )
                []
                (enumerate 0 (- (length input-ids) 1))
            )
        )
    )
    (defun UC_BestHopper:object{SwapperIssueV4.Hopper} (candidates:[object{SwapperIssueV4.Hopper}])
        @doc "Picks the candidate Hopper with the highest final output value. \
            \ <candidates> must be non-empty (caller's responsibility — <URCx_Hopper> \
            \ only calls this once it has confirmed at least one route was found)."
        (if (<= (length candidates) 1)
            (at 0 candidates)
            (fold
                (lambda
                    (best:object{SwapperIssueV4.Hopper} idx:integer)
                    (let
                        (
                            (candidate:object{SwapperIssueV4.Hopper} (at idx candidates))
                            (best-final:decimal (at 0 (take -1 (at "output-values" best))))
                            (candidate-final:decimal (at 0 (take -1 (at "output-values" candidate))))
                        )
                        (if (> candidate-final best-final) candidate best)
                    )
                )
                (at 0 candidates)
                (enumerate 1 (- (length candidates) 1))
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCx_Hopper:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal swpairs:[string])
        @doc "Shared Hopper-computation core for <URC_Hopper>/<URC_HopperActive> — \
            \ identical in every respect except which <swpairs> universe routing \
            \ is allowed to consider. Internal only, not on <SwapperIssueV4>. \
            \ #65bL Phase 5 fix: was best-of-3 via <SWPT::URC_ComputeAlternateRoutes> \
            \ (#34M/M2's original fix). Measured directly against this codebase's \
            \ real, organically-grown ~102-pool topology (not a hand-engineered one) \
            \ across 7 representative pairs spanning 1-8 hops: best-of-3 found a \
            \ better route than the single first-found one in ZERO of them — 0.0% \
            \ difference every time. #34M/M2's own original proof that best-of-3 \
            \ matters used a deliberately hand-built diamond topology (issuance order \
            \ controlled specifically to make BFS's first-found route the weak one) \
            \ to demonstrate the FAILURE MODE is real — it never claimed the failure \
            \ mode manifests naturally at scale, and per this measurement, it \
            \ doesn't, here: with dozens of parallel pools and organic swap activity \
            \ pushing chronically-unbalanced pools back toward parity, first-found \
            \ and best-of-3 converge. Switched to a single <SWPT::URC_ComputeGraphPath> \
            \ call — the greedy, single-shot search <URC_HopperActiveShortest> \
            \ already uses elsewhere. <SWPT::URC_ComputeAlternateRoutes> itself is \
            \ NOT deleted (still correct, still tested, `SWP|TX 032c`-`032g`'s own \
            \ adversarial proof of the original failure mode stays as regression \
            \ coverage) — just no longer the default live-routing path. \
            \ CAVEAT, worth stating plainly: URCx_HopperForNodes's own per-hop \
            \ <URC_BestEdgeFiltered> selection is a GREEDY choice — picking the best \
            \ available edge at each individual hop does not mathematically guarantee \
            \ the overall path is the highest-value one achievable end to end (a \
            \ locally-optimal choice at every step is not the same as a globally- \
            \ optimal path). This was already true before this fix, at every K \
            \ (including best-of-3) — this fix does not introduce that limitation, it \
            \ was always structurally present; it only removes the (measured, at this \
            \ topology, not currently earning its cost) 2-candidate cross-route \
            \ comparison layered on top of it. \
            \ #65bL Phase 1 fix: checks SWPT|PathCache (via URC_ReadPathCacheFresh) \
            \ first — on a fresh hit, skips the live BFS search entirely and \
            \ uses the cached node-path as the sole candidate. Safe because the real \
            \ per-hop edge is always re-derived live downstream in \
            \ URCx_HopperForNodes regardless of where the node-path came from — a \
            \ cache hit only changes WHICH nodes get tried, never how an edge gets \
            \ picked or validated. On a miss (or a stale entry, topology-version \
            \ behind current), falls through to the unchanged live search."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list at all — the Tracer's
                ;;storage is principal-agnostic (SwapTracerV3).
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — a `let` binding here would
                ;;evaluate unconditionally even on a hit, silently paying for the live
                ;;search Phase 1's whole point is to skip. Nested inside the `if`
                ;;instead so a cache hit never touches SWPT::URC_ComputeGraphPathFromRaw.
                (routes:[[string]]
                    (if (!= cached-nodes [BAR])
                        [cached-nodes]
                        ;;#65bL Phase 5 fix: must go through the raw-graph-once path
                        ;;(URC_FetchRawGraph + URC_ComputeGraphPathFromRaw), NOT the
                        ;;plain self-fetching URC_ComputeGraphPath — that function was
                        ;;never touched by Phase 2's optimization (it only ever makes
                        ;;one call, so cross-attempt sharing never applied to it), so
                        ;;using it here would mean a SINGLE search that's still paying
                        ;;the pre-Phase-2 cost, while best-of-3's own first attempt
                        ;;(via URC_ComputeAlternateRoutes's own internal fetch) is
                        ;;already Phase-2-cheap. Measured directly: using the plain
                        ;;self-fetching path here was NET MORE EXPENSIVE than
                        ;;best-of-3, exactly backwards from the goal — caught before
                        ;;shipping, not after.
                        (let
                            (
                                (single-route:[string]
                                    (ref-SWPT::URC_ComputeGraphPathFromRaw
                                        hopper-input-id hopper-output-id swpairs
                                        (ref-SWPT::URC_FetchRawGraph
                                            (ref-U|SWP::UC_MakeGraphNodes hopper-input-id hopper-output-id swpairs)
                                        )
                                    )
                                )
                            )
                            (if (= single-route [BAR]) [] [single-route])
                        )
                    )
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URCx_HopperFromRaw:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] raw-graph:[object{SwapTracerV3.RawGraphNode}]
        )
        @doc "#65bL Phase 4 fix: <URCx_Hopper>, sourcing its routing search via an \
            \ ALREADY-FETCHED <raw-graph> (<SWPT::URC_FetchRawGraph>) instead of \
            \ letting <SWPT::URC_ComputeGraphPathFromRaw> fetch its own — for a caller \
            \ making MULTIPLE unrelated Hopper queries in one transaction (the \
            \ STOA-repricing loop: one query per distinct pool touched, each to a \
            \ different first-token but the SAME destination, WSTOA) who fetches the \
            \ whole topology's raw graph exactly ONCE and reuses it across every \
            \ query. Safe because <SWPT::UC_MakeGraphNodes> (the node-universe \
            \ derivation both the fetch and every query rely on) is <input>/<output>- \
            \ independent by construction — it derives every token appearing across \
            \ the full <swpairs> list, regardless of which specific pair is being \
            \ queried — so ONE raw-graph fetched against a given <swpairs> universe \
            \ is valid for EVERY query against that same universe, not just the one \
            \ it happened to be fetched for. Still checks SWPT|PathCache first, \
            \ identically to <URCx_Hopper> — a cache hit is even cheaper than a \
            \ shared-raw-graph live search, this doesn't replace that, it only makes \
            \ the miss case cheaper too. \
            \ #65bL Phase 5 fix: was best-of-3 via <SWPT::URC_ComputeAlternateRoutesFromRaw> \
            \ — see <URCx_Hopper>'s own doc for the full measured rationale (identical \
            \ here, same shared decision)."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — see URCx_Hopper's own comment
                ;;on this exact same eager-`let`-evaluation trap.
                (routes:[[string]]
                    (if (!= cached-nodes [BAR])
                        [cached-nodes]
                        (let
                            (
                                (single-route:[string]
                                    (ref-SWPT::URC_ComputeGraphPathFromRaw hopper-input-id hopper-output-id swpairs raw-graph)
                                )
                            )
                            (if (= single-route [BAR]) [] [single-route])
                        )
                    )
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URCx_HopperFromGraph:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] graph:[object{BreadthFirstSearchV2.GraphNode}]
        )
        @doc "#65bL Phase 7 fix: <URCx_HopperFromRaw>, sourcing its routing search \
            \ via an ALREADY-BUILT <graph> (<SWPT::UC_MakeGraphFromRaw>) instead of \
            \ rebuilding it from <raw-graph> on every call — see \
            \ <URC_HopperFromGraph>'s own doc for the full rationale (repricing- \
            \ loop graph-build sharing, one layer deeper than Phase 4's raw-graph \
            \ sharing). Still checks SWPT|PathCache first, identically to \
            \ <URCx_Hopper>/<URCx_HopperFromRaw> — a cache hit is even cheaper than \
            \ a shared-graph live search, this doesn't replace that, it only makes \
            \ the miss case cheaper too."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                ;;Only computed on an actual cache miss — see URCx_Hopper's own comment
                ;;on this exact same eager-`let`-evaluation trap.
                (routes:[[string]]
                    (if (!= cached-nodes [BAR])
                        [cached-nodes]
                        (let
                            (
                                (single-route:[string]
                                    (ref-SWPT::URC_ComputeGraphPathFromGraph hopper-input-id hopper-output-id graph)
                                )
                            )
                            (if (= single-route [BAR]) [] [single-route])
                        )
                    )
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URC_EliteFeeReduction:object{UtilitySwpV2.SwapFeez} (account:string fees:object{UtilitySwpV2.SwapFeez})
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
                (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
            )
            (ref-U|SWP::UDC_SwapFeez
                (ref-U|DALOS::UC_GasCost (at "lp" fees) major minor false)
                (ref-U|DALOS::UC_GasCost (at "special" fees) major minor false)
                (ref-U|DALOS::UC_GasCost (at "boost" fees) major minor false)
            )
        )
    )
    (defun URCv_PoolTokenPositions:[integer] (swpair:string input-ids:[string])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens (ref-SWP::UR_PoolTokens swpair))
                (are-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
            )
            (enforce are-on-pool (format "Input Token IDs {} arent on pool {}" [input-ids swpair]))
            (fold
                (lambda
                    (acc:[integer] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (ref-SWP::URv_PoolTokenPosition swpair (at idx input-ids))
                    )
                )
                []
                (enumerate 0 (- (length input-ids) 1))
            )
        )
    )
    ;;
    (defun URC_DirectRawSwapInput:object{UtilitySwpV2.DirectRawSwapInput}
        (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-U|SWP::UDC_DirectRawSwapInput
                (ref-SWP::UR_Amplifier swpair)
                (ref-SWP::UR_PoolTokenSupplies swpair)
                input-amounts 
                (URCv_PoolTokenPositions swpair input-ids)
                (ref-SWP::URv_PoolTokenPosition swpair output-id)
                (ref-DPTF::UR_Decimals output-id)
                (ref-SWP::UR_Weigths swpair)
            )
        )
    )
    (defun URC_InverseRawSwapInput:object{UtilitySwpV2.InverseRawSwapInput}
        (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
            )
            (ref-U|SWP::UDC_InverseRawSwapInput
                (ref-SWP::UR_Amplifier swpair)
                (ref-SWP::UR_PoolTokenSupplies swpair)
                output-amount
                (ref-SWP::URv_PoolTokenPosition swpair output-id)
                (ref-SWP::URv_PoolTokenPosition swpair input-id)
                (ref-DPTF::UR_Decimals input-id)
                (ref-SWP::UR_Weigths swpair)
            )
        )
    )
    ;;
    (defun URCv_Swap:decimal 
        (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData} validation:bool)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (l1:integer (length (at "input-amounts" dsid)))
            )
            (if (= pool-type "S")
                (enforce (= l1 1) "Only a single Input can be used in Stable Swap")
                true
            )
            (if validation
                (UEV_SwapData swpair dsid)
                true
            )
            (cond
                ((= pool-type "S") (URC_S-Swap swpair dsid))
                ((= pool-type "W") (URC_W-Swap swpair dsid))
                ((= pool-type "P") (URC_P-Swap swpair dsid))
                -1.0
            )
        )
    )
    (defun URC_S-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Swable Pool. Data needed: \
            \ <A> = Pool Amplifier\
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = Position of the input token (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeY
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_W-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Weigthed Constant Product Pool. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = list with the pool position of the input tokens (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeWP
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_P-Swap:decimal (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        @doc "Performs a Swap Computation in a Constant Product Pool. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <input-amounts> = Amounts of the Input Tokens that make the swap. They must be in the same order as the <input-ids> \
            \ ip = list with the pool position of the input tokens (must be read) \
            \ op = position in the pool of the output token (must be read) \
            \ o-prec = precision of the output token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeEP
                (URC_DirectRawSwapInput swpair dsid)
            )
        )
    )
    (defun URC_InverseSwap:decimal
        (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData} validation:bool)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
            )
            (if validation
                (UEV_InverseSwapData swpair rsid)
                true
            )
            (cond
                ((= pool-type "S") (URC_S-InverseSwap swpair rsid))
                ((= pool-type "W") (URC_W-InverseSwap swpair rsid))
                ((= pool-type "P") (URC_P-InverseSwap swpair rsid))
                -1.0
            )
        )
    )
    (defun URC_S-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        @doc "Performs a Swap Computation in a Swable Pool. Data needed: \
            \ <A> = Pool Amplifier\
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UCv_ComputeInverseY
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    (defun URC_W-InverseSwap:decimal (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        @doc "Inverse Swap solves how much of a given SINGLE input is needed to get a specific SINGLE output. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read) \
            \ w = weigths of the swpair"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeInverseWP 
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    (defun URC_P-InverseSwap (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        @doc "Inverse Swap solves how much of a given SINGLE input is needed to get a specific SINGLE output. Data needed: \
            \ <X> = Pool Token Supplies (must be read) \
            \ <output-amount> = How much output must be achieved by swaping the input amount that must be solved for \
            \ <op> = output position in the pool (must be read) \
            \ <ip> = input position in the pool (must be read) \
            \ <i-prec> = precision of the input token (must be read)"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (ref-U|SWP::UC_ComputeInverseEP 
                (URC_InverseRawSwapInput swpair rsid)
            )
        )
    )
    ;;
    (defun URCx_HopperForNodes:object{SwapperIssueV4.Hopper}
        (nodes:[string] hopper-input-amount:decimal swpairs:[string])
        @doc "Computes the Hopper object (best per-hop edge + accumulated output) for \
            \ an ALREADY-KNOWN <nodes> path. Split out of <URCx_Hopper> (#34M/M2 fix) \
            \ so the identical per-hop best-edge computation can be run once per \
            \ candidate route in <URCx_Hopper>'s best-of-K comparison, not just the \
            \ single first-found route. Computes: \
            \ 1] The hops along <nodes>, the <edges> as the highest-output edge from all available \
            \ #49L fix: was 'cheapest available edge' — backwards framing (C1/#6C's own fix made \
            \ this maximize output among parallel pools, not minimize cost) \
            \ 2] The best <output> values using said best <edges>, given the <hopper-input-amount>"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
            )
            (if (!= nodes [BAR])
                (let
                    (
                        (fl:[object{SwapperIssueV4.Hopper}]
                            (fold
                                (lambda
                                    (acc:[object{SwapperIssueV4.Hopper}] idx:integer)
                                    (ref-U|LST::UC_ReplaceAt
                                        acc
                                        0
                                        (let
                                            (
                                                (input:decimal
                                                    (if (= idx 0)
                                                        hopper-input-amount
                                                        (at 0 (take -1 (at "output-values" (at 0 acc))))
                                                    )
                                                )
                                                (i-id:string (at idx nodes))
                                                (o-id:string (at (+ idx 1) nodes))
                                                ;;#19H fix: restrict edge candidates to this call's
                                                ;;<swpairs> universe (full for <URC_Hopper>, active-only
                                                ;;for <URC_HopperActive>) — a disabled parallel pool can
                                                ;;never be chosen over an active one, or at all when
                                                ;;routing active-only.
                                                (best-edge:string (URC_BestEdgeFiltered input i-id o-id swpairs))
                                                (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                                    (ref-U|SWP::UDC_DirectSwapInputData [i-id] [input] o-id)
                                                )
                                                (output:decimal (URCv_Swap best-edge dsid false))
                                            )
                                            (UDC_Hopper
                                                nodes
                                                (ref-U|LST::UC_AppL (at "edges" (at 0 acc)) best-edge)
                                                (ref-U|LST::UC_AppL (at "output-values" (at 0 acc)) output)
                                            )
                                        )
                                    )
                                )
                                EMPTY_HOPPER
                                (enumerate 0 (- (length nodes) 2))
                            )
                        )
                    )
                    (at 0 fl)
                )
                (at 0 EMPTY_HOPPER)
            )
        )
    )
    (defun URC_HopperForKnownRoute:object{SwapperIssueV4.Hopper}
        (nodes:[string] edges:[string] hopper-input-amount:decimal)
        @doc "#34 Phase 8: like URCx_HopperForNodes, computes the feeless per-hop output \
            \ chain for a KNOWN path — but walks the caller-supplied <edges> directly \
            \ instead of re-deriving a 'best' edge per hop via URC_BestEdgeFiltered. \
            \ This matters: a dirty-read-injected bundle's swap-route is what real \
            \ execution (XI_SmartSwapCore) will actually walk, hop for hop — the feeless \
            \ quote used for the slippage floor check must be computed against those SAME \
            \ edges, not a possibly-different 'best' edge a live re-derivation might pick \
            \ when parallel pools exist between the same two tokens (that mismatch could \
            \ silently let a worse real execution slip past a floor check computed on a \
            \ better hypothetical route). Also reused for pricing paths (boost-path, \
            \ stoa-paths) where the caller-chosen edges are likewise the ones that matter, \
            \ not a re-optimized alternative. Caller validates nodes/edges beforehand — \
            \ this function trusts its input and only computes."
        (if (!= nodes [BAR])
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                    (le:integer (length edges))
                )
                (if (= le 0)
                    (UDC_Hopper nodes [] [])
                    (let
                        (
                            (fl:[object{SwapperIssueV4.Hopper}]
                                (fold
                                    (lambda
                                        (acc:[object{SwapperIssueV4.Hopper}] idx:integer)
                                        (ref-U|LST::UC_ReplaceAt
                                            acc
                                            0
                                            (let
                                                (
                                                    (input:decimal
                                                        (if (= idx 0)
                                                            hopper-input-amount
                                                            (at 0 (take -1 (at "output-values" (at 0 acc))))
                                                        )
                                                    )
                                                    (i-id:string (at idx nodes))
                                                    (o-id:string (at (+ idx 1) nodes))
                                                    (swpair:string (at idx edges))
                                                    (dsid:object{UtilitySwpV2.DirectSwapInputData}
                                                        (ref-U|SWP::UDC_DirectSwapInputData [i-id] [input] o-id)
                                                    )
                                                    (output:decimal (URCv_Swap swpair dsid false))
                                                )
                                                (UDC_Hopper
                                                    nodes
                                                    (ref-U|LST::UC_AppL (at "edges" (at 0 acc)) swpair)
                                                    (ref-U|LST::UC_AppL (at "output-values" (at 0 acc)) output)
                                                )
                                            )
                                        )
                                    )
                                    [(UDC_Hopper nodes [] [])]
                                    (enumerate 0 (- le 1))
                                )
                            )
                        )
                        (at 0 fl)
                    )
                )
            )
            (at 0 EMPTY_HOPPER)
        )
    )
    (defun URC_HopperExhaustive:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            swpairs:[string] max-attempts:integer
        )
        @doc "#34 Phase 11 — the original #34 ask: genuine exhaustive route discovery, \
            \ not URCx_Hopper's fixed best-of-3 approximation. Identical shape to \
            \ URCx_Hopper (route-then-price-then-pick-best) but sources candidate \
            \ node-paths from SWPT::URC_ComputeAllRoutes (a real parameterized search \
            \ up to <max-attempts>, P0.2's flat +1000 caller-side escalation pattern \
            \ and P0.2/P0.4's outer-hard-stop/depth-cap already enforced inside that \
            \ function) instead of the K=3-capped URC_ComputeAlternateRoutes. Reuses \
            \ URCx_HopperForNodes (per-candidate feeless value) and UC_BestHopper (pick \
            \ the genuinely highest-output candidate, P1.8's requirement — never by hop \
            \ count as a proxy for cost) completely unchanged; no new value-computation \
            \ logic needed, same division of labor URCx_Hopper already established. \
            \ Exposes <swpairs> directly (unlike the hidden-universe URC_Hopper/ \
            \ URC_HopperActive public wrappers) so a caller picks the routing universe \
            \ explicitly — active-only for real swap discovery, or any subset for \
            \ Phase 12's varying-scale measurement (P2.1). Off-chain dirty-read use \
            \ only — never call this from a paid transaction, that defeats the entire \
            \ point of the #34/#34M redesign."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (routes:[[string]]
                    (ref-SWPT::URC_ComputeAllRoutes hopper-input-id hopper-output-id swpairs max-attempts)
                )
            )
            (if (= (length routes) 0)
                (at 0 EMPTY_HOPPER)
                (let
                    (
                        (candidates:[object{SwapperIssueV4.Hopper}]
                            (map
                                (lambda (nodes:[string]) (URCx_HopperForNodes nodes hopper-input-amount swpairs))
                                routes
                            )
                        )
                    )
                    (UC_BestHopper candidates)
                )
            )
        )
    )
    (defun URC_Hopper:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Creates a Hopper Object routed over the FULL swpair universe, \
            \ including <can-swap>=false pools. Used internally for issuance-time \
            \ pricing (<URC_WorthWSTOA>, <UEV_Issue>'s principal-anchoring check), \
            \ which must work even when neighboring pools aren't swap-enabled yet. \
            \ Live swap-execution/quote callers must use <URC_HopperActive> \
            \ instead (#19H) — routing a real user swap over disabled pools is \
            \ the exact bug that fix closes."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_Hopper hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs))
        )
    )
    (defun URC_HopperFromRaw:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            raw-graph:[object{SwapTracerV3.RawGraphNode}]
        )
        @doc "#65bL Phase 4 fix: <URC_Hopper>, sourcing its routing search via an \
            \ ALREADY-FETCHED <raw-graph> instead of a fresh self-fetch — see \
            \ <URCx_HopperFromRaw>'s own doc for the full rationale."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_HopperFromRaw hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs) raw-graph)
        )
    )
    (defun URC_HopperFromGraph:object{SwapperIssueV4.Hopper}
        (
            hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal
            graph:[object{BreadthFirstSearchV2.GraphNode}]
        )
        @doc "#65bL Phase 7 fix: <URC_HopperFromRaw>, sourcing its routing search \
            \ via an ALREADY-BUILT <graph> instead of rebuilding it from \
            \ <raw-graph> on every call — see <URCx_HopperFromGraph>'s own doc for \
            \ the full rationale."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_HopperFromGraph hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_Swpairs) graph)
        )
    )
    (defun URC_HopperActive:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Live-swap-execution routing entrypoint — restricts BFS routing to \
            \ <can-swap>=true pools only, so a disabled pool can never be \
            \ BFS-selected and then rejected downstream with no fallback (#19H). \
            \ Used by SWPU's actual swap-execution and slippage-quote call sites."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
            )
            (URCx_Hopper hopper-input-id hopper-output-id hopper-input-amount (ref-SWP::URC_ActiveSwpairs))
        )
    )
    (defun URC_HopperActiveShortest:object{SwapperIssueV4.Hopper}
        (hopper-input-id:string hopper-output-id:string hopper-input-amount:decimal)
        @doc "Lightweight Hopper routing over <can-swap>=true pools only — a single \
            \ shortest BFS route (<SWPT::URC_ComputeGraphPath>), never the best-of-3 \
            \ alternate-route search <URC_HopperActive> runs (P0.6, SWP exhaustive- \
            \ path-search HANDOFF doc). Built for <SWPU::XI_RawLiquidPump>'s Liquid \
            \ Boost pump: that call only needs *a* valid route to SSTOA to price a \
            \ small residual fee slice for burning, not the *optimal* one — but it \
            \ fires once per SmartSwap hop, so routing it through the same up-to-3x \
            \ alternate-route search real swap execution uses multiplies cost by \
            \ hop-count x 3 for no pricing benefit worth the gas. Do not use this for \
            \ any live user-facing quote/execution path — those must keep using \
            \ <URC_HopperActive> so users still get the best available route. \
            \ #65fL Phase 8a fix: this was the one Hopper variant left completely \
            \ untouched by #65bL Phases 1-7 — no PathCache check, no shared \
            \ raw-graph. Now checks SWPT|PathCache first (URC_ReadPathCacheFresh), \
            \ identically to URCx_Hopper's own Phase 1 pattern — on a fresh hit, \
            \ skips the live BFS entirely and uses the cached node-path as the \
            \ sole candidate, safe for the same reason Phase 1 established (the \
            \ real per-hop edge is always re-derived live downstream in \
            \ URCx_HopperForNodes against the <swpairs> active-only universe, \
            \ regardless of where the node-path came from). Especially valuable \
            \ here since this targets exactly the pair a bundle-assisted swap's \
            \ own <boost-path> already warms in this same cache (#65bL Phase 6) — \
            \ a self-searching swap running after one for the same input token \
            \ gets this for free. On a miss, falls through to the unchanged live \
            \ search."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPT:module{SwapTracerV3} SWPT)
                (swpairs:[string] (ref-SWP::URC_ActiveSwpairs))
                (cached:object{SwapTracerV3.PathCacheRow}
                    (ref-SWPT::URC_ReadPathCacheFresh hopper-input-id hopper-output-id)
                )
                (cached-nodes:[string] (at "nodes" cached))
                (nodes:[string]
                    (if (!= cached-nodes [BAR])
                        cached-nodes
                        (ref-SWPT::URC_ComputeGraphPath hopper-input-id hopper-output-id swpairs)
                    )
                )
            )
            (URCx_HopperForNodes nodes hopper-input-amount swpairs)
        )
    )
    (defun URC_ValidatePathActive:bool (nodes:[string] edges:[string])
        @doc "#34 Phase 7: active-required validation for the A->B execution route — \
            \ SWPT's exists-only structural check (real edges, correctly connected, \
            \ within the depth cap) PLUS every edge must be <can-swap>=true, since this \
            \ route is actually walked with real user funds, unlike the boost/stoa-value \
            \ pricing paths (SWPT::URC_ValidatePathStructure alone, exists-only, is \
            \ sufficient for those — see the P3.0 split in the exhaustive-path-search \
            \ HANDOFF doc)."
        (let
            (
                (ref-SWPT:module{SwapTracerV3} SWPT)
            )
            (if (not (ref-SWPT::URC_ValidatePathStructure nodes edges))
                false
                (if (= (length edges) 0)
                    true
                    (let
                        (
                            (ref-SWP:module{SwapperV4} SWP)
                        )
                        (fold
                            (lambda (acc:bool e:string) (and acc (ref-SWP::UR_CanSwap e)))
                            true
                            edges
                        )
                    )
                )
            )
        )
    )
    (defun URCx_BestEdgeOf:string (ia:decimal i:string o:string edges:[string])
        @doc "Shared best-edge-selection core for <URC_BestEdge>/<URC_BestEdgeFiltered> \
            \ — identical in every respect except which <edges> candidate list is \
            \ passed in. Internal only, not on the interface."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (svl:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (URCv_Swap (at idx edges) (ref-U|SWP::UDC_DirectSwapInputData [i] [ia] o) false)
                            )
                        )
                        []
                        (enumerate 0 (- (length edges) 1))
                    )
                )
                ;;C1 fix: keep the index with the LARGER output (argmax), not smaller (argmin) — "best"
                ;;edge for a fixed input means most output, matching URC_Hopper's own documented intent.
                (sp:integer
                    (fold
                        (lambda
                            (acc:integer idx:integer)
                            (if (= idx 0)
                                acc
                                (if (> (at idx svl) (at acc svl))
                                    idx
                                    acc
                                )
                            )
                        )
                        0
                        (enumerate 0 (- (length svl) 1))
                    )
                )
            )
            (at sp edges)
        )
    )
    (defun URC_BestEdge:string (ia:decimal i:string o:string)
        @doc "Best edge across ALL swpairs connecting <i>/<o>, including disabled \
            \ ones — matches <URC_Hopper>'s full-universe scope. Live \
            \ swap-execution callers should use <URC_BestEdgeFiltered> instead."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list.
                (ref-SWPT:module{SwapTracerV3} SWPT)
            )
            (URCx_BestEdgeOf ia i o (ref-SWPT::URC_Edges i o))
        )
    )
    (defun URC_BestEdgeFiltered:string (ia:decimal i:string o:string swpairs:[string])
        @doc "Best edge restricted to swpairs also present in <swpairs> — used by \
            \ <URCx_Hopper> so a disabled parallel pool between the same token \
            \ pair is never selected as the executed hop, even when an active \
            \ parallel pool exists between the same two tokens (#19H)."
        (let
            (
                ;;#21H: SWPT no longer needs a principal list.
                (ref-SWPT:module{SwapTracerV3} SWPT)
            )
            (URCx_BestEdgeOf ia i o (ref-SWPT::URC_EdgesActive i o swpairs))
        )
    )
    ;;Value Computations
    (defun URC_SingleSSTOAWorthWSTOA:decimal ()
        @doc "#65fL Phase 8b: SSTOA's own worth in WSTOA terms, per unit — the ATS \
            \ autostake index (the 'liquid staking conversion, backwards'), zero \
            \ graph search. Extracted as its own function, mirroring \
            \ <URC_SingleOuroWorthWSTOA>, so <URCx_PrimordialValueAndOuroSupply> can \
            \ call it directly instead of going through <URC_SingleWorthWSTOA>/ \
            \ <URC_WorthWSTOA> — routing through those would create a genuine STATIC \
            \ recursive cycle at compile time (URC_WorthWSTOA's own id==OURO branch \
            \ calls into URCx_PrimordialValueAndOuroSupply), caught by Pact 5's own \
            \ cycle detector when this was first wired that way — even though the \
            \ actual runtime call chain (always SSTOA's own id here, which never \
            \ re-enters the OURO branch) would never truly recurse. <URC_WorthWSTOA>'s \
            \ own id==SSTOA branch also uses this now, instead of its own inline copy \
            \ of the same lookup."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (ats-pairs-with-sstoa-id:[string] (ref-DPTF::UR_RewardBearingToken sstoa))
                (stoaliquindex:string (at 0 ats-pairs-with-sstoa-id))
            )
            (ref-ATS::URC_Index stoaliquindex)
        )
    )
    (defun URCx_PrimordialValueAndOuroSupply:[decimal] ()
        @doc "#65fL Phase 8b: shared core extracted from <URC_OuroPrimordialPrice> — \
            \ [<primordial-wstoa-value> <ouro-supply>], where <primordial-wstoa-value> \
            \ is the primordial pool's total value in WSTOA-equivalent terms (native \
            \ WSTOA reserve plus the SSTOA reserve converted via its own cheap \
            \ index-based shortcut, URC_SingleSSTOAWorthWSTOA — zero graph search either \
            \ way). \
            \ #73C fix, scope note: originally shared by BOTH <URC_OuroPrimordialPrice> \
            \ (dollar-denominated) and <URC_SingleOuroWorthWSTOA> (WSTOA-denominated) — \
            \ the WSTOA-denominated side moved to a real 1-unit weighted-pool swap \
            \ instead (see <URC_SingleOuroWorthWSTOA>'s own doc for why: this helper's \
            \ ratio ignores the primordial pool's own weights, undervaluing OURO). \
            \ <URC_OuroPrimordialPrice> is the only remaining caller. Flagged, not \
            \ fixed here (out of scope — the WSTOA-denominated case is what surfaced \
            \ this): <URC_OuroPrimordialPrice>'s own final division likely has the \
            \ identical weight-omission issue, unverified, left for a follow-up. \
            \ Internal only, not on the public interface."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (primordial:string (ref-SWP::UR_PrimordialPool))
                (pts:[decimal] (ref-SWP::UR_PoolTokenSupplies primordial))
                ;;
                (sstoa:string (ref-DALOS::UR_SilverStoaID))
                (sstoa-supply:decimal (at 0 pts))
                (ouro-supply:decimal (at 1 pts))
                (wstoa-supply:decimal (at 2 pts))
                ;;
                (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                (sstoa-in-wstoa:decimal (URC_SingleSSTOAWorthWSTOA))
                (sstoa-in-wstoa-value (floor (* sstoa-supply sstoa-in-wstoa) sstoa-prec))
                (primordial-wstoa-value:decimal (+ wstoa-supply sstoa-in-wstoa-value))
            )
            [primordial-wstoa-value ouro-supply]
        )
    )
    (defun URC_OuroPrimordialPrice:decimal ()
        @doc "OURO's price in dollars. \
            \ #73C-TWIN FIX (2026-09-17): this used to compute its own flat reserve ratio -- \
            \ (primordial-wstoa-value * stoa-pid) / ouro-supply -- which READ NO WEIGHT and so \
            \ silently assumed the primordial pool was equal-weighted. It cannot be: \
            \ SWP|C>DEFINE-PRIMORDIAL-POOL enforces a WEIGHTED pool of exactly three tokens, and \
            \ genesis ships [SSTOA 0.3, OURO 0.5, WSTOA 0.2]. Measured before the fix, with \
            \ reserves held constant and weights varied through the live C_ModifyWeights path, \
            \ the old output was BIT-IDENTICAL across [0.4 0.4 0.2], [0.2 0.6 0.2] and genesis \
            \ [0.3 0.5 0.2] -- it did not move one digit across three weightings of the pool it \
            \ prices. Error at genesis weights: -38.65%, reproducing #73C's independently \
            \ measured ~38% on the WSTOA twin, which is the same bug this is the twin of. \
            \ It reached the OURO oracle write, DEMIPAD launchpad payments and the Explorer. \
            \ The fix DELEGATES rather than re-deriving: URC_TokenDollarPrice -> \
            \ URC_SingleWorthWSTOA -> URC_WorthWSTOA's OURO short-circuit -> \
            \ URC_SingleOuroWorthWSTOA, a real 1-unit weighted swap through UC_ComputeWP -- the \
            \ only math in the family that consumes (at \"weights\" drsi). That path is #73C's \
            \ own repair, already live and already proven, so this carries no new arithmetic. \
            \ See DEFECT-LEDGER 8.1."
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
            )
            (URC_TokenDollarPrice (at "gas-source-id" ids) stoa-pid)
        )
    )
    (defun URC_SingleOuroWorthWSTOA:decimal (ouro:string wstoa:string)
        @doc "#73C fix: OURO's own worth in WSTOA, per unit — a real 1-unit swap \
            \ through the primordial pool's own weighted-pool math (URC_W-Swap, the \
            \ exact same UC_ComputeWP invariant a live swap would use), instead of the \
            \ old hand-rolled <primordial-wstoa-value / ouro-supply> ratio. The old \
            \ formula was mathematically wrong for THIS pool, not just approximate: it \
            \ implicitly assumed every token in the primordial pool carries equal \
            \ weight, but the pool is genuinely weighted (SSTOA 0.3 / OURO 0.5 / WSTOA \
            \ 0.2 at issuance) — a weighted pool's real exchange rate depends on \
            \ reserve/weight ratios, not a flat sum-of-other-reserves-over-own-reserve \
            \ ratio. Confirmed live: the old formula returned 91.95 WSTOA for 100 OURO \
            \ against real reserves [sstoa=3200.0 ouro=10002.0 wstoa=5997.009] and \
            \ weights [0.3 0.5 0.2], while the weighted spot formula \
            \ ((wstoa/wstoa_w)/(ouro/ouro_w)) gives ~149.9, matching the pre-existing \
            \ graph-search fallback's 147.31 (the small remainder being real, correctly \
            \ modeled AMM slippage from an actual ~1%-of-reserves trade — see \
            \ URC_WorthWSTOA's own doc for why THAT part is now handled at the caller, \
            \ not here). Still zero graph search: OURO and WSTOA are direct pool \
            \ siblings in the SAME primordial pool, this is one single-hop direct-pool \
            \ swap computation, not a BFS route search. <ouro>/<wstoa> passed in by the \
            \ caller (not self-fetched) — every real caller already holds them via \
            \ DALOS::UR_CanonicalStoaIds, so this adds no new read."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-SWP:module{SwapperV4} SWP)
                (primordial:string (ref-SWP::UR_PrimordialPool))
            )
            (URC_W-Swap primordial (ref-U|SWP::UDC_DirectSwapInputData [ouro] [1.0] wstoa))
        )
    )
    (defun URC_TokenDollarPrice (id:string stoa-pid:decimal)
        @doc "Retrieves Token Price in Dollars, via DIA Oracle that outputs STOA Price"
        ;;<stoa-pid> or <stoa-price-in-dollars> can be retrieved prior to the function call with:
        ;;(at "value" (n_bfb76eab37bf8c84359d6552a1d96a309e030b71.dia-oracle.get-value "STOA/USD"))
        ;;This function is structured like this, to allow price retrieval from any source.
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (id-in-stoa:decimal (URC_SingleWorthWSTOA id))
                (id-precision:integer (ref-DPTF::UR_Decimals id))
            )
            (floor (* id-in-stoa stoa-pid) id-precision)
        )
    )
    (defun URC_SingleWorthWSTOA (id:string)
        (URC_WorthWSTOA id 1.0)
    )
    (defun URC_WorthWSTOA (id:string amount:decimal)
        @doc "#65fL Phase 8b fix: added an id==OURO short-circuit (URC_SingleOuroWorthWSTOA, \
            \ straight off the primordial pool's own reserves), zero graph search — same \
            \ shape as the pre-existing id==SSTOA short-circuit below. WSTOA/SSTOA/OURO are the \
            \ only tokens with a canonical zero-search pricing mechanism; every other id \
            \ still falls through to the graph-search branch. The OURO shortcut only fires \
            \ when a primordial pool has actually been defined (SWP::UR_PrimordialPool != \
            \ BAR, checked via a short-circuited `and` so this extra read only happens for \
            \ id==OURO, never for any other id) — SAFETY, not a guess: caught live, a real \
            \ pre-bootstrap crash reading an unset primordial pool during that very pool's \
            \ OWN issuance (UEV_Issue's spawn-limit check prices the first token before any \
            \ primordial pool could exist yet). Falls through to the exact original \
            \ graph-search behavior when unsafe — matches pre-Phase-8b behavior byte for \
            \ byte in that edge case, not a new approximation. Fetches WSTOA/SSTOA/OURO via \
            \ DALOS::UR_CanonicalStoaIds — ONE read for all 3, instead of 3 independent \
            \ reads of the same DALOS row — caught live: adding a naive 3rd standalone \
            \ UR_OuroborosID call regressed the P0.5/P2-scale worst-case checkpoints \
            \ (measured +928 gas) despite neither pool ever pricing OURO/SSTOA in that \
            \ scenario, isolated via git-stash bisection before this fix, not guessed. \
            \ #73C fix: the graph-search fallback below now prices ONE unit and scales \
            \ linearly, instead of simulating a swap of the full <amount> — see the \
            \ fallback branch's own comment for why (depth-skew: 'worth of N tokens' is \
            \ not N times 'worth of 1 token' once a simulated swap eats meaningfully into \
            \ pool depth, and URC_PoolValue's own caller passes an ENTIRE pool reserve as \
            \ <amount>, not a small swap-sized figure)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-SWP:module{SwapperV4} SWP)
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
                (wstoa:string (at "wrapped-stoa-id" ids))
                (sstoa:string (at "silver-stoa-id" ids))
                (ouro:string (at "gas-source-id" ids))
            )
            (if (= id wstoa)
                amount
                (if (= id sstoa)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (index-value:decimal (URC_SingleSSTOAWorthWSTOA))
                            (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                        )
                        (floor (* amount index-value) sstoa-prec)
                    )
                    (if (and (= id ouro) (!= (ref-SWP::UR_PrimordialPool) BAR))
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ouro-worth-per-unit:decimal (URC_SingleOuroWorthWSTOA ouro wstoa))
                                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro))
                            )
                            (floor (* amount ouro-worth-per-unit) ouro-prec)
                        )
                        ;;#73C fix: price ONE unit via the real route (URC_Hopper amount=1.0,
                        ;;not <amount>), then scale linearly — never simulate a swap of the
                        ;;full requested <amount>, since a real swap of a large amount eats
                        ;;into pool depth (AMM slippage), so "worth of N" would come out
                        ;;systematically LESS than N times "worth of 1," most severely
                        ;;exactly where this function is actually called from
                        ;;(URC_PoolValue prices a pool's ENTIRE first-token reserve this
                        ;;way). "1 unit" is an accepted, unavoidable approximation of the
                        ;;true marginal/instantaneous spot price (an exact closed-form
                        ;;derivative isn't implemented anywhere in this codebase and isn't
                        ;;worth building for this) — computing at a smaller-than-1 amount
                        ;;isn't meaningful once atomic-unit precision is reached.
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (h-obj:object{SwapperIssueV4.Hopper} (URC_Hopper id wstoa 1.0))
                                (ovs:[decimal] (at "output-values" h-obj))
                                (per-unit-worth:decimal (if (= (length ovs) 0) 0.0 (at 0 (take -1 ovs))))
                                (id-prec:integer (ref-DPTF::UR_Decimals id))
                            )
                            (floor (* amount per-unit-worth) id-prec)
                        )
                    )
                )
            )
        )
    )
    (defun URC_WorthWSTOAFromRaw (id:string amount:decimal raw-graph:[object{SwapTracerV3.RawGraphNode}])
        @doc "#65bL Phase 4 fix: <URC_WorthWSTOA>, sourcing any graph search it needs \
            \ via an ALREADY-FETCHED <raw-graph> (<URC_HopperFromRaw>) instead of a \
            \ fresh self-fetch — see <URCx_HopperFromRaw>'s own doc for the full \
            \ rationale (repricing-loop sharing). The WSTOA/SSTOA short-circuit branches \
            \ never needed a graph search to begin with and stay unchanged. \
            \ #65fL Phase 8b fix: added the same id==OURO short-circuit \
            \ <URC_WorthWSTOA> gained (URC_SingleOuroWorthWSTOA) — also never needed a \
            \ graph search. Same pre-bootstrap safety guard too: only fires when \
            \ a primordial pool has actually been defined, see <URC_WorthWSTOA>'s \
            \ own doc for the crash this closes."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-SWP:module{SwapperV4} SWP)
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
                (wstoa:string (at "wrapped-stoa-id" ids))
                (sstoa:string (at "silver-stoa-id" ids))
                (ouro:string (at "gas-source-id" ids))
            )
            (if (= id wstoa)
                amount
                (if (= id sstoa)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (index-value:decimal (URC_SingleSSTOAWorthWSTOA))
                            (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                        )
                        (floor (* amount index-value) sstoa-prec)
                    )
                    (if (and (= id ouro) (!= (ref-SWP::UR_PrimordialPool) BAR))
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ouro-worth-per-unit:decimal (URC_SingleOuroWorthWSTOA ouro wstoa))
                                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro))
                            )
                            (floor (* amount ouro-worth-per-unit) ouro-prec)
                        )
                        ;;#73C fix: price ONE unit, scale linearly — see URC_WorthWSTOA's
                        ;;own comment on this same branch for the full rationale.
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (h-obj:object{SwapperIssueV4.Hopper} (URC_HopperFromRaw id wstoa 1.0 raw-graph))
                                (ovs:[decimal] (at "output-values" h-obj))
                                (per-unit-worth:decimal (if (= (length ovs) 0) 0.0 (at 0 (take -1 ovs))))
                                (id-prec:integer (ref-DPTF::UR_Decimals id))
                            )
                            (floor (* amount per-unit-worth) id-prec)
                        )
                    )
                )
            )
        )
    )
    (defun URC_WorthWSTOAFromGraph (id:string amount:decimal graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65bL Phase 7 fix: <URC_WorthWSTOA>, sourcing any graph search it needs \
            \ via an ALREADY-BUILT <graph> (<URC_HopperFromGraph>) instead of \
            \ rebuilding it from <raw-graph> per call — see \
            \ <URCx_HopperFromGraph>'s own doc for the full rationale (repricing- \
            \ loop graph-build sharing). The WSTOA/SSTOA short-circuit branches never \
            \ needed a graph search to begin with and stay unchanged. \
            \ #65fL Phase 8b fix: added the same id==OURO short-circuit \
            \ <URC_WorthWSTOA> gained (URC_SingleOuroWorthWSTOA) — also never needed a \
            \ graph search. Same pre-bootstrap safety guard too: only fires when \
            \ a primordial pool has actually been defined, see <URC_WorthWSTOA>'s \
            \ own doc for the crash this closes."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-SWP:module{SwapperV4} SWP)
                (ids:object{OuronetDalosV2.CanonicalStoaIds} (ref-DALOS::UR_CanonicalStoaIds))
                (wstoa:string (at "wrapped-stoa-id" ids))
                (sstoa:string (at "silver-stoa-id" ids))
                (ouro:string (at "gas-source-id" ids))
            )
            (if (= id wstoa)
                amount
                (if (= id sstoa)
                    (let
                        (
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (index-value:decimal (URC_SingleSSTOAWorthWSTOA))
                            (sstoa-prec:integer (ref-DPTF::UR_Decimals sstoa))
                        )
                        (floor (* amount index-value) sstoa-prec)
                    )
                    (if (and (= id ouro) (!= (ref-SWP::UR_PrimordialPool) BAR))
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ouro-worth-per-unit:decimal (URC_SingleOuroWorthWSTOA ouro wstoa))
                                (ouro-prec:integer (ref-DPTF::UR_Decimals ouro))
                            )
                            (floor (* amount ouro-worth-per-unit) ouro-prec)
                        )
                        ;;#73C fix: price ONE unit, scale linearly — see URC_WorthWSTOA's
                        ;;own comment on this same branch for the full rationale.
                        (let
                            (
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (h-obj:object{SwapperIssueV4.Hopper} (URC_HopperFromGraph id wstoa 1.0 graph))
                                (ovs:[decimal] (at "output-values" h-obj))
                                (per-unit-worth:decimal (if (= (length ovs) 0) 0.0 (at 0 (take -1 ovs))))
                                (id-prec:integer (ref-DPTF::UR_Decimals id))
                            )
                            (floor (* amount per-unit-worth) id-prec)
                        )
                    )
                )
            )
        )
    )
    (defun URC_PoolValue:[decimal] (swpair:string)
        @doc "Outputs the Pool Value in WSTOA. \
            \ If the Pool is empty, even though its value is technically zero, \
            \ The Value of the Genesis Initiation is outputed \
            \ PoolValue includes two decimal values: \
            \ 1st Value: Total Value of the Pool in WSTOA \
            \ 2nd Value: Value of 1 LP Token in WSTOA"
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (lp-supply:decimal
                    (if (= current-lp-supply 0.0)
                        10000000.0
                        current-lp-supply
                    )
                )
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                ;;
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                (first-worth:decimal (URC_WorthWSTOA first-token first-token-supply))
                ;;
                (pool-worth:decimal
                    (if (or (= pool-type "S") (= pool-type "P"))
                        (floor (* (dec how-many) first-worth) first-token-precision)
                        (floor (/ first-worth first-weigth) first-token-precision)
                    )
                )
                (lp-worth:decimal
                    (floor (/ pool-worth lp-supply) lp-prec)
                )
            )
            [pool-worth lp-worth]
        )
    )
    (defun URC_PoolValueFromRaw:[decimal] (swpair:string raw-graph:[object{SwapTracerV3.RawGraphNode}])
        @doc "#65bL Phase 4 fix: <URC_PoolValue>, sourcing its <URC_WorthWSTOA> call via \
            \ an ALREADY-FETCHED <raw-graph> (<URC_WorthWSTOAFromRaw>) instead of a \
            \ fresh self-fetch. Built for the STOA-repricing loop \
            \ (TS01-C3::SWP|CC_SmartSwap{With,No}Slippage, one URC_PoolValue call per \
            \ distinct pool a self-searching swap touched) — every call in that loop \
            \ now shares ONE raw-graph fetch instead of each one independently \
            \ re-reading and rebuilding the whole graph, same shape of win Phase 2 \
            \ already proved for a single Hopper call's own best-of-3 attempts, \
            \ extended here across the WHOLE loop's separate calls. Everything else \
            \ (genesis-vs-live supply/weight selection, pool-worth/lp-worth formulas) \
            \ is byte-for-byte identical to <URC_PoolValue> — only the one \
            \ <first-worth> line changes."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (lp-supply:decimal
                    (if (= current-lp-supply 0.0)
                        10000000.0
                        current-lp-supply
                    )
                )
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                ;;
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                (first-worth:decimal (URC_WorthWSTOAFromRaw first-token first-token-supply raw-graph))
                ;;
                (pool-worth:decimal
                    (if (or (= pool-type "S") (= pool-type "P"))
                        (floor (* (dec how-many) first-worth) first-token-precision)
                        (floor (/ first-worth first-weigth) first-token-precision)
                    )
                )
                (lp-worth:decimal
                    (floor (/ pool-worth lp-supply) lp-prec)
                )
            )
            [pool-worth lp-worth]
        )
    )
    (defun URC_PoolValueFromGraph:[decimal] (swpair:string graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65bL Phase 7 fix: <URC_PoolValue>, sourcing its <URC_WorthWSTOA> call via \
            \ an ALREADY-BUILT <graph> (<URC_WorthWSTOAFromGraph>) instead of \
            \ rebuilding it from <raw-graph> per call. Built for the STOA-repricing \
            \ loop (TS01-C3::SWP|CC_SmartSwap{With,No}Slippage) — every call in that \
            \ loop already shared ONE raw-graph fetch (Phase 4); this shares the \
            \ downstream graph-BUILD too (SWPT::UC_MakeGraphFromRaw, a linear scan \
            \ per node in the whole topology, previously rebuilt identically on \
            \ every one of the loop's N distinct-first-token queries despite always \
            \ producing byte-identical output for the same <raw-graph>/<swpairs> \
            \ universe). Everything else (genesis-vs-live supply/weight selection, \
            \ pool-worth/lp-worth formulas) is byte-for-byte identical to \
            \ <URC_PoolValue>/<URC_PoolValueFromRaw> — only the one <first-worth> \
            \ line changes."
        (let
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (current-lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (lp-supply:decimal
                    (if (= current-lp-supply 0.0)
                        10000000.0
                        current-lp-supply
                    )
                )
                (pool-token-supplies:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_PoolGenesisSupplies swpair)
                        (ref-SWP::UR_PoolTokenSupplies swpair)
                    )
                )
                (w:[decimal]
                    (if (= current-lp-supply 0.0)
                        (ref-SWP::UR_GenesisWeigths swpair)
                        (ref-SWP::UR_Weigths swpair)
                    )
                )
                ;;
                (pool-type:string (ref-U|SWP::UC_PoolType swpair))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (how-many:integer (length pool-tokens))
                (lp-prec:integer (ref-DPTF::UR_Decimals (ref-SWP::UR_TokenLP swpair)))
                ;;
                (first-token:string (at 0 pool-tokens))
                (first-token-supply:decimal (at 0 pool-token-supplies))
                (first-token-precision:integer (ref-DPTF::UR_Decimals first-token))
                (first-weigth:decimal (at 0 w))
                (first-worth:decimal (URC_WorthWSTOAFromGraph first-token first-token-supply graph))
                ;;
                (pool-worth:decimal
                    (if (or (= pool-type "S") (= pool-type "P"))
                        (floor (* (dec how-many) first-worth) first-token-precision)
                        (floor (/ first-worth first-weigth) first-token-precision)
                    )
                )
                (lp-worth:decimal
                    (floor (/ pool-worth lp-supply) lp-prec)
                )
            )
            [pool-worth lp-worth]
        )
    )
    (defun URC_DirectRefillAmounts:[decimal] (swpair:string ids:[string] amounts:[decimal])
        @doc "Refill incomplete amount values with zeros, to create an amount list equal to the <swpair> token number"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (let
                        (
                            (pt:string (at idx pool-tokens))
                            (spt:[integer] (ref-U|LST::UC_Search ids pt))
                            (pos:integer
                                (if (> (length spt) 0)
                                    (at 0 spt)
                                    -1
                                )
                            )
                            (value:decimal
                                (if (= pos -1)
                                    0.0
                                    (at pos amounts)
                                )
                            )
                        )
                        (ref-U|LST::UC_AppL acc value)
                    )
                )
                []
                (enumerate 0 (- (length pool-tokens) 1))
            )
        )
    )
    (defun URC_IndirectRefillAmounts:[decimal] (X:[decimal] positions:[integer] amounts:[decimal])
        @doc "Refill incomplete amount values with zeros, to create an amount equal to the <X> positions number"
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (let
                        (
                            (spt:[integer] (ref-U|LST::UC_Search positions idx))
                            (pos:integer
                                (if (> (length spt) 0)
                                    (at 0 spt)
                                    -1
                                )
                            )
                            (value:decimal
                                (if (= pos -1)
                                    0.0
                                    (at pos amounts)
                                )
                            )
                        )
                        (ref-U|LST::UC_AppL acc value)
                    )
                )
                []
                (enumerate 0 (- (length X) 1))
            )
        )
    )
    (defun URC_TrimIdsWithZeroAmounts:[string] (swpair:string input-amounts:[decimal])
        @doc "From a complete list of input amounts, also containing zeroes, \
            \ creates a list of Pool Token IDs for the amounts greater than zero."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (zero-positions:[integer] (ref-U|LST::UC_Search input-amounts 0.0))
            )
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (let
                        (
                            (iz-index-zero:bool (contains idx zero-positions))
                        )
                        (if (not iz-index-zero)
                            (ref-U|LST::UC_AppL
                                acc
                                (at idx pool-tokens)
                            )
                            acc
                        )
                    )
                )
                []
                (enumerate 0 (- (length input-amounts) 1))
            )
        )
    )
    (defun URCi_IssueStoa:decimal ()
        @doc "STOA leg of a SINGLE-TX swap-pair issue. Read-only twin of the <stoa-costs> that \
            \ C_Issue hands to XE_CollectStoa, so the exec and its INFO_ previews are sourced from \
            \ one place and cannot drift. \
            \ NOTE this is deliberately NOT the same figure as the DEFPACT pool-issue path: \
            \ MTX-SWP charges (+ UsagePrice \"dptf\" \"swp\") while this charges \
            \ UC_StoaPrice \"issue-swp-pair\". The two paths really do cost different amounts, and \
            \ all six INFO_SWP|Issue* previews used to quote the MTX figure for both -- over-quoting \
            \ the single-tx path. Mirrors ATS::URCi_IssueStoa. \
            \ Pinned by `Stage_01/[6.2+3]_DPTF-SWP_Issuance-Only.repl <<SWP-ISSUE-INFO>>`."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UC_StoaPrice "issue-swp-pair")
        )
    )
    (defun URC_IssuePoolIgnis:decimal ()
        @doc "The ONE-leg IGNIS total the MULTI-STEP (defpact) pool issuance bills in \
            \ MTX-SWP::MTX|C_Issue step 2. Lives here, beside URCi_Issue, so the preview and the \
            \ exec read the SAME number from the SAME place: MTX-SWP deploys after SWPI, so the \
            \ exec can call down to this, and INFO_SWP|Issue*Pool previews through URCi_IssuePool. \
            \ ADDED 2026-09-14 with the GS-04 repair -- see URCi_IssuePool."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (fold (+) 0.0
                [
                    (ref-IGNIS::UC_IgnisDeter "issue-swp-pair")
                    (ref-IGNIS::UC_IgnisLeg "tier-token-issue")
                    (ref-IGNIS::UC_IgnisLeg "tier-biggest")
                    (ref-IGNIS::UC_IgnisLeg "tier-smallest")
                ]
            )
        )
    )
    (defun URCi_IssuePool:object{IgnisCollectorV3.OutputCumulator}
        (account:string pool-tokens:[object{SwapperV4.PoolTokens}])
        @doc "Cost preview for the MULTI-STEP pool issuance -- MTX-SWP::MTX|C_Issue -- as opposed \
            \ to URCi_Issue below, which previews the SINGLE-TX SWPI::C_Issue. TWO legs, matching \
            \ that step's concat exactly: the folded one-leg total (URC_IssuePoolIgnis) and the \
            \ account->SWP pool-token multi-transfer. \
            \ GS-04 (2026-09-14): the three INFO_SWP|Issue*Pool previews used to route through \
            \ URCi_Issue, which is tuned to the single-tx exec -- FOUR non-transfer legs totalling \
            \ 6158 against the defpact's ONE leg of 5506, an over-quote of 652. The leg COUNT \
            \ mattered independently: UDC_PrimeIgnisCumulator discounts and quarter-splits PER LEG, \
            \ so even equal totals could round apart. The tell was a dead `op-key` parameter, still \
            \ in URCi_Issue's signature and used nowhere in its body -- one reader serving two \
            \ executions that bill differently, the same shape as the red team's RT-A-001. \
            \ Measured, not reasoned about, at modules/DEFPACT-BILLING.repl <<DPB-02>>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (URC_IssuePoolIgnis) SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                    )
                    (ref-TFT::URCi_MultiTransferCumulator
                        pool-token-ids account SWP|SC_NAME pool-token-amounts
                    )
                ]
                []
            )
        )
    )
    (defun URCi_Issue:object{IgnisCollectorV3.OutputCumulator}
        (account:string pool-tokens:[object{SwapperV4.PoolTokens}])
        @doc "Cost preview for the SINGLE-TX C_Issue's IGNIS cumulator (the STOA dptf+swp usage prices are \
            \ billed separately). Five legs, matching C_Issue's concat: \
            \ ico1 = LP-token issue gas (URCi_IssueGas 1 on SWP); \
            \ ico2 = the account->SWP pool-token multi-transfer (EXISTING tokens, real reader); \
            \ ico3 = the genesis LP mint (origin -> biggest on SWP); \
            \ ico4 = the SWP->account LP transfer-out (fresh LP is fee-toggle-off => class-1 \
            \        Simple => smallest); \
            \ ico5 = the flat swp-issue gas. \
            \ ico3/ico4 are reconstructed from XE_IssueLP's FIXED LP invariants (issued via \
            \ XB_IssueFree with fee-toggle off, so a fresh LP always transfers as class 1) rather \
            \ than calling URCi_Mint/URCi_Transfer, because the LP id is a block-hash write product \
            \ that does not exist at preview time. Every trigger reduces to the GLOBAL \
            \ URC_IsVirtualGasZero: URC_IsVirtualGasZeroAbsolutely on a non-gas id is global, \
            \ SWP is not in GAS_EXCEPTION, and <account> is a normal (non-exempt) account. \
            \ Output ([swpair token-lp]) is empty here (write products)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (swp-sc:string SWP|SC_NAME)
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator (ref-DPTF::URCi_IssueGas 1) swp-sc trigger [])
                    (ref-TFT::URCi_MultiTransferCumulator pool-token-ids account swp-sc pool-token-amounts)
                    ;;ico3 — the genesis LP mint. The LP id is a block-hash write product that does
                    ;;not exist at preview time, so we cannot call URCi_Mint on it; we charge the
                    ;;SAME PRICE it would return. This MUST track DPTF|C_Mint: it was a hardcoded
                    ;;"tier-biggest" (5) and silently desynced when C_Mint was re-priced to its real
                    ;;computation (87), leaving the preview 82 BELOW what the exec charges.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "DPTF|C_Mint" "usage") swp-sc trigger [])
                    ;;ico4 — the SWP->account LP transfer-out. A fresh LP is fee-toggle-off, so it
                    ;;always transfers as class-1 Simple = smallest.
                    (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisLeg "tier-smallest") swp-sc trigger [])
                    ;;ico5 — MUST equal what C_Issue bills, which is the DETERRENCE ALONE. Using
                    ;;UC_IgnisPrice here added the op's 35-point component cost to the preview only,
                    ;;overstating it by 35. A preview's job is to equal the exec, not to be the
                    ;;price we think the exec ought to charge.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisDeter "issue-swp-pair") swp-sc trigger [])
                ]
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_SwapData 
        (swpair:string dsid:object{UtilitySwpV2.DirectSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (input-ids:[string] (at "input-ids" dsid))
                (input-amounts:[decimal] (at "input-amounts" dsid))
                (output-id:string (at "output-id" dsid))
                ;;
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (l1:integer (length input-ids))
                (l2:integer (length input-amounts))
                (l3:integer (length pool-tokens))
                (lengths:[integer] [l1 l2])
                (iz-on-pool:bool (ref-SWP::UEV_CheckAgainst input-ids pool-tokens))
                (t1:bool (contains output-id input-ids))
                (t2:bool (contains output-id pool-tokens))
            )
            (ref-U|INT::UEV_UniformList lengths)
            (enforce iz-on-pool "Input Tokens are not part of the pool")
            (enforce (not t1) "Output-ID cannot be within the Input-IDs")
            (enforce t2 "OutputID is not part of Swpair Tokens")
            (enforce (and (>= l2 1) (< l2 l3)) "Incorrect amount of swap Tokens")
        )
    )
    (defun UEV_InverseSwapData 
        (swpair:string rsid:object{UtilitySwpV2.ReverseSwapInputData})
        (let
            (
                ;;Unwrap Object Data
                (output-id:string (at "output-id" rsid))
                (output-amount:decimal (at "output-amount" rsid))
                (input-id:string (at "input-id" rsid))
                ;;
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (t1:bool (contains input-id pool-tokens))
                (t2:bool (contains output-id pool-tokens))
            )
            (enforce (and t1 t2) "Invalid Pool Tokens")
            (ref-DPTF::UEV_Amount output-id output-amount)
        )
    )
    (defun UEV_Issue
        (account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "#74 note (2026-08-29): deliberately does NOT enforce that <pool-tokens>' \
            \ token IDs are distinct — that protection already exists, composed for \
            \ free, one layer down. Both real issuance paths (this function, via \
            \ XI_IssueWrite's SWPI|C>ISSUE, and MTX-SWP's defpact issuance) collect the \
            \ caller's genesis deposits through the SAME shared XE_IssueWrite chokepoint \
            \ (Fix #22/M5), which calls TFT::C_MultiTransfer — and C_MultiTransfer's own \
            \ U|LST::UC_IzUnique check already rejects a repeated token ID in the \
            \ transfer list ('Unique Items Required, duplicate item found: <id>'), for \
            \ its own unrelated reason (a batched multi-transfer can't sensibly resolve \
            \ two different amounts for the same ID). Confirmed live, not assumed: \
            \ issuing [OURO, OURO, W1] as a nominal 3-token pool reverts cleanly \
            \ (whole-tx atomicity, no partial/orphaned pool state) at \
            \ TFT|C>MULTI-TRANSFER, before this function's own writes ever run. \
            \ Duplicating that check HERE would be pure redundant gas cost for a \
            \ property a composed dependency already guarantees on every real call \
            \ path — the same 'no single non-tier choke point exists, OR one already \
            \ does and it's downstream' reasoning StoicSyntax's `v`-specialization rule \
            \ asks for before adding an intrinsic bounds guard (§6.1) applies in \
            \ reverse here: the choke point already exists, just not in this module."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (fee-precision:integer (ref-U|CT::CT_FEE_PRECISION))
                (principals:[string] (ref-SWP::UR_Principals))
                (l1:integer (length pool-tokens))
                (l2:integer (length weights))
                (ws:decimal (fold (+) 0.0 weights))
                (pt-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                (ptte:[string]
                    (if (= amp -1.0)
                        (drop 1 pt-ids)
                        pt-ids
                    )
                )
                (first-pool-token:string (at 0 pt-ids))
                (iz-principal:bool (contains first-pool-token principals))
                (contains-principals:bool
                    (fold
                        (lambda
                            (acc:bool idx:integer)
                            (or
                                acc
                                (contains (at idx pt-ids) principals)
                            )
                        )
                        false
                        (enumerate 0 (- (length pt-ids) 1))
                    )
                )
            )
            ;;Functions
            (ref-SWP::UEV_PoolFee fee-lp)
            (ref-SWP::UEV_New pt-ids weights amp)
            ;;Mappings
            (map
                (lambda
                    (id:string)
                    (ref-DPTF::CAP_Owner id)
                )
                ptte
            )
            ;;#11C fix: real per-weight enforce — the original computed this exact precision check via
            ;;`=` and discarded the result (same dead-map pattern independently flagged as H5/#23H;
            ;;fixing this map in place closes both, since it's the one place the check lives). Combines
            ;;the precision check with a >=0.1 floor per weight — rules out the 0.0-weight div-by-zero
            ;;this finding is about, matching the floor already enforced for post-issuance reweights
            ;;(SWP|S>WEIGHTS, C7/#8C fix) so issuance and modification agree on the same bound.
            (map
                (lambda
                    (w:decimal)
                    (enforce
                        (fold (and) true [(= (floor w fee-precision) w) (>= w 0.1)])
                        (format "Weight {} must respect fee precision and be at least 0.1" [w])
                    )
                )
                weights
            )

            ;;Enforcements
            (enforce (!= principals [BAR]) "Principals must be defined before a Swap Pair can be issued")
            (enforce (or (= amp -1.0) (>= amp 1.0)) "Invalid amp value")
            (enforce (and (>= l1 2) (<= l1 7)) "2 - 7 Tokens can be used to create a Swap Pair")
            (enforce (= l1 l2) "Number of weigths does not concide with the pool-tokens Number")
            (enforce-one
                "Invalid Weight Values"
                [
                    (enforce (= ws 1.0) "Weights must add to exactly 1.0")
                    (enforce (= ws (dec l1)) "Weights must all be 1.0")
                ]
            )
            ;;Ifs
            ;;On a W or P pool, first Pool Token must be a Principal Token
            (if (= amp -1.0)
                (enforce iz-principal "1st Token is not a Principal")
                true
            )
            ;;#34bM fix: was checking multi-hop BFS connectivity to SSTOA specifically
            ;;(SWPT::URC_Hopper, unbounded hop count, one hardcoded target token) —
            ;;owner's actual design: if a Stable Pool's first Token isn't itself a
            ;;Principal, it must be DIRECTLY pooled (one hop, an existing pool) with
            ;;ANY current Principal — not transitively connected through a chain of
            ;;non-Principal tokens, and not specifically SSTOA. Fixed to check the
            ;;first Token's direct neighbours (SWPT::URC_TokenNeighbours, one hop,
            ;;every existing pool regardless of type) against the full current
            ;;<principals> list.
            (if (and (> amp 0.0) (not contains-principals))
                (let
                    (
                        (ref-SWPT:module{SwapTracerV3} SWPT)
                        (neighbours:[string] (ref-SWPT::URC_TokenNeighbours first-pool-token))
                        (has-principal-neighbour:bool
                            (> (length (filter (lambda (n:string) (contains n principals)) neighbours)) 0)
                        )
                    )
                    (enforce
                        has-principal-neighbour
                        (format "{} is not directly pooled with any Principal token" [first-pool-token])
                    )
                )
                true
            )
            ;;If pool is not a principal pool, its initial liquidity must be worth at least <spawn-limit>
            (if (not p)
                (let
                    (
                        (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                        (pt-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                        (first-pool-token-amount:decimal (at 0 pt-amounts))
                        (prefix:string (ref-U|SWP::UC_Prefix weights amp))
                        (how-many:integer (length pool-tokens))
                        ;;
                        (first-worth:decimal (URC_WorthWSTOA first-pool-token first-pool-token-amount))
                        (pool-worth-with-input-tokens-in-wstoa:decimal
                            (if (or (= prefix "S") (= prefix "P"))
                                (* (dec how-many) first-worth)
                                (/ first-worth (at 0 weights))
                            )
                        )
                        (spawn-limit:decimal (ref-SWP::UR_SpawnLimit))
                    )
                    (enforce (>= pool-worth-with-input-tokens-in-wstoa spawn-limit) "More liquidity is needed to open a new pool!")
                )
                true
            )
            (format "Validation prior to pool creation executed succesfully {}" ["!"])
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          SWPI|XE>ISSUE-WRITE
    (defun XE_IssueWrite:list
        (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "#36M/M5 fix: forward-module entrypoint holding the ONE shared pool-issuance \
            \ write sequence — mint the LP token, register the pool, transfer pool tokens \
            \ in, mint genesis LP supply, transfer LP out to the account, register the \
            \ swap-tracer graph edge. Both SWPI::C_Issue (this module) and \
            \ MTX-SWP::MTX|C_Issue's Step 3 (a different module, reached via a \
            \ module{SwapperIssueV4} ref) call this instead of each independently \
            \ reimplementing it. \
            \ Returns [swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out] — \
            \ a wider list, not an IgnisCollectorV3.OutputCumulator (this codebase's XE_* \
            \ convention: the forward module's own C_ composes IGNIS, not this function). \
            \ C_Issue aggregates all four sub-cumulators into its own single billed \
            \ response; MTX|C_Issue's Step 3 only needs swpair/token-lp (it already billed \
            \ separately, in its own Step 2, before Step 3 ever runs) and ignores the rest."
        (P|UEV_IMC)
        (with-capability (SWPI|XE>ISSUE-WRITE account pool-tokens fee-lp weights amp p)
            (let
                (
                    (ref-BRD:module{BrandingV2} BRD)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;#21H: SWPT no longer needs a principal list.
                    (ref-SWPT:module{SwapTracerV3} SWPT)
                    (ref-SWP:module{SwapperV4} SWP)
                    (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                    (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                    (lp-name-ticker:[string] (ref-SWP::URC_LpComposer pool-tokens weights amp))
                    (ico-lp:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::XE_IssueLP (at 0 lp-name-ticker) (at 1 lp-name-ticker))
                    )
                    (token-lp:string (at 0 (at "output" ico-lp)))
                    (swpair:string (ref-SWP::XE_Issue account pool-tokens token-lp fee-lp weights amp p))
                )
                (ref-BRD::XE_Issue swpair)
                (let
                    (
                        (ico-transfer-in:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_MultiTransfer pool-token-ids account SWP|SC_NAME pool-token-amounts true)
                        )
                        (ico-mint:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPTF::C_Mint patron SWP|SC_NAME token-lp GENESIS_LP_SUPPLY true)
                        )
                        (ico-transfer-out:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer token-lp SWP|SC_NAME account GENESIS_LP_SUPPLY true)
                        )
                    )
                    ;;C9 fix (preserved): SWP|LP registration lives inside SWP::XE_Issue
                    ;;itself (called above via <swpair>'s own binding) — not a standalone
                    ;;call either caller needs to remember separately.
                    (ref-SWPT::XE_UpdateGraph swpair)
                    [swpair token-lp ico-lp ico-transfer-in ico-mint ico-transfer-out]
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_RebuildGraph ()
        @doc "One-time migration/backfill utility (#21H). Rebuilds SWPT's adjacency \
            \ graph (SwapTracerV3) from every currently-existing swpair \
            \ (SWP::URC_Swpairs()), by calling SWPT::XE_UpdateGraph exactly as normal \
            \ issuance already does — just once per EXISTING pool instead of once for \
            \ a newly-issued one. Lives here rather than in SWPT itself because SWPT \
            \ deploys before SWP in this codebase's deploy order and can't hold a \
            \ compile-time reference to SwapperV4; SWPI already deploys after both and \
            \ is already a legitimate XE_UpdateGraph caller (C_Issue uses the same \
            \ call). XE_UpdateGraph's own writes are idempotent (XI_UpdatePair only \
            \ appends a swpair if not already present), so this is safe to re-run — \
            \ pools issued after this upgrade (which already populate the graph \
            \ directly at issuance) are a no-op here. Intended to be run exactly once \
            \ by an admin immediately after deploying the #21H architecture change, to \
            \ backfill every pool that was issued under the old, now-removed \
            \ principal-keyed SWPT|Tracer storage."
        (with-capability (GOV|SWPI_ADMIN)
            ;;XE_UpdateGraph's own P|UEV_IMC checks that P|SWPI|CALLER (the guard SWPI
            ;;registers with SWPT via P|A_Define) is actively composed — true when
            ;;reached via C_Issue's cap chain (SWPI|C>ISSUE -> P|DT), not true by
            ;;default just because this code happens to live in SWPI's module.
            (with-capability (P|SECURE-CALLER)
                (let
                    (
                        (ref-SWP:module{SwapperV4} SWP)
                        (ref-SWPT:module{SwapTracerV3} SWPT)
                    )
                    (map (lambda (sp:string) (ref-SWPT::XE_UpdateGraph sp)) (ref-SWP::URC_Swpairs))
                )
            )
        )
    )
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "Issues a new SWPair (Liquidty Pool). \
            \ #36M/M5 fix: the write sequence itself (mint/transfer/tracker) now lives in \
            \ the shared XE_IssueWrite — MTX-SWP::MTX|C_Issue's own Step 3 calls the same \
            \ function instead of independently reimplementing it. This function still \
            \ owns all of ITS OWN IGNIS billing/aggregation (MTX|C_Issue bills separately, \
            \ in its own Step 2, before Step 3 ever runs)."
        (P|UEV_IMC)
        (with-capability (SWPI|C>ISSUE executor pool-tokens fee-lp weights amp p)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;STOA leg of a swap-pair issue: the SAME DOLLAR VALUE as its IGNIS deter
                    ;;($50 => 500 STOA at the $0.10 peg), via UC_StoaPrice. Replaces the two
                    ;;legacy sub-cent UsagePrice legs ("dptf" + "swp").
                    (stoa-costs:decimal (ref-IGNIS::UC_StoaPrice "issue-swp-pair"))
                    (gas-swp-cost:decimal (ref-IGNIS::UC_IgnisDeter "issue-swp-pair"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (write-result:list (XE_IssueWrite patron executor pool-tokens fee-lp weights amp p))
                    (swpair:string (at 0 write-result))
                    (token-lp:string (at 1 write-result))
                    (ico1:object{IgnisCollectorV3.OutputCumulator} (at 2 write-result))
                    (ico2:object{IgnisCollectorV3.OutputCumulator} (at 3 write-result))
                    (ico3:object{IgnisCollectorV3.OutputCumulator} (at 4 write-result))
                    (ico4:object{IgnisCollectorV3.OutputCumulator} (at 5 write-result))
                    (ico5:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator gas-swp-cost SWP|SC_NAME trigger [])
                    )
                )
                (ref-IGNIS::XE_CollectStoa patron stoa-costs)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4 ico5] [swpair token-lp])
            )
        )
    )

)

;; --- tables for 16_SWPI.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)


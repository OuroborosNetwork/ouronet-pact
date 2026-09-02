;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
(interface SwapperV3
    @doc "Swapper forward surface for module SWP (successor to SwapperV2). \
        \ Row shapes use this interface's PoolTokens and FeeSplit schemas (field-compatible with SwapperV2). \
        \ V3: UR_StoaValue and XE_UpdateStoaValue for STOA pool ledger on SWP|Pairs."
    ;;
    (defschema PoolTokens
        token-id:string
        token-supply:decimal
    )
    (defschema FeeSplit
        target:string
        value:integer
    )
    ;;
    (defun SWP|Info ())
    ;;
    ;;
    (defun UC_ExtractTokens:[string] (input:[object{PoolTokens}]))
    (defun UC_ExtractTokenSupplies:[decimal] (input:[object{PoolTokens}]))
    (defun UC_CustomSpecialFeeTargets:[string] (io:[object{FeeSplit}]))
    (defun UC_CustomSpecialFeeTargetsProportions:[decimal] (io:[object{FeeSplit}]))
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
    (defun UR_PoolTokenPosition:integer (swpair:string id:string))
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
    ;;
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
    ;;
    ;;
    (defun A_UpdatePrincipal (principal:string add-or-remove:bool))
    (defun A_RotatePrincipal (old:string new:string))
    (defun A_UpdateLimit (limit:decimal spawn:bool))
    (defun A_UpdateLiquidBoost (new-boost-variable:bool))
    (defun A_DefinePrimordialPool (primordial-pool:string))
    (defun A_ToggleAsymetricLiquidityAddition (toggle:bool))
    ;;
    (defun C_ChangeOwnership:object{IgnisCollectorV1.OutputCumulator} (swpair:string new-owner:string))
    (defun C_EnableFrozenLP:object{IgnisCollectorV1.OutputCumulator} (patron:string swpair:string))
    (defun C_EnableSleepingLP:object{IgnisCollectorV1.OutputCumulator} (patron:string swpair:string))
    (defun C_ModifyCanChangeOwner:object{IgnisCollectorV1.OutputCumulator} (swpair:string new-boolean:bool))
    (defun C_ModifyWeights:object{IgnisCollectorV1.OutputCumulator} (swpair:string new-weights:[decimal]))
    (defun C_ToggleAddOrSwap:object{IgnisCollectorV1.OutputCumulator} (swpair:string toggle:bool add-or-swap:bool))
    (defun C_ToggleFeeLock:object{IgnisCollectorV1.OutputCumulator} (patron:string swpair:string toggle:bool))
    (defun C_UpdateAmplifier:object{IgnisCollectorV1.OutputCumulator} (swpair:string amp:decimal))
    (defun C_UpdateFee:object{IgnisCollectorV1.OutputCumulator} (swpair:string new-fee:decimal lp-or-special:bool))
    (defun C_UpdateSpecialFeeTargets:object{IgnisCollectorV1.OutputCumulator} (swpair:string targets:[object{FeeSplit}]))
    ;;  [URCi] cost readers — single source per op (EnableFrozen/Sleeping/ToggleAddOrSwap composers -> Phase 1.2)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV1.OutputCumulator} (entity-id:string))
    (defun URCi_ChangeOwnership:object{IgnisCollectorV1.OutputCumulator} (swpair:string))
    (defun URCi_ModifyCanChangeOwner:object{IgnisCollectorV1.OutputCumulator} (swpair:string))
    (defun URCi_ModifyWeights:object{IgnisCollectorV1.OutputCumulator} (swpair:string))
    (defun URCi_UpdateAmplifier:object{IgnisCollectorV1.OutputCumulator} (swpair:string))
    (defun URCi_UpdateFee:object{IgnisCollectorV1.OutputCumulator} (swpair:string))
    (defun URCi_UpdateSpecialFeeTargets:object{IgnisCollectorV1.OutputCumulator} (swpair:string))
    (defun URCi_ToggleFeeLock:object{IgnisCollectorV1.OutputCumulator} (swpair:string toggle:bool))
    (defun URCi_EnableFrozenLP:object{IgnisCollectorV1.OutputCumulator} (patron:string swpair:string))
    (defun URCi_EnableSleepingLP:object{IgnisCollectorV1.OutputCumulator} (patron:string swpair:string))
    (defun URCi_ToggleAddOrSwap:object{IgnisCollectorV1.OutputCumulator} (swpair:string toggle:bool add-or-swap:bool))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    ;;
    (defun XB_ModifyWeights (swpair:string new-weights:[decimal]))
    ;;
    (defun XE_UpdateSupplies (swpair:string new-supplies:[decimal]))
    (defun XE_UpdateSupply (swpair:string id:string new-supply:decimal))
    (defun XE_UpdateStoaValue (swpair:string new-stoa-value:decimal))
    (defun XE_Issue:string (account:string pool-tokens:[object{PoolTokens}] token-lp:string fee-lp:decimal weights:[decimal] amp:decimal p:bool))
    (defun XE_CanAddOrSwapToggle (swpair:string toggle:bool add-or-swap:bool))
    ;;
)
;;
(module SWP GOV
    ;;
    (implements OuronetPolicyV1)
    (implements BrandingUsagePrimaryV1)
    (implements SwapperV3)
    ;;{G1}
    (defconst GOV|MD_SWP            (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_SWP            (keyset-ref-guard SWP|SC_KEY))
    ;;
    (defconst SWP|SC_KEY            (GOV|SwapKey))
    (defconst SWP|SC_NAME           (GOV|SWP|SC_NAME))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|SWP_ADMIN)))
    (defcap GOV|SWP_ADMIN ()
        (enforce-one
            "SWP Swapper Admin not satisfed"
            [
                (enforce-guard GOV|MD_SWP)
                (enforce-guard GOV|SC_SWP)
            ]
        )
    )
    (defcap SWP|GOV ()
        @doc "Governor Capability for the Swapper Smart DALOS Account"
        true
    )
    (defcap SWP|NATIVE-AUTOMATIC ()
        @doc "Autonomic management of <stoa-konto> of SWAPPER Smart Account"
        true
    )
    ;;
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    (defun GOV|SwapKey ()           (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|SwapKey)))
    (defun GOV|SWP|SC_NAME ()       (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|SWP|SC_NAME)))
    ;;
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV1.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P3}
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
    ;;{P4}
    (defconst P|I                   (P|Info))
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun A_P|Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|SWP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun A_P|AddIMP (policy-guard:guard)
        (with-capability (GOV|SWP_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV1} U|LST)
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
    (defun A_P|Define ()
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (ref-P|BRD:module{OuronetPolicyV1} BRD)
                (ref-P|DPTF:module{OuronetPolicyV1} DPTF)
                ;(ref-P|DPOF:module{OuronetPolicyV1} DPOF)
                (ref-P|ATS:module{OuronetPolicyV1} ATS)
                (ref-P|TFT:module{OuronetPolicyV1} TFT)
                (ref-P|ATSU:module{OuronetPolicyV1} ATSU)
                (ref-P|VST:module{OuronetPolicyV1} VST)
                (ref-P|LIQUID:module{OuronetPolicyV1} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV1} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV1} SWPT)
                (mg:guard (create-capability-guard (P|SWP|CALLER)))
            )
            (ref-P|DALOS::A_P|AddIMP mg)
            (ref-P|BRD::A_P|AddIMP mg)
            (ref-P|DPTF::A_P|AddIMP mg)
            ;(ref-P|DPOF::A_P|AddIMP mg)
            (ref-P|ATS::A_P|AddIMP mg)
            (ref-P|TFT::A_P|AddIMP mg)
            (ref-P|ATSU::A_P|AddIMP mg)
            (ref-P|VST::A_P|AddIMP mg)
            (ref-P|LIQUID::A_P|AddIMP mg)
            (ref-P|ORBR::A_P|AddIMP mg)
            (ref-P|SWPT::A_P|AddIMP mg)
        )
    )
    (defun UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
                (mp:[guard] (P|UR_IMP))
                (g:guard (ref-U|G::UEV_GuardOfAny mp))
            )
            (enforce-guard g)
        )
    )
    ;;
    ;;{1}
    (defschema SWP|PropertiesSchema
        principals:[string]
        primordial-pool:string
        liquid-boost:bool
        spawn-limit:decimal
        inactive-limit:decimal
    )
    (defschema SWP|PairsSchemaV3
        @doc "Per liquidity pool. Table row key is <swpair> (see UC_PoolID in UtilitySwpV1); \
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
        genesis-ratio:[object{SwapperV3.PoolTokens}]    ;;[.]   Token supplies at issue
        pool-tokens:[object{SwapperV3.PoolTokens}]      ;;[M]   Current per-token supplies
        token-lp:string                                 ;;[.]   LP DPTF id for this pool
        ;;
        ;;Fees
        fee-lp:decimal                                  ;;[M]   LP fee (promille semantics per module)
        fee-special:decimal                             ;;[M]
        fee-special-targets:[object{SwapperV3.FeeSplit}];;[M]
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
    ;;{2}
    (deftable SWP|Properties:{SWP|PropertiesSchema})    ;;Key = SWP|INFO
    (deftable SWP|Pairs:{SWP|PairsSchemaV3})            ;;Key = <swpair>
    (deftable SWP|Pools:{SWP|PoolsSchema})              ;;Key = <pool-category>
    (deftable SWP|Asymmetry:{SWP|AsymmetrySchema})      ;;Key = SWP|INFO
    (deftable SWP|LP:{SWP|LpTracker})                   ;;Key = <LP-string>
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defun CT_EmptyCumulator ()     (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::DALOS|EmptyOutputCumulatorV2)))
    (defun SWP|Info ()              (at 0 ["SwapperInformation"]))
    (defconst BAR                   (CT_Bar))
    (defconst EOC                   (CT_EmptyCumulator))
    (defconst SWP|INFO              (SWP|Info))
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
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    (defcap SWP|S>RT_OWN (swpair:string new-owner:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
                ("Insufficient Major Elite Tier for NewOwner to support CurrentOwner existing SpecialFeeTargets of {}" [current-special-targets])
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
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
                (ref-U|INT:module{OuronetIntegersV1} U|INT)
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
                (ref-U|INT:module{OuronetIntegersV1} U|INT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
    (defcap SPW|S>UPDATE_SPECIAL-FEE-TARGETS (swpair:string targets:[object{SwapperV3.FeeSplit}])
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
                    (obj:object{SwapperV3.FeeSplit})
                    (UEV_FeeSplit obj)
                )
                targets
            )
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
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
            (compose-capability (GOV|SWP_ADMIN))
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
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (current:[string] (UR_Principals))
            )
            (ref-DPTF::UEV_id new)
            (ref-U|LST::UEV_StringPresence old current)
            (enforce (not (URC_IsMajorPrincipal old)) (format "{} is a major (primordial-pool) principal — cannot be rotated" [old]))
            (enforce (!= old new) "Cannot rotate a principal into itself")
            (enforce (not (contains new current)) (format "{} is already a principal" [new]))
            (compose-capability (GOV|SWP_ADMIN))
        )
    )
    (defcap SWP|C>LQBOOST (new-boost-variable:bool)
        @event
        (let
            (
                (lqb:bool (UR_LiquidBoost))
            )
            (enforce (!= new-boost-variable lqb) (format "Liquid Boost already set to {}" [new-boost-variable]))
        )
        (compose-capability (GOV|SWP_ADMIN))
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
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
            (compose-capability (GOV|SWP_ADMIN))
        )
    )
    (defcap SWP|C>TG-ASYMETRIC-LQ (toggle:bool)
        (let
            (
                (pp:string (UR_PrimordialPool))
            )
            (enforce (!= pp BAR) "PrimordialPool must be set for this operation")
            (UEV_AsymetricState (not toggle))
            (compose-capability (GOV|SWP_ADMIN))
            (compose-capability (P|SWP|CALLER))
        )
    )
    ;;{FC}
    (defun UC_ExtractTokens:[string] (input:[object{SwapperV3.PoolTokens}])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[string] item:object{SwapperV3.PoolTokens})
                    (ref-U|LST::UC_AppL acc (at "token-id" item))
                )
                []
                input
            )
        )
    )
    (defun UC_ExtractTokenSupplies:[decimal] (input:[object{SwapperV3.PoolTokens}])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
            )
            (fold
                (lambda
                    (acc:[decimal] item:object{SwapperV3.PoolTokens})
                    (ref-U|LST::UC_AppL acc (at "token-supply" item))
                )
                []
                input
            )
        )
    )
    (defun UC_CustomSpecialFeeTargets:[string] (io:[object{SwapperV3.FeeSplit}])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
    (defun UC_CustomSpecialFeeTargetsProportions:[decimal] (io:[object{SwapperV3.FeeSplit}])
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
    ;;{F0}
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
    (defun UR_GenesisRatio:[object{SwapperV3.PoolTokens}] (swpair:string)
        (at "genesis-ratio" (read SWP|Pairs swpair ["genesis-ratio"]))
    )
    (defun UR_PoolTokenObject:[object{SwapperV3.PoolTokens}] (swpair:string)
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
    (defun UR_FeeSPT:[object{SwapperV3.FeeSplit}] (swpair:string)
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
    (defun UR_PoolTokenPosition:integer (swpair:string id:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                ;;
                (pool-tokens:[string] (UR_PoolTokens swpair))
                (iz-on-pool:bool (contains id pool-tokens))
            )
            (enforce iz-on-pool (format "Token {} is not part of Pool {}" [id swpair]))
            (at 0 (ref-U|LST::UC_Search pool-tokens id))
        )
    )
    (defun UC_PoolTokenPosition:integer (swpair:string id:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                ;;
                (pool-tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (iz-on-pool:bool (contains id pool-tokens))
            )
            (enforce iz-on-pool (format "Token {} is not part of the Pool String {}" [id swpair]))
            (at 0 (ref-U|LST::UC_Search pool-tokens id))
        )
    )
    (defun UR_PoolTokenSupply:decimal (swpair:string id:string)
        (at (UR_PoolTokenPosition swpair id) (UR_PoolTokenSupplies swpair))
    )
    (defun UR_PoolTokenPrecisions:[integer] (swpair:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
    (defun UC_PoolTokenPrecisions:[integer] (swpair:string)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
    (defun UR_SpecialFeeTargets:[string] (swpair:string)
        (UC_CustomSpecialFeeTargets (UR_FeeSPT swpair))
    )
    (defun UR_SpecialFeeTargetsProportions:[decimal] (swpair:string)
        (UC_CustomSpecialFeeTargetsProportions (UR_FeeSPT swpair))
    )
    (defun UR_GetLpSwpair:string (lp-id:string)
        (at "swpair" (read SWP|LP lp-id ["swpair"]))
    )
    ;;{F1}
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
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
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
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
            )
            (ref-U|SWP::UC_UniqueTokens (URC_Swpairs))
        )
    )
    (defun URC_Swpairs:[string] ()
        @doc "Outputs all current Existing Swpairs. Cheaper than <keys SWP|Pairs>"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
    (defun URC_LpComposer:[string] (pool-tokens:[object{SwapperV3.PoolTokens}] weights:[decimal] amp:decimal)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
    ;;{F2}
    (defun UEV_FeeSplit (input:object{SwapperV3.FeeSplit})
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
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
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
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
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
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
            (enforce (= state frozen-lp) (format "Swpair {} must have its Frozen-LP set to <> for this operation" [swpair state]))
        )
    )
    (defun UEV_SleepingLP (swpair:string state:bool)
        (let
            (
                (sleeping-lp:bool (UR_IzSleepingLP swpair))
            )
            (enforce (= state sleeping-lp) (format "Swpair {} must have its Sleeping-LP set to <> for this operation" [swpair state]))
        )
    )
    ;;{F3}
    ;;{F4}
    (defun CAP_Owner (swpair:string)
        @doc "Enforces SWPair Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_OwnerKonto swpair))
        )
    )
    ;;
    ;;{F5}
    (defun A_UpdatePrincipal (principal:string add-or-remove:bool)
        @doc "Adds <principal> (while under the 7 maximum) or removes it (while at \
            \ least 2 would remain defined, AND <principal> isn't currently a \
            \ 'major' principal — #65eL, URC_IsMajorPrincipal). SWPT's storage is \
            \ principal-agnostic (#21H), so removal of a minor principal is safe \
            \ — it only affects future SWPI::UEV_Issue principal-anchoring \
            \ validation, never existing routing. Major principals (currently a \
            \ member of the primordial pool — always OURO/WSTOA/SSTOA in practice) are \
            \ never removable here regardless of the floor; retiring one requires \
            \ redefining the primordial pool itself (A_SWP|DefinePrimordialPool). \
            \ A_RotatePrincipal remains available as an atomic, count-preserving \
            \ alternative for minor principals — it never touches the floor or \
            \ cap, but is equally blocked from rotating a major principal away."
        (UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
            \ redefining the primordial pool itself (A_SWP|DefinePrimordialPool)."
        (UEV_IMC)
        (with-read SWP|Properties SWP|INFO
            { "principals" := pp }
            (with-capability (SWP|C>ROTATE-PRINCIPAL old new)
                (let
                    (
                        (ref-U|LST:module{StringProcessorV1} U|LST)
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
        (UEV_IMC)
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
        (UEV_IMC)
        (with-capability (SWP|C>LQBOOST new-boost-variable)
            (update SWP|Properties SWP|INFO
                {"liquid-boost" : new-boost-variable}
            )
        )
    )
    (defun A_DefinePrimordialPool (primordial-pool:string)
        (UEV_IMC)
        (with-capability (SWP|C>DEFINE-PRIMORDIAL-POOL primordial-pool)
            (update SWP|Properties SWP|INFO
                {"primordial-pool" : primordial-pool}
            )
        )
    )
    (defun A_ToggleAsymetricLiquidityAddition (toggle:bool)
        (UEV_IMC)
        (with-capability (SWP|C>TG-ASYMETRIC-LQ toggle)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-ATS:module{AutostakeV2} ATS)
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
                    (ref-ATS::C_DPTF|ToggleBurnRole ignis-id SWP|SC_NAME true)
                    true
                )
                (if (not ouro-mint-role)
                    (ref-ATS::C_DPTF|ToggleMintRole ouro-id SWP|SC_NAME true)
                    true
                )
                (if (not ignis-fee-exemption-role)
                    (ref-ATS::C_DPTF|ToggleFeeExemptionRole ignis-id SWP|SC_NAME true)
                    true
                )
                (if (not ignis-fee-exemption-role)
                    (ref-ATS::C_DPTF|ToggleFeeExemptionRole ignis-id vst-sc true)
                    true
                )
                (update SWP|Asymmetry SWP|INFO
                    {"asymmetric" : toggle}
                )
            )
        )
    )
    ;;
    ;;[URCi] cost readers — single cost source per op. Enable*/ToggleAddOrSwap composers -> Phase 1.2.
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV1.OutputCumulator} (entity-id:string)
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::UDC_BrandingCumulator (UR_OwnerKonto entity-id) 4.0))
    )
    (defun URCi_ChangeOwnership:object{IgnisCollectorV1.OutputCumulator} (swpair:string)
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::UDC_BiggestCumulator (UR_OwnerKonto swpair)))
    )
    (defun URCi_ModifyCanChangeOwner:object{IgnisCollectorV1.OutputCumulator} (swpair:string)
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::UDC_BiggestCumulator (UR_OwnerKonto swpair)))
    )
    (defun URCi_ModifyWeights:object{IgnisCollectorV1.OutputCumulator} (swpair:string)
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::UDC_BiggestCumulator (UR_OwnerKonto swpair)))
    )
    (defun URCi_UpdateAmplifier:object{IgnisCollectorV1.OutputCumulator} (swpair:string)
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::UDC_MediumCumulator (UR_OwnerKonto swpair)))
    )
    (defun URCi_UpdateFee:object{IgnisCollectorV1.OutputCumulator} (swpair:string)
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::UDC_SmallCumulator (UR_OwnerKonto swpair)))
    )
    (defun URCi_UpdateSpecialFeeTargets:object{IgnisCollectorV1.OutputCumulator} (swpair:string)
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::UDC_MediumCumulator (UR_OwnerKonto swpair)))
    )
    (defun URCi_ToggleFeeLock:object{IgnisCollectorV1.OutputCumulator} (swpair:string toggle:bool)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (unlock-costs:[decimal] (if toggle [0.0 0.0] (ref-U|ATS::UC_UnlockPrice (UR_FeeUnlocks swpair))))
                (gas-costs:decimal (+ (ref-DALOS::UR_UsagePrice "ignis|small") (at 0 unlock-costs)))
                (output:bool (> (at 1 unlock-costs) 0.0))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs (UR_OwnerKonto swpair) (ref-IGNIS::URC_IsVirtualGasZero) [output])
        )
    )
    (defun URCi_UpgradeBranding:decimal (months:integer)
        (let ((ref-BRD:module{BrandingV1} BRD)) (ref-BRD::URCi_UpgradeBranding months))
    )
    ;;{F6}
    (defun C_UpdatePendingBranding:object{IgnisCollectorV1.OutputCumulator}
        (entity-id:string logo:string description:string website:string social:[object{BrandingV1.SocialSchema}])
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-BRD:module{BrandingV1} BRD)
            )
            (with-capability (SWP|C>UPDATE-BRD entity-id)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (URCi_UpdatePendingBranding entity-id)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string entity-id:string months:integer)
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-BRD:module{BrandingV1} BRD)
                (owner:string (UR_OwnerKonto entity-id))
            )
            ;;Perform the branding upgrade (side effect); bill the STOA via the URCi (== XE_UpgradeBranding's price)
            (with-capability (SWP|C>UPGRADE-BRD entity-id)
                (ref-BRD::XE_UpgradeBranding entity-id owner months)
            )
            (ref-IGNIS::C_STOA|CollectWT patron (URCi_UpgradeBranding months) false)
        )
    )
    ;;
    (defun C_ChangeOwnership:object{IgnisCollectorV1.OutputCumulator}
        (swpair:string new-owner:string)
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (SWP|S>RT_OWN swpair new-owner)
                (XI_ChangeOwnership swpair new-owner)
                (URCi_ChangeOwnership swpair)
            )
        )
    )
    (defun URCi_EnableFrozenLP:object{IgnisCollectorV1.OutputCumulator}
        (patron:string swpair:string)
        @doc "Cost preview for C_EnableFrozenLP: if no frozen link exists yet, the VST \
            \ create-frozen-link cost; otherwise the medium IGNIS price on the pool owner \
            \ (output == existing link). Re-derived purely (XI_EnableFrozenLP is a free write)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-VST:module{VestingV1} VST)
                (lp-id:string (UR_TokenLP swpair))
                (current-frozen-link:string (ref-DPTF::UR_Frozen lp-id))
            )
            (if (= current-frozen-link BAR)
                (ref-VST::URCi_CreateSpecialTrueFungibleLink lp-id)
                (ref-IGNIS::UDC_ConstructOutputCumulator
                    (ref-DALOS::UR_UsagePrice "ignis|medium")
                    (UR_OwnerKonto swpair)
                    (ref-IGNIS::URC_IsVirtualGasZero)
                    [current-frozen-link]
                )
            )
        )
    )
    (defun URCi_EnableSleepingLP:object{IgnisCollectorV1.OutputCumulator}
        (patron:string swpair:string)
        @doc "Cost preview for C_EnableSleepingLP: if no sleeping link exists yet, the VST \
            \ create-sleeping-link (vzh-tag 2) cost; otherwise the medium IGNIS price on the \
            \ pool owner (output == existing link). Re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-VST:module{VestingV1} VST)
                (lp-id:string (UR_TokenLP swpair))
                (current-sleeping-link:string (ref-DPTF::UR_Sleeping lp-id))
            )
            (if (= current-sleeping-link BAR)
                (ref-VST::URCi_CreateSpecialOrtoFungibleLink lp-id 2)
                (ref-IGNIS::UDC_ConstructOutputCumulator
                    (ref-DALOS::UR_UsagePrice "ignis|medium")
                    (UR_OwnerKonto swpair)
                    (ref-IGNIS::URC_IsVirtualGasZero)
                    [current-sleeping-link]
                )
            )
        )
    )
    (defun URCi_ToggleAddOrSwap:object{IgnisCollectorV1.OutputCumulator}
        (swpair:string toggle:bool add-or-swap:bool)
        @doc "Cost preview for C_ToggleAddOrSwap: the base 5x-biggest IGNIS price (ico0) plus, \
            \ when enabling add-liquidity (toggle), the one-time LP burn/mint + per-pool-token \
            \ fee-exemption role bootstrap that only bills for roles not already set (ico1). \
            \ Role costs use DPTF's own toggle-role cumulators; XE_CanAddOrSwapToggle is a free \
            \ write. Re-derived purely from the live role states."
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (biggest:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (price:decimal (* 5.0 biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ico0:object{IgnisCollectorV1.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price (UR_OwnerKonto swpair) trigger [])
                )
                (ico1:object{IgnisCollectorV1.OutputCumulator}
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
                                (ico2:object{IgnisCollectorV1.OutputCumulator}
                                    (if (not lp-burn-role)
                                        (ref-DPTF::URCi_ToggleBurnRole lp-id)
                                        EOC
                                    )
                                )
                                (ico3:object{IgnisCollectorV1.OutputCumulator}
                                    (if (not lp-mint-role)
                                        (ref-DPTF::URCi_ToggleMintRole lp-id)
                                        EOC
                                    )
                                )
                                (folded-obj:[object{IgnisCollectorV1.OutputCumulator}]
                                    (fold
                                        (lambda
                                            (acc:[object{IgnisCollectorV1.OutputCumulator}] idx:integer)
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
                                (ico4:object{IgnisCollectorV1.OutputCumulator}
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
    (defun C_EnableFrozenLP:object{IgnisCollectorV1.OutputCumulator}
        (patron:string swpair:string)
        (UEV_IMC)
        (with-capability (SWP|C>ENABLE-FROZEN swpair)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-VST:module{VestingV1} VST)
                    (lp-id:string (UR_TokenLP swpair))
                    (current-frozen-link:string (ref-DPTF::UR_Frozen lp-id))
                )
                (XI_EnableFrozenLP swpair)
                (if (= current-frozen-link BAR)
                    (ref-VST::C_CreateFrozenLink patron lp-id)    
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-DALOS::UR_UsagePrice "ignis|medium")
                        (UR_OwnerKonto swpair)
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        [current-frozen-link]
                    )
                )
            )
        )
    )
    (defun C_EnableSleepingLP:object{IgnisCollectorV1.OutputCumulator}
        (patron:string swpair:string)
        (UEV_IMC)
        (with-capability (SWP|C>ENABLE-SLEEPING swpair)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-VST:module{VestingV1} VST)
                    (lp-id:string (UR_TokenLP swpair))
                    (current-sleeping-link:string (ref-DPTF::UR_Sleeping lp-id))
                )
                (XI_EnableSleepingLP swpair)
                (if (= current-sleeping-link BAR)
                    (ref-VST::C_CreateSleepingLink patron lp-id)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-DALOS::UR_UsagePrice "ignis|medium")
                        (UR_OwnerKonto swpair)
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        [current-sleeping-link]
                    )
                )
            )
        )
    )
    (defun C_ModifyCanChangeOwner:object{IgnisCollectorV1.OutputCumulator}
        (swpair:string new-boolean:bool)
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (SWP|S>RT_CAN-CHANGE swpair new-boolean)
                (XI_ModifyCanChangeOwner swpair new-boolean)
                (URCi_ModifyCanChangeOwner swpair)
            )
        )
    )
    (defun C_ModifyWeights:object{IgnisCollectorV1.OutputCumulator}
        (swpair:string new-weights:[decimal])
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (SECURE)
                (XB_ModifyWeights swpair new-weights)
                (URCi_ModifyWeights swpair)
            )
        )
    )
    (defun C_ToggleAddOrSwap:object{IgnisCollectorV1.OutputCumulator}
        (swpair:string toggle:bool add-or-swap:bool)
        @doc "#71L: called directly (cross-module C_->C_) by SWPU::C_ToggleSwapCapability and \
            \ SWPLC::C_ToggleAddLiquidity, instead of through an XE_* forward entrypoint — \
            \ intentional, DESIGN-accepted, not an oversight. This function is not a plain \
            \ toggle write: it bills real IGNIS (ico0), bootstraps LP burn/mint/fee-exemption \
            \ roles the first time add-liquidity is enabled (ico1-ico4), and — critically — is \
            \ the ONLY place in this call chain that enforces pool ownership, via \
            \ SWP|C>ADD-OR-SWAP's composed CAP_Owner. The existing XE_CanAddOrSwapToggle does \
            \ none of that (only UEV_IMC + a raw update, no ownership check) and would need to \
            \ replicate all of the above to be a safe drop-in replacement for either caller — \
            \ neither SWPU::SPWU|C>TOGGLE-SWAP nor SWPLC::P|SWPLC|CALLER re-derives ownership \
            \ independently, so rerouting through the bare XE_* today would silently strip \
            \ authorization. Left as-is; a properly-capped XE_* replacement is real design work, \
            \ not a mechanical rename — deferred, not attempted here."
        (UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
                (biggest:decimal (ref-DALOS::UR_UsagePrice "ignis|biggest"))
                (price:decimal (* 5.0 biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (ico0:object{IgnisCollectorV1.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price (UR_OwnerKonto swpair) trigger [])
                )
                (ico1:object{IgnisCollectorV1.OutputCumulator}
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
                                    (ico2:object{IgnisCollectorV1.OutputCumulator}
                                        (if (not lp-burn-role)
                                            (ref-ATS::C_DPTF|ToggleBurnRole lp-id SWP|SC_NAME true)
                                            EOC
                                        )
                                    )
                                    (ico3:object{IgnisCollectorV1.OutputCumulator}
                                        (if (not lp-mint-role)
                                            (ref-ATS::C_DPTF|ToggleMintRole lp-id SWP|SC_NAME true)
                                            EOC
                                        )
                                    )
                                    (folded-obj:[object{IgnisCollectorV1.OutputCumulator}]
                                        (fold
                                            (lambda
                                                (acc:[object{IgnisCollectorV1.OutputCumulator}] idx:integer)
                                                (ref-U|LST::UC_AppL
                                                    acc
                                                    (if (not (ref-DPTF::UR_AccountRoleFeeExemption (at idx ptts) SWP|SC_NAME))
                                                        (ref-ATS::C_DPTF|ToggleFeeExemptionRole (at idx ptts) SWP|SC_NAME true)
                                                        EOC
                                                    )
                                                )
                                            )
                                            []
                                            (enumerate 0 (- (length ptts) 1))
                                        )
                                    )
                                    (ico4:object{IgnisCollectorV1.OutputCumulator}
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
    (defun C_ToggleFeeLock:object{IgnisCollectorV1.OutputCumulator}
        (patron:string swpair:string toggle:bool)
        (UEV_IMC)
        (with-capability (SWP|C>TG_FEE-LOCK swpair toggle)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (toggle-costs:[decimal] (XI_ToggleFeeLock swpair toggle))
                    (stoa-costs:decimal (at 1 toggle-costs))
                    ;;URCi computed HERE — reads fee-unlocks BEFORE XI_IncrementFeeUnlocks below mutates it
                    (cumulator:object{IgnisCollectorV1.OutputCumulator} (URCi_ToggleFeeLock swpair toggle))
                )
                (if (> stoa-costs 0.0)
                    (do
                        (XI_IncrementFeeUnlocks swpair)
                        (ref-IGNIS::C_STOA|Collect patron stoa-costs)
                    )
                    true
                )
                cumulator
            )
        )
    )
    (defun C_UpdateAmplifier:object{IgnisCollectorV1.OutputCumulator}
        (swpair:string amp:decimal)
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (SWP|S>UPDATE-AMPLIFIER swpair amp)
                (XI_UpdateAmplifier swpair amp)
                (URCi_UpdateAmplifier swpair)
            )
        )
    )
    (defun C_UpdateFee:object{IgnisCollectorV1.OutputCumulator}
        (swpair:string new-fee:decimal lp-or-special:bool)
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (SWP|S>UPDATE-FEE swpair new-fee)
                (XI_UpdateFee swpair new-fee lp-or-special)
                (URCi_UpdateFee swpair)
            )
        )
    )
    (defun C_UpdateSpecialFeeTargets:object{IgnisCollectorV1.OutputCumulator}
        (swpair:string targets:[object{SwapperV3.FeeSplit}])
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (with-capability (SPW|S>UPDATE_SPECIAL-FEE-TARGETS swpair targets)
                (XI_UpdateSpecialFeeTargets swpair targets)
                (URCi_UpdateSpecialFeeTargets swpair)
            )
        )
    )
    ;;{F7}
    (defun XB_ModifyWeights (swpair:string new-weights:[decimal])
        (UEV_IMC)
        (with-capability (SWP|S>WEIGHTS swpair new-weights)
            (update SWP|Pairs swpair
                {"weights"  : new-weights}
            )
        )
    )
    ;;
    (defun XE_UpdateSupplies (swpair:string new-supplies:[decimal])
        (UEV_IMC)
        (with-capability (SWP|S>UPDATE-SUPPLIES swpair new-supplies)
            (let
                (
                    (pool-tokens:[string] (UR_PoolTokens swpair))
                    (new-pool-tokens:[object{SwapperV3.PoolTokens}]
                        (zip (lambda (x:string y:decimal) { "token-id": x, "token-supply": y }) pool-tokens new-supplies)
                    )
                )
                (update SWP|Pairs swpair
                    {"pool-tokens" : new-pool-tokens}
                )
            )
        )
    )
    (defun XE_UpdateSupply (swpair:string id:string new-supply:decimal)
        (UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (current-pool-tokens:[object{SwapperV3.PoolTokens}] (UR_PoolTokenObject swpair))
                (id-pos:integer (UR_PoolTokenPosition swpair id))
                (new:object{SwapperV3.PoolTokens} { "token-id" : id, "token-supply" : new-supply})
                (new-pool-tokens:[object{SwapperV3.PoolTokens}] (ref-U|LST::UC_ReplaceAt current-pool-tokens id-pos new))
            )
            (with-capability (SWP|S>UPDATE-SUPPLY swpair id new-supply)
                (update SWP|Pairs swpair
                    {"pool-tokens" : new-pool-tokens}
                )
            )
        )
    )
    (defun XE_UpdateStoaValue (swpair:string new-stoa-value:decimal)
        @doc "Forward writer: sets stoa-value on SWP|Pairs. Requires UEV_IMC; pool row must exist (UEV_id)."
        (UEV_IMC)
        (update SWP|Pairs swpair
            {"stoa-value" : new-stoa-value}
        )
    )
    (defun XE_Issue:string (account:string pool-tokens:[object{SwapperV3.PoolTokens}] token-lp:string fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        @doc "Forward writer: inserts the new SWP|Pairs row, registers the LP tracker \
            \ (C9 fix), saves the pool, and deploys token accounts. \
            \ #52L fix (R4): returns the newly-constructed <swpair> ID — callers \
            \ (e.g. SWPI::C_Issue, MTX-SWP::C_MTX|Issue) need it back to finish \
            \ building their own response/continue the issuance flow."
        (UEV_IMC)
        (let
            (
                (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
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
            ;;remember — 16_SWPI.pact::C_Issue did remember; 20_MTX-SWP.pact::C_MTX|Issue (the defpact
            ;;path, which also calls XE_Issue) never did, so every pool issued through it had an LP token
            ;;that could never be resolved back to its swpair (UR_GetLpSwpair hard-aborts on the missing
            ;;row), permanently blocking AQP LP-stake admission for that pool.
            (XE_AddLPTracker token-lp swpair)
            (with-capability (P|SECURE-CALLER)
                (XI_SavePool n what swpair)
                (ref-DPTF::C_DeployAccount token-lp account)
                (map
                    (lambda
                        (id:string)
                        (ref-DPTF::C_DeployAccount id SWP|SC_NAME)
                    )
                    ptte
                )
                swpair
            )
        )
    )
    (defun XE_CanAddOrSwapToggle (swpair:string toggle:bool add-or-swap:bool)
        @doc "#55L fix: removed a redundant second guard check that used to sit here — \
            \ it re-ran UEV_Any against [local-guard] + (P|UR_IMP), the exact same list \
            \ UEV_IMC (above) already checked, plus one extra local guard. Since UEV_IMC \
            \ is a bare statement (not wrapped in try) and aborts the whole tx on \
            \ failure, reaching this point already proves (P|UR_IMP) alone contains a \
            \ passing guard — adding local-guard to an already-guaranteed-passing OR-set \
            \ can never change the outcome. Pure dead weight, safely removed."
        (UEV_IMC)
        (if add-or-swap
            (update SWP|Pairs swpair
                {"can-add"                      : toggle}
            )
            (update SWP|Pairs swpair
                {"can-swap"                     : toggle}
            )
        )
    )
    (defun XE_AddLPTracker (lp-id:string swpair:string)
        (UEV_IMC)
        (insert SWP|LP lp-id
            {"swpair"                           : swpair}
        )
    )
    ;;
    (defun XI_ChangeOwnership (swpair:string new-owner:string)
        (require-capability (SWP|S>RT_OWN swpair new-owner))
        (update SWP|Pairs swpair
            {"owner-konto"                      : new-owner}
        )
    )
    (defun XI_IncrementFeeUnlocks (swpair:string)
        (require-capability (SECURE))
        (with-read SWP|Pairs swpair
            { "unlocks" := u }
            (update SWP|Pairs swpair
                {"unlocks" : (+ u 1)}
            )
        )
    )
    (defun XI_ModifyCanChangeOwner (swpair:string new-boolean:bool)
        (require-capability (SWP|S>RT_CAN-CHANGE swpair new-boolean))
        (update SWP|Pairs swpair
            {"can-change-owner"                 : new-boolean}
        )
    )
    (defun XI_SavePool (n:integer what:bool swpair:string)
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
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
    (defun XI_ToggleFeeLock:[decimal] (swpair:string toggle:bool)
        @doc "Writes the new fee-lock state. \
            \ #52L fix (R4): returns [virtual-gas-cost(IGNIS) native-gas-cost(STOA)] — \
            \ [0.0 0.0] when locking (toggle=true, free); the real ATS unlock price \
            \ (U|ATS::UC_UnlockPrice) when unlocking (toggle=false), scaled by this \
            \ pool's current <UR_FeeUnlocks> count. The caller (C_ToggleFeeLock) bills \
            \ this back to the patron."
        (require-capability (SWP|C>TG_FEE-LOCK swpair toggle))
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
            )
            (update SWP|Pairs swpair
                { "fee-lock" : toggle}
            )
            (if (= toggle true)
                [0.0 0.0]
                (ref-U|ATS::UC_UnlockPrice (UR_FeeUnlocks swpair))
            )
        )
    )
    (defun XI_UpdateAmplifier (swpair:string new-amplifier:decimal)
        (with-capability (SWP|S>UPDATE-AMPLIFIER swpair new-amplifier)
            (update SWP|Pairs swpair
                {"amplifier" : new-amplifier}
            )
        )
    )
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
    (defun XI_UpdateSpecialFeeTargets (swpair:string targets:[object{SwapperV3.FeeSplit}])
        (require-capability (SPW|S>UPDATE_SPECIAL-FEE-TARGETS swpair targets))
        (update SWP|Pairs swpair
            {"fee-special-targets"                : targets}
        )
    )
    (defun XI_EnableFrozenLP (swpair:string)
        (require-capability (SWP|C>ENABLE-FROZEN swpair))
        (update SWP|Pairs swpair
            {"frozen-lp"    : true}
        )
    )
    (defun XI_EnableSleepingLP (swpair:string)
        (require-capability (SWP|C>ENABLE-SLEEPING swpair))
        (update SWP|Pairs swpair
            {"sleeping-lp"    : true}
        )
    )
    ;;
    ;;{F8}  [AUP - Admin Update Functions]
    ;;
    (defcap AHU ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ah:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
            )
            (ref-DALOS::CAP_EnforceAccountOwnership ah)
            (compose-capability (SECURE))
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
    ;;
)

(create-table P|T)
(create-table P|MT)
(create-table SWP|Properties)
(create-table SWP|Asymmetry)
(create-table SWP|Pairs)
(create-table SWP|Pools)
(create-table SWP|LP)
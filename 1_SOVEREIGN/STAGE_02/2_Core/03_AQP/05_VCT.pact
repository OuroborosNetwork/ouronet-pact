(interface AcquisitionVacateV1
    (defun GOV|Demiurgoi ())
    (defun UC_ComputeMinSliceCount:integer (unit-count:integer vacate-kind:integer))
    (defun UC_ZeroIntAmountsMatrix:[[integer]] (nonces-array:[[integer]]))
    (defun URDC_BuildVacateSlicePlan:object
        (pool-id:string asset-id:string vacate-kind:integer slice-count:integer))
    (defun UR_Job:object (vacate-job-id:string))
    (defun UR_Slice:object (vacate-job-id:string slice-idx:integer))
    (defun URD_SlicesForJob:[object] (vacate-job-id:string))
    (defun URDC_ActiveJobForPool:object (pool-id:string))
    ;;  [UR/URD] vacate inventory + session observability (UI preflight)
    (defun UR_VacateInProgress:bool (pool-id:string))
    (defun UR_InitialVacateHash:string (pool-id:string))
    (defun UR_PhaseVacateHash:string (pool-id:string))
    (defun UR_LastVacateHash:string (pool-id:string))
    (defun URD_VacateTfInventory:object (pool-id:string dptf-id:string))
    (defun URD_VacateOfInventory:object (pool-id:string dpof-id:string))
    (defun URD_VacateCollectableInventory:object (pool-id:string collectable-id:string son:bool))
    ;;  [C] Full vacate — one tx (Talos wired)
    (defun C_FullVacateTrueFungible:object{IgnisCollectorV1.OutputCumulator} (pool-id:string dptf-id:string))
    (defun C_FullVacateOrtoFungible:object{IgnisCollectorV1.OutputCumulator} (pool-id:string dpof-id:string))
    (defun C_FullVacateSemiFungible:object{IgnisCollectorV1.OutputCumulator} (pool-id:string dpsf-id:string))
    (defun C_FullVacateNonFungible:object{IgnisCollectorV1.OutputCumulator} (pool-id:string dpnf-id:string))
    ;;  [C] Session vacate — multi-tx sliced (Talos wired)
    (defun C_BeginVacate:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string asset-id:string vacate-kind:integer slice-count:integer))
    (defun C_ResliceVacate:object{IgnisCollectorV1.OutputCumulator}
        (vacate-job-id:string slice-count:integer))
    (defun C_VacateChunkTrueFungible:object{IgnisCollectorV1.OutputCumulator}
        (vacate-job-id:string slice-idx:integer owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun C_VacateChunkNonce:object{IgnisCollectorV1.OutputCumulator}
        (vacate-job-id:string slice-idx:integer owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    (defun C_AbortVacate:object{IgnisCollectorV1.OutputCumulator} (vacate-job-id:string))
)

;; =============================================================================
;; AQP-VCT — Acquisition Vacate (pool-owner forced unstake)
;; =============================================================================
;; Two UI variants — pick one per pool × asset stream:
;;
;;   FULL (one tx, Talos wired)
;;     C_FullVacate* — URDC_VacateTfOwnerRows / URDC_VacateNonceOwnerRows + AQP array helpers; delegates to AQP-VCT.XI_Vacate*
;;     atomics inside VCT|C>FULL-* caps. Use when inventory fits one-tx gas envelope.
;;
;;   SLICED SESSION (multi-tx, Talos wired)
;;     C_BeginVacate → C_VacateChunk* (×N) → auto finalize on last chunk;
;;     optional C_ResliceVacate (new VacateJobID; old job resliced=true);
;;     C_AbortVacate escape hatch (does not re-enable stake).
;;     On-chain: VCT|T|Job (key=VacateJobID) + VCT|T|Slice (hash-only commitments).
;;     Slice payloads: Begin/Reslice OC output + URDC_BuildVacateSlicePlan preflight.
;;
;; Vacate entity = OWNER (custody recipient). One owner may have multiple beneficiaries.
;; Bulk transfer list: parallel owner-ids, beneficiary-ids, amounts (or nonces per owner row).
;; Table unwind dedupes by unique beneficiary (shared beneficiaries across owners).
;;
;; TF vacate unit of work = one object{VCT|VacateTfLeg} (owner × beneficiary × balance).
;;   URDC_VacateTfOwnerRows → legs; all TF vacate XI_* take legs:[object{VCT|VacateTfLeg}].
;;
;; Phases for FULL TF VACATE (unwind before transfer):
;;   2] Trackers — per leg: AQP|XE_ZeroDptfTrackerSlot (write-only)
;;   3] SCORE   — per unique beneficiary × employed scores: SCR|XE_ApplyTrueFungibleStakeDelta
;;   4] RPS     — XI_3|RpsVacatePreZero; FVT anchor refresh; book unclaimed; checkpoint
;;   0] Transfer — TFT bulk custody return LAST
;;
;; Vacate orchestration lives in AQP-VCT. Back modules expose only core XE table writers and stake/RPS primitives.
;;
;; Session / full C_*: each owns a master @event VCT|C>* cap; body calls XI_* on leg lists.
;; =============================================================================

(module AQP-VCT GOV
    (implements OuronetPolicyV1)
    (implements AcquisitionVacateV1)

    ;;<========>
    ;;GOVERNANCE
    (defconst GOV|MD_VCT (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV () (compose-capability (GOV|VCT_ADMIN)))
    (defcap GOV|VCT_ADMIN () (enforce-guard GOV|MD_VCT))
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<====>
    ;;POLICY
    (deftable P|T:{OuronetPolicyV1.P|S})                          ;;Key = <Policy-Name>
    (deftable P|MT:{OuronetPolicyV1.P|MS})                        ;;Key = module P|I singleton

    (defcap P|VCT|CALLER ()
        true
    )
    (defcap P|VCT|REMOTE-GOV ()
        @doc "Remote governor for AQP|SC_NAME vault-send (registered on AQP-POOL policy table)."
        true
    )
    (defcap P|VCT|RECIPE ()
        @doc "Vacate custody recipe: TFT/DPOF/DPDC-T transfer (P|VCT|CALLER), AQP|SC_NAME vault-send \
            \ (P|VCT|REMOTE-GOV), cross-module AQP/FVT/SCR writes (SECURE). Composed by all VCT|C>*VACATE* caps."
        (compose-capability (P|VCT|CALLER))
        (compose-capability (P|VCT|REMOTE-GOV))
        (compose-capability (SECURE))
    )

    (defconst P|I (P|Info))
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
    (defun P|A_Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|VCT_ADMIN)
            (write P|T policy-name {"policy" : policy-guard})
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|VCT_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV1} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)})
                )
            )
        )
    )
    (defun P|A_Define ()
        @doc "Post-deploy: VCT SECURE on AQP-SCORE + AQP-POOL + AQP-FVT IMP; P|VCT|CALLER on TFT/DPOF/DPDC-T; VCT|RemoteAqpGov on AQP-POOL."
        (let
            (
                (ref-P|SCR:module{OuronetPolicyV1} AQP-SCORE)
                (ref-P|AQP:module{OuronetPolicyV1} AQP-POOL)
                (ref-P|FVT:module{OuronetPolicyV1} AQP-FVT)
                (ref-P|TFT:module{OuronetPolicyV1} TFT)
                (ref-P|DPOF:module{OuronetPolicyV1} DPOF)
                (ref-P|DPDC-T:module{OuronetPolicyV1} DPDC-T)
                ;;
                (dg:guard (create-capability-guard (SECURE)))
                (mg:guard (create-capability-guard (P|VCT|CALLER)))
                (rg:guard (create-capability-guard (P|VCT|REMOTE-GOV)))
            )
            (ref-P|SCR::P|A_AddIMP dg)
            (ref-P|AQP::P|A_AddIMP dg)
            (ref-P|FVT::P|A_AddIMP dg)
            (ref-P|AQP::P|A_Add "VCT|RemoteAqpGov" rg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
        )
    )
    (defun UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defcap SECURE () true)

    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;; Session vacate: two job tables (+ P|T / P|MT):
    ;;   Job   — one row per VacateJobID (pool-id immutable on row)
    ;;   Slice — hash-only commitment per slice (payload lives in Begin/Reslice OC)
    (defschema VCT|SlicePayload
        @doc "Vacate slice payload for plan OC and hash commitment. \
            \ TF (vacate-asset-kind=1): amounts populated; nonces-array and amounts-array empty. \
            \ OF/DPSF/DPNF: nonces-array + amounts-array populated; amounts empty. \
            \ OF uses zero-sentinel amounts-array; collectables use full tracker balances per nonce."
        pool-id:string
        asset-id:string
        vacate-asset-kind:integer
        owner-ids:[string]
        beneficiary-ids:[string]
        amounts:[decimal]
        nonces-array:[[integer]]
        amounts-array:[[integer]]
    )
    (defschema VCT|VacateSlicePlan
        @doc "Begin/Reslice execution output — full slice payloads for off-chain storage."
        vacate-job-id:string
        pool-id:string
        asset-id:string
        vacate-asset-kind:integer
        slice-count:integer
        slices:[object{VCT|SlicePayload}]
    )
    (defschema VCT|Job
        @doc "Key = VacateJobID. One vacate session. pool-id immutable. \
            \ Terminal via exactly one of finalized / aborted / resliced."
        pool-id:string
        asset-id:string
        vacate-asset-kind:integer
        slice-count:integer
        initial-manifest-hash:string
        finalized:bool
        aborted:bool
        resliced:bool
        ;;
        vacate-job-id:string
    )
    (defschema VCT|Slice
        @doc "Key = <VacateJobID> | <slice-idx>. Blake2b commitment only — payload in OC."
        slice-hash:string
        processed:bool
        ;;
        vacate-job-id:string
        slice-idx:integer
    )
    (defschema VCT|SeqCounter
        next-id:integer
    )

    (defschema VCT|VacateTfLeg
        owner-id:string
        beneficiary-id:string
        balance:decimal
    )
    (defschema VCT|VacateNonceRow
        owner-id:string
        beneficiary-id:string
        nonce:integer
        balance:decimal
    )
    (defschema VCT|VacateNonceLeg
        owner-id:string
        beneficiary-id:string
        nonces:[integer]
        amounts:[decimal]
    )
    (defschema VCT|VacateTfInventory
        @doc "UI pre-flight bundle: TF vacate legs + leg-count."
        legs:[object{VCT|VacateTfLeg}]
        leg-count:integer
    )
    (defschema VCT|VacateNonceLegInventory
        @doc "UI pre-flight bundle: grouped nonce vacate legs + leg-count."
        legs:[object{VCT|VacateNonceLeg}]
        leg-count:integer
    )

    (deftable VCT|T|Job:{VCT|Job})
    (deftable VCT|T|Slice:{VCT|Slice})
    (deftable VCT|T|Seq:{VCT|SeqCounter})

    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV1} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defconst BAR (CT_Bar))
    (defun CT_AqpScName:string ()
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-ANK::GOV|AQP|SC_NAME)
        )
    )
    (defconst AQP|SC_NAME (CT_AqpScName))

    (defconst VACATE-KIND-TF 1)
    (defconst VACATE-KIND-OF 2)
    (defconst VACATE-KIND-DPSF 3)
    (defconst VACATE-KIND-DPNF 4)

    ;; REPL gas sweep (REPL/VCT-gas-sweep.repl) tunes these; keep above probe ladder max during profiling.
    ;; TF: max unique owners (custody recipients) per chunk tx.
    ;; OF/DPSF/DPNF: max total nonces summed across all owner rows per chunk tx (not owner count).
    (defconst VACATE-MAX-LEGS 16)
    (defconst VACATE-MAX-NONCES 64)
    (defconst VACATE-FULL-MAX-LEGS 128)
    (defconst VACATE-FULL-MAX-NONCES 512)
    (defconst VACATE-GAS-MAX-TF 24)
    (defconst VACATE-GAS-MAX-OF 33)
    (defconst VACATE-GAS-MAX-DPSF 29)
    (defconst VACATE-GAS-MAX-DPNF 30)
    (defconst VCT|SEQ-JOB-KEY "JOB")

    ;;<==========>
    ;;CAPABILITIES
    (defcap CAP_VctVacatePoolOwner (pool-id:string)
        @doc "Vacate and session operations require tx sender ownership of pool canonical owner konto."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (ref-AQP::URC_AqpOwnerKonto pool-id))
        )
    )

    (defcap VCT|C>TRUE-FUNGIBLE-VACATE
        (
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (class-ok:bool (ref-AQP::URC_StakeTrueFungiblePoolClassOk pool-id))
                (asset-ok:bool (ref-AQP::URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id))
                (gas-ok:bool (URC_TfOwnerArraysGasOk owner-ids beneficiary-ids amounts))
                (legs:[object{VCT|VacateTfLeg}]
                    (UC_TfLegsFromParallelArrays owner-ids beneficiary-ids amounts))
                (owners-ok:bool (URC_VacateTfLegsOk pool-id dptf-id legs))
            )
            (enforce (fold (and) true [class-ok asset-ok gas-ok owners-ok]) "Invalid TF vacate cap input")
            (CAP_VctVacatePoolOwner pool-id)
            (UEV_TrueFungibleStakeNotReserved dptf-id)
            (compose-capability (P|VCT|RECIPE))
        )
    )
    (defcap VCT|C>ORTO-FUNGIBLE-VACATE-BATCH
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
        )
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (asset-ok:bool (ref-AQP::URC_StakeOrtoFungibleDpofMatchesPool pool-id dpof-id))
                (gas-ok:bool (URC_BatchOwnerArraysGasOk owner-ids beneficiary-ids nonces-array VACATE-GAS-MAX-OF))
                (nonce-ok:bool (URC_VacateBatchNonceTotalOk nonces-array))
            )
            (enforce (fold (and) true [asset-ok gas-ok nonce-ok]) "Invalid OF vacate batch")
            (CAP_VctVacatePoolOwner pool-id)
            (compose-capability (P|VCT|RECIPE))
        )
    )
    (defcap VCT|C>COLLECTABLE-VACATE-BATCH
        (
            pool-id:string
            collectable-id:string
            son:bool
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (class-ok:bool (ref-AQP::URC_StakeCollectablePoolClassOk pool-id son))
                (asset-ok:bool (ref-AQP::URC_StakeCollectableMatchesPool pool-id collectable-id))
                (gas-max:integer
                    (if son VACATE-GAS-MAX-DPSF VACATE-GAS-MAX-DPNF)
                )
                (gas-ok:bool (URC_BatchOwnerArraysGasOk owner-ids beneficiary-ids nonces-array gas-max))
                (nonce-ok:bool (URC_VacateBatchNonceTotalOk nonces-array))
            )
            (enforce (fold (and) true [class-ok asset-ok gas-ok nonce-ok]) "Invalid collectable vacate batch")
            (CAP_VctVacatePoolOwner pool-id)
            (compose-capability (P|VCT|RECIPE))
        )
    )
    (defcap VCT|C>FULL-TRUE-FUNGIBLE-VACATE
        (pool-id:string dptf-id:string legs:[object{VCT|VacateTfLeg}])
        @doc "Master recipe cap: one-tx full TF vacate (pool owner). Validates leg inventory; composes SECURE + P|VCT|RECIPE."
        @event
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (enforce
                (fold (and) true
                    [
                        (ref-AQP::URC_StakeTrueFungiblePoolClassOk pool-id)
                        (ref-AQP::URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id)
                        (URC_VacateTfLegsOk pool-id dptf-id legs)
                    ]
                )
                "Invalid full TF vacate"
            )
            (CAP_VctVacatePoolOwner pool-id)
            (UEV_TrueFungibleStakeNotReserved dptf-id)
            (compose-capability (SECURE))
            (compose-capability (P|VCT|RECIPE))
        )
    )
    (defcap VCT|C>FULL-ORTO-FUNGIBLE-VACATE
        (pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "Master recipe cap: one-tx full OF vacate (pool owner)."
        @event
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (enforce
                (fold (and) true
                    [
                        (ref-AQP::URC_StakeOrtoFungibleDpofMatchesPool pool-id dpof-id)
                        (URC_VacateFullBatchLegParityOk owner-ids beneficiary-ids nonces-array)
                        (URC_VacateFullBatchNonceTotalOk nonces-array)
                    ]
                )
                "Invalid full OF vacate"
            )
            (CAP_VctVacatePoolOwner pool-id)
            (compose-capability (SECURE))
            (compose-capability (P|VCT|RECIPE))
        )
    )
    (defcap VCT|C>FULL-COLLECTABLE-VACATE
        (pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "Master recipe cap: one-tx full DPSF/DPNF vacate (pool owner)."
        @event
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (enforce
                (fold (and) true
                    [
                        (ref-AQP::URC_StakeCollectablePoolClassOk pool-id son)
                        (ref-AQP::URC_StakeCollectableMatchesPool pool-id collectable-id)
                        (URC_VacateFullBatchLegParityOk owner-ids beneficiary-ids nonces-array)
                        (URC_VacateFullBatchNonceTotalOk nonces-array)
                    ]
                )
                "Invalid full collectable vacate"
            )
            (CAP_VctVacatePoolOwner pool-id)
            (compose-capability (SECURE))
            (compose-capability (P|VCT|RECIPE))
        )
    )
    (defcap VCT|C>BEGIN-VACATE
        (pool-id:string asset-id:string vacate-kind:integer slice-count:integer)
        @doc "Master recipe cap: open sliced vacate session (pool owner). All BeginVacate validation lives here."
        @event
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (owner-count:integer
                    (URDC_VacateOwnerCountForKind pool-id asset-id vacate-kind)
                )
                (unit-count:integer
                    (URDC_VacateUnitCountForKind pool-id asset-id vacate-kind)
                )
            )
            (enforce (not (UR_VacateInProgress pool-id)) "Vacate session already in progress on this pool")
            (enforce (URC_VacateKindAssetOk pool-id asset-id vacate-kind) "Invalid vacate kind/asset")
            (enforce (> slice-count 0) "slice-count must be positive")
            (enforce (> owner-count 0) "No active vacate owners for this pool/asset")
            (enforce (> unit-count 0) "No active vacate units for this pool/asset")
            (enforce
                (>= slice-count (UC_ComputeMinSliceCount unit-count vacate-kind))
                "slice-count below minimum for vacate unit count"
            )
            (CAP_VctVacatePoolOwner pool-id)
            (compose-capability (SECURE))
        )
    )
    (defcap VCT|C>RESLICE-VACATE
        (vacate-job-id:string slice-count:integer)
        @doc "Master recipe cap: supersede active job (resliced=true) and open new VacateJobID from live URD."
        @event
        (let
            (
                (pool-id:string (UR_J|PoolId vacate-job-id))
                (asset-id:string (UR_J|AssetId vacate-job-id))
                (kind:integer (UR_J|VacateAssetKind vacate-job-id))
                (owner-count:integer
                    (URDC_VacateOwnerCountForKind pool-id asset-id kind)
                )
                (unit-count:integer
                    (URDC_VacateUnitCountForKind pool-id asset-id kind)
                )
            )
            (enforce (URC_JobIsActive vacate-job-id) "Vacate job is not active")
            (enforce (> owner-count 0) "No remaining vacate owners for reslice")
            (enforce (> unit-count 0) "No remaining vacate units for reslice")
            (enforce (> slice-count 0) "slice-count must be positive")
            (enforce
                (>= slice-count (UC_ComputeMinSliceCount unit-count kind))
                "slice-count below minimum for remaining vacate unit count"
            )
            (CAP_VctVacatePoolOwner pool-id)
            (compose-capability (SECURE))
        )
    )
    (defcap VCT|C>VACATE-CHUNK-TRUE-FUNGIBLE
        (
            vacate-job-id:string
            slice-idx:integer
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
        @doc "Master recipe cap: one TF vacate slice — payload hash vs VCT|T|Slice."
        @event
        (let
            (
                (pool-id:string (UR_J|PoolId vacate-job-id))
                (dptf-id:string (UR_J|AssetId vacate-job-id))
                (payload:object{VCT|SlicePayload}
                    (UDC_TfSlicePayload pool-id dptf-id VACATE-KIND-TF owner-ids beneficiary-ids amounts)
                )
                (expected-hash:string (UC_HashTfSlicePayload payload))
                (kind-ok:bool (= (UR_J|VacateAssetKind vacate-job-id) VACATE-KIND-TF))
                (open-ok:bool
                    (and
                        (URC_JobIsActive vacate-job-id)
                        (not (UR_S|Processed vacate-job-id slice-idx))
                    )
                )
                (hash-ok:bool (= expected-hash (UR_S|SliceHash vacate-job-id slice-idx)))
            )
            (enforce (fold (and) true [kind-ok open-ok hash-ok]) "Invalid TF vacate chunk")
            (CAP_VctVacatePoolOwner pool-id)
            (compose-capability (VCT|C>TRUE-FUNGIBLE-VACATE pool-id dptf-id owner-ids beneficiary-ids amounts))
            (compose-capability (SECURE))
        )
    )
    (defcap VCT|C>VACATE-CHUNK-NONCE
        (
            vacate-job-id:string
            slice-idx:integer
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Master recipe cap: one OF / DPSF / DPNF vacate slice — unified SlicePayload hash."
        @event
        (let
            (
                (pool-id:string (UR_J|PoolId vacate-job-id))
                (asset-id:string (UR_J|AssetId vacate-job-id))
                (kind:integer (UR_J|VacateAssetKind vacate-job-id))
                (payload:object{VCT|SlicePayload}
                    (UDC_NonceSlicePayload
                        pool-id asset-id kind owner-ids beneficiary-ids nonces-array amounts-array
                    )
                )
                (expected-hash:string (UC_HashNonceSlicePayload payload))
                (kind-ok:bool (contains kind [VACATE-KIND-OF VACATE-KIND-DPSF VACATE-KIND-DPNF]))
                (open-ok:bool
                    (and
                        (URC_JobIsActive vacate-job-id)
                        (not (UR_S|Processed vacate-job-id slice-idx))
                    )
                )
                (hash-ok:bool (= expected-hash (UR_S|SliceHash vacate-job-id slice-idx)))
                (of-sentinel-ok:bool
                    (if (= kind VACATE-KIND-OF)
                        (URC_NonceAmountsAreZeroSentinel amounts-array)
                        true
                    )
                )
                (son:bool (UC_VacateKindSon kind))
            )
            (enforce (fold (and) true [kind-ok open-ok hash-ok of-sentinel-ok]) "Invalid nonce vacate chunk")
            (CAP_VctVacatePoolOwner pool-id)
            (if (= kind VACATE-KIND-OF)
                (compose-capability
                    (VCT|C>ORTO-FUNGIBLE-VACATE-BATCH
                        pool-id asset-id owner-ids beneficiary-ids nonces-array
                        (URDC_ResolveOfDecimalAmountsFromTracker
                            pool-id asset-id owner-ids beneficiary-ids nonces-array
                        )
                    )
                )
                (compose-capability
                    (VCT|C>COLLECTABLE-VACATE-BATCH
                        pool-id asset-id son owner-ids beneficiary-ids nonces-array amounts-array
                    )
                )
            )
            (compose-capability (SECURE))
        )
    )
    (defcap VCT|C>ABORT-VACATE
        (vacate-job-id:string)
        @doc "Master recipe cap: abort active vacate session (pool owner); stake stays disabled."
        @event
        (let
            (
                (pool-id:string (UR_J|PoolId vacate-job-id))
            )
            (enforce (URC_JobIsActive vacate-job-id) "Vacate job is not active")
            (CAP_VctVacatePoolOwner pool-id)
            (compose-capability (SECURE))
        )
    )

    ;;<=======>
    ;;FUNCTIONS — UC → UCK → UR → UDC → W → URD → URC → URDC → UEV → C → X
    ;; [UC]
    (defun UC_EmptyOc:object{IgnisCollectorV1.OutputCumulator} ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-IGNIS::DALOS|EmptyOutputCumulatorV2)
        )
    )
    (defun UC_CeilDiv:integer (numerator:integer denominator:integer)
        (if (<= denominator 0)
            numerator
            (let
                (
                    (q:integer (/ numerator denominator))
                    (r:integer (mod numerator denominator))
                )
                (if (= r 0) q (+ q 1))
            )
        )
    )
    (defun UC_GasMaxForKind:integer (vacate-kind:integer)
        (if (= vacate-kind VACATE-KIND-TF)
            VACATE-GAS-MAX-TF
            (if (= vacate-kind VACATE-KIND-OF)
                VACATE-GAS-MAX-OF
                (if (= vacate-kind VACATE-KIND-DPSF) VACATE-GAS-MAX-DPSF VACATE-GAS-MAX-DPNF)
            )
        )
    )
    (defun UC_ComputeMinSliceCount:integer (unit-count:integer vacate-kind:integer)
        @doc "Minimum slice txs: TF unit-count = owner count; OF/DPSF/DPNF unit-count = total nonces."
        (let
            (
                (raw:integer (UC_CeilDiv unit-count (UC_GasMaxForKind vacate-kind)))
            )
            (if (> raw 1) raw 1)
        )
    )
    (defun UC_BatchNonceTotal:integer (nonces-array:[[integer]])
        (fold
            (+)
            0
            (map (lambda (ns:[integer]) (length ns)) nonces-array)
        )
    )
    (defun UC_OwnerRowNonceTotal:integer (owner-rows:[object{VCT|VacateNonceLeg}])
        (fold
            (+)
            0
            (map (lambda (row:object{VCT|VacateNonceLeg}) (length (at "nonces" row))) owner-rows)
        )
    )
    (defun UC_SplitNonceOwnerRowToMax:[object{VCT|VacateNonceLeg}]
        (owner-row:object{VCT|VacateNonceLeg} max-nonces:integer)
        (let
            (
                (ns:[integer] (at "nonces" owner-row))
                (ams:[decimal] (at "amounts" owner-row))
                (owner-id:string (at "owner-id" owner-row))
                (beneficiary-id:string (at "beneficiary-id" owner-row))
                (L:integer (length ns))
                (chunk-count:integer (UC_CeilDiv L max-nonces))
            )
            (if (<= L max-nonces)
                [owner-row]
                (map
                    (lambda (chunk-idx:integer)
                        (let
                            (
                                (start:integer (* chunk-idx max-nonces))
                                (cnt:integer
                                    (if (< max-nonces (- L start)) max-nonces (- L start))
                                )
                            )
                            {
                                "owner-id": owner-id,
                                "beneficiary-id": beneficiary-id,
                                "nonces": (take cnt (drop start ns)),
                                "amounts": (take cnt (drop start ams))
                            }
                        )
                    )
                    (enumerate 0 (- chunk-count 1))
                )
            )
        )
    )
    (defun UC_ExpandNonceOwnerRowsForGasMax:[object{VCT|VacateNonceLeg}]
        (owner-rows:[object{VCT|VacateNonceLeg}] max-nonces:integer)
        (fold
            (lambda
                (acc:[object{VCT|VacateNonceLeg}]
                    owner-row:object{VCT|VacateNonceLeg}
                )
                (+ acc (UC_SplitNonceOwnerRowToMax owner-row max-nonces))
            )
            []
            owner-rows
        )
    )
    (defun UC_VacateKindSon:bool (vacate-kind:integer)
        @doc "Collectable tracker son implied by vacate-kind: DPSF=true, all other kinds false."
        (= vacate-kind VACATE-KIND-DPSF)
    )
    (defun UC_ZeroIntAmountsRow:[integer] (nonces:[integer])
        (map (lambda (_:integer) 0) nonces)
    )
    (defun UC_ZeroIntAmountsMatrix:[[integer]] (nonces-array:[[integer]])
        (map UC_ZeroIntAmountsRow nonces-array)
    )
    (defun UC_DecimalAmountsRowToInt:[integer] (amounts:[decimal])
        (map (lambda (a:decimal) (floor a)) amounts)
    )
    (defun UC_DecimalAmountsMatrixToInt:[[integer]] (rows:[[decimal]])
        (map UC_DecimalAmountsRowToInt rows)
    )
    (defun UC_HashTfSlicePayload:string (payload:object{VCT|SlicePayload})
        (hash
            {"pool-id"              : (at "pool-id" payload)
            ,"asset-id"             : (at "asset-id" payload)
            ,"vacate-asset-kind"    : (at "vacate-asset-kind" payload)
            ,"owner-ids"            : (at "owner-ids" payload)
            ,"beneficiary-ids"      : (at "beneficiary-ids" payload)
            ,"amounts"              : (at "amounts" payload)}
        )
    )
    (defun UC_HashNonceSlicePayload:string (payload:object{VCT|SlicePayload})
        (hash
            {"pool-id"              : (at "pool-id" payload)
            ,"asset-id"             : (at "asset-id" payload)
            ,"vacate-asset-kind"    : (at "vacate-asset-kind" payload)
            ,"owner-ids"            : (at "owner-ids" payload)
            ,"beneficiary-ids"      : (at "beneficiary-ids" payload)
            ,"nonces-array"         : (at "nonces-array" payload)
            ,"amounts-array"        : (at "amounts-array" payload)}
        )
    )
    (defun UC_HashSlicePayload:string (slice:object{VCT|SlicePayload})
        (if (= (at "vacate-asset-kind" slice) VACATE-KIND-TF)
            (UC_HashTfSlicePayload slice)
            (UC_HashNonceSlicePayload slice)
        )
    )
    (defun UC_HashSlicePlanManifest:string
        (vacate-job-id:string slice-hashes:[string])
        (hash {"vacate-job-id" : vacate-job-id, "slice-hashes" : slice-hashes})
    )
    (defun UC_TfSlicePayloadFromOwnerRows:object{VCT|SlicePayload}
        (pool-id:string asset-id:string owner-rows:[object{VCT|VacateTfLeg}])
        (UDC_TfSlicePayload
            pool-id
            asset-id
            VACATE-KIND-TF
            (map (lambda (row:object{VCT|VacateTfLeg}) (at "owner-id" row)) owner-rows)
            (map (lambda (row:object{VCT|VacateTfLeg}) (at "beneficiary-id" row)) owner-rows)
            (map (lambda (row:object{VCT|VacateTfLeg}) (at "balance" row)) owner-rows)
        )
    )
    (defun UC_NonceSlicePayloadFromOwnerRows:object{VCT|SlicePayload}
        (pool-id:string asset-id:string vacate-kind:integer owner-rows:[object{VCT|VacateNonceLeg}])
        (let
            (
                (nonces-array:[[integer]]
                    (map (lambda (row:object{VCT|VacateNonceLeg}) (at "nonces" row)) owner-rows)
                )
                (amounts-array:[[integer]]
                    (if (= vacate-kind VACATE-KIND-OF)
                        (UC_ZeroIntAmountsMatrix nonces-array)
                        (UC_DecimalAmountsMatrixToInt
                            (map (lambda (row:object{VCT|VacateNonceLeg}) (at "amounts" row)) owner-rows)
                        )
                    )
                )
            )
            (UDC_NonceSlicePayload
                pool-id
                asset-id
                vacate-kind
                (map (lambda (row:object{VCT|VacateNonceLeg}) (at "owner-id" row)) owner-rows)
                (map (lambda (row:object{VCT|VacateNonceLeg}) (at "beneficiary-id" row)) owner-rows)
                nonces-array
                amounts-array
            )
        )
    )
    (defun UC_BuildTfVacateSlicePlanFromOwnerRows:object{VCT|VacateSlicePlan}
        (
            pool-id:string
            asset-id:string
            slice-count:integer
            owner-rows:[object{VCT|VacateTfLeg}]
        )
        @doc "Pure compute: partition TF owner-rows into slice payloads (no table reads)."
        (let
            (
                (L:integer (length owner-rows))
                (N:integer slice-count)
                (owners-per-slice:integer (UC_CeilDiv L N))
            )
            (UDC_VacateSlicePlan
                ""
                pool-id
                asset-id
                VACATE-KIND-TF
                slice-count
                (map
                    (lambda (slice-idx:integer)
                        (let
                            (
                                (start:integer (* slice-idx owners-per-slice))
                                (count:integer
                                    (if (< owners-per-slice (- L start)) owners-per-slice (- L start))
                                )
                                (slice-owner-rows:[object{VCT|VacateTfLeg}]
                                    (if (= count 0) [] (take count (drop start owner-rows)))
                                )
                            )
                            (UC_TfSlicePayloadFromOwnerRows pool-id asset-id slice-owner-rows)
                        )
                    )
                    (enumerate 0 (- N 1))
                )
            )
        )
    )
    (defun UC_BuildNonceVacateSlicePlanFromOwnerRows:object{VCT|VacateSlicePlan}
        (
            pool-id:string
            asset-id:string
            vacate-kind:integer
            slice-count:integer
            owner-rows:[object{VCT|VacateNonceLeg}]
        )
        @doc "Pure compute: partition nonce owner-rows into slice payloads (no table reads)."
        (let
            (
                (L:integer (length owner-rows))
                (N:integer slice-count)
                (owners-per-slice:integer (UC_CeilDiv L N))
            )
            (UDC_VacateSlicePlan
                ""
                pool-id
                asset-id
                vacate-kind
                slice-count
                (map
                    (lambda (slice-idx:integer)
                        (let
                            (
                                (start:integer (* slice-idx owners-per-slice))
                                (count:integer
                                    (if (< owners-per-slice (- L start)) owners-per-slice (- L start))
                                )
                                (slice-owner-rows:[object{VCT|VacateNonceLeg}]
                                    (if (= count 0) [] (take count (drop start owner-rows)))
                                )
                            )
                            (UC_NonceSlicePayloadFromOwnerRows pool-id asset-id vacate-kind slice-owner-rows)
                        )
                    )
                    (enumerate 0 (- N 1))
                )
            )
        )
    )
    (defun UC_SlicePlanOc:object{IgnisCollectorV1.OutputCumulator}
        (plan:object{VCT|VacateSlicePlan})
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (vacate-job-id:string (at "vacate-job-id" plan))
                (slice-strs:[string]
                    (map (lambda (s:object{VCT|SlicePayload}) (format "{}" [s])) (at "slices" plan))
                )
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-DALOS::UR_UsagePrice "ignis|smallest")
                AQP|SC_NAME
                true
                (+ [vacate-job-id (format "{}" [plan])] slice-strs)
            )
        )
    )

    ;;{F0}  [UCK]
    (defun UCK_Slice:string (vacate-job-id:string slice-idx:integer)
        @doc "Composite key for VCT|T|Slice (vacate-job-id BAR slice-idx)."
        (concat [vacate-job-id BAR (format "{}" [slice-idx])])
    )

    ;;{F0}  [UR]
    ;;{F1} [1] VCT|Job — key = vacate-job-id
    (defun UR_Job:object (vacate-job-id:string)
        (with-default-read VCT|T|Job vacate-job-id
            (UDC_Job "" "" 0 0 "" false false false vacate-job-id)
            {"pool-id"                  := pid
            ,"asset-id"                 := aid
            ,"vacate-asset-kind"        := vk
            ,"slice-count"              := sc
            ,"initial-manifest-hash"    := imh
            ,"finalized"                := fi
            ,"aborted"                  := ab
            ,"resliced"                 := rs
            ,"vacate-job-id"            := vjid}
            (UDC_Job pid aid vk sc imh fi ab rs vjid)
        )
    )
    (defun UR_J|PoolId:string (vacate-job-id:string)
        (at "pool-id" (read VCT|T|Job vacate-job-id ["pool-id"]))
    )
    (defun UR_J|AssetId:string (vacate-job-id:string)
        (at "asset-id" (read VCT|T|Job vacate-job-id ["asset-id"]))
    )
    (defun UR_J|VacateAssetKind:integer (vacate-job-id:string)
        (at "vacate-asset-kind" (read VCT|T|Job vacate-job-id ["vacate-asset-kind"]))
    )
    (defun UR_J|SliceCount:integer (vacate-job-id:string)
        (at "slice-count" (read VCT|T|Job vacate-job-id ["slice-count"]))
    )
    (defun UR_J|InitialManifestHash:string (vacate-job-id:string)
        (at "initial-manifest-hash" (read VCT|T|Job vacate-job-id ["initial-manifest-hash"]))
    )
    (defun UR_J|Finalized:bool (vacate-job-id:string)
        (at "finalized" (read VCT|T|Job vacate-job-id ["finalized"]))
    )
    (defun UR_J|Aborted:bool (vacate-job-id:string)
        (at "aborted" (read VCT|T|Job vacate-job-id ["aborted"]))
    )
    (defun UR_J|Resliced:bool (vacate-job-id:string)
        (at "resliced" (read VCT|T|Job vacate-job-id ["resliced"]))
    )
    (defun UR_J|VacateJobId:string (vacate-job-id:string)
        (at "vacate-job-id" (read VCT|T|Job vacate-job-id ["vacate-job-id"]))
    )

    ;;{F1} [2] VCT|Slice — key = UCK_Slice(vacate-job-id, slice-idx)
    (defun UR_Slice:object (vacate-job-id:string slice-idx:integer)
        (read VCT|T|Slice (UCK_Slice vacate-job-id slice-idx))
    )
    (defun UR_S|SliceHash:string (vacate-job-id:string slice-idx:integer)
        (at "slice-hash" (read VCT|T|Slice (UCK_Slice vacate-job-id slice-idx) ["slice-hash"]))
    )
    (defun UR_S|Processed:bool (vacate-job-id:string slice-idx:integer)
        (at "processed" (read VCT|T|Slice (UCK_Slice vacate-job-id slice-idx) ["processed"]))
    )
    (defun UR_S|VacateJobId:string (vacate-job-id:string slice-idx:integer)
        (at "vacate-job-id" (read VCT|T|Slice (UCK_Slice vacate-job-id slice-idx) ["vacate-job-id"]))
    )
    (defun UR_S|SliceIdx:integer (vacate-job-id:string slice-idx:integer)
        (at "slice-idx" (read VCT|T|Slice (UCK_Slice vacate-job-id slice-idx) ["slice-idx"]))
    )

    ;;{F1} [3] VCT|Seq — singleton row VCT|SEQ-JOB-KEY
    (defun UR_Seq|NextId:integer ()
        (with-default-read VCT|T|Seq VCT|SEQ-JOB-KEY
            {"next-id" : 0}
            {"next-id" := n}
            n
        )
    )

    ;; [UDC]
    (defun UDC_TfSlicePayload:object{VCT|SlicePayload}
        (
            pool-id:string
            asset-id:string
            vacate-asset-kind:integer
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
        {"pool-id"              : pool-id
        ,"asset-id"             : asset-id
        ,"vacate-asset-kind"    : vacate-asset-kind
        ,"owner-ids"            : owner-ids
        ,"beneficiary-ids"      : beneficiary-ids
        ,"amounts"              : amounts
        ,"nonces-array"         : []
        ,"amounts-array"        : []}
    )
    (defun UDC_NonceSlicePayload:object{VCT|SlicePayload}
        (
            pool-id:string
            asset-id:string
            vacate-asset-kind:integer
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        {"pool-id"              : pool-id
        ,"asset-id"             : asset-id
        ,"vacate-asset-kind"    : vacate-asset-kind
        ,"owner-ids"            : owner-ids
        ,"beneficiary-ids"      : beneficiary-ids
        ,"amounts"              : []
        ,"nonces-array"         : nonces-array
        ,"amounts-array"        : amounts-array}
    )
    (defun UDC_VacateSlicePlan:object{VCT|VacateSlicePlan}
        (
            vacate-job-id:string
            pool-id:string
            asset-id:string
            vacate-asset-kind:integer
            slice-count:integer
            slices:[object{VCT|SlicePayload}]
        )
        {"vacate-job-id"        : vacate-job-id
        ,"pool-id"              : pool-id
        ,"asset-id"             : asset-id
        ,"vacate-asset-kind"    : vacate-asset-kind
        ,"slice-count"          : slice-count
        ,"slices"               : slices}
    )
    (defun UDC_Job:object{VCT|Job}
        (
            pool-id:string
            asset-id:string
            vacate-asset-kind:integer
            slice-count:integer
            initial-manifest-hash:string
            finalized:bool
            aborted:bool
            resliced:bool
            vacate-job-id:string
        )
        {"pool-id"                  : pool-id
        ,"asset-id"                 : asset-id
        ,"vacate-asset-kind"        : vacate-asset-kind
        ,"slice-count"              : slice-count
        ,"initial-manifest-hash"    : initial-manifest-hash
        ,"finalized"                : finalized
        ,"aborted"                  : aborted
        ,"resliced"                 : resliced
        ,"vacate-job-id"            : vacate-job-id}
    )
    (defun UDC_Slice:object{VCT|Slice}
        (slice-hash:string processed:bool vacate-job-id:string slice-idx:integer)
        {"slice-hash"       : slice-hash
        ,"processed"        : processed
        ,"vacate-job-id"    : vacate-job-id
        ,"slice-idx"        : slice-idx}
    )

    ;;{FW}  [W]
    ;; Three blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    ;; [1] VCT|T|Job  (VCT|Job)  Key = <Vacate-Job-ID>
    (defun WI_Job:string
        (vacate-job-id:string job:object{VCT|Job})
        @doc "Insert VCT|T|Job full row (open begin / reslice new session)."
        (require-capability (SECURE))
        (insert VCT|T|Job vacate-job-id job)
    )
    ;; WW_Job — not used: issue path is WI_Job; terminal flags use WU_*.
    ;; WU_Job|PoolId — not mutable [.]
    ;; WU_Job|AssetId — not mutable [.]
    ;; WU_Job|VacateAssetKind — not mutable [.]
    ;; WU_Job|SliceCount — not mutable [.]
    ;; WU_Job|InitialManifestHash — not mutable [.]
    (defun WU_Job|Finalized:string
        (vacate-job-id:string)
        @doc "Set finalized=true on VCT|T|Job."
        (require-capability (SECURE))
        (update VCT|T|Job vacate-job-id {"finalized": true})
    )
    (defun WU_Job|Aborted:string
        (vacate-job-id:string)
        @doc "Set aborted=true on VCT|T|Job."
        (require-capability (SECURE))
        (update VCT|T|Job vacate-job-id {"aborted": true})
    )
    (defun WU_Job|Resliced:string
        (vacate-job-id:string)
        @doc "Set resliced=true on VCT|T|Job."
        (require-capability (SECURE))
        (update VCT|T|Job vacate-job-id {"resliced": true})
    )
    ;; WU_Job|VacateJobId — select key; WU not needed.
    ;;
    ;; [2] VCT|T|Slice  (VCT|Slice)  Key = UCK_Slice(vacate-job-id, slice-idx)
    (defun WI_Slice:string
        (vacate-job-id:string slice-idx:integer row:object{VCT|Slice})
        @doc "Insert VCT|T|Slice hash commitment row (begin / reslice)."
        (require-capability (SECURE))
        (insert VCT|T|Slice (UCK_Slice vacate-job-id slice-idx) row)
    )
    ;; WW_Slice — not used: issue path is WI_Slice; processed uses WU_Slice|Processed.
    ;; WU_Slice|SliceHash — not mutable [.]
    (defun WU_Slice|Processed:string
        (vacate-job-id:string slice-idx:integer)
        @doc "Set processed=true on VCT|T|Slice."
        (require-capability (SECURE))
        (update VCT|T|Slice (UCK_Slice vacate-job-id slice-idx) {"processed": true})
    )
    ;; WU_Slice|VacateJobId — select key; WU not needed.
    ;; WU_Slice|SliceIdx — select key; WU not needed.
    ;;
    ;; [3] VCT|T|Seq  (VCT|SeqCounter)  Key = constant VCT|SEQ-JOB-KEY ("JOB")
    ;; WI_Seq — not used: first row touch is WW_Seq (upsert path).
    (defun WW_Seq:string
        (next-id:integer)
        @doc "Upsert singleton VCT|T|Seq next-id counter (VacateJobID mint)."
        (require-capability (SECURE))
        (write VCT|T|Seq VCT|SEQ-JOB-KEY {"next-id": next-id})
    )
    ;; WU_Seq|NextId — not used: mutates via WW_Seq (full row).

    ;; [URD]
    (defun URD_SlicesForJob:[object] (vacate-job-id:string)
        (select VCT|T|Slice
            ["slice-hash" "processed" "vacate-job-id" "slice-idx"]
            (where "vacate-job-id" (= vacate-job-id))
        )
    )
    (defun URD_JobRowsForPool:[object{VCT|Job}] (pool-id:string)
        (select VCT|T|Job
            ["vacate-job-id" "pool-id" "asset-id" "vacate-asset-kind" "slice-count" "initial-manifest-hash" "finalized" "aborted" "resliced"]
            (where "pool-id" (= pool-id))
        )
    )

    ;; [URC]
    (defun URC_TfOwnerArraysGasOk:bool
        (owner-ids:[string] beneficiary-ids:[string] amounts:[decimal])
        (let
            (
                (l:integer (length owner-ids))
            )
            (fold
                (and)
                true
                [
                    (> l 0)
                    (<= l VACATE-GAS-MAX-TF)
                    (= l (length beneficiary-ids))
                    (= l (length amounts))
                ]
            )
        )
    )
    (defun URC_BatchOwnerArraysGasOk:bool
        (owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] gas-max:integer)
        @doc "OF/DPSF/DPNF chunk gas: gas-max caps total nonces across rows, not owner row count."
        (let
            (
                (l:integer (length owner-ids))
                (nonce-total:integer (UC_BatchNonceTotal nonces-array))
            )
            (fold
                (and)
                true
                [
                    (> l 0)
                    (> nonce-total 0)
                    (<= nonce-total gas-max)
                    (= l (length beneficiary-ids))
                    (= l (length nonces-array))
                ]
            )
        )
    )
    (defun URC_VacateKindAssetOk:bool
        (pool-id:string asset-id:string vacate-kind:integer)
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (if (= vacate-kind VACATE-KIND-TF)
                (fold
                    (and)
                    true
                    [
                        (ref-AQP::URC_StakeTrueFungiblePoolClassOk pool-id)
                        (ref-AQP::URC_StakeTrueFungibleDptfMatchesPool pool-id asset-id)
                    ]
                )
                (if (= vacate-kind VACATE-KIND-OF)
                    (ref-AQP::URC_StakeOrtoFungibleDpofMatchesPool pool-id asset-id)
                    (if (= vacate-kind VACATE-KIND-DPSF)
                        (fold
                            (and)
                            true
                            [
                                (ref-AQP::URC_StakeCollectablePoolClassOk pool-id true)
                                (ref-AQP::URC_StakeCollectableMatchesPool pool-id asset-id)
                            ]
                        )
                        (if (= vacate-kind VACATE-KIND-DPNF)
                            (fold
                                (and)
                                true
                                [
                                    (ref-AQP::URC_StakeCollectablePoolClassOk pool-id false)
                                    (ref-AQP::URC_StakeCollectableMatchesPool pool-id asset-id)
                                ]
                            )
                            false
                        )
                    )
                )
            )
        )
    )

    (defun URC_JobIsActive:bool (vacate-job-id:string)
        (fold
            (and)
            true
            [
                (not (UR_J|Finalized vacate-job-id))
                (not (UR_J|Aborted vacate-job-id))
                (not (UR_J|Resliced vacate-job-id))
            ]
        )
    )
    (defun URC_NonceAmountsAreZeroSentinel:bool (amounts-array:[[integer]])
        (fold
            (and)
            true
            (map
                (lambda (row:[integer])
                    (fold (and) true (map (lambda (x:integer) (= x 0)) row))
                )
                amounts-array
            )
        )
    )

    (defun URC_PoolHasActiveJob:bool (pool-id:string)
        (> (length
            (filter
                (lambda (row:object{VCT|Job}) (URC_JobIsActive (at "vacate-job-id" row)))
                (URD_JobRowsForPool pool-id)
            )
        ) 0)
    )

    ;; [URDC]
    (defun URDC_VacateTfOwnerRows:[object{VCT|VacateTfLeg}]
        (pool-id:string dptf-id:string)
        @doc "TF vacate owner rows from URD_VacateTfInventory."
        (at "legs" (URD_VacateTfInventory pool-id dptf-id))
    )
    (defun URDC_VacateNonceOwnerRowsRaw:[object{VCT|VacateNonceLeg}]
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "Grouped nonce vacate owner rows from VCT inventory URD (unexpanded)."
        (let ((son:bool (UC_VacateKindSon vacate-kind)))
            (if (= vacate-kind VACATE-KIND-OF)
                (at "legs" (URD_VacateOfInventory pool-id asset-id))
                (at "legs" (URD_VacateCollectableInventory pool-id asset-id son))
            )
        )
    )
    (defun URDC_VacateNonceOwnerRows:[object{VCT|VacateNonceLeg}]
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "Nonce vacate owner rows gas-expanded for slice/full vacate chunk limits."
        (UC_ExpandNonceOwnerRowsForGasMax
            (URDC_VacateNonceOwnerRowsRaw pool-id asset-id vacate-kind)
            (UC_GasMaxForKind vacate-kind)
        )
    )
    (defun URDC_BuildVacateSlicePlan:object
        (pool-id:string asset-id:string vacate-kind:integer slice-count:integer)
        @doc "Slice plan from live pool inventory (URDC read + UC partition)."
        (if (= vacate-kind VACATE-KIND-TF)
            (UC_BuildTfVacateSlicePlanFromOwnerRows
                pool-id
                asset-id
                slice-count
                (URDC_VacateTfOwnerRows pool-id asset-id)
            )
            (UC_BuildNonceVacateSlicePlanFromOwnerRows
                pool-id
                asset-id
                vacate-kind
                slice-count
                (URDC_VacateNonceOwnerRows pool-id asset-id vacate-kind)
            )
        )
    )
    (defun URDC_AllSlicesProcessed:bool (vacate-job-id:string)
        (let
            (
                (slice-count:integer (UR_J|SliceCount vacate-job-id))
                (rows:[object{VCT|Slice}] (URD_SlicesForJob vacate-job-id))
            )
            (if (= (length rows) slice-count)
                (fold
                    (and)
                    true
                    (map
                        (lambda (row:object{VCT|Slice})
                            (UR_S|Processed vacate-job-id (at "slice-idx" row))
                        )
                        rows
                    )
                )
                false
            )
        )
    )
    (defun URDC_ActiveJobForPool:object
        (pool-id:string)
        @doc "Active vacate job for pool (exactly one expected while session open)."
        (let
            (
                (rows:[object{VCT|Job}] (URD_JobRowsForPool pool-id))
                (active:[object{VCT|Job}]
                    (filter
                        (lambda (row:object{VCT|Job})
                            (URC_JobIsActive (at "vacate-job-id" row))
                        )
                        rows
                    )
                )
            )
            (enforce (= (length active) 1) "Expected exactly one active vacate job for pool")
            (at 0 active)
        )
    )
    (defun URDC_ResolveOfDecimalAmountsFromTracker
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
        )
        @doc "Derive whole-nonce decimal amounts from pool tracker for FVT vacate owner-row unwind."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (map
                (lambda (idx:integer)
                    (map
                        (lambda (n:integer)
                            (ref-AQP::UR_AQP|DPOFTrackerBalance
                                pool-id dpof-id (at idx owner-ids) (at idx beneficiary-ids) n
                            )
                        )
                        (at idx nonces-array)
                    )
                )
                (enumerate 0 (- (length owner-ids) 1))
            )
        )
    )
    (defun URDC_VacateOwnerCountForKind:integer
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "Owner-row count from live vacate inventory — UI preflight before C_BeginVacate."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (son:bool (UC_VacateKindSon vacate-kind))
            )
            (if (= vacate-kind VACATE-KIND-TF)
                (at "leg-count" (URD_VacateTfInventory pool-id asset-id))
                (if (= vacate-kind VACATE-KIND-OF)
                    (at "leg-count" (URD_VacateOfInventory pool-id asset-id))
                    (at "leg-count" (URD_VacateCollectableInventory pool-id asset-id son))
                )
            )
        )
    )
    (defun URDC_VacateNonceTotalForKind:integer
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "Sum of nonces across all owner rows — gas unit for OF/DPSF/DPNF slice planning."
        (UC_OwnerRowNonceTotal (URDC_VacateNonceOwnerRowsRaw pool-id asset-id vacate-kind))
    )
    (defun URDC_VacateUnitCountForKind:integer
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "TF → owner count; OF/DPSF/DPNF → total nonce count (for UC_ComputeMinSliceCount)."
        (if (= vacate-kind VACATE-KIND-TF)
            (URDC_VacateOwnerCountForKind pool-id asset-id vacate-kind)
            (URDC_VacateNonceTotalForKind pool-id asset-id vacate-kind)
        )
    )
    ;; [UEV]
    (defun UEV_TrueFungibleStakeNotReserved (dptf-id:string)
        (enforce (not (= (take 2 dptf-id) "R|")) "Reserved DPTF (R|) cannot be vacated")
    )
    ;;{F5b}  vacate inventory / validation / leg helpers
    ;;
    (defun UDC_VacateTfLeg:object{VCT|VacateTfLeg}
        (owner-id:string beneficiary-id:string balance:decimal)
        {"owner-id" : owner-id, "beneficiary-id" : beneficiary-id, "balance" : balance}
    )
    (defun UDC_VacateNonceRow:object{VCT|VacateNonceRow}
        (owner-id:string beneficiary-id:string nonce:integer balance:decimal)
        {"owner-id" : owner-id, "beneficiary-id" : beneficiary-id, "nonce" : nonce, "balance" : balance}
    )
    (defun UDC_VacateNonceLeg:object{VCT|VacateNonceLeg}
        (owner-id:string beneficiary-id:string nonces:[integer] amounts:[decimal])
        {"owner-id" : owner-id, "beneficiary-id" : beneficiary-id, "nonces" : nonces, "amounts" : amounts}
    )
    (defun UDC_VacateTfInventory:object{VCT|VacateTfInventory}
        (legs:[object{VCT|VacateTfLeg}])
        {"legs" : legs, "leg-count" : (length legs)}
    )
    (defun UDC_VacateNonceLegInventory:object{VCT|VacateNonceLegInventory}
        (legs:[object{VCT|VacateNonceLeg}])
        {"legs" : legs, "leg-count" : (length legs)}
    )
    (defun UR_VacateInProgress:bool (pool-id:string)
        (at "vacate-in-progress" (UR_VacateSessionFields pool-id))
    )
    (defun UR_InitialVacateHash:string (pool-id:string)
        (at "initial-vacate-hash" (UR_VacateSessionFields pool-id))
    )
    (defun UR_PhaseVacateHash:string (pool-id:string)
        (at "phase-vacate-hash" (UR_VacateSessionFields pool-id))
    )
    (defun UR_LastVacateHash:string (pool-id:string)
        (at "last-vacate-hash" (UR_VacateSessionFields pool-id))
    )
    (defun UR_VacateSessionFields:object
        (pool-id:string)
        (let ((ref-AQP:module{AcquisitionPoolsV1} AQP-POOL))
            (ref-AQP::UR_AQP|PoolVacateSession pool-id)
        )
    )
    (defun URD_VacateTfInventory:object (pool-id:string dptf-id:string)
        (let ((ref-AQP:module{AcquisitionPoolsV1} AQP-POOL))
            (UDC_VacateTfInventory
                (map
                    (lambda (row:object)
                        (UDC_VacateTfLeg (at "owner-id" row) (at "beneficiary-id" row) (at "balance" row))
                    )
                    (ref-AQP::URD_AQP|ActiveDptfTrackerRows pool-id dptf-id)
                )
            )
        )
    )
    (defun URD_VacateOfNonceRows:[object{VCT|VacateNonceRow}] (pool-id:string dpof-id:string)
        (let ((ref-AQP:module{AcquisitionPoolsV1} AQP-POOL))
            (map
                (lambda (row:object)
                    (UDC_VacateNonceRow (at "owner-id" row) (at "beneficiary-id" row) (at "nonce" row) (at "balance" row))
                )
                (ref-AQP::URD_AQP|ActiveDpofTrackerRows pool-id dpof-id)
            )
        )
    )
    (defun URD_VacateOfInventory:object (pool-id:string dpof-id:string)
        (UDC_VacateNonceLegInventory
            (fold
                (lambda (acc:[object{VCT|VacateNonceLeg}] row:object{VCT|VacateNonceRow})
                    (UC_MergeVacateNonceRowIntoLegs acc (at "owner-id" row) (at "beneficiary-id" row) (at "nonce" row) (at "balance" row))
                )
                []
                (URD_VacateOfNonceRows pool-id dpof-id)
            )
        )
    )
    (defun URD_VacateCollectableNonceRows:[object{VCT|VacateNonceRow}]
        (pool-id:string collectable-id:string son:bool)
        (let ((ref-AQP:module{AcquisitionPoolsV1} AQP-POOL))
            (map
                (lambda (row:object)
                    (UDC_VacateNonceRow (at "owner-id" row) (at "beneficiary-id" row) (at "nonce" row) (at "balance" row))
                )
                (if son
                    (ref-AQP::URD_AQP|ActiveDpsfTrackerRows pool-id collectable-id)
                    (ref-AQP::URD_AQP|ActiveDpnfTrackerRows pool-id collectable-id)
                )
            )
        )
    )
    (defun URD_VacateCollectableInventory:object
        (pool-id:string collectable-id:string son:bool)
        (UDC_VacateNonceLegInventory
            (fold
                (lambda (acc:[object{VCT|VacateNonceLeg}] row:object{VCT|VacateNonceRow})
                    (UC_MergeVacateCollectableRowIntoLegs acc (at "owner-id" row) (at "beneficiary-id" row) (at "nonce" row) (at "balance" row))
                )
                []
                (URD_VacateCollectableNonceRows pool-id collectable-id son)
            )
        )
    )
    (defun URC_VacateOrtoLegBeneficiaryOk:bool
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonces:[integer])
        @doc "Vacate: each DPOF nonce tracker row beneficiary-id must equal the supplied beneficiary-id."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (l:integer (length nonces))
            )
            (fold
                (and)
                true
                (map
                    (lambda (idx:integer)
                        (let
                            (
                                (n:integer (at idx nonces))
                                (row-ben:string
                                    (ref-AQP::UR_AQP|DPOFTrackerBeneficiaryId pool-id dpof-id owner-id beneficiary-id n)
                                )
                            )
                            (= row-ben beneficiary-id)
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_VacateOrtoNoncesSufficient:bool
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "Vacate: each DPOF nonce amount must equal full tracker row (no partial vacate)."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (l:integer (length nonces))
            )
            (fold
                (and)
                true
                (map
                    (lambda (idx:integer)
                        (let
                            (
                                (n:integer (at idx nonces))
                                (q:decimal (at idx nonce-amounts))
                                (bal:decimal
                                    (ref-AQP::UR_AQP|DPOFTrackerBalance pool-id dpof-id owner-id beneficiary-id n)
                                )
                            )
                            (= bal q)
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_VacateTfLegBalancesOk:bool
        (pool-id:string dptf-id:string owner-id:string beneficiary-id:string amount:decimal)
        @doc "Vacate: amount must equal full DPTFTracker row (no partial vacate); rollup must cover amount."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (staked-bal:decimal (ref-AQP::UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
                (rollup-bal:decimal (ref-AQP::UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
            )
            (fold (and) true [(> amount 0.0) (= amount staked-bal) (>= rollup-bal amount)])
        )
    )
    (defun UC_MergeVacateNonceRowIntoLegs:[object{VCT|VacateNonceLeg}]
        (acc:[object{VCT|VacateNonceLeg}] owner-id:string beneficiary-id:string nonce:integer amount:decimal)
        @doc "Fold step: append one active nonce row into grouped vacate legs (owner × beneficiary)."
        (if (= (length acc) 0)
            [
                (UDC_VacateNonceLeg owner-id beneficiary-id [nonce] [amount])
            ]
            (let
                (
                    (last-idx:integer (- (length acc) 1))
                    (last:object{VCT|VacateNonceLeg} (at last-idx acc))
                    (last-owner:string (at "owner-id" last))
                    (last-ben:string (at "beneficiary-id" last))
                )
                (if (and (= owner-id last-owner) (= beneficiary-id last-ben))
                    (+ (take last-idx acc)
                        [
                            (UDC_VacateNonceLeg
                                owner-id
                                beneficiary-id
                                (+ (at "nonces" last) [nonce])
                                (+ (at "amounts" last) [amount])
                            )
                        ]
                    )
                    (+ acc
                        [
                            (UDC_VacateNonceLeg owner-id beneficiary-id [nonce] [amount])
                        ]
                    )
                )
            )
        )
    )
    (defun UC_MergeVacateCollectableRowIntoLegs:[object{VCT|VacateNonceLeg}]
        (acc:[object{VCT|VacateNonceLeg}] owner-id:string beneficiary-id:string nonce:integer amount:decimal)
        @doc "Fold step for collectable vacate legs — same grouping as UC_MergeVacateNonceRowIntoLegs."
        (if (= (length acc) 0)
            [
                (UDC_VacateNonceLeg owner-id beneficiary-id [nonce] [amount])
            ]
            (let
                (
                    (last-idx:integer (- (length acc) 1))
                    (last:object{VCT|VacateNonceLeg} (at last-idx acc))
                    (last-owner:string (at "owner-id" last))
                    (last-ben:string (at "beneficiary-id" last))
                )
                (if (and (= owner-id last-owner) (= beneficiary-id last-ben))
                    (+ (take last-idx acc)
                        [
                            (UDC_VacateNonceLeg
                                owner-id
                                beneficiary-id
                                (+ (at "nonces" last) [nonce])
                                (+ (at "amounts" last) [amount])
                            )
                        ]
                    )
                    (+ acc
                        [
                            (UDC_VacateNonceLeg owner-id beneficiary-id [nonce] [amount])
                        ]
                    )
                )
            )
        )
    )
    (defun UC_VacateDecimalAmountsToIntegers:[integer] (amounts:[decimal])
        @doc "Collectable vacate: tracker decimal balances → integer amounts for DPDC-T bulk."
        (map
            (lambda (idx:integer) (floor (at idx amounts)))
            (enumerate 0 (- (length amounts) 1))
        )
    )
    (defun UC_VacateOfLegsToVacateArrays:object (legs:[object{VCT|VacateNonceLeg}])
        @doc "Build parallel OF vacate batch arrays from VacateOfInventory legs (object{VCT|VacateNonceLeg}). Module: AQP-VCT."
        {
            "owner-ids"             : (map (lambda (leg:object{VCT|VacateNonceLeg}) (at "owner-id" leg)) legs)
            ,"beneficiary-ids"      : (map (lambda (leg:object{VCT|VacateNonceLeg}) (at "beneficiary-id" leg)) legs)
            ,"nonces-array"         : (map (lambda (leg:object{VCT|VacateNonceLeg}) (at "nonces" leg)) legs)
            ,"nonce-amounts-array"  : (map (lambda (leg:object{VCT|VacateNonceLeg}) (at "amounts" leg)) legs)
        }
    )
    (defun UC_VacateCollectableLegsToVacateArrays:object (legs:[object{VCT|VacateNonceLeg}])
        @doc "Build parallel collectable vacate batch arrays from VacateCollectableInventory legs. \
            \ Integer amounts via UC_VacateDecimalAmountsToIntegers. Module: AQP-VCT."
        {
            "owner-ids"         : (map (lambda (leg:object{VCT|VacateNonceLeg}) (at "owner-id" leg)) legs)
            ,"beneficiary-ids"  : (map (lambda (leg:object{VCT|VacateNonceLeg}) (at "beneficiary-id" leg)) legs)
            ,"nonces-array"     : (map (lambda (leg:object{VCT|VacateNonceLeg}) (at "nonces" leg)) legs)
            ,"amounts-array"    : (map
                (lambda (leg:object{VCT|VacateNonceLeg})
                    (UC_VacateDecimalAmountsToIntegers (at "amounts" leg))
                )
                legs
            )
        }
    )
    (defun URC_VacateBatchLegParityOk:bool
        (owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "Vacate batch: owner/beneficiary/nonce legs same positive length ≤ VACATE-MAX-LEGS."
        (let
            (
                (l:integer (length owner-ids))
            )
            (fold
                (and)
                true
                [
                    (> l 0)
                    (<= l VACATE-MAX-LEGS)
                    (= l (length beneficiary-ids))
                    (= l (length nonces-array))
                ]
            )
        )
    )
    (defun URC_VacateBatchNonceTotalOk:bool (nonces-array:[[integer]])
        @doc "Vacate batch: total nonce count across legs is positive and ≤ VACATE-MAX-NONCES."
        (let
            (
                (tot:integer
                    (fold
                        (+)
                        0
                        (map
                            (lambda (ns:[integer]) (length ns))
                            nonces-array
                        )
                    )
                )
            )
            (fold (and) true [(> tot 0) (<= tot VACATE-MAX-NONCES)])
        )
    )
    (defun URC_VacateFullBatchLegParityOk:bool
        (owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "Full vacate: owner/beneficiary/nonce legs same positive length ≤ VACATE-FULL-MAX-LEGS."
        (let
            (
                (l:integer (length owner-ids))
            )
            (fold
                (and)
                true
                [
                    (> l 0)
                    (<= l VACATE-FULL-MAX-LEGS)
                    (= l (length beneficiary-ids))
                    (= l (length nonces-array))
                ]
            )
        )
    )
    (defun URC_VacateFullBatchNonceTotalOk:bool (nonces-array:[[integer]])
        @doc "Full vacate: total nonce count across legs is positive and ≤ VACATE-FULL-MAX-NONCES."
        (let
            (
                (tot:integer
                    (fold
                        (+)
                        0
                        (map
                            (lambda (ns:[integer]) (length ns))
                            nonces-array
                        )
                    )
                )
            )
            (fold (and) true [(> tot 0) (<= tot VACATE-FULL-MAX-NONCES)])
        )
    )
    (defun URC_VacateCollectableLegBeneficiaryOk:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer])
        @doc "Vacate: each nonce tracker row beneficiary-id must equal the supplied beneficiary-id."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (l:integer (length nonces))
            )
            (fold
                (and)
                true
                (map
                    (lambda (idx:integer)
                        (let
                            (
                                (n:integer (at idx nonces))
                                (row-ben:string
                                    (if son
                                        (ref-AQP::UR_AQP|DPSFTrackerBeneficiaryId pool-id collectable-id owner-id beneficiary-id n)
                                        (ref-AQP::UR_AQP|DPNFTrackerBeneficiaryId pool-id collectable-id owner-id beneficiary-id n)
                                    )
                                )
                            )
                            (= row-ben beneficiary-id)
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_VacateCollectableNoncesSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Vacate: each nonce amount must equal full DPSF/DPNF tracker row (no partial vacate)."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (l:integer (length nonces))
            )
            (fold
                (and)
                true
                (map
                    (lambda (idx:integer)
                        (let
                            (
                                (n:integer (at idx nonces))
                                (q:integer (at idx nonce-amounts))
                                (bal:decimal
                                    (if son
                                        (ref-AQP::UR_AQP|DPSFTrackerBalance pool-id collectable-id owner-id beneficiary-id n)
                                        (ref-AQP::UR_AQP|DPNFTrackerBalance pool-id collectable-id owner-id beneficiary-id n)
                                    )
                                )
                            )
                            (= bal (dec q))
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_VacateCollectableRollupSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Vacate: each nonce has cross-pool Ben* nonce rollup amount ≥ vacate amount."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (l:integer (length nonces))
            )
            (fold
                (and)
                true
                (map
                    (lambda (idx:integer)
                        (let
                            (
                                (n:integer (at idx nonces))
                                (q:integer (at idx nonce-amounts))
                                (rollup-amt:integer
                                    (if son
                                        (ref-AQP::UR_AQP|BenDpsfNonceAmount beneficiary-id collectable-id n)
                                        (ref-AQP::UR_AQP|BenDpnfNonceAmount beneficiary-id collectable-id n)
                                    )
                                )
                            )
                            (>= rollup-amt q)
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun UC_VacateUniqueBeneficiaries:[string] (beneficiary-ids:[string])
        (fold (lambda (acc:[string] b:string) (if (contains b acc) acc (+ acc [b]))) [] beneficiary-ids)
    )
    (defun UC_VacateMergeDecimalNonceRowsForBeneficiary:object
        (beneficiary-id:string beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[decimal]])
        (fold
            (lambda (acc:object idx:integer)
                (if (= beneficiary-id (at idx beneficiary-ids))
                    {"nonces": (+ (at "nonces" acc) (at idx nonces-array)), "amounts": (+ (at "amounts" acc) (at idx amounts-array))}
                    acc))
            {"nonces": [], "amounts": []}
            (enumerate 0 (- (length beneficiary-ids) 1))
        )
    )
    (defun UC_VacateMergeIntNonceRowsForBeneficiary:object
        (beneficiary-id:string beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]])
        (fold
            (lambda (acc:object idx:integer)
                (if (= beneficiary-id (at idx beneficiary-ids))
                    {"nonces": (+ (at "nonces" acc) (at idx nonces-array)), "amounts": (+ (at "amounts" acc) (at idx amounts-array))}
                    acc))
            {"nonces": [], "amounts": []}
            (enumerate 0 (- (length beneficiary-ids) 1))
        )
    )

    ;; [URC] TF vacate leg inventory
    (defun URC_VacateTfLegsOk:bool
        (pool-id:string dptf-id:string legs:[object{VCT|VacateTfLeg}])
        @doc "Full TF vacate: positive leg count ≤ VACATE-FULL-MAX-LEGS; each leg balance matches tracker + rollup."
        (let
            (
                (l:integer (length legs))
            )
            (fold
                (and)
                true
                [
                    (> l 0)
                    (<= l VACATE-FULL-MAX-LEGS)
                    (fold
                        (lambda (ok:bool leg:object{VCT|VacateTfLeg})
                            (and
                                ok
                                (URC_VacateTfLegBalancesOk
                                    pool-id
                                    dptf-id
                                    (at "owner-id" leg)
                                    (at "beneficiary-id" leg)
                                    (at "balance" leg)
                                )
                            )
                        )
                        true
                        legs
                    )
                ]
            )
        )
    )
    ;; [UC] TF vacate leg list helpers
    (defun UC_VacateUniqueBeneficiariesFromLegs:[string]
        (legs:[object{VCT|VacateTfLeg}])
        @doc "Preserve first-seen order; dedupe beneficiaries for score/RPS phases."
        (fold
            (lambda (acc:[string] leg:object{VCT|VacateTfLeg})
                (let ((b:string (at "beneficiary-id" leg)))
                    (if (contains b acc) acc (+ acc [b]))
                )
            )
            []
            legs
        )
    )
    (defun UC_VacateSumAmountForBeneficiaryFromLegs:decimal
        (beneficiary-id:string legs:[object{VCT|VacateTfLeg}])
        @doc "Sum leg balances for one beneficiary (rollup/score amount for deduped unwind)."
        (fold
            (+)
            0.0
            (map
                (lambda (leg:object{VCT|VacateTfLeg})
                    (if (= beneficiary-id (at "beneficiary-id" leg))
                        (at "balance" leg)
                        0.0
                    )
                )
                legs
            )
        )
    )
    (defun UC_TfLegsFromParallelArrays:[object{VCT|VacateTfLeg}]
        (owner-ids:[string] beneficiary-ids:[string] amounts:[decimal])
        @doc "Build leg objects from parallel slice/chunk arrays (session vacate chunks)."
        (map
            (lambda (idx:integer)
                (UDC_VacateTfLeg
                    (at idx owner-ids)
                    (at idx beneficiary-ids)
                    (at idx amounts)
                )
            )
            (enumerate 0 (- (length owner-ids) 1))
        )
    )
    (defun UC_VacateTfLegsToTftBulkArrays:object
        (legs:[object{VCT|VacateTfLeg}])
        @doc "One DPTF row: parallel owner/balance inner lists for TFT::C_MultiBulkTransfer."
        {
            "receiver-array"
                : [
                    (map
                        (lambda (leg:object{VCT|VacateTfLeg})
                            (at "owner-id" leg)
                        )
                        legs
                    )
                ]
            ,"transfer-amount-array"
                : [
                    (map
                        (lambda (leg:object{VCT|VacateTfLeg})
                            (at "balance" leg)
                        )
                        legs
                    )
                ]
        }
    )

    ;;{F6}  [C] — client vacate recipes (FULL + SLICED SESSION; see module header)
    ;;
    ;; =============================================================================
    ;; FULL VACATE — one tx per pool × asset (Talos wired)
    ;; =============================================================================
    (defun C_FullVacateTrueFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dptf-id:string)
        @doc "Full TF vacate (one tx): load legs from pool inventory → unwind → bulk transfer last."
        (UEV_IMC)
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (legs:[object{VCT|VacateTfLeg}]
                    (URDC_VacateTfOwnerRows pool-id dptf-id))
            )
            (with-capability (VCT|C>FULL-TRUE-FUNGIBLE-VACATE pool-id dptf-id legs)
                (if (ref-AQP::UR_AQP|PoolStakeEnabled pool-id)
                    (ref-AQP::XB_SetPoolStakeEnabled pool-id false)
                    true
                )
                (XI_VacateTrueFungibleFromLegs pool-id dptf-id legs)
            )
        )
    )
    (defun C_FullVacateOrtoFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpof-id:string)
        (UEV_IMC)
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (owner-rows:[object{VCT|VacateNonceLeg}]
                    (URDC_VacateNonceOwnerRows pool-id dpof-id VACATE-KIND-OF))
                (arr:object (UC_VacateOfLegsToVacateArrays owner-rows))
                (owner-ids:[string] (at "owner-ids" arr))
                (beneficiary-ids:[string] (at "beneficiary-ids" arr))
                (nonces-array:[[integer]] (at "nonces-array" arr))
            )
            (with-capability (VCT|C>FULL-ORTO-FUNGIBLE-VACATE pool-id dpof-id owner-ids beneficiary-ids nonces-array)
                (if (ref-AQP::UR_AQP|PoolStakeEnabled pool-id)
                    (ref-AQP::XB_SetPoolStakeEnabled pool-id false)
                    true
                )
                (XI_VacateOrtoFungibleBatch
                    pool-id
                    dpof-id
                    owner-ids
                    beneficiary-ids
                    nonces-array
                    (at "nonce-amounts-array" arr)
                )
            )
        )
    )
    (defun C_FullVacateSemiFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpsf-id:string)
        (UEV_IMC)
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (owner-rows:[object{VCT|VacateNonceLeg}]
                    (URDC_VacateNonceOwnerRows pool-id dpsf-id VACATE-KIND-DPSF))
                (arr:object (UC_VacateCollectableLegsToVacateArrays owner-rows))
                (owner-ids:[string] (at "owner-ids" arr))
                (beneficiary-ids:[string] (at "beneficiary-ids" arr))
                (nonces-array:[[integer]] (at "nonces-array" arr))
            )
            (with-capability (VCT|C>FULL-COLLECTABLE-VACATE pool-id dpsf-id true owner-ids beneficiary-ids nonces-array)
                (if (ref-AQP::UR_AQP|PoolStakeEnabled pool-id)
                    (ref-AQP::XB_SetPoolStakeEnabled pool-id false)
                    true
                )
                (XI_VacateCollectableBatch
                    pool-id
                    dpsf-id
                    true
                    owner-ids
                    beneficiary-ids
                    nonces-array
                    (at "amounts-array" arr)
                )
            )
        )
    )
    (defun C_FullVacateNonFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpnf-id:string)
        (UEV_IMC)
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (owner-rows:[object{VCT|VacateNonceLeg}]
                    (URDC_VacateNonceOwnerRows pool-id dpnf-id VACATE-KIND-DPNF))
                (arr:object (UC_VacateCollectableLegsToVacateArrays owner-rows))
                (owner-ids:[string] (at "owner-ids" arr))
                (beneficiary-ids:[string] (at "beneficiary-ids" arr))
                (nonces-array:[[integer]] (at "nonces-array" arr))
            )
            (with-capability (VCT|C>FULL-COLLECTABLE-VACATE pool-id dpnf-id false owner-ids beneficiary-ids nonces-array)
                (if (ref-AQP::UR_AQP|PoolStakeEnabled pool-id)
                    (ref-AQP::XB_SetPoolStakeEnabled pool-id false)
                    true
                )
                (XI_VacateCollectableBatch
                    pool-id
                    dpnf-id
                    false
                    owner-ids
                    beneficiary-ids
                    nonces-array
                    (at "amounts-array" arr)
                )
            )
        )
    )

    ;; =============================================================================
    ;; SLICED SESSION — C_BeginVacate → C_VacateChunk* → auto finalize
    ;; =============================================================================
    (defun C_BeginVacate:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string asset-id:string vacate-kind:integer slice-count:integer)
        @doc "Open sliced vacate session — mint VacateJobID, write hash-only VCT|T|Slice rows, return slice plan OC."
        (UEV_IMC)
        (with-capability (VCT|C>BEGIN-VACATE pool-id asset-id vacate-kind slice-count)
            (let
                (
                    (vacate-job-id:string (XI_MintVacateJobId))
                    (draft-plan:object{VCT|VacateSlicePlan}
                        (URDC_BuildVacateSlicePlan pool-id asset-id vacate-kind slice-count)
                    )
                    (plan:object{VCT|VacateSlicePlan}
                        (UDC_VacateSlicePlan
                            vacate-job-id
                            pool-id
                            asset-id
                            vacate-kind
                            slice-count
                            (at "slices" draft-plan)
                        )
                    )
                    (slice-hashes:[string]
                        (map (lambda (s:object{VCT|SlicePayload}) (UC_HashSlicePayload s)) (at "slices" plan))
                    )
                    (manifest-hash:string (UC_HashSlicePlanManifest vacate-job-id slice-hashes))
                    (job:object{VCT|Job}
                        (UDC_Job
                            pool-id asset-id vacate-kind slice-count manifest-hash
                            false false false vacate-job-id
                        )
                    )
                )
                (XI_OpenBeginVacateSession vacate-job-id job plan pool-id manifest-hash)
                (UC_SlicePlanOc plan)
            )
        )
    )
    (defun C_ResliceVacate:object{IgnisCollectorV1.OutputCumulator}
        (vacate-job-id:string slice-count:integer)
        (UEV_IMC)
        (with-capability (VCT|C>RESLICE-VACATE vacate-job-id slice-count)
            (let
                (
                    (pool-id:string (UR_J|PoolId vacate-job-id))
                    (asset-id:string (UR_J|AssetId vacate-job-id))
                    (kind:integer (UR_J|VacateAssetKind vacate-job-id))
                    (new-job-id:string (XI_MintVacateJobId))
                    (draft-plan:object{VCT|VacateSlicePlan}
                        (URDC_BuildVacateSlicePlan pool-id asset-id kind slice-count)
                    )
                    (plan:object{VCT|VacateSlicePlan}
                        (UDC_VacateSlicePlan
                            new-job-id pool-id asset-id kind slice-count (at "slices" draft-plan)
                        )
                    )
                    (slice-hashes:[string]
                        (map (lambda (s:object{VCT|SlicePayload}) (UC_HashSlicePayload s)) (at "slices" plan))
                    )
                    (manifest-hash:string (UC_HashSlicePlanManifest new-job-id slice-hashes))
                    (job:object{VCT|Job}
                        (UDC_Job
                            pool-id asset-id kind slice-count manifest-hash
                            false false false new-job-id
                        )
                    )
                )
                (XI_MarkJobResliced vacate-job-id)
                (XI_OpenBeginVacateSession new-job-id job plan pool-id manifest-hash)
                (UC_SlicePlanOc plan)
            )
        )
    )
    (defun C_VacateChunkTrueFungible:object{IgnisCollectorV1.OutputCumulator}
        (vacate-job-id:string slice-idx:integer owner-ids:[string] beneficiary-ids:[string] amounts:[decimal])
        (UEV_IMC)
        (with-capability
            (VCT|C>VACATE-CHUNK-TRUE-FUNGIBLE vacate-job-id slice-idx owner-ids beneficiary-ids amounts)
            (let
                (
                    (pool-id:string (UR_J|PoolId vacate-job-id))
                    (dptf-id:string (UR_J|AssetId vacate-job-id))
                    (slice-hash:string (UR_S|SliceHash vacate-job-id slice-idx))
                    (job:object{VCT|Job} (UR_Job vacate-job-id))
                    (legs:[object{VCT|VacateTfLeg}]
                        (UC_TfLegsFromParallelArrays owner-ids beneficiary-ids amounts))
                    (oc:object{IgnisCollectorV1.OutputCumulator}
                        (XI_VacateTrueFungibleFromLegs pool-id dptf-id legs)
                    )
                )
                (XI_CompleteVacateChunk pool-id vacate-job-id slice-idx slice-hash job oc)
            )
        )
    )
    (defun C_VacateChunkNonce:object{IgnisCollectorV1.OutputCumulator}
        (
            vacate-job-id:string
            slice-idx:integer
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        (UEV_IMC)
        (with-capability
            (VCT|C>VACATE-CHUNK-NONCE
                vacate-job-id slice-idx owner-ids beneficiary-ids nonces-array amounts-array
            )
            (let
                (
                    (pool-id:string (UR_J|PoolId vacate-job-id))
                    (asset-id:string (UR_J|AssetId vacate-job-id))
                    (kind:integer (UR_J|VacateAssetKind vacate-job-id))
                    (slice-hash:string (UR_S|SliceHash vacate-job-id slice-idx))
                    (job:object{VCT|Job} (UR_Job vacate-job-id))
                    (of-amounts:[[decimal]]
                        (URDC_ResolveOfDecimalAmountsFromTracker
                            pool-id asset-id owner-ids beneficiary-ids nonces-array
                        )
                    )
                    (oc:object{IgnisCollectorV1.OutputCumulator}
                        (if (= kind VACATE-KIND-OF)
                            (XI_VacateOrtoFungibleBatch
                                pool-id asset-id owner-ids beneficiary-ids nonces-array of-amounts
                            )
                            (XI_VacateCollectableBatch
                                pool-id
                                asset-id
                                (UC_VacateKindSon kind)
                                owner-ids
                                beneficiary-ids
                                nonces-array
                                amounts-array
                            )
                        )
                    )
                )
                (XI_CompleteVacateChunk pool-id vacate-job-id slice-idx slice-hash job oc)
            )
        )
    )
    (defun C_AbortVacate:object{IgnisCollectorV1.OutputCumulator} (vacate-job-id:string)
        @doc "Abort active vacate session; stake stays disabled."
        (UEV_IMC)
        (with-capability (VCT|C>ABORT-VACATE vacate-job-id)
            (let
                (
                    (pool-id:string (UR_J|PoolId vacate-job-id))
                )
                (XI_AbortVacateSession pool-id vacate-job-id)
                (UC_EmptyOc)
            )
        )
    )

    ;;{F7}  [X] — internal orchestration (after all C_* recipes)
    ;; Depth: C_* → XI_* (depth 0) → XI_1|* (depth 1) → XI_2|* (depth 2) → XI_3|* (depth 3).
    ;; Session helpers: C_* uses XI_MintVacateJobId / XI_MarkJobResliced; XI_* uses XI_1|WriteSliceHashes / XI_1|FinalizeVacateIfComplete.
    ;; AQP pool writes: ref-AQP::XB_* directly (no XI_2 hop).
    ;; Table persistence: W_ layer only. XI_* call W_ directly with ;; SECURE: comments; no raw insert/update/write on VCT|T|*.
    ;; SECURE composed by master VCT|C>* cap or P|VCT|RECIPE (atomic vacate batch). No UEV_* in XI bodies.
    ;;
    (defun XI_1|WriteSliceHashes
        (vacate-job-id:string slices:[object{VCT|SlicePayload}] slice-hashes:[string])
        ;; SECURE: granted by WI_Slice (underlying W_).
        (map
            (lambda (idx:integer)
                (WI_Slice vacate-job-id idx
                    (UDC_Slice (at idx slice-hashes) false vacate-job-id idx)
                )
            )
            (enumerate 0 (- (length slice-hashes) 1))
        )
    )
    (defun XI_MintVacateJobId:string
        ()
        @doc "Internal depth 1: issue next VacateJobID from seq counter + block entropy."
        ;; SECURE: granted by WW_Seq (underlying W_).
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                ;;
                (cur:integer (UR_Seq|NextId))
                (next:integer (+ cur 1))
            )
            (WW_Seq next)
            (ref-U|DALOS::UDC_Makeid (concat ["VACATE-" (format "{}" [next])]))
        )
    )
    (defun XI_MarkJobResliced:string (vacate-job-id:string)
        ;; SECURE: granted by WU_Job|Resliced (underlying W_).
        (WU_Job|Resliced vacate-job-id)
    )
    (defun XI_OpenBeginVacateSession:object{VCT|VacateSlicePlan}
        (
            vacate-job-id:string
            job:object{VCT|Job}
            plan:object{VCT|VacateSlicePlan}
            pool-id:string
            manifest-hash:string
        )
        ;; SECURE: granted by WI_Job, WI_Slice (via XI_1|WriteSliceHashes), ref-AQP::XE_SetVacateJobState, ref-AQP::XB_SetPoolStakeEnabled.
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (slice-hashes:[string]
                    (map (lambda (s:object{VCT|SlicePayload}) (UC_HashSlicePayload s)) (at "slices" plan))
                )
            )
            ;; SECURE: granted by WI_Job (underlying W_).
            (WI_Job vacate-job-id job)
            (XI_1|WriteSliceHashes vacate-job-id (at "slices" plan) slice-hashes)
            (ref-AQP::XE_SetVacateJobState pool-id true manifest-hash manifest-hash "")
            (if (ref-AQP::UR_AQP|PoolStakeEnabled pool-id)
                (ref-AQP::XB_SetPoolStakeEnabled pool-id false)
                true
            )
            plan
        )
    )
    (defun XI_CompleteVacateChunk:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            vacate-job-id:string
            slice-idx:integer
            slice-hash:string
            job:object{VCT|Job}
            oc:object{IgnisCollectorV1.OutputCumulator}
        )
        ;; SECURE: granted by WU_Slice|Processed, ref-AQP::XE_SetVacateJobState, and XI_1|FinalizeVacateIfComplete children.
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (WU_Slice|Processed vacate-job-id slice-idx)
            (ref-AQP::XE_SetVacateJobState
                pool-id
                true
                (at "initial-manifest-hash" job)
                (at "initial-manifest-hash" job)
                slice-hash
            )
            (XI_1|FinalizeVacateIfComplete pool-id vacate-job-id oc)
        )
    )
    (defun XI_1|FinalizeVacateIfComplete:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string vacate-job-id:string oc:object{IgnisCollectorV1.OutputCumulator})
        (if (URDC_AllSlicesProcessed vacate-job-id)
            ;; SECURE: granted by WU_Job|Finalized, ref-AQP::XE_SetVacateJobState, ref-AQP::XB_SetPoolStakeEnabled.
            (let
                (
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    ;;
                    (pid pool-id)
                )
                (WU_Job|Finalized vacate-job-id)
                (ref-AQP::XE_SetVacateJobState pid false "" "" "")
                (ref-AQP::XB_SetPoolStakeEnabled pid true)
                (UC_EmptyOc)
            )
            oc
        )
    )
    (defun XI_AbortVacateSession:string (pool-id:string vacate-job-id:string)
        ;; SECURE: granted by WU_Job|Aborted and ref-AQP::XE_SetVacateJobState.
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (WU_Job|Aborted vacate-job-id)
            (ref-AQP::XE_SetVacateJobState pool-id false "" "" "")
        )
    )
    (defun XI_3|RpsVacatePreZero:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object)
        @doc "TF vacate RPS prelude: bank pending at OLD deb per score plan. Skips ghost-TVL sync and row ensure."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                ;;
                (settle-plans:[object] (at "settle-plans" settle-bundle))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (map
                (lambda (plan:object)
                    (ref-FVT::XE_BankScorePendingRewards beneficiary-id pool-id plan)
                )
                settle-plans
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                0.0
                AQP|SC_NAME
                trigger
                [pool-id beneficiary-id "vacate-rps-pre-zero"]
            )
        )
    )
    (defun XI_2|VacateTrueFungibleBeneficiaryUnwind:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "TF vacate per beneficiary: rollup → RPS bank → ANK → SCORE unstake → RPS book+checkpoint."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (settle-bundle:object
                    (ref-FVT::URDC_BuildStakeSettleBundle pool-id beneficiary-id)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-AQP::XE_TrueFungibleBeneficiaryRollup
                        pool-id "" beneficiary-id dptf-id amount false
                    )
                    (XI_3|RpsVacatePreZero beneficiary-id pool-id settle-bundle)
                    (ref-FVT::XE_RefreshTrueFungibleStakeAnchors beneficiary-id dptf-id)
                    (ref-SCR::XE_ApplyTrueFungibleStakeDelta
                        pool-id beneficiary-id dptf-id amount false
                        (ref-AQP::URC_PoolActiveScoreIds pool-id)
                        (ref-AQP::URC_DptfStakeIsNativeLeg dptf-id)
                    )
                    (ref-FVT::XE_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
                    (ref-FVT::XE_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
                ]
                []
            )
        )
    )
    (defun XI_1|VacateTrueFungibleUnwindFromLegs:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dptf-id:string legs:[object{VCT|VacateTfLeg}])
        @doc "TF vacate phases 2–4: write-only tracker zero per leg; beneficiary unwind deduped by unique beneficiary."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (unique-beneficiaries:[string] (UC_VacateUniqueBeneficiariesFromLegs legs))
                (tracker-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                    (map
                        (lambda (leg:object{VCT|VacateTfLeg})
                            (ref-AQP::XE_ZeroDptfTrackerSlot
                                pool-id
                                (at "owner-id" leg)
                                (at "beneficiary-id" leg)
                                dptf-id
                            )
                        )
                        legs
                    )
                )
                (score-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                    (map
                        (lambda (beneficiary-id:string)
                            (XI_2|VacateTrueFungibleBeneficiaryUnwind
                                pool-id
                                beneficiary-id
                                dptf-id
                                (UC_VacateSumAmountForBeneficiaryFromLegs beneficiary-id legs)
                            )
                        )
                        unique-beneficiaries
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators (+ tracker-ocs score-ocs) [])
        )
    )
    (defun XI_VacateTrueFungibleFromLegs:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dptf-id:string legs:[object{VCT|VacateTfLeg}])
        @doc "TF vacate atomic: phases 2–4 unwind from leg list, then phase 0 bulk TFT transfer last."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                ;;
                (unwind-oc:object{IgnisCollectorV1.OutputCumulator}
                    (XI_1|VacateTrueFungibleUnwindFromLegs pool-id dptf-id legs)
                )
                (bulk-arr:object (UC_VacateTfLegsToTftBulkArrays legs))
                (bulk-oc:object{IgnisCollectorV1.OutputCumulator}
                    (ref-TFT::C_MultiBulkTransfer
                        [dptf-id]
                        AQP|SC_NAME
                        (at "receiver-array" bulk-arr)
                        (at "transfer-amount-array" bulk-arr)
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [unwind-oc bulk-oc] [])
        )
    )
    (defun XI_2|VacateOrtoFungibleScoreUnwind:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
        )
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (settle-bundle:object
                    (ref-FVT::URDC_BuildStakeSettleBundle pool-id beneficiary-id)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (XI_3|RpsVacatePreZero beneficiary-id pool-id settle-bundle)
                    (ref-SCR::XE_ApplyOrtoFungibleStakeDelta
                        pool-id beneficiary-id dpof-id nonces nonce-amounts false
                        (ref-AQP::URC_PoolActiveScoreIds pool-id)
                    )
                    (ref-FVT::XE_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
                    (ref-FVT::XE_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
                ]
                []
            )
        )
    )
    (defun XI_2|VacateCollectableScoreUnwind:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
        )
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (settle-bundle:object
                    (ref-FVT::URDC_BuildStakeSettleBundle pool-id beneficiary-id)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (XI_3|RpsVacatePreZero beneficiary-id pool-id settle-bundle)
                    (ref-FVT::XE_RefreshCollectableStakeAnchors beneficiary-id collectable-id son nonces nonce-amounts false)
                    (ref-SCR::XE_ApplyCollectableStakeDelta
                        pool-id beneficiary-id collectable-id son nonces nonce-amounts false
                        (ref-AQP::URC_PoolActiveScoreIds pool-id)
                    )
                    (ref-FVT::XE_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
                    (ref-FVT::XE_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
                ]
                []
            )
        )
    )
    (defun XI_1|VacateOrtoFungibleUnwindBatch:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
        )
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (L:integer (length owner-ids))
                (unique-beneficiaries:[string] (UC_VacateUniqueBeneficiaries beneficiary-ids))
                (tracker-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                    (map
                        (lambda (idx:integer)
                            (ref-AQP::XE_OrtoFungiblePoolTracker
                                pool-id
                                (at idx owner-ids)
                                (at idx beneficiary-ids)
                                dpof-id
                                (at idx nonces-array)
                                (at idx nonce-amounts-array)
                                false
                            )
                        )
                        (enumerate 0 (- L 1))
                    )
                )
                (score-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                    (map
                        (lambda (beneficiary-id:string)
                            (let
                                (
                                    (merged:object
                                        (UC_VacateMergeDecimalNonceRowsForBeneficiary
                                            beneficiary-id beneficiary-ids nonces-array nonce-amounts-array
                                        )
                                    )
                                )
                                (XI_2|VacateOrtoFungibleScoreUnwind
                                    pool-id
                                    beneficiary-id
                                    dpof-id
                                    (at "nonces" merged)
                                    (at "amounts" merged)
                                )
                            )
                        )
                        unique-beneficiaries
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators (+ tracker-ocs score-ocs) [])
        )
    )
    (defun XI_1|VacateCollectableUnwindBatch:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            collectable-id:string
            son:bool
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (L:integer (length owner-ids))
                (unique-beneficiaries:[string] (UC_VacateUniqueBeneficiaries beneficiary-ids))
                (tracker-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                    (map
                        (lambda (idx:integer)
                            (let
                                (
                                    (ns:[integer] (at idx nonces-array))
                                    (ams:[integer] (at idx amounts-array))
                                )
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                    [
                                        (ref-AQP::XE_CollectablePoolTracker
                                            pool-id
                                            (at idx owner-ids)
                                            (at idx beneficiary-ids)
                                            collectable-id
                                            son
                                            ns
                                            ams
                                            false
                                        )
                                        (ref-AQP::XE_CollectableBeneficiaryRollup
                                            pool-id
                                            (at idx owner-ids)
                                            (at idx beneficiary-ids)
                                            collectable-id
                                            son
                                            ns
                                            ams
                                            false
                                        )
                                    ]
                                    []
                                )
                            )
                        )
                        (enumerate 0 (- L 1))
                    )
                )
                (score-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                    (map
                        (lambda (beneficiary-id:string)
                            (let
                                (
                                    (merged:object
                                        (UC_VacateMergeIntNonceRowsForBeneficiary
                                            beneficiary-id beneficiary-ids nonces-array amounts-array
                                        )
                                    )
                                )
                                (XI_2|VacateCollectableScoreUnwind
                                    pool-id
                                    beneficiary-id
                                    collectable-id
                                    son
                                    (at "nonces" merged)
                                    (at "amounts" merged)
                                )
                            )
                        )
                        unique-beneficiaries
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators (+ tracker-ocs score-ocs) [])
        )
    )
    (defun XI_VacateOrtoFungibleBatch:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
        )
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                ;;
                (bulk-oc:object{IgnisCollectorV1.OutputCumulator}
                    (ref-DPOF::C_BulkTransfer dpof-id nonces-array AQP|SC_NAME owner-ids true)
                )
                (unwind-oc:object{IgnisCollectorV1.OutputCumulator}
                    (XI_1|VacateOrtoFungibleUnwindBatch
                        pool-id dpof-id owner-ids beneficiary-ids nonces-array nonce-amounts-array
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [bulk-oc unwind-oc] [])
        )
    )
    (defun XI_VacateCollectableBatch:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            collectable-id:string
            son:bool
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                ;;
                (bulk-oc:object{IgnisCollectorV1.OutputCumulator}
                    (ref-DPDC-T::C_BulkTransfer
                        collectable-id son nonces-array amounts-array AQP|SC_NAME owner-ids true
                    )
                )
                (unwind-oc:object{IgnisCollectorV1.OutputCumulator}
                    (XI_1|VacateCollectableUnwindBatch
                        pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [bulk-oc unwind-oc] [])
        )
    )

)

(create-table P|T)
(create-table P|MT)
(create-table VCT|T|Job)
(create-table VCT|T|Slice)
(create-table VCT|T|Seq)
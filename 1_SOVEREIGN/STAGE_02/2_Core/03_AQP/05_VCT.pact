(interface AcquisitionVacateV1
    (defun GOV|Demiurgoi ())
    (defun UC_ComputeMinSliceCount:integer (unit-count:integer vacate-kind:integer))
    (defun UC_ZeroIntAmountsMatrix:[[integer]] (nonces-array:[[integer]]))
    (defun URDC_BuildVacateSlicePlan:object
        (pool-id:string asset-id:string vacate-kind:integer slice-count:integer))
    (defun URDC_VacateUnitCountForKind:integer
        (pool-id:string asset-id:string vacate-kind:integer))
    ;;  [UR/URD] vacate inventory + vacate-in-progress observability (UI preflight)
    (defun UR_VacateInProgress:bool (pool-id:string))
    (defun UR_InitialVacateHash:string (pool-id:string))
    (defun UR_PhaseVacateHash:string (pool-id:string))
    (defun UR_LastVacateHash:string (pool-id:string))
    (defun URD_VacateTfInventory:object (pool-id:string dptf-id:string))
    (defun URD_VacateOfInventory:object (pool-id:string dpof-id:string))
    (defun URD_VacateCollectableInventory:object (pool-id:string collectable-id:string son:bool))
    ;;  [C/XB] Vacate REHAUL (phase 4) — agnostic, pool-id-only, legs read on-chain
    (defun CC_FullVacate:object{IgnisCollectorV1.OutputCumulator} (pool-id:string))
    (defun XB_VacateTrueFungible:object{IgnisCollectorV1.OutputCumulator} (pool-id:string))
    (defun XB_VacateOrtoFungible:object{IgnisCollectorV1.OutputCumulator} (pool-id:string dpof-id:string))
    (defun XB_VacateSemiFungible:object{IgnisCollectorV1.OutputCumulator} (pool-id:string dpsf-id:string))
    (defun XB_VacateNonFungible:object{IgnisCollectorV1.OutputCumulator} (pool-id:string dpnf-id:string))
    ;;  [C] Full vacate — one tx: UI dirty-reads inventory, passes full Legs payload, always finalize
    (defun C_FullVacateTrueFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun C_FullVacateOrtoFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    (defun C_FullVacateSemiFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpsf-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    (defun C_FullVacateNonFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpnf-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    ;;  [C] Stateless batched legs — UI splits inventory; auto-begin; finalize=UI claim when asset empty
    (defun C_VacateTrueFungibleLegs:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal] finalize:bool))
    (defun C_VacateOrtoFungibleLegs:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]] finalize:bool))
    (defun C_VacateSemiFungibleLegs:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpsf-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]] finalize:bool))
    (defun C_VacateNonFungibleLegs:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpnf-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]] finalize:bool))
    (defun C_AbortVacate:object{IgnisCollectorV1.OutputCumulator} (pool-id:string))
)

;; =============================================================================
;; AQP-VCT — Acquisition Vacate (pool-owner forced unstake)
;; =============================================================================
;; Two UI variants — pick one per pool × asset stream:
;;
;;   FULL (one tx, Talos wired)
;;     C_FullVacate*(… Legs payload …) — UI dirty-reads URD/URDC (no scan in C_*), passes the
;;     full inventory arrays, auto-begin → vacate all → finalize (re-enable stake). Same payload
;;     shape as Legs; always finalizes (UI-trust, like Legs finalize=true).
;;
;;   STATELESS BATCHED LEGS (multi-tx, Talos wired)
;;     C_Vacate*Legs(..., finalize) — UI dirty-reads URD inventory, splits into gas-safe batches,
;;     dumps N txs. First successful tx auto-begins (disable stake + vacate-in-progress).
;;     Last tx sets finalize=true (UI claim that asset emptied — write-only finalize, no on-chain scan).
;;     If some txs fail, remaining inventory stays; UI re-reads, re-splits, continues.
;;     C_AbortVacate(pool-id) clears vacate-in-progress; stake stays disabled (ops re-enable).
;;     Preflight: URDC_BuildVacateSlicePlan (offline plan only — no on-chain job/slice writes).
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
    ;; Offline plan schemas (SlicePayload / VacateSlicePlan). No Job/Slice session tables.
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
        @doc "Offline Legs split plan — full slice payloads for UI (no on-chain job writes). \
            \ vacate-job-id is unused under Legs (always \"\")."
        vacate-job-id:string
        pool-id:string
        asset-id:string
        vacate-asset-kind:integer
        slice-count:integer
        slices:[object{VCT|SlicePayload}]
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

    ;;<==========>
    ;;CAPABILITIES
    (defcap CAP_VctVacatePoolOwner (pool-id:string)
        @doc "Vacate operations require tx sender ownership of pool canonical owner konto."
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
                (legs-ok:bool
                    (URC_VacateOrtoLegsOk pool-id dpof-id owner-ids beneficiary-ids nonces-array nonce-amounts-array))
            )
            (enforce (fold (and) true [asset-ok gas-ok nonce-ok legs-ok]) "Invalid OF vacate batch")
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
                (legs-ok:bool
                    (URC_VacateCollectableLegsOk pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array))
            )
            (enforce (fold (and) true [class-ok asset-ok gas-ok nonce-ok legs-ok]) "Invalid collectable vacate batch")
            (CAP_VctVacatePoolOwner pool-id)
            (compose-capability (P|VCT|RECIPE))
        )
    )
    (defcap VCT|C>LEGS-TRUE-FUNGIBLE-VACATE
        (
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
            finalize:bool
        )
        @doc "Master: stateless TF legs batch (+ optional finalize). Composes batch validation + SECURE."
        @event
        (compose-capability
            (VCT|C>TRUE-FUNGIBLE-VACATE pool-id dptf-id owner-ids beneficiary-ids amounts)
        )
        (compose-capability (SECURE))
    )
    (defcap VCT|C>LEGS-ORTO-FUNGIBLE-VACATE
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
            finalize:bool
        )
        @doc "Master: stateless OF legs batch (+ optional finalize)."
        @event
        (compose-capability
            (VCT|C>ORTO-FUNGIBLE-VACATE-BATCH
                pool-id dpof-id owner-ids beneficiary-ids nonces-array nonce-amounts-array
            )
        )
        (compose-capability (SECURE))
    )
    (defcap VCT|C>LEGS-COLLECTABLE-VACATE
        (
            pool-id:string
            collectable-id:string
            son:bool
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
        @doc "Master: stateless DPSF/DPNF legs batch (+ optional finalize)."
        @event
        (compose-capability
            (VCT|C>COLLECTABLE-VACATE-BATCH
                pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array
            )
        )
        (compose-capability (SECURE))
    )
    (defcap VCT|C>ABORT-VACATE-POOL
        (pool-id:string)
        @doc "Clear vacate-in-progress on pool; stake stays disabled."
        @event
        (CAP_VctVacatePoolOwner pool-id)
        (compose-capability (SECURE))
    )
    (defcap VCT|C>VACATE (pool-id:string)
        @doc "Master AGNOSTIC vacate cap (rehaul). Class-agnostic: the new vacate reads the pool's staker legs \
            \ ON-CHAIN (no UI-supplied arrays to tamper/validate), so this only gates the pool OWNER + composes \
            \ SECURE + P|VCT|RECIPE. Used by the single-tx dispatcher CC_FullVacate and the per-kind XB_Vacate* \
            \ wrappers; the per-kind XI_Vacate*Pool functions run under it via require P|VCT|RECIPE."
        @event
        (CAP_VctVacatePoolOwner pool-id)
        (compose-capability (SECURE))
        (compose-capability (P|VCT|RECIPE))
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
                        (URC_VacateOrtoLegsBeneficiaryOk pool-id dpof-id owner-ids beneficiary-ids nonces-array)
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
                        (URC_VacateCollectableLegsBeneficiaryOk pool-id collectable-id son owner-ids beneficiary-ids nonces-array)
                    ]
                )
                "Invalid full collectable vacate"
            )
            (CAP_VctVacatePoolOwner pool-id)
            (compose-capability (SECURE))
            (compose-capability (P|VCT|RECIPE))
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
    ;; [UDC] — offline plan constructors (no Job/Slice table writers)
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
    ;; [URC]
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
    (defun URC_ResolveOfDecimalAmountsFromTracker
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
        @doc "Owner-row count from live vacate inventory — UI preflight before Full/Legs."
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
    ;; [URC] OF / collectable vacate leg inventory (batch wrappers — mirror URC_VacateTfLegsOk)
    (defun URC_VacateOrtoLegsOk:bool
        (pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string]
         nonces-array:[[integer]] nonce-amounts-array:[[decimal]])
        @doc "OF Legs vacate: bind every leg to real tracker rows — supplied beneficiary matches the tracker \
            \ row for (owner,beneficiary,nonce), and each amount equals the full staked balance (no partial, \
            \ no redirect to a non-staker). Point reads, gas-bounded by VACATE-GAS-MAX-OF."
        (let
            (
                (l:integer (length owner-ids))
            )
            (if (> l 0)
                (fold (and) true
                    (map
                        (lambda (idx:integer)
                            (and
                                (URC_VacateOrtoLegBeneficiaryOk
                                    pool-id dpof-id (at idx owner-ids) (at idx beneficiary-ids) (at idx nonces-array))
                                (URC_VacateOrtoNoncesSufficient
                                    pool-id dpof-id (at idx owner-ids) (at idx beneficiary-ids) (at idx nonces-array) (at idx nonce-amounts-array))
                            )
                        )
                        (enumerate 0 (- l 1))
                    )
                )
                true
            )
        )
    )
    (defun URC_VacateOrtoLegsBeneficiaryOk:bool
        (pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "Full OF vacate: bind every leg's nonces to a real tracker row whose beneficiary equals the \
            \ supplied beneficiary (blocks redirecting another staker's nonce). Amounts are whole-nonce (tracker-derived)."
        (let
            (
                (l:integer (length owner-ids))
            )
            (if (> l 0)
                (fold (and) true
                    (map
                        (lambda (idx:integer)
                            (URC_VacateOrtoLegBeneficiaryOk
                                pool-id dpof-id (at idx owner-ids) (at idx beneficiary-ids) (at idx nonces-array))
                        )
                        (enumerate 0 (- l 1))
                    )
                )
                true
            )
        )
    )
    (defun URC_VacateCollectableLegsOk:bool
        (pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string]
         nonces-array:[[integer]] amounts-array:[[integer]])
        @doc "DPSF/DPNF Legs vacate: bind every leg to real tracker rows — supplied beneficiary matches, each \
            \ amount equals the full staked balance, and the cross-pool rollup covers the amount. Point reads, gas-bounded."
        (let
            (
                (l:integer (length owner-ids))
            )
            (if (> l 0)
                (fold (and) true
                    (map
                        (lambda (idx:integer)
                            (fold (and) true
                                [
                                    (URC_VacateCollectableLegBeneficiaryOk
                                        pool-id collectable-id son (at idx owner-ids) (at idx beneficiary-ids) (at idx nonces-array))
                                    (URC_VacateCollectableNoncesSufficient
                                        pool-id collectable-id son (at idx owner-ids) (at idx beneficiary-ids) (at idx nonces-array) (at idx amounts-array))
                                    (URC_VacateCollectableRollupSufficient
                                        pool-id collectable-id son (at idx owner-ids) (at idx beneficiary-ids) (at idx nonces-array) (at idx amounts-array))
                                ]
                            )
                        )
                        (enumerate 0 (- l 1))
                    )
                )
                true
            )
        )
    )
    (defun URC_VacateCollectableLegsBeneficiaryOk:bool
        (pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "Full DPSF/DPNF vacate: bind every leg's nonces to a real tracker row whose beneficiary equals \
            \ the supplied beneficiary (blocks redirecting another staker's nonce)."
        (let
            (
                (l:integer (length owner-ids))
            )
            (if (> l 0)
                (fold (and) true
                    (map
                        (lambda (idx:integer)
                            (URC_VacateCollectableLegBeneficiaryOk
                                pool-id collectable-id son (at idx owner-ids) (at idx beneficiary-ids) (at idx nonces-array))
                        )
                        (enumerate 0 (- l 1))
                    )
                )
                true
            )
        )
    )
    ;; [URC] Whole-pool emptiness gate for finalize (audit H3 / fix #6)
    (defun URC_PoolFullyVacated:bool (pool-id:string)
        @doc "True when EVERY employed score of the pool has nzs-count = 0 — i.e. no non-zero-score staker \
            \ remains, so ALL streams (LP TF-leg + OF-leg) are empty. Bounded to ≤7 cross-module point reads \
            \ (no scan). Gates finalize re-enabling stake. Exact once SCORE base floors at 0 (fix #7)."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (slots:[string]
                    [
                        (ref-AQP::UR_AQP|PoolScorePrimary pool-id)
                        (ref-AQP::UR_AQP|PoolScoreSecondary pool-id)
                        (ref-AQP::UR_AQP|PoolScoreTertiary pool-id)
                        (ref-AQP::UR_AQP|PoolScoreQuaternary pool-id)
                        (ref-AQP::UR_AQP|PoolScoreQuinary pool-id)
                        (ref-AQP::UR_AQP|PoolScoreSenary pool-id)
                        (ref-AQP::UR_AQP|PoolScoreSeptenary pool-id)
                    ]
                )
            )
            (fold (and) true
                (map
                    (lambda (score-id:string)
                        (if (= score-id BAR)
                            true
                            (= (ref-SCR::UR_SCR|ScoreNzsCount score-id) 0)
                        )
                    )
                    slots
                )
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
        @doc "Build leg objects from parallel Legs batch arrays."
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
    ;; FULL VACATE — one tx: UI-supplied full Legs payload + auto-begin + finalize
    ;; =============================================================================
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;; VACATE REHAUL (phase 4) — agnostic pool-id-only vacate. Legs read ON-CHAIN.
    ;;   CC_FullVacate(pool-id)  — one-tx, dispatches by aqp-class to per-kind XI_Vacate*Pool.
    ;;   XB_Vacate{TF,OF,SF,NF}  — external per-kind wrappers over the same XI cores.
    ;;   (multistep defpact + OF/SF/NF dispatch land in later steps of this phase.)
    ;; ═══════════════════════════════════════════════════════════════════════════
    (defun XB_VacateTrueFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string)
        @doc "Vacate rehaul — external per-kind TF vacate for a whole pool (both internal + external, hence XB). \
            \ UEV_IMC + VCT|C>VACATE (owner + SECURE + P|VCT|RECIPE) around XI_VacateTrueFungibleAllLanes — vacates \
            \ EVERY live TF lane (native asset-id + F| frozen leg). The pool's DPOF satellites (Z|/H|) are vacated \
            \ by XB_VacateOrtoFungible; use CC_FullVacate to empty a whole pool of any class in one call."
        (UEV_IMC)
        (with-capability (VCT|C>VACATE pool-id)
            (XI_VacateTrueFungibleAllLanes pool-id)
        )
    )
    (defun XB_VacateOrtoFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpof-id:string)
        @doc "Vacate rehaul — external per-kind OF vacate for ONE OF asset of a pool (both internal + external). \
            \ UEV_IMC + VCT|C>VACATE around XI_VacateOrtoFungiblePool. A class-1 pool has TF + ≥1 OF satellite; call \
            \ per satellite, or use CC_FullVacate to empty the whole pool."
        (UEV_IMC)
        (with-capability (VCT|C>VACATE pool-id)
            (XI_VacateOrtoFungiblePool pool-id dpof-id)
        )
    )
    (defun XB_VacateSemiFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpsf-id:string)
        @doc "Vacate rehaul — external per-kind DPSF (semi-fungible collection) vacate for ONE collectable of a \
            \ pool (both internal + external). UEV_IMC + VCT|C>VACATE around XI_VacateCollectablePool (son=true). \
            \ Class-3 pools hold one DPSF collection; use CC_FullVacate to empty the whole pool in one call."
        (UEV_IMC)
        (with-capability (VCT|C>VACATE pool-id)
            (XI_VacateCollectablePool pool-id dpsf-id true)
        )
    )
    (defun XB_VacateNonFungible:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpnf-id:string)
        @doc "Vacate rehaul — external per-kind DPNF (non-fungible collection) vacate for ONE collectable of a \
            \ pool (both internal + external). UEV_IMC + VCT|C>VACATE around XI_VacateCollectablePool (son=false). \
            \ Class-4 pools hold one DPNF collection; use CC_FullVacate to empty the whole pool in one call."
        (UEV_IMC)
        (with-capability (VCT|C>VACATE pool-id)
            (XI_VacateCollectablePool pool-id dpnf-id false)
        )
    )
    (defun CC_FullVacate:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string)
        @doc "HEAVY (R3 CC_) AGNOSTIC single-tx full vacate: input is JUST the pool-id. Reads the pool's aqp-class \
            \ and vacates EVERY custody lane the pool holds by scanning its inventory ON-CHAIN. TF-FAMILY (class 0 \
            \ LP farm / class 1 DPTF family) is MULTI-LANE — up to native TF + F| frozen TF + Z|/H| DPOF satellites \
            \ (class 0 stakes a Z| sleeping-LP DPOF too, NOT TF-only) — so both dispatch to XI_VacateTrueFungibleFamilyPool \
            \ which enumerates every live DPTF lane AND every live DPOF satellite. class 2 → standalone OF; class 3 → \
            \ DPSF; class 4 → DPNF. Empty lanes are skipped (no abort). Owner-gated (VCT|C>VACATE)."
        (UEV_IMC)
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (aqp-class:integer (ref-AQP::UR_AQP|PoolAqpClass pool-id))
                (asset-id:string (ref-AQP::UR_AQP|PoolAssetId pool-id))
            )
            (with-capability (VCT|C>VACATE pool-id)
                (enforce (contains aqp-class [0 1 2 3 4]) "CC_FullVacate: unknown aqp-class")
                (if (or (= aqp-class 0) (= aqp-class 1))
                    (XI_VacateTrueFungibleFamilyPool pool-id)
                    (if (= aqp-class 2)
                        (XI_VacateOrtoFungiblePool pool-id asset-id)
                        (XI_VacateCollectablePool pool-id asset-id (= aqp-class 3))
                    )
                )
            )
        )
    )
    (defun C_FullVacateTrueFungible:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
        @doc "Full TF vacate (one tx): begin → unwind UI-supplied inventory → finalize. \
            \ No URD/URDC in C_* — UI dirty-reads then passes Legs arrays (StoicSyntax §10.2)."
        (UEV_IMC)
        (let
            (
                (legs:[object{VCT|VacateTfLeg}]
                    (UC_TfLegsFromParallelArrays owner-ids beneficiary-ids amounts)
                )
            )
            (with-capability (VCT|C>FULL-TRUE-FUNGIBLE-VACATE pool-id dptf-id legs)
                (XI_EnsureVacateBegun pool-id)
                (let
                    (
                        (oc:object{IgnisCollectorV1.OutputCumulator}
                            (XI_VacateTrueFungibleFromLegs pool-id dptf-id legs)
                        )
                    )
                    (do
                        (XI_MaybeFinalizeVacate pool-id dptf-id VACATE-KIND-TF true)
                        oc
                    )
                )
            )
        )
    )
    (defun C_FullVacateOrtoFungible:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Full OF vacate (one tx). Amounts may be zero-sentinels (resolved via URC point reads)."
        (UEV_IMC)
        (let
            (
                (of-amounts:[[decimal]]
                    (URC_ResolveOfDecimalAmountsFromTracker
                        pool-id dpof-id owner-ids beneficiary-ids nonces-array
                    )
                )
            )
            (with-capability
                (VCT|C>FULL-ORTO-FUNGIBLE-VACATE pool-id dpof-id owner-ids beneficiary-ids nonces-array)
                (XI_EnsureVacateBegun pool-id)
                (let
                    (
                        (oc:object{IgnisCollectorV1.OutputCumulator}
                            (XI_VacateOrtoFungibleBatch
                                pool-id dpof-id owner-ids beneficiary-ids nonces-array of-amounts
                            )
                        )
                    )
                    (do
                        (XI_MaybeFinalizeVacate pool-id dpof-id VACATE-KIND-OF true)
                        oc
                    )
                )
            )
        )
    )
    (defun C_FullVacateSemiFungible:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dpsf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Full DPSF vacate (one tx). UI supplies Legs arrays from dirty URD/URDC."
        (UEV_IMC)
        (with-capability
            (VCT|C>FULL-COLLECTABLE-VACATE
                pool-id dpsf-id true owner-ids beneficiary-ids nonces-array
            )
            (XI_EnsureVacateBegun pool-id)
            (let
                (
                    (oc:object{IgnisCollectorV1.OutputCumulator}
                        (XI_VacateCollectableBatch
                            pool-id dpsf-id true owner-ids beneficiary-ids nonces-array amounts-array
                        )
                    )
                )
                (do
                    (XI_MaybeFinalizeVacate pool-id dpsf-id VACATE-KIND-DPSF true)
                    oc
                )
            )
        )
    )
    (defun C_FullVacateNonFungible:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dpnf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Full DPNF vacate (one tx). UI supplies Legs arrays from dirty URD/URDC."
        (UEV_IMC)
        (with-capability
            (VCT|C>FULL-COLLECTABLE-VACATE
                pool-id dpnf-id false owner-ids beneficiary-ids nonces-array
            )
            (XI_EnsureVacateBegun pool-id)
            (let
                (
                    (oc:object{IgnisCollectorV1.OutputCumulator}
                        (XI_VacateCollectableBatch
                            pool-id dpnf-id false owner-ids beneficiary-ids nonces-array amounts-array
                        )
                    )
                )
                (do
                    (XI_MaybeFinalizeVacate pool-id dpnf-id VACATE-KIND-DPNF true)
                    oc
                )
            )
        )
    )

    ;; =============================================================================
    ;; STATELESS BATCHED LEGS — UI splits; auto-begin; finalize flag when asset empty
    ;; =============================================================================
    (defun C_VacateTrueFungibleLegs:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
            finalize:bool
        )
        @doc "Vacate one gas-safe TF leg batch. Auto-begins vacate if needed. \
            \ finalize=true requires this asset inventory empty after the batch, then re-enables stake."
        (UEV_IMC)
        (with-capability
            (VCT|C>LEGS-TRUE-FUNGIBLE-VACATE pool-id dptf-id owner-ids beneficiary-ids amounts finalize)
            (XI_EnsureVacateBegun pool-id)
            (let
                (
                    (legs:[object{VCT|VacateTfLeg}]
                        (UC_TfLegsFromParallelArrays owner-ids beneficiary-ids amounts)
                    )
                    (oc:object{IgnisCollectorV1.OutputCumulator}
                        (XI_VacateTrueFungibleFromLegs pool-id dptf-id legs)
                    )
                )
                (do
                    (XI_MaybeFinalizeVacate pool-id dptf-id VACATE-KIND-TF finalize)
                    oc
                )
            )
        )
    )
    (defun C_VacateOrtoFungibleLegs:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
        @doc "Vacate one gas-safe OF nonce batch. Amounts may be zero-sentinels (resolved from tracker)."
        (UEV_IMC)
        (let
            (
                (of-amounts:[[decimal]]
                    (URC_ResolveOfDecimalAmountsFromTracker
                        pool-id dpof-id owner-ids beneficiary-ids nonces-array
                    )
                )
            )
            (with-capability
                (VCT|C>LEGS-ORTO-FUNGIBLE-VACATE
                    pool-id dpof-id owner-ids beneficiary-ids nonces-array of-amounts finalize
                )
                (XI_EnsureVacateBegun pool-id)
                (let
                    (
                        (oc:object{IgnisCollectorV1.OutputCumulator}
                            (XI_VacateOrtoFungibleBatch
                                pool-id dpof-id owner-ids beneficiary-ids nonces-array of-amounts
                            )
                        )
                    )
                    (do
                        (XI_MaybeFinalizeVacate pool-id dpof-id VACATE-KIND-OF finalize)
                        oc
                    )
                )
            )
        )
    )
    (defun C_VacateSemiFungibleLegs:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dpsf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
        (UEV_IMC)
        (with-capability
            (VCT|C>LEGS-COLLECTABLE-VACATE
                pool-id dpsf-id true owner-ids beneficiary-ids nonces-array amounts-array finalize
            )
            (XI_EnsureVacateBegun pool-id)
            (let
                (
                    (oc:object{IgnisCollectorV1.OutputCumulator}
                        (XI_VacateCollectableBatch
                            pool-id dpsf-id true owner-ids beneficiary-ids nonces-array amounts-array
                        )
                    )
                )
                (do
                    (XI_MaybeFinalizeVacate pool-id dpsf-id VACATE-KIND-DPSF finalize)
                    oc
                )
            )
        )
    )
    (defun C_VacateNonFungibleLegs:object{IgnisCollectorV1.OutputCumulator}
        (
            pool-id:string
            dpnf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
            finalize:bool
        )
        (UEV_IMC)
        (with-capability
            (VCT|C>LEGS-COLLECTABLE-VACATE
                pool-id dpnf-id false owner-ids beneficiary-ids nonces-array amounts-array finalize
            )
            (XI_EnsureVacateBegun pool-id)
            (let
                (
                    (oc:object{IgnisCollectorV1.OutputCumulator}
                        (XI_VacateCollectableBatch
                            pool-id dpnf-id false owner-ids beneficiary-ids nonces-array amounts-array
                        )
                    )
                )
                (do
                    (XI_MaybeFinalizeVacate pool-id dpnf-id VACATE-KIND-DPNF finalize)
                    oc
                )
            )
        )
    )
    (defun C_AbortVacate:object{IgnisCollectorV1.OutputCumulator} (pool-id:string)
        @doc "Clear vacate-in-progress; stake stays disabled (ops: C_EnablePoolStake)."
        (UEV_IMC)
        (with-capability (VCT|C>ABORT-VACATE-POOL pool-id)
            (XI_ClearVacateInProgress pool-id)
            (UC_EmptyOc)
        )
    )

    ;;{F7}  [X] — internal orchestration (after all C_* recipes)
    ;; Depth: C_* → XI_* (depth 0) → XI_1|* (depth 1) → XI_2|* (depth 2) → XI_3|* (depth 3).
    ;; Begin/finalize: XI_EnsureVacateBegun / XI_MaybeFinalizeVacate / XI_ClearVacateInProgress.
    ;; AQP pool writes: ref-AQP::XB_* / XE_SetVacateJobState directly (SECURE from master cap).
    ;; Table persistence: W_ layer only. XI_* call W_ directly with ;; SECURE: comments; no raw insert/update/write on VCT|T|*.
    ;; SECURE composed by master VCT|C>* cap or P|VCT|RECIPE (atomic vacate batch). No UEV_* in XI bodies.
    ;;
    (defun XI_EnsureVacateBegun:string (pool-id:string)
        @doc "If vacate not in progress: set vacate-in-progress and disable pool stake."
        ;; SECURE: granted by master vacate caps.
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (if (UR_VacateInProgress pool-id)
                "already-begun"
                (do
                    (ref-AQP::XE_SetVacateJobState pool-id true "" "" "")
                    (if (ref-AQP::UR_AQP|PoolStakeEnabled pool-id)
                        (ref-AQP::XB_SetPoolStakeEnabled pool-id false)
                        true
                    )
                    "begun"
                )
            )
        )
    )
    (defun XI_ClearVacateInProgress:string (pool-id:string)
        ;; SECURE: granted by VCT|C>ABORT-VACATE-POOL / finalize path.
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (ref-AQP::XE_SetVacateJobState pool-id false "" "" "")
        )
    )
    (defun XI_MaybeFinalizeVacate:string
        (
            pool-id:string
            asset-id:string
            vacate-kind:integer
            finalize:bool
        )
        @doc "If finalize=true AND the pool is verified empty (URC_PoolFullyVacated — every employed score \
            \ nzs=0, so both LP streams are empty): clear vacate-in-progress and re-enable stake. If finalize \
            \ is requested but inventory remains, stake stays DISABLED and the session continues (finalize is \
            \ honoured only when truly empty — audit H3 / fix #6). Write path; the emptiness check is a bounded \
            \ ≤7 point-read URC (no scan, no enforce). asset-id/vacate-kind kept for call-site stability."
        ;; SECURE: granted by master vacate caps.
        (if (and finalize (URC_PoolFullyVacated pool-id))
            (let
                (
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-AQP::XE_SetVacateJobState pool-id false "" "" "")
                (ref-AQP::XB_SetPoolStakeEnabled pool-id true)
                "finalized"
            )
            (if finalize "finalize-deferred-inventory-remains" "continued")
        )
    )
    ;; Legs orchestration: XI_EnsureVacateBegun / XI_MaybeFinalizeVacate / XI_ClearVacateInProgress.
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
    (defun XI_VacateTrueFungibleForAsset:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dptf-id:string)
        @doc "Vacate rehaul — self-contained TF vacate for ONE DPTF lane of a pool (a specific dptf-id: the native \
            \ asset-id OR the F| frozen leg). SCAN that lane's staker inventory ON-CHAIN (URDC_VacateTfOwnerRows — \
            \ HEAVY); if the lane is empty, NO-OP (return empty Oc — the batch core is not empty-safe: a zero-leg \
            \ TF vacate would hit a 0.0 debit and abort); else unwind every leg + bulk custody-return \
            \ (XI_VacateTrueFungibleFromLegs). require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (legs:[object{VCT|VacateTfLeg}] (URDC_VacateTfOwnerRows pool-id dptf-id))
            )
            (if (= (length legs) 0)
                (UC_EmptyOc)
                (XI_VacateTrueFungibleFromLegs pool-id dptf-id legs)
            )
        )
    )
    (defun XI_VacateTrueFungibleAllLanes:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string)
        @doc "Vacate rehaul — vacate EVERY live DPTF lane of a TF-family pool: enumerate the pool's active DPTF ids \
            \ ON-CHAIN (URD_AQP|ActivePoolDptfIds — native asset-id AND the F| frozen leg, both separate tracker \
            \ rows) and vacate each (XI_VacateTrueFungibleForAsset). Never orphans the frozen leg. Concatenates all \
            \ lane cumulators; a pool with no TF stake → empty Oc (concat is not empty-safe). require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (lane-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                    (map
                        (lambda (dptf-id:string) (XI_VacateTrueFungibleForAsset pool-id dptf-id))
                        (ref-AQP::URD_AQP|ActivePoolDptfIds pool-id)))
            )
            (if (= (length lane-ocs) 0)
                (UC_EmptyOc)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators lane-ocs [])
            )
        )
    )
    (defun XI_VacateTrueFungibleFamilyPool:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string)
        @doc "Vacate rehaul — TF-FAMILY full vacate (class 0 LP farm / class 1 DPTF family). A TF-family pool can \
            \ hold up to THREE custody lane KINDS: native TF (asset-id), F| frozen TF, and Z|/H| DPOF satellites \
            \ (class 0 stakes a Z| sleeping-LP DPOF too — NOT TF-only). Vacate EVERY live DPTF lane \
            \ (XI_VacateTrueFungibleAllLanes: native + F|) AND every live DPOF satellite (URD_AQP|ActivePoolDpofIds \
            \ → XI_VacateOrtoFungiblePool). Fully agnostic on-chain scan — no orphaned lane, no wrong class \
            \ assumption. `all-tf-oc` is always a valid Oc (empty if no TF stake), so the concat list is never \
            \ empty. require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;; 1) every live DPTF lane (native + F| frozen)
                (all-tf-oc:object{IgnisCollectorV1.OutputCumulator} (XI_VacateTrueFungibleAllLanes pool-id))
                ;; 2) every live DPOF satellite (Z| sleeping for class 0; Z|/H| for class 1)
                (sat-ocs:[object{IgnisCollectorV1.OutputCumulator}]
                    (map
                        (lambda (dpof-id:string) (XI_VacateOrtoFungiblePool pool-id dpof-id))
                        (ref-AQP::URD_AQP|ActivePoolDpofIds pool-id)))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators (+ [all-tf-oc] sat-ocs) [])
        )
    )
    (defun XI_VacateOrtoFungiblePool:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string dpof-id:string)
        @doc "Vacate rehaul — self-contained OF vacate for ONE OF asset of a pool: SCAN its staker legs ON-CHAIN \
            \ (URDC_VacateNonceOwnerRowsRaw, kind OF), RESOLVE the per-nonce decimal amounts from the tracker \
            \ (URC_ResolveOfDecimalAmountsFromTracker — the scanned inventory carries zero-sentinel amounts), then \
            \ bulk custody-return + unwind (XI_VacateOrtoFungibleBatch). A class-1 DPTF pool has ≥1 OF satellite; \
            \ CC_FullVacate calls this once per satellite. require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (legs:[object{VCT|VacateNonceLeg}] (URDC_VacateNonceOwnerRowsRaw pool-id dpof-id VACATE-KIND-OF))
            )
            ;; empty-safe: the batch core is not empty-safe (empty owner-ids → enumerate 0 -1 → out-of-bounds)
            (if (= (length legs) 0)
                (UC_EmptyOc)
                (let
                    (
                        (owner-ids:[string] (map (lambda (l:object{VCT|VacateNonceLeg}) (at "owner-id" l)) legs))
                        (beneficiary-ids:[string] (map (lambda (l:object{VCT|VacateNonceLeg}) (at "beneficiary-id" l)) legs))
                        (nonces-array:[[integer]] (map (lambda (l:object{VCT|VacateNonceLeg}) (at "nonces" l)) legs))
                    )
                    (XI_VacateOrtoFungibleBatch pool-id dpof-id owner-ids beneficiary-ids nonces-array
                        (URC_ResolveOfDecimalAmountsFromTracker pool-id dpof-id owner-ids beneficiary-ids nonces-array))
                )
            )
        )
    )
    (defun XI_VacateCollectablePool:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string collectable-id:string son:bool)
        @doc "Vacate rehaul — self-contained collectable vacate for ONE collection of a pool (son=true → DPSF, \
            \ son=false → DPNF): SCAN its staker legs ON-CHAIN (URDC_VacateNonceOwnerRowsRaw, kind DPSF/DPNF — \
            \ the scanned inventory already carries each row's full tracker balance), extract owner/beneficiary/ \
            \ nonce arrays + the integer amounts (collectable units are whole → round the decimal balance), then \
            \ bulk custody-return + unwind (XI_VacateCollectableBatch). require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (legs:[object{VCT|VacateNonceLeg}]
                    (URDC_VacateNonceOwnerRowsRaw pool-id collectable-id
                        (if son VACATE-KIND-DPSF VACATE-KIND-DPNF)))
            )
            ;; empty-safe: the batch core is not empty-safe (empty owner-ids → enumerate 0 -1 → out-of-bounds)
            (if (= (length legs) 0)
                (UC_EmptyOc)
                (let
                    (
                        (owner-ids:[string] (map (lambda (l:object{VCT|VacateNonceLeg}) (at "owner-id" l)) legs))
                        (beneficiary-ids:[string] (map (lambda (l:object{VCT|VacateNonceLeg}) (at "beneficiary-id" l)) legs))
                        (nonces-array:[[integer]] (map (lambda (l:object{VCT|VacateNonceLeg}) (at "nonces" l)) legs))
                        ;; collectable units are whole → floor (parity with the proven UC_VacateDecimalAmountsToIntegers)
                        (amounts-array:[[integer]]
                            (map
                                (lambda (l:object{VCT|VacateNonceLeg})
                                    (map (lambda (q:decimal) (floor q)) (at "amounts" l)))
                                legs))
                    )
                    (XI_VacateCollectableBatch pool-id collectable-id son
                        owner-ids beneficiary-ids nonces-array amounts-array)
                )
            )
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
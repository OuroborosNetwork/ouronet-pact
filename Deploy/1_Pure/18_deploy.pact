;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 18 of 22
;; This is STEP 18 of 23 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-17 must have run first, including the init steps between deploys.
;; 3 source file(s), 849,276 gas measured in the REPL gas model, 258,962 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/06_VCT.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/07_MTX-AQP.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08_DSA.pact
;;
;; TOTAL: 3 interface(s), 3 module(s), 9 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/06_VCT.pact
;;      interface  AcquisitionVacateV1
;;      module     AQP-VCT
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/07_MTX-AQP.pact
;;      interface  AqpMtxV1
;;      module     MTX-AQP
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08_DSA.pact
;;      interface  DsaV1
;;      module     AQP-DSA
;;      table      P|T
;;      table      P|MT
;;      table      DSA|T|Template
;;      table      DSA|T|Agency
;;      table      DSA|T|OracleAuth
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/06_VCT.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AcquisitionVacateV1
    @doc "Interface for the AQP pool-vacate subsystem. Declares UC_ helpers for slice \
        \ sizing, URC_/URH_ readers for vacate progress, per-asset inventory and gas-bounded \
        \ owner-array checks, URHC_ slice-plan builders, per-fungibility XB_Vacate leg \
        \ writers, the CC_FullVacate drain flow, and C_AbortVacate/C_FinalizeVacate client \
        \ entrypoints returning IGNIS OutputCumulators."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|Demiurgoi ())

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
    ;; [UC]  compute
    (defun UC_ComputeMinSliceCount:integer (unit-count:integer vacate-kind:integer))
    (defun UC_ZeroIntAmountsMatrix:[[integer]] (nonces-array:[[integer]]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    (defun UR_VacateInProgress:bool (pool-id:string))
    (defun URC_PoolFullyVacated:bool (pool-id:string))
    (defun URC_TfOwnerArraysGasOk:bool (owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun URC_BatchOwnerArraysGasOk:bool (owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] gas-max:integer))
    ;; [URH] heavy-read
    (defun URHC_BuildVacateSlicePlan:object
        (pool-id:string asset-id:string vacate-kind:integer slice-count:integer))
    (defun URHC_VacateUnitCountForKind:integer
        (pool-id:string asset-id:string vacate-kind:integer))
    (defun URH_VacateTfInventory:object (pool-id:string dptf-id:string))
    (defun URH_VacateOfInventory:object (pool-id:string dpof-id:string))
    (defun URH_VacateCollectableInventory:object (pool-id:string collectable-id:string son:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;; [XB]
    (defun XB_VacateTrueFungible:object{IgnisCollectorV3.OutputCumulator} (pool-id:string))
    (defun XB_VacateOrtoFungible:object{IgnisCollectorV3.OutputCumulator} (pool-id:string dpof-id:string))
    (defun XB_VacateSemiFungible:object{IgnisCollectorV3.OutputCumulator} (pool-id:string dpsf-id:string))
    (defun XB_VacateNonFungible:object{IgnisCollectorV3.OutputCumulator} (pool-id:string dpnf-id:string))
    ;;{5.7}  User [A/C]
    ;; [C]   client
    (defun CC_FullVacate:object{IgnisCollectorV3.OutputCumulator} (pool-id:string))
    (defun CCp_BatchVacateTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun CCp_BatchVacateOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]]))
    (defun CCp_BatchVacateCollectables:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    (defun CCp_BatchDrainTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun CCp_BatchDrainOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]]))
    (defun CCp_BatchDrainCollectable:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    (defun C_AbortVacate:object{IgnisCollectorV3.OutputCumulator} (pool-id:string))
    (defun C_FinalizeVacate:object{IgnisCollectorV3.OutputCumulator} (pool-id:string))

)

;; =============================================================================
;; AQP-VCT — Acquisition Vacate (pool-owner forced unstake)
;; =============================================================================
;; Two UI variants — pick one per pool × asset stream:
;;
;;   FULL (one tx, Talos wired) — input is JUST the pool-id (+ asset-id for the XB_ per-stream forms)
;;     CC_FullVacate(pool-id) — AGNOSTIC: VCT reads aqp-class, scans the pool inventory ON-CHAIN
;;       (lanes derived from asset-id, no UI arrays) and vacates every asset type; auto-begin →
;;       vacate all → auto-finalize (re-enable stake). Fits a pool that empties inside one tx.
;;     XB_Vacate{TrueFungible,OrtoFungible,SemiFungible,NonFungible} — one asset stream of a pool,
;;       same on-chain scan, standalone or as the family branch CC_FullVacate composes.
;;
;;   STATELESS BATCHED LEGS (multi-tx, Talos wired) — for pools too large to empty in one tx
;;     Cp_BatchVacate{TrueFungible,OrtoFungible,Collectables}(… owner/beneficiary/nonce slice …) —
;;       UI splits inventory into gas-safe, disjoint (owner,beneficiary[,nonce]) slices and fires N
;;       parallel txs. There is NO finalize flag: the first batch auto-begins (freeze stake+unstake+
;;       the pool's FVTs), each batch drains its slice, and the batch that empties the pool
;;       (URC_PoolFullyVacated — all ≤7 scores nzs==0) auto-finalizes/unfreezes. Chainweb serial
;;       execution means the batches integrate one-at-a-time → no write conflicts, first/last safe.
;;     C_AbortVacate(pool-id) clears vacate-in-progress; stake stays disabled (ops re-enable).
;;
;; Vacate entity = OWNER (custody recipient). One owner may have multiple beneficiaries.
;; Bulk transfer list: parallel owner-ids, beneficiary-ids, amounts (or nonces per owner row).
;; Table unwind dedupes by unique beneficiary (shared beneficiaries across owners).
;;
;; TF vacate unit of work = one object{AcquisitionSchemasV1.VCT|VacateTfLeg} (owner × beneficiary × balance).
;;   URHC_VacateTfOwnerRows → legs; all TF vacate XI_* take legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}].
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
    @doc "Sovereign vacate module that unwinds an AQP pool by returning every staked \
        \ position to owners. Works over slice-payload/plan and per-leg inventory/lane \
        \ schemas to batch-drain TF/OF/SF/NF stakes in gas-bounded slices. Provides \
        \ XB_Vacate per-fungibility leg writers, the CC_FullVacate paginated drain, and \
        \ owner-gated C_AbortVacate / C_FinalizeVacate; finalize requires the pool empty and \
        \ nukes the employed scores' totals via AQP-SCORE."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    (implements OuronetPolicyV2)
    (implements AcquisitionVacateV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    (defconst GOV|MD_VCT (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV () (compose-capability (GOV|VCT_ADMIN)))
    (defcap GOV|VCT_ADMIN () (enforce-guard GOV|MD_VCT))
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
    (defconst P|I (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    (deftable P|T:{OuronetPolicyV2.P|S})                          ;;Key = <Policy-Name>
    (deftable P|MT:{OuronetPolicyV2.P|MS})                        ;;Key = module P|I singleton
    ;;{P4}  capabilities
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
        (with-capability (GOV|VCT_ADMIN)
            (write P|T policy-name {"policy" : policy-guard})
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|VCT_ADMIN)
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
        (with-capability (GOV|VCT_ADMIN)
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
        (with-capability (GOV|VCT_ADMIN)
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
        @doc "Post-deploy: VCT SECURE on AQP-SCORE + AQP-POOL + AQP-FVT IMP; P|VCT|CALLER on TFT/DPOF/DPDC-T; VCT|RemoteAqpGov on AQP-POOL."
        (let
            (
                (ref-P|SCR:module{OuronetPolicyV2} AQP-SCORE)
                (ref-P|AQP:module{OuronetPolicyV2} AQP-POOL)
                (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                (ref-P|RPS:module{OuronetPolicyV2} RPS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                ;;
                (dg:guard (create-capability-guard (SECURE)))
                (mg:guard (create-capability-guard (P|VCT|CALLER)))
                (rg:guard (create-capability-guard (P|VCT|REMOTE-GOV)))
            )
            (ref-P|SCR::P|A_AddIMP dg)
            (ref-P|AQP::P|A_AddIMP dg)
            (ref-P|FVT::P|A_AddIMP dg)
            ;; #75 B': VCT's RPS-vacate pre-zero drives RPS::XE_BankScorePendingRewards — register on RPS IMP.
            (ref-P|RPS::P|A_AddIMP dg)
            (ref-P|AQP::P|A_Add "VCT|RemoteAqpGov" rg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR (CT_Bar))
    (defconst AQP|SC_NAME (CT_AqpScName))
    (defconst VACATE-KIND-TF 1)
    (defconst VACATE-KIND-OF 2)
    (defconst VACATE-KIND-DPSF 3)
    (defconst VACATE-KIND-DPNF 4)
    ;; REPL gas sweep (REPL/VCT-gas-sweep.repl) tunes these; keep above probe ladder max during profiling.
    ;; OF/DPSF/DPNF: max total nonces summed across all owner rows per chunk tx (not owner count).
    (defconst VACATE-MAX-NONCES 64)
    (defconst VACATE-FULL-MAX-LEGS 128)
    (defconst VACATE-FULL-MAX-NONCES 512)
    (defconst VACATE-GAS-MAX-TF 24)                     ;; legacy flat caps — superseded by the beneficiary-aware model below,
    (defconst VACATE-GAS-MAX-OF 33)                     ;; kept for UC_ComputeMinSliceCount / slice-plan references.
    (defconst VACATE-GAS-MAX-DPSF 29)
    (defconst VACATE-GAS-MAX-DPNF 30)
    ;; Vacate-v2 Phase 2 — beneficiary-aware gas model (measured; applies to BOTH v1 vacate and v2 drain).
    ;; est = unique-bens × PER-BEN + positions × PER-POS ≤ BUDGET. Cost is dominated by the per-beneficiary
    ;; settle (~67-85k); the per-position marginal is small (~4k bare / ~10k trait-rich).
    ;; ROLE (Phase 2 Step 3): this on-chain check is a GENEROUS BACKSTOP + the UI's seed — NOT the optimizer.
    ;; The UI sizes real batches by simulating (/local dry-run) against the true, model-dependent gas and the
    ;; node's gas meter is the real enforcement; an aborted oversized batch is atomic (rolls back — submitter's
    ;; gas, no protocol harm). So the coefficients are the CHEAPEST realistic case (bare NFT, low settle), making
    ;; the cap loose enough to never throttle a well-simulated batch: ~481 concentrated / ~25 spread. It only
    ;; rejects egregiously-oversized / non-simulated batches early with a clean error. UC_ComputeMinSliceCount
    ;; seeds the UI's optimization loop from the same model (concentrated slice size).
    (defconst VACATE-GAS-BUDGET 2000000)
    (defconst VACATE-GAS-PER-BEN 75000)
    (defconst VACATE-GAS-PER-POS 4000)
    ;;{3.2}  schemas
    ;; Offline plan schemas (SlicePayload / VacateSlicePlan). No Job/Slice session tables.
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap SECURE () true)
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap VCT|C>TRUE-FUNGIBLE-VACATE
        (
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
        @doc "Authorizes a true-fungible vacate batch on <pool-id>/<dptf-id>: validates pool class, asset match, \
            \ per-tx gas bound on the parallel owner/beneficiary/amount arrays, and that every (owner,beneficiary) \
            \ leg is actually staked for the given amount. Enforces pool-owner ownership, that the DPTF stake is \
            \ not reserved, and composes the P|VCT|RECIPE recipe capability for the XB write."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (class-ok:bool (ref-AQP::URC_StakeTrueFungiblePoolClassOk pool-id))
                (asset-ok:bool (ref-AQP::URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id))
                (gas-ok:bool (URC_TfOwnerArraysGasOk owner-ids beneficiary-ids amounts))
                (legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}]
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
        @doc "Authorizes an orto-fungible vacate batch on <pool-id>/<dpof-id>: validates asset match, the per-tx \
            \ gas bound on the owner/beneficiary/nonce arrays, the total nonce count, and that every per-owner \
            \ nonce row is actually staked for the given amounts. Enforces pool-owner ownership and composes \
            \ the P|VCT|RECIPE recipe capability for the XB write."
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
        @doc "Authorizes a collectable (SF/NF) vacate batch on <pool-id>/<collectable-id> (<son> = set vs \
            \ non-set): validates pool class, asset match, the per-tx gas bound (DPSF vs DPNF max), the total \
            \ nonce count, and that every per-owner nonce row is actually staked for the given amounts. Enforces \
            \ pool-owner ownership and composes the P|VCT|RECIPE recipe capability for the XB write."
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
    (defcap VCT|C>FINALIZE-VACATE (pool-id:string)
        @doc "Vacate-v2 finalize (nuke) master cap. All validation here, not in the body: the tx sender must own \
            \ the pool (CAP_VctVacatePoolOwner), a vacate must be in progress, AND the pool must be fully drained \
            \ (URC_PoolFullyVacated — nns==0, so every position is out and every beneficiary was already settled \
            \ during the drain). Composes SECURE for the pool re-enable + FVT unfreeze; the per-score nuke goes \
            \ through SCORE's own IMC-gated XE_NukeScoreForVacate."
        @event
        (CAP_VctVacatePoolOwner pool-id)
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (enforce (ref-AQP::UR_AQP|PoolVacateInProgress pool-id) "Finalize: no vacate in progress on this pool")
            (enforce (URC_PoolFullyVacated pool-id) "Finalize: pool not fully drained (nns != 0)")
        )
        (compose-capability (SECURE))
    )
    (defcap VCT|C>VACATE (pool-id:string)
        @doc "Master AGNOSTIC vacate cap (rehaul). Class-agnostic: the new vacate reads the pool's staker legs \
            \ ON-CHAIN (no UI-supplied arrays to tamper/validate), so this gates the pool OWNER, ENFORCES the pool's \
            \ aqp-class is a known class (0-4) — all validation lives here, not in the function body — and composes \
            \ SECURE + P|VCT|RECIPE. Used by the single-tx dispatcher CC_FullVacate and the per-kind XB_Vacate* \
            \ wrappers; the per-kind XI_Vacate*FromLegs / *PoolLegs functions run under it via require P|VCT|RECIPE."
        @event
        (CAP_VctVacatePoolOwner pool-id)
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (enforce (contains (ref-AQP::UR_AQP|PoolAqpClass pool-id) [0 1 2 3 4])
                "VCT|C>VACATE: unknown aqp-class")
        )
        (compose-capability (SECURE))
        (compose-capability (P|VCT|RECIPE))
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
    (defun CT_AqpScName:string ()
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-ANK::GOV|AQP|SC_NAME)
        )
    )
    ;; [UDC] construct
    (defun UDC_TfSlicePayload:object{AcquisitionSchemasV1.VCT|SlicePayload}
        (
            pool-id:string
            asset-id:string
            vacate-asset-kind:integer
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
        @doc "Construct a TF vacate SlicePayload object: owner / beneficiary / amount parallel arrays with the \
            \ nonce fields left empty."
        {"pool-id"              : pool-id
        ,"asset-id"             : asset-id
        ,"vacate-asset-kind"    : vacate-asset-kind
        ,"owner-ids"            : owner-ids
        ,"beneficiary-ids"      : beneficiary-ids
        ,"amounts"              : amounts
        ,"nonces-array"         : []
        ,"amounts-array"        : []}
    )
    (defun UDC_NonceSlicePayload:object{AcquisitionSchemasV1.VCT|SlicePayload}
        (
            pool-id:string
            asset-id:string
            vacate-asset-kind:integer
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Construct a nonce (OF/SF/NF) vacate SlicePayload object: owner / beneficiary arrays plus the \
            \ nonces / amounts matrices, with the TF amounts field left empty."
        {"pool-id"              : pool-id
        ,"asset-id"             : asset-id
        ,"vacate-asset-kind"    : vacate-asset-kind
        ,"owner-ids"            : owner-ids
        ,"beneficiary-ids"      : beneficiary-ids
        ,"amounts"              : []
        ,"nonces-array"         : nonces-array
        ,"amounts-array"        : amounts-array}
    )
    (defun UDC_VacateSlicePlan:object{AcquisitionSchemasV1.VCT|VacateSlicePlan}
        (
            vacate-job-id:string
            pool-id:string
            asset-id:string
            vacate-asset-kind:integer
            slice-count:integer
            slices:[object{AcquisitionSchemasV1.VCT|SlicePayload}]
        )
        @doc "Construct the offline VacateSlicePlan the UI drives: job id, pool / asset, vacate kind, slice \
            \ count, and the per-slice payloads (one gas-bounded batch tx each)."
        {"vacate-job-id"        : vacate-job-id
        ,"pool-id"              : pool-id
        ,"asset-id"             : asset-id
        ,"vacate-asset-kind"    : vacate-asset-kind
        ,"slice-count"          : slice-count
        ,"slices"               : slices}
    )
    ;;
    (defun UDC_VacateTfLeg:object{AcquisitionSchemasV1.VCT|VacateTfLeg}
        (owner-id:string beneficiary-id:string balance:decimal)
        @doc "Construct a TF vacate leg object (owner, beneficiary, staked balance)."
        {"owner-id" : owner-id, "beneficiary-id" : beneficiary-id, "balance" : balance}
    )
    (defun UDC_VacateNonceRow:object{AcquisitionSchemasV1.VCT|VacateNonceRow}
        (owner-id:string beneficiary-id:string nonce:integer balance:decimal)
        @doc "Construct a single-nonce vacate row object (owner, beneficiary, nonce, balance)."
        {"owner-id" : owner-id, "beneficiary-id" : beneficiary-id, "nonce" : nonce, "balance" : balance}
    )
    (defun UDC_VacateNonceLeg:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}
        (owner-id:string beneficiary-id:string nonces:[integer] amounts:[decimal])
        @doc "Construct a per-owner nonce vacate leg object (owner, beneficiary, nonces, amounts)."
        {"owner-id" : owner-id, "beneficiary-id" : beneficiary-id, "nonces" : nonces, "amounts" : amounts}
    )
    (defun UDC_VacateTfLane:object{AcquisitionSchemasV1.VCT|VacateTfLane}
        (asset-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Construct a TF vacate lane object (asset-id + its TF legs)."
        {"asset-id" : asset-id, "legs" : legs}
    )
    (defun UDC_VacateNonceLane:object{AcquisitionSchemasV1.VCT|VacateNonceLane}
        (asset-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Construct a nonce vacate lane object (asset-id + its nonce legs)."
        {"asset-id" : asset-id, "legs" : legs}
    )
    (defun UDC_VacateTfInventory:object{AcquisitionSchemasV1.VCT|VacateTfInventory}
        (legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Construct a TF vacate inventory object (legs + derived leg-count)."
        {"legs" : legs, "leg-count" : (length legs)}
    )
    (defun UDC_VacateNonceLegInventory:object{AcquisitionSchemasV1.VCT|VacateNonceLegInventory}
        (legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Construct a nonce vacate inventory object (legs + derived leg-count)."
        {"legs" : legs, "leg-count" : (length legs)}
    )
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    (defun UC_EmptyOc:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "The empty OutputCumulator (no IGNIS, no STOA) — the identity result for vacate paths that bill nothing."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    (defun UC_CeilDiv:integer (numerator:integer denominator:integer)
        @doc "Ceiling integer division; returns <numerator> unchanged when <denominator> is <= 0 (guard)."
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
        @doc "Per-tx gas-max unit budget for a vacate kind (TF / OF / DPSF / DPNF)."
        (if (= vacate-kind VACATE-KIND-TF)
            VACATE-GAS-MAX-TF
            (if (= vacate-kind VACATE-KIND-OF)
                VACATE-GAS-MAX-OF
                (if (= vacate-kind VACATE-KIND-DPSF) VACATE-GAS-MAX-DPSF VACATE-GAS-MAX-DPNF)
            )
        )
    )
    (defun UC_ComputeMinSliceCount:integer (unit-count:integer vacate-kind:integer)
        @doc "UI SEED for the batch-optimization loop (Phase 2 Step 3): minimum slice txs assuming the best case \
            \ (fully concentrated — one beneficiary, so the ~PER-BEN settle is paid once), i.e. slice size = \
            \ (BUDGET - PER-BEN) / PER-POS ~= 481 positions. This is the aggressive starting point; the UI then \
            \ SIMULATES each candidate (/local) against the true gas and ADDS slices if a chunk doesn't fit (a \
            \ spread pool pays the settle per position, so it needs more slices). Kind-agnostic now — the gas \
            \ model is beneficiary/position-based, not per-kind. TF unit-count = owner count; OF/SF/NF = total \
            \ nonces. vacate-kind retained for call-site stability."
        (let
            (
                (slice-size:integer (/ (- VACATE-GAS-BUDGET VACATE-GAS-PER-BEN) VACATE-GAS-PER-POS))
                (raw:integer (UC_CeilDiv unit-count slice-size))
            )
            (if (> raw 1) raw 1)
        )
    )
    (defun UC_BatchNonceTotal:integer (nonces-array:[[integer]])
        @doc "Total nonce count across a nonces-array (sum of each row's length)."
        (fold
            (+)
            0
            (map (lambda (ns:[integer]) (length ns)) nonces-array)
        )
    )
    (defun UC_OwnerRowNonceTotal:integer (owner-rows:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Total nonce count across per-owner vacate nonce rows (sum of each row's nonce count)."
        (fold
            (+)
            0
            (map (lambda (row:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (length (at "nonces" row))) owner-rows)
        )
    )
    (defun UC_SplitNonceOwnerRowToMax:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}]
        (owner-row:object{AcquisitionSchemasV1.VCT|VacateNonceLeg} max-nonces:integer)
        @doc "Split one per-owner nonce row into <= max-nonces-sized chunks (preserving owner/beneficiary), so \
            \ each resulting slice tx stays within the gas budget. Returns [owner-row] unchanged when it already fits."
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
    (defun UC_ExpandNonceOwnerRowsForGasMax:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}]
        (owner-rows:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}] max-nonces:integer)
        @doc "Expand per-owner nonce rows into gas-bounded rows by splitting any row whose nonce count exceeds \
            \ <max-nonces> (via UC_SplitNonceOwnerRowToMax)."
        (fold
            (lambda
                (acc:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}]
                    owner-row:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}
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
        @doc "Zero-amount integer row matching the length of <nonces> (OF vacate carries no per-nonce amount)."
        (map (lambda (_:integer) 0) nonces)
    )
    (defun UC_ZeroIntAmountsMatrix:[[integer]] (nonces-array:[[integer]])
        @doc "Per-row zero-amount integer matrix matching <nonces-array> shape."
        (map UC_ZeroIntAmountsRow nonces-array)
    )
    (defun UC_DecimalAmountsRowToInt:[integer] (amounts:[decimal])
        @doc "Floor each decimal amount in a row to integer (collectable nonce amounts are whole units)."
        (map (lambda (a:decimal) (floor a)) amounts)
    )
    (defun UC_DecimalAmountsMatrixToInt:[[integer]] (rows:[[decimal]])
        @doc "Floor a decimal amounts matrix to integers, row by row."
        (map UC_DecimalAmountsRowToInt rows)
    )
    (defun UC_TfSlicePayloadFromOwnerRows:object{AcquisitionSchemasV1.VCT|SlicePayload}
        (pool-id:string asset-id:string owner-rows:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Build a TF vacate SlicePayload from per-owner TF legs (projects the owner / beneficiary / balance \
            \ parallel arrays and stamps VACATE-KIND-TF)."
        (UDC_TfSlicePayload
            pool-id
            asset-id
            VACATE-KIND-TF
            (map (lambda (row:object{AcquisitionSchemasV1.VCT|VacateTfLeg}) (at "owner-id" row)) owner-rows)
            (map (lambda (row:object{AcquisitionSchemasV1.VCT|VacateTfLeg}) (at "beneficiary-id" row)) owner-rows)
            (map (lambda (row:object{AcquisitionSchemasV1.VCT|VacateTfLeg}) (at "balance" row)) owner-rows)
        )
    )
    (defun UC_NonceSlicePayloadFromOwnerRows:object{AcquisitionSchemasV1.VCT|SlicePayload}
        (pool-id:string asset-id:string vacate-kind:integer owner-rows:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Build a nonce (OF/SF/NF) vacate SlicePayload from per-owner nonce rows: OF carries zeroed amounts, \
            \ SF/NF floor the decimal amounts to integers."
        (let
            (
                (nonces-array:[[integer]]
                    (map (lambda (row:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "nonces" row)) owner-rows)
                )
                (amounts-array:[[integer]]
                    (if (= vacate-kind VACATE-KIND-OF)
                        (UC_ZeroIntAmountsMatrix nonces-array)
                        (UC_DecimalAmountsMatrixToInt
                            (map (lambda (row:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "amounts" row)) owner-rows)
                        )
                    )
                )
            )
            (UDC_NonceSlicePayload
                pool-id
                asset-id
                vacate-kind
                (map (lambda (row:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "owner-id" row)) owner-rows)
                (map (lambda (row:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "beneficiary-id" row)) owner-rows)
                nonces-array
                amounts-array
            )
        )
    )
    (defun UC_BuildTfVacateSlicePlanFromOwnerRows:object{AcquisitionSchemasV1.VCT|VacateSlicePlan}
        (
            pool-id:string
            asset-id:string
            slice-count:integer
            owner-rows:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}]
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
                                (slice-owner-rows:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}]
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
    (defun UC_BuildNonceVacateSlicePlanFromOwnerRows:object{AcquisitionSchemasV1.VCT|VacateSlicePlan}
        (
            pool-id:string
            asset-id:string
            vacate-kind:integer
            slice-count:integer
            owner-rows:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}]
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
                                (slice-owner-rows:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}]
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
    (defun UC_MergeVacateNonceRowIntoLegs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}]
        (acc:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}] owner-id:string beneficiary-id:string nonce:integer amount:decimal)
        @doc "Fold step: append one active nonce row into grouped vacate legs (owner × beneficiary)."
        (if (= (length acc) 0)
            [
                (UDC_VacateNonceLeg owner-id beneficiary-id [nonce] [amount])
            ]
            (let
                (
                    (last-idx:integer (- (length acc) 1))
                    (last:object{AcquisitionSchemasV1.VCT|VacateNonceLeg} (at last-idx acc))
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
    (defun UC_MergeVacateCollectableRowIntoLegs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}]
        (acc:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}] owner-id:string beneficiary-id:string nonce:integer amount:decimal)
        @doc "Fold step for collectable vacate legs — same grouping as UC_MergeVacateNonceRowIntoLegs."
        (if (= (length acc) 0)
            [
                (UDC_VacateNonceLeg owner-id beneficiary-id [nonce] [amount])
            ]
            (let
                (
                    (last-idx:integer (- (length acc) 1))
                    (last:object{AcquisitionSchemasV1.VCT|VacateNonceLeg} (at last-idx acc))
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
        @doc "Collectable vacate: tracker decimal balances → integer amounts for DPDC-T bulk. \
            \ Delegates to UC_DecimalAmountsRowToInt: same operation, one implementation."
        ;;MADE TOTAL 2026-09-13. This used to index its own argument through
        ;;`(enumerate 0 (- (length amounts) 1))`, which is the descending-pair trap: on an EMPTY list
        ;;that is `(enumerate 0 -1)`, and Pact evaluates that to `[0, -1]` -- NOT the empty list -- so
        ;;the map then ran `(at 0 [])` and died on a native "Array index out of bounds" fault.
        ;;Its twin `UC_DecimalAmountsRowToInt` (above) does the identical job with a plain `map` and
        ;;is total; the two were verified to return identical results on every non-empty input.
        ;;
        ;;NOT A LIVE BUG, which is why this is a delegation rather than a behaviour change: every
        ;;leg reaching here is built by `UC_MergeVacateNonceRowIntoLegs`, which always constructs
        ;;with at least one element (`[nonce]` / `[amount]`) and only ever APPENDS -- so an empty
        ;;amounts row is unreachable today. It was a footgun armed for whoever next changes the leg
        ;;builder, and collapsing the duplicate removes it. Pinned by REPL/modules/AQP.repl <<AQP-F3>>.
        (UC_DecimalAmountsRowToInt amounts)
    )
    (defun UC_VacateOfLegsToVacateArrays:object (legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Build parallel OF vacate batch arrays from VacateOfInventory legs (object{AcquisitionSchemasV1.VCT|VacateNonceLeg}). Module: AQP-VCT."
        {
            "owner-ids"             : (map (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "owner-id" leg)) legs)
            ,"beneficiary-ids"      : (map (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "beneficiary-id" leg)) legs)
            ,"nonces-array"         : (map (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "nonces" leg)) legs)
            ,"nonce-amounts-array"  : (map (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "amounts" leg)) legs)
        }
    )
    (defun UC_VacateCollectableLegsToVacateArrays:object (legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Build parallel collectable vacate batch arrays from VacateCollectableInventory legs. \
            \ Integer amounts via UC_VacateDecimalAmountsToIntegers. Module: AQP-VCT."
        {
            "owner-ids"         : (map (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "owner-id" leg)) legs)
            ,"beneficiary-ids"  : (map (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "beneficiary-id" leg)) legs)
            ,"nonces-array"     : (map (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "nonces" leg)) legs)
            ,"amounts-array"    : (map
                (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateNonceLeg})
                    (UC_VacateDecimalAmountsToIntegers (at "amounts" leg))
                )
                legs
            )
        }
    )
    (defun UC_VacateUniqueBeneficiaries:[string] (beneficiary-ids:[string])
        @doc "Order-preserving distinct beneficiary-ids (the merge target set for per-beneficiary rollup)."
        (fold (lambda (acc:[string] b:string) (if (contains b acc) acc (+ acc [b]))) [] beneficiary-ids)
    )
    (defun UC_VacateMergeDecimalNonceRowsForBeneficiary:object
        (beneficiary-id:string beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[decimal]])
        @doc "Concatenate the nonces/amounts (decimal) of every row whose beneficiary equals <beneficiary-id> \
            \ into a single {nonces, amounts} object — per-beneficiary merge for the OF/SF/NF vacate rollup."
        ;;EMPTY-INPUT GUARD (2026-09-13). `(enumerate 0 (- (length xs) 1))` on an EMPTY list is
        ;;`(enumerate 0 -1)`, which Pact evaluates to the DESCENDING PAIR `[0, -1]` -- NOT the empty
        ;;list -- so the body then indexes `(at 0 [])` and dies on a native "Array index out of
        ;;bounds". The index is genuinely needed here (it zips parallel arrays), so the repair is a
        ;;guard rather than a `map` over one list.
        (if (= (length beneficiary-ids) 0)
            {"nonces": [], "amounts": []}
            (fold
                (lambda (acc:object idx:integer)
                    (if (= beneficiary-id (at idx beneficiary-ids))
                        {"nonces": (+ (at "nonces" acc) (at idx nonces-array)), "amounts": (+ (at "amounts" acc) (at idx amounts-array))}
                        acc))
                {"nonces": [], "amounts": []}
                (enumerate 0 (- (length beneficiary-ids) 1))
            )
        )
    )
    (defun UC_VacateMergeIntNonceRowsForBeneficiary:object
        (beneficiary-id:string beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]])
        @doc "Concatenate the nonces/amounts (integer) of every row whose beneficiary equals <beneficiary-id> \
            \ into a single {nonces, amounts} object — per-beneficiary merge for the collectable vacate rollup."
        ;;EMPTY-INPUT GUARD (2026-09-13). `(enumerate 0 (- (length xs) 1))` on an EMPTY list is
        ;;`(enumerate 0 -1)`, which Pact evaluates to the DESCENDING PAIR `[0, -1]` -- NOT the empty
        ;;list -- so the body then indexes `(at 0 [])` and dies on a native "Array index out of
        ;;bounds". The index is genuinely needed here (it zips parallel arrays), so the repair is a
        ;;guard rather than a `map` over one list.
        (if (= (length beneficiary-ids) 0)
            {"nonces": [], "amounts": []}
            (fold
                (lambda (acc:object idx:integer)
                    (if (= beneficiary-id (at idx beneficiary-ids))
                        {"nonces": (+ (at "nonces" acc) (at idx nonces-array)), "amounts": (+ (at "amounts" acc) (at idx amounts-array))}
                        acc))
                {"nonces": [], "amounts": []}
                (enumerate 0 (- (length beneficiary-ids) 1))
            )
        )
    )
    (defun UC_VacateUniqueBeneficiariesFromLegs:[string]
        (legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Preserve first-seen order; dedupe beneficiaries for score/RPS phases."
        (fold
            (lambda (acc:[string] leg:object{AcquisitionSchemasV1.VCT|VacateTfLeg})
                (let
                    (
                        (b:string (at "beneficiary-id" leg))
                    )
                    (if (contains b acc) acc (+ acc [b]))
                )
            )
            []
            legs
        )
    )
    (defun UC_VacateSumAmountForBeneficiaryFromLegs:decimal
        (beneficiary-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Sum leg balances for one beneficiary (rollup/score amount for deduped unwind)."
        (fold
            (+)
            0.0
            (map
                (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateTfLeg})
                    (if (= beneficiary-id (at "beneficiary-id" leg))
                        (at "balance" leg)
                        0.0
                    )
                )
                legs
            )
        )
    )
    (defun UC_TfLegsFromParallelArrays:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}]
        (owner-ids:[string] beneficiary-ids:[string] amounts:[decimal])
        @doc "Build leg objects from parallel Legs batch arrays. Empty in, empty out."
        ;;SHADOWED-GUARD FIX (2026-09-13). `VCT|C>TRUE-FUNGIBLE-VACATE-BATCH` binds
        ;;`gas-ok := (URC_TfOwnerArraysGasOk …)`, which DOES test `(> l 0)` -- and then binds `legs`
        ;;to THIS function in the same `let`. Pact evaluates let bindings eagerly, so on an empty
        ;;batch this faulted BEFORE the enforce could read `gas-ok`, and the caller saw a native
        ;;"Array index out of bounds" instead of "Invalid TF vacate cap input". Verified live: the
        ;;guard computed `false` correctly while this function faulted first.
        ;;Making it total restores the guard's voice -- `legs` becomes `[]`, `gas-ok` stays false,
        ;;and the enforce fires with its own message. Pinned by REPL/modules/AQP.repl <<AQP-F6>>.
        (if (= (length owner-ids) 0)
            []
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
    )
    (defun UC_VacateTfLegsToTftBulkArrays:object
        (legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "One DPTF row: parallel owner/balance inner lists for TFT::C_MultiBulkTransfer."
        {
            "receiver-array"
                : [
                    (map
                        (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateTfLeg})
                            (at "owner-id" leg)
                        )
                        legs
                    )
                ]
            ,"transfer-amount-array"
                : [
                    (map
                        (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateTfLeg})
                            (at "balance" leg)
                        )
                        legs
                    )
                ]
        }
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [URCi]   vacate / drain / full-vacate flow ifp readers — relocated from AQP-INFO (byte-identical
    ;;   ifp sums). Fed the SAME dirty-read legs/lanes the exec receives. Tier gates + the two score-delta
    ;;   sums are reached cross-module on AQP-FVT (AQP-FVT.URC_Tier* / AQP-FVT.URC_StakeScoreDeltaSum*),
    ;;   the single source they share with the stake readers. INFO repoints here; execs are unchanged.
    (defun URCi_FinalizeVacate:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "Single source for C_FinalizeVacate + its INFO preview: deter(usage) + the op's \
            \ components. USAGE tier — finalizing a vacate is activity on an already-authorised \
            \ campaign, not a new setup."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_FinalizeVacate" "usage")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) [])
        ))
    (defun URCi_BatchVacateTrueFungible:decimal
        (pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Variant-A shared cost estimator for CCp_BatchVacateTrueFungible. Mirrors \
            \ XI_VacateTrueFungibleFromLegs byte-for-byte: per-leg tracker-zero (medium) + per-unique- \
            \ beneficiary unwind (rollup biggest + free RPS-prezero + anchor-refresh [ANK per-live + XB \
            \ biggest] + score-delta + book + checkpoint) + the one bulk DPTF multi-transfer."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (unique-benefs:[string] (UC_VacateUniqueBeneficiariesFromLegs legs))
                (n-live:integer (length (AQP-ANK.UR_ANK|AnchorsForAsset dptf-id)))
                (bulk-arr:object (UC_VacateTfLegsToTftBulkArrays legs))
                (score-delta:decimal (RPS.URC_StakeScoreDeltaSum pool-id))
            )
            (fold (+) 0.0
                [ (* (RPS.URC_TierMedium) (dec (length legs)))                                 ;; per-leg tracker-zero
                  (fold (+) 0.0
                      (map
                          (lambda (benef:string)
                              (fold (+) 0.0
                                  [ (RPS.URC_TierBiggest)                                      ;; rollup
                                    (RPS.URC_TierFixed (AQP-ANK.URC_TrueFungibleStakeAnchorRefreshIgnis n-live)) ;; anchor refresh
                                    (RPS.URC_TierBiggest)                                      ;; XB sync-count flat
                                    (RPS.URC_TierFixed score-delta)                            ;; apply stake delta
                                    (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis
                                        (at "distinct-fvts" (RPS.URHC_BuildStakeSettleBundle pool-id benef)))) ;; book
                                    (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis))  ;; checkpoint
                                  ]))
                          unique-benefs))
                  (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator               ;; bulk DPTF multi-transfer
                      (TFT.URCi_MultiBulkTransferCumulator [dptf-id] AQP-POOL.AQP|SC_NAME
                          (at "receiver-array" bulk-arr) (at "transfer-amount-array" bulk-arr))))
                ])
        )
    )
    (defun URCi_BatchVacateOrtoFungible:decimal
        (pool-id:string dpof-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Variant-A shared cost estimator for CCp_BatchVacateOrtoFungible. Mirrors \
            \ XI_VacateOrtoFungibleBatch: the one bulk DPOF whole-nonce transfer (URCi_MoveCumulator over \
            \ all nonces) + per-owner-row tracker (medium × total-nonce-count) + per-unique-beneficiary \
            \ score unwind = free RPS-prezero + ApplyOFDelta (class-matched {0,2}) + book + checkpoint. \
            \ NO rollup, NO anchor (OF phase-3 N/A)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (nonces-array:[[integer]] (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "nonces" l)) legs))
                (unique-benefs:[string]
                    (UC_VacateUniqueBeneficiaries
                        (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "beneficiary-id" l)) legs)))
                (all-nonces:[integer] (fold (+) [] nonces-array))
                (score-delta:decimal (RPS.URC_StakeScoreDeltaSumForClasses pool-id [0 2]))
            )
            (fold (+) 0.0
                [ (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator               ;; bulk DPOF transfer
                      (DPOF.URCi_MoveCumulator dpof-id all-nonces false)))
                  (* (RPS.URC_TierMedium) (dec (length all-nonces)))                            ;; per-row tracker (medium × Σ|nonces|)
                  (fold (+) 0.0
                      (map
                          (lambda (benef:string)
                              (fold (+) 0.0
                                  [ (RPS.URC_TierFixed score-delta)                             ;; apply OF stake delta {0,2}
                                    (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis
                                        (at "distinct-fvts" (RPS.URHC_BuildStakeSettleBundle pool-id benef)))) ;; book
                                    (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis))   ;; checkpoint
                                  ]))
                          unique-benefs))
                ])
        )
    )
    (defun URCi_BatchVacateCollectables:decimal
        (pool-id:string collectable-id:string son:bool legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Variant-A shared cost estimator for CCp_BatchVacateCollectables (son=DPSF/DPNF). Mirrors \
            \ XI_VacateCollectableBatch: the one bulk DPDC-T transfer + per-owner-row (tracker medium× \
            \ |nonces| + rollup medium×|nonces|) + per-unique-beneficiary score unwind = free RPS-prezero \
            \ + FLAT anchor refresh (medium+biggest) + ApplyCollectableDelta (SF [3] / NF [4]) + book + \
            \ checkpoint. Collectable units are whole (amounts floored, matching exec)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (nonces-array:[[integer]] (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "nonces" l)) legs))
                (amounts-array:[[integer]]
                    (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg})
                            (map (lambda (q:decimal) (floor q)) (at "amounts" l))) legs))
                (unique-benefs:[string]
                    (UC_VacateUniqueBeneficiaries
                        (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "beneficiary-id" l)) legs)))
                (score-delta:decimal (RPS.URC_StakeScoreDeltaSumForClasses pool-id (if son [3] [4])))
                (anchor-flat:decimal (+ (RPS.URC_TierMedium) (RPS.URC_TierBiggest)))
            )
            (fold (+) 0.0
                [ (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator               ;; bulk DPDC-T transfer
                      (DPDC-T.URCi_BulkTransferCumulator collectable-id son AQP-POOL.AQP|SC_NAME
                          (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "owner-id" l)) legs)
                          nonces-array amounts-array)))
                  (* (* 2.0 (RPS.URC_TierMedium)) (dec (length (fold (+) [] nonces-array))))    ;; per-row tracker + rollup (each medium×|nonces|)
                  (fold (+) 0.0
                      (map
                          (lambda (benef:string)
                              (fold (+) 0.0
                                  [ (RPS.URC_TierFixed anchor-flat)                             ;; flat anchor refresh
                                    (RPS.URC_TierFixed score-delta)                             ;; apply collectable delta [son?3:4]
                                    (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis
                                        (at "distinct-fvts" (RPS.URHC_BuildStakeSettleBundle pool-id benef)))) ;; book
                                    (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis))   ;; checkpoint
                                  ]))
                          unique-benefs))
                ])
        )
    )
    (defun URCi_BatchDrainTrueFungible:decimal
        (pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Variant-A shared cost estimator for CCp_BatchDrainTrueFungible. Mirrors \
            \ XI_DrainTrueFungibleFromLegs (score-FREE): Phase A per-leg = tracker-zero (medium) + rollup \
            \ (biggest). Phase B settle-triple (book + checkpoint + anchor-refresh [ANK per-live + XB \
            \ biggest]) fires ONLY for beneficiaries whose UserUnn hits 0 this round — simulate the drain \
            \ read-only as pre-unn minus this batch's leg-count for that beneficiary == 0. Then the one \
            \ bulk DPTF multi-transfer. NO score-delta (drain leaves the score live for finalize)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (unique-benefs:[string] (UC_VacateUniqueBeneficiariesFromLegs legs))
                (n-live:integer (length (AQP-ANK.UR_ANK|AnchorsForAsset dptf-id)))
                (bulk-arr:object (UC_VacateTfLegsToTftBulkArrays legs))
                (anchor-ifp:decimal (+ (RPS.URC_TierFixed (AQP-ANK.URC_TrueFungibleStakeAnchorRefreshIgnis n-live)) (RPS.URC_TierBiggest)))
                (checkpoint:decimal (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis)))
            )
            (fold (+) 0.0
                [ (* (dec (length legs)) (+ (RPS.URC_TierMedium) (RPS.URC_TierBiggest)))    ;; Phase A per-leg tracker-zero + rollup
                  (fold (+) 0.0
                      (map
                          (lambda (benef:string)
                              (if (= (- (AQP-POOL.UR_AQP|UserUnn pool-id benef)
                                        (length (filter (lambda (l:object{AcquisitionSchemasV1.VCT|VacateTfLeg}) (= (at "beneficiary-id" l) benef)) legs)))
                                     0)
                                  (+ (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis
                                        (at "distinct-fvts" (RPS.URHC_BuildStakeSettleBundle pool-id benef))))
                                     (+ checkpoint anchor-ifp))
                                  0.0))
                          unique-benefs))
                  (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator               ;; bulk DPTF multi-transfer
                      (TFT.URCi_MultiBulkTransferCumulator [dptf-id] AQP-POOL.AQP|SC_NAME
                          (at "receiver-array" bulk-arr) (at "transfer-amount-array" bulk-arr))))
                ])
        )
    )
    (defun URCi_BatchDrainOrtoFungible:decimal
        (pool-id:string dpof-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Variant-A shared cost estimator for CCp_BatchDrainOrtoFungible. Mirrors \
            \ XI_DrainOrtoFungibleBatch (score-free): bulk DPOF transfer + per-owner-row tracker (medium × \
            \ total-nonces) + settle-on-last-drain (book + checkpoint, NO anchor for OF) only for \
            \ beneficiaries whose UserUnn hits 0 — OF decrements unn PER WHOLE NONCE, so simulate pre-unn \
            \ minus this benef's total nonce-count == 0. NO rollup, NO anchor, NO score-delta."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (unique-benefs:[string]
                    (UC_VacateUniqueBeneficiaries
                        (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "beneficiary-id" l)) legs)))
                (all-nonces:[integer] (fold (+) [] (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "nonces" l)) legs)))
                (checkpoint:decimal (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis)))
            )
            (fold (+) 0.0
                [ (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator               ;; bulk DPOF transfer
                      (DPOF.URCi_MoveCumulator dpof-id all-nonces false)))
                  (* (RPS.URC_TierMedium) (dec (length all-nonces)))                            ;; per-row tracker (medium × total-nonces)
                  (fold (+) 0.0
                      (map
                          (lambda (benef:string)
                              (if (= (- (AQP-POOL.UR_AQP|UserUnn pool-id benef)
                                        (fold (+) 0 (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (length (at "nonces" l)))
                                                         (filter (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (= (at "beneficiary-id" l) benef)) legs))))
                                     0)
                                  (+ (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis
                                        (at "distinct-fvts" (RPS.URHC_BuildStakeSettleBundle pool-id benef))))
                                     checkpoint)
                                  0.0))
                          unique-benefs))
                ])
        )
    )
    (defun URCi_BatchDrainCollectable:decimal
        (pool-id:string collectable-id:string son:bool legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "Variant-A shared cost estimator for CCp_BatchDrainCollectable. Mirrors \
            \ XI_DrainCollectableBatch (score-free): bulk DPDC-T transfer + per-owner-row Phase A = tracker \
            \ (medium×|nonces|) + rollup (medium×|nonces|) + FLAT anchor-refresh (medium+biggest, per LEG \
            \ here — delta-based) + settle-on-last-drain (book + checkpoint, anchor already done in Phase A) \
            \ only for beneficiaries whose UserUnn hits 0 (per-whole-nonce decrement). NO score-delta."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (nonces-array:[[integer]] (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "nonces" l)) legs))
                (amounts-array:[[integer]]
                    (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg})
                            (map (lambda (q:decimal) (floor q)) (at "amounts" l))) legs))
                (unique-benefs:[string]
                    (UC_VacateUniqueBeneficiaries
                        (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "beneficiary-id" l)) legs)))
                (checkpoint:decimal (RPS.URC_TierFixed (RPS.URC_CheckpointStakeRpsIgnis)))
            )
            (fold (+) 0.0
                [ (RPS.URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator               ;; bulk DPDC-T transfer
                      (DPDC-T.URCi_BulkTransferCumulator collectable-id son AQP-POOL.AQP|SC_NAME
                          (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "owner-id" l)) legs)
                          nonces-array amounts-array)))
                  (* (* 2.0 (RPS.URC_TierMedium)) (dec (length (fold (+) [] nonces-array))))    ;; per-leg tracker + rollup
                  (* (+ (RPS.URC_TierMedium) (RPS.URC_TierBiggest)) (dec (length legs)))    ;; per-leg flat anchor refresh
                  (fold (+) 0.0
                      (map
                          (lambda (benef:string)
                              (if (= (- (AQP-POOL.UR_AQP|UserUnn pool-id benef)
                                        (fold (+) 0 (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (length (at "nonces" l)))
                                                         (filter (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (= (at "beneficiary-id" l) benef)) legs))))
                                     0)
                                  (+ (RPS.URC_TierFixed (RPS.URC_BookStakeUnclaimedIgnis
                                        (at "distinct-fvts" (RPS.URHC_BuildStakeSettleBundle pool-id benef))))
                                     checkpoint)
                                  0.0))
                          unique-benefs))
                ])
        )
    )
    (defun URCi_FullVacate:decimal
        (pool-id:string
         tf-lanes:[object{AcquisitionSchemasV1.VCT|VacateTfLane}]
         of-lanes:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}]
         coll-lanes:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}]
         coll-son:bool)
        @doc "Variant-A shared cost estimator for CC_FullVacate, fed the same dirty-read lane plan the \
            \ exec's PHASE-1 scan produces. CC_FullVacate = Σ over lanes of the per-asset vacate recipe. \
            \ The auto MaybeFinalizeVacate write's cumulator is discarded by the exec, so it is NOT part \
            \ of this total. Reuses the three per-batch vacate readers."
        (fold (+) 0.0
            [ (fold (+) 0.0
                  (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateTfLane})
                          (URCi_BatchVacateTrueFungible pool-id (at "asset-id" l) (at "legs" l))) tf-lanes))
              (fold (+) 0.0
                  (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLane})
                          (URCi_BatchVacateOrtoFungible pool-id (at "asset-id" l) (at "legs" l))) of-lanes))
              (fold (+) 0.0
                  (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLane})
                          (URCi_BatchVacateCollectables pool-id (at "asset-id" l) coll-son (at "legs" l))) coll-lanes))
            ])
    )
    ;; [UR]  read
    (defun URC_TfOwnerArraysGasOk:bool
        (owner-ids:[string] beneficiary-ids:[string] amounts:[decimal])
        @doc "TF chunk gas check (vacate-v2 Phase 2, beneficiary-aware): shape valid AND the estimated cost \
            \ unique-beneficiaries × VACATE-GAS-PER-BEN + legs × VACATE-GAS-PER-POS is within VACATE-GAS-BUDGET. \
            \ The settle is per-beneficiary and dominates, so concentrated batches (few beneficiaries, many legs) \
            \ fit ~159 vs the old flat 24; spread (1 leg per beneficiary) stays ~19. Applies to both v1 vacate \
            \ and v2 drain (shared cap)."
        (let
            (
                (l:integer (length owner-ids))
                (bens:integer (length (distinct beneficiary-ids)))
            )
            (fold
                (and)
                true
                [
                    (> l 0)
                    (= l (length beneficiary-ids))
                    (= l (length amounts))
                    (<= (+ (* bens VACATE-GAS-PER-BEN) (* l VACATE-GAS-PER-POS)) VACATE-GAS-BUDGET)
                ]
            )
        )
    )
    (defun URC_BatchOwnerArraysGasOk:bool
        (owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] gas-max:integer)
        @doc "OF/DPSF/DPNF chunk gas (vacate-v2 Phase 2, beneficiary-aware): shape valid AND unique-beneficiaries \
            \ × VACATE-GAS-PER-BEN + total-nonces × VACATE-GAS-PER-POS within VACATE-GAS-BUDGET. The legacy \
            \ gas-max param is retained for call-site stability but no longer used (the settle-per-beneficiary + \
            \ marginal-per-nonce model replaces the flat per-kind cap). Concentrated batches fit ~159 nonces vs \
            \ the old flat ~30; spread stays ~19. Applies to both v1 vacate and v2 drain."
        (let
            (
                (l:integer (length owner-ids))
                (nonce-total:integer (UC_BatchNonceTotal nonces-array))
                (bens:integer (length (distinct beneficiary-ids)))
            )
            (fold
                (and)
                true
                [
                    (> l 0)
                    (> nonce-total 0)
                    (= l (length beneficiary-ids))
                    (= l (length nonces-array))
                    (<= (+ (* bens VACATE-GAS-PER-BEN) (* nonce-total VACATE-GAS-PER-POS)) VACATE-GAS-BUDGET)
                ]
            )
        )
    )
    (defun URC_VacateKindAssetOk:bool
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "Pool/asset admits the given vacate-kind: dispatches per kind — TF (pool class + dptf match), \
            \ OF (dpof match), DPSF/DPNF (collectable pool class + asset match); unknown kind returns false."
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
        @doc "True when every amount across the matrix is 0 — the OF sentinel (OF vacate carries no per-nonce amount)."
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
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;; VACATE — PHASE 1: SCAN. One URH_ per asset family builds the pool's legs, grouped by asset-lane
    ;; ({asset-id, legs}). ALL on-chain scanning lives here; the XI_*PoolLegs consumers do the writes with
    ;; ZERO reads. This clean scan/consume split is what the parallel batch functions reuse (UI dirty-reads
    ;; these same scanners off-chain to build slices, then feeds one XI_*FromLegs consumer per tx).
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;; PHASE-1 lane-id DERIVATION (URC_): each returns the pool's vacate-lane ids DERIVED from the single pool
    ;; asset-id (a table field) — no table scans. Variant tokens (F| frozen / Z| sleeping / H| hibernating) are
    ;; added ONLY when they exist (their DPTF link is non-BAR); a variant that exists but was never staked into
    ;; this pool is still safe — its lane's legs read empty and the consumer no-ops it.
    (defun URC_VacatePoolTfIds:[string] (pool-id:string)
        @doc "The pool's DPTF vacate-lane ids: the native asset-id (always) + its F| frozen counterpart WHEN it \
            \ exists (DPTF::UR_Frozen → BAR if never frozen → dropped). Same existence-filter idea as the OF variant."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (asset-id:string (ref-AQP::UR_AQP|PoolAssetId pool-id))
            )
            (+
                [asset-id]
                (filter
                    (lambda (fid:string) (!= fid BAR))
                    [(ref-DPTF::UR_Frozen asset-id)]
                )
            )
        )
    )
    (defun URC_VacatePoolOfIds:[string] (pool-id:string)
        @doc "The pool's DPOF vacate-lane ids, matching the 3 OF-bearing aqp-classes exactly \
            \ (URC_StakeOrtoFungibleDpofMatchesPool): class 2 → the native ortofungible (the asset-id; special \
            \ Z|/H| are NOT accepted); class 0 → ONLY the sleeping (Z|) LP satellite; class 1 → the sleeping (Z|) \
            \ AND hibernation (H|) DPTF satellites. Satellites read via DPTF::UR_Sleeping / UR_Hibernation on the \
            \ DPTF asset-id (class 0/1 asset-id is a DPTF); BAR (not linked) dropped."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (c:integer (ref-AQP::UR_AQP|PoolAqpClass pool-id))
                (asset-id:string (ref-AQP::UR_AQP|PoolAssetId pool-id))
            )
            (if (= c 2)
                [asset-id]
                (filter
                    (lambda (sat-id:string) (!= sat-id BAR))
                    (if (= c 0)
                        [(ref-DPTF::UR_Sleeping asset-id)]
                        [(ref-DPTF::UR_Sleeping asset-id) (ref-DPTF::UR_Hibernation asset-id)]
                    )
                )
            )
        )
    )
    (defun URC_VacatePoolCollectableIds:[string] (pool-id:string)
        @doc "The pool's collectable vacate-lane id: the single collection = the pool asset-id."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            [(ref-AQP::UR_AQP|PoolAssetId pool-id)]
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
        @doc "Derive whole-nonce decimal amounts from pool tracker for FVT vacate owner-row unwind. \
            \ Empty in, empty out."
        ;;EMPTY-INPUT GUARD (2026-09-13). Same descending-pair trap as its three siblings above:
        ;;`(enumerate 0 -1)` is `[0, -1]`, not the empty list, so an empty owner batch faulted on
        ;;`(at 0 [])` instead of returning no rows. The index zips three parallel arrays here, so a
        ;;guard is the repair rather than mapping over one of them.
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (if (= (length owner-ids) 0)
                []
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
    )
    (defun UR_VacateInProgress:bool (pool-id:string)
        (at "vacate-in-progress" (UR_VacateSessionFields pool-id))
    )
    (defun UR_VacateSessionFields:object
        (pool-id:string)
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (ref-AQP::UR_AQP|PoolVacateSession pool-id)
        )
    )
    (defun URC_VacateOrtoLegBeneficiaryOk:bool
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonces:[integer])
        @doc "Vacate: each DPOF nonce tracker row beneficiary-id must equal the supplied beneficiary-id. \
            \ TAUTOLOGY -- the ortofungible twin of URC_VacateCollectableLegBeneficiaryOk; see its note."
        ;;TAUTOLOGY, for exactly the reason given on `URC_VacateCollectableLegBeneficiaryOk` below:
        ;;<beneficiary-id> is a COMPONENT OF THE LOOKUP KEY passed to
        ;;`UR_AQP|DPOFTrackerBeneficiaryId`, so the value compared against it is always itself -- the
        ;;stored column on a live row, the echoed key on an absent one (`with-default-read` whose
        ;;default object is built from the key). `(= row-ben beneficiary-id)` cannot be false.
        ;;
        ;;The binding it describes is enforced one conjunct over, by
        ;;`URC_VacateOrtoNoncesSufficient` / `URC_VacateOrtoRollupSufficient`: a wrong beneficiary
        ;;addresses a different, absent tracker row whose balance is zero, so the amount check rejects
        ;;it. Pinned in REPL/modules/AQP.repl <<AQP-F15>>.
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
    (defun URC_VacateCollectableLegBeneficiaryOk:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer])
        @doc "Vacate: each nonce tracker row beneficiary-id must equal the supplied beneficiary-id. \
            \ TAUTOLOGY -- see the note below; the real binding is enforced by the balance checks."
        ;;TAUTOLOGY, NOT A LIVE CHECK (established by execution 2026-09-13). <beneficiary-id> is a
        ;;COMPONENT OF THE LOOKUP KEY: `UR_AQP|DPSFTrackerBeneficiaryId pool collectable owner
        ;;BENEFICIARY nonce`. So the value compared against it can only ever be itself --
        ;;  * row present -> the stored column IS the key component it was looked up by;
        ;;  * row ABSENT  -> the reader is a `with-default-read` whose default object is built FROM
        ;;                   the key, so it echoes <beneficiary-id> straight back.
        ;;Either way `(= row-ben beneficiary-id)` holds, and this function cannot return false.
        ;;Confirmed live: passing a beneficiary the row was never written under still returns true.
        ;;
        ;;THE BINDING IT DESCRIBES IS STILL ENFORCED, just not here. A leg naming the wrong
        ;;beneficiary addresses a DIFFERENT (and absent) tracker row, whose balance defaults to zero
        ;;-- so `URC_VacateCollectableNoncesSufficient` and `URC_VacateCollectableRollupSufficient`
        ;;reject it on amount. Those two are the real protection and are pinned alongside this one in
        ;;REPL/modules/AQP.repl <<AQP-F15>>.
        ;;
        ;;Left in place rather than deleted: it is a harmless conjunct in a `fold (and)` and it
        ;;documents the intended invariant. It is recorded here so no future reader mistakes it for
        ;;the thing standing between a caller and someone else's rollup.
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
    (defun URC_VacateTfLegsOk:bool
        (pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
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
                        (lambda (ok:bool leg:object{AcquisitionSchemasV1.VCT|VacateTfLeg})
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
    (defun URC_PoolFullyVacated:bool (pool-id:string)
        @doc "#FP1 pool-empty oracle. AMOUNT pools (class 0/1, nns = -1): every employed score has nzs-count = 0 — \
            \ amount stakes always score, so nzs is exact. NONCE pools (class 2/3/4): pool nns = 0 — the occupancy \
            \ counter of staked nonce positions, which counts GHOST nonces (0-score assets) that nzs would miss, \
            \ so a vacate can't finalize while ghost stake remains. Bounded point reads, no scan. Gates finalize."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (nns:integer (ref-AQP::UR_AQP|PoolNns pool-id))
            )
            (if (!= nns -1)
                ;; nonce-based pool: occupancy oracle (ghost-safe)
                (= nns 0)
                ;; amount-based pool: nzs across the ≤7 employed scores
                (let
                    (
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
        )
    )
    ;; [URH] heavy-read
    (defun URHC_VacateTfOwnerRows:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}]
        (pool-id:string dptf-id:string)
        @doc "TF vacate owner rows from URH_VacateTfInventory."
        (at "legs" (URH_VacateTfInventory pool-id dptf-id))
    )
    (defun URHC_VacateNonceOwnerRowsRaw:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}]
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "Grouped nonce vacate owner rows from VCT inventory URD (unexpanded)."
        (let
            (
                (son:bool (UC_VacateKindSon vacate-kind))
            )
            (if (= vacate-kind VACATE-KIND-OF)
                (at "legs" (URH_VacateOfInventory pool-id asset-id))
                (at "legs" (URH_VacateCollectableInventory pool-id asset-id son))
            )
        )
    )
    (defun URHC_VacateNonceOwnerRows:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}]
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "Nonce vacate owner rows gas-expanded for slice/full vacate chunk limits."
        (UC_ExpandNonceOwnerRowsForGasMax
            (URHC_VacateNonceOwnerRowsRaw pool-id asset-id vacate-kind)
            (UC_GasMaxForKind vacate-kind)
        )
    )
    ;; PHASE-1 SCAN (URH_): identical shape — one `let` binding the NAMED id-list (from the URC_ above), then
    ;; `map` the per-kind lane-builder over it. No inline id construction, no scan.
    (defun URH_VacateTrueFungiblePoolLegs:[object{AcquisitionSchemasV1.VCT|VacateTfLane}] (pool-id:string)
        @doc "PHASE-1 — the pool's DPTF lanes as {asset-id, legs}: ids from URC_VacatePoolTfIds, legs from \
            \ URHC_VacateTfOwnerRows. An empty lane → the consumer no-ops it."
        (let
            (
                (dptf-ids:[string] (URC_VacatePoolTfIds pool-id))
            )
            (map
                (lambda (dptf-id:string)
                    (UDC_VacateTfLane
                        dptf-id
                        (URHC_VacateTfOwnerRows pool-id dptf-id)
                    )
                )
                dptf-ids
            )
        )
    )
    (defun URH_VacateOrtoFungiblePoolLegs:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}] (pool-id:string)
        @doc "PHASE-1 — the pool's DPOF lanes as {asset-id, legs}: ids from URC_VacatePoolOfIds, legs from \
            \ URHC_VacateNonceOwnerRowsRaw (kind OF)."
        (let
            (
                (dpof-ids:[string] (URC_VacatePoolOfIds pool-id))
            )
            (map
                (lambda (dpof-id:string)
                    (UDC_VacateNonceLane
                        dpof-id
                        (URHC_VacateNonceOwnerRowsRaw pool-id dpof-id VACATE-KIND-OF)
                    )
                )
                dpof-ids
            )
        )
    )
    (defun URH_VacateCollectablesPoolLegs:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}] (pool-id:string son:bool)
        @doc "PHASE-1 — the pool's DPSF (son=true) / DPNF (son=false) collection lane as [{asset-id, legs}]: id \
            \ from URC_VacatePoolCollectableIds, legs from URHC_VacateNonceOwnerRowsRaw (kind DPSF/DPNF)."
        (let
            (
                (collectable-ids:[string] (URC_VacatePoolCollectableIds pool-id))
                (vacate-kind:integer (if son VACATE-KIND-DPSF VACATE-KIND-DPNF))
            )
            (map
                (lambda (collectable-id:string)
                    (UDC_VacateNonceLane
                        collectable-id
                        (URHC_VacateNonceOwnerRowsRaw pool-id collectable-id vacate-kind)
                    )
                )
                collectable-ids
            )
        )
    )
    (defun URHC_BuildVacateSlicePlan:object
        (pool-id:string asset-id:string vacate-kind:integer slice-count:integer)
        @doc "Slice plan from live pool inventory (URDC read + UC partition)."
        (if (= vacate-kind VACATE-KIND-TF)
            (UC_BuildTfVacateSlicePlanFromOwnerRows
                pool-id
                asset-id
                slice-count
                (URHC_VacateTfOwnerRows pool-id asset-id)
            )
            (UC_BuildNonceVacateSlicePlanFromOwnerRows
                pool-id
                asset-id
                vacate-kind
                slice-count
                (URHC_VacateNonceOwnerRows pool-id asset-id vacate-kind)
            )
        )
    )
    (defun URHC_VacateOwnerCountForKind:integer
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "Owner-row count from live vacate inventory — UI preflight before Full/Legs."
        (let
            (
                ;;
                (son:bool (UC_VacateKindSon vacate-kind))
            )
            (if (= vacate-kind VACATE-KIND-TF)
                (at "leg-count" (URH_VacateTfInventory pool-id asset-id))
                (if (= vacate-kind VACATE-KIND-OF)
                    (at "leg-count" (URH_VacateOfInventory pool-id asset-id))
                    (at "leg-count" (URH_VacateCollectableInventory pool-id asset-id son))
                )
            )
        )
    )
    (defun URHC_VacateNonceTotalForKind:integer
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "Sum of nonces across all owner rows — gas unit for OF/DPSF/DPNF slice planning."
        (UC_OwnerRowNonceTotal (URHC_VacateNonceOwnerRowsRaw pool-id asset-id vacate-kind))
    )
    (defun URHC_VacateUnitCountForKind:integer
        (pool-id:string asset-id:string vacate-kind:integer)
        @doc "TF → owner count; OF/DPSF/DPNF → total nonce count (for UC_ComputeMinSliceCount)."
        (if (= vacate-kind VACATE-KIND-TF)
            (URHC_VacateOwnerCountForKind pool-id asset-id vacate-kind)
            (URHC_VacateNonceTotalForKind pool-id asset-id vacate-kind)
        )
    )
    (defun URH_VacateTfInventory:object (pool-id:string dptf-id:string)
        @doc "Live TF vacate inventory for <pool-id>/<dptf-id>: reads the active DPTF tracker rows and builds \
            \ per-owner TF legs. Being a live tracker read, a vacated leg zeroes its slot, so a re-read after a \
            \ partial vacate naturally returns the outstanding remains (the UI's 'construct remains' is implicit)."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (UDC_VacateTfInventory
                (map
                    (lambda (row:object)
                        (UDC_VacateTfLeg (at "owner-id" row) (at "beneficiary-id" row) (at "balance" row))
                    )
                    (ref-AQP::URH_AQP|ActiveDptfTrackerRows pool-id dptf-id)
                )
            )
        )
    )
    (defun URH_VacateOfNonceRows:[object{AcquisitionSchemasV1.VCT|VacateNonceRow}] (pool-id:string dpof-id:string)
        @doc "Live per-nonce OF vacate rows for <pool-id>/<dpof-id> from the active DPOF tracker."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (map
                (lambda (row:object)
                    (UDC_VacateNonceRow (at "owner-id" row) (at "beneficiary-id" row) (at "nonce" row) (at "balance" row))
                )
                (ref-AQP::URH_AQP|ActiveDpofTrackerRows pool-id dpof-id)
            )
        )
    )
    (defun URH_VacateOfInventory:object (pool-id:string dpof-id:string)
        @doc "Live OF vacate inventory: folds the per-nonce rows into per-owner nonce legs (legs + leg-count)."
        (UDC_VacateNonceLegInventory
            (fold
                (lambda (acc:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}] row:object{AcquisitionSchemasV1.VCT|VacateNonceRow})
                    (UC_MergeVacateNonceRowIntoLegs acc (at "owner-id" row) (at "beneficiary-id" row) (at "nonce" row) (at "balance" row))
                )
                []
                (URH_VacateOfNonceRows pool-id dpof-id)
            )
        )
    )
    (defun URH_VacateCollectableNonceRows:[object{AcquisitionSchemasV1.VCT|VacateNonceRow}]
        (pool-id:string collectable-id:string son:bool)
        @doc "Live per-nonce collectable vacate rows for <pool-id>/<collectable-id> (<son> selects the DPSF vs \
            \ DPNF active tracker)."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (map
                (lambda (row:object)
                    (UDC_VacateNonceRow (at "owner-id" row) (at "beneficiary-id" row) (at "nonce" row) (at "balance" row))
                )
                (if son
                    (ref-AQP::URH_AQP|ActiveDpsfTrackerRows pool-id collectable-id)
                    (ref-AQP::URH_AQP|ActiveDpnfTrackerRows pool-id collectable-id)
                )
            )
        )
    )
    (defun URH_VacateCollectableInventory:object
        (pool-id:string collectable-id:string son:bool)
        @doc "Live collectable vacate inventory: folds the per-nonce rows into per-owner nonce legs (legs + leg-count)."
        (UDC_VacateNonceLegInventory
            (fold
                (lambda (acc:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}] row:object{AcquisitionSchemasV1.VCT|VacateNonceRow})
                    (UC_MergeVacateCollectableRowIntoLegs acc (at "owner-id" row) (at "beneficiary-id" row) (at "nonce" row) (at "balance" row))
                )
                []
                (URH_VacateCollectableNonceRows pool-id collectable-id son)
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;; MEASURED (REPL/Kursan/AQP-scale-vacate.repl, TF drain, 50 distinct-beneficiary legs — the SPREAD case):
    ;; gas(n) = 24,620 + 54,290*n → ~36 legs fit 2M. Per-distinct-ben leg = 54,290 < the model's 79,000
    ;; (PER-BEN 75k + PER-POS 4k), so the 2-D model OVER-estimates → a safe, conservative backstop (it rejects
    ;; at ~25 spread vs the true ~36; PER-BEN 75k also covers the ~85k trait-rich settle a bare TF leg doesn't hit).
    ;; [CAP] pool-owner enforce predicate. MUST be a defun (not a defcap): every VCT|C>* vacate/abort
    ;; cap calls it BARE — `(CAP_VctVacatePoolOwner pool-id)` — as an inline enforce. A defcap bare-called
    ;; that way does NOT run its body, which silently no-opped the owner gate on the WHOLE vacate surface
    ;; (CC_FullVacate / XB_Vacate* / Cp_BatchVacate* / C_AbortVacate) — any non-owner could vacate or abort.
    ;; A defun runs the enforce, exactly like AQP-POOL::CAP_PoolOwner. Only the pool owner may vacate/abort.
    (defun CAP_VctVacatePoolOwner (pool-id:string)
        @doc "Vacate operations require tx sender ownership of the pool's canonical owner konto."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (ref-AQP::URC_AqpOwnerKonto pool-id))
        )
    )
    ;; [UEV] enforce
    (defun UEV_TrueFungibleStakeNotReserved (dptf-id:string)
        @doc "Enforce <dptf-id> is not a reserved (R|) token — reserved DPTFs cannot be vacated."
        (enforce (not (= (take 2 dptf-id) "R|")) "Reserved DPTF (R|) cannot be vacated")
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;; [XI]
    ;; Depth: C_* → XI_* (depth 0) → XI_1|* (depth 1) → XI_2|* (depth 2) → XI_3|* (depth 3).
    ;; Begin/finalize: XI_EnsureVacateBegun / XI_MaybeFinalizeVacate / XI_ClearVacateInProgress.
    ;; AQP pool writes: ref-AQP::XB_* / XE_SetVacateJobState directly (SECURE from master cap).
    ;; Table persistence: W_ layer only. XI_* call W_ directly with ;; SECURE: comments; no raw insert/update/write on VCT|T|*.
    ;; SECURE composed by master VCT|C>* cap or P|VCT|RECIPE (atomic vacate batch). No UEV_* in XI bodies.
    ;;
    ;;Protection: Class 1 — Innate protection offered by XE_SetFvtVacateFrozen
    (defun XI_SetPoolFvtsVacateFrozen:string (pool-id:string frozen:bool)
        @doc "Freeze (frozen=true at begin) / unfreeze (false at finalize) collect + inject on every FVT the \
            \ vacating pool's employed scores link to: walk URC_PoolActiveScoreIds → UR_SCR|ScoreFvtLink (BAR \
            \ dropped) → distinct FVTs → FVT::XE_SetFvtVacateFrozen. Bounded (≤7 scores). The FVTs are the pool's \
            \ own, so this never freezes another pool. Stake/unstake are frozen pool-side (PoolVacateInProgress)."
        ;; SECURE: granted by master vacate caps.
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                (fvt-ids:[string]
                    (distinct
                        (filter
                            (lambda (fid:string) (!= fid BAR))
                            (map
                                (lambda (score-id:string) (ref-SCR::UR_SCR|ScoreFvtLink score-id))
                                (ref-AQP::URC_PoolActiveScoreIds pool-id)
                            )
                        )
                    )
                )
            )
            (do
                (map
                    (lambda (fvt-id:string) (ref-FVT::XE_SetFvtVacateFrozen fvt-id frozen))
                    fvt-ids
                )
                "pool-fvts-freeze-set"
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_SetVacateJobState,
    ;;Protection:          XB_SetPoolStakeEnabled
    (defun XI_EnsureVacateBegun:string (pool-id:string)
        @doc "If vacate not in progress: set vacate-in-progress, disable pool stake (stake+unstake are then blocked \
            \ pool-side), AND freeze collect + inject on the pool's employed-score FVTs (XI_SetPoolFvtsVacateFrozen)."
        ;; SECURE: granted by master vacate caps.
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (if (UR_VacateInProgress pool-id)
                "already-begun"
                (do
                    (ref-AQP::XE_SetVacateJobState pool-id true)
                    (if (ref-AQP::UR_AQP|PoolStakeEnabled pool-id)
                        (ref-AQP::XB_SetPoolStakeEnabled pool-id false)
                        true
                    )
                    (XI_SetPoolFvtsVacateFrozen pool-id true)
                    "begun"
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_SetVacateJobState
    (defun XI_ClearVacateInProgress:string (pool-id:string)
        @doc "Abort/clear: clear vacate-in-progress AND unfreeze the pool's FVTs (collect+inject). Stake stays \
            \ disabled (ops re-enable via C_EnablePoolStake) — matches C_AbortVacate semantics."
        ;; SECURE: granted by VCT|C>ABORT-VACATE-POOL / finalize path.
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (ref-AQP::XE_SetVacateJobState pool-id false)
            (XI_SetPoolFvtsVacateFrozen pool-id false)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_SetVacateJobState,
    ;;Protection:          XB_SetPoolStakeEnabled
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
                (ref-AQP::XE_SetVacateJobState pool-id false)
                (ref-AQP::XB_SetPoolStakeEnabled pool-id true)
                (XI_SetPoolFvtsVacateFrozen pool-id false)
                "finalized"
            )
            (if finalize "finalize-deferred-inventory-remains" "continued")
        )
    )
    ;; Legs orchestration: XI_EnsureVacateBegun / XI_MaybeFinalizeVacate / XI_ClearVacateInProgress.
    ;;Protection: Class 1 — Innate protection offered by XE_BankScorePendingRewards
    (defun XI_3|RpsVacatePreZero:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object)
        @doc "TF vacate RPS prelude: bank pending at OLD deb per score plan. Skips ghost-TVL sync and row ensure."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (settle-plans:[object] (at "settle-plans" settle-bundle))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (map
                (lambda (plan:object)
                    (RPS.XE_BankScorePendingRewards beneficiary-id pool-id plan)
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
    ;;Protection: Class 1 — Innate protection offered by XE_BookStakeUnclaimedCounts,
    ;;Protection:          XE_CheckpointStakeRps
    (defun XI_2|SettleBeneficiaryRewardsOnly:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string beneficiary-id:string)
        @doc "Vacate-v2 §4 settle-on-last-drain: preserve ONE beneficiary's pending rewards into unclaimed \
            \ WITHOUT touching their score. The asset-agnostic reward triple — Bank (XI_3|RpsVacatePreZero, \
            \ settle pending at live deb) -> Book (XE_BookStakeUnclaimedCounts, unclaimed-count hygiene) -> \
            \ Checkpoint (XE_CheckpointStakeRps, advance RPS) — identical to the v1 beneficiary unwind's reward \
            \ steps but WITHOUT XE_ApplyStakeDelta and WITHOUT the rollup/anchor legs (those are asset-specific \
            \ and handled per-position in the drain). MUST run BEFORE the fast-vacate generation bump: Bank reads \
            \ the beneficiary's LIVE per-user deb, so a stale/zeroed score would bank 0. Same depth-2 no-self-cap \
            \ convention as XI_2|Vacate*BeneficiaryUnwind — the XE_ forward calls each enforce their own IMC."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (settle-bundle:object (RPS.URHC_BuildStakeSettleBundle pool-id beneficiary-id))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (XI_3|RpsVacatePreZero beneficiary-id pool-id settle-bundle)
                    (RPS.XE_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
                    (RPS.XE_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
                ]
                []
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_TrueFungibleBeneficiaryRollup,
    ;;Protection:          XE_RefreshTrueFungibleStakeAnchors,
    ;;Protection:          XE_ApplyTrueFungibleStakeDelta, XE_BookStakeUnclaimedCounts,
    ;;Protection:          XE_CheckpointStakeRps
    (defun XI_2|VacateTrueFungibleBeneficiaryUnwind:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "TF vacate per beneficiary: rollup → RPS bank → ANK → SCORE unstake → RPS book+checkpoint."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (settle-bundle:object
                    (RPS.URHC_BuildStakeSettleBundle pool-id beneficiary-id)
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
                    (RPS.XE_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
                    (RPS.XE_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
                ]
                []
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_ZeroDptfTrackerSlot
    (defun XI_1|VacateTrueFungibleUnwindFromLegs:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "TF vacate phases 2–4: write-only tracker zero per leg; beneficiary unwind deduped by unique beneficiary."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (unique-beneficiaries:[string] (UC_VacateUniqueBeneficiariesFromLegs legs))
                (tracker-ocs:[object{IgnisCollectorV3.OutputCumulator}]
                    (map
                        (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateTfLeg})
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
                (score-ocs:[object{IgnisCollectorV3.OutputCumulator}]
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
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_VacateTrueFungibleFromLegs:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "TF vacate CONSUMER (per DPTF asset) — no scan. Phases 2–4 unwind from the pre-built leg list, then \
            \ phase 0 bulk TFT transfer last. Empty legs → no-op (the batch core is not empty-safe: a zero-leg \
            \ TF vacate would hit a 0.0 debit and abort)."
        (require-capability (P|VCT|RECIPE))
        (if (= (length legs) 0)
            (UC_EmptyOc)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (unwind-oc:object{IgnisCollectorV3.OutputCumulator}
                        (XI_1|VacateTrueFungibleUnwindFromLegs pool-id dptf-id legs)
                    )
                    (bulk-arr:object (UC_VacateTfLegsToTftBulkArrays legs))
                    (bulk-oc:object{IgnisCollectorV3.OutputCumulator}
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
    )
    ;;Protection: Class 1 — Innate protection offered by XE_ZeroDptfTrackerSlot,
    ;;Protection:          XE_TrueFungibleBeneficiaryRollup,
    ;;Protection:          XE_RefreshTrueFungibleStakeAnchors
    (defun XI_1|DrainTrueFungibleFromLegs:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Vacate-v2 TF DRAIN phases 2-4 (no score delta). Per leg: zero the tracker row (nns--/unn--) AND \
            \ decrement the cross-pool rollup by the leg amount (amount-linear; owner-id unused in the bump). \
            \ THEN — unn is now decremented — for each unique beneficiary whose unn hit 0 (their LAST position \
            \ drained) refresh anchors + settle their rewards ONCE. Beneficiaries still holding positions are \
            \ left untouched (settled on their own last drain). The per-user score is NEVER decremented here: it \
            \ stays live so this-round settles bank the correct deb, then the finalize generation bump zeroes it \
            \ lazily and the nuke bulk-zeroes the aggregate. Nested lets force the tracker side effects to land \
            \ before the unn==0 gate is read."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                (unique-beneficiaries:[string] (UC_VacateUniqueBeneficiariesFromLegs legs))
            )
            ;; Phase A — per-leg tracker-zero (nns--/unn--) + cross-pool rollup decrement (side effects first)
            (let
                (
                    (tracker-ocs:[object{IgnisCollectorV3.OutputCumulator}]
                        (map
                            (lambda (leg:object{AcquisitionSchemasV1.VCT|VacateTfLeg})
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                    [
                                        (ref-AQP::XE_ZeroDptfTrackerSlot
                                            pool-id (at "owner-id" leg) (at "beneficiary-id" leg) dptf-id)
                                        (ref-AQP::XE_TrueFungibleBeneficiaryRollup
                                            pool-id (at "owner-id" leg) (at "beneficiary-id" leg)
                                            dptf-id (at "balance" leg) false)
                                    ]
                                    []
                                )
                            )
                            legs
                        )
                    )
                )
                ;; Phase B — unn now reflects the drain: settle ONLY beneficiaries fully drained this round
                (let
                    (
                        (settle-ocs:[object{IgnisCollectorV3.OutputCumulator}]
                            (map
                                (lambda (beneficiary-id:string)
                                    (if (= (ref-AQP::UR_AQP|UserUnn pool-id beneficiary-id) 0)
                                        ;; Bank must read PRE-anchor-refresh deb (v1 order: Bank(2) before ANK(3)),
                                        ;; so settle FIRST, then refresh anchors from the decremented rollup.
                                        (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                            [
                                                (XI_2|SettleBeneficiaryRewardsOnly pool-id beneficiary-id)
                                                (ref-FVT::XE_RefreshTrueFungibleStakeAnchors beneficiary-id dptf-id)
                                            ]
                                            []
                                        )
                                        (UC_EmptyOc)
                                    )
                                )
                                unique-beneficiaries
                            )
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators (+ tracker-ocs settle-ocs) [])
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_DrainTrueFungibleFromLegs:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dptf-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateTfLeg}])
        @doc "Vacate-v2 TF DRAIN CONSUMER (per DPTF asset) — no scan. Phases 2-4 drain-unwind from the pre-built \
            \ leg list, then phase 0 bulk TFT transfer back to owners last. Empty legs -> no-op. NO finalize: the \
            \ drain leaves the pool frozen; C_FinalizeVacate (nuke) re-enables it once nns==0. require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (if (= (length legs) 0)
            (UC_EmptyOc)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (unwind-oc:object{IgnisCollectorV3.OutputCumulator}
                        (XI_1|DrainTrueFungibleFromLegs pool-id dptf-id legs)
                    )
                    (bulk-arr:object (UC_VacateTfLegsToTftBulkArrays legs))
                    (bulk-oc:object{IgnisCollectorV3.OutputCumulator}
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
    )
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_VacateOrtoFungibleFromLegs:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dpof-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "OF vacate CONSUMER (per DPOF asset) — no scan. Unpack the pre-built nonce legs (owner/beneficiary/ \
            \ nonces + the real per-nonce decimal amounts the PHASE-1 URD scan already read off the tracker) into \
            \ the batch arrays and run bulk custody-return + unwind (XI_VacateOrtoFungibleBatch). Empty legs → \
            \ no-op (the batch core is not empty-safe: empty owner-ids → enumerate 0 -1 → out-of-bounds). \
            \ require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (if (= (length legs) 0)
            (UC_EmptyOc)
            (XI_VacateOrtoFungibleBatch pool-id dpof-id
                (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "owner-id" l)) legs)
                (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "beneficiary-id" l)) legs)
                (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "nonces" l)) legs)
                (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "amounts" l)) legs)
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_VacateCollectablesFromLegs:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string collectable-id:string son:bool legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "DPSF/DPNF vacate CONSUMER (per collection, son=DPSF/DPNF) — no scan. Unpack the pre-built nonce legs \
            \ into the batch arrays (collectable units are whole → floor the decimal amounts) and run bulk \
            \ custody-return + unwind (XI_VacateCollectableBatch). Empty legs → no-op. require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (if (= (length legs) 0)
            (UC_EmptyOc)
            (XI_VacateCollectableBatch pool-id collectable-id son
                (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "owner-id" l)) legs)
                (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "beneficiary-id" l)) legs)
                (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (at "nonces" l)) legs)
                (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateNonceLeg}) (map (lambda (q:decimal) (floor q)) (at "amounts" l))) legs)
            )
        )
    )
    ;; ── PHASE-2 POOL consumers: walk the PHASE-1 lanes → per-asset FromLegs consumer. No reads, no scans. ──
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_VacateTrueFungiblePoolLegs:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string lanes:[object{AcquisitionSchemasV1.VCT|VacateTfLane}])
        @doc "TF-lane POOL consumer — no scan. Run XI_VacateTrueFungibleFromLegs on every pre-scanned DPTF lane \
            \ (native / F| frozen) and concatenate. Empty lane list → empty Oc. require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if (= (length lanes) 0)
                (UC_EmptyOc)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    (map
                        (lambda (lane:object{AcquisitionSchemasV1.VCT|VacateTfLane})
                            (XI_VacateTrueFungibleFromLegs pool-id (at "asset-id" lane) (at "legs" lane)))
                        lanes)
                    [])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_VacateOrtoFungiblePoolLegs:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string lanes:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}])
        @doc "OF-lane POOL consumer — no scan. Run XI_VacateOrtoFungibleFromLegs on every pre-scanned DPOF lane \
            \ (Z|/H| satellite or class-2 standalone) and concatenate. Empty → empty Oc. require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if (= (length lanes) 0)
                (UC_EmptyOc)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    (map
                        (lambda (lane:object{AcquisitionSchemasV1.VCT|VacateNonceLane})
                            (XI_VacateOrtoFungibleFromLegs pool-id (at "asset-id" lane) (at "legs" lane)))
                        lanes)
                    [])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_VacateCollectablesPoolLegs:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string son:bool lanes:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}])
        @doc "Collectable-lane POOL consumer — no scan. Run XI_VacateCollectablesFromLegs (son) on every \
            \ pre-scanned DPSF/DPNF lane and concatenate. Empty → empty Oc. require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if (= (length lanes) 0)
                (UC_EmptyOc)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    (map
                        (lambda (lane:object{AcquisitionSchemasV1.VCT|VacateNonceLane})
                            (XI_VacateCollectablesFromLegs pool-id (at "asset-id" lane) son (at "legs" lane)))
                        lanes)
                    [])
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_ApplyOrtoFungibleStakeDelta,
    ;;Protection:          XE_BookStakeUnclaimedCounts, XE_CheckpointStakeRps
    (defun XI_2|VacateOrtoFungibleScoreUnwind:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
        )
        @doc "Level-2 per-beneficiary OF score unwind: settle at the pre-zero RPS, apply the negative OF stake \
            \ delta across the pool's active scores, book unclaimed counts, and re-checkpoint RPS. Returns the \
            \ concatenated IGNIS cumulator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (settle-bundle:object
                    (RPS.URHC_BuildStakeSettleBundle pool-id beneficiary-id)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (XI_3|RpsVacatePreZero beneficiary-id pool-id settle-bundle)
                    (ref-SCR::XE_ApplyOrtoFungibleStakeDelta
                        pool-id beneficiary-id dpof-id nonces nonce-amounts false
                        (ref-AQP::URC_PoolActiveScoreIds pool-id)
                    )
                    (RPS.XE_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
                    (RPS.XE_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
                ]
                []
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_RefreshCollectableStakeAnchors,
    ;;Protection:          XE_ApplyCollectableStakeDelta, XE_BookStakeUnclaimedCounts,
    ;;Protection:          XE_CheckpointStakeRps
    (defun XI_2|VacateCollectableScoreUnwind:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Level-2 per-beneficiary collectable (SF/NF) score unwind: settle at the pre-zero RPS, refresh the \
            \ stake anchors, apply the negative collectable stake delta across active scores, book unclaimed \
            \ counts, and re-checkpoint RPS. Returns the concatenated IGNIS cumulator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (settle-bundle:object
                    (RPS.URHC_BuildStakeSettleBundle pool-id beneficiary-id)
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
                    (RPS.XE_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
                    (RPS.XE_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
                ]
                []
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_OrtoFungiblePoolTracker
    (defun XI_1|VacateOrtoFungibleUnwindBatch:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
        )
        @doc "Level-1 OF unwind batch: drain each owner row's DPOF pool tracker + beneficiary rollup, then run \
            \ the level-2 score unwind once per unique beneficiary. Concatenates every leg's IGNIS cumulator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (L:integer (length owner-ids))
                (unique-beneficiaries:[string] (UC_VacateUniqueBeneficiaries beneficiary-ids))
                (tracker-ocs:[object{IgnisCollectorV3.OutputCumulator}]
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
                (score-ocs:[object{IgnisCollectorV3.OutputCumulator}]
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
    ;;Protection: Class 1 — Innate protection offered by XE_CollectablePoolTracker,
    ;;Protection:          XE_CollectableBeneficiaryRollup
    (defun XI_1|VacateCollectableUnwindBatch:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            collectable-id:string
            son:bool
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Level-1 collectable (SF/NF) unwind batch: drain each owner row's collectable pool tracker + \
            \ beneficiary rollup, then run the level-2 score unwind once per unique beneficiary. Concatenates \
            \ every leg's IGNIS cumulator."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (L:integer (length owner-ids))
                (unique-beneficiaries:[string] (UC_VacateUniqueBeneficiaries beneficiary-ids))
                (tracker-ocs:[object{IgnisCollectorV3.OutputCumulator}]
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
                (score-ocs:[object{IgnisCollectorV3.OutputCumulator}]
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
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_VacateOrtoFungibleBatch:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
        )
        @doc "Top-level OF vacate batch write (require P|VCT|RECIPE): bulk-transfers each owner's DPOF nonces \
            \ back out of the pool SC, then runs the level-1 unwind batch (tracker/rollup drain + per-beneficiary \
            \ score unwind). Concatenates the transfer + unwind IGNIS cumulators."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (bulk-oc:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::C_BulkTransfer dpof-id nonces-array AQP|SC_NAME owner-ids true)
                )
                (unwind-oc:object{IgnisCollectorV3.OutputCumulator}
                    (XI_1|VacateOrtoFungibleUnwindBatch
                        pool-id dpof-id owner-ids beneficiary-ids nonces-array nonce-amounts-array
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [bulk-oc unwind-oc] [])
        )
    )
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_VacateCollectableBatch:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            collectable-id:string
            son:bool
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Top-level collectable (SF/NF) vacate batch write (require P|VCT|RECIPE): bulk-transfers each \
            \ owner's nonces/amounts back out of the pool SC, then runs the level-1 unwind batch. Concatenates \
            \ the transfer + unwind IGNIS cumulators."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                ;;
                (bulk-oc:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPDC-T::C_BulkTransfer
                        collectable-id son nonces-array amounts-array AQP|SC_NAME owner-ids true
                    )
                )
                (unwind-oc:object{IgnisCollectorV3.OutputCumulator}
                    (XI_1|VacateCollectableUnwindBatch
                        pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [bulk-oc unwind-oc] [])
        )
    )
    ;; ══ Vacate-v2 FAST-DRAIN batch internals (OF + collectable) — score-free mirrors of the vacate batches ══
    ;;Protection: Class 1 — Innate protection offered by XE_OrtoFungiblePoolTracker
    (defun XI_1|DrainOrtoFungibleUnwindBatch:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
        )
        @doc "Vacate-v2 OF DRAIN unwind (no score delta). Phase A per leg: XE_OrtoFungiblePoolTracker(dir=false) \
            \ clears the tracker rows (nns--/unn-- per whole nonce). Phase B — unn now reflects the drain: settle \
            \ ONCE each beneficiary whose unn hit 0 (XI_2|SettleBeneficiaryRewardsOnly). OF has NO rollup and NO \
            \ anchor refresh. NO ApplyStakeDelta — the per-user score stays live for the finalize generation bump. \
            \ Nested lets force the tracker side effects before the unn==0 gate is read."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (L:integer (length owner-ids))
                (unique-beneficiaries:[string] (UC_VacateUniqueBeneficiaries beneficiary-ids))
            )
            (let
                (
                    (tracker-ocs:[object{IgnisCollectorV3.OutputCumulator}]
                        (map
                            (lambda (idx:integer)
                                (ref-AQP::XE_OrtoFungiblePoolTracker
                                    pool-id (at idx owner-ids) (at idx beneficiary-ids)
                                    dpof-id (at idx nonces-array) (at idx nonce-amounts-array) false)
                            )
                            (enumerate 0 (- L 1))
                        )
                    )
                )
                (let
                    (
                        (settle-ocs:[object{IgnisCollectorV3.OutputCumulator}]
                            (map
                                (lambda (beneficiary-id:string)
                                    (if (= (ref-AQP::UR_AQP|UserUnn pool-id beneficiary-id) 0)
                                        (XI_2|SettleBeneficiaryRewardsOnly pool-id beneficiary-id)
                                        (UC_EmptyOc)
                                    )
                                )
                                unique-beneficiaries
                            )
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators (+ tracker-ocs settle-ocs) [])
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_DrainOrtoFungibleBatch:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            nonce-amounts-array:[[decimal]]
        )
        @doc "Vacate-v2 OF DRAIN batch (require P|VCT|RECIPE): bulk-transfer each owner's DPOF nonces back out of \
            \ the pool SC, then the drain unwind (tracker-clear + settle-once). NO score delta, NO finalize."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (bulk-oc:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::C_BulkTransfer dpof-id nonces-array AQP|SC_NAME owner-ids true)
                )
                (unwind-oc:object{IgnisCollectorV3.OutputCumulator}
                    (XI_1|DrainOrtoFungibleUnwindBatch
                        pool-id dpof-id owner-ids beneficiary-ids nonces-array nonce-amounts-array)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [bulk-oc unwind-oc] [])
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_CollectablePoolTracker,
    ;;Protection:          XE_CollectableBeneficiaryRollup,
    ;;Protection:          XE_RefreshCollectableStakeAnchors
    (defun XI_1|DrainCollectableUnwindBatch:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            collectable-id:string
            son:bool
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Vacate-v2 collectable (SF/NF) DRAIN unwind (no score delta). Phase A per leg: clear the tracker \
            \ (XE_CollectablePoolTracker dir=false -> nns--/unn--) + decrement the beneficiary rollup + refresh \
            \ anchors (per-nonce, delta-based, so per leg). Phase B — unn now reflects the drain: settle ONCE each \
            \ beneficiary whose unn hit 0. NO ApplyStakeDelta. The anchor refresh does NOT write the per-user deb \
            \ (verified), so running it in phase A before the last-drain Bank is safe. Nested lets order the \
            \ tracker side effects before the unn==0 gate."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                (L:integer (length owner-ids))
                (unique-beneficiaries:[string] (UC_VacateUniqueBeneficiaries beneficiary-ids))
            )
            (let
                (
                    (tracker-ocs:[object{IgnisCollectorV3.OutputCumulator}]
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
                                                pool-id (at idx owner-ids) (at idx beneficiary-ids)
                                                collectable-id son ns ams false)
                                            (ref-AQP::XE_CollectableBeneficiaryRollup
                                                pool-id (at idx owner-ids) (at idx beneficiary-ids)
                                                collectable-id son ns ams false)
                                            (ref-FVT::XE_RefreshCollectableStakeAnchors
                                                (at idx beneficiary-ids) collectable-id son ns ams false)
                                        ]
                                        []
                                    )
                                )
                            )
                            (enumerate 0 (- L 1))
                        )
                    )
                )
                (let
                    (
                        (settle-ocs:[object{IgnisCollectorV3.OutputCumulator}]
                            (map
                                (lambda (beneficiary-id:string)
                                    (if (= (ref-AQP::UR_AQP|UserUnn pool-id beneficiary-id) 0)
                                        (XI_2|SettleBeneficiaryRewardsOnly pool-id beneficiary-id)
                                        (UC_EmptyOc)
                                    )
                                )
                                unique-beneficiaries
                            )
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators (+ tracker-ocs settle-ocs) [])
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|VCT|RECIPE
    (defun XI_DrainCollectableBatch:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            collectable-id:string
            son:bool
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Vacate-v2 collectable DRAIN batch (require P|VCT|RECIPE): bulk-transfer each owner's nonces/amounts \
            \ back out of the pool SC, then the drain unwind (tracker-clear + rollup + anchor refresh + settle- \
            \ once). NO score delta, NO finalize."
        (require-capability (P|VCT|RECIPE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                ;;
                (bulk-oc:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPDC-T::C_BulkTransfer
                        collectable-id son nonces-array amounts-array AQP|SC_NAME owner-ids true)
                )
                (unwind-oc:object{IgnisCollectorV3.OutputCumulator}
                    (XI_1|DrainCollectableUnwindBatch
                        pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [bulk-oc unwind-oc] [])
        )
    )
    ;; [XB]
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
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          VCT|C>VACATE
    (defun XB_VacateTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string)
        @doc "Vacate rehaul — external per-kind TF vacate for a whole pool (both internal + external, hence XB). \
            \ 2-phase: SCAN every live DPTF lane (URH_VacateTrueFungiblePoolLegs: native + F| frozen) → CONSUME \
            \ (XI_VacateTrueFungiblePoolLegs). The pool's DPOF satellites (Z|/H|) are vacated by XB_VacateOrtoFungible; \
            \ use CC_FullVacate to empty a whole pool of any class in one call."
        (P|UEV_IMC)
        (with-capability (VCT|C>VACATE pool-id)
            (XI_VacateTrueFungiblePoolLegs pool-id (URH_VacateTrueFungiblePoolLegs pool-id))
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          VCT|C>VACATE
    (defun XB_VacateOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dpof-id:string)
        @doc "Vacate rehaul — external per-kind OF vacate for ONE OF asset of a pool (both internal + external). \
            \ 2-phase: SCAN that asset's legs (URHC_VacateNonceOwnerRowsRaw) → CONSUME (XI_VacateOrtoFungibleFromLegs). \
            \ A class-1 pool has TF + ≥1 OF satellite; call per satellite, or use CC_FullVacate for the whole pool."
        (P|UEV_IMC)
        (with-capability (VCT|C>VACATE pool-id)
            (XI_VacateOrtoFungibleFromLegs pool-id dpof-id
                (URHC_VacateNonceOwnerRowsRaw pool-id dpof-id VACATE-KIND-OF))
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          VCT|C>VACATE
    (defun XB_VacateSemiFungible:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dpsf-id:string)
        @doc "Vacate rehaul — external per-kind DPSF (semi-fungible collection) vacate for ONE collectable of a \
            \ pool. 2-phase: SCAN (URHC_VacateNonceOwnerRowsRaw, DPSF) → CONSUME (XI_VacateCollectablesFromLegs, \
            \ son=true). Use CC_FullVacate to empty the whole pool in one call."
        (P|UEV_IMC)
        (with-capability (VCT|C>VACATE pool-id)
            (XI_VacateCollectablesFromLegs pool-id dpsf-id true
                (URHC_VacateNonceOwnerRowsRaw pool-id dpsf-id VACATE-KIND-DPSF))
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          VCT|C>VACATE
    (defun XB_VacateNonFungible:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string dpnf-id:string)
        @doc "Vacate rehaul — external per-kind DPNF (non-fungible collection) vacate for ONE collectable of a \
            \ pool. 2-phase: SCAN (URHC_VacateNonceOwnerRowsRaw, DPNF) → CONSUME (XI_VacateCollectablesFromLegs, \
            \ son=false). Use CC_FullVacate to empty the whole pool in one call."
        (P|UEV_IMC)
        (with-capability (VCT|C>VACATE pool-id)
            (XI_VacateCollectablesFromLegs pool-id dpnf-id false
                (URHC_VacateNonceOwnerRowsRaw pool-id dpnf-id VACATE-KIND-DPNF))
        )
    )
    ;;{5.7}  User [A/C]
    ;; [C]   client
    (defun CC_FullVacate:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string)
        @doc "HEAVY (R3 CC_) AGNOSTIC single-tx full vacate: input is JUST the pool-id. Clean 2-PHASE per aqp-class: \
            \ PHASE 1 URH_Vacate*PoolLegs SCANs the pool's legs (grouped by asset-lane); PHASE 2 XI_Vacate*PoolLegs \
            \ CONSUMEs them. TF-FAMILY (class 0 LP farm / class 1 DPTF family) is MULTI-LANE — up to native TF + F| \
            \ frozen TF + Z|/H| DPOF satellites (class 0 stakes a Z| sleeping-LP DPOF too, NOT TF-only) — so it runs \
            \ BOTH the TF pair AND the OF pair. class 2 → OF; class 3 → DPSF; class 4 → DPNF. Empty lanes no-op. \
            \ Owner-gated (VCT|C>VACATE)."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (c:integer (ref-AQP::UR_AQP|PoolAqpClass pool-id))
                (son:bool (= c 3))
            )
            ;; aqp-class validity is enforced inside VCT|C>VACATE (all validation lives in the cap).
            (with-capability (VCT|C>VACATE pool-id)
                (if (or (= c 0) (= c 1))
                    ;; TF-family: scan+consume the DPTF lanes AND the DPOF satellite lanes
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (XI_VacateTrueFungiblePoolLegs pool-id (URH_VacateTrueFungiblePoolLegs pool-id))
                            (XI_VacateOrtoFungiblePoolLegs pool-id (URH_VacateOrtoFungiblePoolLegs pool-id))
                        ]
                        [])
                    (if (= c 2)
                        (XI_VacateOrtoFungiblePoolLegs pool-id (URH_VacateOrtoFungiblePoolLegs pool-id))
                        (XI_VacateCollectablesPoolLegs pool-id son (URH_VacateCollectablesPoolLegs pool-id son))
                    )
                )
            )
        )
    )
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;; PHASE 2 — Cp_BatchVacate<Kind>: one tx of a UI-sliced multi-tx campaign. The UI dirty-reads the
    ;; URH_Vacate*PoolLegs scanners, splits into disjoint gas-bounded slices (across legs; within a leg by nonces
    ;; for nonce kinds), and fires one Cp_BatchVacate<Kind> per slice. Each: validate the slice vs the LIVE tracker
    ;; + owner-gate (VCT|C>LEGS-*-VACATE), EnsureVacateBegun (first tx freezes stake/unstake pool-side + collect/
    ;; inject on the pool's FVTs), consume the slice, then MaybeFinalizeVacate with finalize=true (auto — honoured
    ;; only when URC_PoolFullyVacated, i.e. the genuinely-last batch, which then unfreezes). Serial block execution
    ;; makes this conflict-free; split beneficiaries drain incrementally.
    ;; ═══════════════════════════════════════════════════════════════════════════
    (defun CCp_BatchVacateOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
        )
        @doc "OF batch vacate (one UI slice). Amounts are resolved from the live tracker (whole-nonce), so the UI \
            \ passes only owner/beneficiary/nonce arrays. Validates the slice + owner (VCT|C>LEGS-ORTO-FUNGIBLE-VACATE, \
            \ auto-finalize), EnsureVacateBegun (freeze if first), XI_VacateOrtoFungibleBatch, then MaybeFinalizeVacate \
            \ true (unfreezes + finalizes only when the whole pool is empty)."
        (P|UEV_IMC)
        (let
            (
                (of-amounts:[[decimal]]
                    (URC_ResolveOfDecimalAmountsFromTracker pool-id dpof-id owner-ids beneficiary-ids nonces-array)
                )
            )
            (with-capability
                (VCT|C>LEGS-ORTO-FUNGIBLE-VACATE
                    pool-id dpof-id owner-ids beneficiary-ids nonces-array of-amounts true
                )
                (XI_EnsureVacateBegun pool-id)
                (let
                    (
                        (oc:object{IgnisCollectorV3.OutputCumulator}
                            (XI_VacateOrtoFungibleBatch
                                pool-id dpof-id owner-ids beneficiary-ids nonces-array of-amounts
                            )
                        )
                    )
                    (XI_MaybeFinalizeVacate pool-id dpof-id VACATE-KIND-OF true)
                    oc
                )
            )
        )
    )
    (defun CCp_BatchVacateTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
        @doc "TF batch vacate (one UI slice). Validate the slice + owner (VCT|C>LEGS-TRUE-FUNGIBLE-VACATE, \
            \ auto-finalize), EnsureVacateBegun (freeze if first), consume (UC_TfLegsFromParallelArrays → \
            \ XI_VacateTrueFungibleFromLegs), MaybeFinalizeVacate true (unfreezes + finalizes only when the pool \
            \ is fully empty)."
        (P|UEV_IMC)
        (with-capability
            (VCT|C>LEGS-TRUE-FUNGIBLE-VACATE pool-id dptf-id owner-ids beneficiary-ids amounts true)
            (XI_EnsureVacateBegun pool-id)
            (let
                (
                    (oc:object{IgnisCollectorV3.OutputCumulator}
                        (XI_VacateTrueFungibleFromLegs pool-id dptf-id
                            (UC_TfLegsFromParallelArrays owner-ids beneficiary-ids amounts))
                    )
                )
                (XI_MaybeFinalizeVacate pool-id dptf-id VACATE-KIND-TF true)
                oc
            )
        )
    )
    (defun CCp_BatchDrainTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            dptf-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            amounts:[decimal]
        )
        @doc "Vacate-v2 FAST-DRAIN: one TF batch that returns assets to owners and preserves each fully-drained \
            \ beneficiary's rewards, but does NOT touch scores and does NOT finalize. Same validation + owner gate \
            \ as CCp_BatchVacateTrueFungible (VCT|C>LEGS-TRUE-FUNGIBLE-VACATE, finalize=false), EnsureVacateBegun \
            \ (freeze if first), then XI_DrainTrueFungibleFromLegs (per-leg transfer+tracker-zero+rollup; \
            \ settle-once for beneficiaries whose last position drained). The pool stays FROZEN until \
            \ C_FinalizeVacate nukes the scores (generation bump + aggregate zero) once nns==0. Commit-forward: v1 \
            \ CCp_BatchVacateTrueFungible remains the abortable/score-delta path."
        (P|UEV_IMC)
        (with-capability
            (VCT|C>LEGS-TRUE-FUNGIBLE-VACATE pool-id dptf-id owner-ids beneficiary-ids amounts false)
            (XI_EnsureVacateBegun pool-id)
            (XI_DrainTrueFungibleFromLegs pool-id dptf-id
                (UC_TfLegsFromParallelArrays owner-ids beneficiary-ids amounts))
        )
    )
    (defun CCp_BatchDrainOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            dpof-id:string
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
        )
        @doc "Vacate-v2 FAST-DRAIN OF batch: return each owner's DPOF nonces + preserve each fully-drained \
            \ beneficiary's rewards, but does NOT touch scores and does NOT finalize. Amounts resolved from the \
            \ live tracker (whole-nonce). Same validation + owner gate as CCp_BatchVacateOrtoFungible \
            \ (VCT|C>LEGS-ORTO-FUNGIBLE-VACATE, finalize=false), EnsureVacateBegun (freeze if first), then \
            \ XI_DrainOrtoFungibleBatch. Pool stays FROZEN until C_FinalizeVacate nukes scores once nns==0. \
            \ Commit-forward; v1 CCp_BatchVacateOrtoFungible remains the abortable/score-delta path."
        (P|UEV_IMC)
        (let
            (
                (of-amounts:[[decimal]]
                    (URC_ResolveOfDecimalAmountsFromTracker pool-id dpof-id owner-ids beneficiary-ids nonces-array)
                )
            )
            (with-capability
                (VCT|C>LEGS-ORTO-FUNGIBLE-VACATE
                    pool-id dpof-id owner-ids beneficiary-ids nonces-array of-amounts false
                )
                (XI_EnsureVacateBegun pool-id)
                (XI_DrainOrtoFungibleBatch pool-id dpof-id owner-ids beneficiary-ids nonces-array of-amounts)
            )
        )
    )
    (defun CCp_BatchDrainCollectable:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            collectable-id:string
            son:bool
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "Vacate-v2 FAST-DRAIN collectable (SF son=true / NF son=false) batch: return each owner's nonces + \
            \ preserve each fully-drained beneficiary's rewards, but does NOT touch scores and does NOT finalize. \
            \ Same validation + owner gate as CCp_BatchVacateCollectables (VCT|C>LEGS-COLLECTABLE-VACATE, \
            \ finalize=false), EnsureVacateBegun (freeze if first), then XI_DrainCollectableBatch. Pool stays \
            \ FROZEN until C_FinalizeVacate nukes scores once nns==0. Commit-forward; v1 CCp_BatchVacateCollectables \
            \ remains the abortable/score-delta path."
        (P|UEV_IMC)
        (with-capability
            (VCT|C>LEGS-COLLECTABLE-VACATE
                pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array false
            )
            (XI_EnsureVacateBegun pool-id)
            (XI_DrainCollectableBatch
                pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array)
        )
    )
    (defun CCp_BatchVacateCollectables:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            collectable-id:string
            son:bool
            owner-ids:[string]
            beneficiary-ids:[string]
            nonces-array:[[integer]]
            amounts-array:[[integer]]
        )
        @doc "DPSF (son=true) / DPNF (son=false) batch vacate (one UI slice). Validate the slice + owner \
            \ (VCT|C>LEGS-COLLECTABLE-VACATE, auto-finalize), EnsureVacateBegun (freeze if first), \
            \ XI_VacateCollectableBatch, MaybeFinalizeVacate true (unfreezes + finalizes only when the pool is \
            \ fully empty)."
        (P|UEV_IMC)
        (with-capability
            (VCT|C>LEGS-COLLECTABLE-VACATE
                pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array true
            )
            (XI_EnsureVacateBegun pool-id)
            (let
                (
                    (oc:object{IgnisCollectorV3.OutputCumulator}
                        (XI_VacateCollectableBatch
                            pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array
                        )
                    )
                )
                (XI_MaybeFinalizeVacate pool-id collectable-id
                    (if son VACATE-KIND-DPSF VACATE-KIND-DPNF) true)
                oc
            )
        )
    )
    (defun C_AbortVacate:object{IgnisCollectorV3.OutputCumulator} (pool-id:string)
        @doc "Clear vacate-in-progress; stake stays disabled (ops: C_EnablePoolStake)."
        (P|UEV_IMC)
        (with-capability (VCT|C>ABORT-VACATE-POOL pool-id)
            (XI_ClearVacateInProgress pool-id)
            (UC_EmptyOc)
        )
    )
    (defun C_FinalizeVacate:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string)
        @doc "Vacate-v2 FINALIZE (the nuke) — commit-forward terminal step of a v2 campaign. After the pool has \
            \ been fully drained (nns==0) via Cp_BatchDrain*, bulk-zero every employed score's aggregates + bump \
            \ their vacate-generation (lazily invalidating all per-user rows — the drained beneficiaries were \
            \ already settled during the drain), then clear vacate-in-progress, RE-ENABLE stake, and unfreeze the \
            \ pool's FVTs. Pool-owner + nns==0 gated (in the cap). v1 Cp_BatchVacate* auto-finalizes instead."
        (P|UEV_IMC)
        (with-capability (VCT|C>FINALIZE-VACATE pool-id)
            (let
                (
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                ;; 1] nuke each employed score: bulk-zero aggregates + bump vacate-generation (≤7 point writes)
                (map
                    (lambda (score-id:string) (ref-SCR::XE_NukeScoreForVacate score-id))
                    (ref-AQP::URC_PoolActiveScoreIds pool-id)
                )
                ;; 2] finalize the pool: clear vacate-in-progress, re-enable stake, unfreeze the pool's FVTs
                (ref-AQP::XE_SetVacateJobState pool-id false)
                (ref-AQP::XB_SetPoolStakeEnabled pool-id true)
                (XI_SetPoolFvtsVacateFrozen pool-id false)
                (URCi_FinalizeVacate)
            )
        )
    )

)

;; --- tables for 06_VCT.pact (2 defined) ---
;; NEW MODULE this round -- not live on chain, so its tables do
;; not exist yet and these create-table calls are ACTIVE.
(create-table P|T)
(create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/07_MTX-AQP.pact ==========
;; Deploy: load THIS file — interface + module ship together (model: 1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact).
;; Holds ALL AQP multi-transaction (defpact) functions. M3 #12 (deb-staleness): the spike-fallback inject.
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AqpMtxV1
    @doc "Exposes AQP MultiStep (defpact) client functions. Currently: the tiered enforced-fresh FVT inject \
        \ (MTX|n|C_Inject) — the spike fallback for CC_Inject when the stale set exceeds one transaction."

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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_2|Inject (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal))
    (defun C_2|SweepRevokeAnchor (patron:string executor:string anchor-id:string))

)
;;
(module MTX-AQP GOV
    @doc "Holds all AQP multi-transaction (defpact) flows. Provides C_2|Inject — a 2-step \
        \ enforced-fresh vault/treasury reward inject that is the spike fallback for \
        \ AQP-FVT::CC_Inject when the deb-stale staker set exceeds one tx — and \
        \ C_2|SweepRevokeAnchor — a 2-step paginated re-score sweep that retires an employed \
        \ anchor. Each step atomically fixes/recomputes a bounded window of holders via \
        \ AQP-FVT XE_ building blocks under its own policy caller guard."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements AqpMtxV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_MTX-AQP                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|MTX-AQP_ADMIN)))
    (defcap GOV|MTX-AQP_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_MTX-AQP)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "MTX-AQP Ownership not verified"
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
    (defcap P|MTX-AQP|CALLER ()
        true
    )
    (defcap P|MTX-AQP|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|MTX-AQP|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|MTX-AQP|REMOTE-GOV))
        (compose-capability (P|MTX-AQP|CALLER))
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
        (with-capability (GOV|MTX-AQP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|MTX-AQP_ADMIN)
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
        (with-capability (GOV|MTX-AQP_ADMIN)
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
        (with-capability (GOV|MTX-AQP_ADMIN)
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
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|MTX-AQP|CALLER)))
            )
            ;; MTX-AQP calls AQP-FVT's XE_ building blocks (P|UEV_IMC) — register as an allowed IMC caller.
            ;; (The re-score sweep's ANK/POOL calls live in AQP-FVT::CC_SweepRevokeAnchor, which is already in
            ;;  ANK's + POOL's IMP — so MTX-AQP itself does not call ANK/POOL directly.)
            (ref-P|FVT::P|A_AddIMP mg)
            ;; #75 B': the deb-fix + re-score defpacts now drive RPS::XE_FvtFixUserChunk /
            ;; XE_FvtSweepRecomputeChunk (moved to the RPS reward engine) — register on RPS IMP too.
            (ref-P|RPS::P|A_AddIMP mg)
            ;;IGNIS RESTRUCTURE 2026-09-20: the collectors became protected X_ functions
            ;;behind `P|UEV_IMC`, so every module that bills must be a registered IMP peer
            ;;of IGNIS or the fee call dies with "None of the guards passed".
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;; Per-step fix capacity (deb-staleness sweep). CALIBRATION-GATED: size N against the measured gas of one
    ;; (settle+refresh+mirror-resync) fix + the O(present-users) scan that shares the step, staying under ~2M.
    ;; Placeholder pending real-state measurement (design §2.7 / Pre-build calibration). Start conservative.
    (defconst N_FIX:integer 400)
    ;; Per-step recompute capacity (re-score SWEEP). CALIBRATION-GATED — size N_SWEEP against the measured gas of one
    ;; holder recompute (settle → aggregate/lane refold → deb + mirror) plus the O(present) window scan it shares,
    ;; staying under ~2M. The sweep unit is HEAVIER than the inject fix (deeper refold), so N_SWEEP < N_FIX.
    ;; Placeholder pending real-state measurement (design §2.7 / Pre-build calibration).
    (defconst N_SWEEP:integer 300)
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap MTX-AQP|C>INJECT (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Protects the MTX|n|C_Inject multistep flow. Composes P|SECURE-CALLER so P|MTX-AQP|CALLER is ACTIVE \
            \ while the steps call AQP-FVT's XE_ building blocks (FVT's P|UEV_IMC checks MTX-AQP's registered caller \
            \ guard — see P|A_Define). Acquired fresh per step (steps are separate txs; the pact-id gates continuation)."
        @event
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap MTX-AQP|C>SWEEP-REVOKE (patron:string executor:string anchor-id:string)
        @doc "Protects the MTX|n|C_SweepRevokeAnchor multistep flow. Composes P|SECURE-CALLER so P|MTX-AQP|CALLER is \
            \ ACTIVE while the steps call AQP-FVT's XE_ bracket (freeze/revoke/unfreeze) + recompute-chunk building \
            \ blocks (FVT's P|UEV_IMC checks MTX-AQP's registered caller guard — see P|A_Define). Acquired fresh per \
            \ step (steps are separate txs; the pact-id gates continuation). The anchor owner (= anchored-asset \
            \ owner) is enforced downstream inside ANK|XE>SWEEP-REVOKE; the EXECUTOR is pinned to that same \
            \ authority here, via ANK's shared disjunction helper rather than a second copy of the rule."
        @event
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-ANK::UEV_ExecutorIzAnchorAuthority executor anchor-id)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_SweepTotalPresent:integer (score-ids:[string])
        @doc "Total present holders across every FVT member employing the swept boost-class — the paginated \
            \ recompute-set size. Read-only; sweep-in-progress keeps it fixed across defpact steps."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (fold (+) 0
                (map
                    (lambda (sid:string) (length (RPS.URH_FvtPresentUsers (ref-SCR::UR_SCR|ScoreFvtLink sid))))
                    score-ids))
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 1 — Innate protection offered by XE_FvtSweepRecomputeChunk
    (defun XI_SweepRecomputeWindow:integer
        (score-ids:[string] boost-class-id:string win-lo:integer win-hi:integer)
        @doc "Recompute holders whose GLOBAL flattened index — present users concatenated across score-ids in order \
            \ — falls in [win-lo, win-hi). Per score, slice its present users to the window overlap and forward one \
            \ AQP-FVT::XE_FvtSweepRecomputeChunk. The sweep freeze makes URH_FvtPresentUsers order deterministic \
            \ across steps, so (drop offset) advances the window without re-processing (contrast the inject's \
            \ shrinking (take N) set). Returns the number of holders recomputed. Runs under MTX-AQP|C>SWEEP-REVOKE."
        (at "processed"
            (fold
                (lambda (acc:object sid:string)
                    (let
                        (
                            (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                            (seen-before:integer (at "seen" acc))
                            (fvt:string (ref-SCR::UR_SCR|ScoreFvtLink sid))
                            (member:string
                                (if (ref-SCR::UR_SCR|ScoreTriplet sid) (ref-SCR::UR_SCR|ScoreTripletId sid) sid))
                        )
                        (let
                            (
                                (users:[string] (RPS.URH_FvtPresentUsers fvt))
                            )
                            (let
                                (
                                    (seen-after:integer (+ seen-before (length users)))
                                    (lo:integer (if (> win-lo seen-before) win-lo seen-before))
                                )
                                (let
                                    (
                                        (hi:integer (if (< win-hi seen-after) win-hi seen-after))
                                    )
                                    (if (> hi lo)
                                        (let
                                            (
                                                (slice:[string] (take (- hi lo) (drop (- lo seen-before) users)))
                                            )
                                            (RPS.XE_FvtSweepRecomputeChunk fvt member boost-class-id slice)
                                            {
                                            "seen"
                                            :
                                            seen-after,
                                            "processed"
                                            :
                                            (+ (at "processed" acc) (length slice))
                                            }
                                        )
                                        {"seen": seen-after, "processed": (at "processed" acc)})
                                )
                            )
                        )
                    ))
                {"seen": 0, "processed": 0}
                score-ids))
    )
    ;;{5.7}  User [A/C]
    (defun C_2|Inject (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "2-step enforced-fresh inject (spike fallback for AQP-FVT::CC_Inject; handles up to 2×N_FIX stale \
            \ stakers). Acquires MTX-AQP|C>INJECT, then runs the MTX|2|C_Inject defpact. Advance with \
            \ (continue-pact 1). Vault/treasury only (the defpact's inject is class≠0)."
        (P|UEV_IMC)
        (with-capability (MTX-AQP|C>INJECT patron fvt-id reward-dptf-id amount)
            (MTX|2|C_Inject patron injector fvt-id reward-dptf-id amount)
        )
    )
    (defun C_2|SweepRevokeAnchor (patron:string executor:string anchor-id:string)
        @doc "2-step paginated re-score SWEEP that retires an employed anchor (Phase 3 closeout; spike fallback for \
            \ AQP-FVT::CC_SweepRevokeAnchor when the recompute set exceeds one tx). Acquires MTX-AQP|C>SWEEP-REVOKE, \
            \ then runs the MTX|2|C_SweepRevokeAnchor defpact. Step 0 brackets (freeze + swept-revoke) + recomputes \
            \ the first window; advance with (continue-pact 1). Owner enforced downstream in ANK|XE>SWEEP-REVOKE."
        (P|UEV_IMC)
        (with-capability (MTX-AQP|C>SWEEP-REVOKE patron executor anchor-id)
            (MTX|2|C_SweepRevokeAnchor patron executor anchor-id)
        )
    )
    (defpact MTX|2|C_Inject (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Enforced-fresh vault/treasury inject as a 2-step defpact: each step's opening stale scan IS the \
            \ pre-inject freshness proof — atomically fixing a whole scanned set of size <= N_FIX leaves zero \
            \ stale, so no re-scan is needed. Step 0 injects terminally when the stale set fits, else fixes \
            \ N_FIX and continues to step 1. Handles up to 2xN_FIX stale stakers; larger spikes need a higher-n variant."
        ;; Enforced-fresh vault/treasury inject over 2 steps (owner design §2.8). Each step's opening scan IS the
        ;; pre-inject freshness proof: fixing an entire scanned set of size ≤ N_FIX atomically leaves ZERO stale, so
        ;; no separate re-scan is needed. Handles up to 2×N_FIX; larger spikes → a higher-n variant (add when needed).
        ;;
        ;;Step 0 — scan; if the whole stale set fits (≤ N_FIX) fix it all + inject (terminal), else fix N_FIX + continue.
        (step
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (require-capability (MTX-AQP|C>INJECT patron fvt-id reward-dptf-id amount))
              (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (stale:[string] (RPS.URH_FvtStalePresentUsers fvt-id))
                )
                (if (<= (length stale) N_FIX)
                    (let
                        (
                            (n:integer (length stale))
                        )
                        (RPS.XE_FvtFixUserChunk fvt-id reward-dptf-id stale)
                        (ref-IGNIS::XE_CollectIgnis patron (ref-FVT::XB_FvtInject patron injector fvt-id reward-dptf-id amount))
                        (yield {"injected" : true})
                        (format "MTX Inject 1|2: fixed {} stale staker(s) and INJECTED {} {} (terminal)." [n amount reward-dptf-id])
                    )
                    (let
                        (
                            (remaining:integer (- (length stale) N_FIX))
                        )
                        (RPS.XE_FvtFixUserChunk fvt-id reward-dptf-id (take N_FIX stale))
                        (yield {"injected" : false})
                        (format "MTX Inject 1|2: fixed {} of {} stale — {} remain, continue to step 2." [N_FIX (length stale) remaining])
                    )
                )
              )
            )
        )
        ;;Step 1 — if step 0 already injected, no-op; else fix the (now ≤ N_FIX) remainder and inject.
        (step
            (resume
                {"injected" := injected}
                (if injected
                    "MTX Inject 2|2: already injected in step 1 — no-op."
                    (with-capability (MTX-AQP|C>INJECT patron fvt-id reward-dptf-id amount)
                        (let
                            (
                                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                                (stale:[string] (RPS.URH_FvtStalePresentUsers fvt-id))
                            )
                            (RPS.XE_FvtFixUserChunk fvt-id reward-dptf-id stale)
                            (ref-IGNIS::XE_CollectIgnis patron (ref-FVT::XB_FvtInject patron injector fvt-id reward-dptf-id amount))
                            (format "MTX Inject 2|2: fixed {} remaining stale staker(s) and INJECTED {} {}." [(length stale) amount reward-dptf-id])
                        )
                    )
                )
            )
        )
    )
    (defpact MTX|2|C_SweepRevokeAnchor (patron:string executor:string anchor-id:string)
        @doc "Paginated re-score sweep + anchor revoke as a 2-step defpact (Phase 3 closeout): step 0 brackets \
            \ the sweep (freezes every affected pool + swept-revokes the anchor) then recomputes the first window \
            \ of present holders; sweep-in-progress holds across steps (separate txs) so the flattened holder \
            \ window pages deterministically. Terminal in step 0 when the whole holder set fits (<= N_SWEEP); \
            \ handles up to 2xN_SWEEP holders, larger spikes need a higher-n variant."
        ;; Paginated re-score SWEEP over 2 steps (Phase 3 closeout). Step 0 brackets the sweep (freeze every affected
        ;; pool + swept-revoke the anchor) then recomputes the first window of present holders; if the whole set fits
        ;; (≤ N_SWEEP) it unfreezes + terminates, else it yields the cursor. sweep-in-progress holds ACROSS steps
        ;; (separate txs), keeping the recompute set FIXED (stake + collect blocked) so the flattened [offset, …)
        ;; window pages deterministically. Handles up to 2×N_SWEEP holders; larger spikes → a higher-n variant.
        ;;
        ;;Step 0 — bracket (freeze + swept-revoke) + recompute window [0, N_SWEEP); terminal if the whole set fits.
        (step
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (require-capability (MTX-AQP|C>SWEEP-REVOKE patron executor anchor-id))
                (let
                    (
                        (boost-class-id:string (ref-ANK::UR_ANK|BoostClassId anchor-id))
                    )
                    (let
                        (
                            (score-ids:[string] (ref-ANK::UR_BC|ScoreLinks boost-class-id))
                        )
                        (ref-FVT::XE_SweepBegin anchor-id)
                        (let
                            (
                                (total:integer (URC_SweepTotalPresent score-ids))
                            )
                            (if (<= total N_SWEEP)
                                (let
                                    (
                                        (n:integer (XI_SweepRecomputeWindow score-ids boost-class-id 0 total))
                                    )
                                    (ref-FVT::XE_SweepEnd anchor-id)
                                    (yield {"done": true, "boost-class-id": boost-class-id, "score-ids": score-ids, "offset": 0})
                                    (format "MTX Sweep 1|2: swept-revoked anchor {} and recomputed {} holder(s) across {} score(s) (terminal)." [anchor-id n (length score-ids)])
                                )
                                (let
                                    (
                                        (n:integer (XI_SweepRecomputeWindow score-ids boost-class-id 0 N_SWEEP))
                                    )
                                    (yield {"done": false, "boost-class-id": boost-class-id, "score-ids": score-ids, "offset": N_SWEEP})
                                    (format "MTX Sweep 1|2: swept-revoked anchor {}; recomputed {} of {} holder(s) — {} remain, continue to step 2." [anchor-id n total (- total N_SWEEP)])
                                ))
                        )
                    )
                )
            )
        )
        ;;Step 1 — if step 0 already finished, no-op; else recompute the remainder [offset, total) then unfreeze.
        (step
            (resume
                {"done" := done, "boost-class-id" := boost-class-id, "score-ids" := score-ids, "offset" := offset}
                (if done
                    "MTX Sweep 2|2: already completed in step 1 — no-op."
                    (with-capability (MTX-AQP|C>SWEEP-REVOKE patron executor anchor-id)
                        (let
                            (
                                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                                (total:integer (URC_SweepTotalPresent score-ids))
                            )
                            (let
                                (
                                    (n:integer (XI_SweepRecomputeWindow score-ids boost-class-id offset total))
                                )
                                (ref-FVT::XE_SweepEnd anchor-id)
                                (format "MTX Sweep 2|2: recomputed {} remaining holder(s) — anchor {} retired." [n anchor-id])
                            )
                        )))))
    )

)

;; --- tables for 07_MTX-AQP.pact (2 defined) ---
;; NEW MODULE this round -- not live on chain, so its tables do
;; not exist yet and these create-table calls are ACTIVE.
(create-table P|T)
(create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08_DSA.pact ==============
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
    (defun A_ToggleExternalOracle:string (on:bool))
    (defun A_SetOracleValidity:string (seconds:integer))

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
            \ Only the FVT owner may define it. P|UEV_IMC + DSA|C>DEFINE-VAULT. Bills GAS|DEFINE-VAULT."
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
            \ Bills GAS|SET-ORACLE-AUTH."
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
    (defun A_ToggleExternalOracle:string (on:bool)
        @doc "DSA MODULE ADMIN (GOV): flip the SINGULAR GLOBAL external-oracle switch for ALL operators at once. \
            \ OFF ⇒ external oracling is bypassed protocol-wide — every agency captures its STORED weight (oracle \
            \ entries, fresh or stale, are ignored); ON ⇒ the oracle-validity freshness gate applies (an operator \
            \ with no/stale entry captures 0). Composes P|SECURE-CALLER for the FVT global-config write."
        (with-capability (GOV|DSA_ADMIN)
            (with-capability (P|SECURE-CALLER)
                (RPS.XE_SetExternalOracle on)
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
                (RPS.XE_SetOracleValidity seconds)
            )
        )
    )
    (defun C_WithdrawRoyalty:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
        @doc "Owner-only: dispose the whole royalty pool (uptime-shortfall custody) of <reward-dptf-id> on a DSA \
            \ vault by WITHDRAWING it to the FVT owner (delegates the AQP-custody move + zero to the FVT primitive \
            \ FVT::XE_WithdrawRoyalty, which holds the custody-governor authority). P|UEV_IMC + DSA|C>WITHDRAW-ROYALTY. \
            \ Bills GAS|WITHDRAW-ROYALTY merged with the custody transfer's IGNIS."
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
            \ P|UEV_IMC + DSA|C>BURN-ROYALTY. Bills GAS|BURN-ROYALTY merged with the burn's IGNIS."
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
            \ of the swpair). P|UEV_IMC + DSA|C>FUEL-ROYALTY. Bills GAS|FUEL-ROYALTY merged with the fuel's IGNIS."
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
            \ DSA|C>SET-AGENCY-FEE. Bills GAS|SET-AGENCY-FEE."
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
            \ whole open). P|UEV_IMC + DSA|C>OPEN-AGENCY. Bills GAS|OPEN-AGENCY."
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
        @doc "Permissionless: recompute an agency's capture from its CURRENT quintessence (after a delegator \
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

;; --- tables for 08_DSA.pact (5 defined) ---
;; NEW MODULE this round -- not live on chain, so its tables do
;; not exist yet and these create-table calls are ACTIVE.
(create-table P|T)
(create-table P|MT)
(create-table DSA|T|Template)
(create-table DSA|T|Agency)
(create-table DSA|T|OracleAuth)


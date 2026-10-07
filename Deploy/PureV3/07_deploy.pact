;; TX 07/08 -- AQP-VCT, TS02-C3       (~297,730 B, ~252k gas)
;;
;; AQP-VCT   No edit of its own -- interface bump plus dot-pin on RPS, AQP-POOL and AQP-ANK.
;; TS02-C3   2.16.2: the five score issuers reported `score-name`, the stem the caller typed, while
;;           the generated id (`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) went unreported. The
;;           core already threaded it out via `URCi_IssueScore executor [score-id]`; the wrapper was
;;           throwing it away. Also wires the three score-definition wrappers to
;;           `AQP-POOL::UEV_ScoreDefinitionTargetMatchesPool` from TX 04.
;;
;; TS02-C3 is dot-called by AQP-INFO and AQP-BOOT, which is why it must precede TX 08.
;;
;; ROUND V3 -- the StoicSyntax 2.16 canon sweep. EIGHT transactions, nineteen modules.
;;
;; TWO OWNER RULINGS, 2026-10-06, both from one observation: a score was issued, and the block
;; explorer could tell you neither what had happened nor what had been created.
;;
;;   2.16.1  Only the MAIN capability of a C_/A_ entrypoint may be @event; an internal
;;           XI_/XE_/XB_ capability may not. One operation emitting two events is
;;           indistinguishable, to anything reading the chain, from two operations. 8 fixed.
;;   2.16.2  An issuance must return the id it GENERATED. The name the caller typed is an INPUT;
;;           the id is the only thing the transaction produced. 11 fixed.
;;
;; WHY EIGHT AND NOT THREE. Gas scales as the SEVENTH POWER of transaction size on this network
;; (measured: 3 x ~256 KB = ~285,675 gas against ~202,525,154 for one 768 KB transaction), which
;; puts the per-transaction ceiling at ~395 KB / 2.00M gas. Consolidating this round into 3 files
;; of ~692 KB was tried and would have cost ~100,000,000 gas EACH -- fifty times the limit. Six
;; transactions is impossible; seven puts 80% of the budget on one of them. Eight is the smallest
;; count that keeps every transaction an order of magnitude clear, and totals ~1.17M gas.
;;
;; ORDER IS LOAD-BEARING, AND IT RUNS THROUGH THE FILES, NOT JUST BETWEEN THEM. Modules inside one
;; transaction deploy top to bottom, so a dot-callee need only PRECEDE its callers in the overall
;; sequence. Two cascades fix that sequence:
;;
;;   AcquisitionScoresV1 -> V2 (five URH_ definition-inspection readers). A module holding
;;   `module{AcquisitionScoresV1} AQP-SCORE` fails its modref check once AQP-SCORE implements only
;;   V2. The interface ships in 03; every module naming it ships in 04 or later.
;;
;;   DOT-PIN. A dot call resolves at the CALLER's deploy time, so a caller not redeployed keeps the
;;   old callee -- and because these callees own tables, it does not go stale, it ABORTS with
;;   "hash not blessed". `_purev3.py --check` re-derives the whole ordering and fails on a breach.
;;
;; DEPLOY IN NUMERIC ORDER. Seven of the nineteen modules contain no edit of their own and are here
;; purely to stay in step; skipping one breaks it.
;;
;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev3.py

(namespace "ouronet-ns")

;; ---- source: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/06_VCT.pact (module only -- its interface is already live)
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
        (executor:string pool-id:string)
        @doc "Clear vacate-in-progress on pool; stake stays disabled. \
            \ <executor> is BOUND to the derived pool owner beside the key check -- HANDOFF 4g."
        @event
        (CAP_VctVacatePoolOwner pool-id)
        (UEV_ExecutorIzVacatePoolOwner executor pool-id)
        (compose-capability (SECURE))
    )
    (defcap VCT|C>FINALIZE-VACATE (executor:string pool-id:string)
        @doc "Vacate-v2 finalize (nuke) master cap. All validation here, not in the body: the tx sender must own \
            \ the pool (CAP_VctVacatePoolOwner), a vacate must be in progress, AND the pool must be fully drained \
            \ (URC_PoolFullyVacated — nns==0, so every position is out and every beneficiary was already settled \
            \ during the drain). Composes SECURE for the pool re-enable + FVT unfreeze; the per-score nuke goes \
            \ through SCORE's own IMC-gated XE_NukeScoreForVacate."
        @event
        (CAP_VctVacatePoolOwner pool-id)
        (UEV_ExecutorIzVacatePoolOwner executor pool-id)
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (enforce (ref-AQP::UR_AQP|PoolVacateInProgress pool-id) "Finalize: no vacate in progress on this pool")
            (enforce (URC_PoolFullyVacated pool-id) "Finalize: pool not fully drained (nns != 0)")
        )
        (compose-capability (SECURE))
    )
    (defcap VCT|C>VACATE (executor:string pool-id:string)
        @doc "Master AGNOSTIC vacate cap (rehaul). Class-agnostic: the new vacate reads the pool's staker legs \
            \ ON-CHAIN (no UI-supplied arrays to tamper/validate), so this gates the pool OWNER, ENFORCES the pool's \
            \ aqp-class is a known class (0-4) — all validation lives here, not in the function body — and composes \
            \ SECURE + P|VCT|RECIPE. Used by the single-tx dispatcher CC_FullVacate and the per-kind XB_Vacate* \
            \ wrappers; the per-kind XI_Vacate*FromLegs / *PoolLegs functions run under it via require P|VCT|RECIPE."
        @event
        (CAP_VctVacatePoolOwner pool-id)
        (UEV_ExecutorIzVacatePoolOwner executor pool-id)
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
    (defun URCi_VacateTrueFungible:decimal (pool-id:string)
        @doc "Cost of XB_VacateTrueFungible, which is the whole of a pool's TF side. \
            \ \
            \ MIRRORS THE EXEC EXACTLY: the exec scans `URH_VacateTrueFungiblePoolLegs` and feeds \
            \ the lanes to `XI_VacateTrueFungiblePoolLegs`, so the cost is the per-batch reader \
            \ summed over the SAME lanes, read the SAME way. Reading the plan rather than being \
            \ handed it is what makes this previewable from a pool id alone -- `URCi_FullVacate` \
            \ takes its lanes as arguments because its caller has already scanned. \
            \ \
            \ WRITTEN 2026-10-04 BECAUSE NOTHING COULD PRICE THESE. The four per-leg vacates were \
            \ named `AQP-POOL|XB_Vacate*` on Talos, which matches neither the registry's \
            \ entrypoint filter nor the price sheet's, so four BILLED client operations had no \
            \ preview and nobody noticed. Renaming them to `CC_Vacate*` is what made the gap \
            \ visible; this closes it."
        (fold (+) 0.0
            (map (lambda (l:object{AcquisitionSchemasV1.VCT|VacateTfLane})
                     (URCi_BatchVacateTrueFungible pool-id (at "asset-id" l) (at "legs" l)))
                 (URH_VacateTrueFungiblePoolLegs pool-id)))
    )
    (defun URCi_VacateOrtoFungible:decimal (pool-id:string dpof-id:string)
        @doc "Cost of XB_VacateOrtoFungible -- ONE OrtoFungible satellite of a pool. Mirrors the \
            \ exec: same `URHC_VacateNonceOwnerRowsRaw pool-id dpof-id VACATE-KIND-OF` scan, fed \
            \ to the same per-batch reader the exec's consume path is priced by."
        (URCi_BatchVacateOrtoFungible pool-id dpof-id
            (URHC_VacateNonceOwnerRowsRaw pool-id dpof-id VACATE-KIND-OF))
    )
    (defun URCi_VacateSemiFungible:decimal (pool-id:string dpsf-id:string)
        @doc "Cost of XB_VacateSemiFungible -- ONE DPSF collection of a pool. Mirrors the exec, \
            \ including `son=true`, which is what selects the DPSF side of the shared reader."
        (URCi_BatchVacateCollectables pool-id dpsf-id true
            (URHC_VacateNonceOwnerRowsRaw pool-id dpsf-id VACATE-KIND-DPSF))
    )
    (defun URCi_VacateNonFungible:decimal (pool-id:string dpnf-id:string)
        @doc "Cost of XB_VacateNonFungible -- ONE DPNF collection of a pool. Mirrors the exec, \
            \ including `son=false`; the DPSF and DPNF paths differ only in that flag and in the \
            \ scan kind, and getting either wrong prices the other asset."
        (URCi_BatchVacateCollectables pool-id dpnf-id false
            (URHC_VacateNonceOwnerRowsRaw pool-id dpnf-id VACATE-KIND-DPNF))
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
    (defun UEV_ExecutorIzVacatePoolOwner (executor:string pool-id:string)
        @doc "BINDS <executor> to the pool's canonical owner konto -- the SAME value \
            \ CAP_VctVacatePoolOwner resolves and key-checks, read through the same \
            \ ref-AQP::URC_AqpOwnerKonto so the two can never disagree. \
            \ \
            \ It does NOT replace that gate. CAP_VctVacatePoolOwner proves the signer holds the \
            \ owner's key; this proves the account the caller NAMED is that owner. Both are \
            \ needed and they are different questions: an AQP pool's owner is derived from the \
            \ canonical ASSET, which for a sovereign asset is a SMART account whose key a human \
            \ holds -- so the key check passes for an account the caller never names. That is \
            \ HANDOFF 4g, and it is the same reasoning AQP-POOL's own UEV_ExecutorIzPoolOwner \
            \ carries; this is its local twin, declared here because 03_AQP does not expose it \
            \ on AcquisitionPoolsV1. \
            \ (patron/executor canon 2.2, indirect route named, 2026-09-22.)"
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (enforce (= executor (ref-AQP::URC_AqpOwnerKonto pool-id))
                (format "Executor {} is not the owner of pool {} (owner is {})"
                    [executor pool-id (ref-AQP::URC_AqpOwnerKonto pool-id)]))
        )
    )
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
                            AQP|SC_NAME
                            AQP|SC_NAME
                            (at "receiver-array" bulk-arr)
                            [dptf-id]
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
                            AQP|SC_NAME
                            AQP|SC_NAME
                            (at "receiver-array" bulk-arr)
                            [dptf-id]
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
        (patron:string pool-id:string dpof-id:string legs:[object{AcquisitionSchemasV1.VCT|VacateNonceLeg}])
        @doc "OF vacate CONSUMER (per DPOF asset) — no scan. Unpack the pre-built nonce legs (owner/beneficiary/ \
            \ nonces + the real per-nonce decimal amounts the PHASE-1 URD scan already read off the tracker) into \
            \ the batch arrays and run bulk custody-return + unwind (XI_VacateOrtoFungibleBatch). Empty legs → \
            \ no-op (the batch core is not empty-safe: empty owner-ids → enumerate 0 -1 → out-of-bounds). \
            \ require P|VCT|RECIPE."
        (require-capability (P|VCT|RECIPE))
        (if (= (length legs) 0)
            (UC_EmptyOc)
            (XI_VacateOrtoFungibleBatch patron pool-id dpof-id
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
        (patron:string pool-id:string lanes:[object{AcquisitionSchemasV1.VCT|VacateNonceLane}])
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
                            (XI_VacateOrtoFungibleFromLegs patron pool-id (at "asset-id" lane) (at "legs" lane)))
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
        (patron:string 
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
                    (ref-DPOF::C_BulkTransfer patron AQP|SC_NAME owner-ids dpof-id nonces-array true)
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
                        AQP|SC_NAME AQP|SC_NAME owner-ids collectable-id son nonces-array amounts-array true
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
        (patron:string 
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
                    (ref-DPOF::C_BulkTransfer patron AQP|SC_NAME owner-ids dpof-id nonces-array true)
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
                        AQP|SC_NAME AQP|SC_NAME owner-ids collectable-id son nonces-array amounts-array true
                    )
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
        (executor:string pool-id:string)
        @doc "Vacate rehaul — external per-kind TF vacate for a whole pool (both internal + external, hence XB). \
            \ 2-phase: SCAN every live DPTF lane (URH_VacateTrueFungiblePoolLegs: native + F| frozen) → CONSUME \
            \ (XI_VacateTrueFungiblePoolLegs). The pool's DPOF satellites (Z|/H|) are vacated by XB_VacateOrtoFungible; \
            \ use CC_FullVacate to empty a whole pool of any class in one call."
        (P|UEV_IMC)
        (with-capability (VCT|C>VACATE executor pool-id)
            (XI_VacateTrueFungiblePoolLegs pool-id (URH_VacateTrueFungiblePoolLegs pool-id))
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          VCT|C>VACATE
    (defun XB_VacateOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string dpof-id:string)
        @doc "Vacate rehaul — external per-kind OF vacate for ONE OF asset of a pool (both internal + external). \
            \ 2-phase: SCAN that asset's legs (URHC_VacateNonceOwnerRowsRaw) → CONSUME (XI_VacateOrtoFungibleFromLegs). \
            \ A class-1 pool has TF + ≥1 OF satellite; call per satellite, or use CC_FullVacate for the whole pool."
        (P|UEV_IMC)
        (with-capability (VCT|C>VACATE executor pool-id)
            (XI_VacateOrtoFungibleFromLegs patron pool-id dpof-id
                (URHC_VacateNonceOwnerRowsRaw pool-id dpof-id VACATE-KIND-OF))
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          VCT|C>VACATE
    (defun XB_VacateSemiFungible:object{IgnisCollectorV3.OutputCumulator}
        (executor:string pool-id:string dpsf-id:string)
        @doc "Vacate rehaul — external per-kind DPSF (semi-fungible collection) vacate for ONE collectable of a \
            \ pool. 2-phase: SCAN (URHC_VacateNonceOwnerRowsRaw, DPSF) → CONSUME (XI_VacateCollectablesFromLegs, \
            \ son=true). Use CC_FullVacate to empty the whole pool in one call."
        (P|UEV_IMC)
        (with-capability (VCT|C>VACATE executor pool-id)
            (XI_VacateCollectablesFromLegs pool-id dpsf-id true
                (URHC_VacateNonceOwnerRowsRaw pool-id dpsf-id VACATE-KIND-DPSF))
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          VCT|C>VACATE
    (defun XB_VacateNonFungible:object{IgnisCollectorV3.OutputCumulator}
        (executor:string pool-id:string dpnf-id:string)
        @doc "Vacate rehaul — external per-kind DPNF (non-fungible collection) vacate for ONE collectable of a \
            \ pool. 2-phase: SCAN (URHC_VacateNonceOwnerRowsRaw, DPNF) → CONSUME (XI_VacateCollectablesFromLegs, \
            \ son=false). Use CC_FullVacate to empty the whole pool in one call."
        (P|UEV_IMC)
        (with-capability (VCT|C>VACATE executor pool-id)
            (XI_VacateCollectablesFromLegs pool-id dpnf-id false
                (URHC_VacateNonceOwnerRowsRaw pool-id dpnf-id VACATE-KIND-DPNF))
        )
    )
    ;;{5.7}  User [A/C]
    ;; [C]   client
    (defun CC_FullVacate:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string)
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
            (with-capability (VCT|C>VACATE executor pool-id)
                (if (or (= c 0) (= c 1))
                    ;; TF-family: scan+consume the DPTF lanes AND the DPOF satellite lanes
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (XI_VacateTrueFungiblePoolLegs pool-id (URH_VacateTrueFungiblePoolLegs pool-id))
                            (XI_VacateOrtoFungiblePoolLegs patron pool-id (URH_VacateOrtoFungiblePoolLegs pool-id))
                        ]
                        [])
                    (if (= c 2)
                        (XI_VacateOrtoFungiblePoolLegs patron pool-id (URH_VacateOrtoFungiblePoolLegs pool-id))
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
        (patron:string 
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
                                patron pool-id dpof-id owner-ids beneficiary-ids nonces-array of-amounts
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
        (patron:string 
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
                (XI_DrainOrtoFungibleBatch patron pool-id dpof-id owner-ids beneficiary-ids nonces-array of-amounts)
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
    (defun C_AbortVacate:object{IgnisCollectorV3.OutputCumulator} (patron:string executor:string pool-id:string)
        @doc "Clear vacate-in-progress; stake stays disabled (ops: C_EnablePoolStake). \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. VCT|C>ABORT-VACATE-POOL runs \
            \ CAP_VctVacatePoolOwner, which enforces ownership of the DERIVED \
            \ (URC_AqpOwnerKonto pool-id) and names no actor -- HANDOFF 4g -- and \
            \ UEV_ExecutorIzVacatePoolOwner binds the declared executor to that same owner. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (VCT|C>ABORT-VACATE-POOL executor pool-id)
            (XI_ClearVacateInProgress pool-id)
            (UC_EmptyOc)
        )
    )
    (defun C_FinalizeVacate:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string)
        @doc "Vacate-v2 FINALIZE (the nuke) — commit-forward terminal step of a v2 campaign. After the pool has \
            \ been fully drained (nns==0) via Cp_BatchDrain*, bulk-zero every employed score's aggregates + bump \
            \ their vacate-generation (lazily invalidating all per-user rows — the drained beneficiaries were \
            \ already settled during the drain), then clear vacate-in-progress, RE-ENABLE stake, and unfreeze the \
            \ pool's FVTs. Pool-owner + nns==0 gated (in the cap). v1 Cp_BatchVacate* auto-finalizes instead."
        (P|UEV_IMC)
        (with-capability (VCT|C>FINALIZE-VACATE executor pool-id)
            (let
                (
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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

;; ---- source: 1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact (module only -- its interface is already live)
(module TS02-C3 GOV
    @doc "TALOS Stage 2 Client Functiones Part 3 - Acquisition Pools Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_ClientThreeV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    ;;Defaults for AQP-FVT|C_IssueGenericEarningVault. Named rather than inlined because each one
    ;;is a class rule a caller would otherwise have to know: getting any of them wrong builds a
    ;;vault that looks issued and cannot be staked.
    (defconst GV|PRECISION:integer                      6)
    (defconst GV|MX_FROZEN:decimal                      2.0)
    (defconst GV|POOL_CLASS_TF:integer                  1)      ;;aqp-class 1 = non-LP true fungible
    (defconst GV|FVT_CLASS_VAULT:integer                1)      ;;fvt-class 1 = Vault
    (defconst GV|SCORE_ENTITY_SCORE:integer             1)
    (defconst GV|COMMON_BAR:string                      "|")
    (defconst GOV|MD_TS02-C3                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS02-C3_ADMIN)))
    (defcap GOV|TS02-C3_ADMIN ()                        (enforce-guard GOV|MD_TS02-C3))
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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (gap:bool (ref-DALOS::UR_GAP))
            )
            (enforce (not gap) "While Global Administrative Pause is online, no client Functions can be executed")
            (compose-capability (P|TALOS-SUMMONER))
        )
    )
    (defcap P|TALOS-SUMMONER ()
        @doc "Talos Summoner Capability"
        true
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
        (with-capability (GOV|TS02-C3_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS02-C3_ADMIN)
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
        (with-capability (GOV|TS02-C3_ADMIN)
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
        (with-capability (GOV|TS02-C3_ADMIN)
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
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (ref-P|ANK:module{OuronetPolicyV2} AQP-ANK)
                (ref-P|SCR:module{OuronetPolicyV2} AQP-SCORE)
                (ref-P|AQP:module{OuronetPolicyV2} AQP-POOL)
                (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                (ref-P|VCT:module{OuronetPolicyV2} AQP-VCT)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|MTX-AQP:module{OuronetPolicyV2} MTX-AQP)
                (ref-P|DSA:module{OuronetPolicyV2} AQP-DSA)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|TS01-A::P|A_AddIMP mg)
            (ref-P|ANK::P|A_AddIMP mg)
            (ref-P|SCR::P|A_AddIMP mg)
            (ref-P|AQP::P|A_AddIMP mg)
            (ref-P|FVT::P|A_AddIMP mg)
            (ref-P|VCT::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            ;; MTX-AQP defpact wrapper below — register the Talos summoner as an allowed IMC caller of MTX-AQP.
            (ref-P|MTX-AQP::P|A_AddIMP mg)
            ;; DSA vault/agency wrappers below — register the Talos summoner as an allowed IMC caller of AQP-DSA.
            (ref-P|DSA::P|A_AddIMP mg)
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
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap AQP|C>STAKE-TRUE-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "AQP client event: stake TrueFungible. Composes P|TS only; sovereign recipe in FVT::CC_TrueFungibleStakeFlow."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-TRUE-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "AQP client event: unstake TrueFungible. Composes P|TS only; sovereign recipe in FVT::CC_TrueFungibleStakeFlow."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>STAKE-ORTO-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "AQP client event: stake OrtoFungible. nonces and nonce-amounts are resolved before this cap \
            \ (DPOF::UR_NoncesSupplies — whole nonce only) so the explorer records the exact legs moved."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-ORTO-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "AQP client event: unstake OrtoFungible. nonces and nonce-amounts resolved before this cap \
            \ (DPOF::UR_NoncesSupplies — whole nonce only) for explorer visibility."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>STAKE-SEMI-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: stake DPSF collectable (son=true). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-SEMI-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: unstake DPSF collectable (son=true). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>STAKE-NON-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: stake DPNF collectable (son=false). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-NON-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: unstake DPNF collectable (son=false). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-TF-ANCHORS
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "AQP client event: pool-agnostic TF anchor repair. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-SEMI-FUNGIBLE-ANCHORS
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "AQP client event: pool-agnostic DPSF anchor repair. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-NON-FUNGIBLE-ANCHORS
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "AQP client event: pool-agnostic DPNF anchor repair. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>ABORT-VACATE
        (patron:string pool-id:string)
        @doc "AQP client event: clear vacate-in-progress (stake stays disabled). Composes P|TS only."
        @event
        (compose-capability (P|TS))
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
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_ShortAccount:string (account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UC_ShortAccount account)
        )
    )
    (defun UC_FormatStakeTrueFungibleResult:string
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Stake success text: self-stake when owner=beneficiary; else names short owner and beneficiary."
        (if (= owner-id beneficiary-id)
            (format "Successfully staked TrueFungible {} amount {} into Pool {} (self-stake, {}). "
                [dptf-id amount pool-id (UC_ShortAccount owner-id)]
            )
            (format "Successfully staked TrueFungible {} amount {} into Pool {} for beneficiary {} (owner {}). "
                [dptf-id amount pool-id (UC_ShortAccount beneficiary-id) (UC_ShortAccount owner-id)]
            )
        )
    )
    (defun UC_FormatUnstakeTrueFungibleResult:string
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Unstake success text: self-stake when owner=beneficiary; else names short owner and beneficiary."
        (if (= owner-id beneficiary-id)
            (format "Successfully unstaked TrueFungible {} amount {} from Pool {} (self-stake, {}). "
                [dptf-id amount pool-id (UC_ShortAccount owner-id)]
            )
            (format "Successfully unstaked TrueFungible {} amount {} from Pool {} for beneficiary {} (owner {}). "
                [dptf-id amount pool-id (UC_ShortAccount beneficiary-id) (UC_ShortAccount owner-id)]
            )
        )
    )
    (defun UC_FormatStakeOrtoFungibleResult:string
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonce-count:integer)
        @doc "Stake OF success text (whole-nonce Transfer)."
        (if (= owner-id beneficiary-id)
            (format "Successfully staked OrtoFungible {} ({} whole nonces) into Pool {} (self-stake, {}). "
                [
                    dpof-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount owner-id)
                ]
            )
            (format "Successfully staked OrtoFungible {} ({} whole nonces) into Pool {} for beneficiary {} (owner {}). "
                [
                    dpof-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount beneficiary-id)
                    (UC_ShortAccount owner-id)
                ]
            )
        )
    )
    (defun UC_FormatUnstakeOrtoFungibleResult:string
        (pool-id:string owner-id:string dpof-id:string nonce-count:integer)
        @doc "Unstake OF success text; beneficiary resolved from tracker in sovereign phase 1."
        (format "Successfully unstaked OrtoFungible {} ({} whole nonces) from Pool {} (owner {}). "
            [
                dpof-id
                nonce-count
                pool-id
                (UC_ShortAccount owner-id)
            ]
        )
    )
    (defun UC_FormatStakeCollectableResult:string
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce-count:integer
        )
        @doc "Stake collectable success text."
        (if (= owner-id beneficiary-id)
            (format "Successfully staked {} {} ({} nonces) into Pool {} (self-stake, {}). "
                [
                    (if son "DPSF" "DPNF")
                    collectable-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount owner-id)
                ]
            )
            (format "Successfully staked {} {} ({} nonces) into Pool {} for beneficiary {} (owner {}). "
                [
                    (if son "DPSF" "DPNF")
                    collectable-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount beneficiary-id)
                    (UC_ShortAccount owner-id)
                ]
            )
        )
    )
    (defun UC_FormatUnstakeCollectableResult:string
        (pool-id:string owner-id:string collectable-id:string son:bool nonce-count:integer)
        @doc "Unstake collectable success text."
        (format "Successfully unstaked {} {} ({} nonces) from Pool {} (owner {}). "
            [
                (if son "DPSF" "DPNF")
                collectable-id
                nonce-count
                pool-id
                (UC_ShortAccount owner-id)
            ]
        )
    )
    (defun UC_FormatVacateCollectableResult:string
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce-count:integer
        )
        @doc "Vacate collectable success text (pool-owner forced unstake)."
        (format "Successfully vacated {} {} ({} nonces) from Pool {} (owner {} → beneficiary {}). "
            [
                (if son "DPSF" "DPNF")
                collectable-id
                nonce-count
                pool-id
                (UC_ShortAccount owner-id)
                (UC_ShortAccount beneficiary-id)
            ]
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;ADDED 2026-09-19. The generic-vault cost reader. It lives HERE, under {5.3} Read, and not
    ;;beside the client function it prices: URCi_ is a reader, and the canonical section order
    ;;puts every UR/URC/URH/URCi/INFO in this block regardless of what consumes it.
    (defun URCi_IssueGenericEarningVault:object{IgnisCollectorV3.OutputCumulator}
        (owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
        @doc "Cost reader for AQP-FVT|C_IssueGenericEarningVault: the six component cumulators, \
            \ concatenated exactly as the operation concatenates them."
        ;;WHY IT COMPOSES RATHER THAN NAMING A PRICE. The operation is six core calls; its cost is
        ;;whatever those six cost. Writing a standalone price here would be a SECOND definition of
        ;;the same number, free to drift from the first -- the failure this codebase has found in
        ;;its own artefacts repeatedly. Concatenating the same six readers the operation's own
        ;;cumulators come from means the preview cannot disagree with the charge by construction.
        ;;
        ;;The component readers live in four different modules, and two of them are on RPS rather
        ;;than FVT (AddScoreEntity, AddRewardLink) -- which is worth knowing, because looking for
        ;;them on FVT beside the ops they price finds nothing.
        (let*
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                ;;
                (score-name:string (concat [vault-name "Score"]))
                (pool-name:string (concat [vault-name "Pool"]))
                (fvt-name:string (concat [vault-name "Vault"]))
                (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                (pool-id:string (ref-U|DALOS::UDC_Makeid pool-name))
                (fvt-id:string (ref-U|DALOS::UDC_Makeid fvt-name))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-SCR::URCi_IssueScore owner-konto [score-id])
                    (ref-AQP::URCi_Issue [pool-id])
                    (ref-AQP::URCi_AddScore [pool-id score-id])
                    (ref-FVT::URCi_Issue owner-konto [fvt-id])
                    ;;THE LAST TWO ARE BUILT HERE RATHER THAN CALLED, and the reason is specific.
                    ;;RPS::URCi_AddScoreEntity and URCi_AddRewardLink resolve their active-account
                    ;;with `UR_FVT|OwnerKonto fvt-id` -- a READ of the FVT row. For a PREVIEW of a
                    ;;vault that does not exist yet, that row is absent and the reader aborts:
                    ;;  No value found in table RPS_FVT|T|RewardAggregate for key: <name>Vault-...
                    ;;A cost preview for a CREATION operation cannot depend on reading the thing it
                    ;;is about to create. (Found by running it; the RT-K family is about exactly
                    ;;this class of preview/exec divergence.)
                    ;;
                    ;;The PRICE is not the problem -- it is static, from the same price-table keys
                    ;;below. Only the active-account came from the row, and here it is `owner-konto`,
                    ;;which the caller supplies. So these two use the identical UC_IgnisPrice keys
                    ;;and substitute the account. No price is restated; nothing can drift.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "AQP-FVT|C_AddScoreEntity" "add-score-entity")
                        owner-konto (ref-IGNIS::URC_IsVirtualGasZero) [fvt-id score-id])
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "AQP-FVT|C_AddRewardLink" "add-reward-link")
                        owner-konto (ref-IGNIS::URC_IsVirtualGasZero)
                        [fvt-id reward-dptf-id GV|COMMON_BAR])
                ]
                []
            )
        )
    )


    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|CC_VacateTrueFungible:string
        (patron:string executor:string pool-id:string)
        @doc "Vacate rehaul — pool-owner vacate of a pool's TrueFungible leg only (one tx; used standalone or by \
            \ the agnostic CC_FullVacate for a class-1 TF+OF pool). Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateTrueFungible executor pool-id))
                (format "Successfully vacated the TrueFungible leg of Pool {}." [pool-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|CC_VacateOrtoFungible:string
        (patron:string executor:string pool-id:string dpof-id:string)
        @doc "Vacate rehaul — pool-owner vacate of ONE OrtoFungible asset of a pool (one tx; standalone or per \
            \ class-1 satellite). Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateOrtoFungible patron executor pool-id dpof-id))
                (format "Successfully vacated OrtoFungible {} of Pool {}." [dpof-id pool-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|CC_VacateSemiFungible:string
        (patron:string executor:string pool-id:string dpsf-id:string)
        @doc "Vacate rehaul — pool-owner vacate of the DPSF (semi-fungible) collection of a class-3 pool (one tx). \
            \ Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateSemiFungible executor pool-id dpsf-id))
                (format "Successfully vacated SemiFungible {} of Pool {}." [dpsf-id pool-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|CC_VacateNonFungible:string
        (patron:string executor:string pool-id:string dpnf-id:string)
        @doc "Vacate rehaul — pool-owner vacate of the DPNF (non-fungible) collection of a class-4 pool (one tx). \
            \ Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateNonFungible executor pool-id dpnf-id))
                (format "Successfully vacated NonFungible {} of Pool {}." [dpnf-id pool-id])
            )
        )
    )
    (defun AQP-DSA|C_DefineDelegationVault:string
        (patron:string executor:string fvt-id:string model-id:string unit-score:integer)
        @doc "DSA (Talos): bind a class-0 FVT as a delegation vault (score-entity model + unit-score); collects \
            \ IGNIS on patron. Only the FVT owner may run it."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DSA::C_DefineDelegationVault patron executor fvt-id model-id unit-score)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "DSA vault defined on FVT {} (model {}, unit-score {})." [fvt-id model-id unit-score])
            )
        )
    )
    (defun AQP-DSA|C_SetOracleAuth:string
        (patron:string executor:string fvt-id:string oracle-guard:guard)
        @doc "DSA (Talos): owner authorizes the delegated oracle key for a vault + arms the 25h capture expiry; \
            \ collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DSA::C_SetOracleAuth patron executor fvt-id oracle-guard)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Oracle authority set + oracle-on armed on FVT {}." [fvt-id])
            )
        )
    )
    (defun AQP-DSA|C_OracleWrite:string
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "DSA (Talos): the delegated oracle writes an agency's daily {nodes, uptime} + recomputes its capture \
            \ (fresh oracle-ts); collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DSA::C_OracleWrite patron fvt-id score-entity-id nodes uptime)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Oracle wrote nodes {} / uptime {}‰ for agency {}." [nodes uptime score-entity-id])
            )
        )
    )
    (defun AQP-DSA|C_WithdrawRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
        @doc "DSA (Talos): the FVT owner withdraws the whole royalty pool of <reward-dptf-id> on vault <fvt-id> to \
            \ the owner konto; collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DSA::C_WithdrawRoyalty patron executor fvt-id reward-dptf-id)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Royalty pool of {} on FVT {} withdrawn to the owner." [reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-DSA|C_BurnRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
        @doc "DSA (Talos): the FVT owner BURNS the whole royalty pool of <reward-dptf-id> on vault <fvt-id>; \
            \ collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DSA::C_BurnRoyalty patron executor fvt-id reward-dptf-id)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Royalty pool of {} on FVT {} burned." [reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-DSA|C_FuelRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "DSA (Talos): the FVT owner FUELS <swpair> with the whole royalty pool of <reward-dptf-id> on vault \
            \ <fvt-id> (adds liquidity, no LP mint); collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DSA::C_FuelRoyalty patron executor fvt-id reward-dptf-id swpair)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Royalty pool of {} on FVT {} fueled into swpair {}." [reward-dptf-id fvt-id swpair])
            )
        )
    )
    (defun AQP-DSA|C_SetAgencyFee:string
        (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "DSA (Talos): the FVT owner changes a delegation agency's operator fee (reprices only future injects); \
            \ collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DSA::C_SetAgencyFee patron executor fvt-id score-entity-id fee-per-mille)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Agency {} fee set to {} per-mille." [score-entity-id fee-per-mille])
            )
        )
    )
    (defun AQP-DSA|A_ToggleExternalOracle:string (patron:string executor:string on:bool)
        @doc "DSA (Talos): MODULE ADMIN (GOV) flip of the SINGULAR GLOBAL external-oracle switch for ALL agencies. \
            \ No IGNIS billing (pure governance, master-signed, no OutputCumulator)."
        (with-capability (P|TS)
            (let
                (
                    (ref-DSA:module{DsaV1} AQP-DSA)
                )
                (ref-DSA::A_ToggleExternalOracle patron executor on)
                (format "Global external-oracle switch set to {}." [on])
            )
        )
    )
    (defun AQP-DSA|A_SetOracleValidity:string (patron:string executor:string seconds:integer)
        @doc "DSA (Talos): MODULE ADMIN (GOV) set of the GLOBAL oracle-validity window (freshness horizon, seconds). \
            \ No IGNIS billing (pure governance, master-signed, no OutputCumulator)."
        (with-capability (P|TS)
            (let
                (
                    (ref-DSA:module{DsaV1} AQP-DSA)
                )
                (ref-DSA::A_SetOracleValidity patron executor seconds)
                (format "Global oracle-validity window set to {} seconds." [seconds])
            )
        )
    )
    ;;
    (defun AQP-ANK|C_RevokeBoostClass:string
        (patron:string executor:string boost-class-id:string)
        @doc "Revokes an empty BoostClass."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ANK::C_RevokeBoostClass patron executor boost-class-id)
                )
                (format "Successfully revoked BoostClass {}." [boost-class-id])
            )
        )
    )
    (defun AQP-ANK|C_IssueTrueFungibleAnchor:string
        (patron:string executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Issues a DPTF Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ANK::C_IssueTrueFungibleAnchor 
                            patron executor anchor-name dptf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dptf-amount
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (if acnoi
                    (format "Successfully issued TrueFungible Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dptf-id])
                    (format "Successfully issued TrueFungible Anchor {} for {}." [anchor-id dptf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_IssueSemiFungibleAnchor:string
        (patron:string executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Issues a DPSF Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ANK::C_IssueSemiFungibleAnchor 
                            patron executor anchor-name dpsf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpsf-nonce
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (if acnoi
                    (format "Successfully issued SemiFungible Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dpsf-id])
                    (format "Successfully issued SemiFungible Anchor {} for {}." [anchor-id dpsf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_IssueNonFungibleAnchor:string
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Issues a DPNF trait-Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ANK::C_IssueNonFungibleAnchor 
                            patron executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-trait-key dpnf-trait-value
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (if acnoi
                    (format "Successfully issued NonFungible Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dpnf-id])
                    (format "Successfully issued NonFungible Anchor {} for {}." [anchor-id dpnf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_IssueNonFungibleSetAnchor:string
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Issues a DPNF set-Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ANK::C_IssueNonFungibleSetAnchor
                            patron executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-nonce-class
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (if acnoi
                    (format "Successfully issued NonFungible Set Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dpnf-id])
                    (format "Successfully issued NonFungible Set Anchor {} for {}." [anchor-id dpnf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_RevokeAnchor:string (patron:string executor:string anchor-id:string)
        @doc "Revokes an existing Anchor, removing it from its BoostClass and AssetAnchors bookkeeping."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                )
                (ref-IGNIS::XE_CollectIgnis patron 
                    (ref-ANK::C_RevokeAnchor patron executor anchor-id)
                )
                (format "Successfully revoked Anchor {}." [anchor-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueLiquidityScore:string
        (patron:string executor:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Issues score-class 0 (LP) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SCR::C_IssueLiquidityScore patron executor score-name precision lp-denominator mx-frozen mx-sleeping)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED score-id, not `score-name`. The name is the caller's own
                ;;INPUT -- echoing it tells them nothing they did not already type, while the id
                ;;(`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) is the only thing the transaction
                ;;produced and the key every later op takes. The core already threaded it out via
                ;;`URCi_IssueScore executor [score-id]`; this just stopped throwing it away.
                ;;StoicSyntax 2.16.2.
                (format "Successfully issued Liquidity Score {} for owner {}." [(at 0 (at "output" ico)) executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueTrueFungibleScore:string
        (patron:string executor:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Issues score-class 1 (DPTF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SCR::C_IssueTrueFungibleScore patron executor score-name precision mx-frozen)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED score-id, not `score-name`. The name is the caller's own
                ;;INPUT -- echoing it tells them nothing they did not already type, while the id
                ;;(`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) is the only thing the transaction
                ;;produced and the key every later op takes. The core already threaded it out via
                ;;`URCi_IssueScore executor [score-id]`; this just stopped throwing it away.
                ;;StoicSyntax 2.16.2.
                (format "Successfully issued TrueFungible Score {} for owner {}." [(at 0 (at "output" ico)) executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueOrtoFungibleScore:string
        (patron:string executor:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Issues score-class 2 (DPOF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SCR::C_IssueOrtoFungibleScore patron executor score-name precision mx-sleeping mx-hibernated)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED score-id, not `score-name`. The name is the caller's own
                ;;INPUT -- echoing it tells them nothing they did not already type, while the id
                ;;(`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) is the only thing the transaction
                ;;produced and the key every later op takes. The core already threaded it out via
                ;;`URCi_IssueScore executor [score-id]`; this just stopped throwing it away.
                ;;StoicSyntax 2.16.2.
                (format "Successfully issued OrtoFungible Score {} for owner {}." [(at 0 (at "output" ico)) executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueSemiFungibleScore:string
        (patron:string executor:string score-name:string precision:integer sft-equality:bool)
        @doc "Issues score-class 3 (DPSF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SCR::C_IssueSemiFungibleScore patron executor score-name precision sft-equality)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED score-id, not `score-name`. The name is the caller's own
                ;;INPUT -- echoing it tells them nothing they did not already type, while the id
                ;;(`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) is the only thing the transaction
                ;;produced and the key every later op takes. The core already threaded it out via
                ;;`URCi_IssueScore executor [score-id]`; this just stopped throwing it away.
                ;;StoicSyntax 2.16.2.
                (format "Successfully issued SemiFungible Score {} for owner {}." [(at 0 (at "output" ico)) executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleScore:string
        (patron:string executor:string score-name:string precision:integer nft-score-model:integer)
        @doc "Issues score-class 4 (DPNF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SCR::C_IssueNonFungibleScore patron executor score-name precision nft-score-model)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED score-id, not `score-name`. The name is the caller's own
                ;;INPUT -- echoing it tells them nothing they did not already type, while the id
                ;;(`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) is the only thing the transaction
                ;;produced and the key every later op takes. The core already threaded it out via
                ;;`URCi_IssueScore executor [score-id]`; this just stopped throwing it away.
                ;;StoicSyntax 2.16.2.
                (format "Successfully issued NonFungible Score {} for owner {}." [(at 0 (at "output" ico)) executor])
            )
        )
    )
    (defun AQP-SCR|C_RotateScoreOwnership:string (patron:string executor:string executee:string score-id:string)
        @doc "Rotates score ownership in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_RotateOwnership patron executor executee score-id))
                (format "Successfully rotated ownership for score {} to {}." [score-id executee])
            )
        )
    )
    (defun AQP-SCR|C_ControlScore:string (patron:string executor:string score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Updates score control flags in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_Control patron executor score-id new-can-upgrade new-can-change-owner)
                )
                (format "Successfully updated control flags for score {}." [score-id])
            )
        )
    )
    (defun AQP-SCR|C_CreateScoreBoostClassLink:string (patron:string executor:string score-id:string boost-class-id:string)
        @doc "Creates score -> boost-class link in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_CreateBoostClassLink patron executor score-id boost-class-id))
                (format "Successfully linked score {} to BoostClass {}." [score-id boost-class-id])
            )
        )
    )
    (defun AQP-SCR|C_CreateScoreBoostLink:string (patron:string executor:string score-id:string boost-score-id:string)
        @doc "Creates score -> boost-score link in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_CreateBoostLink patron executor score-id boost-score-id))
                (format "Successfully linked score {} to boost score {}." [score-id boost-score-id])
            )
        )
    )
    (defun AQP-SCR|C_EnableDebBoost:string (patron:string executor:string score-id:string)
        @doc "Enables irreversible DEB boost on the score row. Medium IGNIS cost; no native STOA."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_EnableDebBoost patron executor score-id))
                (format "Successfully enabled DEB boost for score {}." [score-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueTriplet:string
        (patron:string executor:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Issues SCR triplet bundle T|bronze|silver|golden and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SCR::C_IssueTriplet patron executor bronze-score-id silver-score-id golden-score-id)
                    )
                    (out:[string] (at "output" ico))
                    (triplet-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Successfully issued triplet {}." [triplet-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueSingleScoreModel:string
        (patron:string executor:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal] boost-class-id:string)
        @doc "Defines a SINGLE score-entity model in AQP-SCORE and collects IGNIS on patron. Returns the model-id."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SCR::C_IssueSingleScoreModel patron executor model-name score-class collectable-id precision nonces nonce-score-values boost-class-id)
                    )
                    (model-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Successfully defined single score-entity model {}." [model-id])
            )
        )
    )
    (defun AQP-SCR|C_CombineTripletScoreModel:string
        (patron:string executor:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
        @doc "Combines three single models into a TRIPLET score-entity model in AQP-SCORE and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SCR::C_CombineTripletScoreModel patron executor model-name bronze-model-id silver-model-id golden-model-id)
                    )
                    (model-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Successfully combined triplet score-entity model {}." [model-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueScoreFromModel:string (patron:string executor:string model-id:string agency-name:string)
        @doc "FACTORY (Talos): issue a conforming score entity from <model-id> for executor; collects IGNIS on \
            \ patron. Returns the (score | triplet) id."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SCR::C_IssueScoreFromModel patron executor model-id agency-name)
                    )
                    (entity-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Successfully issued score entity {} from model {}." [entity-id model-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueSemiFungibleScoreDefinition:string
        (patron:string executor:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Writes DPSF nonce score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                ;;DEAD-DEFINITION GUARD (StoicSyntax 2.16, 2026-10-06). If this score is already
                ;;employed by a pool, the collection being defined must be the one that pool
                ;;stakes -- otherwise the rows save cleanly and score nothing forever. No-op
                ;;while aqpool-link is BAR, which is the normal state at definition time.
                ;;Here rather than in AQP-SCORE because the pool fact lives one module LATER in
                ;;deploy order: AQP-SCORE cannot reference AQP-POOL, only the reverse.
                (ref-AQP::UEV_ScoreDefinitionTargetMatchesPool score-id dpsf-id)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueSemiFungibleScoreDefinition patron executor score-id dpsf-id nonces nonce-score-values)
                )
                (format "Successfully issued SemiFungible score definitions for score {} and dpsf-id {}." [score-id dpsf-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleScoreDefinition:string
        (patron:string executor:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Writes DPNF trait score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                ;;DEAD-DEFINITION GUARD (StoicSyntax 2.16, 2026-10-06). If this score is already
                ;;employed by a pool, the collection being defined must be the one that pool
                ;;stakes -- otherwise the rows save cleanly and score nothing forever. No-op
                ;;while aqpool-link is BAR, which is the normal state at definition time.
                ;;Here rather than in AQP-SCORE because the pool fact lives one module LATER in
                ;;deploy order: AQP-SCORE cannot reference AQP-POOL, only the reverse.
                (ref-AQP::UEV_ScoreDefinitionTargetMatchesPool score-id dpnf-id)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueNonFungibleScoreDefinition patron executor score-id dpnf-id trait-keys trait-values trait-score-values)
                )
                (format "Successfully issued NonFungible score definitions for score {} and dpnf-id {}." [score-id dpnf-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleSetScoreDefinition:string
        (patron:string executor:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Writes DPNF set-mode (nonce-class) score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                ;;DEAD-DEFINITION GUARD (StoicSyntax 2.16, 2026-10-06). If this score is already
                ;;employed by a pool, the collection being defined must be the one that pool
                ;;stakes -- otherwise the rows save cleanly and score nothing forever. No-op
                ;;while aqpool-link is BAR, which is the normal state at definition time.
                ;;Here rather than in AQP-SCORE because the pool fact lives one module LATER in
                ;;deploy order: AQP-SCORE cannot reference AQP-POOL, only the reverse.
                (ref-AQP::UEV_ScoreDefinitionTargetMatchesPool score-id dpnf-id)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueNonFungibleSetScoreDefinition patron executor score-id dpnf-id dpnf-nonce-classes class-score-values)
                )
                (format "Successfully issued NonFungible set score definitions for score {} and dpnf-id {}." [score-id dpnf-id])
            )
        )
    )
    (defun AQP-POOL|C_Issue:string
        (patron:string executor:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Issues an acquisition pool (aqp-class + canonical native asset-id) and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-AQP::C_Issue patron executor pool-name asset-id aqp-class)
                    )
                    (out:[string] (at "output" ico))
                    (pool-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully issued Acquisition Pool {} (class {} for asset {})." [pool-id aqp-class asset-id])
            )
        )
    )
    (defun AQP-POOL|C_AddScore:string
        (patron:string executor:string pool-id:string score-id:string)
        @doc "Assigns score-id to the first free slot on pool-id; collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_AddScore patron executor pool-id score-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully assigned Score {} to Pool {}." [score-id pool-id])
            )
        )
    )
    (defun AQP-POOL|C_RevokeScore:string
        (patron:string executor:string pool-id:string score-id:string)
        @doc "Revokes score-id from pool-id (compact slots, clear aqpool-link); collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_RevokeScore patron executor pool-id score-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully revoked Score {} from Pool {}." [score-id pool-id])
            )
        )
    )
    (defun AQP-POOL|C_DisablePoolStake:string
        (patron:string executor:string pool-id:string)
        @doc "Pool owner pauses new stakes (stake-enabled → false); collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_DisablePoolStake patron executor pool-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully disabled staking on Pool {}." [pool-id])
            )
        )
    )
    (defun AQP-POOL|C_EnablePoolStake:string
        (patron:string executor:string pool-id:string)
        @doc "Pool owner re-enables new stakes (stake-enabled → true); collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_EnablePoolStake patron executor pool-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully enabled staking on Pool {}." [pool-id])
            )
        )
    )
    ;;
    (defun AQP-POOL|CC_StakeTrueFungible:string
        (patron:string executor:string executee:string pool-id:string dptf-id:string amount:decimal)
        @doc "Stake DPTF (or native|F| LP) into pool-id. Talos client shell: event cap + FVT::CC_TrueFungibleStakeFlow direction=true."
        (with-capability (AQP|C>STAKE-TRUE-FUNGIBLE patron pool-id executor executee dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_TrueFungibleStakeFlow patron executor executee pool-id dptf-id amount true)
                )
                (UC_FormatStakeTrueFungibleResult pool-id executor executee dptf-id amount)
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeTrueFungible:string
        (patron:string executor:string executee:string pool-id:string dptf-id:string amount:decimal)
        @doc "Unstake DPTF from pool-id. Talos client shell: event cap + FVT::CC_TrueFungibleStakeFlow direction=false."
        (with-capability (AQP|C>UNSTAKE-TRUE-FUNGIBLE patron pool-id executor executee dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_TrueFungibleStakeFlow patron executor executee pool-id dptf-id amount false)
                )
                (UC_FormatUnstakeTrueFungibleResult pool-id executor executee dptf-id amount)
            )
        )
    )
    (defun AQP-POOL|CC_StakeOrtoFungible:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            dpof-id:string
            nonces:[integer]
        )
        @doc "Stake whole DPOF nonces via C_Transfer. Poll DPOF::UR_NoncesSupplies, then @event cap with resolved legs."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>STAKE-ORTO-FUNGIBLE patron pool-id executor executee dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_OrtoFungibleStakeFlow
                            patron executor executee pool-id dpof-id nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeOrtoFungibleResult pool-id executor executee dpof-id nonce-count)
                )
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeOrtoFungible:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            dpof-id:string
            nonces:[integer]
        )
        @doc "Unstake whole DPOF nonces via C_Transfer from the (owner, beneficiary) row. M5: executee is \
            \ caller-supplied (self OR foreign) so the exact staked row is located — mirrors TF. Poll UR_NoncesSupplies, \
            \ then @event cap with resolved legs."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>UNSTAKE-ORTO-FUNGIBLE patron pool-id executor executee dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_OrtoFungibleStakeFlow
                            patron executor executee pool-id dpof-id nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeOrtoFungibleResult pool-id executor dpof-id nonce-count)
                )
            )
        )
    )
    ;;
    (defun AQP-POOL|CC_StakeSemiFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
        )
        @doc "Stake DPSF collectable (son=true). Poll DPDC::UR_AccountNoncesSupplies, then FVT::CC_CollectableStakeFlow."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[integer] (ref-DPDC::UR_AccountNoncesSupplies executor collectable-id true nonces))
            )
            (with-capability
                (AQP|C>STAKE-SEMI-FUNGIBLE-COLLECTABLE
                    patron pool-id executor executee collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            patron executor executee pool-id collectable-id true nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeCollectableResult
                        pool-id executor executee collectable-id true nonce-count
                    )
                )
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeSemiFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Unstake DPSF collectable (son=true) from the (owner, beneficiary) row. M5: executee caller-supplied \
            \ (self OR foreign) so the exact staked row is located — mirrors TF."
        (let
            (
                (nonce-count:integer (length nonces))
            )
            (with-capability
                (AQP|C>UNSTAKE-SEMI-FUNGIBLE-COLLECTABLE
                    patron pool-id executor executee collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            patron executor executee pool-id collectable-id true nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeCollectableResult pool-id executor collectable-id true nonce-count)
                )
            )
        )
    )
    (defun AQP-POOL|CC_StakeNonFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
        )
        @doc "Stake DPNF collectable (son=false). Poll DPDC::UR_AccountNoncesSupplies, then FVT::CC_CollectableStakeFlow."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[integer] (ref-DPDC::UR_AccountNoncesSupplies executor collectable-id false nonces))
            )
            (with-capability
                (AQP|C>STAKE-NON-FUNGIBLE-COLLECTABLE
                    patron pool-id executor executee collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            patron executor executee pool-id collectable-id false nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeCollectableResult
                        pool-id executor executee collectable-id false nonce-count
                    )
                )
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeNonFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Unstake DPNF collectable (son=false) from the (owner, beneficiary) row. M5: executee caller-supplied \
            \ (self OR foreign) so the exact staked row is located — mirrors TF."
        (let
            (
                (nonce-count:integer (length nonces))
            )
            (with-capability
                (AQP|C>UNSTAKE-NON-FUNGIBLE-COLLECTABLE
                    patron pool-id executor executee collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            patron executor executee pool-id collectable-id false nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeCollectableResult pool-id executor collectable-id false nonce-count)
                )
            )
        )
    )
    ;;
    ;; Vacate — Full (1 tx) or Stateless Legs (N txs; auto-begin; finalize on last)
    ;;
    (defun AQP-POOL|C_AbortVacate:string
        (patron:string executor:string pool-id:string)
        @doc "Clear vacate-in-progress; stake stays disabled. Talos → AQP-VCT::C_AbortVacate."
        (with-capability (AQP|C>ABORT-VACATE patron pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::C_AbortVacate patron executor pool-id)
                )
                (format "Successfully aborted vacate-in-progress on Pool {} (stake remains disabled)."
                    [pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_FinalizeVacate:string
        (patron:string executor:string pool-id:string)
        @doc "Vacate-v2 FINALIZE (nuke) — after a pool has been fully drained via AQP-POOL|Cp_BatchDrain*, this \
            \ bulk-zeroes every employed score + bumps their vacate-generation (lazily invalidating all per-user \
            \ rows), then clears vacate-in-progress, re-enables stake, and unfreezes the pool's FVTs. Pool-owner + \
            \ nns==0 gated in VCT; IGNIS on patron. The commit-forward terminal step of a v2 drain campaign."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::C_FinalizeVacate patron executor pool-id))
                (format "Successfully finalized vacate on Pool {} — scores nuked, stake re-enabled." [pool-id])
            )
        )
    )
    (defun AQP-POOL|CC_FullVacate:string
        (patron:string executor:string pool-id:string)
        @doc "Vacate rehaul — pool-owner AGNOSTIC full vacate (one tx): input is JUST the pool-id. VCT reads the \
            \ pool class + scans its inventory on-chain and vacates every asset type. Owner enforced in VCT|C>VACATE; \
            \ collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::CC_FullVacate patron executor pool-id))
                (format "Successfully full-vacated Pool {} (all asset types)." [pool-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchVacateTrueFungible:string
        (patron:string pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal])
        @doc "One TF batch of a UI-sliced vacate campaign. The first successful batch freezes the pool + its FVTs; \
            \ the batch that empties the pool auto-finalizes/unfreezes. Owner enforced in VCT; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchVacateTrueFungible pool-id dptf-id owner-ids beneficiary-ids amounts))
                (format "Batch-vacated {} TF leg(s) on Pool {} (asset {})." [(length owner-ids) pool-id dptf-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchDrainTrueFungible:string
        (patron:string pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal])
        @doc "Vacate-v2 FAST-DRAIN — one TF batch that returns assets + preserves rewards WITHOUT touching scores \
            \ and WITHOUT finalizing (cheaper than CCp_BatchVacateTrueFungible for large pools). First batch freezes \
            \ the pool + its FVTs; the pool stays frozen until AQP-POOL|C_FinalizeVacate nukes the scores once \
            \ empty. Owner enforced in VCT; IGNIS on patron. Commit-forward — CCp_BatchVacateTrueFungible is the \
            \ abortable path."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchDrainTrueFungible pool-id dptf-id owner-ids beneficiary-ids amounts))
                (format "Fast-drained {} TF leg(s) on Pool {} (asset {}) — scores untouched, awaiting finalize."
                    [(length owner-ids) pool-id dptf-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchDrainOrtoFungible:string
        (patron:string pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "Vacate-v2 FAST-DRAIN — one OF batch that returns nonces + preserves rewards WITHOUT touching scores \
            \ and WITHOUT finalizing. Amounts resolved on-chain from the tracker. First batch freezes the pool + \
            \ its FVTs; it stays frozen until AQP-POOL|C_FinalizeVacate nukes the scores once empty. Owner enforced \
            \ in VCT; IGNIS on patron. Commit-forward — CCp_BatchVacateOrtoFungible is the abortable path."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchDrainOrtoFungible patron pool-id dpof-id owner-ids beneficiary-ids nonces-array))
                (format "Fast-drained {} OF leg(s) on Pool {} (asset {}) — scores untouched, awaiting finalize."
                    [(length owner-ids) pool-id dpof-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchDrainCollectable:string
        (patron:string pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]])
        @doc "Vacate-v2 FAST-DRAIN — one DPSF (son=true) / DPNF (son=false) batch that returns nonces + preserves \
            \ rewards WITHOUT touching scores and WITHOUT finalizing. First batch freezes the pool + its FVTs; it \
            \ stays frozen until AQP-POOL|C_FinalizeVacate nukes the scores once empty. Owner enforced in VCT; \
            \ IGNIS on patron. Commit-forward — CCp_BatchVacateCollectables is the abortable path."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchDrainCollectable pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array))
                (format "Fast-drained {} collectable leg(s) on Pool {} (asset {}, son {}) — scores untouched, awaiting finalize."
                    [(length owner-ids) pool-id collectable-id son])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchVacateOrtoFungible:string
        (patron:string pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "One OF batch of a UI-sliced vacate campaign (amounts resolved on-chain from the tracker). First batch \
            \ freezes; the emptying batch auto-finalizes/unfreezes. Owner enforced in VCT; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchVacateOrtoFungible patron pool-id dpof-id owner-ids beneficiary-ids nonces-array))
                (format "Batch-vacated {} OF leg(s) on Pool {} (asset {})." [(length owner-ids) pool-id dpof-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchVacateCollectables:string
        (patron:string pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]])
        @doc "One DPSF (son=true) / DPNF (son=false) batch of a UI-sliced vacate campaign. First batch freezes; the \
            \ emptying batch auto-finalizes/unfreezes. Owner enforced in VCT; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchVacateCollectables pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array))
                (format "Batch-vacated {} collectable leg(s) on Pool {} (asset {}, son {})."
                    [(length owner-ids) pool-id collectable-id son])
            )
        )
    )
    (defun AQP-POOL|C_SyncTrueFungibleAnchors:string
        (patron:string executee:string dptf-id:string)
        @doc "Pool-agnostic TF anchor repair for beneficiary × dptf-id. Talos shell → AQP-POOL::C_SyncTrueFungibleAnchors."
        (with-capability (AQP|C>SYNC-TF-ANCHORS patron executee dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_SyncTrueFungibleAnchors patron executee dptf-id)
                )
                (format "Successfully synced TrueFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount executee) dptf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncSemiFungibleAnchors:string
        (patron:string executee:string dpsf-id:string)
        @doc "Pool-agnostic DPSF anchor repair. Talos shell → AQP-POOL::C_SyncCollectableAnchors son=true."
        (with-capability (AQP|C>SYNC-SEMI-FUNGIBLE-ANCHORS patron executee dpsf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_SyncCollectableAnchors patron executee dpsf-id true)
                )
                (format "Successfully synced SemiFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount executee) dpsf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncNonFungibleAnchors:string
        (patron:string executee:string dpnf-id:string)
        @doc "Pool-agnostic DPNF anchor repair. Talos shell → AQP-POOL::C_SyncCollectableAnchors son=false."
        (with-capability (AQP|C>SYNC-NON-FUNGIBLE-ANCHORS patron executee dpnf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_SyncCollectableAnchors patron executee dpnf-id false)
                )
                (format "Successfully synced NonFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount executee) dpnf-id]
                )
            )
        )
    )
    ;;
    ;; --- AQP-FVT lifecycle (Talos client shell → AQP-FVT::C_*) ---
    (defun AQP-FVT|C_Issue:string
        (patron:string executor:string fvt-name:string fvt-class:integer common-denominator:string)
        @doc "Issues an FVT (farm/vault/treasury) and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-FVT::C_Issue patron executor fvt-name fvt-class common-denominator)
                    )
                    (out:[string] (at "output" ico))
                    (fvt-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully issued FVT {} (class {})." [fvt-id fvt-class])
            )
        )
    )
    (defun AQP-FVT|C_IssueMultipletFamily:string
        (
            patron:string
            executor:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "Issues chain-wide MultipletFamily F|t0|t1|t2 (rank 3) with ATS ladder validation."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-FVT::C_IssueMultipletFamily
                            patron executor token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id
                        )
                    )
                    (out:[string] (at "output" ico))
                    (family-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully issued MultipletFamily {}." [family-id])
            )
        )
    )
    (defun AQP-FVT|C_AddScoreEntity:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Admits score (type 1) or triplet (type 3) to fvt-id via ScoreEntityLink."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_AddScoreEntity patron executor fvt-id score-entity-type score-entity-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully added score-entity type {} id {} to FVT {}."
                    [score-entity-type score-entity-id fvt-id]
                )
            )
        )
    )
    (defun AQP-FVT|C_AddRewardLink:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Registers one reward DPTF on fvt-id (multiplet-family-id BAR for plain tokens). Collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_AddRewardLink patron executor fvt-id reward-dptf-id segmentation multiplet-family-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully added reward link {} on FVT {} (family={})."
                    [reward-dptf-id fvt-id multiplet-family-id]
                )
            )
        )
    )
    (defun AQP-FVT|C_ToggleScoreEntityLink:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Toggles ScoreEntityLink.enabled and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_ToggleScoreEntityLink patron executor fvt-id score-entity-type score-entity-id enabled)
                )
                (format "Successfully toggled score-entity type {} id {} on FVT {} to enabled={}."
                    [score-entity-type score-entity-id fvt-id enabled]
                )
            )
        )
    )
    (defun AQP-FVT|C_ToggleRewardLink:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Toggles reward-enabled and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_ToggleRewardLink patron executor fvt-id reward-dptf-id enabled)
                )
                (format "Successfully toggled reward link {} on FVT {} to enabled={}." [reward-dptf-id fvt-id enabled])
            )
        )
    )
    (defun AQP-FVT|C_SetQualitySplit:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Round B: set a MULTIPLET_BASE reward's quality-split MODE + heterogeneous MATRIX (owner-gated). \
            \ HOMOGENEOUS routes each lane to its one ladder token; HETEROGENEOUS splits each lane across all 3 \
            \ ladder tokens per its [to-t0 to-t1 to-t2] per-mille row. Collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_SetQualitySplit patron executor fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
                )
                (format "Successfully set quality split mode={} on reward {} of FVT {}." [mode reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-FVT|C_Control:string
        (patron:string executor:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Updates FVT control flags and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_Control patron executor fvt-id new-can-upgrade new-can-change-owner)
                )
                (format "Successfully updated control flags for FVT {}." [fvt-id])
            )
        )
    )
    (defun AQP-FVT|C_RotateOwnership:string
        (patron:string executor:string executee:string fvt-id:string)
        @doc "Rotates FVT ownership and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_RotateOwnership patron executor executee fvt-id)
                )
                (format "Successfully rotated ownership for FVT {} to {}." [fvt-id executee])
            )
        )
    )
    (defun AQP-FVT|C_SetCommonDenominator:string
        (patron:string executor:string fvt-id:string common-denominator:string)
        @doc "Sets farm common-denominator (before ScoreEntityLinks) and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_SetCommonDenominator patron executor fvt-id common-denominator)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully set common-denominator on FVT {} to {}." [fvt-id common-denominator])
            )
        )
    )
    (defun AQP-FVT|C_SetMosaic:string
        (patron:string executor:string fvt-id:string mosaic:bool)
        @doc "Sets mosaic membership policy when FVT has no member links; collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_SetMosaic patron executor fvt-id mosaic)
                )
                (format "Successfully set mosaic on FVT {} to {}." [fvt-id mosaic])
            )
        )
    )
    (defun AQP-FVT|C_SetSplitMode:string
        (patron:string executor:string fvt-id:string split-mode:string)
        @doc "Sets a farm's reward-split mode (SPLIT|STAKED participation | SPLIT|TVL pool-size); collects IGNIS on patron. \
            \ Freely mutable — re-weights only future injects."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_SetSplitMode patron executor fvt-id split-mode)
                )
                (format "Successfully set reward-split mode on farm {} to {}." [fvt-id split-mode])
            )
        )
    )
    (defun AQP-FVT|C_IssueGenericEarningVault:string
        (patron:string executor:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
        @doc "Stand up a complete single-asset earning Vault in ONE transaction and ONE IGNIS \
            \ collection: stake a true fungible, earn another true fungible. Composes the six core \
            \ operations a Vault needs and concatenates their cumulators, so the caller pays once \
            \ rather than six times."
        ;; WHY THIS IS A TALOS ORCHESTRATOR AND NOT A CITIZEN HELPER
        ;;   The same six steps written in a citizen module would call the six TS02-C3 wrappers,
        ;;   and EVERY ONE OF THOSE COLLECTS IGNIS ON ITS OWN -- six collections for one logical
        ;;   operation. Composing the CORE C_ functions here and concatenating their cumulators
        ;;   collects once, which is the entire reason this belongs in Talos.
        ;;
        ;; WHAT A VAULT ACTUALLY NEEDS -- six operations, four class constants
        ;;   1 score for the staked DPTF   score-class 1
        ;;   2 pool it is staked into      aqp-class 1   (0 is reserved for LP)
        ;;   3 score -> pool link          without it the pool scores nothing
        ;;   4 the FVT entity              fvt-class 1 (Vault)
        ;;   5 score admitted to the FVT   score-entity type 1
        ;;   6 reward token registered     multiplet-family-id BAR (plain, not a laddered family)
        ;;
        ;;   Step 6 is not optional: an EMPLOYED score with no reward link makes every stake abort
        ;;   in the FVT pipeline (05_FVT.pact:1210). Doing 1-5 without 6 builds a vault nobody can
        ;;   use, which is a state this function makes unreachable.
        ;;
        ;; CLASS SAFETY
        ;;   Two sovereign admission rules disagree about fvt-class for SF/NF
        ;;   (URC_ScoreClassMatchesFvtClass vs URC_TripletCategoryMatchesFvtClass). They AGREE for
        ;;   true fungibles: score-class 1 is admitted at fvt-class 1 by the first, and VAULT_TF
        ;;   maps to 1 in the second. A TF-in/TF-out vault is the case both describe identically,
        ;;   so this function does not depend on how that dispute is settled.
        ;;
        ;; NAMING -- one name in, three derived, and they MUST differ
        ;;   UDC_Makeid is <name>-<block-hash> and ids collide across families because
        ;;   BRD|BrandingTable is shared (DPDC audit #33M). Three entities minted from one name in
        ;;   one transaction would produce three byte-identical ids and the second insert would
        ;;   hard-abort. Hence <name>Score / <name>Pool / <name>Vault.
        (with-capability (P|TS)
            (let*
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    ;;
                    (score-name:string (concat [vault-name "Score"]))
                    (pool-name:string (concat [vault-name "Pool"]))
                    (fvt-name:string (concat [vault-name "Vault"]))
                    ;;ids are derived in THIS transaction for entities minted in THIS transaction,
                    ;;so UDC_Makeid returns exactly what the C_Issue calls below are about to make.
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (pool-id:string (ref-U|DALOS::UDC_Makeid pool-name))
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid fvt-name))
                    ;;The POOL's executor is the STAKED ASSET's owner konto -- which is NOT
                    ;;necessarily `executor`, the account that will own the score and vault.
                    ;;A vault operator may stake a token somebody else issued. Derived, not assumed.
                    (stake-asset-owner:string
                        (ref-AQP::URC_AqpOwnerKontoFromClassAndAsset GV|POOL_CLASS_TF stake-dptf-id))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-SCR::C_IssueTrueFungibleScore
                                patron executor score-name GV|PRECISION GV|MX_FROZEN)
                            (ref-AQP::C_Issue patron stake-asset-owner pool-name stake-dptf-id GV|POOL_CLASS_TF)
                            (ref-AQP::C_AddScore patron stake-asset-owner pool-id score-id)
                            (ref-FVT::C_Issue
                                patron executor fvt-name GV|FVT_CLASS_VAULT GV|COMMON_BAR)
                            ;;The FVT's executor here IS `executor` -- C_Issue two lines up
                            ;;makes that account the vault's owner, so it is derived, not assumed.
                            (ref-FVT::C_AddScoreEntity
                                patron executor fvt-id GV|SCORE_ENTITY_SCORE score-id)
                            (ref-FVT::C_AddRewardLink
                                patron executor fvt-id reward-dptf-id false GV|COMMON_BAR)
                        ]
                        []
                    )
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format
                    "Successfully issued Generic Earning Vault {}: stake {} earn {}. score={} pool={} fvt={}."
                    [vault-name stake-dptf-id reward-dptf-id score-id pool-id fvt-id]
                )
            )
        )
    )

    (defun AQP-FVT|CC_InjectStream:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Injects reward DPTF as a TIME-STREAM (linear vesting over `duration` seconds, 1h..365d) into fvt-id \
            \ and collects IGNIS on patron. The DELAYED counterpart of AQP-FVT|CC_Inject (instant): the amount vests \
            \ continuously and whoever is staked during each slice earns it (late stakers included). Independent \
            \ overlapping streams, capped by the FVT owner konto's Elite tier. See Audit/STREAMED-INJECT-DESIGN.md."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_InjectStream patron executor fvt-id reward-dptf-id amount duration)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully streamed {} {} into FVT {} over {}s." [amount reward-dptf-id fvt-id duration])
            )
        )
    )
    (defun AQP-FVT|CC_Inject:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "HEAVY enforced-FRESH inject for ANY FVT class (farm/vault/treasury; M3 #12): refreshes every stale \
            \ staker's deb so the divisor is live before injecting, then injects + collects IGNIS on patron. Same \
            \ shape as C_Inject. Farms are covered too — a mosaic farm's singular/non-true-triplet members are \
            \ deb-stale-exposed via SCR|ScoreTotalDebScore just like a vault."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_Inject patron executor fvt-id reward-dptf-id amount)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully FRESH-injected {} {} into FVT {}." [amount reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-FVT|CCp_InjectFixChunk:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "PAGE the enforced-fresh inject's fix phase — refresh up to `chunk` currently-stale stakers (penalized), \
            \ the scalable prelude to AQP-FVT|CC_InjectFinalize for stale sets exceeding one tx. Repeat until none \
            \ remain. `chunk` is the UI's simulated slice (bounded by AQP-FVT's loose INJECT-FIX-CHUNK-MAX). Lives \
            \ in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CCp_InjectFixChunk patron fvt-id reward-dptf-id chunk))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CC_InjectFinalize:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "FINALIZE a paginated enforced-fresh inject: after CCp_InjectFixChunk pages left ZERO stale, inject on \
            \ the fresh divisor + collect IGNIS on patron — same outcome as the single-tx AQP-FVT|CC_Inject. Lives \
            \ in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_InjectFinalize patron executor fvt-id reward-dptf-id amount)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully FRESH-injected {} {} into FVT {} (paginated)." [amount reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-FVT|CCp_UnstaleAll:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "OWNER mass deb-unstale — force-refresh up to `chunk` currently-stale present stakers (penalized, same \
            \ 2e tag as an inject's fix) to make the FVT INJECTION-READY, WITHOUT injecting. Repeat until the report \
            \ says injection-ready (or `all up to date` when nothing is stale), then run a light AQP-FVT|CC_Inject. \
            \ Owner-gated in AQP-FVT::CCp_UnstaleAll. `chunk` is the UI's simulated slice (bounded by INJECT-FIX-CHUNK-MAX). \
            \ Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CCp_UnstaleAll patron fvt-id reward-dptf-id chunk))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun MTX-AQP|2|CC_Inject:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Starts the 2-step enforced-fresh inject defpact (MTX-AQP — spike fallback for AQP-FVT|CC_Inject when \
            \ the stale set exceeds one tx). Step 0 runs here; advance with (continue-pact 1). Each defpact step \
            \ collects its own IGNIS on patron, so this wrapper only summons the pact."
        (with-capability (P|TS)
            (let
                (
                    (ref-MTX-AQP:module{AqpMtxV1} MTX-AQP)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-MTX-AQP::C_2|Inject patron executor fvt-id reward-dptf-id amount))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun MTX-AQP|2|CC_SweepRevokeAnchor:string
        (patron:string executor:string anchor-id:string)
        @doc "Starts the 2-step paginated re-score SWEEP defpact (MTX-AQP — spike fallback for \
            \ AQP-FVT|CC_SweepRevokeAnchor when the recompute set exceeds one tx). Step 0 brackets (freeze + \
            \ swept-revoke) + recomputes the first window here; advance with (continue-pact 1). The defpact is \
            \ gas-only (no reward inject), so this wrapper just summons the pact and refuels."
        (with-capability (P|TS)
            (let
                (
                    (ref-MTX-AQP:module{AqpMtxV1} MTX-AQP)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-MTX-AQP::C_2|SweepRevokeAnchor patron executor anchor-id))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CC_SweepRevokeAnchor:string
        (patron:string executor:string anchor-id:string)
        @doc "Single-tx re-score SWEEP that retires an EMPLOYED anchor (H4 half-2): freezes the affected pools, \
            \ removes the anchor (swept-revoke), recomputes every affected holder (aggregate/lane refold + deb), \
            \ then unfreezes. Owner-initiated (patron = the anchored-asset owner). Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CC_SweepRevokeAnchor patron executor anchor-id))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CC_SweepBegin:string
        (patron:string executor:string anchor-id:string)
        @doc "OPEN a paginated (defun+gate) re-score sweep — the scalable twin of AQP-FVT|CC_SweepRevokeAnchor for \
            \ holder sets exceeding one tx: freezes the affected pools + swept-revokes the anchor, then defers the \
            \ recompute to AQP-FVT|CCp_SweepRecomputeChunk calls under the held freeze. Owner-initiated. Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CC_SweepBegin patron executor anchor-id))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CCp_SweepRecomputeChunk:string
        (patron:string anchor-id:string chunk:integer)
        @doc "PAGE an open re-score sweep: recompute the next `chunk` holders over the frozen global present set, \
            \ advancing the cursor; the finalizing chunk (set exhausted) unfreezes the affected pools. `chunk` is \
            \ the UI's simulated slice size (bounded by AQP-FVT's loose SWEEP-CHUNK-MAX backstop). Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CCp_SweepRecomputeChunk patron anchor-id chunk))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CC_UnstaleMyScores:string
        (patron:string executor:string fvt-ids:[string])
        @doc "User self-service deb-unstale: the caller refreshes THEIR OWN stale scores across the listed FVTs \
            \ (non-penalized — the cheap alternative to being force-fixed by an inject), then collects IGNIS on \
            \ patron. The UI finds the FVT list via RPS.URC_FvtUserHasStaleMember per FVT the user stakes. \
            \ Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_UnstaleMyScores patron executor fvt-ids)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Refreshed your stale scores across {} FVT(s)." [(length fvt-ids)])
            )
        )
    )
    (defun AQP-FVT|CC_Collect:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Collects pending reward DPTF for patron on one score-entity from fvt-id; collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (bal-before:decimal (ref-DPTF::UR_AccountSupply reward-dptf-id patron))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_Collect patron executor fvt-id score-entity-type score-entity-id reward-dptf-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (let
                    (
                        (bal-after:decimal (ref-DPTF::UR_AccountSupply reward-dptf-id patron))
                        (payout:decimal (- bal-after bal-before))
                    )
                    (format "Successfully collected {} {} rewards from FVT {} for score-entity type {} id {}."
                        [payout reward-dptf-id fvt-id score-entity-type score-entity-id]
                    )
                )
            )
        )
    )
    (defun AQP-DSA|CC_OpenAgency:string
        (patron:string executor:string fvt-id:string pool-id:string score-entity-id:string fee-per-mille:integer
         collectable-id:string stake-nonces:[integer])
        @doc "DSA (Talos): open a delegation agency ATOMICALLY under P|TS — (1) admit the operator's BLANK triplet \
            \ <score-entity-id> to vault <fvt-id> (AQP-DSA::C_AdmitAgency); (2) stake the operator's initial \
            \ <collectable-id>/<stake-nonces> from <pool-id> (FVT::CC_CollectableStakeFlow — runs under P|TS so the \
            \ deep DPDC custody transfer's IMC passes); (3) enforce the terminal quintessence >= unit-score/2 open \
            \ gate (AQP-DSA::UEV_OpenGate — a short stake reverts the whole open). Collects both cumulators on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                )
                ;; (1) admit the blank triplet (fvt-links must be BAR) + record the agency
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DSA::C_AdmitAgency patron executor fvt-id score-entity-id fee-per-mille))
                ;; (2) stake the operator's initial quintessence into the now-linked, reward-ready triplet
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_CollectableStakeFlow
                        patron executor executor pool-id collectable-id true
                        stake-nonces (ref-DPDC::UR_AccountNoncesSupplies executor collectable-id true stake-nonces) true))
                ;; (3) terminal atomic gate — after the stake, Q must clear unit-score/2 or the whole tx reverts
                (ref-DSA::UEV_OpenGate fvt-id score-entity-id)
                (format "Agency opened on FVT {} for score-entity {} (fee {} per-mille)." [fvt-id score-entity-id fee-per-mille])
            )
        )
    )
    (defun AQP-DSA|C_RecomputeCapture:string
        (patron:string fvt-id:string score-entity-id:string)
        @doc "DSA (Talos): permissionlessly recompute an agency's capture from its current quintessence (after a \
            \ delegator stake/unstake changed Q); collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DSA::C_RecomputeCapture patron fvt-id score-entity-id)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Capture recomputed for agency {} on FVT {}." [score-entity-id fvt-id])
            )
        )
    )

    ;;<=========================================================================>
    ;;{6}  REPL
    ;;
    ;; --- REPL dry-run (P|TS client shell → AQP-FVT::REPL_BootstrapVault under GOV|FVT_ADMIN) ---
    (defun AQP-FVT|REPL_BootstrapVault:string
        (patron:string fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only Talos shell: composes P|TS for SCR XE IMC; forwards to AQP-FVT::REPL_BootstrapVault."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-FVT::REPL_BootstrapVault fvt-id owner-konto score-id reward-dptf-id)
            )
        )
    )
    (defun AQP-FVT|REPL_BootstrapTreasury:string
        (patron:string fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only Talos shell: class-2 treasury bootstrap for OF score pools."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-FVT::REPL_BootstrapTreasury fvt-id owner-konto score-id reward-dptf-id)
            )
        )
    )


)


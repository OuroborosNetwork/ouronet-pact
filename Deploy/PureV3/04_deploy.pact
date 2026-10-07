;; TX 04/08 -- AQP-POOL, TS02-C1, TS02-C2     (~299,681 B, ~264k gas -- the round's largest)
;;
;; AQP-POOL  NEW `UEV_ScoreDefinitionTargetMatchesPool`: refuses a weight definition written
;;           against a collection the score's EMPLOYING POOL does not stake. Two point reads, no
;;           scan -- the complete check needs a URH_ scan, which would make every caller in its
;;           tree heavy (CC_/AA_ doubling) and drag a rename through Talos. It lives here, not in
;;           AQP-SCORE, because the pool fact is one module LATER in deploy order: AQP-POOL may
;;           reference AQP-SCORE, never the reverse.
;; TS02-C1   2.16.2: the three DPSF set definers reported `set-name`, the caller's own input.
;; TS02-C2   2.16.2: likewise the three DPNF ones. set-class is an AUTO-INCREMENT integer, so
;;           unlike a name-derived id it cannot be reconstructed afterwards -- yet C_ToggleSet,
;;           C_RenameSet and C_UpdateSetNonce* all key on it. Pairs with DPDC-S in TX 02.
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

;; ---- source: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/03_AQP.pact (module only -- its interface is already live)
(module AQP-POOL GOV
    @doc "Sovereign acquisition-pool module. Owns pool definitions (asset, aqp-class, up to \
        \ 7 employed scores, stake-enabled/vacate/sweep state, occupancy counts), \
        \ per-position stake trackers for TF/OF/SF/NF assets, and per-beneficiary balance \
        \ rollups with anchor-sync counters. Handles pool issuance, add/revoke score, \
        \ enable/disable staking, custody transfers and anchor sync; stake/unstake token \
        \ movement and tracker/rollup writes flow through its XE_/XB_ blocks driven by \
        \ Talos/FVT."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements AcquisitionPoolsV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;(implements DemiourgosPactDigitalCollectibles-UtilityPrototype)
    ;;
    (defconst GOV|MD_AQP                                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|AQP_ADMIN)))
    (defcap GOV|AQP_ADMIN ()                            (enforce-guard GOV|MD_AQP))
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
    (defcap P|AQP|CALLER ()
        true
    )
    (defcap P|AQP|REMOTE-GOV ()
        @doc "Reserved local remote-gov slot — forward modules register P|*|REMOTE-GOV on P|T (FVT|RemoteAqpGov, VCT|RemoteAqpGov)."
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|AQP|CALLER))
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
        (with-capability (GOV|AQP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|AQP_ADMIN)
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
        (with-capability (GOV|AQP_ADMIN)
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
        (with-capability (GOV|AQP_ADMIN)
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
        @doc "Post-deploy IMC wiring (AQP-BOOT Step 0). TFT + DPOF vault transfer/receive on AQP|SC_NAME."
        (let
            (
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                ;;
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|AQP|CALLER)))
            )
            ;; AQP-POOL → TFT: XE_TrueFungibleTransfer calls TFT::C_Transfer; TFT P|UEV_IMC requires this guard.
            (ref-P|TFT::P|A_AddIMP mg)
            ;; AQP-POOL → DPOF: XE_OrtoFungibleTransfer calls DPOF::C_Transfer; vacate batch is AQP-VCT → DPOF::C_BulkTransfer.
            (ref-P|DPOF::P|A_AddIMP mg)
            ;; AQP-POOL → DPDC-T: XE_CollectableTransfer calls DPDC-T::C_Transfer; vacate batch is AQP-VCT → DPDC-T::C_BulkTransfer.
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            true
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst GAS|ISSUE-POOL                        (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "issue-pool")))
    (defconst GAS|ADD-SCORE                         (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "add-score")))
    (defconst GAS|REVOKE-SCORE                      (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "revoke-score")))
    (defconst GAS|SET-POOL-STAKE                    (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "pool-stake-toggle")))
    (defconst GAS|SYNC-TF-ANCHORS                   (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "sync-anchors")))
    (defconst GAS|SYNC-COLLECTABLE-ANCHORS          (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "sync-anchors")))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst AQP|SC_NAME                               (CT_AqpScName))
    ;;{3.2}  schemas
    ;;
    ;; [1] AQP|T|Pool
    ;;
    ;; [2] AQP|T|DPTFTracker
    ;;
    ;; [3] AQP|T|DPOFTracker
    ;;
    ;; [4] AQP|T|DPSFTracker
    ;;
    ;; [5] AQP|T|DPNFTracker
    ;;
    ;; [8] AQP|T|BenDptfTotal
    ;;Ben × asset rollups (pool-agnostic totals for ANK sync — see README_AQP.md § Anchor sync)
    ;;
    ;; [9] AQP|T|BenDpsfNonceTotal
    ;;
    ;; [10] AQP|T|BenDpnfNonceTotal
    ;;
    ;; [11] AQP|T|BenDpsfAnkMeta
    ;;
    ;; [12] AQP|T|BenDpnfAnkMeta
    ;;
    ;; [13] AQP|T|UserOccupancy
    ;;{3.3}  tables
    ;;
    (deftable AQP|T|Pool:{AcquisitionSchemasV1.AQP|Schema})                                  ;;1] Key = <Pool-ID>
    (deftable AQP|T|DPTFTracker:{AcquisitionSchemasV1.AQP|TrueFungibleTracker})              ;;2] Key = <Pool-ID> | <DPTF-ID> | <Owner-ID> | <Beneficiary-ID>
    (deftable AQP|T|DPOFTracker:{AcquisitionSchemasV1.AQP|OrtoFungibleTracker})              ;;3] Key = <Pool-ID> | <DPOF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|DPSFTracker:{AcquisitionSchemasV1.AQP|SemiFungibleTracker})              ;;4] Key = <Pool-ID> | <DPSF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|DPNFTracker:{AcquisitionSchemasV1.AQP|NonFungibleTracker})               ;;5] Key = <Pool-ID> | <DPNF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|BenDptfTotal:{AcquisitionSchemasV1.AQP|BenDptfTotal})                    ;;8] Key = <Beneficiary-ID> | <DPTF-ID>
    (deftable AQP|T|BenDpsfNonceTotal:{AcquisitionSchemasV1.AQP|BenDpsfNonceTotal})          ;;9] Key = <Beneficiary-ID> | <DPSF-ID> | <Nonce>
    (deftable AQP|T|BenDpnfNonceTotal:{AcquisitionSchemasV1.AQP|BenDpnfNonceTotal})          ;;10] Key = <Beneficiary-ID> | <DPNF-ID> | <Nonce>
    (deftable AQP|T|BenDpsfAnkMeta:{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta})                ;;11] Key = <Beneficiary-ID> | <DPSF-ID>
    (deftable AQP|T|BenDpnfAnkMeta:{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta})                ;;12] Key = <Beneficiary-ID> | <DPNF-ID>
    (deftable AQP|T|UserOccupancy:{AcquisitionSchemasV1.AQP|UserOccupancy})                  ;;13] Key = <Pool-ID> | <Beneficiary-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap AQP|GOV ()
        @doc "Governor capability for the AQP|SC_NAME smart DALOS account (TFT/DPOF/DPDC vault send and receive). \
            \ Composed only from this module — never compose AQP-ANK.AQP|GOV cross-module."
        true
    )
    ;;{C3}  Composed
    (defcap AQP|C>ISSUE-POOL
        (executor:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Issue one acquisition pool (single @event). Validates pool-name, class, and asset-id; \
            \ enforces canonical asset ownership from aqp-class + asset-id; composes SECURE for XI_IssuePool."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            ;;1] pool-name is a valid autostake index (unique pool id stem)
            (ref-U|ATS::UEV_AutostakeIndex pool-name)
            ;;2] aqp-class in 0..4 and asset-id matches class rules (native id, not a special prefix)
            (UEV_IssuePoolClassAndAsset aqp-class asset-id)
            ;;3] tx sender must own the canonical asset behind this pool class + asset-id
            (CAP_AqpAssetOwner aqp-class asset-id)
            (UEV_ExecutorIzAqpAssetOwner executor aqp-class asset-id)
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|C>ADD-SCORE
        (executor:string pool-id:string score-id:string slot-index:integer)
        @doc "Assign score-id to score slot slot-index (first free; computed once in C_AddScore). Validates \
            \ slot claim, pool/score pairing; CAP_PoolOwner. Score owner in SCR|XE>CREATE-AQPOOL-LINK on XE. \
            \ Composes SECURE for XI_AddScoreToPool."
        @event
        (UEV_AddScorePoolAndScore pool-id score-id slot-index)
        (CAP_PoolOwner pool-id)
        (UEV_ExecutorIzPoolOwner executor pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>REVOKE-SCORE
        (executor:string pool-id:string score-id:string slot-index:integer)
        @doc "Revoke score-id from score slot slot-index (computed once in C_RevokeScore). Validates \
            \ slot claim, zero totals, fvt-link BAR, boost-link dependents; CAP_PoolOwner. Score owner in \
            \ SCR|XE>REVOKE-AQPOOL-LINK on XE. Composes SECURE for XI_RevokeScoreFromPool."
        @event
        (UEV_RevokeScorePoolAndScore pool-id score-id slot-index)
        (CAP_PoolOwner pool-id)
        (UEV_ExecutorIzPoolOwner executor pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>DISABLE-POOL-STAKE
        (executor:string pool-id:string)
        @doc "Pool owner pauses new stakes (stake-enabled → false). Idempotent when already false. \
            \ Unstake and vacate are unaffected."
        @event
        (CAP_PoolOwner pool-id)
        (UEV_ExecutorIzPoolOwner executor pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>ENABLE-POOL-STAKE
        (executor:string pool-id:string)
        @doc "Pool owner re-enables new stakes (stake-enabled → true). BLOCKED while a vacate session is in \
            \ progress — the owner must finish the vacate or C_AbortVacate first (audit H2 / fix #5). \
            \ Idempotent when already true; admission still requires ≥1 employed score and FVT pipeline ready."
        @event
        (enforce
            (not (UR_AQP|PoolVacateInProgress pool-id))
            "Cannot enable pool stake while a vacate is in progress; finish or abort the vacate first"
        )
        (CAP_PoolOwner pool-id)
        (UEV_ExecutorIzPoolOwner executor pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Forward-only (FVT::CC_TrueFungibleStakeFlow phase 1]): validation for XE_TrueFungibleTransfer. \
            \ Pool/beneficiary/tracker/rollup rules here; dptf-id/amount/debit via TFT::C_Transfer. \
            \ CAP_StakeOwner (owner wallet); compose P|AQP|CALLER (TFT IMC); compose AQP|GOV (AQP|SC_NAME smart account — \
            \ send and receive both require governor proof). XI_* writers have no enforce. Not @event — P|UEV_IMC on XE entry."
        (let
            (
                (staked-bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
                (rollup-bal:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (class-ok:bool (URC_StakeTrueFungiblePoolClassOk pool-id))
                (stake-admission-ok:bool (if direction (URC_PoolStakeAdmissionOk pool-id) (URC_PoolUnstakeAdmissionOk pool-id)))
                (dptf-ok:bool (URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id))
                (tracker-ok:bool (or direction (>= staked-bal amount)))
                (rollup-ok:bool (or direction (>= rollup-bal amount)))
            )
            (enforce
                (fold (and) true [class-ok stake-admission-ok dptf-ok tracker-ok rollup-ok])
                "Invalid TF pool custody: pool class/stake admission/dptf-id or insufficient staked/rollup balance"
            )
            (UEV_StakeBeneficiaryAccount beneficiary-id)
            (CAP_StakeOwner owner-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP|GOV))
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Forward-only (FVT::CC_OrtoFungibleStakeFlow phase 1]): validation for XE_OrtoFungibleTransfer. \
            \ Whole-nonce DPOF::C_Transfer only. CAP_StakeOwner; compose P|AQP|CALLER + AQP|GOV for vault custody."
        (let
            (
                (stake-admission-ok:bool (if direction (URC_PoolStakeAdmissionOk pool-id) (URC_PoolUnstakeAdmissionOk pool-id)))
                (class-ok:bool (URC_StakeOrtoFungiblePoolClassOk pool-id))
                (dpof-ok:bool (URC_StakeOrtoFungibleDpofMatchesPool pool-id dpof-id))
                ;; L1 #16: no whole-nonce-amount check — DPOF::C_Transfer moves WHOLE nonces (ignores amounts),
                ;; and every caller sources nonce-amounts from UR_NoncesSupplies, so "amount == nonce supply" was a
                ;; tautology. Whole-nonce is a structural invariant of the token transfer, not a cap-level check.
                (tracker-ok:bool
                    (if direction
                        true
                        (URC_OrtoUnstakeNoncesSufficient pool-id dpof-id owner-id beneficiary-id nonces nonce-amounts)
                    )
                )
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a) stake-admission-ok class-ok dpof-ok tracker-ok])
                "Invalid OF pool custody: pool class/dpof-id, equal nonce/amount length, stake admission, or insufficient tracker balance"
            )
            (if direction
                (let
                    (
                        (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    )
                    (ref-DPOF::UEV_NoncesToAccount dpof-id owner-id nonces)
                    (ref-DPOF::UEV_NoncesCirculating dpof-id nonces)
                    (map
                        (lambda (idx:integer)
                            (ref-DPOF::UEV_Amount dpof-id (at idx nonce-amounts))
                        )
                        (enumerate 0 (- l-n 1))
                    )
                )
                true
            )
            (UEV_StakeOrtoFungibleDpofLeg dpof-id)
            ;; M5: beneficiary account must exist BOTH directions (owner may stake for self OR a foreign beneficiary;
            ;; unstake removes that exact (owner, beneficiary) row). Mirror TF custody cap.
            (UEV_StakeBeneficiaryAccount beneficiary-id)
            (CAP_StakeOwner owner-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP|GOV))
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|XE>COLLECTABLE-POOL-CUSTODY
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Forward-only (FVT::CC_CollectableStakeFlow phase 1]): DPDC::C_Transfer + tracker validation. \
            \ son=true DPSF (class-3 pool); son=false DPNF (class-4 pool)."
        (let
            (
                (stake-admission-ok:bool (if direction (URC_PoolStakeAdmissionOk pool-id) (URC_PoolUnstakeAdmissionOk pool-id)))
                (class-ok:bool (URC_StakeCollectablePoolClassOk pool-id son))
                (collectable-ok:bool (URC_StakeCollectableMatchesPool pool-id collectable-id))
                (tracker-ok:bool
                    (if direction
                        true
                        (URC_CollectableUnstakeNoncesSufficient
                            pool-id collectable-id son owner-id beneficiary-id nonces nonce-amounts
                        )
                    )
                )
                (rollup-ok:bool
                    (if direction
                        true
                        (URC_CollectableUnstakeRollupSufficient
                            pool-id collectable-id son owner-id beneficiary-id nonces nonce-amounts
                        )
                    )
                )
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a) stake-admission-ok class-ok collectable-ok tracker-ok rollup-ok])
                "Invalid collectable pool custody: pool class/collectable-id, stake admission, or insufficient tracker balance"
            )
            (if direction
                (let
                    (
                        (ref-DPDC:module{DpdcV2} DPDC)
                    )
                    (ref-DPDC::UEV_NonceQuantityInclusionMapper owner-id collectable-id son nonces nonce-amounts)
                )
                true
            )
            (UEV_StakeCollectableLeg collectable-id son)
            ;; M5: beneficiary account must exist BOTH directions (self OR foreign beneficiary). Mirror TF custody cap.
            (UEV_StakeBeneficiaryAccount beneficiary-id)
            (CAP_StakeOwner owner-id)
            (compose-capability (P|AQP|CALLER))
            (compose-capability (AQP|GOV))
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC
        (beneficiary-id:string dptf-id:string)
        @doc "Backward-only (FVT::CC_TrueFungibleStakeFlow phase 2.2]): stamp last-ank-sync-count on BenDptfTotal. \
            \ beneficiary/dptf validation here; full stake rules in FVT|C>TRUE-FUNGIBLE-STAKE-FLOW. \
            \ Composes SECURE for XE write body. Not @event — P|UEV_IMC on XE entry."
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (UEV_StakeTrueFungibleDptfLeg dptf-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>SYNC-TF-ANCHORS
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Pool-agnostic ANK repair for one beneficiary × dptf-id leg. Patron pays IGNIS; composes SECURE."
        @event
        (enforce
            (> (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id) 0.0)
            "No cross-pool TF stake to sync"
        )
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (UEV_StakeTrueFungibleDptfLeg dptf-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>SYNC-COLLECTABLE-ANCHORS
        (patron:string beneficiary-id:string collectable-id:string son:bool)
        @doc "Pool-agnostic ANK repair for DPSF (son=true) or DPNF (son=false). Patron pays IGNIS; composes SECURE."
        @event
        (enforce
            (URC_BenCollectableHasStake beneficiary-id collectable-id son)
            "No cross-pool collectable stake to sync"
        )
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (UEV_StakeCollectableLeg collectable-id son)
        (compose-capability (SECURE))
    )
    (defcap AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC
        (beneficiary-id:string collectable-id:string son:bool)
        @doc "Backward (FVT stake phase 3 / C_SyncCollectableAnchors): stamp BenDpsfAnkMeta or BenDpnfAnkMeta."
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (UEV_StakeCollectableLeg collectable-id son)
        (compose-capability (SECURE))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Bar:string
        ()
        @doc "Returns CT_BAR constant."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_EmptyCumulator ()
        @doc "Empty IGNIS OutputCumulator for stub transfer legs."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    (defun CT_AqpScName:string
        ()
        @doc "Resolves AQP|SC_NAME from canonical AQP-ANK via interface ref."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-ANK::GOV|AQP|SC_NAME)
        )
    )
    ;;
    ;; [UDC] construct
    ;;
    ;; Default tracker and attribution rows for UR with-default-read.
    (defun UDC_AQP|TrueFungibleTracker:object{AcquisitionSchemasV1.AQP|TrueFungibleTracker}
        (bal:decimal pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Default DPTF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dptf-id"          : dptf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id}
    )
    (defun UDC_AQP|OrtoFungibleTracker:object{AcquisitionSchemasV1.AQP|OrtoFungibleTracker}
        (bal:decimal pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPOF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpof-id"          : dpof-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|SemiFungibleTracker:object{AcquisitionSchemasV1.AQP|SemiFungibleTracker}
        (bal:decimal pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPSF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpsf-id"          : dpsf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|NonFungibleTracker:object{AcquisitionSchemasV1.AQP|NonFungibleTracker}
        (bal:decimal pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPNF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpnf-id"          : dpnf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|BenDptfTotal:object{AcquisitionSchemasV1.AQP|BenDptfTotal}
        (total:decimal sync-count:integer beneficiary-id:string dptf-id:string)
        @doc "Default beneficiary DPTF rollup row (zero total, never synced)."
        {"total-balance"        : total
        ,"last-ank-sync-count"  : sync-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dptf-id"              : dptf-id}
    )
    (defun UDC_AQP|BenDpsfNonceTotal:object{AcquisitionSchemasV1.AQP|BenDpsfNonceTotal}
        (amount:integer beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Default DPSF per-nonce rollup row (zero amount)."
        {"amount"           : amount
        ,"beneficiary-id"   : beneficiary-id
        ,"dpsf-id"          : dpsf-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|BenDpnfNonceTotal:object{AcquisitionSchemasV1.AQP|BenDpnfNonceTotal}
        (amount:integer beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Default DPNF per-nonce rollup row (zero amount)."
        {"amount"           : amount
        ,"beneficiary-id"   : beneficiary-id
        ,"dpnf-id"          : dpnf-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|BenDpsfAnkMeta:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta}
        (sync-count:integer active-nonce-count:integer beneficiary-id:string dpsf-id:string)
        @doc "Default DPSF ANK meta row (never synced, no active nonces)."
        {"last-ank-sync-count"  : sync-count
        ,"active-nonce-count"   : active-nonce-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dpsf-id"              : dpsf-id}
    )
    (defun UDC_AQP|BenDpnfAnkMeta:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta}
        (sync-count:integer active-nonce-count:integer beneficiary-id:string dpnf-id:string)
        @doc "Default DPNF ANK meta row (never synced, no active nonces)."
        {"last-ank-sync-count"  : sync-count
        ,"active-nonce-count"   : active-nonce-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dpnf-id"              : dpnf-id}
    )
    (defun UDC_AQP|UserOccupancy:object{AcquisitionSchemasV1.AQP|UserOccupancy}
        (unn:integer pool-id:string beneficiary-id:string)
        @doc "Vacate-v2 §4: default per (pool, beneficiary) occupancy row (unn = 0 when absent)."
        {"unn"                  : unn
        ,"pool-id"              : pool-id
        ,"beneficiary-id"       : beneficiary-id}
    )
    (defun UDC_AQP|Schema:object{AcquisitionSchemasV1.AQP|Schema}
        (aqp-class:integer asset-id:string aqp-id:string)
        @doc "Default new pool row: all seven score slots BAR; aqp-id equals pool-id (table key). #FP1 universal \
            \ nns: starts -1 only for LP pools (class 0, complex multi-leg — still nzs-based finalize) and 0 for \
            \ occupancy-tracked pools (class 1 TF legs, 2/3/4 OF/SF/NF nonce positions)."
        {"aqp-class"            : aqp-class
        ,"asset-id"             : asset-id
        ,"score-primary"        : BAR
        ,"score-secondary"      : BAR
        ,"score-tertiary"       : BAR
        ,"score-quaternary"     : BAR
        ,"score-quinary"        : BAR
        ,"score-senary"         : BAR
        ,"score-septenary"      : BAR
        ,"stake-enabled"        : true
        ,"vacate-in-progress"   : false
        ,"sweep-in-progress"    : false
        ,"nns"                  : (if (< aqp-class 1) -1 0)
        ,"aqp-id"               : aqp-id}
    )
    (defun UDC_AQP|SchemaWithScoreSlots:object{AcquisitionSchemasV1.AQP|Schema}
        (pool:object{AcquisitionSchemasV1.AQP|Schema}
            score-primary:string
            score-secondary:string
            score-tertiary:string
            score-quaternary:string
            score-quinary:string
            score-senary:string
            score-septenary:string
        )
        @doc "Returns pool row with all seven score slots replaced (merge over the existing row)."
        ;;MERGE ORDER FIX (2026-09-13). This was `(+ pool {…seven slots…})` and was therefore a
        ;;COMPLETE NO-OP: Pact's object `+` gives precedence to the LEFT operand on key collisions
        ;;-- verified live, `(+ {"a": 1, "b": 9} {"a": 2, "c": 3})` is `{"a": 1, "b": 9, "c": 3}`.
        ;;The pool row already carries all seven slot keys, so every supplied value was discarded and
        ;;the function returned its input unchanged, flatly contradicting its own @doc ("all seven
        ;;score slots replaced").
        ;;
        ;;Caught by writing the first test this function has ever had: addressing slot N and reading
        ;;back slot N returned the row's ORIGINAL score, not the one just written.
        ;;
        ;;NO BLAST RADIUS, which is why this is a repair rather than a deletion: its only caller is
        ;;`UDC_AQP|SchemaWithScoreAtSlot` directly below, and THAT has no callers anywhere in the
        ;;codebase. Neither is on the AcquisitionPoolsV1 interface, so no cascade. The live slot
        ;;writer is a different mechanism entirely -- `UC_PoolScoreSlotPatch` builds a PARTIAL update
        ;;map consumed by `WU_Pool|ScoreSlot`, which is correct and unaffected.
        ;;Pinned slot-by-slot by REPL/modules/AQP.repl <<AQP-F10>>.
        (+  {"score-primary"    : score-primary
            ,"score-secondary"  : score-secondary
            ,"score-tertiary"   : score-tertiary
            ,"score-quaternary" : score-quaternary
            ,"score-quinary"    : score-quinary
            ,"score-senary"     : score-senary
            ,"score-septenary"  : score-septenary}
            pool
        )
    )
    (defun UDC_AQP|SchemaWithScoreAtSlot:object{AcquisitionSchemasV1.AQP|Schema}
        (pool:object{AcquisitionSchemasV1.AQP|Schema} slot-index:integer score-id:string)
        @doc "Returns pool row with score-id written into slot-index (0=primary .. 6=septenary)."
        (UDC_AQP|SchemaWithScoreSlots pool
            (if (= slot-index 0) score-id (at "score-primary" pool))
            (if (= slot-index 1) score-id (at "score-secondary" pool))
            (if (= slot-index 2) score-id (at "score-tertiary" pool))
            (if (= slot-index 3) score-id (at "score-quaternary" pool))
            (if (= slot-index 4) score-id (at "score-quinary" pool))
            (if (= slot-index 5) score-id (at "score-senary" pool))
            (if (= slot-index 6) score-id (at "score-septenary" pool))
        )
    )
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    (defun UCk_DPTFTracker:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Composite key for AQP|T|DPTFTracker: pool-id | dptf-id | owner-id | beneficiary-id."
        (concat [pool-id BAR dptf-id BAR owner-id BAR beneficiary-id])
    )
    (defun UCk_DPOFTracker:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPOFTracker: pool-id | dpof-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpof-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UCk_DPSFTracker:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPSFTracker: pool-id | dpsf-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpsf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UCk_DPNFTracker:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPNFTracker: pool-id | dpnf-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpnf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UCk_BenDptfTotal:string (beneficiary-id:string dptf-id:string)
        @doc "Composite key for AQP|T|BenDptfTotal: beneficiary-id | dptf-id."
        (concat [beneficiary-id BAR dptf-id])
    )
    (defun UCk_BenDpsfNonceTotal:string (beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Composite key for AQP|T|BenDpsfNonceTotal: beneficiary-id | dpsf-id | nonce."
        (concat [beneficiary-id BAR dpsf-id BAR (format "{}" [nonce])])
    )
    (defun UCk_BenDpnfNonceTotal:string (beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Composite key for AQP|T|BenDpnfNonceTotal: beneficiary-id | dpnf-id | nonce."
        (concat [beneficiary-id BAR dpnf-id BAR (format "{}" [nonce])])
    )
    (defun UCk_BenDpsfAnkMeta:string (beneficiary-id:string dpsf-id:string)
        @doc "Composite key for AQP|T|BenDpsfAnkMeta: beneficiary-id | dpsf-id."
        (concat [beneficiary-id BAR dpsf-id])
    )
    (defun UCk_BenDpnfAnkMeta:string (beneficiary-id:string dpnf-id:string)
        @doc "Composite key for AQP|T|BenDpnfAnkMeta: beneficiary-id | dpnf-id."
        (concat [beneficiary-id BAR dpnf-id])
    )
    (defun UCk_UserOccupancy:string (pool-id:string beneficiary-id:string)
        @doc "Composite key for AQP|T|UserOccupancy: pool-id | beneficiary-id."
        (concat [pool-id BAR beneficiary-id])
    )
    (defun UC_PoolScoreSlotPatch:object
        (slot-index:integer score-id:string)
        @doc "Partial AQP|T|Pool update map for one score slot (0=primary .. 6=septenary)."
        (if (= slot-index 0)
            {"score-primary": score-id}
            (if (= slot-index 1)
                {"score-secondary": score-id}
                (if (= slot-index 2)
                    {"score-tertiary": score-id}
                    (if (= slot-index 3)
                        {"score-quaternary": score-id}
                        (if (= slot-index 4)
                            {"score-quinary": score-id}
                            (if (= slot-index 5)
                                {"score-senary": score-id}
                                {"score-septenary": score-id}
                            )
                        )
                    )
                )
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    (defun UR_AQP|Pool:object{AcquisitionSchemasV1.AQP|Schema} (pool-id:string)
        @doc "Reads full pool definition row from AQP|T|Pool."
        (read AQP|T|Pool pool-id)
    )
    (defun UR_AQP|PoolAqpClass:integer (pool-id:string)
        @doc "Reads aqp-class from pool row."
        (at "aqp-class" (read AQP|T|Pool pool-id ["aqp-class"]))
    )
    (defun UR_AQP|PoolAssetId:string (pool-id:string)
        @doc "Reads canonical asset-id from pool row."
        (at "asset-id" (read AQP|T|Pool pool-id ["asset-id"]))
    )
    (defun UR_AQP|PoolScorePrimary:string (pool-id:string)
        @doc "Reads score-primary slot from pool row."
        (at "score-primary" (read AQP|T|Pool pool-id ["score-primary"]))
    )
    (defun UR_AQP|PoolScoreSecondary:string (pool-id:string)
        @doc "Reads score-secondary slot from pool row."
        (at "score-secondary" (read AQP|T|Pool pool-id ["score-secondary"]))
    )
    (defun UR_AQP|PoolScoreTertiary:string (pool-id:string)
        @doc "Reads score-tertiary slot from pool row."
        (at "score-tertiary" (read AQP|T|Pool pool-id ["score-tertiary"]))
    )
    (defun UR_AQP|PoolScoreQuaternary:string (pool-id:string)
        @doc "Reads score-quaternary slot from pool row."
        (at "score-quaternary" (read AQP|T|Pool pool-id ["score-quaternary"]))
    )
    (defun UR_AQP|PoolScoreQuinary:string (pool-id:string)
        @doc "Reads score-quinary slot from pool row."
        (at "score-quinary" (read AQP|T|Pool pool-id ["score-quinary"]))
    )
    (defun UR_AQP|PoolScoreSenary:string (pool-id:string)
        @doc "Reads score-senary slot from pool row."
        (at "score-senary" (read AQP|T|Pool pool-id ["score-senary"]))
    )
    (defun UR_AQP|PoolScoreSeptenary:string (pool-id:string)
        @doc "Reads score-septenary slot from pool row."
        (at "score-septenary" (read AQP|T|Pool pool-id ["score-septenary"]))
    )
    (defun UR_AQP|PoolAqpId:string (pool-id:string)
        @doc "Reads aqp-id field from pool row."
        (at "aqp-id" (read AQP|T|Pool pool-id ["aqp-id"]))
    )
    (defun UR_AQP|PoolStakeEnabled:bool (pool-id:string)
        @doc "Reads stake-enabled from pool row (true at issue; owner may disable to pause new stakes)."
        (at "stake-enabled" (read AQP|T|Pool pool-id ["stake-enabled"]))
    )
    (defun UR_AQP|PoolNns:integer (pool-id:string)
        @doc "#FP1: reads the pool nns occupancy counter — -1 for amount pools (class 0/1); for nonce pools \
            \ (class 2/3/4) the number of occupied nonce positions (0 = tracker empty, the finalize oracle)."
        (at "nns" (read AQP|T|Pool pool-id ["nns"]))
    )
    (defun UR_AQP|UserUnn:integer (pool-id:string beneficiary-id:string)
        @doc "Vacate-v2 §4: reads the (pool, beneficiary) occupancy counter — occupied tracker positions for \
            \ this beneficiary (0 when absent). The fast-vacate drain settles a beneficiary the moment this \
            \ decrements to 0 (their last position drained)."
        (with-default-read AQP|T|UserOccupancy (UCk_UserOccupancy pool-id beneficiary-id)
            {"unn" : 0} {"unn" := u} u)
    )
    (defun UR_AQP|PoolVacateInProgress:bool (pool-id:string)
        @doc "Point read: true while an AQP-VCT vacate session is active on this pool (audit H2 / fix #5)."
        (at "vacate-in-progress" (read AQP|T|Pool pool-id ["vacate-in-progress"]))
    )
    (defun UR_AQP|PoolSweepInProgress:bool (pool-id:string)
        @doc "Point read: true while a re-score sweep (anchor retire/re-price) is active on this pool — blocks new \
            \ stakes AND collect until the sweep completes (the aggregate-promile is in flux; sweep D3)."
        (at "sweep-in-progress" (read AQP|T|Pool pool-id ["sweep-in-progress"]))
    )
    ;;
    (defun UR_AQP|DPTFTracker:object{AcquisitionSchemasV1.AQP|TrueFungibleTracker}
        (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads DPTF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPTFTracker (UCk_DPTFTracker pool-id dptf-id owner-id beneficiary-id)
            (UDC_AQP|TrueFungibleTracker 0.0 pool-id dptf-id owner-id beneficiary-id)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dptf-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid}
            (UDC_AQP|TrueFungibleTracker bal pid did oid bid)
        )
    )
    (defun UR_AQP|DPTFTrackerBalance:decimal (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads staked DPTF balance from tracker row."
        (at "balance" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerPoolId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads pool-id from DPTF tracker row."
        (at "pool-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerDptfId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads dptf-id from DPTF tracker row."
        (at "dptf-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerOwnerId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads owner-id from DPTF tracker row."
        (at "owner-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    (defun UR_AQP|DPTFTrackerBeneficiaryId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads beneficiary-id from DPTF tracker row."
        (at "beneficiary-id" (UR_AQP|DPTFTracker pool-id dptf-id owner-id beneficiary-id))
    )
    ;;
    (defun UR_AQP|BenDptfTotal:object{AcquisitionSchemasV1.AQP|BenDptfTotal}
        (beneficiary-id:string dptf-id:string)
        @doc "Reads cross-pool DPTF stake rollup for beneficiary × dptf-id; absent row reads as zero total."
        (with-default-read AQP|T|BenDptfTotal (UCk_BenDptfTotal beneficiary-id dptf-id)
            (UDC_AQP|BenDptfTotal 0.0 0 beneficiary-id dptf-id)
            {"total-balance"        := tb
            ,"last-ank-sync-count"  := sc
            ,"beneficiary-id"       := bid
            ,"dptf-id"              := did}
            (UDC_AQP|BenDptfTotal tb sc bid did)
        )
    )
    (defun UR_AQP|BenDptfTotalBalance:decimal (beneficiary-id:string dptf-id:string)
        @doc "Total DPTF staked by beneficiary across all pools for this exact dptf-id leg."
        (at "total-balance" (UR_AQP|BenDptfTotal beneficiary-id dptf-id))
    )
    (defun UR_AQP|BenDptfLastAnkSyncCount:integer (beneficiary-id:string dptf-id:string)
        @doc "ANK anchors-active count recorded at last anchor sync for this beneficiary × dptf-id."
        (at "last-ank-sync-count" (UR_AQP|BenDptfTotal beneficiary-id dptf-id))
    )
    (defun URC_BenDptfAnchorsNeedSync:bool (beneficiary-id:string dptf-id:string)
        @doc "True when beneficiary has positive cross-pool stake on dptf-id and ANK has more live anchors \
            \ than were applied at last sync — UI signal for C_SyncTrueFungibleAnchors."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (total:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (last-sync:integer (UR_AQP|BenDptfLastAnkSyncCount beneficiary-id dptf-id))
                (live-count:integer (ref-ANK::UR_AA|AnchorsActive dptf-id))
            )
            (and (> total 0.0) (> live-count last-sync))
        )
    )
    ;;
    (defun UR_AQP|BenDpsfNonceTotal:object{AcquisitionSchemasV1.AQP|BenDpsfNonceTotal}
        (beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Reads cross-pool per-nonce DPSF rollup; absent row reads as zero amount."
        (with-default-read AQP|T|BenDpsfNonceTotal
            (UCk_BenDpsfNonceTotal beneficiary-id dpsf-id nonce)
            (UDC_AQP|BenDpsfNonceTotal 0 beneficiary-id dpsf-id nonce)
            {"amount"           := amt
            ,"beneficiary-id"   := bid
            ,"dpsf-id"          := did
            ,"nonce"            := n}
            (UDC_AQP|BenDpsfNonceTotal amt bid did n)
        )
    )
    (defun UR_AQP|BenDpsfNonceAmount:integer (beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Staked integer supply on one DPSF nonce across all pools for (beneficiary, dpsf-id)."
        (at "amount" (UR_AQP|BenDpsfNonceTotal beneficiary-id dpsf-id nonce))
    )
    (defun UR_AQP|BenDpsfAnkMeta:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta}
        (beneficiary-id:string dpsf-id:string)
        @doc "Reads ANK sync metadata for one DPSF leg; absent row reads as never synced / no active nonces."
        (with-default-read AQP|T|BenDpsfAnkMeta
            (UCk_BenDpsfAnkMeta beneficiary-id dpsf-id)
            (UDC_AQP|BenDpsfAnkMeta 0 0 beneficiary-id dpsf-id)
            {"last-ank-sync-count"  := sc
            ,"active-nonce-count"   := anc
            ,"beneficiary-id"       := bid
            ,"dpsf-id"              := did}
            (UDC_AQP|BenDpsfAnkMeta sc anc bid did)
        )
    )
    (defun UR_AQP|BenDpsfLastAnkSyncCount:integer (beneficiary-id:string dpsf-id:string)
        @doc "ANK anchors-active count recorded at last DPSF anchor sync for (beneficiary, dpsf-id)."
        (at "last-ank-sync-count" (UR_AQP|BenDpsfAnkMeta beneficiary-id dpsf-id))
    )
    (defun UR_AQP|BenDpsfActiveNonceCount:integer (beneficiary-id:string dpsf-id:string)
        @doc "O(1) count of positive BenDpsfNonceTotal rows — defcap-safe has-stake signal."
        (at "active-nonce-count" (UR_AQP|BenDpsfAnkMeta beneficiary-id dpsf-id))
    )
    (defun URC_BenDpsfHasStake:bool (beneficiary-id:string dpsf-id:string)
        @doc "True when beneficiary has any positive DPSF per-nonce rollup under dpsf-id (O(1) meta counter)."
        (> (UR_AQP|BenDpsfActiveNonceCount beneficiary-id dpsf-id) 0)
    )
    (defun URC_BenDpsfAnchorsNeedSync:bool (beneficiary-id:string dpsf-id:string)
        @doc "True when beneficiary has active DPSF stake and ANK has more live anchors on dpsf-id than at last sync."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (last-sync:integer (UR_AQP|BenDpsfLastAnkSyncCount beneficiary-id dpsf-id))
                (live-count:integer (ref-ANK::UR_AA|AnchorsActive dpsf-id))
            )
            (and (URC_BenDpsfHasStake beneficiary-id dpsf-id) (> live-count last-sync))
        )
    )
    ;;
    (defun UR_AQP|BenDpnfNonceTotal:object{AcquisitionSchemasV1.AQP|BenDpnfNonceTotal}
        (beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Reads cross-pool per-nonce DPNF rollup; absent row reads as zero amount."
        (with-default-read AQP|T|BenDpnfNonceTotal
            (UCk_BenDpnfNonceTotal beneficiary-id dpnf-id nonce)
            (UDC_AQP|BenDpnfNonceTotal 0 beneficiary-id dpnf-id nonce)
            {"amount"           := amt
            ,"beneficiary-id"   := bid
            ,"dpnf-id"          := nid
            ,"nonce"            := n}
            (UDC_AQP|BenDpnfNonceTotal amt bid nid n)
        )
    )
    (defun UR_AQP|BenDpnfNonceAmount:integer (beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Staked integer supply on one DPNF nonce across all pools for (beneficiary, dpnf-id)."
        (at "amount" (UR_AQP|BenDpnfNonceTotal beneficiary-id dpnf-id nonce))
    )
    (defun UR_AQP|BenDpnfAnkMeta:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta}
        (beneficiary-id:string dpnf-id:string)
        @doc "Reads ANK sync metadata for one DPNF leg; absent row reads as never synced / no active nonces."
        (with-default-read AQP|T|BenDpnfAnkMeta
            (UCk_BenDpnfAnkMeta beneficiary-id dpnf-id)
            (UDC_AQP|BenDpnfAnkMeta 0 0 beneficiary-id dpnf-id)
            {"last-ank-sync-count"  := sc
            ,"active-nonce-count"   := anc
            ,"beneficiary-id"       := bid
            ,"dpnf-id"              := nid}
            (UDC_AQP|BenDpnfAnkMeta sc anc bid nid)
        )
    )
    (defun UR_AQP|BenDpnfLastAnkSyncCount:integer (beneficiary-id:string dpnf-id:string)
        @doc "ANK anchors-active count recorded at last DPNF anchor sync for (beneficiary, dpnf-id)."
        (at "last-ank-sync-count" (UR_AQP|BenDpnfAnkMeta beneficiary-id dpnf-id))
    )
    (defun UR_AQP|BenDpnfActiveNonceCount:integer (beneficiary-id:string dpnf-id:string)
        @doc "O(1) count of positive BenDpnfNonceTotal rows — defcap-safe has-stake signal."
        (at "active-nonce-count" (UR_AQP|BenDpnfAnkMeta beneficiary-id dpnf-id))
    )
    (defun URC_BenDpnfHasStake:bool (beneficiary-id:string dpnf-id:string)
        @doc "True when beneficiary has any positive DPNF per-nonce rollup under dpnf-id (O(1) meta counter)."
        (> (UR_AQP|BenDpnfActiveNonceCount beneficiary-id dpnf-id) 0)
    )
    (defun URC_BenDpnfAnchorsNeedSync:bool (beneficiary-id:string dpnf-id:string)
        @doc "True when beneficiary has active DPNF stake and ANK has more live anchors on dpnf-id than at last sync."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (last-sync:integer (UR_AQP|BenDpnfLastAnkSyncCount beneficiary-id dpnf-id))
                (live-count:integer (ref-ANK::UR_AA|AnchorsActive dpnf-id))
            )
            (and (URC_BenDpnfHasStake beneficiary-id dpnf-id) (> live-count last-sync))
        )
    )
    ;;
    (defun UR_AQP|DPOFTracker:object{AcquisitionSchemasV1.AQP|OrtoFungibleTracker}
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPOF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPOFTracker (UCk_DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce)
            (UDC_AQP|OrtoFungibleTracker 0.0 pool-id dpof-id owner-id beneficiary-id nonce)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dpof-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid
            ,"nonce"            := n}
            (UDC_AQP|OrtoFungibleTracker bal pid did oid bid n)
        )
    )
    (defun UR_AQP|DPOFTrackerBalance:decimal (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads staked DPOF balance from tracker row."
        (at "balance" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerPoolId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads pool-id from DPOF tracker row."
        (at "pool-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerDpofId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads dpof-id from DPOF tracker row."
        (at "dpof-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerOwnerId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads owner-id from DPOF tracker row."
        (at "owner-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerBeneficiaryId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads beneficiary-id from DPOF tracker row."
        (at "beneficiary-id" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPOFTrackerNonce:integer (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads nonce from DPOF tracker row."
        (at "nonce" (UR_AQP|DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce))
    )
    ;;
    (defun UR_AQP|DPSFTracker:object{AcquisitionSchemasV1.AQP|SemiFungibleTracker}
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPSF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPSFTracker (UCk_DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce)
            (UDC_AQP|SemiFungibleTracker 0.0 pool-id dpsf-id owner-id beneficiary-id nonce)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dpsf-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid
            ,"nonce"            := n}
            (UDC_AQP|SemiFungibleTracker bal pid did oid bid n)
        )
    )
    (defun UR_AQP|DPSFTrackerBalance:decimal (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads staked DPSF balance from tracker row."
        (at "balance" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerPoolId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads pool-id from DPSF tracker row."
        (at "pool-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerDpsfId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads dpsf-id from DPSF tracker row."
        (at "dpsf-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerOwnerId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads owner-id from DPSF tracker row."
        (at "owner-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerBeneficiaryId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads beneficiary-id from DPSF tracker row."
        (at "beneficiary-id" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPSFTrackerNonce:integer (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads nonce from DPSF tracker row."
        (at "nonce" (UR_AQP|DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce))
    )
    ;;
    (defun UR_AQP|DPNFTracker:object{AcquisitionSchemasV1.AQP|NonFungibleTracker}
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPNF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPNFTracker (UCk_DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce)
            (UDC_AQP|NonFungibleTracker 0.0 pool-id dpnf-id owner-id beneficiary-id nonce)
            {"balance"          := bal
            ,"pool-id"          := pid
            ,"dpnf-id"          := did
            ,"owner-id"         := oid
            ,"beneficiary-id"   := bid
            ,"nonce"            := n}
            (UDC_AQP|NonFungibleTracker bal pid did oid bid n)
        )
    )
    (defun UR_AQP|DPNFTrackerBalance:decimal (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads staked DPNF balance from tracker row."
        (at "balance" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerPoolId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads pool-id from DPNF tracker row."
        (at "pool-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerDpnfId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads dpnf-id from DPNF tracker row."
        (at "dpnf-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerOwnerId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads owner-id from DPNF tracker row."
        (at "owner-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerBeneficiaryId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads beneficiary-id from DPNF tracker row."
        (at "beneficiary-id" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    (defun UR_AQP|DPNFTrackerNonce:integer (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads nonce from DPNF tracker row."
        (at "nonce" (UR_AQP|DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce))
    )
    ;;
    (defun URC_AqpOwnerKontoFromClassAndAsset:string (aqp-class:integer asset-id:string)
        @doc "Resolve pool governor konto from aqp-class and canonical native asset-id (issue-time or pre-pool-row)."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (if (= aqp-class 0)
                (ref-SWP::UR_OwnerKonto (ref-SWP::UR_GetLpSwpair asset-id))
                (if (= aqp-class 1)
                    (ref-DPTF::UR_Konto asset-id)
                    (if (= aqp-class 2)
                        (ref-DPOF::UR_Konto asset-id)
                        (if (= aqp-class 3)
                            (ref-DPDC::UR_OwnerKonto asset-id true)
                            (ref-DPDC::UR_OwnerKonto asset-id false)
                        )
                    )
                )
            )
        )
    )
    (defun URC_AqpOwnerKonto:string (pool-id:string)
        @doc "Resolve pool governor konto from AQP|T|Pool via URC_AqpOwnerKontoFromClassAndAsset."
        (URC_AqpOwnerKontoFromClassAndAsset (UR_AQP|PoolAqpClass pool-id) (UR_AQP|PoolAssetId pool-id))
    )
    (defun URC_PoolActiveScoreIds:[string] (pool-id:string)
        @doc "Non-BAR score-id values currently assigned on pool-id (primary through septenary order)."
        (filter
            (lambda (sid:string) (!= sid BAR))
            [
                (UR_AQP|PoolScorePrimary pool-id)
                (UR_AQP|PoolScoreSecondary pool-id)
                (UR_AQP|PoolScoreTertiary pool-id)
                (UR_AQP|PoolScoreQuaternary pool-id)
                (UR_AQP|PoolScoreQuinary pool-id)
                (UR_AQP|PoolScoreSenary pool-id)
                (UR_AQP|PoolScoreSeptenary pool-id)
            ]
        )
    )
    (defun URC_StakeTrueFungibleDptfMatchesPool:bool (pool-id:string dptf-id:string)
        @doc "True when dptf-id (native or F| frozen leg) matches pool canonical asset-id for class 0/1 TF stake."
        (let
            (
                (c:integer (UR_AQP|PoolAqpClass pool-id))
                (asset-id:string (UR_AQP|PoolAssetId pool-id))
                (core:string
                    (if (= (URC_DptfLegPrefix dptf-id) "F|")
                        (drop 2 dptf-id)
                        dptf-id
                    )
                )
            )
            (if (= c 1)
                (= core asset-id)
                (if (= c 0)
                    (and (URC_DptfIsLpNomenclature dptf-id) (= core asset-id))
                    false
                )
            )
        )
    )
    (defun URC_PoolScoreSlotValue:string (pool-id:string slot-index:integer)
        @doc "Score-id at pool score slot 0..6 (primary..septenary); read via UR_AQP|PoolScore* helpers."
        (if (= slot-index 0)
            (UR_AQP|PoolScorePrimary pool-id)
            (if (= slot-index 1)
                (UR_AQP|PoolScoreSecondary pool-id)
                (if (= slot-index 2)
                    (UR_AQP|PoolScoreTertiary pool-id)
                    (if (= slot-index 3)
                        (UR_AQP|PoolScoreQuaternary pool-id)
                        (if (= slot-index 4)
                            (UR_AQP|PoolScoreQuinary pool-id)
                            (if (= slot-index 5)
                                (UR_AQP|PoolScoreSenary pool-id)
                                (UR_AQP|PoolScoreSeptenary pool-id)
                            )
                        )
                    )
                )
            )
        )
    )
    (defun URC_PriorScoreSlotsOccupied:bool (pool-id:string slot-index:integer)
        @doc "Every slot index below slot-index is non-BAR; vacuously true when slot-index is 0."
        (if (= slot-index 0)
            true
            (fold (and) true
                (map
                    (lambda (i:integer) (!= (URC_PoolScoreSlotValue pool-id i) BAR))
                    (enumerate 0 (- slot-index 1))
                )
            )
        )
    )
    (defun URC_FirstFreeScoreSlotIndex:integer (pool-id:string)
        @doc "First empty score slot index 0..6 (primary..septenary), or -1 when all slots are taken."
        (if (= (UR_AQP|PoolScorePrimary pool-id) BAR)
            0
            (if (= (UR_AQP|PoolScoreSecondary pool-id) BAR)
                1
                (if (= (UR_AQP|PoolScoreTertiary pool-id) BAR)
                    2
                    (if (= (UR_AQP|PoolScoreQuaternary pool-id) BAR)
                        3
                        (if (= (UR_AQP|PoolScoreQuinary pool-id) BAR)
                            4
                            (if (= (UR_AQP|PoolScoreSenary pool-id) BAR)
                                5
                                (if (= (UR_AQP|PoolScoreSeptenary pool-id) BAR)
                                    6
                                    -1
                                )
                            )
                        )
                    )
                )
            )
        )
    )
    (defun URC_ScoreSlotIndexForScore:integer (pool-id:string score-id:string)
        @doc "Slot index 0..6 where score-id is assigned on pool-id, or -1 when not employed."
        (let
            (
                (lst:[string]
                    [
                        (UR_AQP|PoolScorePrimary pool-id)
                        (UR_AQP|PoolScoreSecondary pool-id)
                        (UR_AQP|PoolScoreTertiary pool-id)
                        (UR_AQP|PoolScoreQuaternary pool-id)
                        (UR_AQP|PoolScoreQuinary pool-id)
                        (UR_AQP|PoolScoreSenary pool-id)
                        (UR_AQP|PoolScoreSeptenary pool-id)
                    ]
                )
            )
            (cond
                ((= score-id (at 0 lst)) 0)
                ((= score-id (at 1 lst)) 1)
                ((= score-id (at 2 lst)) 2)
                ((= score-id (at 3 lst)) 3)
                ((= score-id (at 4 lst)) 4)
                ((= score-id (at 5 lst)) 5)
                ((= score-id (at 6 lst)) 6)
                -1
            )
        )
    )
    (defun URC_NoEmployedBoostLinkTarget:bool (pool-id:string score-id:string)
        @doc "True when no other employed pool score has boost-link pointing at score-id (triplet hub protection)."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                ;;
                (active-ids:[string] (URC_PoolActiveScoreIds pool-id))
            )
            (fold (and) true
                (map
                    (lambda (peer-id:string)
                        (if (= peer-id score-id)
                            true
                            (!= (ref-SCR::UR_SCR|ScoreBoostLink peer-id) score-id)
                        )
                    )
                    active-ids
                )
            )
        )
    )
    (defun URC_DptfLegPrefix:string (dptf-id:string)
        @doc "First two characters of dptf-id (F|, R|, S|, W|, P|, or empty for short ids)."
        (take 2 dptf-id)
    )
    (defun URC_DptfStakeIsNativeLeg:bool (dptf-id:string)
        @doc "True when dptf-id is a native TF stake leg (not F| frozen prefix). Used for SCORE native-or-frozen internal flag."
        (!= (URC_DptfLegPrefix dptf-id) "F|")
    )
    (defun URC_DptfStakeIsReservedLeg:bool (dptf-id:string)
        @doc "True when dptf-id is R| reserved — stake paths reject this leg."
        (= (URC_DptfLegPrefix dptf-id) "R|")
    )
    (defun URC_DptfIsLpNomenclature:bool (dptf-id:string)
        @doc "True when dptf-id (after optional F| strip) uses LP token nomenclature S|, W|, or P|."
        (let
            (
                (p2:string (URC_DptfLegPrefix dptf-id))
                (core:string
                    (if (= p2 "F|")
                        (drop 2 dptf-id)
                        dptf-id
                    )
                )
            )
            (contains (take 2 core) ["S|" "W|" "P|"])
        )
    )
    (defun URC_PoolHasEmployedScores:bool (pool-id:string)
        @doc "True when pool-id has at least one non-BAR score slot (required before stake)."
        (> (length (URC_PoolActiveScoreIds pool-id)) 0)
    )
    (defun URC_PoolStakeAdmissionOk:bool (pool-id:string)
        @doc "True when stake-enabled, pool has ≥1 employed score, AND no vacate session NOR re-score sweep is in \
            \ progress (stake direction only). The vacate guard blocks new stakes mid-vacate (audit H2 / fix #5); \
            \ the sweep guard blocks new stakes mid-sweep so the recompute set stays bounded (sweep D3)."
        (fold (and) true
            [
                (UR_AQP|PoolStakeEnabled pool-id)
                (URC_PoolHasEmployedScores pool-id)
                (not (UR_AQP|PoolVacateInProgress pool-id))
                (not (UR_AQP|PoolSweepInProgress pool-id))
            ]
        )
    )
    (defun URC_PoolUnstakeAdmissionOk:bool (pool-id:string)
        @doc "True when the UNSTAKE direction is allowed: the pool must NOT be vacate-in-progress. A vacate session \
            \ (begin→finalize) force-unwinds every staker itself, so a concurrent user-initiated unstake would race \
            \ the same tracker/aggregate rows the drain writes — freeze it until finalize. (Unlike stake admission, \
            \ this does NOT require stake-enabled or employed scores — exiting a disabled/empty pool stays allowed.)"
        (not (UR_AQP|PoolVacateInProgress pool-id))
    )
    (defun URC_StakeTrueFungiblePoolClassOk:bool (pool-id:string)
        @doc "True when pool aqp-class is 0 (LP via TF) or 1 (non-LP DPTF)."
        (let
            (
                (c:integer (UR_AQP|PoolAqpClass pool-id))
            )
            (or (= c 0) (= c 1))
        )
    )
    (defun URC_StakeOrtoFungiblePoolClassOk:bool (pool-id:string)
        @doc "True when pool aqp-class is 0 (LP + Z| orto), 1 (DPTF + sleep/hib DPOF satellites), or 2 (native DPOF)."
        (let
            (
                (c:integer (UR_AQP|PoolAqpClass pool-id))
            )
            (or (= c 0) (or (= c 1) (= c 2)))
        )
    )
    (defun URC_DpofLegPrefix:string (dpof-id:string)
        @doc "First two characters of dpof-id (Z|, H|, or native collection prefix)."
        (take 2 dpof-id)
    )
    (defun URC_StakeOrtoFungibleDpofMatchesPool:bool (pool-id:string dpof-id:string)
        @doc "True when dpof-id is an allowed OF leg for pool aqp-class and canonical asset-id: \
            \ class 2 native circulating; class 1 Z|/H| satellite linked to pool DPTF; class 0 Z| orto LP linked to pool native LP."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (c:integer (UR_AQP|PoolAqpClass pool-id))
                (asset-id:string (UR_AQP|PoolAssetId pool-id))
                (p2:string (URC_DpofLegPrefix dpof-id))
            )
            (if (= c 2)
                (and
                    (= dpof-id asset-id)
                    (not (contains p2 ["Z|" "H|"]))
                )
                (if (= c 1)
                    (or
                        (and (= p2 "Z|") (= (ref-DPOF::UR_Sleeping dpof-id) asset-id))
                        (and (= p2 "H|") (= (ref-DPOF::UR_Hibernation dpof-id) asset-id))
                    )
                    (if (= c 0)
                        (and
                            (= p2 "Z|")
                            (and
                                (URC_DptfIsLpNomenclature asset-id)
                                (= (ref-DPOF::UR_Sleeping dpof-id) asset-id)
                            )
                        )
                        false
                    )
                )
            )
        )
    )
    (defun URC_OrtoUnstakeNoncesSufficient:bool
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "Unstake: each nonce has tracker balance ≥ unstake amount at the exact (owner, beneficiary) row. \
            \ M5: beneficiary-id is caller-supplied (self OR foreign), not a self-key derivation."
        (let
            (
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
                                (bal:decimal (UR_AQP|DPOFTrackerBalance pool-id dpof-id owner-id beneficiary-id n))
                            )
                            (>= bal q)
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_StakeCollectablePoolClassOk:bool (pool-id:string son:bool)
        @doc "True when pool aqp-class matches son: true→3 (DPSF), false→4 (DPNF)."
        (= (UR_AQP|PoolAqpClass pool-id) (if son 3 4))
    )
    (defun URC_StakeCollectableMatchesPool:bool (pool-id:string collectable-id:string)
        @doc "True when collectable-id equals pool canonical asset-id."
        (= collectable-id (UR_AQP|PoolAssetId pool-id))
    )
    (defun URC_CollectableUnstakeNoncesSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Unstake: each nonce has tracker balance ≥ unstake amount at the exact (owner, beneficiary) row. \
            \ M5: beneficiary-id is caller-supplied (self OR foreign), not a self-key derivation."
        (let
            (
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
                                        (UR_AQP|DPSFTrackerBalance pool-id collectable-id owner-id beneficiary-id n)
                                        (UR_AQP|DPNFTrackerBalance pool-id collectable-id owner-id beneficiary-id n)
                                    )
                                )
                            )
                            (>= bal (dec q))
                        )
                    )
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun URC_BenCollectableHasStake:bool (beneficiary-id:string collectable-id:string son:bool)
        @doc "True when beneficiary has active cross-pool collectable rollup (son dispatches DPSF vs DPNF table)."
        (if son
            (URC_BenDpsfHasStake beneficiary-id collectable-id)
            (URC_BenDpnfHasStake beneficiary-id collectable-id)
        )
    )
    (defun URC_CollectableUnstakeRollupSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Unstake: each nonce has cross-pool Ben* nonce rollup amount ≥ unstake amount for the beneficiary. \
            \ M5: beneficiary-id is caller-supplied (self OR foreign), not a self-key derivation."
        (let
            (
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
                                        (UR_AQP|BenDpsfNonceAmount beneficiary-id collectable-id n)
                                        (UR_AQP|BenDpnfNonceAmount beneficiary-id collectable-id n)
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
    ;;
    (defun UR_AQP|PoolVacateSession:object
        (pool-id:string)
        @doc "Pool-row vacate session observability (AQP|T|Pool fields)."
        (read AQP|T|Pool pool-id
            ["vacate-in-progress"])
    )
    ;; [URH] heavy-read
    ;; WU_BenDpnfAnkMeta|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpnfAnkMeta|DpnfId — select key; WU not needed.
    ;;
    ;; Reads follow schema order: (1) AQP|Schema (2) TrueFungibleTracker (2b) BenDptfTotal \
    ;;     (2c) BenDpsf* + BenDpnf* rollups \
    ;;     (3) OrtoFungibleTracker (4) SemiFungibleTracker (5) NonFungibleTracker
    ;;
    (defun URH_AQP|AllPoolIds:[string] ()
        @doc "Returns all row keys from AQP|T|Pool."
        (keys AQP|T|Pool)
    )
    (defun URH_AQP|BenDpsfActiveNonceSupplies:[object] (beneficiary-id:string dpsf-id:string)
        @doc "Nonce × amount objects for (beneficiary, dpsf-id) where rollup amount > 0 — DPSF resync inventory."
        (let
            (
                (results
                    (filter
                        (lambda (x) (> (at "amount" x) 0))
                        (select AQP|T|BenDpsfNonceTotal ["nonce" "amount"]
                            (and?
                                (where "beneficiary-id" (= beneficiary-id))
                                (where "dpsf-id" (= dpsf-id))
                            )
                        )
                    )
                )
            )
            (if (= (length results) 0) [] results)
        )
    )
    (defun URH_AQP|BenDpnfActiveNonceSupplies:[object] (beneficiary-id:string dpnf-id:string)
        @doc "Nonce × amount objects for (beneficiary, dpnf-id) where rollup amount > 0 — DPNF resync inventory."
        (let
            (
                (results
                    (filter
                        (lambda (x) (> (at "amount" x) 0))
                        (select AQP|T|BenDpnfNonceTotal ["nonce" "amount"]
                            (and?
                                (where "beneficiary-id" (= beneficiary-id))
                                (where "dpnf-id" (= dpnf-id))
                            )
                        )
                    )
                )
            )
            (if (= (length results) 0) [] results)
        )
    )
    (defun URH_AQP|ActiveDptfTrackerRows:[object] (pool-id:string dptf-id:string)
        @doc "Core pool read: active DPTF tracker rows (balance>0) for pool×asset."
        (filter
            (lambda (row:object) (> (at "balance" row) 0.0))
            (select AQP|T|DPTFTracker ["owner-id" "beneficiary-id" "balance"]
                (and?
                    (where "pool-id" (= pool-id))
                    (where "dptf-id" (= dptf-id))
                )
            )
        )
    )
    (defun URH_AQP|ActiveDpofTrackerRows:[object] (pool-id:string dpof-id:string)
        @doc "Core pool read: active DPOF tracker rows (balance>0) for pool×asset."
        (map
            (lambda (row:object)
                {"owner-id": (at "owner-id" row), "beneficiary-id": (at "beneficiary-id" row),
                 "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter
                (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPOFTracker ["owner-id" "beneficiary-id" "nonce" "balance"]
                    (and?
                        (where "pool-id" (= pool-id))
                        (where "dpof-id" (= dpof-id))
                    )
                )
            )
        )
    )
    (defun URH_AQP|ActiveDpsfTrackerRows:[object] (pool-id:string dpsf-id:string)
        @doc "Core pool read: active DPSF tracker rows (balance>0) for pool×asset."
        (map
            (lambda (row:object)
                {"owner-id": (at "owner-id" row), "beneficiary-id": (at "beneficiary-id" row),
                 "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter
                (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPSFTracker ["owner-id" "beneficiary-id" "nonce" "balance"]
                    (and?
                        (where "pool-id" (= pool-id))
                        (where "dpsf-id" (= dpsf-id))
                    )
                )
            )
        )
    )
    (defun URH_AQP|ActiveDpnfTrackerRows:[object] (pool-id:string dpnf-id:string)
        @doc "Core pool read: active DPNF tracker rows (balance>0) for pool×asset."
        (map
            (lambda (row:object)
                {"owner-id": (at "owner-id" row), "beneficiary-id": (at "beneficiary-id" row),
                 "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter
                (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPNFTracker ["owner-id" "beneficiary-id" "nonce" "balance"]
                    (and?
                        (where "pool-id" (= pool-id))
                        (where "dpnf-id" (= dpnf-id))
                    )
                )
            )
        )
    )
    ;;
    ;; ── M5 (#14) UI OBSERVABILITY ──────────────────────────────────────────────
    ;; Cross-pool, dirty-read `select` helpers over the trackers (no maintained tables). For a user U:
    ;;   ByOwner(U)       → every leg U staked (as owner). Split: self = rows where beneficiary-id = U;
    ;;                       staked-for-others = rows where beneficiary-id != U.  (answers query A + B)
    ;;   ByBeneficiary(U) → every leg staked FOR U (as beneficiary). gifted-by-others = rows where owner-id != U.
    ;;                       (answers query C; owner-id = U rows are U's own self-stakes)
    ;; TF is amount-based (no nonce); OF/SF/NF carry nonce + amount. Rows include pool-id + asset-id + the
    ;; counterparty so the UI can display everything and has all inputs for any unstake.
    (defun URH_AQP|DptfStakesByOwner:[object] (owner-id:string)
        @doc "UI: all TF legs where OWNER = owner-id (balance>0), cross-pool. Row: {pool-id, dptf-id, beneficiary-id, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dptf-id": (at "dptf-id" row),
                 "beneficiary-id": (at "beneficiary-id" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPTFTracker ["pool-id" "dptf-id" "beneficiary-id" "balance"]
                    (where "owner-id" (= owner-id))))
        )
    )
    (defun URH_AQP|DptfStakesByBeneficiary:[object] (beneficiary-id:string)
        @doc "UI: all TF legs where BENEFICIARY = beneficiary-id (balance>0), cross-pool. Row: {pool-id, dptf-id, owner-id, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dptf-id": (at "dptf-id" row),
                 "owner-id": (at "owner-id" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPTFTracker ["pool-id" "dptf-id" "owner-id" "balance"]
                    (where "beneficiary-id" (= beneficiary-id))))
        )
    )
    (defun URH_AQP|DpofStakesByOwner:[object] (owner-id:string)
        @doc "UI: all OF legs where OWNER = owner-id (balance>0), cross-pool. Row: {pool-id, dpof-id, beneficiary-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpof-id": (at "dpof-id" row),
                 "beneficiary-id": (at "beneficiary-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPOFTracker ["pool-id" "dpof-id" "beneficiary-id" "nonce" "balance"]
                    (where "owner-id" (= owner-id))))
        )
    )
    (defun URH_AQP|DpofStakesByBeneficiary:[object] (beneficiary-id:string)
        @doc "UI: all OF legs where BENEFICIARY = beneficiary-id (balance>0), cross-pool. Row: {pool-id, dpof-id, owner-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpof-id": (at "dpof-id" row),
                 "owner-id": (at "owner-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPOFTracker ["pool-id" "dpof-id" "owner-id" "nonce" "balance"]
                    (where "beneficiary-id" (= beneficiary-id))))
        )
    )
    (defun URH_AQP|DpsfStakesByOwner:[object] (owner-id:string)
        @doc "UI: all SF legs where OWNER = owner-id (balance>0), cross-pool. Row: {pool-id, dpsf-id, beneficiary-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpsf-id": (at "dpsf-id" row),
                 "beneficiary-id": (at "beneficiary-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPSFTracker ["pool-id" "dpsf-id" "beneficiary-id" "nonce" "balance"]
                    (where "owner-id" (= owner-id))))
        )
    )
    (defun URH_AQP|DpsfStakesByBeneficiary:[object] (beneficiary-id:string)
        @doc "UI: all SF legs where BENEFICIARY = beneficiary-id (balance>0), cross-pool. Row: {pool-id, dpsf-id, owner-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpsf-id": (at "dpsf-id" row),
                 "owner-id": (at "owner-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPSFTracker ["pool-id" "dpsf-id" "owner-id" "nonce" "balance"]
                    (where "beneficiary-id" (= beneficiary-id))))
        )
    )
    (defun URH_AQP|DpnfStakesByOwner:[object] (owner-id:string)
        @doc "UI: all NF legs where OWNER = owner-id (balance>0), cross-pool. Row: {pool-id, dpnf-id, beneficiary-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpnf-id": (at "dpnf-id" row),
                 "beneficiary-id": (at "beneficiary-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPNFTracker ["pool-id" "dpnf-id" "beneficiary-id" "nonce" "balance"]
                    (where "owner-id" (= owner-id))))
        )
    )
    (defun URH_AQP|DpnfStakesByBeneficiary:[object] (beneficiary-id:string)
        @doc "UI: all NF legs where BENEFICIARY = beneficiary-id (balance>0), cross-pool. Row: {pool-id, dpnf-id, owner-id, nonce, balance}."
        (map
            (lambda (row:object)
                {"pool-id": (at "pool-id" row), "dpnf-id": (at "dpnf-id" row),
                 "owner-id": (at "owner-id" row), "nonce": (at "nonce" row), "balance": (at "balance" row)}
            )
            (filter (lambda (row:object) (> (at "balance" row) 0.0))
                (select AQP|T|DPNFTracker ["pool-id" "dpnf-id" "owner-id" "nonce" "balance"]
                    (where "beneficiary-id" (= beneficiary-id))))
        )
    )
    ;; [URCi]   cost readers — single source for exec billing + INFO preview (config/sync)
    (defun URCi_Issue:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_Issue" "issue-pool")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_IssueStoa:decimal ()
        @doc "STOA cost for pool-issue: the deterrence expressed in DOLLARS, converted at the live \
            \ STOA price by UC_StoaPrice (issue-pool = $10 => 100 STOA). Previously read the raw \
            \ 'smart' usage price (0.02), a pre-rehaul STOA amount that was never \
            \ dollar-denominated and so ignored the peg entirely."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UC_StoaPrice "issue-pool")
        ))
    (defun URCi_AddScore:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_AddScore" "add-score")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_RevokeScore:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_RevokeScore" "revoke-score")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetPoolStake:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        @doc "Shared by Enable / Disable pool-stake — one component key is exact because \
            \ AQP-POOL|C_EnablePoolStake and C_DisablePoolStake are both 6.0."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_EnablePoolStake" "pool-stake-toggle")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SyncTrueFungibleAnchors:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        @doc "Gas leg for the TF anchor sync; exec concats it with the anchor-repair + meta \
            \ legs (state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_SyncTrueFungibleAnchors" "sync-anchors")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SyncCollectableAnchors:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        @doc "Gas leg for the SF+NF anchor sync; exec concats it with the anchor-repair + \
            \ meta legs (state-dependent). One component key is exact because \
            \ AQP-POOL|C_SyncSemiFungibleAnchors and C_SyncNonFungibleAnchors are both 36.0."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_SyncSemiFungibleAnchors" "sync-anchors")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SyncTrueFungibleAnchorsFull:decimal (beneficiary-id:string dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of C_SyncTrueFungibleAnchors: the read-only mirror of the exec's \
            \ UDC_ConcatenateOutputCumulators [ico-ank ico-meta ico-gas]. ico-ank = ANK anchor-refresh (ignis|small \
            \ x n-live, n-live = live TF anchors on dptf-id) reproducing XE_UpdateTrueFungibleUserAnchorValues; \
            \ ico-meta = the biggest-tier sync-count stamp (XB_SetBenDptfAnkSyncCount); ico-gas = URCi_SyncTrueFungibleAnchors."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (n-live:integer (length (ref-ANK::UR_ANK|AnchorsForAsset dptf-id)))
            )
            (fold (+) 0.0
                [ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-ank
                      (ref-IGNIS::UDC_ConstructOutputCumulator
                          (ref-ANK::URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                          AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-meta
                      (ref-IGNIS::UDC_LegCumulator "ank-sync-count-tf" AQP|SC_NAME))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-gas
                      (URCi_SyncTrueFungibleAnchors [beneficiary-id dptf-id]))
                ])
        ))
    (defun URCi_SyncCollectableAnchorsFull:decimal (beneficiary-id:string collectable-id:string)
        @doc "FULL reconstructed IGNIS ifp of C_SyncCollectableAnchors (SF son=true / NF son=false — cost is \
            \ son-independent). Read-only mirror of the exec's UDC_ConcatenateOutputCumulators [ico-ank ico-meta ico-gas]. \
            \ ico-ank = ANK anchor-refresh (ignis|small x n-live, n-live = live anchors on collectable-id) reproducing \
            \ XE_Resync{Semi,Non}FungibleUserAnchorValues (both use URC_TrueFungibleStakeAnchorRefreshIgnis); ico-meta = \
            \ the biggest-tier sync-count stamp (XB_SetBenCollectableAnkSyncCount); ico-gas = URCi_SyncCollectableAnchors."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (n-live:integer (length (ref-ANK::UR_ANK|AnchorsForAsset collectable-id)))
            )
            (fold (+) 0.0
                [ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-ank
                      (ref-IGNIS::UDC_ConstructOutputCumulator
                          (ref-ANK::URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                          AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-meta
                      (ref-IGNIS::UDC_LegCumulator "ank-sync-count-tf" AQP|SC_NAME))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-gas
                      (URCi_SyncCollectableAnchors [beneficiary-id collectable-id]))
                ])
        ))
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_ScoreDefinitionTargetMatchesPool (score-id:string asset-id:string)
        @doc "Refuses a weight definition written against a collection the score's EMPLOYING POOL \
            \ does not stake. No-op while the score is employed by no pool. \
            \ \
            \ WHY (2026-10-06). A score carries no asset-id -- identity resolves Score -> \
            \ aqpool-link -> Pool -> asset-id -- and the definition write validates the collection \
            \ for EXISTENCE only. Pair that with `undefined nonce => 0` rather than a failure and a \
            \ mistyped collection id writes a full set of structurally valid rows that are NEVER \
            \ read: green transaction, dead weights, no signal anywhere. \
            \ \
            \ TWO POINT READS, NO SCAN, DELIBERATELY. The complete check -- enumerate every asset \
            \ this score has definitions for and reject any that is not the pool's -- needs a \
            \ URH_ table scan, which would make every caller in its tree HEAVY (CC_/AA_ doubling) \
            \ and drag a rename through Talos for a guard that runs on a cold path. This asks the \
            \ cheap half of the question and gets the case that actually bites: writing weights \
            \ for the wrong collection on a score that is already employed, i.e. one that may \
            \ already have stakers. \
            \ \
            \ WHAT IT DOES NOT CATCH, stated so nobody reads more into it: definitions written \
            \ BEFORE the score is employed (aqpool-link is BAR, so there is nothing to compare \
            \ against -- the UI flags these as unverified), and an NF trait-key no staked nonce \
            \ carries, which no id comparison can detect."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                ;;
                (aqpool:string (ref-SCR::UR_SCR|ScoreAqpoolLink score-id))
            )
            (enforce
                (or (= aqpool BAR) (= asset-id (UR_AQP|PoolAssetId aqpool)))
                (format
                    "Score {} is employed by pool {}, which stakes {} -- a definition for {} would score nothing"
                    [score-id aqpool (if (= aqpool BAR) BAR (UR_AQP|PoolAssetId aqpool)) asset-id]
                )
            )
        )
    )
    (defun UEV_IssuePoolClassAndAsset (aqp-class:integer asset-id:string)
        @doc "aqp-class 0..4 and asset-id existence / shape for that class (native id only at issue)."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (p2:string (take 2 asset-id))
                (is-class-ok:bool (contains aqp-class (enumerate 0 4)))
                (is-native:bool
                    (not
                        (fold (or) false
                            [(= p2 "F|") (= p2 "Z|") (= p2 "H|") (= p2 "V|") (= p2 "R|")]
                        )
                    )
                )
            )
            (enforce
                (fold (and) true
                    [
                        is-class-ok
                        is-native
                        (if (<= aqp-class 2)
                            (enforce-one
                                "Invalid pool issue asset-id for aqp-class"
                                [
                                    (enforce
                                        (fold (and) true
                                            [
                                                (= aqp-class 0)
                                                (contains p2 ["S|" "W|" "P|"])
                                                (= asset-id (ref-SWP::UR_TokenLP (ref-SWP::UR_GetLpSwpair asset-id)))
                                            ]
                                        )
                                        "class 0 asset-id must be native LP nomenclature matching its swap pair"
                                    )
                                    (enforce
                                        (fold (and) true
                                            [
                                                (= aqp-class 1)
                                                (not (contains p2 ["S|" "W|" "P|"]))
                                            ]
                                        )
                                        "class 1 asset-id must be a non-LP DPTF"
                                    )
                                    (enforce
                                        (fold (and) true
                                            [
                                                (= aqp-class 2)
                                                (not
                                                    (fold (or) false
                                                        [
                                                            (= (take 2 (ref-DPOF::UR_Ticker asset-id)) "Z|")
                                                            (= (take 2 (ref-DPOF::UR_Ticker asset-id)) "H|")
                                                        ]
                                                    )
                                                )
                                            ]
                                        )
                                        "class 2 asset-id must not be a sleeping or hibernating DPOF collection"
                                    )
                                ]
                            )
                            true
                        )
                    ]
                )
                "Invalid pool issue aqp-class or asset-id"
            )
            (if (or (= aqp-class 0) (= aqp-class 1))
                (ref-DPTF::UEV_id asset-id)
                (if (= aqp-class 2)
                    (ref-DPOF::UEV_id asset-id)
                    (if (= aqp-class 3)
                        (ref-DPDC::UEV_id asset-id true)
                        (ref-DPDC::UEV_id asset-id false)
                    )
                )
            )
        )
    )
    (defun UEV_AddScorePoolAndScore (pool-id:string score-id:string slot-index:integer)
        @doc "Validates slot-index is the first free slot (caller supplies index from one URC_FirstFreeScoreSlotIndex); \
            \ score exists with BAR aqpool-link; score-class matches pool; class-0 lp-denominator fits pool LP pair."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                (aqp-class:integer (UR_AQP|PoolAqpClass pool-id))
                (asset-id:string (UR_AQP|PoolAssetId pool-id))
            )
            (enforce
                (fold (and) true
                    [
                        (contains slot-index (enumerate 0 6))
                        (= (URC_PoolScoreSlotValue pool-id slot-index) BAR)
                        (URC_PriorScoreSlotsOccupied pool-id slot-index)
                    ]
                )
                "Invalid or unavailable score slot index for pool"
            )
            ;;PRODUCED-TRIAGED (_eagerlet --produced, 2026-09-16): this message claims EXISTENCE, and a
            ;;hard read of the same subject raises before it can say so. Not actionable in isolation --
            ;;it is one of SEVEN AQP guards sharing one root cause and one blocker: the readers are
            ;;shared with the INFO_ previews, and `Stage_02/[6.5]_AQP-INFO.repl` is DELIBERATELY
            ;;fixture-free (it passes "SCR-x"/"DPNF-x" to all 83 AQP readers because AQP prices are
            ;;argument-independent) and PINS those aborts. Defaulting a shared reader turns a pinned
            ;;expect-failure red. Full reasoning at 02_SCORE.pact's SCR|XI>X_ISSUE-NF-SCORE-DEFINITION
            ;;and DEFECT-LEDGER G-37..G-41 + 7.2b; 7.3 records the same blocker for RT-K-007's preview half.
            (enforce
                (fold (and) true
                    [
                        (= (ref-SCR::UR_SCR|ScoreScoreId score-id) score-id)
                        (= (ref-SCR::UR_SCR|ScoreAqpoolLink score-id) BAR)
                        (= (ref-SCR::UR_SCR|ScoreClass score-id) aqp-class)
                        (not (contains score-id (URC_PoolActiveScoreIds pool-id)))
                    ]
                )
                "Invalid score-id for pool assignment (missing score, class mismatch, aqpool-link set, or duplicate slot)"
            )
            (enforce
                (if (= aqp-class 0)
                    (let
                        (
                            (lp-denom:string (ref-SCR::UR_SCR|ScoreLpDenominator score-id))
                            (swpair:string (ref-SWP::UR_GetLpSwpair asset-id))
                            (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                        )
                        (contains lp-denom pool-tokens)
                    )
                    true
                )
                "Class 0 score lp-denominator must appear in the swap pair for the pool native LP asset-id"
            )
        )
    )
    (defun UEV_RevokeScorePoolAndScore (pool-id:string score-id:string slot-index:integer)
        @doc "Validates slot-index holds score-id with aqpool-link = pool-id, zero totals, fvt-link BAR, \
            \ and no employed peer has boost-link = score-id (revoke dependents before hub)."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (enforce (!= slot-index -1) "score-id is not assigned to pool")
            (enforce
                (fold (and) true
                    [
                        (contains slot-index (enumerate 0 6))
                        (= (URC_PoolScoreSlotValue pool-id slot-index) score-id)
                        (= (ref-SCR::UR_SCR|ScoreAqpoolLink score-id) pool-id)
                        (= (ref-SCR::UR_SCR|ScoreTotalBaseScore score-id) 0.0)
                        (= (ref-SCR::UR_SCR|ScoreTotalBoostedScore score-id) 0.0)
                        (= (ref-SCR::UR_SCR|ScoreTotalDebScore score-id) 0.0)
                        (= (ref-SCR::UR_SCR|ScoreNzsCount score-id) 0)
                        (= (ref-SCR::UR_SCR|ScoreFvtLink score-id) BAR)
                        (URC_NoEmployedBoostLinkTarget pool-id score-id)
                    ]
                )
                "Invalid score revoke for pool (slot, aqpool-link, zero totals, fvt-link, or boost-link dependents)"
            )
        )
    )
    (defun UEV_StakeBeneficiaryAccount (beneficiary-id:string)
        @doc "Stake paths: beneficiary must exist and be an activated standard (non-principal) Ouronet account."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists beneficiary-id)
            (ref-DALOS::UEV_EnforceAccountType beneficiary-id false)
        )
    )
    (defun UEV_StakeTrueFungibleDptfLeg (dptf-id:string)
        @doc "Reject R| reserved; validate DPTF id exists via DPTF::UEV_id."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (enforce (not (URC_DptfStakeIsReservedLeg dptf-id)) "Reserved DPTF (R|) cannot be staked")
            (ref-DPTF::UEV_id dptf-id)
        )
    )
    (defun UEV_StakeOrtoFungibleDpofLeg (dpof-id:string)
        @doc "Validate issued DPOF id via DPOF::UEV_id."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (ref-DPOF::UEV_id dpof-id)
        )
    )
    (defun UEV_StakeCollectableLeg (collectable-id:string son:bool)
        @doc "Validate issued DPDC collectable id via DPDC::UEV_id."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_id collectable-id son)
        )
    )
    ;;
    (defun UEV_ExecutorIzPoolOwner (executor:string pool-id:string)
        @doc "Enforces that <executor> IS the pool's owner konto -- the SAME value CAP_PoolOwner \
            \ resolves and key-checks, read through the same URC_ so the two can never disagree. \
            \ It does not REPLACE that gate: CAP_PoolOwner proves the signer holds the owner's key, \
            \ this proves the named actor IS that owner. Both are needed, because they are not the \
            \ same question -- a sovereign asset's owner is a SMART account whose key a human holds, \
            \ so the key check passes for an account the caller never names (see 01_ANK, 2026-09-20)."
        (enforce (= executor (URC_AqpOwnerKonto pool-id))
            (format "Executor {} is not the owner of pool {} (owner is {})"
                [executor pool-id (URC_AqpOwnerKonto pool-id)]))
    )
    (defun UEV_ExecutorIzAqpAssetOwner (executor:string aqp-class:integer asset-id:string)
        @doc "Issue-time form of UEV_ExecutorIzPoolOwner: the pool does not exist yet, so the \
            \ authority is derived from the canonical asset for <aqp-class>/<asset-id>, mirroring \
            \ CAP_AqpAssetOwner."
        (enforce (= executor (URC_AqpOwnerKontoFromClassAndAsset aqp-class asset-id))
            (format "Executor {} is not the owner of the canonical asset {} (owner is {})"
                [executor asset-id (URC_AqpOwnerKontoFromClassAndAsset aqp-class asset-id)]))
    )
    (defun CAP_AqpAssetOwner (aqp-class:integer asset-id:string)
        @doc "Issue / pre-pool: tx sender must own the canonical asset for aqp-class and asset-id."
        (let 
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (URC_AqpOwnerKontoFromClassAndAsset aqp-class asset-id))
        )
    )
    (defun CAP_PoolOwner (pool-id:string)
        @doc "Post-issue pool governance: tx sender must own the canonical asset behind pool-id (URC_AqpOwnerKonto)."
        (let 
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (URC_AqpOwnerKonto pool-id))
        )
    )
    (defun CAP_StakeOwner (owner-id:string)
        @doc "Stake / unstake: tx sender must own owner-id (depositor of tokens)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-id)
        )
    )
    ;;{5.5}  Write [W]
    ;; [W]   write
    ;;
    ;; Twelve blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    (defun WI_Pool:string
        (pool-id:string row:object{AcquisitionSchemasV1.AQP|Schema})
        @doc "Insert AQP|T|Pool full row (issue only)."
        (require-capability (SECURE))
        (insert AQP|T|Pool pool-id row)
    )
    ;; WW_Pool — not used: issue path is WI_Pool; other paths use WU_*.
    (defun WU_Pool|StakeEnabled:string
        (pool-id:string enabled:bool)
        @doc "Update stake-enabled on AQP|T|Pool."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id {"stake-enabled": enabled})
    )
    (defun WU_Pool|SweepInProgress:string
        (pool-id:string flag:bool)
        @doc "Update sweep-in-progress on AQP|T|Pool (the re-score sweep freeze)."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id {"sweep-in-progress": flag})
    )
    (defun WU_Pool|ScoreSlot:string
        (pool-id:string slot-index:integer score-id:string)
        @doc "Write score-id into one pool score slot (0=primary .. 6=septenary)."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id (UC_PoolScoreSlotPatch slot-index score-id))
    )
    (defun WU4_Pool|VacateJobState:string
        (pool-id:string vacate-in-progress:bool)
        @doc "Update vacate-in-progress on AQP|T|Pool."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id
            {"vacate-in-progress"   : vacate-in-progress}
        )
    )
    (defun WU_Pool|Nns:string
        (pool-id:string delta:integer)
        @doc "#FP1: add <delta> to the pool nns occupancy counter. Defensive no-op on amount pools (nns=-1) — the \
            \ nonce-tracker slot writers only call this for class 2/3/4, on a 0<->occupied position transition."
        (require-capability (SECURE))
        (let
            (
                (cur:integer (at "nns" (read AQP|T|Pool pool-id ["nns"])))
            )
            (if (= cur -1)
                "nns N/A (amount pool)"
                (update AQP|T|Pool pool-id {"nns" : (+ cur delta)})
            )
        )
    )
    (defun WU_User|Unn:string
        (pool-id:string beneficiary-id:string delta:integer)
        @doc "Vacate-v2 §4: add <delta> to the (pool, beneficiary) occupancy counter, in lockstep with the \
            \ pool nns. Defensive no-op on amount pools (pool nns=-1, i.e. LP) — the tracker slot writers call \
            \ this only on a 0<->occupied transition for occupancy-tracked pools (class 1/2/3/4)."
        (require-capability (SECURE))
        (if (= (at "nns" (read AQP|T|Pool pool-id ["nns"])) -1)
            "unn N/A (amount pool)"
            (with-default-read AQP|T|UserOccupancy (UCk_UserOccupancy pool-id beneficiary-id)
                {"unn" : 0} {"unn" := cur}
                (write AQP|T|UserOccupancy (UCk_UserOccupancy pool-id beneficiary-id)
                    (UDC_AQP|UserOccupancy (+ cur delta) pool-id beneficiary-id))
            )
        )
    )
    (defun WU_Pool|Occupancy:string
        (pool-id:string beneficiary-id:string delta:integer)
        @doc "Vacate-v2: advance BOTH occupancy counters in lockstep on a tracker 0<->occupied transition — the \
            \ pool nns (#FP1) and the (pool, beneficiary) unn (§4). Both share the nns=-1 LP guard internally, so \
            \ this is a no-op on amount pools. The single call every tracker slot writer makes on a transition."
        (require-capability (SECURE))
        (WU_Pool|Nns pool-id delta)
        (WU_User|Unn pool-id beneficiary-id delta)
    )
    (defun WU7_Pool|ScoreSlots:string
        (pool-id:string
            score-primary:string
            score-secondary:string
            score-tertiary:string
            score-quaternary:string
            score-quinary:string
            score-senary:string
            score-septenary:string
        )
        @doc "Replace all seven score slots on AQP|T|Pool (revoke compact path)."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id
            {"score-primary"    : score-primary
            ,"score-secondary"  : score-secondary
            ,"score-tertiary"   : score-tertiary
            ,"score-quaternary" : score-quaternary
            ,"score-quinary"    : score-quinary
            ,"score-senary"     : score-senary
            ,"score-septenary"  : score-septenary}
        )
    )
    ;; WU_Pool|AqpClass — not mutable [.]
    ;; WU_Pool|AssetId — not mutable [.]
    ;; WU_Pool|ScorePrimary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreSecondary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreTertiary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreQuaternary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreQuinary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreSenary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|ScoreSeptenary — not used: mutates via WU_Pool|ScoreSlot or WU7_Pool|ScoreSlots.
    ;; WU_Pool|VacateInProgress — not used: mutates via WU4_Pool|VacateJobState.
    ;; WU_Pool|AqpId — select key; WU not needed.
    ;;
    ;; WI_DPTFTracker — not used: first row touch is WW_DPTFTracker (upsert path).
    (defun WW_DPTFTracker:string
        (pool-id:string dptf-id:string owner-id:string beneficiary-id:string row:object{AcquisitionSchemasV1.AQP|TrueFungibleTracker})
        @doc "Upsert full AQP|T|DPTFTracker row for (pool, dptf, owner, beneficiary)."
        (require-capability (SECURE))
        (write AQP|T|DPTFTracker (UCk_DPTFTracker pool-id dptf-id owner-id beneficiary-id) row)
    )
    ;; WU_DPTFTracker|Balance — not used: mutates via WW_DPTFTracker (full row).
    ;; WU_DPTFTracker|PoolId — select key; WU not needed.
    ;; WU_DPTFTracker|DptfId — select key; WU not needed.
    ;; WU_DPTFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPTFTracker|BeneficiaryId — select key; WU not needed.
    ;;
    ;; WI_DPOFTracker — not used: first row touch is WW_DPOFTracker (upsert path).
    (defun WW_DPOFTracker:string
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer row:object{AcquisitionSchemasV1.AQP|OrtoFungibleTracker})
        @doc "Upsert full AQP|T|DPOFTracker row for (pool, dpof, owner, beneficiary, nonce)."
        (require-capability (SECURE))
        (write AQP|T|DPOFTracker (UCk_DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce) row)
    )
    ;; WU_DPOFTracker|Balance — not used: mutates via WW_DPOFTracker (full row).
    ;; WU_DPOFTracker|PoolId — select key; WU not needed.
    ;; WU_DPOFTracker|DpofId — select key; WU not needed.
    ;; WU_DPOFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPOFTracker|BeneficiaryId — select key; WU not needed.
    ;; WU_DPOFTracker|Nonce — select key; WU not needed.
    ;;
    ;; WI_DPSFTracker — not used: first row touch is WW_DPSFTracker (upsert path).
    (defun WW_DPSFTracker:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer row:object{AcquisitionSchemasV1.AQP|SemiFungibleTracker})
        @doc "Upsert full AQP|T|DPSFTracker row for (pool, dpsf, owner, beneficiary, nonce)."
        (require-capability (SECURE))
        (write AQP|T|DPSFTracker (UCk_DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce) row)
    )
    ;; WU_DPSFTracker|Balance — not used: mutates via WW_DPSFTracker (full row).
    ;; WU_DPSFTracker|PoolId — select key; WU not needed.
    ;; WU_DPSFTracker|DpsfId — select key; WU not needed.
    ;; WU_DPSFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPSFTracker|BeneficiaryId — select key; WU not needed.
    ;; WU_DPSFTracker|Nonce — select key; WU not needed.
    ;;
    ;; WI_DPNFTracker — not used: first row touch is WW_DPNFTracker (upsert path).
    (defun WW_DPNFTracker:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer row:object{AcquisitionSchemasV1.AQP|NonFungibleTracker})
        @doc "Upsert full AQP|T|DPNFTracker row for (pool, dpnf, owner, beneficiary, nonce)."
        (require-capability (SECURE))
        (write AQP|T|DPNFTracker (UCk_DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce) row)
    )
    ;; WU_DPNFTracker|Balance — not used: mutates via WW_DPNFTracker (full row).
    ;; WU_DPNFTracker|PoolId — select key; WU not needed.
    ;; WU_DPNFTracker|DpnfId — select key; WU not needed.
    ;; WU_DPNFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPNFTracker|BeneficiaryId — select key; WU not needed.
    ;; WU_DPNFTracker|Nonce — select key; WU not needed.
    ;;
    ;; WI_BenDptfTotal — not used: first row touch is WW_BenDptfTotal (upsert path).
    (defun WW_BenDptfTotal:string
        (beneficiary-id:string dptf-id:string row:object{AcquisitionSchemasV1.AQP|BenDptfTotal})
        @doc "Upsert full AQP|T|BenDptfTotal row for (beneficiary, dptf-id)."
        (require-capability (SECURE))
        (write AQP|T|BenDptfTotal (UCk_BenDptfTotal beneficiary-id dptf-id) row)
    )
    (defun WU_BenDptfTotal|LastAnkSyncCount:string
        (beneficiary-id:string dptf-id:string row:object{AcquisitionSchemasV1.AQP|BenDptfTotal} sync-count:integer)
        @doc "Update last-ank-sync-count on AQP|T|BenDptfTotal; preserve other fields. \
            \ <row> kept for call-site symmetry with collectable meta WU_*; write uses update (not object-+ merge)."
        (require-capability (SECURE))
        (update AQP|T|BenDptfTotal (UCk_BenDptfTotal beneficiary-id dptf-id)
            {"last-ank-sync-count": sync-count}
        )
    )
    ;; WU_BenDptfTotal|TotalBalance — not used: mutates via WW_BenDptfTotal (full row).
    ;; WU_BenDptfTotal|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDptfTotal|DptfId — select key; WU not needed.
    ;;
    ;; WI_BenDpsfNonceTotal — not used: first row touch is WW_BenDpsfNonceTotal (upsert path).
    (defun WW_BenDpsfNonceTotal:string
        (beneficiary-id:string dpsf-id:string nonce:integer row:object{AcquisitionSchemasV1.AQP|BenDpsfNonceTotal})
        @doc "Upsert full AQP|T|BenDpsfNonceTotal row for (beneficiary, dpsf-id, nonce)."
        (require-capability (SECURE))
        (write AQP|T|BenDpsfNonceTotal (UCk_BenDpsfNonceTotal beneficiary-id dpsf-id nonce) row)
    )
    ;; WU_BenDpsfNonceTotal|Amount — not used: mutates via WW_BenDpsfNonceTotal (full row).
    ;; WU_BenDpsfNonceTotal|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpsfNonceTotal|DpsfId — select key; WU not needed.
    ;; WU_BenDpsfNonceTotal|Nonce — select key; WU not needed.
    ;;
    ;; WI_BenDpnfNonceTotal — not used: first row touch is WW_BenDpnfNonceTotal (upsert path).
    (defun WW_BenDpnfNonceTotal:string
        (beneficiary-id:string dpnf-id:string nonce:integer row:object{AcquisitionSchemasV1.AQP|BenDpnfNonceTotal})
        @doc "Upsert full AQP|T|BenDpnfNonceTotal row for (beneficiary, dpnf-id, nonce)."
        (require-capability (SECURE))
        (write AQP|T|BenDpnfNonceTotal (UCk_BenDpnfNonceTotal beneficiary-id dpnf-id nonce) row)
    )
    ;; WU_BenDpnfNonceTotal|Amount — not used: mutates via WW_BenDpnfNonceTotal (full row).
    ;; WU_BenDpnfNonceTotal|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpnfNonceTotal|DpnfId — select key; WU not needed.
    ;; WU_BenDpnfNonceTotal|Nonce — select key; WU not needed.
    ;;
    ;; WI_BenDpsfAnkMeta — not used: first row touch is WW_BenDpsfAnkMeta (upsert path).
    (defun WW_BenDpsfAnkMeta:string
        (beneficiary-id:string dpsf-id:string row:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta})
        @doc "Upsert full AQP|T|BenDpsfAnkMeta row for (beneficiary, dpsf-id)."
        (require-capability (SECURE))
        (write AQP|T|BenDpsfAnkMeta (UCk_BenDpsfAnkMeta beneficiary-id dpsf-id) row)
    )
    (defun WU_BenDpsfAnkMeta|LastAnkSyncCount:string
        (beneficiary-id:string dpsf-id:string row:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta} sync-count:integer)
        @doc "Update last-ank-sync-count; preserve active-nonce-count from <row>."
        (require-capability (SECURE))
        (write AQP|T|BenDpsfAnkMeta (UCk_BenDpsfAnkMeta beneficiary-id dpsf-id)
            (UDC_AQP|BenDpsfAnkMeta sync-count (at "active-nonce-count" row) beneficiary-id dpsf-id)
        )
    )
    ;; WU_BenDpsfAnkMeta|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpsfAnkMeta|DpsfId — select key; WU not needed.
    ;;
    ;; WI_BenDpnfAnkMeta — not used: first row touch is WW_BenDpnfAnkMeta (upsert path).
    (defun WW_BenDpnfAnkMeta:string
        (beneficiary-id:string dpnf-id:string row:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta})
        @doc "Upsert full AQP|T|BenDpnfAnkMeta row for (beneficiary, dpnf-id)."
        (require-capability (SECURE))
        (write AQP|T|BenDpnfAnkMeta (UCk_BenDpnfAnkMeta beneficiary-id dpnf-id) row)
    )
    (defun WU_BenDpnfAnkMeta|LastAnkSyncCount:string
        (beneficiary-id:string dpnf-id:string row:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta} sync-count:integer)
        @doc "Update last-ank-sync-count; preserve active-nonce-count from <row>."
        (require-capability (SECURE))
        (write AQP|T|BenDpnfAnkMeta (UCk_BenDpnfAnkMeta beneficiary-id dpnf-id)
            (UDC_AQP|BenDpnfAnkMeta sync-count (at "active-nonce-count" row) beneficiary-id dpnf-id)
        )
    )
    ;;{5.6}  Aux/X
    ;; [XI]
    ;;Protection: Class 1 — Innate protection offered by WI_Pool
    (defun XI_IssuePool:string
        (pool-id:string aqp-class:integer asset-id:string)
        @doc "Insert AQP|T|Pool under SECURE (from AQP|C>ISSUE-POOL). Write only; C_Issue builds IGNIS."
        ;; SECURE: granted by WI_Pool (underlying W_).
        (WI_Pool pool-id (UDC_AQP|Schema aqp-class asset-id pool-id))
        pool-id
    )
    ;;Protection: Class 1 — Innate protection offered by WU_Pool|ScoreSlot
    (defun XI_AddScoreToPool:string
        (pool-id:string score-id:string slot-index:integer)
        @doc "Write score-id into the first free slot (0=primary .. 6=septenary). Under SECURE from AQP|C>ADD-SCORE."
        ;; SECURE: granted by WU_Pool|ScoreSlot (underlying W_).
        (WU_Pool|ScoreSlot pool-id slot-index score-id)
        score-id
    )
    ;;Protection: Class 1 — Innate protection offered by WU7_Pool|ScoreSlots
    (defun XI_RevokeScoreFromPool:string
        (pool-id:string slot-index:integer)
        @doc "Remove score at slot-index and compact higher slots down (0=primary .. 6=septenary). Under SECURE from AQP|C>REVOKE-SCORE."
        ;; SECURE: granted by WU7_Pool|ScoreSlots (underlying W_).
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (lst:[string]
                    [
                        (UR_AQP|PoolScorePrimary pool-id)
                        (UR_AQP|PoolScoreSecondary pool-id)
                        (UR_AQP|PoolScoreTertiary pool-id)
                        (UR_AQP|PoolScoreQuaternary pool-id)
                        (UR_AQP|PoolScoreQuinary pool-id)
                        (UR_AQP|PoolScoreSenary pool-id)
                        (UR_AQP|PoolScoreSeptenary pool-id)
                    ]
                )
                (lst-v1:[string] (ref-U|LST::UC_RemoveItemAt lst slot-index))
                (lst-v2:[string] (ref-U|LST::UC_AppL lst-v1 BAR))
            )
            (WU7_Pool|ScoreSlots pool-id
                (at 0 lst-v2)
                (at 1 lst-v2)
                (at 2 lst-v2)
                (at 3 lst-v2)
                (at 4 lst-v2)
                (at 5 lst-v2)
                (at 6 lst-v2)
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_DPSFTracker, WU_Pool|Occupancy,
    ;;Protection:          WW_DPNFTracker
    (defun XI_1|WriteCollectableTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce:integer
            amount:integer
            direction:bool
        )
        @doc "One DPSF/DPNF tracker row — read balance, write ±amount (cap validates unstake sufficiency)."
        ;; SECURE: granted by WW_DPSFTracker / WW_DPNFTracker (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (delta:decimal (if direction (dec amount) (- (dec amount))))
            )
            (if son
                (let
                    (
                        (bal:decimal (UR_AQP|DPSFTrackerBalance pool-id collectable-id owner-id beneficiary-id nonce))
                        (new-bal:decimal (+ bal delta))
                    )
                    (WW_DPSFTracker pool-id collectable-id owner-id beneficiary-id nonce
                        (UDC_AQP|SemiFungibleTracker new-bal pool-id collectable-id owner-id beneficiary-id nonce)
                    )
                    ;; #FP1: pool nns occupancy — +1 when this position goes empty->occupied, -1 on last-amount removal
                    (if (and (= bal 0.0) (> new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id 1)
                        (if (and (> bal 0.0) (= new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id -1) "no nns transition"))
                )
                (let
                    (
                        (bal:decimal (UR_AQP|DPNFTrackerBalance pool-id collectable-id owner-id beneficiary-id nonce))
                        (new-bal:decimal (+ bal delta))
                    )
                    (WW_DPNFTracker pool-id collectable-id owner-id beneficiary-id nonce
                        (UDC_AQP|NonFungibleTracker new-bal pool-id collectable-id owner-id beneficiary-id nonce)
                    )
                    ;; #FP1: pool nns occupancy — +1 when this position goes empty->occupied, -1 on last-amount removal
                    (if (and (= bal 0.0) (> new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id 1)
                        (if (and (> bal 0.0) (= new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id -1) "no nns transition"))
                )
            )
            (ref-IGNIS::UDC_LegCumulator "tracker-write-collectable" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XI_2|BumpBenDpsfNonceTotal,
    ;;Protection:          XI_2|BumpBenDpnfNonceTotal
    (defun XI_1|BumpBenCollectableNonceTotalSlot:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string collectable-id:string son:bool nonce:integer amount:integer direction:bool)
        @doc "One BenDpsfNonceTotal or BenDpnfNonceTotal row — son dispatch to XI_2 leaf."
        ;; SECURE: granted by XI_2|BumpBenDpsfNonceTotal / XI_2|BumpBenDpnfNonceTotal (underlying W_).
        (if son
            (XI_2|BumpBenDpsfNonceTotal beneficiary-id collectable-id nonce amount direction)
            (XI_2|BumpBenDpnfNonceTotal beneficiary-id collectable-id nonce amount direction)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_BenDpsfNonceTotal,
    ;;Protection:          WW_BenDpsfAnkMeta
    (defun XI_2|BumpBenDpsfNonceTotal:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string dpsf-id:string nonce:integer amount:integer direction:bool)
        @doc "AQP|T|BenDpsfNonceTotal: bump amount ±supply for (beneficiary, dpsf-id, nonce) across pools. \
            \ Also bumps BenDpsfAnkMeta.active-nonce-count when amount crosses 0↔positive."
        ;; SECURE: granted by WW_BenDpsfNonceTotal / WW_BenDpsfAnkMeta (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (amt:integer (UR_AQP|BenDpsfNonceAmount beneficiary-id dpsf-id nonce))
                (delta:integer (if direction amount (- amount)))
                (new-amt:integer (+ amt delta))
                (meta:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta} (UR_AQP|BenDpsfAnkMeta beneficiary-id dpsf-id))
                (sc:integer (at "last-ank-sync-count" meta))
                (anc:integer (at "active-nonce-count" meta))
                (new-anc:integer
                    (if (and (= amt 0) (> new-amt 0))
                        (+ anc 1)
                        (if (and (> amt 0) (= new-amt 0))
                            (- anc 1)
                            anc
                        )
                    )
                )
            )
            (WW_BenDpsfNonceTotal beneficiary-id dpsf-id nonce
                (UDC_AQP|BenDpsfNonceTotal new-amt beneficiary-id dpsf-id nonce)
            )
            (if (!= new-anc anc)
                (WW_BenDpsfAnkMeta beneficiary-id dpsf-id
                    (UDC_AQP|BenDpsfAnkMeta sc new-anc beneficiary-id dpsf-id)
                )
                true
            )
            (ref-IGNIS::UDC_LegCumulator "ben-nonce-total-sf" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_BenDpnfNonceTotal,
    ;;Protection:          WW_BenDpnfAnkMeta
    (defun XI_2|BumpBenDpnfNonceTotal:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string dpnf-id:string nonce:integer amount:integer direction:bool)
        @doc "AQP|T|BenDpnfNonceTotal: bump amount ±supply for (beneficiary, dpnf-id, nonce) across pools. \
            \ Also bumps BenDpnfAnkMeta.active-nonce-count when amount crosses 0↔positive."
        ;; SECURE: granted by WW_BenDpnfNonceTotal / WW_BenDpnfAnkMeta (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (amt:integer (UR_AQP|BenDpnfNonceAmount beneficiary-id dpnf-id nonce))
                (delta:integer (if direction amount (- amount)))
                (new-amt:integer (+ amt delta))
                (meta:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta} (UR_AQP|BenDpnfAnkMeta beneficiary-id dpnf-id))
                (sc:integer (at "last-ank-sync-count" meta))
                (anc:integer (at "active-nonce-count" meta))
                (new-anc:integer
                    (if (and (= amt 0) (> new-amt 0))
                        (+ anc 1)
                        (if (and (> amt 0) (= new-amt 0))
                            (- anc 1)
                            anc
                        )
                    )
                )
            )
            (WW_BenDpnfNonceTotal beneficiary-id dpnf-id nonce
                (UDC_AQP|BenDpnfNonceTotal new-amt beneficiary-id dpnf-id nonce)
            )
            (if (!= new-anc anc)
                (WW_BenDpnfAnkMeta beneficiary-id dpnf-id
                    (UDC_AQP|BenDpnfAnkMeta sc new-anc beneficiary-id dpnf-id)
                )
                true
            )
            (ref-IGNIS::UDC_LegCumulator "ben-nonce-total-nf" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_DPTFTracker, WU_Pool|Occupancy
    (defun XI_1|WriteDptfTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "One AQP|T|DPTFTracker row — read balance, write ±amount (cap validates unstake sufficiency)."
        ;; SECURE: granted by WW_DPTFTracker (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
                (delta:decimal (if direction amount (- amount)))
                (new-bal:decimal (+ bal delta))
            )
            (WW_DPTFTracker pool-id dptf-id owner-id beneficiary-id
                (UDC_AQP|TrueFungibleTracker new-bal pool-id dptf-id owner-id beneficiary-id)
            )
            ;; #FP1 universal nns: TF leg occupancy — +1 empty->occupied, -1 occupied->empty (last amount out).
            ;; No-op on LP pools (class 0, nns=-1) via the WU_Pool|Nns guard. Covers TF stake AND unstake.
            (if (and (= bal 0.0) (> new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id 1)
                (if (and (> bal 0.0) (= new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id -1) "no nns transition"))
            (ref-IGNIS::UDC_LegCumulator "tracker-write-tf" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_DPTFTracker, WU_Pool|Occupancy
    (defun XI_1|ZeroDptfTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string)
        @doc "Vacate: write AQP|T|DPTFTracker balance=0. #FP1: reads the pre-balance so the pool nns occupancy \
            \ counter can record the occupied->empty transition (the old 'no read' shortcut yields to correct nns)."
        ;; SECURE: granted by WW_DPTFTracker (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
            )
            (WW_DPTFTracker pool-id dptf-id owner-id beneficiary-id
                (UDC_AQP|TrueFungibleTracker 0.0 pool-id dptf-id owner-id beneficiary-id)
            )
            ;; #FP1 universal nns: zeroing an OCCUPIED leg is an occupied->empty transition (-1). No-op on LP.
            (if (> bal 0.0) (WU_Pool|Occupancy pool-id beneficiary-id -1) "no nns transition")
            (ref-IGNIS::UDC_LegCumulator "tracker-zero-tf" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_BenDptfTotal
    (defun XI_1|BumpBenDptfTotalSlot:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "One AQP|T|BenDptfTotal row — bump total-balance ±amount; preserve last-ank-sync-count."
        ;; SECURE: granted by WW_BenDptfTotal (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (tb:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (sc:integer (UR_AQP|BenDptfLastAnkSyncCount beneficiary-id dptf-id))
                (delta:decimal (if direction amount (- amount)))
                (new-total:decimal (+ tb delta))
            )
            (WW_BenDptfTotal beneficiary-id dptf-id
                (UDC_AQP|BenDptfTotal new-total sc beneficiary-id dptf-id)
            )
            (ref-IGNIS::UDC_LegCumulator "ben-total-tf" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_DPOFTracker, WU_Pool|Occupancy
    (defun XI_1|WriteDpofTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonce:integer
            amount:decimal
            direction:bool
        )
        @doc "One AQP|T|DPOFTracker row — read UR_AQP|DPOFTrackerBalance, write ±amount (cap validates unstake sufficiency)."
        ;; SECURE: granted by WW_DPOFTracker (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (bal:decimal (UR_AQP|DPOFTrackerBalance pool-id dpof-id owner-id beneficiary-id nonce))
                (delta:decimal (if direction amount (- amount)))
                (new-bal:decimal (+ bal delta))
            )
            (WW_DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce
                (UDC_AQP|OrtoFungibleTracker new-bal pool-id dpof-id owner-id beneficiary-id nonce)
            )
            ;; #FP1: pool nns occupancy — OF moves the whole nonce, so every move is a full 0<->occupied transition
            (if (and (= bal 0.0) (> new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id 1)
                (if (and (> bal 0.0) (= new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id -1) "no nns transition"))
            (ref-IGNIS::UDC_LegCumulator "tracker-write-of" AQP|SC_NAME)
        )
    )
    ;; [XE]
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_SetVacateJobState:string
        (pool-id:string vacate-in-progress:bool)
        @doc "Write vacate-in-progress on AQP|T|Pool. P|UEV_IMC gates AQP-VCT caller."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            ;; SECURE: granted by WU4_Pool|VacateJobState (underlying W_).
            (WU4_Pool|VacateJobState pool-id vacate-in-progress)
        )
        pool-id
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_SetSweepInProgress:string
        (pool-id:string flag:bool)
        @doc "Forward (re-score sweep · MTX-AQP): freeze/unfreeze a pool for a sweep — blocks new stakes AND collect \
            \ while true (D3). P|UEV_IMC gates the caller; P|SECURE-CALLER composes SECURE."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            ;; SECURE: granted by WU_Pool|SweepInProgress (underlying W_).
            (WU_Pool|SweepInProgress pool-id flag)
        )
        pool-id
    )
    ;;
    ;; --- Block B · Phase 1 custody (FVT::C_*StakeFlow) ---
    ;;   Phase 1 — move assets user↔vault and record pool-local + cross-pool custody.
    ;;   1.1 Transfer          UrStoa ≡ X_UR|Transfer
    ;;   1.2 Pool tracker      UrStoa ≡ (implicit in vault accounting)
    ;;   1.3 Beneficiary rollup UrStoa ≡ N/A (TF cross-pool O(1) for ANK)
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY
    (defun XE_TrueFungibleTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.1 — UrStoa ≡ X_UR|Transfer. TFT::C_Transfer owner↔AQP|SC_NAME. Composes custody cap (validation once per tx). \
            \ \
            \ PROVISIONAL PATRON SLOT CLEARED, 2026-09-22. The inner transfer carried \
            \ <owner-id> in the patron slot -- registered in _patronslots as provisional -- \
            \ because no caller had a patron to give. 05_FVT's turn gave the stake flows a \
            \ real one, so the payer is now the payer. HANDOFF 4e promises every provisional \
            \ slot is written down AND re-pointed when its turn lands; this is the re-pointing."
        (P|UEV_IMC)
        (with-capability (AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY pool-id owner-id beneficiary-id dptf-id amount direction)
            (let
                (
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (vault:string AQP|SC_NAME)
                )
                (if direction
                    (ref-TFT::C_Transfer patron owner-id vault dptf-id amount true)
                    (ref-TFT::C_Transfer patron vault owner-id dptf-id amount true)
                )
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_TrueFungiblePoolTracker:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.2 — per-pool AQP|T|DPTFTracker row. UrStoa: N/A. P|SECURE-CALLER (no custody re-validation)."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|WriteDptfTrackerSlot pool-id owner-id beneficiary-id dptf-id amount direction)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_ZeroDptfTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string)
        @doc "IMC: zero one AQP|T|DPTFTracker row (write-only). Called from AQP-VCT vacate."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|ZeroDptfTrackerSlot pool-id owner-id beneficiary-id dptf-id)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_TrueFungibleBeneficiaryRollup:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.3 — cross-pool AQP|T|BenDptfTotal. UrStoa ≡ N/A. P|SECURE-CALLER."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|BumpBenDptfTotalSlot pool-id owner-id beneficiary-id dptf-id amount direction)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
    (defun XE_OrtoFungibleTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string 
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Phase 1.1 — UrStoa ≡ X_UR|Transfer. DPOF::C_Transfer whole nonces. Composes custody cap (validation once per tx)."
        (P|UEV_IMC)
        (with-capability (AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
            (let
                (
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    ;;
                    (vault:string AQP|SC_NAME)
                    (sender:string (if direction owner-id vault))
                    (receiver:string (if direction vault owner-id))
                )
                (ref-DPOF::C_Transfer patron sender receiver dpof-id nonces true)
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_OrtoFungiblePoolTracker:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Phase 1.2 — per-pool AQP|T|DPOFTracker rows. UrStoa: N/A. P|SECURE-CALLER (no custody re-validation)."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (l:integer (length nonces))
                    (slot-ocs:[object{IgnisCollectorV3.OutputCumulator}]
                        (map
                            (lambda (idx:integer)
                                ;; M5: write/remove the exact (owner, beneficiary) tracker row BOTH directions —
                                ;; beneficiary-id is caller-supplied (self OR foreign), no self-key derivation.
                                (XI_1|WriteDpofTrackerSlot
                                    pool-id owner-id beneficiary-id dpof-id (at idx nonces) (at idx nonce-amounts) direction
                                )
                            )
                            (enumerate 0 (- l 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators slot-ocs [])
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          AQP|XE>COLLECTABLE-POOL-CUSTODY
    (defun XE_CollectableTransfer:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Phase 1.1 — UrStoa ≡ X_UR|Transfer. DPDC-T::C_Transfer. Composes custody cap (validation once per tx). \
            \ \
            \ PROVISIONAL PATRON SLOT CLEARED, 2026-09-22. The inner transfer carried \
            \ <owner-id> in the patron slot -- registered in _patronslots as provisional -- \
            \ because no caller had a patron to give. 05_FVT's turn gave the stake flows a \
            \ real one, so the payer is now the payer. HANDOFF 4e promises every provisional \
            \ slot is written down AND re-pointed when its turn lands; this is the re-pointing."
        (P|UEV_IMC)
        (with-capability
            (AQP|XE>COLLECTABLE-POOL-CUSTODY
                pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts direction
            )
            (let
                (
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    ;;
                    (vault:string AQP|SC_NAME)
                    (sender:string (if direction owner-id vault))
                    (receiver:string (if direction vault owner-id))
                )
                (ref-DPDC-T::C_Transfer patron sender receiver [collectable-id] [son] [nonces] [nonce-amounts] true)
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_CollectablePoolTracker:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Phase 1.2 — per-pool DPSF/DPNF tracker rows. UrStoa: N/A. P|SECURE-CALLER."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (l:integer (length nonces))
                    (slot-ocs:[object{IgnisCollectorV3.OutputCumulator}]
                        (map
                            (lambda (idx:integer)
                                ;; M5: write/remove the exact (owner, beneficiary) tracker row BOTH directions —
                                ;; beneficiary-id is caller-supplied (self OR foreign), no self-key derivation.
                                (XI_1|WriteCollectableTrackerSlot
                                    pool-id owner-id beneficiary-id collectable-id son (at idx nonces) (at idx nonce-amounts) direction
                                )
                            )
                            (enumerate 0 (- l 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators slot-ocs [])
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_CollectableBeneficiaryRollup:object{IgnisCollectorV3.OutputCumulator}
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Phase 1.3 — cross-pool BenDpsfNonceTotal / BenDpnfNonceTotal. UrStoa ≡ N/A. P|SECURE-CALLER."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (l:integer (length nonces))
                    (slot-ocs:[object{IgnisCollectorV3.OutputCumulator}]
                        (map
                            (lambda (idx:integer)
                                ;; M5: bump/unbump the exact beneficiary rollup slot BOTH directions —
                                ;; beneficiary-id is caller-supplied (self OR foreign), no self-key derivation.
                                (XI_1|BumpBenCollectableNonceTotalSlot
                                    beneficiary-id collectable-id son (at idx nonces) (at idx nonce-amounts) direction
                                )
                            )
                            (enumerate 0 (- l 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators slot-ocs [])
            )
        )
    )
    ;; [XB]
    ;;
    ;; Depth: C_* → XI_* (depth 0) ; XE_* / XB_* → XI_1|* (depth 1). Map order = entry first.
    ;;
    ;; --- Block A · C_* pool lifecycle ---
    ;;   C_Issue → XI_IssuePool
    ;;   C_AddScore → XI_AddScoreToPool
    ;;   C_RevokeScore → XI_RevokeScoreFromPool
    ;;   C_DisablePoolStake / C_EnablePoolStake → XB_SetPoolStakeEnabled (also AQP-VCT vacate via IMC)
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XB_SetPoolStakeEnabled:string
        (pool-id:string enabled:bool)
        @doc "Write stake-enabled on AQP|T|Pool. P|UEV_IMC gates cross-module callers (e.g. AQP-VCT vacate). \
            \ Same-module C_Disable/C_Enable compose owner caps then call here."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            ;; SECURE: granted by WU_Pool|StakeEnabled (underlying W_).
            (WU_Pool|StakeEnabled pool-id enabled)
        )
        pool-id
    )
    ;;
    ;; --- Block C · TF stake phase 2.2 (FVT::XI_RefreshTrueFungibleStakeAnchors backward) ---
    ;;   XB_SetBenDptfAnkSyncCount
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC
    (defun XB_SetBenDptfAnkSyncCount:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Backward (FVT::CC_TrueFungibleStakeFlow phase 2.2]): set last-ank-sync-count on BenDptfTotal \
            \ (:= AQP-ANK::UR_AA|AnchorsActive dptf-id); preserve total-balance. P|UEV_IMC + AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC. \
            \ Same-module C_SyncTrueFungibleAnchors and cross-module FVT::XI_RefreshTrueFungibleStakeAnchors call here."
        (P|UEV_IMC)
        (with-capability (AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC beneficiary-id dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    ;;
                    (row:object{AcquisitionSchemasV1.AQP|BenDptfTotal} (UR_AQP|BenDptfTotal beneficiary-id dptf-id))
                    (live-count:integer (ref-ANK::UR_AA|AnchorsActive dptf-id))
                )
                ;; SECURE: granted by WU_BenDptfTotal|LastAnkSyncCount (underlying W_).
                (WU_BenDptfTotal|LastAnkSyncCount beneficiary-id dptf-id row live-count)
                (ref-IGNIS::UDC_LegCumulator "ank-sync-count-tf" AQP|SC_NAME)
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC
    (defun XB_SetBenCollectableAnkSyncCount:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string collectable-id:string son:bool)
        @doc "Backward (FVT collectable stake phase 3 / C_SyncCollectableAnchors): stamp last-ank-sync-count \
            \ on BenDpsfAnkMeta or BenDpnfAnkMeta. P|UEV_IMC + AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC."
        (P|UEV_IMC)
        (with-capability (AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC beneficiary-id collectable-id son)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    ;;
                    (live-count:integer (ref-ANK::UR_AA|AnchorsActive collectable-id))
                )
                (if son
                    (let
                        (
                            (row:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta} (UR_AQP|BenDpsfAnkMeta beneficiary-id collectable-id))
                        )
                        ;; SECURE: granted by WU_BenDpsfAnkMeta|LastAnkSyncCount (underlying W_).
                        (WU_BenDpsfAnkMeta|LastAnkSyncCount beneficiary-id collectable-id row live-count)
                    )
                    (let
                        (
                            (row:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta} (UR_AQP|BenDpnfAnkMeta beneficiary-id collectable-id))
                        )
                        ;; SECURE: granted by WU_BenDpnfAnkMeta|LastAnkSyncCount (underlying W_).
                        (WU_BenDpnfAnkMeta|LastAnkSyncCount beneficiary-id collectable-id row live-count)
                    )
                )
                (ref-IGNIS::UDC_LegCumulator "ank-sync-count-collectable" AQP|SC_NAME)
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]   client
    ;;
    ;;Lifecycle (AQP|T|Pool / AQP|Schema)
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Create a new pool (canonical native asset-id + aqp-class). Patron pays STOA smart + IGNIS; \
            \ returns pool-id in output list. Score slots start BAR."
        (P|UEV_IMC)
        (with-capability (AQP|C>ISSUE-POOL executor pool-name asset-id aqp-class)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (pool-id:string (ref-U|DALOS::UDC_Makeid pool-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueStoa))
                (XI_IssuePool pool-id aqp-class asset-id)
                (URCi_Issue [pool-id])
            )
        )
    )
    ;;Score slots (score-primary … score-septenary); score-class must match pool aqp-class.
    (defun C_AddScore:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string score-id:string)
        @doc "Assign score-id to the first free pool slot; SCR XE_CreateAqpoolLink then XI pool slot write. \
            \ URC_FirstFreeScoreSlotIndex runs once before the cap; slot-index is passed through. \
            \ IGNIS only (GAS|ADD-SCORE 500.0 on AQP|SC_NAME); no STOA."
        (P|UEV_IMC)
        (let 
            (
                (slot-index:integer (URC_FirstFreeScoreSlotIndex pool-id))
            )
            (with-capability (AQP|C>ADD-SCORE executor pool-id score-id slot-index)
                (let
                    (
                        (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        ;;
                        (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    )
                    (ref-SCR::XE_CreateAqpoolLink score-id pool-id)
                    (XI_AddScoreToPool pool-id score-id slot-index)
                    (URCi_AddScore [pool-id score-id])
                )
            )
        )
    )
    (defun C_RevokeScore:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string score-id:string)
        @doc "Clear score-id from its pool slot (compact higher slots); SCR XE_RevokeAqpoolLink then XI pool slot write. \
            \ URC_ScoreSlotIndexForScore runs once before the cap; slot-index is passed through. \
            \ IGNIS only (GAS|REVOKE-SCORE 500.0 on AQP|SC_NAME); no STOA."
        (P|UEV_IMC)
        (let
            (
                (slot-index:integer (URC_ScoreSlotIndexForScore pool-id score-id))
            )
            (with-capability (AQP|C>REVOKE-SCORE executor pool-id score-id slot-index)
                (let
                    (
                        (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        ;;
                        (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    )
                    (ref-SCR::XE_RevokeAqpoolLink score-id pool-id)
                    (XI_RevokeScoreFromPool pool-id slot-index)
                    (URCi_RevokeScore [pool-id score-id])
                )
            )
        )
    )
    (defun C_DisablePoolStake:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string)
        @doc "Pool owner pauses new stakes (stake-enabled → false). IGNIS only (GAS|SET-POOL-STAKE); no STOA."
        (P|UEV_IMC)
        (with-capability (AQP|C>DISABLE-POOL-STAKE executor pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (XB_SetPoolStakeEnabled pool-id false)
                (URCi_SetPoolStake [pool-id])
            )
        )
    )
    (defun C_EnablePoolStake:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string)
        @doc "Pool owner re-enables new stakes (stake-enabled → true). IGNIS only (GAS|SET-POOL-STAKE); no STOA."
        (P|UEV_IMC)
        (with-capability (AQP|C>ENABLE-POOL-STAKE executor pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (XB_SetPoolStakeEnabled pool-id true)
                (URCi_SetPoolStake [pool-id])
            )
        )
    )
    (defun C_SyncTrueFungibleAnchors:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executee:string dptf-id:string)
        @doc "Pool-agnostic ANK repair when new TF anchors issued after stake. Reads BenDptfTotal, \
            \ refreshes promile, stamps last-ank-sync-count. SCORE boosted unchanged (lazy on next stake). \
            \ \
            \ EXECUTORLESS BY DESIGN, and <executee> is exactly that (canon 2.2, 2026-09-22). \
            \ The capability validates that the beneficiary EXISTS and is a standard account \
            \ (UEV_StakeBeneficiaryAccount) and nothing else; it is never ownership-checked. \
            \ Acted upon, needing no signature, only type-validated: the executee test \
            \ verbatim, and the same disposition DPDC-I reached for <creator-account> under \
            \ audit #53L. \
            \ \
            \ There is NO executor to name, and inventing one would be worse than none (4f). \
            \ This is permissionless maintenance: it recomputes anchor values from the \
            \ beneficiary's ACTUAL balances, so every outcome is the truth, and the PATRON pays \
            \ for it. A third party -- typically whoever issued the new anchors that made the \
            \ values stale -- can and should be able to trigger the repair. Requiring the \
            \ beneficiary's signature would remove that path and protect nothing: the only \
            \ thing a caller can do here is make someone else's data correct at their own \
            \ expense. \
            \ (patron/executor canon 2.2, EXECUTORLESS + executee, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (AQP|C>SYNC-TF-ANCHORS patron executee dptf-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (total:decimal (UR_AQP|BenDptfTotalBalance executee dptf-id))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (ico-ank:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ANK::XE_UpdateTrueFungibleUserAnchorValues executee dptf-id total)
                    )
                    (ico-meta:object{IgnisCollectorV3.OutputCumulator}
                        (XB_SetBenDptfAnkSyncCount executee dptf-id)
                    )
                    (ico-gas:object{IgnisCollectorV3.OutputCumulator}
                        (URCi_SyncTrueFungibleAnchors [executee dptf-id])
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-ank ico-meta ico-gas] [])
            )
        )
    )
    (defun C_SyncCollectableAnchors:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executee:string collectable-id:string son:bool)
        @doc "Pool-agnostic ANK repair for DPSF (son=true) or DPNF (son=false). Reads Ben* nonce rollup, \
            \ absolute resync via AQP-ANK::XE_Resync*, stamps Ben*AnkMeta. Talos splits SF/NF shells. \
            \ URD inventory is read before with-capability (select illegal in defcap). \
            \ \
            \ EXECUTORLESS BY DESIGN, and <executee> is the EXECUTEE (patron/executor \
            \ canon 2.2, 2026-09-22). The capability validates that the beneficiary EXISTS and \
            \ is a standard account (UEV_StakeBeneficiaryAccount) and nothing else -- it is \
            \ never ownership-checked. Acted upon, needing no signature, only type-validated: \
            \ the executee test verbatim, and the same disposition DPDC-I reached for \
            \ <creator-account> under audit #53L. \
            \ \
            \ There is NO executor to name, and inventing one would be worse than none (4f). \
            \ This is permissionless maintenance: it recomputes anchor values from the \
            \ beneficiary's ACTUAL balances, so every outcome is the truth, and the PATRON pays \
            \ for it. A third party -- typically whoever issued the new anchors that made the \
            \ values stale -- can and should be able to trigger the repair. Requiring the \
            \ beneficiary's signature would remove that path and protect nothing: the only \
            \ thing a caller can do here is make someone else's data correct at their own \
            \ expense. \
            \ (patron/executor canon 2.2, EXECUTORLESS + executee, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (supplies:[object]
                    (if son
                        (URH_AQP|BenDpsfActiveNonceSupplies executee collectable-id)
                        (URH_AQP|BenDpnfActiveNonceSupplies executee collectable-id)
                    )
                )
            )
            (with-capability (AQP|C>SYNC-COLLECTABLE-ANCHORS patron executee collectable-id son)
                (let
                    (
                        (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        ;;
                        (nonces:[integer] (map (at "nonce") supplies))
                        (nonce-amounts:[integer] (map (at "amount") supplies))
                        (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                        (ico-ank:object{IgnisCollectorV3.OutputCumulator}
                            (if son
                                (ref-ANK::XE_ResyncSemiFungibleUserAnchorValues
                                    executee collectable-id nonces nonce-amounts
                                )
                                (ref-ANK::XE_ResyncNonFungibleUserAnchorValues
                                    executee collectable-id nonces
                                )
                            )
                        )
                        (ico-meta:object{IgnisCollectorV3.OutputCumulator}
                            (XB_SetBenCollectableAnkSyncCount executee collectable-id son)
                        )
                        (ico-gas:object{IgnisCollectorV3.OutputCumulator}
                            (URCi_SyncCollectableAnchors [executee collectable-id])
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-ank ico-meta ico-gas] [])
                )
            )
        )
    )

)



;;

;; ---- source: 1_SOVEREIGN/STAGE_02/3_Talos/01_TS02-C1.pact (module only -- its interface is already live)
(module TS02-C1 GOV
    @doc "TALOS Stage 2 Client Functiones Part 1 - SFT Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_ClientOneV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS02-C1                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS02-C1_ADMIN)))
    (defcap GOV|TS02-C1_ADMIN ()                        (enforce-guard GOV|MD_TS02-C1))
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
        (with-capability (GOV|TS02-C1_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS02-C1_ADMIN)
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
        (with-capability (GOV|TS02-C1_ADMIN)
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
        (with-capability (GOV|TS02-C1_ADMIN)
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
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (ref-P|DPDC-I:module{OuronetPolicyV2} DPDC-I)
                (ref-P|DPDC-R:module{OuronetPolicyV2} DPDC-R)
                (ref-P|DPDC-MNG:module{OuronetPolicyV2} DPDC-MNG)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPDC-F:module{OuronetPolicyV2} DPDC-F)
                (ref-P|DPDC-S:module{OuronetPolicyV2} DPDC-S)
                (ref-P|DPDC-N:module{OuronetPolicyV2} DPDC-N)
                (ref-P|EQUITY:module{OuronetPolicyV2} EQUITY)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|TS01-A::P|A_AddIMP mg)
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
            (ref-P|DPDC-I::P|A_AddIMP mg)
            (ref-P|DPDC-R::P|A_AddIMP mg)
            (ref-P|DPDC-MNG::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|DPDC-F::P|A_AddIMP mg)
            (ref-P|DPDC-S::P|A_AddIMP mg)
            (ref-P|DPDC-N::P|A_AddIMP mg)
            (ref-P|EQUITY::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
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
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [2] DPDC
    ;;
    (defun DPDC|C_MultiTransfer (patron:string executor:string executee:string ids:[string] sons:[bool] nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Transfer multiple collectable <ids> from <executor> to <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (hm:integer (length ids))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor ids sons nonces-array amounts-array)
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                    (l:integer (length c))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer patron executor executee ids sons nonces-array amounts-array method)
                )
                [
                    (format "Successfully transfered DPDC(s) {} Nonce-Array {} using Amount-Array {} from {} to {}" [ids nonces-array amounts-array sa ra])
                    (if (= s 0.0)
                        (format "Transfer executed without collecting any IGNIS Royalties for the Collectable(s) {}" [ids])
                        (format "Transfer executed while collecting {} IGNIS Royalty to {} Collectable Creator(s)" [s l])
                    )
                ]
            )
        )
    )
    (defun DPSF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPSF Token <entity-id> costing 400 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC::C_UpdatePendingBranding patron executor entity-id true logo description website social)
                )
            )
        )
    )
    (defun DPSF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Upgrades Branding for DPSF Token, making it a premium BrandingV2. \
            \ Also sets pending-branding to live branding if its branding is not live yet"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DPDC::C_UpgradeBranding patron executor entity-id true months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    ;;
    ;;  [3] DPDC-C
    ;;
    (defun DPSF|C_Create:string
        (
            patron:string executor:string id:string amount:[integer]
            input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}]
        )
        @doc "Creates a new SFT Collection Element(s), having a new nonce, \
            \ of amount <amount>, on the Account that has <r-nft-create> \
            \ As this account is the only Account that is allowed to create new SFTs in the Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    (l:integer (length input-nonce-data))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (if (= l 1)
                            (ref-DPDC-C::C_CreateNewNonce
                                patron executor id true 0 (at 0 amount) (at 0 input-nonce-data) false
                            )
                            (ref-DPDC-C::C_CreateNewNonces
                                patron executor id true amount input-nonce-data
                            )
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Created {} Clas 0 SemiFungible(s) within the {} DPSF Collection"
                    [(at "output" ico) id]
                )
            )
        )
    )
    ;;
    ;;  [4] DPDC-I
    ;;
    ;; DPSF|C_DeployAccount removed — DPDC Audit #35M: see interface-side removal note above.
    (defun DPSF|C_Issue:string
        (
            patron:string 
            executor:string executee:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
        )
        @doc "Issues a new DPSF (Demiourgos Pact Semi-Fungible) Digital Collection: <SFT> \
            \ Costs 5x<ignis|token-issue> = 2500 IGNIS and 400 STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-I:module{DpdcIssueV2} DPDC-I)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-I::C_IssueDigitalCollection
                            patron executor executee true
                            collection-name collection-ticker
                            can-upgrade can-change-owner can-change-creator can-add-special-role
                            can-transfer-nft-create-role can-freeze can-wipe can-pause
                            false
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at 0 (at "output" ico))
            )
        )
    )
    ;;
    ;;  [5] DPDC-R
    ;;
    (defun DPSF|C_ToggleAddQuantityRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles the add quantity role for a DPTF Token on a given Ouronet Account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleAddQuantityRole patron executor executee id toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Freezes a given account for a given DPSF Token. Frozen Accounts can no longer send or receive that DPSF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleFreezeAccount patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleExemptionRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles exemption Role for a given DPSF on a given Smart Ouronet Account (Only Smart Ouronet Accounts can accept this role) \
            \ When sending to or receiving from such Accounts, the flat IGNIS Royalty fee must not be paid."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleExemptionRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles burn Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can then burn the DPSF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleBurnRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleUpdateRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles update Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can then update (modify) the Metadata on any DPSF nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleUpdateRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleModifyCreatorRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Modify Creator Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Creator of the DPSF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyCreatorRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleModifyRoyaltiesRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Modify Royalties Role for a given DPSF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Permille Royalty of any nonce in the  DPSF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyRoyaltiesRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Transfer Role for a given DPSF on any Ouronet Account. \
            \ Transfers for any Nonce in the DPSF Collection are then restricted only to and from these accounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleTransferRole patron executor executee id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_MoveCreateRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Create Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can issue new SFTs in the Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveCreateRole patron executor executee id true)
                )
            )
        )
    )
    (defun DPSF|C_MoveRecreateRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Recreate Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can recreate any existing SFT in the Collection \
            \ Recreation reffers to a complete update (modification) of all SFT properties of a given nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveRecreateRole patron executor executee id true)
                )
            )
        )
    )
    (defun DPSF|C_MoveSetUriRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Set URI Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can modify the URIs of any nonce in the SFT Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveSetUriRole patron executor executee id true)
                )
            )
        )
    )
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun DPSF|C_Control (patron:string executor:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        @doc "Controls DPSF Properties"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_Control patron executor id true cu cco ccc casr ctncr cf cw cp)
                )
            )
        )
    )
    (defun DPSF|C_TogglePause (patron:string executor:string id:string toggle:bool)
        @doc "Pauses a DPSF Collection. Paused Collections can no longer be transfered"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_TogglePause patron executor id true toggle)
                )
            )
        )
    )
    (defun DPSF|C_AddQuantity (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "Increases the Quantity for SFT <id> <nonce> by <amount> on <executor>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_AddQuantity patron executor id nonce amount)
                )
                (format "Successfully added {} Units for SFT {} Nonce {} on Account {}" [amount id nonce (UC_ShortAccount executor)])
            )
        )
    )
    (defun DPSF|C_Burn (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "Decreases the Quantity for SFT <id> <nonce> by <amount> on <executor>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_BurnSFT patron executor id nonce amount)
                )
                (format "Successfully burned {} Units for SFT {} Nonce {} on Account {}" [amount id nonce (UC_ShortAccount executor)])
            )
        )
    )
    (defun DPSF|C_WipeNoncePartialy (patron:string executor:string executee:string id:string nonce:integer amount:integer)
        @doc "Wipes a partial <amount> of SFT <id> <nonce> from <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_WipeSlim patron executor executee id nonce amount)
                )
                (format "Successfully wiped {} Units for SFT {} Nonce {} from Account {}" [amount id nonce (UC_ShortAccount executee)])
            )
        )
    )
    (defun DPSF|C_WipeNonce (patron:string executor:string executee:string id:string nonce:integer)
        @doc "Wipes the SFT <id> <nonce> from <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_WipeNonce patron executor executee id true nonce)
                )
                (format "Successfully wiped SFT {} Nonce {} from Account {}" [id nonce (UC_ShortAccount executee)])
            )
        )
    )
    (defun DPSF|CC_WipeHeavy (patron:string executor:string executee:string id:string)
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::CC_WipeHeavy patron executor executee id true)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Successfully executed Heavy Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|C_WipePure (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipePure patron executor executee id true removable-nonces-obj) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Successfully executed Pure Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|C_WipeClean (patron:string executor:string executee:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeClean patron executor executee id true nonces) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Successfully executed Clean Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|C_WipeDirty (patron:string executor:string executee:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeDirty patron executor executee id true nonces)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format
                    "Successfully executed Dirty Wipe of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}"
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPSF|Cp_WipeSlice (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes ONE <URHC_BuildWipeSlicePlan> slice of the SFT \
            \ <account>'s <id> nonces. The UI dirty-reads the plan and fires one such tx per \
            \ slice, all in parallel; slices are disjoint, order-independent and retryable \
            \ (replay REVERTS on the zeroed account supply)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::Cp_WipeSlice account id true removable-nonces-obj)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format
                    "Successfully executed Hydra Wipe Slice of SFT {} on Account {}, wiping {} Nonces With a Total Supply of {}"
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    ;;
    ;;  [7] DPDC-T
    ;;
    (defun DPSF|C_Repurpose (patron:string executor:string executee:string id:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose SFT(s) from <executee> to <repurpose-to>. The <executor> must BE the \
            \ collection owner -- that is the authority the whole op rests on, and DPDC-T now \
            \ binds the name to it rather than deriving it silently."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_RepurposeCollectable patron executor executee id true repurpose-to nonces amounts)
                )
                (format "Successfully repurposed SFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPSF|C_TransferNonce (patron:string executor:string executee:string id:string nonce:integer amount:integer method:bool)
        @doc "Transfer an SFT <nonce> of <amount> from <executor> to <executee> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor [id] [true] [[nonce]] [[amount]])
                    )
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer patron executor executee [id] [true] [[nonce]] [[amount]] method)
                )
                [
                    (format "Successfully transfered SFT {} Nonce {} and Amount {} from {} to {}" [id nonce amount sa ra])
                    (if (= s 0.0)
                        (format "Transfer executed without collecting any IGNIS Royalties for the Collectable {}" [id])
                        (format "Transfer executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                    )
                ]
            )
        )
    )
    (defun DPSF|C_TransferNonces (patron:string executor:string executee:string id:string nonces:[integer] amounts:[integer] method:bool)
        @doc "Transfer SFT <nonces> of <amounts> from <executor> to <executee> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor [id] [true] [nonces] [amounts])
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer patron executor executee [id] [true] [nonces] [amounts] method)
                )
                [
                    (format "Successfully transfered SFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sa ra])
                    (if (= s 0.0)
                        (format "Transfer executed without collecting any IGNIS Royalties for the Collectable {}" [id])
                        (format "Transfer executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                    )
                ]
            )
        )
    )
    (defun DPDC|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string son:bool nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Bulk whole collectable transfer — one executor, many standard-account executees (TalosStageTwo_ClientOneV2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    ;;
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (l:integer (length executee-lst))
                    ;;FIXED 2026-09-12: these two used to map over `(enumerate 0 (- l 1))`.
                    ;;**In Pact `(enumerate 0 -1)` is `[0, -1]` -- a DESCENDING pair, not an empty
                    ;;list.** So an EMPTY receiver list produced TWO ids, `C_IgnisRoyaltyCollector`
                    ;;below indexed past the one-element arrays, and the caller got
                    ;;`Array index out of bounds` instead of DPDC-T|C>BULK-TRANSFER's own shape
                    ;;message -- which is bound in that cap and never got the chance to speak.
                    ;;Mapping over `receiver-lst` ITSELF yields exactly `l` elements and is genuinely
                    ;;empty when the list is, so the hazard is removed rather than worked around.
                    ;;Chosen over reordering the call: the royalty collector must still run BEFORE the
                    ;;transfer, and moving it would change what is charged, not just what is said.
                    (ids:[string]  (map (lambda (rcv:string) id)  executee-lst))
                    (sons:[bool]   (map (lambda (rcv:string) son) executee-lst))
                )
                ;;THE CORE TRANSFER RUNS FIRST, and the ordering is the fix.
                ;;FIXED 2026-09-12: the royalty collector used to be bound in the `let` ABOVE this
                ;;call. It iterates `(enumerate 0 (- (length ids) 1))` and indexes
                ;;`(at idx nonces-array)` -- so for an EMPTY receiver list, or for MORE receivers than
                ;;nonce legs, it ran off the end and raised `Array index out of bounds` before
                ;;DPDC-T|C>BULK-TRANSFER's shape guard could say what was actually wrong. Only the
                ;;opposite mismatch (more legs than receivers) stayed in bounds and reached the
                ;;message, which is what made it a defect rather than a dead guard.
                ;;Calling the core first lets its capability validate the shapes, after which every
                ;;downstream `enumerate` is operating on lists already proven to agree.
                ;;`TS01-C1::DPOF|C_BulkTransfer` has always been in this order and is not mute
                ;;(pinned by DPOF-G12) -- so this follows an in-repo precedent rather than inventing
                ;;an order. Royalties are computed from the collectable's creator settings and the
                ;;amounts, not from balances, so moving the call does not change what is charged.
                (let
                    (
                        (core-ico:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPDC-T::C_BulkTransfer patron executor executee-lst id son nonces-array amounts-array method)
                        )
                    )
                (let
                    (
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor ids sons nonces-array amounts-array)
                    )
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron core-ico)
                [
                    (format "Successfully bulk-transferred collectable {} from {} to {} receivers" [id sa l])
                    (if (= s 0.0)
                        (format "Bulk transfer executed without collecting any IGNIS Royalties for the Collectable {}" [id])
                        (format "Bulk transfer executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                    )
                ]
            )))
        )
    )
    (defun DPSF|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Bulk SFT transfer — son=true wrapper over DPDC|C_BulkTransfer. \
        \ \
        \ Executor: PROVEN INDIRECTLY, and named. This is a thin alias: it delegates to \
        \ DPDC|C_BulkTransfer in THIS module, and that wrapper's own call chain is what \
        \ proves the account. FORWARDED matches cross-module `ref-X::` calls by design, so an \
        \ intra-Talos delegation has to be traced by a human and written down. \
        \ (patron/executor canon 2.2, 2026-09-22.)"
        (DPDC|C_BulkTransfer patron executor executee-lst id true nonces-array amounts-array method)
    )
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun DPSF|C_Make
        (patron:string executor:string id:string nonces:[integer] set-class:integer how-many-sets:integer)
        @doc "Makes a Set SFT of Class <set-class>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                ;;G-44 FIX (2026-09-17), and the G-14 shape exactly: <nonce> used to be bound HERE,
                ;;eagerly, purely to be printed in the success message below. `UR_NonceOfSet`
                ;;funnels to `UR_Set`'s bare `read`, so a set-class that does not exist aborted on
                ;;the raw table key IN THIS WRAPPER -- before the core was called and therefore
                ;;before `DPDC-S|C>MAKE`'s own guard could speak. Fixing the defcap alone left this
                ;;path unchanged, which is how the fix was caught as incomplete.
                ;;Reading it AFTER the core call is value-identical: "nonce-of-set" is written once,
                ;;when the set-class is DEFINED, and never updated by a make. Inlined rather than
                ;;re-bound because it is used exactly once (CLAUDE.md let-vs-inline rule).
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_MakeSemiFungibleSet patron executor id nonces set-class how-many-sets)
                )
                (format "Successfully generated {} Class {} Sets (Nonce {}) of SFT Collection {} on Account {}"
                    [how-many-sets set-class (ref-DPDC-S::UR_NonceOfSet id set-class) id sa])
            )
        )
    )
    (defun DPSF|CC_Break
        (patron:string executor:string id:string nonce:integer how-many-sets:integer)
        @doc "Brakes an SFT Nonce representing an SFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (set-class:integer (ref-DPDC::UR_NonceClass id true nonce))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::CC_BreakSemiFungibleSet patron executor id nonce how-many-sets)
                )
                (format "Successfully broken {} Class {} Sets (Nonce {}) of SFT Collection {} on Account {}" [how-many-sets set-class nonce id sa])
            )
        )
    )
    (defun DPSF|C_DefinePrimordialSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Primordial SFT Set. Primordial Sets are composed of Class 0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-S::C_DefinePrimordialSet patron executor id true set-name score-multiplier set-definition ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Primordial Set <{}> (set-class {}) for SFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPSF|C_DefineCompositeSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Composite SFT Set. Composite Sets are composed of Class (!=0) Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-S::C_DefineCompositeSet patron executor id true set-name score-multiplier set-definition ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Composite Set <{}> (set-class {}) for SFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPSF|C_DefineHybridSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Hybrid SFT Set. Hybrid Sets are composed of both Class 0 and Non-0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-S::C_DefineHybridSet patron executor id true set-name score-multiplier primordial-sd composite-sd ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Hybrid Set <{}> (set-class {}) for SFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPSF|C_EnableSetClassFragmentation
        (
            patron:string executor:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Enables Fragmentation for a given Set Class. This allows all SFTs of the given Set Class to be Fragmented"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_EnableSetClassFragmentation patron executor id true set-class fragmentation-ind)
                )
                (format "Set Class {} for SFT {} succesfully fragmented" [set-class id])
            )
        )
    )
    (defun DPSF|C_ToggleSet (patron:string executor:string id:string set-class:integer toggle:bool)
        @doc "Enables or Disables a Set. A disabled Set allows only for decomposition of Set Elements, but not for composition"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_ToggleSet patron executor id true set-class toggle)
                )
                (format "SFT {} Set Class {} succesfully turned {}" [id set-class (if toggle "ON" "OFF")])
            )
        )
    )
    (defun DPSF|C_RenameSet (patron:string executor:string id:string set-class:integer new-name:string)
        @doc "Renames an SFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_RenameSet patron executor id true set-class new-name)
                )
                (format "SFT {} Set Class {} succesfuly renamed to <{}>" [id set-class new-name])
            )
        )
    )
    ;; DPSF|C_UpdateSetMultiplier removed — DPDC Audit #15H.
    ;;
    (defun DPSF|C_UpdateSetNonce 
        (patron:string executor:string id:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id true [set-class] nos false [new-nonce-data])
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonces
        (patron:string executor:string id:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id true set-classes nos false new-nonces-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceRoyalty
        (patron:string executor:string id:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Set Nonce Native Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty patron executor id true set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceIgnisRoyalty
        (patron:string executor:string id:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Set Nonce IGNIS Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty patron executor id true set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceName
        (patron:string executor:string id:string set-class:integer nos:bool name:string)
        @doc "[3] Updates Set Nonce Name, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName patron executor id true set-class nos false name)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceDescription
        (patron:string executor:string id:string set-class:integer nos:bool description:string)
        @doc "[4] Updates Set Nonce Description, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription patron executor id true set-class nos false description)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceScore
        (patron:string executor:string id:string set-class:integer nos:bool score:decimal)
        @doc "[5] Updates Set Nonce Score, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore patron executor id true set-class nos false score)
                )
            )
        )
    )
    (defun DPSF|C_RemoveSetNonceScore (patron:string executor:string id:string set-class:integer nos:bool)
        @doc "[5b] Removes Set Nonce Score, setting it to -1.0, either Native or Split, for an SFT \
        \ \
        \ Executor: PROVEN INDIRECTLY, and named. This is a thin alias: it delegates to \
        \ DPSF|C_UpdateSetNonceScore in THIS module, and that wrapper's own call chain is what \
        \ proves the account. FORWARDED matches cross-module `ref-X::` calls by design, so an \
        \ intra-Talos delegation has to be traced by a human and written down. \
        \ (patron/executor canon 2.2, 2026-09-22.)"
        (DPSF|C_UpdateSetNonceScore patron executor id set-class nos -1.0)
    )
    (defun DPSF|C_UpdateSetNonceMetaData
        (patron:string executor:string id:string set-class:integer nos:bool meta-data:object)
        @doc "[6] Updates Set Nonce Meta-Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData patron executor id true set-class nos false meta-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateSetNonceURI
        (
            patron:string executor:string id:string set-class:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Set Nonce URI, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI patron executor id true set-class nos false ay u1 u2 u3)
                )
            )
        )
    )
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun DPSF|C_RepurposeFragments (patron:string executor:string executee:string id:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose SFT Fragment(s) from <executee> to <repurpose-to>. The <executor> must \
            \ BE the collection owner -- that is the authority the whole op rests on, and \
            \ DPDC-F now binds the name to it rather than deriving it silently."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_RepurposeCollectableFragments patron executor executee id true repurpose-to nonces amounts)
                )
                (format "Successfully repurposed SFT {} Fragment-Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPSF|C_MakeFragments (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "Fragments SFT nonce of the given amount into its respective Fragments."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MakeFragments patron executor id true nonce amount)
                )
                (format "Successfully Fragmented {} SFT(s) {} of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPSF|C_MergeFragments (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "MErges SFT Fragments nonces of the given amount into the original SFT nonce."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MergeFragments patron executor id true nonce amount)
                )
                (format "Successfully merged {} {} SFT(s) Fragments of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPSF|C_EnableNonceFragmentation (patron:string executor:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        @doc "Enables Fragmentation for a given SFT Nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_EnableNonceFragmentation patron executor id true nonce fragmentation-ind)
                )
                (format "Fragmentation for SFT {} Nonce {} enabled succesfully" [id nonce])
            )
        )
    )
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun DPSF|C_UpdateNonce
        (patron:string executor:string id:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id true [nonce] nos true [new-nonce-data])
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonces
        (patron:string executor:string id:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an SFT, for multiple Nonces at a time"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id true nonces nos true new-nonces-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceRoyalty
        (patron:string executor:string id:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Nonce Native Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty patron executor id true nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceIgnisRoyalty
        (patron:string executor:string id:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Nonce IGNIS Royalty Value, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty patron executor id true nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceName
        (patron:string executor:string id:string nonce:integer nos:bool name:string)
        @doc "[3] Updates Nonce Name, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName patron executor id true nonce nos true name)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceDescription
        (patron:string executor:string id:string nonce:integer nos:bool description:string)
        @doc "[4] Updates Nonce Description, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription patron executor id true nonce nos true description)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceScore
        (patron:string executor:string id:string nonce:integer nos:bool score:decimal)
        @doc "[5] Updates Nonce Score, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore patron executor id true nonce nos true score)
                )
            )
        )
    )
    (defun DPSF|C_RemoveNonceScore (patron:string executor:string id:string nonce:integer nos:bool)
        @doc "[5b] Removes Nonce Score, setting it to -1.0, either Native or Split, for an SFT \
        \ \
        \ Executor: PROVEN INDIRECTLY, and named. This is a thin alias: it delegates to \
        \ DPSF|C_UpdateNonceScore in THIS module, and that wrapper's own call chain is what \
        \ proves the account. FORWARDED matches cross-module `ref-X::` calls by design, so an \
        \ intra-Talos delegation has to be traced by a human and written down. \
        \ (patron/executor canon 2.2, 2026-09-22.)"
        (DPSF|C_UpdateNonceScore patron executor id nonce nos -1.0)
    )
    (defun DPSF|C_UpdateNonceMetaData
        (patron:string executor:string id:string nonce:integer nos:bool meta-data:object)
        @doc "[6] Updates Nonce Meta-Data, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData patron executor id true nonce nos true meta-data)
                )
            )
        )
    )
    (defun DPSF|C_UpdateNonceURI
        (
            patron:string executor:string id:string nonce:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Nonce URI, either Native or Split, for an SFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI patron executor id true nonce nos true ay u1 u2 u3)
                )
            )
        )
    )
    ;;
    ;;  [11] EQUITY
    ;;
    (defun DPSF|C_IssueCompany:string
        (
            patron:string executor:string collection-name:string collection-ticker:string
            royalty:decimal ignis-royalty:decimal ipfs-links:[string]
        )
        @doc "Issues an SFT Equity Collection to tokenize Company Shares on Ouronet. \
            \ Royalty is the standard Royalty for the Whole Collection \
            \ While <ignis-royalty> is the ignis Royalty for 1% of Company Shares \
            \ This makes the value of <ignis-royalty> in $ the Price to transfer All Existing Shares as Package Shares \
            \ \
            \ <ipfs-links> must be 8 elements long.\
            \ The Collection is an Image SFT Collection, automanaged by the <dpdc> Smart Ouronet Account as Collection Owner \
            \ Only 8 Elements can exist in this Collection, and no more can be added. \
            \ \
            \ Equity Collections Costs 0.001 IGNIS per Share for Pure Share Transfers as GAS Fees. \
            \ Package Share cost the normal <ignis|small> price per unit as GAS Fees, as for all SFTs.\
            \ \
            \ <ipfs-links> must contain a 24 string list, 8 links for each element in the primary secondarz and tertiary uri list"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-EQUITY:module{EquityV2} EQUITY)
                    ;;
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-EQUITY::C_IssueShareholderCollection 
                            patron executor collection-name collection-ticker
                            royalty ignis-royalty ipfs-links
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;Issuing a COMPANY is $100 in IGNIS deter and $100 in STOA (spec): the equity
                ;;premium leg. The underlying SFT collection issue carries its own cost on top,
                ;;in both currencies — same composition rule as the VST links.
                (ref-IGNIS::XE_CollectStoa patron (ref-IGNIS::UC_StoaPrice "issue-shareholder"))
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at 0 (at "output" ico))
            )
        )
    )
    (defun DPSF|C_MorphEquity
        (patron:string executor:string id:string input-nonce:integer input-amount:integer output-nonce:integer)
        @doc "Converts any Nonce to [1 2 3 4 5 6 7 8] to any Nonce [1 2 3 4 5 6 7 8] \
            \ Input-Nonce must be different from Output-Nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (ref-EQUITY:module{EquityV2} EQUITY)
                    ;;
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-EQUITY::C_MorphPackageShares
                            patron executor id input-nonce input-amount output-nonce
                        )
                    )
                    (output:list (at "output" ico))
                    (ir-nonces:[integer] (at 0 output))
                    (ir-amounts:[integer] (at 1 output))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor [id] [true] [ir-nonces] [ir-amounts])
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (if (= input-nonce 1)
                    [
                        ;;Make Package Shares
                        (format "Successfully combined {} Shares to Tier {} Package Share on Account {}" [input-amount (- output-nonce 1) sa])
                        (if (= s 0.0)
                            (format "Combining Shares executed witout collecting any IGNIS Royalties for the Collectable {}" [id])
                            (format "Combining Shares executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                        )
                    ]
                    (if (= output-nonce 1)
                        [
                            ;;Brake Package Shares
                            (format "Successfully broke {} Tier {} Package Share to {} Shares on Account {}" [input-amount (- input-nonce 1) (at 1 ir-amounts) sa])
                            (if (= s 0.0)
                                (format "Breaking Package Shares executed witout collecting any IGNIS Royalties for the Collectable {}" [id])
                                (format "Breaking Package Shares executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                            )
                        ]
                        [
                            ;;Convert Package Shares
                            (format "Successfully Converter Tier {} to Tier {} Package Shares on Account {}" [(- input-nonce 1) (- output-nonce 1) sa])
                            (if (= s 0.0)
                                (format "Converting Package Shares executed witout collecting any IGNIS Royalties for the Collectable {}" [id])
                                (format "Converting Package Shares executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                            )
                        ]
                        
                        
                    )
                )
            )
        )
    )

)

;; ---- source: 1_SOVEREIGN/STAGE_02/3_Talos/02_TS02-C2.pact (module only -- its interface is already live)
(module TS02-C2 GOV
    @doc "TALOS Stage 2 Client Functiones Part 2 - NFT Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_ClientTwoV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS02-C2                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS02-C2_ADMIN)))
    (defcap GOV|TS02-C2_ADMIN ()                        (enforce-guard GOV|MD_TS02-C2))
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
        (with-capability (GOV|TS02-C2_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS02-C2_ADMIN)
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
        (with-capability (GOV|TS02-C2_ADMIN)
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
        (with-capability (GOV|TS02-C2_ADMIN)
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
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|DPDC-C:module{OuronetPolicyV2} DPDC-C)
                (ref-P|DPDC-I:module{OuronetPolicyV2} DPDC-I)
                (ref-P|DPDC-R:module{OuronetPolicyV2} DPDC-R)
                (ref-P|DPDC-MNG:module{OuronetPolicyV2} DPDC-MNG)
                (ref-P|DPDC-N:module{OuronetPolicyV2} DPDC-N)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPDC-F:module{OuronetPolicyV2} DPDC-F)
                (ref-P|DPDC-S:module{OuronetPolicyV2} DPDC-S)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|TS01-A::P|A_AddIMP mg)
            (ref-P|DPDC::P|A_AddIMP mg)
            (ref-P|DPDC-C::P|A_AddIMP mg)
            (ref-P|DPDC-I::P|A_AddIMP mg)
            (ref-P|DPDC-R::P|A_AddIMP mg)
            (ref-P|DPDC-MNG::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|DPDC-F::P|A_AddIMP mg)
            (ref-P|DPDC-S::P|A_AddIMP mg)
            (ref-P|DPDC-N::P|A_AddIMP mg)
            ;;IGNIS RESTRUCTURE 2026-09-20: the collectors became protected X_ functions
            ;;behind `P|UEV_IMC`, so every module that bills must be a registered IMP peer
            ;;of IGNIS or the fee call dies with "None of the guards passed".
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
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
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [2] DPDC
    ;;
    (defun DPNF|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPNF Token <entity-id> costing 500 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC::C_UpdatePendingBranding patron executor entity-id false logo description website social)
                )
            )
        )
    )
    (defun DPNF|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Upgrades Branding for DPNF Token, making it a premium BrandingV2. \
            \ Also sets pending-branding to live branding if its branding is not live yet"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DPDC::C_UpgradeBranding patron executor entity-id false months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    ;;
    ;;  [3] DPDC-C
    ;;
    (defun DPNF|C_Create:string
        (
            patron:string executor:string id:string
            input-nonce-data:[object{DpdcUdcV2.DPDC|NonceData}]
        )
        @doc "Creates a new NFT Collection Element(s), having a new nonce, \
            \ of amount 1, on the <creator> account."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-C:module{DpdcCreateV2} DPDC-C)
                    (l:integer (length input-nonce-data))
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (if (= l 1)
                            (ref-DPDC-C::C_CreateNewNonce
                                patron executor id false 0 1 (at 0 input-nonce-data) false
                            )
                            (ref-DPDC-C::C_CreateNewNonces
                                patron executor id false (make-list l 1) input-nonce-data
                            )
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Created {} Clas 0 NonFungible(s) within the {} DPNF Collection"
                    [(at "output" ico) id]
                )
            )
        )
    )
    ;;
    ;;  [4] DPDC-I
    ;;
    ;; DPNF|C_DeployAccount removed — DPDC Audit #35M: see interface-side removal note above.
    (defun DPNF|C_Issue:string
        (
            patron:string 
            executor:string executee:string collection-name:string collection-ticker:string
            can-upgrade:bool can-change-owner:bool can-change-creator:bool can-add-special-role:bool
            can-transfer-nft-create-role:bool can-freeze:bool can-wipe:bool can-pause:bool
        )
        @doc "Issues a new DPNF (Demiourgos Pact Non-Fungible) Digital Collection: <NFT> \
            \ Costs 10x<ignis|token-issue> = 5000 IGNIS and 500 STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-I:module{DpdcIssueV2} DPDC-I)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-I::C_IssueDigitalCollection
                            patron executor executee false
                            collection-name collection-ticker
                            can-upgrade can-change-owner can-change-creator can-add-special-role
                            can-transfer-nft-create-role can-freeze can-wipe can-pause
                            false
                        )
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at 0 (at "output" ico))
            )
        )
    )
    ;;
    ;;  [5] DPDC-R
    ;;
    (defun DPNF|C_ToggleFreezeAccount (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Freezes a given account for a given DPNF Token. Frozen Accounts can no longer send or receive that DPNF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleFreezeAccount patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleExemptionRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles exemption Role for a given DPNF on a given Smart Ouronet Account (Only Smart Ouronet Accounts can accept this role) \
            \ When sending to or receiving from such Accounts, the flat IGNIS Royalty fee must not be paid."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleExemptionRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleBurnRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles burn Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can then burn the DPNF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleBurnRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleUpdateRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles update Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can then update (modify) the Metadata on any DPNF nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleUpdateRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleModifyCreatorRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Modify Creator Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Creator of the DPNF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyCreatorRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleModifyRoyaltiesRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Modify Royalties Role for a given DPNF on any Ouronet Account. \
            \ Such Accounts can proceed to modify the Permille Royalty of any nonce in the  DPNF Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleModifyRoyaltiesRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_ToggleTransferRole (patron:string executor:string executee:string id:string toggle:bool)
        @doc "Toggles Transfer Role for a given DPNF on any Ouronet Account. \
            \ Transfers for any Nonce in the DPNF Collection are then restricted only to and from these accounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_ToggleTransferRole patron executor executee id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_MoveCreateRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Create Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can issue new NFTs in the Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveCreateRole patron executor executee id false)
                )
            )
        )
    )
    (defun DPNF|C_MoveRecreateRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Recreate Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can recreate any existing NFT in the Collection \
            \ Recreation reffers to a complete update (modification) of all NFT properties of a given nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveRecreateRole patron executor executee id false)
                )
            )
        )
    )
    (defun DPNF|C_MoveSetUriRole (patron:string executor:string executee:string id:string)
        @doc "Moves the Set URI Role to another Ouronet Account. A single Account may have this Role \
            \ This is the only account that can modify the URIs of any nonce in the NFT Collection"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-R:module{DpdcRolesV2} DPDC-R)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-R::C_MoveSetUriRole patron executor executee id false)
                )
            )
        )
    )
    ;;
    ;;  [6] DPDC-MNG
    ;;
    (defun DPNF|C_Control (patron:string executor:string id:string cu:bool cco:bool ccc:bool casr:bool ctncr:bool cf:bool cw:bool cp:bool)
        @doc "Controls DPNF Properties"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_Control patron executor id false cu cco ccc casr ctncr cf cw cp)
                )
            )
        )
    )
    (defun DPNF|C_TogglePause (patron:string executor:string id:string toggle:bool)
        @doc "Pauses a DPNF Collection. Paused Collections can no longer be transfered"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_TogglePause patron executor id false toggle)
                )
            )
        )
    )
    (defun DPNF|C_Respawn (patron:string executor:string id:string nonce:integer)
        @doc "Respawns NFT <id> <nonce> on <executor>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_RespawnNFT patron executor id nonce)
                )
                (format "Succesfuly respawned NFT {} Nonce {} on Account {}" [id nonce (UC_ShortAccount executor)])
            )
        )
    )
    (defun DPNF|C_Burn (patron:string executor:string id:string nonce:integer)
        @doc "Burns NFT <id> <nonce> on <executor>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_BurnNFT patron executor id nonce)
                )
                (format "Succesfuly burned NFT {} Nonce {} on Account {}" [id nonce (UC_ShortAccount executor)])
            )
        )
    )
    (defun DPNF|C_WipeNonce (patron:string executor:string executee:string id:string nonce:integer)
        @doc "Wipes NFT <id> <nonce> on <executee>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG) 
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-MNG::C_WipeNonce patron executor executee id false nonce)
                )
                (format "Succesfuly wiped NFT {} Nonce {} from Account {}" [id nonce (UC_ShortAccount executee)])
            )
        )
    )
    (defun DPNF|CC_WipeHeavy (patron:string executor:string executee:string id:string)
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::CC_WipeHeavy patron executor executee id false)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Succesfuly executed Heavy Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|C_WipePure (patron:string executor:string executee:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipePure patron executor executee id false removable-nonces-obj) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Succesfuly executed Pure Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|C_WipeClean (patron:string executor:string executee:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeClean patron executor executee id false nonces) 
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format 
                    "Succesfuly executed Clean Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}" 
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|C_WipeDirty (patron:string executor:string executee:string id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::C_WipeDirty patron executor executee id false nonces)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format
                    "Succesfuly executed Dirty Wipe of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}"
                    [id (UC_ShortAccount executee) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    (defun DPNF|Cp_WipeSlice (patron:string account:string id:string removable-nonces-obj:object{DpdcManagementV2.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes ONE <URHC_BuildWipeSlicePlan> slice of the NFT \
            \ <account>'s <id> nonces. The UI dirty-reads the plan and fires one such tx per \
            \ slice, all in parallel; slices are disjoint, order-independent and retryable \
            \ (replay REVERTS on the zeroed account supply)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-MNG:module{DpdcManagementV2} DPDC-MNG)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-MNG::Cp_WipeSlice account id false removable-nonces-obj)
                    )
                    (no-of-nonces:integer (length (at "r-nonces" (at 0 (at "output" ico)))))
                    (total-nonces-supplies:integer (fold (+) 0 (at "r-amounts" (at 0 (at "output" ico)))))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format
                    "Succesfuly executed Hydra Wipe Slice of NFT {} on Account {}, wiping {} Nonces With a Total Supply of {}"
                    [id (UC_ShortAccount account) no-of-nonces total-nonces-supplies]
                )
            )
        )
    )
    ;;
    ;;  [7] DPDC-T
    ;;
    (defun DPNF|C_Repurpose (patron:string executor:string executee:string id:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose NFT(s) from <executee> to <repurpose-to>. The <executor> must BE the \
            \ collection owner -- that is the authority the whole op rests on, and DPDC-T now \
            \ binds the name to it rather than deriving it silently."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_RepurposeCollectable patron executor executee id false repurpose-to nonces amounts)
                )
                (format "Successfully repurposed NFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPNF|C_TransferNonce (patron:string executor:string executee:string id:string nonce:integer amount:integer method:bool)
        @doc "Transfer an NFT <nonce> of <amount> from <executor> to <executee> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor [id] [false] [[nonce]] [[amount]])
                    )
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer patron executor executee [id] [false] [[nonce]] [[amount]] method)
                )
                [
                    (format "Successfully transfered NFT {} Nonce {} and Amount {} from {} to {}" [id nonce amount sa ra])
                    (if (= s 0.0)
                        (format "Transfer executed without collecting any IGNIS Royalties for the Collectable {}" [id])
                        (format "Transfer executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                    )
                ]
            )
        )
    )
    (defun DPNF|C_TransferNonces (patron:string executor:string executee:string id:string nonces:[integer] amounts:[integer] method:bool)
        @doc "Transfer NFT <nonces> of <amounts> from <executor> to <executee> using <method>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ra:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    ;;
                    (irs:object{DpdcTransferV2.AggregatedRoyalties}
                        (ref-DPDC-T::C_IgnisRoyaltyCollector patron executor [id] [false] [nonces] [amounts])
                    )
                    (c:[string] (at "creators" irs))
                    (r:[decimal] (at "ignis-royalties" irs))
                    (s:decimal (fold (+) 0.0 r))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-T::C_Transfer patron executor executee [id] [false] [nonces] [amounts] method)
                )
                [
                    (format "Successfully transfered NFT {} Nonces {} with Amounts {} from {} to {}" [id nonces amounts sa ra])
                    (if (= s 0.0)
                        (format "Transfer executed without collecting any IGNIS Royalties for the Collectable {}" [id])
                        (format "Transfer executed while collecting {} IGNIS Royalty to the Collectable {} Creator" [s id])
                    )
                ]
            )
        )
    )
    (defun DPNF|C_BulkTransfer
        (patron:string executor:string executee-lst:[string] id:string nonces-array:[[integer]] amounts-array:[[integer]] method:bool)
        @doc "Bulk NFT transfer — son=false wrapper over TS02-C1.DPDC|C_BulkTransfer."
        (let
            (
                (ref-TS02-C1:module{TalosStageTwo_ClientOneV2} TS02-C1)
            )
            (ref-TS02-C1::DPDC|C_BulkTransfer patron executor executee-lst id false nonces-array amounts-array method)
        )
    )
    ;;
    ;;  [8] DPDC-S
    ;;
    (defun DPNF|C_Make
        (patron:string executor:string id:string nonces:[integer] set-class:integer)
        @doc "Makes a Set NFT of Class <set-class>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (nonce:integer (+ 1 (ref-DPDC::UR_NoncesUsed id false)))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_MakeNonFungibleSet patron executor id nonces set-class)
                )
                (format "Successfully generated Class {} Set (Nonce {}) of NFT Collection {} on Account {}" [set-class nonce id sa])
            )
        )
    )
    (defun DPNF|C_Break
        (patron:string executor:string id:string nonce:integer)
        @doc "Brakes an NFT Nonce representing an NFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (set-class:integer (ref-DPDC::UR_NonceClass id false nonce))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_BreakNonFungibleSet patron executor id nonce)
                )
                (format "Successfully broken Class {} Set (Nonce {}) of NFT Collection {} on Account {}" [set-class nonce id sa])
            )
        )
    )
    (defun DPNF|C_DefinePrimordialSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Primordial NFT Set. Primordial Sets are composed of Class 0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-S::C_DefinePrimordialSet patron executor id false set-name score-multiplier set-definition ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Primordial Set <{}> (set-class {}) for NFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPNF|C_DefineCompositeSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            set-definition:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Composite NFT Set. Composite Sets are composed of Class (!=0) Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-S::C_DefineCompositeSet patron executor id false set-name score-multiplier set-definition ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Composite Set <{}> (set-class {}) for NFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPNF|C_DefineHybridSet
        (
            patron:string executor:string id:string set-name:string score-multiplier:decimal
            primordial-sd:[object{DpdcUdcV2.DPDC|AllowedNonceForSetPosition}]
            composite-sd:[object{DpdcUdcV2.DPDC|AllowedClassForSetPosition}]
            ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Defines a New Hybrid NFT Set. Hybrid Sets are composed of both Class 0 and Non-0 Nonces"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPDC-S::C_DefineHybridSet patron executor id false set-name score-multiplier primordial-sd composite-sd ind)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED set-class. It used to report only `set-name` -- the
                ;;caller's own input -- while set-class is an AUTO-INCREMENT integer assigned
                ;;inside XI_*Set. Unlike a name-derived id it cannot be reconstructed after the
                ;;fact, yet C_ToggleSet / C_RenameSet / C_UpdateSetNonce* all key on it. The core
                ;;was discarding it into an empty cumulator output; both halves are fixed.
                ;;StoicSyntax 2.16.2.
                (format "Hybrid Set <{}> (set-class {}) for NFT Collection {} defined succesfully" [set-name (at 0 (at "output" ico)) id])
            )
        )
    )
    (defun DPNF|C_EnableSetClassFragmentation
        (
            patron:string executor:string id:string set-class:integer
            fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData}
        )
        @doc "Enables Fragmentation for a given Set Class. This allows all NFTs of the given Set Class to be Fragmented"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_EnableSetClassFragmentation patron executor id false set-class fragmentation-ind)
                )
                (format "Set Class {} for NFT {} succesfully fragmented" [set-class id])
            )
        )
    )
    (defun DPNF|C_ToggleSet (patron:string executor:string id:string set-class:integer toggle:bool)
        @doc "Enables or Disables a Set. A disabled Set allows only for decomposition of Set Elements, but not for composition"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_ToggleSet patron executor id false set-class toggle)
                )
                (format "NFT {} Set Class {} succesfully turned {}" [id set-class (if toggle "ON" "OFF")])
            )
        )
    )
    (defun DPNF|C_RenameSet (patron:string executor:string id:string set-class:integer new-name:string)
        @doc "Renames an NFT Set"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-S:module{DpdcSetsV2} DPDC-S)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-S::C_RenameSet patron executor id false set-class new-name)
                )
                (format "NFT {} Set Class {} succesfuly renamed to <{}>" [id set-class new-name])
            )
        )
    )
    ;; DPNF|C_UpdateSetMultiplier removed — DPDC Audit #15H.
    ;;
    (defun DPNF|C_UpdateSetNonce 
        (patron:string executor:string id:string set-class:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id false [set-class] nos false [new-nonce-data])
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonces
        (patron:string executor:string id:string set-classes:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Set Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id false set-classes nos false new-nonces-data)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceRoyalty
        (patron:string executor:string id:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Set Nonce Native Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty patron executor id false set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceIgnisRoyalty
        (patron:string executor:string id:string set-class:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Set Nonce IGNIS Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty patron executor id false set-class nos false royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceName
        (patron:string executor:string id:string set-class:integer nos:bool name:string)
        @doc "[3] Updates Set Nonce Name, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName patron executor id false set-class nos false name)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceDescription
        (patron:string executor:string id:string set-class:integer nos:bool description:string)
        @doc "[4] Updates Set Nonce Description, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription patron executor id false set-class nos false description)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceScore
        (patron:string executor:string id:string set-class:integer nos:bool score:decimal)
        @doc "[5] Updates Set Nonce Score, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore patron executor id false set-class nos false score)
                )
            )
        )
    )
    (defun DPNF|C_RemoveSetNonceScore (patron:string executor:string id:string set-class:integer nos:bool)
        @doc "[5b] Removes Set Nonce Score, setting it to -1.0, either Native or Split, for an NFT \
        \ \
        \ Executor: PROVEN INDIRECTLY, and named. This is a thin alias: it delegates to \
        \ DPNF|C_UpdateSetNonceScore in THIS module, and that wrapper's own call chain is what \
        \ proves the account. FORWARDED matches cross-module `ref-X::` calls by design, so an \
        \ intra-Talos delegation has to be traced by a human and written down. \
        \ (patron/executor canon 2.2, 2026-09-22.)"
        (DPNF|C_UpdateSetNonceScore patron executor id set-class nos -1.0)
    )
    (defun DPNF|C_UpdateSetNonceMetaData
        (patron:string executor:string id:string set-class:integer nos:bool meta-data:object)
        @doc "[6] Updates Set Nonce Meta-Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData patron executor id false set-class nos false meta-data)
                )
            )
        )
    )
    (defun DPNF|C_UpdateSetNonceURI
        (
            patron:string executor:string id:string set-class:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Set Nonce URI, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI patron executor id false set-class nos false ay u1 u2 u3)
                )
            )
        )
    )
    ;;
    ;;  [9] DPDC-F
    ;;
    (defun DPNF|C_RepurposeFragments (patron:string executor:string executee:string id:string repurpose-to:string nonces:[integer] amounts:[integer])
        @doc "Repurpose NFT Fragment(s) from <executee> to <repurpose-to>. The <executor> must \
            \ BE the collection owner -- that is the authority the whole op rests on, and \
            \ DPDC-F now binds the name to it rather than deriving it silently."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                    (sf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    ;; #79: this is the NFT (C_DPNF|) wrapper — son MUST be false. Was hardcoded `true`
                    ;; (SFT), so it read CNF from the DPSF table and failed. Never caught: no test coverage.
                    (ref-DPDC-F::C_RepurposeCollectableFragments patron executor executee id false repurpose-to nonces amounts)
                )
                (format "Successfully repurposed NFT {} Fragment-Nonces {} with Amounts {} from {} to {}" [id nonces amounts sf st])
            )
        )
    )
    (defun DPNF|C_MakeFragments (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "Fragments NFT nonce of the given amount into its respective Fragments."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MakeFragments patron executor id false nonce amount)
                )
                (format "Succesfuly Fragmented {} NFT(s) {} of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPNF|C_MergeFragments (patron:string executor:string id:string nonce:integer amount:integer)
        @doc "MErges NFT Fragments nonces of the given amount into the original NFT nonce."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_MergeFragments patron executor id false nonce amount)
                )
                (format "Succesfuly merged {} {} NFT(s) Fragments of Nonce {}" [amount id nonce])
            )
        )
    )
    (defun DPNF|C_EnableNonceFragmentation (patron:string executor:string id:string nonce:integer fragmentation-ind:object{DpdcUdcV2.DPDC|NonceData})
        @doc "Enables Fragmentation for a given NFT Nonce"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-F:module{DpdcFragmentsV2} DPDC-F)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-F::C_EnableNonceFragmentation patron executor id false nonce fragmentation-ind)
                )
                (format "Fragmentation for NFT {} Nonce {} enabled succesfully" [id nonce])
            )
        )
    )
    ;;
    ;;  [10] DPDC-N
    ;;
    (defun DPNF|C_UpdateNonce 
        (patron:string executor:string id:string nonce:integer nos:bool new-nonce-data:object{DpdcUdcV2.DPDC|NonceData})
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id false [nonce] nos true [new-nonce-data])
                )
                (format "Nonce {} updated successfully!" [nonce])
            )
        )
    )
    (defun DPNF|C_UpdateNonces
        (patron:string executor:string id:string nonces:[integer] nos:bool new-nonces-data:[object{DpdcUdcV2.DPDC|NonceData}])
        @doc "[0] Updates Full Nonce Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonces patron executor id false nonces nos true new-nonces-data)
                )
                (format "Nonces {} updated successfully!" [nonces])
            )
        )
    )
    (defun DPNF|C_UpdateNonceRoyalty
        (patron:string executor:string id:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[1] Updates Nonce Native Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceRoyalty patron executor id false nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceIgnisRoyalty
        (patron:string executor:string id:string nonce:integer nos:bool royalty-value:decimal)
        @doc "[2] Updates Nonce IGNIS Royalty Value, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceIgnisRoyalty patron executor id false nonce nos true royalty-value)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceName
        (patron:string executor:string id:string nonce:integer nos:bool name:string)
        @doc "[3] Updates Nonce Name, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceName patron executor id false nonce nos true name)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceDescription
        (patron:string executor:string id:string nonce:integer nos:bool description:string)
        @doc "[4] Updates Nonce Description, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceDescription patron executor id false nonce nos true description)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceScore
        (patron:string executor:string id:string nonce:integer nos:bool score:decimal)
        @doc "[5] Updates Nonce Score, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceScore patron executor id false nonce nos true score)
                )
            )
        )
    )
    (defun DPNF|C_RemoveNonceScore (patron:string executor:string id:string nonce:integer nos:bool)
        @doc "[5b] Removes Nonce Score, setting it to -1.0, either Native or Split, for an NFT \
        \ \
        \ Executor: PROVEN INDIRECTLY, and named. This is a thin alias: it delegates to \
        \ DPNF|C_UpdateNonceScore in THIS module, and that wrapper's own call chain is what \
        \ proves the account. FORWARDED matches cross-module `ref-X::` calls by design, so an \
        \ intra-Talos delegation has to be traced by a human and written down. \
        \ (patron/executor canon 2.2, 2026-09-22.)"
        (DPNF|C_UpdateNonceScore patron executor id nonce nos -1.0)
    )
    (defun DPNF|C_UpdateNonceMetaData
        (patron:string executor:string id:string nonce:integer nos:bool meta-data:object)
        @doc "[6] Updates Nonce Meta-Data, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceMetaData patron executor id false nonce nos true meta-data)
                )
            )
        )
    )
    (defun DPNF|C_UpdateNonceURI
        (
            patron:string executor:string id:string nonce:integer nos:bool
            ay:object{DpdcUdcV2.URI|Type} u1:object{DpdcUdcV2.URI|Data} u2:object{DpdcUdcV2.URI|Data} u3:object{DpdcUdcV2.URI|Data}
        )
        @doc "[7] Updates Nonce URI, either Native or Split, for an NFT"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC-N:module{DpdcNonceV2} DPDC-N)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DPDC-N::C_UpdateNonceURI patron executor id false nonce nos true ay u1 u2 u3)
                )
            )
        )
    )

)


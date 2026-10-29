;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 7 of 8
;; This is STEP 7 of 8 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-6 must have run first, including the init steps between deploys.
;; 2 source file(s), 259,571 gas measured in the REPL gas model, 234,901 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08b_EVCT.pact
;;   1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact
;;
;; TOTAL: 2 interface(s), 2 module(s), 4 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08b_EVCT.pact
;;      interface  AcquisitionRewardEvictionV1
;;      module     AQP-EVCT
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact
;;      interface  TalosStageTwo_ClientThreeV6
;;      module     TS02-C3
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08b_EVCT.pact ============
;; net: v1   ·   dev: v1   ;; NEW MODULE 2026-10-29. Never deployed, so its interface stays V1.
;; Deploy: load THIS file — interface + module ship together.
;; ==============================================================================
;; AQP-EVCT — REWARD EVICTION. The FVT owner collects FOR their stakers.
;;
;; A collect is triggered by the beneficiary: `CC_Collect` opens with
;; `CAP_EnforceAccountOwnership executor`, because only the claimant may trigger
;; its own claim. An EVICTION is the same operation triggered by the FVT OWNER on
;; the beneficiary's behalf — a benevolence, paid for by the owner.
;;
;; IT RUNS THE SAME CODE, NOT A COPY. `AQP-FVT::XE_EvictDrip` and
;; `XE_EvictPay` call `XI_CollectDrip` / `XI_CollectPay` — the phase functions
;; extracted out of `CC_Collect` on the same day — so a beneficiary receives
;; exactly what a self-collect would have paid them. That is a property of the
;; call graph, not of a test.
;;
;; WHAT MADE IT POSSIBLE AT ALL. The triplet reward ladder used to coil as the
;; <collector>, and a coil's first leg transfers OUT of the coiler, so
;; `C_Transfer` enforces its ownership. An eviction has no beneficiary signature,
;; so the ladder was reachable by the beneficiary alone. It now coils as
;; `AQP|SC_NAME` through `ATSU::XB_Coil`, whose ownership the AQP
;; remote-governor guard satisfies. Owner's framing: "we could, with the creation
;; of the reward eviction mechanic and module, to also change how CC_Collect
;; itself handles the triplet rewards ... This way we would have a common core."
;;
;; ──────────────────────────────────────────────────────────────────────────────
;; WHAT IT DOES *NOT* DO, each a ruling rather than an omission
;; ──────────────────────────────────────────────────────────────────────────────
;;   · NO FREEZE. Owner, 2026-10-29: "evict rewards doesn't need freeze, because
;;     it is simply a collect rewards triggered by the pool owner instead of the
;;     beneficiary. there is no reason to freeze the pool." Contrast AQP-VCT,
;;     which freezes for a whole-pool unwind.
;;   · NO SCORE CHANGE. "Eviction has nothing to do with score, its just sending
;;     the rewards." It DOES refresh a stale deb, because a collect does — that
;;     is PHASE 6 inside the shared core, not a score delta.
;;   · NO FORCED-FIX PENALTY. `XE_EvictPay` ZEROES the count instead of billing
;;     it: with an automaton evicting daily a user might never self-collect, so an
;;     accumulating penalty would grow unpayable and a deterrent would become a
;;     trap. The charge still bites the user who is unstaled by an inject and
;;     then collects for themselves.
;;   · NO ZERO LEGS. "0 reward simply means there is nothing to collect" — the
;;     plan reader emits only positive legs and the entrypoint re-checks, so a
;;     slice that has gone stale REFUSES rather than paying to move nothing.
;;
;; ──────────────────────────────────────────────────────────────────────────────
;; THREE SHAPES, AND WHICH ONE THE CLIENT USES — owner, 2026-10-30
;; ──────────────────────────────────────────────────────────────────────────────
;; One leg is (beneficiary × score-entity × reward-lane) with `fvt-id` constant.
;; `URHC_BuildEvictPlans` emits exactly one object per leg, and the three
;; entrypoints differ only in how many of those legs one transaction carries:
;;
;;   CC_FullEvictRewards     ALL legs, ONE transaction. Scans on chain, so it
;;   AA_FullEvictRewards     takes no plan. THE DEFAULT THE UI TRIES FIRST —
;;                           "if it fits it is what would be executed." Bounded
;;                           by the node gas meter, which is why the other two
;;                           exist.
;;
;;   CC_EvictSingleReward    ONE leg, ONE transaction. WHAT THE UI FALLS BACK TO
;;   AA_EvictSingleReward    when Full does not fit, and the owner's preferred
;;                           shape: "you can see instantly if there are 120 tx
;;                           constructed there are 120 legs." The transaction
;;                           count IS the leg count, no packing loop, and no
;;                           single transaction can approach the ceiling — safe
;;                           BY CONSTRUCTION rather than by measurement.
;;
;;   CCp_EvictMultiRewards   N legs per transaction, packed toward the 2,000,000
;;   AAp_EvictMultiRewards   limit. FEWER transactions, at the cost of a
;;                           construct-measure-resize loop. Owner: "I would keep
;;                           that only for demonstration purposes" — reachable by
;;                           a UI toggle, not the default.
;;
;; So the client's decision tree is: try Full; if the gas model refuses it, fan
;; out Single, one per plan entry; and offer Multi behind a switch for anyone who
;; wants the smaller transaction count.
;;
;; WHAT IS ORDER-DEPENDENT IN A FAN-OUT, and it is only one thing: THE DUST. The
;; last claimant on a lane sweeps the remainder, so whichever transaction lands
;; last on a lane receives it. The lane still ends at zero and the total is
;; unaffected — and this IS the ruling (2026-10-29): dust to the royalty sink if
;; the pair has one, "if not, to the last beneficiary".
;;
;; A REFUSED LEG IS NOT A LOST LEG either. Every entrypoint re-checks the
;; claimable, so a leg collected between the read and the send refuses and moves
;; nothing; a re-read returns only what is left. Firing N at once must expect
;; some to bounce.
;;
;; ──────────────────────────────────────────────────────────────────────────────
;; WHY THE MULTI SLICE IS PARALLEL ARRAYS RATHER THAN OBJECTS
;; ──────────────────────────────────────────────────────────────────────────────
;; A slice is four parallel arrays. They are PRIMITIVE arrays deliberately: an
;; `object{Schema}` argument would have to live in `AcquisitionSchemasV3`, whose
;; bump cascades through nine modules. Parallel arrays need no shared schema, and
;; the objects are built inside this module where the schema is local. It is also
;; the shape `AQP-VCT::CCp_BatchVacateTrueFungible` already uses.
;;
;; The UI dirty-reads `URHC_BuildEvictPlans` (or `URHC_BuildEvictSlicePlan` for
;; ready-made arrays), splits into gas-bounded slices, and fires them in PARALLEL
;; — legs are order-independent, and block execution is serial, which is the same
;; reasoning AQP-VCT records for its batches. Being a LIVE read, a re-read after a
;; partial run returns only what is left.
;; ==============================================================================

(interface AcquisitionRewardEvictionV1
    @doc "Reward eviction for an FVT: the owner collects on behalf of every staker with a \
        \ positive claimable. Plan readers, the slice partitioner, cost readers and THREE \
        \ owner-gated client entrypoints that differ only in how many legs one transaction \
        \ carries — all legs (Full), one leg (Single), or a packed slice (Multi). Writes nothing \
        \ itself: every write is a forward call into AQP-FVT's eviction surface, which runs the \
        \ collect path's own phase functions."

    ;;{1}  CAP
    ;;{2}  FUN
    ;;{5.1}  Compute [UC/UCv]
    (defun UC_EvictLegsFromParallelArrays:[object] (beneficiaries:[string] score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string]))
    (defun UC_CeilDiv:integer (numerator:integer denominator:integer))
    ;;{5.2}  Read [UR]
    ;;{5.3}  Read-Compute [URC/URCv]
    (defun URHC_BuildEvictPlans:[object] (fvt-id:string))
    (defun URH_EvictInventory:object (fvt-id:string))
    (defun URHC_EvictLegCount:integer (fvt-id:string))
    (defun URHC_BuildEvictSlicePlan:object (fvt-id:string slice-count:integer))
    (defun URCi_EvictMultiRewards:decimal (patron:string fvt-id:string beneficiaries:[string] score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string]))
    (defun URCi_EvictSingleReward:decimal (patron:string fvt-id:string beneficiary:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun URCi_FullEvictRewards:decimal (patron:string fvt-id:string))
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_EvictSliceShape (beneficiaries:[string] score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string]))
    (defun CAP_EvctFvtOwner (fvt-id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    (defun CCp_EvictMultiRewards:object{IgnisCollectorV4.OutputCumulator}
        (patron:string evictor:string fvt-id:string beneficiaries:[string] score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string]))
    (defun CC_EvictSingleReward:object{IgnisCollectorV4.OutputCumulator}
        (patron:string evictor:string fvt-id:string beneficiary:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun CC_FullEvictRewards:object{IgnisCollectorV4.OutputCumulator}
        (patron:string evictor:string fvt-id:string))
)

(module AQP-EVCT GOV
    @doc "Reward eviction for an AQP FVT: the owner collects on behalf of every staker carrying a \
        \ positive claimable. Owns no table, holds no custody and performs no write of its own -- \
        \ every leg is a forward call into AQP-FVT's eviction surface, which runs the SAME phase \
        \ functions a self-collect runs. See the file header for the rulings it implements."

    ;;{0}  IMPLEMENTERS
    (implements OuronetPolicyV2)
    (implements AcquisitionRewardEvictionV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    (defconst GOV|MD_EVCT (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV () (compose-capability (GOV|EVCT_ADMIN)))
    (defcap GOV|EVCT_ADMIN () (enforce-guard GOV|MD_EVCT))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
    (defcap P|EVCT|CALLER ()
        true
    )
    ;;NO REMOTE-GOV CAPABILITY HERE, deliberately. AQP-VCT needs one because it sends assets
    ;;OUT of AQP|SC_NAME itself. This module never touches custody: every payout leg runs inside
    ;;AQP-FVT::XE_EvictPay, under AQP-FVT's own P|FVT|REMOTE-GOV grant. So there is nothing to
    ;;register on AQP-POOL's policy table and NO governor rotation on AQP|SC_NAME is required --
    ;;which is the single most expensive step a new AQP module can otherwise incur, since that
    ;;rotation REPLACES the guard set and a botched one would strip collect and vacate of their
    ;;vault authority too.
    (defcap P|EVCT|RECIPE ()
        @doc "Eviction recipe: the forward calls into AQP-FVT's eviction surface (P|EVCT|CALLER) and \
            \ this module's own SECURE. No custody leg, so no remote governor -- see above."
        (compose-capability (P|EVCT|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
        (with-capability (GOV|EVCT_ADMIN)
            (write P|T policy-name {"policy" : policy-guard})
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|EVCT_ADMIN)
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
        (with-capability (GOV|EVCT_ADMIN)
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
        (with-capability (GOV|EVCT_ADMIN)
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
        @doc "Post-deploy: EVCT SECURE on AQP-FVT's IMP, so the XE_EvictDrip / XE_EvictPay forward \
            \ calls pass P|UEV_IMC. \
            \ \
            \ THAT IS THE WHOLE REGISTRATION, and the shortness is the point. This module reads RPS \
            \ through unprotected readers (no IMP needed), never touches TFT/DPOF/DPDC-T, and never \
            \ sends from AQP|SC_NAME -- so unlike AQP-VCT it needs no entry on AQP-POOL's policy \
            \ table and no governor rotation. IGNIS is collected by the Talos wrapper, as AQP-VCT's \
            \ is, so no IGNIS IMP either."
        (let
            (
                (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                ;;
                (dg:guard (create-capability-guard (SECURE)))
            )
            (ref-P|FVT::P|A_AddIMP dg)
        )
    )

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap SECURE ()
        true
    )
    ;;{C3}  Ownership
    (defcap EVCT|C>EVICT-MULTI
        (evictor:string fvt-id:string beneficiaries:[string] score-entity-types:[integer]
         score-entity-id-lst:[string] reward-dptf-ids:[string])
        @doc "One eviction SLICE. Validates the slice shape and the FVT owner, then composes the \
            \ recipe. \
            \ \
            \ IT DOES NOT VALIDATE THE CLAIMABLES, and that is not an oversight -- the entrypoint \
            \ does, because the figure it must check is a PROJECTION including stream time vested to \
            \ now (RPS::URC_LiveClaimable), and a capability body is the wrong place for a per-leg \
            \ fold over a list whose length the UI chose. The refusal belongs where the slice is, \
            \ and a CC_ may enforce."
        @event
        (CAP_EvctFvtOwner fvt-id)
        (UEV_EvictSliceShape beneficiaries score-entity-types score-entity-id-lst reward-dptf-ids)
        (compose-capability (P|EVCT|RECIPE))
    )
    (defcap EVCT|C>EVICT-SINGLE (evictor:string fvt-id:string)
        @doc "ONE LEG, ONE TRANSACTION -- the default path for an FVT too large to evict whole. \
            \ Owner-gated identically to its siblings; no slice shape to validate, because there is \
            \ no array to be ragged. \
            \ \
            \ WHY A SEPARATE CAPABILITY RATHER THAN EVICT-MULTI WITH ONE ELEMENT. The @event is the \
            \ reason: a campaign of 120 single-leg transactions emits 120 EVICT-SINGLE events, and an \
            \ auditor reading the chain can count legs without reconstructing array lengths out of a \
            \ MULTI event. The owner's point about legibility holds on chain as well as in the UI."
        @event
        (CAP_EvctFvtOwner fvt-id)
        (compose-capability (P|EVCT|RECIPE))
    )
    (defcap EVCT|C>FULL-EVICT (evictor:string fvt-id:string)
        @doc "Whole-FVT eviction in ONE transaction -- the convenience path for a small FVT, scanning \
            \ its own legs rather than taking a fed slice. Owner-gated identically; the gas meter is \
            \ the real ceiling, which is why the sliced entrypoint exists at all."
        @event
        (CAP_EvctFvtOwner fvt-id)
        (compose-capability (P|EVCT|RECIPE))
    )

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Compute [UC/UCv]
    (defun UC_CeilDiv:integer (numerator:integer denominator:integer)
        @doc "Ceiling division, for sizing N slices over a leg count."
        (if (<= denominator 0)
            0
            (if (= 0 (mod numerator denominator))
                (/ numerator denominator)
                (+ 1 (/ numerator denominator))
            )
        )
    )
    (defun UC_EvictLegsFromParallelArrays:[object]
        (beneficiaries:[string] score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
        @doc "Zip four parallel arrays into leg objects. PURE -- the shape check is UEV_EvictSliceShape's \
            \ job and the caller has already run it, so this does no validation and reads nothing. \
            \ Mirrors AQP-VCT::UC_TfLegsFromParallelArrays: the arrays cross the module boundary \
            \ because a shared OBJECT argument would have to live in AcquisitionSchemasV3, whose bump \
            \ cascades through nine modules. Objects are built HERE, where the shape is local."
        (map
            (lambda (i:integer)
                {"beneficiary"        : (at i beneficiaries)
                ,"score-entity-type"  : (at i score-entity-types)
                ,"score-entity-id"    : (at i score-entity-ids)
                ,"reward-dptf-id"     : (at i reward-dptf-ids)}
            )
            (enumerate 0 (- (length beneficiaries) 1))
        )
    )
    ;;{5.3}  Read-Compute [URC/URCv]
    (defun URHC_BuildEvictPlans:[object] (fvt-id:string)
        @doc "HEAVY. Every eviction leg this FVT currently owes: one row per \
            \ (beneficiary x score-entity x reward-lane) with a POSITIVE claimable, as \
            \ {beneficiary, score-entity-type, score-entity-id, reward-dptf-id, pool-id, claimable}. \
            \ \
            \ THE TRIPLE DOES NOT EXIST AS A TABLE, so it is composed from the two readers that do: \
            \ RPS::URHC_BuildInjectScorePlans gives score-entities x enabled reward lanes (with the \
            \ score-entity-TYPE already resolved, which is why it is used instead of the id-only \
            \ reader), and RPS::URH_FvtPresentUsers gives the beneficiary set. \
            \ \
            \ THE PRESENT-USER SET IS A SUPERSET and its own doc says so: 'Stale true rows are \
            \ harmless (consumer no-ops on zero-weight)'. The claimable filter is what makes it \
            \ exact here, so no caller has to know that. \
            \ \
            \ FILTERED ON URC_LiveClaimable, NOT on the stored claimable, and the difference matters: \
            \ LiveClaimable is a PROJECTION that includes stream time vested up to now, so a lane \
            \ carrying a live stream is included at the value the drip is about to realise. Filtering \
            \ on the pre-drip figure would silently skip exactly the streamed lanes an eviction \
            \ exists to clear. \
            \ \
            \ `/local` ONLY in practice: three nested scans plus a point read per leg. The UI reads \
            \ this, slices it and fires the slices in parallel. Being a LIVE read, a re-read after a \
            \ partial run returns only what is left -- the same property AQP-VCT's inventory readers \
            \ rely on."
        (let
            (
                (users:[string] (RPS.URH_FvtPresentUsers fvt-id))
                (plans:[object{AcquisitionSchemasV3.FVT|SettleScorePlan}]
                    (RPS.URHC_BuildInjectScorePlans fvt-id))
            )
            (filter
                (lambda (leg:object) (> (at "claimable" leg) 0.0))
                (fold
                    (lambda (acc:[object] plan:object{AcquisitionSchemasV3.FVT|SettleScorePlan})
                        (+ acc
                           (let
                               (
                                   (set-type:integer (at "score-entity-type" plan))
                                   (set-id:string    (at "score-entity-id" plan))
                                   (lanes:[string]   (at "reward-dptf-ids" plan))
                               )
                               (let
                                   (
                                       (pool-id:string (AQP-FVT.URC_CollectPoolId set-type set-id))
                                   )
                                   (fold
                                       (lambda (inner:[object] lane:string)
                                           (+ inner
                                              (map
                                                  (lambda (u:string)
                                                      {"beneficiary"       : u
                                                      ,"score-entity-type" : set-type
                                                      ,"score-entity-id"   : set-id
                                                      ,"reward-dptf-id"    : lane
                                                      ,"pool-id"           : pool-id
                                                      ,"claimable"         :
                                                          (RPS.URC_LiveClaimable u fvt-id pool-id set-type set-id lane)}
                                                  )
                                                  users
                                              )
                                           )
                                       )
                                       []
                                       lanes
                                   )
                               )
                           )
                        )
                    )
                    []
                    plans
                )
            )
        )
    )
    (defun URHC_EvictLegCount:integer (fvt-id:string)
        @doc "HEAVY. How many legs an eviction of this FVT would run -- the UI's preflight for sizing \
            \ slices. Same scan as URHC_BuildEvictPlans; call that one if the rows are wanted too."
        (length (URHC_BuildEvictPlans fvt-id))
    )
    (defun URH_EvictInventory:object (fvt-id:string)
        @doc "HEAVY. The eviction inventory as {legs, leg-count} -- the single dirty read a client \
            \ needs. Bare object by design: a module-defined schema could not be declared on this \
            \ module's interface, and AQP-VCT's URH_Vacate*Inventory readers answer the same shape."
        {"legs"      : (URHC_BuildEvictPlans fvt-id)
        ,"leg-count" : (URHC_EvictLegCount fvt-id)}
    )
    (defun URHC_BuildEvictSlicePlan:object (fvt-id:string slice-count:integer)
        @doc "HEAVY. The inventory already PARTITIONED into <slice-count> disjoint slices, each as the \
            \ four parallel arrays CCp_EvictMultiRewards takes -- so a client loops rather than reshaping. \
            \ Mirrors AQP-VCT::URHC_BuildVacateSlicePlan, whose UI contract is written out in \
            \ README_VACATE_UI.md. \
            \ \
            \ SLICE SIZE IS THE CALLER'S, and it should come from SIMULATION rather than from a \
            \ constant: a triplet lane costs roughly 180,000 gas of ATS hops per leg while a plain \
            \ DPTF lane costs a fraction of that, so one number cannot serve both. FVT|C>SWEEP-DRAIN \
            \ records the same rule -- 'the UI sizes the real chunk by simulation, the node gas meter \
            \ is the real enforcement'."
        (let
            (
                (legs:[object] (URHC_BuildEvictPlans fvt-id))
            )
            (let
                (
                    (per:integer (UC_CeilDiv (length legs) (if (<= slice-count 0) 1 slice-count)))
                )
                {"leg-count" : (length legs)
                ,"per-slice" : per
                ,"slices"    :
                    (map
                        (lambda (s:integer)
                            (let
                                (
                                    (chunk:[object] (take per (drop (* s per) legs)))
                                )
                                {"beneficiaries"      : (map (lambda (l:object) (at "beneficiary" l)) chunk)
                                ,"score-entity-types" : (map (lambda (l:object) (at "score-entity-type" l)) chunk)
                                ,"score-entity-ids"   : (map (lambda (l:object) (at "score-entity-id" l)) chunk)
                                ,"reward-dptf-ids"    : (map (lambda (l:object) (at "reward-dptf-id" l)) chunk)}
                            )
                        )
                        (enumerate 0 (- (if (<= slice-count 0) 1 slice-count) 1))
                    )
                }
            )
        )
    )
    (defun URCi_EvictMultiRewards:decimal
        (patron:string fvt-id:string beneficiaries:[string] score-entity-types:[integer]
         score-entity-ids:[string] reward-dptf-ids:[string])
        @doc "IGNIS ifp of one eviction slice: the sum of what each leg's collect costs. \
            \ \
            \ IT REUSES AQP-RPSC::URCi_CollectFull, PER LEG, with the BENEFICIARY as collector -- \
            \ which is only correct because that reader gained a <collector> parameter on 2026-10-29. \
            \ Before that it read <patron> for both roles, so an eviction preview would have quoted \
            \ the OWNER's claimable, the owner's triplet lane split and the owner's forced-fix count \
            \ for every leg. Eviction is the first operation where the two accounts are never the \
            \ same, which is how that defect was found. \
            \ \
            \ RESIDUAL, stated because the collect preview states its own: URCi_CollectFull is exact \
            \ for un-streamed or already-settled lanes and can shift a transfer tier on a lane with a \
            \ live stream, since the payout is read pre-drip. An eviction slice inherits that per leg."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
            )
            (fold (+) 0.0
                (map
                    (lambda (i:integer)
                        (ref-RPSC::URCi_CollectFull patron (at i beneficiaries) fvt-id
                            (at i score-entity-types) (at i score-entity-ids) (at i reward-dptf-ids))
                    )
                    (enumerate 0 (- (length beneficiaries) 1))
                )
            )
        )
    )
    (defun URCi_EvictSingleReward:decimal
        (patron:string fvt-id:string beneficiary:string score-entity-type:integer
         score-entity-id:string reward-dptf-id:string)
        @doc "IGNIS ifp of ONE eviction leg -- the whole of what a single-leg transaction costs. \
            \ \
            \ IT IS AQP-RPSC::URCi_CollectFull WITH THE BENEFICIARY AS COLLECTOR -- the SAME reader \
            \ URCi_EvictMultiRewards folds over its legs, so N single-leg quotes sum to the MULTI \
            \ quote for the same N legs. The UI's choice between the two paths is therefore not a \
            \ choice between two numbers for one operation. \
            \ \
            \ NOT WRITTEN AS A DELEGATION, deliberately: having MULTI fold THIS function instead of \
            \ calling RPSC directly would read as the tidier version and would degrade the generated \
            \ price sheet, which walks `ref-MOD::` edges and loses a leg behind an intra-module hop. \
            \ That is measured, not feared -- C_Coil delegating to XB_Coil took the sheet from 93 \
            \ claimed-exact prices to 87 and was reverted for it. Duplication of ONE call, pinned by \
            \ the equality above, is the cheaper trade. \
            \ \
            \ RESIDUAL, inherited and stated: exact for un-streamed or already-settled lanes, and \
            \ able to shift a transfer tier on a lane with a live stream, because the payout is read \
            \ pre-drip."
        (let
            (
                (ref-RPSC:module{AcquisitionRewardCostsV1} AQP-RPSC)
            )
            (ref-RPSC::URCi_CollectFull patron beneficiary fvt-id
                score-entity-type score-entity-id reward-dptf-id)
        )
    )
    (defun URCi_FullEvictRewards:decimal (patron:string fvt-id:string)
        @doc "HEAVY. IGNIS ifp of a WHOLE-FVT eviction -- the scan, then URCi_EvictMultiRewards over every \
            \ leg it finds. The figure a client shows before pressing the one-transaction variant."
        (let
            (
                (legs:[object] (URHC_BuildEvictPlans fvt-id))
            )
            (URCi_EvictMultiRewards patron fvt-id
                (map (lambda (l:object) (at "beneficiary" l)) legs)
                (map (lambda (l:object) (at "score-entity-type" l)) legs)
                (map (lambda (l:object) (at "score-entity-id" l)) legs)
                (map (lambda (l:object) (at "reward-dptf-id" l)) legs))
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_EvictSliceShape
        (beneficiaries:[string] score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
        @doc "The four arrays are PARALLEL, so they must be the same length, and a slice must not be \
            \ empty. An unequal set would silently truncate at the shortest -- paying some legs and \
            \ dropping others with no error -- which is the failure a parallel-array interface has to \
            \ be defended against. An empty slice would bill a transaction that moves nothing, the \
            \ same defect the collect refusal closed."
        (let
            (
                (n:integer (length beneficiaries))
            )
            (enforce (> n 0) "Eviction slice is empty: there is nothing to evict")
            (enforce
                (fold (and) true
                    [(= n (length score-entity-types))
                     (= n (length score-entity-ids))
                     (= n (length reward-dptf-ids))])
                "Eviction slice arrays must be of equal length"
            )
        )
    )
    (defun CAP_EvctFvtOwner (fvt-id:string)
        @doc "Eviction requires tx-sender ownership of the FVT's canonical owner konto. The eviction IS \
            \ the owner's benevolence toward their stakers, and they pay the IGNIS for it, so the \
            \ owner is the only account that may trigger one. \
            \ \
            \ Mirrors AQP-VCT::CAP_VctVacatePoolOwner, which gates a pool unwind on the pool's owner \
            \ konto the same way."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-RPS:module{AcquisitionRewardPerShareV5} RPS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (ref-RPS::UR_FVT|OwnerKonto fvt-id))
        )
    )
    ;;{5.6}  Aux/X
    ;; [XI]
    ;;Protection: Class 3 — Custom: P|EVCT|RECIPE
    (defun XI_EvictLegs:object{IgnisCollectorV4.OutputCumulator}
        (patron:string evictor:string fvt-id:string legs:[object])
        @doc "The eviction CONSUMER: drip then pay, per leg, through AQP-FVT's eviction surface. \
            \ Empty legs -> empty cumulator, so a caller cannot bill for nothing. \
            \ \
            \ NO ENFORCE HERE -- an XI_ must not, and the claimable refusal already ran in the \
            \ entrypoint. NO CUSTODY either: every transfer and every coil happens inside \
            \ XE_EvictPay, under AQP-FVT's own remote-governor grant, which is why this module needs \
            \ no governor of its own. \
            \ \
            \ PER-LEG RE-READ IS LOAD-BEARING. XE_EvictPay recomputes the payout from live state for \
            \ every leg, so two legs on the SAME reward lane each see the available-rewards figure the \
            \ previous one left. Hoisting that read and subtracting a batch total would be wrong \
            \ exactly when a slice carries two beneficiaries of one lane -- which is the normal case."
        (require-capability (P|EVCT|RECIPE))
        (if (= (length legs) 0)
            (UC_EmptyOc)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    (map
                        (lambda (leg:object)
                            (let
                                (
                                    (set-type:integer (at "score-entity-type" leg))
                                    (set-id:string    (at "score-entity-id" leg))
                                    (lane:string      (at "reward-dptf-id" leg))
                                    (who:string       (at "beneficiary" leg))
                                )
                                (ref-FVT::XE_EvictDrip evictor fvt-id set-type set-id lane)
                                (ref-FVT::XE_EvictPay patron evictor who fvt-id set-type set-id lane)
                            )
                        )
                        legs
                    )
                    []
                )
            )
        )
    )
    (defun UC_EmptyOc:object{IgnisCollectorV4.OutputCumulator} ()
        @doc "The empty cumulator -- an operation that moved nothing and must bill nothing."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator 0.0 "" false [])
        )
    )
    ;;{5.7}  User [A/C]
    ;; [C]   client
    (defun CCp_EvictMultiRewards:object{IgnisCollectorV4.OutputCumulator}
        (patron:string evictor:string fvt-id:string beneficiaries:[string]
         score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
        @doc "ONE EVICTION SLICE -- a fed slice of a UI-sliced campaign. The client dirty-reads \
            \ URHC_BuildEvictPlans (or URHC_BuildEvictSlicePlan for ready-made arrays), splits into \
            \ disjoint gas-bounded slices and fires them in PARALLEL: legs are order-independent, and \
            \ block execution is serial, which is the same reasoning AQP-VCT records for its batches. \
            \ \
            \ THE CLAIMABLE REFUSAL IS HERE, not in the capability, and not in the XI_. It must run \
            \ on URC_LiveClaimable -- a projection INCLUDING stream time vested to now -- because a \
            \ streamed lane reads zero before its drip, and refusing on the pre-drip figure would \
            \ reject exactly the streamed evictions that are legitimate. An XI_ must not enforce and \
            \ a capability body is the wrong place for a fold over a caller-sized list, so it lands \
            \ in the CC_, which may. \
            \ \
            \ A STALE SLICE REFUSES RATHER THAN SKIPS. Owner, 2026-10-29: '0 reward simply means \
            \ there is nothing to collect'. If a leg has been collected between the read and the send, \
            \ the whole slice aborts and the client re-reads -- which is recoverable and auditable, \
            \ where a silent skip is neither."
        (P|UEV_IMC)
        (with-capability
            (EVCT|C>EVICT-MULTI evictor fvt-id beneficiaries score-entity-types score-entity-ids reward-dptf-ids)
            (let
                (
                    (legs:[object]
                        (UC_EvictLegsFromParallelArrays beneficiaries score-entity-types score-entity-ids reward-dptf-ids))
                )
                (enforce
                    (fold (and) true
                        (map
                            (lambda (leg:object)
                                (> (RPS.URC_LiveClaimable (at "beneficiary" leg) fvt-id
                                        (AQP-FVT.URC_CollectPoolId (at "score-entity-type" leg) (at "score-entity-id" leg))
                                        (at "score-entity-type" leg) (at "score-entity-id" leg) (at "reward-dptf-id" leg))
                                    0.0)
                            )
                            legs
                        )
                    )
                    "Nothing to evict on at least one leg of this slice: re-read the plan and re-slice"
                )
                (XI_EvictLegs patron evictor fvt-id legs)
            )
        )
    )
    (defun CC_EvictSingleReward:object{IgnisCollectorV4.OutputCumulator}
        (patron:string evictor:string fvt-id:string beneficiary:string
         score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "ONE LEG, ONE TRANSACTION. The third and smallest of the three eviction shapes, and the \
            \ one a large FVT is actually evicted with. \
            \ \
            \ THE UI FIRES AS MANY OF THESE AS THERE ARE LEGS, which is the whole point (owner, \
            \ 2026-10-30): 'you can see instantly if there are 120 tx constructed there are 120 \
            \ legs.' URHC_BuildEvictPlans returns exactly one object per leg, so the transaction \
            \ count IS the leg count -- no packing loop, no probe-and-resize, and no arithmetic \
            \ between what was read and what was sent. \
            \ \
            \ AND NO SINGLE TRANSACTION CAN APPROACH THE GAS CEILING, which is the structural \
            \ argument for preferring it: one leg is one drip plus one pay, so the campaign is safe \
            \ BY CONSTRUCTION rather than by measurement. The MULTI path has to be measured against \
            \ 2,000,000 and re-measured whenever the data moves. \
            \ \
            \ WHAT IS ORDER-DEPENDENT, stated because the UI cannot see it from the plan: the DUST. \
            \ The last claimant on a lane sweeps whatever remains, so whichever of the N transactions \
            \ lands last on a given lane receives it. The total is unaffected and the lane still ends \
            \ at zero -- and this is the owner's own ruling, 2026-10-29: dust goes to the royalty \
            \ sink if the pair has one, 'if not, to the last beneficiary'. \
            \ \
            \ A REFUSED LEG IS NOT A LOST LEG. The claimable enforce below means a leg collected \
            \ between the read and the send refuses; nothing moves, and a re-read returns only what \
            \ is left. Firing N at once must expect some to bounce -- that is the safety property, \
            \ not a failure of the campaign."
        (P|UEV_IMC)
        (with-capability (EVCT|C>EVICT-SINGLE evictor fvt-id)
            (let
                (
                    ;;THE SAME PROJECTION THE MULTI PATH REFUSES ON, and it must be: a streamed lane
                    ;;reads zero before its drip, so refusing on the pre-drip figure would reject
                    ;;exactly the streamed evictions that are legitimate.
                    (claimable:decimal
                        (RPS.URC_LiveClaimable beneficiary fvt-id
                            (AQP-FVT.URC_CollectPoolId score-entity-type score-entity-id)
                            score-entity-type score-entity-id reward-dptf-id))
                )
                (enforce (> claimable 0.0)
                    "Nothing to evict on this leg: it has already been collected, or never accrued")
                ;;ONE LEG THROUGH THE SAME CONSUMER the other two use. XI_EvictLegs already handles
                ;;a one-element list, and its per-leg re-read is what makes a single-leg fan-out
                ;;correct -- every leg recomputes its payout from live state, so N transactions on
                ;;one lane each see what the previous one left.
                (XI_EvictLegs patron evictor fvt-id
                    [ { "beneficiary"       : beneficiary
                      , "score-entity-type" : score-entity-type
                      , "score-entity-id"   : score-entity-id
                      , "reward-dptf-id"    : reward-dptf-id } ])
            )
        )
    )
    (defun CC_FullEvictRewards:object{IgnisCollectorV4.OutputCumulator}
        (patron:string evictor:string fvt-id:string)
        @doc "WHOLE-FVT eviction in ONE transaction, scanning its own legs. The convenience path for a \
            \ small FVT; a large one must use CCp_EvictMultiRewards, because the node gas meter is the real \
            \ ceiling and this scans before it pays. Mirrors AQP-VCT::CC_FullVacate, which stands in \
            \ the same relation to its CCp_Batch* siblings. \
            \ \
            \ NO CLAIMABLE ENFORCE, and the asymmetry with CCp_EvictMultiRewards is deliberate: the legs \
            \ here come from URHC_BuildEvictPlans in the SAME transaction, which filters on a positive \
            \ claimable, so there is no window for a leg to go stale. The sliced path cannot say that \
            \ -- its arrays were read in an earlier transaction."
        (P|UEV_IMC)
        (with-capability (EVCT|C>FULL-EVICT evictor fvt-id)
            (XI_EvictLegs patron evictor fvt-id (URHC_BuildEvictPlans fvt-id))
        )
    )
)

;; --- tables for 08b_EVCT.pact (2 defined) ---
;; NEW MODULE this round -- not live on chain, so its tables do
;; not exist yet and these create-table calls are ACTIVE.
(create-table P|T)
(create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact ================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageTwo_ClientThreeV6
    @doc "Exposes Stage Two Third Batch of Client Functions: \
        \ the AcquisitionPools Client Functions"

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
    (defun URCi_IssueGenericEarningVault:object{IgnisCollectorV4.OutputCumulator}
        (owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [VCT] -- per-leg vacate. ONE transaction each, standalone, for a pool owner who wants to
    ;;  clear a single asset leg rather than the whole pool (CC_FullVacate does that).
    ;;
    ;;  RENAMED FROM `XB_` 2026-10-03, and the prefix was not a cosmetic error. `XB_` means
    ;;  "protected, used inside this module AND by a forward module" -- neither is true here:
    ;;  NOTHING in TS02-C3 calls these (measured: zero in-module callers) and no other module
    ;;  reaches them. They are ordinary Talos client entrypoints -- (patron, executor), P|TS,
    ;;  one core call, IGNIS on the patron, a format string -- identical in shape to every `C_`
    ;;  below, and they were simply named after their CALLEE (`AQP-VCT::XB_Vacate*`) instead of
    ;;  after their own band.
    ;;
    ;;  The consequence was not cosmetic either. `_registry.py`'s entrypoint filter is
    ;;  `^[A-Za-z0-9|_-]*\|C{1,2}p?_[A-Za-z0-9]+$`, which an `XB_` name cannot match -- so four
    ;;  live client operations were ABSENT from OURONET-REGISTRY.json and therefore unreachable
    ;;  from OuronetUI, unpriced in the IGNIS sheet, and invisible to every gate built on it.
    ;;  They were also the ONLY `X*`-named definitions in all eleven Talos modules.
    ;;
    (defun AQP-POOL|CC_VacateTrueFungible:string (patron:string executor:string pool-id:string))
    (defun AQP-POOL|CC_VacateOrtoFungible:string (patron:string executor:string pool-id:string dpof-id:string))
    (defun AQP-POOL|CC_VacateSemiFungible:string (patron:string executor:string pool-id:string dpsf-id:string))
    (defun AQP-POOL|CC_VacateNonFungible:string (patron:string executor:string pool-id:string dpnf-id:string))
    ;;
    ;;  [ANK]
    ;;
    (defun AQP-ANK|C_RevokeBoostClass:string (patron:string executor:string boost-class-id:string))
    (defun AQP-ANK|C_IssueTrueFungibleAnchor:string
        (patron:string executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
    )
    (defun AQP-ANK|C_IssueSemiFungibleAnchor:string
        (patron:string executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
    )
    (defun AQP-ANK|C_IssueNonFungibleAnchor:string
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
    )
    (defun AQP-ANK|C_IssueNonFungibleSetAnchor:string
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
    )
    (defun AQP-ANK|C_RevokeAnchor:string (patron:string executor:string anchor-id:string))
    ;;
    ;;  [AQP-SCORE]
    ;;
    (defun AQP-SCR|C_IssueLiquidityScore:string
        (patron:string executor:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
    )
    (defun AQP-SCR|C_IssueTrueFungibleScore:string
        (patron:string executor:string score-name:string precision:integer mx-frozen:decimal)
    )
    (defun AQP-SCR|C_IssueOrtoFungibleScore:string
        (patron:string executor:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
    )
    (defun AQP-SCR|C_IssueSemiFungibleScore:string
        (patron:string executor:string score-name:string precision:integer sft-equality:bool)
    )
    (defun AQP-SCR|C_IssueNonFungibleScore:string
        (patron:string executor:string score-name:string precision:integer nft-score-model:integer)
    )
    (defun AQP-SCR|C_RotateScoreOwnership:string (patron:string executor:string executee:string score-id:string))
    (defun AQP-SCR|C_ControlScore:string (patron:string executor:string score-id:string new-can-upgrade:bool new-can-change-owner:bool))
    (defun AQP-SCR|C_CreateScoreBoostClassLink:string (patron:string executor:string score-id:string boost-class-id:string))
    (defun AQP-SCR|C_CreateScoreBoostLink:string (patron:string executor:string score-id:string boost-score-id:string))
    (defun AQP-SCR|C_EnableDebBoost:string (patron:string executor:string score-id:string))
    (defun AQP-SCR|C_LockScoreDrift:string (patron:string executor:string score-id:string))
    (defun AQP-FVT|CC_LatchStreamEligible:string (patron:string executor:string fvt-id:string))
    (defun AQP-SCR|C_IssueTriplet:string
        (patron:string executor:string bronze-score-id:string silver-score-id:string golden-score-id:string)
    )
    (defun AQP-SCR|C_IssueSingleScoreModel:string
        (patron:string executor:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal] boost-class-id:string)
    )
    (defun AQP-SCR|C_CombineTripletScoreModel:string
        (patron:string executor:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
    )
    (defun AQP-SCR|C_IssueScoreFromModel:string (patron:string executor:string model-id:string agency-name:string))
    (defun AQP-SCR|C_IssueSemiFungibleScoreDefinition:string
        (patron:string executor:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
    )
    (defun AQP-SCR|C_IssueNonFungibleScoreDefinition:string
        (patron:string executor:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
    )
    (defun AQP-SCR|C_IssueNonFungibleSetScoreDefinition:string
        (patron:string executor:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
    )
    ;;
    ;;  [AQP-POOL]
    ;;
    (defun AQP-POOL|C_Issue:string
        (patron:string executor:string pool-name:string asset-id:string aqp-class:integer)
    )
    (defun AQP-POOL|C_AddScore:string
        (patron:string executor:string pool-id:string score-id:string)
    )
    (defun AQP-POOL|C_RevokeScore:string
        (patron:string executor:string pool-id:string score-id:string)
    )
    (defun AQP-POOL|C_DisablePoolStake:string
        (patron:string executor:string pool-id:string)
    )
    (defun AQP-POOL|C_EnablePoolStake:string
        (patron:string executor:string pool-id:string)
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
    )
    ;;
    (defun AQP-POOL|CC_StakeTrueFungible:string
        (patron:string executor:string executee:string pool-id:string dptf-id:string amount:decimal)
    )
    (defun AQP-POOL|CC_UnstakeTrueFungible:string
        (patron:string executor:string executee:string pool-id:string dptf-id:string amount:decimal)
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
    )
    (defun AQP-POOL|C_SyncTrueFungibleAnchors:string
        (patron:string executee:string dptf-id:string)
    )
    (defun AQP-POOL|C_SyncSemiFungibleAnchors:string
        (patron:string executee:string dpsf-id:string)
    )
    (defun AQP-POOL|C_SyncNonFungibleAnchors:string
        (patron:string executee:string dpnf-id:string)
    )
    (defun AQP-POOL|C_AbortVacate:string
        (patron:string executor:string pool-id:string)
    )
    (defun AQP-POOL|C_FinalizeVacate:string (patron:string executor:string pool-id:string))
    (defun AQP-POOL|CC_FullVacate:string (patron:string executor:string pool-id:string))
    (defun AQP-POOL|CCp_BatchVacateTrueFungible:string
        (patron:string pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun AQP-POOL|CCp_BatchVacateOrtoFungible:string
        (patron:string pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]]))
    (defun AQP-POOL|CCp_BatchVacateCollectables:string
        (patron:string pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    (defun AQP-POOL|CCp_BatchDrainTrueFungible:string
        (patron:string pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun AQP-POOL|CCp_BatchDrainOrtoFungible:string
        (patron:string pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]]))
    (defun AQP-POOL|CCp_BatchDrainCollectable:string
        (patron:string pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    ;;
    ;;  [AQP-FVT]
    ;;
    (defun AQP-FVT|C_Issue:string
        (patron:string executor:string fvt-name:string fvt-class:integer common-denominator:string)
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
    )
    (defun AQP-FVT|C_AddScoreEntity:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string)
    )
    (defun AQP-FVT|C_AddRewardLink:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
    )
    (defun AQP-FVT|C_ToggleScoreEntityLink:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
    )
    (defun AQP-FVT|C_ToggleRewardLink:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string enabled:bool)
    )
    (defun AQP-FVT|C_SetMinInjectAmount:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string min-inject-amount:decimal)
    )
    (defun AQP-FVT|C_SetQualitySplit:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
    )
    (defun AQP-FVT|C_Control:string
        (patron:string executor:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
    )
    (defun AQP-FVT|C_RotateOwnership:string
        (patron:string executor:string executee:string fvt-id:string)
    )
    (defun AQP-FVT|C_SetCommonDenominator:string
        (patron:string executor:string fvt-id:string common-denominator:string)
    )
    (defun AQP-FVT|C_SetMosaic:string
        (patron:string executor:string fvt-id:string mosaic:bool)
    )
    (defun AQP-FVT|C_SetSplitMode:string
        (patron:string executor:string fvt-id:string split-mode:string)
    )
    (defun AQP-FVT|C_IssueGenericEarningVault:string
        (patron:string executor:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
    )
    (defun AQP-FVT|CC_InjectStream:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
    )
    (defun AQP-FVT|CC_Inject:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun AQP-FVT|CCp_InjectFixChunk:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
    )
    (defun AQP-FVT|CC_InjectFinalize:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun AQP-FVT|CCp_UnstaleAll:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
    )
    (defun MTX-AQP|2|CC_Inject:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun MTX-AQP|2|CC_SweepRevokeAnchor:string
        (patron:string executor:string anchor-id:string)
    )
    (defun AQP-FVT|CC_SweepRevokeAnchor:string
        (patron:string executor:string anchor-id:string)
    )
    (defun AQP-FVT|CC_SweepBegin:string
        (patron:string executor:string anchor-id:string)
    )
    (defun AQP-FVT|CCp_SweepRecomputeChunk:string
        (patron:string anchor-id:string chunk:integer)
    )
    (defun AQP-FVT|CC_UnstaleMyScores:string
        (patron:string executor:string fvt-ids:[string])
    )
    (defun AQP-FVT|CC_Collect:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    )
    ;;
    ;;  [AQP-EVCT]
    ;;
    ;;REWARD EVICTION, 2026-10-29. FOUR wrappers over TWO core functions, and the pairing is the
    ;;shape the owner asked for: "we could create 2 variants for this AA_/AAp that uses the gasless
    ;;patron, signaling its an Admin call, or CC_/CCp_ signaling its not an admin call for which
    ;;ignis has to be paid, and we can use the same name in the Talos orchestrator for it."
    ;;
    ;;ONE CORE PER SHAPE; ONLY THE PATRON AND THE GATE DIFFER. The AA_/AAp_ pair supplies
    ;;GOV|DALOS|SC_NAME -- the single account IGNIS::XE_CollectIgnis exempts via
    ;;`iz-gassles-patron` -- so the collection PATH still runs and the cumulator is still
    ;;consumed; it simply is not charged. The A-variant therefore cannot drift from the
    ;;C-variant's pricing, because it is the same call with a different account in slot 0.
    ;;
    ;;THE A-VARIANTS ARE ADMIN-GATED, AND THAT IS NOT DECORATION. AQP-EVCT's own gate is FVT
    ;;OWNERSHIP, not administration -- so a gasless wrapper carrying only P|TS would hand every
    ;;FVT owner in the system an unmetered IGNIS path, which is precisely the door narrowed to one
    ;;account on 2026-09-15 after RedTeam/[RT-I]_GasStation.repl. They gate on
    ;;P|ADMINISTRATIVE-SUMMONER instead (TS01-A's pattern, added to this module for them): the
    ;;admin keyset says the call MAY happen, <executor> says who made it happen, and AQP-EVCT still
    ;;requires that executor to own the FVT.
    ;;
    ;;TWO WRAPPERS RATHER THAN ONE WITH A BOOL: IG|COMPONENTS and the price sheet are keyed by
    ;;wrapper name, so a single entrypoint whose price is sometimes 0 and sometimes N has no honest
    ;;row.
    (defun AQP-EVCT|CCp_EvictMultiRewards:string
        (patron:string executor:string fvt-id:string beneficiaries:[string]
         score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
    )
    (defun AQP-EVCT|AAp_EvictMultiRewards:string
        (executor:string fvt-id:string beneficiaries:[string]
         score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
    )
    (defun AQP-EVCT|CC_EvictSingleReward:string
        (patron:string executor:string fvt-id:string beneficiary:string
         score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    )
    (defun AQP-EVCT|AA_EvictSingleReward:string
        (executor:string fvt-id:string beneficiary:string
         score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    )
    (defun AQP-EVCT|CC_FullEvictRewards:string
        (patron:string executor:string fvt-id:string)
    )
    (defun AQP-EVCT|AA_FullEvictRewards:string
        (executor:string fvt-id:string)
    )
    (defun AQP-DSA|C_DefineDelegationVault:string
        (patron:string executor:string fvt-id:string model-id:string unit-score:integer)
    )
    (defun AQP-DSA|CC_OpenAgency:string
        (patron:string executor:string fvt-id:string pool-id:string score-entity-id:string fee-per-mille:integer
         collectable-id:string stake-nonces:[integer])
    )
    (defun AQP-DSA|C_RecomputeCapture:string
        (patron:string fvt-id:string score-entity-id:string)
    )
    (defun AQP-DSA|C_SetOracleAuth:string
        (patron:string executor:string fvt-id:string oracle-guard:guard)
    )
    (defun AQP-DSA|C_OracleWrite:string
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
    )
    (defun AQP-DSA|C_WithdrawRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
    )
    (defun AQP-DSA|C_BurnRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
    )
    (defun AQP-DSA|C_FuelRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string swpair:string)
    )
    (defun AQP-DSA|C_SetAgencyFee:string
        (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
    )
    (defun AQP-DSA|A_ToggleExternalOracle:string (patron:string executor:string on:bool))
    (defun AQP-DSA|A_SetOracleValidity:string (patron:string executor:string seconds:integer))


    ;;<=========================================================================>
    ;; ADDED 2026-10-12 -- interface-membership sweep (StoicSyntax-Prefixes.md Sec5,
    ;; owner ruling). Every one of these was already live in the module body; this
    ;; closes the gap between what the module DOES and what its interface SAYS it does.
    ;;<=========================================================================>
    (defun AQP-FVT|CC_ClearPoolSweep:string (patron:string pool-id:string))
    (defun AQP-FVT|CCp_FvtFixSlice:string (patron:string fvt-id:string reward-dptf-id:string users:[string]))
    (defun AQP-POOL|CC_FinalizeScoreRevoke:string (patron:string executor:string pool-id:string score-id:string))
    (defun AQP-POOL|CC_ReassignCollectableStakeBeneficiary:string (
            patron:string
            owner:string
            pool-id:string
            collectable-id:string
            son:bool
            nonce:integer
            current-beneficiary:string
            new-beneficiary:string
        ))
    (defun AQP-POOL|CC_ReassignOrtoStakeBeneficiary:string (
            patron:string
            owner:string
            pool-id:string
            dpof-id:string
            nonce:integer
            current-beneficiary:string
            new-beneficiary:string
        ))
    (defun AQP-POOL|CC_ReassignTrueFungibleStakeBeneficiary:string (
            patron:string
            owner:string
            pool-id:string
            dptf-id:string
            amount:decimal
            current-beneficiary:string
            new-beneficiary:string
        ))
    (defun AQP-POOL|CC_UpdateScoreMultipliers:string (patron:string executor:string score-id:string
         mx-frozen:decimal mx-sleeping:decimal mx-hibernated:decimal))
    (defun AQP-POOL|CCp_BackfillScoreSlice:string (patron:string pool-id:string score-id:string beneficiaries:[string]))
    (defun AQP-POOL|CCp_ReleaseSpecialCustodial:string (patron:string pool-id:string executee:string dpof-id:string nonce:integer))
    (defun AQP-POOL|CCp_StakeSpecialCustodial:string (
            patron:string
            executor:string
            executee:string
            pool-id:string
            dpof-id:string
            nonces:[integer]
        ))
    (defun AQP-POOL|C_BeginScoreRevoke:string (patron:string executor:string pool-id:string score-id:string))
    (defun AQP-POOL|Cp_DrainScoreSlice:string (patron:string pool-id:string score-id:string accounts:[string]))
    (defun UC_FormatStakeCollectableResult:string (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce-count:integer
        ))
    (defun UC_FormatStakeOrtoFungibleResult:string (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonce-count:integer))
    (defun UC_FormatStakeTrueFungibleResult:string (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal))
    (defun UC_FormatUnstakeCollectableResult:string (pool-id:string owner-id:string collectable-id:string son:bool nonce-count:integer))
    (defun UC_FormatUnstakeOrtoFungibleResult:string (pool-id:string owner-id:string dpof-id:string nonce-count:integer))
    (defun UC_FormatUnstakeTrueFungibleResult:string (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal))
    (defun UC_FormatVacateCollectableResult:string (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce-count:integer
        ))
    (defun UC_ShortAccount:string (account:string))
)
;;
(module TS02-C3 GOV
    @doc "TALOS Stage 2 Client Functiones Part 3 - Acquisition Pools Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_ClientThreeV6)

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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
    (defcap P|ADMINISTRATIVE-SUMMONER ()
        @doc "ADMIN-GATED Talos summoner — P|TS plus this module's deploy keyset. Added 2026-10-29 for \
            \ the gasless reward-eviction pair (AQP-EVCT|AAp_EvictMultiRewards, AQP-EVCT|AA_FullEvictRewards), \
            \ copying TS01-A's capability of the same name. \
            \ \
            \ WHY A SEPARATE GATE EXISTS AT ALL: every other admin path in Talos reaches an `A_` core \
            \ that enforces its own GOV keyset, so P|TS is sufficient there. Reward eviction does not \
            \ -- AQP-EVCT gates on FVT OWNERSHIP -- so without this, a wrapper that supplies the \
            \ gasless patron would be an unmetered IGNIS path open to every FVT owner. \
            \ \
            \ It names no account: <executor> is the actor and AQP-EVCT still checks that it owns the \
            \ FVT. Composition order is authorisation-then-validation by way of P|TS, which carries \
            \ the GAP check."
        (compose-capability (P|TS))
        (compose-capability (GOV|TS02-C3_ADMIN))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-P|EVCT:module{OuronetPolicyV2} AQP-EVCT)
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
            ;; Reward-eviction wrappers below — register the Talos summoner as an allowed IMC caller
            ;; of AQP-EVCT. Both of its client entrypoints open with P|UEV_IMC, so without this row
            ;; every AQP-EVCT|* wrapper dies with "None of the guards passed".
            (ref-P|EVCT::P|A_AddIMP mg)
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
    ;;
    ;;  ONE EVENT PER CORE FUNCTION CALLED -- owner ruling, 2026-10-14.
    ;;
    ;;  A Talos shell that merely FORWARDS to a core function must not carry `@event`: the core
    ;;  module's own capability already emits one, and two capabilities firing for a single
    ;;  operation puts two near-identical events on one transaction, which is what the explorer
    ;;  showed for `CC_ReassignTrueFungibleStakeBeneficiary` (`FVT|C>REASSIGN-TRUE-FUNGIBLE-
    ;;  BENEFICIARY` from AQP-FVT *and* `AQP|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY` from here).
    ;;  `P|TS` alone is enough for the gas/IMC scope these shells exist to provide.
    ;;
    ;;  THE EXCEPTION, and the only one: where the core function being called carries NO evented
    ;;  capability of its own, the Talos cap is the single event and stays. That is why the nine
    ;;  stake/unstake caps below KEEP `@event` -- `FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`,
    ;;  `FVT|C>ORTO-FUNGIBLE-STAKE-FLOW` and `FVT|C>COLLECTABLE-STAKE-FLOW` are not evented, and
    ;;  one shared `direction:bool` recipe cap could not tell a stake from an unstake anyway.
    ;;  Stripping those would leave the entire AQP stake surface with no event at all.
    ;;
    ;;  Orchestration is NOT an exception: a shell that drives several evented core functions
    ;;  legitimately shows several events -- one per real operation -- and still adds none here.
    ;;
    ;;  Measured before the change: 23 of this module's 28 defcaps were evented, against ZERO in
    ;;  every other Talos module in the tree (all six Stage-1 Talos, TS02-C1, TS02-C2, TS02-DPAD).
    ;;  14 stripped here; 9 kept under the exception above.
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
    (defcap AQP|C>STAKE-SPECIAL-CUSTODIAL
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string
         nonces:[integer] nonce-amounts:[decimal])
        @doc "AQP client event: stake SLEEPING batches under pool custody. Composes P|TS only. \
            \ Distinct from `AQP|C>STAKE-ORTO-FUNGIBLE` so the explorer can tell a custodial stake \
            \ from an ordinary one -- they differ in who the tracker names as owner, which is \
            \ exactly the fact an observer needs and cannot otherwise see."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>RELEASE-SPECIAL-CUSTODIAL
        (patron:string pool-id:string beneficiary-id:string dpof-id:string nonce:integer)
        @doc "AQP client gate: release a MATURED custodial sleeping position. Composes P|TS only; \
            \ maturity is enforced by VST and custody by AQP-FVT. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-FVT::FVT|C>RELEASE-SPECIAL-CUSTODIAL,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
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
    (defcap AQP|C>UPDATE-SCORE-MULTIPLIERS
        (patron:string executor:string score-id:string
         mx-frozen:decimal mx-sleeping:decimal mx-hibernated:decimal)
        @doc "AQP client gate: re-set a score's frozen/sleeping multipliers. Composes P|TS only. \
            \ THE TALOS MIRROR CARRIES NO VALIDATION, deliberately and like its siblings: acquiring \
            \ it is what puts a registered inter-module guard in scope so the core client's \
            \ `P|UEV_IMC` passes. The real conditions — the emptiness gate in AQP-POOL, and \
            \ ownership plus the ordering invariant in AQP-SCORE — are enforced by the modules that \
            \ can actually see what they are checking. Duplicating them here would be a second \
            \ copy free to drift. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>UPDATE-SCORE-MULTIPLIERS,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>BEGIN-SCORE-REVOKE
        (patron:string executor:string pool-id:string score-id:string slot-index:integer)
        @doc "AQP client gate: phase 1 of a score revoke — vacate the slot, freeze the pool. \
            \ Composes P|TS only; the conditions live in AQP-POOL, which can see the slots. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>BEGIN-SCORE-REVOKE,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>DRAIN-SCORE-SLICE
        (patron:string pool-id:string score-id:string accounts:[string])
        @doc "AQP client gate: phase 2 — one fed slice of a score drain. Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>DRAIN-SCORE-SLICE,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>FINALIZE-SCORE-REVOKE
        (patron:string executor:string pool-id:string score-id:string)
        @doc "AQP client gate: phase 3 — cut the aqpool-link once the drain is complete. \
            \ Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>FINALIZE-SCORE-REVOKE,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>REASSIGN-ORTO-BENEFICIARY
        (patron:string owner:string pool-id:string dpof-id:string nonce:integer
         current-beneficiary:string new-beneficiary:string)
        @doc "AQP client gate: redirect who earns from an already-staked orto position, custody \
            \ or not. Composes P|TS only -- the conditions live in AQP-FVT, which can see the \
            \ tracker row. Renamed from AQP|C>REASSIGN-CUSTODIAL-BENEFICIARY, 2026-10-11: custody \
            \ is retired, so this now covers every staked sleeping position, not only one locked \
            \ under the pool's name. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-FVT::FVT|C>REASSIGN-ORTO-BENEFICIARY,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>REASSIGN-COLLECTABLE-BENEFICIARY
        (patron:string owner:string pool-id:string collectable-id:string son:bool nonce:integer
         current-beneficiary:string new-beneficiary:string)
        @doc "AQP client gate: the NFT/SFT counterpart of AQP|C>REASSIGN-ORTO-BENEFICIARY. \
            \ Composes P|TS only -- the conditions live in AQP-FVT. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-FVT::FVT|C>REASSIGN-COLLECTABLE-BENEFICIARY,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY
        (patron:string owner:string pool-id:string dptf-id:string amount:decimal
         current-beneficiary:string new-beneficiary:string)
        @doc "AQP client gate: the TF counterpart of AQP|C>REASSIGN-ORTO-BENEFICIARY -- redirect \
            \ who earns from an already-staked true-fungible position, native or frozen, in whole \
            \ or in part. Composes P|TS only -- the conditions live in AQP-FVT, which can see the \
            \ tracker row. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-FVT::FVT|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap FVT|C>CLEAR-POOL-SWEEP
        (patron:string pool-id:string)
        @doc "AQP-FVT client gate: release a pool's sweep freeze. Composes P|TS only. \
            \ Mirrors AQP-FVT's cap, not AQP-POOL's: the release lives in AQP-FVT because the \
            \ freeze has two owners and only that module can see both. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-FVT::FVT|C>CLEAR-POOL-SWEEP,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>BACKFILL-SCORE-SLICE
        (patron:string pool-id:string score-id:string beneficiaries:[string])
        @doc "AQP client gate: one fed slice of the score re-rate sweep. Composes P|TS only. \
            \ No validation here, as for every mirror beside it — acquiring this is what puts a \
            \ registered inter-module guard in scope so the core client's `P|UEV_IMC` passes, and \
            \ the real conditions live in AQP-POOL, the only module that can see the tracker. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>BACKFILL-SCORE-SLICE,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-TF-ANCHORS
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "AQP client gate: pool-agnostic TF anchor repair. Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>SYNC-TF-ANCHORS,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-SEMI-FUNGIBLE-ANCHORS
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "AQP client gate: pool-agnostic DPSF anchor repair. Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>SYNC-COLLECTABLE-ANCHORS,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-NON-FUNGIBLE-ANCHORS
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "AQP client gate: pool-agnostic DPNF anchor repair. Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>SYNC-COLLECTABLE-ANCHORS,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>ABORT-VACATE
        (patron:string pool-id:string)
        @doc "AQP client gate: clear vacate-in-progress (stake stays disabled). Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-VCT::VCT|C>ABORT-VACATE-POOL,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
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
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
    (defun URCi_IssueGenericEarningVault:object{IgnisCollectorV4.OutputCumulator}
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
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-DSA:module{DsaV3} AQP-DSA)
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
                    (ref-DSA:module{DsaV3} AQP-DSA)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_EnableDebBoost patron executor score-id))
                (format "Successfully enabled DEB boost for score {}." [score-id])
            )
        )
    )
    (defun AQP-SCR|C_LockScoreDrift:string (patron:string executor:string score-id:string)
        @doc "Permanently marks a score drift-proof — irreversible. Refused unless the score is \
            \ already provably drift-free (deb-boost off, no boost-class link), and from then on \
            \ the score accepts neither. This is the per-score half of what a streaming FVT \
            \ requires; the FVT half is AQP-FVT|CC_LatchStreamEligible."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_LockScoreDrift patron executor score-id))
                (format "Score {} is now permanently drift-locked." [score-id])
            )
        )
    )
    (defun AQP-FVT|CC_LatchStreamEligible:string (patron:string executor:string fvt-id:string)
        @doc "Permanently latches an FVT as eligible for TIME-STREAMED injects — irreversible, and \
            \ HEAVY: it scans every enabled member and requires each to be drift-locked. Afterwards \
            \ the FVT admits and re-enables only drift-locked members. CC_InjectStream refuses \
            \ until this has been done."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-FVT::CC_LatchStreamEligible patron executor fvt-id))
                (format "FVT {} is now stream-eligible; its membership is permanently drift-locked." [fvt-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueTriplet:string
        (patron:string executor:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Issues SCR triplet bundle T|bronze|silver|golden and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_TrueFungibleStakeFlow patron executor executee pool-id dptf-id amount false)
                )
                (UC_FormatUnstakeTrueFungibleResult pool-id executor executee dptf-id amount)
            )
        )
    )
    (defun AQP-POOL|CCp_StakeSpecialCustodial:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            dpof-id:string
            nonces:[integer]
        )
        @doc "Stake whole SLEEPING (Z|) nonces into a pool UNDER CUSTODY: the batches leave \
            \ <executor>, but the tracker records the pool as their owner, so they cannot be \
            \ withdrawn until the lock matures. Scores, rewards and claims still accrue to \
            \ <executee> exactly as on an ordinary stake. \
            \ \
            \ Release with `AQP-POOL|CCp_ReleaseSpecialCustodial`, which is PERMISSIONLESS once \
            \ the lock matures and can only pay the beneficiary -- so the time-lock is on the \
            \ asset, not on the staker's ability to get it back. Talos shell → \
            \ AQP-FVT::CCp_StakeSpecialCustodial."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability
                (AQP|C>STAKE-SPECIAL-CUSTODIAL patron pool-id executor executee dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CCp_StakeSpecialCustodial
                            patron executor executee pool-id dpof-id nonces nonce-amounts
                        )
                    )
                    (format "Staked {} sleeping nonce(s) of {} into pool {} under POOL CUSTODY for {}. Releasable only at maturity."
                        [nonce-count dpof-id pool-id (UC_ShortAccount executee)]
                    )
                )
            )
        )
    )
    (defun AQP-POOL|CCp_ReleaseSpecialCustodial:string
        (patron:string pool-id:string executee:string dpof-id:string nonce:integer)
        @doc "Release a MATURED custodial sleeping position: unwind the score and tracker, dissolve \
            \ the batch, and send the native counterpart to <executee>. Talos shell → \
            \ AQP-FVT::CCp_ReleaseSpecialCustodial. \
            \ \
            \ PERMISSIONLESS BY DESIGN, and that is what makes custody safe to accept: the staker \
            \ cannot trigger this themselves (the pool owns the tracker row), so if it needed the \
            \ pool owner's signature an absent owner could hold a matured position forever. Anyone \
            \ may call it and nobody can profit from doing so -- the native tokens go to the \
            \ beneficiary recorded in the tracker, never to the caller. \
            \ \
            \ Refused before maturity by `VST|XE>UNSLEEP`, the same gate a user's own unsleep must \
            \ pass."
        (with-capability
            (AQP|C>RELEASE-SPECIAL-CUSTODIAL patron pool-id executee dpof-id nonce)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CCp_ReleaseSpecialCustodial patron pool-id executee dpof-id nonce)
                )
                (format "Released sleeping nonce {} of {} from pool {}: batch dissolved, native sent to {}."
                    [nonce dpof-id pool-id (UC_ShortAccount executee)]
                )
            )
        )
    )
    (defun AQP-POOL|CC_ReassignOrtoStakeBeneficiary:string
        (
            patron:string
            owner:string
            pool-id:string
            dpof-id:string
            nonce:integer
            current-beneficiary:string
            new-beneficiary:string
        )
        @doc "Redirect who earns from an already-staked orto position -- including a sleeping \
            \ batch still inside its maturity lock -- without unstaking and restaking it. \
            \ RENAMED from AQP-POOL|CCp_ReassignCustodialBeneficiary, 2026-10-11: custody is \
            \ retired, <owner> stays the tracker owner throughout, and this works for any staked \
            \ sleeping position, not only one locked under the pool's name. \
            \ \
            \ NO ASSET EVER MOVES HERE OR AT RELEASE -- the ordinary unstake always returns the \
            \ position to <owner>, regardless of who the beneficiary was, so this is pure \
            \ earnings bookkeeping and the token's transfer rules have nothing to say about it. \
            \ \
            \ Requires the OWNER's signature -- they are the one entitled to decide who earns. \
            \ Talos shell → AQP-FVT::CC_ReassignOrtoStakeBeneficiary."
        (with-capability
            (AQP|C>REASSIGN-ORTO-BENEFICIARY
                patron owner pool-id dpof-id nonce current-beneficiary new-beneficiary)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_ReassignOrtoStakeBeneficiary
                        patron owner pool-id dpof-id nonce current-beneficiary new-beneficiary
                    )
                )
                (format "Nonce {} of {} in pool {} now earns for {} instead of {}; owner {} and the position are unchanged."
                    [nonce dpof-id pool-id (UC_ShortAccount new-beneficiary)
                     (UC_ShortAccount current-beneficiary) (UC_ShortAccount owner)]
                )
            )
        )
    )
    (defun AQP-POOL|CC_ReassignCollectableStakeBeneficiary:string
        (
            patron:string
            owner:string
            pool-id:string
            collectable-id:string
            son:bool
            nonce:integer
            current-beneficiary:string
            new-beneficiary:string
        )
        @doc "The NFT/SFT counterpart of AQP-POOL|CC_ReassignOrtoStakeBeneficiary. Collectables \
            \ carry no maturity lock -- this redirects earnings on an already-staked nonce \
            \ without an unstake/restake round trip. son=true DPSF, son=false DPNF. \
            \ Talos shell → AQP-FVT::CC_ReassignCollectableStakeBeneficiary."
        (with-capability
            (AQP|C>REASSIGN-COLLECTABLE-BENEFICIARY
                patron owner pool-id collectable-id son nonce current-beneficiary new-beneficiary)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_ReassignCollectableStakeBeneficiary
                        patron owner pool-id collectable-id son nonce current-beneficiary new-beneficiary
                    )
                )
                (format "Nonce {} of {} in pool {} now earns for {} instead of {}; owner {} and the position are unchanged."
                    [nonce collectable-id pool-id (UC_ShortAccount new-beneficiary)
                     (UC_ShortAccount current-beneficiary) (UC_ShortAccount owner)]
                )
            )
        )
    )
    (defun AQP-POOL|CC_ReassignTrueFungibleStakeBeneficiary:string
        (
            patron:string
            owner:string
            pool-id:string
            dptf-id:string
            amount:decimal
            current-beneficiary:string
            new-beneficiary:string
        )
        @doc "Redirect part or all of who earns from an already-staked true-fungible position -- \
            \ native or its `F|` frozen counterpart -- without unstaking and restaking it. \
            \ Unlike the OF/collectable reassigns, a TF position has no nonce, so <amount> may be \
            \ any value up to the current balance: the owner may split a position across two \
            \ beneficiaries, or move it whole. \
            \ \
            \ NO ASSET EVER MOVES -- the ordinary unstake always returns the position to <owner>, \
            \ regardless of who the beneficiary was, so this is pure earnings bookkeeping. \
            \ \
            \ Requires the OWNER's signature -- they are the one entitled to decide who earns. \
            \ Talos shell → AQP-FVT::CC_ReassignTrueFungibleStakeBeneficiary."
        (with-capability
            (AQP|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY
                patron owner pool-id dptf-id amount current-beneficiary new-beneficiary)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_ReassignTrueFungibleStakeBeneficiary
                        patron owner pool-id dptf-id amount current-beneficiary new-beneficiary
                    )
                )
                (format "{} of {} in pool {} now earns for {} instead of {}; owner {} and the position are unchanged."
                    [amount dptf-id pool-id (UC_ShortAccount new-beneficiary)
                     (UC_ShortAccount current-beneficiary) (UC_ShortAccount owner)]
                )
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
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>STAKE-ORTO-FUNGIBLE patron pool-id executor executee dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>UNSTAKE-ORTO-FUNGIBLE patron pool-id executor executee dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                (ref-DPDC:module{DpdcV3} DPDC)
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
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchVacateCollectables pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array))
                (format "Batch-vacated {} collectable leg(s) on Pool {} (asset {}, son {})."
                    [(length owner-ids) pool-id collectable-id son])
            )
        )
    )
    (defun AQP-POOL|CC_UpdateScoreMultipliers:string
        (patron:string executor:string score-id:string
         mx-frozen:decimal mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Re-set a score's frozen/sleeping/hibernating multipliers. Talos shell → AQP-POOL::CC_UpdateScoreMultipliers. \
            \ Refused while a frozen or sleeping position exists on the score; the result string says \
            \ which rule a caller just satisfied, because `mx-sleeping` is a CEILING and reads like a \
            \ factor."
        ;;THE CAPABILITY IS ACQUIRED HERE, AND THAT IS WHAT MAKES THE CALL LEGAL. `P|UEV_IMC` on
        ;;the core client asks whether a registered inter-module guard is in scope; acquiring the
        ;;callee's own `AQP|C>...` from Talos is what puts one there. Calling the client directly
        ;;fails with "None of the guards passed" from `U|G::UEV_Any`, several frames below the
        ;;mistake -- which is exactly how this was found.
        (with-capability
            (AQP|C>UPDATE-SCORE-MULTIPLIERS patron executor score-id mx-frozen mx-sleeping mx-hibernated)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::CC_UpdateScoreMultipliers patron executor score-id mx-frozen mx-sleeping mx-hibernated)
                )
                (format "Score {} now frozen x{} (flat, a freeze is permanent), sleeping UP TO x{} (reached only at the full 25-year lock), hibernating x{} (flat, it asks no commitment)."
                    [score-id mx-frozen mx-sleeping mx-hibernated]
                )
            )
        )
    )
    (defun AQP-POOL|C_BeginScoreRevoke:string
        (patron:string executor:string pool-id:string score-id:string)
        @doc "PHASE 1 of 3 — begin retiring a score from a pool: vacate its slot and freeze the \
            \ pool. Pool owner. Talos shell → AQP-POOL::C_BeginScoreRevoke. \
            \ \
            \ Use this when `AQP-POOL|C_RevokeScore` refuses because holders still carry weight \
            \ for the score. Then drain with `AQP-POOL|Cp_DrainScoreSlice` until \
            \ `URHC_AQP|ScoreDrainOutstanding` is empty, finalize, and clear the freeze."
        ;;THE SLOT INDEX IS READ THROUGH THE MODREF, not by a dot call. `AQP-POOL.URC_...` would
        ;;have PINNED AQP-POOL's code hash at this module's deploy time, adding a permanent
        ;;(callee, caller) edge that forces Talos to redeploy with every AQP-POOL change -- and
        ;;a stale dot caller of a table-owning callee does not go quietly stale, it aborts with
        ;;"hash not blessed". `_dotpin.py --check` refused the first draft of this wrapper.
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
            )
            (with-capability (AQP|C>BEGIN-SCORE-REVOKE patron executor pool-id score-id
                                (ref-AQP::URC_ScoreSlotIndexForScore pool-id score-id))
                (do
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-AQP::C_BeginScoreRevoke patron executor pool-id score-id)
                    )
                    (format "Score {} unslotted from pool {}. Pool is FROZEN: drain its holders, finalize, then clear."
                        [score-id pool-id]
                    )
                )
            )
        )
    )
    (defun AQP-POOL|Cp_DrainScoreSlice:string
        (patron:string pool-id:string score-id:string accounts:[string])
        @doc "PHASE 2 of 3 — retire one SLICE of the holders of a score that is mid-revoke. Talos \
            \ shell → AQP-POOL::Cp_DrainScoreSlice. Permissionless and idempotent: send one per \
            \ slice of `URHC_AQP|ScoreDrainOutstanding`, in any order, in parallel, as often as you \
            \ like — an account already retired contributes a zero delta. Complete when that read \
            \ returns []."
        (with-capability (AQP|C>DRAIN-SCORE-SLICE patron pool-id score-id accounts)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::Cp_DrainScoreSlice patron pool-id score-id accounts)
                )
                (format "Retired {} holder(s) of score {} in pool {}. Drain is complete when URHC_AQP|ScoreDrainOutstanding returns []."
                    [(length accounts) score-id pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|CC_FinalizeScoreRevoke:string
        (patron:string executor:string pool-id:string score-id:string)
        @doc "PHASE 3 of 3 — cut the score's aqpool-link now that no holder carries weight for it. \
            \ Pool owner. Talos shell → AQP-POOL::CC_FinalizeScoreRevoke. Refused while a single \
            \ holder remains. Does NOT release the pool freeze — `AQP-POOL|CC_ClearPoolSweep` does, \
            \ and only when every score on the pool is clear."
        (with-capability (AQP|C>FINALIZE-SCORE-REVOKE patron executor pool-id score-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::CC_FinalizeScoreRevoke patron executor pool-id score-id)
                )
                (format "Score {} fully retired from pool {}." [score-id pool-id])
            )
        )
    )
    (defun AQP-FVT|CC_ClearPoolSweep:string
        (patron:string pool-id:string)
        @doc "Release a pool's sweep freeze and return it to trading. Talos shell → \
            \ AQP-FVT::CC_ClearPoolSweep. PERMISSIONLESS and self-proving: it succeeds only when \
            \ every employed score is fully re-rated and no retired score still holds weight, so \
            \ anybody may be the one to finish the job — including a holder who wants to exit."
        (with-capability (FVT|C>CLEAR-POOL-SWEEP patron pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_ClearPoolSweep patron pool-id)
                )
                (format "Pool {} released: no outstanding re-rate or drain work remains." [pool-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BackfillScoreSlice:string
        (patron:string pool-id:string score-id:string beneficiaries:[string])
        @doc "Re-rate one SLICE of a score's holders to their canonical base. Talos shell → \
            \ AQP-POOL::CCp_BackfillScoreSlice. Permissionless and idempotent: send one per slice \
            \ of `URHC_AQP|ScoreBackfillOutstanding`, in any order, in parallel, as many times as \
            \ you like — a holder already correctly rated contributes a zero delta. The sweep is \
            \ complete when that read returns []."
        (with-capability (AQP|C>BACKFILL-SCORE-SLICE patron pool-id score-id beneficiaries)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::CCp_BackfillScoreSlice patron pool-id score-id beneficiaries)
                )
                (format "Re-rated {} holder(s) of score {} in pool {}. The sweep is complete when URHC_AQP|ScoreBackfillOutstanding returns []."
                    [(length beneficiaries) score-id pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncTrueFungibleAnchors:string
        (patron:string executee:string dptf-id:string)
        @doc "Pool-agnostic TF anchor repair for beneficiary × dptf-id. Talos shell → AQP-POOL::C_SyncTrueFungibleAnchors."
        (with-capability (AQP|C>SYNC-TF-ANCHORS patron executee dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_ToggleRewardLink patron executor fvt-id reward-dptf-id enabled)
                )
                (format "Successfully toggled reward link {} on FVT {} to enabled={}." [reward-dptf-id fvt-id enabled])
            )
        )
    )
    (defun AQP-FVT|C_SetMinInjectAmount:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string min-inject-amount:decimal)
        @doc "Sets one reward lane's MINIMUM single injection (owner-gated) and collects IGNIS on \
            \ patron. The floor exists because the stale-fix loop inside an inject runs regardless \
            \ of amount, so without it one smallest unit buys a full force-fix of the membership. \
            \ Every lane is created at the default, so this raises an existing floor rather than \
            \ introducing one."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_SetMinInjectAmount patron executor fvt-id reward-dptf-id min-inject-amount)
                )
                (format "Successfully set minimum injection on lane {} of FVT {} to {}." [reward-dptf-id fvt-id min-inject-amount])
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_Inject patron executor fvt-id reward-dptf-id amount)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully FRESH-injected {} {} into FVT {}." [amount reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-FVT|CCp_FvtFixSlice:string
        (patron:string fvt-id:string reward-dptf-id:string users:[string])
        @doc "PARALLEL fed slice of the enforced-fresh inject's fix phase: refresh exactly the \
            \ LISTED stale stakers. Read `URH_FvtStalePresentUsers`, split it into DISJOINT slices, \
            \ and send them together -- then `AQP-FVT|CC_InjectFinalize`. \
            \ \
            \ PREFER THIS OVER `AQP-FVT|CCp_InjectFixChunk` WHEN FANNING OUT. That one takes a \
            \ chunk SIZE and takes the first N of the shared stale list, so two concurrent sends \
            \ pick the SAME users -- duplicate work, and the 2e forced-fix penalty recorded twice \
            \ against those holders. This one takes the accounts, and re-checks staleness inside \
            \ the transaction, so an overlapping or replayed slice simply finds them fresh and \
            \ skips them with no second penalty. \
            \ \
            \ WHEN A SLICE IS NEEDED: adding or revoking a score entity on an FVT makes its \
            \ members deb-stale. That does NOT block stake or unstake -- a stale member mis-states \
            \ reward SHARES, never the base -- but `CC_InjectFinalize` refuses to inject while any \
            \ stale member remains, so the work has to be done before the next reward injection. \
            \ Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CCp_FvtFixSlice patron fvt-id reward-dptf-id users))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
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
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-MTX-AQP:module{AqpMtxV2} MTX-AQP)
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
                    (ref-MTX-AQP:module{AqpMtxV2} MTX-AQP)
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
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
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
        @doc "Collects pending reward DPTF for the EXECUTOR on one score-entity from fvt-id; collects IGNIS on \
            \ patron. \
            \ \
            \ THE @doc SAID \"for patron\" UNTIL 2026-10-29 AND THE BALANCE DIFF BELOW BELIEVED IT. \
            \ <FVT::CC_Collect> credits the EXECUTOR -- `XI_TransferRewardDptfFromVault`'s own doc calls it \
            \ the REWARD SUBJECT and says `patron` \"only pays IGNIS and is deliberately unused here\". So a \
            \ sponsored collect measured the SPONSOR's balance across a transfer that moved nothing of theirs \
            \ and reported `0.0` for a collect that really paid out. Reading the executor is the fix; the \
            \ figure is unchanged for a self-collect, where the two accounts are the same. \
            \ \
            \ IT STILL UNDERSTATES A TRIPLET LANE, and that is pre-existing rather than introduced here: a \
            \ MULTIPLET_BASE triplet pays in up to THREE tokens and this reads only <reward-dptf-id>, so the \
            \ coiled and double-coiled shares are invisible to it. <RPS::URC_CollectLadderPreview> is the \
            \ reader that answers per-token and exists for exactly that reason."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                    (bal-before:decimal (ref-DPTF::UR_AccountSupply reward-dptf-id executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_Collect patron executor fvt-id score-entity-type score-entity-id reward-dptf-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (let
                    (
                        (bal-after:decimal (ref-DPTF::UR_AccountSupply reward-dptf-id executor))
                        (payout:decimal (- bal-after bal-before))
                    )
                    (format "Successfully collected {} {} rewards from FVT {} for score-entity type {} id {}."
                        [payout reward-dptf-id fvt-id score-entity-type score-entity-id]
                    )
                )
            )
        )
    )
    ;;
    ;;  [AQP-EVCT -- Reward Eviction]
    ;;
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-EVCT|CCp_EvictMultiRewards:string
        (patron:string executor:string fvt-id:string beneficiaries:[string]
         score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
        @doc "ONE EVICTION SLICE: the FVT owner collects on behalf of the listed stakers, so each one \
            \ receives exactly what a self-collect would have paid them -- AQP-FVT's eviction surface \
            \ runs the SAME phase functions (XI_CollectDrip/XI_CollectPay) that CC_Collect runs. Owner \
            \ enforced in EVCT|C>EVICT-SLICE; IGNIS on patron. \
            \ \
            \ FED SLICE, SO PARALLEL-SAFE: the client dirty-reads AQP-EVCT::URHC_BuildEvictSlicePlan, \
            \ splits into disjoint gas-bounded slices and fires them at once. Contrast a cursor pager, \
            \ which is strictly sequential. \
            \ \
            \ WHAT IT DOES NOT DO: it does not touch scores (eviction only moves reward tokens, and \
            \ stale scores are refreshed exactly as a collect refreshes them), and it does not freeze \
            \ the FVT -- an eviction is a collect triggered by the pool owner instead of the \
            \ beneficiary, so there is nothing to protect from a concurrent stake."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EVCT::CCp_EvictMultiRewards patron executor fvt-id beneficiaries
                        score-entity-types score-entity-ids reward-dptf-ids))
                (format "Evicted {} reward leg(s) on FVT {} to their beneficiaries."
                    [(length beneficiaries) fvt-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|ADMINISTRATIVE-SUMMONER
    (defun AQP-EVCT|AAp_EvictMultiRewards:string
        (executor:string fvt-id:string beneficiaries:[string]
         score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
        @doc "GASLESS ADMIN eviction slice -- byte-for-byte AQP-EVCT|CCp_EvictMultiRewards with the Ouronet \
            \ system account in the patron slot, so no IGNIS is charged for it. \
            \ \
            \ FOR THE DAILY AUTOMATON. Owner, 2026-10-29: daily evictions across the FVTs the Ouronet \
            \ administrator owns would cost 'a ton of ignis', and the gasless patron is the only way \
            \ to make them sustainable. This wrapper IS that path, which is why no secondary \
            \ orchestration from the DSP module is needed to reach it. \
            \ \
            \ TWO GATES, BOTH REQUIRED: the ADMIN keyset (P|ADMINISTRATIVE-SUMMONER) says the call may \
            \ happen at all, and AQP-EVCT still requires <executor> to own <fvt-id>. Dropping the \
            \ first would make every FVT owner a free rider on the gas station; dropping the second \
            \ would let the administrator evict a stranger's FVT. \
            \ \
            \ GASLESS MEANS NO IGNIS, NOT NO GAS -- the Chainweb gas is still paid, by the Ouronet gas \
            \ station, because this is a Talos path."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                    ;;THE GASLESS PATRON, RESOLVED LOCALLY. `GASLESS-PATRON` is a defconst in
                    ;;01_TS01-A, not something every Talos module has, and the bare name reads as a
                    ;;MODULE reference to Pact. Read from the same source URC_Gassless reads: one
                    ;;definition, no chance of the two drifting.
                    (gasless:string (ref-DALOS-G::GOV|DALOS|SC_NAME))
                )
                (ref-IGNIS::XE_CollectIgnis gasless
                    (ref-EVCT::CCp_EvictMultiRewards gasless executor fvt-id beneficiaries
                        score-entity-types score-entity-ids reward-dptf-ids))
                (format "Evicted {} reward leg(s) on FVT {} to their beneficiaries. [gasless admin]"
                    [(length beneficiaries) fvt-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-EVCT|CC_EvictSingleReward:string
        (patron:string executor:string fvt-id:string beneficiary:string
         score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "ONE LEG, ONE TRANSACTION — the shape a large FVT is evicted with, and the one the UI \
            \ falls back to when AQP-EVCT|CC_FullEvictRewards does not fit. Owner enforced in \
            \ EVCT|C>EVICT-SINGLE; IGNIS on patron. \
            \ \
            \ THE TRANSACTION COUNT IS THE LEG COUNT. AQP-EVCT::URHC_BuildEvictPlans returns exactly \
            \ one object per leg, so a client sends one of these per entry and nothing has to be \
            \ packed, measured or resized. Owner, 2026-10-30: 'you can see instantly if there are 120 \
            \ tx constructed there are 120 legs.' \
            \ \
            \ SAFE BY CONSTRUCTION, not by measurement: one leg is one drip plus one pay, so no \
            \ single transaction in the campaign can approach the 2,000,000 ceiling. Contrast \
            \ AQP-EVCT|CCp_EvictMultiRewards, which must be measured against it and re-measured when \
            \ the data moves. \
            \ \
            \ ORDER-INDEPENDENT EXCEPT FOR THE DUST: the last claimant on a lane sweeps the \
            \ remainder, so whichever transaction lands last on a lane receives it. The lane still \
            \ ends at zero. A leg already collected refuses and moves nothing, so a fan-out must \
            \ expect some to bounce."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EVCT::CC_EvictSingleReward patron executor fvt-id beneficiary
                        score-entity-type score-entity-id reward-dptf-id))
                (format "Evicted {} on FVT {} to {}." [reward-dptf-id fvt-id beneficiary])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|ADMINISTRATIVE-SUMMONER
    (defun AQP-EVCT|AA_EvictSingleReward:string
        (executor:string fvt-id:string beneficiary:string
         score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "GASLESS ADMIN single-leg eviction — byte-for-byte AQP-EVCT|CC_EvictSingleReward with the \
            \ Ouronet system account in the patron slot, so no IGNIS is charged. \
            \ \
            \ THIS IS THE AUTOMATON'S WORKHORSE. A daily eviction across the administrator's FVTs is \
            \ a fan-out of these: the count is known from the plan before anything is sent, every \
            \ transaction is the same size, and none of them can be refused for gas. See \
            \ AQP-EVCT|AAp_EvictMultiRewards for why the pair is admin-gated as well as owner-gated."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                    (gasless:string (ref-DALOS-G::GOV|DALOS|SC_NAME))
                )
                (ref-IGNIS::XE_CollectIgnis gasless
                    (ref-EVCT::CC_EvictSingleReward gasless executor fvt-id beneficiary
                        score-entity-type score-entity-id reward-dptf-id))
                (format "Evicted {} on FVT {} to {}. [gasless admin]"
                    [reward-dptf-id fvt-id beneficiary])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-EVCT|CC_FullEvictRewards:string (patron:string executor:string fvt-id:string)
        @doc "WHOLE-FVT eviction in ONE transaction -- the convenience path for a small FVT, which scans \
            \ its own legs instead of being handed a slice. A large FVT must use \
            \ AQP-EVCT|CCp_EvictMultiRewards: the node gas meter is the real ceiling and this scans before \
            \ it pays. Owner enforced in EVCT|C>FULL-EVICT; IGNIS on patron. \
            \ \
            \ Stands to AQP-EVCT|CCp_EvictMultiRewards exactly as AQP-POOL|CC_FullVacate stands to the \
            \ AQP-POOL|CCp_Batch* family."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EVCT::CC_FullEvictRewards patron executor fvt-id))
                (format "Evicted every outstanding reward leg on FVT {} to its beneficiaries." [fvt-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|ADMINISTRATIVE-SUMMONER
    (defun AQP-EVCT|AA_FullEvictRewards:string (executor:string fvt-id:string)
        @doc "GASLESS ADMIN whole-FVT eviction. See AQP-EVCT|AAp_EvictMultiRewards for why the patron slot \
            \ carries the Ouronet system account, and why the executor is STILL owner-gated on top of \
            \ the admin keyset."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                    (gasless:string (ref-DALOS-G::GOV|DALOS|SC_NAME))
                )
                (ref-IGNIS::XE_CollectIgnis gasless
                    (ref-EVCT::CC_FullEvictRewards gasless executor fvt-id))
                (format "Evicted every outstanding reward leg on FVT {} to its beneficiaries. [gasless admin]"
                    [fvt-id])
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-DSA:module{DsaV3} AQP-DSA)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DSA::C_RecomputeCapture patron fvt-id score-entity-id)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Capture recomputed for agency {} on FVT {}." [score-entity-id fvt-id])
            )
        )
    )
)

;; --- tables for 04_TS02-C3.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)


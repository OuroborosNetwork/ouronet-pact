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
(create-table P|T)
(create-table P|MT)

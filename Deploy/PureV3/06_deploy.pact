;; TX 06/08 -- AQP-FVT, MTX-AQP, AQP-DSA      (~277,164 B, ~154k gas)
;;
;; No edits of their own. All three name AcquisitionScoresV2 and all three dot-call RPS, so they
;; move for the interface bump (TX 03) and the RPS upgrade (TX 05). Shipping them is not optional:
;; a stale dot-caller of a table-owning callee ABORTS with "hash not blessed" rather than merely
;; returning old data.
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

;; ---- source: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/05_FVT.pact (module only -- its interface is already live)
(module AQP-FVT GOV
    @doc "Large sovereign reward-accounting module for AQP farms (class 0), vaults (1) and \
        \ treasuries (2). Uses a UrStoa-style RPS (reward-per-share) model across \
        \ global/member/user/stream tables plus member vaults, user presence/weight mirrors, \
        \ quality-splits, forced-fix counts, vacate-freeze and DSA agency-fee/oracle rows. \
        \ Drives the multi-phase stake/unstake settle, reward inject (incl. streamed and \
        \ enforced-fresh), collect, deb-staleness fixes, and the re-score anchor-sweep \
        \ recompute; composes AQP-POOL/SCORE/ANK."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements AcquisitionFarmsVaultsTreasuriesV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;(implements DemiourgosPactDigitalCollectibles-UtilityPrototype)
    ;;
    (defconst GOV|MD_FVT                                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|FVT_ADMIN)))
    (defcap GOV|FVT_ADMIN ()                            (enforce-guard GOV|MD_FVT))
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
    (deftable P|T:{OuronetPolicyV2.P|S})                      ;; Key = <policy-name>
    ;;  PURPOSE: Named keyset guards for this module (OuronetPolicyV2). Used by GOV|FVT_ADMIN and IMP registration.
    (deftable P|MT:{OuronetPolicyV2.P|MS})                     ;; Key = P|I (module-identity constant)
    ;;{P4}  capabilities
    ;;  PURPOSE: Multi-policy metadata — IMP guard list for cross-module capability checks.
    (defcap P|FVT|CALLER ()
        true
    )
    (defcap P|FVT|REMOTE-GOV ()
        @doc "Remote governor for AQP|SC_NAME vault TFT legs (inject/collect). Registered on AQP-POOL P|T as FVT|RemoteAqpGov."
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|FVT|CALLER))
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
        (with-capability (GOV|FVT_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|FVT_ADMIN)
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
        (with-capability (GOV|FVT_ADMIN)
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
        (with-capability (GOV|FVT_ADMIN)
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
        @doc "Post-deploy (AQP-BOOT Step 0): FVT SECURE on AQP-SCORE + AQP-POOL IMP; \
            \ P|FVT|CALLER on TFT/DPOF/DPDC-T; FVT|RemoteAqpGov on AQP-POOL for inject/collect vault legs. \
            \ Vacate recipes live in AQP-VCT."
        (let
            (
                (ref-P|SCR:module{OuronetPolicyV2} AQP-SCORE)
                (ref-P|AQP:module{OuronetPolicyV2} AQP-POOL)
                (ref-P|RPS:module{OuronetPolicyV2} RPS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|SWPLC:module{OuronetPolicyV2} SWPLC)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                ;;
                (dg:guard (create-capability-guard (SECURE)))
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|FVT|CALLER)))
                (rg:guard (create-capability-guard (P|FVT|REMOTE-GOV)))
            )
            ;; #75 B': FVT drives the RPS reward engine via RPS::XE_ — register FVT's SECURE guard on RPS IMP.
            (ref-P|RPS::P|A_AddIMP dg)
            (ref-P|SCR::P|A_AddIMP dg)
            (ref-P|AQP::P|A_AddIMP dg)
            (ref-P|AQP::P|A_Add "FVT|RemoteAqpGov" rg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
            ;; DPTF: FVT burns the royalty pool in place from AQP|SC_NAME (DSA royalty burn disposal).
            (ref-P|DPTF::P|A_AddIMP mg)
            ;; SWPLC: FVT fuels a swpair with the royalty pool from AQP|SC_NAME (DSA royalty fuel disposal).
            (ref-P|SWPLC::P|A_AddIMP mg)
            ;; OUROBOROS: FVT normalizes an IGNIS royalty leg to OURO (XB_Compress) before disposal.
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst CT_FVT_RPS_PREC 48)
    (defconst FVT|DSA-ORACLE-KEY:string "GLOBAL")
    ;; --- Time-streamed inject (linear vesting release) — see Audit/STREAMED-INJECT-DESIGN.md ---
    (defconst STREAM_EPOCH:time (time "1970-01-01T00:00:00Z")
        "Default stream-last-release for a lane with no live stream (irrelevant while stream-count = 0).")
    (defconst STREAM_MIN_UPS 10000000
        "Anti-degeneracy floor: min smallest-token-units released per second for a streamed inject. \
       \ Precision-normalized — the effective min rate is STREAM_MIN_UPS * 10^(-reward-decimals), so it is \
       \ uniform across tokens (a 24-dp token clears it with a tiny amount; a 12-dp token needs ~0.864/24h).")
    (defconst STREAM_MAX_DURATION 31536000
        "Max stream duration in seconds (365 days).")
    (defconst STREAM_MIN_DURATION 3600
        "Min stream duration in seconds (1 hour). duration = 0 means an INSTANT inject (unchanged path).")
    (defconst STREAM_MAX_LANES 49
        "Hard ceiling on concurrent streams per lane (7x7 grid). The per-account cap (URC_MaxStreamLanes, by \
       \ Elite tier of the FVT owner konto) is always <= this.")
    ;; --- DSA (Delegated Staking Agencies) — see Audit/DSA-DELEGATED-STAKING-DESIGN.md ---
    (defconst DSA_ORACLE_TTL 90000
        "Oracle validity window in seconds (25h = a daily oracle write + 1h overlap, so there is never a gap \
       \ between last-write-expired and next-write). At inject, a delegation member whose last oracle write is \
       \ older than this (now − oracle-ts > DSA_ORACLE_TTL) captures NOTHING (effective weight 0 ⇒ its whole \
       \ share routes to the royalty pool). Only consulted when the FVT's oracle-on flag is set.")
    ;; --- Re-score sweep CC-batch gas backstop (loose ceiling + UI seed, mirrors the vacate cap philosophy) ---
    (defconst SWEEP-CHUNK-GAS-BUDGET 2000000
        "Nominal per-tx gas envelope the sweep CC-batch chunk cap is sized against (backstop, not the optimizer).")
    (defconst SWEEP-GAS-PER-HOLDER 2000
        "Per-holder backstop for the re-score recompute (settle across every reward stream + ANK aggregate \
       \ refold + deb refresh + mirror resync). MEASURED (REPL/Kursan/AQP-scale-sweep.repl, final hoisted \
       \ code): gas(n) = 81,040 + 1,684*n on a single-score/single-stream FVT → ~1,139 holders fit 2M. Set to \
       \ 2,000 (slope + ~19% margin) → SWEEP-CHUNK-MAX = 1,000 (1,000 holders = 1.77M, headroom). NOT the \
       \ optimizer: the UI sizes real chunks by simulating (/local) against the true model-dependent gas (richer \
       \ FVTs settle across more streams → higher per-holder → simulate lower), and the node gas meter is the \
       \ real enforcement (an oversized chunk aborts atomically — submitter's gas, offset unchanged, retry smaller).")
    (defconst SWEEP-CHUNK-MAX (/ SWEEP-CHUNK-GAS-BUDGET SWEEP-GAS-PER-HOLDER)
        "1,000 holders/chunk — the UI's optimistic seed + a coarse safety ceiling; refined by simulation.")
    ;; --- Enforced-fresh inject CC-batch fix backstop (loose ceiling + UI seed; same philosophy) ---
    (defconst INJECT-FIX-CHUNK-GAS-BUDGET 2000000
        "Nominal per-tx gas envelope the inject-fix chunk cap is sized against (backstop, not the optimizer).")
    (defconst INJECT-FIX-GAS-PER-USER 6500
        "Per-stale-user backstop for the enforced-fresh deb-fix (settle across every reward stream + deb refresh \
       \ + mirror resync). MEASURED (REPL/Kursan/AQP-scale-inject.repl, final hoisted code): gas(n) = 199,096 + \
       \ 5,189*n on a single-score/single-stream FVT → ~347 users fit 2M. Set to 6,500 (slope + ~25% margin) → \
       \ INJECT-FIX-CHUNK-MAX = 307 (307 users = 1.79M, headroom). NOT the optimizer — the UI sizes real chunks \
       \ by simulating (/local) and the node gas meter is the real ceiling; an oversized chunk aborts atomically \
       \ (retry smaller). Richer FVTs → higher fixed + per-user → simulate lower.")
    (defconst INJECT-FIX-CHUNK-MAX (/ INJECT-FIX-CHUNK-GAS-BUDGET INJECT-FIX-GAS-PER-USER)
        "307 stale users/chunk — the UI's optimistic seed + a coarse safety ceiling; refined by simulation.")
    ;; M3 #12 2e — IGNIS charged per inject-forced deb-fix, at the user's next collect (non-discountable). Governance
    ;; param (placeholder); set ≥ the IGNIS cost of self-fixing one score so self-fixing is always cheaper. ~10 IGNIS.
    (defconst CT_FORCED_FIX_RATE:decimal 10.0)
    (defconst BAR                                       (CT_Bar))
    (defconst AQP|SC_NAME                               (CT_AqpScName))
    (defconst GAS|ISSUE-FVT                         (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "issue-fvt")))
    (defconst GAS|ADD-SCORE-ENTITY                  (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "add-score-entity")))
    (defconst GAS|ISSUE-MULTIPLET-FAMILY            (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "issue-multiplet")))
    (defconst GAS|TOGGLE-SCORE-ENTITY-LINK          (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "fvt-link-toggle")))
    (defconst GAS|SET-MOSAIC                        (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "fvt-split-setup")))
    (defconst GAS|ADD-REWARD-LINK                   (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "add-reward-link")))
    (defconst GAS|TOGGLE-REWARD-LINK                (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "fvt-link-toggle")))
    (defconst GAS|SET-QUALITY-SPLIT                 (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "fvt-split-setup")))
    (defconst GAS|SET-COMMON-DENOMINATOR            (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "fvt-split-setup")))
    (defconst GAS|SET-SPLIT-MODE                    (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "fvt-split-setup")))
    (defconst GAS|INJECT                            (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "aqp-inject")))
    (defconst GAS|COLLECT                           (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "aqp-collect")))
    (defconst GAS|UNSTALE                           (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "unstale")))
    (defconst CT_REWARD_KIND_PLAIN                      "PLAIN")
    (defconst CT_REWARD_KIND_MULTIPLET_BASE             "MULTIPLET_BASE")
    ;; Round B: a MULTIPLET_BASE triplet reward line can split each lane HOMOGENEOUSLY (each lane → one ladder
    ;; token: bronze→token-0, silver→token-1, gold→token-2) or HETEROGENEOUSLY (each lane → all 3 ladder tokens
    ;; per a stored per-mille matrix). Absent config ⇒ HOMOGENEOUS (unchanged behavior).
    (defconst CT_REWARD_MODE_HOMOGENEOUS                "HOMOGENEOUS")
    (defconst CT_REWARD_MODE_HETEROGENEOUS              "HETEROGENEOUS")
    (defconst CT_SCORE_ENTITY_SCORE                     1)
    (defconst CT_SCORE_ENTITY_TRIPLET                   3)
    (defconst CT_MEMBERSHIP_MODE_BAR                    "BAR")
    (defconst CT_MEMBERSHIP_MODE_SCORE                  "SCORE")
    (defconst CT_MEMBERSHIP_MODE_TRUE_TRIPLET           "TRUE-TRIPLET")
    (defconst CT_MEMBERSHIP_MODE_STANDARD_TRIPLET       "STANDARD-TRIPLET")
    ;; Farm reward-split modes (D1-G2). Level-2 W_i source at inject; per-farm, freely mutable.
    (defconst CT_SPLIT_MODE_STAKED                      "SPLIT|STAKED") ;; Variant 1 — participation (farm default): W_i = member STAKED value (RPS.URC_MemberStakedStoaValue)
    (defconst CT_SPLIT_MODE_TVL                         "SPLIT|TVL")    ;; Variant 2 — pool-size: W_i = whole swpair TVL (UR_StoaValue)
    (defconst CT_SPLIT_MODE_NA                          "|")            ;; sentinel — split-mode is farm-only; vaults/treasuries store this and never consult it
    ;;{3.2}  schemas
    ;;
    ;; duplicate copies of moved schemas (structural types referenced by staying FVT — #75 B' Stage 3)
    ;;{3.3}  tables
    ;;
    (deftable FVT|T:{AcquisitionSchemasV1.FVT|Schema})                               ;; Key = <FVT-ID>
      ;; Key = <FVT-ID>  (#75 B' Stage 1)
      ;; Key = <FVT-ID> | <Score-Entity-ID>
      ;; Key = <Multiplet-Family-ID>
                ;; Key = <FVT-ID> | <DPTF-ID>
                ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
                    ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
                ;; Key = <FVT-ID> | <DPTF-ID> | <position 1..49>
    ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>
              ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
            ;; Key = <FVT-ID> | <Ouronet-ID>
        ;; Key = <FVT-ID> | <DPTF-ID> | <User-ID>
    (deftable FVT|T|VacateFreeze:{AcquisitionSchemasV1.FVT|VacateFreeze})            ;; Key = <FVT-ID>
    (deftable FVT|T|SweepProgress:{AcquisitionSchemasV1.FVT|SweepProgress})          ;; Key = <Anchor-ID>
      ;; Key = FVT|DSA-ORACLE-KEY (single global row)
                  ;; Key = <FVT-ID> | <Score-Entity-ID>
            ;; Key = <FVT-ID> | <DPTF-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap FVT|C>ISSUE-FVT
        (fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Issue one FVT|T row: autostake fvt-name, owner, class 0..2, farm common-denominator or vault/treasury \"|\". Composes SECURE for XI_IssueFvt."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (fvt-id:string (ref-U|DALOS::UDC_Makeid fvt-name))
            )
            (enforce
                (fold (and) true
                    [
                        (>= fvt-class 0)
                        (<= fvt-class 2)
                        (not (ref-RPS::URC_FvtExists fvt-id))
                    ]
                )
                "Invalid FVT issue: fvt-class must be 0..2 and fvt-name must be unused"
            )
            (if (= fvt-class 0)
                (enforce
                    (fold (and) true
                        [
                            (!= common-denominator BAR)
                            (!= common-denominator "|")
                        ]
                    )
                    "Farm FVT requires a full native DPTF common-denominator"
                )
                (enforce (= common-denominator "|") "Vault/Treasury FVT common-denominator must be |")
            )
            (if (= fvt-class 0)
                (ref-DPTF::UEV_id common-denominator)
                true
            )
            (ref-U|ATS::UEV_AutostakeIndex fvt-name)
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (ref-DALOS::UEV_EnforceAccountType owner-konto false)
            (compose-capability (SECURE))
        )
    )
    )
    (defcap FVT|C>ROTATE-OWNERSHIP-FVT (executor:string fvt-id:string new-owner-konto:string)
        @doc "Rotate FVT owner-konto: current owner, can-change-owner true, distinct new standard account. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner-now:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (can-change-owner:bool (UR_FVT|CanChangeOwner fvt-id))
            )
            (enforce
                (and can-change-owner (!= new-owner-konto owner-now))
                "FVT owner rotation requires can-change-owner true and a distinct new owner-konto"
            )
            (enforce (= executor owner-now)
                (format "Executor {} is not the current owner of FVT {} (owner is {})"
                    [executor fvt-id owner-now]))
            (ref-DALOS::CAP_EnforceAccountOwnership owner-now)
            (ref-DALOS::UEV_EnforceAccountType new-owner-konto false)
            (compose-capability (SECURE))
        )
    )
    )
    (defcap FVT|C>CONTROL-FVT (executor:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Update FVT can-upgrade and can-change-owner: owner ownership and current can-upgrade true. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (can-upgrade:bool (UR_FVT|CanUpgrade fvt-id))
            )
            (enforce can-upgrade "FVT control update requires can-upgrade true")
            (UEV_ExecutorIzFvtOwner executor fvt-id)
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
    )
    )
    (defcap FVT|C>SET-COMMON-DENOMINATOR (executor:string fvt-id:string common-denominator:string)
        @doc "Farm-only: set common-denominator before any ScoreEntityLink rows. Owner + can-upgrade. Composes SECURE."
        @event
        (UEV_ExecutorIzFvtOwner executor fvt-id)
        (UEV_SetCommonDenominatorContext fvt-id common-denominator)
        (compose-capability (SECURE))
    )
    (defcap FVT|C>SET-MOSAIC (executor:string fvt-id:string mosaic:bool)
        @doc "Toggle mosaic membership policy when FVT has zero ScoreEntityLink rows. Owner + can-upgrade. Composes SECURE."
        @event
        (UEV_ExecutorIzFvtOwner executor fvt-id)
        (UEV_SetMosaicContext fvt-id mosaic)
        (compose-capability (SECURE))
    )
    (defcap FVT|C>ADD-SCORE-ENTITY
        (executor:string fvt-id:string score-entity-type:integer score-entity-id:string swpair:string ghost-weight:decimal)
        @doc "Admit score (type 1) or triplet (type 3) via ScoreEntityLink. Composes SECURE."
        @event
        (UEV_ExecutorIzFvtOwner executor fvt-id)
        (UEV_AddScoreEntityContext fvt-id score-entity-type score-entity-id swpair ghost-weight)
        (compose-capability (SECURE))
    )
    (defcap FVT|C>ISSUE-MULTIPLET-FAMILY
        (
            executor:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "Issue one FVT|T|MultipletFamily reward ladder. Distinct tokens and ATS pairs; family id unused. Composes SECURE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (UEV_IssueMultipletFamilyContext token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id)
        (compose-capability (SECURE))
    )
    (defcap FVT|C>TOGGLE-SCORE-ENTITY-LINK
        (executor:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Toggle ScoreEntityLink.enabled; farm adjusts S. FVT owner. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (ref-RPS::URC_FvtScoreEntityLinkRowExists fvt-id score-entity-id) "ScoreEntityLink row must exist")
            (enforce (= score-entity-type (ref-RPS::UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)) "score-entity-type mismatch")
            (UEV_ExecutorIzFvtOwner executor fvt-id)
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
    )
    )
    (defcap FVT|C>ADD-REWARD-LINK
        (executor:string fvt-id:string reward-dptf-id:string segmentation:bool reward-kind:string multiplet-family-id:string)
        @doc "Insert FVT|T|RPS|Global with reward-enabled true. FVT owner; issued reward DPTF. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (UEV_ExecutorIzFvtOwner executor fvt-id)
            (ref-RPS::UEV_AddRewardLinkContext fvt-id reward-dptf-id reward-kind multiplet-family-id)
        (compose-capability (SECURE))
    )
    )
    (defcap FVT|C>SET-QUALITY-SPLIT
        (executor:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Set a MULTIPLET_BASE reward's quality-split mode + heterogeneous matrix. FVT owner. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (UEV_ExecutorIzFvtOwner executor fvt-id)
            (ref-RPS::UEV_QualitySplitContext fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
        (compose-capability (SECURE))
    )
    )
    (defcap FVT|C>SET-SPLIT-MODE (executor:string fvt-id:string split-mode:string)
        @doc "Set the farm reward-split mode (D1-G2): SPLIT|STAKED (participation) | SPLIT|TVL (pool-size). Farm \
            \ (class 0) only; FVT owner; FREELY mutable (no cooldown) — a change re-weights only FUTURE injects \
            \ (RPS is checkpoint-based, past rewards untouched). Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
            )
            ;; 1] farm-only + valid mode value (two boolean conditions → one enforce)
            (enforce
                (and (= (ref-RPS::UR_FVT|FvtClass fvt-id) 0)
                     (or (= split-mode CT_SPLIT_MODE_STAKED) (= split-mode CT_SPLIT_MODE_TVL)))
                "Split-mode: farm (class 0) only, value must be SPLIT|STAKED or SPLIT|TVL")
            ;; 2] owner authorization
            (UEV_ExecutorIzFvtOwner executor fvt-id)
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
    )
    )
    (defcap FVT|C>TOGGLE-REWARD-LINK (executor:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Toggle RPS|Global.reward-enabled; ±1 enabled-reward-count on flip. FVT owner. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (ref-RPS::URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (UEV_ExecutorIzFvtOwner executor fvt-id)
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
    )
    )
    (defcap FVT|C>INJECT
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Inject reward DPTF into FVT RPS (UrStoa URV|INJECT). Farm: S>0; vault/treasury: total-deb-score>0; reward-enabled. \
            \ Composes P|SECURE-CALLER + P|FVT|REMOTE-GOV for TFT custody to AQP|SC_NAME."
        @event
        (UEV_InjectContext patron fvt-id reward-dptf-id amount)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|FVT|REMOTE-GOV))
    )
    (defcap FVT|C>INJECT-STREAM
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Inject a reward DPTF as a TIME-STREAM (linear vesting over `duration` seconds). Same reward context \
            \ as an instant inject (UEV_InjectContext: not vacate-frozen, reward-enabled, patron/amount valid) plus \
            \ the count-independent stream-param guard (UEV_StreamParams: duration bounds + min rate). The slot-cap \
            \ (Elite-tier concurrent-stream limit on the FVT owner konto) is enforced in XIv_FvtAddStream AFTER the \
            \ drip. Composes the same P|SECURE-CALLER + P|FVT|REMOTE-GOV as an inject (TFT custody to AQP|SC_NAME)."
        @event
        (UEV_InjectContext patron fvt-id reward-dptf-id amount)
        (UEV_StreamParams reward-dptf-id amount duration)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|FVT|REMOTE-GOV))
    )
    (defcap FVT|C>INJECT-FIX (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Protects a paginated enforced-fresh inject FIX chunk (CCp_InjectFixChunk) — the scalable prelude to \
            \ CC_InjectFinalize, for stale sets exceeding one tx. Validates the SAME reward context as an inject \
            \ (not vacate-frozen, reward link row exists + enabled) minus the amount, so a fix pass is always tied \
            \ to a real reward link (the fix force-refreshes stale stakers + records the 2e penalty, exactly as \
            \ the MTX|2|C_Inject defpact does). `chunk` is bounded by the loose INJECT-FIX-CHUNK-MAX backstop (the \
            \ UI sizes it by simulation; the node gas meter is the real ceiling). Composes P|SECURE-CALLER for the \
            \ intra-module fix + the cross-module XE_RefreshUserScoreDeb into AQP-SCORE. `patron` retained for \
            \ symmetry / the event."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
        (enforce (and (ref-RPS::URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) (ref-RPS::UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id))
            "Reward link row must exist and be enabled for a fix pass")
        (enforce (and (> chunk 0) (<= chunk INJECT-FIX-CHUNK-MAX))
            "Inject-fix chunk out of range — the UI sizes it by simulation, the gas meter is the real ceiling")
        (compose-capability (P|SECURE-CALLER))
    )
    )
    (defcap FVT|C>UNSTALE-ALL (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Protects the OWNER-run mass deb-unstale (CCp_UnstaleAll): the FVT entity owner force-refreshes up to \
            \ `chunk` currently-stale present stakers to make the entity INJECTION-READY, WITHOUT injecting. Uses \
            \ the SAME penalized fix as an inject's fix-phase (ref-RPS::XE_XI_FixUserFvtDebPenalizedIn records the 2e forced-fix \
            \ count on (fvt, reward-dptf, user) → the user reimburses it in non-discountable IGNIS at his next \
            \ collect of this lane), so a standalone prep and a real inject tag stale users identically. Validates \
            \ the SAME reward context as an inject (not vacate-frozen, reward link row exists + enabled) minus the \
            \ amount, plus the `chunk` bound. Unlike the permissionless inject-fix (part of a billed inject flow), \
            \ this standalone op is OWNER-GATED — only the FVT owner may pre-unstale their own entity. Composes \
            \ P|SECURE-CALLER for the intra-module fix + the cross-module XE_RefreshUserScoreDeb into AQP-SCORE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (ref-RPS::UR_FVT|OwnerKonto fvt-id))
        )
        (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
        (enforce (and (ref-RPS::URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) (ref-RPS::UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id))
            "Reward link row must exist and be enabled for an unstale pass")
        (enforce (and (> chunk 0) (<= chunk INJECT-FIX-CHUNK-MAX))
            "Unstale chunk out of range — the UI sizes it by simulation, the gas meter is the real ceiling")
        (compose-capability (P|SECURE-CALLER))
    )
    )
    (defcap FVT|C>SWEEP-REVOKE (patron:string executor:string anchor-id:string)
        @doc "Protects the single-tx re-score sweep (CC_SweepRevokeAnchor). Composes P|SECURE-CALLER so SECURE is \
            \ granted for the intra-module recompute (XI_*) AND FVT's registered SECURE guard is satisfied for the \
            \ cross-module XE calls into AQP-ANK (aggregate refold + swept anchor removal) and AQP-POOL (freeze) — \
            \ FVT is in both IMPs (P|A_Define). The anchor owner (= anchored-asset owner) is enforced inside \
            \ ANK|XE>SWEEP-REVOKE; the EXECUTOR is pinned to that SAME authority here, at the FRONT of the \
            \ flow, via ANK's shared disjunction helper rather than a second copy of the rule -- the downstream \
            \ check is only reached after pools are frozen and the anchor revoked."
        @event
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-ANK::UEV_ExecutorIzAnchorAuthority executor anchor-id)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap FVT|C>COLLECT
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Collect accrued rewards for patron on one score-entity × reward DPTF. Composes P|SECURE-CALLER + P|FVT|REMOTE-GOV."
        @event
        (UEV_CollectContext patron fvt-id score-entity-type score-entity-id reward-dptf-id)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|FVT|REMOTE-GOV))
    )
    (defcap FVT|XE>SWEEP-BRACKET (anchor-id:string)
        @doc "Forward (paginated MTX|n|C_SweepRevokeAnchor defpact): authorize the sweep BRACKET — freeze/unfreeze \
            \ every affected pool and the one-shot swept-revoke of the anchor. Composes P|SECURE-CALLER so FVT's \
            \ SECURE guard is satisfied for the cross-module XE calls into AQP-POOL (freeze) and AQP-ANK (revoke); \
            \ the anchor owner (= anchored-asset owner) is enforced inside ANK|XE>SWEEP-REVOKE."
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap FVT|C>SWEEP-DRAIN (patron:string anchor-id:string chunk:integer)
        @doc "Protects a paginated re-score sweep CHUNK (CCp_SweepRecomputeChunk). The sweep was authorized + the \
            \ anchor swept-revoked at CC_SweepBegin (owner enforced in ANK|XE>SWEEP-REVOKE); a chunk only COMPLETES \
            \ the already-committed recompute under the freeze, so it re-checks the cursor is ACTIVE (honest \
            \ completion — re-enforcing owner per chunk is unnecessary; premature unfreeze is impossible because \
            \ the body unfreezes only when offset reaches total). `chunk` is bounded by the loose gas backstop \
            \ SWEEP-CHUNK-MAX — the UI sizes the real chunk by simulation, the node gas meter is the real \
            \ enforcement. Composes P|SECURE-CALLER for the intra-module recompute + cross-module XE calls."
        @event
        (enforce (UR_FVT|SweepActive anchor-id) "No active sweep for this anchor")
        (enforce (and (> chunk 0) (<= chunk SWEEP-CHUNK-MAX))
            "Sweep chunk out of range — the UI sizes it by simulation, the gas meter is the real ceiling")
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap FVT|C>UNSTALE-MY-SCORES (executor:string)
        @doc "User SELF-SERVICE deb-unstale (CC_UnstaleMyScores): the caller refreshes THEIR OWN stale scores \
            \ across the listed FVTs — settle pending at the old deb, refresh the score deb to the live Elite-DEB, \
            \ resync the FVT total-deb mirror — NON-penalized (contrast the inject's forced fix, which bills the \
            \ 2e penalty; self-service is deliberately the cheaper path so users proactively unstale). Auth = \
            \ account ownership of `executor`: you may only unstale your OWN scores, and refreshing your deb to the \
            \ live value is always safe. RENAMED FROM `patron` 2026-09-22: the parameter was the ACTOR all along -- \
            \ its ownership is what this capability enforces -- and a patron is who PAYS, which the gas station lets \
            \ be somebody else entirely. One word, two roles, and the split now has a name for each. \
            \ live value is always safe (no fund movement — pending is banked, not paid). Composes P|SECURE-CALLER \
            \ for the intra-module fix + the cross-module XE_RefreshUserScoreDeb into AQP-SCORE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
        )
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap FVT|C>TRUE-FUNGIBLE-STAKE-FLOW
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "TrueFungible stake/unstake recipe (direction=true stake, false unstake). \
            \ Composes SECURE for FVT XI_* phases. \
            \ Input validation: numbered matrix in cap body below. \
            \ Phase 1 transfer/custody/balance: AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (pool-class-ok:bool (ref-AQP::URC_StakeTrueFungiblePoolClassOk pool-id))
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) (ref-AQP::URC_PoolUnstakeAdmissionOk pool-id)))
                (dptf-pool-ok:bool (ref-AQP::URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id))
                (fvt-ready:bool (if direction (ref-RPS::URC_PoolEmployedScoresFvtStakeReady pool-id) true))
            )
            ;;1] pool-id
            ;;1a] pool-id must refer to issued AQP|T|Pool row — implicit (AQP-POOL URC_* reads pool-id key)
            ;;1b] aqp-class must be TF-stakeable (0 = LP, 1 = DPTF) — HERE
            (enforce pool-class-ok "Invalid pool-id: TF stake requires aqp-class 0 or 1")
            ;;1c] stake direction: stake-enabled + ≥1 employed score — HERE
            (enforce stake-admission-ok "Invalid pool-id: pool stake disabled or has no employed scores")
            ;;
            ;;4] dptf-id
            ;;4a] dptf-id must not be R| reserved leg — HERE
            ;;4b] dptf-id must be issued DPTF — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (TFT::C_Transfer → DPTF::UEV_id)
            ;;4c] dptf-id must match pool canonical asset (native or F| frozen) — HERE
            (enforce dptf-pool-ok "Invalid dptf-id: leg does not match pool canonical asset")
            ;;
            ;;5] amount
            ;;5a] amount must be > 0 — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (TFT::C_Transfer)
            ;;5b] amount must fit dptf-id decimal precision — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (TFT::C_Transfer → DPTF::UEV_Amount)
            ;;
            ;;6] direction
            ;;6a] bool — no id validation required
            ;;6b] unstake (direction=false): tracker + rollup balance sufficiency — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY
            ;;
            ;;7] FVT reward pipeline (phase 2.1 / 2.4 — stake direction only)
            ;;7a] every employed score: fvt-link ≠ BAR, FVT issued, ScoreEntityLink enabled, ≥1 enabled reward DPTF — HERE
            (if direction
                (enforce fvt-ready "Invalid FVT reward pipeline: employed score missing enabled FVT ScoreEntityLink or reward DPTF")
                true
            )
            ;;2] owner-id
            ;;2a] owner-id must be an activated Ouronet account — HERE
            (ref-RPS::UEV_TrueFungibleStakeOwnerAccount owner-id)
            ;;2b] tx sender must own owner-id — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (CAP_StakeOwner)
            ;;
            ;;3] beneficiary-id
            ;;3a] beneficiary must exist — HERE (DALOS::UEV_EnforceAccountExists)
            ;;3b] beneficiary must be activated standard (non-principal) account — HERE (DALOS::UEV_EnforceAccountType false)
            (ref-RPS::UEV_TrueFungibleStakeBeneficiaryAccount beneficiary-id)
            ;;
            (ref-RPS::UEV_TrueFungibleStakeNotReserved dptf-id)
            ;;
            ;;8] transfer / custody (phase 1 — not re-validated here)
            ;;8a] owner signer proof — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (CAP_StakeOwner)
            ;;8b] TFT IMC + AQP|SC_NAME vault governor — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (P|AQP|CALLER, AQP|GOV)
            ;;
            ;;9] admission-time only (not re-checked at stake)
            ;;9a] score LP denominator vs pool pair — C_AddScore admission
            ;;9b] FVT common-denominator vs member scores — C_AddScoreEntity admission
            ;;9c] aqpool-link slot assignment — C_AddScore / C_RevokeScore
            ;;
            ;;--- UrStoa canonical phases (see map above CC_TrueFungibleStakeFlow) ---
            ;; PHASE 1   1.1–1.3 AQP-POOL custody
            ;; PHASE 2   FVT::XI_RpsPreScore
            ;; PHASE 3   3.1 TF anchors; 3.2/3.3 reserved
            ;; PHASE 4   SCR::XE_ApplyTrueFungibleStakeDelta
            ;; PHASE 5   5.1 unclaimed; 5.2 checkpoint
            (compose-capability (SECURE))
        )
    )
    )
    (defcap FVT|C>ORTO-FUNGIBLE-STAKE-FLOW
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
        @doc "OrtoFungible stake/unstake recipe (direction=true stake, false unstake). \
            \ Whole-nonce DPOF::C_Transfer only — no Transmit / partial segmentation on stake. \
            \ Four phases — no ANK leg (anchors are TF/SF/NF only; DPOF stake does not move anchor balances). \
            \ Phase 1 custody: AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) (ref-AQP::URC_PoolUnstakeAdmissionOk pool-id)))
                (fvt-ready:bool (if direction (ref-RPS::URC_PoolEmployedScoresFvtStakeReady pool-id) true))
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            ;;1] pool-id — stake direction: stake-enabled + ≥1 employed score
            (enforce stake-admission-ok "Invalid pool-id: pool stake disabled or has no employed scores")
            ;;3] beneficiary-id — M5: caller-supplied and authoritative BOTH directions (self OR foreign). The real
            ;;   (owner, beneficiary) tracker row is written on stake and removed on unstake; sufficiency for that exact
            ;;   row is enforced in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY. No BAR sentinel / self-key derivation any more.
            ;;4] dpof-id — issued DPOF; pool leg match in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
            ;;5] nonces / nonce-amounts — equal positive length. L1 #16: no "amount == nonce supply" check —
            ;;   DPOF::C_Transfer moves WHOLE nonces (ignores amounts) and callers source amounts from
            ;;   UR_NoncesSupplies, so whole-nonce is a structural token-layer invariant, not a cap-level check.
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a)])
                "Invalid nonces / nonce-amounts: equal positive length required"
            )
            ;;6] direction — stake/unstake; unstake sufficiency in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
            ;;7] FVT reward pipeline — stake direction only
            (if direction
                (enforce fvt-ready "Invalid FVT reward pipeline: employed score missing enabled FVT ScoreEntityLink or reward DPTF")
                true
            )
            ;;2] owner-id — activated account; signer proof in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
            (ref-RPS::UEV_TrueFungibleStakeOwnerAccount owner-id)
            ;;3a/3b] beneficiary must exist + be a standard account — BOTH directions (mirror TF flow cap).
            (ref-RPS::UEV_TrueFungibleStakeBeneficiaryAccount beneficiary-id)
            ;;--- UrStoa canonical phases (no 1.3 / 3.x on OF — reserved no-op) ---
            ;; PHASE 1   1.1–1.2 AQP-POOL; 1.3 no-op
            ;; PHASE 2   FVT::XI_RpsPreScore
            ;; PHASE 3   3.1–3.3 no-op
            ;; PHASE 4   SCR::XE_ApplyOrtoFungibleStakeDelta
            ;; PHASE 5   5.1 unclaimed; 5.2 checkpoint
            (compose-capability (SECURE))
        )
    )
    )
    (defcap FVT|C>COLLECTABLE-STAKE-FLOW
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
        @doc "DPDC collectable stake/unstake recipe. son=true DPSF (class-3 pool); son=false DPNF (class-4 pool). \
            \ Phase 1 custody: AQP|XE>COLLECTABLE-POOL-CUSTODY."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) (ref-AQP::URC_PoolUnstakeAdmissionOk pool-id)))
                (fvt-ready:bool (if direction (ref-RPS::URC_PoolEmployedScoresFvtStakeReady pool-id) true))
                (class-ok:bool (ref-AQP::URC_StakeCollectablePoolClassOk pool-id son))
                (collectable-ok:bool (ref-AQP::URC_StakeCollectableMatchesPool pool-id collectable-id))
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            (enforce stake-admission-ok "Invalid pool-id: pool stake disabled or has no employed scores")
            (enforce class-ok "Invalid pool-id: collectable son does not match pool aqp-class")
            (enforce collectable-ok "Invalid collectable-id: leg does not match pool canonical asset")
            ;; M5: beneficiary-id caller-supplied and authoritative BOTH directions (self OR foreign). The real
            ;; (owner, beneficiary) tracker + Ben rollup rows are written on stake and removed on unstake; sufficiency
            ;; for that exact row is enforced in AQP|XE>COLLECTABLE-POOL-CUSTODY. No BAR sentinel / self-key derivation.
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a)])
                "Invalid nonces / nonce-amounts: equal positive length required"
            )
            (if direction
                (enforce fvt-ready "Invalid FVT reward pipeline: employed score missing enabled FVT ScoreEntityLink or reward DPTF")
                true
            )
            (ref-RPS::UEV_TrueFungibleStakeOwnerAccount owner-id)
            ;; beneficiary must exist + be a standard account — BOTH directions (mirror TF flow cap).
            (ref-RPS::UEV_TrueFungibleStakeBeneficiaryAccount beneficiary-id)
            (compose-capability (SECURE))
        )
    )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
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
    ;;
    ;; Early UDC: constructors required before UR_* with-default-read default objects.
    (defun UDC_FVT|Schema:object{AcquisitionSchemasV1.FVT|Schema}
        (
            can-upgrade:bool
            can-change-owner:bool
            common-denominator:string
            oracle-on:bool
            fvt-id:string
        )
        @doc "Core constructor for object{AcquisitionSchemasV1.FVT|Schema} (identity/config). oracle-on (DSA toggle) passes through. \
            \ owner-konto/mosaic/membership-mode/split-mode moved to FVT|RewardAggregate (#75 B' Stage 2b)."
        {"can-upgrade"              : can-upgrade
        ,"can-change-owner"         : can-change-owner
        ,"common-denominator"       : common-denominator
        ,"oracle-on"                : oracle-on
        ,"fvt-id"                   : fvt-id}
    )
    (defun UDC_FVT|RewardAggregate:object{AcquisitionSchemasV1.FVT|RewardAggregate}
        (
            fvt-class:integer
            owner-konto:string
            mosaic:bool
            membership-mode:string
            split-mode:string
            total-ghost-tvl-weight:decimal
            total-base-score:decimal
            total-boosted-score:decimal
            total-deb-score:decimal
            total-nzs-count:integer
            enabled-reward-count:integer
            member-link-count:integer
            fvt-id:string
        )
        @doc "Constructor for object{AcquisitionSchemasV1.FVT|RewardAggregate} — fvt-class + entity config the reward engine owns + reward aggregates (#75 B' Stage 1/2)."
        {"fvt-class"                : fvt-class
        ,"owner-konto"              : owner-konto
        ,"mosaic"                   : mosaic
        ,"membership-mode"          : membership-mode
        ,"split-mode"               : split-mode
        ,"total-ghost-tvl-weight"   : total-ghost-tvl-weight
        ,"total-base-score"         : total-base-score
        ,"total-boosted-score"      : total-boosted-score
        ,"total-deb-score"          : total-deb-score
        ,"total-nzs-count"          : total-nzs-count
        ,"enabled-reward-count"     : enabled-reward-count
        ,"member-link-count"        : member-link-count
        ,"fvt-id"                   : fvt-id}
    )
    ;; --- Phase 2.1 settle · ephemeral (no deftable / no UR) ---
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    (defun UCk_ScoreEntityLink:string (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UCk_ScoreEntityLink fvt-id score-entity-id)
    )
    (defun UCk_RpsGlobal:string (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UCk_RpsGlobal fvt-id dptf-id)
    )
    (defun UCk_RpsMember:string (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UCk_RpsMember fvt-id score-entity-id dptf-id)
    )
    (defun UCk_RpsUser:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UCk_RpsUser user-id fvt-id score-entity-id dptf-id)
    )
    (defun UC_EmptyOc:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "Empty OutputCumulator for write-only inject/collect phase slots."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;; [URCi]   multi-leg STAKE/UNSTAKE flow ifp readers — relocated from AQP-INFO (byte-identical ifp sums).
    ;;   Mirror CC_*StakeFlow leg-for-leg; every leg gated by the virtual-gas toggle so toggle-on -> 0.
    ;;   Tier gates below reproduce the UsagePrice tier behind URC_IsVirtualGasZero);
    ;;   AQP-VCT's vacate readers reach them + the two score-delta sums cross-module. Leg map:
    ;;   IGNIS-PRICING/DECISION-LOG-DETAILED.md
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    ;; FVT|T|MemberVault  Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>  (Tier-1 dust sweep, M1/#10)
    ;;
    ;;
    ;;
    ;; Reads follow schema order: (1) FVT|Schema (2) ScoreEntityLink (3) MultipletFamily (4) RPS|Global (5) RPS|Member (6) RPS|User
    ;;
    (defun UR_FVT|Fvt:object{AcquisitionSchemasV1.FVT|Schema} (fvt-id:string)
        @doc "Reads full FVT definition row from FVT|T."
        (read FVT|T fvt-id)
    )
    (defun UR_FVT|CanUpgrade:bool (fvt-id:string)
        @doc "Reads can-upgrade from FVT row."
        (at "can-upgrade" (read FVT|T fvt-id ["can-upgrade"]))
    )
    (defun UR_FVT|CanChangeOwner:bool (fvt-id:string)
        @doc "Reads can-change-owner from FVT row."
        (at "can-change-owner" (read FVT|T fvt-id ["can-change-owner"]))
    )
    (defun UR_FVT|VacateFrozen:bool (fvt-id:string)
        @doc "True when the FVT is frozen for a pool vacate (blocks collect + inject). Default false (unset)."
        (with-default-read FVT|T|VacateFreeze fvt-id
            {"frozen": false}
            {"frozen":= frozen}
            frozen
        )
    )
    (defun UR_FVT|SweepProgress:object{AcquisitionSchemasV1.FVT|SweepProgress} (anchor-id:string)
        @doc "The paginated re-score sweep cursor for anchor-id; defaults to an inactive empty cursor when no \
            \ sweep is open. Module-only (returns a module schema)."
        (with-default-read FVT|T|SweepProgress anchor-id
            {"total": 0, "offset": 0, "active": false}
            {"total" := t, "offset" := o, "active" := a}
            {"total": t, "offset": o, "active": a}
        )
    )
    (defun UR_FVT|SweepActive:bool (anchor-id:string)
        @doc "True while a paginated re-score sweep is open for anchor-id (gates CCp_SweepRecomputeChunk; blocks a \
            \ double CC_SweepBegin)."
        (at "active" (UR_FVT|SweepProgress anchor-id))
    )
    (defun UR_FVT|CommonDenominator:string (fvt-id:string)
        @doc "Reads common-denominator from FVT row."
        (at "common-denominator" (read FVT|T fvt-id ["common-denominator"]))
    )
    (defun UR_FVT|OracleOn:bool (fvt-id:string)
        @doc "DSA: does the node/uptime oracle govern capture on this FVT? false ⇒ capture = units, uptime ≡ 1000, no expiry."
        (at "oracle-on" (read FVT|T fvt-id ["oracle-on"]))
    )
    (defun UR_FVT|FvtId:string (fvt-id:string)
        @doc "Reads fvt-id field from FVT row."
        (at "fvt-id" (read FVT|T fvt-id ["fvt-id"]))
    )
    ;;
    ;;
    ;;
    ;;
    ;;
    ;;
    ;; --- Cap / stake-flow validation (cheap bools; no keys/select) ---
    ;; URH_FvtScoreEntityLinkKeysForFvt ((keys FVT|T|ScoreEntityLink) scan) RETIRED — M2/#11. Its only caller was
    ;; the vault inject-denominator scan, now replaced by the incrementally-maintained total-deb-score mirror.
    ;; URC_FvtVaultDebDenominator (vault inject divisor via keys-scan) RETIRED — M2/#11. The divisor is now the
    ;; maintained total-deb-score mirror (incrementally kept at stake/toggle/add, point-read at inject). No scan.
    (defun URC_MaxStreamLanes:integer (account:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_MaxStreamLanes account)
    )
    (defun URC_ScoreClassMatchesFvtClass:bool (fvt-class:integer score-class:integer)
        @doc "Admission rule: farm↔LP(0), vault↔TF/OF(1/2), treasury↔SF/NF(3/4). \
            \ Score classes are 0=LP 1=DPTF 2=DPOF 3=DPSF 4=DPNF; FVT classes 0=Farm \
            \ 1=Vault 2=Treasury. CORRECTED 2026-09-19 (owner ruling): this used to read \
            \ vault↔1/3/4 and treasury↔2, i.e. it admitted COLLECTABLES into the vault and \
            \ sent ORTOFUNGIBLES to the treasury -- the two swapped. It disagreed with \
            \ URC_TripletCategoryMatchesFvtClass (VAULT_TF↔1, TREASURY_SF_NF↔2), which was \
            \ right, and nothing caught it because AQP-BOOT Step8 issued its four entities \
            \ NAMED Treasury at class 1, so the broken rule was exactly what let them work."
        (if (= fvt-class 0)
            (= score-class 0)
            (if (= fvt-class 1)
                (or (= score-class 1) (= score-class 2))
                (if (= fvt-class 2)
                    (or (= score-class 3) (= score-class 4))
                    false
                )
            )
        )
    )
    (defun URC_ResolveScoreEntitySwpair:string
        (score-entity-type:integer score-entity-id:string fvt-class:integer)
        @doc "Farm class-0: SWP pair from native LP (score) or silver-score pool (triplet); vault/treasury |."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-SWP:module{SwapperV4} SWP)
                (sentinel:string "|")
                (pool-score-id:string
                    (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id)
                        score-entity-id
                    )
                )
                (pool-id:string (ref-SCR::UR_SCR|ScoreAqpoolLink pool-score-id))
                (asset-id:string (ref-AQP::UR_AQP|PoolAssetId pool-id))
                (aqp-class:integer (ref-AQP::UR_AQP|PoolAqpClass pool-id))
            )
            (if (= fvt-class 0)
                (if (= aqp-class 0)
                    (ref-SWP::UR_GetLpSwpair asset-id)
                    sentinel
                )
                sentinel
            )
        )
    )
    ;; NOTE (audit LP redesign): URC_MemberStakedStoaValue above is the correct Level-2 primitive (staked value),
    ;; but it CANNOT be cached via this resolver + the ghost-TVL sync — staked value is base-dependent and the
    ;; sync runs at stake phase 2.1 (before the base updates at phase 4), while the inject defcap checks the
    ;; stale cached S. It must be computed FRESH at inject (split-at-inject, Stage 2). This resolver stays on the
    ;; old whole-pool value until then, so the accumulator/defcap keep working.
    (defun URC_ResolvePoolScoreId:string (score-entity-type:integer score-entity-id:string)
        @doc "Pool id for collect/settle SCR reads: score pool or triplet silver pool."
        (let 
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (if (= score-entity-type CT_SCORE_ENTITY_SCORE)
                (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)
                (ref-SCR::UR_SCR|ScoreAqpoolLink
                    (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id)
                )
            )
        )
    )
    ;; --- Phase 2.1 settle · lists, plans, IGNIS ---
    ;; --- Phase 2.35 unclaimed · IGNIS ---
    ;; --- Phase 2.4 checkpoint · IGNIS ---
    ;; --- Shared deb-staleness SCAN predicates (M3 #12 — scan + fix use the SAME predicate, cannot diverge) ---
    ;; FVT|T|AgencyFee  Key = <FVT-ID> | <Score-Entity-ID>  (DSA operator-fee mirror; Phase 5b)
    ;; FVT|T|QualitySplit  Key = <FVT-ID> | <DPTF-ID>  (DSA Round B heterogeneous split matrix)
    ;; [URH] heavy-read
    ;;
    ;; --- FVT|T|RPS|Global selects (stake hot path: one batched select via URH_FVT|SettleFvtRewardBundle) ---
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    (defun URCi_Issue:object{IgnisCollectorV3.OutputCumulator} (owner-konto:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_Issue" "issue-fvt")
                owner-konto (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_IssueStoa:decimal ()
        @doc "STOA cost for FVT-issue: the deterrence expressed in DOLLARS, converted at the live \
            \ STOA price by UC_StoaPrice (issue-fvt = $10 => 100 STOA). Previously read the raw \
            \ 'smart' usage price (0.02), a pre-rehaul STOA amount that was never \
            \ dollar-denominated and so ignored the peg entirely."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UC_StoaPrice "issue-fvt")
        ))
    (defun URCi_IssueMultipletFamily:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|C_IssueMultipletFamily" "issue-multiplet")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_UnstaleMyScores:object{IgnisCollectorV3.OutputCumulator} (patron:string output:[string])
        @doc "GAS|UNSTALE gas leg (konto = patron); exec concats it with the per-fvt unstale walk."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-FVT|CC_UnstaleMyScores" "unstale")
                patron (r::URC_IsVirtualGasZero) output)
        ))
    ;; [URCi]   DSA royalty-disposal CUSTODY-move ifp readers — read-only mirror of the XE_*Royalty custody legs
    ;;   (the DSA A_*Royalty exec concats URCi_*Royalty gas leg with the FVT XE_*Royalty custody cumulator).
    ;;   The disposal amount/token are reconstructed from the live royalty pool balance + IGNIS-normalize decision.
    ;; [URCi/URC]   CC_Collect FULL-cost readers — read-only mirror of the reward-payout leg (XI_TransferRewardDptfFromVault:
    ;;   plain single TFT transfer, or a MULTIPLET_BASE triplet Coil/Curl ladder, homogeneous or heterogeneous) + the
    ;;   Phase-7 forced-fix penalty + GAS|COLLECT. The payout is derived on the CURRENT (pre-drip) claimable state —
    ;;   exact for un-streamed / settled lanes (see URCi_CollectFull residual note).
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_ExecutorIzFvtOwner (executor:string fvt-id:string)
        @doc "Enforces that <executor> IS the FVT's owner konto -- the SAME value every UEV_*Context \
            \ helper resolves and key-checks, read through the same RPS reader so the two cannot \
            \ disagree. It does NOT replace those gates: they prove the signer holds the owner's \
            \ key, this proves the named actor IS that owner. Both are needed -- a sovereign FVT's \
            \ owner can be a SMART account whose key a human holds, so the key check passes for an \
            \ account the caller never names (see 01_ANK, 2026-09-20)."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (enforce (= executor (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (format "Executor {} is not the owner of FVT {} (owner is {})"
                    [executor fvt-id (ref-RPS::UR_FVT|OwnerKonto fvt-id)]))
        )
    )
    (defun UEV_SetMosaicContext (fvt-id:string mosaic:bool)
        @doc "C_SetMosaic: owner, can-upgrade, zero member-link-count."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (can-upgrade:bool (UR_FVT|CanUpgrade fvt-id))
            )
            ;;PRODUCED-TRIAGED (_eagerlet --produced, 2026-09-16): <can-upgrade> comes from a hard
            ;;read, so for an FVT that does not exist the raw table error fires before this line.
            ;;Left as is: this is a STATE claim about an FVT that exists. Telling a caller who named
            ;;a non-existent FVT that it "requires can-upgrade true" asserts the entity is real and
            ;;merely mis-configured, which is worse than saying the row was not found. Same
            ;;disposition as SWPLC's UEV_AddChilledLiquidity.
            (enforce can-upgrade "FVT mosaic update requires can-upgrade true")
            (enforce
                (= (ref-RPS::UR_FVT|MemberLinkCount fvt-id) 0)
                "Cannot change mosaic while ScoreEntityLink rows exist"
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
        )
    )
    )
    (defun UEV_AddScoreEntityContext
        (fvt-id:string score-entity-type:integer score-entity-id:string swpair:string ghost-weight:decimal)
        @doc "C_AddScoreEntity unified admission: type 1 = score rules; type 3 = triplet rules + SCR fvt-links."
        (if (= score-entity-type CT_SCORE_ENTITY_SCORE)
            (UEV_AddScoreEntityScoreContext fvt-id score-entity-id swpair ghost-weight)
            (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                (UEV_AddScoreEntityTripletContext fvt-id score-entity-id swpair ghost-weight)
                (enforce false "score-entity-type must be 1 (score) or 3 (triplet)")
            )
        )
    )
    (defun UEV_AddScoreEntityScoreContext
        (fvt-id:string score-id:string swpair:string ghost-weight:decimal)
        @doc "Validates the context for linking a SCORE entity to <fvt-id>: score-owner matches FVT-owner, \
            \ membership mode admits scores (or mosaic), no pre-existing link, score class matches FVT class, \
            \ correct <swpair>, and the class-0 farm rule (lp-denominator = common-denominator + positive \
            \ ghost-weight) vs the vault/treasury rule (swpair | + zero ghost-weight). Enforces FVT-owner ownership."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (fvt-class:integer (ref-RPS::UR_FVT|FvtClass fvt-id))
                (score-owner:string (ref-SCR::UR_SCR|ScoreOwnerKonto score-id))
                (score-class:integer (ref-SCR::UR_SCR|ScoreClass score-id))
                (fvt-link:string (ref-SCR::UR_SCR|ScoreFvtLink score-id))
                (aqpool-link:string (ref-SCR::UR_SCR|ScoreAqpoolLink score-id))
                (lp-denom:string (ref-SCR::UR_SCR|ScoreLpDenominator score-id))
                (common-denom:string (UR_FVT|CommonDenominator fvt-id))
                (expected-swpair:string (URC_ResolveScoreEntitySwpair CT_SCORE_ENTITY_SCORE score-id fvt-class))
            )
            (enforce (= score-owner fvt-owner) "Score owner must match FVT owner")
            (enforce
                (or (ref-RPS::UR_FVT|Mosaic fvt-id)
                    (let
                        (
                            (mode:string (ref-RPS::UR_FVT|MembershipMode fvt-id))
                        )
                        (or (= mode CT_MEMBERSHIP_MODE_BAR) (= mode CT_MEMBERSHIP_MODE_SCORE))
                    ))
                "Non-mosaic FVT locked to score membership only")
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
                    [(not (ref-RPS::URC_FvtScoreEntityLinkRowExists fvt-id score-id))
                     (= fvt-link BAR) (!= aqpool-link BAR)
                     (URC_ScoreClassMatchesFvtClass fvt-class score-class)
                     (= swpair expected-swpair)])
                "Invalid AddScoreEntity score: row exists, links, class, or swpair mismatch")
            (if (= fvt-class 0)
                (enforce (fold (and) true [(= lp-denom common-denom) (> ghost-weight 0.0)])
                    "Farm score: lp-denominator and ghost weight required")
                (enforce (fold (and) true [(= swpair "|") (= ghost-weight 0.0)])
                    "Vault/Treasury score: swpair | and zero ghost weight"))
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
    )
    )
    (defun UEV_AddScoreEntityTripletContext
        (fvt-id:string triplet-id:string swpair:string ghost-weight:decimal)
        @doc "Validates the context for linking a TRIPLET entity to <fvt-id>: triplet is issued with a category \
            \ matching the FVT class, membership mode admits the triplet kind (true vs standard, or mosaic), \
            \ silver-owner matches FVT-owner, no pre-existing link, silver has an aqpool link, all three \
            \ (bronze/silver/golden) score fvt-links are BAR, correct <swpair>, and the class-0 farm vs \
            \ vault/treasury weight rule. Enforces FVT-owner ownership."
        ;;SHADOWED-GUARD FIX: "Triplet must be issued in AQP-SCORE" used to be the first enforce
        ;;INSIDE the inner let, under FIVE hard reads of SCR|T|Triplet keyed by <triplet-id>
        ;;(bronze/silver/golden score ids, category, true-triplet). Pact evaluates let bindings
        ;;eagerly, so a triplet that does not exist aborted on "row not found" and the guard was
        ;;unreachable for EVERY input. URC_TripletExists is a with-default-read written precisely
        ;;to answer for a missing row -- it simply never got the chance. Hoisted here.
        (let ((ref-SCR:module{AcquisitionScoresV2} AQP-SCORE))
            (enforce (ref-SCR::URC_TripletExists triplet-id) "Triplet must be issued in AQP-SCORE"))
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (fvt-class:integer (ref-RPS::UR_FVT|FvtClass fvt-id))
                (bronze-id:string (ref-SCR::UR_SCR|TripletBronzeScoreId triplet-id))
                (silver-id:string (ref-SCR::UR_SCR|TripletSilverScoreId triplet-id))
                (golden-id:string (ref-SCR::UR_SCR|TripletGoldenScoreId triplet-id))
                (triplet-cat:string (ref-SCR::UR_SCR|TripletCategory triplet-id))
                (is-true-triplet:bool (ref-SCR::UR_SCR|TripletTrueTriplet triplet-id))
                (silver-owner:string (ref-SCR::UR_SCR|ScoreOwnerKonto silver-id))
                (silver-aqpool:string (ref-SCR::UR_SCR|ScoreAqpoolLink silver-id))
                (common-denom:string (UR_FVT|CommonDenominator fvt-id))
                (silver-lp-denom:string (ref-SCR::UR_SCR|ScoreLpDenominator silver-id))
                (expected-swpair:string (URC_ResolveScoreEntitySwpair CT_SCORE_ENTITY_TRIPLET triplet-id fvt-class))
            )
            ;;(the existence check now runs ABOVE this let -- see the note on the defun.)
            (enforce (ref-SCR::URC_TripletCategoryMatchesFvtClass triplet-cat fvt-class) "Triplet category must match FVT class")
            ;;FIXED 2026-09-12, owner-ruled. This was a THREE-argument `or`, and Pact's `or` is
            ;;BINARY -- it raised `Attempted to apply a closure to too many arguments` instead of
            ;;evaluating. The outer `(or mosaic ...)` SHORT-CIRCUITS and every FVT built so far is
            ;;mosaic, so the broken branch had never been reached and the fault was invisible.
            ;;It was not a mute message: the ADMITTING modes failed identically to the refusing one,
            ;;so no NON-MOSAIC FVT could admit a triplet in ANY mode.
            ;;Owner ruling: "triple or or multiple or is not allowed. instead use fold construction
            ;;using or over false." -- which is also the `or` analogue of the 3+ boolean rule already
            ;;in CLAUDE.md for `and`. `fold` is not short-circuiting, but all three disjuncts here are
            ;;comparisons on already-bound locals, so evaluating all three is free.
            ;;The legal 2-argument twin is UEV_AddScoreEntityScoreContext above, which always worked.
            ;;Pinned by REPL/Kursan/dsa-grand-tour.repl <<GT-16>> section 03, which now drives all
            ;;three modes against a non-mosaic vault. 2026-09-12-binary-or-arity-break.md
            (enforce
                (or (ref-RPS::UR_FVT|Mosaic fvt-id)
                    (let
                        (
                            (mode:string (ref-RPS::UR_FVT|MembershipMode fvt-id))
                        )
                        (fold (or) false
                            [(= mode CT_MEMBERSHIP_MODE_BAR)
                             (and (= mode CT_MEMBERSHIP_MODE_TRUE_TRIPLET) is-true-triplet)
                             (and (= mode CT_MEMBERSHIP_MODE_STANDARD_TRIPLET) (not is-true-triplet))])
                    ))
                "Non-mosaic FVT membership mode mismatch for triplet admission")
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
                    [(= silver-owner fvt-owner)
                     (not (ref-RPS::URC_FvtScoreEntityLinkRowExists fvt-id triplet-id))
                     (!= silver-aqpool BAR) (= swpair expected-swpair)
                     (= (ref-SCR::UR_SCR|ScoreFvtLink bronze-id) BAR)
                     (= (ref-SCR::UR_SCR|ScoreFvtLink silver-id) BAR)
                     (= (ref-SCR::UR_SCR|ScoreFvtLink golden-id) BAR)])
                "Invalid AddScoreEntity triplet: row exists, links, or swpair mismatch")
            (if (= fvt-class 0)
                (enforce (fold (and) true [(= silver-lp-denom common-denom) (> ghost-weight 0.0)])
                    "Farm triplet: lp-denominator and ghost weight required")
                (enforce (fold (and) true [(= swpair "|") (= ghost-weight 0.0)])
                    "Vault/Treasury triplet: swpair | and zero ghost weight"))
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
    )
    )
    (defun UEV_IssueMultipletFamilyContext
        (
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "C_IssueMultipletFamily: distinct issued DPTF ids, distinct ATS pairs; ATS ladder must match Coil/Curl chain."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (enforce
                (ref-DPTF::URC_IzRBTg ats-0-1-id token-1-id)
                "MultipletFamily token-1 must be reward-bearing on first ATS pair (Coil output)"
            )
            (enforce
                (ref-DPTF::URC_IzRBTg ats-1-2-id token-2-id)
                "MultipletFamily token-2 must be reward-bearing on second ATS pair (Curl output)"
            )
            (enforce
                (fold (and) true
                    [
                        (!= token-0-id token-1-id)
                        (!= token-1-id token-2-id)
                        (!= token-0-id token-2-id)
                        (!= ats-0-1-id BAR)
                        (!= ats-1-2-id BAR)
                        (!= ats-0-1-id ats-1-2-id)
                    ]
                )
                "Invalid MultipletFamily issue: tokens and ATS pairs must be distinct"
            )
            (ref-DPTF::UEV_id token-0-id)
            (ref-DPTF::UEV_id token-1-id)
            (ref-DPTF::UEV_id token-2-id)
            (ref-ATS::UEV_id ats-0-1-id)
            (ref-ATS::UEV_id ats-1-2-id)
            (ref-ATS::UEV_RewardTokenExistance ats-0-1-id token-0-id true)
            (ref-ATS::UEV_RewardTokenExistance ats-1-2-id token-1-id true)
        )
    )
    (defun UEV_InjectContext
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "C_Inject: patron account, issued reward DPTF, reward-enabled row, positive amount. \
            \ Escrow-on-empty: the inject denominator is NO LONGER required to be positive — a zero-denominator \
            \ inject (no stakers) is accepted and its amount is held as zombie-rewards (limbo), to be distributed \
            \ by the next non-zero inject. The zero/non-zero split is handled in XI_FvtInjectCore (farm S and \
            \ vault deb-sum are both computed there); this defcap only validates the token + amount + row."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
            (enforce (> amount 0.0) "Inject amount must be positive")
            (enforce (ref-RPS::URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (enforce (ref-RPS::UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id) "Reward token is disabled for inject")
            (ref-DALOS::UEV_EnforceAccountExists patron)
            (ref-DPTF::UEV_id reward-dptf-id)
            (ref-DPTF::UEV_Amount reward-dptf-id amount)
        )
    )
    )
    (defun UEV_StreamParams:bool
        (reward-dptf-id:string amount:decimal duration:integer)
        @doc "Count-INDEPENDENT part of the streamed-inject guard (defcap-safe — no post-drip state): duration in \
            \ [STREAM_MIN_DURATION, STREAM_MAX_DURATION] and a minimum release rate amount/duration >= \
            \ STREAM_MIN_UPS * 10^(-reward-decimals) (precision-normalized via exact integer pow, so the floor is \
            \ uniform across token decimals; 1e-5/sec for a 12-dp token). The count-DEPENDENT slot-cap check lives \
            \ in XIv_FvtAddStream AFTER the drip — a finished stream frees its slot only once the drip prunes it."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (reward-dec:integer (ref-DPTF::UR_Decimals reward-dptf-id))
                (min-rate:decimal (/ (dec STREAM_MIN_UPS) (dec (^ 10 reward-dec))))
                (rate:decimal (/ amount (dec duration)))
            )
            (enforce
                (fold (and) true
                    [ (>= duration STREAM_MIN_DURATION)
                      (<= duration STREAM_MAX_DURATION)
                      (>= rate min-rate) ])
                "FVT|Stream: duration must be 1h..365d and rate >= STREAM_MIN_UPS/sec (raise amount or shorten duration)")
        )
    )
    (defun UEV_CollectContext
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "CC_Collect: dispatch by score-entity-type; MULTIPLET_BASE triplet collect requires matching global."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (reward-kind:string (ref-RPS::UR_FVT-RG|RewardKind fvt-id reward-dptf-id))
                ;; the score's employing pool (triplet ⇒ silver leg's pool — mirrors CC_Collect's resolution)
                (pool-id:string
                    (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                        (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)))
            )
            ;; sweep D3: collect is frozen while a re-score sweep runs on the pool (the aggregate-promile is in
            ;; flux; a mid-sweep collect on an unswept holder would refresh deb against a stale-high aggregate).
            (enforce (not (ref-AQP::UR_AQP|PoolSweepInProgress pool-id))
                "Collect is frozen while a re-score sweep is in progress on this pool")
            (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
            (enforce (ref-RPS::URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (enforce (ref-RPS::UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id) "Reward token is disabled for collect")
            (enforce (ref-RPS::URC_FvtScoreEntityLinkRowExists fvt-id score-entity-id) "ScoreEntityLink row must exist")
            (enforce (ref-RPS::UR_FVT-SEL|Enabled fvt-id score-entity-id) "ScoreEntityLink must be enabled for collect")
            (enforce (= score-entity-type (ref-RPS::UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)) "score-entity-type mismatch")
            (if (and (= reward-kind CT_REWARD_KIND_MULTIPLET_BASE) (= score-entity-type CT_SCORE_ENTITY_TRIPLET))
                (enforce
                    (fold (and) true
                        [
                            (!= (ref-RPS::UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id) BAR)
                            (ref-RPS::URC_MultipletFamilyExists (ref-RPS::UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                            (ref-RPS::UR_FVT-MF|Active (ref-RPS::UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                        ]
                    )
                    "MULTIPLET_BASE collect requires active MultipletFamily on global row"
                )
                true
            )
            (ref-DALOS::CAP_EnforceAccountOwnership patron)
            (ref-DPTF::UEV_id reward-dptf-id)
        )
    )
    )
    (defun UEV_SetCommonDenominatorContext (fvt-id:string common-denominator:string)
        @doc "C_SetCommonDenominator: farm only, can-upgrade, no ScoreEntityLinks yet, valid DPTF id."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (can-upgrade:bool (UR_FVT|CanUpgrade fvt-id))
                (fvt-class:integer (ref-RPS::UR_FVT|FvtClass fvt-id))
            )
            (enforce can-upgrade "SetCommonDenominator requires can-upgrade true")
            (enforce (= fvt-class 0) "SetCommonDenominator applies to farm (class 0) FVT only")
            (enforce
                (not (ref-RPS::URC_FvtHasScoreEntityLinks fvt-id))
                "Cannot change common-denominator after ScoreEntityLink rows exist"
            )
            (enforce
                (fold (and) true
                    [
                        (!= common-denominator BAR)
                        (!= common-denominator "|")
                    ]
                )
                "common-denominator must be a full native DPTF id"
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (ref-DPTF::UEV_id common-denominator)
        )
    )
    )
    ;;{5.5}  Write [W]
    ;; [W]   write
    ;; Five blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    (defun WI_Fvt:string
        (fvt-id:string row:object{AcquisitionSchemasV1.FVT|Schema})
        @doc "Insert FVT|T full row (issue only)."
        (require-capability (SECURE))
        (insert FVT|T fvt-id row)
    )
    ;; WW_Fvt — not used: issue path is WI_Fvt; other paths use WU_*.
    ;; WU_Fvt|FvtClass — not mutable [.]
    (defun WU2_Fvt|Control:string
        (fvt-id:string can-upgrade:bool can-change-owner:bool)
        @doc "Update can-upgrade and can-change-owner on FVT|T."
        (require-capability (SECURE))
        (update FVT|T fvt-id
            {"can-upgrade": can-upgrade, "can-change-owner": can-change-owner}
        )
    )
    ;; WU_Fvt|CanUpgrade — not used: mutates via WU2_Fvt|Control.
    ;; WU_Fvt|CanChangeOwner — not used: mutates via WU2_Fvt|Control.
    (defun WU_Fvt|CommonDenominator:string
        (fvt-id:string common-denominator:string)
        @doc "Update common-denominator on FVT|T."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"common-denominator": common-denominator})
    )
    ;; WU_Fvt|TotalBaseScore — not yet written in this module.
    ;; WU_Fvt|TotalBoostedScore — not yet written in this module.
    ;; WU_Fvt|TotalNzsCount — not yet written in this module.
    (defun WU_FvtVacateFreeze:string (fvt-id:string frozen:bool)
        @doc "Set the FVT vacate-frozen flag on FVT|T|VacateFreeze (write = upsert; reader defaults false)."
        (require-capability (SECURE))
        (write FVT|T|VacateFreeze fvt-id {"frozen": frozen})
    )
    (defun WU_FvtSweepProgress:string (anchor-id:string total:integer offset:integer active:bool)
        @doc "Upsert the paginated re-score sweep cursor on FVT|T|SweepProgress (write = upsert; reader defaults \
            \ to an inactive empty cursor). SECURE."
        (require-capability (SECURE))
        (write FVT|T|SweepProgress anchor-id {"total": total, "offset": offset, "active": active})
    )
    (defun WU_Fvt|OracleOn:string
        (fvt-id:string oracle-on:bool)
        @doc "DSA: toggle the node/uptime oracle on this FVT."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"oracle-on": oracle-on})
    )
    ;; WU_Fvt|FvtId — select key; WU not needed.
    ;;
    ;; FVT|T|MemberUserWeight  Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>
    ;;
    ;;
    ;;
    ;;
    ;;{5.6}  Aux/X
    ;; [XI]
    ;;
    ;;
    ;;1]INJECT Rewards (farm: require total-ghost-tvl-weight S > 0)
    ;;  1a] Tier-2: current-rps (G) += reward-amount / S
    ;;  1b] Update <available-rewards> = (+ <available-rewards> <reward-amount>)
    ;;  1c] Update <unclaimed-count> = <nzs-count> (aggregate across members; semantics TBD)
    ;;
    ;;2]STAKE / UNSTAKE (per beneficiary, per employed member score, per reward DPTF)
    ;;  UrStoa XI_URV|UpdatePendingRewards ≡ phase 2.1 only (bank pending at OLD indices).
    ;;  LP vs non-LP: phase 1 custody + phase 2.3 SCORE dispatch differ by score-class;
    ;;  phase 2.1 settle is the same Tier-1 deb×(L_i−last_rps) for every employed score with fvt-link≠BAR.
    ;;  Tier-2 (farm class-0 FVT only) splits injections across member scores by ghost TVL weight W_i.
    ;;  2.0] Ensure FVT|T|RPS|User row (UrStoa: insert user with last-rps=current index if absent)
    ;;  2a] Tier-2: farm class-0 earned = floor(W_i×(G−g_i), 48); vault/treasury earned = floor(D_i×(G−g_i), 48);
    ;;       if total-deb > 0: L_i += floor(earned/total-deb, 48); flush pending-member-rewards into L_i when deb appears;
    ;;       else pending-member-rewards += floor(earned, reward DPTF decimals); g_i := G
    ;;  2b] Tier-1: pending-rewards += deb_user×(L_i−last_rps_user) — read deb_user from SCORE (OLD, pre-2.3)
    ;;       do NOT advance last-rps here (UrStoa UpdateUserRPS ≡ phase 2.4 XI_CheckpointStakeRps)
    ;;  2c] SCORE stake path updates user deb / score totals — phase 2.3 XE_ApplyTrueFungibleStakeDelta
    ;;  2d] nz / unclaimed bookkeeping — phase 2.35 XI_BookStakeUnclaimedCounts (after SCORE; UrStoa UpdateNZS is in SCORE nzs-count)
    ;;  2e] last-rps_user := L_i — phase 2.4 only (after NEW deb is known if needed)
    ;;
    ;;3]UNSTAKE — same settle order as STAKE (2a then 2b before mutating deb)
    ;;
    ;;4]COLLECT
    ;;  4a] Repeat 2a (member Tier-2 settle) then 2b with current deb for reward line
    ;;  4b] Decrement available-rewards by payout
    ;;  4c] Dust / last-claimer rule on available-rewards vs pending
    ;;  4d-4f] pending and unclaimed-count updates; last-rps_user := L_i
    ;;
    ;;5]SWP / AQP — SWP|Pairs.stoa-value updated by TS01 swap/liquidity txs (no FVT call from SWP).
    ;;  FVT lazy-sync on reward entry (C_AddScoreEntity, C_Inject, XI_SettleStakePendingRewards phase-2 entry, CC_Collect):
    ;;  read SWP::UR_StoaValue via ScoreEntityLink.swpair; if W_live ≠ W_cached settle Tier-2 at old W_i; write W_i; fix S.
    ;;
    ;; --- Block L · Lifecycle XI (C_Issue / C_AddScoreEntity / …) ---
    ;;   C_Issue / C_RotateOwnership / C_Control / C_SetCommonDenominator
    ;;     └ XI_IssueFvt / XI_RotateOwnership / XI_Control / XI_SetCommonDenominator
    ;;   C_AddScoreEntity / C_ToggleScoreEntityLink
    ;;     └ XI_AddScoreEntity / XI_ToggleScoreEntityLink
    ;;   C_AddRewardLink / C_ToggleRewardLink
    ;;     └ XI_AddRewardLink / XI_ToggleRewardLink
    ;;   C_Inject — phased recipe (see canonical inject map above C_Inject)
    ;;   CC_Collect — phased recipe (see canonical collect map above CC_Collect)
    ;;
    ;;Protection: Class 1 — Innate protection offered by WI_Fvt, XE_WI_FvtRewardAggregate
    (defun XI_IssueFvt:string
        (fvt-id:string fvt-class:integer owner-konto:string common-denominator:string)
        @doc "Under SECURE (FVT|C>ISSUE-FVT): insert FVT|T row with zeroed aggregates and enabled-reward-count 0."
        ;; SECURE: granted by WI_Fvt (underlying W_).
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (WI_Fvt fvt-id
            (UDC_FVT|Schema true true common-denominator false fvt-id)
        )
        (ref-RPS::XE_WI_FvtRewardAggregate fvt-id
            ;; split-mode: farm (class 0) default participation; vault/treasury get the "|" sentinel (never read)
            (UDC_FVT|RewardAggregate fvt-class owner-konto true CT_MEMBERSHIP_MODE_BAR
                (if (= fvt-class 0) CT_SPLIT_MODE_STAKED CT_SPLIT_MODE_NA)
                0.0 0.0 0.0 0.0 0 0 0 fvt-id)
        )
    )
    )
    ;;Protection: Class 1 — Innate protection offered by WU2_Fvt|Control
    (defun XI_Control:string
        (fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Under SECURE (FVT|C>CONTROL-FVT): update can-upgrade and can-change-owner."
        ;; SECURE: granted by WU2_Fvt|Control (underlying W_).
        (WU2_Fvt|Control fvt-id new-can-upgrade new-can-change-owner)
        fvt-id
    )
    ;;Protection: Class 1 — Innate protection offered by WU_Fvt|CommonDenominator
    (defun XI_SetCommonDenominator:string
        (fvt-id:string common-denominator:string)
        @doc "Under SECURE (FVT|C>SET-COMMON-DENOMINATOR): update farm common-denominator."
        ;; SECURE: granted by WU_Fvt|CommonDenominator (underlying W_).
        (WU_Fvt|CommonDenominator fvt-id common-denominator)
    )
    ;;
    ;; --- Block D · Inject (UrStoa C_URV|Inject / XI_URV|Inject analogue) ---
    ;;   C_Inject — phased recipe in C_ body (no monolithic XI_Inject)
    ;;     ├ XI_SyncFarmGhostTvlForInject (farm-only wrapper)
    ;;     ├ TFT::C_Transfer
    ;;     ├ WU_RpsGlobal|CurrentRps
    ;;     └ WU_RpsGlobal|AvailableRewards
    ;;
    ;; --- Block E · Collect (UrStoa C_URV|Collect analogue) ---
    ;;   CC_Collect — phased recipe in C_ body (same structure as C_Inject / CC_TrueFungibleStakeFlow)
    ;;     ├ XI_TransferRewardDptfFromVault            (coin 1 · URC_CollectClaimableRewards inside)
    ;;     ├ WU_RpsGlobal|AvailableRewards decrement (coin 5 · pre-reset URC read)
    ;;     ├ WU_RpsUser|PendingRewards reset           (coin 2)
    ;;     ├ XI_BookCollectUnclaimed                    (coin 3)
    ;;     └ WU_RpsUser|LastRps checkpoint             (coin 4)
    ;;
    ;;
    ;; --- Block A · Phase 4.5 FVT total-deb mirror (post-SCORE) ---
    ;; --- Block A · Phase 4.7 FVT user-presence ADD (M3 #12 / H4 sweep enumeration) ---
    ;;
    ;; --- Block A · Phase 2.1 settle (CC_TrueFungibleStakeFlow) ---
    ;;   XI_RpsPreScore — orchestrator: ghost TVL → ensure rows → bank pending
    ;;     └ (map) → XI_1|EnsureScoreRewardRows, XI_1|BankScorePendingRewards
    ;;
    ;; --- Shared deb-staleness FIX (M3 #12 — used by CC_Inject AND collect PHASE 6 backstop) ---
    ;; --- Shared inject-CORE + cross-module XE_ building blocks (CC_Inject FVT-local; MTX|n|C_Inject via MTX-AQP) ---
    ;;
    ;; --- Block B · Phase 3 anchor refresh (CC_TrueFungibleStakeFlow · 3.1) ---
    ;;   XI_RefreshTrueFungibleStakeAnchors
    ;;     ├ AQP-ANK::XE_UpdateTrueFungibleUserAnchorValues
    ;;     └ AQP-POOL::XB_SetBenDptfAnkSyncCount
    ;;
    ;; --- Anchors (AQP-ANK · TF stake only) ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XI_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Internal (CC_TrueFungibleStakeFlow phase 3.1 · depth 0]): read post-ico1 BenDptfTotal balance, \
            \ call backward ANK promile refresh + AQP last-ank-sync-count bump; concat IGNIS OCs. \
            \ require-capability (SECURE) only — backward XE_* use P|UEV_IMC / domain caps."
        (require-capability (SECURE))
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (total-dptf-amount:decimal (ref-AQP::UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (ico-ank:object{IgnisCollectorV3.OutputCumulator}
                    (ref-ANK::XE_UpdateTrueFungibleUserAnchorValues beneficiary-id dptf-id total-dptf-amount)
                )
                (ico-aqp:object{IgnisCollectorV3.OutputCumulator}
                    (ref-AQP::XB_SetBenDptfAnkSyncCount beneficiary-id dptf-id)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-ank ico-aqp] [])
        )
    )
    ;;
    ;; --- Block B′ · Phase 3 anchor refresh (CC_CollectableStakeFlow · 3.2 or 3.3 via son) ---
    ;;   XI_RefreshCollectableStakeAnchors
    ;;     ├ AQP-ANK::XE_UpdateSemiFungible* or XE_UpdateNonFungible*
    ;;     └ AQP-POOL::XB_SetBenCollectableAnkSyncCount
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_RefreshCollectableStakeAnchors:object{IgnisCollectorV3.OutputCumulator}
        (
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Internal (CC_CollectableStakeFlow phase 3]): ANK promile refresh — DPSF (son=true) or DPNF (son=false)."
        (require-capability (SECURE))
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if son
                (ref-ANK::XE_UpdateSemiFungibleUserAnchorValues
                    beneficiary-id collectable-id nonces nonce-amounts direction
                )
                (ref-ANK::XE_UpdateNonFungibleUserAnchorValues
                    beneficiary-id collectable-id nonces direction
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_LegCumulator "stake-anchor-refresh" AQP|SC_NAME)
                    (ref-AQP::XB_SetBenCollectableAnkSyncCount beneficiary-id collectable-id son)
                ]
                []
            )
        )
    )
    ;;
    ;; --- Block B · Phase 2.35 unclaimed (C_*StakeFlow) ---
    ;;   XI_BookStakeUnclaimedCounts — map distinct-fvts × reward lines; child XI_2|BumpRpsGlobalUnclaimed.
    ;;
    ;; --- RPS post-SCORE (UrStoa unclaimed + checkpoint) ---
    ;;
    ;; --- Block C · checkpoint (C_*StakeFlow) ---
    ;;   XI_CheckpointStakeRps — nested map (score plan × reward line); no child XI_*.
    ;;
    ;; [XE]
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          FVT|XE>SWEEP-BRACKET
    (defun XE_SweepBegin:string (anchor-id:string)
        @doc "Sweep bracket BEGIN (paginated MTX|n|C_SweepRevokeAnchor): freeze every affected pool (stake + collect \
            \ blocked) then remove the anchor globally (swept-revoke — skips the #9 score-link lock). Mirrors steps \
            \ 1-2 of the single-tx CC_SweepRevokeAnchor. P|UEV_IMC + FVT|XE>SWEEP-BRACKET (P|SECURE-CALLER)."
        (P|UEV_IMC)
        (with-capability (FVT|XE>SWEEP-BRACKET anchor-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (score-ids:[string]
                        (ref-ANK::UR_BC|ScoreLinks (ref-ANK::UR_ANK|BoostClassId anchor-id)))
                )
                ;; 1. FREEZE every affected pool (idempotent per shared pool)
                (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) true)) score-ids)
                ;; 2. REVOKE the anchor globally (swept — keeps scores linked; the paged recompute un-stales everyone)
                (ref-ANK::XE_SweepRevokeAnchor anchor-id)
                (format "Sweep begun for anchor {}: froze {} affected pool(s), anchor swept-revoked." [anchor-id (length score-ids)])
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          FVT|XE>SWEEP-BRACKET
    (defun XE_SweepEnd:string (anchor-id:string)
        @doc "Sweep bracket END (paginated MTX|n|C_SweepRevokeAnchor terminal step): unfreeze every affected pool. \
            \ The anchor was already swept-revoked in XE_SweepBegin; the reverse index is unchanged so score-ids \
            \ still resolve. P|UEV_IMC + FVT|XE>SWEEP-BRACKET (P|SECURE-CALLER)."
        (P|UEV_IMC)
        (with-capability (FVT|XE>SWEEP-BRACKET anchor-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (score-ids:[string]
                        (ref-ANK::UR_BC|ScoreLinks (ref-ANK::UR_ANK|BoostClassId anchor-id)))
                )
                (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) false)) score-ids)
                (format "Sweep ended for anchor {}: unfroze {} affected pool(s)." [anchor-id (length score-ids)])
            )
        )
    )
    ;;
    ;; --- XE forwarders (AQP-VCT TF vacate composes stake/RPS primitives via IMC) ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_SetFvtVacateFrozen:string (fvt-id:string frozen:bool)
        @doc "AQP-VCT begin/finalize: set this FVT's vacate-frozen flag (blocks collect + inject during a pool \
            \ vacate). Called once per the vacating pool's employed-score FVTs. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (WU_FvtVacateFreeze fvt-id frozen)
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_SetFvtOracleOn:string (fvt-id:string oracle-on:bool)
        @doc "DSA: toggle this FVT's node/uptime oracle (off ⇒ capture = units, uptime ≡ 1000, no expiry). P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (WU_Fvt|OracleOn fvt-id oracle-on)
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Forward (stake/unstake flow): recompute the beneficiary's true-fungible stake-anchor values for \
            \ <dptf-id> after a stake delta, keeping the anchor aggregates in sync with the live stake. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_RefreshTrueFungibleStakeAnchors beneficiary-id dptf-id)
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_RefreshCollectableStakeAnchors:object{IgnisCollectorV3.OutputCumulator}
        (
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Forward (stake/unstake flow): recompute the beneficiary's collectable (SF/NF) stake-anchor values \
            \ for <collectable-id>'s <nonces>/<nonce-amounts> in <direction> (stake vs unstake), keeping the \
            \ anchor aggregates in sync with the live nonce stake. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_RefreshCollectableStakeAnchors
                beneficiary-id collectable-id son nonces nonce-amounts direction
            )
        )
    )
    ;; [XB]
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          FVT|C>INJECT
    (defun XB_FvtInject:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "THE single authorized inject entry — usable BOTH internally (C_Inject delegates here) and externally \
            \ (the MTX|n|C_Inject defpact terminal step calls it cross-module), hence `XB`. Just the auth wrapper: \
            \ P|UEV_IMC + FVT|C>INJECT (validates + composes SECURE) around the one XI_FvtInjectCore. Any FVT class \
            \ (farm/vault/treasury); the core branches on class. Distributes over the CURRENT divisor — enforced- \
            \ fresh callers (CC_Inject / the defpact) fix stale members BEFORE calling. Replaces the former \
            \ XE_FvtInject: after the class-guard removal (N2) it was byte-identical to C_Inject's body, so the two \
            \ collapsed onto this one XB entry."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>INJECT patron fvt-id reward-dptf-id amount)
            (ref-RPS::XE_XI_FvtInjectCore "MTX-AQP|2|CC_Inject" patron executor fvt-id reward-dptf-id amount)
        )
    )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]   client
    ;; --- Lifecycle (FVT|T) ---
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-name:string fvt-class:integer common-denominator:string)
        @doc "Create a new FVT (Farm | Vault | Treasury), owned by <executor>. GAS|ISSUE-FVT + \
            \ smart STOA from patron; returns fvt-id in output. \
            \ \
            \ Executor: ENFORCED DIRECTLY. FVT|C>ISSUE-FVT closes with \
            \ (CAP_EnforceAccountOwnership owner-konto) on the parameter itself, after the \
            \ class / name-freshness / common-denominator checks. A RENAME AND A REORDER: the \
            \ account was always proven and always the actor, it simply sat third, behind the \
            \ name, where the canon puts the executor second. \
            \ \
            \ The ownership gate is pinned by [6.2.2] <<TX-SCORE-13>>, which is worth reading \
            \ as a model: it walks the two SHADOWING guards first (an out-of-range class, then \
            \ a wrong denominator) to prove they are NOT what refuses, and only then reaches \
            \ the keyset failure naming the victim. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (FVT|C>ISSUE-FVT fvt-name executor fvt-class common-denominator)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid fvt-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueStoa))
                (XI_IssueFvt fvt-id fvt-class executor common-denominator)
                (URCi_Issue executor [fvt-id])
            )
        )
    )
    ;;Management (FVT|Schema)
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string fvt-id:string)
        @doc "Transfer FVT owner-konto. Validation in FVT|C>ROTATE-OWNERSHIP-FVT; medium IGNIS on pre-rotate owner. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named -- FVT|C>ROTATE-OWNERSHIP-FVT resolves it \
            \ IN PLACE. The capability binds (= executor owner-now) and separately runs \
            \ CAP_EnforceAccountOwnership owner-now on that same derived account, so both halves \
            \ of HANDOFF 4g are already present: the authority is proven and the actor is named \
            \ against it. Executee: <executee> receives ownership and is only type-validated -- \
            \ acted upon, needing no signature. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ico:object{IgnisCollectorV3.OutputCumulator} (ref-RPS::URCi_RotateOwnership fvt-id))
            )
            (with-capability (FVT|C>ROTATE-OWNERSHIP-FVT executor fvt-id executee)
                (ref-RPS::XE_XI_RotateOwnership fvt-id executee)
            )
            ico
        )
    )
    )
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Set can-upgrade and can-change-owner on FVT. Medium IGNIS on owner-konto."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
            )
            (with-capability (FVT|C>CONTROL-FVT executor fvt-id new-can-upgrade new-can-change-owner)
                (XI_Control fvt-id new-can-upgrade new-can-change-owner)
            )
            (ref-RPS::URCi_Control fvt-id)
        )
    )
    )
    (defun C_SetCommonDenominator:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string common-denominator:string)
        @doc "Farm-only: set common-denominator before any ScoreEntityLinks. GAS|SET-COMMON-DENOMINATOR on owner."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-COMMON-DENOMINATOR executor fvt-id common-denominator)
                (XI_SetCommonDenominator fvt-id common-denominator)
            )
            (ref-RPS::URCi_SetCommonDenominator fvt-id [fvt-id])
        )
    )
    )
    (defun C_SetMosaic:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string mosaic:bool)
        @doc "Toggle mosaic membership policy when FVT has no ScoreEntityLink rows. GAS|SET-MOSAIC on owner."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-MOSAIC executor fvt-id mosaic)
                (ref-RPS::XE_XI_SetMosaic fvt-id mosaic)
            )
            (ref-RPS::URCi_SetMosaic fvt-id [fvt-id])
        )
    )
    )
    (defun C_SetSplitMode:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string split-mode:string)
        @doc "Set the farm reward-split mode (D1-G2): SPLIT|STAKED (participation, default) | SPLIT|TVL (pool-size). \
            \ Farm owner; FREELY mutable (no cooldown) — a change re-weights only FUTURE injects (RPS is \
            \ checkpoint-based, past rewards untouched). GAS|SET-SPLIT-MODE on owner."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-SPLIT-MODE executor fvt-id split-mode)
                (ref-RPS::XE_XI_SetSplitMode fvt-id split-mode)
            )
            (ref-RPS::URCi_SetSplitMode fvt-id [fvt-id split-mode])
        )
    )
    )
    ;; --- Score membership (FVT|T|ScoreEntityLink) ---
    (defun C_AddScoreEntity:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Register score (type 1) or triplet (type 3) on FVT; insert ScoreEntityLink; SCR fvt-links. GAS|ADD-SCORE-ENTITY."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (fvt-class:integer (ref-RPS::UR_FVT|FvtClass fvt-id))
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (swpair:string (URC_ResolveScoreEntitySwpair score-entity-type score-entity-id fvt-class))
                (ghost-weight:decimal (RPS.URC_ResolveScoreEntityGhostWeight score-entity-type score-entity-id fvt-class swpair))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>ADD-SCORE-ENTITY executor fvt-id score-entity-type score-entity-id swpair ghost-weight)
                (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                    (let
                        (
                            (bronze-id:string (ref-SCR::UR_SCR|TripletBronzeScoreId score-entity-id))
                            (silver-id:string (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                            (golden-id:string (ref-SCR::UR_SCR|TripletGoldenScoreId score-entity-id))
                        )
                        (ref-SCR::XE_CreateFvtLink bronze-id fvt-id)
                        (ref-SCR::XE_CreateFvtLink silver-id fvt-id)
                        (ref-SCR::XE_CreateFvtLink golden-id fvt-id)
                    )
                    (ref-SCR::XE_CreateFvtLink score-entity-id fvt-id)
                )
                (ref-RPS::XE_XI_AddScoreEntity fvt-id score-entity-type score-entity-id swpair ghost-weight)
            )
            (ref-RPS::URCi_AddScoreEntity fvt-id [fvt-id score-entity-id])
        )
    )
    )
    (defun C_ToggleScoreEntityLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Turn ScoreEntityLink.enabled on/off; farm adjusts S when toggling. GAS|TOGGLE-SCORE-ENTITY-LINK."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>TOGGLE-SCORE-ENTITY-LINK executor fvt-id score-entity-type score-entity-id enabled)
                (ref-RPS::XE_XI_ToggleScoreEntityLink fvt-id score-entity-id enabled)
            )
            (ref-RPS::URCi_ToggleScoreEntityLink fvt-id [fvt-id score-entity-id])
        )
    )
    )
    (defun C_IssueMultipletFamily:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string
            executor:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "Issue one chain-wide MultipletFamily reward ladder F|t0|t1|t2."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (family-id:string (ref-RPS::UCk_MultipletFamily token-0-id token-1-id token-2-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>ISSUE-MULTIPLET-FAMILY executor token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id)
                (ref-RPS::XE_XI_IssueMultipletFamily token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id)
            )
            (URCi_IssueMultipletFamily patron [family-id])
        )
    )
    )
    ;; --- Reward token registration (FVT|T|RPS|Global) — atomic one row per reward DPTF ---
    (defun C_AddRewardLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Register one reward DPTF on FVT (single RPS|Global row). multiplet-family-id BAR for plain tokens (VESTA, etc.); \
            \ F|t0|t1|t2 when reward-dptf-id is family token-0 — enables triplet lane collect on triplet anchors; score anchors stay plain. \
            \ One inject feeds all membership tranches; collect branches on anchor-id (score vs triplet)."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (reward-kind:string
                    (if (= multiplet-family-id BAR)
                        CT_REWARD_KIND_PLAIN
                        CT_REWARD_KIND_MULTIPLET_BASE
                    )
                )
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>ADD-REWARD-LINK executor fvt-id reward-dptf-id segmentation reward-kind multiplet-family-id)
                (ref-RPS::XE_XI_AddRewardLink fvt-id reward-dptf-id segmentation reward-kind multiplet-family-id)
            )
            (ref-RPS::URCi_AddRewardLink fvt-id [fvt-id reward-dptf-id multiplet-family-id])
        )
    )
    )
    (defun C_ToggleRewardLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Toggle reward-enabled; ±1 enabled-reward-count on flip. GAS|TOGGLE-REWARD-LINK on owner."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>TOGGLE-REWARD-LINK executor fvt-id reward-dptf-id enabled)
                (ref-RPS::XE_XI_ToggleRewardLink fvt-id reward-dptf-id enabled)
            )
            (ref-RPS::URCi_ToggleRewardLink fvt-id [fvt-id reward-dptf-id])
        )
    )
    )
    (defun C_SetQualitySplit:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Round B: set a MULTIPLET_BASE reward's quality-split MODE + heterogeneous MATRIX. HOMOGENEOUS (default \
            \ when unset) routes each quality lane to its one ladder token (bronze->t0, silver->t1, gold->t2). \
            \ HETEROGENEOUS routes each lane across ALL 3 ladder tokens per its [to-t0 to-t1 to-t2] per-mille row \
            \ (each row sums to 1000). FVT owner; O(1) reprice (no per-delegator recompute). GAS|SET-QUALITY-SPLIT."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-QUALITY-SPLIT executor fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
                (ref-RPS::XE_WI_QualitySplit fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
            )
            (ref-RPS::URCi_SetQualitySplit fvt-id [fvt-id reward-dptf-id mode])
        )
    )
    )
    ;;
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;; UrStoa canonical inject / collect — phased model (00_StoaSandbox/coin.pact)
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;;
    ;; INJECT — C_URV|Inject / XI_URV|Inject
    ;; PHASE 0 — FVT farm pre-inject (architecture adaptation; UrStoa ≡ N/A):
    ;;   0.1 Ghost TVL lazy sync (all enabled ScoreEntityLinks)   XI_1|SyncFarmGhostTvlForEmployedScores
    ;; PHASE 1 — Custody (coin step 0):
    ;;   1.1 Transfer reward DPTF patron → AQP|SC_NAME      TFT::C_Transfer
    ;; PHASE 2 — RPS global index (coin step 1 · XI_URV|UpdateVaultRPS):
    ;;   2.1 current-rps G += floor(R / S, 48)              WU_RpsGlobal|CurrentRps
    ;; PHASE 3 — Reward vault balance (coin step 2 · XI_URV|UpdateVaultSupply):
    ;;   3.1 available-rewards += R                           WU_RpsGlobal|AvailableRewards
    ;; PHASE 4 — Unclaimed policy (coin step 3 · comment-only):
    ;;   4.1 Do NOT reset unclaimed-count on inject         N/A
    ;;
    ;; COLLECT — C_URV|Collect (00_StoaSandbox/coin.pact L1804–1827)
    ;; PRE — claimable amount (UrStoa let-binding · URC_URV|ClaimableRewards; includes dust rule):
    ;;   URC_CollectClaimableRewards — inside phase 1 / 5 XIs after FVT phase 0 accrual
    ;; PHASE 0 — FVT two-tier accrual prelude (README §4a; UrStoa ≡ N/A — not in C_URV|Collect):
    ;;   0.1 Ghost TVL lazy sync (farm, this score)         XI_1|SyncFarmGhostTvlForEmployedScores
    ;;   0.2 Tier-2 member settle (README 2a)               XI_2|SettleMemberTier2
    ;;   0.3 Tier-1 accrue pending at current deb (2b)    XI_2|BankUserTier1Pending
    ;; PHASE 1 — Payout custody (coin step 1 · C_Transmit URV|KONTO→account):
    ;;   1.1 Transfer reward DPTF AQP|SC_NAME → patron      XI_TransferRewardDptfFromVault
    ;; PHASE 2 — User row (coin step 2 · XI_URV|ResetPendingRewards):
    ;;   2.1 Zero pending-rewards on RPS|User               WU_RpsUser|PendingRewards
    ;; PHASE 3 — Unclaimed (coin step 3 · XI_URV|UpdateUnclaimedCount false when user-supply=0):
    ;;   3.1 FVT adapt: decrement when deb-score = 0        XI_BookCollectUnclaimed
    ;; PHASE 4 — Checkpoint (coin step 4 · XI_URV|UpdateUserRPS vault current-rps):
    ;;   4.1 FVT adapt: advance last-rps to L_i               WU_RpsUser|LastRps
    ;; PHASE 5 — Global vault (coin step 5 · XI_URV|UpdateVaultSupply available-rewards false):
    ;;   5.1 Decrement available-rewards by payout          WU_RpsGlobal|AvailableRewards
    ;;       (ICO slot after phase 1, before phase 2 — same URC read as UrStoa available-rewards let)
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;;
    ;; ───────────────────────────────────────────────────────────────────────────
    ;; INJECT FUNCTION MATRIX — all three route through the ONE core XI_FvtInjectCore
    ;; ───────────────────────────────────────────────────────────────────────────
    ;;   Entrypoint (Talos wrapper)        Farm(0,LP)  Vault(1,TF/OF)  Treasury(2,SF/NF)  Divisor  Tx
    ;;   CORRECTED 2026-09-29 -- this header still carried the PRE-RULING mapping
    ;;   `Vault(1,TF/SF/NF) Treasury(2,OF)`, which is exactly the pair the 2026-09-19 owner
    ;;   ruling REVERSED in URC_ScoreClassMatchesFvtClass ~1000 lines below. The function was
    ;;   fixed and documented; this comment was not, so the file stated both mappings and the
    ;;   wrong one came first. A comment cannot be gate-diffed, which is why it outlived the
    ;;   defect it described -- and why it got quoted into a UI design before anyone re-read
    ;;   the function. Live rule: farm<->LP(0), vault<->TF/OF(1/2), treasury<->SF/NF(3/4).
    ;;   C_Inject   (AQP-FVT|CC_Inject)        yes           yes               yes          naive    1
    ;;   CC_Inject  (AQP-FVT|CC_Inject)       yes           yes               yes          fresh    1
    ;;   MTX|2|C_Inject defpact (C_2|Inject)  yes           yes               yes          fresh    2*
    ;;   (* spike fallback for CC_Inject — up to 2×N_FIX stale stakers across 2 steps)
    ;;
    ;;   NAIVE  = distribute over the CURRENT divisor (may be deb-lagged; self-heals at each staker's collect).
    ;;   FRESH  = scan URH_FvtStalePresentUsers + FIX every stale member first (settle@old-deb → refresh SCORE deb
    ;;            → resync), so the distribution reflects LIVE debs and is fair across stakers. HEAVY (R3 `CC_`).
    ;;
    ;;   ALL FVT classes are deb-stale-exposed, so all three serve all classes:
    ;;    · Vault/Treasury: inject divisor = maintained SCR/FVT total-deb-score mirror (stale-able).
    ;;    · Farm: Tier-1 denominator S is fresh (ref-RPS::URC_FarmInjectDenominatorFresh), but the Tier-2 per-member
    ;;      L_i-advance divisor is SCR|ScoreTotalDebScore — stale-able for singular / non-true-triplet members
    ;;      (e.g. a mosaic farm carrying a singular score). True-triplet members are deb-independent (lane weights)
    ;;      and the fix no-ops on them.
    ;;   Inject cost scales with MEMBER count (employed score-entities; a triplet = ONE member): a 4-member farm
    ;;   costs one member-iteration more than a 3-member farm.
    ;; ───────────────────────────────────────────────────────────────────────────
    ;;
    (defun CC_InjectStream:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Inject a reward DPTF as a TIME-STREAM — the DELAYED inject path (any FVT class): `amount` vests \
            \ LINEARLY over `duration` seconds (1h..365d) and whoever is staked during each slice earns that slice \
            \ (late stakers included). duration = 0 is not accepted here — use C_Inject for an instant inject. \
            \ Streams are independent + overlap (no merge), capped per the FVT owner konto's Elite tier; a full \
            \ lane accepts only instant injects until a stream finishes. Delegates to XIv_FvtAddStream under \
            \ FVT|C>INJECT-STREAM (validate + custody + SECURE). UI: URC_LiveClaimable / URC_StreamStatus show \
            \ real-time accrual. See Audit/STREAMED-INJECT-DESIGN.md. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. FVT|C>INJECT-STREAM validates the CONTEXT \
            \ only. The executor's tokens are debited by XE_XI_FvtAddStream, which bottoms out \
            \ in (TFT::C_Transfer patron executor AQP|SC_NAME reward-dptf-id amount) -- the \
            \ custody leg, whose capability opens on CAP_EnforceAccountOwnership. Renamed from \
            \ <injector>, which was already the right account under a local word. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>INJECT-STREAM patron fvt-id reward-dptf-id amount duration)
            (ref-RPS::XE_XI_FvtAddStream "AQP-FVT|CC_InjectStream" patron executor fvt-id reward-dptf-id amount duration)
        )
    )
    )
    (defun CC_Inject:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "HEAVY (R3 `CC_`) enforced-FRESH inject for ANY FVT class (farm/vault/treasury) — see the INJECT \
            \ FUNCTION MATRIX above C_Inject. Before injecting, SCAN the FVT's present users (`URH_FvtStalePresentUsers` \
            \ — one select over the purpose-built presence table, populated for every class at stake) and FIX every \
            \ stale member (settle-at-old-deb across all streams → refresh SCORE deb → resync via XI_FixUserFvtDeb), so \
            \ the distribution reflects LIVE debs and is fair to every current staker. Atomic: fixing the whole scanned \
            \ set leaves ZERO stale — NO second scan. Why farms need this too: a farm's Tier-1 denominator S is always \
            \ fresh (ref-RPS::URC_FarmInjectDenominatorFresh), BUT its Tier-2 per-member L_i-advance divisor is the maintained \
            \ SCR|ScoreTotalDebScore mirror, which goes deb-stale for singular / non-true-triplet members (e.g. a \
            \ mosaic farm carrying a singular score) exactly like a vault — the fix un-stales it (true-triplet members \
            \ no-op: deb-independent lanes). Same authorization as C_Inject (FVT|C>INJECT). For spike loads that exceed \
            \ one tx, use the MTX|n|C_Inject defpact (MTX-AQP). UrStoa ≡ C_URV|Inject with a pre-fresh divisor. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. FVT|C>INJECT validates the CONTEXT only. \
            \ The executor's tokens are debited by XE_XI_FvtInjectCore, which bottoms out in \
            \ (TFT::C_Transfer patron executor AQP|SC_NAME reward-dptf-id amount). Renamed from \
            \ <injector>. (patron/executor canon 2.2, 2026-09-22.)"
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>INJECT patron fvt-id reward-dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 0 (CC)=== SCAN the FVT's STALE present users + FIX every stale member (recording
                        ;; the 2e forced-fix count per user) → fresh divisor. Atomic: fixing the whole scanned set ⟹
                        ;; ZERO stale afterward (scan-cut, no re-scan).
                        (let
                            (
                                (members:[string] (ref-RPS::URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                                (reward-rows:[string] (ref-RPS::URH_FVT-RG|EnabledRewardRows fvt-id))
                            )
                            ;; DRIP each reward lane once (checkpoint) before the fix loop → users settle at now's index
                            (map (lambda (d:string) (ref-RPS::XE_XI_ReleaseStream fvt-id d)) reward-rows)
                            (map (lambda (u:string) (ref-RPS::XE_XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) (ref-RPS::URH_FvtStalePresentUsers fvt-id))
                            (UC_EmptyOc)
                        )
                        ;;===>PHASE 1-3=== inject on the now-FRESH divisor (shared core, also driven by the defpact)
                        (ref-RPS::XE_XI_FvtInjectCore "AQP-FVT|CC_Inject" patron executor fvt-id reward-dptf-id amount)
                    ]
                    []
                )
            )
        )
    )
    )
    (defun CCp_InjectFixChunk:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "PAGE the enforced-fresh inject's FIX phase — the scalable prelude to CC_InjectFinalize, the defun+gate \
            \ twin of the fixed 2-step MTX|2|C_Inject defpact, for stale sets exceeding one tx. Fixes up to `chunk` \
            \ CURRENTLY-stale present users (settle at old deb + refresh to live + resync mirror, recording the 2e \
            \ forced-fix count — same penalized fix as the single-tx CC_Inject and the defpact). No cursor: the \
            \ stale set SHRINKS as it is fixed (fixed users read fresh, so they drop out of URH_FvtStalePresentUsers) \
            \ — repeat until none remain, then CC_InjectFinalize. P|UEV_IMC + FVT|C>INJECT-FIX (reward context + chunk \
            \ bound). Between-tx staleness from external Elite-DEB moves is re-caught by the next scan; finalize \
            \ enforces zero-stale at inject."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>INJECT-FIX patron fvt-id reward-dptf-id chunk)
            (let
                (
                    (stale:[string] (ref-RPS::URH_FvtStalePresentUsers fvt-id))
                )
                (let
                    (
                        (batch:[string] (take chunk stale))
                        ;; hoist the FVT-invariant member + reward-row lists ONCE for the whole chunk (no per-user re-scan)
                        (members:[string] (ref-RPS::URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                        (reward-rows:[string] (ref-RPS::URH_FVT-RG|EnabledRewardRows fvt-id))
                    )
                    ;; DRIP each reward lane ONCE (checkpoint) before the fix loop so every user settles against the
                    ;; now-current index (no time passes during the batch tx). No-op when no lane carries a stream.
                    (map (lambda (d:string) (ref-RPS::XE_XI_ReleaseStream fvt-id d)) reward-rows)
                    ;; force-refresh this chunk of stale stakers (penalized); fixed users drop out of the stale set
                    (map (lambda (u:string) (ref-RPS::XE_XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) batch)
                    (let
                        (
                            (remaining:integer (- (length stale) (length batch)))
                        )
                        (format "Inject-fix: fixed {} of {} stale staker(s) — {} remain{}." [(length batch) (length stale) remaining (if (= remaining 0) " (ready to CC_InjectFinalize)" ", keep paging")])
                    )
                )
            )
        )
    )
    )
    (defun CC_InjectFinalize:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "FINALIZE a paginated enforced-fresh inject: enforce that NO stale present user remains (the prior \
            \ CCp_InjectFixChunk pages made the divisor live), then inject on the fresh divisor via the shared \
            \ XI_FvtInjectCore — identical outcome to the single-tx CC_Inject and the MTX|2|C_Inject defpact terminal \
            \ step. The zero-stale gate is the enforced-fresh guarantee at the moment of inject (a heavy scan, so it \
            \ lives in the body, not the defcap). P|UEV_IMC + FVT|C>INJECT (same auth as any inject). \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. Same route as CC_Inject -- the debit is \
            \ XE_XI_FvtInjectCore's (TFT::C_Transfer patron executor AQP|SC_NAME ...). Renamed \
            \ from <injector>. (patron/executor canon 2.2, 2026-09-22.)"
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>INJECT patron fvt-id reward-dptf-id amount)
            ;; enforced-fresh gate: refuse to inject while any present staker is stale (page CCp_InjectFixChunk first).
            ;; The URH_ scan (select) MUST be computed in a let, NOT inside the enforce — Pact evaluates an enforce
            ;; predicate in read-only/sys-only mode, where select is disallowed. Fires before XI_FvtInjectCore's
            ;; custody transfer, so an aborted finalize moves no funds.
            (let
                (
                    (stale-remaining:integer (length (ref-RPS::URH_FvtStalePresentUsers fvt-id)))
                )
                (enforce (= 0 stale-remaining)
                    "Stale stakers remain — page CCp_InjectFixChunk until none remain before finalizing (or use single-tx CC_Inject)")
                (ref-RPS::XE_XI_FvtInjectCore "AQP-FVT|CC_InjectFinalize" patron executor fvt-id reward-dptf-id amount)
            )
        )
    )
    )
    (defun CCp_UnstaleAll:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "OWNER-run mass deb-unstale: force-refresh up to `chunk` CURRENTLY-stale present stakers of `fvt-id` to \
            \ make the entity INJECTION-READY, WITHOUT injecting — the inject's FIX phase (CCp_InjectFixChunk) decoupled \
            \ from the inject. Same penalized fix (XI_FixUserFvtDebPenalizedIn: settle at old deb → refresh to live → \
            \ resync mirror, recording the 2e forced-fix count on this lane, which the user reimburses in IGNIS at his \
            \ next collect), so pre-unstaling tags stale users EXACTLY as a real inject would. No cursor: fixed users \
            \ read fresh and drop out of URH_FvtStalePresentUsers, so the stale set SHRINKS — repeat until none remain, \
            \ then a cheap light C_Inject (or CC_Inject) runs on the fresh divisor. When NO present staker is stale it \
            \ is a cheap no-op reporting `all up to date`. OWNER-GATED (contrast the permissionless inject-fix). \
            \ P|UEV_IMC + FVT|C>UNSTALE-ALL (owner + reward context + chunk bound). Not IGNIS-billed (gas-station \
            \ subsidised like the inject-fix pages; cost is recovered from the fixed users' 2e)."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>UNSTALE-ALL patron fvt-id reward-dptf-id chunk)
            (let
                (
                    (stale:[string] (ref-RPS::URH_FvtStalePresentUsers fvt-id))
                )
                (let
                    (
                        (batch:[string] (take chunk stale))
                        ;; hoist the FVT-invariant member + reward-row lists ONCE for the whole chunk (no per-user re-scan)
                        (members:[string] (ref-RPS::URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                        (reward-rows:[string] (ref-RPS::URH_FVT-RG|EnabledRewardRows fvt-id))
                    )
                    ;; DRIP each reward lane ONCE (checkpoint) before the fix loop so every user settles against the
                    ;; now-current index (no time passes during the batch tx). No-op when no lane carries a stream.
                    (map (lambda (d:string) (ref-RPS::XE_XI_ReleaseStream fvt-id d)) reward-rows)
                    ;; force-refresh this chunk of stale stakers (penalized — records the 2e forced-fix count); fixed
                    ;; users read fresh and drop out of the stale set.
                    (map (lambda (u:string) (ref-RPS::XE_XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) batch)
                    (let
                        (
                            (remaining:integer (- (length stale) (length batch)))
                        )
                        (if (= (length stale) 0)
                            (format "Unstale-all: FVT {} lane {} — all present stakers up to date (injection-ready)." [fvt-id reward-dptf-id])
                            (format "Unstale-all: unstaled {} of {} stale staker(s) — {} remain{}." [(length batch) (length stale) remaining (if (= remaining 0) " (injection-ready)" ", keep paging")]))
                    )
                )
            )
        )
    )
    )
    (defun CC_SweepRevokeAnchor:string
        (patron:string executor:string anchor-id:string)
        @doc "HEAVY (R3 CC_) single-tx RE-SCORE SWEEP that RETIRES an EMPLOYED anchor (H4 half-2). Freezes the \
            \ affected pools, removes the anchor globally (swept-revoke — skips the #9 score-link lock), recomputes \
            \ EVERY present holder on every affected FVT member (settle → aggregate/lane refold → deb refresh → \
            \ mirror), then unfreezes. Owner-initiated: the anchor owner (= the anchored-asset owner) signs; CAP_Owner \
            \ is enforced inside ANK|XE>SWEEP-REVOKE. Scans the boost-class reverse index (ANK::UR_BC|ScoreLinks) × \
            \ each score's present users — bounded by score DEFINITIONS × stakers. For staker sets exceeding one tx, \
            \ use the paginated MTX-AQP::MTX|2|C_SweepRevokeAnchor defpact (mirrors CC_Inject → MTX|2|C_Inject). Lives in \
            \ AQP-FVT (earliest module that can call ANK/SCR/POOL/FVT + owns the recompute). P|UEV_IMC + \
            \ FVT|C>SWEEP-REVOKE. `patron` is retained for symmetry / future IGNIS."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>SWEEP-REVOKE patron executor anchor-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    ;;
                    (boost-class-id:string (ref-ANK::UR_ANK|BoostClassId anchor-id))
                    (score-ids:[string] (ref-ANK::UR_BC|ScoreLinks boost-class-id))
                )
                ;; 1. FREEZE every affected pool (stake + collect blocked) — idempotent per shared pool
                (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) true)) score-ids)
                ;; 2. REVOKE the anchor globally (swept — skips the #9 lock; the recompute below un-stales everyone)
                (ref-ANK::XE_SweepRevokeAnchor anchor-id)
                ;; 3. RECOMPUTE every present holder on every affected member. URH_FvtPresentUsers (ALL present) not
                ;;    the stale subset: right after removal the aggregate is not yet refolded, so no holder reads as
                ;;    deb-stale yet; the per-user recompute no-ops for holders whose aggregate did not change.
                (map
                    (lambda (sid:string)
                        (ref-RPS::XE_XI_FvtSweepRecomputeChunk
                            (ref-SCR::UR_SCR|ScoreFvtLink sid)
                            (if (ref-SCR::UR_SCR|ScoreTriplet sid) (ref-SCR::UR_SCR|ScoreTripletId sid) sid)
                            boost-class-id
                            (ref-RPS::URH_FvtPresentUsers (ref-SCR::UR_SCR|ScoreFvtLink sid))))
                    score-ids)
                ;; 4. UNFREEZE
                (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) false)) score-ids)
                (format "Sweep-retired anchor {} (BoostClass {}): recomputed holders across {} employing score(s)." [anchor-id boost-class-id (length score-ids)])
            )
        )
    )
    )
    (defun CC_SweepBegin:string
        (patron:string executor:string anchor-id:string)
        @doc "OPEN a paginated defun+gate re-score sweep — the scalable twin of CC_SweepRevokeAnchor (single-tx) \
            \ and MTX|2|C_SweepRevokeAnchor (fixed 2-step defpact). Mirrors steps 1-2 of the single-tx: FREEZE every \
            \ affected pool then swept-revoke the anchor globally (skips the #9 score-link lock), then records the \
            \ frozen recompute-set size in an offset-0 cursor. Recompute is deferred to repeated CCp_SweepRecomputeChunk \
            \ calls under the held freeze; the finalizing chunk unfreezes. Use this + chunking when the holder set \
            \ exceeds one tx; for small sets prefer the single-tx CC_SweepRevokeAnchor. Owner-initiated (the anchor \
            \ owner signs; CAP_Owner enforced inside ANK|XE>SWEEP-REVOKE). P|UEV_IMC + FVT|C>SWEEP-REVOKE."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>SWEEP-REVOKE patron executor anchor-id)
            (enforce (not (UR_FVT|SweepActive anchor-id)) "A sweep is already in progress for this anchor")
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    ;;
                    (boost-class-id:string (ref-ANK::UR_ANK|BoostClassId anchor-id))
                )
                (let
                    (
                        (score-ids:[string] (ref-ANK::UR_BC|ScoreLinks boost-class-id))
                    )
                    ;; 1. FREEZE every affected pool (stake + collect blocked) — idempotent per shared pool
                    (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) true)) score-ids)
                    ;; 2. REVOKE the anchor globally (swept — keeps scores linked; the paged recompute un-stales everyone)
                    (ref-ANK::XE_SweepRevokeAnchor anchor-id)
                    ;; 3. OPEN the cursor at offset 0 over the now-frozen recompute set
                    (let
                        (
                            (total:integer (ref-RPS::URC_FvtSweepTotalPresent score-ids))
                        )
                        (WU_FvtSweepProgress anchor-id total 0 true)
                        (format "Sweep begun for anchor {} (BoostClass {}): swept-revoked; {} holder(s) to recompute across {} score(s) — page via CCp_SweepRecomputeChunk." [anchor-id boost-class-id total (length score-ids)])
                    )
                )
            )
        )
    )
    )
    (defun CCp_SweepRecomputeChunk:string
        (patron:string anchor-id:string chunk:integer)
        @doc "PAGE a paginated re-score sweep: recompute the next `chunk` holders over the GLOBAL flattened present \
            \ set [offset, min(offset+chunk, total)), advancing the cursor. When the window reaches `total` the set \
            \ is exhausted, so this chunk also UNFREEZES every affected pool and closes the cursor (completeness is \
            \ ENFORCED — pools cannot unfreeze until offset reaches total). Idempotent recompute funnels through the \
            \ SAME XI_FvtSweepRecomputeChunk as the single-tx and defpact paths. `chunk` is the UI's simulated slice \
            \ size (bounded by the loose SWEEP-CHUNK-MAX backstop). P|UEV_IMC + FVT|C>SWEEP-DRAIN (active-gated)."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>SWEEP-DRAIN patron anchor-id chunk)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    ;;
                    (cursor:object{AcquisitionSchemasV1.FVT|SweepProgress} (UR_FVT|SweepProgress anchor-id))
                    (boost-class-id:string (ref-ANK::UR_ANK|BoostClassId anchor-id))
                )
                (let
                    (
                        (total:integer (at "total" cursor))
                        (offset:integer (at "offset" cursor))
                        (score-ids:[string] (ref-ANK::UR_BC|ScoreLinks boost-class-id))
                    )
                    (let
                        (
                            (win-hi:integer (if (< (+ offset chunk) total) (+ offset chunk) total))
                        )
                        ;; recompute the window [offset, win-hi) over the frozen global flattened present set
                        (let
                            (
                                (n:integer (ref-RPS::XE_XI_FvtSweepRecomputeWindow score-ids boost-class-id offset win-hi))
                            )
                            (if (>= win-hi total)
                                ;; FINAL chunk — recompute set exhausted: unfreeze every affected pool + close the cursor
                                (do
                                    (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) false)) score-ids)
                                    (WU_FvtSweepProgress anchor-id total total false)
                                    (format "Sweep chunk [{}→{}): recomputed {} holder(s) — set exhausted, anchor {} retired, {} pool(s) unfrozen." [offset win-hi n anchor-id (length score-ids)]))
                                ;; MORE remain — advance the cursor, freeze stays held
                                (do
                                    (WU_FvtSweepProgress anchor-id total win-hi true)
                                    (format "Sweep chunk [{}→{}): recomputed {} holder(s) of {} — {} remain, continue paging." [offset win-hi n total (- total win-hi)]))
                            )
                        )
                    )
                )
            )
        )
    )
    )
    (defun CC_UnstaleMyScores:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-ids:[string])
        @doc "User SELF-SERVICE deb-unstale: the caller refreshes THEIR OWN stale scores across `fvt-ids` — per \
            \ FVT, XI_FixUserFvtDeb settles the caller's pending at the OLD deb, refreshes each score deb to the \
            \ live Elite-DEB, and resyncs the FVT total-deb mirror. NON-penalized (self-service is the cheap path; \
            \ only inject-forced fixes bill the 2e penalty). Each member already fresh (or a true triplet) no-ops, \
            \ so passing a whole FVT only touches its stale members. Single-tx and bounded (a user's own FVT set is \
            \ small — no pagination needed). The UI finds the list via URC_FvtUserHasStaleMember per FVT the user \
            \ stakes. No fund movement (pending is banked, not paid). P|UEV_IMC + FVT|C>UNSTALE-MY-SCORES (owner)."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>UNSTALE-MY-SCORES executor)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;; fix ALL the caller's stale members across the listed FVTs (each fresh member no-ops)
                        (do
                            (map (lambda (fvt-id:string) (ref-RPS::XE_XI_FixUserFvtDeb patron fvt-id)) fvt-ids)
                            (UC_EmptyOc))
                        ;; GAS — the user pays for their own refresh
                        (URCi_UnstaleMyScores patron [(format "{}" [(length fvt-ids)])])
                    ]
                    []
                )
            )
        )
    )
    )
    (defun CC_Collect:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Collect reward DPTF — phases 0 → 5 — see canonical collect map above. UrStoa ≡ C_URV|Collect."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-DALOS-X:module{OuronetDalosV2} DALOS)
            )
            ;;ATTRIBUTION + AUTHORISATION (canon 2.2, 2026-09-22). FVT|C>COLLECT validates the
            ;;CONTEXT -- pool not sweeping, FVT not vacate-frozen, reward token enabled, score
            ;;entity linked -- and proves NO account. The reward leaves the vault and is credited
            ;;to <executor>, so <executor> is the claimant and must sign for its own claim. The
            ;;patron/executor split is preserved and is the point: a sponsor may pay the gas,
            ;;but only the claimant may trigger the claim. An executor nobody checks would be
            ;;exactly the decorative attribution 4f rates worse than none.
            (ref-DALOS-X::CAP_EnforceAccountOwnership executor)
        )
        (with-capability (FVT|C>COLLECT patron fvt-id score-entity-type score-entity-id reward-dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    ;;
                    (pool-id:string
                        (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                        (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)
                    ))
                    (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                ;; DRIP the collected lane FIRST (checkpoint) so the farm pre-settle, the payout
                ;; (ref-RPS::URC_CollectClaimableRewards) and the PHASE-4 last-rps advance all reflect streamed rewards
                ;; vested up to `now`. No-op when the lane carries no live stream.
                (ref-RPS::XE_XI_ReleaseStream fvt-id reward-dptf-id)
                (if (= (ref-RPS::UR_FVT|FvtClass fvt-id) 0)
                    (ref-RPS::XE_XI_2|SettleMemberTier2 fvt-id score-entity-type score-entity-id reward-dptf-id)
                    true
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 0=== (audit LP redesign / Stage 2b) farm ghost-TVL sync REMOVED — L_i is
                        ;; advanced at inject (split-at-inject); the pre-settle above still flushes parked pending.
                        ;;
                        ;;===>PHASE 1=== coin step 1 · C_Transmit URV|KONTO→account
                        ;; PRE payout via URC_CollectClaimableRewards inside XI (post phase 0, pre reset)
                        (ref-RPS::XE_XI_TransferRewardDptfFromVault patron executor pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                        ;;
                        ;;===>PHASE 5=== coin step 5 · XI_URV|UpdateVaultSupply false
                        ;; ICO slot before phase 2 so URC reads same pre-reset state as UrStoa available-rewards let
                        (let
                            (
                                (payout:decimal
                                    (ref-RPS::URC_CollectClaimableRewards executor pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                                )
                                (ar:decimal (ref-RPS::UR_FVT-RG|AvailableRewards fvt-id reward-dptf-id))
                                (new-ar:decimal (- ar payout))
                                ;; #10 Tier-1: decrement the member mini-vault too. Clamp at 0 for the global-sweep
                                ;; case (payout = global available ≥ member available), which zeroes the member vault.
                                (ma:decimal (ref-RPS::UR_FVT-MV|AvailableRewards fvt-id score-entity-id reward-dptf-id))
                                (new-ma:decimal
                                    (let
                                        (
                                            (m:decimal (- ma payout))
                                        )
                                        (if (< m 0.0) 0.0 m)
                                    )
                                )
                            )
                            ;; SECURE: granted by WU_RpsGlobal|AvailableRewards / WU_MemberVault|AvailableRewards (underlying W_).
                            (ref-RPS::XE_WU_RpsGlobal|AvailableRewards fvt-id reward-dptf-id new-ar)
                            (ref-RPS::XE_WU_MemberVault|AvailableRewards fvt-id score-entity-id reward-dptf-id new-ma)
                            (UC_EmptyOc)
                        )
                        ;;
                        ;;===>PHASE 3=== coin step 3 · XI_URV|UpdateUnclaimedCount false
                        ;;SEQUENCED BEFORE PHASE 2 ON 2026-09-14, and the order is load-bearing.
                        ;;XI_1|BookCollectUnclaimed now retires a caller from the claimant set only
                        ;;when it is unstaked AND still holds unsettled pending -- which is the rule
                        ;;the stake path uses to keep such a user counted in the first place. Read
                        ;;after PHASE 2, `pending` is 0 for everyone and that test cannot
                        ;;distinguish "retiring now" from "retired long ago", which is how an
                        ;;already-exited account could decrement the counter a second time.
                        ;;The two phases touch disjoint state -- counters here, pending-rewards
                        ;;there -- so the swap changes nothing else.
                        (ref-RPS::XE_XI_BookCollectUnclaimed executor pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                        ;;
                        ;;===>PHASE 2=== coin step 2 · XI_URV|ResetPendingRewards
                        (do
                            ;; SECURE: granted by WU_RpsUser|PendingRewards (underlying W_).
                            (ref-RPS::XE_WU_RpsUser|PendingRewards executor fvt-id score-entity-id reward-dptf-id 0.0)
                            (UC_EmptyOc)
                        )
                        ;;
                        ;;===>PHASE 4=== coin step 4 · XI_URV|UpdateUserRPS (farm: L_i; vault/treasury: G)
                        (do
                            ;; SECURE: granted by WU_RpsUser|LastRps (underlying W_).
                            (ref-RPS::XE_WU_RpsUser|LastRps executor fvt-id score-entity-id reward-dptf-id
                                (ref-RPS::URC_FvtTier1IndexRps fvt-id score-entity-id reward-dptf-id)
                            )
                            (UC_EmptyOc)
                        )
                        ;;
                        ;;===>PHASE 6=== (M3 #12 deb-staleness collect-backstop) delegate to the SHARED fix
                        ;; XI_FixUserMemberDeb: iff deb-based & stale, settle the patron's pending at OLD deb across
                        ;; ALL reward streams (the just-collected stream re-settles to 0 — its last-rps is already G;
                        ;; the OTHER streams get settled here, closing the multi-reward-dptf edge), refresh the SCORE
                        ;; deb-score(s) to live (each triplet leg at its OWN pool), and resync the FVT total-deb mirror
                        ;; by the member delta. Runs AFTER phases 1-4 so settle-before-weight-change holds. No-op when
                        ;; fresh or a TRUE triplet (deb-independent lanes).
                        (ref-RPS::XE_XI_FixUserMemberDeb executor fvt-id score-entity-type score-entity-id)
                        ;;===>PHASE 7=== (M3 #12 2e) inject-forced-fix penalty: `count × RATE` NON-discountable IGNIS,
                        ;; then zero the count. Non-discount via gross-up (price = count×RATE / patron-discount → after
                        ;; the uniform prime-time discount it lands at exactly count×RATE). The reward paid is untouched;
                        ;; self-fixing (PHASE 6) is never penalized, so it stays the cheaper path. No-op when count = 0.
                        (let
                            (
                                (ffc:integer (ref-RPS::UR_FVT-FFC|Count fvt-id reward-dptf-id executor))
                            )
                            (if (<= ffc 0)
                                (UC_EmptyOc)
                                (let
                                    (
                                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                                        (penalty:decimal (* (dec ffc) CT_FORCED_FIX_RATE))
                                    )
                                    (ref-RPS::XE_WU_FvtForcedFixCount|Zero fvt-id reward-dptf-id executor)
                                    (ref-IGNIS::UDC_ConstructOutputCumulator
                                        (/ penalty (ref-DALOS::URC_IgnisGasDiscount patron)) patron trigger []
                                    )
                                )
                            )
                        )
                        (ref-RPS::URCi_Collect fvt-id [fvt-id score-entity-id reward-dptf-id])
                    ]
                    []
                )
            )
        )
    )
    )
    ;;
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;; UrStoa canonical stake/unstake — phased model (00_StoaSandbox/coin.pact)
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;;
    ;; PHASE 1 — Custody (AQP-POOL): move assets + record trackers before RPS/SCORE.
    ;;   1.1 Transfer asset user↔vault           UrStoa ≡ X_UR|Transfer
    ;;   1.2 Per-pool tracker row                 UrStoa ≡ N/A (implicit single vault)
    ;;   1.3 Cross-pool beneficiary rollup        UrStoa ≡ N/A (TF / DPTF ANK only)
    ;;
    ;; PHASE 2 — FVT RPS prelude (at OLD deb/L_i, before SCORE mutation):
    ;;   2.1 Ghost TVL sync (farm Tier-2)         UrStoa ≡ N/A
    ;;   2.2 Ensure RPS Member + User rows        UrStoa ≡ insert UrStoaVaultUser if !IzAccount
    ;;   2.3 Bank pending at OLD deb × ΔL_i       UrStoa ≡ XI_URV|UpdatePendingRewards
    ;;
    ;; PHASE 3 — Anchors (AQP-ANK promile refresh after custody, before SCORE):
    ;;   3.1 DPTF anchor refresh                  UrStoa ≡ N/A · TF only (XI_RefreshTrueFungibleStakeAnchors)
    ;;   3.2 DPSF anchor refresh                  UrStoa ≡ N/A · DPDC son=true (incremental nonces + amounts)
    ;;   3.3 DPNF anchor refresh                  UrStoa ≡ N/A · DPDC son=false (incremental nonces)
    ;;
    ;; PHASE 4 — SCORE weight mutation:
    ;;   4.1 Vault aggregate totals               UrStoa ≡ XI_URV|UpdateVaultScore
    ;;   4.2 User base/boosted/deb triple         UrStoa ≡ XI_URV|UpdateUserScore
    ;;   4.3 NZS count delta                      UrStoa ≡ XI_URV|UpdateNZS
    ;;
    ;; PHASE 5 — FVT RPS post-SCORE (after nz state known):
    ;;   5.1 Global unclaimed-count               UrStoa ≡ XI_URV|UpdateUnclaimedCount
    ;;   5.2 Advance user last-rps to NEW L_i     UrStoa ≡ XI_URV|UpdateUserRPS
    ;;
    ;; Flow slots: TF=1.1–1.3,3.1 | OF=1.1–1.2 (1.3/3.x comment-only) | DPDC=1.1–1.2 + 3.2 or 3.3
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;;
    ;; --- TF stake/unstake recipe (Talos client → CC_TrueFungibleStakeFlow) ---
    (defun CC_TrueFungibleStakeFlow:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string pool-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Core TF stake/unstake recipe. Phases 1 -> 2 -> 3 -> 4 -> 5, see the canonical map above. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. Phase 1 hands <executor> to AQP-POOL's \
            \ custody leg (AQP|XE>*-POOL-CUSTODY), which is where the asset actually moves and \
            \ where the account is proven. <executor> WAS the actor all along; it now says so, \
            \ and sits where the canon puts it. \
            \ Executee: the account whose stake POSITION is created or reduced. It is validated \
            \ (UEV_StakeBeneficiaryAccount) and never consulted -- an owner may stake on a \
            \ beneficiary's behalf, which is the whole reason the two are separate parameters. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>TRUE-FUNGIBLE-STAKE-FLOW pool-id executor executee dptf-id amount direction)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    ;;
                    (settle-bundle:object{AcquisitionSchemasV1.FVT|StakeSettleBundle}
                        (ref-RPS::URHC_BuildStakeSettleBundle pool-id executee)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 1===
                        ;; PHASE 1.1 — Custody transfer · UrStoa ≡ X_UR|Transfer
                        (ref-AQP::XE_TrueFungibleTransfer
                            patron pool-id executor executee dptf-id amount direction)
                        ;; PHASE 1.2 — Per-pool DPTFTracker · UrStoa ≡ N/A
                        (ref-AQP::XE_TrueFungiblePoolTracker
                            pool-id executor executee dptf-id amount direction)
                        ;; PHASE 1.3 — BenDptfTotal rollup · UrStoa ≡ N/A
                        (ref-AQP::XE_TrueFungibleBeneficiaryRollup
                            pool-id executor executee dptf-id amount direction)
                        ;;
                        ;;===>PHASE 2===
                        ;; PHASE 2 — FVT RPS prelude at OLD deb (2.1→2.2→2.3)
                        (ref-RPS::XE_XI_RpsPreScore executee pool-id settle-bundle)
                        ;;
                        ;;===>PHASE 3===
                        ;; PHASE 3.1 — DPTF anchor refresh · UrStoa ≡ N/A (TF only)
                        (XI_RefreshTrueFungibleStakeAnchors executee dptf-id)
                        ;; PHASE 3.2 — DPSF anchor slot · N/A (DPDC son=true)
                        ;; PHASE 3.3 — DPNF anchor slot · N/A (DPDC son=false)
                        ;;
                        ;;===>PHASE 4===
                        ;; PHASE 4 — SCORE vault + user + nzs
                        (ref-SCR::XE_ApplyTrueFungibleStakeDelta
                            pool-id executee dptf-id amount direction
                            (ref-AQP::URC_PoolActiveScoreIds pool-id)
                            (ref-AQP::URC_DptfStakeIsNativeLeg dptf-id)
                        )
                        ;; PHASE 4.5 — Sync FVT|T total-deb-score mirror for vault inject denominator
                        (ref-RPS::XE_XI_SyncFvtTotalDebMirrors (at "pre-member-debs" settle-bundle))
                        ;; PHASE 4.6 — Re-snapshot farm-triplet Level-1 weights (maintained Σ w-user divisor)
                        (ref-RPS::XE_XI_SyncTripletLaneWeights executee (at "settle-plans" settle-bundle))
                        ;; PHASE 4.7 — Presence: stake→add, unstake→recompute (flip false on last withdrawal)
                        (ref-RPS::XE_XI_SyncFvtPresence executee (at "distinct-fvts" settle-bundle) direction)
                        ;;
                        ;;===>PHASE 5===
                        ;; PHASE 5.1 — RPS unclaimed-count · UrStoa ≡ UpdateUnclaimedCount
                        (ref-RPS::XE_XI_BookStakeUnclaimedCounts executee pool-id settle-bundle)
                        ;; PHASE 5.2 — RPS checkpoint last-rps · UrStoa ≡ UpdateUserRPS
                        (ref-RPS::XE_XI_CheckpointStakeRps executee pool-id settle-bundle)
                    ]
                    []
                )
            )
        )
    )
    )
    ;;
    ;; --- OF stake/unstake recipe (Talos ×4 → CC_OrtoFungibleStakeFlow) ---
    ;;   No phase 2.2 — ANK anchors are DPTF / DPSF / DPNF only; OF custody does not refresh promile.
    (defun CC_OrtoFungibleStakeFlow:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string pool-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
        @doc "Core OrtoFungible stake/unstake recipe. Phases 1 → 2 → 3 → 4 → 5 — see canonical map above. \
            \ OF: phase 1.3 and 3.x are N/A (comment-only in ICO list)."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>ORTO-FUNGIBLE-STAKE-FLOW pool-id executor executee dpof-id nonces nonce-amounts direction)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    ;;
                    ;; M5: executee is authoritative BOTH directions (stake and unstake). The caller supplies
                    ;; the real beneficiary on unstake too, so the exact (owner, beneficiary) tracker row is settled —
                    ;; no self-key derivation (which stranded non-self stakes). Sufficiency is enforced in the cap.
                    (settle-beneficiary:string executee)
                    (settle-bundle:object{AcquisitionSchemasV1.FVT|StakeSettleBundle}
                        (ref-RPS::URHC_BuildStakeSettleBundle pool-id settle-beneficiary)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 1===
                        ;; PHASE 1.1 — Custody transfer · UrStoa ≡ X_UR|Transfer
                        (ref-AQP::XE_OrtoFungibleTransfer
                            patron pool-id executor executee dpof-id nonces nonce-amounts direction)
                        ;; PHASE 1.2 — Per-pool DPOFTracker · UrStoa ≡ N/A
                        (ref-AQP::XE_OrtoFungiblePoolTracker
                            pool-id executor executee dpof-id nonces nonce-amounts direction)
                        ;; PHASE 1.3 — Beneficiary rollup slot · N/A (OF)
                        ;;
                        ;;===>PHASE 2===
                        ;; PHASE 2 — FVT RPS prelude at OLD deb (2.1→2.2→2.3)
                        (ref-RPS::XE_XI_RpsPreScore settle-beneficiary pool-id settle-bundle)
                        ;;
                        ;;===>PHASE 3===
                        ;; PHASE 3.1 — DPTF anchor slot · N/A (OF)
                        ;; PHASE 3.2 — DPSF anchor slot · N/A (DPDC son=true)
                        ;; PHASE 3.3 — DPNF anchor slot · N/A (DPDC son=false)
                        ;;
                        ;;===>PHASE 4===
                        ;; PHASE 4 — SCORE vault + user + nzs
                        (ref-SCR::XE_ApplyOrtoFungibleStakeDelta
                            pool-id settle-beneficiary dpof-id nonces nonce-amounts direction
                            (ref-AQP::URC_PoolActiveScoreIds pool-id)
                        )
                        ;; PHASE 4.5 — Sync FVT|T total-deb-score mirror for vault inject denominator
                        (ref-RPS::XE_XI_SyncFvtTotalDebMirrors (at "pre-member-debs" settle-bundle))
                        ;; PHASE 4.6 — Re-snapshot farm-triplet Level-1 weights (maintained Σ w-user divisor)
                        (ref-RPS::XE_XI_SyncTripletLaneWeights settle-beneficiary (at "settle-plans" settle-bundle))
                        ;; PHASE 4.7 — Presence: stake→add, unstake→recompute (flip false on last withdrawal)
                        (ref-RPS::XE_XI_SyncFvtPresence settle-beneficiary (at "distinct-fvts" settle-bundle) direction)
                        ;;
                        ;;===>PHASE 5===
                        ;; PHASE 5.1 — RPS unclaimed-count · UrStoa ≡ UpdateUnclaimedCount
                        (ref-RPS::XE_XI_BookStakeUnclaimedCounts settle-beneficiary pool-id settle-bundle)
                        ;; PHASE 5.2 — RPS checkpoint last-rps · UrStoa ≡ UpdateUserRPS
                        (ref-RPS::XE_XI_CheckpointStakeRps settle-beneficiary pool-id settle-bundle)
                    ]
                    []
                )
            )
        )
    )
    )
    ;;
    ;; --- DPDC collectable stake/unstake recipe (Talos ×4 → CC_CollectableStakeFlow; son=true DPSF / false DPNF) ---
    (defun CC_CollectableStakeFlow:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Core DPDC collectable stake/unstake recipe. Phases 1 → 2 → 3 → 4 → 5 — see canonical map above. \
            \ son=true DPSF (phase 3.2); son=false DPNF (phase 3.3). Phase 1.3 N/A."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability
            (FVT|C>COLLECTABLE-STAKE-FLOW
                pool-id executor executee collectable-id son nonces nonce-amounts direction
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    ;;
                    ;; M5: executee is authoritative BOTH directions (see CC_OrtoFungibleStakeFlow). The caller
                    ;; supplies the real beneficiary on unstake, so the exact (owner, beneficiary) tracker + Ben rollup
                    ;; rows are settled — no self-key derivation. Sufficiency is enforced in the cap.
                    (settle-beneficiary:string executee)
                    (settle-bundle:object{AcquisitionSchemasV1.FVT|StakeSettleBundle}
                        (ref-RPS::URHC_BuildStakeSettleBundle pool-id settle-beneficiary)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 1===
                        ;; PHASE 1.1 — Custody transfer · UrStoa ≡ X_UR|Transfer
                        (ref-AQP::XE_CollectableTransfer
                            patron pool-id executor executee collectable-id son nonces nonce-amounts direction)
                        ;; PHASE 1.2 — Per-pool DPSF/DPNF tracker · UrStoa ≡ N/A
                        (ref-AQP::XE_CollectablePoolTracker
                            pool-id executor executee collectable-id son nonces nonce-amounts direction)
                        ;; PHASE 1.3 — BenDpsf* / BenDpnf* cross-pool rollup · UrStoa ≡ N/A
                        (ref-AQP::XE_CollectableBeneficiaryRollup
                            pool-id executor executee collectable-id son nonces nonce-amounts direction)
                        ;;
                        ;;===>PHASE 2===
                        ;; PHASE 2 — FVT RPS prelude at OLD deb (2.1→2.2→2.3)
                        (ref-RPS::XE_XI_RpsPreScore settle-beneficiary pool-id settle-bundle)
                        ;;
                        ;;===>PHASE 3===
                        ;; PHASE 3.1 — DPTF anchor slot · N/A (TF)
                        ;; PHASE 3.2 — DPSF anchor refresh · AQP-ANK::XE_UpdateSemiFungibleUserAnchorValues (son=true)
                        ;; PHASE 3.3 — DPNF anchor refresh · AQP-ANK::XE_UpdateNonFungibleUserAnchorValues (son=false)
                        (XI_RefreshCollectableStakeAnchors
                            settle-beneficiary collectable-id son nonces nonce-amounts direction)
                        ;;
                        ;;===>PHASE 4===
                        ;; PHASE 4 — SCORE vault + user + nzs
                        (ref-SCR::XE_ApplyCollectableStakeDelta
                            pool-id settle-beneficiary collectable-id son nonces nonce-amounts direction
                            (ref-AQP::URC_PoolActiveScoreIds pool-id)
                        )
                        ;; PHASE 4.5 — Sync FVT|T total-deb-score mirror for vault inject denominator
                        (ref-RPS::XE_XI_SyncFvtTotalDebMirrors (at "pre-member-debs" settle-bundle))
                        ;; PHASE 4.6 — Re-snapshot farm-triplet Level-1 weights (maintained Σ w-user divisor)
                        (ref-RPS::XE_XI_SyncTripletLaneWeights settle-beneficiary (at "settle-plans" settle-bundle))
                        ;; PHASE 4.7 — Presence: stake→add, unstake→recompute (flip false on last withdrawal)
                        (ref-RPS::XE_XI_SyncFvtPresence settle-beneficiary (at "distinct-fvts" settle-bundle) direction)
                        ;;
                        ;;===>PHASE 5===
                        ;; PHASE 5.1 — RPS unclaimed-count · UrStoa ≡ UpdateUnclaimedCount
                        (ref-RPS::XE_XI_BookStakeUnclaimedCounts settle-beneficiary pool-id settle-bundle)
                        ;; PHASE 5.2 — RPS checkpoint last-rps · UrStoa ≡ UpdateUserRPS
                        (ref-RPS::XE_XI_CheckpointStakeRps settle-beneficiary pool-id settle-bundle)
                    ]
                    []
                )
            )
        )
    )
    )



    ;;<=====================================================================>
    ;;  #75 FACADE — thin delegating wrappers onto the RPS reward engine
    (defun URC_CollectClaimableRewards:decimal (patron:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_CollectClaimableRewards patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
    )
    (defun URC_FvtUserStillPresent:bool (fvt-id:string user-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_FvtUserStillPresent fvt-id user-id)
    )
    (defun URC_InjectDenominator:decimal (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_InjectDenominator fvt-id)
    )
    (defun URC_LiveClaimable:decimal (user-id:string fvt-id:string pool-id:string score-entity-type:integer score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_LiveClaimable user-id fvt-id pool-id score-entity-type score-entity-id dptf-id)
    )
    (defun URC_MemberEffectiveCapture:decimal (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_MemberEffectiveCapture fvt-id score-entity-id)
    )
    (defun URC_MemberLevel2Weight:decimal (fvt-id:string score-entity-type:integer score-entity-id:string swpair:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_MemberLevel2Weight fvt-id score-entity-type score-entity-id swpair)
    )
    (defun URC_PoolEmployedScoresFvtStakeReady:bool (pool-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_PoolEmployedScoresFvtStakeReady pool-id)
    )
    (defun URC_ScoreEntityUserWeight:decimal (user-id:string fvt-id:string pool-id:string score-entity-type:integer score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_ScoreEntityUserWeight user-id fvt-id pool-id score-entity-type score-entity-id)
    )
    (defun URC_StakeScoreDeltaSum:decimal (pool-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_StakeScoreDeltaSum pool-id)
    )
    (defun URC_StreamStatus:object (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_StreamStatus fvt-id dptf-id)
    )
    (defun URC_UserTier1AvailableRewards:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string deb-user:decimal)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_UserTier1AvailableRewards user-id fvt-id score-entity-id dptf-id deb-user)
    )
    (defun URCi_CollectFull:decimal (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URCi_CollectFull patron fvt-id score-entity-type score-entity-id reward-dptf-id)
    )
    (defun URH_FvtEnabledScoreEntityIdsForFvt:[string] (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URH_FvtEnabledScoreEntityIdsForFvt fvt-id)
    )
    (defun URH_FvtPresentUsers:[string] (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URH_FvtPresentUsers fvt-id)
    )
    (defun URH_FvtStalePresentUsers:[string] (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URH_FvtStalePresentUsers fvt-id)
    )
    (defun UR_ExternalOracle:bool ()
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_ExternalOracle)
    )
    (defun UR_FVT-FFC|Count:integer (fvt-id:string dptf-id:string user-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-FFC|Count fvt-id dptf-id user-id)
    )
    (defun UR_FVT-MV|AvailableRewards:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-MV|AvailableRewards fvt-id score-entity-id dptf-id)
    )
    (defun UR_FVT-QS|BronzeSplit:[integer] (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-QS|BronzeSplit fvt-id dptf-id)
    )
    (defun UR_FVT-QS|GoldSplit:[integer] (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-QS|GoldSplit fvt-id dptf-id)
    )
    (defun UR_FVT-QS|Mode:string (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-QS|Mode fvt-id dptf-id)
    )
    (defun UR_FVT-RG|AvailableRewards:decimal (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|AvailableRewards fvt-id dptf-id)
    )
    (defun UR_FVT-RG|CurrentRps:decimal (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|CurrentRps fvt-id dptf-id)
    )
    (defun UR_FVT-RG|RewardEnabled:bool (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|RewardEnabled fvt-id dptf-id)
    )
    (defun UR_FVT-RG|RewardKind:string (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|RewardKind fvt-id dptf-id)
    )
    (defun UR_FVT-RG|RoyaltyRewards:decimal (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|RoyaltyRewards fvt-id dptf-id)
    )
    (defun UR_FVT-RG|StreamCount:integer (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|StreamCount fvt-id dptf-id)
    )
    (defun UR_FVT-RG|StreamUnreleased:decimal (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|StreamUnreleased fvt-id dptf-id)
    )
    (defun UR_FVT-RG|UnclaimedCount:integer (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|UnclaimedCount fvt-id dptf-id)
    )
    (defun UR_FVT-RG|ZombieRewards:decimal (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|ZombieRewards fvt-id dptf-id)
    )
    (defun UR_FVT-RM|LastFarmRpsG:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RM|LastFarmRpsG fvt-id score-entity-id dptf-id)
    )
    (defun UR_FVT-RM|MemberDebRps:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RM|MemberDebRps fvt-id score-entity-id dptf-id)
    )
    (defun UR_FVT-RU|LastRps:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RU|LastRps user-id fvt-id score-entity-id dptf-id)
    )
    (defun UR_FVT-RU|PendingRewards:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RU|PendingRewards user-id fvt-id score-entity-id dptf-id)
    )
    (defun UR_FVT-SEL|CaptureUnits:decimal (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|CaptureUnits fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|CaptureWeight:decimal (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|CaptureWeight fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|Delegation:bool (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|Delegation fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|Enabled:bool (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|Enabled fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|GhostTvlWeight:decimal (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|GhostTvlWeight fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|OracleTs:time (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|OracleTs fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|ScoreEntityType:integer (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|Swpair:string (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|Swpair fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|TotalLaneWeight:decimal (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|TotalLaneWeight fvt-id score-entity-id)
    )
    (defun UR_FVT-UP|IsPresent:bool (fvt-id:string ouronet-account:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-UP|IsPresent fvt-id ouronet-account)
    )
    (defun UR_FVT|EnabledRewardCount:integer (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|EnabledRewardCount fvt-id)
    )
    (defun UR_FVT|FvtClass:integer (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|FvtClass fvt-id)
    )
    (defun UR_FVT|MembershipMode:string (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|MembershipMode fvt-id)
    )
    (defun UR_FVT|Mosaic:bool (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|Mosaic fvt-id)
    )
    (defun UR_FVT|OwnerKonto:string (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|OwnerKonto fvt-id)
    )
    (defun UR_FVT|SplitMode:string (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|SplitMode fvt-id)
    )
    (defun UR_FVT|TotalDebScore:decimal (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|TotalDebScore fvt-id)
    )
    (defun UR_FVT|TotalGhostTvlWeight:decimal (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|TotalGhostTvlWeight fvt-id)
    )
    (defun UR_OracleValidity:integer ()
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_OracleValidity)
    )

    ;;<=========================================================================>
    ;;{6}  REPL
    ;; [REPL] dry-run helpers (not on the interface)
    ;;
    ;; --- REPL dry-run (GOV|FVT_ADMIN; not on AcquisitionFarmsVaultsTreasuriesV1) ---
    ;; Until C_Issue / C_AddScoreEntity / C_AddRewardLink are implemented.
    (defun REPL_BootstrapVault:string
        (fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only: insert class-1 vault + enabled ScoreEntityLink (type 1) + reward-enabled RPS|Global."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (with-capability (GOV|FVT_ADMIN)
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (with-capability (SECURE)
                    (WI_Fvt fvt-id
                        (UDC_FVT|Schema true true "|" false fvt-id)
                    )
                    (ref-RPS::XE_WI_FvtRewardAggregate fvt-id
                        (UDC_FVT|RewardAggregate 1 owner-konto true CT_MEMBERSHIP_MODE_BAR CT_SPLIT_MODE_NA 0.0 0.0 0.0 0.0 0 1 1 fvt-id)
                    )
                    (ref-RPS::XE_WI_ScoreEntityLink fvt-id score-id
                        (RPS.UDC_FVT|ScoreEntityLink CT_SCORE_ENTITY_SCORE true "|" 0.0 0.0 false 0.0 0.0 STREAM_EPOCH fvt-id score-id)
                    )
                    (ref-RPS::XE_WI_RpsGlobal fvt-id reward-dptf-id
                        (RPS.UDC_FVT|RPS|Global true 0.0 0.0 0 0.0 false CT_REWARD_KIND_PLAIN BAR 0 STREAM_EPOCH 0.0 0.0 fvt-id reward-dptf-id)
                    )
                    (ref-SCR::XE_CreateFvtLink score-id fvt-id)
                )
                ;;UNREACHABLE BY A NEGATIVE TEST: this is a POST-CONDITION self-check, not an
                ;;input guard. It asserts that XE_CreateFvtLink on the line above actually wrote
                ;;the link, so the only way to trip it is to break XE_CreateFvtLink itself -- no
                ;;argument to this helper can do it. Worth keeping (a silent no-op write here
                ;;would produce a vault that looks bootstrapped and is not), but it is not
                ;;coverage, and this helper is REPL-only in any case.
                (enforce (= (ref-SCR::UR_SCR|ScoreFvtLink score-id) fvt-id)
                    "REPL_BootstrapVault: SCR fvt-link not set after XE_CreateFvtLink")
            )
        )
        fvt-id
    )
    )
    (defun REPL_BootstrapTreasury:string
        (fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only: insert class-2 treasury + enabled ScoreEntityLink (type 1) + reward-enabled RPS|Global."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (with-capability (GOV|FVT_ADMIN)
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (with-capability (SECURE)
                    (WI_Fvt fvt-id
                        (UDC_FVT|Schema true true "|" false fvt-id)
                    )
                    (ref-RPS::XE_WI_FvtRewardAggregate fvt-id
                        (UDC_FVT|RewardAggregate 2 owner-konto true CT_MEMBERSHIP_MODE_BAR CT_SPLIT_MODE_NA 0.0 0.0 0.0 0.0 0 1 1 fvt-id)
                    )
                    (ref-RPS::XE_WI_ScoreEntityLink fvt-id score-id
                        (RPS.UDC_FVT|ScoreEntityLink CT_SCORE_ENTITY_SCORE true "|" 0.0 0.0 false 0.0 0.0 STREAM_EPOCH fvt-id score-id)
                    )
                    (ref-RPS::XE_WI_RpsGlobal fvt-id reward-dptf-id
                        (RPS.UDC_FVT|RPS|Global true 0.0 0.0 0 0.0 false CT_REWARD_KIND_PLAIN BAR 0 STREAM_EPOCH 0.0 0.0 fvt-id reward-dptf-id)
                    )
                    (ref-SCR::XE_CreateFvtLink score-id fvt-id)
                )
                ;;UNREACHABLE BY A NEGATIVE TEST: this is a POST-CONDITION self-check, not an
                ;;input guard. It asserts that XE_CreateFvtLink on the line above actually wrote
                ;;the link, so the only way to trip it is to break XE_CreateFvtLink itself -- no
                ;;argument to this helper can do it. Worth keeping (a silent no-op write here
                ;;would produce a vault that looks bootstrapped and is not), but it is not
                ;;coverage, and this helper is REPL-only in any case.
                (enforce (= (ref-SCR::UR_SCR|ScoreFvtLink score-id) fvt-id)
                    "REPL_BootstrapTreasury: SCR fvt-link not set after XE_CreateFvtLink")
            )
        )
        fvt-id
    )
    )
)



;;

;; ---- source: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/07_MTX-AQP.pact (module only -- its interface is already live)
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
                            (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
    (defun C_2|Inject (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "2-step enforced-fresh inject (spike fallback for AQP-FVT::CC_Inject; handles up to 2×N_FIX stale \
            \ stakers). Acquires MTX-AQP|C>INJECT, then runs the MTX|2|C_Inject defpact. Advance with \
            \ (continue-pact 1). Vault/treasury only (the defpact's inject is class≠0). \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. MTX-AQP|C>INJECT validates the CONTEXT and \
            \ proves no account. The executor's tokens are debited inside the defpact's step 0, \
            \ which calls AQP-FVT::XB_FvtInject and bottoms out in \
            \ (TFT::C_Transfer patron executor AQP|SC_NAME reward-dptf-id amount). FORWARDED \
            \ cannot see it: the hop is a DEFPACT STEP, and the tool matches direct modref \
            \ calls in the entrypoint's own body. Renamed from <injector>, which was already the \
            \ right account under a local word -- the same rename 05_FVT's three injects took. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (MTX-AQP|C>INJECT patron fvt-id reward-dptf-id amount)
            (MTX|2|C_Inject patron executor fvt-id reward-dptf-id amount)
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
    (defpact MTX|2|C_Inject (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
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
                        (ref-IGNIS::XE_CollectIgnis patron (ref-FVT::XB_FvtInject patron executor fvt-id reward-dptf-id amount))
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
                            (ref-IGNIS::XE_CollectIgnis patron (ref-FVT::XB_FvtInject patron executor fvt-id reward-dptf-id amount))
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

;; ---- source: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/08_DSA.pact (module only -- its interface is already live)
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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


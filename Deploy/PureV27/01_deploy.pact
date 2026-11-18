;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 1 of 9
;; This is STEP 1 of 9 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-0 must have run first, including the init steps between deploys.
;; 3 source file(s), 249,736 gas measured in the REPL gas model, 309,213 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/00_AQP-SCHEMAS.pact
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact
;;
;; TOTAL: 1 interface(s), 2 module(s), 10 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact
;;      module     IGNIS
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/00_AQP-SCHEMAS.pact
;;      interface  AcquisitionSchemasV5
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact
;;      module     AQP-ANK
;;      table      P|T
;;      table      P|MT
;;      table      ANK|T|Anchor
;;      table      ANK|T|BoostClass
;;      table      ANK|T|AssetAnchors
;;      table      ANK|T|BoostClassScoreLinks
;;      table      ANK|T|Anchors
;;      table      ANK|T|UserBoost
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact ===================

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; IgnisCollectorV4: already deployed and unchanged -- see LIVE_INTERFACES


;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; OuronetInfoV3: already deployed and unchanged -- see LIVE_INTERFACES


(module IGNIS GOV
    @doc "IGNIS — the virtual-chain gas collector, implementing IgnisCollectorV3 and \
        \ OuronetInfoV2. It compresses and primes OutputCumulators into per-interactor \
        \ charges, splitting a GAS_QUARTER cut between smart-account interactors and the \
        \ principal; XE_CollectIgnis debits the patron and credits collectors via DALOS balance \
        \ updates, while STOA collection splits native STOA 10/20/30/40 across \
        \ Demiourgos/Dalos/maintenance/Ouroboros. Also hosts shared cost/format helpers and \
        \ the DALOS per-op tier cost readers."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements IgnisCollectorV4)
    (implements OuronetInfoV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_IGNIS                              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|IGNIS_ADMIN)))
    (defcap GOV|IGNIS_ADMIN ()                          (enforce-guard GOV|MD_IGNIS))
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
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities
    (defcap P|IGNIS|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|IGNIS|CALLER))
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
        (with-capability (GOV|IGNIS_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|IGNIS_ADMIN)
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
        (with-capability (GOV|IGNIS_ADMIN)
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
        (with-capability (GOV|IGNIS_ADMIN)
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
                (mg:guard (create-capability-guard (P|IGNIS|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst STOAPREC                                  (CT_StoaPrec))
    ;;
    (defconst DALOS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|DALOS|SC_NAME)
        )
    )
    (defconst OUROBOROS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|OUROBOROS|SC_NAME)
        )
    )
    (defconst GAS_QUARTER 0.25)
    ;;
    ;;  IGNIS COST REHAUL (owner batch 2026-09-05) — THE single home of every pricing constant.
    ;;  1 ignis = 1 USD/EUR cent (hard peg). Everyone reads these via UC_IgnisWeight /
    ;;  UC_IgnisDeter; no module keeps local GAS|/deter constants. Adding a new op later
    ;;  means adding its key here (IGNIS module upgrade) — accepted trade-off for one
    ;;  manageable location. Source of values: OWNER_DECISIONS in
    ;;  REPL/_ignis_deter_worksheet.py == OuronetInformational/IGNIS-PRICING/IGNIS-DETER-WORKSHEET.md.
    ;;
    (defconst IG|WEIGHTS
        {"tx"         : 1.0
        ,"ins"        : 3.0
        ;;update granularity CALIBRATED (substage 6, REPL/Kursan/IGNIS-bucket-calibration.repl):
        ;;measured 5-field vs 1-field update = 2.08x, but the original ceil(fields/2) model
        ;;predicted 3.0x — updates have a HIGH fixed base and a small marginal per field, so the
        ;;divisor moved 2 -> 4 (ceil(fields/4) => 1 field=1, 5 fields=2, ratio 2.0 ~= measured).
        ,"upd-per-4f" : 1.0
        ,"xcall"      : 2.0
        ,"w-s"        : 1.0
        ,"w-m"        : 2.0
        ,"w-l"        : 3.0
        ,"w-xl"       : 5.0
        ;;read multipliers CALIBRATED against measured Pact gas (substage 6,
        ;;REPL/Kursan/IGNIS-bucket-calibration.repl): measured M/L/XL vs S = 2.4 / 5.4 / 9.4.
        ;;The original 1/1/2/3 guess was far too flat — a big row costs nearly as much to read
        ;;as to write. Write multipliers measured 1.72/3.28/5.36 vs model 2/3/5 => kept as-is.
        ,"r-s"        : 1.0
        ,"r-m"        : 2.0
        ,"r-l"        : 5.0
        ,"r-xl"       : 9.0
        ,"wipe-nonce" : 5.0
        ,"frag-nonce" : 100.0}
    )
    ;;
    ;;  IG|LEGS — named INTERNAL write legs charged inside XI_/XB_ writers. These are NOT client
    ;;  ops: one user operation adds several of them (stake a token -> write a tracker slot AND
    ;;  bump a total), so a composed op's price is its own price plus whichever legs it touches.
    ;;  Kept separate from the other two maps ON PURPOSE — IG|DETER is deterrence, IG|COMPONENTS
    ;;  is per-CLIENT-OP work, IG|LEGS is per-WRITE work. Values below are exactly what these
    ;;  sites charged as hardcoded tiers before centralisation (medium 3 / biggest 5), so lifting
    ;;  them here moved no price; from now on a leg is retuned HERE, not hunted for in AQP.
    ;;
    (defconst IG|LEGS
        {"tracker-write-tf"          : 3.0
        ,"tracker-write-of"          : 3.0
        ,"tracker-write-collectable" : 3.0
        ,"tracker-zero-tf"           : 3.0
        ,"ben-total-tf"              : 5.0
        ,"ben-nonce-total-sf"        : 3.0
        ,"ben-nonce-total-nf"        : 3.0
        ,"ank-sync-count-tf"         : 5.0
        ,"ank-sync-count-collectable": 5.0
        ,"stake-anchor-refresh"      : 3.0
        ;;legs lifted out of Stage-1 writers/composers (2026-09-06, same parity rule: each value
        ;;is exactly what its site charged as a hardcoded tier, so lifting moved no price)
        ,"special-tf-link"           : 5.0
        ,"special-of-link"           : 5.0
        ,"vst-link-role-toggle-tf"   : 4.0
        ,"vst-link-role-toggle-of"   : 5.0
        ,"lp-mint"                   : 2.0
        ;;GENERIC UNIT TIERS. Owner 2026-09-07: "we run no more table values, but constants for
        ;;determining prices now." These six are the pre-rehaul DALOS usage-price tiers
        ;;(ignis|smallest .. ignis|biggest, ignis|branding) lifted here VERBATIM, so the move
        ;;changed no price -- only where the number lives. They are per-ITEM units fed to scaling
        ;;formulas (per nonce, per amount, per fragment, per transfer-size band), NOT per-op
        ;;prices; those are IG|DETER + IG|COMPONENTS. Retune a unit here and every site follows.
        ,"tier-smallest"             : 1.0
        ,"tier-small"                : 2.0
        ,"tier-medium"               : 3.0
        ,"tier-big"                  : 4.0
        ,"tier-biggest"              : 5.0
        ,"tier-branding"             : 100.0
        ;;The old ignis|token-issue (500), kept as a LEG because its one surviving live site is
        ;;MTX-SWP::C_AddSleepingLiquidity, where it is a leg INSIDE a defpact that already
        ;;carries deter:issue-swp-pair 5000 -- it was never that op's own price.
        ,"tier-token-issue"          : 500.0}
    )
    (defconst IG|DETER
        {"usage"             : 1.0
        ,"setup"             : 5.0
        ,"auth"              : 10.0
        ,"fee"               : 25.0
        ,"small"             : 50.0
        ,"token-account"     : 50.0
        ,"issue-tf"          : 1000.0
        ,"issue-of"          : 1000.0
        ,"issue-sft"         : 2000.0
        ,"issue-nft"         : 2500.0
        ,"issue-ats-pair"    : 4000.0
        ,"issue-swp-pair"    : 5000.0
        ,"issue-shareholder" : 10000.0
        ,"issue-dsa-vault"   : 5000.0
        ,"issue-dsa-agency"  : 2000.0
        ;;a VST link's OWN deterrence ($2.50); the DPTF/DPOF it issues is charged separately
        ,"vst-link"          : 250.0
        ,"lp-churn"          : 1000.0
        ;;Anchors are a FLAT 500 regardless of what they anchor (owner 2026-09-06). This
        ;;SUPERSEDES the 2026-09-05 rule of "half the issuance price of the anchored asset"
        ;;(anchor-tf 500 / anchor-sf 1000 / anchor-nf 1250), which is why there is now a single
        ;;key. The op's component cost is charged ON TOP, like every other priced op.
        ,"anchor"            : 500.0
        ,"revoke-anchor"     : 100.0
        ,"revoke-boost"      : 500.0
        ,"combine-triplet"   : 100.0
        ,"add-score"         : 200.0
        ,"revoke-score"      : 250.0
        ,"pool-stake-toggle" : 50.0
        ,"fvt-split-setup"   : 100.0
        ,"fvt-link-toggle"   : 50.0
        ;;100 -> 50 (owner, 2026-10-26). Unstaling is permissionless maintenance that makes
        ;;someone ELSE's inject cheaper, so it belongs with `sync-anchors` (50) rather than at
        ;;twice its price.
        ,"unstale"           : 50.0
        ,"frag-enable"       : 100.0
        ;; legacy-honored flat values (owner batch did NOT reprice these — values preserved,
        ;; now sourced from here instead of module-local GAS| defconsts; substage 5 rewire):
        ,"issue-score"       : 1000.0
        ,"issue-triplet"     : 500.0
        ,"issue-score-model" : 500.0
        ,"issue-pool"        : 1000.0
        ,"issue-fvt"         : 1000.0
        ,"issue-multiplet"   : 500.0
        ,"add-score-entity"  : 500.0
        ,"add-reward-link"   : 500.0
        ;;COLLECT AND INJECT CARRY NO DETERRENCE (owner ruling, 2026-10-26). Both were 500 and
        ;;both were sitting in the "legacy-honored" block below, never actually repriced -- so
        ;;they inherited an ISSUANCE tier. Deterrence exists to make SPAM CREATION expensive;
        ;;these two are the opposite of creation. Collecting is a holder claiming earnings he
        ;;has already accrued, done daily across several aggregators; injecting is an owner
        ;;funding his own lane, which is the entire point of having created it. Charging either
        ;;a creation-tier flat fee taxes the system's most routine actions hardest: four daily
        ;;collects cost ~2,230 IGNIS just to be paid.
        ;;
        ;;ZERO IS THE DETERRENCE, NOT THE PRICE. `UC_IgnisPrice` is (deter + components), so
        ;;both ops still pay their REAL computed work -- 57 for CC_Collect, and the inject's own
        ;;component cost. What is removed is the arbitrary flat charge on top of it.
        ,"aqp-inject"        : 0.0
        ,"aqp-collect"       : 0.0
        ,"sync-anchors"      : 50.0
        ;;Re-rating is permissionless maintenance, like the anchor syncs it sits beside, so it
        ;;carries their deterrence rather than a settings-change tier. The charge is FLAT per
        ;;transaction while the component charge is PER HOLDER, which is the combination that
        ;;makes a one-account slice uneconomic and a forty-account slice cheap -- the sweep is
        ;;designed to be fanned out in batches, not fired one holder at a time.
        ,"backfill"          : 50.0
        ,"recompute-capture" : 300.0
        ,"set-oracle-auth"   : 300.0
        ,"oracle-write"      : 200.0
        ,"royalty-dispose"   : 400.0
        ,"royalty-fuel"      : 500.0
        ,"set-agency-fee"    : 300.0
        ;;Ouronet ACCOUNT CREATION carries NO IGNIS charge — these two entries are the DOLLAR
        ;;BASIS for its STOA leg only ($5 standard / $10 smart), consumed via UC_StoaPrice and
        ;;gated by DALOS's account-creation-stoa switch.
        ,"acct-standard"     : 500.0
        ,"acct-smart"        : 1000.0
        ;;Unlocking fee parameters costs a FLAT $50 in IGNIS and $50 in STOA, every time
        ;;(owner 2026-09-06). This REPLACES the old escalating ladder (base x (unlocks+1),
        ;;unbounded), whose intent was cheap-first/punitive-later; flat makes unlocking
        ;;uniformly expensive and not worth doing casually.
        ;;Blue-flag BRANDING carries no IGNIS charge either — this is the DOLLAR BASIS for its
        ;;STOA leg only: $25 per month (owner 2026-09-07), consumed via UC_StoaPrice, so
        ;;BRD::URCi_UpgradeBranding = months x 250 STOA at the $0.10 peg.
        ,"branding-blue"     : 2500.0
        ;;PYTHIA tolls carry NO IGNIS charge — dollar basis for their STOA leg only, and they
        ;;are NON-DISCOUNTABLE (collected with XB_CollectStoaFull). $50 deploy / $10 rename
        ;;(owner 2026-09-07) = 500 / 100 STOA at the $0.10 peg, i.e. exactly today's amounts.
        ;;Defining a collectable SET is NOT an issuance (no STOA leg) -- it only carries its
        ;;own IGNIS deterrence of $5 (owner 2026-09-07). The collectable itself is taxed on
        ;;its own issue.
        ,"define-set"        : 500.0
        ;;Adding/removing an ATS secondary is a LINK, not an issuance: small deterrent only,
        ;;the same deal as a VST link (owner 2026-09-07). The ortofungible being linked is
        ;;taxed on its own issue.
        ,"ats-secondary"     : 250.0
        ;;Withdrawing accrued fees is a FLAT 100x deterrence and nothing else -- the one
        ;;op that deliberately charges deter with NO component cost (owner 2026-09-07).
        ,"fee-withdraw"      : 100.0
        ,"pythia-deploy"     : 5000.0
        ,"pythia-rename"     : 1000.0
        ,"fee-unlock"        : 5000.0}
    )
    ;;
    ;;  IG|COMPONENTS — the PROPER IGNIS COMPUTATION per client op: the cost of the work it
    ;;  actually does (writes/updates/reads/scans/cross-module hops), priced with IG|WEIGHTS
    ;;  and calibrated against measured gas. This is the half that is NOT deterrence: an op's
    ;;  total is UC_IgnisPrice = deter + components. Keyed by the TALOS client name
    ;;  <ENTITY>|<FN>, so this map, the price sheet and the deter worksheet are one list.
    ;;  GENERATED — regenerate with REPL/_ignis_price_sheet.py's analyser after code changes.
    ;;
    (defconst IG|COMPONENTS
        {"AQP-ANK|C_IssueNonFungibleAnchor"             : 74.0
        ,"AQP-ANK|C_IssueNonFungibleSetAnchor"          : 74.0
        ,"AQP-ANK|C_IssueSemiFungibleAnchor"            : 74.0
        ,"AQP-ANK|C_IssueTrueFungibleAnchor"            : 74.0
        ,"AQP-ANK|C_RevokeAnchor"                       : 67.0
        ,"AQP-ANK|C_RevokeBoostClass"                   : 10.0
        ,"AQP-DSA|C_BurnRoyalty"                        : 5.0
        ,"AQP-DSA|C_DefineDelegationVault"              : 11.0
        ,"AQP-DSA|C_FuelRoyalty"                        : 5.0
        ,"AQP-DSA|CC_OpenAgency"                         : 11.0
        ,"AQP-DSA|C_OracleWrite"                        : 22.0
        ,"AQP-DSA|C_RecomputeCapture"                   : 21.0
        ,"AQP-DSA|C_SetAgencyFee"                       : 8.0
        ,"AQP-DSA|C_SetOracleAuth"                      : 10.0
        ,"AQP-DSA|C_WithdrawRoyalty"                    : 5.0
        ,"AQP-FVT|CC_Collect"                           : 57.0
        ,"AQP-FVT|CC_Inject"                            : 21.0
        ,"AQP-FVT|CC_InjectFinalize"                    : 7.0
        ,"AQP-FVT|CC_InjectStream"                      : 5.0
        ,"AQP-FVT|CC_LatchStreamEligible"               : 23.0
        ,"AQP-FVT|CC_SweepBegin"                        : 19.0
        ,"AQP-FVT|CC_SweepRevokeAnchor"                 : 29.0
        ,"AQP-FVT|CC_UnstaleMyScores"                   : 11.0
        ,"AQP-FVT|CCp_InjectFixChunk"                   : 13.0
        ,"AQP-FVT|CCp_SweepRecomputeChunk"              : 17.0
        ,"AQP-FVT|CCp_UnstaleAll"                       : 23.0
        ,"AQP-FVT|C_AddRewardLink"                      : 11.0
        ,"AQP-FVT|C_AddScoreEntity"                     : 39.0
        ,"AQP-FVT|C_Control"                            : 8.0
        ,"AQP-FVT|C_Issue"                              : 19.0
        ,"AQP-FVT|C_IssueMultipletFamily"               : 9.0
        ,"AQP-FVT|C_RotateOwnership"                    : 7.0
        ,"AQP-FVT|C_SetCommonDenominator"               : 10.0
        ,"AQP-FVT|C_SetMosaic"                          : 11.0
        ,"AQP-FVT|C_SetQualitySplit"                    : 11.0
        ,"AQP-FVT|C_SetSplitMode"                       : 11.0
        ,"AQP-FVT|C_ToggleRewardLink"                   : 11.0
        ,"AQP-FVT|C_ToggleScoreEntityLink"              : 11.0
        ,"AQP-POOL|CC_FullVacate"                       : 97.0
        ,"AQP-POOL|CC_StakeNonFungibleCollectable"      : 39.0
        ,"AQP-POOL|CC_StakeOrtoFungible"                : 27.0
        ,"AQP-POOL|CC_StakeSemiFungibleCollectable"     : 39.0
        ,"AQP-POOL|CC_StakeTrueFungible"                : 39.0
        ,"AQP-POOL|CC_UnstakeNonFungibleCollectable"    : 39.0
        ,"AQP-POOL|CC_UnstakeOrtoFungible"              : 27.0
        ,"AQP-POOL|CC_UnstakeSemiFungibleCollectable"   : 39.0
        ,"AQP-POOL|CC_UnstakeTrueFungible"              : 39.0
        ,"AQP-POOL|CCp_BatchDrainCollectable"           : 41.0
        ,"AQP-POOL|CCp_BatchDrainOrtoFungible"          : 37.0
        ,"AQP-POOL|CCp_BatchDrainTrueFungible"          : 43.0
        ,"AQP-POOL|CCp_BatchVacateCollectables"         : 63.0
        ,"AQP-POOL|CCp_BatchVacateOrtoFungible"         : 59.0
        ,"AQP-POOL|CCp_BatchVacateTrueFungible"         : 65.0
        ,"AQP-POOL|C_AbortVacate"                       : 13.0
        ,"AQP-POOL|C_AddScore"                          : 43.0
        ,"AQP-POOL|C_DisablePoolStake"                  : 6.0
        ,"AQP-POOL|C_EnablePoolStake"                   : 6.0
        ,"AQP-POOL|C_FinalizeVacate"                    : 17.0
        ,"AQP-POOL|C_Issue"                             : 20.0
        ,"AQP-POOL|C_RevokeScore"                       : 48.0
        ,"AQP-POOL|C_SyncNonFungibleAnchors"            : 36.0
        ,"AQP-POOL|C_SyncSemiFungibleAnchors"           : 36.0
        ,"AQP-POOL|C_SyncTrueFungibleAnchors"           : 16.0
        ,"AQP-POOL|CC_UpdateScoreMultipliers"            : 13.0
        ,"AQP-POOL|CCp_BackfillScoreSlice"              : 9.0
        ;;THE THREE-PHASE SCORE REVOKE, plus the freeze release. The two config writes are
        ;;priced with the other pool settings; the DRAIN is priced like the re-rate it mirrors,
        ;;per holder, because that is what the transaction does one of per account.
        ,"AQP-POOL|C_BeginScoreRevoke"                 : 13.0
        ,"AQP-POOL|Cp_DrainScoreSlice"                : 9.0
        ,"AQP-POOL|CC_FinalizeScoreRevoke"              : 13.0
        ,"AQP-FVT|CC_ClearPoolSweep"                   : 5.0
        ,"AQP-SCR|C_CombineTripletScoreModel"           : 16.0
        ,"AQP-SCR|C_ControlScore"                       : 13.0
        ,"AQP-SCR|C_CreateScoreBoostClassLink"          : 26.0
        ,"AQP-SCR|C_CreateScoreBoostLink"               : 13.0
        ,"AQP-SCR|C_EnableDebBoost"                     : 13.0
        ;;Same shape and same cost as EnableDebBoost: one owner-gated flag on the score row, one
        ;;point write, refused unless the score is empty. Nothing scans.
        ,"AQP-SCR|C_SetSingleShareWeight"                : 13.0
        ,"AQP-SCR|C_IssueLiquidityScore"                : 28.0
        ,"AQP-SCR|C_IssueNonFungibleScore"              : 28.0
        ,"AQP-SCR|C_IssueNonFungibleScoreDefinition"    : 48.0
        ,"AQP-SCR|C_IssueNonFungibleSetScoreDefinition" : 48.0
        ,"AQP-SCR|C_IssueOrtoFungibleScore"             : 28.0
        ,"AQP-SCR|C_IssueScoreFromModel"                : 69.0
        ,"AQP-SCR|C_IssueSemiFungibleScore"             : 28.0
        ,"AQP-SCR|C_IssueSemiFungibleScoreDefinition"   : 26.0
        ,"AQP-SCR|C_IssueSingleScoreModel"              : 16.0
        ,"AQP-SCR|C_IssueTriplet"                       : 39.0
        ,"AQP-SCR|C_IssueTrueFungibleScore"             : 28.0
        ,"AQP-SCR|C_LockScoreDrift"                     : 13.0
        ,"AQP-SCR|C_RotateScoreOwnership"               : 13.0
        ,"ATS|AA_RemoveSecondary"                        : 41.0
        ,"ATS|C_AddHotRBT"                              : 26.0
        ,"ATS|C_AddSecondary"                           : 29.0
        ,"ATS|C_Brumate"                                : 37.0
        ,"ATS|C_Coil"                                   : 17.0
        ,"ATS|C_ColdRecovery"                           : 123.0
        ,"ATS|C_Constrict"                              : 29.0
        ,"ATS|C_Control"                                : 19.0
        ,"ATS|C_ControlColdRecoveryFees"                : 19.0
        ,"ATS|C_ControlHotRecoveryFee"                  : 19.0
        ,"ATS|C_Cull"                                   : 125.0
        ,"ATS|C_Curl"                                   : 25.0
        ,"ATS|C_DirectRecovery"                         : 27.0
        ,"ATS|C_Fuel"                                   : 7.0
        ,"ATS|C_HotRecovery"                            : 25.0
        ,"ATS|C_Issue"                                  : 52.0
        ,"ATS|C_KickStart"                              : 3.0
        ,"ATS|C_Redeem"                                 : 41.0
        ,"ATS|CC_RemoveSecondary"                        : 41.0
        ,"ATS|C_Reverse"                                : 19.0
        ,"ATS|C_RotateOwnership"                        : 19.0
        ,"ATS|C_SetColdRecoveryDuration"                : 24.0
        ,"ATS|C_SetColdRecoveryFees"                    : 14.0
        ,"ATS|C_SetDirectRecoveryFee"                   : 19.0
        ,"ATS|C_SetHibernationFees"                     : 19.0
        ,"ATS|C_SetHotRecoveryFee"                      : 15.0
        ,"ATS|C_SwitchColdRecovery"                     : 19.0
        ,"ATS|C_SwitchDirectRecovery"                   : 19.0
        ,"ATS|C_SwitchHotRecovery"                      : 19.0
        ,"ATS|C_Syphon"                                 : 13.0
        ,"ATS|C_ToggleElite"                            : 19.0
        ,"ATS|C_ToggleParameterLock"                    : 26.0
        ,"ATS|C_ToggleUpgrade"                          : 19.0
        ,"ATS|C_UpdatePendingBranding"                  : 16.0
        ,"ATS|C_UpdateRoyalty"                          : 19.0
        ,"ATS|C_UpdateSyphon"                           : 19.0
        ,"ATS|C_UpgradeBranding"                        : 18.0
        ,"ATS|C_VestedCoil"                             : 17.0
        ,"ATS|C_VestedCurl"                             : 25.0
        ,"ATS|C_WithdrawRoyalties"                      : 11.0
        ,"CODEX|C_RecordArweaveUpload"                  : 9.0
        ,"CODEX|C_RegisterStoicTag"                     : 17.0
        ,"CODEX|C_ReleaseStoicTag"                      : 7.0
        ,"CODEX|C_RotateCodexGuard"                     : 4.0
        ,"CUSTODIANS|C_Acquire"                         : 29.0
        ,"DALOS|C_ControlSmartAccount"                  : 4.0
        ;;UpdateEliteAccount / …Squared were MISSING from the generated map (same class of
        ;;omission as SWP|C_IssueStandard). Valued from the ControlSmartAccount shape they share:
        ;;a single elite-tier recompute per account touched, so the Squared variant is 2x.
        ,"DALOS|C_UpdateEliteAccount"                   : 4.0
        ,"DALOS|C_UpdateEliteAccountSquared"            : 8.0
        ,"DALOS|C_RotateGovernor"                       : 4.0
        ,"DALOS|C_RotateGuard"                          : 14.0
        ,"DALOS|C_RotateSovereign"                      : 4.0
        ,"DALOS|C_RotateStoa"                           : 24.0
        ,"DEMIPAD|C_Deposit"                            : 117.0
        ,"DEMIPAD|C_FuelNonFungible"                    : 13.0
        ,"DEMIPAD|C_FuelOrtoFungible"                   : 9.0
        ,"DEMIPAD|C_FuelSemiFungible"                   : 13.0
        ,"DEMIPAD|C_FuelTrueFungible"                   : 9.0
        ,"DEMIPAD|C_RetrieveNonFungible"                : 13.0
        ,"DEMIPAD|C_RetrieveOrtoFungible"               : 9.0
        ,"DEMIPAD|C_RetrieveSemiFungible"               : 13.0
        ,"DEMIPAD|C_RetrieveTrueFungible"               : 9.0
        ,"DEMIPAD|C_Withdraw"                           : 29.0
        ,"DPDC|C_BulkTransfer"                          : 25.0
        ,"DPDC|C_MultiTransfer"                         : 25.0
        ,"DPNF|C_Break"                                 : 19.0
        ,"DPNF|C_Burn"                                  : 13.0
        ,"DPNF|C_Control"                               : 15.0
        ,"DPNF|C_Create"                                : 47.0
        ,"DPNF|C_DefineCompositeSet"                    : 43.0
        ,"DPNF|C_DefineHybridSet"                       : 45.0
        ,"DPNF|C_DefinePrimordialSet"                   : 43.0
        ,"DPNF|C_EnableNonceFragmentation"              : 17.0
        ,"DPNF|C_EnableSetClassFragmentation"           : 11.0
        ,"DPNF|C_Issue"                                 : 49.0
        ,"DPNF|C_Make"                                  : 31.0
        ,"DPNF|C_MakeFragments"                         : 17.0
        ,"DPNF|C_MergeFragments"                        : 17.0
        ,"DPNF|C_MoveCreateRole"                        : 19.0
        ,"DPNF|C_MoveRecreateRole"                      : 19.0
        ,"DPNF|C_MoveSetUriRole"                        : 19.0
        ,"DPNF|C_RenameSet"                             : 9.0
        ,"DPNF|C_Repurpose"                             : 37.0
        ,"DPNF|C_RepurposeFragments"                    : 37.0
        ,"DPNF|C_Respawn"                               : 9.0
        ,"DPNF|C_ToggleBurnRole"                        : 13.0
        ,"DPNF|C_ToggleExemptionRole"                   : 13.0
        ,"DPNF|C_ToggleFreezeAccount"                   : 13.0
        ,"DPNF|C_ToggleModifyCreatorRole"               : 13.0
        ,"DPNF|C_ToggleModifyRoyaltiesRole"             : 13.0
        ,"DPNF|C_TogglePause"                           : 9.0
        ,"DPNF|C_ToggleSet"                             : 9.0
        ,"DPNF|C_ToggleTransferRole"                    : 13.0
        ,"DPNF|C_ToggleUpdateRole"                      : 13.0
        ,"DPNF|C_TransferNonce"                         : 25.0
        ,"DPNF|C_TransferNonces"                        : 25.0
        ,"DPNF|C_UpdateNonce"                           : 17.0
        ,"DPNF|C_UpdateNonceDescription"                : 17.0
        ,"DPNF|C_UpdateNonceIgnisRoyalty"               : 17.0
        ,"DPNF|C_UpdateNonceMetaData"                   : 17.0
        ,"DPNF|C_UpdateNonceName"                       : 17.0
        ,"DPNF|C_UpdateNonceRoyalty"                    : 17.0
        ,"DPNF|C_UpdateNonceScore"                      : 17.0
        ,"DPNF|C_UpdateNonceURI"                        : 17.0
        ,"DPNF|C_UpdateNonces"                          : 17.0
        ,"DPNF|C_UpdatePendingBranding"                 : 7.0
        ,"DPNF|C_UpdateSetNonce"                        : 17.0
        ,"DPNF|C_UpdateSetNonceDescription"             : 17.0
        ,"DPNF|C_UpdateSetNonceIgnisRoyalty"            : 17.0
        ,"DPNF|C_UpdateSetNonceMetaData"                : 17.0
        ,"DPNF|C_UpdateSetNonceName"                    : 17.0
        ,"DPNF|C_UpdateSetNonceRoyalty"                 : 17.0
        ,"DPNF|C_UpdateSetNonceScore"                   : 17.0
        ,"DPNF|C_UpdateSetNonceURI"                     : 17.0
        ,"DPNF|C_UpdateSetNonces"                       : 17.0
        ,"DPNF|C_UpgradeBranding"                       : 7.0
        ,"DPNF|C_WipeClean"                             : 35.0
        ,"DPNF|C_WipeDirty"                             : 33.0
        ,"DPNF|CC_WipeHeavy"                             : 33.0
        ,"DPNF|C_WipeNonce"                             : 25.0
        ,"DPNF|C_WipePure"                              : 33.0
        ,"DPNF|Cp_WipeSlice"                            : 23.0
        ,"DPOF|A_DeployAccount"                         : 27.0
        ,"DPOF|C_AddQuantity"                           : 78.0
        ,"DPOF|C_BulkTransfer"                          : 54.0
        ,"DPOF|C_Burn"                                  : 45.0
        ,"DPOF|C_Control"                               : 20.0
        ,"DPOF|C_DeployAccount"                         : 27.0
        ,"DPOF|C_Issue"                                 : 73.0
        ,"DPOF|C_Mint"                                  : 80.0
        ,"DPOF|C_MoveCreateRole"                        : 47.0
        ,"DPOF|C_RotateOwnership"                       : 19.0
        ,"DPOF|C_ToggleAddQuantityRole"                 : 53.0
        ,"DPOF|C_ToggleBurnRole"                        : 53.0
        ,"DPOF|C_ToggleFreezeAccount"                   : 53.0
        ,"DPOF|C_TogglePause"                           : 19.0
        ,"DPOF|C_ToggleTransferRole"                    : 53.0
        ,"DPOF|C_Transfer"                              : 54.0
        ,"DPOF|C_Transmit"                              : 85.0
        ,"DPOF|C_UpdatePendingBranding"                 : 16.0
        ,"DPOF|C_UpgradeBranding"                       : 47.0
        ,"DPOF|C_WipeClean"                             : 7.0
        ,"DPOF|CC_WipeHeavy"                             : 49.0
        ,"DPOF|C_WipePure"                              : 49.0
        ,"DPOF|C_WipeSlim"                              : 45.0
        ,"DPOF|Cp_WipeSlice"                            : 48.0
        ,"DPSF|C_AddQuantity"                           : 13.0
        ,"DPSF|CC_Break"                                 : 33.0
        ,"DPSF|C_Burn"                                  : 15.0
        ,"DPSF|C_Control"                               : 15.0
        ,"DPSF|C_Create"                                : 47.0
        ,"DPSF|C_DefineCompositeSet"                    : 43.0
        ,"DPSF|C_DefineHybridSet"                       : 45.0
        ,"DPSF|C_DefinePrimordialSet"                   : 43.0
        ,"DPSF|C_EnableNonceFragmentation"              : 17.0
        ,"DPSF|C_EnableSetClassFragmentation"           : 11.0
        ,"DPSF|C_Issue"                                 : 49.0
        ,"DPSF|C_IssueCompany"                          : 93.0
        ,"DPSF|C_Make"                                  : 19.0
        ,"DPSF|C_MakeFragments"                         : 17.0
        ,"DPSF|C_MergeFragments"                        : 17.0
        ,"DPSF|C_MorphEquity"                           : 37.0
        ,"DPSF|C_MoveCreateRole"                        : 19.0
        ,"DPSF|C_MoveRecreateRole"                      : 19.0
        ,"DPSF|C_MoveSetUriRole"                        : 19.0
        ,"DPSF|C_RenameSet"                             : 9.0
        ,"DPSF|C_Repurpose"                             : 37.0
        ,"DPSF|C_RepurposeFragments"                    : 37.0
        ,"DPSF|C_ToggleAddQuantityRole"                 : 13.0
        ,"DPSF|C_ToggleBurnRole"                        : 13.0
        ,"DPSF|C_ToggleExemptionRole"                   : 13.0
        ,"DPSF|C_ToggleFreezeAccount"                   : 13.0
        ,"DPSF|C_ToggleModifyCreatorRole"               : 13.0
        ,"DPSF|C_ToggleModifyRoyaltiesRole"             : 13.0
        ,"DPSF|C_TogglePause"                           : 9.0
        ,"DPSF|C_ToggleSet"                             : 9.0
        ,"DPSF|C_ToggleTransferRole"                    : 13.0
        ,"DPSF|C_ToggleUpdateRole"                      : 13.0
        ,"DPSF|C_TransferNonce"                         : 25.0
        ,"DPSF|C_TransferNonces"                        : 25.0
        ,"DPSF|C_UpdateNonce"                           : 17.0
        ,"DPSF|C_UpdateNonceDescription"                : 17.0
        ,"DPSF|C_UpdateNonceIgnisRoyalty"               : 17.0
        ,"DPSF|C_UpdateNonceMetaData"                   : 17.0
        ,"DPSF|C_UpdateNonceName"                       : 17.0
        ,"DPSF|C_UpdateNonceRoyalty"                    : 17.0
        ,"DPSF|C_UpdateNonceScore"                      : 17.0
        ,"DPSF|C_UpdateNonceURI"                        : 17.0
        ,"DPSF|C_UpdateNonces"                          : 17.0
        ,"DPSF|C_UpdatePendingBranding"                 : 7.0
        ,"DPSF|C_UpdateSetNonce"                        : 17.0
        ,"DPSF|C_UpdateSetNonceDescription"             : 17.0
        ,"DPSF|C_UpdateSetNonceIgnisRoyalty"            : 17.0
        ,"DPSF|C_UpdateSetNonceMetaData"                : 17.0
        ,"DPSF|C_UpdateSetNonceName"                    : 17.0
        ,"DPSF|C_UpdateSetNonceRoyalty"                 : 17.0
        ,"DPSF|C_UpdateSetNonceScore"                   : 17.0
        ,"DPSF|C_UpdateSetNonceURI"                     : 17.0
        ,"DPSF|C_UpdateSetNonces"                       : 17.0
        ,"DPSF|C_UpgradeBranding"                       : 7.0
        ,"DPSF|C_WipeClean"                             : 35.0
        ,"DPSF|C_WipeDirty"                             : 33.0
        ,"DPSF|CC_WipeHeavy"                             : 33.0
        ,"DPSF|C_WipeNonce"                             : 25.0
        ,"DPSF|C_WipeNoncePartialy"                     : 15.0
        ,"DPSF|C_WipePure"                              : 33.0
        ,"DPSF|Cp_WipeSlice"                            : 23.0
        ,"DPTF|A_DeployAccount"                         : 24.0
        ,"DPTF|C_BulkTransfer"                          : 143.0
        ,"DPTF|C_Burn"                                  : 71.0
        ,"DPTF|C_ClearDispo"                            : 51.0
        ,"DPTF|C_ClearDispoForeign"                     : 51.0
        ,"DPTF|C_Control"                               : 20.0
        ,"DPTF|C_DeployAccount"                         : 24.0
        ,"DPTF|C_DonateFees"                            : 19.0
        ,"DPTF|C_Issue"                                 : 70.0
        ,"DPTF|C_Mint"                                  : 86.0
        ,"DPTF|C_MultiBulkTransfer"                     : 143.0
        ,"DPTF|C_MultiTransfer"                         : 139.0
        ,"DPTF|C_ResetFeeTarget"                        : 19.0
        ,"DPTF|C_RotateOwnership"                       : 19.0
        ,"DPTF|C_SetFee"                                : 19.0
        ,"DPTF|C_SetFeeTarget"                          : 19.0
        ,"DPTF|C_SetMinMove"                            : 19.0
        ,"DPTF|C_ToggleBurnRole"                        : 58.0
        ,"DPTF|C_ToggleFee"                             : 19.0
        ,"DPTF|C_ToggleFeeExemptionRole"                : 58.0
        ,"DPTF|C_ToggleFeeLock"                         : 35.0
        ,"DPTF|C_ToggleFreezeAccount"                   : 58.0
        ,"DPTF|C_ToggleMintRole"                        : 58.0
        ,"DPTF|C_TogglePause"                           : 19.0
        ,"DPTF|C_ToggleReservation"                     : 19.0
        ,"DPTF|C_ToggleTransferRole"                    : 58.0
        ,"DPTF|C_Transfer"                              : 137.0
        ,"DPTF|C_Transmute"                             : 101.0
        ,"DPTF|C_UpdatePendingBranding"                 : 16.0
        ,"DPTF|C_UpgradeBranding"                       : 36.0
        ,"DPTF|C_Wipe"                                  : 80.0
        ,"DPTF|C_WipeSlim"                              : 80.0
        ,"KPAY|C_BuyStoicPay"                           : 17.0
        ,"LQD|C_UnwrapStoa"                             : 17.0
        ,"LQD|C_UnwrapUrStoa"                           : 17.0
        ,"LQD|C_WrapStoa"                               : 15.0
        ,"LQD|C_WrapUrStoa"                             : 15.0
        ,"MTX-AQP|2|CC_Inject"                           : 11.0
        ,"MTX-AQP|2|CC_SweepRevokeAnchor"                : 21.0
        ,"ORBR|C_WithdrawFees"                          : 15.0
        ,"PYTHIA|C_DeployApiKey"                        : 9.0
        ,"PYTHIA|C_Link"                                : 10.0
        ,"PYTHIA|C_RevokeLink"                          : 7.0
        ,"PYTHIA|C_UpdateDualConsumerLane"              : 4.0
        ,"SNAKES|C_Acquire"                             : 31.0
        ,"SPARK|C_BuySparks"                            : 15.0
        ,"SPARK|C_RedemAllSparks"                       : 27.0
        ,"SPARK|C_RedemFewSparks"                       : 25.0
        ,"SWP|CC_SmartSwapNoSlippage"                   : 117.0
        ,"SWP|CC_SmartSwapWithSlippage"                 : 117.0
        ,"SWP|C_AddFrozenLiquidity"                     : 57.0
        ,"SWP|C_AddGlacialLiquidity"                    : 51.0
        ,"SWP|C_AddIcedLiquidity"                       : 51.0
        ,"SWP|C_AddSleepingLiquidity"                   : 65.0
        ,"SWP|C_AddStandardLiquidity"                   : 51.0
        ,"SWP|C_ChangeOwnership"                        : 19.0
        ,"SWP|C_EnableFrozenLP"                         : 32.0
        ,"SWP|C_EnableSleepingLP"                       : 32.0
        ,"SWP|C_Firestarter"                            : 15.0
        ,"SWP|C_Fuel"                                   : 21.0
        ,"SWP|C_IssueStable"                            : 35.0
        ;;C_IssueStandard was MISSING from the generated map while its two siblings were
        ;;present; same five-leg shape as Stable/Weighted, so it carries their value.
        ,"SWP|C_IssueStandard"                          : 35.0
        ,"SWP|C_IssueStablePool"                        : 43.0
        ,"SWP|C_IssueStandardPool"                      : 43.0
        ,"SWP|C_IssueWeighted"                          : 35.0
        ,"SWP|C_IssueWeightedPool"                      : 43.0
        ,"SWP|C_ModifyCanChangeOwner"                   : 19.0
        ,"SWP|C_ModifyWeights"                          : 19.0
        ,"SWP|C_MultiSwapNoSlippage"                    : 105.0
        ,"SWP|C_MultiSwapWithSlippage"                  : 105.0
        ,"SWP|C_RemoveLiquidity"                        : 29.0
        ,"SWP|C_SingleSwapNoSlippage"                   : 105.0
        ,"SWP|C_SingleSwapWithSlippage"                 : 105.0
        ,"SWP|C_SmartSwapNoSlippage"                    : 165.0
        ,"SWP|C_SmartSwapWithSlippage"                  : 165.0
        ,"SWP|C_ToggleAddLiquidity"                     : 5.0
        ,"SWP|C_ToggleFeeLock"                          : 35.0
        ,"SWP|C_ToggleSwapCapability"                   : 5.0
        ,"SWP|C_UpdateAmplifier"                        : 19.0
        ,"SWP|C_UpdateFee"                              : 20.0
        ,"SWP|C_UpdatePendingBranding"                  : 16.0
        ,"SWP|C_UpdatePendingBrandingLPs"               : 19.0
        ,"SWP|C_UpdateSpecialFeeTargets"                : 19.0
        ,"SWP|C_UpgradeBranding"                        : 18.0
        ,"SWP|C_UpgradeBrandingLPs"                     : 17.0
        ,"VST|C_Awake"                                  : 23.0
        ,"VST|C_CreateFrozenLink"                       : 29.0
        ,"VST|C_CreateHibernatingLink"                  : 29.0
        ,"VST|C_CreateReservationLink"                  : 29.0
        ,"VST|C_CreateSleepingLink"                     : 29.0
        ,"VST|C_CreateVestingLink"                      : 29.0
        ,"VST|C_Freeze"                                 : 13.0
        ,"VST|C_Hibernate"                              : 17.0
        ,"VST|C_Merge"                                  : 39.0
        ,"VST|C_RepurposeFrozen"                        : 17.0
        ,"VST|C_RepurposeHibernating"                   : 21.0
        ,"VST|C_RepurposeMerge"                         : 39.0
        ,"VST|C_RepurposeReserved"                      : 17.0
        ,"VST|C_RepurposeSleeping"                      : 21.0
        ,"VST|C_RepurposeSlumber"                       : 39.0
        ,"VST|C_RepurposeVested"                        : 21.0
        ,"VST|C_Reserve"                                : 13.0
        ,"VST|C_Sleep"                                  : 23.0
        ,"VST|C_Slumber"                                : 39.0
        ,"VST|C_ToggleTransferRoleFrozenDPTF"           : 5.0
        ,"VST|C_ToggleTransferRoleHibernatingDPOF"      : 5.0
        ,"VST|C_ToggleTransferRoleReservedDPTF"         : 5.0
        ,"VST|C_ToggleTransferRoleSleepingDPOF"         : 5.0
        ,"VST|C_Unreserve"                              : 13.0
        ,"VST|C_Unsleep"                                : 19.0
        ,"VST|C_Unvest"                                 : 37.0
        ,"VST|C_Vest"                                   : 23.0}
    )
    (defconst GAS_EXCEPTION
        [
            DALOS|SC_NAME
            OUROBOROS|SC_NAME
        ]
    )
    (defconst EMPTY_CC
        [
            {
                "ignis-prices" : [],
                "interactors" : []
            }
        ]
    )
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    (defcap IGNIS|S>DISCOUNT (patron:string idp:string)
        @event
        true
    )
    (defcap IGNIS|S>FREE ()
        @event
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap IGNIS|C>DEBIT (sender:string ta:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (read-gas:decimal (ref-DALOS::UR_TF_AccountSupply sender false))
            )
            (enforce (<= ta read-gas) "Insufficient GAS for GAS-Debiting")
            (ref-DALOS::UEV_EnforceAccountExists sender)
            (ref-DALOS::UEV_EnforceAccountType sender false)
            (compose-capability (SECURE))
        )
    )
    (defcap IGNIS|C>CREDIT (receiver:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists receiver)
            (compose-capability (SECURE))
        )
    )
    (defcap IGNIS|C>DC (patron:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (compose-capability (IGNIS|S>DISCOUNT patron (UDC_MakeIDP (ref-DALOS::URC_IgnisGasDiscount patron))))
            (compose-capability (P|IGNIS|CALLER))
        )
    )
    (defcap IGNIS|C>COLLECT (patron:string interactor:string amount:decimal)
        @event
        (UEV_Patron patron)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (first:string (take 1 interactor))
                (sigma:string "Σ")
                (tanker:string (ref-DALOS::UR_Tanker))
            )
            ;;UNREACHABLE -- `interactor` is not a client argument, and the only thing that builds
            ;;one normalises it first. `UDC_MakeModularCumulator` sets
            ;;    (interactor (if (DALOS::UR_AccountType active-account) active-account BAR))
            ;;so a SMART account passes through as itself and everything else becomes BAR -- exactly
            ;;the two branches this enforce-one accepts. A triggered (free) leg is BAR regardless.
            ;;Measured: handing XE_CollectIgnis a hand-built cumulator naming a STANDARD account succeeds,
            ;;because the constructor sanitised it on the way in.
            ;;Kept as a fail-closed backstop for a future builder that does not normalise.
            ;;Pinned by REPL/modules/CUMULATOR.repl <<CUM-G1>>, which drives the normalisation itself
            ;;-- pure compute, no fixture -- so this annotation cannot rot if it is ever weakened.
            (enforce-one
                "Invalid Interactor"
                [
                    (enforce (= interactor BAR) "Interactor is invalid")
                    (enforce (= first sigma) "Invalid Smart Account as interactor")
                ]
            )
            (if (= interactor BAR)
                (compose-capability (IGNIS|C>TRANSFER patron tanker amount))
                (compose-capability (IGNIS|C>TRANSFER patron interactor amount))
            )
            (compose-capability (P|IGNIS|CALLER))
        )
    )
    (defcap IGNIS|C>TRANSFER (sender:string receiver:string ta:decimal)
        (enforce (!= sender receiver) "Sender and Receiver must be different")
        (UEV_TwentyFourPrecision ta)
        (enforce (> ta 0.0) "Cannot debit|credit 0.0 or negative GAS amounts")
        (compose-capability (IGNIS|C>DEBIT sender ta))
        (compose-capability (IGNIS|C>CREDIT receiver))
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
    (defun CT_StoaPrec ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_STOA_PRECISION)
        )
    )
    (defun UDC_EmptyOutputCumulatorV2:object{IgnisCollectorV4.OutputCumulator} ()
        {"cumulator-chain"      :
            [
                {"ignis"        : 0.0
                ,"interactor"   : BAR}
            ]
        ,"output"               : []}
    )
    ;;
    (defun UDC_MakeIDP:string (ignis-discount:decimal)
        (format "{}{}" [(* (- 1.0 ignis-discount) 100.0) "%"])
    )
    (defun UDC_ConstructOutputCumulator:object{IgnisCollectorV4.OutputCumulator}
        (price:decimal active-account:string trigger:bool output-lst:list)
        (UDC_MakeOutputCumulator
            [
                (UDC_MakeModularCumulator
                    price
                    active-account
                    trigger
                )
            ]
            output-lst
        )
    )
    (defun UDC_BrandingCumulator:object{IgnisCollectorV4.OutputCumulator}
        (active-account:string multiplier:decimal)
        (UDC_ConstructOutputCumulator
            (* multiplier (UC_IgnisLeg "tier-branding"))
            active-account
            (URC_IsVirtualGasZero)
            []
        )
    )
    (defun UDC_LegCumulator:object{IgnisCollectorV4.OutputCumulator}
        (leg-key:string active-account:string)
        @doc "Cumulator for ONE named internal write leg (IG|LEGS). Replaces the hardcoded \
            \ UDC_<tier>Cumulator calls inside XI_/XB_ writers so every internal charge has a \
            \ name and a single place to be retuned."
        (UDC_ConstructOutputCumulator
            (UC_IgnisLeg leg-key)
            active-account
            (URC_IsVirtualGasZero)
            []
        )
    )
    (defun UDC_CustomCodeCumulator:object{IgnisCollectorV4.OutputCumulator} ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (UDC_ConstructOutputCumulator
                (* 5.0 (UC_IgnisLeg "tier-biggest"))
                (at 1 (ref-DALOS::UR_DemiurgoiID))
                (URC_IsVirtualGasZero)
                []
            )
        )
    )
    ;;
    (defun UDC_MakeModularCumulator:object{IgnisCollectorV4.ModularCumulator}
        (price:decimal active-account:string trigger:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (interactor:string
                    (if (ref-DALOS::UR_AccountType active-account)
                        active-account
                        BAR
                    )
                )
            )
            (if trigger
                {"ignis"        : 0.0
                ,"interactor"   : BAR}
                {"ignis"        : price
                ,"interactor"   : interactor}
            )
        )
    )
    (defun UDC_MakeOutputCumulator:object{IgnisCollectorV4.OutputCumulator}
        (input-modular-cumulator-chain:[object{IgnisCollectorV4.ModularCumulator}] output-lst:list)
        {"cumulator-chain"  : input-modular-cumulator-chain
        ,"output"           : output-lst}
    )
    (defun UDC_ConcatenateOutputCumulators:object{IgnisCollectorV4.OutputCumulator}
        (input-output-cumulator-chain:[object{IgnisCollectorV4.OutputCumulator}] new-output-lst:list)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (folded-obj:[[object{IgnisCollectorV4.ModularCumulator}]]
                    (fold
                        (lambda
                            (acc:[[object{IgnisCollectorV4.ModularCumulator}]] idx:integer)
                            (ref-U|LST::UC_AppL
                                acc
                                (at "cumulator-chain" (at idx input-output-cumulator-chain))
                            )
                        )
                        []
                        (enumerate 0 (- (length input-output-cumulator-chain) 1))
                    )
                )
            )
            {"cumulator-chain"  : (fold (+) [] folded-obj)
            ,"output"           : new-output-lst}
        )
    )
    (defun UDC_CompressOutputCumulator:object{IgnisCollectorV4.CompressedCumulator}
        (input-output-cumulator:object{IgnisCollectorV4.OutputCumulator})
        @doc "Merges same-interactor legs of a cumulator-chain into one (interactor, summed-ignis) \
            \ entry each. Optimized (DALOS audit, post-#8H): uses the local single-pass \
            \ UC_FindKeyIndex instead of U|LST::UC_Search (which does ~4x the traversals for a \
            \ question this caller only ever needs one index for), and folds the accumulator as a \
            \ bare object instead of a throwaway 1-element list, dropping a UC_ReplaceAt/UC_Chain \
            \ call every iteration. Output is provably identical to the prior implementation — see \
            \ REPL/_scratch_ignis_compress_prime_optimization.repl."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (cumulator-chain-input:[object{IgnisCollectorV4.ModularCumulator}]
                    (at "cumulator-chain" input-output-cumulator)
                )
                (folded-obj:object{IgnisCollectorV4.CompressedCumulator}
                    (fold
                        (lambda
                            (acc:object{IgnisCollectorV4.CompressedCumulator} idx:integer)
                            (let
                                (
                                    (read-ignis-price:decimal (at "ignis" (at idx cumulator-chain-input)))
                                    (read-interactor:string (at "interactor" (at idx cumulator-chain-input)))
                                    (interactor-position:integer (UC_FindKeyIndex (at "interactors" acc) read-interactor))
                                )
                                (if (= interactor-position -1)
                                    {
                                        "ignis-prices"  : (ref-U|LST::UC_AppL (at "ignis-prices" acc) read-ignis-price),
                                        "interactors"   : (ref-U|LST::UC_AppL (at "interactors" acc) read-interactor)
                                    }
                                    (let
                                        (
                                            (ignis-amount-in-acc:decimal (at interactor-position (at "ignis-prices" acc)))
                                            (updated-ignis-amount:decimal (+ read-ignis-price ignis-amount-in-acc))
                                        )
                                        {
                                            "ignis-prices"  : (ref-U|LST::UC_ReplaceAt (at "ignis-prices" acc) interactor-position updated-ignis-amount),
                                            "interactors"   : (at "interactors" acc)
                                        }
                                    )
                                )
                            )
                        )
                        (at 0 EMPTY_CC)
                        (enumerate 0 (- (length cumulator-chain-input) 1))
                    )
                )
            )
            folded-obj
        )
    )
    (defun UDC_PrimeIgnisCumulator:object{IgnisCollectorV4.PrimedCumulator}
        (patron:string input:object{IgnisCollectorV4.CompressedCumulator})
        @doc "Splits each compressed leg into a smart-account cut and a principal/BAR cut per the \
            \ GAS_QUARTER fee-share. Optimized (DALOS audit, post-#8H) the same way as \
            \ UDC_CompressOutputCumulator above — see that function's @doc."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (fll:integer (length (at "ignis-prices" input)))
                (ignis-discount:decimal (ref-DALOS::URC_IgnisGasDiscount patron))
                (folded-obj:object{IgnisCollectorV4.CompressedCumulator}
                    (fold
                        (lambda
                            (acc:object{IgnisCollectorV4.CompressedCumulator} idx:integer)
                            (let
                                (
                                    (input-ignis-price:decimal (at idx (at "ignis-prices" input)))
                                    (input-ignis-price-discounted:decimal (* input-ignis-price ignis-discount))
                                    (input-interactor:string (at idx (at "interactors" input)))
                                    (iz-interactor-principal:bool
                                        (if (= input-interactor BAR)
                                            true
                                            false
                                        )
                                    )
                                    (smart-ignis-amount:decimal
                                        (if iz-interactor-principal
                                            0.0
                                            (* GAS_QUARTER input-ignis-price-discounted)
                                        )
                                    )
                                    (prime-ignis-amount:decimal (- input-ignis-price-discounted smart-ignis-amount))
                                    ;;
                                    (principal-interactor-position:integer (UC_FindKeyIndex (at "interactors" acc) BAR))
                                    (principal-interactor-exists:bool (!= principal-interactor-position -1))
                                )
                                (if principal-interactor-exists
                                    ;;Wen principal interactor already exists
                                    (let
                                        (
                                            (principal-interactor-current-ignis-amount:decimal (at principal-interactor-position (at "ignis-prices" acc)))
                                            (updated-interactor-ignis-amount:decimal (+ principal-interactor-current-ignis-amount prime-ignis-amount))
                                        )
                                        (if iz-interactor-principal
                                            ;;Wen interactor is principal
                                            {
                                                "ignis-prices"  : (ref-U|LST::UC_ReplaceAt (at "ignis-prices" acc) principal-interactor-position updated-interactor-ignis-amount),
                                                "interactors"   : (ref-U|LST::UC_AppL (at "interactors" acc) input-interactor)
                                            }
                                            ;;Wen interactor is not principal
                                            {
                                                "ignis-prices"  : (ref-U|LST::UC_AppL (ref-U|LST::UC_ReplaceAt (at "ignis-prices" acc) principal-interactor-position updated-interactor-ignis-amount) smart-ignis-amount),
                                                "interactors"   : (ref-U|LST::UC_AppL (at "interactors" acc) input-interactor)
                                            }
                                        )
                                    )
                                    ;;Wen principal interactor doesnt exit yet
                                    (if iz-interactor-principal
                                        ;;Wen interactor is principal
                                        {
                                            "ignis-prices"  : (ref-U|LST::UC_AppL (at "ignis-prices" acc) prime-ignis-amount),
                                            "interactors"   : (ref-U|LST::UC_AppL (at "interactors" acc) input-interactor)
                                        }
                                        ;;Wen interactor is not principal
                                        {
                                            "ignis-prices"  : (ref-U|LST::UC_AppL (ref-U|LST::UC_AppL (at "ignis-prices" acc) prime-ignis-amount) smart-ignis-amount),
                                            "interactors"   : (ref-U|LST::UC_AppL (ref-U|LST::UC_AppL (at "interactors" acc) BAR) input-interactor)
                                        }
                                    )
                                )
                            )
                        )
                        (at 0 EMPTY_CC)
                        (enumerate 0 (- fll 1))
                    )
                )
            )
            {"primed-cumulator" : folded-obj}
        )
    )
    (defun OI|UDC_ClientInfo:object{OuronetInfoV3.ClientInfo}
        (a:[string] b:[string] c:object{OuronetInfoV3.ClientIgnisCosts} d:object{OuronetInfoV3.ClientStoaCosts} e:list)
        {"pre-text"         : a
        ,"post-text"        : b
        ,"ignis"            : c
        ,"stoa"           : d
        ,"output"           : e}
    )
    (defun OI|UDC_ClientIgnisCosts:object{OuronetInfoV3.ClientIgnisCosts}
        (a:decimal b:decimal c:decimal d:string)
        {"ignis-discount"   : a
        ,"ignis-full"       : b
        ,"ignis-need"       : c
        ,"ignis-text"       : d}
    )
    (defun OI|UDC_ClientStoaCosts:object{OuronetInfoV3.ClientStoaCosts}
        (a:decimal b:decimal c:decimal d:[decimal] e:[string] f:string)
        {"stoa-discount"  : a
        ,"stoa-full"      : b
        ,"stoa-need"      : c
        ,"stoa-split"     : d
        ,"stoa-targets"   : e
        ,"stoa-text"      : f}
    )
    (defun OI|UDC_FullStoaCosts:object{OuronetInfoV3.ClientStoaCosts} (kfp:decimal)
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                ;;
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (stoa-split:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit kfp STOAPREC))
                (stoa-targets:[string] (OI|UR_StoaTargets))
                (stoa-price:string (OI|UC_ConvertPrice (* kfp stoa-pid)))
                (stoa-text:string
                    (format "Operation costs {} STOA valued at {} with no further discounts applied." [kfp stoa-price])
                )
            )
            (OI|UDC_ClientStoaCosts
                1.0
                kfp
                kfp
                stoa-split
                stoa-targets
                stoa-text
            )
        )
    )
    (defun OI|UDC_StoaCosts:object{OuronetInfoV3.ClientStoaCosts} (patron:string kfp:decimal)
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                ;;
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (stoa-discount:decimal (ref-DALOS::URC_StoaGasDiscount patron))
                (discount-percent:string (format "{}%" [(* 100.0 (- 1.0 stoa-discount))]))
                (stoa-need:decimal (floor (* stoa-discount kfp) STOAPREC))
                (stoa-split:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit stoa-need STOAPREC))
                (stoa-targets:[string] (OI|UR_StoaTargets))
                (stoa-need-price:string (OI|UC_ConvertPrice (* stoa-need stoa-pid)))
                (stoa-text:string
                    (if (= stoa-discount 1.0)
                        (format "Operation costs {} STOA valued at {} with no further discounts applied." [stoa-need stoa-need-price])
                        (format "Operation costs {} STOA discounted by {} to {} STOA valued at {}"
                            [kfp discount-percent stoa-need stoa-need-price]
                        )
                    )
                )
            )
            (OI|UDC_ClientStoaCosts
                stoa-discount
                kfp
                stoa-need
                stoa-split
                stoa-targets
                stoa-text
            )
        )
    )
    (defun OI|UDC_NoStoaCosts:object{OuronetInfoV3.ClientStoaCosts} ()
        (OI|UDC_ClientStoaCosts
            1.0
            0.0
            0.0
            [0.0]
            [BAR]
            "Operation is free of native Stoa (STOA)"
        )
    )
    (defun OI|UDC_DynamicStoaCost:object{OuronetInfoV3.ClientStoaCosts} (patron:string kfp:decimal)
        (if (= kfp 0.0)
            (OI|UDC_NoStoaCosts)
            (OI|UDC_StoaCosts patron kfp)
        )
    )
    ;;
    (defun OI|UDC_IgnisCosts:object{OuronetInfoV3.ClientIgnisCosts} (patron:string ifp:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                ;;
                (ignis-discount:decimal (ref-DALOS::URC_IgnisGasDiscount patron))
                (discount-percent:string (format "{}%" [(* 100.0 (- 1.0 ignis-discount))]))
                (ignis-need:decimal (* ignis-discount ifp))
                (ignis-need-price (OI|UC_ConvertPrice (/ ignis-need 100.0)))
                (ignis-text:string
                    (if (= ignis-discount 1.0)
                        (format "Operation costs {} IGNIS valued at {} with no further discounts applied." [ignis-need ignis-need-price])
                        (format "Operation costs {} IGNIS discounted by {} to {} IGNIS valued at {}"
                            [(floor ifp) discount-percent ignis-need ignis-need-price]
                        )
                    )
                )
            )
            (OI|UDC_ClientIgnisCosts
                ignis-discount
                ifp
                ignis-need
                ignis-text
            )
        )
    )
    (defun OI|UDC_NoIgnisCosts:object{OuronetInfoV3.ClientIgnisCosts} ()
        (OI|UDC_ClientIgnisCosts
            1.0
            0.0
            0.0
            "Operation is free of Ouronet GAS (IGNIS)"
        )
    )
    (defun OI|UDC_DynamicIgnisCost:object{OuronetInfoV3.ClientIgnisCosts} (patron:string ifp:decimal)
        (if (= ifp 0.0)
            (OI|UDC_NoIgnisCosts)
            (OI|UDC_IgnisCosts patron ifp)
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_IgnisWeight:decimal (key:string)
        @doc "Reads one mechanical pricing weight from the central IG|WEIGHTS map (tx, ins, \
            \ upd-per-4f, xcall, w-s..w-xl, r-s..r-xl, wipe-nonce, frag-nonce). The SINGLE \
            \ source of truth for component pricing — an unknown key fails fast via <at>."
        (at key IG|WEIGHTS)
    )
    (defun UC_IgnisDeter:decimal (key:string)
        @doc "Reads one deterrence multiplier (on the IG|TX base unit) from the central \
            \ IG|DETER map — usage/setup/auth/fee tiers + the owner-priced issuance and \
            \ AQP-family tiers (2026-09-05 batch). 1 ignis = 1 USD/EUR cent. An unknown \
            \ key fails fast via <at>."
        (at key IG|DETER)
    )
    (defun UC_IgnisLeg:decimal (leg-key:string)
        @doc "Price of ONE named internal write leg, from IG|LEGS. Charged by XI_/XB_ writers \
            \ for the persistence work a single write does — not a client-op price. Fails fast \
            \ on an unknown key."
        (at leg-key IG|LEGS)
    )
    (defun UC_IgnisComponents:decimal (op-key:string)
        @doc "The op's own computed IGNIS consumption (its real work), from IG|COMPONENTS. \
            \ Keyed by the Talos client name <ENTITY>|<FN>. Fails fast on an unknown op."
        (at op-key IG|COMPONENTS)
    )
    (defun UC_IgnisPrice:decimal (op-key:string deter-key:string)
        @doc "THE price of a client op: deterrence + its proper ignis computation. Every \
            \ URCi_* reader should bill through this, so a price lives in exactly one place. \
            \ 1 IGNIS = 1 US/EUR cent."
        (+ (UC_IgnisDeter deter-key) (UC_IgnisComponents op-key))
    )
    (defun UC_IgnisPriceScaled:decimal (op-key:string deter-key:string weight-key:string n:integer)
        @doc "Per-item variant: deter + components + n x the per-item surcharge (wipe-nonce, \
            \ frag-nonce, ...). For ops whose work scales with a nonce/receiver/hop count."
        (+ (UC_IgnisPrice op-key deter-key) (* (dec n) (UC_IgnisWeight weight-key)))
    )
    (defun UC_StoaPrice:decimal (deter-key:string)
        @doc "STOA leg for ISSUE functions: the SAME DOLLAR VALUE as the deter, converted at \
            \ the live STOA price. 1 IGNIS = 1 cent, so deter/100 = dollars; dividing by the \
            \ STOA price gives the STOA amount. STOA is hard-pegged at $0.10 today, so $40 of \
            \ deter = 400 STOA; when a real price lands the AMOUNT moves but the VALUE holds. \
            \ \
            \ CORRECTED 2026-10-02 (owner). This read a USAGE-PRICES table key for the STOA \
            \ peg, and that table is for prices of USAGE -- not for the price of STOA \
            \ itself. The canonical STOA/USD reader is U|CT::UR_STOA-PID|Price, the \
            \ DIA oracle stub, used in ~40 places across the tree INCLUDING TWICE IN THIS \
            \ MODULE a hundred lines above (OI|UDC_FullStoaCosts). This function was the \
            \ only reader of that table key anywhere, and the lone outlier in its own file. \
            \ \
            \ Both answer 0.1 today, so nothing moves. The cost was twofold and elsewhere: \
            \ the key was NEVER WRITTEN on mainnet, so every STOA-charging op died on an \
            \ uncatchable read, while [4.0] seeds it in the REPL so the divergence could \
            \ not surface in test. And writing the row would have papered over it until the \
            \ day a real oracle landed -- wiring it changes UR_STOA-PID|Price and leaves \
            \ the table untouched, so the two would then silently disagree."
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
            )
            (/ (/ (UC_IgnisDeter deter-key) 100.0) (ref-U|CT|DIA::UR_STOA-PID|Price))
        )
    )
    (defun UC_FeeUnlockPrice:[decimal] ()
        @doc "Cost of unlocking fee parameters: [IGNIS STOA] = a FLAT $50 + $50, every unlock \
            \ (owner 2026-09-06). Returns the same 2-element shape the retired escalating \
            \ ladder returned, so call sites kept their structure; the <unlocks> count no longer \
            \ changes the price. That ladder (U|DEC/U|ATS/U|DPTF UC_UnlockPrice) had been dead \
            \ code since the flattening and was DELETED 2026-09-10. Used by DPTF|C_ToggleFeeLock, \
            \ ATS|C_ToggleParameterLock and SWP|C_ToggleFeeLock."
        [(UC_IgnisDeter "fee-unlock") (UC_StoaPrice "fee-unlock")]
    )
    (defun UC_FindKeyIndex:integer (key-lst:[string] key:string)
        @doc "First index of key in key-lst, or -1 if absent. Single linear scan, local to the \
            \ compress/prime pipeline below (UDC_CompressOutputCumulator/UDC_PrimeIgnisCumulator) \
            \ only — NOT a general-purpose replacement for U|LST::UC_Search, whose documented \
            \ contract (return every matching index) is different and untouched by this helper."
        (if (= (length key-lst) 0)
            -1
            (fold
                (lambda
                    (found:integer idx:integer)
                    (if (and (= found -1) (= (at idx key-lst) key)) idx found)
                )
                -1
                (enumerate 0 (- (length key-lst) 1))
            )
        )
    )
    ;;
    ;;[OURONET-INFO] Functions — shared cost/format vocabulary (relocated from INFO-ZERO;
    ;;  must live pre-Talos so Talos + all cost modules + Z_Reads presentation can reach it)
    (defun OI|UC_IfpFromOutputCumulator:decimal (input:object{IgnisCollectorV4.OutputCumulator})
        (let
            (
                (cc:[object{IgnisCollectorV4.ModularCumulator}] (at "cumulator-chain" input))
            )
            (fold
                (lambda
                    (acc:decimal idx:integer)
                    (+ acc (at "ignis" (at idx cc)))
                )
                0.0
                (enumerate 0 (- (length cc) 1))
            )
        )
    )
    (defun OI|UC_ShortAccount:string (account:string)
        (concat
            [
                (take 5 account)
                "..."
                (take -3 account)
            ]
        )
    )
    (defun OI|UC_ConvertPrice:string (input-price:decimal)
        (let
            (
                (number-of-decimals:integer (if (<= input-price 1.00) 3 2))
                (converted:decimal
                    (if (< input-price 1.00)
                        (floor (* input-price 100.0) 3)
                        (floor input-price 2)
                    )
                )
                (s:string
                    (if (< input-price 1.00)
                        "¢"
                        "$"
                    )
                )
                (ss:string "<0.001¢")
            )
            (if (< input-price 0.00001)
                (format "{}" [ss])
                (format "{}{}" [converted s])
            )
        )
    )
    (defun OI|UC_FormatIndex:string (index:decimal)
        (let
            (
                (fi:decimal (floor index 12))
                (fis:string (format "{}" [fi]))
                (l1:string (take -3 fis))
                (l2:string (take -3 (drop -3 fis)))
                (l3:string (take -3 (drop -6 fis)))
                (l4:string (take -3 (drop -9 fis)))
                (whole:string (drop -13 fis))
            )
            (concat
                [whole ",[" l4 "." l3 "." l2 "." l1 "]"]
            )
        )
    )
    (defun OI|UC_FormatTokenAmount:string (amount:decimal)
        (format "{}" [(floor amount 4)])
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_Exception (account:string)
        (contains account GAS_EXCEPTION)
    )
    (defun URC_ZeroEliteGAZ (sender:string receiver:string)
        (let
            (
                (t1:bool (URC_Exception sender))
                (t2:bool (URC_Exception receiver))
            )
            (or t1 t2)
        )
    )
    (defun URC_ZeroGAZ:bool (id:string sender:string receiver:string)
        (let
            (
                (t1:bool (URC_ZeroGAS id sender))
                (t2:bool (URC_Exception receiver))
            )
            (or t1 t2)
        )
    )
    (defun URC_ZeroGAS:bool (id:string sender:string)
        (let
            (
                (t1:bool (URC_IsVirtualGasZeroAbsolutely id))
                (t2:bool (URC_Exception sender))
            )
            (or t1 t2)
        )
    )
    (defun URC_IsVirtualGasZeroAbsolutely:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (t1:bool (URC_IsVirtualGasZero))
                (gas-id:string (ref-DALOS::UR_IgnisID))
                (t2:bool (if (or (= gas-id BAR)(= id gas-id)) true false))
            )
            (or t1 t2)
        )
    )
    (defun URC_IsVirtualGasZero:bool ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (if (ref-DALOS::UR_VirtualToggle)
                false
                true
            )
        ) 
    )
    (defun URC_IsNativeGasZero:bool ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (if (ref-DALOS::UR_NativeToggle)
                false
                true
            )
        )
    )
    ;;
    ;;[DALOS-URCi] cost readers — the single source for each DALOS client op's tier choice.
    ;;  DALOS deploys below IGNIS (cannot host these); Talos bills through them and the Z_Reads
    ;;  presentation derives its preview from the same call, so billing and preview never drift.
    (defun DALOS|URCi_ControlSmartAccount:object{IgnisCollectorV4.OutputCumulator} (account:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_ControlSmartAccount" "setup")
            account (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_RotateGovernor:object{IgnisCollectorV4.OutputCumulator} (account:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_RotateGovernor" "auth")
            account (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_RotateGuard:object{IgnisCollectorV4.OutputCumulator} (account:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_RotateGuard" "auth")
            account (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_RotateStoa:object{IgnisCollectorV4.OutputCumulator} (account:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_RotateStoa" "auth")
            account (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_RotateSovereign:object{IgnisCollectorV4.OutputCumulator} (account:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_RotateSovereign" "auth")
            account (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_UpdateEliteAccount:object{IgnisCollectorV4.OutputCumulator} (patron:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_UpdateEliteAccount" "usage")
            patron (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_UpdateEliteAccountSquared:object{IgnisCollectorV4.OutputCumulator} (patron:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_UpdateEliteAccountSquared" "usage")
            patron (URC_IsVirtualGasZero) [])
    )
    ;;  STOA-billed DALOS ops: the URCi returns the native fair price (the tier "key" single-sourced)
    (defun DALOS|URCi_DeploySmartAccount:decimal ()
        @doc "STOA price of deploying a smart Ouronet account: $10 of value, converted at the live \
            \ STOA price (UC_StoaPrice). Returns 0.0 while DALOS's account-creation-stoa switch \
            \ is OFF, so onboarding is free even when global STOA collection is ON — that switch \
            \ is the single gate, and both the exec path and the INFO preview read it here."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (if (ref-DALOS::UR_AccountCreationStoa) (UC_StoaPrice "acct-smart") 0.0)
        )
    )
    (defun DALOS|URCi_DeployStandardAccount:decimal ()
        @doc "STOA price of deploying a standard Ouronet account: $5 of value, converted at the live \
            \ STOA price (UC_StoaPrice). Returns 0.0 while DALOS's account-creation-stoa switch \
            \ is OFF, so onboarding is free even when global STOA collection is ON — that switch \
            \ is the single gate, and both the exec path and the INFO preview read it here."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (if (ref-DALOS::UR_AccountCreationStoa) (UC_StoaPrice "acct-standard") 0.0)
        )
    )
    (defun OI|UR_StoaTargets:[string] ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            [
                (at 2 (ref-DALOS::UR_DemiurgoiID))
                DALOS|SC_NAME
                (at 1 (ref-DALOS::UR_DemiurgoiID))
                OUROBOROS|SC_NAME
            ]
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_TwentyFourPrecision (amount:decimal)
        @doc "Enforces a 24 Precision, for use with IGNIS Token."
        (enforce
            (= (floor amount 24) amount)
            (format "The GAS Amount of {} is not a valid GAS Amount decimal wise" [amount])
        )
    )
    (defun UEV_Patron (patron:string)
        @doc "Capability that ensures a DALOS account can act as gas payer, enforcing all necesarry restrictions"
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (if (ref-DALOS::UR_AccountType patron)
                (do
                    (enforce (= patron DALOS|SC_NAME) "Only the DALOS Account can be a Smart Patron")
                    (ref-DALOS::CAP_EnforceAccountOwnership DALOS|SC_NAME)
                )
                (ref-DALOS::CAP_EnforceAccountOwnership patron)
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: IGNIS|C>COLLECT
    (defun XI_IgnisCollector (patron:string interactor:string amount:decimal)
        (require-capability (IGNIS|C>COLLECT patron interactor amount))
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (collector:string
                    (if (= interactor BAR)
                        (ref-DALOS::UR_Tanker)
                        interactor
                    )
                )
            )
            (ref-DALOS::XE_IgnisIncrement false amount)
            (XI_IgnisTransfer patron collector amount)
        )
    )
    ;;Protection: Class 3 — Custom: IGNIS|C>TRANSFER
    (defun XI_IgnisTransfer (sender:string receiver:string ta:decimal)
        (require-capability (IGNIS|C>TRANSFER sender receiver ta))
        (XI_IgnisDebit sender ta)
        (XI_IgnisCredit receiver ta)
    )
    ;;Protection: Class 3 — Custom: IGNIS|C>DEBIT
    (defun XI_IgnisDebit (sender:string ta:decimal)
        (require-capability (IGNIS|C>DEBIT sender ta))
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::XB_UpdateBalance sender false 
                (- (ref-DALOS::UR_TF_AccountSupply sender false) ta)
            )
        )
    )
    ;;Protection: Class 3 — Custom: IGNIS|C>CREDIT
    (defun XI_IgnisCredit (receiver:string ta:decimal)
        (require-capability (IGNIS|C>CREDIT receiver))
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::XB_UpdateBalance receiver false 
                (+ (ref-DALOS::UR_TF_AccountSupply receiver false) ta)
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_MoveDalosFuel (executor:string executee:string amount:decimal)
        @doc "Move native STOA fuel in a SINGLE PASS, from one account to another. A ZERO amount is a NO-OP, not a transfer: Stoa's coin \
            \ enforces (> amount 0.0), so passing 0.0 aborts the whole transaction. Zero legs are \
            \ NORMAL -- the account-creation STOA switch prices onboarding at 0.0 while it is OFF, \
            \ and a small dollar-pegged amount can round one of the four legs to zero. This guard \
            \ is why neither the fee path nor LIQUID can call coin.transfer directly. \
            \ \
            \ MOVE vs COLLECT: this moves fuel BETWEEN two accounts (LIQUID's migrate / wrap / \
            \ unwrap). XB_CollectDalosFuel takes a SPLIT and fans one payment out to the four \
            \ protocol accounts. Same zero-guard underneath, two different jobs, two names. \
            \ \
            \ THIS IS THE PROTECTION POINT FOR THE WHOLE STOA PATH. Every collector -- full, \
            \ discounted, triggered -- funnels its four legs through here, so gating HERE gates \
            \ all of them. P|UEV_IMC checks the transaction's signatures against the registered \
            \ inter-module guards, which is depth-invariant: it gives the same answer at any \
            \ call depth, so repeating it at every level above would be identical work for an \
            \ identical answer."
        (P|UEV_IMC)
        (if (> amount 0.0)
            (let
                (
                    (ref-coin:module{stoa-ns.fungible-v1} coin)
                )
                (ref-coin::transfer executor executee amount)
            )
            "Zero STOA leg -- nothing transferred"
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XB_MoveDalosFuel
    (defun XB_CollectDalosFuel (patron:string amount:decimal)
        @doc "COLLECT native STOA fuel from <patron>'s Stoa account and fan it out over the \
            \ protocol's INNATE 10/20/30/40 split -- 10% Demiourgos.Holdings, 30% Ouronet \
            \ Maintenance, 40% STOA-Ouroboros, 20% STOA-Dalos (the gas station). \
            \ \
            \ THE SPLIT IS NOT A PARAMETER, deliberately. It used to be, and that let a caller \
            \ hand this function any four numbers -- including four that do not sum to the \
            \ amount, or that pay the wrong accounts. There is no legitimate second split, so \
            \ taking one as input could only ever be a way to get it wrong. \
            \ \
            \ MOVE vs COLLECT: XB_MoveDalosFuel moves fuel BETWEEN two accounts (LIQUID's \
            \ migrate / wrap / unwrap). This one collects it TO the protocol."
            (let
                (
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
                    (demiurgoi:[string] (ref-DALOS::UR_DemiurgoiID))
                    (stoa-sender:string (ref-DALOS::UR_AccountStoa patron))
                    (split:[decimal] (ref-DALOS::URC_SplitSTOAPricesFull amount))
                )
                (do
                    (XB_MoveDalosFuel stoa-sender (ref-DALOS::UR_AccountStoa (at 2 demiurgoi)) (at 0 split))
                    (XB_MoveDalosFuel stoa-sender (ref-DALOS::UR_AccountStoa (at 1 demiurgoi)) (at 2 split))
                    (XB_MoveDalosFuel stoa-sender (ref-DALOS::UR_AccountStoa OUROBOROS|SC_NAME) (at 3 split))
                    (XB_MoveDalosFuel stoa-sender (ref-DALOS::UR_AccountStoa DALOS|SC_NAME) (at 1 split))
                )
            )
    )
    ;;Protection: Class 1 — Innate protection offered by XB_CollectStoaFull
    (defun XB_CollectStoaDiscountedFrom (patron:string discount-account:string amount:decimal trigger:bool)
        @doc "Discounted STOA collection: the FULL collector applied to an amount that has first \
            \ been clamped by <discount-account>'s Elite discount. \
            \ \
            \ That is the whole difference, and it is worth stating because it used to be a \
            \ SECOND 25-line copy of the collector that differed from the full one in a single \
            \ expression. The discount applies to the TOTAL before the split -- \
            \ URC_SplitSTOAPrices is literally UC_TenTwentyThirtyFourtySplit of (discount x \
            \ price) -- so discounting the amount and collecting in full is not an approximation \
            \ of the old behaviour, it IS the old behaviour. \
            \ \
            \ <discount-account> is usually the patron; it differs only where the spec says the \
            \ discount follows the asset rather than the payer."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (XB_CollectStoaFull patron
                (* (ref-DALOS::URC_StoaGasDiscount discount-account) amount) trigger)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XB_CollectDalosFuel
    (defun XB_CollectStoaFull (patron:string amount:decimal trigger:bool)
        @doc "THE STOA COLLECTOR -- charges <amount> in full, no Elite discount. Every other STOA \
            \ entrypoint in this module is a wrapper on it. <trigger> true means collection is \
            \ switched OFF and the call is a documented no-op."
        (if (not trigger)
            (XB_CollectDalosFuel patron amount)
            (format "While Stoa Collection is {}, the {} STOA could not be collected" [trigger amount])
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XB_CollectStoaDiscountedFrom
    (defun XB_CollectStoaWithTrigger (patron:string amount:decimal trigger:bool)
        @doc "Discounted STOA collection with an EXPLICIT trigger. Discount is read from the \
            \ patron's own account."
        (XB_CollectStoaDiscountedFrom patron patron amount trigger)
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_CollectStoa (patron:string amount:decimal)
        @doc "Discounted STOA collection, trigger read from the live native-gas switch. The \
            \ ordinary entrypoint: 28 call sites across 17 modules use this one."
        (P|UEV_IMC)
        (XB_CollectStoaWithTrigger patron amount (URC_IsNativeGasZero))
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_CollectIgnis
        (patron:string input-output-cumulator:object{IgnisCollectorV4.OutputCumulator})
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (compressed-cumulator:object{IgnisCollectorV4.CompressedCumulator}
                    (UDC_CompressOutputCumulator input-output-cumulator)
                )
                (primed-cumulator:object{IgnisCollectorV4.PrimedCumulator}
                    (UDC_PrimeIgnisCumulator patron compressed-cumulator)
                )
                (ignis-prices:[decimal] (at "ignis-prices" (at "primed-cumulator" primed-cumulator)))
                (ignis-sum:decimal (fold (+) 0.0 ignis-prices))
                ;;RT-I-001 FIX (2026-09-15, owner design confirmed). This read
                ;;`(ref-DALOS::UR_AccountType patron)` -- the `smart-contract` flag, which
                ;;XI_DeploySmartAccount sets to `true` UNCONDITIONALLY for EVERY smart account,
                ;;including the seven system ones and every user account created through the
                ;;PERMISSIONLESS client wrapper DALOS|C_DeploySmartAccount (TS01-C1:311).
                ;;
                ;;OWNER: "an IGNIS gas payer account can only be a STANDARD account. A smart account
                ;;can never be a gassless payer, EXCEPT one single account hardcoded into the code,
                ;;to allow admin-based gassless IGNIS transactions -- the Ouroboros daily minter uses
                ;;such a gassless patron. No other smart account should have this property."
                ;;
                ;;That account is `GOV|DALOS|SC_NAME`: 03_DSP+.pact binds
                ;;`(defconst GASLESS-PATRON (URC_Gassless))` and `URC_Gassless` returns it. But that
                ;;was a CALLER-SIDE CONVENTION, not an enforcement -- DSP chose to pass one account
                ;;while this line exempted any smart one. RT-C-001's lesson in a new place: a
                ;;convention that is honoured is indistinguishable from a rule that is enforced,
                ;;until someone does not honour it. The GAS_PAYER Case 3 custom-code door let an
                ;;attacker write the patron into their OWN transaction text, where DSP's discipline
                ;;has no reach at all -- see RedTeam/[RT-I]_GasStation.repl.
                ;;
                ;;SAFE TO NARROW, MEASURED: resolving every call site that passes a smart-account
                ;;constant as a FIRST argument, against the callee's actual first PARAMETER NAME,
                ;;gives 37 genuine `patron` slots and ALL 37 are in 03_DSP+.pact. The sovereign hits
                ;;that looked like patrons are not -- VST::C_Freeze takes `freezer`, C_Sleep takes
                ;;`sleeper`, C_Hibernate takes `hibernator`, SWPLC::C_Fuel takes `account`. Nothing
                ;;outside DSP relies on this exemption.
                (iz-gassles-patron:bool (= patron (ref-DALOS::GOV|DALOS|SC_NAME)))
                (virtual-gas-toggle:bool (ref-DALOS::UR_VirtualToggle))
            )
            (if (and (!= ignis-sum 0.0) (not iz-gassles-patron))
                (if virtual-gas-toggle
                    (with-capability (IGNIS|C>DC patron)
                        (let
                            (
                                (icl:integer (length ignis-prices))
                                (primed-collector:object{IgnisCollectorV4.CompressedCumulator} 
                                    (at "primed-cumulator" primed-cumulator)
                                )
                            )
                            (map
                                (lambda
                                    (idx:integer)
                                    (let
                                        (
                                            (interactor:string (at idx (at "interactors" primed-collector)))
                                            (amount:decimal (at idx (at "ignis-prices" primed-collector)))
                                        )
                                        ;;A leg priced at 0.0 (or, if ever misconfigured, negative) is a
                                        ;;legitimately free leg for THIS interactor within an otherwise-
                                        ;;billable bundle — skip collecting it instead of hitting
                                        ;;IGNIS|C>TRANSFER's unconditional (> ta 0.0) enforce, which would
                                        ;;otherwise abort the whole batch over one free leg (DALOS audit
                                        ;;#8H). Ties into the same IGNIS|S>FREE event already used for the
                                        ;;all-free case, so a free leg is still observable on-chain.
                                        (if (> amount 0.0)
                                            (with-capability (IGNIS|C>COLLECT patron interactor amount)
                                                (XI_IgnisCollector patron interactor amount)
                                            )
                                            (with-capability (IGNIS|S>FREE) true)
                                        )
                                    )
                                )
                                (enumerate 0 (- icl 1))
                            )
                            (ref-DALOS::XE_IncrementOuronetAccountNonce patron)
                        )
                    )
                    (with-capability (IGNIS|S>FREE)
                        true
                    )
                )
                (with-capability (IGNIS|S>FREE)
                    true
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_DonateStoa (executor:string amount:decimal)
        @doc "DONATE native STOA to the protocol -- the ONE legitimate standalone use of the \
            \ collection machinery, and the reason that machinery is otherwise protected. \
            \ \
            \ Every other collector here runs as part of an operation that is CHARGING a fee; none \
            \ may be called on its own, which is why they are X_ and IMC-gated. A donation is the \
            \ inverse: nobody is being charged, someone is giving. That makes it a true client \
            \ function. \
            \ \
            \ PATRONLESS by design: you cannot ask an account donating STOA to also pay IGNIS for \
            \ the privilege of donating. The donor is the EXECUTOR -- their own STOA, their own \
            \ initiative. \
            \ \
            \ Collected in FULL, no Elite discount: a discount on a voluntary gift is meaningless. \
            \ The same four-way split (10/30/40/20) applies as to any fee."
        (XB_CollectStoaFull executor amount false)
    )
    ;;
    ;;

)

;; --- tables for 02_IGNIS.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/00_AQP-SCHEMAS.pact ======
;;<=============================================================================>
;;{0}  ACQUISITION SCHEMAS — the one place every AQP row shape is declared
;;
;; Generated by REPL/tools/_aqpschemas.py. Edit the SCHEMAS here, never a copy.
;;
;; WHY THIS FILE EXISTS
;;   The seven AQP core modules used to declare these 74 schemas between them, 11 of
;;   them twice (RPS and FVT both carried identical copies). A schema that lives in a
;;   module cannot appear in that module's interface, so every function returning one
;;   was locked out of the interface -- 106 of them across the family, unreachable
;;   through a modref. The duplication was a symptom: RPS keeps 10 UDC_ constructors
;;   and declares none of them, so FVT could not call them and copied the shapes.
;;
;;   Hoisting them here is the same shape as DpdcUdcV2 (01_DPDC-UDC.pact), which the
;;   DPDC family already deploys first for exactly this reason.
;;
;; DEPLOY ORDER: this interface loads BEFORE 01_ANK.pact and every AQP module after it.
;;
;; NOT DONE HERE, DELIBERATELY: tables that share a key are NOT merged. Row existence
;;   is used as a boolean signal in this family, so folding a sparse table into a dense
;;   one changes meaning silently. Moving a schema changes no stored bytes; merging a
;;   table changes the data layout. One axis at a time.
;;<=============================================================================>

(namespace "ouronet-ns")

(interface AcquisitionSchemasV5

    ;;<=========================================================================>
    ;;{1}  ANK   — anchors, boost classes, user boost
    ;;      source: 01_ANK.pact
    ;;
    (defschema ANK|Schema
        @doc "General Anchor Definition \
            \ Each Anchor is defined via a so called Anchored-Asset \
            \ This may be a DPTF, DPSF or DPNF; It designation is stored here; \
            \ Along with the Anchor Precision and the Anchor ID itself \
            \ [.]   = fixed, cannot be changed \
            \ [M]   = mutable, can be modified via <CAP_Owner>"
        ank-asset:string            ;;[.]   ID of the the Anchored Asset
        ank-fungibility:[bool]      ;;[.]   Stores the fungibility of the Asset the Anchor is based on.
        boost-class-id:string       ;;[.]   BoostClass this anchor belongs to
        ank-precision:integer       ;;[.]   Precision of the Anchor Variable [min 2 - max 8]
        ank-active:bool             ;;[M]   Stores if the Anchor is active or not. It can be inactivated by revoking it
        ank-promile:decimal         ;;[.]   Promile-value of Anchor
        ;;
        ;;DPTF Anchor ONLY
        dptf-amount:decimal         ;;[.]   DPTF Amount for the defined <promile> [0.0 when not DPTF Anchor]
        ;;
        ;;DPSF Anchor ONLY
        dpsf-nonce:integer          ;;[.]   DPSF Nonce for the defined <promile> [0 when not DPSF Anchor]
        ;;
        ;;DPNF Anchor ONLY
        dpnf-trait-key:string       ;;[.]   DPNF Trait-Key for the defined <promile> [BAR when not DPNF Anchor]
        dpnf-trait-value:string     ;;[.]   DPNF Trait-Value for the defined <promile> [BAR when not DPNF Anchor]
        dpnf-nonce-class:integer    ;;[.]   DPNF Nonce-Class for set anchors [-1 when trait mode, 0 all native NFTs, >0 specific set class]
        ;;
        ;;Select Keys
        anchor-id:string
    )
    (defschema ANK|BoostClass
        @doc "Heterogeneous anchor grouping for score boosting. \
            \ Not tied to any asset-id. Up to 7 anchor slots from different asset types."
        anchor-primary:string       ;;[M]   1st anchor slot
        anchor-secondary:string     ;;[M]   2nd anchor slot
        anchor-tertiary:string      ;;[M]   3rd anchor slot
        anchor-quaternary:string    ;;[M]   4th anchor slot
        anchor-quinary:string       ;;[M]   5th anchor slot
        anchor-senary:string        ;;[M]   6th anchor slot
        anchor-septenary:string     ;;[M]   7th anchor slot
        ;;
        anchors:integer             ;;[M]   Count of active anchors (0-7)
        class-active:bool           ;;[M]   Active flag
        ;;ADDED 2026-09-19. A BoostClass had NO owner at all, so attaching an anchor to an existing
        ;;class (acnoi=false) validated only "class active" and "a slot is free (max 7)". Issuing
        ;;the anchor itself is gated on CAP_OwnerOrCreator of the ANCHORED ASSET -- but that is the
        ;;attacker's own asset. So anyone owning any anchorable asset could anchor it into someone
        ;;else's class and hand their holders a boost inside that vault's scoring. Six free slots on
        ;;a 7-slot class is six such grants. The class now carries its creator, and the
        ;;acnoi=false path enforces it.
        class-owner:string          ;;[.]   Ouronet account that created the class; only it may attach anchors
        ;;
        ;;Select Keys
        boost-class-id:string       ;;[.]   Self-referential ID
    )
    (defschema ANK|InternalGroup
        @doc "Nested schema for ANK|AssetAnchors group slots (not a table). Up to 7 anchor slots per group."
        anchor-primary:string
        anchor-secondary:string
        anchor-tertiary:string
        anchor-quaternary:string
        anchor-quinary:string
        anchor-senary:string
        anchor-septenary:string
        anchors:integer             ;;Count within this group (0-7)
    )
    (defschema ANK|AssetAnchors
        @doc "Tracks all anchors for one asset-id. 7 internal groups x 7 slots = 49 cap. \
            \ Single read gives all anchor-ids for an asset."
        group-primary:object{ANK|InternalGroup}
        group-secondary:object{ANK|InternalGroup}
        group-tertiary:object{ANK|InternalGroup}
        group-quaternary:object{ANK|InternalGroup}
        group-quinary:object{ANK|InternalGroup}
        group-senary:object{ANK|InternalGroup}
        group-septenary:object{ANK|InternalGroup}
        ;;
        groups-active:integer       ;;[M]   Groups in use (0-7)
        anchors-active:integer      ;;[M]   Total anchors across all groups (0-49)
        ;;
        ;;Select Keys
        asset-id:string             ;;[.]   Self-referential asset-id
    )
    (defschema ANK|UserSchema
        @doc "Stores the cumulate promile of a given <ouronet-account> for a given <anchor-id> \
            \ [.]   = fixed, cannot be changed \
            \ [M]   = mutable, can be modified via <ouronet-account> Ownership"
        promile:decimal             ;;[M]   Promile of User with Anchor
        ;;
        ;;Select Keys
        ouronet-account:string      ;;[.]   Stores the Ouronet Account for which the Anchor Value is saved
        anchor-id:string            ;;[.]   Stores the Anchor-ID
    )
    (defschema ANK|UserBoostSchema
        @doc "Aggregate promile for one user across all anchors in one BoostClass. \
            \ Eagerly updated whenever any member anchor promile changes for this user."
        aggregate-promile:decimal   ;;[M]   Sum of user promiles across member anchors
        ;;
        ;;Select Keys
        ouronet-account:string      ;;[.]   User account
        boost-class-id:string       ;;[.]   BoostClass reference
    )
    (defschema ANK|BoostClassScoreLinks
        @doc "Key = <Boost-Class-ID>. The SET of SCORE ids whose boost-class-link references this class — the H4 \
            \ REVERSE INDEX (sweep phase 1): enumerable (the re-score sweep walks it to find every score/position \
            \ an anchor change touches) AND the #9 revoke lock (the class's anchors are locked while the set is \
            \ non-empty). AQP-SCORE maintains it in XI_CreateBoostClassLink: add on link, remove on re-point/unlink. \
            \ The lock count = (length score-links) — this set is the single source of truth."
        score-links:[string]
        boost-class-id:string
    )

    ;;<=========================================================================>
    ;;{2}  SCORE — scores, per-asset score definitions, triplets
    ;;      source: 02_SCORE.pact
    ;;
    (defschema SCR|Schema
        @doc "General Score Definition \
            \ [.]   = fixed, cannot be changed \
            \ [..]  = Once linked, cannot be changed \
            \ [.t]  = Once set to true, cannot be changed \
            \ [M]   = mutable, can be modified  <owner-konto> \
            \ [Mu]  = mutable via upgrade, can be modified via \
            \        <owner-konto> and true <can-upgrade> \
            \ \
            \ Identity: No separate scr-asset on the score. Staking asset is \
            \ defined on the AQP pool. Resolve Score -> aqpool-link -> Pool \
            \ -> asset-id. FVT must only add ScoreLink when aqpool-link is \
            \ set, so membership checks (e.g. farm common-denominator vs LP \
            \ construction) use that chain. \
            \ \
            \ Class-0 LP: One score employed per pool aggregates all stake \
            \ that pool allows. Multiple token ids (e.g. native LP, sleeping \
            \ OF, frozen TF) may stake into the same pool when the protocol \
            \ verifies they are the same LP family; trackers distinguish ids, \
            \ but SCR|T|UserScore rows are per pool-id x score-id for \
            \ beneficiaries. \
            \ \
            \ Immutability vs users: Per-user weights in SCR|T|UserScore are \
            \ advanced on Stake/Unstake (and FVT Inject/Collect handle \
            \ rewards), matching the UrStoa vault pattern; there is no \
            \ practical global recomputation over all accounts. Do not change \
            \ [.] semantic fields (score-class, multipliers, sft/nft models), \
            \ links [..], or deb-boost [.t] after positions \
            \ exist; that would leave existing rows wrong until users \
            \ restake. Correct mistakes by issuing a new score-id, removing \
            \ the old score from pool slots and FVT membership, then wiring \
            \ the new score. \
            \ \
            \ [M] totals on this row are aggregate bookkeeping; they do not \
            \ replace the rule that meaning-of-weight is fixed by [.] fields \
            \ at issue."
        ;;
        ;;Management
        owner-konto:string          ;;[Mu]  Stores the Score Owner.
        can-upgrade:bool            ;;[Mu]  Defines if Score Settings can be upgraded
        can-change-owner:bool       ;;[Mu]  Defines if the Owner can be changed
        ;;
        ;; Links
        boost-class-link:string     ;;[..]  Specifies the BoostClass-ID for boosting. BAR if not in use.
        ;; Foreign boost-link: promile uses linked score user base; UserScore boosted/deb may hold surplus only (README_SCORE.md). Never self: SCR|C>CREATE-BOOST-LINK-SCORE.
        boost-link:string           ;;[..]  BAR = own base for promile; else other score-id (≠ this score-id per SCR|C>CREATE-BOOST-LINK-SCORE).
        aqpool-link:string          ;;[..]  Specifies the Pool that employs the Score. BAR if not in use.
        fvt-link:string             ;;[..]  Specifies the FVT the Score is part of. BAR if not in use.
        triplet:bool                ;;[..]  false at issue; true once bundled in SCR|T|Triplet (immutable).
        triplet-id:string           ;;[..]  BAR until triplet issue; then T|bronze|silver|golden (immutable).
        ;;Score Information
        deb-boost:bool              ;;[.t]  Specifies if DEB boosting occurs.
        ;; THE PERMANENT "THIS SCORE CANNOT DRIFT" LATCH. One-way to true, owner-gated, and
        ;; settable ONLY while the score is provably drift-free: deb-boost false AND
        ;; boost-class-link BAR. Those two are the only inputs to a weight that can move without
        ;; the holder restaking -- an Elite tier change moves deb, a booster promile moves the
        ;; boost -- so a score with neither is arithmetically frozen between stakes.
        ;; WHY IT EXISTS: CC_InjectStream divides by the STORED total-deb mirror and pays each
        ;; member against their STORED deb for the stream's whole duration, with no fix loop and
        ;; no freshness enforce (memories/2026-10-23 §4). A mis-split there is not corrected
        ;; retroactively. Requiring every member of a streaming FVT to be latched makes that
        ;; impossible BY CONSTRUCTION rather than by a scan nobody can afford at drip time.
        ;; Checked locally at every site that could introduce drift, so no reverse index and no
        ;; cross-module lock is needed.
        drift-locked:bool           ;;[.t]  Permanently drift-proof: deb-boost false + no boost class.
        precision:integer           ;;[.]   Decimal places for per-user weights and aggregate total-* fields on this score; range enforced at issuance; forward writers must respect it.
        total-base-score:decimal    ;;[M]   Sum of user base-scores; same decimal precision as precision field
        total-boosted-score:decimal ;;[M]   Sum of user boosted-scores; same decimal precision as precision field
        total-deb-score:decimal     ;;[M]   Sum of user deb-scores; same decimal precision as precision field
        total-base-deb-score:decimal    ;;[M] M3: Σ user base-deb-scores (aggregate base×deb decomposition)
        total-boosted-deb-score:decimal ;;[M] M3: Σ user boosted-deb-scores. total-base-deb + total-boosted-deb = total-deb-score.
        nzs-count:integer           ;;[M]   Store the amount of Non-Zero-Scores
        vacate-generation:integer   ;;[M]   Vacate-v2 lazy-invalidation counter (§5). Bumped once at fast-vacate
        ;;                                  finalize (nuke). A SCR|T|UserScore row whose stamped-generation < this
        ;;                                  reads as 0 (stale); re-stake stamps the current value. Default 0.
        ;;
        ;;Score Class
        score-class:integer         ;;[.]   Defines the Score Class, there are 5
        ;;                                  Class 0 = LP Score (LP - native|sleeping|freezing)
        ;;                                  Class 1 = DPTF Score (non LP) 
        ;;                                  Class 2 = DPOF Score (non LP)
        ;;                                  Class 3 = DPSF Score (SFTs)
        ;;                                  Class 4 = DPNF Score (NFTs)
        ;;
        ;;LP, DPTF, DPOF
        lp-denominator:string       ;;[.]   Class-0 only: native DPTF token-id of the common pool leg (e.g. OURO-98c486052a51); BAR for classes 1-4.
        mx-frozen:decimal           ;;[.]   Multiplier for Frozen Tokens (Default 2.0)
        mx-sleeping:decimal         ;;[.]   Multiplier for Sleeping Tokens (Default 1.0)
        mx-hibernated:decimal       ;;[.]   Multiplier for Hibernated Tokens (Default 1.0)
        ;;
        ;;DPSF
        sft-equality:bool           ;;[.]   When true all SFTs are equal. When <false>, <nonce-score-value> is checked.
        ;; EQUITY COLLECTIONS ONLY, and the one weight input that is TWO-WAY. true = a raw share
        ;; (nonce 1) counts its 1 share; false = it counts NOTHING and only the package nonces 2-8
        ;; score. Present on every score because the schema is one shape; consulted ONLY in the
        ;; equity branch of URC_SignedBaseDeltaForDpsfStake, where it is the only thing that can
        ;; make two scores over the SAME collection weigh it differently.
        ;;
        ;; WHY IT HAD TO EXIST. The equity branch was keyed on the ASSET, deliberately, on the
        ;; reasoning that "a shareholder collection has exactly one meaningful weighting -- shares".
        ;; That held while one collection meant one score. It does not: CompanySharesTreasury counts
        ;; raw shares, SnakesTreasury must count only aggregated packages, and both employ scores over
        ;; the same equity collection. An asset-keyed rule cannot express that at all.
        ;;
        ;; MUTABLE BOTH WAYS, UNLIKE deb-boost, which is one-way to true -- but gated the same: the
        ;; score's nzs-count must be 0, so the pool employing it has to VACATE first. It is a weight
        ;; input, and the 2026-11-08 owner ruling on those is absolute -- a weight change does not
        ;; re-value positions already staked. A drift-locked score refuses it outright, because that
        ;; latch promises holders no input to their weight can move.
        ;;
        ;; ABSENT ON EVERY ROW THAT PREDATES IT, and that needs NO migration: the guarded reader
        ;; defaults to TRUE, which is exactly how every existing score already behaves. The column is
        ;; written the first time the flag is actually set. (§7.24 / _newcolumnsafety.py.)
        single-share-weight:bool    ;;[M]   Equity only: does nonce 1, the raw share, carry weight.
        ;;
        ;;DPNF
        nft-score-model:integer     ;;[.]   Sets NFT Score Model; Only 3 Models Allowed [-1 0 1]
        ;;                                  Model -1 = All NFTs are equal, and will have a score of 1
        ;;                                  Model  0 = NFTs will be scored by their native Score Systems
        ;;                                  Model  1 = NFTs scored from SCR|T|NF|TraitScore / SCR|T|NF|ClassScore rows
        ;;
        ;;Select Keys
        score-id:string             ;;[.]   Stores the ID of the Score
    )
    (defschema SCR|UserSchema
        @doc "Per account x pool x score. base-score, boosted-score, \
            \ deb-score are updated on Stake/Unstake (and related paths), \
            \ not by bulk recompute when SCR|Schema rules change; migrate \
            \ via a new score-id."
        base-score:decimal
        boosted-score:decimal
        deb-score:decimal
        base-deb-score:decimal      ;;[M]  M3: base × deb (deb applied to the base part)
        boosted-deb-score:decimal   ;;[M]  M3: boost × deb (deb applied to the boost part). base-deb + boosted-deb = deb-score.
        stamped-generation:integer  ;;[M]  Vacate-v2 (§5): the SCR|Schema.vacate-generation this row was written under.
        ;;                                 When < the score's current vacate-generation, readers treat this row as 0
        ;;                                 (stale after a fast-vacate); a fresh stake re-stamps it live. Default 0.
        ;;
        ;;Select Keys
        ouronet-account:string
        pool-id:string
        score-id:string
    )
    (defschema SCR|SingularUserScoreDelta
        @doc "Result of applying one signed user-base delta at score precision: new user triple, nz-count delta, and deltas to SCR|T|Score aggregate totals \
            \ (LP stake legs are one consumer; other forward paths can reuse the same derivation object). Aggregate totals are floored at the score precision field in XI."
        new-user-base-score:decimal
        new-user-boosted-score:decimal
        new-user-deb-score:decimal
        new-user-base-deb-score:decimal
        new-user-boosted-deb-score:decimal
        nz-delta:integer
        delta-global-base-score:decimal
        delta-global-boosted-score:decimal
        delta-global-deb-score:decimal
        delta-global-base-deb-score:decimal
        delta-global-boosted-deb-score:decimal
    )
    (defschema SCR|SF|Schema
        @doc "Per (score-id, dpsf-id, nonce). Changing nonce-score-value \
            \ changes weights for that nonce going forward; wholesale rule \
            \ changes still favor a new score-id if fairness requires it."
        nonce-score-value:decimal   ;;[M]   Score Value of DPSF Nonce
        ;;
        ;;Select Keys
        score-id:string
        dpsf-id:string
        nonce:integer
    )
    (defschema SCR|NF|TraitSchema
        @doc "Per (score-id, dpnf-id, trait-key, trait-value). trait-score-value is mutable."
        trait-score-value:decimal   ;;[M]
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
        trait-key:string
        trait-value:string
    )
    (defschema SCR|NF|ClassSchema
        @doc "Per (score-id, dpnf-id, dpnf-nonce-class). trait-score-value is mutable (set-mode class weights)."
        trait-score-value:decimal   ;;[M]
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
        dpnf-nonce-class:integer    ;;[.]   0 = all native NFTs in class model; >0 = specific set class (AQP-ANK DPNF anchors)
    )
    (defschema SCR|SF|DefRevision
        @doc "Per (score-id, dpsf-id). revision-nonce bumps on any add or \
            \ update in SCR|T|SF|Score for that score-id and dpsf-id."
        revision-nonce:integer      ;;[M]   Bump on SCR|T|SF|Score change
        ;;
        ;;Select Keys
        score-id:string
        dpsf-id:string
    )
    (defschema SCR|NF|DefRevision
        @doc "Per (score-id, dpnf-id). global-revision-nonce bumps on any trait or class definition change; \
            \ trait-revision-nonce only on SCR|T|NF|TraitScore change; class-revision-nonce only on SCR|T|NF|ClassScore change."
        global-revision-nonce:integer   ;;[M]
        trait-revision-nonce:integer    ;;[M]
        class-revision-nonce:integer     ;;[M]
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
    )
    (defschema SCR|NF|TraitKeys
        @doc "Per (score-id, dpnf-id): the DISTINCT trait-keys with any SCR|T|NF|TraitScore definition. Lets model-1 \
            \ trait scoring point-read each defined key against a staked nonce's metadata instead of scanning."
        trait-keys:[string]         ;;[M]   distinct defined trait-keys
        ;;
        ;;Select Keys
        score-id:string
        dpnf-id:string
    )
    (defschema SCR|Triplet
        @doc "Key = T|<bronze-score-id>|<silver-score-id>|<golden-score-id>. Bundles three SCORE rows for FVT TripletLink membership. \
            \ Positions bronze/silver/golden are id slots only (not boost roles). true-triplet when one score has BAR boost-link and the other two boost-link to it. \
            \ Tags: [.] fixed at issue."
        bronze-score-id:string                               ;;[.]   First score id slot
        silver-score-id:string                               ;;[.]   Second score id slot
        golden-score-id:string                               ;;[.]   Third score id slot
        triplet-category:string                              ;;[.]   LP | VAULT_TF | TREASURY_SF_NF (from shared score-class)
        triplet-id:string                                    ;;[.]   Select key T|bronze|silver|golden
        true-triplet:bool                                    ;;[.]   Boost-anchored bundle (one BAR hub, two satellites)
    )
    (defschema SCR|ScoreEntityModel
        @doc "Key = <Model-ID>. A reusable score-entity TEMPLATE so many entities issue IDENTICALLY (DSA: every \
            \ agency scores the same). single (entity-type 1): the scoring spec — issue 1 score + its SF definition \
            \ from it. triplet (entity-type 3): references three single model-ids — issue the 3 singles, then \
            \ C_IssueTriplet. Tags: [.] fixed at define."
        entity-type:integer                                  ;;[.]   CT_SCORE_MODEL_SINGLE (1) | CT_SCORE_MODEL_TRIPLET (3)
        score-class:integer                                  ;;[.]   single: 3 = SemiFungible (DPSF), v1 SF only. triplet: 0.
        collectable-id:string                                ;;[.]   single: the DPSF id the definition scores. triplet: BAR.
        precision:integer                                    ;;[.]   single: score precision. triplet: 0.
        nonces:[integer]                                     ;;[.]   single: SF definition nonces (incl. fragment negatives). triplet: [].
        nonce-score-values:[decimal]                         ;;[.]   single: parallel values. triplet: [].
        ;;ADDED 2026-09-19 — ANCHORS IN DELEGATION VAULTS. A score's boost-class link used to be
        ;;settable only AFTER issue, by whoever owns the score — which in a delegation vault is the
        ;;AGENCY OPERATOR, not the vault admin. That inverted the intended authority: an agency
        ;;could decline the vault's anchor, or point at a different class, and every agency on one
        ;;vault could score by different rules. Carrying it on the MODEL puts the decision where it
        ;;belongs: the vault admin defines how a score behaves, the agency merely opens under those
        ;;rules. XI_IssueOneFromModel applies it at issue; BAR means "no boost class", which is the
        ;;pre-existing behaviour and what every model written before this field defaulted to.
        boost-class-id:string                                ;;[.]   single: ANK boost class applied at issue (BAR = none). triplet: BAR.
        bronze-model-id:string                               ;;[.]   triplet: the 3 sub single-model ids. single: BAR.
        silver-model-id:string
        golden-model-id:string
        ;;Select Keys
        model-id:string                                      ;;[.]
    )

    ;;<=========================================================================>
    ;;{3}  AQP   — pools, per-fungibility trackers, beneficiary totals
    ;;      source: 03_AQP.pact
    ;;
    (defschema AQP|Schema
        @doc "One aqp-class and one canonical asset-id per pool; employed \
            \ scores must match that class. Staking asset identity is \
            \ authoritative here (SCORE: Score -> aqpool-link -> this pool \
            \ -> asset-id). Class 0: asset-id is the primary LP key; stake \
            \ paths may accept additional linked LP token ids (native / \
            \ sleeping OF / frozen TF) when verified as the same LP family; \
            \ all credit the same pool score slots. Fix wrong pool economics \
            \ by issuing a new pool and new scores, not by mutating class or \
            \ primary asset-id after stake exists."
        ;;
        aqp-class:integer                                       ;;Defines the Pool Class, there are 5
        ;;                                                        Class 0 = LP family pool (issue native LP; stake native|F||Z| LP)
        ;;                                                        Class 1 = DPTF family pool (issue native DPTF; stake native|F| + linked sleep/hib DPOF)
        ;;                                                        Class 2 = standalone DPOF (issue one dpof; no sleep/hib satellites — use class 0/1)
        ;;                                                        Class 3 = DPSF collection pool
        ;;                                                        Class 4 = DPNF collection pool
        asset-id:string                                         ;;ID of the Asset that is allowed to be staked in the Pool.
        ;;                                                        This must be in accordance with the <aqp-class> and together with it
        ;;                                                        Defines which assets can be staked in the Pool
        ;;
        ;;Score - Links
        score-primary:string
        score-secondary:string
        score-tertiary:string
        score-quaternary:string
        score-quinary:string
        score-senary:string
        score-septenary:string
        ;;
        stake-enabled:bool                                      ;;[M]   Gates new stakes when false; default true at issue. Unstake/vacate ignore.
        vacate-in-progress:bool                                 ;;[M]   True while AQP-VCT session active on this pool.
        sweep-in-progress:bool                                  ;;[M]   True while a re-score sweep (anchor retire/re-price) runs; blocks stake + collect (D3).
        nns:integer                                             ;;[M]   #FP1: number of OCCUPIED nonce positions in the pool tracker (occupancy oracle,
        ;;                                                        counts ghost nonces that nzs misses). -1 for amount-based pools (class 0/1, N/A);
        ;;                                                        0 at issue for nonce-based pools (class 2/3/4). +1 on a position going empty->occupied,
        ;;                                                        -1 on occupied->empty (last amount removed). Finalize uses nns==0 for nonce pools.
        ;;
        ;;Select Keys
        aqp-id:string
    )
    (defschema AQP|TrueFungibleTracker
        balance:decimal                                         ;;Store DPTF Balance Amount
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dptf-id:string                                          ;;DPTF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
    )
    (defschema AQP|OrtoFungibleTracker
        balance:decimal                                         ;;Staked DPOF amount for this nonce slot
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpof-id:string                                          ;;DPOF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    (defschema AQP|SemiFungibleTracker
        @doc "DPSF custody: staked balance per pool, collection, owner, beneficiary, nonce."
        balance:decimal                                         ;;Stores DPSF Balance
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpsf-id:string                                          ;;DPSF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    (defschema AQP|NonFungibleTracker
        @doc "DPNF custody: staked balance per pool, collection, owner, beneficiary, nonce."
        balance:decimal                                         ;;Stores DPNF Balance
        ;;
        ;;Select Keys
        pool-id:string                                          ;;Pool-ID
        dpnf-id:string                                          ;;DPNF-ID
        owner-id:string                                         ;;Owner-ID
        beneficiary-id:string                                   ;;Beneficiary-ID
        nonce:integer                                           ;;Nonce-Value
    )
    (defschema AQP|BenDptfTotal
        @doc "Cross-pool rollup: total DPTF staked by one beneficiary on one exact dptf-id leg \
            \ (native X and F|X are separate rows). Maintained on every TF stake/unstake POOL leg \
            \ (FVT::CC_TrueFungibleStakeFlow → XE_TrueFungible* legs → XI bump). Input to \
            \ ANK::XE_UpdateTrueFungibleUserAnchorValues without scanning AQP|T|DPTFTracker keys. \
            \ last-ank-sync-count stores AQP-ANK::UR_AA|AnchorsActive(dptf-id) after the last successful \
            \ anchor refresh; URC_BenDptfAnchorsNeedSync compares it to the live count so the UI can \
            \ prompt C_SyncTrueFungibleAnchors when new anchors are issued after stake. Per-pool detail \
            \ remains in AQP|T|DPTFTracker; this row is the single O(1) read for anchor promile."
        total-balance:decimal                                           ;;[M] Sum of tracker balances for (beneficiary, dptf-id) across all pools
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last C_Sync* / stake ANK leg (0 = never synced)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.] Beneficiary (SCORE/ANK ouronet-account)
        dptf-id:string                                                  ;;[.] Exact DPTF id leg (native or F|); must match ANK ank-asset for sync call
    )
    (defschema AQP|BenDpsfNonceTotal
        @doc "Cross-pool per-nonce DPSF rollup for one beneficiary. Separate table from DPNF so SELECT inventory \
            \ does not scan NFT rows. Maintained on DPSF stake/unstake POOL legs (phase 1.3, planned). amount is \
            \ integer supply staked on that nonce across all pools; 0 means fully unstaked (row may remain)."
        amount:integer                                                  ;;[M] Staked supply on this nonce (0 = no active stake)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.] Beneficiary (SCORE/ANK ouronet-account)
        dpsf-id:string                                                  ;;[.] DPSF collection id (ANK ank-asset for SF sync)
        nonce:integer                                                   ;;[.] DPSF nonce
    )
    (defschema AQP|BenDpnfNonceTotal
        @doc "Cross-pool per-nonce DPNF rollup for one beneficiary. Separate table from DPSF — same id string may \
            \ exist on both collections when minted in one tx, but rows live in disjoint tables. Maintained on DPNF \
            \ stake/unstake POOL legs (phase 1.3, planned)."
        amount:integer                                                  ;;[M] Staked supply on this nonce (0 = no active stake)
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpnf-id:string                                                  ;;[.] DPNF collection id
        nonce:integer                                                   ;;[.] DPNF nonce
    )
    (defschema AQP|BenDpsfAnkMeta
        @doc "Per (beneficiary, dpsf-id) ANK sync metadata. last-ank-sync-count is leg-wide, not per nonce — \
            \ mirrors AQP|BenDptfTotal for TF. active-nonce-count is O(1) has-stake for defcaps (no select). \
            \ Bumped when BenDpsfNonceTotal crosses 0↔positive; preserved on sync stamp."
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last sync (0 = never)
        active-nonce-count:integer                                      ;;[M] Count of BenDpsfNonceTotal rows with amount > 0
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpsf-id:string                                                  ;;[.]
    )
    (defschema AQP|BenDpnfAnkMeta
        @doc "Per (beneficiary, dpnf-id) ANK sync metadata — DPNF counterpart of AQP|BenDpsfAnkMeta."
        last-ank-sync-count:integer                                     ;;[M] ANK AssetAnchors.anchors-active at last sync (0 = never)
        active-nonce-count:integer                                      ;;[M] Count of BenDpnfNonceTotal rows with amount > 0
        ;;
        ;;Select Keys
        beneficiary-id:string                                           ;;[.]
        dpnf-id:string                                                  ;;[.]
    )
    (defschema AQP|UserOccupancy
        @doc "Vacate-v2 §4: per (pool, beneficiary) occupancy — the count of this beneficiary's OCCUPIED \
            \ tracker positions in the pool (nonce rows for class 2/3/4; the single TF leg contributes 1 for \
            \ class 1). Maintained alongside the pool nns on every tracker 0<->occupied transition (stake / \
            \ unstake / vacate-drain). The fast-vacate drain settles a beneficiary exactly once, the moment \
            \ this hits 0 (their last position drained). Point-readable so the drain never scans tracker keys."
        unn:integer                                                     ;;[M] User-Nonces-in-pool: occupied tracker positions for this beneficiary
        ;;
        ;;Select Keys
        pool-id:string                                                  ;;[.] Pool
        beneficiary-id:string                                           ;;[.] Beneficiary (SCORE / reward recipient)
    )

    ;;<=========================================================================>
    ;;{4}  RPS   — reward engine: global/member/user/stream ledgers
    ;;      source: 04_RPS.pact
    ;;
    (defschema FVT|RPS|Global
        @doc "Key = <FVT-ID> | <DPTF-ID>. One registered reward DPTF on this FVT."
        reward-enabled:bool
        current-rps:decimal
        available-rewards:decimal
        unclaimed-count:integer                                 ;;[M]   legs whose claimable is > 0 RIGHT NOW
        ;; S1 (2026-11-09): `unclaimed-count` is DOCUMENTED as "users with unclaimed rewards" and was
        ;; MAINTAINED as "accounts that can ever claim" -- it is only decremented when an account
        ;; UNSTAKES, never when a still-staked account collects to zero. So on a live aggregator it
        ;; never reaches 1, the last-claimant dust sweep is unreachable, and the floor dust accrues.
        ;; Measured on mainnet 2026-11-08: the count EXCEEDS the positive-claimable leg count on ALL
        ;; ELEVEN live lanes (SubsidiaryTreasury/AURYN read 69 against 27), and three lanes held a
        ;; balance with ZERO collectable legs.
        ;;
        ;; THE FIX NEEDS A SECOND COUNTER, and this is the one field that makes the first one
        ;; restorable in O(1). At every accrual the count must be reset to the number of legs that
        ;; then have a positive claimable, which is `earning + dormant`:
        ;;   earning  -- legs that receive a share of THIS accrual;
        ;;   dormant  -- legs still OWED from an earlier accrual that receive nothing from this one:
        ;;               an account that fully unstaked without collecting, or a member whose
        ;;               ScoreEntityLink is toggled off.
        ;; RESETTING TO `nzs` ALONE IS THE DEFECT THE CANONICAL `coin` VAULT ALREADY REMOVED -- its
        ;; live source says so twice ("do not reset unclaimed to nzs or we lose 0-score-with-pending
        ;; accounts"). An orphan is not in `nzs` and is still owed, so a reset to `nzs` reads LOW,
        ;; `= 1` fires while someone else is owed, and the sweeper takes their rewards. Counting the
        ;; dormant legs separately is what makes the restore safe in BOTH directions.
        dormant-claim-count:integer                             ;;[M]   owed legs that earn nothing at accrual
        ;; Escrow-on-empty (zombie/limbo): reward tokens injected while the inject denominator is 0 (no stakers)
        ;; are held here — physically in AQP|SC_NAME custody, counted, but NOT yet routed into G / available-rewards.
        ;; The next inject at a NON-zero denominator adds this on top of its amount, distributes the sum to whoever
        ;; is staked at that instant (pro-rata via G / farm-split), and zeroes it. Kept OUT of available-rewards so
        ;; the M1 last-claimant dust sweep can never pay a prior cohort the pending escrow. No owner reclaim: it
        ;; stays until a normal non-zero inject flushes it.
        zombie-rewards:decimal
        segmentation:bool
        reward-kind:string                                      ;;[.]   PLAIN | MULTIPLET_BASE
        multiplet-family-id:string                              ;;[.]   BAR or F|t0|t1|t2
        ;; Time-streamed inject (linear vesting) — the lane's active-stream ledger cursor. stream-count = live
        ;; stream positions (0 = none; the drip fast-returns). stream-last-release = shared lane checkpoint (every
        ;; active stream's start <= this, since a new stream is only added AFTER a drip). stream-unreleased =
        ;; custodied-but-not-yet-dripped total (held in AQP|SC_NAME, kept OUT of available-rewards / the M1 sweep
        ;; until the drip releases it). See Audit/STREAMED-INJECT-DESIGN.md.
        stream-count:integer
        stream-last-release:time
        stream-unreleased:decimal
        ;; DSA royalty pool: the uptime-shortfall slice of a delegation inject that no agency captured
        ;; (Σ capture-units − Σ effective capture-weight, worth A×that/Σunits). Custodied in AQP|SC_NAME, kept
        ;; OUT of available-rewards / G / the M1 sweep until the owner disposes it (withdraw / burn / fuel).
        ;; Always 0.0 on a non-delegation lane (Σ capture-weight == Σ capture-units ⇒ no shortfall).
        royalty-rewards:decimal
        ;; The lane's FLOOR on a single injection, set by the FVT owner. Added 2026-10-23 because
        ;; `CC_Inject` runs its stale-fix loop regardless of `amount` — so without a floor, one
        ;; smallest-unit injection force-fixes an entire membership, and (when the owner is the
        ;; injector) force-BILLS it. Defaults to CT_DEFAULT_MIN_INJECT at lane creation; every row
        ;; written before this field existed is carried to the same default by the one-time
        ;; AA_MigrateMinInject pass that ships with this round.
        min-inject-amount:decimal
        ;;
        ;;Select Keys
        fvt-id:string
        dptf-id:string
    )
    (defschema FVT|RPS|Member
        @doc "Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>. Member reward line per score-entity × reward DPTF."
        last-farm-rps-g:decimal
        member-deb-rps:decimal
        pending-member-rewards:decimal
        ;;
        ;;Select Keys
        fvt-id:string
        score-entity-id:string
        dptf-id:string
    )
    (defschema FVT|RPS|User
        @doc "Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>. Per-staker row."
        last-rps:decimal
        pending-rewards:decimal
        user-id:string
        fvt-id:string
        score-entity-id:string
        dptf-id:string
    )
    (defschema FVT|RPS|Stream
        @doc "Key = <FVT-ID> | <DPTF-ID> | <position 1..49>. One live linear-release stream on a reward lane. \
            \ Positions are kept COMPACT (occupied = 1..stream-count); a finished stream is pruned and later \
            \ positions shift down. UI renders position n as tier-style major.minor (major = ceil(n/7), \
            \ minor = ((n-1) mod 7) + 1). rate = amount/duration (token-per-second, high precision); finish = \
            \ block-time the stream stops; amount = original streamed amount; released = cumulative released so \
            \ far, so the finish drip flushes (amount - released) and per-stream conservation is exact."
        rate:decimal
        finish:time
        amount:decimal
        released:decimal
        ;;
        ;;Select Keys
        fvt-id:string
        dptf-id:string
        position:integer
    )
    (defschema FVT|MemberVault
        @doc "Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID> (base ATS token). The per-member mini-vault for the \
            \ Tier-1 dust sweep (M1 / #10): available-rewards = rewards routed to this member (farm split-at-inject \
            \ slice, or vault Tier-2 earned) minus what its users have been paid; unclaimed-count = users in this \
            \ member with a live claim. When unclaimed-count hits 1, the member's last user is paid available-rewards \
            \ (sweeping the member's floor dust). Mirrors FVT|RPS|Global's available-rewards/unclaimed-count one tier down."
        available-rewards:decimal
        unclaimed-count:integer
        ;; THE TIER-1 TWIN OF `FVT|RPS|Global.dormant-claim-count`, and it is NOT optional. The
        ;; member branch of the sweep (`mc == 1`) is FARM-ONLY, and the chain has exactly one farm --
        ;; `OuroLpFarm`, which is the lane that was measured holding 27 sub-units of stranded dust
        ;; with zero collectable legs. Fixing only the global counter would leave the one aggregator
        ;; where tier-1 dust actually forms still unable to sweep it.
        dormant-claim-count:integer                             ;;[M]   owed users in this member that earn nothing
        ;;
        ;;Select Keys
        fvt-id:string
        score-entity-id:string
        dptf-id:string
    )
    (defschema FVT|MemberUserWeight
        @doc "Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>. Farm-triplet per-user Level-1 weight snapshot — \
            \ w-user (Σ lanes) as of the user's last score stake/unstake. Summed into \
            \ ScoreEntityLink.total-lane-weight and used as the user's Tier-1 numerator, so numerator and \
            \ divisor share one snapshot basis (reward conservation), exactly like a singular score uses \
            \ stored deb-score + maintained total-deb-score."
        contrib-weight:decimal
        ;;
        ;;Select Keys
        user-id:string
        fvt-id:string
        score-entity-id:string
    )
    (defschema FVT|ForcedFixCount
        @doc "Key = <FVT-ID> | <DPTF-ID> | <User-ID>. M3 #12 2e penalty: how many of this user's stale scores an \
            \ enforced inject (CC_Inject / MTX|n|C_Inject) FORCE-fixed on this reward lane since the user last \
            \ collected it. At collect the user pays `count × RATE` NON-discountable IGNIS (a gas reimbursement — \
            \ the inject did N fixes for him; reward paid is untouched) and the count is zeroed. Self-fixing at \
            \ collect (PHASE 6 backstop) does NOT bump this — only inject-forced fixes do, so self-fixing stays \
            \ the cheaper path."
        count:integer
        ;;
        ;;Select Keys
        fvt-id:string
        dptf-id:string
        user-id:string
    )
    (defschema FVT|RewardAggregate
        @doc "Key = <FVT-ID>. Reward-computation aggregates split out of FVT|Schema (#75 B' Stage 1) so \
            \ the reward orchestration owns them; identity/config stays in FVT|Schema."
        fvt-class:integer                                       ;;[.]   0=Farm · 1=Vault · 2=Treasury (moved here #75 B' Stage 2)
        owner-konto:string                                      ;;      entity owner (moved #75 B' Stage 2b)
        mosaic:bool                                             ;;[Mu]  mix score + triplet entities when true
        membership-mode:string                                  ;;[Mu]  BAR | SCORE | TRUE-TRIPLET | STANDARD-TRIPLET
        split-mode:string                                       ;;[M]   Farm reward-split: SPLIT|STAKED | SPLIT|TVL
        total-ghost-tvl-weight:decimal                          ;;[M]   Farm S = sum enabled ScoreEntityLink W_i
        total-base-score:decimal
        total-boosted-score:decimal
        total-deb-score:decimal
        total-nzs-count:integer
        ;; EARNING LEGS, AND IT IS NOT `total-nzs-count`. A reward leg is (user, score-entity): the
        ;; booking is per member. `nzs-count` is per SCORE, and one member can employ SEVERAL scores
        ;; -- measured on chain, DHOuroLp employs THREE and the same six accounts hold all three, so
        ;; a sum over employed scores counts one user three times for ONE leg. Restoring
        ;; `unclaimed-count` from such a sum would set it ABOVE the collectable legs, the sweep would
        ;; never reach 1, and the dust would accrue exactly as before -- the defect reintroduced by
        ;; its own repair. (`total-nzs-count` itself has a reader, no writer and no consumer; it is
        ;; left alone here and should be retired separately rather than pressed into this job.)
        ;; MAINTAINED WHERE THE TRANSITION ALREADY EXISTS: `XI_1|BookUnclaimedForFvtRewardLine`
        ;; already derives, per member, whether this user held weight BEFORE and AFTER
        ;; (`m-was`/`m-is`). That IS the (user, member) leg transition, so this is +1/-1 at a site
        ;; that already runs -- no walk, and nothing new on the inject path.
        earning-leg-count:integer                               ;;[M]   (user, member) pairs with non-zero weight
        enabled-reward-count:integer
        member-link-count:integer                               ;;[M]   ScoreEntityLink rows (gates C_SetMosaic)
        ;;Select Keys
        fvt-id:string
    )
    (defschema FVT|ScoreEntityLink
        @doc "Key = <FVT-ID> | <Score-Entity-ID>. Unified membership — score (type 1) or triplet (type 3)."
        score-entity-type:integer                               ;;[.]   CT_SCORE_ENTITY_SCORE=1, CT_SCORE_ENTITY_TRIPLET=3
        ;; TIER-1 EARNING COUNT: users with non-zero weight on THIS member. Lane-independent (weight
        ;; is not per reward token), which is why it lives on the link row and not on the mini-vault.
        ;; Same +1/-1 site as `FVT|RewardAggregate.earning-leg-count`, from the same `m-was`/`m-is`.
        earning-user-count:integer                              ;;[M]   users with non-zero weight on this member
        enabled:bool                                            ;;[M]
        swpair:string                                           ;;[..]
        ghost-tvl-weight:decimal                                ;;[M]   Level-2 W_i (SWP staked value)
        total-lane-weight:decimal                               ;;[M]   Farm-triplet Level-1 divisor Σ w-user;
        ;;                                                              snapshot-maintained at stake/unstake (phase 4.6),
        ;;                                                              point-read as the L_i divisor (no staker scan).
        ;; DSA (Delegated Staking Agencies) — set only for a delegation member (= an agency); default
        ;; false/0.0/0.0/EPOCH for every normal member. DSA maintains them (delegator stake/unstake + the daily
        ;; oracle) via an XE_; FVT only ever READS its own fields at inject (dependency DSA -> FVT). See
        ;; Audit/DSA-DELEGATED-STAKING-DESIGN.md §3.
        delegation:bool                                         ;;[M]   is this member a DSA agency?
        capture-units:decimal                                   ;;[M]   ideal capacity = min(floor(Q/unit-score), nodes) — the IDEAL denominator term
        capture-weight:decimal                                  ;;[M]   actual = capture-units × uptime/1000 — the inject NUMERATOR
        oracle-ts:time                                          ;;[M]   timestamp of the last oracle write (now − ts > 25h ⇒ effective capture 0)
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;[.]
        score-entity-id:string                                  ;;[.]   score-id or triplet-id T|…
    )
    (defschema FVT|MultipletFamily
        @doc "Key = F|<token-0-id>|<token-1-id>|<token-2-id>. Reward ladder for MULTIPLET_BASE collect."
        token-0-id:string
        token-1-id:string
        token-2-id:string
        ats-0-1-id:string
        ats-1-2-id:string
        rank:integer                                            ;;[.]   Lane count at issue (v1 = 3)
        active:bool
        ;;
        ;;Select Keys
        multiplet-family-id:string
    )
    (defschema FVT|UserPresence
        @doc "Key = <FVT-ID> | <Ouronet-ID>. Membership marker (M3 #12 / shared with the H4 anchor sweep): \
            \ is-present = true while the user holds a live position (nonzero weight) in AT LEAST ONE of this \
            \ FVT's score-entities. Written true (add-only) on every stake; recomputed to false on the unstake \
            \ that drops the user's LAST position in the FVT. Maintained for ALL FVT classes. Lets a sweep \
            \ enumerate one FVT's users with a single `select` over a small purpose-built table (no giant \
            \ RPS|User scan). A stale `true` is harmless — the sweep no-ops on a zero-weight user."
        is-present:bool
        ;;
        ;;Select Keys
        fvt-id:string
        ouronet-id:string
    )
    (defschema FVT|AgencyFee
        @doc "Key = <FVT-ID> | <Score-Entity-ID>. DSA operator fee for a delegation member (the agency), mirrored \
            \ from DSA|Agency so the FVT inject settle can read it locally (FVT can't reach DSA). At inject the \
            \ member-slice is split: the delegator-facing index L_i advances by member-slice·(1−fee) (so ALL \
            \ stakers accrue net), and the whole member-slice·fee is credited DIRECTLY to the operator's pending — \
            \ giving the operator its own weighted share + the fee (effective weight own + fee·Σdelegators), \
            \ delegators (1−fee), conserved. The fee is never baked into a stored weight, so a fee change is O(1) \
            \ (it only reprices the NEXT inject). Set by DSA at open + C_SetAgencyFee."
        operator-konto:string
        fee-per-mille:integer
    )
    (defschema FVT|QualitySplit
        @doc "Key = <FVT-ID> | <DPTF-ID> (same as RPS|Global). Round B: the per-FVT reward MODE + heterogeneous \
            \ split MATRIX for a MULTIPLET_BASE triplet reward. HOMOGENEOUS ⇒ each lane routes to its one ladder \
            \ token (bronze→t0, silver→t1, gold→t2) — the default when this row is absent. HETEROGENEOUS ⇒ each \
            \ lane splits across ALL 3 ladder tokens per its row [to-t0 to-t1 to-t2] (per-mille, sums to 1000): \
            \ bronze-split for the bronze lane, silver-split for silver, gold-split for gold. Per-FVT-reward + \
            \ owner-tunable (unlike the chain-wide immutable FVT|MultipletFamily ladder)."
        mode:string                                             ;;[M]   HOMOGENEOUS | HETEROGENEOUS
        bronze-split:[integer]                                  ;;[M]   [to-t0 to-t1 to-t2] per-mille, sums 1000
        silver-split:[integer]                                  ;;[M]
        gold-split:[integer]                                    ;;[M]
        ;;Select Keys
        fvt-id:string
        dptf-id:string
    )
    (defschema FVT|DsaOracleConfig
        @doc "Single GLOBAL row (key = FVT|DSA-ORACLE-KEY). The protocol-wide DSA external-oracle switch + validity \
            \ window, replacing the per-FVT oracle-on + the DSA_ORACLE_TTL constant. `external-oracle` = is external \
            \ oracling on at all: ON ⇒ a delegation member captures its weight only while its last oracle write is \
            \ fresher than `oracle-validity` seconds (no/stale entry ⇒ effective 0); OFF ⇒ oracling is bypassed \
            \ entirely and the stored capture-weight is trusted as-is. Read lazily (defaults: on=true, \
            \ validity=DSA_ORACLE_TTL) so no init is needed; written only by A_ToggleExternalOracle / \
            \ A_SetOracleValidity (DSA module admin) via the FVT XE_ setters."
        external-oracle:bool
        oracle-validity:integer
    )
    (defschema FVT|ScorePreNzFlag
        @doc "Pre-SCORE snapshot for one employed score."
        score-id:string
        was-nz:bool
    )
    (defschema FVT|SettleFvtRewards
        @doc "One distinct FVT row in URH_FVT|SettleFvtRewardBundle."
        fvt-id:string
        reward-dptf-ids:[string]
    )
    (defschema FVT|SettleScorePlan
        @doc "One score-entity row in URC_SettleScorePlanRows — entity + fvt + reward list."
        score-entity-type:integer
        score-entity-id:string
        fvt-id:string
        reward-dptf-ids:[string]
    )
    (defschema FVT|MemberPreDeb
        @doc "Pre-SCORE live deb-weight snapshot for one settled member (M2/#11 incremental total-deb mirror). \
            \ Self-describing (carries its keys) so no positional alignment with settle-plans is needed."
        fvt-id:string
        score-entity-type:integer
        score-entity-id:string
        pre-deb:decimal
    )
    (defschema FVT|StakeSettleBundle
        @doc "Precomputed stake/unstake settle scope."
        settle-scores:[string]
        distinct-fvts:[string]
        settle-plans:[object{FVT|SettleScorePlan}]
        pre-nz-flags:[object{FVT|ScorePreNzFlag}]
        pre-member-debs:[object{FVT|MemberPreDeb}]
    )

    ;;<=========================================================================>
    ;;{5}  FVT   — farms, vaults, treasuries
    ;;      source: 05_FVT.pact
    ;;
    (defschema FVT|Schema
        @doc "Key = <FVT-ID>. One farm, vault, or treasury (FVT) entity: class, owner, enabled-reward-count, SCORE aggregate mirrors. \
            \ Farm (fvt-class 0): common-denominator + total-ghost-tvl-weight S is inject denominator. \
            \ Vault/Treasury: total-deb-score mirror for inject; common-denominator sentinel \"|\"; total-ghost-tvl-weight 0.0. \
            \ UrStoa analogue: vault header (urstoa-supply on SCORE side; S or total-deb here is FVT-side denominator). \
            \ Field tags: [.] fixed at issue; [..] fixed once set; [M] mutable; [Mu] mutable only under owner + can-upgrade."
        can-upgrade:bool
        can-change-owner:bool
        common-denominator:string                               ;;[Mu]  unsafe to change after ScoreEntityLinks
        oracle-on:bool                                          ;;[M]   DSA: node/uptime oracle governs capture. Default false.
        ;; STREAMING LATCH. One-way to true, owner-gated, HEAVY to set: latching scans every
        ;; enabled ScoreEntityLink and requires each member score to be drift-locked. Once true,
        ;; C_AddScoreEntity / C_ToggleScoreEntityLink refuse any member that is not drift-locked,
        ;; so the proof cannot be invalidated afterwards. CC_InjectStream refuses unless this is
        ;; true. Defaults FALSE -- the fail-safe direction: an un-latched FVT simply cannot open
        ;; NEW streams, while streams already running keep dripping (XI_ReleaseStream is not gated
        ;; by the inject defcap, and halting a live vest would strand custodied tokens).
        ;; LIVES HERE, NOT ON FVT|RewardAggregate: this is entity CONFIG, which is what this row
        ;; holds, and it is read/written by AQP-FVT itself -- so it needs no cross-module hop.
        stream-eligible:bool                                    ;;[.t]  May open time-streamed injects.
        ;; fvt-class, owner-konto, mosaic, membership-mode, split-mode + the reward aggregates
        ;; live in FVT|RewardAggregate (#75 B' Stage 1/2) — the reward engine reads/owns them.
        ;;Select Keys
        fvt-id:string
    )
    (defschema FVT|VacateFreeze
        @doc "Key = <FVT-ID>. True while a pool this FVT serves is mid-vacate — blocks collect + inject on the FVT \
            \ so the owner-forced vacate is not interfered with (stake/unstake are frozen pool-side via \
            \ PoolVacateInProgress). Set by AQP-VCT begin (XI_EnsureVacateBegun) on each of the vacating pool's \
            \ employed-score FVTs; cleared by VCT finalize. Read via UR_FVT|VacateFrozen (with-default-read false)."
        frozen:bool
    )
    (defschema FVT|SweepProgress
        @doc "Key = <Anchor-ID>. Cursor for the paginated defun+gate re-score sweep (CC_SweepBegin → \
            \ CCp_SweepRecomputeChunk*), the scalable twin of the fixed 2-step MTX|2|C_SweepRevokeAnchor defpact. \
            \ `total` = the recompute-set size captured at BEGIN (sweep-in-progress freeze holds URH_FvtPresentUsers \
            \ fixed across the batch's separate txs); `offset` = holders recomputed so far over the GLOBAL flattened \
            \ present set (present users concatenated across the boost-class's score-ids in order); `active` = a \
            \ sweep is open. The finalizing chunk (win-hi reaches total) unfreezes every affected pool + clears \
            \ active — completeness is ENFORCED (pools cannot unfreeze until offset reaches total). Read via \
            \ UR_FVT|SweepProgress / UR_FVT|SweepActive (with-default-read inactive)."
        total:integer
        offset:integer
        active:bool
    )

    ;;<=========================================================================>
    ;;{6}  VCT   — vacate planning
    ;;      source: 06_VCT.pact
    ;;
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
    (defschema VCT|VacateTfLane
        @doc "One DPTF asset-lane of a pool + its TF vacate legs (PHASE-1 scan output; consumed per asset)."
        asset-id:string
        legs:[object{VCT|VacateTfLeg}]
    )
    (defschema VCT|VacateNonceLane
        @doc "One DPOF/DPSF/DPNF asset-lane of a pool + its nonce vacate legs (PHASE-1 scan output)."
        asset-id:string
        legs:[object{VCT|VacateNonceLeg}]
    )

    ;;<=========================================================================>
    ;;{7}  DSA   — delegated staking agencies
    ;;      source: 08_DSA.pact
    ;;
    (defschema DSA|Template
        @doc "Key = <FVT-ID>. Per DSA vault: binds a class-0 FVT to the score-entity MODEL every agency \
            \ instantiates (SCR|ScoreEntityModel) + the unit-score (1 staking unit = 1 node; open gate = \
            \ unit-score/2). The model fixes the scoring (Custodians nonce→quintessence) so all agencies are comparable."
        model-id:string                                         ;;[.]   the SCR|ScoreEntityModel agencies instantiate (SCORE)
        unit-score:integer                                      ;;[.]   quintessence per capture unit (e.g. 20000)
        active:bool                                             ;;[M]
        ;;Select Keys
        fvt-id:string
    )
    (defschema DSA|Agency
        @doc "Key = <FVT-ID> | <Score-Entity-ID>. One agency = one FVT member (its triplet). Operator is an \
            \ ownership role independent of stake; fee is skimmed from delegators only. nodes + uptime are the \
            \ oracle inputs to the capture transform (the derived capture-units/weight live on the FVT member)."
        operator-konto:string                                   ;;[..]  the agency operator (runs nodes, takes the fee)
        fee-per-mille:integer                                   ;;[M]   flat fee 10..500 (= 1%..50%) on delegators
        nodes:integer                                           ;;[M]   oracle: nodes the operator runs (capture cap)
        uptime:integer                                          ;;[M]   oracle: promile 1..1000 (1000 = full)
        ;;Select Keys
        fvt-id:string
        score-entity-id:string
    )
    (defschema DSA|OracleAuth
        @doc "Key = <FVT-ID>. The FVT-owner-delegated key allowed to write the daily {nodes, uptime} oracle values \
            \ for every agency on this vault."
        oracle-guard:guard                                      ;;[M]
        ;;Select Keys
        fvt-id:string
    )

)

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; AcquisitionAnchorsV3: already deployed and unchanged -- see LIVE_INTERFACES

(module AQP-ANK GOV
    @doc "Sovereign anchor module for AQP. Stores anchor definitions, BoostClasses (7-slot \
        \ groupings), per-asset anchor bookkeeping, per-user anchor promile, \
        \ per-user/boost-class aggregates, and a reverse score-link index. Issues \
        \ true/semi/non-fungible (trait or set) anchors, revokes anchors/BoostClasses, and \
        \ updates each holder's aggregate promile on stake/unstake. Includes the revoke-lock \
        \ and re-score sweep hooks; anchors feed score boosting in AQP-SCORE."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;; REPL observability: REPL/Stage_02/[6.2.1]_AQP-ANK.repl tags each intra-tx group as TXnnn · mm · <slug> in ;;==== … ==== and (print "--- [TXnnn · mm · …] ---"); mm is 01.. within each begin-tx.
    ;;
    (implements OuronetPolicyV2)
    (implements AcquisitionAnchorsV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_AQP-ANK                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ANK_ADMIN)))
    (defcap GOV|ANK_ADMIN ()                            (enforce-guard GOV|MD_AQP-ANK))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        @doc "Resolves the governance keyset from DALOS."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|AqpKey ()
        @doc "Governance keyset name for the AQP smart account (canonical — sibling AQP modules ref AQP-ANK)."
        (+ (CT_Namespace) ".dh_sc_aqp-keyset")
    )
    (defun GOV|AQP|SC_NAME ()
        @doc "Symbolic name of the AQP sovereign smart DALOS account (canonical)."
        (at 0 ["Σ.ЖřÎzэóΣQз3ÌĄăådìÜλÅË9γğ7χûПæ0₳ПûÖŞrĄθXtFìмkщsGвÅgλąÇπЩAĚЭDíéαэБùđáżñИïПÆΣтцξsηåäялÃБц¢r6ÁíäзуμþĄĐЫîÉAćýìЧыQPнŁзßξĂйjay£üѺçRЫfУQșÏΠÜqîÔĄťß6ЗSρŠeΦñëdmûΦøШâΞýκъиřк"])
    )
    (defun GOV|AQP|PBL ()
        @doc "Public branding/license payload for AQP|SC_NAME smart account deploy (canonical)."
        (at 0 ["9G.632vHq208xaznBw9AfwrFGmLBqkr7tqEzf2Msq389xqEknmfAk8qI5MM1MaszdgMtEBpo6rbuC09Do7F6pjc91jzy3JxI6fjCkyuIbDpDD5i8CxeCBL0dKdDu3d2uAAwl6wE6npnm4Mjxx6JhiFq1sKddsGjLH9BjHF0ljtegHrn39qIADru76Ftr9Kgxh6Ds2aj4EufG07uK9sFG38ej5vooDMr0wp8alqGdnIiJxbhmwEKEg44l8pI5LDq2EotoM2jq86x1EJ5hM4wkfhtq4ye610tkAMIdLrDD87Euk14aJgMwnrLmytzcCc3Kakrnhs8Jxy5dFeowGxzlx1bGHqfwEen0pLcd6nl9udGE9hfFucLjM1seKzv542nwzz5jrpKmvzebI4BLK00Br1ocvxs4uor2nEv2Fng1l6qAiLcbv0hMnbLDEEcLpF1bD55gw55of7H2c3ieozahorkuCe5FEkAkEAhcGwJ35HCletrbcn2Ebo0fsD0tf2zxKsbzinpcJCtpv4EF4AyyhwD1LbtEd6qsEbgyJkA2DqdGBE5Fuqudzf8082Ei88d"])
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
    (defcap P|ANK|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|ANK|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        @doc "Returns policy metadata key from DALOS policy module."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        @doc "Reads one policy guard by policy name."
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        @doc "Reads imported policy guards list."
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
        @doc "Enforces that caller matches an imported policy guard."
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        @doc "Writes or updates one local policy guard entry."
        (with-capability (GOV|ANK_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|ANK_ADMIN)
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
        (with-capability (GOV|ANK_ADMIN)
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
        (with-capability (GOV|ANK_ADMIN)
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
        @doc "No IMP registration, and that is a MEASURED conclusion rather than an omission. \
            \ \
            \ This module bills -- `C_Issue*Anchor` all end on IGNIS' STOA collector, which became \
            \ `P|UEV_IMC`-gated on 2026-09-20. It still needs no guard of its own in IGNIS' IMP, \
            \ because every one of those call sites is a plain `C_` reached through TS02-C3, and \
            \ `P|UEV_IMC` is DEPTH-INVARIANT: the `P|TALOS-SUMMONER` capability TS02-C3 acquires \
            \ at the top is still in scope when the collector is reached. TS02-C3's guard is \
            \ registered; this module's would be a second answer to a question already answered. \
            \ \
            \ That is not free to add. `P|UEV_IMC` -> `U|G::UEV_Any` maps `UC_Try` over the WHOLE \
            \ guard list with no short-circuit, so every entry in IGNIS' IMP costs gas on EVERY \
            \ billed operation on the chain. A redundant registration is a permanent tax. \
            \ \
            \ WHAT WOULD CHANGE THIS: a billing call site inside a `defpact` step. A step arrives \
            \ in its own transaction via `continue-pact` with an EMPTY capability scope and \
            \ inherits nothing -- which is exactly what caught MTX-SWP. If one is ever added here, \
            \ this module needs its own guard registered, or that step must acquire `P|ANK|CALLER` \
            \ itself. Verified 2026-09-20 by `REPL/tools/_impdiff.py`: this registration never \
            \ landed in the genesis chain and the full gate was green regardless."
        true
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst AQP|SC_KEY                                (GOV|AqpKey))
    (defconst AQP|SC_NAME                               (GOV|AQP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst E-ANK
        {"promile"                  : 0.0
        ,"ouronet-account"          : BAR
        ,"anchor-id"                : BAR}
    )
    ;; M6 #15 — anchor-definition sanity bounds enforced at issue (UEV_Promile + ANK|C>ISSUE-DPTF).
    (defconst CT_ANK_PRECISION:integer                  3)          ;; anchors use exactly 3 decimals of promile precision
    (defconst CT_ANK_MIN_PROMILE:decimal                1.0)        ;; minimum anchor promile
    (defconst CT_ANK_MAX_PROMILE:decimal                10000.0)    ;; maximum anchor promile (caps a single anchor's boost)
    ;;The three NATIVE liquidity-pool token prefixes. Same set as `05_DPTF.pact`'s DPTF|C>MINT
    ;;and `03_AQP.pact`'s LP predicate -- named here so the anchor authority rule and those two
    ;;cannot drift apart silently. `F|` wrappers are stripped BEFORE this is consulted.
    (defconst CT_ANK_LP_PREFIXES:[string]               ["S|" "W|" "P|"])
    (defconst CT_ANK_MIN_DPTF_AMOUNT:decimal            1000.0)     ;; minimum TF-anchor denominated amount
    (defconst CT_ANK_MAX_DPTF_AMOUNT:decimal            1000000.0)  ;; maximum TF-anchor denominated amount
    ;;{3.2}  schemas
    ;;
    ;;1]General Anchor Definition
    ;;2]BoostClass Definition
    ;;3]Per-Asset Bookkeeping
    ;;4]User Anchor Values
    ;;5]Per-User Per-BoostClass Aggregate
    ;;{3.3}  tables
    ;;
    (deftable ANK|T|Anchor:{AcquisitionSchemasV5.ANK|Schema})                        ;;Key = <Anchor-ID>
    (deftable ANK|T|BoostClass:{AcquisitionSchemasV5.ANK|BoostClass})                ;;Key = <Boost-Class-ID>
    (deftable ANK|T|AssetAnchors:{AcquisitionSchemasV5.ANK|AssetAnchors})            ;;Key = <Asset-ID>
    (deftable ANK|T|BoostClassScoreLinks:{AcquisitionSchemasV5.ANK|BoostClassScoreLinks}) ;;Key = <Boost-Class-ID>
    ;;
    (deftable ANK|T|Anchors:{AcquisitionSchemasV5.ANK|UserSchema})                   ;;Key = <Ouronet-Account> | <Anchor-ID>
    (deftable ANK|T|UserBoost:{AcquisitionSchemasV5.ANK|UserBoostSchema})            ;;Key = <Ouronet-Account> | <Boost-Class-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    (defcap ANK|C>BUMP-BOOST-CLASS-LINKS (boost-class-id:string)
        @doc "Authorizes AQP-SCORE (forward) to +1 a BoostClass score-link count — the H4 (#9) revoke lock."
        (compose-capability (SECURE))
    )
    (defcap ANK|XE>SWEEP ()
        @doc "Forward (re-score sweep · MTX-AQP): authorize the anchor-retire sweep's ANK writes — per-holder \
            \ aggregate-promile refold + swept anchor removal. NO fund movement. Composes SECURE."
        (compose-capability (SECURE))
    )
    ;;{C2}  Simple
    (defcap AQP|GOV ()
        @doc "Interface/deploy surface for AQP|SC_NAME governor rotate. Runtime compose: AQP-POOL.AQP|GOV only — \
            \ do not compose this cap from other modules."
        true
    )
    ;;{C3}  Composed
    (defcap ANK|C>UPDATE-DPTF (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Authorizes updating user promile for all live DPTF-backed anchors on <dptf-id> after stake/unstake."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
            )
            ;;1]<total-dptf-amount> must be non-negative (0.0 allowed — vacate/unstake refresh)
            ;;
            ;;DATA-INTEGRITY BACKSTOP, NOT A CLIENT-FACING CHECK. The value is never caller-supplied.
            ;;The only caller is FVT::XI_RefreshTrueFungibleStakeAnchors, reaching this cap through
            ;;AQP-ANK::XE_UpdateTrueFungibleUserAnchorValues, which opens with (P|UEV_IMC) — so no
            ;;external account can present an argument here at all. What FVT passes is the post-stake
            ;;tracker total, a sum over AQP|T|DPTFTracker balances, each of which is itself non-negative
            ;;by the custody cap (AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY refuses an unstake larger than the
            ;;staked balance, so a row can reach 0.0 but never go below it). A negative therefore cannot
            ;;be constructed from any sequence of user actions; only a corrupt tracker write could
            ;;produce one, which is precisely what this line exists to catch. Kept deliberately at >=
            ;;rather than >: 0.0 is the legal vacate/unstake refresh value.
            ;;Backed by REPL/modules/AQP.repl <<AQP-G45>>, which asserts the IMC gate and the
            ;;non-negativity of the derivation rather than pretending to drive the guard.
            ;;UNREACHABLE
            (enforce (>= total-dptf-amount 0.0) "total-dptf-amount must be non-negative")
            ;;2]<account> must exist
            (ref-DALOS::UEV_EnforceAccountExists account)
            ;;3]<dptf-id> must exist
            (ref-DPTF::UEV_id dptf-id)
            ;;4] when positive, <total-dptf-amount> must conform to DPTF precision
            (if (> total-dptf-amount 0.0)
                (ref-DPTF::UEV_Amount dptf-id total-dptf-amount)
                true
            )
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>UPDATE-DPSF (account:string dpsf-id:string nonces:[integer])
        @doc "Authorizes updating user promile for DPSF-backed anchors on one asset (delegates to UPDATE-DPDC, SF)."
        @event
        (compose-capability (ANK|C>UPDATE-DPDC account dpsf-id nonces true))
    )
    (defcap ANK|C>UPDATE-DPNF (account:string dpnf-id:string nonces:[integer])
        @doc "Authorizes updating user promile for DPNF-backed anchors on one asset (delegates to UPDATE-DPDC, NF)."
        @event
        (compose-capability (ANK|C>UPDATE-DPDC account dpnf-id nonces false))
    )
    (defcap ANK|C>UPDATE-DPDC (account:string asset-id:string nonces:[integer] son:bool)
        @doc "Authorizes a DPDC anchor-value update for <account> on <asset-id>'s <nonces> \
            \ (<son> discriminates the set / non-set collectable fungibility mode). Validates the \
            \ account exists and the nonces exist for the target DPDC asset; composes SECURE for the write."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            ;;1]<account> must exist
            (ref-DALOS::UEV_EnforceAccountExists account)
            ;;2]<nonces> must exist for the target DPDC asset + fungibility mode
            (ref-DPDC::UEV_NonceMapper asset-id son nonces)
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>REVOKE-BOOST-CLASS (boost-class-id:string)
        @doc "Authorizes revoking an empty BoostClass."
        @event
        (let
            (
                (bc:object{AcquisitionSchemasV5.ANK|BoostClass} (UR_BC|Data boost-class-id))
            )
            (enforce (= (at "anchors" bc) 0) (format "{} BoostClass {} not empty" [E-ANK boost-class-id]))
            (enforce (at "class-active" bc) (format "{} BoostClass {} already inactive" [E-ANK boost-class-id]))
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>ISSUE-DPTF
        (executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Validates DPTF anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
            )
            ;;LIQUIDITY-POOL TOKENS ARE ANCHORABLE AS OF 2026-10-03. The enforce that used to
            ;;stand here blocked them, in two clauses that together implemented lines 4] and 5]
            ;;of CAP_TF|Owner's doc:
            ;;
            ;;    (!= first-two "S|") (!= first-two "W|") (!= first-two "P|")
            ;;        -- a NATIVE LP token, by its prefix.
            ;;    (!= fourth BAR)
            ;;        -- a FROZEN LP, `F|W|...`, whose FOURTH character is the bar. Compact, and
            ;;           the only thing that caught a frozen LP at all.
            ;;
            ;;It is REMOVED rather than narrowed, because what it protected against is gone. It
            ;;existed because an LP token's owner is SWP|SC_NAME -- a smart account nobody can
            ;;sign for -- so issuance would have failed later and far less legibly.
            ;;`URCv_AnchorableDptfAuthority` now resolves an LP (native or frozen) to its
            ;;swpair's POOL OWNER, a real signable account, which is the authority every other
            ;;LP operation already uses: 15_SWP's XE_EnableFrozenLP says in as many words that
            ;;"SWP's executor is the POOL owner (UR_OwnerKonto swpair)", as distinct from the LP
            ;;token's owner. With that resolution in place this enforce blocks a legal operation
            ;;and nothing else.
            ;;
            ;;THE ASYMMETRY IS WHY IT CHANGED. A frozen ORDINARY token resolved to its parent
            ;;and was accepted; a frozen LP resolved to the native LP and was refused. Same
            ;;rule, opposite outcome, for no reason a user could see -- and a pool owner could
            ;;not anchor their own pool's LP token.
            ;;
            ;;SHAPE VALIDATION IS NOT LOST WITH IT: `UEV_id` two lines below is what actually
            ;;checks the id, and always was.
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPTF::UEV_id dptf-id)
            (ref-DPTF::UEV_Amount dptf-id dptf-amount)
            ;; M6 #15: TF-anchor denominated amount must sit within [1000, 1,000,000] so a tiny denominator can't
            ;; leverage the pro-rated promile into an insane boost.
            (enforce
                (and (>= dptf-amount CT_ANK_MIN_DPTF_AMOUNT) (<= dptf-amount CT_ANK_MAX_DPTF_AMOUNT))
                "TF anchor denominated amount (dptf-amount) must be within [1000, 1,000,000]"
            )
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (CAP_TF|Owner dptf-id)
            (UEV_ExecutorIzAssetAuthority executor dptf-id [true true])
            (if acnoi
                (UEV_AssetAnchorCap dptf-id)
                (UEV_IssueAnchor dptf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>ISSUE-DPSF
        (executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Validates DPSF anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPDC::UEV_id dpsf-id true)
            (ref-DPDC::UEV_Nonce dpsf-id true dpsf-nonce)
            (ref-DPDC::CAP_OwnerOrCreator dpsf-id true)
            (UEV_ExecutorIzAssetAuthority executor dpsf-id [false true])
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (if acnoi
                (UEV_AssetAnchorCap dpsf-id)
                (UEV_IssueAnchor dpsf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>ISSUE-DPNF
        (executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Validates DPNF trait-anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
                ;;
                (meta-data:object
                    (ref-DPDC::UR_N|RawMetaData
                        (ref-DPDC::UR_NativeNonceData dpnf-id false 1)
                    )
                )
                (iz-key-present:bool (contains dpnf-trait-key meta-data))
                (l:integer (length dpnf-trait-value))
            )
            (enforce
                (fold (and) true 
                    [
                        iz-key-present
                        (>= l 2)
                        (<= l 256)
                        (!= dpnf-trait-value BAR)
                    ]
                )
                "Invalid Non-Fungible Key or Invalid Promile DPNF Trait-Value"
            )
            (compose-capability (ANK|XI>ISSUE-DPNF-COMMON executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile))
        )
    )
    (defcap ANK|C>ISSUE-DPNF-SET
        (executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Validates DPNF set-anchor issuance via nonce-class model. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
                ;;
                (classes-used:integer (ref-DPDC::UR_SetClassesUsed dpnf-id false))
            )
            (enforce
                (and (>= dpnf-nonce-class 0) (<= dpnf-nonce-class classes-used))
                (format "Invalid DPNF nonce-class {} for collection {}." [dpnf-nonce-class dpnf-id])
            )
            (compose-capability (ANK|XI>ISSUE-DPNF-COMMON executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile))
        )
    )
    (defcap ANK|XI>ISSUE-DPNF-COMMON
        (executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal)
        @doc "Common DPNF issuance checks shared by trait and set modes."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            ;;AUTHORISATION FIRST (2026-09-14 ruling), and it is NEW here. Until 2026-09-20 the two
            ;;DPNF anchor paths reached NO ownership enforce at all, while their DPTF sibling ran
            ;;CAP_TF|Owner and their DPSF sibling ran CAP_OwnerOrCreator. The asymmetry mattered:
            ;;UEV_AssetAnchorCap caps an asset at 49 anchors, so a stranger could mint 49 anchors
            ;;against a collection he did not own, exhaust the cap permanently, and own every
            ;;resulting boost class. Bounded by STOA cost, but cheap next to blocking a collection
            ;;forever. Closed here because AQP is pre-mainnet and the gap is free to close now.
            (ref-DPDC::CAP_OwnerOrCreator dpnf-id false)
            (UEV_ExecutorIzAssetAuthority executor dpnf-id [false false])
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPDC::UEV_id dpnf-id false)
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (if acnoi
                (UEV_AssetAnchorCap dpnf-id)
                (UEV_IssueAnchor dpnf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>REVOKE (executor:string anchor-id:string)
        @doc "Authorizes anchor revocation for <anchor-id>; requires the anchor to be ALIVE + owned. H4 (#9) \
            \ temp-patch: blocked while the anchor's BoostClass is linked by any score — vacate/unlink first (the \
            \ re-score-sweep unwind is not built yet; see Audit/ANCHOR-STALENESS-INVENTORY.md)."
        @event
        ;; L4 #17: reject a dead/never-existed anchor up front (revoke sets State→false), so a double-revoke aborts
        ;; cleanly here instead of deep in UC_RemoveItemAt — and the H4 lock below never reads a revoked anchor.
        (UEV_LiveAnchor anchor-id)
        (CAP_Owner anchor-id)
        ;;ATTRIBUTION (canon 2.2, 2026-09-22). CAP_Owner above enforces on the ANCHORED ASSET's
        ;;authority -- a DERIVED account naming no actor, HANDOFF 4g. This binds the declared
        ;;executor to that same authority.
        ;;
        ;;DELIBERATELY BELOW UEV_LiveAnchor, and this is not stylistic. The binder resolves the
        ;;anchored asset out of the anchor row, so on a NON-EXISTENT anchor it would raise a raw
        ;;table error -- replacing the liveness message that [6.2.10] <<TX-AQP-NEG-OWNER2>> exists
        ;;to pin, and which was itself only made reachable by turning UR_ANK|State into a
        ;;defaulted read. Reading an owner before proving the entity exists is the standing hazard
        ;;in HANDOFF's rules list; here it has a named test that would have caught it.
        (UEV_ExecutorIzAnchorAuthority executor anchor-id)
        ;; #9 lock: cannot revoke an anchor whose BoostClass is employed by ≥1 score (stale-boost prevention).
        (enforce
            (= (UR_BC|ScoreLinkCount (UR_ANK|BoostClassId anchor-id)) 0)
            "Anchor's BoostClass is in use by a score — revoke locked until scores are vacated/unlinked"
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|XE>SWEEP-REVOKE (anchor-id:string)
        @doc "Forward (re-score sweep terminal): authorize SWEPT revocation of an EMPLOYED anchor — liveness + \
            \ owner enforced, but NOT the #9 score-link lock (the sweep has already refreshed every affected \
            \ holder, so no staleness remains). Distinct from ANK|C>REVOKE (gated on set==0 for UNemployed anchors)."
        (UEV_LiveAnchor anchor-id)
        (CAP_Owner anchor-id)
        (compose-capability (SECURE))
    )
    ;;UNUSED and REDUNDANT -- harmless. The live revoke path (XI at ~2280) acquires
    ;;ANK|C>REVOKE-BOOST-CLASS directly, and that cap is itself @event and carries both real
    ;;guards (empty class, still active). This wrapper only re-emits around it, so nothing is
    ;;lost by it never being reached: no guard is skipped and the inner event still fires.
    ;;Contrast ATS|S>CONTROL-DIRECT-RECOVERY, whose orphaning DOES skip a guard. Flagged 2026-09-10.
    (defcap ANK|C>REVOKE-BOOST-CLASS-ENTRY (boost-class-id:string)
        @doc "Authorizes revoking a BoostClass entity."
        @event
        (compose-capability (ANK|C>REVOKE-BOOST-CLASS boost-class-id))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Namespace ()
        @doc "Namespace prefix for AQP governance keyset name."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    ;; [UDC] construct
    (defun UDC_ANK|Schema:object{AcquisitionSchemasV5.ANK|Schema}
        (a:string b:[bool] c:string d:integer e:bool f:decimal g:decimal h:integer i:string j:string k:integer l:string)
        @doc "Constructs anchor definition row for ANK|T|Anchor."
        {"ank-asset"            : a
        ,"ank-fungibility"      : b
        ,"boost-class-id"       : c
        ,"ank-precision"        : d
        ,"ank-active"           : e
        ,"ank-promile"          : f
        ,"dptf-amount"          : g
        ,"dpsf-nonce"           : h
        ,"dpnf-trait-key"       : i
        ,"dpnf-trait-value"     : j
        ,"dpnf-nonce-class"     : k
        ,"anchor-id"            : l}
    )
    (defun UDC_BoostClass:object{AcquisitionSchemasV5.ANK|BoostClass}
        (a:string b:string c:string d:string e:string f:string g:string h:integer i:bool j:string k:string)
        @doc "Constructs BoostClass object. `k` is the class-owner (creator); only it may attach anchors."
        {"anchor-primary"       : a
        ,"anchor-secondary"     : b
        ,"anchor-tertiary"      : c
        ,"anchor-quaternary"    : d
        ,"anchor-quinary"       : e
        ,"anchor-senary"        : f
        ,"anchor-septenary"     : g
        ,"anchors"              : h
        ,"class-active"         : i
        ,"boost-class-id"       : j
        ,"class-owner"          : k}
    )
    (defun UDC_EmptyInternalGroup:object{AcquisitionSchemasV5.ANK|InternalGroup} ()
        @doc "Constructs empty InternalGroup (all BAR, anchors=0)."
        {"anchor-primary"       : BAR
        ,"anchor-secondary"     : BAR
        ,"anchor-tertiary"      : BAR
        ,"anchor-quaternary"    : BAR
        ,"anchor-quinary"       : BAR
        ,"anchor-senary"        : BAR
        ,"anchor-septenary"     : BAR
        ,"anchors"              : 0}
    )
    (defun UDC_IG|WithAddedAnchor:object{AcquisitionSchemasV5.ANK|InternalGroup}
        (ig:object{AcquisitionSchemasV5.ANK|InternalGroup} new-anchor-id:string)
        @doc "Adds anchor-id to first free slot in an InternalGroup."
        (let
            (
                (a1:string (at "anchor-primary" ig))
                (a2:string (at "anchor-secondary" ig))
                (a3:string (at "anchor-tertiary" ig))
                (a4:string (at "anchor-quaternary" ig))
                (a5:string (at "anchor-quinary" ig))
                (a6:string (at "anchor-senary" ig))
                (a7:string (at "anchor-septenary" ig))
                (n:integer (at "anchors" ig))
            )
            (cond
                ((= a1 BAR) {"anchor-primary": new-anchor-id, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a2 BAR) {"anchor-primary": a1, "anchor-secondary": new-anchor-id, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a3 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": new-anchor-id, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a4 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": new-anchor-id, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a5 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": new-anchor-id, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a6 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": new-anchor-id, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a7 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": new-anchor-id, "anchors": (+ n 1)})
                ig
            )
        )
    )
    (defun UDC_IG|WithRemovedAnchor:object{AcquisitionSchemasV5.ANK|InternalGroup}
        (ig:object{AcquisitionSchemasV5.ANK|InternalGroup} revoked-anchor-id:string)
        @doc "Removes anchor-id from group, compacts slots."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (lst:[string]
                    [(at "anchor-primary" ig)
                     (at "anchor-secondary" ig)
                     (at "anchor-tertiary" ig)
                     (at "anchor-quaternary" ig)
                     (at "anchor-quinary" ig)
                     (at "anchor-senary" ig)
                     (at "anchor-septenary" ig)]
                )
                (position-to-remove:integer
                    (cond
                        ((= revoked-anchor-id (at 0 lst)) 0)
                        ((= revoked-anchor-id (at 1 lst)) 1)
                        ((= revoked-anchor-id (at 2 lst)) 2)
                        ((= revoked-anchor-id (at 3 lst)) 3)
                        ((= revoked-anchor-id (at 4 lst)) 4)
                        ((= revoked-anchor-id (at 5 lst)) 5)
                        ((= revoked-anchor-id (at 6 lst)) 6)
                        -1
                    )
                )
                (lst-v1 (ref-U|LST::UC_RemoveItemAt lst position-to-remove))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
                (n:integer (at "anchors" ig))
            )
            {"anchor-primary"   : (at 0 lst-v2)
            ,"anchor-secondary" : (at 1 lst-v2)
            ,"anchor-tertiary"  : (at 2 lst-v2)
            ,"anchor-quaternary": (at 3 lst-v2)
            ,"anchor-quinary"   : (at 4 lst-v2)
            ,"anchor-senary"    : (at 5 lst-v2)
            ,"anchor-septenary" : (at 6 lst-v2)
            ,"anchors"          : (- n 1)}
        )
    )
    (defun UDC_BC|WithAddedAnchor:object{AcquisitionSchemasV5.ANK|BoostClass}
        (bc:object{AcquisitionSchemasV5.ANK|BoostClass} new-anchor-id:string)
        @doc "Adds anchor-id to first free slot in a BoostClass."
        (let
            (
                (a1:string (at "anchor-primary" bc))
                (a2:string (at "anchor-secondary" bc))
                (a3:string (at "anchor-tertiary" bc))
                (a4:string (at "anchor-quaternary" bc))
                (a5:string (at "anchor-quinary" bc))
                (a6:string (at "anchor-senary" bc))
                (a7:string (at "anchor-septenary" bc))
                (n:integer (at "anchors" bc))
                (ca:bool (at "class-active" bc))
                (co:string (at "class-owner" bc))
                (co:string (at "class-owner" bc))
                (bcid:string (at "boost-class-id" bc))
            )
            (cond
                ((= a1 BAR) (UDC_BoostClass new-anchor-id a2 a3 a4 a5 a6 a7 (+ n 1) ca bcid co))
                ((= a2 BAR) (UDC_BoostClass a1 new-anchor-id a3 a4 a5 a6 a7 (+ n 1) ca bcid co))
                ((= a3 BAR) (UDC_BoostClass a1 a2 new-anchor-id a4 a5 a6 a7 (+ n 1) ca bcid co))
                ((= a4 BAR) (UDC_BoostClass a1 a2 a3 new-anchor-id a5 a6 a7 (+ n 1) ca bcid co))
                ((= a5 BAR) (UDC_BoostClass a1 a2 a3 a4 new-anchor-id a6 a7 (+ n 1) ca bcid co))
                ((= a6 BAR) (UDC_BoostClass a1 a2 a3 a4 a5 new-anchor-id a7 (+ n 1) ca bcid co))
                ((= a7 BAR) (UDC_BoostClass a1 a2 a3 a4 a5 a6 new-anchor-id (+ n 1) ca bcid co))
                bc
            )
        )
    )
    (defun UDC_BC|WithRemovedAnchor:object{AcquisitionSchemasV5.ANK|BoostClass}
        (bc:object{AcquisitionSchemasV5.ANK|BoostClass} revoked-anchor-id:string)
        @doc "Removes anchor-id from BoostClass, compacts slots."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (lst:[string]
                    [(at "anchor-primary" bc)
                     (at "anchor-secondary" bc)
                     (at "anchor-tertiary" bc)
                     (at "anchor-quaternary" bc)
                     (at "anchor-quinary" bc)
                     (at "anchor-senary" bc)
                     (at "anchor-septenary" bc)]
                )
                (position-to-remove:integer
                    (cond
                        ((= revoked-anchor-id (at 0 lst)) 0)
                        ((= revoked-anchor-id (at 1 lst)) 1)
                        ((= revoked-anchor-id (at 2 lst)) 2)
                        ((= revoked-anchor-id (at 3 lst)) 3)
                        ((= revoked-anchor-id (at 4 lst)) 4)
                        ((= revoked-anchor-id (at 5 lst)) 5)
                        ((= revoked-anchor-id (at 6 lst)) 6)
                        -1
                    )
                )
                (lst-v1 (ref-U|LST::UC_RemoveItemAt lst position-to-remove))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
                (n:integer (at "anchors" bc))
                (ca:bool (at "class-active" bc))
                (co:string (at "class-owner" bc))
                (bcid:string (at "boost-class-id" bc))
            )
            (UDC_BoostClass (at 0 lst-v2) (at 1 lst-v2) (at 2 lst-v2) (at 3 lst-v2)
                (at 4 lst-v2) (at 5 lst-v2) (at 6 lst-v2) (- n 1) ca bcid co
            )
        )
    )
    (defun UDC_AA|PlaceAnchor:object{AcquisitionSchemasV5.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV5.ANK|AssetAnchors} new-anchor-id:string)
        @doc "Places anchor in first group with a free slot; creates new group if needed. \
            \ Pure constructor — no enforce. Caller (issue caps via UEV_*) must ensure \
            \ anchors-active < 49 (implies a free group slot exists under 7×7)."
        (let
            (
                (ga:integer (at "groups-active" aa))
                (ta:integer (at "anchors-active" aa))
                (aid:string (at "asset-id" aa))
            )
            (let
                (
                    (result:list
                        (fold
                            (lambda (acc:list gi:integer)
                                (if (= (at 1 acc) 1)
                                    acc
                                    (let
                                        (
                                            (grp:object{AcquisitionSchemasV5.ANK|InternalGroup} (URC_AA|GroupAtSlot aa gi))
                                            (gn:integer (at "anchors" grp))
                                        )
                                        (if (< gn 7)
                                            [(UDC_IG|WithAddedAnchor grp new-anchor-id) 1 gi]
                                            acc
                                        )
                                    )
                                )
                            )
                            [(UDC_EmptyInternalGroup) 0 -1]
                            (enumerate 0 6)
                        )
                    )
                    (placed:integer (at 1 result))
                )
                (if (= placed 1)
                    (let
                        (
                            (updated-grp:object{AcquisitionSchemasV5.ANK|InternalGroup} (at 0 result))
                            (slot:integer (at 2 result))
                            (prev-grp:object{AcquisitionSchemasV5.ANK|InternalGroup} (URC_AA|GroupAtSlot aa slot))
                            (new-ga:integer
                                (if (and (= (at "anchors" prev-grp) 0) (> (at "anchors" updated-grp) 0))
                                    (if (> ga (+ slot 1)) ga (+ slot 1))
                                    ga
                                )
                            )
                        )
                        (URC_AA|SetGroupAtSlot aa updated-grp slot (+ ta 1) new-ga false)
                    )
                    (let
                        (
                            (new-grp:object{AcquisitionSchemasV5.ANK|InternalGroup} (UDC_IG|WithAddedAnchor (UDC_EmptyInternalGroup) new-anchor-id))
                        )
                        (URC_AA|SetGroupAtSlot aa new-grp ga (+ ta 1) ga true)
                    )
                )
            )
        )
    )
    (defun UDC_AA|RemoveAnchor:object{AcquisitionSchemasV5.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV5.ANK|AssetAnchors} revoked-anchor-id:string)
        @doc "Removes anchor from its group in AssetAnchors."
        (let
            (
                (ga:integer (at "groups-active" aa))
                (ta:integer (at "anchors-active" aa))
                (aid:string (at "asset-id" aa))
            )
            (fold
                (lambda (acc:object{AcquisitionSchemasV5.ANK|AssetAnchors} gi:integer)
                    (let
                        (
                            (grp:object{AcquisitionSchemasV5.ANK|InternalGroup} (URC_AA|GroupAtSlot acc gi))
                        )
                        (if (URC_IG|ContainsAnchor grp revoked-anchor-id)
                            (let
                                (
                                    (updated-grp:object{AcquisitionSchemasV5.ANK|InternalGroup} (UDC_IG|WithRemovedAnchor grp revoked-anchor-id))
                                    (was-ga:integer (at "groups-active" acc))
                                    (was-ta:integer (at "anchors-active" acc))
                                    (grp-now-empty:bool (= (at "anchors" updated-grp) 0))
                                )
                                (URC_AA|SetGroupAtSlot acc updated-grp gi (- was-ta 1) was-ga grp-now-empty)
                            )
                            acc
                        )
                    )
                )
                aa
                (enumerate 0 6)
            )
        )
    )
    (defun UDC_AccountAnchor:object{AcquisitionSchemasV5.ANK|UserSchema}
        (a:decimal b:string c:string)
        @doc "Constructs user-anchor contribution object."
        {"promile"              : a
        ,"ouronet-account"      : b
        ,"anchor-id"            : c}
    )
    (defun UDC_UserBoost:object{AcquisitionSchemasV5.ANK|UserBoostSchema}
        (aggregate-promile:decimal ouronet-account:string boost-class-id:string)
        @doc "Constructs user-boost aggregate row for ANK|T|UserBoost."
        {"aggregate-promile"   : aggregate-promile
        ,"ouronet-account"     : ouronet-account
        ,"boost-class-id"      : boost-class-id}
    )
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    (defun UCk_Anchors:string
        (account:string anchor-id:string)
        @doc "Composite key for ANK|T|Anchors (account BAR anchor-id)."
        (concat [account BAR anchor-id])
    )
    (defun UCk_UserBoost:string
        (account:string boost-class-id:string)
        @doc "Composite key for ANK|T|UserBoost (account BAR boost-class-id)."
        (concat [account BAR boost-class-id])
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    ;; Reads follow schema order: (1) ANK|Schema (2) ANK|BoostClass (3) ANK|AssetAnchors (4) ANK|UserSchema (5) ANK|UserBoostSchema
    ;; Policy P|T, P|MT — not ANK rows; use P|Info, P|UR, P|UR_IMP above.
    ;;
    ;; Core row: UR_ANK|Data
    (defun UR_ANK|Data:object{AcquisitionSchemasV5.ANK|Schema} (anchor-id:string)
        @doc "Reads full anchor definition row from ANK|T|Anchor."
        (read ANK|T|Anchor anchor-id)
    )
    (defun UR_ANK|AnchoredAsset:string (anchor-id:string)
        @doc "Reads anchored asset id from anchor row."
        (at "ank-asset" (read ANK|T|Anchor anchor-id ["ank-asset"]))
    )
    (defun UR_ANK|Fungibility:[bool] (anchor-id:string)
        @doc "Reads anchor fungibility marker."
        (at "ank-fungibility" (read ANK|T|Anchor anchor-id ["ank-fungibility"]))
    )
    (defun UR_ANK|BoostClassId:string (anchor-id:string)
        @doc "Reads the BoostClass-ID this anchor belongs to."
        (at "boost-class-id" (read ANK|T|Anchor anchor-id ["boost-class-id"]))
    )
    (defun UR_ANK|Precision:decimal (anchor-id:string)
        @doc "Reads anchor precision as decimal."
        (dec (at "ank-precision" (read ANK|T|Anchor anchor-id ["ank-precision"])))
    )
    (defun UR_ANK|State:bool (anchor-id:string)
        @doc "Reads anchor active flag. DEFAULTED: an anchor that does not exist is not active, \
            \ which is what every caller means by this question."
        ;;This was a bare `read`, so for an anchor that does not exist it raised
        ;;`No value found in table ouronet-ns.AQP-ANK_ANK|T|Anchor for key: <id>` -- and
        ;;`UEV_LiveAnchor`, the validator built on it, could therefore never deliver its own
        ;;message ("Anchor <id> must be alive for operation") for the one input that most needs it.
        ;;Both callers are correct under the default: UEV_LiveAnchor wants false, and the anchor
        ;;filter at ~1193 already screens BAR and wants false for anything not alive.
        ;;Same shape as DPTF's UEV_id, which defaults <supply> to -1.0 for exactly this reason.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-007a/b>>.
        (with-default-read ANK|T|Anchor anchor-id
            { "ank-active" : false }
            { "ank-active" := a }
            a
        )
    )
    (defun UR_ANK|Promile:decimal (anchor-id:string)
        @doc "Reads anchor promile value."
        (at "ank-promile" (read ANK|T|Anchor anchor-id ["ank-promile"]))
    )
    ;;
    (defun UR_ANK|TFAmount:decimal (anchor-id:string)
        @doc "Reads DPTF amount for TF anchor."
        (at "dptf-amount" (read ANK|T|Anchor anchor-id ["dptf-amount"]))
    )
    (defun UR_ANK|SFNonce:integer (anchor-id:string)
        @doc "Reads DPSF nonce for SF anchor."
        (at "dpsf-nonce" (read ANK|T|Anchor anchor-id ["dpsf-nonce"]))
    )
    (defun UR_ANK|NFTraitKey:string (anchor-id:string)
        @doc "Reads DPNF trait key for NF anchor."
        (at "dpnf-trait-key" (read ANK|T|Anchor anchor-id ["dpnf-trait-key"]))
    )
    (defun UR_ANK|NFTraitValue:string (anchor-id:string)
        @doc "Reads DPNF trait value for NF anchor."
        (at "dpnf-trait-value" (read ANK|T|Anchor anchor-id ["dpnf-trait-value"]))
    )
    (defun UR_ANK|NFNonceClass:integer (anchor-id:string)
        @doc "Reads DPNF nonce-class for NF set-anchor mode."
        (at "dpnf-nonce-class" (read ANK|T|Anchor anchor-id ["dpnf-nonce-class"]))
    )
    (defun UR_ANK|ID:string (anchor-id:string)
        @doc "Reads anchor-id field from anchor row."
        (at "anchor-id" (UR_ANK|Data anchor-id))
    )
    ;;
    (defun UR_BC|Data:object{AcquisitionSchemasV5.ANK|BoostClass} (boost-class-id:string)
        @doc "Reads full BoostClass row."
        (read ANK|T|BoostClass boost-class-id)
    )
    (defun UR_BC|Anchors:integer (boost-class-id:string)
        @doc "Reads anchor count from BoostClass."
        (at "anchors" (read ANK|T|BoostClass boost-class-id ["anchors"]))
    )
    (defun UR_BC|Active:bool (boost-class-id:string)
        @doc "Reads active flag from BoostClass."
        (at "class-active" (read ANK|T|BoostClass boost-class-id ["class-active"]))
    )
    (defun UR_BC|ScoreLinks:[string] (boost-class-id:string)
        @doc "The SET of score-ids employing this BoostClass — the H4 reverse index (sweep phase 1). Empty when \
            \ absent. Enumerated by the re-score sweep to find every score/position an anchor change touches."
        (with-default-read ANK|T|BoostClassScoreLinks boost-class-id
            {"score-links": []}
            {"score-links" := sl}
            sl
        )
    )
    (defun UR_BC|ScoreLinkCount:integer (boost-class-id:string)
        @doc "Count of SCORE links referencing this BoostClass (H4 #9 revoke lock) = length of the reverse-index \
            \ set; 0 when absent. Single source of truth is UR_BC|ScoreLinks."
        (length (UR_BC|ScoreLinks boost-class-id))
    )
    (defun UR_BC|ID:string (boost-class-id:string)
        @doc "Reads boost-class-id from BoostClass row."
        (at "boost-class-id" (read ANK|T|BoostClass boost-class-id ["boost-class-id"]))
    )
    ;;
    (defun UR_AA|Data:object{AcquisitionSchemasV5.ANK|AssetAnchors} (asset-id:string)
        @doc "Reads full per-asset bookkeeping row (with-default-read when absent)."
        (let
            (
                (eg:object{AcquisitionSchemasV5.ANK|InternalGroup} (UDC_EmptyInternalGroup))
            )
            (with-default-read ANK|T|AssetAnchors asset-id
                {"group-primary"     : eg
                ,"group-secondary"   : eg
                ,"group-tertiary"    : eg
                ,"group-quaternary"  : eg
                ,"group-quinary"     : eg
                ,"group-senary"      : eg
                ,"group-septenary"   : eg
                ,"groups-active"     : 0
                ,"anchors-active"    : 0
                ,"asset-id"          : asset-id}
                {"group-primary"     := g1
                ,"group-secondary"   := g2
                ,"group-tertiary"    := g3
                ,"group-quaternary"  := g4
                ,"group-quinary"     := g5
                ,"group-senary"      := g6
                ,"group-septenary"   := g7
                ,"groups-active"     := ga
                ,"anchors-active"    := aa
                ,"asset-id"          := aid}
                {"group-primary"     : g1
                ,"group-secondary"   : g2
                ,"group-tertiary"    : g3
                ,"group-quaternary"  : g4
                ,"group-quinary"     : g5
                ,"group-senary"      : g6
                ,"group-septenary"   : g7
                ,"groups-active"     : ga
                ,"anchors-active"    : aa
                ,"asset-id"          : aid}
            )
        )
    )
    (defun UR_AA|GroupsActive:integer (asset-id:string)
        @doc "Reads groups-active from asset anchors row."
        (at "groups-active" (UR_AA|Data asset-id))
    )
    (defun UR_AA|AnchorsActive:integer (asset-id:string)
        @doc "Reads anchors-active from asset anchors row."
        (at "anchors-active" (UR_AA|Data asset-id))
    )
    (defun UR_ANK|AnchorsForAsset:[string] (asset-id:string)
        @doc "Live anchor-ids for an asset. Reads the single AssetAnchors row, \
            \ iterates all groups and slots, collects non-BAR active anchors."
        (let
            (
                (aa:object{AcquisitionSchemasV5.ANK|AssetAnchors} (UR_AA|Data asset-id))
                (ga:integer (at "groups-active" aa))
            )
            (if (<= ga 0)
                []
                (fold
                    (lambda (acc:[string] gi:integer)
                        (let
                            (
                                (grp:object{AcquisitionSchemasV5.ANK|InternalGroup} (URC_AA|GroupAtSlot aa gi))
                                (q:integer (at "anchors" grp))
                            )
                            (if (<= q 0)
                                acc
                                (fold
                                    (lambda (acc2:[string] ai:integer)
                                        (let
                                            (
                                                (aid:string (URC_IG|AnchorIdAtSlot grp ai))
                                            )
                                            (if (and (!= aid BAR) (UR_ANK|State aid))
                                                (+ acc2 [aid])
                                                acc2
                                            )
                                        )
                                    )
                                    acc
                                    (enumerate 0 (- q 1))
                                )
                            )
                        )
                    )
                    []
                    (enumerate 0 6)
                )
            )
        )
    )
    ;;
    ;; Core row: UR_ANK-U|Data
    (defun UR_ANK-U|Data:object{AcquisitionSchemasV5.ANK|UserSchema} (account:string anchor-id:string)
        @doc "Core read: user cumulative promile row for account x anchor."
        (with-default-read ANK|T|Anchors (UCk_Anchors account anchor-id)
            (UDC_AccountAnchor 0.0 account anchor-id)
            {"promile"                  := p
            ,"ouronet-account"          := oa
            ,"anchor-id"                := aid}
            (UDC_AccountAnchor p oa aid)
        )
    )
    (defun UR_ANK-U|Promile:decimal (account:string anchor-id:string)
        @doc "Reads promile from user-anchor row."
        (at "promile" (UR_ANK-U|Data account anchor-id))
    )
    (defun UR_ANK-U|Account:string (account:string anchor-id:string)
        @doc "Reads account id from user-anchor row."
        (at "ouronet-account" (UR_ANK-U|Data account anchor-id))
    )
    (defun UR_ANK-U|ID:string (account:string anchor-id:string)
        @doc "Reads anchor id from user-anchor row."
        (at "anchor-id" (UR_ANK-U|Data account anchor-id))
    )
    ;;
    (defun UR_UB|Data:object{AcquisitionSchemasV5.ANK|UserBoostSchema} (account:string boost-class-id:string)
        @doc "Reads user-boost aggregate row (with-default-read when absent)."
        (with-default-read ANK|T|UserBoost (UCk_UserBoost account boost-class-id)
            (UDC_UserBoost 0.0 account boost-class-id)
            {"aggregate-promile"   := ap
            ,"ouronet-account"     := oa
            ,"boost-class-id"      := bcid}
            (UDC_UserBoost ap oa bcid)
        )
    )
    (defun UR_UB|AggregatePromile:decimal (account:string boost-class-id:string)
        @doc "Reads aggregate promile for user in a BoostClass."
        (at "aggregate-promile" (UR_UB|Data account boost-class-id))
    )
    ;;
    (defun URC_TrueFungibleAnchorPromile:decimal 
        (anchor-id:string total-dptf-amount:decimal)
        @doc "Promile from staked DPTF vs anchor reference amount, times anchor promile. \
            \ Reads anchor row via UR_*; if reference amount is non-positive, yields 0.0 (no enforce — use UEV on issue paths)."
        (let
            (
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dptf-amount:decimal (UR_ANK|TFAmount anchor-id))
            )
            (if (<= dptf-amount 0.0)
                0.0
                (floor (* (/ total-dptf-amount dptf-amount) ank-promile) ank-precision)
            )
        )
    )
    (defun URC_SemiFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Computes SF anchor promile from nonce equality model."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dpfs-nonce:integer (UR_ANK|SFNonce anchor-id))
                (current-promile:decimal (UR_ANK-U|Promile account anchor-id))
                ;;
                (anchor-nonce-position:[integer] (ref-U|LST::UC_Search nonces dpfs-nonce))
                (l:integer (length anchor-nonce-position))
                (conform-nonces:integer
                    (if (= l 0)
                        0
                        (at (at 0 anchor-nonce-position) nonce-amounts)
                    )
                )
                (computed-promile-to-consider:decimal (* (dec conform-nonces) ank-promile))
            )
            (if direction
                (+ current-promile computed-promile-to-consider)
                (- current-promile computed-promile-to-consider)
            )
        )
    )
    (defun URC_NonFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] direction:bool)
        @doc "Computes NF anchor promile using trait mode or nonce-class mode."
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dpnf-trait-key:string (UR_ANK|NFTraitKey anchor-id))
                (dpnf-trait-value:string (UR_ANK|NFTraitValue anchor-id))
                (current-promile:decimal (UR_ANK-U|Promile account anchor-id))
                ;;
                (trait-mode:bool (URC_TraitOrClass anchor-id))
                (conform-nonces:integer
                    (if trait-mode
                        (URC_ConformNonces ank-asset nonces dpnf-trait-key dpnf-trait-value)
                        (URC_ConformNoncesByClass ank-asset nonces (UR_ANK|NFNonceClass anchor-id))
                    )
                )
                (computed-promile-to-consider:decimal (* (dec conform-nonces) ank-promile))
            )
            (if direction
                (+ current-promile computed-promile-to-consider)
                (- current-promile computed-promile-to-consider)
            )
        )
    )
    (defun URC_SemiFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Absolute SF promile from full cross-pool nonce inventory (C_SyncCollectableAnchors resync)."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (dpfs-nonce:integer (UR_ANK|SFNonce anchor-id))
                (anchor-nonce-position:[integer] (ref-U|LST::UC_Search nonces dpfs-nonce))
                (l:integer (length anchor-nonce-position))
                (conform-amount:integer
                    (if (= l 0)
                        0
                        (at (at 0 anchor-nonce-position) nonce-amounts)
                    )
                )
            )
            (floor (* (dec conform-amount) ank-promile) ank-precision)
        )
    )
    (defun URC_NonFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer])
        @doc "Absolute NF promile from full cross-pool nonce inventory (C_SyncCollectableAnchors resync)."
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (dpnf-trait-key:string (UR_ANK|NFTraitKey anchor-id))
                (dpnf-trait-value:string (UR_ANK|NFTraitValue anchor-id))
                (trait-mode:bool (URC_TraitOrClass anchor-id))
                (conform-nonces:integer
                    (if trait-mode
                        (URC_ConformNonces ank-asset nonces dpnf-trait-key dpnf-trait-value)
                        (URC_ConformNoncesByClass ank-asset nonces (UR_ANK|NFNonceClass anchor-id))
                    )
                )
            )
            (floor (* (dec conform-nonces) ank-promile) ank-precision)
        )
    )
    (defun URC_TraitOrClass:bool (anchor-id:string)
        @doc "Returns true for trait-mode; false for nonce-class mode."
        (fold (and) true
            [
                (!= (UR_ANK|NFTraitKey anchor-id) BAR)
                (!= (UR_ANK|NFTraitValue anchor-id) BAR)
                (= (UR_ANK|NFNonceClass anchor-id) -1)
            ]
        )
    )
    (defun URC_ConformNonces:integer (dpnf-id:string nonces:[integer] trait-key:string trait-value:string)
        @doc "Outputs how many nonces from <nonces> have the proper MetaData Trait"
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (fold
                (lambda
                    (acc:integer idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (nonce-meta-data:object 
                                (ref-DPDC::UR_N|RawMetaData 
                                    (ref-DPDC::UR_NativeNonceData dpnf-id false nonce)
                                )
                            )
                            (has-trait-key:bool (contains trait-key nonce-meta-data))
                            (output:integer
                                (if (or (< nonce 0) (not has-trait-key))
                                    0
                                    (if (= trait-value (at trait-key nonce-meta-data))
                                        1
                                        0
                                    )
                                )
                            )
                        )
                        (+ acc output)
                    )
                )
                0
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    (defun URC_ConformNoncesByClass:integer (dpnf-id:string nonces:[integer] nonce-class:integer)
        @doc "Outputs how many nonces from <nonces> conform to nonce-class mode."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (fold
                (lambda
                    (acc:integer idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (output:integer
                                (if (< nonce 0)
                                    0
                                    (if (= nonce-class 0)
                                        1
                                        (if (= (ref-DPDC::UR_NonceClass dpnf-id false nonce) nonce-class)
                                            1
                                            0
                                        )
                                    )
                                )
                            )
                        )
                        (+ acc output)
                    )
                )
                0
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    (defun URC_TrueFungibleStakeAnchorRefreshIgnis:decimal (n-live:integer)
        @doc "Internal: ignis|small per live TF anchor refreshed (n_live = length UR_ANK|AnchorsForAsset). Zero when n_live ≤ 0."
        (if (<= n-live 0)
            0.0
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    ;;
                    (unit:decimal (ref-IGNIS::UC_IgnisLeg "tier-small"))
                )
                (* (dec n-live) unit)
            )
        )
    )
    ;; --- AssetAnchors / BoostClass slot helpers (in-memory; UDC_AA|* and XI_2|Recompute*) ---
    (defun URC_BC|AnchorIdAtSlot:string (bc:object{AcquisitionSchemasV5.ANK|BoostClass} idx:integer)
        @doc "URC: reads anchor-id at slot idx (0..6) from a BoostClass object (in-memory)."
        (cond
            ((= idx 0) (at "anchor-primary" bc))
            ((= idx 1) (at "anchor-secondary" bc))
            ((= idx 2) (at "anchor-tertiary" bc))
            ((= idx 3) (at "anchor-quaternary" bc))
            ((= idx 4) (at "anchor-quinary" bc))
            ((= idx 5) (at "anchor-senary" bc))
            ((= idx 6) (at "anchor-septenary" bc))
            BAR
        )
    )
    (defun URC_AA|GroupAtSlot:object{AcquisitionSchemasV5.ANK|InternalGroup} (aa:object{AcquisitionSchemasV5.ANK|AssetAnchors} idx:integer)
        @doc "URC: reads internal group at slot idx (0..6) from an AssetAnchors object (in-memory)."
        (cond
            ((= idx 0) (at "group-primary" aa))
            ((= idx 1) (at "group-secondary" aa))
            ((= idx 2) (at "group-tertiary" aa))
            ((= idx 3) (at "group-quaternary" aa))
            ((= idx 4) (at "group-quinary" aa))
            ((= idx 5) (at "group-senary" aa))
            ((= idx 6) (at "group-septenary" aa))
            (UDC_EmptyInternalGroup)
        )
    )
    (defun URC_IG|AnchorIdAtSlot:string (ig:object{AcquisitionSchemasV5.ANK|InternalGroup} idx:integer)
        @doc "URC: reads anchor-id at slot idx (0..6) from an InternalGroup object (in-memory)."
        (cond
            ((= idx 0) (at "anchor-primary" ig))
            ((= idx 1) (at "anchor-secondary" ig))
            ((= idx 2) (at "anchor-tertiary" ig))
            ((= idx 3) (at "anchor-quaternary" ig))
            ((= idx 4) (at "anchor-quinary" ig))
            ((= idx 5) (at "anchor-senary" ig))
            ((= idx 6) (at "anchor-septenary" ig))
            BAR
        )
    )
    (defun URC_IG|ContainsAnchor:bool (ig:object{AcquisitionSchemasV5.ANK|InternalGroup} anchor-id:string)
        @doc "URC: true when InternalGroup contains anchor-id (in-memory scan of seven slots)."
        (or (= anchor-id (at "anchor-primary" ig))
        (or (= anchor-id (at "anchor-secondary" ig))
        (or (= anchor-id (at "anchor-tertiary" ig))
        (or (= anchor-id (at "anchor-quaternary" ig))
        (or (= anchor-id (at "anchor-quinary" ig))
        (or (= anchor-id (at "anchor-senary" ig))
            (= anchor-id (at "anchor-septenary" ig))))))))
    )
    (defun URC_AA|SetGroupAtSlot:object{AcquisitionSchemasV5.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV5.ANK|AssetAnchors} grp:object{AcquisitionSchemasV5.ANK|InternalGroup} slot:integer ta:integer ga:integer adjust-ga:bool)
        @doc "URC: returns updated AssetAnchors with group replaced at slot (in-memory; used by UDC_AA|PlaceAnchor / RemoveAnchor)."
        (let
            (
                (g1:object{AcquisitionSchemasV5.ANK|InternalGroup} (if (= slot 0) grp (at "group-primary" aa)))
                (g2:object{AcquisitionSchemasV5.ANK|InternalGroup} (if (= slot 1) grp (at "group-secondary" aa)))
                (g3:object{AcquisitionSchemasV5.ANK|InternalGroup} (if (= slot 2) grp (at "group-tertiary" aa)))
                (g4:object{AcquisitionSchemasV5.ANK|InternalGroup} (if (= slot 3) grp (at "group-quaternary" aa)))
                (g5:object{AcquisitionSchemasV5.ANK|InternalGroup} (if (= slot 4) grp (at "group-quinary" aa)))
                (g6:object{AcquisitionSchemasV5.ANK|InternalGroup} (if (= slot 5) grp (at "group-senary" aa)))
                (g7:object{AcquisitionSchemasV5.ANK|InternalGroup} (if (= slot 6) grp (at "group-septenary" aa)))
                (new-ta:integer ta)
                (new-ga:integer
                    (if adjust-ga
                        (if (= (at "anchors" grp) 0)
                            (- ga 1)
                            (+ ga 1)
                        )
                        ga
                    )
                )
            )
            {"group-primary"    : g1
            ,"group-secondary"  : g2
            ,"group-tertiary"   : g3
            ,"group-quaternary" : g4
            ,"group-quinary"    : g5
            ,"group-senary"     : g6
            ,"group-septenary"  : g7
            ,"groups-active"    : new-ga
            ,"anchors-active"   : new-ta
            ,"asset-id"         : (at "asset-id" aa)}
        )
    )
    ;; [URH] heavy-read
    (defun URH_ANK|AllAnchorIds:[string] ()
        @doc "Returns all row keys from ANK|T|Anchor."
        (keys ANK|T|Anchor)
    )
    (defun URH_BC|AllBoostClassIds:[string] ()
        @doc "Returns all row keys from ANK|T|BoostClass."
        (keys ANK|T|BoostClass)
    )
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    (defun URCi_IssueAnchor:object{IgnisCollectorV4.OutputCumulator} (op-key:string output:[string])
        @doc "IGNIS cost for the 4 anchor-issue ops: a FLAT 500 deterrence for every anchor type \
            \ plus that op's own component cost (owner 2026-09-06). This supersedes the \
            \ 2026-09-05 rule of half the anchored asset's issuance price, which is why the \
            \ caller now passes its TALOS OP KEY (AQP-ANK|C_Issue…Anchor) rather than a deter \
            \ tier — the tier is the same for all four. <output> carries \
            \ anchor-id[+boost-class-id]. Shared by exec and the INFO_* previews."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice op-key "anchor") AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_IssueAnchorStoa:decimal (acnoi:bool)
        @doc "STOA cost for anchor-issue: the deterrence expressed in DOLLARS, converted at the live \
            \ STOA price by UC_StoaPrice (anchor = $5 => 50 STOA). Previously read the raw \
            \ 'standard' usage price (0.01), a pre-rehaul STOA amount that was never \
            \ dollar-denominated and so ignored the peg entirely. Doubled when <acnoi>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
            )
            (* (ref-IGNIS::UC_StoaPrice "anchor") (if acnoi 2.0 1.0))
        ))
    (defun URCi_RevokeAnchor:object{IgnisCollectorV4.OutputCumulator} ()
        @doc "IGNIS cost for C_RevokeAnchor — owner-priced 100 deterrence + its component cost, via the central IG|DETER/IG|COMPONENTS \
            \ map. Shared by exec and the INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "AQP-ANK|C_RevokeAnchor" "revoke-anchor") AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        ))
    (defun URCi_RevokeBoostClass:object{IgnisCollectorV4.OutputCumulator} ()
        @doc "IGNIS cost for C_RevokeBoostClass — owner-priced 500 deterrence + its component cost, via the central IG|DETER/IG|COMPONENTS \
            \ map. Shared by exec and the INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "AQP-ANK|C_RevokeBoostClass" "revoke-boost") AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        ))
    (defun URC_AnchorableAssetOwner:string (ank-asset:string asset-fungibility:[bool])
        @doc "The OWNER konto of an anchorable asset -- the account an anchor issuance must name as \
            \ its executor. For a DPTF this resolves F|/R| to the core token first; for a collectable \
            \ it is the owner (the CREATOR is also an authority -- see UEV_ExecutorIzAssetAuthority -- \
            \ but only one of the two can be 'the' owner, and this reader answers that). \
            \ Exists because the answer is frequently NOT the obvious account: sovereign assets such \
            \ as OURO are owned by a SMART account, and the human admin merely holds its key. Before \
            \ the executor was named, that distinction was invisible at every call site."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (if (= asset-fungibility [true true])
                (URCv_AnchorableDptfAuthority ank-asset)
                (ref-DPDC::UR_OwnerKonto ank-asset (= asset-fungibility [false true]))
            )
        )
    )
    (defun URCv_CoreDptf:string (dptf-id:string)
        @doc "The CORE DPTF behind an anchored DPTF id: an `F|` frozen or `R|` reserved token \
            \ resolves to its parent, anything else is already core. Extracted from CAP_TF|Owner \
            \ (2026-09-20) so the executor check and the ownership gate read the SAME rule -- two \
            \ copies of a resolution that must agree is the failure class this refactor's own \
            \ tooling was built to prevent."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (first-two:string (take 2 dptf-id))
            )
            (cond
                ((= first-two "F|") (ref-DPTF::UR_Frozen dptf-id))
                ((= first-two "R|") (ref-DPTF::UR_Reservation dptf-id))
                dptf-id
            )
        )
    )
    (defun URCv_AnchorableDptfAuthority:string (dptf-id:string)
        @doc "The ACCOUNT that may anchor <dptf-id>. ONE rule, read by all THREE places that \
            \ need it -- URC_AnchorableAssetOwner (the reader), CAP_TF|Owner (the ownership \
            \ gate) and UEV_ExecutorIzAssetAuthority (the executor check). Three copies of a \
            \ resolution that must agree is the failure class URCv_CoreDptf was extracted to \
            \ prevent; this extends the same discipline to the liquidity-pool case. \
            \ \
            \ FOUR SHAPES: \
            \   pure DPTF        -> its own owner \
            \   F| / R| special  -> its PARENT's owner (URCv_CoreDptf follows the link) \
            \   native LP        -> the POOL OWNER of the swpair behind it \
            \   F| frozen LP     -> the same pool owner, through the same two steps \
            \ \
            \ WHY THE LP BRANCH EXISTS (2026-10-03). It did not, and the asymmetry it left was \
            \ indefensible: a frozen special resolved to its parent and was ACCEPTED, so a \
            \ frozen LP resolved to the native LP -- owned by SWP|SC_NAME, a smart account \
            \ nobody can sign for -- and was REFUSED. Same rule, opposite outcome, for no \
            \ reason a user could see. A pool owner could not anchor their own pool's LP token. \
            \ \
            \ The pool owner is the right answer and the system already said so elsewhere: \
            \ 15_SWP's XE_EnableFrozenLP records that SWP's executor is the POOL owner \
            \ (UR_OwnerKonto swpair), as distinct from the LP TOKEN's owner, which is a smart \
            \ account. Anchoring now draws the same distinction every other LP operation does."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-SWP:module{SwapperV5} SWP)
                ;;
                ;;Specials first. An `F|`/`R|` id resolves through the back-link that
                ;;XE_UpdateSpecialTrueFungible writes in BOTH directions. A frozen LP lands here
                ;;too -- C_EnableFrozenLP creates it through VST::C_CreateFrozenLink, the same
                ;;path -- so past this line a frozen LP is indistinguishable from a native one.
                (core:string (URCv_CoreDptf dptf-id))
            )
            (if (contains (take 2 core) CT_ANK_LP_PREFIXES)
                (ref-SWP::UR_OwnerKonto (ref-SWP::UR_GetLpSwpair core))
                (ref-DPTF::UR_Konto core)
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_AnkFungibility (asset-fungibility:[bool])
        @doc "Validates asset-fungibility tuple (TF/SF/NF discriminator) for anchor-class / asset-summary tables."
        (let
            (
                (l:integer (length asset-fungibility))
            )
            (enforce (and (= l 2) (!= asset-fungibility [true false])) "Invalid Fungibility")
        )
    )
    (defun UEV_Promile (anchor-precision:integer anchor-promile:decimal)
        @doc "M6 #15: anchor precision is exactly CT_ANK_PRECISION (3); anchor-promile is conform to that precision \
            \ and within [CT_ANK_MIN_PROMILE, CT_ANK_MAX_PROMILE] = [1, 10000] (caps a single anchor's boost)."
        (enforce
            (fold (and) true
                [
                    (= anchor-precision CT_ANK_PRECISION)                             ;;<anchor-precision> must be exactly 3
                    (= (floor anchor-promile CT_ANK_PRECISION) anchor-promile)        ;;<anchor-promile> conform to precision 3
                    (>= anchor-promile CT_ANK_MIN_PROMILE)                            ;;<anchor-promile> must be >= 1.0
                    (<= anchor-promile CT_ANK_MAX_PROMILE)                            ;;<anchor-promile> must be <= 10000.0
                ]
            )
            "Invalid Promile Variables: precision must be 3 and promile within [1, 10000]"
        )
    )
    (defun UEV_IssueAnchor (ank-asset:string boost-class-id:string)
        @doc "Validates BoostClass exists, is active, has a free slot, and IS OWNED BY THE CALLER; also \
            \ validates asset 49-anchor cap. Used when acnoi=false (attaching to an EXISTING class)."
        ;;OWNERSHIP ADDED 2026-09-19. Issuing an anchor is gated on CAP_OwnerOrCreator of the
        ;;ANCHORED ASSET -- but on this path that is the caller's OWN asset, which gates nothing
        ;;about the class being joined. A BoostClass had no owner at all, so anyone holding any
        ;;anchorable asset could attach it to someone else's class and hand their holders a boost
        ;;inside that vault's scoring; a 7-slot class with one anchor used offered six such grants.
        ;;Enforced via account ownership rather than a passed patron so no defcap signature moves:
        ;;CAP_EnforceAccountOwnership checks the transaction is signed by that account's guard.
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (bc:object{AcquisitionSchemasV5.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV5.ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (at "class-owner" bc))
            (enforce (at "class-active" bc) (format "{} BoostClass {} must be active" [E-ANK boost-class-id]))
            (enforce (< (at "anchors" bc) 7) (format "{} BoostClass {} full (7 anchors)" [E-ANK boost-class-id]))
            (enforce (< (at "anchors-active" aa) 49) (format "{} Asset {} at 49-anchor cap" [E-ANK ank-asset]))
        )
    )
    (defun UEV_ExecutorNotCustodial (executor:string)
        @doc "Refuses the three smart accounts that hold tokens as CUSTODY, never as management. \
            \ \
            \   SWP|SC_NAME  owns every liquidity-pool token \
            \   VST|SC_NAME  owns every frozen and reserved special token \
            \   ATS|SC_NAME  owns the hot-RBTs \
            \ \
            \ OWNER RULING, 2026-10-04: those three own tokens as a PROTOCOL FUNCTION, and that \
            \ must never become a route to managing them. Management flows through the parent -- \
            \ an LP through its POOL OWNER, a special through the owner of the token it was \
            \ derived from -- which is exactly what `URCv_AnchorableDptfAuthority` resolves. \
            \ \
            \ THIS IS DEFENCE IN DEPTH, NOT THE PRIMARY GATE, and saying so matters because an \
            \ enforce that is already unreachable invites deletion. The authority resolution \
            \ ALREADY keeps these accounts out: an LP resolves to the pool owner, so SWP is not \
            \ the authority for its own LP token and `CAP_TF|Owner` refuses it. This catches the \
            \ case where that resolution is ever wrong, loosened, or outgrown by a fourth \
            \ custodial account -- and it fails with a message that NAMES custody, where the \
            \ ownership gate would only say the executor is not the authority. \
            \ \
            \ It is on the shared authority check, so it covers ISSUE and REVOKE alike: a \
            \ custodial account must not be able to revoke an anchor either."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (enforce
                (not (contains executor
                        [(ref-DALOS::GOV|SWP|SC_NAME)
                         (ref-DALOS::GOV|VST|SC_NAME)
                         (ref-DALOS::GOV|ATS|SC_NAME)]))
                (format "{} Executor {} holds tokens as CUSTODY only; anchor management flows \
                    \ through the asset's parent -- a pool's owner, or the owner of the token a \
                    \ special was derived from" [E-ANK executor])
            )
        )
    )
    (defun UEV_ExecutorIzAssetAuthority (executor:string ank-asset:string asset-fungibility:[bool])
        @doc "Enforces that <executor> IS the anchored asset's authority, mirroring -- never replacing \
            \ -- the CAP_ gate running alongside it. The authority differs by asset kind, and that \
            \ difference is why this is one helper rather than three inline checks: a DPTF has exactly \
            \ ONE authority (URCv_AnchorableDptfAuthority: its own owner, or its parent's for an \
            \ F|/R| special, or the POOL OWNER for a liquidity-pool token), a collectable has \
            \ TWO (owner OR creator) and is therefore a DISJUNCTION, not a value. Band 1's usual \
            \ prescription -- 'enforce executor equals the derived owner' -- has no single owner to \
            \ equal in the collectable case, which is exactly why MTX-AQP's C_2|SweepRevokeAnchor \
            \ could not be done inline and waited for this."
        (UEV_ExecutorNotCustodial executor)
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
            )
            (enforce
                (if (= asset-fungibility [true true])
                    (= executor (URCv_AnchorableDptfAuthority ank-asset))
                    (let
                        (
                            (son:bool (= asset-fungibility [false true]))
                        )
                        (or (= executor (ref-DPDC::UR_OwnerKonto ank-asset son))
                            (= executor (ref-DPDC::UR_CreatorKonto ank-asset son)))
                    )
                )
                (format "Executor {} is not an authority for anchored asset {}; authority is {}"
                    [executor ank-asset
                        (if (= asset-fungibility [true true])
                            [(URCv_AnchorableDptfAuthority ank-asset)]
                            (let
                                (
                                    (son:bool (= asset-fungibility [false true]))
                                )
                                [(ref-DPDC::UR_OwnerKonto ank-asset son)
                                 (ref-DPDC::UR_CreatorKonto ank-asset son)]
                            )
                        )
                    ]
                )
            )
        )
    )
    (defun UEV_ExecutorIzClassOwner (executor:string boost-class-id:string)
        @doc "Enforces that <executor> IS the BoostClass's recorded creator, AND that the \
            \ transaction is signed for that account. \
            \ \
            \ BOTH HALVES ARE NEW HERE (2026-09-22), and the second is a fix rather than an \
            \ attribution. ANK|C>REVOKE-BOOST-CLASS validated only that the class is EMPTY and \
            \ ACTIVE -- it checked no account at all -- so any account reachable through Talos \
            \ could revoke any empty BoostClass that was not theirs. Not a funds hole: a revoked \
            \ class holds no anchors by construction. It is a griefing and denial vector, and it \
            \ costs the victim real money, because re-creating the class is the 2x-STOA inline \
            \ path in C_Issue*Anchor. \
            \ \
            \ The ATTACH path already did exactly this -- UEV_AttachToExistingClass runs \
            \ (CAP_EnforceAccountOwnership (at \"class-owner\" bc)) and the schema comment beside \
            \ <class-owner> explains why it was added on 2026-09-19. The REVOKE path was not \
            \ carried over with it. Same field, same rule, one path short. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (co:string (at "class-owner" (UR_BC|Data boost-class-id)))
            )
            (enforce (= executor co)
                (format "{} Executor {} is not BoostClass {}'s owner; owner is {}"
                    [E-ANK executor boost-class-id co]))
            (ref-DALOS::CAP_EnforceAccountOwnership co)
        )
    )
    (defun UEV_ExecutorIzAnchorAuthority (executor:string anchor-id:string)
        @doc "Anchor-level form of UEV_ExecutorIzAssetAuthority: resolves the anchored asset and its \
            \ fungibility from the anchor row, then defers. This is the shape MTX-AQP needs for \
            \ C_2|SweepRevokeAnchor, which holds an anchor-id and no asset."
        (UEV_ExecutorIzAssetAuthority executor
            (UR_ANK|AnchoredAsset anchor-id) (UR_ANK|Fungibility anchor-id))
    )
    (defun UEV_AssetAnchorCap (ank-asset:string)
        @doc "Validates asset 49-anchor cap. Used when acnoi=true (BoostClass is new)."
        (let
            (
                (aa:object{AcquisitionSchemasV5.ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (enforce (< (at "anchors-active" aa) 49) (format "{} Asset {} at 49-anchor cap" [E-ANK ank-asset]))
        )
    )
    (defun UEV_LiveAnchor (anchor-id:string)
        @doc "Validates anchor exists and is active."
        (let
            (
                (iz-anchor-active:bool (UR_ANK|State anchor-id))
            )
            (enforce iz-anchor-active (format "Anchor {} must be alive for operation" [anchor-id]))
        )
    )
    ;; WU_UserBoost|AggregatePromile — not used: mutates via WW_UserBoost (full row).
    ;; WU_UserBoost|Account — select key; WU not needed.
    ;; WU_UserBoost|BoostClassId — select key; WU not needed.
    (defun CAP_Owner (anchor-id:string)
        @doc "Enforces Anchor Ownership; This is computed as: \
        \ 1] For DPTFs Computed via <CAP_TF|Owner> \
        \ 2] For DPSFs and DPNFs can be either its Owner or Creator"
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
                ;;
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-fungibility:[bool] (UR_ANK|Fungibility anchor-id))
            )
            (if (= ank-fungibility [true true])
                (CAP_TF|Owner ank-asset)
                (if (= ank-fungibility [false true])
                    (ref-DPDC::CAP_OwnerOrCreator ank-asset true)
                    (ref-DPDC::CAP_OwnerOrCreator ank-asset false)
                )
            )
        )
    )
    (defun CAP_TF|Owner (dptf-id:string)
        @doc "Enforces dptf-id Ownership, as underlying Dptf-Based Anchor Ownership. \
        \ FIVE DPTF variants can exist as underlying anchored asset, and the rule for each is \
        \ URCv_AnchorableDptfAuthority's -- this gate only enforces what that returns: \
        \ 1] Pure DPTF      = Its Owner \
        \ 2] Frozen DPTF    = DPTF Parent Ownership \
        \ 3] Reserved DPTF  = DPTF Parent Ownership \
        \ 4] LP DPTF        = The POOL OWNER of its swpair \
        \ 5] Frozen LP DPTF = The same pool owner \
        \ \
        \ CORRECTED 2026-10-03. Lines 4] and 5] read 'Cannot exist as underlaying DPTF-Based \
        \ Anchor', which was true and indefensible: an LP token is owned by SWP|SC_NAME with \
        \ can-change-owner false, so the ownership enforce could never pass and a pool owner \
        \ could not anchor their own pool's LP token. Worse, it was INCONSISTENT -- 2] accepts \
        \ a frozen token by resolving to its parent, so a frozen LP resolved to the native LP \
        \ and was then refused for being owned by a contract. Same rule, opposite outcome. \
        \ \
        \ Note 4] and 5] were never an enforce: they were a CONSEQUENCE, which is why nothing \
        \ caught the inconsistency. [6.2.1] <<TX-ANK-VAR4b>> pinned the old refusal; it now \
        \ pins the new acceptance."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                ;;
                (owner:string (URCv_AnchorableDptfAuthority dptf-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner)
        )
    )
    ;;{5.5}  Write [W]
    ;; [W]   write
    ;; Five blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    (defun WI_Anchor:string
        (anchor-id:string row:object{AcquisitionSchemasV5.ANK|Schema})
        @doc "Insert ANK|T|Anchor full row (issue only)."
        (require-capability (SECURE))
        (insert ANK|T|Anchor anchor-id row)
    )
    ;; WW_Anchor — not used: issue path is WI_Anchor; revoke uses WU_Anchor|State.
    ;; WU_Anchor|AnchoredAsset — not mutable [.]
    ;; WU_Anchor|Fungibility — not mutable [.]
    ;; WU_Anchor|BoostClassId — not mutable [.]
    ;; WU_Anchor|Precision — not mutable [.]
    (defun WU_Anchor|State:string
        (anchor-id:string ank-active:bool)
        @doc "Update ank-active on ANK|T|Anchor."
        (require-capability (SECURE))
        (update ANK|T|Anchor anchor-id {"ank-active": ank-active})
    )
    (defun WU_BC|AddScoreLink:string
        (boost-class-id:string score-id:string)
        @doc "Add score-id to the BoostClass reverse-index set (idempotent — no-op if already present). Upsert. \
            \ H4 reverse index + #9 revoke lock (locked while the set is non-empty)."
        (require-capability (SECURE))
        (let
            (
                (sl:[string] (UR_BC|ScoreLinks boost-class-id))
            )
            (write ANK|T|BoostClassScoreLinks boost-class-id
                {"score-links"     : (if (contains score-id sl) sl (+ sl [score-id]))
                ,"boost-class-id"  : boost-class-id})
        )
    )
    (defun WU_BC|RemoveScoreLink:string
        (boost-class-id:string score-id:string)
        @doc "Remove score-id from the BoostClass reverse-index set (a score re-pointed/unlinked its \
            \ boost-class-link AWAY — M4 #13 / sweep unlink). Upsert. Releases the class's revoke lock once empty."
        (require-capability (SECURE))
        (write ANK|T|BoostClassScoreLinks boost-class-id
            {"score-links"     : (filter (lambda (s:string) (!= s score-id)) (UR_BC|ScoreLinks boost-class-id))
            ,"boost-class-id"  : boost-class-id})
    )
    ;; WU_Anchor|Promile — not mutable [.]
    ;; WU_Anchor|TFAmount — not mutable [.]
    ;; WU_Anchor|SFNonce — not mutable [.]
    ;; WU_Anchor|NFTraitKey — not mutable [.]
    ;; WU_Anchor|NFTraitValue — not mutable [.]
    ;; WU_Anchor|NFNonceClass — not mutable [.]
    ;; WU_Anchor|ID — select key; WU not needed.
    ;;
    (defun WI_BoostClass:string
        (boost-class-id:string row:object{AcquisitionSchemasV5.ANK|BoostClass})
        @doc "Insert ANK|T|BoostClass full row (inline issue when acnoi)."
        (require-capability (SECURE))
        (insert ANK|T|BoostClass boost-class-id row)
    )
    (defun WW_BoostClass:string
        (boost-class-id:string row:object{AcquisitionSchemasV5.ANK|BoostClass})
        @doc "Upsert full ANK|T|BoostClass row (bookkeeping add/remove anchor slots)."
        (require-capability (SECURE))
        (write ANK|T|BoostClass boost-class-id row)
    )
    ;; WU_BoostClass|Primary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Secondary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Tertiary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Quaternary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Quinary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Senary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Septenary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Anchors — not used: mutates via WW_BoostClass (full row).
    (defun WU_BoostClass|Active:string
        (boost-class-id:string class-active:bool)
        @doc "Update class-active on ANK|T|BoostClass."
        (require-capability (SECURE))
        (update ANK|T|BoostClass boost-class-id {"class-active": class-active})
    )
    ;; WU_BoostClass|ID — select key; WU not needed.
    ;;
    ;; WI_AssetAnchors — not used: first row touch is WW_AssetAnchors (upsert path).
    (defun WW_AssetAnchors:string
        (asset-id:string row:object{AcquisitionSchemasV5.ANK|AssetAnchors})
        @doc "Upsert full ANK|T|AssetAnchors row (place/remove anchor in groups)."
        (require-capability (SECURE))
        (write ANK|T|AssetAnchors asset-id row)
    )
    ;; WU_AssetAnchors|GroupPrimary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSecondary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupTertiary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupQuaternary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupQuinary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSenary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSeptenary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupsActive — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|AnchorsActive — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|AssetId — select key; WU not needed.
    ;;
    ;; WI_Anchors — not used: first row touch is WW_Anchors (upsert path).
    (defun WW_Anchors:string
        (account:string anchor-id:string promile:decimal)
        @doc "Upsert user promile on ANK|T|Anchors for (account, anchor-id). L6 #18: floors the stored promile at \
            \ 0 — this is the SOLE write chokepoint for per-anchor user promile (every TF/SF/NF, incremental AND \
            \ absolute, path routes here), so an incremental delta can never persist a negative. The trigger is \
            \ real and outside AQP's control (NFT metadata on a trait-anchor is mutable at the DPDC layer, even by \
            \ module admin), so AQP guards its own accounting at its boundary. The aggregate (Σ of these) is then \
            \ non-negative too; the …PromileAbsolute resync recomputes the true value. Floor, not enforce — a hard \
            \ abort would strand a staker's assets; the clamp lets unstake always succeed."
        (require-capability (SECURE))
        (write ANK|T|Anchors (UCk_Anchors account anchor-id)
            (UDC_AccountAnchor (if (< promile 0.0) 0.0 promile) account anchor-id)
        )
    )
    ;; WU_Anchors|Promile — not used: mutates via WW_Anchors (full row).
    ;; WU_Anchors|Account — select key; WU not needed.
    ;; WU_Anchors|ID — select key; WU not needed.
    ;;
    ;; WI_UserBoost — not used: first row touch is WW_UserBoost (upsert path).
    (defun WW_UserBoost:string
        (account:string boost-class-id:string aggregate-promile:decimal)
        @doc "Upsert aggregate-promile on ANK|T|UserBoost."
        (require-capability (SECURE))
        (write ANK|T|UserBoost (UCk_UserBoost account boost-class-id)
            (UDC_UserBoost aggregate-promile account boost-class-id)
        )
    )
    ;;{5.6}  Aux/X
    ;; [XI]
    ;;
    ;; Depth: C_* → XI_* (depth 0) → XI_1|* … ; XE_* / XB_* → XI_1|* (depth 1) → XI_2|* …
    ;; Blocks: map first, then functions in map order (entry → children → shared leaves).
    ;;
    ;; --- Block A · C_Issue*Anchor ---
    ;;   C_Issue*Anchor
    ;;     ├ XI_IssueBoostClass (optional)
    ;;     └ XI_IssueAnchor
    ;;          └ XI_PlaceAnchorInBookkeeping
    ;; --- Block B · C_RevokeAnchor ---
    ;;   C_RevokeAnchor → XI_RevokeAnchorBookkeeping
    ;; --- Block C · TF user promile (FVT phase 2.2 backward) ---
    ;;   XE_UpdateTrueFungibleUserAnchorValues
    ;;     └ XI_1|UpdateTrueFungibleUserAnchorValues
    ;; --- Block D · SF user promile ---
    ;;   XE_UpdateSemiFungibleUserAnchorValues
    ;;     └ XI_1|UpdateSemiFungibleUserAnchorValues
    ;; --- Block E · NF user promile ---
    ;;   XE_UpdateNonFungibleUserAnchorValues
    ;;     └ XI_1|UpdateNonFungibleUserAnchorValues
    ;; --- Block F · shared leaf ---
    ;;   XI_2|RecomputeAffectedBoostAggregates (TF / SF / NF / resync)
    ;;
    ;;Protection: Class 1 — Innate protection offered by WI_BoostClass
    (defun XI_IssueBoostClass:string
        (boost-class-name:string class-owner:string)
        @doc "Internal (C_Issue*Anchor · depth 0]): create BoostClass inline when acnoi; returns boost-class-id. \
            \ `class-owner` is recorded so only the creator may later attach anchors (2026-09-19)."
        ;; SECURE: granted by WI_BoostClass (underlying W_).
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                ;;
                (boost-class-id:string (ref-U|DALOS::UDC_Makeid boost-class-name))
            )
            (WI_BoostClass boost-class-id
                (UDC_BoostClass BAR BAR BAR BAR BAR BAR BAR 0 true boost-class-id class-owner)
            )
            boost-class-id
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WI_Anchor
    (defun XI_IssueAnchor:string
        (
            ank-name:string ank-asset:string ank-fungibility:[bool] boost-class-id:string ank-precision:integer ank-promile:decimal
            dptf-amount:decimal dpsf-nonce:integer dpnf-trait-key:string dpnf-trait-value:string dpnf-nonce-class:integer
        )
        @doc "Internal (C_Issue*Anchor · depth 0]): insert ANK|T|Anchor row; returns anchor-id."
        ;; SECURE: granted by WI_Anchor (underlying W_).
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                ;;
                (anchor-id:string (ref-U|DALOS::UDC_Makeid ank-name))
            )
            (WI_Anchor anchor-id
                (UDC_ANK|Schema
                    ank-asset ank-fungibility boost-class-id ank-precision true ank-promile
                    dptf-amount dpsf-nonce dpnf-trait-key dpnf-trait-value dpnf-nonce-class anchor-id
                )
            )
            anchor-id
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_BoostClass, WW_AssetAnchors
    (defun XI_PlaceAnchorInBookkeeping (anchor-id:string asset-id:string boost-class-id:string)
        @doc "Internal (C_Issue*Anchor · depth 1]): place anchor in BoostClass + AssetAnchors bookkeeping."
        ;; SECURE: granted by WW_BoostClass and WW_AssetAnchors (underlying W_).
        (let
            (
                (bc:object{AcquisitionSchemasV5.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV5.ANK|AssetAnchors} (UR_AA|Data asset-id))
            )
            (WW_BoostClass boost-class-id (UDC_BC|WithAddedAnchor bc anchor-id))
            (WW_AssetAnchors asset-id (UDC_AA|PlaceAnchor aa anchor-id))
        )
    )
    ;;
    ;; --- Block B · C_RevokeAnchor ---
    ;;Protection: Class 1 — Innate protection offered by C_RevokeAnchor, WW_BoostClass,
    ;;Protection:          WW_AssetAnchors
    (defun XI_RevokeAnchorBookkeeping (anchor-id:string)
        @doc "Internal (C_RevokeAnchor · depth 0]): remove anchor from BoostClass + AssetAnchors bookkeeping."
        ;; SECURE: granted by WW_BoostClass and WW_AssetAnchors (underlying W_).
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (boost-class-id:string (UR_ANK|BoostClassId anchor-id))
                (bc:object{AcquisitionSchemasV5.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV5.ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (WW_BoostClass boost-class-id (UDC_BC|WithRemovedAnchor bc anchor-id))
            (WW_AssetAnchors ank-asset (UDC_AA|RemoveAnchor aa anchor-id))
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|UpdateTrueFungibleUserAnchorValues
        (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Internal (XE_Update*TF · depth 1]): rewrite user promile for each live TF anchor on dptf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dptf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPTF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_TrueFungibleAnchorPromile aid total-dptf-amount))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|UpdateSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Internal (XE_Update*SF · depth 1]): rewrite user promile for each live SF anchor on dpsf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPSF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_SemiFungibleAnchorPromile account aid nonces nonce-amounts direction))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|UpdateNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer] direction:bool)
        @doc "Internal (XE_Update*NF · depth 1]): rewrite user promile for each live NF anchor on dpnf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPNF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_NonFungibleAnchorPromile account aid nonces direction))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|ResyncSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Internal (XE_ResyncSemiFungible* · depth 1]): absolute promile per live SF anchor from rollup nonce inventory."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal
                                                (URC_SemiFungibleAnchorPromileAbsolute aid nonces nonce-amounts)
                                            )
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|ResyncNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer])
        @doc "Internal (XE_ResyncNonFungible* · depth 1]): absolute promile per live NF anchor from rollup nonce inventory."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal
                                                (URC_NonFungibleAnchorPromileAbsolute aid nonces)
                                            )
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;
    ;; --- Block F · shared leaf ---
    ;;Protection: Class 1 — Innate protection offered by WW_UserBoost
    (defun XI_2|RecomputeAffectedBoostAggregates (account:string boost-class-ids:[string])
        @doc "Internal (user promile update · depth 2 · shared leaf]): recompute ANK|T|UserBoost aggregate-promile per boost-class-id."
        ;; SECURE: granted by WW_UserBoost (underlying W_).
        ;; map: distinct boost-class-ids touched by anchor promile refresh
        (map
            (lambda (bcid:string)
                (let
                    (
                        (bc:object{AcquisitionSchemasV5.ANK|BoostClass} (UR_BC|Data bcid))
                        (n:integer (at "anchors" bc))
                    )
                    (if (<= n 0)
                        ;; class has NO anchors left ⇒ aggregate-promile is 0. Must WRITE it (not skip) — the sweep
                        ;; can remove the LAST anchor from a class, and a skipped write would leave a stale nonzero
                        ;; aggregate (surfaced by the re-score sweep proof). Normal stake/unstake never hits n<=0.
                        (WW_UserBoost account bcid 0.0)
                        (let
                            (
                                (agg:decimal
                                    ;; fold: anchor slots 0..n-1 in this BoostClass (sum user promile)
                                    (fold
                                        (lambda (acc:decimal idx:integer)
                                            (let
                                                (
                                                    (aid:string (URC_BC|AnchorIdAtSlot bc idx))
                                                )
                                                (if (= aid BAR)
                                                    acc
                                                    (+ acc (UR_ANK-U|Promile account aid))
                                                )
                                            )
                                        )
                                        0.0
                                        (enumerate 0 (- n 1))
                                    )
                                )
                            )
                            (WW_UserBoost account bcid agg)
                        )
                    )
                )
            )
            boost-class-ids
        )
    )
    ;; [XE]
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|XE>SWEEP-REVOKE
    (defun XE_SweepRevokeAnchor:string
        (anchor-id:string)
        @doc "Forward (re-score sweep terminal · MTX-AQP): revoke an EMPLOYED anchor after the sweep has refreshed \
            \ every affected holder — set state false + remove it from its BoostClass/AssetAnchors, SKIPPING the #9 \
            \ score-link lock (which C_RevokeAnchor enforces for UNemployed anchors). The reverse-index set is \
            \ UNCHANGED: scores keep employing the class (via its other anchors, or an emptied class contributing \
            \ 0 boost). No IGNIS (the sweep defpact bills). P|UEV_IMC + ANK|XE>SWEEP-REVOKE (liveness + owner + SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|XE>SWEEP-REVOKE anchor-id)
            (WU_Anchor|State anchor-id false)
            (XI_RevokeAnchorBookkeeping anchor-id)
        )
        anchor-id
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>BUMP-BOOST-CLASS-LINKS
    (defun XE_BumpBoostClassScoreLinks:string
        (boost-class-id:string score-id:string)
        @doc "Forward (AQP-SCORE::XI_CreateBoostClassLink): register score-id in the BoostClass reverse-index set, \
            \ locking revoke of any anchor in this class while the set is non-empty (H4 #9 lock + the sweep's \
            \ enumerable index). Idempotent. P|UEV_IMC + ANK|C>BUMP-BOOST-CLASS-LINKS (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|C>BUMP-BOOST-CLASS-LINKS boost-class-id)
            (WU_BC|AddScoreLink boost-class-id score-id)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>BUMP-BOOST-CLASS-LINKS
    (defun XE_UnbumpBoostClassScoreLinks:string
        (boost-class-id:string score-id:string)
        @doc "Forward (AQP-SCORE::XI_CreateBoostClassLink re-point/unlink): remove score-id from the BoostClass \
            \ reverse-index set (M4 #13 / sweep unlink). Releases the class's revoke lock once the set empties. \
            \ P|UEV_IMC + ANK|C>BUMP-BOOST-CLASS-LINKS (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|C>BUMP-BOOST-CLASS-LINKS boost-class-id)
            (WU_BC|RemoveScoreLink boost-class-id score-id)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|XE>SWEEP
    (defun XE_RecomputeUserBoostAggregates:string
        (account:string boost-class-ids:[string])
        @doc "Forward (re-score sweep): refold this user's aggregate-promile for the given boost-classes from the \
            \ anchors CURRENTLY in each class. After a sweep removes (or re-prices) an anchor GLOBALLY, this \
            \ re-derives each holder's stored aggregate-promile so it no longer reflects the retired anchor — the \
            \ DEEPER recompute (the deb refresh alone assumes the aggregate is correct). NO fund movement; the \
            \ sweep defpact bills IGNIS. P|UEV_IMC + ANK|XE>SWEEP (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|XE>SWEEP)
            (XI_2|RecomputeAffectedBoostAggregates account boost-class-ids)
            (format "ANK sweep: refolded {} boost aggregate(s) for {}" [(length boost-class-ids) account])
        )
    )
    ;;
    ;; --- Block C · TF user promile ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateTrueFungibleUserAnchorValues:object{IgnisCollectorV4.OutputCumulator}
        (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Backward (FVT::XI_RefreshTrueFungibleStakeAnchors / C_Sync*): P|UEV_IMC + XI_1|UpdateTrueFungibleUserAnchorValues \
            \ when n_live > 0; IGNIS = ignis|small × n_live (live anchors on dptf-id). \
            \ IGNIS interactor = AQP|SC_NAME (pool vault receiver)."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dptf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPTF account dptf-id total-dptf-amount)
                    (XI_1|UpdateTrueFungibleUserAnchorValues account dptf-id total-dptf-amount)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dptf-id]
            )
        )
    )
    ;;
    ;; --- Block D · SF user promile ---
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>UPDATE-DPSF
    (defun XE_UpdateSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Updates user promile for each live SF anchor on dpsf-id, then recomputes affected BoostClass aggregates."
        (P|UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPSF account dpsf-id nonces)
            (XI_1|UpdateSemiFungibleUserAnchorValues account dpsf-id nonces nonce-amounts direction)
        )
    )
    ;;
    ;; --- Block E · NF user promile ---
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>UPDATE-DPNF
    (defun XE_UpdateNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer] direction:bool)
        @doc "Updates user promile for each live NF anchor on dpnf-id, then recomputes affected BoostClass aggregates."
        (P|UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPNF account dpnf-id nonces)
            (XI_1|UpdateNonFungibleUserAnchorValues account dpnf-id nonces direction)
        )
    )
    ;;
    ;; --- Block D′ · SF resync (C_SyncCollectableAnchors · son=true) ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_ResyncSemiFungibleUserAnchorValues:object{IgnisCollectorV4.OutputCumulator}
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Backward (AQP::C_SyncCollectableAnchors): rewrite SF promile from full rollup inventory; IGNIS per live anchor."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPSF account dpsf-id nonces)
                    (XI_1|ResyncSemiFungibleUserAnchorValues account dpsf-id nonces nonce-amounts)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dpsf-id]
            )
        )
    )
    ;;
    ;; --- Block E′ · NF resync (C_SyncCollectableAnchors · son=false) ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_ResyncNonFungibleUserAnchorValues:object{IgnisCollectorV4.OutputCumulator}
        (account:string dpnf-id:string nonces:[integer])
        @doc "Backward (AQP::C_SyncCollectableAnchors): rewrite NF promile from full rollup inventory; IGNIS per live anchor."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPNF account dpnf-id nonces)
                    (XI_1|ResyncNonFungibleUserAnchorValues account dpnf-id nonces)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dpnf-id]
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]   client
    ;;
    (defun C_RevokeBoostClass:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string boost-class-id:string)
        @doc "Revokes an empty BoostClass. \
            \ \
            \ Executor: ENFORCED DIRECTLY, and THE ENFORCE IS NEW. See \
            \ UEV_ExecutorIzClassOwner: this entrypoint checked no account whatsoever, so any \
            \ account reachable through Talos could revoke any empty BoostClass. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIzClassOwner executor boost-class-id)
        (with-capability (ANK|C>REVOKE-BOOST-CLASS boost-class-id)
            (WU_BoostClass|Active boost-class-id false)
            (URCi_RevokeBoostClass)
        )
    )
    (defun C_IssueTrueFungibleAnchor:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Issues a DPTF anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPTF executor anchor-name dptf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dptf-amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [true true])
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dptf-id fungibility boost-class-id anchor-precision anchor-promile
                            dptf-amount 0 BAR BAR -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dptf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueTrueFungibleAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_IssueSemiFungibleAnchor:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Issues a DPSF anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPSF executor anchor-name dpsf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpsf-nonce)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [false true])
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dpsf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 dpsf-nonce BAR BAR -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpsf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueSemiFungibleAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_IssueNonFungibleAnchor:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Issues a DPNF trait-anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-trait-key dpnf-trait-value)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [false false])
                    (anchor-id:string
                        (XI_IssueAnchor
                            anchor-name dpnf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 0 dpnf-trait-key dpnf-trait-value -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpnf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueNonFungibleAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_IssueNonFungibleSetAnchor:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Issues a DPNF set-anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF-SET executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-nonce-class)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [false false])
                    (anchor-id:string
                        (XI_IssueAnchor
                            anchor-name dpnf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 0 BAR BAR dpnf-nonce-class
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpnf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueNonFungibleSetAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_RevokeAnchor:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string anchor-id:string)
        @doc "Revokes an anchor and updates BoostClass and AssetAnchors bookkeeping. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. ANK|C>REVOKE runs (CAP_Owner anchor-id), \
            \ which resolves the ANCHORED ASSET's authority and enforces on it -- a DERIVED \
            \ account naming no actor, HANDOFF 4g. UEV_ExecutorIzAnchorAuthority supplies the \
            \ other half. That helper already existed, written for MTX-AQP's \
            \ C_2|SweepRevokeAnchor, and it is a DISJUNCTION rather than an equality because a \
            \ collectable has two authorities (owner OR creator) where a DPTF has one. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (ANK|C>REVOKE executor anchor-id)
            (WU_Anchor|State anchor-id false)
            (XI_RevokeAnchorBookkeeping anchor-id)
            (URCi_RevokeAnchor)
        )
    )

)



;;

;; --- tables for 01_ANK.pact (8 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table ANK|T|Anchor)
;; (create-table ANK|T|BoostClass)
;; (create-table ANK|T|AssetAnchors)
;; (create-table ANK|T|BoostClassScoreLinks)
;; (create-table ANK|T|Anchors)
;; (create-table ANK|T|UserBoost)


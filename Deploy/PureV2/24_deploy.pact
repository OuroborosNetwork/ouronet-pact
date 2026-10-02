;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 24
;; IGNIS + AQP-BOOT -- the STOA price source, and the bootstrap re-run guards
;; =========================================================================================
;; TWO MODULE UPGRADES IN ONE TRANSACTION, in deploy order: IGNIS (sovereign core) then
;; AQP-BOOT (citizen). Both module-only -- IgnisCollectorV3 and AcquisitionPoolBootV1 are
;; already live, and a deployed interface cannot be re-sent. Neither declares a new table.
;;
;; RUN Deploy/2_Init/02_init.pact FIRST. That is the IMC permission delta (35 registrations);
;; without it every AQP call still dies on `P|UEV_IMC` -- "None of the guards passed" -- before
;; reaching anything in this file.
;;
;; =========================================================================================
;; PART 1 -- IGNIS: UC_StoaPrice read the wrong source for the price of STOA
;; =========================================================================================
;; One function, one line.
;;
;;     was:  (/ (/ (UC_IgnisDeter deter-key) 100.0) (ref-DALOS::UR_UsagePrice "stoa|price"))
;;     now:  (/ (/ (UC_IgnisDeter deter-key) 100.0) (ref-U|CT|DIA::UR_STOA-PID|Price))
;;
;; THE DEFECT. `"stoa|price"` is a row in the USAGE-PRICES table. That table is for prices of
;; USAGE; the price of STOA itself is not one. The canonical STOA/USD reader is the DIA oracle
;; stub `U|CT::UR_STOA-PID|Price`. Measured across the tree:
;;
;;     "stoa|price"            read in exactly ONE place -- this function
;;     UR_STOA-PID|Price       read in ~40: every launchpad, every AppReads price column, and
;;                             -- IN THIS MODULE, a hundred lines above -- OI|UDC_FullStoaCosts,
;;                             the COST PREVIEW
;;
;; So charge and preview read different sources. Moving the peg with the admin operation
;; `DALOS|A_UpdateUsagePrice "stoa|price"` 0.10 -> 0.25, on the pre-fix code:
;;
;;     UC_StoaPrice "issue-nft"   250.0 -> 100.0      the CHARGE moved
;;     U|CT::UR_STOA-PID|Price      0.1 ->   0.1      the PREVIEW did not
;;
;; The preview would quote $40 of STOA while the charge took $10. The peg was adjustable for one
;; reader out of forty.
;;
;; WHAT IT BROKE ON MAINNET, and it is two things, not one:
;;
;;   1. EVERY STOA-CHARGING OPERATION. The key was never written, and a missing-row read is not
;;      catchable -- it takes the transaction. AQP-BOOT Step 2 dies here:
;;         C_Step2 -> TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor -> ANK::C_IssueNonFungibleAnchor
;;                 -> (IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
;;                 -> (* (IGNIS::UC_StoaPrice "anchor") (if acnoi 2.0 1.0))
;;
;;   2. THE PYTHIA CONSOLE. `PYTHIA::UR_Config` defaults to
;;      `(ref-IGNIS::UC_StoaPrice "pythia-deploy")`, so `UR_DeployPrice`, `UR_RenamePrice` and
;;      `P-UI-ONE::URC_03|Prices` all abort through it. PYTHIA needs NO change of its own -- it
;;      reaches IGNIS through a MODREF, which resolves at runtime, so this upgrade repairs it.
;;      Verified with no `stoa|price` row anywhere:
;;         PYTHIA.UR_Config = {"deploy-price": 500.0, "rename-price": 100.0}
;;      i.e. $50 / $10 at the $0.10 peg, exactly as its @doc claims.
;;      (PureV2/19_deploy's header called this "an init gap, not a code one". It was the
;;      reverse, and is corrected there.)
;;
;; WHAT IS GIVEN UP. The peg is no longer tunable by an admin table write. `UR_STOA-PID|Price`
;; is a hardcoded stub ("wire the real oracle call above once one is available"), and U|CT is a
;; UTILITY deployed before Core, so it cannot read a DALOS table to regain tunability without a
;; deploy-order violation. Until the DIA oracle is wired the peg moves only with a U|CT
;; redeploy -- and once wired it moves with the market for all ~40 readers at once.
;;
;; VALUES ARE UNCHANGED. Both sources answer 0.1, and the live oracle was probed to confirm it:
;; `(ouronet-ns.U|CT.UR_STOA-PID|Price)` -> 0.1. Both generated pricing artefacts regenerate
;; BYTE-IDENTICAL. Nothing in the price sheet moves; only where the number comes from.
;;
;; =========================================================================================
;; PART 2 -- AQP-BOOT: the bootstrap steps were not re-runnable
;; =========================================================================================
;; Three guards and one internal helper. Also re-pins KBN -- see the last section.
;;
;; THE DEFECT. Every id these steps create comes from `U|DALOS::UDC_Makeid`, which seeds on
;; <prev-block-hash> -- block-level, not per-transaction. A second run in the SAME block collides
;; on a raw insert and aborts, which reads as protection and is not: in a LATER block the hash
;; differs, so a second run gets FRESH ids, inserts cleanly, and leaves a COMPLETE DUPLICATE set
;; of entities with no error anywhere. `C_DefinePrimordialSet` computes
;; `(set-class = used + 1)` and inserts at that fresh key, so it can never collide.
;;
;; THE TEST SUITE HAD BEEN DOING IT ON EVERY GATE RUN. `[5.4]_PopulateBunnies` TX-03 calls
;; `KBN::A_BunnyRGBSet` directly and `[6.2.9]_AQP-BOOT-FULL` then calls Step 1 on the same
;; collection -- [5.4] first in all four loaders. Two set classes, every run, asserted nowhere.
;; The guard is what surfaced it.
;;
;; THE GUARDS CHECK CHAIN STATE, NOT A STEP LEDGER:
;;     Step 1   DPDC::UR_SetClassesUsed kbn-id false   must be 0
;;     Step 2   AQP-ANK::UR_AA|AnchorsActive kbn-id    must be 0   (it issues the first four)
;;     Step 3   AQP-ANK::UR_AA|AnchorsActive kbn-id    must be 4   (Step 2's, not its own eleven)
;; A ledger records that this module ran something; state records that the THING EXISTS. Only
;; the second is true retroactively, and only the second cannot drift from reality. Step 3 is
;; EXACT: after it the count is 15, and a >= would admit a second run and issue eleven duplicate
;; anchors against the 49-slot asset cap.
;;
;; ONLY STEPS 1-3 ARE GUARDED, and the limit is stated rather than tidied away: those three have
;; a natural per-collection signal. Steps 4-8, 10, 13 and 14 create scores, pools, FVT entities
;; and agencies with random ids and no per-owner count, so there is nothing to check without a
;; ledger table. THEY REMAIN NOT RE-RUN-SAFE -- run each exactly once and keep the id lists each
;; returns.
;;
;; =========================================================================================
;; WHY AQP-BOOT IS IN THIS ROUND AT ALL -- THE DOT-CALL PIN
;; =========================================================================================
;; `AQP-BOOT` line 414 is `(KBN.A_BunnyRGBSet patron kbn-id)` -- a DOT call, the only one in the
;; file, because KBN implements no interface and there is nothing to modref. A dot call resolves
;; at the CALLER's deploy time and PINS the callee's code into the caller.
;;
;;     block 621,458   KBN upgraded to write the Arweave artwork
;;     block 621,472   Step 1 ran -- FOURTEEN BLOCKS LATER -- and wrote the OLD placeholders
;;
;; because AQP-BOOT still carried the KBN it was compiled against. Redeploying it here re-pins
;; the current KBN. That repair is now MOOT for the Bunny set, which was fixed by hand with
;; `DPNF|C_UpdateSetNonceURI`, but the pin would bite the next KBN change.
;;
;; `_dotpin.py --upgrade KBN` reports this mechanically; `--check` is gate-fatal on a new
;; unregistered dot edge. `--upgrade IGNIS` reports none: nothing dot-calls IGNIS, so Part 1
;; refreshes every caller and needs nothing redeployed behind it.
;;
;; =========================================================================================
;; VERIFICATION
;; =========================================================================================
;; `[6.2.9]_AQP-BOOT-FULL` pins all three guards, asserting on the MESSAGE rather than on bare
;; failure -- these calls are also gated by GOV|AQP_BOOT_ADMIN and by per-anchor ownership, so a
;; message-less expect-failure would stay green with the guards deleted:
;;     <<BOOT-S1-DUP>>   Step 1 refused; the collection still carries exactly ONE set class
;;     <<BOOT-S23-DUP>>  15 anchors after 2+3; Step 2 refused at 15; Step 3 refused at 15; the
;;                       refusals wrote nothing
;; NEGATIVE-TESTED: neutering the enforce to `(or true ...)` turns six assertions red.
;;
;; `modules/AQP.repl` <<AQP-D1a>>/<<AQP-D1b>> were rewritten: D1b previously MOVED the peg and
;; asserted the amounts followed -- every assertion true, protecting the incoherent behaviour.
;; It now asserts that writing the table key changes NOTHING and that charge and preview read the
;; same source.
;;
;; `REPL/_scratch_loadpurev2.repl` loads 23 and this file over an already-deployed tree -- the
;; only check that catches an interface re-sent or a create-table left in an upgrade -- and
;; asserts both interfaces are still satisfied and that UC_StoaPrice derives from the oracle.
;;
;; Gate green at 26,225 assertions.
;;
;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/../../1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact (module only -- its interface is already live)
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
    (implements IgnisCollectorV3)
    (implements OuronetInfoV2)

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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|DALOS|SC_NAME)
        )
    )
    (defconst OUROBOROS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
        ,"unstale"           : 100.0
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
        ,"aqp-inject"        : 500.0
        ,"aqp-collect"       : 500.0
        ,"sync-anchors"      : 50.0
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
        ,"AQP-SCR|C_CombineTripletScoreModel"           : 16.0
        ,"AQP-SCR|C_ControlScore"                       : 13.0
        ,"AQP-SCR|C_CreateScoreBoostClassLink"          : 26.0
        ,"AQP-SCR|C_CreateScoreBoostLink"               : 13.0
        ,"AQP-SCR|C_EnableDebBoost"                     : 13.0
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists receiver)
            (compose-capability (SECURE))
        )
    )
    (defcap IGNIS|C>DC (patron:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun UDC_EmptyOutputCumulatorV2:object{IgnisCollectorV3.OutputCumulator} ()
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
    (defun UDC_ConstructOutputCumulator:object{IgnisCollectorV3.OutputCumulator}
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
    (defun UDC_BrandingCumulator:object{IgnisCollectorV3.OutputCumulator}
        (active-account:string multiplier:decimal)
        (UDC_ConstructOutputCumulator
            (* multiplier (UC_IgnisLeg "tier-branding"))
            active-account
            (URC_IsVirtualGasZero)
            []
        )
    )
    (defun UDC_LegCumulator:object{IgnisCollectorV3.OutputCumulator}
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
    (defun UDC_CustomCodeCumulator:object{IgnisCollectorV3.OutputCumulator} ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun UDC_MakeModularCumulator:object{IgnisCollectorV3.ModularCumulator}
        (price:decimal active-account:string trigger:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun UDC_MakeOutputCumulator:object{IgnisCollectorV3.OutputCumulator}
        (input-modular-cumulator-chain:[object{IgnisCollectorV3.ModularCumulator}] output-lst:list)
        {"cumulator-chain"  : input-modular-cumulator-chain
        ,"output"           : output-lst}
    )
    (defun UDC_ConcatenateOutputCumulators:object{IgnisCollectorV3.OutputCumulator}
        (input-output-cumulator-chain:[object{IgnisCollectorV3.OutputCumulator}] new-output-lst:list)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (folded-obj:[[object{IgnisCollectorV3.ModularCumulator}]]
                    (fold
                        (lambda
                            (acc:[[object{IgnisCollectorV3.ModularCumulator}]] idx:integer)
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
    (defun UDC_CompressOutputCumulator:object{IgnisCollectorV3.CompressedCumulator}
        (input-output-cumulator:object{IgnisCollectorV3.OutputCumulator})
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
                (cumulator-chain-input:[object{IgnisCollectorV3.ModularCumulator}]
                    (at "cumulator-chain" input-output-cumulator)
                )
                (folded-obj:object{IgnisCollectorV3.CompressedCumulator}
                    (fold
                        (lambda
                            (acc:object{IgnisCollectorV3.CompressedCumulator} idx:integer)
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
    (defun UDC_PrimeIgnisCumulator:object{IgnisCollectorV3.PrimedCumulator}
        (patron:string input:object{IgnisCollectorV3.CompressedCumulator})
        @doc "Splits each compressed leg into a smart-account cut and a principal/BAR cut per the \
            \ GAS_QUARTER fee-share. Optimized (DALOS audit, post-#8H) the same way as \
            \ UDC_CompressOutputCumulator above — see that function's @doc."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (fll:integer (length (at "ignis-prices" input)))
                (ignis-discount:decimal (ref-DALOS::URC_IgnisGasDiscount patron))
                (folded-obj:object{IgnisCollectorV3.CompressedCumulator}
                    (fold
                        (lambda
                            (acc:object{IgnisCollectorV3.CompressedCumulator} idx:integer)
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
    (defun OI|UDC_ClientInfo:object{OuronetInfoV2.ClientInfo}
        (a:[string] b:[string] c:object{OuronetInfoV2.ClientIgnisCosts} d:object{OuronetInfoV2.ClientStoaCosts} e:list)
        {"pre-text"         : a
        ,"post-text"        : b
        ,"ignis"            : c
        ,"stoa"           : d
        ,"output"           : e}
    )
    (defun OI|UDC_ClientIgnisCosts:object{OuronetInfoV2.ClientIgnisCosts}
        (a:decimal b:decimal c:decimal d:string)
        {"ignis-discount"   : a
        ,"ignis-full"       : b
        ,"ignis-need"       : c
        ,"ignis-text"       : d}
    )
    (defun OI|UDC_ClientStoaCosts:object{OuronetInfoV2.ClientStoaCosts}
        (a:decimal b:decimal c:decimal d:[decimal] e:[string] f:string)
        {"stoa-discount"  : a
        ,"stoa-full"      : b
        ,"stoa-need"      : c
        ,"stoa-split"     : d
        ,"stoa-targets"   : e
        ,"stoa-text"      : f}
    )
    (defun OI|UDC_FullStoaCosts:object{OuronetInfoV2.ClientStoaCosts} (kfp:decimal)
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
    (defun OI|UDC_StoaCosts:object{OuronetInfoV2.ClientStoaCosts} (patron:string kfp:decimal)
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun OI|UDC_NoStoaCosts:object{OuronetInfoV2.ClientStoaCosts} ()
        (OI|UDC_ClientStoaCosts
            1.0
            0.0
            0.0
            [0.0]
            [BAR]
            "Operation is free of native Stoa (STOA)"
        )
    )
    (defun OI|UDC_DynamicStoaCost:object{OuronetInfoV2.ClientStoaCosts} (patron:string kfp:decimal)
        (if (= kfp 0.0)
            (OI|UDC_NoStoaCosts)
            (OI|UDC_StoaCosts patron kfp)
        )
    )
    ;;
    (defun OI|UDC_IgnisCosts:object{OuronetInfoV2.ClientIgnisCosts} (patron:string ifp:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun OI|UDC_NoIgnisCosts:object{OuronetInfoV2.ClientIgnisCosts} ()
        (OI|UDC_ClientIgnisCosts
            1.0
            0.0
            0.0
            "Operation is free of Ouronet GAS (IGNIS)"
        )
    )
    (defun OI|UDC_DynamicIgnisCost:object{OuronetInfoV2.ClientIgnisCosts} (patron:string ifp:decimal)
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
    (defun OI|UC_IfpFromOutputCumulator:decimal (input:object{IgnisCollectorV3.OutputCumulator})
        (let
            (
                (cc:[object{IgnisCollectorV3.ModularCumulator}] (at "cumulator-chain" input))
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defun DALOS|URCi_ControlSmartAccount:object{IgnisCollectorV3.OutputCumulator} (account:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_ControlSmartAccount" "setup")
            account (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_RotateGovernor:object{IgnisCollectorV3.OutputCumulator} (account:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_RotateGovernor" "auth")
            account (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_RotateGuard:object{IgnisCollectorV3.OutputCumulator} (account:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_RotateGuard" "auth")
            account (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_RotateStoa:object{IgnisCollectorV3.OutputCumulator} (account:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_RotateStoa" "auth")
            account (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_RotateSovereign:object{IgnisCollectorV3.OutputCumulator} (account:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_RotateSovereign" "auth")
            account (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_UpdateEliteAccount:object{IgnisCollectorV3.OutputCumulator} (patron:string)
        (UDC_ConstructOutputCumulator
            (UC_IgnisPrice "DALOS|C_UpdateEliteAccount" "usage")
            patron (URC_IsVirtualGasZero) [])
    )
    (defun DALOS|URCi_UpdateEliteAccountSquared:object{IgnisCollectorV3.OutputCumulator} (patron:string)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (ref-DALOS::UR_AccountCreationStoa) (UC_StoaPrice "acct-standard") 0.0)
        )
    )
    (defun OI|UR_StoaTargets:[string] ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
        (patron:string input-output-cumulator:object{IgnisCollectorV3.OutputCumulator})
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (compressed-cumulator:object{IgnisCollectorV3.CompressedCumulator}
                    (UDC_CompressOutputCumulator input-output-cumulator)
                )
                (primed-cumulator:object{IgnisCollectorV3.PrimedCumulator}
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
                                (primed-collector:object{IgnisCollectorV3.CompressedCumulator} 
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

;; ---- source: 2_CITIZEN/Stage_Z/../5_VaultsMinter/04_AQP-BOOT.pact (module only -- its interface is already live)
(module AQP-BOOT GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements AcquisitionPoolBootV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_AQP-BOOT                           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|AQP_BOOT_ADMIN)))
    (defcap GOV|AQP_BOOT_ADMIN ()                       (enforce-guard GOV|MD_AQP-BOOT))
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
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst BOOT|SCORE_SILVER:string                  "SilverSnakePower")
    (defconst BOOT|SCORE_BRONZE:string                  "BronzeSnakePower")
    (defconst BOOT|SCORE_GOLDEN:string                  "GoldenSnakePower")
    (defconst BOOT|PRECISION:integer                    6)
    (defconst BOOT|MX_FROZEN:decimal                    2.0)
    (defconst BOOT|MX_SLEEPING:decimal                  2.0)
    (defconst BOOT|FVT_OURO_LP_FARM:string              "OuroLpFarm")
    (defconst BOOT|FVT_SUBSIDIARY_TREASURY:string       "SubsidiaryTreasury")
    (defconst BOOT|FVT_CODING_TREASURY:string           "CodingDivisionTreasury")
    (defconst BOOT|FVT_SNAKES_TREASURY:string           "SnakesTreasury")
    (defconst BOOT|FVT_SHARES_TREASURY:string           "CompanySharesTreasury")
    ;;ADDED 2026-09-19. The fifth treasury. C_Step4 creates FOUR core scores and three of them
    ;;had a treasury of their own -- TheCodingDivision, DemiourgosSnakes, DemiourgosShareholder --
    ;;while `Bloodshed` had none, even though C_Step7 attaches it to DHBloodshed and so makes it
    ;;EMPLOYED. An employed score with no FVT link and no reward DPTF aborts every stake at
    ;;05_FVT.pact:1031. Owner ruling 2026-09-19: "staking bloodshed assets determines the pure
    ;;bloodshed score, and we need to be able to earn stuff via that score alone" -- so it earns,
    ;;and it earns through its own class-2 Treasury (the score is NF, and treasuries take SF/NF).
    (defconst BOOT|FVT_BLOODSHED_TREASURY:string "BloodshedTreasury")

    ;;<---------------------------------------------------------------------->
    ;; CUSTODIANS DELEGATED-STAKING VAULT (Steps 13-14). Added 2026-09-19.
    ;;
    ;; WHY THIS IS A CLASS-0 FVT AND NOT A TREASURY. It was specified as "a DSA Treasury",
    ;; and it behaves like one -- users stake an SFT collection, no LP is involved. But
    ;; 08_DSA.pact:292 refuses anything else outright:
    ;;     (enforce (= (RPS.UR_FVT|FvtClass fvt-id) 0) "DSA vault must be a class-0 FVT")
    ;; and AQP.repl <<AQP-G20b>> pins that refusal for a class-1 vault. The reason is in that
    ;; test's own note: capture arithmetic is denominated in an LP denominator, which classes
    ;; 1 and 2 do not have. Delegation members are then admitted through
    ;; RPS::XE_AdmitDelegationMember with swpair "|" and ghost-tvl 0.0, which SKIPS every LP
    ;; rule and the triplet-category<->fvt-class check. So class 0 is the container; the
    ;; behaviour is vault-like. Same shape as OuroLpFarm, which is the working precedent for
    ;; triplet + MULTIPLET_BASE + quality split.
    (defconst BOOT|FVT_CUSTODIANS_VAULT:string          "CustodiansVault")
    (defconst BOOT|POOL_CUSTODIANS:string               "CustodiansPool")
    (defconst BOOT|MODEL_CUSTODIANS_BRONZE:string       "CustodiansBronzeQuintessence")
    (defconst BOOT|MODEL_CUSTODIANS_SILVER:string       "CustodiansSilverQuintessence")
    (defconst BOOT|MODEL_CUSTODIANS_GOLDEN:string       "CustodiansGoldenQuintessence")
    (defconst BOOT|MODEL_CUSTODIANS_TRIPLET:string      "CustodiansQuintessenceTriplet")

    ;; ONE number sets both published thresholds. `unit-score` is quintessence per capture
    ;; unit -- "1 staking unit = 1 node" -- and UEV_OpenGate (08_DSA.pact:672) requires only
    ;; HALF of it to open an agency:
    ;;     (enforce (>= (URC_AgencyQuintessence score-entity-id) (/ (dec unit-score) 2.0)))
    ;; So 20000 => a node at 20000 and an agency at 10000. Do not add a second constant for
    ;; the agency gate; there is no second knob, and inventing one would let the two drift.
    (defconst BOOT|CUSTODIANS_UNIT_SCORE:integer        20000)

    ;; HETEROGENEOUS quality split, per-mille, each row summing to 1000. Rows are read as
    ;; [to-t0 to-t1 to-t2] against the MULTIPLET ladder, which for this vault is the
    ;; OURO|AURYN|ELITEAURYN family from Step 10 -- so t0=OURO, t1=Auryn, t2=Elite-Auryn.
    ;;   bronze  20% OURO / 40% Auryn / 40% Elite-Auryn
    ;;   silver  40% / 30% / 30%
    ;;   golden  60% / 20% / 20%
    (defconst BOOT|CUSTODIANS_SPLIT_BRONZE:[integer]    [200 400 400])
    (defconst BOOT|CUSTODIANS_SPLIT_SILVER:[integer]    [400 300 300])
    (defconst BOOT|CUSTODIANS_SPLIT_GOLDEN:[integer]    [600 200 200])

    ;; QUINTESSENCE PER CUSTODIANS UNIT — owner values, 2026-09-19.
    ;;     nonce 1 Bronze   1 000 whole   ·  1  per fragment
    ;;     nonce 2 Silver  10 000 whole   ·  10 per fragment
    ;;     nonce 3 Golden 100 000 whole   ·  100 per fragment
    ;;     nonce 4 OG      1 000, GOLDEN type, NOT fragmentable — plus a 5% anchor boost (below)
    ;;
    ;; WHY WHOLE AND FRAGMENT CARRY THE SAME NUMBER. URCx_SfStakeDefinitionWeightedRawWeight
    ;; scales a NEGATIVE (fragment) nonce by 0.001 and a whole by 1.0, and one whole splits into
    ;; exactly 1000 fragments. So a single value per tier expresses both:
    ;;     1 whole bronze      = 1000 x 1.000 x 1    = 1000
    ;;     1000 bronze frags   = 1000 x 0.001 x 1000 = 1000
    ;;     1 bronze fragment   = 1000 x 0.001 x 1    = 1
    ;; Listing only the negatives (as the Kursan DSA fixtures do) would make a WHOLE nonce score
    ;; ZERO. <<TX-BOOT-14>> stakes whole nonces precisely to keep that path honest.
    ;;
    ;; CORRECTED 2026-09-19: these were 1.0 / 10.0 / 100.0 — the right RATIO but 1000x too small,
    ;; taken from the collection's "a third of ownership over 10000/1000/100 units" description
    ;; rather than from the quintessence schedule. The ratio held, so every test still passed;
    ;; only the absolute scale was wrong, which is the kind of error a ratio-preserving fixture
    ;; cannot see. It matters: the whole collection is 30,000,000 quintessence, not 30,000, so at
    ;; unit-score 20000 it supports ~1500 capture units rather than one.
    (defconst BOOT|CUSTODIANS_NONCES_BRONZE:[integer]   [1 -1])
    (defconst BOOT|CUSTODIANS_NONCES_SILVER:[integer]   [2 -2])
    (defconst BOOT|CUSTODIANS_NONCES_GOLDEN:[integer]   [3 -3 4])
    (defconst BOOT|CUSTODIANS_VALUE_BRONZE:[decimal]    [1000.0 1000.0])
    (defconst BOOT|CUSTODIANS_VALUE_SILVER:[decimal]    [10000.0 10000.0])
    ;; Golden carries nonce 4 as a THIRD entry: the OG Founder SFT scores 1000 of the golden
    ;; type. It has no fragment negative because nonce 4 is not fragmentable.
    (defconst BOOT|CUSTODIANS_VALUE_GOLDEN:[decimal]    [100000.0 100000.0 1000.0])

    ;; NONCE 4 IS ALSO AN ANCHOR — +5% on the staked quintessence, owner ruling 2026-09-19.
    ;; ank-promile is per-mille and the boost is ADDITIVE (02_SCORE.pact: boosted = base x
    ;; promile/1000, stored as the boost PART, not a replacement), so 5% is 50.0.
    ;; The anchor is issued ONCE with the vault (Step 13); each agency's three scores link to
    ;; the class in Step 14, which is why the boost lands on the user's WHOLE staked
    ;; quintessence and not just the golden lane.
    (defconst BOOT|CUSTODIANS_OG_ANCHOR:string          "CustodiansOgFounder")
    (defconst BOOT|CUSTODIANS_OG_BOOST_CLASS:string     "CustodiansOgBoost")
    (defconst BOOT|CUSTODIANS_OG_PROMILE:decimal        50.0)
    (defconst BOOT|CUSTODIANS_OG_NONCE:integer          4)
    (defconst BOOT|CUSTODIANS_ANK_PRECISION:integer     3)
    (defconst BOOT|CUSTODIANS_PRECISION:integer         24)
    ;;Mirrors AQP-FVT/RPS CT_REWARD_MODE_HETEROGENEOUS. Restated rather than referenced because a
    ;;defconst is not reachable through a module reference -- (ref-FVT::CT_...) is "Cannot apply
    ;;value to non-closure". Pinned against the real thing by <<TX-BOOT-13>>, which reads the mode
    ;;back out of RPS after Step 13 writes it, so a drift in either spelling fails the suite.
    (defconst BOOT|REWARD_MODE_HETEROGENEOUS:string     "HETEROGENEOUS")
    (defconst BOOT|TREASURY_COMMON:string               "|")
    (defconst BOOT|SCORE_ENTITY_SCORE:integer           1)
    (defconst BOOT|SCORE_ENTITY_TRIPLET:integer         3)
    ;;{3.2}  schemas
    ;;{3.3}  tables

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
    ;;
    ;;Step 0 - Wire AQP sovereign IMC policies + AQP|SC_NAME vault governor (run once after module deploy)
    ;;Step 1 - Create the Bunny Set Definition
    ;;Step 2 - Create the BronzeSnakePower, SilverSnakePower and GoldenSnakePower Anchor-Class Definitions
    ;;Step 3 - Create the UnityBooster, StoaBooster and VestaBooster Anchor-Class Definitions
    ;;Step 4 - Create the TheCodingDivision, Bloodshed, DemiourgosShareholder and DemiourgosSnakes Score Definitions
    ;;Step 5 - Create the SubsidiaryCodingDivision, SubsidiaryWonderCoach, SubsidiaryBloodshed, SubsidiaryNosferatu and SubsidiaryBunnies Score Definitions
    ;;Step 6 - Create the Ouro LP Triplet Score Definition
    ;;Step 7 - Create six DH pools (class 3/4 by entity) + class-0 OURO LP pool; assign Step4/5/6 scores
    ;;Step 8 - Issue five FVT entities (farm + vault treasuries) — C_Issue only
    ;;Step 9 - C_AddScoreEntity (type 1) on vault/treasury FVT entities (not farm LP triplet)
    ;;Step 10 - C_IssueMultipletFamily (OURO / Auryn / Elite-Auryn ATS ladder)
    ;;Step 11 - C_IssueTriplet + C_AddScoreEntity (type 3) + C_AddRewardLink (OURO + multiplet-family) on OuroLpFarm
    ;;Step 12 - C_AddRewardLink on vault/treasury FVT entities (plain rewards)

    ;;<=========================================================================>
    ;;{5.4}  Validate [UEV]
    ;;
    (defun UEV_BootStepState (step-name:string what:string actual:integer expected:integer)
        @doc "Refuses a bootstrap step whose CHAIN STATE says it has already completed. \
            \ \
            \ WHY THIS EXISTS, 2026-10-02. These steps are one-shot populators and none of \
            \ them was re-run-safe. Every id they create comes from U|DALOS::UDC_Makeid, \
            \ which seeds on <prev-block-hash> -- block-level, not per-tx. A second run in \
            \ the SAME block collides on a raw insert and aborts, which looks like protection \
            \ and is not: a second run in a LATER block gets fresh ids, inserts cleanly, and \
            \ leaves a COMPLETE DUPLICATE set of entities with no error anywhere. \
            \ \
            \ Observed on mainnet. C_DefinePrimordialSet computes (set-class = used + 1) and \
            \ inserts at that fresh key, so re-running Step 1 does not fail -- it adds a \
            \ second <Bunny RGB Set> at class 2, identically named, with the same recipe, and \
            \ the same 120 nonces then compose into either. \
            \ \
            \ A CHAIN-STATE CHECK, NOT A STEP LEDGER, and the difference is the point. A \
            \ ledger records that this module ran something; the state records that the THING \
            \ EXISTS. Only the second is true retroactively -- it refuses Step 1 on a chain \
            \ where the set was created before this guard was written, which no ledger row \
            \ could do. It also cannot drift from reality, which a ledger can."
        (enforce (= actual expected)
            (format
                "AQP-BOOT {} refused: {} is {}, expected {}. Either this step already ran -- \
                \ it is NOT re-runnable, a second run creates DUPLICATE entities rather than \
                \ failing -- or its predecessor step has not."
                [step-name what actual expected]
            )
        )
    )

    (defun C_Step0_WireImcAndGovernor:string
        (patron:string)
        @doc "Step 0 — AQP-POOL TFT + DPOF IMC + AQP|SC_NAME governor rotate. \
            \ Run once after all four sovereign AQP modules are on chain (before stake/unstake or Step 1+). \
            \ Prerequisite: AQP|SC_NAME smart account deployed (DALOS|A_DeploySmartAccount). \
            \ Talos TS02-C3 P|A_Define (P|TALOS-SUMMONER) is separate — sovereign executor / [4.0]. \
            \ FVT + VCT P|A_Define register IMP; FVT|RemoteAqpGov + VCT|RemoteAqpGov on AQP-POOL for vault legs."
        ;; INPUT
        ;;   patron — gas payer konto (REPL: KST.ANHD)
        ;; REPL: (AQP-BOOT.C_Step0_WireImcAndGovernor KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-P|AQP:module{OuronetPolicyV2} AQP-POOL)
                    (ref-P|RPS:module{OuronetPolicyV2} RPS)
                    (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                    (ref-P|VCT:module{OuronetPolicyV2} AQP-VCT)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    ;;
                    (aqp-sc:string (ref-ANK::GOV|AQP|SC_NAME))
                )
                (ref-P|AQP::P|A_Define)
                (ref-P|RPS::P|A_Define)   ;; #75 B': RPS reward engine registers its guards on deps (royalty disposal)
                (ref-P|FVT::P|A_Define)
                (ref-P|VCT::P|A_Define)
                ;; C_RotateGovernor — AQP|SC_NAME: AQP-POOL.AQP|GOV (stake) + FVT|RemoteAqpGov + VCT|RemoteAqpGov.
                (ref-TS01-C1::DALOS|C_RotateGovernor patron aqp-sc
                    (let
                        (
                            (ref-U|G:module{OuronetGuardsV2} U|G)
                        )
                        (ref-U|G::UEV_GuardOfAny
                            [
                                (create-capability-guard (AQP-POOL.AQP|GOV))
                                (ref-P|AQP::P|UR "FVT|RemoteAqpGov")
                                (ref-P|AQP::P|UR "VCT|RemoteAqpGov")
                            ]
                        )
                    )
                )
                (format "AQP-BOOT Step 0 done. aqp-sc={}. TFT+DPOF IMC + gov wired. NEXT=Step1 or client txs." [aqp-sc])
            )
        )
    )
    (defun C_Step1_CreateBunnySet:string
        (patron:string kbn-id:string)
        @doc "Step 1 — Create Bunny set definition on KBN. INPUT: kbn-id from chain deploy. \
            \ OUTPUT echo: kbn-id. NEXT: Steps 2 and 3 use the same kbn-id."
        ;; INPUT
        ;;   patron   — gas payer konto (REPL: KST.ANHD)
        ;;   kbn-id   — KBN collection id already on chain (REPL: "KBN-98c486052a51")
        ;; OUTPUT (return string)
        ;;   kbn-id echoed — pass unchanged to Steps 2 and 3
        ;; REPL: (AQP-BOOT.C_Step1_CreateBunnySet KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;AUTHORISATION FIRST (2026-09-14 ruling): the admin gate is acquired by the
            ;;with-capability above, so a non-admin is refused before this business check is
            ;;reached and the check can never be what shadows the gate.
            (UEV_BootStepState "Step1" "set-classes-used on the collection"
                (DPDC.UR_SetClassesUsed kbn-id false) 0)
            ;;A DOT CALL, AND IT PINS KBN'S CODE INTO THIS MODULE at AQP-BOOT's deploy time.
            ;;KBN implements no interface, so there is nothing to modref -- which is why this is
            ;;the only non-modref call in the file. The consequence is not theoretical:
            ;;
            ;;  block 621,458  KBN upgraded to write the Arweave artwork
            ;;  block 621,472  THIS step ran and wrote the OLD placeholder strings
            ;;
            ;;because AQP-BOOT had not been redeployed and was still carrying the KBN it was
            ;;compiled against. The set had to be repaired by hand with C_UpdateSetNonceURI.
            ;;
            ;;SO: ANY KBN CHANGE REQUIRES REDEPLOYING AQP-BOOT. `_dotpin.py --upgrade KBN` says
            ;;so mechanically, and `--check` is gate-fatal on a new unregistered dot edge.
            (KBN.A_BunnyRGBSet patron kbn-id)
            (format "AQP-BOOT Step 1 done. kbn-id={}. NEXT=Step2,Step3:kbn-id={}." [kbn-id kbn-id])
        )
    )
    (defun C_Step2_CreateSnakePowerAnchorClasses:string
        (patron:string kbn-id:string)
        @doc "Step 2 — SnakePower anchor classes (Bronze/Silver/Golden). INPUT: kbn-id from Step 1. \
            \ OUTPUT: anchor-ids, boost-class-ids. NEXT: Step 6 boost-class-ids=[Silver Bronze Golden]."
        ;; INPUT
        ;;   kbn-id — from Step 1 output
        ;; OUTPUT (return string)
        ;;   anchor-ids[4]       — OuroborosRain, AurynRain, EliteAurynRain, LegendarySnakeTokenRain
        ;;   boost-class-ids[3]  — emitted ONCE, in Step 6 order: silver, bronze, golden
        ;; NEXT
        ;;   Step 6: paste the bracketed list at the end of the output string directly into the
        ;;           `boost-class-ids` argument. It is already in Step 6 order (silver, bronze,
        ;;           golden) and already quoted. No reordering, no re-quoting.
        ;; REPL: (AQP-BOOT.C_Step2_CreateSnakePowerAnchorClasses KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;Step 2 issues the collection's FIRST four anchors, so the asset's bookkeeping row
            ;;must still be empty. UR_AA|AnchorsActive is a with-default-read, so a collection
            ;;that has never been anchored answers 0 rather than aborting on a missing row.
            (UEV_BootStepState "Step2" "anchors-active on the collection"
                (AQP-ANK.UR_AA|AnchorsActive kbn-id) 0)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    ;;
                    (bronze-boost-class-id:string (ref-U|DALOS::UDC_Makeid "BronzeSnakePower"))
                    (silver-boost-class-id:string (ref-U|DALOS::UDC_Makeid "SilverSnakePower"))
                    (golden-boost-class-id:string (ref-U|DALOS::UDC_Makeid "GoldenSnakePower"))
                    ;;
                    (anchor-ouroboros-rain-id:string (ref-U|DALOS::UDC_Makeid "OuroborosRain"))
                    (anchor-auryn-rain-id:string (ref-U|DALOS::UDC_Makeid "AurynRain"))
                    (anchor-elite-auryn-rain-id:string (ref-U|DALOS::UDC_Makeid "EliteAurynRain"))
                    (anchor-legendary-snake-token-rain-id:string (ref-U|DALOS::UDC_Makeid "LegendarySnakeTokenRain"))
                    ;;The EXECUTOR of an anchor issuance is the ANCHORED ASSET's owner, which is not
                    ;;necessarily the patron paying for it -- sovereign assets are owned by SMART
                    ;;accounts whose key the admin merely holds. Read it, never assume it.
                    (kbn-owner:string (AQP-ANK.URC_AnchorableAssetOwner kbn-id [false false]))
                )
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "OuroborosRain" kbn-id true "BronzeSnakePower" 3 50.0 "Background" "Ouroboros Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "AurynRain" kbn-id true "SilverSnakePower" 3 100.0 "Background" "Auryn Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "EliteAurynRain" kbn-id true "GoldenSnakePower" 3 200.0 "Background" "Elite-Auryn Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendarySnakeTokenRain" kbn-id false golden-boost-class-id 3 400.0 "Rarity" "Legendary")
                ;;OUTPUT SHAPE CHANGED 2026-09-18, for deployment use.
                ;;
                ;;It used to print the three boost classes TWICE, in two different orders: first
                ;;`boost-class-ids=[bronze silver golden]` (creation order) and then
                ;;`NEXT=Step6:[silver bronze golden]` (consumption order). An operator copying the
                ;;first list into Step 6 would wire the 50.0-weight class where the 100.0 belongs,
                ;;and NOTHING WOULD ERROR -- the pools would simply pay the wrong boosts forever.
                ;;
                ;;Now it prints them ONCE, in Step 6's order, as a QUOTED PACT LIST that can be
                ;;pasted straight into the `boost-class-ids` argument with no reordering and no
                ;;re-quoting. A format an operator has to transform is a format that will
                ;;eventually be transformed wrongly.
                ;;
                ;;No test asserts on this string -- both call sites are `print` -- so the change
                ;;breaks nothing. Verified before editing.
                (format "AQP-BOOT Step 2 done. kbn-id={}. anchors issued=[{} {} {} {}]. \
                        \ PASTE INTO Step6 boost-class-ids (silver bronze golden, already ordered): \
                        \ [\"{}\" \"{}\" \"{}\"]"
                    [
                        kbn-id
                        anchor-ouroboros-rain-id anchor-auryn-rain-id
                        anchor-elite-auryn-rain-id anchor-legendary-snake-token-rain-id
                        silver-boost-class-id bronze-boost-class-id golden-boost-class-id
                    ]
                )
            )
        )
    )
    (defun C_Step3_CreateBoosterAnchorClasses:string
        (patron:string kbn-id:string)
        @doc "Step 3 — Unity/Stoa/Vesta booster anchor classes. INPUT: kbn-id from Step 1. \
            \ OUTPUT: anchor-ids, boost-class-ids. NEXT: none required for Steps 4–7 (user ANK boosting)."
        ;; INPUT
        ;;   kbn-id — from Step 1 output
        ;; OUTPUT (return string)
        ;;   anchor-ids[11], boost-class-ids[3] — UnityBooster, StoaBooster, VestaBooster
        ;; REPL: (AQP-BOOT.C_Step3_CreateBoosterAnchorClasses KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;EXACTLY FOUR, not "at least four". Step 2 leaves 4 and Step 3 adds 11, so 4 is the
            ;;only count that means "Step 2 done, Step 3 not" -- it pins the predecessor and the
            ;;re-run in one check. A >= would admit a second run of Step 3 at 15.
            (UEV_BootStepState "Step3" "anchors-active on the collection"
                (AQP-ANK.UR_AA|AnchorsActive kbn-id) 4)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    ;;
                    (unity-boost-class-id:string (ref-U|DALOS::UDC_Makeid "UnityBooster"))
                    (stoa-boost-class-id:string (ref-U|DALOS::UDC_Makeid "StoaBooster"))
                    (vesta-boost-class-id:string (ref-U|DALOS::UDC_Makeid "VestaBooster"))
                    ;;
                    (anchor-elk0nite-id:string (ref-U|DALOS::UDC_Makeid "Elk0nite"))
                    (anchor-osmiridium-id:string (ref-U|DALOS::UDC_Makeid "Osmiridium"))
                    (anchor-titanium-id:string (ref-U|DALOS::UDC_Makeid "Titanium"))
                    (anchor-legendary-unity-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryUnityBooster"))
                    (anchor-vegold-eyes-id:string (ref-U|DALOS::UDC_Makeid "VegoldEyes"))
                    (anchor-legendary-stoa-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryStoaBooster"))
                    (anchor-red-eyes-id:string (ref-U|DALOS::UDC_Makeid "RedEyes"))
                    (anchor-green-eyes-id:string (ref-U|DALOS::UDC_Makeid "GreenEyes"))
                    (anchor-blue-eyes-id:string (ref-U|DALOS::UDC_Makeid "BlueEyes"))
                    (anchor-legendary-vesta-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryVestaBooster"))
                    (anchor-rgb-eyes-id:string (ref-U|DALOS::UDC_Makeid "RGBEyes"))
                    ;;Anchor executor = the anchored asset's owner, read not assumed.
                    (kbn-owner:string (AQP-ANK.URC_AnchorableAssetOwner kbn-id [false false]))
                )
                ;; Unity
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "Elk0nite" kbn-id true "UnityBooster" 3 100.0 "Eyes" "Elk0nite Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "Osmiridium" kbn-id false unity-boost-class-id 3 300.0 "Eyes" "Osmiridium Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "Titanium" kbn-id false unity-boost-class-id 3 900.0 "Eyes" "Titaniumgold Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendaryUnityBooster" kbn-id false unity-boost-class-id 3 1000.0 "Rarity" "Legendary")
                ;; Stoa
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "VegoldEyes" kbn-id true "StoaBooster" 3 1000.0 "Eyes" "vEGLD Focus")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendaryStoaBooster" kbn-id false stoa-boost-class-id 3 3500.0 "Rarity" "Legendary")
                ;; Vesta
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "RedEyes" kbn-id true "VestaBooster" 3 250.0 "Eyes" "Red")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "GreenEyes" kbn-id false vesta-boost-class-id 3 250.0 "Eyes" "Green")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "BlueEyes" kbn-id false vesta-boost-class-id 3 250.0 "Eyes" "Blue")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendaryVestaBooster" kbn-id false vesta-boost-class-id 3 3500.0 "Rarity" "Legendary")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleSetAnchor patron kbn-owner "RGBEyes" kbn-id false vesta-boost-class-id 3 1000.0 1)
                (format "AQP-BOOT Step 3 done. kbn-id={}. anchor-ids=[{} {} {} {} {} {} {} {} {} {} {}]. boost-class-ids=[unity={} stoa={} vesta={}]. NEXT=none-for-Steps4-7."
                    [
                        kbn-id
                        anchor-elk0nite-id anchor-osmiridium-id anchor-titanium-id anchor-legendary-unity-booster-id
                        anchor-vegold-eyes-id anchor-legendary-stoa-booster-id
                        anchor-red-eyes-id anchor-green-eyes-id anchor-blue-eyes-id anchor-legendary-vesta-booster-id anchor-rgb-eyes-id
                        unity-boost-class-id stoa-boost-class-id vesta-boost-class-id
                    ]
                )
            )
        )
    )
    (defun C_Step4_CreateCoreScores:string
        (patron:string owner-konto:string)
        @doc "Step 4 — Core scores (SF/NF). OUTPUT: score-ids ×4. NEXT: Step7 dh-score-ids slots 0,2,4,5."
        ;; INPUT
        ;;   patron, owner-konto — score owner (REPL: KST.ANHD for both)
        ;; OUTPUT (return string) — score-ids (UDC_Makeid names):
        ;;   TheCodingDivision, Bloodshed, DemiourgosShareholder, DemiourgosSnakes
        ;; NEXT Step 7 dh-score-ids[0,2,4,5] = these four ids (see README_AQP_BOOT.md index map)
        ;; REPL: (AQP-BOOT.C_Step4_CreateCoreScores KST.ANHD KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    (score-coding:string (ref-U|DALOS::UDC_Makeid "TheCodingDivision"))
                    (score-bloodshed:string (ref-U|DALOS::UDC_Makeid "Bloodshed"))
                    (score-company-share:string (ref-U|DALOS::UDC_Makeid "DemiourgosShareholder"))
                    (score-company-snakes:string (ref-U|DALOS::UDC_Makeid "DemiourgosSnakes"))
                )
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "TheCodingDivision" 3 false)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "Bloodshed" 6 0)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "DemiourgosShareholder" 6 true)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "DemiourgosSnakes" 6 false)
                (format "AQP-BOOT Step 4 done. score-ids=[coding={} bloodshed={} company-share={} company-snakes={}]. NEXT=Step7:dh-score-ids[0,2,4,5]=[{} {} {} {}]."
                    [
                        score-coding score-bloodshed score-company-share score-company-snakes
                        score-coding score-bloodshed score-company-share score-company-snakes
                    ]
                )
            )
        )
    )
    (defun C_Step5_CreateSubsidiaryScores:string
        (patron:string owner-konto:string)
        @doc "Step 5 — Subsidiary scores. OUTPUT: score-ids ×5. NEXT: Step7 dh-score-ids slots 1,3,6,7,8."
        ;; INPUT
        ;;   patron, owner-konto — score owner (REPL: KST.ANHD for both)
        ;; OUTPUT (return string) — score-ids:
        ;;   SubsidiaryCodingDivision, SubsidiaryWonderCoach, SubsidiaryBloodshed, SubsidiaryNosferatu, SubsidiaryBunnies
        ;; NEXT Step 7 dh-score-ids[1,3,6,7,8] = these five ids
        ;; REPL: (AQP-BOOT.C_Step5_CreateSubsidiaryScores KST.ANHD KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    (score-sub-coding:string (ref-U|DALOS::UDC_Makeid "SubsidiaryCodingDivision"))
                    (score-sub-wondercoach:string (ref-U|DALOS::UDC_Makeid "SubsidiaryWonderCoach"))
                    (score-sub-bloodshed:string (ref-U|DALOS::UDC_Makeid "SubsidiaryBloodshed"))
                    (score-sub-nosferatu:string (ref-U|DALOS::UDC_Makeid "SubsidiaryNosferatu"))
                    (score-sub-bunnies:string (ref-U|DALOS::UDC_Makeid "SubsidiaryBunnies"))
                )
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "SubsidiaryCodingDivision" 6 true)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "SubsidiaryWonderCoach" 6 false)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryBloodshed" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryNosferatu" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryBunnies" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-coding)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-wondercoach)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-bloodshed)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-nosferatu)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-bunnies)
                ;;ORDERING BUG FIXED 2026-09-18. The `NEXT=Step7:dh-score-ids[1,3,6,7,8]` list used
                ;;to be emitted in CREATION order -- coding, wondercoach, bloodshed, nosferatu,
                ;;bunnies -- while slots [1,3,6,7,8] are coding, BLOODSHED, WONDERCOACH, nosferatu,
                ;;bunnies. Positions 2 and 3 were transposed against the slots the same string
                ;;names. An operator pasting it into Step 7 would put SubsidiaryWonderCoach in slot
                ;;3 and SubsidiaryBloodshed in slot 6, so DHBloodshed would carry the WonderCoach
                ;;subsidiary score and DHWonderCoach the Bloodshed one -- PERMANENTLY, and WITHOUT
                ;;ERRORING, because both are valid score ids.
                ;;Now emitted in slot order, and as a quoted pasteable list. Same defect class as
                ;;Step 2's boost-class ordering, fixed the same day.
                (format "AQP-BOOT Step 5 done. score-ids=[sub-coding={} sub-wondercoach={} sub-bloodshed={} sub-nosferatu={} sub-bunnies={}] deb-boost=enabled×5. \
                        \ PASTE INTO Step7 dh-score-ids slots [1,3,6,7,8] IN THIS ORDER: \
                        \ [\"{}\" \"{}\" \"{}\" \"{}\" \"{}\"]"
                    [
                        score-sub-coding score-sub-wondercoach score-sub-bloodshed score-sub-nosferatu score-sub-bunnies
                        score-sub-coding score-sub-bloodshed score-sub-wondercoach score-sub-nosferatu score-sub-bunnies
                    ]
                )
            )
        )
    )
    (defun C_Step6_CreateOuroLpTriplet:string
        (patron:string owner-konto:string lp-denominator:string boost-class-ids:[string])
        @doc "Step 6 — Issue OURO LP triplet **scores only** (Silver/Bronze/Golden class-0). \
            \ Does not create a pool or farm links — wire those in Step 7 (first LP) or manually per new LP line."
        ;;
        ;; WHAT THIS STEP DOES (scores only — no pool, no FVT)
        ;; Creates three class-0 liquidity scores sharing one lp-denominator (full OURO DPTF id):
        ;;   SilverSnakePower  — primary; owns user base-score for the triplet boost chain
        ;;   BronzeSnakePower  — foreign boost-link → Silver
        ;;   GoldenSnakePower  — foreign boost-link → Silver
        ;; Each score also gets a boost-class-link from Step 2 anchor classes.
        ;;
        ;; lp-denominator — full native DPTF id of the OURO pool leg (NOT ticker "OURO"):
        ;;   REPL example: "OURO-98c486052a51"
        ;;   Must match the Farm FVT common-denominator when scores are later admitted to a farm.
        ;;
        ;; boost-class-ids[0..2] — from Step 2 (SnakePower anchor classes).
        ;;
        ;; !! MAINNET: PASTE THESE FROM STEP 2's OUTPUT. DO NOT RECOMPUTE THEM.
        ;; The `UDC_Makeid` forms shown below are the REPL shape, and they are correct ONLY when
        ;; Step 2 ran in the same block -- which is true in the REPL (one prev-block-hash for the
        ;; whole suite) and false on mainnet, where Step 2 is its own transaction. Recomputing here
        ;; yields three ids that do not exist, the triplet wires to nothing, and no test can catch
        ;; it. Step 2's output ends with a ready-to-paste `["silver" "bronze" "golden"]` list for
        ;; exactly this argument.
        ;;
        ;;   0 silver-boost-class-id  e.g. (U|DALOS.UDC_Makeid "SilverSnakePower")
        ;;   1 bronze-boost-class-id  e.g. (U|DALOS.UDC_Makeid "BronzeSnakePower")
        ;;   2 golden-boost-class-id  e.g. (U|DALOS.UDC_Makeid "GoldenSnakePower")
        ;;
        ;; Score ids created (fixed names — first OURO LP line only):
        ;;   (U|DALOS.UDC_Makeid "SilverSnakePower")
        ;;   (U|DALOS.UDC_Makeid "BronzeSnakePower")
        ;;   (U|DALOS.UDC_Makeid "GoldenSnakePower")
        ;;
        ;; AFTER Step 6 — per LP line (full flow: README.md § OURO LP onboarding flow):
        ;;   1. C_Issue class-0 pool (DHOuroLp) with native LP asset-id  ← Step 7
        ;;   2. C_AddScore × 3 — employ triplet on that pool              ← Step 7
        ;;   3. Users stake LP into pool → SCORE user rows update
        ;;   4. C_AddScoreEntity (type 3) on shared Farm FVT                     ← Step 11
        ;;   5. C_AddRewardLink (OURO, multiplet-family-id) on farm    ← Step 11
        ;;
        ;; SECOND OURO LP: repeat score issuance with **new score names** (cannot reuse ids),
        ;; then new pool + C_AddScore × 3 + C_IssueTriplet + C_AddScoreEntity (type 3) on the same farm.
        ;;
        ;; REPL call (after Steps 2–3 anchor classes exist):
        ;; (AQP-BOOT.C_Step6_CreateOuroLpTriplet
        ;;   KST.ANHD
        ;;   KST.ANHD
        ;;   "OURO-98c486052a51"
        ;;   [(U|DALOS.UDC_Makeid "SilverSnakePower") (U|DALOS.UDC_Makeid "BronzeSnakePower") (U|DALOS.UDC_Makeid "GoldenSnakePower")]
        ;; )
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;FIXED 2026-09-12: the LENGTH check is enforced HERE, above the binding group.
            ;;It used to sit BELOW a `let` that already did `(at 0 boost-class-ids)`, `(at 1 …)` and
            ;;`(at 2 …)`. A `let` is EAGER, so for a SHORT list those indexes ran first and the
            ;;operator got `Array index out of bounds` instead of the sentence naming the argument.
            ;;The message only ever arrived for a list that was too LONG -- the one case the `at`s
            ;;survive. C_Step9 in this same file is the correctly-ordered twin, so the fix was
            ;;demonstrated in place. A length test needs nothing but the parameter, so it can run
            ;;before anything is derived. Pinned by REPL/modules/DPDC.repl <<DPDC-G10>>.
            (enforce (= (length boost-class-ids) 3) "Step 6 expects boost-class-ids=[silver bronze golden].")
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    ;;
                    (silver-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_SILVER))
                    (bronze-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_BRONZE))
                    (golden-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_GOLDEN))
                    ;;
                    (silver-boost-class-id:string (at 0 boost-class-ids))
                    (bronze-boost-class-id:string (at 1 boost-class-ids))
                    (golden-boost-class-id:string (at 2 boost-class-ids))
                )
                ;; [1..2] Silver
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_SILVER BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron owner-konto silver-id silver-boost-class-id)
                ;; [3..5] Bronze
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_BRONZE BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron owner-konto bronze-id bronze-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostLink patron owner-konto bronze-id silver-id)
                ;; [6..8] Golden
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_GOLDEN BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron owner-konto golden-id golden-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostLink patron owner-konto golden-id silver-id)
                ;;
                (format "AQP-BOOT Step 6 done. lp-denominator={}. score-ids=[silver={} bronze={} golden={}]. \
                        \ boost-class-ids-IN=[{} {} {}]. boost-links=[{}->{} {}->{}]. \
                        \ PASTE INTO Step7 ouro-triplet-score-ids (these are the SCORES made here, \
                        \ NOT the Step 2 boost classes of the same name): [\"{}\" \"{}\" \"{}\"]."
                    [
                        lp-denominator
                        silver-id bronze-id golden-id
                        silver-boost-class-id bronze-boost-class-id golden-boost-class-id
                        bronze-id silver-id golden-id silver-id
                        silver-id bronze-id golden-id
                    ]
                )
            )
        )
    )
    (defun C_Step7_CreatePoolsAndScores:string
        (patron:string dh-asset-ids:[string] ouro-lp-asset-id:string dh-score-ids:[string] ouro-triplet-score-ids:[string])
        @doc "Step 7 — Issue six DH pools (class 3 or 4 by entity) plus one class-0 OURO LP pool and assign existing scores. \
            \ All ids are caller-supplied so this step can run after Steps 4–6 in separate transactions. \
            \ Pool aqp-class is fixed per entity (see ;; block). This step does not create FVT links."
        ;;
        ;; POOL MAP (aqp-class is fixed in code — pass the matching native collection id in dh-asset-ids)
        ;; | Pool name         | aqp-class | pass in dh-asset-ids     | Scores attached                                         |
        ;; | DHCodingDivision  | 3 DPSF    | DHCD-… dpsf-id           | TheCodingDivision, SubsidiaryCodingDivision             |
        ;; | DHBloodshed       | 4 DPNF    | DHB-… dpnf-id            | Bloodshed, SubsidiaryBloodshed                          |
        ;; | DHCompany         | 3 DPSF    | E|DH-… dpsf-id           | DemiourgosShareholder, DemiourgosSnakes                 |
        ;; | DHWonderCoach     | 3 DPSF    | DHWC-… dpsf-id           | SubsidiaryWonderCoach                                   |
        ;; | DHNosferatu       | 4 DPNF    | DHN-… dpnf-id            | SubsidiaryNosferatu                                     |
        ;; | DHBunnies         | 4 DPNF    | KBN-… dpnf-id            | SubsidiaryBunnies                                       |
        ;; | DHOuroLp          | 0 LP      | native LP id             | SilverSnakePower, BronzeSnakePower, GoldenSnakePower    |
        ;;
        ;; dh-asset-ids[0..5] — REPL examples (replace suffix with mainnet hash):
        ;;   0 "DHCD-98c486052a51"
        ;;   1 "DHB-98c486052a51"
        ;;   2 "E|DH-98c486052a51"
        ;;   3 "DHWC-98c486052a51"
        ;;   4 "DHN-98c486052a51"
        ;;   5 "KBN-98c486052a51"
        ;; ouro-lp-asset-id — e.g. "W|SSTOA-OURO-WSTOA|LP-98c486052a51"
        ;;
        ;; dh-pool-ids[0..5]:
        ;;   [(U|DALOS.UDC_Makeid "DHCodingDivision") (U|DALOS.UDC_Makeid "DHBloodshed") (U|DALOS.UDC_Makeid "DHCompany")
        ;;    (U|DALOS.UDC_Makeid "DHWonderCoach") (U|DALOS.UDC_Makeid "DHNosferatu") (U|DALOS.UDC_Makeid "DHBunnies")]
        ;; ouro-lp-pool-id — (U|DALOS.UDC_Makeid "DHOuroLp")
        ;;
        ;; !! MAINNET, AND THE TWO HALVES OF THIS STEP BEHAVE DIFFERENTLY:
        ;;
        ;;   dh-pool-ids / ouro-lp-pool-id  -- SAFE to recompute with UDC_Makeid. This step CREATES
        ;;      those pools, in this transaction, so the id it derives is the id it makes. The
        ;;      `UDC_Makeid "DHCodingDivision"` forms above are correct on mainnet.
        ;;
        ;;   dh-score-ids / ouro-triplet-score-ids  -- MUST BE PASTED FROM EARLIER OUTPUTS. The
        ;;      nine scores are created in Steps 4 and 5, the three triplet scores in Step 2, all
        ;;      in their own transactions and therefore their own blocks. The `UDC_Makeid` forms
        ;;      below are the REPL shape and are WRONG on mainnet. They look right, they typecheck,
        ;;      and the suite passes -- because the REPL runs every step under one prev-block-hash.
        ;;      Take these ids from the return strings of Steps 2, 4 and 5.
        ;;
        ;; dh-score-ids[0..8] — from Steps 4–5 (REPL shape below; on mainnet paste from output):
        ;;   [TheCodingDivision SubsidiaryCodingDivision Bloodshed SubsidiaryBloodshed
        ;;    DemiourgosShareholder DemiourgosSnakes SubsidiaryWonderCoach SubsidiaryNosferatu SubsidiaryBunnies]
        ;; ouro-triplet-score-ids[0..2] — from Step 6:
        ;;   [SilverSnakePower BronzeSnakePower GoldenSnakePower]
        ;;
        ;; REPL call (copy/paste; swap ids for mainnet):
        ;; (AQP-BOOT.C_Step7_CreatePoolsAndScores
        ;;   KST.ANHD
        ;;   ["DHCD-98c486052a51" "DHB-98c486052a51" "E|DH-98c486052a51" "DHWC-98c486052a51" "DHN-98c486052a51" "KBN-98c486052a51"]
        ;;   "W|SSTOA-OURO-WSTOA|LP-98c486052a51"
        ;;   [(U|DALOS.UDC_Makeid "DHCodingDivision") (U|DALOS.UDC_Makeid "DHBloodshed") (U|DALOS.UDC_Makeid "DHCompany")
        ;;    (U|DALOS.UDC_Makeid "DHWonderCoach") (U|DALOS.UDC_Makeid "DHNosferatu") (U|DALOS.UDC_Makeid "DHBunnies")]
        ;;   (U|DALOS.UDC_Makeid "DHOuroLp")
        ;;   [(U|DALOS.UDC_Makeid "TheCodingDivision") (U|DALOS.UDC_Makeid "SubsidiaryCodingDivision")
        ;;    (U|DALOS.UDC_Makeid "Bloodshed") (U|DALOS.UDC_Makeid "SubsidiaryBloodshed")
        ;;    (U|DALOS.UDC_Makeid "DemiourgosShareholder") (U|DALOS.UDC_Makeid "DemiourgosSnakes")
        ;;    (U|DALOS.UDC_Makeid "SubsidiaryWonderCoach") (U|DALOS.UDC_Makeid "SubsidiaryNosferatu") (U|DALOS.UDC_Makeid "SubsidiaryBunnies")]
        ;;   [(U|DALOS.UDC_Makeid "SilverSnakePower") (U|DALOS.UDC_Makeid "BronzeSnakePower") (U|DALOS.UDC_Makeid "GoldenSnakePower")]
        ;; )
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;FIXED 2026-09-12: all FOUR length checks are enforced HERE, above the binding group.
            ;;They used to sit BELOW a `let` that indexes every one of these lists -- (at 0 dh-score-ids)
            ;;through (at 8 dh-score-ids), and so on. A `let` is EAGER, so for any list that was too
            ;;SHORT the indexes ran first and the operator got `Array index out of bounds` instead of
            ;;the sentence naming which argument was wrong. Six operator-facing messages in this file
            ;;arrived only when a list was too LONG -- the one case the `at`s survive.
            ;;C_Step9 in this same file is the correctly-ordered twin. Length tests need nothing but
            ;;the parameters, so they run before anything is derived.
            ;;Pinned by REPL/modules/DPDC.repl <<DPDC-G10>>.
                (enforce (= (length dh-asset-ids) 6) "Step 7 expects dh-asset-ids=[coding bloodshed company wondercoach nosferatu bunnies].")
                (enforce (= (length dh-score-ids) 9) "Step 7 expects dh-score-ids=[coding sub-coding bloodshed sub-bloodshed company-share company-snakes sub-wondercoach sub-nosferatu sub-bunnies].")
                (enforce (= (length ouro-triplet-score-ids) 3) "Step 7 expects ouro-triplet-score-ids=[silver bronze golden].")
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    ;;
                    (asset-coding:string (at 0 dh-asset-ids))
                    (asset-coding-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 3 asset-coding))
                    (asset-bloodshed:string (at 1 dh-asset-ids))
                    (asset-bloodshed-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 4 asset-bloodshed))
                    (asset-company:string (at 2 dh-asset-ids))
                    (asset-company-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 3 asset-company))
                    (asset-wondercoach:string (at 3 dh-asset-ids))
                    (asset-wondercoach-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 3 asset-wondercoach))
                    (asset-nosferatu:string (at 4 dh-asset-ids))
                    (asset-nosferatu-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 4 asset-nosferatu))
                    (asset-bunnies:string (at 5 dh-asset-ids))
                    (asset-bunnies-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 4 asset-bunnies))
                    ;;
                    ;;POOL IDS ARE DERIVED HERE, NOT PASSED IN. Changed 2026-09-18.
                    ;;They used to be two arguments -- `dh-pool-ids` (6) and `ouro-lp-pool-id` --
                    ;;which the caller had to supply. But this step MINTS these seven pools, from
                    ;;the very name literals used in the C_Issue calls below, in this transaction.
                    ;;`UDC_Makeid` on the same literal in the same transaction therefore returns
                    ;;exactly the id C_Issue is about to create. Passing them in could only ever
                    ;;match or be wrong; it could never be MORE right.
                    ;;
                    ;;Removing them takes seven values off the caller, removes one of the four
                    ;;length guards, and removes an entire class of operator error on mainnet.
                    ;;What remains as arguments is precisely what this step CANNOT know: the six
                    ;;live collection assets, and the twelve scores created in earlier blocks.
                    (pool-coding:string (ref-U|DALOS::UDC_Makeid "DHCodingDivision"))
                    (pool-coding-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-coding))
                    (pool-bloodshed:string (ref-U|DALOS::UDC_Makeid "DHBloodshed"))
                    (pool-bloodshed-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-bloodshed))
                    (pool-company:string (ref-U|DALOS::UDC_Makeid "DHCompany"))
                    (pool-company-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-company))
                    (pool-wondercoach:string (ref-U|DALOS::UDC_Makeid "DHWonderCoach"))
                    (pool-wondercoach-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-wondercoach))
                    (pool-nosferatu:string (ref-U|DALOS::UDC_Makeid "DHNosferatu"))
                    (pool-nosferatu-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-nosferatu))
                    (pool-bunnies:string (ref-U|DALOS::UDC_Makeid "DHBunnies"))
                    (pool-bunnies-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-bunnies))
                    (pool-ouro-lp:string (ref-U|DALOS::UDC_Makeid "DHOuroLp"))
                    (pool-ouro-lp-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-ouro-lp))
                    ;;
                    (score-coding:string (at 0 dh-score-ids))
                    (score-sub-coding:string (at 1 dh-score-ids))
                    (score-bloodshed:string (at 2 dh-score-ids))
                    (score-sub-bloodshed:string (at 3 dh-score-ids))
                    (score-company-share:string (at 4 dh-score-ids))
                    (score-company-snakes:string (at 5 dh-score-ids))
                    (score-sub-wondercoach:string (at 6 dh-score-ids))
                    (score-sub-nosferatu:string (at 7 dh-score-ids))
                    (score-sub-bunnies:string (at 8 dh-score-ids))
                    (score-silver:string (at 0 ouro-triplet-score-ids))
                    (score-bronze:string (at 1 ouro-triplet-score-ids))
                    (score-golden:string (at 2 ouro-triplet-score-ids))
                    ;;The LP pool's executor is the LP token's owner konto -- read, not assumed.
                    (ouro-lp-asset-owner:string
                        (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 0 ouro-lp-asset-id))
                )
                ;;
                ;; [1] DHCodingDivision — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-coding-owner "DHCodingDivision" asset-coding 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-coding-owner pool-coding score-coding)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-coding-owner pool-coding score-sub-coding)
                ;; [2] DHBloodshed — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-bloodshed-owner "DHBloodshed" asset-bloodshed 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bloodshed-owner pool-bloodshed score-bloodshed)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bloodshed-owner pool-bloodshed score-sub-bloodshed)
                ;; [3] DHCompany — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-company-owner "DHCompany" asset-company 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-company-owner pool-company score-company-share)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-company-owner pool-company score-company-snakes)
                ;; [4] DHWonderCoach — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-wondercoach-owner "DHWonderCoach" asset-wondercoach 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-wondercoach-owner pool-wondercoach score-sub-wondercoach)
                ;; [5] DHNosferatu — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-nosferatu-owner "DHNosferatu" asset-nosferatu 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-nosferatu-owner pool-nosferatu score-sub-nosferatu)
                ;; [6] DHBunnies — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-bunnies-owner "DHBunnies" asset-bunnies 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bunnies-owner pool-bunnies score-sub-bunnies)
                ;; [7] DHOuroLp — aqp-class 0 (LP); triplet from Step 6 — see Step 6 ;; for OURO LP flow
                (ref-TS02-C3::AQP-POOL|C_Issue patron ouro-lp-asset-owner "DHOuroLp" ouro-lp-asset-id 0)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp-owner pool-ouro-lp score-silver)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp-owner pool-ouro-lp score-bronze)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp-owner pool-ouro-lp score-golden)
                ;;
                (format "AQP-BOOT Step 7 done. pool-ids=[coding={} bloodshed={} company={} wondercoach={} nosferatu={} bunnies={} ouro-lp={}]. ouro-lp-asset-id={}. score-slots-wired=12. NEXT=Step8:C_Step8_IssueFvtEntities."
                    [
                        pool-coding pool-bloodshed pool-company pool-wondercoach pool-nosferatu pool-bunnies pool-ouro-lp
                        ouro-lp-asset-id
                    ]
                )
            )
        )
    )
    (defun C_Step8_IssueFvtEntities:string
        (patron:string owner-konto:string lp-denominator:string)
        @doc "Step 8 — Issue five production FVT entities (C_Issue only). \
            \ OuroLpFarm class 0 when lp-denominator non-empty (same OURO DPTF id as Step 6). \
            \ Four class-1 vault treasuries with common-denominator '|'. \
            \ Product names say Treasury; they are issued at fvt-class 1. \
            \ !! 2026-09-19: TWO SOVEREIGN ADMISSION RULES DISAGREE ABOUT WHAT CLASS 1 MEANS. \
            \ URC_ScoreClassMatchesFvtClass (05_FVT.pact) says vault(1) admits score-class 1/3/4 \
            \ = TF/SF/NF and treasury(2) admits 2 = OF. URC_TripletCategoryMatchesFvtClass \
            \ (02_SCORE.pact) says VAULT_TF<->1 and TREASURY_SF_NF<->2, i.e. vault = TF only and \
            \ treasury = SF/NF. The schema comment at 05_FVT.pact:580 reads 0=Farm 1=Vault \
            \ 2=Treasury. Owner intent (2026-09-19): vaults take TF and OF, treasuries take SF \
            \ and NF -- which the TRIPLET rule matches and the SCORE rule does not. \
            \ This step issues four entities NAMED Treasury at class 1, and Step 9 links SF/NF \
            \ subsidiary scores to them; that passes only because the score rule permits 3/4 at \
            \ class 1. UNRESOLVED -- do not treat either rule as authoritative until ruled on. \
            \ NEXT=Step9 vault score links, Steps 10–11 farm triplet — pass fvt-ids from this output."
        ;;
        ;; INPUT
        ;;   patron, owner-konto — FVT owner (REPL: KST.ANHD)
        ;;   lp-denominator — full OURO DPTF id for OuroLpFarm; pass \"\" to skip farm (vault-only bootstrap)
        ;; OUTPUT — fvt-ids ×6 (farm skipped → echo farm=skipped)
        ;; REPL: see 2_CITIZEN/Stage_02/README_AQP_BOOT.md § Steps 8–12
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    (farm-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_OURO_LP_FARM))
                    (sub-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SUBSIDIARY_TREASURY))
                    (coding-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_CODING_TREASURY))
                    (snakes-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SNAKES_TREASURY))
                    (shares-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SHARES_TREASURY))
                    (bloodshed-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_BLOODSHED_TREASURY))
                )
                (if (!= lp-denominator "")
                    (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_OURO_LP_FARM 0 lp-denominator)
                    true
                )
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_SUBSIDIARY_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_CODING_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_SNAKES_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_SHARES_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_BLOODSHED_TREASURY 2 BOOT|TREASURY_COMMON)
                (format "AQP-BOOT Step 8 done. fvt-ids=[farm={} sub-treasury={} coding-treasury={} snakes-treasury={} shares-treasury={} bloodshed-treasury={}]. NEXT=Step9:C_AddScoreEntity."
                    [
                        (if (!= lp-denominator "") farm-id "skipped")
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                        bloodshed-treasury-id
                    ]
                )
            )
        )
    )
    (defun C_Step9_AddFvtScoreEntities:string
        (patron:string sub-treasury-id:string coding-treasury-id:string snakes-treasury-id:string shares-treasury-id:string bloodshed-treasury-id:string subsidiary-score-ids:[string] coding-score-id:string snakes-score-id:string shares-score-id:string bloodshed-score-id:string)
        @doc "Step 9 — Admit score entities (type 1) on vault/treasury FVT entities only. \
            \ SubsidiaryTreasury: five subsidiary scores. \
            \ CodingDivisionTreasury: TheCodingDivision. SnakesTreasury: DemiourgosSnakes. \
            \ CompanySharesTreasury: DemiourgosShareholder. BloodshedTreasury: Bloodshed \
            \ (the PURE score from Step 4, not the subsidiary -- that one is in the five). \
            \ Farm OURO LP triplet is wired in Step 11."
        ;;
        ;; INPUT — fvt-ids from Step 8 output; score ids from Steps 4–5
        ;; REPL: see 2_CITIZEN/Stage_02/README_AQP_BOOT.md § Steps 8–12
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                )
                (enforce (= (length subsidiary-score-ids) 5) "Step 9 expects subsidiary-score-ids×5.")
                (map
                    (lambda (score-id:string)
                        (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto sub-treasury-id) sub-treasury-id BOOT|SCORE_ENTITY_SCORE score-id)
                    )
                    subsidiary-score-ids
                )
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto coding-treasury-id) coding-treasury-id BOOT|SCORE_ENTITY_SCORE coding-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto snakes-treasury-id) snakes-treasury-id BOOT|SCORE_ENTITY_SCORE snakes-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto shares-treasury-id) shares-treasury-id BOOT|SCORE_ENTITY_SCORE shares-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto bloodshed-treasury-id) bloodshed-treasury-id BOOT|SCORE_ENTITY_SCORE bloodshed-score-id)
                (format "AQP-BOOT Step 9 done. score-entities=[sub=5 coding=1 snakes=1 shares=1]. fvt-ids=[sub-treasury={} coding-treasury={} snakes-treasury={} shares-treasury={}]. NEXT=Step10:C_IssueMultipletFamily."
                    [
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                    ]
                )
            )
        )
    )
    (defun C_Step10_IssueMultipletFamily:string
        (patron:string ouro-id:string auryn-id:string elite-auryn-id:string ats-0-1-id:string ats-1-2-id:string)
        @doc "Step 10 — Issue chain-wide MultipletFamily (rank 3) for OURO→Auryn→Elite-Auryn Coil/Curl ladder. \
            \ INPUT: live DPTF ids + ATS pair ids (token-0 RT on ats-0-1; token-1 RBT/RT; token-2 RBT)."
        ;;
        ;; family-id = F|ouro-id|auryn-id|elite-auryn-id (deterministic — pass to Step 11)
        ;; REPL: ouro-id, auryn-id, elite-auryn-id from DALOS; ats ids from deployed ATS pairs
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    (family-id:string (concat ["F" "|" ouro-id "|" auryn-id "|" elite-auryn-id]))
                )
                (ref-TS02-C3::AQP-FVT|C_IssueMultipletFamily
                    patron patron ouro-id auryn-id elite-auryn-id ats-0-1-id ats-1-2-id
                )
                (format "AQP-BOOT Step 10 done. multiplet-family-id={}. tokens=[ouro={} auryn={} elite={}] ats=[{} {}]. NEXT=Step11:C_IssueTriplet+AddScoreEntity."
                    [family-id ouro-id auryn-id elite-auryn-id ats-0-1-id ats-1-2-id]
                )
            )
        )
    )
    (defun C_Step11_WireFarmTriplet:string
        (patron:string farm-id:string bronze-score-id:string silver-score-id:string golden-score-id:string ouro-id:string multiplet-family-id:string)
        @doc "Step 11 — Issue triplet bundle, admit to OuroLpFarm (type 3), register OURO MULTIPLET_BASE reward. \
            \ Skip when farm-id empty or 'skipped'. INPUT: score ids from Step 6; family id from Step 10 echo."
        ;;
        ;; triplet-id = T|bronze|silver|golden (deterministic from score ids)
        ;; REPL: farm-id from Step 8; ouro-id = lp-denominator; multiplet-family-id from Step 10
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    (wire-farm:bool
                        (and
                            (!= farm-id "")
                            (!= farm-id "skipped")
                        )
                    )
                    (triplet-id:string (concat ["T" "|" bronze-score-id "|" silver-score-id "|" golden-score-id]))
                )
                (if wire-farm
                    (do
                        (ref-TS02-C3::AQP-SCR|C_IssueTriplet patron patron bronze-score-id silver-score-id golden-score-id)
                        (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto farm-id) farm-id BOOT|SCORE_ENTITY_TRIPLET triplet-id)
                        (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto farm-id) farm-id ouro-id false multiplet-family-id)
                    )
                    true
                )
                (format "AQP-BOOT Step 11 done. farm={} triplet-id={} multiplet-family-id={} ouro-reward={}. NEXT=Step12:C_AddRewardLink."
                    [
                        (if wire-farm farm-id "skipped")
                        (if wire-farm triplet-id "skipped")
                        (if wire-farm multiplet-family-id "skipped")
                        (if wire-farm ouro-id "skipped")
                    ]
                )
            )
        )
    )
    (defun C_Step12_AddFvtRewardLinks:string
        (patron:string sub-treasury-id:string coding-treasury-id:string snakes-treasury-id:string shares-treasury-id:string bloodshed-treasury-id:string reward-auryn-id:string reward-ouroboros-id:string reward-wstoa-id:string)
        @doc "Step 12 — Register reward tokens on treasury FVT entities via C_AddRewardLink (multiplet-family-id BAR). \
            \ SubsidiaryTreasury, SnakesTreasury → Auryn. CodingDivisionTreasury → Wstoa. \
            \ CompanySharesTreasury → Ouroboros. BloodshedTreasury → Auryn AND Wstoa (the only \
            \ multi-reward FVT here). Farm OURO + family is Step 11."
        ;;
        ;; INPUT — fvt-ids from Step 8; reward DPTF ids from live chain
        ;; REPL: AURYN-98c486052a51, DALOS::UR_OuroborosID, DALOS::UR_WrappedStoaID
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    (ref-U|CT:module{OuronetConstantsV2} U|CT)
                    (bar:string (ref-U|CT::CT_BAR))
                )
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto sub-treasury-id) sub-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto coding-treasury-id) coding-treasury-id reward-wstoa-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto snakes-treasury-id) snakes-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto shares-treasury-id) shares-treasury-id reward-ouroboros-id false bar)
                ;;BloodshedTreasury earns TWO tokens -- owner ruling 2026-09-19: "add wstoa and
                ;;auryn for now on the pure bloodshed score vault". It is the only FVT here with
                ;;more than one reward; the other four take a single token each.
                ;;
                ;;This is supported by construction, not a workaround: FVT|T|RPS|Global is keyed
                ;;`fvt-id | dptf-id` (RPS::UCk_RpsGlobal), so reward state is per (FVT, token) and
                ;;UR_FVT|EnabledRewardCount exists to count them. Two links are two rows.
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto bloodshed-treasury-id) bloodshed-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto bloodshed-treasury-id) bloodshed-treasury-id reward-wstoa-id false bar)
                ;;LABELLING FIXED 2026-09-18. This read
                ;;  reward-links=[sub={} coding={} snakes={} shares={}]
                ;;fed with the REWARD TOKEN ids, so `sub=<auryn-id>` looked like it was naming the
                ;;sub-treasury when it was naming what the sub-treasury was linked TO -- and the
                ;;same three reward ids were then printed again under `rewards=`. Arity was always
                ;;correct; the labels were not, and the treasury ids the links actually attach to
                ;;did not appear at all. Now each link is printed as the PAIR it is.
                (format "AQP-BOOT Step 12 done. reward-links=[{}<-auryn {}<-wstoa {}<-auryn {}<-ouroboros {}<-auryn+wstoa]. rewards=[auryn={} wstoa={} ouroboros={}]. Bootstrap complete — ready for inject/stake/collect."
                    [
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                        bloodshed-treasury-id
                        reward-auryn-id reward-wstoa-id reward-ouroboros-id
                    ]
                )
            )
        )
    )

    (defun C_Step13_CreateCustodiansVault:string
        (patron:string owner-konto:string custodians-dpsf-id:string ouro-id:string multiplet-family-id:string)
        @doc "Step 13 — stand up the Custodians DELEGATED-STAKING vault: three quintessence score \
            \ MODELS (bronze/silver/golden) + the triplet model every agency instantiates, a class-0 \
            \ FVT, a MULTIPLET_BASE OURO reward on the Step-10 ladder, the HETEROGENEOUS quality \
            \ split, the DSA template, and the pool the Custodians SFT stakes into. \
            \ Issues NO agency — that is Step 14, once per operator."
        ;;
        ;; INPUT
        ;;   custodians-dpsf-id  — the live Custodians DPSF collection id (REPL: DHOC-98c486052a51)
        ;;   ouro-id             — OURO DPTF id; BOTH the FVT common-denominator and the reward token
        ;;   multiplet-family-id — from Step 10. MUST be the OURO|AURYN|ELITEAURYN family: the
        ;;                         quality split routes per-mille across t0/t1/t2 OF THIS LADDER, so
        ;;                         a different family silently redirects every payout.
        ;; OUTPUT — fvt-id, pool-id, the four model ids. Step 14 needs the triplet model id.
        ;;
        ;; ORDER IS FORCED, not stylistic:
        ;;   * C_SetQualitySplit's own guard (04_RPS.pact UEV_QualitySplitContext) demands the reward
        ;;     link already exist, BE MULTIPLET_BASE, and carry an ACTIVE family. A reward link is
        ;;     MULTIPLET_BASE precisely when C_AddRewardLink is passed a family id instead of BAR.
        ;;     So: family (Step 10) -> reward link -> split. It cannot be reordered.
        ;;   * C_DefineDelegationVault requires the FVT to exist and be class 0, owned by patron.
        ;;   * The pool is issued here but its scores are added in Step 14 — they do not exist until
        ;;     an agency instantiates the model.
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_CUSTODIANS_VAULT))
                    (pool-id:string (ref-U|DALOS::UDC_Makeid BOOT|POOL_CUSTODIANS))
                    (bronze-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_BRONZE))
                    (silver-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_SILVER))
                    (golden-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_GOLDEN))
                    (triplet-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_TRIPLET))
                    (og-boost-class-id:string (ref-U|DALOS::UDC_Makeid BOOT|CUSTODIANS_OG_BOOST_CLASS))
                    ;;Anchor executor = the anchored SFT collection's owner, read not assumed.
                    (custodians-dpsf-owner:string
                        (AQP-ANK.URC_AnchorableAssetOwner custodians-dpsf-id [false true]))
                )
                ;; 1. the OG-Founder ANCHOR (+5%) and the boost class it creates. `acnoi` true means
                ;;    the next argument is a NAME to create rather than an existing class id.
                ;;    Issued once, here: the class is shared by every agency's scores (Step 14
                ;;    links them), which is what makes the 5% apply to a user's WHOLE staked
                ;;    quintessence rather than only the golden lane.
                (ref-TS02-C3::AQP-ANK|C_IssueSemiFungibleAnchor patron custodians-dpsf-owner BOOT|CUSTODIANS_OG_ANCHOR
                    custodians-dpsf-id true BOOT|CUSTODIANS_OG_BOOST_CLASS
                    BOOT|CUSTODIANS_ANK_PRECISION BOOT|CUSTODIANS_OG_PROMILE BOOT|CUSTODIANS_OG_NONCE)
                ;; 2. the three single models — score-class 3 (SemiFungible); v1 models are SF-only.
                ;;    Each carries og-boost-class-id, so every score minted from them is boost-linked
                ;;    AT ISSUE by the vault's rule. The agency never chooses.
                (ref-TS02-C3::AQP-SCR|C_IssueSingleScoreModel patron patron BOOT|MODEL_CUSTODIANS_BRONZE
                    3 custodians-dpsf-id BOOT|CUSTODIANS_PRECISION
                    BOOT|CUSTODIANS_NONCES_BRONZE BOOT|CUSTODIANS_VALUE_BRONZE og-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_IssueSingleScoreModel patron patron BOOT|MODEL_CUSTODIANS_SILVER
                    3 custodians-dpsf-id BOOT|CUSTODIANS_PRECISION
                    BOOT|CUSTODIANS_NONCES_SILVER BOOT|CUSTODIANS_VALUE_SILVER og-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_IssueSingleScoreModel patron patron BOOT|MODEL_CUSTODIANS_GOLDEN
                    3 custodians-dpsf-id BOOT|CUSTODIANS_PRECISION
                    BOOT|CUSTODIANS_NONCES_GOLDEN BOOT|CUSTODIANS_VALUE_GOLDEN og-boost-class-id)
                ;; 3. the triplet model — what every agency instantiates, so all agencies score alike
                (ref-TS02-C3::AQP-SCR|C_CombineTripletScoreModel patron patron BOOT|MODEL_CUSTODIANS_TRIPLET
                    bronze-model-id silver-model-id golden-model-id)
                ;; 4. the class-0 FVT. common-denominator is a REAL DPTF here, not BAR: DSA capture
                ;;    arithmetic is denominated in it, which is the whole reason class 1/2 is refused.
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_CUSTODIANS_VAULT 0 ouro-id)
                ;; 5. MULTIPLET_BASE reward — the family id is what makes it so
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto fvt-id) fvt-id ouro-id false multiplet-family-id)
                ;; 6. the heterogeneous split across the OURO|AURYN|ELITEAURYN ladder
                (ref-TS02-C3::AQP-FVT|C_SetQualitySplit patron (AQP-FVT.UR_FVT|OwnerKonto fvt-id) fvt-id ouro-id
                    BOOT|REWARD_MODE_HETEROGENEOUS
                    BOOT|CUSTODIANS_SPLIT_BRONZE BOOT|CUSTODIANS_SPLIT_SILVER BOOT|CUSTODIANS_SPLIT_GOLDEN)
                ;; 7. the DSA template — unit-score sets the node bar AND, at half, the agency bar
                (ref-TS02-C3::AQP-DSA|C_DefineDelegationVault patron patron fvt-id triplet-model-id
                    BOOT|CUSTODIANS_UNIT_SCORE)
                ;; 8. the pool the Custodians SFT stakes into — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron custodians-dpsf-owner BOOT|POOL_CUSTODIANS custodians-dpsf-id 3)
                (format "AQP-BOOT Step 13 done. fvt={} pool={} triplet-model={} models=[bronze={} silver={} golden={}] og-boost-class={} (+5%% on nonce 4) unit-score={} (agency gate {}). NEXT=Step14:CC_Step14_OpenCustodiansAgency."
                    [
                        fvt-id pool-id triplet-model-id
                        bronze-model-id silver-model-id golden-model-id
                        (ref-U|DALOS::UDC_Makeid BOOT|CUSTODIANS_OG_BOOST_CLASS)
                        BOOT|CUSTODIANS_UNIT_SCORE (/ (dec BOOT|CUSTODIANS_UNIT_SCORE) 2.0)
                    ]
                )
            )
        )
    )
    (defun CC_Step14_OpenCustodiansAgency:string
        (patron:string agency-name:string custodians-dpsf-id:string stake-nonces:[integer] fee-per-mille:integer)
        @doc "Step 14 — open ONE Custodians agency: instantiate the triplet model for this operator, \
            \ HEAVY (CC_): reaches RPS::URH_FvtEnabledScoreEntityIdsForFvt through CC_OpenAgency's \
            \ stake leg, so its cost scales with the vault's score-entity count, not with a constant. \
            \ employ its three scores in the Custodians pool, then open the agency and stake in one \
            \ atomic Talos call. Run once per operator; the first run is the vault's first agency."
        ;;
        ;; INPUT
        ;;   patron         — THE OPERATOR. There is deliberately no separate operator parameter:
        ;;                    the operator is whoever calls. C_AdmitAgency admits with
        ;;                    `XE_AdmitDelegationMember fvt-id score-entity-id PATRON`, and
        ;;                    FVT|XE>ADMIT-DELEGATION then enforces `silver-owner == operator` plus
        ;;                    that operator's account ownership -- while CC_OpenAgency stakes from
        ;;                    patron too. An earlier draft took an `operator-konto` alongside
        ;;                    `patron`; it could only ever be the same value, and passing anything
        ;;                    else failed inside RPS with a message naming neither parameter. The
        ;;                    test passed because both were KST.ANHD, which is exactly how a
        ;;                    parameter that cannot vary looks like one that can.
        ;;                    The operator need NOT be the vault owner -- only the caller.
        ;;   agency-name    — names the three scores <agency-name>Bronze/Silver/Golden, so it must be
        ;;                    unique per agency or the second one collides on the branding table.
        ;;   stake-nonces   — the operator's OWN opening stake, e.g. [-1 -2 -3] for fragments of all
        ;;                    three tiers. This is not optional: UEV_OpenGate is TERMINAL inside
        ;;                    CC_OpenAgency, so a stake too small to reach unit-score/2 reverts the
        ;;                    whole open rather than leaving a half-built agency.
        ;;   fee-per-mille  — 10..500 (1%..50%), skimmed from DELEGATORS only, never the operator.
        ;;
        ;; WHY THE POOL LINKS HAPPEN HERE AND NOT IN STEP 13: the scores do not exist until this
        ;; call mints them, and RPS's FVT|XE>ADMIT-DELEGATION requires the SILVER score to carry a
        ;; pool link before it will admit the triplet. Employ-then-open, per agency.
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_CUSTODIANS_VAULT))
                    (pool-id:string (ref-U|DALOS::UDC_Makeid BOOT|POOL_CUSTODIANS))
                    (pool-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-id))
                    (triplet-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_TRIPLET))
                    (og-boost-class-id:string (ref-U|DALOS::UDC_Makeid BOOT|CUSTODIANS_OG_BOOST_CLASS))
                )
                ;; 1. the factory: 3 scores + their SF definitions + the triplet, in one call
                (ref-TS02-C3::AQP-SCR|C_IssueScoreFromModel patron patron triplet-model-id agency-name)
                (let
                    (
                        (bronze-id:string (ref-U|DALOS::UDC_Makeid (concat [agency-name "Bronze"])))
                        (silver-id:string (ref-U|DALOS::UDC_Makeid (concat [agency-name "Silver"])))
                        (golden-id:string (ref-U|DALOS::UDC_Makeid (concat [agency-name "Golden"])))
                    )
                    ;; 2. employ all three in the Custodians pool (silver's link is the one admission reads).
                    ;;    NOTE what is NOT here: boost-class links. Those used to be three explicit
                    ;;    C_CreateScoreBoostClassLink calls at this point, which was the defect --
                    ;;    they were made by the AGENCY, so an agency could decline the vault's anchor
                    ;;    or point at another class. The class now rides on the MODEL and is applied
                    ;;    by XI_IssueOneFromModel at issue, so step 1 above already linked all three.
                    ;;    The vault admin defines how a score behaves; the agency just opens.
                    (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-owner pool-id bronze-id)
                    (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-owner pool-id silver-id)
                    (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-owner pool-id golden-id)
                    ;; 3. admit + stake + gate, atomically
                    (ref-TS02-C3::AQP-DSA|CC_OpenAgency patron patron fvt-id pool-id
                        (ref-SCR::UC_ComputeTripletId bronze-id silver-id golden-id)
                        fee-per-mille custodians-dpsf-id stake-nonces)
                    (format "AQP-BOOT Step 14 done. agency={} triplet={} operator={} fee={}/1000 scores=[bronze={} silver={} golden={}]. NEXT: C_SetOracleAuth then C_OracleWrite — capture stays 0 until an oracle reports nodes."
                        [
                            agency-name
                            (ref-SCR::UC_ComputeTripletId bronze-id silver-id golden-id)
                            patron fee-per-mille bronze-id silver-id golden-id
                        ]
                    )
                )
            )
        )
    )
    (defun C_IssueGenericEarningVault:string
        (patron:string owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
        @doc "Thin delegate to TS02-C3.AQP-FVT|C_IssueGenericEarningVault. Kept so existing callers \
            \ keep working; the operation itself moved to Talos on 2026-09-19."
        ;;WHY THE BODY MOVED. This used to compose the six TS02-C3 wrappers directly, and each of
        ;;those collects IGNIS on its own -- six collections for one logical operation. The work now
        ;;lives in TS02-C3, composing the six CORE C_ functions and concatenating their cumulators
        ;;into ONE collection. Single-collection billing is a Talos concern, not a citizen one, and
        ;;putting it there also makes the operation a public client feature rather than something
        ;;only the AQP-BOOT admin can reach.
        (TS02-C3.AQP-FVT|C_IssueGenericEarningVault
            patron owner-konto vault-name stake-dptf-id reward-dptf-id)
    )

)


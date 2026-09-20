;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 1 of 20
;; This is STEP 1 of 21 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-0 must have run first, including the init steps between deploys.
;; 2 module(s), 234,294 gas measured in the REPL gas model, 225,062 bytes
;;
;; Modules in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact ===================

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface IgnisCollectorV3
    @doc "IgnisCollectorV3 — the interface defining Ouronet's virtual-gas (IGNIS) data model \
        \ and collection API. Declares the cumulator schemas \
        \ (OutputCumulator/ModularCumulator per-interactor legs, plus Compressed and Primed \
        \ forms), UDC cumulator constructors and tier presets, URC zero-gas readers, DALOS \
        \ cost readers, and the C_Collect / STOA-collect entrypoints that every core C_ \
        \ returns and Talos uses to bill gas."

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
    ;;
    ;;  SCHEMAS
    ;;
    (defschema PrimedCumulator
        primed-cumulator:object{CompressedCumulator}
    )
    (defschema CompressedCumulator
        ignis-prices:[decimal]
        interactors:[string]
    )
    (defschema OutputCumulator
        cumulator-chain:[object{ModularCumulator}]
        output:list
    )
    (defschema ModularCumulator
        ignis:decimal
        interactor:string
    )
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
    ;;
    ;;  [UDC]
    ;;
    (defun UDC_MakeIDP:string (ignis-discount:decimal))
    (defun UDC_ConstructOutputCumulator:object{OutputCumulator} (price:decimal active-account:string trigger:bool output-lst:list))
    (defun UDC_BrandingCumulator:object{OutputCumulator} (active-account:string multiplier:decimal))
    (defun UDC_LegCumulator:object{OutputCumulator} (leg-key:string active-account:string))
    (defun UDC_CustomCodeCumulator:object{OutputCumulator} ())
        ;;
    (defun UDC_MakeModularCumulator:object{ModularCumulator} (price:decimal active-account:string trigger:bool))
    (defun UDC_MakeOutputCumulator:object{OutputCumulator} (input-modular-cumulator-chain:[object{ModularCumulator}] output-lst:list))
    (defun UDC_ConcatenateOutputCumulators:object{OutputCumulator} (input-output-cumulator-chain:[object{OutputCumulator}] new-output-lst:list))
    (defun UDC_CompressOutputCumulator:object{CompressedCumulator} (input-output-cumulator:object{OutputCumulator}))
    (defun UDC_PrimeIgnisCumulator:object{PrimedCumulator} (patron:string input:object{CompressedCumulator}))
    ;;{5.2}  Compute [UC]
    (defun UC_IgnisWeight:decimal (key:string))
    (defun UC_IgnisDeter:decimal (key:string))
    (defun UC_IgnisLeg:decimal (leg-key:string))
    (defun UC_IgnisComponents:decimal (op-key:string))
    (defun UC_IgnisPrice:decimal (op-key:string deter-key:string))
    (defun UC_IgnisPriceScaled:decimal (op-key:string deter-key:string weight-key:string n:integer))
    (defun UC_StoaPrice:decimal (deter-key:string))
    (defun UC_FeeUnlockPrice:[decimal] ())
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URC]
    ;;
    (defun URC_Exception (account:string))
    (defun URC_ZeroEliteGAZ (sender:string receiver:string))
    (defun URC_ZeroGAZ:bool (id:string sender:string receiver:string))
    (defun URC_ZeroGAS:bool (id:string sender:string))
    (defun URC_IsVirtualGasZeroAbsolutely:bool (id:string))
    (defun URC_IsVirtualGasZero:bool ())
    (defun URC_IsNativeGasZero:bool ())
    ;;
    ;;  [DALOS-URCi] cost readers — single-source the tier choice for DALOS client ops.
    ;;  DALOS deploys below IGNIS so it hosts these here; Talos bills through them and the
    ;;  Z_Reads presentation derives its preview from the same source (kills tier-choice drift).
    (defun DALOS|URCi_ControlSmartAccount:object{OutputCumulator} (account:string))
    (defun DALOS|URCi_RotateGovernor:object{OutputCumulator} (account:string))
    (defun DALOS|URCi_RotateGuard:object{OutputCumulator} (account:string))
    (defun DALOS|URCi_RotateStoa:object{OutputCumulator} (account:string))
    (defun DALOS|URCi_RotateSovereign:object{OutputCumulator} (account:string))
    (defun DALOS|URCi_UpdateEliteAccount:object{OutputCumulator} (patron:string))
    (defun DALOS|URCi_UpdateEliteAccountSquared:object{OutputCumulator} (patron:string))
    (defun DALOS|URCi_DeploySmartAccount:decimal ())
    (defun DALOS|URCi_DeployStandardAccount:decimal ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_TwentyFourPrecision (amount:decimal))
    (defun UEV_Patron (patron:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_TransferDalosFuel (executor:string executee:string amount:decimal))
    (defun C_Collect                                    (patron:string input-output-cumulator:object{OutputCumulator}))
    (defun STOA|C_Collect (patron:string amount:decimal))
    (defun STOA|C_CollectWT (patron:string amount:decimal trigger:bool))
    (defun STOA|C_CollectWTEx (patron:string discount-account:string amount:decimal trigger:bool))
    (defun STOA|C_CollectFull (patron:string amount:decimal trigger:bool))

)

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface OuronetInfoV2
    @doc "Holds Information Schemas"

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
    ;;
    ;;  SCHEMAS
    ;;
    (defschema ClientInfo
        pre-text:[string]
        post-text:[string]
        ignis:object{ClientIgnisCosts}
        stoa:object{ClientStoaCosts}
        output:list
    )
    (defschema ClientIgnisCosts
        ignis-discount:decimal
        ignis-full:decimal
        ignis-need:decimal
        ignis-text:string
    )
    (defschema ClientStoaCosts
        stoa-discount:decimal
        stoa-full:decimal
        stoa-need:decimal
        stoa-split:[decimal]
        stoa-targets:[string]
        stoa-text:string
    )
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
    ;;
    ;;
    ;;  [UDC] Functions
    ;;
    (defun OI|UDC_ClientInfo:object{ClientInfo} (a:[string] b:[string] c:object{ClientIgnisCosts} d:object{ClientStoaCosts} e:list))
    (defun OI|UDC_ClientIgnisCosts:object{ClientIgnisCosts} (a:decimal b:decimal c:decimal d:string))
    (defun OI|UDC_ClientStoaCosts:object{ClientStoaCosts} (a:decimal b:decimal c:decimal d:[decimal] e:[string] f:string))
        ;;
    (defun OI|UDC_FullStoaCosts:object{ClientStoaCosts} (kfp:decimal))
    (defun OI|UDC_StoaCosts:object{ClientStoaCosts} (patron:string kfp:decimal))
    (defun OI|UDC_NoStoaCosts:object{ClientStoaCosts} ())
    (defun OI|UDC_DynamicStoaCost:object{ClientStoaCosts} (patron:string kfp:decimal))
        ;;
    (defun OI|UDC_IgnisCosts:object{ClientIgnisCosts} (patron:string ifp:decimal))
    (defun OI|UDC_NoIgnisCosts:object{ClientIgnisCosts} ())
    (defun OI|UDC_DynamicIgnisCost:object{ClientIgnisCosts} (patron:string ifp:decimal))
    ;;{5.2}  Compute [UC]
    ;;
    ;;
    ;;  [UC] Functions
    ;;
    (defun OI|UC_IfpFromOutputCumulator:decimal (input:object{IgnisCollectorV3.OutputCumulator}))
    (defun OI|UC_ShortAccount:string (account:string))
    (defun OI|UC_ConvertPrice:string (input-price:decimal))
    (defun OI|UC_FormatIndex:string (index:decimal))
    (defun OI|UC_FormatTokenAmount:string (amount:decimal))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;
    ;;  [UR] Functions
    ;;
    (defun OI|UR_StoaTargets:[string] ())
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]

)

(module IGNIS GOV
    @doc "IGNIS — the virtual-chain gas collector, implementing IgnisCollectorV3 and \
        \ OuronetInfoV2. It compresses and primes OutputCumulators into per-interactor \
        \ charges, splitting a GAS_QUARTER cut between smart-account interactors and the \
        \ principal; C_Collect debits the patron and credits collectors via DALOS balance \
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
        (with-capability (GOV|IGNIS_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)}
                    )
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
        ;;are NON-DISCOUNTABLE (collected with STOA|C_CollectFull). $50 deploy / $10 rename
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
            ;;Measured: handing C_Collect a hand-built cumulator naming a STANDARD account succeeds,
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
            \ deter = 400 STOA; when a real price lands the AMOUNT moves but the VALUE holds."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (/ (/ (UC_IgnisDeter deter-key) 100.0) (ref-DALOS::UR_UsagePrice "stoa|price"))
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
    ;;{5.7}  User [A/C]
    ;;
    ;;
    (defun C_TransferDalosFuel (executor:string executee:string amount:decimal)
        @doc "Move native STOA. A ZERO amount is a NO-OP, not a transfer: Stoa's coin enforces \
            \ (> amount 0.0), so passing 0.0 aborts the whole transaction. Zero legs are now \
            \ normal — the account-creation STOA switch prices onboarding at 0.0 while it is \
            \ OFF, and a small dollar-pegged amount can round one of the four split legs to \
            \ zero. Guarding here covers every STOA|C_Collect* path at once."
        (if (> amount 0.0)
            (let
                (
                    (ref-coin:module{stoa-ns.fungible-v1} coin)
                )
                (ref-coin::transfer executor executee amount)
            )
            "Zero STOA leg — nothing transferred"
        )
    )
    (defun C_Collect
        (patron:string input-output-cumulator:object{IgnisCollectorV3.OutputCumulator})
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
    (defun STOA|C_Collect (patron:string amount:decimal)
        (STOA|C_CollectWT patron amount (URC_IsNativeGasZero))
    )
    (defun STOA|C_CollectWT (patron:string amount:decimal trigger:bool)
        (STOA|C_CollectWTEx patron patron amount trigger)
    )
    (defun STOA|C_CollectFull (patron:string amount:decimal trigger:bool)
        @doc "Collect native STOA taxed in FULL — no Elite discount. The pricing spec marks a \
            \ few costs as non-discountable (PYTHIA's fees, some asymmetric-liquidity legs); \
            \ everything else must keep using STOA|C_Collect* so the discount applies."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (split-full:[decimal] (ref-DALOS::URC_SplitSTOAPricesFull amount))
                (am0:decimal (at 0 split-full))
                (am1:decimal (at 1 split-full))
                (am2:decimal (at 2 split-full))
                (am3:decimal (at 3 split-full))
                (stoa-sender:string (ref-DALOS::UR_AccountStoa patron))
                (demiurgoi:[string] (ref-DALOS::UR_DemiurgoiID))
                (stoa-cto:string (ref-DALOS::UR_AccountStoa (at 1 demiurgoi)))
                (stoa-hov:string (ref-DALOS::UR_AccountStoa (at 2 demiurgoi)))
                (stoa-ouroboros:string (ref-DALOS::UR_AccountStoa OUROBOROS|SC_NAME))
                (stoa-dalos:string (ref-DALOS::UR_AccountStoa DALOS|SC_NAME))
            )
            (if (not trigger)
                (do
                    (C_TransferDalosFuel stoa-sender stoa-hov am0)          ;;10% to Demiourgos.Holdings
                    (C_TransferDalosFuel stoa-sender stoa-cto am2)          ;;30% to Ouronet Maintenance
                    (C_TransferDalosFuel stoa-sender stoa-ouroboros am3)    ;;40% to STOA-Ouroboros
                    (C_TransferDalosFuel stoa-sender stoa-dalos am1)        ;;20% to STOA-Dalos (Gas Station)
                )
                (format "While Stoa Collection is {}, the {} STOA could not be collected" [trigger amount])
            )
        )
    )
    (defun STOA|C_CollectWTEx (patron:string discount-account:string amount:decimal trigger:bool)
        @doc "Collect native STOA from patron Stoa account; Elite split from discount-account."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (split-discounted-stoa:[decimal] (ref-DALOS::URC_SplitSTOAPrices discount-account amount))
                (am0:decimal (at 0 split-discounted-stoa))
                (am1:decimal (at 1 split-discounted-stoa))
                (am2:decimal (at 2 split-discounted-stoa))
                (am3:decimal (at 3 split-discounted-stoa))
                (stoa-sender:string (ref-DALOS::UR_AccountStoa patron))
                (demiurgoi:[string] (ref-DALOS::UR_DemiurgoiID))
                (stoa-cto:string (ref-DALOS::UR_AccountStoa (at 1 demiurgoi)))
                (stoa-hov:string (ref-DALOS::UR_AccountStoa (at 2 demiurgoi)))
                (stoa-ouroboros:string (ref-DALOS::UR_AccountStoa OUROBOROS|SC_NAME))
                (stoa-dalos:string (ref-DALOS::UR_AccountStoa DALOS|SC_NAME))
            )
            (if (not trigger)
                (do
                    (C_TransferDalosFuel stoa-sender stoa-hov am0)          ;;10% to Demiourgos.Holdings
                    (C_TransferDalosFuel stoa-sender stoa-cto am2)          ;;30% to Ouronet Maintenance
                    (C_TransferDalosFuel stoa-sender stoa-ouroboros am3)    ;;40% to STOA-Ouroboros (as Pitstop for LiquidStoaIndex fueling)
                    (C_TransferDalosFuel stoa-sender stoa-dalos am1)        ;;20% to STOA-Dalos (Ouronet Gas Station)
                )
                (format "While Stoa Collection is {}, the {} STOA could not be collected" [trigger amount])
            )
        )
    )

)

;; --- tables for 02_IGNIS.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/05_DPTF.pact ====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface BrandingUsagePrimaryV2
    @doc "Exposes Branding Functions for True-Fungibles (T), Orto-Fungibles (M), ATS-Pairs (A) and SWP-Pairs (S)"

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
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun C_UpgradeBranding (patron:string entity-id:string months:integer))

)

;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface DemiourgosPactTrueFungibleV2
    @doc "Exposes most of the Functions related to True-Fungibles"

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
    ;;
    ;;  [UDC]
    ;;
    (defun UDC_TrueFungibleAccount:object{OuronetDalosV2.DPTF|BalanceSchema} (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string))
    ;;{5.2}  Compute [UC]
    (defun UC_IdAccount:string (id:string account:string))
    (defun UC_VolumetricTax (id:string amount:decimal))
    (defun UC_TreasuryLowestDispo (ouro-supply:decimal ouro-precision:integer dispo-type:integer tdp:decimal tds:decimal))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UC]
    ;;
    (defun URU_UpgradeTruefungibleToV2 (ids:[string]))
    ;;
    ;;  [UR]
    ;;
    (defun UR_P-KEYS:[string] ())
    (defun UR_KEYS:[string] ())
    ;;
    ;;  [0] DPTF|PropertiesTable:{DPTF|PropertiesSchema}
    (defun UR_Konto:string (id:string))
    (defun UR_Name:string (id:string))
    (defun UR_Ticker:string (id:string))
    (defun UR_Decimals:integer (id:string))
    (defun UR_CanUpgrade:bool (id:string))
    (defun UR_CanChangeOwner:bool (id:string))
    (defun UR_CanAddSpecialRole:bool (id:string))
    (defun UR_CanFreeze:bool (id:string))
    (defun UR_CanWipe:bool (id:string))
    (defun UR_CanPause:bool (id:string))
    (defun UR_Paused:bool (id:string))
    (defun UR_Supply:decimal (id:string))
    (defun UR_OriginMint:bool (id:string))
    (defun UR_OriginAmount:decimal (id:string))
    (defun UR_FeeToggle:bool (id:string))
    (defun UR_MinMove:decimal (id:string))
    (defun UR_FeePromile:decimal (id:string))
    (defun UR_FeeTarget:string (id:string))
    (defun UR_FeeLock:bool (id:string))
    (defun UR_FeeUnlocks:integer (id:string))
    (defun UR_PrimaryFeeVolume:decimal (id:string))
    (defun UR_SecondaryFeeVolume:decimal (id:string))
    (defun UR_RewardToken:[string] (id:string))
    (defun UR_RewardBearingToken:[string] (id:string))
    (defun UR_Vesting:string (id:string))
    (defun UR_Sleeping:string (id:string))
    (defun UR_Hibernation:string (id:string))
    (defun UR_Frozen:string (id:string))
    (defun UR_Reservation:string (id:string))
    (defun UR_IzReservationOpen:bool (id:string))
    (defun UR_IzId:bool (id:string))
    ;;  [1]     DPTF|RoleTable:{DPTF|RoleSchema}
    (defun UR_Verum1:[string] (id:string))
    (defun UR_Verum2:[string] (id:string))
    (defun UR_Verum3:[string] (id:string))
    (defun UR_Verum4:[string] (id:string))
    (defun UR_Verum5:[string] (id:string))
    ;;  [2]     DPTF|BalanceTable:{OuronetDalosV2.DPTF|BalanceSchema}
    (defun UR_IzAccount:bool (id:string account:string))
    (defun UR_AccountSupply:decimal (id:string account:string))
    (defun UR_AccountFrozenState:bool (id:string account:string))
    (defun UR_AccountRoleBurn:bool (id:string account:string))
    (defun UR_AccountRoleMint:bool (id:string account:string))
    (defun UR_AccountRoleTransfer:bool (id:string account:string))
    (defun UR_AccountRoleFeeExemption:bool (id:string account:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_IzRT:bool (reward-token:string))
    (defun URC_IzRTg:bool (atspair:string reward-token:string))
    (defun URC_IzRBT:bool (reward-bearing-token:string))
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string))
    (defun URC_IzCoreDPTF:bool (id:string))
    (defun URC_Fee:[decimal] (id:string amount:decimal))
        ;;
    (defun URC_HasVesting:bool (id:string))
    (defun URC_HasSleeping:bool (id:string))
    (defun URC_HasHibernation:bool (id:string))
    (defun URC_HasFrozen:bool (id:string))
    (defun URC_HasReserved:bool (id:string))
    (defun URCv_Parent:string (dptf:string))
    (defun URC_TreasuryLowestDispo:decimal ())
    ;;
    ;;  [URD]
    ;;
    (defun URH_HeldTrueFungibles:[string] (account:string))
    (defun URH_ExistingTrueFungibles:[string] (dptf:string))
    (defun URH_OwnedTrueFungibles:[string] (account:string))
    ;;
    ;;  [URCi] cost readers — single source per op (the C_ bills them, INFO previews from them)
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string))
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleReservation:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleFee:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_SetMinMove:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_SetFee:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_SetFeeTarget:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleMintRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleFeeExemptionRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_Wipe:object{IgnisCollectorV3.OutputCumulator} (id:string))
    (defun URCi_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string account:string))
    (defun URCi_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string account:string origin:bool))
    (defun URCi_UpdateSpecialTrueFungible:object{IgnisCollectorV3.OutputCumulator} (main-dptf:string))
    (defun URCi_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (id:string toggle:bool))
    (defun URCi_IssueGas:decimal (token-count:integer))
    (defun URCi_IssueStoa:decimal (token-count:integer))
    (defun URCi_UpgradeBranding:decimal (months:integer))
    (defun URCi_DeployAccount:object{IgnisCollectorV3.OutputCumulator} (account:string))
    (defun URCi_ToggleFeeLockStoa:decimal (id:string toggle:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_ParentOwnership (dptf:string))
    (defun UEV_id (id:string))
    (defun UEV_CheckID:bool (id:string))
    (defun UEV_Amount (id:string amount:decimal))
    (defun UEV_CheckAmount:bool (id:string amount:decimal))
        ;;
    (defun UEV_CanChangeOwnerON (id:string))
    (defun UEV_CanUpgradeON (id:string))
    (defun UEV_CanAddSpecialRoleON (id:string))
    (defun UEV_CanFreezeON (id:string))
    (defun UEV_CanWipeON (id:string))
    (defun UEV_CanPauseON (id:string))
        ;;
    (defun UEV_PauseState (id:string state:bool))
    (defun UEV_ReservationState (id:string state:bool))
    (defun UEV_AccountBurnState (id:string account:string state:bool))
    (defun UEV_AccountTransferState (id:string account:string state:bool))
    (defun UEV_AccountFreezeState (id:string account:string state:bool))
    (defun UEV_Virgin (id:string))
    (defun UEV_FeeLockState (id:string state:bool))
    (defun UEV_FeeToggleState (id:string state:bool))
    (defun UEV_AccountMintState (id:string account:string state:bool))
    (defun UEV_AccountFeeExemptionState (id:string account:string state:bool))
    (defun UEV_Vesting (id:string existance:bool))
    (defun UEV_Sleeping (id:string existance:bool))
    (defun UEV_Hibernation (id:string existance:bool))
    (defun UEV_Frozen (id:string existance:bool))
    (defun UEV_Reserved (id:string existance:bool))
    ;;
    ;;  [CAP]
    ;;
    (defun CAP_Owner (id:string))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [X]
    ;;
    (defun XE_IssueLP:object{IgnisCollectorV3.OutputCumulator} (name:string ticker:string))
    (defun XB_IssueFree:object{IgnisCollectorV3.OutputCumulator}
        (
            account:string
            name:[string]
            ticker:[string]
            decimals:[integer]
            ;;
            can-upgrade:[bool]
            can-change-owner:[bool]
            can-add-special-role:[bool]
            ;;
            can-freeze:[bool]
            can-wipe:[bool]
            can-pause:[bool]
            ;;
            iz-special:[bool]
        )
    )
    (defun XB_DeployAccountWNE (account:string id:string))
    (defun XBv_UpdateSupply (id:string amount:decimal direction:bool))
    (defun XE_UpdateFeeVolume (id:string amount:decimal primary:bool))
    (defun XE_UpdateRewardToken (atspair:string id:string direction:bool))
    (defun XE_UpdateRewardBearingToken (atspair:string id:string))
    (defun XE_UpdateVesting (dptf:string dpof:string))
    (defun XE_UpdateSleeping (dptf:string dpof:string))
    (defun XE_UpdateHibernation (dptf:string dpof:string))
    (defun XE_UpdateSpecialTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (main-dptf:string secondary-dptf:string fr-tag:integer)
    )
    (defun XB_DebitTrueFungible (id:string account:string amount:decimal dispo-data:object{UtilityDptfV2.DispoData} wipe-mode:bool))
    (defun XB_CreditTrueFungible (id:string account:string amount:decimal))
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun A_UpdateTreasury (type:integer tdp:decimal tds:decimal))
    (defun A_WipeTreasuryDebt ())
    (defun A_WipeTreasuryDebtPartial (debt-to-be-wiped:decimal))
    ;;
    ;;  [C]
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string executor:string 
            name:[string] ticker:[string] decimals:[integer] 
            can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] 
            can-freeze:[bool] can-wipe:[bool] can-pause:[bool]
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string new-owner:string))
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator} (id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool))
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string toggle:bool))
    (defun C_ToggleReservation:object{IgnisCollectorV3.OutputCumulator} (id:string toggle:bool))
        ;;
    (defun C_ToggleFee:object{IgnisCollectorV3.OutputCumulator} (id:string toggle:bool))
    (defun C_SetMinMove:object{IgnisCollectorV3.OutputCumulator} (id:string min-move-value:decimal))
    (defun C_SetFee:object{IgnisCollectorV3.OutputCumulator} (id:string fee:decimal))
    (defun C_SetFeeTarget:object{IgnisCollectorV3.OutputCumulator} (id:string target:string))
    (defun C_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (patron:string id:string toggle:bool))
        ;;
    (defun C_DeployAccount (id:string account:string))
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
    (defun C_ToggleMintRole:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
    (defun C_ToggleFeeExemptionRole:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string account:string toggle:bool))
        ;;
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string account:string amount:decimal))
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string account:string amount:decimal origin:bool))
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string account-to-be-wiped:string amount-to-be-wiped:decimal))
    (defun C_Wipe:object{IgnisCollectorV3.OutputCumulator} (id:string account-to-be-wiped:string))

)
;;
(module DPTF GOV
    @doc "DPTF — the True-Fungible token core, implementing DemiourgosPactTrueFungibleV2 and \
        \ the primary branding interface. It owns a properties table (ownership, decimals, \
        \ control flags, supply, fee config, reward-token/RBT and \
        \ vesting/sleeping/frozen/reservation links), a role table and a balance table. \
        \ Client ops include issue, mint/burn, control flags, pause, reservation, fee \
        \ set/target/lock/exemption, account freeze, mint/burn/transfer roles, wipe, \
        \ ownership rotation and treasury-debt admin."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements BrandingUsagePrimaryV2)
    (implements DemiourgosPactTrueFungibleV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPTF                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPTF_ADMIN)))
    (defcap GOV|DPTF_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_DPTF)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "DPTF Ownership not verified"
                [
                    (enforce-guard g1)
                    (enforce-guard g2)
                ]
            )
        )
    )
    (defcap GOV|SET_TREASURY-DISPO (type:integer tdp:decimal tds:decimal)
        @event
        (compose-capability (GOV|DPTF_ADMIN))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (ouro-supply:decimal (UR_Supply ouro))
                (op:integer (UR_Decimals ouro))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (treasury-supply:decimal (UR_AccountSupply ouro treasury))
            )
            ;;Type can only pe 0, 1, 2 or 3
            ;;Type 0 = No Treasury Dispo
            ;;Type 1 = Maximum Dispo equal to Total Supply
            ;;Type 2 = Percent Based Dispo
            ;:Type 3 = Absolute Value Dispo in Thousands
            (enforce (= (contains type (enumerate 0 3)) true) "Treasury Dispo Type can only be 0, 1, 2 or 3!")
            (let
                (
                    (lowest-dispo:decimal (UC_TreasuryLowestDispo ouro-supply op type tdp tds))
                )
                (enforce
                    (<= lowest-dispo treasury-supply)
                    (format "A Type {} Treasury Dispo cannot be set at {} because it surpases the Current Treasury Value of {}" [type tdp treasury-supply])
                )
            )
        )
    )
    (defcap GOV|WIPE_ALL-TREASURY-DEBT ()
        @event
        (compose-capability (GOV|DPTF_ADMIN))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (ouro-supply:decimal (UR_Supply ouro))
                (op:integer (UR_Decimals ouro))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (treasury-supply:decimal (UR_AccountSupply ouro treasury))
            )
            (enforce (< treasury-supply 0.0) "Cannot Wipe Positive Treasury Balance")
            (compose-capability (SECURE))
        )
    )
    (defcap GOV|WIPE_PARTIAL-TREASURY-DEBT (debt-to-be-wiped:decimal)
        @event
        (compose-capability (GOV|DPTF_ADMIN))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (ouro-supply:decimal (UR_Supply ouro))
                (op:integer (UR_Decimals ouro))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (treasury-supply:decimal (UR_AccountSupply ouro treasury))
            )
            (enforce (< treasury-supply 0.0) "Cannot Wipe Positive Treasury Balance")
            (enforce (<= debt-to-be-wiped (abs treasury-supply))
                "Debt to be wiped must be smaller than or equal to the absolute value of the current Treasury Debt"
            )
            (compose-capability (SECURE))
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
    (defcap P|DPTF|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|DPTF|CALLER))
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
        (with-capability (GOV|DPTF_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|DPTF_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_AppL mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_Define ()
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (mg:guard (create-capability-guard (P|DPTF|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
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
    ;;{3.2}  schemas
    ;;
    (defschema DPTF|PropertiesSchema
        id:string
        owner-konto:string
        name:string
        ticker:string
        decimals:integer
        ;;
        can-upgrade:bool
        can-change-owner:bool
        can-add-special-role:bool
        can-freeze:bool
        can-wipe:bool
        can-pause:bool
        ;;
        is-paused:bool
        ;;
        supply:decimal
        origin-mint:bool
        origin-mint-amount:decimal
        ;;
        fee-toggle:bool
        min-move:decimal
        fee-promile:decimal
        fee-target:string
        fee-lock:bool
        fee-unlocks:integer
        primary-fee-volume:decimal
        secondary-fee-volume:decimal
        ;;
        reward-token:[string]
        reward-bearing-token:[string]
        ;;
        vesting-link:string
        sleeping-link:string
        hibernation-link:string
        frozen-link:string
        reservation-link:string
        reservation:bool
    )
    (defschema DPTF|RoleSchema
        a-frozen:[string]
        r-burn:[string]
        r-mint:[string]
        r-fee-exemption:[string]
        r-transfer:[string]
    )
    ;;{3.3}  tables
    (deftable DPTF|PropertiesTable:{DPTF|PropertiesSchema})             ;;Key = <DPTF-id>
    (deftable DPTF|RoleTable:{DPTF|RoleSchema})                         ;;Key = <DPTF-id>
    (deftable DPTF|BalanceTable:{OuronetDalosV2.DPTF|BalanceSchema})    ;;Key = <DPTF-id> + BAR + <account> 

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap DPTF|S>ROTATE-OWNERSHIP (id:string new-owner:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_SenderWithReceiver (UR_Konto id) new-owner)
            (ref-DALOS::UEV_EnforceAccountExists new-owner)
            (CAP_Owner id)
            (UEV_CanChangeOwnerON id)
        )
    )
    (defcap DPTF|S>CONTROL (id:string)
        @event
        (CAP_Owner id)
        (UEV_CanUpgradeON id)
    )
    (defcap DPTF|S>TOGGLE_PAUSE (id:string pause:bool)
        @event
        (if pause
            (UEV_CanPauseON id)
            true
        )
        (CAP_Owner id)
        (UEV_PauseState id (not pause))
    )
    (defcap DPTF|S>TOGGLE_RESERVATION (id:string toggle:bool)
        @event
        (CAP_Owner id)
        (UEV_ReservationState id (not toggle))
    )
    ;;
    (defcap DPTF|S>SET_FEE (id:string fee:decimal)
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
            )
            (ref-U|DALOS::UEV_Fee fee)
            (CAP_Owner id)
            (UEV_FeeLockState id false)
        )
    )
    (defcap DPTF|S>SET_FEE-TARGET (id:string target:string) ;;add blacklisted accounts. eventual D Accounts.
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (current-fee-target:string (UR_FeeTarget id))
                (target-type:bool (ref-DALOS::UR_AccountType target))
                (dalos-sc:string (ref-DALOS::GOV|DALOS|SC_NAME))
                (orbr-sc:string (ref-DALOS::GOV|OUROBOROS|SC_NAME))
            )
            (enforce (!= target current-fee-target) "New Fee Target must be different than the current <fee-target>")
            (if target-type
                (enforce (or (= target dalos-sc)(= target orbr-sc)) "As Smart OURONET Accounts, only DALOS and OUROBOROS can be set as as fee Target")
                (ref-DALOS::UEV_EnforceAccountExists target)
            )
            (CAP_Owner id)
            (UEV_FeeLockState id false)
        )
    )
    (defcap DPTF|S>SET_MIN-MOVE (id:string min-move-value:decimal)
        @event
        (let
            (
                (decimals:integer (UR_Decimals id))
            )
            (enforce
                (= (floor min-move-value decimals) min-move-value)
                (format "Min tr amount {} does not conform with the {} DPTF dec. no." [min-move-value id])
            )
            (enforce (or (= min-move-value -1.0) (> min-move-value 0.0)) "Min-Move Value does not compute")
            (CAP_Owner id)
            (UEV_FeeLockState id false)
        )
    )
    (defcap DPTF|S>TOGGLE_FEE (id:string toggle:bool)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fee-promile:decimal (UR_FeePromile id))
            )
            (enforce (or (= fee-promile -1.0) (and (>= fee-promile 0.0) (<= fee-promile 1000.0))) "Please Set up Fee Promile before Turning Fee Collection on !")
            (ref-DALOS::UEV_EnforceAccountExists (UR_FeeTarget id))
            (CAP_Owner id)
            (UEV_FeeLockState id false)
            (UEV_FeeToggleState id (not toggle))
        )
    )
    (defcap DPTF|S>X_TG_FEE-LOCK (id:string toggle:bool)
        (CAP_Owner id)
        (UEV_FeeLockState id (not toggle))
    )
    ;;{C3}  Composed
    ;;
    ;;
    (defcap AHU ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ah:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
            )
            (ref-DALOS::CAP_EnforceAccountOwnership ah)
            (compose-capability (SECURE))
        )
    )
    ;;
    (defcap DPTF|C>UPDATE-BRD (dptf:string)
        @event
        (UEV_ParentOwnership dptf)
        (compose-capability (P|DPTF|CALLER))
    )
    (defcap DPTF|C>UPGRADE-BRD (dptf:string)
        @event
        (UEV_ParentOwnership dptf)
        (compose-capability (P|DPTF|CALLER))
    )
    ;;
    (defcap DPTF|C>ISSUE (account:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @event
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (l1:integer (length name))
                (l2:integer (length ticker))
                (l3:integer (length decimals))
                (l4:integer (length can-change-owner))
                (l5:integer (length can-upgrade))
                (l6:integer (length can-add-special-role))
                (l7:integer (length can-freeze))
                (l8:integer (length can-wipe))
                (l9:integer (length can-pause))
                (lengths:[integer] [l1 l2 l3 l4 l5 l6 l7 l8 l9])
            )
            (ref-U|INT::UEV_UniformList lengths)
            (ref-U|LST::UEV_IzUnique name)
            (ref-U|LST::UEV_IzUnique ticker)
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (P|SECURE-CALLER))
        )
    )
    ;;
    (defcap DPTF|C>TOGGLE_FEE-LOCK (id:string toggle:bool)
        @event
        (compose-capability (DPTF|S>X_TG_FEE-LOCK id toggle))
        (compose-capability (SECURE))
    )
    ;;
    (defcap DPTF|C>FREEZE (id:string account:string frozen:bool)
        @doc "Toggle Verum 1"
        @event
        (compose-capability (DPTF|C>X_FREEZE id account frozen))
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>X_FREEZE (id:string account:string frozen:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountFreezeState id account (not frozen))
            (if frozen
                (UEV_CanFreezeON id)
                true
            )
            (compose-capability (P|DPTF|CALLER))
        )
    )
    (defcap DPTF|C>TOGGLE-BURN-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 2"
        @event
        (compose-capability (DPTF|C>X_TOGGLE-BURN-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>X_TOGGLE-BURN-ROLE (id:string account:string toggle:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountBurnState id account (not toggle))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
            (compose-capability (P|DPTF|CALLER))
        )
    )
    (defcap DPTF|C>TOGGLE-MINT-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 3"
        @event
        (compose-capability (DPTF|C>X_TOGGLE-MINT-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>X_TOGGLE-MINT-ROLE (id:string account:string toggle:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (CAP_Owner id)
            (UEV_AccountMintState id account (not toggle))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
        )
        (compose-capability (P|DPTF|CALLER))
    )
    (defcap DPTF|C>TOGGLE-FEE-EXEMPTION-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 4"
        @event
        (compose-capability (DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE (id:string account:string toggle:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_NotSmartOuronetAccount account)
            (ref-DALOS::UEV_EnforceAccountType account true)
            (CAP_Owner id)
            (UEV_AccountFeeExemptionState id account (not toggle))
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
            (compose-capability (P|DPTF|CALLER))
        )
    )
    (defcap DPTF|C>TOGGLE_TRANSFER-ROLE (id:string account:string toggle:bool)
        @doc "Toggle Verum 5"
        @event
        (compose-capability (DPTF|C>X_TOGGLE-TRANSFER-ROLE id account toggle))
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>X_TOGGLE-TRANSFER-ROLE (id:string account:string toggle:bool)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (special:[string] ["F|" "R|"])
                (ft:string (take 2 id))
                (iz-special:bool (contains ft special))
            )
            ;;Frozen and Reserved Special Tokens can use Core Smart Ouronet Accounts for Transfer Roles Setup.
            (if (not iz-special)
                (do
                    (ref-DALOS::UEV_NotSmartOuronetAccount account)
                    (UEV_AccountTransferState id account (not toggle))
                )
                true
            )
            (CAP_Owner id)
            (if toggle
                (UEV_CanAddSpecialRoleON id)
                true
            )
            (compose-capability (P|DPTF|CALLER))
        )
    )
    (defcap DPTF|C>BURN (id:string client:string amount:decimal)
        @event
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
            )
            (UEV_AccountBurnState id client true)
            (compose-capability (DPTF|C>DEBIT client id amount (ref-U|DPTF::UDC_EmptyDispo) false))
        )
    )
    (defcap DPTF|C>MINT (id:string client:string amount:decimal origin:bool)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (lp-prefix:[string] ["S|" "W|" "P|"])
                (ft:string (take 2 id))
                (iz-lp:bool (contains ft lp-prefix))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership client)
            (if origin
                (do
                    (CAP_Owner id)
                    (UEV_Virgin id)
                    (if (not iz-lp)
                        (ref-DALOS::UEV_NotSmartOuronetAccount client)
                        true
                    )
                )
                (UEV_AccountMintState id client true)  
            )
            (compose-capability (DPTF|C>CREDIT client id amount))
        )
    )
    (defcap DPTF|C>WIPE-SLIM (id:string account-to-be-wiped:string amount:decimal)
        @event
        (compose-capability (DPTF|C>X_WIPE id account-to-be-wiped amount))
    )
    (defcap DPTF|C>WIPE (id:string account-to-be-wiped:string)
        @event
        (compose-capability (DPTF|C>X_WIPE id account-to-be-wiped (UR_AccountSupply id account-to-be-wiped)))
    )
    (defcap DPTF|C>X_WIPE (id:string account-to-be-wiped:string amount:decimal)
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
            )
            (UEV_CanWipeON id)
            (UEV_AccountFreezeState id account-to-be-wiped true)
            (compose-capability (DPTF|C>DEBIT account-to-be-wiped id amount (ref-U|DPTF::UDC_EmptyDispo) true))
        )
    )
    ;;
    (defcap DPTF|C>DEBIT (account:string id:string amount:decimal dispo-data:object{UtilityDptfV2.DispoData} wipe-mode:bool)
        (UEV_Amount id amount)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (current-supply:decimal (UR_AccountSupply id account))
                (debit-result:decimal (- current-supply amount))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
            )
            (if (= id ouro-id)
                (let
                    (
                        (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
                        (ea-id:string (ref-DALOS::UR_EliteAurynID))
                        (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                        (account-type:bool (ref-DALOS::UR_AccountType account))
                        (lowest-dispo:decimal
                            (if account-type
                                (if (= account treasury)
                                    (URC_TreasuryLowestDispo)
                                    0.0
                                )
                                (if (= ea-id BAR)
                                    0.0
                                    (- (ref-U|DPTF::UC_OuroDispo dispo-data))
                                )
                            )
                        )
                    )
                    (enforce (>= debit-result lowest-dispo) (format "Cannot Debit OURO from {}, dispo capabilities exceeded!" [account]))
                )
                (enforce (>= debit-result 0.0) (format "Cannot Debit DPTF {} from {} into the negatives" [id account]))
            )
            (if wipe-mode
                (CAP_Owner id)
                (ref-DALOS::CAP_EnforceAccountOwnership account)
            )
            (if (and (= id ouro-id) wipe-mode)
                ;;UNREACHABLE -- a fail-closed backstop that no input can trip. Proven in
                ;;REPL/modules/DPTF.repl <<DPTF-G7>> section 02, four facts: (a) wipe-mode TRUE
                ;;implies the wipe path (all five external callers in 09_TFT pass FALSE);
                ;;(b) the wipe path always passes UDC_EmptyDispo, so the floor is 0.0;
                ;;(c) the treasury -- the only account with a non-zero floor -- is a SMART account
                ;;and can never be frozen, hence never wiped; (d) UEV_Amount forces amount > 0.0.
                ;;Compose (b)+(d): reaching this line at all requires current-supply > 0, which is
                ;;exactly what it tests. NOTE: the condition tests current-supply while the message
                ;;names the amount; if `(> amount 0.0)` was intended, (d) already enforces it.
                (enforce (> current-supply 0.0) "Can only Debit positive OURO Amounts")
                true
            )
            (compose-capability (SECURE))
        )
    )
    (defcap DPTF|C>CREDIT (account:string id:string amount:decimal)
        (UEV_Amount id amount)
        (compose-capability (SECURE))
    )
    (defcap DPTF|C>UPDATE-SPECIAL (main-dptf:string secondary-dptf:string fr-tag:integer)
        ;;UNREACHABLE BY CONSTRUCTION, and a DUPLICATE. The only path in is
        ;;VST::XI_CreateSpecialTrueFungibleLink -> XE_UpdateSpecialTrueFungible, and VST already
        ;;runs the identical check under the identical message in VST|C>REPURPOSE-TRUE-FUNGIBLE.
        ;;Every caller passes a literal 1 or 2 and no client supplies <fr-tag>. Kept as this
        ;;module's own fail-closed backstop for a future external caller; because the wording is
        ;;shared with VST it also cannot be pinned distinctly by message.
        (enforce (contains fr-tag [1 2]) "Invalid Frozen|Reserve Tag")
        (let
            (
                (main-special-id:string
                    (cond
                        ((= fr-tag 1) (UR_Frozen main-dptf))
                        ((= fr-tag 2) (UR_Reservation main-dptf))
                        BAR
                    )
                )
                (secondary-special-id:string
                    (cond
                        ((= fr-tag 1) (UR_Frozen secondary-dptf))
                        ((= fr-tag 2) (UR_Reservation secondary-dptf))
                        BAR
                    )
                )
                (iz-secondary-rt:bool (URC_IzRT secondary-dptf))
                (iz-secondary-rbt:bool (URC_IzRBT secondary-dptf))
                (main-dptf-ftc:string (take 2 main-dptf))
            )
            (CAP_Owner main-dptf)
            (CAP_Owner secondary-dptf)
            (enforce
                (and (= main-special-id BAR) (= secondary-special-id BAR) )
                "Special True Fungible Links (Frozen or Reserved) are immutable !"
            )
            ;;UNREACHABLE -- <secondary-dptf> is ALWAYS a token issued moments earlier, and a
            ;;just-issued token can be neither an RT nor a Cold-RBT (both require registration on
            ;;an ATS pair, which cannot have happened yet). The single caller,
            ;;VST::XI_CreateSpecialTrueFungibleLink, calls DPTF::XB_IssueFree and passes THAT id
            ;;straight into XE_UpdateSpecialTrueFungible in the same expression -- there is no input
            ;;by which a client names the secondary. Fail-closed backstop for a future caller that
            ;;does. Its sibling one `cond` below (the Special/LP prefix rule on the MAIN token) IS
            ;;reachable and is pinned by REPL/modules/VST.repl <<VST-G9>>.
            (enforce
                (and (not iz-secondary-rt) (not iz-secondary-rbt))
                "Special True Fungible cannot be RTs or Cold-RBTs"
            )
            (cond
                ((= fr-tag 1)
                    (enforce
                        (not (contains main-dptf-ftc ["R|" "F|"]))
                        (format "When setting a Frozen Link, the main DPTF {} cannot be a Special Token" [main-dptf])
                        ;;But can be an LP Token
                    )
                )
                ((= fr-tag 2)
                    (enforce
                        (not (contains main-dptf-ftc ["R|" "F|" "S|" "W|" "P|"]))
                        (format "When setting a Reserve Link, the main DPTF {} cannot be a Special or LP Token" [main-dptf])
                    )
                )
                true
            )
            (compose-capability (SECURE))
        )
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
    ;;
    (defun UDC_VerumRoles:object{DPTF|RoleSchema}
        (a:[string] b:[string] c:[string] d:[string] e:[string])
        {"a-frozen"             : a
        ,"r-burn"               : b
        ,"r-mint"               : c
        ,"r-fee-exemption"      : d
        ,"r-transfer"           : e}
    )
    (defun UDC_TrueFungibleAccount:object{OuronetDalosV2.DPTF|BalanceSchema}
        (a:decimal b:bool c:bool d:bool e:bool f:bool g:string h:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UDC_TrueFungibleAccount a b c d e f g h)
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_IdAccount:string (id:string account:string)
        (format "{}{}{}" [id BAR account])
    )
    (defun UC_VolumetricTax (id:string amount:decimal)
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
            )
            (UEV_Amount id amount)
            (ref-U|DPTF::UC_VolumetricTax (UR_Decimals id) amount)
        )
    )
    (defun UC_TreasuryLowestDispo
        (ouro-supply:decimal ouro-precision:integer dispo-type:integer tdp:decimal tds:decimal)
        (let
            (
                (max-dispo:decimal
                    (cond
                        ((= dispo-type 1) ouro-supply)
                        ((= dispo-type 2) (floor (/ (* tdp ouro-supply) 1000.0) ouro-precision))
                        ((= dispo-type 3) (floor (* tds 1000.0) ouro-precision))
                        0.0
                    )
                )
            )
            (- 0.0 max-dispo)
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URU_UpgradeTruefungibleToV2 (ids:[string])
        (map
            (lambda
                (id:string)
                (UR_Hibernation id)
            )
            ids
        )
    )
    (defun UR_P-KEYS:[string] ()
        (keys DPTF|PropertiesTable)
    )
    (defun UR_KEYS:[string] ()
        (keys DPTF|BalanceTable)
    )
    ;;
    ;;
    (defun UR_Konto:string (id:string)
        (at "owner-konto" (read DPTF|PropertiesTable id ["owner-konto"]))
    )
    (defun UR_Name:string (id:string)
        (at "name" (read DPTF|PropertiesTable id ["name"]))
    )
    (defun UR_Ticker:string (id:string)
        (at "ticker" (read DPTF|PropertiesTable id ["ticker"]))
    )
    (defun UR_Decimals:integer (id:string)
        (at "decimals" (read DPTF|PropertiesTable id ["decimals"]))
    )
    ;;
    (defun UR_CanUpgrade:bool (id:string)
        (at "can-upgrade" (read DPTF|PropertiesTable id ["can-upgrade"]))
    )
    (defun UR_CanChangeOwner:bool (id:string)
        (at "can-change-owner" (read DPTF|PropertiesTable id ["can-change-owner"]))
    )
    (defun UR_CanAddSpecialRole:bool (id:string)
        (at "can-add-special-role" (read DPTF|PropertiesTable id ["can-add-special-role"]))
    )
    (defun UR_CanFreeze:bool (id:string)
        (at "can-freeze" (read DPTF|PropertiesTable id ["can-freeze"]))
    )
    (defun UR_CanWipe:bool (id:string)
        (at "can-wipe" (read DPTF|PropertiesTable id ["can-wipe"]))
    )
    (defun UR_CanPause:bool (id:string)
        (at "can-pause" (read DPTF|PropertiesTable id ["can-pause"]))
    )
    ;;
    (defun UR_Paused:bool (id:string)
        (at "is-paused" (read DPTF|PropertiesTable id ["is-paused"]))
    )
    ;;
    (defun UR_Supply:decimal (id:string)
        (at "supply" (read DPTF|PropertiesTable id ["supply"]))
    )
    (defun UR_OriginMint:bool (id:string)
        (at "origin-mint" (read DPTF|PropertiesTable id ["origin-mint"]))
    )
    (defun UR_OriginAmount:decimal (id:string)
        (at "origin-mint-amount" (read DPTF|PropertiesTable id ["origin-mint-amount"]))
    )
    ;;
    (defun UR_FeeToggle:bool (id:string)
        (at "fee-toggle" (read DPTF|PropertiesTable id ["fee-toggle"]))
    )
    (defun UR_MinMove:decimal (id:string)
        (at "min-move" (read DPTF|PropertiesTable id ["min-move"]))
    )
    (defun UR_FeePromile:decimal (id:string)
        (at "fee-promile" (read DPTF|PropertiesTable id ["fee-promile"]))
    )
    (defun UR_FeeTarget:string (id:string)
        (at "fee-target" (read DPTF|PropertiesTable id ["fee-target"]))
    )
    (defun UR_FeeLock:bool (id:string)
        (at "fee-lock" (read DPTF|PropertiesTable id ["fee-lock"]))
    )
    (defun UR_FeeUnlocks:integer (id:string)
        (at "fee-unlocks" (read DPTF|PropertiesTable id ["fee-unlocks"]))
    )
    (defun UR_PrimaryFeeVolume:decimal (id:string)
        (at "primary-fee-volume" (read DPTF|PropertiesTable id ["primary-fee-volume"]))
    )
    (defun UR_SecondaryFeeVolume:decimal (id:string)
        (at "secondary-fee-volume" (read DPTF|PropertiesTable id ["secondary-fee-volume"]))
    )
    ;;
    (defun UR_RewardToken:[string] (id:string)
        (at "reward-token" (read DPTF|PropertiesTable id ["reward-token"]))
    )
    (defun UR_RewardBearingToken:[string] (id:string)
        (at "reward-bearing-token" (read DPTF|PropertiesTable id ["reward-bearing-token"]))
    )
    ;;
    (defun UR_Vesting:string (id:string)
        (at "vesting-link" (read DPTF|PropertiesTable id ["vesting-link"]))
    )
    (defun UR_Sleeping:string (id:string)
        (at "sleeping-link" (read DPTF|PropertiesTable id ["sleeping-link"]))
    )
    (defun UR_Hibernation:string (id:string)
        ;;#30M fix: was a "read" that silently backfilled a missing hibernation-link with a
        ;;live table `update` - a read/write-separation violation of the UR_* prefix contract.
        ;;Confirmed via a live StoaChain dirty-read (2026-08-28, see
        ;;OuronetInformational/memories/2026-08-28-querying-live-stoachain-via-pythia-dirty-read.md)
        ;;that every one of the 18 real deployed DPTF tokens already has this field populated -
        ;;the backfill branch was fully dead code, so no migration step was needed. The write is
        ;;removed; the in-memory default-value fallback (for any future schema-incomplete row)
        ;;is kept, so the return value is unchanged for every caller.
        (let
            (
                (default-value:string BAR)
                (temp (read DPTF|PropertiesTable id ["hibernation-link"]))
                (needs-populate:bool (= temp {}))
            )
            (if needs-populate default-value (at "hibernation-link" temp))
        )
    )
    (defun UR_Frozen:string (id:string)
        (at "frozen-link" (read DPTF|PropertiesTable id ["frozen-link"]))
    )
    (defun UR_Reservation:string (id:string)
        (at "reservation-link" (read DPTF|PropertiesTable id ["reservation-link"]))
    )
    (defun UR_IzReservationOpen:bool (id:string)
        (at "reservation" (read DPTF|PropertiesTable id ["reservation"]))
    )
    ;;
    (defun UR_IzId:bool (id:string)
        (let
            (
                (trial (try false (read DPTF|PropertiesTable id))) 
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    ;;
    ;;
    (defun UR_Verum1:[string] (id:string)
        (at "a-frozen" (read DPTF|RoleTable id ["a-frozen"]))
    )
    (defun UR_Verum2:[string] (id:string)
        (at "r-burn" (read DPTF|RoleTable id ["r-burn"]))
    )
    (defun UR_Verum3:[string] (id:string)
        (at "r-mint" (read DPTF|RoleTable id ["r-mint"]))
    )
    (defun UR_Verum4:[string] (id:string)
        (at "r-fee-exemption" (read DPTF|RoleTable id ["r-fee-exemption"]))
    )
    (defun UR_Verum5:[string] (id:string)
        (at "r-transfer" (read DPTF|RoleTable id ["r-transfer"]))
    )
    ;;
    ;;
    (defun UR_IzAccount:bool (id:string account:string)
        (let
            (
                (trial (try false (read DPTF|BalanceTable (UC_IdAccount id account))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun UR_AccountSupply:decimal (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::UR_TF_AccountSupply account (= id (ref-DALOS::UR_OuroborosID)))
                (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                    { "balance" : 0.0 }
                    { "balance" := b}
                    b
                )
            )
        )
    )
    (defun UR_AccountFrozenState:bool (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (and
                (if (URC_IzCoreDPTF id)
                    (ref-DALOS::UR_TF_AccountFreezeState account (= id (ref-DALOS::UR_OuroborosID)))
                    (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                        { "frozen" : false}
                        { "frozen" := fr }
                        fr
                    )
                )
                (not (ref-DALOS::UR_AutonomicRoles account))
            )
        )
    )
    (defun UR_AccountRoleBurn:bool (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (if (URC_IzCoreDPTF id)
                    (ref-DALOS::UR_TF_AccountRoleBurn account (= id (ref-DALOS::UR_OuroborosID)))
                    (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                        { "role-burn" : false}
                        { "role-burn" := rb }
                        rb
                    )
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
            
        )
    )
    (defun UR_AccountRoleMint:bool (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (if (URC_IzCoreDPTF id)
                    (ref-DALOS::UR_TF_AccountRoleMint account (= id (ref-DALOS::UR_OuroborosID)))
                    (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                        { "role-mint" : false}
                        { "role-mint" := rm }
                        rm
                    )
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
        )
    )
    (defun UR_AccountRoleTransfer:bool (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (or
                (if (URC_IzCoreDPTF id)
                    (ref-DALOS::UR_TF_AccountRoleTransfer account (= id (ref-DALOS::UR_OuroborosID)))
                    (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                        { "role-transfer" : false}
                        { "role-transfer" := rt }
                        rt
                    )
                )
                (ref-DALOS::UR_AutonomicRoles account)
            )
            
        )
    )
    (defun UR_AccountRoleFeeExemption:bool (id:string account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (owner:string (UR_Konto id))
            )
            (fold (or) false
                [
                    (if (URC_IzCoreDPTF id)
                        (ref-DALOS::UR_TF_AccountRoleFeeExemption account (= id (ref-DALOS::UR_OuroborosID)))
                        (with-default-read DPTF|BalanceTable (UC_IdAccount id account)
                            { "role-fee-exemption" : false}
                            { "role-fee-exemption" := rfe }
                            rfe
                        )
                    )
                    (= account owner)
                    (ref-DALOS::UR_AutonomicRoles account)
                ]
            )
        )
    )
    (defun URC_IzRT:bool (reward-token:string)
        @doc "Returns a boolean, if token id is RT in any atspair"
        (UEV_id reward-token)
        (if (= (UR_RewardToken reward-token) [BAR])
            false
            true
        )
    )
    (defun URC_IzRTg:bool (atspair:string reward-token:string)
        @doc "Returns a boolean, if token id is RT in a specific atspair"
        (UEV_id reward-token)
        (if (= (UR_RewardToken reward-token) [BAR])
            false
            (if (= (contains atspair (UR_RewardToken reward-token)) true)
                true
                false
            )
        )
    )
    (defun URC_IzRBT:bool (reward-bearing-token:string)
        @doc "Returns a boolean, if token id is RBT in any atspair"
        (UEV_id reward-bearing-token)
        (if (= (UR_RewardBearingToken reward-bearing-token) [BAR])
            false
            true
        )
    )
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string)
        @doc "Returns a boolean, if token id is RBT in a specific atspair"
        (UEV_id reward-bearing-token)
        (if (= (UR_RewardBearingToken reward-bearing-token) [BAR])
            false
            (if (contains atspair (UR_RewardBearingToken reward-bearing-token))
                true
                false
            )
        )
    )
    (defun URC_IzCoreDPTF:bool (id:string)
        @doc "Returns a boolean, if id is a Core DPTF \
            \ Core DPTFs are OUROBOROS and IGNIS"
        (UEV_id id)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (iz-ouro-defined:bool (not (= ouro-id BAR)))
                (iz-ignis-defined:bool (not (= ignis-id BAR)))
            )
            (if (not iz-ouro-defined)
                (if (not iz-ignis-defined)
                        false
                        (= id ignis-id)
                    )
                (if (= id ouro-id)
                    true
                    (if (not iz-ignis-defined)
                        false
                        (= id ignis-id)
                    )
                )
            )
        )
    )
    (defun URC_Fee:[decimal] (id:string amount:decimal)
        @doc "Computes the DPTF transfer fee split given a DPTF Id and amount \
            \ Returns a list of decimals: \
            \ <primary-fee-value> - the actual transfer fee \
            \ <secondary-fee-value> - results when to many Fee-Unlocks have been executed \
            \ <remainder> - the Token amount that reaches the target"
        (let
            (
                (fee-toggle:bool (UR_FeeToggle id))
            )
            (if (= fee-toggle false)
                [0.0 0.0 amount]
                (let
                    (
                        (precision:integer (UR_Decimals id))
                        (fee-promile:decimal (UR_FeePromile id))
                        (fee-unlocks:integer (UR_FeeUnlocks id))
                        (volumetric-fee:decimal (UC_VolumetricTax id amount))
                        (primary-fee-value:decimal
                            (if (= fee-promile -1.0)
                                volumetric-fee
                                (floor (* (/ fee-promile 1000.0) amount) precision)
                            )
                        )
                        (secondary-fee-value:decimal
                            (if (= fee-unlocks 0)
                                0.0
                                (* (dec fee-unlocks) volumetric-fee)
                            )
                        )
                        (remainder:decimal (- amount (+ primary-fee-value secondary-fee-value)))
                    )
                    [primary-fee-value secondary-fee-value remainder]
                )
            )
        )
    )
    ;;
    (defun URC_HasVesting:bool (id:string)
        @doc "Returns a boolean if DPTF has a vesting counterpart"
        (if (= (UR_Vesting id) BAR)
            false
            true
        )
    )
    (defun URC_HasSleeping:bool (id:string)
        @doc "Returns a boolean if DPTF has a sleeping counterpart"
        (if (= (UR_Sleeping id) BAR)
            false
            true
        )
    )
    (defun URC_HasHibernation:bool (id:string)
        @doc "Returns a boolean if DPTF has a hibernation counterpart"
        (if (= (UR_Hibernation id) BAR)
            false
            true
        )
    )
    (defun URC_HasFrozen:bool (id:string)
        @doc "Returns a boolean if DPTF has a frozen counterpart"
        (if (= (UR_Frozen id) BAR)
            false
            true
        )
    )
    (defun URC_HasReserved:bool (id:string)
        @doc "Returns a boolean if DPTF has a reserved counterpart"
        (if (= (UR_Reservation id) BAR)
            false
            true
        )
    )
    (defun URCv_Parent:string (dptf:string)
        @doc "Computes <dptf> parent"
        (let
            (
                (fourth:string (drop 3 (take 4 dptf)))
            )
            (enforce (!= fourth BAR) "Frozen LP Tokens not allowed for this operation")
            (let
                (
                    (first-two:string (take 2 dptf))
                )
                (cond
                    ((= first-two "F|") (UR_Frozen dptf))
                    ((= first-two "R|") (UR_Reservation dptf))
                    dptf
                )
            )
        )
    )
    (defun URC_TreasuryLowestDispo:decimal ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
            )
            (UC_TreasuryLowestDispo
                (UR_Supply ouro)
                (UR_Decimals ouro)
                (ref-DALOS::UR_DispoType)
                (ref-DALOS::UR_DispoTDP)
                (ref-DALOS::UR_DispoTDS)
            )
        )
    )
    ;;
    ;;  [URD]
    ;;
    ;;1] Returns True Fungibles held by Account
    (defun URH_HeldTrueFungibles:[string] (account:string)
        @doc "Returns all True Fungibles that are registered for a given <account>"
        (map (at "id")
            (select DPTF|BalanceTable ["id"]
                (where "account" (= account))
            )
        )
    )
    ;;2]Returns Accounts that are registered for a given DPTF
    (defun URH_ExistingTrueFungibles:[string] (dptf:string)
        @doc "Returns all Ouronet Accounts that are registered for a given <dptf>"
        (map (at "account")
            (select DPTF|BalanceTable ["account"]
                (where "id" (= dptf))
            )
        )
    )
    ;;3]Returns a List of DPTFs that are owned by a given Account for Management Purposes
    (defun URH_OwnedTrueFungibles:[string] (account:string)
        @doc "Returns all True Fungibles that can be managed by the given <account>"
        (map (at "id")
            (select DPTF|PropertiesTable ["id"]
                (where "owner-konto" (= account))
            )
        )
    )
    ;;
    ;;[URCi] cost readers — the single cost source per client/forward op. The C_/XE_ returns its URCi
    ;;  (billing); Phase 1.2 INFO previews from the same reader. Each == the prior inline cumulator.
    (defun URCi_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator} (entity-id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_BrandingCumulator (UR_Konto entity-id) 1.0)
        )
    )
    (defun URCi_RotateOwnership:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_RotateOwnership" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Control:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_Control" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_TogglePause:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_TogglePause" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleReservation:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleReservation" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFee:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleFee" "fee")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetMinMove:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_SetMinMove" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetFee:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_SetFee" "fee")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_SetFeeTarget:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_SetFeeTarget" "fee")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleFreezeAccount" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleBurnRole" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleMintRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleMintRole" "auth")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleFeeExemptionRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleFeeExemptionRole" "fee")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleTransferRole" "usage")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_WipeSlim:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_WipeSlim" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Wipe:object{IgnisCollectorV3.OutputCumulator} (id:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_Wipe" "setup")
                (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_Burn:object{IgnisCollectorV3.OutputCumulator} (id:string account:string)
        ;;REFUSAL PARITY (family K, 2026-09-15): this reader is shared by the exec's cumulator and
        ;;by INFO_DPTF|Burn, and without this line the PREVIEW narrated
        ;;"Succesfully burned 1.0 NOSUCHTOKEN-98c486052a51 on Account ..." for a token that does not
        ;;exist, while C_Burn refuses with UEV_id's own message. A non-existent token is a
        ;;STRUCTURAL impossibility -- no action by the caller makes the op available -- so the quote
        ;;was simply wrong, not merely optimistic about a balance. Guarded HERE rather than in the
        ;;INFO wrapper so both paths keep using one message.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-002b>>.
        (UEV_id id)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "DPTF|C_Burn" "usage") account (ref-IGNIS::URC_ZeroGAS id account) [])
        )
    )
    (defun URCi_Mint:object{IgnisCollectorV3.OutputCumulator} (id:string account:string origin:bool)
        ;;REFUSAL PARITY (family K, 2026-09-15): this reader is shared by the exec's cumulator and
        ;;by INFO_DPTF|Mint, and without this line the PREVIEW narrated
        ;;"Succesfully minted 1.0 NOSUCHTOKEN-98c486052a51 on Account ..." for a token that does not
        ;;exist, while C_Mint refuses with UEV_id's own message. A non-existent token is a
        ;;STRUCTURAL impossibility -- no action by the caller makes the op available -- so the quote
        ;;was simply wrong, not merely optimistic about a balance. Guarded HERE rather than in the
        ;;INFO wrapper so both paths keep using one message.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-002c>>.
        (UEV_id id)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_Mint" "usage")
                account (ref-IGNIS::URC_ZeroGAS id account) []
            )
        )
    )
    (defun URCi_UpdateSpecialTrueFungible:object{IgnisCollectorV3.OutputCumulator} (main-dptf:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_LegCumulator "special-tf-link" (UR_Konto main-dptf))
        )
    )
    ;;  Group C — pure cost readers whose cumulator/price were previously coupled to a write.
    ;;  ToggleFeeLock: full cumulator, re-derived from fee-unlocks (must be read PRE-increment — see C_).
    (defun URCi_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator} (id:string toggle:bool)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (unlock-costs:[decimal] (if toggle [0.0 0.0] (ref-IGNIS::UC_FeeUnlockPrice)))
                (gas-costs:decimal (+ (ref-IGNIS::UC_IgnisLeg "tier-small") (at 0 unlock-costs)))
                (output:bool (> (at 1 unlock-costs) 0.0))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs (UR_Konto id) (ref-IGNIS::URC_IsVirtualGasZero) [output])
        )
    )
    ;;  Issue: two native/gas price rails per issued token; the cumulator's output (created IDs) stays in XB_IssueFree.
    (defun URCi_IssueGas:decimal (token-count:integer)
        @doc "IGNIS issuance price per token. Sourced from the CENTRAL IG|DETER map in the \
            \ IGNIS module (rehaul substage 5, 1 ignis = 1 cent): true fungible issuance = $10 = 1000 ignis/token (owner 2026-09-05). \
            \ Shared by the exec path and its INFO_* preview, so both move as one."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            ;;deterrence scales PER TOKEN; the op's own compute is charged ONCE
            (+ (* (dec token-count) (ref-IGNIS::UC_IgnisDeter "issue-tf"))
               (ref-IGNIS::UC_IgnisComponents "DPTF|C_Issue"))
        )
    )
    (defun URCi_IssueStoa:decimal (token-count:integer)
        @doc "STOA leg of issuance, per token. Carries the SAME DOLLAR VALUE as the IGNIS deter \
            \ (true fungible = $10 => 100 STOA), converted at the live STOA price by UC_StoaPrice — so \
            \ when a real STOA price replaces the $0.10 peg the AMOUNT moves but the value the \
            \ user pays does not. Shared by the exec path and its INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (* (dec token-count) (ref-IGNIS::UC_StoaPrice "issue-tf"))
        )
    )
    ;;  UpgradeBranding: STOA price is unconditionally months x "blue" (BRD's XE_UpgradeBranding returns the same).
    (defun URCi_UpgradeBranding:decimal (months:integer)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (ref-BRD::URCi_UpgradeBranding months)
        )
    )
    ;;  DeployAccount: CORE C_DeployAccount returns no cumulator; the ignis|small toll is billed
    ;;  by Talos keyed on the deployed account. This reader single-sources that toll for exec + INFO.
    (defun URCi_DeployAccount:object{IgnisCollectorV3.OutputCumulator} (account:string)
        @doc "IGNIS cost of DELIBERATE token-account creation (the explicit C_DeployAccount \
            \ entrypoint, billed at its Talos wrapper): the central IG|DETER token-account tier \
            \ (50) — an anti-spam deterrent per owner 2026-09-05. Auto-creation inside a transfer \
            \ never reaches this reader and stays FREE (S1 constraint). Shared by exec + INFO_*."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_DeployAccount" "token-account")
                account (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    ;;  ToggleFeeLock STOA leg: the unlock price rail (0.0 when locking); mirrors the STOA amount
    ;;  C_ToggleFeeLock collects (at 1 (IGNIS::UC_FeeUnlockPrice)) — FLAT since 2026-09-06; the
    ;;  <fee-unlocks> count no longer scales it (this line described the retired ladder). Pure.
    (defun URCi_ToggleFeeLockStoa:decimal (id:string toggle:bool)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (if toggle 0.0 (at 1 (ref-IGNIS::UC_FeeUnlockPrice)))
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_ParentOwnership (dptf:string)
        @doc "Enforces: \
            \ <dptf> Ownership, if <dptf> is pure \
            \ <(UR_Frozen dptf)>, if its a f|dptf \
            \ (UR_Reservation dptf), if its a r|dptf \
            \ While ensuring a Frozen LP cant be used for this operation."
        (CAP_Owner (URCv_Parent dptf))
    )
    (defun UEV_id (id:string)
        (with-default-read DPTF|PropertiesTable id
            { "supply" : -1.0 }
            { "supply" := s }
            (enforce
                (>= s 0.0)
                (format "DPTF ID {} does not exist" [id])
            )
        )
    )
    (defun UEV_CheckID:bool (id:string)
        (with-default-read DPTF|PropertiesTable id
            { "supply" : -1.0 }
            { "supply" := s }
            (if (>= s 0.0)
                true
                false
            )
        )
    )
    (defun UEV_Amount (id:string amount:decimal)
        (let
            (
                (decimals:integer (UR_Decimals id))
            )
            (enforce
                (= (floor amount decimals) amount)
                (format "{} is not conform with the {} prec." [amount id])
            )
            (enforce
                (> amount 0.0)
                (format "{} is not a Valid Transaction amount" [amount])
            )
        )
    )
    (defun UEV_CheckAmount:bool (id:string amount:decimal)
        (let
            (
                (decimals:integer (UR_Decimals id))
                (decimal-check:bool (if (= (floor amount decimals) amount) true false))
                (positivity-check:bool (if (> amount 0.0) true false))
                (result:bool (and decimal-check positivity-check))
            )
            result
        )
    )
    (defun UEV_CanChangeOwnerON (id:string)
        (let
            (
                (x:bool (UR_CanChangeOwner id))
            )
            (enforce x (format "{} ownership cannot be changed" [id]))
        )
    )
    (defun UEV_CanUpgradeON (id:string)
        (let
            (
                (x:bool (UR_CanUpgrade id))
            )
            (enforce x (format "{} properties cannot be upgraded" [id]))
        )
    )
    (defun UEV_CanAddSpecialRoleON (id:string)
        (let
            (
                (x:bool (UR_CanAddSpecialRole id))
            )
            (enforce x (format "For {} no special roles can be added" [id])
            )
        )
    )
    (defun UEV_CanFreezeON (id:string)
        (let
            (
                (x:bool (UR_CanFreeze id))
            )
            (enforce x (format "{} cannot be freezed" [id])
            )
        )
    )
    (defun UEV_CanWipeON (id:string)
        (let
            (
                (x:bool (UR_CanWipe id))
            )
            (enforce x (format "{} cannot be wiped" [id])
            )
        )
    )
    (defun UEV_CanPauseON (id:string)
        (let
            (
                (x:bool (UR_CanPause id))
            )
            (enforce x (format "{} cannot be paused" [id])
            )
        )
    )
    (defun UEV_PauseState (id:string state:bool)
        (let
            (
                (x:bool (UR_Paused id))
            )
            ;;Arm 1 fires when the token is NOT paused (it enforces x = is-paused), so the old
            ;;wording "must not be paused for action" said the opposite of the condition that
            ;;produced it. Aligned with DPOF/DPDC/DPMF, which all word this arm "is already
            ;;unpaused". Arm 2 was already correct and is left as-is.
            (if state
                (enforce x (format "{} is already unpaused" [id]))
                (enforce (not x) (format "{} is paused; transfers are paused" [id]))
            )
        )
    )
    (defun UEV_ReservationState (id:string state:bool)
        (let
            (
                (x:bool (UR_IzReservationOpen id))
            )
            ;;Both messages were INVERTED: arm 1 enforces x (= is-open) so it fires when
            ;;reservations are CLOSED, yet reported "already open"; arm 2 fires when they are
            ;;OPEN and reported "already closed". Swapped, so each names the state that actually
            ;;tripped it -- the same "is already <current state>" shape the sibling
            ;;UEV_PauseState guards use across DPOF/DPDC/DPMF.
            (if state
                (enforce x (format "{} is already closed for reservations" [id]))
                (enforce (not x) (format "{} is already open for reservations" [id]))
            )
        )
    )
    (defun UEV_AccountBurnState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleBurn id account))
            )
            (enforce (= x state) (format "Burn Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountTransferState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleTransfer id account))
            )
            (enforce (= x state) (format "Transfer Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountFreezeState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountFrozenState id account))
            )
            (enforce (= x state) (format "Frozen for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_Virgin (id:string)
        (let
            (
                (om:bool (UR_OriginMint id))
                (oma:decimal (UR_OriginAmount id))
            )
            (enforce
                (and (= om false) (= oma 0.0))
                (format "Origin Mint for {} is offline" [id])
            )
        )
    )
    (defun UEV_FeeLockState (id:string state:bool)
        (let
            (
                (x:bool (UR_FeeLock id))
            )
            (enforce (= x state) (format "Fee-lock for {} must be set to {} for exec" [id state]))
        )
    )
    (defun UEV_FeeToggleState (id:string state:bool)
        (let
            (
                (x:bool (UR_FeeToggle id))
            )
            (enforce (= x state) (format "Fee-Toggle for {} must be set to {} for exec" [id state]))
        )
    )
    (defun UEV_AccountMintState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleMint id account))
            )
            (enforce (= x state) (format "Mint Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_AccountFeeExemptionState (id:string account:string state:bool)
        (let
            (
                (x:bool (UR_AccountRoleFeeExemption id account))
            )
            (enforce (= x state) (format "Fee-Exemption Role for {} on Account {} must be set to {} for exec" [id account state]))
        )
    )
    (defun UEV_Vesting (id:string existance:bool)
        (let
            (
                (has-vesting:bool (URC_HasVesting id))
            )
            (enforce (= has-vesting existance) (format "Vesting for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun UEV_Sleeping (id:string existance:bool)
        (let
            (
                (has-sleeping:bool (URC_HasSleeping id))
            )
            (enforce (= has-sleeping existance) (format "Sleeping for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun UEV_Hibernation (id:string existance:bool)
        (let
            (
                (has-hibernation:bool (URC_HasHibernation id))
            )
            (enforce (= has-hibernation existance) (format "Hibernation for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun UEV_Frozen (id:string existance:bool)
        (let
            (
                (has-frozen:bool (URC_HasFrozen id))
            )
            (enforce (= has-frozen existance) (format "Frozen for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun UEV_Reserved (id:string existance:bool)
        (let
            (
                (has-reserved:bool (URC_HasReserved id))
            )
            (enforce (= has-reserved existance) (format "Reserved for the Token {} is not satisfied with existance {}" [id existance]))
        )
    )
    (defun CAP_Owner (id:string)
        @doc "Enforces DPTF Token ID Ownership"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_Konto id))
        )
    )
    ;;{5.5}  Write [W]
    (defun WW_UpdateBalance (id:string account:string new-balance:decimal)
        (require-capability (SECURE))
        (let
            (
                (tk:string (UC_IdAccount id account))
                (data-obj:object (read DPTF|BalanceTable tk))
                (has-removable:bool (contains "exist" data-obj))
                (new-balance-obj:object
                    (+
                        {"balance" : new-balance}
                        (remove "balance" data-obj)
                    )
                )
            )
            (write DPTF|BalanceTable tk
                (if has-removable
                    (remove "exist" new-balance-obj)
                    new-balance-obj
                )
            )
        )
    )
    ;;{5.6}  Aux/X
    ;;Protection: Class 5 — IMC + Custom: SECURE
    (defun XE_IssueLP:object{IgnisCollectorV3.OutputCumulator}
        (name:string ticker:string)
        @doc "Issues a DPTF Token as a Liquidity Pool Token. A LP DPTF follows specific rules in naming."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (swp-sc:string (ref-DALOS::GOV|SWP|SC_NAME))
                )
                (XB_IssueFree swp-sc [name] [ticker] [24] [false] [false] [true] [false] [false] [false] [true])
            )
        )
    )
    ;;Protection: Class 5 — IMC + Custom: DPTF|C>ISSUE
    (defun XB_IssueFree:object{IgnisCollectorV3.OutputCumulator}
        (
            account:string
            name:[string]
            ticker:[string]
            decimals:[integer]
            ;;
            can-upgrade:[bool]
            can-change-owner:[bool]
            can-add-special-role:[bool]
            ;;
            can-freeze:[bool]
            can-wipe:[bool]
            can-pause:[bool]
            ;;
            iz-special:[bool]
        )
        (P|UEV_IMC)
        (with-capability (DPTF|C>ISSUE account name ticker decimals can-change-owner can-upgrade can-add-special-role can-freeze can-wipe can-pause)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-BRD:module{BrandingV2} BRD)
                    (l1:integer (length name))
                    (gas-costs:decimal (URCi_IssueGas l1))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (folded-lst:[string]
                        (fold
                            (lambda
                                (acc:[string] index:integer)
                                (let
                                    (
                                        (id:string
                                            (XIv_Issue
                                                account
                                                (at index name)
                                                (at index ticker)
                                                (at index decimals)
                                                (at index can-change-owner)
                                                (at index can-upgrade)
                                                (at index can-add-special-role)
                                                (at index can-freeze)
                                                (at index can-wipe)
                                                (at index can-pause)
                                                (at index iz-special)
                                            )
                                        )
                                    )
                                    (ref-BRD::XE_Issue id)
                                    (ref-U|LST::UC_AppL acc id)
                                )
                            )
                            []
                            (enumerate 0 (- l1 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConstructOutputCumulator gas-costs account trigger folded-lst)
            )
        )
    )
    ;;Enforce: per-element-in-map -- XB_IssueFree maps this over LISTS (name/ticker/decimals), so
    ;;          UEV_Decimals validates one element. DPTF|C>ISSUE receives the whole [integer] list and has
    ;;          no per-element loop; adding one purely for decimals is more code. (ATS does have such a
    ;;          loop, so ATS's copy was a true duplicate and was deleted.)
    ;;Protection: Class 2 — SECURE
    (defun XIv_Issue:string
        (
            account:string
            name:string
            ticker:string
            decimals:integer
            can-change-owner:bool
            can-upgrade:bool
            can-add-special-role:bool
            can-freeze:bool
            can-wipe:bool
            can-pause:bool
            iz-special:bool
        )
        (require-capability (SECURE))
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (id:string (ref-U|DALOS::UDC_Makeid ticker))
            )
            (ref-U|DALOS::UEV_Decimals decimals)
            (ref-U|DALOS::UEV_NameOrTicker name true iz-special)
            (ref-U|DALOS::UEV_NameOrTicker ticker false iz-special)
            (insert DPTF|PropertiesTable id
                {"id"                   : id
                ,"owner-konto"          : account
                ,"name"                 : name
                ,"ticker"               : ticker
                ,"decimals"             : decimals
                ;;
                ,"can-upgrade"          : can-upgrade
                ,"can-change-owner"     : can-change-owner
                ,"can-add-special-role" : can-add-special-role
                ,"can-freeze"           : can-freeze
                ,"can-wipe"             : can-wipe
                ,"can-pause"            : can-pause
                ;;
                ,"is-paused"            : false
                ;;
                ,"supply"               : 0.0
                ,"origin-mint"          : false
                ,"origin-mint-amount"   : 0.0
                ;;
                ,"fee-toggle"           : false
                ,"min-move"             : -1.0
                ,"fee-promile"          : 0.0
                ,"fee-target"           : OUROBOROS|SC_NAME
                ,"fee-lock"             : false
                ,"fee-unlocks"          : 0
                ,"primary-fee-volume"   : 0.0
                ,"secondary-fee-volume" : 0.0
                ;;
                ,"reward-token"         : [BAR]
                ,"reward-bearing-token" : [BAR]
                ;;
                ,"vesting-link"         : BAR
                ,"sleeping-link"        : BAR
                ,"frozen-link"          : BAR
                ,"reservation-link"     : BAR
                ,"hibernation-link"     : BAR
                ,"reservation"          : false}
            )
            (XI_WriteRoles id
                (UDC_VerumRoles
                    [BAR]
                    [BAR]
                    [BAR]
                    [BAR]
                    [BAR]
                )
            )
            (C_DeployAccount id account)
            id
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_DeployAccountWNE (account:string id:string)
        (P|UEV_IMC)
        (let
            (
                (exist-account:bool (UR_IzAccount id account))
            )
            (if (not exist-account)
                (C_DeployAccount id account)
                true
            )
        )
    )
    ;;1]DPTF|PropertiesTable
    ;;Protection: Class 3 — Custom: DPTF|S>ROTATE-OWNERSHIP
    (defun XI_ChangeOwnership (id:string new-owner:string)
        (require-capability (DPTF|S>ROTATE-OWNERSHIP id new-owner))
        (update DPTF|PropertiesTable id
            {"owner-konto"                      : new-owner}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>CONTROL
    (defun XI_Control (id:string can-upgrade:bool can-change-owner:bool can-add-special-role:bool can-freeze:bool can-wipe:bool can-pause:bool)
        (require-capability (DPTF|S>CONTROL id))
        (update DPTF|PropertiesTable id
            {"can-upgrade"                      : can-upgrade
            ,"can-change-owner"                 : can-change-owner
            ,"can-add-special-role"             : can-add-special-role
            ,"can-freeze"                       : can-freeze
            ,"can-wipe"                         : can-wipe
            ,"can-pause"                        : can-pause}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>TOGGLE_PAUSE
    (defun XI_TogglePause (id:string toggle:bool)
        (require-capability (DPTF|S>TOGGLE_PAUSE id toggle))
        (update DPTF|PropertiesTable id
            { "is-paused" : toggle}
        )
    )
    ;;Enforce: 5 call sites (C_Burn, C_Mint, C_Wipe, C_WipeSlim, XI_CPF_BurnFee) -- relocating UEV_Amount
    ;;          duplicates it 5x. AND read-and-write-in-one: the supply-underflow guard reads <supply> and
    ;;          writes it back, so a defcap would have to re-read the same row.
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XBv_UpdateSupply (id:string amount:decimal direction:bool)
        (P|UEV_IMC)
        (UEV_Amount id amount)
        (if (= direction true)
            (with-read DPTF|PropertiesTable id
                { "supply" := s }
                ;;UNREACHABLE BY ARITHMETIC -- unlike its twin on the debit branch below, which is a
                ;;live backstop. `UEV_Amount` runs FIRST (two lines up) and enforces `amount > 0.0`,
                ;;and a supply is never negative (this very pair of guards is what keeps it so). So
                ;;`(+ s amount)` is a positive added to a non-negative and cannot be < 0.0.
                ;;The DEBIT branch IS reachable -- `(- s amount)` goes negative when an account holds
                ;;more than the token's total supply -- and is driven by
                ;;REPL/modules/DPTF.repl <<DPTF-G12>>, which forces that corruption and watches this
                ;;message stop the burn. Both sites share the wording, so only that test proves one.
                (enforce (>= (+ s amount) 0.0) "DPTF Token Supply cannot be updated to negative values!")
                (update DPTF|PropertiesTable id { "supply" : (+ s amount)})
            )
            (with-read DPTF|PropertiesTable id
                { "supply" := s }
                (enforce (>= (- s amount) 0.0) "DPTF Token Supply cannot be updated to negative values!")
                (update DPTF|PropertiesTable id { "supply" : (- s amount)})
            )
        )
    )
    ;;
    ;;Protection: Class 3 — Custom: DPTF|S>TOGGLE_FEE
    (defun XI_ToggleFee(id:string toggle:bool)
        (require-capability (DPTF|S>TOGGLE_FEE id toggle))
        (update DPTF|PropertiesTable id
            { "fee-toggle" : toggle}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>SET_MIN-MOVE
    (defun XI_SetMinMove (id:string min-move-value:decimal)
        (require-capability (DPTF|S>SET_MIN-MOVE id min-move-value))
        (update DPTF|PropertiesTable id
            { "min-move" : min-move-value}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>SET_FEE
    (defun XI_SetFee (id:string fee:decimal)
        (require-capability (DPTF|S>SET_FEE id fee))
        (update DPTF|PropertiesTable id
            { "fee-promile" : fee}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>SET_FEE-TARGET
    (defun XI_SetFeeTarget (id:string target:string)
        (require-capability (DPTF|S>SET_FEE-TARGET id target))
        (update DPTF|PropertiesTable id
            { "fee-target" : target}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>X_TG_FEE-LOCK
    (defun XI_ToggleFeeLock:[decimal] (id:string toggle:bool)
        (require-capability (DPTF|S>X_TG_FEE-LOCK id toggle))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (update DPTF|PropertiesTable id
                { "fee-lock" : toggle}
            )
            (if (= toggle true)
                [0.0 0.0]
                (ref-IGNIS::UC_FeeUnlockPrice)
            )
        )
    )
    ;;Enforce: read-and-write-in-one -- <fee-unlocks> is read here and written back incremented, so a
    ;;          defcap would have to re-read the same row. The cap is economic, not cosmetic: URC_Fee
    ;;          prices every transfer's secondary fee at (fee-unlocks - 1) x volumetric-fee.
    ;;Protection: Class 2 — SECURE
    (defun XIv_IncrementFeeUnlocks (id:string)
        (require-capability (SECURE))
        (with-read DPTF|PropertiesTable id
            { "fee-unlocks" := fu }
            ;;UNTESTABLE-EXTERNALLY: XIv_IncrementFeeUnlocks sits behind (require-capability (SECURE)), and SECURE cannot be acquired from outside
            ;;this module -- so no REPL negative test can reach this line. The guard is LIVE and
            ;;does real work on the in-module path; it is NOT dead code. Distinguished from
            ;;the UNREACHABLE marker deliberately: that marker means no input can trip the guard at all.
            (enforce (< fu 7) (format "Cannot increment Fee Unlocks for Token {}" [id]))
            (update DPTF|PropertiesTable id
                {"fee-unlocks" : (+ fu 1)}
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateFeeVolume (id:string amount:decimal primary:bool)
        (P|UEV_IMC)
        (UEV_Amount id amount)
        (if primary
            (with-read DPTF|PropertiesTable id
                { "primary-fee-volume" := pfv }
                (update DPTF|PropertiesTable id
                    {"primary-fee-volume" : (+ pfv amount)}
                )
            )
            (with-read DPTF|PropertiesTable id
                { "secondary-fee-volume" := sfv }
                (update DPTF|PropertiesTable id
                    {"secondary-fee-volume" : (+ sfv amount)}
                )
            )
        )
    )
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateRewardToken (atspair:string id:string direction:bool)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (with-read DPTF|PropertiesTable id
                {"reward-token" := rt}
                (if (= direction true)
                    (if (= (at 0 rt) BAR)
                        (update DPTF|PropertiesTable id
                            {"reward-token" : [atspair]}
                        )
                        (update DPTF|PropertiesTable id
                            {"reward-token" : (ref-U|LST::UC_AppL rt atspair)}
                        )
                    )
                    ;;SENTINEL RESTORED ON REMOVE (2026-09-13). `UC_RemoveItem` is
                    ;;`(filter (!= item) in)`, so removing the LAST remaining atspair yields the bare
                    ;;empty list -- breaking the `[BAR]`-sentinel invariant that the ADD branch
                    ;;directly above this one is careful to maintain. The two branches were
                    ;;asymmetric: ADD understood the sentinel, REMOVE did not.
                    ;;
                    ;;WHY IT MATTERED. `URC_IzRT` decides "is this token a reward token anywhere?" by
                    ;;`(if (= (UR_RewardToken id) [BAR]) false true)`. An empty list is not `[BAR]`,
                    ;;so the token would answer TRUE -- claiming to be a reward token while holding
                    ;;no pairs -- and every transfer of it routes into `TFT::URCx_CPF_RT`, which does
                    ;;`(enumerate 0 (- (length ats-pairs) 1))`. On an empty list that is
                    ;;`(enumerate 0 -1)` = the DESCENDING PAIR `[0, -1]`, so `(at 0 [])` faults.
                    ;;The token becomes permanently untransferable -- and un-repairable, because the
                    ;;ADD branch opens with `(at 0 rt)`, which faults on `[]` too.
                    ;;
                    ;;The `(> rt-position 0)` guard in `ATSU|C>X_REMOVE-SECONDARY` does NOT prevent
                    ;;this: it protects position 0 of the ATS PAIR's reward-token list, a different
                    ;;list from the DPTF's list of pairs. A token that is the sole SECONDARY RT of
                    ;;one pair passes that guard; the precondition is reachable through the ordinary
                    ;;`ATS|C_AddSecondary` client path (verified live).
                    ;;
                    ;;Restoring the sentinel is the minimal repair and is symmetric with ADD: lists
                    ;;of length >= 1 after the filter are untouched, so this changes behaviour ONLY
                    ;;in the case that was broken. Invariant swept by REPL/modules/ATS.repl <<ATS-F1>>.
                    (update DPTF|PropertiesTable id
                        {"reward-token" :
                            (let
                                (
                                    (remaining:[string] (ref-U|LST::UC_RemoveItem rt atspair))
                                )
                                (if (= (length remaining) 0) [BAR] remaining)
                            )
                        }
                    )
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateRewardBearingToken (atspair:string id:string)
        (P|UEV_IMC)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
            )
            (with-read DPTF|PropertiesTable id
                {"reward-bearing-token" := rbt}
                (if (= (at 0 rbt) BAR)
                    (update DPTF|PropertiesTable id
                        {"reward-bearing-token" : [atspair]}
                    )
                    (update DPTF|PropertiesTable id
                        {"reward-bearing-token" : (ref-U|LST::UC_AppL rbt atspair)}
                    )
                )
            )
        )
    )
    ;;
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateVesting (dptf:string dpof:string)
        (P|UEV_IMC)
        (update DPTF|PropertiesTable dptf
            {"vesting-link" : dpof}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateSleeping (dptf:string dpof:string)
        (P|UEV_IMC)
        (update DPTF|PropertiesTable dptf
            {"sleeping-link" : dpof}
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateHibernation (dptf:string dpof:string)
        (P|UEV_IMC)
        (update DPTF|PropertiesTable dptf
            {"hibernation-link" : dpof}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateFrozen (core-dptf:string frozen-dptf:string)
        (require-capability (SECURE))
        (update DPTF|PropertiesTable core-dptf
            {"frozen-link" : frozen-dptf}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateReserved (core-dptf:string reserved-dptf:string)
        (require-capability (SECURE))
        (update DPTF|PropertiesTable core-dptf
            {"reservation-link" : reserved-dptf}
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|S>TOGGLE_RESERVATION
    (defun XI_ToggleReservation (id:string toggle:bool)
        (require-capability (DPTF|S>TOGGLE_RESERVATION id toggle))
        (update DPTF|PropertiesTable id
            { "reservation" : toggle}
        )
    )
    ;;Protection: Class 5 — IMC + Custom: DPTF|C>UPDATE-SPECIAL
    (defun XE_UpdateSpecialTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (main-dptf:string secondary-dptf:string fr-tag:integer)
        (P|UEV_IMC)
        (with-capability (DPTF|C>UPDATE-SPECIAL main-dptf secondary-dptf fr-tag)
            (cond
                ((= fr-tag 1)
                    (do
                        (XI_UpdateFrozen main-dptf secondary-dptf)
                        (XI_UpdateFrozen secondary-dptf main-dptf)
                    )
                )
                ((= fr-tag 2)
                    (do
                        (XI_UpdateReserved main-dptf secondary-dptf)
                        (XI_UpdateReserved secondary-dptf main-dptf)
                    )
                )
                true
            )
            (URCi_UpdateSpecialTrueFungible main-dptf)
        )
    )
    ;;2]DPTF|RoleTable
    ;;Protection: Class 2 — SECURE
    (defun XI_WriteRoles (id:string verum-roles:object{DPTF|RoleSchema})
        (require-capability (SECURE))
        (write DPTF|RoleTable id verum-roles)
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum1 (id:string new-verum1:[string])
        (require-capability (SECURE))  
        (update DPTF|RoleTable id
            {"a-frozen" : new-verum1}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum2 (id:string new-verum2:[string])
        (require-capability (SECURE))  
        (update DPTF|RoleTable id
            {"r-burn" : new-verum2}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum3 (id:string new-verum3:[string])
        (require-capability (SECURE))  
        (update DPTF|RoleTable id
            {"r-mint" : new-verum3}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum4 (id:string new-verum4:[string])
        (require-capability (SECURE))  
        (update DPTF|RoleTable id
            {"r-fee-exemption" : new-verum4}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVerum5 (id:string new-verum5:[string])
        (require-capability (SECURE))  
        (update DPTF|RoleTable id
            {"r-transfer" : new-verum5}
        )
    )
    ;;3]DPTF|BalanceTable
    ;;Protection: Class 3 — Custom: DPTF|C>X_FREEZE
    (defun XI_ToggleFreezeAccount (id:string account:string toggle:bool)
        @doc "Toggle Verum 1"
        (require-capability (DPTF|C>X_FREEZE id account toggle))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::XE_UpdateFreeze account (= id (ref-DALOS::UR_OuroborosID)) toggle)
                (update DPTF|BalanceTable (UC_IdAccount id account)
                    { "frozen" : toggle}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|C>X_TOGGLE-BURN-ROLE
    (defun XI_ToggleBurnRole (id:string account:string toggle:bool)
        @doc "Toggle Verum 2"
        (require-capability (DPTF|C>X_TOGGLE-BURN-ROLE id account toggle))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::XE_UpdateBurnRole account (= id (ref-DALOS::UR_OuroborosID)) toggle)
                (update DPTF|BalanceTable (UC_IdAccount id account)
                    {"role-burn" : toggle}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|C>X_TOGGLE-MINT-ROLE
    (defun XI_ToggleMintRole (id:string account:string toggle:bool)
        @doc "Toggle Verum 3"
        (require-capability (DPTF|C>X_TOGGLE-MINT-ROLE id account toggle))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::XE_UpdateMintRole account (= id (ref-DALOS::UR_OuroborosID)) toggle)
                (update DPTF|BalanceTable (UC_IdAccount id account)
                    {"role-mint" : toggle}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE
    (defun XI_ToggleFeeExemptionRole (id:string account:string toggle:bool)
        @doc "Toggle Verum 4"
        (require-capability (DPTF|C>X_TOGGLE-FEE-EXEMPTION-ROLE id account toggle))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::XE_UpdateFeeExemptionRole account (= id (ref-DALOS::UR_OuroborosID)) toggle)
                (update DPTF|BalanceTable (UC_IdAccount id account)
                    {"role-fee-exemption" : toggle}
                )
            )
        )
    )
    ;;Protection: Class 3 — Custom: DPTF|C>X_TOGGLE-TRANSFER-ROLE
    (defun XI_ToggleTransferRole (id:string account:string toggle:bool)
        @doc "Toggle Verum 5"                
        (require-capability (DPTF|C>X_TOGGLE-TRANSFER-ROLE id account toggle))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                (ref-DALOS::XE_UpdateTransferRole account (= id (ref-DALOS::UR_OuroborosID)) toggle)
                (update DPTF|BalanceTable (UC_IdAccount id account)
                    {"role-transfer" : toggle}
                )
            )
        )
    )
    ;;
    ;;
    ;;Protection: Class 5 — IMC + Custom: DPTF|C>DEBIT
    (defun XB_DebitTrueFungible (id:string account:string amount:decimal dispo-data:object{UtilityDptfV2.DispoData} wipe-mode:bool)
        @doc "Debit DPTF <id> on <account> with <amount> \
            \ Ouronet Account <account> must exist \
            \ Assumes DPTF Account with key <(UC_IdAccount id account)> exists\
            \ Only Performs Debitation, does not update supply"
        (P|UEV_IMC)
        (with-capability (DPTF|C>DEBIT account id amount dispo-data wipe-mode)
            (let
                (
                    (current-supply:decimal (UR_AccountSupply id account))
                )
                (XI_UpdateBalance id account (- current-supply amount))
            )
        )
    )
    ;;Protection: Class 5 — IMC + Custom: DPTF|C>CREDIT
    (defun XB_CreditTrueFungible (id:string account:string amount:decimal)
        @doc "Debit DPTF <id> on <account> with <amount> \
            \ Ouronet Account <account> must exist \
            \ DPTF Account with key <(UC_IdAccount id account)> may exist or not\
            \ Only Performs Creditation, does not update supply"
        (P|UEV_IMC)
        (with-capability (DPTF|C>CREDIT account id amount)
            (XB_DeployAccountWNE account id)
            (let
                (
                    (current-supply:decimal (UR_AccountSupply id account))
                )
                (XI_UpdateBalance id account (+ current-supply amount))
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateBalance (id:string account:string new-balance:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (URC_IzCoreDPTF id)
                ;;Updates for Core Tokens
                (with-capability (P|DPTF|CALLER)
                    (ref-DALOS::XB_UpdateBalance account (= id (ref-DALOS::UR_OuroborosID)) new-balance)
                )
                ;;Updates for Non Core Tokens
                (WW_UpdateBalance id account new-balance)
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_UpdateTreasury (type:integer tdp:decimal tds:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (with-capability (GOV|SET_TREASURY-DISPO type tdp tds)
                (ref-DALOS::XE_UpdateTreasury type tdp tds)
            )
        )
    )
    (defun A_WipeTreasuryDebt ()
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (treasury-supply:decimal (UR_AccountSupply ouro treasury))
            )
            (with-capability (GOV|WIPE_ALL-TREASURY-DEBT)
                (C_Mint ouro treasury (abs treasury-supply) false)
                (ref-DALOS::XE_UpdateTreasury 0 0.0 0.0)
            )
        )
    )
    (defun A_WipeTreasuryDebtPartial (debt-to-be-wiped:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (treasury:string (at 0 (ref-DALOS::UR_DemiurgoiID)))
                (treasury-supply:decimal (UR_AccountSupply ouro treasury))
            )
            (with-capability (GOV|WIPE_PARTIAL-TREASURY-DEBT debt-to-be-wiped)
                (C_Mint ouro treasury debt-to-be-wiped false)
            )
        )
    )
    (defun AU_TrueFungibleAccounts (keyz:[string])
        @doc "Get <keyz> with <(UR_KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_TrueFungibleAccount) keyz)
        )
    )
    (defun AU_TrueFungibleAccount (ky:string)
        (require-capability (SECURE))
        (let
            (
                (input-obj:object (read DPTF|BalanceTable ky))
                (has-exist:bool (contains "exist" input-obj))
                (v1:object
                    (+
                        {"id" : (drop -163 ky)}
                        (remove "id" input-obj)
                    )
                )
                (v2:object
                    (+
                        {"account" : (take -162 ky)}
                        (remove "account" v1)
                    )
                )
                (v3:object
                    (if has-exist
                        (remove "exist" v2)
                        v2
                    )
                )
            )
            (write DPTF|BalanceTable ky v3)
        )
    )
    (defun AU_TrueFungibles (ids:[string])
        @doc "Get <ids> with <(UR_P-KEYS)>, or update one a time"
        (with-capability (AHU)
            (map (AU_TrueFungible) ids)
        )
    )
    (defun AU_TrueFungible (id:string)
        (require-capability (SECURE))
        (update DPTF|PropertiesTable id
            {"id"       : id}
        )
    )
    (defun C_UpdatePendingBranding:object{IgnisCollectorV3.OutputCumulator}
        (entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        (P|UEV_IMC)
        (let
            (
                (ref-BRD:module{BrandingV2} BRD)
            )
            (with-capability (DPTF|C>UPDATE-BRD entity-id)
                (ref-BRD::XE_UpdatePendingBranding entity-id logo description website social)
                (URCi_UpdatePendingBranding entity-id)
            )
        )
    )
    (defun C_UpgradeBranding (patron:string entity-id:string months:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-BRD:module{BrandingV2} BRD)
                (parent:string (URCv_Parent entity-id))
                (parent-owner:string (UR_Konto parent))
            )
            ;;Perform the branding upgrade (side effect); bill the STOA via the URCi (== XE_UpgradeBranding's price)
            (with-capability (DPTF|C>UPGRADE-BRD entity-id)
                (ref-BRD::XE_UpgradeBranding entity-id parent-owner months)
            )
            (ref-IGNIS::STOA|C_CollectWT patron (URCi_UpgradeBranding months) false)
        )
    )
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string name:[string] ticker:[string] decimals:[integer] can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (l1:integer (length name))
                (tl:[bool] (make-list l1 false))
                (stoa-costs:decimal (URCi_IssueStoa l1))
                (ico:object{IgnisCollectorV3.OutputCumulator}
                    (with-capability (SECURE)
                        (XB_IssueFree executor name ticker decimals can-upgrade can-change-owner can-add-special-role can-freeze can-wipe can-pause tl)
                    )
                )
            )
            (ref-IGNIS::STOA|C_Collect patron stoa-costs)
            ico
        )
    )
    (defun C_RotateOwnership:object{IgnisCollectorV3.OutputCumulator}
        (id:string new-owner:string)
        (P|UEV_IMC)
        (with-capability (DPTF|S>ROTATE-OWNERSHIP id new-owner)
            (XI_ChangeOwnership id new-owner)
            (URCi_RotateOwnership id)
        )
    )
    (defun C_Control:object{IgnisCollectorV3.OutputCumulator}
        (id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool)
        (P|UEV_IMC)
        (with-capability (DPTF|S>CONTROL id)
            (XI_Control id cu cco casr cf cw cp)
            (URCi_Control id)
        )
    )
    (defun C_TogglePause:object{IgnisCollectorV3.OutputCumulator}
        (id:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (DPTF|S>TOGGLE_PAUSE id toggle)
            (XI_TogglePause id toggle)
            (URCi_TogglePause id)
        )
    )
    (defun C_ToggleReservation:object{IgnisCollectorV3.OutputCumulator}
        (id:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (DPTF|S>TOGGLE_RESERVATION id toggle)
            (XI_ToggleReservation id toggle)
            (URCi_ToggleReservation id)
        )
    )
    ;;
    (defun C_ToggleFee:object{IgnisCollectorV3.OutputCumulator}
        (id:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (DPTF|S>TOGGLE_FEE id toggle)
            (XI_ToggleFee id toggle)
            (URCi_ToggleFee id)
        )
    )
    (defun C_SetMinMove:object{IgnisCollectorV3.OutputCumulator}
        (id:string min-move-value:decimal)
        (P|UEV_IMC)
        (with-capability (DPTF|S>SET_MIN-MOVE id min-move-value)
            (XI_SetMinMove id min-move-value)
            (URCi_SetMinMove id)
        )
    )
    (defun C_SetFee:object{IgnisCollectorV3.OutputCumulator}
        (id:string fee:decimal)
        (P|UEV_IMC)
        (with-capability (DPTF|S>SET_FEE id fee)
            (XI_SetFee id fee)
            (URCi_SetFee id)
        )
    )
    (defun C_SetFeeTarget:object{IgnisCollectorV3.OutputCumulator}
        (id:string target:string)
        (P|UEV_IMC)
        (with-capability (DPTF|S>SET_FEE-TARGET id target)
            (XI_SetFeeTarget id target)
            (URCi_SetFeeTarget id)
        )
    )
    (defun C_ToggleFeeLock:object{IgnisCollectorV3.OutputCumulator}
        (patron:string id:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (DPTF|C>TOGGLE_FEE-LOCK id toggle)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (toggle-costs:[decimal] (XI_ToggleFeeLock id toggle))
                    (stoa-costs:decimal (at 1 toggle-costs))
                    ;;URCi computed HERE — reads fee-unlocks BEFORE XIv_IncrementFeeUnlocks below mutates it
                    (cumulator:object{IgnisCollectorV3.OutputCumulator} (URCi_ToggleFeeLock id toggle))
                )
                (if (> stoa-costs 0.0)
                    (do
                        (XIv_IncrementFeeUnlocks id)
                        (ref-IGNIS::STOA|C_Collect patron stoa-costs)
                    )
                    true
                )
                cumulator
            )
        )
    )
    ;;
    (defun C_DeployAccount (id:string account:string)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (f:bool false)
                (tk:string (UC_IdAccount id account))
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (UEV_id id)
            (with-default-read DPTF|BalanceTable tk
                (UDC_TrueFungibleAccount 0.0 f f f f f id account)
                {"balance"                  := b
                ,"frozen"                   := f
                ,"role-burn"                := rb
                ,"role-mint"                := rm
                ,"role-transfer"            := rt
                ,"role-fee-exemption"       := rfe
                ,"id"                       := i
                ,"account"                  := a
                }
                (write DPTF|BalanceTable tk
                    (UDC_TrueFungibleAccount b f rb rm rt rfe i a)
                )
            )
        )
    )
    (defun C_ToggleFreezeAccount:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string toggle:bool)
        @doc "Toggle Verum 1"
        (P|UEV_IMC)
        (with-capability (DPTF|C>FREEZE id account toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-one:[string] (UR_Verum1 id))
                    (updated-verum-one:[string] (ref-U|DALOS::UCv_NewRoleList verum-one account toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE account id)
                ;;Update Verum Roles
                (XI_UpdateVerum1 id updated-verum-one)
                ;;Update Account Roles
                (XI_ToggleFreezeAccount id account toggle)
                ;;Output
                (URCi_ToggleFreezeAccount id)
            )
        )
    )
    (defun C_ToggleBurnRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string toggle:bool)
        @doc "Toggle Verum 2"
        (P|UEV_IMC)
        (with-capability (DPTF|C>TOGGLE-BURN-ROLE id account toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-two:[string] (UR_Verum2 id))
                    (updated-verum-two:[string] (ref-U|DALOS::UCv_NewRoleList verum-two account toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE account id)
                ;;Update Verum Roles
                (XI_UpdateVerum2 id updated-verum-two)
                ;;Update Account Roles
                (XI_ToggleBurnRole id account toggle)
                ;;Output
                (URCi_ToggleBurnRole id)
            )
        )
    )
    (defun C_ToggleMintRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string toggle:bool)
        @doc "Toggle Verum 3"
        (P|UEV_IMC)
        (with-capability (DPTF|C>TOGGLE-MINT-ROLE id account toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-three:[string] (UR_Verum3 id))
                    (updated-verum-three:[string] (ref-U|DALOS::UCv_NewRoleList verum-three account toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE account id)
                ;;Update Verum Roles
                (XI_UpdateVerum3 id updated-verum-three)
                ;;Update Account Roles
                (XI_ToggleMintRole id account toggle)
                ;;Output
                (URCi_ToggleMintRole id)
            )
        )
    )
    ;;Toggle Verum 4
    (defun C_ToggleFeeExemptionRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string toggle:bool)
        @doc "Toggle Verum 4"
        (P|UEV_IMC)
        (with-capability (DPTF|C>TOGGLE-FEE-EXEMPTION-ROLE id account toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-four:[string] (UR_Verum4 id))
                    (updated-verum-four:[string] (ref-U|DALOS::UCv_NewRoleList verum-four account toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE account id)
                ;;Update Verum Roles
                (XI_UpdateVerum4 id updated-verum-four)
                ;;Update Account Roles
                (XI_ToggleFeeExemptionRole id account toggle)
                ;;Output
                (URCi_ToggleFeeExemptionRole id)
            )
        )
    )
    ;;Toggle Verum 5
    (defun C_ToggleTransferRole:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string toggle:bool)
        @doc "Toggle Verum 5"
        (P|UEV_IMC)
        (with-capability (DPTF|C>TOGGLE_TRANSFER-ROLE id account toggle)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (verum-five:[string] (UR_Verum5 id))
                    (updated-verum-five:[string] (ref-U|DALOS::UCv_NewRoleList verum-five account toggle))
                )
                ;;Deploy WNE
                (XB_DeployAccountWNE account id)
                ;;Update Verum Roles
                (XI_UpdateVerum5 id updated-verum-five)
                ;;Update Account Roles
                (XI_ToggleTransferRole id account toggle)
                ;;Output
                (URCi_ToggleTransferRole id)
            )
        )
    )
    ;;
    (defun C_Burn:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
            )
            (with-capability (DPTF|C>BURN id account amount)
                (XB_DebitTrueFungible id account amount (ref-U|DPTF::UDC_EmptyDispo) false)
                (XBv_UpdateSupply id amount false)
                (URCi_Burn id account)
            )
        )
    )
    (defun C_Mint:object{IgnisCollectorV3.OutputCumulator}
        (id:string account:string amount:decimal origin:bool)
        (P|UEV_IMC)
        (with-capability (DPTF|C>MINT id account amount origin)
            (XB_CreditTrueFungible id account amount)
            (XBv_UpdateSupply id amount true)
            (if origin
                (update DPTF|PropertiesTable id
                    {"origin-mint"          : false
                    ,"origin-mint-amount"   : amount}
                )
                true
            )
            (URCi_Mint id account origin)
        )
    )
    ;;
    (defun C_WipeSlim:object{IgnisCollectorV3.OutputCumulator}
        (id:string account-to-be-wiped:string amount-to-be-wiped:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
            )
            (with-capability (DPTF|C>WIPE-SLIM id account-to-be-wiped amount-to-be-wiped)
                (XB_DebitTrueFungible id account-to-be-wiped amount-to-be-wiped (ref-U|DPTF::UDC_EmptyDispo) true)
                (XBv_UpdateSupply id amount-to-be-wiped false)
                (URCi_WipeSlim id)
            )
        )
    )
    (defun C_Wipe:object{IgnisCollectorV3.OutputCumulator}
        (id:string account-to-be-wiped:string)
        (P|UEV_IMC)
        (let
            (
                (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
                (amount-to-be-wiped:decimal (UR_AccountSupply id account-to-be-wiped))
            )
            (with-capability (DPTF|C>WIPE id account-to-be-wiped)
                (XB_DebitTrueFungible id account-to-be-wiped amount-to-be-wiped (ref-U|DPTF::UDC_EmptyDispo) true)
                (XBv_UpdateSupply id amount-to-be-wiped false)
                (URCi_Wipe id)
            )
        )
    )

)

;; --- tables for 05_DPTF.pact (5 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table DPTF|PropertiesTable)
;; (create-table DPTF|BalanceTable)
;; (create-table DPTF|RoleTable)


;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 7 of 20
;; This is STEP 7 of 21 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-6 must have run first, including the init steps between deploys.
;; 5 module(s), 321,972 gas measured in the REPL gas model, 276,537 bytes
;;
;; Modules in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/21_CODEX.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact
;;   1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
;;   1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/20_MTX-SWP.pact =================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v3   ·   dev: v4   ;; bumped by the StoicSyntax refactor — deploy v4 then set net: v4
(interface SwapperMtxV4
    @doc "Exposes SWP MultiStep (via defpact) Functions. \
        \ V3: issue pool caps use SwapperV4.PoolTokens (bumped with SwapperV4 row types)."

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
    ;;
    ;;  []C] Functions
    ;;
    ;;
    (defun C_IssueStablePool (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal amp:decimal p:bool))
    (defun C_IssueWeightedPool (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool))
    (defun C_IssueStandardPool (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal p:bool))
    ;;
    (defun C_AddStandardLiquidity (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_AddIcedLiquidity (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_AddGlacialLiquidity (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_AddFrozenLiquidity (patron:string executor:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun C_AddSleepingLiquidity (patron:string executor:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))

)
;;
;;HISTORICAL NOTE (owner, 2026-08-17, during SWP audit #C9): this module's whole reason to exist is
;;gas-limit-driven multi-step (defpact) issuance/liquidity flows, split across steps to stay under a
;;150k-gas-per-transaction ceiling that applied when this was written. StoaChain's actual live limit is
;;~2,000,000 gas per transaction (see OuronetInformational/pact5/SEMANTICS.md's gas table) — comfortably
;;enough headroom for even a 7-pool-token issuance to complete in a SINGLE transaction today. The
;;multi-step mechanism is therefore no longer technically required for gas reasons; it's kept live for
;;historical continuity (real pools — e.g. pool7 in the SWP audit's own REPL fixtures — were already
;;issued through it) and as a worked defpact/multi-step example elsewhere in the codebase. Any new
;;single-issuance flow does NOT need to be split into steps purely for gas headroom; that constraint no
;;longer applies. (This context is exactly what let #C9 slip through undetected for as long as it did:
;;SWPI::C_Issue, the single-tx path, remembered to call XE_AddLPTracker; this defpact path's own XE_Issue
;;call — added later, per the owner — never got the same follow-up wired in. Fixed by folding the
;;registration into XE_Issue itself, in 1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact, so every issuance path
;;gets it "for free" and this class of per-caller-remembers-it gap can't recur here.)
(module MTX-SWP GOV
    @doc "MTX-SWP (SwapperMtxV4) provides multi-step (defpact) versions of SWP pool issuance \
        \ and liquidity addition, originally to split work under an old per-transaction gas \
        \ ceiling (now kept for continuity/example, no longer strictly required). Its \
        \ defpacts stage validation, IGNIS/STOA collection, LP minting, and LP \
        \ transfer/freeze/sleep across steps with rollback, delegating writes to SWPL and \
        \ SWPI::XE_IssueWrite."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SwapperMtxV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_MTX-SWP                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|MTX-SWP_ADMIN)))
    (defcap GOV|MTX-SWP_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (master:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
                (g1:guard GOV|MD_MTX-SWP)
                (g2:guard (ref-DALOS::UR_AccountGuard master))
            )
            (enforce-one
                "MTX-SWP Ownership not verified"
                [
                    (enforce-guard g1)
                    (enforce-guard g2)
                ]
            )
        )
    )
    ;;{G5}  functions
    ;;
    (defun GOV|SWP|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|SWP|SC_NAME)
        )
    )
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
    (deftable P|T:{OuronetPolicyV2.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV2.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P4}  capabilities
    (defcap P|MTX-SWP|CALLER ()
        true
    )
    (defcap P|MTX-SWP|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|MTX-SWP|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT ()
        (compose-capability (P|MTX-SWP|REMOTE-GOV))
        (compose-capability (P|MTX-SWP|CALLER))
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
        (with-capability (GOV|MTX-SWP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|MTX-SWP_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPL:module{OuronetPolicyV2} SWPL)
                ;;#36M/M5 fix: MTX-SWP now calls SWPI::XE_IssueWrite (P|UEV_IMC-gated)
                ;;directly from MTX|C_Issue's Step 3, so MTX-SWP must register itself
                ;;as an approved IMC caller on SWPI too — same as every other module
                ;;it already calls into below.
                (ref-P|SWPI:module{OuronetPolicyV2} SWPI)
                (mg:guard (create-capability-guard (P|MTX-SWP|CALLER)))
            )
            (ref-P|VST::P|A_Add
                "MTX-SWP|RemoteSwpGov"
                (create-capability-guard (P|MTX-SWP|REMOTE-GOV))
            )
            (ref-P|SWP::P|A_Add
                "MTX-SWP|RemoteSwpGov"
                (create-capability-guard (P|MTX-SWP|REMOTE-GOV))
            )
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPL::P|A_AddIMP mg)
            (ref-P|SWPI::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst SWP|SC_NAME                               (GOV|SWP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;;
    ;;The INITIATION slice of a multi-step add-liquidity. Owner design, restated 2026-09-14:
    ;;step 0 takes this much for opening the pact, and the step that actually SUCCEEDS takes
    ;;the remainder of the op's lp-churn deterrent. The TOTAL is unchanged and still equals
    ;;the single-tx twin in 18_SWPLC.pact, so no door is cheaper than the other -- what
    ;;changes is WHEN the money moves, so a pact killed by an altered pool state costs its
    ;;owner this slice instead of the whole deterrent. See UC_AddLiquidityChurnRemainder.
    (defconst LQ|INITIATION-FEE:decimal                  100.0)
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    (defcap MTX-SWP|C>ISSUE-S-POOL (pool-tokens:[object{SwapperV4.PoolTokens}])
        @event
        (compose-capability (SECURE))
    )
    (defcap MTX-SWP|C>ISSUE-W-POOL (pool-tokens:[object{SwapperV4.PoolTokens}])
        @event
        (compose-capability (SECURE))
    )
    (defcap MTX-SWP|C>ISSUE-P-POOL (pool-tokens:[object{SwapperV4.PoolTokens}])
        @event
        (compose-capability (SECURE))
    )
    (defcap MTX-SWP|S>ADD-LQ (stoa-pid:decimal)
        @doc "Records the STOA-PID the MTX was initiated with"
        @event
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap MTX-SWP|C>ISSUE (p:bool)
        (compose-capability (P|DT))
        (if p
            (compose-capability (GOV|MTX-SWP_ADMIN))
            true
        )
    )
    ;;
    (defcap MTX-SWP|C>ADD-STANDARD-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (MTX-SWP|C>X-ADD-LQ swpair ld))
    )
    (defcap MTX-SWP|C>ADD-ICED-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (MTX-SWP|C-ADD-CHILLED-LQ swpair ld))
    )
    (defcap MTX-SWP|C>ADD-GLACIAL-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (compose-capability (MTX-SWP|C-ADD-CHILLED-LQ swpair ld))
    )
    (defcap MTX-SWP|C>ADD-FROZEN-LQ 
        (swpair:string frozen-dptf:string ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC) 
            )
            (ref-SWPLC::UEV_AddFrozenLiquidity swpair frozen-dptf)
            (compose-capability (MTX-SWP|C-ADD-CHILLED-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C>ADD-SLEEPING-LQ 
        (account:string swpair:string sleeping-dpof:string nonce:integer ld:object{SwapperLiquidityV2.LiquidityData})
        @event
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
            )
            (ref-SWPLC::UEV_AddSleepingLiquidity account swpair sleeping-dpof nonce)
            (compose-capability (MTX-SWP|C-ADD-DORMANT-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C-ADD-DORMANT-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC)
            )
            (ref-SWPLC::UEV_AddDormantLiquidity swpair)
            (compose-capability (MTX-SWP|C>X-ADD-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C-ADD-CHILLED-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC) 
            )
            (ref-SWPLC::UEV_AddChilledLiquidity swpair ld)
            (compose-capability (MTX-SWP|C>X-ADD-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C>X-ADD-LQ (swpair:string ld:object{SwapperLiquidityV2.LiquidityData})
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV2} SWPLC) 
            )
            (ref-SWPLC::UEV_AddLiquidity swpair ld)
            (compose-capability (P|DT))
        )
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
    (defun UR_PoolState:object{SwapperLiquidityV2.PoolState} (swpair:string)
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
            )
            (ref-SWPL::UDC_PoolState
                (ref-SWP::UR_Amplifier swpair)
                (ref-SWPL::UDC_PoolFees swpair)
                (ref-SWP::UR_PoolTokenSupplies swpair)
                (ref-SWP::UR_Weigths swpair)
                ;;
                (ref-SWP::URC_LpCapacity swpair)
                (ref-SWP::UR_SpecialFeeTargets swpair)
                (ref-SWP::UR_SpecialFeeTargetsProportions swpair)
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_IssueStablePool
        (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal amp:decimal p:bool)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|C>ISSUE-S-POOL pool-tokens)
            (MTX|C_Issue
                patron executor pool-tokens fee-lp
                (make-list (length pool-tokens) 1.0)
                amp p
            )
        )
    )
    (defun C_IssueWeightedPool
        (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|C>ISSUE-W-POOL pool-tokens)
            (MTX|C_Issue
                patron executor pool-tokens fee-lp
                weights
                -1.0 p
            )
        )
    )
    (defun C_IssueStandardPool
        (patron:string executor:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal p:bool)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|C>ISSUE-P-POOL pool-tokens)
            (MTX|C_Issue
                patron executor pool-tokens fee-lp
                (make-list (length pool-tokens) 1.0)
                -1.0 p
            )
        )
    )
    ;;
    (defun C_AddStandardLiquidity
        (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (MTX|C_AddLiquidity patron executor swpair input-amounts true true stoa-pid)
        )
    )
    (defun C_AddIcedLiquidity
        (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (MTX|C_AddLiquidity patron executor swpair input-amounts false true stoa-pid)
        )
    )
    (defun C_AddGlacialLiquidity
        (patron:string executor:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (MTX|C_AddLiquidity patron executor swpair input-amounts false false stoa-pid)
        )
    )
    (defun C_AddFrozenLiquidity
        (patron:string executor:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (MTX|C_AddFrozenLiquidity patron executor swpair frozen-dptf input-amount stoa-pid)
        )
    )
    (defun C_AddSleepingLiquidity
        (patron:string executor:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        (P|UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (MTX|C_AddSleepingLiquidity patron executor swpair sleeping-dpof nonce stoa-pid)
        )
    )
    (defun UC_AddLiquidityChurnKey:string (asymmetric-collection:bool gaseous-collection:bool)
        @doc "The IGNIS price key MTX|C_AddLiquidity must bill, chosen by the SAME two collection \
            \ flags that decide which variant it is running -- (t,t) Standard, (f,t) Iced, \
            \ (f,f) Glacial, matching the C_Add*Liquidity wrappers above and SWPLC's twins. \
            \ ADDED 2026-09-14 with the lp-churn repair below; see the step-0 comment."
        (cond
            ((and asymmetric-collection gaseous-collection) "SWP|C_AddStandardLiquidity")
            ((and (not asymmetric-collection) gaseous-collection) "SWP|C_AddIcedLiquidity")
            "SWP|C_AddGlacialLiquidity"
        )
    )
    (defun URCi_AddLiquidityInitiation:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "The INITIATION slice every multi-step add-liquidity pays in step 0, before \
            \ anything is validated. Deliberately small: step 0 only QUOTES, and a quote \
            \ that a stranger's ordinary trade can invalidate must not cost the quoter the \
            \ whole deterrent. The remainder is taken by URCi_AddLiquidityChurnRemainder in \
            \ the step that succeeds, so the TOTAL is unchanged."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
            )
        )
    )
    (defun URCi_AddLiquidityChurnRemainder:object{IgnisCollectorV3.OutputCumulator}
        (op-key:string)
        @doc "The rest of OP-KEY's lp-churn deterrent, after the step-0 initiation slice. \
            \ Charged in the EXECUTION step, i.e. only once the pool state has been checked \
            \ and the liquidity is actually being added. LQ|INITIATION-FEE + this = the full \
            \ UC_IgnisPrice the single-tx twin in 18_SWPLC.pact bills in one go; the split is \
            \ a timing change, not a discount. Pinned by modules/SWP.repl <<SWPX-LQSPLIT>>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (- (ref-IGNIS::UC_IgnisPrice op-key "lp-churn") LQ|INITIATION-FEE)
                SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
            )
        )
    )
    (defpact MTX|C_AddLiquidity 
        (
            patron:string account:string swpair:string input-amounts:[decimal] 
            asymmetric-collection:bool gaseous-collection:bool stoa-pid:decimal
        )
        ;;Adds Standard,Iced or Glacial Liquidity, as an MTX in 3 steps
        ;;
        ;;Step 0 Computation and Validation
        (step
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                    ;;
                    (pool-state:object{SwapperLiquidityV2.PoolState}
                        (UR_PoolState swpair)
                    )
                    (ld:object{SwapperLiquidityV2.LiquidityData}
                        (ref-SWPL::URC_LD swpair input-amounts)
                    )
                    (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                        (ref-SWPL::URC_STOA-PID|CLAD 
                            account swpair ld asymmetric-collection gaseous-collection stoa-pid
                        )
                    )
                )
                (require-capability (MTX-SWP|S>ADD-LQ stoa-pid))
                (yield
                    {"pool-state"   : pool-state
                    ,"ld"           : ld
                    ,"clad"         : clad}
                )
                ;;LP-CHURN REPAIR (2026-09-14). This charged a flat literal 100.0 while the
                ;;single-tx twin for the SAME operation charged UC_IgnisPrice "..." "lp-churn"
                ;;= 1051.0. Both are live P|UEV_IMC-gated Talos clients -- TS01-CP reaches here,
                ;;TS01-C3 reaches SWPLC -- so a liquidity provider could DECLINE the churn
                ;;deterrent simply by choosing the other door, at a tenth of the price, on the
                ;;route the gas station subsidises. A deterrent that can be declined is not one.
                ;;The earlier repair that put every add-liquidity op onto UC_IgnisPrice landed in
                ;;18_SWPLC.pact only, and nothing compared the two modules afterwards: each route
                ;;was measured against ITS OWN preview and both agreed with themselves.
                ;;Measured, exploit-first, at RedTeam/[RT-A]_Economics.repl <<RT-A-001>>.
                (ref-IGNIS::C_Collect patron (URCi_AddLiquidityInitiation))
                (format "MTX LqAdd. computed succesfully and collected {} IGNIS before discounts; 1|3"
                    [LQ|INITIATION-FEE])
            )
        )
        ;;Step 1, Adding Liquidity and Minting LP
        (step-with-rollback
            (resume
                {"pool-state"   := prev-pool-state
                ,"ld"           := ld
                ,"clad"         := clad
                }
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                        ;;
                        (current-pool-state:object{SwapperLiquidityV2.PoolState} (UR_PoolState swpair))
                        (primary:decimal (at "primary-lp" clad))
                        (secondary:decimal (at "secondary-lp" clad))
                        (sum-lp:decimal (+ primary secondary))
                    )
                    (enforce 
                        (= prev-pool-state current-pool-state) 
                        "Execution Step of Adding Liquidity cannot execute on altered pool state!"
                    )
                    ;;The lp-churn deterrent's REMAINDER is taken HERE, not in step 0, and only
                    ;;after the pool-state check above has passed. Step 0 takes the small
                    ;;LQ|INITIATION-FEE; the two sum to exactly what 18_SWPLC.pact's single-tx
                    ;;twin bills in one transaction. Before 2026-09-14 the whole deterrent was
                    ;;taken in step 0 -- ahead of the very check that decides whether the
                    ;;operation may happen at all -- so any stranger's ordinary swap moved the
                    ;;pool, failed this enforce, and destroyed the quoter's entire fee with no
                    ;;refund. Measured, exploit-first, at RedTeam/[RT-F]_Griefing.repl <<RT-F-001>>.
                    (ref-IGNIS::C_Collect patron
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators
                            [(URCi_AddLiquidityChurnRemainder
                                (UC_AddLiquidityChurnKey asymmetric-collection gaseous-collection))
                             (at "perfect-ignis-fee" (at "clad-op" clad))]
                            []
                        )
                    )
                    (if (and asymmetric-collection gaseous-collection)
                        (with-capability (MTX-SWP|C>ADD-STANDARD-LQ swpair ld)
                            ;;<asymmetric-collection=true> <gaseous-collection=true>
                            (ref-SWPL::XE_STOA-PID|AddLiquidity 
                                account swpair asymmetric-collection gaseous-collection stoa-pid ld clad
                            )
                        )
                        (if gaseous-collection
                            (with-capability (MTX-SWP|C>ADD-ICED-LQ swpair ld)
                                ;;<asymmetric-collection=false> <gaseous-collection=true>
                                (ref-SWPL::XE_STOA-PID|AddLiquidity 
                                    account swpair asymmetric-collection gaseous-collection stoa-pid ld clad
                                )
                            )
                            (with-capability (MTX-SWP|C>ADD-GLACIAL-LQ swpair ld)
                                ;;<asymmetric-collection=false> <gaseous-collection=false>
                                (ref-SWPL::XE_STOA-PID|AddLiquidity 
                                    account swpair asymmetric-collection gaseous-collection stoa-pid ld clad
                                )
                            )
                        )
                    )
                    (yield
                        {"primary-lp-amount"    : primary
                        ,"secondary-lp-amount"  : secondary}
                    )
                    (format "Succesfully Added Liquidity on {} and minted {} LP; 2|3" [swpair sum-lp])
                )
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                    )
                )
                (format "Inconsistent Pool State detected: Adding Liquidity not allowed; Stepped rolled back; 2|3" [swpair])
            )
        )
        ;;Step 2, transfering LP To Client
        (step
            (resume
                {"primary-lp-amount"    := primary
                ,"secondary-lp-amount"  := secondary
                }
                (with-capability (P|DT)
                    (let
                        (
                            (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                            (ref-TFT:module{TrueFungibleTransferV2} TFT)
                            (ref-VST:module{VestingV2} VST)
                            (ref-SWP:module{SwapperV4} SWP)
                            (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                            ;;
                            (lp-id:string (ref-SWP::UR_TokenLP swpair))
                            (ico1:object{IgnisCollectorV3.OutputCumulator}
                                (if (!= primary 0.0)
                                    (ref-TFT::C_Transfer lp-id SWP|SC_NAME account primary true)
                                    EOC
                                )
                            )
                            (ico2:object{IgnisCollectorV3.OutputCumulator}
                                (if (not asymmetric-collection)
                                    (ref-VST::C_Freeze SWP|SC_NAME account lp-id secondary)
                                    EOC
                                )
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Collect Last Gas
                        (ref-IGNIS::C_Collect patron 
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                [ico1 ico2] 
                                []
                            ) 
                        )
                        (if (not asymmetric-collection)
                            (format "Succesfully moved {} Native LP and {} Frozen LP to client; 3|3" [primary secondary])
                            (format "Succesfully moved {} Native LP to client; 2|2" [primary])
                        )
                    )
                )
            )
        )
    )
    (defpact MTX|C_AddFrozenLiquidity
        (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        ;;Adds Frozen Liquidity, as an MTX in 3 Steps
        ;;
        ;:Step 0, Computation and Validation
        (step
            (let
                (
                    (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                    ;;
                    (pool-state:object{SwapperLiquidityV2.PoolState}
                        (UR_PoolState swpair)
                    )
                    ;;
                    (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
                    (ptp:integer (ref-SWP::URv_PoolTokenPosition swpair dptf))
                    (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp input-amount))
                    (ld:object{SwapperLiquidityV2.LiquidityData}
                        (ref-SWPL::URC_LD swpair lq-lst)
                    )
                    (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                        (ref-SWPL::URC_STOA-PID|CLAD account swpair ld false false stoa-pid)
                    )
                )
                (require-capability (MTX-SWP|S>ADD-LQ stoa-pid))
                (yield
                    {"pool-state"   : pool-state
                    ,"ld"           : ld
                    ,"clad"         : clad}
                )
                ;;LP-CHURN REPAIR (2026-09-14) -- same defect as MTX|C_AddLiquidity's step 0
                ;;above, in this variant. The single-tx twin bills UC_IgnisPrice
                ;;"SWP|C_AddFrozenLiquidity" "lp-churn"; this billed a flat literal.
                (ref-IGNIS::C_Collect patron (URCi_AddLiquidityInitiation))
                (format "MTX Frozen LqAdd. computed succesfully and collected {} IGNIS before discounts; 1|3"
                    [LQ|INITIATION-FEE])
            )
        )
        ;;Step 1, Adding Liquidity and Minting LP
        (step-with-rollback
            (resume
                {"pool-state"   := prev-pool-state
                ,"ld"           := ld
                ,"clad"         := clad
                }
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        ;;
                        (current-pool-state:object{SwapperLiquidityV2.PoolState} (UR_PoolState swpair))
                        (secondary:decimal (at "secondary-lp" clad))
                    )
                    (enforce 
                        (= prev-pool-state current-pool-state) 
                        "Execution Step of Adding Liquidity cannot execute on altered pool state!"
                    )
                    (with-capability (MTX-SWP|C>ADD-FROZEN-LQ swpair frozen-dptf ld)
                        (let
                            (
                                (ref-DALOS:module{OuronetDalosV2} DALOS)
                                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                                ;;
                                ;;Move F|DPTF to vst-sc and burn it
                                (ico1:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-TFT::C_Transfer frozen-dptf account vst-sc input-amount true)
                                )
                                (ico2:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-DPTF::C_Burn frozen-dptf vst-sc input-amount)
                                )
                                (ico3:object{IgnisCollectorV3.OutputCumulator}
                                    (at "perfect-ignis-fee" (at "clad-op" clad))
                                )
                            )
                            ;;lp-churn REMAINDER taken here, after validation -- see the twin
                            ;;comment in MTX|C_AddLiquidity's execution step.
                            (ref-IGNIS::C_Collect patron 
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                    [(URCi_AddLiquidityChurnRemainder "SWP|C_AddFrozenLiquidity")
                                     ico1 ico2 ico3] []
                                )
                            )
                            (ref-SWPL::XE_STOA-PID|AddLiquidity vst-sc swpair false false stoa-pid ld clad)
                            (yield
                                {"secondary-lp-amount"  : secondary}
                            )
                            (format "Succesfully Added Frozen Liquidity on {} and minted {} LP; Stepped rolled back; 2|3" [swpair secondary])
                        )
                    )
                )
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                    )
                )
                (format "Inconsistent Pool State detected: Adding Liquidity not allowed; 2|3" [swpair])
            )
        )
        ;;Step 2, transfering LP To Client
        (step
            (resume
                {"secondary-lp-amount"  := secondary}
                (with-capability (P|DT)
                    (let
                        (
                            (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                            (ref-VST:module{VestingV2} VST)
                            (ref-SWP:module{SwapperV4} SWP)
                            (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                            ;;
                            (lp-id:string (ref-SWP::UR_TokenLP swpair))
                            (ico:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Freeze SWP|SC_NAME account lp-id secondary)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Collect Last Gas
                        (ref-IGNIS::C_Collect patron ico)
                        (format "Succesfuly frozen {} LP to Client; 3|3" [secondary])
                    )
                )
            )
        )
    )
    (defpact MTX|C_AddSleepingLiquidity
        (patron:string account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        ;;Adds Frozen Liquidity, as an MTX in 3 Steps
        ;;
        ;:Step 0, Computation and Validation
        (step
            (let
                (
                    (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-SWP:module{SwapperV4} SWP)
                    (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                    ;;
                    (pool-state:object{SwapperLiquidityV2.PoolState}
                        (UR_PoolState swpair)
                    )
                    ;;
                    (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
                    (ptp:integer (ref-SWP::URv_PoolTokenPosition swpair dptf))
                    (batch-amount:decimal (ref-DPOF::UR_NonceSupply sleeping-dpof nonce))
                    (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp batch-amount))
                    (ld:object{SwapperLiquidityV2.LiquidityData}
                        (ref-SWPL::URC_LD swpair lq-lst)
                    )
                    (clad:object{SwapperLiquidityV2.CompleteLiquidityAdditionData}
                        (ref-SWPL::URC_STOA-PID|CLAD account swpair ld true true stoa-pid)
                    )
                )
                (require-capability (MTX-SWP|S>ADD-LQ stoa-pid))
                (yield
                    {"pool-state"   : pool-state
                    ,"ld"           : ld
                    ,"clad"         : clad
                    ,"ba"           : batch-amount}
                )
                ;;LP-CHURN REPAIR (2026-09-14) -- same defect as MTX|C_AddLiquidity's step 0
                ;;above, in this variant. The single-tx twin bills UC_IgnisPrice
                ;;"SWP|C_AddSleepingLiquidity" "lp-churn"; this billed a flat literal.
                (ref-IGNIS::C_Collect patron (URCi_AddLiquidityInitiation))
                (format "MTX Sleeping LqAdd. computed succesfully and collected {} IGNIS before discounts; 1|3"
                    [LQ|INITIATION-FEE])
            )
        )
        ;;Step 1, Adding Liquidity and Minting LP
        (step-with-rollback
            (resume
                {"pool-state"   := prev-pool-state
                ,"ld"           := ld
                ,"clad"         := clad
                ,"ba"           := batch-amount
                }
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        ;;
                        (current-pool-state:object{SwapperLiquidityV2.PoolState} (UR_PoolState swpair))
                        (primary:decimal (at "primary-lp" clad))
                    )
                    (enforce 
                        (= prev-pool-state current-pool-state) 
                        "Execution Step of Adding Liquidity cannot execute on altered pool state!"
                    )
                    (with-capability (MTX-SWP|C>ADD-SLEEPING-LQ account swpair sleeping-dpof nonce ld)
                        (let
                            (
                                (ref-DALOS:module{OuronetDalosV2} DALOS)
                                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                                (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                                ;;
                                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                                (ignis-id:string (ref-DALOS::UR_IgnisID))
                                ;;
                                (nonce-md:[object] (ref-DPOF::UR_NonceMetaData sleeping-dpof nonce))
                                (release-date:time (at "release-date" (at 0 nonce-md)))
                                (present-time:time (at "block-time" (chain-data)))
                                (dt:integer (floor (diff-time release-date present-time)))
                                ;;
                                ;;Move Z|DPOF to vst-sc and burn it
                                (ico1:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-DPOF::C_Transfer sleeping-dpof [nonce] account vst-sc true)
                                )
                                (ico2:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-DPOF::C_Burn sleeping-dpof vst-sc nonce batch-amount)
                                )
                                (ico3:object{IgnisCollectorV3.OutputCumulator}
                                    (at "perfect-ignis-fee" (at "clad-op" clad))
                                )
                                ;;
                                ;;MOVE IGNIS to vst-sc, paying for the ignis-tax
                                (ico4:object{IgnisCollectorV3.OutputCumulator}
                                    (ref-TFT::C_Transfer ignis-id account vst-sc (at "total-ignis-tax-needed" clad) true)
                                )
                            )
                            ;;lp-churn REMAINDER taken here, after validation -- see the twin
                            ;;comment in MTX|C_AddLiquidity's execution step.
                            (ref-IGNIS::C_Collect patron 
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                    [(URCi_AddLiquidityChurnRemainder "SWP|C_AddSleepingLiquidity")
                                     ico1 ico2 ico3 ico4] []
                                )
                            )
                            (ref-SWPL::XE_STOA-PID|AddLiquidity vst-sc swpair true true stoa-pid ld clad)
                            (yield
                                {"primary-lp-amount"    : primary
                                ,"time-diff"            : dt}
                            )
                            (format "Succesfully Added Sleeping Liquidity on {} and minted {} LP; 2|3" [swpair primary])
                        )
                    )
                )
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                    )
                )
                (format "Inconsistent Pool State detected: Adding Liquidity not allowed; Stepped rolled back; 2|3" [swpair])
            )
        )
        ;;Step 2, transfering LP To Client
        (step
            (resume
                {"primary-lp-amount"    := primary
                ,"time-diff"            := dt}
                (with-capability (P|DT)
                    (let
                        (
                            (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                            (ref-VST:module{VestingV2} VST)
                            (ref-SWP:module{SwapperV4} SWP)
                            (ref-SWPL:module{SwapperLiquidityV2} SWPL)
                            ;;
                            (lp-id:string (ref-SWP::UR_TokenLP swpair))
                            (ico:object{IgnisCollectorV3.OutputCumulator}
                                (ref-VST::C_Sleep SWP|SC_NAME account lp-id primary dt)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Collect Last Gas
                        (ref-IGNIS::C_Collect patron ico)
                        (format "Succesfuly put to sleep {} LP to Client; 3|3" [primary])
                    )
                )
            )
        )
    )
    (defpact MTX|C_Issue
        (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        ;;Issues an SWPair, as MultiStep Transaction, to be used in case <C_Issue> cant fit inside one TX.
        ;;
        ;;Step 1 Validation
        (step
            (let
                (
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                )
                (require-capability (SECURE))
                ;;M11 FIX (2026-09-17) — AUTHORISATION BEFORE THE MONEY, per the 2026-09-14 ruling.
                ;;This conditional admin gate used to live ONLY in step 3's <MTX-SWP|C>ISSUE>, which
                ;;runs AFTER step 2 has irreversibly collected IGNIS + STOA. Measured by execution:
                ;;a p=true issuance committed 2,919.77 IGNIS + 459.0 STOA in step 2 and was then
                ;;refused in step 3 with "MTX-SWP Ownership not verified" -- no refund, no cancel,
                ;;and rolling back costs a further 53.00 IGNIS. The SINGLE-TRANSACTION twin refuses
                ;;the identical operation for ZERO, because <SWPI|C>ISSUE> hoisted this same branch
                ;;above <UEV_Issue> during that sweep. Same operation, two live Talos doors, and
                ;;only one charged you for a refusal -- selected by <p>, an undocumented raw bool.
                ;;
                ;;THE WHOLE CONDITIONAL FORM IS HOISTED, not the bare acquire: only a PERMISSIONED
                ;;issuance needs the admin key, so unwrapping the branch would convert a conditional
                ;;gate into an unconditional one and lock out every ordinary pool issuance. That is
                ;;the exact mistake CLAUDE.md records a scripted reorder making during the sweep.
                ;;<with-capability> rather than <compose-capability> because this is a defpact step,
                ;;not a defcap body; acquiring <GOV|MTX-SWP_ADMIN> runs its enforce-one and nothing
                ;;else, and step 3 re-acquires it unchanged.
                (if p
                    (with-capability (GOV|MTX-SWP_ADMIN) true)
                    true
                )
                (ref-SWPI::UEV_Issue account pool-tokens fee-lp weights amp p)
            )
        )
        ;;Step 2 Ignis Collection and STOA Fuel Processing
        (step-with-rollback
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-SWPI:module{SwapperIssueV4} SWPI)
                    ;;GS-04 REPAIR (2026-09-14). This step used to build its own cumulator inline
                    ;;while INFO_SWP|Issue*Pool previewed it through SWPI::URCi_Issue -- a reader
                    ;;tuned to the SINGLE-TX SWPI::C_Issue. Four preview legs totalling 6158 against
                    ;;this step's ONE leg of 5506: an over-quote of 652, and a leg-count mismatch
                    ;;that matters on its own because the cumulator discounts per leg. Both sides now
                    ;;read SWPI::URCi_IssuePool, so there is one source and no second place to drift.
                    (sum-ignis:decimal (ref-SWPI::URC_IssuePoolIgnis))
                    ;;
                    (stoa-costs:decimal 
                        (+ 
                            (ref-DALOS::UR_UsagePrice "dptf")
                            (ref-DALOS::UR_UsagePrice "swp")
                        )
                    )
                )
                ;;Collect IGNIS for Issuance
                (ref-IGNIS::C_Collect patron (ref-SWPI::URCi_IssuePool account pool-tokens))
                ;;Collect STOA for Issuance
                (ref-IGNIS::STOA|C_Collect patron stoa-costs)
                (let
                    (
                        (ref-ORBR:module{OuroborosV2} OUROBOROS)
                        (auto-fuel:bool (ref-DALOS::UR_AutoFuel))
                    )
                    (if auto-fuel
                        (do
                            (with-capability (P|DT)
                                (ref-ORBR::C_Fuel)
                            )
                            (format "{} IGNIS and {} STOA collected (raising SSTOA Index) succesfully; 2|3" [sum-ignis stoa-costs])
                        )
                        (format "{} IGNIS collected, with {} STOA collected (in reserves) succesfully; 2|3" [sum-ignis stoa-costs])
                    )
                )
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                )
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        100.0 SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                    )
                )
                (format "Insufficient IGNIS and STOA for Collection; Stepped rolled back{} 2|3" [";"])
            )
        )
        ;;Step 3 Issuance
        ;;#36M/M5 fix: the write sequence itself (mint/transfer/tracker) now lives in
        ;;SWPI::XE_IssueWrite — the shared forward-module entrypoint SWPI::C_Issue also
        ;;calls, instead of this step independently reimplementing it. Billing already
        ;;happened in Step 2, above, so only swpair/token-lp (indices 0/1) are needed
        ;;here — the sub-cumulators XE_IssueWrite also returns are for C_Issue's own
        ;;aggregation, not relevant to this already-billed path.
        (step
            (with-capability (MTX-SWP|C>ISSUE p)
                (let
                    (
                        (ref-SWPI:module{SwapperIssueV4} SWPI)
                        (write-result:list (ref-SWPI::XE_IssueWrite account pool-tokens fee-lp weights amp p))
                        (swpair:string (at 0 write-result))
                        (token-lp:string (at 1 write-result))
                    )
                    (format "Swpair with ID {} and LP Token {} ID created succesfully" [swpair token-lp])
                )
            )
        )
    )

)

;; --- tables for 20_MTX-SWP.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/21_CODEX.pact ===================
;; CODEX — Codex Identity registry + Arweave upload tracker + StoicTags (Stage 01 core #22).
;; Spec: OuronetInformational/01-mnemosyne-codex-pact-module.md
;; Nomenclature: OuronetInformational/MODULE_ARCHITECTURE.md
;; Client entrypoints: Talos TS01-C4 (StoicTag: 1 native STOA per glyph; fee wiring in TS01-C4).
;; Mnemosyne operator: ouronet-ns.codex-keyset (define before A_RegisterCodexIdentity).
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface CodexV2
    @doc "CodexV2 is the interface for the CODEX module — the on-chain Codex Identity \
        \ registry, Arweave upload audit log, and StoicTag name registry. It declares UC \
        \ validators (Apollo composite id, Arweave tx-id, StoicTag name/fee), UR field \
        \ accessors and DataOrNull readers over the CODEX tables, URCi cost single-sources \
        \ for StoicTag register/release, plus A_/C_ entrypoints to \
        \ register identities, rotate codex guards, record Arweave uploads, and \
        \ register/release StoicTags. Client entrypoints are wired through Talos TS01-C4."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|CodexKey ())

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
    ;;
    ;;
    (defun UC_ValidateArweaveTxId:bool (tx-id:string))
    (defun UC_StoicTagStoaFee:decimal (tag-name:string))
    (defun UC_ValidateStoicTagName:bool (tag-name:string))
    (defun UC_CodexIdStandard:string (codex-id:string))
    (defun UC_CodexIdSmart:string (codex-id:string))
    (defun UC_ValidateCompositeCodexId:bool (codex-id:string))
    (defun UC_ArweaveTrackerKey:string (codex-id:string arweave-tx-id:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;; [URCi] cost single-source readers — one raw toll per cost-bearing client op;
    ;; consumed by BOTH the TS01-C4 exec collect and the INFO preview layer.
    (defun URCi_RegisterStoicTag:decimal (tag-name:string))
    (defun URCi_ReleaseStoicTag:decimal (tag-name:string))
    (defun URCi_RotateCodexGuard:object{IgnisCollectorV3.OutputCumulator} (patron:string))
    (defun URCi_RecordArweaveUpload:object{IgnisCollectorV3.OutputCumulator} (patron:string))
    ;;
    ;; [UR] CODEX|S|Identity — field accessors + DataOrNull (UR_CIX|Data is module-only; schema not in interface)
    (defun UR_CIX|CodexIdStandard:string (codex-id:string))
    (defun UR_CIX|CodexIdSmart:string (codex-id:string))
    (defun UR_CIX|PublicStandard:string (codex-id:string))
    (defun UR_CIX|PublicSmart:string (codex-id:string))
    (defun UR_CIX|CodexGuard:guard (codex-id:string))
    (defun UR_CIX|RegisteredAt:time (codex-id:string))
    (defun UR_CIX|RegisteredBy:string (codex-id:string))
    (defun UR_CIX|CodexId:string (codex-id:string))
    (defun UR_CIX|DataOrNull:object (codex-id:string))
    ;;
    ;; [UR] CODEX|S|ArweaveTracker — field accessors (UR_AWT|Data is module-only)
    (defun UR_AWT|UploadTime:time (codex-id:string arweave-tx-id:string))
    (defun UR_AWT|UploadedBytes:integer (codex-id:string arweave-tx-id:string))
    (defun UR_AWT|CodexId:string (codex-id:string arweave-tx-id:string))
    (defun UR_AWT|ArweaveTxId:string (codex-id:string arweave-tx-id:string))
    (defun UR_AWT|ListByCodex:[object] (codex-id:string))
    ;;
    ;; [UR] CODEX|S|StoicTag — field accessors + DataOrNull (UR_STG|Data is module-only)
    (defun UR_STG|AccountAddress:string (tag-name:string))
    (defun UR_STG|RegisteredAt:time (tag-name:string))
    (defun UR_STG|IzActive:bool (tag-name:string))
    (defun UR_STG|TagName:string (tag-name:string))
    (defun UR_STG|DataOrNull:object (tag-name:string))
    ;;
    ;; [UR] CODEX|S|StoicTagByAccount — field accessors + DataOrNull (UR_STBA|Data is module-only)
    (defun UR_STBA|TagName:string (account-address:string))
    (defun UR_STBA|AccountAddress:string (account-address:string))
    (defun UR_STBA|IzActive:bool (account-address:string))
    (defun UR_STBA|DataOrNull:object (account-address:string))
    ;;
    ;; [URC]
    (defun URC_AWT|LatestUpload:object (codex-id:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;; NOTE: INFO_CODEX|* previews are UI-only → NOT declared here (canon: INFO not in
    ;; interfaces); they live in the CODEX module's {5.3} Read block.
    ;;
    (defun A_RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string ))
    ;;
    ;;#24H fix: these four were already live/actively-called via TS01-C4's module{CodexV2}-typed
    ;;ref, but missing from the interface itself. Added here, purely additive - the module already
    ;;implements all four with matching signatures.
    ;; [C]
    (defun C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard))
    (defun C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer))
    (defun C_RegisterStoicTag:string (tag-name:string account-address:string))
    (defun C_ReleaseStoicTag:string (tag-name:string))

)

(module CODEX GOV
    @doc "On-chain Codex Identity registry, Arweave upload audit log, and StoicTag \
         \ name registry. Apollo cosign is off-chain only; chain enforces Stoa guards."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements CodexV2)
    (implements OuronetPolicyV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_CODEX                              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|CODEX_ADMIN)))
    (defcap GOV|CODEX_ADMIN ()                          (enforce-guard GOV|MD_CODEX))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|CodexKey ()                              (+ (CT_Namespace) ".codex-keyset"))

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
    (defcap P|CODEX|CALLER ()
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
        (with-capability (GOV|CODEX_ADMIN)
            (write P|T policy-name {"policy" : policy-guard})
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|CODEX_ADMIN)
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
                (mg:guard (create-capability-guard (P|CODEX|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst CODEX|EPOCH:time                          (time "1970-01-01T00:00:00Z"))
    (defconst CODEX|APOLLO-HALF-LEN:integer             162)
    (defconst CODEX|COMPOSITE-SEP:string                ":")
    (defconst CODEX|APOLLO-COMPOSITE-LEN:integer
        (fold (+) 0 [CODEX|APOLLO-HALF-LEN 1 CODEX|APOLLO-HALF-LEN])
    )
    ;;{3.2}  schemas
    ;;
    (defschema CODEX|S|Identity
        @doc "One Mnemosyne-registered codex identity. Immutable except codex-guard."
        codex-id-standard:string            ;;[.]   Apollo Standard half (₱. + 160 charset chars, len 162)
        codex-id-smart:string               ;;[.]   Apollo Smart half (Π. + 160 charset chars, len 162)
        public-standard:string              ;;[.]   Canonical Standard Apollo pubkey material
        public-smart:string                 ;;[.]   Canonical Smart Apollo pubkey material
        codex-guard:guard                   ;;[M]   Stoa CodexGuard keyset (rotatable)
        registered-at:time                  ;;[.]   Block time at registration
        registered-by:string                ;;[.]   Operator observability string
        ;;
        ;;Select Keys
        codex-id:string                     ;;[.]   Composite Apollo id: standard + ':' + smart (len 325)
    )
    (defschema CODEX|S|ArweaveTracker
        @doc "Append-only Arweave backup row for one codex."
        upload-time:time                    ;;[.]   Block time at insert
        uploaded-bytes:integer              ;;[.]   Encrypted blob size on Arweave
        ;;
        ;;Select Keys
        codex-id:string                     ;;[.]   Parent identity (FK to CODEX|T|Identities)
        arweave-tx-id:string                ;;[.]   Arweave transaction id (43-char base64url)
    )
    (defschema CODEX|S|StoicTag
        @doc "Human-readable name → Ouronet account (codex-agnostic). Release sets iz-active false."
        account-address:string              ;;[M]   Ouronet DALOS account (Ѻ.* or Σ.*), not a Stoa k: account
        registered-at:time                  ;;[M]   Block time at last activation
        iz-active:bool                      ;;[M]   true = name in use; false = released (re-register updates row)
        ;;
        ;;Select Keys
        tag-name:string                     ;;[.]   Bare name without § prefix (table key)
    )
    (defschema CODEX|S|StoicTagByAccount
        @doc "Reverse index: one active StoicTag per account when iz-active is true."
        tag-name:string                     ;;[M]   StoicTag registered to account
        iz-active:bool                      ;;[M]   Mirrors CODEX|T|StoicTags.iz-active for this account slot
        ;;
        ;;Select Keys
        account-address:string              ;;[.]   Ouronet DALOS account (table key; Ѻ.* or Σ.*)
    )
    ;;{3.3}  tables
    (deftable CODEX|T|Identities:{CODEX|S|Identity})                    ;;Key = <codex-id>
    (deftable CODEX|T|ArweaveTracker:{CODEX|S|ArweaveTracker})          ;;Key = <codex-id> | <arweave-tx-id>
    (deftable CODEX|T|StoicTags:{CODEX|S|StoicTag})                     ;;Key = <tag-name>
    (deftable CODEX|T|StoicTagsByAccount:{CODEX|S|StoicTagByAccount})   ;;Key = <account-address>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap CODEX|ADMIN ()                              (enforce-guard (keyset-ref-guard (GOV|CodexKey))))
    (defcap CODEX|OWNER (codex-id:string)
        (let 
            (
                (codex-guard:guard (UR_CIX|CodexGuard codex-id))
            )
            (enforce-guard codex-guard)
        )
    )
    ;;{C3}  Composed
    (defcap CODEX|A>REGISTER-IDENTITY
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string )
        @doc "Mnemosyne operator registers a new codex identity. Derives Apollo halves from composite codex-id."
        @event
        ;;FIXED 2026-09-12: the LENGTH check is enforced HERE, above the binding group.
        ;;It used to be computed inside the `let` below as `iz-composite-len` and folded in with the
        ;;other six conditions -- but a `let` is EAGER and `fold (and)` does not short-circuit, so for
        ;;an id too short to split, `iz-standard-valid` ran anyway, indexed into an empty derived half
        ;;and raised `Array index out of bounds. Length (0), Index (0)`. Being false in the FIRST
        ;;conjunct saved nothing, and a truncated or hand-typed id -- the likeliest bad input on this
        ;;path -- got no message at all.
        ;;A length test needs nothing but the parameter, so it can run before anything is derived.
        ;;The fold below is unchanged and still answers for every other way to be invalid.
        ;;Pinned by REPL/modules/CODEX.repl <<CODEX-G3>>.
        (compose-capability (CODEX|ADMIN))
        (enforce
            (= (length codex-id) CODEX|APOLLO-COMPOSITE-LEN)
            "Invalid codex identity: composite Apollo codex-id must be 325 characters"
        )
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                (codex-len:integer (length codex-id))
                (codex-id-standard:string (UC_CodexIdStandard codex-id))
                (codex-id-smart:string (UC_CodexIdSmart codex-id))
                (iz-composite-len:bool (= codex-len CODEX|APOLLO-COMPOSITE-LEN))
                (iz-separator:bool
                    (= CODEX|COMPOSITE-SEP (take 1 (drop CODEX|APOLLO-HALF-LEN codex-id)))
                )
                (iz-standard-valid:bool
                    (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck codex-id-standard false)
                )
                (iz-smart-valid:bool
                    (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck codex-id-smart true)
                )
                (iz-reconcat:bool
                    (= codex-id (format "{}{}{}" [codex-id-standard CODEX|COMPOSITE-SEP codex-id-smart]))
                )
                (iz-nonempty-pub-std:bool (!= public-standard ""))
                (iz-nonempty-pub-smt:bool (!= public-smart ""))
            )
            (enforce
                (fold (and) true
                    [
                        iz-composite-len
                        iz-separator
                        iz-standard-valid
                        iz-smart-valid
                        iz-reconcat
                        iz-nonempty-pub-std
                        iz-nonempty-pub-smt
                    ]
                )
                "Invalid codex identity: composite Apollo codex-id or pubkey material"
            )
            (compose-capability (SECURE))
        )
    )
    (defcap CODEX|C>ROTATE-GUARD (codex-id:string new-codex-guard:guard)
        @doc "Rotate codex-guard: current owner + new guard must sign. Composes SECURE for XI."
        @event
        (compose-capability (CODEX|OWNER codex-id))
        (enforce-guard new-codex-guard)
        (compose-capability (SECURE))
    )
    (defcap CODEX|C>RECORD-ARWEAVE (codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "Append Arweave tracker row for registered codex. Composes OWNER + SECURE for XI."
        @event
        (let
            (
                (iz-valid-tx-id:bool (UC_ValidateArweaveTxId arweave-tx-id))
                (iz-positive-bytes:bool (> uploaded-bytes 0))
            )
            (compose-capability (CODEX|OWNER codex-id))
            (enforce
                (and iz-valid-tx-id iz-positive-bytes)
                "Invalid arweave upload: bad tx-id format or non-positive uploaded-bytes"
            )
            (compose-capability (SECURE))
        )
    )
    (defcap CODEX|C>REGISTER-STOICTAG (tag-name:string account-address:string)
        @doc "Register or re-activate StoicTag. Fails if name or account slot is already active. Composes SECURE for XI."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (tag-row-found:bool (not (= (try false (UR_STG|Data tag-name)) false)))
                (tag-iz-active:bool
                    (if tag-row-found
                        (UR_STG|IzActive tag-name)
                        false
                    )
                )
                (acct-row-found:bool (not (= (try false (UR_STBA|Data account-address)) false)))
                (acct-iz-active:bool
                    (if acct-row-found
                        (UR_STBA|IzActive account-address)
                        false
                    )
                )
            )
            (ref-U|DALOS::UEV_StoicTagName tag-name)
            (ref-DALOS::UEV_EnforceAccountExists account-address)
            (enforce (not tag-iz-active) "StoicTag name is already active")
            (enforce (not acct-iz-active) "Account already has an active StoicTag")
            (compose-capability (CODEX|STOICTAG-DALOS-OWNER account-address))
            (compose-capability (SECURE))
        )
    )
    (defcap CODEX|C>RELEASE-STOICTAG (tag-name:string)
        @doc "Release (deactivate) StoicTag: must exist and be active. Composes SECURE for XI."
        @event
        (let
            (
                (tag-row-found:bool (not (= (try false (UR_STG|Data tag-name)) false)))
                (tag-iz-active:bool
                    (if tag-row-found
                        (UR_STG|IzActive tag-name)
                        false
                    )
                )
                (account-address:string
                    (if tag-row-found
                        (UR_STG|AccountAddress tag-name)
                        ""
                    )
                )
            )
            (enforce tag-row-found "StoicTag not found")
            (enforce tag-iz-active "StoicTag is not active")
            (compose-capability (CODEX|STOICTAG-DALOS-OWNER account-address))
            (compose-capability (SECURE))
        )
    )
    ;;{C4}  Ownership [gold]
    (defcap CODEX|STOICTAG-DALOS-OWNER (account-address:string)
        @doc "Caller controls the Ouronet (DALOS) account — Standard or Smart, not Stoa coin.details."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account-address)
        )
    )

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    (defun UDC_CIX|Identity:object{CODEX|S|Identity}
        ( codex-id-standard:string
          codex-id-smart:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-at:time
          registered-by:string
          codex-id:string )
        @doc "Constructor for object{CODEX|S|Identity}."
        { "codex-id-standard": codex-id-standard
        , "codex-id-smart":    codex-id-smart
        , "public-standard":   public-standard
        , "public-smart":      public-smart
        , "codex-guard":       codex-guard
        , "registered-at":     registered-at
        , "registered-by":     registered-by
        , "codex-id":          codex-id
        }
    )
    (defun UDC_CIX|GuardUpdate:object (new-codex-guard:guard)
        @doc "Partial update object for codex-guard rotation."
        { "codex-guard": new-codex-guard }
    )
    (defun UDC_CIX|Unregistered:object ()
        @doc "Sentinel for UR_CIX|DataOrNull when codex-id is absent."
        { "codex-id":           ""
        , "codex-id-standard":  ""
        , "codex-id-smart":     ""
        , "public-standard":    ""
        , "public-smart":       ""
        , "registered-at":      CODEX|EPOCH
        , "registered-by":      ""
        , "is-registered":      false
        }
    )
    (defun UDC_CIX|WithRegisteredFlag:object (row:object{CODEX|S|Identity})
        (+ row { "is-registered": true })
    )
    (defun UDC_AWT|Tracker:object{CODEX|S|ArweaveTracker}
        ( codex-id:string
          arweave-tx-id:string
          upload-time:time
          uploaded-bytes:integer )
        { "codex-id":       codex-id
        , "arweave-tx-id":  arweave-tx-id
        , "upload-time":    upload-time
        , "uploaded-bytes": uploaded-bytes
        }
    )
    (defun UDC_AWT|EmptyLatest:object (codex-id:string)
        (UDC_AWT|Tracker codex-id "" CODEX|EPOCH 0)
    )
    (defun UDC_STG|StoicTag:object{CODEX|S|StoicTag}
        ( account-address:string registered-at:time iz-active:bool tag-name:string )
        { "account-address": account-address
        , "registered-at":   registered-at
        , "iz-active":         iz-active
        , "tag-name":        tag-name
        }
    )
    (defun UDC_STG|IzActiveUpdate:object (iz-active:bool)
        { "iz-active": iz-active }
    )
    (defun UDC_STG|Unregistered:object ()
        { "tag-name":        ""
        , "account-address": ""
        , "registered-at":   CODEX|EPOCH
        , "iz-active":         false
        , "is-registered":   false
        }
    )
    (defun UDC_STG|WithRegisteredFlag:object (row:object{CODEX|S|StoicTag})
        (+ row { "is-registered": true })
    )
    (defun UDC_STBA|StoicTagByAccount:object{CODEX|S|StoicTagByAccount}
        ( tag-name:string iz-active:bool account-address:string )
        { "tag-name":        tag-name
        , "iz-active":         iz-active
        , "account-address": account-address
        }
    )
    (defun UDC_STBA|IzActiveUpdate:object (iz-active:bool)
        { "iz-active": iz-active }
    )
    (defun UDC_STBA|Unregistered:object ()
        { "account-address": ""
        , "tag-name":        ""
        , "iz-active":         false
        , "has-stoictag":    false
        }
    )
    (defun UDC_STBA|WithHasStoicTagFlag:object (row:object{CODEX|S|StoicTagByAccount})
        (+ row { "has-stoictag": true })
    )
    ;;{5.2}  Compute [UC]
    (defun UC_IsBase64urlChar:bool (c:string)
        (or (and (>= c "A") (<= c "Z"))
            (or (and (>= c "a") (<= c "z"))
                (or (and (>= c "0") (<= c "9"))
                    (contains c ["_" "-"])
                )
            )
        )
    )
    (defun UC_ValidateArweaveTxId:bool (tx-id:string)
        @doc "True when tx-id is 43-char Arweave base64url (length + charset)."
        (and (= (length tx-id) 43)
            (fold
                (lambda (ok:bool c:string) (and ok (UC_IsBase64urlChar c)))
                true
                (str-to-list tx-id)
            )
        )
    )
    (defun UC_StoicTagStoaFee:decimal (tag-name:string)
        @doc "Native STOA due for registering <tag-name>: exactly 1 STOA per glyph (= string \
            \ length). E.g. bytales -> 7.0 STOA. DELIBERATE EXCEPTION to the dollar rule (owner \
            \ 2026-09-07): this toll is FIXED IN STOA UNITS, not denominated in dollars and \
            \ converted, so a glyph always costs one STOA whatever the oracle says. It is also \
            \ non-discountable. Do NOT change it to derive from IG|DETER."
        (dec (length tag-name))
    )
    (defun UC_ValidateStoicTagName:bool (tag-name:string)
        @doc "True when tag-name is 3–256 glyphs from DALOS|CHARSET (U|DALOS)."
        (let 
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
            )
            (ref-U|DALOS::UC_IzStoicTagName tag-name)
        )
    )
    (defun UC_CodexIdStandard:string (codex-id:string)
        @doc "Standard Apollo half of composite codex-id (first 162 chars)."
        (take CODEX|APOLLO-HALF-LEN codex-id)
    )
    (defun UC_CodexIdSmart:string (codex-id:string)
        @doc "Smart Apollo half of composite codex-id (chars after separator ':')."
        (drop (+ CODEX|APOLLO-HALF-LEN 1) codex-id)
    )
    (defun UC_ValidateCompositeCodexId:bool (codex-id:string)
        @doc "True when codex-id is 325 chars: valid ₱. standard + ':' + valid Π. smart Apollo strings."
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                (standard:string (UC_CodexIdStandard codex-id))
                (smart:string (UC_CodexIdSmart codex-id))
            )
            (fold (and) true
                [
                    (= (length codex-id) CODEX|APOLLO-COMPOSITE-LEN)
                    (= CODEX|COMPOSITE-SEP (take 1 (drop CODEX|APOLLO-HALF-LEN codex-id)))
                    (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck standard false)
                    (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck smart true)
                    (= codex-id (format "{}{}{}" [standard CODEX|COMPOSITE-SEP smart]))
                ]
            )
        )
    )
    (defun UC_ArweaveTrackerKey:string (codex-id:string arweave-tx-id:string)
        @doc "Composite table key for CODEX|T|ArweaveTracker."
        (format "{}|{}" [codex-id arweave-tx-id])
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCi_RegisterStoicTag:decimal (tag-name:string)
        @doc "Cost single-source for CODEX|C_RegisterStoicTag — RAW native STOA toll \
            \ (1/glyph). Elite discount is applied at collect against the tagged account, \
            \ so this returns the pre-discount amount. Consumed by TS01-C4 exec + INFO."
        (UC_StoicTagStoaFee tag-name)
    )
    (defun URCi_RotateCodexGuard:object{IgnisCollectorV3.OutputCumulator} (patron:string)
        @doc "Cost single-source for CODEX|C_RotateCodexGuard — deter(usage) + components, on the \
            \ patron (the codex row carries no konto of its own). USAGE tier (deterrence 1x, owner \
            \ 2026-09-07): CODEX ops pay what they structurally cost and carry no deterrent premium. \
            \ Consumed by the TS01-C4 exec path + INFO, so the two cannot drift."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "CODEX|C_RotateCodexGuard" "usage")
                patron (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_RecordArweaveUpload:object{IgnisCollectorV3.OutputCumulator} (patron:string)
        @doc "Cost single-source for CODEX|C_RecordArweaveUpload — deter(usage) + components, on \
            \ the patron. USAGE tier: recording an upload is routine activity, not a config \
            \ change. Consumed by the TS01-C4 exec path + INFO."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "CODEX|C_RecordArweaveUpload" "usage")
                patron (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_ReleaseStoicTag:decimal (tag-name:string)
        @doc "Cost single-source for CODEX|C_ReleaseStoicTag — flat IGNIS toll (1/glyph), \
            \ collected via IGNIS::C_Collect in TS01-C4. Consumed by exec + INFO."
        (UC_StoicTagStoaFee tag-name)
    )
    ;;
    ;; [1] CODEX|T|Identities  (CODEX|S|Identity)  Key = <codex-id>
    (defun UR_CIX|Data:object{CODEX|S|Identity} (codex-id:string)
        @doc "Full codex identity row."
        (read CODEX|T|Identities codex-id)
    )
    (defun UR_CIX|CodexIdStandard:string (codex-id:string)
        (at "codex-id-standard" (read CODEX|T|Identities codex-id ["codex-id-standard"]))
    )
    (defun UR_CIX|CodexIdSmart:string (codex-id:string)
        (at "codex-id-smart" (read CODEX|T|Identities codex-id ["codex-id-smart"]))
    )
    (defun UR_CIX|PublicStandard:string (codex-id:string)
        (at "public-standard" (read CODEX|T|Identities codex-id ["public-standard"]))
    )
    (defun UR_CIX|PublicSmart:string (codex-id:string)
        (at "public-smart" (read CODEX|T|Identities codex-id ["public-smart"]))
    )
    (defun UR_CIX|CodexGuard:guard (codex-id:string)
        (at "codex-guard" (read CODEX|T|Identities codex-id ["codex-guard"]))
    )
    (defun UR_CIX|RegisteredAt:time (codex-id:string)
        (at "registered-at" (read CODEX|T|Identities codex-id ["registered-at"]))
    )
    (defun UR_CIX|RegisteredBy:string (codex-id:string)
        (at "registered-by" (read CODEX|T|Identities codex-id ["registered-by"]))
    )
    (defun UR_CIX|CodexId:string (codex-id:string)
        (at "codex-id" (UR_CIX|Data codex-id))
    )
    (defun UR_CIX|DataOrNull:object (codex-id:string)
        @doc "Like UR_CIX|Data but returns is-registered:false when absent."
        (if (= (try false (UR_CIX|Data codex-id)) false)
            (UDC_CIX|Unregistered)
            (UDC_CIX|WithRegisteredFlag (UR_CIX|Data codex-id))
        )
    )
    ;;
    ;; [2] CODEX|T|ArweaveTracker  (CODEX|S|ArweaveTracker)  Key = <codex-id> | <arweave-tx-id>
    (defun UR_AWT|Data:object{CODEX|S|ArweaveTracker} (codex-id:string arweave-tx-id:string)
        @doc "One Arweave tracker row."
        (read CODEX|T|ArweaveTracker (UC_ArweaveTrackerKey codex-id arweave-tx-id))
    )
    (defun UR_AWT|UploadTime:time (codex-id:string arweave-tx-id:string)
        (at "upload-time"
            (read CODEX|T|ArweaveTracker (UC_ArweaveTrackerKey codex-id arweave-tx-id) ["upload-time"])
        )
    )
    (defun UR_AWT|UploadedBytes:integer (codex-id:string arweave-tx-id:string)
        (at "uploaded-bytes"
            (read CODEX|T|ArweaveTracker (UC_ArweaveTrackerKey codex-id arweave-tx-id) ["uploaded-bytes"])
        )
    )
    (defun UR_AWT|CodexId:string (codex-id:string arweave-tx-id:string)
        (at "codex-id" (UR_AWT|Data codex-id arweave-tx-id))
    )
    (defun UR_AWT|ArweaveTxId:string (codex-id:string arweave-tx-id:string)
        (at "arweave-tx-id" (UR_AWT|Data codex-id arweave-tx-id))
    )
    (defun UR_AWT|ListByCodex:[object] (codex-id:string)
        @doc "All tracker rows for codex-id (select scan)."
        (select CODEX|T|ArweaveTracker
            ["codex-id" "arweave-tx-id" "upload-time" "uploaded-bytes"]
            (where "codex-id" (= codex-id))
        )
    )
    ;;
    ;; [3] CODEX|T|StoicTags  (CODEX|S|StoicTag)  Key = <tag-name>
    (defun UR_STG|Data:object{CODEX|S|StoicTag} (tag-name:string)
        (read CODEX|T|StoicTags tag-name)
    )
    (defun UR_STG|AccountAddress:string (tag-name:string)
        (at "account-address" (read CODEX|T|StoicTags tag-name ["account-address"]))
    )
    (defun UR_STG|RegisteredAt:time (tag-name:string)
        (at "registered-at" (read CODEX|T|StoicTags tag-name ["registered-at"]))
    )
    (defun UR_STG|IzActive:bool (tag-name:string)
        (at "iz-active" (read CODEX|T|StoicTags tag-name ["iz-active"]))
    )
    (defun UR_STG|TagName:string (tag-name:string)
        (at "tag-name" (UR_STG|Data tag-name))
    )
    (defun UR_STG|DataOrNull:object (tag-name:string)
        (if (= (try false (UR_STG|Data tag-name)) false)
            (UDC_STG|Unregistered)
            (if (UR_STG|IzActive tag-name)
                (UDC_STG|WithRegisteredFlag (UR_STG|Data tag-name))
                (UDC_STG|Unregistered)
            )
        )
    )
    ;;
    ;; [4] CODEX|T|StoicTagsByAccount  (CODEX|S|StoicTagByAccount)  Key = <account-address>
    (defun UR_STBA|Data:object{CODEX|S|StoicTagByAccount} (account-address:string)
        (read CODEX|T|StoicTagsByAccount account-address)
    )
    (defun UR_STBA|TagName:string (account-address:string)
        (at "tag-name" (read CODEX|T|StoicTagsByAccount account-address ["tag-name"]))
    )
    (defun UR_STBA|AccountAddress:string (account-address:string)
        (at "account-address" (UR_STBA|Data account-address))
    )
    (defun UR_STBA|IzActive:bool (account-address:string)
        (at "iz-active" (read CODEX|T|StoicTagsByAccount account-address ["iz-active"]))
    )
    (defun UR_STBA|DataOrNull:object (account-address:string)
        (if (= (try false (UR_STBA|Data account-address)) false)
            (UDC_STBA|Unregistered)
            (if (UR_STBA|IzActive account-address)
                (UDC_STBA|WithHasStoicTagFlag (UR_STBA|Data account-address))
                (UDC_STBA|Unregistered)
            )
        )
    )
    ;;
    (defun URC_AWT|LatestUpload:object (codex-id:string)
        @doc "Newest arweave-tracker row for codex-id, or empty object if none."
        (let 
            (
                (rows:[object] (UR_AWT|ListByCodex codex-id))
            )
            (if (= (length rows) 0)
                (UDC_AWT|EmptyLatest codex-id)
                (fold
                    (lambda (best:object row:object)
                        (if (> (at "upload-time" row) (at "upload-time" best))
                            row
                            best
                        )
                    )
                    (at 0 rows)
                    (drop 1 rows)
                )
            )
        )
    )
    ;;
    (defun INFO_CODEX|RegisterStoicTag:object{OuronetInfoV2.ClientInfo}
        (patron:string tag-name:string account-address:string)
        @doc "ClientInfo preview for TS01-C4 CODEX|C_RegisterStoicTag — STOA from patron; Elite discount on account-address."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;single-source: the SAME reader the TS01-C4 exec path collects from
                (stoa-fee:decimal (URCi_RegisterStoicTag tag-name))
                (glyph-count:integer (length tag-name))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account-address))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Register StoicTag §{} to Ouronet account {}." [tag-name sa])
                    (format "Native STOA fee: {} (1 per glyph, {} glyphs; Elite discount on tagged account)." [stoa-fee glyph-count])
                ]
                [(format "StoicTag §{} registered to account {}." [tag-name account-address])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_StoaCosts account-address stoa-fee)
                []
            )
        )
    )
    (defun INFO_CODEX|RotateCodexGuard:object{OuronetInfoV2.ClientInfo}
        (patron:string codex-id:string)
        
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Rotate the Codex Guard of Codex {}." [codex-id])]
                [(format "Codex Guard of Codex {} rotated." [codex-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_RotateCodexGuard patron)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_CODEX|RecordArweaveUpload:object{OuronetInfoV2.ClientInfo}
        (patron:string codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "ClientInfo preview for TS01-C4 CODEX|C_RecordArweaveUpload — deter(usage) + \
            \ components via URCi_RecordArweaveUpload, so preview and execution cannot drift. \
            \ Records the Arweave transaction id and the uploaded byte count."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [(format "Operation: Record Arweave upload {} ({} bytes) for Codex {}."
                    [arweave-tx-id uploaded-bytes codex-id])]
                [(format "Arweave upload {} recorded for Codex {}." [arweave-tx-id codex-id])]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron
                    (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_RecordArweaveUpload patron)))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_CODEX|ReleaseStoicTag:object{OuronetInfoV2.ClientInfo}
        (patron:string tag-name:string)
        @doc "ClientInfo preview for TS01-C4 CODEX|C_ReleaseStoicTag (IGNIS = UC_StoicTagStoaFee per glyph)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;single-source: the SAME reader the TS01-C4 exec path collects from
                (tag-fee:decimal (URCi_ReleaseStoicTag tag-name))
                (glyph-count:integer (length tag-name))
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Release StoicTag §{}." [tag-name])
                    (format "IGNIS fee: {} (1 per glyph, {} glyphs)." [tag-fee glyph-count])
                ]
                [(format "StoicTag §{} released." [tag-name])]
                (if is-ignis-zero
                    (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                    (ref-I|OURONET::OI|UDC_IgnisCosts patron tag-fee)
                )
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_InsertIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string )
        @doc "Under SECURE (from CODEX|A>REGISTER-IDENTITY): insert identity row. Write only."
        (require-capability (SECURE))
        (insert CODEX|T|Identities codex-id
            (UDC_CIX|Identity
                (UC_CodexIdStandard codex-id)
                (UC_CodexIdSmart codex-id)
                public-standard public-smart
                codex-guard (at "block-time" (chain-data)) registered-by codex-id
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateCodexGuard:string (codex-id:string new-codex-guard:guard)
        @doc "Under SECURE (from CODEX|C>ROTATE-GUARD): update codex-guard only. Write only."
        (require-capability (SECURE))
        (update CODEX|T|Identities codex-id (UDC_CIX|GuardUpdate new-codex-guard))
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_InsertArweaveTracker:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "Under SECURE (from CODEX|C>RECORD-ARWEAVE): append tracker row. Write only."
        (require-capability (SECURE))
        (insert CODEX|T|ArweaveTracker (UC_ArweaveTrackerKey codex-id arweave-tx-id)
            (UDC_AWT|Tracker
                codex-id arweave-tx-id (at "block-time" (chain-data)) uploaded-bytes
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpsertStoicTag:string (tag-name:string account-address:string)
        @doc "Under SECURE (from CODEX|C>REGISTER-STOICTAG): insert new or re-activate released rows. Write only."
        (require-capability (SECURE))
        (let 
            (
                (now:time (at "block-time" (chain-data)))
            )
            (if (= (try false (UR_STG|Data tag-name)) false)
                (insert CODEX|T|StoicTags tag-name
                    (UDC_STG|StoicTag account-address now true tag-name))
                (update CODEX|T|StoicTags tag-name
                    (UDC_STG|StoicTag account-address now true tag-name))
            )
            (if (= (try false (UR_STBA|Data account-address)) false)
                (insert CODEX|T|StoicTagsByAccount account-address
                    (UDC_STBA|StoicTagByAccount tag-name true account-address))
                (update CODEX|T|StoicTagsByAccount account-address
                    (UDC_STBA|StoicTagByAccount tag-name true account-address))
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_DeactivateStoicTag:string (tag-name:string)
        @doc "Under SECURE (from CODEX|C>RELEASE-STOICTAG): set iz-active false on both tables. Write only."
        (require-capability (SECURE))
        (let
            (
                (account-address:string (UR_STG|AccountAddress tag-name))
            )
            (update CODEX|T|StoicTags tag-name (UDC_STG|IzActiveUpdate false))
            (update CODEX|T|StoicTagsByAccount account-address (UDC_STBA|IzActiveUpdate false))
        )
    )
    ;;{5.7}  User [A/C]
    (defun A_RegisterCodexIdentity:string
        ( codex-id:string
          public-standard:string
          public-smart:string
          codex-guard:guard
          registered-by:string )
        @doc "ADMIN-only insert into CODEX|T|Identities; standard/smart halves derived from codex-id."
        (P|UEV_IMC)
        (with-capability (CODEX|A>REGISTER-IDENTITY codex-id public-standard public-smart codex-guard registered-by)
            (XI_InsertIdentity
                codex-id public-standard public-smart codex-guard registered-by
            )
        )
        (format "Codex Identity {} registered" [codex-id])
    )
    (defun C_RotateCodexGuard:string (codex-id:string new-codex-guard:guard)
        @doc "Rotate codex-guard; validation in CODEX|C>ROTATE-GUARD; XI writes only."
        (P|UEV_IMC)
        (with-capability (CODEX|C>ROTATE-GUARD codex-id new-codex-guard)
            (XI_UpdateCodexGuard codex-id new-codex-guard)
        )
        (format "Codex {} guard rotated" [codex-id])
    )
    ;;
    (defun C_RecordArweaveUpload:string (codex-id:string arweave-tx-id:string uploaded-bytes:integer)
        @doc "Append one row to CODEX|T|ArweaveTracker; validation in CODEX|C>RECORD-ARWEAVE."
        (P|UEV_IMC)
        (with-capability (CODEX|C>RECORD-ARWEAVE codex-id arweave-tx-id uploaded-bytes)
            (XI_InsertArweaveTracker codex-id arweave-tx-id uploaded-bytes)
        )
        (format "Upload recorded: {} -> {}" [codex-id arweave-tx-id])
    )
    ;;
    (defun C_RegisterStoicTag:string (tag-name:string account-address:string)
        @doc "Register StoicTag; validation in CODEX|C>REGISTER-STOICTAG; XI writes only (1 STOA/glyph fee in TS01-C4)."
        (P|UEV_IMC)
        (with-capability (CODEX|C>REGISTER-STOICTAG tag-name account-address)
            (XI_UpsertStoicTag tag-name account-address)
        )
        (format "StoicTag §{} registered to account {}" [tag-name account-address])
    )
    ;;
    (defun C_ReleaseStoicTag:string (tag-name:string)
        @doc "Release StoicTag (iz-active false); validation in CODEX|C>RELEASE-STOICTAG; XI updates only."
        (P|UEV_IMC)
        (with-capability (CODEX|C>RELEASE-STOICTAG tag-name)
            (XI_DeactivateStoicTag tag-name)
        )
        (format "StoicTag §{} released" [tag-name])
    )

)

;; --- tables for 21_CODEX.pact (6 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table CODEX|T|Identities)
;; (create-table CODEX|T|ArweaveTracker)
;; (create-table CODEX|T|StoicTags)
;; (create-table CODEX|T|StoicTagsByAccount)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/22_PYTHIA.pact ==================
;; PYTHIA — Apollo Pythia dual-Apollo API-key registry (Stage 01 core #23).
;; Spec: OuronetInformational/HANDOFFS/HANDOFF-pact-apollo-pythia-key-module.md
;; Deploy: load THIS file — PythiaV5 + PythiaLedgerV3 interfaces + PYTHIA module ship together.
;; Shared/historical registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact (PythiaV1–V3, PythiaLedger V1/V2BlockTime).
;; Talos client: 1_SOVEREIGN/STAGE_01/3_Talos/06_TS01-C4.pact (TalosStageOne_ClientFourV8 embedded).
;; REPL: REPL/Stage_01/[6.10]_PYTHIA.repl
;; Cronoton: ouronet-ns.pythia-cronoton-keyset (A_Link / A_RevokeLink / A_Flush).
;;
;; TABLES (deftable) — vs PYTHIA V1/V2 single-key model:
;;   PYTHIA|T|ApiKeys     — carryover table name; V3 schema (counterpart; no per-half consumer-lane)
;;   PYTHIA|T|Config      — carryover (deploy/rename prices)
;;   PYTHIA|T|DualLinks   — NEW V3 (pair row: lane + iz-active)
;;   PYTHIA|T|Revocation  — NEW V3 (revoked-at-height fast-lane anchor)
;;   PYTHIA|T|PythDaily   — Pyth ledger calendar-day snapshots (key = day ordinal string; iz-sealed)
;;   PYTHIA|T|PythTotal   — Pyth ledger running totals (key = "stoachain")
;;   P|T / P|MT           — standard Ouronet policy tables
;;
;; Spec (ledger): OuronetInformational/HANDOFFS/HANDOFF-pact-pyth-ledger.md
;; (create-table ...) at module bottom runs on **first module install** (greenfield).
;; You do not submit separate create-table txs. All eight fire in the PYTHIA deploy tx.
;; If PYTHIA were already on-chain at V3, only PythDaily + PythTotal are additive create-tables.
;;
;; net: v4   ·   dev: v5   ;; bumped by the StoicSyntax refactor — deploy v5 then set net: v5
(interface PythiaV5
    @doc "PYTHIA V4 — V3 dual-Apollo + Config UR prices; select-based inventory is URH_."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|CronotonKey ())

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
    ;;
    (defun UC_DeployPrice:decimal ())
    (defun UC_RenamePrice:decimal ())
    (defun UC_RevokeIgnisFee:decimal ())
    (defun UC_IsStandardApollo:bool (apollo-account:string))
    (defun UC_FeeDiscountAnchor:string ())
    (defun UC_DualLinkKey:string (standard-apollo:string smart-apollo:string))
    (defun UC_DualLinkStandard:string (dual-link-key:string))
    (defun UC_DualLinkSmart:string (dual-link-key:string))
    (defun UC_ChainEpoch:integer (block-height:integer))
    (defun UC_CurrentChainEpoch:integer ())
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;; [URCi] cost single-source readers — one raw toll per cost-bearing client op;
    ;; consumed by BOTH the TS01-C4 exec collect and the INFO preview layer.
    (defun URCi_DeployApiKey:decimal ())
    (defun URCi_UpdateDualConsumerLane:decimal ())
    (defun URCi_RevokeLink:decimal ())
    ;;
    ;; [UR] PYTHIA|S|ApiKey + DualLink + Config + Revocation
    (defun UR_Public:string (apollo-account:string))
    (defun UR_Counterpart:string (apollo-account:string))
    (defun UR_DualLinkConsumerLane:string (dual-link-key:string))
    (defun UR_OwnerAccount:string (apollo-account:string))
    (defun UR_RegisteredAt:time (apollo-account:string))
    (defun UR_UpdatedAt:time (apollo-account:string))
    (defun UR_ApiKeyRowOrNull:object (apollo-account:string))
    (defun UR_DualLinkIzActive:bool (dual-link-key:string))
    (defun UR_DualLinkRowOrNull:object (dual-link-key:string))
    (defun UR_DualLinkIzActiveOrFalse:bool (dual-link-key:string))
    (defun UR_Config ())
    (defun UR_DeployPrice:decimal ())
    (defun UR_RenamePrice:decimal ())
    (defun UR_RevocationAtHeight:integer ())
    (defun UR_RevocationEpoch:integer ())
    (defun UR_ApiKeyBySlot:object (standard-apollo:string))
    ;;
    ;; [URD] — select / keys inventory
    (defun URH_ApiKeyCount:integer ())
    (defun URH_ApiKeyCountStr:string ())
    (defun URH_DualLinkCount:integer ())
    (defun URH_ListAllApiKeys:[object] ())
    (defun URH_ListAllDualLinks:[object] ())
    (defun URH_ListActiveDualLinks:[object] ())
    (defun URH_ListInactiveDualLinks:[object] ())
    (defun URH_ActiveDualLinkSet:[string] ())
    (defun URH_ApiKeyByConsumer:object (smart-apollo:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;; NOTE: INFO_PYTHIA|* previews are UI-only → NOT declared here (canon: INFO not in
    ;; interfaces); they live in the PYTHIA module's {5.3} Read block.
    ;;
    (defun A_LinkDualApiKey:string (standard-apollo:string smart-apollo:string))
        ;; Cronoton: create+activate (auto PYTHIA-<hash12> lane) or flip inactive→true
    (defun A_RevokeDualLink:string (dual-link-key:string))
    (defun A_UpdateDeployPrice:string (new-price:decimal))
    (defun A_UpdateRenamePrice:string (new-price:decimal))
    ;;
    (defun C_DeployApolloPythiaApiKey:string
        (
            owner-account:string
            apollo-account:string
            public:string
        ))
    (defun C_LinkDualApiKey:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        ))
    (defun C_RevokeDualLink:string (dual-link-key:string))
    (defun C_UpdateDualConsumerLane:string
        (
            dual-link-key:string
            new-name:string
        ))

)
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface PythiaLedgerV3
    @doc "Pyth ledger V2 — batch flush entries (explicit day, iz-complete); order-independent txs."

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
    (defschema PYTHIA|S|PythMetrics
        @doc "Six Pyth work counters — nested on daily and total rows."
        petitions:integer
        pondus:decimal
        transactions:integer
        gas-reserved:integer
        failed-transactions:integer
        wasted-gas-reserved:integer
    )
    (defschema PYTHIA|S|PythFlushAcc
        @doc "Internal fold state for batch XI_FlushPythLedger."
        total-metrics:object{PYTHIA|S|PythMetrics}
        last-day:integer
    )
    (defschema PYTHIA|S|PythFlushEntry
        @doc "One calendar day in a batch A_Flush (metrics cumulative for that UTC day)."
        day:integer
        iz-complete:bool
        petitions:integer
        pondus:decimal
        transactions:integer
        gas-reserved:integer
        failed-transactions:integer
        wasted-gas-reserved:integer
    )
    (defschema PYTHIA|S|PythDaily
        @doc "One calendar-day snapshot. Table key = day ordinal string."
        day:integer
        flushed-at:time
        iz-sealed:bool
        metrics:object{PYTHIA|S|PythMetrics}
    )
    (defschema PYTHIA|S|PythTotal
        @doc "Running totals. Key = stoachain. last-day = highest day ordinal written."
        total-metrics:object{PYTHIA|S|PythMetrics}
        last-day:integer
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
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_PythMaxFlushBatch:integer ())
    (defun UR_PythLedgerEpochStart:time ())
    (defun UR_PythCurrentDay:integer ())
    (defun UR_PythTotal:object{PYTHIA|S|PythTotal} ())
    (defun UR_PythTotal|TotalMetrics:object{PYTHIA|S|PythMetrics} ())
    (defun UR_PythTotal|LastDay:integer ())
    (defun UR_PythDay:object{PYTHIA|S|PythDaily} (day:integer))
    (defun URH_ListPythDaily:[object{PYTHIA|S|PythDaily}] (from:integer to:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_Flush:string (entries:[object{PYTHIA|S|PythFlushEntry}]))

)
;;
(module PYTHIA GOV
    @doc "Dual-Apollo Pythia registry + on-chain Pyth work ledger (daily flush / running total)."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements PythiaV5)
    (implements PythiaLedgerV3)
    (implements OuronetPolicyV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_PYTHIA                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|PYTHIA_ADMIN)))
    (defcap GOV|PYTHIA_ADMIN ()                         (enforce-guard GOV|MD_PYTHIA))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|CronotonKey ()                           (+ (CT_Namespace) ".pythia-cronoton-keyset"))

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
    (defcap P|PYTHIA|CALLER ()
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
        (with-capability (GOV|PYTHIA_ADMIN)
            (write P|T policy-name {"policy" : policy-guard})
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|PYTHIA_ADMIN)
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
                (mg:guard (create-capability-guard (P|PYTHIA|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR:string                                (CT_Bar))
    (defconst PYTHIA|EPOCH:time                         (time "1970-01-01T00:00:00Z"))
    (defconst PYTHIA|LEDGER-EPOCH-START:time            (time "2026-08-01T00:00:00Z"))
    (defconst PYTHIA|SECONDS-PER-DAY:decimal            86400.0)
    (defconst PYTHIA|APOLLO-LEN:integer                 162)
    (defconst PYTHIA|DUAL-LINK-LEN:integer              325)
    (defconst PYTHIA|INFO:string                        "config")
    (defconst PYTHIA|REVOCATION:string                  "revocation")
    (defconst PYTHIA|STOACHAIN:string                   "stoachain")
    (defconst PYTHIA|REVOKE-IGNIS-FEE:decimal           1.0)
    (defconst PYTHIA|EPOCH-BLOCKS:integer               120)
    (defconst PYTHIA|APOLLO-STANDARD:string             "₱")
    (defconst PYTHIA|APOLLO-SMART:string                "Π")
    (defconst PYTHIA|MAX-DAILY-RANGE:integer            365)
    (defconst PYTHIA|MAX-FLUSH-BATCH:integer            1000)
    ;;{3.2}  schemas
    ;;
    (defschema PYTHIA|S|ApiKey
        @doc "One Apollo half (₱. slot or Π. consumer). Table key = apollo-account."
        public:string                                   ;;[.]   Canonical Apollo public-key material
        counterpart:string                              ;;[.]   Other half; BAR until linked (immutable once set)
        owner-account:string                            ;;[.]   Ouronet DALOS account that deployed + paid
        registered-at:time                              ;;[.]   Block time at deploy
        updated-at:time                                 ;;[M]   Block time at last mutation
        ;;
        ;;Select Keys
        apollo-account:string                           ;;[.]   Apollo account string (= table key)
    )
    (defschema PYTHIA|S|DualLink
        @doc "Dual-Apollo pair. Table key = standard + BAR + smart composite (325 chars)."
        standard-apollo:string                          ;;[.]   Standard ₱. slot half
        smart-apollo:string                             ;;[.]   Smart Π. consumer half
        consumer-lane:string                            ;;[M]   Stoic lane (C_Link) or auto PYTHIA-<hash12> (A_Link create); rename via C_UpdateDualConsumerLane
        iz-active:bool                                  ;;[M]   Live auth only when true (Cronoton or pre-linked false row)
        linked-at:time                                  ;;[.]   Block time at first link insert
        updated-at:time                                 ;;[M]   Block time at last iz-active mutation
        ;;
        ;;Select Keys
        dual-link-key:string                            ;;[.]   Composite key (= table key)
    )
    (defschema PYTHIA|S|Config
        deploy-price:decimal
        rename-price:decimal
    )
    (defschema PYTHIA|S|Revocation
        @doc "Last dual-link revoke anchor: block height at revoke (epoch = floor(height / 120))."
        revoked-at-height:integer
    )
    ;;{3.3}  tables
    (deftable PYTHIA|T|ApiKeys:{PYTHIA|S|ApiKey})                       ;;Key = <apollo-account>
    (deftable PYTHIA|T|DualLinks:{PYTHIA|S|DualLink})                   ;;Key = <dual-link-key>
    (deftable PYTHIA|T|Config:{PYTHIA|S|Config})                        ;;Key = PYTHIA|INFO
    (deftable PYTHIA|T|Revocation:{PYTHIA|S|Revocation})                ;;Key = PYTHIA|REVOCATION
    (deftable PYTHIA|T|PythDaily:{PythiaLedgerV3.PYTHIA|S|PythDaily})   ;;Key = <day ordinal string>
    (deftable PYTHIA|T|PythTotal:{PythiaLedgerV3.PYTHIA|S|PythTotal})   ;;Key = PYTHIA|STOACHAIN

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;#68L fix: removed PYTHIA|FLUSH-GAS-TARGET - dead constant, confirmed zero references
    ;;anywhere; likely a leftover from an earlier gas-based batching design later replaced by
    ;;the count-based PYTHIA|MAX-FLUSH-BATCH cap. No functional change.
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap PYTHIA|CRONOTON ()                          (enforce-guard (keyset-ref-guard (GOV|CronotonKey))))
    ;;{C3}  Composed
    (defcap PYTHIA|C>DEPLOY-API-KEY
        (
            owner-account:string
            apollo-account:string
            public:string
        )
        @doc "Owner deploys inert Apollo half (₱. or Π.). Composes SECURE for WI_ApiKey."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                ;;
                (is-smart:bool (not (UC_IsStandardApollo apollo-account)))
            )
            (enforce (!= public "") "Public key material must be non-empty")
            (ref-U|DALOS::GLYPH|UEV_ApolloAccount apollo-account is-smart)
            (compose-capability (PYTHIA|OWNER owner-account))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>LINK-DUAL
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        )
        @doc "Both Apollo half-owners link deployed halves into inactive dual row with lane label."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
            )
            (ref-U|DALOS::UEV_StoicTagName consumer-lane)
            (UEV_DualPairForLink standard-apollo smart-apollo)
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount standard-apollo)))
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount smart-apollo)))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>LINK-DUAL (standard-apollo:string smart-apollo:string)
        @doc "Cronoton create-or-activate: insert active dual row (auto lane) or flip inactive→true."
        @event
        (let
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
                (row-missing:bool (= (try false (UR_DLK|Data dlk)) false))
            )
            (if row-missing
                (UEV_DualPairForLink standard-apollo smart-apollo)
                (enforce
                    (fold (and) true
                        [
                            (not (UR_DualLinkIzActive dlk))
                            (= (UR_Counterpart standard-apollo) smart-apollo)
                            (= (UR_Counterpart smart-apollo) standard-apollo)
                        ]
                    )
                    "Dual link not ready for Cronoton activate (must exist inactive with counterparts)"
                )
            )
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>REVOKE-DUAL (dual-link-key:string)
        @doc "Both Apollo half-owners revoke active dual link (iz-active false)."
        @event
        (let
            (
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
                (iz-active:bool (at "iz-active" row))
            )
            (enforce iz-active "Dual link is already inactive")
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount standard)))
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount smart)))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>REVOKE-DUAL (dual-link-key:string)
        @doc "Cronoton revokes active dual link (Pythia authority)."
        @event
        (let
            (
                (iz-active:bool (UR_DualLinkIzActive dual-link-key))
            )
            (enforce iz-active "Dual link is already inactive")
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|C>UPDATE-DUAL-LANE (dual-link-key:string new-name:string)
        @doc "Both half-owners rename consumer-lane on the dual link row."
        @event
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                ;;
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
            )
            (ref-U|DALOS::UEV_StoicTagName new-name)
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount standard)))
            (compose-capability (PYTHIA|OWNER (UR_OwnerAccount smart)))
            (compose-capability (SECURE))
        )
    )
    (defcap PYTHIA|A>FLUSH
        (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Cronoton batch Pyth ledger flush; each entry is one calendar day (order-independent across txs)."
        @event
        (let
            (
                (entry-count:integer (length entries))
            )
            (enforce
                (fold (and) true
                    [
                        (> entry-count 0)
                        (<= entry-count PYTHIA|MAX-FLUSH-BATCH)
                        (UEV_FlushEntries entries)
                    ]
                )
                (format "Pyth flush batch invalid or exceeds max {} entries per tx" [PYTHIA|MAX-FLUSH-BATCH])
            )
            (compose-capability (PYTHIA|CRONOTON))
            (compose-capability (SECURE))
        )
    )
    ;;{C4}  Ownership [gold]
    (defcap PYTHIA|OWNER (owner-account:string)
        @doc "Caller controls the Ouronet (DALOS) account."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-account)
        )
    )

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    ;;
    (defun UDC_AKY|ApiKey:object{PYTHIA|S|ApiKey}
        (
            public:string
            counterpart:string
            owner-account:string
            apollo-account:string
        )
        @doc "Constructor for object{PYTHIA|S|ApiKey}; WI_ApiKey stamps registered-at/updated-at."
        { "public"         : public
        , "counterpart"    : counterpart
        , "owner-account"  : owner-account
        , "registered-at"  : PYTHIA|EPOCH
        , "updated-at"     : PYTHIA|EPOCH
        , "apollo-account" : apollo-account
        }
    )
    (defun UDC_AKY|Unregistered:object ()
        @doc "Sentinel for UR_ApiKeyRowOrNull when apollo-account is absent."
        { "apollo-account" : ""
        , "public"         : ""
        , "counterpart"    : BAR
        , "owner-account"  : ""
        , "registered-at"  : PYTHIA|EPOCH
        , "updated-at"     : PYTHIA|EPOCH
        , "is-registered"  : false
        }
    )
    (defun UDC_AKY|WithRegisteredFlag:object (row:object{PYTHIA|S|ApiKey})
        (+ row { "is-registered": true })
    )
    (defun UDC_DLK|DualLink:object{PYTHIA|S|DualLink}
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
            iz-active:bool
            dual-link-key:string
        )
        @doc "Constructor for object{PYTHIA|S|DualLink}; WI_DualLink stamps linked-at/updated-at."
        { "standard-apollo" : standard-apollo
        , "smart-apollo"    : smart-apollo
        , "consumer-lane"   : consumer-lane
        , "iz-active"       : iz-active
        , "linked-at"       : PYTHIA|EPOCH
        , "updated-at"      : PYTHIA|EPOCH
        , "dual-link-key"   : dual-link-key
        }
    )
    (defun UDC_DLK|Unregistered:object ()
        @doc "Sentinel for UR_DualLinkRowOrNull when dual-link-key is absent."
        { "dual-link-key"   : ""
        , "standard-apollo" : ""
        , "smart-apollo"    : ""
        , "consumer-lane"   : BAR
        , "iz-active"       : false
        , "linked-at"       : PYTHIA|EPOCH
        , "updated-at"      : PYTHIA|EPOCH
        , "is-registered"   : false
        }
    )
    (defun UDC_DLK|WithRegisteredFlag:object (row:object{PYTHIA|S|DualLink})
        (+ row { "is-registered": true })
    )
    (defun UDC_DualLinkView:object
        (
            dual-link-key:string
            standard-apollo:string
            smart-apollo:string
            iz-active:bool
            standard-owner:string
            smart-owner:string
            consumer-lane:string
        )
        @doc "Composite dual-link view (owners from ApiKeys halves)."
        { "dual-link-key"    : dual-link-key
        , "standard-apollo"  : standard-apollo
        , "smart-apollo"     : smart-apollo
        , "consumer-apollo"  : smart-apollo
        , "iz-active"        : iz-active
        , "standard-owner"   : standard-owner
        , "smart-owner"      : smart-owner
        , "consumer-lane"    : consumer-lane
        }
    )
    (defun UDC_PythMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        (
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythMetrics}."
        { "petitions": petitions
        , "pondus": pondus
        , "transactions": transactions
        , "gas-reserved": gas-reserved
        , "failed-transactions": failed-transactions
        , "wasted-gas-reserved": wasted-gas-reserved
        }
    )
    (defun UDC_PythMetrics|Zero:object{PythiaLedgerV3.PYTHIA|S|PythMetrics} ()
        @doc "Zeroed six-metric blob."
        (UDC_PythMetrics 0 0.0 0 0 0 0)
    )
    (defun UDC_PythTotal:object{PythiaLedgerV3.PYTHIA|S|PythTotal}
        (
            total-metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
            last-day:integer
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythTotal}."
        { "total-metrics": total-metrics
        , "last-day": last-day
        }
    )
    (defun UDC_PythTotal|Zero:object{PythiaLedgerV3.PYTHIA|S|PythTotal} ()
        @doc "Zeroed Pyth running total (default before first flush)."
        (UDC_PythTotal (UDC_PythMetrics|Zero) 0)
    )
    (defun UDC_PythDaily:object{PythiaLedgerV3.PYTHIA|S|PythDaily}
        (
            day:integer
            flushed-at:time
            iz-sealed:bool
            metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythDaily}."
        { "day": day
        , "flushed-at": flushed-at
        , "iz-sealed": iz-sealed
        , "metrics": metrics
        }
    )
    (defun UDC_PythFlushEntry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}
        (
            day:integer
            iz-complete:bool
            petitions:integer
            pondus:decimal
            transactions:integer
            gas-reserved:integer
            failed-transactions:integer
            wasted-gas-reserved:integer
        )
        @doc "Constructor for object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}."
        { "day": day
        , "iz-complete": iz-complete
        , "petitions": petitions
        , "pondus": pondus
        , "transactions": transactions
        , "gas-reserved": gas-reserved
        , "failed-transactions": failed-transactions
        , "wasted-gas-reserved": wasted-gas-reserved
        }
    )
    ;;{5.2}  Compute [UC]
    (defun UC_DeployPrice:decimal ()
        @doc "Alias → UR_DeployPrice (kept for Talos/INFO call sites)."
        (UR_DeployPrice)
    )
    (defun UC_RenamePrice:decimal ()
        @doc "Alias → UR_RenamePrice (kept for Talos/INFO call sites)."
        (UR_RenamePrice)
    )
    (defun UC_IsStandardApollo:bool (apollo-account:string)
        @doc "True when apollo-account begins with Standard ₱. (false = Smart Π.)."
        (= PYTHIA|APOLLO-STANDARD (take 1 apollo-account))
    )
    (defun UC_FeeDiscountAnchor:string ()
        @doc "STOA fee discount anchor — BAR yields tier 0.0; Elite discounts never apply."
        BAR
    )
    (defun UC_RevokeIgnisFee:decimal ()
        @doc "Fixed IGNIS toll for owner or Cronoton dual-link revoke (1 IGNIS; collected in TS01-C4)."
        PYTHIA|REVOKE-IGNIS-FEE
    )
    (defun UC_DualLinkKey:string (standard-apollo:string smart-apollo:string)
        @doc "Composite dual-link key: Standard ₱. + BAR + Smart Π."
        (+ standard-apollo (+ BAR smart-apollo))
    )
    (defun UC_DualLinkStandard:string (dual-link-key:string)
        @doc "Standard ₱. half of composite dual-link key."
        (take PYTHIA|APOLLO-LEN dual-link-key)
    )
    (defun UC_DualLinkSmart:string (dual-link-key:string)
        @doc "Smart Π. half of composite dual-link key."
        (drop (+ PYTHIA|APOLLO-LEN (length BAR)) dual-link-key)
    )
    (defun UC_ChainEpoch:integer (block-height:integer)
        @doc "Stoa chain epoch: block-height / 120 (int div) — matches explorer (e.g. 378734 → 3156)."
        (/ block-height PYTHIA|EPOCH-BLOCKS)
    )
    (defun UC_CurrentChainEpoch:integer ()
        @doc "Chain epoch for the executing block."
        (UC_ChainEpoch (at "block-height" (chain-data)))
    )
    (defun UC_AutonomousConsumerLane:string ()
        @doc "Token-style auto lane PYTHIA-<first 12 of prev-block-hash> via U|DALOS.UDC_Makeid; rename later via C_UpdateDualConsumerLane."
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
            )
            (ref-U|DALOS::UDC_Makeid "PYTHIA")
        )
    )
    ;;
    (defun UCk_PythDaily:string (day:integer)
        @doc "PYTHIA|T|PythDaily key = decimal string of day ordinal."
        (int-to-str 10 day)
    )
    (defun UC_PythDayOrdinal:integer (stamp:time)
        @doc "Calendar operating day: 1 = PYTHIA|LEDGER-EPOCH-START (UTC midnight boundary)."
        (+ 1 (floor (/ (diff-time stamp PYTHIA|LEDGER-EPOCH-START) PYTHIA|SECONDS-PER-DAY)))
    )
    (defun UC_AddPythMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        (
            a:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
            b:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        )
        @doc "Element-wise sum — A_Flush ADDs each entry (gateway drain delta) onto day row and grand total."
        { "petitions": (+ (at "petitions" a) (at "petitions" b))
        , "pondus": (+ (at "pondus" a) (at "pondus" b))
        , "transactions": (+ (at "transactions" a) (at "transactions" b))
        , "gas-reserved": (+ (at "gas-reserved" a) (at "gas-reserved" b))
        , "failed-transactions": (+ (at "failed-transactions" a) (at "failed-transactions" b))
        , "wasted-gas-reserved": (+ (at "wasted-gas-reserved" a) (at "wasted-gas-reserved" b))
        }
    )
    (defun UC_FlushAccFromTotal:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
        (tot:object{PythiaLedgerV3.PYTHIA|S|PythTotal})
        @doc "Seed batch fold from current PYTHIA|T|PythTotal row."
        { "total-metrics": (at "total-metrics" tot)
        , "last-day": (at "last-day" tot) }
    )
    (defun UC_FlushEntryMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        (entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry})
        @doc "Extract six-metric blob from a flush entry."
        (UDC_PythMetrics
            (at "petitions" entry)
            (at "pondus" entry)
            (at "transactions" entry)
            (at "gas-reserved" entry)
            (at "failed-transactions" entry)
            (at "wasted-gas-reserved" entry)
        )
    )
    (defun UC_MaxDay:integer (a:integer b:integer)
        @doc "Greater of two day ordinals."
        (if (> a b) a b)
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCi_DeployApiKey:decimal ()
        @doc "Cost single-source for PYTHIA|C_DeployApiKey — RAW native STOA toll \
            \ (UC_DeployPrice, default 500). Discount anchor is BAR (no Elite discount). \
            \ Consumed by TS01-C4 exec collect + INFO preview."
        (UC_DeployPrice)
    )
    (defun URCi_UpdateDualConsumerLane:decimal ()
        @doc "Cost single-source for PYTHIA|C_UpdateDualConsumerLane — RAW native STOA \
            \ rename toll (UC_RenamePrice). Consumed by exec collect + INFO preview."
        (UC_RenamePrice)
    )
    (defun URCi_RevokeLink:decimal ()
        @doc "Cost single-source for PYTHIA|C_RevokeLink — flat IGNIS toll \
            \ (UC_RevokeIgnisFee), collected via IGNIS::C_Collect in TS01-C4. \
            \ Consumed by exec + INFO."
        (UC_RevokeIgnisFee)
    )
    ;;
    ;; [1] PYTHIA|T|ApiKeys  (PYTHIA|S|ApiKey)  Key = <apollo-account>
    (defun UR_AKY|Data:object{PYTHIA|S|ApiKey} (apollo-account:string)
        @doc "Full Apollo half row."
        (read PYTHIA|T|ApiKeys apollo-account)
    )
    (defun UR_Public:string (apollo-account:string)
        (at "public" (read PYTHIA|T|ApiKeys apollo-account ["public"]))
    )
    (defun UR_Counterpart:string (apollo-account:string)
        (at "counterpart" (read PYTHIA|T|ApiKeys apollo-account ["counterpart"]))
    )
    (defun UR_OwnerAccount:string (apollo-account:string)
        (at "owner-account" (read PYTHIA|T|ApiKeys apollo-account ["owner-account"]))
    )
    (defun UR_RegisteredAt:time (apollo-account:string)
        (at "registered-at" (read PYTHIA|T|ApiKeys apollo-account ["registered-at"]))
    )
    (defun UR_UpdatedAt:time (apollo-account:string)
        (at "updated-at" (read PYTHIA|T|ApiKeys apollo-account ["updated-at"]))
    )
    (defun UR_ApiKeyRowOrNull:object (apollo-account:string)
        @doc "ApiKey row with is-registered flag, or unregistered sentinel."
        (if (= (try false (UR_AKY|Data apollo-account)) false)
            (UDC_AKY|Unregistered)
            (UDC_AKY|WithRegisteredFlag (UR_AKY|Data apollo-account))
        )
    )
    ;;
    ;; [2] PYTHIA|T|DualLinks  (PYTHIA|S|DualLink)  Key = <dual-link-key>
    (defun UR_DLK|Data:object{PYTHIA|S|DualLink} (dual-link-key:string)
        @doc "Full dual-link row."
        (read PYTHIA|T|DualLinks dual-link-key)
    )
    (defun UR_DualLinkIzActive:bool (dual-link-key:string)
        (at "iz-active" (read PYTHIA|T|DualLinks dual-link-key ["iz-active"]))
    )
    (defun UR_DualLinkRowOrNull:object (dual-link-key:string)
        @doc "DualLink row with is-registered flag, or unregistered sentinel."
        (if (= (try false (UR_DLK|Data dual-link-key)) false)
            (UDC_DLK|Unregistered)
            (UDC_DLK|WithRegisteredFlag (UR_DLK|Data dual-link-key))
        )
    )
    (defun UR_DualLinkIzActiveOrFalse:bool (dual-link-key:string)
        @doc "iz-active when dual row exists; false when absent (default-read)."
        (with-default-read PYTHIA|T|DualLinks dual-link-key
            {"iz-active" : false}
            {"iz-active" := iz}
            iz
        )
    )
    (defun UR_DualLinkConsumerLane:string (dual-link-key:string)
        @doc "Stoic lane on dual link row; BAR when row absent."
        (with-default-read PYTHIA|T|DualLinks dual-link-key
            {"consumer-lane" : BAR}
            {"consumer-lane" := lane}
            lane
        )
    )
    ;;
    ;; [3] PYTHIA|T|Config  (PYTHIA|S|Config)  Key = PYTHIA|INFO
    (defun UR_Config ()
        @doc "Full Config row (deploy-price + rename-price); defaults when unset. The defaults \
            \ are DERIVED, not hardcoded: every Ouronet price is denominated in DOLLARS and \
            \ converted to STOA at the oracle, so these read $50 deploy / $10 rename out of \
            \ IG|DETER through UC_StoaPrice (= 500 / 100 STOA at the $0.10 peg, unchanged from \
            \ the raw constants they replace). Governance may still override either in-table."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (with-default-read PYTHIA|T|Config PYTHIA|INFO
                {"deploy-price" : (ref-IGNIS::UC_StoaPrice "pythia-deploy")
                ,"rename-price" : (ref-IGNIS::UC_StoaPrice "pythia-rename")}
                {"deploy-price" := d, "rename-price" := r}
                {"deploy-price" : d, "rename-price" : r}
            )
        )
    )
    (defun UR_DeployPrice:decimal ()
        @doc "Governance-tunable deploy toll (default $50 = 500 STOA per Apollo half; collected in TS01-C4)."
        (at "deploy-price" (UR_Config))
    )
    (defun UR_RenamePrice:decimal ()
        @doc "Governance-tunable consumer-lane rename toll (default $10 = 100 STOA; collected in TS01-C4)."
        (at "rename-price" (UR_Config))
    )
    ;;
    ;; [4] PYTHIA|T|Revocation  (PYTHIA|S|Revocation)  Key = PYTHIA|REVOCATION
    (defun UR_RevocationAtHeight:integer ()
        @doc "Block height recorded at last dual-link revoke; 0 when never revoked."
        (with-default-read PYTHIA|T|Revocation PYTHIA|REVOCATION
            {"revoked-at-height" : 0}
            {"revoked-at-height" := h}
            h
        )
    )
    (defun UR_RevocationEpoch:integer ()
        @doc "Chain epoch at last revoke: floor(revoked-at-height / 120); 0 when never revoked."
        (let
            (
                (h:integer (UR_RevocationAtHeight))
            )
            (if (= h 0)
                0
                (UC_ChainEpoch h)
            )
        )
    )
    ;;
    ;; [5] PYTHIA|T|PythDaily  (PythiaLedgerV3.PYTHIA|S|PythDaily)  Key = <day ordinal string>
    (defun UR_PythDay:object{PythiaLedgerV3.PYTHIA|S|PythDaily} (day:integer)
        @doc "Full Pyth daily delta row for day ordinal; zeroed row for un-flushed / gap \
            \ days (never aborts, so range reads survive holes in the ledger)."
        (with-default-read PYTHIA|T|PythDaily (UCk_PythDaily day)
            { "day":         day
            , "flushed-at":  PYTHIA|LEDGER-EPOCH-START
            , "iz-sealed":   false
            , "metrics":     (UDC_PythMetrics|Zero) }
            { "day"        := d
            , "flushed-at" := fa
            , "iz-sealed"  := iz
            , "metrics"    := m }
            (UDC_PythDaily d fa iz m)
        )
    )
    ;;
    ;; [6] PYTHIA|T|PythTotal  (PythiaLedgerV3.PYTHIA|S|PythTotal)  Key = PYTHIA|STOACHAIN
    (defun UR_PythTotal:object{PythiaLedgerV3.PYTHIA|S|PythTotal} ()
        @doc "Running Pyth ledger totals; zeros when never flushed."
        (with-default-read PYTHIA|T|PythTotal PYTHIA|STOACHAIN
            { "total-metrics":
                { "petitions": 0
                , "pondus": 0.0
                , "transactions": 0
                , "gas-reserved": 0
                , "failed-transactions": 0
                , "wasted-gas-reserved": 0 }
            , "last-day": 0 }
            { "total-metrics" := total-metrics
            , "last-day" := last-day }
            (UDC_PythTotal total-metrics last-day)
        )
    )
    (defun UR_PythTotal|TotalMetrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics} ()
        @doc "Six-metric running totals blob; zeros when never flushed."
        (at "total-metrics" (UR_PythTotal))
    )
    (defun UR_PythTotal|LastDay:integer ()
        @doc "Highest calendar day ordinal with a daily row; 0 before first flush."
        (with-default-read PYTHIA|T|PythTotal PYTHIA|STOACHAIN
            {"last-day": 0}
            {"last-day" := last-day}
            last-day
        )
    )
    (defun UR_PythCurrentDay:integer ()
        @doc "Calendar day ordinal for the executing block-time (UTC; helper for Khronoton)."
        (UC_PythDayOrdinal (at "block-time" (chain-data)))
    )
    (defun UR_PythLedgerEpochStart:time ()
        @doc "UTC midnight anchor for calendar day 1; keyless read for off-chain day math."
        PYTHIA|LEDGER-EPOCH-START
    )
    (defun UR_PythMaxFlushBatch:integer ()
        @doc "Max calendar-day entries per A_Flush tx (tuned for ~2M gas; see HANDOFF)."
        PYTHIA|MAX-FLUSH-BATCH
    )
    (defun UR_PythDailyExists:bool (day:integer)
        @doc "True when PYTHIA|T|PythDaily has a row for day ordinal."
        ;; Avoid (keys ...) enumeration (disallowed in some capability/guard modes) AND
        ;; do not rely on UR_PythDay throwing (it now defaults). Probe a sentinel `day`
        ;; of -1: a real row always carries day >= 1, so present <=> read day != -1.
        (with-default-read PYTHIA|T|PythDaily (UCk_PythDaily day)
            { "day": -1 }
            { "day" := d }
            (!= d -1)
        )
    )
    ;;
    ;; [7] Composite reads (dual-link views)
    (defun UR_ApiKeyBySlot:object (standard-apollo:string)
        @doc "Dual-link view keyed by Standard ₱. slot (owner/status reads)."
        (let
            (
                (counterpart:string (UR_Counterpart standard-apollo))
                (dlk:string
                    (if (= counterpart BAR)
                        BAR
                        (UC_DualLinkKey standard-apollo counterpart)
                    )
                )
            )
            (if (= dlk BAR)
                (UDC_DualLinkView BAR standard-apollo BAR false BAR BAR BAR)
                (let
                    (
                        (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dlk))
                        (standard:string (at "standard-apollo" row))
                        (smart:string (at "smart-apollo" row))
                        (lane:string (at "consumer-lane" row))
                    )
                    (UDC_DualLinkView
                        dlk
                        standard
                        smart
                        (at "iz-active" row)
                        (UR_OwnerAccount standard)
                        (UR_OwnerAccount smart)
                        lane
                    )
                )
            )
        )
    )
    ;; WU_PythTotal|TotalMetrics — not used: mutates via WW_PythTotal (full row).
    ;; WU_PythTotal|LastDay — not used: mutates via WW_PythTotal (full row).
    ;;
    (defun URH_ApiKeyCount:integer ()
        (length (keys PYTHIA|T|ApiKeys))
    )
    (defun URH_ApiKeyCountStr:string ()
        (format "Pythia Apollo halves registered: {}" [(URH_ApiKeyCount)])
    )
    (defun URH_DualLinkCount:integer ()
        (length (keys PYTHIA|T|DualLinks))
    )
    (defun URH_ListAllApiKeys:[object] ()
        (select PYTHIA|T|ApiKeys
            [ "apollo-account" "public" "counterpart" "owner-account"
              "registered-at" "updated-at" ]
            (constantly true)
        )
    )
    (defun URH_ListAllDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (constantly true)
        )
    )
    (defun URH_ListActiveDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (where "iz-active" (= true))
        )
    )
    (defun URH_ListInactiveDualLinks:[object] ()
        (select PYTHIA|T|DualLinks
            [ "dual-link-key" "standard-apollo" "smart-apollo" "consumer-lane" "iz-active"
              "linked-at" "updated-at" ]
            (where "iz-active" (= false))
        )
    )
    (defun URH_ActiveDualLinkSet:[string] ()
        @doc "Active dual-link-key strings for Pythia cache mirror."
        (map
            (lambda (row:object) (at "dual-link-key" row))
            (select PYTHIA|T|DualLinks ["dual-link-key"] (where "iz-active" (= true)))
        )
    )
    (defun URH_ApiKeyByConsumer:object (smart-apollo:string)
        @doc "Auth-path lookup by Smart Π. consumer half (select on DualLinks)."
        (let
            (
                (rows:[object] (select PYTHIA|T|DualLinks
                    [ "dual-link-key" "standard-apollo" "smart-apollo" "iz-active" "consumer-lane" ]
                    (where "smart-apollo" (= smart-apollo))
                ))
            )
            (if (= (length rows) 0)
                (UDC_DualLinkView BAR BAR smart-apollo false BAR BAR BAR)
                (let
                    (
                        (row:object (at 0 rows))
                        (dlk:string (at "dual-link-key" row))
                        (standard:string (at "standard-apollo" row))
                        (lane:string (at "consumer-lane" row))
                    )
                    (UDC_DualLinkView
                        dlk
                        standard
                        smart-apollo
                        (at "iz-active" row)
                        (UR_OwnerAccount standard)
                        (UR_OwnerAccount smart-apollo)
                        lane
                    )
                )
            )
        )
    )
    (defun URH_ListPythDaily:[object{PythiaLedgerV3.PYTHIA|S|PythDaily}] (from:integer to:integer)
        @doc "Bounded daily delta rows for charting (inclusive range; empty when invalid)."
        (if
            (fold (or) false
                [
                    (< from 1)
                    (< to from)
                    (> (- to from) PYTHIA|MAX-DAILY-RANGE)
                ]
            )
            []
            (map
                (lambda (d:integer) (UR_PythDay d))
                (enumerate from to)
            )
        )
    )
    ;;
    (defun INFO_PYTHIA|DeployApiKey:object{OuronetInfoV2.ClientInfo}
        (
            patron:string
            owner-account:string
            apollo-account:string
            public:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_DeployApiKey (500 STOA per half)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (deploy-fee:decimal (UR_DeployPrice))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount owner-account))
                (kind:string
                    (if (UC_IsStandardApollo apollo-account) "Standard (₱.)" "Smart (Π.)")
                )
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Deploy {} Pythia Apollo half (unlinked)." [kind])
                    (format "Owner Ouronet account: {}." [sa])
                    (format "Native STOA deploy fee: {} per half (full price; Elite discounts do not apply)." [deploy-fee])
                    "Consumer lane is set at C_Link when both halves are paired."
                ]
                [(format "Pythia {} Apollo half registered (unlinked)." [kind])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_StoaCosts (UC_FeeDiscountAnchor) deploy-fee)
                []
            )
        )
    )
    (defun INFO_PYTHIA|Link:object{OuronetInfoV2.ClientInfo}
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_Link (inactive dual row; no fee)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
                (std-owner:string (UR_OwnerAccount standard-apollo))
                (smt-owner:string (UR_OwnerAccount smart-apollo))
                (sa-std:string (ref-I|OURONET::OI|UC_ShortAccount std-owner))
                (sa-smt:string (ref-I|OURONET::OI|UC_ShortAccount smt-owner))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Link Standard {} to Smart {} for lane {} (inactive dual row)." [standard-apollo smart-apollo consumer-lane])
                    (format "Standard half owner: {}." [sa-std])
                    (format "Smart half owner: {}." [sa-smt])
                    (format "Dual link key: {}." [dlk])
                    "No STOA or IGNIS fee. Cronoton activates after off-chain proof."
                ]
                [(format "Pythia dual link {} created for lane {} (inactive)." [dlk consumer-lane])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_PYTHIA|RevokeLink:object{OuronetInfoV2.ClientInfo}
        (
            patron:string
            dual-link-key:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_RevokeLink / A_RevokeLink (1 IGNIS)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (revoke-fee:decimal (UC_RevokeIgnisFee))
                (is-ignis-zero:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
                (sa-std:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount standard)))
                (sa-smt:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount smart)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Revoke (deactivate) dual link {}." [dual-link-key])
                    (format "Standard half owner: {}." [sa-std])
                    (format "Smart half owner: {}." [sa-smt])
                    (format "IGNIS fee: {} (minimum unit)." [revoke-fee])
                    "Counterpart fields remain immutable; deploy fresh halves to re-pair."
                ]
                [(format "Pythia dual link {} deactivated." [dual-link-key])]
                (if is-ignis-zero
                    (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                    (ref-I|OURONET::OI|UDC_IgnisCosts patron revoke-fee)
                )
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun INFO_PYTHIA|UpdateDualConsumerLane:object{OuronetInfoV2.ClientInfo}
        (
            patron:string
            dual-link-key:string
            new-name:string
        )
        @doc "ClientInfo for TS01-C4 PYTHIA|C_UpdateDualConsumerLane."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                ;;
                (rename-fee:decimal (UR_RenamePrice))
                (row:object{PYTHIA|S|DualLink} (UR_DLK|Data dual-link-key))
                (standard:string (at "standard-apollo" row))
                (smart:string (at "smart-apollo" row))
                (sa-std:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount standard)))
                (sa-smt:string (ref-I|OURONET::OI|UC_ShortAccount (UR_OwnerAccount smart)))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [
                    (format "Operation: Rename Pythia dual link consumer-lane to {}." [new-name])
                    (format "Dual link key: {}." [dual-link-key])
                    (format "Standard half owner: {}." [sa-std])
                    (format "Smart half owner: {}." [sa-smt])
                    (format "Native STOA rename fee: {} (full price; Elite discounts do not apply)." [rename-fee])
                ]
                [(format "Pythia dual link lane renamed to {}." [new-name])]
                (ref-I|OURONET::OI|UDC_NoIgnisCosts)
                (ref-I|OURONET::OI|UDC_StoaCosts (UC_FeeDiscountAnchor) rename-fee)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_FlushEntries:bool (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Validate flush batch: fold over entries; pure bool (no enforce)."
        (fold
            (lambda (acc:bool entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry})
                (let
                    (
                        (day:integer (at "day" entry))
                        (pondus:decimal (at "pondus" entry))
                        (sealed-ok:bool
                            (if (UR_PythDailyExists day)
                                (= (at "iz-sealed" (UR_PythDay day)) false)
                                true
                            )
                        )
                        (entry-ok:bool
                            (fold (and) true
                                [
                                    (> day 0)
                                    (>= (at "petitions" entry) 0)
                                    (>= pondus 0.0)
                                    (= pondus (floor pondus 3))
                                    (>= (at "transactions" entry) 0)
                                    (>= (at "gas-reserved" entry) 0)
                                    (>= (at "failed-transactions" entry) 0)
                                    (>= (at "wasted-gas-reserved" entry) 0)
                                    sealed-ok
                                ]
                            )
                        )
                    )
                    (and acc entry-ok)
                )
            )
            true
            entries
        )
    )
    (defun UEV_ValidateCompositeDualLinkKey:bool (dual-link-key:string)
        @doc "Dual-link-key is 325 chars: valid ₱. standard + BAR + valid Π. smart."
        (let
            (
                (ref-U|DALOS:module{UtilityDalosGlyphsV3} U|DALOS)
                ;;
                (standard:string (UC_DualLinkStandard dual-link-key))
                (smart:string (UC_DualLinkSmart dual-link-key))
                (sep:string (take (length BAR) (drop PYTHIA|APOLLO-LEN dual-link-key)))
            )
            (enforce (= (length dual-link-key) PYTHIA|DUAL-LINK-LEN) "Dual link key length must be 325")
            (enforce (= sep BAR) "Dual link key separator must be BAR")
            (and
                (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck standard false)
                (ref-U|DALOS::GLYPH|UEV_ApolloAccountCheck smart true)
            )
        )
    )
    (defun UEV_DualPairForLink
        (
            standard-apollo:string
            smart-apollo:string
        )
        @doc "Both halves deployed, unlinked, valid glyphs, dual row absent."
        (let 
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
            )
            (UEV_ValidateCompositeDualLinkKey dlk)
            (enforce (= (UR_Counterpart standard-apollo) BAR) "Standard half is already linked")
            (enforce (= (UR_Counterpart smart-apollo) BAR) "Smart half is already linked")
            ;;UNREACHABLE: the DLK row exists only if the pair was linked, and both link paths
            ;;(A_LinkDualApiKey / C_LinkDualApiKey) call XI_ApplyDualCounterparts -- which sets
            ;;BOTH counterparts -- immediately before WI_DualLink, in one transaction. So the
            ;;row's existence implies the counterpart enforces above already fired. Counterparts
            ;;are never cleared (C_RevokeDualLink deactivates only). Fail-closed backstop that
            ;;would start earning its keep if a non-atomic write path were ever introduced.
            ;;Demonstrated in REPL/Stage_01/[6.10]_PYTHIA.repl <<TX007g-02>>.
            (enforce
                (= (try false (UR_DLK|Data dlk)) false)
                "Dual link row already exists for this pair"
            )
        )
    )
    (defun UEV_DualPairReadyForActivate
        (
            standard-apollo:string
            smart-apollo:string
        )
        @doc "Both halves exist and counterparts match (linked metadata present)."
        (let 
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
            )
            (enforce (= (UR_Counterpart standard-apollo) smart-apollo) "Standard half not linked to Smart")
            ;;UNREACHABLE for the same reason as the backstop in UEV_DualPairForLink above: the
            ;;two counterparts are written as one atomic pair by XI_ApplyDualCounterparts, so
            ;;they cannot disagree, and any genuine mismatch trips the STANDARD-side enforce on
            ;;the line above. Pinned as unreachable, not as coverage, in
            ;;REPL/Stage_01/[6.10]_PYTHIA.repl <<TX007g-02>>.
            (enforce (= (UR_Counterpart smart-apollo) standard-apollo) "Smart half not linked to Standard")
            dlk
        )
    )
    ;;{5.5}  Write [W]
    ;;
    ;; Six blocks — one per deftable (table order). Within each block: WI → WW → WU (all fields).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_* / sibling WU_*.
    ;;
    ;; [1] PYTHIA|T|ApiKeys  (PYTHIA|S|ApiKey)  Key = <apollo-account>
    (defun WI_ApiKey:string
        (
            apollo-account:string
            row:object{PYTHIA|S|ApiKey}
        )
        @doc "Insert PYTHIA|T|ApiKeys full row (deploy only); stamps registered-at/updated-at from block time."
        (require-capability (SECURE))
        (let
            (
                (now:time (at "block-time" (chain-data)))
            )
            (insert PYTHIA|T|ApiKeys apollo-account
                (+ {"registered-at": now, "updated-at": now} row)
            )
        )
    )
    ;; WW_ApiKey — not used: deploy path is WI_ApiKey.
    ;; WU_ApiKey|Public — not mutable [.]
    (defun WU_ApiKey|Counterpart:string (apollo-account:string counterpart:string)
        @doc "Set counterpart on PYTHIA|T|ApiKeys (link only; immutability enforced in event caps)."
        (require-capability (SECURE))
        (update PYTHIA|T|ApiKeys apollo-account
            { "counterpart": counterpart
            , "updated-at": (at "block-time" (chain-data))
            }
        )
    )
    ;; WU_ApiKey|OwnerAccount — not mutable [.]
    ;; WU_ApiKey|RegisteredAt — not mutable [.]
    ;; WU_ApiKey|UpdatedAt — not used: mutates via WU_ApiKey|Counterpart.
    ;; WU_ApiKey|ApolloAccount — select key; WU not needed.
    ;;
    ;; [2] PYTHIA|T|DualLinks  (PYTHIA|S|DualLink)  Key = <dual-link-key>
    (defun WI_DualLink:string
        (
            dual-link-key:string
            row:object{PYTHIA|S|DualLink}
        )
        @doc "Insert PYTHIA|T|DualLinks full row (C_Link inactive or A_Link create+active); stamps linked-at/updated-at."
        (require-capability (SECURE))
        (let
            (
                (now:time (at "block-time" (chain-data)))
            )
            (insert PYTHIA|T|DualLinks dual-link-key
                (+ {"linked-at": now, "updated-at": now} row)
            )
        )
    )
    ;; WW_DualLink — not used: link path is WI_DualLink; revoke uses WU_DualLink|IzActive.
    ;; WU_DualLink|StandardApollo — not mutable [.]
    ;; WU_DualLink|SmartApollo — not mutable [.]
    (defun WU_DualLink|ConsumerLane:string (dual-link-key:string consumer-lane:string)
        @doc "Update consumer-lane on PYTHIA|T|DualLinks."
        (require-capability (SECURE))
        (update PYTHIA|T|DualLinks dual-link-key
            { "consumer-lane": consumer-lane
            , "updated-at": (at "block-time" (chain-data))
            }
        )
    )
    (defun WU_DualLink|IzActive:string (dual-link-key:string iz-active:bool)
        @doc "Update iz-active on PYTHIA|T|DualLinks."
        (require-capability (SECURE))
        (update PYTHIA|T|DualLinks dual-link-key
            { "iz-active": iz-active
            , "updated-at": (at "block-time" (chain-data))
            }
        )
    )
    ;; WU_DualLink|LinkedAt — not mutable [.]
    ;; WU_DualLink|UpdatedAt — not used: mutates via WU_DualLink|ConsumerLane / WU_DualLink|IzActive.
    ;; WU_DualLink|DualLinkKey — select key; WU not needed.
    ;;
    ;; [3] PYTHIA|T|Config  (PYTHIA|S|Config)  Key = PYTHIA|INFO
    ;; WI_Config — not used: first row touch is WW_Config (upsert path).
    (defun WW_Config:string (deploy-price:decimal rename-price:decimal)
        @doc "Upsert PYTHIA|T|Config full row (governance price updates)."
        (require-capability (SECURE))
        (write PYTHIA|T|Config PYTHIA|INFO
            {"deploy-price": deploy-price, "rename-price": rename-price}
        )
    )
    ;; WU_Config|DeployPrice — not used: mutates via WW_Config (full row).
    ;; WU_Config|RenamePrice — not used: mutates via WW_Config (full row).
    ;;
    ;; [4] PYTHIA|T|Revocation  (PYTHIA|S|Revocation)  Key = PYTHIA|REVOCATION
    ;; WI_Revocation — not used: first row touch is WW_Revocation (upsert path).
    (defun WW_Revocation:string (revoked-at-height:integer)
        @doc "Upsert PYTHIA|T|Revocation block height anchor (set on each revoke)."
        (require-capability (SECURE))
        (write PYTHIA|T|Revocation PYTHIA|REVOCATION
            {"revoked-at-height": revoked-at-height}
        )
    )
    ;; WU_Revocation|RevokedAtHeight — not used: mutates via WW_Revocation (full row).
    ;;
    ;; [5] PYTHIA|T|PythDaily  (PythiaLedgerV3.PYTHIA|S|PythDaily)  Key = <day ordinal string>
    (defun WI_PythDaily:string
        (
            day:integer
            row:object{PythiaLedgerV3.PYTHIA|S|PythDaily}
        )
        @doc "Insert PYTHIA|T|PythDaily full row (first flush of calendar day only)."
        (require-capability (SECURE))
        (insert PYTHIA|T|PythDaily (UCk_PythDaily day) row)
    )
    (defun WU_PythDaily|Metrics:string
        (
            day:integer
            metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
        )
        @doc "Replace same-day metrics snapshot (open day re-flush)."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCk_PythDaily day) {"metrics": metrics})
    )
    (defun WU_PythDaily|FlushedAt:string (day:integer flushed-at:time)
        @doc "Stamp latest flush time on the open calendar day row."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCk_PythDaily day) {"flushed-at": flushed-at})
    )
    (defun WU_PythDaily|IzSealed:string (day:integer iz-sealed:bool)
        @doc "Seal a calendar day when advancing to the next day."
        (require-capability (SECURE))
        (update PYTHIA|T|PythDaily (UCk_PythDaily day) {"iz-sealed": iz-sealed})
    )
    ;; WU_PythDaily|Day — not mutable [.]
    ;;
    ;; [6] PYTHIA|T|PythTotal  (PythiaLedgerV3.PYTHIA|S|PythTotal)  Key = PYTHIA|STOACHAIN
    ;; WI_PythTotal — not used: first row touch is WW_PythTotal (upsert path).
    (defun WW_PythTotal:string (row:object{PythiaLedgerV3.PYTHIA|S|PythTotal})
        @doc "Upsert PYTHIA|T|PythTotal full row (A_Flush total-metrics + last-day)."
        (require-capability (SECURE))
        (write PYTHIA|T|PythTotal PYTHIA|STOACHAIN row)
    )
    ;;{5.6}  Aux/X
    ;;
    ;;Protection: Class 1 — Innate protection offered by WW_Revocation
    (defun XI_RecordRevocationAtHeight:integer ()
        @doc "Record executing block height at revoke (fast-lane poll via UR_RevocationAtHeight)."
        ;; SECURE: granted by WW_Revocation (underlying W_).
        (let
            (
                (bh:integer (at "block-height" (chain-data)))
            )
            (WW_Revocation bh)
            bh
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WU_ApiKey|Counterpart
    (defun XI_ApplyDualCounterparts:string
        (
            standard-apollo:string
            smart-apollo:string
        )
        @doc "Fill immutable counterpart fields on both Apollo halves."
        ;; SECURE: granted by WU_ApiKey|Counterpart; BAR validated in PYTHIA|C>LINK-DUAL cap.
        (WU_ApiKey|Counterpart standard-apollo smart-apollo)
        (WU_ApiKey|Counterpart smart-apollo standard-apollo)
        (format "Counterparts linked: {} <-> {}" [standard-apollo smart-apollo])
    )
    ;;Protection: Class 1 — Innate protection offered by WW_PythTotal
    (defun XI_FlushPythLedger:string
        (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Process batch entries; commit running total once (entries may land in any tx order)."
        ;; SECURE: granted by WW_PythTotal (underlying W_).
        (let
            (
                (now:time (at "block-time" (chain-data)))
                (tot:object{PythiaLedgerV3.PYTHIA|S|PythTotal} (UR_PythTotal))
                (init:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc} (UC_FlushAccFromTotal tot))
                (final:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
                    (fold
                        (lambda
                            (
                                acc:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
                                entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}
                            )
                            (XI_1|ApplyOneFlushEntry acc entry now)
                        )
                        init
                        entries
                    )
                )
            )
            (WW_PythTotal
                (UDC_PythTotal
                    (at "total-metrics" final)
                    (at "last-day" final)
                )
            )
            (format "batch {} entries" [(length entries)])
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WU_PythDaily|Metrics,
    ;;Protection:          WU_PythDaily|FlushedAt, WU_PythDaily|IzSealed, WI_PythDaily
    (defun XI_1|ApplyOneFlushEntry:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
        (
            acc:object{PythiaLedgerV3.PYTHIA|S|PythFlushAcc}
            entry:object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}
            now:time
        )
        @doc "Fold step: ADD entry metrics (gateway drain delta) onto day row + grand total; seal flag only."
        ;; SECURE: granted by WI_/WU_PythDaily (underlying W_).
        (let
            (
                (day:integer (at "day" entry))
                (iz-complete:bool (at "iz-complete" entry))
                (delta:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                    (UC_FlushEntryMetrics entry)
                )
                (total-metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                    (at "total-metrics" acc)
                )
                (last-day:integer (at "last-day" acc))
                (next-last:integer (UC_MaxDay last-day day))
                (next-total:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                    (UC_AddPythMetrics total-metrics delta)
                )
            )
            (if (UR_PythDailyExists day)
                (let
                    (
                        (old-row:object{PythiaLedgerV3.PYTHIA|S|PythDaily} (UR_PythDay day))
                        (day-metrics:object{PythiaLedgerV3.PYTHIA|S|PythMetrics}
                            (UC_AddPythMetrics (at "metrics" old-row) delta)
                        )
                    )
                    (WU_PythDaily|Metrics day day-metrics)
                    (WU_PythDaily|FlushedAt day now)
                    (if iz-complete (WU_PythDaily|IzSealed day true) true)
                    { "total-metrics": next-total
                    , "last-day": next-last }
                )
                (let
                    (
                        (_:string (WI_PythDaily day (UDC_PythDaily day now iz-complete delta)))
                    )
                    { "total-metrics": next-total
                    , "last-day": next-last }
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_LinkDualApiKey:string (standard-apollo:string smart-apollo:string)
        @doc "Cronoton create-or-activate (no fee): create active dual with auto PYTHIA-<hash12> lane, or flip inactive C_Link row to true."
        (P|UEV_IMC)
        (let
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
                (row-missing:bool (= (try false (UR_DLK|Data dlk)) false))
            )
            (with-capability (PYTHIA|A>LINK-DUAL standard-apollo smart-apollo)
                (if row-missing
                    (let
                        (
                            (lane:string (UC_AutonomousConsumerLane))
                        )
                        (XI_ApplyDualCounterparts standard-apollo smart-apollo)
                        (WI_DualLink dlk
                            (UDC_DLK|DualLink
                                standard-apollo smart-apollo lane true dlk
                            )
                        )
                        (format "Pythia dual link {} created+activated with lane {}" [dlk lane])
                    )
                    (let
                        (
                            (msg:string
                                (format "Pythia dual link {} activated" [dlk])
                            )
                        )
                        (WU_DualLink|IzActive dlk true)
                        msg
                    )
                )
            )
        )
    )
    (defun A_RevokeDualLink:string (dual-link-key:string)
        @doc "Cronoton revokes active dual link."
        (P|UEV_IMC)
        (with-capability (PYTHIA|A>REVOKE-DUAL dual-link-key)
            (WU_DualLink|IzActive dual-link-key false)
            (XI_RecordRevocationAtHeight)
        )
        (format "Pythia dual link {} revoked by Cronoton" [dual-link-key])
    )
    (defun A_UpdateDeployPrice:string (new-price:decimal)
        (P|UEV_IMC)
        (with-capability (GOV|PYTHIA_ADMIN)
            (with-capability (SECURE)
                (WW_Config new-price (UR_RenamePrice))
            )
        )
        (format "Pythia deploy price set to {}" [new-price])
    )
    (defun A_UpdateRenamePrice:string (new-price:decimal)
        (P|UEV_IMC)
        (with-capability (GOV|PYTHIA_ADMIN)
            (with-capability (SECURE)
                (WW_Config (UR_DeployPrice) new-price)
            )
        )
        (format "Pythia rename price set to {}" [new-price])
    )
    (defun A_Flush:string (entries:[object{PythiaLedgerV3.PYTHIA|S|PythFlushEntry}])
        @doc "Cronoton batch flush: each entry is a drain DELTA — ADD onto day row + grand total; iz-complete seals only."
        (P|UEV_IMC)
        (with-capability (PYTHIA|A>FLUSH entries)
            (XI_FlushPythLedger entries)
        )
        (format "Pythia ledger flushed {} day entries" [(length entries)])
    )
    ;;
    (defun C_DeployApolloPythiaApiKey:string
        (
            owner-account:string
            apollo-account:string
            public:string
        )
        @doc "Owner deploys inert Apollo half (₱. or Π.). Fee in TS01-C4."
        (P|UEV_IMC)
        (let
            (
                (kind:string (if (UC_IsStandardApollo apollo-account) "Standard" "Smart"))
            )
            (with-capability (PYTHIA|C>DEPLOY-API-KEY owner-account apollo-account public)
                (WI_ApiKey apollo-account
                    (UDC_AKY|ApiKey public BAR owner-account apollo-account)
                )
            )
            (format "Pythia {} Apollo half {} registered (unlinked)" [kind apollo-account])
        )
    )
    (defun C_LinkDualApiKey:string
        (
            standard-apollo:string
            smart-apollo:string
            consumer-lane:string
        )
        @doc "Both half-owners link deployed halves into inactive dual row with lane (no fee)."
        (P|UEV_IMC)
        (let
            (
                (dlk:string (UC_DualLinkKey standard-apollo smart-apollo))
            )
            (with-capability (PYTHIA|C>LINK-DUAL standard-apollo smart-apollo consumer-lane)
                (XI_ApplyDualCounterparts standard-apollo smart-apollo)
                (WI_DualLink dlk
                    (UDC_DLK|DualLink
                        standard-apollo smart-apollo consumer-lane false dlk
                    )
                )
            )
            (format "Pythia dual link {} created for lane {} (inactive)" [dlk consumer-lane])
        )
    )
    (defun C_RevokeDualLink:string (dual-link-key:string)
        @doc "Both half-owners revoke active dual link. Fee in TS01-C4 (IGNIS)."
        (P|UEV_IMC)
        (with-capability (PYTHIA|C>REVOKE-DUAL dual-link-key)
            (WU_DualLink|IzActive dual-link-key false)
            (XI_RecordRevocationAtHeight)
        )
        (format "Pythia dual link {} revoked by owner" [dual-link-key])
    )
    (defun C_UpdateDualConsumerLane:string
        (
            dual-link-key:string
            new-name:string
        )
        @doc "Both half-owners rename consumer-lane on dual link row. Fee in TS01-C4."
        (P|UEV_IMC)
        (with-capability (PYTHIA|C>UPDATE-DUAL-LANE dual-link-key new-name)
            (WU_DualLink|ConsumerLane dual-link-key new-name)
        )
        (format "Pythia dual link {} lane renamed to {}" [dual-link-key new-name])
    )

)

;; Module install — (create-table ...) runs in the same tx as (module PYTHIA …) on greenfield deploy.
                    ;; policy
                   ;; policy meta
       ;; V1 name; V3 schema
        ;; carryover
     ;; V3 NEW
    ;; V3 NEW
     ;; Ledger NEW
     ;; Ledger NEW

;; --- tables for 22_PYTHIA.pact (8 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table PYTHIA|T|ApiKeys)
;; (create-table PYTHIA|T|Config)
;; (create-table PYTHIA|T|DualLinks)
;; (create-table PYTHIA|T|Revocation)
;; (create-table PYTHIA|T|PythDaily)
;; (create-table PYTHIA|T|PythTotal)

;; ===== 1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact =================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageOne_AdminV2
    @doc "Exposes Ouronet Administrative Functions"

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
    ;;
    ;;
    ;;Fueling Functions
    (defun XB_DynamicFuelSTOA ())
    (defun XE_ConditionalFuelSTOA (condition:bool))
    ;;{5.7}  User [A/C]
    ;;
    (defun DALOS|A_MigrateLiquidFunds:decimal (executor:string migration-target-stoa-account:string))
    (defun DALOS|A_ToggleOAPU (executor:string oapu:bool))
    (defun DALOS|A_ToggleGAP (executor:string gap:bool))
    (defun DALOS|A_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string))
    (defun DALOS|A_DeployStandardAccount (executor:string guard:guard stoa:string public:string))
    (defun DALOS|A_IgnisToggle (executor:string native:bool toggle:bool))
    (defun DALOS|A_AccountCreationStoaToggle (executor:string toggle:bool))
    (defun DALOS|A_SetIgnisSourcePrice (executor:string price:decimal))
    (defun DALOS|A_SetAutoFueling (executor:string toggle:bool))
    (defun DALOS|A_UpdatePublicKey (executor:string new-public:string))
    (defun DALOS|A_UpdateUsagePrice (executor:string action:string new-price:decimal))
    ;;
    ;;
    (defun BRD|A_Live (entity-id:string))
    (defun BRD|A_SetFlag (entity-id:string flag:integer))
    ;;
    ;;
    (defun DPTF|A_UpdateTreasuryDispoParameters (type:integer tdp:decimal tds:decimal))
    (defun DPTF|A_WipeTreasuryDebt ())
    (defun DPTF|A_WipeTreasuryDebtPartial (debt-to-be-wiped:decimal))
    (defun DPTF|A_DeployAccount (patron:string id:string account:string))
    ;;
    (defun DPOF|A_DeployAccount (patron:string id:string account:string))
    ;;
    (defun ATS|AA_RemoveSecondary (patron:string remover:string ats:string reward-token:string accounts-with-ats-data:[string]))
    (defun ATS|A_KickStart (executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    ;;
    (defun LIQUID|A_MigrateLiquidFunds:decimal (migration-target-stoa-account:string))
    ;;
    ;;
    (defun ORBR|A_Fuel ())
    ;;
    ;;
    (defun SWP|A_UpdatePrincipal (principal:string add-or-remove:bool))
    (defun SWP|A_RotatePrincipal (old:string new:string))
    (defun SWP|A_UpdateLimit (limit:decimal spawn:bool))
    (defun SWP|A_UpdateLiquidBoost (new-boost-variable:bool))
    (defun SWP|A_DefinePrimordialPool (primordial-pool:string))
    (defun SWP|A_ToggleAsymetricLiquidityAddition (toggle:bool))

)
;;
(module TS01-A GOV
    @doc "TALOS Stage 1 Administrator Functions \
        \ Contains All Administrator functions [DALOS BRD ORBR SWP]\
        \ Also contains Fueling Functions needed in all subsequent TALOS Modules"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_AdminV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-A                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-A_ADMIN)))
    (defcap GOV|TS01-A_ADMIN ()                         (enforce-guard GOV|MD_TS01-A))
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
        @doc "Talos Summoner Capability"
        true
    )
    (defcap P|TRG ()
        @doc "Talos Remote Governor Capability"
        true
    )
    (defcap P|ADMINISTRATIVE-SUMMONER ()
        (compose-capability (P|TS))
        (compose-capability (GOV|TS01-A_ADMIN))
    )
    (defcap P|GOVERNING-SUMMONER ()
        (compose-capability (P|TS))
        (compose-capability (P|TRG))
    )
    (defcap P|SECURE-SUMMONER ()
        (compose-capability (P|TS))
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
        (with-capability (GOV|TS01-A_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|TS01-A_ADMIN)
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
        @doc "Fix (audit finding #22L test-coverage sweep): ATS and ATSU were never \
            \ registered as permitted callers here (ATS was even bound - ref-P|ATS - \
            \ but never used), so any TS01-A admin function routing into either module \
            \ (e.g. ATS|AA_RemoveSecondary, ATS|A_KickStart) always failed P|UEV_IMC's \
            \ whitelist check - unconditionally, regardless of caller/key. Never caught \
            \ because those functions had zero test coverage. Every other Talos module's \
            \ own P|A_Define already registers into both ATS and ATSU; this just matches \
            \ that existing pattern."
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (mg:guard (create-capability-guard (P|TS)))
            )
            (ref-P|DALOS::P|A_Add
                "TS01-A|RemoteDalosGov"
                (create-capability-guard (P|TRG))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst GASLESS-PATRON                            (URC_Gassless))
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
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_Gassless ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|DALOS|SC_NAME)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    ;;  [Fueling Functions]
    ;;Protection: Class 5 — IMC + Custom: SECURE
    (defun XB_DynamicFuelSTOA ()
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (if (ref-DALOS::UR_AutoFuel)
                (with-capability (SECURE)
                    (XI_DirectFuelSTOA)
                )
                true
            )
        )
    )
    ;;
    ;;Protection: Class 5 — IMC + Custom: SECURE
    (defun XE_ConditionalFuelSTOA (condition:bool)
        (P|UEV_IMC)
        (if condition
            (with-capability (SECURE)
                (XB_DynamicFuelSTOA)
            )
            true
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_DirectFuelSTOA ()
        (require-capability (SECURE))
        (let
            (
                (ref-ORBR:module{OuroborosV2} OUROBOROS)
            )
            (with-capability (P|TS)
                (ref-ORBR::C_Fuel)
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;;  [DALOS_Administrator]
    (defun DALOS|A_MigrateLiquidFunds:decimal (executor:string migration-target-stoa-account:string)
        @doc "Migrates Ouronet Gas Station Funds, to another stoa adress, \
        \ if needed due to a migration to a new namespace and new module code \
        \ Outputs the migrated amount"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_MigrateLiquidFunds GASLESS-PATRON executor migration-target-stoa-account)
            )
        )
    )
    (defun DALOS|A_ToggleOAPU (executor:string oapu:bool)
        @doc "Toggles the Ouroboros Autonomous Price Update to <oapu>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleOAPU GASLESS-PATRON executor oapu)
                (if oapu
                    "Ouroboros Autonomous Price Update successfully turned ON"
                    "Ouroboros Autonomous Price Update successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_ToggleGAP (executor:string gap:bool)
        @doc "Toggles the Global administrative Pause, the GAP, to <toggle>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleGAP GASLESS-PATRON executor gap)
                (if gap
                    "Global Administrative Pause successfully turned ON"
                    "Global Administrative Pause successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string)
        @doc "Deploys a Smart Ouronet Account in Administrator Mode, without collection STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::A_DeploySmartAccount executor guard stoa sovereign public)
                (format "Succesfuly deployed Smart Account {} in Admin Mode!" [sa])
            )
        )
    )
    (defun DALOS|A_DeployStandardAccount (executor:string guard:guard stoa:string public:string)
        @doc "Deploys a Standard Ouronet Account in Administrator Mode, without collection STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::A_DeployStandardAccount executor guard stoa public)
                (format "Succesfuly deployed Standard Account {} in Admin Mode!" [sa])
            )
        )
    )
    (defun DALOS|A_AccountCreationStoaToggle (executor:string toggle:bool)
        @doc "ADMIN: switch STOA collection on Ouronet ACCOUNT CREATION on/off, INDEPENDENTLY \
            \ of the global STOA switch (DALOS|A_IgnisToggle native=true). OFF — the default — \
            \ keeps onboarding free while global STOA collection is ON. Admin op, so this \
            \ entrypoint is itself IGNIS+STOA exempt."
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleAccountCreationStoa GASLESS-PATRON executor toggle)
                (if toggle
                    "Account-Creation STOA Collection succesfully turned ON"
                    "Account-Creation STOA Collection succesfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_IgnisToggle (executor:string native:bool toggle:bool)
        @doc "Toggles Ouronet Gas Collection \
        \ <native> true is STOA Collection for Specific Usage Actions \
        \ <native> false is IGNIS Collection for Client Functions"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_ToggleGasCollection GASLESS-PATRON executor native toggle)
                (if native
                    (if toggle
                        "STOA Collection succesfully turned ON"
                        "STOA Collection succesfully turned OFF"
                    )
                    (if toggle
                        "IGNIS Collection succesfully turned ON"
                        "IGNIS Collection succesfully turned OFF"
                    )
                )
            )
        )
    )
    (defun DALOS|A_SetIgnisSourcePrice (executor:string price:decimal)
        @doc "Sets OUROBOROS Price in $. Used in Compresion and Sublimation"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_SetIgnisSourcePrice GASLESS-PATRON executor price)
                (format "Succesfuly set IGNIS price to {}" [price])
            )
        )
    )
    (defun DALOS|A_SetAutoFueling (executor:string toggle:bool)
        @doc "Sets Automatic fueling of Collected STOA for the Increase of the <StoaLiquindex>"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_SetAutoFueling GASLESS-PATRON executor toggle)
                (if toggle
                    "LiquidStaking Autofueling successfully turned ON"
                    "LiquidStaking Autofueling successfully turned OFF"
                )
            )
        )
    )
    (defun DALOS|A_UpdatePublicKey (executor:string new-public:string)
        @doc "Updates Public Key; To be used only as failsafe by the Admin"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-DALOS::A_UpdatePublicKey GASLESS-PATRON executor new-public)
                (format "Public Key for Account {} successfully updated!" [sa])
            )
        )
    )
    (defun DALOS|A_UpdateUsagePrice (executor:string action:string new-price:decimal)
        @doc "Updates specific Usage Price in STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::A_UpdateUsagePrice GASLESS-PATRON executor action new-price)
                (format "Price for Action {} successfully updated with {}" [action new-price])
            )
        )
    )
    ;;  [BRD_Administrator]
    (defun BRD|A_Live (entity-id:string)
        @doc "Sets <pending-branding> for an <entity-id> to <live-branding>, reseting <pending-branding> data \
            \ Resetting <pending-branding> data does not reset its last 3 keys \
            \ Can only be done by Branding Administrator"
        (with-capability (P|TS)
            (let
                (
                    (ref-BRD:module{BrandingV2} BRD)
                )
                (ref-BRD::A_Live entity-id)
            )
        )
    )
    (defun BRD|A_SetFlag (entity-id:string flag:integer)
        @doc "Forcibly (in administrator mode) sets a Branding Flag for <entity-id> \
            \ <0> Flag = Golden Flag        Premium Flag reserved for Demiourgos Entity IDs \
            \ <1> Flag = Blue Flag          Premium Flag for Entity IDs (non-Demiourgos); \
            \                               Premium Flags are paid live branded Entity-IDs that are not labeled as problematic \
            \                               Paid live branded Entity IDs can still be flaged Red by the Branding Administrator \
            \ <2> Flag = Green Flag         Standard Flag for Entity IDs (non-Demiourgos) that have their Branding set to Live \
            \ <3> Flag = Gray Flag          Default Flag for newly-issued Entity-IDs (non-Demiourgos) that dont have their Branding Live yet \
            \ <4> Flag = Red Flag           Problem Flag for Entity IDs, marking potential dangerous or scam Entity IDs"
        (with-capability (P|TS)
            (let
                (
                    (ref-BRD:module{BrandingV2} BRD)
                )
                (ref-BRD::A_SetFlag entity-id flag)
            )
        )
    )
    ;;  [DPTF_Administrator]
    (defun DPTF|A_UpdateTreasuryDispoParameters (type:integer tdp:decimal tds:decimal)
        @doc "Updates Treasury Dispo Parameters, that dictate how much OURO Debt the Treasury can incurr \
            \ Type can only be 0 1 2 3 \
            \ Type 0 = No Treasury Dispo \
            \ Type 1 = Maximum Dispo equal to Total Supply \
            \ Type 2 = Promile Based Dispo; A <tdp> value of 320.0 means up to 32% of Total Supply can be overspent\
            \ Type 3 = Absolute Value Dispo in Thousands; A <tds> value of 250.0 means up to 250 Thousands can be overspent"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::A_UpdateTreasury type tdp tds)
            )
        )
    )
    (defun DPTF|A_WipeTreasuryDebt ()
        @doc "Wipes all Treasury Debt, increasing OURO supply by the Debt Amount, \
            \ and setting Treasury Dispo Parameters to neutral (no overspend capability)"
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::A_WipeTreasuryDebt)
            )
        )
    )
    (defun DPTF|A_WipeTreasuryDebtPartial (debt-to-be-wiped:decimal)
        @doc "Wipes all partialy the Treasury Debt, increasing OURO supply by the <debt-to-be-wiped> amount \
        \ Treasury Dispo Parameters are left as they are, this function simply wipe a part of the Treasury Debt through mint."
        (with-capability (P|TS)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::A_WipeTreasuryDebtPartial debt-to-be-wiped)
            )
        )
    )
    (defun DPTF|A_DeployAccount (patron:string id:string account:string)
        @doc "Administrative variant of DPTF|C_DeployAccount (TS01-C1) - deploys a DPTF \
            \ Account for <account> with no ownership check on <account>. For \
            \ system/infrastructure account setup only (a smart account governed by \
            \ another module, e.g. a pool/vault/dispenser account), where the caller \
            \ legitimately cannot hold <account>'s own guard. End-user self-service \
            \ activation must use the ownership-gated DPTF|C_DeployAccount instead."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DPTF::C_DeployAccount id account)
                (ref-IGNIS::C_Collect patron
                    ;;charge through the SAME reader the client twin uses, so the admin variant
                    ;;cannot drift from DPTF|C_DeployAccount's price
                    (ref-DPTF::URCi_DeployAccount account)
                )
                (format "DPTF {} added to {} Ouronet Account succesfully! (admin)" [id sa])
            )
        )
    )
    ;;
    ;;  [DPOF_Administrator]
    (defun DPOF|A_DeployAccount (patron:string id:string account:string)
        @doc "Administrative variant of DPOF|C_DeployAccount (TS01-C1) - deploys a DPOF \
            \ Account for <account> with no ownership check on <account>. For \
            \ system/infrastructure account setup only (a smart account governed by \
            \ another module, e.g. a pool/vault/dispenser account), where the caller \
            \ legitimately cannot hold <account>'s own guard. End-user self-service \
            \ activation must use the ownership-gated DPOF|C_DeployAccount instead."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DPOF::C_DeployAccount id account)
                (ref-IGNIS::C_Collect patron
                    ;;charge through the SAME reader the client twin uses, so the admin variant
                    ;;cannot drift from DPOF|C_DeployAccount's price
                    (ref-DPOF::URCi_DeployAccount account)
                )
                (format "Succesfully deployed a New DPOF Account for DPOF {} on Ouronet Account {} (admin)" [id sa])
            )
        )
    )
    ;;  [ATS_Administrator]
    (defun ATS|AA_RemoveSecondary (patron:string remover:string ats:string reward-token:string accounts-with-ats-data:[string])
        @doc "Administrative Variant, queries <accounts-with-ats-data> via <DPTF-DPOF-ATS|UR_FilterKeysForInfo>"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-ATSU::AA_RemoveSecondary remover ats reward-token accounts-with-ats-data)
                )
            )
        )
    )
    (defun ATS|A_KickStart (executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Administrative Variant (audit finding #11M / M2): forgoes pool ownership \
            \ for module governance, with no upper bound on the resulting KickStart \
            \ index (still subject to the shared 0.1 floor) - for legitimate ratios \
            \ above the owner-facing ATS|C_KickStart's 100.0 ceiling."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV2} ATSU)
                )
                ;;A_ on the blessed path: the collection runs EXACTLY as any C_'s does -- it is
                ;;simply served by GASLESS-PATRON, the one account IGNIS::C_Collect exempts. The
                ;;path is preserved, not skipped; that is what makes an A_ gasless.
                (ref-IGNIS::C_Collect GASLESS-PATRON
                    (ref-ATSU::A_KickStart GASLESS-PATRON executor ats rt-amounts rbt-request-amount)
                )
            )
        )
    )
    ;;  [LIQUID_Administrator]
    (defun LIQUID|A_MigrateLiquidFunds:decimal (migration-target-stoa-account:string)
        @doc "Migrates Stoa Liquid Staking STOA Funds, to another stoa adress, \
        \ if needed due to a migration to a new namespace and new module code \
        \ Outputs the migrated amount"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
                )
                (ref-LIQUID::A_MigrateLiquidFunds migration-target-stoa-account)
            )
        )
    )
    ;;  [OUROBOROS_Administrator]
    (defun ORBR|A_Fuel ()
        @doc "Uses up all collected Native STOA on the Ouroboros Account, wraps it, and fuels the Stoa Liquid Index \
            \ Transaction fee must be paid for by the Ouronet Gas Station, so that all available balance may be used. \
            \ Is Part of all the Functions that collect native STOA as fee, \
            \ boosting the STOA Liquid Index, from 40% of the collected STOA \
            \ As Stand-Alone Function, can only be used by the Admin. \
            \ In normal condition, there is no need for using it on itself, as all collected STOA is automatically used up \
            \ by implementing this function at the end of those funtions that collect the STOA. \
            \ Dalos-Patron is the only gass"
        ;;GATE FIX (P3.3 sweep): this was (with-capability (SECURE)), and SECURE in this module
        ;;is (defcap SECURE () true) -- a C1 trivial cap. So the function's own @doc above ("As
        ;;Stand-Alone Function, can only be used by the Admin") was not enforced by anything:
        ;;ANY signer could call it and force the STOA fuelling at a moment of their choosing.
        ;;Every other |A_ entrypoint in this module already gates on P|ADMINISTRATIVE-SUMMONER
        ;;(P|TS + GOV|TS01-A_ADMIN); this one was the single outlier. The only live caller,
        ;;REPL/Stage_01/[6.3]_SWP.repl:2443, already signs with a Demiurgoi key, so no legitimate
        ;;caller loses access.
        ;;
        ;;SECURE is still ACQUIRED rather than replaced: XI_DirectFuelSTOA require-capability's it,
        ;;so swapping the two caps outright breaks the call (it did -- the suite caught it). The
        ;;admin cap gates, SECURE grants. Same shape as XB_DynamicFuelSTOA, the automatic path,
        ;;which gates on P|UEV_IMC and then grants SECURE inside it.
        ;;
        ;;Pinned by REPL/modules/CONFORMANCE.repl <<CONF-05>>; the class is linted by
        ;;_conformance.py [admin-gate-terminal], which was written FROM this defect and verified
        ;;against it by reverting the fix and watching the rule fire.
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (with-capability (SECURE)
                (XI_DirectFuelSTOA)
            )
        )
    )
    ;;  [SWP_Administrator]
    (defun SWP|A_UpdatePrincipal (principal:string add-or-remove:bool)
        @doc "Adds <principal> (while under the 7 maximum) or removes it (while at \
        \ least 2 would remain defined, and <principal> isn't a 'major' principal \
        \ — #65eL). A principal is a token that must exist once in every W or P \
        \ Swpiar, on the first position. Also, the S Pools, must have at least \
        \ one Token dtied directly to a principal Token. SWPT's storage is \
        \ principal-agnostic (#21H), so removal of a minor principal is safe — it \
        \ only affects future pool-issuance principal-anchoring validation, never \
        \ existing routing. A major principal (currently a member of the \
        \ primordial pool — always OURO/WSTOA/SSTOA in practice) can never be removed \
        \ this way; retiring one requires redefining the primordial pool itself \
        \ (SWP|A_DefinePrimordialPool). SWP|A_RotatePrincipal remains available as \
        \ an atomic, count-preserving alternative for minor principals — it never \
        \ touches the floor or cap, but is equally blocked from rotating a major \
        \ principal away."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_UpdatePrincipal principal add-or-remove)
            )
        )
    )
    (defun SWP|A_RotatePrincipal (old:string new:string)
        @doc "Atomically replaces principal <old> with <new> in one step, without \
        \ touching the 2-minimum floor or 7-maximum cap. Safe with respect to \
        \ SWPT's routing graph (#21H fix): SWPT's storage is principal-agnostic, \
        \ so this never orphans anything there — the only effect is on future \
        \ pool-issuance principal-anchoring validation. Rejects rotating a \
        \ principal into itself, rejects <new> already being a principal, and \
        \ rejects <old> being a 'major' principal (currently a member of the \
        \ primordial pool — always OURO/WSTOA/SSTOA in practice, #65eL) — majors are \
        \ fixed, retirable only by redefining the primordial pool itself \
        \ (SWP|A_DefinePrimordialPool)."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_RotatePrincipal old new)
            )
        )
    )
    (defun SWP|A_UpdateLimit (limit:decimal spawn:bool)
        @doc "Updates either the <spawn-limit> or <inactive-limit> for the SWP Module \
        \ The <spawn-limit> is the minimum number in STOA that a pool must be created with, in order to be opened for swap \
        \ The <inactive-limit> is the minimum number in STOA as total pool liquidity value, that trigger autonomic disable of the swap mechanism"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_UpdateLimit limit spawn)
            )
        )
    )
    (defun SWP|A_UpdateLiquidBoost (new-boost-variable:bool)
        @doc "Updates Liquid Boost switch. When set to true, every swap is set to pump the Index for Stoa Liquid Staking"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_UpdateLiquidBoost new-boost-variable)
            )
        )
    )
    (defun SWP|A_DefinePrimordialPool (primordial-pool:string)
        @doc "Updates the Primordial Pool"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_DefinePrimordialPool primordial-pool)
            )
        )
    )
    (defun SWP|A_ToggleAsymetricLiquidityAddition (toggle:bool)
        @doc "Updates the Primordial Pool"
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-SWP:module{SwapperV4} SWP)
                )
                (ref-SWP::A_ToggleAsymetricLiquidityAddition toggle)
            )
        )
    )

)

;; --- tables for 01_TS01-A.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact ================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageOne_ClientOneV2
    @doc "Exposes Ouronets Stage One First Batch of Client Functions \
        \ Modules: DALOS, DPTF and DPOF are included in the First Batch"

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
    (defun DALOS|C_ControlSmartAccount (patron:string executor:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool))
    (defun DALOS|C_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string))
    (defun DALOS|C_DeployStandardAccount (executor:string guard:guard stoa:string public:string))
    (defun DALOS|C_RotateGovernor (patron:string executor:string governor:guard))
    (defun DALOS|C_RotateGuard (patron:string executor:string new-guard:guard safe:bool))
    (defun DALOS|C_RotateStoa (patron:string executor:string stoa:string))
    (defun DALOS|C_RotateSovereign (patron:string executor:string new-sovereign:string))
    (defun DALOS|C_UpdateEliteAccount (patron:string account:string))
    (defun DALOS|C_UpdateEliteAccountSquared (patron:string sender:string receiver:string))
    ;;
    ;;
    (defun DPTF|C_UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun DPTF|C_UpgradeBranding (patron:string entity-id:string months:integer))
    ;;
    (defun DPTF|C_Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool]))
    (defun DPTF|C_RotateOwnership (patron:string id:string new-owner:string))
    (defun DPTF|C_Control (patron:string id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool))
    (defun DPTF|C_TogglePause (patron:string id:string toggle:bool))
    (defun DPTF|C_ToggleReservation (patron:string id:string toggle:bool))
        ;;
    (defun DPTF|C_ToggleFee (patron:string id:string toggle:bool))
    (defun DPTF|C_SetMinMove (patron:string id:string min-move-value:decimal))
    (defun DPTF|C_SetFee (patron:string id:string fee:decimal))
    (defun DPTF|C_SetFeeTarget (patron:string id:string target:string))
    (defun DPTF|C_DonateFees (patron:string id:string))
    (defun DPTF|C_ResetFeeTarget (patron:string id:string))
    (defun DPTF|C_ToggleFeeLock (patron:string id:string toggle:bool))
        ;;
    (defun DPTF|C_DeployAccount (patron:string id:string account:string))
    (defun DPTF|C_ToggleFreezeAccount (patron:string id:string account:string toggle:bool))
    (defun DPTF|C_ToggleBurnRole (patron:string id:string account:string toggle:bool))
    (defun DPTF|C_ToggleMintRole (patron:string id:string account:string toggle:bool))
    (defun DPTF|C_ToggleFeeExemptionRole (patron:string id:string account:string toggle:bool))
    (defun DPTF|C_ToggleTransferRole (patron:string id:string account:string toggle:bool))
        ;;
    (defun DPTF|C_ClearDispo (patron:string account:string))
    (defun DPTF|C_Burn (patron:string id:string account:string amount:decimal))
    (defun DPTF|C_Mint (patron:string id:string account:string amount:decimal origin:bool))
    (defun DPTF|C_WipeSlim (patron:string id:string atbw:string amtbw:decimal))
    (defun DPTF|C_Wipe (patron:string id:string atbw:string))
        ;;
    (defun DPTF|C_Transmute (patron:string id:string transmuter:string transmute-amount:decimal))
    (defun DPTF|C_Transfer (patron:string id:string sender:string receiver:string transfer-amount:decimal method:bool))
    (defun DPTF|C_MultiTransfer (patron:string id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal] method:bool))
    (defun DPTF|C_BulkTransfer (patron:string id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal]))
    (defun DPTF|C_MultiBulkTransfer (patron:string id:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]]))
    ;;
    ;;
    (defun DPOF|C_UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}]))
    (defun DPOF|C_UpgradeBranding (patron:string entity-id:string months:integer))
    ;;
    (defun DPOF|C_Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool]))
    (defun DPOF|C_RotateOwnership (patron:string id:string new-owner:string))
    (defun DPOF|C_Control (patron:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool))
    (defun DPOF|C_TogglePause (patron:string id:string toggle:bool))
        ;;
    (defun DPOF|C_DeployAccount (patron:string id:string account:string))
    (defun DPOF|C_ToggleFreezeAccount (patron:string id:string account:string toggle:bool))
    (defun DPOF|C_ToggleAddQuantityRole (patron:string id:string account:string toggle:bool))
    (defun DPOF|C_ToggleBurnRole (patron:string id:string account:string toggle:bool))
    (defun DPOF|C_MoveCreateRole (patron:string id:string receiver:string))
    (defun DPOF|C_ToggleTransferRole (patron:string id:string account:string toggle:bool))
        ;;
    (defun DPOF|C_AddQuantity (patron:string id:string account:string nonce:integer amount:decimal))
    (defun DPOF|C_Burn (patron:string id:string account:string nonce:integer amount:decimal))
    (defun DPOF|C_Mint (patron:string id:string account:string amount:decimal meta-data-chain:[object]))
    (defun DPOF|C_WipeSlim (patron:string id:string account:string nonce:integer amount:decimal))
    (defun DPOF|CC_WipeHeavy (patron:string id:string account:string))
    (defun DPOF|C_WipePure (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
    (defun DPOF|C_WipeClean (patron:string id:string account:string nonces:[integer]))
    (defun DPOF|Cp_WipeSlice (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces}))
        ;;
    (defun DPOF|C_Transmit (patron:string id:string nonces:[integer] amounts:[decimal] sender:string receiver:string method:bool))
    (defun DPOF|C_Transfer (patron:string id:string nonces:[integer] sender:string receiver:string method:bool))    
    (defun DPOF|C_BulkTransfer
        (patron:string id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool)
    )

)
;;
(module TS01-C1 GOV
    @doc "TALOS Stage 1 Client Functiones Part 1"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_ClientOneV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-C1                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()                        (enforce-guard GOV|MD_TS01-C1))
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
        (with-capability (GOV|TS01-C1_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|TS01-C1_ADMIN)
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
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ELITE:module{OuronetPolicyV2} ELITE)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ELITE::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|TS01-A::P|A_AddIMP mg)
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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [DALOS_Client]
    (defun DALOS|C_ControlSmartAccount (patron:string executor:string payable-as-smart-contract:bool payable-by-smart-contract:bool payable-by-method:bool)
        @doc "Controls Smart Ouronet Account properties via boolean triggers"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_ControlSmartAccount patron executor payable-as-smart-contract payable-by-smart-contract payable-by-method)
                (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_ControlSmartAccount executor))
                (format "Smart Ouronet Account {} controlled succesfully" [executor])
            )
        )
    )
    (defun DALOS|C_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string)
        @doc "Deploys a Standard Ouronet Account, taxing for STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DALOS::C_DeploySmartAccount executor guard stoa sovereign public)
                ;;Collecting IGNIS is moved from DALOS here, due to IGNIS existing after DALOS
                (if (not (ref-IGNIS::URC_IsNativeGasZero))
                    (ref-IGNIS::STOA|C_Collect executor (ref-IGNIS::DALOS|URCi_DeploySmartAccount))
                    true
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Smart Ouronet Account {} deployed succesfully" [executor])
            )
        )
    )
    (defun DALOS|C_DeployStandardAccount (executor:string guard:guard stoa:string public:string)
        @doc "Deploys a Standard Ouronet Account, taxing for STOA"
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-DALOS::C_DeployStandardAccount executor guard stoa public)
                ;;Collecting IGNIS is moved from DALOS here, due to IGNIS existing after DALOS
                (if (not (ref-IGNIS::URC_IsNativeGasZero))
                    (ref-IGNIS::STOA|C_Collect executor (ref-IGNIS::DALOS|URCi_DeployStandardAccount))
                    true
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Standard Ouronet Account {} deployed succesfully" [executor])
            )
        )
    )
    (defun DALOS|C_RotateGovernor (patron:string executor:string governor:guard)
        @doc "Rotates the governor of a Smart Ouronet Account \
        \ The Governor acts as a governing entity for the Smart Ouronet Account allowing fine control of its assets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateGovernor patron executor governor)
                (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_RotateGovernor executor))
                (format "Ouronet Account {} Governor-Guard rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_RotateGuard (patron:string executor:string new-guard:guard safe:bool)
        @doc "Rotates the guard of an Ouronet Safe. Boolean <safe> also enforces the <new-guard>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateGuard patron executor new-guard safe)
                (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_RotateGuard executor))
                (format "Ouronet Account {} Primary-Guard rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_RotateStoa (patron:string executor:string stoa:string)
        @doc "Rotates the STOA Account attached to an Ouronet Account. \
        \ The attached STOA Account is the account that makes STOA Payments for specific Ouronet Actions"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateStoa patron executor stoa)
                (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_RotateStoa executor))
                (format "Ouronet Account {} Attached Stoa-Address rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_RotateSovereign (patron:string executor:string new-sovereign:string)
        @doc "Rotates the Sovereign of a Smart Ouronet Account \
        \ The Sovereign of a Smart Ouronet Account acts as its owner, allowing dominion over its assets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                )
                (ref-DALOS::C_RotateSovereign patron executor new-sovereign)
                (ref-IGNIS::C_Collect patron (ref-IGNIS::DALOS|URCi_RotateSovereign executor))
                (format "Smart Ouronet Account {} Sovereign rotated succesfully!" [executor])
            )
        )
    )
    (defun DALOS|C_UpdateEliteAccount (patron:string account:string)
        @doc "Manualy Updates the Demiourgos Elite Account for one Ouronet Account in case of emergency. \
        \ Can be used without account ownership by anyone."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (ea-id:string (ref-DALOS::UR_EliteAurynID))
                )
                (ref-ELITE::XE_UpdateEliteSingle ea-id account)
                (ref-IGNIS::C_Collect patron
                    (ref-IGNIS::DALOS|URCi_UpdateEliteAccount patron)
                )
                (format "Elite Account Data for {} updated succesfully!" [account])
            )
        )
    )
    (defun DALOS|C_UpdateEliteAccountSquared (patron:string sender:string receiver:string)
        @doc "Manualy Updates the Demiourgos Elite Account for two Ouronet Accounts in case of emergency. \
        \ Can be used without account ownership by anyone."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (ea-id:string (ref-DALOS::UR_EliteAurynID))
                )
                (ref-ELITE::XE_UpdateElite ea-id sender receiver)
                (ref-IGNIS::C_Collect patron
                    (ref-IGNIS::DALOS|URCi_UpdateEliteAccountSquared patron)
                )
                (format "Elite Account Data for {} and {} updated succesfully!" [sender receiver])
            )
        )
    )
    ;;  [DPTF_Client]
    (defun DPTF|C_UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPTF Token <entity-id> costing 100 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-B|DPTF:module{BrandingUsagePrimaryV2} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-B|DPTF::C_UpdatePendingBranding entity-id logo description website social)
                )
                (format "Pending Branding for DPTF {} updated succesfully" [entity-id])
            )
        )
    )
    (defun DPTF|C_UpgradeBranding (patron:string entity-id:string months:integer)
        @doc "Upgrades Branding for DPTF Token, making it a premium BrandingV2. \
            \ Also sets pending-branding to live branding if its branding is not live yet"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|DPTF:module{BrandingUsagePrimaryV2} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|DPTF::C_UpgradeBranding patron entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "DPTF {} succesfully upgraded for {} months(s)!" [entity-id months])
            )
        )
    )
    ;;
    (defun DPTF|C_Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-change-owner:[bool] can-upgrade:[bool] can-add-special-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @doc "Issues a new DPTF Token in Bulk, can also be used to issue a single DPTF \
        \ Outputs a string list with the issed DPTF IDs"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Issue patron account name ticker decimals can-change-owner can-upgrade can-add-special-role can-freeze can-wipe can-pause)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun DPTF|C_RotateOwnership (patron:string id:string new-owner:string)
        @doc "Rotates DPTF ID Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount new-owner))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_RotateOwnership id new-owner)
                )
                (format "ID {} Ownership succesfully set to {}" [id sa])
            )
        )
    )
    (defun DPTF|C_Control (patron:string id:string cu:bool cco:bool casr:bool cf:bool cw:bool cp:bool)
        @doc "Controls the properties of a DPTF Token \
            \ <can-change-owner> <can-upgrade> <can-add-special-role> <can-freeze> <can-wipe> <can-pause>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_Control id cu cco casr cf cw cp)
                )
                (format "Succesfully controlled Properties of {}" [id])
            )
        )
    )
    (defun DPTF|C_TogglePause (patron:string id:string toggle:bool)
        @doc "Toggles Pause for a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_TogglePause id toggle)
                )
                (if toggle
                    (format "ID {} succesfully pauses" [id])
                    (format "ID {} succesfully unpauses" [id])
                )
            )
        )
    )
    (defun DPTF|C_ToggleReservation (patron:string id:string toggle:bool)
        @doc "Toggles Reservations for a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleReservation id toggle)
                )
                (if toggle
                    (format "Reservations succesfully opened for {}" [id])
                    (format "Reservations succesfully closed for {}" [id])
                )
            )
        )
    )
    ;;
    (defun DPTF|C_ToggleFee (patron:string id:string toggle:bool)
        @doc "Toggles Fee collection for a DPTF Token. When a DPTF Token is setup with a transfer fee, \
            \ it will come in effect only when the toggle is on(true)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleFee id toggle)
                )
                (if toggle
                    (format "Fee Collection activated succesfully for {}" [id])
                    (format "Fee Collection deactivated succesfully for {}" [id])
                )
            )
        )
    )
    (defun DPTF|C_SetMinMove (patron:string id:string min-move-value:decimal)
        @doc "Sets the minimum amount needed to transfer a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_SetMinMove id min-move-value)
                )
                (format "MinMove Value succesfully set for {} to {}" [id min-move-value])
            )
        )
    )
    (defun DPTF|C_SetFee (patron:string id:string fee:decimal)
        @doc "Sets a transfer fee for the DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_SetFee id fee)
                )
                (format "Fee Promille succesfully set to {} Promille for {}" [fee id])
            )
        )
    )
    (defun DPTF|C_SetFeeTarget (patron:string id:string target:string)
        @doc "Sets the Fee Collection Target for a DPTF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount target))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_SetFeeTarget id target)
                )
                (format "Fee Target succesfully set for {} to {}" [id sa])
            )
        )
    )
    (defun DPTF|C_DonateFees (patron:string id:string)
        @doc "Sets the Fee Collection target to the DALOS|SC_NAME \
        \ When DPTF Fees collect here, the will be earned by Ouronet Custodians"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|DALOS|SC_NAME)))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_SetFeeTarget id (ref-DALOS::GOV|DALOS|SC_NAME))
                )
                (format "Fee Collection succesfully set to {}" [sa])
            )
        )
    )
    (defun DPTF|C_ResetFeeTarget (patron:string id:string)
        @doc "Sets the Fee Collection target to the OUROBOROS|SC_NAME \
        \ Fees can then be collected by <DPTF|C_WithdrawFees>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount (ref-DALOS::GOV|OUROBOROS|SC_NAME)))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_SetFeeTarget id (ref-DALOS::GOV|OUROBOROS|SC_NAME))
                )
                (format "Fee Collection succesfully set to {}" [sa])
            )
        )
    )
    (defun DPTF|C_ToggleFeeLock (patron:string id:string toggle:bool)
        @doc "Toggles DPTF Fee Settings Lock"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_ToggleFeeLock patron id toggle)
                    )
                    (collect:bool (at 0 (at "output" ico)))
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XE_ConditionalFuelSTOA collect)
                (if toggle
                    (format "Fee Settings succesfully locked for {}" [id])
                    (format "Fee Settings succesfully unlocked  for {}" [id])
                )
            )
        )
    )
    ;;
    (defun DPTF|C_DeployAccount (patron:string id:string account:string)
        @doc "Deploys a DPTF Account. Self-service activation only - the caller must own \
            \ <account> (DALOS|CAP_EnforceAccountOwnership). System/infrastructure account \
            \ setup (a smart account governed by another module) must use the admin variant \
            \ DPTF|A_DeployAccount in TS01-A instead."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DALOS::CAP_EnforceAccountOwnership account)
                (ref-DPTF::C_DeployAccount id account)
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::URCi_DeployAccount account)
                )
                (format "DPTF {} added to {} Ouronet Account succesfully!" [id sa])
            )
        )
    )
    (defun DPTF|C_ToggleFreezeAccount (patron:string id:string account:string toggle:bool)
        @doc "Toggles Freezing of a DPTF Account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleFreezeAccount id account toggle)
                )
                (if toggle
                    (format "Account {} succesfully frozen for {}" [sa id])
                    (format "Account {} succesfuly unfrozen for {}" [sa id])
                )
            )
        )
    )
    (defun DPTF|C_ToggleBurnRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <burn-role> for a DPTF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleBurnRole id account toggle)
                )
            )
        )
    )
    (defun DPTF|C_ToggleMintRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <mint-role> for a DPTF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleMintRole id account toggle)
                )
            )
        )
    )
    (defun DPTF|C_ToggleFeeExemptionRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <fee-exemption-role> for a DPTF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleFeeExemptionRole id account toggle)
                )
            )
        )
    )
    (defun DPTF|C_ToggleTransferRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <transfer-role> for a DPTF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_ToggleTransferRole id account toggle)
                )
                (if toggle
                    (format "Transfer Role succesfuly added for {} to {}" [id sa])
                    (format "Transfer Role succesfuly removed for {} to {}" [id sa])
                )
            )
        )
    )
    ;;
    (defun DPTF|C_ClearDispo (patron:string account:string)
        @doc "Clears OURO Dispo by levereging existing Elite-Auryn"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_ClearDispo account)
                )
            )
        )
    )
    (defun DPTF|C_Burn (patron:string id:string account:string amount:decimal)
        @doc "Burns a DPTF Token from an account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_Burn id account amount)
                )
                (format "Succesfully burned {} {} on Account {}" [amount id sa])
            )
        )
    )
    (defun DPTF|C_Mint (patron:string id:string account:string amount:decimal origin:bool)
        @doc "Mints a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_Mint id account amount origin)
                )
                (if origin
                    (format "Succesfully premined {} {} on Account {}" [amount id sa])
                    (format "Succesfully minted {} {} on Account {}" [amount id sa])
                )
            )
        )
    )
    (defun DPTF|C_WipeSlim (patron:string id:string atbw:string amtbw:decimal)
        @doc "Similar to <DPTF|C_Wipe>, but doesnt wipe the whole existing amount"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount atbw))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_WipeSlim id atbw amtbw)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id atbw)
                (format "Succesfully wiped {} {} from account {}" [amtbw id sa])
            )
        )
    )
    (defun DPTF|C_Wipe (patron:string id:string atbw:string)
        @doc "Wipes a DPTF Token from a given account in its entirety \
        \ Only works for positive existing amounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount atbw))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPTF::C_Wipe id atbw)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id atbw)
                (format "Succesfully wiped all {} from account {}" [id sa])
            )
        )
    )
    ;;
    (defun DPTF|C_Transmute (patron:string id:string transmuter:string transmute-amount:decimal)
        @doc "Transmutes a DPTF Token. Transmuting Uses the whole amount as it if were Primary Fee \
        \ without adding to the Primary Fee Counter. \
        \ Thus it can either be collected to the Fee Target Collector \
        \ or to increase Autostake Indices, if the Id is part of any Autostake Pools \
        \ (and these have the neccesary setting set up in the  required manner) \
        \ Only works for DPTFs that have been setup up with transfer fees. \
        \ One of 3 Variants is automatically chosen for transmutation \
        \   Simple  >> For DPTFs that are not Elite Auryn Class \
        \   Elite   >> For Elite Auryn Class DPTFs that require Elite Account Update"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_Transmute id transmuter transmute-amount)
                )
            )
        )
    )
    (defun DPTF|C_Transfer (patron:string id:string sender:string receiver:string transfer-amount:decimal method:bool)
        @doc "Transfers a DPTF Token from <sender> to <receiver>, using the <transfer-amount> and <method> \
        \ It autonomously choose between the 6 Transfer Variants spread over 3 Classes. \
        \ \
        \   Class 1 >> 1 IGNIS Cost \
        \           [CX_Class1Transfer]             Transfers a DPTF with no transfer Fees (also for VTT amounts < 10.0) \
        \           [CX_Class1TransferUnity]        Transfers UNITY with no transfer Fees (amount < 10.0) \
        \   Class 2 >> 2 IGNIS Cost \
        \           [CX_Class2Transfer]             Transfer a DPTF with a transfer Fee \
        \           [CX_Class2TransferUnity]        Transfers Unity with transfer Fee \
        \           [CX_Class2TransferElite]        Transfers EA Class DPTFs with no Fees \
        \   Class 3 >> 3 IGNIS Cost \
        \           [CX_Class3TransferElite]        Transfers EA Class DPTFs with transfer Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (receiver-amount:decimal (ref-TFT::URC_ReceiverAmount id sender receiver transfer-amount))
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_Transfer id sender receiver transfer-amount method)
                )
                (if (= receiver-amount transfer-amount)
                    (format "Succesfully transfered {} {} from {} to {}, moving the Full Amount to the Receiver" [transfer-amount id sa-s sa-r])
                    (format "Succesfully transfered {} {} from {} to {}, moving only {} to the Receiver due to DPTF Fee Settings" [transfer-amount id sa-s sa-r receiver-amount])
                )
            )
        )
    )
    (defun DPTF|C_MultiTransfer (patron:string id-lst:[string] sender:string receiver:string transfer-amount-lst:[decimal] method:bool)
        @doc "Transfers Multiple DPTF Tokens from one sender to another, each token having its own amount specified \
        \ Receiver, as it is only one, can also be a Smart Ouronet Account \
        \ 150k Gas can support between 10 and 20 Transfers, depending on DPTF Token (Simple, Complex, Elite, Unity)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (sa-r:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_MultiTransfer id-lst sender receiver transfer-amount-lst method)
                )
                (format "Succesfully multi-transfered {} DPTFs from {} to {}" [(length id-lst) sa-s sa-r])
            )
        )
    )
    (defun DPTF|C_BulkTransfer (patron:string id:string sender:string receiver-lst:[string] transfer-amount-lst:[decimal])
        @doc "Transfers a DPTF in Bulk, from 1 sender to multiple receivers, each with its own amount \
        \ Because <receivers> cannot be Smart Ouronet Accounts, no <method> parameter is needed \
        \ When the Token <id> is set up with a Transfer Fee, and its receiver is on the receiver list, \
        \ it is not exempted from the transfer fee, as is normally the case \
        \ \
        \ It autonomously choose between the 6 Transfer Variants spread over 4 Classes. \
        \ \
        \   Class 0 >> VTT (Volumetric Transfer Tax) Class: (1xL IGNIS or Variable IGNIS Cost for UNITY)\
        \           [CX_Class0BulkTransfer]         Bulk Transfers DPTFs with VTT \
        \           [CX_Class0BulkTransferUnity]    Bulk Transfers UNITY, which also has VTT \
        \   Class 1 >> 1xL IGNIS Cost \
        \           [CX_Class1BulkTransfer]         Bulk Transfers DPTFs with no transfer Fees \
        \   Class 2 >> 2xL IGNIS Cost \
        \           [CX_Class2BulkTransfer]         Bulk Transfers DPTFs with transfer Fees \
        \           [CX_Class2BulkTransferElite]    Bulk Transfers Elite Auryn Class DPTFs with no Transfer Fees \
        \   Class 3 >> 3xL IGNIS Cost \
        \           [CX_Class3BulkTransferElite]    Bulk Transfers Elite Auryn Class DPTFs with Transfer Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_MultiBulkTransfer [id] sender [receiver-lst] [transfer-amount-lst])
                )
                (format "Succesfully bulk-transfered {} DPTF from {} to {} Receivers" [id sa-s (length receiver-lst)])
            )
        )
    )
    (defun DPTF|C_MultiBulkTransfer (patron:string id:[string] sender:string receiver-array:[[string]] transfer-amount-array:[[decimal]])
        @doc "Executes Multiple Bulk Transfers in a single Function"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-TFT::C_MultiBulkTransfer id sender receiver-array transfer-amount-array)
                )
                (format "Succesfully multi-bulk-transfered {} DPTFs from Sender {} to {} Individual Receiver Lists" [(length id) sa-s (length receiver-array)])
            )
        )
    )
    ;;  [DPOF_Client]
    (defun DPOF|C_UpdatePendingBranding (patron:string entity-id:string logo:string description:string website:string social:[object{BrandingV2.SocialSchema}])
        @doc "Updates <pending-branding> for DPOF Token <entity-id> costing 150 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-B|DPOF::C_UpdatePendingBranding entity-id logo description website social)
                )
                (format "Pending Branding for DPOF {} updated succesfully" [entity-id])
            )
        )
    )
    (defun DPOF|C_UpgradeBranding (patron:string entity-id:string months:integer)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|DPOF:module{BrandingUsagePrimaryV2} DPOF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|DPOF::C_UpgradeBranding patron entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "DPOF {} succesfully upgraded for {} months(s)!" [entity-id months])
            )
        )
    )
    ;;
    (defun DPOF|C_Issue:list (patron:string account:string name:[string] ticker:[string] decimals:[integer] can-upgrade:[bool] can-change-owner:[bool] can-add-special-role:[bool] can-transfer-oft-create-role:[bool] can-freeze:[bool] can-wipe:[bool] can-pause:[bool])
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPOF::C_Issue patron account name ticker decimals can-upgrade can-change-owner can-add-special-role can-transfer-oft-create-role can-freeze can-wipe can-pause)
                    )
                )
                (ref-IGNIS::C_Collect patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun DPOF|C_RotateOwnership (patron:string id:string new-owner:string)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_RotateOwnership id new-owner)
                )
            )
        )
    )
    (defun DPOF|C_Control (patron:string id:string cu:bool cco:bool casr:bool ctocr:bool cf:bool cw:bool cp:bool sg:bool)
        @doc "Similar to its DPTF Variant, has an extra boolean trigger for <can-transfer-nft-create-role>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_Control id cu cco casr ctocr cf cw cp sg)
                )
                (format "Succesfully controlled DPOF {} Boolean Properties" [id])
            )
        )
    )
    (defun DPOF|C_TogglePause (patron:string id:string toggle:bool)
        ;;#35M fix: removed a dead ref-TS01-A binding (copy-paste leftover, never used) and
        ;;added the CLAUDE.md-mandated format result string, mirroring the correct DPTF sibling.
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_TogglePause id toggle)
                )
                (if toggle
                    (format "ID {} succesfully pauses" [id])
                    (format "ID {} succesfully unpauses" [id])
                )
            )
        )
    )
    ;;
    (defun DPOF|C_DeployAccount (patron:string id:string account:string)
        @doc "Similar to its DPTF Variant. Self-service activation only - the caller must \
            \ own <account> (DALOS|CAP_EnforceAccountOwnership). System/infrastructure \
            \ account setup (a smart account governed by another module) must use the \
            \ admin variant DPOF|A_DeployAccount in TS01-A instead."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-DALOS::CAP_EnforceAccountOwnership account)
                (ref-DPOF::C_DeployAccount id account)
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::URCi_DeployAccount account)
                )
                (format "Succesfully deployed a New DPOF Account for DPOF {} on Ouronet Account {}" [id sa])
            )
        )
    )
    (defun DPOF|C_ToggleFreezeAccount (patron:string id:string account:string toggle:bool)
        ;;#35M fix: removed a dead ref-TS01-A binding (copy-paste leftover, never used) and
        ;;added the CLAUDE.md-mandated format result string, mirroring the correct DPTF sibling.
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_ToggleFreezeAccount id account toggle)
                )
                (if toggle
                    (format "Account {} succesfully frozen for {}" [sa id])
                    (format "Account {} succesfuly unfrozen for {}" [sa id])
                )
            )
        )
    )
    (defun DPOF|C_ToggleAddQuantityRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <add-quantity-role> for a DPOF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_ToggleAddQuantityRole id account toggle)
                )
            )
        )
    )
    (defun DPOF|C_ToggleBurnRole (patron:string id:string account:string toggle:bool)
        @doc "Toggles <burn-role> for a DPOF Token <id> on a specific <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_ToggleBurnRole id account toggle)
                )
            )
        )
    )
    (defun DPOF|C_MoveCreateRole (patron:string id:string receiver:string)
        @doc "Moves <create-role> for a DPOF Token <id> to <receiver> \
        \ Only a single account may have this role"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_MoveCreateRole id receiver)
                )
            )
        )
    )
    (defun DPOF|C_ToggleTransferRole (patron:string id:string account:string toggle:bool)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_ToggleTransferRole id account toggle)
                )
            )
        )
    )
    ;;
    (defun DPOF|C_AddQuantity (patron:string id:string account:string nonce:integer amount:decimal)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_AddQuantity id account nonce amount)
                )
                (format "Succesfully increased DPOF {} nonce {} quantity on Account {} by {}" [id nonce sa amount])
            )
        )
    )
    (defun DPOF|C_Burn (patron:string id:string account:string nonce:integer amount:decimal)
        @doc "Similar to its DPTF Variant"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_Burn id account nonce amount)
                )
                (format "Succesfully burned {} Units of DPOF {} Nonce {} on Account {}" [amount id nonce sa])
            )
        )
    )
    (defun DPOF|C_Mint (patron:string id:string account:string amount:decimal meta-data-chain:[object])
        @doc "Mints a DPOF Token, creating it and adding quantity to it \
        \ Outputs the nonce of the created DPOF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (with-capability (P|TS)
                            (ref-DPOF::C_Mint id account amount meta-data-chain)
                        )
                    )
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                (ref-IGNIS::C_Collect patron ico)
                (format "Succesfully minted {} {} on Account {}, on the new Nonce {}" [amount id sa (at 0 (at "output" ico))])
            )
        )
    )
    (defun DPOF|C_WipeSlim (patron:string id:string account:string nonce:integer amount:decimal)
        @doc "Wipes a specific DPOF <id> <nonce> on <account> by <amount> \
            \ Amount may be lower or equal to the nonce amount. \
            \ Requires <id> has <segmentation> set to true"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_WipeSlim id account nonce amount)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    (defun DPOF|CC_WipeHeavy (patron:string id:string account:string)
        @doc "Wipes all viable <id> Nonces of an DPOF <account> \
            \ \
            \ |Heavy| reffers to the usage of expensive functions like <select> or <keys> \
            \ (that arent meant to be used in transactional context) to get the Account Nonces; \
            \ May fit in a single Transaction for Small Data Sets"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::CC_WipeHeavy id account)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    (defun DPOF|C_WipePure (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Wipes all <id> Nonces of an DPOF <account>, presented via an <removable-nonces-obj> object \
        \ \
        \ The object must be pre-read (dirty read) \
        \ \
        \ Example to retrieve the <removable-nonces-obj> \
        \ <(URHC_WipePure account id)> ; to get the whole object \
        \ <(UCv_TakePureWipe (URHC_WipePure account id) 165)> ; to get only the first 165 units \
        \ Aproximately xx Individual Wipes fit inside one TX (for NFTs)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_WipePure id account removable-nonces-obj)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    (defun DPOF|C_WipeClean (patron:string id:string account:string nonces:[integer])
        @doc "Wipes <id> select <nonces> of a DPOF <account>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_WipeClean id account nonces)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    (defun DPOF|Cp_WipeSlice (patron:string id:string account:string removable-nonces-obj:object{DpofUdcV2.RemovableNonces})
        @doc "Hydra parallel wipe slice: wipes ONE <URHC_BuildWipeSlicePlan> slice of <account>'s \
            \ <id> nonces. The UI dirty-reads the plan and fires one such tx per slice, all in \
            \ parallel; slices are disjoint, order-independent and retryable (replay REVERTS). \
            \ Elite re-rank runs per slice — it recomputes from live state, so whichever slice \
            \ lands last leaves the correct final rank under any arrival order."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::Cp_WipeSlice id account removable-nonces-obj)
                )
                ;;Update Elite Account
                (ref-ELITE::XE_UpdateEliteSingle id account)
            )
        )
    )
    ;;
    (defun DPOF|C_Transmit (patron:string id:string nonces:[integer] amounts:[decimal] sender:string receiver:string method:bool)
        @doc "Transfer DPOF <id> <nonces> from <sender> to <receiver> by a specific <amount> \
            \ This debits the <sender> nonces by <amount> and creates new nonces on receiver of <amount> \
            \ Requires <segmentation> set to <true> \
            \ Using an <amount> equal to the nonce supply, will take nonce out of the circulation"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    ;;
                    (ss:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_Transmit id nonces amounts sender receiver method)
                )
                (ref-ELITE::XE_UpdateElite id sender receiver)
                (format "Succesfuly Transmited DPOF {} Nonces {} with Amounts {} from Sender {} to Receiver {}"
                    [id nonces amounts ss sr]
                )
            )
        )
    )
    (defun DPOF|C_Transfer (patron:string id:string nonces:[integer] sender:string receiver:string method:bool)
        @doc "Transfer DPOF <id> <nonces> from <sender> to <receiver> by changing their Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    ;;
                    (ss:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount receiver))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_Transfer id nonces sender receiver method)
                )
                (ref-ELITE::XE_UpdateElite id sender receiver)
                (format "Succesfuly Transmited DPOF {} Nonces {} from Sender {} to Receiver {}"
                    [id nonces ss sr]
                )
            )
        )
    )
    (defun DPOF|C_BulkTransfer
        (patron:string id:string nonces-array:[[integer]] sender:string receiver-lst:[string] method:bool)
        @doc "Bulk whole-nonce DPOF transfer — one sender, many standard-account receivers (TalosStageOne_ClientOneV2)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-ELITE:module{EliteV2} ELITE)
                    ;;
                    (sa-s:string (ref-I|OURONET::OI|UC_ShortAccount sender))
                    (l:integer (length receiver-lst))
                )
                (ref-IGNIS::C_Collect patron
                    (ref-DPOF::C_BulkTransfer id nonces-array sender receiver-lst method)
                )
                (map
                    (lambda (idx:integer)
                        (ref-ELITE::XE_UpdateElite id sender (at idx receiver-lst))
                    )
                    (enumerate 0 (- l 1))
                )
                (format "Succesfully bulk-transferred DPOF {} from {} to {} receivers"
                    [id sa-s l]
                )
            )
        )
    )

)

;; --- tables for 02_TS01-C1.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)


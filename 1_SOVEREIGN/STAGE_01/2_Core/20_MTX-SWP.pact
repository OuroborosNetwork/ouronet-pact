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
        @doc "This module's identity as an inter-module caller: the guard registered into other \
        \ modules' IMPs by <P|A_Define> is `(create-capability-guard (P|MTX-SWP|CALLER))`, so \
        \ `P|UEV_IMC` over there passes exactly when THIS is in scope over here. \
        \ \
        \ IT IS ACQUIRED DIRECTLY AT EVERY BILLING SITE IN THIS MODULE, and that is not \
        \ redundancy. The IGNIS collectors became `P|UEV_IMC`-protected on 2026-09-20. On the \
        \ ordinary path nothing has to do this: Talos acquires <P|TALOS-SUMMONER> at the top, \
        \ `P|UEV_IMC` is depth-invariant, and every nested core call inherits it. A DEFPACT \
        \ STEP INHERITS NOTHING -- it arrives in its own transaction through <continue-pact> \
        \ with an empty capability scope -- and this module is almost entirely defpacts that \
        \ bill. Hence the explicit acquire, scoped to the collect call and nothing wider."
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
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|MTX-SWP_ADMIN)
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
        (with-capability (GOV|MTX-SWP_ADMIN)
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
        (with-capability (GOV|MTX-SWP_ADMIN)
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
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
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
            (ref-P|IGNIS::P|A_AddIMP mg)
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
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron (URCi_AddLiquidityInitiation))
                )
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
                    (with-capability (P|MTX-SWP|CALLER)
                        (ref-IGNIS::XE_CollectIgnis patron
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [(URCi_AddLiquidityChurnRemainder
                                    (UC_AddLiquidityChurnKey asymmetric-collection gaseous-collection))
                                 (at "perfect-ignis-fee" (at "clad-op" clad))]
                                []
                            )
                        )
                    )
                    (if (and asymmetric-collection gaseous-collection)
                        (with-capability (MTX-SWP|C>ADD-STANDARD-LQ swpair ld)
                            ;;<asymmetric-collection=true> <gaseous-collection=true>
                            (ref-SWPL::XE_STOA-PID|AddLiquidity 
                                patron account swpair asymmetric-collection gaseous-collection stoa-pid ld clad
                            )
                        )
                        (if gaseous-collection
                            (with-capability (MTX-SWP|C>ADD-ICED-LQ swpair ld)
                                ;;<asymmetric-collection=false> <gaseous-collection=true>
                                (ref-SWPL::XE_STOA-PID|AddLiquidity 
                                    patron account swpair asymmetric-collection gaseous-collection stoa-pid ld clad
                                )
                            )
                            (with-capability (MTX-SWP|C>ADD-GLACIAL-LQ swpair ld)
                                ;;<asymmetric-collection=false> <gaseous-collection=false>
                                (ref-SWPL::XE_STOA-PID|AddLiquidity 
                                    patron account swpair asymmetric-collection gaseous-collection stoa-pid ld clad
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
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron 
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                        )
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
                                    (ref-VST::C_Freeze patron SWP|SC_NAME account lp-id secondary)
                                    EOC
                                )
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Collect Last Gas
                        (with-capability (P|MTX-SWP|CALLER)
                            (ref-IGNIS::XE_CollectIgnis patron 
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                    [ico1 ico2] 
                                    []
                                ) 
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
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron (URCi_AddLiquidityInitiation))
                )
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
                                    (ref-DPTF::C_Burn patron vst-sc frozen-dptf input-amount)
                                )
                                (ico3:object{IgnisCollectorV3.OutputCumulator}
                                    (at "perfect-ignis-fee" (at "clad-op" clad))
                                )
                            )
                            ;;lp-churn REMAINDER taken here, after validation -- see the twin
                            ;;comment in MTX|C_AddLiquidity's execution step.
                            (with-capability (P|MTX-SWP|CALLER)
                                (ref-IGNIS::XE_CollectIgnis patron 
                                    (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                        [(URCi_AddLiquidityChurnRemainder "SWP|C_AddFrozenLiquidity")
                                         ico1 ico2 ico3] []
                                    )
                                )
                            )
                            (ref-SWPL::XE_STOA-PID|AddLiquidity patron vst-sc swpair false false stoa-pid ld clad)
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
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron 
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                        )
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
                                (ref-VST::C_Freeze patron SWP|SC_NAME account lp-id secondary)
                            )
                        )
                        ;;Autonomous Swap Mangement
                        (ref-SWPL::XE_AutonomousSwapManagement swpair)
                        ;;Collect Last Gas
                        (with-capability (P|MTX-SWP|CALLER)
                            (ref-IGNIS::XE_CollectIgnis patron ico)
                        )
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
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron (URCi_AddLiquidityInitiation))
                )
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
                            (with-capability (P|MTX-SWP|CALLER)
                                (ref-IGNIS::XE_CollectIgnis patron 
                                    (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                        [(URCi_AddLiquidityChurnRemainder "SWP|C_AddSleepingLiquidity")
                                         ico1 ico2 ico3 ico4] []
                                    )
                                )
                            )
                            (ref-SWPL::XE_STOA-PID|AddLiquidity patron vst-sc swpair true true stoa-pid ld clad)
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
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron 
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            LQ|INITIATION-FEE SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                        )
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
                        (with-capability (P|MTX-SWP|CALLER)
                            (ref-IGNIS::XE_CollectIgnis patron ico)
                        )
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
                ;;Collect IGNIS and STOA for Issuance.
                ;;
                ;;THE <with-capability> IS LORD-BEARING, NOT DECORATION. The IGNIS collectors
                ;;became `P|UEV_IMC`-protected on 2026-09-20, and that gate passes only when one
                ;;of IGNIS' registered capability guards is IN SCOPE. For the ordinary path that
                ;;is automatic -- Talos acquires <P|TALOS-SUMMONER> at the top and `P|UEV_IMC` is
                ;;depth-invariant, so every nested core call inherits it. A DEFPACT STEP INHERITS
                ;;NOTHING: step 2 arrives in its own transaction via <continue-pact>, with an
                ;;empty capability scope, so the guard this module registered in IGNIS' IMP
                ;;(<P|MTX-SWP|CALLER>) has to be acquired here or billing dies with "None of the
                ;;guards passed". Step 3 already does the same thing for SWPI::XE_IssueWrite,
                ;;via <MTX-SWP|C>ISSUE> -> <P|DT> -> <P|MTX-SWP|CALLER>; this is that, scoped to
                ;;the two calls that need it rather than borrowing the governance composite.
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron (ref-SWPI::URCi_IssuePool account pool-tokens))
                    (ref-IGNIS::XE_CollectStoa patron stoa-costs)
                )
                (let
                    (
                        (ref-ORBR:module{OuroborosV2} OUROBOROS)
                        (auto-fuel:bool (ref-DALOS::UR_AutoFuel))
                    )
                    (if auto-fuel
                        (do
                            (with-capability (P|DT)
                                (ref-ORBR::C_Fuel patron)
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
                ;;Same reason as the step body above: the rollback runs in its own transaction
                ;;with an empty capability scope, and it bills.
                (with-capability (P|MTX-SWP|CALLER)
                    (ref-IGNIS::XE_CollectIgnis patron 
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            100.0 SWP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []
                        )
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
                        (write-result:list (ref-SWPI::XE_IssueWrite patron account pool-tokens fee-lp weights amp p))
                        (swpair:string (at 0 write-result))
                        (token-lp:string (at 1 write-result))
                    )
                    (format "Swpair with ID {} and LP Token {} ID created succesfully" [swpair token-lp])
                )
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)
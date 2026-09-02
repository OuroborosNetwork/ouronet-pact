;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
(interface SwapperMtxV3
    @doc "Exposes SWP MultiStep (via defpact) Functions. \
        \ V3: issue pool caps use SwapperV3.PoolTokens (bumped with SwapperV3 row types)."
    ;;
    ;;
    ;;  []C] Functions
    ;;
    ;;
    (defun C_IssueStablePool (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal amp:decimal p:bool))
    (defun C_IssueWeightedPool (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool))
    (defun C_IssueStandardPool (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal p:bool))
    ;;
    (defun C_AddStandardLiquidity (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_AddIcedLiquidity (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_AddGlacialLiquidity (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal))
    (defun C_AddFrozenLiquidity (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal))
    (defun C_AddSleepingLiquidity (patron:string account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal))
    ;;
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
    ;;
    (implements OuronetPolicyV1)
    (implements SwapperMtxV3)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_MTX-SWP        (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst SWP|SC_NAME           (GOV|SWP|SC_NAME))
    ;;{G2}
    (defcap GOV ()                  (compose-capability (GOV|MTX-SWP_ADMIN)))
    (defcap GOV|MTX-SWP_ADMIN ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
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
    ;;
    (defun GOV|SWP|SC_NAME ()       (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|SWP|SC_NAME)))
    ;;{G3}
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<====>
    ;;POLICY
    ;;{P1}
    ;;{P2}
    (deftable P|T:{OuronetPolicyV1.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV1.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P3}
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
    ;;{P4}
    (defconst P|I                   (P|Info))
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun A_P|Add (policy-name:string policy-guard:guard)
        (with-capability (GOV|MTX-SWP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun A_P|AddIMP (policy-guard:guard)
        (with-capability (GOV|MTX-SWP_ADMIN)
            (let
                (
                    (ref-U|LST:module{StringProcessorV1} U|LST)
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
    (defun A_P|Define ()
        (let
            (
                (ref-P|DALOS:module{OuronetPolicyV1} DALOS)
                (ref-P|BRD:module{OuronetPolicyV1} BRD)
                (ref-P|DPTF:module{OuronetPolicyV1} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV1} DPOF)
                (ref-P|TFT:module{OuronetPolicyV1} TFT)
                (ref-P|VST:module{OuronetPolicyV1} VST)
                (ref-P|ORBR:module{OuronetPolicyV1} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV1} SWPT)
                (ref-P|SWP:module{OuronetPolicyV1} SWP)
                (ref-P|SWPL:module{OuronetPolicyV1} SWPL)
                ;;#36M/M5 fix: MTX-SWP now calls SWPI::XE_IssueWrite (UEV_IMC-gated)
                ;;directly from C_MTX|Issue's Step 3, so MTX-SWP must register itself
                ;;as an approved IMC caller on SWPI too — same as every other module
                ;;it already calls into below.
                (ref-P|SWPI:module{OuronetPolicyV1} SWPI)
                (mg:guard (create-capability-guard (P|MTX-SWP|CALLER)))
            )
            (ref-P|VST::A_P|Add
                "MTX-SWP|RemoteSwpGov"
                (create-capability-guard (P|MTX-SWP|REMOTE-GOV))
            )
            (ref-P|SWP::A_P|Add
                "MTX-SWP|RemoteSwpGov"
                (create-capability-guard (P|MTX-SWP|REMOTE-GOV))
            )
            (ref-P|BRD::A_P|AddIMP mg)
            (ref-P|DPTF::A_P|AddIMP mg)
            (ref-P|DPOF::A_P|AddIMP mg)
            (ref-P|TFT::A_P|AddIMP mg)
            (ref-P|ORBR::A_P|AddIMP mg)
            (ref-P|VST::A_P|AddIMP mg)
            (ref-P|SWPT::A_P|AddIMP mg)
            (ref-P|SWP::A_P|AddIMP mg)
            (ref-P|SWPL::A_P|AddIMP mg)
            (ref-P|SWPI::A_P|AddIMP mg)
        )
    )
    (defun UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    ;;{1}
    ;;{2}
    ;;{3}
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    (defun CT_EmptyCumulator ()     (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS)) (ref-IGNIS::UDC_EmptyOutputCumulatorV2)))
    (defconst BAR                   (CT_Bar))
    (defconst EOC                   (CT_EmptyCumulator))
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
    ;;{C3}
    ;;{C4}
    (defcap MTX-SWP|C>ISSUE-S-POOL (pool-tokens:[object{SwapperV3.PoolTokens}])
        @event
        (compose-capability (SECURE))
    )
    (defcap MTX-SWP|C>ISSUE-W-POOL (pool-tokens:[object{SwapperV3.PoolTokens}])
        @event
        (compose-capability (SECURE))
    )
    (defcap MTX-SWP|C>ISSUE-P-POOL (pool-tokens:[object{SwapperV3.PoolTokens}])
        @event
        (compose-capability (SECURE))
    )
    (defcap MTX-SWP|C>ISSUE (p:bool)
        (compose-capability (P|DT))
        (if p
            (compose-capability (GOV|MTX-SWP_ADMIN))
            true
        )
    )
    ;;
    (defcap MTX-SWP|C>ADD-STANDARD-LQ (swpair:string ld:object{SwapperLiquidityV1.LiquidityData})
        @event
        (compose-capability (MTX-SWP|C>X-ADD-LQ swpair ld))
    )
    (defcap MTX-SWP|C>ADD-ICED-LQ (swpair:string ld:object{SwapperLiquidityV1.LiquidityData})
        @event
        (compose-capability (MTX-SWP|C-ADD-CHILLED-LQ swpair ld))
    )
    (defcap MTX-SWP|C>ADD-GLACIAL-LQ (swpair:string ld:object{SwapperLiquidityV1.LiquidityData})
        @event
        (compose-capability (MTX-SWP|C-ADD-CHILLED-LQ swpair ld))
    )
    (defcap MTX-SWP|C>ADD-FROZEN-LQ 
        (swpair:string frozen-dptf:string ld:object{SwapperLiquidityV1.LiquidityData})
        @event
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC) 
            )
            (ref-SWPLC::UEV_AddFrozenLiquidity swpair frozen-dptf)
            (compose-capability (MTX-SWP|C-ADD-CHILLED-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C>ADD-SLEEPING-LQ 
        (account:string swpair:string sleeping-dpof:string nonce:integer ld:object{SwapperLiquidityV1.LiquidityData})
        @event
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
            )
            (ref-SWPLC::UEV_AddSleepingLiquidity account swpair sleeping-dpof nonce)
            (compose-capability (MTX-SWP|C-ADD-DORMANT-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C-ADD-DORMANT-LQ (swpair:string ld:object{SwapperLiquidityV1.LiquidityData})
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
            )
            (ref-SWPLC::UEV_AddDormantLiquidity swpair)
            (compose-capability (MTX-SWP|C>X-ADD-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C-ADD-CHILLED-LQ (swpair:string ld:object{SwapperLiquidityV1.LiquidityData})
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC) 
            )
            (ref-SWPLC::UEV_AddChilledLiquidity swpair ld)
            (compose-capability (MTX-SWP|C>X-ADD-LQ swpair ld))
        )
    )
    (defcap MTX-SWP|C>X-ADD-LQ (swpair:string ld:object{SwapperLiquidityV1.LiquidityData})
        (let
            (
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC) 
            )
            (ref-SWPLC::UEV_AddLiquidity swpair ld)
            (compose-capability (P|DT))
        )
    )
    (defcap MTX-SWP|S>ADD-LQ (stoa-pid:decimal)
        @doc "Records the STOA-PID the MTX was initiated with"
        @event
        true
    )
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F1}  Construct [UDC]
    ;;{F2}  Compute [UC]
    ;;{F3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_PoolState:object{SwapperLiquidityV1.PoolState} (swpair:string)
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
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
    ;;{F4}  Validate [UEV/CAP]
    ;;{F5}  Write [W]
    ;;{F6}  Aux/Protected [X]
    ;;{F7}  User [A]
    ;;{F8}  User [C]
    ;;
    (defun C_IssueStablePool
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal amp:decimal p:bool)
        (UEV_IMC)
        (with-capability (MTX-SWP|C>ISSUE-S-POOL pool-tokens)
            (C_MTX|Issue
                patron account pool-tokens fee-lp
                (make-list (length pool-tokens) 1.0)
                amp p
            )
        )
    )
    (defun C_IssueWeightedPool
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool)
        (UEV_IMC)
        (with-capability (MTX-SWP|C>ISSUE-W-POOL pool-tokens)
            (C_MTX|Issue
                patron account pool-tokens fee-lp
                weights
                -1.0 p
            )
        )
    )
    (defun C_IssueStandardPool
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal p:bool)
        (UEV_IMC)
        (with-capability (MTX-SWP|C>ISSUE-P-POOL pool-tokens)
            (C_MTX|Issue
                patron account pool-tokens fee-lp
                (make-list (length pool-tokens) 1.0)
                -1.0 p
            )
        )
    )
    ;;
    (defun C_AddStandardLiquidity
        (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (C_MTX|AddLiquidity patron account swpair input-amounts true true stoa-pid)
        )
    )
    (defun C_AddIcedLiquidity
        (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (C_MTX|AddLiquidity patron account swpair input-amounts false true stoa-pid)
        )
    )
    (defun C_AddGlacialLiquidity
        (patron:string account:string swpair:string input-amounts:[decimal] stoa-pid:decimal)
        (UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (C_MTX|AddLiquidity patron account swpair input-amounts false false stoa-pid)
        )
    )
    (defun C_AddFrozenLiquidity
        (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        (UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (C_MTX|AddFrozenLiquidity patron account swpair frozen-dptf input-amount stoa-pid)
        )
    )
    (defun C_AddSleepingLiquidity
        (patron:string account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        (UEV_IMC)
        (with-capability (MTX-SWP|S>ADD-LQ stoa-pid)
            (C_MTX|AddSleepingLiquidity patron account swpair sleeping-dpof nonce stoa-pid)
        )
    )
    (defpact C_MTX|AddLiquidity 
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
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                    ;;
                    (pool-state:object{SwapperLiquidityV1.PoolState}
                        (UR_PoolState swpair)
                    )
                    (ld:object{SwapperLiquidityV1.LiquidityData}
                        (ref-SWPL::URC_LD swpair input-amounts)
                    )
                    (clad:object{SwapperLiquidityV1.CompleteLiquidityAdditionData}
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
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator 100.0 SWP|SC_NAME false [])
                )
                (format "MTX LqAdd. computed succesfully and collected {} IGNIS before discounts; 1|3" [100.0])
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
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                        ;;
                        (current-pool-state:object{SwapperLiquidityV1.PoolState} (UR_PoolState swpair))
                        (primary:decimal (at "primary-lp" clad))
                        (secondary:decimal (at "secondary-lp" clad))
                        (sum-lp:decimal (+ primary secondary))
                    )
                    (enforce 
                        (= prev-pool-state current-pool-state) 
                        "Execution Step of Adding Liquidity cannot execute on altered pool state!"
                    )
                    (ref-IGNIS::C_Collect patron 
                        (at "perfect-ignis-fee" (at "clad-op" clad))
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
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                )
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator 100.0 SWP|SC_NAME false [])
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
                            (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                            (ref-TFT:module{TrueFungibleTransferV1} TFT)
                            (ref-VST:module{VestingV1} VST)
                            (ref-SWP:module{SwapperV3} SWP)
                            (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                            ;;
                            (lp-id:string (ref-SWP::UR_TokenLP swpair))
                            (ico1:object{IgnisCollectorV1.OutputCumulator}
                                (if (!= primary 0.0)
                                    (ref-TFT::C_Transfer lp-id SWP|SC_NAME account primary true)
                                    EOC
                                )
                            )
                            (ico2:object{IgnisCollectorV1.OutputCumulator}
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
    (defpact C_MTX|AddFrozenLiquidity
        (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal stoa-pid:decimal)
        ;;Adds Frozen Liquidity, as an MTX in 3 Steps
        ;;
        ;:Step 0, Computation and Validation
        (step
            (let
                (
                    (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                    ;;
                    (pool-state:object{SwapperLiquidityV1.PoolState}
                        (UR_PoolState swpair)
                    )
                    ;;
                    (dptf:string (ref-DPTF::UR_Frozen frozen-dptf))
                    (ptp:integer (ref-SWP::UR_PoolTokenPosition swpair dptf))
                    (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp input-amount))
                    (ld:object{SwapperLiquidityV1.LiquidityData}
                        (ref-SWPL::URC_LD swpair lq-lst)
                    )
                    (clad:object{SwapperLiquidityV1.CompleteLiquidityAdditionData}
                        (ref-SWPL::URC_STOA-PID|CLAD account swpair ld false false stoa-pid)
                    )
                )
                (require-capability (MTX-SWP|S>ADD-LQ stoa-pid))
                (yield
                    {"pool-state"   : pool-state
                    ,"ld"           : ld
                    ,"clad"         : clad}
                )
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator 100.0 SWP|SC_NAME false [])
                )
                (format "MTX Frozen LqAdd. computed succesfully and collected {} IGNIS before discounts; 1|3" [100.0])
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
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        ;;
                        (current-pool-state:object{SwapperLiquidityV1.PoolState} (UR_PoolState swpair))
                        (secondary:decimal (at "secondary-lp" clad))
                    )
                    (enforce 
                        (= prev-pool-state current-pool-state) 
                        "Execution Step of Adding Liquidity cannot execute on altered pool state!"
                    )
                    (with-capability (MTX-SWP|C>ADD-FROZEN-LQ swpair frozen-dptf ld)
                        (let
                            (
                                (ref-DALOS:module{OuronetDalosV1} DALOS)
                                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                                (vst-sc:string (ref-DALOS::GOV|VST|SC_NAME))
                                ;;
                                ;;Move F|DPTF to vst-sc and burn it
                                (ico1:object{IgnisCollectorV1.OutputCumulator}
                                    (ref-TFT::C_Transfer frozen-dptf account vst-sc input-amount true)
                                )
                                (ico2:object{IgnisCollectorV1.OutputCumulator}
                                    (ref-DPTF::C_Burn frozen-dptf vst-sc input-amount)
                                )
                                (ico3:object{IgnisCollectorV1.OutputCumulator}
                                    (at "perfect-ignis-fee" (at "clad-op" clad))
                                )
                            )
                            (ref-IGNIS::C_Collect patron 
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                    [ico1 ico2 ico3] []
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
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                )
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator 100.0 SWP|SC_NAME false [])
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
                            (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                            (ref-VST:module{VestingV1} VST)
                            (ref-SWP:module{SwapperV3} SWP)
                            (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                            ;;
                            (lp-id:string (ref-SWP::UR_TokenLP swpair))
                            (ico:object{IgnisCollectorV1.OutputCumulator}
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
    (defpact C_MTX|AddSleepingLiquidity
        (patron:string account:string swpair:string sleeping-dpof:string nonce:integer stoa-pid:decimal)
        ;;Adds Frozen Liquidity, as an MTX in 3 Steps
        ;;
        ;:Step 0, Computation and Validation
        (step
            (let
                (
                    (ref-U|SWP:module{UtilitySwpV1} U|SWP)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                    ;;
                    (pool-state:object{SwapperLiquidityV1.PoolState}
                        (UR_PoolState swpair)
                    )
                    ;;
                    (dptf:string (ref-DPOF::UR_Sleeping sleeping-dpof))
                    (ptp:integer (ref-SWP::UR_PoolTokenPosition swpair dptf))
                    (batch-amount:decimal (ref-DPOF::UR_NonceSupply sleeping-dpof nonce))
                    (lq-lst:[decimal] (ref-U|SWP::UC_MakeLiquidityList swpair ptp batch-amount))
                    (ld:object{SwapperLiquidityV1.LiquidityData}
                        (ref-SWPL::URC_LD swpair lq-lst)
                    )
                    (clad:object{SwapperLiquidityV1.CompleteLiquidityAdditionData}
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
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator 100.0 SWP|SC_NAME false [])
                )
                (format "MTX Sleeping LqAdd. computed succesfully and collected {} IGNIS before discounts; 1|3" [100.0])
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
                        (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                        ;;
                        (current-pool-state:object{SwapperLiquidityV1.PoolState} (UR_PoolState swpair))
                        (primary:decimal (at "primary-lp" clad))
                    )
                    (enforce 
                        (= prev-pool-state current-pool-state) 
                        "Execution Step of Adding Liquidity cannot execute on altered pool state!"
                    )
                    (with-capability (MTX-SWP|C>ADD-SLEEPING-LQ account swpair sleeping-dpof nonce ld)
                        (let
                            (
                                (ref-DALOS:module{OuronetDalosV1} DALOS)
                                (ref-DPOF:module{DemiourgosPactOrtoFungibleV1} DPOF)
                                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                                (ref-SWPL:module{SwapperLiquidityV1} SWPL)
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
                                (ico1:object{IgnisCollectorV1.OutputCumulator}
                                    (ref-DPOF::C_Transfer sleeping-dpof [nonce] account vst-sc true)
                                )
                                (ico2:object{IgnisCollectorV1.OutputCumulator}
                                    (ref-DPOF::C_Burn sleeping-dpof vst-sc nonce batch-amount)
                                )
                                (ico3:object{IgnisCollectorV1.OutputCumulator}
                                    (at "perfect-ignis-fee" (at "clad-op" clad))
                                )
                                ;;
                                ;;MOVE IGNIS to vst-sc, paying for the ignis-tax
                                (ico4:object{IgnisCollectorV1.OutputCumulator}
                                    (ref-TFT::C_Transfer ignis-id account vst-sc (at "total-ignis-tax-needed" clad) true)
                                )
                            )
                            (ref-IGNIS::C_Collect patron 
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                    [ico1 ico2 ico3 ico4] []
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
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                )
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator 100.0 SWP|SC_NAME false [])
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
                            (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                            (ref-VST:module{VestingV1} VST)
                            (ref-SWP:module{SwapperV3} SWP)
                            (ref-SWPL:module{SwapperLiquidityV1} SWPL)
                            ;;
                            (lp-id:string (ref-SWP::UR_TokenLP swpair))
                            (ico:object{IgnisCollectorV1.OutputCumulator}
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
    (defpact C_MTX|Issue
        (patron:string account:string pool-tokens:[object{SwapperV3.PoolTokens}] fee-lp:decimal weights:[decimal] amp:decimal p:bool)
        ;;Issues an SWPair, as MultiStep Transaction, to be used in case <C_Issue> cant fit inside one TX.
        ;;
        ;;Step 1 Validation
        (step
            (let
                (
                    (ref-SWPI:module{SwapperIssueV3} SWPI)
                )
                (require-capability (SECURE))
                (ref-SWPI::UEV_Issue account pool-tokens fee-lp weights amp p)
            )
        )
        ;;Step 2 Ignis Collection and STOA Fuel Processing
        (step-with-rollback
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                    (ref-SWP:module{SwapperV3} SWP)
                    (pool-token-ids:[string] (ref-SWP::UC_ExtractTokens pool-tokens))
                    (pool-token-amounts:[decimal] (ref-SWP::UC_ExtractTokenSupplies pool-tokens))
                    ;;
                    (sum-ignis:decimal 
                        (fold (+) 0.0 
                            [
                                (ref-DALOS::UR_UsagePrice "ignis|swp-issue")
                                (ref-DALOS::UR_UsagePrice "ignis|token-issue")
                                (ref-DALOS::UR_UsagePrice "ignis|biggest")
                                (ref-DALOS::UR_UsagePrice "ignis|smallest")
                            ]
                        )
                    )
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    ;;
                    (ico0:object{IgnisCollectorV1.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator sum-ignis SWP|SC_NAME trigger [])
                    )
                    (ico1:object{IgnisCollectorV1.OutputCumulator}
                        (ref-TFT::URCi_MultiTransferCumulator pool-token-ids account SWP|SC_NAME pool-token-amounts)
                    )
                    ;;
                    (stoa-costs:decimal 
                        (+ 
                            (ref-DALOS::UR_UsagePrice "dptf")
                            (ref-DALOS::UR_UsagePrice "swp")
                        )
                    )
                )
                ;;Collect IGNIS for Issuance
                (ref-IGNIS::C_Collect patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1] [])
                )
                ;;Collect STOA for Issuance
                (ref-IGNIS::C_STOA|Collect patron stoa-costs)
                (let
                    (
                        (ref-ORBR:module{OuroborosV1} OUROBOROS)
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
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                )
                (ref-IGNIS::C_Collect patron 
                    (ref-IGNIS::UDC_ConstructOutputCumulator 100.0 SWP|SC_NAME false [])
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
                        (ref-SWPI:module{SwapperIssueV3} SWPI)
                        (write-result:list (ref-SWPI::XE_IssueWrite account pool-tokens fee-lp weights amp p))
                        (swpair:string (at 0 write-result))
                        (token-lp:string (at 1 write-result))
                    )
                    (format "Swpair with ID {} and LP Token {} ID created succesfully" [swpair token-lp])
                )
            )
        )
    )
    ;;{F9}  REPL (test-only, stripped at mainnet) [REPL]
    ;;
)

(create-table P|T)
(create-table P|MT)
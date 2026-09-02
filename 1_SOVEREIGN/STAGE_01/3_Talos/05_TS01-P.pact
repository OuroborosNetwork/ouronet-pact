;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;; #39M/M14 fix: prior live ClientPactsV2 frozen here, alongside its sibling ClientThreeV2
;; (frozen in 04_TS01-C3.pact for the same reason) rather than the central registry — kept
;; together with its always-paired sibling rather than split across files.
;;
;; net: v3   ·   dev: v4   ;; bumped by the StoicSyntax refactor — deploy v4 then set net: v4
(interface TalosStageOne_ClientPactsV4
    @doc "Exposes Ouronet Stage One Client Multistep Functions \
        \ Currently including functions from SWP Module. \
        \ V3: pooled issue caps use SwapperV4.PoolTokens (interface bump per versioning rule)."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;{G5}  functions

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
    ;;Issue
    (defun C_SWP|IssueStablePool (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal amp:decimal p:bool))
    (defun C_SWP|IssueWeightedPool (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool))
    (defun C_SWP|IssueStandardPool (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal p:bool))
    ;;
    (defun C_SWP|AddStandardLiquidity (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun C_SWP|AddIcedLiquidity (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun C_SWP|AddGlacialLiquidity (patron:string account:string swpair:string input-amounts:[decimal]))
    (defun C_SWP|AddFrozenLiquidity (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal))
    (defun C_SWP|AddSleepingLiquidity (patron:string account:string swpair:string sleeping-dpof:string nonce:integer))

)
;;
(module TS01-CP GOV
    @doc "TALOS Administrator and Client Module for Stage 1"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_ClientPactsV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-CP        (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                  (compose-capability (GOV|TS01-CP_ADMIN)))
    (defcap GOV|TS01-CP_ADMIN ()    (enforce-guard GOV|MD_TS01-CP))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()         (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                   (P|Info))
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
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
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
        (with-capability (GOV|TS01-CP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        (with-capability (GOV|TS01-CP_ADMIN)
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
                (ref-P|MTX-SWP:module{OuronetPolicyV2} MTX-SWP)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|MTX-SWP::P|A_AddIMP mg)
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
    ;;  [SWP PactStarters]
    (defun C_SWP|IssueStablePool (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal amp:decimal p:bool)
        @doc "Similar outcome to <ref-TS01-C2::C_SWP|IssueStable>, but over 3 <steps> (0|1|2) via <defpact> \
            \ Calling this function runs the Step 0 of 2. To finalize SWPair creation, Steps 1 and 2 must also be executed \
            \ \
            \ Step 0: Data Validation, makes sure the input data is correct for SWPair Creation \
            \ Step 1: Collects IGNIS, STOA, and fuels LiquidStaking Index with collected STOA \
            \ Step 2: Executes the actual Pool Creation, Issuing the LP Token, Creating the SWPair, minting the LP Token Supply \
            \   transfering it to its creator, and saves all other relevant data when a Pool Creation takes place"
        (with-capability (P|TS)
            (let
                (
                    (ref-MTX-SWP:module{SwapperMtxV4} MTX-SWP)
                )
                (ref-MTX-SWP::C_IssueStablePool patron account pool-tokens fee-lp amp p)
            )
        )
    )
    (defun C_SWP|IssueWeightedPool (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal weights:[decimal] p:bool)
        @doc "Similar to <SWP|C_IssueStableMultiStep>, but issues a W (Weighted) Pool"
        (with-capability (P|TS)
            (let
                (
                    (ref-MTX-SWP:module{SwapperMtxV4} MTX-SWP)
                )
                (ref-MTX-SWP::C_IssueWeightedPool patron account pool-tokens fee-lp weights p)
            )
        )
    )
    (defun C_SWP|IssueStandardPool (patron:string account:string pool-tokens:[object{SwapperV4.PoolTokens}] fee-lp:decimal p:bool)
        @doc "Similar to <SWP|C_IssueStableMultiStep>, but issues a P (Standard) Pool"
        (with-capability (P|TS)
            (let
                (
                    (ref-MTX-SWP:module{SwapperMtxV4} MTX-SWP)
                )
                (ref-MTX-SWP::C_IssueStandardPool patron account pool-tokens fee-lp p)
            )
        )
    )
    ;;
    (defun C_SWP|AddStandardLiquidity
        (patron:string account:string swpair:string input-amounts:[decimal])
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ref-MTX-SWP:module{SwapperMtxV4} MTX-SWP)
                )
                (ref-MTX-SWP::C_AddStandardLiquidity 
                    patron account swpair input-amounts stoa-pid
                )
            )
        )
    )
    (defun C_SWP|AddIcedLiquidity
        (patron:string account:string swpair:string input-amounts:[decimal])
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ref-MTX-SWP:module{SwapperMtxV4} MTX-SWP)
                )
                (ref-MTX-SWP::C_AddIcedLiquidity 
                    patron account swpair input-amounts stoa-pid
                )
            )
        )
    )
    (defun C_SWP|AddGlacialLiquidity
        (patron:string account:string swpair:string input-amounts:[decimal])
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ref-MTX-SWP:module{SwapperMtxV4} MTX-SWP)
                )
                (ref-MTX-SWP::C_AddGlacialLiquidity 
                    patron account swpair input-amounts stoa-pid
                )
            )
        )
    )
    (defun C_SWP|AddFrozenLiquidity
        (patron:string account:string swpair:string frozen-dptf:string input-amount:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ref-MTX-SWP:module{SwapperMtxV4} MTX-SWP)
                )
                (ref-MTX-SWP::C_AddFrozenLiquidity
                    patron account swpair frozen-dptf input-amount stoa-pid
                )
            )
        )
    )
    (defun C_SWP|AddSleepingLiquidity
        (patron:string account:string swpair:string sleeping-dpof:string nonce:integer)
        (with-capability (P|TS)
            (let
                (
                    (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                    (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                    (ref-MTX-SWP:module{SwapperMtxV4} MTX-SWP)
                )
                (ref-MTX-SWP::C_AddSleepingLiquidity
                    patron account swpair sleeping-dpof nonce stoa-pid
                )
            )
        )
    )

)

(create-table P|T)
(create-table P|MT)